public with sharing class Trigger_30_Handler {
    public static void deleteOppAndUpdateConOnAccActiveStatusChange(List<Account> accList, Map<Id, Account> oldMap) {
        if (accList == null || accList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contact> conList = new List<Contact>();

        for (Account acc : accList) {
            Account oldAcc = oldMap.get(acc.Id);

            if (acc.Active__c == 'No' && oldAcc.Active__c == 'Yes') {
                accIds.add(acc.Id);
            }
        }

        if (accIds.isEmpty()) return;

        for (Opportunity opp : [
            SELECT Id
            FROM Opportunity
            WHERE AccountId IN : accIds
        ]) {
            oppList.add(opp);
        }

        for (Contact con : [
            SELECT Id, Do_not_Contact__c
            FROM Contact
            WHERE AccountId IN :accIds
        ]) {
            con.Do_not_Contact__c = true;
            conList.add(con);
        }

        if (!oppList.isEmpty()) delete oppList;
        if (!conList.isEmpty()) update conList;
    }
}