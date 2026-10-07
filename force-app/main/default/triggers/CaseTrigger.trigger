trigger CaseTrigger on Case (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Trigger_44_Handler.createTaskOnCase(Trigger.new, null);
        }

        if (Trigger.isUpdate) {
            Trigger_44_Handler.createTaskOnCase(Trigger.new, Trigger.oldMap);
        }
    }
}