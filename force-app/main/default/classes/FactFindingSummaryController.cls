/**
* @author Pablo Martinez (pablomartinez@cdeloitte.co.nz)
* @date 25/07/2019
* @description
*
**/

public without sharing class FactFindingSummaryController {
    // parameters / attributes
    public Id mainAccountId {get;set;}
    public Id partnerAccountId {get;set;}
    public Fact_Find__c factFindAttr {get; set;}
    public List<Account> accountsAttr {get; set;}
    public List<Object> familyMembersAttr {get; set;}
    public List<Account> legalEntitiesAttr {get; set;}
    public List<Goal__c> goalsAttr {get; set;}
    public List<Object> assetsAttr {get; set;}
    public List<Object> liabilitiesAttr {get; set;}
    public List<Object> incomesExpensesAttr {get; set;}

    // variables to use
    public Decimal totalAssets {get; set;}
    public List<Decimal> totalLiabilities {get; set;}
    public List<Decimal> totalIncomeExpenses {get; set;}
    public Map<String, List<Policy__c>> mapPolicies {get; set;}
    public Map<Id, List<Policy_Role__c>> mapPolicyRolesByIds {get; set;}
    public Map<Id, List<Policy_Benefit__c>> mapPolicyBenefitsByIds {get; set;}
    public Map<String, Map<String, Decimal>> beneficiarySummaryMap {get; set;}
    public Boolean mainAccountWaiverofPremium {get;set;}
    public Boolean partnerAccountWaiverofPremium {get;set;}

    // Constants with the types
    public Set<String> benefitTypes {
        get {
            return ApexAkina_Constants.benefitsTypes;
        }
        set;
    }

    // PRINT VARIABLES
    public String baseUrl {
        get {
            return Url.getSalesforceBaseUrl().toExternalForm();
        }
        set;
    }

    public String printOptions {
        get {
            if (ApexPages.currentPage().getParameters().containsKey('print')) {
                return String.join(new List<String>(ApexPages.currentPage().getParameters().keySet()), ',');
            }
            return null;
        }
        set;
    }

    public Decimal netWorth {
        get {
            return totalAssets - totalLiabilities[0];
        }
        set;
    }
    public Decimal disposableIncome {
        get {
            return totalIncomeExpenses[0] + totalIncomeExpenses[1] - (totalIncomeExpenses[2] * 12);
        }
        set;
    }

    public Set<Id> accountIds {
        get {
            accountIds = new Set<Id>{mainAccountId};

            if (partnerAccountId != null) {
                accountIds.add(partnerAccountId);
            }

            return accountIds;
        }
        set;
    }

    public List<FactFindingControllerService.FamilyMemberWrapper> allFamilyMembers {
        get {
            if (familyMembersAttr == null) {
                if (allFamilyMembers == null) {
                    allFamilyMembers = FactFindingControllerService.getAllFamilyMembers(new Set<Id>{mainAccountId}, new Set<String>(relationshipTypes.get(ApexAkina_Constants.FAMILY_MEMBER_RELATIONSHIP_TYPE)));
                }
            } else {
                allFamilyMembers = (List<FactFindingControllerService.FamilyMemberWrapper>) JSON.deserialize(JSON.serialize(familyMembersAttr), List<FactFindingControllerService.FamilyMemberWrapper>.class);
            }

            return allFamilyMembers;
        }
        set;
    }

    public Fact_Find__c theFactFind {
        get {
            if (factFindAttr == null) {
                if (theFactFind == null) {
                    List<Fact_Find__c> factFinds = FactFindingControllerSelector.getFactFinds(mainAccountId, null);

                    if (factFinds != null && !factFinds.isEmpty()) {
                        theFactFind = factFinds[0];
                    }
                    theFactFind = new Fact_Find__c();
                }
            }
            else {
                theFactFind = factFindAttr;
            }

            return theFactFind;
        }
        set;
    }

    public Map<Id, Account> mapAccountsByIds {
        get {
            mapAccountsByIds = new Map<Id, Account>();

            for (AccountSummaryWrapper acc : theAccounts) {
                // add to the map
                if (!mapAccountsByIds.containsKey(acc.account.Id)) {
                    mapAccountsByIds.put(acc.account.Id, acc.account);
                }
            }

            return mapAccountsByIds;
        }
        set;
    }

    public List<AccountSummaryWrapper> theAccounts {
        get {
            if (accountsAttr == null) {
                if (theAccounts == null) {
                    theAccounts = new List<AccountSummaryWrapper>();
                    for (Account acc : FactFindingControllerSelector.getAccountByIds(accountIds)) {
                        // add to the list
                        theAccounts.add(new AccountSummaryWrapper(acc, FactFindingControllerSelector.getEmploymentDetailsByAccountId(acc.Id), theFactFind.Chosen_Not_to_Provide_Employment_Details__c));
                    }
                }
            } else {
                theAccounts = new List<AccountSummaryWrapper>();

                for (Account acc : accountsAttr) {
                    // add to the list
                    theAccounts.add(new AccountSummaryWrapper(acc, FactFindingControllerSelector.getEmploymentDetailsByAccountId(acc.Id), theFactFind.Chosen_Not_to_Provide_Employment_Details__c));
                }
            }

            return theAccounts;
        }
        set;
    }

    public Map<String, List<String>> relationshipTypes {
        get {
            if (relationshipTypes == null) {
                relationshipTypes = FactFindingControllerService.getMapRelationshipTypes();
            }
            return relationshipTypes;
        }
        set;
    }

    public List<FactFindingControllerService.FamilyMemberWrapper> theDependants {
        get {
            theDependants = new List<FactFindingControllerService.FamilyMemberWrapper>();
            for (FactFindingControllerService.FamilyMemberWrapper frWrapper : allFamilyMembers) {
                if (frWrapper.relationship.Dependant__c == 'Yes') {
                    theDependants.add(frWrapper);
                }
            }

            return theDependants;
        }
        set;
    }

    public List<FactFindingControllerService.FamilyMemberWrapper> theOtherFamily {
        get {
            theOtherFamily = new List<FactFindingControllerService.FamilyMemberWrapper>();
            for (FactFindingControllerService.FamilyMemberWrapper frWrapper : allFamilyMembers) {
                if (frWrapper.relationship.Dependant__c == 'No') {
                    theOtherFamily.add(frWrapper);
                }
            }

            return theOtherFamily;
        }
        set;
    }

    public Map<Id, Account> theLegalEntities {
        get {
            if (legalEntitiesAttr == null) {
                if (theLegalEntities == null) {
                    theLegalEntities = new Map<Id, Account>();
                    Set<Id> legalEntityIds = new Set<Id>();
                    Set<Id> accountsIdsToQuery = new Set<Id>(accountIds);
                    // add the ids for dependants
                    for (FactFindingControllerService.FamilyMemberWrapper frWrapper : theDependants) {
                        accountsIdsToQuery.add(frWrapper.account.Id);
                    }

                    for (Relationship__c relationship : FactFindingControllerSelector.getRelationshipsByAccountIdsAndType(accountsIdsToQuery, new Set<String>(relationshipTypes.get(ApexAkina_Constants.OTHERENTITIES_RELATIONSHIP_TYPE)))) {
                        legalEntityIds.add(relationship.Related_Account__c);
                    }

                    // get the accounts
                    theLegalEntities = new Map<Id, Account>(FactFindingControllerSelector.getAccountByIds(legalEntityIds));
                }
            }
            else {
                theLegalEntities = new Map<Id, Account>(legalEntitiesAttr);
            }

            return theLegalEntities;
        }
        set;
    }

    public List<Goal__c> theGoals {
        get {
            if (goalsAttr == null) {
                theGoals = new List<Goal__c>();
                for (Goal__c goal : FactFindingControllerSelector.getGoalsByAccountIds(accountIds)) {
                    if (goal.RecordTypeId == ApexAkina_Constants.FINANCIAL_RECTYPE) {
                        theGoals.add(goal);
                    }
                }
            }
            else {
                theGoals = goalsAttr;
            }

            return theGoals;
        }
        set;
    }

    public List<Non_Apex_Cover__c> theNonApexCover{
        get{
            
            theNonApexCover = FactFindingControllerSelector.getNonApexCover(accountIds);
            return theNonApexCover;

        }
        set;
    }

    public List<FactFindingControllerService.AssetRoleWrapper> theAssets {
        get {
            totalAssets = 0;
            if (assetsAttr == null) {
                theAssets = new List<FactFindingControllerService.AssetRoleWrapper>();
                Set<Id> accountsIdsToQuery = new Set<Id>(accountIds);
                accountsIdsToQuery.addAll(theLegalEntities.keySet());
                totalAssets = FactFindingControllerService.getAssets(accountsIdsToQuery, new Map<Id, List<Asset_Role__c>>(), theAssets, true, theFactFind);
            }
            else {
                theAssets = (List<FactFindingControllerService.AssetRoleWrapper>) JSON.deserialize(JSON.serialize(assetsAttr), List<FactFindingControllerService.AssetRoleWrapper>.class);
                for (FactFindingControllerService.AssetRoleWrapper asRole : theAssets) {
                    asRole.strOwnerType = asRole.assetRole.Account__r.Name;
                    if (!theFactFind.No_Assets__c && !theFactFind.Chosen_Not_to_Provide_Asset_Details__c && asRole.asset.Value__c != null) {
                        totalAssets += asRole.asset.Value__c;
                    }
                }
            }

            return theAssets;
        }
        set;
    }

    public List<FactFindingControllerService.LiabilityRoleWrapper> theLiabilities {
        get {
            totalLiabilities = new List<Decimal>{0,0};
            if (liabilitiesAttr == null) {
                theLiabilities = new List<FactFindingControllerService.LiabilityRoleWrapper>();
                Set<Id> accountsIdsToQuery = new Set<Id>(accountIds);
                accountsIdsToQuery.addAll(theLegalEntities.keySet());
                totalLiabilities = FactFindingControllerService.getLiabilities(accountsIdsToQuery, new Map<Id, List<Liability_Role__c>>(), theLiabilities, new List<FactFindingControllerService.LiabilityRoleWrapper>(), true, theFactFind);
            }
            else {
                theLiabilities = (List<FactFindingControllerService.LiabilityRoleWrapper>) JSON.deserialize(JSON.serialize(liabilitiesAttr), List<FactFindingControllerService.LiabilityRoleWrapper>.class);
                for (FactFindingControllerService.LiabilityRoleWrapper liabRole : theLiabilities) {
                    liabRole.strOwnerType = liabRole.liabilityRole.Account__r.Name;
                    if (!theFactFind.No_Liabilities__c && !theFactFind.Chosen_Not_to_Provide_Liability_Details__c && liabRole.liability.Current_Balance__c != null) {
                        totalLiabilities[0] += liabRole.liability.Current_Balance__c;
                    }
                }
            }

            return theLiabilities;
        }
        set;
    }

    public Map<String, List<FactFindingControllerService.IncomeExpenseWrapper>> theIncomesAndExpenses {
        get {
            totalIncomeExpenses = new List<Decimal>{0,0,0};
            theIncomesAndExpenses = new Map<String, List<FactFindingControllerService.IncomeExpenseWrapper>>{'Income' => new List<FactFindingControllerService.IncomeExpenseWrapper>(), 'Expense' => new List<FactFindingControllerService.IncomeExpenseWrapper>()};
            if (incomesExpensesAttr == null) {
                Map<String, List<FactFindingControllerService.IncomeExpenseWrapper>> theIncomesAndExpensesMap = new Map<String, List<FactFindingControllerService.IncomeExpenseWrapper>>{'Client 1 - Income' => new List<FactFindingControllerService.IncomeExpenseWrapper>(), 'Client 1 - Expenses' => new List<FactFindingControllerService.IncomeExpenseWrapper>(), ApexAkina_Constants.CLIENT_2 => new List<FactFindingControllerService.IncomeExpenseWrapper>()};
                totalIncomeExpenses = FactFindingControllerService.getIncomeExpenses(accountIds, theIncomesAndExpensesMap, mainAccountId, theFactFind, null);

                for (String key : theIncomesAndExpensesMap.keySet()) {
                    if (key != 'Client 1 - Expenses') {
                        theIncomesAndExpenses.get('Income').addAll(theIncomesAndExpensesMap.get(key));
                    } else {
                        theIncomesAndExpenses.get('Expense').addAll(theIncomesAndExpensesMap.get(key));
                    }
                }

            }
            else {
                List<FactFindingControllerService.IncomeExpenseWrapper> incExpDetail = (List<FactFindingControllerService.IncomeExpenseWrapper>) JSON.deserialize(JSON.serialize(incomesExpensesAttr), List<FactFindingControllerService.IncomeExpenseWrapper>.class);

                for (FactFindingControllerService.IncomeExpenseWrapper incExp : incExpDetail) {
                    if(incExp.incomeExpense.RecordTypeId == ApexAkina_Constants.INCOME_RECTYPE && !theFactFind.Chosen_Not_to_Provide_Income_Details__c){
                        theIncomesAndExpenses.get('Income').add(incExp);
                        totalIncomeExpenses[incExp.incomeExpense.Primary_Owner__c == mainAccountId ? 0 : 1] += incExp.incomeExpense.Amount__c != null ? incExp.incomeExpense.Amount__c : 0;
                    } else if (incExp.incomeExpense.RecordTypeId == ApexAkina_Constants.EXPENSE_RECTYPE && !theFactFind.Chosen_Not_to_Provide_Expense_Details__c && !theFactFind.Do_not_Know_What_Are_My_Expenses__c) {
                        theIncomesAndExpenses.get('Expense').add(incExp);
                        totalIncomeExpenses[2] += incExp.incomeExpense.Amount__c != null ? incExp.incomeExpense.Amount__c : 0;
                    }
                }
            }

            return theIncomesAndExpenses;
        }
        set;
    }


    public List<String> listPolicyTypes {
        get {
            Set<Id> policyIds = new Set<Id>();
            mapPolicies = new Map<String, List<Policy__c>>();
            listPolicyTypes = new List<String>();
            mapPolicyBenefitsByIds = new Map<Id, List<Policy_Benefit__c>>();
            mapPolicyRolesByIds = new Map<Id, List<Policy_Role__c>>();
            beneficiarySummaryMap = new Map<String, Map<String, Decimal>>();

            // get the policies from policy role
            for (Policy__c polRole : FactFindingControllerSelector.getPolicyWithRoles(accountIds)) {
                if (!policyIds.contains(polRole.Id)) {
                    policyIds.add(polRole.Id);

                    if (!mapPolicies.containsKey(polRole.Type__c)) {
                        mapPolicies.put(polRole.Type__c, new List<Policy__c>());
                        listPolicyTypes.add(polRole.Type__c);
                    }

                    // add to the policies map
                    mapPolicies.get(polRole.Type__c).add(polRole);

                    // add to the roles map
                    if (!mapPolicyRolesByIds.containsKey(polRole.Id)) {
                        mapPolicyRolesByIds.put(polRole.Id, new List<Policy_Role__c>());
                    }

                    // add to the benefits map
                    if (!mapPolicyBenefitsByIds.containsKey(polRole.Id)) {
                        mapPolicyBenefitsByIds.put(polRole.Id, new List<Policy_Benefit__c>());
                    }

                    mapPolicyRolesByIds.get(polRole.Id).addAll(polRole.Policy_Owners__r);
                }
            }

            // get the other policies from benefits for the policy owners
            for (Policy__c polBenefit : FactFindingControllerSelector.getPolicyWithBenefitsForPolicyOwners(accountIds)) {
                if (!policyIds.contains(polBenefit.Id)) {
                    mapPolicyRolesByIds.put(polBenefit.Id, new List<Policy_Role__c>());

                    if (!mapPolicies.containsKey(polBenefit.Type__c)) {
                        mapPolicies.put(polBenefit.Type__c, new List<Policy__c>());
                        listPolicyTypes.add(polBenefit.Type__c);
                    }

                    // add to the policies map
                    mapPolicies.get(polBenefit.Type__c).add(polBenefit);
                }

                // add to the benefits map
                if (!mapPolicyBenefitsByIds.containsKey(polBenefit.Id)) {
                    mapPolicyBenefitsByIds.put(polBenefit.Id, new List<Policy_Benefit__c>());
                }

                mapPolicyBenefitsByIds.get(polBenefit.Id).addAll(polBenefit.Benefits__r);
            }

            // get the other policies from where the owners are beneficiary
            for (Policy__c polBenefit : FactFindingControllerSelector.getPolicyWithOwnersAsBeneficiaries(accountIds)) {
                if (!policyIds.contains(polBenefit.Id)) {

                    if (!mapPolicies.containsKey(polBenefit.Type__c)) {
                        mapPolicies.put(polBenefit.Type__c, new List<Policy__c>());
                        listPolicyTypes.add(polBenefit.Type__c);
                    }

                    // add to the policies map
                    mapPolicies.get(polBenefit.Type__c).add(polBenefit);
                }

                // add to the benefits map
                if (!mapPolicyBenefitsByIds.containsKey(polBenefit.Id)) {
                    mapPolicyBenefitsByIds.put(polBenefit.Id, polBenefit.Benefits__r);
                }

                if (!mapPolicyRolesByIds.containsKey(polBenefit.Id)) {
                    mapPolicyRolesByIds.put(polBenefit.Id, polBenefit.Policy_Owners__r);
                }
            }

            // populate the types with the constants
            Map<String, Decimal> mapAmountByType = new Map<String, Decimal>();

            for (String type : benefitTypes) {
                if (!mapAmountByType.containsKey(type)) {
                    mapAmountByType.put(type, 0);
                }
            }
            
            // create a list of the beneficiaries for the summary part
            for (Id policyId : mapPolicyBenefitsByIds.keySet()) {

                for (Policy_Benefit__c beneficiary : mapPolicyBenefitsByIds.get(policyId)) {

                    // if it's not the main account or partner account
                    if (!accountIds.contains(beneficiary.Account__c)) {

                        // check if we already have it
                        if (!beneficiarySummaryMap.containsKey(beneficiary.Account__r.Client_Preferred_Name__c)) {
                            beneficiarySummaryMap.put(beneficiary.Account__r.Client_Preferred_Name__c, new Map<String, Decimal>(mapAmountByType));
                        }

                        // get the map and sum
                        Map<String, Decimal> mapAmountByTypeForAccount = beneficiarySummaryMap.get(beneficiary.Account__r.Client_Preferred_Name__c);

                        // if type is health then add a 1 for Yes (0 is No)
                        if (beneficiary.Type__c == 'Health') {

                            mapAmountByTypeForAccount.put(beneficiary.Type__c, 1);
                        }
                        // If anything else, update if not missing the type
                        else if (mapAmountByTypeForAccount.containsKey(beneficiary.Type__c)) {

                            mapAmountByTypeForAccount.put(
                                beneficiary.Type__c, 
                                mapAmountByTypeForAccount.get(beneficiary.Type__c) + (beneficiary.Sum_Insured__c != null ? beneficiary.Sum_Insured__c : 0)
                            );
                        }
                    } else {

                        // if it's waiver of premium
                        if (beneficiary.Name.contains('Waiver of Premium')) {
                            // if it's main account
                            if (beneficiary.Account__c == mainAccountId) {
                                mainAccountWaiverofPremium = true;
                            }

                            // if it's partner account
                            if (beneficiary.Account__c == partnerAccountId) {
                                partnerAccountWaiverofPremium = true;
                            }
                        }
                    }
                }
            }

            // order ascending
            listPolicyTypes.sort();

            // order descending
            List<String> finalList = new List<String>();
            for(Integer i = listPolicyTypes.size() -1; i >= 0; i--) {
                finalList.add(listPolicyTypes.get(i));
            }
            // assign the value
            listPolicyTypes = finalList;

            return listPolicyTypes;
        }
        set;
    }

    public List<Client_Asset__c> listAssetsPolicies {
        get {
            if (listAssetsPolicies == null) {
                listAssetsPolicies = FactFindingControllerSelector.getAssetsForPolicies(accountIds);
            }
            return listAssetsPolicies;
        }
        set;
    }

    public List<Liability__c> listLiabilitiesPolicies {
        get {
            if (listLiabilitiesPolicies == null) {
                listLiabilitiesPolicies = FactFindingControllerSelector.getLiabilitiesForPolicies(accountIds);
            }
            return listLiabilitiesPolicies;
        }
        set;
    }

    // empty checks
    public Boolean getIsDependantEmpty() {
        return theDependants.size() == 0 || theFactFind.No_Dependents__c || theFactFind.Chosen_Not_to_Provide_Dependents_Details__c;
    }

    public Boolean getIsOtherFamilyEmpty() {
        return theOtherFamily.size() == 0 || theFactFind.No_Dependents__c || theFactFind.Chosen_Not_to_Provide_Dependents_Details__c;
    }

    public Boolean getIsLegalEntitiesEmpty() {
        return theLegalEntities.size() == 0 || theFactFind.No_Other_Entities__c || theFactFind.Chosen_Not_to_Provide_Other_Entities__c;
    }

    public Boolean getIsIncomesEmpty() {
        return theIncomesAndExpenses.get('Income').isEmpty() || theFactFind.Chosen_Not_to_Provide_Income_Details__c;
    }

    public Boolean getIsExpensesEmpty() {
        return theIncomesAndExpenses.get('Expense').isEmpty();
    }

    public Boolean getIsAssetsEmpty() {
        return theAssets.size() == 0 || theFactFind.No_Assets__c || theFactFind.Chosen_Not_to_Provide_Asset_Details__c;
    }

    public Boolean getIsLiabilitiesEmpty() {
        return theLiabilities.size() == 0 || theFactFind.No_Liabilities__c || theFactFind.Chosen_Not_to_Provide_Liability_Details__c;
    }

    public class AccountSummaryWrapper {
        public Account account {get; set;}
        public String employment {get; set;}

        public AccountSummaryWrapper(Account account, List<Employment_Detail__c> employments, Boolean chosenNotToProvide) {
            this.account = account;

            if (chosenNotToProvide) {
                this.employment = 'You choose not  to provide these details';
            } else {
                if (employments != null) {
                    this.employment = '';
                    for (Employment_Detail__c emp : employments) {
                        if (emp.Current_Occupation__c) {
                            this.employment += emp.Job_Title__c + (emp.Employer__c != null ? ' - ' + emp.Employer__c + '. ' : '. ');
                        }
                    }
                } else {
                    this.employment = '';
                }
            }
        }
    }

}