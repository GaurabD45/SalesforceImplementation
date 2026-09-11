trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Trigger_20_Handler.recalculateTotalOpportunityLineItemsOnAccount(Trigger.new, null, null);
        }

        if (Trigger.isUndelete) {
            Trigger_20_Handler.recalculateTotalOpportunityLineItemsOnAccount(Trigger.new, null, null);
        }

        if (Trigger.isDelete) {
            Trigger_20_Handler.recalculateTotalOpportunityLineItemsOnAccount(Trigger.old, null, null);
        }
    }
}