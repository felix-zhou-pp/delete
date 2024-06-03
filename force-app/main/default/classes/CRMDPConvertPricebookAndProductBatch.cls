/**
* クラス名: CRMDPConvertPricebookAndProductBatch
* クラス概要: サービス管理オブジェクト分割 価格表更新バッチ
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/6
* Updated Date: -
------------------------------------------------------------------------------------------------------
* 案件に紐づいている、標準価格表に含まれるサービスを、カスタム価格表に含まれるサービスに付け替える、サービス管理は新たに作成されないようにする
* 開発者コンソールから以下のコマンドを実行する
* CRMDPConvertPricebookAndProductBatch.run();
* - 前提条件
* フロー「サービス情報登録時保存後フロー」の無効化
* 新しい価格表、新しいサービスが組織に追加されていること
* - サービス名
* 次の設計書をもとに実装
* https://docs.google.com/spreadsheets/d/1LGjfVBfMG2STi9OgTlmTojowsmC4BsFf/edit#gid=167590816&fvid=1042614316
*/
global class CRMDPConvertPricebookAndProductBatch implements Database.Batchable<sObject>, Database.Stateful {

    // DMLException test のためのフラグ
    @testVisible
    private static Boolean isDMLExceptionTest = false;
    // テストで異なるエラーを出し分けるための文字列
    @testVisible
    private static String errorExpected = '';

    // エラーログ保存時のタイトル
    @testVisible
    private static final String BATCH_LOG_TITLE = '【CRM高度化】価格表更新バッチ:';
    @testVisible
    private static final String COND_DELETE_PRICEBOOK = ' 価格表null更新';
    @testVisible
    private static final String COND_RELATECUSTOM_PRICEBOOK = ' 価格表紐づけ直し';
    @testVisible
    private static final String COND_INSERT_OPPLINEITEMLIST = ' サービス情報作成';
    @testVisible
    private static final String COND_UPDATE_ORDERPROGRESS = ' サービス管理更新';

    // バッチ結果格納
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;
    private integer notReplaceNum = 0;
    private integer multiOrderNum = 0;
    private integer noOrderNum = 0;
    private integer lackOfInfoNum = 0;
    private integer notFoundPbNum = 0;

    // カスタム例外クラス
    public class MyException extends Exception{}

    // 組織の価格表ID
    ID PRICEBOOK_ID_STANDARD;
    ID PRICEBOOK_ID_INDEVSALES;

    // 価格表エントリIDとエントリ名(サービス名)のMap
    Map<Id, String> pBookEntryIdNameMap = new Map<Id, String>();
    // 標準価格表から移行しない価格表エントリID
    Set<Id> dontReplacePBookEntryIdSet = new Set<Id>();
    // 価格表エントリと価格表ID
    Map<Id, Id> pBookEntryIdPriceBook2IdMap = new Map<Id, Id>();
    // 価格表エントリと紐づくサービス
    Map<Id, Id> pBookEntryIdProduct2IdMap = new Map<Id, Id>();
    // 価格表移行タイプ - 旧価格表エントリIDと新価格表エントリID
    Map<CRMDPPBookProd2NameUtil.REPLACE_TYPE, Map<Id, Id>> typeAndReplacePBookEntryIdMap = new Map<CRMDPPBookProd2NameUtil.REPLACE_TYPE, Map<Id, Id>>();

    /**
     * コンストラクタ
     */
    public CRMDPConvertPricebookAndProductBatch() {
    }

    /**
     * バッチ呼び出し
     */
    global static void run() {
        // バッチサイズ200仮置き
        Database.executeBatch(new CRMDPConvertPricebookAndProductBatch(), 200);
    }

    /**
     * バッチ開始
     * @param BC 一括処理ジョブ
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // 価格表ID取得
        getPricebook2Id();
        setPBookEntryIdPBookIdMap();

        return Database.getQueryLocator([
            SELECT
                opp.id, opp.name, opp.Pricebook2Id, opp.AccountId,
                (SELECT 
                    lineItems.Id,
                    lineItems.name,
                    lineItems.PricebookEntry.Product2.Id,
                    lineItems.PricebookEntry.Name,
                    lineItems.PricebookEntry.Product2.Name,
                    lineItems.OpportunityId,
                    lineItems.ForRelatedOrderProgressId__c
                    FROM OpportunityLineItems lineItems
                ),
                (SELECT
                    op.Id,
                    op.OnOff__c,
                    op.NewIndustryclass__c
                    FROM OrderProgress_OpportunityId__r op)
            FROM Opportunity opp
            WHERE opp.Pricebook2Id = :PRICEBOOK_ID_STANDARD
            AND AccountId != :CRMDPPBookProd2NameUtil.TEST_ACCOUNT_ID
            AND StageName IN :CRMDPPBookProd2NameUtil.OPP_TARGET_STAGENAME
        ]);
    }

    /**
     * 標準価格表IDと個店価格表IDの取得
     */
    private void getPricebook2Id() {
        for (Pricebook2 pBook2 : [
            SELECT id, name, IsStandard
            FROM Pricebook2 
            WHERE Name = :CRMDPPBookProd2NameUtil.CRMD_PBOOK_STD
            OR Name = :CRMDPPBookProd2NameUtil.CRMD_PBOOK_INDEVSALES]) {
            // 標準価格表ID取得
            if (Test.isRunningTest()) {
                PRICEBOOK_ID_STANDARD = Test.getStandardPricebookId();
            }
            else if (pBook2.IsStandard) {
                PRICEBOOK_ID_STANDARD = pBook2.Id;
            }
            // 個店価格表のID取得
            if (pBook2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_PBOOK_INDEVSALES)) {
                PRICEBOOK_ID_INDEVSALES = pBook2.Id;
            }
        }
    }

    /**
     * 価格表エントリと価格表IDのMap作成
     */
    private void setPBookEntryIdPBookIdMap() {
        List<PricebookEntry> pbeList = [SELECT Id, Pricebook2Id, Product2Id, Product2.Name FROM PricebookEntry WHERE Pricebook2Id != :PRICEBOOK_ID_INDEVSALES];
        Map<String, Id> product2CustPBEntryIdMap = new Map<String, Id>(); // サービス名とカスタム価格表に登録されているエントリIDのMap
        List<PricebookEntry> stdPBEntryList = new List<PricebookEntry>(); // 標準価格表に登録されているエントリ

        // 価格表エントリIDと価格表IDのMap作成
        for (PricebookEntry pbe : pbeList) {
            pBookEntryIdPriceBook2IdMap.put(pbe.Id, pbe.Pricebook2Id);
            pBookEntryIdProduct2IdMap.put(pbe.Id, pbe.Product2Id);
            // 標準価格表エントリとカスタム価格表エントリのリストをそれぞれ作成
            if (pbe.Pricebook2Id.equals(PRICEBOOK_ID_STANDARD)) {
                stdPBEntryList.add(pbe);
            }
            else {
                // サービス名は標準、個店価格表を除くとその他の価格表を横断しても一意になる
                product2CustPBEntryIdMap.put(pbe.Product2.Name, pbe.Id);
            }
            pBookEntryIdNameMap.put(pbe.Id, pbe.Product2.Name);
        }

        // Mapの初期化
        for (CRMDPPBookProd2NameUtil.REPLACE_TYPE replaceType : CRMDPPBookProd2NameUtil.REPLACE_TYPE.values()) {
            typeAndReplacePBookEntryIdMap.put(replaceType, new Map<Id, Id>());
        }

        // 旧価格表(=標準価格表)エントリIDと新価格表エントリID(置き換え後ID)のMap
        for (PricebookEntry pbeStd : stdPBEntryList) {
            // 特定のサービスの場合は移行先が2種に分かれるためそれぞれのキーワードと新旧IDをMapへ登録
            // - オフライン_PLC
            if (pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_OFF_PLC)) {
                // オフライン、自動機に分割
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_OFFLINE).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_PLC));
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_VENDING).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_OFFPLC));
            }
            // - オンライン_PLC
            else if (pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_ON_PLC)) {
                // オンライン、自動機に分割
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_ONLINE).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_PLC));
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_VENDING).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_ONPLC));
            }
            // - PayPayポイント
            else if (pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_POINT)) {
                // オフライン、オンラインに分割
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_OFFLINE).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_POINT));
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_ONLINE).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_POINT));
            }
            // - 【集約】個社キャンペーン（ジャンボ）
            else if (pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_CAMPAIGN_JAMBO)) {
                // オフライン、オンラインに分割
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_OFFLINE).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_CAMPAIGN_JAMBO));
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_ONLINE).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_CAMPAIGN_JAMBO));
            }
            // - 【集約】個社キャンペーン（総付け）
            else if (pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_CAMPAIGN_GRANT)) {
                // オフライン、オンラインに分割
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_OFFLINE).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_CAMPAIGN_GRANT));
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_ONLINE).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_CAMPAIGN_GRANT));
            }
            // - オンライン_モール/カート
            else if (pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_MALL_CART)) {
                // PSP、オンラインに分割
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_PSP).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP_CART));
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_ONLINE).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_MALL));
            }
            // 移行元サービス名が変更となるもの:移行タイプはNOMAL
            // - オフライン大手加盟店、オフライン中小加盟店、オフライン_SS切替＞オフライン
            else if (pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_OFF_ENPR_BIZ) ||
                pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_OFF_SMALL_BIZ) ||
                pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_ON_SS)) {
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_NOMAL).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE));
            }
            // - オンライン大手加盟店、オンライン中小加盟店＞オンライン
            else if (pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_ON_ENPR_BIZ) ||
                pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_ON_SMALL_BIZ)) {
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_NOMAL).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_ONLINE));
            }
            // - 日時指定クーポン＞【Offline】日時指定クーポン
            else if (pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_SCHEDULED)) {
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_NOMAL).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_SCHEDULED));
            }
            // - マイストア＞マイストア（大手営業管理）
            else if (pbeStd.Product2.Name.equals(CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_MYSTORE)) {
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_NOMAL).put(pbeStd.Id, product2CustPBEntryIdMap.get(CRMDPPBookProd2NameUtil.CRMD_PROD2_MYSTORE_ENPR));
            }
            // 他移行元と移行先のサービス名同じもの:移行タイプはNOMAL
            else if (product2CustPBEntryIdMap.containsKey(pbeStd.Product2.Name)) {
                typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_NOMAL).put(pbeStd.Id, product2CustPBEntryIdMap.get(pbeStd.Product2.Name));
            }
            // 移行先にサービス名が存在しない＝移行対象外の価格表エントリが紐づいている場合
            else {
                // 移行対象外価格表エントリセットに価格表エントリIDを追加
                dontReplacePBookEntryIdSet.add(pbeStd.Id);
            }
        }
    }

    /**
     * バッチ処理
     * @param BC 一括処理ジョブ
     * @param oppList 更新対象案件リスト
     * @todo 成功時のinfoログの出力
     */
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        bResult.totalRecordSize += oppList.size();

        List<Opportunity> targetOpportunitys = new List<Opportunity>(); // サービスが1件のみ紐づく案件→更新可能案件
        Set<String> notReplaceOppIds = new Set<String>(); // 価格表を移行しない案件
        Set<String> multiOrderOpportunityIds = new Set<String>(); // サービスが複数紐づく案件
        Set<String> noOrderOpportunitys = new Set<String>(); // サービスが紐づかない案件
        Set<String> lackOfInfoOpportunityIds = new Set<String>(); // 判定条件が欠如している案件
        Set<String> notFoundPriceBookIds = new Set<String>(); // 価格表IDが見つからなかった案件

        // 案件にカスタム価格表を紐づける
        // このトランザクション内のデータすべてチェックしてからエラーログを出す
        for (Opportunity opp : oppList) {
            // サービスが紐づいている
            if (opp.OpportunityLineItems.size() == 1) {
                // 移行しない価格表エントリが紐づいている場合
                if (dontReplacePBookEntryIdSet.contains(opp.OpportunityLineItems[0].PricebookEntry.Id)) {
                    notReplaceOppIds.add(opp.Id);
                }
                else {
                    try {
                        Id pbookEntryId = getReplacePriceBookEntryId(opp);
                        if (pBookEntryIdPriceBook2IdMap.containsKey(pbookEntryId)) {
                            opp.Pricebook2Id = pBookEntryIdPriceBook2IdMap.get(pbookEntryId);
                            opp.SummaryProduct2Name__c = pBookEntryIdNameMap.get(pbookEntryId);
                            targetOpportunitys.add(opp);
                        }
                        // 対応する価格表が見つからなかった場合
                        else {
                            notFoundPriceBookIds.add(opp.Id);
                        }
                    }
                    catch (Exception ex) {
                        // 案件の価格表付け替えのためのデータが欠如している場合
                        lackOfInfoOpportunityIds.add(opp.Id);
                        continue;
                    }
                }
            }
            // 案件にサービスが紐づいていない場合はエラーにはしないがログで検知したい
            else if (opp.OpportunityLineItems.size() == 0) {
                noOrderOpportunitys.add(opp.Id);
            }
            // 案件に複数サービスが紐づいている場合など
            else {
                multiOrderOpportunityIds.add(opp.Id);
            }
        }

        if (targetOpportunitys.isEmpty()) {
            String formatLogText = createLogText(oppList.size(), 0, notReplaceOppIds, lackOfInfoOpportunityIds, 
                noOrderOpportunitys, multiOrderOpportunityIds, notFoundPriceBookIds);

            Logger logger = new Logger();
            logger.info(BATCH_LOG_TITLE + COND_RELATECUSTOM_PRICEBOOK + ' 更新スキップ', formatLogText, false).saveAll();
            bResult.failured(oppList.size());
            return;
        }

        // 標準価格表null更新前までロールバックする
        Savepoint sp = Database.setSavepoint();

        // 価格表移行可能な案件から価格表を削除する(新しい価格表を紐づける際に一度null更新が必須)
        boolean isSuccess = updateOppPriceBookIdNull(sp, targetOpportunitys);
        if (!isSuccess) {
            // ロールバックはメソッド内で実施済
            this.hasException = true;
            bResult.failured(oppList.size());
            return;
        }

        // 案件の価格表ID、集約サービス更新
        isSuccess = updateOpportunityPriceBook(sp, oppList.size(), targetOpportunitys, 
            notReplaceOppIds, lackOfInfoOpportunityIds, noOrderOpportunitys, multiOrderOpportunityIds, notFoundPriceBookIds);
        if (!isSuccess) {
            // ロールバックはメソッド内で実施済
            this.hasException = true;
            bResult.failured(oppList.size());
            return;
        }

        // サービス情報作成
        List<OpportunityLineItem> insertOppLineItemList = createOpportunityLineItem(sp, targetOpportunitys);
        if (insertOppLineItemList == null) {
            // ロールバックはメソッド内で実施済
            this.hasException = true;
            bResult.failured(oppList.size());
            return;
        }
        
        // サービス情報をサービス管理へ紐づける
        isSuccess = correlateOpportunityLineItem(sp, targetOpportunitys, insertOppLineItemList);
        if (!isSuccess) {
            // ロールバックはメソッド内で実施済
            this.hasException = true;
            bResult.failured(oppList.size());
            return;
        }

        // 正常にサービス情報の作成までできたものをカウント
        bResult.successed(insertOppLineItemList.size());
        bResult.failured(oppList.size() - insertOppLineItemList.size());
    }

    /**
     * 案件から価格表を削除する
     * @param sp DBセーブポイント
     * @param oppList 更新対象案件
     * @return 成否
     * @details 新しい価格表を紐づける際に一度null更新が必須
     */
    private boolean updateOppPriceBookIdNull(Savepoint sp, List<Opportunity> oppList) {
        for (Opportunity opp : oppList) {
            opp.Pricebook2Id = null;
        }
        try {
            throwException(COND_DELETE_PRICEBOOK);
            update oppList;
        }
        catch (Exception ex) {
            Database.rollback(sp);

            Logger logger = new Logger();
            logger.error(BATCH_LOG_TITLE + COND_DELETE_PRICEBOOK, logger.formatErrorMessage(ex), false).saveAll();
            return false;
        }
        return true;
    }

    /**
     * 価格表更新
     * @param sp DBセーブポイント
     * @param batchListSize バッチ実行時のクエリで取得した案件数
     * @param tgtOpportunityList 更新する案件のリスト
     * @param notReplaceIds 価格表移行対象外の案件ID
     * @param lackOfInfoIds 更新に必要なデータがない案件のリスト
     * @param noOrderIds サービスが紐づけられていない案件ID
     * @param multiOrderIds 複数サービスの紐づく案件のリスト
     * @param notFouondIds 移行先の価格表がない案件のリスト
     * @return 成否
     */
    private boolean updateOpportunityPriceBook(Savepoint sp, Integer batchListSize, List<Opportunity> tgtOpportunityList,
        Set<String> notReplaceIds, Set<String> lackOfInfoIds, Set<String> noOrderIds, Set<String> multiOrderIds, Set<String> notFouondIds) {
        try {
            throwException(COND_RELATECUSTOM_PRICEBOOK);
            update tgtOpportunityList;

            String formatLogText = createLogText(batchListSize, tgtOpportunityList.size(),
                notReplaceIds, lackOfInfoIds, noOrderIds, multiOrderIds, notFouondIds);

            Logger logger = new Logger();
            logger.info(BATCH_LOG_TITLE + COND_RELATECUSTOM_PRICEBOOK, formatLogText).saveAll();
        }
        catch (Exception ex) {
            Database.rollback(sp);

            Logger logger = new Logger();
            logger.error(BATCH_LOG_TITLE + COND_RELATECUSTOM_PRICEBOOK, logger.formatErrorMessage(ex), false).saveAll();
            return false;
        }
        return true;
    }

    /**
     * サービス情報作成
     * @param sp DBセーブポイント
     * @param tgtOpportunityList 更新した案件のリスト
     * @return 成功時:作成したサービス情報のリスト
     *         エラー時:null
     */
    private List<OpportunityLineItem> createOpportunityLineItem(Savepoint sp, List<Opportunity> tgtOpportunityList) {
        List<OpportunityLineItem> newOppLineItemList= new List<OpportunityLineItem>();
        for (Opportunity opp : tgtOpportunityList) {
            // 案件に紐づく価格表エントリIDを取得する
            // 事前にエラーのある案件を選別済なので、ここでエラーは発生しない
            Id oppNewPBEntryId = getReplacePriceBookEntryId(opp);

            // 新規価格表に紐づくサービス情報を作成する
            OpportunityLineItem oppLineItem = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = pBookEntryIdProduct2IdMap.get(oppNewPBEntryId),
                PricebookEntryId = oppNewPBEntryId
            );
            newOppLineItemList.add(oppLineItem);
        }

        try {
            throwException(COND_INSERT_OPPLINEITEMLIST);
            insert newOppLineItemList;

            Logger logger = new Logger();
            logger.info(BATCH_LOG_TITLE + COND_INSERT_OPPLINEITEMLIST, '更新実行 サービス紐づけ直し案件レコード件数: ' + newOppLineItemList.size() + '件').saveAll();
        }
        catch (Exception ex) {
            Database.rollback(sp);

            Logger logger = new Logger();
            logger.error(BATCH_LOG_TITLE + COND_INSERT_OPPLINEITEMLIST, logger.formatErrorMessage(ex), false).saveAll();
            return null;
        }
        return newOppLineItemList;
    }

    /**
     * サービス管理（決済事業）へサービス情報を紐づける
     * @param sp DBセーブポイント
     * @param tgtOpportunityList 更新した案件のリスト
     * @param oppLineItemList 作成したサービス情報のリスト
     * @return 成否
     */
    private boolean correlateOpportunityLineItem(Savepoint sp, List<Opportunity> tgtOpportunityList, List<OpportunityLineItem> oppLineItemList) {
        Map<Id, Id> tgtOppIdOrderProgressIdMap = new Map<Id, Id>();
        // 案件とサービス管理（決済事業）の1:1Map作成
        for (OrderProgress__c oderProgress : [SELECT Id, OpportunityId__c FROM OrderProgress__c WHERE OpportunityId__c IN :tgtOpportunityList]) {
            tgtOppIdOrderProgressIdMap.put(oderProgress.OpportunityId__c, oderProgress.Id);
        }

        List<OrderProgress__c> updateOderProgressList = new List<OrderProgress__c>();
        for (OpportunityLineItem lineItem : oppLineItemList) {
            if (tgtOppIdOrderProgressIdMap.containsKey(lineItem.OpportunityId)) {
                updateOderProgressList.add(new OrderProgress__c(Id = tgtOppIdOrderProgressIdMap.get(lineItem.OpportunityId), OpportunityLineItemId__c = lineItem.Id));
            }
        }

        try {
            throwException(COND_UPDATE_ORDERPROGRESS);
            update updateOderProgressList;

            Logger logger = new Logger();
            String logText = 'サービス情報数 ' + oppLineItemList.size() + '件\n';
            logText = 'サービス情報連携(決済事業) ' + updateOderProgressList.size() + '件';
            logger.info(BATCH_LOG_TITLE + COND_UPDATE_ORDERPROGRESS, logText).saveAll();
        }
        catch (Exception ex) {
            Database.rollback(sp);

            Logger logger = new Logger();
            logger.error(BATCH_LOG_TITLE + COND_UPDATE_ORDERPROGRESS, logger.formatErrorMessage(ex), false).saveAll();
            return false;
        }
        return true;
    }

    /**
     * 使用する価格表エントリIDを取得する
     * @param opp 更新対象案件
     * @return 更新先価格表エントリID
     * @details 参照項目がnull、空白の場合はExceptionを発生させる。呼び出し元で検知する
     */
    private Id getReplacePriceBookEntryId(Opportunity opp) {
        // 価格表エントリが複数に分岐する場合
        if (CRMDPPBookProd2NameUtil.CRMD_MULTI_MIG_SERVICE.contains(opp.OpportunityLineItems[0].PricebookEntry.Name)) {

            // オフライン_PLCの場合
            if (CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_OFF_PLC.equals(opp.OpportunityLineItems[0].PricebookEntry.Name)) {
                if (opp.OrderProgress_OpportunityId__r.size() == 0 || String.isBlank(opp.OrderProgress_OpportunityId__r[0].NewIndustryclass__c)) {
                    throw new MyException('[ID:' + opp.Id +']' + opp.Name + 'に紐づくサービス管理(決済事業)「業種（中項目）」項目に値が設定されていません');
                }
                // サービス管理「業種（中項目）」が自動機の場合＞自動機
                if (opp.OrderProgress_OpportunityId__r[0].NewIndustryclass__c.equals(CRMDPPBookProd2NameUtil.CRMD_INDUSTRY_TYPE_VENDING)) {
                    return typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_VENDING).get(opp.OpportunityLineItems[0].PricebookEntry.Id);
                }
                // それ以外＞オフライン
                else {
                    return typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_OFFLINE).get(opp.OpportunityLineItems[0].PricebookEntry.Id);
                }
            }
            // オンライン_PLCの場合
            else if (CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_ON_PLC.equals(opp.OpportunityLineItems[0].PricebookEntry.Name)) {
                if (opp.OrderProgress_OpportunityId__r.size() == 0 || String.isBlank(opp.OrderProgress_OpportunityId__r[0].NewIndustryclass__c)) {
                    throw new MyException('[ID:' + opp.Id +']' + opp.Name + 'に紐づくサービス管理(決済事業)「業種（中項目）」項目に値が設定されていません');
                }
                // サービス管理「業種（中項目）」が自動機の場合＞自動機
                if (opp.OrderProgress_OpportunityId__r[0].NewIndustryclass__c.equals(CRMDPPBookProd2NameUtil.CRMD_INDUSTRY_TYPE_VENDING)) {
                    return typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_VENDING).get(opp.OpportunityLineItems[0].PricebookEntry.Id);
                }
                // それ以外＞オンライン
                else {
                    return typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_ONLINE).get(opp.OpportunityLineItems[0].PricebookEntry.Id);
                }
            }
            // PayPayポイント
            // 【集約】個社キャンペーン（ジャンボ）
            // 【集約】個社キャンペーン（総付け）の場合
            else if (CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_POINT.equals(opp.OpportunityLineItems[0].PricebookEntry.Name) ||
                CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_CAMPAIGN_JAMBO.equals(opp.OpportunityLineItems[0].PricebookEntry.Name) ||
                CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_CAMPAIGN_GRANT.equals(opp.OpportunityLineItems[0].PricebookEntry.Name)) {
                if (opp.OrderProgress_OpportunityId__r.size() == 0 || String.isBlank(opp.OrderProgress_OpportunityId__r[0].OnOff__c)) {
                    throw new MyException('[ID:' + opp.Id +']' + opp.Name + 'に紐づくサービス管理(決済事業)「オン/オフ」項目に値が設定されていません');
                }
                // サービス管理「オン/オフ」がオンの場合＞オンライン
                if (opp.OrderProgress_OpportunityId__r[0].OnOff__c.equals(CRMDPPBookProd2NameUtil.CRMD_SERVICE_TYPE_ON)) {
                    return typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_ONLINE).get(opp.OpportunityLineItems[0].PricebookEntry.Id);
                }
                // サービス管理「オン/オフ」がオフの場合＞オフライン
                else if (opp.OrderProgress_OpportunityId__r[0].OnOff__c.equals(CRMDPPBookProd2NameUtil.CRMD_SERVICE_TYPE_OFF)) {
                    return typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_OFFLINE).get(opp.OpportunityLineItems[0].PricebookEntry.Id);
                }
            }
            // オンライン_モール/カートの場合
            else if (CRMDPPBookProd2NameUtil.CRMD_OLD_PROD2_MALL_CART.equals(opp.OpportunityLineItems[0].PricebookEntry.Name)) {
                if (opp.OrderProgress_OpportunityId__r.size() == 0 || String.isBlank(opp.OrderProgress_OpportunityId__r[0].NewIndustryclass__c)) {
                    throw new MyException('[ID:' + opp.Id +']' + opp.Name + 'に紐づくサービス管理(決済事業)「業種（中項目）」項目に値が設定されていません');
                }
                // サービス管理「業種（中項目）」がカートの場合＞PSP
                if (opp.OrderProgress_OpportunityId__r[0].NewIndustryclass__c.equals(CRMDPPBookProd2NameUtil.CRMD_INDUSTRY_TYPE_CART)) {
                    return typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_PSP).get(opp.OpportunityLineItems[0].PricebookEntry.Id);
                }
                // それ以外の場合＞オンライン
                else {
                    return typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_ONLINE).get(opp.OpportunityLineItems[0].PricebookEntry.Id);
                }
            }
            else {
                throw new MyException('[ID:' + opp.Id +']' + opp.Name + 'の移行先価格表エントリが見つかりませんでした');
            }
        }
        // 旧価格表エントリの情報から対応する新価格表エントリ情報が判定可能な場合
        return typeAndReplacePBookEntryIdMap.get(CRMDPPBookProd2NameUtil.REPLACE_TYPE.IS_NOMAL).get(opp.OpportunityLineItems[0].PricebookEntry.Id);
    }

    /**
     * ログ本文作成処理
     * @param batchListSize バッチ実行時のクエリで取得した案件数
     * @param tgtOpportunityList 更新する案件のレコード数
     * @param notReplaceIds 価格表移行対象外の案件ID
     * @param lackOfInfoIds 更新に必要なデータがない案件のリスト
     * @param noOrderIds サービスが紐づけられていない案件ID
     * @param multiOrderIds 複数サービスの紐づく案件のリスト
     * @param notFouondIds 移行先の価格表がない案件のリスト
     * @return バッチログ本文用テキスト
     */
    private String createLogText(Integer batchListSize, Integer tgtOpportunityListSize, Set<String> notReplaceIds, 
        Set<String> lackOfInfoIds, Set<String> noOrderIds, Set<String> multiOrderIds, Set<String> notFouondIds) {

        List<String> logInfoText = new List<String>();
        logInfoText.add('更新案件総数: ' + batchListSize + '件\n');
        logInfoText.add('更新実施 案件件数: ' + tgtOpportunityListSize + '件\n\n');
        logInfoText.add('価格表を移行しない案件件数: ' + notReplaceIds.size() + '件\n');
        logInfoText.add('＞案件ID: ' + String.join(notReplaceIds, ', ') + '\n\n');
        logInfoText.add('更新するためのデータが欠如している案件件数: ' + lackOfInfoIds.size() + '件\n');
        logInfoText.add('＞案件ID: ' + String.join(lackOfInfoIds, ', ') + '\n\n');
        logInfoText.add('サービスの紐づかない案件件数: ' + noOrderIds.size() + '件\n');
        logInfoText.add('＞案件ID: ' + String.join(noOrderIds, ', ') + '\n\n');
        logInfoText.add('その他条件で更新できなかった案件件数: ' + multiOrderIds.size() + '件\n');
        logInfoText.add('＞案件ID: ' + String.join(multiOrderIds, ', ') + '\n\n');
        logInfoText.add('価格表IDが見つからなかった案件件数: ' + notFouondIds.size() + '件\n');
        logInfoText.add('＞案件ID: ' + String.join(notFouondIds, ', '));

        // 各エラーの集計
        notReplaceNum += notReplaceIds.size();
        multiOrderNum += multiOrderIds.size();
        noOrderNum += noOrderIds.size();
        lackOfInfoNum += lackOfInfoIds.size();
        notFoundPbNum += notFouondIds.size();

        String formatLogText = String.format('{0}{1}{2}{3}{4}{5}{6}{7}{8}{9}{10}{11}', logInfoText);
        return formatLogText;
    }

    /**
     * テストカバー率向上のため、テスト時のみ例外を発生させる
     * errorExpectedに文言をセットして使用
     * @param errorLocation エラー発生場所
     */
    private void throwException(String errorLocation) {
        if (errorExpected.equals(errorLocation) && Test.isRunningTest() && isDMLExceptionTest) {
            throw new MyException(errorExpected + ':テスト実行時エラー');
        }
    }

    /**
     * バッチ終了
     * @param BC 一括処理ジョブ
     */
    public void finish(Database.BatchableContext BC) {
        List<String> logInfoText = new List<String>();
        logInfoText.add('\n============================================\n');
        logInfoText.add('価格表移行しない総数:' + notReplaceNum + '\n');
        logInfoText.add('サービスが複数紐づく総数:' + multiOrderNum + '\n');
        logInfoText.add('サービスが紐づかない総数:' + noOrderNum + '\n');
        logInfoText.add('情報が不足している件数:' + lackOfInfoNum + '\n');
        logInfoText.add('移行先価格表が判定できなかった件数:' + notFoundPbNum);
        String formatLogText = String.format('{0}{1}{2}{3}{4}{5}', logInfoText);

        Logger logger = new Logger();
        if (this.hasException || bResult.hasError) {
            logger.error(BATCH_LOG_TITLE + ' 完了', bResult.toString() + formatLogText, false).saveAll();
        }
        else {
            logger.info(BATCH_LOG_TITLE+ ' 完了', bResult.toString() + formatLogText, false).saveAll();
        }
    }
}