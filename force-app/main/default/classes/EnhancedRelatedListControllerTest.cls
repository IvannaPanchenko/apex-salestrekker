/**
 * @author       Pablo Martinez (pablomartinez@deloitte.co.nz)
 * @date         2019-06-20
 * @description  
 * 
 **/
@IsTest
private class EnhancedRelatedListControllerTest {
    @IsTest
    static void testGetRecords() {
        Contact testContact = new Contact(FirstName='Test', LastName='Name');
        insert testContact;

        Case testCase = new Case(Subject='Test Case', ContactId=testContact.Id);
        insert testCase;

        Object recordsObject = EnhancedRelatedListController.getRecords(testContact.Id, 'Case', 'ContactId', 'Subject', null, null, 'Subject ASC', 1);
        List<SObject> records = (List<SObject>) JSON.deserialize(JSON.serialize(recordsObject), List<SObject>.class);

        System.assertEquals(1, records.size(), 'Must return 1 record.');
        System.assertEquals(testCase.Subject, records[0].get('Subject'), 'The Subject must be ' + testCase.Subject);
    }

    @IsTest
    static void testGetRecordsWhereCondition() {
        Contact testContact = new Contact(FirstName='Test', LastName='Name');
        insert testContact;

        Case testCase = new Case(Subject='Test Case', ContactId=testContact.Id);
        insert testCase;

        Object recordsObject = EnhancedRelatedListController.getRecords(testContact.Id, 'Case', 'ContactId', 'Subject', 'Subject IN [[EnhancedRelatedListQueryAbstractTest]]', null, 'Subject ASC', 1);
        List<SObject> records = (List<SObject>) JSON.deserialize(JSON.serialize(recordsObject), List<SObject>.class);

        System.assertEquals(1, records.size(), 'Must return 1 record.');
        System.assertEquals(testCase.Subject, records[0].get('Subject'), 'The Subject must be ' + testCase.Subject);
    }
}