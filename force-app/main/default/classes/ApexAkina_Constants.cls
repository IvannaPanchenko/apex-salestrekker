/**
 ** Description: Utility class to capture global values
 ** Author: David Catindoy (david@cloudinit.nz)
 ** Date Created: Nov 15, 2017
 ** History:
 **/
public class ApexAkina_Constants {

    public static final String CLIENT_1 = 'Client 1';
    public static final String CLIENT_2 = 'Client 2';
    public static final String JOINT = 'Joint';
    public static final String BENEFICIARY = 'Beneficiary';
    public static final Integer DEPENDANT_UNTIL_AGE = 21;
    public static final Map<String, String> FAMILY_MEMBER_OPPOSITE_RELATIONSHIP_TYPE = new Map<String,String>{'Child' => 'Parent', 'Parent' => 'Child'};
    public static final String FAMILY_MEMBER_RELATIONSHIP_TYPE = 'Dependant';
    public static final String OTHERENTITIES_RELATIONSHIP_TYPE = 'Other Entity';
    public static final String ERROR_NOOPPTY = 'No opportunity record.';
    public static final String EXISTINGRISK_OPTION1 = 'You have no personal risk policies at this time';
    public static final String EXISTINGRISK_OPTION2 = 'You have indicated that you have current personal insurance policies that Apex does not advise on, and have completed the letter of authority to allow us access to these policies. (Please identify the Insurers in the Non-Apex Serviced Section)';
    public static final String EXISTINGRISK_OPTION3 = 'All Policies are serviced by Apex';
    public static final String EXISTINGRISK_OPTION4 = 'You have current personal insurance policies that Apex does not advise on';
    public static final Id ACC_BUSINESSRECTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider Account').getRecordTypeId();
    public static final Id ACC_CLIENTRECTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
    public static final Id ACC_BENEFICIARYRECTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ApexAkina_Constants.BENEFICIARY).getRecordTypeId();
    public static final Id ACC_LEGALENTITYRECTYPE = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
    public static final Id INCOME_RECTYPE = Schema.SObjectType.Income_and_Expense__c.getRecordTypeInfosByName().get('Income').getRecordTypeId();
    public static final Id EXPENSE_RECTYPE = Schema.SObjectType.Income_and_Expense__c.getRecordTypeInfosByName().get('Expenses').getRecordTypeId();
    public static final Id FINANCIAL_RECTYPE = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('Financial and Lifestyle').getRecordTypeId();
    public static final Id INVGOAL_RECTYPE = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('Investment Goals').getRecordTypeId();
    public static final Id NEEDS_RECTYPE = Schema.SObjectType.Analysis__c.getRecordTypeInfosByName().get('Needs').getRecordTypeId();
    public static final Id INVESTMENT_RECTYPE = Schema.SObjectType.Analysis__c.getRecordTypeInfosByName().get('Investment').getRecordTypeId();
    public static final Id TASKS_RECTYPE = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Tasks').getRecordTypeId();
    public static final Id MORTGAGE_RECTYPE = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Mortgage').getRecordTypeId();

    // benefit types
    public static final Set<String> benefitsTypes = new Set<String>{
        'Life',
        'TPD',
        'Trauma',
        'Income Protection',
        'Health',
        'Business Expenses'
    };

    public static final Map<ApexPages.Severity, String> severityToThemeMap = new Map<ApexPages.Severity, String> {
        ApexPages.Severity.CONFIRM  => 'success',
        ApexPages.Severity.ERROR    => 'error',
        ApexPages.Severity.FATAL    => 'error',
        ApexPages.Severity.INFO     => 'info',
        ApexPages.Severity.WARNING  => 'warning'
    };

    //Type Opps
    public static final String MORTGAGE ='Mortgage';
    public static final String INSURANCE ='Insurance';
    public static final String EXTERNAL_REFERRAL ='External Referral';

    //Stage Opps
    public static final String STAGE_BUSINESS_SETTLED ='Business Settled';
    public static final String STAGE_NO_OPPORTUNITY ='No Opportunity';

    // HTTP CONSTANTS
    public static final Integer HTTP_SUCCESS =200;
    public static final Integer HTTP_ERROR = 400;
    

    // Exception Event 
    public static final String DEAL_CREATED ='DealCreated';
    public static final String DEAL_UPDATED ='DealUpdated';
    public static final String DEAL_CHANGE_STAGE ='DealChangesStage';
    public static final String DEAL_RETRIEVED ='DealRetrieved';
    public static final String CONTACT_CREATED ='ContactCreated';
    public static final String SEV_HIGH ='High';
    public static final String SEV_LOW ='Low';

    // Labels Type Names

    public static final String CLIENT = 'Client';
    
}