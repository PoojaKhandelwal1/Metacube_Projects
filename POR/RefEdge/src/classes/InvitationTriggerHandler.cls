/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, 
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, 
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR, 
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF 
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING, 
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS 
 * WRITTEN CONSENT FROM COMPANY.
 */
public with sharing class InvitationTriggerHandler {
    /**
     * Properties and variables
     */
    public static list < Invitation__c > newInvitations;
    public static list < Invitation__c > oldInvitations;
    public static map < Id, Invitation__c > newInvitationsMap;
    public static map < Id, Invitation__c > oldInvitationsMap;

    /**
     * Method called on after insert of Invitation
     */
    public static void onAfterInsert() {
        list < Reference_Requests_and_Invitations__c > listNewRRI = new list < Reference_Requests_and_Invitations__c > ();
        for (Invitation__c inv: newInvitations) {
            if (inv.Opportunity__c != null) {
                listNewRRI.add(new Reference_Requests_and_Invitations__c(Opportunity__c = inv.Opportunity__c, Invitation__c = inv.Id));
            }
        }

        //Insert New RRI
        if (listNewRRI.size() > 0)
            insert listNewRRI; 
    }

    /**
     * Method called on after update of Invitation
     */
    public static void onAfterUpdate() {
        list < Reference_Requests_and_Invitations__c > listNewRRI = new list < Reference_Requests_and_Invitations__c > ();
        set < Id > oldInvitationIds = new set < Id > ();
        for (Invitation__c inv: newInvitations) {
            if (newInvitationsMap.get(inv.Id).Opportunity__c != oldInvitationsMap.get(inv.Id).Opportunity__c) {
                if (newInvitationsMap.get(inv.Id).Opportunity__c != null) {
                    listNewRRI.add(new Reference_Requests_and_Invitations__c(Opportunity__c = inv.Opportunity__c, Invitation__c = inv.Id));
                }
                if (oldInvitationsMap.get(inv.Id).Opportunity__c != null) {
                    oldInvitationIds.add(inv.Id);
                }
            }
        }

        //Delete old RRI    
        list < Reference_Requests_and_Invitations__c > listOldRRI = [SELECT Id FROM Reference_Requests_and_Invitations__c Where Invitation__c IN: oldInvitationIds];
        if (listOldRRI.size() > 0)
            delete listOldRRI;

        //Insert New RRI
        if (listNewRRI.size() > 0)
            insert listNewRRI;
    }

    /**
     * Method called on after delete of Invitation
     */
    public static void onAfterDelete() {
        //Delete old RRI
        list < Reference_Requests_and_Invitations__c > listOldRRI = [SELECT Id FROM Reference_Requests_and_Invitations__c WHERE Invitation__c = null AND Reference_Request__c = null];
        if (listOldRRI.size() > 0)
            delete listOldRRI;
    }

    /**
     * Method called on after undelete of Invitation
     */
    public static void onAfterUndelete() {
        list < Reference_Requests_and_Invitations__c > listNewRRI = new list < Reference_Requests_and_Invitations__c > ();
        list < Reference_Requests_and_Invitations__c > deleteRRI = new list < Reference_Requests_and_Invitations__c > ();
        set < Id > invitationIds = new set < Id > ();
        for (Invitation__c inv: newInvitations) {
            if (inv.Opportunity__c != null) {
                invitationIds.add(inv.Id);
            }
        }

        for (Invitation__c inv: [SELECT Id, Opportunity__c, (Select Id, Opportunity__c From Reference_Requests_and_Invitations__r order by CreatedDate ASC) FROM Invitation__c WHERE Id IN: invitationIds]) {
            Integer countRRI = 0;
            for (Reference_Requests_and_Invitations__c rri: inv.Reference_Requests_and_Invitations__r) {
                countRRI++;
                if (countRRI != 1) {
                    deleteRRI.add(rri);
                }
            }
            if (countRRI == 0)
                listNewRRI.add(new Reference_Requests_and_Invitations__c(Opportunity__c = inv.Opportunity__c, Invitation__c = inv.Id));
        }

        //Insert New RRI
        if (listNewRRI.size() > 0)
            insert listNewRRI;

        //Delete RRI
        if (deleteRRI.size() > 0)
            delete deleteRRI;
    }
}