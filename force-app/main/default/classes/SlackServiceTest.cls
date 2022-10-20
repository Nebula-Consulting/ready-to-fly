@IsTest
private with sharing class SlackServiceTest {
    @IsTest
    static void postMessagesSuccess() {
        // GIVEN
        Test.setMock(HttpCalloutMock.class, new SlackMock());

        // WHEN
        Test.startTest();
        SlackService.postMessages('Slack rocks!');
        Test.stopTest();

        // THEN
        System.assert(true, 'No exception expected');
    }

    @IsTest
    static void postMessagesFailure() {
        // GIVEN
        String message = 'Slack rocks!';
        SlackMock mock = new SlackMock();
        mock.throwError = true;
        Test.setMock(HttpCalloutMock.class, mock);

        try {
            // WHEN
            Test.startTest();
            SlackService.postMessages(message);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception e) {
            // THEN
            System.assert(
                e instanceof SlackService.SlackException,
                'SlackException exception expected'
            );
            String expectedMessage =
                'Failed to post messages to Slack: HTTP500 Failure - ' +
                message;
            System.assertEquals(
                e.getMessage(),
                expectedMessage,
                'Messages are not equal'
            );
        }
    }

}
