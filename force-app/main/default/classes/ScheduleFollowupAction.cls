public with sharing class ScheduleFollowupAction {

    @InvocableMethod(label='Schedule Followup Discussion' description='Schedules a followup discussion with a customer' category='Agent Actions')
    public static List<Result> scheduleFollowup(List<Request> requests) {
        List<Result> results = new List<Result>();
        List<Task> tasksToInsert = new List<Task>();

        for (Request req : requests) {
            Result result = new Result();
            try {
                Task followupTask = new Task();
                followupTask.Subject = 'Follow-up Discussion: ' + req.subject;
                followupTask.Description = req.notes;
                followupTask.ActivityDate = req.followupDate;
                followupTask.Priority = 'Normal';
                followupTask.Status = 'Not Started';

                if (req.relatedToId != null) {
                    followupTask.WhatId = req.relatedToId;
                }

                if (req.assignedToId != null) {
                    followupTask.OwnerId = req.assignedToId;
                } else {
                    followupTask.OwnerId = UserInfo.getUserId();
                }

                tasksToInsert.add(followupTask);
                result.success = true;
                result.message = 'Follow-up scheduled for ' + req.followupDate.format();
            } catch (Exception e) {
                result.success = false;
                result.message = 'Error scheduling follow-up: ' + e.getMessage();
            }
            results.add(result);
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
            for (Integer i = 0; i < tasksToInsert.size(); i++) {
                results[i].taskId = tasksToInsert[i].Id;
            }
        }

        return results;
    }

    public class Request {
        @InvocableVariable(required=true label='Subject')
        public String subject;

        @InvocableVariable(required=true label='Follow-up Date')
        public Date followupDate;

        @InvocableVariable(label='Notes')
        public String notes;

        @InvocableVariable(label='Related To ID')
        public Id relatedToId;

        @InvocableVariable(label='Assigned To User ID')
        public Id assignedToId;
    }

    public class Result {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String message;

        @InvocableVariable
        public Id taskId;
    }
}