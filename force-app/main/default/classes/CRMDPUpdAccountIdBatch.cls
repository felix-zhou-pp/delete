/**
 * CRM高度化対応：取引先の参照更新バッチ
 * 更新対象
 * 　・PP加盟店の法人名と紐づく取引先名が異なる
 * 更新内容
 * 　・PP加盟店の参照するPPアタックリスト〜案件の取引先参照をPP加盟店の法人名に突合する取引先に更新
 */
global class CRMDPUpdAccountIdBatch implements Database.Batchable<sObject>, Database.Stateful {
    private static final String BATCH_NAME = '【CRM高度化】エンプラ取引先参照更新バッチ';
    public Set<Id> opportunityIds;
    public Set<Id> oppIdsTarget;
    public Set<Id> oppIdsSuccess;
    public Set<Id> oppIdsFailed;
    public Set<Id> opIdsTarget;
    public Set<Id> opIdsSuccess;
    public Set<Id> opIdsFailed;
    public Set<Id> oppIdsManualTarget;
    public Set<Id> oppIdsManualSuccess;
    public Set<Id> oppIdsManualFailed;

    public CRMDPUpdAccountIdBatch() {
        this.opportunityIds = new Set<Id>();
        this.oppIdsTarget = new Set<Id>();
        this.oppIdsSuccess = new Set<Id>();
        this.oppIdsFailed = new Set<Id>();
        this.opIdsTarget = new Set<Id>();
        this.opIdsSuccess = new Set<Id>();
        this.opIdsFailed = new Set<Id>();
        this.oppIdsManualTarget = new Set<Id>();
        this.oppIdsManualSuccess = new Set<Id>();
        this.oppIdsManualFailed = new Set<Id>();
    }
    // 処理対象のPP加盟店のID指定（リカバリで使用予定）
    public CRMDPUpdAccountIdBatch(Set<Id> opportunityIds) {
        this.opportunityIds = opportunityIds;
        this.oppIdsTarget = new Set<Id>();
        this.oppIdsSuccess = new Set<Id>();
        this.oppIdsFailed = new Set<Id>();
        this.opIdsTarget = new Set<Id>();
        this.opIdsSuccess = new Set<Id>();
        this.opIdsFailed = new Set<Id>();
        this.oppIdsManualTarget = new Set<Id>();
        this.oppIdsManualSuccess = new Set<Id>();
        this.oppIdsManualFailed = new Set<Id>();
    }

    global static void run() {
        Database.executeBatch(new CRMDPUpdAccountIdBatch(), 200);
    }
    global static void run(Set<Id> opportunityIds) {
        Database.executeBatch(new CRMDPUpdAccountIdBatch(opportunityIds), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String soqlStr = 'SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c'
                        + ',(SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c FROM OrderProgress_OpportunityId__r WHERE MyStoreRelation__c = null AND CopyOrderProgressId__c = null)'
                        + ' FROM Opportunity';
        if (this.opportunityIds.size() > 0) {
            soqlStr += ' WHERE Id = :opportunityIds';
        } else {
            soqlStr += ' WHERE CRMDPBeforeAccount__c = null';
        }
        return Database.getQueryLocator(soqlStr);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        Logger logger = new Logger();

        Set<Id> oppIdsTargetInBatch = new Set<Id>();
        Set<Id> oppIdsSuccessInBatch = new Set<Id>();
        Set<Id> oppIdsFailedInBatch = new Set<Id>();
        Set<Id> opIdsSuccessInBatch = new Set<Id>();
        Set<Id> opIdsFailedInBatch = new Set<Id>();
        Set<Id> oppIdsManualTargetInBatch = new Set<Id>();
        Set<Id> oppIdsManualSuccessInBatch = new Set<Id>();
        Set<Id> oppIdsManualFailedInBatch = new Set<Id>();

        Set<String> mbRecordType = new Set<String>{
            Constant.ORDP_DEVELOPER_NAME_PLC
            ,Constant.ORDP_DEVELOPER_NAME_ONLINE_PLC
            ,Constant.ORDP_DEVELOPER_NAME_REVISITING_COUPON
            ,Constant.ORDP_DEVELOPER_NAME_SCHEDULED_COUPON
            ,Constant.ORDP_DEVELOPER_NAME_SC
            ,Constant.ORDP_DEVELOPER_NAME_FLYER_APPLY
            ,'FlyerDraft'
            ,Constant.ORDP_DEVELOPER_NAME_PAAS
            ,Constant.ORDP_DEVELOPER_NAME_PC
            ,Constant.ORDP_DEVELOPER_NAME_CAMPAIGN
            ,Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE_MYSTORE
            ,Constant.ORDP_DEVELOPER_NAME_MINI_APP
            ,Constant.ORDP_DEVELOPER_NAME_BALANCEAPI
            ,Constant.ORDP_DEVELOPER_NAME_SPECIFIC_PRODUCT_COUPON
            ,'ServiceCommon'
            ,Constant.ORDP_DEVELOPER_NAME_ROUTEOPENING
            ,Constant.ORDP_DEVELOPER_NAME_RETAILGIFT
            ,Constant.ORDP_DEVELOPER_NAME_LYPMILEAGE
            ,Constant.ORDP_DEVELOPER_NAME_GIFTCARD
            // ,Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER
            // ,Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE
            // ,Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB
        };
        Set<String> opRecordType = new Set<String>{
            Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER
            ,Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE
            ,Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE
            ,'US_SS'
            ,Constant.ORDP_DEVELOPER_NAME_ENP_ONLINE
            ,Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER_VENDING
            ,Constant.ORDP_DEVELOPER_NAME_ENPMALL_ONLINE
            ,Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB
            ,'RecordTypeOfflineSmallBusiness'
            ,'RecordTypeOnlineSmallBusiness'
            ,Constant.ORDP_DEVELOPER_NAME_ENP_ONLINE_MANAGE
        };

        try {
            // 子のサービス管理とそれに紐づく案件取得
            Set<Id> parentopids = new Set<Id>();
            Set<Id> childoppids = new Set<Id>();
            for (Opportunity opp : oppList) {
                for (OrderProgress__c op : opp.OrderProgress_OpportunityId__r) {
                    parentopids.add(op.Id);
                }
            }
            Map<Id, List<OrderProgress__c>> childopMap = new Map<Id, List<OrderProgress__c>>();
            for (OrderProgress__c op : [SELECT Id, OpportunityId__c, AccountId__c, MyStoreRelation__c, CopyOrderProgressId__c FROM OrderProgress__c WHERE MyStoreRelation__c = :parentopids OR CopyOrderProgressId__c = :parentopids]) {
                Id id = op.MyStoreRelation__c != null ? op.MyStoreRelation__c : op.CopyOrderProgressId__c;
                List<OrderProgress__c> childs = childopMap.containsKey(id) ? childopMap.get(id) : new List<OrderProgress__c>();
                childs.add(op);
                childopMap.put(id, childs);
                childoppids.add(op.OpportunityId__c);
            }
            Map<Id, Opportunity> childoppMap = new Map<Id, Opportunity>([SELECT Id, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :childoppids]);

            // 更新先の取引先取得
            Set<String> cns = new Set<String>();
            Map<Id, String> midMap = new Map<Id, String>();

            // 案件法人番号、ないものは加盟店事業のメインMID抽出
            for (Opportunity opp : oppList) {
                if (opp.OrderProgress_OpportunityId__r.size() < 1) {
                    continue;
                } else if (String.isNotBlank(opp.CorporateNumber__c)) {
                    cns.add(opp.CorporateNumber__c);
                } else {
                    Boolean isKameiten = false;
                    Set<String> mids = new Set<String>();
                    for (OrderProgress__c op : opp.OrderProgress_OpportunityId__r) {
                        if (opRecordType.contains(op.RecordType.DeveloperName)) {
                            continue;
                        }
                        isKameiten = true;
                        if (String.isNotBlank(op.MainMID__c)) {
                            mids.add(op.MainMID__c);
                        }
                    }

                    if (!isKameiten) {
                        continue;
                    }

                    if (mids.isEmpty()) {
                        logger.error(BATCH_NAME + '：メインMIDがない案件', opp.AccountId, opp.Id, false);
                        oppIdsManualTargetInBatch.add(opp.Id);
                    } else if (mids.size() > 1) {
                        logger.error(BATCH_NAME + '：メインMIDが複数ある案件', 'MID：' + String.join(mids, ','), opp.Id, false);
                        oppIdsManualTargetInBatch.add(opp.Id);
                    } else {
                        String mid = '';
                        for (String s : mids) {
                            mid = s;
                        }
                        midMap.put(opp.Id, mid);
                    }
                }
            }

            // 法人番号で取引先抽出
            Map<String, Set<Id>> cnAccIdMap = new Map<String, Set<Id>>();
            for (Account acc : [SELECT Id, CorporateNumber__c FROM Account WHERE RecordType.DeveloperName = 'AccountRecordType_MemberStore' AND CorporateNumber__c = :cns]) {
                Set<Id> accids = cnAccIdMap.containsKey(acc.CorporateNumber__c) ? cnAccIdMap.get(acc.CorporateNumber__c) : new Set<Id>();
                accids.add(acc.Id);
                cnAccIdMap.put(acc.CorporateNumber__c, accids);
            }

            // メインMIDでリレーションの取引先抽出
            Map<String, Id> midAccIdMap = new Map<String, Id>();
            for (CompanyInfo_UniqueId_Relation__c cur : [SELECT Id, CompanyInfoId__c, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE UniqueId__c = :midMap.values() AND Account__c != null]) {
                midAccIdMap.put(cur.UniqueId__c, cur.Account__c);
            }

            // 更新値セット
            List<Opportunity> updateOpps = new List<Opportunity>();
            List<OrderProgress__c> updateOps = new List<OrderProgress__c>();
            List<Opportunity> updateOppsManual = new List<Opportunity>();
            Map<Id, Id> opidoppidMap = new Map<Id, Id>();

            for (Opportunity opp : oppList) {
                if (opp.OrderProgress_OpportunityId__r.size() < 1) {
                    continue;
                }

                // データ不備
                if (oppIdsManualTargetInBatch.contains(opp.Id)) {
                    opp.CRMDPBeforeAccount__c = opp.AccountId;
                    updateOppsManual.add(opp);
                    continue;
                }

                Id accid = null;
                if (String.isNotBlank(opp.CorporateNumber__c)) {
                    if (!cnAccIdMap.containsKey(opp.CorporateNumber__c)) {
                        opp.CRMDPBeforeAccount__c = opp.AccountId;
                        updateOppsManual.add(opp);
                        logger.error(BATCH_NAME + '：法人番号の取引先がない案件', opp.AccountId, opp.Id, false);
                        oppIdsManualTargetInBatch.add(opp.Id);
                        continue;
                    }
                    Set<Id> accids = cnAccIdMap.get(opp.CorporateNumber__c);
                    if (accids.size() > 1) {
                        opp.CRMDPBeforeAccount__c = opp.AccountId;
                        updateOppsManual.add(opp);
                        logger.error(BATCH_NAME + '：法人番号で取引先が複数抽出された案件', '付け直し先：' + String.join(accids, ','), opp.Id, false);
                        oppIdsManualTargetInBatch.add(opp.Id);
                        continue;
                    }
                    for (Id id : accids) {
                        accid = id;
                    }
                } else {
                    if (!midMap.containsKey(opp.Id)) {
                        continue;
                    }
                    String mid = midMap.get(opp.Id);
                    if (!midAccIdMap.containsKey(mid)) {
                        opp.CRMDPBeforeAccount__c = opp.AccountId;
                        updateOppsManual.add(opp);
                        logger.error(BATCH_NAME + '：メインMIDの取引先がない案件', opp.AccountId, opp.Id, false);
                        oppIdsManualTargetInBatch.add(opp.Id);
                        continue;
                    }
                    accid = midAccIdMap.get(mid);
                }

                // 処理対象外にならず取引先がセットできなかったものはエラー（ないはず）
                if (accid == null) {
                    logger.error(BATCH_NAME + '：取引先抽出処理エラー', '抽出対象がありそうで処理に失敗、原因不明', opp.Id, false);
                    continue;
                }

                // レコードに値セット
                if (opp.AccountId != accid || opp.CRMDPBeforeAccount__c == null) {
                    opp.CRMDPBeforeAccount__c = opp.AccountId;
                    opp.AccountId = accid;
                    updateOpps.add(opp);
                    oppIdsTargetInBatch.add(opp.Id);
                }
                for (OrderProgress__c op : opp.OrderProgress_OpportunityId__r) {
                    if (op.AccountId__c != accid) {
                        op.AccountId__c = accid;
                        updateOps.add(op);
                        opidoppidMap.put(op.Id, opp.Id);
                    }
                    if (childopMap.containsKey(op.Id)) {
                        for (OrderProgress__c op2 : childopMap.get(op.Id)) {
                            if (!opidoppidMap.containsKey(op2.Id) && op2.AccountId__c != accid) {
                                op2.AccountId__c = accid;
                                updateOps.add(op2);
                                opidoppidMap.put(op2.Id, opp.Id);
                            }
                            if (!oppIdsTargetInBatch.contains(op2.OpportunityId__c) && childoppMap.containsKey(op2.OpportunityId__c)) {
                                Opportunity opp2 = childoppMap.get(op2.OpportunityId__c);
                                if (opp2.AccountId != accid || opp2.CRMDPBeforeAccount__c == null) {
                                    opp2.CRMDPBeforeAccount__c = opp2.AccountId;
                                    opp2.AccountId = accid;
                                    updateOpps.add(opp2);
                                    oppIdsTargetInBatch.add(opp2.Id);
                                }
                            }
                        }
                    }
                }
            }

            // 更新
            if (updateOpps.size() > 0) {
                List<Database.SaveResult> results = Database.update(updateOpps, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        oppIdsSuccessInBatch.add(result.getId());
                        continue;
                    }
                    List<String> errMsgs = new List<String>();
                    List<Database.Error> errors = result.getErrors();
                    for(Database.Error e : errors){
                        errMsgs.add(e.getFields() + ':' + e.getMessage() + ':' + e.getStatusCode());
                    }
                    if (errMsgs.size() > 0) {
                        oppIdsFailedInBatch.add(result.getId());
                        logger.error(BATCH_NAME + '：案件更新エラー', String.join(errMsgs, '／'), result.getId(), false);
                    }
                }
                // update updateOpps;
            }
            if (updateOps.size() > 0) {
                List<Database.SaveResult> results = Database.update(updateOps, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        opIdsSuccessInBatch.add(result.getId());
                        continue;
                    }
                    List<String> errMsgs = new List<String>();
                    List<Database.Error> errors = result.getErrors();
                    for(Database.Error e : errors){
                        errMsgs.add(e.getFields() + ':' + e.getMessage() + ':' + e.getStatusCode());
                    }
                    if (errMsgs.size() > 0) {
                        opIdsFailedInBatch.add(result.getId());
                        logger.error(BATCH_NAME + '：サービス管理更新エラー', 'サービス管理ID：' + result.getId() +  '／' + String.join(errMsgs, '／'), opidoppidMap.get(result.getId()), false);
                    }
                }
                // update updateOps;
            }
            if (updateOppsManual.size() > 0) {
                List<Database.SaveResult> results = Database.update(updateOppsManual, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        oppIdsManualSuccessInBatch.add(result.getId());
                        continue;
                    }
                    List<String> errMsgs = new List<String>();
                    List<Database.Error> errors = result.getErrors();
                    for(Database.Error e : errors){
                        errMsgs.add(e.getFields() + ':' + e.getMessage() + ':' + e.getStatusCode());
                    }
                    if (errMsgs.size() > 0) {
                        oppIdsManualFailedInBatch.add(result.getId());
                        logger.error(BATCH_NAME + '：案件処理済み更新エラー（手動対応分）', String.join(errMsgs, '／'), result.getId(), false);
                    }
                }
                // update updateOps;
            }

            this.oppIdsTarget.addAll(oppIdsTargetInBatch);
            this.oppIdsSuccess.addAll(oppIdsSuccessInBatch);
            this.oppIdsFailed.addAll(oppIdsFailedInBatch);
            this.opIdsTarget.addAll(opidoppidMap.keySet());
            this.opIdsSuccess.addAll(opIdsSuccessInBatch);
            this.opIdsFailed.addAll(opIdsFailedInBatch);
            this.oppIdsManualTarget.addAll(oppIdsManualTargetInBatch);
            this.oppIdsManualSuccess.addAll(oppIdsManualSuccessInBatch);
            this.oppIdsManualFailed.addAll(oppIdsManualFailedInBatch);

            String log = '【対象件数】案件:' + oppIdsTargetInBatch.size() + '／サービス管理：' + opidoppidMap.size() + '／案件（手動確認）：' + oppIdsManualTargetInBatch.size()
                        + '【成功件数】案件:' + oppIdsSuccessInBatch.size() + '／サービス管理：' + opIdsSuccessInBatch.size() + '／案件（手動確認）：' + oppIdsManualSuccessInBatch.size()
                        + '【失敗件数】案件:' + oppIdsFailedInBatch.size() + '／サービス管理：' + opIdsFailedInBatch.size() + '／案件（手動確認）：' + oppIdsManualFailedInBatch.size();
            logger.info(BATCH_NAME, log, false);

        } catch (Exception ex) {
            logger.error(BATCH_NAME, ex.getMessage() + '/' + ex.getStackTraceString(), false);
        }
        logger.saveAll();
    }

    global void finish(Database.BatchableContext BC) {
        Logger logger = new Logger();
        String log = '【対象総件数】案件:' + this.oppIdsTarget.size() + '／サービス管理：' + this.opIdsTarget.size() + '／案件（手動確認）：' + this.oppIdsManualTarget.size()
                    + '【成功総件数】案件:' + this.oppIdsSuccess.size() + '／サービス管理：' + this.opIdsSuccess.size() + '／案件（手動確認）：' + this.oppIdsManualSuccess.size()
                    + '【失敗総件数】案件:' + this.oppIdsFailed.size() + '／サービス管理：' + this.opIdsFailed.size() + '／案件（手動確認）：' + this.oppIdsManualFailed.size();
        logger.info(BATCH_NAME + '：処理終了', log, false);
        logger.saveAll();
    }
}