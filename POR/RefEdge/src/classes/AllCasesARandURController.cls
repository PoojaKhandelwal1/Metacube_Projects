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
 * VF Page: AllCasesARandUR
 * Description: controller for inline page on case detail page to show all the
 *				reference requests related to the case record
 * LastModified by: Gaurav Saini (13 June, 2017) for #732
 */
public with sharing class AllCasesARandURController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public Map<String, List<Reference_Request_Account__c>> accountRequestMap { get; set; }
    public Map<String, List<Unspecified_Request__c>> unspecifiedRequestMap { get; set; }
    public List<RequestWrapper> requestList { get; set; }
    public boolean isSalesUser { get; set; }
    public boolean isSLDS { get; set; }
    
    /**
     * Constructor
     */
    public AllCasesARandURController(ApexPages.StandardController controller) {
        Case caseObj = (Case)controller.getRecord();
        
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        String caseId = caseObj.Id;
	        requestList = new List<RequestWrapper>();
	        accountRequestMap = new Map<String, List<Reference_Request_Account__c>>();
	        unspecifiedRequestMap = new Map<String, List<Unspecified_Request__c>>();
	        
	        isSalesUser = false;
	        List<Profile> proList = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT: limits.getLimitQueryRows()];
	        
	        if (proList.size() > 0) {
	        	isSalesUser = (proList[0].Name.contains('Sales') ? true : false);
	        }
	        List<String> accountsIds = new List<String>();
	        List<Reference_Request__c> refRequets = [SELECT Id, Name, 
	    										(SELECT Name, Deadline__c, Reference_Type_Needed__c, Requester__c,
	    											Reference_Request_Additional_Info__c, Request_Notes__c,
	    											Specified_Account__c, Unspecified_Request_Status__c,
	    											Project_Owner__c, Project_Owner__r.Name, Specified_Account__r.Name,
	    											Reference_Type_Needed__r.Name
	    											FROM Unspecified_Requests__r
	    											ORDER BY CreatedDate DESC),
												(SELECT Name, Account__c, Deadline__c, Requester__c, Managed_Request__c, Process__c,
													Reference_Type_Needed__c, Approval_Status__c, Account_Request_Status__c,
													Reference_Owner__c, Reference_Owner__r.Name, Account__r.Name, Reference_Type_Needed__r.Name
													FROM Reference_Request_Accounts__r
													ORDER BY CreatedDate DESC)
												FROM Reference_Request__c r
												WHERE Case__c = :caseId
												ORDER BY CreatedDate DESC];
	        
	        for (Reference_Request__c req : refRequets) {
	        	 
	            for (Reference_Request_Account__c rra : req.Reference_Request_Accounts__r) {
	        		accountsIds.add(rra.Account__c);
	            }
	        }
	        Map<Id,Reference_Basic_Information__c> rbiMap = new Map<Id,Reference_Basic_Information__c>();
	        
	        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountsRBI(accountsIds)) {
	        	rbiMap.put(rbi.Account__c, rbi);
	        }
	        List<Group> groups = [SELECT Id FROM Group WHERE Name = 'Customer Reference Team'];
	        
	        for (Reference_Request__c req : refRequets) {
	            requestList.add(new RequestWrapper(req, req.Reference_Request_Accounts__r, req.Unspecified_Requests__r, rbiMap, groups[0].Id));
	        }
        }
    }
    
    /**
     * Wrapper class
     */
    public class RequestWrapper {
        public Reference_Request__c request { get; set; }
        public List<AccountRequestWrapper> accReqs { get; set; }
        public List<UnspecifiedWrapper> unspReqs { get; set; }
        
        public RequestWrapper(Reference_Request__c request, List<Reference_Request_Account__c> accReqs1, 
        			List<Unspecified_Request__c> unspReqs1, Map<Id,Reference_Basic_Information__c> rbiMap, String gId) {
            this.request = request;
            this.accReqs = new List<AccountRequestWrapper>();
            
            for (Reference_Request_Account__c rra : accReqs1) {
            	accReqs.add(new AccountRequestWrapper(rra, rbiMap, gId));
            }
            this.unspReqs = new List<UnspecifiedWrapper>();
            
            for (Unspecified_Request__c rra : unspReqs1) {
            	unspReqs.add(new UnspecifiedWrapper(rra, gId));
            }
        }
    }
    
    /**
     * Wrapper class
     */
    public class AccountRequestWrapper {
    	public Reference_Request_Account__c rra { get; set; }
    	public String Owner { get; set; }
        public String OwnerName { get; set; }
        
        public AccountRequestWrapper(Reference_Request_Account__c rra, Map<Id, Reference_Basic_Information__c> rbiMap, String gId) {
        	this.rra = rra;
        	
        	if (rra.Process__c == 'Peer2Peer') {
        		this.Owner = (rra.Reference_Owner__c != null ? rra.Reference_Owner__c : gId);
        		this.OwnerName = (rra.Reference_Owner__c != null ? rra.Reference_Owner__r.Name : 'Reference Team');
        	} else {
        		this.Owner = (rra.Reference_Owner__c != null ? rra.Reference_Owner__c : gId);
        		this.OwnerName = (rra.Reference_Owner__c != null ? rra.Reference_Owner__r.Name : 'Reference Team');
        	}
        }
    }
    
    /**
     * Wrapper class
     */
    public class UnspecifiedWrapper {
    	public Unspecified_Request__c unspReq { get; set; }
    	public String Owner { get; set; }
        public String OwnerName { get; set; }
        
        public UnspecifiedWrapper(Unspecified_Request__c unspReq, String gId) {
        	this.unspReq = unspReq;
    		this.Owner = (unspReq.Project_Owner__c != null ? unspReq.Project_Owner__c : gId);
    		this.OwnerName = (unspReq.Project_Owner__c != null ? unspReq.Project_Owner__r.Name : 'Reference Team');
        }
    }
}