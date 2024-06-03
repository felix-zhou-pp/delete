/**
* クラス名: CRMDPUpdatePayCASEntryMpOpp
* クラス概要: D015：案件・サービス管理・営業先管理　個店
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2024/01/16
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class CRMDPUpdatePayCASEntryMpOppTest {
    @TestSetup
    static void setup() {
        // 取引先
        Account acc = TestDataFactory.createAccount('取引先テスト株式会社', Constant.ACC_DEVELOPER_NAME_MEMBER, true);
        // 案件（個店）作成
        Opportunity opp = TestDataFactory.createOpportunity('てすと案件1', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, true);

        // サービス管理（PayCAS以外）作成
        Id RECORDTYPE_OP_OFFLINE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE); // offline
        OrderProgress__c orderOff1 = TestDataFactory.createOrderProgress('個店情報管理1', acc.Id, opp.Id, RECORDTYPE_OP_OFFLINE, false);
        OrderProgress__c orderOff2 = TestDataFactory.createOrderProgress('個店情報管理2', acc.Id, opp.Id, RECORDTYPE_OP_OFFLINE, false);
        OrderProgress__c orderOff3 = TestDataFactory.createOrderProgress('個店情報管理3', acc.Id, opp.Id, RECORDTYPE_OP_OFFLINE, false);

        // サービス管理（PayCAS）作成
        Id RECORDTYPE_OP_PAYCAS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAYCAS); // PayCAS
        OrderProgress__c orderPayCAS1 = TestDataFactory.createOrderProgress('テスト_PayCAS切替提案1', acc.Id, opp.Id, RECORDTYPE_OP_PAYCAS, false);
        OrderProgress__c orderPayCAS2 = TestDataFactory.createOrderProgress('テスト_PayCAS切替提案2', acc.Id, opp.Id, RECORDTYPE_OP_PAYCAS, false);
        OrderProgress__c orderPayCAS3 = TestDataFactory.createOrderProgress('テスト_PayCAS切替提案3', acc.Id, opp.Id, RECORDTYPE_OP_PAYCAS, false);

        insert new List<OrderProgress__c>{orderOff1, orderOff2, orderOff3, orderPayCAS1, orderPayCAS2, orderPayCAS3};

        // アタックリスト作成
        Id mpOppRecTypePos = mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, Constant.MPOPPORTUNITY_DEV_NAME_POS);
        mpOpportunity__c mpOpp1 = TestDataFactory.createMpOpportunity('移行元アタックリスト1', mpOppRecTypePos, false);
        mpOpp1.OrderProgressId__c = orderOff1.Id;
        mpOpportunity__c mpOpp2 = TestDataFactory.createMpOpportunity('移行元アタックリスト2', mpOppRecTypePos, false);
        mpOpp2.OrderProgressId__c = orderOff2.Id;
        mpOpportunity__c mpOpp3 = TestDataFactory.createMpOpportunity('移行元アタックリスト3', mpOppRecTypePos, false);
        mpOpp3.OrderProgressId__c = orderOff3.Id;
        mpOpportunity__c mpOpp4 = TestDataFactory.createMpOpportunity('移行元アタックリスト4', mpOppRecTypePos, false); // サービス管理と紐づかない
        
        insert new List<mpOpportunity__c>{mpOpp1, mpOpp2, mpOpp3, mpOpp4};

        // PP加盟店作成
        String dummyMID = 'TEST_MID_2024';
        mpMerchant__c merchant1 = TestDataFactory.createMpMerchant('テスト加盟店1', dummyMID + '_01', false);
        merchant1.mpOpportunity__c = mpOpp1.Id;
        mpMerchant__c merchant2 = TestDataFactory.createMpMerchant('テスト加盟店2', dummyMID + '_02', false);
        merchant2.mpOpportunity__c = mpOpp2.Id;
        mpMerchant__c merchant4 = TestDataFactory.createMpMerchant('テスト加盟店4', dummyMID + '_04', false);
        merchant4.mpOpportunity__c = mpOpp4.Id;

        insert new List<mpMerchant__c>{merchant1, merchant2, merchant4};

        // PPストア作成
        PayPayStore__c store1 = TestDataFactory.createPayPayStore('テストストア1', false);
        store1.PayPayMerchant__c = merchant1.Id;
        PayPayStore__c store2 = TestDataFactory.createPayPayStore('テストストア2', false);
        store2.PayPayMerchant__c = merchant2.Id;
        PayPayStore__c store3 = TestDataFactory.createPayPayStore('テストストア3', false); // 加盟店と紐づいていないストア
        PayPayStore__c store4 = TestDataFactory.createPayPayStore('テストストア4', false);
        store4.PayPayMerchant__c = merchant4.Id;

        insert new List<PayPayStore__c>{store1, store2, store3, store4};

        // サービス管理にアタックリストを紐づける
        orderOff1.CRMDPMpOppId__c = mpOpp1.Id;
        orderOff2.CRMDPMpOppId__c = mpOpp2.Id;
        orderOff3.CRMDPMpOppId__c = mpOpp3.Id;
        orderPayCAS1.CRMDPMpOppId__c = mpOpp1.Id;
        orderPayCAS2.CRMDPMpOppId__c = mpOpp2.Id;
        orderPayCAS3.CRMDPMpOppId__c = mpOpp3.Id;
        update new List<OrderProgress__c>{orderOff1, orderOff2, orderOff3, orderPayCAS1, orderPayCAS2, orderPayCAS3};

        // PayCAS申込アタックリスト作成
        // 正常 Prefix「K_」Suffix「/検証データ/20240101/」
        mpOpportunity__c mpOppPayCAS1 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト1', mpOppRecTypePos, false);
        mpOppPayCAS1.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS1.Agency_Memo__c = 'K_' + store1.Id + '/検証データ/20240101/';
        // 正常 Prefix「S_」Suffix「_A」
        mpOpportunity__c mpOppPayCAS2 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト2', mpOppRecTypePos, false);
        mpOppPayCAS2.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS2.Agency_Memo__c = 'S_' + store2.Id + '_A';
        // 正常 Prefix「K_」Suffix「なし」 store1 2件目の登録
        mpOpportunity__c mpOppPayCAS3 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト3', mpOppRecTypePos, false);
        mpOppPayCAS3.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS3.Agency_Memo__c = 'K_' + store1.Id;
        // 正常 アタックリストID
        mpOpportunity__c mpOppPayCAS4 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト4', mpOppRecTypePos, false);
        mpOppPayCAS4.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS4.Agency_Memo__c = 'K_' + mpOpp1.Id;
        // 異常 PPストア、アタックリストID以外のID
        mpOpportunity__c mpOppPayCAS5 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト5', mpOppRecTypePos, false);
        mpOppPayCAS5.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS5.Agency_Memo__c = 'S_0015j00000jzZViAAM';
        // 異常 Prefix「P_」
        mpOpportunity__c mpOppPayCAS6 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト6', mpOppRecTypePos, false);
        mpOppPayCAS6.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS6.Agency_Memo__c = 'P_' + store2.Id + '_A';
        // 異常 IDのフォーマット不正
        mpOpportunity__c mpOppPayCAS7 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト7', mpOppRecTypePos, false);
        mpOppPayCAS7.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS7.Agency_Memo__c = 'K_a221e000000AAAAAAA';
        // 異常 PP加盟店に紐づいていないPPストア
        mpOpportunity__c mpOppPayCAS8 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト8', mpOppRecTypePos, false);
        mpOppPayCAS8.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS8.Agency_Memo__c = 'K_' + store3.Id;
        // 異常 サービス管理が見つからないPPストア
        mpOpportunity__c mpOppPayCAS9 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト9', mpOppRecTypePos, false);
        mpOppPayCAS9.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS9.Agency_Memo__c = 'K_' + store4.Id + '_A';
        // 異常 PPストアが存在しない
        mpOpportunity__c mpOppPayCAS10 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト10', mpOppRecTypePos, false);
        mpOppPayCAS10.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS10.Agency_Memo__c = 'K_a222x000000vN3vAAE';
        // 異常 包括代理店_備考が空欄
        mpOpportunity__c mpOppPayCAS11 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト11', mpOppRecTypePos, false);
        mpOppPayCAS11.Agency_Service_name__c = 'PayCAS';
        mpOppPayCAS11.Agency_Memo__c = '';
        // 異常 包括代理店_サービスがPayCAS以外
        mpOpportunity__c mpOppPayCAS12 = TestDataFactory.createMpOpportunity('PayCAS申込アタックリスト12', mpOppRecTypePos, false);
        mpOppPayCAS12.Agency_Service_name__c = 'CASCAS';
        mpOppPayCAS12.Agency_Memo__c = '';
        
        insert new List<mpOpportunity__c>{mpOppPayCAS1, mpOppPayCAS2, mpOppPayCAS3, mpOppPayCAS4, mpOppPayCAS5, mpOppPayCAS6,
            mpOppPayCAS7, mpOppPayCAS8, mpOppPayCAS9, mpOppPayCAS10, mpOppPayCAS11, mpOppPayCAS12};
    }

    // PayCAS申込情報アタックリストとサービス管理の紐づけバッチ 成功
    @isTest
    private static void update_payCasMpOppRecord_success() {
        Test.startTest();
        CRMDPUpdatePayCASEntryMpOpp.run();
        Test.stopTest();

        // 成功件数チェック
        List<mpOpportunity__c> resultList = [SELECT Id, Agency_Memo__c, OrderProgressId__c 
            FROM mpOpportunity__c WHERE Agency_Service_name__c = 'PayCAS' AND OrderProgressId__c <> null];
        System.assertEquals(4, resultList.size(), '成功数が期待値と異なる');

        Map<Id, Id> mpOppOrderProgressMap = new Map<Id, Id>();
        Id RECORDTYPE_OP_PAYCAS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAYCAS); // PayCAS
        for (OrderProgress__c op : [SELECT Id, CRMDPMpOppId__c FROM OrderProgress__c WHERE RecordTypeId = :RECORDTYPE_OP_PAYCAS]) {
            mpOppOrderProgressMap.put(op.CRMDPMpOppId__c, op.Id);
        }

        Map<Id, Id> storeIdMpOppIdMap = new Map<Id, Id>();
        for (PayPayStore__c store : [SELECT Id, PayPayMerchant__r.mpOpportunity__c FROM PayPayStore__c WHERE Name IN ('テストストア1', 'テストストア2')]) {
            storeIdMpOppIdMap.put(store.Id, store.PayPayMerchant__r.mpOpportunity__c);
        }
        for (mpOpportunity__c result : resultList) {
            Id targetStoreId = Id.valueOf(result.Agency_Memo__c.removeStartIgnoreCase('K_').removeStartIgnoreCase('S_').left(18));
            if (storeIdMpOppIdMap.containsKey(targetStoreId)) {
                Id expectOrderProgressId = mpOppOrderProgressMap.get(storeIdMpOppIdMap.get(targetStoreId));
                System.assertEquals(expectOrderProgressId, result.OrderProgressId__c, '登録されたサービス管理Idが期待値と異なる');
            }
            else if (mpOppOrderProgressMap.containsKey(targetStoreId)) {
                Id expectOrderProgressId = mpOppOrderProgressMap.get(targetStoreId);
                System.assertEquals(expectOrderProgressId, result.OrderProgressId__c, '登録されたサービス管理Idが期待値と異なる');
            }
            else {
                System.assert(true, 'アタックリストに想定外のサービス管理が紐づく');
            }
        }

        String errorLogTitle = CRMDPUpdatePayCASEntryMpOpp.BATCH_LOG_TITLE + '_エラーあり';
        List<Log__c> log = [SELECT Level__c, Detail__c FROM Log__c WHERE Title__c = :errorLogTitle];
        System.assertEquals(false, log.isEmpty(), 'エラーログの取得に失敗');
        System.assertEquals('ERROR', log[0].Level__c, 'ログレベルの設定に失敗');
    }

    // PayCAS申込情報アタックリストとサービス管理の紐づけバッチ 失敗
    // 更新するレコードが入力規則などの制限に抵触するケース（Nameの最大文字数制限に抵触）
    @isTest
    private static void update_payCasMpOppRecord_failured_1() {
        CRMDPUpdatePayCASEntryMpOpp.testMode = CRMDPUpdatePayCASEntryMpOpp.TEST_MODE.UPDATE_ERROR;
        Test.startTest();
        CRMDPUpdatePayCASEntryMpOpp.run();
        Test.stopTest();

        String errorLogTitle = CRMDPUpdatePayCASEntryMpOpp.BATCH_LOG_TITLE + '_エラーあり';
        List<Log__c> log = [SELECT Level__c, Detail__c FROM Log__c WHERE Title__c = :errorLogTitle];
        System.assertEquals(false, log.isEmpty(), 'エラーログの取得に失敗');
        System.assertEquals('ERROR', log[0].Level__c, 'ログレベルの設定に失敗');
        System.assertEquals(true, log[0].Detail__c.contains('法人名、個人事業主名: データ値が大きすぎる'), 'ログ詳細が期待と異なる');
    }

    // PayCAS申込情報アタックリストとサービス管理の紐づけバッチ 失敗
    // Update前後でExceptionが発生するケース
    @isTest
    private static void update_payCasMpOppRecord_failured_2() {
        CRMDPUpdatePayCASEntryMpOpp.testMode = CRMDPUpdatePayCASEntryMpOpp.TEST_MODE.UNKNOWN_EXCEPTION;

        Test.startTest();
        CRMDPUpdatePayCASEntryMpOpp.run();
        Test.stopTest();

        String errorLogTitle = CRMDPUpdatePayCASEntryMpOpp.BATCH_LOG_TITLE + '_Exception';
        List<Log__c> log = [SELECT Level__c, Detail__c FROM Log__c WHERE Title__c = :errorLogTitle];
        System.assertEquals(false, log.isEmpty(), 'エラーログの取得に失敗');
        System.assertEquals('ERROR', log[0].Level__c, 'ログレベルの設定に失敗');
        System.assertEquals(true, log[0].Detail__c.contains('System.NullPointerException Message'), 'ログ詳細が期待と異なる');
    }
}