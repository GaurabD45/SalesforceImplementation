public with sharing class Trigger_23_Handler {
    public static void createOrUpdateTaskOnOpportunityStageChange(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if (oppList == null || oppList.isEmpty()) {
            return;
        }

        Set<Id> oppIds = new Set<Id>();
        Map<Id, Task> opportunityToTaskMap = new Map<Id, Task>();
        List<Task> newTasks = new List<Task>();

        for (Opportunity oppRec : oppList) {
            Opportunity oldRec = oldMap.get(oppRec.Id);

            if (oppRec.StageName != oldRec.StageName) {
                oppIds.add(oppRec.Id);
            }
        }

        if (oppIds.isEmpty()) {
            return;
        }

        for (Task tsk : [
            SELECT Id, WhatId, Description
            FROM Task
            WHERE WhatId IN :oppIds AND Status != 'Completed'
            ORDER BY LastModifiedDate DESC NULLS LAST
        ]) {
            if (opportunityToTaskMap.containsKey(tsk.WhatId)) {
                continue;
            }

            opportunityToTaskMap.put(tsk.WhatId, tsk);
        }

        for (Opportunity oppRec : oppList) {
            if (!oppIds.contains(oppRec.Id)) {
                continue;
            }

            Task tsk;

            if (opportunityToTaskMap.containsKey(oppRec.Id)) {
                tsk = opportunityToTaskMap.get(oppRec.Id);
                tsk.Description = oppRec.StageName;
            }
            else {
                tsk = new Task();
                tsk.Status = 'New';
                tsk.WhatId = oppRec.Id;
                tsk.Description = oppRec.StageName;
                tsk.Priority = 'Normal';
                tsk.ActivityDate = Date.today().addDays(7);
                tsk.OwnerId = UserInfo.getUserId();
                tsk.Subject = 'Follow Up';
            }

            newTasks.add(tsk);
        }

        if (!newTasks.isEmpty()) {
            upsert newTasks;
        }
    }
}