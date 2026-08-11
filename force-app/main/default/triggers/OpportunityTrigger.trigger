trigger OpportunityTrigger on Opportunity (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUndelete) {
            Trigger_8_Handler.recalculateOppAmountSumAndUpdateAccDesc(Trigger.New, null);
        }

        if (Trigger.isUpdate) {
            Trigger_8_Handler.recalculateOppAmountSumAndUpdateAccDesc(Trigger.New, Trigger.oldMap);
        }

        if (Trigger.isDelete) {
            Trigger_8_Handler.recalculateOppAmountSumAndUpdateAccDesc(Trigger.old, null);
        }

    }
}