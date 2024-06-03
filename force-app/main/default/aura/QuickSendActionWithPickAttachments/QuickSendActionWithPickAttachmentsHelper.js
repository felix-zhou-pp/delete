({
	availableActionFields : function( cmp, event, helper) {
        var actionAPI = cmp.find("quickActionAPI");
        var entityNm = cmp.get("v.entityName");
        var actionNm =  cmp.get("v.actionApiName");
        var docList = cmp.get("v.lstContentDoc");
        
        var docIdsArray = [];
        docList.forEach(function(doc) {
            docIdsArray.push(doc.ContentDocumentId);
        });

        var fields = {ContentDocumentIds:{value:docIdsArray},};
        var args = {actionName :entityNm+"."+actionNm, entityName: entityNm , targetFields: fields};

        actionAPI.setActionFieldValues(args).then(function(result){
            if(result.success){}
        }).catch(function(e){
            if(e.errors){
                console.error(e.errors);
            }
        });
    },
})