trigger ContactTrigger on Contact (before insert, after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        Trigger_4_Handler.updateAccountDescriptionOnContactDescriptonUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isBefore && Trigger.isInsert) {
        Trigger_11_Handler.validateContactLimitPerAccount(Trigger.new);
    }
}