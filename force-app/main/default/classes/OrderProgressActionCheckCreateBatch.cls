/**
 * サービス管理オブジェクト分割
 *  - 概要
 *   アーキテクチャ移行時に使用。
 *   サービス管理のデータをもとに新オブジェクト：サービス管理アクションを作成する
 *  - 実行方法
 *   開発者コンソールから以下のコマンドを実行する
 *   Database.executeBatch(new OrderProgressActionCheckCreateBatch(), 200);
 */
public with sharing class OrderProgressActionCheckCreateBatch implements Database.Batchable<sObject>, Database.Stateful {

    // DMLException test のためのフラグ
    // @testVisible
    // private static Boolean isDMLExceptionTest = false;

    // // 移行対象のサービス管理レコードタイプ
    // Id RECORDTYPE_OFFLINE_PLC;
    // Id RECORDTYPE_ONLINE_PLC;
    // Id RECORDTYPE_REVISITING_PLC;
    // Id RECORDTYPE_SCHADULED_PLC;
    // Id RECORDTYPE_CAMPAIGN;
    // Id RECORDTYPE_STAMPCARD;
    // Id RECORDTYPE_FLYER_APPLY;
    // Id RECORDTYPE_FLYER_DRAFT;
    // Id RECORDTYPE_SERVICE_COMMON;
    // Id RECORDTYPE_MYSTORE;
    
    // // 移行後サービス管理アクションのレコードタイプ
    // Id RECORDTYPE_OFFLINE_PLC_ACTION;
    // Id RECORDTYPE_OFFLINE_PLC_TOOL;
    // Id RECORDTYPE_ONLINE_PLC_ACTION;
    // Id RECORDTYPE_REVISITING_PLC_ACTION;
    // Id RECORDTYPE_SCHADULED_PLC_ACTION;
    // Id RECORDTYPE_SCHADULED_PLC_TOOL;
    // Id RECORDTYPE_CAMPAIGN_ACTION;
    // Id RECORDTYPE_CAMPAIGN_TOOL;
    // Id RECORDTYPE_STAMPCARD_ACTION;
    // Id RECORDTYPE_STAMPCARD_TOOL;
    // Id RECORDTYPE_FLYER_APPLY_ACTION;
    // Id RECORDTYPE_FLYER_APPLY_TOOL;
    // Id RECORDTYPE_FLYER_DRAFT_ACTION;
    // Id RECORDTYPE_SERVICE_COMMON_ACTION;
    // Id RECORDTYPE_SERVICE_COMMON_TOOL;
    // Id RECORDTYPE_MYSTORE_ACTION;

    // // サービス管理のレコードタイプSet
    // Set<String> orderProgressRecordTypeIdSet;

    // // 新オブジェクト登録時のレコード名
    // private static final String RECORD_NAME_ACTION = '_アクションチェック/再現';
    // private static final String RECORD_NAME_TOOL = '_ツール/販促管理関連';

    // // エラーログ保存時のタイトル
    // @testVisible
    // private static final String ERROR_LOG_TITLE = '【アーキ分割】サービス管理アクション作成処理に失敗しました';

    /**
     * コンストラクタ
     */
    public OrderProgressActionCheckCreateBatch() {
    // サービス管理のレコードタイプID取得
    //     RECORDTYPE_OFFLINE_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PLCRecordType');
    //     RECORDTYPE_ONLINE_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'OnlinePLCRecordType');
    //     RECORDTYPE_REVISITING_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RevisitingCoupon');
    //     RECORDTYPE_SCHADULED_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'ScheduledCoupon');
    //     RECORDTYPE_CAMPAIGN = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Campaign');
    //     RECORDTYPE_STAMPCARD = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'SCRecordType');
    //     RECORDTYPE_FLYER_APPLY = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'FlyerApply');
    //     RECORDTYPE_FLYER_DRAFT = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'FlyerDraft');
    //     RECORDTYPE_SERVICE_COMMON = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'ServiceCommon');
    //     RECORDTYPE_MYSTORE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PayEnterprise_mystore');

    // orderProgressRecordTypeIdSet = new Set<String>();
    // orderProgressRecordTypeIdSet.add(String.valueOf(RECORDTYPE_OFFLINE_PLC));
    // orderProgressRecordTypeIdSet.add(String.valueOf(RECORDTYPE_ONLINE_PLC));
    // orderProgressRecordTypeIdSet.add(String.valueOf(RECORDTYPE_REVISITING_PLC));
    // orderProgressRecordTypeIdSet.add(String.valueOf(RECORDTYPE_CAMPAIGN));
    // orderProgressRecordTypeIdSet.add(String.valueOf(RECORDTYPE_STAMPCARD));
    // orderProgressRecordTypeIdSet.add(String.valueOf(RECORDTYPE_FLYER_APPLY));
    // orderProgressRecordTypeIdSet.add(String.valueOf(RECORDTYPE_FLYER_DRAFT));
    // orderProgressRecordTypeIdSet.add(String.valueOf(RECORDTYPE_SERVICE_COMMON));
    // orderProgressRecordTypeIdSet.add(String.valueOf(RECORDTYPE_MYSTORE));
    // orderProgressRecordTypeIdSet.add(String.valueOf(RECORDTYPE_SCHADULED_PLC));

    //     // サービス管理アクションのレコードタイプID取得
    //     RECORDTYPE_OFFLINE_PLC_ACTION = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'PLCRecordType_Action');
    //     RECORDTYPE_OFFLINE_PLC_TOOL = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'PLCRecordType_Tool_SalesPromotion');
    //     RECORDTYPE_ONLINE_PLC_ACTION = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'OnlinePLCRecordType_Action');
    //     RECORDTYPE_REVISITING_PLC_ACTION = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'RevisitingCoupon_Action');
    //     RECORDTYPE_SCHADULED_PLC_ACTION = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'ScheduledCoupon_Action');
    //     RECORDTYPE_SCHADULED_PLC_TOOL = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'ScheduledCoupon_Tool_SalesPromotion');
    //     RECORDTYPE_CAMPAIGN_ACTION = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'Campaign_Action');
    //     RECORDTYPE_CAMPAIGN_TOOL = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'Campaign_Tool_SalesPromotion');
    //     RECORDTYPE_STAMPCARD_ACTION = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'SCRecordType_Action');
    //     RECORDTYPE_STAMPCARD_TOOL = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'SCRecordType_Tool_SalesPromotion');
    //     RECORDTYPE_FLYER_APPLY_ACTION = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'FlyerApply_Action');
    //     RECORDTYPE_FLYER_APPLY_TOOL = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'FlyerApply_Tool_SalesPromotion');
    //     RECORDTYPE_FLYER_DRAFT_ACTION = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'FlyerDraft_Action');
    //     RECORDTYPE_SERVICE_COMMON_ACTION = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'ServiceCommon_Action');
    //     RECORDTYPE_SERVICE_COMMON_TOOL = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'ServiceCommon_Tool_SalesPromotion');
    //     RECORDTYPE_MYSTORE_ACTION = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'PayEnterprise_mystore_Action');
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // System.debug('===== start OrderProgressActionCheckCreateBatch =====');

        return Database.getQueryLocator([
            SELECT 
                Id
        //         Name,
        //         RecordTypeId,
        //         MaxGrantPerPLCPeriod__c,
        //         MaxGrantPerPay__c,
        //         B2Poster__c,
        //         B2PosterPerKit__c,
        //         B2PosterBulkSale__c,
        //         CMWebPublishConsentForm__c,
        //         ES_SecondInCharge__c,
        //         ES_PersonInCharge__c,
        //         KPIFormula__c,
        //         KPIType__c,
        //         KPIAchievedFlg__c,
        //         KPIAchievementRate__c,
        //         KVMainVisual__c,
        //         LPCheckCompleted__c,
        //         MTG_PersonInCharge__c,
        //         MTGedFlg__c,
        //         PLCQuestionDistributeEmail__c,
        //         PLCQuestionDistributeName__c,
        //         PayPayCoverImageUsageIn__c,
        //         PayPayLogoUsageIn__c,
        //         PayPayCoverImageUsageOut__c,
        //         PayPayLogoUsageOut__c,
        //         QRPreferredTransition__c,
        //         SBPLCAppeal__c,
        //         CMCheckCompleted__c,
        //         VerifierPromo__c,
        //         VerifierSales__c,
        //         AnyNumberOfTimesStatement__c,
        //         CPBannerTOPPage__c,
        //         CPBannerProductCart__c,
        //         CPBannerPostingCriteria__c,
        //         CPBannerSettlementPage__c,
        //         CPBannerReason__c,
        //         TwitterFollowers__c,
        //         TwitterURL__c,
        //         TwitterNotice__c,
        //         MMMembersNumber__c,
        //         MMAnnouceStatus__c,
        //         MMTransmissionNumber__c,
        //         ExplanationDraft__c,
        //         InHouseAppDLPerUU__c,
        //         InHouseAppPushNotificationNumber__c,
        //         InHouseAppAnnounceStatus__c,
        //         NoticeTimeline__c,
        //         PostCreatedCompleted__c,
        //         PostCreation_RequestCompleted__c,
        //         OtherPerKit__c,
        //         OtherPerBulk__c,
        //         OtherSizePoster__c,
        //         OtherSizePosterPerKit__c,
        //         OtherSizePosterPerBulk__c,
        //         TotalKits__c,
        //         CampaignToken__c,
        //         CouponCreatedCompleted__c,
        //         PLCPeriod__c,
        //         SwingPOP__c,
        //         SwingPOPPerKit__c,
        //         SwingPOPPerBulk__c,
        //         StampcardPurpose__c,
        //         StampPost_Completed__c,
        //         StampPeriod__c,
        //         StampCondition__c,
        //         StampSpecialOffer__c,
        //         ToolInputComplete__c,
        //         DesignPattern__c,
        //         Data__c,
        //         Banner__c,
        //         BlandPageCreatedCompleted__c,
        //         BlandIntroductionRequestCreate__c,
        //         Image_SubmitCompleted__c,
        //         PromotionAgreement__c,
        //         BonusSetting__c,
        //         NumberOfRecoups__c,
        //         Photo_SubmitCompleted__c,
        //         LogoStorageFolder__c,
        //         LogoSelectReason__c,
        //         NoticeConfirmation_RequestCompleted__c,
        //         ReportDeal__c,
        //         ReportNeed__c,
        //         EnterpriseMemo__c,
        //         DeliveryRemarks__c,
        //         DraftFormat_CollectCompleted__c,
        //         DraftFormat_CouponPost_Completed__c,
        //         DraftFormat_StampPost_Completed__c,
        //         Draft_DoubleCheck__c,
        //         Draft_Deadline__c,
        //         ContentsA4Poster__c,
        //         ContentsOther__c,
        //         ContentsSwingPOP__c,
        //         ContentsSticker__c,
        //         ContentsTrianglePOP__c,
        //         ContentsGreetingCard__c,
        //         ContentsExplanationDraft__c,
        //         ReproductionReration__c,
        //         FirstCredit_AcquisitionCompleted__c,
        //         FirstCredit_AcquisitionDate__c,
        //         MaxUsedTime__c,
        //         AnalyticalUtilization_DocumentCreate__c,
        //         PurposeOfFunding__c,
        //         DraftNumber__c,
        //         ParticipationDeadline__c,
        //         NumberOfCoveringWithinAGroup__c,
        //         CouponUsageRate__c,
        //         GrowthRate__c,
        //         IncrementalGMW__c,
        //         PerformanceCompleted__c,
        //         PerformanceCompleted_Capitalization__c,
        //         ExamComplete__c,
        //         MTG_PreferredDate__c,
        //         ShopListAddCompleted__c,
        //         ShopListDeleteCompleted__c,
        //         ShopListCheckCompleted__c,
        //         Commission__c,
        //         InvestmentRecoupLogic__c,
        //         GreetingCardPerKit__c,
        //         GreetingCardPerBulk__c,
        //         GreetingCard__c,
        //         Stamp_AcquisitionDateCompleted__c,
        //         Stamp_AcquisitionDate__c,
        //         DocsFolderURL__c,
        //         MinimumPayment__c,
        //         FinalVersionCompleted__c,
        //         UpcomingBudget__c,
        //         UpcomingYearMonth__c,
        //         NextImplementation__c,
        //         ComparingEndDate__c,
        //         ComparingStartDate__c,
        //         JudicialAffairsCompleted__c,
        //         BonusCost__c,
        //         BonusResource__c,
        //         ApplicatonCheckCompleted__c,
        //         ApplicationCollectStatus__c,
        //         IncrementalGMWFormula__c,
        //         RequestForDecision_Acquired__c,
        //         RequestForDecision_AcquisitionDate__c,
        //         RequestForDecision_Memo_Acquired__c,
        //         DeliveryInfo__c,
        //         DeliveryInputComplete__c,
        //         DeliveryService__c,
        //         MaterialPrecautions__c,
        //         ResultEntered__c,
        //         MemoCheckRequest__c,
        //         MemorandumCollectionStatus__c,
        //         AmountRecorded__c,
        //         ExplanationDraftPerKit__c,
        //         ExplanationDraftPerBulk__c,
        //         BillingRate__c,
        //         BillingContactCompleted_First__c,
        //         BillingContactCompleted_Second__c,
        //         PromotionCheckCompleted__c,
        //         PromotionInfoCompleted__c,
        //         TransferredFlg__c,
        //         SendingStatus__c,
        //         Addressee__c,
        //         NumberOfExpenses__c,
        //         AchievementRate__c,
        //         CapitalizationRate__c,
        //         CapitalizationAmount__c,
        //         DMPosting__c,
        //         Publication_Flyer_AgentService__c,
        //         Publication_Flyer_Memo__c,
        //         Publication_Flyer__c,
        //         ToolMemo__c,
        //         BlandPageCreatedUser__c,
        //         Online_LINEFlyer__c,
        //         Online_Shufoo__c,
        //         Online_KurashiruFlyer__c,
        //         Online_Tokubai__c,
        //         SubmissionsNumber__c,
        //         SubmissionsImageNumber__c,
        //         SubmitFlyerPossibleDateTime__c,
        //         Publication_OneOffFlyer__c,
        //         Publication_ContinueFlyer__c,
        //         StoreListURL__c,
        //         ShopList_CollectStatus__c,
        //         InsertedFlyer__c,
        //         PostingStatus_Memo__c,
        //         ScheduledPublicationDate__c,
        //         ScheduledPublicationDateDetails__c,
        //         MonthlyPublicationFrequency__c,
        //         ApplicatonPDFStorage__c,
        //         ApplicationStatus_Memo__c,
        //         InHouseMedia_SNS__c,
        //         InHouseMedia_Web__c,
        //         InHouseMedia_App__c,
        //         PromotionService_UsageStats__c,
        //         TransferredFlgMarketing__c,
        //         LogoStorage__c,
        //         LogoStrageMaster__c
            FROM OrderProgress__c
            // WHERE RecordTypeId IN :orderProgressRecordTypeIdSet
            LIMIT 1
        ]);
    }

    public void execute(Database.BatchableContext BC, List<OrderProgress__c> orderProgressList) {
        // System.debug('===== execute OrderProgressActionCheckCreateBatch =====');
        // List<OrderProgressActionCheck__c> newRecordList = new List<OrderProgressActionCheck__c>();
        // // サービス管理のレコードタイプ毎にレコードを作成する
        // for (OrderProgress__c orderProgress : orderProgressList) {
        //     // (1)オフラインPLC
        //     if (orderProgress.RecordTypeId.equals(RECORDTYPE_OFFLINE_PLC)) {
        //         newRecordList.add(
        //             createOrderProgressActionCheckAction(RECORDTYPE_OFFLINE_PLC_ACTION, orderProgress)
        //         );
        //         newRecordList.add(
        //             createOrderProgressActionCheckTool(RECORDTYPE_OFFLINE_PLC_TOOL, orderProgress)
        //         );
        //     }

        //     // (2)オンラインPLC
        //     if (orderProgress.RecordTypeId.equals(RECORDTYPE_ONLINE_PLC)) {
        //         newRecordList.add(
        //             createOrderProgressActionCheckAction(RECORDTYPE_ONLINE_PLC_ACTION, orderProgress)
        //         );
        //     }

        //     // (3)再来店クーポン
        //     if (orderProgress.RecordTypeId.equals(RECORDTYPE_REVISITING_PLC)) {
        //         newRecordList.add(
        //             createOrderProgressActionCheckAction(RECORDTYPE_REVISITING_PLC_ACTION, orderProgress)
        //         );
        //     }

        //     // (4)日時指定クーポン
        //     if (orderProgress.RecordTypeId.equals(RECORDTYPE_SCHADULED_PLC)) {
        //         newRecordList.add(
        //             createOrderProgressActionCheckAction(RECORDTYPE_SCHADULED_PLC_ACTION, orderProgress)
        //         );
        //         newRecordList.add(
        //             createOrderProgressActionCheckTool(RECORDTYPE_SCHADULED_PLC_TOOL, orderProgress)
        //         );
        //     }

        //     // (5)キャンペーン
        //     if (orderProgress.RecordTypeId.equals(RECORDTYPE_CAMPAIGN)) {
        //         newRecordList.add(
        //             createOrderProgressActionCheckAction(RECORDTYPE_CAMPAIGN_ACTION, orderProgress)
        //         );
        //         newRecordList.add(
        //             createOrderProgressActionCheckTool(RECORDTYPE_CAMPAIGN_TOOL, orderProgress)
        //         );
        //     }

        //     // (6)スタンプカード
        //     if (orderProgress.RecordTypeId.equals(RECORDTYPE_STAMPCARD)) {
        //         newRecordList.add(
        //             createOrderProgressActionCheckAction(RECORDTYPE_STAMPCARD_ACTION, orderProgress)
        //         );
        //         newRecordList.add(
        //             createOrderProgressActionCheckTool(RECORDTYPE_STAMPCARD_TOOL, orderProgress)
        //         );
        //     }

        //     // (7)チラシ_申込
        //     if (orderProgress.RecordTypeId.equals(RECORDTYPE_FLYER_APPLY)) {
        //         newRecordList.add(
        //             createOrderProgressActionCheckAction(RECORDTYPE_FLYER_APPLY_ACTION, orderProgress)
        //         );
        //         newRecordList.add(
        //             createOrderProgressActionCheckTool(RECORDTYPE_FLYER_APPLY_TOOL, orderProgress)
        //         );
        //     }

        //     // (8)チラシ_入稿
        //     if (orderProgress.RecordTypeId.equals(RECORDTYPE_FLYER_DRAFT)) {
        //         newRecordList.add(
        //             createOrderProgressActionCheckAction(RECORDTYPE_FLYER_DRAFT_ACTION, orderProgress)
        //         );
        //     }

        //     // (9)新サービス共通
        //     if (orderProgress.RecordTypeId.equals(RECORDTYPE_SERVICE_COMMON)) {
        //         newRecordList.add(
        //             createOrderProgressActionCheckAction(RECORDTYPE_SERVICE_COMMON_ACTION, orderProgress)
        //         );
        //         newRecordList.add(
        //             createOrderProgressActionCheckTool(RECORDTYPE_SERVICE_COMMON_TOOL, orderProgress)
        //         );
        //     }

        //     // (10)マイストア
        //     if (orderProgress.RecordTypeId.equals(RECORDTYPE_MYSTORE)) {
        //         newRecordList.add(
        //             createOrderProgressActionCheckAction(RECORDTYPE_MYSTORE_ACTION, orderProgress)
        //         );
        //     }

        //     // for DMLException Test Logic
        //     if (Test.isRunningTest() && isDMLExceptionTest) {
        //         newRecordList.add(new OrderProgressActionCheck__c(Name = 'テスト用レコード', RecordTypeId = null));
        //     }
        // }

        // try {
        //     System.debug('===== execute newRecordList.Size:' + newRecordList.size() + ' =====');
        //     insert newRecordList;
        // }
        // catch (Exception ex) {
        //     Set<Id> failureOpIds = new Set<Id>();
        //     for (OrderProgressActionCheck__c newRecord : newRecordList) {
        //         failureOpIds.add((newRecord.OrderProgress_Action__c != null) ? newRecord.OrderProgress_Action__c : newRecord.OrderProgress_Tool_SalesPromotion__c);
        //     }
        //     Logger logger = new Logger();
        //     logger.error(ERROR_LOG_TITLE, ex + '\n▼失敗したサービス管理ID\n' + failureOpIds, false).saveAll();
        // }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('===== finish OrderProgressActionCheckCreateBatch =====');
    }

    /**
     * サービス管理のデータを新オブジェクトへ移行する(アクション系)
     *  レコードタイプ関係なく一律設定する
     * @param tgtRecordTypeId 新レコードのレコードタイプID
     * @param base 移行元サービス管理
     * @return データ移行後新オブジェクト
     */
    // private OrderProgressActionCheck__c createOrderProgressActionCheckAction(Id tgtRecordTypeId, OrderProgress__c base) {
    //     String recordName = base.Name + RECORD_NAME_ACTION;
    //     return new OrderProgressActionCheck__c(
    //         Name = recordName.left(80),
    //         OrderProgress_Action__c = base.Id,
    //         RecordTypeId = tgtRecordTypeId,
    //         MaxGrantPerPLCPeriod__c = base.MaxGrantPerPLCPeriod__c,
    //         MaxGrantPerPay__c = base.MaxGrantPerPay__c,
    //         B2Poster__c = base.B2Poster__c,
    //         B2PosterPerKit__c = base.B2PosterPerKit__c,
    //         B2PosterBulkSale__c = base.B2PosterBulkSale__c,
    //         CMWebPublishConsentForm__c = base.CMWebPublishConsentForm__c,
    //         ES_SecondInCharge__c = base.ES_SecondInCharge__c,
    //         ES_PersonInCharge__c = base.ES_PersonInCharge__c,
    //         KPIFormula__c = base.KPIFormula__c,
    //         KPIType__c = base.KPIType__c,
    //         KPIAchievedFlg__c = base.KPIAchievedFlg__c,
    //         KPIAchievementRate__c = base.KPIAchievementRate__c,
    //         KVMainVisual__c = base.KVMainVisual__c,
    //         LPCheckCompleted__c = base.LPCheckCompleted__c,
    //         MTG_PersonInCharge__c = base.MTG_PersonInCharge__c,
    //         MTGedFlg__c = base.MTGedFlg__c,
    //         PLCQuestionDistributeEmail__c = base.PLCQuestionDistributeEmail__c,
    //         PLCQuestionDistributeName__c = base.PLCQuestionDistributeName__c,
    //         PayPayCoverImageUsageIn__c = base.PayPayCoverImageUsageIn__c,
    //         PayPayLogoUsageIn__c = base.PayPayLogoUsageIn__c,
    //         PayPayCoverImageUsageOut__c = base.PayPayCoverImageUsageOut__c,
    //         PayPayLogoUsageOut__c = base.PayPayLogoUsageOut__c,
    //         QRPreferredTransition__c = base.QRPreferredTransition__c,
    //         SBPLCAppeal__c = base.SBPLCAppeal__c,
    //         CMCheckCompleted__c = base.CMCheckCompleted__c,
    //         VerifierPromo__c = base.VerifierPromo__c,
    //         VerifierSales__c = base.VerifierSales__c,
    //         AnyNumberOfTimesStatement__c = base.AnyNumberOfTimesStatement__c,
    //         CPBannerTOPPage__c = base.CPBannerTOPPage__c,
    //         CPBannerProductCart__c = base.CPBannerProductCart__c,
    //         CPBannerPostingCriteria__c = base.CPBannerPostingCriteria__c,
    //         CPBannerSettlementPage__c = base.CPBannerSettlementPage__c,
    //         CPBannerReason__c = base.CPBannerReason__c,
    //         TwitterFollowers__c = base.TwitterFollowers__c,
    //         TwitterURL__c = base.TwitterURL__c,
    //         TwitterNotice__c = base.TwitterNotice__c,
    //         MMMembersNumber__c = base.MMMembersNumber__c,
    //         MMAnnouceStatus__c = base.MMAnnouceStatus__c,
    //         MMTransmissionNumber__c = base.MMTransmissionNumber__c,
    //         ExplanationDraft__c = base.ExplanationDraft__c,
    //         InHouseAppDLPerUU__c = base.InHouseAppDLPerUU__c,
    //         InHouseAppPushNotificationNumber__c = base.InHouseAppPushNotificationNumber__c,
    //         InHouseAppAnnounceStatus__c = base.InHouseAppAnnounceStatus__c,
    //         NoticeTimeline__c = base.NoticeTimeline__c,
    //         PostCreatedCompleted__c = base.PostCreatedCompleted__c,
    //         PostCreation_RequestCompleted__c = base.PostCreation_RequestCompleted__c,
    //         OtherPerKit__c = base.OtherPerKit__c,
    //         OtherPerBulk__c = base.OtherPerBulk__c,
    //         OtherSizePoster__c = base.OtherSizePoster__c,
    //         OtherSizePosterPerKit__c = base.OtherSizePosterPerKit__c,
    //         OtherSizePosterPerBulk__c = base.OtherSizePosterPerBulk__c,
    //         TotalKits__c = base.TotalKits__c,
    //         CampaignToken__c = base.CampaignToken__c,
    //         CouponCreatedCompleted__c = base.CouponCreatedCompleted__c,
    //         PLCPeriod__c = base.PLCPeriod__c,
    //         SwingPOP__c = base.SwingPOP__c,
    //         SwingPOPPerKit__c = base.SwingPOPPerKit__c,
    //         SwingPOPPerBulk__c = base.SwingPOPPerBulk__c,
    //         StampcardPurpose__c = base.StampcardPurpose__c,
    //         StampPost_Completed__c = base.StampPost_Completed__c,
    //         StampPeriod__c = base.StampPeriod__c,
    //         StampCondition__c = base.StampCondition__c,
    //         StampSpecialOffer__c = base.StampSpecialOffer__c,
    //         ToolInputComplete__c = base.ToolInputComplete__c,
    //         DesignPattern__c = base.DesignPattern__c,
    //         Data__c = base.Data__c,
    //         Banner__c = base.Banner__c,
    //         BlandPageCreatedCompleted__c = base.BlandPageCreatedCompleted__c,
    //         BlandIntroductionRequestCreate__c = base.BlandIntroductionRequestCreate__c,
    //         Image_SubmitCompleted__c = base.Image_SubmitCompleted__c,
    //         PromotionAgreement__c = base.PromotionAgreement__c,
    //         BonusSetting__c = base.BonusSetting__c,
    //         NumberOfRecoups__c = base.NumberOfRecoups__c,
    //         Photo_SubmitCompleted__c = base.Photo_SubmitCompleted__c,
    //         LogoStorageFolder__c = base.LogoStorageFolder__c,
    //         LogoSelectReason__c = base.LogoSelectReason__c,
    //         NoticeConfirmation_RequestCompleted__c = base.NoticeConfirmation_RequestCompleted__c,
    //         ReportDeal__c = base.ReportDeal__c,
    //         ReportNeed__c = base.ReportNeed__c,
    //         EnterpriseMemo__c = base.EnterpriseMemo__c,
    //         DeliveryRemarks__c = base.DeliveryRemarks__c,
    //         DraftFormat_CollectCompleted__c = base.DraftFormat_CollectCompleted__c,
    //         DraftFormat_CouponPost_Completed__c = base.DraftFormat_CouponPost_Completed__c,
    //         DraftFormat_StampPost_Completed__c = base.DraftFormat_StampPost_Completed__c,
    //         Draft_DoubleCheck__c = base.Draft_DoubleCheck__c,
    //         Draft_Deadline__c = base.Draft_Deadline__c,
    //         ContentsA4Poster__c = base.ContentsA4Poster__c,
    //         ContentsOther__c = base.ContentsOther__c,
    //         ContentsSwingPOP__c = base.ContentsSwingPOP__c,
    //         ContentsSticker__c = base.ContentsSticker__c,
    //         ContentsTrianglePOP__c = base.ContentsTrianglePOP__c,
    //         ContentsGreetingCard__c = base.ContentsGreetingCard__c,
    //         ContentsExplanationDraft__c = base.ContentsExplanationDraft__c,
    //         ReproductionReration__c = base.ReproductionReration__c,
    //         FirstCredit_AcquisitionCompleted__c = base.FirstCredit_AcquisitionCompleted__c,
    //         FirstCredit_AcquisitionDate__c = base.FirstCredit_AcquisitionDate__c,
    //         MaxUsedTime__c = base.MaxUsedTime__c,
    //         AnalyticalUtilization_DocumentCreate__c = base.AnalyticalUtilization_DocumentCreate__c,
    //         PurposeOfFunding__c = base.PurposeOfFunding__c,
    //         DraftNumber__c = base.DraftNumber__c,
    //         ParticipationDeadline__c = base.ParticipationDeadline__c,
    //         NumberOfCoveringWithinAGroup__c = base.NumberOfCoveringWithinAGroup__c,
    //         CouponUsageRate__c = base.CouponUsageRate__c,
    //         GrowthRate__c = base.GrowthRate__c,
    //         IncrementalGMW__c = base.IncrementalGMW__c,
    //         PerformanceCompleted__c = base.PerformanceCompleted__c,
    //         PerformanceCompleted_Capitalization__c = base.PerformanceCompleted_Capitalization__c,
    //         ExamComplete__c = base.ExamComplete__c,
    //         MTG_PreferredDate__c = base.MTG_PreferredDate__c,
    //         ShopListAddCompleted__c = base.ShopListAddCompleted__c,
    //         ShopListDeleteCompleted__c = base.ShopListDeleteCompleted__c,
    //         ShopListCheckCompleted__c = base.ShopListCheckCompleted__c,
    //         Commission__c = base.Commission__c,
    //         InvestmentRecoupLogic__c = base.InvestmentRecoupLogic__c,
    //         GreetingCardPerKit__c = base.GreetingCardPerKit__c,
    //         GreetingCardPerBulk__c = base.GreetingCardPerBulk__c,
    //         GreetingCard__c = base.GreetingCard__c,
    //         Stamp_AcquisitionDateCompleted__c = base.Stamp_AcquisitionDateCompleted__c,
    //         Stamp_AcquisitionDate__c = base.Stamp_AcquisitionDate__c,
    //         DocsFolderURL__c = base.DocsFolderURL__c,
    //         MinimumPayment__c = base.MinimumPayment__c,
    //         FinalVersionCompleted__c = base.FinalVersionCompleted__c,
    //         UpcomingBudget__c = base.UpcomingBudget__c,
    //         UpcomingYearMonth__c = base.UpcomingYearMonth__c,
    //         NextImplementation__c = base.NextImplementation__c,
    //         ComparingEndDate__c = base.ComparingEndDate__c,
    //         ComparingStartDate__c = base.ComparingStartDate__c,
    //         JudicialAffairsCompleted__c = base.JudicialAffairsCompleted__c,
    //         BonusCost__c = base.BonusCost__c,
    //         BonusResource__c = base.BonusResource__c,
    //         ApplicatonCheckCompleted__c = base.ApplicatonCheckCompleted__c,
    //         ApplicationCollectStatus__c = base.ApplicationCollectStatus__c,
    //         IncrementalGMWFormula__c = base.IncrementalGMWFormula__c,
    //         RequestForDecision_Acquired__c = base.RequestForDecision_Acquired__c,
    //         RequestForDecision_AcquisitionDate__c = base.RequestForDecision_AcquisitionDate__c,
    //         RequestForDecision_Memo_Acquired__c = base.RequestForDecision_Memo_Acquired__c,
    //         //DeliveryInfo__c = base.DeliveryInfo__c, URL埋め込み数式のためデータ移行不要
    //         DeliveryInputComplete__c = base.DeliveryInputComplete__c,
    //         DeliveryService__c = base.DeliveryService__c,
    //         MaterialPrecautions__c = base.MaterialPrecautions__c,
    //         ResultEntered__c = base.ResultEntered__c,
    //         MemoCheckRequest__c = base.MemoCheckRequest__c,
    //         MemorandumCollectionStatus__c = base.MemorandumCollectionStatus__c,
    //         AmountRecorded__c = base.AmountRecorded__c,
    //         ExplanationDraftPerKit__c = base.ExplanationDraftPerKit__c,
    //         ExplanationDraftPerBulk__c = base.ExplanationDraftPerBulk__c,
    //         BillingRate__c = base.BillingRate__c,
    //         BillingContactCompleted_First__c = base.BillingContactCompleted_First__c,
    //         BillingContactCompleted_Second__c = base.BillingContactCompleted_Second__c,
    //         PromotionCheckCompleted__c = base.PromotionCheckCompleted__c,
    //         PromotionInfoCompleted__c = base.PromotionInfoCompleted__c,
    //         TransferredFlg__c = base.TransferredFlg__c,
    //         SendingStatus__c = base.SendingStatus__c,
    //         Addressee__c = base.Addressee__c,
    //         NumberOfExpenses__c = base.NumberOfExpenses__c,
    //         AchievementRate__c = base.AchievementRate__c,
    //         CapitalizationRate__c = base.CapitalizationRate__c,
    //         CapitalizationAmount__c = base.CapitalizationAmount__c,
    //         DMPosting__c = base.DMPosting__c,
    //         Publication_Flyer_AgentService__c = base.Publication_Flyer_AgentService__c,
    //         Publication_Flyer_Memo__c = base.Publication_Flyer_Memo__c,
    //         Publication_Flyer__c = base.Publication_Flyer__c,
    //         ToolMemo__c = base.ToolMemo__c,
    //         BlandPageCreatedUser__c = base.BlandPageCreatedUser__c,
    //         Online_LINEFlyer__c = base.Online_LINEFlyer__c,
    //         Online_Shufoo__c = base.Online_Shufoo__c,
    //         Online_KurashiruFlyer__c = base.Online_KurashiruFlyer__c,
    //         Online_Tokubai__c = base.Online_Tokubai__c,
    //         SubmissionsNumber__c = base.SubmissionsNumber__c,
    //         SubmissionsImageNumber__c = base.SubmissionsImageNumber__c,
    //         SubmitFlyerPossibleDateTime__c = base.SubmitFlyerPossibleDateTime__c,
    //         Publication_OneOffFlyer__c = base.Publication_OneOffFlyer__c,
    //         Publication_ContinueFlyer__c = base.Publication_ContinueFlyer__c,
    //         StoreListURL__c = base.StoreListURL__c,
    //         ShopList_CollectStatus__c = base.ShopList_CollectStatus__c,
    //         InsertedFlyer__c = base.InsertedFlyer__c,
    //         PostingStatus_Memo__c = base.PostingStatus_Memo__c,
    //         ScheduledPublicationDate__c = base.ScheduledPublicationDate__c,
    //         ScheduledPublicationDateDetails__c = base.ScheduledPublicationDateDetails__c,
    //         MonthlyPublicationFrequency__c = base.MonthlyPublicationFrequency__c,
    //         ApplicatonPDFStorage__c = base.ApplicatonPDFStorage__c,
    //         ApplicationStatus_Memo__c = base.ApplicationStatus_Memo__c,
    //         InHouseMedia_SNS__c = base.InHouseMedia_SNS__c,
    //         InHouseMedia_Web__c = base.InHouseMedia_Web__c,
    //         InHouseMedia_App__c = base.InHouseMedia_App__c,
    //         PromotionService_UsageStats__c = base.PromotionService_UsageStats__c,
    //         TransferredFlgMarketing__c = base.TransferredFlgMarketing__c,
    //         LogoStorage__c = base.LogoStorage__c
    //         //LogoStrageMaster__c = base.LogoStrageMaster__c 数式項目のためデータ移行不要
    //     );
    // }

    /**
     * サービス管理のデータを新オブジェクトへ移行する(ツール系)
     *  レコードタイプ関係なく一律設定する
     * @param tgtRecordTypeId 新レコードのレコードタイプID
     * @param base 移行元サービス管理
     * @return データ移行後新オブジェクト
     */
    // private OrderProgressActionCheck__c createOrderProgressActionCheckTool(Id tgtRecordTypeId, OrderProgress__c base) {
    //     String recordName = base.Name + RECORD_NAME_TOOL;
    //     return new OrderProgressActionCheck__c(
    //         Name = recordName.left(80),
    //         OrderProgress_Tool_SalesPromotion__c = base.Id,
    //         RecordTypeId = tgtRecordTypeId,
    //         MaxGrantPerPLCPeriod__c = base.MaxGrantPerPLCPeriod__c,
    //         MaxGrantPerPay__c = base.MaxGrantPerPay__c,
    //         B2Poster__c = base.B2Poster__c,
    //         B2PosterPerKit__c = base.B2PosterPerKit__c,
    //         B2PosterBulkSale__c = base.B2PosterBulkSale__c,
    //         CMWebPublishConsentForm__c = base.CMWebPublishConsentForm__c,
    //         ES_SecondInCharge__c = base.ES_SecondInCharge__c,
    //         ES_PersonInCharge__c = base.ES_PersonInCharge__c,
    //         KPIFormula__c = base.KPIFormula__c,
    //         KPIType__c = base.KPIType__c,
    //         KPIAchievedFlg__c = base.KPIAchievedFlg__c,
    //         KPIAchievementRate__c = base.KPIAchievementRate__c,
    //         KVMainVisual__c = base.KVMainVisual__c,
    //         LPCheckCompleted__c = base.LPCheckCompleted__c,
    //         MTG_PersonInCharge__c = base.MTG_PersonInCharge__c,
    //         MTGedFlg__c = base.MTGedFlg__c,
    //         PLCQuestionDistributeEmail__c = base.PLCQuestionDistributeEmail__c,
    //         PLCQuestionDistributeName__c = base.PLCQuestionDistributeName__c,
    //         PayPayCoverImageUsageIn__c = base.PayPayCoverImageUsageIn__c,
    //         PayPayLogoUsageIn__c = base.PayPayLogoUsageIn__c,
    //         PayPayCoverImageUsageOut__c = base.PayPayCoverImageUsageOut__c,
    //         PayPayLogoUsageOut__c = base.PayPayLogoUsageOut__c,
    //         QRPreferredTransition__c = base.QRPreferredTransition__c,
    //         SBPLCAppeal__c = base.SBPLCAppeal__c,
    //         CMCheckCompleted__c = base.CMCheckCompleted__c,
    //         VerifierPromo__c = base.VerifierPromo__c,
    //         VerifierSales__c = base.VerifierSales__c,
    //         AnyNumberOfTimesStatement__c = base.AnyNumberOfTimesStatement__c,
    //         CPBannerTOPPage__c = base.CPBannerTOPPage__c,
    //         CPBannerProductCart__c = base.CPBannerProductCart__c,
    //         CPBannerPostingCriteria__c = base.CPBannerPostingCriteria__c,
    //         CPBannerSettlementPage__c = base.CPBannerSettlementPage__c,
    //         CPBannerReason__c = base.CPBannerReason__c,
    //         TwitterFollowers__c = base.TwitterFollowers__c,
    //         TwitterURL__c = base.TwitterURL__c,
    //         TwitterNotice__c = base.TwitterNotice__c,
    //         MMMembersNumber__c = base.MMMembersNumber__c,
    //         MMAnnouceStatus__c = base.MMAnnouceStatus__c,
    //         MMTransmissionNumber__c = base.MMTransmissionNumber__c,
    //         ExplanationDraft__c = base.ExplanationDraft__c,
    //         InHouseAppDLPerUU__c = base.InHouseAppDLPerUU__c,
    //         InHouseAppPushNotificationNumber__c = base.InHouseAppPushNotificationNumber__c,
    //         InHouseAppAnnounceStatus__c = base.InHouseAppAnnounceStatus__c,
    //         NoticeTimeline__c = base.NoticeTimeline__c,
    //         PostCreatedCompleted__c = base.PostCreatedCompleted__c,
    //         PostCreation_RequestCompleted__c = base.PostCreation_RequestCompleted__c,
    //         OtherPerKit__c = base.OtherPerKit__c,
    //         OtherPerBulk__c = base.OtherPerBulk__c,
    //         OtherSizePoster__c = base.OtherSizePoster__c,
    //         OtherSizePosterPerKit__c = base.OtherSizePosterPerKit__c,
    //         OtherSizePosterPerBulk__c = base.OtherSizePosterPerBulk__c,
    //         TotalKits__c = base.TotalKits__c,
    //         CampaignToken__c = base.CampaignToken__c,
    //         CouponCreatedCompleted__c = base.CouponCreatedCompleted__c,
    //         PLCPeriod__c = base.PLCPeriod__c,
    //         SwingPOP__c = base.SwingPOP__c,
    //         SwingPOPPerKit__c = base.SwingPOPPerKit__c,
    //         SwingPOPPerBulk__c = base.SwingPOPPerBulk__c,
    //         StampcardPurpose__c = base.StampcardPurpose__c,
    //         StampPost_Completed__c = base.StampPost_Completed__c,
    //         StampPeriod__c = base.StampPeriod__c,
    //         StampCondition__c = base.StampCondition__c,
    //         StampSpecialOffer__c = base.StampSpecialOffer__c,
    //         ToolInputComplete__c = base.ToolInputComplete__c,
    //         DesignPattern__c = base.DesignPattern__c,
    //         Data__c = base.Data__c,
    //         Banner__c = base.Banner__c,
    //         BlandPageCreatedCompleted__c = base.BlandPageCreatedCompleted__c,
    //         BlandIntroductionRequestCreate__c = base.BlandIntroductionRequestCreate__c,
    //         Image_SubmitCompleted__c = base.Image_SubmitCompleted__c,
    //         PromotionAgreement__c = base.PromotionAgreement__c,
    //         BonusSetting__c = base.BonusSetting__c,
    //         NumberOfRecoups__c = base.NumberOfRecoups__c,
    //         Photo_SubmitCompleted__c = base.Photo_SubmitCompleted__c,
    //         LogoStorageFolder__c = base.LogoStorageFolder__c,
    //         LogoSelectReason__c = base.LogoSelectReason__c,
    //         NoticeConfirmation_RequestCompleted__c = base.NoticeConfirmation_RequestCompleted__c,
    //         ReportDeal__c = base.ReportDeal__c,
    //         ReportNeed__c = base.ReportNeed__c,
    //         EnterpriseMemo__c = base.EnterpriseMemo__c,
    //         DeliveryRemarks__c = base.DeliveryRemarks__c,
    //         DraftFormat_CollectCompleted__c = base.DraftFormat_CollectCompleted__c,
    //         DraftFormat_CouponPost_Completed__c = base.DraftFormat_CouponPost_Completed__c,
    //         DraftFormat_StampPost_Completed__c = base.DraftFormat_StampPost_Completed__c,
    //         Draft_DoubleCheck__c = base.Draft_DoubleCheck__c,
    //         Draft_Deadline__c = base.Draft_Deadline__c,
    //         ContentsA4Poster__c = base.ContentsA4Poster__c,
    //         ContentsOther__c = base.ContentsOther__c,
    //         ContentsSwingPOP__c = base.ContentsSwingPOP__c,
    //         ContentsSticker__c = base.ContentsSticker__c,
    //         ContentsTrianglePOP__c = base.ContentsTrianglePOP__c,
    //         ContentsGreetingCard__c = base.ContentsGreetingCard__c,
    //         ContentsExplanationDraft__c = base.ContentsExplanationDraft__c,
    //         ReproductionReration__c = base.ReproductionReration__c,
    //         FirstCredit_AcquisitionCompleted__c = base.FirstCredit_AcquisitionCompleted__c,
    //         FirstCredit_AcquisitionDate__c = base.FirstCredit_AcquisitionDate__c,
    //         MaxUsedTime__c = base.MaxUsedTime__c,
    //         AnalyticalUtilization_DocumentCreate__c = base.AnalyticalUtilization_DocumentCreate__c,
    //         PurposeOfFunding__c = base.PurposeOfFunding__c,
    //         DraftNumber__c = base.DraftNumber__c,
    //         ParticipationDeadline__c = base.ParticipationDeadline__c,
    //         NumberOfCoveringWithinAGroup__c = base.NumberOfCoveringWithinAGroup__c,
    //         CouponUsageRate__c = base.CouponUsageRate__c,
    //         GrowthRate__c = base.GrowthRate__c,
    //         IncrementalGMW__c = base.IncrementalGMW__c,
    //         PerformanceCompleted__c = base.PerformanceCompleted__c,
    //         PerformanceCompleted_Capitalization__c = base.PerformanceCompleted_Capitalization__c,
    //         ExamComplete__c = base.ExamComplete__c,
    //         MTG_PreferredDate__c = base.MTG_PreferredDate__c,
    //         ShopListAddCompleted__c = base.ShopListAddCompleted__c,
    //         ShopListDeleteCompleted__c = base.ShopListDeleteCompleted__c,
    //         ShopListCheckCompleted__c = base.ShopListCheckCompleted__c,
    //         Commission__c = base.Commission__c,
    //         InvestmentRecoupLogic__c = base.InvestmentRecoupLogic__c,
    //         GreetingCardPerKit__c = base.GreetingCardPerKit__c,
    //         GreetingCardPerBulk__c = base.GreetingCardPerBulk__c,
    //         GreetingCard__c = base.GreetingCard__c,
    //         Stamp_AcquisitionDateCompleted__c = base.Stamp_AcquisitionDateCompleted__c,
    //         Stamp_AcquisitionDate__c = base.Stamp_AcquisitionDate__c,
    //         DocsFolderURL__c = base.DocsFolderURL__c,
    //         MinimumPayment__c = base.MinimumPayment__c,
    //         FinalVersionCompleted__c = base.FinalVersionCompleted__c,
    //         UpcomingBudget__c = base.UpcomingBudget__c,
    //         UpcomingYearMonth__c = base.UpcomingYearMonth__c,
    //         NextImplementation__c = base.NextImplementation__c,
    //         ComparingEndDate__c = base.ComparingEndDate__c,
    //         ComparingStartDate__c = base.ComparingStartDate__c,
    //         JudicialAffairsCompleted__c = base.JudicialAffairsCompleted__c,
    //         BonusCost__c = base.BonusCost__c,
    //         BonusResource__c = base.BonusResource__c,
    //         ApplicatonCheckCompleted__c = base.ApplicatonCheckCompleted__c,
    //         ApplicationCollectStatus__c = base.ApplicationCollectStatus__c,
    //         IncrementalGMWFormula__c = base.IncrementalGMWFormula__c,
    //         RequestForDecision_Acquired__c = base.RequestForDecision_Acquired__c,
    //         RequestForDecision_AcquisitionDate__c = base.RequestForDecision_AcquisitionDate__c,
    //         RequestForDecision_Memo_Acquired__c = base.RequestForDecision_Memo_Acquired__c,
    //         //DeliveryInfo__c = base.DeliveryInfo__c, URL埋め込み数式のためデータ移行不要
    //         DeliveryInputComplete__c = base.DeliveryInputComplete__c,
    //         DeliveryService__c = base.DeliveryService__c,
    //         MaterialPrecautions__c = base.MaterialPrecautions__c,
    //         ResultEntered__c = base.ResultEntered__c,
    //         MemoCheckRequest__c = base.MemoCheckRequest__c,
    //         MemorandumCollectionStatus__c = base.MemorandumCollectionStatus__c,
    //         AmountRecorded__c = base.AmountRecorded__c,
    //         ExplanationDraftPerKit__c = base.ExplanationDraftPerKit__c,
    //         ExplanationDraftPerBulk__c = base.ExplanationDraftPerBulk__c,
    //         BillingRate__c = base.BillingRate__c,
    //         BillingContactCompleted_First__c = base.BillingContactCompleted_First__c,
    //         BillingContactCompleted_Second__c = base.BillingContactCompleted_Second__c,
    //         PromotionCheckCompleted__c = base.PromotionCheckCompleted__c,
    //         PromotionInfoCompleted__c = base.PromotionInfoCompleted__c,
    //         TransferredFlg__c = base.TransferredFlg__c,
    //         SendingStatus__c = base.SendingStatus__c,
    //         Addressee__c = base.Addressee__c,
    //         NumberOfExpenses__c = base.NumberOfExpenses__c,
    //         AchievementRate__c = base.AchievementRate__c,
    //         CapitalizationRate__c = base.CapitalizationRate__c,
    //         CapitalizationAmount__c = base.CapitalizationAmount__c,
    //         DMPosting__c = base.DMPosting__c,
    //         Publication_Flyer_AgentService__c = base.Publication_Flyer_AgentService__c,
    //         Publication_Flyer_Memo__c = base.Publication_Flyer_Memo__c,
    //         Publication_Flyer__c = base.Publication_Flyer__c,
    //         ToolMemo__c = base.ToolMemo__c,
    //         BlandPageCreatedUser__c = base.BlandPageCreatedUser__c,
    //         Online_LINEFlyer__c = base.Online_LINEFlyer__c,
    //         Online_Shufoo__c = base.Online_Shufoo__c,
    //         Online_KurashiruFlyer__c = base.Online_KurashiruFlyer__c,
    //         Online_Tokubai__c = base.Online_Tokubai__c,
    //         SubmissionsNumber__c = base.SubmissionsNumber__c,
    //         SubmissionsImageNumber__c = base.SubmissionsImageNumber__c,
    //         SubmitFlyerPossibleDateTime__c = base.SubmitFlyerPossibleDateTime__c,
    //         Publication_OneOffFlyer__c = base.Publication_OneOffFlyer__c,
    //         Publication_ContinueFlyer__c = base.Publication_ContinueFlyer__c,
    //         StoreListURL__c = base.StoreListURL__c,
    //         ShopList_CollectStatus__c = base.ShopList_CollectStatus__c,
    //         InsertedFlyer__c = base.InsertedFlyer__c,
    //         PostingStatus_Memo__c = base.PostingStatus_Memo__c,
    //         ScheduledPublicationDate__c = base.ScheduledPublicationDate__c,
    //         ScheduledPublicationDateDetails__c = base.ScheduledPublicationDateDetails__c,
    //         MonthlyPublicationFrequency__c = base.MonthlyPublicationFrequency__c,
    //         ApplicatonPDFStorage__c = base.ApplicatonPDFStorage__c,
    //         ApplicationStatus_Memo__c = base.ApplicationStatus_Memo__c,
    //         InHouseMedia_SNS__c = base.InHouseMedia_SNS__c,
    //         InHouseMedia_Web__c = base.InHouseMedia_Web__c,
    //         InHouseMedia_App__c = base.InHouseMedia_App__c,
    //         PromotionService_UsageStats__c = base.PromotionService_UsageStats__c,
    //         TransferredFlgMarketing__c = base.TransferredFlgMarketing__c,
    //         LogoStorage__c = base.LogoStorage__c
    //         //LogoStrageMaster__c = base.LogoStrageMaster__c 数式項目のためデータ移行不要
    //     );
    // }
}