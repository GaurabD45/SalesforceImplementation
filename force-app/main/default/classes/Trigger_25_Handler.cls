public with sharing class Trigger_25_Handler {
    public static void syncAccountDescriptionWithLatestModifiedOpportunityLineItemDescription(List<OpportunityLineItem> oliList) {
        if (oliList == null || oliList.isEmpty()) {
            return;
        }

        Set<Id> oppIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, String> accToOpportunityLineItemDescriptionMap = new Map<Id, String>();
        List<Account> accList = new List<Account>();

        for (OpportunityLineItem oli : oliList) {
            oppIds.add(oli.OpportunityId);
        }

        for (Opportunity opp : [
            SELECT Id, AccountId
            FROM Opportunity
            WHERE Id IN :oppIds
        ]){
            if (opp.AccountId == null) {
                continue;
            }
            accIds.add(opp.AccountId);
        }

        if (accIds.isEmpty()) {
            return;
        }

        for (OpportunityLineItem oli : [
            SELECT Id, Description, Opportunity.AccountId
            FROM OpportunityLineItem 
            WHERE Opportunity.AccountId IN :accIds
            ORDER BY LastModifiedDate DESC NULLS LAST
        ]) {
            Id accId = oli.Opportunity.AccountId;

            if (accToOpportunityLineItemDescriptionMap.containsKey(accId)) {
                continue;
            }

            if (String.isBlank(oli.Description)) {
                accToOpportunityLineItemDescriptionMap.put(accId, '');    
            } else {
                accToOpportunityLineItemDescriptionMap.put(accId, oli.Description);
            }
        }

        for (Id accId : accIds) {
            Account acc = new Account(Id = accId);
            String description;
            
            if (!accToOpportunityLineItemDescriptionMap.containsKey(accId)) {
                acc.Description = 'There is no Opportunity Product associated with this Account.';    
                accList.add(acc);
                continue;
            }

            description = accToOpportunityLineItemDescriptionMap.get(accId);

            if (String.isNotBlank(description)) {
                acc.Description = description;
            } else {
                acc.Description = 'The Opportunity Product has no description';
            }

            accList.add(acc);
        }

        if (!accList.isEmpty()) {
            update accList;
        }
    }
}