public with sharing class Trigger_17_Handler {
    public static void validatePrimaryContact(List<Contact> conList, Map<Id, Contact> oldMap) {
       
        if (conList.isEmpty()) {
            return;
        }

        Set<Id> accIds = new Set<Id>();
        Map<Id, Id> accountToPriConMap = new Map<Id, Id>();
        Set<Id> newlyAddedPriConAccIds = new Set<Id>();

        //collecting account ids
        for (Contact con : conList) {
            if (con.Primary_Contact__c && con.AccountId != null) {
                accIds.add(con.AccountId);
            }
        }

        //constructing map
        if (!accIds.isEmpty()) {
            for (Contact con : [
                SELECT Id, Primary_Contact__c, AccountId
                FROM Contact
                WHERE Primary_Contact__c = true AND AccountId IN :accIds
            ]) {
                accountToPriConMap.put(con.AccountId, con.Id);
            }
        }

        //validation on insertion and updation
        for (Contact con : conList) {
            if (con.Primary_Contact__c == true && con.AccountId != null) {
                if ((accountToPriConMap.containsKey(con.AccountId)) && (oldMap == null || (accountToPriConMap.get(con.AccountId) != con.Id))) {
                    con.addError('Primary contact on the related account already exists.');
                } 
                else if(newlyAddedPriConAccIds.contains(con.AccountId)){
                    con.addError('Cannot add more than one primary contact on an Account.');
                }
                else {
                    newlyAddedPriConAccIds.add(con.AccountId);
                }
            }
        }
    }
}