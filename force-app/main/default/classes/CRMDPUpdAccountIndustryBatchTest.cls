/**
* クラス名：CRMDPUpdAccountIndustryBatchTest
* クラス概要：取引先.業種の更新バッチテストクラス
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/22
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
@isTest
public with sharing class CRMDPUpdAccountIndustryBatchTest {

    @TestSetup
    static void setup() {

        // アタックリスト
        List<mpOpportunity__c> mpOppList = new List<mpOpportunity__c>();
        for (Integer i = 0; i < 22; i++) {
            mpOpportunity__c mpOpp = new mpOpportunity__c();
            mpOpp = TestDataFactory.createMpOpportunity('アタックリスト' + String.valueOf(i+1), mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, 'mpList'), false);
            mpOppList.add(mpOpp);
        }
        mpOppList[0].MerchandiseClassification__c = '食品スーパー';
        mpOppList[1].MerchandiseClassification__c = '各種小売';
        mpOppList[2].MerchandiseClassification__c = '大規模小売店';
        mpOppList[3].MerchandiseClassification__c = '公共サービス';
        mpOppList[4].MerchandiseClassification__c = 'コンビニ';
        mpOppList[5].MerchandiseClassification__c = '大手向け特別';
        mpOppList[6].MerchandiseClassification__c = '学校・教育機関';
        mpOppList[7].MerchandiseClassification__c = '行政・公共サービス';
        mpOppList[8].MerchandiseClassification__c = '交通';
        mpOppList[9].MerchandiseClassification__c = 'ギフトカード';
        mpOppList[10].MerchandiseClassification__c = 'サービス';
        mpOppList[11].MerchandiseClassification__c = 'スクール';
        mpOppList[12].MerchandiseClassification__c = '病院';
        mpOppList[13].MerchandiseClassification__c = 'ビューティ・リラクゼーション';
        mpOppList[14].MerchandiseClassification__c = '飲食';
        mpOppList[15].MerchandiseClassification__c = '小売';
        mpOppList[16].MerchandiseClassification__c = 'テスト';
        mpOppList[18].MerchandiseClassification__c = '小売';
        mpOppList[19].MerchandiseClassification__c = '飲食';
        mpOppList[20].MerchandiseClassification__c = '娯楽';
        insert mpOppList;

        // 取引先
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < 21; i++) {
            Account acc = new Account();
            if (i < 15) {
                acc = TestDataFactory.createAccount('【取引先_業種更新テスト】個店・取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_MEMBER, false);
            }
            else if (i < 19) {
                acc = TestDataFactory.createAccount('【取引先_業種更新テスト】個店・見込取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_NON_MEMBER, false);
            }
            else {
                acc = TestDataFactory.createAccount('【取引先_業種更新テスト】エンプラ・取引先' + String.valueOf(i+1), Constant.ACC_DEVELOPER_NAME_MEMBER, false);
            }

            // 移行元アタックリスト設定
            if (0 < i) {
                acc.CRMDPAccountId__c = mpOppList[i-1].Id;
            }
            accList.add(acc);
        }
        insert accList;

        // 企業分割取引先
        Account acc1 = TestDataFactory.createAccount('【取引先_業種更新テスト】企業分割1-1', Constant.ACC_DEVELOPER_NAME_MEMBER, false);
        Account acc2 = TestDataFactory.createAccount('【取引先_業種更新テスト】企業分割1-2', Constant.ACC_DEVELOPER_NAME_MEMBER, false);
        // Id pearentId = [SELECT Id FROM Account WHERE Name = 'エンプラ取引先1'];
        acc1.ParentId = accList[0].Id;
        acc1.CRMDPAccountId__c = mpOppList[20].Id;
        acc2.ParentId = accList[0].Id;
        insert new List<Account>{acc1, acc2};

        // 案件
        List<Opportunity> oppList = new List<Opportunity>();
        for (Integer i = 0; i < 22; i++) {
            Opportunity opp = new Opportunity();
            if (i < 18) {
                opp = TestDataFactory.createOpportunity('個店案件' + String.valueOf(i+1), accList[i+1].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false);
            }
            else if (i < 20) {
                opp = TestDataFactory.createOpportunity('エンプラ案件' + String.valueOf(i+1), accList[i+1].Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE, false);
            }
            else if (i == 20) {
                opp = TestDataFactory.createOpportunity('個店企業分割案件' + String.valueOf(i+1), acc1.Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false);
            }
            else {
                opp = TestDataFactory.createOpportunity('個店企業分割案件' + String.valueOf(i+1), acc2.Id, Date.newInstance(2099, 10, 1), Constant.OPP_DEVELOPER_NAME_INDIVSALES, false);
            }
            oppList.add(opp);
        }
        insert oppList;
    }

    /**
     * 取引先.業種の更新バッチ 全件成功
     */
    @isTest
    private static void update_accountIndustry_success() {
        DateTime executionDate = DateTime.newInstance(2024, 01, 01, 00, 00, 00);
        Test.startTest();
        CRMDPUpdAccountIndustryBatch.run(executionDate);
        Test.stopTest();

        // 取引先を取得
        List<Account> expectAccList = [
            SELECT Id, Industry, CRMDPAccountId__r.MerchandiseClassification__c
            FROM Account
            WHERE CRMDPAccountId__c != null
            AND Id IN (SELECT AccountId FROM Opportunity WHERE RecordType.DeveloperName = :Constant.OPP_DEVELOPER_NAME_INDIVSALES)];

        // 移行元アタックリストがある取引先レコード = 19
        System.assertEquals(19, expectAccList.size(), 'test_CRMDPUpdAccountIndustryBatchTest_size_success');

        List<String> ngText = new List<String>{'テスト', 'ギフトカード'};
        for (Account expAcc : expectAccList) {
            String val = expAcc.CRMDPAccountId__r.MerchandiseClassification__c;
            if (ngText.contains(val)) {
                System.assertEquals(null, expAcc.Industry, 'test_CRMDPUpdAccountIndustryBatchTest_value_success');
            } else {
                System.assertEquals(expAcc.CRMDPAccountId__r.MerchandiseClassification__c, expAcc.Industry, 'test_CRMDPUpdAccountIndustryBatchTest_value_success');
            }
        }
    }

    /**
     * 取引先.業種の更新バッチ 失敗
     * 更新時エラーがある場合
     */
    @isTest
    private static void update_accountIndustry_ngIndustry_error() {
        CRMDPUpdAccountIndustryBatch.testFlag = true;
        DateTime executionDate = DateTime.newInstance(2024, 01, 01, 00, 00, 00);

        Test.startTest();
        CRMDPUpdAccountIndustryBatch.run(executionDate);
        Test.stopTest();

        // 取引先を取得
        List<Account> expectAccList = [
            SELECT Id, Industry, CRMDPAccountId__r.MerchandiseClassification__c
            FROM Account
            WHERE CRMDPAccountId__c != null
            AND Id IN (SELECT AccountId FROM Opportunity WHERE RecordType.DeveloperName = :Constant.OPP_DEVELOPER_NAME_INDIVSALES)];

        // 移行元アタックリストがある取引先レコード = 19
        System.assertEquals(19, expectAccList.size(), 'test_CRMDPUpdAccountIndustryBatchTest_size_success');

        String errorLogTitle = CRMDPUpdAccountIndustryBatch.BATCH_LOG_TITLE;
        List<Log__c> log = [SELECT Title__c, Level__c, Detail__c FROM Log__c WHERE Title__c LIKE :errorLogTitle + '%'];
        System.assertEquals(true, log.size() >= 1, 'cannt get ErrorLog');
        System.assertEquals('ERROR', log[0].Level__c, 'not correct logLevel');
    }

    /**
     * 取引先.業種の更新バッチ 失敗
     * DMLException
     */
    @isTest
    private static void update_accountIndustry_dmlExeption_error() {
        CRMDPUpdAccountIndustryBatch.isUpdateAccIndustryExceptionTest = true;
        DateTime executionDate = DateTime.newInstance(2024, 01, 01, 00, 00, 00);

        Test.startTest();
        CRMDPUpdAccountIndustryBatch.run(executionDate);
        Test.stopTest();

        String errorLogTitle = CRMDPUpdAccountIndustryBatch.BATCH_LOG_TITLE;
        List<Log__c> log = [SELECT Title__c, Level__c, Detail__c FROM Log__c WHERE Title__c LIKE :errorLogTitle + '%'];
        System.assertEquals(true, log.size() >= 1, 'cannt get ErrorLog');
        System.assertEquals('ERROR', log[0].Level__c, 'not correct logLevel');
    }
}