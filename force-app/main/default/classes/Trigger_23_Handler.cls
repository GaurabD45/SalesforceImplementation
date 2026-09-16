public with sharing class Trigger_23_Handler {
    public static void createOrUpdateTaskOnOpportunityStageChange(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        if (newMap == null || newMap.isEmpty()) {
            return;
        }

        Set<Id> oppIds = new Set<Id>();
        Map<Id, Task> opportunityToTaskMap = new Map<Id, Task>();
        List<Task> newTasks = new List<Task>();

        for (Id oppId : newMap.keySet()) {
            Opportunity newRec, oldRec;
            newRec = newMap.get(oppId);
            oldRec = oldMap.get(oppId);

            if (newRec.StageName != oldRec.StageName) {
                oppIds.add(oppId);
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

        for (Id oppId : oppIds) {
            Opportunity opp = newMap.get(oppId);
            Task tsk;

            if (opportunityToTaskMap.containsKey(oppId)) {
                tsk = opportunityToTaskMap.get(oppId);
                tsk.Description = opp.StageName;
            }
            else {
                tsk = new Task();
                tsk.Status = 'New';
                tsk.WhatId = oppId;
                tsk.Description = opp.StageName;
                tsk.Priority = 'Normal';
                tsk.ActivityDate = Date.today().addDays(7);
            }

            newTasks.add(tsk);
        }

        if (!newTasks.isEmpty()) {
            upsert newTasks;
        }

    }
}