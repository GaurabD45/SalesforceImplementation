public with sharing class Trigger_11_Handler {
    public static void validateContactLimitPerAccount(List<Contact> conList) {
        if (conList.isEmpty()) {
            return;
        }

        Set<Id> accIds = new Set<Id>();
        Map<Id, Integer> accToNoOfConMap = new Map<Id, Integer>();

        for (Contact con : conList) {
            if (con.AccountId != null) {
                accIds.add(con.AccountId);
                accToNoOfConMap.put(con.AccountId, 0);
            }
        }

        if (!accIds.isEmpty()) {
            for (AggregateResult res : [SELECT AccountId, COUNT(Id) total FROM Contact WHERE AccountId IN :accIds GROUP BY AccountId]) {
                Id accId = (Id)res.get('AccountId');
                Integer noOfContacts = (Integer)res.get('total');

                accToNoOfConMap.put(accId, noOfContacts);
            }

            for (Contact con : conList) {
                if (con.AccountId != null) {
                    if (accToNoOfConMap.get(con.AccountId) >= 2) {
                        con.addError('Cannot add more than two contacts on an Account');
                    } else {
                        Integer count = accToNoOfConMap.get(con.AccountId);
                        accToNoOfConMap.put(con.AccountId, count + 1);
                    }
                }
            }
        }
    }
}