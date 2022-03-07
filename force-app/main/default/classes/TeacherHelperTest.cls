@isTest
private class TeacherHelperTest {
    
    @TestSetup
    static void makeData(){
        insert new School__c(Name = 'VU');
    }

    @isTest
    private static void updateActiveTeachersAfertInsertAndDeleteTest(){

        School__c school = [SELECT Id, Number_of_teachers__c FROM School__c LIMIT 1];

        System.assertEquals(null, school.Number_of_teachers__c, 'School without active teachers');

        Teacher__c teacherActive = new Teacher__c(Name = 'Vesna', School_Name__c = school.Id, Active__c = true);
        insert teacherActive;

        school = [SELECT Id, Number_of_teachers__c FROM School__c WHERE Id = :school.Id];
        System.assertEquals(1, school.Number_of_teachers__c, 'An active teacher was inserted.');

        Teacher__c teacherInactive = new Teacher__c(Name = 'Floriana', School_Name__c = school.Id, Active__c = false);
        insert teacherInactive;

        school = [SELECT Id, Number_of_teachers__c FROM School__c WHERE Id = :school.Id];
        System.assertEquals(1, school.Number_of_teachers__c, 'An inactive teacher was inserted.');

        delete teacherInactive;

        school = [SELECT Id, Number_of_teachers__c FROM School__c WHERE Id = :school.Id];
        System.assertEquals(1, school.Number_of_teachers__c, 'An inactive teacher was deleted.');
        
        delete teacherActive;

        school = [SELECT Id, Number_of_teachers__c FROM School__c WHERE Id = :school.Id];
        System.assertEquals(0, school.Number_of_teachers__c, 'An active teacher was deleted.');
    }

    @isTest
    private static void updateActiveTeachersAfterSchoolChangeTest(){
        School__c VU = [SELECT Id, Number_of_teachers__c FROM School__c LIMIT 1];
        School__c UVA = new School__c(Name = 'Universiteit van Amsterdam');
        insert UVA;

        Teacher__c teacher = new Teacher__c (Name= 'Ana', School_Name__c = VU.Id, Active__c = true);
        insert teacher;
            
        VU = [SELECT Id, Number_of_teachers__c FROM School__c WHERE Id = :VU.Id];
        System.assertEquals(1, VU.Number_of_teachers__c, 'VU should have 1 active teacher.');

        System.Test.startTest();

        teacher.School_Name__c = UVA.Id;
        update teacher;
        System.debug(teacher);

        System.Test.stopTest();

        VU = [SELECT Id, Number_of_teachers__c FROM School__c WHERE Id = :VU.Id];
        System.assertEquals(0, VU.Number_of_teachers__c, 'VU should have an active teacher');
        UVA = [SELECT Id, Number_of_teachers__c FROM School__c WHERE Id = :UVA.Id];
        System.assertEquals(null, UVA.Number_of_teachers__c, 'UVA should have 1 active teacher');
    }

    @isTest
    private static void updateActiveTeachersAfterActiveChangeTest(){
        School__c school = [SELECT Id, Number_of_teachers__c FROM School__c LIMIT 1];

        Teacher__c teacher = new Teacher__c (Name = 'Floriana', School_Name__c = school.Id, Active__c = true);
        insert teacher;

        school = [SELECT Id, Number_of_teachers__c FROM School__c WHERE Id = :school.Id];
        System.assertEquals(1, school.Number_of_teachers__c, 'School should have 1 active teacher.');

        teacher.Active__c = false;
        update teacher;

        school = [SELECT Id, Number_of_teachers__c FROM School__c WHERE Id = :school.Id];
        System.assertEquals(0, school.Number_of_teachers__c, 'School should not have an active teacher.');

        teacher.Active__c = true;
        update teacher;

        school = [SELECT Id, Number_of_teachers__c FROM School__c WHERE Id = :school.Id];
        System.assertEquals(1, school.Number_of_teachers__c, 'School should have 1 active teacher.');
    } 
}