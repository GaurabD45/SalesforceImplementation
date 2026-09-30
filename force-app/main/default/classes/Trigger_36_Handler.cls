public with sharing class Trigger_36_Handler {
    public static void assignMangerToUser(List<User> userList) {
        if (userList == null || userList.isEmpty()) return;

        Set<String> teams = new Set<String>();
        Map<String, Id> teamToManagerMap = new Map<String, Id>();

        for (User user : userList) {
            if (user.Assign_Manager__c && user.Team__c != null) teams.add(user.Team__c);
        }

        if (teams.isEmpty()) return;

        for (User manager : [
            SELECT Id, Team__c FROM User WHERE Team__c IN :teams
        ]) {
            if (!teamToManagerMap.containsKey(manager.Team__c)) {
                teamToManagerMap.put(manager.Team__c, manager.Id);
            }
        }

        if (teamToManagerMap.isEmpty()) return;
        
        for (User user : userList) { 
            if (user.Assign_Manager__c && user.Team__c != null) {
                if (teamToManagerMap.containsKey(user.Team__c)) {
                    Id manId = teamToManagerMap.get(user.Team__c);
                    user.ManagerId = manId;
                } else {
                    user.addError('There are no team managers for ' + user.Team__c);
                }
            }
        }
    }
}