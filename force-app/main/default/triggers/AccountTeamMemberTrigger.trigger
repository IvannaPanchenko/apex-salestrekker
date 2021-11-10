trigger AccountTeamMemberTrigger on AccountTeamMember (before delete,after delete) {

    if (Trigger.isAfter) {

        // Call to the HandlerClass method where advisor lookups are being handled
        AccountTeamMemberTriggerHandler.updateAdvisorLookupOnAccount(Trigger.oldMap);

    }else if(AccountTeamMemberTriggerHandler.runOnce()) {

        // Call to the HandlerClass Method where Account_Team_MemberRemoveOnDelete flow is being called
        AccountTeamMemberTriggerHandler.runFlow();
    }
}