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
/** 
 * Page : Nomination Attributes
 * Description:  Class used to handle Nomination Attributes
 * Last Modified By: Rajesh @Feb 4 2017
 */
public with sharing class NominationAttributesInlineController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Nomination__c nomination { get; set; }
    public List<Nomination_Label__c> nominationList { get; set; }
    public Map<Id, List<String>> filterAttributes { get; set; }
    
    /**
     * Constructor
     */
    public NominationAttributesInlineController(ApexPages.StandardController controller) {
        nomination = (Nomination__c)controller.getRecord();
        nominationList = [SELECT Id, Name, Label__c, Label__r.Name FROM Nomination_Label__c WHERE Nomination__c = :nomination.Id];
        filterAttributes = new Map<Id, List<String>>();
        
        for (Nomination_Label__c nomi : nominationList) {
            filterAttributes.put(nomi.Id, new List <String>());
        }
        
        for (Nomination_Label_Attribute__c NLA : [SELECT Attribute__c, Attribute__r.Name, Nomination_Label__c 
        						FROM Nomination_Label_Attribute__c WHERE Nomination_Label__c IN :filterAttributes.keySet()]) {
            
            if (filterAttributes.containsKey(NLA.Nomination_Label__c)) {
                filterAttributes.get(NLA.Nomination_Label__c).add(NLA.Attribute__r.Name);
            }
        }
    }
}