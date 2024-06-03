/**
* クラス名: CRMDPConvertOrderProgressRTBatch
* クラス概要: サービス管理オブジェクト分割 レコードタイプ変更バッチ
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/10/31
* Updated Date: -
------------------------------------------------------------------------------------------------------
* サービス管理レコードタイプ「オフライン_SS切替」「オフライン_中小_加盟店」を「オフライン（旧オフライン_大手_加盟店）」に変更
* サービス管理レコードタイプ「オンライン_中小_加盟店」を「オンライン（旧オンライン_大手_加盟店）」に変更
* 開発者コンソールから以下のコマンドを実行する
* CRMDPConvertOrderProgressRTBatch.run();
*/
global class CRMDPConvertOrderProgressRTBatch implements Database.Batchable<sObject>, Database.Stateful {
    // DMLException test のためのフラグ
    @testVisible
    private static Boolean isDMLExceptionTest = false;

    // 移行対象のサービス管理レコードタイプ
    Id RECORDTYPE_OFF_SS; // オフライン_SS切替
    Id RECORDTYPE_OFF_SMALLBUSINESS; // オフライン_中小_加盟店
    Id RECORDTYPE_ON_SMALLBUSINESS; // オンライン_中小_加盟店
    Id RECORDTYPE_OFFLINE; // オフライン
    Id RECORDTYPE_ONLINE; // オンライン

    // サービス管理のレコードタイプIDのSet
    Set<String> orderProgressRecordTypeIdSet;

    // ログ保存時のタイトル
    @testVisible
    private static final String BATCH_LOG_TITLE = '【CRM高度化】サービス管理（決済事業）レコードタイプ変更バッチ';
    
    // バッチ結果格納
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;

    /**
     * コンストラクタ
     */
    public CRMDPConvertOrderProgressRTBatch() {
        // 変更対象のサービス管理のレコードタイプID取得
        RECORDTYPE_OFF_SS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'US_SS');
        RECORDTYPE_OFF_SMALLBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RecordTypeOfflineSmallBusiness');
        RECORDTYPE_ON_SMALLBUSINESS = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, 'RecordTypeOnlineSmallBusiness');
        // 変更後のサービス管理のレコードタイプID取得
        RECORDTYPE_OFFLINE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE);
        RECORDTYPE_ONLINE = mpUtilString.getRecordTypeByDeveloperName(OrderProgress__c.sObjectType, Constant.ORDP_DEVELOPER_NAME_ENP_ONLINE);

        // 移行対象のサービス管理のレコードタイプIDのSet作成
        orderProgressRecordTypeIdSet = new Set<String>{
            String.valueOf(RECORDTYPE_OFF_SS),
            String.valueOf(RECORDTYPE_OFF_SMALLBUSINESS),
            String.valueOf(RECORDTYPE_ON_SMALLBUSINESS)
        };
    }

    /**
     * バッチ呼び出し
     */
    global static void run() {
        // バッチサイズ200仮置き
        Database.executeBatch(new CRMDPConvertOrderProgressRTBatch(), 200);
    }

    /**
     * バッチ開始
     * @param BC 一括処理ジョブ
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, RecordTypeId
            FROM OrderProgress__c
            WHERE RecordTypeId IN :orderProgressRecordTypeIdSet
        ]);
    }

    /**
     * バッチ処理
     * @param BC 一括処理ジョブ
     * @param orderProgressList 更新対象サービス管理(決済事業)リスト
     */
    global void execute(Database.BatchableContext BC, List<OrderProgress__c> orderProgressList) {
        bResult.totalRecordSize += orderProgressList.size();

        // サービス管理のレコードタイプに応じてレコードタイプを変更
        for (OrderProgress__c orderProgress : orderProgressList) {

            // オフライン_SS_切替またはオフライン_中小_加盟店の場合> オフラインに変更
            if (orderProgress.RecordTypeId.equals(RECORDTYPE_OFF_SS) || orderProgress.RecordTypeId.equals(RECORDTYPE_OFF_SMALLBUSINESS)) {
                orderProgress.RecordTypeId = RECORDTYPE_OFFLINE;
            }
            // オンライン_中小_加盟店の場合> オンラインに変更
            else if (orderProgress.RecordTypeId.equals(RECORDTYPE_ON_SMALLBUSINESS)) {
                orderProgress.RecordTypeId = RECORDTYPE_ONLINE;
            }
        }
        
        try {
            if (Test.isRunningTest() && isDMLExceptionTest) {
                throw new DmlException();
            }
            update orderProgressList;

            Logger logger = new Logger();
            logger.info(BATCH_LOG_TITLE, '更新実行 サービス管理レコード件数: ' + orderProgressList.size() + '件').saveAll();

            bResult.successed(orderProgressList.size());
        }
        catch (Exception ex) {
            Logger logger = new Logger();
            logger.error(BATCH_LOG_TITLE, logger.formatErrorMessage(ex), false).saveAll();

            this.hasException = true;
            bResult.failured(orderProgressList.size());
        }
    }

    /**
     * バッチ終了
     * @param BC 一括処理ジョブ
     */
    global void finish(Database.BatchableContext BC) {
        Logger logger = new Logger();
        if (this.hasException || bResult.hasError) {
            logger.error(BATCH_LOG_TITLE + '(完了)', bResult.toString(), false).saveAll();
        } else {
            logger.info(BATCH_LOG_TITLE + '(完了)', bResult.toString(), false).saveAll();
        }
    }
}