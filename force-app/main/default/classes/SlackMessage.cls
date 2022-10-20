public with sharing class SlackMessage {
    public Id id;
    public String name;
    public String description;
    public String origin;
    public String destination;
    public Date startDate;
    public Date endDate;
    public Decimal cost;
    public String status;
    public String ownerName;
    public String userId;
    public String instanceUrl;

    public SlackMessage() {}

    public SlackMessage(Travel_Request__c request, Map<Id, String> slackUserIdsBySalesforceUserId, Map<Id, User> usersById) {
        Id destinationUserId;

        if (request.Status__c == 'New') {
            destinationUserId = request.Approver__c;
        } else {
            destinationUserId = request.OwnerId;
        }

        id = request.Id;
        name = request.Name;
        description = request.Description__c;
        origin = request.Origin__c;
        destination = request.Destination__c;
        startDate = request.Start_Date__c;
        endDate = request.End_Date__c;
        cost = request.Cost__c.intValue();
        status = request.Status__c;
        ownerName = usersById.get(request.OwnerId).Name;
        userId = slackUserIdsBySalesforceUserId.get(destinationUserId);
        instanceUrl = Url.getSalesforceBaseUrl().toExternalForm();
    }
}
