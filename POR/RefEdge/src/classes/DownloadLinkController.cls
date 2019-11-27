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
 * VF Page: DownloadLinkPage.page
 * Description: controller for downloading/opening ref contents and updating the corresponding count
 * Last modified by: Gaurav Saini (16 Dec, 2016) for #571
 */
public with sharing class DownloadLinkController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public Boolean isLinkTypeContent { get; set; }
    public String selectedRefContentId { get; set; }
    public String contentURL { get; set; }
    public String contentVersionId { get; set; }
    public Boolean isPermissionGranted { get; set; }
    public String baseUrl { get; set; }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions(String action) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c', new Set<String>());
        
        if (action == 'download') {
        	fieldMap.get(UtilityController.appNamespace() + 'Reference_Content__c').add(UtilityController.appNamespace() + 'Number_of_Download__c');
        } else if (action == 'open') {
        	fieldMap.get(UtilityController.appNamespace() + 'Reference_Content__c').add(UtilityController.appNamespace() + 'Ref_Content_Open_Clicks__c');
        }
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
        isPermissionGranted = isUpsertPermission;
        return isUpsertPermission;
    }
    
    /**
     * Constructor
     */
    public DownloadLinkController() {
    	isLinkTypeContent = false;
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm().replace('visual.force.com', 'content.force.com');
    	
    	if (ApexPages.currentPage().getParameters().get('ContentId') != null) {
    		isLinkTypeContent = false;
    		contentVersionId = ApexPages.currentPage().getParameters().get('ContentId');
    		checkPermissions('download');
    	} else if (ApexPages.currentPage().getParameters().get('ContentURL') != null) {
    		isLinkTypeContent = true;
    		contentURL = ApexPages.currentPage().getParameters().get('ContentURL');
    		checkPermissions('open');
    	}
    }
    
    /**
     * method to update the download count for ref content
     */
    public void updateContentDownloadCount() {
        
        if (selectedRefContentId != null && selectedRefContentId != '') {
            List<Reference_Content__c> refContentList = [SELECT Id, Number_of_Download__c
            												FROM Reference_Content__c
            												WHERE Id = :selectedRefContentId LIMIT 1];
            
            if (refContentList.size() > 0) {
                refContentList[0].Number_of_Download__c = (refContentList[0].Number_of_Download__c != null
                												? refContentList[0].Number_of_Download__c + 1 : 1);
                update refContentList;
            }
        }
    }
    
    /**
     * method to update the open link count for ref content
     */
    public void updateContentOpenCount() {
    	
        if (selectedRefContentId != null && selectedRefContentId != '') {
            List<Reference_Content__c> refContentList = [SELECT Id, Ref_Content_Open_Clicks__c
            												FROM Reference_Content__c
            												WHERE Id = :selectedRefContentId LIMIT 1];
            
            if (refContentList.size() > 0) {
                refContentList[0].Ref_Content_Open_Clicks__c = (refContentList[0].Ref_Content_Open_Clicks__c != null
                												? refContentList[0].Ref_Content_Open_Clicks__c + 1 : 1);
                update refContentList;
            }
        }
    }
}