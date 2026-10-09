public with sharing class Trigger_46_Handler {
    public static void syncAccountCountryOnContactWithCountryOnAccount(List<Account> accList, Map<Id, Account> oldMap) {
        if (accList == null || accList.isEmpty() || oldMap == null || oldMap.isEmpty()) return;

        Map<Id, String> accToCountryMap = new Map<Id, String>();
        List<Contact> conList = new List<Contact>();

        for (Account acc : accList) {
            Account oldAcc = oldMap.get(acc.Id);

            if (acc.Country__c != oldAcc.Country__c) {
                if (String.isNotBlank(acc.Country__c)) {
                    accToCountryMap.put(acc.Id, acc.Country__c);
                }
                else {
                    accToCountryMap.put(acc.Id, '');
                }
            }
        }

        for (Contact con : [
            SELECT Id, AccountId, Account_Country__c FROM Contact
            WHERE AccountId IN :accToCountryMap.keySet()
        ]) {
            con.Account_Country__c = accToCountryMap.get(con.AccountId);
            conList.add(con);
        }

        if (!conList.isEmpty()) update conList;
    }
}