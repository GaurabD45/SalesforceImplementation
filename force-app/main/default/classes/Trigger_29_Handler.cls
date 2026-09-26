public with sharing class Trigger_29_Handler {
    public static void createFollowUpTaskOnLeadConversion(List<Lead> leadList, Map<Id, Lead> oldMap) {
        if (leadList == null || leadList.isEmpty()) return;

        Set<Id> convertedLeadIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        List<Task> taskList = new List<Task>();

        for (Lead leadRec : leadList) {
            Lead oldLead = oldMap != null ? oldMap.get(leadRec.Id) : null;

            if ((leadRec.IsConverted == true) && (oldMap == null || leadRec.IsConverted != oldLead.IsConverted)) {
                convertedLeadIds.add(leadRec.Id);
                accIds.add(leadRec.ConvertedAccountId);
                contactIds.add(leadRec.ConvertedContactId);

                if (leadRec.ConvertedOpportunityId != null) opportunityIds.add(leadRec.ConvertedOpportunityId);
            }
        }

        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, Name, Industry
            FROM Account
            WHERE Id IN :accIds
        ]);

        Map<Id, Contact> conMap = new Map<Id, Contact>([
            SELECT Id, Phone, Name
            FROM Contact
            WHERE Id IN :contactIds
        ]);

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, Name, Amount, StageName
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ]);

        for (Lead rec : leadList) {
            if (!convertedLeadIds.contains(rec.Id)) continue;

            Account acc = accMap.get(rec.ConvertedAccountId);
            Contact con = conMap.get(rec.ConvertedContactId);
            Opportunity opp = oppMap.get(rec.ConvertedOpportunityId);

            String description = 'New Converted Lead Details:\n' +
                                    'Account Name : ' + acc.Name + '\n' +
                                    'Account Industry : ' + acc.Industry + '\n' +
                                    'Contact Name : ' + con.Name + '\n' +
                                    'Contact Phone : ' + con.Phone + '\n';
                                    

            if (opp != null) {
                description +=  'Opportunity Name : ' + opp.Name + '\n' +
                                'Opportunity Amount : ' + opp.Amount + '\n' +
                                'Opportunity StageName : ' + opp.StageName;
            }

    
            Task newTask = new Task();
            newTask.Subject = 'Follow Up!';
            newTask.Status = 'New';
            newTask.Priority = 'Normal';
            newTask.WhatId = acc.Id;
            newTask.WhoId = con.Id;
            newTask.Description = description;
            newTask.OwnerId = UserInfo.getUserId();

            taskList.add(newTask);
        }

        if (!taskList.isEmpty()) insert taskList;
    }
}