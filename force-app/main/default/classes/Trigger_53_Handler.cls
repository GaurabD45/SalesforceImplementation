public with sharing class Trigger_53_Handler {
    public static void markNewContactsAndUnMarkOldContacts(List<Contact> conList) {
        if (conList == null || conList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        List<Contact> updatedConList = new List<Contact>();

        for (Contact con : conList) {
            if (con.AccountId != null) {
                con.New_Contact__c = true;
                accIds.add(con.AccountId);
            }
        }

        if (accIds.isEmpty()) return;

        for (Contact con : [
            SELECT Id, New_Contact__c FROM Contact
            WHERE AccountId IN :accIds AND New_Contact__c = true
        ]) {
            con.New_Contact__c = false;
            updatedConList.add(con);
        }

        if (!updatedConList.isEmpty()) update updatedConList;
    }
}