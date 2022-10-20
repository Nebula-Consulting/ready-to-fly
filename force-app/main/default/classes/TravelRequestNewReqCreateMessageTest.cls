/**
 * @author jasonf@nebulaconsulting.co.uk
 * @date 20/10/2022
 */

@IsTest
private class TravelRequestNewReqCreateMessageTest {
    private static nebc.TestRecordSource testRecordSource = new nebc.TestRecordSource();
    private static final User approver = [SELECT Id FROM User WHERE IsActive = TRUE AND UserType = 'Standard' AND Id != :UserInfo.getUserId() LIMIT 1];

    @IsTest
    static void onInsert() {
        SlackTestService slackTestService = new SlackTestService();
        TravelRequestNewReqCreateMessage.slackServiceHandler = slackTestService;

        Test.startTest();
        Travel_Request__c travelRequest = (Travel_Request__c) testRecordSource.getRecord(Travel_Request__c.SObjectType)
                .put(Travel_Request__c.Approver__c, approver.Id)
                .withInsert();

        Test.stopTest();

        Assert.areEqual(slackTestService.messages.size(), 1);
    }

    @IsTest
    static void onInsertNoAuthentication() {
        delete [SELECT Id FROM Slack_Authentication__c];

        SlackTestService slackTestService = new SlackTestService();
        TravelRequestNewReqCreateMessage.slackServiceHandler = slackTestService;

        Test.startTest();
        Travel_Request__c travelRequest = (Travel_Request__c) testRecordSource.getRecord(Travel_Request__c.SObjectType)
                .put(Travel_Request__c.Approver__c, approver.Id)
                .withInsert();
        Test.stopTest();

        Assert.areEqual(slackTestService.messages.size(), 0);
    }

    public class SlackTestService implements SlackHandler {
        private List<SlackMessage> messages;

        public void processMessages(List<SlackMessage> messages) {
            this.messages = messages;
        }
    }

    @TestSetup
    static void setupData() {
        List<Slack_Authentication__c> slackAuthentications = (List<Slack_Authentication__c>) testRecordSource.getRecord(Slack_Authentication__c.SObjectType)
                .withoutInsert(2);

        slackAuthentications[1].User__c = approver.Id;
        slackAuthentications[1].Slack_User_ID__c = 'USERID2';

        insert slackAuthentications;
    }
}