({
    init: function(cmp, event, helper) {

        cmp.set('v.thisComponentType', cmp.getType());
        cmp.set('v.recordTypeId', helper.getParameterValue(cmp, 'recordTypeId'));
        cmp.set('v.parameterKind', helper.getParameterValue(cmp, 'Kind__c'));
        cmp.set('v.createdObjectName', helper.getParameterValue(cmp, 'createdObject__c')); // 作成元オブジェクト
        
        helper.getDefinitionFieldsByKind(cmp, event, helper);
    },

    closeModal: function(cmp, event, helper){
        cmp.set('v.showSpinner', false);
        var parentModalCloseEvent = cmp.getEvent('parentModalClose');
        parentModalCloseEvent.fire();
    },

    handleAdvancedFuncPress: function(cmp, event, helper){
        
        let functionName = event.getSource().get('v.name');
        let section = event.getSource().get('v.value');
        let pramFields = cmp.get('v.'+section);
        let paramAttr= {
            'functionName': functionName,
            'section': section,
            'fieldsAndValues': pramFields,
        };
    
        helper.dispatchFunctionsBykindCallOut(cmp, helper, paramAttr);

    },
    handleAdvFuncProcEnd: function(cmp, event, helper){
        if(cmp.getType() != event.getParam('type')) return;
        //CallOut or CallBack
        switch( event.getParam('message') ) {
            case 'CallBack':
                //
                break;
                
            case 'CallOut':
                helper.bindToTargetSectionFields(cmp, event.getParam('attributes'));
                break;

            default:
                break;
        }

        
    },
    
    handleFieldChange: function(cmp, event, helper){
        if(cmp.getType() != event.getParam('type')) return;

        //CallOut or CallBack
        switch( event.getParam('message') ) {
            case 'CallBack':
                helper.dispatchFunctionsBykindWithCallBack(cmp, helper, event.getParam('attributes'));
                break;
                
            case 'CallOut':
                helper.dispatchFunctionsBykindCallOut(cmp, helper, event.getParam('attributes'));
                break;

            default:
                break;
        }

    },
    
    handleLoad: function(cmp, event, helper) {},
    handleSubmit: function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);

        event.preventDefault();
        let fields = event.getParam('fields');

        fields.PayPayMaster__c=cmp.get('v.userInfoView').mpMasterId__c;
        cmp.find('customRecordEdit').submit(fields);
    },
    handleSuccess: function(cmp, event, helper) {

        cmp.set('v.showSpinner', true);

        var insertedRecord = JSON.parse(JSON.stringify(event.getParam('response')));
        var navService = cmp.find("navService");
        navService.navigate({
            'type': 'standard__recordPage',
            'attributes': {
                'recordId': insertedRecord.id,
                'objectApiName': cmp.get('v.objectApiName'),
                'actionName': 'view'
            }
        });

        var parentModalCloseEvent = cmp.getEvent('parentModalClose');
        parentModalCloseEvent.fire();

        cmp.set('v.showSpinner', false);

    },
    handleError: function(cmp, event, helper) {
        console.log('onError');
        console.log(event.getParams());
        cmp.set('v.showSpinner', false);
    },






//↓↓ TEST Code

    test_GetUserInfo: function(cmp, event, helper){
        // cmp.find("userInfo").getUserInfo()
        //     .then($A.getCallback(function(userinfo) {
        //         console.log(userinfo.Name);
        //     })).catch(function(reason) {
        //         console.error(reason);
        //     });
    },
    
})