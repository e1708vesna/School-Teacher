public without sharing class JunctionHelper {

    //BEFORE trigger
    public static void updateActiveTeachersRollup(List<Teach_Multiple_School__c> schoolTeacherList){

        //before you check if there is a duplicate in the existing record you should check in the new records also if there is a duplicate before inserting      
        Set<String> uniqueKeySet = new Set<String>();

        for(Teach_Multiple_School__c exst : [SELECT School__c, Teacher__c, uniqueSTCombo__c
                                             FROM Teach_Multiple_School__c])
        {
            uniqueKeySet.add(exst.uniqueSTCombo__c); //we expect the return values of DB to be unique
                     
        }

        //for each junction record fill out the unique key field for s-t combo
        for(Teach_Multiple_School__c st : schoolTeacherList){
            st.uniqueSTCombo__c = st.School__c + '_' + st.Teacher__c;  
            if(uniqueKeySet.contains(st.uniqueSTCombo__c)){
                st.addError('The record You are trying to save is already existing in the Database. Please try another entry.');        
            }    
            else{
                uniqueKeySet.add(st.uniqueSTCombo__c);
            }
        }
    }

    //AFTER trigger

    //counting the number of teachers in each school from the junction object
    public static void updateActiveTeachersJunction(List<Teach_Multiple_School__c> schoolTeacherList) {
        
        Set<Id> schoolIdSet = new Set<Id>(); //set of school's Ids appeared in the junction records

        //map with the set of IDs, for deduplicating data 
        Map<Id, Set<Id>> schoolSetOfTeacherMap = new Map<Id, Set<Id>>(); //[id]school, [value]set of teachers ids for that particular school

        //for each junction record populate the school's ids set and the map accordingly
        for(Teach_Multiple_School__c st : schoolTeacherList){
            schoolIdSet.add(st.School__c);
            schoolSetOfTeacherMap.put(st.School__c, new Set<Id>());
        }  

        //now query all the junction records where the teacher is active and the schools are in the set 
        for(Teach_Multiple_School__c schoolTeacher : [SELECT School__c, Teacher__c, uniqueSTCombo__c
                                                        FROM Teach_Multiple_School__c
                                                        WHERE Teacher__r.Active__c = true AND School__c IN : schoolIdSet])
        {
            CustomLog.log(CustomLog.LogLevel.INFO, 'JunctionHelper', 'Populate', 'Populate the map with the set of active teacher\'s ids for each school', null);
            //and populate the map with the set of active teacher's ids for each school
            schoolSetOfTeacherMap.get(schoolTeacher.School__c).add(schoolTeacher.Teacher__c);           
        }

        updateTeachersNumber(schoolSetOfTeacherMap);
    }

    //when teacher's active status is changed
    public static void updateActiveTeachersIndirect(List<Teacher__c> newTeacherList, Map<Id, Teacher__c> oldTeacherMap){
        
        Set<Id> teacherIdSet = new Set<Id>(); //set of teacher's Ids appeared in the teacher list (newTeacherList)
        Teacher__c oldTeacher; //instance of a teacher object where we get the previous status before the update
        //for each teacher in the newTeacherList
        for(Teacher__c teacher : newTeacherList){
            oldTeacher = oldTeacherMap.get(teacher.Id); //intialize the old teacher object
            if(teacher.Active__c != oldTeacher.Active__c){ //and check if there is any change in the activity status for that particular techer
                teacherIdSet.add(teacher.Id); //if so, put that teacher id in the set of techer's ids
            }
        }
        //map with the set of IDs, for deduplicating data 
        Map<Id, Set<Id>> schoolSetOfTeacherMap = new Map<Id, Set<Id>>(); //[id]school, [value]set of teachers ids for that particular school
        Set<Id> schoolIdSet = new Set<Id>(); //set of school's Ids appearing in the junction records where the activity status of the teacher is changed
        //get all the junction records where the status of the teacher is changed 
        List<Teach_Multiple_School__c> schoolTeacherIncluded = [SELECT School__c, Teacher__c
                                                                FROM Teach_Multiple_School__c
                                                                WHERE Teacher__c IN : teacherIdSet];
        //for each junction record populate the school's ids set
        for(Teach_Multiple_School__c stIncluded : schoolTeacherIncluded){
            schoolIdSet.add(stIncluded.School__c);
        }
        //now query again all the junction records where the teacher is active and the schools are in the set
        schoolTeacherIncluded = [SELECT School__c, Teacher__c
                                FROM Teach_Multiple_School__c
                                WHERE Teacher__r.Active__c = true AND School__c IN : schoolIdSet];

        for(Teach_Multiple_School__c stIncluded : schoolTeacherIncluded){
            if(!schoolSetOfTeacherMap.containsKey(stIncluded.School__c)){
                schoolSetOfTeacherMap.put(stIncluded.School__c, new Set<Id>{stIncluded.Teacher__c});
            }
            schoolSetOfTeacherMap.get(stIncluded.School__c).add(stIncluded.Teacher__c);
        }
        
        List<School__c> schoolsToBeUpdated = new List<School__c>();

        for(Id id : schoolIdSet){
            if(!schoolSetOfTeacherMap.containsKey(id)){
                schoolsToBeUpdated.add(new School__c(Id = id, NumberOfTeachersJ__c = 0));
            }
            else{
                schoolsToBeUpdated.add(new School__c(Id = id, NumberOfTeachersJ__c = schoolSetOfTeacherMap.get(id).size()));
            }          
        }

        update schoolsToBeUpdated;
    }

    private static void updateTeachersNumber(Map<Id, Set<Id>> schoolSetOfTeacherMap){

        List<School__c> schoolsToBeUpdated = new List<School__c>();

        for(Id schoolId : schoolSetOfTeacherMap.keySet()){
            schoolsToBeUpdated.add(
                    new School__c(Id = schoolId, NumberOfTeachersJ__c = schoolSetOfTeacherMap.get(schoolId).size())
                );  
        }

        update schoolsToBeUpdated;
    }
}