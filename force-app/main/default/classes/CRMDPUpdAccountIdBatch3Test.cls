@isTest
public class CRMDPUpdAccountIdBatch3Test {
    public static final Id RECORDTYPEID_OP_OFF = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PayEnterprise');
    public static final Id RECORDTYPEID_OP_PAY_PARTNER = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER);
    public static final Id RECORDTYPEID_OP_PARTNER_ONLINE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE);
    public static final Id RECORDTYPEID_OP_DIRECT_SMB = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB);
    public static final Id RECORDTYPEID_MPOPP_MPLIST = mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, 'mpList');

    // 通常
    @isTest
    private static void execute1() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp3', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.OrderProgressId__c = op2.Id;
        mpopp3.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        // 更新：1取引先で複数
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        // 更新：1取引先で複数
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc2.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc3.Id;
        cur2.UniqueId__c = '123456789012345002';
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.Account__c = acc3.Id;
        cur3.UniqueId__c = '123456789012345003';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id};

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, UniqueId__c, Account__c
            FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids
        ]) {
            Id accid = rec.Id == cur1.Id ? acc2.Id
                    : rec.Id == cur2.Id ? acc3.Id
                    : rec.Id == cur3.Id ? acc3.Id
                    : null;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch3.run();
        Test.stopTest();

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id
                    : rec.Id == mer2.Id ? acc3.Id
                    : rec.Id == mer3.Id ? acc3.Id
                    : null;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
        }
    }

    // 案件空
    @isTest
    private static void execute3() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        insert new List<Account>{acc1,acc2};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        // 更新：1取引先で複数
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc2.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc2.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(rec.Id == mer2.Id ? null : accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(rec.Id == mer2.Id ? null : accid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, UniqueId__c, Account__c
            FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids
        ]) {
            Id accid = rec.Id == cur1.Id ? acc2.Id
                    : rec.Id == cur2.Id ? acc2.Id
                    : null;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch3.run();
        Test.stopTest();

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = rec.Id == mer2.Id ? acc1.Id : acc2.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(rec.Id == mer2.Id ? null : acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(rec.Id == mer2.Id ? null : acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
        }
    }

    // リレーション取引先空
    @isTest
    private static void execute4() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        insert new List<Account>{acc1,acc2};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        // 更新：1取引先で複数
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc2.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, UniqueId__c, Account__c
            FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids
        ]) {
            Id accid = rec.Id == cur1.Id ? acc2.Id
                    : null;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch3.run();
        Test.stopTest();

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id : acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
        }
    }

    // リレーションデータなし
    @isTest
    private static void execute5() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        insert new List<Account>{acc1,acc2};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        // 更新：1取引先で複数
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc2.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, UniqueId__c, Account__c
            FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids
        ]) {
            Id accid = rec.Id == cur1.Id ? acc2.Id
                    : null;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch3.run();
        Test.stopTest();

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id : acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
        }
    }

    // 同アタックリストのリレーションデータ間で取引先が異なる
    @isTest
    private static void execute7() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        // 更新：1取引先で複数
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp1.Id;
        mer2.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc2.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc3.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, UniqueId__c, Account__c
            FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids
        ]) {
            Id accid = rec.Id == cur1.Id ? acc2.Id
                    : rec.Id == cur2.Id ? acc3.Id
                    : null;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch3.run();
        Test.stopTest();

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id
                    : rec.Id == mer2.Id ? acc3.Id
                    : null;
            System.assert(rec.mpOpportunity__r.AccountId__c == acc2.Id || rec.mpOpportunity__r.AccountId__c == acc3.Id);
            System.assert(rec.AccountId__c == acc2.Id || rec.AccountId__c == acc3.Id);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
        }
    }

    // 更新済み
    @isTest
    private static void execute8() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        insert new List<Account>{acc1,acc2};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc2.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc2.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc2.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc2.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc2.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc2.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc2.Id;
        // 更新：1取引先で複数
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc2.Id;
        insert new List<mpMerchant__c>{mer1,mer2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc2.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc2.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = acc2.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, UniqueId__c, Account__c
            FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids
        ]) {
            Id accid = rec.Id == cur1.Id ? acc2.Id
                    : rec.Id == cur2.Id ? acc2.Id
                    : null;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch3.run();
        Test.stopTest();

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = acc2.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
        }
    }

    // 加盟店ID指定
    @isTest
    private static void execute9() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        insert new List<Account>{acc1,acc2};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        // 更新：1取引先で複数
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc2.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc2.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, UniqueId__c, Account__c
            FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids
        ]) {
            Id accid = rec.Id == cur1.Id ? acc2.Id
                    : rec.Id == cur2.Id ? acc2.Id
                    : null;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch3.run(new Set<Id>{mer1.Id});
        Test.stopTest();

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id : acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
        }
    }

    // 企業分割
    @isTest
    private static void execute10() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        insert new List<Account>{acc1,acc2};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        // 更新：1取引先で複数
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc2.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc2.Id;
        cur2.UniqueId__c = '123456789012345002';
        cur2.SFReplacementCandidateFlag__c = true;
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, UniqueId__c, Account__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids
        ]) {
            System.assertEquals(acc2.Id, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            Boolean bool = rec.Id == cur1.Id ? false
                        : rec.Id == cur2.Id ? true
                        : null;
            System.assertEquals(bool, rec.SFReplacementCandidateFlag__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch3.run();
        Test.stopTest();

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id : acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
        }
    }

    // 個店
    @isTest
    private static void execute11() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        insert new List<Account>{acc1,acc2};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_IndivSales', false);
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        // 更新：1取引先で複数
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc2.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc2.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, UniqueId__c, Account__c
            FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids
        ]) {
            System.assertEquals(acc2.Id, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch3.run();
        Test.stopTest();

        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id : acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc1.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);
        }
    }

}