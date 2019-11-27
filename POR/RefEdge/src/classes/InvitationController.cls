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
 * VF Page: Invitation
 * Description : Class used to send invitaion emails along with contents. 
 * Last modified date:21 Nov  2016
 * Modified by: Rajesh for ticket #591
 */

public with sharing class InvitationController {
    /**
     * Properties and variables
     */
    public String selectedRefContents { get; set; }
    public String opportunityId { get; set; }
    public String caseId { get; set; }
    public String contactEmailIds { get; set; }
    public String coworkerEmailIds { get; set; }
    public String message { get; set; }
    public String contactIds { get; set; }
    public String coworkerIds { get; set; }
    public Invitation__c invitation { get; set; }
    public Microsite__c microsite { get; set; }
    public Boolean showShareButton { get; set; }
    public List<SelectOption> microsites { get; set; }
    private List<Invitation_ReferenceContent__c> IRCList;
    private List<Invitee__c> invitees;
    private List<User> coWorkers;
    public Decimal defaultExpirationDays { get; set; }
    public Decimal maximumExpirationDays { get; set; }
    private Date todayDate = Date.Today();
    public Boolean isSubmitted { get; set; }
    public String forAccount { get; set; }
    public String forContent { get; set; }
    public String templateBody { get; set; } 
    public String datetext { get; set; } 
    public Boolean isRefcontentBlock { get; set; }
    public List<ConetntWrapper> listReferenceContent { get; set; }
    public String leadId { get; set; }
    public String fromLead { get; set; }
    public String hoverContentId { get; set; }
    public String hoverRefContentId { get; set; }
    public ContentVersion hoverContentVersion { get; set; }
    public Boolean customRefContent { get; set; }
    public Set<String> customContentFields;
    public String internalSummary { get; set; }
    public List<Reference_Interview__c> refInterview { get; set; }
    public Reference_Interview__c refInterviewRecord { get; set; }
    public Map<String, Boolean> customContentTypeFieldsMap { get; set; }
    public List<Reference_Content_Type_Field__c> refContentFields { get; set; }
    public Map<String, Schema.SObjectField> fldObjMap;
    public String referenceContentTitle { get; set; }
    public List<String> customContentTypeFields { get; set; }
    public Boolean isShowCoworker { get; set; }
    public String contentIdToRemove { get; set; }
    public Set<String> contentIds { get; set; }
    //#REF-1307
    public Map<String,FieldWrapper> mapCustomContentLabels { get; set; }
    /*
    * This field is use to show reward points in disolving alert for sales reward issue to user
    */
    public transient Decimal rewardPoints { get; set; }
    /*
    * This field is use to show action message in disolving alert for sales reward issue to user
    */
    public transient String actionMessage { get; set; }
    
    private String selectedContactIds, selectedUserIds;
    private List<sObject> postFeedItems = new List<sObject>();
    public String pageUrl { get; set; }
   
    /** 
     * Constructor
     */
    public InvitationController() { 
        isRefcontentBlock = false;
        showShareButton = true;
        contactEmailIds = '';
        coworkerIds = '';
        datetext = ''; 
        message = '';
        rewardPoints = 0; 
        refContentFields = new List<Reference_Content_Type_Field__c>();
        customContentFields = new Set<String>();
        customContentTypeFields = new List<String>();
        //#REF-1751 : Date Format on Modal
        mapCustomContentLabels = new Map<String,FieldWrapper>();
        reset();
        fldObjMap = schema.SObjectType.Reference_Content_Type_Field__c.fields.getMap();
        
        for (String str : fldObjMap.keyset()) {
            
            if (fldObjMap.get(str).getDescribe().isCreateable() && fldObjMap.get(str).getDescribe().isCustom() 
            						&& fldObjMap.get(str).getDescribe().getName() != UtilityController.appNamespace() + 'Reference_Content__c') {
                customContentFields.add(fldObjMap.get(str).getDescribe().getName());
                mapCustomContentLabels.put(fldObjMap.get(str).getDescribe().getName(),new FieldWrapper(fldObjMap.get(str).getDescribe().getName(), fldObjMap.get(str).getDescribe().getLabel(), String.valueOf(fldObjMap.get(str).getDescribe().getType())));
            }
        }
    }
    
    /**
     * Method to reset the variables
     */
    public void reset() {
        contentIds = new Set<String>();
        isSubmitted = false;
        isShowCoworker = false;
        //Initialize List to create records
        IRCList = new List<Invitation_ReferenceContent__c>();
        invitees = new List<Invitee__c>();
        coWorkers = new List<User>();
        refInterview = new List<Reference_Interview__c>();
        
    }
    
    /**
     * Method to fetch data on load of invitation page
     */
    public void onLoad() { 
        //New invitation record
        invitation = new Invitation__c(Name = 'Invitation ' + System.now(), 
        								Invitation_Expiration__c = todayDate.addDays(Integer.valueOf(defaultExpirationDays)), Start_Date__c = todayDate);
        //Changes for R15.89 - MOD
        User activeUser = [SELECT NAME, Email, PHONE, TITLE, mobilePhone, companyName From User WHERE ID = :Userinfo.getUserId() LIMIT 1];
        String phone = '';
        String mobile = '';
        String companyName = '';
        String profileName = '';
        
        if (activeUser.Phone != null && activeUser.Phone != '') {
        	phone = '\n'+activeUser.Phone+' Main';
        }
        
        if (activeUser.mobilePhone != null && activeUser.mobilePhone != '') {
        	mobile = '\n'+activeUser.mobilePhone+' Mobile';
        }
        
        if (activeUser.companyName != null && activeUser.companyName != '') {
        	companyName = '\n'+activeUser.companyName;
        }
        
        if (activeUser.Title != null && activeUser.Title != '') {
        	profileName = '\n'+activeUser.Title;
        }
        invitation.Message__c = '\n\n\n'+activeuser.Name+profileName+companyName+phone+mobile; 
        String micrositeId = UtilityController.getMicrositeTemplete();
       
        if (micrositeId != '') invitation.Microsite__c = micrositeId;
        
        //Microsites
        microsites = new List<SelectOption>();
        microsites.add(new SelectOption('', '--None--'));
        
        for (Microsite__c ms : [SELECT Id, Name FROM Microsite__c WHERE Available_for_Use__c = true ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
            microsites.add(new SelectOption(ms.Id, ms.Name));
        }
        List<EmailTemplate> templist = [SELECT Id, Subject, body, HTMLValue, BrandTemplateId FROM EmailTemplate WHERE DeveloperName = 'Invitation_Email_Template'];
        
        if (templist.size() > 0) {
            EmailTemplate temp = templist[0];
            List<BrandTemplate> letterHeads = [SELECT Value FROM BrandTemplate WHERE Id = :temp.BrandTemplateId LIMIT 1];
            
            if (letterHeads.size() > 0) {
                String textValue = letterHeads[0].Value;
                String header = textValue.substringBetween('<![CDATA[', ']]>');
                textValue = textValue.replace('<![CDATA[' + header + ']]>', '');
                String footer = '';
                
                while (textValue.contains('<![CDATA[') && footer == '') {
                    footer = textValue.substringBetween('<![CDATA[', ']]>');
                   
                    if (footer == '') {
                        textValue = textValue.replace('<![CDATA[]]>', '');
                    }
                }
                
                String tempStr = '';
                String bar1 = '';
                String bar2 = '';
                String bar3 = '';
                String height1 = '';
                String height2 = '';
                String height3 = '';
                String valignheader = '';
                String valignfooter = '';
                String textalignheader = '';
                String textalignfooter = '';
                String headerHeight = '';
                String footerHeight = '';
                String headercolor = '';
                String footercolor = '';
                
                while (textValue.contains('<style')) {
                    tempStr = textValue.substringBetween('<style', '</style>');
                    
                    if (tempStr.contains('bLabel="header"')) {
                        headercolor = tempStr.substringBetween('background-color="', '"');
                        headerHeight = tempStr.substringBetween('height="', '"');
                        valignheader = tempStr.substringBetween('vertical-align="', '"');
                        textalignheader = tempStr.substringBetween('text-align="', '"');
                    }
                    
                    if (tempStr.contains('bLabel="footer"')) {
                        footercolor = tempStr.substringBetween('background-color="', '"');
                        footerHeight = tempStr.substringBetween('height="', '"');
                        valignfooter = tempStr.substringBetween('vertical-align="', '"');
                        textalignfooter = tempStr.substringBetween('text-align="', '"');
                    }
                    
                    if (tempStr.contains('bLabel="accent1"')) {
                        bar1 = tempStr.substringBetween('background-color="', '"');
                        height1 = tempStr.substringBetween('height="', '"');
                    }
                    
                    if (tempStr.contains('bLabel="accent2"')) {
                        bar2 = tempStr.substringBetween('background-color="', '"');
                        height2 = tempStr.substringBetween('height="', '"');
                    }
                    
                    if (tempStr.contains('bLabel="accent3"')) {
                        bar3 = tempStr.substringBetween('background-color="', '"');
                        height3 = tempStr.substringBetween('height="', '"');
                    }
                    textValue = textValue.replace('<style' + tempStr + '</style>', '');
                }
                
                templateBody = '<div style="background-color:#ffffff"><center><table height="500px" width="550px" cellpadding="0" cellspacing="0"><tbody><tr valign="top"><td style="vertical-align:' + valignheader + ';height:' + headerHeight + 'px;text-align:' + textalignheader + ';background-color:' + headercolor + ';padding-left: 5px;"><img src="' + header + '"alt="Company Header Logo"/></td></tr><tr valign="top"><td style="height:' + height1 + 'px;background-color:' + ((bar1 != null && bar1 != '') ? bar1 : '#ffcc99') + '"></td></tr><tr valign="top"><td height="350px" style="color:#000000;font-size:12pt;background-color:#FFFFFF;font-family:arial"><div style="text-align:left;font-family: arial;font-size: 12pt;padding: 10px;">' + temp.HTMLValue + '</div></td></tr><tr valign="top"><td style="height:' + height2 + 'px;background-color:' + ((bar2 != null && bar2 != '') ? bar2 : '#ffcc99') + '"></td></tr><tr valign="top"><td style="vertical-align:' + valignfooter + ';height:' + footerHeight + 'px;text-align:' + textalignfooter + ';background-color:' + footercolor + '"><img src="' + footer + '"alt="Company Footer Logo"/></td></tr><tr valign="top"><td style="height:' + height3 + 'px;background-color:' + ((bar3 != null && bar3 != '') ? bar3 : '#ffcc99') + '"></td></tr></tbody></table></center><br><br></div>';
                templateBody = templateBody.replace('<![CDATA[', '');
                templateBody = templateBody.replace(']]>', '');
                templateBody = templateBody.replace('{!' + UtilityController.appNamespace() + 'Invitation__c.' + UtilityController.appNamespace() + 'Message__c}', '@@@m@@@');
                templateBody = templateBody.replace('{!' + UtilityController.appNamespace() + 'Invitation__c.' + UtilityController.appNamespace() + 'Invitation_Expiration__c}', '@@@d@@@');
                templateBody = templateBody.replace('{!' + UtilityController.appNamespace() + 'Invitee__c.' + UtilityController.appNamespace() + 'View_Microsite__c}', '<a href="#" onclick="previewMicrosite(); return false;"> ' + SYSTEM.LABEL.Preview_Microsite + '</a>');
            }
        }
    }

    
    /**
     * Method to showCoworkers
     */
    public void showCoworkers() {
        isShowCoworker = true;
    }

    /**
     * Method to set Default Template
     */
    public void setDefaultTemplate() {
        //Check for user premissions
        if (checkPermissions('TEMPLATE')) {
        
	        if (invitation.Microsite__c != null) { 
	            List<User_Mapping__c> userMappings = UtilityController.getUserMappings('Invitation');
				
				if (userMappings != null && userMappings.size() > 0) {
		        	userMappings[0].Default_Value__c = invitation.Microsite__c;
				} else {
		        	userMappings = new List<User_Mapping__c>();
		        	userMappings.add(new User_Mapping__c(Default_Value__c = invitation.Microsite__c, User__c = Userinfo.getUserId(),Process__c = 'Invitation'));
		    	}
		    	upsert userMappings;
	        }
        }
    }
    
    /**
     * Method to create new Invitation
     */
    public PageReference createInvitation() {
    	//Check for user premissions
        if (checkPermissions('CREATE')) {
	        Savepoint sp = Database.setSavepoint();
	        try {
	            List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
	            //Check Recipent Details
	            if ((contactEmailIds == null || contactEmailIds == '') && (coworkerEmailIds == null || coworkerEmailIds == '')) {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.SELECT_RECIPIENT));
	                return null;
	            }
	            //Check Subject value
	            if (invitation.Subject__c == null || invitation.Subject__c == '') {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.ENTER_SUBJECT));
	                return null;
	            }
	            //Check Invitation Expiration value
	            if (invitation.Invitation_Expiration__c == null) {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.ENTER_INVITATION_EXPIRATION));
	                return null;
	            }
	            //Validation for Invitation Expiration date
	            if (invitation.Invitation_Expiration__c <= Date.Today()) {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.INVITATION_EXPIRATION_TODAY));
	                return null;
	            }
	            //Validation for Invitation Expiration date
	            Date maximumExpirationDate = todayDate.addDays(Integer.valueOf(maximumExpirationDays));
	            if (invitation.Invitation_Expiration__c > maximumExpirationDate) {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, (System.Label.Invitation_Expiration_Error).replace('@@@', String.valueOf(maximumExpirationDays))));
	                return null;
	            }
	            //Check Microsite Templete value
	            if (invitation.Microsite__c == null) {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.SELECT_MICROSITE));
	                return null;
	            }
	            
	            if (opportunityId != null && opportunityId != '') {
	                invitation.Opportunity__c = opportunityId;
	            }
	            
	            if (caseId != null && caseId != '') {
	                invitation.Case__c = caseId; 
	            }
	            
	            //regarding ticket #809
	            if (leadId != null && leadId != '') {
	                invitation.Lead__c = leadId; 
	            }
	            
	            //Insert invitation
	            if (invitation.Id == null) {
	                insert invitation;
	            }             
	            //Recepient as Contact
	            selectedContactIds = contactIds;
	            List<String> listContactIds = new List<String>();
	            
	            if (contactIds != null && contactIds != '') {
	                listContactIds = contactIds.split(',');
	            }
	            Map<Id, Contact> mapContact = new Map<Id, Contact>([SELECT Id, FirstName, Name, Email FROM Contact WHERE Id IN :listContactIds]);
	            
	            for (String contactId : listContactIds) {
	                String uniqueUrl = UtilityController.getSiteUrl() + Page.PreviewMicrositeNew.geturl() + '?key=' + getEncryptedUniqueKey(invitation.id, contactId);
	                Invitee__c tempObj = new Invitee__c();
	                tempObj.Invitation__c = invitation.Id;
	                tempObj.Contact__c = contactId;
	                tempObj.URL__c = uniqueUrl;
	                invitees.add(tempObj);
	            }
	            //Recepient as Co-worker
	            selectedUserIds = coworkerIds;
	            List<String> listUserIds = new List<String>();
	            
	            if (coworkerIds != null && coworkerIds != '') {
	                listUserIds = coworkerIds.split(',');
	            }
	            
	            Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, FirstName, Name, Email FROM User WHERE Id IN :listUserIds]);
	            
	            for (String userId : listUserIds) {
	                String uniqueUrl = UtilityController.getSiteUrl() + Page.PreviewMicrositeNew.geturl() + '?key=' + getEncryptedUniqueKey(invitation.id, userId);
	                Invitee__c tempObj = new Invitee__c();
	                tempObj.Invitation__c = invitation.Id;
	                tempObj.User__c = userId;
	                tempObj.URL__c = uniqueUrl;
	                invitees.add(tempObj);
	            }
	            
	            //Insert Recepient
	            if (invitees.size() > 0) { 
	                insert invitees;
	            }
	            
	            //Insert Reference Content invitation
	            if (listReferenceContent != null && listReferenceContent.size() > 0) {
	                
	                for (Invitee__c invitee : invitees) {
	                   
	                    for (ConetntWrapper cw : listReferenceContent) {
	                        Invitation_ReferenceContent__c ircObj = new Invitation_ReferenceContent__c();
	                        ircObj.Invitation__c = invitation.Id;
	                        ircObj.Reference_Content__c = cw.refContent.Id;
	                        ircObj.Recipient__c = invitee.id;
	                        IRCList.add(ircObj);
	                    }
	                }
	                
	                if (IRCList.size() > 0) {
	                    insert IRCList;
	                }
	            }
	            isSubmitted = true;            
	            //Below condtion added for Sales Reward Implementation RE #145 Issue Sales Reward Invitation - to Contact and Invitation ? to Co Worker
	            Custom_Settings__c cs = UtilityController.getCustomSettings(); 
	                        
		        if (RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c ==  true) {   
		        	List<Reward__c> rewardsToBeInsert = new List<Reward__c>(); 
		            List<Referenceability_Type__c> refType;
		            List<String> lstRefType = new List<String>();
		            
		            if (contactEmailIds != null && contactEmailIds != '') {	   
		            	lstRefType.add(ConstantsController.INVITATION_TO_CONTACT);  
		            } else { 
		            	lstRefType.add(ConstantsController.INVITATION_TO_CO_WORKER); 	            	
		            }
					
		            refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstRefType); 
		             
		            //re #583 -Null check for User reward points.
		           	if (refType.size() > 0) {	           
			       		 rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c, Referenceability_Type__c = refType[0].Id, 
			       		 									Transaction__c = ConstantsController.ISSUE, RewardDate__c = Date.Today(), User__c = Userinfo.getUserId()));
			             UtilityController.isUserProfileExist(Userinfo.getUserId());
			             		             
			             //re #591 NEW field Onscreen Notification allow for on/off of Nomination onscreen notification.
			             if (cs.User_Reward_Onscreen_Notification__c) {
				             actionMessage = refType[0].Name;
				             rewardPoints = refType[0].Sales_Point__c;
			             }
		           	} 
		           	
			        if (rewardsToBeInsert.size() > 0) { 
		 				WithoutSharingHelperController.insertRewards(rewardsToBeInsert); 
					}  
	           	 }	  
	            return null;
	    	} catch (Exception e) {
	            Apexpages.addMessages(e);
	            Database.rollback(sp);
	            return null;
	       }
        } else {
        	 rewardPoints = 0;
        	 return null;
        }
    }
    
    /**
     * Method to Return to opportunity Page  & Ref Search Page
     */
    public Pagereference returnOpportunity() {
        PageReference returnPage;
        
        if (opportunityId != null && opportunityId.trim().length() > 0 && opportunityId != '') {
            returnPage = new PageReference('/' + OpportunityId);
        } else if (caseId != null && caseId.trim().length() != 0 && caseId != '') {
            returnPage = new PageReference('/' + caseId);
            //regarding ticket #809
        } else if (leadId != null && leadId.trim().length() != 0 && leadId != '') {
            returnPage = new PageReference('/' + leadId);
        } else {
            returnPage = new PageReference(pageUrl);
        }
        returnPage.setRedirect(true);
        return ReturnPage;
    }
    
    /**
     * Method to generate Unique Key
     */
    private String getEncryptedUniqueKey(String invitationId, String recepientId) {
        // Changes made for #614 by Gaurav Saini (29 Nov, 2016)
        //String specialChar = 'KzcBgAgfds';
        String dataString = 'invitationId' + invitationId + 'recepientId' + recepientId;
        String encodedKey = UtilityController.getEncodedKey();
        blob blobdata = EncodingUtil.base64Decode(dataString);
        blob key = EncodingUtil.base64Decode(encodedKey);
        blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, blobdata);
        String encryptedString = EncodingUtil.base64Encode(encryptedData);
        //encryptedString = encryptedString + specialChar + EncodingUtil.base64Encode(key);
        return encryptedString;
    }
	
	/**
     * Method to preview Email
     */
    public void previewEmail() {
        message = (invitation.Message__c != null ? invitation.Message__c : '<p id="msgSapnId"></p>'); 
        datetext = (invitation.Invitation_Expiration__c != null ? invitation.Invitation_Expiration__c.format() : '<p id="dateSapnId"></p>');
    }

    /* Create a 'what's in my invitation' list which includes a 'delete' functionality*/
    /**
     * Method to refresh
     */
    public void refresh() {
        contentIds = new Set<String>();
        
        if (selectedRefContents != null && selectedRefContents != '') {
            
            for (String refId : selectedRefContents.split(',')) {
                contentIds.add(refId);
            }
        }
        invitation.Message__c = '\n\n\n'+invitation.Message__c.trim(); 
        listReferenceContent = new List<ConetntWrapper>();
        List<Reference_Content__c> refContentList = [SELECT Id, Reference_Content_Type__r.Name__c, Title__c, Content_ID__c,Summary__c,Custom_Reference_Content__c, 
        												(SELECT Id, Account__c, Account__r.Name FROM Account_Reference_Contents__r LIMIT 2) 
        												FROM Reference_Content__c WHERE Id IN :contentIds ORDER BY Title__c ASC];
        Set<String> tempContentIds = new Set<String>();
        
        for (Reference_Content__c rc : refContentList) {
            tempContentIds.add(rc.Content_ID__c);
        } 
        Map<Id, ContentVersion> mapContentVersion = new Map<Id, ContentVersion>([SELECT Id, title, FileType, LastModifiedDate, ContentDocumentId 
        														FROM ContentVersion WHERE Id IN :tempContentIds LIMIT :limits.getLimitQueryRows()]);
        
        for (Reference_Content__c rc : refContentList) {
            String AccountName = '';
            String AccountId = '';
           
            if (rc.Account_Reference_Contents__r.size() == 0) {
                AccountName = '';
                AccountId = '';
            } else if (rc.Account_Reference_Contents__r.size() == 1) {
                AccountName = rc.Account_Reference_Contents__r[0].Account__r.Name;
                AccountId = '/' + rc.Account_Reference_Contents__r[0].Account__r.Id;
            } else {
                AccountName = System.Label.Multiple_Accounts;
                AccountId = Page.AssociatedRefContAccounts.geturl() + '?refContentId=' + rc.Id;
            }
            
            if (mapContentVersion.containsKey(rc.Content_ID__c)) {
                listReferenceContent.add(new ConetntWrapper(rc, mapContentVersion.get(rc.Content_ID__c), accountName, AccountId));
            } else {
                listReferenceContent.add(new ConetntWrapper(rc, new ContentVersion(), accountName, AccountId));
            }
        } 
    }

    /**
     * Method to show block
     */
    public void showRefContents() {
        isRefcontentBlock = (isRefcontentBlock ? false : true);
        refresh();
    }

    /**
     * Method to remove List
     */
    public void removeContent() {
        Integer countRecords = 0;
       
        if (listReferenceContent.size() == 1) {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, system.label.You_cannot_delete_all_Contents));
            return;
        }
        
        for (ConetntWrapper cw : listReferenceContent) {
            
            if (cw.refContent.id == contentIdToRemove) {
                listReferenceContent.remove(countRecords);
                selectedRefContents = selectedRefContents.replace(',' + cw.refContent.id, '');
                selectedRefContents = selectedRefContents.replace(cw.refContent.id + ',', '');
                selectedRefContents = selectedRefContents.replace(cw.refContent.id, '');
                break;
            }
            countRecords++;
        }
        refresh();
    }
    
    /**
     * Method on Hover of content record
     */
    public void fetchHoverContentItem() {
    	if (checkPermissions('HOVER_CONTENT')) {
	        refContentFields = new List<Reference_Content_Type_Field__c>();
	        refInterview = new List<Reference_Interview__c>();
	        refInterviewRecord = new Reference_Interview__c();
	        customContentTypeFieldsMap = new Map<String, Boolean>();
	        hoverContentVersion = new ContentVersion();
	        Boolean refContentInterviewType;
	        
	        if (hoverContentId != null && hoverContentId.trim() != '') {
	            List<ContentVersion> lstCV = [SELECT Id, Title, FileType, ContentUrl, VersionNumber, PositiveRatingCount, ContentDocumentId, FirstPublishLocationId, CreatedDate, CreatedById, Description, ContentSize FROM ContentVersion WHERE id = :hoverContentId];
	            
	            if (lstCV.size() > 0) {
	                customRefContent = false;
	                hoverContentVersion = lstCV[0];
	            } else {
	            	hoverContentVersion = new ContentVersion();
	            }
	        } else {
	            String refContentId;
	            
	            for (Reference_Content__c rc : [SELECT Title__c,Summary__c, Custom_Reference_Content__c, Reference_Content_Type__r.Name__c, Reference_Content_Type__r.Recorded_Reference_Type__c, Reference_Content_Type__c FROM Reference_Content__c WHERE Id = :hoverRefContentId]) {
	                
	                if (rc.Custom_Reference_Content__c) {
	                    customRefContent = true;
                        internalSummary = rc.Summary__c ;
	                } else {
	                    customRefContent = false;
	                } 
	                refContentInterviewType = rc.Reference_Content_Type__r.Recorded_Reference_Type__c;
	                refContentId = rc.Reference_Content_Type__c;
	                referenceContentTitle = rc.Title__c;
	            }
	              
	            if (customRefContent) {    

                    if (customContentFields.size() ==0 ) {
                        
                        for (String str : fldObjMap.keyset()) {
            
                            if (fldObjMap.get(str).getDescribe().isCreateable() && fldObjMap.get(str).getDescribe().isCustom() 
                                                    && fldObjMap.get(str).getDescribe().getName() != UtilityController.appNamespace() + 'Reference_Content__c') {
                                customContentFields.add(fldObjMap.get(str).getDescribe().getName());
                            }
                        }   
                    }         
	                String soqlQuery = 'SELECT Id ';
	                
	                for (String s : customContentFields) {
	                    soqlQuery += ',' + s;
	                }
	                soqlQuery += ' FROM Reference_Content_Type_Field__c WHERE Reference_Content__c =: hoverRefContentId';
	                
	                for (Reference_Content_Type_Field__c rcf : Database.query(String.escapeSingleQuotes(soqlQuery))) {
	                    refContentFields.add(rcf);
	                }
	                Set<String> fieldMappingsDelete = new Set<String>();
	                customContentTypeFields = new List<String>();
	                
	                for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Required__c, Reference_Content_Type__c, Name FROM Reference_Type_Mapping__c WHERE Reference_Content_Type__c = :refContentId AND visible__c = true ORDER BY Order__c NULLS LAST, Name]) {
	                    customContentTypeFields.add(rtm.Name);
	                    
	                    if (rtm.Required__c) {
	                        customContentTypeFieldsMap.put(rtm.Name, true);
	                    } else {
	                        customContentTypeFieldsMap.put(rtm.Name, false);
	                    }
	                }
	                
	                for (String fieldName : customContentTypeFields) {
	                    
	                    if (!customContentFields.contains(fieldName)) {
	                        fieldMappingsDelete.add(fieldName);
	                    }
	                }
	                
	                for (String fieldName : fieldMappingsDelete) {
	                    customContentTypeFieldsMap.remove(fieldName);
	                }
	                List<integer> indexToBeDeleted = new List<integer>();
                    List<String> itemsToBeDeleted = new List<String>();
	                
	                for (Integer index = 0; index < customContentTypeFields.size(); index++) {
	                	
	                    if (fieldMappingsDelete.contains(customContentTypeFields[index])) {
	                        indexToBeDeleted.add(index);
                            itemsToBeDeleted.add(customContentTypeFields[index]);
	                    }
	                }
	                
	                for (String item : itemsToBeDeleted) {
	                    customContentTypeFields.remove(customContentTypeFields.indexOf(item));
	                }
	                List<Reference_Type_Mapping__c> deleteRTM = new List<Reference_Type_Mapping__c>();
	                
	                for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Required__c, Reference_Content_Type__c, Name FROM Reference_Type_Mapping__c WHERE Reference_Content_Type__c = :refContentId AND Name IN :fieldMappingsDelete]) {
	                    deleteRTM.add(rtm);
	                }
	                
	                if (deleteRTM.size() > 0) {
	                    delete deleteRTM;
	                }
	            } else if (refContentInterviewType) {
	
	                refInterview = [SELECT Transcript__c, Reference_Content__r.Title__c, LastModifiedDate, Photograph__c, Speaker_info__c, Transcript_Content_Id__c, 
	                				Org_website__c, Org_description__c, Name, (SELECT Name, Question__c, Transcript__c, Video_Url_Embed__c, Content_Id__c, Order__c 
	                				FROM Interview_Topics__r ORDER BY Order__c) FROM Reference_Interview__c WHERE Reference_Content__c = :hoverRefContentId];
	                
	                if (refInterview.size() > 0) {
	                    refInterviewRecord = refInterview[0];
	                }
	            }
	        }
        }
    }

    /**
     * Method to single download
     */
    public PageReference singleContentDownload() {
        //Check for user premissions
        if (checkPermissions('DOWNLOAD')) {
        
	        if (hoverRefContentId != '') {
	            List<Reference_Content__c> updateDownloads = new List<Reference_Content__c>();
	            List<Reference_Content__c> tempList = [SELECT Id, Number_of_Download__c, Content_ID__c FROM Reference_Content__c WHERE Id = :hoverRefContentId ];
	            
	            for (Reference_Content__c refContent : tempList) {
	                Reference_Content__c temp = refContent;
	                decimal downloadNo = (temp.Number_of_Download__c != null ? temp.Number_of_Download__c : 0);
	                temp.Number_of_Download__c = downloadNo + 1;
	                updateDownloads.add(temp);
	            }
	            
	            if (updateDownloads.size() > 0) {
	                update updateDownloads;
	            }
	        }
	        String ContentUrl = '';
	        
	        if (hoverContentVersion.FileType == 'LINK') {
	            ContentUrl = hoverContentVersion.ContentUrl;
	        } else {
	            ContentUrl = '/sfc/servlet.shepherd/document/download/' + hoverContentVersion.ContentDocumentId;
	        }
	        return new PageReference(ContentUrl);
        } else {
        	return null;
        }    
    }

    /**
     * Wrapper Class Content Types
     */
    public class FieldWrapper {
        public String apiName { get; set; }
        public String label { get; set; }
        public String type { get; set; }
        public FieldWrapper(String apiName, String label, String type) {
            this.apiName = apiName;
            this.label = label;
            this.type = type;
        }
    }
    
    /**
     * Method to check User premissions
     */
    public Boolean checkPermissions(String action) { 
        	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        	Boolean isInsertPermission = true;
        	Boolean isDeletePermission = true;
        	Boolean isUpsertPermission = true;
        	Boolean isUpsertMappingPermission = true;
        	
        	if (action == 'CREATE' || action == 'PAGE_LOAD') {
	           	fieldMap.put(UtilityController.appNamespace() + 'Invitation__c', new Set<String> { 'Name', 
	            										UtilityController.appNamespace() + 'Invitation_Expiration__c',
	            										UtilityController.appNamespace() + 'Start_Date__c',
	            										UtilityController.appNamespace() + 'Message__c',
	            										UtilityController.appNamespace() + 'Microsite__c',
	            										UtilityController.appNamespace() + 'Subject__c'});
														
	 			if (opportunityId != null && opportunityId.trim().length() > 0 && opportunityId != '') {
	 				fieldMap.get(UtilityController.appNamespace() + 'Invitation__c').add(UtilityController.appNamespace() + 'Opportunity__c'); 
	        	} else if (caseId != null && caseId.trim().length() != 0 && caseId != '') {
	        		fieldMap.get(UtilityController.appNamespace() + 'Invitation__c').add(UtilityController.appNamespace() + 'Case__c'); 
	        	//regarding ticket #809
	        	} else if (leadId != null && leadId.trim().length() != 0 && leadId != '') {
	        		fieldMap.get(UtilityController.appNamespace() + 'Invitation__c').add(UtilityController.appNamespace() + 'Lead__c'); 
	        	}
				fieldMap.put(UtilityController.appNamespace() + 'Invitee__c', new Set<String> { UtilityController.appNamespace() + 'Invitation__c',
	            										UtilityController.appNamespace() + 'User__c',
	            										UtilityController.appNamespace() + 'URL__c'});
				fieldMap.put(UtilityController.appNamespace() + 'Invitation_ReferenceContent__c', new Set<String> { UtilityController.appNamespace() + 'Invitation__c',
	            										UtilityController.appNamespace() + 'Reference_Content__c',
	            										UtilityController.appNamespace() + 'Recipient__c'});
	            isInsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);  
        	}	 
        	fieldMap.clear(); 	  
        	
        	if (action == 'HOVER_CONTENT' || action == 'PAGE_LOAD') {
        		isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Reference_Type_Mapping__c'});
        	}
        	fieldMap.clear(); 
        	
        	if (action == 'TEMPLATE' || action == 'PAGE_LOAD') {
	        	fieldMap.put(UtilityController.appNamespace() + 'User_Mapping__c', new Set<String> { UtilityController.appNamespace() + 'Default_Value__c',
	            										UtilityController.appNamespace() + 'User__c',
	            										UtilityController.appNamespace() + 'Process__c'});
	            isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true); 
        	}            
            fieldMap.clear();   
        	
        	if (action == 'DOWNLOAD' || action == 'PAGE_LOAD') {
	        	fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c', new Set<String> { UtilityController.appNamespace() + 'Number_of_Download__c'});									
	           	isUpsertMappingPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true); 
        	}
            
            return (isUpsertPermission && isDeletePermission && isInsertPermission && isUpsertMappingPermission); 
    }
}