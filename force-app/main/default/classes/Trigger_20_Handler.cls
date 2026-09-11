public with sharing class Trigger_20_Handler {
    public static void recalculateTotalOpportunityLineItemsOnAccount(List<OpportunityLineItem> oliList, List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if ((oliList == null || oliList.isEmpty()) && (oppList == null || oppList.isEmpty())) {
            return;
        }

        Set<Id> oppIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, Integer> accToOliCount = new Map<Id, Integer>();
        List<Account> accList = new List<Account>();

        if (oliList != null) {
            for (OpportunityLineItem oliRec : oliList) {
                oppIds.add(oliRec.OpportunityId);
            }

            if (!oppIds.isEmpty()) {
                for (Opportunity opp : [
                    SELECT Id, AccountId
                    FROM Opportunity
                    WHERE Id IN :oppIds
                ]) {
                    if (opp.AccountId != null) {
                        accIds.add(opp.AccountId);
                    }
                }
            }
        }
        
        if (oppList != null) {
            for (Opportunity opp : oppList) {
                Opportunity oldOpp = oldMap.get(opp.Id);

                if (opp.AccountId != oldOpp.AccountId){
                    if (opp.AccountId != null) {
                        accIds.add(opp.AccountId);
                    }
                    
                    if (oldOpp.AccountId != null) {
                        accIds.add(oldOpp.AccountId);
                    }
                }
            }
        }


        if (!accIds.isEmpty()) {
            for (AggregateResult res : [
                SELECT count(Id) total, Opportunity.AccountId accId
                FROM OpportunityLineItem
                WHERE Opportunity.AccountId IN :accIds
                GROUP BY Opportunity.AccountId
            ]) {
                Id accountId = (Id)res.get('accId');
                Integer count = (Integer)res.get('total');

                accToOliCount.put(accountId, count);
            }

            for (Id accId : accIds) {
                Account acc = new Account(Id = accId);

                if (accToOliCount.containsKey(accId)) {
                    acc.Total_Opportunity_Products__c = accToOliCount.get(accId);
                } else {
                    acc.Total_Opportunity_Products__c = 0;
                }

                accList.add(acc);
            }

            if (!accList.isEmpty()){
                update accList;
            }
        }
    }
}