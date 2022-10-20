/**
 * @author paulk@nebulaconsulting.co.uk
 * @date 20/10/2022
 * @description (if required)
 */

global without sharing class TravelRequestToSlack implements nebc.AfterInsert, nebc.AfterUpdate {

    @TestVisible
    private static SlackHandler slackServiceHandler = new SlackService();

    nebc.SObjectIndex slackUsers;
    Map<Id, User> usersById;

    global void handleAfterInsert(List<Travel_Request__c> newList) {
        preloadMappings(newList);
        handle(new nebc.LazySObjectIterator(newList));
    }

    global void handleAfterUpdate(List<Travel_Request__c> oldList, List<Travel_Request__c> newList) {
        preloadMappings(newList);
        handle(new nebc.LazyTriggerContextPairIterator(oldList, newList)
            .filterT(new nebc.IsFieldChangedInTrigger(Travel_Request__c.Status__c))
            .newRecords());
    }

    private void handle(nebc.LazySObjectIterator iterator) {
        List<SlackMessage> messages = (List<SlackMessage>) iterator
            .filterT(new IsRecipientASlackUser(slackUsers))
            .mapValues(new CreateMessage(slackUsers, usersById))
            .toList(new List<SlackMessage>());

        slackServiceHandler.processMessages(messages);
    }

    private void preloadMappings(List<Travel_Request__c> requests) {
        Set<Id> salesforceUserIds = new Set<Id>();
        new nebc.LazySObjectIterator(requests)
            .addTo(Travel_Request__c.OwnerId, salesforceUserIds)
            .addTo(Travel_Request__c.Approver__c, salesforceUserIds)
            .forEach();

        slackUsers = new nebc.SObjectIndex(Slack_Authentication__c.User__c)
            .putAll([
                SELECT Slack_User_ID__c, User__c
                FROM Slack_Authentication__c
                WHERE User__c IN :salesforceUserIds
                AND Slack_User_ID__c != NULL
            ]);
        usersById = new Map<Id, User>([
            SELECT Name
            FROM User
            WHERE Id IN :salesforceUserIds
        ]);
    }

    private class IsRecipientASlackUser implements nebc.BooleanFunction {

        nebc.SObjectIndex slackUsers;
        public IsRecipientASlackUser(nebc.SObjectIndex slackUsers) {
            this.slackUsers = slackUsers;
        }
        public Boolean isTrueFor(Object o) {
            Travel_Request__c thisTravelRequest = (Travel_Request__c) o;
            Id destinationUserId = 'New'.equals(thisTravelRequest.Status__c) ? thisTravelRequest.Approver__c : thisTravelRequest.OwnerId;
            return slackUsers.get(destinationUserId) != null;
        }
    }

    private class CreateMessage implements nebc.Function {

        nebc.SObjectIndex slackUsers;
        Map<Id, User> usersById;

        public CreateMessage(nebc.SObjectIndex slackUsers, Map<Id, User> usersById) {
            this.slackUsers = slackUsers;
            this.usersById = usersById;
        }
        public Object call(Object o) {
            Travel_Request__c thisTravelRequest = (Travel_Request__c) o;
            Id destinationUserId = 'New'.equals(thisTravelRequest.Status__c) ? thisTravelRequest.Approver__c : thisTravelRequest.OwnerId;
            SlackMessage message = new SlackMessage();

            message.id = thisTravelRequest.Id;
            message.name = thisTravelRequest.Name;
            message.description = thisTravelRequest.Description__c;
            message.origin = thisTravelRequest.Origin__c;
            message.destination = thisTravelRequest.Destination__c;
            message.startDate = thisTravelRequest.Start_Date__c;
            message.endDate = thisTravelRequest.End_Date__c;
            message.cost = thisTravelRequest.Cost__c;
            message.status = thisTravelRequest.Status__c;
            message.ownerName = usersById.get(thisTravelRequest.OwnerId).Name;
            message.userId = getSlackUserId(destinationUserId);
            message.instanceUrl = Url.getSalesforceBaseUrl().toExternalForm();
            return message;
        }
        private String getSlackUserId(Id userId) {
            return ((Slack_Authentication__c) slackUsers.get(userId)).Slack_User_ID__c;
        }
    }

}