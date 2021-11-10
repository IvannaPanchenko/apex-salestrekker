/**
* @author Pablo Martinez (pablomartinez@cdeloitte.co.nz)
* @date 3/07/2019
* @description
* @Modification Log
*  9/17/2020   Patrick Lorilla  Added client expectation field in the getFactFinds method's query
*  1/03/2021   Patrick Lorilla  Added additional formula fields in the getOpportunityById method's query
**/

public without sharing class FactFindingControllerSelector {
    public static List<Asset_Role__c> getAssetRoles(Set<Id> clientIds) {
        return [
                SELECT Id, Account__c, Asset__c, Asset__r.Id, Asset__r.Name, Asset__r.Type__c, Asset__r.Value__c, Asset__r.Disposable__c, Asset__r.Gift_Asset__c, Account__r.Name, Account__r.Client_Preferred_Name__c,
                        Asset__r.Street__c, Asset__r.Suburb__c, Asset__r.City__c, Asset__r.Country__c, Asset__r.Postal_Code__c, Asset__r.Provider__c, Asset__r.Details__c
                FROM Asset_Role__c
                WHERE Account__c IN :clientIds
                ORDER BY CreatedDate ASC
        ];
    }

    public static List<Liability_Role__c> getLiabilityRoles(Set<Id> clientIds) {
        return [
                SELECT Id, Account__c, Liability__c, Liability__r.Id, Liability__r.Name, Liability__r.Type__c, Liability__r.Current_Balance__c,
                        Liability__r.Asset__c, Liability__r.Asset__r.Type__c, Liability__r.Asset__r.Value__c, Liability__r.Asset__r.Street__c, Liability__r.Asset__r.Suburb__c, Liability__r.Asset__r.City__c,
                        Liability__r.Personal_Guarantees__c, Liability__r.Structure__c, Liability__r.Notes__c, Liability__r.Term_Months__c, Liability__r.Institution__c, Account__r.Name, Account__r.Client_Preferred_Name__c
                FROM Liability_Role__c
                WHERE Account__c IN :clientIds
                ORDER BY CreatedDate ASC
        ];
    }

    public static List<Questionnaire__mdt> getQuestionnaires () {
        return [
                SELECT MasterLabel, DeveloperName, Order__c, Question__c, (SELECT MasterLabel, Answer__c, Answer_Value__c, Sort_Order__c FROM Question_Answers__r ORDER BY MasterLabel ASC)
                FROM Questionnaire__mdt
                ORDER BY Order__c ASC
        ];
    }

    public static Opportunity getOpportunityById (Id oppId) {
        return [
                SELECT Id, Name, AccountId, Joint_Owner__c, Description, Fact_Find__c, Amount, Type, Referee__c, Client_1_Signature__c, Client_2_Signature__c, Owner.Name, OwnerId, Send_Mortgage_Monitoring_Service_Doc__c,
                        Fact_Find_Template_Formula__c, Limited_Advice_Required_Formula__c, Conga_Letter_of_Authority_Template__c,Compliance_Documents_Conga_Status__c, All_Docs_Sent__c,
                        Fact_Find_Remote_Template_Formula__c, Remote_Limited_Advice_Required_Formula__c, Conga_Remote_Letter_of_Authority_Templat__c, Servicing_Adviser__c,
                        Person_Account_ID__c, Joint_Owner_Person_Account_ID__c, Primary_Owner_Contact_ID_Formula__c,Services__c,Risk_Providers__c,Kiwisaver_Providers__c,Benefits__c,Investment_Providers__c,Mortgage_Providers__c,Letter_of_Authority_Scope__c, Show_Risk_Providers__c, Show_Mortgage_Providers__c, Show_Kiwisaver_Providers__c, Show_Benefits__c, Show_Investment_Providers__c
                FROM Opportunity
                WHERE Id = :oppId
        ];
    }

    public static List<Application_Role__c> getApplicationRolesByOpportunityId (Id oppId) {
        return [
                SELECT Id, Account__c, Fact_Find__c, Opportunity__c, Role__c
                FROM Application_Role__c
                WHERE Opportunity__c = :oppId
                ORDER BY CreatedDate ASC
        ];
    }

    public static List<Application_Role__c> getApplicationRolesForFamily (Id oppId, Id factFindId, Id accId) {
        return [
                SELECT Id
                FROM Application_Role__c
                WHERE Opportunity__c = :oppId
                AND Role__c = :ApexAkina_Constants.BENEFICIARY
                AND Account__c = :accId
                AND Fact_Find__c = :factFindId
        ];
    }

    public static Account getAccountById (Id accId) {
        return getAccountByIds(new Set<Id>{accId})[0];
    }

    public static List<Account> getAccountByIds (Set<Id> accId) {
        return [
                SELECT Id, Name, Salutation, FirstName, LastName, MiddleName, Preferred_Name__pc, PersonBirthdate, Gender__pc, Marital_Status__pc, Smoker__pc, Health__pc, Resident__pc, Housing_Status__pc, Dependant_until_age__pc,
                        PersonHomePhone, Phone, PersonMobilePhone, PersonEmail, Other_Email__pc, Business_Email__c, PersonOtherStreet, PersonOtherCity, PersonOtherState, PersonOtherPostalCode, PersonOtherCountry, PersonContactId,
                        PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry, isPersonAccount, RecordType.DeveloperName, Type, Age__pc, Conga_Health_Policy_Exists__c,
                        Total_Business_Expense_Cover__c, Total_Individual_Monthly_Premiums__c, Total_DI_Cover__c, Total_Health_Cover__c, Total_Life_Cover__c, Total_TPD_Cover__c, Total_Trauma_Cover__c, PersonOtherAddress, PersonMailingAddress, Client_Preferred_Name__c,
                        Number_of_Investment_Assets__c,Country_Code__pc, Total_KiwiSaver_Assets__c,Number_of_Retirement_Assets__c, Number_of_Mortgage_Investment_Liabilitie__c, Fire_and_General__c, Mortgage__c, Income__c, Retirement__c, Life_Event__c, Investment_Savings__c, Total_Joint_Policy_Monthly_Premium__c
                FROM Account
                WHERE Id IN :accId
                ORDER BY Partner_Status__pc
        ];
    }

    public static List<Account> getAccountByNameAndType (String name, String type) {
        return [
                SELECT Id, Name, Type,isPersonAccount
                FROM Account
                WHERE Name = :name
                AND Type = :type
                LIMIT 1
        ];
    }

    public static List<Fact_Find__c> getFactFinds (Id accountId, Id factFindId) {
        return [
                SELECT Id, Unique_Number__c, Do_Not_Advise_Base_On_Client_Details__c, Joint_Owner__c, Primary_Owner__c, No_Dependents__c, Chosen_Not_to_Provide_Dependents_Details__c, Chosen_Not_to_Provide_Employment_Details__c,
                        Chosen_Not_to_Provide_Income_Details__c, Do_not_Know_What_Are_My_Expenses__c, Chosen_Not_to_Provide_Expense_Details__c, No_Assets__c, Chosen_Not_to_Provide_Asset_Details__c,
                        No_Liabilities__c, Chosen_Not_to_Provide_Liability_Details__c, Existing_Risk_Insurance_Primary_Owner__c, Existing_Risk_Insurance_Joint_Owner__c, Assets_and_Liabilities_Notes__c,
                        No_Contingent_Liabilities__c, Letter_of_Authority_Scope__c, Servicing_Adviser__c, Dependent_Notes__c, Asset_Notes__c, Existing_Risk_Notes__c, Income_Notes__c, Referrals_Notes__c, Agenda_Notes__c,
                        No_Other_Entities__c, Chosen_Not_to_Provide_Other_Entities__c, Primary_Owner__r.LastName, Joint_Owner__r.LastName, Referral_Contact_Financial_Details__c, Referral_Disclosure__c, Client_Expectations__c,
            			Tax_Resident_Country_Other_Than_NZ__c, Tax_Resident_Country_Name__c, Tax_Resident_Number__c
                FROM Fact_Find__c
                WHERE Primary_Owner__c = :accountId OR Id = :factFindId
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
    }

    public static List<Relationship__c> getRelationshipsByAccountIdsAndType (Set<Id> accId, Set<String> types) {
        return [
                SELECT Id, Account__c, Fact_Find__c, Related_Account__c, Relationship_Type__c, Account__r.Name, Related_Account__r.Name, Description__c, External_Id__c, Dependant__c, Account__r.Client_Preferred_Name__c, Related_Account__r.Client_Preferred_Name__c
                FROM Relationship__c
                WHERE Relationship_Type__c IN :types
                AND Account__c IN :accId
        ];
    }

    public static List<Application_Role__c> getApplicationRolesByOppId (Id oppId, Id accId){

        return [
                SELECT Id, Account__c,Opportunity__c, Fact_Find__c
                FROM Application_Role__c
                WHERE Opportunity__c =:oppId
                AND Account__c =:accId
        ];

    }

    public static List<Relationship__c> getRelationshipByAccountIdsAndRelatedAccountIdAndType (Id accId, Id relatedAccountId, Set<String> types) {
        return [
                SELECT Id, Account__c, Fact_Find__c, Related_Account__c, Relationship_Type__c, Account__r.Name, Related_Account__r.Name, Description__c, External_Id__c, Dependant__c, Account__r.Client_Preferred_Name__c, Related_Account__r.Client_Preferred_Name__c
                FROM Relationship__c
                WHERE Related_Account__c = :relatedAccountId
                AND Account__c = :accId
                AND Relationship_Type__c IN :types
                LIMIT 1
        ];
    }

    public static List<Relationship__c> getRelationshipsByAccountIdAndFactFindId (Id accId, Id factFindId) {
        return [
                SELECT Id
                FROM Relationship__c
                WHERE Related_Account__c = :accId
                AND Fact_Find__c = :factFindId
        ];
    }

    public static List<Account> getDependantAccounts(Set<Id> accIds) {
        return [
                SELECT Id, Name, FirstName, LastName, PersonBirthdate, Dependant_until_age__pc, isPersonAccount, Age__pc, Client_Preferred_Name__c
                FROM Account
                WHERE Id IN :accIds
                AND isPersonAccount = TRUE
                ORDER BY CreatedDate DESC
        ];
    }

    public static List<Employment_Detail__c> getEmploymentDetails (Set<Id> clientIds) {
        return [
                SELECT Id, Account__c, Employer__c, Fact_Find__c, Job_Title__c, Status__c, Main_Source_of_Income__c, Current_Occupation__c, End_Date__c, Start_Date__c
                FROM Employment_Detail__c
                WHERE Account__c IN :clientIds
                ORDER BY CreatedDate ASC
        ];
    }

    public static List<Employment_Detail__c> getEmploymentDetailsByAccountId (Id accId) {
        return getEmploymentDetails(new Set<Id>{accId});
    }

    public static List<Income_and_Expense__c> getIncomeAndExpenses (Set<Id> clientIds) {
        return [
                SELECT Id, Amount__c, Type__c, Fact_Find__c, Primary_Owner__c, RecordTypeId, Primary_Owner__r.Name, Primary_Owner__r.Client_Preferred_Name__c
                FROM Income_and_Expense__c
                WHERE Primary_Owner__c IN :clientIds
                ORDER BY CreatedDate ASC
        ];
    }

    public static List<Estate_Planning__c> getEstatePlannings (Set<Id> clientIds) {
        return [
                SELECT Id, Primary_Owner__c, Joint_Owner__c, Will__c, Referral_Required_No_Will__c, Will_Up_to_Date__c, Where_is_your_Will_Held__c, Granted_Power_of_Attorney__c, Do_you_have_a_trust__c, Trust_Name__c, Notes__c
                FROM Estate_Planning__c
                WHERE Primary_Owner__c IN :clientIds
                ORDER BY CreatedDate ASC
        ];
    }

    public static List<AccountContactRelation> getAccountContactRelationsByIds (Set<String> ids) {
        return [
                SELECT Id, AccountId, ContactId, Roles, Firm__c
                FROM AccountContactRelation
                WHERE Id IN :ids
                ORDER BY CreatedDate ASC
        ];
    }

    public static List<AccountContactRelation> getAccountContactRelationsByAccountId (Id accId) {
        return [
                SELECT Id, AccountId, ContactId, Roles, Firm__c
                FROM AccountContactRelation
                WHERE AccountId = :accId
                ORDER BY CreatedDate ASC
        ];
    }

    public static List<Goal__c> getGoalsByAccountIds (Set<Id> accIds) {
        return [
                SELECT Id, Name, Account__c, Comments__c, Fact_Find__c, Sub_Type__c, Term__c, Goal_Type__c, Type__c, Amount__c, Date_Required__c, RecordTypeId, Section__c
                FROM Goal__c
                WHERE Account__c IN :accIds
                ORDER BY Section__c ASC, CreatedDate ASC
        ];
    }

    public static List<Referral__c> getInternalReferralsByOpportunityId (Id oppId) {
        return [
                SELECT Id, Internal_Referral__c, Internal_Referral__r.Name, Contact_Financial_Details__c, Opportunity__c, Referral_Disclosure__c, Type__c, Notes__c
                FROM Referral__c
                WHERE Opportunity__c = :oppId
                AND Internal_Referral__c != NULL
                ORDER BY CreatedDate DESC
        ];
    }

    public static List<Analysis__c> getAnalyses (Set<Id> clientIds) {
        return [
                SELECT Id, RecordTypeId, Account__c, Type__c, Name, Annual_Income__c, Total_Requirements__c, Income_to_be_replaced__c, Liabilities_to_be_paid_out__c, Children_Included__c, Monthly_mortgage_repayments__c, Gift_Assets__c, Retirement_Planning__c,
                        Existing_Private_Health_Insurance__c, Benefits_Required__c, Excess_Required__c, Notes__c, Sum_to_be_ensure_assured__c, Waiting_Period_Weeks__c, Benefit_Period__c, Existing_Insurance__c, Dispose_any_Assets__c, Retirement_Income_Estimate__c,
                        Cash_savings_or_disposable_assets__c, Emergency_Fund__c, Income_Replaced_Months__c, Medical_Costs_Recovery__c, Funeral_Expenses__c, Personal_Health_Issues__c, Smoker__c, Client_Investment_Knowledge__c, Client_Investment_Experience__c,
                        Emergency_Fund_Planning__c, Own_or_Any_Occupation__c, Investment_Notes__c, Agree_to_Risk_Profile_Score__c, Risk_Profile_Score__c, Risk_Profile_Type__c, Personal_Health_Issues_Other__c, Family_History_Notes__c
                FROM Analysis__c
                WHERE Account__c IN :clientIds
                ORDER BY CreatedDate ASC
        ];
    }

    public static List<Task> getTasksForExternalReferrals(Id oppId) {
        return [
                SELECT Id, Subject, Status, CreatedDate
                FROM Task
                WHERE WhatId = :oppId
                AND Subject LIKE 'Referrals for%'
                ORDER BY CreatedDate DESC
        ];
    }

    public static List<Analysis_Survey__c> getAnalysisSurveysByAnalysisId (Id analysisId) {
        return [
                SELECT Id, Name, Answer_Value__c
                FROM Analysis_Survey__c
                WHERE Analysis__c = :analysisId
        ];
    }

    public static Fact_Find__c getFactFindById (Id facFindId) {
        return getFactFinds(null, facFindId)[0];
    }

    public static List<ContentDocument> getContentDocumentsByContentVersionId (String contentVersionId) {
        return [
                SELECT Id
                FROM ContentDocument
                WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId)
        ];
    }

    public static List<Question_Scoring__mdt> getScorings () {
        return [
                SELECT MasterLabel, DeveloperName, Min__c, Max__c, Profile__c, Profile_Description__c, Profile_Type__c
                FROM Question_Scoring__mdt
                ORDER BY DeveloperName ASC
        ];
    }

    public static List<Declaration__mdt> getDeclarations () {
        return [
                SELECT MasterLabel, DeveloperName, Content__c, Order__c
                FROM Declaration__mdt
                ORDER BY Order__c ASC
        ];
    }

    public static List<Relationship_Type__mdt> getRelationshipTypes() {
        return [
                SELECT MasterLabel, DeveloperName, Type__c, Order__c
                FROM Relationship_Type__mdt
                ORDER BY Type__c ASC, Order__c ASC
        ];
    }

    public static List<Referral_Type__mdt> getReferralTypes() {
        return [
                SELECT MasterLabel, DeveloperName, Type__c, Order__c,
                (SELECT Id, MasterLabel, DeveloperName, Portal_URL__c, Referral_Text__c, Order__c, AccountId__c
                FROM Referral_Providers__r ORDER BY Order__c)
                FROM Referral_Type__mdt
                ORDER BY Type__c ASC, Order__c ASC
        ];
    }

    public static Set<String> getRelationshipTypeNamesByType(String type) {
        Set<String> relationshipNames = new Set<String>();
        for (Relationship_Type__mdt relationship : [SELECT MasterLabel FROM Relationship_Type__mdt WHERE Type__c = :type]) {
            relationshipNames.add(relationship.MasterLabel);
        }

        return relationshipNames;
    }

    public static List<Goal_Type__mdt> getGoalTypes() {
        return [
                SELECT MasterLabel, DeveloperName, Type__c, Section__c, Order__c
                FROM Goal_Type__mdt
                ORDER BY Type__c ASC, Order__c ASC
        ];
    }

    public static List<Asset_Type__mdt> getAssetTypesWithLiabilityType() {
        return [
                SELECT MasterLabel, DeveloperName, Type__c, Order__c, Liability_Type__c, Liability_Type__r.MasterLabel, Liability_Type__r.DeveloperName
                FROM Asset_Type__mdt
                ORDER BY Type__c ASC, Order__c ASC
        ];
    }

    public static List<Liability_Type__mdt> getLiabilityTypesWithAssetTypes() {
        return [
                SELECT MasterLabel, DeveloperName, Type__c, Order__c,
                (SELECT MasterLabel, DeveloperName FROM Asset_Types__r)
                FROM Liability_Type__mdt
                ORDER BY Type__c ASC, Order__c ASC
        ];
    }

    public static List<Policy__c> getPolicyWithRoles (Set<Id> clientIds) {
        return [
                SELECT Id, Name, Plan_Name__c, Provider__r.Name, Provider__r.Company_Logo__c, Provider__c, Type__c, Commencement_Date__c, Total_Premium__c, Premium_Frequency__c,Exclusions_Loadings__c,
                (SELECT Id, Account__r.Name, Account__r.Client_Preferred_Name__c FROM Policy_Owners__r WHERE Role__c LIKE '%Owner%' ORDER BY Account__r.Client_Preferred_Name__c)
                FROM Policy__c
                WHERE Type__c IN ('Risk', 'Medical')
                AND Policy_Status__c = 'Existing'
                AND Id IN (SELECT Policy__c FROM Policy_Role__c WHERE Account__c IN :clientIds AND Role__c LIKE '%Owner%')
                ORDER BY Type__c DESC
        ];
    }

    public static List<Policy__c> getPolicyWithBenefitsForPolicyOwners (Set<Id> clientIds) {
        return [
                SELECT Id, Name, Plan_Name__c, Provider__r.Name, Provider__r.Company_Logo__c, Provider__c, Type__c, Commencement_Date__c, Total_Premium__c, Premium_Frequency__c,Exclusions_Loadings__c,
                (SELECT Id, Account__c, Account__r.Name, Account__r.Client_Preferred_Name__c, Type__c, Name, Sum_Insured__c, Type_Icon__c, CPI_Linked__c, Waiver_of_Premium__c, Benefit_Structure__c, Waiting_Period_Weeks__c,
                        Premium_Structure__c, Buyback_Option__c, Future_Insurability__c, Accelerate_Stand_Alone_Choice__c, Cancer_Upgrade__c, Maternity_Benefit__c, Child_Trauma__c,
                        Women_s_Specific_Conditions__c, Men_s_Specific_Conditions__c, Agreed_Indemnity_Choice__c, Benefit_Period__c, Claim_Period__c, Benefit_Frequency__c,
                        Best_Doctors__c, Benefit_Premium__c, Policy__r.Name, Policy__r.Provider__r.Name,
                        Specialist_Tests__c, Optical__c, Dental__c, Extras__c, Private_Hospital__c, Excess__c, Specialist_Excess__c, Hospital_Excess__c, Premium_Payback__c
                FROM Benefits__r
                WHERE Status__c = 'Existing'
                ORDER BY Account__r.Client_Preferred_Name__c)
                FROM Policy__c
                WHERE Type__c IN ('Risk', 'Medical')
                AND Policy_Status__c = 'Existing'
                AND Id IN (SELECT Policy__c FROM Policy_Role__c WHERE Account__c IN :clientIds)
                ORDER BY Type__c DESC
        ];
    }

    public static List<Policy__c> getPolicyWithOwnersAsBeneficiaries (Set<Id> clientIds) {
        return [
                SELECT Id, Name, Plan_Name__c, Provider__r.Name, Provider__r.Company_Logo__c, Provider__c, Type__c, Commencement_Date__c, Total_Premium__c, Premium_Frequency__c,Exclusions_Loadings__c,
                (SELECT Id, Account__c, Account__r.Name, Account__r.Client_Preferred_Name__c, Type__c, Name, Sum_Insured__c, Type_Icon__c, CPI_Linked__c, Waiver_of_Premium__c, Benefit_Structure__c, Waiting_Period_Weeks__c,
                        Premium_Structure__c, Buyback_Option__c, Future_Insurability__c, Accelerate_Stand_Alone_Choice__c, Cancer_Upgrade__c, Maternity_Benefit__c, Child_Trauma__c,
                        Women_s_Specific_Conditions__c, Men_s_Specific_Conditions__c, Agreed_Indemnity_Choice__c, Benefit_Period__c, Claim_Period__c, Benefit_Frequency__c,
                        Best_Doctors__c, Benefit_Premium__c, Policy__r.Name, Policy__r.Provider__r.Name,
                        Specialist_Tests__c, Optical__c, Dental__c, Extras__c, Private_Hospital__c, Excess__c, Specialist_Excess__c, Hospital_Excess__c, Premium_Payback__c
                FROM Benefits__r
                WHERE Status__c = 'Existing'
                AND Account__c IN :clientIds
                ORDER BY Account__r.Name),
                (SELECT Id, Account__r.Name, Account__r.Client_Preferred_Name__c FROM Policy_Owners__r WHERE Role__c LIKE '%Owner%' ORDER BY Account__r.Client_Preferred_Name__c)
                FROM Policy__c
                WHERE Type__c IN ('Risk', 'Medical')
                AND Policy_Status__c = 'Existing'
                AND Id IN (SELECT Policy__c FROM Policy_Benefit__c WHERE Status__c = 'Existing' AND Account__c IN :clientIds)
                ORDER BY Type__c DESC
        ];
    }

    public static List<Client_Asset__c> getAssetsForPolicies (Set<Id> clientIds) {
        return [
                SELECT Id, Name, Provider__r.Name, Provider__r.Company_Logo__c, Provider__c, Type__c, Account_Client_Number__c, Establishment_Date__c, Contribution_Amount__c, Contribution_Frequency__c, Values_Last_Updated__c, Value__c,
                (SELECT Account__r.Name, Account__r.Client_Preferred_Name__c FROM Asset_Roles__r)
                FROM Client_Asset__c
                WHERE Type__c IN ('Investments', 'Kiwisaver')
                AND Status__c = 'Existing'
                AND Serviced_by_Apex__c = TRUE
                AND Id IN (SELECT Asset__c FROM Asset_Role__c WHERE Account__c IN :clientIds)
        ];
    }

    public static List<Liability__c> getLiabilitiesForPolicies (Set<Id> clientIds) {
        return [
                SELECT Id, Name, Institution__r.Name, Institution__r.Company_Logo__c, Institution__c, Type__c, Client_Number__c, Start_Date__c, Term_Months__c, Rate__c, Values_Last_Updated__c, Current_Balance__c, Loan_Amount__c,
                (SELECT Account__r.Name, Account__r.Client_Preferred_Name__c FROM Liability_Roles__r)
                FROM Liability__c
                WHERE Serviced_by_Apex__c = TRUE
                AND Status__c = 'Current'
                AND Id IN (SELECT Liability__c FROM Liability_Role__c WHERE Account__c IN :clientIds)
        ];
    }

    //Added by: Alvin Aquino - AP2-104
    public static List<Policy_Benefit__c> getPolicyBenefit (Set<Id> clientIds) {
        return [
                SELECT Id, Account__c, Account__r.Name, Type__c, Name, Policy__c, Policy__r.Name, Sum_Insured__c, Policy__r.Provider__r.Name
                FROM Policy_Benefit__c 
                WHERE Account__c IN :clientIds 
                AND Status__c = 'Existing'
        ];
    }

    public static List<Non_Apex_Cover__c> getNonApexCover (Set<Id> clientIds){
        return [
                SELECT Id, Name, Benefit_Type__c, Person_Insured__c, Person_Insured__r.Name, Policy_Number__c, Policy_Type__c, Provider__c  , Value__c
                FROM Non_Apex_Cover__c 
                WHERE Person_Insured__c IN :clientIds OR Related_Account__c IN :clientIds
                ORDER BY CreatedDate
        ];
    }
}