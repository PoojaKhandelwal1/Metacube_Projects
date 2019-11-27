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
 * Page: AllOpportunitysARandUR
 * Description: Class to show all requests associated to any opportunity
 * Modified by: Rekha @Feb 4 2017
 */
public with sharing class AllOpportunitysARandURController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Map<String, List<Reference_Request_Account__c>> accountRequestMap { get; set; }
    public Map<String, List<Unspecified_Request__c>> unspecifiedRequestMap { get; set; }
    public List<requestWrapper> requestList { get; set; }
    public boolean isSalesUser { get; set; }
    public boolean isSLDS { get; set; }
    
    /**
     * Constructor
     */
    public AllOpportunitysARandURController(ApexPages.StandardController controller) {
        Opportunity opp = (Opportunity) controller.getRecord();
        
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        String oppId = opp.Id;
	        isSalesUser = false;
	        List<Profile> proList = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT: limits.getLimitQueryRows()];
	        
	        if (proList.size() > 0) {
	        	isSalesUser = (proList[0].Name.contains('Sales') ? true : false);
	        }
	        requestList = new List<requestWrapper>();
	        accountRequestMap = new Map<String, List<Reference_Request_Account__c>>();
	        unspecifiedRequestMap = new Map<String, List<Unspecified_Request__c>>();
	        List<String> accountsIds = new List<String>();
	        List<Reference_Request__c> refRequets = WithoutSharingHelperController.getReferenceRequests(oppId);
	        
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
	            requestList.add(new requestWrapper(req, req.Reference_Request_Accounts__r, req.Unspecified_Requests__r, rbiMap, groups[0].Id));
	        }
        }
    }
    
    /**
     * Wrapper class
     */
    public class requestWrapper {
        public Reference_Request__c request {
            get;
            set;
        }
        public List<accountRequestWrapper> accReqs {
            get;
            set;
        }
        public List<UnspecifiedWrapper> unspReqs {
            get;
            set;
        }
        public requestWrapper(Reference_Request__c request, List<Reference_Request_Account__c> accReqs1, 
        			List<Unspecified_Request__c> unspReqs1,map<Id,Reference_Basic_Information__c> rbiMap, String gId) {
            this.request = request;
            this.accReqs = new List<accountRequestWrapper>();
            for(Reference_Request_Account__c rra : accReqs1){
            	accReqs.add(new accountRequestWrapper(rra,rbiMap,gId));
            }
            this.unspReqs = new List<UnspecifiedWrapper>();
            for(Unspecified_Request__c rra : unspReqs1){
            	unspReqs.add(new UnspecifiedWrapper(rra,gId));
            }
        }
    }
    
    /**
     * Wrapper class
     */
    public class accountRequestWrapper {
    	public Reference_Request_Account__c rra { get; set; }
    	public String Owner { get; set; }
        public String OwnerName { get; set; }
        
        public accountRequestWrapper(Reference_Request_Account__c rra, Map<Id, Reference_Basic_Information__c> rbiMap, String gId){
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
        
        public UnspecifiedWrapper(Unspecified_Request__c unspReq, String gId){
        	this.unspReq = unspReq;
    		this.Owner = (unspReq.Project_Owner__c != null ? unspReq.Project_Owner__c : gId);
    		this.OwnerName = (unspReq.Project_Owner__c != null ? unspReq.Project_Owner__r.Name : 'Reference Team');
        }
    }
}