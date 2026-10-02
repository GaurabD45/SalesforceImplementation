public with sharing class Trigger_32_Handler {
    public static void updateConAccOppOnLeadConversion(List<Lead> leadList, Map<Id, Lead> oldMap) {
        if (leadList == null || leadList.isEmpty()) return;

        List<Lead> convertedLeads = new List<Lead>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<Opportunity> oppList = new List<Opportunity>();

        for (Lead rec : leadList) {
            if (oldMap == null) {
                if (rec.IsConverted) {
                    convertedLeads.add(rec);
                    accIds.add(rec.ConvertedAccountId);
                    conIds.add(rec.ConvertedContactId);

                    if (rec.ConvertedOpportunityId != null) oppIds.add(rec.ConvertedOpportunityId);
                }
            }else {
                Lead oldLead = oldMap.get(rec.Id);

                if (rec.IsConverted && !oldLead.IsConverted) {
                    convertedLeads.add(rec);
                    accIds.add(rec.ConvertedAccountId);
                    conIds.add(rec.ConvertedContactId);

                    if (rec.ConvertedOpportunityId != null) oppIds.add(rec.ConvertedOpportunityId);
                }
            }
        }

        if (convertedLeads.isEmpty()) return;

        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, Active__c FROM Account WHERE Id IN :accIds
        ]);
        Map<Id, Contact> conMap = new Map<Id, Contact>([
            SELECT Id, Lead_Contact__c FROM Contact WHERE Id IN :conIds
        ]);
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, Description FROM Opportunity WHERE Id IN :oppIds
        ]);

        for (Lead rec : convertedLeads) {
            Account acc = accMap.get(rec.ConvertedAccountId);
            Contact con = conMap.get(rec.ConvertedContactId);
            Opportunity opp = rec.ConvertedOpportunityId != null? oppMap.get(rec.ConvertedOpportunityId) : null;

            acc.Active__c = 'Yes';
            accList.add(acc);

            con.Lead_Contact__c = true;
            conList.add(con);

            if (opp != null) {
                opp.Description = rec.Name;
                oppList.add(opp);
            }
        }

        if (!accList.isEmpty()) update accList;
        if (!conList.isEmpty()) update conList;
        if (!oppList.isEmpty()) update oppList;
    }
}