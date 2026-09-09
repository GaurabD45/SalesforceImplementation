trigger ContactTrigger on Contact (before insert, before update, after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        Trigger_4_Handler.updateAccountDescriptionOnContactDescriptonUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isBefore && Trigger.isInsert) {
        Trigger_11_Handler.validateContactLimitPerAccount(Trigger.new);
        Trigger_13_Handler.preventDuplicateContactRecordsBasedOnEmailAndPhone(Trigger.new, null);
        Trigger_17_Handler.validatePrimaryContact(Trigger.new, null);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        Trigger_13_Handler.preventDuplicateContactRecordsBasedOnEmailAndPhone(Trigger.new, Trigger.oldMap);
        Trigger_17_Handler.validatePrimaryContact(Trigger.new, Trigger.oldMap);
    }
}