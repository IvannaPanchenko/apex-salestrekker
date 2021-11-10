/**
* @author David (david@cloudinit.nz)
* @date Oct 9, 2017
* @description Invocable action to update service fields.
*
* CHANGE LOG
* 08/04/19 - Chris Parker - Removed Mortgage newsletter functionality
**/
public class ChangeCategory {

    /**
    *   @author David Catindoy(david@cloudinit.nz)
    *   @description Used by Account_Client Service Standards PB.
    *                This method will update service fields.
    **/
    @InvocableMethod(label='Update Service Fields')
    public static void updateServiceStandardFields(List<Account> newAccounts) {
        String optIn = Label.Service_Opt_In_Value;
        String optOut = Label.Service_Opt_Out_Value;
        String serviceSchedule = Label.Service_Schedule_Value;
        String notApplicable = Label.Service_Not_Applicable;

        //List<Account> accountList = new List<Account>([SELECT Id, Category__pc, WelcomeLetter__pc, ApexMortgage_Newsletter__pc, ApexQuarterly_Newsletter__pc, Economic_Update__pc,
        //                                              Annual_Phone_Call__pc, Sale_Completed_Follow_up_Call__pc, Annual_Email_Letter__pc, Apex_Desktop_Calendar__pc,
        //                                              AssistanceOnClaim__pc, Courtesy_TelephoneCall__pc, Newsletters__c, End_of_the_Year_Email__pc FROM Account WHERE Id IN :accountIds]);
        for(Account accRec : newAccounts){
            //accRec.WelcomeLetter__pc = accRec.WelcomeLetter__pc != optOut ? serviceSchedule : accRec.WelcomeLetter__pc;
            accRec.AssistanceOnClaim__pc = accRec.AssistanceOnClaim__pc != optIn && accRec.AssistanceOnClaim__pc != optOut ? serviceSchedule : accRec.AssistanceOnClaim__pc;

            //accRec.ApexMortgage_Newsletter__pc = accRec.ApexMortgage_Newsletter__pc != optIn && accRec.ApexMortgage_Newsletter__pc != optOut ? notApplicable : accRec.ApexMortgage_Newsletter__pc;
            accRec.Economic_Update__pc = accRec.Economic_Update__pc != optIn && accRec.Economic_Update__pc != optOut ? notApplicable : accRec.Economic_Update__pc;

            if(accRec.Category__pc != 'E'){
                //accRec.Newsletters__c =
                accRec.ApexQuarterly_Newsletter__pc = accRec.ApexQuarterly_Newsletter__pc == notApplicable || String.isBlank(accRec.ApexQuarterly_Newsletter__pc) ? serviceSchedule : accRec.ApexQuarterly_Newsletter__pc;
                accRec.Sale_Completed_Follow_up_Call__pc = accRec.Sale_Completed_Follow_up_Call__pc == notApplicable || String.isBlank(accRec.Sale_Completed_Follow_up_Call__pc) ? serviceSchedule : accRec.Sale_Completed_Follow_up_Call__pc;
                accRec.End_of_the_Year_Email__pc = accRec.End_of_the_Year_Email__pc == notApplicable || String.isBlank(accRec.End_of_the_Year_Email__pc) ? serviceSchedule : accRec.End_of_the_Year_Email__pc;
            } else{
                accRec.ApexQuarterly_Newsletter__pc = accRec.ApexQuarterly_Newsletter__pc == serviceSchedule || String.isBlank(accRec.ApexQuarterly_Newsletter__pc) ? notApplicable : accRec.ApexQuarterly_Newsletter__pc;
                accRec.Sale_Completed_Follow_up_Call__pc = accRec.Sale_Completed_Follow_up_Call__pc == serviceSchedule || String.isBlank(accRec.Sale_Completed_Follow_up_Call__pc) ? notApplicable : accRec.Sale_Completed_Follow_up_Call__pc;
                accRec.End_of_the_Year_Email__pc = accRec.End_of_the_Year_Email__pc == serviceSchedule || String.isBlank(accRec.End_of_the_Year_Email__pc) ? notApplicable : accRec.End_of_the_Year_Email__pc;
            }

            if(accRec.Category__pc != 'D' && accRec.Category__pc != 'E'){
                accRec.Annual_Phone_Call__pc = accRec.Annual_Phone_Call__pc == notApplicable || String.isBlank(accRec.Annual_Phone_Call__pc) ? serviceSchedule : accRec.Annual_Phone_Call__pc;
                accRec.Apex_Desktop_Calendar__pc = accRec.Apex_Desktop_Calendar__pc == notApplicable || String.isBlank(accRec.Apex_Desktop_Calendar__pc) ? serviceSchedule : accRec.Apex_Desktop_Calendar__pc;
            } else{
                accRec.Annual_Phone_Call__pc = accRec.Annual_Phone_Call__pc == serviceSchedule || String.isBlank(accRec.Annual_Phone_Call__pc) ? notApplicable : accRec.Annual_Phone_Call__pc;
                accRec.Apex_Desktop_Calendar__pc = accRec.Apex_Desktop_Calendar__pc == serviceSchedule || String.isBlank(accRec.Apex_Desktop_Calendar__pc) ? notApplicable : accRec.Apex_Desktop_Calendar__pc;
            }

            if(accRec.Category__pc == 'D'){
                accRec.Annual_Email_Letter__pc = accRec.Annual_Email_Letter__pc == notApplicable || String.isBlank(accRec.Annual_Email_Letter__pc) ? serviceSchedule : accRec.Annual_Email_Letter__pc;
            } else{
                accRec.Annual_Email_Letter__pc = accRec.Annual_Email_Letter__pc == serviceSchedule || String.isBlank(accRec.Annual_Email_Letter__pc) ? notApplicable : accRec.Annual_Email_Letter__pc;
            }
        }
    }
}