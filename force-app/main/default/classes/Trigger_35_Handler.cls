public with sharing class Trigger_35_Handler {
    public static void updateContactIdWithPrimaryContactOfTheRelatedAccont(List<Case> caseList, Map<Id, Case> oldCaseMap) {
        if (caseList == null || caseList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        List<Case> filteredCases = new List<Case>();
        Map<Id, Contact> accToPrimaryContactMap = new Map<Id, Contact>();
        List<Event> eventList = new List<Event>();

        for (Case case : caseList) {
            if (oldCaseMap == null) {
                if (case.AccountId != null) {
                    accIds.add(case.AccountId);
                    filteredCases.add(case);
                }
                continue;
            }

            Case oldCase = oldCaseMap.get(case.Id);

            if (case.AccountId != oldCase.AccountId && case.AccountId != null) {
                accIds.add(case.AccountId);
                filteredCases.add(case);
            }
        }

        if (accIds.isEmpty()) return;

        for (Contact con : [
            SELECT Id, AccountId FROM Contact WHERE AccountId IN :accIds AND Primary_Contact__c = true
        ]) {
            accToPrimaryContactMap.put(con.AccountId, con);
        }

        if (accToPrimaryContactMap.isEmpty()) return;

        for (Case case : filteredCases) {
            Contact priCon = accToPrimaryContactMap.get(case.AccountId);

            if (priCon == null) continue;

            case.ContactId = priCon.Id;

            Event evnt = new Event();
            evnt.WhoId = priCon.Id;
            evnt.WhatId = case.Id;
            evnt.Subject = case.Subject;
            evnt.StartDateTime = Datetime.now().addHours(12);
            evnt.EndDateTime = evnt.StartDateTime.addDays(3);

            eventList.add(evnt);
        }

        if (!filteredCases.isEmpty()) update filteredCases;
        if (!eventList.isEmpty()) insert eventList;
    }
}