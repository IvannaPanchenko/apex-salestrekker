/**
* @author Jacob Taljaard (jacob@cloudinit.nz)
* @date Oct 26, 2018
* @description Trigger handler for account trigger - for looking up and creating customer provider numbers
*
* CHANGE LOG
* Oct 26, 2018 - Initial setup (jacob@cloudinit.nz)
**/
public without sharing class ProviderCustomerHelper {
    
    public static Map<String,Advisor_Agency_Codes__c> getAdviserAgencyCodes(List<String> AdviserCodes) {
        System.debug('***** getAdviserAgencyCodes ' + AdviserCodes);
        Map<String,Advisor_Agency_Codes__c> result = new Map<String,Advisor_Agency_Codes__c>{};
        Advisor_Agency_Codes__c[] advisercodeslist = [Select Id, Name,Provider__c,External_Id__c,Company__c,Advisor__c From  Advisor_Agency_Codes__c where External_Id__c in :AdviserCodes];
        System.debug('***** getAdviserAgencyCodes advisercodeslist ' + advisercodeslist);
        for (Advisor_Agency_Codes__c adviserCode : advisercodeslist) {
            System.debug('***** getAdviserAgencyCodes External_Id__c ' + adviserCode.External_Id__c);
            System.debug('***** getAdviserAgencyCodes adviserCode ' + adviserCode);
            result.put(adviserCode.External_Id__c,adviserCode);
        }
        System.debug('***** getAdviserAgencyCodes result ' + result);
        return result;
    }

    public static Map<String,Customer_Provider_Code__c> getProviderCustomerNumbers(List<String> ProviderCustomerNumbers) {

        Map<String,Customer_Provider_Code__c> result = new Map<String,Customer_Provider_Code__c>{};

        for (Customer_Provider_Code__c c : [select Id, Customer__c,Ext_Id__c from Customer_Provider_Code__c where Ext_Id__c in :ProviderCustomerNumbers]) {
            result.put(c.Ext_Id__c.toUpperCase(),c);
        }

        return result;
    }

}