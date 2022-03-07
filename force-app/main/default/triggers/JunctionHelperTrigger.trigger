trigger JunctionHelperTrigger on Teach_Multiple_School__c (before insert, after insert, after delete) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            JunctionHelper.updateActiveTeachersRollup(Trigger.new);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            JunctionHelper.updateActiveTeachersJunction(Trigger.new);
        } else if(Trigger.isDelete){
            JunctionHelper.updateActiveTeachersJunction(Trigger.old);
        } 
    }    
}