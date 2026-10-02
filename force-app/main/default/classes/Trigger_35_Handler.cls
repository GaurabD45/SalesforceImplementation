public with sharing class Trigger_35_Handler {
    public static void updateContactIdWithPrimaryContactOfTheRelatedAccont(List<Case> caseList, Map<Id, Case> oldCaseMap) {
        if (caseList == null || caseList.isEmpty()) return;

        Set<Id> accIds = new Set<Id>();
        List<Case> filteredCases = new List<Case>();
        Map<Id, Contact> accToPrimaryContactMap = new Map<Id, Contact>();
        List<Event> eventList = new List<Event>();

        for (Case caseRec : caseList) {
            if (oldCaseMap == null) {
                if (caseRec.AccountId != null) {
                    accIds.add(caseRec.AccountId);
                    filteredCases.add(caseRec);
                }
                continue;
            }

            Case oldCase = oldCaseMap.get(caseRec.Id);

            if (caseRec.AccountId != oldCase.AccountId && caseRec.AccountId != null) {
                accIds.add(caseRec.AccountId);
                filteredCases.add(caseRec);
            }
        }

        if (accIds.isEmpty()) return;

        for (Contact con : [
            SELECT Id, AccountId FROM Contact WHERE AccountId IN :accIds AND Primary_Contact__c = true
        ]) {
            accToPrimaryContactMap.put(con.AccountId, con);
        }

        if (accToPrimaryContactMap.isEmpty()) return;

        for (Case caseRec : filteredCases) {
            Contact priCon = accToPrimaryContactMap.get(caseRec.AccountId);

            if (priCon == null) continue;

            caseRec.ContactId = priCon.Id;

            Event evnt = new Event();
            evnt.WhoId = priCon.Id;
            evnt.WhatId = caseRec.Id;
            evnt.Subject = caseRec.Subject;
            evnt.StartDateTime = Datetime.now().addHours(12);
            evnt.EndDateTime = evnt.StartDateTime.addDays(3);

            eventList.add(evnt);
        }

        if (!filteredCases.isEmpty()) update filteredCases;
        if (!eventList.isEmpty()) insert eventList;
    }
}