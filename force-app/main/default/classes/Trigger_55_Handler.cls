public with sharing class Trigger_55_Handler {
    public static void populateAccDescWithRelatedContactDetails(List<Contact> conList, Map<Id, Contact> oldConMap) {
        if (conList == null || conList.isEmpty()) {
            return;
        }

        Set<Id> accIds = new Set<Id>();

        for (Contact con : conList) {
            if (oldConMap == null) {
                // Insert or Undelete or Delete
                if (con.AccountId != null) {
                    accIds.add(con.AccountId);
                }
            } else {
                Contact oldCon = oldConMap.get(con.Id);

                // Account reparented
                if (con.AccountId != oldCon.AccountId) {
                    if (con.AccountId != null) {
                        accIds.add(con.AccountId);
                    }
                    if (oldCon.AccountId != null) {
                        accIds.add(oldCon.AccountId);
                    }
                } 
                // Same Account, check if relevant displayed fields changed
                else if (con.AccountId != null && (
                    con.FirstName != oldCon.FirstName ||
                    con.LastName != oldCon.LastName ||
                    con.Phone != oldCon.Phone
                )) {
                    accIds.add(con.AccountId);
                }
            }
        }

        if (accIds.isEmpty()) {
            return;
        }

        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : [
            SELECT Id, Description, (
                SELECT Id, Name, Phone, CreatedDate 
                FROM Contacts 
                ORDER BY CreatedDate ASC
            ) 
            FROM Account 
            WHERE Id IN :accIds
        ]) {
            List<String> contactSummaries = new List<String>();

            for (Contact con : acc.Contacts) {
                String phoneStr = String.isNotBlank(con.Phone) ? con.Phone : 'N/A';
                String createdDateStr = con.CreatedDate != null ? con.CreatedDate.format() : 'N/A';

                contactSummaries.add(
                    'Name: ' + con.Name + '\n' +
                    'Phone: ' + phoneStr + '\n' +
                    'CreatedDate: ' + createdDateStr
                );
            }

            // String.join avoids trailing double newlines and string concatenation overhead
            acc.Description = String.join(contactSummaries, '\n\n');
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}