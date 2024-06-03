/**
* クラス名: CRMDPPBookProd2NameUtil
* クラス概要: サービス管理オブジェクト分割 価格表、サービス名定義共通クラス
------------------------------------------------------------------------------------------------------
* Project Name: デジタルセールス高度化Ph4
------------------------------------------------------------------------------------------------------
* Created Date: 2023/11/1
* Updated Date: -
------------------------------------------------------------------------------------------------------
* 定義書
* https://docs.google.com/spreadsheets/d/1LGjfVBfMG2STi9OgTlmTojowsmC4BsFf/edit#gid=167590816&fvid=1042614316
* @warning
* 名称の変更や追加・削除が考えられるため、高度化移行バッチ以外での使用は禁止する
*/
public without sharing class CRMDPPBookProd2NameUtil {
    /**
     * 価格表名
     */
    public final static String CRMD_PBOOK_STD = 'Standard Price Book';
    public final static String CRMD_PBOOK_OFFLINE = 'エンプラ_オフライン';
    public final static String CRMD_PBOOK_ONLINE = 'エンプラ_オンライン';
    public final static String CRMD_PBOOK_VENDING = 'エンプラ_自動機';
    public final static String CRMD_PBOOK_MAKER = 'エンプラ_メーカー';
    public final static String CRMD_PBOOK_POINT = 'エンプラ_ポイント事業者';
    public final static String CRMD_PBOOK_MYSTORE = 'エンプラ_マイストア';
    public final static String CRMD_PBOOK_PSP = 'エンプラ_PSP';
    public final static String CRMD_PBOOK_GW = 'エンプラ_GW';
    public final static String CRMD_PBOOK_INVISIBLE = 'エンプラ_非表示';
    public final static String CRMD_PBOOK_INDEVSALES = '個店';

    /**
     * サービス名
     */
    // オフライン
    public final static String CRMD_PROD2_OFFLINE = 'オフライン';
    public final static String CRMD_PROD2_OFF_PLC = 'オフライン_PLC';
    public final static String CRMD_PROD2_OFF_STAMP = '【Offline】スタンプ';
    public final static String CRMD_PROD2_OFF_PAAS = 'PaaS';
    public final static String CRMD_PROD2_OFF_POINT = '【Offline】PPポイント加盟店';
    public final static String CRMD_PROD2_OFF_REVISIT = '【Offline】再来店クーポン';
    public final static String CRMD_PROD2_OFF_FLYER = 'チラシ_申込';
    public final static String CRMD_PROD2_OFF_SCHEDULED = '【Offline】日時指定クーポン';
    public final static String CRMD_PROD2_OFF_ROUTE = 'ルート開通';
    public final static String CRMD_PROD2_OFF_CAMPAIGN_GRANT = '【集約】【Offline】個社キャンペーン（総付け）';
    public final static String CRMD_PROD2_OFF_CAMPAIGN_JAMBO = '【集約】【Offline】個社キャンペーン（ジャンボ）';

    // オンライン
    public final static String CRMD_PROD2_ONLINE = 'オンライン';
    public final static String CRMD_PROD2_ON_MALL = 'オンライン_モール';
    public final static String CRMD_PROD2_ON_PLC ='オンライン_PLC';
    public final static String CRMD_PROD2_ON_STAMP = '【Online】スタンプ';
    public final static String CRMD_PROD2_ON_MINI = 'ミニアプリ';
    public final static String CRMD_PROD2_ON_POINT = '【Online】PPポイント加盟店';
    public final static String CRMD_PROD2_ON_REVISIT = '【Online】再来店クーポン';
    public final static String CRMD_PROD2_ON_SCHEDULED = '【Online】日時指定クーポン';
    public final static String CRMD_PROD2_ON_CAMPAIGN_GRANT = '【集約】【Online】個社キャンペーン（総付け）';
    public final static String CRMD_PROD2_ON_CAMPAIGN_JAMBO = '【集約】【Online】個社キャンペーン（ジャンボ）';

    // 自動機
    public final static String CRMD_PROD2_VENDING = 'オンライン_自動機';
    public final static String CRMD_PROD2_VENDING_OFFPLC = '【自動機】オフラインPLC';
    public final static String CRMD_PROD2_VENDING_ONPLC = '【自動機】オンラインPLC';
    public final static String CRMD_PROD2_VENDING_REVISIT = '【自動機】再来店クーポン';
    public final static String CRMD_PROD2_VENDING_SCHEDULED = '【自動機】日時指定クーポン';

    // メーカー非メーカー
    public final static String CRMD_PROD2_MAKER_SKU = '商品特定クーポン';
    public final static String CRMD_PROD2_MAKER_RETAIL = 'リテールギフト';
    public final static String CRMD_PROD2_MAKER_LYP = 'LYPマイレージ';
    public final static String CRMD_PROD2_MAKER_GIFT = 'ギフトカード';
    public final static String CRMD_PROD2_MAKER_LINE = 'LINEで応募';

    // ポイント事業者
    public final static String CRMD_PROD2_BALANCE_API = '残高API';

    // GW
    public final static String CRMD_PROD2_GW = 'オフライン_GW';

    // PSP
    public final static String CRMD_PROD2_PSP_CART = 'オンライン_カート';
    public final static String CRMD_PROD2_PSP = 'オンライン_PSP';
    public final static String CRMD_PROD2_PSP_SMB = '直契約SMB';

    // マイストア
    public final static String CRMD_PROD2_MYSTORE_ENPR = 'マイストア（大手営業管理）';

    // 非表示
    public final static String CRMD_PROD2_MANAGED_ENPR = 'オンライン大手管理用';

    // 旧サービス名 (新サービスとして新しい価格表へ登録されないもの、または名称変更等されて登録されるもの)
    public final static String CRMD_OLD_PROD2_ON_ENPR_BIZ = 'オンライン_大手_加盟店';
    public final static String CRMD_OLD_PROD2_ON_SMALL_BIZ = 'オンライン_中小_加盟店';
    public final static String CRMD_OLD_PROD2_OFF_ENPR_BIZ = 'オフライン_大手_加盟店';
    public final static String CRMD_OLD_PROD2_OFF_SMALL_BIZ = 'オフライン_中小_加盟店';
    public final static String CRMD_OLD_PROD2_ON_SS = 'オフライン_SS切替';
    public final static String CRMD_OLD_PROD2_SCHEDULED = '日時指定クーポン';
    public final static String CRMD_OLD_PROD2_POINT = 'PayPayポイント';
    public final static String CRMD_OLD_PROD2_CAMPAIGN_JAMBO = '【集約】個社キャンペーン（ジャンボ）';
    public final static String CRMD_OLD_PROD2_CAMPAIGN_GRANT = '【集約】個社キャンペーン（総付け）';
    public final static String CRMD_OLD_PROD2_OFF_PLC = 'オフライン_PLC';
    public final static String CRMD_OLD_PROD2_ON_PLC = 'オンライン_PLC';
    public final static String CRMD_OLD_PROD2_MALL_CART = 'オンライン_モール/カート';
    public final static String CRMD_OLD_PROD2_MYSTORE = 'マイストア';

    // 移行タイプ
    public enum REPLACE_TYPE {
        IS_NOMAL, // 旧価格表エントリと新価格表エントリが1:1で紐づく
        IS_ONLINE, // 旧価格表エントリがオンラインとその他に分離する
        IS_OFFLINE, // 旧価格表エントリがオフラインとその他に分離する
        IS_VENDING, // 旧価格表エントリが自動機とその他に分離する
        IS_PSP, // 旧価格表エントリがPSPとその他に分離する
        IS_STD // 旧価格表エントリをそのまま利用する
    }

    // 旧サービスが複数の新サービスに分岐するもの(REPLACE_TYPE=IS_NOMAL以外)
    public final static Set<String> CRMD_MULTI_MIG_SERVICE = new Set<String>{
        CRMD_OLD_PROD2_OFF_PLC,
        CRMD_OLD_PROD2_ON_PLC,
        CRMD_OLD_PROD2_POINT,
        CRMD_OLD_PROD2_CAMPAIGN_JAMBO,
        CRMD_OLD_PROD2_CAMPAIGN_GRANT,
        CRMD_OLD_PROD2_MALL_CART
    };

    // オンオフ定義
    public final static String CRMD_SERVICE_TYPE_ON = 'オンライン';
    public final static String CRMD_SERVICE_TYPE_OFF = 'オフライン';

    // 業種
    public final static string CRMD_INDUSTRY_TYPE_VENDING = '自動機';
    public final static string CRMD_INDUSTRY_TYPE_CART = 'カート';

    // 案件営業状況（未商談～申込書受領済、失注）
    public final static Set<String> OPP_TARGET_STAGENAME = new Set<String> {
        '00', '10', '20', '30', '40', '50', '60', '90'
    };

    // 各部テストアカウントの取引先ID
    public final static String TEST_ACCOUNT_ID = '0015j00000jzZViAAM';
}