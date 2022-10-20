/**
 * @author jasonf@nebulaconsulting.co.uk
 * @date 20/10/2022
 * @description Create Slack message for newly inserted requests
 */

global without sharing class TravelRequestNewReqCreateMessage implements nebc.AfterInsert {
    @TestVisible
    private static SlackHandler slackServiceHandler = new SlackService();

    public void handleAfterInsert(List<Travel_Request__c> newList) {
        Map<Id, String> slackUserIdsBySalesforceUserId = TravelRequestService.preloadUserMappings(newList);
        Map<Id, User> usersById = TravelRequestService.preloadOwnerNames(newList);

        List<SlackMessage> messagesToProcess = (List<SlackMessage>) new nebc.LazySObjectIterator(newList)
                .mapValuesT(new SetSlackMessage(slackUserIdsBySalesforceUserId, usersById))
                .toList(new List<SlackMessage>());

        if (messagesToProcess.size() > 0) {
            slackServiceHandler.processMessages(messagesToProcess);
        }
    }
}