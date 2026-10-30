public with sharing class Trigger_57_Handler {
    public static void validateCustomProductRecord(List<Product__c> proList) {
        if (proList == null || proList.isEmpty()) {
            return;
        }

        for (Product__c pro : proList) {
            if (pro.Offer_Available__c == false) {
                pro.addError('Offer Available must be checked.');
            }

            if (pro.Offer_Type__c == 'Flat') {
                if (pro.Flat_Discount__c == null) {
                    pro.addError('Flat Discount field cannot be empty when Offer Type is Flat.');
                } else {
                    pro.Offer_Price__c = pro.Flat_Discount__c < pro.Original_Price__c ? pro.Original_Price__c - pro.Flat_Discount__c : 0;
                }
            }

            if (pro.Offer_Type__c == 'Percentage') {
                if (pro.Percentage_Discount__c == null) {
                    pro.addError('Percentage Discount field cannot be empty when Offer Type is Percentage.');
                } else {
                    Decimal calDisc = (pro.Original_Price__c * pro.Percentage_Discount__c) / 100;
                    pro.Offer_Price__c = pro.Original_Price__c > calDisc ? pro.Original_Price__c - calDisc : 0;
                }
            }
        }
    }
}