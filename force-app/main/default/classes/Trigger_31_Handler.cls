public with sharing class Trigger_31_Handler {
    public static void updateAccRatingBasedOnRelatedClosedCases(List<Case> caseList, Map<Id, Case> oldMap) {
        if (caseList == null || caseList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        Map<Id, Integer> accToClosedCaseCount = new Map<Id, Integer>();
        List<Account> accList = new List<Account>();

        for (Case caseRec : caseList) {
            if (oldMap == null) { //for delete and undelete scenarios
                if (caseRec.IsClosed && caseRec.AccountId != null) accIds.add(caseRec.AccountId);
                continue; //skip to the next record, so the update logic does not execute
            }

            Case oldCase = oldMap.get(caseRec.Id);//update scenario

            if (oldCase.Status != caseRec.Status && (oldCase.IsClosed || caseRec.IsClosed) && caseRec.AccountId != null) {
                accIds.add(caseRec.AccountId);
            }

            if (caseRec.AccountId != oldCase.AccountId && (oldCase.IsClosed || caseRec.IsClosed)) {
                if (caseRec.AccountId != null) accIds.add(caseRec.AccountId);
                if (oldCase.AccountId != null) accIds.add(oldCase.AccountId);
            }
        }

        if (accIds.isEmpty()) return;

        for (AggregateResult res : [
            SELECT COUNT(Id), AccountId
            FROM Case
            WHERE Status = 'Closed' AND AccountId IN :accIds
            GROUP BY AccountId
        ]) {
            Id accId = (Id)res.get('AccountId');
            Integer count = (Integer)res.get('exp0'); //since we have not used alias, exp0 will get us the count(Id) field

            accToClosedCaseCount.put(accId,count);
        }

        for (Id accId : accIds) {
            Account acc = new Account(Id = accId);
            Integer closedCaseCount = accToClosedCaseCount.containsKey(accId)? accToClosedCaseCount.get(accId) : 0;
            
            if (closedCaseCount > 5) acc.Rating = 'Hot';
            else if (closedCaseCount > 2) acc.Rating = 'Warm';
            else acc.Rating = 'Cold';

            accList.add(acc);
        }

        if (!accList.isEmpty()) update accList;
    }
}