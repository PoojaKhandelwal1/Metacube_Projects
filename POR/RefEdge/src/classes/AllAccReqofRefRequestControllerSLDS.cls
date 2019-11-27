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
 * VF Page: AllAccReqofRefRequestSLDS.page
 * Description: controller for inline page on Reference request detail page to display
 *				all the account requests for that reference request
 * Last modified by: Rekha @23 august 2017
 */
public with sharing class AllAccReqofRefRequestControllerSLDS extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public String reqId { get; set; }
    
    /**
     * Constructor
     */
    public AllAccReqofRefRequestControllerSLDS(ApexPages.StandardController controller) {
        Reference_Request__c refObj = (Reference_Request__c)controller.getRecord();
        reqId = refObj.Id;
    }
    
    /**
     * Method to get all Requests
     * Created By: Rekha Jangir @23 August 2017
     */
    @RemoteAction
    public static List<AccountRequestWrapper> getRequestList(String reqId) { 
        List<AccountRequestWrapper> accountRequests = new List<AccountRequestWrapper>();
    	
    	for (Reference_Request_Account__c rra : WithoutSharingHelperController.getRRAccountRequests(reqId)) {
    		accountRequests.add(new AccountRequestWrapper(rra));
    	}
        return accountRequests;
    }
    
    /**
     * Wrapper class for Account Request and Unspecified Request
     * Created By: Rekha Jangir @23 August 2017
     */
    public class AccountRequestWrapper {
    	public String requesterId { get; set; }
    	public String requesterName { get; set; }
        public String AccountId { get; set; }
        public String AccountName { get; set; }
        public String ReferenceTypeNeededId { get; set; }
        public String ReferenceTypeNeeded { get; set; }
        public String Deadline { get; set; }
        public String ApprovalStatus { get; set; }
        public String ManagedRequestStatus { get; set; }
        public String DetailId { get; set; }
        public Boolean ManagedRequest { get; set; }
        
        public AccountRequestWrapper(Reference_Request_Account__c rra) {
          	this.AccountId = rra.Account__c;
          	this.AccountName = rra.Account__r.Name;
          	this.ReferenceTypeNeededId = rra.Reference_Type_Needed__c;
          	this.ReferenceTypeNeeded = rra.Reference_Type_Needed__r.Name;
          	this.requesterId = rra.Requester__c;
          	this.requesterName = rra.Requester__r.Name;
          	this.Deadline = (rra.Deadline__c != null ? rra.Deadline__c.format() : '');
          	this.ApprovalStatus = rra.Approval_Status__c;
          	this.ManagedRequestStatus = rra.Account_Request_Status__c;
          	this.DetailId = rra.Id;
          	this.ManagedRequest = rra.Managed_Request__c;
        }
    }
}