/**
* クラス名: CRMDPConvertOpportunityRTBatch
* クラス概要: サービス管理オブジェクト分割 案件レコードタイプ変更バッチ
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/10/31
* Updated Date: -
------------------------------------------------------------------------------------------------------
* 案件に紐づいているサービス管理のRTに応じて、案件RTを変更する
* 開発者コンソールから以下のコマンドを実行する
* CRMDPConvertOpportunityRTBatch.run();
* - 前提条件
* 新しい案件レコードタイプが組織に追加されていること
* - サービス名
* 次の設計書をもとに実装
* https://docs.google.com/spreadsheets/d/1LGjfVBfMG2STi9OgTlmTojowsmC4BsFf/edit#gid=167590816&fvid=1042614316
*/
global class CRMDPConvertOpportunityRTBatch implements Database.Batchable<sObject>, Database.Stateful {
    // DMLException test のためのフラグ
    @testVisible
    private static Boolean isDMLExceptionTest = false;

    // 案件レコードタイプ
    Id RECORDTYPE_ENPOFF; // エンプラ_オフライン
    Id RECORDTYPE_ENPON; // エンプラ_オンライン
    Id RECORDTYPE_ENPVENDING; // エンプラ_自動機
    Id RECORDTYPE_ENPMAKER; // エンプラ_メーカー
    Id RECORDTYPE_ENPPOINTOPERATOR; // エンプラ_ポイント事業者
    Id RECORDTYPE_ENPGW; // エンプラ_GW
    Id RECORDTYPE_ENPPSP; // エンプラ_PSP
    Id RECORDTYPE_ENPMYSTORE; // エンプラ_マイストア
    Id RECORDTYPE_INVISIBLE; // エンプラ_非表示
    Id RECORDTYPE_OLD_EMPR; // 案件レコードタイプ(エンプラ営業)

    // サービス名と割り当てる案件レコードタイプのMap
    Map<String, Id> productNameOppRTIdMap = new Map<String, Id>{};

    // ログ保存時のタイトル
    @testVisible
    private static final String BATCH_LOG_TITLE = '【CRM高度化】案件レコードタイプ変更バッチ';

    // バッチ結果格納
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;
    
    /**
     * コンストラクタ
     */
    public CRMDPConvertOpportunityRTBatch() {
        // 案件のレコードタイプID取得
        RECORDTYPE_ENPOFF = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_OFFLINE);
        RECORDTYPE_ENPON = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_ONLINE);
        RECORDTYPE_ENPVENDING = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_VENDING);
        RECORDTYPE_ENPMAKER = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MAKER);
        RECORDTYPE_ENPPOINTOPERATOR = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_POINTOPERATOR);
        RECORDTYPE_ENPGW = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_GW);
        RECORDTYPE_ENPPSP = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_PSP);
        RECORDTYPE_ENPMYSTORE = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_MYSTORE);
        RECORDTYPE_INVISIBLE = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, Constant.OPP_DEVELOPER_NAME_ENTERPRISE_INVISIBLE);
        RECORDTYPE_OLD_EMPR = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, Constant.OPP_DEVELOPER_NAME_ENTERPRISE);

        // サービス - 案件レコードタイプIDのマッピング。他にマッピングされている場所がないためべた書き
        // 案件:エンプラ_オフライン に紐づけるサービス
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFFLINE, RECORDTYPE_ENPOFF);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_PLC, RECORDTYPE_ENPOFF);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_PAAS, RECORDTYPE_ENPOFF);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_ROUTE, RECORDTYPE_ENPOFF);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_POINT, RECORDTYPE_ENPOFF);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_FLYER, RECORDTYPE_ENPOFF);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_CAMPAIGN_GRANT, RECORDTYPE_ENPOFF);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_CAMPAIGN_JAMBO, RECORDTYPE_ENPOFF);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_REVISIT, RECORDTYPE_ENPOFF);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_SCHEDULED, RECORDTYPE_ENPOFF);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_OFF_STAMP, RECORDTYPE_ENPOFF);
        // 案件:エンプラ_オンライン に紐づけるサービス
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_ONLINE, RECORDTYPE_ENPON);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_PLC, RECORDTYPE_ENPON);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_MINI, RECORDTYPE_ENPON);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_POINT, RECORDTYPE_ENPON);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_CAMPAIGN_GRANT, RECORDTYPE_ENPON);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_CAMPAIGN_JAMBO, RECORDTYPE_ENPON);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_REVISIT, RECORDTYPE_ENPON);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_SCHEDULED, RECORDTYPE_ENPON);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_STAMP, RECORDTYPE_ENPON);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_ON_MALL, RECORDTYPE_ENPON);
        // 案件:エンプラ_自動機 に紐づけるサービス
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING, RECORDTYPE_ENPVENDING);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_OFFPLC, RECORDTYPE_ENPVENDING);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_ONPLC, RECORDTYPE_ENPVENDING);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_REVISIT, RECORDTYPE_ENPVENDING);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_VENDING_SCHEDULED, RECORDTYPE_ENPVENDING);
        // 案件:エンプラ_メーカー に紐づけるサービス
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_MAKER_SKU, RECORDTYPE_ENPMAKER);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_MAKER_RETAIL, RECORDTYPE_ENPMAKER);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_MAKER_LYP, RECORDTYPE_ENPMAKER);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_MAKER_GIFT, RECORDTYPE_ENPMAKER);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_MAKER_LINE, RECORDTYPE_ENPMAKER);
        // 案件:エンプラ_ポイント事業者 に紐づけるサービス
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_BALANCE_API, RECORDTYPE_ENPPOINTOPERATOR);
        // 案件:GW担当 に紐づけるサービス
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_GW, RECORDTYPE_ENPGW);
        // 案件:エンプラ_PSP に紐づけるサービス
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP, RECORDTYPE_ENPPSP);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP_CART, RECORDTYPE_ENPPSP);
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_PSP_SMB, RECORDTYPE_ENPPSP);
        // 案件:エンプラ_マイストア に紐づけるサービス
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_MYSTORE_ENPR, RECORDTYPE_ENPMYSTORE);
        // 案件:エンプラ_非表示 に紐づけるサービス
        productNameOppRTIdMap.put(CRMDPPBookProd2NameUtil.CRMD_PROD2_MANAGED_ENPR, RECORDTYPE_INVISIBLE);
    }

    /**
     * バッチ呼び出し
     */
    global static void run() {
        // バッチサイズ200仮置き
        Database.executeBatch(new CRMDPConvertOpportunityRTBatch(), 200);
    }

    /**
     * バッチ開始
     * @param BC 一括処理ジョブ
     * @detail 標準価格表の紐づいている案件は処理対象外
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT opp.Id, (
                SELECT oppLineItems.Id, oppLineItems.PricebookEntry.Product2.Name
                FROM OpportunityLineItems oppLineItems)
            FROM Opportunity opp
            WHERE opp.RecordTypeId = :RECORDTYPE_OLD_EMPR
            AND Pricebook2.IsStandard != true
            AND Pricebook2Id != null
        ]);
    }

    /**
     * バッチ処理
     * @param BC 一括処理ジョブ
     * @param oppList 更新対象案件リスト
     */
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        bResult.totalRecordSize += oppList.size();

        Set<String> errorOpportunityIds = new Set<String>();
        List<Opportunity> updateOpportunityList = new List<Opportunity>();

        // サービスに基づいて案件RTを設定
        for (Opportunity opp : oppList) {
            boolean errorCheckFlg = true;

            if (opp.OpportunityLineItems.size() == 1) {
                String product2Name = opp.OpportunityLineItems[0].PricebookEntry.Product2.Name;
                if (productNameOppRTIdMap.containsKey(product2Name)) {
                    opp.RecordTypeId = productNameOppRTIdMap.get(product2Name);
                    updateOpportunityList.add(opp);
                    errorCheckFlg = false; // レコードタイプ変更できた場合エラーフラグを落とす
                }
            }

            // 案件にサービスが紐づいていない場合、複数紐づいている場合、その他
            if (errorCheckFlg) {
                errorOpportunityIds.add(opp.Id);
            }
        }

        try {
            if (Test.isRunningTest() && isDMLExceptionTest) {
                throw new DmlException();
            }
            update updateOpportunityList;

            List<String> logInfoText = new List<String>();
            logInfoText.add('更新案件総数: ' + oppList.size() + '件\n');
            logInfoText.add('更新実行 案件件数: ' + updateOpportunityList.size() + '件\n\n');
            logInfoText.add('サービスがない、複数、または移行先が見つからない案件件数: ' + errorOpportunityIds.size() + '件\n');
            logInfoText.add('＞案件ID: ' + String.join(errorOpportunityIds, ', '));
            String formatLogText = String.format('{0}{1}{2}{3}', logInfoText);

            String logTitle = '';
            if (errorOpportunityIds.size() > 0) { // エラーではないが更新できない案件があった場合
                logTitle = logTitle = BATCH_LOG_TITLE + '(例外あり)';
            }
            else {
                logTitle = BATCH_LOG_TITLE;
            }

            Logger logger = new Logger();
            logger.info(logTitle, formatLogText).saveAll();

            bResult.successed(updateOpportunityList.size()); // 更新成功
            bResult.failured(errorOpportunityIds.size()); // エラーのある案件
        }
        catch (Exception ex) {
            Logger logger = new Logger();
            logger.error(BATCH_LOG_TITLE, logger.formatErrorMessage(ex), false).saveAll();

            this.hasException = true;
            bResult.failured(oppList.size());
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
            logger.info(BATCH_LOG_TITLE+ '(完了)', bResult.toString(), false).saveAll();
        }
    }
}