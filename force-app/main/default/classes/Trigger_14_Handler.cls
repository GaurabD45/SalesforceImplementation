public with sharing class Trigger_14_Handler {
    public static void sendEmailToContactsOnAccountTypeUpdate(List<Account> accList, Map<Id, Account> oldMap) {
        if (accList.isEmpty()) {
            return;
        }

        Set<Id> accIds = new Set<Id>();
        Map<Id, String> accountToTypeMapNew = new Map<Id, String>();
        Map<Id, String> accountToTypeMapOld = new Map<Id, String>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (Account acc : accList) {
            Account oldAcc = oldMap.get(acc.Id);

            if (acc.Type != oldAcc.Type) {
                accIds.add(acc.Id);
                accountToTypeMapNew.put(acc.Id, acc.Type);
                accountToTypeMapOld.put(acc.Id, oldAcc.Type);
            }
        }

        if (!accIds.isEmpty()) {
            for (Contact con : [
                SELECT Id, FirstName, LastName, Email, AccountId FROM Contact
                WHERE AccountId IN :accIds
            ]) {
                
                if (String.isBlank(con.Email)) {
                    continue;
                }

                String oldType = accountToTypeMapOld.get(con.AccountId);
                String newType = accountToTypeMapNew.get(con.AccountId);

                String emailBody = 'Account Type has been changed from ' + oldType + ' to ' + newType + '.';
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                email.setToAddresses(new List<String>{con.Email});
                email.setPlainTextBody(emailBody);
                email.setSubject('Related Account Type Updated');

                emailList.add(email);
            }

            if (!emailList.isEmpty()) {
                Messaging.sendEmail(emailList);
            }
        }
    }
}