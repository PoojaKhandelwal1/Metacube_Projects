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
 * VF Page: Reference Content-> Upload Thumbnail
 * Description: Controller used to upload attachments.
 * Last modified by: Gaurav Saini (1 May, 2017) for #5
 */
global with sharing class UploadThumbnailForRefContentController { 
	/**
     * Properties and variables
     */
    public Id currentThumbnail { get; set; }
    public Boolean isAllowedPremission { get; set; }
    public Boolean isSLDS { get; set; }
    public String contentVersionId { get; set; }
    public Boolean isFileChanged { get; set; }
    
    /**
     * Constructor
     */
	global UploadThumbnailForRefContentController() {}
    global UploadThumbnailForRefContentController(ApexPages.StandardController controller) {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
    	// Check User premissions.
    	isAllowedPremission = checkPermissions() ? true : false;
    	Reference_Content__c currentRecord = (Reference_Content__c)controller.getRecord();
    	List<Reference_Content__c> refContentList = [SELECT Id, Content_ID__c, Is_File_Changed__c
    													FROM Reference_Content__c
    													WHERE Id = :currentRecord.Id];
    	
    	if (refContentList != null && refContentList.size() > 0 && refContentList[0].Content_ID__c != null) {
    		contentVersionId = refContentList[0].Content_ID__c;
    		isFileChanged = refContentList[0].Is_File_Changed__c;
    	} else {
    		contentVersionId = '';
    		isFileChanged = false;
    	}
    	List<Attachment> attachmentsList = [SELECT ParentId, Name, Id, Body FROM Attachment
    										WHERE Name = 'documentThumbnail.jpg' AND ParentId = :currentRecord.Id];
    	
    	if (attachmentsList != null && attachmentsList.size() > 0) {
	    	currentThumbnail = attachmentsList[0].Id;
    	}
    }
    
    /**
     * Method used to save the thumbnail in ref content record
     * author: Gaurav Saini (19 May, 2017) for #498
     */
    @RemoteAction
    global static String saveThumbnail(String imageSource, String contentId) {
    	List<Reference_Content__c> refContentList = [SELECT Is_File_Changed__c, Id FROM Reference_Content__c WHERE Id = :contentId];
		
		if (refContentList != null && refContentList.size() > 0 && imageSource != '') {
			refContentList[0].Is_File_Changed__c = false;
			update refContentList;
			// moved the code for deleting old attachment to AddNewReferenceContentController
			// creating new attachment
			Attachment att = new Attachment(Name = 'documentThumbnail.jpg', ParentId = contentId);
			att.Body = EncodingUtil.base64Decode(imageSource);
			insert att;
			return 'success';
		} else {
			return 'failure';
		}
    }
    
    /**
     * Method used to get content version details
     * author: Gaurav Saini (1 May, 2017) for #498
     */
    @RemoteAction
    global static String getContentVersion(String contentVersionId) {
    	List<ContentVersion> cvList = WithoutSharingHelperController.getContentVersionList(contentVersionId);
    	String result = '';
    	
    	if (cvList != null && cvList.size() > 0) {
    		ContentVersionWrapper cvWrapper = new ContentVersionWrapper(cvList[0]);
    		result = JSON.serialize(cvWrapper);
    	}
    	return result;
    }
    
    /**
     * Method used to get file thumbnail
     * author: Gaurav Saini (1 July, 2017) for #498
     */
    @RemoteAction
    global static String getImageSource(String fileId, String refContentId) {
    	String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        String url = salesforceHost + '/services/data/v39.0/connect/files/'
                        + fileId + '/rendition?type=THUMB720BY480';
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(url);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        Http http = new Http();
        
        if (!Test.isRunningTest()) {
            HTTPResponse response = http.send(req);
        	
        	if (response.getStatusCode() == 200) {
        		saveThumbnail(EncodingUtil.base64Encode(response.getBodyAsBlob()), refContentId);
	        	return EncodingUtil.base64Encode(response.getBodyAsBlob());
        	} else {
        		return '';
        	}
        } else {
            return '';
        }
    }
    
    /**
     * deprecated method
     */
    global static String getImageSource(String fileId) {
    	return '';
    }
    
    /**
     * Method used to upload file attachments
     */ 
    @RemoteAction
    global static String uploadAttachment(String contentId, String attachmentBody, String attachmentName,
											String attachmentId) {
    	
    	if (checkPermissions()) {
	    	
	    	try {
	    		
				if (attachmentId == null || attachmentId == 'null') {
		    		
		    		if (contentId != null && contentId != '') {
			    		List<Attachment> attachmentsList = [SELECT ParentId, Name, Id, Body FROM Attachment WHERE Name = 'documentThumbnail.jpg' AND ParentId = :contentId];
			    		
			    		if (attachmentsList != null && attachmentsList.size() > 0) {
			    			delete attachmentsList;
			    		}
			    	}
		    	}
		    	
		    	if (contentId != null && contentId != '') {
		    		
		    		if (attachmentBody != null && attachmentBody != '') {
		    			List<Attachment> attachmentsList = [SELECT ParentId, Name, Id, Body FROM Attachment WHERE Name = 'documentThumbnail.jpg' AND ParentId = :contentId];
		    			Attachment att;
		    			
		    			if (attachmentsList != null && attachmentsList.size() > 0) {
		    				att = attachmentsList[0];
		    				attachmentsList = null;
		    			} else {
		    				att = new Attachment(Name = attachmentName, ParentId = contentId);
		    			}
		    			String newBody = '';
		    			
		    			if (att.Body != null) {
		    				newBody = EncodingUtil.base64Encode(att.Body);
		    			}
		    			newBody += attachmentBody;
		    			att.Body = EncodingUtil.base64Decode(newBody);
		    			newBody = null;
		    			upsert att;
		    			
		    			return att.Id;
		    		} else {
		    			return 'Attachment Body was null';
		    		}
		    	} else {
		    		return 'Ref Content could not be found';
		    	}
	    	} catch(Exception e) {
	            return e.getMessage();
	    	}
    	} else {
    		return null;
    	}
    }
    
    /**
     * Method to check Permissions-Check parent object premissions
     */
    public static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c', new Set<String>()); 
    	Boolean isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> { UtilityController.appNamespace() + 'Reference_Content__c'});    	
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
        
        return (isUpsertPermission && isDeletePermission);
    }
    
    global class ContentVersionWrapper {
    	public String fileType { get; set; }
    	public String fileId { get; set; }
    	
    	global ContentVersionWrapper(ContentVersion cv) {
    		this.fileType = cv.FileType;
    		this.fileId = cv.ContentDocumentId != null ? cv.ContentDocumentId : '';
    	}
    }
}