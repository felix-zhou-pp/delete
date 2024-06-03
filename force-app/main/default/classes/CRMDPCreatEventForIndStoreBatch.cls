/**
 * CRM高度化PJ　個店行動移行バッチ
 *  - 概要
 *   CRM高度化　個店案件の移行元PPアタックリストとPPストア、の下のPP営業履歴とPPコミュニケーションを案件の行動に移行するバッチ
 *   個店案件移行後実行できる（個店取引先と案件の存在が前提）
 * 　　ロジック：
 * 　　　根拠項目：案件.移行元PayPayアタックリスト(CRMDPMpOppId__c)	移行元PayPayストア	CRMDPStoreId__c
 * 　　　①個店案件＋案件移行元値あり　の案件レコードをバッチ取得し
 * 　　　②バッチ内、案件移行元とその下の行動相当レコード取得
 * 　　　③オブジェクトごとに行動相当レコードをループし行動に移行
 *          3.1移行元行動のIdが行動のInteractionQueue__cにあれば移行済み判定しスキップ キューはPG使っていない
 * 　　　　　3.2項目によって異なるロジック：結合か、優先項目使うか、案件移行元Or行動移行元使うか
 *          3.3移行元行動のIdをInteractionQueue__cに保存
 * 　　　④まとめて保存し件数集計
 * 　　　⑤まとめて結果をログに
1回目  CRMDPStoreId__c != null

2回目 (CRMDPMpOppId__c != null AND CRMDPStoreId__c = null)

2-1       CRMDPMpOppId__r.createdDate <=2018-05-31T23:59:59.999+0900
  
2-2  　　 CRMDPMpOppId__r.createdDate >=2018-06-01T00:00:00.000+0900
             AND CRMDPMpOppId__r.createdDate <=2018-12-31T23:59:59.999+0900

2-3    CRMDPMpOppId__r.createdDate >=2019-01-01T00:00:00.000+0900
             AND CRMDPMpOppId__r.createdDate <=2019-10-31T23:59:59.999+0900
        
2-4             CRMDPMpOppId__r.createdDate >=2019-11-01T00:00:00.000+0900
             AND CRMDPMpOppId__r.createdDate <=2021-12-31T23:59:59.999+0900


2-5             CRMDPMpOppId__r.createdDate >=2022-01-01T00:00:00.000+0900

 *  - 実行方法
 *   開発者コンソールから以下のコマンドを実行する
 *   Database.executeBatch(new CRMDPCreatEventForIndStoreBatch(), 200);
 */
public without sharing class CRMDPCreatEventForIndStoreBatch implements Database.Batchable<sObject>, Database.Stateful {
    // DMLException test のためのフラグ
    @testVisible
    private static Boolean isDMLExceptionTest = false;
    @testVisible
    private static Boolean ifRemoveDup = true;
    @testVisible
    public static Id unActiveUserId  = '0055j000006l340AAA';
    public static Id queueDummyUserId = '0055j00000BwUXTAA3';
    // 移行済みの案件レコードタイプ個店　OpportunityRecordType_IndivSales
    public final String OPP_RTDNAME_INDIVSALES = 'OpportunityRecordType_IndivSales';
    public Id RTID_OPP_IND;

    //移行対象のPPコミュニケーションmpComm__cRT：マイストア営業活動ログ　PayPayMyStoreTask
    public final String MPCOM_RTDNAME_MYSTTSK = 'PayPayMyStoreTask';
    public Id RTID_MPCOM;

    //移行先の行動のRT：
    public final String EVT_RTDNAME_INDS = 'EventRecordType_IndividualSales';
    public Id RTID_EVT;
    //デフォルトの件名、活動区分
    @testVisible
    public static final String EVT_TITLE = '活動ログ';
    @testVisible
    private static final String BATCH_NAME = '【CRM高度化】個店行動移行CRMDPCreatEventForIndStoreBatch';
    //インスタンスごとの変数
    @testVisible
    public Integer termIndex;
    //対象案件作成日時の最小時刻　2回目移行の時以前の移行済み分の排除のため
    //設定例：oneBth.targetOppCreatedTimeStart=Datetime.newInstance(Date.Today(),Time.newInstance(0, 0, 0, 0));
    @testVisible
    public Datetime targetOppCreatedTimeStart = null;
    // バッチ結果格納
    @testVisible
    private BatchResult bResult = new BatchResult();
    private Boolean hasException = false;
    
    //期間限定移行元案件取得用SOQL生成　汎用メソッド
    public static String createSOQLByTerm(Integer term){
        String soql ='SELECT '
        +'    Id,AccountId,CRMDPMpOppId__c,CRMDPStoreId__c,'
        +'    (SELECT id,RecordType.DeveloperName FROM OrderProgress_OpportunityId__r),'
        +'    (SELECT id,RecordType.DeveloperName FROM OrderProgressMB_OpportunityId__r) ' 
        +' FROM Opportunity'
        +' WHERE RecordTypeId = :RTID_OPP_IND'
        +' AND CreatedDate >= :targetOppCreatedTimeStart';
        switch on term {
            when 1 {
                soql+=' AND CRMDPStoreId__c != null';
            }
            when 2 {
                soql+=' AND (CRMDPMpOppId__c != null AND CRMDPStoreId__c = null)';
                soql+=' AND CRMDPMpOppId__r.createdDate <=2018-05-31T23:59:59.999+0900';
            }
            when 3 {
                soql+=' AND (CRMDPMpOppId__c != null AND CRMDPStoreId__c = null)';
                soql+=' AND CRMDPMpOppId__r.createdDate >=2018-06-01T00:00:00.000+0900';
                soql+=' AND CRMDPMpOppId__r.createdDate <=2018-12-31T23:59:59.999+0900';
            }
            when 4 {
                soql+=' AND (CRMDPMpOppId__c != null AND CRMDPStoreId__c = null)';
                soql+=' AND CRMDPMpOppId__r.createdDate >=2019-01-01T00:00:00.000+0900';
                soql+=' AND CRMDPMpOppId__r.createdDate <=2019-10-31T23:59:59.999+0900';
            }
            when 5 {
                soql+=' AND (CRMDPMpOppId__c != null AND CRMDPStoreId__c = null)';
                soql+=' AND CRMDPMpOppId__r.createdDate >=2019-11-01T00:00:00.000+0900';
                soql+=' AND CRMDPMpOppId__r.createdDate <=2021-12-31T23:59:59.999+0900';
            }
            when 6 {
                soql+=' AND (CRMDPMpOppId__c != null AND CRMDPStoreId__c = null)';
                soql+=' AND CRMDPMpOppId__r.createdDate >=2022-01-01T00:00:00.000+0900';
            }
            when else {
                soql+=' AND (CRMDPMpOppId__c != null OR CRMDPStoreId__c != null)';
            }
        }
        return soql;
    }
    /**
     * コンストラクタ
     */
    public CRMDPCreatEventForIndStoreBatch() {
        RTID_OPP_IND = mpUtilString.getRecordTypeByDeveloperName(Opportunity.sObjectType, OPP_RTDNAME_INDIVSALES); 
        RTID_MPCOM   = mpUtilString.getRecordTypeByDeveloperName(mpComm__c.sObjectType, MPCOM_RTDNAME_MYSTTSK); 
        RTID_EVT     = mpUtilString.getRecordTypeByDeveloperName(Event.sObjectType, EVT_RTDNAME_INDS);       
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('===== start CRMDPCreatEventForIndStoreBatch =====');
        // ①個店案件＋案件移行元値あり　の案件レコードをバッチ取得し
        return Database.getQueryLocator(createSOQLByTerm(termIndex));
    }
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        System.debug('===== execute CRMDPCreatEventForIndStoreBatch =====');
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
        //新規行動リスト
        List<Event> newEvents = new List<Event>();
        //アタックリスト処理
        if(mpOppIdLst.size()>0){
            //PP営業履歴を検索
            List<mpBusinessToDo__c> mBTList = [
                SELECT 
                    //営業履歴
                    CreatedDate,
                    Result__c,//コンタクト結果
                    NotesForForbidden__c,//備考：受付不可業種、業態
                    NotesForEscalation__c,//備考：エスカ案件（後日営業提案）	
                    Check__c,//対応者確認（コンタクト完了以外）
                    CheckMemo__c,//対応者確認（その他）	
                    Subject__c,//コンタクト手段
                    BusinessMemo__c,//備考欄
                    Comment__c,//コメント
                    NextMeetingDate__c,//次回コンタクト予定日
                    //アタックリスト
                    mpRelation__r.Id,
                    mpRelation__r.OwnerId,
                    mpRelation__r.Owner.IsActive,
                    mpRelation__r.Owner.Type,
                    mpRelation__r.Note__c,//提案日時・希望連絡先情報・コメント
                    mpRelation__r.RecentToDoComment__c,//最新活動コメント
                    mpRelation__r.LastTodoDate__c,//営業結果入力日
                    mpRelation__r.SuggestCompleteDate__c,//提案完了日
                    Id
                FROM   mpBusinessToDo__c
                WHERE  mpRelation__c IN  :mpOppIdLst
                    AND  Result__c   IN  ('7.受付禁止業態','8.閉店','9.休業')
            ];
            //移行済みの行動を検索し、移行済み営業履歴を排除
            Set<String> mBTIdStringList = new Set<String>();
            for(mpBusinessToDo__c mbt : mBTList){
                mBTIdStringList.add(String.valueOf(mbt.Id));
            }
            List<Event> migedEvts = [
                SELECT Id,InteractionQueue__c
                FROM   Event
                WHERE  InteractionQueue__c IN :mBTIdStringList
                AND isDeleted = false
                ALL ROWS
            ];
            //移行済み営業履歴を排除
            Set<Id> migedMBTIds = new Set<Id>();
            for(Event migedEvt : migedEvts){
                Id migedMBTId = Id.valueOf(migedEvt.InteractionQueue__c);
                migedMBTIds.add(migedMBTId);
                for (Integer i = (mBTList.size()-1) ; i>= 0 ; i--){
                    if(mBTList[i].Id == migedMBTId){
                        mBTList.remove(i);
                        mBTIdStringList.remove(String.valueOf(migedMBTId));
                    }
                }
            }
            //真の移行　営業履歴
            for(mpBusinessToDo__c mbt : mBTList){
                //行動作成
                MigClassBT mCBT = new MigClassBT(mbt,mpOppToOppMap.get(mbt.mpRelation__r.Id),RTID_EVT);
                newEvents.add(mCBT.evt);
            }
        }
        //PPストア処理　PPコミュニケーション移行mpComm__c
        if(ppStoreIdLst.size()>0){
            //PPコミュニケーションを検索
            List<mpComm__c> mpComList = [
                SELECT 
                    //PPコミュニケーション
                    OwnerId,
                    Owner.IsActive,
                    Owner.Type,
                    CreatedDate,
                    IntroMemo__c, //【コンタクト関連】コンタクト関連備考
                	X08__c,       //その他（なんでも）
                    CouponIssueNegotiationsDate__c,//【重要商材商談状況】クーポン発行商談日	
	                LightPlanNegotiationsDate__c,  //【重要商材商談状況】ライトプラン商談日
                    PayPayFlyerNegotiationsDate__c,//【その他商材商談状況】PayPayチラシ商談日	
                	StampIssueNegotiationsDate__c, //【重要商材商談状況】スタンプ発行商談日
                	UStoSSNegotiationsDate__c,     //【US→SS商材商談状況】US→SS商談日

                    CouponIssueBusinessContent__c, //【重要商材商談状況】クーポン発行商談内容	
                	LightPlanBusinessContent__c,   //【重要商材商談状況】ライトプラン商談内容
                	StampIssueBusinessContent__c,  //【重要商材商談状況】スタンプ発行商談内容
                    UStoSSBusinessContent__c,//【US→SS商材商談状況】US→SS商談日
                    
                    BusinessContent__c,

                    ContactResult__c, //【コンタクト関連】コンタクト結果
                    ContactType__c,   //【コンタクト関連】コンタクト種別	
                    Comment__c,//コメント

                    PayPayMyStoreToDo__r.Id,
                    Id
                FROM   mpComm__c
                WHERE  PayPayMyStoreToDo__c IN  :ppStoreIdLst //PayPayストア（マイストア営業活動ログ）	
                    AND  ContactResult__c   IN  ('閉店','休業')
                    AND  RecordTypeId = :RTID_MPCOM
            ];
            //移行済みの行動を検索し、移行済み営業履歴を排除
            Set<String> mpComIdStringList = new Set<String>();
            for(mpComm__c mpC : mpComList){
                mpComIdStringList.add(String.valueOf(mpC.Id));
            }
            List<Event> migedEvtsCom = [
                SELECT Id,InteractionQueue__c
                FROM   Event
                WHERE  InteractionQueue__c IN :mpComIdStringList
                AND isDeleted = false
                ALL ROWS
            ];
            //移行済み営業履歴を排除
            Set<Id> migedMpComIds = new Set<Id>();
            for(Event migedEvtCom : migedEvtsCom){
                Id migedMpComId = Id.valueOf(migedEvtCom.InteractionQueue__c);
                migedMpComIds.add(migedMpComId);
                for (Integer i = (mpComList.size()-1) ; i>= 0 ; i--){
                    if(mpComList[i].Id == migedMpComId){
                        mpComList.remove(i);
                        mpComIdStringList.remove(String.valueOf(migedMpComId));
                    }
                }
            }
            //真の移行　PPコミュニケーション
            for(mpComm__c mpCom : mpComList){
                //行動作成
                MigClassCom mClsCom = new MigClassCom(mpCom,ppStoreToOppMap.get(mpCom.PayPayMyStoreToDo__r.Id),RTID_EVT);
                newEvents.addAll(mClsCom.evts);
            }    
        }
        // for DMLException Test Logic
        if (Test.isRunningTest() && isDMLExceptionTest) {
            newEvents.add(new Event( TalkType__c = 'unacceptable'));
        }
        //DB更新：行動
        if(newEvents.size()>0){
            try{
                insert newEvents;
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
    //重複作成したアーカイブ分削除
    public void deleteDup(){
        Logger logger = new Logger();
        //移行元Id＋Typeごとに1件削除 (PPコミュニケーションは同じ移行元で複数Typeで作成されるため)
        Set<Id> eventIdLstForRemove = new Set<Id>();
        List<AggregateResult>  dupRlt =[Select InteractionQueue__c,Type,count(ID),MAX(Id) from Event Where (InteractionQueue__c like 'a29%' OR InteractionQueue__c like 'a2A%')AND isDeleted = false Group By InteractionQueue__c,Type Having count(ID)>1 All Rows];
        System.debug(dupRlt.size());
        for(AggregateResult e:dupRlt){
            Id dupId= (Id) e.get('expr1');
            System.debug(dupId);
            eventIdLstForRemove.add(dupId);
        }
        if(ifRemoveDup&&eventIdLstForRemove.size()>0){
            List<Event> evtLstRemove = [Select Id From Event Where Id IN :eventIdLstForRemove All Rows];
            try{
                delete evtLstRemove;
                logger.info(BATCH_NAME, '\n▼重複削除成功\n' + eventIdLstForRemove , false);
            }catch (Exception ex) {
                system.debug(ex.getmessage());
                system.debug(ex.getStackTracestring());
                this.hasException = true;
                logger.error(BATCH_NAME, '\n▼重複削除失敗\n' + eventIdLstForRemove + '\n▼エラー概要\n' + logger.formatErrorMessage(ex), false);
            }finally {
                logger.saveAll();
            }
        }
        //削除完了
    }
    public void finish(Database.BatchableContext BC) {
        System.debug('===== finish CRMDPCreatEventForIndStoreBatch =====');
        System.debug('処理対象個店案件合計：' + bResult.totalRecordSize);
        System.debug(bResult.toString());
        deleteDup();
        Logger logger = new Logger();
        if (this.hasException || bResult.hasError) {
            logger.error(BATCH_NAME, bResult.toString(), true).saveAll();
        } else {
            logger.info(BATCH_NAME, bResult.toString(), false).saveAll();
        }
    }
    static String convertStringWithEmpty(String inString){
        return String.isBlank(inString)?'':inString;
    }
    //商談対象
    static private Map<String,String> oPRTDNameToTType = new Map<String, String>{
        'PayEnterprise' => '加盟店獲得（OFF）'
        , 'PayCAS' => 'PayCAS'
        //以下加盟店事業
        , 'IndividualStore_mystore' => 'マイストア'//マイストア（個店営業管理）
        , 'FlyerApply' => 'チラシ'//チラシ_申込	
        , 'PLCRecordType' => 'PLC(OFF)'//オフライン_PLC	
        , 'SCRecordType' => 'スタンプカード'
    };
    static private String mappingTalkType(Opportunity opp){
        Set<String> selectedTT = new Set<String>();
        //決済：オフライン　PayCAS
        for(OrderProgress__c op:opp.OrderProgress_OpportunityId__r){
            String tType = oPRTDNameToTType.get(op.RecordType.DeveloperName);
            if(tType != null){
                selectedTT.add(tType);
            }
        }
        for(OrderProgressMB__c opMb:opp.OrderProgressMB_OpportunityId__r){
            String tType = oPRTDNameToTType.get(opMb.RecordType.DeveloperName);
            if(tType != null){
                selectedTT.add(tType);
            }
        }
        return String.join(selectedTT,';');
    }
    /*サービス分類
    static private Map<String,String> oPRTDNameToP2C = new Map<String, String>{
        'PayEnterprise' => 'オフライン'
        , 'PayCAS' => 'PayCAS'
        //以下加盟店事業
        , 'IndividualStore_mystore' => 'マイストア（個店営業管理）'//マイストア（個店営業管理）
        , 'FlyerApply' => 'チラシ_申込'//チラシ_申込	
        , 'PLCRecordType' => 'オフライン_PLC'//オフライン_PLC	
        , 'SCRecordType' => 'スタンプカード'
    };
    static private String mappingP2C(Opportunity opp){
        Set<String> selectedP2C = new Set<String>();
        //決済：オフライン　PayCAS
        for(OrderProgress__c op:opp.OrderProgress_OpportunityId__r){
            String p2C = oPRTDNameToP2C.get(op.RecordType.DeveloperName);
            if(p2C != null){
                selectedP2C.add(p2C);
            }
        }
        for(OrderProgressMB__c opMb:opp.OrderProgressMB_OpportunityId__r){
            String p2C = oPRTDNameToP2C.get(opMb.RecordType.DeveloperName);
            if(p2C != null){
                selectedP2C.add(p2C);
            }
        }
        return String.join(selectedP2C,';');
    }
    */
    static private Map<String,String> bTResultMap = new Map<String,String> {
        '7.受付禁止業態'  => '受付禁止業態',
        '8.閉店'  => '閉店',
        '9.休業'  => '休業'
    };
    static private Map<String,String> bTContactTypeMap = new Map<String,String> {
        '1.訪問'  => '訪問',
        '2.電話(アウト)'  => '電話(アウト)',
        '3.電話（イン）'  => '電話(イン)',
        '4.メール'  => 'メール'
    };
    
    //営業履歴移行クラス
    private class MigClassBT{
        public Event evt;
        public mpBusinessToDo__c bt;

        public MigClassBT(mpBusinessToDo__c bt,Opportunity opp,Id evtRTId){
            this.bt = bt;
            //移行
            this.evt = new Event(
                InteractionQueue__c = String.valueOf(bt.Id),//移行元Idは保存　営業履歴
                RecordTypeId = evtRTId,
                WhatId    = opp.AccountId,//関連先 ID移行後のAccount
                OwnerId   = (bt.mpRelation__r.Owner.IsActive&bt.mpRelation__r.Owner.Type=='User')?bt.mpRelation__r.OwnerId:((bt.mpRelation__r.Owner.Type=='User')?unActiveUserId:queueDummyUserId),   //PayPay営業履歴の所有者
                Subject   = EVT_TITLE,//Select件名	
                Type      = EVT_TITLE,//Select活動区分
                StartDateTime = bt.CreatedDate,//移行対象活動ログの作成日時
                EndDateTime   = bt.CreatedDate,//移行対象活動ログの作成日時
                Description   = convertStringWithEmpty(bt.Comment__c) +'\n'+ convertStringWithEmpty(bt.BusinessMemo__c) +'\n'+ convertStringWithEmpty(bt.mpRelation__r.Note__c),//32000コメント説明
                TalkTypeConsultation__c = (convertStringWithEmpty(bt.Comment__c) +'\n'+ convertStringWithEmpty(bt.BusinessMemo__c) +'\n'+ convertStringWithEmpty(bt.mpRelation__r.Note__c)).left(255),//255備考
                CreatedDate   = bt.CreatedDate,//作成日 元が作成日なので結論作成日にした
                Remarks_NotAccepted__c = bt.NotesForForbidden__c,//255備考：受付不可業種、業態
                Remarks_EscaPJT__c = bt.NotesForEscalation__c,//255備考：エスカ案件(後日営業提案)
                ChargeConfirmOthers__c = bt.CheckMemo__c,//255対応者確認（その他）	
                Check__c  = bt.Check__c,//Select対応者確認（コンタクト完了以外）
                Result__c = mappingBTResult(bt.Result__c),//Select結果
                ContactType__c = mappingBTContactType(bt.Subject__c),//Selectコンタクト種別
                NextActionDate__c = bt.NextMeetingDate__c==null?null:bt.NextMeetingDate__c.addHours(9).date(),//ネクストアクション期日 次回コンタクト予定日
                TalkType__c = mappingTalkType(opp) //Select商談対象	商材別マッピング表に従い登録 Appendix.行動「サービス分類」「商談対象」
                //Product2Category__c = mappingP2C(opp)//サービス分類 移行要件「商材別識別方法」に基づきアタックリストの項目から識別した商材を読み替え登録 Appendix.行動「サービス分類」「商談対象」
            );
            
        }
        
        private String mappingBTResult(String bTResult){
            return  bTResultMap.get(bTResult);
        }
        
        private String mappingBTContactType(String bTSubject){
            return bTContactTypeMap.get(bTSubject);
        }

    }


    //PPコミュニケーション商材ごとの商談日＞商談内容Map
    static private Map<String,String> dateToContentFieldNameMapCom = new Map<String,String> {
        'CouponIssueNegotiationsDate__c'  => 'CouponIssueBusinessContent__c'//【重要商材商談状況】クーポン発行商談日 	
        ,'LightPlanNegotiationsDate__c'   => 'LightPlanBusinessContent__c'//【重要商材商談状況】ライトプラン商談日
        ,'PayPayFlyerNegotiationsDate__c' => 'BusinessContent__c'//【その他商材商談状況】PayPayチラシ商談日　該当商談内容項目が無いため
        ,'StampIssueNegotiationsDate__c'  => 'StampIssueBusinessContent__c'//【重要商材商談状況】スタンプ発行商談日
        ,'UStoSSNegotiationsDate__c'      => 'UStoSSBusinessContent__c'//【US→SS商材商談状況】US→SS商談日
    };
    //PPコミュニケーション商材ごとの商談日＞商談対象Map
    static private Map<String,String> dateToTTypeMapCom = new Map<String,String> {
        'UStoSSNegotiationsDate__c' => '加盟店獲得（OFF）'
        //以下加盟店事業
        , 'LightPlanNegotiationsDate__c' => 'マイストア'//マイストア（個店営業管理）
        , 'PayPayFlyerNegotiationsDate__c' => 'チラシ'//チラシ_申込	
        , 'CouponIssueNegotiationsDate__c' => 'PLC(OFF)'//オフライン_PLC	
        , 'StampIssueNegotiationsDate__c' => 'スタンプカード'
    };
    //PPコミュニケーション移行クラス
    private class MigClassCom{
        public List<Event> evts;
        public mpComm__c com;
        private Event createEvent(mpComm__c com,Opportunity opp,Id evtRTId){
            return new Event(
                InteractionQueue__c = String.valueOf(com.Id),//移行元Idは保存　PPコミュニケーション
                RecordTypeId = evtRTId,
                WhatId    = opp.AccountId,//関連先 ID移行後のAccount
                OwnerId   = (com.Owner.IsActive&com.Owner.Type=='User')?com.OwnerId:((com.Owner.Type=='User')?unActiveUserId:queueDummyUserId),  //PayPayコミュニケーションの所有者
                StartDateTime = com.CreatedDate,//移行対象活動ログの作成日時
                EndDateTime   = com.CreatedDate,//移行対象活動ログの作成日時
                Description   = convertStringWithEmpty(com.IntroMemo__c) +'\n'+ convertStringWithEmpty(com.X08__c) ,//32000コメント
                TalkTypeConsultation__c = (convertStringWithEmpty(com.IntroMemo__c) +'\n'+ convertStringWithEmpty(com.X08__c)).left(255) ,//255備考
                Result__c = convertStringWithEmpty(com.ContactResult__c),//Select結果 【コンタクト関連】コンタクト結果
                ContactType__c = convertStringWithEmpty(com.ContactType__c)//Selectコンタクト種別
                //TalkType__c = mappingTalkType(opp) //商談対象	商材別マッピング表に従い登録 Appendix.行動「サービス分類」「商談対象」
                //Product2Category__c = mappingP2C(opp)//サービス分類 移行要件「商材別識別方法」に基づきアタックリストの項目から識別した商材を読み替え登録 Appendix.行動「サービス分類」「商談対象」
            );
        }
        public MigClassCom(mpComm__c com,Opportunity opp,Id evtRTId){
            this.com = com;
            this.evts = new List<Event>();
            //移行 商材別商談状況系日付ごとに行動作成　
            for(String dateFName : dateToContentFieldNameMapCom.keySet()){
                String bTalkContent = convertStringWithEmpty((String) com.get(dateToContentFieldNameMapCom.get(dateFName)));
                Date   bTalkDate    = (Date) com.get(dateFName);
                //方針：商材ごとに商談日と内容のペア項目があって、どれか値あれば単独レコードとして作成移行する、全部空欄なら移行しない
                //作成日＝商談日付Or移行元作成日　件名&活動区分＝商談内容Orデフォルト活動区分	
                //商談対象は商材に合わせる
                if(bTalkDate!=null||!String.isBlank(bTalkContent)){
                    if(String.isBlank(bTalkContent)){bTalkContent = EVT_TITLE;}
                    Event eForBTalkContent = createEvent(com,opp,evtRTId);
                    eForBTalkContent.CreatedDate = (bTalkDate==null?com.createdDate:Datetime.newInstance(bTalkDate.year(), bTalkDate.month(), bTalkDate.day()));
                    eForBTalkContent.Type = bTalkContent;//Select
                    eForBTalkContent.Subject = bTalkContent;//Select件名
                    eForBTalkContent.TalkType__c = dateToTTypeMapCom.get(dateFName);//Select商談対象	商材別マッピング表に従い登録
                    this.evts.add(eForBTalkContent);
                }
            }
            
        }
    }


}