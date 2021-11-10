/**
* @author David Catindoy (david@cloudinit.nz)
* @date Nov 7, 2017
* @description Controller for SLDSDynamicLookup component
*
* CHANGE LOG
**/
public with sharing class SLDSDynamicLookupController {
    /*
    * public variables
    **/
    public String objectName{get;
        set{
            if(objectName != value){
                objectName = value;
                objectLabelPlural = Schema.getGlobalDescribe().get(ObjectName).getDescribe().getLabelPlural();
            }
        }
        
    }
    
    public String label{
        get;
        set{
            label = value;
            uniqueComponentId = label.replace(' ', '').toLowerCase();
        }
    }
    
    public String placeHolder{
        get;
        set{
            placeHolder = value;
        }
    }
    
    public String uniqueComponentId {get; set;}
    public String objectLabelPlural {get; set;}
    
    /**
     * Remote action method to send list of records
     * @param  searchText 
     * @return  List<Wrapper>
     */
    @RemoteAction
    public static List<Wrapper> search(String objectName, String displayFieldNames, String fieldsPattern, String photoValue, String searchText, String recordId, String jsfunction, String additionalWHEREFilter) {
        String query;
        List<String> displayFieldNamesLst;
        String photoFieldName;
        List<Wrapper> results = new List<Wrapper>();
        String finalQuery;
        String photoToDisplay;
        
        if(String.isBlank(fieldsPattern)){
            fieldsPattern = displayFieldNames;
        }
        
        //prepare a where clause
        displayFieldNamesLst = displayFieldNames.split(',');
        String whereClause = '';
        if(String.isNotBlank(recordId)){
            whereClause = ' WHERE Id = \'' + recordId + '\'';
        } else {
            for(String fieldName : displayFieldNamesLst){
                whereClause += String.isBlank(whereClause) ? ' WHERE (' + fieldName + ' LIKE \'%{text}%\'' : ' OR ' + fieldName + ' LIKE \'%{text}%\'';
            }
            whereClause += ')';
        }
        //Add Id field to field names if necessary
        if(!displayFieldNames.toLowerCase().contains('id')){
            displayFieldNames += ', Id';
        }
        
        if(String.isNotBlank(additionalWHEREFilter)){ //Include where filter in the query if there's a where filter passed
            whereClause += String.isBlank(whereClause) ? ' WHERE ' + additionalWHEREFilter : ' AND ' + additionalWHEREFilter;
        }
        
        //Add photo field if not added
        if(photoValue.toLowerCase().contains('field')){
            List<String> photoValueLst = photoValue.split('->');
            if(photoValueLst.size() > 1 && !displayFieldNames.toLowerCase().contains(photoValueLst[1].toLowerCase())){
                photoFieldName = photoValueLst[1];
                displayFieldNames += ', '+photoValueLst[1];
            }
        } else if(photoValue.toLowerCase().contains('url')){
            List<String> photoValueLst = photoValue.split('->');
            if(photoValueLst.size() > 1){
                photoToDisplay = photoValueLst[1];
            }
        }
        
        query = 'SELECT ' + displayFieldNames + ' FROM ' + objectName + whereClause + ' LIMIT 200';
        finalQuery = query.replace('{text}', searchText.replace(' ', '%'));
        
        Map<Id, SObject> queryResults = new Map<Id, SObject>(Database.query(finalQuery));
        
        // Retrieve a map of read access values to the search results
        Map<Id, Boolean> hasAccessMap = getReadAccessMapForRecords(queryResults.keySet());
        
        for(Sobject sobj : queryResults.values()){
            String displayValue = fieldsPattern;
            for(String fieldName : displayFieldNamesLst){
                String fieldValue = sobj.get(fieldName) == null ? '' : String.valueOf(sobj.get(fieldName));
                displayValue = displayValue.replace(fieldName, fieldValue);
                if(String.isNotBlank(photoFieldName) && sobj.get(photoFieldName) != null){
                    photoToDisplay = String.valueOf(sobj.get(photoFieldName));
                }
            }
            
            // If the user has access ot the record
            //if (hasAccessMap.get(String.valueOf(sobj.get('Id')))) {
                results.add(new Wrapper(String.valueOf(sobj.get('Id')), displayValue, photoToDisplay, jsfunction));
            //}
        }
        return results;
    }
    
    /**
     * Method to check user reord access
     * @param  Set of ids 
     * @return  Boolean map
     */
    public static Map<Id, Boolean> getReadAccessMapForRecords (Set<Id> recordIds) {

        Map<Id, Boolean> hasAccessMap = new Map<Id, Boolean>();
    
        for (UserRecordAccess recordAccess : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId IN :recordIds]) {
        
            hasAccessMap.put(recordAccess.RecordId, recordAccess.HasReadAccess);
        }
    
        return hasAccessMap;
    }
    
    //Wrapper class
    public class Wrapper{
        //Public variables
        public Id recordId {get; set;}
        public String displayValue {get; set;}
        public String photoUrl {get; set;}
        public String jsfunction {get; set;}
        
        //Constructor
        public Wrapper(Id recordId, String displayValue, String photoUrl, String jsfunction){
            this.recordId = recordId;
            this.displayValue = displayValue;
            this.photoUrl = photoUrl;
            this.jsfunction = jsfunction;
        }
    }
}