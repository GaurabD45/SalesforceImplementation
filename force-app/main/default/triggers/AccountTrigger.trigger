trigger AccountTrigger on Account (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            Trigger_3_Handler.conPhoneUpdateOnAccPhoneUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}