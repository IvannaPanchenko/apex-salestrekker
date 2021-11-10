/**
* @author Ben Edwards (beedwards@deloitte.co.nz)
* @date 13th November 2020
* @description Controller for the Flow Picklist
*
* CHANGE LOG
**/
public with sharing class AssetLiabilityPicklistController {
    
    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getPicklistOptions (Id accountId, Id partnerId, String objectName) {

        Map<String, PicklistOption> picklistOptions = new Map<String, PicklistOption>();

        for (SObject record :Database.query(getQuery(accountId, partnerId, objectName))) {

            // Retrieve the record id from the lookup field
            String recordId = String.valueOf(record.get(objectName));

            picklistOptions.put(
                recordId,
                new PicklistOption(
                    recordId,
                    String.valueOf(record.get('KAR_Flow_Picklist_Names__c'))
                )
            );
        }

        return picklistOptions.values();
    }

    // Generate the query to retrieve Asset or Liability objects
    public static String getQuery (Id accountId, Id partnerId, String objectName) {

        String query = 'SELECT ' + objectName +  ',KAR_Flow_Picklist_Names__c';
        query += ' FROM ' + objectName.removeEnd('__c') + '_Role__c';
        query += ' WHERE Account__c = :accountId';

        if (String.isNotBlank(partnerId)) {
            query += ' OR Account__c = :partnerId';
        }
        
        return query;
    }

    public class PicklistOption {

        @AuraEnabled
        public String value {get; set;}

        @AuraEnabled
        public String label {get; set;}

        public PicklistOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}