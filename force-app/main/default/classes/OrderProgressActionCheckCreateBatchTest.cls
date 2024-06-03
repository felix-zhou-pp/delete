@isTest
public with sharing class OrderProgressActionCheckCreateBatchTest {

    @TestSetup
    static void setup(){
        // サービス管理のレコードタイプID
        // Id recordtypeOfflinePlc = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PLCRecordType');
        // Id recordtypeOnlinePlc = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'OnlinePLCRecordType');
        // Id recordtypeEevisitingPlc = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RevisitingCoupon');
        // Id recordtypeSchaduledPlc = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'ScheduledCoupon');
        // Id recordtypeCampaign = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Campaign');
        // Id recordtypeStampcard = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'SCRecordType');
        // Id recordtypeFlyerApply = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'FlyerApply');
        // Id recordtypeFlyerDraft = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'FlyerDraft');
        // Id recordtypeServiceCommon = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'ServiceCommon');
        // Id recordtypeMystore = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PayEnterprise_mystore');

        // Account acc = TestDataFactory.createAccount('サービス管理データ移行バッチテスト企業', true);
        // Opportunity opp = TestDataFactory.createOpportunity('サービス管理データ移行バッチテスト案件', acc.Id, Date.newInstance(2023, 2, 22), true);
        
        // OrderProgress__c order1 = TestDataFactory.createOrderProgress('データ移行バッチ_オフラインPLC', acc.Id, opp.Id, recordtypeOfflinePlc, false); // 関連する新オブジェクト数:2
        // OrderProgress__c order2 = TestDataFactory.createOrderProgress('データ移行バッチ_オンラインPLC', acc.Id, opp.Id, recordtypeOnlinePlc, false); // 関連する新オブジェクト数:1
        // OrderProgress__c order3 = TestDataFactory.createOrderProgress('データ移行バッチ_再来店クーポン', acc.Id, opp.Id, recordtypeEevisitingPlc, false); // 関連する新オブジェクト数:1
        // OrderProgress__c order4 = TestDataFactory.createOrderProgress('データ移行バッチ_日時指定クーポン', acc.Id, opp.Id, recordtypeSchaduledPlc, false); // 関連する新オブジェクト数:2
        // OrderProgress__c order5 = TestDataFactory.createOrderProgress('データ移行バッチ_キャンペーン', acc.Id, opp.Id, recordtypeCampaign, false); // 関連する新オブジェクト数:2
        // OrderProgress__c order6 = TestDataFactory.createOrderProgress('データ移行バッチ_スタンプカード', acc.Id, opp.Id, recordtypeStampcard, false); // 関連する新オブジェクト数:2
        // OrderProgress__c order7 = TestDataFactory.createOrderProgress('データ移行バッチ_チラシ申込', acc.Id, opp.Id, recordtypeFlyerApply, false); // 関連する新オブジェクト数:2
        // OrderProgress__c order8 = TestDataFactory.createOrderProgress('データ移行バッチ_チラシ入稿', acc.Id, opp.Id, recordtypeFlyerDraft, false); // 関連する新オブジェクト数:1
        // OrderProgress__c order9 = TestDataFactory.createOrderProgress('データ移行バッチ_新サービス共通', acc.Id, opp.Id, recordtypeServiceCommon, false);  // 関連する新オブジェクト数:2
        // OrderProgress__c order10 = TestDataFactory.createOrderProgress('データ移行バッチ_マイストア', acc.Id, opp.Id, recordtypeMystore, false); // 関連する新オブジェクト数:1
        // insert new List<OrderProgress__c>{order1, order2, order3, order4, order5, order6, order7, order8, order9, order10};
    }

    @isTest
    private static void test_OrderProgressUpdateBatch_success() {
        // // データ移行対象のサービス管理のIDを取得
        // Map<Id, OrderProgress__c> baseMap = new Map<Id, OrderProgress__c>([
        //     SELECT Id FROM OrderProgress__c
        //     WHERE Name IN (
        //         'データ移行バッチ_オフラインPLC',
        //         'データ移行バッチ_オンラインPLC',
        //         'データ移行バッチ_再来店クーポン',
        //         'データ移行バッチ_日時指定クーポン',
        //         'データ移行バッチ_キャンペーン',
        //         'データ移行バッチ_スタンプカード',
        //         'データ移行バッチ_チラシ申込',
        //         'データ移行バッチ_チラシ入稿',
        //         'データ移行バッチ_新サービス共通',
        //         'データ移行バッチ_マイストア'
        // )]);

        // // テストに不要なデータ(フロー自動生成分)を削除
        // List<OrderProgressActionCheck__c> deleteRecords = [
        //     SELECT Id
        //     FROM OrderProgressActionCheck__c
        //     WHERE OrderProgress_Action__c = :baseMap.keySet()
        //     OR OrderProgress_Tool_SalesPromotion__c = :baseMap.keySet()
        // ];
        // delete deleteRecords;

        Test.startTest();
        Database.executeBatch(new OrderProgressActionCheckCreateBatch(), 200);
        Test.stopTest();
        
        // サービス管理アクションチェックが作成された事を確認
        // Integer actual = [
        //     SELECT COUNT()
        //     FROM OrderProgressActionCheck__c 
        //     WHERE OrderProgress_Action__c = :baseMap.keySet()
        //     OR OrderProgress_Tool_SalesPromotion__c = :baseMap.keySet()
        // ];

        // // バッチ実行で作成される新オブジェクトのレコード = 16
        // System.assertEquals(16, actual, 'test_OrderProgressUpdateBatch_success');
    }

    // @isTest
    // private static void test_OrderProgressUpdateBatch_failure() {
    //     // データ移行対象のサービス管理のIDを取得
    //     Map<Id, OrderProgress__c> baseMap = new Map<Id, OrderProgress__c>([
    //         SELECT Id FROM OrderProgress__c
    //         WHERE Name IN (
    //             'データ移行バッチ_オフラインPLC',
    //             'データ移行バッチ_オンラインPLC',
    //             'データ移行バッチ_再来店クーポン',
    //             'データ移行バッチ_日時指定クーポン',
    //             'データ移行バッチ_キャンペーン',
    //             'データ移行バッチ_スタンプカード',
    //             'データ移行バッチ_チラシ申込',
    //             'データ移行バッチ_チラシ入稿',
    //             'データ移行バッチ_新サービス共通',
    //             'データ移行バッチ_マイストア'
    //     )]);

    //     // テストに不要なデータ(フロー自動生成分)を削除
    //     List<OrderProgressActionCheck__c> deleteRecords = [
    //         SELECT Id
    //         FROM OrderProgressActionCheck__c
    //         WHERE OrderProgress_Action__c = :baseMap.keySet()
    //         OR OrderProgress_Tool_SalesPromotion__c = :baseMap.keySet()
    //     ];
    //     delete deleteRecords;

    //     Test.startTest();
    //     // DMLExceptionを発生するようにフラグを更新する
    //     OrderProgressActionCheckCreateBatch.isDMLExceptionTest = true;
    //     Database.executeBatch(new OrderProgressActionCheckCreateBatch(), 200);
    //     Test.stopTest();
        
    //     // サービス管理アクションチェックが作成されていない事を確認
    //     Integer actual = [
    //         SELECT COUNT()
    //         FROM OrderProgressActionCheck__c 
    //         WHERE OrderProgress_Action__c = :baseMap.keySet()
    //         OR OrderProgress_Tool_SalesPromotion__c = :baseMap.keySet()
    //     ];

    //     System.assertEquals(0, actual, 'test_OrderProgressUpdateBatch_failure record num');

    //     String log_title = OrderProgressActionCheckCreateBatch.ERROR_LOG_TITLE;
    //     List<Log__c> actual_log = [
    //         SELECT Id, Title__c, Detail__c
    //         FROM Log__c
    //         WHERE Title__c = :log_title
    //     ];

    //     // ログデータが作成されていることを確認する
    //     System.assertEquals(true, actual_log.size() > 0, 'test_OrderProgressUpdateBatch_failure log check');
    //     System.assertEquals(true, actual_log.get(0).Detail__c.contains('失敗したサービス管理ID'), 'test_OrderProgressUpdateBatch_failure log check');
    // }
}