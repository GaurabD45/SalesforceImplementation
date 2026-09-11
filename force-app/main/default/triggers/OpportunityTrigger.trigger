trigger OpportunityTrigger on Opportunity (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUndelete) {
            Trigger_8_Handler.recalculateOppAmountSumAndUpdateAccDesc(Trigger.New, null);
            Trigger_16_Handler.updateAccountDescriptionWithHighestAmountOpportunityName(Trigger.new, null);
        }

        if (Trigger.isUpdate) {
            Trigger_8_Handler.recalculateOppAmountSumAndUpdateAccDesc(Trigger.New, Trigger.oldMap);
            Trigger_16_Handler.updateAccountDescriptionWithHighestAmountOpportunityName(Trigger.new, Trigger.oldMap);
            Trigger_20_Handler.recalculateTotalOpportunityLineItemsOnAccount(null, Trigger.new, Trigger.oldMap);
        }

        if (Trigger.isDelete) {
            Trigger_8_Handler.recalculateOppAmountSumAndUpdateAccDesc(Trigger.old, null);
            Trigger_16_Handler.updateAccountDescriptionWithHighestAmountOpportunityName(Trigger.old, null);
        }

    }
}