/**
* クラス名: CRMDPMigrationOPMBModBatchTest
* クラス概要: サービス管理オブジェクト分割 サービス管理データ移行バッチテスト
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/07
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class CRMDPMigrationOPMBModBatchTest {

    @TestSetup
    static void setup() {
        // サービス管理のレコードタイプID
        Id RECORDTYPE_LYPMILEAGE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'LYPMileage'); // LYPマイレージ
        Id RECORDTYPE_PAAS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PaaSRecordType'); // PaaS
        Id RECORDTYPE_POINT = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PCRecordType'); // PayPayポイント
        Id RECORDTYPE_OFF_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PLCRecordType'); // オフライン_PLC
        Id RECORDTYPE_ON_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'OnlinePLCRecordType'); // オンライン_PLC
        Id RECORDTYPE_GIFTCARD = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Giftcard'); // ギフトカード
        Id RECORDTYPE_CAMPAIGN = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Campaign'); // キャンペーン
        Id RECORDTYPE_STAMPCARD = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'SCRecordType'); // スタンプカード
        Id RECORDTYPE_FLYER_APPLY = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'FlyerApply'); // チラシ_申込
        Id RECORDTYPE_MYSTORE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PayEnterprise_mystore'); // マイストア
        Id RECORDTYPE_MINIAPP = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'MiniAppRecordType'); // ミニアプリ
        Id RECORDTYPE_RETAILGIFT = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RetailGift'); // リテールギフト
        Id RECORDTYPE_ROUTEOPENING = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RouteOpening'); // ルート開通
        Id RECORDTYPE_REVISITINGCOUPON = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RevisitingCoupon'); // 再来店クーポン
        Id RECORDTYPE_SCHEDULEDCOUPON = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'ScheduledCoupon'); // 日時指定クーポン
        Id RECORDTYPE_BALANCEAPI = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'BalanceAPI'); // 残高API
        Id RECORDTYPE_SPECIFICPRODUCTCOUPON = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'SpecificProductCoupon'); // 商品特定クーポン

        // PayPayアタックリストのレコードタイプID
        Id RECORDTYPE_MPOPPORTUNITY = mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, 'mpList'); // mpアタックリスト

        // PayPay申込書管理のレコードタイプID
        Id RECORDTYPE_APPFORM = mpUtilString.getRecordTypeByDeveloperName(ApplicationForm__c.sObjectType, 'JumboCampaign'); // ジャンボキャンペーン

        // サービス申込のレコードタイプID
        Id RECORDTYPE_SERVICEORDER = mpUtilString.getRecordTypeByDeveloperName(ServiceOrder__c.sObjectType, 'OfflinePLC'); // オフライン_PLC

        // サービス管理アクションのレコードタイプID
        Id RECORDTYPE_ORDERPROGRESSACTIONCHECK = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'PLCRecordType_Action'); // オフライン_PLC（アクションチェック/再現）
        Id RECORDTYPE_ACTIONCHECK_POINT_ACT = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'PCRecordType_Action'); // PayPayポイント（アクションチェック/再現）
        Id RECORDTYPE_ORDERPROGRESSACTIONCHECKTOOL = mpUtilString.getRecordTypeByDeveloperName(OrderProgressActionCheck__c.sObjectType, 'PLCRecordType_Tool_SalesPromotion'); // オフライン_PLC（ツール/販促）

        // 取引先作成
        Account acc = TestDataFactory.createAccount('サービス管理データ移行_サービス管理（加盟店事業）作成バッチテスト企業', true);
        // 案件作成
        Opportunity opp = TestDataFactory.createOpportunity('サービス管理データ移行_サービス管理（加盟店事業）作成バッチテスト企業', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, true);
        // サービス管理（決済事業）作成
        OrderProgress__c order1 = TestDataFactory.createOrderProgress('データ移行バッチ_LYPマイレージ', acc.Id, opp.Id, RECORDTYPE_LYPMILEAGE, false);
        OrderProgress__c order2 = TestDataFactory.createOrderProgress('データ移行バッチ_PaaS', acc.Id, opp.Id, RECORDTYPE_PAAS, false);
        OrderProgress__c order3 = TestDataFactory.createOrderProgress('データ移行バッチ_PayPayポイント', acc.Id, opp.Id, RECORDTYPE_POINT, false);
        OrderProgress__c order4 = TestDataFactory.createOrderProgress('データ移行バッチ_オフラインPLC', acc.Id, opp.Id, RECORDTYPE_OFF_PLC, false);
        OrderProgress__c order5 = TestDataFactory.createOrderProgress('データ移行バッチ_オンラインPLC', acc.Id, opp.Id, RECORDTYPE_ON_PLC, false);
        OrderProgress__c order6 = TestDataFactory.createOrderProgress('データ移行バッチ_ギフトカード', acc.Id, opp.Id, RECORDTYPE_GIFTCARD, false);
        OrderProgress__c order7 = TestDataFactory.createOrderProgress('データ移行バッチ_キャンペーン', acc.Id, opp.Id, RECORDTYPE_CAMPAIGN, false);
        OrderProgress__c order8 = TestDataFactory.createOrderProgress('データ移行バッチ_スタンプカード', acc.Id, opp.Id, RECORDTYPE_STAMPCARD, false);
        OrderProgress__c order9 = TestDataFactory.createOrderProgress('データ移行バッチ_チラシ申込', acc.Id, opp.Id, RECORDTYPE_FLYER_APPLY, false);
        OrderProgress__c order10 = TestDataFactory.createOrderProgress('データ移行バッチ_マイストア', acc.Id, opp.Id, RECORDTYPE_MYSTORE, false);
        OrderProgress__c order11 = TestDataFactory.createOrderProgress('データ移行バッチ_ミニアプリ', acc.Id, opp.Id, RECORDTYPE_MINIAPP, false);
        OrderProgress__c order12 = TestDataFactory.createOrderProgress('データ移行バッチ_リテールギフト', acc.Id, opp.Id, RECORDTYPE_RETAILGIFT, false);
        OrderProgress__c order13 = TestDataFactory.createOrderProgress('データ移行バッチ_ルート開通', acc.Id, opp.Id, RECORDTYPE_ROUTEOPENING, false);
        OrderProgress__c order14 = TestDataFactory.createOrderProgress('データ移行バッチ_再来店クーポン', acc.Id, opp.Id, RECORDTYPE_REVISITINGCOUPON, false);
        OrderProgress__c order15 = TestDataFactory.createOrderProgress('データ移行バッチ_日時指定クーポン', acc.Id, opp.Id, RECORDTYPE_SCHEDULEDCOUPON, false);
        OrderProgress__c order16 = TestDataFactory.createOrderProgress('データ移行バッチ_残高API', acc.Id, opp.Id, RECORDTYPE_BALANCEAPI, false);
        OrderProgress__c order17 = TestDataFactory.createOrderProgress('データ移行バッチ_商品特定クーポン', acc.Id, opp.Id, RECORDTYPE_SPECIFICPRODUCTCOUPON, false);
        OrderProgress__c order18 = TestDataFactory.createOrderProgress('データ移行バッチ_取引先IDエラー', acc.Id, opp.Id, RECORDTYPE_SPECIFICPRODUCTCOUPON, false);
        order7.MultiMID__c = '123456789012345678';
        insert new List<OrderProgress__c>{order1, order2, order3, order4, order5, order6, order7, order8, order9, order10, order11, order12, order13, order14, order15, order16, order17, order18};

        // PayPayアタックリスト作成
        mpOpportunity__c mpopp = TestDataFactory.createMpOpportunity('データ移行バッチ_参照元アタックリスト', RECORDTYPE_MPOPPORTUNITY, false);
        mpopp.OrderProgressId__c = order7.Id;
        insert mpopp;

        // PayPay加盟店作成
        mpMerchant__c  mpMerchant = TestDataFactory.createMpMerchant('データ移行バッチ_参照元PayPay加盟店', '123456789012345678', false);
        mpMerchant.mpOpportunity__c = mpopp.Id;
        mpMerchant.OrderProgressId__c = order7.Id;
        insert mpMerchant;

        // PayPay申込書管理作成
        ApplicationForm__c appForm = TestDataFactory.createApplicationForm(RECORDTYPE_APPFORM, false);
        appForm.OrderProgressId__c = order7.Id;
        insert appForm;

        // サービス管理アクション作成(アクション)
        OrderProgressActionCheck__c opActionCheck = TestDataFactory.createOrderProgressActionCheck('データ移行バッチ_参照元サービス管理アクション', null, null, RECORDTYPE_ORDERPROGRESSACTIONCHECK, false);
        opActionCheck.OrderProgress_Action__c = order4.Id;
        OrderProgressActionCheck__c opActionCheck2 = TestDataFactory.createOrderProgressActionCheck('データ移行バッチ_参照元サービス管理アクション_CP', null, null, RECORDTYPE_ACTIONCHECK_POINT_ACT, false);
        opActionCheck2.OrderProgress_Action__c = order7.Id;
        opActionCheck2.CampaignToken__c = 'pointTestToken';
        // サービス管理アクション作成(ツール)
        OrderProgressActionCheck__c opActionCheckTool = TestDataFactory.createOrderProgressActionCheck('データ移行バッチ_参照元サービス管理アクション（ツール）', null, null, RECORDTYPE_ORDERPROGRESSACTIONCHECKTOOL, false);
        opActionCheckTool.OrderProgress_Tool_SalesPromotion__c = order4.Id;
        insert new List<OrderProgressActionCheck__c>{opActionCheck, opActionCheck2, opActionCheckTool};

        // サービス申込作成
        ServiceOrder__c so = TestDataFactory.createServiceOrder(RECORDTYPE_SERVICEORDER, false);
        so.OrderProgress__c = order7.Id;
        insert so;
    }

    @isTest
    private static void test_MigrationOPMBModBatch_success() {
        Test.startTest();
        CRMDPMigrationOPMBModBatch.run();
        Test.stopTest();
        Map<Id, OrderProgress__c> baseOPMap = new Map<Id, OrderProgress__c>([
            SELECT Id, Name, OrderProgressMB__c, OrderProgressMB__r.Id, OrderProgressMB__r.Name FROM OrderProgress__c]);
        Map<Id, OrderProgressMB__c> baseOPMBMap = new Map<Id, OrderProgressMB__c>([
            SELECT Id, Name, OrderProgress__c, MyStoreRelation__c, ReferenceSetting__c, CouponRelation__c, CopyOrderProgressId__c
            FROM OrderProgressMB__c
            WHERE OrderProgress__c = : baseOPMap.keySet()
        ]);
        // バッチ実行で作成されるサービス管理（加盟店事業）のレコード = 18
        System.assertEquals(18, baseOPMBMap.size(), '作成される加盟店事業レコード数が期待値と異なる');

        // 他Objのサービス管理（加盟店事業）参照項目に値が設定されていることを確認
        // 参照先のサービス管理（加盟店事業）レコード
        OrderProgressMB__c tgt = [SELECT Id FROM OrderProgressMB__c WHERE Name = 'データ移行バッチ_キャンペーン'];

        // PayPayアタックリストの「サービス管理（加盟店事業）」項目の値が設定されていることを確認
        mpOpportunity__c mpopp_res = [
            SELECT id ,name, OrderProgressId__c, OrderProgressMBId__c
            FROM mpOpportunity__c 
            WHERE Name = 'データ移行バッチ_参照元アタックリスト'
        ];
        System.assertEquals(tgt.id, mpopp_res.OrderProgressMBId__c, '参照項目の設定が期待値と異なる[アタックリスト]');

        // PayPay加盟店の「サービス管理（加盟店事業）」項目の値が設定されていることを確認
        mpMerchant__c mpMer_res = [
            SELECT id ,name, OrderProgressMBId__c 
            FROM mpMerchant__c 
            WHERE Name = 'データ移行バッチ_参照元PayPay加盟店'
        ];
        System.assertEquals(tgt.id, mpMer_res.OrderProgressMBId__c, '参照項目の設定が期待値と異なる[PP加盟店]');

        // PayPay申込書管理の「サービス管理（加盟店事業）」項目の値が設定されていることを確認
        ApplicationForm__c appForm_res = [
            SELECT id ,name, OrderProgressMBId__c, OrderProgressId__c, OrderProgressId__r.Name
            FROM ApplicationForm__c 
            WHERE OrderProgressId__r.Name = :CRMDPMigrationOPMBModBatch.DELETE_NAME_LABEL + 'データ移行バッチ_キャンペーン'
        ];
        System.assertEquals(tgt.id, appForm_res.OrderProgressMBId__c, '参照項目の設定が期待値と異なる[申込書管理]');

        // サービス管理アクションの「[アクション]紐づくサービス管理名（加盟店事業）」項目の値が設定されていることを確認
        OrderProgressMB__c tgt2 = [SELECT Id FROM OrderProgressMB__c WHERE Name = 'データ移行バッチ_オフラインPLC'];
        OrderProgressActionCheck__c opActionCheck_res = [
            SELECT id ,name, OrderProgressMB_Action__c
            FROM OrderProgressActionCheck__c 
            WHERE Name = 'データ移行バッチ_参照元サービス管理アクション'
        ];
        System.assertEquals(tgt2.id, opActionCheck_res.OrderProgressMB_Action__c, '参照項目の設定が期待値と異なる[サービス管理アクション(action)]');

        // サービス管理アクションの「[ツール/販促]紐づくサービス管理名（加盟店事業）」項目の値が設定されていることを確認
        OrderProgressActionCheck__c opActionCheckTool_res = [
            SELECT id ,name, OrderProgressMB_Tool_SalesPromotion__c
            FROM OrderProgressActionCheck__c 
            WHERE Name = 'データ移行バッチ_参照元サービス管理アクション（ツール）'
        ];
        System.assertEquals(tgt2.id, opActionCheckTool_res.OrderProgressMB_Tool_SalesPromotion__c, '参照項目の設定が期待値と異なる[サービス管理アクション(tool)]');

        // サービス申込の「サービス管理（加盟店事業）」項目の値が設定されていることを確認
        ServiceOrder__c so_res = [
            SELECT id ,name, OrderProgress__c, OrderProgressMB__c
            FROM ServiceOrder__c 
            WHERE OrderProgress__r.Name = :CRMDPMigrationOPMBModBatch.DELETE_NAME_LABEL + 'データ移行バッチ_キャンペーン'
        ];
        System.assertEquals(tgt.id, so_res.OrderProgressMB__c, '参照項目の設定が期待値と異なる[サービス申込]');

        // サービス管理（決済事業）の「サービス管理（加盟店事業）」項目の値が設定されていることを確認
        for (OrderProgress__c op : baseOPMap.values()) {
            for (OrderProgressMB__c opmb : baseOPMBMap.values()) {
                if (op.Name.equals(CRMDPMigrationOPMBModBatch.DELETE_NAME_LABEL + opmb.Name)) {
                    System.assertEquals(opmb.Id, op.OrderProgressMB__c, '参照項目の設定が期待値と異なる[決済事業]');
                }
            }
        }

        // 成功時のログデータチェック
        String endLogFlg = CRMDPMigrationOPMBModBatch.BATCH_LOG_TITLE + ' 完了';
        List<Log__c> actualLogList = [
            SELECT Id, Title__c, Level__c, Detail__c
            FROM Log__c
            WHERE Level__c = 'INFO'
            AND Title__c = :endLogFlg
        ];
        System.assertEquals(1, actualLogList.size(), '成功時の完了ログが適切に作成されていない');
    }

    /**
     * サービス管理（加盟店事業）作成に失敗あり：企業ID変換エラー
     * setupで作成したレコード18で発生させる
     */
    /*@isTest
    private static void test_MigrationOPMBModBatch_failure0() {
        OrderProgress__c order18 = [SELECT Id FROM OrderProgress__c WHERE Name = 'データ移行バッチ_取引先IDエラー' LIMIT 1];
        order18.CompanyID__c = 'hoge';
        update order18;

        Test.startTest();
        CRMDPMigrationOPMBModBatch.run();
        Test.stopTest();

        Map<Id, OrderProgress__c> baseOPMap = new Map<Id, OrderProgress__c>([
            SELECT Id, Name, OrderProgressMB__c, OrderProgressMB__r.Id, OrderProgressMB__r.Name FROM OrderProgress__c]);
        List<OrderProgressMB__c> oPMBList = [
            SELECT Id, Name, OrderProgress__c, MyStoreRelation__c, ReferenceSetting__c, CouponRelation__c, CopyOrderProgressId__c
            FROM OrderProgressMB__c
            WHERE OrderProgress__c = : baseOPMap.keySet()
        ];
         // バッチ実行で作成されるサービス管理（加盟店事業）のレコード = 17
        System.assertEquals(17, oPMBList.size(), '作成される加盟店事業レコード数が期待値と異なります');

        String endLogFlg = CRMDPMigrationOPMBModBatch.BATCH_LOG_TITLE + ' 完了';
        List<Log__c> acctualLog = new List<Log__c>();
        boolean endLogErrorFlg = false;
        for (Log__c logData : [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPMigrationOPMBModBatch.BATCH_LOG_TITLE
            OR (Title__c = :endLogFlg AND Level__c = 'ERROR')]) {
            if (logData.Detail__c.contains('企業ID変換失敗レコード数: ') && acctualLog.isEmpty()) {
                acctualLog.add(logData);
            } 
            if (logData.Title__c.equals(endLogFlg)) {
                endLogErrorFlg = true;
            }
        }
        System.assertNotEquals(0, acctualLog.size(), '企業ID変換時のエラーログが作成されませんでした');
        System.assertEquals(true, acctualLog[0].Detail__c.contains(order18.Id), '企業ID変換時のエラーが期待と異なるレコードで発生しました');
        System.assertEquals(true, endLogErrorFlg, '完了時のログがERRORレベルで作成されませんでした');
    }*/

    /**
     * サービス管理（加盟店事業）作成に失敗
     */
    @isTest
    private static void test_MigrationOPMBModBatch_failure1() {
        Test.startTest();
        // DMLExceptionを発生するようにフラグを更新する
        CRMDPMigrationOPMBModBatch.isDMLExceptionTest = true;
        CRMDPMigrationOPMBModBatch.ErrorType = 'createOrderProgressMB';
        CRMDPMigrationOPMBModBatch.run();
        Test.stopTest();
        Map<Id, OrderProgress__c> baseOPMap = new Map<Id, OrderProgress__c>([
            SELECT Id, Name, OrderProgressMB__c, OrderProgressMB__r.Id, OrderProgressMB__r.Name FROM OrderProgress__c]);
        Map<Id, OrderProgressMB__c> baseOPMBMap = new Map<Id, OrderProgressMB__c>([
            SELECT Id, Name, OrderProgress__c, MyStoreRelation__c, ReferenceSetting__c, CouponRelation__c, CopyOrderProgressId__c
            FROM OrderProgressMB__c
            WHERE OrderProgress__c = : baseOPMap.keySet()
        ]);
        // バッチ実行で作成されるサービス管理（加盟店事業）のレコード = 0
        System.assertEquals(0, baseOPMBMap.size(), '作成される加盟店事業レコードが期待値と異なる');

        String log_title = CRMDPMigrationOPMBModBatch.BATCH_LOG_TITLE + CRMDPMigrationOPMBModBatch.COND_CREATE_ERROR;
        List<Log__c> actual_log = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :log_title
        ];

        // ログデータが作成されていることを確認する
        System.assertEquals(true, actual_log.size() > 0, 'ログ生成ができませんでした');
    }

    /**
     * サービス管理（決済事業）Objのサービス管理（加盟店事業）参照項目設定処理に失敗
     */
    @isTest
    private static void test_MigrationOPMBModBatch_failure2() {
        Test.startTest();
        // DMLExceptionを発生するようにフラグを更新する
        CRMDPMigrationOPMBModBatch.isDMLExceptionTest = true;
        CRMDPMigrationOPMBModBatch.ErrorType = 'OrderProgress__c';
        CRMDPMigrationOPMBModBatch.run();
        Test.stopTest();
        
        // サービス管理（決済事業）Objのサービス管理（加盟店事業）項目がNullであることを確認
        for (OrderProgress__c op : [SELECT Id, OrderProgressMB__c FROM OrderProgress__c]) {
            System.assertEquals(null, op.OrderProgressMB__c, 'サービス管理（決済事業）Objのサービス管理（加盟店事業）項目がNullでない');
        }

        String log_title = CRMDPMigrationOPMBModBatch.BATCH_LOG_TITLE + CRMDPMigrationOPMBModBatch.COND_UPDATERELATED_RECORDS + '_OrderProgress__c';
        List<Log__c> actual_log = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :log_title
            AND Level__c = 'ERROR'
        ];

        // ログデータが作成されていることを確認する
        System.assertEquals(true, actual_log.size() > 0, 'ログ生成ができませんでした');
    }

    /**
     * PayPayアタックリストObjのサービス管理（加盟店事業）参照項目設定処理に失敗
     */
    @isTest
    private static void test_MigrationOPMBModBatch_failure4() {
        Test.startTest();
        // DMLExceptionを発生するようにフラグを更新する
        CRMDPMigrationOPMBModBatch.isDMLExceptionTest = true;
        CRMDPMigrationOPMBModBatch.ErrorType = 'mpOpportunity__c';
        CRMDPMigrationOPMBModBatch.run();
        Test.stopTest();

        // PayPayアタックリストObjのサービス管理（加盟店事業）項目がNullであることを確認
        for (mpOpportunity__c mpOpp : [SELECT Id, OrderProgressMBId__c FROM mpOpportunity__c]) {
            System.assertEquals(null, mpOpp.OrderProgressMBId__c, 'PayPayアタックリストObjのサービス管理（加盟店事業）項目がNullでない');
        }

        String log_title = CRMDPMigrationOPMBModBatch.BATCH_LOG_TITLE + CRMDPMigrationOPMBModBatch.COND_UPDATERELATED_RECORDS;
        List<Log__c> actual_log = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :log_title
        ];

        // ログデータが作成されていることを確認する
        System.assertEquals(true, actual_log.size() > 0, 'ログ生成ができませんでした');
    }

    /**
     * PayPay加盟店Objのサービス管理（加盟店事業）参照項目設定処理に失敗
     */
    @isTest
    private static void test_MigrationOPMBModBatch_failure5() {
        Test.startTest();
        // DMLExceptionを発生するようにフラグを更新する
        CRMDPMigrationOPMBModBatch.isDMLExceptionTest = true;
        CRMDPMigrationOPMBModBatch.ErrorType = 'mpMerchant__c';
        CRMDPMigrationOPMBModBatch.run();
        Test.stopTest();

        // PayPay加盟店Objのサービス管理（加盟店事業）項目がNullであることを確認
        for (mpMerchant__c mpMer : [SELECT Id, OrderProgressMBId__c FROM mpMerchant__c]) {
            System.assertEquals(null, mpMer.OrderProgressMBId__c, 'PayPay加盟店Objのサービス管理（加盟店事業）項目がNullでない');
        }

        String log_title = CRMDPMigrationOPMBModBatch.BATCH_LOG_TITLE + CRMDPMigrationOPMBModBatch.COND_UPDATERELATED_RECORDS;
        List<Log__c> actual_log = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :log_title
        ];

        // ログデータが作成されていることを確認する
        System.assertEquals(true, actual_log.size() > 0, 'ログ生成ができませんでした');
    }

    /**
     * PayPay申込書管理Objのサービス管理（加盟店事業）参照項目設定処理に失敗
     */
    @isTest
    private static void test_MigrationOPMBModBatch_failure6() {
        Test.startTest();
        // DMLExceptionを発生するようにフラグを更新する
        CRMDPMigrationOPMBModBatch.isDMLExceptionTest = true;
        CRMDPMigrationOPMBModBatch.ErrorType = 'ApplicationForm__c';
        CRMDPMigrationOPMBModBatch.run();
        Test.stopTest();

        // PayPay申込書管理Objのサービス管理（加盟店事業）項目がNullであることを確認
        for (ApplicationForm__c appForm : [SELECT Id, OrderProgressMBId__c FROM ApplicationForm__c]) {
            System.assertEquals(null, appForm.OrderProgressMBId__c, 'PayPay申込書管理Objのサービス管理（加盟店事業）項目がNullでない');
        }

        String log_title = CRMDPMigrationOPMBModBatch.BATCH_LOG_TITLE + CRMDPMigrationOPMBModBatch.COND_UPDATERELATED_RECORDS;
        List<Log__c> actual_log = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :log_title
        ];

        // ログデータが作成されていることを確認する
        System.assertEquals(true, actual_log.size() > 0, 'ログ生成ができませんでした');
    }

    /**
     * サービス管理アクションObjのサービス管理（加盟店事業）参照項目設定処理に失敗
     */
    @isTest
    private static void test_MigrationOPMBModBatch_failure7() {
        Test.startTest();
        // DMLExceptionを発生するようにフラグを更新する
        CRMDPMigrationOPMBModBatch.isDMLExceptionTest = true;
        CRMDPMigrationOPMBModBatch.ErrorType = 'OrderProgressActionCheck__c';
        CRMDPMigrationOPMBModBatch.run();
        Test.stopTest();

        // サービス管理アクションチェックObjのサービス管理（加盟店事業）項目がNullであることを確認
        for (OrderProgressActionCheck__c opac : [SELECT Id, OrderProgressMB_Action__c, OrderProgressMB_Tool_SalesPromotion__c FROM OrderProgressActionCheck__c WHERE Name LIKE '%データ移行バッチ_参照元サービス管理アクション%']) {
            System.assertEquals(null, opac.OrderProgressMB_Action__c, 'サービス管理アクションチェックObjのサービス管理（加盟店事業）項目がNullでない1');
            System.assertEquals(null, opac.OrderProgressMB_Tool_SalesPromotion__c, 'サービス管理アクションチェックObjのサービス管理（加盟店事業）項目がNullでない2');
        }

        String log_title = CRMDPMigrationOPMBModBatch.BATCH_LOG_TITLE + CRMDPMigrationOPMBModBatch.COND_UPDATERELATED_RECORDS;
        List<Log__c> actual_log = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :log_title
        ];

        // ログデータが作成されていることを確認する
        System.assertEquals(true, actual_log.size() > 0, 'ログ生成ができませんでした');
    }

    /**
     * サービス申込Objのサービス管理（加盟店事業）参照項目設定処理に失敗
     */
    @isTest
    private static void test_MigrationOPMBModBatch_failure8() {
        Test.startTest();
        // DMLExceptionを発生するようにフラグを更新する
        CRMDPMigrationOPMBModBatch.isDMLExceptionTest = true;
        CRMDPMigrationOPMBModBatch.ErrorType = 'ServiceOrder__c';
        CRMDPMigrationOPMBModBatch.run();
        Test.stopTest();

        // サービス申込Objのサービス管理（加盟店事業）項目がNullであることを確認
        for (ServiceOrder__c so : [SELECT Id, OrderProgressMB__c FROM ServiceOrder__c]) {
            System.assertEquals(null, so.OrderProgressMB__c, 'サービス申込Objのサービス管理（加盟店事業）項目がNullでない');
        }

        String log_title = CRMDPMigrationOPMBModBatch.BATCH_LOG_TITLE + CRMDPMigrationOPMBModBatch.COND_UPDATERELATED_RECORDS;
        List<Log__c> actual_log = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :log_title
        ];

        // ログデータが作成されていることを確認する
        System.assertEquals(true, actual_log.size() > 0, 'ログ生成ができませんでした');
    }
}