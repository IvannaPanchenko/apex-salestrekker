/**
* @author David Catindoy (david@cloudinit.nz)
* @date May 9, 2018
* @description Letter of Authority wrapper class
*
* CHANGE LOG
**/
public with sharing class LetterofAuthority {
    
    //Public variables
    public String recordId {get; set;}
    public Opportunity oppty {get; set;}
    
    public Map<String, PickList> scopeValues {
        get {
            if(scopeValues == null){
                scopeValues = new Map<String, PickList>();
                Integer i = 1;
                for(Schema.PicklistEntry pe : Opportunity.Letter_of_Authority_Scope__c.getDescribe().getPicklistValues()){
                    scopeValues.put(String.valueOf(i), new PickList(pe.getLabel(), pe.getValue(), false));
                    i++;
                }
            }
            return scopeValues;
        }
        set;
    }
    
    //Controller
    public LetterofAuthority(ApexPages.StandardController stdController){
        this.recordId = stdController.getId();
        
        if(String.isNotBlank(recordId)){
            initialize();
        }
    }
    
    // Method to untick all checkboxes
    public void untickAll() {
        scopeValues = null;
        oppty.Servicing_Adviser__c = false;
    }
    
    public void initialize(){
        scopeValues = null;
        
        try{
            List<Opportunity> opptyList = [SELECT Id, Letter_of_Authority_Scope__c, Servicing_Adviser__c FROM Opportunity WHERE Id =: recordId];
            if(!opptyList.isEmpty()){
                oppty = opptyList.get(0);
                
                if(String.isNotBlank(oppty.Letter_of_Authority_Scope__c)){
                    Integer i = 1;
                    for(Schema.PicklistEntry pe : Opportunity.Letter_of_Authority_Scope__c.getDescribe().getPicklistValues()){
                        if(oppty.Letter_of_Authority_Scope__c.contains(pe.getValue())){
                            if(scopeValues.containsKey(String.valueOf(i))){
                                scopeValues.get(String.valueOf(i)).selected = true;
                            } else {
                                scopeValues.put(String.valueOf(i), new Picklist(pe.getLabel(), pe.getValue(), true));
                            }
                        }
                        i++;
                    }
                } else {
                    // Default checkboxes to true
                    for (String key : scopeValues.keySet()) {
                        scopeValues.get(key).selected = true;
                    }
                }
            }
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    //Method to save all changes in the scope of engagement page/component
    public void saveRecord(){
        
        Set<String> valuesSelected = new Set<String>();
        
        for(Picklist scope : scopeValues.values()){
            if(scope.selected){
                valuesSelected.add(scope.value);
            }
        }
        
        try{
            oppty.Letter_of_Authority_Scope__c = String.join(new List<String>(valuesSelected), ';');
            
            Database.upsert(oppty);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Letter of Authority successfully saved.'));
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    public class Picklist {
        public String label {get; set;}
        public String value {get; set;}
        public Boolean selected {get; set;}
        
        public Picklist(String label, String value, Boolean flag){
            this.label = label;
            this.value = value;
            this.selected = flag;
        }
    }

}