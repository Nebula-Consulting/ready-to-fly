/**
 * @author paulk@nebulaconsulting.co.uk
 * @date 20/10/2022
 * @description (if required)
 */

trigger TravelRequest on Travel_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new nebc.MetadataTriggerManager(Travel_Request__c.SObjectType).handle();
}