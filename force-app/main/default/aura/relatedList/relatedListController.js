({
    //Add
    handleAdd : function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    //Flow Status Change
    statusChange : function (component, event, helper) {

        var action = component.get("c.calculateRollupOfParentRecord");
        action.setParams({ parentRecordId : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            component.refMethod();
        });

        $A.enqueueAction(action);

        var toastEvent = $A.get("e.force:showToast");

        if (event.getParam('helpText') && event.getParam('helpText').indexOf('Flow_Error') !== -1) {
            component.set('v.flowError', true);
        }

        //Check Flow Status
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            if (!component.get('v.flowError')) {
                toastEvent.setParams({
                    title: "Success!",
                    message: `${component.get('v.customTitle') || 'Record'} Added successfully!`,
                    type: "success"
                });
            }
            
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire();
        component.find("enhancedRelatedList").forceRefresh();

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
       component.find("enhancedRelatedList").forceRefresh();
    },
    refreshFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            console.log('ref');
            workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
        })
        .catch(function(error) {
            console.log(error);
        });
    }
        
})