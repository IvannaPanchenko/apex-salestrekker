/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Nov 3, 2020
* @description Class for Update KAR Records invocable method
*
* CHANGE LOG
**/
public with sharing class KARUpdateRecordService {

      /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description invocable method to update KAR records
    **/
    @InvocableMethod(label = 'Update KAR Records')
    public static void updateKARs(List<Id> recIds){
        updateKARsBackground(recIds);
    }


     /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description future method to update KAR records
    **/
    @future
    public static void updateKARsBackground(List<Id> recIds){
        //get object name
        String objectName = String.valueOf(recIds[0].getSObjectType());

        if(objectName == 'Non_Apex_Cover__c'){
            update [SELECT Id FROM KAR__c WHERE Non_Apex_Cover__c IN: recIds];
        }


    }
}