/**
* @description Trigger for Customer Adviser Relationship
*
* CHANGE LOG
**/
trigger CustomerAdviserRelationshipTrigger on Customer_Adviser_Relationship__c (after insert,after update) {

    if(trigger.isAfter)
    {
        if(trigger.isInsert || trigger.isUpdate) {

            List<String> ProviderCustomerNumbers = new List<String>();
            List<String> AdviserAgencyCodeList = new List<String>();
            
            for(Customer_Adviser_Relationship__c b : trigger.new) {
                
                if (!String.isEmpty(b.Provider_Customer_Number__c)) {
                    
                    ProviderCustomerNumbers.add(b.Provider_Customer_Number__c.toUpperCase());
                    AdviserAgencyCodeList.add(b.Adviser_Agency_Code__c);
                    
                }
            }
            
            Map<String, Customer_Provider_Code__c> ProviderCustomerNumberMap = ProviderCustomerHelper.getProviderCustomerNumbers(ProviderCustomerNumbers);
            Map<String, Advisor_Agency_Codes__c> AdviserAgencyCode = ProviderCustomerHelper.getAdviserAgencyCodes(AdviserAgencyCodeList);
            Map<String, Account> AccountsToUpdate = new Map<String, Account>(); // Changed by David Catindoy - Feb 14, 2019 - Change to map to avoid 'System.ListException: Duplicate id in list: 001XXXXXXXXXXXX' error

            if(AdviserAgencyCode.size() > 0) {
                
                for(Customer_Adviser_Relationship__c b : trigger.new){
                    
                    if(!String.isEmpty(b.Provider_Customer_Number__c)){
                        
                        if(ProviderCustomerNumberMap.containsKey(b.Provider_Customer_Number__c.toUpperCase())){
                            
                            Account ToUpdate = new Account();
                            ToUpdate.Id = ProviderCustomerNumberMap.get(b.Provider_Customer_Number__c.toUpperCase()).Customer__c;
                            ToUpdate.Advisor_Agency_Code__c = AdviserAgencyCode.get(b.Adviser_Agency_Code__c).Id;
                            AccountsToUpdate.put(ToUpdate.Id, ToUpdate);
                            
                        }
                    }
                }
            }


            if(AccountsToUpdate.size() > 0){
                update AccountsToUpdate.values();
            }
            
            // Delete the Customer_Adviser_Relationship__c records
            List<Customer_Adviser_Relationship__c> toDeleteList = new List<Customer_Adviser_Relationship__c>();
            
            for(Customer_Adviser_Relationship__c r : trigger.new){
                Customer_Adviser_Relationship__c toDelete = new Customer_Adviser_Relationship__c();
                toDelete.Id = r.Id;
                toDeleteList.add(toDelete);
            } 
            
            if(toDeleteList.size() > 0) {
                delete toDeleteList;
            }
        }
    }
}