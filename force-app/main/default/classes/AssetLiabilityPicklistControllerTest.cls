/**
* @author Ben Edwards (beedwards@deloitte.co.nz)
* @date 13th November 2020
* @description Test class for AssetLiabilityPicklistController
*
* CHANGE LOG
**/
@isTest 
public class AssetLiabilityPicklistControllerTest {

    @isTest 
    static void testGetPicklistOptions() {

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
        
        Test.startTest();

        List<AssetLiabilityPicklistController.PicklistOption> options = 
            AssetLiabilityPicklistController.getPicklistOptions(newAcc.Id, partnerAccount.Id, 'Asset__c');

        Test.stopTest();

        system.assertNotEquals(null, options);
    }
}