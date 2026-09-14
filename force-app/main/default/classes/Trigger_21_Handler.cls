public with sharing class Trigger_21_Handler {
    public static void createAssetForEachOpportunityProductInserted(List<OpportunityLineItem> oliList) {
        if (oliList == null || oliList.isEmpty()) {
            return;
        }

        Set<Id> oppIds = new Set<Id>();
        List<Asset> assetList = new List<Asset>();
        Map<Id, Opportunity> oppMap; 
        
        for (OpportunityLineItem oli : oliList) {
            oppIds.add(oli.OpportunityId);
        }

        oppMap = new Map<Id, Opportunity>([
                SELECT Id, Name, AccountId
                FROM Opportunity
                WHERE Id IN :oppIds
            ]);
        
        if (oppMap.isEmpty()) {
            return;
        }

        for (OpportunityLineItem oli : oliList) {
            Opportunity opp = oppMap.get(oli.OpportunityId);

            if (opp.AccountId != null) {

                Asset newAsset = new Asset();
                newAsset.Name = opp.Name + ' Item';
                newAsset.Product2Id = oli.Product2Id;
                newAsset.AccountId = opp.AccountId;
                
                assetList.add(newAsset);
            }

        }

        if (!assetList.isEmpty()) {
            insert assetList;
        }
    }
}