public with sharing class Trigger_9_Handler {
    public static void preventActiveAccDeletion(List<Account> accList) {

        if (accList.isEmpty()) {
            return;
        }

        for (Account acc : accList) {
            if (acc.Active__c == 'Yes') {
                acc.addError('Cannot delete active accounts!');
            }
        }
    }
}