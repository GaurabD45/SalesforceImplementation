public with sharing class Trigger_47_Handler {
    public static void updateAccDescriptionWithHightestOppAmount(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if (oppList == null || oppList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        Map<Id, Decimal> accToHighestOppAmountMap = new Map<Id, Decimal>();
        List<Account> accList = new List<Account>();

        for (Opportunity opp : oppList) {
            if (oldMap == null) {
                if (opp.AccountId != null) accIds.add(opp.AccountId);
            } else {
                Opportunity oldOpp = oldMap.get(opp.Id);

                if (opp.Amount != oldOpp.Amount && opp.AccountId != null) {
                    accIds.add(opp.AccountId);
                }

                if (opp.AccountId != oldOpp.AccountId) {
                    if (opp.AccountId != null) accIds.add(opp.AccountId);
                    if (oldOpp.AccountId != null) accIds.add(oldOpp.AccountId);
                }
            }
        }

        if (accIds.isEmpty()) return;

        for (AggregateResult res : [
            SELECT AccountId, MAX(Amount) Total FROM Opportunity
            WHERE AccountId IN :accIds
            GROUP BY AccountId
        ]) {
            Id accId = (Id)res.get('AccountId');
            Decimal maxAmount = (Decimal)res.get('Total');

            accToHighestOppAmountMap.put(accId, maxAmount);
        }

        for (Id accId : accIds) {
            Account acc = new Account(Id = accId);

            Decimal amount = accToHighestOppAmountMap.get(accId);

            acc.Description = 'Maximum Opportunity Amount on this account is ' + amount == null ? 0 : amount + '.';

            accList.add(acc);
        }

        if (!accList.isEmpty()) update accList;
    }
}