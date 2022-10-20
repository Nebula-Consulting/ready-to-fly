/**
 * @author samuelf@nebulaconsulting.co.uk
 * @date 20/10/2022
 * @description creates and posts slack messages on creation and status change of travel requests
 */

global without sharing class TravelRequestPostSlackMessages implements nebc.AfterInsert, nebc.AfterUpdate {

    @TestVisible
    private static SlackHandler slackServiceHandler = new SlackService();

    global void handleAfterInsert(List<Travel_Request__c> newList) {
        nebc.SObjectIndex slackAuthenticationIndex = getSlackAuthenticationIndex(newList);

        List<SlackMessage> slackMessages = new List<SlackMessage>();
        new nebc.LazySObjectIterator(newList)
                .forEach(new CreateSlackMessage(slackAuthenticationIndex, slackMessages));

        slackServiceHandler.processMessages(slackMessages);
    }

    global void handleAfterUpdate(List<Travel_Request__c> oldList, List<Travel_Request__c> newList) {
        nebc.SObjectIndex slackAuthenticationIndex = getSlackAuthenticationIndex(newList);

        List<SlackMessage> slackMessages = new List<SlackMessage>();
        new nebc.LazyTriggerContextPairIterator(oldList, newList)
                .filterT(new nebc.IsFieldChangedInTrigger(Travel_Request__c.Status__c))
                .newRecords()
                .forEach(new CreateSlackMessage(slackAuthenticationIndex, slackMessages));

        slackServiceHandler.processMessages(slackMessages);
    }

    private nebc.SObjectIndex getSlackAuthenticationIndex(List<Travel_Request__c> requests) {
        Set<Id> ownerAndApproverIds = new Set<Id>();

        new nebc.LazySObjectIterator(requests)
                .addTo(Travel_Request__c.OwnerId, ownerAndApproverIds)
                .addTo(Travel_Request__c.Approver__c, ownerAndApproverIds)
                .forEach();

        return new nebc.SObjectIndex(Slack_Authentication__c.User__c)
                .putAll([
                        SELECT Slack_User_ID__c, User__c, User__r.Name
                        FROM Slack_Authentication__c
                        WHERE User__c IN :ownerAndApproverIds
                ]);
    }

    private inherited sharing class CreateSlackMessage implements nebc.VoidFunction {

        private nebc.SObjectIndex slackAuthenticationIndex;
        private List<SlackMessage> slackMessages;

        public CreateSlackMessage(nebc.SObjectIndex slackAuthenticationIndex, List<SlackMessage> slackMessages) {
            this.slackAuthenticationIndex = slackAuthenticationIndex;
            this.slackMessages = slackMessages;
        }

        public void call(Object o) {
            Travel_Request__c request = (Travel_Request__c) o;
            Id destinationId = request.Status__c == 'New' ? request.Approver__c : request.OwnerId;


            Slack_Authentication__c authentication = (Slack_Authentication__c) slackAuthenticationIndex.get(destinationId);
            if(authentication == null){
                return;
            }

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
            message.ownerName = authentication.User__r.Name;
            message.userId = authentication.User__c;
            message.instanceUrl = Url.getSalesforceBaseUrl().toExternalForm();

            slackMessages.add(message);
        }
    }
}