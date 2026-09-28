public with sharing class Trigger_33_Handler {
    public static void syncContactTypeWithAccountType(List<Contact> conList) { //before insert
        if (conList == null || conList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();

        for (Contact con : conList) {
            if (con.AccountId != null) accIds.add(con.AccountId);
        }

        if (accIds.isEmpty()) return;

        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, Account_Type__c FROM Account WHERE Id IN :accIds
        ]);

        for (Contact con : conList) {
            if (con.AccountId != null) {
                Account acc = accMap.get(con.AccountId);
                con.Contact_Type__c = acc.Account_Type__c;
            }
        }
    }

    public static void validateContactTypeField(List<Contact> conList, Map<Id, Contact> oldMap) {
        if (conList.isEmpty() || conList == null || oldMap == null || oldMap.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();

        for (Contact con : conList) {
            Contact oldCon = oldMap.get(con.Id);

            if ((con.Contact_Type__c != oldCon.Contact_Type__c || con.AccountId != oldCon.AccountId) && con.AccountId != null) accIds.add(con.AccountId);
        }

        if (accIds.isEmpty()) return;

        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, Account_Type__c FROM Account WHERE Id IN : accIds
        ]);

        for (Contact con : conList) {
            Contact oldCon = oldMap.get(con.Id);

            if ((con.Contact_Type__c != oldCon.Contact_Type__c || con.AccountId != oldCon.AccountId) && con.AccountId != null) {
                Account acc = accMap.get(con.AccountId);

                if (con.Contact_Type__c != acc.Account_Type__c) {
                    con.addError('Contact Type cannot be different from Parent Account\'s Account Type.');
                }
            }
        }
    }
}