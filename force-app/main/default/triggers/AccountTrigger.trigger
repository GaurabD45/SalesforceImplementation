trigger AccountTrigger on Account (before insert, before update, after update) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Trigger_6_Handler.preventAccountRecordDuplicationByName(Trigger.New, null);
        }

        if (Trigger.isUpdate) {
            Trigger_6_Handler.preventAccountRecordDuplicationByName(Trigger.New, Trigger.oldMap);
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            Trigger_3_Handler.conPhoneUpdateOnAccPhoneUpdate(Trigger.new, Trigger.oldMap);
            Trigger_9_Handler.updateOppStatusOnAccUpdate(Trigger.newMap);
        }
    }
}