public with sharing class Trigger_8_Handler {
    public static void recalculateOppAmountSumAndUpdateAccDesc(List<Opportunity> oppList, Map<Id, Opportunity> oldOppMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Decimal> accToOppAmountMap = new Map<Id, Decimal>();
        List<Account> updatedAccList = new List<Account>();

        if (!oppList.isEmpty()) {
            for (Opportunity opp : oppList) {
                //update
                if (oldOppMap != null) {
                    Opportunity oldOpp = oldOppMap.get(opp.Id);

                    if (opp.AccountId != oldOpp.AccountId) {
                        if (opp.AccountId != null) accIds.add(opp.AccountId);
                        if (oldOpp.AccountId != null) accIds.add(oldOpp.AccountId);
                        
                    } else if (opp.Amount != oldOpp.Amount && opp.AccountId != null) {
                        accIds.add(opp.AccountId);
                    }
                } else {
                    //insert , delete, undelete
                    if (opp.AccountId != null) accIds.add(opp.AccountId);
                }
            }

            if (!accIds.isEmpty()) {
                for (Id accId : accIds) {
                    accToOppAmountMap.put(accId, 0.0);
                }

                for (AggregateResult res : [SELECT AccountId, SUM(Amount) total FROM Opportunity WHERE AccountId IN :accIds GROUP BY AccountId]) {
                    Id accId = (Id)res.get('AccountId');
                    Decimal totalAmount = (Decimal)res.get('total');

                    accToOppAmountMap.put(accId, totalAmount);
                }

                for (Id accId : accToOppAmountMap.keySet()) {
                    Account acc = new Account();
                    Decimal totalAmount = accToOppAmountMap.get(accId);

                    acc.Id = accId;
                    acc.Description = 'Total Opportunity Amount: ' + totalAmount;

                    updatedAccList.add(acc);
                }

                if (!updatedAccList.isEmpty()) {
                    update updatedAccList;
                }
            }

        }
    }
}