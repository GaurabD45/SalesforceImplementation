public with sharing class Trigger_44_Handler {
    public static void createTaskOnCase(List<Case> caseList, Map<Id, Case> oldMap) {
        if (caseList == null || caseList.isEmpty()) return;

        List<Case> cases = new List<Case>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, Id> accIdToConId = new Map<Id, Id>();
        List<Task> tskList = new List<Task>();

        for (Case caseRec : caseList) {
            Case oldCase = oldMap != null ? oldMap.get(caseRec.Id) : null;
            
            if (caseRec.AccountId != null && caseRec.Create_Task__c && (oldCase == null || !oldCase.Create_Task__c )) {
                cases.add(caseRec);
                accIds.add(caseRec.AccountId);
            }
        }

        if (cases.isEmpty()) return;

        for (Contact con : [
            SELECT Id, AccountId FROM Contact
            WHERE Primary_Contact__c = true AND AccountId IN :accIds
        ]){
            accIdToConId.put(con.AccountId, con.Id);
        }

        if (accIdToConId.isEmpty()) return;

        for (Case caseRec : cases) {
            Id conId = accIdToConId.get(caseRec.AccountId);

            Task tsk = new Task();
            tsk.WhoId = conId;
            tsk.WhatId = caseRec.Id;
            tsk.Status = 'Not Started';
            tsk.Subject = 'Follow Up';
            tsk.Priority = 'High';
            tsk.OwnerId = caseRec.OwnerId;
            tsk.ActivityDate = Date.today().addDays(3);

            tskList.add(tsk);
        }

        if (!tskList.isEmpty()) insert tskList;
    }
}