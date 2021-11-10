/**
* @author David Catindoy (david@cloudinit.nz)
* @date Oct 24, 2017
* @description Controller for FactFind page
*
* CHANGE LOG
* Version           Author                              Date                Description
* 2.0               Siddharth (Deloitte)                12 April 2019       Segregate the saveClientDetails() logic based on the
*                                                                           new tabs defined for 'Know Your Client' tabs Story (JIRA AP2-65)
*
* 3.0               Siddharth (Deloitte)                09 May 2019     Refactoring the logic to replace the Asset retrieval from
*                                                                       (Asset Role) Asset_Role__c instead of (Asset) Client_Asset__c (JIRA AP2-16)
*
* 3.1               Siddharth (Deloitte)                19 Jun 2019     Bug Fix (CSD-275)
*
* 4.0               Pablo Martinez (Deloitte)           17 Jul 2019     Refactoring the logic to replace Liability with Liability Role
*                                                                       Add Deletion of several elements
*                                                                       Bug fixes and small improvements
* 5.0              Pablo Martinez (Be Intelligent)      10 May 2021     Add Children as clientOptions for Existing Cover
*                                                                       Rename the method getClientOptions to getWhoListNonApexServicedCover
*                                                                       Add the children to the Apex Advice Serviced Cover list
* 6.0             Ivanna Panchenko (Be Intelligent)     17 Sep 2021     Add fields on Fact find to display on the Investor Profile 
*                                                                      
**/
public without sharing class FactFindingController {

    // Boolean variables
    public Boolean single {get; set;}
    public Boolean joint {get; set;}
    public Boolean sandbox {get; set;}
    public Boolean hasError {get; set;}
    public Boolean differentLastName {get; set;}
    public Boolean resetScopeOfEngagement {get; set;}
    public Boolean resetLetterOfEngagement {get; set;}
    public boolean openNextAppointment {get; set;}

    // Record types
    public Id legalEntityRecordType {get; set;}

    // String variables
    public String recordId {get; set;}
    public String initialApplicationType {get; set;}
    public String applicationType {get; set;}
    public String selectedTab {get; set;}
    public String selectedInternalTab {get; set;}               //Sid 2.0    JIRA AP2-65
    public String keys {get; set;}
    public List<String> stringDates {get; set;}
    public String client1Type {get; set;}
    public String client2Type {get; set;}
    public String goalTypeToAdd {get; set;}
    public String oppNameRemoved;

    // SObject variables
    public Opportunity opp {get; set;}
    public FactFindingControllerService.AccountWrapper client1 {get; set;}
    public FactFindingControllerService.AccountWrapper client2 {get; set;}
    public Fact_Find__c factFind {get; set;}
    public Note nextStepsNotes {get; set;}
    public Event nextAppointment {get; set;}
    public Account newInstitution {get;set;} // Pablo Martinez AP2-436

    // List variables
    public Set<Id> clientIds {get; set;}
    public Set<Id> familyMemberIds {get; set;} // Pablo Martinez AP2-51
    public Set<Id> legalEntityIdsForAssetsLiabilities {get;set;} // Pablo Martinez  AP2-43
    public List<Decimal> totals {get; set;}
    public List<Question_Scoring__mdt> scoring {get; set;}
    public List<Declaration__mdt> declaration {get; set;}
    public List<String> eventTime {get; set;}
    public List<FactFindingControllerService.AssetRoleWrapper> assetRoleWrappers {get; set;}  //Sid 3.0   JIRA AP2-122
    public List<FactFindingControllerService.LiabilityRoleWrapper> liabilityRoleWrappers {get; set;}  // Pablo Martinez  AP2-155
    public List<FactFindingControllerService.LiabilityRoleWrapper> contingentLiabilityWrappers {get; set;}  // Pablo Martinez  AP2-155
    public List<FactFindingControllerService.OtherEntitiesWrapper> otherEntitiesWrappers {get; set;}  // Pablo Martinez  AP2-51
    public List<FactFindingControllerService.NonApexCoverWrapper> nonApexCoverWrappers { get; set; }
    public List<Account> listAllLegalEntities {get; set;} // Pablo Martinez  AP2-51
    public List<Account> listDependants {get; set;}  // Pablo Martinez  AP2-43
    public List<FactFindingControllerService.FamilyMemberWrapper> listAllFamily {get; set;}  // Pablo Martinez  AP2-356
    public List<FactFindingControllerService.FamilyMemberWrapper> familyMemberWrappers {get;set;}
    public List<Goal__c> listPersonalGoals {get;set;}
    public List<String> listPersonalGoalTypes {get; set;} // Pablo Martinez AP2-58
    public List<String> listInvestmentGoalTypes {get; set;} // Pablo Martinez AP2-58
    public List<Task> listExternalReferralTasks {get; set;} // Pablo Martinez AP2-61

    // variables for summary page
    public List<Account> listAccounts {get; set;}
    public List<FactFindingControllerService.IncomeExpenseWrapper> listIncomeExpense {get;set;}

    // Map variables
    public Map<String, Application_Role__c> applicationRoles {get; set;}
    public Map<String, List<FactFindingControllerService.EmploymentWrapper>> employment {get; set;}
    public Map<String, List<FactFindingControllerService.IncomeExpenseWrapper>> incomeAndExpenses {get; set;}
    public Map<String, Estate_Planning__c> estatePlanning {get; set;}
    public Map<String, AccountContactRelation> contactRoles {get; set;}
    public Map<String, AccountContactRelation> forDeletion {get; set;}
    public Map<String, Contact> professionals {get; set;}
    public Map<String, FactFindingControllerService.ExistingRisk> existingRisks {get; set;}
    public Map<String, Map<String, Analysis__c>> analysis {get; set;}
    public Map<String, FactFindingControllerService.BenefitsRequired> clientBenefits {get; set;}
    public Map<String, Boolean> includeInAnalysis {get; set;}
    public Map<String, FactFindingControllerService.QuestionnaireAnswers> investmentRiskQ {get; set;}
    public Map<String, Questionnaire__mdt> questionnaire {get; set;}
    public Map<Id, List<Asset_Role__c>> mapAssetAssetRole = new Map<Id, List<Asset_Role__c>>();            //Sid 3.0   JIRA AP2-122
    public Map<Id, List<Liability_Role__c>> mapLiabilityRoles = new Map<Id, List<Liability_Role__c>>();            // Pablo Martinez AP2-155
    public Map<Id, List<Relationship__c>> mapOtherEntityRoles = new Map<Id, List<Relationship__c>>(); // Pablo Martinez AP2-51
    public Map<String, List<String>> mapRelationshipTypes {get; set;}  // Pablo Martinez  AP2-51
    public Map<String, Relationship__c> mapUniqueRelationships {get; set;} // Pablo Martinez  AP2-51
    public Map<String, List<SelectOption>> mapPersonalGoalTypes {get; set;} // Pablo Martinez AP2-58
    public Map<String, FactFindingControllerService.GoalsListWrapper> mapPersonalGoals {get;set;} // Pablo Martinez AP2-58
    public Map<String, List<SelectOption>> mapInvestmentGoalTypes {get; set;} // Pablo Martinez AP2-58
    public Map<String, FactFindingControllerService.GoalsListWrapper> mapInvestmentGoals {get;set;} // Pablo Martinez AP2-58
    public Map<Id, Referral_Provider__mdt> mapReferralProviders {get; set;} // Pablo Martinez AP2-61
    public Map<String, String> mapAssetTypeLiabilityType {get; set;} // Pablo Martinez AP2-436

    // variables for Deletion
    public Id recordIdToDelete {get;set;}
    public String tempIdToDelete {get;set;}
    public String typeToDelete {get;set;}

    // variables for popups
    public String familyMemberAddEditType {get; set;}
    public FactFindingControllerService.FamilyMemberWrapper familyMemberToAddEdit {get; set;}
    public String otherEntityAddEditType {get; set;}
    public FactFindingControllerService.OtherEntitiesWrapper otherEntityToAddEdit {get; set;}
    public FactFindingControllerService.AssetRoleWrapper assetToAddEdit {get; set;}

    // custom settings variables
    public Map<String, List<FactFindingControllerService.ReferralWrapper>> referralTypes {get; set;}
    public Apex_Admin_Settings__c apexAdminSettings { get; set; } // Pablo Martinez AP2-226
    
    // variable for Apex Advice Serviced Cover - Alvin Aquino -AP2-104 - Changed by Pablo Martinez
    public List<Policy_Benefit__c> apexServicedCoverList { get; set; }
    
    // Variable flag to control the tax country code on the investor profile 
    public boolean isRequiredCountryTaxes{get;set;}
    public boolean hasUpdateFactFindTaxes{get;set;}
	
    public FactFindingController(ApexPages.StandardController stdController){
        recordId = stdController.getId();
        initialize();
    }

    public String baseUrl {
        get {
            return Url.getSalesforceBaseUrl().toExternalForm();
        }
        set;
    }

    public void initialize(){
        try{
            // Initialize variables
            clientIds = new Set<Id>();
            legalEntityRecordType = ApexAkina_Constants.ACC_LEGALENTITYRECTYPE;
            client1Type = ApexAkina_Constants.CLIENT_1;
            client2Type = ApexAkina_Constants.CLIENT_2;
            stringDates = new List<String>{'','','','','','','','','','','',''};
            keys = '';
            goalTypeToAdd = '';
            apexAdminSettings = Apex_Admin_Settings__c.getOrgDefaults();
            questionnaire = new Map<String, Questionnaire__mdt>();
            mapRelationshipTypes = FactFindingControllerService.getMapRelationshipTypes();
            scoring = FactFindingControllerSelector.getScorings();
            declaration = FactFindingControllerSelector.getDeclarations();
            investmentRiskQ = new Map<String, FactFindingControllerService.QuestionnaireAnswers>();
            listAccounts = new List<Account>();
            newInstitution = new Account();
            //to control if it was update front the frontend to avoid call update without being updated
            hasUpdateFactFindTaxes = false;

            // Put the questionnaire in the map
            for(Questionnaire__mdt question : FactFindingControllerSelector.getQuestionnaires()){
                questionnaire.put(question.MasterLabel, question);
                investmentRiskQ.put(question.MasterLabel, new FactFindingControllerService.QuestionnaireAnswers(new Analysis_Survey__c()));
            }

            // get a map of asset types with liability types
            mapAssetTypeLiabilityType = new Map<String, String>();
            // put the asset type in the map with liability type
            for (Asset_Type__mdt assetType : FactFindingControllerSelector.getAssetTypesWithLiabilityType()) {
                mapAssetTypeLiabilityType.put(assetType.MasterLabel, assetType.Liability_Type__c != null ? assetType.Liability_Type__r.MasterLabel : 'None');
            }

            nextStepsNotes = new Note();
            client1 = new FactFindingControllerService.AccountWrapper();
            client2 = new FactFindingControllerService.AccountWrapper();
            // Initialize boolean variables
            single = true;
            joint = false;
            hasError = false;
            sandbox = UserInfo.getUiThemeDisplayed() == 'Theme4d' || UserInfo.getUiThemeDisplayed() == 'Theme4u';

            existingRisks = new Map<String, FactFindingControllerService.ExistingRisk>{client1Type => new FactFindingControllerService.ExistingRisk(), client2Type => new FactFindingControllerService.ExistingRisk()};
            initialApplicationType = 'Single';
            applicationType = 'Single';
            selectedTab = '';
            if(String.isEmpty(selectedInternalTab)){
                selectedInternalTab = '';
            }

            System.debug('Record Id: ' + recordId);

            // Check if there's an actual record id passed
            if(String.isNotBlank(recordId)){
                opp = FactFindingControllerSelector.getOpportunityById(recordId);
                this.oppNameRemoved = opp.Name.replace('-', '+');

                ApexPages.StandardController sc = new ApexPages.StandardController(opp);

                // Initialize and get existing application roles
                applicationRoles = new Map<String, Application_Role__c>{client1Type => new Application_Role__c(), client2Type => new Application_Role__c(Opportunity__c = opp.Id, Role__c = 'Joint Owner')};
                for(Application_Role__c applicationRole : FactFindingControllerSelector.getApplicationRolesByOpportunityId(opp.Id)){
                    if(applicationRole.Role__c == 'Primary Owner'){
                        applicationRoles.put(client1Type, applicationRole);
                    } else if(applicationRole.Role__c == 'Joint Owner'){
                        applicationRoles.put(client2Type, applicationRole);
                    } else {
                        applicationRoles.put(applicationRole.Account__c, applicationRole);
                    }
                }

                System.debug('applicationRoles: ' + applicationRoles);

                // Get client 1 details
                if(String.isNotBlank(applicationRoles.get(client1Type).Account__c)){
                    client1.account = FactFindingControllerSelector.getAccountById(applicationRoles.get(client1Type).Account__c);
                    clientIds.add(client1.account.Id);
                    listAccounts.add(client1.account);

                    if (client1.account.PersonBirthdate != null) {
                        client1.stringDate = FactFindingControllerService.formatDateToString(client1.account.PersonBirthdate.format());
                    }
                }

                // Get client 2 details
                if(String.isNotBlank(applicationRoles.get(client2Type).Account__c)){
                    client2.account = FactFindingControllerSelector.getAccountById(applicationRoles.get(client2Type).Account__c);
                    clientIds.add(client2.account.Id);
                    listAccounts.add(client2.account);

                    if (client2.account.PersonBirthdate != null) {
                        client2.stringDate = FactFindingControllerService.formatDateToString(client2.account.PersonBirthdate.format());
                    }

                    single = false;
                    joint = true;
                    initialApplicationType = ApexAkina_Constants.JOINT;
                    applicationType = ApexAkina_Constants.JOINT;
                }

                // set address different flag
                setAddressDifferent();

                initializeNextAppointment();

                // Retrieve fact find details
                pullFactFindDetails();

            } else{
                ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        ApexAkina_Constants.ERROR_NOOPPTY
                ));
            }
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage()) // + ' ' + // Only uncomment for debugging purposes
                    // String.escapeSingleQuotes(e.getStackTraceString())
            ));
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));
        }
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to initialize next appointment
    **/
    public void initializeNextAppointment(){

        nextAppointment = new Event(Type = 'Follow up Appointment', ShowAs = 'Busy', Event_Status__c = 'Accept', Appointment_Preference__c = 'Face to Face', OwnerId = UserInfo.getUserId(), WhatId = opp.Id, WhoId = client1.account.PersonContactId);

        stringDates[10] = FactFindingControllerService.formatDateToString(System.today().format());
        stringDates[11] = FactFindingControllerService.formatDateToString(System.today().format());

        Integer hourNow = Integer.valueOf(String.valueOf(System.now().time()).split(':').get(0));
        eventTime = new List<String>{(hourNow+2 > 23 ? (hourNow+2)-24 : hourNow+2)+':00', (hourNow+3 > 23 ? (hourNow+3)-24 : hourNow+3)+':00'};

    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to set a flag if the address are different
    **/
    public void setAddressDifferent () {
        // check client 1
        if (client1.account.PersonMailingStreet != client1.account.PersonOtherStreet
                || client1.account.PersonMailingCity != client1.account.PersonOtherCity
                || client1.account.PersonMailingState != client1.account.PersonOtherState
                || client1.account.PersonMailingPostalCode != client1.account.PersonOtherPostalCode
                || client1.account.PersonMailingCountry != client1.account.PersonOtherCountry) {
            client1.differentAddresses = true;
        } else {
            client1.differentAddresses = false;
        }

        // check client2
        // check different postal addresses
        if (joint && (client2.account.PersonMailingStreet != client2.account.PersonOtherStreet
                || client2.account.PersonMailingCity != client2.account.PersonOtherCity
                || client2.account.PersonMailingState != client2.account.PersonOtherState
                || client2.account.PersonMailingPostalCode != client2.account.PersonOtherPostalCode
                || client2.account.PersonMailingCountry != client2.account.PersonOtherCountry)) {
            client2.differentAddresses = true;
        }else {
            client2.differentAddresses = false;
        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to get Family Members and relationships
    **/
    public void getFamilyMembers () {
        listAllFamily = new List<FactFindingControllerService.FamilyMemberWrapper>();
        listDependants = new List<Account>();
        familyMemberIds = new Set<Id>();
        //familyMemberWrappers = FactFindingControllerService.getAllFamilyMembers(new Set<Id>{opp.AccountId}, new Set<String>(mapRelationshipTypes.get(ApexAkina_Constants.FAMILY_MEMBER_RELATIONSHIP_TYPE)));
        familyMemberWrappers = FactFindingControllerService.getAllFamilyMembersWithChildrn(new Set<Id>{opp.AccountId}, new Set<String>(mapRelationshipTypes.get(ApexAkina_Constants.FAMILY_MEMBER_RELATIONSHIP_TYPE)), opp.Id);

        for (FactFindingControllerService.FamilyMemberWrapper familyMemberWrapper : familyMemberWrappers) {
            familyMemberIds.add(familyMemberWrapper.relationship.Id);
            if (familyMemberWrapper.relationship.Dependant__c == 'Yes') {
                listDependants.add(familyMemberWrapper.account);
            }
            listAllFamily.add(familyMemberWrapper);
        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to get Other Entities
    **/
    public void getOtherEntities () {
        // other entities
        otherEntitiesWrappers = new List<FactFindingControllerService.OtherEntitiesWrapper>();
        Set<Id> accountIds = new Set<Id>(clientIds);

        // add the ids for dependants
        for (Account acc : listDependants) {
            accountIds.add(acc.Id);
        }
        mapUniqueRelationships = new Map<String, Relationship__c>();
        mapOtherEntityRoles = new Map<Id, List<Relationship__c>>();
        legalEntityIdsForAssetsLiabilities = new Set<Id>();

        //Iterating over Relationships Retrieved
        for(Relationship__c relationship : FactFindingControllerSelector.getRelationshipsByAccountIdsAndType(accountIds, new Set<String>(mapRelationshipTypes.get(ApexAkina_Constants.OTHERENTITIES_RELATIONSHIP_TYPE)))) {
            //Create a Map of other entities
            if (!mapOtherEntityRoles.containsKey(relationship.Related_Account__c)) {
                mapOtherEntityRoles.put(relationship.Related_Account__c, new List<Relationship__c>());
            }

            mapOtherEntityRoles.get(relationship.Related_Account__c).add(relationship);
            mapUniqueRelationships.put(relationship.External_Id__c, relationship);

            // if it belongs to Client 1 or Client 2 then add for assets and liabilities
            if (clientIds.contains(relationship.Account__c)) {
                legalEntityIdsForAssetsLiabilities.add(relationship.Related_Account__c);
            }
        }

        // get the accounts
        listAllLegalEntities = FactFindingControllerSelector.getAccountByIds(mapOtherEntityRoles.keySet());
        FactFindingControllerService.OtherEntitiesWrapper otherEntitiesWrapper;
        FactFindingControllerService.OtherEntitiesRolesWrapper otherEntitiesRolesWrapper;

        //Iterating over the mapOtherEntityRoles
        for(Account account : listAllLegalEntities) {
            otherEntitiesWrapper = new FactFindingControllerService.OtherEntitiesWrapper();
            // add the account
            otherEntitiesWrapper.account = account;

            for (Relationship__c relationship : mapOtherEntityRoles.get(account.Id)) {
                otherEntitiesRolesWrapper = new FactFindingControllerService.OtherEntitiesRolesWrapper();
                otherEntitiesRolesWrapper.relationship = relationship;
                otherEntitiesRolesWrapper.strOwnerType = relationship.Account__c;

                // add the roles to the wrapper
                otherEntitiesWrapper.roles.add(otherEntitiesRolesWrapper);
            }

            // add to the main list
            otherEntitiesWrappers.add(otherEntitiesWrapper);
        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to get the Goals
    **/
    public void getGoals () {
        listPersonalGoals = new List<Goal__c>();
        listPersonalGoalTypes = new List<String>();
        mapPersonalGoalTypes = new Map<String, List<SelectOption>>();
        mapPersonalGoals = new Map<String, FactFindingControllerService.GoalsListWrapper>();
        listInvestmentGoalTypes = new List<String>();
        mapInvestmentGoalTypes = new Map<String, List<SelectOption>>();
        mapInvestmentGoals = new Map<String, FactFindingControllerService.GoalsListWrapper>();

        // remove this variable after rebuilding Investor Profile UI
        Set<String> savedInvestorProfileGoals = new Set<String>();

        List<Goal_Type__mdt> listAllGoalTypes = FactFindingControllerSelector.getGoalTypes();
        List<Goal__c> listAllGoals = FactFindingControllerSelector.getGoalsByAccountIds(new Set<Id>{client1.account.Id});

        for (Goal_Type__mdt goalType : listAllGoalTypes) {
            // divide between personal and investment goals
            if (goalType.Type__c == 'Personal') {
                // add to the picklist for Personal Goals
                if (!mapPersonalGoalTypes.containsKey(goalType.Section__c)) {
                    mapPersonalGoalTypes.put(goalType.Section__c, new List<SelectOption>());
                    // add to the unordered list
                    listPersonalGoalTypes.add(goalType.Section__c);
                }

                // add to the map of types
                mapPersonalGoalTypes.get(goalType.Section__c).add(new SelectOption(goalType.MasterLabel, goalType.MasterLabel));

                // create the empty map record
                if (!mapPersonalGoals.containsKey(goalType.Section__c)) {
                    mapPersonalGoals.put(goalType.Section__c, new FactFindingControllerService.GoalsListWrapper());
                }
            } else if (goalType.Type__c == 'Investment') {
                // add to the picklist only for Investment Goals
                if (!mapInvestmentGoalTypes.containsKey(goalType.Section__c)) {
                    mapInvestmentGoalTypes.put(goalType.Section__c, new List<SelectOption>());
                    // add to the unordered list
                    listInvestmentGoalTypes.add(goalType.Section__c);
                }

                // add to the map of types
                mapInvestmentGoalTypes.get(goalType.Section__c).add(new SelectOption(goalType.MasterLabel, goalType.MasterLabel));

                // create the empty map record
                if (!mapInvestmentGoals.containsKey(goalType.Section__c)) {
                    mapInvestmentGoals.put(goalType.Section__c, new FactFindingControllerService.GoalsListWrapper());
                }
            }
        }

        // traverse the results of the query to add to the map
        for(Goal__c goal : listAllGoals) {
            String section = String.isNotBlank(goal.Section__c) ? goal.Section__c : 'Investment Specific Goals';

            // add to the map of types
            FactFindingControllerService.GoalWrapper goalWrapper = new FactFindingControllerService.GoalWrapper(client1.account.Id, goal.RecordTypeId);
            goalWrapper.goal = goal;

            // Personal
            if(goal.RecordTypeId == ApexAkina_Constants.FINANCIAL_RECTYPE) {
                listPersonalGoals.add(goal);
                mapPersonalGoals.get(section).goals.add(goalWrapper);
            }
            else {
                if (goal.RecordTypeId == ApexAkina_Constants.INVGOAL_RECTYPE) {
                    if (goal.Date_Required__c != null) {
                        goalWrapper.stringDate = FactFindingControllerService.formatDateToString(goal.Date_Required__c.format());
                    }
                    mapInvestmentGoals.get(section).goals.add(goalWrapper);

                    // remove next line after rebuilding Investor Profile UI
                    savedInvestorProfileGoals.add(goal.Name);
                } else {
                    hasError = true;

                    ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.ERROR,
                            String.escapeSingleQuotes('The recordType ' + goal.RecordTypeId + ' has not been implemented yet.')
                    ));
                }
            }
        }

        // remove this piece of code after rebuilding Investor Profile UI
        Set<String> investorProfileGoals = new Set<String>{'Car/Boat etc', 'Deposit for New Home', 'Education', 'Retirement'};
        for (String invGoal : investorProfileGoals) {
            if (!savedInvestorProfileGoals.contains(invGoal)) {
                FactFindingControllerService.GoalWrapper goalWrapper = new FactFindingControllerService.GoalWrapper(client1.account.Id, ApexAkina_Constants.INVGOAL_RECTYPE);
                goalWrapper.goal.Name = invGoal;
                mapInvestmentGoals.get('Investment Specific Goals').goals.add(goalWrapper);
            }
        }
        mapInvestmentGoals.get('Investment Specific Goals').goals.sort();
        // remove up to here
    }

    /**
   *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
   *   @description Method to get the Referrals
   **/
    public void getReferrals () {
        listExternalReferralTasks = FactFindingControllerSelector.getTasksForExternalReferrals(opp.Id);
        List<Referral__c> internalReferrals = FactFindingControllerSelector.getInternalReferralsByOpportunityId(opp.Id);
        Map<String, Referral__c> mapInternalReferrals = new Map<String, Referral__c>();
        List<Referral_Type__mdt> mapReferralTypes = FactFindingControllerSelector.getReferralTypes();
        referralTypes = new Map<String, List<FactFindingControllerService.ReferralWrapper>>();
        mapReferralProviders = new Map<Id, Referral_Provider__mdt>();

        //  build a map of referrals by type
        for (Referral__c referral : internalReferrals) {
            // only put the first one per type, that is the latest created one
            if (!mapInternalReferrals.containsKey(referral.Type__c)) {
                mapInternalReferrals.put(referral.Type__c, referral);
            }
        }

        // Traverse the types from the custom metadata
        for (Referral_Type__mdt refType : mapReferralTypes) {
            if (!referralTypes.containsKey(refType.Type__c)) {
                referralTypes.put(refType.Type__c, new List<FactFindingControllerService.ReferralWrapper>());
            }

            FactFindingControllerService.ReferralWrapper referralWrapper = new FactFindingControllerService.ReferralWrapper();
            referralWrapper.referralType = refType;

            // it it's in the internal referrals record
            if (mapInternalReferrals.containsKey(refType.MasterLabel)) {
                referralWrapper.referral = mapInternalReferrals.get(refType.MasterLabel);
                referralWrapper.internalUserIdSelected = mapInternalReferrals.get(refType.MasterLabel).Internal_Referral__c;
                referralWrapper.notes = mapInternalReferrals.get(refType.MasterLabel).Notes__c;
            }

            // traverse the providers and build the map and the select options
            for (Referral_Provider__mdt provider : refType.Referral_Providers__r) {
                // add to the map
                mapReferralProviders.put(provider.Id, provider);

                // add to the select option
                referralWrapper.providerSelectOptions.add(new SelectOption(provider.Id, provider.MasterLabel));
            }

            referralTypes.get(refType.Type__c).add(referralWrapper);
        }
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to get fact find details and related records
    **/
    public void pullFactFindDetails(){
        // Get fact find records that matches with the criteria
        List<Fact_Find__c> factFinds = FactFindingControllerSelector.getFactFinds(applicationRoles.get(client1Type).Account__c, applicationRoles.get(client1Type).Fact_Find__c);

        // Initialize fact find variable
        factFind = new Fact_Find__c(Primary_Owner__c = client1.account.Id);
        System.debug('factFinds: ' + factFinds);
        if(!factFinds.isEmpty()){

            factFind = factFinds[0];
            
            //Initialize attribute for old data the field will be null so set it as No
            factFind.Tax_Resident_Country_Other_Than_NZ__c = String.isBlank(factFind?.Tax_Resident_Country_Other_Than_NZ__c)
                											 ?'No':factFind?.Tax_Resident_Country_Other_Than_NZ__c ;
          
            //to display or not taxes country
            isRequiredCountryTaxes =  'Yes'.containsIgnoreCase(factFind?.Tax_Resident_Country_Other_Than_NZ__c) ; 
            
            if(String.isNotBlank(factFind.Existing_Risk_Insurance_Primary_Owner__c)){
                if(factFind.Existing_Risk_Insurance_Primary_Owner__c.equals(ApexAkina_Constants.EXISTINGRISK_OPTION1)){
                    existingRisks.get(client1Type).option1 = true;
                }else if(factFind.Existing_Risk_Insurance_Primary_Owner__c.equals(ApexAkina_Constants.EXISTINGRISK_OPTION3)){
                    existingRisks.get(client1Type).option3 = true;

                }else if(factFind.Existing_Risk_Insurance_Primary_Owner__c.equals(ApexAkina_Constants.EXISTINGRISK_OPTION4)){
                    existingRisks.get(client1Type).option4 = true;
                }else if(factFind.Existing_Risk_Insurance_Primary_Owner__c.equals(ApexAkina_Constants.EXISTINGRISK_OPTION2)) {
                    existingRisks.get(client1Type).option2 = true;
                }else{
                    existingRisks.get(client1Type).option2 = null;
                    existingRisks.get(client1Type).option1 = null;
                    existingRisks.get(client1Type).option3 = null;
                    existingRisks.get(client1Type).option4 = null;

                }
            }

            if(String.isNotBlank(factFind.Existing_Risk_Insurance_Joint_Owner__c)){
                if(factFind.Existing_Risk_Insurance_Joint_Owner__c.equals(ApexAkina_Constants.EXISTINGRISK_OPTION1)){
                    existingRisks.get(client2Type).option1 = true;
                }else if(factFind.Existing_Risk_Insurance_Joint_Owner__c.equals(ApexAkina_Constants.EXISTINGRISK_OPTION3)){
                    existingRisks.get(client2Type).option3 = true;
                }else if(factFind.Existing_Risk_Insurance_Joint_Owner__c.equals(ApexAkina_Constants.EXISTINGRISK_OPTION4)){
                    existingRisks.get(client2Type).option4 = true;
                }else if(factFind.Existing_Risk_Insurance_Joint_Owner__c.equals(ApexAkina_Constants.EXISTINGRISK_OPTION2)) {
                    existingRisks.get(client2Type).option2 = true;
                }else {
                    existingRisks.get(client2Type).option2 = null;
                    existingRisks.get(client2Type).option1 = null;
                    existingRisks.get(client2Type).option3 = null;
                    existingRisks.get(client2Type).option4 = null;

                }
            }
        }


        System.debug('Employment: ' + employment);
        //Employment Details
        employment = new Map<String, List<FactFindingControllerService.EmploymentWrapper>>{client1Type => new List<FactFindingControllerService.EmploymentWrapper>(), client2Type => new List<FactFindingControllerService.EmploymentWrapper>()};
        for(Employment_Detail__c employmentDetail : FactFindingControllerSelector.getEmploymentDetails(clientIds)){
            String startDate = employmentDetail.Start_Date__c != null ? employmentDetail.Start_Date__c.format() : '';
            startDate = FactFindingControllerService.formatDateToString(startDate);
            String endDate = employmentDetail.End_Date__c != null ? employmentDetail.End_Date__c.format() : '';
            endDate = FactFindingControllerService.formatDateToString(endDate);
            if(employmentDetail.Account__c == client1.account.Id){
                if(employment.containsKey(client1Type)){
                    employment.get(client1Type).add(new FactFindingControllerService.EmploymentWrapper(employmentDetail, startDate, endDate));
                }
            } else if(employmentDetail.Account__c == client2.account.Id){
                if(employment.containsKey(client2Type)){
                    employment.get(client2Type).add(new FactFindingControllerService.EmploymentWrapper(employmentDetail, startDate, endDate));
                }
            }
        }
        
        System.debug('Employment: ' + employment);

        // get the family members
        getFamilyMembers();
        // get other entities
        getOtherEntities();

        //Income and Expenses
        listIncomeExpense = new List<FactFindingControllerService.IncomeExpenseWrapper>();
        incomeAndExpenses = new Map<String, List<FactFindingControllerService.IncomeExpenseWrapper>>{'Client 1 - Income' => new List<FactFindingControllerService.IncomeExpenseWrapper>(), 'Client 1 - Expenses' => new List<FactFindingControllerService.IncomeExpenseWrapper>(), client2Type => new List<FactFindingControllerService.IncomeExpenseWrapper>()};
        totals = FactFindingControllerService.getIncomeExpenses(clientIds, incomeAndExpenses, client1.account.Id, null, listIncomeExpense);

        // add other totals that we need
        totals.addAll(new List<Decimal>{0,0,0,0});

        //Assets
        Set<Id> clientIdsForAssetAndLiabilities = new Set<Id>(clientIds);
        clientIdsForAssetAndLiabilities.addAll(mapOtherEntityRoles.keySet());
        mapAssetAssetRole = new Map<Id, List<Asset_Role__c>>();
        assetRoleWrappers = new List<FactFindingControllerService.AssetRoleWrapper>();
        totals[4] = FactFindingControllerService.getAssets(clientIdsForAssetAndLiabilities, mapAssetAssetRole, assetRoleWrappers, false, null);

        //Liabilities
        mapLiabilityRoles = new Map<Id, List<Liability_Role__c>>();
        liabilityRoleWrappers = new List<FactFindingControllerService.LiabilityRoleWrapper>();
        contingentLiabilityWrappers = new List<FactFindingControllerService.LiabilityRoleWrapper>();
        List<Decimal> liabTotals = FactFindingControllerService.getLiabilities(clientIdsForAssetAndLiabilities, mapLiabilityRoles, liabilityRoleWrappers, contingentLiabilityWrappers, false, null);
        totals[5] = liabTotals[0];
        totals[6] = liabTotals[1];

        //Estate Planning
        estatePlanning = new Map<String, Estate_Planning__c>{client1Type => new Estate_Planning__c(), client2Type => new Estate_Planning__c()};
        for(Estate_Planning__c estate : FactFindingControllerSelector.getEstatePlannings(clientIds)){
            if(estate.Primary_Owner__c == client1.account.Id){
                estatePlanning.put(client1Type, estate);
            } else if(estate.Primary_Owner__c == client2.account.Id){
                estatePlanning.put(client2Type, estate);
            }
        }

        //Contact Roles
        contactRoles = new Map<String, AccountContactRelation>{'Accountant/Tax Agent' => new AccountContactRelation(Roles = 'Accountant/Tax Agent'), 'Other Adviser' => new AccountContactRelation(Roles = 'Other Adviser'), 'Solicitor' => new AccountContactRelation(Roles = 'Solicitor')};
        professionals = new Map<String, Contact>{'Accountant/Tax Agent' => new Contact(), 'Other Adviser' => new Contact(), 'Solicitor' => new Contact()};
        for(AccountContactRelation contactRole : contactRoles.values()){
            contactRole.IsActive = true;
            contactRole.AccountId = client1.account.Id;
        }

        forDeletion = new Map<String, AccountContactRelation>();
        for(AccountContactRelation contactRole : FactFindingControllerSelector.getAccountContactRelationsByAccountId(client1.account.Id)){
            if(String.isNotBlank(contactRole.Roles)){
                AccountContactRelation cloneContactRole = null;
                if(contactRole.Roles.containsIgnoreCase('Accountant/Tax Agent')){
                    cloneContactRole = contactRole.clone(false, true, false, false);
                    cloneContactRole.Roles = 'Accountant/Tax Agent';
                    contactRoles.put('Accountant/Tax Agent', cloneContactRole);
                }

                if(contactRole.Roles.containsIgnoreCase('Other Adviser')){
                    cloneContactRole = contactRole.clone(false, true, false, false);
                    cloneContactRole.Roles = 'Other Adviser';
                    contactRoles.put('Other Adviser', cloneContactRole);
                }

                if(contactRole.Roles.containsIgnoreCase('Solicitor')){
                    cloneContactRole = contactRole.clone(false, true, false, false);
                    cloneContactRole.Roles = 'Solicitor';
                    contactRoles.put('Solicitor', cloneContactRole);
                }

                forDeletion.put(contactRole.Id, contactRole);
            }
        }

        //Goals
        getGoals();

        //Referrals
        getReferrals();

        //Analysis
        Id needsRecType = ApexAkina_Constants.NEEDS_RECTYPE;
        Id investmentRecType = ApexAkina_Constants.INVESTMENT_RECTYPE;
        analysis = new Map<String, Map<String, Analysis__c>>{client1Type => new Map<String, Analysis__c>(), client2Type => new Map<String, Analysis__c>()};
        Map<String, String> analysisType = new Map<String, String>{'Health Insurance' => 'Major Medical Event', 'Income and Mortgage Protection' => 'Making Sure the bills are paid',
        'Trauma' => 'If you are too sick to work', 'TPD' => 'Injury and Permanent Disability', 'Life Cover' => 'Premature Death'};
        clientBenefits = new Map<String, FactFindingControllerService.BenefitsRequired>{client1Type => new FactFindingControllerService.BenefitsRequired(), client2Type => new FactFindingControllerService.BenefitsRequired()};
        for(String key : analysis.keySet()){
            Map<String, Analysis__c> clientAnalysis = analysis.get(key);
            for(Schema.PicklistEntry pe : Analysis__c.Type__c.getDescribe().getPicklistValues()){
                clientAnalysis.put(pe.getValue(), new Analysis__c(Type__c = pe.getValue(), Name = analysisType.containsKey(pe.getValue()) ? analysisType.get(pe.getValue()) : '',
                        RecordTypeId = needsRecType, Account__c = key.equals(client1Type) ? client1.account.Id : null));
            }
            clientAnalysis.put('Risk Analysis', new Analysis__c(Name = 'Understanding you as a Potential Investor', RecordTypeId = investmentRecType, Account__c = key.equals(client1Type) ? client1.account.Id : null));
            analysis.put(key, clientAnalysis);
        }

        for(Analysis__c clientAnalysis : FactFindingControllerSelector.getAnalyses(clientIds)){
            FactFindingControllerService.BenefitsRequired benefit = new FactFindingControllerService.BenefitsRequired();
            Boolean benefitValid = false;

            if(String.isNotBlank(clientAnalysis.Benefits_Required__c) && clientAnalysis.Type__c == 'Health Insurance'){
                benefit.option1 = clientAnalysis.Benefits_Required__c.containsIgnoreCase('Hospital');
                benefit.option2 = clientAnalysis.Benefits_Required__c.containsIgnoreCase('Specialists and tests');
                benefit.option3 = clientAnalysis.Benefits_Required__c.containsIgnoreCase('Doctors and prescriptions');
                benefit.option4 = clientAnalysis.Benefits_Required__c.containsIgnoreCase('Optical and dental');
                benefit.option5 = clientAnalysis.Benefits_Required__c.containsIgnoreCase('Childrens Cover');
                benefitValid = true;
            }

            analysis.get(clientAnalysis.Account__c == client1.account.Id ? client1Type : client2Type).put(clientAnalysis.RecordTypeId == needsRecType ? clientAnalysis.Type__c : 'Risk Analysis', clientAnalysis);
            if(benefitValid && clientAnalysis.RecordTypeId == needsRecType){
                clientBenefits.put(clientAnalysis.Account__c == client1.account.Id ? client1Type : client2Type, benefit);
            }

            if(clientAnalysis.Risk_Profile_Score__c > 0){
                totals[3] = clientAnalysis.Risk_Profile_Score__c;
            }
        }

        //Analysis Survey
        if(String.isNotBlank(analysis.get(client1Type).get('Risk Analysis').Id)){
            for(Analysis_Survey__c analysisSurvey : FactFindingControllerSelector.getAnalysisSurveysByAnalysisId(analysis.get(client1Type).get('Risk Analysis').Id)){
                if(String.isNotBlank(analysisSurvey.Answer_Value__c)){
                    FactFindingControllerService.QuestionnaireAnswers answer = new FactFindingControllerService.QuestionnaireAnswers(analysisSurvey);
                    answer.option1 = analysisSurvey.Answer_Value__c.equals('A');
                    answer.option2 = analysisSurvey.Answer_Value__c.equals('B');
                    answer.option3 = analysisSurvey.Answer_Value__c.equals('C');
                    answer.option4 = analysisSurvey.Answer_Value__c.equals('D');
                    answer.option5 = analysisSurvey.Answer_Value__c.equals('E');
                    investmentRiskQ.put(analysisSurvey.Name, answer);
                }
            }
        }

        // get Apex Serviced Cover Benefits - Pablo Martinez
        getApexServicedCover();
                
        // get Non Apex Policy  - Alvin Aquino - Changed by Pablo Martinez 12/05/2021
        getNonApexServicedCover();

    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Get methods
    **/
    public Boolean getClient2IncomeIsEmpty() {
        return incomeAndExpenses.containsKey(client2Type) ? incomeAndExpenses.get(client2Type).isEmpty() : true;
    }

    public Boolean getClient1IncomeIsEmpty() {
        return incomeAndExpenses.containsKey('Client 1 - Income') ? incomeAndExpenses.get('Client 1 - Income').isEmpty() : true;
    }

    public Boolean getExpensesIsEmpty() {
        return incomeAndExpenses.containsKey('Client 1 - Expenses') ? incomeAndExpenses.get('Client 1 - Expenses').isEmpty() : true;
    }

    public Boolean getClient1EmploymentIsEmpty() {
        System.debug('Employment: ' + employment);
        return employment != null && employment.containsKey(client1Type) ? employment.get(client1Type).isEmpty() : true;
    }

    public Boolean getClient2EmploymentIsEmpty() {
        return employment != null && employment.containsKey(client2Type) ? employment.get(client2Type).isEmpty() : true;
    }

    public Boolean getAssetsIsEmpty() {
        return assetRoleWrappers.isEmpty();     //Sid 3.0
    }

    public Boolean getLiabilitiesIsEmpty() {
        return liabilityRoleWrappers.isEmpty();
    }

    public Boolean getConLiabilitiesIsEmpty() {
        return contingentLiabilityWrappers.isEmpty();
    }

    public Boolean getOtherEntitiesIsEmpty() {
        return otherEntitiesWrappers.isEmpty();
    }

    public Boolean getOtherEntitiesRolesIsEmpty() {
        return otherEntityToAddEdit == null || otherEntityToAddEdit.roles.isEmpty();
    }

    public Boolean getFamilyMembersIsEmpty() {
        return familyMemberWrappers == null || familyMemberWrappers.isEmpty();
    }

    public Boolean getNonApexCoverIsEmpty() {
        return nonApexCoverWrappers == null || nonApexCoverWrappers.isEmpty();
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to add employment record
    **/
    public void addEmployment() {
        if(employment.containsKey(keys)){
            employment.get(keys).add(new FactFindingControllerService.EmploymentWrapper(new Employment_Detail__c(Current_Occupation__c = true), '', ''));
        }
    }

    /**
   *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
   *   @description Method to add family member record
   **/
    public void addEditFamilyMember() {
        // Get values
        String relationshipAccountId = ApexPages.currentPage().getParameters().get( 'memberAccountId' );
        familyMemberToAddEdit = new FactFindingControllerService.FamilyMemberWrapper();

        if (!String.isBlank(relationshipAccountId)) {
            differentLastName = false;
            for (FactFindingControllerService.FamilyMemberWrapper fmWrapper : familyMemberWrappers) {
                if (fmWrapper.account.Id == relationshipAccountId) {
                    // do this to get a new copy every time
                    familyMemberToAddEdit = (FactFindingControllerService.FamilyMemberWrapper) JSON.deserialize(JSON.serialize(fmWrapper), FactFindingControllerService.FamilyMemberWrapper.class);
                }
            }
        } else {
            // default until age 21
            familyMemberToAddEdit.account.Dependant_until_age__pc = ApexAkina_Constants.DEPENDANT_UNTIL_AGE;

            // add the last name if it's only primary owner or primary owner last name = joint owner last name
            if ((client2.account.Id != null && client1.account.LastName == client2.account.LastName) || client2.account.Id == null) {
                familyMemberToAddEdit.account.LastName = client1.account.LastName;
            } else {
                differentLastName = true;
            }
        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to add other Entity record
    **/
    public void addEditOtherEntity() {
        // Get values
        String entityAccountId = ApexPages.currentPage().getParameters().get( 'otherEntityAccountId' );
        otherEntityToAddEdit = new FactFindingControllerService.OtherEntitiesWrapper();

        if (!String.isBlank(entityAccountId)) {
            for (FactFindingControllerService.OtherEntitiesWrapper oeWrapper : otherEntitiesWrappers) {
               if (oeWrapper.account.Id == entityAccountId) {
                   // do this to get a new copy every time
                   otherEntityToAddEdit = (FactFindingControllerService.OtherEntitiesWrapper) JSON.deserialize(JSON.serialize(oeWrapper), FactFindingControllerService.OtherEntitiesWrapper.class);
               }
           }
        }
    }

    /**
    *   @author Pablo Martinez (pablo@beintelligent.nz)
    *   @description Add line of non apex policy
    **/
    public void addNonApexPolicy() {
        nonApexCoverWrappers.add(new FactFindingControllerService.NonApexCoverWrapper());
    }

    public void selectLegalEntity() {
        if (otherEntityToAddEdit.account != null && String.isNotBlank(otherEntityToAddEdit.account.Id)) {
            otherEntityToAddEdit.account = FactFindingControllerSelector.getAccountById(otherEntityToAddEdit.account.Id);
        } else {
            otherEntityToAddEdit.account = new Account(RecordTypeId = ApexAkina_Constants.ACC_LEGALENTITYRECTYPE);
        }
    }

    public void selectFamilyAccount() {
        if (familyMemberToAddEdit.account != null && String.isNotBlank(familyMemberToAddEdit.account.Id)) {
            familyMemberToAddEdit.account = FactFindingControllerSelector.getAccountById(familyMemberToAddEdit.account.Id);

            // add the birthdate
            String dob = familyMemberToAddEdit.account.PersonBirthdate != null ? familyMemberToAddEdit.account.PersonBirthdate.format() : '';
            familyMemberToAddEdit.stringDate = FactFindingControllerService.formatDateToString(dob);

            if (familyMemberToAddEdit.account.Dependant_until_age__pc == null) {
                familyMemberToAddEdit.account.Dependant_until_age__pc = ApexAkina_Constants.DEPENDANT_UNTIL_AGE;
            }
        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to add asset data
    **/
    public void addEditAsset() {
        // Get values
        String tempId = ApexPages.currentPage().getParameters().get( 'tempId' );

        assetToAddEdit = new FactFindingControllerService.AssetRoleWrapper();

        if (!String.isBlank(tempId)) {
            for (FactFindingControllerService.AssetRoleWrapper arWrapper : assetRoleWrappers) {
                if (arWrapper.tempId == tempId) {
                    // do this to get a new copy every time
                    assetToAddEdit = arWrapper;
                }
            }
        }
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to add income record
    **/
    public void addIncome() {
        if(incomeAndExpenses.containsKey(keys)){
            Income_and_Expense__c inc = new Income_and_Expense__c(RecordTypeId = ApexAkina_Constants.INCOME_RECTYPE);
            incomeAndExpenses.get(keys).add(new FactFindingControllerService.IncomeExpenseWrapper(inc));
        }
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to add expense record
    **/
    public void addExpense() {
        if(incomeAndExpenses.containsKey(keys)){
            Income_and_Expense__c exp = new Income_and_Expense__c(RecordTypeId = ApexAkina_Constants.EXPENSE_RECTYPE);
            incomeAndExpenses.get(keys).add(new FactFindingControllerService.IncomeExpenseWrapper(exp));
        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to add new Institution
    **/
    public void addNewInstitution() {
        newInstitution = new Account(RecordTypeId = ApexAkina_Constants.ACC_BUSINESSRECTYPE);
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to add asset record
    **/
    public void addAsset() {
        assetRoleWrappers.add(new FactFindingControllerService.AssetRoleWrapper());
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to add liability record
    **/
    public void addLiability() {
        liabilityRoleWrappers.add(new FactFindingControllerService.LiabilityRoleWrapper());
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to add contingent liability record
    **/
    public void addConLiability() {
        contingentLiabilityWrappers.add(new FactFindingControllerService.LiabilityRoleWrapper());
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to add an other entity role
    **/
    public void addOtherEntityRole() {
        otherEntityToAddEdit.roles.add(new FactFindingControllerService.OtherEntitiesRolesWrapper());
    }

    // get the map serialized to use in javascript
    public String getSerializedMapRelatedAssetList () {
        return JSON.serialize(relatedAssetList);
    }

    // get the map serialized to use in javascript
    public String getSerializedMapAssetTypeLiabilityType () {
        return JSON.serialize(mapAssetTypeLiabilityType);
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to add a goal by type
    **/
    public void addGoal() {
        FactFindingControllerService.GoalsListWrapper goalListWrapper = mapPersonalGoals.get(goalTypeToAdd);

        goalListWrapper.goals.add(new FactFindingControllerService.GoalWrapper(client1.account.Id, ApexAkina_Constants.FINANCIAL_RECTYPE));

        mapPersonalGoals.put(goalTypeToAdd, goalListWrapper);
    }

    // Initialize salutation picklist.
    public List<SelectOption> salutationList {
        get {
            if(salutationList == null){
                salutationList = new List<SelectOption>();
                salutationList.add(new SelectOption('', '--None--'));
                for(Schema.PicklistEntry pe : Account.Salutation.getDescribe().getPicklistValues()){
                    salutationList.add(new SelectOption(pe.getValue(), pe.getLabel()));
                }
            }
            return salutationList;
        }
        set;
    }

    public Map<String, SelectOption> genericOwnerList {
        get {
            genericOwnerList = new Map<String, SelectOption>();

            // add joint as first
            if (client2.account.Name != null) {
                genericOwnerList.put(ApexAkina_Constants.JOINT, new SelectOption(ApexAkina_Constants.JOINT, ApexAkina_Constants.JOINT));
            }

            // add primary owner as second
            genericOwnerList.put(client1.account.Id, new SelectOption(client1.account.Id, client1.account.Name));

            // add second owner as third
            if (client2.account.Name != null) {
                genericOwnerList.put(client2.account.Id, new SelectOption(client2.account.Id, client2.account.Name));
            }

            return genericOwnerList;
        }
        set;
    }

    // Initialize owner type picklist.
    public List<SelectOption> ownerTypeList {
        get {

            Map<String, SelectOption> mapOptions = genericOwnerList;

            if (!legalEntityIdsForAssetsLiabilities.isEmpty()) {
                List<Account> accounts = FactFindingControllerSelector.getAccountByIds(legalEntityIdsForAssetsLiabilities);

                // add other Entities
                for (Account account : accounts) {
                    if (!mapOptions.containsKey(account.Id)) {
                        mapOptions.put(account.Id, new SelectOption(account.Id, account.Name));
                    }
                }
            }

             ownerTypeList = mapOptions.values();

             return ownerTypeList;
         }
         set;
     }

    // Initialize the related asset list
    public Map<String, List<Client_Asset__c>> relatedAssetList {
        get {
            relatedAssetList = new Map<String, List<Client_Asset__c>>();

            for (FactFindingControllerService.AssetRoleWrapper assetRole : assetRoleWrappers) {
                // if we have liability types related to the asset type
                if (mapAssetTypeLiabilityType.get(assetRole.asset.Type__c) != 'None') {
                    // if we don't have it in the map
                    if (!relatedAssetList.containsKey(mapAssetTypeLiabilityType.get(assetRole.asset.Type__c))) {
                        relatedAssetList.put(mapAssetTypeLiabilityType.get(assetRole.asset.Type__c), new List<Client_Asset__c>());
                    }
                    // add the select option
                    relatedAssetList.get(mapAssetTypeLiabilityType.get(assetRole.asset.Type__c)).add(assetRole.asset);
                }
            }

            return relatedAssetList;
        }
        set;
    }

     // Initialize who picklist.
     public List<SelectOption> whoList {
         get {

             Map<String, SelectOption> mapOptions = genericOwnerList;

             for (Account acc : listDependants) {
                 if (!mapOptions.containsKey(acc.Id)) {
                     mapOptions.put(acc.Id, new SelectOption(acc.Id, acc.Name));
                 }
             }
             whoList = mapOptions.values();

             return whoList;
         }
         set;
     }

    // Initialize dependant type picklist.
    public List<SelectOption> dependantList {
        get {
            dependantList = new List<SelectOption>();
            dependantList.add(new SelectOption('Yes', 'Yes'));
            dependantList.add(new SelectOption('No', 'No'));

            return dependantList;
        }
        set;
    }

     // Initialize personal Guarantee type picklist.
     public List<SelectOption> personalGuaranteeList {
         get {
             personalGuaranteeList = new List<SelectOption>();
             personalGuaranteeList.add(new SelectOption('Yes', 'Yes'));
             personalGuaranteeList.add(new SelectOption('No', 'No'));

             return personalGuaranteeList;
         }
         set;
     }

     // Initialize relation picklist.
     public List<SelectOption> familyRelationList {
         get {
             if(familyRelationList == null){
                 familyRelationList = new List<SelectOption>();

                 for (String rel : mapRelationshipTypes.get(ApexAkina_Constants.FAMILY_MEMBER_RELATIONSHIP_TYPE)) {
                     familyRelationList.add(new SelectOption(rel, rel));
                 }
             }
             return familyRelationList;
         }
         set;
     }

    public String getFamilyRelationListCommaSeparated () {
        return '\'' + String.join(mapRelationshipTypes.get(ApexAkina_Constants.FAMILY_MEMBER_RELATIONSHIP_TYPE), '\',\'') + '\'';
    }

     // Initialize relation picklist.
     public List<SelectOption> otherEntityRoleRelationList {
         get {
             if(otherEntityRoleRelationList == null){
                 otherEntityRoleRelationList = new List<SelectOption>();

                 for (String rel : mapRelationshipTypes.get(ApexAkina_Constants.OTHERENTITIES_RELATIONSHIP_TYPE)) {
                     otherEntityRoleRelationList.add(new SelectOption(rel, rel));
                 }
             }
             return otherEntityRoleRelationList;
         }
         set;
     }

     // Initialize relation picklist.
     public List<SelectOption> contactType {
         get {
             if(contactType == null){
                 contactType = new List<SelectOption>();
                 contactType.add(new SelectOption('Single', 'Single'));
                 contactType.add(new SelectOption(ApexAkina_Constants.JOINT, ApexAkina_Constants.JOINT));
             }
             return contactType;
         }
         set;
     }

     // Initialize time picklist.
     public List<SelectOption> timeList {
         get {
             if(timeList == null){
                 timeList = new List<SelectOption>();
                 for(Integer i=0; i<24; i++){
                     timeList.add(new SelectOption(i + ':00', (i>12 ? i-12 : (i<1 ? 12 : i)) + ':00' + (i>=12 ? ' PM' : ' AM')));
                     timeList.add(new SelectOption(i + ':30', (i>12 ? i-12 : (i<1 ? 12 : i)) + ':30' + (i>=12 ? ' PM' : ' AM')));
                 }
             }
             return timeList;
         }
         set;
     }

     /**
     *   @author David Catindoy (david@cloudinit.nz)
     *   @description Method to re-initialize some variables after change of application type
     **/
    public void changeApplicationType(){
        SavePoint sp = Database.setSavepoint();

        try {
            single = false;
            joint = false;

            if (applicationType == 'Single') {
                client2 = new FactFindingControllerService.AccountWrapper();
                single = true;
                opp.Joint_Owner__c = null;
                joint = false;
                // Delete client 2 application role
                if (String.isNotBlank(applicationRoles.get(client2Type).Account__c)) {
                    delete new Application_Role__c(Id = applicationRoles.get(client2Type).Id);
                }

                // reinitialize the variables
                initialize();
            } else {
                opp.Joint_Owner__c = null;
                joint = true;
                single = false;

                // add new application role
                applicationRoles.put(client2Type, new Application_Role__c(Opportunity__c = opp.Id, Role__c = 'Joint Owner'));
            }

        } catch (Exception e){

            hasError = true;

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage()) // + ' ' + // Only uncomment for debugging purposes
                    // String.escapeSingleQuotes(e.getStackTraceString())
            ));

            Database.rollback(sp);
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));
        }
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to calculate score in the Investment Investor Profile Questionnaire
    **/
    public void calculateScore(){

        totals[3] = 0;
        //Analysis Survey
        for(FactFindingControllerService.QuestionnaireAnswers answer : investmentRiskQ.values()){
            totals[3] += answer.option1 ? 5 : 0;
            totals[3] += answer.option2 ? 4 : 0;
            totals[3] += answer.option3 ? 3 : 0;
            totals[3] += answer.option4 ? 2 : 0;
            totals[3] += answer.option5 ? 1 : 0;
        }

        for(Question_Scoring__mdt score : scoring){
            if(totals[3] >= score.Min__c && totals[3] <= score.Max__c){
                analysis.get(client1Type).get('Risk Analysis').Risk_Profile_Type__c = score.Profile_Type__c;
                break;
            }
        }
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to get client 2 details if there is a record selected
    **/
    public void changeClient2(){

        if(String.isNotBlank(opp.Joint_Owner__c)){

            client2.account = FactFindingControllerSelector.getAccountById(opp.Joint_Owner__c);

            if (client2.account.PersonBirthdate != null) {
                client2.stringDate = FactFindingControllerService.formatDateToString(client2.account.PersonBirthdate.format());
            }

            single = false;
            joint = true;
            initialApplicationType = ApexAkina_Constants.JOINT;

            if (applicationRoles.get(client2Type).Account__c != opp.Joint_Owner__c || String.isBlank(applicationRoles.get(client2Type).Account__c)) {
                insert new Application_Role__c(Opportunity__c = opp.Id, Role__c = 'Joint Owner', Account__c = opp.Joint_Owner__c, Fact_Find__c = factFind.Id);
            }

            initialize();
        } else {
            client2 = new FactFindingControllerService.AccountWrapper();

            if (String.isNotBlank(applicationRoles.get(client2Type).Account__c)) {
                delete new Application_Role__c(Id = applicationRoles.get(client2Type).Id);
                applicationRoles.put(client2Type, new Application_Role__c(Opportunity__c = opp.Id, Role__c = 'Joint Owner'));
            }

        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to reset and clean the scope of engagement variables
    **/
    public void cleanScopeOfEngagement () {
        resetScopeOfEngagement = true;
        opp.Services__c = '';
        opp.Risk_Providers__c = '';
        opp.Kiwisaver_Providers__c = '';
        opp.Benefits__c = '';
        opp.Investment_Providers__c = '';
        opp.Mortgage_Providers__c = '';
    }

    /**
   *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
   *   @description Method to save the Scope of engagement variables
   **/
    public void saveScopeOfEngagement() {
        resetScopeOfEngagement = false;
        upsert new Opportunity(
                Id = opp.Id,
                Services__c = opp.Services__c,
                Risk_Providers__c = opp.Risk_Providers__c,
                Kiwisaver_Providers__c = opp.Kiwisaver_Providers__c,
                Benefits__c = opp.Benefits__c,
                Investment_Providers__c = opp.Investment_Providers__c,
                Mortgage_Providers__c = opp.Mortgage_Providers__c
        );

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Scope of Engagement successfully saved.'));
    }

    /**
   *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
   *   @description Method to reset and clean the Letter of Authority variables
   **/
    public void cleanLetterOfAuthority () {
        resetLetterOfEngagement = true;
        opp.Letter_of_Authority_Scope__c = '';
    }

    /**
   *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
   *   @description Method to save the Letter of Authority variables
   **/
    public void saveLetterOfAuthority() { 
        Set<String> values = new Set<String>();
         
        for(Schema.PicklistEntry pe : Opportunity.Letter_of_Authority_Scope__c.getDescribe().getPicklistValues()){
            // if it's empty then add all the values to the field
            if (String.isBlank(opp.Letter_of_Authority_Scope__c)) {
                values.add(pe.getValue());
            }
            else{ //if not add the values that exist in the field
               if(opp.Letter_of_Authority_Scope__c.containsIgnoreCase(pe.getValue())){
                   values.add(pe.getValue());
               }
            }
        }
    
        resetLetterOfEngagement = false;
        upsert new Opportunity(
                Id = opp.Id,
                Letter_of_Authority_Scope__c = String.join(new List<String>(values), ';'),
                Servicing_Adviser__c = opp.Servicing_Adviser__c
        );

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Letter of Authority successfully saved.'));
    }

    /**
   *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
   *   @description Method to save a new Institution
   **/
    public void saveNewInstitution() {
        String rowTempId = ApexPages.currentPage().getParameters().get( 'tempId' );
        String origin = ApexPages.currentPage().getParameters().get( 'origin' );

        // insert the account
        insert newInstitution;

        if (origin == 'Liability') {
            // set the id to the correspondent liability
            for (FactFindingControllerService.LiabilityRoleWrapper liabRole : liabilityRoleWrappers) {
                if (liabRole.tempId == rowTempId) {
                    liabRole.liability.Institution__c = newInstitution.Id;
                }
            }
        }
        else {
            if (origin == 'Asset') {
                for (FactFindingControllerService.AssetRoleWrapper asRole : assetRoleWrappers) {
                    if (asRole.tempId == rowTempId) {
                        asRole.asset.Provider__c = newInstitution.Id;
                    }
                }
            }
        }

    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to save client details captured in "Know Your Client" tab
    **/
    public void saveClientDetails() {

        SavePoint sp = Database.setSavepoint();

        System.debug('Save Client Details: ' + client1);

        try{
            // Initialize containers/variables
            List<Schema.PicklistEntry> ple = Fact_Find__c.Existing_Risk_Insurance_Primary_Owner__c.getDescribe().getPicklistValues();
            List<Account> clients = new List<Account>();
            List<Application_Role__c> appRoles = new List<Application_Role__c>();
            List<Employment_Detail__c> empDetails = new List<Employment_Detail__c>();
            List<Income_and_Expense__c> incomeAndExpense = new List<Income_and_Expense__c>();
            List<Estate_Planning__c> estates = new List<Estate_Planning__c>();
            List<Goal__c> clientGoals = new List<Goal__c>();
            Map<String, AccountContactRelation> acRelations = new Map<String, AccountContactRelation>();

            // Format client birth date
            client1.account.PersonBirthdate = String.isNotBlank(FactFindingControllerService.formatStringToDate(client1.stringDate)) ? Date.valueOf(FactFindingControllerService.formatStringToDate(client1.stringDate)) : null;

            // copy home address to postal address
            if (!client1.differentAddresses && client1.account.PersonMailingAddress == null) {
                client1.account.PersonMailingStreet = client1.account.PersonOtherStreet;
                client1.account.PersonMailingCity = client1.account.PersonOtherCity;
                client1.account.PersonMailingState = client1.account.PersonOtherState;
                client1.account.PersonMailingPostalCode = client1.account.PersonOtherPostalCode;
                client1.account.PersonMailingCountry = client1.account.PersonOtherCountry;
            }

            clients.add(client1.account);

            // Validate if application type is joint and save client 2 details
            if(joint){
                client2.account.PersonBirthdate = String.isNotBlank(FactFindingControllerService.formatStringToDate(client2.stringDate)) ? Date.valueOf(FactFindingControllerService.formatStringToDate(client2.stringDate)) : null;

                // copy home address to postal address
                if (!client2.differentAddresses && client2.account.PersonMailingAddress == null) {
                    client2.account.PersonMailingStreet = client2.account.PersonOtherStreet;
                    client2.account.PersonMailingCity = client2.account.PersonOtherCity;
                    client2.account.PersonMailingState = client2.account.PersonOtherState;
                    client2.account.PersonMailingPostalCode = client2.account.PersonOtherPostalCode;
                    client2.account.PersonMailingCountry = client2.account.PersonOtherCountry;
                }

                if(String.isNotBlank(client2.account.LastName)){
                    clients.add(client2.account);
                } else {
                    applicationType = 'Single';
                    joint = false;
                    hasError = true;

                    ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.ERROR,
                            'Lastname for client 2 is required.'
                    ));
                }
            }

            upsert clients; // Upsert client account details. This will ensure existing accounts will only be updated.

            analysis.get(client1Type).get('Health Insurance').Smoker__c = client1.account.Smoker__pc;

            // Fact Find & Oppty

            //Existing Cover (Start)

            if(existingRisks.get(client1Type).option1){

                factFind.Existing_Risk_Insurance_Primary_Owner__c = ple.get(0).getValue();

            }else if(existingRisks.get(client1Type).option3){

                factFind.Existing_Risk_Insurance_Primary_Owner__c = ple.get(2).getValue();

            }else if(existingRisks.get(client1Type).option4){
                factFind.Existing_Risk_Insurance_Primary_Owner__c = ple.get(3).getValue();
            }else if(existingRisks.get(client1Type).option2){
                factFind.Existing_Risk_Insurance_Primary_Owner__c = ple.get(1).getValue();
            }else {
                factFind.Existing_Risk_Insurance_Primary_Owner__c = null;
            }

            // Populate joint owner fields in both oppty and fact find if the application type is joint
            if(joint){ // Only enter if aplication type is joint
                factFind.Joint_Owner__c = clients.get(1).Id;
                // Change in business logic for Existing Risk

                if(existingRisks.get(client2Type).option1){

                    factFind.Existing_Risk_Insurance_Joint_Owner__c = ple.get(0).getValue();

                }else if(existingRisks.get(client2Type).option3){

                    factFind.Existing_Risk_Insurance_Joint_Owner__c = ple.get(2).getValue();

                }else if(existingRisks.get(client2Type).option4){
                    factFind.Existing_Risk_Insurance_Joint_Owner__c = ple.get(3).getValue();
                }else if(existingRisks.get(client2Type).option2) {
                    factFind.Existing_Risk_Insurance_Joint_Owner__c = ple.get(1).getValue();
                }else {
                    factFind.Existing_Risk_Insurance_Joint_Owner__c = null;
                }

                opp.Joint_Owner__c = clients.get(1).Id;
            } else { // Else empty the fields
                factFind.Joint_Owner__c = null;
                factFind.Existing_Risk_Insurance_Joint_Owner__c = null;
                opp.Joint_Owner__c = null;
            }

            // save non apex serviced cover
            saveNonApexServicedCover();
            
            //Existing Cover (END)

            factFind.Name = (String.isNotBlank(client1.account.FirstName) ? client1.account.FirstName : client1.account.LastName) + ' - Fact Find';
            upsert factFind; // Upsert fact find record.

            opp.Fact_Find__c = factFind.Id;
            upsert opp; // Upsert oppty record.

            // Application Roles
            applicationRoles.get(client1Type).Fact_Find__c = factFind.Id;
            appRoles.add(applicationRoles.get(client1Type));

            // If application type is joint, then create an application role for client 2
            if(joint){
                Application_Role__c appRole = applicationRoles.get(client2Type);
                appRole.Account__c = clients.get(1).Id;
                appRole.Fact_Find__c = factFind.Id;
                appRoles.add(appRole);

                // add the account to the list of accounts for summary if it does not exists
                Boolean accountExists = false;
                for (Account acc : listAccounts) {
                    if (acc.Id == client2.account.Id) {
                        accountExists = true;
                    }
                }

                // add it only if it's not there
                if (!accountExists) {
                    listAccounts.add(client2.account);
                }
            }

            upsert appRoles; // Upsert application roles.

            // Upsert partner relationship
            if(joint){
                upsert new Relationship__c(Account__c = client1.account.Id, Related_Account__c = client2.account.Id, Relationship_Type__c = 'Partner', Fact_Find__c = factFind.Id, External_Id__c = client1.account.Id + '' + client2.account.Id + 'Partner') External_Id__c;
            }

            // Employment Details logic (START)

            List<Employment_Detail__c> empDetail1 = new List<Employment_Detail__c>();
            for(FactFindingControllerService.EmploymentWrapper empDetail : employment.get(client1Type)){
                Employment_Detail__c emp = empDetail.employment;
                // Include only employment details that has a Title or Employer
                if(String.isNotBlank(emp.Job_Title__c) || String.isNotBlank(emp.Employer__c)){
                    emp.Fact_Find__c = factFind.Id;
                    emp.Account__c = clients.get(0).Id;
                    emp.Application_Role__c = appRoles.get(0).Id;
                    emp.Name = String.isNotBlank(emp.Job_Title__c) ? emp.Job_Title__c : emp.Employer__c;
                    emp.Start_Date__c = String.isNotBlank(FactFindingControllerService.formatStringToDate(empDetail.startDate)) ? Date.valueOf(FactFindingControllerService.formatStringToDate(empDetail.startDate)) : null;
                    emp.End_Date__c = String.isNotBlank(FactFindingControllerService.formatStringToDate(empDetail.endDate)) ? Date.valueOf(FactFindingControllerService.formatStringToDate(empDetail.endDate)) : null;
                    empDetail1.add(emp);
                }
            }

            empDetails.addAll(empDetail1);

            if(joint){
                List<Employment_Detail__c> empDetail2 = new List<Employment_Detail__c>();
                for(FactFindingControllerService.EmploymentWrapper empDetail : employment.get(client2Type)){
                    Employment_Detail__c emp = empDetail.employment;
                    if(String.isNotBlank(emp.Job_Title__c) || String.isNotBlank(emp.Employer__c)){
                        emp.Account__c = clients.get(1).Id;
                        emp.Application_Role__c = appRoles.get(1).Id;
                        emp.Fact_Find__c = factFind.Id;
                        emp.Name = String.isNotBlank(emp.Job_Title__c) ? emp.Job_Title__c : emp.Employer__c;
                        emp.Start_Date__c = String.isNotBlank(FactFindingControllerService.formatStringToDate(empDetail.startDate)) ? Date.valueOf(FactFindingControllerService.formatStringToDate(empDetail.startDate)) : null;
                        emp.End_Date__c = String.isNotBlank(FactFindingControllerService.formatStringToDate(empDetail.endDate)) ? Date.valueOf(FactFindingControllerService.formatStringToDate(empDetail.endDate)) : null;
                        empDetail2.add(emp);
                    }
                }
                empDetails.addAll(empDetail2);
            }

            upsert empDetails; // Upsert employment details.

            // Employment Details logic (END)

            // Income logic (START)
            for(String key : incomeAndExpenses.keySet()){
                if((key == client2Type && joint) || key == 'Client 1 - Income'){
                    for(FactFindingControllerService.IncomeExpenseWrapper incomeAndExp : incomeAndExpenses.get(key)){
                        // Ignore income with no type
                        if(incomeAndExp.incomeExpense.RecordTypeId == ApexAkina_Constants.INCOME_RECTYPE && incomeAndExp.incomeExpense.Type__c != null){
                            incomeAndExp.incomeExpense.Fact_Find__c = factFind.Id;
                            incomeAndExp.incomeExpense.Owner_Type__c = client1Type;
                            incomeAndExp.incomeExpense.RecordTypeId = ApexAkina_Constants.INCOME_RECTYPE;
                            incomeAndExp.incomeExpense.Application_Role__c = appRoles.get(0).Id;
                            incomeAndExp.incomeExpense.Primary_Owner__c = clients.get(0).Id;

                            if(key == client2Type){
                                incomeAndExp.incomeExpense.Primary_Owner__c = clients.get(1).Id;
                                incomeAndExp.incomeExpense.Application_Role__c = appRoles.get(1).Id;
                                incomeAndExp.incomeExpense.Owner_Type__c = client2Type;
                            }

                            incomeAndExpense.add(incomeAndExp.incomeExpense);
                        }
                    }
                }
            }
            // Income logic (END)

            // Expense logic (START)
            for(FactFindingControllerService.IncomeExpenseWrapper incomeAndExp : incomeAndExpenses.get('Client 1 - Expenses')){
                if(incomeAndExp.incomeExpense.RecordTypeId == ApexAkina_Constants.EXPENSE_RECTYPE && incomeAndExp.incomeExpense.Type__c != null){
                    incomeAndExp.incomeExpense.RecordTypeId = ApexAkina_Constants.EXPENSE_RECTYPE;
                    incomeAndExp.incomeExpense.Fact_Find__c = factFind.Id;
                    incomeAndExp.incomeExpense.Owner_Type__c = client1Type;
                    incomeAndExp.incomeExpense.Application_Role__c = appRoles.get(0).Id;
                    incomeAndExp.incomeExpense.Primary_Owner__c = clients.get(0).Id;
                    incomeAndExpense.add(incomeAndExp.incomeExpense);
                }
            }
            // Expense logic (END)

            if(!incomeAndExpense.isEmpty()){
                upsert incomeAndExpense; // Upsert income and expense details.

                // new map without the empty records
                Map<String, List<FactFindingControllerService.IncomeExpenseWrapper>> newMapIncomeAndExpenses = new Map<String, List<FactFindingControllerService.IncomeExpenseWrapper>>{'Client 1 - Income' => new List<FactFindingControllerService.IncomeExpenseWrapper>(), 'Client 1 - Expenses' => new List<FactFindingControllerService.IncomeExpenseWrapper>(), client2Type => new List<FactFindingControllerService.IncomeExpenseWrapper>()}; 
                // remove the income and/or expenses that weren't saved because of missing fields
                for(String key : incomeAndExpenses.keySet()) { 
                    for (FactFindingControllerService.IncomeExpenseWrapper incomeAndExp : incomeAndExpenses.get(key)) {
                        if (incomeAndExp.incomeExpense.Id != null) {
                            newMapIncomeAndExpenses.get(key).add(incomeAndExp);
                        }
                    }
                }
                // set the map again
                incomeAndExpenses = newMapIncomeAndExpenses;
            }

            // Assets logic (START)
            saveAssetsAndRoles(assetRoleWrappers);
            // Assets logic (END)

            // Liabilities logic (START)
            List<Liability__c> newLiabilities = new List<Liability__c>();      //Liabilities to be created
            List<Liability_Role__c> newLiabilityRoles = new List<Liability_Role__c>();      //Liability Roles to be created//Liability to be updated with Updated Values
            List<Liability__c> liabilitiesToUpdate = new List<Liability__c>();

            //Iterate LiabilitiesRoleWrappers and create new Liabilities
            for(FactFindingControllerService.LiabilityRoleWrapper liabRole : liabilityRoleWrappers){
                // check required fields
                if (liabRole.liability.Type__c != null && liabRole.strOwnerType != null) {
                    // if it's new
                    if (liabRole.liabilityRole.Liability__c == null) {
                        liabRole.liability.Fact_Find__c = factFind.Id;
                        liabRole.liability.Name = liabRole.liability.Type__c;
                        liabRole.liability.Application_Role__c = appRoles.get(0).Id;
                        newLiabilities.add(liabRole.liability);
                    } else {
                        // add the liability to update
                        liabilitiesToUpdate.add(liabRole.liability);
                    }
                }
            }

            //Iterate contingentLiabilityWrappers and create new Contingent Liabilities
            for(FactFindingControllerService.LiabilityRoleWrapper liabRole : contingentLiabilityWrappers){
                // check required fields
                if (liabRole.liability.Type__c != null && liabRole.strOwnerType != null) {
                    // if it's new
                    if (liabRole.liabilityRole.Liability__c == null) {
                        liabRole.liability.Fact_Find__c = factFind.Id;
                        liabRole.liability.Name = liabRole.liability.Type__c;
                        liabRole.liability.Application_Role__c = appRoles.get(0).Id;
                        newLiabilities.add(liabRole.liability);
                    } else {
                        // add the liability to update
                        liabilitiesToUpdate.add(liabRole.liability);
                    }
                }
            }
            //Insert New Liabilities
            insert newLiabilities;
            //Update the Liabilities records
            update liabilitiesToUpdate;

            //Iterate again to create the Liabilities Roles
            for(FactFindingControllerService.LiabilityRoleWrapper liabRole : liabilityRoleWrappers) {
                if (liabRole.liabilityRole.Liability__c == null && liabRole.liability.Type__c != null && liabRole.strOwnerType != null) {
                    liabRole.liabilityRole.Liability__c = liabRole.liability.Id;
                    liabRole.liabilityRole.Liability_Type__c = liabRole.liability.Type__c;
                    liabRole.liabilityRole.Liability_Value__c = liabRole.liability.Current_Balance__c;

                    // If Joint Liability is being created
                    if (liabRole.strOwnerType.equalsIgnoreCase(ApexAkina_Constants.JOINT)) {
                        liabRole.liabilityRole.Account__c = client1.account.Id;

                        //Create 2nd Liability Role
                        Liability_Role__c liabilityRole2 = new Liability_Role__c();
                        liabilityRole2.Liability__c = liabRole.liability.Id;
                        liabilityRole2.Liability_Type__c = liabRole.liability.Type__c;
                        liabilityRole2.Liability_Value__c = liabRole.liability.Current_Balance__c;
                        liabilityRole2.Account__c = client2.account.Id;

                        newLiabilityRoles.add(liabRole.liabilityRole);
                        newLiabilityRoles.add(liabilityRole2);
                    }

                    // any other case
                    else {
                        liabRole.liabilityRole.Account__c = liabRole.strOwnerType;
                        newLiabilityRoles.add(liabRole.liabilityRole);
                    }
                }
            }

            //Iterate again to create the Liabilities Roles for Contingent
            for(FactFindingControllerService.LiabilityRoleWrapper liabRole : contingentLiabilityWrappers) {
                if (liabRole.liabilityRole.Liability__c == null && liabRole.liability.Type__c != null && liabRole.strOwnerType != null) {
                    liabRole.liabilityRole.Account__c = client1.account.Id;
                    liabRole.liabilityRole.Liability__c = liabRole.liability.Id;
                    liabRole.liabilityRole.Liability_Type__c = liabRole.liability.Type__c;
                    liabRole.liabilityRole.Liability_Value__c = liabRole.liability.Current_Balance__c;
                    newLiabilityRoles.add(liabRole.liabilityRole);
                }
            }
            //Insert New Liabilities Roles
            insert newLiabilityRoles;


            // new list without the empty records
            List<FactFindingControllerService.LiabilityRoleWrapper> newLiabilityRoleWrapper = new List<FactFindingControllerService.LiabilityRoleWrapper>();
            // remove the liabilties roles that weren't saved because of missing fields
            for (FactFindingControllerService.LiabilityRoleWrapper liabRole : liabilityRoleWrappers) {
                if (liabRole.liabilityRole.Id != null) {
                    newLiabilityRoleWrapper.add(liabRole);
                }
            }
            liabilityRoleWrappers = newLiabilityRoleWrapper;

            // new list without the empty records
            newLiabilityRoleWrapper = new List<FactFindingControllerService.LiabilityRoleWrapper>();
            // remove the liabilties roles that weren't saved because of missing fields
            for (FactFindingControllerService.LiabilityRoleWrapper liabRole : contingentLiabilityWrappers) {
                if (liabRole.liabilityRole.Id != null) {
                    newLiabilityRoleWrapper.add(liabRole);
                }
            }
            contingentLiabilityWrappers = newLiabilityRoleWrapper;

            //Make changes in the existing Liability Roles if Any

            //Liability Roles to be Created / Updated
            List<Liability_Role__c> upsertLiabilityRoles = new List<Liability_Role__c>();
            //Liability Roles to be deleted
            List<Liability_Role__c> deleteLiabilityRoles = new List<Liability_Role__c>();

            for(FactFindingControllerService.LiabilityRoleWrapper liabRole : liabilityRoleWrappers){
                // check for the ownertype not null to do this
                if (liabRole.strOwnerType != null && mapLiabilityRoles.containsKey(liabRole.liability.Id)) {
                    //Get the Liability from the map mapLiabilityRoles
                    List<Liability_Role__c> tempLiabilityRoles = mapLiabilityRoles.get(liabRole.liability.Id);

                    //If the Liability Role was Joint and CHANGED
                    if (tempLiabilityRoles.size() > 1) {
                        //If the Owner Type is CHANGED FROM JOINT
                        if (!liabRole.strOwnerType.equalsIgnoreCase(ApexAkina_Constants.JOINT)) {

                            // if it's not client1 and client2 then add to upsert
                            if (liabRole.strOwnerType != client1.account.Id && liabRole.strOwnerType != client2.account.Id) {
                                liabRole.liabilityRole.Account__c = liabRole.strOwnerType;
                                upsertLiabilityRoles.add(liabRole.liabilityRole);
                            }

                            // traverse the original liability roles to delete or update to other
                            for (Liability_Role__c tempLiabRole : tempLiabilityRoles) {

                                // if it's a different account, then delete the role, if not, check if other and client1
                                if (tempLiabRole.Account__c != liabRole.strOwnerType) {
                                    deleteLiabilityRoles.add(tempLiabRole);
                                }
                            }
                        }
                    }
                    //If the Liability Role wasn't Joint
                    else {
                        Liability_Role__c tempLiabRole = tempLiabilityRoles[0];

                        // if it's JOINT
                        if (liabRole.strOwnerType.equalsIgnoreCase(ApexAkina_Constants.JOINT)) {
                            Liability_Role__c newLiabilityRole = new Liability_Role__c(
                                    Liability__c = liabRole.liability.Id,
                                    Liability_Type__c = liabRole.liability.Type__c,
                                    Liability_Value__c = liabRole.liability.Current_Balance__c
                            );

                            // If it was client1 or client2 then create the other one
                            if (tempLiabRole.Account__c == client1.account.Id || tempLiabRole.Account__c == client2.account.Id) {

                                // add to upsert
                                upsertLiabilityRoles.add(tempLiabRole);

                                // add the corresponding account
                                newLiabilityRole.Account__c = (tempLiabRole.Account__c == client1.account.Id ? client2.account.Id : client1.account.Id);
                                upsertLiabilityRoles.add(newLiabilityRole);
                            } else {
                                // if it isn't client1 or 2, then need to delete that role and create 2 new ones
                                deleteLiabilityRoles.add(tempLiabRole);

                                // create for client 1
                                newLiabilityRole.Account__c = client1.account.Id;

                                // create for client 2
                                Liability_Role__c newLiabilityRole2 = new Liability_Role__c(
                                        Liability__c = liabRole.liability.Id,
                                        Liability_Type__c = liabRole.liability.Type__c,
                                        Liability_Value__c = liabRole.liability.Current_Balance__c,
                                        Account__c = client2.account.Id
                                );

                                // add both to upsert
                                upsertLiabilityRoles.add(newLiabilityRole);
                                upsertLiabilityRoles.add(newLiabilityRole2);
                            }
                        } else {
                            tempLiabRole.Account__c = liabRole.strOwnerType;
                            upsertLiabilityRoles.add(tempLiabRole);
                        }
                    }
                }
            }

            delete deleteLiabilityRoles;        //Delete the Redundant Liabilities Roles
            upsert upsertLiabilityRoles;        //Upsert the Liabilities Roles for which ownership changed

            // Liabilities logic (END)

            // Estate Planning logic (START)
            estatePlanning.get(client1Type).Fact_Find__c = factFind.Id;
            estatePlanning.get(client1Type).Primary_Owner__c = clients.get(0).Id;
            estatePlanning.get(client1Type).Application_Role__c = appRoles.get(0).Id;
            estates.add(estatePlanning.get(client1Type));
            if(joint){
                Estate_Planning__c estate = estatePlanning.get(client2Type);
                estate.Primary_Owner__c = clients.get(1).Id;
                estate.Application_Role__c = appRoles.get(1).Id;
                estate.Fact_Find__c = factFind.Id;
                estates.add(estate);
            }

            upsert estates; // Upsert estate details.

            Map<String, Contact> validContacts = new Map<String, Contact>();
            Map<String, String> completeNames = new Map<String, String>();
            Map<String, Account> validFirms = new Map<String, Account>();
            for(String key : professionals.keySet()){
                if(String.isBlank(contactRoles.get(key).ContactId) && String.isNotBlank(professionals.get(key).LastName)){
                    completeNames.put(key, professionals.get(key).LastName);
                    if(professionals.get(key).LastName.contains(' ')){
                        List<String> names = professionals.get(key).LastName.split(' ');
                        professionals.get(key).FirstName = names.get(0);
                        professionals.get(key).LastName = names.get(1);
                    }
                    validContacts.put(key, professionals.get(key));
                    validFirms.put(key, new Account(RecordTypeId = ApexAkina_Constants.ACC_BUSINESSRECTYPE, Name = String.isBlank(contactRoles.get(key).Firm__c) ? completeNames.get(key) : contactRoles.get(key).Firm__c));
                }
            }

            if(!validFirms.isEmpty()){
                upsert validFirms.values();
            }

            for(String key : validContacts.keySet()){
                validContacts.get(key).AccountId = validFirms.get(key).Id;
            }

            if(!validContacts.isEmpty()){
                upsert validContacts.values();
                for(String key : validContacts.keySet()){
                    professionals.get(key).LastName = '';
                }
            }

            if(!forDeletion.isEmpty()){
                delete FactFindingControllerSelector.getAccountContactRelationsByIds(forDeletion.keySet());
                forDeletion = new Map<String, AccountContactRelation>();
            }

            // Create or update Account Contact Relationship
            for(AccountContactRelation acRelation : contactRoles.values()){

                if(String.isNotBlank(acRelation.ContactId)){
                    if(acRelations.containsKey(acRelation.ContactId)){
                        AccountContactRelation acRel = acRelations.get(acRelation.ContactId);
                        acRel.Roles += String.isNotBlank(acRel.Roles) ? ';' + acRelation.Roles : acRelation.Roles;
                        acRelations.put(acRelation.ContactId, acRel);
                    } else {
                        acRelations.put(acRelation.ContactId, acRelation);
                    }
                } else if(validContacts.containsKey(acRelation.Roles)){
                    AccountContactRelation cloneACRec = new AccountContactRelation(IsActive = true, AccountId = client1.account.Id, Roles = acRelation.Roles, ContactId = validContacts.get(acRelation.Roles).Id, Firm__c = acRelation.Firm__c);
                    acRelations.put(cloneACRec.ContactId, cloneACRec);
                }
            }

            if(!acRelations.isEmpty()){
                upsert acRelations.values();
                // Logic to get rid of old records that are no longer applicable
                for(AccountContactRelation acRelation : acRelations.values()){
                    if(String.isNotBlank(acRelation.Roles)){
                        AccountContactRelation cloneContactRole = null;
                        if(acRelation.Roles.containsIgnoreCase('Accountant/Tax Agent')){
                            cloneContactRole = acRelation.clone(false, true, false, false);
                            cloneContactRole.Roles = 'Accountant/Tax Agent';
                            contactRoles.put('Accountant/Tax Agent', cloneContactRole);
                        }

                        if(acRelation.Roles.containsIgnoreCase('Other Adviser')){
                            cloneContactRole = acRelation.clone(false, true, false, false);
                            cloneContactRole.Roles = 'Other Adviser';
                            contactRoles.put('Other Adviser', cloneContactRole);
                        }

                        if(acRelation.Roles.containsIgnoreCase('Solicitor')){
                            cloneContactRole = acRelation.clone(false, true, false, false);
                            cloneContactRole.Roles = 'Solicitor';
                            contactRoles.put('Solicitor', cloneContactRole);
                        }

                        forDeletion.put(acRelation.Id, acRelation);
                    }
                }
            }

            // Estate Planning logic (END)

            //Goals
            for(String goalType : mapPersonalGoals.keySet()){
                for (FactFindingControllerService.GoalWrapper goalWrapper : mapPersonalGoals.get(goalType).goals) {
                   if (goalWrapper.goal.RecordTypeId == ApexAkina_Constants.FINANCIAL_RECTYPE) {
                       goalWrapper.goal.Fact_Find__c = factFind.Id;
                       goalWrapper.goal.Section__c = goalType;
                       clientGoals.add(goalWrapper.goal);
                   }
               }
            }

            if(!clientGoals.isEmpty()){
                upsert clientGoals;
            }

            //Referrals
            List<Referral__c> referralsToUpsert = new List<Referral__c>();
            String taskDescription;
            Referral__c newReferral;

            for (String key : referralTypes.keySet()) {
                for(FactFindingControllerService.ReferralWrapper ref : referralTypes.get(key)) {
                    newReferral = new Referral__c(
                            Name = ref.referralType.MasterLabel,
                            Type__c = ref.referralType.MasterLabel,
                            Notes__c = ref.notes,
                            Contact_Financial_Details__c = factFind.Referral_Contact_Financial_Details__c,
                            Referral_Disclosure__c = factFind.Referral_Disclosure__c,
                            Opportunity__c = opp.Id,
                            Account__c = opp.AccountId
                    );

                    // internal, if there is a user selected and the user selected is different
                    if (String.isNotBlank(ref.internalUserIdSelected) && ref.userInternalIdChanged) {
                        newReferral.Internal_Referral__c = ref.internalUserIdSelected;

                        // add the referral to the list for creation
                        referralsToUpsert.add(newReferral);
                    }
                    else {
                        if (String.isNotBlank(ref.referral.Id) && ref.referral.Notes__c != ref.notes) {
                            referralsToUpsert.add(new Referral__c(Id = ref.referral.Id, Notes__c = ref.notes));
                        }
                    }

                    // external, if it's checked
                    if (ref.externalChecked) {
                        // if it has a provider selected
                        if (ref.externalProviderSelected != null) {
                            newReferral.External_Referral__c = mapReferralProviders.get(ref.externalProviderSelected).AccountId__c;
                        }

                        // add the referral to the list for creation
                        referralsToUpsert.add(newReferral);

                        // create the first line of the task Description or add a line break
                        if (taskDescription == null) {
                            taskDescription = 'Referrals Required: \n\n';
                        } else {
                            taskDescription += '\n\n';
                        }

                        // add the complete description
                        taskDescription += ref.referralType.MasterLabel +
                                ((ref.externalProviderSelected != null && mapReferralProviders.get(ref.externalProviderSelected).MasterLabel != 'None')
                                        ? ' - ' + mapReferralProviders.get(ref.externalProviderSelected).MasterLabel +
                                                (mapReferralProviders.get(ref.externalProviderSelected).Portal_URL__c != null 
                                                    ? ' - ' + mapReferralProviders.get(ref.externalProviderSelected).Portal_URL__c 
                                                    : '') +
                                                (mapReferralProviders.get(ref.externalProviderSelected).Referral_Text__c != null 
                                                    ? ' - ' + mapReferralProviders.get(ref.externalProviderSelected).Referral_Text__c 
                                                    : '')                                               
                                        : '') +
                                '\n\n Notes: ' + ref.notes;
                    }
                }
            }

            // if we have a task description then we need to create the task
            if (taskDescription != null) {
                // create the task
               insert new Task(
                       Subject = 'Referrals for ' + client1.account.Client_Preferred_Name__c + (client2.account.Id != null ? ' and ' + client2.account.Client_Preferred_Name__c : ''),
                       WhatId = opp.Id,
                       WhoId = client1.account.PersonContactId,
                       Description = taskDescription,
                       Status = 'Not Started',
                       Priority = 'High',
                       ActivityDate = System.today(),
                       OwnerId = UserInfo.getUserId(),
                       RecordTypeId = ApexAkina_Constants.TASKS_RECTYPE,
                       Type = 'Other'
                );
            }

            // if there is some referrals to upsert then upsert
            if(!referralsToUpsert.isEmpty()){
                upsert referralsToUpsert;
            }

            if(!hasError){
                // set address flag
                setAddressDifferent();

                // Query again the opportunity to use the formula fields for the Conga Button
                opp = FactFindingControllerSelector.getOpportunityById(recordId);

                // pull the details again
                pullFactFindDetails();

                ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.CONFIRM,
                        'Saved successfully!'
                ));
            }
        } catch (Exception e){

            hasError = true;

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage())  //+ ' ' + // Only uncomment for debugging purposes
                     //String.escapeSingleQuotes(e.getStackTraceString())
            ));
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));

            Database.rollback(sp);
        }
    }

    /*********************************************************************************************************
     * @name			saveNonApexServicedCover
     * @author			Pablo Martinez <pablo@beintelligent.nz>
     * @created			12 / 05 / 2021
     * @description		Save the records of the Non Apex Serviced Cover from the Fact FactFindingControllerService
    **********************************************************************************************************/
    public void saveNonApexServicedCover() {
        List<Non_Apex_Cover__c> listNACtoUpsert = new List <Non_Apex_Cover__c>();
        if (!nonApexCoverWrappers.isEmpty()) {
            for (FactFindingControllerService.NonApexCoverWrapper nacWrapper: nonApexCoverWrappers) {
                if (nacWrapper.nonApexCover.Person_Insured__c != null) {
                    // if it's client 1 or 2 check the right second risk chechbox
                    // if it's neither, then it's a child and we need to populate the related_account__c field
                    if (client1.account.Id == nacWrapper.nonApexCover.Person_Insured__c) {
                        existingRisks.get(client1Type).option2 = true;
                    } else if (client2.account.Id == nacWrapper.nonApexCover.Person_Insured__c) {
                        existingRisks.get(client2Type).option2 = true;
                    } else {
                        // get the related family member
                        for (FactFindingControllerService.FamilyMemberWrapper familyMember : listAllFamily) {
                            if (familyMember.account.Id == nacWrapper.nonApexCover.Person_Insured__c) {
                                nacWrapper.nonApexCover.Related_Account__c = familyMember.relationship.Account__c;
                            }
                        }
                    }

                    listNACtoUpsert.add(nacWrapper.nonApexCover);
                }
            }
        }

        // if we have something then upsert
        if (!listNACtoUpsert.isEmpty()) {
            upsert listNACtoUpsert;
        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to save assets and asset roles
    **/
    public void saveAssetsAndRoles (List<FactFindingControllerService.AssetRoleWrapper> assets) {
        List<Client_Asset__c> newAssets = new List<Client_Asset__c>();      //Assets to be created for newly added Assets
        List<Asset_Role__c> newAssetRoles = new List<Asset_Role__c>();      //Asset Role to be created for newly added Assets
        List<Client_Asset__c> assetsToUpdate = new List<Client_Asset__c>(); // Assets to update

        //Iterate AssetsRoleWrappers and create new Assets or update
        for(FactFindingControllerService.AssetRoleWrapper asRole : assets){
            // check required fields
            if (asRole.asset.Type__c != null && asRole.asset.Value__c != null && asRole.strOwnerType != null) {
                // if it's new
                if (asRole.assetRole.Asset__c == null) {
                    asRole.asset.Fact_Find__c = factFind.Id;
                    asRole.asset.Name = asRole.asset.Type__c;
                    newAssets.add(asRole.asset);
                } else {
                    // add the asset to update if the value changed
                    assetsToUpdate.add(asRole.asset);
                }
            }
        }

        //Insert New Assets
        insert newAssets;
        //Update the Assets records
        update assetsToUpdate;

        //Iterate again to create the asset Roles
        for(FactFindingControllerService.AssetRoleWrapper asRole : assets) {
            if (asRole.assetRole.Asset__c == null && asRole.asset.Type__c != null && asRole.asset.Value__c != null && asRole.strOwnerType != null) {

                asRole.assetRole.Asset__c = asRole.asset.Id;
                asRole.assetRole.Asset_Type__c = asRole.asset.Type__c;
                asRole.assetRole.Asset_Value__c = asRole.asset.Value__c;

                // If Joint Asset is being created
                if (asRole.strOwnerType.equalsIgnoreCase(ApexAkina_Constants.JOINT)) {
                    asRole.assetRole.Account__c = client1.account.Id;

                    //Create 2nd Asset Role
                    Asset_Role__c assetRole2 = new Asset_Role__c();
                    assetRole2.Asset__c = asRole.asset.Id;
                    assetRole2.Asset_Type__c = asRole.asset.Type__c;
                    assetRole2.Asset_Value__c = asRole.asset.Value__c;
                    assetRole2.Account__c = client2.account.Id;

                    newAssetRoles.add(asRole.assetRole);
                    newAssetRoles.add(assetRole2);
                }
                // any other option gos here
                else {
                    asRole.assetRole.Account__c = asRole.strOwnerType;
                    newAssetRoles.add(asRole.assetRole);
                }
            }
        }

        //Insert New Asset Roles
        insert newAssetRoles;

        // new list without the empty records
        List<FactFindingControllerService.AssetRoleWrapper> newAssetRoleWrapper = new List<FactFindingControllerService.AssetRoleWrapper>();
        // remove the asset roles that weren't saved because of missing fields
        for (FactFindingControllerService.AssetRoleWrapper asRole : assets) {
            if (asRole.assetRole.Id != null) {
                newAssetRoleWrapper.add(asRole);
            }
        }
        assets = newAssetRoleWrapper;

        //Sid 3.0
        //Make changes in the existing AssetRoles if Any

        //Asset Roles to be Created / Updated
        List<Asset_Role__c> upsertAssetRoles = new List<Asset_Role__c>();
        //Asset Roles to be deleted
        List<Asset_Role__c> deleteAssetRoles = new List<Asset_Role__c>();

        //Find the corresponding AssetRole record from assetRoleWrappers
        for(FactFindingControllerService.AssetRoleWrapper asRole : assets){
            // Pablo Martinez 07/06/2019
            // check for the ownertype not null to do this
            if (asRole.strOwnerType != null && mapAssetAssetRole.containsKey(asRole.asset.Id)) {
                //Get the Asset from the map mapAssetRoles
                List<Asset_Role__c> tempAssetRoles = mapAssetAssetRole.get(asRole.asset.Id);

                //If the Asset Role was Joint and CHANGED
                if (tempAssetRoles.size() > 1) {
                    //If the Owner Type is CHANGED FROM JOINT
                    if (!asRole.strOwnerType.equalsIgnoreCase(ApexAkina_Constants.JOINT)) {
                        // if it's not other client1 and client2 then add to upsert
                        if (asRole.strOwnerType != client1.account.Id && asRole.strOwnerType != client2.account.Id) {
                            asRole.assetRole.Account__c = asRole.strOwnerType;
                            upsertAssetRoles.add(asRole.assetRole);
                        }

                        // traverse the original asset roles to delete or update to other
                        for (Asset_Role__c tempAssetRole : tempAssetRoles) {

                            // if it's a different account, then delete the role, if not, check if other and client1
                            if (tempAssetRole.Account__c != asRole.strOwnerType) {
                                deleteAssetRoles.add(tempAssetRole);
                            }
                        }
                    }
                }
                //If the Asset Role wasn't Joint
                else {
                    Asset_Role__c tempAssetRole = tempAssetRoles[0];

                    // if it's JOINT
                    if (asRole.strOwnerType.equalsIgnoreCase(ApexAkina_Constants.JOINT)) {
                        Asset_Role__c newAssetRole = new Asset_Role__c(
                                Asset__c = asRole.asset.Id,
                                Asset_Type__c = asRole.asset.Type__c,
                                Asset_Value__c = asRole.asset.Value__c
                        );

                        // If it was client1 or client2 then create the other one
                        if (tempAssetRole.Account__c == client1.account.Id || tempAssetRole.Account__c == client2.account.Id) {

                            // add to upsert
                            upsertAssetRoles.add(tempAssetRole);

                            // add the corresponding account
                            newAssetRole.Account__c = (tempAssetRole.Account__c == client1.account.Id ? client2.account.Id : client1.account.Id);
                            upsertAssetRoles.add(newAssetRole);
                        } else {
                            // if it isn't client1 or 2, then need to delete that role and create 2 new ones
                            deleteAssetRoles.add(tempAssetRole);

                            // create for client 1
                            newAssetRole.Account__c = client1.account.Id;

                            // create for client 2
                            Asset_Role__c newAssetRole2 = new Asset_Role__c(
                                    Asset__c = asRole.asset.Id,
                                    Asset_Type__c = asRole.asset.Type__c,
                                    Asset_Value__c = asRole.asset.Value__c,
                                    Account__c = client2.account.Id
                            );

                            // add both to upsert
                            upsertAssetRoles.add(newAssetRole);
                            upsertAssetRoles.add(newAssetRole2);
                        }
                    } else {
                        tempAssetRole.Account__c = asRole.strOwnerType;
                        upsertAssetRoles.add(tempAssetRole);
                    }
                }
            }
        }

        delete deleteAssetRoles;        //Delete the Redundant Asset Roles
        upsert upsertAssetRoles;        //Upsert the Asset Roles for which ownership changed
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to save captured details in "Needs Analysis" tab
    **/
    public void saveNeedsAnalysis() {
        SavePoint sp = Database.setSavepoint();

        try{
            List<Application_Role__c> appRoles = new List<Application_Role__c>();
            List<Analysis__c> needsAnalysis = new List<Analysis__c>();
            Boolean childrenIncluded = false;
            Id needsRecType = ApexAkina_Constants.NEEDS_RECTYPE;

            // upsert client1.account;

            for(String key : analysis.keySet()){
                if((key == client2Type && joint) || key == client1Type){
                    for(Analysis__c analysisRec : analysis.get(key).values()){
                        if(analysisRec.RecordTypeId == needsRecType){
                            if(analysisRec.Type__c == 'Health Insurance'){

                                FactFindingControllerService.BenefitsRequired benefits = clientBenefits.get(key);
                                List<String> selectedBenefits = new List<String>();
                                if(benefits.option1){
                                    selectedBenefits.add('Hospital');
                                }

                                if(benefits.option2){
                                    selectedBenefits.add('Specialists and tests');
                                }

                                if(benefits.option3){
                                    selectedBenefits.add('Doctors and prescriptions');
                                }

                                if(benefits.option4){
                                    selectedBenefits.add('Optical and dental');
                                }

                                if(benefits.option5){
                                    selectedBenefits.add('Childrens Cover');
                                }
                                analysisRec.Benefits_Required__c = String.join(selectedBenefits, ';');

                                if(analysisRec.Children_Included__c){
                                    childrenIncluded = true;
                                }
                            }

                            if(key == client2Type){
                                analysisRec.Account__c = client2.account.Id;
                            }

                            analysisRec.Fact_Find__c = factFind.Id;
                            needsAnalysis.add(analysisRec);
                        }
                    }
                }
            }

            if(childrenIncluded){

                for(FactFindingControllerService.FamilyMemberWrapper fmWrapper : familyMemberWrappers) {

                    if(fmWrapper.includeInAnalysis) {

                        // Each Child Included must have an associated application role
                        Application_Role__c applctnRole = new Application_Role__c(Opportunity__c = opp.Id, Role__c = ApexAkina_Constants.BENEFICIARY, Account__c = fmWrapper.account.Id, Fact_Find__c = factFind.Id);
                        if (applicationRoles.containsKey(fmWrapper.account.Id)) {
                            applctnRole.Id = applicationRoles.get(fmWrapper.account.Id).Id;
                        }
                        appRoles.add(applctnRole);
                        System.debug('!!!!!!!!!' + applctnRole);
                        applicationRoles.put(fmWrapper.account.Id, applctnRole);
                    }
                }


                if(!appRoles.isEmpty() ){
                    upsert appRoles;
                }
            }

            if(!needsAnalysis.isEmpty()){
                upsert needsAnalysis;
            }

           /* ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Needs Analysis details were saved.'
            ));*/
            saveClientDetails();

        } catch (Exception e){

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage()) // + ' ' + // Only uncomment for debugging purposes
                    // String.escapeSingleQuotes(e.getStackTraceString())
            ));
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));

            Database.rollback(sp);

        }
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to save captured details in "Investor Profile" tab
    **/
    public void saveRiskAnalysis() {
        SavePoint sp = Database.setSavepoint();

        try{
            List<Analysis__c> riskAnalysis = new List<Analysis__c>();
            List<Goal__c> invGoals = new List<Goal__c>();
            List<Analysis_Survey__c> analysisSurveys = new List<Analysis_Survey__c>();
            Map<String, Client_Asset__c> disposableAndGiftAssets = new Map<String, Client_Asset__c>();
            Id investmentRecType = ApexAkina_Constants.INVESTMENT_RECTYPE;

            //Assets
            for(FactFindingControllerService.AssetRoleWrapper assetRole : assetRoleWrappers){

                if(assetRole.asset.Disposable__c){
                    if(analysis.containsKey(assetRole.strOwnerType)){
                        analysis.get(assetRole.strOwnerType).get('Risk Analysis').Dispose_any_Assets__c = true;
                    } else if (assetRole.strOwnerType == ApexAkina_Constants.JOINT){
                        analysis.get(client1Type).get('Risk Analysis').Dispose_any_Assets__c = true;
                        analysis.get(client2Type).get('Risk Analysis').Dispose_any_Assets__c = true;
                    }
                }

                if(assetRole.asset.Gift_Asset__c){
                    if(analysis.containsKey(assetRole.strOwnerType)){
                        analysis.get(assetRole.strOwnerType).get('Risk Analysis').Gift_Assets__c = true;
                    } else if (assetRole.strOwnerType == ApexAkina_Constants.JOINT){
                        analysis.get(client1Type).get('Risk Analysis').Gift_Assets__c = true;
                        analysis.get(client2Type).get('Risk Analysis').Gift_Assets__c = true;
                    }
                }

                if(String.isNotBlank(assetRole.strOwnerType)){
                    disposableAndGiftAssets.put(assetRole.asset.Id, assetRole.asset);
                }
            }

            if(!disposableAndGiftAssets.isEmpty()){
                upsert disposableAndGiftAssets.values();
            }

            for(String key : analysis.keySet()){
                if((key == client2Type && joint) || key == client1Type){
                    for(Analysis__c analysisRec : analysis.get(key).values()){
                        if(analysisRec.RecordTypeId == investmentRecType){
                            if(key == client2Type){
                                analysisRec.Account__c = client2.account.Id;
                            }

                            analysisRec.Fact_Find__c = factFind.Id;
                            riskAnalysis.add(analysisRec);
                        }
                    }
                }
            }

            if(!riskAnalysis.isEmpty()){
                upsert riskAnalysis;
            }

            //Goals
            for (FactFindingControllerService.GoalWrapper goalWrapper : mapInvestmentGoals.get('Investment Specific Goals').goals) {
                if (String.isNotBlank(goalWrapper.goal.Term__c) || goalWrapper.goal.Comments__c != null || goalWrapper.goal.Amount__c != null || goalWrapper.stringDate != '') {
                    goalWrapper.goal.Fact_Find__c = factFind.Id;
                    String dateReq = FactFindingControllerService.formatStringToDate(goalWrapper.stringDate);
                    if(String.isNotBlank(dateReq)){
                        goalWrapper.goal.Date_Required__c = Date.valueOf(dateReq);
                    }
                    invGoals.add(goalWrapper.goal);
                }
            }

            if(!invGoals.isEmpty()){
                upsert invGoals;
            }

            //Analysis Survey
            for(String key : investmentRiskQ.keySet()){
                FactFindingControllerService.QuestionnaireAnswers answer = investmentRiskQ.get(key);
                Questionnaire__mdt question = questionnaire.get(key);
                Question_Answer__mdt qAns = new Question_Answer__mdt();
                qAns = answer.option1 ? question.Question_Answers__r.get(0) : qAns;
                qAns = answer.option2 ? question.Question_Answers__r.get(1) : qAns;
                qAns = answer.option3 ? question.Question_Answers__r.get(2) : qAns;
                qAns = answer.option4 ? question.Question_Answers__r.get(3) : qAns;
                qAns = answer.option5 ? question.Question_Answers__r.get(4) : qAns;


                answer.analysisSurvey.Name = key;
                answer.analysisSurvey.Analysis__c = analysis.get(client1Type).get('Risk Analysis').Id;
                answer.analysisSurvey.Answer__c = qAns.Answer__c;
                answer.analysisSurvey.Answer_Value__c = qAns.Answer_Value__c;
                answer.analysisSurvey.Question__c = question.Question__c;
                answer.analysisSurvey.Question_order__c = question.Order__c;
                analysisSurveys.add(answer.analysisSurvey);
            }

            if(!analysisSurveys.isEmpty()){
                upsert analysisSurveys;
            }
            
           
            //we only update the fact find if the user made changes from the page
            if( hasUpdateFactFindTaxes){
                if(!isRequiredCountryTaxes){
                    factFind.Tax_Resident_Country_Other_Than_NZ__c ='No';
                    factFind.Tax_Resident_Country_Name__c='';
                    factFind.Tax_Resident_Number__c ='';
                }
               
            	upsert factFind;
                
           	}     

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Investor Profile details were saved.'
            ));

        } catch (Exception e){
        
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage()) // + ' ' + // Only uncomment for debugging purposes
                    // String.escapeSingleQuotes(e.getStackTraceString())
            ));
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));

            Database.rollback(sp);
        }
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to save new appointment
    **/
    public void saveAppointment() {
        SavePoint sp = Database.setSavepoint();

        try{
            String startDate = FactFindingControllerService.formatStringToDate(stringDates[10]);
            String endDate = FactFindingControllerService.formatStringToDate(stringDates[11]);
            nextAppointment.StartDateTime = String.isNotBlank(startDate) ? DateTime.newInstance(Date.valueOf(startDate), Time.newInstance(Integer.valueOf(eventTime[0].split(':').get(0)), Integer.valueOf(eventTime[0].split(':').get(1)), 0, 0)) : null;
            nextAppointment.EndDateTime = String.isNotBlank(endDate) ? DateTime.newInstance(Date.valueOf(endDate), Time.newInstance(Integer.valueOf(eventTime[1].split(':').get(0)), Integer.valueOf(eventTime[1].split(':').get(1)), 0, 0)) : null;
            upsert nextAppointment;

            initializeNextAppointment();

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Event was created.'
            ));

        } catch(Exception e){

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage()) // + ' ' + // Only uncomment for debugging purposes
                    // String.escapeSingleQuotes(e.getStackTraceString())
            ));
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));

            Database.rollback(sp);
        }

    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to save next step notes
    **/
    public void addNotes() {
        SavePoint sp = Database.setSavepoint();

        try{
            if(String.isNotBlank(nextStepsNotes.Body)){
                ContentNote cn = new ContentNote(Title = 'Next Steps Notes', Content = Blob.valueOf('<p>' + String.valueOf(nextStepsNotes.Body.escapeHtml4()).replaceAll('\n','</p><p>') + '</p>'));
                insert cn;

                insert new List<ContentDocumentLink>{new ContentDocumentLink(ContentDocumentId = cn.Id, LinkedEntityId = factFind.Id, Visibility = 'AllUsers', ShareType = 'I'), new ContentDocumentLink(ContentDocumentId = cn.Id, LinkedEntityId = opp.Id, Visibility = 'AllUsers', ShareType = 'I')};
            }

            nextStepsNotes = new Note();

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Next Steps Notes was saved.'
            ));

        } catch(Exception e){

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage()) // + ' ' + // Only uncomment for debugging purposes
                    // String.escapeSingleQuotes(e.getStackTraceString())
            ));
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));

            Database.rollback(sp);
        }

    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to save Family member and relationships
    **/
    public void saveFamilyMember () {
        SavePoint sp = Database.setSavepoint();
        try {
            if (familyMemberToAddEdit.stringDate != null) {
                // Format the date before saving the record
                String dob = FactFindingControllerService.formatStringToDate(familyMemberToAddEdit.stringDate);

                if (String.isNotBlank(dob)) {
                    familyMemberToAddEdit.account.PersonBirthdate = Date.valueOf(dob);
                }
            }

            if (String.isNotBlank(familyMemberToAddEdit.selectedAccountId)) {
                familyMemberToAddEdit.account.Id = familyMemberToAddEdit.selectedAccountId;
            }

            // set the gender
            if (familyMemberToAddEdit.relationship.Relationship_Type__c == 'Son') {
                familyMemberToAddEdit.account.Gender__pc = 'Male';
            } else {
                if (familyMemberToAddEdit.relationship.Relationship_Type__c == 'Daughter') {
                    familyMemberToAddEdit.account.Gender__pc = 'Female';
                }
            }

            // upsert the account first
            upsert familyMemberToAddEdit.account;

            /*// Each family member must have an associated application role
            Application_Role__c appRole = new Application_Role__c(Opportunity__c = opp.Id, Role__c = ApexAkina_Constants.BENEFICIARY, Account__c = familyMemberToAddEdit.account.Id, Fact_Find__c = factFind.Id);

            if(applicationRoles.containsKey(familyMemberToAddEdit.account.Id)){
                appRole.Id = applicationRoles.get(familyMemberToAddEdit.account.Id).Id;
            }
            upsert appRole;
            applicationRoles.put(familyMemberToAddEdit.account.Id, appRole);
*/

            List<Relationship__c> relationshipToSave = new List<Relationship__c>();
            // Add the relationship with the main account
            if (familyMemberToAddEdit.relationship.Id == null) {
                familyMemberToAddEdit.relationship.Fact_Find__c = factFind.Id;
                familyMemberToAddEdit.relationship.Related_Account__c = familyMemberToAddEdit.account.Id;
                familyMemberToAddEdit.relationship.Account__c = client1.account.Id;
            }

            // always add the main relationship to save/update
            relationshipToSave.add(familyMemberToAddEdit.relationship);

            // save the records
            upsert relationshipToSave;

            // get again the family members
            getFamilyMembers();

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Saved successfully!'
            ));
        }
        catch (Exception e){

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage()) // + ' ' + // Only uncomment for debugging purposes
                    // String.escapeSingleQuotes(e.getStackTraceString())
            ));
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));

            Database.rollback(sp);
        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to save other entities and relationships
    **/
    public void saveOtherEntities () {
        SavePoint sp = Database.setSavepoint();
        try {
            // insert the account first, if it's new, if not update in case they change name or type
            if (String.isBlank(otherEntityToAddEdit.selectedLegalEntityId)) {
                // check if it exists an account with same name and type
                List<Account> account = FactFindingControllerSelector.getAccountByNameAndType(otherEntityToAddEdit.account.Name, otherEntityToAddEdit.account.Type);

                if (account.size() > 0) {
                    otherEntityToAddEdit.account = account[0];
                }
                else {
                    insert otherEntityToAddEdit.account;
                }
            } else {
                otherEntityToAddEdit.account.Id = otherEntityToAddEdit.selectedLegalEntityId;
                update otherEntityToAddEdit.account;
            }

            List<Relationship__c> relationshipToSave = new List<Relationship__c>();

            // traverse the roles and upsert the records
            for (FactFindingControllerService.OtherEntitiesRolesWrapper oeRole : otherEntityToAddEdit.roles) {
                // if it's new add the related account
                if (oeRole.relationship.Id == null) {
                    oeRole.relationship.Related_Account__c = otherEntityToAddEdit.account.Id;
                }

                // if it's joint then add one role with the partner and modify the Joint to the owner client
                if (oeRole.strOwnerType == ApexAkina_Constants.JOINT) {
                    oeRole.relationship.Account__c = client1.account.Id;

                    // check that relationship (external_Id__c) does not exists before adding to the saving
                    if (!mapUniqueRelationships.containsKey(client2.account.Id + '' + otherEntityToAddEdit.account.Id + '' + oeRole.relationship.Relationship_Type__c)) {
                        relationshipToSave.add(new Relationship__c(Related_Account__c = otherEntityToAddEdit.account.Id, Account__c = client2.account.Id, Relationship_Type__c = oeRole.relationship.Relationship_Type__c, Description__c = oeRole.relationship.Description__c));
                        mapUniqueRelationships.put(client2.account.Id + '' + otherEntityToAddEdit.account.Id + '' + oeRole.relationship.Relationship_Type__c, oeRole.relationship);
                    }
                } else {
                    oeRole.relationship.Account__c = oeRole.strOwnerType;
                }

                // check that relationship (external_Id__c) does not exists before saving
                if (!mapUniqueRelationships.containsKey(oeRole.relationship.Account__c + '' + oeRole.relationship.Related_Account__c + '' + oeRole.relationship.Relationship_Type__c)) {
                    relationshipToSave.add(oeRole.relationship);
                    mapUniqueRelationships.put(oeRole.relationship.Account__c + '' + oeRole.relationship.Related_Account__c + '' + oeRole.relationship.Relationship_Type__c, oeRole.relationship);
                }
            }

            if (!relationshipToSave.isEmpty()) {
                upsert relationshipToSave;
            }

            // get again the other entities
            getOtherEntities();

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Saved successfully!'
            ));
        }
        catch (Exception e){

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage()) // + ' ' + // Only uncomment for debugging purposes
                    // String.escapeSingleQuotes(e.getStackTraceString())
            ));
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));

            Database.rollback(sp);
        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to save assets data
    **/
    public void saveAssetData () {
        SavePoint sp = Database.setSavepoint();
        try {
            Boolean hasMortgage = ApexPages.currentPage().getParameters().get( 'createLiability' ) == 'true';

            // insert or update asset and assetRole
            saveAssetsAndRoles(new List<FactFindingControllerService.AssetRoleWrapper>{assetToAddEdit});

            if (hasMortgage) {
                FactFindingControllerService.LiabilityRoleWrapper newLiability = new FactFindingControllerService.LiabilityRoleWrapper();

                newLiability.liability.Type__c = mapAssetTypeLiabilityType.get(assetToAddEdit.asset.Type__c);
                newLiability.liability.Asset__c = assetToAddEdit.asset.Id;
                newLiability.assetSelectedDisplayValue = assetToAddEdit.asset.Type__c +
                        (assetToAddEdit.asset.Street__c != null ? ' (' +
                                (assetToAddEdit.asset.Street__c != null ? assetToAddEdit.asset.Street__c : '') +
                        ')' : '');

                liabilityRoleWrappers.add(newLiability);
            }

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Saved successfully!'
            ));
        }
        catch (Exception e){

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage()) // + ' ' + // Only uncomment for debugging purposes
                    // String.escapeSingleQuotes(e.getStackTraceString())
            ));
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));

            Database.rollback(sp);
        }
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Method to delete a specific record
    **/
    public void deleteRecord() {
        SavePoint sp = Database.setSavepoint();
        try {
            switch on typeToDelete {
                when 'Relationship' {
                    Integer indexToDelete;
                    List<FactFindingControllerService.FamilyMemberWrapper> theFamilyMembers = new List<FactFindingControllerService.FamilyMemberWrapper>(familyMemberWrappers);

                    for (FactFindingControllerService.FamilyMemberWrapper familyMember : theFamilyMembers) {
                        if (familyMember.account.Id == recordIdToDelete) {
                            indexToDelete = theFamilyMembers.indexOf(familyMember);
                        }
                    }

                    // remove the index from the list
                    if (indexToDelete != null) {
                        theFamilyMembers.remove(indexToDelete);
                    }

                    if (!String.isBlank(recordIdToDelete)) {
                        // delete application role
                        delete FactFindingControllerSelector.getApplicationRolesForFamily(opp.Id, factFind.Id, recordIdToDelete);
                        // delete relationship
                        delete FactFindingControllerSelector.getRelationshipsByAccountIdAndFactFindId(recordIdToDelete, factFind.Id);

                        // get again the family members for refreshing the page
                        getFamilyMembers();
                    }
                }
                when 'Employment' {
                    // delete from the map
                    Map<String, List<FactFindingControllerService.EmploymentWrapper>> newMap = new Map<String, List<FactFindingControllerService.EmploymentWrapper>>{client1Type => new List<FactFindingControllerService.EmploymentWrapper>(), client2Type => new List<FactFindingControllerService.EmploymentWrapper>()};
                    for (String key : employment.keySet()) {
                        for (FactFindingControllerService.EmploymentWrapper emp : employment.get(key)) {
                            // if it's not the one that we are deleting
                            if (emp.employment.Id != recordIdToDelete && emp.tempId != tempIdToDelete) {
                                // add to the new map
                                newMap.get(key).add(emp);
                            }
                        }
                    }
                    // replace the map
                    employment = newMap;

                    // delete the record
                    if (!String.isBlank(recordIdToDelete)) {
                        delete new Employment_Detail__c(Id = recordIdToDelete);
                    }
                }
                when 'Asset' {
                    Integer indexToDelete;
                    // delete from list
                    for (FactFindingControllerService.AssetRoleWrapper asRole : assetRoleWrappers) {
                        if ((asRole.asset.Id == recordIdToDelete) || (asRole.tempId == tempIdToDelete)) {
                            indexToDelete = assetRoleWrappers.indexOf(asRole);
                        }
                    }

                    // remove the index from the list
                    if (indexToDelete != null) {
                        assetRoleWrappers.remove(indexToDelete);
                    }

                    if (!String.isBlank(recordIdToDelete)) {
                        // delete the record, this will delete the roles as well
                        delete new Client_Asset__c(Id = recordIdToDelete);
                    }
                }
                when 'Liability' {
                    Integer indexToDelete;
                    // delete from list
                    for (FactFindingControllerService.LiabilityRoleWrapper liabRole : liabilityRoleWrappers) {
                        if ((liabRole.liability.Id == recordIdToDelete) || (liabRole.tempId == tempIdToDelete)) {
                            indexToDelete = liabilityRoleWrappers.indexOf(liabRole);
                        }
                    }

                    // remove the index from the list
                    if (indexToDelete != null) {
                        liabilityRoleWrappers.remove(indexToDelete);
                    }

                    // delete the record, this will delete the roles as well
                    if (!String.isBlank(recordIdToDelete)) {
                        delete new Liability__c(Id = recordIdToDelete);
                    }
                }
                when 'Contingent Liability' {
                    Integer indexToDelete;
                    // delete from list
                    for (FactFindingControllerService.LiabilityRoleWrapper liabRole : contingentLiabilityWrappers) {
                        if ((liabRole.liability.Id == recordIdToDelete) || (liabRole.tempId == tempIdToDelete)) {
                            indexToDelete = contingentLiabilityWrappers.indexOf(liabRole);
                        }
                    }
                    // remove the index from the list
                    if (indexToDelete != null) {
                        contingentLiabilityWrappers.remove(indexToDelete);
                    }

                    // delete the record, this will delete the roles as well
                    if (!String.isBlank(recordIdToDelete)) {
                        delete new Liability__c(Id = recordIdToDelete);
                    }
                }
                when 'Income/Expense' {
                    // delete from the map
                    Map<String, List<FactFindingControllerService.IncomeExpenseWrapper>> newMap = new Map<String, List<FactFindingControllerService.IncomeExpenseWrapper>>{'Client 1 - Income' => new List<FactFindingControllerService.IncomeExpenseWrapper>(), 'Client 1 - Expenses' => new List<FactFindingControllerService.IncomeExpenseWrapper>(), client2Type => new List<FactFindingControllerService.IncomeExpenseWrapper>()};
                    for (String key : incomeAndExpenses.keySet()) {
                        for (FactFindingControllerService.IncomeExpenseWrapper incExp : incomeAndExpenses.get(key)) {
                            // if it's not the one that we are deleting
                            if (incExp.incomeExpense.Id != recordIdToDelete && incExp.tempId != tempIdToDelete) {
                                // add to the new map
                                newMap.get(key).add(incExp);
                            }
                        }
                    }
                    // replace the map
                    incomeAndExpenses = newMap;

                    // delete the record
                    if (!String.isBlank(recordIdToDelete)) {
                        delete new Income_and_Expense__c(Id = recordIdToDelete);
                    }
                }
                when 'Other Entity' {
                    Integer indexToDelete;
                    List<Relationship__c> rolesToDelete = new List<Relationship__c>();

                    for (FactFindingControllerService.OtherEntitiesWrapper oeWrapper : otherEntitiesWrappers) {
                        if (oeWrapper.tempId == tempIdToDelete) {
                            indexToDelete = otherEntitiesWrappers.indexOf(oeWrapper);
                            for (FactFindingControllerService.OtherEntitiesRolesWrapper oeRole: oeWrapper.roles) {
                                rolesToDelete.add(oeRole.relationship);
                            }
                        }
                    }

                    // remove the index from the list
                    if (indexToDelete != null) {
                        otherEntitiesWrappers.remove(indexToDelete);
                    }

                    // remove from database
                    if (!rolesToDelete.isEmpty()) {
                        // delete the record
                        delete rolesToDelete;
                    }

                    // get again the entities for refreshing the page
                    getOtherEntities();
                }
                when 'Entity Role' {
                    Integer indexToDelete;

                    // delete from list of the popup
                    for (FactFindingControllerService.OtherEntitiesRolesWrapper oeRole : otherEntityToAddEdit.roles) {
                        if ((oeRole.relationship.Id == recordIdToDelete) || (oeRole.tempId == tempIdToDelete)) {
                            indexToDelete = otherEntityToAddEdit.roles.indexOf(oeRole);
                        }
                    }

                    // remove the index from the list
                    if (indexToDelete != null) {
                        otherEntityToAddEdit.roles.remove(indexToDelete);
                    }

                    if (!String.isBlank(recordIdToDelete)) {
                        // delete the record
                        delete new Relationship__c(Id = recordIdToDelete);

                        // get again the entities for refreshing the page
                        getOtherEntities();
                    }
                }
                when 'Goal' {
                    FactFindingControllerService.GoalsListWrapper goalsListWrapper;
                    Map<String, FactFindingControllerService.GoalsListWrapper> newMap = new Map<String, FactFindingControllerService.GoalsListWrapper>();
                    for (String key : mapPersonalGoals.keySet()) {
                        if (!newMap.containsKey(key)) {
                            goalsListWrapper = new FactFindingControllerService.GoalsListWrapper();
                            newMap.put(key, goalsListWrapper);
                        }

                        for (FactFindingControllerService.GoalWrapper goalWrapper : mapPersonalGoals.get(key).goals) {
                            // if it's not the one that we are deleting
                            if (goalWrapper.goal.Id != recordIdToDelete && goalWrapper.tempId != tempIdToDelete) {
                                goalsListWrapper.goals.add(goalWrapper);
                            }
                        }

                        if (goalsListWrapper.getListSize() > 0) {
                            // add to the new map
                            newMap.put(key, goalsListWrapper);
                        }
                    }
                    // replace the map
                    mapPersonalGoals = newMap;

                    if (!String.isBlank(recordIdToDelete)) {
                        // delete the record
                        delete new Goal__c(Id = recordIdToDelete);
                    }
                }
                when 'Non Apex Cover' {
                    Integer indexToDelete;
                    // delete from list
                    for (FactFindingControllerService.NonApexCoverWrapper nanWrapper : nonApexCoverWrappers) {
                        if ((nanWrapper.nonApexCover.Id == recordIdToDelete) || (nanWrapper.tempId == tempIdToDelete)) {
                            indexToDelete = nonApexCoverWrappers.indexOf(nanWrapper);
                        }
                    }

                    // remove the index from the list
                    if (indexToDelete != null) {
                        nonApexCoverWrappers.remove(indexToDelete);
                    }

                    // delete the record
                    if (!String.isBlank(recordIdToDelete)) {
                        delete new Non_Apex_Cover__c(Id = recordIdToDelete);
                    }
                }
                when else {
                    ApexPages.addMessage(new ApexPages.Message(
                            ApexPages.Severity.WARNING,
                            'This function is not implemented yet!'
                    ));
                }
            }

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    'Deleted successfully!'
            ));
        }
        catch (Exception e){

            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    String.escapeSingleQuotes(e.getMessage()) // + ' ' + // Only uncomment for debugging purposes
                    // String.escapeSingleQuotes(e.getStackTraceString())
            ));
            System.debug('Error: ' + String.escapeSingleQuotes(e.getStackTraceString()));

            Database.rollback(sp);
        }
    }



    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Get the Templates
    **/
    public String congaTemplates {
        get {
            // add the fact find summary and scope of engagement
            String result =
                    '[Fact+Find+Summary+' +  this.oppNameRemoved + '+FF_Completed]' + opp.Fact_Find_Template_Formula__c + ',' +
                    '[Needs+Analysis+' +  this.oppNameRemoved + '+NA_Completed]' + apexAdminSettings.Conga_Needs_Analysis__c + ',' +
                    '[Scope+of+Engagement+' +  this.oppNameRemoved + '+SOE_Completed]' + apexAdminSettings.Conga_Scope_of_Engagement__c;

            // if we have to include the limited advice template
            if (String.isNotBlank(opp.Limited_Advice_Required_Formula__c)) {
                    result +=  ',[Limited+Advice+' +  this.oppNameRemoved + '+LA_Completed]' + opp.Limited_Advice_Required_Formula__c;
            }

            // add the letter of authority
            if (String.isNotBlank(opp.Conga_Letter_of_Authority_Template__c)) {
                result += ',[Letter+Authority+' +  this.oppNameRemoved + '+LOA_Completed]' + opp.Conga_Letter_of_Authority_Template__c;
            }

            return result;
        }
        set;
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Get the Queries
    **/
    public String congaQueries {
        get {

            FactFindingCongaQueriesService cq = new FactFindingCongaQueriesService();

            return  '[othentities]'+cq.othentities+'?pv0=\'' + client1.account.Id + '\'' + (client2.account.Id  != null ? '|\'' + client2.account.Id + '\'' : '') + ',' +
                    '[oppapproles]'+cq.oppapproles+'?pv0=' + opp.Id + ',' +
                    '[dependents]'+cq.dependents+'?pv0=\'' + String.join(new List<Id>(familyMemberIds), '\'|\'') + '\',' +
                    '[otherfamily]'+cq.otherfamily+'?pv0=\'' + String.join(new List<Id>(familyMemberIds), '\'|\'') + '\',' +
                    '[owners]'+cq.owners+'?pv0=' + opp.Fact_Find__c + ',' +
                    '[employment]'+cq.employment+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'Account__c =\'' + client1.account.Id + '\'' + 'OR Account__c =\'' + client2.account.Id + '\'' : 'Account__c =\'' + client1.account.Id + '\'') +',' +
                    '[incexp]'+cq.incexp+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'RecordTypeId = \'0127F000000Z5BU\' AND (Primary_Owner__c =\'' + client1.account.Id + '\'' + 'OR Primary_Owner__c = \'' + client2.account.Id + '\')' : 'RecordTypeId = \'0127F000000Z5BU\' AND Primary_Owner__c =\'' + client1.account.Id + '\'') +',' +
                    '[assets]'+cq.assets+'?pv0=\'' + client1.account.Id + '\'' + (client2.account.Id != null ? '|\'' + client2.account.Id + '\'' : '') + '|\'' + String.join(new List<Id>(legalEntityIdsForAssetsLiabilities), '\'|\'') + '\',' +
                    '[nonapexserviced]'+cq.nonapexserviced+'?pv0=\'' + client1.account.Id + '\'' + (client2.account.Id != null ? '|\'' + client2.account.Id + '\'' : '') + '|\'' + String.join(new List<Id>(legalEntityIdsForAssetsLiabilities), '\'|\'') + '\',' +
                    '[liability]'+cq.liability+'?pv0=\'' + opp.AccountId + '\'' + (opp.Joint_Owner__c != null ? '|\'' + opp.Joint_Owner__c + '\'' : '') + '|\'' + String.join(new List<Id>(legalEntityIdsForAssetsLiabilities), '\'|\'') + '\',' +
                    '[expenses]'+cq.expenses+'?pv0=' + client1.account.Id + ',' +
                    '[analysismed]'+cq.analysismed+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'Type__c = \'Health Insurance\' AND (Account__c =\'' + client1.account.Id + '\'' + 'OR Account__c = \'' + client2.account.Id + '\')' : 'Type__c = \'Health Insurance\' AND Account__c =\'' + client1.account.Id + '\'') +',' +
                    '[estate]'+cq.estate+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'Primary_Owner__c =\'' + client1.account.Id + '\'' + 'OR Primary_Owner__c =\'' + client2.account.Id + '\'' : 'Primary_Owner__c =\'' + client1.account.Id + '\'') +',' +
                    '[goals]'+cq.goals+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'RecordTypeId = \'0127F000000Z5BR\' AND (Account__c =\'' + client1.account.Id + '\'' + 'OR Account__c = \'' + client2.account.Id + '\')' : 'RecordTypeId = \'0127F000000Z5BR\' AND Account__c =\'' + client1.account.Id + '\'') +',' +
                    '[invstgoals]'+cq.invstgoals+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'RecordTypeId = \'0127F000000Z5BS\' AND (Account__c =\'' + client1.account.Id + '\'' + 'OR Account__c = \'' + client2.account.Id + '\')' : 'RecordTypeId = \'0127F000000Z5BS\' AND Account__c =\'' + client1.account.Id + '\'') +',' +
                    '[contingent]'+cq.contingent+'?pv0=' + client1.account.Id + ',' +
                    '[analysisbills]'+cq.analysisbills+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'Type__c = \'Income and Mortgage Protection\' AND (Account__c =\'' + client1.account.Id + '\'' + 'OR Account__c = \'' + client2.account.Id + '\')' : 'Type__c = \'Income and Mortgage Protection\' AND Account__c =\'' + client1.account.Id + '\'') +',' +
                    '[analysistrauma]'+cq.analysistrauma+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'Type__c = \'Trauma\' AND (Account__c =\'' + client1.account.Id + '\'' + 'OR Account__c = \'' + client2.account.Id + '\')' : 'Type__c = \'Trauma\' AND Account__c =\'' + client1.account.Id + '\'') +',' +
                    '[analysisTPD]'+cq.analysisTPD+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'Type__c = \'TPD\' AND (Account__c =\'' + client1.account.Id + '\'' + 'OR Account__c = \'' + client2.account.Id + '\')' : 'Type__c = \'TPD\' AND Account__c =\'' + client1.account.Id + '\'') +',' +
                    '[analysisLife]'+cq.analysisLife+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'Type__c = \'Life Cover\' AND (Account__c =\'' + client1.account.Id + '\'' + 'OR Account__c = \'' + client2.account.Id + '\')' : 'Type__c = \'Life Cover\' AND Account__c =\'' + client1.account.Id + '\'') +',' +
                    '[disposableasset]'+cq.disposableasset+'?pv0=\'' + opp.AccountId + '\'' + (opp.Joint_Owner__c != null ? '|\'' + opp.Joint_Owner__c + '\'' : '') + '|\'' + String.join(new List<Id>(legalEntityIdsForAssetsLiabilities), '\'|\'') + '\',' +
                    '[analysisInvst]'+cq.analysisInvst+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'RecordTypeId  = \'0127F000000Z5BP\' AND (Account__c =\'' + client1.account.Id + '\'' + 'OR Account__c = \'' + client2.account.Id + '\')' : 'RecordTypeId  = \'0127F000000Z5BP\' AND Account__c =\'' + client1.account.Id + '\'') +',' +
                    '[giftableasset]'+cq.giftableasset+'?pv0=\'' + opp.AccountId + '\'' + (opp.Joint_Owner__c != null ? '|\'' + opp.Joint_Owner__c + '\'' : '') + '|\'' + String.join(new List<Id>(legalEntityIdsForAssetsLiabilities), '\'|\'') + '\',' +
                    '[analysissurvey]'+cq.analysissurvey+'?pv0=' + client1.account.Id + ',' +
                    '[referral]'+cq.referral+'?pv0=' + opp.Id + ',' +
                    '[acctcontact]'+cq.acctcontact+'?pv0=' + client1.account.Id + ',' +
                    '[understanding]'+cq.understanding+'?pv0=' + client1.account.Id + ',' +
                    '[factfind]'+cq.factfind+'?pv0=' + opp.Id + ',' +
                    '[medissues]'+cq.medissues+'?pv0=' + (string.isNotBlank(client2.account.Id) ? 'Type__c = \'Health Insurance\' AND (Account__c =\'' + client1.account.Id + '\'' + 'OR Account__c = \'' + client2.account.Id + '\')' : 'Type__c = \'Health Insurance\' AND Account__c =\'' + client1.account.Id + '\'') +',' +
                    '[sig]'+cq.sig+'?pv0=' + opp.Fact_Find__c;
        }
        set;
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Get the Attributes
    **/
    public String congaAttributes {
        get {
            return 'DefaultPDF=1&SelectTemplates=1&DS7=0&DS7Preview=1&UF0=1&MFTS0=Delete_Signature_Trigger__c&MFTSValue0=TRUE&MFTS1=Compliance_Documents_Conga_Status__c&MFTSValue1=Saved&MFTS2=All_Docs_Sent__c&MFTSValue2=TRUE&SC0=1&SF1=1&SC1=SalesforceFile&&TemplateGroup=SendAll&APDF=0';
        }
        set;
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Get the Templates for the Remote conga document
    **/
    public String congaRemoteTemplates {
        get {
            // add the fact find summary and scope of engagement
            String result =
            '[Fact+Find+Summary+'+  this.oppNameRemoved + '+FF]' + opp.Fact_Find_Remote_Template_Formula__c + ',' + '[Needs+Analysis+' +  this.oppNameRemoved + '+NA]' + apexAdminSettings.Conga_Needs_Analysis__c + ',' + '[Scope+of+Engagement+' +  this.oppNameRemoved + '+SOE]' + apexAdminSettings.Conga_R_Scope_of_Engagement__c;

            // if we have to include the limited advice template
            if (String.isNotBlank(opp.Remote_Limited_Advice_Required_Formula__c)) {
                result += ',[Limited+Advice+' +  this.oppNameRemoved + '+LA]' + opp.Remote_Limited_Advice_Required_Formula__c;
            }

            // add the letter of authority
            if (String.isNotBlank(opp.Conga_Remote_Letter_of_Authority_Templat__c)) {
                result += ',[Letter+Authority+'+  this.oppNameRemoved + '+LOA]' + opp.Conga_Remote_Letter_of_Authority_Templat__c;
            }

            return result;
        }
        set;
    }

    /**
    *   @author Pablo Martinez (pablomartinez@deloitte.co.nz)
    *   @description Get the Attributes for the Remote conga document
    **/
    public String congaRemoteAttributes {
        get {
            return 'DefaultPDF=1&SelectTemplates=1&DocuSignVisible=1&DocuSignRelatedAccountId=' + opp.Person_Account_ID__c +
                    '&DocuSignR1Id=' + opp.Primary_Owner_Contact_ID_Formula__c +
                    '&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1' +
                    '&DocuSignR2Id=' + (opp.Joint_Owner_Person_Account_ID__c != null ? opp.Joint_Owner_Person_Account_ID__c : '') +
                    '&DocuSignR2Type=Signer&DocuSignR2Role=Signer+2&DocuSignR2RoutingOrder=2&DocuSignEmailSubject=Compliance Documents To Sign&DocuSignExpireIn=120&DS7=0&DS7Preview=1&UF0=1' +
                    '&MFTS1=Compliance_Documents_Conga_Status__c&MFTS0=Delete_Signature_Trigger__c&MFTSValue0=TRUE&MFTSValue1=Sent&SC0=1&SF1=1&SC1=SalesforceFile&TemplateGroup=Remote&APDF=0&DV0=Remote';
        }
        set;
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to remove client 1 existing signature
    **/
    public void removeClient1Signature(){
        removeSignature(opp.Client_1_Signature__c, client1Type);
        getUpdatedSignatures();
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to remove client 2 existing signature
    **/
    public void removeClient2Signature(){
        removeSignature(opp.Client_2_Signature__c, client2Type);
        getUpdatedSignatures();
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to remove captured signature
    **/
    public void removeSignature(String signatureId, String client) {
        delete FactFindingControllerSelector.getContentDocumentsByContentVersionId(signatureId);

        if(client.equals(client1Type)) {
            opp.Client_1_Signature__c = null;
        } else {
            opp.Client_2_Signature__c = null;
        }

        update opp;
    }

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to get updated opportunity and fact find fields to get the signature ids.
    **/
    public void getUpdatedSignatures(){
        opp = FactFindingControllerSelector.getOpportunityById(recordId);

        if(String.isNotBlank(factFind.Id)){
            factFind = FactFindingControllerSelector.getFactFindById(factFind.Id);
        }
    }

    public Map<String, List<String>> getAllPageMessagesMap() {

        Map<String, List<String>> allPageMessagesMap = new Map<String, List<String>>();

        // Iterate over each alert message
        for(ApexPages.Message apexPageMessage : ApexPages.getMessages()) {

            // Get the alert style for the message
            String alertTheme = ApexAkina_Constants.severityToThemeMap.get(apexPageMessage.getSeverity());

            // If the map already contains an error for this style
            if (allPageMessagesMap.containsKey(alertTheme)) {

                // Get the existing list
                List<String> existingErrors = allPageMessagesMap.get(alertTheme);

                // Add the new error
                existingErrors.add(apexPageMessage.getDetail());

                // Put back into the map
                allPageMessagesMap.put(alertTheme, existingErrors);
            } else {
                // Otherwise, it doesn't yet exist
                allPageMessagesMap.put(alertTheme, new List<String>{apexPageMessage.getDetail()});
            }
        }
        return allPageMessagesMap;
    }
    
        /**
    *   @author Alvin Aquino (aaquino@deloitte.com)
    *   @description Method to retrieve Policy Benefit
    *   Changed by Pablo Martinez on 12/05/2021
    *           - Changed the name to be consistent with the others
    *           - Include the policy for childrens
    **/
    public void getApexServicedCover() {
        Map<Id, List<Policy_Benefit__c>> mapPolicyBenefitByPolicyId = new Map<Id, List<Policy_Benefit__c>>();
        apexServicedCoverList = new List<Policy_Benefit__c>();

        // get the other policies from benefits for the policy owners
        for (Policy__c polBenefit : FactFindingControllerSelector.getPolicyWithBenefitsForPolicyOwners(clientIds)) {
            if (!mapPolicyBenefitByPolicyId.containsKey(polBenefit.Id)) {
                mapPolicyBenefitByPolicyId.put(polBenefit.Id, new List<Policy_Benefit__c>());
            }
            mapPolicyBenefitByPolicyId.get(polBenefit.Id).addAll(polBenefit.Benefits__r);
        }

        // get the other policies from where the owners are beneficiaries
        for (Policy__c polBenefit : FactFindingControllerSelector.getPolicyWithOwnersAsBeneficiaries(clientIds)) {
            if (!mapPolicyBenefitByPolicyId.containsKey(polBenefit.Id)) {
                mapPolicyBenefitByPolicyId.put(polBenefit.Id, polBenefit.Benefits__r);
            }
        }

        // for each key on the map, add the list of beneficiary to the list to show
        for (Id key : mapPolicyBenefitByPolicyId.keySet()) {
            apexServicedCoverList.addAll(mapPolicyBenefitByPolicyId.get(key));
        }
    }
    
    /**
    *   @author Alvin Aquino (aaquino@deloitte.com)
    *   @description Method to retrieve Non Apex Policy
    *   Changed by Pablo Martinez on 12/05/2021
    *           - Changed the name to be consistent with the others
    *           - remove the assignment
    **/
    public void getNonApexServicedCover () {
        nonApexCoverWrappers = new List<FactFindingControllerService.NonApexCoverWrapper>();
        for (Non_Apex_Cover__c nan : FactFindingControllerSelector.getNonApexCover(clientIds)) {
            FactFindingControllerService.NonApexCoverWrapper nanWrapper = new FactFindingControllerService.NonApexCoverWrapper();
            nanWrapper.nonApexCover = nan;

            nonApexCoverWrappers.add(nanWrapper);
        }
    }

    /**
    *   @author Alvin Aquino (aaquino@deloitte.com)
    *   @description Policy Account Picklist
    **/
    public List<SelectOption> getWhoListNonApexServicedCover() {
        Map<String, SelectOption> mapClientOptions = new Map<String, SelectOption>();
        mapClientOptions.put('1', new SelectOption('','--None--'));

        // if we have a client1
        if(client1.account.Id != null && client1.account.Name != null){
            mapClientOptions.put(client1.account.Id, new SelectOption(client1.account.Id, client1.account.Name));
        }

        // if we have a client 2 (partner)
        if(client2.account.Id != null && client2.account.Name != null){
            mapClientOptions.put(client2.account.Id, new SelectOption(client2.account.Id, client2.account.Name));
        }

        // get the related children
        if(clientIds != null) {
            for(Relationship__c child : FactFindingControllerSelector.getRelationshipsByAccountIdsAndType(clientIds, new Set<String> { 'Child' })) {
                if (!mapClientOptions.containsKey(child.Related_Account__c)) {
                    mapClientOptions.put(child.Related_Account__c, new SelectOption(child.Related_Account__c, child.Related_Account__r.Name));
                }
            }
        }
        
        return mapClientOptions.values();
    }
    
    /**
    *   @author Alvin Aquino (aaquino@deloitte.com)
    *   @description Open Next Appointment
    **/
    public void openNextAppointment(){
        openNextAppointment = true;
    }
    
    
    /**
     *   @author Ivanna Panchenko (ivanna@beintelligent.nz)
     *   @description Method to re-initialize some variables after change of change the tax resident
     **/
    public void changeTaxResidentCountry(){        
        isRequiredCountryTaxes = 'Yes'.containsIgnoreCase(this.factFind?.Tax_Resident_Country_Other_Than_NZ__c);
        hasUpdateFactFindTaxes = true;
    }

     // Initialize taxesResidentCountry picklist.
     public List<SelectOption> taxesResidentCountry {
        get {
            if(taxesResidentCountry == null){
                taxesResidentCountry = new List<SelectOption>();
                taxesResidentCountry.add(new SelectOption('Yes', 'Yes'));
                taxesResidentCountry.add(new SelectOption('No', 'No'));
            }
            return taxesResidentCountry;
        }
        set;
    }

}