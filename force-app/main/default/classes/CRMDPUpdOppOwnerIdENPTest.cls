@isTest
public class CRMDPUpdOppOwnerIdENPTest {
    public static final Id RECORDTYPEID_OP_OFF = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PayEnterprise');
    public static final Id RECORDTYPEID_MPOPP_MPLIST = mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, 'mpList');

    // カバレッジカバー：通常
    // テストクラスでのテストが不可のため手動確認
    // @isTest
    // private static void execute_x() {
    //     Account acc = TestDataFactory.createAccount('acc', 'AccountRecordType_MemberStore', true);
    //     User beforeOwnerUser = TestDataFactory.createUser('boUser', 'システム管理者', false);
    //     beforeOwnerUser.LastName = 'boUser';
    //     User valueUpdUser = TestDataFactory.createUser('vuUser', 'システム管理者', false);
    //     valueUpdUser.LastName = 'vuUser';
    //     User fieldValueUser = TestDataFactory.createUser('fvUser', 'システム管理者', false);
    //     fieldValueUser.LastName = 'fvUser';
    //     insert new List<User>{beforeOwnerUser,valueUpdUser,fieldValueUser};
    //     AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, beforeOwnerUser.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

    //     Opportunity opp = TestDataFactory.createOpportunity('CRMDPTestExistOp', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', true);

    //     OrderProgress__c op = TestDataFactory.createOrderProgress('op', acc.Id, opp.Id, RECORDTYPEID_OP_OFF, false);
    //     op.ProductsNum__c = 1;
    //     op.DailyTxPredictedValueMerchantAnswer__c = 1;
    //     op.Numberofstores__c = 1;
    //     op.EvaluateeAYomi__c = 'fvUser';
    //     op.EvaluateeDepartmentAYomi__c = 'a b c';
    //     insert op;

    //     opp.StageName = '50';
    //     opp.FirstAppoint__c = true;
    //     opp.PaymentMethod_ck1__c = true;
    //     opp.PresentEffectOfMeasuresFlg__c = true;
    //     opp.PaymentMethod_ck2__c = true;
    //     opp.ConfirmedIntroductionFlg__c = true;
    //     opp.DecidedEconomicConditionFlg__c = true;
    //     opp.ContractRelated_ck3__c = true;
    //     opp.IntroductionRelated_ck1__c = true;
    //     opp.LaunchDateAndImplementationPeriod__c = true;
    //     opp.AmountSales__c = 100;
    //     opp.ContractDate__c = Date.today();
    //     update opp;

    //     Test.startTest();
    //     CRMDPUpdOppOwnerIdENP.run();
    //     Test.stopTest();
    // }

    // カバレッジカバー：ID指定
    // テストクラスでのテストが不可のため手動確認
    // @isTest
    // private static void execute_y() {
    //     Account acc = TestDataFactory.createAccount('acc', 'AccountRecordType_MemberStore', true);
    //     User beforeOwnerUser = TestDataFactory.createUser('boUser', 'システム管理者', false);
    //     beforeOwnerUser.LastName = 'boUser';
    //     User valueUpdUser = TestDataFactory.createUser('vuUser', 'システム管理者', false);
    //     valueUpdUser.LastName = 'vuUser';
    //     User fieldValueUser = TestDataFactory.createUser('fvUser', 'システム管理者', false);
    //     fieldValueUser.LastName = 'fvUser';
    //     insert new List<User>{beforeOwnerUser,valueUpdUser,fieldValueUser};
    //     AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, beforeOwnerUser.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

    //     Opportunity opp = TestDataFactory.createOpportunity('CRMDPTestExistOp', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', true);

    //     OrderProgress__c op = TestDataFactory.createOrderProgress('op', acc.Id, opp.Id, RECORDTYPEID_OP_OFF, false);
    //     op.ProductsNum__c = 1;
    //     op.DailyTxPredictedValueMerchantAnswer__c = 1;
    //     op.Numberofstores__c = 1;
    //     op.EvaluateeAYomi__c = 'fvUserx';
    //     insert op;

    //     opp.StageName = '50';
    //     opp.FirstAppoint__c = true;
    //     opp.PaymentMethod_ck1__c = true;
    //     opp.PresentEffectOfMeasuresFlg__c = true;
    //     opp.PaymentMethod_ck2__c = true;
    //     opp.ConfirmedIntroductionFlg__c = true;
    //     opp.DecidedEconomicConditionFlg__c = true;
    //     opp.ContractRelated_ck3__c = true;
    //     opp.IntroductionRelated_ck1__c = true;
    //     opp.LaunchDateAndImplementationPeriod__c = true;
    //     opp.AmountSales__c = 100;
    //     opp.ContractDate__c = Date.today();
    //     update opp;

    //     Test.startTest();
    //     CRMDPUpdOppOwnerIdENP.run(new Set<Id>{opp.Id});
    //     Test.stopTest();
    // }

    @TestSetup
    static void setup() {
        Test.startTest();
        Account acc = TestDataFactory.createAccount('acc', 'AccountRecordType_MemberStore', true);
        User user1 = TestDataFactory.createUser('user1', 'システム管理者', false);
        user1.LastName = 'user1';
        User user2 = TestDataFactory.createUser('user2', 'システム管理者', false);
        user2.LastName = 'user2';
        User user3 = TestDataFactory.createUser('user3', 'システム管理者', false);
        user3.LastName = 'user3';
        insert new List<User>{user1,user2,user3};
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user1.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp = TestDataFactory.createOpportunity('opp', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', true);

        OrderProgress__c op = TestDataFactory.createOrderProgress('op', acc.Id, opp.Id, RECORDTYPEID_OP_OFF, false);
        op.ProductsNum__c = 1;
        op.DailyTxPredictedValueMerchantAnswer__c = 1;
        op.Numberofstores__c = 1;
        op.EvaluateeAYomi__c = 'user2';
        op.EvaluateeDepartmentAYomi__c = 'a b c';
        insert op;

        opp.StageName = '50';
        opp.FirstAppoint__c = true;
        opp.PaymentMethod_ck1__c = true;
        opp.PresentEffectOfMeasuresFlg__c = true;
        opp.PaymentMethod_ck2__c = true;
        opp.ConfirmedIntroductionFlg__c = true;
        opp.DecidedEconomicConditionFlg__c = true;
        opp.ContractRelated_ck3__c = true;
        opp.IntroductionRelated_ck1__c = true;
        opp.LaunchDateAndImplementationPeriod__c = true;
        opp.AmountSales__c = 100;
        opp.ContractDate__c = Date.today();
        opp.OwnerId = user1.Id;
        update opp;
        Test.stopTest();
    }

    // 通常50
    @isTest
    private static void execute1() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals('user2', rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user2.Id, rec.OwnerId);
            System.assertEquals('a', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('b', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('c', rec.EvaluateeAYomiTeam__c);
        }
    }
    // 通常60
    @isTest
    private static void execute2() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        opp.StageName = '60';
        update opp;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('60', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals('user2', rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user2.Id, rec.OwnerId);
            System.assertEquals('a', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('b', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('c', rec.EvaluateeAYomiTeam__c);
        }
    }
    // 営業状況が40
    @isTest
    private static void execute3() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        opp.StageName = '40';
        opp.IntroductionRelated_ck1__c = false;
        opp.LaunchDateAndImplementationPeriod__c = false;
        update opp;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('40', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals('user2', rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
    }
    // サービス管理がない
    @isTest
    private static void execute4() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);
        delete op;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        List<OrderProgress__c> opscheck = [SELECT Id FROM OrderProgress__c];
        System.assertEquals(0, opscheck.size());

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
    }
    // ユーザがいない1
    @isTest
    private static void execute5() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        op.EvaluateeAYomi__c = 'user';
        update op;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals('user', rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user3.Id, rec.OwnerId);
            System.assertEquals('a', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('b', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('c', rec.EvaluateeAYomiTeam__c);
        }
    }
    // ユーザがいない2
    @isTest
    private static void execute6() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        op.EvaluateeAYomi__c = 'us er2';
        update op;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals('us er2', rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user3.Id, rec.OwnerId);
            System.assertEquals('a', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('b', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('c', rec.EvaluateeAYomiTeam__c);
        }
    }
    // ユーザ名が空
    @isTest
    private static void execute7() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        op.EvaluateeAYomi__c = null;
        update op;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals(null, rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user3.Id, rec.OwnerId);
            System.assertEquals('a', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('b', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('c', rec.EvaluateeAYomiTeam__c);
        }
    }
    // 更新所有者がいない1
    @isTest
    private static void execute8() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        op.EvaluateeAYomi__c = null;
        update op;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals(null, rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => null};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals('a', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('b', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('c', rec.EvaluateeAYomiTeam__c);
        }
    }
    // 更新所有者がいない2
    @isTest
    private static void execute9() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        op.EvaluateeAYomi__c = null;
        update op;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals(null, rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals('a', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('b', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('c', rec.EvaluateeAYomiTeam__c);
        }
    }
    // Aヨミ情報元が空
    @isTest
    private static void execute10() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        op.EvaluateeDepartmentAYomi__c = null;
        update op;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals('user2', rec.EvaluateeAYomi__c);
            System.assertEquals(null, rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user2.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
    }
    // Aヨミ情報が空じゃない
    @isTest
    private static void execute11() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        opp.EvaluateeAYomiDivision__c = 'd';
        opp.EvaluateeAYomiDepartment__c = 'e';
        opp.EvaluateeAYomiTeam__c = 'f';
        update opp;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user1.Id, rec.OwnerId);
            System.assertEquals('d', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('e', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('f', rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals('user2', rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user2.Id, rec.OwnerId);
            System.assertEquals('d', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('e', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('f', rec.EvaluateeAYomiTeam__c);
        }
    }
    // 所有者更新済1
    @isTest
    private static void execute12() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        opp.OwnerId = user2.Id;
        update opp;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user2.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals('user2', rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user2.Id, rec.OwnerId);
            System.assertEquals('a', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('b', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('c', rec.EvaluateeAYomiTeam__c);
        }
    }
    // 所有者更新済2
    @isTest
    private static void execute13() {
        User user1 = null;
        User user2 = null;
        User user3 = null;
        for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
            if ('user1'.equals(user.Name)) {
                user1 = user;
            } else if ('user2'.equals(user.Name)) {
                user2 = user;
            } else if ('user3'.equals(user.Name)) {
                user3 = user;
            }
        }
        System.assertNotEquals(null, user1);
        System.assertNotEquals(null, user2);
        System.assertNotEquals(null, user3);

        List<Opportunity> opps = [
            SELECT Id, StageName, OwnerId
                ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
            FROM Opportunity];
        System.assertEquals(1, opps.size());
        Opportunity opp = opps.get(0);

        List<OrderProgress__c> ops = [SELECT Id, EvaluateeAYomi__c FROM OrderProgress__c WHERE OpportunityId__c = :opp.Id];
        System.assertEquals(1, ops.size());
        OrderProgress__c op = ops.get(0);

        opp.OwnerId = user3.Id;
        update opp;

        op.EvaluateeAYomi__c = null;
        update op;

        for (Opportunity rec : [SELECT Id, StageName, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals('50', rec.StageName);
            System.assertEquals(user3.Id, rec.OwnerId);
            System.assertEquals(null, rec.EvaluateeAYomiDivision__c);
            System.assertEquals(null, rec.EvaluateeAYomiDepartment__c);
            System.assertEquals(null, rec.EvaluateeAYomiTeam__c);
        }
        for (OrderProgress__c rec : [SELECT Id, EvaluateeAYomi__c, EvaluateeDepartmentAYomi__c FROM OrderProgress__c WHERE Id = :op.Id]) {
            System.assertEquals(null, rec.EvaluateeAYomi__c);
            System.assertEquals('a b c', rec.EvaluateeDepartmentAYomi__c);
        }

        Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
        Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
        Test.stopTest();

        for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
            System.assertEquals(user3.Id, rec.OwnerId);
            System.assertEquals('a', rec.EvaluateeAYomiDivision__c);
            System.assertEquals('b', rec.EvaluateeAYomiDepartment__c);
            System.assertEquals('c', rec.EvaluateeAYomiTeam__c);
        }
    }
    // CSV読み込み部分のカバレッジカバー
    @isTest
    private static void execute14() {
        Test.startTest();
        CRMDPUpdOppOwnerIdENP.run(new Set<Id>());
        Test.stopTest();
    }
    // ID指定
    // @isTest
    // private static void execute1() {
    //     User user1 = null;
    //     User user2 = null;
    //     User user3 = null;
    //     for (User user : [SELECT Id, Name FROM User WHERE Name IN ('user1','user2','user3')]) {
    //         if ('user1'.equals(user.Name)) {
    //             user1 = user;
    //         } else if ('user2'.equals(user.Name)) {
    //             user2 = user;
    //         } else if ('user3'.equals(user.Name)) {
    //             user3 = user;
    //         }
    //     }
    //     System.assertNotEquals(null, user1);
    //     System.assertNotEquals(null, user2);
    //     System.assertNotEquals(null, user3);

    //     List<Opportunity> opps = [
    //         SELECT Id, StageName, OwnerId
    //             ,EvaluateeAYomiDivision__c,EvaluateeAYomiDepartment__c,EvaluateeAYomiTeam__c
    //         FROM Opportunity];
    //     System.assertEquals(1, opps.size());

    //     Opportunity opp = opps.get(0);
    //     System.assertEquals('50', opp.StageName);
    //     System.assertEquals(user1.Id, opp.OwnerId);
    //     System.assertEquals(null, opp.EvaluateeAYomiDivision__c);
    //     System.assertEquals(null, opp.EvaluateeAYomiDepartment__c);
    //     System.assertEquals(null, opp.EvaluateeAYomiTeam__c);

    //     Map<Id, Id> ownerIdMap = new Map<Id, Id>{opp.Id => user3.Id};
    //     Map<Id, Date> contractDateMap = new Map<Id, Date>{opp.Id => Date.today()};
    //     Test.startTest();
    //     CRMDPUpdOppOwnerIdENP.run(ownerIdMap, contractDateMap);
    //     Test.stopTest();

    //     for (Opportunity rec : [SELECT Id, OwnerId, EvaluateeAYomiDivision__c, EvaluateeAYomiDepartment__c, EvaluateeAYomiTeam__c FROM Opportunity WHERE Id = :opp.Id]) {
    //         System.assertEquals(user2.Id, rec.OwnerId);
    //         System.assertEquals('a', rec.EvaluateeAYomiDivision__c);
    //         System.assertEquals('b', rec.EvaluateeAYomiDepartment__c);
    //         System.assertEquals('c', rec.EvaluateeAYomiTeam__c);
    //     }
    // }
    // 合意予定日元がない ※手動確認
    // 合意予定日が空じゃない ※手動確認
}