public with sharing class TravelRequestTriggerHandler {

    @TestVisible
    private static SlackHandler slackServiceHandler = new SlackService();

    public static void afterInsert(List<Travel_Request__c> requests) {
        afterUpdate(requests, null);
    }

    public static void afterUpdate(List<Travel_Request__c> requests, Map<Id, Travel_Request__c> oldRequestsById) {

        CreateSlackMessage slackMessageCreator = new CreateSlackMessage(requests);

        new nebc.LazyTriggerContextPairIterator(oldRequestsById?.values(), requests)
                .filterT(new nebc.IsFieldChangedInTrigger(Travel_Request__c.Status__c))
                .newRecords()
                .forEach(slackMessageCreator);

        slackServiceHandler.processMessages(slackMessageCreator.messages);
    }

    public class CreateSlackMessage implements nebc.VoidFunction {

        private SlackAuthentication slackAuthentication;
        public List<SlackMessage> messages = new List<SlackMessage>();

        public CreateSlackMessage(List<Travel_Request__c> requests) {
            this.slackAuthentication = getSlackAuthentication(requests);
        }

        private SlackAuthentication getSlackAuthentication(List<Travel_Request__c> requests) {
            Set<Id> userIds = new Set<Id>();

            new nebc.LazySObjectIterator(requests)
                    .addTo(Travel_Request__c.OwnerId, userIds)
                    .addTo(Travel_Request__c.Approver__c, userIds)
                    .forEach();

            return new SlackAuthentication(userIds);
        }

        public void call(Object o) {
            Travel_Request__c request = (Travel_Request__c) o;

            Id destinationUserId = request.Status__c == 'New' ? request.Approver__c : request.OwnerId;

            if (slackAuthentication.hasAuthentication(destinationUserId)) {
                // Just post message if user authenticated from slack
                SlackMessage message = new SlackMessage();
                message.id = request.Id;
                message.name = request.Name;
                message.description = request.Description__c;
                message.origin = request.Origin__c;
                message.destination = request.Destination__c;
                message.startDate = request.Start_Date__c;
                message.endDate = request.End_Date__c;
                message.cost = request.Cost__c.intValue();
                message.status = request.Status__c;
                message.ownerName = slackAuthentication.getSlackUserName(request.OwnerId);
                message.userId = slackAuthentication.getSlackUserId(destinationUserId);
                message.instanceUrl = Url.getSalesforceBaseUrl().toExternalForm();

                messages.add(message);
            }

        }

    }

}
