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
 * VF Page: ReferenceLeadFormSLDS.page
 * Description: controller for creating reference profile from reference lead form page
 * Author: Gaurav Saini (25 May, 2017)
 * Last modified by: Gaurav Saini (6 June, 2017)
 */
public with sharing class ReferenceLeadFormControllerSLDS extends RefEdgeEditionFeatures {
    
    private static Custom_Settings__c cs = UtilityController.getCustomSettings();
    public String refLeadId { get; set; }
    public String pageHeader { get; set; }
    public String pageSubHeader { get; set; }
    public String dateFormatString { get; set; }
    
    /**
     * constructor to use this as an extension on RefProspectorResponsePage
     * author: Gaurav Saini (16 Nov, 2017) #1104
     */
    public ReferenceLeadFormControllerSLDS(RefProspectorResponseController controller) {}
    
    public ReferenceLeadFormControllerSLDS(ApexPages.StandardController controller) {
    	refLeadId = '';
    	pageHeader = ConstantsController.HEADER;
    	pageSubHeader = ConstantsController.SUBHEADER;
    	dateFormatString = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale());
    	
    	if (ApexPages.currentPage().getParameters().get('Id') != null
    				&& ApexPages.currentPage().getParameters().get('Id') != '') {
    		refLeadId = ApexPages.currentPage().getParameters().get('Id');
    	}
    }
    
    /**
     * Method to get Date Format #1070
     */
    @RemoteAction
    public static String getDateFormat() {   
    		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
    		return dateFormat;
    }
    
    /**
     * method to get filters to exclude from accounts and contacts
     * author: Gaurav Saini (26 May, 2017) for #5
     */
    @RemoteAction
    public static String getFiltersToExclude() {
    	Map<String, Set<String>> excludedFiltersMap = new Map<String, Set<String>>();
    	excludedFiltersMap.put('account', new Set<String>());
    	excludedFiltersMap.put('contact', new Set<String>());
    	
    	for (Attribute_Mapping__c attMap : [SELECT Filter_Label_Name__c, Object__c FROM Attribute_Mapping__c
        									WHERE (Object__c = :ConstantsController.CONTACT
        									OR Object__c = :ConstantsController.ACCOUNT)
        									AND Is_Related_Mapping__c = false]) {
            
            if (attMap.Object__c == ConstantsController.CONTACT) {
            	excludedFiltersMap.get('contact').add(attMap.Filter_Label_Name__c);
            } else {
            	excludedFiltersMap.get('account').add(attMap.Filter_Label_Name__c);
            }
        }
        return JSON.serialize(excludedFiltersMap);
    }
    
    /**
     * method to get data mappings list for reference lead form
     * author: Gaurav Saini (29 May, 2017) for #5
     */
    @RemoteAction
    public static String getDataMappingsList() {
    	List<DataMappingWrapper> dataMappingWrapperList = new List<DataMappingWrapper>();
    	List<Data_Mapping__c> dataMappingsList = [SELECT Visible__c, Required__c, Referenceability_Type__c, Order__c,
			            							Object__c, Name, Label__c, Id, Filter__c, Field_API_Name__c
			            							FROM Data_Mapping__c
			            							WHERE (Object__c = :ConstantsController.REFERENCE_LEAD
			            							AND Filter__c = null
			            							AND Visible__c = true)
			            							OR (Object__c = :ConstantsController.REFERENCE_LEAD_HEADER)
			            							OR (Object__c = :ConstantsController.REFERENCE_LEAD
						                			AND Filter__c != null AND Visible__c = true)
			            							ORDER BY Order__c];
    	Map<String, Schema.SObjectField> fieldsMap = Schema.SObjectType.Reference_Lead__c.fields.getMap();
    	Map<String, Schema.DescribeFieldResult> customFieldsMap = new Map<String, Schema.DescribeFieldResult>();
        
        for (String field : fieldsMap.keyset()) {
        	Schema.DescribeFieldResult fieldObj = fieldsMap.get(field).getDescribe();
        	
            if (fieldObj.isCustom() && fieldObj.isUpdateable()) {
            	customFieldsMap.put(fieldObj.getName(), fieldObj);
            }
        }
    	
    	for (Data_Mapping__c dm : dataMappingsList) {
	    	
	    	if (dm.Field_API_Name__c != null && customFieldsMap.containsKey(dm.Field_API_Name__c)) {
	    		dataMappingWrapperList.add(new DataMappingWrapper(dm, customFieldsMap.get(dm.Field_API_Name__c)));
	    	} else {
	    		dataMappingWrapperList.add(new DataMappingWrapper(dm, null));
	    	}
    	}
    	return JSON.serialize(dataMappingWrapperList);
    }
    
    /**
     * method to get fields list for custom fields section on reference lead form
     * author: Gaurav Saini (1 June, 2017) for #5
     */
    @RemoteAction
    public static String getFilterAttributesMap(String filterIdsJSON) {
    	List<String> filterIds = (List<String>)JSON.deserialize(filterIdsJSON, List<String>.class);
    	Map<String, List<AttributeWrapper>> filterAttributesMap = new Map<String, List<AttributeWrapper>>();
    	Set<String> attributeIds = new Set<String>();
    	List<Attributes_Labels__c> attLabelsList = [SELECT Id, Attribute__c, Attribute__r.Name, Attribute__r.ParentIds__c,
													Label__c, Label__r.Name, Label__r.Ref_Limit_to_Acct_or_Cntct__c
													FROM Attributes_Labels__c
													WHERE Label__c IN :filterIds
													AND Attribute__c != null
													ORDER BY Attribute__r.Name
													LIMIT :limits.getLimitQueryRows()];
        
        for (Attributes_Labels__c al : attLabelsList) {
			
			if (al.Attribute__r.ParentIds__c != null && al.Attribute__r.ParentIds__c != '') {
				attributeIds.addAll(al.Attribute__r.ParentIds__c.split(','));
			}
		}
		Map<String, Attribute__c> rootAttMap
					= new Map<String, Attribute__c>([SELECT Id, Name, Ref_Limit_to_Acct_or_Cntct__c
														FROM Attribute__c
														WHERE Id IN :attributeIds AND Level__c = 0]);
    	
    	for (Attributes_Labels__c al : attLabelsList) {
    		Attribute__c tempRootAtt;
    		String currentRootAttLimitedTo = '';
    		
    		if (!filterAttributesMap.containsKey(al.Label__c)) {
    			filterAttributesMap.put(al.Label__c, new List<AttributeWrapper>());
    		}
    		
    		if (al.Attribute__r.ParentIds__c != null && al.Attribute__r.ParentIds__c != '') {
    			
	    		for (String attId : al.Attribute__r.ParentIds__c.split(',')) {
	    			
	    			if (rootAttMap.containsKey(attId) && rootAttMap.get(attId) != null
	    						&& rootAttMap.get(attId).Ref_Limit_to_Acct_or_Cntct__c != null) {
	    				currentRootAttLimitedTo = rootAttMap.get(attId).Ref_Limit_to_Acct_or_Cntct__c;
	    				break;
	    			}
	    		}
    		}
    		filterAttributesMap.get(al.Label__c).add(new AttributeWrapper(al, currentRootAttLimitedTo));
    	}
    	return JSON.serialize(filterAttributesMap);
    }
    
    /**
     * method to get reference lead object
     * author: Gaurav Saini (29 May, 2017) for #5
     */
    @RemoteAction
    public static String getRefLead(String refLeadId, String fieldMappingsJSON) {
    	List<RefLeadWrapper> refLeadWrapperList = new List<RefLeadWrapper>();
    	List<DataMappingWrapper> fieldMappingsList
    				= (List<DataMappingWrapper>)JSON.deserialize(fieldMappingsJSON, List<DataMappingWrapper>.class);
    	String query = 'SELECT Id, Nomination__c, Other_Info__c, Notification_response__c, Response_Received__c, '
    					+ 'Reference_Lead_Status__c, Nominated__c, Reference_Profile__c, Reference_Lead_Opportunity__c, '
    					+ 'No_Response_Date__c, Reference_Lead_Opportunity__r.Owner.Name, '
    					+ 'Reference_Lead_Owner__c, Follow_up_timeframe__c, Reference_Lead_Account__c, Contact__c, '
    					+ 'Reference_Lead_Account__r.Name, Contact__r.Name, Reference_Lead_Opportunity__r.Name ';
    	
    	for (DataMappingWrapper dm : fieldMappingsList) {
    		query += ', ' + dm.fieldAPIName;
    	}
    	query += ' FROM Reference_Lead__c WHERE Id = :refLeadId';
    	List<Reference_Lead__c> refLeads = WithoutSharingHelperController.getRefLeadRecords(query, refLeadId);
    	
    	if (refLeads != null && refLeads.size() > 0) {
    		refLeadWrapperList.add(new RefLeadWrapper(refLeads[0]));
    	}
    	return JSON.serialize(refLeadWrapperList);
    }
    
    /**
     * method to get list of contacts for ref lead account
     * author: Gaurav Saini (29 May, 2017) for #5
     */
    @RemoteAction
    public static String getContactsList(String accountId) {
    	List<Contact> tempContactList = WithoutSharingHelperController.getAccountContacts(accountId, cs);
    	List<ContactWrapper> contactWrapperList = new List<ContactWrapper>();
    	List<ContactWrapper> contactWrapperListTemp = new List<ContactWrapper>();
    	contactWrapperList.add(new ContactWrapper(null));
    	
    	if (tempContactList != null && tempContactList.size() > 0) {
            
            for (Contact c : tempContactList) {
            	contactWrapperListTemp.add(new ContactWrapper(c));
            }
        }
        // commented because this block retrieves the child contacts for the account
        // but the above block retieves child as well as shared contacts
        // so any contacts which will be retrieved in this block will already be in the previous block
        /*
         else {
        	List<Contact> contactList1 = WithoutSharingHelperController.getContactInRBI1(new Set<String> {accountId});
            
            for (Contact c : contactList1) {
            	contactWrapperListTemp.add(new ContactWrapper(c));
            }
        }
        */
        contactWrapperListTemp.sort();
        contactWrapperList.addAll(contactWrapperListTemp);
        return JSON.serialize(contactWrapperList);
    }
    
    /**
     * method to get list of referenceability types
     * author: Gaurav Saini (29 May, 2017) for #5
     */
    @RemoteAction
    public static String getRefTypesList(String refTypeIdsJSON) {
    	List<String> refTypeIds = (List<String>)JSON.deserialize(refTypeIdsJSON, List<String>.class);
    	List<RefTypeWrapper> refTypeWrapperList = new List<RefTypeWrapper>();
    	List<Referenceability_Type__c> refTypesList = [SELECT Id, Name, Visible__c, Ref_Limit_to_Acct_or_Cntct__c
														FROM Referenceability_Type__c 
														WHERE Visible__c = true AND Id IN :refTypeIds ORDER BY Name];
    	
    	for (Referenceability_Type__c rt : refTypesList) {
    		refTypeWrapperList.add(new RefTypeWrapper(rt));
    	}
    	return JSON.serialize(refTypeWrapperList);
    }
    
    /**
     * method to save the reference lead record
     * author: Gaurav Saini (6 June, 2017) for #5
     */
    @RemoteAction
    public static String saveRefLead(String refLeadWrapperJSON, String fieldMappingsJSON, String contactId,
    									String filterAttributesMapJSON, String selectedRefTypeIdsJSON,
    									String accFiltersToExcludeJSON, String conFiltersToExcludeJSON) {
    	Savepoint sp = Database.setSavepoint();
    	String result = '';
    	
    	try {
	    	List<RefLeadWrapper> refLeadWrapperList
	    				= (List<RefLeadWrapper>)JSON.deserialize(refLeadWrapperJSON, List<RefLeadWrapper>.class);
	    	List<DataMappingWrapper> fieldMappings
	    				= (List<DataMappingWrapper>)JSON.deserialize(fieldMappingsJSON, List<DataMappingWrapper>.class);
	    	Map<String, List<AttributeWrapper>> filterAttributesMap
	    				= (Map<String, List<AttributeWrapper>>)JSON.deserialize(filterAttributesMapJSON, Map<String, List<AttributeWrapper>>.class);
	    	List<String> selectedRefTypeIds
	    				= (List<String>)JSON.deserialize(selectedRefTypeIdsJSON, List<String>.class);
	    	Set<String> accFiltersToExclude
	    				= (Set<String>)JSON.deserialize(accFiltersToExcludeJSON, Set<String>.class);
	    	Set<String> conFiltersToExclude
	    				= (Set<String>)JSON.deserialize(conFiltersToExcludeJSON, Set<String>.class);
	    	RefLeadWrapper refLeadWrapper = refLeadWrapperList[0];
	    	String query = 'SELECT Id, Nomination__c, Other_Info__c, Notification_response__c, Response_Received__c, '
	    					+ 'Reference_Lead_Status__c, Nominated__c, Reference_Profile__c, Reference_Lead_Opportunity__c, '
	    					+ 'No_Response_Date__c, Reference_Lead_Opportunity__r.Owner.Name, '
	    					+ 'Reference_Lead_Owner__c, Follow_up_timeframe__c, Reference_Lead_Account__c, Contact__c, '
	    					+ 'Reference_Lead_Account__r.Name, Contact__r.Name, Reference_Lead_Opportunity__r.Name ';
	    	
	    	for (DataMappingWrapper dm : fieldMappings) {
	    		query += ', ' + dm.fieldAPIName;
	    	}
	    	query += ' FROM Reference_Lead__c WHERE Id = :refLeadWrapper.refLeadId';
	    	List<Reference_Lead__c> refLeads = WithoutSharingHelperController.getRefLeadRecords(query, refLeadWrapper.refLeadId);
	    	Reference_Lead__c refLead = refLeads[0];
	    	
	    	if (contactId != null && contactId != '') {
		    	refLead.Contact__c = contactId;
	    	}
	    	refLead.Response_Received__c = true;
	        refLead.Notification_response__c = 'Yes, this is a very happy account';
	        refLead.Reference_Lead_Status__c = 'Converted to Program Member';
	        
	        for (DataMappingWrapper field : fieldMappings) {
	        	
	        	if (field.fieldType == 'BOOLEAN') {
	        		refLead.put(field.fieldAPIName, field.booleanFieldValue);
	        	} else if (field.fieldType == 'DATE' && field.fieldValue != '') {
	        		refLead.put(field.fieldAPIName, Date.valueOf(field.fieldValue));
	        	} else if (field.fieldType == 'DATE' && field.fieldValue == '') {
	        		refLead.put(field.fieldAPIName, null);
	        	} else {
		        	refLead.put(field.fieldAPIName, field.fieldValue);
	        	}
	        }
			refLead.Other_Info__c = refLeadWrapper.otherInfo == null ? '' : refLeadWrapper.otherInfo;
	        refLead = WithoutSharingHelperController.createRefLead(refLead);
	    	createFiltersAndRefTypes(filterAttributesMap, refLead.Id, selectedRefTypeIds);
	    	
	    	if (cs.Create_Reference_Profile__c) {
	    		UtilityController.createRBI1(refLeadWrapper.accountId, contactId, refLeadWrapper.refLeadId,
							conFiltersToExclude, accFiltersToExclude, refLeadWrapper.accountName, refLeadWrapper.conName);
	    	}
	    	result = 'success';
	    	
            if (!RefEdgeEditionFeatures.isBasic && cs.Enable_Sales_Rewards_Notification__c) {
            	List<String> lstUserAction = new List<String>();
            	lstUserAction.add(ConstantsController.RLF_RESPONSE);
	            List<Referenceability_Type__c> refType
	            			= WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);
	            
	            if (refType.size() > 0 && refType[0].Sales_Point__c != null) {
	                List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
	                
	                if (refLead.Response_Received__c) {
	                    Reference_Lead__c refId = [SELECT OwnerId FROM Reference_Lead__c
	                    							WHERE Id = :refLead.Id LIMIT 1];
	                    rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c,
	                    									Referenceability_Type__c = refType[0].Id,
	                    									Transaction__c = ConstantsController.ISSUE,
	                    									RewardDate__c = Date.Today(),
	                    									User__c = UserInfo.getUserId()));
	                    UtilityController.isUserProfileExist(refId.OwnerId);
	                    
		            	if (cs.User_Reward_Onscreen_Notification__c) {
		                    result = result + '***' + refType[0].Sales_Point__c + '***' + refType[0].Name;
		            	}
					}
	                
					if (rewardsToBeInsert.size() > 0) {
                    	WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
	                }
	            }
			}
    	} catch (Exception e) {
    		Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
    	return result;
    }
    
    /**
     * method to create filters and ref types associated to the ref lead record
     * author: Gaurav Saini (6 June, 2017) for #5
     */
    public static String createFiltersAndRefTypes(Map<String, List<AttributeWrapper>> filterAttributesMap,
    												String refLeadId, List<String> selectedRefTypeIds) {
		List<ReferenceLeadFilter__c> referenceLeadFilterList = new List<ReferenceLeadFilter__c>();
        List<ReferenceLeadAttributes__c> refLeadFilterAttList = new List<ReferenceLeadAttributes__c>();
        List<ReferenceLeadReferenceability__c> refiRefTypeList = new List<ReferenceLeadReferenceability__c>();
        
        for (String filterId : filterAttributesMap.keySet()) {
        	Boolean isAttributeSelected = false;
        	
        	for (AttributeWrapper attWrapper : filterAttributesMap.get(filterId)) {
        		
        		if (attWrapper.isSelected) {
		        	isAttributeSelected = true;
		        	break;
        		}
        	}
        	
        	if (isAttributeSelected) {
		    	ReferenceLeadFilter__c refLeadFilter
		    				= new ReferenceLeadFilter__c(Filter__c = filterId, Reference_Lead__c = refLeadId);
        		referenceLeadFilterList.add(refLeadFilter);
        	}
        }
        
        if (referenceLeadFilterList.size() > 0) {
        	WithoutSharingHelperController.insertRefLeadFilters(referenceLeadFilterList);
        	
        	for (ReferenceLeadFilter__c refLeadFilter : [SELECT Filter__c, Id FROM ReferenceLeadFilter__c
        													WHERE Reference_Lead__c = :refLeadId]) {
				
				for (AttributeWrapper attWrapper : filterAttributesMap.get(refLeadFilter.Filter__c)) {
					
					if (attWrapper.isSelected) {
						refLeadFilterAttList.add(new ReferenceLeadAttributes__c(Attribute__c = attWrapper.attributeId,
																			ReferenceLeadFilter__c = refLeadFilter.Id));
					}
				}
			}
			
            if (refLeadFilterAttList.size() > 0) {
            	WithoutSharingHelperController.insertRefLeadAttributes(refLeadFilterAttList);
            }
        }
        
        for (String refTypeId : selectedRefTypeIds) {
            refiRefTypeList.add(new ReferenceLeadReferenceability__c(Reference_Lead__c = refLeadId,
        															Referenceability_Type__c = refTypeId));
        }
        
        // for SF1
        if (refiRefTypeList.size() > 0) {
        	WithoutSharingHelperController.insertRefLeadReferenceabilities(refiRefTypeList);
        }
        return 'success';
    }
    
    // Wrapper classes used for the page
    public class DataMappingWrapper {
    	public String dataMappingId { get; set; }
    	public String fieldAPIName { get; set; }
    	public Integer fieldOrder { get; set; }
    	public Boolean visible { get; set; }
    	public Boolean required { get; set; }
    	public String refTypeId { get; set; }
    	public String dataMappingName { get; set; }
    	public Boolean isHeader { get; set; }
    	public String filterId { get; set; }
    	public String fieldType { get; set; }
    	public String fieldValue { get; set; }
    	public List<String> picklistValues { get; set; }
    	public Boolean booleanFieldValue { get; set; }
    	
    	public DataMappingWrapper(Data_Mapping__c dm, Schema.DescribeFieldResult fieldDescribe) {
    		this.dataMappingId = dm.Id;
    		this.fieldAPIName = dm.Field_API_Name__c != null ? dm.Field_API_Name__c : '';
    		this.fieldOrder = Integer.valueOf(dm.Order__c) != null ? Integer.valueOf(dm.Order__c) : -1;
    		this.visible = dm.Visible__c;
    		this.required = dm.Required__c;
    		this.refTypeId = dm.Referenceability_Type__c != null ? (String)dm.Referenceability_Type__c : '';
    		this.dataMappingName = dm.Name != null ? dm.Name : '';
    		this.isHeader = dm.Object__c == ConstantsController.REFERENCE_LEAD_HEADER ? true : false;
    		this.filterId = dm.Filter__c != null ? (String)dm.Filter__c : '';
    		this.fieldType = fieldDescribe != null ? String.valueOf(fieldDescribe.getType()) : '';
    		this.fieldValue = '';
    		this.picklistValues = new List<String>();
    		
    		if (fieldDescribe != null && (String.valueOf(fieldDescribe.getType()) == 'MULTIPICKLIST'
						|| String.valueOf(fieldDescribe.getType()) == 'PICKLIST')) {
    			
    			for (Schema.PicklistEntry ple : fieldDescribe.getPicklistValues()) {
            		
		            if (this.fieldValue == '') {
		            	this.fieldValue = String.valueOf(ple.value);
		            }
		            this.picklistValues.add(String.valueOf(ple.value));
		        }
    		}
    		
    		if (fieldDescribe != null && (String.valueOf(fieldDescribe.getType()) == 'BOOLEAN')) {
    			this.booleanFieldValue = Boolean.valueOf(fieldDescribe.getDefaultValue());
    		}
    	}
    }
    
    public class RefLeadWrapper {
    	public String refLeadId { get; set; }
    	public String accountName { get; set; }
    	public String accountId { get; set; }
    	public String oppName { get; set; }
    	public String oppId { get; set; }
    	public String oppOwnerName { get; set; }
    	public String conName { get; set; }
    	public String conId { get; set; }
    	public String otherInfo { get; set; }
    	
    	public RefLeadWrapper(Reference_Lead__c referenceLead) {
    		this.refLeadId = referenceLead.Id;
    		this.accountName = referenceLead.Reference_Lead_Account__c != null ? referenceLead.Reference_Lead_Account__r.Name : '';
    		this.accountId = referenceLead.Reference_Lead_Account__c != null ? (String)referenceLead.Reference_Lead_Account__c : '';
    		this.oppName = referenceLead.Reference_Lead_Opportunity__c != null ? referenceLead.Reference_Lead_Opportunity__r.Name : '';
    		this.oppId = referenceLead.Reference_Lead_Opportunity__c != null ? (String)referenceLead.Reference_Lead_Opportunity__c : '';
    		this.oppOwnerName = (referenceLead.Reference_Lead_Opportunity__c != null
    									&& referenceLead.Reference_Lead_Opportunity__r.Owner != null)
    								? referenceLead.Reference_Lead_Opportunity__r.Owner.Name : '';
    		this.conName = referenceLead.Contact__c != null ? referenceLead.Contact__r.Name : '';
    		this.conId = referenceLead.Contact__c != null ? (String)referenceLead.Contact__c : '';
    		this.otherInfo = referenceLead.Other_Info__c != null ? referenceLead.Other_Info__c : '';
    	}
    }
    
    public class ContactWrapper implements Comparable {
    	public String contactName { get; set; }
    	public String contactId { get; set; }
    	
    	public ContactWrapper(Contact c) {
    		this.contactName = c != null ? c.Name : '--None--';
    		this.contactId = c != null ? (String)c.Id : '';
    	}
    	
    	public Integer compareTo(Object compareTo) {
	        ContactWrapper cw = (ContactWrapper)compareTo;
	        
	        if (contactName == cw.contactName) {
	        	return 0;
	        }
	        
	        if (contactName > cw.contactName) {
	        	return 1;
	        }
	        return -1;
    	}
    }
    
    public class RefTypeWrapper {
    	public String refTypeId { get; set; }
    	public String refTypeName { get; set; }
    	public String refTypeLimitedTo { get; set; }
    	public Boolean visible { get; set; }
    	public Boolean isSelected { get; set; }
    	
    	public RefTypeWrapper(Referenceability_Type__c rt) {
    		this.refTypeId = rt.Id;
    		this.refTypeName = rt.Name;
    		this.visible = rt.Visible__c;
    		this.isSelected = false;
    		
    		if (rt.Ref_Limit_to_Acct_or_Cntct__c == null || rt.Ref_Limit_to_Acct_or_Cntct__c == '') {
				this.refTypeLimitedTo = '';
			} else if (rt.Ref_Limit_to_Acct_or_Cntct__c == 'Contact') {
				this.refTypeLimitedTo = 'Contact';
			} else if (rt.Ref_Limit_to_Acct_or_Cntct__c == 'Account') {
				this.refTypeLimitedTo = 'Account';
			}
    	}
    }
    
    public class AttributeWrapper {
    	public String filterId { get; set; }
    	public String attributeId { get; set; }
    	public String attributeLabelId { get; set; }
    	public String filterLimitedTo { get; set; }
    	public String attributeLimitedTo { get; set; }
    	public Boolean isSelected { get; set; }
    	public String attributeName { get; set; }
    	public String filterName { get; set; }
    	
    	public AttributeWrapper(Attributes_Labels__c al, String rootAttLimitedTo) {
    		this.filterId = al.Label__c;
    		this.attributeId = al.Attribute__c;
    		this.attributeLabelId = al.Id;
    		this.filterLimitedTo = al.Label__r.Ref_Limit_to_Acct_or_Cntct__c != null
    								? al.Label__r.Ref_Limit_to_Acct_or_Cntct__c : '';
    		this.attributeLimitedTo = rootAttLimitedTo;
    		this.isSelected = false;
    		this.attributeName = al.Attribute__r.Name;
    		this.filterName = al.Label__r.Name;
    	}
    }
}