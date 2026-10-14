public with sharing class Trigger_52_Handler {
    public static void notifyOpportunityOwnerOfHighValueOpportunity(List<Opportunity> oppList, Map<Id, Opportunity> oldMap) {
        if (oppList == null || oppList.isEmpty()) return;

        final Decimal AMOUNT_VALUE = 10000;
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (Opportunity opp : oppList) {
            Opportunity oldOpp = oldMap == null ? null : oldMap.get(opp.Id);

            if ((opp.Amount != null && opp.Amount >= AMOUNT_VALUE) && (oldOpp == null || opp.Amount != oldOpp.Amount)) {
                String body = 'This is to inform you that an opportunity with an amount of $' + AMOUNT_VALUE +' or more has been created/updated.';

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                email.setTargetObjectId(opp.OwnerId);
                email.setSubject('High-Value Opportunity');
                email.setPlainTextBody(body);

                emailList.add(email);
            }
        }

        if (!emailList.isEmpty()) Messaging.sendEmail(emailList);
    }
}