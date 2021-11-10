/**
* @author Ben Edwards (ben@cloudinit.nz)
* @date 14th December 2017
* @description Test class for the UserTriggerHandler
* 
* CHANGE LOG
**/
@isTest
public class UserTriggerHandlerTest {

    @testSetup
    static void setupTestData() {

        TestData.enableTriggers();
    }
    
    // Test scenario of creating a new user
    @isTest
    static void testParseDrawingImageUrl () {

        // Create the test user
        User testUser = TestData.createUser();

        // ASsert that the Rich Text URL has been pushed to the URL field
        testUser = [SELECT Signature_Image_Url__c FROM User WHERE Id = :testUser.Id];
        system.assertEquals('https://testimage.com/myimage.png', testUser.Signature_Image_Url__c);

        // Now update the value
        testUser.Signature_Image__c = '<img src="https://testimage.com/imagechange.png" />';
        update testUser;

        // Assert the updated results
        testUser = [SELECT Signature_Image_Url__c FROM User WHERE Id = :testUser.Id];
        system.assertEquals('https://testimage.com/imagechange.png', testUser.Signature_Image_Url__c);
    }
}