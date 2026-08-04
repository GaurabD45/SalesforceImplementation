trigger ContactTrigger on Contact (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        Trigger_4_Handler.updateAccountDescriptionOnContactDescriptonUpdate(Trigger.new, Trigger.oldMap);
    }
}