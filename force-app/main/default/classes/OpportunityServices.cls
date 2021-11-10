/*************************************************************************************************************
 * @name			OpportunityServices
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			14th October 2021
 * @description		To control DML method on the opportunity object
 * @testClass       OpportunityServicesTest
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-14      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/
public without sharing class OpportunityServices {
    
    
    public static List<FlowOutput> createOrUpdateOppFromSalestrekker(List<Opportunity> oppsList){

        List<FlowOutput> oppsListResults = new List<FlowOutput>();
        
        if(oppsList != null && !oppsList.isEmpty()){
            // DML statement
            Database.UpsertResult[] srList = Database.upsert(oppsList, false);
                Integer index = 0; 
                // Iterate through each returned result
                for(Integer i=0;i<srList.size();i++){
                    FlowOutput result= new FlowOutput();
                    result.oppId = oppsList.get(index).Id;                   
                    result.salesTrekkerId = oppsList.get(index).Salestrekker_Deal_Id__c;   
                        
                    if (srList.get(i).isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully create or update opp. Opp ID: ' + srList.get(i).getId());
                        result.success = true;
                       
                    }
                    else {
                        Database.Error err =  srList.get(index).getErrors().get(0);    
                        result.success = false;
                        result.errorMessage = 'Opportunity >> The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage()
                                            +' Opportunity fields that affected this error: ' + err.getFields();
                            
                    }

                    oppsListResults.add(result);
                    index = index + 1;
                }
        }        

        return oppsListResults;    
    }
}