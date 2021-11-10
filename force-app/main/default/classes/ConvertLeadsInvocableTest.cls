/**
* @author Chris Parker (chris@cloudinit.nz)
* @date 14th December 2017
* @description Test class for the ConvertLeadsInvocable class
* 
* CHANGE LOG
**/
@isTest
private class ConvertLeadsInvocableTest {

    @isTest
    static void test_convert_lead_yes_opportunity() {

        Test.startTest();

        Lead testLead = TestData.createLead();
        ConvertLeadsInvocable.LeadConvertRequest request = new ConvertLeadsInvocable.LeadConvertRequest();
        request.leadId = testLead.Id;
        request.convertedStatus = 'Qualified';
        
        try{
            // We cannot rely on the PB cause in the initial deployment it might not be active yet.
            ConvertLeadsInvocable.convertLeads(new List<ConvertLeadsInvocable.LeadConvertRequest>{request});
        } catch (Exception e){
            System.assert(e.getMessage().contains('This lead was already converted to the contact'));
        }

        Test.stopTest();

        // Assert result.
        System.assertEquals(1, [SELECT count() FROM Account]);
        System.assertEquals(1, [SELECT count() FROM Contact]);
        System.assertEquals(1, [SELECT count() FROM Opportunity]);
    }
}