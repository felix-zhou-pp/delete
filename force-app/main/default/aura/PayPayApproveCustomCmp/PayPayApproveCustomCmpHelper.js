({
    createComponent: function(c, h, componentDef, componentAttributes) {
        return new Promise(function (resolve, reject) {
            $A.createComponent(componentDef, componentAttributes, function(newComponent, status, errorMessage){
                if (status === "SUCCESS") resolve(newComponent);
                else if (status === "ERROR") reject(errorMessage);
            });
        });
    },

    getParameterValue: function(cmp, propName) {
        let returnValue='';
        let receiveAttributes= cmp.get('v.objectFormatParameter');

        if(propName != '_blank' && !receiveAttributes.hasOwnProperty(propName)){
            returnValue='_ignoreProperty';
        }else if(!$A.util.isUndefinedOrNull(receiveAttributes) 
                && $A.util.isObject(receiveAttributes)
                    && receiveAttributes.hasOwnProperty(propName)){
            
            returnValue = receiveAttributes[propName];
        }
        return returnValue=='null' ? '' : returnValue;
    },

    setParametersVaelue: function(cmp, helper, object){

        if(!$A.util.isUndefinedOrNull(object) 
                && $A.util.isObject(object)){

                Object.keys(object).forEach(function(prop, index, propArray){
                    let thisProptyToParamValue = helper.getParameterValue(cmp, prop.toString());
                    if(thisProptyToParamValue=='_ignoreProperty'){
                        delete object[prop.toString()];
                    }else{
                        object[prop].isDisabled = !$A.util.isEmpty(thisProptyToParamValue);
                        object[prop].value = object[prop].isDisabled ? thisProptyToParamValue : object[prop].value;
                    }
                });
        }
        return object;
    },

    bindToTargetSectionFields: function(cmp, fieldsInfo){
        if(!$A.util.isUndefinedOrNull(fieldsInfo) && $A.util.isObject(fieldsInfo)){
            if(!$A.util.isUndefinedOrNull(fieldsInfo.fieldsAndValues)
                    && $A.util.isObject(fieldsInfo.fieldsAndValues)
                        && !$A.util.isUndefinedOrNull(cmp.get('v.'+fieldsInfo.targetFieldsObjectName))){
                cmp.set('v.'+fieldsInfo.targetFieldsObjectName, fieldsInfo.fieldsAndValues);
            }
        }
    },

    dispatchFunctionsBykindCallOut: function(cmp, helper, paramAttr){

        let functionName = paramAttr['functionName'];
        let functionsCmp = cmp.find('PayPayApproveFunctions');

        if(!$A.util.isUndefinedOrNull(functionsCmp)){
            functionsCmp.set('v.functionName', functionName);
            functionsCmp.set('v.material', paramAttr);

            functionsCmp.execAdvancedFunction();
        }
    },

    dispatchFunctionsBykindWithCallBack: function(cmp, helper, paramAttr){
        cmp.set('v.showSpinner', true);

        let functionName = paramAttr['functionName'];
        let functionsCmp = cmp.find('PayPayApproveFunctions');

        if(!$A.util.isUndefinedOrNull(functionsCmp)){
            functionsCmp.set('v.functionName', functionName);
            functionsCmp.set('v.material', paramAttr);

            functionsCmp.execFunction().then(
                    $A.getCallback(function(returnValue) {

                        helper.bindToTargetSectionFields(cmp, returnValue);
                        cmp.set('v.showSpinner', false);
                    })
                ).catch(
                    $A.getCallback(function(reason) {
                        console.error(reason);
                    })
                );
        }

    },

    getDefinitionFieldsByKind: function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);

        let functionsCmp = cmp.find('PayPayApproveFunctions');
        functionsCmp.getDefinitionFields()
                .then($A.getCallback(function(returnValue) {

                    cmp.set('v.standardHeaderFields', returnValue.standardHeader);
                    cmp.set('v.standardDetailFields', returnValue.standardDetail);
                    cmp.set('v.thisKindRelationFields', helper.setParametersVaelue(cmp, helper, returnValue.thisKindRelation));
                    cmp.set('v.thisKindMainFields', returnValue.thisKindMain);

                    cmp.set('v.thisKindAdvancedFunctions', returnValue.thisKindAdvFuncs);

                    cmp.set('v.showSpinner', false);
                }))
                .catch($A.getCallback(function(reason) {
                    console.error(reason);
                }));
    },

})