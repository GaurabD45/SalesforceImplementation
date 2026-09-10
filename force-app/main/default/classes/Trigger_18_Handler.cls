public with sharing class Trigger_18_Handler {
    public static void closeOppWithProbabilityGreaterThan70Percent(List<Account> accList, Map<Id, Account> oldMap) {

        if (accList.isEmpty()) {
            return;
        }

        Set<Id> accIds = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();

        for (Account acc : accList) {
            Account oldAcc = oldMap.get(acc.Id);

            if (acc.Close_Opportunities__c && oldAcc.Close_Opportunities != true) {
                accIds.add(acc.Id);
            }
        }

        if (!accIds.isEmpty()) {
            for (Opportunity oppRec : [
                SELECT Id, Probability, StageName, AccountId FROM Opportunity
                WHERE AccountId IN :accIds 
                AND Probability > 70
            ]) {
                oppRec.StageName = 'Closed Won';
                oppList.add(oppRec);
            }

            if (!oppList.isEmpty()) {
                update oppList;
            }
        }
    }
}