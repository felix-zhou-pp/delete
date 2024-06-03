/**
* クラス名：CRMDPInsertEPAccountTeamMemberBatchTest
* クラス概要：エンプラ取引先チーム（企業分割非対称）・作成バッチテストクラス
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/10/20
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class CRMDPInsertEPAccountTeamMemberBatchTest {

    // サービス管理（決済/加盟店）レコードタイプ
    static final Id OP_RT_OFFLINE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE);
    static final Id OP_RT_OFF_GW = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER);
    static final Id OPM_RT_OFF_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PLC);
    static final Id OPM_RT_MAKER_LYP = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_LYPMILEAGE);
    static final Id OPM_RT_SC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_SC); 
    static final Id OPM_RT_ENTERPRISE_MYSTORE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE_MYSTORE);
    static final Id OPM_RT_ENTERPRISE_RETAILGIFT = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_RETAILGIFT);
    static final Id OPM_RT_SMB = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB);
    static final Id OPM_RT_PRODUCT_COUPON = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_SPECIFIC_PRODUCT_COUPON);
    static final Id OPM_RT_BALANCEAPI = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_BALANCEAPI);
    static final Id OPM_RT_ENP_ONLINE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_ENP_ONLINE);
    static final Id OPM_RT_ONLINE_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_ONLINE_PLC);
    static final Id OPM_RT_CAMPAIGN = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_CAMPAIGN);
    static final Id OPM_RT_VENDING = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER_VENDING);
    static final Id OPM_RT_ONLINE_MANAGE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_ENP_ONLINE_MANAGE);
    static final Id OPM_RT_PSP = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE);
    static final Id OPM_RT_GIFTCARD = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_GIFTCARD);
    static final Id OPM_RT_REVISITING_COUPON = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_REVISITING_COUPON);
    static final Id OPM_RT_ENPMALL_ONLINE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_ENPMALL_ONLINE);

    @TestSetup
    static void setup() {
        
        // ユーザ
        User user1 = TestDataFactory.createUser('test1', 'セールスエンプラ管理ユーザ', false);
        User user2 = TestDataFactory.createUser('test2', 'セールスエンプラ管理ユーザ', false);
        User user3 = TestDataFactory.createUser('test3', 'セールスエンプラ管理ユーザ', false);
        User user4 = TestDataFactory.createUser('test4', 'セールスエンプラ管理ユーザ', false);
        user4.IsActive =false;
        insert new List<User>{user1, user2, user3, user4};

        // 取引先
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < 18; i++) {
            Account acc = new Account();
            if (i < 6) {
                acc = TestDataFactory.createAccount('【testロジック修正】エンプラ取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_MEMBER, false);
            } else if (i < 17) {
                acc = TestDataFactory.createAccount('【testロジック修正】エンプラ見込取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_NON_MEMBER, false);
            } else {
                acc = TestDataFactory.createAccount('【testロジック修正】個店取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_MEMBER, false);
            }
            accList.add(acc);
        }
        // メーカー担当者の設定
        accList[4].MakerPerson__c = user1.Id;
        accList[6].MakerPerson__c = user3.Id;
        accList[9].MakerPerson__c = user4.Id;
        accList[13].MakerPerson__c = user1.Id;
        accList[16].MakerPerson__c = user3.Id;

        // 取引先_案件フラグの更新
        accList[1].OpportunityFlgOffline__c = true;
        accList[2].OpportunityFlgOffline__c = true;
        accList[3].OpportunityFlgOnline__c = true;
        accList[3].OpportunityFlgOffline__c = true;
        accList[3].OpportunityFlgVending__c = true;
        accList[4].OpportunityFlgGW__c = true;
        accList[4].OpportunityFlgMaker__c = true;
        accList[4].OpportunityFlgPoint__c = true;
        accList[4].OpportunityFlgOnline__c = true;
        accList[5].OpportunityFlgVending__c = true;
        accList[5].OpportunityFlgOffline__c = true;
        accList[6].OpportunityFlgPSP__c = true;
        accList[6].OpportunityFlgMaker__c = true;
        accList[6].OpportunityFlgOffline__c = true;
        accList[7].OpportunityFlgOffline__c = true;
        accList[8].OpportunityFlgOffline__c = true;
        accList[9].OpportunityFlgGW__c = true;
        accList[9].OpportunityFlgMaker__c = true;
        accList[9].OpportunityFlgPoint__c = true;
        accList[9].OpportunityFlgOnline__c = true;
        accList[10].OpportunityFlgPSP__c = true;
        accList[10].OpportunityFlgMaker__c = true;
        accList[10].OpportunityFlgOffline__c = true;
        accList[12].OpportunityFlgOffline__c = true;
        accList[13].OpportunityFlgGW__c = true;
        accList[13].OpportunityFlgPoint__c = true;
        accList[13].OpportunityFlgOnline__c = true;
        accList[14].OpportunityFlgOffline__c = true;
        accList[15].OpportunityFlgOnline__c = true;
        accList[16].OpportunityFlgPSP__c = true;
        accList[16].OpportunityFlgMaker__c = true;
        accList[16].OpportunityFlgOffline__c = true;
        accList[17].OpportunityFlgIndevs__c = true;
        insert accList;

        // 企業分割取引先
        Account acc1 = TestDataFactory.createAccount('【testロジック修正】企業分割1-1', Constant.ACC_DEVELOPER_NAME_MEMBER, false);
        Account acc2 = TestDataFactory.createAccount('【testロジック修正】企業分割1-2', Constant.ACC_DEVELOPER_NAME_MEMBER, false);
        acc1.ParentId = accList[0].Id;
        acc2.ParentId = accList[0].Id;
        insert new List<Account>{acc1, acc2};
        
        // 案件
        List<Opportunity> oppList = new List<Opportunity>{
            // 企業分割分された取引先（抽出されないことを確認するため）
            TestDataFactory.createOpportunity('企業分割案件1-1', acc1.Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //0  オフライン
            TestDataFactory.createOpportunity('企業分割案件MB1-1', acc1.Id, Date.newInstance(2099, 10, 1),Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //1  オフライン
            TestDataFactory.createOpportunity('企業分割案件1-2', acc2.Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_GW, false), //2 GW
            TestDataFactory.createOpportunity('企業分割案件MB1-2', acc2.Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //3  オフライン
            
            // サービス管理（決済事業）のみあるデータ
            TestDataFactory.createOpportunity('エンプラ取引先案件2', accList[1].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //4  オフライン

            // サービス管理（決済事業・加盟店事業）が１つずつあるデータ
            TestDataFactory.createOpportunity('エンプラ取引先案件3-1', accList[2].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //5  オフライン
            TestDataFactory.createOpportunity('エンプラ取引先案件MB3-1', accList[2].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //6  オフライン

            // 1ユーザ複数担当のデータ
            TestDataFactory.createOpportunity('エンプラ取引先案件4-1', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //7 オンライン
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB4-1', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //8 オンライン
            TestDataFactory.createOpportunity('エンプラ取引先案件4-2', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //9  オフライン
            TestDataFactory.createOpportunity('エンプラ取引先案件MB4-2', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //10  オフライン
            TestDataFactory.createOpportunity('エンプラ取引先案件4-3', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_VENDING, false), //11 自動機
            
            // メーカー担当者が設定されていて、複数取引先チームが作成されるデータ
            TestDataFactory.createOpportunity('エンプラ取引先案件5-1', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_GW, false), //12 GW
            TestDataFactory.createOpportunity('エンプラ取引先案件MB5-3', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //13 メーカー
            TestDataFactory.createOpportunity('エンプラ取引先案件MB5-4', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_POINTOPERATOR, false), //14 ポイント事業者
            TestDataFactory.createOpportunity('エンプラ取引先案件5-2', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //15 オンライン
            TestDataFactory.createOpportunity('エンプラ取引先案件MB5-2', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //16 オンライン

            // 取引先チーム担当除外案件を含むデータ＿オンライン大手管理用
            TestDataFactory.createOpportunity('エンプラ見込取引先案件6-1', accList[5].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_VENDING, false), //17 自動機
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB6-1', accList[5].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_VENDING, false), //18 自動機
            TestDataFactory.createOpportunity('エンプラ見込取引先案件6-2', accList[5].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //19 オフライン
            TestDataFactory.createOpportunity('エンプラ見込取引先案件6-3', accList[5].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_INVISIBLE, false), //20 非表示
            
            // 取引先チーム担当除外案件を含むデータ＿マイストア
            // メーカー担当者が案件所有者と異なるデータ（メーカー担当者が優先）
            TestDataFactory.createOpportunity('エンプラ見込取引先案件7-1', accList[6].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_PSP, false), //21 PSP
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB7-3', accList[6].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //22 メーカー
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB7-4', accList[6].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //23 メーカー
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB7-5', accList[6].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MYSTORE, false), //24 マイストア
            TestDataFactory.createOpportunity('エンプラ見込取引先案件7-2', accList[6].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //25 オフライン

            // 所有者無効のデータ
            TestDataFactory.createOpportunity('エンプラ取引先案件8', accList[7].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //26  オフライン

            // 所有者無効のデータ（複数案件）
            TestDataFactory.createOpportunity('エンプラ取引先案件9-1', accList[8].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //27  オフライン
            TestDataFactory.createOpportunity('エンプラ取引先案件MB9-1', accList[8].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //28  オフライン

            // メーカー担当者が無効のデータ
            TestDataFactory.createOpportunity('エンプラ取引先案件10-1', accList[9].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_GW, false), //29 GW
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB10-3', accList[9].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //30 メーカー
            TestDataFactory.createOpportunity('エンプラ取引先案件MB10-4', accList[9].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_POINTOPERATOR, false), //31  ポイント事業者
            TestDataFactory.createOpportunity('エンプラ取引先案件MB10-2', accList[9].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //32  オンライン
            
            // メーカー担当者が設定されていないデータ
            TestDataFactory.createOpportunity('エンプラ見込取引先案件11-1', accList[10].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_PSP, false), //33 PSP
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB11-3', accList[10].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //34 メーカー
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB11-4', accList[10].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //35 メーカー
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB11-5', accList[10].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MYSTORE, false), //36 マイストア
            TestDataFactory.createOpportunity('エンプラ見込取引先案件11-2', accList[10].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //37 オフライン

            // 失注のデータ
            TestDataFactory.createOpportunity('エンプラ取引先案件12', accList[11].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //38  オフライン

            // 取下げのデータ（複数案件）
            TestDataFactory.createOpportunity('エンプラ取引先案件13-1', accList[12].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //39  オフライン
            TestDataFactory.createOpportunity('エンプラ取引先案件MB13-1', accList[12].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //40  オフライン

            // 失注と担当者無効を含むデータ
            TestDataFactory.createOpportunity('エンプラ取引先案件14-1', accList[13].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_GW, false), //41 GW
            TestDataFactory.createOpportunity('エンプラ取引先案件MB14-3', accList[13].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //42 メーカー
            TestDataFactory.createOpportunity('エンプラ取引先案件MB14-4', accList[13].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_POINTOPERATOR, false), //43 ポイント事業者
            TestDataFactory.createOpportunity('エンプラ取引先案件14-2', accList[13].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //44 オンライン
            
            // サービス管理（加盟店事業）のみのデータ
            TestDataFactory.createOpportunity('エンプラ取引先案件15', accList[14].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //45  オフライン

            // サービス管理（決済事業）とサービス管理（加盟店事業）のそれぞれの案件所有者が異なるデータ
            TestDataFactory.createOpportunity('エンプラ取引先案件16-1', accList[15].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //46  オンライン
            TestDataFactory.createOpportunity('エンプラ取引先案件MB16-2', accList[15].Id, Date.newInstance(2099, 10, 1),Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //47  オンライン

             // サービス管理（決済事業）の案件が同じレコードタイプで担当が重複しているデータ
            TestDataFactory.createOpportunity('エンプラ見込取引先案件17-1', accList[16].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_PSP, false), //48 PSP
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB17-4', accList[16].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //49 メーカー
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB17-5', accList[16].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //50 メーカー
            TestDataFactory.createOpportunity('エンプラ見込取引先案件MB17-6', accList[16].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MYSTORE, false), //51 マイストア
            TestDataFactory.createOpportunity('エンプラ見込取引先案件17-2', accList[16].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //52 オフライン
            TestDataFactory.createOpportunity('エンプラ見込取引先案件17-3', accList[16].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //53 オフライン

            TestDataFactory.createOpportunity('個店取引先案件', accList[17].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false) //54 個店
        };

        // 所有者の変更
        oppList[0].ownerId = user1.Id;
        oppList[1].ownerId = user1.Id;
        oppList[2].ownerId = user2.Id;
        oppList[3].ownerId = user2.Id;
        oppList[4].ownerId = user1.Id;
        oppList[5].ownerId = user1.Id;
        oppList[6].ownerId = user1.Id;
        oppList[7].ownerId = user1.Id;
        oppList[8].ownerId = user1.Id;
        oppList[9].ownerId = user1.Id;
        oppList[10].ownerId = user1.Id;
        oppList[11].ownerId = user1.Id;
        oppList[12].ownerId = user1.Id;
        oppList[13].ownerId = user2.Id;
        oppList[14].ownerId = user3.Id;
        oppList[15].ownerId = user3.Id;
        oppList[16].ownerId = user3.Id;
        oppList[17].ownerId = user2.Id;
        oppList[18].ownerId = user2.Id;
        oppList[19].ownerId = user1.Id;
        oppList[20].ownerId = user1.Id;
        oppList[21].ownerId = user2.Id;
        oppList[22].ownerId = user2.Id;
        oppList[23].ownerId = user2.Id;
        oppList[24].ownerId = user1.Id;
        oppList[25].ownerId = user3.Id;
        oppList[26].ownerId = user4.Id;
        oppList[27].ownerId = user4.Id;
        oppList[28].ownerId = user4.Id;
        oppList[29].ownerId = user4.Id;
        oppList[30].ownerId = user2.Id;
        oppList[31].ownerId = user3.Id;
        oppList[32].ownerId = user3.Id;
        oppList[33].ownerId = user2.Id;
        oppList[34].ownerId = user2.Id;
        oppList[35].ownerId = user2.Id;
        oppList[36].ownerId = user1.Id;
        oppList[37].ownerId = user3.Id;
        oppList[38].ownerId = user1.Id;
        oppList[39].ownerId = user1.Id;
        oppList[40].ownerId = user1.Id;
        oppList[41].ownerId = user1.Id;
        oppList[42].ownerId = user2.Id;
        oppList[43].ownerId = user3.Id;
        oppList[44].ownerId = user4.Id;
        oppList[45].ownerId = user2.Id;
        oppList[46].ownerId = user1.Id;
        oppList[47].ownerId = user2.Id;
        oppList[48].ownerId = user2.Id;
        oppList[49].ownerId = user2.Id;
        oppList[50].ownerId = user2.Id;
        oppList[51].ownerId = user2.Id;
        oppList[52].ownerId = user2.Id;
        oppList[53].ownerId = user3.Id;

        // 営業状況の更新
        oppList[0].StageName = '50';
        oppList[1].StageName = '20';
        oppList[2].StageName = '50';
        oppList[3].StageName = '20';
        oppList[4].StageName = '00';
        oppList[5].StageName = '10';
        oppList[6].StageName = '20';
        oppList[7].StageName = '30';
        oppList[8].StageName = '40';
        oppList[9].StageName = '50';
        oppList[10].StageName = '10';
        oppList[11].StageName = '60';
        oppList[12].StageName = '00';
        oppList[13].StageName = '10';
        oppList[14].StageName = '20';
        oppList[15].StageName = '60';
        oppList[16].StageName = '30';
        oppList[17].StageName = '40';
        oppList[18].StageName = '50';
        oppList[19].StageName = '60';
        oppList[20].StageName = '00';
        oppList[21].StageName = '10';
        oppList[22].StageName = '20';
        oppList[23].StageName = '30';
        oppList[24].StageName = '40';
        oppList[25].StageName = '50';
        oppList[26].StageName = '60';
        oppList[27].StageName = '00';
        oppList[28].StageName = '10';
        oppList[29].StageName = '20';
        oppList[30].StageName = '30';
        oppList[31].StageName = '40';
        oppList[32].StageName = '50';
        oppList[33].StageName = '60';
        oppList[34].StageName = '10';
        oppList[35].StageName = '20';
        oppList[36].StageName = '30';
        oppList[37].StageName = '00';
        oppList[38].StageName = '90';
        oppList[38].LostReason__c = '価格';
        oppList[38].LostReasonDetail__c = 'test';
        oppList[39].StageName = '95';
        oppList[39].LostReason__c = '価格';
        oppList[39].LostReasonDetail__c = 'test';
        oppList[40].StageName = '20';
        oppList[41].StageName = '00';
        oppList[42].StageName = '取下げ';
        oppList[43].StageName = '00';
        oppList[44].StageName = '10';
        oppList[45].StageName = '20';
        oppList[46].StageName = '50';
        oppList[47].StageName = '20';
        oppList[48].StageName = '10';
        oppList[49].StageName = '20';
        oppList[50].StageName = '30';
        oppList[51].StageName = '40';
        oppList[52].StageName = '50';
        oppList[53].StageName = '50';
        insert oppList;

        // サービス管理決済事業
        List<OrderProgress__c> opsList = new List<OrderProgress__c>{
            TestDataFactory.createOrderProgress('企業分割サービス管理1-1', acc1.Id, oppList[0].Id, OP_RT_OFFLINE, false), //0  オフライン
            TestDataFactory.createOrderProgress('企業分割サービス管理MB1-1', acc1.Id, oppList[1].Id, OPM_RT_OFF_PLC, false), //1  オフライン
            TestDataFactory.createOrderProgress('企業分割サービス管理1-2', acc2.Id, oppList[2].Id, OP_RT_OFF_GW, false), //2 GW
            TestDataFactory.createOrderProgress('企業分割サービス管理MB1-2', acc2.Id, oppList[3].Id, OPM_RT_SC, false), //3  オフラインスタンプカード
            
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理2', accList[1].Id, oppList[4].Id, OP_RT_OFFLINE, false), //4  オフライン
            
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理3-1', accList[2].Id, oppList[5].Id, OP_RT_OFFLINE, false), //5  オフライン
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB3-1', accList[2].Id, oppList[6].Id, OPM_RT_OFF_PLC, false), //6  オフラインPLC

            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理4-1', accList[3].Id, oppList[7].Id, OPM_RT_ENP_ONLINE, false), //7 オンライン
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB4-1', accList[3].Id, oppList[8].Id, OPM_RT_ONLINE_PLC, false), //8 オンラインPLC
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理4-2', accList[3].Id,  oppList[9].Id, OP_RT_OFFLINE, false), //9  オフライン
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB4-2', accList[3].Id, oppList[10].Id, OPM_RT_CAMPAIGN, false), //10  オフラインキャンペーン
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理4-3', accList[3].Id, oppList[11].Id, OPM_RT_VENDING, false), //11 自動機

            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理5-1', accList[4].Id, oppList[12].Id,  OP_RT_OFF_GW, false), //12 GW
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB5-3', accList[4].Id, oppList[13].Id, OPM_RT_PRODUCT_COUPON, false), //13 メーカー
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB5-4', accList[4].Id, oppList[14].Id, OPM_RT_BALANCEAPI, false), //14 ポイント事業者
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理5-2', accList[4].Id, oppList[15].Id, OPM_RT_ENP_ONLINE, false), //15 オンライン
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB5-2', accList[4].Id, oppList[16].Id, OPM_RT_SC, false), //16 オンライン
            
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理6-1', accList[5].Id, oppList[17].Id, OPM_RT_VENDING, false), //17 自動機
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理MB6-1', accList[5].Id, oppList[18].Id, OPM_RT_ONLINE_PLC, false), //18 自動機
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理6-2', accList[5].Id, oppList[19].Id, OP_RT_OFFLINE, false), //19 オフライン
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理6-3', accList[5].Id, oppList[20].Id, OPM_RT_ONLINE_MANAGE, false), //20 非表示

            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理7-1', accList[6].Id, oppList[21].Id, OPM_RT_PSP, false), //21 PSP
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理MB7-3', accList[6].Id, oppList[22].Id, OPM_RT_PRODUCT_COUPON, false), //22 メーカー
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理MB7-4', accList[6].Id, oppList[23].Id, OPM_RT_GIFTCARD, false), //23 メーカー
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理MB7-5', accList[6].Id, oppList[24].Id, OPM_RT_ENTERPRISE_MYSTORE, false), //24 マイストア
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理7-2', accList[6].Id, oppList[25].Id, OP_RT_OFFLINE, false), //25 オフライン
            
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理8', accList[7].Id, oppList[26].Id, OP_RT_OFFLINE, false), //26  オフライン
            
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理9-1', accList[8].Id, oppList[27].Id, OP_RT_OFFLINE, false), //27  オフライン
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB9-1', accList[8].Id, oppList[28].Id, OPM_RT_REVISITING_COUPON, false), //28  オフラインPLC

            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理10-1', accList[9].Id, oppList[29].Id,  OP_RT_OFF_GW, false), //29 GW
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB10-3', accList[9].Id, oppList[30].Id, OPM_RT_MAKER_LYP, false), //30 メーカー
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB10-4', accList[9].Id, oppList[31].Id, OPM_RT_BALANCEAPI, false), //31 ポイント事業者
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理10-2', accList[9].Id, oppList[32].Id, OPM_RT_ENPMALL_ONLINE, false), //32 オンライン

            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理11-1', accList[10].Id, oppList[33].Id, OPM_RT_ENPMALL_ONLINE, false), //33 PSP
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理MB11-3', accList[10].Id, oppList[34].Id, OPM_RT_PRODUCT_COUPON, false), //34 メーカー
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理MB11-4', accList[10].Id, oppList[35].Id, OPM_RT_GIFTCARD, false), //35 メーカー
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理MB11-5', accList[10].Id, oppList[36].Id, OPM_RT_ENTERPRISE_MYSTORE, false), //36 マイストア
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理11-2', accList[10].Id, oppList[37].Id, OP_RT_OFFLINE, false), //37 オフライン

            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理12', accList[11].Id, oppList[38].Id, OP_RT_OFFLINE, false), //38  オフライン
            
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理13-1', accList[12].Id, oppList[39].Id, OP_RT_OFFLINE, false), //39  オフライン
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB13-1', accList[12].Id, oppList[40].Id, OPM_RT_OFF_PLC, false), //40  オフラインPLC

            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理14-1', accList[13].Id, oppList[41].Id,  OP_RT_OFF_GW, false), //41 GW
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB14-3', accList[13].Id, oppList[42].Id, OPM_RT_PRODUCT_COUPON, false), //42 メーカー
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB14-4', accList[13].Id, oppList[43].Id, OPM_RT_BALANCEAPI, false), //43 ポイント事業者
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理14-2', accList[13].Id, oppList[44].Id, OPM_RT_PRODUCT_COUPON, false), //44 オンライン

            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理15', accList[14].Id, oppList[45].Id, OPM_RT_OFF_PLC, false), //45  オフライン
            
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理16-1', accList[15].Id, oppList[46].Id, OPM_RT_ENPMALL_ONLINE, false), //46  オンライン
            TestDataFactory.createOrderProgress('エンプラ取引先サービス管理MB16-2', accList[15].Id, oppList[47].Id, OPM_RT_OFF_PLC, false), //47  オンラインPLC

            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理17-1', accList[16].Id, oppList[48].Id, OPM_RT_SMB, false), //48 PSP
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理MB17-4', accList[16].Id, oppList[49].Id, OPM_RT_ENTERPRISE_RETAILGIFT, false), //49 メーカー
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理MB17-5', accList[16].Id, oppList[50].Id, OPM_RT_MAKER_LYP, false), //50 メーカー
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理MB17-6', accList[16].Id, oppList[51].Id, OPM_RT_ENTERPRISE_MYSTORE, false), //51 マイストア
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理17-2', accList[16].Id, oppList[52].Id, OP_RT_OFFLINE, false), //52 オフライン
            TestDataFactory.createOrderProgress('エンプラ見込取引先サービス管理17-3', accList[16].Id, oppList[53].Id, OP_RT_OFFLINE, false), //53 オフライン

            TestDataFactory.createOrderProgress('個店取引先サービス管理', accList[17].Id, oppList[54].Id, OP_RT_OFFLINE, false) //54 個店
        };

        opsList[32].Industryclass__c = '小売業';
        opsList[32].NewIndustryclass__c = 'モール';
        opsList[32].Industryclassification__c = 'モール';
        opsList[33].Industryclass__c = 'GW・PSP/カート・収納代行';
        opsList[33].NewIndustryclass__c = 'カート';
        opsList[33].Industryclassification__c = 'カート';
        opsList[44].Industryclass__c = '小売業';
        opsList[44].NewIndustryclass__c = 'モール';
        opsList[44].Industryclassification__c = 'モール';
        opsList[46].Industryclass__c = 'サービス';
        opsList[46].NewIndustryclass__c = 'サービス';
        opsList[46].Industryclassification__c = 'サービス';
        insert opsList;
    }

    /**
     * エンプラ取引先チーム作成バッチ 全件成功
     */
    @isTest
    private static void insert_accountTeamMember_success() {
        Test.startTest();
        CRMDPInsertEPAccountTeamMemberBatch.run();
        Test.stopTest();


        // 移行元の案件を取得
        List<Opportunity> oppList = [
            SELECT Id
            FROM Opportunity
            WHERE RecordType.Name !=: Constant.OPP_DEVELOPER_NAME_INDIVSALES];

        // 移行元のサービス管理（決済事業）を取得
        List<OrderProgress__c> opsList = [
            SELECT Id, OpportunityId__r.AccountId, RecordType.DeveloperName, OpportunityId__r.StageName, OpportunityId__r.OwnerId, OpportunityId__r.Account.MakerPerson__c
            FROM OrderProgress__c
            WHERE OpportunityId__c = :oppList];
        
        // 取引先チームを取得
        List<AccountTeamMember> expectAtmList = [
            SELECT Id, UserId, ProductInCharge__c, AssignStatus__c, TeamMemberRole, AccountId, Account.Name
            FROM AccountTeamMember
            WHERE Account.ParentId = NULL 
            AND TeamMemberRole =: AccountTeamMemberUtil.TEAMMEMBERROLE_ENP];
            
        // 取引先単位の取引先チームのMap
        Map<Id, List<AccountTeamMember>> atmMap = new Map<Id, List<AccountTeamMember>>();
        for (AccountTeamMember axpAtm: expectAtmList) {
            if (atmMap.containskey(axpAtm.AccountId)) {
                atmMap.get(axpAtm.AccountId).add(axpAtm);
            }
            else {
                atmMap.put(axpAtm.AccountId, new List<AccountTeamMember>());
                atmMap.get(axpAtm.AccountId).add(axpAtm);
            }
        }
        
        // バッチ実行で作成される取引先チームメンバーのレコード = 14
        System.assertEquals(12, expectAtmList.size(), 'test_CRMDPInsertEPAccountTeamMemberBatchTest_size_success');

        String errorLogTitle = CRMDPInsertEPAccountTeamMemberBatch.BATCH_LOG_TITLE;
        List<Log__c> log = [SELECT Title__c, Level__c, Detail__c FROM Log__c WHERE Title__c LIKE :errorLogTitle + '%'];
        System.assertEquals(true, log.size() >= 1, 'cannt get log');
        System.assertEquals('ERROR', log[0].Level__c, 'not correct logLevel');
    }

    /**
     * エンプラ取引先チーム作成バッチ 失敗
     */
    @isTest
    private static void insert_accountTeamMember_dmlExeption_error() {
        CRMDPInsertEPAccountTeamMemberBatch.isInsertEPAtmExceptionTest = true;
        Test.startTest();
        CRMDPInsertEPAccountTeamMemberBatch.run();
        Test.stopTest();

        String errorLogTitle = CRMDPInsertEPAccountTeamMemberBatch.BATCH_LOG_TITLE;
        List<Log__c> log = [SELECT Title__c, Level__c, Detail__c FROM Log__c WHERE Title__c LIKE :errorLogTitle + '%'];
        System.assertEquals(true, log.size() >= 1, 'cannt get ErrorLog');
        System.assertEquals('ERROR', log[0].Level__c, 'not correct logLevel');
    }
}