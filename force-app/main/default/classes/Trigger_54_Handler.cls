public with sharing class Trigger_54_Handler {
    public static void linkCaseAndContact(List<Case> caseList) {
        if (caseList == null || caseList.isEmpty()) return;

        Set<String> suppliedEmailList = new Set<String>();
        Set<Id> accIds = new Set<Id>();
        Map<String, Contact> emailToContactMap = new Map<String, Contact>();
        Map<String, Id> emailToAccountMap = new Map<String, Id>();
        List<Contact> conList = new List<Contact>();

        for (Case caseRec : caseList) {
            if (String.isNotBlank(caseRec.SuppliedEmail) && caseRec.AccountId != null) {
                String email = caseRec.SuppliedEmail.trim().toLowerCase();
                suppliedEmailList.add(email);
                accIds.add(caseRec.AccountId);
                emailToAccountMap.put(email, caseRec.AccountId);
            } 
        }

        if (suppliedEmailList.isEmpty()) return;

        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accIds]);

        for (Contact con : [
            SELECT Id, Email FROM Contact WHERE Email IN :suppliedEmailList
        ]) {
            emailToContactMap.put(con.Email.trim().toLowerCase(), con);
        }

        suppliedEmailList.removeAll(emailToContactMap.keySet());

        for (String email : suppliedEmailList) {
            Account acc = emailToAccountMap.get(email);

            Contact con = new Contact();
            con.Email = email;
            con.LastName = 'Contact';
            con.FirstName = acc.Name;
            con.AccountId = acc.Id;
            con.Phone = acc.Phone;

            conList.add(con);
            emailToContactMap.put(email, con);    
        }

        if (!conList.isEmpty()) insert conList;

        for (Case caseRec : caseList) {
            if (String.isNotBlank(caseRec.SuppliedEmail) && caseRec.AccountId != null) {
                
                String email = caseRec.SuppliedEmail.trim().toLowerCase();
                Contact con = emailToContactMap.get(email);
                caseRec.ContactId = con.Id;
            } 
        }
    }
}