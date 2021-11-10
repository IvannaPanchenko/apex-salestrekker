/**
* @author Pablo Martinez (pablomartinex@deloitte.co.nz)
* @date 05/07/2019
* @description Trigger handler for liability role trigger.
*
* CHANGE LOG
**/
public with sharing class LiabilityRoleTriggerHandler {
    
    /**
    *   @author DPablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to assign Owner based on the Customer Number
    **/
    public static void linkPrimaryOwner(List<Liability_Role__c> roles) {

        Set<String> customerNumbers = new Set<String>();

        // Loop through roles to get the customer numbers
        for (Liability_Role__c role : roles) {

            if (String.isNotBlank(role.Customer_Number__c)) {
                // Add customer number
                customerNumbers.add(
                    role.Customer_Number__c.toUpperCase()
                );
            }

        }

        Map<String, Customer_Provider_Code__c> customerNumberMap = new Map<String, Customer_Provider_Code__c>();
        
        if (!customerNumbers.isEmpty()) {
            customerNumberMap = ProviderCustomerHelper.getProviderCustomerNumbers(
                new List<String>(customerNumbers)
            );
        }
        
        
        // Loop through roles to assign owner
        for (Liability_Role__c role : roles) {

            String key = String.isNotBlank(role.Customer_Number__c) ?
                            role.Customer_Number__c.toUpperCase() : '';

            if (customerNumberMap.containsKey(key)) {
                // Assign owner based on the customer provider code
                role.Account__c = customerNumberMap.get(key).Customer__c;
                role.Customer_Number__c = null;

            }

        }
    }
}