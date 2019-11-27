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
 * Page: ReferenceWorkSpaceSLDS
 * Description: Class used to display all requests and provide filters on requests.
 * Created by: Dixita @Nov 2017
 */
public with sharing class ReferenceWorkspaceSLDSController extends RefEdgeEditionFeatures{
	
    /**
	* Properties and variables
	*/
	public String namespace { get; set; } 
    public String todayDate { get; set; }
	private static String SPECIFIED_REQUEST_MESSAGE = 'I would like to use an account as a reference for which you are the owner.  ';
    private static String APPROVE_DECLINE_LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.SelectReferenceUseContacts.getURL() + '?id=';
    private static String APPROVE_DECLINE_TITLE = 'Approve/Decline';
    private static String REFERENCE_REQUEST_TASK_SUBJECT = 'Reference Use Approval Request';
    
	/**
     * Method to get SelectionList
     */

	/**
     * Constructor
     */
    public ReferenceWorkspaceSLDSController() {
		namespace = UtilityController.appNamespace();
		todayDate = Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
	}
    
    @RemoteAction
    public static String getDefaults() {
		if (checkPermissions()) {
			try {
				Custom_Settings__c cs = UtilityController.getCustomSettings();
				List<String> returnList = new List<String>();
				List<User_Mapping__c> userMappings = [SELECT Id, Label__c, Visible__c, From_Mapping__c, Process__c, User__c, Field_API_Name__c, Default_Value__c, Order__c FROM User_Mapping__c WHERE Label__c = null AND User__c = :UserInfo.getUserId() AND Process__c = 'WorkspaceSLDS' Order By Order__c];
				Map<Decimal,User_Mapping__c> userMappingMap = new Map<Decimal,User_Mapping__c>();
				
				if (userMappings.size() == 0) {
					Integer selNo = 1;
					List<String> selectionList = new List<String>();
					selectionList.add('Managed');
					selectionList.add('My Requests & Projects');
					selectionList.add('Open Requests & Projects');
					selectionList.add('Peer2Peer');
					selectionList.add('Nomination');
					selectionList.add('Requests with Opportunities');
					selectionList.add('Requests without Opportunities');
					selectionList.add('Today\'s Requests');
					selectionList.add('Unspecified');

					for (String name : selectionList) {
						User_Mapping__c tempUM = new User_Mapping__c();
						tempUM.User__c = UserInfo.getUserId();
						tempUM.Process__c = 'WorkspaceSLDS';
						tempUM.Field_API_Name__c = name;
						tempUM.Visible__c = selNo == 3 ? true : false;
						tempUM.Default_Value__c = selNo == 5 ? 'Nomination__c' : (selNo == 4 ? 'Reference_Request_Account__c' : (selNo == 9 ? 'Unspecified_Request__c' : 'Reference_Request_Account__c,Unspecified_Request__c'));
						tempUM.Order__c = selNo++;
						tempUM.From_Mapping__c = false;
						userMappings.add(tempUM);
					}
					
					insert userMappings;
					createDefaultFilters(userMappings);
				}
				
				for (User_Mapping__c record : userMappings) {
					userMappingMap.put(record.Order__c,record);
				}
				returnList.add(JSON.serialize(userMappingMap));
				returnList.add(getFields());
				Date criticalDate = cs.Critical_Deadline_window__c != null && String.valueOf(cs.Critical_Deadline_window__c) != '' ? system.today().addDays(Integer.valueOf(cs.Critical_Deadline_window__c)) : null ;
				String criticalDateString = criticalDate != null ? JSON.serialize(criticalDate) : null;
				returnList.add(criticalDateString);
				Date cautionDate = cs.Caution_deadline_window__c != null && String.valueOf(cs.Caution_deadline_window__c) != '' ? system.today().addDays(Integer.valueOf(cs.Caution_deadline_window__c)) : null ;
				String cautionDateString = cautionDate != null ? JSON.serialize(cautionDate) : null;
				returnList.add(cautionDateString);
				Date nominationCriticalDate = cs.Nomination_disposition_window__c != null && String.valueOf(cs.Nomination_disposition_window__c) != '' ? system.today().addDays(-integer.valueOf(cs.Nomination_disposition_window__c)) : null;
				String nominationCriticalDateString = nominationCriticalDate != null ? JSON.serialize(nominationCriticalDate) : null;
				returnList.add(nominationCriticalDateString);
				Date managed_to_P2P_Min = cs.Managed_to_P2P_Min__c != null && String.valueOf(cs.Managed_to_P2P_Min__c) != '' ? system.today().addDays(integer.valueOf(cs.Managed_to_P2P_Min__c)) : null;
				String managed_to_P2P_MinString = managed_to_P2P_Min != null ? JSON.serialize(managed_to_P2P_Min) : null;
				returnList.add(managed_to_P2P_MinString);
				returnList.add(JSON.serialize(getReferencibilityTypes()));

				Map<String,String> arStatusList = new Map<String,String>();
				Schema.SObjectType artargetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Reference_Request_Account__c'); //From the Object Api name retrieving the SObject
				Sobject arObject_name = artargetType.newSObject();
				Schema.sObjectType arsobject_type = arObject_name.getSObjectType(); //grab the sobject that was passed
				Schema.DescribeSObjectResult arsobject_describe = arsobject_type.getDescribe(); //describe the sobject
				Map<String, Schema.SObjectField> arfield_map = arsobject_describe.fields.getMap();
				Schema.DescribeFieldResult arfieldResult = arfield_map.get(UtilityController.appNamespace() + 'Account_Request_Status__c').getDescribe();
				List<Schema.PicklistEntry> arentry = arfieldResult.getPicklistValues();
						
				for (Schema.PicklistEntry value : arentry) {
					arStatusList.put(value.getLabel(), value.getValue());
				} 
				returnList.add(JSON.serialize(arStatusList));
				Map<String,String> urStatusList = new Map<String,String>();
				Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Unspecified_Request__c'); //From the Object Api name retrieving the SObject
				Sobject Object_name = targetType.newSObject();
				Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
				Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
				Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
				Schema.DescribeFieldResult urfieldResult = field_map.get(UtilityController.appNamespace() + 'Unspecified_Request_Status__c').getDescribe();
				List<Schema.PicklistEntry> urentry = urfieldResult.getPicklistValues();
						
				for (Schema.PicklistEntry value : urentry) {
					urStatusList.put(value.getLabel(), value.getValue());
				} 
				returnList.add(JSON.serialize(urStatusList));
				returnList.add(JSON.serialize(cs));
				return JSON.serialize(returnList);
			} catch (Exception ex) {
				return null;
			}
		} else {
			List<Apexpages.Message> msgs = ApexPages.getMessages();
			String msg = msgs.size() > 0 ? msgs[0].getDetail() : '';
			return 'false:' + msg;
		}
    }
	public static void createDefaultFilters(List<User_Mapping__c> views) {
		List<User_Mapping__c> filtersToInsert = new List<User_Mapping__c>();
		String namespace = UtilityController.appNamespace();
		User_Mapping__c tempUM = new User_Mapping__c();

		for (User_Mapping__c view : views) {
			tempUM = new User_Mapping__c();
			tempUM.User__c = UserInfo.getUserId();
			tempUM.Process__c = 'WorkspaceSLDS';
				
			if (view.Order__c == 1) { //Managed
				tempUM.Field_API_Name__c = namespace + 'Managed_Request__c::Managed Request::BOOLEAN::equals::' + namespace + 'Reference_Request_Account__c';
				tempUM.Visible__c = false;
				tempUM.Default_Value__c = 'true';
				tempUM.Label__c = view.Id;
				filtersToInsert.add(tempUM);
			} else if (view.Order__c == 2) { //My Requests & Projects
				tempUM.Field_API_Name__c = namespace + 'Project_Owner__c::Project Owner::REFERENCE::equals::' + namespace + 'Reference_Request_Account__c';
				tempUM.Visible__c = false;
				tempUM.Default_Value__c = UserInfo.getUserId();
				tempUM.Label__c = view.Id;
				filtersToInsert.add(tempUM);
				tempUM = new User_Mapping__c();
				tempUM.User__c = UserInfo.getUserId();
				tempUM.Process__c = 'WorkspaceSLDS';
				tempUM.Field_API_Name__c = namespace + 'Project_Owner__c::Project Owner::REFERENCE::equals::' + namespace + 'Unspecified_Request__c';
				tempUM.Visible__c = false;
				tempUM.Default_Value__c = UserInfo.getUserId();
				tempUM.Label__c = view.Id;
				filtersToInsert.add(tempUM);
			} else if (view.Order__c == 4) { //Peer2Peer
				tempUM.Field_API_Name__c = namespace + 'Managed_Request__c::Managed Request::BOOLEAN::equals::' + namespace + 'Reference_Request_Account__c';
				tempUM.Visible__c = false;
				tempUM.Default_Value__c = 'false';
				tempUM.Label__c = view.Id;
				filtersToInsert.add(tempUM);
			} else if (view.Order__c == 6) { //Requests with Opportunities
				tempUM.Field_API_Name__c = namespace + 'Reference_Request__r.Opportunity__c::Opportunity::REFERENCE::not equal to::' + namespace + 'Reference_Request_Account__c';
				tempUM.Visible__c = false;
				tempUM.Default_Value__c = null;
				tempUM.Label__c = view.Id;
				filtersToInsert.add(tempUM);
				tempUM = new User_Mapping__c();
				tempUM.User__c = UserInfo.getUserId();
				tempUM.Process__c = 'WorkspaceSLDS';
				tempUM.Field_API_Name__c = namespace + 'Reference_Request__r.Opportunity__c::Opportunity::REFERENCE::not equal to::' + namespace + 'Unspecified_Request__c';
				tempUM.Visible__c = false;
				tempUM.Default_Value__c = null;
				tempUM.Label__c = view.Id;
				filtersToInsert.add(tempUM);
				
			} else if (view.Order__c == 7) { //Requests withOut Opportunities
				tempUM.Field_API_Name__c = namespace + 'Reference_Request__r.Opportunity__c::Opportunity::REFERENCE::equals::' + namespace + 'Reference_Request_Account__c';
				tempUM.Visible__c = false;
				tempUM.Default_Value__c = null;
				tempUM.Label__c = view.Id;
				filtersToInsert.add(tempUM);
				tempUM = new User_Mapping__c();
				tempUM.User__c = UserInfo.getUserId();
				tempUM.Process__c = 'WorkspaceSLDS';
				tempUM.Field_API_Name__c = namespace + 'Reference_Request__r.Opportunity__c::Opportunity::REFERENCE::equals::' + namespace + 'Unspecified_Request__c';
				tempUM.Visible__c = false;
				tempUM.Default_Value__c = null;
				tempUM.Label__c = view.Id;
				filtersToInsert.add(tempUM);
			} else if (view.Order__c == 8) { //Today's Requests CreatedDate
				tempUM.Field_API_Name__c = 'CreatedDate::CreatedDate::DATE::greater or equal::' + namespace + 'Reference_Request_Account__c';
				tempUM.Visible__c = false;
				tempUM.Default_Value__c = 'TODAY';
				tempUM.Label__c = view.Id;
				filtersToInsert.add(tempUM);
				tempUM = new User_Mapping__c();
				tempUM.User__c = UserInfo.getUserId();
				tempUM.Process__c = 'WorkspaceSLDS';
				tempUM.Field_API_Name__c = 'CreatedDate::CreatedDate::DATE::greater or equal::' + namespace + 'Unspecified_Request__c';
				tempUM.Visible__c = false;
				tempUM.Default_Value__c = 'TODAY';
				tempUM.Label__c = view.Id;
				filtersToInsert.add(tempUM);
			}
		}
		insert filtersToInsert;
	}
	/**
     * Method to get Nomination/Request Fields
     */
    public static String getFields() {
		List<FieldWrapper> fieldListNomination = new List<FieldWrapper>();
		List<FieldWrapper> fieldListRequest = new List<FieldWrapper>();
		List<User_Mapping__c> userMappingsNomination = UtilityController.getUserMappings(ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS);
		List<User_Mapping__c> userMappingsRequest = UtilityController.getUserMappings(ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS);
		String namespace = UtilityController.appNamespace();

		for (User_Mapping__c mapping : userMappingsNomination) {
			fieldListNomination.add(new FieldWrapper(mapping.Field_API_Name__c,mapping.Label__c,mapping.Visible__c, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, mapping.Default_Value__c, mapping));
		}
	    	
	    for (User_Mapping__c mapping : userMappingsRequest) {
			fieldListRequest.add(new FieldWrapper(mapping.Field_API_Name__c,mapping.Label__c,mapping.Visible__c, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, mapping.Default_Value__c, mapping));
		}	

		Boolean newInsert = false;
	    	
	    if (fieldListRequest.size() == 0) { 
			fieldListRequest.add(new FieldWrapper(namespace + 'Account__r.Name', 'Account Requested', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'LookUp:Account', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Reference_Type_Needed__r.Name', 'Type', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'Picklist:Type', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper('hasOpportunity', 'Opportunity Icon', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Requester__r.Name', 'Requester', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Deadline__c', 'Deadline' ,true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'Date', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Project_Owner__r.Name', 'Owner', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'LookUp:User', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Process__c', 'Process', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'PickList:Process', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper('CreatedDate', 'Submitted Date', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Reference_Request__r.' + namespace + 'Opportunity__r.Name', 'Opportunity', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS,  'FALSE',new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Reference_Request__r.' + namespace + 'Opportunity__r.Account.Name', 'Opportunity Account', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper('Name', 'Request Name', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Reference_Request__r.Name', 'Reference Request Name', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper('LastModifiedDate', 'Last Updated', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Reference_Request__r.' + namespace + 'Title__c', 'Subject', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'String', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper('dueColor', 'Due In', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Account_Request_Status__c', 'Status', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'PickList:Status', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Reference_Request__r.' + namespace + 'Case__r.CaseNumber', 'Case', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListRequest.add(new FieldWrapper(namespace + 'Reference_Request_Account_Contacts__r.records.' + namespace + 'Contact__r.Name', 'Contact', true, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, 'LookUp:Contact', new User_Mapping__c()));
			saveSelectedColumns(JSON.serialize(fieldListRequest),'false','false');
			newInsert = true;
		}
    		
		if (fieldListNomination.size() == 0) {
			fieldListNomination.add(new FieldWrapper(namespace + 'Account__r.Name', 'Account', true, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListNomination.add(new FieldWrapper(namespace + 'Contact__r.Name', 'Contact', true, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListNomination.add(new FieldWrapper(namespace + 'Status__c', 'Status', true, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListNomination.add(new FieldWrapper('dueColor', 'Due In', true, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListNomination.add(new FieldWrapper('Owner.Name', 'Owner', true, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListNomination.add(new FieldWrapper(namespace + 'Manager__r.Name', 'Manager', true, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListNomination.add(new FieldWrapper('CreatedBy.Name', 'Created By', true, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, 'FALSE', new User_Mapping__c()));
			fieldListNomination.add(new FieldWrapper('CreatedDate', 'Created Date', true, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, 'FALSE', new User_Mapping__c()));
			saveSelectedColumns(JSON.serialize(fieldListNomination),'true','false');
			newInsert = true;
		}
		
		if (newInsert) {
			userMappingsNomination = UtilityController.getUserMappings(ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS);
			userMappingsRequest = UtilityController.getUserMappings(ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS);
			fieldListNomination = new List<FieldWrapper>();
			fieldListRequest = new List<FieldWrapper>();

			for (User_Mapping__c mapping : userMappingsNomination) {
				fieldListNomination.add(new FieldWrapper(mapping.Field_API_Name__c,mapping.Label__c,mapping.Visible__c, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, mapping.Default_Value__c, mapping));
			}
				
			for (User_Mapping__c mapping : userMappingsRequest) {
				fieldListRequest.add(new FieldWrapper(mapping.Field_API_Name__c,mapping.Label__c,mapping.Visible__c, ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS, mapping.Default_Value__c, mapping));
			}	
		} else {
			
			if (fieldListNomination.size() == 7) {
				User_Mapping__c mapping = new User_Mapping__c(Visible__c = false,
															Default_Value__c = 'LookUp:User',
															Field_API_Name__c = namespace + 'Manager__r.Name',
															User__c = UserInfo.getUserId(),
															Order__c = 8,
															Label__c = 'Manager',
															Process__c = ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS);
				insert mapping;
				fieldListNomination.add(new FieldWrapper(mapping.Field_API_Name__c,mapping.Label__c,mapping.Visible__c, ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS, mapping.Default_Value__c, mapping));
			}
		}
		List<List<FieldWrapper>> returnList = new List<List<FieldWrapper>>();
		returnList.add(fieldListNomination);
		returnList.add(fieldListRequest);
		return JSON.serialize(returnList);
    }
   	 	
    /**
     * Method to save default selection
     */
    @RemoteAction
    public static Boolean saveAsDefaultView(String defaultsList, String selectionOrder) {
		Boolean success = true;
		Map<Decimal,User_Mapping__c> userMapping = (Map<Decimal,User_Mapping__c>)JSON.deserialize(defaultsList, Map<Decimal,User_Mapping__c>.class);
		List<User_Mapping__c> updateList = new List<User_Mapping__c>();
		
		if (checkPermissions()) {
			
			for (Decimal key : userMapping.keySet()) {
				User_Mapping__c tempUM = userMapping.get(key);
				tempUM.Visible__c = selectionOrder.equals(String.valueOf(key)) ? true : false;
				updateList.add(tempUM);
			}
			update updateList;
		} else {
			success = false;
		}
		return success;
    }

	/**
     * Method to Delete View
     */
    @RemoteAction
    public static String deleteViewEntry(String viewId) {
		String returnValue = '';

		if (checkPermissions()) {
			User_Mapping__c userMapping = [SELECT Id, Label__c, Visible__c, Field_API_Name__c, From_Mapping__c, Default_Value__c, Order__c FROM User_Mapping__c WHERE Id =:viewId]; 
			Decimal order = userMapping.Order__c;
			List<User_Mapping__c> allFilters = [SELECT Id, Label__c, Visible__c, Field_API_Name__c, From_Mapping__c, Default_Value__c, Order__c FROM User_Mapping__c WHERE Label__c =:viewId AND User__c = :UserInfo.getUserId() AND Process__c = 'WorkspaceSLDS'];
			allFilters.add(userMapping);
			Database.DeleteResult result =  Database.delete(userMapping, true);
			
			if (result.isSuccess()) {
				if (userMapping.Visible__c) {
					User_Mapping__c defaultView = [SELECT Id, Label__c, Visible__c, Field_API_Name__c, From_Mapping__c, Default_Value__c, Order__c FROM User_Mapping__c WHERE Label__c = null AND User__c = :UserInfo.getUserId() AND Order__c = 3 LIMIT 1]; 
					defaultView.Visible__c = true;
					update defaultView;
				}
				returnValue =  String.valueOf(order);
			} else {
				returnValue =  null;
			}
		} else {
			List<Apexpages.Message> msgs = ApexPages.getMessages();
			String msg = msgs.size() > 0 ? msgs[0].getDetail() : 'Insufficient Access Rights';
			returnValue = msg;
		}
		return returnValue;
    }

	/**
     * Method to save default selection
     */
    @RemoteAction
    public static User_Mapping__c updateNewView(String listViewId, String order) {
		User_Mapping__c newRecord = [SELECT Id, Label__c, Visible__c, Field_API_Name__c, From_Mapping__c, Default_Value__c, Order__c FROM User_Mapping__c WHERE Id =:listViewId]; 
		newRecord.Order__c = Integer.valueOf(order) + 1;
		update newRecord;
		return newRecord;
    }
    
    /**
	* Method to get Referencibility Types
	*/
    public static List<object> getReferencibilityTypes() {
		List<object> returnList = new List<object>();
		List<RefTypeWrapper> refTypesMap = new List<RefTypeWrapper>();
        
		for (Referenceability_Type__c refType : [SELECT Id, Name, Sales_Point__c, Max_accounts_per_request_type__c,
                                                    Min_lead_time_per_request_type__c, Project_type__c, Request_type__c,
                                                    Referenceability_no__c FROM Referenceability_Type__c
                                                    WHERE Visible__c = true
                                                    ORDER BY Name LIMIT :Limits.getLimitQueryRows()]) {
            refTypesMap.add(new RefTypeWrapper(refType));
        }										
		Custom_Settings__c cs = UtilityController.getCustomSettings();
        Boolean accountRequired = cs.Project_Account_Required__c;
        Boolean contactRequired = cs.Project_Contact_Required__c;
        Boolean oppRequired = cs.Project_Opportunity_Required__c;
        Boolean caseRequired = cs.Project_Case_Required__c;
        Boolean noteRequired = cs.Project_Notes_Required__c;
        Boolean subjectRequired = cs.Project_Subject_Required__c;	
        returnList.add(refTypesMap);	
        returnList.add(accountRequired);	
        returnList.add(contactRequired);	
        returnList.add(oppRequired);	
        returnList.add(caseRequired);	
        returnList.add(noteRequired);
        returnList.add(subjectRequired);								
        return returnList;										
    }
    /**
     * Method to get records based on selection
     */
    @RemoteAction
    public static String getData(String selection, String existingIdString, String extraCondition, String sortBy, String sortOrder) {
		String returnValue = '';
		String sortByReqUR = sortBy == '' || sortBy == null ? UtilityController.appNamespace() + 'Deadline__c' : sortBy;
		String sortByReqAR = sortBy == '' || sortBy == null ? UtilityController.appNamespace() + 'Deadline__c' : sortBy;
		
    	try {
			List<String> existingIds =  (List<String>)JSON.deserialize(existingIdString, List<String>.class);
			Custom_Settings__c cs = UtilityController.getCustomSettings();
			Date cautionDate = cs.Caution_deadline_window__c != null && String.valueOf(cs.Caution_deadline_window__c) != '' ? system.today().addDays(Integer.valueOf(cs.Caution_deadline_window__c)) : null ;
			Date criticalDate = cs.Critical_Deadline_window__c != null && String.valueOf(cs.Critical_Deadline_window__c) != '' ? system.today().addDays(Integer.valueOf(cs.Critical_Deadline_window__c)) : null ;
			Date nominationCriticalDate = cs.Nomination_disposition_window__c != null && String.valueOf(cs.Nomination_disposition_window__c) != '' ? system.today().addDays(-integer.valueOf(cs.Nomination_disposition_window__c)) : null;
			User_Mapping__c view =  (User_Mapping__c)JSON.deserialize(selection, User_Mapping__c.class);
			List<User_Mapping__c> allFilters = [SELECT Id, Label__c, Visible__c, Field_API_Name__c, From_Mapping__c, Default_Value__c, Order__c FROM User_Mapping__c WHERE Label__c =:view.Id AND User__c = :UserInfo.getUserId() AND Process__c = 'WorkspaceSLDS'];
			List<User_Mapping__c> unspecifiedFilters = new List<User_Mapping__c>();
			List<User_Mapping__c> accountFilters = new List<User_Mapping__c>();
			List<User_Mapping__c> nominationFilters = new List<User_Mapping__c>();
			Boolean hasAccountRequest = false , hasUnspecifiedRequest = false , hasNomination = false;
			
			for (User_Mapping__c filter : allFilters) {
				
				if (filter.Field_API_Name__c.split('::').get(4).containsIgnoreCase('Unspecified_Request__c')) {
					unspecifiedFilters.add(filter);
				} else if (filter.Field_API_Name__c.split('::').get(4).containsIgnoreCase('Reference_Request_Account__c')) {
					accountFilters.add(filter);
				} else if (filter.Field_API_Name__c.split('::').get(4).containsIgnoreCase('Nomination__c')) {
					nominationFilters.add(filter);
				}
			}

			if (view.Default_Value__c.containsIgnoreCase('Unspecified_Request__c') && !view.From_Mapping__c || unspecifiedFilters.size() > 0) {
				hasUnspecifiedRequest = true;
			}
			
			if (view.Default_Value__c.containsIgnoreCase('Reference_Request_Account__c') && !view.From_Mapping__c || accountFilters.size() > 0) {
				hasAccountRequest = true;
			}
			
			if (view.Default_Value__c.containsIgnoreCase('Nomination__c') || nominationFilters.size() > 0) {
				hasNomination = true;
			}

			if (!hasNomination && allFilters.size() == 0 && view.From_Mapping__c) {
				hasUnspecifiedRequest = true;
				hasAccountRequest = true;
			}
			String unspecifiedWhere = getWhereClause(unspecifiedFilters);
			String accountWhere = getWhereClause(accountFilters);
			String nominationWhere = getWhereClause(nominationFilters);
			Set<String> status = new Set<String> {
				ConstantsController.COMPLETED, ConstantsController.NO_LONGER_NEEDED, ConstantsController.ACCOUNT_SPECIFIED, ConstantsController.UNAVAILABLE, ConstantsController.NO_RESPONSE
			};
			sortOrder = sortOrder == 'DESC' ? sortOrder + ' NULLS LAST' : sortOrder;
			List<List<SObject>> recordList = new List<List<SObject>>();
			String URextraCondition = extraCondition == 'OnHold' ? 'AND Unspecified_Request_Status__c = \'On Hold\'' : extraCondition;
			
			sortByReqUR = sortBy == UtilityController.appNamespace() + 'Account_Request_Status__c' ? UtilityController.appNamespace() + 'Unspecified_Request_Status__c' : sortByReqUR	;
			sortByReqUR = sortBy.containsIgnoreCase('Reference_Request_Account_Contacts__r') ? UtilityController.appNamespace() + 'Deadline__c' : sortByReqUR	;
			sortByReqUR = sortBy.containsIgnoreCase('Account__r') || sortBy.containsIgnoreCase('Process__c') ? UtilityController.appNamespace() + 'Deadline__c' : sortByReqUR	;
			
			String queryUnspecified = 'SELECT Reference_Request__r.Case__c, Reference_Request__r.Name, Name, Reference_Request__c, Reference_Request__r.Opportunity__r.Name, '
												+ 'Reference_Request__r.Opportunity__r.Account.Name, Reference_Request__r.Title__c, LastModifiedDate, Notes__c,'
												+ 'Id, Reference_Request__r.Id, CreatedDate, Reference_Request__r.Opportunity__c, CreatedById, Project_Owner__c, '
												+ 'Reference_Request__r.Case__r.CaseNumber, Requester__r.Name, Deadline__c, Reference_Type_Needed__c, Reference_Type_Needed__r.Name, Project_Owner__r.Name, Unspecified_Request_Status__c '
												+ 'FROM Unspecified_Request__c '
												+ 'WHERE Unspecified_Request_Status__c NOT IN :status '
												+ 'AND Specified_Account__c = null '
												+ 'AND Deadline__c != null '
												+ 'AND Reference_Request__r.Reference_Request_Status__c NOT IN :status'
												+ unspecifiedWhere + ' '
												+ URextraCondition + ' '
												+ 'AND Id NOT IN :existingIds '
												+ 'ORDER BY ' + sortByReqUR + ' ' + sortOrder + ' LIMIT 25';
			if (hasUnspecifiedRequest) {
				List<Unspecified_Request__c> uRList = Database.query(queryUnspecified);
				recordList.add(uRList);
			} 
			String ARextraCondition = extraCondition == 'OnHold' ? 'AND Account_Request_Status__c = \'On Hold\'' : extraCondition;
			String queryAccount = 'SELECT Reference_Request__r.Opportunity__r.Account.Name, Name, Reference_Request__r.Name, Reference_Request__c, Reference_Request__r.Opportunity__r.Name, '
												+ 'Reference_Request__r.Case__r.CaseNumber, Reference_Request__r.Title__c, LastModifiedDate, Approve_Deny_Notes__c, '
												+ 'Id, Reference_Request__r.Id, CreatedDate, Reference_Request__r.Opportunity__c, CreatedById, Project_Owner__c, '
												+ 'Requester__r.Name, Account__c ,Account__r.Name, Process__c, Deadline__c, Managed_Request__c, Reference_Owner__c, '
												+ 'Project_Owner__r.Name, Reference_Type_Needed__c, Reference_Type_Needed__r.Name, Account_Request_Status__c, '
												+ '(SELECT Contact__c, Contact__r.Phone, Contact__r.Email, Contact__r.Name FROM Reference_Request_Account_Contacts__r)'
												+ ' FROM Reference_Request_Account__c'
												+ ' WHERE Account_Request_Status__c NOT IN :status'
												+ ' AND Approval_Status__c = null' 
												+ ' AND Deadline__c != null' 
												+ ' AND Account_Request_Status__c NOT IN :status'
												+ ' AND Reference_Request__r.Reference_Request_Status__c NOT IN :status'
												+ ' AND (NOT Account_Request_Status__c LIKE \'Give Up%\')'
												+ ' AND Reference_Use__c = false '
												+ accountWhere + ' '
												+ ARextraCondition + ' '
												+ 'AND Id NOT IN :existingIds '
												+ ' ORDER BY ' + sortByReqAR + ' ' + sortOrder + ' LIMIT 25';
								
			if (hasAccountRequest) {
				List<Reference_Request_Account__c> aRList = Database.query(queryAccount);
				recordList.add(aRList);
			}
			String completed = ConstantsController.COMPLETED ;
			String sortByNom = sortBy == '' || sortBy == null ? 'CreatedDate' : sortBy;
			String queryNomination = 'SELECT Id, Name, Account__c ,Account__r.Name, Contact__r.Name, Other_Info__c, Status__c, OwnerId, '
								+ 'Owner.Name, CreatedBy.Name, CreatedDate , Manager__c, Manager__r.Name '
								+ 'FROM Nomination__c '
								+ 'WHERE Status__c != :completed '
								+ 'AND Account__c != null '
								+ 'AND Id NOT IN :existingIds '
								+ nominationWhere + ' '
								+ extraCondition + ' '
								+ 'ORDER BY ' + sortByNom + ' ' + sortOrder + ' LIMIT 25';
			if (hasNomination) {
				List<Nomination__c> nomList = Database.query(queryNomination);
				returnValue = JSON.serialize(nomList);
			}

			if (!hasNomination) {
				List<SObject> returnList =  new List<SObject>();
				Boolean isAesc = sortOrder == 'ASC' ? true : false;
				returnList = sortRecords(sortByReqAR , recordList , isAesc);
				returnValue = JSON.serialize(returnList);
			}
			
		} catch (Exception ex) {
			returnValue = null;
		}
		return returnValue;
    }

	/**
     * Method to Sort Objects
     */
	public static List<SObject> sortRecords(String field, List<List<SObject>> recordList, Boolean isAesc) {
		List<SortWrapper> recordWrapperList = new List<SortWrapper>();
		Integer count = 1;
		
		for (Integer index = 0 ; index < recordList.size() ; index++ ) {
			List<SObject> innerRecordList = recordList[index];
			
			for (SObject record : innerRecordList) {
				recordWrapperList.add(new SortWrapper(record, field, isAesc));
			}
		}
		recordWrapperList.sort();
		List<SObject> returnList = new List<SObject> ();

		for (SortWrapper wrapperRecord : recordWrapperList) {

			if (count < 101) {
				returnList.add(wrapperRecord.record);
				count++;
			} else {
				break;
			} 
		}
        return returnList;
    }

	public class SortWrapper implements Comparable {

		public SObject record;
		public String sortBy;
		public Boolean aesc;
		public Boolean isUR;

		// Constructor
		public SortWrapper(SObject record , String sortBy , Boolean aesc) {
			this.record = record;
			this.sortBy = sortBy;
			this.aesc = aesc;
			this.isUR = record instanceof Unspecified_Request__c;
		}

		public Integer compareTo(Object compareTo) {
			try {
				SortWrapper compareToRecord = (SortWrapper)compareTo;
				Integer returnValue = 0;
				Object recordValue ;
				Object compareToRecordValue;
				
				if (sortBy == UtilityController.appNamespace() + 'Process__c' && isUR ){
					recordValue = 'Managed';
				} else if (sortBy == UtilityController.appNamespace() + 'Account__r.Name' && isUR ) {
					recordValue = 'Unspecified';
				} else if (sortBy.contains('Reference_Request_Account_Contacts__r') && isUR ) {
					recordValue = '';
				} else if (sortBy == UtilityController.appNamespace() + 'Account_Request_Status__c' && isUR ) {
					String URField = UtilityController.appNamespace() + 'Unspecified_Request_Status__c';
					recordValue = record.get(URField);
				} else {
					List<String> sortByList = sortBy.split('\\.');
					recordValue = record;
					
					Integer index;
					for (index = 0 ; index < sortByList.size() - 1 ; index++) {
						
						if (recordValue != null) {
							recordValue = ((SObject)recordValue).getSObject(sortByList[index]);
						}
						
					}
					recordValue = recordValue != null ? ((SObject)recordValue).get(sortByList[index]) : '';
				}

				if (sortBy == UtilityController.appNamespace() + 'Process__c' && compareToRecord.isUR){
					compareToRecordValue = 'Managed';
				} else if (sortBy == UtilityController.appNamespace() + 'Account__r.Name' && compareToRecord.isUR) {
					compareToRecordValue = 'Unspecified';
				} else if (sortBy.contains('Reference_Request_Account_Contacts__r') && compareToRecord.isUR) {
					compareToRecordValue = '';
				}  else if (sortBy == UtilityController.appNamespace() + 'Account_Request_Status__c' && compareToRecord.isUR) {
					String URField = UtilityController.appNamespace() + 'Unspecified_Request_Status__c';
					compareToRecordValue = compareToRecord.record.get(URField);
				} else {
					List<String> sortByList = sortBy.split('\\.');
					compareToRecordValue = compareToRecord.record;
					Integer index;

					for (index = 0 ; index < sortByList.size() - 1 ; index++) {
						
						if (compareToRecordValue != null) {
							compareToRecordValue = ((SObject)compareToRecordValue).getSObject(sortByList[index]);
						}
					}
					compareToRecordValue = compareToRecordValue != null ? ((SObject)compareToRecordValue).get(sortByList[index]) : '';
				}
				
				if (String.valueOf(recordValue) == '' && String.valueOf(compareToRecordValue) != '') {
					returnValue = aesc ? -1 : 1;
				} else if (String.valueOf(compareToRecordValue) == '' && String.valueOf(recordValue) != '') {
					returnValue = aesc ? 1 : -1;
				} else if (getType(recordValue) == 'Date') {
					
					if (Date.valueOf(recordValue) >= Date.valueOf(compareToRecordValue)) {
						returnValue = aesc ? 1 : -1;
					} else if (Date.valueOf(recordValue) < Date.valueOf(compareToRecordValue)) {
						returnValue = aesc ? -1 : 1;
					}
				} else if (getType(recordValue) == 'Datetime') {
					
					if (Datetime.valueOf(recordValue) >= Datetime.valueOf(compareToRecordValue)) {
						returnValue = aesc ? 1 : -1;
					} else if (Datetime.valueOf(recordValue) < Datetime.valueOf(compareToRecordValue)) {
						returnValue = aesc ? -1 : 1;
					}
				} else if (getType(recordValue) == 'Double') {
					
					if (Double.valueOf(recordValue) >= Double.valueOf(compareToRecordValue)) {
						returnValue = aesc ? 1 : -1;
					} else if (Double.valueOf(recordValue) < Double.valueOf(compareToRecordValue)) {
						returnValue = aesc ? -1 : 1;
					}
				} else {
					
					if (String.valueOf(recordValue) >= String.valueOf(compareToRecordValue)) {
						returnValue = aesc ? 1 : -1;
					} else if (String.valueOf(recordValue) < String.valueOf(compareToRecordValue)) {
						returnValue = aesc ? -1 : 1;
					}
				} 
				return returnValue;   
			} catch(Exception ex) {
				return null;
			}
		}
		string getType(Object obj) {
			if (obj == null) {
				return '';
			} else if(obj instanceof Boolean) {
				return 'String';
			} else if(obj instanceof Id) {
				return 'String';
			} else if(obj instanceof String) {
				return 'String';
			} else if(obj instanceof Blob) {
				return 'String';
			} else if(obj instanceof Date) {
				return 'Date';
			} else if(obj instanceof Datetime) {
				return 'Datetime';
			} else if(obj instanceof Integer) {
				return 'Double';
			} else if(obj instanceof Double) {
				return 'Double';
			} else if(obj instanceof Long) {
				return 'Double';
			} else if(obj instanceof Decimal) {
				return 'Double';
			} else {
				return 'String';
			}                  
		}
	}

	/**
     * Method to get records based on selection
     */
    @RemoteAction
    public static String getCount(String selection) {
		String returnValue = '';
		
    	try {
			Custom_Settings__c cs = UtilityController.getCustomSettings();
			User_Mapping__c view =  (User_Mapping__c)JSON.deserialize(selection, User_Mapping__c.class);
			List<User_Mapping__c> allFilters = [SELECT Id, Label__c, Visible__c, Field_API_Name__c, From_Mapping__c, Default_Value__c, Order__c FROM User_Mapping__c WHERE Label__c =:view.Id AND User__c = :UserInfo.getUserId() AND Process__c = 'WorkspaceSLDS'];
			List<User_Mapping__c> unspecifiedFilters = new List<User_Mapping__c>();
			List<User_Mapping__c> accountFilters = new List<User_Mapping__c>();
			List<User_Mapping__c> nominationFilters = new List<User_Mapping__c>();
			Boolean hasAccountRequest = false , hasUnspecifiedRequest = false , hasNomination = false;
			Date cautionDate = cs.Caution_deadline_window__c != null && String.valueOf(cs.Caution_deadline_window__c) != '' ? system.today().addDays(Integer.valueOf(cs.Caution_deadline_window__c)) : null ;
			Date criticalDate = cs.Critical_Deadline_window__c != null && String.valueOf(cs.Critical_Deadline_window__c) != '' ? system.today().addDays(Integer.valueOf(cs.Critical_Deadline_window__c)) : null ;
			Date nominationCriticalDate = cs.Nomination_disposition_window__c != null && String.valueOf(cs.Nomination_disposition_window__c) != '' ? system.today().addDays(-integer.valueOf(cs.Nomination_disposition_window__c)) : null;
			Integer allOpen = 0,red = 0,green = 0,yellow = 0,onHold = 0;
			
			for (User_Mapping__c filter : allFilters) {
				
				if (filter.Field_API_Name__c.split('::').get(4).containsIgnoreCase('Unspecified_Request__c')) {
					unspecifiedFilters.add(filter);
				} else if (filter.Field_API_Name__c.split('::').get(4).containsIgnoreCase('Reference_Request_Account__c')) {
					accountFilters.add(filter);
				} else if (filter.Field_API_Name__c.split('::').get(4).containsIgnoreCase('Nomination__c')) {
					nominationFilters.add(filter);
				}
			}
			if (view.Default_Value__c.containsIgnoreCase('Unspecified_Request__c') && !view.From_Mapping__c || unspecifiedFilters.size() > 0) {
				hasUnspecifiedRequest = true;
			}
			
			if (view.Default_Value__c.containsIgnoreCase('Reference_Request_Account__c') && !view.From_Mapping__c || accountFilters.size() > 0) {
				hasAccountRequest = true;
			}
			
			if (view.Default_Value__c.containsIgnoreCase('Nomination__c') || nominationFilters.size() > 0) {
				hasNomination = true;
			}

			if (!hasNomination && allFilters.size() == 0 && view.From_Mapping__c) {
				hasUnspecifiedRequest = true;
				hasAccountRequest = true;
			}
			String unspecifiedWhere = getWhereClause(unspecifiedFilters);
			String accountWhere = getWhereClause(accountFilters);
			String nominationWhere = getWhereClause(nominationFilters);
			Set<String> status = new Set<String> {
				ConstantsController.COMPLETED, ConstantsController.NO_LONGER_NEEDED, ConstantsController.ACCOUNT_SPECIFIED, ConstantsController.UNAVAILABLE, ConstantsController.NO_RESPONSE
			};
			
			String queryUnspecifiedAll = 'SELECT COUNT() FROM Unspecified_Request__c '
												+ 'WHERE Unspecified_Request_Status__c NOT IN :status '
												+ 'AND Reference_Request__r.Reference_Request_Status__c NOT IN :status '
												+ 'AND Specified_Account__c = null '
												+ 'AND Deadline__c != null '
												+ unspecifiedWhere ;
			String queryUnspecifiedRed = 'SELECT COUNT() FROM Unspecified_Request__c '
												+ 'WHERE Unspecified_Request_Status__c NOT IN :status '
												+ 'AND Specified_Account__c = null '
												+ 'AND Reference_Request__r.Reference_Request_Status__c NOT IN :status '
												+ 'AND Deadline__c != null '
												+ unspecifiedWhere + ' '
												+ 'AND Deadline__c < :criticalDate';
			String queryUnspecifiedYellow = 'SELECT COUNT() FROM Unspecified_Request__c '
												+ 'WHERE Unspecified_Request_Status__c NOT IN :status '
												+ 'AND Specified_Account__c = null '
												+ 'AND Deadline__c != null '
												+ 'AND Reference_Request__r.Reference_Request_Status__c NOT IN :status '
												+ unspecifiedWhere + ' '
												+ 'AND Deadline__c >= :criticalDate '
												+ 'AND Deadline__c <= :cautionDate ';	
			String queryUnspecifiedGreen = 'SELECT COUNT() FROM Unspecified_Request__c '
												+ 'WHERE Unspecified_Request_Status__c NOT IN :status '
												+ 'AND Specified_Account__c = null '
												+ 'AND Deadline__c != null '
												+ 'AND Reference_Request__r.Reference_Request_Status__c NOT IN :status '
												+ unspecifiedWhere + ' '
												+ 'AND Deadline__c > :cautionDate ';
			String queryUnspecifiedOnHold = 'SELECT COUNT() FROM Unspecified_Request__c '
												+ 'WHERE Unspecified_Request_Status__c NOT IN :status '
												+ 'AND Specified_Account__c = null '
												+ 'AND Deadline__c != null '
												+ 'AND Reference_Request__r.Reference_Request_Status__c NOT IN :status '
												+ unspecifiedWhere + ' '
												+ 'AND Unspecified_Request_Status__c = \'On Hold\' ';																																		
			
			if (hasUnspecifiedRequest) {
				Integer urCountAll = Database.countQuery(queryUnspecifiedAll);
				Integer urCountRed = Database.countQuery(queryUnspecifiedRed);
				Integer urCountYellow = Database.countQuery(queryUnspecifiedYellow);
				Integer urCountGreen = Database.countQuery(queryUnspecifiedGreen);
				Integer urCountOnHold = Database.countQuery(queryUnspecifiedOnHold);
				allOpen += urCountAll;
				red += urCountRed;
				green += urCountGreen;
				yellow += urCountYellow;
				onHold += urCountOnHold;
			} 
			String queryAccountAll = 'SELECT COUNT() FROM Reference_Request_Account__c'
												+ ' WHERE Account_Request_Status__c NOT IN :status'
												+ ' AND Approval_Status__c = null'
												+ ' AND Deadline__c != null' 
												+ ' AND Reference_Request__r.Reference_Request_Status__c NOT IN :status'
												+ ' AND Account_Request_Status__c NOT IN :status'
												+ ' AND (NOT Account_Request_Status__c LIKE \'Give Up%\')'
												+ ' AND Reference_Use__c = false '
												+ accountWhere ;
			String queryAccountRed = 'SELECT COUNT() FROM Reference_Request_Account__c'
												+ ' WHERE Account_Request_Status__c NOT IN :status'
												+ ' AND Approval_Status__c = null'
												+ ' AND Deadline__c != null' 
												+ ' AND Reference_Request__r.Reference_Request_Status__c NOT IN :status'
												+ ' AND Account_Request_Status__c NOT IN :status'
												+ ' AND (NOT Account_Request_Status__c LIKE \'Give Up%\')'
												+ ' AND Reference_Use__c = false '
												+ accountWhere + ' '
												+ 'AND Deadline__c < :criticalDate';
			String queryAccountYellow = 'SELECT COUNT() FROM Reference_Request_Account__c'
												+ ' WHERE Account_Request_Status__c NOT IN :status'
												+ ' AND Approval_Status__c = null'
												+ ' AND Reference_Request__r.Reference_Request_Status__c NOT IN :status'
												+ ' AND Deadline__c != null' 
												+ ' AND Account_Request_Status__c NOT IN :status'
												+ ' AND (NOT Account_Request_Status__c LIKE \'Give Up%\')'
												+ ' AND Reference_Use__c = false '
												+ accountWhere + ' '
												+ 'AND Deadline__c >= :criticalDate '
												+ 'AND Deadline__c <= :cautionDate ';	
			String queryAccountGreen = 'SELECT COUNT() FROM Reference_Request_Account__c'
												+ ' WHERE Account_Request_Status__c NOT IN :status'
												+ ' AND Approval_Status__c = null'
												+ ' AND Deadline__c != null' 
												+ ' AND Reference_Request__r.Reference_Request_Status__c NOT IN :status'
												+ ' AND Account_Request_Status__c NOT IN :status'
												+ ' AND (NOT Account_Request_Status__c LIKE \'Give Up%\')'
												+ ' AND Reference_Use__c = false '
												+ accountWhere + ' '
												+ 'AND Deadline__c >:cautionDate '	;
			String queryAccountOnHold = 'SELECT COUNT() FROM Reference_Request_Account__c'
												+ ' WHERE Account_Request_Status__c NOT IN :status'
												+ ' AND Approval_Status__c = null'
												+ ' AND Deadline__c != null' 
												+ ' AND Reference_Request__r.Reference_Request_Status__c NOT IN :status'
												+ ' AND Account_Request_Status__c NOT IN :status'
												+ ' AND (NOT Account_Request_Status__c LIKE \'Give Up%\')'
												+ ' AND Reference_Use__c = false '
												+ accountWhere + ' '
												+ 'AND Account_Request_Status__c = \'On Hold\' ';	

			if (hasAccountRequest) {
				Integer arCountAll = Database.countQuery(queryAccountAll);
				Integer arCountRed = Database.countQuery(queryAccountRed);
				Integer arCountYellow = Database.countQuery(queryAccountYellow);
				Integer arCountGreen = Database.countQuery(queryAccountGreen);
				Integer arCountOnHold = Database.countQuery(queryAccountOnHold);
				allOpen += arCountAll;
				red += arCountRed;
				green += arCountGreen;
				yellow += arCountYellow;
				onHold += arCountOnHold;
			}
			String completed = ConstantsController.COMPLETED ;
			String queryNominationAll = 'SELECT Count() FROM Nomination__c '
								+ 'WHERE Status__c != :completed '
								+ 'AND Account__c != null '
								+ nominationWhere;
			String queryNominationRed = 'SELECT Count() FROM Nomination__c '
								+ 'WHERE Status__c != :completed '
								+ 'AND Account__c != null '
								+ nominationWhere
								+ ' AND CreatedDate <= :nominationCriticalDate';
			String queryNominationGreen = 'SELECT Count() FROM Nomination__c '
								+ 'WHERE Status__c != :completed '
								+ 'AND Account__c != null '
								+ nominationWhere
								+ ' AND CreatedDate > :nominationCriticalDate';
			String queryNominationOnHold = 'SELECT Count() FROM Nomination__c '
								+ 'WHERE Status__c != :completed '
								+ 'AND Account__c != null '
								+ nominationWhere
								+ ' AND Status__c = \'On Hold\'';															
			if (hasNomination) {
				Integer nomCountAll = Database.countQuery(queryNominationAll);
				Integer nomCountRed = Database.countQuery(queryNominationRed);
				Integer nomCountGreen = Database.countQuery(queryNominationGreen);
				Integer nomCountOnHold = Database.countQuery(queryNominationOnHold);
				allOpen += nomCountAll;
				red += nomCountRed;
				green += nomCountGreen;
				onHold += nomCountOnHold;
			}

			List<Integer> returnList = new List<Integer>();
			returnList.add(allOpen);
			returnList.add(red);
			returnList.add(yellow);
			returnList.add(green);
			returnList.add(onHold);
			returnValue = JSON.serialize(returnList); 
		} catch (Exception ex) {
			List<Integer> returnList = new List<Integer>();
			returnList.add(0);
			returnList.add(0);
			returnList.add(0);
			returnList.add(0);
			returnList.add(0);
			returnValue = JSON.serialize(returnList); 
		}
		return returnValue;
    }

	/**
     * method to get accounts list for creating new ref leads
     * author: Dixita Jain (Feb, 2018)
     */
    private static String getWhereClause (List<User_Mapping__c> fiterMappings) {

		String whereClause = '';
		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
		dateFormat = dateFormat != null ? dateFormat : 'yyyy-MM-dd';
		List<String> dateFormatList = new List<String>();
		
		for (String str : dateFormat.split('[./-]')) {
			dateFormatList.add(str.substring(0, 1).toLowerCase());
		}
		
		Map<String, String> operatorMap = new Map<String, String>();
		operatorMap.put('equals', ' @@@ = \'###\' ');
		operatorMap.put('not equal to', ' @@@ != \'###\' ');
		operatorMap.put('less than', ' @@@ < \'###\' ');
		operatorMap.put('greater than', ' @@@ > \'###\' ');
		operatorMap.put('less or equal', ' @@@ <= \'###\' ');
		operatorMap.put('greater or equal', ' @@@ >= \'###\' ');
		operatorMap.put('contains', ' @@@ LIKE \'%###%\' ');
		operatorMap.put('does not contain', ' (NOT @@@ LIKE \'%###%\') ');
		operatorMap.put('starts with', ' @@@ LIKE \'###%\' ');
		operatorMap.put('includes', ' @@@ INCLUDES (\'###\') ');
		operatorMap.put('excludes', ' @@@ EXCLUDES (\'###\') ');
    		
		if (fiterMappings != null && fiterMappings.size() > 0) {

			for (User_Mapping__c um : fiterMappings) {
				
				if (um.Field_API_Name__c != null) {
					String fieldValue = um.Default_Value__c != null ? um.Default_Value__c : '';
					String fieldApiName = um.Field_API_Name__c.split('::')[0];
					String fieldLabel = um.Field_API_Name__c.split('::')[1];
					String fieldType = um.Field_API_Name__c.split('::')[2];
					String operator = um.Field_API_Name__c.split('::')[3];
					String objectName = um.Field_API_Name__c.split('::')[4];
					
					if (fieldType == 'PICKLIST') {
						
						if (fieldValue.trim() != '') {
							String picklistClause = '';

							for (String value : fieldValue.split(', ')) {
								picklistClause = picklistClause == '' ? operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', value) : picklistClause + (operator == 'not equal to' ? 'AND' : 'OR') + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', value); 
							}
								whereClause =  whereClause + ' AND (' + picklistClause + ')';
						} else {
								whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null');
						}
					} else if (fieldType == 'MULTIPICKLIST') {
						
						if (fieldValue.trim() != '') {
							String joinedValues = fieldValue.replaceAll(', ', '\',\'');
								whereClause = operator == 'equals' ? (whereClause + ' AND ' + fieldApiName + ' IN (\'' + joinedValues + '\')') :  whereClause + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', joinedValues);
						} else {
								whereClause = operator == 'excludes' ? (whereClause + ' AND ' + fieldApiName + ' != null ') : (whereClause + 'AND ' + fieldApiName + ' = null ');
						}
					} else if (fieldType == 'DATE') {
						
						if (fieldValue != null && fieldValue.trim() != '' && fieldValue != 'TODAY') {
							List<String> dateList = fieldValue.split('[./-]');
							Datetime filterDateTime = Datetime.newInstance(Integer.valueOf(dateList[dateFormatList.indexOf('y')]),
																		Integer.valueOf(dateList[dateFormatList.indexOf('m')]),
																		Integer.valueOf(dateList[dateFormatList.indexOf('d')]));
								whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', filterDateTime.format('yyyy-MM-dd'));
						} else if (fieldValue == 'TODAY') {
							whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', fieldValue);
						} else {
								whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null');
						}
					} else if (fieldType == 'DATETIME') {
						
						if (fieldValue != null && fieldValue.trim() != '') {
							List<String> dateList = fieldValue.split('[./-]');
							Datetime filterDate = Datetime.newInstance(Integer.valueOf(dateList[dateFormatList.indexOf('y')]),
																		Integer.valueOf(dateList[dateFormatList.indexOf('m')]),
																		Integer.valueOf(dateList[dateFormatList.indexOf('d')]));
								whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', filterDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\''));
						} else {
								whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null');
						}
					} else if (fieldType == 'BOOLEAN') {
							whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', fieldValue != null ? fieldValue : 'false');
					} else if (fieldType == 'DOUBLE' || fieldType == 'INTEGER' || fieldType == 'CURRENCY') {
							whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', fieldValue != null ? fieldValue : 'null');
					} else if (fieldType == 'REFERENCE') { 
						if (fieldValue == '' || fieldValue == null) {
							whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', fieldValue != '' && fieldValue != null ? fieldValue : 'null');
						} else {
							whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', fieldValue != null ? fieldValue : 'null');
						}
					} else {
							whereClause =  whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', fieldValue != null ? fieldValue : 'null');
					}
				}
			}
		}
		return whereClause;
    }
    
	/**
     * Method to save Inline Edit
     */
    @RemoteAction
    public static String saveInlineEdit(Map<String,Map<String,Object>> recordList, String refTypesMapJson, String isNomination) {
		Map<String,String> success = new Map<String,String>();

		if (checkPermissions()) {

			try {
				if (isNomination == 'false') {
					Map<String, Reference_Note__c> noteMap = new Map<String, Reference_Note__c>();
					List<Reference_Note__c> refNoteList = new List<Reference_Note__c>();
					List<Task> listTask = new List<Task>();
					Map<String, String> refTypeUserMapForRewards = new Map<String, String>();
            		Custom_Settings__c cs = UtilityController.getCustomSettings();
            		Map<String, RefTypeWrapper> refTypesMap = (Map<String, RefTypeWrapper>)JSON.deserialize(refTypesMapJson, Map<String, RefTypeWrapper>.class);
					Map<String, Reference_Basic_Information__c> accountRBImap = new Map<String, Reference_Basic_Information__c>();
					List<Id> refRequestAccountIds =  new List<Id> ();

					for (String recordKey : recordList.keySet()) {
						
						if (recordList.get(recordKey).get('Account__c') != null && recordList.get(recordKey).get('Account__c') != '') {
							refRequestAccountIds.add(String.valueOf(recordList.get(recordKey).get('Account__c')));
						}
					}

					if (refRequestAccountIds != null && refRequestAccountIds.size() != 0) {

						for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountsRBI(refRequestAccountIds)) {
							accountRBImap.put(rbi.Account__r.Id, rbi);
						}
					}
					for (Reference_Note__c note: [SELECT Account_Request__c, Unspecified_Request__c, Note__c, Reference_Request__c 
								FROM Reference_Note__c WHERE(Account_Request__c IN : recordList.keySet() OR Unspecified_Request__c IN : recordList.keySet())]) {
						
						if (note.Account_Request__c != null) {
							noteMap.put(note.Account_Request__c, note);
						} else if (note.Unspecified_Request__c != null) {
							noteMap.put(note.Unspecified_Request__c, note);
						}
					}
					List<Unspecified_Request__c> urUpdateList = new List<Unspecified_Request__c>();
					List<Reference_Request_Account__c> arUpdateList = new List<Reference_Request_Account__c>();
					Map<Id,Unspecified_Request__c> urMap = new Map<Id,Unspecified_Request__c>([SELECT Reference_Request__r.Case__c, Reference_Request__r.Opportunity__r.Name, 
																Reference_Request__r.Opportunity__r.Account.Name, Reference_Request__r.Title__c, LastModifiedDate, 
																Id, Notes__c, Reference_Request__r.Id, Reference_Request__r.Case__r.CaseNumber, CreatedDate, Reference_Request__r.Opportunity__c, CreatedById, Project_Owner__c, Request_Notes__c,
																Requester__r.Name, Deadline__c, Reference_Type_Needed__c, Reference_Type_Needed__r.Name, Project_Owner__r.Name, Unspecified_Request_Status__c 
																FROM Unspecified_Request__c WHERE Id =:recordList.keySet()]);
					Map<Id,Reference_Request_Account__c> arMap = new Map<Id,Reference_Request_Account__c> ([SELECT Reference_Request__r.Opportunity__r.Account.Name, Reference_Request__r.Opportunity__r.Name,
															Reference_Request__r.Case__r.CaseNumber, Reference_Request__r.Title__c, LastModifiedDate, 
															Id, Reference_Request__r.Id, CreatedDate, Reference_Request__r.Opportunity__c, CreatedById, Project_Owner__c, Request_Notes__c,
															Requester__r.Name, Approve_Deny_Notes__c, Account__c ,Account__r.Name, Process__c, Deadline__c, Managed_Request__c, Reference_Owner__c, 
															Project_Owner__r.Name, Reference_Type_Needed__c, Reference_Type_Needed__r.Name, Account_Request_Status__c , 
															(SELECT Contact__c, Contact__r.Phone, Contact__r.Email, Contact__r.Name FROM Reference_Request_Account_Contacts__r)
															FROM Reference_Request_Account__c 
															WHERE Id =:recordList.keySet()]);
					Map<Id,String> arContactMap = new Map<Id,String>();
					
					for (Reference_Request_Account_Contact__c contactRequest : [SELECT Id, Contact__c, Reference_Request_Account__c FROM Reference_Request_Account_Contact__c WHERE Reference_Request_Account__c IN :arMap.keySet()]) {
						arContactMap.put(contactRequest.Reference_Request_Account__c,String.valueOf(contactRequest.Contact__c));
					}
					for (String recordKey : recordList.keySet()) {
						Map<String,Object> record = recordList.get(recordKey);	
						Boolean isUR = String.valueOf(record.get('isUR')) == 'true' ? true : false;
						Unspecified_Request__c ur = new Unspecified_Request__c();
						Reference_Request_Account__c ar = new Reference_Request_Account__c();
						
						if (isUR && record.get('Id') != null && record.get('Id') != '')  {
							ur = String.valueOf(record.get('Request Name')) != '' ? urMap.get(String.valueOf(record.get('Id'))) : urMap.containsKey(String.valueOf(record.get('Id')).remove('@1')) ? urMap.get(String.valueOf(record.get('Id')).remove('@1')) : null;
							Reference_Request_Account__c urNew ;
							
							Reference_Request__c rr = ur.Reference_Request__r;
							
							if (record.get('Request Name') == '') {
								urNew = new Reference_Request_Account__c();
								urNew.Account__c = String.valueOf(record.get('Account__c'));
								urNew.Reference_Request__c = ur.Reference_Request__r.Id;
								urNew.Reference_Type_Needed__c = String.valueOf(record.get('Reference_Type_Needed__c'));
								urNew.Deadline__c = date.valueOf(String.valueOf(record.get('Deadline')).trim());
								urNew.Requester__c = ur.Requester__c;
								urNew.Request_Notes__c = ur.Request_Notes__c;
								urNew.Process__c = String.valueOf(record.get('Process'));
								urNew.Account_Request_Status__c = String.valueOf(record.get('Status'));
								urNew.Project_Owner__c = String.valueOf(record.get('User__c'));
								urNew.Managed_Request__c = true; 
								WithoutSharingHelperController.upsertRRA(urNew);
								ur.Specified_Account__c = urNew.Id;
								ConstantsController.shouldUnspecifiedStatusChange = true;
								ur.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
								update ur;
								// Create RRAC Record
								Reference_Request_Account_Contact__c refReqAccContactObject = new Reference_Request_Account_Contact__c();

								if (record.get('Contact__c') != null && String.valueOf(record.get('Contact__c')) != '') {
									refReqAccContactObject.Reference_Request_Account__c = urNew.Id;
									refReqAccContactObject.Referenceability_Type__c = urNew.Reference_Type_Needed__c;
									refReqAccContactObject.Deadline__c = urNew.Deadline__c;
									refReqAccContactObject.Request_notes__c = urNew.Request_Notes__c;
									refReqAccContactObject.Contact_Request_Status__c = ConstantsController.IN_PROGRESS;
									refReqAccContactObject.Project_Owner__c = urNew.Project_Owner__c;
									refReqAccContactObject.Contact__c = String.valueOf(record.get('Contact__c'));
									WithoutSharingHelperController.upsertRRAC(refReqAccContactObject);
								}
							} else {
								if (ur.Reference_Request__r.Title__c != String.valueOf(record.get('Subject'))) {
									ur.Reference_Request__r.Title__c = String.valueOf(record.get('Subject'));
									rr.Title__c = String.valueOf(record.get('Subject'));
								}
								ur.Deadline__c = date.valueOf(String.valueOf(record.get('Deadline')));
								ur.Reference_Type_Needed__c = String.valueOf(record.get('Reference_Type_Needed__c'));
								
								if (ur.Unspecified_Request_Status__c != String.valueOf(record.get('Status')) && String.valueOf(record.get('Status')) != 'Account Specified') {
									ur.Unspecified_Request_Status__c = String.valueOf(record.get('Status'));
								}

								if ((ur.Project_Owner__c == null && record.get('User__c') != null )|| (record.get('User__c') != null && String.valueOf(ur.Project_Owner__c) != String.valueOf(record.get('User__c')).trim())) {
									ur.Project_Owner__c = String.valueOf(record.get('User__c')).trim();
								}

								if (record.get('Mail') != null && String.valueOf(record.get('Mail')) != 'null' && String.valueOf(record.get('Mail')) != '') {
									Map<String,String> email = (Map<String,String>)JSON.deserialize(String.valueOf(record.get('Mail')), Map<String,String>.class);
									ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST = email.get('Subject') ;
									ur.Notes__c = email.get('Notes');
									Boolean writetoNote = email.get('WriteToNote') == 'true' ? true : false;
									ConstantsController.isNotificationSend = true;
									
									if (writetoNote && ur.Notes__c != null && ur.Notes__c != '') {
								
										if (noteMap != null && noteMap.containsKey(ur.Id)) {
											Reference_Note__c tempNote = noteMap.get(ur.Id);
											tempNote.Note__c = ur.Notes__c;
											refNoteList.add(tempNote);
										} else {
											refNoteList.add(new Reference_Note__c(Unspecified_Request__c = ur.Id, Note_Date__c = system.today(), 
											Note__c = ur.Notes__c, Reference_Request__c = ur.Reference_Request__c));
										}
									}
								} else {
									ConstantsController.isNotificationSend = false;
								}
								Database.SaveResult result = Database.update(rr, true);
								urUpdateList.add(ur);
							}
						} else if (!isUR && record.get('Id') != null && String.valueOf(record.get('Id')) != '')  {
							
							ar = record.get('Request Name') != null && String.valueOf(record.get('Request Name')) != '' ? arMap.get(String.valueOf(record.get('Id'))) : arMap.containsKey(String.valueOf(record.get('Id')).remove('@1')) ? arMap.get(String.valueOf(record.get('Id')).remove('@1')) : null;
							
							if (String.valueOf(record.get('Request Name')) == '') {
								Reference_Request_Account__c arNew = new Reference_Request_Account__c();
								arNew.Account__c = String.valueOf(record.get('Account__c'));
								arNew.Reference_Request__c = ar.Reference_Request__r.Id;
								arNew.Reference_Type_Needed__c = String.valueOf(record.get('Reference_Type_Needed__c'));
								arNew.Deadline__c = date.valueOf(String.valueOf(record.get('Deadline')).trim());
								arNew.Requester__c = ar.Requester__c;
								arNew.Request_Notes__c = ar.Request_Notes__c;
								arNew.Process__c = String.valueOf(record.get('Process'));
								arNew.Account_Request_Status__c = String.valueOf(record.get('Status'));
								arNew.Project_Owner__c = String.valueOf(record.get('User__c'));
								arNew.Managed_Request__c = true;
								WithoutSharingHelperController.upsertRRA(arNew);
								
								// Create RRAC Record
								Reference_Request_Account_Contact__c refReqAccContactObject = new Reference_Request_Account_Contact__c();
								
								if (record.get('Contact__c') != null && String.valueOf(record.get('Contact__c')) != '') {
									refReqAccContactObject.Reference_Request_Account__c = arNew.Id;
									refReqAccContactObject.Referenceability_Type__c = arNew.Reference_Type_Needed__c;
									refReqAccContactObject.Deadline__c = arNew.Deadline__c;
									refReqAccContactObject.Request_notes__c = arNew.Request_Notes__c;
									refReqAccContactObject.Contact_Request_Status__c = ConstantsController.IN_PROGRESS;
									refReqAccContactObject.Project_Owner__c = arNew.Project_Owner__c;
									refReqAccContactObject.Contact__c = String.valueOf(record.get('Contact__c'));
									WithoutSharingHelperController.upsertRRAC(refReqAccContactObject);
								}
							} else {
								
								if (ar.Reference_Request__r.Title__c != String.valueOf(record.get('Subject')).trim()) {
									Reference_Request__c rr = ar.Reference_Request__r;
									ar.Reference_Request__r.Title__c = String.valueOf(record.get('Subject')).trim();
									rr.Title__c = String.valueOf(record.get('Subject')).trim();
									Database.SaveResult result = Database.update(rr, true);
								}
								if (ar.Deadline__c != Date.valueOf(String.valueOf(record.get('Deadline')).trim())) {
									ar.Deadline__c = date.valueOf(String.valueOf(record.get('Deadline')));
									ar.Process__c = ConstantsController.MANAGED;
									ar.Managed_Request__c = true;
								}

								if (ar.Reference_Type_Needed__c != String.valueOf(record.get('Reference_Type_Needed__c')).trim()) {
									ar.Reference_Type_Needed__c = String.valueOf(record.get('Reference_Type_Needed__c'));
									ar.Process__c = ConstantsController.MANAGED;
									ar.Managed_Request__c = true;
								}
								
								if (ar.Account_Request_Status__c != String.valueOf(record.get('Status')).trim()) {
									ar.Account_Request_Status__c = String.valueOf(record.get('Status'));
									ar.Process__c = ConstantsController.MANAGED;
									ar.Managed_Request__c = true;
								}
								
								
								if (record.get('Mail') != null && String.valueOf(record.get('Mail')) != 'null' && String.valueOf(record.get('Mail')) != '') {
									
									Map<String,String> email = (Map<String,String>)JSON.deserialize(String.valueOf(record.get('Mail')), Map<String,String>.class);
									
									ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST = email.get('Subject') ;
									ar.Approve_Deny_Notes__c = email.get('Notes');
									Boolean writetoNote = email.get('WriteToNote') == 'true' ? true : false;
									ConstantsController.isNotificationSend = true;

									if (writetoNote && ar.Approve_Deny_Notes__c != null && ar.Approve_Deny_Notes__c != '') {
							
										if (noteMap != null && noteMap.containsKey(ar.Id)) {
											Reference_Note__c tempNote = noteMap.get(ar.Id);
											tempNote.Note__c = ar.Approve_Deny_Notes__c;
											refNoteList.add(tempNote);
										} else {
											refNoteList.add(new Reference_Note__c(Account_Request__c = ar.Id, Note_Date__c = system.today(), 
											Note__c = ar.Approve_Deny_Notes__c, Reference_Request__c = ar.Reference_Request__c));
										}
									}
								} else {
									ConstantsController.isNotificationSend = false;
								}
								
								if (ar.Process__c != String.valueOf(record.get('Process')).trim() && String.valueOf(record.get('Process')).trim() == ConstantsController.REP2REP) {
									ar.Managed_Request__c = false;
									ConstantsController.isNotificationSend = true;

									if (accountRBImap.containsKey(String.valueOf(record.get('Account__c')))) {
										Map<String,String> email = (record.get('Mail') != null && String.valueOf(record.get('Mail')) != 'null' && String.valueOf(record.get('Mail')) != '') ? 
																	(Map<String,String>)JSON.deserialize(String.valueOf(record.get('Mail')), Map<String,String>.class)
																	: null;
										listTask.add(MailChatterController.prepareTask((accountRBImap.get(String.valueOf(record.get('Account__c'))).Reference_Owner__c == null
															? accountRBImap.get(String.valueOf(record.get('Account__c'))).Account__r.OwnerId
															: accountRBImap.get(String.valueOf(record.get('Account__c'))).Reference_Owner__c),
														String.valueOf(record.get('Account__c')), ar.Deadline__c,
														REFERENCE_REQUEST_TASK_SUBJECT, SPECIFIED_REQUEST_MESSAGE
															+ MailChatterController.prepareChatterEmailMessage(ar.Deadline__c,
																String.valueOf(record.get('Account Requested')), String.valueOf(record.get('Type')),
																UtilityController.checkValueOfString(email != null && email.containsKey('Notes') && email.get('Notes') != null ? String.valueOf(email.get('Notes')) : '')
															+ APPROVE_DECLINE_TITLE + ': ' + (APPROVE_DECLINE_LINK_URL + String.valueOf(record.get('Account__c')))),''));
									}
								}

								if (ar.Process__c != String.valueOf(record.get('Process')).trim() && String.valueOf(record.get('Process')).trim() == ConstantsController.MANAGED
										&& ar.Project_Owner__c == String.valueOf(record.get('User__c')).trim()) {
									ar.Process__c = ConstantsController.MANAGED;
                            		ar.Managed_Request__c = true;
									ar.Project_Owner__c = UserInfo.getUserId();
									ConstantsController.isNotificationSend = true;
								} else if (ar.Process__c != String.valueOf(record.get('Process')).trim() && String.valueOf(record.get('Process')).trim() == ConstantsController.MANAGED
										&& ar.Project_Owner__c != String.valueOf(record.get('User__c')).trim()) {
									ar.Process__c = ConstantsController.MANAGED;
                            		ar.Managed_Request__c = true;
									ConstantsController.isNotificationSend = true;
									ar.Project_Owner__c = String.valueOf(record.get('User__c')).trim();
								} else if (ar.Process__c != String.valueOf(record.get('Process')).trim() && String.valueOf(record.get('Process')).trim() == ConstantsController.REP2REP) {
									ar.Process__c = ConstantsController.REP2REP;
									ar.Project_Owner__c = accountRBImap.get(String.valueOf(ar.get('Account__c'))).Reference_Owner__c == null
													? accountRBImap.get(String.valueOf(ar.get('Account__c'))).Account__r.OwnerId
																: accountRBImap.get(String.valueOf(ar.get('Account__c'))).Reference_Owner__c;
								} else if ((ar.Project_Owner__c == null && record.get('User__c') != null ) || (record.get('User__c') != null && String.valueOf(ar.Project_Owner__c) != String.valueOf(record.get('User__c')).trim())) {
									ar.Project_Owner__c = String.valueOf(record.get('User__c')).trim();
									ar.Process__c = ConstantsController.MANAGED;
                            		ar.Managed_Request__c = true;
								}
								
								if (record.get('Status') == ConstantsController.COMPLETED) {
									refTypeUserMapForRewards.put(String.valueOf(record.get('Reference_Type_Needed__c')), record.get('User__c') != null && record.get('User__c') != ''
																								? String.valueOf(record.get('User__c'))
																								: accountRBImap.get(String.valueOf(record.get('Account__c'))).Account__r.OwnerId);
								}
								
								if (record.get('Contact__c') != null && String.valueOf(record.get('Contact__c')) != '' && (!arContactMap.containsKey(ar.Id) || arContactMap.get(ar.Id) != record.get('Contact__c'))) {
									Reference_Request_Account_Contact__c refReqAccContactObject = new Reference_Request_Account_Contact__c();
									refReqAccContactObject.Reference_Request_Account__c = ar.Id;
									refReqAccContactObject.Referenceability_Type__c = ar.Reference_Type_Needed__c;
									refReqAccContactObject.Deadline__c = ar.Deadline__c;
									refReqAccContactObject.Request_notes__c = ar.Request_Notes__c;
									refReqAccContactObject.Contact_Request_Status__c = ar.Account_Request_Status__c;
									refReqAccContactObject.Project_Owner__c = ar.Project_Owner__c;
									refReqAccContactObject.Contact__c = String.valueOf(record.get('Contact__c'));
									WithoutSharingHelperController.upsertRRAC(refReqAccContactObject);
								}
								arUpdateList.add(ar);
							} 
						}
					}	
					if (listTask.size() > 0) {
						listTask = WithoutSharingHelperController.insertTask(listTask);
					}
					
					for (Reference_Request_Account__c rra : arUpdateList) {

						for (Task lstTask : listTask) {
							
							if (rra.Account__c == lstTask.WhatId) {
								rra.Task_ID__c = lstTask.Id;
							}
						}
					}
					
					if (refTypeUserMapForRewards.size() > 0 && !RefEdgeEditionFeatures.isBasic && cs.Auto_Assign_Sales_Rewards__c
							&& cs.Enable_Sales_Rewards_Notification__c) {
						List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
						Set<Id> ownerIds = new Set<Id>();
						
						
						for (String refTypeId : refTypeUserMapForRewards.keySet()) {

							if (refTypesMap != null && refTypesMap.containsKey(refTypeId.trim())) {
								rewardsToBeInsert.add(new Reward__c(Amount__c = refTypesMap.get(refTypeId).salesPoints,
														Referenceability_Type__c = refTypeId, Transaction__c = ConstantsController.ISSUE,
														RewardDate__c = Date.Today(), User__c = refTypeUserMapForRewards.get(refTypeId)));
								ownerIds.add(refTypeUserMapForRewards.get(refTypeId));
							}
						}

						if (rewardsToBeInsert.size() > 0) {
							UtilityController.isUserProfileExist(ownerIds);
							WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
						}
					}

					
					if (urUpdateList.size() > 0) {
						WithoutSharingHelperController.updateUnspecified(urUpdateList);
					}
					
					if (arUpdateList.size() > 0) {
						WithoutSharingHelperController.updateRRA(arUpdateList);
					}
					
					if (refNoteList.size() > 0) {
						refNoteList = WithoutSharingHelperController.upsertNotes(refNoteList);
					}
					success.put('success', 'true');
				}
			} catch (Exception ex) {
				success.put('success', 'false');
				success.put('message', CRUDAndFLSCheckController.getCleanSystemErrorMsg(ex.getMessage()));
			}
		} else {
			success.put('success', 'true');
			List<Apexpages.Message> msgs = ApexPages.getMessages();
			String msg = msgs.size() > 0 ? msgs[0].getDetail() : 'Insufficient Access Rights';
			success.put('message', msg);
		}
		return JSON.serialize(success);									
	}

    /**
     * Method to save selected Columns
     */
    @RemoteAction
    public static String saveSelectedColumns(String fieldListString , String isNomination, String externalCall) {
		Savepoint sp = Database.setSavepoint();
		try {
			List<FieldWrapper> fieldList = (List<FieldWrapper>)JSON.deserialize(fieldListString, (List<FieldWrapper>.class)); 
			String proces = (isNomination == 'true') ? ConstantsController.FIELD_SELECTOR_NONIMATION_PROCESS : ConstantsController.FIELD_SELECTOR_REQUEST_PROCESS;
			List<User_Mapping__c> UMsToUpsert = new List<User_Mapping__c>();
			Integer orderVisible = 1;
			Integer orderNotVisible = 1;
			for (FieldWrapper col : fieldList) {
							
				if (col.visible) {
					
					if (col.userMapping.Id == null) {
						UMsToUpsert.add(new User_Mapping__c(Visible__c = true,
															Default_Value__c = col.fieldType,
															Field_API_Name__c = col.fieldName,
															User__c = UserInfo.getUserId(),
															Label__c = col.fieldLabel,
															Order__c = orderVisible++,
															Process__c = proces));
					} else {
						col.userMapping.Visible__c = true;
						col.userMapping.Order__c = orderVisible++;
						UMsToUpsert.add(col.userMapping);
					}
				} else {
					
					if (col.userMapping.Id != null) {
						col.userMapping.Visible__c = false;
						col.userMapping.Order__c = orderNotVisible++;
						UMsToUpsert.add(col.userMapping);
					} else {
						UMsToUpsert.add(new User_Mapping__c(Visible__c = false,
															Default_Value__c = col.fieldType,
															Field_API_Name__c = col.fieldName,
															User__c = UserInfo.getUserId(),
															Order__c = orderNotVisible++,
															Label__c = col.fieldLabel,
															Process__c = proces));
					}
				}	
					
			}
			if (orderVisible == 1) {

				for (User_Mapping__c um : UMsToUpsert) {
					um.Visible__c = true;
				}
				
			}
			
			if (UMsToUpsert != null && UMsToUpsert.size() > 0) {
				upsert UMsToUpsert;
			} 
			
			if (externalCall == 'true') {
				return getFields();
			} else {
				return null;
			}
		} catch (Exception ex) {
			Database.rollback(sp);
			return getFields();
		}
			
    }
    
    /**
     * Method to check Permissions
     */
    @RemoteAction
    public static Boolean checkPermissions() {
		Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		fieldMap.put(UtilityController.appNamespace() + 'User_Mapping__c', new Set<String> { 
											UtilityController.appNamespace() + 'Label__c',
											UtilityController.appNamespace() + 'From_Mapping__c',
											UtilityController.appNamespace() + 'Process__c',
											UtilityController.appNamespace() + 'User__c',
											UtilityController.appNamespace() + 'Field_API_Name__c',
											UtilityController.appNamespace() + 'Default_Value__c',
											UtilityController.appNamespace() + 'Order__c' });
		return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);

    }
    
    /**
     * Method to get Date Format
     */
    @RemoteAction
    public static String getDateFormat() {   
		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
		return dateFormat;
    }
    
    /**
     * Method to create new project
     */
    @RemoteAction
    public static String createProject(String projectString) {
		Map<String,String> returnString = new Map<String,String>();
		
		if (checkPermissions()) {
			Savepoint sp = Database.setSavepoint();
			
			try {
				Custom_Settings__c cs = UtilityController.getCustomSettings();
				Map<String,String> projectDetail = (Map<String,String>)JSON.deserialize(projectString, Map<String,String>.class);
				List<Reference_Basic_Information__c> refList = new List<Reference_Basic_Information__c>();
				Reference_Basic_Information__c accountProfile;
				Reference_Basic_Information__c contactProfile;
				Reference_Request__c refReqObject = new Reference_Request__c();
				Reference_Request_Account__c refReqAccountObject = new Reference_Request_Account__c();
				Reference_Request_Account_Contact__c refReqAccContactObject = new Reference_Request_Account_Contact__c();
				
				if (projectDetail.get('refType') == null || projectDetail.get('deadline') == null || 
									(projectDetail.get('oppId') == null && projectDetail.get('oppRequired') == 'true' && projectDetail.get('type') == 'Member') || 
									(projectDetail.get('caseId') == null && projectDetail.get('caseRequired') == 'true' && projectDetail.get('type') == 'Member') || 
									(projectDetail.get('subject') == null && projectDetail.get('subjectRequired') == 'true') || 
									(projectDetail.get('note') == null && projectDetail.get('noteRequired') == 'true') || 
									(((projectDetail.get('accountId') == null) && (projectDetail.get('accountName') == null || projectDetail.get('accountName') == '')) && projectDetail.get('accountRequired') == 'true') || 
									(projectDetail.get('contactId') == null && projectDetail.get('contactRequired') == 'true')) {
					returnString.put('success','false');
					returnString.put('message',System.Label.Complete_the_required_fields);
				}
				
				if (projectDetail.get('accountId') != null && projectDetail.get('accountId').trim() != '') {
					refList = getRefProfile(projectDetail.get('accountId'),true);
						
					if(refList.size() > 0) {
						if (refList.size() > 1) {
							returnString.put('success','false');
							returnString.put('message',system.label.Multiple_items_found);
						} else {
								accountProfile = refList.get(0);
						}
					}	
				}
				
				if (projectDetail.get('contactId') != null && projectDetail.get('contactId').trim() != '') {
					refList = getRefProfile(projectDetail.get('contactId'),false);
					if(refList.size() > 0) {
						if (refList.size() > 1) {
							returnString.put('success','false');
							returnString.put('message',system.label.Multiple_items_found);
						} else {
							contactProfile = refList.get(0);
						}
					}
				}
				
				if (contactProfile != null && contactProfile.Contact__c != null
						&& accountProfile != null && !(accountProfile.Reference_Program_Candidate__c)) {
					
					if (contactProfile.Reference_Program_Candidate__c) {
						returnString.put('success','false');
						returnString.put('message',ConstantsController.CANDIDATE_CHECKED_CONTACT);
					}
				}

				if (contactProfile != null && contactProfile.Contact__c != null
							&& accountProfile != null && (accountProfile.Reference_Program_Candidate__c)) {
					
					if (!contactProfile.Reference_Program_Candidate__c) {
						returnString.put('success','false');
						returnString.put('message',system.Label.CANDIDATE_NOT_CHECKED_CONTACT);
					}
				}
				// Create RR Record
				if (projectDetail.get('type') == 'Candidate') {
					refReqObject.Opportunity__c = null;
					refReqObject.Case__c = null;
				} else {
					refReqObject.Opportunity__c = projectDetail.get('oppId') == '' ? null : projectDetail.get('oppId');
					refReqObject.Case__c = projectDetail.get('caseId') == '' ? null : projectDetail.get('caseId');
				}
				refReqObject.Reference_Request_Status__c = ConstantsController.IN_PROGRESS;
				refReqObject.Requester__c = UserInfo.getUserId();
				refReqObject.Title__c = projectDetail.get('subject') == null ? '' : projectDetail.get('subject');
				
				if (projectDetail.get('type') == 'Member') {
					refReqObject.Project_Type__c = 'Member';
				} else {
					refReqObject.Project_Type__c = 'Candidate';
				}
				insert refReqObject;
				
				if (accountProfile != null && projectDetail.get('accountId') != null && projectDetail.get('accountId').trim() != '') {
						
					if (!accountProfile.Reference_Program_Candidate__c) {
						
						// Check RBI Records Created or not
						if (contactProfile != null && contactProfile.Contact__c != null) {
							List<Reference_Basic_Information__c> updateList = new List<Reference_Basic_Information__c>();
							UtilityController.checkRBI(accountProfile.Account__c, contactProfile.Contact__c, 
														contactProfile.Contact__r.AccountId, true);
							
							if (contactProfile.Referenceability_Status__c == 'Inactive' && contactProfile.Referenceability_Status__c != cs.Default_Referenceablity_Status__c) {
								contactProfile.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
								updateList.add(contactProfile);
							}
							if (accountProfile.Referenceability_Status__c == 'Inactive' && accountProfile.Referenceability_Status__c != cs.Default_Referenceablity_Status__c) {
								accountProfile.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
								updateList.add(accountProfile);
							}
							WithoutSharingHelperController.upsertRBI(updateList);
						} else if(contactProfile == null && projectDetail.get('contactId') != null && projectDetail.get('contactId').trim() != '') {
							Reference_Basic_Information__c rbi = new Reference_Basic_Information__c();
	                		rbi.Contact__c = projectDetail.get('contactId').trim();
	                		rbi.Account__c = projectDetail.get('accountId').trim();
	                		rbi.Is_Referenceable__c = true;
	                		rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
	                		WithoutSharingHelperController.upsertRBI(new List<Reference_Basic_Information__c> {rbi});
	                	}
					} else {
	                	if(projectDetail.get('contactId') != null && projectDetail.get('contactId').trim() != ''  
	                		&& contactProfile == null) {
	                		
	                		Reference_Basic_Information__c rbi = new Reference_Basic_Information__c();
	                		rbi.Contact__c = projectDetail.get('contactId').trim();
	                		rbi.Account__c = projectDetail.get('accountId').trim();
	                		rbi.Reference_Program_Candidate__c = true;
	                		WithoutSharingHelperController.upsertRBI(new List<Reference_Basic_Information__c> {rbi});
	                	}
	                }
                    
					refReqAccountObject.Account__c = accountProfile.Account__c;
					refReqAccountObject.Reference_Request__c = refReqObject.Id;
					refReqAccountObject.Reference_Type_Needed__c = projectDetail.get('refType');
					refReqAccountObject.Deadline__c = date.valueOf(projectDetail.get('deadline'));
					refReqAccountObject.Requester__c = UserInfo.getUserId();
					refReqAccountObject.Project_Owner__c = UserInfo.getUserId();
					refReqAccountObject.Request_notes__c = projectDetail.get('note');
					
					if (accountProfile.Reference_Owner__c != null) {
						refReqAccountObject.Reference_Owner__c = accountProfile.Reference_Owner__c;
					} else {
						refReqAccountObject.Reference_Owner__c = accountProfile.Managed_Reference_Account__c
																	? null : accountProfile.Account__r.OwnerId;
					}
					refReqAccountObject.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
					refReqAccountObject.Managed_Request__c = true;
					refReqAccountObject.Process__c = ConstantsController.MANAGED;
					WithoutSharingHelperController.upsertRRA(refReqAccountObject);
					// Create RRAC Record
					if(projectDetail.get('contactId') != null && projectDetail.get('contactId').trim() != '') {
						refReqAccContactObject.Reference_Request_Account__c = refReqAccountObject.Id;
						refReqAccContactObject.Referenceability_Type__c = refReqAccountObject.Reference_Type_Needed__c;
						refReqAccContactObject.Deadline__c = refReqAccountObject.Deadline__c;
						refReqAccContactObject.Request_notes__c = refReqAccountObject.Request_Notes__c;
						refReqAccContactObject.Contact_Request_Status__c = ConstantsController.IN_PROGRESS;
						refReqAccContactObject.Project_Owner__c = UserInfo.getUserId();
						refReqAccContactObject.Contact__c = projectDetail.get('contactId').trim(); 
						WithoutSharingHelperController.upsertRRAC(refReqAccContactObject);
					}
					returnString.put('success','true');
					returnString.put('message',JSON.serialize(refReqAccountObject));
				} else {
					Unspecified_Request__c unspec = new Unspecified_Request__c(Reference_Type_Needed__c = projectDetail.get('refType'),
														Deadline__c = date.valueOf(projectDetail.get('deadline')),
														Reference_Request__c = refReqObject.Id,
														Requester__c = UserInfo.getUserId(),
														Project_Owner__c = UserInfo.getUserId(),
														Request_Notes__c = projectDetail.get('note'),
														Unspecified_Request_Status__c = ConstantsController.NOT_STARTED);
					insert unspec;
					returnString.put('success','true');
					returnString.put('message',JSON.serialize(unspec));
				}
			}  catch (Exception e) {
				Database.rollback(sp);
				returnString.put('success','false');
				returnString.put('message','Error: ' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage()));
			}  
        } else {
			returnString.put('success','false');
			List<Apexpages.Message> msgs = ApexPages.getMessages();
			String msg = msgs.size() > 0 ? msgs[0].getDetail() : 'Insufficient Access Rights';
            returnString.put('message',msg);
	    }
        return JSON.serialize(returnString);
    }
    
	public static List<Reference_Basic_Information__c> getRefProfile(String Id, Boolean isAccount) {
		List<Reference_Basic_Information__c> rbiList ;
		String soqlQuery = '';
		
		if (isAccount) {
			soqlQuery = 'SELECT Account__r.Name, Account__r.OwnerId, Name, Id, Account__c, Reference_Owner__c, '
							+ 'Managed_Reference_Account__c, Reference_Program_Candidate__c, Is_Referenceable__c, '
							+ 'Referenceability_Status__c '
							+ 'FROM Reference_Basic_Information__c '
							+ 'WHERE Contact__c = null '
							+ 'AND Account__c = \'' + Id
							+ '\' LIMIT 10'; 
		} else {
			soqlQuery = 'SELECT Account__r.Name, Account__r.OwnerId,Contact__c, Name, Id, Account__c, Reference_Owner__c, '
            					+ 'Managed_Reference_Account__c,Contact__r.AccountId, Reference_Program_Candidate__c, Is_Referenceable__c, '
            					+ 'Referenceability_Status__c '
            					+ 'FROM Reference_Basic_Information__c '
            					+ 'WHERE Contact__c = \'' + Id
            					+ '\' LIMIT 10'; 
		}
        rbiList = WithoutSharingHelperController.getRBI(soqlQuery);
        return rbiList;
    }
    /**
     * Wrapper for Fields
     */
    public class FieldWrapper {
    		public String fieldName;
    		public String fieldLabel;
    		public Boolean visible;
    		public User_Mapping__c userMapping;
    		public String proces;
    		public String fieldType;
			public FieldWrapper (String fieldName,String fieldLabel, Boolean visible, String proces, String fieldType, User_Mapping__c userMapping) {
    			this.fieldName = fieldName;
    			this.visible = visible;
    			this.fieldLabel = fieldLabel;
    			this.proces = proces;
    			this.userMapping = userMapping;
				this.fieldType = fieldType;
    		}
    }

	public class RefTypeWrapper {
        public String refTypeId { get; set; }
        public String refTypeName { get; set; }
        public Decimal salesPoints { get; set; }
        public String refNo { get; set; }
        public Boolean isForProject { get; set; }
        public Boolean isForRequest { get; set; }
        public Decimal maxAccPerRequest { get; set; }
        public Decimal minLeadTimePerRequest { get; set; }

        public RefTypeWrapper(Referenceability_Type__c refType) {
            this.refTypeId = refType.Id;
            this.refTypeName = refType.Name;
            this.isForProject = refType.Project_type__c;
            this.isForRequest = refType.Request_type__c;
            this.salesPoints = refType.Sales_Point__c != null ? refType.Sales_Point__c : 0;
            this.refNo = refType.Referenceability_no__c != null ? String.valueOf(refType.Referenceability_no__c) : '';
            this.maxAccPerRequest = refType.Max_accounts_per_request_type__c != null ? refType.Max_accounts_per_request_type__c : 0;
            this.minLeadTimePerRequest = refType.Min_lead_time_per_request_type__c != null ? refType.Min_lead_time_per_request_type__c : 0;
        }
    }
}