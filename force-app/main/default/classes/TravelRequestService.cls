/**
 * @author jasonf@nebulaconsulting.co.uk
 * @date 20/10/2022
 */

public with sharing class TravelRequestService {
    public static Map<Id, String> preloadUserMappings(List<Travel_Request__c> requests) {
        Map<Id, String> slackUserIdsBySalesforceUserId = new Map<Id, String>();
        Set<Id> salesforceUserIds = new Set<Id>();

        salesforceUserIds.addAll(new nebc.LazySObjectIterator(requests)
                .get(Travel_Request__c.OwnerId)
                .toSet(new Set<Id>())
        );

        salesforceUserIds.addAll(new nebc.LazySObjectIterator(requests)
                .get(Travel_Request__c.Approver__c)
                .toSet(new Set<Id>())
        );

        for (Slack_Authentication__c userMapping : [
                SELECT Id, User__c, Slack_User_ID__c
                FROM Slack_Authentication__c
                WHERE User__c IN :salesforceUserIds
        ]) {
            slackUserIdsBySalesforceUserId.put(
                    userMapping.User__c,
                    userMapping.Slack_User_ID__c
            );
        }
        return slackUserIdsBySalesforceUserId;
    }

    public static Map<Id, User> preloadOwnerNames(
            List<Travel_Request__c> requests
    ) {
        Set<Id> ownerIds = new Set<Id>();
        List<SlackMessage> messages = new List<SlackMessage>();
        for (Travel_Request__c request : requests) {
            ownerIds.add(request.OwnerId);
        }
        List<User> users = [SELECT Name FROM User WHERE Id IN :ownerIds];

        return new Map<Id, User>(users);
    }
}