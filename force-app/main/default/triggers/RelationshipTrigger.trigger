trigger RelationshipTrigger on Relationship__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if (Trigger.isBefore) {
	    	//call your handler.before method
	    	if(Trigger.isInsert || Trigger.isUpdate) {
	    		for(Relationship__c relationship : Trigger.new) {
					//set the external id for the relationshipt record
					relationship.External_Id__c = relationship.Account__c + '' + relationship.Related_Account__c + '' + relationship.Relationship_Type__c;
				}
	    	}
	    
		} else if (Trigger.isAfter) {
	    	if (Trigger.isInsert || Trigger.isDelete) {
                //check the relationships
                RelationshipTriggerHelper.checkRelatedRelationshipAccount(Trigger.new, Trigger.old, Trigger.isDelete, Trigger.isInsert);
            }
		}
}