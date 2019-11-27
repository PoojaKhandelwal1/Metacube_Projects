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
 * Page: AssociatedRefContAccounts
 * Description : Class used to show Attribute Mappings on Reference Content detail page.
 * Modified by: Rekha @Feb 3 2017
 */
public without sharing class AssociatedRefContAccountsController {
    /**
     * Properties and variables
     */
    public List<Account> listAccount { get; set; }
    
    /**
     * Constructor
     */
    public AssociatedRefContAccountsController() {
        String refContentId = ApexPages.currentPage().getParameters().get('refContentId');
        listAccount = new List<Account>();
        
        if (refContentId != null && refContentId.trim().length() > 0) {
            List<Reference_Content__c> refContents = [SELECT Id, Name, (SELECT Id, Account__c FROM Account_Reference_Contents__r) 
            									FROM Reference_Content__c WHERE Id = : refContentId LIMIT 1];
            Set<String> accountIds = new Set<String>();
            
            if (refContents.size() > 0) {
            
	            for (Account_Reference_Content__c arc : refContents[0].Account_Reference_Contents__r) {
	                accountIds.add(arc.Account__c);
	            }
	            listAccount = [SELECT Id, Name, Type, Phone, 
	            				(SELECT Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r 
	            				WHERE Generic_Account__c = false AND Contact__c = null) 
	            				FROM Account WHERE Id In: accountIds];
            }
        }
    }
}