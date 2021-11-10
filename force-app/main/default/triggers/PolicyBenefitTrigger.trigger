trigger PolicyBenefitTrigger on Policy_Benefit__c (before insert,before update) {

	if(trigger.isBefore)
	{
		if(trigger.isInsert || trigger.isUpdate){
			/*if(ProviderCustomerHelper.runBenefitOnce()){
				ProviderCustomerHelper.LinkBenefitsToCustomers(trigger.new);
			}*/

			system.debug('**** LinkBenefitsToCustomers');
			List<String> ProviderCustomerNumbers = new List<String>{};
			for(Policy_Benefit__c b : trigger.new){
				if(!String.isEmpty(b.Provider_Customer_Number__c)){
					ProviderCustomerNumbers.add(b.Provider_Customer_Number__c.toUpperCase());
				}
			}
			system.debug('**** ProviderCustomerNumbers ' + ProviderCustomerNumbers);
			Map<String,Customer_Provider_Code__c> ProviderCustomerNumberMap = ProviderCustomerHelper.getProviderCustomerNumbers(ProviderCustomerNumbers);
			system.debug('**** ProviderCustomerNumberMap ' + ProviderCustomerNumberMap);
			for(Policy_Benefit__c b : trigger.new){
				if(!String.isEmpty(b.Provider_Customer_Number__c)){
					if(ProviderCustomerNumberMap.containsKey(b.Provider_Customer_Number__c.toUpperCase())){
						if(b.Account__c==null){
							system.debug('**** ProviderCustomerNumberMap toUpperCase ' + ProviderCustomerNumberMap.containsKey(b.Provider_Customer_Number__c.toUpperCase()));
							system.debug('**** ProviderCustomerNumberMap toUpperCase ' + b.Provider_Customer_Number__c.toUpperCase());
							b.Account__c = ProviderCustomerNumberMap.get(b.Provider_Customer_Number__c.toUpperCase()).Customer__c;
							system.debug('**** b.Account__c ' + b.Account__c);
						}
					}
				}
			}
		}
	}
}