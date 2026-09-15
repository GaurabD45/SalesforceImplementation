trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, after insert, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Trigger_20_Handler.recalculateTotalOpportunityLineItemsOnAccount(Trigger.new, null, null);
            Trigger_21_Handler.createAssetForEachOpportunityProductInserted(Trigger.new);
        }

        if (Trigger.isUndelete) {
            Trigger_20_Handler.recalculateTotalOpportunityLineItemsOnAccount(Trigger.new, null, null);
        }

        if (Trigger.isDelete) {
            Trigger_20_Handler.recalculateTotalOpportunityLineItemsOnAccount(Trigger.old, null, null);
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Trigger_22_Handler.validateProductFamily(Trigger.new);
        }
    }
}