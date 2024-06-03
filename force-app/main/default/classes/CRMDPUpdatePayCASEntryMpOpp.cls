/**
* クラス名: CRMDPUpdatePayCASEntryMpOpp
* クラス概要: D015：案件・サービス管理・営業先管理　個店
*            PayCAS申込情報アタックリストとサービス管理の紐づけ
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2024/01/16
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
global class CRMDPUpdatePayCASEntryMpOpp implements Database.Batchable<sObject>, Database.Stateful {

    @TestVisible
    private static final String BATCH_LOG_TITLE = '【CRM高度化】PayCAS申込情報レコード連携バッチ';
    private static final String BATCH_LOG_END = '_完了';

    private static final Integer PREFIX_NUM = 3;
    private static final Integer AGENCY_MEMO_PREFIX_NUM = 2;
    private static final Integer ID_DIGIT_MAX_NUM = 18;
    private static final String PREFIX_MP_OPP = Schema.SObjectType.mpOpportunity__c.getKeyPrefix(); // アタックリストレコードのprefix
    private static final String PREFIX_PP_STORE = Schema.SObjectType.PayPayStore__c.getKeyPrefix(); // PPストアレコードのprefix

    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;

    @TestVisible
    private enum TEST_MODE {
        NONE,
        UPDATE_ERROR,
        UNKNOWN_EXCEPTION
    }
    @TestVisible
    private static TEST_MODE testMode = TEST_MODE.NONE;

    /**
     * バッチ呼び出し
     */
    global static void run() {
        // バッチサイズ200仮置き
        Database.executeBatch(new CRMDPUpdatePayCASEntryMpOpp(), 200);
    }

    /**
     * バッチ開始
     * @param BC 一括処理ジョブ
     * @details PayCAS申込情報を管理するアタックリストを抽出
     *          - レコードタイプ: マーチャントスキャン（大手）
     *          - 包括代理店_サービス名: PayCAS
     *          - 包括代理店_備考: 空欄でないもの
     *          - サービス管理名（決済事業）: 空欄のもの
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set<Id> targetRCId = new Set<Id>{
            mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, Constant.MPOPPORTUNITY_DEV_NAME_POS),
            mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, 'RecordTypeDummy')
        };
        
        return Database.getQueryLocator([
            SELECT Id, Agency_Memo__c
            FROM mpOpportunity__c
            WHERE RecordTypeId IN :targetRCId
            AND Agency_Service_name__c = 'PayCAS'
            AND Agency_Memo__c <> null
            AND OrderProgressId__c = null
        ]);
    }

    /**
     * バッチ処理
     * @param BC 一括処理ジョブ
     * @param mpOppList アタックリストList
     * @details 「包括代理店_備考」に登録されているデータは以下4パターンが想定される
     * K_a225j000000iGiCAAU
     * S_a2L5j000000q1axEAA
     * S_a2L5j000000q1blEAA/開業前案件/20240114/
     * K_a222x000000wf26AAA_A
     * そのためPrefix二文字削除し、その後に続く18桁IDがアタックリストまたはPPストアのIDであれば更新対象
     * それ以外のデータである場合は更新対象外のため対象外Setに登録
     */
    global void execute(Database.BatchableContext BC, List<mpOpportunity__c> mpOppList) {
        bResult.totalRecordSize += mpOppList.size();

        Set<Id> notApplicableIds = new Set<Id>();
        // 更新対象のアタックリストIDとCRMデータ移行元アタックリストに登録されているアタックリストIDのMAP
        Map<Id, Id> targetIdCrmdpIdMap = new Map<Id, Id>();
        // 更新対象のアタックリストIDとPPストアIDのMAP
        Map<String, Id> oppIdMapStoreIdMp = new Map<String, Id>();
        Map<String, Set<Id>> errorMsgMap = new Map<String, Set<Id>>();

        // 包括代理店_備考に登録されているデータを整形する
        for (mpOpportunity__c data : mpOppList) {
            try {
                String agencyMemoText = data.Agency_Memo__c.removeStartIgnoreCase('K_').removeStartIgnoreCase('S_').left(ID_DIGIT_MAX_NUM);
                Id agencyMemoId = Id.valueOf(agencyMemoText);

                // アタックリストIDが登録されている場合(PayCAS単独商材)
                if (agencyMemoText.length() == ID_DIGIT_MAX_NUM && agencyMemoText.left(PREFIX_NUM).equals(PREFIX_MP_OPP)) {
                    targetIdCrmdpIdMap.put(data.Id, agencyMemoId);
                }
                // PPストアのIDが登録されている場合(PayCAS切替商材)
                else if (agencyMemoText.length() == ID_DIGIT_MAX_NUM && agencyMemoText.left(PREFIX_NUM).equals(PREFIX_PP_STORE)) {
                    oppIdMapStoreIdMp.put(data.Id, agencyMemoId);
                }
                // 対象外のIDが記載されていた場合はログ用の変数にレコードIDを登録
                else {
                    notApplicableIds.add(data.Id);
                }
            }
            catch (Exception e) { // 主にStringからID変換時のExceptionを検知
                if (!errorMsgMap.containsKey(e.getMessage())) {
                    errorMsgMap.put(e.getMessage(), new Set<Id>{data.Id});
                }
                else {
                    errorMsgMap.get(e.getMessage()).add(data.Id);
                }
            }
        }

        Set<Id> notFoundRecordIds = new Set<Id>();

        // PPストアに関連するアタックリストIDを取得する
        Map<Id, PayPayStore__c> pStoreMap = new Map<Id, PayPayStore__c>([
            SELECT Id, PayPayMerchant__c, PayPayMerchant__r.mpOpportunity__c
            FROM PayPayStore__c 
            WHERE Id IN :oppIdMapStoreIdMp.values()
        ]);

        for (Id targetId : oppIdMapStoreIdMp.keySet()) {
            Id targetStoreId = oppIdMapStoreIdMp.get(targetId);
            // PPストアに関連するアタックリストIDがあればtargetIdCrmdpIdMapに登録する
            if (pStoreMap.containsKey(targetStoreId)) {
                PayPayStore__c pStore = pStoreMap.get(targetStoreId);
                if (pStore.PayPayMerchant__c == null || pStore.PayPayMerchant__r.mpOpportunity__c == null) {
                    notFoundRecordIds.add(targetId);
                    continue;
                }
                targetIdCrmdpIdMap.put(targetId, pStore.PayPayMerchant__r.mpOpportunity__c);
            }
            else {
                // PPストアが見つからなかった包括代理店_備考をもつアタックリストID
                notFoundRecordIds.add(targetId);
            }
        }

        Map<Id, OrderProgress__c> mpOppIdOrderProgressMap = new Map<Id, OrderProgress__c>();
        // 包括代理店_備考から取得できたアタックリストのIDをもつサービス管理を検索
        Id recordTypeIdPayCAS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAYCAS);
        for (OrderProgress__c orderProgress : [
            SELECT Id, AccountId__c, CRMDPMpOppId__c
            FROM OrderProgress__c
            WHERE CRMDPMpOppId__c IN :targetIdCrmdpIdMap.values()
            AND RecordTypeId = :recordTypeIdPayCAS
            AND Name LIKE '%PayCAS%']) {
            // CRMデータ移行元アタックリストIDとサービス管理のMAP
            mpOppIdOrderProgressMap.put(orderProgress.CRMDPMpOppId__c, orderProgress);
        }

        // 更新対象アタックリストにサービス管理を紐づける
        List<mpOpportunity__c> updateMpOppList = new List<mpOpportunity__c>();
        for (Id targetId : targetIdCrmdpIdMap.keySet()) {
            // 包括代理店_備考から取得できたアタックリストID
            Id mpOppId = targetIdCrmdpIdMap.get(targetId);

            // 包括代理店_備考に登録されているIDがmpOppIdOrderProgressMapにある場合
            if (mpOppIdOrderProgressMap.containsKey(mpOppId)) {
                // アタックリストを参照しているサービス管理と取引先を更新対象のアタックリストへ紐づける
                mpOpportunity__c tgtMpOpp = new mpOpportunity__c(
                    Id = targetId,
                    AccountId__c = mpOppIdOrderProgressMap.get(mpOppId).AccountId__c,
                    OrderProgressId__c = mpOppIdOrderProgressMap.get(mpOppId).Id
                );
                updateMpOppList.add(tgtMpOpp);
            }
            else {
                // サービス管理と紐づけられなかったアタックリストID
                notFoundRecordIds.add(targetId);
            }
        }

        // レコード更新
        try {
            // Exception発生のテストケースにて使用
            if (Test.isRunningTest()) {
                if (testMode == TEST_MODE.UPDATE_ERROR) {
                    updateMpOppList[0].Name = '123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
                }
                else if (testMode == TEST_MODE.UNKNOWN_EXCEPTION) {
                    throw new NullPointerException();
                }
            }

            Integer successCount = 0;
            List<Database.SaveResult> resultList = database.update(updateMpOppList, false);

            // 出力用ログ作成
            for (Database.SaveResult result : resultList) {
                if (!result.isSuccess()) {
                    for (Database.Error errorData : result.getErrors()) {
                        String errorMsg = errorData.getMessage();
                        if (!errorMsgMap.containsKey(errorMsg)) {
                            errorMsgMap.put(errorMsg, new Set<Id>{result.getId()});
                        }
                        else {
                            errorMsgMap.get(errorMsg).add(result.getId());
                        }
                    }
                }
                else {
                    successCount++;
                }

            }

            // ログ本文作成
            Logger logger = new Logger();
            String logInfoText = 'バッチ起動時取得件数: ' + mpOppList.size() + '件\n';
            logInfoText += '更新対象PPアタックリスト件数: ' + successCount + '件\n';
            logInfoText += '▽包括代理店_備考のIDが対象外レコードまたはフォーマット不正: ' + notApplicableIds.size() + '件\n';
            logInfoText += String.join(notApplicableIds, ', ') + '\n\n';
            logInfoText += '▽関連するレコードが見つからなかったID: ' + notFoundRecordIds.size() + '件\n';
            logInfoText += String.join(notFoundRecordIds, ', ');
            for (String errorMsg : errorMsgMap.keySet()) {
                logInfoText += '\n\n▽' + errorMsg + ': ' + errorMsgMap.get(errorMsg).size() + '件\n';
                logInfoText += String.join(errorMsgMap.get(errorMsg), ', ');
            }

            if (errorMsgMap.isEmpty()) {
                logger.info(BATCH_LOG_TITLE, logInfoText, false).saveAll();
            }
            else {
                logger.error(BATCH_LOG_TITLE + '_エラーあり', logInfoText, false).saveAll();
            }

            bResult.successed(successCount);
            bResult.failured(mpOppList.size() - successCount);
        }
        catch (Exception e) {
            Logger logger = new Logger();
            logger.error(BATCH_LOG_TITLE + '_Exception', logger.formatErrorMessage(e), false).saveAll();

            this.hasException = true;
            bResult.failured(updateMpOppList.size());
        }
    }

    /**
     * バッチ終了
     * @param BC 一括処理ジョブ
     */
    global void finish(Database.BatchableContext BC) {
        Logger logger = new Logger();
        if (this.hasException || bResult.hasError) {
            logger.error(BATCH_LOG_TITLE + BATCH_LOG_END, bResult.toString(), false).saveAll();
        }
        else {
            logger.info(BATCH_LOG_TITLE + BATCH_LOG_END, bResult.toString(), false).saveAll();
        }
    }
}