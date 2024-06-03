global without sharing class deleteAWSFileBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {

    public deleteAWSFileBatch() {
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id from mpComm__c where AWSDeleteDate__c = today and recordType.developerName = 'toBSppEmailReception']);
    }
    
    public void execute(Database.BatchableContext BC, List<mpComm__c> mpCommList){
        List<Id> commIdList =  new List<Id>();
        for (mpComm__c mpComm :mpCommList){
            commIdList.add(mpComm.id);         
        }
        mpInquirytoBAWS.DeleteAWSFiles(commIdList);
    }

    global void finish(Database.BatchableContext BC) {
    }

    global static void run(Integer BatchSize) {
        system.debug('BatchSize = ' + BatchSize);
        Database.executeBatch(new deleteAWSFileBatch(), BatchSize);
    }

    
}