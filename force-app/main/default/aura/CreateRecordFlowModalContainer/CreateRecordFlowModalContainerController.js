({
    init: function (component) {
        
        var flow = component.find("flowData");
       
        var flowName = component.get("v.flowName");

        var recId = component.get("v.recordId");

        
        var inputVariables = [
          {
            name: "recordId",
            type: "String",
            value: recId
          }
        ];
  
        if (recId) {
          flow.startFlow(flowName, inputVariables);
        } else {
          flow.startFlow(flowName);
        }

        console.log('flow run');

        
    },
    handleStatusChange : function (component, event) {
          console.log("outhandleStatusChangeputVal");
        var redirectToCreatedRecord = component.get("v.redirectToCreatedRecord");
        console.log("redirectToCreatedRecord " + redirectToCreatedRecord);
         var recId = component.get("v.recordId");
        if(event.getParam("status") === "FINISHED" && redirectToCreatedRecord) {

            // Get the output variables and iterate over them
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            var outputVariableName = component.get("v.createdRecordIdVariableName");
            var outputVal;

            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                if(outputVar.name === outputVariableName) {
                outputVal = outputVar.value;
                break;     
                } 
            }

            if(outputVal){
              var toastEvent = $A.get("e.force:showToast");

              toastEvent.setParams({
                title: "Success!",
                mode: 'sticky',
                message: "Advice created successfully!",
                messageTemplate: "Advice created successfully! Click {1} to view",
                type: "success",
                duration: 9500,
                messageTemplateData: ['Advice', {
                          url: '/'+outputVal,
                          label: 'this',
                          }
                ]
              });

              toastEvent.fire();

              var workspaceAPI = component.find("workspace");

                workspaceAPI.openTab({
                    url: "/lightning/r/"+recId+"/view",
                    focus: true
                  })
                  .then(function (response) {
                    workspaceAPI.openSubtab({
                      parentTabId: response,
                      url: "/lightning/r/"+outputVal+"/view",
                      focus: true
                    });
                  })
                  .catch(function (error) {
                    console.log(error);
                  });

              /*var redirectToNewRecord = $A.get("e.force:navigateToSObject");

              redirectToNewRecord.setParams({
                recordId: outputVal,
                slideDevName: "related"
              });

              console.log("outputVal" + outputVal);

              redirectToNewRecord.fire();*/

              $A.get("e.force:closeQuickAction").fire();
            }
        }
    }

});