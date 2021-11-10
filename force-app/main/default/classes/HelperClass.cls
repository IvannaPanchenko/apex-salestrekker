/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Nov 10, 2020
* @description Helper class
*
* CHANGE LOG
**/

public with sharing class HelperClass {

      /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Method to format currency value 
    **/
    public static String currencyStrFormatter(String currencyStrVal){
        //format
        String strVal = (Decimal.valueOf(currencyStrVal==null||currencyStrVal.trim()==''?'0':currencyStrVal).setScale(2) + 0.001 ).format();

        return strVal.substring(0,strVal.length()-1);
    }
      /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Formats text to proper case
    **/
    
   public static String toProperCase(String value) {
       
        value = value.toLowerCase();

      
        List<String> words = new List<String>();

        // split and capitalize 
        for(String val : value.split(' ')) {
             
            val = val.capitalize();
            words.add(val);
        }

        // join
        return String.join(words, ' ');
    }


    @AuraEnabled(cacheable = true)
    public static List<String> getFieldSetFieldsByFieldSetName(String objectApiName, String fieldSetName) {

        List<String> fields = new List<String>();

        try{

           List<Schema.FieldSetMember> fieldSetMembers = Schema.getGlobalDescribe().get(objectApiName).getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
            
           for (Schema.FieldSetMember fieldSetMember : fieldSetMembers){
                fields.add(fieldSetMember.fieldPath);
           }

        }
        catch(Exception ex){

        }

        System.debug('fields results '+fields);

        return fields;

    }

   public static Map<Object,List<String>> getDependentPicklistValues( Schema.sObjectField dependToken ){
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
        (   control.getType() == Schema.DisplayType.Boolean
        ?   null
        :   control.getPicklistValues()
        );
    
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                (   controlEntries == null
                ?   (Object) (index == 1)
                :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getValue() : null)
                );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                    ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                    ) continue;
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                dependentPicklistValues.get( controlValue ).add( entry.getValue() );
            }
        }
        return dependentPicklistValues;
    }
    
}