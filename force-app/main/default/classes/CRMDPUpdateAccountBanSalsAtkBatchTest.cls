@isTest
public without sharing class CRMDPUpdateAccountBanSalsAtkBatchTest {
    //移行済みの案件レコードタイプ個店　OpportunityRecordType_IndivSales
    public static final String OPP_RTDNAME_INDIVSALES = 'OpportunityRecordType_IndivSales';
    //移行対象のPPコミュニケーションmpComm__cRT：マイストア営業活動ログ　PayPayMyStoreTask
    public static final String MPCOM_RTDNAME_MYSTTSK = 'PayPayMyStoreTask';
    @TestSetup
    static void setup(){
        // 取引先チームメンバ作成
        User testUser1 = TestDataFactory.createUser('owner00', 'セールスエンプラ管理ユーザ', true);
        User testUser2 = TestDataFactory.createUser('owner00', 'セールスエンプラ管理ユーザ', true);
        // 取引先作成
        Account acc = TestDataFactory.createAccount('テスト企業', false);
        acc.RecordTypeId = mpUtilString.getRecordTypeByDeveloperName(Account.sObjectType, 'AccountRecordType_MemberStore');
        Account acc2 = acc.clone();
        acc2.Name = '企業2';
        Account acc3 = acc.clone();
        acc3.Name = '企業3';
        Account acc4 = acc.clone();
        acc4.Name = '企業4';
        Account accNo1 = acc.clone();
        accNo1.Name = '企業No1';
        Account accNo2 = acc.clone();
        accNo2.Name = '企業No2';
        Insert new List<Account>{acc,acc2,acc3,acc4,accNo1,accNo2};
        AccountTeamMember atm_indev = TestDataFactory.createAccountTeamMember(acc.Id, testUser1.Id, '個店訪販', '個店', false);
        AccountTeamMember atm_indev2 = TestDataFactory.createAccountTeamMember(acc2.Id, testUser1.Id, '個店訪販', '個店', false);
        AccountTeamMember atm_indev3 = TestDataFactory.createAccountTeamMember(acc3.Id, testUser1.Id, '個店訪販', '個店', false);
        AccountTeamMember atm_indev4 = TestDataFactory.createAccountTeamMember(acc4.Id, testUser1.Id, '個店訪販', '個店', false);
        AccountTeamMember atm_indevNo1 = TestDataFactory.createAccountTeamMember(accNo1.Id, testUser1.Id, '個店訪販', '個店', false);
        AccountTeamMember atm_indevNo2 = TestDataFactory.createAccountTeamMember(accNo2.Id, testUser2.Id, '個店訪販', '個店', false);
        Insert new List<AccountTeamMember>{atm_indev,atm_indev2,atm_indev3,atm_indev4,atm_indevNo1,atm_indevNo2};
        //アタックリスト 
        mpOpportunity__c mpOpp1 = TestDataFactory.createMpOpportunity('移行元アタックリスト1',mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, 'mpList'),false);
        mpOpp1.Status__c = '申込完了';
        mpOpp1.OwnerId = testUser1.Id;
        mpOpp1.Note__c = 'コメント1';//提案日時・希望連絡先情報・コメント
        mpOpp1.RecentToDoComment__c = '最新活動コメント1';//最新活動コメント
        mpOpportunity__c mpOpp2 = mpOpp1.clone();
        mpOpp2.Name = '移行元アタックリスト2';
        mpOpportunity__c mpOpp3 = mpOpp1.clone();
        mpOpp3.Name = '移行元アタックリスト3';
        mpOpportunity__c mpOppNo = mpOpp1.clone();
        mpOppNo.Name = '移行元アタックリストNo';
        Insert new List<mpOpportunity__c>{mpOpp1,mpOpp2,mpOpp3,mpOppNo};
        //営業履歴
        mpBusinessToDo__c bt1     = TestDataFactory.createMpBusinessToDo(mpOpp1.Id,false);
        Datetime btDT             = Datetime.newInstance(2011, 1, 1);
        Datetime btNextDT         = Datetime.newInstance(2025, 1, 1);
        bt1.CreatedDate           = btDT;
        bt1.Result__c             = '3.決裁者不在（再訪不可）';//移行条件　コンタクト結果
        bt1.Check__c              = '4.その他（フリーテキスト）';//対応者確認（コンタクト完了以外）
        bt1.CheckMemo__c          = 'メモテキスト対応者確認（その他）';//対応者確認（その他）	
        bt1.Subject__c            = '自由入力2.電話(アウト)	';//コンタクト手段
        bt1.BusinessMemo__c       = '営業履歴の備考';//備考欄
        bt1.Comment__c            = '営業履歴のコメント';//コメント
        bt1.NextMeetingDate__c    = btNextDT;//次回コンタクト予定日
        bt1.BusinessRoute__c      = '社員紹介CP';//営業経路は必須です
        mpBusinessToDo__c bt2     = bt1.clone();
        bt2.Result__c             = '5.門前払い（再訪不可）';
        bt2.mpRelation__c         = mpOpp2.Id;
        mpBusinessToDo__c bt3    = bt1.clone();
        bt3.Result__c            = '6.実店舗なし（再訪不可）';
        bt3.mpRelation__c         = mpOpp3.Id;
        mpBusinessToDo__c btNo    = bt1.clone();
        btNo.Result__c            = '4.門前払い（再訪）';
        btNo.mpRelation__c         = mpOppNo.Id;
        Insert new List<mpBusinessToDo__c>{bt1,bt2,bt3,btNo};
        
        //PPストア
        PayPayStore__c store1 = TestDataFactory.createPayPayStore('ストア1',true);
        PayPayStore__c storeNo = TestDataFactory.createPayPayStore('ストアNo',true);
        //コミュニケーション
        Datetime cDT = Datetime.newInstance(2022, 4, 1);
        mpComm__c com1 = TestDataFactory.createMpComm(false);
        com1.recordTypeId = mpUtilString.getRecordTypeByDeveloperName(mpComm__c.sObjectType, MPCOM_RTDNAME_MYSTTSK); 
        com1.PayPayMyStoreToDo__c = store1.Id;//主従項目
        com1.ContactResult__c   = '再訪不可';//移行条件項目
        com1.OwnerId            = testUser1.Id;
        com1.CreatedDate        = cDT;
        com1.IntroMemo__c       = 'コミュ1コンタクト関連備考';//【コンタクト関連】コンタクト関連備考
        com1.X08__c             = 'その他（なんでも）';//その他（なんでも）
        com1.ContactType__c     = '電話';   //【コンタクト関連】コンタクト種別
        com1.Comment__c         = 'コミュニケーション1コメント';//コメント
        com1.CouponIssueNegotiationsDate__c = Date.newInstance(2022, 1, 1);
        com1.LightPlanNegotiationsDate__c   = Date.newInstance(2022, 1, 2);
        com1.PayPayFlyerNegotiationsDate__c = Date.newInstance(2022, 1, 3);
        com1.StampIssueNegotiationsDate__c  = Date.newInstance(2022, 1, 4);
        com1.UStoSSNegotiationsDate__c      = Date.newInstance(2022, 1, 5);
        com1.CouponIssueBusinessContent__c  = 'サービス提案';
        com1.LightPlanBusinessContent__c    = 'サポート';
        com1.StampIssueBusinessContent__c   = '商談アポ';
        com1.UStoSSBusinessContent__c       = 'PayCAS提案';
        com1.BusinessContent__c             = '挨拶';
        com1.CouponIssueSalesResults__c     = '発行完了';//クーポン発行営業結果を入力してください
        com1.UStoSSNegotiationResult__c	    = 'その他';//US→SS商談結果を入力してください 
        mpComm__c comNo = com1.clone();
        comNo.PayPayMyStoreToDo__c = storeNo.Id;//主従項目
        comNo.OwnerId              = testUser2.Id;
        comNo.ContactResult__c     = '閉店';
        comNo.IntroMemo__c         = 'コミュ2コンタクト関連備考';//【コンタクト関連】コンタクト関連備考
        comNo.X08__c               = 'コミュ2その他（なんでも）';//その他（なんでも）
        comNo.ContactType__c       = '電話';   //【コンタクト関連】コンタクト種別	電話 
        comNo.Comment__c           = 'コミュ2コメント';    //コメント
        comNo.CouponIssueNegotiationsDate__c = null;
        comNo.CouponIssueBusinessContent__c  = '';
        comNo.LightPlanNegotiationsDate__c   = Date.newInstance(2023, 1, 5);
        comNo.PayPayFlyerNegotiationsDate__c = Date.newInstance(2023, 1, 6);
        comNo.StampIssueNegotiationsDate__c  = Date.newInstance(2023, 1, 7);
        comNo.UStoSSNegotiationsDate__c      = null;
        comNo.UStoSSBusinessContent__c       = 'PayCAS提案';
        Insert new List<mpComm__c>{com1,comNo};
        // 案件作成 移行済みの案件レコードタイプ個店
        Opportunity oppO1 = TestDataFactory.createOpportunity('案件:元アタックリスト1', acc.Id, Date.newInstance(2022, 9, 30), OPP_RTDNAME_INDIVSALES, false);
        oppO1.CRMDPMpOppId__c = mpOpp1.Id;
        Opportunity oppO2 = oppO1.clone();
        oppO2.Name ='案件:元アタックリスト2';
        oppO2.AccountId = acc2.Id;
        oppO2.CRMDPMpOppId__c = mpOpp2.Id;
        Opportunity oppO3 = oppO1.clone();
        oppO3.Name ='案件:元アタックリスト3';
        oppO3.AccountId = acc3.Id;
        oppO3.CRMDPMpOppId__c = mpOpp3.Id;
        Opportunity oppONo = oppO1.clone();
        oppONo.Name ='案件:元アタックリストNo';
        oppONo.AccountId = accNo1.Id;
        oppONo.CRMDPMpOppId__c = mpOppNo.Id;
        Opportunity oppS1 = TestDataFactory.createOpportunity('案件:元ストア1', acc4.Id, Date.newInstance(2022, 9, 30), OPP_RTDNAME_INDIVSALES, false);
        oppS1.CRMDPStoreId__c = store1.Id;
        oppS1.CreatedDate = Datetime.now().addDays(-30);
        Opportunity oppSNo = TestDataFactory.createOpportunity('案件:元ストアNo', accNo2.Id, Date.newInstance(2022, 9, 30), OPP_RTDNAME_INDIVSALES, false);
        oppSNo.CRMDPStoreId__c = storeNo.Id;
        Insert new List<Opportunity>{oppO2,oppO1,oppO3,oppONo,oppS1,oppSNo};
        
    }
    //DMLエラー
    @isTest
    static void test_dmlFailure(){
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch.isDMLExceptionTest = true;
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.termIndex = 6;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.assert(logText.contains([SELECT Id FROM Opportunity LIMIT 1][0].Id));
    }
    @isTest
    //正常系、複数企業複数アタックリスト更新
    static void test_success() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.termIndex = 0;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:6'));
        System.assert(logText.contains('更新件数:6'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 4);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //件数
        System.assert(accListNml.size() == 2);
    }
    @isTest
    //正常系、複数企業複数アタックリスト更新、案件日付指定
    static void test_successWithOppCreatedDate() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.targetOppCreatedTimeStart=Datetime.newInstance(Date.Today(),Time.newInstance(0, 0, 0, 0));
        oneBth.termIndex = 0;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:5'));
        System.assert(logText.contains('更新件数:5'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 3);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //件数
        System.assert(accListNml.size() == 3);
    }
    @isTest
    //正常系、０件アタックリスト更新、案件日付指定
    static void test_successZeroWithOppCreatedDate() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.targetOppCreatedTimeStart=Datetime.newInstance(Date.Today().addDays(30),Time.newInstance(0, 0, 0, 0));
        oneBth.termIndex = 0;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:0'));
        System.assert(logText.contains('更新件数:0'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 0);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //件数
        System.assert(accListNml.size() == 6);
    }
    //期間指定実行Termテスト 件数のみ検証　詳細は別メソッド
    @isTest
    static void test_successTerm1Opp() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.targetOppCreatedTimeStart=Datetime.newInstance(Date.Today().addDays(-60),Time.newInstance(0, 0, 0, 0));
        oneBth.termIndex = 1;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:2'));
        System.assert(logText.contains('更新件数:2'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //立つ件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 1);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //立たない件数
        System.assert(accListNml.size() == 5);
    }
    @isTest
    static void test_successTerm1OppToday() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.targetOppCreatedTimeStart=Datetime.newInstance(Date.Today(),Time.newInstance(0, 0, 0, 0));
        oneBth.termIndex = 1;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:1'));
        System.assert(logText.contains('更新件数:1'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //立つ件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 0);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //立たない件数
        System.assert(accListNml.size() == 6);
    }
    //期間指定実行Termテスト ０件アタックリスト更新、案件日付指定
    @isTest
    static void test_successTerm1ZeroWithOppCreatedDate() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.targetOppCreatedTimeStart=Datetime.newInstance(Date.Today().addDays(1),Time.newInstance(0, 0, 0, 0));
        oneBth.termIndex = 1;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:0'));
        System.assert(logText.contains('更新件数:0'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //立つ件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 0);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //立たない件数
        System.assert(accListNml.size() == 6);
    }
    @isTest
    static void test_successTerm2() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.termIndex = 2;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:0'));
        System.assert(logText.contains('更新件数:0'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //立つ件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 0);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //立たない件数
        System.assert(accListNml.size() == 6);
    }
    @isTest
    static void test_successTerm3() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.termIndex = 3;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:0'));
        System.assert(logText.contains('更新件数:0'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //立つ件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 0);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //立たない件数
        System.assert(accListNml.size() == 6);
    }
    @isTest
    static void test_successTerm4() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.termIndex = 4;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:0'));
        System.assert(logText.contains('更新件数:0'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //立つ件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 0);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //立たない件数
        System.assert(accListNml.size() == 6);
    }
    @isTest
    static void test_successTerm5() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.termIndex = 5;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:0'));
        System.assert(logText.contains('更新件数:0'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //立つ件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 0);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //立たない件数
        System.assert(accListNml.size() == 6);
    }
    @isTest
    static void test_successTerm6() {
        Test.startTest();
        CRMDPUpdateAccountBanSalsAtkBatch oneBth = new CRMDPUpdateAccountBanSalsAtkBatch();
        oneBth.termIndex = 6;
        Database.executeBatch(oneBth,10);
        Test.stopTest();
        //ログ内容適切性確認
        String logText = [
            SELECT Id, Title__c, Detail__c
            FROM Log__c
            WHERE Title__c = :CRMDPUpdateAccountBanSalsAtkBatch.BATCH_NAME
        ][0].Detail__c;
        System.debug(logText);
        System.assert(logText.length()>0);
        System.assert(logText.contains('対象件数:4'));
        System.assert(logText.contains('更新件数:4'));
        System.assert(logText.contains('エラー件数:0'));
        new CRMDPUpdateAccountBanSalsAtkBatch().mainExe(new List<Opportunity>());
        //更新正確性
        List<Account> accListBan = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =true
        ];
        //立つ件数
        System.debug(accListBan.size());
        System.assert(accListBan.size() == 3);
        List<Account> accListNml = [
            SELECT Id
            FROM   Account
            WHERE BanSalesAttack__c =false
        ];
        //立たない件数
        System.assert(accListNml.size() == 3);
    }
}