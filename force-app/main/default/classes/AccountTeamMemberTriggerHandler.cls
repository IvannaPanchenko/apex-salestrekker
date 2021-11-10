public class AccountTeamMemberTriggerHandler {

    private static boolean run = true;
    public static boolean runOnce(){

        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }

    public AccountTeamMemberTriggerHandler(){

    }

    public static void runFlow() {

        for(AccountTeamMember actmbr : (List<AccountTeamMember>) Trigger.old){

            Flow.Interview flow = new Flow.Interview.Account_Team_MemberRemoveOnDelete(new map<String,Object>{'recordId' => actmbr.Id});

            flow.start();

        }
    }

    // Method for handling Mortage & Insurance Advisor lookups on TeamMember Removal
    public static void updateAdvisorLookupOnAccount(Map<Id,AccountTeamMember> oldMap){

        // Accounts to be updated where Team Member got removed
        List<Account> accountsToBeUpdated = new List<Account>();

        // Holds Account Record by account ID: account attached to the teamMember
        Map<Id,Account> mapAccountByAccountId = getMapAccountByAccountId(oldMap.values());

        // Apex Advise User which needs to be populated as an Advisor
        List<User> apexAdviceUser = [Select Id from User Where Name = 'Apex Advice' AND IsActive=true];

        // Iterate over the Teammembers which just got deleted
        For(AccountTeamMember accTeamMem : oldMap.values()){

            // if member was a Moratge,Investment OR Insurance and Investment Advisor
            if(accTeamMem.TeamMemberRole == 'Mortgage Advisor' || accTeamMem.TeamMemberRole == 'Investment Advisor' || accTeamMem.TeamMemberRole == 'Insurance and Investment Adviser'){

                mapAccountByAccountId.get(accTeamMem.accountId).Mortgage_Advisor__c = apexAdviceUser[0].Id;
                accountsToBeUpdated.add(mapAccountByAccountId.get(accTeamMem.accountId));

            }

        }

        if(accountsToBeUpdated.size() > 0){

            // Update accounts with Apex Advisor user

            update accountsToBeUpdated;

        }

    }

    public static Map<Id,Account> getMapAccountByAccountId(List<AccountTeamMember> accTeamMembers){

        // Set of AccountIds to query Accounts
        Set<Id> accountIds = New Set<Id>();

        for(AccountTeamMember ATM :accTeamMembers){
            //Add accountIds to the set
            accountIds.add(ATM.accountId);
        }

        // List of accounts attached to the teammember records being deleted
        List<Account> accounts = [SELECT Id,Investment_Adviser__c,Mortgage_Advisor__c from Account WHERE Id  IN :accountIds];

        Map<Id,Account> mapAccountByAccountId = new Map<Id,Account>();

        if(accounts.size() >0){

            for(Account acc :accounts){

                if(!mapAccountByAccountId.containsKey(acc.Id)){

                    mapAccountByAccountId.put(acc.Id, acc);

                }

            }
        }

        return mapAccountByAccountId;

    }


}