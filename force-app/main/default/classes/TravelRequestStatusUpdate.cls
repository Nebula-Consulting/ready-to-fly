/**
 * @author jasonf@nebulaconsulting.co.uk
 * @date 20/10/2022
 * @description Create Slack message when the Request status has updated
 */

global without sharing class TravelRequestStatusUpdate implements nebc.AfterUpdate {
    @TestVisible
    private static SlackHandler slackServiceHandler = new SlackService();

    public void handleAfterUpdate(List<Travel_Request__c> oldList, List<Travel_Request__c> newList) {
        Map<Id, String> slackUserIdsBySalesforceUserId = TravelRequestService.preloadUserMappings(newList);
        Map<Id, User> usersById = TravelRequestService.preloadOwnerNames(newList);

        List<SlackMessage> messagesToProcess = (List<SlackMessage>) new nebc.LazyTriggerContextPairIterator(oldList, newList)
                .filterT(new nebc.IsFieldChangedInTrigger(Travel_Request__c.Status__c))
                .newRecords()
                .mapValuesT(new SetSlackMessage(slackUserIdsBySalesforceUserId, usersById))
                .toList(new List<SlackMessage>());

        if (messagesToProcess.size() > 0) {
            slackServiceHandler.processMessages(messagesToProcess);
        }
    }
}