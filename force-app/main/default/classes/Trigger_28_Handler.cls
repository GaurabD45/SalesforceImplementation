public with sharing class Trigger_28_Handler {
    public static void calculateNewWorkingEscalatedCaseCountonAccount(List<Case> caseList, Map<Id,Case> oldMap) {
        if (caseList == null || caseList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        Map<String, Integer> accCaseStatusToCountMap = new Map<String, Integer>();
        List<Account> accList = new List<Account>();

        for (Case caseRec : caseList) {

            if (oldMap == null) {
                if (caseRec.AccountId != null) accIds.add(caseRec.AccountId);
                continue;
            }

            Case oldCase = oldMap.get(caseRec.Id);

            if (caseRec.Status != oldCase.Status && caseRec.AccountId != null) accIds.add(caseRec.AccountId);

            if (caseRec.AccountId != oldCase.AccountId) {
                if (caseRec.AccountId != null) accIds.add(caseRec.AccountId);
                if (oldCase.AccountId != null) accIds.add(oldCase.AccountId);
            }
        }

        if (accIds.isEmpty()) return;

        for (AggregateResult res : [
            SELECT COUNT(Id) total, AccountId, Status FROM Case
            WHERE AccountId IN :accIds AND Status IN ('New', 'Working', 'Escalated')
            GROUP BY AccountId, Status
        ]) {
            Id accId = (Id)res.get('AccountId');
            String status = (String)res.get('Status');
            Integer count = (Integer)res.get('total');

            accCaseStatusToCountMap.put(accId + status, count);
        }

        for (Id accId : accIds) {

            Account acc = new Account(Id = accId);

            if (accCaseStatusToCountMap.containsKey(accId+'New')) {
                acc.New_Cases__c = accCaseStatusToCountMap.get(accId+'New');
            } else {
                acc.New_Cases__c = 0;
            }

            if (accCaseStatusToCountMap.containsKey(accId+'Working')) {
                acc.Working_Cases__c = accCaseStatusToCountMap.get(accId+'Working');
            } else {
                acc.Working_Cases__c = 0;
            }

            if (accCaseStatusToCountMap.containsKey(accId+'Escalated')) {
                acc.Escalated_Cases__c = accCaseStatusToCountMap.get(accId+'Escalated');
            } else {
                acc.Escalated_Cases__c = 0;
            }

            accList.add(acc);
        }

        if (!accList.isEmpty()) update accList;
    }
}