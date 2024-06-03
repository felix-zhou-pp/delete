/**
* クラス名：CRMDPInsertEPAccountTeamMemberBatch
* クラス概要：エンプラ取引先チーム（企業分割非対称）・作成バッチ
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/10/26
* Updated Date: -
------------------------------------------------------------------------------------------------------
*/
global class CRMDPInsertEPAccountTeamMemberBatch implements Database.Batchable<sObject>, Database.Stateful {

    @testVisible
    private static final String BATCH_LOG_TITLE = '【CRM高度化】エンプラ取引先チーム 作成バッチ';
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;
    @testVisible
    private static Boolean isInsertEPAtmExceptionTest = false;

    //　カート
    public static final String CART_TEXT = 'カート';

    /**
     * バッチ呼び出し
     */
    global static void run() {
        // バッチサイズ200仮置き
        Database.executeBatch(new CRMDPInsertEPAccountTeamMemberBatch(), 200);
    }

    /**
     * バッチ開始
     * @param BC 一括処理ジョブ
     * @details 個店以外の案件が紐ついている取引チーム未作成の取引先に取引先チームを作成する
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('===== start CRMDPInsertEPAccountTeamMemberBatch =====');
        return Database.getQueryLocator([
            SELECT Id, MakerPerson__c, MakerPerson__r.IsActive, (SELECT Id, StageName, RecordTypeId, OwnerId, Owner.IsActive FROM Opportunities WHERE StageName NOT IN ('90', '95', '取下げ'))
            FROM Account
            WHERE ParentId = NULL
            AND Id IN (SELECT AccountId FROM Opportunity WHERE RecordTypeId != :AccountTeamMemberUtil.OPP_RTID_INDEV AND StageName NOT IN ('90', '95', '取下げ'))
            AND Id NOT IN (SELECT AccountId FROM AccountTeamMember)
        ]);
    }

    /**
     * バッチ処理
     * @param BC 一括処理ジョブメソッドパラメータ
     * @param accountList 取引先リスト
     */
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        System.debug('===== execute CRMDPInsertEPAccountTeamMemberBatch =====');
        System.debug(BATCH_LOG_TITLE + ' :対象 取引先数:' + accountList.size());

        // Insert用_取引先チームメンバーリスト
        List<AccountTeamMember> insertAtmList = new List<AccountTeamMember>();
        // 同一取引先内担当確認用Map
        Map<Id, AccountTeamMember> inChargeUserMap = new Map<Id, AccountTeamMember>();
        // 抽出してきた対象取引先Idのリスト
        Set<String> targetAccIdList = new Set<String>();
        // errorレコードIDのリスト
        Set<String> errorRecIds = new Set<String>();
        // 案件_所有者無効リスト
        List<String> inActiveOpp = new List<String>();
        // メーカー担当者無効取引先Idリスト
        List<String> inActiveMakerP = new List<String>();
        // オンラインPSP担当案件リスト
        List<Id> onlinePSPList = new List<Id>();
        
        // 成功・失敗件数カウント用
        Integer successCnt = 0;
        Integer errorCnt = 0;

        // 案件とサービス管理(決済事業）レコードタイプAPI名のMap作成
        Map<Id, String> opRecTypeMap = new Map<Id, String>();
        for (OrderProgress__c record : [SELECT OpportunityId__c, RecordType.developerName, NewIndustryclass__c FROM OrderProgress__c WHERE OpportunityId__r.AccountId IN :accountList]) {
            opRecTypeMap.put(record.OpportunityId__c, record.RecordType.developerName);
            // サービス管理のレコードタイプAPI名が”オンライン_モールカート”で業種（中項目）が”カート”のもの
            if (Constant.ORDP_DEVELOPER_NAME_ENPMALL_ONLINE.equals(record.RecordType.developerName) && CART_TEXT.equals(record.NewIndustryclass__c)) {
                // オンラインPSP担当案件リストに追加
                onlinePSPList.add(record.OpportunityId__c);
            }
        }
        // 取引先のレコード分処理を回す
        for (Account acc : accountList) {
            // 取引先Idをリストに詰める
            targetAccIdList.add(acc.Id);
            // Mapの初期化
            inChargeUserMap.clear();

            // 取引先に紐つく案件分処理を回す
            for (Opportunity opp: acc.Opportunities) {

                // 担当判定用レコードタイプId
                String inChargeRecTypeName = opRecTypeMap.get(opp.Id);

                // 担当判定用レコードタイプIdより「担当」を判定
                String inCharge = ConvertOpRtToCharge.get(inChargeRecTypeName);

                // オンラインPSP案件の場合は担当をオンラインPSPに変更
                if (onlinePSPList.contains(opp.Id)) {
                    inCharge = AccountTeamMemberUtil.PRODUCT_IN_CHARGE_PSP;
                }

                // 割り当てる担当がない場合は処理をスキップ
                if (String.isBlank(inCharge)) {
                    continue;
                }
                // 割り当てる担当がある場合
                else {
                    AccountTeamMember atm = new AccountTeamMember();
                    // チームメンバーのユーザId
                    Id userId = null;

                    // メーカーレコードタイプで「メーカー担当者」が設定されている場合
                    // 取引先の「メーカー担当者」をユーザIdにする
                    if (AccountTeamMemberUtil.PRODUCT_IN_CHARGE_MAKER.equals(inCharge) && acc.MakerPerson__c != null) {
                        userId = acc.MakerPerson__c;

                        // メーカー担当者が無効の場合リストに追加
                        if (!acc.MakerPerson__r.IsActive && !inActiveMakerP.contains(acc.Id)) {
                            inActiveMakerP.add(acc.Id);
                        }
                    }
                    // メーカー担当者ではない or メーカー担当者が設定されていない場合
                    // 案件の所有者をユーザIdにする
                    else {
                        userId = opp.OwnerId;

                        // 所有者が無効の場合リストに追加
                        if (!opp.Owner.IsActive && !inActiveOpp.contains(acc.Id)) {
                            inActiveOpp.add(acc.Id);
                        }
                    }

                    // ユーザー重複チェック
                    // 同一ユーザが複数担当の場合
                    if (inChargeUserMap.containsKey(userId)) {
                        atm = inChargeUserMap.get(userId);
                        if (atm.ProductInCharge__c.contains(inCharge)) {
                            continue;
                        }
                        // 担当を複数選択形式に変更する
                        inCharge = atm.ProductInCharge__c + Constant.SEMICOLON + inCharge;
                    }
                    // 同一ユーザがいない場合
                    else {
                        atm.userId = userId;
                        atm.AccountId = acc.Id;
                        atm.TeamMemberRole = AccountTeamMemberUtil.TEAMMEMBERROLE_ENP;
                        atm.AssignStatus__c = 'アサイン確定';
                    }
                    atm.ProductInCharge__c = inCharge;

                    inChargeUserMap.put(userId, atm);
                }
            }
            List<AccountTeamMember> atmlist = new List<AccountTeamMember>(inChargeUserMap.values());
            // Insert用取引先チームメンバーリストに追加
            insertAtmList.addAll(atmlist);
        }
        try {
            System.debug('===== execute insertAtmList.size:' + insertAtmList.size()  +'=====');
            // 取引先チーム件数
            bResult.totalRecordSize += insertAtmList.size();
            Logger logger = new Logger();

            // Exception発生のテストケースにて使用
            if (Test.isRunningTest() && isInsertEPAtmExceptionTest) {
                throw new DmlException();
            }
            // 取引先チームの作成
            List<Database.SaveResult> rList = database.insert(insertAtmList, false);

            // エラーメッセージ_取引先Idがわかるもの
            Map<String, List<String>> errMsgIdMap = new Map<String, List<String>>();
            // エラーメッセージ_取引先Idがわからないもの
            Map<String, Integer> errMsgCntMap = new Map<String, Integer>();

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
                    List<Database.Error> errList = result.getErrors(); 
                    String fullErrMsg = errList[0].getMessage();
                    if (fullErrMsg.contains(Constant.COLON)) {
                        String errMsg = fullErrMsg.substringBefore(Constant.COLON);
                        String errId = fullErrMsg.substringAfter(Constant.COLON);

                        // 検出済みエラーの場合：取引先Idを追加
                        if (errMsgIdMap.keySet().contains(errMsg)) {
                            if (!errMsgIdMap.get(errMsg).contains(errId)) {
                                // エラーMapに既に追加されているIdリストを取得
                                List<String> errIdList = errMsgIdMap.get(errMsg);
                                // エラーIdリストに追加
                                errIdList.add(errId);
                                // エラーMapに追加
                                errMsgIdMap.put(errMsg, errIdList);
                            }
                        }
                        // 新規エラーの場合：取引先Idを設定
                        else {
                            errMsgIdMap.put(errMsg, new List<String>{errId});
                        }
                    } else {
                        // 検出済みエラーの場合：カウントアップ
                        if (errMsgCntMap.keySet().contains(fullErrMsg)) {
                            // エラーMapに追加
                            errMsgCntMap.put(fullErrMsg, errMsgCntMap.get(fullErrMsg) + 1);
                        }
                        // 新規エラーの場合：1件
                        else {
                            errMsgCntMap.put(fullErrMsg, 1);
                        }
                    }
                }
            }
            
            // ログメッセージの準備
            List<String> logInfoText = new List<String>();
            logInfoText.add('バッチ名: CRMDPInsertEPAccountTeamMemberBatch\n');
            logInfoText.add('作成対象 取引先件数: ' + accountList.size() + '件\n');
            logInfoText.add('作成対象 取引先チーム件数: ' + insertAtmList.size() + '件\n');
            logInfoText.add('成功 取引先チーム件数: ' + successCnt + '件\n');
            logInfoText.add('失敗 取引先チーム件数: ' + errorCnt + '件\n');
            
            // ログフォーマット
            String formatTemp = '{0}{1}{2}{3}{4}';
            Integer firstFormatSize = 4;
            Integer formatSize = firstFormatSize;
            String formatLogText = '';

            // 全件投入成功
            if (errorCnt == 0) {
                formatLogText = String.format(formatTemp, logInfoText);
                logger.info(BATCH_LOG_TITLE, formatLogText).saveAll();
            }
            // エラーがあった場合
            else {
                // 失敗件数のログメッセージ
                // エンプラ取引先チーム
                List<AggregateResult> doneAtmList = [SELECT AccountId FROM AccountTeamMember WHERE AccountId IN :targetAccIdList GROUP BY AccountId];
                Integer errAccCnt = accountList.size() - doneAtmList.size();

                logInfoText.add('失敗 取引先件数: ' + errAccCnt + '件\n\n');
                 // ログフォーマットサイズを拡張
                 formatSize = formatSize + 1;

                // エラー情報の出力_取引先Idがわからるもの
                for (String errmsg : errMsgIdMap.keySet()) {
                    logInfoText.add('エラーメッセージ: ' + errmsg + '\n');
                    if (errMsgIdMap.get(errmsg).size() > 0) {
                        // エラー取引先Idをテキストで追加
                        String errAccRecId = String.join(errMsgIdMap.get(errmsg), Constant.COMMA + Constant.HALF_WIDTH_SP); 
                        logInfoText.add('失敗 取引先Id: ' + errAccRecId + '\n');

                         // ログフォーマットサイズを拡張
                        formatSize = formatSize + 1;
                    }
                    logInfoText.add('\n');

                    // ログフォーマットサイズを拡張
                    formatSize = formatSize + 2;
                }

                // エラー情報の出力
                for (String errmsg : errMsgCntMap.keySet()) {
                    logInfoText.add('エラーメッセージ: ' + errmsg + '\n');

                    // エラー件数をテキストで追加
                    logInfoText.add('無効エラー件数: ' + errMsgCntMap.get(errmsg) + '\n\n');

                    // ログフォーマットサイズを拡張
                    formatSize = formatSize + 2;
                }

                // メーカー担当者無効の取引先Id
                if (inActiveMakerP.size() > 0) {
                    String inActiveMakerPId = String.join(inActiveMakerP, Constant.COMMA + Constant.HALF_WIDTH_SP); 
                    logInfoText.add('メーカー担当者が無効の取引先Id: ' + inActiveMakerPId + '\n\n');
                    formatSize = formatSize + 1;
                }
                // 所有者が無効の取引先Id
                if (inActiveOpp.size() > 0) {
                    String inActiveOppAccId = String.join(inActiveOpp, Constant.COMMA + Constant.HALF_WIDTH_SP); 
                    logInfoText.add('案件所有者が無効の取引先Id: ' + inActiveOppAccId + '\n');
                    formatSize = formatSize + 1;
                }

                // ログフォーマットを拡張
                Integer plusSize = formatSize - firstFormatSize;
                for (Integer i = 1 ; i <= plusSize; i++) {
                    formatTemp = formatTemp + '{' + (firstFormatSize + i) +'}';
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
            bResult.failured(insertAtmList.size());
        }
    }

    /**
     * バッチ終了
     * @param BC 一括処理ジョブメソッドパラメータ
     */
    global void finish(Database.BatchableContext BC){
        System.debug('===== finish CRMDPInsertEPAccountTeamMemberBatch =====');
        System.debug(BATCH_LOG_TITLE + ' 処理対象取引先チーム総合計：' + bResult.totalRecordSize);
        System.debug(BATCH_LOG_TITLE + ' 処理成功取引先チーム総合計：' + bResult.successedRecordSize);
        
        Logger logger = new Logger();
        if (this.hasException || bResult.hasError) {
            logger.error(BATCH_LOG_TITLE + '(完了)', '以下バッチ実行総数：\n' + bResult.toString(), false).saveAll();
        } else {
            logger.info(BATCH_LOG_TITLE + '(完了)', '以下バッチ実行総数：\n' + bResult.toString(), false).saveAll();
        }
    }

     // サービス管理（決済事業）レコードタイプAPI名と担当のマッピング
     public static final Map<String, String> ConvertOpRtToCharge = new Map<String, String>{
        // オフライン
        Constant.ORDP_DEVELOPER_NAME_PAY_ENTERPRISE => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_OFF,
        // オンライン
        Constant.ORDP_DEVELOPER_NAME_ENP_ONLINE => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_ON,
        // オンライン（オンラインモールカートは一旦オンラインで仮設定する）
        Constant.ORDP_DEVELOPER_NAME_ENPMALL_ONLINE => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_ON,
        // 自動機
        Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER_VENDING => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_VENDING,
        // GW
        Constant.ORDP_DEVELOPER_NAME_PAY_PARTNER => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_GW,
        // オンラインPSP
        Constant.ORDP_DEVELOPER_NAME_PARTNER_ONLINE => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_PSP,
        Constant.ORDP_DEVELOPER_NAME_DIRECT_SMB => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_PSP,
        // メーカー
        Constant.ORDP_DEVELOPER_NAME_SPECIFIC_PRODUCT_COUPON => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_MAKER,
        Constant.ORDP_DEVELOPER_NAME_RETAILGIFT => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_MAKER,
        Constant.ORDP_DEVELOPER_NAME_LYPMILEAGE => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_MAKER,
        Constant.ORDP_DEVELOPER_NAME_GIFTCARD => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_MAKER,
        // ポイント事業者
        Constant.ORDP_DEVELOPER_NAME_BALANCEAPI => AccountTeamMemberUtil.PRODUCT_IN_CHARGE_POINT
    };
}