public with sharing class Trigger_22_Handler {
    public static void validateProductFamily(List<OpportunityLineItem> oliList) {
        if (oliList == null || oliList.isEmpty()) {
            return;
        }

        Set<Id> oppIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Map<Id, Opportunity> oppMap;
        Map<Id, Product2> productMap;

        for (OpportunityLineItem oli : oliList) {
            oppIds.add(oli.OpportunityId);
            productIds.add(oli.Product2Id);
        }

        oppMap = new Map<Id, Opportunity>([
            SELECT Id, Product_Family__c
            FROM Opportunity
            WHERE Id IN :oppIds
        ]);

        productMap = new Map<Id, Product2>([
            SELECT Id, Family
            FROM Product2
            WHERE Id IN :productIds
        ]);

        for (OpportunityLineItem oli : oliList) {
            if (oppMap.get(oli.OpportunityId).Product_Family__c != productMap.get(oli.Product2Id).Family) {
                oli.addError('Opportunity and Opportunity Product cannot have different families.');
            }
        }

    }
}