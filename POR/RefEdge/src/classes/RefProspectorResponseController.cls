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
 * VF Page: RefProspectorResponsePage.page
 * Description: controller for prviding response to the reference prospector campaign
 * Author: Gaurav Saini (2 Nov, 2017)
 */
public with sharing class RefProspectorResponseController extends RefEdgeEditionFeatures {
    
    /**
     * method to get custom settings fields
     * author: Gaurav Saini (13 Oct, 2017)
     */
    @RemoteAction
    public static String getCustomSettings() {
    	Custom_Settings__c customSetting = UtilityController.getCustomSettings();
    	Map<String, String> resultMap = new Map<String, String>();
    	resultMap.put('createNomination', customSetting.Create_Nomination__c + '');
    	resultMap.put('isRefProspectEnabled', customSetting.Ref_Prospector_Enable__c + '');
    	resultMap.put('pageHeader', customSetting.Ref_Prospector_Hdr_Txt__c != null ? customSetting.Ref_Prospector_Hdr_Txt__c + '' : 'Potential Reference Leads');
    	resultMap.put('pageSubHeader', customSetting.Ref_Prospector_SubHdr_Txt__c != null ? customSetting.Ref_Prospector_SubHdr_Txt__c + '' : '');
    	//	REF-2008
		resultMap.put('onScreenNotification', customSetting.User_Reward_Onscreen_Notification__c+'');
		return JSON.serialize(resultMap);
    }
    
    /**
     * method to get reference lead records
     * author: Gaurav Saini (13 Oct, 2017)
     */
    @RemoteAction
    public static String getRefLeads() {
    	List<RefLeadWrapper> refLeadWrapperList = new List<RefLeadWrapper>();
    	List<Reference_Lead__c> refLeadsList = WithoutSharingHelperController.getRefLeadsForUser();
    	Set<String> accIds = new Set<String>();
    	
    	for (Reference_Lead__c rl : refLeadsList) {
    		accIds.add(rl.Reference_Lead_Account__c);
    	}
    	Map<String, Account> accRBIMap
    			= new Map<String, Account>((List<Account>)WithoutSharingHelperController.getAccountAndRBI(accIds));
    	
    	for (Reference_Lead__c rl : refLeadsList) {
    		
    		if (accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r != null
					&& accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r.size() > 0
					&& !accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r[0].Generic_Account__c) {
	    		refLeadWrapperList.add(new RefLeadWrapper(rl, accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r[0].Is_Referenceable__c));
    		} else {
    			refLeadWrapperList.add(new RefLeadWrapper(rl, false));
    		}
    	}
    	return JSON.serialize(refLeadWrapperList);
    }
    
    /**
     * method to get the list of reference lead records for specified page number
     * author: Gaurav Saini (13 Nov, 2017)
     */
    @RemoteAction
    public static String getRefLeadsForPageNo(Integer pageNo) {
    	List<RefLeadWrapper> refLeadWrapperList = new List<RefLeadWrapper>();
    	List<Reference_Lead__c> refLeadsList = WithoutSharingHelperController.getRefLeadsForPageNo(((pageNo + 1) * 10));
    	Set<String> accIds = new Set<String>();
    	
    	for (Reference_Lead__c rl : refLeadsList) {
    		accIds.add(rl.Reference_Lead_Account__c);
    	}
    	Map<String, Account> accRBIMap
    			= new Map<String, Account>((List<Account>)WithoutSharingHelperController.getAccountAndRBI(accIds));
    	
    	for (Reference_Lead__c rl : refLeadsList) {
    		
    		if (accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r != null
					&& accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r.size() > 0
					&& !accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r[0].Generic_Account__c) {
	    		refLeadWrapperList.add(new RefLeadWrapper(rl, accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r[0].Is_Referenceable__c));
    		} else {
    			refLeadWrapperList.add(new RefLeadWrapper(rl, false));
    		}
    	}
    	return JSON.serialize(refLeadWrapperList);
    }
    
    /**
     * method to get the list of reference lead records when user clicks on next link
     *			for a page which has already been opened
     * author: Gaurav Saini (13 Nov, 2017)
     */
    @RemoteAction
    public static String getAlreadyPresentRefLeads(String refLeadIdsJSON) {
    	List<RefLeadWrapper> refLeadWrapperList = new List<RefLeadWrapper>();
    	List<String> refLeadIds = (List<String>)JSON.deserialize(refLeadIdsJSON, List<String>.class);
    	List<Reference_Lead__c> refLeadsList = WithoutSharingHelperController.getRefLeadsPresent(refLeadIds);
    	Set<String> accIds = new Set<String>();
    	
    	for (Reference_Lead__c rl : refLeadsList) {
    		accIds.add(rl.Reference_Lead_Account__c);
    	}
    	Map<String, Account> accRBIMap
    			= new Map<String, Account>((List<Account>)WithoutSharingHelperController.getAccountAndRBI(accIds));
    	
    	for (Reference_Lead__c rl : refLeadsList) {
    		
    		if (accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r != null
					&& accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r.size() > 0
					&& !accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r[0].Generic_Account__c) {
	    		refLeadWrapperList.add(new RefLeadWrapper(rl, accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r[0].Is_Referenceable__c));
    		} else {
    			refLeadWrapperList.add(new RefLeadWrapper(rl, false));
    		}
    	}
    	return JSON.serialize(refLeadWrapperList);
    }
    
    /**
     * method to get the list of reference lead records when user clicks on next link
     *			for a new page
     * author: Gaurav Saini (13 Nov, 2017)
     */
    @RemoteAction
    public static String getAlreadyNotPresentRefLeads(String alreadyPresentRefLeadIdsJSON) {
    	List<RefLeadWrapper> refLeadWrapperList = new List<RefLeadWrapper>();
    	List<String> alreadyPresentRefLeadIds = (List<String>)JSON.deserialize(alreadyPresentRefLeadIdsJSON, List<String>.class);
    	List<Reference_Lead__c> refLeadsList = WithoutSharingHelperController.getRefLeadsNotPresent(alreadyPresentRefLeadIds);
    	Set<String> accIds = new Set<String>();
    	
    	for (Reference_Lead__c rl : refLeadsList) {
    		accIds.add(rl.Reference_Lead_Account__c);
    	}
    	Map<String, Account> accRBIMap
    			= new Map<String, Account>((List<Account>)WithoutSharingHelperController.getAccountAndRBI(accIds));
    	
    	for (Reference_Lead__c rl : refLeadsList) {
    		
    		if (accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r != null
					&& accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r.size() > 0
					&& !accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r[0].Generic_Account__c) {
	    		refLeadWrapperList.add(new RefLeadWrapper(rl, accRBIMap.get(rl.Reference_Lead_Account__c).Reference_Basic_Informations__r[0].Is_Referenceable__c));
    		} else {
    			refLeadWrapperList.add(new RefLeadWrapper(rl, false));
    		}
    	}
    	return JSON.serialize(refLeadWrapperList);
    }
    
    /**
     * method to get the reference lead object
     * author: Gaurav Saini (18 April, 2017) for #5
     */
    @RemoteAction
    public static String getRefLead(String refLeadId) {
    	List<Reference_Lead__c> refLeads = WithoutSharingHelperController.getReferenceLead(refLeadId);
    	List<RefLeadWrapper> refLeadWrapperList = new List<RefLeadWrapper>();
		refLeadWrapperList.add(new RefLeadWrapper(refLeads[0]));
		return JSON.serialize(refLeadWrapperList[0]);
    }
	
    /**
     * method to get the reference lead owner for lookup field
     * author: Gaurav Saini (8 Jan, 2018) for REF-1238
     */
    @RemoteAction
    public static String getRefLeadOwnerDetails(String searchText) {
		String SOQLQuery = '';
		String communityProfileName = '\'%Community%\'';
        String siteProfileName = '\'%Guest%\'';
		String result = '';
		List<User> userList = new List<User>();
		String searchValue = searchText.replace('*', '%') + '%';
        searchValue = String.escapeSingleQuotes(searchValue);
        searchValue = '\'%' + searchValue + '\'';
		SOQLQuery = 'SELECT Name, Id FROM User '
					+ 'WHERE IsActive = true '
					+ 'AND (NOT Profile.Name LIKE ' + communityProfileName + ') '
					+ 'AND (NOT Profile.Name LIKE ' + siteProfileName + ') '
					+ 'AND (NOT Name LIKE ' + siteProfileName + ') '
					+ 'AND (Name LIKE ' + searchValue + ') ORDER BY Name LIMIT 2';
		userList = Database.query(SOQLQuery);
		
		if (userList != null && userList.size() == 1) {
			result = userList[0].Id + '@@@' + userList[0].Name;
		} else if (userList != null && userList.size() > 1) {
			result = 'multiple';
		} else if (userList != null && userList.size() == 0) {
			result = 'zero';
		}
		return result;
	}
    
    /**
     * Method to get date format according tocurrent user's locale
     * author: Gaurav Saini (14 Nov, 2017) for #1104
     */
    @RemoteAction
    public static String getDateFormat() {   
		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
		return (dateFormat != null ? dateFormat : 'yyyy-MM-dd');
    }
    
    /**
     * method to get follow up time frame picklist values
     * author: Gaurav Saini (15 Nov, 2017) for #1104
     */
    @RemoteAction
    public static String getFollowUpDaysList() {
    	List<String> followUpDaysList = new List<String>();
    	Schema.DescribeFieldResult dfr
    			= Schema.sObjectType.Reference_Lead__c.fields.getMap().get(UtilityController.appNamespace() + 'Follow_Up_Timeframe__c').getDescribe();
        
        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            followUpDaysList.add(String.valueOf(ple.getValue()));
        }
        return JSON.serialize(followUpDaysList);
    }
    
    public class RefLeadWrapper {
    	public String refLeadId { get; set; }
    	public String status { get; set; }
    	public String accountId { get; set; }
    	public String accountName { get; set; }
    	public String refProfileId { get; set; }
    	public String nominationId { get; set; }
    	public Boolean isAccountMember { get; set; }
    	public String refLeadOwnerName { get; set; }
    	public String refLeadOwnerId { get; set; }
    	public String followUpTimeFrame { get; set; }
    	public Boolean isSelected { get; set; }
    	
    	public RefLeadWrapper(Reference_Lead__c refLead, Boolean isAccountMember) {
    		this.refLeadId = refLead.Id;
	    	this.accountName = refLead.Reference_Lead_Account__r.Name;
    		this.isAccountMember = isAccountMember;
    		this.isSelected = false;
    	}
    	
    	public RefLeadWrapper(Reference_Lead__c refLead) {
    		this.refLeadId = refLead.Id;
    		this.status = refLead.Reference_Lead_Status__c;
	    	this.refProfileId = refLead.Reference_Profile__c != null ? (String)refLead.Reference_Profile__c : '';
	    	this.accountId = refLead.Reference_Lead_Account__c;
	    	this.accountName = refLead.Reference_Lead_Account__r.Name;
	    	this.nominationId = refLead.Nomination__c != null ? (String)refLead.Nomination__c : '';
	    	this.refLeadOwnerName = refLead.Reference_Lead_Owner__r.Name;
	    	this.refLeadOwnerId = '';
	    	this.followUpTimeFrame = '';
    		this.isSelected = false;
    	}
    }
}