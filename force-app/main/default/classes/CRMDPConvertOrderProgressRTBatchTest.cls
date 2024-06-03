/**
* クラス名: CRMDPConvertOrderProgressRTBatchTest
* クラス概要: サービス管理オブジェクト分割 レコードタイプ変更バッチ テストクラス
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/10/31
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class CRMDPConvertOrderProgressRTBatchTest {

    private static Set<String> tgtRecordTypeStr = new Set<String>{
        'データ移行バッチ_オフライン_SS切替',
        'データ移行バッチ_オフライン_中小_加盟店',
        'データ移行バッチ_オンライン_中小_加盟店'
    };

    @TestSetup
    static void setup(){
        Date testDate = Date.today().addDays(14);
        // サービス管理のレコードタイプID
        Id RECORDTYPE_OFF_SS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'US_SS');
        Id RECORDTYPE_OFF_SMALLBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RecordTypeOfflineSmallBusiness');
        Id RECORDTYPE_ON_SMALLBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RecordTypeOnlineSmallBusiness');
        
        // 取引先作成
        Account acc = TestDataFactory.createAccount('決済レコードタイプ変更企業', true);
        // 取引先チームメンバ登録
        User testUser = TestDataFactory.createUser('tstOwner', 'セールスエンプラ管理ユーザ', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, testUser.Id, 'エンプラ/パートナー', 'Offline加盟店;Online加盟店', true);

        // 案件作成
        // オフライン_SS切替用
        Opportunity oppOfflineSS = TestDataFactory.createOpportunity('決済レコードタイプ変更企業_SS切替', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false);
        // オフライン_大手_加盟店用
        Opportunity oppOfflineEnp = TestDataFactory.createOpportunity('決済レコードタイプ変更企業_オフライン大手', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false);
        // オンライン_大手_加盟店用
        Opportunity oppOnlineEnp = TestDataFactory.createOpportunity('決済レコードタイプ変更企業_オンライン大手', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false);
        insert new List<Opportunity>{oppOfflineSS, oppOfflineEnp, oppOnlineEnp};

        // 価格表
        Pricebook2 pricebookOffEnpr = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_OFFLINE, false);
        Pricebook2 pricebookOnEnpr = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_ONLINE, false);
        insert new List<Pricebook2>{pricebookOffEnpr, pricebookOnEnpr};

        // サービス作成
        Product2 productOffEnpr = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE, false);
        productOffEnpr.Family = 'オフライン';
        Product2 productOnEnpr = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ONLINE, false);
        productOnEnpr.Family = 'オンライン';
        insert new List<Product2>{productOffEnpr, productOnEnpr};
        
        // 価格表エントリ作成
        // 標準価格表に紐づけ
        // オフライン_大手_加盟店
        PricebookEntry pbEntryStdOffEnpr = TestDataFactory.createPricebookEntry(productOffEnpr.Id, Test.getStandardPricebookId(), 0, false);
        pbEntryStdOffEnpr.IsActive = true;
        // オンライン_大手_加盟店
        PricebookEntry pbEntryStdOnEnpr = TestDataFactory.createPricebookEntry(productOnEnpr.Id, Test.getStandardPricebookId(), 0, false);
        pbEntryStdOnEnpr.IsActive = true;
        insert new List<PricebookEntry>{pbEntryStdOffEnpr, pbEntryStdOnEnpr};

        // カスタム価格表へ紐づけ
        // Offline価格表_エンプラ
        PricebookEntry pbEntryOffEnpr = TestDataFactory.createPricebookEntry(productOffEnpr.Id, pricebookOffEnpr.Id, 0, false);
        pbEntryOffEnpr.IsActive = true;
        // Online価格表_エンプラ
        PricebookEntry pbEntryOnEnpr = TestDataFactory.createPricebookEntry(productOnEnpr.Id, pricebookOnEnpr.Id, 0, false);
        pbEntryOnEnpr.IsActive = true;
        insert new List<PricebookEntry>{pbEntryOffEnpr, pbEntryOnEnpr};

        // サービス情報作成
        // オフライン_SS切替用
        OpportunityLineItem oppLineItemOffSS = TestDataFactory.createOpportunityLineItem(oppOfflineSS.Id, productOffEnpr.Id, 1, 0, false);
        oppLineItemOffSS.PricebookEntryId = pbEntryOffEnpr.Id;
        // オフライン_大手_加盟店用
        OpportunityLineItem oppLineItemOffEnpr = TestDataFactory.createOpportunityLineItem(oppOfflineEnp.Id, productOffEnpr.Id, 1, 0, false);
        oppLineItemOffEnpr.PricebookEntryId = pbEntryOffEnpr.Id;
        // オンライン_大手_加盟店用
        OpportunityLineItem oppLineItemOnEnpr = TestDataFactory.createOpportunityLineItem(oppOnlineEnp.Id, productOnEnpr.Id, 1, 0, false);
        oppLineItemOnEnpr.PricebookEntryId = pbEntryOnEnpr.Id;
        List<OpportunityLineItem> opLineItemList = new List<OpportunityLineItem>{oppLineItemOffSS, oppLineItemOffEnpr, oppLineItemOnEnpr};
        insert opLineItemList;

        // サービス管理作成
        OrderProgress__c order1 = TestDataFactory.createOrderProgress('データ移行バッチ_オフライン_SS切替', acc.Id, oppOfflineSS.Id, RECORDTYPE_OFF_SS, false);
        order1.OpportunityLineItemId__c = oppLineItemOffSS.Id;
        OrderProgress__c order2 = TestDataFactory.createOrderProgress('データ移行バッチ_オフライン_中小_加盟店', acc.Id, oppOfflineEnp.Id, RECORDTYPE_OFF_SMALLBUSINESS, false);
        order2.OpportunityLineItemId__c = oppLineItemOffEnpr.Id;
        OrderProgress__c order3 = TestDataFactory.createOrderProgress('データ移行バッチ_オンライン_中小_加盟店', acc.Id, oppOnlineEnp.Id, RECORDTYPE_ON_SMALLBUSINESS, false);
        order3.OpportunityLineItemId__c = oppLineItemOnEnpr.Id;
        insert new List<OrderProgress__c>{order1, order2, order3};
    }

    @isTest
    private static void convert_CRMDPConvertOrderProgressRTBatchTest_success() {
        // データ移行対象のサービス管理のIDを取得
        Map<Id, OrderProgress__c> baseMap = new Map<Id, OrderProgress__c>([
            SELECT Id, Name, RecordtypeId
            FROM OrderProgress__c
            WHERE Name IN :tgtRecordTypeStr
        ]);

        // テストデータのバッチ起動前の名前とIDの対応Map作成
        Map<String, Id> nameIdMap = new Map<String, Id>();
        for(Id idKey : baseMap.keyset()){
            OrderProgress__c op = baseMap.get(idKey);
            nameIdMap.put(op.name, idKey);
        }

        Test.startTest();
        CRMDPConvertOrderProgressRTBatch.run();
        Test.stopTest();

        // レコードタイプが変更された事を確認
        // 移行先のサービス管理のレコードタイプID取得
        Id RECORDTYPE_ONLINE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RecordTypeEnpOnline');
        Id RECORDTYPE_OFFLINE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PayEnterprise');
        for(OrderProgress__c result : [SELECT Id, Name, RecordTypeId FROM OrderProgress__c WHERE Id IN :baseMap.keyset()]){
            if(result.Id == nameIdMap.get('データ移行バッチ_オンライン_中小_加盟店')){
                System.assertEquals(RECORDTYPE_ONLINE, result.recordtypeId, 'オンライン_中小_加盟店のレコードタイプが期待と異なります');
            }
            else if(result.Id == nameIdMap.get('データ移行バッチ_オフライン_中小_加盟店')){
                System.assertEquals(RECORDTYPE_OFFLINE, result.recordtypeId, 'オフライン_中小_加盟店のレコードタイプが期待と異なります');
            }
            else if(result.Id == nameIdMap.get('データ移行バッチ_オフライン_SS切替')){
                System.assertEquals(RECORDTYPE_OFFLINE, result.recordtypeId, 'オフライン_SS切替のレコードタイプが期待と異なります');
            }
        }
    }

    @isTest
    private static void convert_CRMDPConvertOrderProgressRTBatchTest_failure() {
        // データ移行対象のサービス管理のIDを取得
        Map<Id, OrderProgress__c> baseMap = new Map<Id, OrderProgress__c>([
            SELECT Id, Name, RecordtypeId
            FROM OrderProgress__c
            WHERE Name IN :tgtRecordTypeStr
        ]);

        // テストデータのバッチ起動前の名前とIDの対応Map作成
        Map<String, Id> nameIdMap = new Map<String, Id>();
        for(Id idKey : baseMap.keyset()){
            OrderProgress__c op = baseMap.get(idKey);
            nameIdMap.put(op.name, idKey);
        }

        // DMLExceptionを発生するようにフラグを更新する
        CRMDPConvertOrderProgressRTBatch.isDMLExceptionTest = true;

        Test.startTest();
        CRMDPConvertOrderProgressRTBatch.run();
        Test.stopTest();

        // レコードタイプが変更されていない事を確認
        // 移行先のサービス管理のレコードタイプID取得
        Id RECORDTYPE_ONLINE_SMALLBUS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RecordTypeOnlineSmallBusiness');
        Id RECORDTYPE_OFFLINE_SMALLBUS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RecordTypeOfflineSmallBusiness');
        Id RECORDTYPE_OFFLINE_SS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'US_SS');

        for(OrderProgress__c result : [SELECT Id, Name, RecordTypeId FROM OrderProgress__c WHERE Id IN :baseMap.keyset()]){
            if(result.Id == nameIdMap.get('データ移行バッチ_オンライン_中小_加盟店')){
                System.assertEquals(RECORDTYPE_ONLINE_SMALLBUS, result.recordtypeId, 'オンライン_中小_加盟店のレコードタイプが期待と異なります');
            }
            else if(result.Id == nameIdMap.get('データ移行バッチ_オフライン_中小_加盟店')){
                System.assertEquals(RECORDTYPE_OFFLINE_SMALLBUS, result.recordtypeId, 'オフライン_中小_加盟店のレコードタイプが期待と異なります');
            }
            else if(result.Id == nameIdMap.get('データ移行バッチ_オフライン_SS切替')){
                System.assertEquals(RECORDTYPE_OFFLINE_SS, result.recordtypeId, 'オフライン_SS切替のレコードタイプが期待と異なります');

            }
        }

        // 案件レコードタイプ更新失敗ログの確認
        String logTitle = CRMDPConvertOrderProgressRTBatch.BATCH_LOG_TITLE + '(完了)';
        List<Log__c> logs = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :logTitle
        ];
        System.assertEquals(true, logs.size() > 0, 'ログが作成されませんでした');
    }
}