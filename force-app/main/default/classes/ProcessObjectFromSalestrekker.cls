/*************************************************************************************************************
 * @name			ProcessObjectFromSalestrekker
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			14th October 2021
 * @description		Generate a list of result if the records (opp or account) that are success or failing 
 * @testClass       ProcessObjectFromSalestrekkerTest
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-14      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/
public without sharing class ProcessObjectFromSalestrekker {

    @InvocableMethod(label='Process Object From Salestrekker' description='Return a list objects (opp or account) success or failing when it were created or updated')
    public static List<ResultOutput> processObjectFromSalestrekker(List<FlowInput>  inputs){
        List<ResultOutput> outputList = new List<ResultOutput>();
        if(!inputs.isEmpty()){
            List<Opportunity> oppsList = inputs.get(0).oppsToBeCreated;
            Account account = inputs.get(0).accountToBeCreatedOrUpdated;
            String objectName = inputs.get(0).objectName;
            if('Opportunity'.endsWithIgnoreCase(objectName)){
                 // call the services
                outputList.add(new ResultOutput (Opportunityservices.createOrUpdateOppFromSalestrekker(oppsList)));
              
            }else if('Account'.endsWithIgnoreCase(objectName)){
                // call the services
                List<FlowOutput> accOutputList = new List<FlowOutput> ();
                accOutputList.add(AccountServices.upsertAccountFromSalestrekker(account));
                System.debug('############ Account Id '+ accOutputList);
                outputList.add(new ResultOutput (accOutputList));
            }
           
        }

        return outputList;
    }

    public class FlowInput{
        @InvocableVariable(Label='Opportunities to be created' Description='Opportunities to be Created')
        public List<Opportunity> oppsToBeCreated;
        
        @InvocableVariable( Label='Accout to be created or updated' Description='Account to be Created created')
        public Account accountToBeCreatedOrUpdated;

        @InvocableVariable( required= true Label='Object Name DML' Description='Account or Opportunity to update or insert the database')
        public String objectName;
    }

    public class ResultOutput{
       //Only for Opportunity
       @InvocableVariable(Label='flowsOutput' Description='flowsOutput')
        public List<FlowOutput> flowsOutput;
        public ResultOutput (List<FlowOutput> outputs){
            flowsOutput = outputs;
        }
    }
}