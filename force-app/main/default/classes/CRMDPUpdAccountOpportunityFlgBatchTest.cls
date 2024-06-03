/**
* クラス名：CRMDPUpdAccountOpportunityFlgBatchTest
* クラス概要：取引先.案件フラグ更新バッチテストクラス
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/30
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class CRMDPUpdAccountOpportunityFlgBatchTest {

    @TestSetup
    static void setup() {

        // 取引先
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < 7; i++) {
            Account acc = new Account();
            if (i < 2) {
                acc = TestDataFactory.createAccount('【取引先_案件フラグ更新テスト】エンプラ見込取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_NON_MEMBER, false);
            } else if (i < 5) {
                acc = TestDataFactory.createAccount('【取引先_案件フラグ更新テスト】エンプラ取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_MEMBER, false);
            } else {
                acc = TestDataFactory.createAccount('【取引先_案件フラグ更新テスト】個店取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_MEMBER, false);
            }
            accList.add(acc);
        }
        insert accList;


        // 企業分割取引先
        Account acc1 = TestDataFactory.createAccount('【取引先_案件フラグ更新テスト】企業分割1-1', Constant.ACC_DEVELOPER_NAME_MEMBER, false);
        Account acc2 = TestDataFactory.createAccount('【取引先_案件フラグ更新テスト】企業分割1-2', Constant.ACC_DEVELOPER_NAME_MEMBER, false);
        acc1.ParentId = accList[0].Id;
        acc2.ParentId = accList[0].Id;
        insert new List<Account>{acc1, acc2};

        // 案件
        List<Opportunity> oppList = new List<Opportunity>{
            TestDataFactory.createOpportunity('企業分割案件1-1', acc1.Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //0  オフライン
            TestDataFactory.createOpportunity('企業分割案件1-2', acc2.Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //1 オフライン
            TestDataFactory.createOpportunity('企業分割案件1-2', acc2.Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //2 オフライン
            TestDataFactory.createOpportunity('EP・取引先案件1-1', accList[1].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //3  オフライン
            TestDataFactory.createOpportunity('EP・取引先案件1-2', accList[1].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //4  オンライン
            TestDataFactory.createOpportunity('EP・取引先案件2-1', accList[2].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //5  オンライン
            TestDataFactory.createOpportunity('EP・取引先案件2-2', accList[2].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //6  オフライン
            TestDataFactory.createOpportunity('EP・取引先案件2-3', accList[2].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //7 オフライン
            TestDataFactory.createOpportunity('EP・取引先案件2-4', accList[2].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_VENDING, false), //8  自動機
            TestDataFactory.createOpportunity('EP・取引先案件3-1', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_GW, false), //9 GW
            TestDataFactory.createOpportunity('EP・取引先案件3-2', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //10 メーカー
            TestDataFactory.createOpportunity('EP・取引先案件3-3', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_POINTOPERATOR, false), //11 ポイント事業者
            TestDataFactory.createOpportunity('EP・取引先案件3-4', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //12 オンライン
            TestDataFactory.createOpportunity('EP・取引先案件4-1', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_VENDING, false), //13 自動機
            TestDataFactory.createOpportunity('EP・取引先案件4-2', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_VENDING, false), //14 自動機
            TestDataFactory.createOpportunity('EP・取引先案件4-3', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE, false), //15 オンライン
            TestDataFactory.createOpportunity('EP・取引先案件4-4', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //16 オフライン
            TestDataFactory.createOpportunity('EP・取引先案件4-5', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER, false), //17 ーカー
            TestDataFactory.createOpportunity('EP・取引先案件4-6', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_PSP, false), //18 PSP
            TestDataFactory.createOpportunity('EP・取引先案件4-7', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_GW, false), //19 GW
            TestDataFactory.createOpportunity('EP・取引先案件4-8', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MYSTORE, false), //20 マイストア
            TestDataFactory.createOpportunity('EP・取引先案件4-9', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_INVISIBLE, false), //21 非表示
            TestDataFactory.createOpportunity('EP・取引先案件5-1', accList[5].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //22 オフライン
            TestDataFactory.createOpportunity('EP・取引先案件5-2', accList[5].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //23 オフライン
            TestDataFactory.createOpportunity('個店・取引先案件', accList[6].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false) //24 個店
        };
        // 営業状況の更新
        oppList[0].StageName = '10';
        oppList[1].StageName = '95';
        oppList[1].LostReason__c = '価格';
        oppList[1].LostReasonDetail__c = 'test';
        oppList[2].StageName = '60';
        oppList[3].StageName = '10';
        oppList[4].StageName = '20';
        oppList[5].StageName = '30';
        oppList[6].StageName = '90';
        oppList[6].LostReason__c = '価格';
        oppList[6].LostReasonDetail__c = 'test';
        oppList[7].StageName = '取下げ';
        oppList[8].StageName = '60';
        oppList[10].StageName = '10';
        oppList[11].StageName = '20';
        oppList[12].StageName = '30';
        oppList[13].StageName = '40';
        oppList[14].StageName = '90';
        oppList[14].LostReason__c = '価格';
        oppList[14].LostReasonDetail__c = 'test';
        oppList[15].StageName = '30';
        oppList[16].StageName = '60';
        oppList[17].StageName = '40';
        oppList[18].StageName = '20';
        oppList[19].StageName = '50';
        oppList[20].StageName = '10';
        oppList[22].StageName = '90';
        oppList[22].LostReason__c = '価格';
        oppList[22].LostReasonDetail__c = 'test';
        oppList[23].StageName = '95';
        oppList[23].LostReason__c = '価格';
        oppList[23].LostReasonDetail__c = 'test';
        oppList[24].StageName = '10';
        insert oppList;
    }

    /**
     * 取引先.案件フラグ更新バッチ 全件成功
     */
    @isTest
    private static void update_oppFlg_success() {
        Test.startTest();
        CRMDPUpdAccountOpportunityFlgBatch.run();
        Test.stopTest();

        // 取引先を取得
        List<Account> expectAccList = [
            SELECT Id, OpportunityFlgOffline__c, OpportunityFlgOnline__c, OpportunityFlgVending__c, OpportunityFlgMaker__c, OpportunityFlgPoint__c, OpportunityFlgGW__c, OpportunityFlgPSP__c,
            (SELECT StageName, RecordType.DeveloperName FROM Opportunities)
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Opportunity WHERE RecordType.DeveloperName != :Constant.OPP_DEVELOPER_NAME_INDIVSALES)];

        // エンプラ案件が紐ついている取引先数 = 7
        System.assertEquals(7, expectAccList.size(), 'test_CRMDPUpdAccountOpportunityFlgBatch_size_success');

        for (Account expAcc : expectAccList) {
            for (Opportunity opp : expAcc.Opportunities) {

                if (CRMDPUpdAccountOpportunityFlgBatch.STATUS_CLOSED_LOST.equals(opp.StageName) ||
                    CRMDPUpdAccountOpportunityFlgBatch.STATUS_WITHDRAWAL.equals(opp.StageName) ||
                    CRMDPUpdAccountOpportunityFlgBatch.STATUS_WITHDRAWALTEXT.equals(opp.StageName)) {
                        continue;
                } 
                else {
                    // 案件のレコードタイプを確認し対象のフラグをTRUEに変更
                    switch on opp.RecordType.DeveloperName {
                        // Offline加盟店
                        when 'OpportunityRecordType_Enterprise_Offline' {
                            System.assertEquals(true, expAcc.OpportunityFlgOffline__c, 'test_CRMDPUpdAccountOpportunityFlgBatch_offline_success');
                        }
                        // Online加盟店
                        when 'OpportunityRecordType_Enterprise_Online' {
                            System.assertEquals(true, expAcc.OpportunityFlgOnline__c, 'test_CRMDPUpdAccountOpportunityFlgBatch_online_success');
                        }
                        // 自動機
                        when 'OpportunityRecordType_Enterprise_Vending' {
                            System.assertEquals(true, expAcc.OpportunityFlgVending__c, 'test_CRMDPUpdAccountOpportunityFlgBatch_vending_success');
                        }
                        // メーカー
                        when 'OpportunityRecordType_Enterprise_Maker' {
                            System.assertEquals(true, expAcc.OpportunityFlgMaker__c, 'test_CRMDPUpdAccountOpportunityFlgBatch_maker_success');
                        }
                        // ポイント事業者
                        when 'OpportunityRecordType_Enterprise_PointOperator' {
                            System.assertEquals(true, expAcc.OpportunityFlgPoint__c, 'test_CRMDPUpdAccountOpportunityFlgBatch_point_success');
                        }
                        // GW
                        when 'OpportunityRecordType_Enterprise_GW' {
                            System.assertEquals(true, expAcc.OpportunityFlgGW__c, 'test_CRMDPUpdAccountOpportunityFlgBatch_gw_success');
                        }
                        // PSP
                        when 'OpportunityRecordType_Enterprise_PSP' {
                            System.assertEquals(true, expAcc.OpportunityFlgPSP__c, 'test_CRMDPUpdAccountOpportunityFlgBatch_psp_success');
                        }
                    }
                }
            }
        }
    }

    /**
     * 取引先.案件フラグ更新バッチ 失敗
     * 更新時エラーがある場合
     */
    @isTest
    private static void update_aoppFlg_ng_error() {

        CRMDPUpdAccountOpportunityFlgBatch.testFlag = true;

        Test.startTest();
        CRMDPUpdAccountOpportunityFlgBatch.run();
        Test.stopTest();

        // 取引先を取得
        List<Account> expectAccList = [
            SELECT Id, OpportunityFlgOffline__c, OpportunityFlgOnline__c, OpportunityFlgVending__c, OpportunityFlgMaker__c, OpportunityFlgPoint__c, OpportunityFlgGW__c, OpportunityFlgPSP__c,
            (SELECT StageName, RecordType.DeveloperName FROM Opportunities)
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Opportunity WHERE RecordType.DeveloperName != :Constant.OPP_DEVELOPER_NAME_INDIVSALES)];

        // エンプラ案件が紐ついている取引先数 = 7
        System.assertEquals(7, expectAccList.size(), 'test_CRMDPUpdAccountOpportunityFlgBatch_size_success');

        String errorLogTitle = CRMDPUpdAccountOpportunityFlgBatch.BATCH_LOG_TITLE;
        List<Log__c> log = [SELECT Title__c, Level__c, Detail__c FROM Log__c WHERE Title__c LIKE :errorLogTitle + '%'];
        System.assertEquals(true, log.size() >= 1, 'cannt get ErrorLog');
        System.assertEquals('ERROR', log[0].Level__c, 'not correct logLevel');
    }

    /**
     * 取引先.案件フラグ更新バッチ 失敗
     * DMLException
     */
    @isTest
    private static void update_oppFlg_dmlExeption_error() {
        CRMDPUpdAccountOpportunityFlgBatch.isUpdateOpportunityFlgExceptionTest = true;
        Test.startTest();
        CRMDPUpdAccountOpportunityFlgBatch.run();
        Test.stopTest();

        String errorLogTitle = CRMDPUpdAccountOpportunityFlgBatch.BATCH_LOG_TITLE;
        List<Log__c> log = [SELECT Title__c, Level__c, Detail__c FROM Log__c WHERE Title__c LIKE :errorLogTitle + '%'];
        System.assertEquals(true, log.size() >= 1, 'cannt get ErrorLog');
        System.assertEquals('ERROR', log[0].Level__c, 'not correct logLevel');
    }
}