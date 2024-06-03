/**
* クラス名: CRMDPConvertOpportunityRTBatchTest
* クラス概要: サービス管理オブジェクト分割 案件レコードタイプ変更バッチテスト
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/10/31
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class CRMDPConvertOpportunityRTBatchTest {

    @TestSetup
    static void setup(){
        Test.startTest();
        Date testDate = Date.today().addDays(14);
        // 取引先作成
        Account acc = TestDataFactory.createAccount('案件RT変更バッチ企業', true);

        // 案件作成
        // オフライン_大手_加盟店紐づけ案件
        Opportunity oppOffEnp = TestDataFactory.createOpportunity('案件RT変更_オフライン_大手', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        // オンライン_大手_加盟店紐づけ案件
        Opportunity oppOnEnp = TestDataFactory.createOpportunity('案件RT変更_オンライン_大手', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        // オンライン_自動機紐づけ案件
        Opportunity oppVending = TestDataFactory.createOpportunity('案件RT変更_自動機', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        // 商品特定クーポン紐づけ案件
        Opportunity oppSpecificCoupon = TestDataFactory.createOpportunity('案件RT変更_商品特定クーポン', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        // 残高API紐づけ案件
        Opportunity oppBalanceAPI = TestDataFactory.createOpportunity('案件RT変更_残高API', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        // オフライン_GW紐づけ案件
        Opportunity oppGW = TestDataFactory.createOpportunity('案件RT変更_GW', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        // オンライン_PSP紐づけ案件
        Opportunity oppPSP = TestDataFactory.createOpportunity('案件RT変更_PSP', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        // マイストア紐づけ案件
        Opportunity oppMyStore = TestDataFactory.createOpportunity('案件RT変更_マイストア', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        insert new List<Opportunity>{
            oppOffEnp, oppOnEnp, oppVending, oppSpecificCoupon, oppBalanceAPI, oppGW, oppPSP, oppMyStore
        };

        // 価格表作成
        Pricebook2 pbOffEnp = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_OFFLINE, false);
        Pricebook2 pbOnEnp = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_ONLINE, false);
        Pricebook2 pbVending = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_VENDING, false);
        Pricebook2 pbMaker = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_MAKER, false);
        Pricebook2 pbPointOperator = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_POINT, false);
        Pricebook2 pbGW = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_GW, false);
        Pricebook2 pbPSP = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_PSP, false);
        Pricebook2 pbMyStore = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_MYSTORE, false);
        insert new List<Pricebook2>{pbOffEnp, pbOnEnp, pbVending, pbMaker, pbPointOperator, pbGW, pbPSP, pbMyStore};

        // サービス作成
        Product2 productOffEnp = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE, false);
        productOffEnp.Family = 'オフライン';
        Product2 productOnEnp = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ONLINE, false);
        productOnEnp.Family = 'オンライン';
        Product2 productVending = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING, false);
        productVending.Family = 'オンライン_自動機';
        Product2 productSpecificCoupon = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_MAKER_SKU, false);
        productSpecificCoupon.Family = '商品特定クーポン';
        Product2 productBalanceAPI = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_BALANCE_API, false);
        productBalanceAPI.Family = '残高API';
        Product2 productGW = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_GW, false);
        productGW.Family = 'オフライン_GW';
        Product2 productPSP = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP, false);
        productPSP.Family = 'オンライン_PSP';
        Product2 productMyStore = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_MYSTORE_ENPR, false);
        productMyStore.Family = 'マイストア（大手営業管理）';

        insert new List<Product2>{productOffEnp, productOnEnp, productVending, productSpecificCoupon, productBalanceAPI, productGW, productPSP, productMyStore};

        // 価格表エントリ作成
        // 標準価格表に紐づけてからカスタム価格表へ紐づけ
        // オフライン_大手_加盟店
        PricebookEntry pbEntryStdOffEnp = TestDataFactory.createPricebookEntry(productOffEnp.Id, Test.getStandardPricebookId(), 0, false);
        PricebookEntry pbEntryOffEnp = TestDataFactory.createPricebookEntry(productOffEnp.Id, pbOffEnp.Id, 0, false);
        pbEntryOffEnp.IsActive = true;
        // オンライン_大手_加盟店
        PricebookEntry pbEntryStdOnEnp = TestDataFactory.createPricebookEntry(productOnEnp.Id, Test.getStandardPricebookId(), 0, false);
        PricebookEntry pbEntryOnEnp = TestDataFactory.createPricebookEntry(productOnEnp.Id, pbOnEnp.Id, 0, false);
        pbEntryOnEnp.IsActive = true;
        // オンライン_自動機
        PricebookEntry pbEntryStdVending = TestDataFactory.createPricebookEntry(productVending.Id, Test.getStandardPricebookId(), 0, false);
        PricebookEntry pbEntryVending = TestDataFactory.createPricebookEntry(productVending.Id, pbVending.Id, 0, false);
        pbEntryVending.IsActive = true;
        // 商品特定クーポン
        PricebookEntry pbEntryStdSpecificCoupon = TestDataFactory.createPricebookEntry(productSpecificCoupon.Id, Test.getStandardPricebookId(), 0, false);
        PricebookEntry pbEntrySpecificCoupon = TestDataFactory.createPricebookEntry(productSpecificCoupon.Id, pbMaker.Id, 0, false);
        pbEntrySpecificCoupon.IsActive = true;
        // 残高API
        PricebookEntry pbEntryStdBalanceAPI = TestDataFactory.createPricebookEntry(productBalanceAPI.Id, Test.getStandardPricebookId(), 0, false);
        PricebookEntry pbEntryBalanceAPI = TestDataFactory.createPricebookEntry(productBalanceAPI.Id, pbPointOperator.Id, 0, false);
        pbEntryBalanceAPI.IsActive = true;
        // オフライン_GW
        PricebookEntry pbEntryStdGW = TestDataFactory.createPricebookEntry(productGW.Id, Test.getStandardPricebookId(), 0, false);
        PricebookEntry pbEntryGW = TestDataFactory.createPricebookEntry(productGW.Id, pbGW.Id, 0, false);
        pbEntryGW.IsActive = true;
        // オンライン_PSP
        PricebookEntry pbEntryStdPSP = TestDataFactory.createPricebookEntry(productPSP.Id, Test.getStandardPricebookId(), 0, false);
        PricebookEntry pbEntryPSP = TestDataFactory.createPricebookEntry(productPSP.Id, pbPSP.Id, 0, false);
        pbEntryPSP.IsActive = true;
        // マイストア
        PricebookEntry pbEntryStdMyStore = TestDataFactory.createPricebookEntry(productMyStore.Id, Test.getStandardPricebookId(), 0, false);
        PricebookEntry pbEntryMyStore = TestDataFactory.createPricebookEntry(productMyStore.Id, pbMyStore.Id, 0, false);
        pbEntryMyStore.IsActive = true;

        insert new List<PricebookEntry>{pbEntryStdOffEnp, pbEntryStdOnEnp, pbEntryStdVending, 
            pbEntryStdSpecificCoupon, pbEntryStdBalanceAPI, pbEntryStdGW, pbEntryStdPSP, pbEntryStdMyStore};
        insert new List<PricebookEntry>{pbEntryOffEnp, pbEntryOnEnp, pbEntryVending, 
            pbEntrySpecificCoupon, pbEntryBalanceAPI, pbEntryGW, pbEntryPSP, pbEntryMyStore};

        // サービス情報作成
        // オフライン_大手_加盟店
        OpportunityLineItem opLineItemoffEnp = TestDataFactory.createOpportunityLineItem(oppOffEnp.Id, productOffEnp.Id, 1, 0, false);
        opLineItemoffEnp.PricebookEntryId = pbEntryOffEnp.Id;
        opLineItemoffEnp.ForRelatedOrderProgressId__c = 'false';
        // オンライン_大手_加盟店
        OpportunityLineItem opLineItemonEnp = TestDataFactory.createOpportunityLineItem(oppOnEnp.Id, productOnEnp.Id, 1, 0, false);
        opLineItemonEnp.PricebookEntryId = pbEntryOnEnp.Id;
        opLineItemonEnp.ForRelatedOrderProgressId__c = 'false';
        // オンライン_自動機
        OpportunityLineItem opLineItemvending = TestDataFactory.createOpportunityLineItem(oppVending.Id, productVending.Id, 1, 0, false);
        opLineItemvending.PricebookEntryId = pbEntryVending.Id;
        opLineItemvending.ForRelatedOrderProgressId__c = 'false';
        // 商品特定クーポン
        OpportunityLineItem opLineItemspecificCoupon = TestDataFactory.createOpportunityLineItem(oppSpecificCoupon.Id, productSpecificCoupon.Id, 1, 0, false);
        opLineItemspecificCoupon.PricebookEntryId = pbEntrySpecificCoupon.Id;
        opLineItemspecificCoupon.ForRelatedOrderProgressId__c = 'false';
        // 残高API
        OpportunityLineItem opLineItembalanceAPI = TestDataFactory.createOpportunityLineItem(oppBalanceAPI.Id, productBalanceAPI.Id, 1, 0, false);
        opLineItembalanceAPI.PricebookEntryId = pbEntryBalanceAPI.Id;
        opLineItembalanceAPI.ForRelatedOrderProgressId__c = 'false';
        // オフライン_GW
        OpportunityLineItem opLineItemGW = TestDataFactory.createOpportunityLineItem(oppGW.Id, productGW.Id, 1, 0, false);
        opLineItemGW.PricebookEntryId = pbEntryGW.Id;
        opLineItemGW.ForRelatedOrderProgressId__c = 'false';
        // オンライン_PSP
        OpportunityLineItem opLineItemPSP = TestDataFactory.createOpportunityLineItem(oppPSP.Id, productPSP.Id, 1, 0, false);
        opLineItemPSP.PricebookEntryId = pbEntryPSP.Id;
        opLineItemPSP.ForRelatedOrderProgressId__c = 'false';
        // マイストア
        OpportunityLineItem opLineItemMyStore = TestDataFactory.createOpportunityLineItem(oppMyStore.Id, productMyStore.Id, 1, 0, false);
        opLineItemMyStore.PricebookEntryId = pbEntryMyStore.Id;
        opLineItemMyStore.ForRelatedOrderProgressId__c = 'false';

        insert new List<OpportunityLineItem>{opLineItemoffEnp, opLineItemonEnp, opLineItemvending, 
            opLineItemspecificCoupon, opLineItembalanceAPI, opLineItemGW, opLineItemPSP, opLineItemMyStore};
        Test.stopTest();
    }

    /**
     * 成功パターン
     */
    @isTest
    private static void test_CRMDPConvertOpportunityRTBatch_success() {
        // 案件レコードタイプID
        Id OPPORTUNITYRECORDTYPEID_DEFAULT = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise'); // 案件レコードタイプ（エンプラ営業）
        Id OPPORTUNITYRECORDTYPEID_OFFLINE_ENP = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_Offline'); // エンプラ_オフライン
        Id OPPORTUNITYRECORDTYPEID_ONLINE_ENP = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_Online'); // エンプラ_オンライン
        Id OPPORTUNITYRECORDTYPEID_VENDING = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_Vending'); // エンプラ_自動機
        Id OPPORTUNITYRECORDTYPEID_MAKER = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_Maker'); // エンプラ_メーカー
        Id OPPORTUNITYRECORDTYPEID_POINTOPERATOR = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_PointOperator'); // エンプラ_ポイント事業者
        Id OPPORTUNITYRECORDTYPEID_GW = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_GW'); // エンプラ_GW
        Id OPPORTUNITYRECORDTYPEID_PSP = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_PSP'); // エンプラ_PSP
        Id OPPORTUNITYRECORDTYPEID_MYSTORE = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_MyStore'); // エンプラ_マイストア

        // バッチ実行前の案件取得
        for (Opportunity opp : [SELECT Id, Name, RecordTypeId FROM Opportunity WHERE Account.Name = '案件RT変更バッチ企業']){
            if(opp.Name.contains('オフライン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('オンライン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('自動機')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('商品特定クーポン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('残高API')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('GW')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('PSP')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('マイストア')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
        }

        Test.startTest();
        CRMDPConvertOpportunityRTBatch.run();
        Test.stopTest();

        // バッチ実行後の案件取得
        for (Opportunity acctual : [SELECT Id, Name, RecordTypeId FROM Opportunity WHERE Account.Name = '案件RT変更バッチ企業']){
            if(acctual.Name.contains('オフライン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_OFFLINE_ENP, acctual.RecordTypeId);
            if(acctual.Name.contains('オンライン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_ONLINE_ENP, acctual.RecordTypeId);
            if(acctual.Name.contains('自動機')) system.assertEquals(OPPORTUNITYRECORDTYPEID_VENDING, acctual.RecordTypeId);
            if(acctual.Name.contains('商品特定クーポン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_MAKER, acctual.RecordTypeId);
            if(acctual.Name.contains('残高API')) system.assertEquals(OPPORTUNITYRECORDTYPEID_POINTOPERATOR, acctual.RecordTypeId);
            if(acctual.Name.contains('GW')) system.assertEquals(OPPORTUNITYRECORDTYPEID_GW, acctual.RecordTypeId);
            if(acctual.Name.contains('PSP')) system.assertEquals(OPPORTUNITYRECORDTYPEID_PSP, acctual.RecordTypeId);
            if(acctual.Name.contains('マイストア')) system.assertEquals(OPPORTUNITYRECORDTYPEID_MYSTORE, acctual.RecordTypeId);
        }
    }

    /**
     * 更新時、更新データの不正によるExceptionによる実行失敗パターン
     */
    @isTest
    private static void test_CRMDPConvertOpportunityRTBatch_failure() {
        // 案件レコードタイプID
        Id OPPORTUNITYRECORDTYPEID_DEFAULT = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise'); // 案件レコードタイプ（エンプラ営業）
        Id OPPORTUNITYRECORDTYPEID_OFFLINE_ENP = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_Offline'); // エンプラ_オフライン
        Id OPPORTUNITYRECORDTYPEID_ONLINE_ENP = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_Online'); // エンプラ_オンライン
        Id OPPORTUNITYRECORDTYPEID_VENDING = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_Vending'); // エンプラ_自動機
        Id OPPORTUNITYRECORDTYPEID_MAKER = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_Maker'); // エンプラ_メーカー
        Id OPPORTUNITYRECORDTYPEID_POINTOPERATOR = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_PointOperator'); // エンプラ_ポイント事業者
        Id OPPORTUNITYRECORDTYPEID_GW = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_GW'); // エンプラ_GW
        Id OPPORTUNITYRECORDTYPEID_PSP = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_PSP'); // エンプラ_PSP
        Id OPPORTUNITYRECORDTYPEID_MYSTORE = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, 'OpportunityRecordType_Enterprise_MyStore'); // エンプラ_マイストア

        // バッチ実行前の案件取得
        for (Opportunity opp : [SELECT Id, Name, RecordTypeId FROM Opportunity WHERE Account.Name = '案件RT変更バッチ企業']){
            if(opp.Name.contains('オフライン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('オンライン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('自動機')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('商品特定クーポン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('残高API')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('GW')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('PSP')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
            if(opp.Name.contains('マイストア')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, opp.RecordTypeId);
        }

        // DMLExceptionを発生するようにフラグを更新する
        CRMDPConvertOpportunityRTBatch.isDMLExceptionTest = true;

        Test.startTest();
        CRMDPConvertOpportunityRTBatch.run();
        Test.stopTest();

        // バッチ実行後の案件取得
        for (Opportunity acctual : [SELECT Id, Name, RecordTypeId FROM Opportunity WHERE Account.Name = '案件RT変更バッチ企業']){
            if(acctual.Name.contains('オフライン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, acctual.RecordTypeId);
            if(acctual.Name.contains('オンライン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, acctual.RecordTypeId);
            if(acctual.Name.contains('自動機')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, acctual.RecordTypeId);
            if(acctual.Name.contains('商品特定クーポン')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, acctual.RecordTypeId);
            if(acctual.Name.contains('残高API')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, acctual.RecordTypeId);
            if(acctual.Name.contains('GW')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, acctual.RecordTypeId);
            if(acctual.Name.contains('PSP')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, acctual.RecordTypeId);
            if(acctual.Name.contains('マイストア')) system.assertEquals(OPPORTUNITYRECORDTYPEID_DEFAULT, acctual.RecordTypeId);
        }

        // ログデータが作成されていることを確認
        String logTitle = CRMDPConvertOpportunityRTBatch.BATCH_LOG_TITLE;
        List<Log__c> logData = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :logTitle
        ];
        System.assertEquals(true, logData.size() > 0, 'ログ生成に失敗しました');
    }

    /**
     * 更新前、既存の登録データに不正があるため更新できないデータが含まれているパターン
     * 処理自体は成功するがエラーログに記録が残る
     */
    @isTest
    private static void test_CRMDPConvertOpportunityRTBatch_failure_2() {
        Date testDate = Date.today().addDays(14);
        // バッチ処理成功する案件数を取得
        Account acc = [SELECT Id FROM Account WHERE Name = '案件RT変更バッチ企業' LIMIT 1];
        Integer successNum = [SELECT COUNT() FROM Opportunity WHERE AccountId = :acc.Id];

        // サービスの紐づかない案件作成=エラーにならない
        Opportunity oppTest1 = TestDataFactory.createOpportunity('案件RT変更_サービス管理0案件', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        // サービスの複数紐づく案件作成=エラーになる
        Opportunity oppTest2 = TestDataFactory.createOpportunity('案件RT変更_サービス管理0案件', acc.Id, testDate, Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        insert new List<Opportunity>{oppTest1, oppTest2};

        Product2 productOffEnp = [SELECT Id FROM Product2 WHERE Family = 'オフライン' LIMIT 1];
        PricebookEntry pbookEntry = [SELECT Id FROM PricebookEntry WHERE Name = :CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE AND Pricebook2Id != :Test.getStandardPricebookId() LIMIT 1];

        OpportunityLineItem opLineItemoffEnp1 = TestDataFactory.createOpportunityLineItem(oppTest2.Id, productOffEnp.Id, 1, 0, false);
        opLineItemoffEnp1.PricebookEntryId = pbookEntry.Id;
        opLineItemoffEnp1.ForRelatedOrderProgressId__c = 'false';
        OpportunityLineItem opLineItemoffEnp2 = TestDataFactory.createOpportunityLineItem(oppTest2.Id, productOffEnp.Id, 1, 0, false);
        opLineItemoffEnp2.PricebookEntryId = pbookEntry.Id;
        opLineItemoffEnp2.ForRelatedOrderProgressId__c = 'false';
        insert new List<OpportunityLineItem>{opLineItemoffEnp1, opLineItemoffEnp2};

        Test.startTest();
        CRMDPConvertOpportunityRTBatch.run();
        Test.stopTest();

        // ログデータが作成されていることを確認
        String logTitleIrregular = CRMDPConvertOpportunityRTBatch.BATCH_LOG_TITLE + '(例外あり)';
        String logTitleEnd = CRMDPConvertOpportunityRTBatch.BATCH_LOG_TITLE + '(完了)';
        List<Log__c> logData = [
            SELECT Id, Title__c, Detail__c, Level__c
            FROM Log__c
            WHERE Title__c = :logTitleEnd
            AND Level__c = 'ERROR'
        ];
        List<Log__c> logData2 = [
            SELECT Id, Title__c, Detail__c, Level__c
            FROM Log__c
            WHERE Title__c = :logTitleIrregular
            AND Level__c = 'INFO'
        ];

        List<String> expectNum = new List<String>{String.valueOf(successNum + 1), String.valueOf(successNum), '1'};
        String formatLogText = String.format('対象件数:{0}\n更新件数:{1}\nエラー件数:{2}', expectNum);
        System.assertEquals(true, logData2.size() > 0, '例外エラーログの生成に失敗しました');
        System.assertEquals(true, logData.size() > 0, 'エラーログの生成に失敗しました');
        System.assertEquals(formatLogText, logData[0].Detail__c, 'エラーログの内容が期待と異なります');
    }
}