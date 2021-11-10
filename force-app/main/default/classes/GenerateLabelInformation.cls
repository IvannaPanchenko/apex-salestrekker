/*************************************************************************************************************
 * @name			GenerateLabelInformation
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			14th October 2021
 * @description		Invocable Class to create a list of label information returning recordtype id for the opp
 * @testClass       GenerateLabelInformationTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-14      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/

public without sharing class GenerateLabelInformation {

    @InvocableMethod(label='Get Labels Information' description='Returns the list of result with labels information.')
    public static  List<ResultOutput> getLabelsIdsList(List<Input>  inputs){
        List<ResultOutput> outputList = new List<ResultOutput>();
        if(!inputs.isEmpty()){
        
            String ids = inputs.get(0).labelsIds;
 
             List<String> labelsIdsSplitted = ids.split(',');
            List<FlowOutput> listOutput = new List<FlowOutput>();

            //Retrieve the name by Ids
            Salestrekker_Label__mdt[] salesTrekkerLabels = [SELECT MasterLabel, Label_Name__c, RecordTypeId__c, Opportunity_Type__c
                                                            FROM Salestrekker_Label__mdt 
                                                            WHERE Label_Id__c IN: labelsIdsSplitted];
           FlowOutput output;
           List<String>providerLabels = new List<String>();
           List<FlowOutput> outputs = new List<FlowOutput>();
            for (Salestrekker_Label__mdt labelsMt : salesTrekkerLabels) {
                output = new FlowOutput();
                output.RecordTypeId = labelsMt.RecordTypeId__c;
                output.oppType = labelsMt.Opportunity_Type__c;
                output.labelName = labelsMt.Label_Name__c;
                // those labels without record type are providers
                if(String.isBlank(labelsMt.RecordTypeId__c)){
                    providerLabels.add(labelsMt.Label_Name__c);
                }
                
                outputs.add(output);
            }
    
            String providerNames = !providerLabels.isEmpty()? String.join(providerLabels, ';'):''; 
            outputList.add(new ResultOutput(outputs, providerNames));

            return outputList;
        } else return null;
    }

    public class Input{
        @InvocableVariable(Required=true Label='Labels Ids' Description='Labels Id not splitted')
        public String labelsIds;
    }

    public class ResultOutput{
        @InvocableVariable(Label='flowsOutput' Description='flowsOutput')
         public List<FlowOutput> flowsOutput;

         @InvocableVariable(Label='providers names' Description='providers names')
         public String providerNames;
         public ResultOutput (List<FlowOutput> outputs, String providerNames){
             flowsOutput = outputs;
             this.providerNames = providerNames;
         }
     }
}