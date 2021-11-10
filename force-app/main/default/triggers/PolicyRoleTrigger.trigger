trigger PolicyRoleTrigger on Policy_Role__c (before insert,before update) {

	if(trigger.isBefore)
	{
		if(trigger.isInsert || trigger.isUpdate){
			/*if(ProviderCustomerHelper.runPolicyRoleOnce()){
				ProviderCustomerHelper.LinkPolicyRoleToCustomers(trigger.new);
			}*/

			system.debug('**** LinkBenefitsToCustomers');
			List<String> ProviderCustomerNumbers = new List<String>{};
			for(Policy_Role__c p : trigger.new){
				if(!String.isEmpty(p.Provider_Customer_Number__c)){
					ProviderCustomerNumbers.add(p.Provider_Customer_Number__c.toUpperCase());
				}
			}
			system.debug('**** ProviderCustomerNumbers ' + ProviderCustomerNumbers);
			Map<String,Customer_Provider_Code__c> ProviderCustomerNumberMap = ProviderCustomerHelper.getProviderCustomerNumbers(ProviderCustomerNumbers);
			system.debug('**** ProviderCustomerNumberMap ' + ProviderCustomerNumberMap);
			
			for(Policy_Role__c p : trigger.new){
				if(!String.isEmpty(p.Provider_Customer_Number__c)){
					if(ProviderCustomerNumberMap.containsKey(p.Provider_Customer_Number__c.toUpperCase())){
						if(p.Account__c==null){
							system.debug('**** ProviderCustomerNumberMap toUpperCase ' + ProviderCustomerNumberMap.containsKey(p.Provider_Customer_Number__c.toUpperCase()));
							p.Account__c = ProviderCustomerNumberMap.get(p.Provider_Customer_Number__c.toUpperCase()).Customer__c;
							system.debug('**** b.Account__c ' + p.Account__c);
						}
					}
				}
			}

		}
	}

}