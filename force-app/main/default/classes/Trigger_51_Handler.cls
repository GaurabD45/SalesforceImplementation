public with sharing class Trigger_51_Handler {
    public static void sendEmailToAccOwnerWithContactUpdateDetails(List<Account> accList, Map<Id, Account> oldMap) {
        if (accList == null || accList.isEmpty() || oldMap == null || oldMap.isEmpty()) return;

        Set<Id> accIds = oldMap.keySet();
        Map<Id, List<Contact>> accToConMap = new Map<Id, List<Contact>>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (Contact con : [
            SELECT Id, Name, LastModifiedDate, AccountId FROM Contact WHERE AccountId IN :accIds
        ]) {
            if (accToConMap.containsKey(con.AccountId)) {
                accToConMap.get(con.AccountId).add(con);
            } else {
                accToConMap.put(con.AccountId, new List<Contact>{con});
            }
        }

        for (Account acc : accList) {
            Account oldAcc = oldMap.get(acc.Id);

            DateTime oldModifiedDate = oldAcc.LastModifiedDate;
            DateTime newModifiedDate = acc.LastModifiedDate;

            String emailMessage = '';
            List<Contact> conList = accToConMap.get(acc.Id);

            if (conList == null) continue;

            for (Contact con : conList) {
                if (con.LastModifiedDate > oldModifiedDate && con.LastModifiedDate <= newModifiedDate) {
                    emailMessage += 'Contact Id:' + con.Id + '\n' + 'Name:' + con.Name + '\n\n';
                }
            }

            if (String.isBlank(emailMessage)) continue;

            emailMessage = 'The following Contacts\' detail on Account ' + acc.Id +  ' have changed:\n' + emailMessage;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(acc.OwnerId);
            mail.setSubject('Account Update Notification');
            mail.setPlainTextBody(emailMessage);

            emailList.add(mail);
        }

        if (!emailList.isEmpty()) Messaging.sendEmail(emailList);
    }
}