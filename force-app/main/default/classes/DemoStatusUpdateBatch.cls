/**
 * Batch class to update Demo__c records with Tag__c = 'Archive' to Status__c = 'Archive'.
 */
public with sharing class DemoStatusUpdateBatch implements Database.Batchable<SObject> {
    
    /**
     * Start method - Query records where Tag__c equals 'Archive' and Status__c is not 'Archive'
     * @param bc BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String archiveTag = 'Archive';
        String archiveStatus = 'Archive';
        
        return Database.getQueryLocator([
            SELECT Id, Status__c, Tag__c 
            FROM Demo__c 
            WHERE Tag__c = :archiveTag 
            AND Status__c != :archiveStatus
            WITH USER_MODE
        ]);
    }
    
    /**
     * Execute method - Update Status__c field to 'Archive' for matched records
     * @param bc BatchableContext
     * @param scope List of Demo__c records to process
     */
    public void execute(Database.BatchableContext bc, List<Demo__c> scope) {
        List<Demo__c> recordsToUpdate = new List<Demo__c>();
        
        for (Demo__c demo : scope) {
            demo.Status__c = 'Archive';
            recordsToUpdate.add(demo);
        }
        
        if (!recordsToUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(recordsToUpdate, false);
            
            // Log any errors
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error error : results[i].getErrors()) {
                        System.debug(LoggingLevel.ERROR, 
                            'Error updating Demo__c record Id ' + recordsToUpdate[i].Id + 
                            ': ' + error.getMessage());
                    }
                }
            }
        }
    }
    
    /**
     * Finish method - Log completion
     * @param bc BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedDate 
            FROM AsyncApexJob 
            WHERE Id = :bc.getJobId()
        ];
        
        System.debug('Batch job completed. Status: ' + job.Status + 
                    ', Items Processed: ' + job.JobItemsProcessed + 
                    ', Errors: ' + job.NumberOfErrors);
    }
}
