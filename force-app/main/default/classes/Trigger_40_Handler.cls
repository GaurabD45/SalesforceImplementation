public with sharing class Trigger_40_Handler {
    public static void assignOppToMangerOnUserDeactivation(List<User> userList, Map<Id, User> oldUserMap) {
        if (userList == null || userList.isEmpty() || oldUserMap == null || oldUserMap.isEmpty()) return;

        Set<Id> deactivatedUserIds = new Set<Id>();

        for (User userRec : userList) {
            User oldValue = oldUserMap.get(userRec.Id);

            if (!userRec.IsActive && oldValue.IsActive) {
                deactivatedUserIds.add(userRec.Id);
            }
        }

        if (deactivatedUserIds.isEmpty()) return;

        updateOppOwners(deactivatedUserIds);
    }

    @future
    public static void updateOppOwners(Set<Id> userIds) {
        if (userIds == null && userIds.isEmpty()) return;

        List<Opportunity> oppList = new List<Opportunity>();

        for (Opportunity opp : [
            SELECT Id, OwnerId, Owner.ManagerId FROM Opportunity
            WHERE IsClosed = false AND OwnerId IN : userIds
        ]) {
            if (opp.Owner.ManagerId == null) continue;

            opp.OwnerId = opp.Owner.ManagerId;
            oppList.add(opp);
        }

        if (!oppList.isEmpty()) update oppList;
    }
}