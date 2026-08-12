public with sharing class Trigger_9_Handler {
    public static void updateOppStatusOnAccUpdate(Map<Id, Account> newAccMap) {
        Set<Id> accIds = new Set<Id> ();
        List<Opportunity> oppList = new List<Opportunity>();

        if (!newAccMap.isEmpty()) {
            accIds = newAccMap.keySet();
            DateTime requiredDateTime = System.now().addDays(-30);

            for (Opportunity opp : [SELECT Id, StageName FROM Opportunity WHERE AccountId IN :accIds AND IsClosed = false AND CreatedDate < :requiredDateTime]) {
                opp.StageName = 'Closed Lost';
                oppList.add(opp);
            }

            if (!oppList.isEmpty()) {
                update oppList;
            }
        }
    }
}