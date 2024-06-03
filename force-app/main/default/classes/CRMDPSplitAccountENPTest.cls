@isTest
public class CRMDPSplitAccountENPTest {
    public static final Id RECORDTYPEID_OP_OFF = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'PayEnterprise');
    public static final Id RECORDTYPEID_OP_PAY_PARTNER = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER);
    public static final Id RECORDTYPEID_OP_PARTNER_ONLINE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE);
    public static final Id RECORDTYPEID_OP_DIRECT_SMB = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB);
    public static final Id RECORDTYPEID_MPOPP_MPLIST = mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, 'mpList');

    // 通常
    @isTest
    private static void execute1() {
        Account acc = TestDataFactory.createAccount('acc', true);
        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc.Id, opp3.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp3', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.OrderProgressId__c = op2.Id;
        mpopp3.AccountId__c = acc.Id;
        mpOpportunity__c mpopp4 = TestDataFactory.createMpOpportunity('mpopp4', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp4.OrderProgressId__c = op3.Id;
        mpopp4.AccountId__c = acc.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3,mpopp4};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc.Id;
        mpMerchant__c mer4 = TestDataFactory.createMpMerchant('mer4', '123456789012345004', false);
        mer4.mpOpportunity__c = mpopp4.Id;
        mer4.AccountId__c = acc.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3,mer4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        CompanyInfo_UniqueId_Relation__c cur4 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur4.UniqueId__c = '123456789012345004';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3,cur4};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id,mer4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id,cur4.Id};

        // 更新前値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // MIDチェック
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : rec.Id == mer4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        // 更新前値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            // MIDチェック
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : rec.Id == cur4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        // テスト用値セット（CSVから抽出する想定の値）
        Set<Id> accids = new Set<Id>{acc.Id};
        Map<Id, Map<String, Set<Id>>> splitMap = new Map<Id, Map<String, Set<Id>>>{
            acc.Id => new Map<String, Set<Id>>{
                '【企業分割】acc1' => new Set<Id>{opp1.Id}
                ,'【企業分割】acc2' => new Set<Id>{opp2.Id,opp3.Id}
            }
        };
        Map<String, String> splitRankMap = new Map<String, String>{
            acc.Id + '【企業分割】acc1' => 'Ａランク'
            ,acc.Id + '【企業分割】acc2' => 'Ｂランク'
        };
        Test.startTest();
        CRMDPSplitAccountENP.run(accids, splitMap, splitRankMap);
        Test.stopTest();

        // 更新後値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.ParentId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Name
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            Id accid = rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId;
            System.assertNotEquals(accid, acc.Id);
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);

            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.ParentId);

            String name = rec.Id == mer1.Id ? '【企業分割】acc1'
                        : rec.Id == mer2.Id ? '【企業分割】acc2'
                        : rec.Id == mer3.Id ? '【企業分割】acc2'
                        : rec.Id == mer4.Id ? '【企業分割】acc2'
                        : null;
            System.assertEquals(name, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Name);

            // ランクチェック
            String rank = rec.Id == mer1.Id ? 'Ａランク'
                        : rec.Id == mer2.Id ? 'Ｂランク'
                        : rec.Id == mer3.Id ? 'Ｂランク'
                        : rec.Id == mer4.Id ? 'Ｂランク'
                        : null;
            System.assertEquals(rank, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);

            System.assertEquals(true, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c);
        }

        // 更新後値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, Account__r.Name, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);

            System.assertEquals(true, rec.SFReplacementCandidateFlag__c);
        }
    }

    // 分割案件漏れ
    @isTest
    private static void execute2() {
        Account acc = TestDataFactory.createAccount('acc', true);
        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc.Id, opp3.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp3', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.OrderProgressId__c = op2.Id;
        mpopp3.AccountId__c = acc.Id;
        mpOpportunity__c mpopp4 = TestDataFactory.createMpOpportunity('mpopp4', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp4.OrderProgressId__c = op3.Id;
        mpopp4.AccountId__c = acc.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3,mpopp4};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc.Id;
        mpMerchant__c mer4 = TestDataFactory.createMpMerchant('mer4', '123456789012345004', false);
        mer4.mpOpportunity__c = mpopp4.Id;
        mer4.AccountId__c = acc.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3,mer4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        CompanyInfo_UniqueId_Relation__c cur4 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur4.UniqueId__c = '123456789012345004';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3,cur4};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id,mer4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id,cur4.Id};

        // 更新前値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // MIDチェック
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : rec.Id == mer4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        // 更新前値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            // MIDチェック
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : rec.Id == cur4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        // テスト用値セット（CSVから抽出する想定の値）
        Set<Id> accids = new Set<Id>{acc.Id};
        Map<Id, Map<String, Set<Id>>> splitMap = new Map<Id, Map<String, Set<Id>>>{
            acc.Id => new Map<String, Set<Id>>{
                '【企業分割】acc1' => new Set<Id>{opp1.Id}
                ,'【企業分割】acc2' => new Set<Id>{opp2.Id}
            }
        };
        Map<String, String> splitRankMap = new Map<String, String>{
            acc.Id + '【企業分割】acc1' => 'Ａランク'
            ,acc.Id + '【企業分割】acc2' => 'Ｂランク'
        };
        Test.startTest();
        CRMDPSplitAccountENP.run(accids, splitMap, splitRankMap);
        Test.stopTest();

        // 更新後値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.ParentId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Name
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            // Id accid = rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId;
            // if (rec.Id == mer4.Id) {
            //     System.assertEquals(accid, acc.Id);
            // } else {
            //     System.assertNotEquals(accid, acc.Id);
            // }
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // System.assertEquals(rec.Id == mer4.Id ? null : acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.ParentId);

            String name = rec.Id == mer1.Id ? '【企業分割】acc1'
                        : rec.Id == mer2.Id ? '【企業分割】acc2'
                        : rec.Id == mer3.Id ? '【企業分割】acc2'
                        : rec.Id == mer4.Id ? 'acc'
                        : null;
            System.assertEquals('acc', rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Name);

            // ランクチェック
            String rank = rec.Id == mer1.Id ? 'Ａランク'
                        : rec.Id == mer2.Id ? 'Ｂランク'
                        : rec.Id == mer3.Id ? 'Ｂランク'
                        : null;
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);

            System.assertEquals(false, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c);
        }

        // 更新後値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, Account__r.Name, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }
    }

    // 紐づくSF案件がない（ファイルの案件IDあり）
    @isTest
    private static void execute3_1() {
        Account acc = TestDataFactory.createAccount('acc', true);
        Account accx = TestDataFactory.createAccount('accx', true);
        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);
        AccountTeamMember atmx = TestDataFactory.createAccountTeamMember(accx.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', accx.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', accx.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp2', accx.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', accx.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', accx.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', accx.Id, opp3.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.AccountId__c = acc.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.AccountId__c = acc.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp3', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.AccountId__c = acc.Id;
        mpOpportunity__c mpopp4 = TestDataFactory.createMpOpportunity('mpopp4', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp4.AccountId__c = acc.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3,mpopp4};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc.Id;
        mpMerchant__c mer4 = TestDataFactory.createMpMerchant('mer4', '123456789012345004', false);
        mer4.mpOpportunity__c = mpopp4.Id;
        mer4.AccountId__c = acc.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3,mer4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        CompanyInfo_UniqueId_Relation__c cur4 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur4.UniqueId__c = '123456789012345004';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3,cur4};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id,mer4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id,cur4.Id};

        // 更新前値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);

            // MIDチェック
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : rec.Id == mer4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        // 更新前値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            // MIDチェック
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : rec.Id == cur4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        // テスト用値セット（CSVから抽出する想定の値）
        Set<Id> accids = new Set<Id>{acc.Id};
        Map<Id, Map<String, Set<Id>>> splitMap = new Map<Id, Map<String, Set<Id>>>{
            acc.Id => new Map<String, Set<Id>>{
                '【企業分割】acc1' => new Set<Id>{opp1.Id}
                ,'【企業分割】acc2' => new Set<Id>{opp2.Id,opp3.Id}
            }
        };
        Map<String, String> splitRankMap = new Map<String, String>{
            acc.Id + '【企業分割】acc1' => 'Ａランク'
            ,acc.Id + '【企業分割】acc2' => 'Ｂランク'
        };
        Test.startTest();
        CRMDPSplitAccountENP.run(accids, splitMap, splitRankMap);
        Test.stopTest();

        // 更新後値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
        }

        // 更新後値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        List<Account> accs1 = [SELECT Id FROM Account WHERE ParentId = :acc.Id AND Name = '【企業分割】acc1' AND CRMDPIsSplit__c = true];
        List<Account> accs2 = [SELECT Id FROM Account WHERE ParentId = :acc.Id AND Name = '【企業分割】acc2' AND CRMDPIsSplit__c = true];
        System.assertEquals(1, accs1.size());
        System.assertEquals(1, accs2.size());
    }

    // 紐づくSF案件がない（ファイルの案件IDなし）
    @isTest
    private static void execute3_2() {
        Account acc = TestDataFactory.createAccount('acc', true);
        Account accx = TestDataFactory.createAccount('accx', true);
        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);
        AccountTeamMember atmx = TestDataFactory.createAccountTeamMember(accx.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', accx.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', accx.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp2', accx.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', accx.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', accx.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', accx.Id, opp3.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.AccountId__c = acc.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.AccountId__c = acc.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp3', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.AccountId__c = acc.Id;
        mpOpportunity__c mpopp4 = TestDataFactory.createMpOpportunity('mpopp4', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp4.AccountId__c = acc.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3,mpopp4};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc.Id;
        mpMerchant__c mer4 = TestDataFactory.createMpMerchant('mer4', '123456789012345004', false);
        mer4.mpOpportunity__c = mpopp4.Id;
        mer4.AccountId__c = acc.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3,mer4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        CompanyInfo_UniqueId_Relation__c cur4 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur4.UniqueId__c = '123456789012345004';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3,cur4};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id,mer4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id,cur4.Id};

        // 更新前値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);

            // MIDチェック
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : rec.Id == mer4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);
        }

        // 更新前値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            // MIDチェック
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : rec.Id == cur4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        // テスト用値セット（CSVから抽出する想定の値）
        Set<Id> accids = new Set<Id>{acc.Id};
        Map<Id, Map<String, Set<Id>>> splitMap = new Map<Id, Map<String, Set<Id>>>{
            acc.Id => new Map<String, Set<Id>>{
                '【企業分割】acc1' => new Set<Id>()
                ,'【企業分割】acc2' => new Set<Id>()
            }
        };
        Map<String, String> splitRankMap = new Map<String, String>{
            acc.Id + '【企業分割】acc1' => 'Ａランク'
            ,acc.Id + '【企業分割】acc2' => 'Ｂランク'
        };
        Test.startTest();
        CRMDPSplitAccountENP.run(accids, splitMap, splitRankMap);
        Test.stopTest();

        // 更新後値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
        }

        // 更新後値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        List<Account> accs1 = [SELECT Id FROM Account WHERE ParentId = :acc.Id AND Name = '【企業分割】acc1' AND CRMDPIsSplit__c = true];
        List<Account> accs2 = [SELECT Id FROM Account WHERE ParentId = :acc.Id AND Name = '【企業分割】acc2' AND CRMDPIsSplit__c = true];
        System.assertEquals(1, accs1.size());
        System.assertEquals(1, accs2.size());
    }

    // ファイルの取引先IDがない
    @isTest
    private static void execute4() {
        Account acc = TestDataFactory.createAccount('acc', true);
        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc.Id, opp3.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp3', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.OrderProgressId__c = op2.Id;
        mpopp3.AccountId__c = acc.Id;
        mpOpportunity__c mpopp4 = TestDataFactory.createMpOpportunity('mpopp4', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp4.OrderProgressId__c = op3.Id;
        mpopp4.AccountId__c = acc.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3,mpopp4};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc.Id;
        mpMerchant__c mer4 = TestDataFactory.createMpMerchant('mer4', '123456789012345004', false);
        mer4.mpOpportunity__c = mpopp4.Id;
        mer4.AccountId__c = acc.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3,mer4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        CompanyInfo_UniqueId_Relation__c cur4 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur4.UniqueId__c = '123456789012345004';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3,cur4};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id,mer4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id,cur4.Id};

        // 更新前値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // MIDチェック
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : rec.Id == mer4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        // 更新前値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            // MIDチェック
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : rec.Id == cur4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        // テスト用値セット（CSVから抽出する想定の値）
        Set<Id> accids = new Set<Id>{'0010X00000xxxxXXXX'};
        Map<Id, Map<String, Set<Id>>> splitMap = new Map<Id, Map<String, Set<Id>>>{
            '0010X00000xxxxXXXX' => new Map<String, Set<Id>>{
                '【企業分割】acc1' => new Set<Id>{opp1.Id}
                ,'【企業分割】acc2' => new Set<Id>{opp2.Id,opp3.Id}
            }
        };
        Map<String, String> splitRankMap = new Map<String, String>{
            '0010X00000xxxxXXXX' + '【企業分割】acc1' => 'Ａランク'
            ,'0010X00000xxxxXXXX' + '【企業分割】acc2' => 'Ｂランク'
        };
        Test.startTest();
        CRMDPSplitAccountENP.run(accids, splitMap, splitRankMap);
        Test.stopTest();

        // 更新後値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        // 更新後値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        List<Account> accs1 = [SELECT Id FROM Account WHERE ParentId = :acc.Id];
        List<Account> accs2 = [SELECT Id FROM Account WHERE Name IN ('【企業分割】acc1','【企業分割】acc2')];
        List<Account> accs3 = [SELECT Id FROM Account WHERE CRMDPIsSplit__c = true];
        System.assertEquals(0, accs1.size());
        System.assertEquals(0, accs2.size());
        System.assertEquals(0, accs3.size());
    }

    // 分割済み
    @isTest
    private static void execute5() {
        Account acc = TestDataFactory.createAccount('acc', true);
        Account accx = TestDataFactory.createAccount('accx', false);
        accx.CRMDPIsSplit__c = true;
        accx.ParentId = acc.Id;
        insert accx;
        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);
        AccountTeamMember atmx = TestDataFactory.createAccountTeamMember(accx.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc.Id, opp3.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp3', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.OrderProgressId__c = op2.Id;
        mpopp3.AccountId__c = acc.Id;
        mpOpportunity__c mpopp4 = TestDataFactory.createMpOpportunity('mpopp4', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp4.OrderProgressId__c = op3.Id;
        mpopp4.AccountId__c = acc.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3,mpopp4};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc.Id;
        mpMerchant__c mer4 = TestDataFactory.createMpMerchant('mer4', '123456789012345004', false);
        mer4.mpOpportunity__c = mpopp4.Id;
        mer4.AccountId__c = acc.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3,mer4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        CompanyInfo_UniqueId_Relation__c cur4 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur4.UniqueId__c = '123456789012345004';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3,cur4};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id,mer4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id,cur4.Id};

        // 更新前値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // MIDチェック
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : rec.Id == mer4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        // 更新前値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            // MIDチェック
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : rec.Id == cur4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        // テスト用値セット（CSVから抽出する想定の値）
        Set<Id> accids = new Set<Id>{acc.Id};
        Map<Id, Map<String, Set<Id>>> splitMap = new Map<Id, Map<String, Set<Id>>>{
            acc.Id => new Map<String, Set<Id>>{
                '【企業分割】acc1' => new Set<Id>{opp1.Id}
                ,'【企業分割】acc2' => new Set<Id>{opp2.Id,opp3.Id}
            }
        };
        Map<String, String> splitRankMap = new Map<String, String>{
            acc.Id + '【企業分割】acc1' => 'Ａランク'
            ,acc.Id + '【企業分割】acc2' => 'Ｂランク'
        };
        Test.startTest();
        CRMDPSplitAccountENP.run(accids, splitMap, splitRankMap);
        Test.stopTest();

        // 更新後値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        // 更新後値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        List<Account> accs1 = [SELECT Id FROM Account WHERE ParentId = :acc.Id];
        List<Account> accs2 = [SELECT Id FROM Account WHERE Name IN ('【企業分割】acc1','【企業分割】acc2')];
        List<Account> accs3 = [SELECT Id FROM Account WHERE CRMDPIsSplit__c = true];
        System.assertEquals(1, accs1.size());
        System.assertEquals(accx.Id, accs1.get(0).Id);
        System.assertEquals(0, accs2.size());
        System.assertEquals(1, accs3.size());
        System.assertEquals(accx.Id, accs3.get(0).Id);
    }

    // 案件数が一致しない（ファイルにしかないID）
    @isTest
    private static void execute6() {
        Account acc = TestDataFactory.createAccount('acc', true);
        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc.Id, opp3.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp3', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.OrderProgressId__c = op2.Id;
        mpopp3.AccountId__c = acc.Id;
        mpOpportunity__c mpopp4 = TestDataFactory.createMpOpportunity('mpopp4', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp4.OrderProgressId__c = op3.Id;
        mpopp4.AccountId__c = acc.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3,mpopp4};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc.Id;
        mpMerchant__c mer4 = TestDataFactory.createMpMerchant('mer4', '123456789012345004', false);
        mer4.mpOpportunity__c = mpopp4.Id;
        mer4.AccountId__c = acc.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3,mer4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        CompanyInfo_UniqueId_Relation__c cur4 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur4.UniqueId__c = '123456789012345004';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3,cur4};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id,mer4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id,cur4.Id};

        // 更新前値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // MIDチェック
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : rec.Id == mer4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        // 更新前値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            // MIDチェック
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : rec.Id == cur4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        // テスト用値セット（CSVから抽出する想定の値）
        Set<Id> accids = new Set<Id>{acc.Id};
        Map<Id, Map<String, Set<Id>>> splitMap = new Map<Id, Map<String, Set<Id>>>{
            acc.Id => new Map<String, Set<Id>>{
                '【企業分割】acc1' => new Set<Id>{opp1.Id}
                ,'【企業分割】acc2' => new Set<Id>{opp2.Id,opp3.Id,'0060X000000xXX0XXX'}
            }
        };
        Map<String, String> splitRankMap = new Map<String, String>{
            acc.Id + '【企業分割】acc1' => 'Ａランク'
            ,acc.Id + '【企業分割】acc2' => 'Ｂランク'
        };
        Test.startTest();
        CRMDPSplitAccountENP.run(accids, splitMap, splitRankMap);
        Test.stopTest();

        // 更新後値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.ParentId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Name
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            Id accid = rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId;
            System.assertNotEquals(accid, acc.Id);
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);

            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.ParentId);

            String name = rec.Id == mer1.Id ? '【企業分割】acc1'
                        : rec.Id == mer2.Id ? '【企業分割】acc2'
                        : rec.Id == mer3.Id ? '【企業分割】acc2'
                        : rec.Id == mer4.Id ? '【企業分割】acc2'
                        : null;
            System.assertEquals(name, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Name);

            // ランクチェック
            String rank = rec.Id == mer1.Id ? 'Ａランク'
                        : rec.Id == mer2.Id ? 'Ｂランク'
                        : rec.Id == mer3.Id ? 'Ｂランク'
                        : rec.Id == mer4.Id ? 'Ｂランク'
                        : null;
            System.assertEquals(rank, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);

            System.assertEquals(true, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c);
        }

        // 更新後値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, Account__r.Name, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);

            System.assertEquals(true, rec.SFReplacementCandidateFlag__c);
        }
    }

    // 紐づく案件にファイルの案件IDが1件もない
    @isTest
    private static void execute7() {
        Account acc = TestDataFactory.createAccount('acc', true);
        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc.Id, opp3.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp3', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.OrderProgressId__c = op2.Id;
        mpopp3.AccountId__c = acc.Id;
        mpOpportunity__c mpopp4 = TestDataFactory.createMpOpportunity('mpopp4', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp4.OrderProgressId__c = op3.Id;
        mpopp4.AccountId__c = acc.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3,mpopp4};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc.Id;
        mpMerchant__c mer4 = TestDataFactory.createMpMerchant('mer4', '123456789012345004', false);
        mer4.mpOpportunity__c = mpopp4.Id;
        mer4.AccountId__c = acc.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3,mer4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        CompanyInfo_UniqueId_Relation__c cur4 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur4.UniqueId__c = '123456789012345004';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3,cur4};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id,mer4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id,cur4.Id};

        // 更新前値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // MIDチェック
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : rec.Id == mer4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        // 更新前値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            // MIDチェック
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : rec.Id == cur4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        // テスト用値セット（CSVから抽出する想定の値）
        Set<Id> accids = new Set<Id>{acc.Id};
        Map<Id, Map<String, Set<Id>>> splitMap = new Map<Id, Map<String, Set<Id>>>{
            acc.Id => new Map<String, Set<Id>>{
                '【企業分割】acc1' => new Set<Id>{'0060X000000xXX1XXX'}
                ,'【企業分割】acc2' => new Set<Id>{'0060X000000xXX2XXX','0060X000000xXX3XXX'}
            }
        };
        Map<String, String> splitRankMap = new Map<String, String>{
            acc.Id + '【企業分割】acc1' => 'Ａランク'
            ,acc.Id + '【企業分割】acc2' => 'Ｂランク'
        };
        Test.startTest();
        CRMDPSplitAccountENP.run(accids, splitMap, splitRankMap);
        Test.stopTest();

        // 更新後値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        // 更新後値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        List<Account> accs1 = [SELECT Id FROM Account WHERE ParentId = :acc.Id];
        List<Account> accs2 = [SELECT Id FROM Account WHERE Name IN ('【企業分割】acc1','【企業分割】acc2')];
        List<Account> accs3 = [SELECT Id FROM Account WHERE CRMDPIsSplit__c = true];
        System.assertEquals(0, accs1.size());
        System.assertEquals(0, accs2.size());
        System.assertEquals(0, accs3.size());
    }

    // レコードが欠けてる
    @isTest
    private static void execute8() {
        Account acc = TestDataFactory.createAccount('acc', true);
        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp3', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp4 = TestDataFactory.createOpportunity('opp4', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3,opp4};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc.Id, opp1.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc.Id, opp2.Id, RECORDTYPEID_OP_OFF, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc.Id, opp3.Id, RECORDTYPEID_OP_OFF, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc.Id;
        insert new List<mpMerchant__c>{mer1};

        Set<Id> merids = new Set<Id>{mer1.Id};

        // 更新前値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpMerchant__c WHERE Id = :mer1.Id
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // MIDチェック
            System.assertEquals('123456789012345001', rec.MerchantId__c);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        for (mpOpportunity__c rec : [
            SELECT Id, AccountId__c
                ,OrderProgressId__r.AccountId__c
                ,OrderProgressId__r.OpportunityId__r.AccountId
                ,OrderProgressId__r.OpportunityId__r.Account.Rank__c
            FROM mpOpportunity__c WHERE Id = :mpopp2.Id
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.OrderProgressId__r.OpportunityId__r.AccountId);

            // ランクチェック
            System.assertEquals(null, rec.OrderProgressId__r.OpportunityId__r.Account.Rank__c);
        }

        for (OrderProgress__c rec : [
            SELECT Id, AccountId__c
                ,OpportunityId__r.AccountId
                ,OpportunityId__r.Account.Rank__c
            FROM OrderProgress__c WHERE Id = :op3.Id
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.OpportunityId__r.AccountId);

            // ランクチェック
            System.assertEquals(null, rec.OpportunityId__r.Account.Rank__c);
        }

        for (Opportunity rec : [
            SELECT Id
                ,AccountId
                ,Account.Rank__c
            FROM Opportunity WHERE Id = :opp4.Id
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId);

            // ランクチェック
            System.assertEquals(null, rec.Account.Rank__c);
        }

        // テスト用値セット（CSVから抽出する想定の値）
        Set<Id> accids = new Set<Id>{acc.Id};
        Map<Id, Map<String, Set<Id>>> splitMap = new Map<Id, Map<String, Set<Id>>>{
            acc.Id => new Map<String, Set<Id>>{
                '【企業分割】acc1' => new Set<Id>{opp1.Id,opp4.Id}
                ,'【企業分割】acc2' => new Set<Id>{opp2.Id,opp3.Id}
            }
        };
        Map<String, String> splitRankMap = new Map<String, String>{
            acc.Id + '【企業分割】acc1' => 'Ａランク'
            ,acc.Id + '【企業分割】acc2' => 'Ｂランク'
        };
        Test.startTest();
        CRMDPSplitAccountENP.run(accids, splitMap, splitRankMap);
        Test.stopTest();

        // 更新後値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.ParentId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Name
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c
            FROM mpMerchant__c WHERE Id = :mer1.Id
        ]) {
            // 企業IDチェック
            Id accid = rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId;
            System.assertNotEquals(accid, acc.Id);
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);

            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.ParentId);

            System.assertEquals('【企業分割】acc1', rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Name);

            System.assertEquals('Ａランク', rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);

            System.assertEquals(true, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c);
        }
        for (mpOpportunity__c rec : [
            SELECT Id, AccountId__c
                ,OrderProgressId__r.AccountId__c
                ,OrderProgressId__r.OpportunityId__r.AccountId
                ,OrderProgressId__r.OpportunityId__r.Account.ParentId
                ,OrderProgressId__r.OpportunityId__r.Account.Name
                ,OrderProgressId__r.OpportunityId__r.Account.Rank__c
                ,OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c
            FROM mpOpportunity__c WHERE Id = :mpopp2.Id
        ]) {
            // 企業IDチェック
            Id accid = rec.OrderProgressId__r.OpportunityId__r.AccountId;
            System.assertNotEquals(accid, acc.Id);
            System.assertEquals(accid, rec.AccountId__c);
            System.assertEquals(accid, rec.OrderProgressId__r.AccountId__c);

            System.assertEquals(acc.Id, rec.OrderProgressId__r.OpportunityId__r.Account.ParentId);

            System.assertEquals('【企業分割】acc2', rec.OrderProgressId__r.OpportunityId__r.Account.Name);

            System.assertEquals('Ｂランク', rec.OrderProgressId__r.OpportunityId__r.Account.Rank__c);

            System.assertEquals(true, rec.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c);
        }
        for (OrderProgress__c rec : [
            SELECT Id, AccountId__c
                ,OpportunityId__r.AccountId
                ,OpportunityId__r.Account.ParentId
                ,OpportunityId__r.Account.Name
                ,OpportunityId__r.Account.Rank__c
                ,OpportunityId__r.Account.CRMDPIsSplit__c
            FROM OrderProgress__c WHERE Id = :op3.Id
        ]) {
            // 企業IDチェック
            Id accid = rec.OpportunityId__r.AccountId;
            System.assertNotEquals(accid, acc.Id);
            System.assertEquals(accid, rec.AccountId__c);

            System.assertEquals(acc.Id, rec.OpportunityId__r.Account.ParentId);

            System.assertEquals('【企業分割】acc2', rec.OpportunityId__r.Account.Name);

            System.assertEquals('Ｂランク', rec.OpportunityId__r.Account.Rank__c);

            System.assertEquals(true, rec.OpportunityId__r.Account.CRMDPIsSplit__c);
        }
        for (Opportunity rec : [
            SELECT Id
                ,AccountId
                ,Account.ParentId
                ,Account.Name
                ,Account.Rank__c
                ,Account.CRMDPIsSplit__c
            FROM Opportunity WHERE Id = :opp4.Id
        ]) {
            // 企業IDチェック
            Id accid = rec.AccountId;
            System.assertNotEquals(accid, acc.Id);

            System.assertEquals(acc.Id, rec.Account.ParentId);

            System.assertEquals('【企業分割】acc1', rec.Account.Name);

            System.assertEquals('Ａランク', rec.Account.Rank__c);

            System.assertEquals(true, rec.Account.CRMDPIsSplit__c);
        }
    }

    // 包括代理店データ（アタックリスト以下は更新されない）
    @isTest
    private static void execute9() {
        Account acc = TestDataFactory.createAccount('acc', true);
        User user = TestDataFactory.createUser('user', 'システム管理者', true);
        AccountTeamMember atm = TestDataFactory.createAccountTeamMember(acc.Id, user.Id, 'エンプラ/パートナー', 'Offline加盟店', true);

        Opportunity opp1 = TestDataFactory.createOpportunity('opp1', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp2 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        Opportunity opp3 = TestDataFactory.createOpportunity('opp2', acc.Id, Date.today(), 'OpportunityRecordType_Enterprise_Offline', false);
        insert new List<Opportunity>{opp1,opp2,opp3};

        OrderProgress__c op1 = TestDataFactory.createOrderProgress('op1', acc.Id, opp1.Id, RECORDTYPEID_OP_PAY_PARTNER, false);
        OrderProgress__c op2 = TestDataFactory.createOrderProgress('op2', acc.Id, opp2.Id, RECORDTYPEID_OP_PARTNER_ONLINE, false);
        OrderProgress__c op3 = TestDataFactory.createOrderProgress('op3', acc.Id, opp3.Id, RECORDTYPEID_OP_DIRECT_SMB, false);
        insert new List<OrderProgress__c>{op1,op2,op3};

        mpOpportunity__c mpopp1 = TestDataFactory.createMpOpportunity('mpopp1', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp1.OrderProgressId__c = op1.Id;
        mpopp1.AccountId__c = acc.Id;
        mpOpportunity__c mpopp2 = TestDataFactory.createMpOpportunity('mpopp2', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp2.OrderProgressId__c = op2.Id;
        mpopp2.AccountId__c = acc.Id;
        mpOpportunity__c mpopp3 = TestDataFactory.createMpOpportunity('mpopp3', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp3.OrderProgressId__c = op2.Id;
        mpopp3.AccountId__c = acc.Id;
        mpOpportunity__c mpopp4 = TestDataFactory.createMpOpportunity('mpopp4', RECORDTYPEID_MPOPP_MPLIST, false);
        mpopp4.OrderProgressId__c = op3.Id;
        mpopp4.AccountId__c = acc.Id;
        insert new List<mpOpportunity__c>{mpopp1,mpopp2,mpopp3,mpopp4};

        mpMerchant__c mer1 = TestDataFactory.createMpMerchant('mer1', '123456789012345001', false);
        mer1.mpOpportunity__c = mpopp1.Id;
        mer1.AccountId__c = acc.Id;
        mpMerchant__c mer2 = TestDataFactory.createMpMerchant('mer2', '123456789012345002', false);
        mer2.mpOpportunity__c = mpopp2.Id;
        mer2.AccountId__c = acc.Id;
        mpMerchant__c mer3 = TestDataFactory.createMpMerchant('mer3', '123456789012345003', false);
        mer3.mpOpportunity__c = mpopp3.Id;
        mer3.AccountId__c = acc.Id;
        mpMerchant__c mer4 = TestDataFactory.createMpMerchant('mer4', '123456789012345004', false);
        mer4.mpOpportunity__c = mpopp4.Id;
        mer4.AccountId__c = acc.Id;
        insert new List<mpMerchant__c>{mer1,mer2,mer3,mer4};

        CompanyInfo_UniqueId_Relation__c cur1 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur1.UniqueId__c = '123456789012345001';
        CompanyInfo_UniqueId_Relation__c cur2 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur2.UniqueId__c = '123456789012345002';
        CompanyInfo_UniqueId_Relation__c cur3 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur3.UniqueId__c = '123456789012345003';
        CompanyInfo_UniqueId_Relation__c cur4 = TestDataFactory.createCompanyInfo_UniqueId_Relation(false);
        cur4.UniqueId__c = '123456789012345004';
        insert new List<CompanyInfo_UniqueId_Relation__c>{cur1,cur2,cur3,cur4};

        Set<Id> merids = new Set<Id>{mer1.Id,mer2.Id,mer3.Id,mer4.Id};
        Set<Id> curids = new Set<Id>{cur1.Id,cur2.Id,cur3.Id,cur4.Id};

        // 更新前値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
                ,mpOpportunity__r.OrderProgressId__r.RecordTypeId
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId);

            // MIDチェック
            String mid = rec.Id == mer1.Id ? '123456789012345001'
                        : rec.Id == mer2.Id ? '123456789012345002'
                        : rec.Id == mer3.Id ? '123456789012345003'
                        : rec.Id == mer4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.MerchantId__c);

            // ランクチェック
            System.assertEquals(null, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);

            String rectypeid = rec.Id == mer1.Id ? RECORDTYPEID_OP_PAY_PARTNER
                            : rec.Id == mer2.Id ? RECORDTYPEID_OP_PARTNER_ONLINE
                            : rec.Id == mer3.Id ? RECORDTYPEID_OP_PARTNER_ONLINE
                            : rec.Id == mer4.Id ? RECORDTYPEID_OP_DIRECT_SMB
                            : null;
            System.assertEquals(rectypeid, rec.mpOpportunity__r.OrderProgressId__r.RecordTypeId);
        }

        // 更新前値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);
            // MIDチェック
            String mid = rec.Id == cur1.Id ? '123456789012345001'
                        : rec.Id == cur2.Id ? '123456789012345002'
                        : rec.Id == cur3.Id ? '123456789012345003'
                        : rec.Id == cur4.Id ? '123456789012345004'
                        : null;
            System.assertEquals(mid, rec.UniqueId__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }

        // テスト用値セット（CSVから抽出する想定の値）
        Set<Id> accids = new Set<Id>{acc.Id};
        Map<Id, Map<String, Set<Id>>> splitMap = new Map<Id, Map<String, Set<Id>>>{
            acc.Id => new Map<String, Set<Id>>{
                '【企業分割】acc1' => new Set<Id>{opp1.Id}
                ,'【企業分割】acc2' => new Set<Id>{opp2.Id,opp3.Id}
            }
        };
        Map<String, String> splitRankMap = new Map<String, String>{
            acc.Id + '【企業分割】acc1' => 'Ａランク'
            ,acc.Id + '【企業分割】acc2' => 'Ｂランク'
        };
        Test.startTest();
        CRMDPSplitAccountENP.run(accids, splitMap, splitRankMap);
        Test.stopTest();

        // 更新後値チェック
        for (mpMerchant__c rec : [
            SELECT Id, MerchantId__c, AccountId__c
                ,mpOpportunity__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.AccountId__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.ParentId
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Name
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c
                ,mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c
            FROM mpMerchant__c WHERE Id = :merids
        ]) {
            // 企業IDチェック
            Id accid = rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.AccountId;
            System.assertNotEquals(accid, acc.Id);
            System.assertEquals(acc.Id, rec.AccountId__c);
            System.assertEquals(acc.Id, rec.mpOpportunity__r.AccountId__c);
            System.assertEquals(accid, rec.mpOpportunity__r.OrderProgressId__r.AccountId__c);

            System.assertEquals(acc.Id, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.ParentId);

            String name = rec.Id == mer1.Id ? '【企業分割】acc1'
                        : rec.Id == mer2.Id ? '【企業分割】acc2'
                        : rec.Id == mer3.Id ? '【企業分割】acc2'
                        : rec.Id == mer4.Id ? '【企業分割】acc2'
                        : null;
            System.assertEquals(name, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Name);

            // ランクチェック
            String rank = rec.Id == mer1.Id ? 'Ａランク'
                        : rec.Id == mer2.Id ? 'Ｂランク'
                        : rec.Id == mer3.Id ? 'Ｂランク'
                        : rec.Id == mer4.Id ? 'Ｂランク'
                        : null;
            System.assertEquals(rank, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.Rank__c);

            System.assertEquals(true, rec.mpOpportunity__r.OrderProgressId__r.OpportunityId__r.Account.CRMDPIsSplit__c);
        }

        // 更新後値チェック
        for (CompanyInfo_UniqueId_Relation__c rec : [
            SELECT Id, Account__c, UniqueId__c, SFReplacementCandidateFlag__c
            FROM CompanyInfo_UniqueId_Relation__c
            WHERE Id = :curids
        ]) {
            System.assertEquals(null, rec.Account__c);

            System.assertEquals(false, rec.SFReplacementCandidateFlag__c);
        }
    }

    /**
     * CSV読み込み部分のカバレッジカバー（テストは手動で実施　※静的リソース読み込みのため、テストクラスでパターンの確認が不可）
     */
    @isTest
    private static void execute_readfile() {
        Test.startTest();
        CRMDPSplitAccountENP.run(new Set<Id>());
        Test.stopTest();
    }

}