/**
 * CRM高度化対応：案件の所有者、合意予定日更新バッチ
 * 更新対象
 * 　・Aヨミ以降の案件
 * 更新内容
 * 　・所有者：紐づくサービス管理の「Aヨミ時の担当者」に突合するユーザ、もしくは案件のBヨミ→Aヨミ更新者
 * 　・合意予定日：Bヨミ→Aヨミ更新日
 */
global class CRMDPUpdOppOwnerIdENP implements Database.Batchable<sObject>, Database.Stateful {
    public Set<Id> opportunityIds;
    public Map<Id, Id> ownerIdMap;
    public Map<Id, Date> contractDateMap;
    private static final String BATCH_NAME = '【CRM高度化】エンプラ案件所有者更新バッチ';
    public Integer targetCount;
    public Integer successCount;

    public CRMDPUpdOppOwnerIdENP() {
        this.opportunityIds = new Set<Id>();
        this.targetCount = 0;
        this.successCount = 0;
    }
    // 処理対象の案件ID指定（リカバリで使用予定）
    public CRMDPUpdOppOwnerIdENP(Set<Id> opportunityIds) {
        this.opportunityIds = opportunityIds;
        this.targetCount = 0;
        this.successCount = 0;
    }

    global static void run(Set<Id> opportunityIds) {
        Logger logger = new Logger();
        Boolean isfileerror = false;

        CRMDPUpdOppOwnerIdENP batch = new CRMDPUpdOppOwnerIdENP(opportunityIds);
        batch.ownerIdMap = new Map<Id, Id>();
        batch.contractDateMap = new Map<Id, Date>();

        // 項目履歴管理データファイル読み込み
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'CRMDPUpdOppOwnerIdENP' LIMIT 1];
        String body = sr.Body.toString();
        Boolean isfirst = true;
        Integer num = 0;
        for(String line : body.split('\n')){
            num++;
            if (isfirst) {
                isfirst = false;
                continue;
            }
            if (String.isBlank(line)) {
                continue;
            }

            String trimline = line.substring(1, line.length() - 1);
            List<String> values = trimline.split('\",\"', -1);

            String oppid = values.get(0);
            String ownerid = values.get(1);
            String contractdate = values.get(2);

            String oldvalue = values.get(3);
            String newvalue = values.get(4);
            // String fieldname = values.get(5);

            if (!'40'.equals(oldvalue) || !'50'.equals(newvalue)) {
                continue;
            }

            // ファイルの値チェック
            List<String> errors = new List<String>();
            if (String.isBlank(oppid)) {
                errors.add('案件IDが空');
            } else {
                try {
                    Id idtest = oppid;
                } catch (Exception ex) {
                    errors.add('案件IDが不正の形式');
                }
            }
            if (String.isBlank(ownerid)) {
                errors.add('更新者IDが空');
            } else {
                try {
                    Id idtest = ownerid;
                } catch (Exception ex) {
                    errors.add('更新者IDが不正の形式');
                }
            }
            if (String.isBlank(contractdate)) {
                errors.add('更新日が空');
            } else {
                try {
                    Date d = Date.valueOf(contractdate);
                } catch (Exception ex) {
                    errors.add('更新日が不正の形式');
                }
            }
            if (errors.size() > 0) {
                logger.error(BATCH_NAME, '【CSVエラー】' + String.valueOf(num) + '行目：' + String.join(errors, '／'), false);
                isfileerror = true;
                continue;
            }

            batch.ownerIdMap.put(oppid, ownerid);

            Date d2 = Date.valueOf(contractdate);
            if (Integer.valueof(contractdate.mid(11,2)) >= 15) {
                d2 = d2.addDays(1);
            }
            batch.contractDateMap.put(oppid, d2);
        }

        if (isfileerror) {
            logger.saveAll();
            return;
        }

        Database.executeBatch(batch, 200);
    }
    global static void run(Map<Id, Id> ownerIdMap, Map<Id, Date> contractDateMap) {
        CRMDPUpdOppOwnerIdENP batch = new CRMDPUpdOppOwnerIdENP();
        batch.ownerIdMap = ownerIdMap;
        batch.contractDateMap = contractDateMap;
        Database.executeBatch(batch, 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String soqlStr = 'SELECT Id, OwnerId, ContractDate__c, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c'
                        + ',(SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress_OpportunityId__r LIMIT 1)'
                        + ' FROM Opportunity WHERE StageName IN (\'50\',\'60\') AND Id IN (SELECT OpportunityId__c FROM OrderProgress__c)';
                        // + ',(SELECT CreatedById, OldValue, NewValue, CreatedDate, OpportunityId FROM Histories WHERE Field = \'StageName\')'
        if (this.opportunityIds.size() > 0) {
            soqlStr += ' AND Id = :opportunityIds';
        }
        return Database.getQueryLocator(soqlStr);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        Logger logger = new Logger();
        try {
            List<Opportunity> updateTarget = new List<Opportunity>();

            Map<Id, String> usernameMap = new Map<Id, String>();
            for (Opportunity opp : oppList) {
                for (OrderProgress__c op : opp.OrderProgress_OpportunityId__r) {
                    if (String.isNotBlank(op.EvaluateeAYomi__c)) {
                        usernameMap.put(opp.Id, op.EvaluateeAYomi__c);
                    }
                }
            }

            // サービス管理の「Aヨミ時の担当者」に突合するユーザ抽出
            Map<String, User> userMap = new Map<String, User>();
            for (User user : [SELECT Id, Name FROM User WHERE Name = :usernameMap.values()]) {
                userMap.put(user.Name, user);
            }

            // 案件更新
            for (Opportunity opp : oppList) {
                Boolean isUpdate = false;
                // 該当ユーザが存在する場合、所有者にセット
                if (usernameMap.containsKey(opp.Id) && userMap.containsKey(usernameMap.get(opp.Id))) {
                    User user = userMap.get(usernameMap.get(opp.Id));
                    if (opp.OwnerId != user.Id) {
                        opp.OwnerId = user.Id;
                        isUpdate = true;
                    }
                // Bヨミ→Aヨミ更新者を所有者にセット
                } else {
                    if (ownerIdMap.containsKey(opp.Id) && ownerIdMap.get(opp.Id) != null) {
                        if (opp.OwnerId != ownerIdMap.get(opp.Id)) {
                            opp.OwnerId = ownerIdMap.get(opp.Id);
                            isUpdate = true;
                        }
                    }
                }
                // 「合意予定日」が空の場合、Bヨミ→Aヨミ更新日を合意予定日にセット
                if (opp.ContractDate__c == null) {
                    if (contractDateMap.containsKey(opp.Id)) {
                        opp.ContractDate__c = contractDateMap.get(opp.Id);
                        isUpdate = true;
                    }
                }
                // サービス管理の「Aヨミ時の担当者の所属部署」に値がある場合、値を分割して案件項目にセット
                for (OrderProgress__c op : opp.OrderProgress_OpportunityId__r) {
                    if (String.isNotBlank(op.EvaluateeDepartmentAYomi__c)) {
                        List<String> values = op.EvaluateeDepartmentAYomi__c.split(' ');
                        if (values.size() > 0 && String.isBlank(opp.EvaluateeAYomiDivision__c) && String.isNotBlank(values.get(0))) {
                            opp.EvaluateeAYomiDivision__c = values.get(0);
                            isUpdate = true;
                        }
                        if (values.size() > 1 && String.isBlank(opp.EvaluateeAYomiDepartment__c) && String.isNotBlank(values.get(1))) {
                            opp.EvaluateeAYomiDepartment__c = values.get(1);
                            isUpdate = true;
                        }
                        if (values.size() > 2 && String.isBlank(opp.EvaluateeAYomiTeam__c) && String.isNotBlank(values.get(2))) {
                            opp.EvaluateeAYomiTeam__c = values.get(2);
                            isUpdate = true;
                        }
                    }
                }

                if (isUpdate) {
                    updateTarget.add(opp);
                }
            }
            this.targetCount += updateTarget.size();

            // レコード更新
            Integer count = 0;
            if (updateTarget.size() > 0) {
                List<Database.SaveResult> results = Database.update(updateTarget, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        count++;
                        continue;
                    }
                    List<String> errMsgs = new List<String>();
                    List<Database.Error> errors = result.getErrors();
                    for(Database.Error e : errors){
                        errMsgs.add(e.getFields() + ':' + e.getMessage() + ':' + e.getStatusCode());
                    }
                    if (errMsgs.size() > 0) {
                        logger.error(BATCH_NAME, String.join(errMsgs, '／'), result.getId(), false);
                    }
                }
                // update updateTarget;
            }
            logger.info(BATCH_NAME, '成功件数：' + count + '/' + updateTarget.size(), false);
            this.successCount += count;
        } catch (Exception ex) {
            logger.error(BATCH_NAME, ex.getMessage() + '/' + ex.getStackTraceString(), false);
        }
        logger.saveAll();
    }

    global void finish(Database.BatchableContext BC) {
        Logger logger = new Logger();
        logger.info(BATCH_NAME, '【処理終了】処理件数：' + this.targetCount + '／成功件数：' + this.successCount, false);
        logger.saveAll();
    }
}