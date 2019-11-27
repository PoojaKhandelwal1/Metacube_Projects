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
 * Page: AggregateHitList
 * Description: Class to update and delete Hit List
 * Modified by: Rekha @Feb 3 2017
 */
public with sharing class AggregateHitListController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Integer number_of_page { get; set; }
    public Integer totalPage { get; set; }
    public Integer noOfRecords { get; set; }
    public Integer size { get; set; }
    public string UpdateHitRecordId { get; set; }
    public string hitRecordId { get; set; }
    public boolean asterikValue { get; set; }
	public List<Hit_List__c> hitLists { get; set; }
    public Boolean isInlineEditingDisabled { get; set; }
    public Boolean isEdit { get; set; }
    public List<Hit_list__c> hitListRecords {
        get {
        	
            if (setCon != null) {
                return (List<Hit_list__c>)setCon.getRecords();
            } else {
                queryHitRecords();
                return (List<Hit_list__c>)setCon.getRecords();
            }
        }
    }
    
    public ApexPages.StandardsetController setCon {
        get {
        	
            if (setCon != null) {
                setCon.setPageSize(size);
                return setCon;
            } else {
                return null;
            }
        }
        set;
    }
    
    /**
     * Constructor
     */
    public AggregateHitListController() {
        size = 10;
        isInlineEditingDisabled = false;
        isEdit = false;
        queryHitRecords();
    }
    
    /**
     * Method to query Hit records
     */
    public void queryHitRecords() {
        hitLists = [SELECT Referenceability_Type__c, Reference_Request__c, Reference_Request__r.Id, Opportunity__c, Note__c, 
        				LastActivityDate, Field1__c, Email__c, Disposition__c, Deadline__c, Contact__c, Account__c, Phone__c, Released__c 
        				FROM Hit_List__c WHERE released__c = false ORDER BY Field1__c DESC, CreatedDate DESC];
        setCon = new ApexPages.StandardsetController(hitLists);
        noOfRecords = setCon.getResultSize();
        totalPage = noOfRecords / size;
        
        if (math.mod(noOfRecords, size) > 0) {
            totalPage += 1;
        }
        isEdit = false;
    }
    
    /**
     * Method to save Hit records
     */
    public void saveTheRecord() {
    	
    	if (checkPermissions(false, 'update')) {
	        try {
	            List<Hit_List__c> tempRecords = setCon.getRecords();
	            
	            for (Hit_List__c hitObj: tempRecords) {
	            	
	                if (UpdateHitRecordId != '' && hitObj.Id == UpdateHitRecordId) {
	                    hitObj.Field1__c = asterikValue;
	                }
	            }
	            
	            if (tempRecords.size() > 0) {
	                update tempRecords;
	            }
	            setCon = null;
	            isEdit = false;
	        } catch (exception e) {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            Apexpages.addMessage(message);
	            system.debug('********'+e.getMessage());
	        }
        }
    }
    
    /**
     * Method to delete Hit records
     */
    public void delHitRecord() {
    	
    	if (checkPermissions(false, 'delete')) {
	        try {
	            List<Hit_List__c> tempRecords = setCon.getRecords();
	            Hit_List__c deletedRecord = new Hit_List__c();
	            
	            for (Hit_List__c hitObj: tempRecords) {
	            	
	                if (hitObj.Id == hitRecordId) {
	                    deletedRecord = hitObj;
	                }
	            }
	            
	            if (deletedRecord.Id != null) {
	                delete deletedRecord;
	                setCon = null;
	            }
	        } catch (Exception e) {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            Apexpages.addMessage(message);
	        }
    	}
    }
    
    /**
     * Method to edit Hit records
     */
    public void editRow(){
        isEdit = true;
    }
    
    /**
     * Method to check Permissions on page load
     */
    public void checkPermission() {
    	checkPermissions(true, '');
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions(Boolean both, String action) {
	
    	Boolean isUpsertPermission = true;
    	Boolean isDeletePermission = true;
    	
    	if (both == true || action == 'update') {
        	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    		fieldMap.put(UtilityController.appNamespace() + 'Hit_List__c', new Set<String> { 
        									UtilityController.appNamespace() + 'Field1__c' });
    		isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    	}
    	
    	if (both == true || action == 'delete') {
        	isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Hit_List__c'});
    	}
        return (isUpsertPermission && isDeletePermission);
    }
}