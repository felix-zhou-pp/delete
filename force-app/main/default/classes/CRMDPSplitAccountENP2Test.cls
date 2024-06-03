@isTest
public class CRMDPSplitAccountENP2Test {
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

        User user1 = TestDataFactory.createUser('user1_1', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
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
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.OrderProgressId__c = op2.Id;
        mpopp3.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        cur1.Account__c = acc1.Id;
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        cur2.Account__c = acc1.Id;
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        cur3.Account__c = acc1.Id;
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3};
 
        Set<Id> mpoppids = new Set<Id>{mpopp1.Id,mpopp2.Id,mpopp3.Id};
        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id};

        for (mpOpportunity__c rec : [SELECT Id, AccountId__c, OrderProgressId__r.OpportunityId__c FROM mpOpportunity__c WHERE Id = :mpoppids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            Id oppid = rec.Id == mpopp1.Id ? opp1.Id
                    : rec.Id == mpopp2.Id ? opp2.Id
                    : rec.Id == mpopp3.Id ? opp2.Id
                    : null;
            System.assertEquals(oppid, rec.OrderProgressId__r.OpportunityId__c);
        }
        for (mpMerchant__c rec : [SELECT Id, AccountId__c, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, MerchantId__c FROM mpMerchant__c WHERE Id = :merids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            Id oppid = rec.Id == mer1.Id ? opp1.Id
                    : rec.Id == mer2.Id ? opp2.Id
                    : rec.Id == mer3.Id ? opp2.Id
                    : null;
            System.assertEquals(oppid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__c);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }
        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, Account__c, UniqueId__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Map<Id, Id> oppAccIdMap = new Map<Id, Id>{
            opp1.Id => acc2.Id
            ,opp2.Id => acc3.Id
        };
        Test.startTest();
        Database.executeBatch(new CRMDPSplitAccountENP2(oppAccIdMap), 2000);
        Test.stopTest();

        for (mpOpportunity__c rec : [SELECT Id, AccountId__c, OrderProgressId__r.OpportunityId__c FROM mpOpportunity__c WHERE Id = :mpoppids]) {
            Id accid = rec.Id == mpopp1.Id ? acc2.Id
                    : rec.Id == mpopp2.Id ? acc3.Id
                    : rec.Id == mpopp3.Id ? acc3.Id
                    : null;
            System.assertEquals(accid, rec.AccountId__c);
        }
        for (mpMerchant__c rec : [SELECT Id, AccountId__c, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, MerchantId__c FROM mpMerchant__c WHERE Id = :merids]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id
                    : rec.Id == mer2.Id ? acc3.Id
                    : rec.Id == mer3.Id ? acc3.Id
                    : null;
            System.assertEquals(accid, rec.AccountId__c);
        }
        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, Account__c, UniqueId__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            Id accid = rec.Id == cur1.Id ? acc2.Id
                    : rec.Id == cur2.Id ? acc3.Id
                    : rec.Id == cur3.Id ? acc3.Id
                    : null;
            System.assertEquals(acc1.Id, rec.Account__c);
        }
    }

    // レコードが欠けてる
    @isTest
    private static void execute2() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        insert new List<Account>{acc1,acc2};

        User user1 = TestDataFactory.createUser('user1_1', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
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
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1};

        Set<Id> mpoppids = new Set<Id>{mpopp1.Id,mpopp2.Id};
        Set<Id> merids = new Set<Id>{mer1.Id};

        for (mpOpportunity__c rec : [SELECT Id, AccountId__c, OrderProgressId__r.OpportunityId__c FROM mpOpportunity__c WHERE Id = :mpoppids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            Id oppid = rec.Id == mpopp1.Id ? opp1.Id
                    : rec.Id == mpopp2.Id ? opp2.Id
                    : null;
            System.assertEquals(oppid, rec.OrderProgressId__r.OpportunityId__c);
        }
        for (mpMerchant__c rec : [SELECT Id, AccountId__c, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, MerchantId__c FROM mpMerchant__c WHERE Id = :merids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            Id oppid = rec.Id == mer1.Id ? opp1.Id
                    : null;
            System.assertEquals(oppid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__c);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        Map<Id, Id> oppAccIdMap = new Map<Id, Id>{
            opp1.Id => acc2.Id
            ,opp2.Id => acc2.Id
        };
        Test.startTest();
        Database.executeBatch(new CRMDPSplitAccountENP2(oppAccIdMap), 2000);
        Test.stopTest();

        for (mpOpportunity__c rec : [SELECT Id, AccountId__c, OrderProgressId__r.OpportunityId__c FROM mpOpportunity__c WHERE Id = :mpoppids]) {
            Id accid = rec.Id == mpopp1.Id ? acc2.Id
                    : rec.Id == mpopp2.Id ? acc2.Id
                    : null;
            System.assertEquals(accid, rec.AccountId__c);
        }
        for (mpMerchant__c rec : [SELECT Id, AccountId__c, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, MerchantId__c FROM mpMerchant__c WHERE Id = :merids]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id
                    : null;
            System.assertEquals(accid, rec.AccountId__c);
        }
    }

    // 付け替え先取引先がない（正常な方は更新される）
    @isTest
    private static void execute3() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        insert new List<Account>{acc1,acc2};

        User user1 = TestDataFactory.createUser('user1_1', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
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
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        cur1.Account__c = acc1.Id;
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        cur2.Account__c = acc1.Id;
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};
 
        Set<Id> mpoppids = new Set<Id>{mpopp1.Id,mpopp2.Id};
        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (mpOpportunity__c rec : [SELECT Id, AccountId__c, OrderProgressId__r.OpportunityId__c FROM mpOpportunity__c WHERE Id = :mpoppids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            Id oppid = rec.Id == mpopp1.Id ? opp1.Id
                    : rec.Id == mpopp2.Id ? opp2.Id
                    : null;
            System.assertEquals(oppid, rec.OrderProgressId__r.OpportunityId__c);
        }
        for (mpMerchant__c rec : [SELECT Id, AccountId__c, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, MerchantId__c FROM mpMerchant__c WHERE Id = :merids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            Id oppid = rec.Id == mer1.Id ? opp1.Id
                    : rec.Id == mer2.Id ? opp2.Id
                    : null;
            System.assertEquals(oppid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__c);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }
        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, Account__c, UniqueId__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Map<Id, Id> oppAccIdMap = new Map<Id, Id>{
            opp1.Id => acc2.Id
            ,opp2.Id => null
        };
        Test.startTest();
        Database.executeBatch(new CRMDPSplitAccountENP2(oppAccIdMap), 2000);
        Test.stopTest();

        for (mpOpportunity__c rec : [SELECT Id, AccountId__c, OrderProgressId__r.OpportunityId__c FROM mpOpportunity__c WHERE Id = :mpoppids]) {
            Id accid = rec.Id == mpopp1.Id ? acc2.Id
                    : rec.Id == mpopp2.Id ? acc1.Id
                    : null;
            System.assertEquals(accid, rec.AccountId__c);
        }
        for (mpMerchant__c rec : [SELECT Id, AccountId__c, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, MerchantId__c FROM mpMerchant__c WHERE Id = :merids]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id
                    : rec.Id == mer2.Id ? acc1.Id
                    : null;
            System.assertEquals(accid, rec.AccountId__c);
        }
        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, Account__c, UniqueId__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            Id accid = rec.Id == cur1.Id ? acc2.Id
                    : rec.Id == cur2.Id ? acc1.Id
                    : null;
            System.assertEquals(acc1.Id, rec.Account__c);
        }
    }

    // 引数に案件IDがない（正常な方は更新される）
    @isTest
    private static void execute4() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        Account acc3 = TestDataFactory.createAccount('acc2', false);
        insert new List<Account>{acc1,acc2,acc3};

        User user1 = TestDataFactory.createUser('user1_1', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp3', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        cur1.Account__c = acc1.Id;
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        cur2.Account__c = acc1.Id;
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};
 
        Set<Id> mpoppids = new Set<Id>{mpopp1.Id,mpopp2.Id};
        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (mpOpportunity__c rec : [SELECT Id, AccountId__c, OrderProgressId__r.OpportunityId__c FROM mpOpportunity__c WHERE Id = :mpoppids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            Id oppid = rec.Id == mpopp1.Id ? opp1.Id
                    : rec.Id == mpopp2.Id ? opp2.Id
                    : null;
            System.assertEquals(oppid, rec.OrderProgressId__r.OpportunityId__c);
        }
        for (mpMerchant__c rec : [SELECT Id, AccountId__c, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, MerchantId__c FROM mpMerchant__c WHERE Id = :merids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            Id oppid = rec.Id == mer1.Id ? opp1.Id
                    : rec.Id == mer2.Id ? opp2.Id
                    : null;
            System.assertEquals(oppid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__c);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }
        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, Account__c, UniqueId__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Map<Id, Id> oppAccIdMap = new Map<Id, Id>{
            opp1.Id => acc2.Id
            ,opp3.Id => acc3.Id
        };
        Test.startTest();
        Database.executeBatch(new CRMDPSplitAccountENP2(oppAccIdMap), 2000);
        Test.stopTest();

        for (mpOpportunity__c rec : [SELECT Id, AccountId__c, OrderProgressId__r.OpportunityId__c FROM mpOpportunity__c WHERE Id = :mpoppids]) {
            Id accid = rec.Id == mpopp1.Id ? acc2.Id
                    : rec.Id == mpopp2.Id ? acc1.Id
                    : null;
            System.assertEquals(accid, rec.AccountId__c);
        }
        for (mpMerchant__c rec : [SELECT Id, AccountId__c, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, MerchantId__c FROM mpMerchant__c WHERE Id = :merids]) {
            Id accid = rec.Id == mer1.Id ? acc2.Id
                    : rec.Id == mer2.Id ? acc1.Id
                    : null;
            System.assertEquals(accid, rec.AccountId__c);
        }
        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, Account__c, UniqueId__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            Id accid = rec.Id == cur1.Id ? acc2.Id
                    : rec.Id == cur2.Id ? acc1.Id
                    : null;
            System.assertEquals(acc1.Id, rec.Account__c);
        }
    }

    // 包括代理店データ（更新されない）
    @isTest
    private static void execute5() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        Account acc4 = TestDataFactory.createAccount('acc4', false);
        insert new List<Account>{acc1,acc2,acc3,acc4};

        User user1 = TestDataFactory.createUser('user1_1', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm4 = TestDataFactory.createAccountTeamMember(acc4.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3,atm4};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp3', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_PARTNER_ONLINE, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc1.Id, opp3.Id, RECORDTYPEID_OP_DIRECT_SMB, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc1.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.OrderProgressId__c = op3.Id;
        mpopp3.AccountId__c = acc1.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc1.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc1.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc1.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        cur1.Account__c = acc1.Id;
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        cur2.Account__c = acc1.Id;
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        cur3.Account__c = acc1.Id;
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3};
 
        Set<Id> mpoppids = new Set<Id>{mpopp1.Id,mpopp2.Id,mpopp3.Id};
        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id};

        for (mpOpportunity__c rec : [SELECT Id, AccountId__c, OrderProgressId__r.OpportunityId__c, OrderProgressId__r.RecordTypeId FROM mpOpportunity__c WHERE Id = :mpoppids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            Id oppid = rec.Id == mpopp1.Id ? opp1.Id
                    : rec.Id == mpopp2.Id ? opp2.Id
                    : rec.Id == mpopp3.Id ? opp3.Id
                    : null;
            System.assertEquals(oppid, rec.OrderProgressId__r.OpportunityId__c);
            Id rectypeid = rec.Id == mpopp1.Id ? RECORDTYPEID_OP_PAY_PARTNER
                        : rec.Id == mpopp2.Id ? RECORDTYPEID_OP_PARTNER_ONLINE
                        : rec.Id == mpopp3.Id ? RECORDTYPEID_OP_DIRECT_SMB
                        : null;
            System.assertEquals(rectypeid, rec.OrderProgressId__r.RecordTypeId);
        }
        for (mpMerchant__c rec : [SELECT Id, AccountId__c, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, MerchantId__c FROM mpMerchant__c WHERE Id = :merids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
            Id oppid = rec.Id == mer1.Id ? opp1.Id
                    : rec.Id == mer2.Id ? opp2.Id
                    : rec.Id == mer3.Id ? opp3.Id
                    : null;
            System.assertEquals(oppid, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__c);
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }
        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, Account__c, UniqueId__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.Account__c);
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
        }

        Map<Id, Id> oppAccIdMap = new Map<Id, Id>{
            opp1.Id => acc2.Id
            ,opp2.Id => acc3.Id
            ,opp3.Id => acc4.Id
        };
        Test.startTest();
        Database.executeBatch(new CRMDPSplitAccountENP2(oppAccIdMap), 2000);
        Test.stopTest();

        for (mpOpportunity__c rec : [SELECT Id, AccountId__c, OrderProgressId__r.OpportunityId__c FROM mpOpportunity__c WHERE Id = :mpoppids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
        }
        for (mpMerchant__c rec : [SELECT Id, AccountId__c, mpOpportunity__r.OrderProgressId__r.OpportunityId__c, MerchantId__c FROM mpMerchant__c WHERE Id = :merids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.AccountId__c);
        }
        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, Account__c, UniqueId__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            Id accid = acc1.Id;
            System.assertEquals(accid, rec.Account__c);
        }
    }

}