/**
* クラス名: CRMDPSetOrderProgressMBRefItem
* クラス概要: サービス管理オブジェクト分割 サービス管理(加盟店事業系)参照項目更新
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/09
* Updated Date: -
------------------------------------------------------------------------------------------------------
* サービス管理(加盟店事業)レコードに対し、参照項目(サービス管理(加盟店事業))のリレーション設定処理を実施
* TODO: 余裕があれば分割バッチにあるその他Objの参照項目更新も移動。その場合起動条件のクエリも修正が必要
* CRMDPSetOrderProgressMBRefItem.run();
*/
global class CRMDPSetOrderProgressMBRefItem implements Database.Batchable<sObject>, Database.Stateful {
    // ログ保存時のタイトル
    @testVisible
    private static final String BATCH_LOG_TITLE = '【CRM高度化】サービス管理（決済事業）参照項目設定バッチ:';

    // バッチ結果格納
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;

    @testVisible
    private static Boolean isExceptionTest = false;

    public CRMDPSetOrderProgressMBRefItem() {
    }

    /**
     * バッチ呼び出し
     */
    global static void run() {
        // バッチサイズ200仮置き
        Database.executeBatch(new CRMDPSetOrderProgressMBRefItem(), 200);
    }

    /**
     * バッチ開始
     * @param BC 一括処理ジョブ
     * @details サービス管理(加盟店事業系)レコードが登録されており、
     *  サービス管理の「マイストア（サービス管理）」「参照先設定」
     * 「関連する通常クーポン（参照）」に値が登録されているレコードを取得
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, OrderProgressMB__c, MyStoreRelation__r.OrderProgressMB__c, ReferenceSetting__r.OrderProgressMB__c,
                CouponRelation__r.OrderProgressMB__c
            FROM OrderProgress__c
            WHERE OrderProgressMB__c != null
            AND ((MyStoreRelation__c != null AND OrderProgressMB__r.MyStoreRelation__c = null)
            OR (ReferenceSetting__c != null AND OrderProgressMB__r.ReferenceSetting__c = null)
            OR (CouponRelation__c != null AND OrderProgressMB__r.CouponRelation__c = null))
        ]);
    }

    /** 
     * バッチ処理
     * @param BC 一括処理ジョブ
     * @param orderProgressList 更新元サービス管理リスト
     */
    global void execute(Database.BatchableContext BC, List<OrderProgress__c> orderProgressList) {
        bResult.totalRecordSize += orderProgressList.size();

        List<OrderProgressMB__c> updateOpmList = new List<OrderProgressMB__c>();
        for (OrderProgress__c orderProgress : orderProgressList) {
            // バッチ実行時のクエリで参照項目に値があるもののみ取得しているので以下条件の一つには必ず当てはまる
            OrderProgressMB__c updateOpm = new OrderProgressMB__c(Id = orderProgress.OrderProgressMB__c);

            // 決済事業の参照している各決済事業参照項目に紐づく加盟店事業レコードIdを各項目へ設定
            // マイストア（サービス管理）
            if (orderProgress.MyStoreRelation__c != null) {
                updateOpm.MyStoreRelation__c = orderProgress.MyStoreRelation__r.OrderProgressMB__c;
            }
            // 参照先設定
            if (orderProgress.ReferenceSetting__c != null) {
                updateOpm.ReferenceSetting__c = orderProgress.ReferenceSetting__r.OrderProgressMB__c;
            }
            // 関連する通常クーポン（参照）
            if (orderProgress.CouponRelation__c != null) {
                updateOpm.CouponRelation__c = orderProgress.CouponRelation__r.OrderProgressMB__c;
            }

            updateOpmList.add(updateOpm);
        }

        Logger logger = new Logger();
        try {
            if (Test.isRunningTest() && isExceptionTest) {
                // DmlException: CIRCULAR_DEPENDENCY
                updateOpmList[0].MyStoreRelation__c = updateOpmList[0].Id;
            }
            update updateOpmList;

            logger.info(BATCH_LOG_TITLE, '更新対象レコード数合計：' + updateOpmList.size() + '件').saveAll();
            bResult.successed(updateOpmList.size());
        }
        catch (Exception ex) {
            logger.error(BATCH_LOG_TITLE, logger.formatErrorMessage(ex), false).saveAll();

            this.hasException = true;
            bResult.failured(updateOpmList.size());
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
        }
        else {
            logger.info(BATCH_LOG_TITLE+ '(完了)', bResult.toString(), false).saveAll();
        }
    }
}