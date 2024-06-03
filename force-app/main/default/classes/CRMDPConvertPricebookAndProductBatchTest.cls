/**
* クラス名: CRMDPConvertPricebookAndProductBatchTest
* クラス概要: サービス管理オブジェクト分割 価格表更新バッチテストクラス
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/6
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class CRMDPConvertPricebookAndProductBatchTest {

    @TestSetup
    static void setup(){
        // 取引先作成
        Account acc = TestDataFactory.createAccount('価格表移行テスト企業', true);
        // 取引先チームメンバ登録
        User testUser = TestDataFactory.createUser('tstOwner', 'セールスエンプラ管理ユーザ', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, testUser.Id, 'エンプラ/パートナー', 'Offline加盟店;Online加盟店;自動機;メーカー;ポイント事業者;GW;PSP', true);

        // 案件作成
        // データ移行されない案件
        // 紐づけられるサービス：2201加盟店ジャンボ
        Opportunity opp_2201jambo = TestDataFactory.createOpportunity('テスト案件_2201加盟店ジャンボ', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_2201jambo.OwnerId = testUser.Id;
        opp_2201jambo.Pricebook2Id = Test.getStandardPricebookId();
        opp_2201jambo.SummaryProduct2Name__c = '2201加盟店ジャンボ';
        // 紐づけられるサービス：チラシ_入稿
        Opportunity opp_flyerdraft = TestDataFactory.createOpportunity('テスト案件_チラシ入稿', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_flyerdraft.OwnerId = testUser.Id;
        opp_flyerdraft.Pricebook2Id = Test.getStandardPricebookId();
        opp_flyerdraft.SummaryProduct2Name__c = 'チラシ_入稿';
        // 紐づけられるサービス：テストジャンボ
        Opportunity opp_testjambo = TestDataFactory.createOpportunity('テスト案件_テストジャンボ', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_testjambo.OwnerId = testUser.Id;
        opp_testjambo.Pricebook2Id = Test.getStandardPricebookId();
        opp_testjambo.SummaryProduct2Name__c = 'テストジャンボ';
        // 紐づけられるサービス：新サービス共通
        Opportunity opp_servicecommon = TestDataFactory.createOpportunity('テスト案件_新サービス共通', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_servicecommon.OwnerId = testUser.Id;
        opp_servicecommon.Pricebook2Id = Test.getStandardPricebookId();
        opp_servicecommon.SummaryProduct2Name__c = '新サービス共通';
        // エンプラ_オフライン価格表に移管される案件
        // 紐づけられるサービス：オフライン
        // 紐づけ先サービス：オフライン
        Opportunity opp_off_enp = TestDataFactory.createOpportunity('テスト案件_オフライン', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_off_enp.OwnerId = testUser.Id;
        opp_off_enp.Pricebook2Id = Test.getStandardPricebookId();
        opp_off_enp.SummaryProduct2Name__c = 'オフライン_大手_加盟店';
        // 紐づけられるサービス：オフライン_SS切替
        // 紐づけ先サービス：オフライン
        Opportunity opp_off_enpSS = TestDataFactory.createOpportunity('テスト案件_オフラインSS切替', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_off_enpSS.OwnerId = testUser.Id;
        opp_off_enpSS.Pricebook2Id = Test.getStandardPricebookId();
        opp_off_enpSS.SummaryProduct2Name__c = 'オフライン_SS切替';
        // 紐づけられるサービス：オフライン_中小_加盟店
        // 紐づけ先サービス：オフライン
        Opportunity opp_off_enpSmall = TestDataFactory.createOpportunity('テスト案件_オフライン中小', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_off_enpSmall.OwnerId = testUser.Id;
        opp_off_enpSmall.Pricebook2Id = Test.getStandardPricebookId();
        opp_off_enpSmall.SummaryProduct2Name__c = 'オフライン_中小_加盟店';
        // 紐づけられるサービス：PayPayポイント
        // 紐づけ先サービス：【Offline】PPポイント加盟店
        Opportunity opp_off_pppoint = TestDataFactory.createOpportunity('テスト案件_オフラインPayPayポイント', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_off_pppoint.OwnerId = testUser.Id;
        opp_off_pppoint.Pricebook2Id = Test.getStandardPricebookId();
        opp_off_pppoint.SummaryProduct2Name__c = 'PayPayポイント';
        // 紐づけられるサービス：【集約】個社キャンペーン（ジャンボ）
        // 紐づけ先サービス：【集約】【Offline】個社キャンペーン（ジャンボ）加盟店
        Opportunity opp_off_indivcamp_jambo = TestDataFactory.createOpportunity('テスト案件_オフライン【集約】個社キャンペーン（ジャンボ）加盟店', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_off_indivcamp_jambo.OwnerId = testUser.Id;
        opp_off_indivcamp_jambo.Pricebook2Id = Test.getStandardPricebookId();
        opp_off_indivcamp_jambo.SummaryProduct2Name__c = '【集約】個社キャンペーン（ジャンボ）';
        // 紐づけられるサービス：【集約】個社キャンペーン（総付け）
        // 紐づけ先サービス：【集約】【Offline】個社キャンペーン（総付け）加盟店
        Opportunity opp_off_indivcamp_all = TestDataFactory.createOpportunity('テスト案件_オフライン【集約】個社キャンペーン（総付け）加盟店', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_off_indivcamp_all.OwnerId = testUser.Id;
        opp_off_indivcamp_all.Pricebook2Id = Test.getStandardPricebookId();
        opp_off_indivcamp_all.SummaryProduct2Name__c = '【集約】個社キャンペーン（総付け）';
        // 紐づけられるサービス：オフライン_PLC
        // 紐づけ先サービス：オフライン_PLC
        Opportunity opp_offplc = TestDataFactory.createOpportunity('テスト案件_オフラインPLC', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_offplc.OwnerId = testUser.Id;
        opp_offplc.Pricebook2Id = Test.getStandardPricebookId();
        opp_offplc.SummaryProduct2Name__c = 'オフライン_PLC';
        // 紐づけられるサービス：スタンプカード
        // 紐づけ先サービス：【Offline】スタンプ
        Opportunity opp_off_stamp = TestDataFactory.createOpportunity('テスト案件_オフラインスタンプカード', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_off_stamp.OwnerId = testUser.Id;
        opp_off_stamp.Pricebook2Id = Test.getStandardPricebookId();
        opp_off_stamp.SummaryProduct2Name__c = 'スタンプカード';
        // 紐づけられるサービス：再来店クーポン
        // 紐づけ先サービス：【Offline】再来店クーポン
        Opportunity opp_off_revisitingcoupon = TestDataFactory.createOpportunity('テスト案件_オフライン再来店クーポン', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_off_revisitingcoupon.OwnerId = testUser.Id;
        opp_off_revisitingcoupon.Pricebook2Id = Test.getStandardPricebookId();
        opp_off_revisitingcoupon.SummaryProduct2Name__c = '再来店クーポン';
        // 紐づけられるサービス：日時指定クーポン
        // 紐づけ先サービス：【Offline】日時指定クーポン
        Opportunity opp_off_scheduledcoupon = TestDataFactory.createOpportunity('テスト案件_オフライン日時指定クーポン', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_off_scheduledcoupon.OwnerId = testUser.Id;
        opp_off_scheduledcoupon.Pricebook2Id = Test.getStandardPricebookId();
        opp_off_scheduledcoupon.SummaryProduct2Name__c = '日時指定クーポン';
        // エンプラ_オンライン価格表に移管される案件
        // 紐づけられるサービス：オンライン
        // 紐づけ先サービス：オンライン
        Opportunity opp_on_enp = TestDataFactory.createOpportunity('テスト案件_オンライン', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_on_enp.OwnerId = testUser.Id;
        opp_on_enp.Pricebook2Id = Test.getStandardPricebookId();
        opp_on_enp.SummaryProduct2Name__c = 'オンライン_大手_加盟店';
        // 紐づけられるサービス：オンライン_中小
        // 紐づけ先サービス：オンライン
        Opportunity opp_on_enpSmall = TestDataFactory.createOpportunity('テスト案件_オンライン中小', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_on_enpSmall.OwnerId = testUser.Id;
        opp_on_enpSmall.Pricebook2Id = Test.getStandardPricebookId();
        opp_on_enpSmall.SummaryProduct2Name__c = 'オンライン_中小_加盟店';
        // 紐づけられるサービス：PayPayポイント
        // 紐づけ先サービス：【Online】PPポイント加盟店
        Opportunity opp_on_pppoint = TestDataFactory.createOpportunity('テスト案件_オンラインPPポイント加盟店', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_on_pppoint.OwnerId = testUser.Id;
        opp_on_pppoint.Pricebook2Id = Test.getStandardPricebookId();
        opp_on_pppoint.SummaryProduct2Name__c = 'PayPayポイント';
        // 紐づけられるサービス：【集約】個社キャンペーン（ジャンボ）
        // 紐づけ先サービス：【集約】【Online】個社キャンペーン（ジャンボ）加盟店
        Opportunity opp_on_indivcamp_jambo = TestDataFactory.createOpportunity('テスト案件_オンライン【集約】個社キャンペーン（ジャンボ）加盟店', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_on_indivcamp_jambo.OwnerId = testUser.Id;
        opp_on_indivcamp_jambo.Pricebook2Id = Test.getStandardPricebookId();
        opp_on_indivcamp_jambo.SummaryProduct2Name__c = '【集約】個社キャンペーン（ジャンボ）';
        // 紐づけられるサービス：【集約】個社キャンペーン（総付け）
        // 紐づけ先サービス：【集約】【Online】個社キャンペーン（総付け）加盟店紐
        Opportunity opp_on_indivcamp_all = TestDataFactory.createOpportunity('テスト案件_オンライン【集約】個社キャンペーン（総付け）加盟店', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_on_indivcamp_all.OwnerId = testUser.Id;
        opp_on_indivcamp_all.Pricebook2Id = Test.getStandardPricebookId();
        opp_on_indivcamp_all.SummaryProduct2Name__c = '【集約】個社キャンペーン（総付け）';
        // 紐づけられるサービス：オンライン_PLC
        // 紐づけ先サービス：オンライン_PLC
        Opportunity opp_onplc = TestDataFactory.createOpportunity('テスト案件_オンラインPLC', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_onplc.OwnerId = testUser.Id;
        opp_onplc.Pricebook2Id = Test.getStandardPricebookId();
        opp_onplc.SummaryProduct2Name__c = 'オンライン_PLC';
        // 紐づけられるサービス：オンライン_モール/カート
        // 紐づけ先サービス：オンライン_モール
        Opportunity opp_onmall = TestDataFactory.createOpportunity('テスト案件_オンモール', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_onmall.OwnerId = testUser.Id;
        opp_onmall.Pricebook2Id = Test.getStandardPricebookId();
        opp_onmall.SummaryProduct2Name__c = 'オンライン_モール/カート';
        // 紐づけられるサービス：スタンプカード
        // 紐づけ先サービス：【Online】スタンプ
        Opportunity opp_on_stamp = TestDataFactory.createOpportunity('テスト案件_オンラインスタンプ', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_on_stamp.OwnerId = testUser.Id;
        opp_on_stamp.Pricebook2Id = Test.getStandardPricebookId();
        opp_on_stamp.SummaryProduct2Name__c = 'スタンプカード';
        // 紐づけられるサービス：再来店クーポン
        // 紐づけ先サービス：【Online】再来店クーポン
        Opportunity opp_on_revisitingcoupon = TestDataFactory.createOpportunity('テスト案件_オンライン再来店クーポン', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_on_revisitingcoupon.OwnerId = testUser.Id;
        opp_on_revisitingcoupon.Pricebook2Id = Test.getStandardPricebookId();
        // 紐づけられるサービス：日時指定クーポン
        // 紐づけ先サービス：【Online】日時指定クーポン
        Opportunity opp_on_scheduledcoupon = TestDataFactory.createOpportunity('テスト案件_オンライン日時指定クーポン', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_on_scheduledcoupon.OwnerId = testUser.Id;
        opp_on_scheduledcoupon.Pricebook2Id = Test.getStandardPricebookId();
        opp_on_scheduledcoupon.SummaryProduct2Name__c = '日時指定クーポン';
        // エンプラ_自動機価格表に移管される案件
        // 紐づけられるサービス：オンライン_自動機
        // 紐づけ先サービス：オンライン_自動機
        Opportunity opp_vending = TestDataFactory.createOpportunity('テスト案件_オンライン自動機', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_vending.OwnerId = testUser.Id;
        opp_vending.Pricebook2Id = Test.getStandardPricebookId();
        opp_vending.SummaryProduct2Name__c = 'オンライン_自動機';
        // 紐づけられるサービス：オフライン_PLC
        // 紐づけ先サービス：【自動機】オフライン_PLC
        Opportunity opp_vending_offplc = TestDataFactory.createOpportunity('テスト案件_【自動機】オフラインPLC', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_vending_offplc.OwnerId = testUser.Id;
        opp_vending_offplc.Pricebook2Id = Test.getStandardPricebookId();
        opp_vending_offplc.SummaryProduct2Name__c = 'オフライン_PLC';
        // 紐づけられるサービス：オンライン_PLC
        // 紐づけ先サービス：【自動機】オンライン_PLC
        Opportunity opp_vending_onplc = TestDataFactory.createOpportunity('テスト案件_【自動機】オンラインPLC', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_vending_onplc.OwnerId = testUser.Id;
        opp_vending_onplc.Pricebook2Id = Test.getStandardPricebookId();
        opp_vending_onplc.SummaryProduct2Name__c = 'オンライン_PLC';
        // 紐づけられるサービス：再来店クーポン
        // 紐づけ先サービス：【自動機】再来店クーポン
        Opportunity opp_vending_revisitingcoupon = TestDataFactory.createOpportunity('テスト案件_【自動機】再来店クーポン', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_vending_revisitingcoupon.OwnerId = testUser.Id;
        opp_vending_revisitingcoupon.Pricebook2Id = Test.getStandardPricebookId();
        opp_vending_revisitingcoupon.SummaryProduct2Name__c = '再来店クーポン';
        // 紐づけられるサービス：日時指定クーポン
        // 紐づけ先サービス：【自動機】日時指定クーポン
        Opportunity opp_vending_scheduledcoupon = TestDataFactory.createOpportunity('テスト案件_【自動機】日時指定クーポン', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_vending_scheduledcoupon.OwnerId = testUser.Id;
        opp_vending_scheduledcoupon.Pricebook2Id = Test.getStandardPricebookId();
        opp_vending_scheduledcoupon.SummaryProduct2Name__c = '日時指定クーポン';
        // エンプラ_メーカー価格表に移管される案件
        // 紐づけられるサービス：商品特定クーポン
        // 紐づけ先サービス：商品特定クーポン
        Opportunity opp_specificCoupon = TestDataFactory.createOpportunity('テスト案件_商品特定クーポン', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_specificCoupon.OwnerId = testUser.Id;
        opp_specificCoupon.Pricebook2Id = Test.getStandardPricebookId();
        opp_specificCoupon.SummaryProduct2Name__c = '商品特定クーポン';
        // エンプラ_ポイント事業者価格表に移管される案件
        // 紐づけられるサービス：残高API
        // 紐づけ先サービス：残高API
        Opportunity opp_balanceAPI = TestDataFactory.createOpportunity('テスト案件_残高API', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_balanceAPI.OwnerId = testUser.Id;
        opp_balanceAPI.Pricebook2Id = Test.getStandardPricebookId();
        opp_balanceAPI.SummaryProduct2Name__c = '残高API';
        // エンプラ_GW価格表に移管される案件
        // 紐づけられるサービス：オフライン_GW
        // 紐づけ先サービス：オフライン_GW
        Opportunity opp_GW = TestDataFactory.createOpportunity('テスト案件_GW', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_GW.OwnerId = testUser.Id;
        opp_GW.Pricebook2Id = Test.getStandardPricebookId();
        opp_GW.SummaryProduct2Name__c = 'オフライン_GW';
        // エンプラ_PSP価格表に移管される案件
        // 紐づけられるサービス：オンライン_PSP
        // 紐づけ先サービス：オンライン_PSP
        Opportunity opp_PSP = TestDataFactory.createOpportunity('テスト案件_PSP', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_PSP.OwnerId = testUser.Id;
        opp_PSP.Pricebook2Id = Test.getStandardPricebookId();
        opp_PSP.SummaryProduct2Name__c = 'オンライン_PSP';
        // 紐づけられるサービス：オンライン_モール/カート
        // 紐づけ先サービス：オンライン_カート
        Opportunity opp_oncart = TestDataFactory.createOpportunity('テスト案件_オンカート', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_oncart.OwnerId = testUser.Id;
        opp_oncart.Pricebook2Id = Test.getStandardPricebookId();
        opp_oncart.SummaryProduct2Name__c = 'オンライン_モール/カート';
        // エンプラ_マイストア価格表に移管される案件
        // 紐づけられるサービス：マイストア（大手営業管理）
        // 紐づけ先サービス：マイストア（大手営業管理）
        Opportunity opp_myStore = TestDataFactory.createOpportunity('テスト案件_マイストア（大手営業管理）', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        opp_myStore.OwnerId = testUser.Id;
        opp_myStore.Pricebook2Id = Test.getStandardPricebookId();
        opp_myStore.SummaryProduct2Name__c = 'マイストア（大手営業管理）';

        List<Opportunity> oppList = new List<Opportunity>{
            opp_2201jambo,
            opp_flyerdraft,
            opp_testjambo,
            opp_servicecommon,
            opp_off_enp,
            opp_off_enpSS,
            opp_off_enpSmall,
            opp_off_pppoint,
            opp_off_indivcamp_jambo,
            opp_off_indivcamp_all,
            opp_offplc,
            opp_off_stamp,
            opp_off_revisitingcoupon,
            opp_off_scheduledcoupon,
            opp_on_enp,
            opp_on_enpSmall,
            opp_on_pppoint,
            opp_on_indivcamp_jambo,
            opp_on_indivcamp_all,
            opp_onplc,
            opp_onmall,
            opp_on_stamp,
            opp_on_revisitingcoupon,
            opp_on_scheduledcoupon,
            opp_vending,
            opp_vending_offplc,
            opp_vending_onplc,
            opp_vending_revisitingcoupon,
            opp_vending_scheduledcoupon,
            opp_specificCoupon,
            opp_balanceAPI,
            opp_GW,
            opp_PSP,
            opp_oncart,
            opp_myStore
        };
        insert oppList;

        // オンライン_モール紐づけ案件サービス管理
        OrderProgress__c op_onmall = TestDataFactory.createOrderProgress('サービス管理（決済事業）_オンモール', acc.Id, opp_onmall.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_ENPMALL_ONLINE), false);
        op_onmall.Industryclass__c = '小売業';
        op_onmall.NewIndustryclass__c = 'コンビニ';
        op_onmall.Industryclassification__c = 'コンビニ';
        // オンライン_カート紐づけ案件サービス管理
        OrderProgress__c op_oncart = TestDataFactory.createOrderProgress('サービス管理（決済事業）_オンカート', acc.Id, opp_oncart.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_ENPMALL_ONLINE), false);
        op_oncart.Industryclass__c = 'GW・PSP/カート・収納代行';
        op_oncart.NewIndustryclass__c = 'カート';
        op_oncart.Industryclassification__c = 'カート';
        // 【Offline】PPポイント加盟店紐づけ案件サービス管理
        OrderProgress__c op_off_pppoint = TestDataFactory.createOrderProgress('サービス管理（加盟店事業）_【Offline】PPポイント加盟店', acc.Id, opp_off_pppoint.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PCRecordType'), false);
        op_off_pppoint.OnOff__c = 'オフライン';
        // 【Online】PPポイント加盟店紐づけ案件サービス管理
        OrderProgress__c op_on_pppoint = TestDataFactory.createOrderProgress('サービス管理（加盟店事業）_【Online】PPポイント加盟店', acc.Id, opp_on_pppoint.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PCRecordType'), false);
        op_on_pppoint.OnOff__c = 'オンライン';
        // 【集約】【Offline】個社キャンペーン（ジャンボ）加盟店紐づけ案件サービス管理
        OrderProgress__c op_off_indivcamp_jambo = TestDataFactory.createOrderProgress('サービス管理（加盟店事業）_【集約】【Offline】個社キャンペーン（ジャンボ）加盟店', acc.Id, opp_off_indivcamp_jambo.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Campaign'), false);
        op_off_indivcamp_jambo.OnOff__c = 'オフライン';
        // 【集約】【Online】個社キャンペーン（ジャンボ）加盟店紐づけ案件サービス管理
        OrderProgress__c op_on_indivcamp_jambo = TestDataFactory.createOrderProgress('サービス管理（加盟店事業）_【集約】【Online】個社キャンペーン（ジャンボ）加盟店', acc.Id, opp_on_indivcamp_jambo.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Campaign'), false);
        op_on_indivcamp_jambo.OnOff__c = 'オンライン';
        // 【集約】【Offline】個社キャンペーン（総付け）加盟店紐づけ案件サービス管理
        OrderProgress__c op_off_indivcamp_all = TestDataFactory.createOrderProgress('サービス管理（加盟店事業）_【集約】【Offline】個社キャンペーン（総付け）加盟店', acc.Id, opp_off_indivcamp_all.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Campaign'), false);
        op_off_indivcamp_all.OnOff__c = 'オフライン';
        // 【集約】【Online】個社キャンペーン（総付け）加盟店紐づけ案件サービス管理
        OrderProgress__c op_on_indivcamp_all = TestDataFactory.createOrderProgress('サービス管理（加盟店事業）_【集約】【Online】個社キャンペーン（総付け）加盟店', acc.Id, opp_on_indivcamp_all.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'Campaign'), false);
        op_on_indivcamp_all.OnOff__c = 'オンライン';
        // 【自動機】オフライン_PLC紐づけ案件サービス管理
        OrderProgress__c op_vending_offplc = TestDataFactory.createOrderProgress('サービス管理（加盟店事業）_オフPLC', acc.Id, opp_vending_offplc.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PLCRecordType'), false);
        op_vending_offplc.Industryclass__c = 'GW・PSP/カート・収納代行';
        op_vending_offplc.NewIndustryclass__c = '自動機';
        op_vending_offplc.Industryclassification__c = '自動機';
        // オフライン_PLC紐づけ案件サービス管理
        OrderProgress__c op_offplc = TestDataFactory.createOrderProgress('サービス管理（加盟店事業）_オフPLC', acc.Id, opp_offplc.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PLCRecordType'), false);
        op_offplc.Industryclass__c = '飲食';
        op_offplc.NewIndustryclass__c = '飲食';
        op_offplc.Industryclassification__c = '飲食店・喫茶店';
        // 【自動機】オンライン_PLC紐づけ案件サービス管理
        OrderProgress__c op_vending_onplc = TestDataFactory.createOrderProgress('サービス管理（加盟店事業）_オンPLC', acc.Id, opp_vending_onplc.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'OnlinePLCRecordType'), false);
        op_vending_onplc.Industryclass__c = 'GW・PSP/カート・収納代行';
        op_vending_onplc.NewIndustryclass__c = '自動機';
        op_vending_onplc.Industryclassification__c = '自動機';
        // オンライン_PLC紐づけ案件サービス管理
        OrderProgress__c op_onplc = TestDataFactory.createOrderProgress('サービス管理（加盟店事業）_オンPLC', acc.Id, opp_onplc.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'OnlinePLCRecordType'), false);
        op_onplc.Industryclass__c = '飲食';
        op_onplc.NewIndustryclass__c = '飲食';
        op_onplc.Industryclassification__c = '飲食店・喫茶店';

        List<OrderProgress__c> opList = new List<OrderProgress__c>{
            op_onmall,
            op_oncart,
            op_off_pppoint,
            op_on_pppoint,
            op_off_indivcamp_jambo,
            op_on_indivcamp_jambo,
            op_off_indivcamp_all,
            op_on_indivcamp_all,
            op_vending_offplc,
            op_offplc,
            op_vending_onplc,
            op_onplc
        };
        insert opList;
        
        // 価格表作成
        // エンプラ_オフライン
        Pricebook2 pb_off_enp = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_OFFLINE, false);
        // エンプラ_オンライン
        Pricebook2 pb_on_enp = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_ONLINE, false);
        // エンプラ_自動機
        Pricebook2 pb_vending = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_VENDING, false);
        // エンプラ_メーカー
        Pricebook2 pb_maker = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_MAKER, false);
        // エンプラ_ポイント事業者
        Pricebook2 pb_pointOperator = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_POINT, false);
        // エンプラ_GW
        Pricebook2 pb_GW = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_GW, false);
        // エンプラ_PSP
        Pricebook2 pb_PSP = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_PSP, false);
        // エンプラ_マイストア
        Pricebook2 pb_myStore = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_MYSTORE, false);
        // 個店
        Pricebook2 pb_indev = TestDataFactory.createPricebook2(CRMDPPBookProd2NameUtil.CRMD_PBOOK_INDEVSALES, false);

        List<Pricebook2> pbList = new List<Pricebook2>{pb_off_enp, pb_on_enp, pb_vending, pb_maker, pb_pointOperator, pb_GW, pb_PSP, pb_myStore, pb_indev};
        insert pbList;

        // サービス作成
        // 2201加盟店ジャンボ
        Product2 product_opp_2201jambo = TestDataFactory.createProduct2('2201加盟店ジャンボ', false);
        product_opp_2201jambo.family = 'キャンペーン';
        product_opp_2201jambo.CampaignCategory__c = 'ジャンボ';
        // チラシ_入稿
        Product2 product_opp_flyerdraft = TestDataFactory.createProduct2('チラシ_入稿', false);
        product_opp_flyerdraft.family = 'チラシ_入稿';
        // テストジャンボ
        Product2 product_opp_testjambo = TestDataFactory.createProduct2('テストジャンボ', false);
        product_opp_testjambo.family = 'キャンペーン';
        product_opp_testjambo.CampaignCategory__c = 'ジャンボ';
        // 新サービス共通
        Product2 product_opp_servicecommon = TestDataFactory.createProduct2('新サービス共通', false);
        product_opp_servicecommon.family = '新サービス共通';
        // オフライン
        Product2 product_off_enp = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE, false);
        product_off_enp.family = CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE;
        // オフラインSS切替
        Product2 product_off_enpSS = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_ON_SS, false);
        product_off_enpSS.family = CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_ON_SS;
        // オフライン_中小_加盟店
        Product2 product_off_enpSmall = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_OFF_SMALL_BIZ, false);
        product_off_enpSmall.family = CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_OFF_SMALL_BIZ;
        // PayPayポイント
        Product2 product_opp_pppoint = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_POINT, false);
        product_opp_pppoint.family = CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_POINT;
        // 【集約】個社キャンペーン（ジャンボ）加盟店
        Product2 product_opp_indivcamp_jambo = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_CAMPAIGN_JAMBO, false);
        product_opp_indivcamp_jambo.family = 'キャンペーン';
        product_opp_indivcamp_jambo.CampaignCategory__c = 'ジャンボ';
        // 【集約】個社キャンペーン（総付け）加盟店
        Product2 product_opp_indivcamp_all = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_CAMPAIGN_GRANT, false);
        product_opp_indivcamp_all.family = 'キャンペーン';
        product_opp_indivcamp_all.CampaignCategory__c = '総付け';
        // オフライン_PLC
        Product2 product_opp_offplc = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_PLC, false);
        product_opp_offplc.family = CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_PLC;
        // スタンプカード
        Product2 product_opp_stamp = TestDataFactory.createProduct2('スタンプカード', false);
        product_opp_stamp.family = 'スタンプカード';
        // 再来店クーポン
        Product2 product_opp_revisitingcoupon = TestDataFactory.createProduct2('再来店クーポン', false);
        product_opp_revisitingcoupon.family = '再来店クーポン';
        // 日時指定クーポン
        Product2 product_opp_scheduledcoupon = TestDataFactory.createProduct2('日時指定クーポン', false);
        product_opp_scheduledcoupon.family = '日時指定クーポン';
        // オンライン
        Product2 product_on_enp = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ONLINE, false);
        product_on_enp.family = CRMDPPBookProd2NameUtil.CRMD_PROD2_ONLINE;
        // オンライン_中小_加盟店
        Product2 product_on_enpSmall = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_ON_SMALL_BIZ, false);
        product_on_enpSmall.family = CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_ON_SMALL_BIZ;
        // オンライン_PLC
        Product2 product_opp_onplc = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_PLC, false);
        product_opp_onplc.family = CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_PLC;
        // オンライン_モール/カート
        Product2 product_opp_onmallcart = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_MALL_CART, false);
        product_opp_onmallcart.family = CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_MALL_CART;
        // オンライン_自動機
        Product2 product_vending = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING, false);
        product_vending.family = CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING;
        // 商品特定クーポン
        Product2 product_specificCoupon = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_MAKER_SKU, false);
        product_specificCoupon.family = CRMDPPBookProd2NameUtil.CRMD_PROD2_MAKER_SKU;
        // 残高API
        Product2 product_balanceAPI = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_BALANCE_API, false);
        product_balanceAPI.family = CRMDPPBookProd2NameUtil.CRMD_PROD2_BALANCE_API;
        // オフライン_GW
        Product2 product_GW = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_GW, false);
        product_GW.family = CRMDPPBookProd2NameUtil.CRMD_PROD2_GW;
        // オンライン_PSP
        Product2 product_PSP = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP, false);
        product_PSP.family = CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP;
        // マイストア
        Product2 product_myStore = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_MYSTORE, false);
        product_myStore.family = CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_MYSTORE;
        // マイストア（大手営業管理）
        Product2 product_myStore_enpr = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_MYSTORE_ENPR, false);
        product_myStore_enpr.family = CRMDPPBookProd2NameUtil.CRMD_PROD2_MYSTORE_ENPR;
        // 【Offline】PPポイント加盟店
        Product2 product_opp_off_pppoint = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_POINT, false);
        product_opp_off_pppoint.family = 'PayPayポイント';
        // 【Online】PPポイント加盟店
        Product2 product_opp_on_pppoint = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_POINT, false);
        product_opp_on_pppoint.family = 'PayPayポイント';
        // 【集約】【Offline】個社キャンペーン（ジャンボ）加盟店
        Product2 product_opp_off_indivcamp_jambo = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_CAMPAIGN_JAMBO, false);
        product_opp_off_indivcamp_jambo.family = 'キャンペーン';
        product_opp_off_indivcamp_jambo.CampaignCategory__c = 'ジャンボ';
        // 【集約】【Offline】個社キャンペーン（総付け）加盟店
        Product2 product_opp_off_indivcamp_all = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_CAMPAIGN_GRANT, false);
        product_opp_off_indivcamp_all.family = 'キャンペーン';
        product_opp_off_indivcamp_all.CampaignCategory__c = '総付け';
        // 【集約】【Online】個社キャンペーン（ジャンボ）加盟店
        Product2 product_opp_on_indivcamp_jambo = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_CAMPAIGN_JAMBO, false);
        product_opp_on_indivcamp_jambo.family = 'キャンペーン';
        product_opp_on_indivcamp_jambo.CampaignCategory__c = 'ジャンボ';
        // 【集約】【Online】個社キャンペーン（総付け）加盟店
        Product2 product_opp_on_indivcamp_all = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_CAMPAIGN_GRANT, false);
        product_opp_on_indivcamp_all.family = 'キャンペーン';
        product_opp_on_indivcamp_all.CampaignCategory__c = '総付け';
        // 【Offline】スタンプ
        Product2 product_opp_off_stamp = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_STAMP, false);
        product_opp_off_stamp.family = 'スタンプカード';
        // 【Online】スタンプ
        Product2 product_opp_on_stamp = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_STAMP, false);
        product_opp_on_stamp.family = 'スタンプカード';
        // 【Offline】再来店クーポン
        Product2 product_opp_off_revisitingcoupon = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_REVISIT, false);
        product_opp_off_revisitingcoupon.family = '再来店クーポン';
        // 【Online】再来店クーポン
        Product2 product_opp_on_revisitingcoupon = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_REVISIT, false);
        product_opp_on_revisitingcoupon.family = '再来店クーポン';
        // 【Offline】日時指定クーポン
        Product2 product_opp_off_scheduledcoupon = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_SCHEDULED, false);
        product_opp_off_scheduledcoupon.family = '日時指定クーポン';
        // 【Online】日時指定クーポン
        Product2 product_opp_on_scheduledcoupon = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_SCHEDULED , false);
        product_opp_on_scheduledcoupon.family = '日時指定クーポン';
        // 【自動機】オフライン_PLC
        Product2 product_opp_vending_offplc = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_OFFPLC, false);
        product_opp_vending_offplc.family = 'オフライン_PLC';
        // 【自動機】オンライン_PLC
        Product2 product_opp_vending_onplc = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_ONPLC, false);
        product_opp_vending_onplc.family = 'オンライン_PLC';
        // 【自動機】再来店クーポン
        Product2 product_opp_vending_revisitingcoupon = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_REVISIT, false);
        product_opp_vending_revisitingcoupon.family = '再来店クーポン';
        // 【自動機】日時指定クーポン
        Product2 product_opp_vending_scheduledcoupon = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_SCHEDULED, false);
        product_opp_vending_scheduledcoupon.family = '日時指定クーポン';
        // オンライン_モール
        Product2 product_opp_onmall = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_MALL, false);
        product_opp_onmall.family = CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_MALL_CART;
        // オンライン_カート
        Product2 product_opp_oncart = TestDataFactory.createProduct2(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP_CART, false);
        product_opp_oncart.family = CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_MALL_CART;

        List<Product2> productList = new List<Product2>{
            product_opp_2201jambo,
            product_opp_flyerdraft,
            product_opp_testjambo,
            product_opp_servicecommon,
            product_off_enp,
            product_off_enpSS,
            product_off_enpSmall,
            product_opp_pppoint,
            product_opp_indivcamp_jambo,
            product_opp_indivcamp_all,
            product_opp_offplc,
            product_opp_stamp,
            product_opp_revisitingcoupon,
            product_opp_scheduledcoupon,
            product_on_enp,
            product_on_enpSmall,
            product_opp_onplc,
            product_opp_onmallcart,
            product_vending,
            product_specificCoupon,
            product_balanceAPI,
            product_GW,
            product_PSP,
            product_myStore,
            product_myStore_enpr,
            product_opp_off_pppoint,
            product_opp_on_pppoint,
            product_opp_off_indivcamp_jambo,
            product_opp_off_indivcamp_all,
            product_opp_on_indivcamp_jambo,
            product_opp_on_indivcamp_all,
            product_opp_off_stamp,
            product_opp_on_stamp,
            product_opp_off_revisitingcoupon,
            product_opp_on_revisitingcoupon,
            product_opp_off_scheduledcoupon,
            product_opp_on_scheduledcoupon,
            product_opp_vending_offplc,
            product_opp_vending_onplc,
            product_opp_vending_revisitingcoupon,
            product_opp_vending_scheduledcoupon,
            product_opp_onmall,
            product_opp_oncart
        };
        insert productList;

        // 価格表エントリ作成
        // 標準価格表へ紐づけ
        // 2201加盟店ジャンボ
        PricebookEntry pbEntry_2201jambo_std = TestDataFactory.createPricebookEntry(product_opp_2201jambo.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_2201jambo_std.IsActive = true;
        // チラシ_入稿
        PricebookEntry pbEntry_flyerdraft_std = TestDataFactory.createPricebookEntry(product_opp_flyerdraft.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_flyerdraft_std.IsActive = true;
        // テストジャンボ
        PricebookEntry pbEntry_testjambo_std = TestDataFactory.createPricebookEntry(product_opp_testjambo.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_testjambo_std.IsActive = true;
        // 新サービス共通
        PricebookEntry pbEntry_servicecommon_std = TestDataFactory.createPricebookEntry(product_opp_servicecommon.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_servicecommon_std.IsActive = true;
        // オフライン
        PricebookEntry pbEntry_off_enp_std = TestDataFactory.createPricebookEntry(product_off_enp.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_off_enp_std.IsActive = true;
        // オフライン_SS切替
        PricebookEntry pbEntry_enpSS_std = TestDataFactory.createPricebookEntry(product_off_enpSS.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_enpSS_std.IsActive = true;
        // オフライン_中小_加盟店
        PricebookEntry pbEntry_off_enpSmall_std = TestDataFactory.createPricebookEntry(product_off_enpSmall.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_off_enpSmall_std.IsActive = true;
        // PayPayポイント
        PricebookEntry pbEntry_pppoint_std = TestDataFactory.createPricebookEntry(product_opp_pppoint.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_pppoint_std.IsActive = true;
        // 【集約】個社キャンペーン（ジャンボ）加盟店
        PricebookEntry pbEntry_indivcamp_jambo_std = TestDataFactory.createPricebookEntry(product_opp_indivcamp_jambo.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_indivcamp_jambo_std.IsActive = true;
        // 【集約】個社キャンペーン（総付け）加盟店
        PricebookEntry pbEntry_indivcamp_all_std = TestDataFactory.createPricebookEntry(product_opp_indivcamp_all.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_indivcamp_all_std.IsActive = true;
        // オフライン_PLC
        PricebookEntry pbEntry_offplc_std = TestDataFactory.createPricebookEntry(product_opp_offplc.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_offplc_std.IsActive = true;
        // スタンプカード
        PricebookEntry pbEntry_stamp_std = TestDataFactory.createPricebookEntry(product_opp_stamp.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_stamp_std.IsActive = true;
        // 再来店クーポン
        PricebookEntry pbEntry_revisitingcoupon_std = TestDataFactory.createPricebookEntry(product_opp_revisitingcoupon.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_revisitingcoupon_std.IsActive = true;
        // 日時指定クーポン
        PricebookEntry pbEntry_scheduledcoupon_std = TestDataFactory.createPricebookEntry(product_opp_scheduledcoupon.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_scheduledcoupon_std.IsActive = true;
        // オンライン
        PricebookEntry pbEntry_on_enp_std = TestDataFactory.createPricebookEntry(product_on_enp.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_on_enp_std.IsActive = true;
        // オンライン_中小_加盟店
        PricebookEntry pbEntry_on_enpSmall_std = TestDataFactory.createPricebookEntry(product_on_enpSmall.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_on_enpSmall_std.IsActive = true;
        // オンライン_PLC
        PricebookEntry pbEntry_onplc_std = TestDataFactory.createPricebookEntry(product_opp_onplc.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_onplc_std.IsActive = true;
        // オンライン_モール/カート
        PricebookEntry pbEntry_onmallcart_std = TestDataFactory.createPricebookEntry(product_opp_onmallcart.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_onmallcart_std.IsActive = true;
        // オンライン_自動機
        PricebookEntry pbEntry_vending_std = TestDataFactory.createPricebookEntry(product_vending.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_vending_std.IsActive = true;
        // 商品特定クーポン
        PricebookEntry pbEntry_specificCoupon_std = TestDataFactory.createPricebookEntry(product_specificCoupon.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_specificCoupon_std.IsActive = true;
        // 残高API
        PricebookEntry pbEntry_balanceAPI_std = TestDataFactory.createPricebookEntry(product_balanceAPI.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_balanceAPI_std.IsActive = true;
        // オフライン_GW
        PricebookEntry pbEntry_GW_std = TestDataFactory.createPricebookEntry(product_GW.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_GW_std.IsActive = true;
        // オンライン_PSP
        PricebookEntry pbEntry_PSP_std = TestDataFactory.createPricebookEntry(product_PSP.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_PSP_std.IsActive = true;
        // マイストア
        PricebookEntry pbEntry_myStore_std = TestDataFactory.createPricebookEntry(product_myStore.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_myStore_std.IsActive = true;
        // マイストア（大手営業管理）
        PricebookEntry pbEntry_myStore_enpr_std = TestDataFactory.createPricebookEntry(product_myStore_enpr.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_myStore_enpr_std.IsActive = true;
        // 【Offline】PPポイント加盟店
        PricebookEntry pbEntry_off_pppoint_std = TestDataFactory.createPricebookEntry(product_opp_off_pppoint.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_off_pppoint_std.IsActive = true;
        // 【Online】PPポイント加盟店
        PricebookEntry pbEntry_on_pppoint_std = TestDataFactory.createPricebookEntry(product_opp_on_pppoint.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_on_pppoint_std.IsActive = true;
        // 【集約】【Offline】個社キャンペーン（ジャンボ）加盟店
        PricebookEntry pbEntry_off_indivcamp_jambo_std = TestDataFactory.createPricebookEntry(product_opp_off_indivcamp_jambo.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_off_indivcamp_jambo_std.IsActive = true;
        // 【集約】【Offline】個社キャンペーン（総付け）加盟店
        PricebookEntry pbEntry_off_indivcamp_all_std = TestDataFactory.createPricebookEntry(product_opp_off_indivcamp_all.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_off_indivcamp_all_std.IsActive = true;
        // 【集約】【Online】個社キャンペーン（ジャンボ）加盟店
        PricebookEntry pbEntry_on_indivcamp_jambo_std = TestDataFactory.createPricebookEntry(product_opp_on_indivcamp_jambo.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_on_indivcamp_jambo_std.IsActive = true;
        // 【集約】【Online】個社キャンペーン（総付け）加盟店
        PricebookEntry pbEntry_on_indivcamp_all_std = TestDataFactory.createPricebookEntry(product_opp_on_indivcamp_all.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_on_indivcamp_all_std.IsActive = true;
        // 【Offline】スタンプ
        PricebookEntry pbEntry_off_stamp_std = TestDataFactory.createPricebookEntry(product_opp_off_stamp.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_off_stamp_std.IsActive = true;
        // 【Online】スタンプ
        PricebookEntry pbEntry_on_stamp_std = TestDataFactory.createPricebookEntry(product_opp_on_stamp.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_on_stamp_std.IsActive = true;
        // 【Offline】再来店クーポン
        PricebookEntry pbEntry_off_revisitingcoupon_std = TestDataFactory.createPricebookEntry(product_opp_off_revisitingcoupon.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_off_revisitingcoupon_std.IsActive = true;
        // 【Online】再来店クーポン
        PricebookEntry pbEntry_on_revisitingcoupon_std = TestDataFactory.createPricebookEntry(product_opp_on_revisitingcoupon.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_on_revisitingcoupon_std.IsActive = true;
        // 【Offline】日時指定クーポン
        PricebookEntry pbEntry_off_scheduledcoupon_std = TestDataFactory.createPricebookEntry(product_opp_off_scheduledcoupon.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_off_scheduledcoupon_std.IsActive = true;
        // 【Online】日時指定クーポン
        PricebookEntry pbEntry_on_scheduledcoupon_std = TestDataFactory.createPricebookEntry(product_opp_on_scheduledcoupon.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_on_scheduledcoupon_std.IsActive = true;
        // 【自動機】オフラインPLC
        PricebookEntry pbEntry_vending_offplc_std = TestDataFactory.createPricebookEntry(product_opp_vending_offplc.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_vending_offplc_std.IsActive = true;
        // 【自動機】オンラインPLC
        PricebookEntry pbEntry_vending_onplc_std = TestDataFactory.createPricebookEntry(product_opp_vending_onplc.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_vending_onplc_std.IsActive = true;
        // 【自動機】再来店クーポン
        PricebookEntry pbEntry_vending_revisitingcoupon_std = TestDataFactory.createPricebookEntry(product_opp_vending_revisitingcoupon.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_vending_revisitingcoupon_std.IsActive = true;
        // 【自動機】日時指定クーポン
        PricebookEntry pbEntry_vending_scheduledcoupon_std = TestDataFactory.createPricebookEntry(product_opp_vending_scheduledcoupon.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_vending_scheduledcoupon_std.IsActive = true;
        // オンライン_モール
        PricebookEntry pbEntry_onmall_std = TestDataFactory.createPricebookEntry(product_opp_onmall.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_onmall_std.IsActive = true;
        // オンライン_カート
        PricebookEntry pbEntry_oncart_std = TestDataFactory.createPricebookEntry(product_opp_oncart.Id, Test.getStandardPricebookId(), 0, false);
        pbEntry_oncart_std.IsActive = true;

        List<PricebookEntry> pbEntryList_std = new List<PricebookEntry>{
            pbEntry_2201jambo_std,
            pbEntry_flyerdraft_std,
            pbEntry_testjambo_std,
            pbEntry_servicecommon_std,
            pbEntry_off_enp_std,
            pbEntry_enpSS_std,
            pbEntry_off_enpSmall_std,
            pbEntry_pppoint_std,
            pbEntry_indivcamp_jambo_std,
            pbEntry_indivcamp_all_std,
            pbEntry_offplc_std,
            pbEntry_stamp_std,
            pbEntry_revisitingcoupon_std,
            pbEntry_scheduledcoupon_std,
            pbEntry_on_enp_std,
            pbEntry_on_enpSmall_std,
            pbEntry_onplc_std,
            pbEntry_onmallcart_std,
            pbEntry_vending_std,
            pbEntry_specificCoupon_std,
            pbEntry_balanceAPI_std,
            pbEntry_GW_std,
            pbEntry_PSP_std,
            pbEntry_myStore_std,
            pbEntry_myStore_enpr_std,
            pbEntry_off_pppoint_std,
            pbEntry_on_pppoint_std,
            pbEntry_off_indivcamp_jambo_std,
            pbEntry_off_indivcamp_all_std,
            pbEntry_on_indivcamp_jambo_std,
            pbEntry_on_indivcamp_all_std,
            pbEntry_off_stamp_std,
            pbEntry_on_stamp_std,
            pbEntry_off_revisitingcoupon_std,
            pbEntry_on_revisitingcoupon_std,
            pbEntry_off_scheduledcoupon_std,
            pbEntry_on_scheduledcoupon_std,
            pbEntry_vending_offplc_std,
            pbEntry_vending_onplc_std,
            pbEntry_vending_revisitingcoupon_std,
            pbEntry_vending_scheduledcoupon_std,
            pbEntry_onmall_std,
            pbEntry_oncart_std
        };
        insert pbEntryList_std;

        // 価格表エントリ作成
        // カスタム価格表へ紐づけ
        // エンプラ_オフラインに紐づけ
        // オフライン
        PricebookEntry pbEntry_off_enp_cst = TestDataFactory.createPricebookEntry(product_off_enp.Id, pb_off_enp.Id, 0, false);
        pbEntry_off_enp_cst.IsActive = true;
        // 【Offline】PPポイント加盟店
        PricebookEntry pbEntry_off_pppoint_cst = TestDataFactory.createPricebookEntry(product_opp_off_pppoint.Id, pb_off_enp.Id, 0, false);
        pbEntry_off_pppoint_cst.IsActive = true;
        // 【集約】【Offline】個社キャンペーン（ジャンボ）
        PricebookEntry pbEntry_off_indivcamp_jambo_cst = TestDataFactory.createPricebookEntry(product_opp_off_indivcamp_jambo.Id, pb_off_enp.Id, 0, false);
        pbEntry_off_indivcamp_jambo_cst.IsActive = true;
        // 【集約】【Offline】個社キャンペーン（総付け）
        PricebookEntry pbEntry_off_indivcamp_all_cst = TestDataFactory.createPricebookEntry(product_opp_off_indivcamp_all.Id, pb_off_enp.Id, 0, false);
        pbEntry_off_indivcamp_all_cst.IsActive = true;
        // オフライン_PLC
        PricebookEntry pbEntry_offplc_cst = TestDataFactory.createPricebookEntry(product_opp_offplc.Id, pb_off_enp.Id, 0, false);
        pbEntry_offplc_cst.IsActive = true;
        // 【Offline】スタンプ
        PricebookEntry pbEntry_off_stamp_cst = TestDataFactory.createPricebookEntry(product_opp_off_stamp.Id, pb_off_enp.Id, 0, false);
        pbEntry_off_stamp_cst.IsActive = true;
        // 【Offline】再来店クーポン
        PricebookEntry pbEntry_off_revisitingcoupon_cst = TestDataFactory.createPricebookEntry(product_opp_off_revisitingcoupon.Id, pb_off_enp.Id, 0, false);
        pbEntry_off_revisitingcoupon_cst.IsActive = true;
        // 【Offline】日時指定クーポン
        PricebookEntry pbEntry_off_scheduledcoupon_cst = TestDataFactory.createPricebookEntry(product_opp_off_scheduledcoupon.Id, pb_off_enp.Id, 0, false);
        pbEntry_off_scheduledcoupon_cst.IsActive = true;
        // エンプラ_オンラインに紐づけ
        // オンライン
        PricebookEntry pbEntry_on_enp_cst = TestDataFactory.createPricebookEntry(product_on_enp.Id, pb_on_enp.Id, 0, false);
        pbEntry_on_enp_cst.IsActive = true;
        // 【Online】PPポイント加盟店
        PricebookEntry pbEntry_on_pppoint_cst = TestDataFactory.createPricebookEntry(product_opp_on_pppoint.Id, pb_on_enp.Id, 0, false);
        pbEntry_on_pppoint_cst.IsActive = true;
        // 【集約】【Online】個社キャンペーン（ジャンボ）加盟店
        PricebookEntry pbEntry_on_indivcamp_jambo_cst = TestDataFactory.createPricebookEntry(product_opp_on_indivcamp_jambo.Id, pb_on_enp.Id, 0, false);
        pbEntry_on_indivcamp_jambo_cst.IsActive = true;
        // 【集約】【Online】個社キャンペーン（総付け）加盟店
        PricebookEntry pbEntry_on_indivcamp_all_cst = TestDataFactory.createPricebookEntry(product_opp_on_indivcamp_all.Id, pb_on_enp.Id, 0, false);
        pbEntry_on_indivcamp_all_cst.IsActive = true;
        // オンライン_PLC
        PricebookEntry pbEntry_onplc_cst = TestDataFactory.createPricebookEntry(product_opp_onplc.Id, pb_on_enp.Id, 0, false);
        pbEntry_onplc_cst.IsActive = true;
        // オンライン_モール
        PricebookEntry pbEntry_onmall_cst = TestDataFactory.createPricebookEntry(product_opp_onmall.Id, pb_on_enp.Id, 0, false);
        pbEntry_onmall_cst.IsActive = true;
        // 【Online】スタンプ
        PricebookEntry pbEntry_on_stamp_cst = TestDataFactory.createPricebookEntry(product_opp_on_stamp.Id, pb_on_enp.Id, 0, false);
        pbEntry_on_stamp_cst.IsActive = true;
        // 【Online】再来店クーポン
        PricebookEntry pbEntry_on_revisitingcoupon_cst = TestDataFactory.createPricebookEntry(product_opp_on_revisitingcoupon.Id, pb_on_enp.Id, 0, false);
        pbEntry_on_revisitingcoupon_cst.IsActive = true;
        // 【Online】日時指定クーポン
        PricebookEntry pbEntry_on_scheduledcoupon_cst = TestDataFactory.createPricebookEntry(product_opp_on_scheduledcoupon.Id, pb_on_enp.Id, 0, false);
        pbEntry_on_scheduledcoupon_cst.IsActive = true;
        // エンプラ_自動機に紐づけ
        // オンライン_自動機
        PricebookEntry pbEntry_vending_cst = TestDataFactory.createPricebookEntry(product_vending.Id, pb_vending.Id, 0, false);
        pbEntry_vending_cst.IsActive = true;
        // 【自動機】オフラインPLC
        PricebookEntry pbEntry_vending_offplc_cst = TestDataFactory.createPricebookEntry(product_opp_vending_offplc.Id, pb_vending.Id, 0, false);
        pbEntry_vending_offplc_cst.IsActive = true;
        // 【自動機】オンラインPLC
        PricebookEntry pbEntry_vending_onplc_cst = TestDataFactory.createPricebookEntry(product_opp_vending_onplc.Id, pb_vending.Id, 0, false);
        pbEntry_vending_onplc_cst.IsActive = true;
        // 【自動機】再来店クーポン
        PricebookEntry pbEntry_vending_revisitingcoupon_cst = TestDataFactory.createPricebookEntry(product_opp_vending_revisitingcoupon.Id, pb_vending.Id, 0, false);
        pbEntry_vending_revisitingcoupon_cst.IsActive = true;
        // 【自動機】日時指定クーポン
        PricebookEntry pbEntry_vending_scheduledcoupon_cst = TestDataFactory.createPricebookEntry(product_opp_vending_scheduledcoupon.Id, pb_vending.Id, 0, false);
        pbEntry_vending_scheduledcoupon_cst.IsActive = true;
        // エンプラ_メーカーに紐づけ
        // 商品特定クーポン
        PricebookEntry pbEntry_specificCoupon_cst = TestDataFactory.createPricebookEntry(product_specificCoupon.Id, pb_maker.Id, 0, false);
        pbEntry_specificCoupon_cst.IsActive = true;
        // エンプラ_ポイント事業者に紐づけ
        // 残高API
        PricebookEntry pbEntry_balanceAPI_cst = TestDataFactory.createPricebookEntry(product_balanceAPI.Id, pb_pointOperator.Id, 0, false);
        pbEntry_balanceAPI_cst.IsActive = true;
        // エンプラ_GWに紐づけ
        // オフライン_GW
        PricebookEntry pbEntry_GW_cst = TestDataFactory.createPricebookEntry(product_GW.Id, pb_GW.Id, 0, false);
        pbEntry_GW_cst.IsActive = true;
        // エンプラ_PSPに紐づけ
        // オンライン_PSP
        PricebookEntry pbEntry_PSP_cst = TestDataFactory.createPricebookEntry(product_PSP.Id, pb_PSP.Id, 0, false);
        pbEntry_PSP_cst.IsActive = true;
        // オンライン_カート
        PricebookEntry pbEntry_oncart_cst = TestDataFactory.createPricebookEntry(product_opp_oncart.Id, pb_PSP.Id, 0, false);
        pbEntry_oncart_cst.IsActive = true;
        // エンプラ_マイストアに紐づけ
        // マイストア（大手営業管理）
        PricebookEntry pbEntry_myStore_cst = TestDataFactory.createPricebookEntry(product_myStore_enpr.Id, pb_myStore.Id, 0, false);
        pbEntry_myStore_cst.IsActive = true;

        List<PricebookEntry> pbEntryList_cst = new List<PricebookEntry>{
            pbEntry_off_enp_cst,
            pbEntry_off_pppoint_cst,
            pbEntry_off_indivcamp_jambo_cst,
            pbEntry_off_indivcamp_all_cst,
            pbEntry_offplc_cst,
            pbEntry_off_stamp_cst,
            pbEntry_off_revisitingcoupon_cst,
            pbEntry_off_scheduledcoupon_cst,
            pbEntry_on_enp_cst,
            pbEntry_on_pppoint_cst,
            pbEntry_on_indivcamp_jambo_cst,
            pbEntry_on_indivcamp_all_cst,
            pbEntry_onplc_cst,
            pbEntry_onmall_cst,
            pbEntry_on_stamp_cst,
            pbEntry_on_revisitingcoupon_cst,
            pbEntry_on_scheduledcoupon_cst,
            pbEntry_vending_cst,
            pbEntry_vending_offplc_cst,
            pbEntry_vending_onplc_cst,
            pbEntry_vending_revisitingcoupon_cst,
            pbEntry_vending_scheduledcoupon_cst,
            pbEntry_specificCoupon_cst,
            pbEntry_balanceAPI_cst,
            pbEntry_GW_cst,
            pbEntry_PSP_cst,
            pbEntry_oncart_cst,
            pbEntry_myStore_cst
        };
        insert pbEntryList_cst;

        // サービス情報作成(標準価格表サービス)
        // 2201加盟店ジャンボ
        OpportunityLineItem opLineItemStdMerchantJambo = TestDataFactory.createOpportunityLineItem(opp_2201jambo.Id, product_opp_2201jambo.Id, 1, 0, false);
        opLineItemStdMerchantJambo.PricebookEntryId = pbEntry_2201jambo_std.Id;
        opLineItemStdMerchantJambo.ForRelatedOrderProgressId__c = 'false';
        // チラシ_入稿
        OpportunityLineItem opLineItemStdFlyerDraft = TestDataFactory.createOpportunityLineItem(opp_flyerdraft.Id, product_opp_flyerdraft.Id, 1, 0, false);
        opLineItemStdFlyerDraft.PricebookEntryId = pbEntry_flyerdraft_std.Id;
        opLineItemStdFlyerDraft.ForRelatedOrderProgressId__c = 'false';
        // テストジャンボ
        OpportunityLineItem opLineItemStdTestJambo = TestDataFactory.createOpportunityLineItem(opp_testjambo.Id, product_opp_testjambo.Id, 1, 0, false);
        opLineItemStdTestJambo.PricebookEntryId = pbEntry_testjambo_std.Id;
        opLineItemStdTestJambo.ForRelatedOrderProgressId__c = 'false';
        // 新サービス共通
        OpportunityLineItem opLineItemStdServiceCommon = TestDataFactory.createOpportunityLineItem(opp_servicecommon.Id, product_opp_servicecommon.Id, 1, 0, false);
        opLineItemStdServiceCommon.PricebookEntryId = pbEntry_servicecommon_std.Id;
        opLineItemStdServiceCommon.ForRelatedOrderProgressId__c = 'false';
        // オフライン
        OpportunityLineItem opLineItemStdOffline = TestDataFactory.createOpportunityLineItem(opp_off_enp.Id, product_off_enp.Id, 1, 0, false);
        opLineItemStdOffline.PricebookEntryId = pbEntry_off_enp_std.Id;
        opLineItemStdOffline.ForRelatedOrderProgressId__c = 'false';
        // オフライン_SS切替
        OpportunityLineItem opLineItemStdOfflineSS = TestDataFactory.createOpportunityLineItem(opp_off_enpSS.Id, product_off_enpSS.Id, 1, 0, false);
        opLineItemStdOfflineSS.PricebookEntryId = pbEntry_enpSS_std.Id;
        opLineItemStdOfflineSS.ForRelatedOrderProgressId__c = 'false';
        // オフライン_中小_加盟店
        OpportunityLineItem opLineItemStdOfflineSmall = TestDataFactory.createOpportunityLineItem(opp_off_enpSmall.Id, product_off_enpSmall.Id, 1, 0, false);
        opLineItemStdOfflineSmall.PricebookEntryId = pbEntry_off_enpSmall_std.Id;
        opLineItemStdOfflineSmall.ForRelatedOrderProgressId__c = 'false';
        // PayPayポイント(Offline)
        OpportunityLineItem opLineItemStdOfflinePoint = TestDataFactory.createOpportunityLineItem(opp_off_pppoint.Id, product_opp_pppoint.Id, 1, 0, false);
        opLineItemStdOfflinePoint.PricebookEntryId = pbEntry_pppoint_std.Id;
        opLineItemStdOfflinePoint.ForRelatedOrderProgressId__c = 'false';
        // 【集約】個社キャンペーン（ジャンボ）加盟店(Offline)
        OpportunityLineItem opLineItemStdCampaignOfflineJambo = TestDataFactory.createOpportunityLineItem(opp_off_indivcamp_jambo.Id, product_opp_indivcamp_jambo.Id, 1, 0, false);
        opLineItemStdCampaignOfflineJambo.PricebookEntryId = pbEntry_indivcamp_jambo_std.Id;
        opLineItemStdCampaignOfflineJambo.ForRelatedOrderProgressId__c = 'false';
        // 【集約】個社キャンペーン（総付け）加盟店(Offline)
        OpportunityLineItem opLineItemStdCampaignOfflineGrant = TestDataFactory.createOpportunityLineItem(opp_off_indivcamp_all.Id, product_opp_indivcamp_all.Id, 1, 0, false);
        opLineItemStdCampaignOfflineGrant.PricebookEntryId = pbEntry_indivcamp_all_std.Id;
        opLineItemStdCampaignOfflineGrant.ForRelatedOrderProgressId__c = 'false';
        // オフライン_PLC
        OpportunityLineItem opLineItemStdOfflinePLC = TestDataFactory.createOpportunityLineItem(opp_offplc.Id, product_opp_offplc.Id, 1, 0, false);
        opLineItemStdOfflinePLC.PricebookEntryId = pbEntry_offplc_std.Id;
        opLineItemStdOfflinePLC.ForRelatedOrderProgressId__c = 'false';
        // スタンプカード(Offline)
        OpportunityLineItem opLineItemStdOfflineStamp = TestDataFactory.createOpportunityLineItem(opp_off_stamp.Id, product_opp_stamp.Id, 1, 0, false);
        opLineItemStdOfflineStamp.PricebookEntryId = pbEntry_stamp_std.Id;
        opLineItemStdOfflineStamp.ForRelatedOrderProgressId__c = 'false';
        // 再来店クーポン(Offline)
        OpportunityLineItem opLineItemStdOfflineRevisit = TestDataFactory.createOpportunityLineItem(opp_off_revisitingcoupon.Id, product_opp_revisitingcoupon.Id, 1, 0, false);
        opLineItemStdOfflineRevisit.PricebookEntryId = pbEntry_revisitingcoupon_std.Id;
        opLineItemStdOfflineRevisit.ForRelatedOrderProgressId__c = 'false';
        // 日時指定クーポン(Offline)
        OpportunityLineItem opLineItemStdOfflineSchaduled = TestDataFactory.createOpportunityLineItem(opp_off_scheduledcoupon.Id, product_opp_scheduledcoupon.Id, 1, 0, false);
        opLineItemStdOfflineSchaduled.PricebookEntryId = pbEntry_scheduledcoupon_std.Id;
        opLineItemStdOfflineSchaduled.ForRelatedOrderProgressId__c = 'false';
        // オンライン
        OpportunityLineItem opLineItemStdOnline = TestDataFactory.createOpportunityLineItem(opp_on_enp.Id, product_on_enp.Id, 1, 0, false);
        opLineItemStdOnline.PricebookEntryId = pbEntry_on_enp_std.Id;
        opLineItemStdOnline.ForRelatedOrderProgressId__c = 'false';
        // オンライン_中小_加盟店
        OpportunityLineItem opLineItemStdOnlineSmall = TestDataFactory.createOpportunityLineItem(opp_on_enpSmall.Id, product_on_enpSmall.Id, 1, 0, false);
        opLineItemStdOnlineSmall.PricebookEntryId = pbEntry_on_enpSmall_std.Id;
        opLineItemStdOnlineSmall.ForRelatedOrderProgressId__c = 'false';
        // PayPayポイント(Online)
        OpportunityLineItem opLineItemStdOnlinePoint = TestDataFactory.createOpportunityLineItem(opp_on_pppoint.Id, product_opp_pppoint.Id, 1, 0, false);
        opLineItemStdOnlinePoint.PricebookEntryId = pbEntry_pppoint_std.Id;
        opLineItemStdOnlinePoint.ForRelatedOrderProgressId__c = 'false';
        // 【集約】個社キャンペーン（ジャンボ）加盟店(Online)
        OpportunityLineItem opLineItemStdCampaignOnlineJambo = TestDataFactory.createOpportunityLineItem(opp_on_indivcamp_jambo.Id, product_opp_indivcamp_jambo.Id, 1, 0, false);
        opLineItemStdCampaignOnlineJambo.PricebookEntryId = pbEntry_indivcamp_jambo_std.Id;
        opLineItemStdCampaignOnlineJambo.ForRelatedOrderProgressId__c = 'false';
        // 【集約】個社キャンペーン（総付け）加盟店(Online)
        OpportunityLineItem opLineItemStdCampaignOnlineGrant = TestDataFactory.createOpportunityLineItem(opp_on_indivcamp_all.Id, product_opp_indivcamp_all.Id, 1, 0, false);
        opLineItemStdCampaignOnlineGrant.PricebookEntryId = pbEntry_indivcamp_all_std.Id;
        opLineItemStdCampaignOnlineGrant.ForRelatedOrderProgressId__c = 'false';
        // オンライン_PLC
        OpportunityLineItem opLineItemStdOnlinePLC = TestDataFactory.createOpportunityLineItem(opp_onplc.Id, product_opp_onplc.Id, 1, 0, false);
        opLineItemStdOnlinePLC.PricebookEntryId = pbEntry_onplc_std.Id;
        opLineItemStdOnlinePLC.ForRelatedOrderProgressId__c = 'false';
        // オンライン_モール/カート(モール)
        OpportunityLineItem opLineItemStdOnlineMall = TestDataFactory.createOpportunityLineItem(opp_onmall.Id, product_opp_onmallcart.Id, 1, 0, false);
        opLineItemStdOnlineMall.PricebookEntryId = pbEntry_onmallcart_std.Id;
        opLineItemStdOnlineMall.ForRelatedOrderProgressId__c = 'false';
        // スタンプカード(Online)
        OpportunityLineItem opLineItemStdOnlineStamp = TestDataFactory.createOpportunityLineItem(opp_on_stamp.Id, product_opp_stamp.Id, 1, 0, false);
        opLineItemStdOnlineStamp.PricebookEntryId = pbEntry_stamp_std.Id;
        opLineItemStdOnlineStamp.ForRelatedOrderProgressId__c = 'false';
        // 再来店クーポン(Online)
        OpportunityLineItem opLineItemStdOnlineRevisit = TestDataFactory.createOpportunityLineItem(opp_on_revisitingcoupon.Id, product_opp_revisitingcoupon.Id, 1, 0, false);
        opLineItemStdOnlineRevisit.PricebookEntryId = pbEntry_revisitingcoupon_std.Id;
        opLineItemStdOnlineRevisit.ForRelatedOrderProgressId__c = 'false';
        // 日時指定クーポン(Online)
        OpportunityLineItem opLineItemStdOnlineSchaduled = TestDataFactory.createOpportunityLineItem(opp_on_scheduledcoupon.Id, product_opp_on_scheduledcoupon.Id, 1, 0, false);
        opLineItemStdOnlineSchaduled.PricebookEntryId = pbEntry_on_scheduledcoupon_std.Id;
        opLineItemStdOnlineSchaduled.ForRelatedOrderProgressId__c = 'false';
        // オンライン自動機
        OpportunityLineItem opLineItemStdVending = TestDataFactory.createOpportunityLineItem(opp_vending.Id, product_vending.Id, 1, 0, false);
        opLineItemStdVending.PricebookEntryId = pbEntry_vending_std.Id;
        opLineItemStdVending.ForRelatedOrderProgressId__c = 'false';
        // オフラインPLC(自動機)
        OpportunityLineItem opLineItemStdVendingOffPLC = TestDataFactory.createOpportunityLineItem(opp_vending_offplc.Id, product_opp_offplc.Id, 1, 0, false);
        opLineItemStdVendingOffPLC.PricebookEntryId = pbEntry_offplc_std.Id;
        opLineItemStdVendingOffPLC.ForRelatedOrderProgressId__c = 'false';
        // オンラインPLC(自動機)
        OpportunityLineItem opLineItemStdVendingOnPLC = TestDataFactory.createOpportunityLineItem(opp_vending_onplc.Id, product_opp_onplc.Id, 1, 0, false);
        opLineItemStdVendingOnPLC.PricebookEntryId = pbEntry_onplc_std.Id;
        opLineItemStdVendingOnPLC.ForRelatedOrderProgressId__c = 'false';
        // 再来店クーポン(自動機)
        OpportunityLineItem opLineItemStdVendingRevisit = TestDataFactory.createOpportunityLineItem(opp_vending_revisitingcoupon.Id, product_opp_revisitingcoupon.Id, 1, 0, false);
        opLineItemStdVendingRevisit.PricebookEntryId = pbEntry_revisitingcoupon_std.Id;
        opLineItemStdVendingRevisit.ForRelatedOrderProgressId__c = 'false';
        // 日時指定クーポン(自動機)
        OpportunityLineItem opLineItemStdVendingSchaduled = TestDataFactory.createOpportunityLineItem(opp_vending_scheduledcoupon.Id, product_opp_scheduledcoupon.Id, 1, 0, false);
        opLineItemStdVendingSchaduled.PricebookEntryId = pbEntry_scheduledcoupon_std.Id;
        opLineItemStdVendingSchaduled.ForRelatedOrderProgressId__c = 'false';
        // 商品特定クーポン
        OpportunityLineItem opLineItemStdSKU = TestDataFactory.createOpportunityLineItem(opp_specificCoupon.Id, product_specificCoupon.Id, 1, 0, false);
        opLineItemStdSKU.PricebookEntryId = pbEntry_specificCoupon_std.Id;
        opLineItemStdSKU.ForRelatedOrderProgressId__c = 'false';
        // 残高API
        OpportunityLineItem opLineItemStdBalanceAPI = TestDataFactory.createOpportunityLineItem(opp_balanceAPI.Id, product_balanceAPI.Id, 1, 0, false);
        opLineItemStdBalanceAPI.PricebookEntryId = pbEntry_balanceAPI_std.Id;
        opLineItemStdBalanceAPI.ForRelatedOrderProgressId__c = 'false';
        // オフライン_GW
        OpportunityLineItem opLineItemStdOffGW = TestDataFactory.createOpportunityLineItem(opp_GW.Id, product_GW.Id, 1, 0, false);
        opLineItemStdOffGW.PricebookEntryId = pbEntry_GW_std.Id;
        opLineItemStdOffGW.ForRelatedOrderProgressId__c = 'false';
        // オンライン_PSP
        OpportunityLineItem opLineItemStdOnPSP = TestDataFactory.createOpportunityLineItem(opp_PSP.Id, product_PSP.Id, 1, 0, false);
        opLineItemStdOnPSP.PricebookEntryId = pbEntry_PSP_std.Id;
        opLineItemStdOnPSP.ForRelatedOrderProgressId__c = 'false';
        // オンライン_モール/カート(カート)
        OpportunityLineItem opLineItemStdOnlineCart = TestDataFactory.createOpportunityLineItem(opp_oncart.Id, product_opp_onmallcart.Id, 1, 0, false);
        opLineItemStdOnlineCart.PricebookEntryId = pbEntry_onmallcart_std.Id;
        opLineItemStdOnlineCart.ForRelatedOrderProgressId__c = 'false';
        // マイストア（大手営業管理）
        OpportunityLineItem opLineItemStdMyStoreEnpr = TestDataFactory.createOpportunityLineItem(opp_myStore.Id, product_myStore.Id, 1, 0, false);
        opLineItemStdMyStoreEnpr.PricebookEntryId = pbEntry_myStore_std.Id;
        opLineItemStdMyStoreEnpr.ForRelatedOrderProgressId__c = 'false';

        List<OpportunityLineItem> opLineItemListStd = new List<OpportunityLineItem>{
            opLineItemStdMerchantJambo,
            opLineItemStdFlyerDraft,
            opLineItemStdTestJambo,
            opLineItemStdServiceCommon,
            opLineItemStdOffline,
            opLineItemStdOfflineSS,
            opLineItemStdOfflineSmall,
            opLineItemStdOfflinePoint,
            opLineItemStdCampaignOfflineJambo,
            opLineItemStdCampaignOfflineGrant,
            opLineItemStdOfflinePLC,
            opLineItemStdOfflineStamp,
            opLineItemStdOfflineRevisit,
            opLineItemStdOfflineSchaduled,
            opLineItemStdOnline,
            opLineItemStdOnlineSmall,
            opLineItemStdOnlinePoint,
            opLineItemStdCampaignOnlineJambo,
            opLineItemStdCampaignOnlineGrant,
            opLineItemStdOnlinePLC,
            opLineItemStdOnlineMall,
            opLineItemStdOnlineStamp,
            opLineItemStdOnlineRevisit,
            opLineItemStdOnlineSchaduled,
            opLineItemStdVending,
            opLineItemStdVendingOffPLC,
            opLineItemStdVendingOnPLC,
            opLineItemStdVendingRevisit,
            opLineItemStdVendingSchaduled,
            opLineItemStdSKU,
            opLineItemStdBalanceAPI,
            opLineItemStdOffGW,
            opLineItemStdOnPSP,
            opLineItemStdOnlineCart,
            opLineItemStdMyStoreEnpr
        };
        insert opLineItemListStd;
    }

    @isTest
    private static void test_CRMDPConvertPricebookAndProductBatch_success() {
        // 価格表を取得し、価格表IDをセットする
        Id PRICEBOOK2ID_STANDARD = Test.getStandardPricebookId(); // 標準価格表
        Id PRICEBOOK2ID_OFFLINE_ENP; // エンプラ_オフライン
        Id PRICEBOOK2ID_ONLINE_ENP; // エンプラ_オンライン
        Id PRICEBOOK2ID_VENDING; // エンプラ_自動機
        Id PRICEBOOK2ID_MAKER; // エンプラ_メーカー
        Id PRICEBOOK2ID_POINTOPERATOR; // エンプラ_ポイント事業者
        Id PRICEBOOK2ID_GW; // エンプラ_GW
        Id PRICEBOOK2ID_PSP; // エンプラ_PSP
        Id PRICEBOOK2ID_MYSTORE; // エンプラ_マイストア
        for (Pricebook2 pb : [SELECT Id, Name FROM Pricebook2]){
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_OFFLINE)) PRICEBOOK2ID_OFFLINE_ENP = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_ONLINE)) PRICEBOOK2ID_ONLINE_ENP = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_VENDING)) PRICEBOOK2ID_VENDING = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_MAKER)) PRICEBOOK2ID_MAKER = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_POINT)) PRICEBOOK2ID_POINTOPERATOR = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_GW)) PRICEBOOK2ID_GW = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_PSP)) PRICEBOOK2ID_PSP = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_MYSTORE)) PRICEBOOK2ID_MYSTORE = pb.Id;
        }

        // バッチ実行前の案件取得
        // 標準価格表が紐づいていることを確認
        for (Opportunity opp : [SELECT Id, Name,Pricebook2Id FROM Opportunity]){
            System.assertEquals(PRICEBOOK2ID_STANDARD, opp.Pricebook2Id);
        }

        Test.startTest();
        CRMDPConvertPricebookAndProductBatch.run();
        Test.stopTest();

        // バッチ実行後の案件取得
        // 案件に紐づく価格表とサービスが適切に移管されていることを確認
        for (Opportunity opp : [
            SELECT p.Id, p.Name, p.Pricebook2Id, p.SummaryProduct2Name__c,
                (SELECT c.Id, c.name, c.PricebookEntry.Product2.Name FROM OpportunityLineItems c) FROM Opportunity p]
            ){
            for (OpportunityLineItem c: opp.OpportunityLineItems) {
                // 標準価格表のまま
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_2201加盟店ジャンボ')) {
                    System.assertEquals(PRICEBOOK2ID_STANDARD, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals('2201加盟店ジャンボ', c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals('2201加盟店ジャンボ', opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_チラシ_入稿')){
                    System.assertEquals(PRICEBOOK2ID_STANDARD, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals('チラシ_入稿', c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals('チラシ_入稿', opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_テストジャンボ')){
                    System.assertEquals(PRICEBOOK2ID_STANDARD, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals('テストジャンボ', c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals('テストジャンボ', opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_新サービス共通')){
                    System.assertEquals(PRICEBOOK2ID_STANDARD, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals('新サービス共通', c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals('新サービス共通', opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オフラインスタンプカード')){
                    System.assertEquals(PRICEBOOK2ID_STANDARD, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals('スタンプカード', c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals('スタンプカード', opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オフライン再来店クーポン')){
                    System.assertEquals(PRICEBOOK2ID_STANDARD, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals('再来店クーポン', c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals('再来店クーポン', opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }

                // エンプラ_オフライン
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オフライン')){
                    System.assertEquals(PRICEBOOK2ID_OFFLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オフラインSS切替')){
                    System.assertEquals(PRICEBOOK2ID_OFFLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オフライン中小')){
                    System.assertEquals(PRICEBOOK2ID_OFFLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オフラインPayPayポイント')){
                    System.assertEquals(PRICEBOOK2ID_OFFLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_POINT, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_POINT, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オフライン【集約】個社キャンペーン（ジャンボ）加盟店')){
                    System.assertEquals(PRICEBOOK2ID_OFFLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_CAMPAIGN_JAMBO, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_CAMPAIGN_JAMBO, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オフライン【集約】個社キャンペーン（総付け）加盟店')){
                    System.assertEquals(PRICEBOOK2ID_OFFLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_CAMPAIGN_GRANT, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_CAMPAIGN_GRANT, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オフラインPLC')){
                    System.assertEquals(PRICEBOOK2ID_OFFLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_PLC, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_PLC, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オフライン日時指定クーポン')){
                    System.assertEquals(PRICEBOOK2ID_OFFLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_SCHEDULED, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_SCHEDULED, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                // エンプラ_オンライン
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オンライン')){
                    System.assertEquals(PRICEBOOK2ID_ONLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ONLINE, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ONLINE, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オンライン中小')){
                    System.assertEquals(PRICEBOOK2ID_ONLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ONLINE, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ONLINE, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オンラインPPポイント加盟店')){
                    System.assertEquals(PRICEBOOK2ID_ONLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_POINT, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_POINT, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オンライン【集約】個社キャンペーン（ジャンボ）加盟店')){
                    System.assertEquals(PRICEBOOK2ID_ONLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_CAMPAIGN_JAMBO, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_CAMPAIGN_JAMBO, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オンライン【集約】個社キャンペーン（総付け）加盟店')){
                    System.assertEquals(PRICEBOOK2ID_ONLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_CAMPAIGN_GRANT, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_CAMPAIGN_GRANT, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オンラインPLC')){
                    System.assertEquals(PRICEBOOK2ID_ONLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_PLC, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_PLC, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オンモール')){
                    System.assertEquals(PRICEBOOK2ID_ONLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_MALL, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_MALL, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オンライン日時指定クーポン')){
                    System.assertEquals(PRICEBOOK2ID_ONLINE_ENP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_SCHEDULED, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_SCHEDULED, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                // エンプラ_自動機
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オンライン自動機')){
                    System.assertEquals(PRICEBOOK2ID_VENDING, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_【自動機】オフラインPLC')){
                    System.assertEquals(PRICEBOOK2ID_VENDING, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_OFFPLC, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_OFFPLC, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_【自動機】オンラインPLC')){
                    System.assertEquals(PRICEBOOK2ID_VENDING, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_ONPLC, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_ONPLC, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                // エンプラ_メーカー
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_商品特定クーポン')){
                    System.assertEquals(PRICEBOOK2ID_MAKER, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_MAKER_SKU, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_MAKER_SKU, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                // エンプラ_ポイント事業者
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_残高API')){
                    System.assertEquals(PRICEBOOK2ID_POINTOPERATOR, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_BALANCE_API, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_BALANCE_API, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                // エンプラ_GW
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_GW')){
                    System.assertEquals(PRICEBOOK2ID_GW, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_GW, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_GW, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                // エンプラ_PSP
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_PSP')){
                    System.assertEquals(PRICEBOOK2ID_PSP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_オンカート')){
                    System.assertEquals(PRICEBOOK2ID_PSP, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP_CART, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP_CART, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
                // エンプラ_マイストア
                if(opp.Name.equals('【価格表移行テスト企業】テスト案件_マイストア（大手営業管理）')){
                    System.assertEquals(PRICEBOOK2ID_MYSTORE, opp.Pricebook2Id, '価格表の紐づけが期待値と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_MYSTORE_ENPR, c.PricebookEntry.Product2.Name, 'サービス名が期待と異なります');
                    System.assertEquals(CRMDPPBookProd2NameUtil.CRMD_PROD2_MYSTORE_ENPR, opp.SummaryProduct2Name__c, '集約サービス名が異なります');
                }
            }
        }
    }

    // 案件に紐づくサービス管理のデータが欠如しているため
    // 移行先のサービスを特定できない
    @isTest
    private static void test_CRMDPConvertPricebookAndProductBatch_failure_lackInfo() {
        Id PRICEBOOK2ID_STANDARD = Test.getStandardPricebookId();
        // 取引先取得
        Account acc = [SELECT Id, OwnerId FROM Account WHERE Name = '価格表移行テスト企業' LIMIT 1];
        Opportunity testOpp = TestDataFactory.createOpportunity('テスト案件_サービス管理情報欠如', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        testOpp.OwnerId = acc.OwnerId;
        testOpp.Pricebook2Id = PRICEBOOK2ID_STANDARD;
        insert testOpp;

        // 価格表エントリ:PayPayポイント
        PricebookEntry pBookEntry = [SELECT Id, Product2Id FROM PricebookEntry WHERE Name = :CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_POINT AND Pricebook2Id = :PRICEBOOK2ID_STANDARD LIMIT 1];

        // サービス情報作成: PayPayポイント
        OpportunityLineItem opLineItemStdPoint = TestDataFactory.createOpportunityLineItem(testOpp.Id, pBookEntry.Product2Id, 1, 0, false);
        opLineItemStdPoint.PricebookEntryId = pBookEntry.Id;
        opLineItemStdPoint.ForRelatedOrderProgressId__c = 'false';
        insert opLineItemStdPoint;

        Test.startTest();
        CRMDPConvertPricebookAndProductBatch.run();
        Test.stopTest();

        // バッチ実行後の案件取得
        // データが欠如している案件の価格表データは移行前の標準のままとなっていることを確認
        Opportunity opp_res = [SELECT Id, Name, Pricebook2Id FROM Opportunity WHERE Id = :testOpp.Id LIMIT 1];
        System.assertEquals(PRICEBOOK2ID_STANDARD, opp_res.Pricebook2Id);

        // ログデータが作成されていることを確認
        String testLogTitle = CRMDPConvertPricebookAndProductBatch.BATCH_LOG_TITLE + CRMDPConvertPricebookAndProductBatch.COND_RELATECUSTOM_PRICEBOOK;
        // サービス管理更新失敗ログの確認
        List<Log__c> resultLog = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :testLogTitle
            AND Level__c = 'INFO'
        ];
        System.assertEquals(true, resultLog.size() > 0, '期待するログが作成されていません');
        System.assertEquals(true, resultLog[0].Detail__c.contains('更新するためのデータが欠如している案件件数: 1件'), '期待するログが作成されていません');
    }

    // 価格表削除時のエラーケース
    @isTest
    private static void test_CRMDPConvertPricebookAndProductBatch_failure_deletePricebook() {
        // 価格表を取得し、価格表IDをセットする
        Id PRICEBOOK2ID_STANDARD = Test.getStandardPricebookId(); // 標準価格表

        // 標準価格表の削除処理に失敗したケースの確認
        // バッチ実行前の案件取得
        for (Opportunity opp_res : [SELECT Id, Name,Pricebook2Id FROM Opportunity]){
            System.assertEquals(PRICEBOOK2ID_STANDARD, opp_res.Pricebook2Id);
        }

        // DMLExceptionを発生するようにフラグを更新する
        CRMDPConvertPricebookAndProductBatch.isDMLExceptionTest = true;
        CRMDPConvertPricebookAndProductBatch.errorExpected = CRMDPConvertPricebookAndProductBatch.COND_DELETE_PRICEBOOK;

        Test.startTest();
        CRMDPConvertPricebookAndProductBatch.run();
        Test.stopTest();

        // バッチ実行後の案件取得
        for (Opportunity opp_res : [SELECT Id, Name,Pricebook2Id FROM Opportunity]){
            System.assertEquals(PRICEBOOK2ID_STANDARD, opp_res.Pricebook2Id);
        }

        // ログデータが作成されていることを確認
        String testLogTitle = CRMDPConvertPricebookAndProductBatch.BATCH_LOG_TITLE + CRMDPConvertPricebookAndProductBatch.COND_DELETE_PRICEBOOK;

        // サービス管理更新失敗ログの確認
        List<Log__c> resultLog = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :testLogTitle
        ];
        System.assertEquals(true, resultLog.size() > 0, '期待するログが作成されていません');
    }

    // カスタム価格表の紐づけ後の更新時のエラー
    @isTest
    private static void test_CRMDPConvertPricebookAndProductBatch_failure_relateCustomPricebook() {
        // 価格表を取得し、価格表IDをセットする
        Id PRICEBOOK2ID_STANDARD = Test.getStandardPricebookId(); // 標準価格表

        // カスタム価格表の紐づけ処理に失敗したケースの確認
        // バッチ実行前の案件取得
        for (Opportunity opp_res : [SELECT Id, Name,Pricebook2Id FROM Opportunity]){
            System.assertEquals(PRICEBOOK2ID_STANDARD, opp_res.Pricebook2Id);
        }

        // DMLExceptionを発生するようにフラグを更新する
        CRMDPConvertPricebookAndProductBatch.isDMLExceptionTest = true;
        CRMDPConvertPricebookAndProductBatch.errorExpected = CRMDPConvertPricebookAndProductBatch.COND_RELATECUSTOM_PRICEBOOK;
        Test.startTest();
        CRMDPConvertPricebookAndProductBatch.run();
        Test.stopTest();

        // バッチ実行後の案件取得
        for (Opportunity opp_res : [SELECT Id, Name,Pricebook2Id FROM Opportunity]){
            System.assertEquals(PRICEBOOK2ID_STANDARD, opp_res.Pricebook2Id);
        }

        // ログデータが作成されていることを確認
        String testLogTitle = CRMDPConvertPricebookAndProductBatch.BATCH_LOG_TITLE + CRMDPConvertPricebookAndProductBatch.COND_RELATECUSTOM_PRICEBOOK;

        // サービス管理更新失敗ログの確認
        List<Log__c> resultLog = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :testLogTitle
        ];
        System.assertEquals(true, resultLog.size() > 0, '期待するログが作成されていません');
    }

    // サービス情報新規作成時のエラー
    @isTest
    private static void test_CRMDPConvertPricebookAndProductBatch_failure_insertOppLineItem() {
        // 価格表を取得し、価格表IDをセットする
        Id PRICEBOOK2ID_STANDARD = Test.getStandardPricebookId(); // 標準価格表

        // サービス情報作成処理に失敗したケースの確認
        // バッチ実行前の案件取得
        for (Opportunity opp_res : [SELECT Id, Name, Pricebook2Id FROM Opportunity]){
            System.assertEquals(PRICEBOOK2ID_STANDARD, opp_res.Pricebook2Id);
        }

        // DMLExceptionを発生するようにフラグを更新する
        CRMDPConvertPricebookAndProductBatch.isDMLExceptionTest = true;
        CRMDPConvertPricebookAndProductBatch.errorExpected = CRMDPConvertPricebookAndProductBatch.COND_INSERT_OPPLINEITEMLIST;

        Test.startTest();
        CRMDPConvertPricebookAndProductBatch.run();
        Test.stopTest();

        // バッチ実行後の案件取得
        for (Opportunity opp_res : [SELECT Id, Name,Pricebook2Id FROM Opportunity]){
            System.assertEquals(PRICEBOOK2ID_STANDARD, opp_res.Pricebook2Id);
        }

        // ログデータが作成されていることを確認
        String testLogTitle = CRMDPConvertPricebookAndProductBatch.BATCH_LOG_TITLE + CRMDPConvertPricebookAndProductBatch.COND_INSERT_OPPLINEITEMLIST;

        // サービス管理更新失敗ログの確認
        List<Log__c> resultLog = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :testLogTitle
        ];

        System.assertEquals(true, resultLog.size() > 0, '期待するログが作成されていません');
    }

    // サービス管理の項目「サービス情報」の更新時にエラー
    @isTest
    private static void test_CRMDPConvertPricebookAndProductBatch_failure_updateOrderProgress() {
        // 取引先取得
        Account acc = [SELECT Id, OwnerId FROM Account WHERE Name = '価格表移行テスト企業' LIMIT 1];
        // サービスが複数紐づく案件
        Opportunity testOpp = TestDataFactory.createOpportunity('テスト案件_サービス管理紐づけ', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        testOpp.OwnerId = acc.OwnerId;
        testOpp.Pricebook2Id = Test.getStandardPricebookId();
        testOpp.SummaryProduct2Name__c = '';
        // サービスを紐づけない案件
        Opportunity testOpp2 = TestDataFactory.createOpportunity('テスト案件_サービス管理紐づけ_2', acc.Id, Date.newInstance(2023, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE, false);
        testOpp2.OwnerId = acc.OwnerId;
        testOpp2.Pricebook2Id = Test.getStandardPricebookId();
        testOpp2.SummaryProduct2Name__c = '';
        insert new List<Opportunity>{testOpp, testOpp2};

        // 価格表エントリ:残高API
        PricebookEntry pBookEntry = [SELECT Id, Product2Id FROM PricebookEntry WHERE Name = '残高API' AND Pricebook2Id = :Test.getStandardPricebookId() LIMIT 1];

        // サービス情報作成: 残高API
        OpportunityLineItem opLineItemStdBalanceAPI = TestDataFactory.createOpportunityLineItem(testOpp.Id, pBookEntry.Product2Id, 1, 0, false);
        opLineItemStdBalanceAPI.PricebookEntryId = pBookEntry.Id;
        opLineItemStdBalanceAPI.ForRelatedOrderProgressId__c = 'false';
        insert opLineItemStdBalanceAPI;

        // サービス管理(決済事業)作成
        OrderProgress__c testOrderProgress = TestDataFactory.createOrderProgress('決済事業_残高API', acc.Id, testOpp.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_BALANCEAPI), false);
        testOrderProgress.OwnerId = acc.OwnerId;
        insert testOrderProgress;

        // サービス管理(決済事業)2作成
        OrderProgress__c testOrderProgress2 = TestDataFactory.createOrderProgress('決済事業_残高API2', acc.Id, testOpp.Id, mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'BalanceAPI'), false);
        testOrderProgress2.OwnerId = acc.OwnerId;
        insert testOrderProgress2;

        // DMLExceptionを発生するようにフラグを更新する
        CRMDPConvertPricebookAndProductBatch.isDMLExceptionTest = true;
        CRMDPConvertPricebookAndProductBatch.errorExpected = CRMDPConvertPricebookAndProductBatch.COND_UPDATE_ORDERPROGRESS;

        Test.startTest();
        CRMDPConvertPricebookAndProductBatch.run();
        Test.stopTest();

        // バッチ実行後の案件取得
        for (Opportunity opp_res : [SELECT Id, Name,Pricebook2Id FROM Opportunity]){
            System.assertEquals(Test.getStandardPricebookId(), opp_res.Pricebook2Id);
        }

        // ログデータが作成されていることを確認
        String testLogTitle = CRMDPConvertPricebookAndProductBatch.BATCH_LOG_TITLE + CRMDPConvertPricebookAndProductBatch.COND_UPDATE_ORDERPROGRESS;

        // サービス管理更新失敗ログの確認
        List<Log__c> resultLog = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :testLogTitle
        ];

        System.assertEquals(true, resultLog.size() > 0, '期待するログが作成されていません');
    }

    /**
     * 失敗ケース検証用
     * バッチ起動前後で案件に紐づく価格表が標準価格表のまま変化しないことを確認する
     * @param cause 失敗の原因
     */
    private static void checkFailureCase(String cause){
        // 価格表を取得し、価格表IDをセットする
        Id PRICEBOOK2ID_STANDARD = Test.getStandardPricebookId(); // 標準価格表
        Id PRICEBOOK2ID_OFFLINE_ENP; // エンプラ_オフライン
        Id PRICEBOOK2ID_ONLINE_ENP; // エンプラ_オンライン
        Id PRICEBOOK2ID_VENDING; // エンプラ_自動機
        Id PRICEBOOK2ID_MAKER; // エンプラ_メーカー
        Id PRICEBOOK2ID_POINTOPERATOR; // エンプラ_ポイント事業者
        Id PRICEBOOK2ID_GW; // エンプラ_GW
        Id PRICEBOOK2ID_PSP; // エンプラ_PSP
        Id PRICEBOOK2ID_MYSTORE; // エンプラ_マイストア
        for (Pricebook2 pb : [SELECT Id, Name FROM Pricebook2]){
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_OFFLINE)) PRICEBOOK2ID_OFFLINE_ENP = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_ONLINE)) PRICEBOOK2ID_ONLINE_ENP = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_VENDING)) PRICEBOOK2ID_VENDING = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_MAKER)) PRICEBOOK2ID_MAKER = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_POINT)) PRICEBOOK2ID_POINTOPERATOR = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_GW)) PRICEBOOK2ID_GW = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_PSP)) PRICEBOOK2ID_PSP = pb.Id;
            if(pb.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_MYSTORE)) PRICEBOOK2ID_MYSTORE = pb.Id;
        }

        // バッチ実行前の案件取得
        for (Opportunity opp_res : [SELECT Id, Name,Pricebook2Id FROM Opportunity]){
            System.assertEquals(PRICEBOOK2ID_STANDARD, opp_res.Pricebook2Id);
        }

        // DMLExceptionを発生するようにフラグを更新する
        CRMDPConvertPricebookAndProductBatch.isDMLExceptionTest = true;
        CRMDPConvertPricebookAndProductBatch.errorExpected = cause;
        Test.startTest();
        CRMDPConvertPricebookAndProductBatch.run();
        Test.stopTest();

        // バッチ実行後の案件取得
        for (Opportunity opp_res : [SELECT Id, Name,Pricebook2Id FROM Opportunity]){
            System.assertEquals(PRICEBOOK2ID_STANDARD, opp_res.Pricebook2Id);
        }
    }

}