/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Nov 3, 2020
* @description Trigger handler for account trigger.
*
* CHANGE LOG
**/

public class KARTriggerHandler extends TriggerHandler {
   

    public List<KAR__c> newKARsList {
        get {
            return (List<KAR__c>) Trigger.new;
        }
        private set;
    }

    public Map <Id, KAR__c> oldKARsMap {
        get {
            return (Map <Id, KAR__c> ) Trigger.oldMap;
        }
        private set;
    }

    public override void afterInsert() {
       prepareForWhoTotals(newKARsList,oldKARsMap);
       prepareProvidersList(newKARsList,oldKARsMap);
    }

    public override void afterUpdate() {
       prepareForWhoTotals(newKARsList,oldKARsMap);
       prepareProvidersList(newKARsList,oldKARsMap);
    }

    public override void afterDelete() {
       prepareForWhoTotals(oldKARsMap.values(),null);
       prepareProvidersList(oldKARsMap.values(),null);
    }

    private static void prepareProvidersList(List<KAR__c> newKARsList, Map <Id, KAR__c> oldKARsMap){

        Set<Id> affectedAdviceIds = new Set<Id>();

        Map<Id,Set<String>> adviceProviders = new Map<Id,Set<String>>();

        List<Advice__c> adviceUpdateList = new List<Advice__c>();

        boolean isInsertOrDelete = (oldKARsMap == null || oldKARsMap.isEmpty());

        for(KAR__c kar : newKARsList){

            if(!isInsertOrDelete && oldKARsMap.containsKey(kar.Id)){

                KAR__c oldKAR = oldKARsMap.get(kar.Id);
                //significant and relevant changes
                if((kar.Status__c != oldKAR.Status__c && kar.Status__c =='Complete') || kar.Provider_Name__c != oldKAR.Provider_Name__c){

                    affectedAdviceIds.add(kar.Advice__c);
                }

            }
            else if(kar.Status__c == 'Complete') { //new or deleted complete record
                affectedAdviceIds.add(kar.Advice__c);
            }

        }

        if(affectedAdviceIds.isEmpty()) return;

        Map<String,String> alternateNamesMap = new Map<String,String>();

        for(Provider_Rationale__mdt provRat : [SELECT MasterLabel, Alternate_Names__c FROM Provider_Rationale__mdt]){

            alternateNamesMap.put(provRat.MasterLabel,provRat.MasterLabel);

            if(String.isBlank(provRat.Alternate_Names__c)) continue;

            for(String alternateName : provRat.Alternate_Names__c.split(';')){
                alternateNamesMap.put(alternateName,provRat.MasterLabel);
            }
             
        }

        for(Advice__c adv : [SELECT Id, (SELECT Id, Provider_Name__c, Advice__c FROM KAR__r WHERE Status__c = 'Complete' AND Approach__c IN ('Add','Keep','Alter')) FROM Advice__c WHERE Id IN: affectedAdviceIds]){

            for(KAR__c advKar : adv.KAR__r){

                String providerName = alternateNamesMap.containsKey(advKar.Provider_Name__c) ? alternateNamesMap.get(advKar.Provider_Name__c) : '';

                if(String.isBlank(providerName)) continue;

                if(adviceProviders.containsKey(adv.Id)){
                    adviceProviders.get(adv.Id).add(providerName);
                }
                else{
                    adviceProviders.put(adv.Id, new Set<String>{providerName});
                }
            }
        }

        for(Id adviceId :adviceProviders.keySet()){

            Set<String> providers = adviceProviders.get(adviceId);

            String providersMPickListVal = String.join((Iterable<String>)providers, ';');

            adviceUpdateList.add(new Advice__c(Id = adviceId, Providers__c = providersMPickListVal));
        }


        update adviceUpdateList;
    }

     /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Method that prepare totals value 
    **/

    private static void prepareForWhoTotals(List<KAR__c> newKARsList, Map <Id, KAR__c> oldKARsMap){
        boolean isInsertOrDelete = (oldKARsMap == null || oldKARsMap.isEmpty());
        Set<Id> adviceIds = new Set<Id>();
        List<Advice__c> adviceToUpdate = new List<Advice__c>();

        for(KAR__c kar : newKARsList){

            boolean hasValidUpdates = oldKARsMap != null && oldKARsMap.containsKey(kar.Id) && (kar.For_Who__c != oldKARsMap.get(kar.Id).For_Who__c || kar.Approach__c != oldKARsMap.get(kar.Id).Approach__c || kar.Before__c != oldKARsMap.get(kar.Id).Before__c || kar.After__c != oldKARsMap.get(kar.Id).After__c);

            if(isInsertOrDelete || hasValidUpdates){

                adviceIds.add(kar.Advice__c);
            }
        }

        Map<Id,List<AggregateResult>> karGroupMap = new Map<Id,List<AggregateResult>>();
        //get totals and group by name and advice
        for(AggregateResult agr : [SELECT Advice__c, For_Who__c, SUM(Before__c) BeforeSum, SUM(After__c) AfterSum FROM KAR__c WHERE Advice__c IN: adviceIds AND For_Who__c != '' AND (Approach__c = 'Keep' OR Approach__c = 'Add' OR Approach__c = 'Remove' OR Approach__c = 'Alter' OR Approach__c = 'Replace') GROUP BY For_Who__c, Advice__c ]){

            String adviceId = String.valueOf(agr.get('Advice__c'));

            if(karGroupMap.containsKey(adviceId)){
                karGroupMap.get(adviceId).add(agr);
            }
            else{
                karGroupMap.put(adviceId, new List<AggregateResult>{agr});
            }
            
        }

        for(Id adviceId : karGroupMap.keySet()){

            String totals = '';

            for(AggregateResult agr : karGroupMap.get(adviceId)){
                //prepare totals text value
                String name = String.valueOf(agr.get('For_Who__c'));
                String before = HelperClass.currencyStrFormatter(String.valueOf(agr.get('BeforeSum')));
                String after = HelperClass.currencyStrFormatter(String.valueOf(agr.get('AfterSum')));

                totals += (name  + '\n');
                totals += String.format('Before: ${0} After: ${1}', new List<Object>{before, after}) +'\n'; 
            }
            //prepare record to save
            adviceToUpdate.add(new Advice__c(Id = adviceId, KAR_Totals__c = totals));

        }

        System.debug('\n\n\n adviceToUpdate '+adviceToUpdate);
        update adviceToUpdate;

    }
}