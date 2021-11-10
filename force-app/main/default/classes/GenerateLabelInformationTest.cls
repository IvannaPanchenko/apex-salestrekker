/*************************************************************************************************************
 * @name			GenerateLabelInformationTest
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			14th October 2021
 * @description		Test Class for GenerateLabelInformation Invocable
 * @testClass       GenerateLabelInformationTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-14      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/
@isTest
public with sharing class GenerateLabelInformationTest {
    @IsTest(SeeAllData=true)
    static void testGetLabelsIdsList () {

        
        List<Salestrekker_Label__mdt> labels = [SELECT Label_Name__c, Label_Id__c FROM Salestrekker_Label__mdt ];

        List<String> ids = new List<String>();
        Integer count=0;
        for(Salestrekker_Label__mdt lb:labels ){

            ids.add(lb.Label_Id__c);
            count= count+1;
        }

        String joinIds = String.join(ids,',');

        GenerateLabelInformation.Input input = new GenerateLabelInformation.Input();

        input.labelsIds = joinIds;

        List<GenerateLabelInformation.Input> inputs = new List<GenerateLabelInformation.Input>();
        inputs.add(input);

        Test.startTest();

            List<GenerateLabelInformation.ResultOutput> results = GenerateLabelInformation.getLabelsIdsList(inputs);

        Test.stopTest();
        GenerateLabelInformation.ResultOutput result = !results?.isEmpty() ? results.get(0): null;
        System.assert(result != null);
        System.assertEquals(result.flowsOutput.size(), count );
        System.assert(String.isNotBlank(result.providerNames));
    }
}