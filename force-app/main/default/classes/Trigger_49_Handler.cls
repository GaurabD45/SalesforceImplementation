public with sharing class Trigger_49_Handler {
    public static void createCandidateSkillRecords(List<Candidate__c> candidateList) {
        if (candidateList == null || candidateList.isEmpty()) return;

        Map<Id, Set<String>> canToSkillMap = new Map<Id, Set<String>>();
        Set<String> skills = new Set<String>();
        Map<String, Skill__c> skillMap = new Map<String, Skill__c>();
        List<Skill__c> newSkills = new List<Skill__c>();
        List<Candidate_Skill__c> canSkillList = new List<Candidate_Skill__c>();

        for (Candidate__c can : candidateList) {
            List<String> canSkills = can.Skills__c.split(',');
            Set<String> normalizedSkills = new Set<String>();

            for (String skill : canSkills) {
                if (String.isBlank(skill)) continue;

                String normalizedSkill = skill.trim().toLowerCase();

                normalizedSkills.add(normalizedSkill);
                skills.add(normalizedSkill);
            }

            canToSkillMap.put(can.Id, normalizedSkills);
        }

        for (Skill__c rec : [
            SELECT Id, Name FROM Skill__c 
            WHERE Name IN :skills
        ]) {
            skillMap.put(rec.Name.trim().toLowerCase(), rec);
        }

        skills.removeAll(skillMap.keySet());

        for (String skill : skills) {
            Skill__c sk = new Skill__c(Name = skill);
            newSkills.add(sk);
            skillMap.add(skill, sk);
        }

        if (!newSkills.isEmpty()) insert newSkills;

        for (Id canId : canToSkillMap.keySet()) {

            for (String skill : canToSkillMap.get(canId)) {
                Candidate_Skill__c cs = new Candidate_Skill__c();
                cs.Candidate__c = canId;
                cs.Skill__c = skillMap.get(skill).Id;

                canSkillList.add(cs);
            }
        }

        if (!canSkillList.isEmpty()) insert canSkillList;
    }
}