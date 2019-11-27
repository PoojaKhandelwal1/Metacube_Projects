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
 * VF Page: PreviewMicrositeNew.page
 * Description: Controller for new microsite page
 * Last Modified By: Rajesh @20 Jan 2017
 */
global with sharing class PreviewMicrositeNewController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
	public String micrositeId { get; set; }
	public String selectedRefContents { get; set; }
	public String encryptedKey { get; set; }
	public Boolean internalPreview { get; set; }
	public Boolean isLicense { get; set; }
	public String siteURLFromAppCfg { get; set; }
	// added for #581 - flag to show sample preview of the microsite
	public Boolean isSamplePreview { get; set; }
    
    /**
     * Constructor
     */
    global PreviewMicrositeNewController() {
    	// Check User premissions
    	checkPermissions(true, 'PAGE_LOAD');
		micrositeId = '';
		selectedRefContents = '';
		encryptedKey = '';
		internalPreview = false;
		isLicense = false;
		siteURLFromAppCfg = UtilityController.getSiteUrl();
		isSamplePreview = false;
		List<User> currentLoggedInUser = [SELECT Id, Name, IsActive, Profile.UserLicense.Name
											FROM User Where Id = :UserInfo.getUserId()];
		
		if (currentLoggedInUser.size() > 0) {
			
			if (currentLoggedInUser[0].Profile.UserLicense.Name.contains('Guest')) {
				isLicense = true;
			}
		}
		
		if (apexPages.currentPage().getParameters().get('samplePreview') != null) {
			isSamplePreview = apexPages.currentPage().getParameters().get('samplePreview') == 'true' ? true : false;
		}
		
		if (apexPages.currentPage().getParameters().get('micrositeId') != null) {
			micrositeId = apexPages.currentPage().getParameters().get('micrositeId');
		}
		
		if (apexPages.currentPage().getParameters().get('selectRefContent') != null) {
			selectedRefContents = ApexPages.currentPage().getParameters().get('selectRefContent');
		}
		
		if (apexPages.currentPage().getParameters().get('key') != null) {
			encryptedKey = apexPages.currentPage().getParameters().get('key');
		}
		
		if (apexPages.currentPage().getParameters().get('internalPreview') != null) {
			internalPreview = (apexPages.currentPage().getParameters().get('internalPreview') == 'true' ? true : false);
		}
    }
    
    /**
	 * method to get invitation Id, content Id and recepient Id
	 */
    @RemoteAction
    global static String getRecepientId(String key) {
    	String uniqueKey = decryptUniqueKey(key);
    	Map<String, String> resultMap = new Map<String, String>();
    	
    	if (uniqueKey != null && uniqueKey != '') {
    		
    		// changes for #588
    		if (uniqueKey == 'Error! Invalid Microsite URL.') {
    			return uniqueKey;
    		} else {
	    		resultMap.put('invitationId', uniqueKey.substringBetween('invitationId', 'recepientId'));
	    		// added for #588 - to check if invitation is sent before current package installation
    			Datetime currentPackageDate = UtilityController.getCurrentPackageDate();
    			List<Invitation__c> invitationList = WithoutSharingHelperController.getInvitationObject(uniqueKey.substringBetween('invitationId', 'recepientId'));
    			
	    		if (key.contains('KzcBgAgfds') && invitationList != null && invitationList.size() > 0 && invitationList[0].CreatedDate > currentPackageDate) {
    				return 'Error! Invalid Microsite URL.';
	    		}
	    		
	    		if (uniqueKey.contains('contentId')) {
					resultMap.put('contentId', uniqueKey.substringAfter('contentId').left(15));
				}
				
				if (uniqueKey.contains('recepientId')) {
					
					if (uniqueKey.substringAfter('recepientId').substring(0, 3) == '003') {
						resultMap.put('inviteeId', uniqueKey.substringAfter('recepientId').left(15));
					} else if (uniqueKey.substringAfter('recepientId').substring(0, 3) == '005') {
						resultMap.put('userId', uniqueKey.substringAfter('recepientId').left(15));
					} else {
						resultMap.put('otherRecepient', uniqueKey.substringAfter('recepientId').left(15));
					}
				}
    		}
    	}
    	return JSON.serialize(resultMap);
    }
    
    /**
	 * method to get invitation object
	 */
    @RemoteAction
    global static String getInvitationDetails(String invitationId) {
    	List<Invitation__c> invitationList;
		Invitation__c invitationObj;
		List<InvitationWrapper> invitationWrapperList = new List<InvitationWrapper>();
    	
    	if (invitationId != null && invitationId != '') {
    		invitationList = WithoutSharingHelperController.getInvitationObject(invitationId);
    		Datetime currentPackageDate = UtilityController.getCurrentPackageDate();
    		
    		if (invitationList != null && invitationList.size() > 0) {
    			invitationObj = invitationList[0];
    			invitationWrapperList.add(new InvitationWrapper(invitationObj));
    		}
    	}
		return JSON.serialize(invitationWrapperList);
    }
    
    /**
	 * method to get microsite details
	 */
    @RemoteAction
    global static String getMicrositeDetails(String micrositeId) {
		Microsite__c micrositeObj = new Microsite__c();
		List<MicrositeWrapper> micrositeWrapperList = new List<MicrositeWrapper>();
		
		if (micrositeId != '') {
			List<Microsite__c> micrositeList = WithoutSharingHelperController.getMicrositeObject(micrositeId);
			
			if (micrositeList != null && micrositeList.size() > 0) {
				micrositeObj = micrositeList[0];
			}
		}
		micrositeWrapperList.add(new MicrositeWrapper(micrositeObj));
		return JSON.serialize(micrositeWrapperList);
	}
    
    /**
	 * method to get included content details
	 */
    @RemoteAction
    global static String getContentDetails(String invitationId, String contentId, String userId,
    											String inviteeId, String otherRecepient) {
		List<Invitation_ReferenceContent__c> invContents;
		List<InvitationRefContentWrapper> IRCWrapperList = new List<InvitationRefContentWrapper>();
    	
    	if (invitationId != '') {
			invContents = WithoutSharingHelperController.getContentRatingDetails(invitationId, contentId,
																					userId, inviteeId, otherRecepient);
    	}
    	
    	if (invContents != null && invContents.size() > 0) {
    		
    		for (Invitation_ReferenceContent__c IRC : invContents) {
    			IRCWrapperList.add(new InvitationRefContentWrapper(IRC));
    		}
    	}
		return JSON.serialize(IRCWrapperList);
    }
    
    /**
	 * method to show included ref contents on the page
	 */
    @RemoteAction
    global static String getRefContentThumbnailMap(List<String> refContentIds) {
	    Map<String, String> refContentThumbnailMap = WithoutSharingHelperController.getRefContentThumbnailMap(refContentIds);
    	
    	if (refContentThumbnailMap != null && refContentThumbnailMap.size() > 0) {
	    	return JSON.serialize(refContentThumbnailMap);
    	} else {
    		return '';
    	}
    }
    
    /**
	 * method to show included ref contents on the page
	 */
    @RemoteAction
    global static String showRefContents(List<String> refContentIds, String invitationId, String contentId,
											String inviteeId, String userId, String otherRecepient, String siteURL) {
    	List<Reference_Content__c> refContentList = new List<Reference_Content__c>();
    	Set<String> tempRefContentIds = new Set<String>();
    	List<String> contentVersionIds = new List<String>();
		List<String> customContentIds = new List<String>();
    	List<IncludedContentWrapper> contentWrapperList = new List<IncludedContentWrapper>();
    	Map<String, String> refContentAccountsMap = new Map<String, String>();
    	refContentList = WithoutSharingHelperController.getRefContents(refContentIds);
		Map<String, Schema.DescribeFieldResult> customContentFieldsMap = new Map<String, Schema.DescribeFieldResult>();
		Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Reference_Content_Type_Field__c');
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        Set<String> queryFieldsSet = new Set<String>();
		queryFieldsSet.add(UtilityController.appNamespace() + 'Reference_Content__c');
		Map<Id,Set<String>> availableFields = new Map<Id,Set<String>>();
		
        for (String field : fieldMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
			
			if (dfr.isCustom()) {
				customContentFieldsMap.put(dfr.getName(), dfr);
				queryFieldsSet.add(dfr.getName());
				
				if (String.valueOf(dfr.getType()) == 'REFERENCE') {
					queryFieldsSet.add(dfr.getName().replace('__c','__r') + '.Name');
				}
			}
        }
    	
    	for (Reference_Content__c rc : refContentList) {
			
			if (rc.Substitute_Account_Name__c != null && rc.Substitute_Account_Name__c != '') {
				refContentAccountsMap.put(rc.id, rc.Substitute_Account_Name__c);
			} else {
				tempRefContentIds.add(rc.Id);
			}
    	}
    	
    	for (Account_Reference_Content__c ARC : WithoutSharingHelperController.getAccountReferenceContent(tempRefContentIds)) {
    		
    		if (!refContentAccountsMap.containsKey(ARC.Reference_Content__c)) {
                refContentAccountsMap.put(ARC.Reference_Content__c, '');
    		}
            String str = refContentAccountsMap.get(ARC.Reference_Content__c);
            refContentAccountsMap.put(ARC.Reference_Content__c, (str == ''
            														? ARC.Account__r.Name
            														: str + ', ' + ARC.Account__r.Name));
    	}
		Set<Id> refTypeForCustomContents = new Set<Id>();
    	
    	for (Reference_Content__c rc : refContentList) {
			
			if (rc.Content_ID__c != null) {
				contentVersionIds.add(rc.Content_ID__c);
			}

			if (rc.Custom_Reference_Content__c) {
				customContentIds.add(rc.Id);
				availableFields.put(rc.Reference_Content_Type__c, new Set<String>());
			}
			
			if (!refContentAccountsMap.containsKey(rc.id)) {
				refContentAccountsMap.put(rc.id, 'N/A');
			}
    	}
		Set<Id> availableFieldsKeys  = availableFields.keySet();
		
		for (Reference_Type_Mapping__c rtm : WithoutSharingHelperController.getRefTypeMapping(availableFieldsKeys)) {
			availableFields.get(rtm.Reference_Content_Type__c).add(rtm.name);													
		}
		
    	Map<Id, Reference_Interview__c> refInterviewMap = new Map<Id, Reference_Interview__c>();
        List<Reference_Interview__c> tempRefInterviewList = new List<Reference_Interview__c>();
        tempRefInterviewList = WithoutSharingHelperController.getRefInterviewList(refContentIds);
    	
    	for (Reference_Interview__c ri : tempRefInterviewList) {
        	refInterviewMap.put(ri.Reference_Content__c, ri);
        }
    	String uniqueURL = '';
    	Map<Id, ContentVersion> contentVersionMap 
    						= WithoutSharingHelperController.getContentVersionMap1(contentVersionIds);
		
		Map<Id, Reference_Content_Type_Field__c> customContentMap
    						= WithoutSharingHelperController.getRefContentTypeFields(customContentIds,queryFieldsSet);
    	
        
    	for (Reference_Content__c rc : refContentList) {
    		
    		if (contentId == '') {
    			
    			if (inviteeId != null) {
                    uniqueUrl = siteURL + Page.PreviewMicrositeNew.geturl()
                    				+ '?key=' + encryptUniqueKey(invitationId, inviteeId, rc.Id);
    			} else if (userId != null) {
                    uniqueUrl = siteURL + Page.PreviewMicrositeNew.geturl()
                    				+ '?key=' + encryptUniqueKey(invitationId, userId, rc.Id);
    			} else if (otherRecepient != null) {
                    uniqueUrl = siteURL + Page.PreviewMicrositeNew.geturl()
                    				+ '?key=' + encryptUniqueKey(invitationId, otherRecepient, rc.Id);
    			}
    		} else {
    			uniqueUrl = URL.getCurrentRequestUrl().toExternalForm();
    		}
			
    		if (rc.Custom_Reference_Content__c && customContentMap.containsKey(rc.Id)) {
				List<CustomContentTypeWrapper> customContentTypeWrapperList = new List<CustomContentTypeWrapper>();
				
				for (String field : customContentFieldsMap.keySet()) {
					
					if (availableFields.get(rc.Reference_Content_Type__c).contains(field)) {
						
						if ((String.valueOf(customContentFieldsMap.get(field).getType()) == 'DATE' || String.valueOf(customContentFieldsMap.get(field).getType()) == 'DATETIME') && customContentMap.get(rc.Id).get(field) != null && String.valueOf(customContentMap.get(rc.Id).get(field)).trim() != '') {
							String data = String.valueOf(customContentMap.get(rc.Id).get(field));
							Date dateValue = date.valueOf(data);
							Integer d = dateValue.day();
							Integer mo = dateValue.month();
							Integer yr = dateValue.year();
							DateTime dateTimeValue = DateTime.newInstance(yr, mo, d);
							data = dateTimeValue.format('MMM dd yyyy');//Format date
							customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), data, String.valueOf(customContentFieldsMap.get(field).getType())));
						} else if (String.valueOf(customContentFieldsMap.get(field).getType()) == 'REFERENCE' && !field.contains('Reference_Content__c')) {
							String fieldName = field.replace('__c','__r');
							sObject data = customContentMap.get(rc.Id).getSObject(fieldName);
							customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), String.valueOf(data.get('Name')), String.valueOf(customContentFieldsMap.get(field).getType())));
						} else if (!field.contains('Reference_Content__c')) {
							customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), customContentMap.get(rc.Id).get(field), String.valueOf(customContentFieldsMap.get(field).getType())));
						}
					}
				}
				if (refContentAccountsMap != null && refContentAccountsMap.containsKey(rc.Id)) {
					contentWrapperList.add(new IncludedContentWrapper(rc,
																		new ContentVersion(),
																		customContentTypeWrapperList,
																		new Reference_Interview__c(),
																		refContentAccountsMap.get(rc.Id),
																		uniqueUrl));
				} else {
					contentWrapperList.add(new IncludedContentWrapper(rc,
																		new ContentVersion(),
																		customContentTypeWrapperList,
																		new Reference_Interview__c(),
																		'',
																		uniqueUrl));
				}													
			} else if (contentVersionMap.containsKey(rc.Content_ID__c)) {
    			
    			if (refInterviewMap != null && refInterviewMap.containsKey(rc.Id)) {
    				
    				if (refContentAccountsMap != null && refContentAccountsMap.containsKey(rc.Id)) {
    					contentWrapperList.add(new IncludedContentWrapper(rc,
    																	contentVersionMap.get(rc.Content_ID__c),
																		null,
    																	refInterviewMap.get(rc.Id),
    																	refContentAccountsMap.get(rc.Id),
    																	uniqueUrl));
    				} else {
    					contentWrapperList.add(new IncludedContentWrapper(rc,
    																	contentVersionMap.get(rc.Content_ID__c),
																		null,
    																	refInterviewMap.get(rc.Id),
    																	'',
    																	uniqueUrl));
    				}
    			} else {
    				
    				if (refContentAccountsMap != null && refContentAccountsMap.containsKey(rc.Id)) {
    					contentWrapperList.add(new IncludedContentWrapper(rc,
    																	contentVersionMap.get(rc.Content_ID__c),
    																	null,
																		new Reference_Interview__c(),
    																	refContentAccountsMap.get(rc.Id),
    																	uniqueUrl));
    				} else {
    					contentWrapperList.add(new IncludedContentWrapper(rc,
    																	contentVersionMap.get(rc.Content_ID__c),
    																	null,
																		new Reference_Interview__c(),
    																	'',
    																	uniqueUrl));
    				}
    			}
    		} else {
    			
    			if (refInterviewMap != null && refInterviewMap.containsKey(rc.Id)) {
    				
    				if (refContentAccountsMap != null && refContentAccountsMap.containsKey(rc.Id)) {
    					contentWrapperList.add(new IncludedContentWrapper(rc,
    																	new ContentVersion(),
    																	null,
																		refInterviewMap.get(rc.Id),
    																	refContentAccountsMap.get(rc.Id),
    																	uniqueUrl));
    				} else {
    					contentWrapperList.add(new IncludedContentWrapper(rc,
    																	new ContentVersion(),
    																	null,
																		refInterviewMap.get(rc.Id),
    																	'',
    																	uniqueUrl));
    				}
    			} else {
    				
    				if (refContentAccountsMap != null && refContentAccountsMap.containsKey(rc.Id)) {
    					contentWrapperList.add(new IncludedContentWrapper(rc,
    																	new ContentVersion(),
    																	null,
																		new Reference_Interview__c(),
    																	refContentAccountsMap.get(rc.Id),
    																	uniqueUrl));
    				} else {
    					contentWrapperList.add(new IncludedContentWrapper(rc,
    																	new ContentVersion(),
    																	null,
																		new Reference_Interview__c(),
    																	'',
    																	uniqueUrl));
    				}
    			}
    		}
    	}
		return JSON.serialize(contentWrapperList);
    }
    
    /**
	 * method to save the rating value for the reference content
	 */
    @RemoteAction
    global static String saveContentRating(Double ratingValue, String refContentId, String invitationId,
											String inviteeId, String userId, String otherRecepient) {
    	Savepoint sp = Database.setSavepoint();
    	
    	if (checkPermissions(false,'SAVE')) {
	    	
	    	try {
	    		Invitation_ReferenceContent__c IRCToUpdate = new Invitation_ReferenceContent__c();
	    		
	    		if (refContentId != null && refContentId != '') {
	    			List<Invitation_ReferenceContent__c> invContents =
	    											WithoutSharingHelperController.getContentRatingDetails1(invitationId,
																											refContentId,
																											userId,
						    																				inviteeId,
						    																				otherRecepient);
	    			
	    			if (invContents != null && invContents.size() > 0) {
	    				
	    				for (Invitation_ReferenceContent__c IRC : invContents) {
	    					
	    					if (ratingValue != null && Double.valueOf(ratingValue) != 0.00) {
	    						IRC.Rating__c = Double.valueOf(ratingValue);
	    					} else {
	    						IRC.Rating__c = null;
	    					}
	    					IRCToUpdate = IRC;
	    				}
	    			}
	    			
	    			if (IRCToUpdate != null) {
	    				update IRCToUpdate;
	    			}
	    		}
	    		return 'SUCCESS';
	    	} catch(DMLException e) {
	    		Database.rollback(sp);
	    		return e.getDmlMessage(0);
	    	} catch(Exception e) {
	    		Database.rollback(sp);
	    		return e.getMessage();
	    	}
    	} else {
    		return null;
    	}
    }
    
    /**
	 * method to update invitation content after downloading
	 */
    @RemoteAction
    global static String updateInvitationContent(String selectedRefContentId, String invitationId,
											String inviteeId, String userId, String otherRecepient) {
    	Savepoint sp = Database.setSavepoint();
    	
    	if (checkPermissions(false, 'INVITATION')) {
	    	
	    	try {
	    		
	    		if (invitationId != '' && selectedRefContentId != '') {
	    			List<Invitation_ReferenceContent__c> invContents =
	    											WithoutSharingHelperController.getContentRatingDetails1(invitationId,
																										selectedRefContentId,
																										userId,
					    																				inviteeId,
					    																				otherRecepient);
	    			
	    			if (invContents != null && invContents.size() > 0) {
	    				
	    				if (invContents[0].First_Visit__c == null) {
	    					invContents[0].First_Visit__c = Datetime.now();
	    				}
	    				invContents[0].Visits_clicks__c = (invContents[0].Visits_clicks__c == null
	    														? 1
	    														: invContents[0].Visits_clicks__c + 1);
	    				update invContents[0];
	    			}
	    		}
	    		return 'IRC updated successfully';
	    	} catch(DMLException e) {
	    		Database.rollback(sp);
	    		return e.getDmlMessage(0);
	    	} catch(Exception e) {
	    		Database.rollback(sp);
	    		return e.getMessage();
	    	}
    	} else {
    		return null;
    	}
    }
    
    /**
	 * method to download content
	 */
    @RemoteAction
	global static String downloadRefContent(String refContentId) {
		
		if (checkPermissions(false, 'DOWNLOAD')) {
			
			try {
				List<String> contentVersionIds = new List<String>();
				String contentDocs = '';
				String resultUrl = '';
				List<Reference_Content__c> refContentsToUpdate = new List<Reference_Content__c>();
				List<Reference_Content__c> refContents =
										WithoutSharingHelperController.getRefContentsForDownload(refContentId);
				
				for (Reference_Content__c rc : refContents) {
					contentVersionIds.add(rc.Content_ID__c);
				}
				Map<Id, ContentVersion> mapContentVersion =
										WithoutSharingHelperController.getContentVersionMap(contentVersionIds);
				
				for (Reference_Content__c rc : refContents) {
					
					if (mapContentVersion != null && mapContentVersion.containsKey(rc.Content_ID__c)) {
	                	
	                	if (mapContentVersion.get(rc.Content_ID__c).ContentDocumentId != null) {
							
							if (contentDocs == '') {
								contentDocs += mapContentVersion.get(rc.Content_ID__c).ContentDocumentId;
							} else {
								contentDocs = contentDocs + '/' + mapContentVersion.get(rc.Content_ID__c).ContentDocumentId;
							}
						}
		            }
					Reference_Content__c temp = rc;
					decimal downloadCount = (temp.Number_of_Download__c != null ? temp.Number_of_Download__c : 0);
					temp.Number_of_Download__c = downloadCount + 1;
					refContentsToUpdate.add(temp);
				}
				
				if (refContentsToUpdate != null && refContentsToUpdate.size() > 0) {
					update refContentsToUpdate;
				}
				
				if (contentDocs != '') {
					resultUrl = '/sfc/servlet.shepherd/document/download/' + contentDocs;
					return resultUrl;
				} else {
					return '';
				}
			} catch (Exception e) {
	            return 'Error' + ' ' + e.getMessage();
	        }
        } else {
    		return null;
    	}
	}
	
	/**
	 * method to update invitee
	 */
	@RemoteAction
	global static String updateInvitee(String invitationId, String inviteeId,
											String userId, String otherRecepient) {
		Savepoint sp = Database.setSavepoint();
		
		if (checkPermissions(false, 'INVITEE')) {
			
			try {
				
				if (invitationId != '' && (inviteeId != '' || userId != '')) {
					List<Invitee__c> inviteeList = WithoutSharingHelperController.getInviteeList(invitationId, inviteeId,
																							userId, otherRecepient);
					
					if (inviteeList != null && inviteeList.size() > 0) {
						
						if (inviteeList[0].First_Visit__c == null) {
							inviteeList[0].First_Visit__c = Datetime.now();
						}
						inviteeList[0].Visits_clicks__c = (inviteeList[0].Visits_clicks__c == null
																					? 1
																					: inviteeList[0].Visits_clicks__c + 1);
						update inviteeList;
					}
				}
				return 'invitee updated successfully.';
			} catch(DMLException e) {
	    		Database.rollback(sp);
	    		return e.getDmlMessage(0);
	    	} catch(Exception e) {
	    		Database.rollback(sp);
	    		return e.getMessage();
	    	}
    	} else {
    		return null;
    	}
	}
    
    global static String encryptUniqueKey(String invitationId, String recepientId, String contentId) {
		// Changes made for #588 by Gaurav Saini (23 Nov, 2016)
		//String specialChar = 'KzcBgAgfds';
		String dataString = 'invitationId' + invitationId + 'recepientId' + recepientId + 'contentId' + contentId;
		String encodedKey = UtilityController.getEncodedKey();
		blob blobdata = EncodingUtil.base64Decode(dataString);
		blob key = EncodingUtil.base64Decode(encodedKey);
		blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, blobdata);
		String encryptedString = EncodingUtil.base64Encode(encryptedData); 
		return encryptedString;
    }
    
    /**
	 * method to decrypt UniqueKey
	 */
    @RemoteAction
    global static String decryptUniqueKey(String uniqueKey) {
		// changes for #588 - taken into account invitations sent before package installation
		// and which are still not expired
		//String spclChar = 'KzcBgAgfds';
		//blob encryptedData = EncodingUtil.base64Decode(uniqueKey.substringBefore(spclChar));
		try {
			blob encryptedData = EncodingUtil.base64Decode(uniqueKey);
			String encodedKey = UtilityController.getEncodedKey();
			blob key = EncodingUtil.base64Decode(encodedKey);
			blob decryptedData = Crypto.decryptWithManagedIV('AES256', key, encryptedData);
			String b64Decrypted = EncodingUtil.base64Encode(decryptedData);
			return b64Decrypted;
		} catch(Exception e) {
			
			try {
				String spclChar = 'KzcBgAgfds';
				
				if (uniqueKey.contains(spclChar)) {
					blob encryptedData = EncodingUtil.base64Decode(uniqueKey.substringBefore(spclChar));
					blob key = EncodingUtil.base64Decode(uniqueKey.substringAfter(spclChar));
					blob decryptedData = Crypto.decryptWithManagedIV('AES256', key, encryptedData);
					String b64Decrypted = EncodingUtil.base64Encode(decryptedData);
					return b64Decrypted;
				} else {
					return 'Error! Invalid Microsite URL.';
				}
			} catch(Exception e1) {
				return 'Error! Invalid Microsite URL.';
			}
		}
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(Boolean isOnPageLoad, String action) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Boolean isUpsertPermission = false;
    	
    	if (isOnPageLoad || action == 'INVITEE') {
            fieldMap.put(UtilityController.appNamespace() + 'Invitee__c', new Set<String> {
            										UtilityController.appNamespace() + 'Visits_clicks__c',
            										UtilityController.appNamespace() + 'First_Visit__c'});
    	}
        
        if (isOnPageLoad || action == 'DOWNLOAD') {
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c', new Set<String> {
            										UtilityController.appNamespace() + 'Number_of_Download__c'});
    	}
    	
    	if (isOnPageLoad || action == 'INVITATION') {
            fieldMap.put(UtilityController.appNamespace() + 'Invitation_ReferenceContent__c', new Set<String> {
            										UtilityController.appNamespace() + 'First_Visit__c',
            										UtilityController.appNamespace() + 'Visits_clicks__c'});
    	}
    	
    	if (isOnPageLoad || action == 'SAVE') {
            
            if (fieldMap.containsKey(UtilityController.appNamespace() + 'Invitation_ReferenceContent__c')) {
            	fieldMap.get(UtilityController.appNamespace() + 'Invitation_ReferenceContent__c').add(UtilityController.appNamespace() + 'Rating__c');
            } else {
	            fieldMap.put(UtilityController.appNamespace() + 'Invitation_ReferenceContent__c', new Set<String> {
	            										UtilityController.appNamespace() + 'Rating__c' });
            }
    	}
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
        return isUpsertPermission;
    }
    
    /**
	 * Wrapper Classes
	 */
    global class IncludedContentWrapper {
    	Boolean isSummaryExpanded { get; set; }
    	String expandIcon { get; set; }
    	String refContentId { get; set; }
    	String title { get; set; }
    	String summary { get; set; }
	    Reference_Content__c refContent { get; set; }
		List<CustomContentTypeWrapper> customContentFieldsList { get; set; }
	    ContentVersion contentVersion { get; set; }
	    String fileType { get; set; }
	    ThumbnailStyleWrapper thumbnailStyle { get; set; }
	    String refContentType { get; set; }
	    Boolean allowSharing { get; set; }
	    String accountName { get; set; }
	    String micrositeLink { get; set; } 
	    Boolean isCustomContent { get; set; }
        Boolean isInterviewType { get; set; }
        String speakerInfo { get; set; }
        String orgWebsite { get; set; }
        String orgDescription { get; set; }
        List<VideoWrapper> videoWrapList { get; set; }
        String photo { get; set; }
	    
	    global IncludedContentWrapper(Reference_Content__c refContent, ContentVersion contentVersion, List<CustomContentTypeWrapper> customContentFieldsList,
	    								Reference_Interview__c refInterview, String accountName, String micrositeLink) {
	        this.isSummaryExpanded = false;
	        this.expandIcon = 'expand_less';
	        this.refContentId = refContent.Id;
	        this.title = refContent.Title__c;
	        this.summary = refContent.External_Summary__c;
	        this.refContent = refContent;
	        this.contentVersion = contentVersion;
	        this.fileType = (contentVersion.FileType != null ? contentVersion.FileType : 'UNKNOWN');
	        
	        if (contentVersion.FileType != null
	        		&& (contentVersion.FileType == 'JPG'
	        		|| contentVersion.FileType == 'PNG')) {
		        
		        this.thumbnailStyle = new ThumbnailStyleWrapper();
	        } else {
	        	this.thumbnailStyle = null;
	        }
	        this.refContentType = refContent.Reference_Content_Type_Name__c;
	        this.allowSharing = refContent.Allow_Social_Sharing__c;
			this.isCustomContent = refContent.Custom_Reference_Content__c;
			this.customContentFieldsList = customContentFieldsList;
	        this.accountName = accountName;
	        this.micrositeLink = micrositeLink; 
	    	this.isInterviewType = refContent.Reference_Content_Type__r.Recorded_Reference_Type__c;
            this.speakerInfo = refInterview.Speaker_info__c;
            this.orgWebsite = refInterview.Org_website__c;
            this.orgDescription = refInterview.Org_description__c;
            this.photo = refInterview.Photograph__c;
            this.videoWrapList = new List<VideoWrapper>();
            
            if (refInterview.Interview_Topics__r != null && refInterview.Interview_Topics__r.size() > 0) {
            	
            	for (Interview_Topic__c it : refInterview.Interview_Topics__r) {
            		this.videoWrapList.add(new VideoWrapper(it));
            	}
            }
	    }

		global IncludedContentWrapper(Reference_Content__c refContent, ContentVersion contentVersion, Reference_Interview__c refInterview, String accountName, String micrositeLink) {
	        this.isSummaryExpanded = false;
	        this.expandIcon = 'expand_less';
	        this.refContentId = refContent.Id;
	        this.title = refContent.Title__c;
	        this.summary = refContent.External_Summary__c;
	        this.refContent = refContent;
	        this.contentVersion = contentVersion;
	        this.fileType = (contentVersion.FileType != null ? contentVersion.FileType : 'UNKNOWN');
	        
	        if (contentVersion.FileType != null
	        		&& (contentVersion.FileType == 'JPG'
	        		|| contentVersion.FileType == 'PNG')) {
		        
		        this.thumbnailStyle = new ThumbnailStyleWrapper();
	        } else {
	        	this.thumbnailStyle = null;
	        }
	        this.refContentType = refContent.Reference_Content_Type_Name__c;
	        this.allowSharing = refContent.Allow_Social_Sharing__c;
			this.isCustomContent = refContent.Custom_Reference_Content__c;
			this.accountName = accountName;
	        this.micrositeLink = micrositeLink; 
	    	this.isInterviewType = refContent.Reference_Content_Type__r.Recorded_Reference_Type__c;
            this.speakerInfo = refInterview.Speaker_info__c;
            this.orgWebsite = refInterview.Org_website__c;
            this.orgDescription = refInterview.Org_description__c;
            this.photo = refInterview.Photograph__c;
            this.videoWrapList = new List<VideoWrapper>();
            
            if (refInterview.Interview_Topics__r != null && refInterview.Interview_Topics__r.size() > 0) {
            	
            	for (Interview_Topic__c it : refInterview.Interview_Topics__r) {
            		this.videoWrapList.add(new VideoWrapper(it));
            	}
            }
	    }
    }
    
    /**
	 * Wrapper Classes
	 */
    global class VideoWrapper {
    	public Boolean isPanelOpen { get; set; }
    	public String videoURL { get; set; }
        public String questionTitle { get; set; }
        public String transcript { get; set; }
        
        global VideoWrapper(Interview_Topic__c interviewTopic) {
        	this.isPanelOpen = false;
        	this.videoURL = (interviewTopic.Video_Url_Embed__c != null && interviewTopic.Video_Url_Embed__c != ''
        						? interviewTopic.Video_Url_Embed__c : '');
        	this.questionTitle = (interviewTopic.Question__c != null ? interviewTopic.Question__c : '');
        	this.transcript = interviewTopic.Transcript__c != null ? interviewTopic.Transcript__c : '';
        }
    }
    
    /**
	 * Wrapper Classes
	 */
    global class ThumbnailStyleWrapper {
    	public String background { get; set; }
        
        global ThumbnailStyleWrapper() {
        	this.background = '';
        }
    }
    
	/**
	 * Wrapper Classes
	 */
    global class CustomContentTypeWrapper {
    	String label { get; set; }
		String apiName { get; set; }
		String value { get; set; }
		String type { get; set; }

		global CustomContentTypeWrapper (String apiName, String label, Object value, String type) {
			this.apiName = apiName;
			this.label = label;
			this.type = type;
			this.value = String.valueOf(value);
		}
    }
    /**
	 * Wrapper Classes
	 */
    global class InvitationWrapper {
    	String micrositeId { get; set; }
    	Boolean isExpired { get; set; }
    	String expirationDate { get; set; }
    	
    	global InvitationWrapper(Invitation__c invitationObj) {
    		this.micrositeId = (invitationObj.Microsite__c != null && string.valueOf(invitationObj.Microsite__c) != '' ?
    												invitationObj.Microsite__c : '');
    		this.isExpired = invitationObj.Is_Invitation_Expired__c;
    		this.expirationDate = (invitationObj.Invitation_Expiration__c != null ?
    												((date)invitationObj.Invitation_Expiration__c).format() : '');
    	}
    }
    
    /**
	 * Wrapper Classes
	 */
    global class InvitationRefContentWrapper {
    	String refContentId { get; set; }
    	Double rating { get; set; }
    	
    	global InvitationRefContentWrapper(Invitation_ReferenceContent__c IRC) {
    		this.refContentId = IRC.Reference_Content__c;
    		this.rating = (IRC.Rating__c != null ? IRC.Rating__c : 0);
    	}
    }
    
    /**
	 * Wrapper Classes
	 */
    global class MicrositeWrapper {
    	String subHeaderText { get; set; }
    	String subHeaderSize { get; set; }
    	String subHeaderColor { get; set; }
    	String subHeaderAlignment { get; set; }
    	String imageAlignment { get; set; }
    	String pageColor { get; set; }
    	String headerAlignment { get; set; }
    	String headerSize { get; set; }
    	String headerColor { get; set; }
    	String headerText { get; set; }
    	String footerLink { get; set; }
    	String footerText { get; set; }
    	String footerSize { get; set; }
    	String footerColor { get; set; }
    	String footerAlignment { get; set; }
    	String titleColor { get; set; }
    	String bannerImage { get; set; }
    	Boolean availableForUse { get; set; }
    	// added for #611 by Gaurav Saini (9 Dec, 2016)
    	String headerBackgroundColor { get; set; }
    	
    	global MicrositeWrapper(Microsite__c micrositeObj) {
    		this.subHeaderText = micrositeObj.Sub_header_Copy__c;
	    	this.subHeaderSize = micrositeObj.Sub_Header_Copy_Size__c;
	    	this.subHeaderColor = micrositeObj.Sub_Header_Copy_Color__c;
	    	this.subHeaderAlignment = micrositeObj.Sub_Header_Copy_Alignment__c;
	    	this.imageAlignment = micrositeObj.Image_Alignment__c;
	    	this.pageColor = micrositeObj.Page_Color__c;
	    	this.headerAlignment = micrositeObj.Header_Copy_Alignment__c;
	    	this.headerSize = micrositeObj.Header_Copy_Size__c;
	    	this.headerColor = micrositeObj.Header_Copy_Color__c;
	    	this.headerText = micrositeObj.Header_Copy__c;
	    	this.footerLink = micrositeObj.Footer_Link__c;
	    	this.footerText = micrositeObj.Footer_Copy__c;
	    	this.footerSize = micrositeObj.Footer_Copy_Size__c;
	    	this.footerColor = micrositeObj.Footer_Copy_Color__c;
	    	this.footerAlignment = micrositeObj.Footer_Copy_Alignment__c;
	    	this.titleColor = micrositeObj.Document_Title_Color__c;
	    	this.bannerImage = micrositeObj.Banner_image__c;
	    	this.availableForUse = micrositeObj.Available_for_Use__c;
	    	this.headerBackgroundColor = micrositeObj.Header_Background_Color__c;
    	}
    }
}