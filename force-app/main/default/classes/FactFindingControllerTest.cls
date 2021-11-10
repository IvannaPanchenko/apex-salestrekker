/**
* @author David Catindoy (david@cloudinit.nz)
* @date Dec 14, 2017
* @description Test class for FactFindingController
*
* CHANGE LOG
* Patrick Lorilla (plorilla@deloitte.co.nz) Added logic to update Fact Find Client Expectation field -  Oct 14, 2020
**/
@IsTest
private class FactFindingControllerTest {

    //Setup method
    @TestSetup
    static void setup(){

        Test.startTest();
        // insert person account
        Account newAcc = TestData.createPersonAccount(true, 'Catindoy');

        // insert related account
        Account newRelatedAcc = TestData.createBeneficiary(true, 'Beneficiary');

        // insert partner account
        Account partnerAccount = TestData.createPartnerAccount(true, newAcc.Id);

        // Insert legal entity
        Account legalEntity = TestData.createLegalEntityAccount(true);

        //Insert new opportunity.
        Opportunity opp = TestData.createOpportunity(true, newAcc.Id);

        // Create new job application role
        Application_Role__c applicationRole = TestData.createApplicationRole(true, newAcc.Id, opp.Id);

        // insert new relationship
        Relationship__c relationship = TestData.createRelationship(true, newAcc.Id, newRelatedAcc.Id, 'Child', 'Yes');

        // insert new Employment
        Employment_Detail__c employmentDetail = TestData.createEmploymentDetail(true, newAcc.Id);

        // insert new Asset
        Client_Asset__c clientAsset = TestData.createAsset(true);
        Asset_Role__c assetRole = TestData.createAssetRole(true, clientAsset.Id, newAcc.Id);

        // insert new Liability
        Liability__c liability = TestData.createLiability(true, false);
        Liability_Role__c liabilityRole = TestData.createLiabilityRole(true, liability.Id, newAcc.Id);

        // insert new contingent liability
        Liability__c contLiability = TestData.createLiability(true, true);
        Liability_Role__c contLiabilityRole = TestData.createLiabilityRole(true, contLiability.Id, newAcc.Id);

        // insert new income
        Income_and_Expense__c income = TestData.createIncome(true, newAcc.Id);

        // insert new other entity relationship
        Relationship__c otherEntity = TestData.createRelationship(true, newAcc.Id, legalEntity.Id, 'Trustee', 'No');

        // insert a goal
        Goal__c goal = TestData.createGoal(true, newAcc.Id);

        // insert a referral
        Referral__c referral = TestData.createReferral(true, newAcc.Id);

        insert new Trigger_Manager__c(Fact_Find__c = true, Opportunity__c = false);

        Test.stopTest();
    }

    @IsTest
    static void testKnowYourClientTab() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        opp.Sharepoint_Folder_Created__c = true;

        update opp;

        Id jointOwner = [SELECT Id FROM Account WHERE PersonEmail = 'testPartner@testDomain.co.nz' LIMIT 1].Id;

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        

        //Change application type to 'Joint'
        controller.changeApplicationType();
        controller.applicationType = 'Joint';
        controller.changeApplicationType();

        //Change Opp Joint Owner
        controller.opp.Joint_Owner__c = jointOwner;
        controller.changeClient2();

        //Assert select option lists
        System.assert(!controller.salutationList.isEmpty());
        System.assert(!controller.ownerTypeList.isEmpty());
        System.assert(!controller.familyRelationList.isEmpty());
        System.assert(!controller.contactType.isEmpty());
        System.assert(!controller.timeList.isEmpty());
        System.assert(!controller.getClient1EmploymentIsEmpty());
        System.assert(controller.getClient2EmploymentIsEmpty());
        System.assert(!controller.getAssetsIsEmpty());
        System.assert(!controller.getLiabilitiesIsEmpty());
        System.assert(!controller.getConLiabilitiesIsEmpty());

        //Additional Meeting Agenda
        controller.client2.account.LastName = 'Ecay';
        controller.client2.account.FirstName = 'Mark';

        //Existing Risk Insurance Cover
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_1).option1 = true;
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_1).option2 = false;
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_2).option1 = true;

        //Employment Details
        controller.keys = ApexAkina_Constants.CLIENT_1;
        controller.addEmployment();
        controller.employment.get(ApexAkina_Constants.CLIENT_1).get(0).employment.Job_Title__c = 'Technical Consultant';
        controller.employment.get(ApexAkina_Constants.CLIENT_1).get(0).employment.Employer__c = 'Salesforce';
        controller.keys = ApexAkina_Constants.CLIENT_2;
        controller.addEmployment();
        controller.employment.get(ApexAkina_Constants.CLIENT_2).get(0).employment.Job_Title__c = 'Building Architect';
        controller.employment.get(ApexAkina_Constants.CLIENT_2).get(0).employment.Employer__c = 'Gensler';

        //Professionals
        controller.professionals.values()[0].LastName = 'Deane Taljaard';
        controller.contactRoles.values()[0].Firm__c = 'CloudinIT';
        controller.professionals.values()[1].LastName = 'Yongling Chua';
        controller.contactRoles.values()[1].Firm__c = 'Salesforce';
        controller.professionals.values()[2].LastName = 'Carmen Ecay';
        controller.contactRoles.values()[2].Firm__c = 'Sovereign';
		Test.startTest();
        controller.saveClientDetails();
		
        System.assertEquals('Saved successfully!', ApexPages.getMessages()[0].getSummary());

        controller.nextStepsNotes.Body = 'Sample Notes';
        controller.addNotes();
		
       

        System.assert(![SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :opp.Id].isEmpty());
		System.debug('\n\n\n factFind '+ controller.factFind.Id);
        update new Fact_Find__c(Id = controller.factFind.Id, Letter_of_Authority_Scope__c = 'Existing application');

        controller = new FactFindingController(new ApexPages.StandardController(opp));
        
        
       
        controller.saveScopeOfEngagement();
        controller.cleanScopeOfEngagement();
        controller.saveLetterOfAuthority();
        controller.cleanLetterOfAuthority();
        controller.getUpdatedSignatures();
       
        Test.stopTest();
    }

    @IsTest
    static void testIncomeAndExpenseTabAndGoalsAndReferrals() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        //Assert select option lists
        System.assert(controller.getClient2IncomeIsEmpty());
        System.assert(!controller.getClient1IncomeIsEmpty());
        System.assert(controller.getExpensesIsEmpty());

        controller.existingRisks.get(ApexAkina_Constants.CLIENT_1).option1 = true;
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_2).option1 = true;

        //Income Details
        controller.keys = ApexAkina_Constants.CLIENT_1;
        controller.keys = ApexAkina_Constants.CLIENT_2;
        controller.addIncome();
        controller.incomeAndExpenses.get(ApexAkina_Constants.CLIENT_2).get(0).incomeExpense.Amount__c = 150000;
        controller.incomeAndExpenses.get(ApexAkina_Constants.CLIENT_2).get(0).incomeExpense.Type__c = 'Salary/Wages';
        controller.keys = 'Client 1 - Income';
        controller.addIncome();
        controller.incomeAndExpenses.get('Client 1 - Income').get(0).incomeExpense.Amount__c = 120000;
        controller.incomeAndExpenses.get('Client 1 - Income').get(0).incomeExpense.Type__c = 'Salary/Wages';

        //Expense Details
        controller.keys = 'Client 1 - Expenses';
        controller.addExpense();
        controller.incomeAndExpenses.get('Client 1 - Expenses').get(0).incomeExpense.Amount__c = 120000;
        controller.incomeAndExpenses.get('Client 1 - Expenses').get(0).incomeExpense.Type__c = 'Insurance';

        // Referrals
        controller.referralTypes.get('Internal')[0].externalChecked = true;
        controller.factFind.Client_Expectations__c = 'test client exp';
        controller.saveClientDetails();

        Test.stopTest();

        System.assertEquals('Saved successfully!', ApexPages.getMessages()[0].getSummary());
    }

    @IsTest
    static void testYourFamilyTab() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        //Assert select option lists
        System.assert(!controller.getFamilyMembersIsEmpty());

        //add a new member
        controller.addEditFamilyMember();

        // add new family member
        controller.familyMemberToAddEdit.account.FirstName = 'MyFirst';
        controller.familyMemberToAddEdit.account.LastName = 'Child';
        controller.familyMemberToAddEdit.relationship.Relationship_Type__c = 'Child';

        controller.saveFamilyMember();

        Test.stopTest();

        System.assertEquals('Saved successfully!', ApexPages.getMessages()[0].getSummary());
    }

    @IsTest
    static void testOtherEntitiesTab() {
        Account legalEntity = [SELECT Id, Name FROM Account WHERE Business_Email__c = 'testLegalEntity@testDomain.co.nz' LIMIT 1];
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        //Assert select option lists
        System.assert(!controller.whoList.isEmpty());
        System.assert(!controller.personalGuaranteeList.isEmpty());
        System.assert(!controller.otherEntityRoleRelationList.isEmpty());
        System.assert(!controller.getOtherEntitiesIsEmpty());
        System.assert(controller.getOtherEntitiesRolesIsEmpty());

        // add existing risks
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_1).option1 = true;
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_2).option1 = true;

        //add a new other entity
        controller.addEditOtherEntity();

        // select legal entity
        controller.otherEntityToAddEdit.account.Id = legalEntity.Id;
        controller.selectLegalEntity();

        // new Role
        controller.addOtherEntityRole();

        for (FactFindingControllerService.OtherEntitiesRolesWrapper role : controller.otherEntityToAddEdit.roles) {
            role.relationship.Relationship_Type__c = 'Owner';
        }

        controller.saveOtherEntities();

        Test.stopTest();

        System.assertEquals('Saved successfully!', ApexPages.getMessages()[0].getSummary());
    }

    @IsTest
    static void testNeedsAnalysis() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        //Needs Analysis
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_1).option1 = true;
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_2).option1 = true;
        controller.analysis.get('Client 1').values()[0].Children_Included__c = true;
        controller.clientBenefits.get('Client 1').option1 = true;
        controller.clientBenefits.get('Client 1').option2 = true;
        controller.clientBenefits.get('Client 1').option3 = true;
        controller.clientBenefits.get('Client 1').option4 = true;
        controller.clientBenefits.get('Client 1').option5 = true;

        controller.saveNeedsAnalysis();

        System.assertEquals('Saved successfully!', ApexPages.getMessages()[0].getSummary());

        Test.stopTest();

        controller = new FactFindingController(new ApexPages.StandardController(opp));
    }

    @IsTest
    static void testRiskAnalysis() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];

        Test.startTest();

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        FactFindingControllerService.GoalsListWrapper goalsListWrapper = new FactFindingControllerService.GoalsListWrapper();
        FactFindingControllerService.GoalWrapper goalWrapper = new FactFindingControllerService.GoalWrapper(client1Account.Id, ApexAkina_Constants.INVGOAL_RECTYPE);
        goalWrapper.goal.Name = 'Car/Boat etc';
        goalWrapper.goal.Term__c = 'Long';
        goalWrapper.goal.Comments__c = 'Test comment';
        goalWrapper.goal.Amount__c = 99;
        goalWrapper.stringDate = '01/10/2020';
        goalsListWrapper.goals.add(goalWrapper);

        //Risk Analysis
        controller.addAsset();
        controller.addAsset();
        controller.assetRoleWrappers.get(0).strOwnerType = 'Joint';
        controller.assetRoleWrappers.get(0).asset.Disposable__c = true;
        controller.assetRoleWrappers.get(0).asset.Gift_Asset__c = true;
        controller.assetRoleWrappers.get(0).asset.Type__c = Client_Asset__c.Type__c.getDescribe().getPicklistValues().get(1).getValue();
        controller.assetRoleWrappers.get(1).strOwnerType = 'Client 1';
        controller.assetRoleWrappers.get(1).asset.Disposable__c = true;
        controller.assetRoleWrappers.get(1).asset.Gift_Asset__c = true;
        controller.assetRoleWrappers.get(1).asset.Type__c = Client_Asset__c.Type__c.getDescribe().getPicklistValues().get(2).getValue();
        controller.mapInvestmentGoals.put('Investment Specific Goals', goalsListWrapper);
        controller.calculateScore();
        controller.investmentRiskQ.values()[0].option1 = true;

        //Save Risk Analysis
        controller.saveRiskAnalysis();
        System.assertEquals('Investor Profile details were saved.', ApexPages.getMessages()[0].getSummary());

        Analysis_Survey__c analysisSurvey = controller.investmentRiskQ.values()[0].analysisSurvey;
        analysisSurvey.Answer_Value__c = 'A';
        upsert analysisSurvey;

        Test.stopTest();

        controller = new FactFindingController(new ApexPages.StandardController(opp));
    }

    //Test next appointment
    @IsTest
    static void testNextAppointment(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        controller.nextAppointment.Subject = 'Meetup at Starbucks';
        controller.nextAppointment.Location = 'Starbucks';
        controller.saveAppointment();
    }

    //Use Cases to Change the Asset Roles
    //Case 1: Client 1 to Client 2
    //Case 2: Client 2 to Client 1
    //Case 3: Client 1 to Joint
    //Case 4: Joint to Client 1
    @IsTest
    static void testAssetsAndLiabilitiesFirst() {

        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];
        Account partnerAccount = [SELECT Id, Name FROM Account WHERE Partner__c = :client1Account.Id LIMIT 1];

        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        opp.Sharepoint_Folder_Created__c = true;
        opp.Joint_Owner__c = partnerAccount.Id;
        update opp;

        //Create Test Asset Records
        List<Client_Asset__c> assets = new List<Client_Asset__c>();
        List<Asset_Role__c> assetRoles = new List<Asset_Role__c>();

        for(Integer index = 0; index < 4; index++){
            Client_Asset__c asset = new Client_Asset__c();
            asset.Value__c = 100 + index;
            assets.add(asset);
        }
        assets[0].Type__c = 'Business Assets';
        assets[0].Name = 'Business Assets';
        assets[1].Type__c = 'Life Style';
        assets[1].Name = 'Life Style';
        assets[2].Type__c = 'Motor Vehicles';
        assets[2].Name = 'Motor Vehicles';
        assets[3].Type__c = 'Real Estate-Primary Residence';
        assets[3].Name = 'Real Estate';

        insert assets;

        assetRoles.add(FactFindingControllerTest.getAssetRoles(client1Account.Id, assets[0].Id));    //Client 1
        assetRoles.add(FactFindingControllerTest.getAssetRoles(partnerAccount.Id, assets[1].Id));    //Client 2
        assetRoles.add(FactFindingControllerTest.getAssetRoles(client1Account.Id, assets[2].Id));    // Joint
        assetRoles.add(FactFindingControllerTest.getAssetRoles(partnerAccount.Id, assets[2].Id));    // Joint
        assetRoles.add(FactFindingControllerTest.getAssetRoles(client1Account.Id, assets[3].Id));    // Client 1
        insert assetRoles;

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        //Change Opp Joint Owner
        controller.opp.Joint_Owner__c = partnerAccount.Id;
        controller.changeClient2();
        Test.startTest();
        controller = new FactFindingController(new ApexPages.StandardController(opp));

        controller.existingRisks.get(ApexAkina_Constants.CLIENT_1).option1 = true;
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_1).option2 = false;
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_2).option1 = true;

        

        //assetRoleWrappers
        for(FactFindingControllerService.AssetRoleWrapper roleWrapper : controller.assetRoleWrappers){

            if(roleWrapper.strOwnerType.equalsIgnoreCase(client1Account.Id)){
                roleWrapper.strOwnerType = partnerAccount.Id;
                roleWrapper.asset.Value__c = 150;
            }
            else if(roleWrapper.strOwnerType.equalsIgnoreCase(partnerAccount.Id)){
                roleWrapper.strOwnerType = client1Account.Id;
            }
            else if(roleWrapper.strOwnerType.equalsIgnoreCase('Joint')){
                roleWrapper.strOwnerType = client1Account.Id;
            }
            else if(roleWrapper.strOwnerType.equalsIgnoreCase(client1Account.Id) && roleWrapper.asset.Name.equalsIgnoreCase('Real Estate')){
                roleWrapper.strOwnerType = 'Joint';
            }
        }

        controller.saveClientDetails();

        Integer first = 0;
        for(Asset_Role__c roleToAssert : [SELECT Id, Account__c, Asset__r.Name FROM Asset_Role__c ORDER BY Account__c]){

            if(roleToAssert.Asset__r.Name.equalsIgnoreCase('Business Assets')){
                System.assertEquals(roleToAssert.Account__c, partnerAccount.Id);
            }
            if(roleToAssert.Asset__r.Name.equalsIgnoreCase('Life Style')){
                System.assertEquals(roleToAssert.Account__c, client1Account.Id);
            }

            if(roleToAssert.Asset__r.Name.equalsIgnoreCase('Real Estate')){
                if (first == 0) {
                    System.assertEquals(roleToAssert.Account__c, partnerAccount.Id);
                    first = 1;
                } else {
                    System.assertEquals(roleToAssert.Account__c, client1Account.Id);
                }
            }

            if(roleToAssert.Asset__r.Name.equalsIgnoreCase('Motor Vehicles')){
                System.assertEquals(roleToAssert.Account__c, client1Account.Id);
            }
        }

        Test.stopTest();
    }

    //Use Cases to Change the Asset Roles
    //Case 1: Client 2 to Joint
    //Case 2: Joint to Client 2
    @IsTest
    static void testAssetsAndLiabilitiesSecond() {

        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];
        Account partnerAccount = [SELECT Id, Name FROM Account WHERE Partner__c = :client1Account.Id LIMIT 1];

        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        opp.Sharepoint_Folder_Created__c = true;
        opp.Joint_Owner__c = partnerAccount.Id;
        update opp;

        //Create Test Asset Records
        List<Client_Asset__c> assets = new List<Client_Asset__c>();
        List<Asset_Role__c> assetRoles = new List<Asset_Role__c>();

        for(Integer index = 0; index < 4; index++){
            Client_Asset__c asset = new Client_Asset__c();
            asset.Value__c = 100 + index;
            assets.add(asset);
        }
        assets[0].Type__c = 'Life Style';
        assets[0].Name = 'Life Style';
        assets[1].Type__c = 'Real Estate-Primary Residence';
        assets[1].Name = 'Real Estate';

        insert assets;

        assetRoles.add(FactFindingControllerTest.getAssetRoles(client1Account.Id, assets[0].Id));    //Joint
        assetRoles.add(FactFindingControllerTest.getAssetRoles(partnerAccount.Id, assets[0].Id));            //Joint
        assetRoles.add(FactFindingControllerTest.getAssetRoles(partnerAccount.Id, assets[1].Id));            //Client 2
        insert assetRoles;

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        //Change Opp Joint Owner
        controller.opp.Joint_Owner__c = partnerAccount.Id;
        controller.changeClient2();Test.startTest();
        controller = new FactFindingController(new ApexPages.StandardController(opp));

        controller.existingRisks.get(ApexAkina_Constants.CLIENT_1).option1 = true;
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_1).option2 = false;
        controller.existingRisks.get(ApexAkina_Constants.CLIENT_2).option1 = true;

        

        //assetRoleWrappers
        for(FactFindingControllerService.AssetRoleWrapper roleWrapper : controller.assetRoleWrappers){

            if(roleWrapper.strOwnerType.equalsIgnoreCase(partnerAccount.Name)){
                roleWrapper.strOwnerType = 'Joint';
            }
            else if(roleWrapper.strOwnerType.equalsIgnoreCase('Joint')){
                roleWrapper.strOwnerType = partnerAccount.Name;
            }
        }

        controller.saveClientDetails();

        Integer cnt = 1;
        Integer first = 0;
        for(Asset_Role__c roleToAssert : [SELECT Id, Account__c, Account__r.Name, Asset__r.Name FROM Asset_Role__c ORDER BY Account__c]){

            if(roleToAssert.Asset__r.Name.equalsIgnoreCase('Life Style')){
                if (first == 0) {
                    System.assertEquals(roleToAssert.Account__c, client1Account.Id);
                    first = 1;
                } else {
                    System.assertEquals(roleToAssert.Account__c, partnerAccount.Id);
                }
            }
            if(roleToAssert.Asset__r.Name.equalsIgnoreCase('Real Estate')){
                cnt ++;
            }
        }
        System.assertEquals(cnt, 2);

        //Use cases for Additional Assets
        FactFindingControllerService.AssetRoleWrapper testAdditionalAssets1 = new FactFindingControllerService.AssetRoleWrapper();
        FactFindingControllerService.AssetRoleWrapper testAdditionalAssets2 = new FactFindingControllerService.AssetRoleWrapper();

        testAdditionalAssets1.asset.Type__c = 'Life Style';
        testAdditionalAssets1.asset.Name = 'Life Style';
        testAdditionalAssets1.asset.Value__c = 400;
        testAdditionalAssets1.strOwnerType = 'Client 2';

        testAdditionalAssets2.asset.Type__c = 'Motor Vehicles';
        testAdditionalAssets2.asset.Name = 'Motor Vehicles';
        testAdditionalAssets2.asset.Value__c = 400;
        testAdditionalAssets2.strOwnerType = 'Joint';

        controller.assetRoleWrappers.add(testAdditionalAssets1);
        controller.assetRoleWrappers.add(testAdditionalAssets2);

        controller.saveClientDetails();

        Test.stopTest();
    }

    @IsTest
    static void testDeleteFamilyMember() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        Account relatedAccount = [SELECT Id, Name, PersonEmail FROM Account WHERE RecordType.DeveloperName = 'Beneficiary' LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        System.assertEquals(relatedAccount.PersonEmail, 'john@beneficiary.co.nz');
        controller.recordIdToDelete = relatedAccount.Id;
        controller.typeToDelete = 'Family Member';
        controller.deleteRecord();

        Test.stopTest();

        System.assertEquals(1, [SELECT Id, Name, PersonEmail FROM Account WHERE RecordType.DeveloperName = 'Beneficiary'].size());
    }

    @IsTest
    static void testDeleteEmployment() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];
        Employment_Detail__c employmentDetail = [SELECT Id, Employer__c, Job_Title__c, Account__c  FROM Employment_Detail__c WHERE Account__c = :client1Account.Id LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        System.assertEquals(employmentDetail.Employer__c, 'Test Employer');
        controller.recordIdToDelete = employmentDetail.Id;
        controller.typeToDelete = 'Employment';
        controller.deleteRecord();

        Test.stopTest();

        System.assertEquals(0, [SELECT Id, Employer__c, Job_Title__c, Account__c  FROM Employment_Detail__c WHERE Account__c = :client1Account.Id LIMIT 1].size());
    }

    @IsTest
    static void testDeleteAsset() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];
        Client_Asset__c asset = [SELECT Id, Name  FROM Client_Asset__c WHERE Id IN (SELECT Asset__c FROM Asset_Role__c WHERE Account__c = :client1Account.Id) LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        System.assertEquals(asset.Name, 'Test Asset');
        controller.recordIdToDelete = asset.Id;
        controller.typeToDelete = 'Asset';
        controller.deleteRecord();

        Test.stopTest();

        System.assertEquals(0, [SELECT Id, Name  FROM Client_Asset__c WHERE Id IN (SELECT Asset__c FROM Asset_Role__c WHERE Account__c = :client1Account.Id) LIMIT 1].size());
    }

    @IsTest
    static void testDeleteLiability() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];
        Liability__c liability = [SELECT Id, Name  FROM Liability__c WHERE Personal_Guarantees__c = NULL AND Id IN (SELECT Liability__c FROM Liability_Role__c WHERE Account__c = :client1Account.Id) LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        System.assertEquals(liability.Name, 'Test Liability');
        controller.recordIdToDelete = liability.Id;
        controller.typeToDelete = 'Liability';
        controller.deleteRecord();

        Test.stopTest();

        System.assertEquals(0, [SELECT Id, Name  FROM Liability__c WHERE Personal_Guarantees__c = NULL AND Id IN (SELECT Liability__c FROM Liability_Role__c WHERE Account__c = :client1Account.Id) LIMIT 1].size());
    }

    @IsTest
    static void testDeleteContingentLiability() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];
        Liability__c liability = [SELECT Id, Name  FROM Liability__c WHERE Personal_Guarantees__c != NULL AND Id IN (SELECT Liability__c FROM Liability_Role__c WHERE Account__c = :client1Account.Id) LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        System.assertEquals(liability.Name, 'Test Liability - Contingent');
        controller.recordIdToDelete = liability.Id;
        controller.typeToDelete = 'Contingent Liability';
        controller.deleteRecord();

        Test.stopTest();

        System.assertEquals(0, [SELECT Id, Name  FROM Liability__c WHERE Personal_Guarantees__c != NULL AND Id IN (SELECT Liability__c FROM Liability_Role__c WHERE Account__c = :client1Account.Id) LIMIT 1].size());
    }

    @IsTest
    static void testDeleteIncome() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];
        Income_and_Expense__c income = [SELECT Id, Type__c, Amount__c  FROM Income_and_Expense__c WHERE Primary_Owner__c = :client1Account.Id LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        System.assertEquals(income.Amount__c, 99);
        System.assertEquals(income.Type__c, 'Annual Earnings(Self Employed)');
        controller.recordIdToDelete = income.Id;
        controller.typeToDelete = 'Income/Expense';
        controller.deleteRecord();

        Test.stopTest();

        System.assertEquals(0, [SELECT Id, Type__c, Amount__c  FROM Income_and_Expense__c WHERE Primary_Owner__c = :client1Account.Id LIMIT 1].size());
    }

    @IsTest
    static void testDeleteOtherEntity() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        Account legalEntity = [SELECT Id, Name FROM Account WHERE Business_Email__c = 'testLegalEntity@testDomain.co.nz' LIMIT 1];
        Relationship__c relationship = [SELECT Id, Related_Account__c, Relationship_Type__c  FROM Relationship__c WHERE Related_Account__c = :legalEntity.Id LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        System.assertEquals(relationship.Relationship_Type__c, 'Trustee');

        for (FactFindingControllerService.OtherEntitiesWrapper oeWrapper : controller.otherEntitiesWrappers) {
            oeWrapper.tempId = 'Test1';
        }

        controller.tempIdToDelete = 'Test1';
        controller.typeToDelete = 'Other Entity';
        controller.deleteRecord();

        Test.stopTest();

        System.assertEquals(0, [SELECT Id, Related_Account__c, Relationship_Type__c  FROM Relationship__c WHERE Related_Account__c = :legalEntity.Id LIMIT 1].size());
    }

    @IsTest
    static void testDeleteEntityRole() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        Account legalEntity = [SELECT Id, Name FROM Account WHERE Business_Email__c = 'testLegalEntity@testDomain.co.nz' LIMIT 1];
        Relationship__c relationship = [SELECT Id, Related_Account__c, Relationship_Type__c  FROM Relationship__c WHERE Related_Account__c = :legalEntity.Id LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        System.assertEquals(relationship.Relationship_Type__c, 'Trustee');
        controller.addEditOtherEntity();
        controller.recordIdToDelete = relationship.Id;
        controller.typeToDelete = 'Entity Role';
        controller.deleteRecord();

        Test.stopTest();

        System.assertEquals(0, [SELECT Id, Related_Account__c, Relationship_Type__c  FROM Relationship__c WHERE Related_Account__c = :legalEntity.Id LIMIT 1].size());
    }

    @IsTest
    static void testDeleteGoal() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];
        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];
        Goal__c goal = [SELECT Id, Name FROM Goal__c WHERE Account__c = :client1Account.Id LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();

        System.assertEquals(goal.Name, 'Retire');
        controller.goalTypeToAdd = 'Life Style Goals';
        controller.addGoal();
        controller.recordIdToDelete = goal.Id;
        controller.typeToDelete = 'Goal';
        controller.deleteRecord();

        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM Goal__c WHERE Account__c = :client1Account.Id LIMIT 1].size());
    }

    @IsTest
    static void testCongaMethods() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();
        System.assertNotEquals(null, controller.congaAttributes);
        System.assertNotEquals(null, controller.congaQueries);
        System.assertNotEquals(null, controller.congaTemplates);
        System.assertNotEquals(null, controller.congaRemoteAttributes);
        System.assertNotEquals(null, controller.congaRemoteTemplates);

        Test.stopTest();
    }

    @IsTest
    static void testOtherMethods() {
        Opportunity opp = [SELECT Id, Sharepoint_Folder_Created__c FROM Opportunity LIMIT 1];

        FactFindingController controller = new FactFindingController(new ApexPages.StandardController(opp));

        Test.startTest();
        System.assertNotEquals(null, controller.getWhoListNonApexServicedCover());
        System.assertNotEquals(null, controller.getAllPageMessagesMap());
        System.assertNotEquals(null, controller.relatedAssetList);

        Test.stopTest();
    }

    private static Asset_Role__c getAssetRoles(Id pAccountId, Id pAssetId){

        Asset_Role__c assetRole = new Asset_Role__c();
        assetRole.Account__c = pAccountId;
        assetRole.Asset__c = pAssetId;
        return assetRole;
    }
}