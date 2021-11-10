({
    handleButtonPressed : function(component, event, helper) {
        component.set('v.isOpen', true);
    },
    //Flow Status Change
    statusChange : function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");

        if (event.getParam('helpText') && event.getParam('helpText').indexOf('Flow_Error') !== -1) {
            component.set('v.flowError', true);
        }

        //Check Flow Status
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            if (!component.get('v.flowError')) {
                toastEvent.setParams({
                    title: "Success!",
                    message: `Recipients Saved successfully!`,
                    type: "success"
                });
            }

            $A.get("e.force:closeQuickAction").fire();
            component.set("v.isOpen", false);
        } else if (event.getParam('status') === "ERROR") {
            toastEvent.setParams({
                title: "Error!",
                message: "ERROR when executing the flow",
                type: "error"
            });

            $A.get("e.force:closeQuickAction").fire();
            component.set("v.isOpen", false);
        }
        toastEvent.fire();
    },
    closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
     }
})