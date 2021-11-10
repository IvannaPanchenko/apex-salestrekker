/**
 * @author       Pablo Martinez (pablomartinez@deloitte.co.nz)
 * @date         2019-06-20
 * @description  
 * 
 * CHANGE LOG
 * Patrick Lorilla (plorilla@deloitte.co.nz) - Nov 2020 - Add get records with non cols parameters
 **/
public with sharing class EnhancedRelatedListController {

     /**
    *   @author      Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description get a list of records Ids for the Object (without non col parameters)
    **/
    @AuraEnabled
    public static Object getRecords(Id parentId, String objectName, String relatedField, String columns, String whereCondition, String groupBy, String order, Integer recordLimit) {

        return getRecords(parentId, objectName, relatedField, columns, '', whereCondition, groupBy, order,  recordLimit);
    }
    
    /**
    *   @author      Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description get a list of records Ids for the Object
    **/
    @AuraEnabled
    public static Object getRecords(Id parentId, String objectName, String relatedField, String columns, String nonColumns, String whereCondition, String groupBy, String order, Integer recordLimit) {
        try {
            if (!String.isBlank(objectName) && !String.isBlank(parentId)) {

                // Add to the WHERE Condition
                if (String.isBlank(whereCondition) && !String.isBlank(relatedField)) whereCondition = relatedField + ' = {{ Id }}';

                // If we have a merge class (we can only have one as we need to get the values and assign it to a variable in the executing class)
                List<Object> objectValues;
                if (whereCondition.contains('[[')) {

                    // Get he class name and method name
                    String className = whereCondition.substring(whereCondition.indexOf('[[') + 2, whereCondition.indexOf(']]'));

                    // Replace with the property name
                    whereCondition = whereCondition.replace('[[' + className + ']]', ':objectValues');

                    // Invoke the class instance and get the objects
                    EnhancedRelatedListQueryAbstract classInstance = ((EnhancedRelatedListQueryAbstract) Type.forName(className.trim()).newInstance());
                    classInstance.setRecordId(parentId);
                    objectValues = classInstance.getObjects();

                }

                // If we have merge fields
                if (whereCondition.contains('{{')) {

                    // Replace start and end patterns
                    whereCondition = whereCondition.replaceAll('\\{\\{', '\'{{').replaceAll('\\}\\}', '}}\'');

                    // Replace merge fields
                    whereCondition = MergeFieldUtility.replaceMergeFieldsWithValues (whereCondition, parentId);

                }

                columns = columns == null ? '' : columns;
                nonColumns = String.isBlank(nonColumns) ? '' : ',' + nonColumns ;
                String fields = columns + nonColumns;
                
                return Database.query(
                    String.format(
                        'SELECT {0} FROM {1}{2}{3}{4} LIMIT {5}',
                        new String[] {
                            (String.isNotBlank(fields) ? String.join(new List<String>(new Set<String>(fields.split(','))), ', ') : 'Id'),
                            objectName,
                            String.isBlank(whereCondition) ? '' : ' WHERE ' + whereCondition,
                            String.isNotBlank(groupBy) ? ' GROUP BY ' + groupBy : '',
                            String.isNotBlank(order) ? ' ORDER BY ' + order : '',
                            recordLimit == null ? '10000' : String.valueOf(recordLimit)
                        }
                    )
                );
            } else {
                throw new AuraHandledException('objectName is a required attribute');
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' / ' + ex.getStackTraceString());
        }
    }
}