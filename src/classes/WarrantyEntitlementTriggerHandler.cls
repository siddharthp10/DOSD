/**
 * Description: This is a trigger utility class which contains all different methods which
 * will be invoked by triggers on different objects.
 *
 * Created By: Siddharth Pandit
 * Created Date: 16/04/2015
 **/
public with sharing class WarrantyEntitlementTriggerHandler {
        // A method to update SLA and expire date on purchase order object
    public static void updateSLAType (List<Warranty_Entitlement__c> lstWarrantyObj) {
        Map<Id, Warranty_Entitlement__c> ordIdWrrntyMap = new Map<Id, Warranty_Entitlement__c> ();
        for (Warranty_Entitlement__c warrantyEnt : lstWarrantyObj ) {
            if (warrantyEnt.Status__c != 'Expired' && String.isNotBlank(warrantyEnt.Type__c))
                ordIdWrrntyMap.put (warrantyEnt.Purchase_Order__c, warrantyEnt);
        }

        List<Purchase_Order__c> ordListToUpdate = new List<Purchase_Order__c> ();
        for (Purchase_Order__c ord : [SELECT Active_SLAs__c, Status__c,
                                            Expire_Date__c
                                        FROM Purchase_Order__c
                                        WHERE Id IN: ordIdWrrntyMap.keySet ()]) {
            ord.Active_SLAs__c = ordIdWrrntyMap.get (ord.Id).Type__c; // Assigning SLAs
            ord.Expire_Date__c = ordIdWrrntyMap.get (ord.Id).End_Date__c; // Assigning date
            ord.Status__c = 'Active'; // Setting the active status
            ordListToUpdate.add (ord);
        }

        if (ordListToUpdate.size() > 0)
            update ordListToUpdate;
    } // End method

    // A method that will change the purchase order status to Inactive
    public static void updateInactiveStatus (List<Warranty_Entitlement__c> pListWarrantyEnt) {
        Set<Id> purOrdIdSet = new Set<Id> ();
        for (Warranty_Entitlement__c warrEnt : pListWarrantyEnt) {
            if (warrEnt.Status__c == 'Expired') {
                purOrdIdSet.add (warrEnt.Purchase_Order__c);
            }
        }

        List<Purchase_Order__c> purOrdListToUpdate = new List<Purchase_Order__c> ();
        for (Purchase_Order__c purOrd : [SELECT Id, Status__c, Expire_Date__c
                                            FROM Purchase_Order__c
                                            WHERE Id IN :purOrdIdSet
                                            AND Id NOT IN 
                                                (SELECT Purchase_Order__c
                                                    FROM Warranty_Entitlement__c
                                                    WHERE Status__c != 'Expired'
                                                    AND Purchase_Order__c IN :purOrdIdSet)]) {
             purOrd.Status__c = 'Inactive'; // Updating inactive status
             purOrdListToUpdate.add (purOrd);
        }

        System.debug ('Inactive POs @@@ '+ purOrdListToUpdate);
        if (purOrdListToUpdate.size ()> 0)
            update purOrdListToUpdate;
    }
}