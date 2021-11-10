/**
* @author David Catindoy (david@cloudinit.nz)
* @date Feb 11, 2019
* @description Controller for PolicyCreateBenefits page
*
* CHANGE LOG
**/
public class PolicyCreateBenefitsController {
    
    public String policyId {get; set;}
    public Map<String, Map<String, Policy_Benefit__c>> policyBenefits {get; set;}
    public Map<String, Map<String, String>> dates {get; set;}
    public Map<String, Boolean> sectionFlags {get ; set;}
    public Map<String, Integer> benefitsCount {get; set;}
    public List<Policy_Benefits_Setting__c> benefitsTypeList {get; set;}
    public String benefitType {get; set;}
    public String selectedId {get; set;}
    public String prefix {get; set;}
    public Boolean sectionFlag {get; set;}
    public Boolean lightning {get; set;}
    
    // Constructor
    public PolicyCreateBenefitsController(ApexPages.StandardController cont){
        
        // Initialize variables
        policyId = cont.getId();
        policyBenefits = new Map<String, Map<String, Policy_Benefit__c>>();
        dates = new Map<String, Map<String, String>>();
        sectionFlags = new Map<String, Boolean>();
        benefitsCount = new Map<String, Integer>();
        benefitsTypeList = new List<Policy_Benefits_Setting__c>();
        benefitType = '';
        selectedId = '';
        prefix = Policy_Benefit__c.sObjectType.getDescribe().getKeyPrefix();
        sectionFlag = false;
        benefitsType = null;
        lightning = UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4u';
        
        // Retrieve and categorize policy benefits according to its type
        for (Policy_Benefit__c benefit : Database.query('SELECT ' + String.join(getCreatableFieldsSOQL('Policy_Benefit__c'), ',') + ' FROM Policy_Benefit__c WHERE Policy__c =: policyId ORDER BY CreatedDate ASC')) {
            
            if(!benefitsType.isEmpty() && benefitsType.containsKey(benefit.RecordTypeId)){
                // Check if the benefit type is already in the map.
                if (policyBenefits.containsKey(benefit.RecordTypeId)) {
                    policyBenefits.get(benefit.RecordTypeId).put(benefit.Id, benefit);
                } else { // Else, we put it in the map
                    policyBenefits.put(benefit.RecordTypeId, new Map<String, Policy_Benefit__c>{benefit.Id => benefit});
                }
                
                populateDate(benefit.Id, benefit.RecordTypeId);
            }
        }
        
        for(String key : policyBenefits.keySet()){
            if(!policyBenefits.get(key).isEmpty()){
                sectionFlags.put(key, true);
                benefitsCount.put(key, policyBenefits.get(key).size());
            }
        }
        
        if (benefitsType.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No policy benefits type found in the custom setting.'));
        }
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Retrieve policy benefits configuration
    *   @return Policy Benefit setting values
    **/
    public Map<String, Policy_Benefits_Setting__c> benefitsType {
        get {
            if(benefitsType == null){
                benefitsType = new Map<String, Policy_Benefits_Setting__c>();
                benefitsTypeList = new List<Policy_Benefits_Setting__c>();
                for (Policy_Benefits_Setting__c benefitType : [SELECT Id, Name, Recordtype__c, Field_Sets_Name__c, Order__c FROM Policy_Benefits_Setting__c ORDER BY Order__c ASC]) {
                    benefitsType.put(benefitType.Recordtype__c, benefitType);
                    sectionFlags.put(benefitType.Recordtype__c, false);
                    benefitsCount.put(benefitType.Recordtype__c, 0);
                    benefitsTypeList.add(benefitType);
                }
                
            }
            return benefitsType;
        }
        set;
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Set benefits type boolean flag
    **/
    public Map<String, Boolean> benefitsTypeFlag {
        get {
            if(benefitsTypeFlag == null){
                benefitsTypeFlag = new Map<String, Boolean>();
                for (String key : benefitsType.keySet()) {
                    benefitsTypeFlag.put(key, policyBenefits.containsKey(key) && !policyBenefits.get(key).isEmpty());
                }
                
            }
            return benefitsTypeFlag;
        }
        set;
    }
    
    // Returns a list of creatable fields for the whole object.
    public static List<String> getCreatableFieldsSOQL(String objectName){
         
        List<String> creatableFields = new List<String>();
         
        //Loop through all field tokens
        for (Schema.SObjectField fm : Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().fields.getMap().values()){ 
            Schema.DescribeFieldResult fieldDescribe = fm.getDescribe(); //Describe field
            if (fieldDescribe.isCreateable()){ //Check if field is creatable.
                creatableFields.add(fieldDescribe.getName());
            }
        }
         
        if (!creatableFields.isEmpty()){
            return creatableFields; //Return list of creatable fields.
        }
         
        return new List<String>(); //If no creatable fields, then return an empty list.
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Convert date into ALJS date format
    **/
    public void populateDate (String mapId, String benefType) {
        dates.put(mapId, new Map<String, String>());
                
        for (Schema.SObjectField fm : Schema.getGlobalDescribe().get('Policy_Benefit__c'.toLowerCase()).getDescribe().fields.getMap().values()){ 
            Schema.DescribeFieldResult fieldDescribe = fm.getDescribe(); //Describe field
            
            if(fieldDescribe.isCreateable() && fieldDescribe.getType() == Schema.DisplayType.Date) {
                Date dateValue = Date.valueOf(policyBenefits.get(benefType).get(mapId).get(fieldDescribe.getName()));
                dates.get(mapId).put(fieldDescribe.getName(), dateValue == null ? '' : FactFindingControllerService.formatDateToString(dateValue.format()));
            }
        }
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Clone existing record
    **/
    public PageReference cloneRecord(){
        
        try {
            
            String key = prefix + benefitsType.get(benefitType).Name + benefitsCount.get(benefitType);
            
            Policy_Benefit__c newBenefit = policyBenefits.get(benefitType).get(selectedId).clone();
            newBenefit.Id = null;
            policyBenefits.get(benefitType).put(key, newBenefit);
            
            populateDate(key, benefitType);
            benefitsCount.put(benefitType, benefitsCount.get(benefitType) + 1);
        
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Clone existing record
    **/
    public PageReference removeRecord(){
        
        try {
            benefitsTypeFlag = null;
            
            if (String.isNotBlank(policyBenefits.get(benefitType).get(selectedId).Id)) {
                Database.delete(new Policy_Benefit__c(Id = policyBenefits.get(benefitType).get(selectedId).Id));
            }
            policyBenefits.get(benefitType).remove(selectedId);
        
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Initialize new record
    **/
    public PageReference newRecord(){
        
        try {
            benefitsTypeFlag = null;
            String key = prefix + benefitsType.get(benefitType).Name + (policyBenefits.containsKey(benefitType) ? benefitsCount.get(benefitType) : 0);
            System.debug(key);
            if (policyBenefits.containsKey(benefitType)) {
                policyBenefits.get(benefitType).put(key, new Policy_Benefit__c(RecordTypeId = Id.valueOf(benefitType)));
            } else {
                policyBenefits.put(benefitType, new Map<String, Policy_Benefit__c>{key => new Policy_Benefit__c(RecordTypeId = Id.valueOf(benefitType))});
            }
            
            populateDate(key, benefitType);
            benefitsCount.put(benefitType, benefitsCount.get(benefitType) + 1);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Save all benefit records
    **/
    public PageReference saveRecords () {
        
        try {
            List<Policy_Benefit__c> benefitRecords = new List<Policy_Benefit__c>();
            
            for (String key : policyBenefits.keySet()){
                for (String benefitKey : policyBenefits.get(key).keySet()) {
                    Policy_Benefit__c benefit = policyBenefits.get(key).get(benefitKey);
                    if (dates.containsKey(benefitKey)) {
                        for (String field : dates.get(benefitKey).keySet()) {
                            benefit.put(field, String.isNotBlank(FactFindingControllerService.formatStringToDate(dates.get(benefitKey).get(field))) ? Date.valueOf(FactFindingControllerService.formatStringToDate(dates.get(benefitKey).get(field))) : null);
                        }
                    }
                    
                    benefit.Policy__c = policyId;
                    benefitRecords.add(benefit);
                }
            }
            
            if (!benefitRecords.isEmpty()) {
                Database.upsert(benefitRecords);
            }
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Policy Benefits were saved.'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return null;
    }
    
    public Map<String, List<String>> getAllPageMessagesMap() {

        Map<String, List<String>> allPageMessagesMap = new Map<String, List<String>>();

        // Iterate over each alert message
        for(ApexPages.Message apexPageMessage : ApexPages.getMessages()) {

            // Get the alert style for the message
            String alertTheme = ApexAkina_Constants.severityToThemeMap.get(apexPageMessage.getSeverity());

            // If the map already contains an error for this style
            if (allPageMessagesMap.containsKey(alertTheme)) {

                // Get the existing list
                List<String> existingErrors = allPageMessagesMap.get(alertTheme);

                // Add the new error
                existingErrors.add(apexPageMessage.getDetail());

                // Put back into the map
                allPageMessagesMap.put(alertTheme, existingErrors);
            } else {
                // Otherwise, it doesn't yet exist
                allPageMessagesMap.put(alertTheme, new List<String>{apexPageMessage.getDetail()});
            }
        }
        return allPageMessagesMap;
    }

}