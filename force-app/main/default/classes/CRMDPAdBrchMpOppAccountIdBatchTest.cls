@isTest
public without sharing class CRMDPAdBrchMpOppAccountIdBatchTest {
    //複数支部追加複数取引先、支部追加無しデータ用意
    @TestSetup
    static void setup(){
        // 取引先チームメンバ作成
        User testUser = TestDataFactory.createUser('owner00', 'セールスエンプラ管理ユーザ', true);
        // 取引先作成
        Account acc = TestDataFactory.createAccount('テスト企業', false);
        acc.RecordTypeId = mpUtilString.getRecordTypeByDeveloperName(Account.sObjectType, 'AccountRecordType_MemberStore');
        Account acc2 = acc.clone();
        acc2.Name = '企業2';
        Insert new List<Account>{acc,acc2};
        AccountTeamMember atm_indev = TestDataFactory.createAccountTeamMember(acc.Id, testUser.Id, '個店訪販', '個店', false);
        AccountTeamMember atm_indev2 = TestDataFactory.createAccountTeamMember(acc2.Id, testUser.Id, '個店訪販', '個店', false);
        Insert new List<AccountTeamMember>{atm_indev,atm_indev2};
        //アタックリスト 本部
        mpOpportunity__c masterMO = TestDataFactory.createMpOpportunity('本部',mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, 'mpList'),false);
        masterMO.Status__c = '申込完了';
        mpOpportunity__c master2 = masterMO.clone();
        master2.Name = '本部2';
        mpOpportunity__c masterNoAB = masterMO.clone();
        masterNoAB.Name = '本部3支部無し';
        Insert new List<mpOpportunity__c>{masterMO,master2,masterNoAB};
        //支部追加
        mpOpportunity__c branchMO = TestDataFactory.createMpOpportunity('支部追加',mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, 'RecordTypeAddBrunch'),false);
        branchMO.Branch__c = masterMO.Id;
        mpOpportunity__c branch2 = branchMO.clone();
        branch2.Name = '本部2支部2';
        branch2.Branch__c = master2.Id;
        mpOpportunity__c branch3 = branch2.clone();
        branch3.Name = '本部2支部3';
        Insert new List<mpOpportunity__c>{branchMO,branch2,branch3};
        // 案件作成
        Opportunity opp = TestDataFactory.createOpportunity('個店案件', acc.Id, Date.newInstance(2022, 9, 30), 'OpportunityRecordType_IndivSales', false);
        opp.CRMDPMpOppId__c = masterMO.Id;
        Opportunity opp2 = TestDataFactory.createOpportunity('個店案件2', acc2.Id, Date.newInstance(2022, 9, 30), 'OpportunityRecordType_IndivSales', false);
        opp2.CRMDPMpOppId__c = master2.Id;
        Opportunity oppNoAB = opp2.clone();
        oppNoAB.Name ='個店案件3本部あり支部無し';
        oppNoAB.CRMDPMpOppId__c = masterNoAB.Id;
        Insert new List<Opportunity>{opp,opp2,oppNoAB};
    }
    @isTest
    private static void test_successGiant() {
        Test.startTest();
        CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun([Select Id from mpOpportunity__c where Name = '本部'][0].Id,1);
        Test.stopTest();
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '支部追加'][0].AccountId__c == [Select Id from Account where Name ='テスト企業'][0].Id);
        CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun([Select Id from mpOpportunity__c where Name = '本部2'][0].Id,1);
        System.assert([Select Id,AccountId__c from mpOpportunity__c where AccountId__c !=null AND Name LIKE '%本部2%'].size()==1);
        CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun([Select Id from mpOpportunity__c where Name = '本部2'][0].Id,1);
        System.assert([Select Id,AccountId__c from mpOpportunity__c where AccountId__c !=null AND Name LIKE '%本部2%'].size()==2);
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '本部2支部2'][0].AccountId__c == [Select Id from Account where Name ='企業2'][0].Id);
        
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPAdBrchMpOppAccountIdBatch.BATCH_NAME
            AND Level__c = 'INFO'
        ][0].Detail__c;
        System.assert(logText.contains('対象件数:1'));
        System.assert(logText.contains('更新件数:1'));
        System.assert(logText.contains('エラー件数:0'));
        //ログ内容適切性肉眼確認
        System.debug(logText);
    }
    @isTest
    private static void test_successGiantWithSize() {
        Test.startTest();
        CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun([Select Id from mpOpportunity__c where Name = '本部2'][0].Id,2);
        Test.stopTest();
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '支部追加'][0].AccountId__c == null);
        System.assert([Select Id,AccountId__c from mpOpportunity__c where AccountId__c !=null AND Name LIKE '%本部2%'].size()==2);
        
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPAdBrchMpOppAccountIdBatch.BATCH_NAME
            AND Level__c = 'INFO'
        ][0].Detail__c;
        System.assert(logText.contains('対象件数:2'));
        System.assert(logText.contains('更新件数:2'));
        System.assert(logText.contains('エラー件数:0'));
        //ログ内容適切性肉眼確認
        System.debug(logText);
    }
    @isTest
    //正常系、複数企業複数アタックリスト更新
    private static void test_success() {
        Test.startTest();
        Database.executeBatch(new CRMDPAdBrchMpOppAccountIdBatch(), 200);
        Test.stopTest();
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '支部追加'][0].AccountId__c == [Select Id from Account where Name ='テスト企業'][0].Id);
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '本部2支部2'][0].AccountId__c == [Select Id from Account where Name ='企業2'][0].Id);
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '本部2支部3'][0].AccountId__c == [Select Id from Account where Name ='企業2'][0].Id);
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPAdBrchMpOppAccountIdBatch.BATCH_NAME
            AND Level__c = 'INFO'
        ][0].Detail__c;
        System.assert(logText.length()>0);
        //ログ内容適切性肉眼確認
        System.debug(logText);
    }
    @isTest
    //正常系、複数企業複数アタックリスト更新 案件日付指定
    private static void test_successWithOppCreatedDate() {
        Test.startTest();
        CRMDPAdBrchMpOppAccountIdBatch oneBth = new CRMDPAdBrchMpOppAccountIdBatch();
        oneBth.targetOppCreatedTimeStart=Datetime.newInstance(Date.Today(),Time.newInstance(0, 0, 0, 0));
        Database.executeBatch(oneBth, 200);
        Test.stopTest();
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '支部追加'][0].AccountId__c == [Select Id from Account where Name ='テスト企業'][0].Id);
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '本部2支部2'][0].AccountId__c == [Select Id from Account where Name ='企業2'][0].Id);
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '本部2支部3'][0].AccountId__c == [Select Id from Account where Name ='企業2'][0].Id);
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPAdBrchMpOppAccountIdBatch.BATCH_NAME
            AND Level__c = 'INFO'
        ][0].Detail__c;
        System.assert(logText.length()>0);
        //ログ内容適切性肉眼確認
        System.debug(logText);
    }
    @isTest
    //正常系、アタックリスト更新0件、案件作成日指定
    private static void test_successZeroWithOppCreatedDate() {
        Test.startTest();
        CRMDPAdBrchMpOppAccountIdBatch oneBth = new CRMDPAdBrchMpOppAccountIdBatch();
        oneBth.targetOppCreatedTimeStart=Datetime.newInstance(Date.Today().addDays(1),Time.newInstance(0, 0, 0, 0));
        Database.executeBatch(oneBth, 200);
        Test.stopTest();
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '支部追加'][0].AccountId__c <> [Select Id from Account where Name ='テスト企業'][0].Id);
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '本部2支部2'][0].AccountId__c <> [Select Id from Account where Name ='企業2'][0].Id);
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '本部2支部3'][0].AccountId__c <> [Select Id from Account where Name ='企業2'][0].Id);
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPAdBrchMpOppAccountIdBatch.BATCH_NAME
            AND Level__c = 'INFO'
        ][0].Detail__c;
        System.assert(logText.length()>0);
        System.assert(logText.contains('更新件数:0'));
        System.assert(logText.contains('エラー件数:0'));
        //ログ内容適切性肉眼確認
        System.debug(logText);
    }
    @isTest
    //更新対象0件テスト、本部が無いため更新しない
    private static void test_successZero() {
        List<Opportunity> oppsAll = [Select Id,CRMDPMpOppId__c from Opportunity limit 10];
        for(Opportunity opp : oppsAll){
            opp.CRMDPMpOppId__c = null;
        }
        update oppsAll;
        Test.startTest();
        Database.executeBatch(new CRMDPAdBrchMpOppAccountIdBatch(), 100);
        Test.stopTest();
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '支部追加'][0].AccountId__c == null);
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPAdBrchMpOppAccountIdBatch.BATCH_NAME
            AND Level__c = 'INFO'
        ][0].Detail__c;
        System.assert(logText.length()>0);
        System.assert(logText.contains('更新件数:0'));
        System.assert(logText.contains('エラー件数:0'));
        //ログ内容適切性肉眼確認
        System.debug(logText);
    }
    @isTest
    //本部あり支部無しだけで分岐ソースをカバー
    private static void test_successZeroAddBrunchInExec() {
        List<Opportunity> oppsWithAB = [Select Id from Opportunity where not Name like '%個店案件3本部あり支部無し%'];
        delete oppsWithAB; 
        Test.startTest();
        Database.executeBatch(new CRMDPAdBrchMpOppAccountIdBatch(), 100);
        Test.stopTest();
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPAdBrchMpOppAccountIdBatch.BATCH_NAME
            AND Level__c = 'INFO'
        ][0].Detail__c;
        //ログ内容適切性肉眼確認
        System.debug(logText);
        System.assert(logText.contains('0'));
        System.assert(logText.contains('更新件数:1'));
        System.assert(logText.contains('エラー件数:0'));
        
    }
    @isTest
    //異常系 未更新　ログにId記録済
    private static void test_failure() {
        Test.startTest();
        CRMDPAdBrchMpOppAccountIdBatch.isDMLExceptionTest = true;
        Database.executeBatch(new CRMDPAdBrchMpOppAccountIdBatch(), 200);
        Test.stopTest();
        System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '支部追加'][0].AccountId__c == null);
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPAdBrchMpOppAccountIdBatch.BATCH_NAME
            AND Level__c = 'ERROR'
        ][0].Detail__c;
        System.assert(logText.contains(
            [Select Id,AccountId__c from mpOpportunity__c where Name = '支部追加'][0].Id
        ));
        //ログ内容適切性肉眼確認
        System.debug(logText);
        System.assert(logText.contains('0'));
        System.assert(logText.contains('更新失敗'));
    }

//大型本部実行異常系 未更新　ログにId記録済
@isTest
private static void test_failureGiant() {
    Test.startTest();
    CRMDPAdBrchMpOppAccountIdBatch.isDMLExceptionTest = true;
    CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun([Select Id from mpOpportunity__c where Name = '本部'][0].Id,1);
    Test.stopTest();
    System.assert([Select Id,AccountId__c from mpOpportunity__c where Name = '支部追加'][0].AccountId__c == null);
    String logText = [
        SELECT Id, Title__c, Detail__c
        FROM Log__c
        WHERE Title__c = :CRMDPAdBrchMpOppAccountIdBatch.BATCH_NAME
        AND Level__c = 'ERROR'
    ][0].Detail__c;
    System.assert(logText.contains(
        [Select Id,AccountId__c from mpOpportunity__c where Name = '支部追加'][0].Id
    ));
    System.assert(logText.contains('更新失敗'));
    //ログ内容適切性肉眼確認
    System.debug(logText);
}

    
}