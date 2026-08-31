public with sharing class Trigger_13_Handler {
 
    public static void preventDuplicateContactRecordsBasedOnEmailAndPhone(List<Contact> conList, Map<Id, Contact> oldMap) {
        
        if (conList.isEmpty()) {
            return;
        }

        Set<String> emailSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();

        Map<String, Id> emailToContactMap = new Map<String, Id>();
        Map<String, Id> phoneToContactMap = new Map<String, Id>();

        Set<String> newlyAddedEmail = new Set<String>();
        Set<String> newlyAddedPhone = new Set<String>();

        //collect values
        for (Contact con : conList) {
            if (String.isNotBlank(con.Email)) {
                emailSet.add(con.Email.trim().toLowerCase());
            }

            if (String.isNotBlank(con.Phone)) {
                phoneSet.add(con.Phone);
            }
        }

        //fetch records with the existing values and map them
        for (Contact con : [
            SELECT Id, Email, Phone FROM Contact 
            WHERE Email IN :emailSet OR  Phone IN :phoneSet
            ]) {
             if (String.isNotBlank(con.Email)) {
                emailToContactMap.put(con.Email.trim().toLowerCase(), con.Id);
            }

            if (String.isNotBlank(con.Phone)) {
                phoneToContactMap.put(con.Phone, con.Id);
            }
        }

        //validate
        for (Contact con : conList) {
            //validating email
            if (String.isNotBlank(con.Email)) {
                String email = con.Email.trim().toLowerCase();

                //for insert and update
                if (emailToContactMap.containsKey(email) && (oldMap == null || emailToContactMap.get(email) != con.Id)) {
                     con.addError('a Contact with this email already exists.');
                }
                else if (newlyAddedEmail.contains(email)) {
                    con.addError('a Contact with this email was recently added');
                }
                else {
                    newlyAddedEmail.add(email);
                }
            }

            //validating phone
            if (String.isNotBlank(con.Phone)) {
                //for insert
                if (phoneToContactMap.containsKey(con.Phone) && (oldMap == null || phoneToContactMap.get(con.Phone) != con.Id)) {
                    con.addError('a Contact with this Phone already exists.');
                } 
                else if (newlyAddedPhone.contains(con.Phone)) {
                    con.addError('a Contact with this Phone was recently added');
                }
                else {
                    newlyAddedPhone.add(con.Phone);
                }
            }
        }
    }
}