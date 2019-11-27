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
 * Page : InterviewTopic 
 * Description : Class used handle Smart search settings 
 * Last Modified By: Rajesh @Feb 9 2017
 */
public with sharing class InterviewTopicExtension extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Interview_Topic__c interviewTopic { get; set; }
    public String ContentType { get; set; }
    public String contentFileName { get; set; }
    public transient blob contentFile { get; set; }
    public String retUrl;
    public String attachmentId { get; set; }
    
    /**
     * Constructor
     */
    public InterviewTopicExtension(ApexPages.standardController controller) {
        interviewTopic = (Interview_Topic__c) controller.getRecord();
        //Check user premissions
        checkPermissions();
         //re #395
        if (interviewTopic.Id != null) {
        	interviewTopic=[SELECT r.Reference_Interview__c, r.Id FROM Interview_Topic__c r WHERE Id = :interviewTopic.Id];
        }
         
        if (ApexPages.currentPage().getParameters().get('retURL') != null) {
	        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        } else {
        	retUrl = interviewTopic.Reference_Interview__c != null ? string.valueOf(interviewTopic.Reference_Interview__c) : '';
        } 
        
        if (interviewTopic.Id != null) {
            interviewTopic = [SELECT Question__c, Order__c, Interview_Question__c, Video_URL__c, (SELECT Id, Name FROM Attachments), Reference_Interview__c, transcript__c, 
            					Language__c, active__c FROM Interview_Topic__c WHERE Id = :interviewTopic.Id LIMIT 1][0];
            
            if (interviewTopic.Attachments.size() > 0) {
                contentFileName = interviewTopic.Attachments[0].Name;
                attachmentId = interviewTopic.Attachments[0].Id;
            }
        }
    }
    
    /**
     * Method to save
     */
    public pageReference Save() {
    	
    	if (checkPermissions()) {
        
	        if (ContentType != null && ContentType != '' && ContentType != 'audio/mp3' && ContentType != 'video/mp4') {
	            ContentType = null;
	            ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.INFO, System.Label.SUPPORTED_FORMATS));
	            return null;
	        }
	        
	        List<Reference_Interview__c> refInterview = [SELECT Reference_Content__r.Library_ID__c, Reference_Content__r.Reference_Content_Type__c, 
	        												Reference_Content__r.Content_Status__c, Reference_Content__c FROM Reference_Interview__c 
	        												WHERE Id = :interviewTopic.Reference_Interview__c];
	        if (refInterview.size() > 0) {
	            List<Interview_Question__c> interViewQuestion = [SELECT Language__c, Order__c, Question__c FROM Interview_Question__c 
	            													WHERE Id = :interviewTopic.Interview_Question__c];
	            
	            if (interViewQuestion.size() > 0) {
	                interviewTopic.Question__c = interViewQuestion[0].Question__c;
	                interviewTopic.Order__c = interViewQuestion[0].Order__c;
	                interviewTopic.Language__c = interViewQuestion[0].Language__c;
	            }
	            
	            if (refInterview[0].Reference_Content__r.Content_Status__c == 'Active') {
	                interviewTopic.active__c = true;
	            } else {
	                interviewTopic.active__c = false;
	            }
	            
	            if (contentFile != null) {
	                ContentVersion cv = new ContentVersion();
	                cv.VersionData = contentFile;
	                cv.PathOnClient = contentFileName;
	                
	                if (!test.isRunningTest()) {
	                    cv.FirstPublishLocationId = refInterview[0].Reference_Content__r.Library_ID__c;
	                    cv.Content_Status__c = refInterview[0].Reference_Content__r.Content_Status__c;
	                }
	              
	                ConstantsController.createRefContentRecord = false;
	                insert cv;
	                interviewTopic.Content_Id__c = cv.Id;
	            }
	            
	            if (interviewTopic.Video_URL__c != null && !interviewTopic.Video_URL__c.contains('brightcove') && (interviewTopic.Video_URL__c.contains('you'))) {
	                integer count = interviewTopic.Video_URL__c.lastIndexOf('/');
	                String path;
	                
	                if (count != -1) {
	                    path = interviewTopic.Video_URL__c.substring(count, interviewTopic.Video_URL__c.length());
	                    interviewTopic.Video_Url_Embed__c = 'https://www.youtube.com/embed' + path;
	                }
	            } else if (interviewTopic.Video_URL__c != null && interviewTopic.Video_URL__c.contains('brightcove')) {
	                
	                if (!interviewTopic.Video_URL__c.contains('https')) {
	                    interviewTopic.Video_Url_Embed__c = interviewTopic.Video_URL__c.replace('http', 'https');
	                    
	                    if (!interviewTopic.Video_URL__c.contains('secureConnections')) {
	                        interviewTopic.Video_Url_Embed__c += '&secureConnections=true';
	                    }
	                   
	                    if (!interviewTopic.Video_URL__c.contains('secureHTMLConnections')) {
	                        interviewTopic.Video_Url_Embed__c += '&secureHTMLConnections=true';
	                    }
	                } else if (interviewTopic.Video_URL__c.contains('https')) {
	                    interviewTopic.Video_Url_Embed__c = interviewTopic.Video_URL__c;
	                   
	                    if (!interviewTopic.Video_URL__c.contains('secureConnections')) {
	                        interviewTopic.Video_Url_Embed__c += '&secureConnections=true';
	                    }
	                   
	                    if (!interviewTopic.Video_URL__c.contains('secureHTMLConnections')) {
	                        interviewTopic.Video_Url_Embed__c += '&secureHTMLConnections=true';
	                    }
	                }
	            } else if (interviewTopic.Video_URL__c != null) {
	                
	                if (!interviewTopic.Video_URL__c.contains('https')) {
	                    interviewTopic.Video_URL__c = interviewTopic.Video_URL__c.replace('http', 'https');
	                }
	                interviewTopic.Video_Url_Embed__c = interviewTopic.Video_URL__c;
	            }
	            upsert interviewTopic;
	        } 
	        
	        return Cancel();
    	} else {
    		return null;
    	} 
    }
	
	/**
     * Method to cancel
     */
    public pageReference Cancel() { 
         //re #589 Open Redirect Vulnerability :-Validate URL and if retURL found blank then redirect to previous page.
		if (retUrl == '' || retUrl == null) {
			
			if (interviewTopic.Id == null) {
        		return new PageReference(System.URL.getSalesforceBaseURL().toExternalForm());
			} else {	
        		 return new PageReference('/' + interviewTopic.Id);
        	}
		} else {
			 return UtilityController.redirectToSource(retUrl); 
		} 
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Boolean isInsertPermission = false;
    	Boolean isUpsertPermission = false; 
    	       		
        fieldMap.put(UtilityController.appNamespace() + 'Interview_Topic__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Question__c',
        										UtilityController.appNamespace() + 'Order__c',
        										UtilityController.appNamespace() + 'Language__c',
        										UtilityController.appNamespace() + 'active__c',
        										UtilityController.appNamespace() + 'Content_Id__c',
        										UtilityController.appNamespace() + 'Video_Url_Embed__c',
        										UtilityController.appNamespace() + 'Video_URL__c'});  
        										
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true); 
       
        fieldMap = new Map<String, Set<String>>();          
        fieldMap.put('ContentVersion', new Set<String> { 
        										'VersionData', 'PathOnClient', 'FirstPublishLocationId',
        										UtilityController.appNamespace() + 'Content_Status__c' });
        										
        isInsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        
        return (isUpsertPermission && isInsertPermission); 
    }
}