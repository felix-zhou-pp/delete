/**
 * CRM高度化PJ　個店取引先訪販アタック禁止移行バッチ (企業分割後、個店案件移行後実行)
 *  - 概要
 *   CRM高度化　個店案件の移行元PPアタックリストとPPストア、の下のPP営業履歴とPPコミュニケーションを取引先のアタック禁止フラグに移行するバッチ
 *   個店案件移行後実行できる（個店取引先と案件の存在が前提）
 * 　このバッチは1項目の移行のみなので再実行を考慮しない、失敗した場合全量再実行
 * 　　ロジック：
 * 　　　根拠項目：案件.移行元PayPayアタックリスト(CRMDPMpOppId__c)	移行元PayPayストア	CRMDPStoreId__c
 * 　　　①個店案件＋案件移行元値あり　の案件レコードをバッチ取得し
 * 　　　②バッチ内、案件移行元とその下の行動相当レコード取得（コンタクト結果＝再訪不可系のみ）
 * 　　　③オブジェクトごとに行動相当レコードをループし、案件の取引先.アタック禁止フラグに移行
 * 　　　④まとめて保存し件数集計
 * 　　　⑤まとめて結果をログに
 * 　　　
 *  - 実行方法
 *   開発者コンソールから以下のコマンドを実行する
 *   Database.executeBatch(new CRMDPUpdateAccountBanSalsAtkBatch(), 200);
 */
public without sharing class CRMDPUpdateAccountBanSalsAtkBatch implements Database.Batchable<sObject>, Database.Stateful {
    // DMLException test のためのフラグ
    @testVisible
    private static Boolean isDMLExceptionTest = false;
    // 移行済みの案件レコードタイプ個店　OpportunityRecordType_IndivSales
    public final String OPP_RTDNAME_INDIVSALES = 'OpportunityRecordType_IndivSales';
    public Id RTID_OPP_IND;
    //移行対象のPPコミュニケーションmpComm__cRT：マイストア営業活動ログ　PayPayMyStoreTask
    public final String MPCOM_RTDNAME_MYSTTSK = 'PayPayMyStoreTask';
    public Id RTID_MPCOM;
    //インスタンスごとの変数
    @testVisible
    public Integer termIndex;
    //対象案件作成日時の最小時刻　2回目移行の時以前の移行済み分の排除のため
    //設定例：oneBth.targetOppCreatedTimeStart=Datetime.newInstance(Date.Today(),Time.newInstance(0, 0, 0, 0));
    @testVisible
    public Datetime targetOppCreatedTimeStart = null;
    @testVisible
    private static final String BATCH_NAME = '【CRM高度化】個店取引先訪販アタック禁止移行MigrationEventForIndStoreBatch';
    // バッチ結果格納
    @testVisible
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;
    /* コンストラクタ */
    public CRMDPUpdateAccountBanSalsAtkBatch() {
        RTID_OPP_IND = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, OPP_RTDNAME_INDIVSALES); 
        RTID_MPCOM   = mpUtilString.getRecordTypeByDeveloperName(mpComm__c.sObjectType, MPCOM_RTDNAME_MYSTTSK); 
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('===== start CRMDPUpdateAccountBanSalsAtkBatch =====');
        // ①個店案件＋案件移行元値あり　の案件レコードをバッチ取得し
        return Database.getQueryLocator(CRMDPCreatEventForIndStoreBatch.createSOQLByTerm(termIndex));
    }
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        System.debug('===== execute CRMDPUpdateAccountBanSalsAtkBatch =====');
        mainExe(oppList);
    }
    public void mainExe(List<Opportunity> oppList){
        Logger logger = new Logger();
        bResult.totalRecordSize += oppList.size();
        System.debug('処理対象個店案件数合計：' + bResult.totalRecordSize);
        Set<Id> mpOppIds = new Set<Id>();
        //②バッチ内、案件移行元とその下の行動相当レコード取得
        Map<Id,Opportunity>    mpOppToOppMap   = new Map<Id,Opportunity>();
        Map<Id,Opportunity>    ppStoreToOppMap = new Map<Id,Opportunity>();
        Set<Id>   mpOppIdLst   = new Set<Id>();
        Set<Id>   ppStoreIdLst = new Set<Id>();
        //更新対象取引先リスト
        List<Account> updateAccounts = new List<Account>();
        Set<Id> updateAccountIds = new Set<Id>();
        for(Opportunity opp : oppList){
            //アタックリストId＞案件Id
            if(opp.CRMDPMpOppId__c != null){
                mpOppIdLst.add(opp.CRMDPMpOppId__c);
                mpOppToOppMap.put(opp.CRMDPMpOppId__c, opp);
            }
            //PPストアId＞案件Id
            if(opp.CRMDPStoreId__c != null){
                ppStoreIdLst.add(opp.CRMDPStoreId__c);
                ppStoreToOppMap.put(opp.CRMDPStoreId__c, opp);
            }
        }
        //アタックリスト処理
        if(mpOppIdLst.size()>0){
            //PP営業履歴を検索
            List<mpBusinessToDo__c> mBTList = [
                SELECT 
                    //営業履歴
                    //アタックリスト
                    mpRelation__r.Id,
                    Id
                FROM   mpBusinessToDo__c
                WHERE  mpRelation__c IN  :mpOppIdLst
                    AND  Result__c   IN  ('3.決裁者不在（再訪不可）','5.門前払い（再訪不可）','6.実店舗なし（再訪不可）')
            ];
            //真の移行　営業履歴
            for(mpBusinessToDo__c mbt : mBTList){
                //更新用取引先に追加
                Id targetAccId = mpOppToOppMap.get(mbt.mpRelation__r.Id).AccountId;
                if(!updateAccountIds.contains(targetAccId)){
                    updateAccountIds.add(targetAccId);
                    updateAccounts.add(new Account(Id=targetAccId,BanSalesAttack__c=true));
                }
                
            }
        }
        //PPストア処理　PPコミュニケーション移行mpComm__c
        if(ppStoreIdLst.size()>0){
            //PPコミュニケーションを検索
            List<mpComm__c> mpComList = [
                SELECT 
                    //PPコミュニケーション
                    PayPayMyStoreToDo__r.Id,
                    Id
                FROM   mpComm__c
                WHERE  PayPayMyStoreToDo__c IN  :ppStoreIdLst //PayPayストア（マイストア営業活動ログ）	
                    AND  ContactResult__c   IN  ('再訪不可')
                    AND  RecordTypeId = :RTID_MPCOM
            ];
            
            //真の移行　PPコミュニケーション
            for(mpComm__c mpCom : mpComList){
                //更新用取引先に追加
                Id targetAccId = ppStoreToOppMap.get(mpCom.PayPayMyStoreToDo__r.Id).AccountId;
                if(!updateAccountIds.contains(targetAccId)){
                    updateAccountIds.add(targetAccId);
                    updateAccounts.add(new Account(Id=targetAccId,BanSalesAttack__c=true));
                }
            }    
        }
        //DB更新
        if(updateAccounts.size()>0){
            try{
                // for DMLException Test Logic
                if (Test.isRunningTest() && isDMLExceptionTest) {
                    updateAccounts.add(new Account(Id=RTID_OPP_IND,BanSalesAttack__c=true));
                }
                update updateAccounts;
                bResult.successed(oppList.size());
            }
            catch (Exception ex) {
                system.debug(ex.getmessage());
                system.debug(ex.getStackTracestring());
                bResult.failured(oppList.size());
                this.hasException = true;
                logger.error(BATCH_NAME, '\n▼移行失敗案件ID\n' + oppList + '\n▼エラー概要\n' + logger.formatErrorMessage(ex), false);
            }finally {
                logger.saveAll();
            }
        }else{
            //execute内の移行対象ありません
            bResult.successed(oppList.size());
        }
    }
    public void finish(Database.BatchableContext BC) {
        System.debug('===== finish MigrationEventForIndStoreBatch =====');
        System.debug('処理対象個店案件合計：' + bResult.totalRecordSize);
        System.debug(bResult.toString());
        Logger logger = new Logger();
        if (this.hasException || bResult.hasError) {
            logger.error(BATCH_NAME, bResult.toString(), true).saveAll();
        } else {
            logger.info(BATCH_NAME, bResult.toString(), false).saveAll();
        }
    }
}