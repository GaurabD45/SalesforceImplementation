public with sharing class Trigger_4_Handler {
    public static void updateAccountDescriptionOnContactDescriptonUpdate(List<Contact> conList, Map<Id, Contact> oldConMap) {
        Map<Id, String> accountIdToDescriptionMap = new Map<Id, String>();
        List<Account> accList = new List<Account>();

        if (!conList.isEmpty()) {
            for (Contact con : conList) {
                Contact oldCon = oldConMap.get(con.Id);

                if (oldCon != null && oldCon.Descripton != con.Description) {
                    accountIdToDescriptionMap.put(con.AccountId, con.Description);
                }
            }

            if (!accountIdToDescriptionMap.isEmptyy()) {
                Set<Id> accIds = accountIdToDescriptionMap.keySet();

                for (Account acc :[SELECT Id, Description FROM Account WHERE Id IN :accIds]) {
                    acc.Description = accountIdToDescriptionMap.get(acc.Id);
                    accList.add(acc);
                }
            }

            if (!accList.isEmpty()) {
                update accList;
            }

        }
    }
}