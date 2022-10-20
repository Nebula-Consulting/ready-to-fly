/**
 * @author jasonf@nebulaconsulting.co.uk
 * @date 20/10/2022
 * @description (if required)
 */

public class SetSlackMessage implements nebc.Function {
    Map<Id, String> slackUserIdsBySalesforceUserId;
    Map<Id, User> usersById;

    public SetSlackMessage(Map<Id, String> slackUserIdsBySalesforceUserId, Map<Id, User> usersById) {
        this.slackUserIdsBySalesforceUserId = slackUserIdsBySalesforceUserId;
        this.usersById = usersById;
    }

    public SlackMessage call(Object o) {
        Travel_Request__c thisRequest = (Travel_Request__c) o;
        return new SlackMessage(thisRequest, slackUserIdsBySalesforceUserId, usersById);
    }
}