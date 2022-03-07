trigger TeacherTrigger on Teacher__c (after insert, after update, after delete) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            TeacherHelper.insertDeleteActiveTeachers(Trigger.new);
        } else if(Trigger.isUpdate){
            TeacherHelper.updateActiveTeachers(Trigger.new, Trigger.oldMap);
            JunctionHelper.updateActiveTeachersIndirect(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isDelete){
            TeacherHelper.insertDeleteActiveTeachers(Trigger.old);
        } 
    }
  }