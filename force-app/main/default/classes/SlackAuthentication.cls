/**
 * @author danb@nebulaconsulting.co.uk
 * @date 20/10/2022
 * @description Manage slack authentication
 */

public inherited sharing class SlackAuthentication {

    private nebc.SObjectIndex authenticationsByUser;

    public SlackAuthentication(Set<Id> userIds) {
        authenticationsByUser = new nebc.SObjectIndex(Slack_Authentication__c.User__c)
                .putAll([
                        SELECT Slack_User_ID__c, User__c, User__r.Name
                        FROM Slack_Authentication__c
                        WHERE User__c IN :userIds
                ]);
    }

    private Slack_Authentication__c getAuthentication(Id userId) {
        return (Slack_Authentication__c) authenticationsByUser.get(userId);
    }

    public String getSlackUserId(Id userId) {
        return getAuthentication(userId)?.Slack_User_ID__c;
    }

    public String getSlackUserName(Id userId) {
        return getAuthentication(userId)?.User__r.Name;
    }

    public Boolean hasAuthentication(Id userId) {
        return getAuthentication(userId) != null;
    }

}