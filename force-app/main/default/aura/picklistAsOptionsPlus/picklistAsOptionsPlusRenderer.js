({
    rerender: function (component, helper) {
        this.superRerender();
        // interact with the DOM here
        if (component.get("v.isOpen")) {
            // Custom Button 1
            if (component.get("v.flowAPIName")) {
                var inputVariables = [
                    {
                        name : "recordId",
                        type : "String",
                        value : component.get("v.recordId")
                    }
                ];

                // if we have variables values then add it to the inputvariables
                var variableValues = component.get("v.flowVariableValues");

                if (variableValues) {
                    variableValues.split(',').forEach((value) => {
                        inputVariables.push({
                            name: value.split(':')[0],
                            type: "String",
                            value: value.split(':')[1]
                        });
                    });
                }

                var flow = component.find("callFlow");
                flow.startFlow(component.get("v.flowAPIName"), inputVariables);
            }
        }
    },
        
})