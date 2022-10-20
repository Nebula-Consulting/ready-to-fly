/**
 * @author samuelf@nebulaconsulting.co.uk
 * @date 20/10/2022
 */

trigger TravelRequestTrigger on Travel_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new nebc.MetadataTriggerManager(Travel_Request__c.SObjectType).handle();
}