/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Nov 3, 2020
* @description Trigger handler for advice trigger
*
* CHANGE LOG
**/
public class    AdviceTriggerHandler extends TriggerHandler {

    public List <Advice__c> newAdvices {
        get {
            return (List <Advice__c> ) Trigger.new;
        }
        private set;
    }

    public Map <Id, Advice__c> newAdvicesMap {
        get {
            return (Map <Id, Advice__c> ) Trigger.newMap;
        }
        private set;
    }

    public Map <Id, Advice__c> oldAdvicesMap {
        get {
            return (Map <Id, Advice__c> ) Trigger.oldMap;
        }
        private set;
    }

    public override void beforeInsert() {
        getUnselectedServiceFromFactFind(newAdvices);
    }

    public override void beforeUpdate(){
        prepareRationaleText(newAdvices,oldAdvicesMap);
    }

    public override void afterInsert() {
        addFactFindItems(newAdvicesMap);
    }

    private static void prepareRationaleText(List <Advice__c> newAdvices, Map<Id,Advice__c> oldAdvicesMap){

        List<Advice__c> affectedAdviceRecords = new List<Advice__c>();

        for(Advice__c adv : newAdvices){

            if(adv.Providers__c != oldAdvicesMap.get(adv.Id).Providers__c){
                affectedAdviceRecords.add(adv);
            }

        }

        if(affectedAdviceRecords.isEmpty()) return;
        
        Map<String, String> providerRationalesMap = new Map<String,String>();

        List<Provider_Rationale__mdt> providerRationales = [SELECT Id, MasterLabel, DeveloperName, Description__c FROM Provider_Rationale__mdt];

        for(Provider_Rationale__mdt pr : providerRationales){
            providerRationalesMap.put(pr.MasterLabel, pr.Description__c);
        }
 
        for(Advice__c adv : affectedAdviceRecords){

            if(String.isBlank(adv.Providers__c)) adv.Provider_Rationale__c = '';
            else{
                adv.Provider_Rationale__c = generateText(adv.Providers__c.split(';'), providerRationalesMap);
            }

        }
    }

    private static String generateText(List<String> providers, Map<String, String> providerRationalesMap){
        
        List<String> rationales = new List<String>();

        for(String provider : providers){

            if(providerRationalesMap.containsKey(provider)){
                String description = providerRationalesMap.get(provider);

                rationales.add(String.format(Label.Provider_Rationale_Template_Text, new List<Object>{provider, provider, description}));
            }

        }

        return String.join(rationales,'<br/><br/>');
    }

      /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Create KAR records from Fact Find Items 
    **/
   private static void addFactFindItems (Map <Id, Advice__c> newAdvicesMap) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Set<Id>> itemsByAccountId = new Map<Id, Set<Id>>();
        Map<Id, String> mapAccountNameById = new Map<Id, String>();
        Map<Id, Id> couplesMapping = new Map<Id, Id>();
        List<KAR__c> listKarToInsert = new List<KAR__c>();

        // get the advice records with the related opportunity fields that we need
        List<Advice__c> listAdvices = [
            SELECT Id, Opportunity__c,
                   Opportunity__r.AccountId, Opportunity__r.Account.Partner__c
            FROM Advice__c
            WHERE Id IN :newAdvicesMap.keySet()
        ];

        // for each advice record get the account ids that we need
        for (Advice__c advice : listAdvices) {
            accountIds.add(advice.Opportunity__r.AccountId);

            // if we have a partner add to the set
            if (advice.Opportunity__r.Account.Partner__c != null) {
                accountIds.add(advice.Opportunity__r.Account.Partner__c);
            }
        }

        // get the children of the accounts
        for (Relationship__c relationship : FactFindingControllerSelector.getRelationshipsByAccountIdsAndType(accountIds, new Set<String>{ 'Child' })) {
            accountIds.add(relationship.Related_Account__c);
        }

        // get the account records with the policies and the non apex cover records
        Map<Id,Account> acctMap = new Map<Id,Account>([
            SELECT Id, Name,
                   (SELECT Id FROM Non_Apex_Cover__r), 
                   (SELECT Policy__c, Policy__r.Premium_Frequency__c, Policy__r.Provider_Name_Formula__c, Benefit_Premium_Formula__c FROM Policy_Benefits__r WHERE Policy__r.Policy_Status__c = 'Existing' AND Status__c = 'Existing')
            FROM Account
            WHERE Id IN: accountIds
        ]);

        List<Policy_Benefit__c> listPolicyBenefits = new List<Policy_Benefit__c>();

        // for each account
        for (Account acct : acctMap.values()) {
            // collect items
            Set<Id> itemIds = new Set<Id>();

            // add the name to the map
            mapAccountNameById.put(acct.Id, acct.Name);

            // add all the non apex cover
            itemIds.addAll(new Map<Id,Non_Apex_Cover__c>(acct.Non_Apex_Cover__r).keySet());

            // add all the benefits
            itemIds.addAll(new Map<Id,Policy_Benefit__c>(acct.Policy_Benefits__r).keySet());
            listPolicyBenefits.addAll(acct.Policy_Benefits__r);

            // create the map if we don't have it
            if (!itemsByAccountId.containsKey(acct.Id)) {
                itemsByAccountId.put(acct.Id, new Set<Id>());
            }

            // add the items to the map
            itemsByAccountId.get(acct.Id).addAll(itemIds);
        }

        // build the map of benefits
        Map<Id, Policy_Benefit__c> mapPolicyBenefitById = new Map<Id, Policy_Benefit__c>();
        if (listPolicyBenefits.size() > 0) {
            for (Policy_Benefit__c benefit : listPolicyBenefits) {
                if (!mapPolicyBenefitById.containsKey(benefit.Id)) {
                    mapPolicyBenefitById.put(benefit.Id, benefit);
                }
            }
        }

        // get the record type ids
        Id nonApexRTID = Schema.SObjectType.KAR__c.getRecordTypeInfosByName().get('Non Apex Cover').getRecordTypeId();
        Id policyRTID = Schema.SObjectType.KAR__c.getRecordTypeInfosByName().get('Policy').getRecordTypeId();

        // for each advice
        for(Advice__c advice : listAdvices) {
            // for each account of the map
            //Assign order to new Kar record
            Integer order = 0;
            for (Id acctId : itemsByAccountId.keySet()) {            
                // for each item Id, create a KAR record
                for (Id itemId : itemsByAccountId.get(acctId)) {
                    //prepare KAR record and correct field values
                    KAR__c karRecord = new KAR__c();
                    
                    // get the object name from the id (could be Policy_Benefit__c or Non_Apex_Cover__c)
                    String objName = String.valueOf(itemId.getSObjectType());

                    // variables to set
                    Id recordTypeId;
                    String lookupFieldName;
                    String frequency;
                    String providerName;
                    Decimal benefitPremium;
                    order = order + 1;

                    // different lookup field name and record type per object
                    switch on objName {
                        when 'Non_Apex_Cover__c' {
                            recordTypeId = nonApexRTID;
                            lookupFieldName = 'Non_Apex_Cover__c';
                            frequency = 'Monthly';
                        }
                        when 'Policy_Benefit__c' {
                            recordTypeId = policyRTID;
                            lookupFieldName = 'Policy_Benefit__c';
                            frequency = mapPolicyBenefitById.containsKey(itemId) ? mapPolicyBenefitById.get(itemId).Policy__r.Premium_Frequency__c : 'Monthly';
                            providerName = mapPolicyBenefitById.containsKey(itemId) ? mapPolicyBenefitById.get(itemId).Policy__r.Provider_Name_Formula__c : null;
                            benefitPremium = mapPolicyBenefitById.containsKey(itemId) ? mapPolicyBenefitById.get(itemId).Benefit_Premium_Formula__c : null;
                        }
                    }

                    // if we have a record type id, add the other fields and add to the list for insert
                    if (String.isNotBlank(recordTypeId)) {
                        karRecord.put('Advice__c', advice.Id);
                        karRecord.put(lookupFieldName, itemId);
                        karRecord.put('RecordTypeId', recordTypeId);
                        karRecord.put('Who_pays_for__c', 'Product Provider');
                        karRecord.put('Frequency__c', frequency);
                        karRecord.put('For__c', mapAccountNameById.get(acctId));
                        karRecord.put('Provider_Name__c', providerName);
                        karRecord.put('Before__c', benefitPremium);
                        karRecord.put('Order__c', order);
                        karRecord.put('Approach__c','Keep');
                        
                        
                        // add to the list
                        listKarToInsert.add(karRecord);
                    }
                }
            }
        }

        // insert the list only if we have something
        if (listKarToInsert.size() > 0) {
            insert listKarToInsert;
        }
    }

    /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Find unselected services and create a list for the advice record
    **/
    public static List<Advice__c> getUnselectedServiceFromFactFind(List <Advice__c> newAdvices){
        Set<Id> opportunityIds = new Set<Id>();

        for(Advice__c advice : newAdvices){
            opportunityIds.add(advice.Opportunity__c);
        }
       //get opportunity records with the service values
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Services__c FROM Opportunity WHERE Id IN: opportunityIds]);
        //get picklist values and see which ones werent selected
        Schema.DescribeFieldResult fieldResult = Opportunity.Services__c.getDescribe();
        List<Schema.PicklistEntry> pleList = fieldResult.getPicklistValues();
        Set<String> services = new Set<String>();

        for(Schema.PicklistEntry ple : pleList){
            services.add(ple.getLabel().toLowerCase());
        }

        for(Advice__c advice : newAdvices){

            String servicesStr = oppMap.get(advice.Opportunity__c).Services__c;
            
            if(servicesStr == null){
                servicesStr = '';
            } 
            else{
                servicesStr = servicesStr.toLowerCase();
            }
            //find unselected services and prepare a list 
            Set<String> values = getUnselectedValues(servicesStr.split(';'), services);
            //put list on advice field
            advice.Areas_of_Advice_Not_Covered__c = prepareUnselectedValuesLongText(values);
        }

        return newAdvices;

    }

     /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Find unselected services values
    **/
    private static Set<String> getUnselectedValues(List<String> selectedValues, Set<String> values){

        Set<String> unselectedValues = new Set<String>();

        for(String val : values){
            //compare to find unselected values
            if(!selectedValues.contains(val)){
                unselectedValues.add(val);
            }
        }

        return unselectedValues;
    }

     /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Prepare list of unselected values in the form of a string
    **/
    private static String prepareUnselectedValuesLongText(Set<String> values){
        String output = '';

        for(String val : values){
            //prepare list 
            output += (HelperClass.toProperCase(val) +'\n');
        }

        return output;
    }


}