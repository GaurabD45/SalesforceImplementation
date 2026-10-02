public with sharing class Trigger_38_Handler {
    public static void deleteOldOpportunityContactRoleAndCreateNewOnOpportunityTypeUpdate(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if (oppList == null || oppList.isEmpty() || oldMap == null || oldMap.isEmpty()) return;

        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<Id> accIds = new Set<Id>();
        Set<String> typeList = new Set<String>();
        Map<String, Id> accConTypeToConMap = new Map<String, Id>();
        List<OpportunityContactRole> newOcrList = new List<OpportunityContactRole>();

        for (Opportunity opp : oppList) {
            Opportunity oldOpp = oldMap.get(opp.Id);

            if (opp.Type != oldOpp.Type && opp.AccountId != null) {
                oppMap.put(opp.Id, opp);
                typeList.add(opp.Type);
                accIds.add(opp.AccountId);
            }
        }

        if (oppMap.isEmpty()) return;

        List<OpportunityContactRole> ocrListToBeDeleted = new List<OpportunityContactRole>([
            SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN :oppMap.keySet()
        ]);

        for (Contact con : [
            SELECT Id, AccountId, Contact_Type__c FROM Contact
            WHERE AccountId IN :accIds AND Contact_Type__c IN :typeList
            ]) {
                String key = con.AccountId + '-' + con.Contact_Type__c;
                
                accConTypeToConMap.put(key, con.Id);
            }
            
        for (Opportunity opp : oppMap.values()) {
            String key = opp.AccountId + '-' + opp.Type;
            
            Id conId = accConTypeToConMap.get(key);
                
            if (conId == null) {
                opp.addError('Contact of same type as Opportunity does not exist.');         continue;
            }
                
            OpportunityContactRole  newOcr = new OpportunityContactRole();
            newOcr.OpportunityId = opp.Id;
            newOcr.ContactId = conId;
                
            newOcrList.add(newOcr);
        }
            
        if (!ocrListToBeDeleted.isEmpty()) delete ocrListToBeDeleted;

        if (!newOcrList.isEmpty()) insert newOcrList;
    }
}