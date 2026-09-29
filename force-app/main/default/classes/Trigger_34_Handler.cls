public with sharing class Trigger_34_Handler {
    public static void updateAccDescAndTaskStatusOnCaseStatusUpdate(List<Case> caseList, Map<Id, Case> oldMap) {
        if (caseList == null || caseList.isEmpty() || oldMap == null || oldMap.isEmpty()) return;

        Set<Id> caseIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        List<Task> tskList = new List<Task>();
        List<Account> accList = new List<Account>();

        for (Case rec : caseList) {
            Case oldCase = oldMap.get(rec.Id);

            if (rec.Status != oldCase.Status) {
                if (rec.AccountId != null) accIds.add(rec.AccountId);
                caseIds.add(rec.Id);
            }
        }
        
        if (caseIds.isEmpty()) return;

        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, Description FROM Account WHERE Id IN :accIds 
            ]);
            

        for (Case rec : [
            SELECT Id, AccountId, Status, (
                SELECT Id, Status FROM Tasks 
                WHERE IsClosed = false
                ORDER BY LastModifiedDate DESC NULLS LAST
                LIMIT 1
            ) FROM Case
            WHERE Id IN :caseIds
        ]) {
            if (rec.AccountId != null) {
                Account acc = accMap.get(rec.AccountId);
                acc.Description = 'Case Id:' + rec.Id + 'status has been updated to' + rec.Status;
                accList.add(acc);
            }

            if (!rec.Tasks.isEmpty()) {
                Task tsk = rec.Tasks[0];
                tsk.Status = rec.Status;
                tskList.add(tsk);
            }
        }

        if (!accList.isEmpty()) update accList;
        if (!tskList.isEmpty()) update tskList;
    }
}