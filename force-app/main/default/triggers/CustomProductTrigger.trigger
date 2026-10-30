trigger CustomProductTrigger on Product__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Trigger_57_Handler.validateCustomProductRecord(Trigger.new);
        }

        if (Trigger.isUpdate) {
            Trigger_57_Handler.validateCustomProductRecord(Trigger.new);
        }
    }
}