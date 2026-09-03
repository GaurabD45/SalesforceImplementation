public with sharing class Trigger_16_Handler {

    public static void updateAccountDescriptionWithHighestAmountOpportunityName(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if (oppList.isEmpty()) {
            return;
        }

        Set<Id> accIds = new Set<Id>();
        Map<Id, Opportunity> accountToOpportunityMap = new Map<Id, Opportunity>();
        List<Account> accList = new List<Account>();
        
        //collecting Account Ids
        for (Opportunity opp : oppList) {
            //update scenario
            if (oldMap != null) {
                Opportunity oldOpp = oldMap.get(opp.Id);
                //Scenario 1 : When Amount is updated
                if (opp.Amount != oldOpp.Amount) {
                    if (opp.AccountId != null ) accIds.add(opp.AccountId);
                }
                //Scenario 2 : When Parent(AccountId) is Updated 
                if (opp.AccountId != oldOpp.AccountId) {
                    if (opp.AccountId != null ) accIds.add(opp.AccountId);

                    if (oldOpp.AccountId != null ) accIds.add(oldOpp.AccountId);
                }
            } 
            //insert, delete, undelete scenarios
            else {
                if (opp.AccountId != null) accIds.add(opp.AccountId);
            }
        }

        //fetching all Opportunities and sorting them in decreasing order as per their amount
        //and populating out account opp map
        for (Opportunity opp : [
            SELECT Id, Name, AccountId, Amount FROM Opportunity
            WHERE AccountId IN :accIds
            ORDER BY Amount DESC NULLS LAST
        ]) {
            if (!accountToOpportunityMap.containsKey(opp.AccountId)) {
                accountToOpportunityMap.put(opp.AccountId, opp);
            }
        }

        //updating Account Description
        for (Id accId : accIds) {
            Account acc = new Account(Id = accId);

            if (accountToOpportunityMap.containsKey(accId)) {
                Opportunity opp = accountToOpportunityMap.get(accId);
                acc.Description = opp.Name + ' has the highest amount.';
            } else {
                acc.Description = 'No opportunity exits on this account.';
            }

            accList.add(acc);
        }

        if (!accList.isEmpty()) {
            update accList;
        }
    }
}