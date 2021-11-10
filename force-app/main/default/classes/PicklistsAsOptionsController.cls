public with sharing class PicklistsAsOptionsController {
    /**
    *   @author      Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description get the data for the field and object
    **/
    private static Object getData (String objectName, String recordId, String fieldNames) {
        String query = 
            'SELECT Id, LastModifiedDate, ' + fieldNames + 
            ' FROM ' + objectName + 
            ' WHERE Id = \'' + recordId + '\'';

        return (Object) Database.query(query);   
    }

    /**
    *   @author      Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description get the Picklist configuration and data to populate
    **/

    @AuraEnabled
    public static PicklistConfiguration getPicklistsConfiguration(String recordId, String fieldNames, boolean enforcePicklistDependencies) { 
        try { 
            if (String.isBlank(recordId) || String.isBlank(fieldNames)) {
                throw new AuraHandledException('The recordId and the fieldNames are required in method getPicklistConfiguration');
            }

            // get the sobjectname
            String sObjName = ((Id) recordId).getSObjectType().getDescribe().getName();
            SObjectType objectType = Schema.getGlobalDescribe().get(sObjName);

            // get the picklist describe properties for each fieldname
            List<String> theFieldNames = fieldNames.split(',');

            List<PicklistField> listPicklistFields = new List<PicklistField>();

            Map<String,String> controllersMap = new Map<String, String>();

            for (String field : theFieldNames) {
                
                String controller = String.valueOf(Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap().get(field).getDescribe().getController());

                if(String.isNotBlank(controller)) controllersMap.put(field,controller);
            }
            
            String controllers = String.join(controllersMap.values(),',');

            controllers = String.isNotBlank(controllers) ? ','+controllers : ''; 
            
            // get the actual data 
            Object data = getData(sObjName, recordId, fieldNames + controllers);

            SObject sObjData = ((List<SObject>) data)[0];

            for (String field : theFieldNames) {
                Schema.SobjectField pickListField = objectType.getDescribe().fields.getMap().get(field);
                Schema.DescribeFieldResult pickListFieldDescribe = pickListField.getDescribe();

                if (pickListFieldDescribe.getType() != DisplayType.MULTIPICKLIST && pickListFieldDescribe.getType() != DisplayType.PICKLIST) {
                    throw new AuraHandledException('The field ' + field + ' must be a picklist or multipicklist field');
                }

                List<Schema.PicklistEntry> picklistEntries = pickListFieldDescribe.getPicklistValues();

                Map<String, String> mapValues = new Map<String,String>();

                Map<Object,List<String>> dependValuesByControlValue = HelperClass.getDependentPicklistValues(pickListField);
                System.debug('\n\n\n dependValuesByControlValue '+dependValuesByControlValue);

                String controller = controllersMap.containsKey(field) ? controllersMap.get(field) : '';

                String controllerVal = String.isNotBlank(controller) ? String.valueOf(sObjData.get(controller)) : '';
                System.debug('\n\n\n controllerVal '+controllerVal);
                           
                for( Schema.PicklistEntry pickListVal : picklistEntries){

                    if (pickListVal.isActive()) {

                        String plLabel = pickListVal.getLabel();
                         
                        if(!enforcePicklistDependencies) mapValues.put(pickListVal.getValue(), plLabel);
                        else{   

                            List<String> availablePicklistValues = new List<String>();
                            
                            if(String.isNotBlank(controllerVal) && dependValuesByControlValue.containsKey(controllerVal)){

                                availablePicklistValues = dependValuesByControlValue.get(controllerVal);
                            }

                            System.debug('\n\n\n availablePicklistValues '+availablePicklistValues);

                            if(availablePicklistValues.contains(plLabel) || String.isBlank(controller)) 
                                mapValues.put(pickListVal.getValue(), plLabel);
                        }
                    }
                }
                // add to the map
                listPicklistFields.add(new PicklistField(field, mapValues, pickListFieldDescribe.getType() == DisplayType.MULTIPICKLIST, pickListFieldDescribe.getLabel()));
            }
            
            
            return new PicklistConfiguration(data, listPicklistFields);

        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' / ' + ex.getStackTraceString());
        }
    }

    public class PicklistField {
        @AuraEnabled
        public String fieldName;

        @AuraEnabled
        public Map<String,String> values;

        @AuraEnabled
        public Boolean multipleSelection;

        @AuraEnabled
        public String label;

        public PicklistField (String fieldName, Map<String,String> values, Boolean multipleSelection, String label) {
            this.fieldName = fieldName;
            this.values = values;
            this.multipleSelection = multipleSelection;
            this.label = label;
        }
    }

    public class PicklistConfiguration {
        @AuraEnabled
        public Object data;
        
        @AuraEnabled
        public List<PicklistField> picklists;

        public PicklistConfiguration (Object data, List<PicklistField> picklists) {
            this.data = data;
            this.picklists = picklists;
        }
    }
}