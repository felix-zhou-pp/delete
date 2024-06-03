/**
 * CRM高度化PJ　PP加盟店の空取引先更新バッチ (移行全部完了後、トリガー有効化後)
 *  - 概要
 *   CRM高度化　データ移行後、取引先が空のPP加盟店を更新して、PP加盟店バッチ
 *   個店案件移行後実行できる（個店取引先と案件の存在が前提）
 * 　このバッチは1項目の移行のみなので再実行を考慮しない、失敗した場合全量再実行
 * 　データ量の想定、PP加盟店全量162万　Start対象100万　条件満たす約7400件
 * 　　ロジック：
 * 　　　根拠項目：取引先が空、かつアタックリストに取引先がある、PP加盟店
 * 　　　①空更新
 * 　　　②エラーならログ記録、単独なのでロールバック不要
 * 　　　③終了後再度件数取得
 * 　　　④対象件数、更新できた件数、失敗件数、更新後取引先空欄のままの件数
 * 　　　⑤まとめて結果をログに
 *  - 実行方法
 *   開発者コンソールから以下のコマンドを実行する
 *   Database.executeBatch(new CRMDPUpdateAccountInMpMerchantBatch(), 200);
 */
public without sharing class CRMDPUpdateAccountInMpMerchantBatch implements Database.Batchable<sObject>, Database.Stateful  {
    // DMLException test のためのフラグ
    @testVisible
    private static Boolean isDMLExceptionTest = false;
    @testVisible
    private static final String BATCH_NAME = '【CRM高度化】PP加盟店の空取引先更新バッチ';
    
    // バッチ結果格納
    @testVisible
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        bResult.totalRecordSize =  [SELECT count() FROM mpMerchant__c WHERE AccountId__c = null AND mpOppAccount_Id_F__c <> ''];
        System.debug('===== start CRMDPUpdateAccountInMpMerchantBatch ====='+bResult.totalRecordSize);
        return Database.getQueryLocator([
            SELECT
                Id
            FROM mpMerchant__c
            WHERE AccountId__c = null
            AND mpOppAccount_Id_F__c <> ''
        ]);
    }
    public void execute(Database.BatchableContext BC, List<mpMerchant__c> mList) {
        System.debug('===== execute CRMDPUpdateAccountInMpMerchantBatch =====');
        Logger logger = new Logger();
        try{
            // for DMLException Test Logic
            if (Test.isRunningTest() && isDMLExceptionTest) {
                mList.add(new mpMerchant__c(Id=mList[0].Id));
            }
            update mList;
            bResult.successed(mList.size());
        }
        catch (Exception ex) {
            system.debug(ex.getmessage());
            system.debug(ex.getStackTracestring());
            bResult.failured(mList.size());
            this.hasException = true;
            logger.error(BATCH_NAME, '\n▼失敗対象\n' + mList + '\n▼エラー概要\n' + logger.formatErrorMessage(ex), false);
        }finally {
            logger.saveAll();
        }
    }
    public void finish(Database.BatchableContext BC) {
        System.debug('===== finish CRMDPUpdateAccountInMpMerchantBatch =====');
        System.debug('処理対象合計：' + bResult.totalRecordSize);
        System.debug('成功合計：' + bResult.successedRecordSize);
        System.debug('失敗合計：' + bResult.failureRecordSize);
        String afterSummaryLogText = '\n処理後PP加盟店空取引先合計：' + [SELECT count() FROM mpMerchant__c WHERE AccountId__c = null]
            + '\n処理後PP加盟店空取引先かつアタックリストに取引先ある合計：'+[SELECT count() FROM mpMerchant__c WHERE AccountId__c = null AND mpOppAccount_Id_F__c <> ''];
        System.debug(afterSummaryLogText);
        Logger logger = new Logger();
        if (this.hasException || bResult.hasError) {
            logger.error(BATCH_NAME, bResult.toString()+afterSummaryLogText, true).saveAll();
        } else {
            logger.info(BATCH_NAME, bResult.toString()+afterSummaryLogText, false).saveAll();
        }
    }

}