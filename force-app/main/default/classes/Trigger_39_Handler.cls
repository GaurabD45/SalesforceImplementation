public with sharing class Trigger_39_Handler {
    public static void createFollowUpTaskOnPrimaryContact(List<Case> caseList, Map<Id, Case> oldMap) {
        if (caseList == null || caseList.isEmpty()) return;

        List<Case> cases = new List<Case>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, Id> accToConMap = new Map<Id, Id>();
        List<Task> tskList = new List<Task>();

        for (Case caseRec : caseList) {
            if (oldMap == null) {
                if (caseRec.Escalation_Required__c && caseRec.AccountId != null) {
                    cases.add(caseRec);
                    accIds.add(caseRec.AccountId);
                    continue;
                }
            }

            Case oldCase = oldMap.get(caseRec.Id);

            if (caseRec.Escalation_Required__c  && !oldCase.Escalation_Required__c && caseRec.AccountId != null) {
                cases.add(caseRec);
                accIds.add(caseRec.AccountId);
            }
        }

        if (cases.isEmpty()) return;

        for (Contact con : [
            SELECT Id, AccountId
            FROM Contact
            WHERE AccountId IN :accIds AND Primary_Contact__c = true
        ]) {
            if (!accToConMap.containsKey(con.AccountId)) {
                accToConMap.put(con.AccountId, con.Id);
            }
        }

        if (accToConMap.isEmpty()) return;

        for (Case caseRec : cases) {
            Id conId = accToConMap.get(caseRec.AccountId);

            if (conId == null) continue;

            Task tsk = new Task();
            tsk.WhoId = conId;
            tsk.WhatId = case.Id;
            tsk.Subject = 'Follow Up';
            tsk.Status = 'Not Started';
            tsk.Priority = 'High';
            tsk.ActivityDate = Date.today().addDays(4);
            tsk.OwnerId = caseRec.OwnerId;

            tskList.add(tsk);
        }

        if (!tskList.isEmpty()) insert tskList;
    }
}