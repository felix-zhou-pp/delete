/**
* クラス名：CRMDPUpdAccountIndevFlgBatch
* クラス概要：取引先.案件・個店フラグの更新バッチ
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/30
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
global class CRMDPUpdAccountIndevFlgBatch implements Database.Batchable<sObject>, Database.Stateful {

    @testVisible
    private static final String BATCH_LOG_TITLE = '【CRM高度化】個店・取引先_案件フラグ 更新バッチ';
    @testVisible
    private static final String STATUS_CLOSED_LOST = '90'; // 失注
    @testVisible
    private static final String STATUS_WITHDRAWAL = '95'; // 取下げ
    @testVisible
    private static final String STATUS_WITHDRAWALTEXT = '取下げ'; // 取下げ

    private Integer limitSize = 0;
    private DateTime limitDateTime = DateTime.now();

    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;
    @testVisible
    private static Boolean isUpdateIndevFlgExceptionTest = false;
    @testVisible
    private static Boolean testFlag = false;

    /**
     * バッチ呼び出し
     * @param argLimitSize クエリサイズ指定。0の場合は全件実行
     * @param argLimitDateTime 日付指定。この日付以降のデータをバッチ実行対象とする
     */
    global static void run(Integer argLimitSize, DateTime argLimitDateTime) {
        // バッチサイズ200仮置き
        Database.executeBatch(new CRMDPUpdAccountIndevFlgBatch(argLimitSize, argLimitDateTime), 200);
    }

    /**
     * コンストラクタ
     * @param argLimitSize クエリサイズ指定。0の場合は全件実行
     * @param argLimitDateTime 日付指定。この日付以降のデータをバッチ実行対象とする
     */
    public CRMDPUpdAccountIndevFlgBatch(Integer argLimitSize, DateTime argLimitDateTime) {
        limitSize = argLimitSize;
        limitDateTime = argLimitDateTime;
    }

    /**
     * バッチ開始
     * @param BC 一括処理ジョブ
     * @details 個店取引先.案件フラグを取引先に紐ついている案件の営業状況を見てTRUE/FALSEを設定する
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('===== start CRMDPUpdAccountIndevFlgBatch SIZE['+ limitSize +']=====');
        if (limitSize != 0) {
            return Database.getQueryLocator([
                SELECT Id, (SELECT Id, StageName, RecordType.DeveloperName FROM Opportunities)
                FROM Account
                WHERE OpportunityFlgIndevs__c = false
                AND Id IN (
                    SELECT AccountId
                    FROM Opportunity
                    WHERE RecordTypeId = :AccountTeamMemberUtil.OPP_RTID_INDEV
                    AND StageName NOT IN (:STATUS_CLOSED_LOST, :STATUS_WITHDRAWAL, :STATUS_WITHDRAWALTEXT)
                    AND CreatedDate >= :limitDateTime
                )
                LIMIT :limitSize
            ]);
        }
        else {
            return Database.getQueryLocator([
                SELECT Id, (SELECT Id, StageName, RecordType.DeveloperName FROM Opportunities)
                FROM Account
                WHERE OpportunityFlgIndevs__c = false
                AND Id IN (
                    SELECT AccountId
                    FROM Opportunity
                    WHERE RecordTypeId = :AccountTeamMemberUtil.OPP_RTID_INDEV
                    AND StageName NOT IN (:STATUS_CLOSED_LOST, :STATUS_WITHDRAWAL, :STATUS_WITHDRAWALTEXT)
                    AND CreatedDate >= :limitDateTime
                )
            ]);
        }
    }

    /**
     * バッチ処理
     * @param BC 一括処理ジョブメソッドパラメータ
     * @param accountList 取引先リスト
     */
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        System.debug('===== execute CRMDPUpdAccountIndevFlgBatch =====');

        System.debug(BATCH_LOG_TITLE + ' :対象 取引先数:' + accountList.size());

        // 更新対象取引先のリスト
        List<Account> updateAccList = new List<Account>();
        // error取引先Idのリスト
        Set<String> errorRecIds = new Set<String>();

        // 成功・失敗件数カウント用
        Integer successCnt = 0;
        Integer errorCnt = 0;

        // 対象の取引先レコード分繰り返し
        for (Account acc : accountList) {
            // 案件フラグのリセット
            acc.OpportunityFlgIndevs__c = false;

            // 取引先に紐つく案件分処理を回す
            for (Opportunity opp: acc.Opportunities) {
                // 営業状況が”失注” or "取下げ"の場合、処理をスキップ
                if (STATUS_CLOSED_LOST.equals(opp.StageName) || STATUS_WITHDRAWAL.equals(opp.StageName) || STATUS_WITHDRAWALTEXT.equals(opp.StageName)) {
                    continue;
                }
                // それ以外
                else if (Constant.OPP_DEVELOPER_NAME_INDIVSALES.equals(opp.RecordType.DeveloperName)) {
                    acc.OpportunityFlgIndevs__c = true;
                    // 更新リストに取引先を追加したらBreak
                    updateAccList.add(acc);
                    break;
                }
            }
            
        }

        try {
            System.debug('===== execute updateAccList.size:' + updateAccList.size()  +'=====');
            // 取引先件数
            bResult.totalRecordSize += updateAccList.size();
            Logger logger = new Logger();

            // Exception発生のテストケースにて使用
            if (Test.isRunningTest() && isUpdateIndevFlgExceptionTest) {
                throw new DmlException();
            }

            // 更新エラーのテストケースにて使用
            if (Test.isRunningTest() && testFlag) {
                updateAccList[0].Rank__c = 'aaa';
                updateAccList[3].Rank__c = 'aaa';
            }

            // 取引先の更新
            List<Database.SaveResult> rList = database.update(updateAccList, false);

            // エラーメッセージ
            Map<String, List<String>> errMsgMap = new Map<String, List<String>>();

            for (Database.SaveResult result : rList) {
                if (result .isSuccess()) {
                    // 成功件数
                    bResult.successed();
                    successCnt += 1;
                }
                else {
                    // 失敗件数
                    bResult.failured();
                    this.hasException = true;
                    errorCnt += 1;

                    // エラーメッセージ
                    String errMsg = BatchResult.getErrorDetail(result.getErrors());

                    // 検出済みエラーの場合；取引先Idを追加
                    if (errMsgMap.keySet().contains(errMsg)) {
                        // エラー取引先Id
                        String errId = result.getId();

                        // エラーMapに既に追加されているIdリストを取得
                        List<String> errIdList = errMsgMap.get(errMsg);
                        // エラーIdリストに追加
                        errIdList.add(errId);
                        // エラーMapに追加
                        errMsgMap.put(errMsg, errIdList);
                    }
                    // 新規エラーの場合：エラーMapに新規追加
                    else {
                        errMsgMap.put(errMsg, new List<String>{result.getId()});
                    }
                }
            }

            // ログメッセージの準備
            List<String> logInfoText = new List<String>();
            logInfoText.add('バッチ名: CRMDPUpdAccountIndevFlgBatch\n');
            logInfoText.add('抽出 取引先件数: ' + accountList.size() + '件\n');
            logInfoText.add('更新対象 取引先件数: ' + updateAccList.size() + '件\n');
            logInfoText.add('成功 取引先件数: ' + successCnt + '件\n');
            logInfoText.add('失敗 取引先件数: ' + errorCnt + '件\n\n');
            
            // ログフォーマット
            String formatTemp = '{0}{1}{2}{3}{4}';
            Integer formatSize = 4;
            String formatLogText = '';
            
            // 全件投入成功
            if (errorCnt == 0) {
                formatLogText = String.format(formatTemp, logInfoText);
                logger.info(BATCH_LOG_TITLE, formatLogText).saveAll();
            }
            // エラーあり
            else {
                // エラー情報の出力
                for (String errmsg : errMsgMap.keySet()) {
                    String errAccRecId = String.join(errMsgMap.get(errmsg), Constant.COMMA + Constant.HALF_WIDTH_SP); 
                    logInfoText.add('エラーメッセージ: ' + errmsg + '\n');
                    logInfoText.add('失敗 取引先Id: ' + errAccRecId + '\n\n');

                    // ログフォーマットを拡張
                    formatTemp = formatTemp + '{' + (formatSize + 1) +'}' + '{' + (formatSize + 2) +'}';
                    formatSize = formatSize + 2;
                }
    
                formatLogText = String.format(formatTemp, logInfoText);
                // ログレコードの出力
                logger.error(BATCH_LOG_TITLE, formatLogText, false).saveAll();
            }
        }
        catch (Exception e) {
            system.debug(e.getmessage());
            system.debug(e.getStackTracestring());

            Logger logger = new Logger();
            logger.error(BATCH_LOG_TITLE + '_Exception', logger.formatErrorMessage(e), false).saveAll();
            this.hasException = true;
            bResult.failured(updateAccList.size());
        }
    }

    /**
     * バッチ終了
     * @param BC 一括処理ジョブメソッドパラメータ
     */
    global void finish(Database.BatchableContext BC){
        System.debug('===== finish CRMDPUpdAccountIndevFlgBatch =====');
        System.debug(BATCH_LOG_TITLE + ' 更新対象取引先総合計：' + bResult.totalRecordSize);
        System.debug(BATCH_LOG_TITLE + ' 更新成功取引先総合計：' + bResult.successedRecordSize);
        System.debug(BATCH_LOG_TITLE + ' 更新失敗取引先総合計：' + bResult.failureRecordSize);
        
        Logger logger = new Logger();
        if (this.hasException || bResult.hasError) {
            logger.error(BATCH_LOG_TITLE + '(完了)', '以下バッチ実行総数：\n' + bResult.toString(), false).saveAll();
        } else {
            logger.info(BATCH_LOG_TITLE + '(完了)', '以下バッチ実行総数：\n' + bResult.toString(), false).saveAll();
        }
    }
}