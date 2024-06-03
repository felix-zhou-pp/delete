@isTest
public class CRMDPUpdAccountIdBatchTest {
    // 決裁事業用
    public static final Id RECORDTYPEID_OP_PAY_PARTNER = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER);
    // 加盟店事業用
    public static final Id RECORDTYPEID_OP_PLC = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PLC);
    public static final Id RECORDTYPEID_OP_PAY_ENTERPRISE_MYSTORE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE_MYSTORE);

    public static final Id RECORDTYPEID_ACC_MEMBER = mpUtilString.getRecordTypeByDeveloperName(Account.sObjectType, Constant.ACC_DEVELOPER_NAME_MEMBER);

    public static final List<String> opRecordType = new List<String>{
        Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER
        ,Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE
        ,Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE
        ,'US_SS'
        ,Constant.ORDP_DEVELOPER_NAME_ENP_ONLINE
        ,Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER_VENDING
        ,Constant.ORDP_DEVELOPER_NAME_ENPMALL_ONLINE
        ,Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB
        ,'RecordTypeOfflineSmallBusiness'
        ,'RecordTypeOnlineSmallBusiness'
        ,Constant.ORDP_DEVELOPER_NAME_ENP_ONLINE_MANAGE
    };

    public static final List<String> opmbRecordType = new List<String>{
        Constant.ORDP_DEVELOPER_NAME_PLC
        ,Constant.ORDP_DEVELOPER_NAME_ONLINE_PLC
        ,Constant.ORDP_DEVELOPER_NAME_REVISITING_COUPON
        ,Constant.ORDP_DEVELOPER_NAME_SCHEDULED_COUPON
        ,Constant.ORDP_DEVELOPER_NAME_SC
        ,Constant.ORDP_DEVELOPER_NAME_FLYER_APPLY
        ,'FlyerDraft'
        ,Constant.ORDP_DEVELOPER_NAME_PAAS
        ,Constant.ORDP_DEVELOPER_NAME_PC
        ,Constant.ORDP_DEVELOPER_NAME_CAMPAIGN
        ,Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE_MYSTORE
        ,Constant.ORDP_DEVELOPER_NAME_MINI_APP
        ,Constant.ORDP_DEVELOPER_NAME_BALANCEAPI
        ,Constant.ORDP_DEVELOPER_NAME_SPECIFIC_PRODUCT_COUPON
        ,'ServiceCommon'
        ,Constant.ORDP_DEVELOPER_NAME_ROUTEOPENING
        ,Constant.ORDP_DEVELOPER_NAME_RETAILGIFT
        ,Constant.ORDP_DEVELOPER_NAME_LYPMILEAGE
        ,Constant.ORDP_DEVELOPER_NAME_GIFTCARD
    };

    public static final Set<String> opRecordType1 = new Set<String>{
        Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE
        ,'US_SS'
        ,Constant.ORDP_DEVELOPER_NAME_ENP_ONLINE
        ,Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER_VENDING
    };
    public static final Set<String> opRecordType2 = new Set<String>{
        Constant.ORDP_DEVELOPER_NAME_ENPMALL_ONLINE
        ,'RecordTypeOfflineSmallBusiness'
        ,'RecordTypeOnlineSmallBusiness'
        ,Constant.ORDP_DEVELOPER_NAME_ENP_ONLINE_MANAGE
    };
    public static final Set<String> agencyRecordType = new Set<String>{
        Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER
        ,Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE
        ,Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB
    };
    public static final Set<String> mbRecordType1 = new Set<String>{
        Constant.ORDP_DEVELOPER_NAME_PLC
        ,Constant.ORDP_DEVELOPER_NAME_ONLINE_PLC
        ,Constant.ORDP_DEVELOPER_NAME_REVISITING_COUPON
        ,Constant.ORDP_DEVELOPER_NAME_SCHEDULED_COUPON
        ,Constant.ORDP_DEVELOPER_NAME_SC
    };
    public static final Set<String> mbRecordType2 = new Set<String>{
        Constant.ORDP_DEVELOPER_NAME_FLYER_APPLY
        ,'FlyerDraft'
        ,Constant.ORDP_DEVELOPER_NAME_PAAS
        ,Constant.ORDP_DEVELOPER_NAME_PC
        ,Constant.ORDP_DEVELOPER_NAME_CAMPAIGN
    };
    public static final Set<String> mbRecordType3 = new Set<String>{
        Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE_MYSTORE
        ,Constant.ORDP_DEVELOPER_NAME_MINI_APP
        ,Constant.ORDP_DEVELOPER_NAME_BALANCEAPI
        ,Constant.ORDP_DEVELOPER_NAME_SPECIFIC_PRODUCT_COUPON
        ,'ServiceCommon'
    };
    public static final Set<String> mbRecordType4 = new Set<String>{
        Constant.ORDP_DEVELOPER_NAME_ROUTEOPENING
        ,Constant.ORDP_DEVELOPER_NAME_RETAILGIFT
        ,Constant.ORDP_DEVELOPER_NAME_LYPMILEAGE
        ,Constant.ORDP_DEVELOPER_NAME_GIFTCARD
        // ,Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER
        // ,Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE
        // ,Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB
    };

    // 通常（法人番号）
    @isTest
    private static void execute1_1_cn() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(opRecordType1);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals('1234567890002', rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc2.Id, rec.AccountId__c);
            System.assertEquals(acc2.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（法人番号）
    @isTest
    private static void execute1_2_cn() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(opRecordType2);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals('1234567890002', rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc2.Id, rec.AccountId__c);
            System.assertEquals(acc2.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（法人番号）
    @isTest
    private static void execute1_3_cn() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(agencyRecordType);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals('1234567890002', rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc2.Id, rec.AccountId__c);
            System.assertEquals(acc2.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（法人番号）
    @isTest
    private static void execute1_4_cn() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(mbRecordType1);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals('1234567890002', rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc2.Id, rec.AccountId__c);
            System.assertEquals(acc2.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（法人番号）
    @isTest
    private static void execute1_5_cn() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(mbRecordType2);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals('1234567890002', rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc2.Id, rec.AccountId__c);
            System.assertEquals(acc2.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（法人番号）
    @isTest
    private static void execute1_6_cn() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(mbRecordType3);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals('1234567890002', rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc2.Id, rec.AccountId__c);
            System.assertEquals(acc2.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（法人番号）
    @isTest
    private static void execute1_7_cn() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(mbRecordType4);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals('1234567890002', rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc2.Id, rec.AccountId__c);
            System.assertEquals(acc2.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（メインMID）※法人番号空
    @isTest
    private static void execute2_1_mainmid() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(opRecordType1);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            // opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals(null, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(null, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（メインMID）※法人番号空
    @isTest
    private static void execute2_2_mainmid() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(opRecordType2);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            // opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals(null, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(null, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（メインMID）※法人番号空
    @isTest
    private static void execute2_3_mainmid() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(agencyRecordType);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            // opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals(null, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(null, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（メインMID）※法人番号空
    @isTest
    private static void execute2_4_mainmid() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(mbRecordType1);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            // opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals(null, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc3.Id, rec.AccountId__c);
            System.assertEquals(acc3.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（メインMID）※法人番号空
    @isTest
    private static void execute2_5_mainmid() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(mbRecordType2);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            // opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals(null, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc3.Id, rec.AccountId__c);
            System.assertEquals(acc3.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（メインMID）※法人番号空
    @isTest
    private static void execute2_6_mainmid() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(mbRecordType3);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            // opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals(null, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc3.Id, rec.AccountId__c);
            System.assertEquals(acc3.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 通常（メインMID）※法人番号空
    @isTest
    private static void execute2_7_mainmid() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3};

        List<String> rts = new List<String>();
        rts.addAll(mbRecordType4);

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < rts.size(); i++) {
            Opportunity opp = TestDataFactory.createOpportunity('opp' + (i+1), acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
            // opp.CorporateNumber__c = '1234567890002';
            opps.add(opp);
        }
        insert opps;

        List<OrderProgress__c> ops = new List<OrderProgress__c>();
        for (Integer i = 0; I < opps.size(); i++) {
            Id rtid = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, rts.get(i));
            OrderProgress__c op = TestDataFactory.createOrderProgress('op' + (i+1), acc1.Id, opps.get(i).Id, rtid, false);
            op.MainMID__c = '123456789012345001';
            ops.add(op);
        }
        insert ops;

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc3.Id;
        cur1.UniqueId__c = '123456789012345001';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id};
        Set<Id> oppids = new Set<Id>();
        for (Opportunity rec : opps) {
            oppids.add(rec.Id);
        }
        Set<Id> opids = new Set<Id>();
        for (OrderProgress__c rec : ops) {
            opids.add(rec.Id);
        }
        Set<Id> curids = new Set<Id>{cur1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals(null, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Integer cnt = 0;
        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, RecordType.DeveloperName FROM OrderProgress__c WHERE Id = :opids ORDER BY Id]) {
            System.assertEquals('123456789012345001', rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            System.assertEquals(rts.get(cnt), rec.RecordType.DeveloperName);
            cnt++;
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (OrderProgress__c rec : [SELECT Id, RecordType.DeveloperName, MainMID__c, AccountId__c, OpportunityId__r.AccountId, OpportunityId__r.CRMDPBeforeAccount__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc3.Id, rec.AccountId__c);
            System.assertEquals(acc3.Id, rec.OpportunityId__r.AccountId);
            System.assertEquals(acc1.Id, rec.OpportunityId__r.CRMDPBeforeAccount__c);
        }

    }

    // 取引先の該当なし（法人番号）
    @isTest
    private static void execute3() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc4 = TestDataFactory.createAccount('acc4', false);
        acc4.CorporateNumber__c = '1234567890004';
        acc4.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc5 = TestDataFactory.createAccount('acc5', false);
        acc5.CorporateNumber__c = '1234567890005';
        acc5.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3,acc4,acc5};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm4 = TestDataFactory.createAccountTeamMember(acc4.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm5 = TestDataFactory.createAccountTeamMember(acc5.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3,atm4,atm5};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp1.CorporateNumber__c = '1234567890006';
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp2.CorporateNumber__c = '1234567890003';
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        op1.MainMID__c = '123456789012345001';
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_PLC, false);
        op2.MainMID__c = '123456789012345002';
        insert new List<OrderProgress__c>{op1,op2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc4.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc5.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id,acc4.Id,acc5.Id};
        Set<Id> oppids = new Set<Id>{opp1.Id,opp2.Id};
        Set<Id> opids = new Set<Id>{op1.Id,op2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : rec.Id == acc4.Id ? '1234567890004'
                        : rec.Id == acc5.Id ? '1234567890005'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String cn = rec.Id == opp1.Id ? '1234567890006'
                        : rec.Id == opp2.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String mid = rec.Id == op1.Id ? '123456789012345001'
                        : rec.Id == op2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc4.Id
                        : rec.Id == cur2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String accid = rec.Id == opp1.Id ? acc1.Id
                        : rec.Id == opp2.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.AccountId);
            String accid2 = rec.Id == opp1.Id ? null
                        : rec.Id == opp2.Id ? acc1.Id
                        : null;
            System.assertEquals(acc1.Id, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String accid = rec.Id == op1.Id ? acc1.Id
                        : rec.Id == op2.Id ? acc3.Id
                        : null;
            System.assertEquals(accid, rec.AccountId__c);
        }

    }

    // 取引先の該当が複数
    @isTest
    private static void execute4() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc4 = TestDataFactory.createAccount('acc4', false);
        acc4.CorporateNumber__c = '1234567890002';
        acc4.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc5 = TestDataFactory.createAccount('acc5', false);
        acc5.CorporateNumber__c = '1234567890003';
        acc5.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3,acc4,acc5};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm4 = TestDataFactory.createAccountTeamMember(acc4.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm5 = TestDataFactory.createAccountTeamMember(acc5.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3,atm4,atm5};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp1.CorporateNumber__c = '1234567890002';
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        // opp2.CorporateNumber__c = '1234567890003';
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        op1.MainMID__c = '123456789012345001';
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_PLC, false);
        op2.MainMID__c = '123456789012345002';
        insert new List<OrderProgress__c>{op1,op2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc4.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc5.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id,acc4.Id,acc5.Id};
        Set<Id> oppids = new Set<Id>{opp1.Id,opp2.Id};
        Set<Id> opids = new Set<Id>{op1.Id,op2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : rec.Id == acc4.Id ? '1234567890002'
                        : rec.Id == acc5.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String cn = rec.Id == opp1.Id ? '1234567890002'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String mid = rec.Id == op1.Id ? '123456789012345001'
                        : rec.Id == op2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc4.Id
                        : rec.Id == cur2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String accid = rec.Id == opp1.Id ? acc1.Id
                        : rec.Id == opp2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.AccountId);
            System.assertEquals(acc1.Id, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String accid = rec.Id == op1.Id ? acc1.Id
                        : rec.Id == op2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.AccountId__c);
        }

    }

    // メインMIDが複数
    @isTest
    private static void execute5() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc4 = TestDataFactory.createAccount('acc4', false);
        acc4.CorporateNumber__c = '1234567890004';
        acc4.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc5 = TestDataFactory.createAccount('acc5', false);
        acc5.CorporateNumber__c = '1234567890005';
        acc5.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3,acc4,acc5};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm4 = TestDataFactory.createAccountTeamMember(acc4.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm5 = TestDataFactory.createAccountTeamMember(acc5.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3,atm4,atm5};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp1.CorporateNumber__c = '1234567890002';
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        // opp2.CorporateNumber__c = '1234567890003';
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        op1.MainMID__c = '123456789012345001';
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_PLC, false);
        op2.MainMID__c = '123456789012345002';
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc1.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        op3.MainMID__c = '123456789012345003';
        OrderProgress__c op4 = TestDataFactory.createOrderProgress('op4', acc1.Id, opp2.Id, RECORDTYPEID_OP_PLC, false);
        op4.MainMID__c = '123456789012345004';
        insert new List<OrderProgress__c>{op1,op2,op3,op4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc4.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc5.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id,acc4.Id,acc5.Id};
        Set<Id> oppids = new Set<Id>{opp1.Id,opp2.Id};
        Set<Id> opids = new Set<Id>{op1.Id,op2.Id,op3.Id,op4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : rec.Id == acc4.Id ? '1234567890004'
                        : rec.Id == acc5.Id ? '1234567890005'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String cn = rec.Id == opp1.Id ? '1234567890002'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String mid = rec.Id == op1.Id ? '123456789012345001'
                        : rec.Id == op2.Id ? '123456789012345002'
                        : rec.Id == op3.Id ? '123456789012345003'
                        : rec.Id == op4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc4.Id
                        : rec.Id == cur2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String accid = rec.Id == opp1.Id ? acc2.Id
                        : rec.Id == opp2.Id ? acc1.Id
                        : null;
            System.assertEquals(accid, rec.AccountId);
            System.assertEquals(acc1.Id, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String accid = rec.Id == op1.Id ? acc2.Id
                        : rec.Id == op2.Id ? acc1.Id
                        : rec.Id == op3.Id ? acc2.Id
                        : rec.Id == op4.Id ? acc1.Id
                        : null;
            System.assertEquals(accid, rec.AccountId__c);
        }

    }

    // サービス管理が空
    @isTest
    private static void execute6() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp1.CorporateNumber__c = '1234567890002';
        insert new List<Opportunity>{opp1};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id};
        Set<Id> oppids = new Set<Id>{opp1.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String cn = rec.Id == opp1.Id ? '1234567890002'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String accid = rec.Id == opp1.Id ? acc1.Id
                        : null;
            System.assertEquals(accid, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

    }

    // 取引先が既存で正しい
    @isTest
    private static void execute7() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc4 = TestDataFactory.createAccount('acc4', false);
        acc4.CorporateNumber__c = '1234567890004';
        acc4.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc5 = TestDataFactory.createAccount('acc5', false);
        acc5.CorporateNumber__c = '1234567890005';
        acc5.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3,acc4,acc5};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm4 = TestDataFactory.createAccountTeamMember(acc4.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm5 = TestDataFactory.createAccountTeamMember(acc5.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3,atm4,atm5};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc2.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp1.CorporateNumber__c = '1234567890002';
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc5.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        // opp2.CorporateNumber__c = '1234567890003';
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc2.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        op1.MainMID__c = '123456789012345001';
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc5.Id, opp2.Id, RECORDTYPEID_OP_PLC, false);
        op2.MainMID__c = '123456789012345002';
        insert new List<OrderProgress__c>{op1,op2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc4.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc5.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id,acc4.Id,acc5.Id};
        Set<Id> oppids = new Set<Id>{opp1.Id,opp2.Id};
        Set<Id> opids = new Set<Id>{op1.Id,op2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : rec.Id == acc4.Id ? '1234567890004'
                        : rec.Id == acc5.Id ? '1234567890005'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String cn = rec.Id == opp1.Id ? '1234567890002'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
            Id accid = rec.Id == opp1.Id ? acc2.Id
                        : rec.Id == opp2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String mid = rec.Id == op1.Id ? '123456789012345001'
                        : rec.Id == op2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MainMID__c);
            Id accid = rec.Id == op1.Id ? acc2.Id
                        : rec.Id == op2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.AccountId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc4.Id
                        : rec.Id == cur2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String accid = rec.Id == opp1.Id ? acc2.Id
                        : rec.Id == opp2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.AccountId);
            System.assertEquals(accid, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String accid = rec.Id == op1.Id ? acc2.Id
                        : rec.Id == op2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.AccountId__c);
        }

    }

    // 取引先の該当なし（メインMID）
    @isTest
    private static void execute8() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc4 = TestDataFactory.createAccount('acc4', false);
        acc4.CorporateNumber__c = '1234567890004';
        acc4.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc5 = TestDataFactory.createAccount('acc5', false);
        acc5.CorporateNumber__c = '1234567890005';
        acc5.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3,acc4,acc5};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm4 = TestDataFactory.createAccountTeamMember(acc4.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm5 = TestDataFactory.createAccountTeamMember(acc5.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3,atm4,atm5};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        // opp1.CorporateNumber__c = '1234567890002';
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        // opp2.CorporateNumber__c = '1234567890003';
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_PLC, false);
        op1.MainMID__c = '123456789012345002';
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_PLC, false);
        op2.MainMID__c = '123456789012345003';
        insert new List<OrderProgress__c>{op1,op2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc4.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        // cur2.Account__c = acc5.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id,acc4.Id,acc5.Id};
        Set<Id> oppids = new Set<Id>{opp1.Id,opp2.Id};
        Set<Id> opids = new Set<Id>{op1.Id,op2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : rec.Id == acc4.Id ? '1234567890004'
                        : rec.Id == acc5.Id ? '1234567890005'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String cn = rec.Id == opp1.Id ? '1234567890006'
                        : rec.Id == opp2.Id ? '1234567890003'
                        : null;
            System.assertEquals(null, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String mid = rec.Id == op1.Id ? '123456789012345002'
                        : rec.Id == op2.Id ? '123456789012345003'
                        : null;
            System.assertEquals(mid, rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc4.Id
                        : rec.Id == cur2.Id ? null
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String accid = rec.Id == opp1.Id ? acc1.Id
                        : rec.Id == opp2.Id ? acc5.Id
                        : null;
            System.assertEquals(acc1.Id, rec.AccountId);
            String accid2 = rec.Id == opp1.Id ? null
                        : rec.Id == opp2.Id ? acc1.Id
                        : null;
            System.assertEquals(acc1.Id, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String accid = rec.Id == op1.Id ? acc1.Id
                        : rec.Id == op2.Id ? acc5.Id
                        : null;
            System.assertEquals(acc1.Id, rec.AccountId__c);
        }

    }

    // サービス管理が空（子サービス管理のみ）、加盟店事業でメインMIDがない
    @isTest
    private static void execute9() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2};

        Opportunity opp = TestDataFactory.createOpportunity('opp', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp1.CorporateNumber__c = '1234567890002';
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp2.CorporateNumber__c = '1234567890002';
        insert new List<Opportunity>{opp,opp1,opp2};

        OrderProgress__c op = TestDataFactory.createOrderProgress('op', acc1.Id, opp.Id, RECORDTYPEID_OP_PAY_ENTERPRISE_MYSTORE, true);
        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        op1.CopyOrderProgressId__c = op.Id;
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        op2.MyStoreRelation__c = op.Id;
        insert new List<OrderProgress__c>{op1,op2};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id};
        Set<Id> oppids = new Set<Id>{opp.Id,opp1.Id,opp2.Id};
        Set<Id> opids = new Set<Id>{op.Id,op1.Id,op2.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String cn = rec.Id == opp.Id ? null
                        : rec.Id == opp1.Id ? '1234567890002'
                        : rec.Id == opp2.Id ? '1234567890002'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, MyStoreRelation__c, CopyOrderProgressId__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(null, rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            String opid1 = rec.Id == op.Id ? null
                        : rec.Id == op1.Id ? op.Id
                        : rec.Id == op2.Id ? null
                        : null;
            System.assertEquals(opid1, rec.CopyOrderProgressId__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            String opid2 = rec.Id == op.Id ? null
                        : rec.Id == op1.Id ? null
                        : rec.Id == op2.Id ? op.Id
                        : null;
            System.assertEquals(opid2, rec.MyStoreRelation__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals(acc1.Id, rec.AccountId);
            String accid = rec.Id == opp.Id ? acc1.Id
                        : null;
            System.assertEquals(accid, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc1.Id, rec.AccountId__c);
        }

    }

    // 通常（子サービス管理）※案件別
    @isTest
    private static void execute10() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc4 = TestDataFactory.createAccount('acc4', false);
        Account acc5 = TestDataFactory.createAccount('acc5', false);
        insert new List<Account>{acc1,acc2,acc3,acc4,acc5};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm4 = TestDataFactory.createAccountTeamMember(acc4.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm5 = TestDataFactory.createAccountTeamMember(acc5.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3,atm4,atm5};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp1.CorporateNumber__c = '1234567890002';
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp3', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp3.CorporateNumber__c = '1234567890003';
        Opportunity opp4 = TestDataFactory.createOpportunity('opp4', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3,opp4};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_PAY_ENTERPRISE_MYSTORE, false);
        op2.MainMID__c = '123456789012345001';
        insert new List<OrderProgress__c>{op1,op2};
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc1.Id, opp3.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        op3.CopyOrderProgressId__c = op1.Id;
        OrderProgress__c op4 = TestDataFactory.createOrderProgress('op4', acc1.Id, opp4.Id, RECORDTYPEID_OP_PAY_ENTERPRISE_MYSTORE, false);
        op4.MainMID__c = '123456789012345002';
        op4.MyStoreRelation__c = op2.Id;
        insert new List<OrderProgress__c>{op3,op4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc4.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc5.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id,acc4.Id,acc5.Id};
        Set<Id> oppids = new Set<Id>{opp1.Id,opp2.Id,opp3.Id,opp4.Id};
        Set<Id> opids = new Set<Id>{op1.Id,op2.Id,op3.Id,op4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String cn = rec.Id == opp1.Id ? '1234567890002'
                        : rec.Id == opp3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, MyStoreRelation__c, CopyOrderProgressId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String mainmid = rec.Id == op2.Id ? '123456789012345001'
                        : rec.Id == op4.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mainmid, rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            String opid1 = rec.Id == op3.Id ? op1.Id
                        : null;
            System.assertEquals(opid1, rec.CopyOrderProgressId__c);
            String opid2 = rec.Id == op4.Id ? op2.Id
                        : null;
            System.assertEquals(opid2, rec.MyStoreRelation__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc4.Id
                        : rec.Id == cur2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String accid = rec.Id == opp1.Id ? acc2.Id
                        : rec.Id == opp2.Id ? acc4.Id
                        : rec.Id == opp3.Id ? acc2.Id
                        : rec.Id == opp4.Id ? acc4.Id
                        : null;
            System.assertEquals(accid, rec.AccountId);
            System.assertEquals(acc1.Id, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String accid = rec.Id == op1.Id ? acc2.Id
                        : rec.Id == op2.Id ? acc4.Id
                        : rec.Id == op3.Id ? acc2.Id
                        : rec.Id == op4.Id ? acc4.Id
                        : null;
            System.assertEquals(accid, rec.AccountId__c);
        }

    }

    // 通常（子サービス管理）※案件同じ
    @isTest
    private static void execute11() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc4 = TestDataFactory.createAccount('acc4', false);
        Account acc5 = TestDataFactory.createAccount('acc5', false);
        insert new List<Account>{acc1,acc2,acc3,acc4,acc5};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm4 = TestDataFactory.createAccountTeamMember(acc4.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm5 = TestDataFactory.createAccountTeamMember(acc5.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3,atm4,atm5};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp1.CorporateNumber__c = '1234567890002';
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_PAY_ENTERPRISE_MYSTORE, false);
        op2.MainMID__c = '123456789012345001';
        insert new List<OrderProgress__c>{op1,op2};
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc1.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        op3.CopyOrderProgressId__c = op1.Id;
        OrderProgress__c op4 = TestDataFactory.createOrderProgress('op4', acc1.Id, opp2.Id, RECORDTYPEID_OP_PAY_ENTERPRISE_MYSTORE, false);
        op4.MainMID__c = '123456789012345002';
        op4.MyStoreRelation__c = op2.Id;
        insert new List<OrderProgress__c>{op3,op4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc4.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc5.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id,acc4.Id,acc5.Id};
        Set<Id> oppids = new Set<Id>{opp1.Id,opp2.Id};
        Set<Id> opids = new Set<Id>{op1.Id,op2.Id,op3.Id,op4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String cn = rec.Id == opp1.Id ? '1234567890002'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(null, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c, MyStoreRelation__c, CopyOrderProgressId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String mainmid = rec.Id == op2.Id ? '123456789012345001'
                        : rec.Id == op4.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mainmid, rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
            String opid1 = rec.Id == op3.Id ? op1.Id
                        : null;
            System.assertEquals(opid1, rec.CopyOrderProgressId__c);
            String opid2 = rec.Id == op4.Id ? op2.Id
                        : null;
            System.assertEquals(opid2, rec.MyStoreRelation__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc4.Id
                        : rec.Id == cur2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String accid = rec.Id == opp1.Id ? acc2.Id
                        : rec.Id == opp2.Id ? acc4.Id
                        : null;
            System.assertEquals(accid, rec.AccountId);
            System.assertEquals(acc1.Id, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String accid = rec.Id == op1.Id ? acc2.Id
                        : rec.Id == op2.Id ? acc4.Id
                        : rec.Id == op3.Id ? acc2.Id
                        : rec.Id == op4.Id ? acc4.Id
                        : null;
            System.assertEquals(accid, rec.AccountId__c);
        }

    }

    // 更新済み
    @isTest
    private static void execute12() {
        Account acc1 = TestDataFactory.createAccount('acc1', false);
        acc1.CorporateNumber__c = '1234567890001';
        Account acc2 = TestDataFactory.createAccount('acc2', false);
        acc2.CorporateNumber__c = '1234567890002';
        acc2.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc3 = TestDataFactory.createAccount('acc3', false);
        acc3.CorporateNumber__c = '1234567890003';
        acc3.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc4 = TestDataFactory.createAccount('acc4', false);
        acc4.CorporateNumber__c = '1234567890004';
        acc4.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        Account acc5 = TestDataFactory.createAccount('acc5', false);
        acc5.CorporateNumber__c = '1234567890005';
        acc5.RecordTypeId = RECORDTYPEID_ACC_MEMBER;
        insert new List<Account>{acc1,acc2,acc3,acc4,acc5};

        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm1 = TestDataFactory.createAccountTeamMember(acc1.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm2 = TestDataFactory.createAccountTeamMember(acc2.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm3 = TestDataFactory.createAccountTeamMember(acc3.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm4 = TestDataFactory.createAccountTeamMember(acc4.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        AccountTeamMember atm5 = TestDataFactory.createAccountTeamMember(acc5.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', false);
        insert new List<AccountTeamMember>{atm1,atm2,atm3,atm4,atm5};

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        opp1.CorporateNumber__c = '1234567890002';
        opp1.CRMDPBeforeAccount__c = acc5.Id;
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc1.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        // opp2.CorporateNumber__c = '1234567890003';
        opp2.CRMDPBeforeAccount__c = acc5.Id;
        insert new List<Opportunity>{opp1,opp2};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc1.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        op1.MainMID__c = '123456789012345001';
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc1.Id, opp2.Id, RECORDTYPEID_OP_PLC, false);
        op2.MainMID__c = '123456789012345002';
        insert new List<OrderProgress__c>{op1,op2};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.Account__c = acc4.Id;
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.Account__c = acc5.Id;
        cur2.UniqueId__c = '123456789012345002';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2};

        Set<Id> accids = new Set<Id>{acc1.Id,acc2.Id,acc3.Id,acc4.Id,acc5.Id};
        Set<Id> oppids = new Set<Id>{opp1.Id,opp2.Id};
        Set<Id> opids = new Set<Id>{op1.Id,op2.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id};

        for (Account rec : [SELECT Id, CorporateNumber__c FROM Account WHERE Id = :accids]) {
            String cn = rec.Id == acc1.Id ? '1234567890001'
                        : rec.Id == acc2.Id ? '1234567890002'
                        : rec.Id == acc3.Id ? '1234567890003'
                        : rec.Id == acc4.Id ? '1234567890004'
                        : rec.Id == acc5.Id ? '1234567890005'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
        }

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            String cn = rec.Id == opp1.Id ? '1234567890002'
                        : null;
            System.assertEquals(cn, rec.CorporateNumber__c);
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(acc5.Id, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            String mid = rec.Id == op1.Id ? '123456789012345001'
                        : rec.Id == op2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.MainMID__c);
            System.assertEquals(acc1.Id, rec.AccountId__c);
        }

        for (CompanyInfo_UniqueId_Relation__c rec : [SELECT Id, UniqueId__c, Account__c FROM CompanyInfo_UniqueId_Relation__c WHERE Id = :curids]) {
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);
            String accid = rec.Id == cur1.Id ? acc4.Id
                        : rec.Id == cur2.Id ? acc5.Id
                        : null;
            System.assertEquals(accid, rec.Account__c);
        }

        Test.startTest();
        CRMDPUpdAccountIdBatch.run();
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, CorporateNumber__c, AccountId, CRMDPBeforeAccount__c FROM Opportunity WHERE Id = :oppids]) {
            System.assertEquals(acc1.Id, rec.AccountId);
            System.assertEquals(acc5.Id, rec.CRMDPBeforeAccount__c);
        }

        for (OrderProgress__c rec : [SELECT Id, MainMID__c, AccountId__c FROM OrderProgress__c WHERE Id = :opids]) {
            System.assertEquals(acc1.Id, rec.AccountId__c);
        }

    }

}