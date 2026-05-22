public with sharing class GetDemoRecordAction {

    @InvocableMethod(label='Get Demo Record Information' description='Retrieves demo record information' category='Agent Actions')
    public static List<Result> getDemoInfo(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result result = new Result();
            try {
                if (req.recordId != null) {
                    String objectType = req.recordId.getSObjectType().getDescribe().getName();
                    String query = 'SELECT Id, Name, CreatedDate, LastModifiedDate FROM ' + objectType + ' WHERE Id = :req.recordId LIMIT 1';

                    SObject record = Database.query(query);

                    result.success = true;
                    result.recordId = (Id)record.get('Id');
                    result.recordName = (String)record.get('Name');
                    result.createdDate = (Datetime)record.get('CreatedDate');
                    result.lastModifiedDate = (Datetime)record.get('LastModifiedDate');
                    result.message = 'Record information retrieved successfully';
                } else if (req.recordName != null) {
                    List<Account> accounts = [SELECT Id, Name, CreatedDate, LastModifiedDate
                                             FROM Account
                                             WHERE Name LIKE :('%' + req.recordName + '%')
                                             LIMIT 1];

                    if (!accounts.isEmpty()) {
                        result.success = true;
                        result.recordId = accounts[0].Id;
                        result.recordName = accounts[0].Name;
                        result.createdDate = accounts[0].CreatedDate;
                        result.lastModifiedDate = accounts[0].LastModifiedDate;
                        result.message = 'Record found: ' + accounts[0].Name;
                    } else {
                        result.success = false;
                        result.message = 'No record found with name: ' + req.recordName;
                    }
                } else {
                    result.success = false;
                    result.message = 'Please provide either a Record ID or Record Name';
                }
            } catch (Exception e) {
                result.success = false;
                result.message = 'Error retrieving demo information: ' + e.getMessage();
            }
            results.add(result);
        }

        return results;
    }

    public class Request {
        @InvocableVariable(label='Record ID')
        public Id recordId;

        @InvocableVariable(label='Record Name')
        public String recordName;
    }

    public class Result {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String message;

        @InvocableVariable
        public Id recordId;

        @InvocableVariable
        public String recordName;

        @InvocableVariable
        public Datetime createdDate;

        @InvocableVariable
        public Datetime lastModifiedDate;
    }
}