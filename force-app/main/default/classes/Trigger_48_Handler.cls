public with sharing class Trigger_48_Handler {
    public static void updateAccDescOrCreateNewOppOnContactInsertion(List<Contact> conList) {
        if (conList == null || conList.isEmpty()) return;
        
        Set<Id> accIds = new Set<Id>();
        Map<Id, Decimal> accToTotalOppAmountMap = new Map<Id, Decimal>();
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();

        for (Contact con : conList) {
            if (con.AccountId != null) accIds.add(con.AccountId);
        }

        if (accIds.isEmpty()) return;

        for(AggregateResult res : [
            SELECT SUM(Amount) total, AccountId FROM Opportunity
            WHERE AccountId IN :accIds
            GROUP BY AccountId
        ]) {
            Id accId = (Id)res.get('AccountId');
            Decimal total = (Decimal)res.get('total'); //this can be null too if all the opportunity on an account has null on Amount

            accToTotalOppAmountMap.put(accId, total);
        }

        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Name, Description FROM Account WHERE Id IN :accIds]);

        for (Id accId : accIds) {
            Account acc = accMap.get(accId);

            if (!accToTotalOppAmountMap.containsKey(accId)) {
                Opportunity opp = new Opportunity();
                opp.Name = acc.Name + ' Opportunity';
                opp.AccountId = acc.Id;
                opp.StageName = 'Prospecting';
                opp.CloseDate = Date.today().addDays(30);
                
                oppList.add(opp);
                continue;
            }

            Decimal amount = accToTotalOppAmountMap.get(accId) == null ? 0 : accToTotalOppAmountMap.get(accId);

            acc.Description = 'Total Opportunity Amount on this account is ' + amount + '.';

            accList.add(acc);
        }

        if (!oppList.isEmpty()) insert oppList;
        if (!accList.isEmpty()) update accList;
    }
}