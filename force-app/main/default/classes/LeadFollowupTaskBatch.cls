/**
 * @description Batch class to create follow-up tasks for open leads that have been open for more than 60 days
 * @author Generated via Claude Code for KAN-1
 */
public with sharing class LeadFollowupTaskBatch implements Database.Batchable<SObject> {

    private static final Integer DAYS_THRESHOLD = 60;
    private static final Integer TASK_DUE_DAYS = 2;
    private static final String TASK_SUBJECT = 'Close the lead or mark it dummy';

    /**
     * @description Start method to query open leads older than 60 days
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date cutoffDate = Date.today().addDays(-DAYS_THRESHOLD);

        return Database.getQueryLocator([
            SELECT Id, OwnerId, Name, CreatedDate, Status
            FROM Lead
            WHERE Status = 'Open'
            AND CreatedDate < :cutoffDate
            WITH USER_MODE
        ]);
    }

    /**
     * @description Execute method to create follow-up tasks for each lead
     * @param bc Database.BatchableContext
     * @param scope List of Lead records to process
     */
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        if (scope == null || scope.isEmpty()) {
            return;
        }

        List<Task> tasksToInsert = new List<Task>();
        Date dueDate = Date.today().addDays(TASK_DUE_DAYS);

        for (Lead lead : scope) {
            Task followupTask = new Task(
                Subject = TASK_SUBJECT,
                WhatId = lead.Id,
                OwnerId = lead.OwnerId,
                ActivityDate = dueDate,
                Status = 'Not Started',
                Priority = 'Normal',
                Description = 'This lead has been open for more than ' + DAYS_THRESHOLD + ' days. Please review and take action.'
            );
            tasksToInsert.add(followupTask);
        }

        if (!tasksToInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(tasksToInsert, false);

            // Log any errors
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error error : results[i].getErrors()) {
                        System.debug(LoggingLevel.ERROR,
                            'Error creating task for Lead ' + scope[i].Id + ': ' + error.getMessage());
                    }
                }
            }
        }
    }

    /**
     * @description Finish method for batch completion
     * @param bc Database.BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedDate
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
            WITH USER_MODE
        ];

        System.debug(LoggingLevel.INFO,
            'LeadFollowupTaskBatch completed. Status: ' + job.Status +
            ', Processed: ' + job.JobItemsProcessed + '/' + job.TotalJobItems +
            ', Errors: ' + job.NumberOfErrors);
    }
}
