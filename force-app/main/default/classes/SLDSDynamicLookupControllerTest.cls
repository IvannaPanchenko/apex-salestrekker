/**
* @author David Catindoy (david@cloudinit.nz)
* @date Dec 14, 2017
* @description Test class for SLDSDynamicLookupController
*
* CHANGE LOG
**/
@isTest
private class SLDSDynamicLookupControllerTest {
    
    //Setup method
    @testSetup
    static void setup(){
        Id clientRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
        Account newAcc = new Account(FirstName = 'David', LastName = 'Catindoy', RecordTypeId = clientRecType);
        Database.insert(newAcc); //Create new person account
    }
    
    //Test search method
    @isTest
    static void testSearch(){
        SLDSDynamicLookupController controller = new SLDSDynamicLookupController();
        controller.objectName = 'Account';
        controller.label = 'Client1';
        controller.placeHolder = 'Search Account';
        List<SLDSDynamicLookupController.Wrapper> results = SLDSDynamicLookupController.search('Account', 'Name,Type', '', 'url->/img/icon/t4v35/standard/person_account_120.png', 'Catindoy', '', '', 'isPersonAccount = true');
        
        //Assert that all values are exactly the same with what we're expecting.
        System.assertEquals('David Catindoy,Client', results.get(0).displayValue);
        System.assertEquals('/img/icon/t4v35/standard/person_account_120.png', results.get(0).photoUrl);
        System.assert(String.isNotBlank(results.get(0).recordId));
        
        results = SLDSDynamicLookupController.search('Account', 'Name,Type', '', 'field->Advisor_Blurb__c', 'Catindoy', '', '', 'isPersonAccount = true');
    }
}