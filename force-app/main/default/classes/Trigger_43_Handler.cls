public with sharing class Trigger_43_Handler {
    public static void createContactOnAccount(List<Account> accList, Map<Id, Account> oldMap) {
        if (accList == null || accList.isEmpty()) return;

        List<Contact> conList = new List<Contact>();

        for (Account acc : accList) {
            Contact con = new Contact();
            con.FirstName = acc.Name;
            con.LastName = 'Contact';
            con.AccountId = acc.Id;
            con.Phone = acc.Phone;
            
            if (oldMap == null) {
                if (acc.Create_Contact__c) {
                    conList.add(con);
                }
            } else {
                Account oldAcc = oldMap.get(acc.Id);

                if (!oldAcc.Create_Contact__c && acc.Create_Contact__c) {
                    conList.add(con);
                }
            }
        }

        if (!conList.isEmpty()) insert conList;
    }
}