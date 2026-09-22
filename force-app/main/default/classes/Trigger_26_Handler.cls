public with sharing class Trigger_26_Handler {
    public static void updateStatusOnAccount(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if (oppList == null || oppList.isEmpty()) {
            return;
        }

        Set<Id> accIds = new Set<Id>();
        List<Account> accList = new List<Account>();

        //accIds collection
        for (Opportunity opp : oppList) {
            //for update
            if (oldMap != null) {
                Opportunity oldOpp = oldMap.get(opp.Id);
                if (opp.StageName != oldOpp.StageName && (opp.StageName == 'Closed Won' || oldOpp.StageName == 'Closed Won') && opp.AccountId != null) {

                    accIds.add(opp.AccountId);
                }

                if (oldOpp.AccountId != opp.AccountId) {
                    if (oldOpp.AccountId != null) {
                        accIds.add(oldOpp.AccountId);
                    }

                    if (opp.AccountId != null) {
                        accIds.add(opp.AccountId);
                    }
                }
            } else {
                //for insert, delete, undelete
                if (opp.AccountId != null) { 
                    accIds.add(opp.AccountId);
                }           
            }
        }

        if (accIds.isEmpty()) {
            return;
        }
    
        for (Account acc : [
            SELECT Id, Status__c, (SELECT Id, StageName FROM Opportunities)
            FROM Account
            WHERE Id IN :accIds
        ]) {
            acc.Status__c = 'Closed';

            for (Opportunity opp : acc.Opportunities) {
                if (opp.StageName != 'Closed Won') {
                    acc.Status__c = 'Open';
                    break;
                }
            }
            
            accList.add(acc);
        }

        if (!accList.isEmpty()) {
            update accList;
        }
    }
}