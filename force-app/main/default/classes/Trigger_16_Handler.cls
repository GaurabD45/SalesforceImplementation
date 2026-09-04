public with sharing class Trigger_16_Handler {

    public static void updateAccountDescriptionWithHighestAmountOpportunityName(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if (oppList.isEmpty()) {
            return;
        }

        Set<Id> accIds = new Set<Id>();
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

        for (Account acc : [
            SELECT Id, Description, (SELECT Id, Name, Amount FROM Opportunities
            ORDER BY Amount DESC NULLS LAST LIMIT 1) FROM Account
            WHERE Id IN :accIds
        ]) {

            if (!acc.Opportunities.isEmpty()) {
                acc.Description = acc.Opportunities[0].Name + ' has the highest Amount.';
            }
            else {
                acc.Description = 'No Opportunities exist on this account.';
            }

            accList.add(acc);
        }

        if (!accList.isEmpty()) {
            update accList;
        }
    }
}