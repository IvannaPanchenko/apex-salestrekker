/**
* @author Jacob Taljaard (jacob@cloudinit.nz)
* @date June, 30, 2018
* @description Helper class for RelationshipTrigger
*
* CHANGE LOG
**/
public without sharing class RelationshipTriggerHelper {


	/**
	* @author Jacob Taljaard (jacob@cloudinit.nz)
	* @date June, 30, 2018
	* @description Method below will check if there is a relationship for the account of the same recordtype - if not, it will create it
	*
	* CHANGE LOG
	**/
	public static void checkRelatedRelationshipAccount(List<Relationship__c> newRelationships, List<Relationship__c> oldRelationships, Boolean isDelete, Boolean isInsert){

			//first build a map of all the relationships by external id
			System.debug('***** in handler');
			Set<String> RelationshipTypes = new Set<String>{};
			RelationshipTypes.addAll(Label.RelationshipTypesToClone.split(','));
			Set<String> familyMemberRelationshipTypes = FactFindingControllerSelector.getRelationshipTypeNamesByType(ApexAkina_Constants.FAMILY_MEMBER_RELATIONSHIP_TYPE);
			Set<String> relationshipsToDelete = new Set<String>{};
			Map<String,Relationship__c> RelationShipsMap = new Map<String,Relationship__c>{};
			Set<Id> accountIds = new Set<Id>();
			Map<String, Relationship__c> mapExternalPartnerIds = new Map<String, Relationship__c>();
			List<Relationship__c> toCreate = new List<Relationship__c>{};

			System.debug('***** in familyMemberRelationshipTypes - ' + familyMemberRelationshipTypes);

			// if it's insert or update
			if (isInsert) {
				for(Relationship__c relationship : newRelationships){
					accountIds.add(relationship.Account__c);
					//only add the relationship types defined
					if(RelationshipTypes.contains(relationship.Relationship_Type__c)){
						RelationShipsMap.put(relationship.External_Id__c,relationship);
					}
				}
				System.debug('***** in RelationShipsMap - ' + RelationShipsMap);

				// search for the partners of the account if any
				Map<Id, Account> partnerAccounts = new Map<Id, Account>([SELECT Id, Partner__c FROM Account WHERE Id IN :accountIds]);

				System.debug('***** in partnerAccounts - ' + partnerAccounts);

				//now build a list of the opposite relationships
				Map<String, String> OppositeRelationships = new Map<String, String>{};
				for (Relationship__c relationship : newRelationships) {
					//only add the relationship types defined
					if (RelationshipTypes.contains(relationship.Relationship_Type__c)) {
						if (familyMemberRelationshipTypes.contains(relationship.Relationship_Type__c)) {
							OppositeRelationships.put(relationship.External_Id__c, relationship.Related_Account__c + '' + relationship.Account__c + '' + ApexAkina_Constants.FAMILY_MEMBER_OPPOSITE_RELATIONSHIP_TYPE.get(relationship.Relationship_Type__c));

							// add the external id for partners to the map if we have partner
							if (partnerAccounts.get(relationship.Account__c).Partner__c != null) {
								mapExternalPartnerIds.put(partnerAccounts.get(relationship.Account__c).Partner__c + '' + relationship.Related_Account__c + '' + relationship.Relationship_Type__c, relationship);
							}

						} else {
							OppositeRelationships.put(relationship.External_Id__c, relationship.Related_Account__c + '' + relationship.Account__c + '' + relationship.Relationship_Type__c);
						}
					}
				}
				System.debug('***** in OppositeRelationships - ' + OppositeRelationships);

				System.debug('***** in mapExternalPartnerIds - ' + mapExternalPartnerIds);

				// add the relationship for the partner if any
				if (mapExternalPartnerIds.size() > 0) {
					Map<String, Relationship__c> relationshipPartners = new Map<String, Relationship__c>();

					for (Relationship__c rel : [SELECT Id, External_Id__c FROM Relationship__c WHERE External_Id__c IN :mapExternalPartnerIds.keySet()]) {
						relationshipPartners.put(rel.External_Id__c, rel);
					}

					for (String extId : mapExternalPartnerIds.keySet()) {
						if (!relationshipPartners.containsKey(extId)) {
							toCreate.add(new Relationship__c(Related_Account__c = mapExternalPartnerIds.get(extId).Related_Account__c,
									Account__c = partnerAccounts.get(mapExternalPartnerIds.get(extId).Account__c).Partner__c,
									Relationship_Type__c = mapExternalPartnerIds.get(extId).Relationship_Type__c,
									External_Id__c = partnerAccounts.get(mapExternalPartnerIds.get(extId).Account__c).Partner__c + '' + mapExternalPartnerIds.get(extId).Related_Account__c + '' + mapExternalPartnerIds.get(extId).Relationship_Type__c
							));
						}
					}
				}

				//then check if there are the oposite relationships created i.e. if the list above had a husband, then the list below must have a wife if not create wife
				Map<String, Set<String>> OriginalRelationships = new Map<String, Set<String>>{};
				for (Relationship__c relationship : [
						SELECT Id,External_Id__c,Account__c,Related_Account__c, Relationship_Type__c
						FROM Relationship__c
						WHERE External_Id__c IN :OppositeRelationships.keySet()
				]) {
					if (!OriginalRelationships.containsKey(relationship.Related_Account__c + '' + relationship.Account__c + '' + relationship.Relationship_Type__c)) {
						OriginalRelationships.put(relationship.Related_Account__c + '' + relationship.Account__c + '' + relationship.Relationship_Type__c, new Set<String>());
					}

					OriginalRelationships.get(relationship.Related_Account__c + '' + relationship.Account__c + '' + relationship.Relationship_Type__c).add(relationship.External_Id__c);//this is the opposite of the original
				}
				System.debug('***** in OriginalRelationships - ' + OriginalRelationships);

				//now that we have the relationships and the opposites, let's check if there are a matching opposite
				for (String OriginalExternalId : RelationShipsMap.keySet()) {
					if (!OriginalRelationships.containsKey(OriginalExternalId)) {
						String type = RelationShipsMap.get(OriginalExternalId).Relationship_Type__c;

						System.debug('***** Relationship does not exist can create');
						Relationship__c newRelationship = new Relationship__c();
						newRelationship.Account__c = RelationShipsMap.get(OriginalExternalId).Related_Account__c;
						newRelationship.Related_Account__c = RelationShipsMap.get(OriginalExternalId).Account__c;
						newRelationship.Description__c = RelationShipsMap.get(OriginalExternalId).Description__c;

						// if it's a family relationship then add the parent one
						if (familyMemberRelationshipTypes.contains(type)) {
							type = ApexAkina_Constants.FAMILY_MEMBER_OPPOSITE_RELATIONSHIP_TYPE.get(type);
						}
						newRelationship.Relationship_Type__c = type;
						newRelationship.External_Id__c = RelationShipsMap.get(OriginalExternalId).Related_Account__c + '' + RelationShipsMap.get(OriginalExternalId).Account__c + '' + type;
						toCreate.add(newRelationship);
					}
				}
				System.debug('***** in toCreate - ' + toCreate);
				if (toCreate.size() > 0) {
					upsert toCreate External_Id__c;
				}
			} else {
				// if it's deleting
				if (isDelete) {
					for (Relationship__c relationship : oldRelationships) {
						String type = relationship.Relationship_Type__c;

						// if it's in the types to clone
						if (RelationshipTypes.contains(type)) {
							// if it's a family relationship then add the parent one and the partner
							if (familyMemberRelationshipTypes.contains(type)) {
								type = ApexAkina_Constants.FAMILY_MEMBER_OPPOSITE_RELATIONSHIP_TYPE.get(type);
							}
							relationshipsToDelete.add(relationship.Related_Account__c + '' + relationship.Account__c + '' + type);
						} else if (ApexAkina_Constants.FAMILY_MEMBER_OPPOSITE_RELATIONSHIP_TYPE.containsKey(type)) {
							// if type is parent then try to delete any family relationship related
							for (String relType : familyMemberRelationshipTypes) {
								relationshipsToDelete.add(relationship.Related_Account__c + '' + relationship.Account__c + '' + relType);
							}
						}
					}

					delete [SELECT Id FROM Relationship__c WHERE External_Id__c IN :relationshipsToDelete];
				}
			}
		}
}