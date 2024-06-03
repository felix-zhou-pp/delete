/**
* クラス名: CRMDPSetOrderProgressMBRefItem
* クラス概要: サービス管理オブジェクト分割 サービス管理(加盟店事業系)参照項目更新 テスト
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/09
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class CRMDPSetOrderProgressMBRefItemTest {

    @TestSetup
    static void setup() {
        // 取引先作成
        Account acc = TestDataFactory.createAccount('テスト取引先', true);
        // 案件作成
        Opportunity opp = TestDataFactory.createOpportunity('テスト案件', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, true);

        Id RECORDTYPE_OP_PAAS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PaaSRecordType'); // PaaS
        Id RECORDTYPE_OP_MYSTORE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PayEnterprise_mystore'); // マイストア
        Id RECORDTYPE_OP_CAMPAIGN = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Campaign'); // キャンペーン
        Id RECORDTYPE_OP_OFF_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PLCRecordType'); // オフライン_PLC

        // 親:サービス管理(決済事業)=更新対象加盟店事業
        OrderProgress__c testOp1 = TestDataFactory.createOrderProgress('参照項目更新_決済(PaaS)', acc.Id, opp.Id, RECORDTYPE_OP_PAAS, false);
        // 子:サービス管理(決済事業)-マイストア
        OrderProgress__c testOp2 = TestDataFactory.createOrderProgress('参照項目更新_決済(マイストア)', acc.Id, opp.Id, RECORDTYPE_OP_MYSTORE, false);
        // 子:サービス管理(決済事業)-参照先設定
        OrderProgress__c testOp3 = TestDataFactory.createOrderProgress('参照項目更新_決済(参照先設定)', acc.Id, opp.Id, RECORDTYPE_OP_CAMPAIGN, false);
        // 子:サービス管理(決済事業)-関連する通常クーポン（参照）
        OrderProgress__c testOp4 = TestDataFactory.createOrderProgress('参照項目更新_決済(通常クーポン)', acc.Id, opp.Id, RECORDTYPE_OP_OFF_PLC, false);
        // 更新対象外レコード:親子関係をもつレコードが存在しない
        OrderProgress__c testOp5 = TestDataFactory.createOrderProgress('参照項目更新_決済(PaaS)2', acc.Id, opp.Id, RECORDTYPE_OP_PAAS, false);
        // 更新対象外レコード:既に加盟店事業へ親子関係を持つレコードが反映されている
        OrderProgress__c testOp6 = TestDataFactory.createOrderProgress('参照項目更新_決済(PaaS)3', acc.Id, opp.Id, RECORDTYPE_OP_PAAS, false);
        insert new List<OrderProgress__c>{testOp1, testOp2, testOp3, testOp4, testOp5, testOp6};

        Id RECORDTYPE_OPM_PAAS = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAAS); // PaaS
        Id RECORDTYPE_OPM_MYSTORE = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE_MYSTORE); // マイストア
        Id RECORDTYPE_OPM_CAMPAIGN = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_CAMPAIGN); // キャンペーン
        Id RECORDTYPE_OPM_OFF_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgressMB__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PLC); // オフライン_PLC

        // 加盟店事業登録: 決済事業とのリレーションを作っておく
        // 親:サービス管理(加盟店事業)
        OrderProgressMB__c testOpm1 = TestDataFactory.createOrderProgressMB('参照項目更新_加盟店(PaaS)', acc.Id, opp.Id, RECORDTYPE_OPM_PAAS, false);
        testOpm1.OrderProgress__c = testOp1.Id;
        // 子:サービス管理(加盟店事業)-マイストア
        OrderProgressMB__c testOpm2 = TestDataFactory.createOrderProgressMB('参照項目更新_加盟店(マイストア)', acc.Id, opp.Id, RECORDTYPE_OPM_MYSTORE, false);
        testOpm2.OrderProgress__c = testOp2.Id;
        // 子:サービス管理(加盟店事業)-参照先設定
        OrderProgressMB__c testOpm3 = TestDataFactory.createOrderProgressMB('参照項目更新_加盟店(参照先設定)', acc.Id, opp.Id, RECORDTYPE_OPM_CAMPAIGN, false);
        testOpm3.OrderProgress__c = testOp3.Id;
        // 子:サービス管理(加盟店事業)-関連する通常クーポン（参照）
        OrderProgressMB__c testOpm4 = TestDataFactory.createOrderProgressMB('参照項目更新_加盟店(通常クーポン)', acc.Id, opp.Id, RECORDTYPE_OPM_OFF_PLC, false);
        testOpm4.OrderProgress__c = testOp4.Id;
        insert new List<OrderProgressMB__c>{testOpm1, testOpm2, testOpm3, testOpm4};
        // 親:サービス管理(加盟店事業)、子リレーション紐づけ済
        OrderProgressMB__c testOpm6 = TestDataFactory.createOrderProgressMB('参照項目更新_加盟店(PaaS)3', acc.Id, opp.Id, RECORDTYPE_OPM_PAAS, false);
        testOpm6.OrderProgress__c = testOpm6.Id;
        testOpm6.MyStoreRelation__c = testOpm2.Id;
        insert testOpm6;

        // 決済事業:リレーション更新
        // PaaS
        testOp1.OrderProgressMB__c = testOpm1.Id;
        testOp1.MyStoreRelation__c = testOp2.Id;
        testOp1.ReferenceSetting__c = testOp3.Id;
        testOp1.CouponRelation__c = testOp4.Id;
        // マイストア
        testOp2.OrderProgressMB__c = testOpm2.Id;
        // キャンペーン
        testOp3.OrderProgressMB__c = testOpm3.Id;
        // LYPマイレージ
        testOp4.OrderProgressMB__c = testOpm4.Id;
        // PaaS3
        testOp6.OrderProgressMB__c = testOpm6.Id;
        testOp6.MyStoreRelation__c = testOp2.Id;
        update new List<OrderProgress__c>{testOp1, testOp2, testOp3, testOp4, testOp6};
    }

    // 加盟店事業の参照項目更新に成功
    @isTest
    private static void setOrderProgressMBRefItemSuccess() {
        Id RECORDTYPE_OP_PAAS = [SELECT Id FROM OrderProgress__c WHERE Name = '参照項目更新_決済(PaaS)' LIMIT 1].Id;
        OrderProgressMB__c beforeAcctual = [
            SELECT Id, OrderProgress__c, MyStoreRelation__c, ReferenceSetting__c, CouponRelation__c
            FROM OrderProgressMB__c
            WHERE Name = '参照項目更新_加盟店(PaaS)' LIMIT 1];
        System.assertEquals(RECORDTYPE_OP_PAAS, beforeAcctual.OrderProgress__c, '加盟店事業に紐づける決済事業IDが異なる');
        System.assertEquals(null, beforeAcctual.MyStoreRelation__c, '参照項目 マイストアに事前に値が設定されている');
        System.assertEquals(null, beforeAcctual.ReferenceSetting__c, '参照項目 参照先に事前に値が設定されている');
        System.assertEquals(null, beforeAcctual.CouponRelation__c, '参照項目 通常クーポンに事前に値が設定されている');

        Test.startTest();
        CRMDPSetOrderProgressMBRefItem.run();
        Test.stopTest();

        OrderProgressMB__c afterAcctual = [
            SELECT Id, OrderProgress__c, MyStoreRelation__c, ReferenceSetting__c, CouponRelation__c
            FROM OrderProgressMB__c
            WHERE Name = '参照項目更新_加盟店(PaaS)' LIMIT 1];

        // 加盟店事業の各項目に正しく子レコードが紐づいていることを確認する
        for (OrderProgressMB__c opm : [SELECT Id, Name FROM OrderProgressMB__c]) {
            if (opm.Name.equals('参照項目更新_加盟店(マイストア)')) {
                System.assertEquals(opm.id, afterAcctual.MyStoreRelation__c, '参照項目 マイストアに紐づける加盟店事業が期待と異なる');
            }
            if (opm.Name.equals('参照項目更新_加盟店(参照先設定)')) {
                System.assertEquals(opm.id, afterAcctual.ReferenceSetting__c, '参照項目 参照先設定に紐づける加盟店事業が期待と異なる');
            }
            if (opm.Name.equals('参照項目更新_加盟店(通常クーポン)')) {
                System.assertEquals(opm.id, afterAcctual.CouponRelation__c, '参照項目 通常クーポンに紐づける加盟店事業が期待と異なる');
            }
        }

        // ログデータチェック
        String logTitle = CRMDPSetOrderProgressMBRefItem.BATCH_LOG_TITLE;
        String endLogFlg = CRMDPSetOrderProgressMBRefItem.BATCH_LOG_TITLE + '(完了)';
        List<Log__c> actualLogList = [
            SELECT Id, Title__c, Level__c, Detail__c
            FROM Log__c
            WHERE Title__c = :logTitle OR Title__c = :endLogFlg
        ];
        boolean titleFlg = false;
        for (Log__c actualLog : actualLogList) {
            if (actualLog.Level__c.equals('ERROR')) {
                System.assert(true, 'エラーログが作成された');
            }
            if (actualLog.Title__c.equals(endLogFlg) && actualLog.Level__c.equals('INFO')) {
                System.assertEquals(true, actualLog.Detail__c.contains('対象件数:1\n更新件数:1\nエラー件数:0'), '完了時のログが期待通りの内容ではない');
                titleFlg = true;
            }
        }
        System.assertEquals(true, titleFlg, '完了時のログがINFOレベルで作成されなかった');
    }

    // 加盟店事業の参照項目更新に成功
    // 
    @isTest
    private static void setOrderProgressMBRefItemSuccess2() {

    }

    @isTest
    private static void setOrderProgressMBRefItemFailured() {
        Id RECORDTYPE_OP_PAAS = [SELECT Id FROM OrderProgress__c WHERE Name = '参照項目更新_決済(PaaS)' LIMIT 1].Id;
        OrderProgressMB__c beforeAcctual = [
            SELECT Id, OrderProgress__c, MyStoreRelation__c, ReferenceSetting__c, CouponRelation__c
            FROM OrderProgressMB__c
            WHERE Name = '参照項目更新_加盟店(PaaS)' LIMIT 1];
        System.assertEquals(RECORDTYPE_OP_PAAS, beforeAcctual.OrderProgress__c, '加盟店事業に紐づける決済事業IDが異なる');
        System.assertEquals(null, beforeAcctual.MyStoreRelation__c, '参照項目 マイストアに事前に値が設定されている');
        System.assertEquals(null, beforeAcctual.ReferenceSetting__c, '参照項目 参照先に事前に値が設定されている');
        System.assertEquals(null, beforeAcctual.CouponRelation__c, '参照項目 通常クーポンに事前に値が設定されている');

        CRMDPSetOrderProgressMBRefItem.isExceptionTest = true;
        Test.startTest();
        CRMDPSetOrderProgressMBRefItem.run();
        Test.stopTest();

        OrderProgressMB__c afterAcctual = [
            SELECT Id, OrderProgress__c, MyStoreRelation__c, ReferenceSetting__c, CouponRelation__c
            FROM OrderProgressMB__c
            WHERE Name = '参照項目更新_加盟店(PaaS)' LIMIT 1];

        // 加盟店事業の各項目に正しく子レコードが紐づいていることを確認する
        for (OrderProgressMB__c opm : [SELECT Id, Name FROM OrderProgressMB__c]) {
            if (opm.Name.equals('参照項目更新_加盟店(マイストア)')) {
                System.assertEquals(null, afterAcctual.MyStoreRelation__c, '参照項目 マイストアに紐づける加盟店事業が期待と異なる');
            }
            if (opm.Name.equals('参照項目更新_加盟店(参照先設定)')) {
                System.assertEquals(null, afterAcctual.ReferenceSetting__c, '参照項目 参照先設定に紐づける加盟店事業が期待と異なる');
            }
            if (opm.Name.equals('参照項目更新_加盟店(通常クーポン)')) {
                System.assertEquals(null, afterAcctual.CouponRelation__c, '参照項目 通常クーポンに紐づける加盟店事業が期待と異なる');
            }
        }

        // ログデータチェック
        String logTitle = CRMDPSetOrderProgressMBRefItem.BATCH_LOG_TITLE;
        String logTitleEnd = CRMDPSetOrderProgressMBRefItem.BATCH_LOG_TITLE + '(完了)';
        List<Log__c> actualLogList = [
            SELECT Id, Title__c, Level__c, Detail__c
            FROM Log__c
            WHERE Title__c = :logTitle OR Title__c = :logTitleEnd
        ];
        boolean errorLogFlg = false;
        boolean endLogFlg = false;
        for (Log__c actualLog : actualLogList) {
            if (actualLog.Title__c.equals(logTitle) && actualLog.Level__c.equals('ERROR')) {
                errorLogFlg = true;
            }
            if (actualLog.Title__c.equals(logTitleEnd) && actualLog.Level__c.equals('ERROR')) {
                System.assertEquals(true, actualLog.Detail__c.contains('対象件数:1\n更新件数:0\nエラー件数:1'), '完了時のログが期待通りの内容ではない');
                endLogFlg = true;
            }
        }
        System.assertEquals(true, errorLogFlg, 'ERRORログが作成されなかった');
        System.assertEquals(true, endLogFlg, '完了時のログがERRORレベルで作成されなかった');
    }
}