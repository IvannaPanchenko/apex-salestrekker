({
    //Add
    handleCallFlow : function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    //Flow Status Change
    statusChange : function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");

        //Check Flow Status
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            $A.get("e.force:closeQuickAction").fire();
            component.set("v.isOpen", false);
            $A.get('e.force:refreshView').fire();
        } else if (event.getParam('status') === "ERROR") {
            toastEvent.setParams({
                title: "Error!",
                message: "ERROR when executing the flow",
                type: "error"
            });

            $A.get("e.force:closeQuickAction").fire();
            component.set("v.isOpen", false);
            $A.get('e.force:refreshView').fire();
        }
        toastEvent.fire();
    },
    closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
    }
})