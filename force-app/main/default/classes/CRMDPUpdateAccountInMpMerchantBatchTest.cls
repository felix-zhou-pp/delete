@IsTest
public without sharing class CRMDPUpdateAccountInMpMerchantBatchTest {
    public CRMDPUpdateAccountInMpMerchantBatchTest() {
    }
    @TestSetup
    static void setup(){
        
        //取引先チームメンバ作成
        User testUser1 = TestDataFactory.createUser('owner00', 'セールスエンプラ管理ユーザ', true);
        //取引先作成
        Account acc = TestDataFactory.createAccount('テスト企業1', false);
        acc.RecordTypeId = mpUtilString.getRecordTypeByDeveloperName(Account.sObjectType, 'AccountRecordType_MemberStore');
        Account acc2 = acc.clone();
        acc2.Name = '企業2';
        acc2.AccountId_AMS__c = '';
        Insert new List<Account>{acc,acc2};
        AccountTeamMember atm_indev = TestDataFactory.createAccountTeamMember(acc.Id, testUser1.Id, '個店訪販', '個店', false);
        AccountTeamMember atm_indev2 = TestDataFactory.createAccountTeamMember(acc2.Id, testUser1.Id, '個店訪販', '個店', false);
        Insert new List<AccountTeamMember>{atm_indev,atm_indev2};
        //アタックリスト 
        mpOpportunity__c mpOppSameMID = TestDataFactory.createMpOpportunity('移行元アタックリスト1',mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, 'mpList'),false);
        mpOppSameMID.Status__c = '申込完了';
        mpOppSameMID.MID__c = '0000';
        mpOppSameMID.OwnerId = testUser1.Id;
        mpOppSameMID.Note__c = 'コメント1';//提案日時・希望連絡先情報・コメント
        mpOppSameMID.RecentToDoComment__c = '最新活動コメント1';//最新活動コメント
        Insert new List<mpOpportunity__c>{mpOppSameMID};
        mpMerchant__c mpM = TestDataFactory.createMpMerchant('PP加盟店',mpOppSameMID.MID__c,false);
        mpM.mpOpportunity__c = mpOppSameMID.Id;
        insert mpM;
        mpOppSameMID.AccountId__c = acc.Id;
        update mpOppSameMID;
    }

    //DMLエラー
    @isTest
    static void test_dmlFailure(){
        Test.startTest();
        CRMDPUpdateAccountInMpMerchantBatch.isDMLExceptionTest = true;
        Database.executeBatch(new CRMDPUpdateAccountInMpMerchantBatch(),10);
        Test.stopTest();
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountInMpMerchantBatch.BATCH_NAME
        ][0].Detail__c;
        //件数
        System.assert([SELECT count() FROM mpMerchant__c WHERE AccountId__c = null] == 1);
    }
    @isTest
    //正常系、複数企業複数アタックリスト更新
    static void test_success() {
        Test.startTest();
        Database.executeBatch(new CRMDPUpdateAccountInMpMerchantBatch(),10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountInMpMerchantBatch.BATCH_NAME
        ][0].Detail__c;
        System.assert(logText.length()>0);
        System.assert(logText.contains('更新件数:1'));
        System.debug(logText);
        //件数
        System.assert([SELECT count() FROM mpMerchant__c WHERE AccountId__c = null] == 0);
        
    }
}