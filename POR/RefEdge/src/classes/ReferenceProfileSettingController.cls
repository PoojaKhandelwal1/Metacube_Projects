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
 * Page: ReferenceProfileSettingPage
 * Description: controller for configuring the reference profile creation form
 * Author: Gaurav Saini (6 Oct, 2017)
 */
public with sharing class ReferenceProfileSettingController extends RefEdgeEditionFeatures {
    
    private Custom_Settings__c cs = UtilityController.getCustomSettings();
    public String customSettingId { get; set; }
    public Boolean isSLDS { get; set; }
    
    public ReferenceProfileSettingController() {
    	customSettingId = cs.Id;
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Boolean isDeletePermission = false;
    	Boolean isUpsertPermission = false;
    	
    	fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String> { 'Name',
            										UtilityController.appNamespace() + 'Referenceability_Type__c',
            										UtilityController.appNamespace() + 'Visible__c',
            										UtilityController.appNamespace() + 'Required__c',
            										UtilityController.appNamespace() + 'Object__c'});
    	isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Data_Mapping__c'});
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);  
        return (isUpsertPermission && isDeletePermission);
    }
    
    /**
     * method to get permissions message
     */
    @RemoteAction
    public static String getPermissionsMessage() {
    	checkPermissions();
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * method to get the data mappings
     * author: Gaurav Saini (6 Oct, 2017)
     */
    @RemoteAction
    public static String getDataMappings() {
    	List<DataMappingWrapper> dataMappings = new List<DataMappingWrapper>();
    	List<Referenceability_Type__c> refTypes = new List<Referenceability_Type__c>();
        Set<Id> refIds = new Set<Id>();
        // re #1114 - Getting only those Referenceability from Data Mapping having visible true in Referenceability Type.
        refTypes = [SELECT Name, Id, Visible__c FROM Referenceability_Type__c WHERE Visible__c = true AND Sales_Reward__c = false  
        													ORDER BY Name LIMIT :limits.getLimitQueryRows()];
        							
        for (Referenceability_Type__c rt : refTypes) {
			refIds.add(rt.Id);
		}
		 
    	for (Data_Mapping__c dm : [SELECT Name, Order__c, Referenceability_Type__c, Referenceability_Type__r.Name,
    								Filter__c, Filter__r.Name, Id, Visible__c, Field_API_Name__c, Required__c
    								FROM Data_Mapping__c
    								WHERE Object__c = :ConstantsController.REFERENCE_PROFILE_FORM AND (Referenceability_Type__c IN :refIds OR Filter__c != NULL) 
    								ORDER BY Order__c]) {
            dataMappings.add(new DataMappingWrapper(dm));
        }  
        return JSON.serialize(dataMappings);
    }
    
    /**
     * method to get the ref type data mappings which are not created already
     * author: Gaurav Saini (6 Oct, 2017)
     */
    @RemoteAction
    public static String getRefTypeMappings(String existingRefTypeMappingIdsJSON) {
    	Set<String> existingRefTypeMappingIds
    				= (Set<String>)JSON.deserialize(existingRefTypeMappingIdsJSON, Set<String>.class);
    	List<DataMappingWrapper> refTypeMappings = new List<DataMappingWrapper>();
    	
    	for (Referenceability_Type__c rt : [SELECT Name, Id, Visible__c
    										FROM Referenceability_Type__c
    										WHERE Visible__c = true AND Sales_Reward__c = false
    										ORDER BY Name
    										LIMIT :limits.getLimitQueryRows()]) {
            
            if (!existingRefTypeMappingIds.contains(rt.Id)) {
	            refTypeMappings.add(new DataMappingWrapper(new Data_Mapping__c(Name = rt.Name,
															Referenceability_Type__c = rt.Id,
															Visible__c = false,
															Required__c = false,
															Object__c = ConstantsController.REFERENCE_PROFILE_FORM)));
            }
        }
        return JSON.serialize(refTypeMappings);
    }
    
    /**
     * method to get the filter data mappings
     * author: Gaurav Saini (6 Oct, 2017)
     */
    @RemoteAction
    public static String getFilterMappings(String existingFilterMappingIdsJSON) {
    	Set<String> existingFilterMappingIds
    				= (Set<String>)JSON.deserialize(existingFilterMappingIdsJSON, Set<String>.class);
    	List<DataMappingWrapper> filterMappings = new List<DataMappingWrapper>();
    	
    	for (Label__c lb : [SELECT Name, Id, Visible__c, Required__c,
							(SELECT Id, Name FROM Attributes_Labels__r)
							FROM Label__c ORDER BY Name
							LIMIT :limits.getLimitQueryRows()]) {
            
            if (lb.Attributes_Labels__r.size() > 0 && !existingFilterMappingIds.contains(lb.Id)) {
	            filterMappings.add(new DataMappingWrapper(new Data_Mapping__c(Name = lb.Name,
	            											Filter__c = lb.Id,
	            											Visible__c = false,
	            											Required__c = false,
	            											Object__c = ConstantsController.REFERENCE_PROFILE_FORM)));
            }
        }
        return JSON.serialize(filterMappings);
    }
    
    /**
     * method to get the section and page headers
     * author: Gaurav Saini (6 Oct, 2017)
     */
    @RemoteAction
    public static String getFormHeaders() {
    	Map<String, DataMappingWrapper> dataMappingWrapperMap = new Map<String, DataMappingWrapper>();
    	List<String> headerList = new List<String>();
        Map<String, String> headerListMap = new Map<String, String>(); 
        headerList.add(ConstantsController.HEADER);
        headerListMap.put(ConstantsController.HEADER, System.Label.Section_1_Header);
        headerList.add(ConstantsController.SUBHEADER);
        headerListMap.put(ConstantsController.SUBHEADER, System.Label.Section_2_Sub_Header);
        headerList.add(ConstantsController.ATTRIBUTES);
        headerListMap.put(ConstantsController.ATTRIBUTES, System.Label.Section_3_Attributes);
        headerList.add(ConstantsController.REFTYPES);
        headerListMap.put(ConstantsController.REFTYPES, System.Label.Section_5_Reference_Activities.replace('5', '4'));
        headerList.add(ConstantsController.FREEFROMTEXT);
        headerListMap.put(ConstantsController.FREEFROMTEXT, System.Label.Section_6_Free_Form_Text.replace('6', '5'));
    	
        for (integer i = 0; i < HeaderList.size(); i++) {
            dataMappingWrapperMap.put(headerList.get(i),
            							new DataMappingWrapper(new Data_Mapping__c(Name = headerList.get(i),
            													Order__c = i + 1,
            													Object__c = ConstantsController.REFERENCE_PROFILE_FORM)));
        }
        
        for (Data_Mapping__c field : [SELECT Name, Order__c, Referenceability_Type__c, Referenceability_Type__r.Name,
    									Filter__c, Filter__r.Name, Id, Visible__c, Field_API_Name__c, Required__c
        								FROM Data_Mapping__c
        								WHERE Object__c = :ConstantsController.REFERENCE_PROFILE_FORM]) {
            
            if (dataMappingWrapperMap.containsKey(field.Name)) {
                dataMappingWrapperMap.put(field.Name, new DataMappingWrapper(field));
            }
		}
        return JSON.serialize(dataMappingWrapperMap) + '@@@' + JSON.serialize(headerListMap);
    }
    
    /**
     * method to save the changes made to the setting form
     * author: Gaurav Saini (6 Oct, 2017)
     */
    @RemoteAction
    public static String saveForm(String upsertDataMappingsJSON, String deleteDataMappingsJSON) {
    	
    	if (checkPermissions()) {
    		Savepoint sp = Database.setSavepoint();
    		
    		try {
    			ConstantsController.shouldDataMappingProcessed = true;
    			List<Data_Mapping__c> upsertDataMappings = new List<Data_Mapping__c>();
    			List<Data_Mapping__c> deleteDataMappings = new List<Data_Mapping__c>();
    			List<DataMappingWrapper> upsertDataMappingWrapperList
    				= (List<DataMappingWrapper>)JSON.deserialize(upsertDataMappingsJSON, List<DataMappingWrapper>.class);
    			List<DataMappingWrapper> deleteDataMappingWrapperList
    				= (List<DataMappingWrapper>)JSON.deserialize(deleteDataMappingsJSON, List<DataMappingWrapper>.class);
    			
    			for (DataMappingWrapper dm : upsertDataMappingWrapperList) {
    				Data_Mapping__c dataMapping
						= new Data_Mapping__c(Name = dm.dataMappingName,
												Visible__c = dm.visible,
												Required__c = dm.required,
												Order__c = dm.orderNo,
												Filter__c = dm.filterId != '' ? dm.filterId : null,
												Referenceability_Type__c = dm.refTypeId != '' ? dm.refTypeId : null,
												Field_API_Name__c = dm.fieldAPIName,
												Object__c = ConstantsController.REFERENCE_PROFILE_FORM);
    				
    				if (dm.dataMappingId != '') {
	    				dataMapping.Id = dm.dataMappingId;
    				}
    				upsertDataMappings.add(dataMapping);
    			}
    			
    			for (DataMappingWrapper dm : deleteDataMappingWrapperList) {
    				deleteDataMappings.add(new Data_Mapping__c(Id = dm.dataMappingId));
    			}
    			
	            if (deleteDataMappings.size() > 0) {
	                delete deleteDataMappings;
	                Database.emptyRecycleBin(deleteDataMappings);
	            }
    			
	            if (upsertDataMappings.size() > 0) {
	                upsert upsertDataMappings;
	            }
    			List<Data_Mapping__c> datatoBeDeleted = [SELECT Name, Order__c, Id, Visible__c,
    														Field_API_Name__c, Required__c
    														FROM Data_Mapping__c
    														WHERE Object__c = :ConstantsController.REFERENCE_PROFILE_FORM
    														AND Referenceability_Type__c = null
    														AND Filter__c = null
    														AND Field_API_Name__c = ''
    														ORDER BY Order__c];
	            
	            if (datatoBeDeleted.size() > 0) {
	                delete datatoBeDeleted;
	            }
    			return 'success';
    		} catch(Exception e) {
    			Database.rollback(sp);
    			return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    		}
    	} else {
    		return CRUDAndFLSCheckController.getErrorMsg(); 
    	}
    }
    
    public class DataMappingWrapper {
    	public String dataMappingId { get; set; }
    	public String dataMappingName { get; set; }
    	public String refTypeId { get; set; }
    	public String refTypeName { get; set; }
    	public String filterId { get; set; }
    	public String filterName { get; set; }
    	public Boolean visible { get; set; }
    	public String fieldAPIName { get; set; }
    	public Boolean required { get; set; }
    	public Decimal orderNo { get; set; }
    	
    	public DataMappingWrapper(Data_Mapping__c dm) {
    		this.dataMappingId = dm.Id != null ? (String)dm.Id : '';
    		// Re :#1193
    		//this.dataMappingName = dm.Name;
    		this.dataMappingName = dm.Referenceability_Type__c != null && dm.Referenceability_Type__r.Name != null ? dm.Referenceability_Type__r.Name : dm.Name;
    		this.refTypeId = dm.Referenceability_Type__c != null ? (String)dm.Referenceability_Type__c : '';    		
    		this.refTypeName = dm.Referenceability_Type__c != null && dm.Referenceability_Type__r.Name != null ? dm.Referenceability_Type__r.Name : '';
    		this.filterId = dm.Filter__c != null ? (String)dm.Filter__c : '';
    		this.filterName = dm.Filter__c != null && dm.Filter__r.Name != null ? dm.Filter__r.Name : '';
    		this.visible = dm.Visible__c;
    		this.fieldAPIName = dm.Field_API_Name__c != null ? dm.Field_API_Name__c : '';
    		this.required = dm.Required__c;
    		this.orderNo = dm.Order__c;
    	}
    }
}