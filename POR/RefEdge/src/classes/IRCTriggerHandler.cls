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
public with sharing class IRCTriggerHandler {
    /**
     * Properties and variables
     */
    public static list < Invitation_ReferenceContent__c > newIRCs;
    public static map < Id, Invitation_ReferenceContent__c > newIRCMap;
    public static map < Id, Invitation_ReferenceContent__c > oldIRCMap;

    /**
     * Method called on after update of Invitation Reference Content
     */
    public static void onAfterUpdate() {
        set < string > setRefContentIds = new set < string > ();
        list < Reference_Content__c > refContents = new list < Reference_Content__c > ();
        for (Invitation_ReferenceContent__c irc: newIRCs) {
            if (newIRCMap.get(irc.Id).Rating__c != oldIRCMap.get(irc.Id).Rating__c)
                setRefContentIds.add(irc.Reference_Content__c);
        }
        for (Reference_Content__c rc: [Select Rating__c, (Select Rating__c From Invitation_ReferenceContents__r) From Reference_Content__c where Id IN: setRefContentIds]) {
            Integer totalIRC = 0;
            Decimal totalRating = 0.0;
            for (Invitation_ReferenceContent__c irc: rc.Invitation_ReferenceContents__r) {
                if (irc.Rating__c != null) {
                    totalRating = totalRating + irc.Rating__c;
                    totalIRC = totalIRC + 1;
                }
            }
            rc.Rating__c = (totalIRC != 0 ? totalRating / totalIRC : totalRating);
            refContents.add(rc);
        }
        if (refContents.size() > 0)
            update refContents;
    }
}