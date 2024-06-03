({
    createdActivityPanel: function( cmp, event, helper ){
        
        $A.createComponent("runtime_sales_activities:activityPanel", { recordId: cmp.get('v.recordId') }, function (c, status, message) {
            if (status === "SUCCESS") {
                cmp.set("v.body", c);
                cmp.set("v.showCreateButton", false);
                helper.availableActionFields(cmp, event, helper);
            }else{
                reject(message);
            }
        });
    },
    closeActivityPanel: function( cmp, event, helper ){
        cmp.set("v.body", null);
        cmp.set("v.showCreateButton", true);
    }
})