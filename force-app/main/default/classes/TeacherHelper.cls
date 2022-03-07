public without sharing class TeacherHelper {
    
    public static void insertDeleteActiveTeachers(List<Teacher__c> teachersList){
        Set<Id> schoolIdsSet = new Set<Id>();
        
        for(Teacher__c teacher : teachersList){
            if(String.IsNotBlank(teacher.School_Name__c) && teacher.Active__c){
                schoolIdsSet.add(teacher.School_Name__c);
            }
        }
        updateActiveTeachers(schoolIdsSet);
    }


    public static void updateActiveTeachers(List<Teacher__c> newTeachersList, Map<Id, Teacher__c>  oldTeacherMap){
        Set<Id> schoolIdsSet = new Set<Id>();
        Teacher__c oldTeacher;

        for(Teacher__c teacher : newTeachersList){
            oldTeacher = oldTeacherMap.get(teacher.Id);

            if(teacher.School_Name__c != oldTeacher.School_Name__c){
                if(teacher.Active__c){
                    schoolIdsSet.add(oldTeacher.School_Name__c);
                }
                if(oldTeacher.Active__c){
                    schoolIdsSet.add(oldTeacher.School_Name__c);
                }
            }
            else if(teacher.Active__c != oldTeacher.Active__c){
                schoolIdsSet.add(teacher.School_Name__c);
                schoolIdsSet.add(oldTeacher.School_Name__c);
            }
        }

        updateActiveTeachers(schoolIdsSet);
    }

    private static void updateActiveTeachers(Set<Id> schoolIdsSet){
        List<School__c> existingSchoolsList = 
            [SELECT Id, Number_of_teachers__c,( SELECT Id FROM Teachers__r WHERE Active__c = true)
             FROM School__c
             WHERE Id IN :schoolIdsSet];
    
        List<School__c> schoolsToBeUpdated = new List<School__c>();

        for(School__c school: existingSchoolsList){
            if(school.Number_of_teachers__c != school.Teachers__r.size()){
                schoolsToBeUpdated.add(
                    new School__c(Id = school.Id, Number_of_teachers__c = school.Teachers__r.size())
                );
            }
        }

        update schoolsToBeUpdated;
    }
}