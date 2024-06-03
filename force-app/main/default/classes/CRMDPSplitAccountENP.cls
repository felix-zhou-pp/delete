/**
 * CRM高度化対応：エンプラ取引先分割のバッチ
 * 更新対象
 * 　・CSVファイルに記載された企業IDを持つ取引先
 * 更新内容
 * 　・CSVファイルの通り（企業IDと案件所有者毎）に取引先を作成、該当の案件以下のオブジェクトの取引先参照を更新
 */
global class CRMDPSplitAccountENP implements Database.Batchable<sObject>, Database.Stateful {
    public Set<Id> fileAccIds;
    public Set<String> fileAccNames;
    public Set<Id> fileOppIds;
    public Map<Id, Map<String, Set<Id>>> splitMap;
    public Map<String, String> splitRankMap;

    public Set<Id> targetParentAccIds;
    public Set<Id> targetSplitAccIds;
    public Set<Id> targetOppIds;

    public Map<Id, Id> oppAccIdMap;
    public Integer splitExecuteMpOppCount;

    private static final String BATCH_NAME = '【CRM高度化】エンプラ取引先分割バッチ';

    public CRMDPSplitAccountENP() {
        this.fileAccIds = new Set<Id>();
        this.fileAccNames = new Set<String>();
        this.fileOppIds = new Set<Id>();
        this.splitMap = new Map<Id, Map<String, Set<Id>>>();
        this.splitRankMap = new Map<String, String>();
        this.targetParentAccIds = new Set<Id>();
        this.targetSplitAccIds = new Set<Id>();
        this.targetOppIds = new Set<Id>();
        this.oppAccIdMap = new Map<Id, Id>();
        this.splitExecuteMpOppCount = 0;
    }

    // 静的リソースからCSV（更新に使用する値）読み込み、バッチ起動
    global static void run(Set<Id> targetAccids) {
        Logger logger = new Logger();
        Boolean isfileerror = false;

        CRMDPSplitAccountENP batch = new CRMDPSplitAccountENP();

        // TODO: ファイルフォーマット待ち
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'CRMDPSplitAccountENP' LIMIT 1];
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

            String accid = values.get(0);
            String oppidstr = values.get(7);
            String name = values.get(2);
            String rank = values.get(3);
            Set<Id> oppidsline = new Set<Id>();

            if (targetAccids.size() > 0 && !targetAccids.contains(accid)) {
                continue;
            }

            // ファイルの値チェック
            List<String> errors = new List<String>();
            if (String.isBlank(accid)) {
                errors.add('取引先IDが空');
            } else {
                try {
                    Id idtest = accid;
                } catch (Exception ex) {
                    errors.add('取引先IDが不正の形式');
                }
            }
            if (String.isBlank(name)) {
                errors.add('取引先名が空');
            }
            if (String.isNotBlank(oppidstr)) {
                try {
                    for (String idstr : oppidstr.split(',')) {
                        Id idtest = idstr;
                        oppidsline.add(idtest);
                    }
                } catch (Exception ex) {
                    errors.add('案件IDが不正の形式');
                }
            }
            if (errors.size() > 0) {
                logger.error(BATCH_NAME, '【CSVエラー】' + String.valueOf(num) + '行目：' + String.join(errors, '／'), false);
                isfileerror = true;
                continue;
            }

            // 処理対象の企業ID
            batch.fileAccIds.add(accid);

            batch.fileAccNames.add(accid + name);

            // 処理対象の企業ID（取引先）に紐づく案件所有者
            Map<String, Set<Id>> splitNameMap = batch.splitMap.containsKey(accid) ? batch.splitMap.get(accid) : new Map<String, Set<Id>>();
            Set<Id> oppids = splitNameMap.containsKey(name) ? splitNameMap.get(name) : new Set<Id>();
            oppids.addAll(oppidsline);
            splitNameMap.put(name, oppids);
            batch.splitMap.put(accid, splitNameMap);

            batch.fileOppIds.addAll(oppids);

            // 分割取引先のランク
            String key = accid + name;
            if (!batch.splitRankMap.containsKey(key) && String.isNotEmpty(rank)) {
                batch.splitRankMap.put(key, rank);
            }
        }

        if (isfileerror) {
            logger.saveAll();
            return;
        }

        logger.info(BATCH_NAME, '【バッチ開始】処理対象の親取引先：' + batch.fileAccIds.size() + '／作成予定の分割取引先：' + batch.fileAccNames.size() + '／紐付け更新の案件：' + batch.fileOppIds.size(), false);
        logger.saveAll();

        Database.executeBatch(batch, 1);
    }

    // テストクラス用（CSV読み込みせず直接値を代入）
    global static void run(Set<Id> fileAccIds, Map<Id, Map<String, Set<Id>>> splitMap, Map<String, String> splitRankMap) {
        CRMDPSplitAccountENP batch = new CRMDPSplitAccountENP();
        batch.fileAccIds = fileAccIds;
        batch.splitMap = splitMap;
        batch.splitRankMap = splitRankMap;
        Database.executeBatch(batch, 100);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe();
        Schema.SObjectType s = m.get('Account');
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField> fields = r.fields.getMap();

        // 分割後の取引先は分割元をコピーして作成するため全項目抽出
        String soqlStr = 'SELECT ' + String.join(fields.keyset(), ',')
                        + ',(SELECT Id, AccountId FROM Opportunities)'
                        + ',(SELECT Id FROM ChildAccounts WHERE CRMDPIsSplit__c = TRUE)'
                        + ' FROM Account'
                        + ' WHERE Id = :fileAccIds';
        return Database.getQueryLocator(soqlStr);
    }

    // TODO: 中小がいるなどの個店判定になる取引先が出てくる、対象外にする処理を追加するかも
    global void execute(Database.BatchableContext BC, List<Account> accList) {
        Logger logger = new Logger();

        Set<Id> targetAccIds = new Set<Id>();

        Set<Id> targetParentAccIdsInBatch = new Set<Id>();
        Set<Id> targetSplitAccIdsInBatch = new Set<Id>();
        Set<Id> targetOppIdsInBatch = new Set<Id>();

        Map<Id, Set<Id>> notSplitOppMap = new Map<Id, Set<Id>>();

        Savepoint sp = Database.setSavepoint();
        try {
            Map<String, Account> accMap = new Map<String, Account>();
            // 企業IDと案件所有者毎に分割取引先の作成
            for (Account acc : accList) {
                targetAccIds.add(acc.Id);
                if (acc.ChildAccounts.size() > 0) {
                    // 分割済みのため処理終了
                    return;
                }

                for (String name : splitMap.get(acc.Id).keySet()) {
                    String key = acc.Id + name;
                    Account cloneacc = acc.clone(false, true);
                    // ファイルに指定の値
                    cloneacc.Name = name;
                    cloneacc.Rank__c = splitRankMap.get(key);
                    cloneacc.ParentId = acc.Id;
                    cloneacc.CRMDPIsSplit__c = true;
                    accMap.put(key, cloneacc);
                }
            }

            // 分割取引先作成
            if (accMap.size() > 0) {
                insert accMap.values();
            } else {
                logger.error(BATCH_NAME + '：処理中断', '【分割取引先作成対象なし】親取引先ID：' + String.join(targetAccIds, ','), false);
                logger.saveAll();
                return;
            }

            // 取引先ID情報セット（ログ用）
            for (String key : accMap.keySet()) {
                Account acc = accMap.get(key);
                targetParentAccIdsInBatch.add(acc.ParentId);
                targetSplitAccIdsInBatch.add(acc.Id);
            }

            // ファイルの案件ID抽出
            Set<Id> targetOppIds = new Set<Id>();
            for (Account acc : accList) {
                Map<String, Set<Id>> splitNameMap = splitMap.get(acc.Id);
                for (String name : splitNameMap.keySet()) {
                    targetOppIds.addAll(splitNameMap.get(name));
                }
            }

            // 該当する案件抽出
            Map<Id, Opportunity> targetOpps = new Map<Id, Opportunity>();
            for (Account acc : accList) {
                for (Opportunity opp : acc.Opportunities) {
                    if (targetOppIds.contains(opp.Id)) {
                        targetOpps.put(opp.Id, opp);
                        targetOppIdsInBatch.add(opp.Id);
                    } else {
                        Set<Id> notSplitOpps = notSplitOppMap.containsKey(acc.Id) ? notSplitOppMap.get(acc.Id) : new Set<Id>();
                        notSplitOpps.add(opp.Id);
                        notSplitOppMap.put(acc.Id, notSplitOpps);
                    }
                }
            }

            if (notSplitOppMap.size() > 0) {
                // 未分割案件がある場合ログ出力
                for (Id accid : notSplitOppMap.keySet()) {
                    Set<Id> oppids = notSplitOppMap.get(accid);
                    logger.error(BATCH_NAME + '：処理中断', '【未分割案件】親取引先ID：' + accid + '／未分割案件ID：' + String.join(oppids, ','), false);
                }

                Database.rollback(sp);
                logger.saveAll();
                return;
            }

            Map<Id, List<OrderProgress__c>> targetOps = new Map<Id, List<OrderProgress__c>>();
            Map<Id, List<mpOpportunity__c>> targetMpOpps = new Map<Id, List<mpOpportunity__c>>();
            Map<Id, List<mpMerchant__c>> targetMers = new Map<Id, List<mpMerchant__c>>();
            Map<String, CompanyInfo_UniqueId_Relation__c> targetCurs = new Map<String, CompanyInfo_UniqueId_Relation__c>();
            Integer mpoppCount = 0;

            if (targetOppIds.size() > 0) {
                // 案件配下のサービス管理抽出
                for (OrderProgress__c op : [SELECT Id, OpportunityId__c, AccountId__c FROM OrderProgress__c WHERE OpportunityId__c = :targetOppIds]) {
                    Id oppId = op.OpportunityId__c;
                    List<OrderProgress__c> ops = targetOps.containsKey(oppId) ? targetOps.get(oppId) : new List<OrderProgress__c>();
                    ops.add(op);
                    targetOps.put(oppId, ops);
                }

                // 包括代理店データのアタックリスト、加盟店、リレーションは更新対象外
                Set<String> excludeOpRecordType = new Set<String>{
                    Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER
                    ,Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE
                    ,Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB
                };
                // バッチ内の処理予定件数抽出
                for (AggregateResult ar : [
                    SELECT COUNT(Id) ct FROM mpOpportunity__c
                    WHERE OrderProgressId__r.OpportunityId__c = :targetOppIds AND OrderProgressId__r.RecordType.DeveloperName != :excludeOpRecordType
                    GROUP BY OrderProgressId__r.OpportunityId__c
                ]) {
                    mpoppCount += Integer.valueOf(ar.get('ct'));
                }

                // アタックリストが3000件以上は別バッチで更新する
                if (mpoppCount <= 3000) {
                    for (mpOpportunity__c mpopp : [
                        SELECT Id, OrderProgressId__r.OpportunityId__c, AccountId__c FROM mpOpportunity__c
                        WHERE OrderProgressId__r.OpportunityId__c = :targetOppIds AND OrderProgressId__r.RecordType.DeveloperName != :excludeOpRecordType
                    ]) {
                        Id oppId = mpopp.OrderProgressId__r.OpportunityId__c;
                        List<mpOpportunity__c> mpopps = targetMpOpps.containsKey(oppId) ? targetMpOpps.get(oppId) : new List<mpOpportunity__c>();
                        mpopps.add(mpopp);
                        targetMpOpps.put(oppId, mpopps);
                    }
                    Set<String> targetMids = new Set<String>();
                    for (mpMerchant__c mer : [
                        SELECT Id, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, AccountId__c, MerchantId__c FROM mpMerchant__c
                        WHERE mpOpportunity__r.OrderProgressId__r.OpportunityId__c = :targetOppIds AND mpOpportunity__r.OrderProgressId__r.RecordType.DeveloperName != :excludeOpRecordType
                    ]) {
                        Id oppId = mer.mpOpportunity__r.OrderProgressId__r.OpportunityId__c;
                        List<mpMerchant__c> mers = targetMers.containsKey(oppId) ? targetMers.get(oppId) : new List<mpMerchant__c>();
                        mers.add(mer);
                        targetMers.put(oppId, mers);
                        targetMids.add(mer.MerchantId__c);
                    }
                    for (CompanyInfo_UniqueId_Relation__c cur : [SELECT Id, UniqueId__c, Account__c, SFReplacementCandidateFlag__c FROM CompanyInfo_UniqueId_Relation__c WHERE UniqueId__c = :targetMids]) {
                        targetCurs.put(cur.UniqueId__c, cur);
                    }
                }
            }

            // 取引先参照更新
            List<Opportunity> updateOpps = new List<Opportunity>();
            List<OrderProgress__c> updateOps = new List<OrderProgress__c>();
            List<mpOpportunity__c> updateMpOpps = new List<mpOpportunity__c>();
            List<mpMerchant__c> updateMers = new List<mpMerchant__c>();
            List<CompanyInfo_UniqueId_Relation__c> updateCurs = new List<CompanyInfo_UniqueId_Relation__c>();
            Map<Id, Id> oppAccIdMapInBatch = new Map<Id, Id>();
            for (Account acc : accList) {
                Map<String, Set<Id>> splitNameMap = splitMap.get(acc.Id);
                for (String name : splitNameMap.keySet()) {
                    Account splitacc = accMap.get(acc.Id + name);
                    for (Id oppId : splitNameMap.get(name)) {
                        if (!targetOpps.containsKey(oppId)) {
                            logger.error(BATCH_NAME, '【ファイル不備】SFに存在しない案件ID：' + oppId + '／親取引先ID：' + acc.Id, false);
                            continue;
                        }
                        Opportunity opp = targetOpps.get(oppId);
                        opp.AccountId = splitacc.Id;
                        updateOpps.add(opp);
                        oppAccIdMapInBatch.put(opp.Id, splitacc.Id);
                        if (targetOps.containsKey(oppId)) {
                            for (OrderProgress__c op : targetOps.get(oppId)) {
                                op.AccountId__c = splitacc.Id;
                                updateOps.add(op);
                            }
                        }
                        if (targetMpOpps.containsKey(oppId)) {
                            for (mpOpportunity__c mpopp : targetMpOpps.get(oppId)) {
                                mpopp.AccountId__c = splitacc.Id;
                                updateMpOpps.add(mpopp);
                            }
                        }
                        if (targetMers.containsKey(oppId)) {
                            for (mpMerchant__c mer : targetMers.get(oppId)) {
                                mer.AccountId__c = splitacc.Id;
                                updateMers.add(mer);
                                if (targetCurs.containsKey(mer.MerchantId__c)) {
                                    CompanyInfo_UniqueId_Relation__c cur = targetCurs.get(mer.MerchantId__c);
                                    // cur.Account__c = splitacc.Id;
                                    cur.SFReplacementCandidateFlag__c = true;
                                    updateCurs.add(cur);
                                } else {
                                    logger.error(BATCH_NAME, '【リレーションデータ不備】存在しないMID：' + mer.MerchantId__c, false);
                                }
                            }
                        }
                    }
                }
            }

            if (updateOpps.size() > 0) {
                update updateOpps;
            }
            if (updateOps.size() > 0) {
                update updateOps;
            }
            if (updateMpOpps.size() > 0) {
                update updateMpOpps;
            }
            if (updateMers.size() > 0) {
                update updateMers;
            }
            if (updateCurs.size() > 0) {
                update updateCurs;
            }

            // アタックリスト以下の更新量が多いものは別バッチで処理（案件IDと分割取引先IDのセットでアタックリスト以下を更新する）
            if (mpoppCount > 3000) {
                if (oppAccIdMapInBatch.size() > 0) {
                    logger.info(BATCH_NAME, '【分岐バッチ処理予定】取引先ID：' + String.join(targetAccIds, ',') + '／アタックリスト件数：' + mpoppCount, false);
                    logger.info(BATCH_NAME, '【分岐バッチ引数】' + JSON.serialize(oppAccIdMapInBatch), false);
                    oppAccIdMap.putAll(oppAccIdMapInBatch);
                    splitExecuteMpOppCount += mpoppCount;
                } else {
                    logger.error(BATCH_NAME, '【分岐バッチ起動不可】oppAccIdMapに値がない（ファイルの案件IDがSFに1件もない）', false);
                }
            }

            String log = '取引先ID' + String.join(targetAccIds, ',')
                        + '／作成分割取引先：' + targetSplitAccIdsInBatch.size()
                        + '／更新案件：' + targetOppIdsInBatch.size()
                        + '／更新サービス管理：' + updateOps.size()
                        + '／更新アタックリスト：' + updateMpOpps.size()
                        + '／更新加盟店：' + updateMers.size()
                        + '／更新リレーション：' + updateCurs.size();
            logger.info(BATCH_NAME, log, false);

            this.targetParentAccIds.addAll(targetParentAccIdsInBatch);
            this.targetSplitAccIds.addAll(targetSplitAccIdsInBatch);
            this.targetOppIds.addAll(targetOppIdsInBatch);
        } catch (Exception ex) {
            Database.rollback(sp);
            logger.error(BATCH_NAME, ex.getMessage() + '/' + ex.getStackTraceString(), false);
        }
        logger.saveAll();
    }

    global void finish(Database.BatchableContext BC) {
        Logger logger = new Logger();
        String log = '【バッチ終了】処理対象の親取引先：' + this.targetParentAccIds.size() + '／作成分割取引先：' + this.targetSplitAccIds.size() + '／更新案件：' + this.targetOppIds.size();
        logger.info(BATCH_NAME, log, false);

        if (oppAccIdMap.size() > 0) {
            logger.info(BATCH_NAME, '【分岐バッチ起動】処理対象のアタックリスト：' + splitExecuteMpOppCount, false);
            Database.executeBatch(new CRMDPSplitAccountENP2(oppAccIdMap), 200);
        }
        logger.saveAll();
    }
}