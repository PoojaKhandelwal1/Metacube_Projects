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
 * Page : Account->Reference Notes Sections
 * Description: Class handle list view for Reference Notes 
 * Last Modified By: Rajesh @Feb 8 2017
 */
public with sharing class ViewAllReferenceNotesController extends RefEdgeEditionFeatures {
	/**
     * Properties and variables
     */
	private String accountId;
	private String contactId;
	private String contentId;
	public String refReqId { get; set; }
	private String accountReqId;
	private String unspecId;
	public String nomiId { get; set; }
	public List<Reference_Note__c> referenceNotes { get; set; }
	private String soqlQuery ='';
	public Boolean isSLDS { get; set; }
	
	/**
     * Constructor
     */
	public ViewAllReferenceNotesController(ApexPages.standardController controller) {
		
		if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') { 
            isSLDS = true;
        } else { 
            isSLDS = false;
        }
        
		if (ApexPages.currentPage().getParameters().get('AccountId') != null && ApexPages.currentPage().getParameters().get('AccountId') != '') {
			accountId = ApexPages.currentPage().getParameters().get('AccountId');
		}
		
		if (ApexPages.currentPage().getParameters().get('ContactId') != null && ApexPages.currentPage().getParameters().get('ContactId') != '') {
			contactId = ApexPages.currentPage().getParameters().get('ContactId');
		}
		
		if (ApexPages.currentPage().getParameters().get('ContentId') != null && ApexPages.currentPage().getParameters().get('ContentId') != '') {
			contentId = ApexPages.currentPage().getParameters().get('ContentId');
		}
		
		if (ApexPages.currentPage().getParameters().get('AccountReqId') != null && ApexPages.currentPage().getParameters().get('AccountReqId') != '') {
			accountReqId = ApexPages.currentPage().getParameters().get('AccountReqId');
		}
		
		if (ApexPages.currentPage().getParameters().get('RefReqId') != null && ApexPages.currentPage().getParameters().get('RefReqId') != '') {
			refReqId = ApexPages.currentPage().getParameters().get('RefReqId');
		}
		
		if (ApexPages.currentPage().getParameters().get('UnspecId') != null && ApexPages.currentPage().getParameters().get('UnspecId') != '') {
			unspecId = ApexPages.currentPage().getParameters().get('UnspecId');
		}
		
		if (ApexPages.currentPage().getParameters().get('NomiId') != null && ApexPages.currentPage().getParameters().get('NomiId') != '') {
			nomiId = ApexPages.currentPage().getParameters().get('NomiId');
		}
		
		soqlQuery = 'SELECT Account__c, Contact__c, Reference_Content__c, Nomination__c, Reference_Request__c, Account_Request__c, Unspecified_Request__c, Note__c,'; 
		soqlQuery += 'Note_Date__c, CreatedDate, LastModifiedDate, Name, Id FROM Reference_Note__c  ';
		 
		if (unspecId != null && unspecId != '') {
			soqlQuery += 'WHERE Unspecified_Request__c = :unspecId ORDER BY Note_Date__c DESC, Name DESC'; 
		} else if (nomiId != null && nomiId != '') {
			soqlQuery += 'WHERE Nomination__c = :nomiId ORDER BY Note_Date__c DESC, Name DESC'; 
		} else if (accountReqId != null && accountReqId != '') {
			soqlQuery += 'WHERE Account_Request__c = :accountReqId ORDER BY Note_Date__c DESC, Name DESC'; 
		} else if (refReqId != null && refReqId != '') {
			soqlQuery += 'WHERE Reference_Request__c = :refReqId ORDER BY Note_Date__c DESC, Name DESC'; 
		} else if (contentId != null && contentId != '') {
			soqlQuery += 'WHERE Reference_Content__c = :contentId ORDER BY Note_Date__c DESC, Name DESC'; 
		} else if (contactId != null && contactId != '') {
			soqlQuery += 'WHERE Contact__c = :contactId ORDER BY Note_Date__c DESC, Name DESC'; 
		} else if (accountId != null && accountId != '') {
			soqlQuery += 'WHERE Account__c = :accountId ORDER BY Note_Date__c DESC, Name DESC';
		} 
		referenceNotes = Database.query(soqlQuery);
	}
	
	/**
     * Constructor
     */
 	public PageReference cancel(){
 		
 		if (unspecId != null && unspecId != '') {
 			return new PageReference('/' + unspecId);
 		} else if (nomiId != null && nomiId != '') {
 			return new PageReference('/' + nomiId);
 		} else if (accountReqId != null && accountReqId != '') {
 			return new PageReference('/' + accountReqId);
 		} else if (refReqId != null && refReqId != '') {
 			return new PageReference('/' + refReqId);
 		} else if (contentId != null && contentId != '') {
 			return new PageReference('/' + contentId);
 		} else if (contactId != null && contactId != '') {
 			return new PageReference('/' + contactId);
 		} else if (accountId != null && accountId != '') {
 			return new PageReference('/' + accountId);
 		}
 		
 		return null;
 	}
}