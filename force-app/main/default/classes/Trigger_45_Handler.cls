public with sharing class Trigger_45_Handler {
    public static void linkCaseWithContactBasedOnSuppliedEmail(List<Case> caseList) {
        if (caseList == null || caseList.isEmpty()) return;

        Map<String, Id> suppLiedEmailToAccIdMap = new Map<String, Id>();
        Map<String, Contact> emailToContactMap = new Map<String, Contact>();
        List<Contact> conList = new List<Contact>();

        
        for (Case caseRec : caseList) {
            if (String.isNotBlank(caseRec.SuppliedEmail) && caseRec.AccountId != null) {
                suppLiedEmailToAccIdMap.put(caseRec.SuppliedEmail.trim().toLowerCase(), caseRec.AccountId);
            }
        }

        if (suppLiedEmailToAccIdMap.isEmpty()) return;

        for (Contact con : [
            SELECT Id, Email FROM Contact
            WHERE Email IN :suppLiedEmailToAccIdMap.keySet()
        ]) {
            emailToContactMap.put(con.Email.trim().toLowerCase(), con);
        }

        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :suppLiedEmailToAccIdMap.values()]);

        for (String email : suppLiedEmailToAccIdMap.keySet()) {
            if (!emailToContactMap.containsKey(email)) {
                Account acc = accMap.get(suppLiedEmailToAccIdMap.get(email));

                Contact con = new Contact();
                con.Email = email;
                con.FirstName = acc.Name;
                con.LastName = 'Contact';
                con.AccountId = acc.Id;

                emailToContactMap.put(email, con);
                conList.add(con);
            }
        }

        if (!conList.isEmpty()) insert conList;

        for (Case caseRec : caseList) {
            if (String.isNotBlank(caseRec.SuppliedEmail) && caseRec.AccountId != null) {
                Contact con = emailToContactMap.get(caseRec.SuppliedEmail.trim().toLowerCase());
                caseRec.ContactId = con.Id;
            }
        }
    }
}