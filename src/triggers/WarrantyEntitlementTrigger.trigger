/**
 * Description: This trigger will update warranty type and expire date on related Purchase Order.
 * It also inactive purchase order status whenever the warranty entitlement expires.
 *
 * Created By: Siddharth Pandit
 * Created Date: 16/04/2015
 **/
trigger WarrantyEntitlementTrigger on Warranty_Entitlement__c (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        WarrantyEntitlementTriggerHandler.updateSLAType (Trigger.new);
    }

    // Inactive the PO status on warranty expire
    if (Trigger.isAfter && Trigger.isInsert) {
        WarrantyEntitlementTriggerHandler.updateInactiveStatus (Trigger.new);
    }
}