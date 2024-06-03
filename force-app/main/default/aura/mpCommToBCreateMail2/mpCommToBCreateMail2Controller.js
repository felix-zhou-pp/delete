({
    doInit : function(cmp, event, helper) {
        console.log('Init2');
        cmp.set('v.subject', '');
        cmp.set('v.body', '');
        cmp.set('v.header', '');
        cmp.set('v.footer', '');
        cmp.set('v.index', 0);

        cmp.set("v.folderDeveloperName", "");

        var layoutInfo = helper.getLayoutInfo(cmp);
        var layoutList = [];
        for (var key of Object.keys(layoutInfo)) {
            layoutList.push({'label': layoutInfo[key]['label'], 'value': key});
        }
        cmp.set("v.layoutInfo", layoutInfo);
        cmp.set("v.layoutList", layoutList);
        helper.setLayout(cmp, 'default');

        var folderDeveloperName = '';
        switch (cmp.get('v.simpleRecord.toB_SupportEMail__r.InqueryType__c')) {
             case '途上審査':
	            folderDeveloperName = 'mp5';
                break;
            case '上限':
	            folderDeveloperName = 'mp7';
                break;
            case '上限-個人':
	            folderDeveloperName = 'mp7';
                break;
            case '上限-法人':
	            folderDeveloperName = 'mp7';
                break;
            case 'MB停止措置通知':
	            folderDeveloperName = 'mp6';
                break;
        }
        cmp.set("v.folderDeveloperName", folderDeveloperName);
    },
    next : function(cmp, event, helper) {
        event.preventDefault();
        cmp.set("v.index", Math.min(2, cmp.get("v.index") + 1));
    },
    prev : function(cmp, event, helper) {
        event.preventDefault();
        cmp.set("v.index", Math.max(0, cmp.get("v.index") - 1));
    },
    setIndex : function(cmp, event, helper) {
        event.preventDefault();
        cmp.set("v.index", Math.max(0, Math.min(2, event.currentTarget.dataset.index)));
    },
    handleTemplateSelected : function(cmp, event, helper) {
        var body = '';
        var subject = [];
        var checkCnt = 0;
        if (event.getParam('selectedMail')) {
            for (let info of event.getParam('selectedMail')) {
                checkCnt++;
                subject.push(info.subject);
                //body += "\n＜＜＜＜＜＜確認事項" + checkCnt + "＞＞＞＞＞＞\n"+info.body + "\n";
                body += info.body + "\n";
            }
        }
        if (checkCnt > 0) {
            body = "下記、確認事項"+checkCnt+"点をご確認ください。\n"
            	+ body;
        }
        cmp.set('v.body', body);
        cmp.set('v.subject', subject.join('/'));
	},
    handleLayoutSelected: function(cmp, event, helper) {
        var ptn = event.getSource().get('v.value');
        helper.setLayout(cmp, ptn);
    },
    handleComplete: function(cmp, event, helper) {
        var today = new Date();
        var day = today.getFullYear() + "/" +  ('' + (today.getMonth() + 1)).padStart(2, '0') + "/"+ ('' + today.getDate()).padStart(2, '0');
        helper.callSendMailAction(cmp, helper, cmp.get('v.simpleRecord.toB_SupportEMail__c'),
                                        cmp.get('v.header')
                                        +cmp.get('v.body')
                                        +cmp.get('v.footer'));
    },
})