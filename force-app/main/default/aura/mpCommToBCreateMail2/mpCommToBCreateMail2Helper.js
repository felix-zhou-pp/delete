({
    getLayoutInfo : function(cmp) {
        var layoutInfo = {};
        var commonHeader1 = "※本メールの内容について、電話でのお問い合わせは承っておりませんので、予めご了承下さい。\n"
        +"※件名の乱数は、管理番号となるため削除せず、そのままご返信をお願いいたします。\n\n";
        var commonHeader2 = "PayPay株式会社 加盟店管理窓口です。\n";
        
        var commonHeader3 = "※1. 本件については、メールでのみ対応しており、電話では受付しておりません。予めご了承ください。\n"
        +"※2. ご返信の際は、件名を変更せずにご返信ください。\n"
        +"\n"
        +"PayPay株式会社です。"
        +"\n"
        +"弊社がご提供していますPayPayのサービスに関する重要なご連絡でございます。\n"
        +"\n"
        +"貴社にて直近で発生した特定ユーザーとの取引について、弊社で調査の必要が生じたため、PayPayサービスの機能を停止いたしました。\n";
        
        var commonHeader4 = "※1. 本件については、メールでのみ対応しており、電話では受付しておりません。予めご了承ください。\n"
        +"※2. ご返信の際は、件名を変更せずにご返信ください。\n"
        +"\n"
        +"PayPay株式会社です。\n"
        +"\n"
        +"弊社が提供しておりますPayPayのサービスに関する重要なご連絡でございます。\n"
        +"\n"
        +"貴社にて直近で発生した特定ユーザーとの取引について、弊社で調査の必要が生じたため、メールをお送りさせていただきました。\n";
        
        var commonHeader5 = "※1. 本件については、メールでのみ対応しており、電話では受付しておりません。予めご了承ください。\n"
        +"※2. ご返信の際は、件名を変更せずにご返信ください。\n"
        +"\n"
        +"PayPay株式会社です。\n"
        +"\n"
        +"弊社が提供しておりますPayPayのサービスに関する重要なご連絡でございます。\n"
        +"\n"
        +"先日、お送りしましたメールにご返信がございませんでしたので、PayPayサービスの機能を停止いたしました。\n";
        
        var commonHeader6 = "※1. 本件については、メールでのみ対応しており、電話では受付しておりません。予めご了承ください。\n"
        +"※2. ご返信の際は、件名を変更せずにご返信ください。\n"
        +"\n"
        +"PayPay株式会社です。\n";
        
        var commonHeader7 = "PayPay株式会社です。\n\n"
        +"ご連絡いただきありがとうございます。\n\n"
        +"お忙しいところ恐縮ではございますが、下記の内容につき再度ご回答をお願いいたたします。\n";
        
        var commonHeader8 = "※本メールはご案内専用となります。本メールにご返信いただいてもお答えできませんのでご了承ください。\n\n"
        +"PayPay月額ご利用限度額引き上げ審査担当です。\n\n"
        +"このたびは、月額ご利用限度額引き上げの申請をいただき、誠にありがとうございます。\n";
        
        var commonHeader9 = "※返信の際は、件名を変更せずご返信ください。\n\n"
        +"PayPay月額ご利用限度額引き上げ審査担当です。\n\n"
        +"このたびは、月額ご利用限度額引き上げの申請をいただき、誠にありがとうございます。\n";
        
        var commonHeader10 = "PayPay月額ご利用限度額引き上げ審査担当です。\n\n"
        +"このたびは、月額ご利用限度額引き上げの申請をいただき、誠にありがとうございます。\n\n";
        
        var commonFooter1 = ""
        
        var commonFooter2 = "※本メールの内容は事前の書面による許可なく\n"
        +"複製、複写、転載、転送することを禁じます。\n"
        +"****************************************************************\n"
        +"発行者：PayPay株式会社\n"
        +"掲載内容の無断転載・再配布は固く禁じます。\n"
        +"\n"
        +"Copyright (C) PayPay Corporation. All Rights Reserved.\n"
        +"****************************************************************";
        
        var commonFooter3 = "なお、5営業日以内に本メールへご返信をいただけない場合、利用規約に基づき貴社との契約を解除させていただく場合もございます。\n"
        +"\n"
        +"ご返信内容によっては利用規約に基づき、更に取引に関わる資料等のご提出をお願いする場合がございますので、予めご了承ください。\n"
        +"\n"
        +"以上、お手数ではございますが、何卒よろしくお願いいたします。\n"
        +"\n"
        +"========================================================\n"
        +"発行者：PayPay株式会社\n"
        +"掲載内容の無断転載・再配布は固く禁じます。\n"
        +"Copyright (C) PayPay Corporation. All Rights Reserved.\n"
        +"========================================================\n";
        
        var commonFooter4 = "5営業日以内に本メールへご返信をいただけない場合、利用規約に基づき貴社に提供しているPayPayサービスの機能を停止させていただく場合もございます。\n"
        +"\n"
        +"ご返信内容によっては利用規約に基づき、更に取引に関わる資料等のご提出をお願いする場合がございますので、予めご了承ください。\n"
        +"\n"
        +"以上、お手数ではございますが、何卒よろしくお願いいたします。\n"
        +"\n"
        +"========================================================\n"
        +"発行者：PayPay株式会社\n"
        +"掲載内容の無断転載・再配布は固く禁じます。\n"
        +"Copyright (C) PayPay Corporation. All Rights Reserved.\n"
        +"========================================================\n";
        
        var commonFooter5 = "5営業日以内に本メールへご返信をいただけない場合、利用規約に基づき貴社との契約を解除させていただく場合もございます。\n"
        +"\n"
        +"また、ご返信内容によっては利用規約に基づき、更に取引に関わる資料等のご提出をお願いする場合がございますので、予めご了承ください。\n"
        +"\n"
        +"以上、お手数ではございますが、何卒よろしくお願いいたします。\n"
        +"\n"
        +"========================================================\n"
        +"発行者：PayPay株式会社\n"
        +"掲載内容の無断転載・再配布は固く禁じます。\n"
        +"Copyright (C) PayPay Corporation. All Rights Reserved.\n"
        +"========================================================\n";
        
        var commonFooter6 = "========================================================\n"
        +"発行者：PayPay株式会社\n"
        +"掲載内容の無断転載・再配布は固く禁じます。\n"
        +"Copyright (C) PayPay Corporation. All Rights Reserved.\n"
        +"========================================================\n";
        
        var commonFooter7 = "本件はPayPay加盟店規約に基づくご対応の依頼となります。\n"
        +"\n"
        +"なお、5営業日以内に本メールへご返信をいただけない場合、PayPay加盟店規約等に基づいた対応をさせていただく場合もございます。\n"
        +"\n"
        +"以上、お手数ではございますが、何卒よろしくお願いいたします。\n"
        +"\n"
        +"========================================================\n"
        +"発行者：PayPay株式会社\n"
        +"掲載内容の無断転載・再配布は固く禁じます。\n"
        +"Copyright (C) PayPay Corporation. All Rights Reserved.\n"
        +"========================================================\n";
        
        var commonFooter8 = "以上、ご確認いただけますようお願いいたします。\n"
        +"\n"
        +"※本メールの内容は事前の書面による許可なく複製、複写、転載、転送することを禁じます。\n"
        +"\n"
        +"========================================================\n"
        +"発行者：PayPay株式会社\n"
        +"掲載内容の無断転載・再配布は固く禁じます。\n"
        +"Copyright (C) PayPay Corporation. All Rights Reserved.\n"
        +"========================================================\n";
        
        var commonFooter9 = "以上、ご確認いただけますようお願いいたします。\n"
        +"\n"
        +"※本メールの内容は事前の書面による許可なく複製、複写、転載、転送することを禁じます。\n"
        +"\n"
        +"========================================================\n"
        +"発行者：PayPay株式会社\n"
        +"掲載内容の無断転載・再配布は固く禁じます。\n"
        +"Copyright (C) PayPay Corporation. All Rights Reserved.\n"
        +"========================================================\n";
        
        var commonFooter10 = "以上、ご確認いただけますようお願いいたします。\n";
        if(cmp.get('v.simpleRecord.toB_SupportEMail__r.InqueryType__c')=='MB停止措置通知'){
            layoutInfo['default'] = {
                'label' : '停止連絡',
                'header' : commonHeader3,
                'footer': commonFooter3
            };
            layoutInfo['ptn3'] = {
                'label' : 'ヒアリング',
                'header' : commonHeader4,
                'footer': commonFooter4
            };
            layoutInfo['ptn4'] = {
                'label' : '停止連絡＆催促メール',
                'header' : commonHeader5,
                'footer': commonFooter5
            };
            layoutInfo['ptn5'] = {
                'label' : 'クローズ＆その他',
                'header' : commonHeader6,
                'footer': commonFooter6
            };
            layoutInfo['ptn6'] = {
                'label' : '再ヒアリング',
                'header' : commonHeader7,
                'footer': commonFooter7
            };
            
        }else if(cmp.get('v.simpleRecord.toB_SupportEMail__r.InqueryType__c')=='上限-法人'||cmp.get('v.simpleRecord.toB_SupportEMail__r.InqueryType__c')=='上限-個人'){
			layoutInfo['default'] = {
                'label' : '可決、否決メール',
                'header' : commonHeader8,
                'footer': commonFooter8
            };
            layoutInfo['ptn8'] = {
                'label' : '返信依頼あり',
                'header' : commonHeader9,
                'footer': commonFooter9
            };
            layoutInfo['ptn9'] = {
                'label' : 'ヒアリングメール',
                'header' : commonHeader10,
                'footer': commonFooter10
            };
        }else{
            layoutInfo['none'] = {
                'label' : '無し',
                'header': '',
                'footer': ''
            };
            layoutInfo['default'] = {
                'label' : '標準',
                'header' : commonHeader1 + commonHeader2,
                'footer': commonFooter1
                + commonFooter2
            };
            layoutInfo['ptn1'] = {
                'label' : '宛名あり（解約用）',
                'header' : commonHeader1
                + "<user_name> 様\n\n"
                + commonHeader2,
                'footer': commonFooter1
                + commonFooter2
            };
        }        return layoutInfo;
    },
    setLayout: function(cmp, ptn) {
		var layoutInfo = cmp.get('v.layoutInfo');
        var header = layoutInfo[ptn]['header'];
        var footer = layoutInfo[ptn]['footer'];

        header = header.replace('<user_name>', 
                       		cmp.get("v.simpleRecord.toB_SupportEMail__r.mpMerchant__r.Name")+"\n"
                            + cmp.get("v.simpleRecord.toB_SupportEMail__r.PayPayMerchantCustomerName__c"));
        /*
        				.replace('<reviewer_name>', cmp.get("v.userRecord.LastName"));
        */
        footer = footer.replace('<id>', cmp.get('v.simpleRecord.toB_SupportEMail__c'));
        
        cmp.set('v.header', header+ ((header != '')? "\n" : ''));
        cmp.set('v.footer', ((footer != '')? "\n\n" : '') + footer);    
	},
    callSendMailAction : function(cmp, helper, recordId, body) {
        $A.createComponent(
            'lightning:quickActionAPI'
            ,{
                'aura:id': 'instantQuickActionAPI',
            }
            ,function(createdQuickActionAPI, status, errorMessage) {
                console.log(status);
                if (status === "SUCCESS") {
                    var entityNm = 'mpComm__c';
                    var actionNm =  'toB_EmailNewReply';
                    var fields = {
                        toB_EMailTextBody__c: {value: body},
                        /*toB_EMailFromAddress__c	: {value: cmp.get('v.simpleRecord.ContactEmail__c')},*/
                    };
                    var args = {actionName :entityNm+'.'+actionNm, entityName: entityNm , targetFields: fields, id:recordId};
                    console.log(fields);
                    console.log(args);
                    createdQuickActionAPI.setActionFieldValues(args).then(function(result){
                    }).catch(function(e){
                        if(e.errors){
                            console.log(e.errors);
                            
                        }
                    });
                }
                else if (status === "INCOMPLETE") {}
                else if (status === "ERROR") {}
            }
        );
    },
})