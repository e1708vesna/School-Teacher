@isTest
private class JunctionHelperTest {
 
  @isTest
  private static void updateActiveTeachersJunctionTest(){
    //insert one school
    School__c school = new School__c(Name = 'VU');
    insert school;

    //insert a list of two teachers
    List<Teacher__c> teachersList = new List<Teacher__c>{
      new Teacher__c (Name='Ana'),
      new Teacher__c (Name='Mike')
    };
    insert teachersList;

    school = [SELECT Id, Name, NumberOfTeachersJ__c FROM School__c WHERE Id = :school.Id];
    System.assertEquals(0, school.NumberOfTeachersJ__c, 'Number of active teachers before the test');

    //case1: insert first teacher for the school
    Teach_Multiple_School__c firstTeacher = new Teach_Multiple_School__c(School__c = school.Id, Teacher__c = teachersList[0].Id);
    insert firstTeacher;

    //check how many active teachers are in the school from junction
    school = [SELECT Id, Name, NumberOfTeachersJ__c FROM School__c WHERE Id = :school.Id];
    System.assertEquals(1, school.NumberOfTeachersJ__c, 'Number of active teachers after inserting the first teacher');

    //case2: insert second teacher for the same school
    Teach_Multiple_School__c secondTeacher = new Teach_Multiple_School__c(School__c = school.Id, Teacher__c = teachersList[1].Id);
    insert secondTeacher;

    //check how many active teachers are in the school from junction
    school = [SELECT Id, Name, NumberOfTeachersJ__c FROM School__c WHERE Id = :school.Id];
    System.assertEquals(2, school.NumberOfTeachersJ__c, 'Number of active teachers after inserting the second teacher');
  }

@isTest
  private static void updateActiveTeachersJunctionBulkTest(){
    //insert bulk, multiple teachers on a school, inlcuding duplicates, for multiple schools
    //insert schools
    List<School__c> schools = new List<School__c>{
      new School__c (Name = 'UVA')
      //new School__c (Name = 'VU')
    };
    insert schools;

    //insert a list of teachers
    List<Teacher__c> teachers = new List<Teacher__c>{
      new Teacher__c (Name = 'Ana'),
      new Teacher__c (Name = 'Mike', Active__c = false),
      new Teacher__c (Name = 'Luke')
    };
    insert teachers;

    List<Teach_Multiple_School__c> junctionList = new List<Teach_Multiple_School__c>{
      new Teach_Multiple_School__c (School__c = schools[0].Id, Teacher__c = teachers[0].Id), //VU, Vesna
      new Teach_Multiple_School__c (School__c = schools[0].Id, Teacher__c = teachers[1].Id), //UVA, Vesna
      new Teach_Multiple_School__c (School__c = schools[0].Id, Teacher__c = teachers[2].Id)    
    };
    insert junctionList;

    schools = [SELECT Id, NumberOfTeachersJ__c FROM School__c ];
    System.assertEquals(2, schools[0].NumberOfTeachersJ__c, 'UVA should have 2 active teachers.');
  }

  @isTest
  private static void updateActiveTeachersRollupBulkTest(){

    Boolean expectedExceptionThrown = false;

    try{
      List<School__c> schools = new List<School__c>{
        new School__c (Name = 'UVA'),
        new School__c (Name = 'VU')
      };
      insert schools;
      
      List<Teacher__c> teachers = new List<Teacher__c>{
        new Teacher__c (Name = 'Ana'),
        new Teacher__c (Name = 'Mike', Active__c = false),
        new Teacher__c (Name = 'Luke')
      };
      insert teachers;
      
      List<Teach_Multiple_School__c> junctionList = new List<Teach_Multiple_School__c>{
        new Teach_Multiple_School__c (School__c = schools[0].Id, Teacher__c = teachers[0].Id, uniqueSTCombo__c = schools[0].Id + '_' + teachers[0].Id), //UVA, Ana
        new Teach_Multiple_School__c (School__c = schools[0].Id, Teacher__c = teachers[0].Id, uniqueSTCombo__c = schools[0].Id + '_' + teachers[0].Id), //UVA, Mike
        new Teach_Multiple_School__c (School__c = schools[0].Id, Teacher__c = teachers[2].Id, uniqueSTCombo__c = schools[0].Id + '_' + teachers[2].Id) //UVA, Luke   
      };
      insert junctionList;
    }
    catch(Exception e){
       expectedExceptionThrown =  e.getMessage().contains('The record You are trying to insert is already existing in the Database.') ? true : false;
    }

    System.assertEquals(expectedExceptionThrown, true);
  }
}