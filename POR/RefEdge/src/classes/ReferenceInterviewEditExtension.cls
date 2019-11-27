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
 * Class: ReferenceInterviewEditExtension
 * Description : Class used to edit Reference interview records. 
 * Modified by: Rajesh @JUNE 13 2017
 */
public with sharing class ReferenceInterviewEditExtension extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public String photoName { get; set; }
    public transient blob photo { get; set; }
    public String photoContentType { get; set; }
    public String transcriptContentType { get; set; }
    public String transcriptName { get; set; }
    public transient blob transcript { get; set; }
    public Reference_Interview__c refInterview { get; set; }
    public Boolean showPage { get; set; }
    public Boolean refInterviewExists { get; set; }
    public String retUrl;
    
	/**
     * Constructor
     */
    public ReferenceInterviewEditExtension(ApexPages.StandardController controller) {
        refInterviewExists = false;
        refInterview = (Reference_Interview__c) controller.getRecord();
        // Check Object premissions
        checkPermissions();
        
        //re #395
        if (refInterview.Id != null) {         
        	refInterview = [SELECT r.Reference_Content__c, r.Id FROM Reference_Interview__c r WHERE Id = :refInterview.Id];
        }         
        showPage = true;
        
        if (ApexPages.currentPage().getParameters().get('retUrl') != null) {
        	retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        } else {
        	retUrl = refInterview.Reference_Content__c != null ? refInterview.Reference_Content__c : '';
        }
       
        if (refInterview.Id != null) {
            refInterview = [SELECT Reference_Content__c, Photograph__c, Speaker_info__c, Org_description__c, Org_website__c FROM Reference_Interview__c 
            				WHERE Id = :refInterview.Id][0];

        } else {
            
            if (refInterview.Reference_Content__c != null) {
                List<Reference_Content__c> refContent = [SELECT Reference_Content_Type_f__c, (SELECT Id FROM Reference_Interviews__r), Content_Type__c, 
                			Reference_Content_Type__r.Name__c, Reference_Content_Type__r.Recorded_Reference_Type__c FROM Reference_Content__c 
                			WHERE Id = :refInterview.Reference_Content__c];

                if (refContent.size() > 0) {
                    
                    if (refContent[0].Reference_Interviews__r.size() > 0) {
                        refInterviewExists = true;
                    }
                    
                    if (!refContent[0].Reference_Content_Type__r.Recorded_Reference_Type__c) {
                    	 showPage = false;
                    }                       
                }
            }
        }
    }
    
    /**
     * Method to save
     */
    public Pagereference save() {
    	
    	if (checkPermissions()) {
	        List<Reference_Content__c> refContents = [SELECT Library_ID__c, Reference_Content_Type__c FROM Reference_Content__c WHERE Id = :refInterview.Reference_Content__c];
	        
	        if (transcript != null) {
	            ContentVersion cv = new ContentVersion();
	            cv.VersionData = transcript;
	            cv.PathOnClient = transcriptName;
	            
	            if (refContents.size() > 0 && !test.isRunningTest()) {
	                cv.FirstPublishLocationId = refContents[0].Library_ID__c;
	            }
	            
	            cv.Title = transcriptName;
	            insert cv;
	            
	            refInterview.Transcript_Content_Id__c = cv.Id;
	        }                
	        upsert refInterview;		
			//re #589 Open Redirect Vulnerability :-if retURL found blank then redirect to previous page.
			return UtilityController.redirectToSource(retUrl); 
    	} else {
    		return null;
    	}
    }
        
	/**
     * Method to cancel
     */
    public pageReference cancel() {  
    	//re #589 Open Redirect Vulnerability :-if retURL found blank then redirect to previous page.
		return UtilityController.redirectToSource(retUrl); 
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {  
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	Boolean isUpsertPermission = false; 
    	Boolean isInsertPermission = false;
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Interview__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Transcript_Content_Id__c'});    
    
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);  
        fieldMap.clear();  
        fieldMap.put('ContentVersion', new Set<String> { 
        										'VersionData','PathOnClient','FirstPublishLocationId','Title'}); 
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        
        return (isUpsertPermission && isUpsertPermission); 
    }
}