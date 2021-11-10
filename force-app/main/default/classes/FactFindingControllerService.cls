/**
* @author David (david@cloudinit.nz)
* @date May 30, 2018
* @description Service class for Fact Find page
*
**/
public class FactFindingControllerService {

    //Method to format string to date.
    public static String formatStringToDate(String dateValue){
        List<String> dateParts = dateValue.split('/');
        if(dateParts.size() == 3){
            return dateParts.get(2) + '-' + dateParts.get(1) + '-' + dateParts.get(0);
        }
        return '';
    }

    //Method to format date to string.
    public static String formatDateToString(String dateValue){
        List<String> dateParts = dateValue.split('/');
        if(dateParts.size() == 3){
            return dateParts.get(0) + '/' + dateParts.get(1) + '/' + dateParts.get(2);
        }
        return '';
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to generate random string.
    **/
    public static String generateRandomString(Integer length) {
        // Return random generate string
        return EncodingUtil.convertToHex(Crypto.generateAesKey(256)).substring(0, length);
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to get the assets by reference with asset roles from the FactFindingController and FactFindingSummary and return the total
    *   @params {
    *       ownerTypeName: if it's true, return the name instead of the id in the strOwnerType
    *   }
    **/
    public static Decimal getAssets (Set<Id> clientIds, Map<Id, List<Asset_Role__c>> mapAssetAssetRole, List<AssetRoleWrapper> assetRoleWrappers, Boolean ownerTypeNames, Fact_Find__c theFactFindSummary) {
        Decimal total = 0;
        //Iterating over Asset Roles Retrieved
        for(Asset_Role__c assetRole : FactFindingControllerSelector.getAssetRoles(clientIds)) {

            if(assetRole.Asset__r.Value__c > 0){

                //Create a Map of Asset and Asset Roles
                if(!mapAssetAssetRole.containsKey(assetRole.Asset__c)){
                    mapAssetAssetRole.put(assetRole.Asset__c, new List<Asset_Role__c>());
                }

                mapAssetAssetRole.get(assetRole.Asset__c).add(assetRole);
            }
        }

        //Iterating over the AssetAssetRoleMap
        for(Id assetId : mapAssetAssetRole.keySet()){
            Asset_Role__c theAssetRole = mapAssetAssetRole.get(assetId)[0];

            AssetRoleWrapper assetRoleWrapper = new AssetRoleWrapper();

            // add the asset role
            assetRoleWrapper.assetRole = theAssetRole;
            // add the asset to the wrapper
            assetRoleWrapper.asset = theAssetRole.Asset__r;

            if(mapAssetAssetRole.get(assetId).size() > 1) {
                assetRoleWrapper.strOwnerType = ApexAkina_Constants.JOINT;
            }
            else {
                // other or the actual id
                assetRoleWrapper.strOwnerType = (ownerTypeNames ? theAssetRole.Account__r.Name : theAssetRole.Account__c);

            }
            // add to the list
            assetRoleWrappers.add(assetRoleWrapper);

            if (((theFactFindSummary != null && !theFactFindSummary.Chosen_Not_to_Provide_Asset_Details__c && !theFactFindSummary.No_Assets__c) || theFactFindSummary == null) && assetRoleWrapper.asset.Value__c != null) {
                total += assetRoleWrapper.asset.Value__c;
            }
        }

        return total;
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to get the liabilities by reference with liabilities roles from the FactFindingController and FactFindingSummary and return the totals
    *   @params {
    *       ownerTypeName: if it's true, return the name instead of the id in the strOwnerType
    *   }
    **/
    public static List<Decimal> getLiabilities (Set<Id> clientIds, Map<Id, List<Liability_Role__c>> mapLiabilityRoles, List<LiabilityRoleWrapper> liabilityRoleWrappers, List<LiabilityRoleWrapper> contingentLiabilityWrappers, Boolean ownerTypeNames, Fact_Find__c theFactFindSummary) {
        List<Decimal> totals = new List<Decimal>{0,0};
        //Iterating over Liabilities Roles Retrieved
        for(Liability_Role__c liabilityRole : FactFindingControllerSelector.getLiabilityRoles(clientIds)){

            //Create a Map of Liabilities and LiabilityRoles
            if(!mapLiabilityRoles.containsKey(liabilityRole.Liability__c)){
                mapLiabilityRoles.put(liabilityRole.Liability__c, new List<Liability_Role__c>());
            }

            mapLiabilityRoles.get(liabilityRole.Liability__c).add(liabilityRole);
        }

        //Iterating over the mapLiabilityRoles
        for(Id liabilityId : mapLiabilityRoles.keySet()){
            Liability_Role__c theLiabilityRole = mapLiabilityRoles.get(liabilityId)[0];

            FactFindingControllerService.LiabilityRoleWrapper liabilityRoleWrapper = new FactFindingControllerService.LiabilityRoleWrapper();
            // add the liability role
            liabilityRoleWrapper.liabilityRole = theLiabilityRole;
            // add the liability to the wrapper
            liabilityRoleWrapper.liability = theLiabilityRole.Liability__r;

            if(mapLiabilityRoles.get(liabilityId).size() > 1){
                liabilityRoleWrapper.strOwnerType = ApexAkina_Constants.JOINT;
            } else {
                // Other or de actual Id
                liabilityRoleWrapper.strOwnerType = (ownerTypeNames ? theLiabilityRole.Account__r.Name : theLiabilityRole.Account__c);
            }

            // add the asset selected display value
            if (theLiabilityRole.Liability__r.Asset__c != null) {
                liabilityRoleWrapper.assetSelectedDisplayValue = theLiabilityRole.Liability__r.Asset__r.Type__c +
                        (theLiabilityRole.Liability__r.Asset__r.Street__c != null ? ' (' +
                        (theLiabilityRole.Liability__r.Asset__r.Street__c != null ? theLiabilityRole.Liability__r.Asset__r.Street__c : '') +
                   ')' : '');
            }

            // add to the main list and totals
            if (String.isNotBlank(liabilityRoleWrapper.liability.Personal_Guarantees__c) && contingentLiabilityWrappers != null) {
                contingentLiabilityWrappers.add(liabilityRoleWrapper);

                if (((theFactFindSummary != null && !theFactFindSummary.No_Contingent_Liabilities__c) || theFactFindSummary == null) && liabilityRoleWrapper.liability.Current_Balance__c != null) {
                    totals[1] += liabilityRoleWrapper.liability.Current_Balance__c;
                }
            } else {
                liabilityRoleWrappers.add(liabilityRoleWrapper);

                if (((theFactFindSummary != null && !theFactFindSummary.Chosen_Not_to_Provide_Liability_Details__c && !theFactFindSummary.No_Liabilities__c) || theFactFindSummary == null) && liabilityRoleWrapper.liability.Current_Balance__c != null) {
                    totals[0] += liabilityRoleWrapper.liability.Current_Balance__c;
                }
            }
        }

        return totals;
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to get the income and expenses by reference from the FactFindingController and FactFindingSummary and return totals
    **/
    public static List<Decimal> getIncomeExpenses (Set<Id> clientIds, Map<String, List<IncomeExpenseWrapper>> incomeAndExpenses, Id mainClient, Fact_Find__c theFactFindSummary, List<IncomeExpenseWrapper> listIncomeExpenses) {
        List<Decimal> totals = new List<Decimal>{0,0,0};
        for(Income_and_Expense__c incomeDetail : FactFindingControllerSelector.getIncomeAndExpenses(clientIds)){
            IncomeExpenseWrapper incomeExpenseWrapper = new IncomeExpenseWrapper(incomeDetail);

            // add to the list for the summary
            if (listIncomeExpenses != null) {
                listIncomeExpenses.add(incomeExpenseWrapper);
            }

            // add to the map for the page
            if(incomeDetail.RecordTypeId == ApexAkina_Constants.INCOME_RECTYPE){
                incomeAndExpenses.get(incomeDetail.Primary_Owner__c == mainClient ? 'Client 1 - Income' : ApexAkina_Constants.CLIENT_2).add(incomeExpenseWrapper);
                if (((theFactFindSummary != null && !theFactFindSummary.Chosen_Not_to_Provide_Income_Details__c) || theFactFindSummary == null) && incomeDetail.Amount__c != null) {
                    totals[incomeDetail.Primary_Owner__c == mainClient ? 0 : 1] += incomeDetail.Amount__c;
                }
            } else if (incomeDetail.RecordTypeId == ApexAkina_Constants.EXPENSE_RECTYPE) {
                incomeAndExpenses.get('Client 1 - Expenses').add(incomeExpenseWrapper);
                if (((theFactFindSummary != null && !theFactFindSummary.Chosen_Not_to_Provide_Expense_Details__c && !theFactFindSummary.Do_not_Know_What_Are_My_Expenses__c) || theFactFindSummary == null) && incomeDetail.Amount__c != null) {
                    totals[2] += incomeDetail.Amount__c;
                }
            }
        }

        return totals;
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to get the family members and relationships by reference from the FactFindingController and FactFindingSummary
    **/
    public static List<FactFindingControllerService.FamilyMemberWrapper> getAllFamilyMembers (Set<Id> clientIds, Set<String> relationshipTypes) {
        List<FactFindingControllerService.FamilyMemberWrapper> familyMemberWrappers = new List<FactFindingControllerService.FamilyMemberWrapper>();
        Map<Id, Relationship__c> theFamilyMemberMap = new Map<Id, Relationship__c>();
        FactFindingControllerService.FamilyMemberWrapper familyMemberWrapper;

        //Dependants Relationship
        for (Relationship__c relationship : FactFindingControllerSelector.getRelationshipsByAccountIdsAndType(clientIds, relationshipTypes)) {
            if (!theFamilyMemberMap.containsKey(relationship.Related_Account__c)) {
                theFamilyMemberMap.put(relationship.Related_Account__c, relationship);
            }
        }

        //Dependants
        for (Account familyMember : FactFindingControllerSelector.getDependantAccounts(theFamilyMemberMap.keySet())) {
            String dob = familyMember.PersonBirthdate != null ? familyMember.PersonBirthdate.format() : '';

            familyMemberWrapper = new FactFindingControllerService.FamilyMemberWrapper();
            // add the account
            familyMemberWrapper.account = familyMember;
            familyMemberWrapper.relationship = theFamilyMemberMap.get(familyMember.Id);
            familyMemberWrapper.stringDate = FactFindingControllerService.formatDateToString(dob);

            // add to the list
            familyMemberWrappers.add(familyMemberWrapper);
        }

        return familyMemberWrappers;
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to get the family members and relationships by reference from the FactFindingController and FactFindingSummary
    **/
    public static List<FactFindingControllerService.FamilyMemberWrapper> getAllFamilyMembersWithChildrn (Set<Id> clientIds, Set<String> relationshipTypes, Id oppId) {
        List<FactFindingControllerService.FamilyMemberWrapper> familyMemberWrappers = new List<FactFindingControllerService.FamilyMemberWrapper>();
        Map<Id, Relationship__c> theFamilyMemberMap = new Map<Id, Relationship__c>();
        FactFindingControllerService.FamilyMemberWrapper familyMemberWrapper;

        //Dependants Relationship
        for (Relationship__c relationship : FactFindingControllerSelector.getRelationshipsByAccountIdsAndType(clientIds, relationshipTypes)) {

            if (!theFamilyMemberMap.containsKey(relationship.Related_Account__c)) {
                theFamilyMemberMap.put(relationship.Related_Account__c, relationship);
            }


        }

        //Dependants
        for (Account familyMember : FactFindingControllerSelector.getDependantAccounts(theFamilyMemberMap.keySet())) {
            String dob = familyMember.PersonBirthdate != null ? familyMember.PersonBirthdate.format() : '';

            familyMemberWrapper = new FactFindingControllerService.FamilyMemberWrapper();
            // add the account
            familyMemberWrapper.account = familyMember;
            familyMemberWrapper.relationship = theFamilyMemberMap.get(familyMember.Id);
            familyMemberWrapper.stringDate = FactFindingControllerService.formatDateToString(dob);

            //Check if account has application role for opp
            if((FactFindingControllerSelector.getApplicationRolesByOppId(oppId,familyMemberWrapper.account.Id)).size() > 0 ){

                System.debug('Hey hey ****' + FactFindingControllerSelector.getApplicationRolesByOppId(oppId,familyMemberWrapper.account.Id));

                familyMemberWrapper.includeInAnalysis = true;

            }

            // add to the list
            familyMemberWrappers.add(familyMemberWrapper);


        }

        return familyMemberWrappers;
    }

    /**
   *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
   *   @description Method to get a map of the Custom Metadata RelationshipTypes. Used in FactFindingController and FactFindingControllerSummary
   **/
    public static Map<String, List<String>> getMapRelationshipTypes () {
        Map<String, List<String>> mapRelationshipTypes = new Map<String, List<String>>();
        // put the relationships in the map
        for (Relationship_Type__mdt relationshipType : FactFindingControllerSelector.getRelationshipTypes()) {
            if (!mapRelationshipTypes.containsKey(relationshipType.Type__c)) {
                mapRelationshipTypes.put(relationshipType.Type__c, new List<String>());
            }
            mapRelationshipTypes.get(relationshipType.Type__c).add(relationshipType.MasterLabel);
        }

        return mapRelationshipTypes;
    }

    public class QuestionnaireAnswers {
        public Analysis_Survey__c analysisSurvey {get; set;}
        public Boolean option1 {get; set;}
        public Boolean option2 {get; set;}
        public Boolean option3 {get; set;}
        public Boolean option4 {get; set;}
        public Boolean option5 {get; set;}

        public QuestionnaireAnswers(Analysis_Survey__c analysisSurvey){
            this.analysisSurvey = analysisSurvey;
            this.option1 = false;
            this.option2 = false;
            this.option3 = false;
            this.option4 = false;
            this.option5 = false;
        }
    }

    public class ExistingRisk {
        public Boolean option1 {get; set;}
        public Boolean option2 {get; set;}
        public Boolean option3 {get; set;}
        public Boolean option4 {get; set;}
    }


    public class BenefitsRequired {
        public Boolean option1 {get; set;}
        public Boolean option2 {get; set;}
        public Boolean option3 {get; set;}
        public Boolean option4 {get; set;}
        public Boolean option5 {get; set;}
    }

    // Account Wrapper
    public class AccountWrapper {
        public Account account {get; set;}
        public String stringDate {get;set;}
        public Boolean differentAddresses {get;set;}

        public AccountWrapper(){
            this.account = new Account(RecordTypeId = ApexAkina_Constants.ACC_CLIENTRECTYPE);
            this.differentAddresses = false;
            this.stringDate = '';
        }
    }

    // Employment Wrapper
    public class EmploymentWrapper {
        public Employment_Detail__c employment {get; set;}
        public String startDate {get; set;}
        public String endDate {get; set;}
        public String tempId {get; set;}

        public EmploymentWrapper(Employment_Detail__c employment, String startDate, String endDate){
            this.employment = employment;
            this.startDate = startDate;
            this.endDate = endDate;
            this.tempId = FactFindingControllerService.generateRandomString(20);
        }
    }

    // Dependant Wrapper
    public class DependantWrapper {
        public Account account {get; set;}
        public Relationship__c relationship {get; set;}
        public String tempId {get; set;}
        public Boolean includeInAnalysis {get; set;}
        public String stringDate {get;set;}
        public String selectedDependantId {get; set;}

        public DependantWrapper(){
            this.account = new Account(RecordTypeId = ApexAkina_Constants.ACC_BENEFICIARYRECTYPE);
            this.relationship = new Relationship__c();
            this.tempId = FactFindingControllerService.generateRandomString(20);
            this.includeInAnalysis = false;
            this.stringDate = '';
            this.selectedDependantId = '';
        }
    }

    // Family Relationship Wrapper
    public class FamilyMemberWrapper {
        public Account account {get; set;}
        public Relationship__c relationship {get; set;}
        public String tempId {get; set;}
        public Boolean includeInAnalysis {get; set;}
        public String stringDate {get;set;}
        public String selectedAccountId {get; set;}

        public FamilyMemberWrapper(){
            this.account = new Account(RecordTypeId = ApexAkina_Constants.ACC_BENEFICIARYRECTYPE);
            this.relationship = new Relationship__c();
            this.tempId = FactFindingControllerService.generateRandomString(20);
            this.includeInAnalysis = false;
            this.stringDate = '';
            this.selectedAccountId = '';
        }
    }

    // Income/Expense Wrapper
    public class IncomeExpenseWrapper {
        public Income_and_Expense__c incomeExpense {get; set;}
        public String tempId {get; set;}

        public IncomeExpenseWrapper (Income_and_Expense__c incomeExpense){
            this.incomeExpense = incomeExpense;
            this.tempId = FactFindingControllerService.generateRandomString(20);
        }
    }

    // Other Entities Wrapper
    public class OtherEntitiesWrapper {
        public Account account {get; set;}
        public String tempId {get; set;}
        public String selectedLegalEntityId {get; set;}
        public List<FactFindingControllerService.OtherEntitiesRolesWrapper> roles {get; set;}

        public OtherEntitiesWrapper (){
            this.account = new Account(RecordTypeId = ApexAkina_Constants.ACC_LEGALENTITYRECTYPE);
            this.tempId = FactFindingControllerService.generateRandomString(20);
            this.selectedLegalEntityId = '';
            this.roles = new List<FactFindingControllerService.OtherEntitiesRolesWrapper>();
        }
    }

    public class OtherEntitiesRolesWrapper {
        public Relationship__c relationship {get; set;}
        public String tempId {get; set;}
        public String strOwnerType {get; set;}

        public OtherEntitiesRolesWrapper (){
            this.relationship = new Relationship__c();
            this.tempId = FactFindingControllerService.generateRandomString(20);
            this.strOwnerType = ApexAkina_Constants.JOINT;
        }
    }

    // Liability Role Wrapper Class // Pablo Martinez  AP2-139
    public class LiabilityRoleWrapper{
        public Liability_Role__c liabilityRole {get; set;}
        public Liability__c liability{get; set;}
        public String strOwnerType {get; set;}
        public String randomString {get; set;}
        public String tempId {get; set;}
        public String assetSelectedDisplayValue {get; set;}

        public LiabilityRoleWrapper(){
            this.liabilityRole = new Liability_Role__c();
            this.liability = new Liability__c();
            this.strOwnerType = ApexAkina_Constants.JOINT;
            this.randomString = 'Liab' + FactFindingControllerService.generateRandomString(20);
            this.tempId = FactFindingControllerService.generateRandomString(20);
            this.assetSelectedDisplayValue = '';
        }
    }

    //Asset Role Wrapper Class
    public class AssetRoleWrapper{
        public Asset_Role__c assetRole {get; set;}
        public Client_Asset__c asset {get; set;}
        public String strOwnerType {get; set;}
        public String randomString {get; set;}
        public String tempId {get; set;}

        public AssetRoleWrapper(){
            this.assetRole = new Asset_Role__c();
            this.asset = new Client_Asset__c();
            this.randomString = 'Asset' + FactFindingControllerService.generateRandomString(20);
            this.strOwnerType = ApexAkina_Constants.JOINT;
            this.tempId = FactFindingControllerService.generateRandomString(20);
        }
    }

    // Goals Wrapper
    public class GoalsListWrapper {
        public List<GoalWrapper> goals {get; set;}

        public GoalsListWrapper () {
            this.goals = new List<GoalWrapper>();
        }

        public Integer getListSize () {
            return this.goals.size();
        }
    }

    // remove the implementation of Comprarable and the compareTo Method when rebuilding the Investor Profile UI
    public class GoalWrapper implements Comparable{
        public Goal__c goal {get; set;}
        public String stringDate {get;set;}
        public String tempId {get; set;}

        public GoalWrapper(Id accountId, Id recordTypeId) {
            this.goal = new Goal__c(Account__c = accountId, RecordTypeId = recordTypeId);
            this.stringDate = '';
            this.tempId = FactFindingControllerService.generateRandomString(20);
        }

        public Integer compareTo(Object ObjToCompare) {
            return this.goal.Name.compareTo(((GoalWrapper)ObjToCompare).goal.Name);
        }
    }

    // Referral Wrapper
    public class ReferralWrapper {
        public Referral_Type__mdt referralType {get; set;}
        public Referral__c referral {get; set;}
        public List<SelectOption> providerSelectOptions {get; set;}
        public Boolean externalChecked {get; set;}
        public String externalProviderSelected {get; set;}
        public Boolean userInternalIdChanged {get; set;}
        public Id internalUserIdSelected {get; set;}
        public String notes {get; set;}
        public String tempId {get; set;}

        public ReferralWrapper() {
            this.referralType = new Referral_Type__mdt();
            this.referral = new Referral__c();
            this.providerSelectOptions = new List<SelectOption>();
            this.externalChecked = false;
            this.externalProviderSelected = null;
            this.internalUserIdSelected = null;
            this.userInternalIdChanged = false;
            this.notes = null;
            this.tempId = FactFindingControllerService.generateRandomString(20);
        }
    }

    // Non Apex serviced cover Wrapper
    public class NonApexCoverWrapper {
        public Non_Apex_Cover__c nonApexCover { get; set; }
        public String tempId { get; set; }

        public NonApexCoverWrapper (){
            this.nonApexCover = new Non_Apex_Cover__c();
            this.tempId = FactFindingControllerService.generateRandomString(20);
        }
    }
}