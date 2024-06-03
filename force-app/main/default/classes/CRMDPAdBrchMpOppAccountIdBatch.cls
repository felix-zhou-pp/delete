/**
 * CRM高度化PJ　個店移行済（支部追加）アタックリストに取引先を付けるバッチ
 *  - 概要
 *   CRM高度化　アーキテクチャ移行時に使用
 * 　個店アタックリストに取引先を付ける
 *   個店アタックリスト移行後実行できる（個店取引先と案件の存在が前提）
 * 　すでに取引先がある支部追加アタックリストはスキップされる
 * 　　ロジック：
 * 　　　根拠項目：案件.移行元PayPayアタックリスト(CRMDPMpOppId__c)	
 * 　　　①個店案件＋移行元PayPayアタックリスト値あり　の案件レコードをバッチ取得し
 * 　　　②バッチ内、移行元PPアタックリストを「本部」にする支店追加アタックリスト取得（RecordTypeAddBrunch）
 * 　　　③支店追加アタックリストの取引先IDを案件の取引先にセットし
 * 　　　④まとめて保存
 * 　　　
 *  - 実行方法
 *   開発者コンソールから以下のコマンドを実行する
 *   ①10,000支部以上の超大型本部は1000件ずつ単独実行： CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x000002CcmeEAC',1000);
 * 　　※1000以上だとCPULimit
 *   ②ログ確認し終わったら、繰り返し11回実行、毎回ログで件数確認、最後の一回のログの件数はきれいな1000ではない、エラーが無くログも出なくなるまで実行
 *   ③ほか500以上単独実行も同じやり方、回数は下記記載を参考
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x000002CuwwEAC',1000);  4回
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L5j000000uwWpEAI',1000);  3回
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x000002BuG4EAK',1000);  2回
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x000002C5POEA0',1000);  2回
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x000002BlZWEA0',1000);  2回
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x000002nJ4sEAE',1000);  2回
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x0000009yPeEAI',1000);  2回
 * ここまで1000支部以上、以下は基本実行不要です、ただし後続の通常実行がDML10000以上エラーになった場合要実行
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x000002VOXSEA4',1000);
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x000000BUlyEAG',1000);
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x000002AHl2EAG',1000);
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x000000AbetEAC',1000);
 * CRMDPAdBrchMpOppAccountIdBatch.commonSpecialRun('a2L2x0000009cHHEAY',1000);
 * ここまで500支部以上
 *   ④上記終わってから通常サイズの実行：Database.executeBatch(new CRMDPAdBrchMpOppAccountIdBatch(), 500);
 * 
 * 備考：
 * 超大型本部二回実行：a2L2x000002CcmeEAC
 * 大型本部12個4回から2回：
 * a2L2x000002CuwwEAC
 * a2L5j000000uwWpEAI
 * a2L2x000002BuG4EAK
 * a2L2x000002C5POEA0
 * a2L2x000002BlZWEA0
 * a2L2x000002nJ4sEAE
 * a2L2x0000009yPeEAI
 * ここまで1000超え
 * a2L2x000002VOXSEA4
 * a2L2x000000BUlyEAG
 * a2L2x000002AHl2EAG
 * a2L2x000000AbetEAC
 * a2L2x0000009cHHEAY
 */
public without sharing class CRMDPAdBrchMpOppAccountIdBatch implements Database.Batchable<sObject>, Database.Stateful{
    // DMLException test のためのフラグ
    @testVisible
    private static Boolean isDMLExceptionTest = false;
    
    // 移行済みの案件レコードタイプ個店　OpportunityRecordType_IndivSales
    public static final String OPP_DEVELOPER_NAME_INDIVSALES = 'OpportunityRecordType_IndivSales';
    //更新対象のアタックリストレコードタイプ支店追加
    public static final String MPOPP_DEVELOPER_NAME_ADDBR = 'RecordTypeAddBrunch';
    public static final Id RTID_OPP_IND     = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, OPP_DEVELOPER_NAME_INDIVSALES);
    public static final Id RTID_MPOPP_ADDBR = mpUtilString.getRecordTypeByDeveloperName(mpOpportunity__c.sObjectType, MPOPP_DEVELOPER_NAME_ADDBR); 
    @testVisible
    private static final String BATCH_NAME = '【CRM高度化】個店アタックリスト支部追加取引先紐づけCRMDPAdBrchMpOppAccountIdBatch';
    //対象案件作成日時の最小時刻　2回目移行の時以前の移行済み分の排除のため
    //設定例：oneBth.targetOppCreatedTimeStart=Datetime.newInstance(Date.Today(),Time.newInstance(0, 0, 0, 0));
    @testVisible
    public Datetime targetOppCreatedTimeStart = null;
    // バッチ結果格納
    @testVisible
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;
    
    
    //各種単独実行用共通メソッド
    public static void commonSpecialRun(Id branchId,Integer updateSize){
        BatchResult bResultSRun = new BatchResult();
        Logger logger = new Logger();
        Opportunity opp = [
            SELECT 
                // 後続処理に必要な項目
                Id,
                AccountId,
                CRMDPMpOppId__c  
            FROM Opportunity
            WHERE RecordTypeId = :RTID_OPP_IND
            AND CRMDPMpOppId__c = :branchId
        ][0];
        System.debug(opp);
        //支部追加を検索
        List<mpOpportunity__c> mpOppAddBrList = [
            SELECT 
                  Id,AccountId__c,Branch__c
            FROM  mpOpportunity__c
            WHERE RecordTypeId = :RTID_MPOPP_ADDBR
            AND   Branch__c    = :branchId 
            AND   AccountId__c = null  
            LIMIT :updateSize
        ];
        bResultSRun.totalRecordSize = mpOppAddBrList.size();
        //支部追加アタックリストありました
        if(mpOppAddBrList.size()>0){
            Set<Id> mpOppABIds = new Set<Id>();
            Set<Id> mpOppABAccountIds = new Set<Id>();
            //③支部追加アタックリストの取引先IDを案件の取引先にセットし
            for(mpOpportunity__c mpOppAB : mpOppAddBrList){
                //対象支部の本部＝移行前アタックリスト　満たす案件の取引先を使う
                mpOppAB.AccountId__c = opp.AccountId;
                mpOppABIds.add(mpOppAB.Id);
                mpOppABAccountIds.add(mpOppAB.AccountId__c);
                System.debug(mpOppAB);
            }
            //④まとめて保存
            if (Test.isRunningTest() && isDMLExceptionTest) {
                mpOppAddBrList.add(new mpOpportunity__c(Name = 'テスト用レコード', RecordTypeId = null));
            }
            try {
                update mpOppAddBrList;
                bResultSRun.successed(mpOppAddBrList.size());
            }
            catch (Exception ex) {
                system.debug(ex.getmessage());
                system.debug(ex.getStackTracestring());
                bResultSRun.failured(mpOppAddBrList.size());
                logger.error(BATCH_NAME, '\n▼更新失敗の支部追加アタックリストID\n' + branchId + mpOppABIds + mpOppABAccountIds + '\n▼エラー概要\n' + logger.formatErrorMessage(ex), false);
            }finally {
                if (bResultSRun.hasError) {
                    logger.error(BATCH_NAME, bResultSRun.toString(), true).saveAll();
                } else {
                    logger.info(BATCH_NAME, bResultSRun.toString(), false).saveAll();
                }
                logger.saveAll();
            }
        }else{
            //execute内の個店アタックリストと関連する支店追加ありません
            logger.error(BATCH_NAME, '\n▼対象支部ありません\n'+branchId ,true);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('===== start CRMDPAdBrchMpOppAccountIdBatch =====');
        //①個店案件＋移行元PayPayアタックリスト値あり　の案件レコードをバッチ取得し
        return Database.getQueryLocator([
            SELECT 
                // 後続処理に必要な項目
                Id,
                AccountId,
                CRMDPMpOppId__c  
            FROM Opportunity
            WHERE RecordTypeId = :RTID_OPP_IND
            AND CRMDPMpOppId__c != null
            AND CreatedDate >= :targetOppCreatedTimeStart
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        System.debug('===== execute CRMDPAdBrchMpOppAccountIdBatch =====');
        Logger logger = new Logger();
        bResult.totalRecordSize += oppList.size();
        System.debug('処理対象個店案件数合計：' + bResult.totalRecordSize);
        Set<Id> mpOppIds = new Set<Id>();
        //②バッチ内、移行元PPアタックリストを「本部」にする支店追加アタックリスト取得（RecordTypeAddBrunch）
        Map<Id,Opportunity> mpOppToOppMap = new Map<Id,Opportunity>();
        for(Opportunity opp : oppList){
            //本部Id＞案件IdのMapを作る
            mpOppIds.add(opp.CRMDPMpOppId__c);
            mpOppToOppMap.put(opp.CRMDPMpOppId__c, opp);
        }
        if(mpOppIds.size()>0){
            //支部追加を検索
            List<mpOpportunity__c> mpOppAddBrList = [
                SELECT 
                      Id,AccountId__c,Branch__c
                FROM  mpOpportunity__c
                WHERE RecordTypeId = :RTID_MPOPP_ADDBR
                AND   Branch__c IN :mpOppIds  
                AND   AccountId__c = null  
            ];
            //支部追加アタックリストありました
            if(mpOppAddBrList.size()>0){
                Set<Id> mpOppABIds = new Set<Id>();
                Set<Id> mpOppABAccountIds = new Set<Id>();
                List<mpOpportunity__c> mpOppAddBrUpdateList = new List<mpOpportunity__c> ();
                //③支部追加アタックリストの取引先IDを案件の取引先にセットし
                for(mpOpportunity__c mpOppAB : mpOppAddBrList){
                    //対象支部の本部＝移行前アタックリスト　満たす案件の取引先を使う
                    mpOppAB.AccountId__c = mpOppToOppMap.get(mpOppAB.Branch__c).AccountId;
                    mpOppABIds.add(mpOppAB.Id);
                    mpOppABAccountIds.add(mpOppAB.AccountId__c);
                    mpOppAddBrUpdateList.add(mpOppAB);
                }
                //④まとめて保存
                // for DMLException Test Logic
                if (Test.isRunningTest() && isDMLExceptionTest) {
                    mpOppAddBrUpdateList.add(new mpOpportunity__c(Name = 'テスト用レコード', RecordTypeId = null));
                }
                try {
                    System.debug('===== execute mpOppAddBrList.Size:' + mpOppAddBrList.size() + ' =====');
                    update mpOppAddBrUpdateList;
                    bResult.successed(oppList.size());
                }
                catch (Exception ex) {
                    system.debug(ex.getmessage());
                    system.debug(ex.getStackTracestring());
                    bResult.failured(oppList.size());
                    this.hasException = true;
                    logger.error(BATCH_NAME, '\n▼更新失敗の支部追加アタックリストID\n' + mpOppABIds + mpOppABAccountIds + '\n▼エラー概要\n' + logger.formatErrorMessage(ex), false);
                }finally {
                    logger.saveAll();
                }
            }else{
                //execute内の個店アタックリストと関連する支店追加ありません
                bResult.successed(oppList.size());
            }
        }
        
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('===== finish CRMDPAdBrchMpOppAccountIdBatch =====');
        System.debug('処理対象移行元アタックリストある個店案件合計：' + bResult.totalRecordSize);
        System.debug(bResult.toString());
        Logger logger = new Logger();
        if (this.hasException || bResult.hasError) {
            logger.error(BATCH_NAME, bResult.toString(), true).saveAll();
        } else {
            logger.info(BATCH_NAME, bResult.toString(), false).saveAll();
        }
    }

}