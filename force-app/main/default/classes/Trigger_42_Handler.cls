public with sharing class Trigger_42_Handler {
    public static void preventAccountDeactivation(List<Account> accList, Map<Id, Account> oldMap) {
        if (accList == null || accList.isEmpty() || oldMap == null || oldMap.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();

        for (Account acc : accList) {
            Account oldAcc = oldMap.get(acc.Id);

            if (acc.Active__c == 'No' && oldAcc.Active__c != 'No') {
                accIds.add(acc.Id);
            }
        }

        if (accIds.isEmpty()) return;

        for (Account acc : [
            SELECT Id, (SELECT Id FROM Contacts WHERE IsActive__c = true LIMIT 1)
            FROM Account WHERE Id IN :accIds
        ]) {
            if (acc.Contacts.isEmpty()) {
                acc.addError('Cannot deactivate an account with an active Contact.');
            }
        }
    }
}