/**
 * @author       Pablo Martinez (pablomartinez@deloitte.co.nz)
 * @date         2019-06-20
 * @description  
 * 
 **/
public with sharing class EnhancedRelatedListFieldsUtility {
    // List of fields
    private static Map<String, FieldsFromFieldSet> fieldsToReturnMap;

    /**
    *   @author      Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Cached Global describe
    **/
    private static Map<String, Schema.SObjectType> globalDescribe {
        get {
            if (globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        set;
    }

    /**
    *   @author      Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description get the Name field of the Object
    **/
    private static String getNameField (String objectName) {
        String result = 'Name';

        Map<String, Schema.SObjectField> mapFields = globalDescribe.get(objectName).getDescribe().fields.getMap();
        
        for(Schema.SObjectField objField : mapFields.values())
        {
            // describe the field
            Schema.DescribeFieldResult describeField = objField.getDescribe();

            if(describeField.isNameField())
            {
                result = describeField.getName();
                break;
            }
        }
        
        return result;
    }

    /**
    *   @author      Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description get the related field in the object with the parent
    **/
    private static String getRelatedField (Id parentId, String objectName) {
        // get the parentObject Name according to the id
        String parentObject = parentId.getSObjectType().getDescribe().getName();

        // get the map of the sobject fields
        Map<String, SObjectField> sObjectFieldsMap = globalDescribe.get(objectName).getDescribe().fields.getMap();
        
        // iterate through fields to get the related one
        for( String fieldName : sObjectFieldsMap.keySet() ) {
            // get the field from the map
            Schema.SObjectField field = sObjectFieldsMap.get( fieldName );
            // describe the field
            DescribeFieldResult fieldDescribe = field.getDescribe();
            // If it is Reference field
            if (fieldDescribe.getType() == DisplayType.REFERENCE && String.valueOf(fieldDescribe.getReferenceTo()[0]) == parentObject) {
                return fieldDescribe.getName();
            }
        }

        return null;
    }

    /**
    *   @author      Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description add the field to the return list
    **/
    private static void addFieldToReturnList(DescribeFieldResult fieldDescribe, String fieldName, Boolean required, String customLabel, Boolean isNameField, String aggregateFunctions) {
        // if it is accessible to the user
        if (fieldDescribe.isAccessible() && !fieldsToReturnMap.containsKey(fieldName)) {

            // Get requiredness
            Boolean requiredness = required || !fieldDescribe.isNillable();

            // Get fieldPath
            String fieldPath = fieldName;

            // Get fieldType
            String fieldType = String.valueOf(fieldDescribe.getType());

            // if it's also a reference field
            /* if (fieldDescribe.getType() == DisplayType.REFERENCE) {

                // get the referenced object
                String objectName = String.valueOf(fieldDescribe.getReferenceTo()[0]);

                // Get fieldPath
                fieldPath = fieldDescribe.getRelationshipName() + '.' + getNameField(objectName);

                // Get fieldType
                fieldType = 'STRING';
            } */

            // add the field to the list
            fieldsToReturnMap.put(
                fieldPath,
                new FieldsFromFieldSet(
                    String.isNotBlank(customLabel) ? customLabel : fieldDescribe.getLabel(),
                    fieldPath,
                    fieldDescribe.isUpdateable(),
                    fieldType,
                    requiredness,
                    String.valueOf(fieldDescribe.getDefaultValue()),
                    isNameField,
                    aggregateFunctions
                )
            );

        }
    }

    /**
    *   @author      Tiaan Swart (tswart@deloitte.co.nz)
    *   @description Helper for field describe
    **/
    private static Map<String, DescribeSObjectResult> sObjectDescribeMap = new Map<String, DescribeSObjectResult>();
    private static DescribeSObjectResult getObjectDescribe(String objectName) {

        if (!sObjectDescribeMap.containsKey(objectName)) {
            sObjectDescribeMap.put(objectName, globalDescribe.get(objectName).getDescribe());
        }

        return sObjectDescribeMap.get(objectName);
    }

    /**
    *   @author      Tiaan Swart (tswart@deloitte.co.nz)
    *   @description Helper for field describe
    **/
    private static Map<String, Map<String, SObjectField>> sObjectFieldsMap = new Map<String, Map<String, SObjectField>>();
    private static Map<String, SObjectField> getObjectFields(String objectName) {

        if (!sObjectFieldsMap.containsKey(objectName)) {
            DescribeSObjectResult describeObject = getObjectDescribe(objectName);
            sObjectFieldsMap.put(objectName, describeObject.fields.getMap());
        }

        return sObjectFieldsMap.get(objectName);
    }

    /**
    *   @author      Tiaan Swart (tiaan@cloudinit.nz)
    *   @description Build a map of relationship names for an object
    *   @return      Map of object name string to relationship names map
    **/
    private static Map<String, Map<String, String>> relationshipNamesForObject;
    private static Map<String, String> getRelationshipNamesForObject (String objectName) {

        if (relationshipNamesForObject == null) {
            relationshipNamesForObject = new Map<String, Map<String, String>>();
        }

        if (!relationshipNamesForObject.containsKey(objectName)) {
            // Build relationship names list
            Map<String, String> relationshipNames = new Map<String, String>();
            for (SObjectField fieldResult : getObjectFields(objectName).values()) {
                DescribeFieldResult fieldDescribe = fieldResult.getDescribe();
                if (fieldDescribe.getSoapType() == Schema.SoapType.ID && !fieldDescribe.getReferenceTo().isEmpty()) {
                    relationshipNames.put(fieldDescribe.getRelationshipName(), fieldDescribe.getReferenceTo()[0].getDescribe().getName());
                }
            }
            relationshipNamesForObject.put(objectName, relationshipNames);
        }

        return relationshipNamesForObject.get(objectName);
    }

    /**
    *   @author      Tiaan Swart (tswart@deloitte.co.nz)
    *   @description Helper for field describe
    **/
    private static Map<String, Map<String, DescribeFieldResult>> sObjectFieldDescribeMap = new Map<String, Map<String, DescribeFieldResult>>();
    private static DescribeFieldResult getFieldDescribe(String objectName, String fieldPath) {

        // Split the field path into it's parts (if we have any parts)
        List<String> fieldPathParts = fieldPath.split('\\.');
        // While we have more parts
        while (!fieldPathParts.isEmpty()) {
            if (!sObjectFieldDescribeMap.containsKey(objectName)) {
                sObjectFieldDescribeMap.put(objectName, new  Map<String, DescribeFieldResult>());
            }
            // Get this field path part
            fieldPath = fieldPathParts.remove(0);
            // If this field is in the object fields fields
            if (getObjectFields(objectName).containsKey(fieldPath)) {
                // Then add it
                sObjectFieldDescribeMap.get(objectName).put(
                    fieldPath,
                    getObjectFields(objectName).get(fieldPath).getDescribe()
                );
            }
            // Else if this field is in relationship names
            else if (getRelationshipNamesForObject(objectName).containsKey(fieldPath)) {
                // Get the object name
                objectName = getRelationshipNamesForObject(objectName).get(fieldPath);
            } else {
                throw new AuraHandledException('The field path "'+fieldPath+'" could not be resolved for object "'+objectName+'"');
            }
        }

        return sObjectFieldDescribeMap.get(objectName).get(fieldPath);
    }

    /**
    *   @author      Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description get a Map of object label and a list of fields according to an object and fieldset or return Name only
    **/
    @AuraEnabled(Cacheable=true)
    public static ObjectData getObjectMetadata(String objectName, String recordId, String fieldSetName, String selectedFields, Boolean allowCreate, Boolean isAggregate) {
        try {
            if (String.isBlank(objectName)) throw new AuraHandledException('The ObjectName is required in method getFieldsFromFieldSet');

            allowCreate = allowCreate == null ? false : allowCreate;
            isAggregate = isAggregate == null ? false : isAggregate;

            // describe the object
            DescribeSObjectResult describeObject = getObjectDescribe(objectName);

            // only if the object is accessible by the user
            if (describeObject.isAccessible()) {
                // fields list
                fieldsToReturnMap = new Map<String, FieldsFromFieldSet>();

                // get the name field
                String nameField = getNameField(objectName);

                // Get the Map of FieldSets for the object
                Map<String, FieldSet> fieldSetMap = describeObject.fieldSets.getMap();

                // Get map of the fields
                Map<String, SObjectField> fields = getObjectFields(objectName);

                // describe the field
                DescribeFieldResult fieldDescribe;

                // if fieldset is not null and we have a fieldset with that same name
                if (String.isNotBlank(fieldSetName) && fieldSetMap.containsKey(fieldSetName)) {

                    // iterate the fields from the fieldset
                    for (FieldSetMember member : fieldSetMap.get(fieldSetName).getFields()) {
                        // get the field Path
                        String fieldPath = member.getFieldPath();

                        // Get the describe
                        fieldDescribe = getFieldDescribe(objectName, fieldPath);

                        // if it's the name field or is required by db or by the fieldset
                        Boolean required = fieldPath == nameField || member.getDBRequired() || member.getRequired();

                        // add the field to the return list
                        addFieldToReturnList(fieldDescribe, fieldPath, required, null, fieldPath == nameField, null);
                    }

                } else if (String.isNotBlank(selectedFields))  {

                    // Work through each field selected
                    for (String selectedField : selectedFields.split(',')) {

                        // Trim the text
                        selectedField = selectedField.trim();

                        // Get a custom label (if we have one)
                        String customLabel;
                        if (selectedField.contains('"')) {
                            // Get the custom label
                            customLabel = selectedField.substring(selectedField.indexOf('"') + 1, selectedField.lastIndexOf('"'));
                            // Remove the custom label from the field
                            selectedField = selectedField.remove('"' + customLabel + '"');
                        }

                        // Get the Aggregate Functions (if any)
                        String aggregateFunctions = '';
                        while (selectedField.contains('(')) {

                            // Trim the text
                            selectedField = selectedField.trim();

                            // Add the function
                            String aggregateFunction = selectedField.substring(0, selectedField.indexOf('('));

                            // Remove the function
                            selectedField = selectedField.substring(selectedField.indexOf('(')+1, selectedField.lastIndexOf(')'));

                            // Add the Aggregate Function to the list
                            aggregateFunctions += (String.isNotBlank(aggregateFunctions) ? ',' : '') + aggregateFunction.toUpperCase();
                        }

                        // Get the describe
                        fieldDescribe = getFieldDescribe(objectName, selectedField);

                        // add the field to the return list
                        addFieldToReturnList(fieldDescribe, selectedField, false, customLabel, selectedField == nameField, aggregateFunctions);
                    }

                } else {

                    // add the Name to the return list
                    fieldDescribe = getFieldDescribe(objectName, nameField);
                    addFieldToReturnList(fieldDescribe, nameField, true, null, true, null);
                }

                // Only add the required fields if we are going to be creating records
                if (allowCreate && !isAggregate) {
                    for( String fieldName : fields.keySet() ) {
                        // get the field from the map
                        Schema.SObjectField field = fields.get( fieldName );

                        // describe the field
                        fieldDescribe = field.getDescribe();

                        // If we have a Compound Field Name and it is already included, then continue
                        if (String.isNotBlank(fieldDescribe.getCompoundFieldName()) && fieldsToReturnMap.containsKey(fieldDescribe.getCompoundFieldName())) continue;

                        // If it is accessible and required
                        if (fieldDescribe.isAccessible() && !fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate()) {
                            String fieldPath = fieldDescribe.getName();
                            addFieldToReturnList(fieldDescribe, fieldPath, true, null, fieldPath == nameField, null);
                        }
                    }
                }

                if (fieldsToReturnMap.isEmpty()) {
                    throw new AuraHandledException('The user does not have any accessible fields.');
                }

                // get the relatedField
                String relatedField = getRelatedField(recordId, objectName);

                return new ObjectData(describeObject.getLabel(), describeObject.getLabelPlural(), objectName, nameField, describeObject.isDeletable(), describeObject.isCreateable(), describeObject.isUpdateable(), fieldsToReturnMap, relatedField);

            }

            throw new AuraHandledException('The user does not have access to '+objectName);

        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' / ' + ex.getStackTraceString());
        }
    }

    // Wrapper class for fields
    public class FieldsFromFieldSet {

        @AuraEnabled
        public String label;
        
        @AuraEnabled
        public String fieldName;
        
        @AuraEnabled
        public Boolean isUpdateable;

        @AuraEnabled
        public String type;

        @AuraEnabled
        public Boolean required;

        @AuraEnabled
        public String defaultValue;

        @AuraEnabled
        public Boolean isNameField;

        @AuraEnabled
        public String aggregateFunctions;
        
        public FieldsFromFieldSet(String label, String fieldName, Boolean isUpdateable, String type, Boolean required, String defaultValue, Boolean isNameField, String aggregateFunctions) {

            this.label = label;
            this.fieldName = fieldName;
            this.isUpdateable = isUpdateable;
            this.required = required;
            this.defaultValue = defaultValue;
            this.type = type.toLowerCase();
            this.isNameField = isNameField;
            this.aggregateFunctions = aggregateFunctions;
        }
    }

    // wrapper class to return
    public class ObjectData {
        @AuraEnabled
        public String objectLabel;

        @AuraEnabled
        public String pluralLabel;

        @AuraEnabled
        public String objectName;

        @AuraEnabled
        public String nameField;

        @AuraEnabled
        public String relatedField;

        @AuraEnabled
        public Boolean isDeletable;

        @AuraEnabled
        public Boolean isCreateable;

        @AuraEnabled
        public Boolean isUpdateable;
        
        @AuraEnabled
        public List<FieldsFromFieldSet> fields;

        public ObjectData(String label, String pluralLabel, String name, String nameField, Boolean deletable, Boolean createable, Boolean updateable, Map<String, FieldsFromFieldSet> fieldsMap, String relatedField) {

            this.objectLabel = label;
            this.pluralLabel = pluralLabel;
            this.objectName = name;
            this.nameField = nameField;
            this.relatedField = relatedField;
            this.isDeletable = deletable;
            this.isCreateable = createable;
            this.isUpdateable = updateable;
            this.fields = new List<FieldsFromFieldSet>(fieldsMap.values());
        }
    }
}