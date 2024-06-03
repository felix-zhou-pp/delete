/**
* クラス名: CRMDPMigrationOPMBModBatch
* クラス概要: サービス管理オブジェクト分割 サービス管理データ移行バッチ
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/07
* Updated Date: -
------------------------------------------------------------------------------------------------------
*   サービス管理のレコードをもとに新オブジェクト：サービス管理(加盟店事業)レコードを作成する
*   他オブジェクトで移行元のサービス管理(決済事業)レコードを参照しているレコードに、サービス管理(加盟店事業)を参照させる
*   移行元のサービス管理(決済事業)が、移行対象のサービス管理(決済事業)参照する場合、移行先のサービス管理(加盟店事業)にも対応するサービス管理(加盟店事業)を参照させる
* 開発者コンソールから以下のコマンドを実行する
* CRMDPMigrationOPMBModBatch.run();
*/
global class CRMDPMigrationOPMBModBatch implements Database.Batchable<sObject>, Database.Stateful {
    // DMLException test のためのフラグ
    @testVisible
    private static Boolean isDMLExceptionTest = false;
    // テストで異なるエラーを出し分けるための文字列
    @testVisible
    private static String errorType = '';

    @testVisible
    private static final String DELETE_NAME_LABEL = '【削除対象のため更新禁止】';

    // ログ保存時のタイトル
    @testVisible
    private static final String BATCH_LOG_TITLE = '【CRM高度化】サービス管理(決済事業)移行バッチ:';
    // エラーログ保存時のタイトル
    @testVisible
    private static final String COND_CREATE_ERROR = ' 複製失敗';
    @testVisible
    private static final String COND_UPDATERELATED_RECORDS = ' 参照項目設定失敗';

    // バッチ結果格納
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;
    private Boolean hasDontUpdateObj = false;

    // 移行対象のサービス管理レコードタイプ
    Id RECORDTYPE_LYPMILEAGE; // LYPマイレージ
    Id RECORDTYPE_PAAS; // PAAS
    Id RECORDTYPE_POINT; // PayPayポイント
    Id RECORDTYPE_OFF_PLC; // オフライン_PLC
    Id RECORDTYPE_ON_PLC; // オンライン_PLC
    Id RECORDTYPE_GIFTCARD; // ギフトカード
    Id RECORDTYPE_CAMPAIGN; // キャンペーン
    Id RECORDTYPE_STAMPCARD; // スタンプカード
    Id RECORDTYPE_FLYER_APPLY; // チラシ_申込
    Id RECORDTYPE_MYSTORE; // マイストア
    Id RECORDTYPE_MINIAPP; // ミニアプリ
    Id RECORDTYPE_RETAILGIFT; // リテールギフト
    Id RECORDTYPE_ROUTEOPENING; // ルート開通
    Id RECORDTYPE_REVISITINGCOUPON; // 再来店クーポン
    Id RECORDTYPE_SCHEDULEDCOUPON; // 日時指定クーポン
    Id RECORDTYPE_BALANCEAPI; // 残高API
    Id RECORDTYPE_SPECIFICPRODUCTCOUPON; // 商品特定クーポン
    
    // 移行後のサービス管理(加盟店事業)のレコードタイプ
    Id RECORDTYPE_LYPMILEAGE_MERCHANTBUSINESS; // LYPマイレージ
    Id RECORDTYPE_PAAS_MERCHANTBUSINESS; // PAAS
    Id RECORDTYPE_POINT_MERCHANTBUSINESS; // PayPayポイント
    Id RECORDTYPE_OFF_PLC_MERCHANTBUSINESS; // オフライン_PLC
    Id RECORDTYPE_ON_PLC_MERCHANTBUSINESS; // オンライン_PLC
    Id RECORDTYPE_GIFTCARD_MERCHANTBUSINESS; // ギフトカード
    Id RECORDTYPE_CAMPAIGN_MERCHANTBUSINESS; // キャンペーン
    Id RECORDTYPE_STAMPCARD_MERCHANTBUSINESS; // スタンプカード
    Id RECORDTYPE_FLYER_APPLY_MERCHANTBUSINESS; // チラシ_申込
    Id RECORDTYPE_MYSTORE_MERCHANTBUSINESS_ENP; // マイストア（大手営業管理）
    Id RECORDTYPE_MINIAPP_MERCHANTBUSINESS; // ミニアプリ
    Id RECORDTYPE_RETAILGIFT_MERCHANTBUSINESS; // リテールギフト
    Id RECORDTYPE_ROUTEOPENING_MERCHANTBUSINESS; // ルート開通
    Id RECORDTYPE_REVISITINGCOUPON_MERCHANTBUSINESS; // 再来店クーポン
    Id RECORDTYPE_SCHEDULEDCOUPON_MERCHANTBUSINESS; // 日時指定クーポン
    Id RECORDTYPE_BALANCEAPI_MERCHANTBUSINESS; // 残高API
    Id RECORDTYPE_SPECIFICPRODUCTCOUPON_MERCHANTBUSINESS; // 商品特定クーポン

    Id RECORDTYPE_ACTIONCHECK_POINT_ACT; // サービス管理アクション:PayPayポイント（アクションチェック/再現）
    Id RECORDTYPE_ACTIONCHECK_CAMPAIGN_ACT; // サービス管理アクション:キャンペーン（アクションチェック/再現）

    // サービス管理(決済事業) のレコードタイプIDのSet
    Set<String> orderProgressRecordTypeIdSet;

    /**
     * コンストラクタ
     */
    public CRMDPMigrationOPMBModBatch() {
        // 移行対象のサービス管理(決済事業)のレコードタイプID取得
        RECORDTYPE_LYPMILEAGE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'LYPMileage'); // LYPマイレージ
        RECORDTYPE_PAAS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PaaSRecordType'); // PAAS
        RECORDTYPE_POINT = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PCRecordType'); // PayPayポイント
        RECORDTYPE_OFF_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PLCRecordType'); // オフライン_PLC
        RECORDTYPE_ON_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'OnlinePLCRecordType'); // オンライン_PLC
        RECORDTYPE_GIFTCARD = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Giftcard'); // ギフトカード
        RECORDTYPE_CAMPAIGN = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Campaign'); // キャンペーン
        RECORDTYPE_STAMPCARD = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'SCRecordType'); // スタンプカード
        RECORDTYPE_FLYER_APPLY = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'FlyerApply'); // チラシ_申込
        RECORDTYPE_MYSTORE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PayEnterprise_mystore'); // マイストア
        RECORDTYPE_MINIAPP = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'MiniAppRecordType'); // ミニアプリ
        RECORDTYPE_RETAILGIFT = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RetailGift'); // リテールギフト
        RECORDTYPE_ROUTEOPENING = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RouteOpening'); // ルート開通
        RECORDTYPE_REVISITINGCOUPON = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RevisitingCoupon'); // 再来店クーポン
        RECORDTYPE_SCHEDULEDCOUPON = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'ScheduledCoupon'); // 日時指定クーポン
        RECORDTYPE_BALANCEAPI = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'BalanceAPI'); // 残高API
        RECORDTYPE_SPECIFICPRODUCTCOUPON = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'SpecificProductCoupon'); // 商品特定クーポン
        // サービス管理アクションチェック レコードタイプ
        RECORDTYPE_ACTIONCHECK_POINT_ACT = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'PCRecordType_Action'); // PayPayポイント（アクションチェック/再現）
        RECORDTYPE_ACTIONCHECK_CAMPAIGN_ACT = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'Campaign_Action'); // キャンペーン（アクションチェック/再現）

        // 移行対象のサービス管理(決済事業)のレコードタイプIDのSet作成
        orderProgressRecordTypeIdSet = new Set<String>{
            String.valueOf(RECORDTYPE_LYPMILEAGE),
            String.valueOf(RECORDTYPE_PAAS),
            String.valueOf(RECORDTYPE_POINT),
            String.valueOf(RECORDTYPE_OFF_PLC),
            String.valueOf(RECORDTYPE_ON_PLC),
            String.valueOf(RECORDTYPE_GIFTCARD),
            String.valueOf(RECORDTYPE_CAMPAIGN),
            String.valueOf(RECORDTYPE_STAMPCARD),
            String.valueOf(RECORDTYPE_FLYER_APPLY),
            String.valueOf(RECORDTYPE_MYSTORE),
            String.valueOf(RECORDTYPE_MINIAPP),
            String.valueOf(RECORDTYPE_RETAILGIFT),
            String.valueOf(RECORDTYPE_ROUTEOPENING),
            String.valueOf(RECORDTYPE_REVISITINGCOUPON),
            String.valueOf(RECORDTYPE_SCHEDULEDCOUPON),
            String.valueOf(RECORDTYPE_BALANCEAPI),
            String.valueOf(RECORDTYPE_SPECIFICPRODUCTCOUPON)
        };

        // サービス管理(加盟店事業) のレコードタイプID取得
        RECORDTYPE_LYPMILEAGE_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'LYPMileage');
        RECORDTYPE_PAAS_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'PaaSRecordType');
        RECORDTYPE_POINT_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'PCRecordType');
        RECORDTYPE_OFF_PLC_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'PLCRecordType');
        RECORDTYPE_ON_PLC_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'OnlinePLCRecordType');
        RECORDTYPE_GIFTCARD_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'Giftcard');
        RECORDTYPE_CAMPAIGN_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'Campaign');
        RECORDTYPE_STAMPCARD_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'SCRecordType');
        RECORDTYPE_FLYER_APPLY_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'FlyerApply');
        RECORDTYPE_MYSTORE_MERCHANTBUSINESS_ENP = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'PayEnterprise_mystore');
        RECORDTYPE_MINIAPP_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'MiniAppRecordType');
        RECORDTYPE_RETAILGIFT_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'RetailGift');
        RECORDTYPE_ROUTEOPENING_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'RouteOpening');
        RECORDTYPE_REVISITINGCOUPON_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'RevisitingCoupon');
        RECORDTYPE_SCHEDULEDCOUPON_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'ScheduledCoupon');
        RECORDTYPE_BALANCEAPI_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'BalanceAPI');
        RECORDTYPE_SPECIFICPRODUCTCOUPON_MERCHANTBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, 'SpecificProductCoupon');
    }

    // サービス管理と（サービス管理アクションの）キャンペーントークン
    Map<Id, String> opIdCampaignTokenMap = new Map<Id, String>();

    /**
     * カスタム例外クラス
     */
    public class MyException extends Exception{}

    /**
     * バッチ呼び出し
     */
    global static void run() {
        // バッチサイズ200仮置き
        Database.executeBatch(new CRMDPMigrationOPMBModBatch(), 200);
    }

    /**
     * バッチ開始
     * @param BC 一括処理ジョブ
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // サービス管理(加盟店事業)への移行対象項目と、後続処理に必要な項目のみクエリに含める
        return Database.getQueryLocator([
            SELECT 
                // 後続処理に必要な項目
                Id,
                // サービス管理(加盟店事業)への移行対象項目
                Name,
                RecordTypeId,
                OpportunityId__c,
                OwnerId,
                AccountHolderNameKana__c,
                AccountId__c,
                AdPayChargeAccountId__c,
                AdPayChargeClientSiteNumber__c,
                AdvancePaymentType__c,
                AgreementContractDate__c,
                AgreementContractScheduleDate__c,
                AlertEmailPerson__c,
                AlertSendCCEmail__c,
                AlertSendTOEmail__c,
                AlertThreshold__c,
                AllOperatingStore__c,
                AmountPPCover__c,
                AnalyticalUtilizationTask__c,
                AnalyticalUtilization_Document__c,
                AnalyticalUtilization__c,
                AppliedDomain__c,
                ApprovalCompleteNumber__c,
                ApprovalNumber__c,
                ApprovalRequestDate__c,
                AsmpRegiShareML__c,
                AssumGTVPerMonth__c,
                AssumPaymentPerMonth__c,
                AssumePremiumCostBurden__c,
                AssumedReturnAgu__c,
                AssumedReturnMode__c,
                AssumedReturnRisk__c,
                AvgCustUnitPrice__c,
                BenefitsCategory__c,
                BenefitsCost__c,
                BenefitsPrice__c,
                BenefitsType__c,
                BillingAccountType__c,
                BillingBuildingNumber__c,
                BillingCity__c,
                BillingManagerDepartment__c,
                BillingManagerMail__c,
                BillingManagerName__c,
                BillingMethodRelative__c,
                BillingMethod__c,
                BillingName__c,
                BillingPrefectures__c,
                BillingZipCode__c,
                BoxHopeUse__c,
                BoxURL__c,
                BoxUserEmail__c,
                BudgetTotal__c,
                CBGrantRate__c,
                CPAgreement__c,
                CPPFFeeStandard__c,
                CPPFFee__c,
                CPParticipationPattern__c,
                CampaignDesign__c,
                CampaignOperatingExpenses__c,
                CampaignParticipationFee__c,
                CampaignType__c,
                CannibalizationRate__c,
                CapitalBurden__c,
                CheckSales__c,
                ClientSiteNumber__c,
                CollectedInvoiceInfoSheetURL__c,
                CommissionRate__c,
                //CompanyID__c,
                CompanyURL__c,
                CompetitionFlg__c,
                ConfirmInstallationNum__c,
                ConfirmInstallation__c,
                ConfirmMID__c,
                ContractBuildingNumber__c,
                ContractCity__c,
                ContractEndDate__c,
                ContractOppNo__c,
                ContractPrefectures__c,
                ContractProposalDraft__c,
                ContractStartDate__c,
                ContractStorageNo__c,
                ContractStreetNumber__c,
                ContractType__c,
                CorporateName__c,
                CostCoverdBy__c,
                CostSideTask__c,
                CouponConditionsLowAmount__c,
                CouponId__c,
                CouponInitialCost__c,
                CouponMonthlyCost__c,
                CouponPublishStart__c,
                CouponSuggestionPattern__c,
                CouponUsagePeriodDays__c,
                CouponUsagePeriodEndDate__c,
                CouponUseCountLimit__c,
                CoveringRateOfCost__c,
                CurrentPointUseRate__c,
                DailyTxPredictedValue__c,
                Dashboard__c,
                DeadlineDay__c,
                DevStartDate__c,
                DevSupAuto__c,
                DevSup_SalesReport__c,
                DevSupportSlackInformed__c,
                DocumentApprovalStatus__c,
                DraftSheetStorageURL__c,
                DuplicateGrants__c,
                EconomicConditionHold__c,
                EndDate__c,
                FeeBilling__c,
                FeeFixedLastTime__c,
                FeeFixed__c,
                FeeInvoiceIssuanceDate__c,
                FeePercentLastTime__c,
                FeePercent__c,
                FeeTariff__c,
                FlyerFee__c,
                FocusServiceType__c,
                FolderURL__c,
                FrequencyOfUseDetail__c,
                FrequencyOfUseType__c,
                FunctionalAspectTask__c,
                GMApprovalComment__c,
                GMApprovalDate__c,
                GMVAgu__c,
                GMVMode__c,
                GMVRisk__c,
                GWCompany__c,
                GeneralMtgComment__c,
                GeneralMtgDay__c,
                GiftCostPAYGRate__c,
                GiftImageStorage__c,
                GlantLimitPeriod__c,
                GlantLimitTimes__c,
                GrantAmount__c,
                GrantBalanceType__c,
                GrantRate__c,
                GrantingPointsMethod__c,
                GuidelineRate__c,
                HopeInstallationNum__c,
                HopeInstallation__c,
                HopeMID__c,
                ImplementCP__c,
                ImplementCost__c,
                ImplementFinishedPoint__c,
                ImplementPurposes__c,
                InclusiveName__c,
                Industryclass__c,
                InsertedFlyerAnnouncement__c,
                InstallationName__c,
                IntegrationPerson__c,
                IntegrationTeamMemo__c,
                Integration_Status__c,
                Introductionstores__c,
                InviteBox__c,
                InvoiceMemo__c,
                InvolvedSalesFee__c,
                IrregularApprovalNumber__c,
                IrregularContract__c,
                IsChangeRecordType__c,
                IsDevSupAutoChecked__c,
                IsInvalidValidationRule__c,
                IsPLCIncludeInsideBuilding__c,
                LPLogoURL__c,
                LPPublishCategory__c,
                LaunchDate__c,
                LaunchScheduledDate__c,
                LeftStamps__c,
                LightPlanExpirationDate__c,
                LightPlanStartDate__c,
                LogoURL__c,
                MID__c,
                MailNewsletterDelivery__c,
                MainMID__c,
                MakerDepreciationRate__c,
                MakerFundingAmount__c,
                ManagementMeetingProposal__c,
                ManagerApprovalComment__c,
                ManagerApprovalDate__c,
                MarketingPerson__c,
                MaxBonusGrantAmountPerPay__c,
                MaxBonusGrantAmountPerUserPLC__c,
                MaxCoveringOfCost__c,
                Memo__c,
                MerchantBurden__c,
                MerchantContractType__c,
                MerchantDepreciationRate__c,
                MerchantGetPerson__c,
                MerchantGetTask__c,
                MerchantMID__c,
                MethodUsagePeriodSetting__c,
                MgmtMtgDay__c,
                MinPaymentAmount__c,
                MultiMID__c,
                MultiMIDorSingleMID__c,
                MyStoreKind__c,
                NDA__c,
                NextActionText__c,
                NextOppDate__c,
                NumOfTargetMid__c,
                NumberOfSlots__c,
                NumberOfStoreId__c,
                Numberofstores__c,
                OnOff__c,
                OnboardingTask__c,
                OneyearPointExchangeAmount__c,
                OneyearPointIssueAmount__c,
                OneyearScheduledGrantAmount__c,
                OppStatus__c,
                OpportunityLineItemId__c,
                OriginalContractPeriod__c,
                OtherTask__c,
                OtherTask_freeText__c,
                OutsystemsApprovalNumber__c,
                Overview__c,
                OwnedMediaExposure__c,
                PLCFeeFixedLastTime__c,
                PLCFeeFixed__c,
                PLCFeeLastTime__c,
                PLCFee__c,
                POSVendor__c,
                PastImplementationsNumber__c,
                PastSituation__c,
                PayPayFundingAmount__c,
                PayingMethod__c,
                PaymentFee__c,
                PaymentSite__c,
                PointRate__c,
                Point_URL__c,
                PostedOnDashboard__c,
                PosterInstallation__c,
                ProdAPIKey__c,
                ProgressStatus__c,
                RelativeAdjustment__c,
                RepresentativeName__c,
                ReproductionFlg__c,
                ReproductionReason__c,
                RequiredDocSubmitDate__c,
                ReturnVisitCouponFeePercent__c,
                RevisitCouponFeeFixed__c,
                SIDListStorageURL__c,
                SLA_SpecialNote__c,
                SLA_Type__c,
                SalesChannels__c,
                SalesDepartment__c,
                SalesDepth__c,
                SalesForecast__c,
                SalesInvolved__c,
                SalesMgmtPromoMtgDate__c,
                SalesStatus_1__c,
                SeasonallyCoupon__c,
                SettlementUpperLimit__c,
                ShipmentSales__c,
                ShippingDisplayStorePercent__c,
                SidCount__c,
                SnsAnnouncement__c,
                SpecialOfferDetails__c,
                SpecialOffer__c,
                StampCardId__c,
                StampConditionalSum__c,
                StampsPerDayNumber__c,
                StampsPerDay__c,
                StartDate__c,
                StateTask__c,
                Status__c,
                StorePromotionalKit__c,
                SuppliersInfoLink__c,
                SystemMaintenanceEmail__c,
                SystemMaintenancePerson__c,
                SystemNda__c,
                TVCM__c,
                TargetProduct__c,
                TargetSegment__c,
                Target_Service_AnnualSales__c,
                TestCandidate__c,
                TestInstallation__c,
                TestLaunchDateEnd__c,
                TestLaunchDateStart__c,
                Test_Memo__c,
                TopOpp__c,
                TotalNumCouponImplemented__c,
                TotalStamps__c,
                UmbrellaAgency__c,
                WEBCM__c,
                WayToConnect__c,
                WayToGiveStamps__c,
                Yomi__c,
                mpMerchant__c,
                mpOpportunityRelatedFlg__c,
                Industryclassification__c,
                NewIndustryclass__c,
                IsDataPolicyConfirm__c,
                ConsortiumMemoURL__c,
                POSLinkageMID__c,
                DataPolicyTask__c,
                POSLinkageTask__c,
                IsConsortiumParticipation__c,
                IsPOSDevelopCost__c,
                MainDealMaker__c,
                POSDevelopBurdenEstCost__c,
                TargetProductName__c,
                POSDevelopCostPP__c,
                POSDevelopCostClient__c,
                ContractURL__c,
                CampaignOverview__c,
                RequestRetailName__c,
                ProductTask__c,
                ProposalURL__c,
                InformationForYJ__c,
                WantToApplyAds__c,
                PlanOfAds__c,
                AdsAmount__c,
                AdsStartDate__c,
                AdsEndDate__c,
                EstimatedAmountIssuedPoint__c,
                CommissionRateIssuedPoint__c,
                PlatformCost__c,
                AdsRevenueShare__c,
                AdsRevenueShareAgencyFee__c,
                RecordOfResultsPerson__c,
                RecordOfResultsMonth__c,
                IsJANConnect__c,
                FeeIncomeManual__c,
                LostAmountSPTariff__c,
                ApprovalName__c,
                ApproveDate__c,
                BannerPublicationStart__c,
                BudgetTokenCharge__c,
                EndDateTime__c,
                FreeFeeEndDate__c,
                IneligibleSID_MSID__c,
                IsLimitedGrant__c,
                LpUrl__c,
                NotificationDate__c,
                PointCondition__c,
                RequiredPromotionTool__c,
                StartDateTime__c,
                TobaccoExclusion__c,
                AdsImplementation__c,
                ContactNumber__c,
                ExpectedEffect__c,
                ExpectedEffect_freeText__c,
                FBDocumentURL__c,
                GWMerchantConnectionTestDate__c,
                GWMerchantConnectionTestScheduleDate__c,
                KPIFeedback__c,
                KPINumericalResult__c,
                NextKPI__c,
                NextKPIResult__c,
                ReferralAgencyName__c,
                AgencyOrSecretariat__c,
                ActionPoint_TargetOrNot__c,
                BillingMeans__c,
                OtherBillingMeans__c,
                NextactionContactDate__c,
                NextactionMain__c,
                NextactionPartner__c,
                NextactionContent__c,
                LastNegotiationsDate__c,
                NegotiationPartnerPositionLayer__c,
                IsTransactionOnlyTestType__c,
                TargetBrandName__c,
                LYPMileageOverview__c,
                GiftcardIssuingTiming__c,
                GiftcardDistributionDate__c,
                NumOfIissues__c,
                IssueAmount__c,
                FeeStd__c,
                FeeFixedStd__c,
                EconConditionSPTariff__c,
                OutsystemsCreditApprovalNumber__c,
                IssuingMethod__c
            FROM OrderProgress__c
            WHERE RecordTypeId IN :orderProgressRecordTypeIdSet
            AND OrderProgressMB__c = null
        ]);
    }

    /**
     * バッチ処理
     * @param BC 一括処理ジョブ
     * @param orderProgressList 更新対象サービス管理リスト
     */
    global void execute(Database.BatchableContext BC, List<OrderProgress__c> orderProgressList) {
        bResult.totalRecordSize += orderProgressList.size();

        Map<Id, Id> insertSuccessMap = createOrderProgressMBRecords(orderProgressList);
        if (insertSuccessMap == null) {
            return;
        }
        relateRecordsToOrderProgressMB(insertSuccessMap);
    }

    /**
     * サービス管理(決済事業)のデータを基にサービス管理(加盟店事業)を作成する
     * @param orderProgressList バッチが拾うサービス管理のリスト
     * @return サービス管理(加盟店事業)の作成に成功したサービス管理(決済事業)レコードMap
     */
    private Map<Id, Id> createOrderProgressMBRecords(List<OrderProgress__c> orderProgressList) {
        // サービス管理アクションよりポイントカード、キャンペーンレコードの「キャンペーントークン」を取得する
        for (OrderProgressActionCheck__c actionCheck : [
            SELECT CampaignToken__c, OrderProgress_Action__c 
            FROM OrderProgressActionCheck__c
            WHERE (RecordTypeId = :RECORDTYPE_ACTIONCHECK_POINT_ACT OR RecordTypeId = :RECORDTYPE_ACTIONCHECK_CAMPAIGN_ACT)
            AND OrderProgress_Action__c IN :orderProgressList]) {
            if (String.isNotBlank(actionCheck.CampaignToken__c)) {
                opIdCampaignTokenMap.put(actionCheck.OrderProgress_Action__c, actionCheck.CampaignToken__c);
            }
        }

        List<OrderProgressMB__c> newRecordList = new List<OrderProgressMB__c>();
        Set<Id> conversionErrorCompanyIds = new Set<Id>();

        for (OrderProgress__c orderProgress : orderProgressList) {
            Decimal companyId = null;
            /*if (orderProgress.CompanyID__c != null) {
                try {
                    companyId = Decimal.ValueOf(orderProgress.CompanyID__c);
                }
                catch (Exception tex) {
                    conversionErrorCompanyIds.add(orderProgress.Id);
                    this.hasException = true;
                    continue;
                }
            }*/
            // LYPマイレージ
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_LYPMILEAGE)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_LYPMILEAGE_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // PaaS
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_PAAS)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_PAAS_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // PayPayポイント
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_POINT)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_POINT_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // オフライン_PLC
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_OFF_PLC)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_OFF_PLC_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // オンライン_PLC
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_ON_PLC)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_ON_PLC_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // ギフトカード
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_GIFTCARD)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_GIFTCARD_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // キャンペーン
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_CAMPAIGN)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_CAMPAIGN_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // スタンプカード
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_STAMPCARD)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_STAMPCARD_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // チラシ_申込
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_FLYER_APPLY)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_FLYER_APPLY_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // マイストア
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_MYSTORE)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_MYSTORE_MERCHANTBUSINESS_ENP, orderProgress, companyId)
                );
            }
            // ミニアプリ
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_MINIAPP)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_MINIAPP_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // リテールギフト
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_RETAILGIFT)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_RETAILGIFT_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // ルート開通
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_ROUTEOPENING)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_ROUTEOPENING_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // 再来店クーポン
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_REVISITINGCOUPON)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_REVISITINGCOUPON_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // 日時指定クーポン
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_SCHEDULEDCOUPON)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_SCHEDULEDCOUPON_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // 残高API
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_BALANCEAPI)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_BALANCEAPI_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
            // 商品特定クーポン
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_SPECIFICPRODUCTCOUPON)) {
                newRecordList.add(
                    createOrderProgressMerchantBusiness(RECORDTYPE_SPECIFICPRODUCTCOUPON_MERCHANTBUSINESS, orderProgress, companyId)
                );
            }
        }

        Logger logger = new Logger();
        Savepoint sp = Database.setSavepoint();

        // サービス管理（加盟店事業）作成
        try {
            throwException('createOrderProgressMB');
            insert newRecordList;
        }
        catch (Exception ex) {
            Database.rollback(sp);
            logger.error(BATCH_LOG_TITLE + COND_CREATE_ERROR, logger.formatErrorMessage(ex), false).saveAll();

            this.hasException = true;
            bResult.failured(orderProgressList.size());
            return null;
        }

        // サービス管理(決済事業)の項目「サービス管理(加盟店事業)」へ値を設定
        Map<Id, Id> opIdOpmIdMap = new Map<Id, Id>();
        List<OrderProgress__c> newOpList = new List<OrderProgress__c>();
        for (OrderProgressMB__c newRecord : newRecordList) {
            OrderProgress__c updateOp = new OrderProgress__c(Id = newRecord.OrderProgress__c);
            String deleteLabelName = DELETE_NAME_LABEL + newRecord.Name;
            updateOp.Name = deleteLabelName.left(80);
            updateOp.OrderProgressMB__c = newRecord.Id;
            newOpList.add(updateOp);

            opIdOpmIdMap.put(newRecord.OrderProgress__c, newRecord.Id);
        }

        try {
            throwException('OrderProgress__c');
            update newOpList;

            List<String> logInfoText = new List<String>();
            String conversionErrorCompanyIdStr = String.join(conversionErrorCompanyIds, ', ');

            logInfoText.add('移行元 サービス管理(決済事業)数: ' + orderProgressList.size() + '件\n');
            logInfoText.add('参照項目設定サービス管理(決済事業)数: ' + newOpList.size() + '件\n');
            logInfoText.add('新規作成 サービス管理(加盟店事業)数: ' + newRecordList.size() + '件\n');
            logInfoText.add('企業ID変換失敗レコード数: ' + conversionErrorCompanyIds.size() + '件\n');
            logInfoText.add('＞サービス管理ID: ' + conversionErrorCompanyIdStr);
            String formatLogText = String.format('{0}{1}{2}{3}{4}', logInfoText);
            logger.info(BATCH_LOG_TITLE, formatLogText).saveAll();
        }
        catch (Exception ex) {
            // サービス管理の参照項目の設定に失敗した場合ロールバックを実施する
            Database.rollback(sp);
            logger.error(BATCH_LOG_TITLE + COND_UPDATERELATED_RECORDS + '_OrderProgress__c', logger.formatErrorMessage(ex), false).saveAll();

            this.hasException = true;
            bResult.failured(orderProgressList.size());
            return null;
        }

        bResult.successed(newOpList.size());
        bResult.failured(conversionErrorCompanyIds.size());
        return opIdOpmIdMap;
    }

    /**
     * 移行対象のサービス管理(決済事業)レコードを参照している他オブジェクトに移行先のサービス管理(加盟店事業)レコードを参照させる
     * @param opIdOpmIdMap 加盟店事業系の作成に成功したサービス管理IDと加盟店事業のレコードIDのMAP
     */
    private void relateRecordsToOrderProgressMB(Map<Id, Id> opIdOpmIdMap) {

        // アタックリストの「サービス管理(加盟店事業)参照項目」へ値を設定
        List<mpOpportunity__c> newMpOppList = [
            SELECT Id, Name, OrderProgressId__c
            FROM mpOpportunity__c 
            WHERE OrderProgressId__c IN :opIdOpmIdMap.keySet()];
        for (mpOpportunity__c mpopp : newMpOppList) {
            if (opIdOpmIdMap.containsKey(mpopp.OrderProgressId__c)) {
                mpopp.OrderProgressMBId__c = opIdOpmIdMap.get(mpopp.OrderProgressId__c);
            }
        }

        // 加盟店の「サービス管理(加盟店事業)参照項目」へ値を設定
        List<mpMerchant__c> newMerList = [
            SELECT Id, Name, OrderProgressId__c
            FROM mpMerchant__c 
            WHERE OrderProgressId__c IN :opIdOpmIdMap.keySet()];
        for (mpMerchant__c mer : newMerList) {
            if (opIdOpmIdMap.containsKey(mer.OrderProgressId__c)) {
                mer.OrderProgressMBId__c = opIdOpmIdMap.get(mer.OrderProgressId__c);
            }
        }

        // PayPay申込書管理の「サービス管理(加盟店事業)参照項目」へ値を設定
        List<ApplicationForm__c> newAppFormList = [
            SELECT Id, Name, OrderProgressId__c
            FROM ApplicationForm__c 
            WHERE OrderProgressId__c IN :opIdOpmIdMap.keySet()];
        for (ApplicationForm__c appForm : newAppFormList) {
            if (opIdOpmIdMap.containsKey(appform.OrderProgressId__c)) {
                appform.OrderProgressMBId__c = opIdOpmIdMap.get(appform.OrderProgressId__c);
            }
        }

        // サービス管理アクションの「サービス管理(加盟店事業)参照項目」へ値を設定
        List<OrderProgressActionCheck__c> newActionCheckList = [
            SELECT Id, Name, OrderProgress_Action__c, OrderProgress_Tool_SalesPromotion__c, OrderProgressMB_Action__c, OrderProgressMB_Tool_SalesPromotion__c 
            FROM OrderProgressActionCheck__c 
            WHERE (OrderProgress_Action__c IN :opIdOpmIdMap.keySet()) OR (OrderProgress_Tool_SalesPromotion__c IN :opIdOpmIdMap.keySet())];
        for (OrderProgressActionCheck__c actionCheck : newActionCheckList) {
            if (opIdOpmIdMap.containsKey(actionCheck.OrderProgress_Action__c)) {
                actionCheck.OrderProgressMB_Action__c = opIdOpmIdMap.get(actionCheck.OrderProgress_Action__c);
            }
            if (opIdOpmIdMap.containsKey(actionCheck.OrderProgress_Tool_SalesPromotion__c)) {
                actionCheck.OrderProgressMB_Tool_SalesPromotion__c = opIdOpmIdMap.get(actionCheck.OrderProgress_Tool_SalesPromotion__c);
            }
        }

        // サービス申込の「サービス管理(加盟店事業)参照項目」へ値を設定
        List<ServiceOrder__c> newServiceOrderList = [SELECT Id, Name, OrderProgress__c FROM ServiceOrder__c WHERE OrderProgress__c IN :opIdOpmIdMap.keySet()];
        for (ServiceOrder__c serviceOrder : newServiceOrderList) {
            serviceOrder.OrderProgressMB__c = opIdOpmIdMap.get(serviceOrder.OrderProgress__c);
        }

        // 各オブジェクトのレコードを更新する
        updateRelatedRecords(newMpOppList, 'mpOpportunity__c');
        updateRelatedRecords(newMerList, 'mpMerchant__c');
        updateRelatedRecords(newAppFormList, 'ApplicationForm__c');
        updateRelatedRecords(newActionCheckList, 'OrderProgressActionCheck__c');
        updateRelatedRecords(newServiceOrderList, 'ServiceOrder__c');
    }

    /**
     * サービス管理のデータをサービス管理(加盟店事業)へ移行する
     *  サービス管理の、移行対象項目＆各種参照項目等の必須項目の値を持つ、サービス管理(加盟店事業)のレコードを返す
     * @param tgtRecordTypeId サービス管理(加盟店事業)レコードのレコードタイプID
     * @param base 移行元サービス管理
     * @param companyId 企業ID
     * @return データ移行後サービス管理(加盟店事業)オブジェクト
     */
    private OrderProgressMB__c createOrderProgressMerchantBusiness(Id tgtRecordTypeId, OrderProgress__c base, Decimal companyId) {
        return new OrderProgressMB__c(
            Name = base.Name.left(80),
            RecordTypeId = tgtRecordTypeId,
            OpportunityId__c = base.OpportunityId__c,
            OwnerId = base.OwnerId,
            OrderProgress__c = base.Id, // 登録元サービス管理ID
            AccountHolderNameKana__c = base.AccountHolderNameKana__c,
            AccountId__c = base.AccountId__c,
            AdPayChargeAccountId__c = base.AdPayChargeAccountId__c,
            AdPayChargeClientSiteNumber__c = base.AdPayChargeClientSiteNumber__c,
            AdvancePaymentType__c = base.AdvancePaymentType__c,
            AgreementContractDate__c = base.AgreementContractDate__c,
            AgreementContractScheduleDate__c = base.AgreementContractScheduleDate__c,
            AlertEmailPerson__c = base.AlertEmailPerson__c,
            AlertSendCCEmail__c = base.AlertSendCCEmail__c,
            AlertSendTOEmail__c = base.AlertSendTOEmail__c,
            AlertThreshold__c = base.AlertThreshold__c,
            AllOperatingStore__c = base.AllOperatingStore__c,
            AmountPPCover__c = base.AmountPPCover__c,
            AnalyticalUtilizationTask__c = base.AnalyticalUtilizationTask__c,
            AnalyticalUtilization_Document__c = base.AnalyticalUtilization_Document__c,
            AnalyticalUtilization__c = base.AnalyticalUtilization__c,
            AppliedDomain__c = base.AppliedDomain__c,
            ApprovalCompleteNumber__c = base.ApprovalCompleteNumber__c,
            ApprovalNumber__c = base.ApprovalNumber__c,
            ApprovalRequestDate__c = base.ApprovalRequestDate__c,
            AsmpRegiShareML__c = base.AsmpRegiShareML__c,
            AssumGTVPerMonth__c = base.AssumGTVPerMonth__c,
            AssumPaymentPerMonth__c = base.AssumPaymentPerMonth__c,
            AssumePremiumCostBurden__c = base.AssumePremiumCostBurden__c,
            AssumedReturnAgu__c = base.AssumedReturnAgu__c,
            AssumedReturnMode__c = base.AssumedReturnMode__c,
            AssumedReturnRisk__c = base.AssumedReturnRisk__c,
            AvgCustUnitPrice__c = base.AvgCustUnitPrice__c,
            BenefitsCategory__c = base.BenefitsCategory__c,
            BenefitsCost__c = base.BenefitsCost__c,
            BenefitsPrice__c = base.BenefitsPrice__c,
            BenefitsType__c = base.BenefitsType__c,
            BillingAccountType__c = base.BillingAccountType__c,
            BillingBuildingNumber__c = base.BillingBuildingNumber__c,
            BillingCity__c = base.BillingCity__c,
            BillingManagerDepartment__c = base.BillingManagerDepartment__c,
            BillingManagerMail__c = base.BillingManagerMail__c,
            BillingManagerName__c = base.BillingManagerName__c,
            BillingMethodRelative__c = base.BillingMethodRelative__c,
            BillingMethod__c = base.BillingMethod__c,
            BillingName__c = base.BillingName__c,
            BillingPrefectures__c = base.BillingPrefectures__c,
            BillingZipCode__c = base.BillingZipCode__c,
            BoxHopeUse__c = base.BoxHopeUse__c,
            BoxURL__c = base.BoxURL__c,
            BoxUserEmail__c = base.BoxUserEmail__c,
            BudgetTotal__c = base.BudgetTotal__c,
            CBGrantRate__c = base.CBGrantRate__c,
            CPAgreement__c = base.CPAgreement__c,
            CPPFFeeStandard__c = base.CPPFFeeStandard__c,
            CPPFFee__c = base.CPPFFee__c,
            CPParticipationPattern__c = base.CPParticipationPattern__c,
            CampaignDesign__c = base.CampaignDesign__c,
            CampaignOperatingExpenses__c = base.CampaignOperatingExpenses__c,
            CampaignParticipationFee__c = base.CampaignParticipationFee__c,
            CampaignType__c = base.CampaignType__c,
            CannibalizationRate__c = base.CannibalizationRate__c,
            CapitalBurden__c = base.CapitalBurden__c,
            CheckSales__c = base.CheckSales__c,
            ClientSiteNumber__c = base.ClientSiteNumber__c,
            CollectedInvoiceInfoSheetURL__c = base.CollectedInvoiceInfoSheetURL__c,
            CommissionRate__c = base.CommissionRate__c,
            //CompanyID__c = companyId, // 数値変換した値を登録
            CompanyURL__c = base.CompanyURL__c,
            CompetitionFlg__c = base.CompetitionFlg__c,
            ConfirmInstallationNum__c = base.ConfirmInstallationNum__c,
            ConfirmInstallation__c = base.ConfirmInstallation__c,
            ConfirmMID__c = base.ConfirmMID__c,
            ContractBuildingNumber__c = base.ContractBuildingNumber__c,
            ContractCity__c = base.ContractCity__c,
            ContractEndDate__c = base.ContractEndDate__c,
            ContractOppNo__c = base.ContractOppNo__c,
            ContractPrefectures__c = base.ContractPrefectures__c,
            ContractProposalDraft__c = base.ContractProposalDraft__c,
            ContractStartDate__c = base.ContractStartDate__c,
            ContractStorageNo__c = base.ContractStorageNo__c,
            ContractStreetNumber__c = base.ContractStreetNumber__c,
            ContractType__c = base.ContractType__c,
            CorporateName__c = base.CorporateName__c,
            CostCoverdBy__c = base.CostCoverdBy__c,
            CostSideTask__c = base.CostSideTask__c,
            CouponConditionsLowAmount__c = base.CouponConditionsLowAmount__c,
            CouponId__c = base.CouponId__c,
            CouponInitialCost__c = base.CouponInitialCost__c,
            CouponMonthlyCost__c = base.CouponMonthlyCost__c,
            CouponPublishStart__c = base.CouponPublishStart__c,
            CouponSuggestionPattern__c = base.CouponSuggestionPattern__c,
            CouponUsagePeriodDays__c = base.CouponUsagePeriodDays__c,
            CouponUsagePeriodEndDate__c = base.CouponUsagePeriodEndDate__c,
            CouponUseCountLimit__c = base.CouponUseCountLimit__c,
            CoveringRateOfCost__c = base.CoveringRateOfCost__c,
            CurrentPointUseRate__c = base.CurrentPointUseRate__c,
            DailyTxPredictedValue__c = base.DailyTxPredictedValue__c,
            Dashboard__c = base.Dashboard__c,
            DeadlineDay__c = base.DeadlineDay__c,
            DevStartDate__c = base.DevStartDate__c,
            DevSupAuto__c = base.DevSupAuto__c,
            DevSup_SalesReport__c = base.DevSup_SalesReport__c,
            DevSupportSlackInformed__c = base.DevSupportSlackInformed__c,
            DocumentApprovalStatus__c = base.DocumentApprovalStatus__c,
            DraftSheetStorageURL__c = base.DraftSheetStorageURL__c,
            DuplicateGrants__c = base.DuplicateGrants__c,
            EconomicConditionHold__c = base.EconomicConditionHold__c,
            EndDate__c = base.EndDate__c,
            FeeBilling__c = base.FeeBilling__c,
            FeeFixedLastTime__c = base.FeeFixedLastTime__c,
            FeeFixed__c = base.FeeFixed__c,
            FeeInvoiceIssuanceDate__c = base.FeeInvoiceIssuanceDate__c,
            FeePercentLastTime__c = base.FeePercentLastTime__c,
            FeePercent__c = base.FeePercent__c,
            FeeTariff__c = base.FeeTariff__c,
            FlyerFee__c = base.FlyerFee__c,
            FocusServiceType__c = base.FocusServiceType__c,
            FolderURL__c = base.FolderURL__c,
            FrequencyOfUseDetail__c = base.FrequencyOfUseDetail__c,
            FrequencyOfUseType__c = base.FrequencyOfUseType__c,
            FunctionalAspectTask__c = base.FunctionalAspectTask__c,
            GMApprovalComment__c = base.GMApprovalComment__c,
            GMApprovalDate__c = base.GMApprovalDate__c,
            GMVAgu__c = base.GMVAgu__c,
            GMVMode__c = base.GMVMode__c,
            GMVRisk__c = base.GMVRisk__c,
            GWCompany__c = base.GWCompany__c,
            GeneralMtgComment__c = base.GeneralMtgComment__c,
            GeneralMtgDay__c = base.GeneralMtgDay__c,
            GiftCostPAYGRate__c = base.GiftCostPAYGRate__c,
            GiftImageStorage__c = base.GiftImageStorage__c,
            GlantLimitPeriod__c = base.GlantLimitPeriod__c,
            GlantLimitTimes__c = base.GlantLimitTimes__c,
            GrantAmount__c = base.GrantAmount__c,
            GrantBalanceType__c = base.GrantBalanceType__c,
            GrantRate__c = base.GrantRate__c,
            GrantingPointsMethod__c = base.GrantingPointsMethod__c,
            GuidelineRate__c = base.GuidelineRate__c,
            HopeInstallationNum__c = base.HopeInstallationNum__c,
            HopeInstallation__c = base.HopeInstallation__c,
            HopeMID__c = base.HopeMID__c,
            ImplementCP__c = base.ImplementCP__c,
            ImplementCost__c = base.ImplementCost__c,
            ImplementFinishedPoint__c = base.ImplementFinishedPoint__c,
            ImplementPurposes__c = base.ImplementPurposes__c,
            InclusiveName__c = base.InclusiveName__c,
            Industryclass__c = base.Industryclass__c,
            InsertedFlyerAnnouncement__c = base.InsertedFlyerAnnouncement__c,
            InstallationName__c = base.InstallationName__c,
            IntegrationPerson__c = base.IntegrationPerson__c,
            IntegrationTeamMemo__c = base.IntegrationTeamMemo__c,
            Integration_Status__c = base.Integration_Status__c,
            Introductionstores__c = base.Introductionstores__c,
            InviteBox__c = base.InviteBox__c,
            InvoiceMemo__c = base.InvoiceMemo__c,
            InvolvedSalesFee__c = base.InvolvedSalesFee__c,
            IrregularApprovalNumber__c = base.IrregularApprovalNumber__c,
            IrregularContract__c = base.IrregularContract__c,
            IsChangeRecordType__c = base.IsChangeRecordType__c,
            IsDevSupAutoChecked__c = base.IsDevSupAutoChecked__c,
            IsInvalidValidationRule__c = base.IsInvalidValidationRule__c,
            IsPLCIncludeInsideBuilding__c = base.IsPLCIncludeInsideBuilding__c,
            LPLogoURL__c = base.LPLogoURL__c,
            LPPublishCategory__c = base.LPPublishCategory__c,
            LaunchDate__c = base.LaunchDate__c,
            LaunchScheduledDate__c = base.LaunchScheduledDate__c,
            LeftStamps__c = base.LeftStamps__c,
            LightPlanExpirationDate__c = base.LightPlanExpirationDate__c,
            LightPlanStartDate__c = base.LightPlanStartDate__c,
            LogoURL__c = base.LogoURL__c,
            MID__c = base.MID__c,
            MailNewsletterDelivery__c = base.MailNewsletterDelivery__c,
            MainMID__c = base.MainMID__c,
            MakerDepreciationRate__c = base.MakerDepreciationRate__c,
            MakerFundingAmount__c = base.MakerFundingAmount__c,
            ManagementMeetingProposal__c = base.ManagementMeetingProposal__c,
            ManagerApprovalComment__c = base.ManagerApprovalComment__c,
            ManagerApprovalDate__c = base.ManagerApprovalDate__c,
            MarketingPerson__c = base.MarketingPerson__c,
            MaxBonusGrantAmountPerPay__c = base.MaxBonusGrantAmountPerPay__c,
            MaxBonusGrantAmountPerUserPLC__c = base.MaxBonusGrantAmountPerUserPLC__c,
            MaxCoveringOfCost__c = base.MaxCoveringOfCost__c,
            Memo__c = base.Memo__c,
            MerchantBurden__c = base.MerchantBurden__c,
            MerchantContractType__c = base.MerchantContractType__c,
            MerchantDepreciationRate__c = base.MerchantDepreciationRate__c,
            MerchantGetPerson__c = base.MerchantGetPerson__c,
            MerchantGetTask__c = base.MerchantGetTask__c,
            MerchantMID__c = base.MerchantMID__c,
            MethodUsagePeriodSetting__c = base.MethodUsagePeriodSetting__c,
            MgmtMtgDay__c = base.MgmtMtgDay__c,
            MinPaymentAmount__c = base.MinPaymentAmount__c,
            MultiMID__c = base.MultiMID__c,
            MultiMIDorSingleMID__c = base.MultiMIDorSingleMID__c,
            MyStoreKind__c = base.MyStoreKind__c,
            NDA__c = base.NDA__c,
            NextActionText__c = base.NextActionText__c,
            NextOppDate__c = base.NextOppDate__c,
            NumOfTargetMid__c = base.NumOfTargetMid__c,
            NumberOfSlots__c = base.NumberOfSlots__c,
            NumberOfStoreId__c = base.NumberOfStoreId__c,
            Numberofstores__c = base.Numberofstores__c,
            OnOff__c = base.OnOff__c,
            OnboardingTask__c = base.OnboardingTask__c,
            OneyearPointExchangeAmount__c = base.OneyearPointExchangeAmount__c,
            OneyearPointIssueAmount__c = base.OneyearPointIssueAmount__c,
            OneyearScheduledGrantAmount__c = base.OneyearScheduledGrantAmount__c,
            OppStatus__c = base.OppStatus__c,
            OpportunityLineItemId__c = base.OpportunityLineItemId__c,
            OriginalContractPeriod__c = base.OriginalContractPeriod__c,
            OtherTask__c = base.OtherTask__c,
            OtherTask_freeText__c = base.OtherTask_freeText__c,
            OutsystemsApprovalNumber__c = base.OutsystemsApprovalNumber__c,
            Overview__c = base.Overview__c,
            OwnedMediaExposure__c = base.OwnedMediaExposure__c,
            PLCFeeFixedLastTime__c = base.PLCFeeFixedLastTime__c,
            PLCFeeFixed__c = base.PLCFeeFixed__c,
            PLCFeeLastTime__c = base.PLCFeeLastTime__c,
            PLCFee__c = base.PLCFee__c,
            POSVendor__c = base.POSVendor__c,
            PastImplementationsNumber__c = base.PastImplementationsNumber__c,
            PastSituation__c = base.PastSituation__c,
            PayPayFundingAmount__c = base.PayPayFundingAmount__c,
            PayingMethod__c = base.PayingMethod__c,
            PaymentFee__c = base.PaymentFee__c,
            PaymentSite__c = base.PaymentSite__c,
            PointRate__c = base.PointRate__c,
            Point_URL__c = base.Point_URL__c,
            PostedOnDashboard__c = base.PostedOnDashboard__c,
            PosterInstallation__c = base.PosterInstallation__c,
            ProdAPIKey__c = base.ProdAPIKey__c,
            ProgressStatus__c = base.ProgressStatus__c,
            RelativeAdjustment__c = base.RelativeAdjustment__c,
            RepresentativeName__c = base.RepresentativeName__c,
            ReproductionFlg__c = base.ReproductionFlg__c,
            ReproductionReason__c = base.ReproductionReason__c,
            RequiredDocSubmitDate__c = base.RequiredDocSubmitDate__c,
            ReturnVisitCouponFeePercent__c = base.ReturnVisitCouponFeePercent__c,
            RevisitCouponFeeFixed__c = base.RevisitCouponFeeFixed__c,
            SIDListStorageURL__c = base.SIDListStorageURL__c,
            SLA_SpecialNote__c = base.SLA_SpecialNote__c,
            SLA_Type__c = base.SLA_Type__c,
            SalesChannels__c = base.SalesChannels__c,
            SalesDepartment__c = base.SalesDepartment__c,
            SalesDepth__c = base.SalesDepth__c,
            SalesForecast__c = base.SalesForecast__c,
            SalesInvolved__c = base.SalesInvolved__c,
            SalesMgmtPromoMtgDate__c = base.SalesMgmtPromoMtgDate__c,
            SalesStatus_1__c = base.SalesStatus_1__c,
            SeasonallyCoupon__c = base.SeasonallyCoupon__c,
            SettlementUpperLimit__c = base.SettlementUpperLimit__c,
            ShipmentSales__c = base.ShipmentSales__c,
            ShippingDisplayStorePercent__c = base.ShippingDisplayStorePercent__c,
            SidCount__c = base.SidCount__c,
            SnsAnnouncement__c = base.SnsAnnouncement__c,
            SpecialOfferDetails__c = base.SpecialOfferDetails__c,
            SpecialOffer__c = base.SpecialOffer__c,
            StampCardId__c = base.StampCardId__c,
            StampConditionalSum__c = base.StampConditionalSum__c,
            StampsPerDayNumber__c = base.StampsPerDayNumber__c,
            StampsPerDay__c = base.StampsPerDay__c,
            StartDate__c = base.StartDate__c,
            StateTask__c = base.StateTask__c,
            Status__c = base.Status__c,
            StorePromotionalKit__c = base.StorePromotionalKit__c,
            SuppliersInfoLink__c = base.SuppliersInfoLink__c,
            SystemMaintenanceEmail__c = base.SystemMaintenanceEmail__c,
            SystemMaintenancePerson__c = base.SystemMaintenancePerson__c,
            SystemNda__c = base.SystemNda__c,
            TVCM__c = base.TVCM__c,
            TargetProduct__c = base.TargetProduct__c,
            TargetSegment__c = base.TargetSegment__c,
            Target_Service_AnnualSales__c = base.Target_Service_AnnualSales__c,
            TestCandidate__c = base.TestCandidate__c,
            TestInstallation__c = base.TestInstallation__c,
            TestLaunchDateEnd__c = base.TestLaunchDateEnd__c,
            TestLaunchDateStart__c = base.TestLaunchDateStart__c,
            Test_Memo__c = base.Test_Memo__c,
            TopOpp__c = base.TopOpp__c,
            TotalNumCouponImplemented__c = base.TotalNumCouponImplemented__c,
            TotalStamps__c = base.TotalStamps__c,
            UmbrellaAgency__c = base.UmbrellaAgency__c,
            WEBCM__c = base.WEBCM__c,
            WayToConnect__c = base.WayToConnect__c,
            WayToGiveStamps__c = base.WayToGiveStamps__c,
            Yomi__c = base.Yomi__c,
            mpMerchant__c = base.mpMerchant__c,
            mpOpportunityRelatedFlg__c = base.mpOpportunityRelatedFlg__c,
            Industryclassification__c = base.Industryclassification__c,
            NewIndustryclass__c = base.NewIndustryclass__c,
            IsDataPolicyConfirm__c = base.IsDataPolicyConfirm__c,
            ConsortiumMemoURL__c = base.ConsortiumMemoURL__c,
            POSLinkageMID__c = base.POSLinkageMID__c,
            DataPolicyTask__c = base.DataPolicyTask__c,
            POSLinkageTask__c = base.POSLinkageTask__c,
            IsConsortiumParticipation__c = base.IsConsortiumParticipation__c,
            IsPOSDevelopCost__c = base.IsPOSDevelopCost__c,
            MainDealMaker__c = base.MainDealMaker__c,
            POSDevelopBurdenEstCost__c = base.POSDevelopBurdenEstCost__c,
            TargetProductName__c = base.TargetProductName__c,
            POSDevelopCostPP__c = base.POSDevelopCostPP__c,
            POSDevelopCostClient__c = base.POSDevelopCostClient__c,
            ContractURL__c = base.ContractURL__c,
            CampaignOverview__c = base.CampaignOverview__c,
            RequestRetailName__c = base.RequestRetailName__c,
            ProductTask__c = base.ProductTask__c,
            ProposalURL__c = base.ProposalURL__c,
            InformationForYJ__c = base.InformationForYJ__c,
            WantToApplyAds__c = base.WantToApplyAds__c,
            PlanOfAds__c = base.PlanOfAds__c,
            AdsAmount__c = base.AdsAmount__c,
            AdsStartDate__c = base.AdsStartDate__c,
            AdsEndDate__c = base.AdsEndDate__c,
            EstimatedAmountIssuedPoint__c = base.EstimatedAmountIssuedPoint__c,
            CommissionRateIssuedPoint__c = base.CommissionRateIssuedPoint__c,
            PlatformCost__c = base.PlatformCost__c,
            AdsRevenueShare__c = base.AdsRevenueShare__c,
            AdsRevenueShareAgencyFee__c = base.AdsRevenueShareAgencyFee__c,
            RecordOfResultsPerson__c = base.RecordOfResultsPerson__c,
            RecordOfResultsMonth__c = base.RecordOfResultsMonth__c,
            IsJANConnect__c = base.IsJANConnect__c,
            FeeIncomeManual__c = base.FeeIncomeManual__c,
            LostAmountSPTariff__c = base.LostAmountSPTariff__c,
            ApprovalName__c = base.ApprovalName__c,
            ApproveDate__c = base.ApproveDate__c,
            BannerPublicationStart__c = base.BannerPublicationStart__c,
            BudgetTokenCharge__c = base.BudgetTokenCharge__c,
            EndDateTime__c = base.EndDateTime__c,
            FreeFeeEndDate__c = base.FreeFeeEndDate__c,
            IneligibleSID_MSID__c = base.IneligibleSID_MSID__c,
            IsLimitedGrant__c = base.IsLimitedGrant__c,
            LpUrl__c = base.LpUrl__c,
            NotificationDate__c = base.NotificationDate__c,
            PointCondition__c = base.PointCondition__c,
            RequiredPromotionTool__c = base.RequiredPromotionTool__c,
            StartDateTime__c = base.StartDateTime__c,
            TobaccoExclusion__c = base.TobaccoExclusion__c,
            AdsImplementation__c = base.AdsImplementation__c,
            ContactNumber__c = base.ContactNumber__c,
            ExpectedEffect__c = base.ExpectedEffect__c,
            ExpectedEffect_freeText__c = base.ExpectedEffect_freeText__c,
            FBDocumentURL__c = base.FBDocumentURL__c,
            GWMerchantConnectionTestDate__c = base.GWMerchantConnectionTestDate__c,
            GWMerchantConnectionTestScheduleDate__c = base.GWMerchantConnectionTestScheduleDate__c,
            KPIFeedback__c = base.KPIFeedback__c,
            KPINumericalResult__c = base.KPINumericalResult__c,
            NextKPI__c = base.NextKPI__c,
            NextKPIResult__c = base.NextKPIResult__c,
            ReferralAgencyName__c = base.ReferralAgencyName__c,
            AgencyOrSecretariat__c = base.AgencyOrSecretariat__c,
            ActionPoint_TargetOrNot__c = base.ActionPoint_TargetOrNot__c,
            BillingMeans__c = base.BillingMeans__c,
            OtherBillingMeans__c = base.OtherBillingMeans__c,
            NextactionContactDate__c = base.NextactionContactDate__c,
            NextactionMain__c = base.NextactionMain__c,
            NextactionPartner__c = base.NextactionPartner__c,
            NextactionContent__c = base.NextactionContent__c,
            LastNegotiationsDate__c = base.LastNegotiationsDate__c,
            NegotiationPartnerPositionLayer__c = base.NegotiationPartnerPositionLayer__c,
            IsTransactionOnlyTestType__c = base.IsTransactionOnlyTestType__c,
            TargetBrandName__c = base.TargetBrandName__c,
            LYPMileageOverview__c = base.LYPMileageOverview__c,
            GiftcardIssuingTiming__c = base.GiftcardIssuingTiming__c,
            GiftcardDistributionDate__c = base.GiftcardDistributionDate__c,
            NumOfIissues__c = base.NumOfIissues__c,
            IssueAmount__c = base.IssueAmount__c,
            FeeStd__c = base.FeeStd__c,
            FeeFixedStd__c = base.FeeFixedStd__c,
            EconConditionSPTariff__c = base.EconConditionSPTariff__c,
            OutsystemsCreditApprovalNumber__c = base.OutsystemsCreditApprovalNumber__c,
            IssuingMethod__c = base.IssuingMethod__c,
            CampaignToken__c = opIdCampaignTokenMap.get(base.Id)// 一致するKeyがある場合対応するvalue、ない場合null
        ); 
    }

    /**
     * サービス管理(決済事業)を参照する他オブジェクトに、対応するサービス管理(加盟店事業)を参照させる
     * @param objList 更新対象のサービス管理 or 加盟店 or アタックリスト or 案件 or 申込書管理 or サービス申込のレコードのリスト
     * @param objectType オブジェクトの型。どのレコードの更新処理に失敗したケースかを判別する
     */
    private void updateRelatedRecords(List<sObject> objList, String objectType) {
        Logger logger = new Logger();
        if (objList.isEmpty()) {
            logger.info(BATCH_LOG_TITLE + ' 更新', '更新対象のリストが空でした: ' + objectType, false).saveAll();
            return;
        }

        Savepoint sp = Database.setSavepoint(); // 1オブジェクト毎ロールバックする
        try {
            throwException(objectType);
            update objList;
            logger.info(BATCH_LOG_TITLE + ' 更新', '更新オブジェクト:' + objectType + '\n更新件数:' + objList.size(), false).saveAll();
        }
        catch (Exception ex) {
            Database.rollback(sp);
            logger.error(BATCH_LOG_TITLE + COND_UPDATERELATED_RECORDS, '更新オブジェクト:' + objectType + '\n' + logger.formatErrorMessage(ex), false).saveAll();
            hasDontUpdateObj = true; // 更新できないオブジェクトが含まれていた場合、Trueにする
        }
    }

    /**
     * テストカバー率向上のため、テスト時のみ例外を発生させる
     * @param objectType エラーの原因となったオブジェクト
     */
    private void throwException(String objectType) {
        if (objectType.equals(errorType) && Test.isRunningTest() && isDMLExceptionTest) {
            throw new MyException(objectType + 'テスト実行時エラー');
        }
    }

    /**
     * バッチ終了
     * @param BC 一括処理ジョブ
     */
    global void finish(Database.BatchableContext BC) {
        Logger logger = new Logger();
        if (this.hasException || bResult.hasError || hasDontUpdateObj) {
            String errorLog = bResult.toString();
            if (hasDontUpdateObj) {
                errorLog += '\n更新できなかったオブジェクトあり';
            }
            logger.error(BATCH_LOG_TITLE + ' 完了', errorLog, false).saveAll();
        }
        else {
            logger.info(BATCH_LOG_TITLE+ ' 完了', bResult.toString(), false).saveAll();
        }
    }
}