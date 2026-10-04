public with sharing class Trigger_41_Handler {
    public static void populateMaxClosedOppAmountOnAccount(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if (oppList == null || oppList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        Map<Id, Decimal> accToMaxAmountMap = new Map<Id, Decimal>();
        List<Account> accList = new List<Account>();

        for (Opportunity opp : oppList) {
            if (oldMap == null) {
                if (opp.Status == 'Closed Won' && opp.AccountId != null) {
                    accIds.add(opp.AccountId);
                }
                continue;
            }

            Opportunity oldOpp = oldMap.get(opp.Id);

            if ((opp.Status == 'Closed Won' || oldOpp.Status == 'Closed Won') && (opp.Status != oldOpp.Status || opp.AccountId != oldOpp.AccountId) ) {

                if (opp.AccountId != null) accIds.add(opp.AccountId);
                if (oldOpp.AccountId != null) accIds.add(oldOpp.AccountId);
            }

            if (opp.Amount != oldOpp.Amount && opp.Status == 'Closed Won' && opp.AccountId != null) accIds.add(opp.AccountId);
        }

        if (accIds.isEmpty()) return;

        for (Opportunity opp : [
            SELECT Id, Amount, AccountId FROM Opportunity
            WHERE AccountId IN : accIds AND Status = 'Closed Won'
            ORDER BY Amount DESC NULLS LAST
        ]) {
            if (accToMaxAmountMap.containsKey(opp.AccountId)) continue;

            accToMaxAmountMap.put(opp.AccountId, opp.Amount);
        }

        for (Id accId : accIds) {
            Account acc = new Account(Id = accId);
            acc.Max_Closed_Opportunity_Amount__c = accToMaxAmountMap.containsKey(accId) ? accToMaxAmountMap.get(accId) : 0;

            accList.add(acc);        
        }

        if (!accList.isEmpty()) update accList;
    }
}