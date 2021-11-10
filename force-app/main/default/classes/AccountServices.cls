/*************************************************************************************************************
 * @name			AccountServices
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			14th October 2021
 * @description		To control DML method on the opportunity object
 * @testClass       AccountServicesTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-14      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/
public without sharing class AccountServices {
        
    public static FlowOutput upsertAccountFromSalestrekker(Account account){

        FlowOutput result = new FlowOutput();
     

        // It would be only one at time
        if(account != null){
            // DML statement
            //account.Name =  account.FirstName +' '+  account.LastName;
            
            Database.UpsertResult sr = Database.upsert(account, false);
                         
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    result.accountId = sr.getId();
                    result.salesTrekkerContactId = account.Salestrekker_Contact_Id__c;
                    result.success = true;
                }
                else {
                    Database.Error err =  sr.getErrors().get(0);    
                    result.success = false;
                    result.errorMessage = 'Account >> The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage()
                                            +' Account fields that affected this error: ' + err.getFields();
                }
        }

        return result; 
        }        

}