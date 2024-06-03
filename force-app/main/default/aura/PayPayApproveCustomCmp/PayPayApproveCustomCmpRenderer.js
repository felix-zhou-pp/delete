({

    afterRender: function (cmp, helper) {
        this.superAfterRender();
        cmp.set('v.showSpinner', false);
    }

})