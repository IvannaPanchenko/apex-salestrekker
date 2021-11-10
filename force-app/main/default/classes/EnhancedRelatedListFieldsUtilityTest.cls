/**
 * @author       Pablo Martinez (pablomartinez@deloitte.co.nz)
 * @date         2019-06-20
 * @description  
 * 
 **/
@IsTest
private class EnhancedRelatedListFieldsUtilityTest {

    @TestSetup
    static void testSetup() {
        Contact testContact = new Contact(FirstName='Test', LastName='Name');
        insert testContact;
    }

    @IsTest
    static void testGetObjectMetadata() {
        Contact testContact = [SELECT Id FROM Contact];

        EnhancedRelatedListFieldsUtility.ObjectData objectMetadata = EnhancedRelatedListFieldsUtility.getObjectMetadata('Case', testContact.Id, null, 'Subject', true, false);

        System.assertEquals('Case', objectMetadata.objectName, 'The ObjectName must be Case');
    }

    @IsTest
    static void testGetObjectMetadataError() {
        Contact testContact = [SELECT Id FROM Contact];

        try {
            EnhancedRelatedListFieldsUtility.getObjectMetadata('Cases', testContact.Id, null, 'Subject', true, false);
            System.assert(false, 'Expected the object metadata request to fail');
        } catch (AuraHandledException ex) {
            System.assert(true, 'Expected the object metadata request to fail');
        }
    }

    @IsTest
    static void testGetObjectMetadataFields() {
        Contact testContact = [SELECT Id FROM Contact];

        EnhancedRelatedListFieldsUtility.ObjectData objectMetadata = EnhancedRelatedListFieldsUtility.getObjectMetadata('Case', testContact.Id, null, 'Subject,AccountId,Contact.Name', true, false);

        System.assertEquals('Case', objectMetadata.objectName, 'The ObjectName must be Case');
        System.assertEquals(4, objectMetadata.fields.size(), 'The Object must have three fields');
    }

    @IsTest
    static void testGetObjectMetadataAggregate() {
        Contact testContact = [SELECT Id FROM Contact];

        EnhancedRelatedListFieldsUtility.ObjectData objectMetadata = EnhancedRelatedListFieldsUtility.getObjectMetadata('Case', testContact.Id, null, 'COUNT(Id),FORMAT(MAX(CreatedDate))', true, true);

        System.assertEquals('Case', objectMetadata.objectName, 'The ObjectName must be Case');
        System.assertEquals(2, objectMetadata.fields.size(), 'The Object must have two fields');
        System.assertEquals('COUNT', objectMetadata.fields[0].aggregateFunctions, 'The Object field must have the aggregate functions');
        System.assertEquals('FORMAT,MAX', objectMetadata.fields[1].aggregateFunctions, 'The Object field must have the aggregate functions');
    }
}