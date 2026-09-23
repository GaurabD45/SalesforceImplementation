public with sharing class Trigger_27_Handler {
    public static void updateRatingOnAccountBasedOnTotalOpportunityAmount(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if (oppList == null || oppList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        Map<Id, Decimal> accountToAmountMap = new Map<Id, Decimal>();
        List<Account> accList = new List<Account>();

        for (Opportunity opp : oppList) {

            if (oldMap == null) {
                if (opp.AccountId != null) accIds.add(opp.AccountId);
                continue;
            }

            Opportunity oldOpp = oldMap.get(opp.Id);

            if (oldOpp.Amount != opp.Amount && opp.AccountId != null) accIds.add(opp.AccountId);

            if (oldOpp.AccountId != opp.AccountId) {
                if (oldOpp.AccountId != null) accIds.add(oldOpp.AccountId);

                if (opp.AccountId != null) accIds.add(opp.AccountId);
            }
        }

        if (accIds.isEmpty()) return;

        for (AggregateResult res : [
            SELECT SUM(Amount) total, AccountId
            FROM Opportunity
            WHERE AccountId IN :accIds
            GROUP BY AccountId
        ]) {
            Id accId = (Id)res.get('AccountId');
            Decimal totalAmount = (Decimal)res.get('total');

            accountToAmountMap.put(accId, totalAmount);
        }

        for (Id accId : accIds) {
            Account acc = new Account(Id = accId);
            Decimal amount;
            
            if (!accountToAmountMap.containsKey(accId)) {
                acc.Rating = 'Cold';
                accList.add(acc);
                continue;
            }

            amount = accountToAmountMap.get(accId);

            if (amount > 100000) {
                acc.Rating = 'Hot';
            } 
            else if (amount > 50000) {
                acc.Rating = 'Warm';
            } 
            else {
                acc.Rating = 'Cold';
            }

            accList.add(acc);
        }

        if (!accList.isEmpty()) update accList;
    }
}