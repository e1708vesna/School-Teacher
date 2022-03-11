public without sharing class CustomLog {

    public enum LogLevel { DEBUG, INFO, WARNING, ERROR, FATAL }
    public static Integer customLogCount = null;
    static List<CustomLog__c> clList = new List<CustomLog__c>();

    //@testVisible
    static CustomLogSettings__c cs;
    private static Map<String, CustomLogSettings__c> csMap = new Map<String,CustomLogSettings__c>(); //key = className
    
    public static void log(LogLevel logLvl, String className, String message, String description, String stackTrace){
        if(cs == null){
            csMap = CustomLogSettings__c.getAll();
            cs = csMap.get(className);

            if(cs == null){
                populateCustomSettings();
            }
        }
        try{
            if(cs.LogActive__c && isLevelHigherOrEqual(cs.LogLevel__c, logLvl.name())){    
                if(message != null && message.length() >= 254){
                    message = message.substring(0, 254);
                }
                if(description != null && description.length() >= 32767){
                    description = description.substring(0, 32767);
                }
                if(stackTrace != null && stackTrace.length() >= 32767){
                    stackTrace = stackTrace.substring(0, 32767);
                }
               
                clList.add(new CustomLog__c(LogLevel__c = logLvl.name(),
                                            ClassName__c = className,
                                            Message__c = message, 
                                            Description__c = description, 
                                            StackTrace__c = stackTrace));

            }
        } catch(Exception ex){
            System.debug('Custom log failed: ' + ex.getMessage() + ' | ' + ex.getStackTraceString());
        }
    }

    public static void commitLogs(){
        if(!clList.isEmpty()){
            try{
                Integer cnt = 0;
                if(cs == null){
                    cs = new CustomLogSettings__c(Name = 'ALL', LogActive__c = true, LogLevel__c = 'DEBUG', MaxRecords__c = 1000);
                    insert cs;
                }
                if(cs.LogActive__c && clList != null && clList.size() > 0){
                    cnt = clList.size();
                    try{
                        customLogCount = database.countQuery('SELECT COUNT() FROM CustomLog__c');
                    } catch (Exception ex){
                        customLogCount = (Integer)cs.MaxRecords__c;   
                    }
                    customLogCount += cnt;
                    cnt += 10;
                    if(customLogCount >= cs.MaxRecords__c){
                        if(cnt > 10000){
                            cnt = 10000;
                        }
                        try{
                            List<CustomLog__c> drList = [SELECT id FROM CustomLog__c ORDER BY CreatedDate LIMIT :cnt];
                            delete drList;
                        } catch(Exception ex) {
                            System.debug('Custom log failed: ' + ex.getMessage());
                        }
                    }
    
                    Database.SaveResult[] srList = Database.insert(clList, false);
                    for(Database.SaveResult sr : srList){
                        if(sr.isSuccess()){
                            //Operation was successfull, so get the ID of the record being proccessed
                            System.debug('Successfully inserted CustomLog__c with ID: ' + sr.getId());
                        }
                        else{
                            //Operation failed so get all the errors
                            for(Database.Error err : sr.getErrors()){
                                System.debug('The following error has occured.');
                                System.debug('Custom log failed: ' + err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('CustomLog__c fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
            } catch (Exception ex){
                System.debug('Custom log failed: ' + ex.getMessage() + ' | ' + ex.getStackTraceString());
            } finally {
                //reset log list
                clList = new List<CustomLog__c>();
            }
        }
    }
    
    @testVisible
    private static Boolean isLevelHigherOrEqual(String csLogLvl, String logLvl){
        return LogLevel.valueOf(logLvl).ordinal() >= LogLevel.valueOf(csLogLvl).ordinal();
    }

    private static void populateCustomSettings(){
        cs = new CustomLogSettings__c(Name = 'ALL', LogActive__c = true, LogLevel__c = 'DEBUG', MaxRecords__c = 1000);
        insert cs;
    }
}