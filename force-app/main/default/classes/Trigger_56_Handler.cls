public with sharing class Trigger_56_Handler {
    public static void updateAccDescWithSecondHighestOppAmount(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if (oppList == null || oppList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        Map<Id, Decimal> accToHighestOppAmount = new Map<Id, Decimal>();
        Map<Id, Decimal> accToSecondHighestOppAmount = new Map<Id, Decimal>();
        List<Account> accList = new List<Account>();

        for (Opportunity opp : oppList) {
            if (oldMap == null) {
                if (opp.AccountId != null && opp.Amount != null) {
                    accIds.add(opp.AccountId);
                }
            } else {
                Opportunity oldOpp = oldMap.get(opp.Id);

                if (oldOpp.AccountId != opp.AccountId) {
                    if (oldOpp.AccountId != null) accIds.add(oldOpp.AccountId);
                    if (opp.AccountId != null) accIds.add(opp.AccountId);
                } else if (opp.AccountId != null && opp.Amount != oldOpp.Amount) {
                    accIds.add(opp.AccountId);
                }
            }
        }

        if (accIds.isEmpty()) return;

        for (AggregateResult res : [
            SELECT AccountId, MAX(Amount) maxAmount FROM Opportunity
            WHERE AccountId IN :accIds
            GROUP BY AccountId
        ]) {
            Id accId = (Id)res.get('AccountId');
            Decimal amount = (Decimal)res.get('maxAmount');

            accToHighestOppAmount.put(accId, amount);
        }

        for (Opportunity opp : [
            SELECT Id, Amount, AccountId FROM Opportunity
            WHERE AccountId IN :accIds AND Amount != null
            ORDER BY Amount DESC
        ]) {
            Decimal maxAmount = accToHighestOppAmount.get(opp.AccountId);

            if (opp.Amount < maxAmount && !accToSecondHighestOppAmount.containsKey(opp.AccountId)) {
                accToSecondHighestOppAmount.put(opp.AccountId, opp.Amount);
            }
        }

        for (Id accId : accIds) {
            Account acc = new Account(Id = accId);
            String amount = 'N/A';

            if (accToSecondHighestOppAmount.containsKey(accId)) {
                amount = String.valueOf(accToSecondHighestOppAmount.get(accId));
            }

            acc.Description = 'Second highest opportunity amount : ' + amount;

            accList.add(acc);
        }

        if (!accList.isEmpty()) update accList;
    }
}