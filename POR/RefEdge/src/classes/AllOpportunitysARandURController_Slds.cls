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
 * VF Page: AllOpportunitysARandURSLDS
 * Description: Class to display all related Requests of an opportunity
 * Modified By: Rekha Jangir @Feb 6 2017
 */
global with sharing class AllOpportunitysARandURController_Slds extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    global static List<requestWrapper> requestList { get; set; }
    global static Boolean isSalesUser { get; set; }
    
    /**
     * Constructor
     */
    public AllOpportunitysARandURController_Slds(ApexPages.StandardController controller) {}
    
    /**
     * Method to get all requests of given opportunity
     * Modified By: Rekha Jangir @Jan/18/2017
     * ticket# 695
     */
    @RemoteAction
    global static List<requestWrapper> getRequestList(String opportunityId) { 
        String oppId = opportunityId;
        requestList = new List<requestWrapper>();
        List<String> accountsIds = new List<String>();
        List<Reference_Request__c> refRequets = WithoutSharingHelperController.getReferenceRequests(oppId);
        
        for (Reference_Request__c req : refRequets) {
            
            for (Reference_Request_Account__c rra : req.Reference_Request_Accounts__r) {
            	accountsIds.add(rra.Account__c);
            }
        }
        Map<Id, Reference_Basic_Information__c> rbiMap = new Map<Id, Reference_Basic_Information__c>();
        
        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountsRBI(accountsIds)) {
          	rbiMap.put(rbi.Account__c, rbi);
        }
        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Customer Reference Team'];
        
        for (Reference_Request__c req : refRequets) {
            requestList.add(new requestWrapper(req, req.Reference_Request_Accounts__r, req.Unspecified_Requests__r, rbiMap, groups[0].Id));
        }
        
        return requestList;
    }
    
    /**
     * Method to get is User Sales Person or not
     * Modified By: Rekha Jangir @Jan/18/2017
     * ticket# 695
     */
    @RemoteAction
    global static Boolean isSalesUser(String opportunityId) { 
     	isSalesUser = false;
        List<Profile> proList = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT :limits.getLimitQueryRows()];
        
        if (proList.size() > 0) {
          	isSalesUser = (proList[0].Name.contains('Sales') ? true : false);
        }
        return isSalesUser;
	}
    
    /**
     * Wrapper class for Reference Request
     * Modified By: Rekha Jangir @Jan/18/2017
     * ticket# 695
     */
    global class requestWrapper {
        public Reference_Request__c request { get; set; }
        public List<AccountRequestWrapper> accReqs { get; set; }
        public List<AccountRequestWrapper> unspReqs { get; set; }
        
        public requestWrapper(Reference_Request__c request, List<Reference_Request_Account__c> accReq, 
        						List<Unspecified_Request__c> unspReqs1, Map<Id, Reference_Basic_Information__c> rbiMap, String gId) {
            this.request = request;
            this.accReqs = new List<AccountRequestWrapper>();
            
            for (Reference_Request_Account__c rra : accReq) {
              	accReqs.add(new AccountRequestWrapper(rra, rbiMap, gId));
            }
            this.unspReqs = new List<AccountRequestWrapper>();
            
            for (Unspecified_Request__c rra : unspReqs1) {
              	unspReqs.add(new AccountRequestWrapper(rra, gId));
            }
        }
    }
    
    /**
     * Wrapper class for Account Request and Unspecified Request
     * Modified By: Rekha Jangir @Jan/18/2017
     * ticket# 695
     */
    public class AccountRequestWrapper {
      	public String Owner { get; set; }
        public String OwnerName { get; set; }
        public String AccountId { get; set; }
        public String AccountName { get; set; }
        public String ReferenceTypeNeededId { get; set; }
        public String ReferenceTypeNeeded { get; set; }
        public String Deadline { get; set; }
        public String ApprovalStatus { get; set; }
        public String ManagedRequestStatus { get; set; }
        public String DetailId { get; set; }
        public Boolean ManagedRequest { get; set; }
        
        public AccountRequestWrapper(Reference_Request_Account__c rra, Map<Id, Reference_Basic_Information__c> rbiMap, String gId) {

          	if (rra.Process__c == 'Peer2Peer') {
	            this.Owner = (rbiMap.get(rra.Account__c).Reference_Owner__c != null 
	            				? rbiMap.get(rra.Account__c).Reference_Owner__c 
	            				: rbiMap.get(rra.Account__c).Account__r.OwnerId);
	            this.OwnerName = (rbiMap.get(rra.Account__c).Reference_Owner__c != null 
	            				? rbiMap.get(rra.Account__c).Reference_Owner__r.Name 
	            				: rbiMap.get(rra.Account__c).Account__r.Owner.Name);
          	} else {
	    		this.Owner = (rra.Project_Owner__c != null ? rra.Project_Owner__c : gId);
	            this.OwnerName = (rra.Project_Owner__c != null ? rra.Project_Owner__r.Name : 'Reference Team');
          	}
          	this.AccountId = rra.Account__c;
          	this.AccountName = rra.Account__r.Name;
          	this.ReferenceTypeNeededId = rra.Reference_Type_Needed__c;
          	this.ReferenceTypeNeeded = rra.Reference_Type_Needed__r.Name;
          	this.Deadline = (rra.Deadline__c != null ? rra.Deadline__c.format() : '');
          	this.ApprovalStatus = rra.Approval_Status__c;
          	this.ManagedRequestStatus = rra.Account_Request_Status__c;
          	this.DetailId = rra.Id;
          	this.ManagedRequest = rra.Managed_Request__c;
        }
        
        public AccountRequestWrapper(Unspecified_Request__c unspReq, String gId) {          	
          	this.Owner = (unspReq.Project_Owner__c != null ? unspReq.Project_Owner__c : gId);
            this.OwnerName = (unspReq.Project_Owner__c != null ? unspReq.Project_Owner__r.Name : 'Reference Team');
            this.AccountId = unspReq.Specified_Account__c;
            this.AccountName = (unspReq.Specified_Account__c != null ? unspReq.Specified_Account__r.Name : '');
            this.ReferenceTypeNeededId = unspReq.Reference_Type_Needed__c;
            this.ReferenceTypeNeeded = unspReq.Reference_Type_Needed__r.Name;
            this.Deadline = (unspReq.Deadline__c != null ? unspReq.Deadline__c.format() : ''); 
            this.ManagedRequestStatus = unspReq.Unspecified_Request_Status__c;
            this.DetailId = unspReq.Id;
        }
    }
        
}