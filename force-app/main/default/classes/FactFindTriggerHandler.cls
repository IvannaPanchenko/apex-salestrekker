/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Oct 14, 2020
* @description Trigger handler for fact find trigger.
*
* CHANGE LOG
**/
public class FactFindTriggerHandler extends TriggerHandler {

    public override void afterUpdate() {
        //Check client expectation update
        checkClientExpectationsUpdate(newFactFinds);
    }

    /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Method to update client expectations field in related Advice records
    **/
    private void checkClientExpectationsUpdate(List<Fact_Find__c> newFactFinds){

        Set<Id> changedFFIds = new Set<Id>();

        for(Fact_Find__c factFind: newFactFinds){
            //get changed fact find records
            if(factFind.Client_Expectations__c != oldFactFindMap.get(factFind.Id).Client_Expectations__c){
               changedFFIds.add(factFind.Id);
            }
        }
        //update related advice records
        
         List<Advice__c> advicesToUpdate =  [SELECT Id, Client_Expectations__c, Opportunity__r.Fact_Find__r.Client_Expectations__c FROM Advice__c WHERE Opportunity__r.Fact_Find__c IN: changedFFIds];

        for(Advice__c advice : advicesToUpdate){

           advice.Client_Expectations__c =   advice.Opportunity__r.Fact_Find__r.Client_Expectations__c;
        }

        if(!advicesToUpdate.isEmpty()) update advicesToUpdate;
        
    }

    public List <Fact_Find__c> newFactFinds {
        get {
            return (List <Fact_Find__c> ) Trigger.new;
        }
        private set;
    }

    public Map <Id, Fact_Find__c> oldFactFindMap {
        get {
            return (Map <Id, Fact_Find__c> ) Trigger.oldMap;
        }
        private set;
    }
}