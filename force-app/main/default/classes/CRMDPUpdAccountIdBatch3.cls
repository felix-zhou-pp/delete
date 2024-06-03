/**
 * CRM高度化対応：取引先の参照更新バッチ
 * 更新対象
 * 　・PP加盟店の法人名と紐づく取引先名が異なる
 * 更新内容
 * 　・PP加盟店の参照するPPアタックリスト〜案件の取引先参照をPP加盟店の法人名に突合する取引先に更新
 */
global class CRMDPUpdAccountIdBatch3 implements Database.Batchable<sObject>, Database.Stateful {
    public Set<Id> merchantIds;
    private static final String BATCH_NAME = '【CRM高度化】エンプラ取引先参照更新バッチ3';
    public Integer targetMpOppCnt;
    public Integer targetMerCnt;
    public Integer successMpOppCnt;
    public Integer successMerCnt;
    public Integer failedMpOppCnt;
    public Integer failedMerCnt;

    public CRMDPUpdAccountIdBatch3() {
        this.merchantIds = new Set<Id>();
        this.targetMpOppCnt = 0;
        this.targetMerCnt = 0;
        this.successMpOppCnt = 0;
        this.successMerCnt = 0;
        this.failedMpOppCnt = 0;
        this.failedMerCnt = 0;
    }
    // 処理対象のPP加盟店のID指定（リカバリで使用予定）
    public CRMDPUpdAccountIdBatch3(Set<Id> merchantIds) {
        this.merchantIds = merchantIds;
        this.targetMpOppCnt = 0;
        this.targetMerCnt = 0;
        this.successMpOppCnt = 0;
        this.successMerCnt = 0;
        this.failedMpOppCnt = 0;
        this.failedMerCnt = 0;
    }

    global static void run() {
        Database.executeBatch(new CRMDPUpdAccountIdBatch3(), 200);
    }
    global static void run(Set<Id> merchantIds) {
        Database.executeBatch(new CRMDPUpdAccountIdBatch3(merchantIds), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String soqlStr = 'SELECT Id, AccountId__c, MerchantId__c'
                        + ',mpOpportunity__r.AccountId__c'
                        + ',mpOpportunity__c'
                        + ',mpOpportunity__r.OrderProgressId__r.OpportunityId__r.RecordType.DeveloperName'
                        + ' FROM mpMerchant__c'
                        + ' WHERE mpOpportunity__r.OrderProgressId__r.OpportunityId__c != null'
                        + ' AND MerchantId__c != null';
        if (this.merchantIds.size() > 0) {
            soqlStr += ' AND Id = :merchantIds';
        }
        return Database.getQueryLocator(soqlStr);
    }

    global void execute(Database.BatchableContext BC, List<mpMerchant__c> merList) {
        Logger logger = new Logger();

        Set<Id> targetMerIdsInBatch = new Set<Id>();
        Set<Id> targetMpOppIdsInBatch = new Set<Id>();

        Set<Id> successMerIdsInBatch = new Set<Id>();
        Set<Id> successMpOppIdsInBatch = new Set<Id>();

        Set<Id> failedMerIdsInBatch = new Set<Id>();
        Set<Id> failedMpOppIdsInBatch = new Set<Id>();

        Map<Id, Id> mpoppmeridMap = new Map<Id, Id>();

        try {
            Set<String> mids = new Set<String>();
            Map<String, Id> midAccIdMap = new Map<String, Id>();
            List<mpMerchant__c> targetMers = new List<mpMerchant__c>();
            Set<Id> targetMpOppIds = new Set<Id>();

            // MIDに対する取引先抽出
            for (mpMerchant__c mer : merList) {
                mids.add(mer.MerchantId__c);
            }
            for (CompanyInfo_UniqueId_Relation__c cur : [SELECT Id, CompanyInfoId__c, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE UniqueId__c = :mids AND SFReplacementCandidateFlag__c = false]) {
                midAccIdMap.put(cur.UniqueId__c, cur.Account__c);
            }

            // 更新対象分別
            Set<String> noRelationDataMids = new Set<String>();
            Set<String> noRelationAccMids = new Set<String>();
            for (mpMerchant__c mer : merList) {
                if (Constant.OPP_DEVELOPER_NAME_INDIVSALES.equals(mer.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.RecordType.DeveloperName)) {
                    continue;
                }
                if (!midAccIdMap.containsKey(mer.MerchantId__c)) {
                    noRelationDataMids.add(mer.MerchantId__c);
                    continue;
                }
                Id accid = midAccIdMap.get(mer.MerchantId__c);
                if (accid == null) {
                    noRelationAccMids.add(mer.MerchantId__c);
                    continue;
                }

                if (accid == mer.AccountId__c && accid == mer.mpOpportunity__r.AccountId__c) {
                    continue;
                }

                targetMers.add(mer);
                targetMpOppIds.add(mer.mpOpportunity__c);
            }
            if (noRelationDataMids.size() > 0) {
                logger.error(BATCH_NAME + '：リレーションデータが存在しないMID', String.join(noRelationDataMids, ','), false);
            }
            if (noRelationAccMids.size() > 0) {
                logger.error(BATCH_NAME + '：リレーションデータの取引先が空のMID', String.join(noRelationAccMids, ','), false);
            }
            if (targetMers.isEmpty()) {
                logger.info(BATCH_NAME, '処理対象なし', false);
                return;
            }

            // アタックリスト抽出
            Map<Id, mpOpportunity__c> targetMpOpps = new Map<Id, mpOpportunity__c>([SELECT Id, AccountId__c FROM mpOpportunity__c WHERE Id = :targetMpOppIds]);

            // 更新するリスト
            List<mpMerchant__c> updateMers = new List<mpMerchant__c>();
            List<mpOpportunity__c> updateMpOpps = new List<mpOpportunity__c>();

            // 値セット
            for (mpMerchant__c mer : targetMers) {
                Id accid = midAccIdMap.get(mer.MerchantId__c);
                if (accid != mer.AccountId__c) {
                    mer.AccountId__c = accid;
                    updateMers.add(mer);
                    targetMerIdsInBatch.add(mer.Id);
                }
                mpOpportunity__c mpopp = targetMpOpps.get(mer.mpOpportunity__c);
                if (accid != mpopp.AccountId__c) {
                    if (!targetMpOppIdsInBatch.contains(mpopp.Id)) {
                        mpopp.AccountId__c = accid;
                        updateMpOpps.add(mpopp);
                        targetMpOppIdsInBatch.add(mpopp.Id);
                        mpoppmeridMap.put(mpopp.Id, mer.Id);
                    }
                }
            }

            if (updateMpOpps.size() > 0) {
                List<Database.SaveResult> results = Database.update(updateMpOpps, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        successMpOppIdsInBatch.add(result.getId());
                        continue;
                    }
                    List<String> errMsgs = new List<String>();
                    List<Database.Error> errors = result.getErrors();
                    for(Database.Error e : errors){
                        errMsgs.add(e.getFields() + ':' + e.getMessage() + ':' + e.getStatusCode());
                    }
                    if (errMsgs.size() > 0) {
                        failedMpOppIdsInBatch.add(result.getId());
                        logger.error(BATCH_NAME + '：アタックリスト更新エラー', 'アタックリストID：' + result.getId() + '／' + String.join(errMsgs, '／'), mpoppmeridMap.get(result.getId()), false);
                    }
                }
                // update updateMpOpps;
            }
            if (updateMers.size() > 0) {
                List<Database.SaveResult> results = Database.update(updateMers, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        successMerIdsInBatch.add(result.getId());
                        continue;
                    }
                    List<String> errMsgs = new List<String>();
                    List<Database.Error> errors = result.getErrors();
                    for(Database.Error e : errors){
                        errMsgs.add(e.getFields() + ':' + e.getMessage() + ':' + e.getStatusCode());
                    }
                    if (errMsgs.size() > 0) {
                        failedMerIdsInBatch.add(result.getId());
                        logger.error(BATCH_NAME + '：加盟店更新エラー', String.join(errMsgs, '／'), result.getId(), false);
                    }
                }
                // update updateMers;
            }

            this.targetMerCnt += targetMerIdsInBatch.size();
            this.targetMpOppCnt += targetMpOppIdsInBatch.size();

            this.successMerCnt += successMerIdsInBatch.size();
            this.successMpOppCnt += successMpOppIdsInBatch.size();

            this.failedMerCnt += failedMerIdsInBatch.size();
            this.failedMpOppCnt += failedMpOppIdsInBatch.size();

            String log = '【対象件数】アタックリスト:' + targetMpOppIdsInBatch.size() + ',加盟店:' + targetMerIdsInBatch.size()
                        + '【成功件数】アタックリスト:' + successMpOppIdsInBatch.size() + ',加盟店:' + successMerIdsInBatch.size()
                        + '【失敗件数】アタックリスト:' + failedMpOppIdsInBatch.size() + ',加盟店:' + failedMerIdsInBatch.size();
            logger.info(BATCH_NAME, log, false);
        } catch (Exception ex) {
            logger.error(BATCH_NAME, ex.getMessage() + '/' + ex.getStackTraceString(), false);
        }
        logger.saveAll();
    }

    // private void setErrMsg(List<Database.SaveResult> results, Logger logger, Set<Id> successIds, Set<Id> failedIds) {
    //     for(Database.SaveResult result : results){
    //         if(result.isSuccess()){
    //             successIds.add(result.getId());
    //             continue;
    //         }
    //         List<String> errMsgs = new List<String>();
    //         List<Database.Error> errors = result.getErrors();
    //         for(Database.Error e : errors){
    //             errMsgs.add(e.getFields() + ':' + e.getMessage() + ':' + e.getStatusCode());
    //         }
    //         if (errMsgs.size() > 0) {
    //             failedIds.add(result.getId());
    //             logger.error(BATCH_NAME, String.join(errMsgs, '／'), result.getId(), false);
    //         }
    //     }
    // }

    global void finish(Database.BatchableContext BC) {
        Logger logger = new Logger();

        String log = '【対象総件数】アタックリスト:' + this.targetMpOppCnt + ',加盟店:' + this.targetMerCnt
                    + '【成功総件数】アタックリスト:' + this.successMpOppCnt + ',加盟店:' + this.successMerCnt
                    + '【失敗総件数】アタックリスト:' + this.failedMpOppCnt + ',加盟店:' + this.failedMerCnt;
        logger.info(BATCH_NAME + '：処理終了', log, false);

        logger.saveAll();
    }
}