/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Oct 14, 2020
* @description Class to update lookup roll up fields
*
* CHANGE LOG
**/

public class LookupRollupCalculator {

    /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Method to calculate lookup roll up values after lightning process
    **/
    @AuraEnabled
    public static String calculateRollupOfParentRecord(Id parentRecordId){

        if(parentRecordId.getSObjectType() == Advice__c.getSObjectType()){

            Advice__c adviceToUpdate = new Advice__c (Id = parentRecordId);
            //get parent records and update roll up values based on list size from query
            Advice__c adviceWithChildren = [SELECT Id, (SELECT Id FROM Recommendations__r), (SELECT Id FROM KAR__r) FROM Advice__c WHERE Id =: parentRecordId];
            
            adviceToUpdate.Number_of_KARs__c = adviceWithChildren.KAR__r.size();
            adviceToUpdate.Number_of_Recommendations__c = adviceWithChildren.Recommendations__r.size();

            adviceWithChildren = [SELECT Id,  (SELECT Id FROM Recommendations__r WHERE Status__c = 'Complete'), (SELECT Id FROM KAR__r WHERE Status__c = 'Complete') FROM Advice__c WHERE Id =: parentRecordId];

            adviceToUpdate.Number_of_Complete_KARs__c = adviceWithChildren.KAR__r.size();
            adviceToUpdate.Number_of_Complete_Recommendations__c = adviceWithChildren.Recommendations__r.size();

            update adviceToUpdate;

            return 'advice object updated';

        }

        return '';
        
        
    }
}