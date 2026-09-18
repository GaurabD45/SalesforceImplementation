public with sharing class Trigger_24_Handler {
    public static void populateOppLineItemCountOnAcc(List<OpportunityLineItem> oliList) {
        if (oliList == null || oliList.isEmpty()) {
            return;
        }

        Set<Id> oppIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, Integer> accToOliCountMap = new Map<Id, Integer>();
        List<Account> accList = new List<Account>();

        //collecting oppIds
        //insert, delete, undelete
        //no update scenario since ListPrice cannot be changed when a product has been added
        /*we can also include the scenario when AccountId on Opportunity is update, which is not
        included here*/
        for (OpportunityLineItem oli : oliList) {
            if (oli.ListPrice > 50000) {
                oppIds.add(oli.OpportunityId);
            }
        }

        if (oppIds.isEmpty()) {
            return;
        }

        for (Opportunity opp : [
            SELECT Id, AccountId
            FROM Opportunity
            WHERE Id IN :oppIds
        ]) {
            if (opp.AccountId != null) {
                accIds.add(opp.AccountId);
            }
        }

        if (accIds.isEmpty()) {
            return;
        }

        for (AggregateResult res : [
            SELECT count(Id) total, Opportunity.AccountId accountId
            FROM OpportunityLineItem
            WHERE Opportunity.AccountId IN :accIds AND ListPrice > 50000
            GROUP BY Opportunity.AccountId
        ]) {
            Id accId = (Id)res.get('accountId');
            Integer count = (Integer)res.get('total');

            accToOliCountMap.put(accId, count);
        }

        for (Id accId : accIds) {
            Account acc = new Account(Id = accId);
            acc.Description = 'Total Opportunity Product associated with this account = ';

            if (accToOliCountMap.containsKey(accId)) {
                acc.Description += accToOliCountMap.get(accId) + '.';
            } else {
                acc.Description += '0.';
            }

            accList.add(acc);
        }

        if (!accList.isEmpty()) {
            update accList;
        }
    }
}