/**
* クラス名：CRMDPUpdAccountIndustryBatch
* クラス概要：取引先.業種の更新バッチ
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/22
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
global class CRMDPUpdAccountIndustryBatch implements Database.Batchable<sObject>, Database.Stateful {

    @testVisible
    private static final String BATCH_LOG_TITLE = '【CRM高度化】個店・取引先_業種 更新バッチ';
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;
    @testVisible
    private static Boolean isUpdateAccIndustryExceptionTest = false;
    @testVisible
    private static Boolean testFlag = false;

    private DateTime limitDateTime = DateTime.now();

    /**
     * バッチ呼び出し
     * @param argLimitDateTime 日付指定。この日付以降のデータをバッチ実行対象とする
     */
    global static void run(DateTime argLimitDateTime) {
        // バッチサイズ200仮置き
        Database.executeBatch(new CRMDPUpdAccountIndustryBatch(argLimitDateTime), 200);
    }

    /**
     * コンストラクタ
     * @param argLimitDateTime 日付指定。この日付以降のデータをバッチ実行対象とする
     */
    public CRMDPUpdAccountIndustryBatch(DateTime argLimitDateTime) {
        limitDateTime = argLimitDateTime;
    }

    /**
     * バッチ開始
     * @param BC 一括処理ジョブ
     * @details 個店の取引先.業種に移行元アタックリストのお取り扱い商品1をセットする
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('===== start CRMDPUpdAccountIndustryBatch =====');
        return Database.getQueryLocator([
            SELECT Id, CRMDPAccountId__c, CRMDPAccountId__r.MerchandiseClassification__c, Industry
            FROM Account
            WHERE CRMDPAccountId__c != null
            AND Id IN (
                SELECT AccountId
                FROM Opportunity
                WHERE RecordType.DeveloperName = :Constant.OPP_DEVELOPER_NAME_INDIVSALES
                AND CreatedDate >= :limitDateTime
            )
        ]);
    }

    /**
     * バッチ処理
     * @param BC 一括処理ジョブメソッドパラメータ
     * @param accountList 取引先リスト
     */
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        System.debug('===== execute CRMDPUpdAccountIndustryBatch =====');

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
            
            // 移行元アタックリストの「お取り扱い商品1」
            String prod1 = acc.CRMDPAccountId__r.MerchandiseClassification__c;

            // 移行元アタックリストの「お取り扱い商品1」から業種を決定
            if (!String.isBlank(prod1)) {
                // 業種の値
                String industryValue = MerchandiseClassificationToIndustry.get(prod1);
                
                if (!String.isBlank(industryValue)) {
                    if (!industryValue.equals(acc.Industry)) {
                        // 業種を設定
                        acc.Industry = industryValue;
                        // 更新対象リストに追加
                        updateAccList.add(acc);
                    }
                }
            }
        }

        try {
            System.debug('===== execute updateAccList.size:' + updateAccList.size()  +'=====');
            // 取引先件数
            bResult.totalRecordSize += updateAccList.size();
            Logger logger = new Logger();

            // Exception発生のテストケースにて使用
            if (Test.isRunningTest() && isUpdateAccIndustryExceptionTest) {
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
            logInfoText.add('バッチ名: CRMDPUpdAccountIndustryBatch\n');
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
    
                System.debug('formatTemp:' + formatTemp);
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
        System.debug('===== finish CRMDPUpdAccountIndustryBatch =====');
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

    // お取り商品1と業種のマッピング
    public static final Map<String, String> MerchandiseClassificationToIndustry = new Map<String, String>{
        '小売' => '小売',
        '飲食' => '飲食',
        'ビューティ・リラクゼーション' => 'ビューティ・リラクゼーション',
        '病院' => '病院',
        'スクール' => 'スクール',
        'サービス' => 'サービス',
        '娯楽' => '娯楽',
        '交通' => '交通',
        '行政・公共サービス' => '行政・公共サービス',
        '学校・教育機関' => '学校・教育機関',
        '大手向け特別' => '大手向け特別',
        'コンビニ' => 'コンビニ',
        '公共サービス' => '公共サービス',
        '大規模小売店' => '大規模小売店',
        '各種小売' => '各種小売',
        '食品スーパー' => '食品スーパー'
    };
}