/**
 * @author
 * @date
 */

@IsTest
public with sharing class SlackMock implements HttpCalloutMock {

    public Boolean throwError;
    public Integer messageCount = 0;

    public HttpResponse respond(HttpRequest req) {
        // Assert request is correctly built
        Bolt_App_Config__mdt record = SlackService.getBoltAppRecord();
        Blob signature = Crypto.generateMac(
                'HmacSHA256',
                Blob.valueOf(req.getBody()),
                Blob.valueOf(record.HMACKey__c)
        );

        System.assertEquals(
                'callout:boltApp/salesforce/message',
                req.getEndpoint()
        );
        System.assertEquals('POST', req.getMethod());
        System.assertEquals(
                'application/json;charset=UTF-8',
                req.getHeader('Content-Type')
        );
        System.assertEquals(
                EncodingUtil.base64Encode(signature),
                req.getHeader('x-salesforce-signature')
        );

        // Create fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(req.getBody());
        if (throwError == true) {
            res.setStatusCode(500);
            res.setStatus('Failure');
        } else {
            res.setStatusCode(200);
            res.setStatus('Success');
        }
        messageCount++;
        System.debug('mock!');

        return res;
    }
}
