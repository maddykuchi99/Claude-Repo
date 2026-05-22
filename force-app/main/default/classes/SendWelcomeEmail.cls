public with sharing class SendWelcomeEmail {

    @InvocableMethod(label='Send Welcome Email' description='Sends a welcome email to a customer' category='Agent Actions')
    public static List<Result> sendWelcomeEmail(List<Request> requests) {
        List<Result> results = new List<Result>();

        for (Request req : requests) {
            Result result = new Result();
            try {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { req.customerEmail });
                email.setSubject('Welcome to Our Service!');
                email.setPlainTextBody(
                    'Dear ' + req.customerName + ',\n\n' +
                    'Welcome! We are delighted to have you with us.\n\n' +
                    'Our team is here to support you every step of the way. ' +
                    'If you have any questions, please don\'t hesitate to reach out.\n\n' +
                    'Best regards,\n' +
                    'Your Support Team'
                );

                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

                result.success = true;
                result.message = 'Welcome email sent successfully to ' + req.customerEmail;
            } catch (Exception e) {
                result.success = false;
                result.message = 'Error sending email: ' + e.getMessage();
            }
            results.add(result);
        }

        return results;
    }

    public class Request {
        @InvocableVariable(required=true label='Customer Name')
        public String customerName;

        @InvocableVariable(required=true label='Customer Email')
        public String customerEmail;
    }

    public class Result {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String message;
    }
}