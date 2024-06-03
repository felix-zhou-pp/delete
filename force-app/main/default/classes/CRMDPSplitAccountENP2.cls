/**
 * CRM高度化対応：エンプラ取引先分割のバッチ（アタックリスト以下の件数が多い場合、ガバナ制限を回避するための補助バッチ）
 * 更新対象
 * 　・企業分割された案件に紐づく包括代理店データ以外のアタックリスト、加盟店、リレーション
 * 更新内容
 * 　・引数の案件IDに紐づくアタックリスト、加盟店、リレーションの取引先参照を引数の取引先IDに更新
 */
global class CRMDPSplitAccountENP2 implements Database.Batchable<sObject>, Database.Stateful {
    public Map<Id, Id> oppAccIdMap;
    public Integer targetCountMpOpp;
    public Integer targetCountMer;
    public Integer targetCountCur;
    public Integer successCountMpOpp;
    public Integer successCountMer;
    public Integer successCountCur;

    private static final String BATCH_NAME = '【CRM高度化】エンプラ取引先分割バッチ（アタックリスト以下分割更新）';

    public CRMDPSplitAccountENP2(Map<Id, Id> oppAccIdMap) {
        this.oppAccIdMap = oppAccIdMap;
        this.targetCountMpOpp = 0;
        this.targetCountMer = 0;
        this.targetCountCur = 0;
        this.successCountMpOpp = 0;
        this.successCountMer = 0;
        this.successCountCur = 0;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> oppids = this.oppAccIdMap.keySet();
        Set<String> excludeOpRecordType = new Set<String>{
            Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER
            ,Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE
            ,Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB
        };
        String soqlStr = 'SELECT Id, OrderProgressId__r.OpportunityId__c, AccountId__c FROM mpOpportunity__c'
                        + ' WHERE OrderProgressId__r.OpportunityId__c = :oppids AND OrderProgressId__r.RecordType.DeveloperName != :excludeOpRecordType';
        return Database.getQueryLocator(soqlStr);
    }

    global void execute(Database.BatchableContext BC, List<mpOpportunity__c> mpoppList) {
        Logger logger = new Logger();

        try {
            // 案件に紐づくレコード抽出
            Set<Id> mpoppIds = new Set<Id>();
            for (mpOpportunity__c mpopp : mpoppList) {
                mpoppIds.add(mpopp.Id);
            }
            List<mpMerchant__c> mers = [SELECT Id, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, AccountId__c, MerchantId__c FROM mpMerchant__c WHERE mpOpportunity__c = :mpoppIds];
            Set<String> mids = new Set<String>();
            for (mpMerchant__c mer : mers) {
                mids.add(mer.MerchantId__c);
            }
            Map<String, CompanyInfo_UniqueId_Relation__c> curs = new Map<String, CompanyInfo_UniqueId_Relation__c>();
            for (CompanyInfo_UniqueId_Relation__c cur : [SELECT Id, UniqueId__c, Account__c, SFReplacementCandidateFlag__c FROM CompanyInfo_UniqueId_Relation__c WHERE UniqueId__c = :mids]) {
                curs.put(cur.UniqueId__c, cur);
            }

            List<mpOpportunity__c> updateMpOpps = new List<mpOpportunity__c>();
            List<mpMerchant__c> updateMers = new List<mpMerchant__c>();
            List<CompanyInfo_UniqueId_Relation__c> updateCurs = new List<CompanyInfo_UniqueId_Relation__c>();

            Set<Id> notExistOppIds = new Set<Id>();

            // 更新対象の分別、値セット
            for (mpOpportunity__c mpopp : mpoppList) {
                Id accid = this.oppAccIdMap.get(mpopp.OrderProgressId__r.OpportunityId__c);
                if (accid == null) {
                    notExistOppIds.add(mpopp.OrderProgressId__r.OpportunityId__c);
                    continue;
                }
                if (accid != mpopp.AccountId__c) {
                    mpopp.AccountId__c = accid;
                    updateMpOpps.add(mpopp);
                }
            }
            for (mpMerchant__c mer : mers) {
                Id accid = this.oppAccIdMap.get(mer.mpOpportunity__r.OrderProgressId__r.OpportunityId__c);
                if (accid == null) {
                    notExistOppIds.add(mer.mpOpportunity__r.OrderProgressId__r.OpportunityId__c);
                    continue;
                }
                if (accid != mer.AccountId__c) {
                    mer.AccountId__c = accid;
                    updateMers.add(mer);
                }
                if (curs.containsKey(mer.MerchantId__c)) {
                    CompanyInfo_UniqueId_Relation__c cur = curs.get(mer.MerchantId__c);
                    if (accid != cur.Account__c) {
                        // cur.Account__c = accid;
                        cur.SFReplacementCandidateFlag__c = true;
                        updateCurs.add(cur);
                    }
                } else {
                    logger.error(BATCH_NAME, '【リレーションデータ不備】存在しないMID：' + mer.MerchantId__c, false);
                }
            }

            if (notExistOppIds.size() > 0) {
                logger.error(BATCH_NAME, '【付け替え取引先IDがない】案件ID：' + String.join(notExistOppIds, ','), false);
            }

            // レコード更新
            Integer countMpOpp = 0;
            if (updateMpOpps.size() > 0) {
                List<Database.SaveResult> results = Database.update(updateMpOpps, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        countMpOpp++;
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
                // update updateMpOpps;
            }
            Integer countMer = 0;
            if (updateMers.size() > 0) {
                List<Database.SaveResult> results = Database.update(updateMers, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        countMer++;
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
                // update updateMers;
            }
            Integer countCur = 0;
            if (updateCurs.size() > 0) {
                List<Database.SaveResult> results = Database.update(updateCurs, false);
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        countCur++;
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
                // update updateCurs;
            }

            String log = '成功件数アタックリスト：' + countMpOpp + '/' + updateMpOpps.size()
                        + '／加盟店：' + countMer + '/' + updateMers.size()
                        + '／リレーション：' + countCur + '/' + updateCurs.size();
            logger.info(BATCH_NAME, log, false);

            this.targetCountMpOpp += updateMpOpps.size();
            this.targetCountMer += updateMers.size();
            this.targetCountCur += updateCurs.size();
            this.successCountMpOpp += countMpOpp;
            this.successCountMer += countMer;
            this.successCountCur += countCur;
        } catch (Exception ex) {
            logger.error(BATCH_NAME, ex.getMessage() + '/' + ex.getStackTraceString(), false);
        }
        logger.saveAll();
    }

    global void finish(Database.BatchableContext BC) {
        Logger logger = new Logger();
        String log = '【処理終了】成功件数アタックリスト：' + this.successCountMpOpp + '/' + this.targetCountMpOpp
                    + '／加盟店：' + this.successCountMer + '/' + this.targetCountMer
                    + '／リレーション：' + this.successCountCur + '/' + this.targetCountCur;
        logger.info(BATCH_NAME, log, false);
        logger.saveAll();
    }
}