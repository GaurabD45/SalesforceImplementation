public with sharing class Trigger_37_Handler {
    public static void validateOpportunityContactRole(List<OpportunityContactRole> oppConRoleList) {
        if (oppConRoleList == null || oppConRoleList.isEmpty()) return;

        Set<Id> oppIds = new Set<Id>();
        Set<String> newRoles = new Set<String>();

        for (OpportunityContactRole oppRole : oppConRoleList) {
            oppIds.add(oppRole.OpportunityId);
        }

        if (oppIds.isEmpty()) return;

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity> ([
            SELECT Id, IsClosed, (
                SELECT Id, ContactId, OpportunityId FROM OpportunityContactRoles
            ) FROM Opportunity WHERE Id IN :oppIds
        ]);

        for (OpportunityContactRole oppRole : oppConRoleList) {
            Opportunity opp = oppMap.get(oppRole.OpportunityId);
            String key = opp.Id + '-' + oppRole.ContactId;
            Boolean errorDetected = false;

            if (opp.IsClosed) {
                oppRole.addError('Cannot add Opportunity Contact Role on a closed opportunity.');
            } 
            else {
                for (OpportunityContactRole ocr : opp.OpportunityContactRoles) {
                    if (ocr.ContactId == oppRole.ContactId) {
                        oppRole.addError('Cannot add duplicate Opportunity Contact Role.');
                        errorDetected = true;
                        break;
                    }
                }

                if (errorDetected) continue;

                if (newRoles.contains(key)) {
                    oppRole.addError('Opportunity Contact Role has been added.');
                    continue;
                } else {
                    newRoles.add(key);
                }
            }
        }
    }
}