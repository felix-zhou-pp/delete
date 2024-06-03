/**
* クラス名：CCRMDPUpdAccountIndevFlgBatchTest
* クラス概要：取引先.案件・個店フラグの更新バッチテストクラス
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/30
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class CRMDPUpdAccountIndevFlgBatchTest {

    @TestSetup
    static void setup() {

        // 取引先
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < 6; i++) {
            Account acc = new Account();
            if (i < 2) {
                acc = TestDataFactory.createAccount('【取引先_案件フラグ更新テスト】個店取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_NON_MEMBER, false);
            } else if (i < 5) {
                acc = TestDataFactory.createAccount('【取引先_案件フラグ更新テスト】個店見込取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_MEMBER, false);
            } else {
                acc = TestDataFactory.createAccount('【取引先_案件フラグ更新テスト】エンプラ取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_MEMBER, false);
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
            TestDataFactory.createOpportunity('企業分割案件1-1', acc1.Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false), //0  個店
            TestDataFactory.createOpportunity('企業分割案件1-2', acc2.Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false), //1 個店
            TestDataFactory.createOpportunity('個店・取引先案件1-1', accList[1].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false), //2  個店
            TestDataFactory.createOpportunity('個店・取引先案件1-2', accList[1].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false), //3  個店
            TestDataFactory.createOpportunity('個店・取引先案件2', accList[2].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false), //4  個店
            TestDataFactory.createOpportunity('個店・取引先案件3-1', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false), //5  個店
            TestDataFactory.createOpportunity('個店・取引先案件3-2', accList[3].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false), //6  個店
            TestDataFactory.createOpportunity('個店・取引先案件4-1', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false), //7  個店
            TestDataFactory.createOpportunity('個店・取引先案件4-2', accList[4].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false), //8  オフライン
            TestDataFactory.createOpportunity('EP・取引先案件', accList[5].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false) //9 オフライン
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
        oppList[7].StageName = '40';
        oppList[8].StageName = '00';
        oppList[9].StageName = '50';
        insert oppList;
    }

    /**
     * 取引先.案件フラグ更新バッチ 全件成功
     */
    @isTest
    private static void update_oppFlg_success() {
        DateTime executionDate = DateTime.newInstance(2024, 01, 01, 00, 00, 00);
        Test.startTest();
        CRMDPUpdAccountIndevFlgBatch.run(0, executionDate);
        Test.stopTest();

        // 取引先を取得
        List<Account> expectAccList = [
            SELECT Id, OpportunityFlgIndevs__c,
            (SELECT StageName, RecordType.DeveloperName FROM Opportunities)
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Opportunity WHERE RecordType.DeveloperName = :Constant.OPP_DEVELOPER_NAME_INDIVSALES)];

        // エンプラ案件が紐ついている取引先数 = 6
        System.assertEquals(6, expectAccList.size(), 'test_CRMDPUpdAccountIndevFlgBatch_size_success');

        for (Account expAcc : expectAccList) {
            for (Opportunity opp : expAcc.Opportunities) {

                if (CRMDPUpdAccountIndevFlgBatch.STATUS_CLOSED_LOST.equals(opp.StageName) ||
                    CRMDPUpdAccountIndevFlgBatch.STATUS_WITHDRAWAL.equals(opp.StageName) ||
                    CRMDPUpdAccountIndevFlgBatch.STATUS_WITHDRAWALTEXT.equals(opp.StageName)) {
                        continue;
                } 
                else if (Constant.OPP_DEVELOPER_NAME_INDIVSALES.equals(opp.RecordType.DeveloperName)) {
                        System.assertEquals(true, expAcc.OpportunityFlgIndevs__c, 'test_CRMDPUpdAccountIndevFlgBatch_indev_success');
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
        DateTime executionDate = DateTime.newInstance(2024, 01, 01, 00, 00, 00);
        CRMDPUpdAccountIndevFlgBatch.testFlag = true;

        Test.startTest();
        CRMDPUpdAccountIndevFlgBatch.run(100, executionDate);
        Test.stopTest();

        // 取引先を取得
        List<Account> expectAccList = [
            SELECT Id, OpportunityFlgIndevs__c,
            (SELECT StageName, RecordType.DeveloperName FROM Opportunities)
            FROM Account
            WHERE Id IN (SELECT AccountId FROM Opportunity WHERE RecordType.DeveloperName = :Constant.OPP_DEVELOPER_NAME_INDIVSALES)];

        // エンプラ案件が紐ついている取引先数 = 6
        System.assertEquals(6, expectAccList.size(), 'test_CRMDPUpdAccountIndevFlgBatch_size_success');

        String errorLogTitle = CRMDPUpdAccountIndevFlgBatch.BATCH_LOG_TITLE;
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
        DateTime executionDate = DateTime.newInstance(2024, 01, 01, 00, 00, 00);
        CRMDPUpdAccountIndevFlgBatch.isUpdateIndevFlgExceptionTest = true;

        Test.startTest();
        CRMDPUpdAccountIndevFlgBatch.run(0, executionDate);
        Test.stopTest();

        String errorLogTitle = CRMDPUpdAccountIndevFlgBatch.BATCH_LOG_TITLE;
        List<Log__c> log = [SELECT Title__c, Level__c, Detail__c FROM Log__c WHERE Title__c LIKE :errorLogTitle + '%'];
        System.assertEquals(true, log.size() >= 1, 'cannt get ErrorLog');
        System.assertEquals('ERROR', log[0].Level__c, 'not correct logLevel');
    }
}