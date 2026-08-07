public with sharing class Trigger_6_Handler {
    public static void preventAccountRecordDuplicationByName(List<Account> accList, Map<Id, Account> oldMap) {
        Set<String> names = new Set<String>();
        Set<String> alreadyExistingNamesAndJustAddedNames = new Set<String>();

        if (!accList.isEmpty()) {

            for (Account acc : accList) {
                //update scenario
                if (oldMap != null) {
                    Account oldAcc = oldMap.get.(acc.Id);
                    
                    if (oldAcc != null && oldAcc.Name != acc.Name) {
                        names.add(acc.Name);
                    }
    
                }
                //insert scenario
                names.add(acc.Name);                
            }

            if (!names.isEmpty()) {
                for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :names]) {
                    alreadyExistingNamesAndJustAddedNames.add(acc.Name);
                }

                for (Account acc : accList) {
                    if (alreadyExistingNamesAndJustAddedNames.contains(acc.Name)) {
                        acc.addError('Account with this name already exists');
                    } else {
                        alreadyExistingNamesAndJustAddedNames.add(acc.Name);
                    }
                }
            }          
        }

    }
}