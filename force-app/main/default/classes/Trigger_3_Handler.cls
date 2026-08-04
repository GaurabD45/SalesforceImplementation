public with sharing class Trigger_3_Handler {
    public static void conPhoneUpdateOnAccPhoneUpdate(List<Account> accList, Map<Id, Account> oldAccMap) {

        Map<Id, String> accountIdToPhoneMap = new Map<Id, String>();
        List<Contact> updatedConList = new List<Contact>();

        if (!accList.isEmpty() && oldAccMap != null) {
            for (Account acc : accList) {
                Account oldAcc = oldAccMap.get(acc.Id);

                if (oldAcc != null && acc.Phone != oldAcc.Phone) {
                    accountIdToPhoneMap.put(acc.Id, acc.Phone);
                }
            }

            if (!accountIdToPhoneMap.isEmpty()) {
                Set<Id> accIds = accountIdToPhoneMap.keySet();

                for (Contact con : [SELECT Id, AccountId, Phone FROM Contact WHERE AccountId IN :accIds]) {
                    con.Phone = accountIdToPhoneMap.get(con.AccountId);
                    updatedConList.add(con);
                }
            }

            if(!updatedConList.isEmpty()) {
                update updatedConList;
            }
        }
    }
}