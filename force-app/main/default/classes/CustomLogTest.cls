@isTest
private class CustomLogTest {

    @IsTest
	public static void testLog() {
               
        Integer logCount;

        CustomLogSettings__c cs = new CustomLogSettings__c(Name = 'JunctionHelper', LogActive__c = true, LogLevel__c = 'DEBUG', MaxRecords__c = 5);
        insert cs;

        //case 1: valid logging
        CustomLog.log(CustomLog.LogLevel.WARNING, 'JunctionHelper', 'Testclass message x', 'Long description of the message', null);
        CustomLog.commitLogs();
        logCount = database.countQuery('SELECT COUNT() FROM CustomLog__c');       
        System.assertEquals(1, logCount, 'Case 1: Number of logs created.');

        //case 2: max nr of logs
        for(Integer t = 2; t <= 5; t++){
            CustomLog.log(CustomLog.LogLevel.WARNING, 'JunctionHelper', 'Testclass message ' + t, 'Long description of the message', null);
        }
        CustomLog.commitLogs();
        logCount = database.countQuery('SELECT COUNT() FROM CustomLog__c');
        System.assertEquals(4, logCount, 'Case 2: Number of logs created.');

        //case 3: try to get over the max number of logs => oldest 10 log records should be removed
        CustomLog.log(CustomLog.LogLevel.WARNING, 'JunctionHelper', 'Testclass message 6', 'Long description of the message', null);
        CustomLog.commitLogs();
        logCount = database.countQuery('SELECT COUNT() FROM CustomLog__c');       
        System.assertEquals(1, logCount, 'Case 3: Number of logs.');

        //case 4: save multiple records at the same time
        CustomLog.log(CustomLog.LogLevel.WARNING, 'JunctionHelper', 'Testclass message 7', 'Long description of the message', null);
        CustomLog.log(CustomLog.LogLevel.WARNING, 'JunctionHelper', 'Testclass message 8', 'Long description of the message', null);
        CustomLog.log(CustomLog.LogLevel.WARNING, 'JunctionHelper', 'Testclass message 9', 'Long description of the message', null);
        logCount = database.countQuery('SELECT COUNT() FROM CustomLog__c');    
        
        //number of logs in the DB should still be 1
        System.assertEquals(1, logCount, 'Case 4: Number of logs.');

        //save the logs in the DB
        CustomLog.commitLogs();

        logCount = database.countQuery('SELECT COUNT() FROM CustomLog__c');
        List<CustomLog__c> test = [SELECT Id, Message__c FROM CustomLog__c];
        System.assertEquals(4, logCount, 'Case 4: Number of logs.');
    }      
    
    @isTest
    public static void csCreationTest(){
        try{
            CustomLog.log(CustomLog.LogLevel.WARNING, 'JunctionHelper', 'Testclass message fail', 'Long description of the message', null);
            CustomLogSettings__c cs = [SELECT LogActive__c, MaxRecords__c FROM CustomLogSettings__c WHERE Name = 'JunctionHelper'];
            System.assertEquals(true, cs.LogActive__c, 'LogActive__c');
            System.assertEquals(1000, cs.MaxRecords__c, 'MaxRecords__c');
        } catch(Exception ex){
            System.debug('Custom log setting is not automatically created.');
        }
    }

    @isTest 
    public static void isLevelHigherOrEqualTest(){
        //case 1: log level is set to DEBUG
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('DEBUG', 'DEBUG'), 'Case 1: Debug');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('DEBUG', 'INFO'), 'Case 1: Info');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('DEBUG', 'WARNING'), 'Case 1: Warning');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('DEBUG', 'ERROR'), 'Case 1: Error');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('DEBUG', 'FATAL'), 'Case 1: Fatal');

        //case 2: log level is set to INFO
        System.assertEquals(false, CustomLog.isLevelHigherOrEqual('INFO', 'DEBUG'), 'Case 2: Debug');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('INFO', 'INFO'), 'Case 2: Info');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('INFO', 'WARNING'), 'Case 2: Warning');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('INFO', 'ERROR'), 'Case 2: Error');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('INFO', 'FATAL'), 'Case 2: Fatal');

        //case 3: log level is set to WARNING
        System.assertEquals(false, CustomLog.isLevelHigherOrEqual('WARNING', 'DEBUG'), 'Case 3: Debug');
        System.assertEquals(false, CustomLog.isLevelHigherOrEqual('WARNING', 'INFO'), 'Case 3: Info');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('WARNING', 'WARNING'), 'Case 3: Warning');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('WARNING', 'ERROR'), 'Case 3: Error');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('WARNING', 'FATAL'), 'Case 3: Fatal');

        //case 4: log level is set to ERROR
        System.assertEquals(false, CustomLog.isLevelHigherOrEqual('ERROR', 'DEBUG'), 'Case 4: Debug');
        System.assertEquals(false, CustomLog.isLevelHigherOrEqual('ERROR', 'INFO'), 'Case 4: Info');
        System.assertEquals(false, CustomLog.isLevelHigherOrEqual('ERROR', 'WARNING'), 'Case 4: Warning');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('ERROR', 'ERROR'), 'Case 4: Error');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('ERROR', 'FATAL'), 'Case 4: Fatal');

        //case 5: log level is set to FATAL
        System.assertEquals(false, CustomLog.isLevelHigherOrEqual('FATAL', 'DEBUG'), 'Case 5: Debug');
        System.assertEquals(false, CustomLog.isLevelHigherOrEqual('FATAL', 'INFO'), 'Case 5: Info');
        System.assertEquals(false, CustomLog.isLevelHigherOrEqual('FATAL', 'WARNING'), 'Case 5: Warning');
        System.assertEquals(false, CustomLog.isLevelHigherOrEqual('FATAL', 'ERROR'), 'Case 5: Error');
        System.assertEquals(true, CustomLog.isLevelHigherOrEqual('FATAL', 'FATAL'), 'Case 5: Fatal');
    }
}