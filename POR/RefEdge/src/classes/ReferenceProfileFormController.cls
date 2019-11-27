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
 * VF Page: ReferenceProfileFormPage.page
 * Description: controller for creating reference profile for contacts/accounts
 * Author: Gaurav Saini (13 Oct, 2017)
 */
public with sharing class ReferenceProfileFormController extends RefEdgeEditionFeatures {
    
    private static Custom_Settings__c cs = UtilityController.getCustomSettings();
    public String accountId { get; set; }
    public String contactId { get; set; }
    public String pageNo { get; set; }
    public String showMore { get; set; }
    public String userId { get; set; }
    public Boolean isSLDS { get; set; }
    public Boolean isFromProfileUpdate { get; set; }
    
    public ReferenceProfileFormController() {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
    	accountId = ApexPages.currentPage().getParameters().get('PUMAccId') != null
    				? ApexPages.currentPage().getParameters().get('PUMAccId') : '';
    	contactId = ApexPages.currentPage().getParameters().get('PUMConId') != null
    				? ApexPages.currentPage().getParameters().get('PUMConId') : '';
    	pageNo = ApexPages.currentPage().getParameters().get('pageNo');
    	showMore = ApexPages.currentPage().getParameters().get('showMore');
		userId = ApexPages.currentPage().getParameters().get('userId');
		isFromProfileUpdate = ApexPages.currentPage().getParameters().get('pageNo') != null
								? true : false;
    }
    
    /**
     * method to get account and contact details
     * author: Gaurav Saini (13 Oct, 2017)
     */
    @RemoteAction
    public static String getAccountContactDetails(String accId, String conId) {
    	List<Account> accList = [SELECT Id, Name FROM Account WHERE Id = :accId];
    	List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conId];
    	String result = '';
    	
    	for (Account acc : accList) {
    		result = result + acc.Name;
    	}
    	
    	for (Contact con : conList) {
    		result = result + '@@@' + con.Name;
    	}
    	return result;
    }
    
    /**
     * method to get data mappings list for reference profile form
     * author: Gaurav Saini (13 Oct, 2017)
     */
    @RemoteAction
    public static String getDataMappingsList() {
    	List<DataMappingWrapper> dataMappingWrapperList = new List<DataMappingWrapper>();
    	List<Data_Mapping__c> dataMappingsList = [SELECT Visible__c, Required__c, Referenceability_Type__c, Order__c,
			            							Object__c, Name, Label__c, Id, Filter__c, Field_API_Name__c
			            							FROM Data_Mapping__c
			            							WHERE Object__c = :ConstantsController.REFERENCE_PROFILE_FORM
			            							AND Visible__c = true
			            							ORDER BY Order__c];
        
    	for (Data_Mapping__c dm : dataMappingsList) {
    		dataMappingWrapperList.add(new DataMappingWrapper(dm));
    	}
    	return JSON.serialize(dataMappingWrapperList);
    }
    
    /**
     * method to get a map of filters and associated attributes
     * author: Gaurav Saini (13 Oct, 2017)
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
     * method to get list of referenceability types
     * author: Gaurav Saini (13 Oct, 2017)
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
     * method to save the reference profile
     * author: Gaurav Saini (13 Oct, 2017)
     */
    @RemoteAction
    public static String saveRefProfile(String accId, String conId, String accName, String conName,
    									String filterAttributesMapJSON, String refTypeIdsJSON, String comments) {
    	Savepoint sp = Database.setSavepoint();
    	String result = '';
    	
    	try {
    		Map<String, List<String>> filterAttributesMap
	    				= (Map<String, List<String>>)JSON.deserialize(filterAttributesMapJSON, Map<String, List<String>>.class);
	    	List<String> refTypeIds = (List<String>)JSON.deserialize(refTypeIdsJSON, List<String>.class);
    		result = createRefProfile(accId, conId, accName, conName, filterAttributesMap, refTypeIds);
    		
    		if (comments != null && comments.trim().length() > 0) {
    			Reference_Note__c refNote = new Reference_Note__c();
    			refNote.Contact__c = conId;
    			refNote.Note__c = comments;
    			WithoutSharingHelperController.insertReferenceNotes(new List<Reference_Note__c> { refNote });
    		}
    	} catch(Exception e) {
    		Database.rollback(sp);
            result = 'Error!' + ' ' + e.getMessage();
    	}
    	return result;
    }
    
    /**
     * method to create the reference profile for the selected account/contact
     * author: Gaurav Saini (13 Oct, 2017)
     */
    private static String createRefProfile(String accountId, String contactId, String accName, String conName,
								Map<String, List<String>> filterAttributesMap, List<String> refTypeIds) {
    	String saveResult = '';
    	List<Reference_Basic_Information__c> upsertNewRBI = new List<Reference_Basic_Information__c>();
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
        
        if (contactId == null || contactId == '') {
            Reference_Basic_Information__c rbi;
            List<Reference_Basic_Information__c> rbis = [SELECT Id, Referenceability_Status__c, Is_Referenceable__c
            												FROM Reference_Basic_Information__c
            												WHERE Account__c = :accountId
            												AND Contact__c = null];
            
            if (rbis.size() == 0) {
                upsertNewRBI.add(new Reference_Basic_Information__c(Account__c = accountId != null ? accountId : null,
                									Referenceability_Status__c = cs.Default_Referenceablity_Status__c,
                									Is_Referenceable__c = true));
            } else {
                rbi = rbis[0];
                rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                rbi.Is_Referenceable__c = true;
                upsertNewRBI.add(rbi);
            }
            upsertNewRBI = WithoutSharingHelperController.upsertRBI(upsertNewRBI);
            createRefProfileChatter(upsertNewRBI[0], new Reference_Basic_Information__c(), accName, '', cs.Profile_Created_Email__c, cs.Profile_Created_Chatter__c, cs.Enable_Slack_Integration__c && cs.Profile_Created_Slack__c);
            createRefProfileAttributes(upsertNewRBI[0], new Reference_Basic_Information__c(), accountId, contactId, filterAttributesMap);
            createRefProfileReferenceability(upsertNewRBI[0], new Reference_Basic_Information__c(), accountId, contactId, cs, refTypeIds);
        } else {
            List<Reference_Basic_Information__c> rbis = [SELECT Id, Referenceability_Status__c, Reference_Program_Candidate__c,
	    													Is_Referenceable__c, Contact__c, Roll_up_Referenceability_to_All_Accounts__c,
	    													Roll_up_Referenceability_to_Primary_Acc__c
	    													FROM Reference_Basic_Information__c
	    													WHERE (Account__c = :accountId AND Contact__c = null)
	    													OR (Contact__c = :contactId AND Contact__c != null)];
            Reference_Basic_Information__c accRbi, conRbi;
            
            if (rbis.size() == 0) {
                conRbi = new Reference_Basic_Information__c(Contact__c = contactId != '' ? contactId : null,
                											Account__c = accountId != '' ? accountId : null,
                											Referenceability_Status__c = cs.Default_Referenceablity_Status__c,
                											Is_Referenceable__c = true);
                upsertNewRBI.add(conRbi);
                accRbi = new Reference_Basic_Information__c(Account__c = accountId != '' ? accountId : null,
                											Referenceability_Status__c = cs.Default_Referenceablity_Status__c,
                											Is_Referenceable__c = true);
                upsertNewRBI.add(accRbi);
            } else { 
            	
                for (Reference_Basic_Information__c rbi : rbis) {
                	
                    if (rbi.Contact__c != null) {
                        conRbi = rbi;
                        conRbi.Reference_Program_Candidate__c = false;
                        conRbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                        conRbi.Is_Referenceable__c = true;
                        upsertNewRBI.add(conRbi);
                    } else {
                        accRbi = rbi;
                        // commented for #1090 - Gaurav Saini (26 Oct, 2017)
                        /*
                        accRbi.Reference_Program_Candidate__c = false;
                        accRbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                        accRbi.Is_Referenceable__c = true;
                        upsertNewRBI.add(accRbi);
                        */
                    }
                }
                
                if (accRbi == null) {
                    accRbi = new Reference_Basic_Information__c(Account__c = accountId != '' ? accountId : null,
                    											Referenceability_Status__c = cs.Default_Referenceablity_Status__c,
                    											Is_Referenceable__c = true);
                    upsertNewRBI.add(accRbi);
                }
                
                if (conRbi == null) {
                    conRbi = new Reference_Basic_Information__c(Contact__c = contactId != '' ? contactId : null,
                    											Account__c = accountId != '' ? accountId : null,
                    											Referenceability_Status__c = cs.Default_Referenceablity_Status__c,
                    											Is_Referenceable__c = true);
                    upsertNewRBI.add(conRbi);
                }
            }
            upsertNewRBI = WithoutSharingHelperController.upsertRBI(upsertNewRBI);
            createRefProfileChatter(accRbi, conRbi, accName, conName, cs.Profile_Created_Email__c, cs.Profile_Created_Chatter__c, cs.Enable_Slack_Integration__c && cs.Profile_Created_Slack__c);
            createRefProfileAttributes(accRbi, conRbi, accountId, contactId, filterAttributesMap);
            createRefProfileReferenceability(accRbi, conRbi, accountId, contactId, cs, refTypeIds);
        }
    	return 'success';
    }
    
    /**
     * Method to create referenceabilities
     */
    private static void createRefProfileReferenceability(Reference_Basic_Information__c accRbi,
    											Reference_Basic_Information__c conRbi, String accountId, String contactId,
    											Custom_Settings__c cs, List<String> refTypeIds) {
        Set<String> referenceabilityTypePresent = new Set<String>();
        Set<String> newReferenceabilityType = new Set<String>();
        List<Referenceability__c> newReferenceabilities = new List<Referenceability__c>();
        Map<Id, Reference_Basic_Information__c> accMap = new Map<Id, Reference_Basic_Information__c>();
        
        if (conRbi.Id != null) {
        	
            for (Referenceability__c ref : [SELECT Referenceability_Type__c FROM Referenceability__c
            								WHERE Status__c = 'Approved'
            								AND Contact__c = :contactId]) {
                referenceabilityTypePresent.add(ref.Referenceability_Type__c);
            }
            // shared contact code start
            Set<String> accountsIds = new Set<String>();
            
            if (contactId != null && contactId != '' && cs.Shared_Contacts__c && conRbi != null
            			&& conRbi.Referenceability_Status__c != '' && conRbi.Referenceability_Status__c != 'Inactive') {
                Boolean addRefToAllAccountsRBI = (conRbi.Roll_up_Referenceability_to_All_Accounts__c
        											? true
        											: (conRbi.Roll_up_Referenceability_to_Primary_Acc__c
        												? false
        												: (cs.Roll_up_Referenceability_to_All_Accounts__c)));
                
                if (addRefToAllAccountsRBI) {
                    Map<String, Set<String>> contactAccountMap = WithoutSharingHelperController.getRelatedAccounts(new Set<String>{contactId}, cs);
                    
                    if (contactAccountMap != null && contactAccountMap.size() > 0
                    			&& contactAccountMap.containsKey(contactId)) {
                        accountsIds.addAll(contactAccountMap.get(contactId));
        			}
                }
                
                if (accountsIds.size() > 0) {
                	accMap = WithoutSharingHelperController.getSharedAccountsRBI(accountsIds);
                }
            }
            // end
            
            for (String refTypeId : refTypeIds) {
                
                if (!referenceabilityTypePresent.contains(refTypeId)) {
                    Referenceability__c newRefer = new Referenceability__c();
                    newRefer.Contact__c = contactId != '' ? contactId : null;
                    
                    if (cs.Default_Referenceablity_Status__c == ConstantsController.ACTIVE
                    			|| cs.Default_Referenceablity_Status__c == ConstantsController.CAUTION) {
                        newRefer.Account__c = accountId != '' ? accountId : null;
        			}
                    newRefer.Status__c = 'Approved';
                    newRefer.Verified__c = system.today();
                    newRefer.Referenceability_Type__c = refTypeId;
                    newReferenceabilities.add(newRefer);
                    
                    // shared contact code start
                    for (String accId : accountsIds) {
                    	
                        if (accId != accountId && accMap != null && accMap.containsKey(accId)
                        			&& (accMap.get(accId).Is_Referenceable__c
                        				|| accMap.get(accId).Reference_Program_Candidate__c)) {
                            newRefer = new Referenceability__c();
                            newRefer.Contact__c = contactId != '' ? contactId : null;
                            
                            if (cs.Default_Referenceablity_Status__c == ConstantsController.ACTIVE
                            			|| cs.Default_Referenceablity_Status__c == ConstantsController.CAUTION) {
                                newRefer.Account__c = accId;
                			}
                            newRefer.Status__c = 'Approved';
                            newRefer.Verified__c = system.today();
                            newRefer.Referenceability_Type__c = refTypeId;
                            newReferenceabilities.add(newRefer);
                        }
                    }	// end
                }
            }
        } else {
        	
            for (Referenceability__c ref : [SELECT Referenceability_Type__c FROM Referenceability__c
            									WHERE Status__c = 'Approved'
            									AND Account__c = :accountId]) {
                referenceabilityTypePresent.add(ref.Referenceability_Type__c);
            }
            
            for (String refTypeId : refTypeIds) {
            	
                if (!referenceabilityTypePresent.contains(refTypeId)) {
                    Referenceability__c newRefer = new Referenceability__c();
                    newRefer.Account__c = accountId != '' ? accountId : null;
                    newRefer.Status__c = 'Approved';
                    newRefer.Verified__c = system.today();
                    newRefer.Referenceability_Type__c = refTypeId;
                    newReferenceabilities.add(newRefer);
                }
            }
        }
        
        if (newReferenceabilities.size() > 0) {
        	newReferenceabilities = WithoutSharingHelperController.upsertReferenceabilities(newReferenceabilities);
        }
    }
    
    /**
     * Method to create chatter post for Reference Profile
     */
    private static void createRefProfileChatter(Reference_Basic_Information__c rbi, Reference_Basic_Information__c crbi,
    											String accountName, String conName, Boolean checkEmailSetting, Boolean checkChatterSetting, Boolean checkSlackSetting) {
    	String rbiNominationLink = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        
		//REF-1316- Added check for CRP team member should be active								 
		List<User> publicGroupMembers = UtilityController.getCustomerReferenceTeam();
        List<sObject> postFeedItems = new List<sObject>();
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c profileCreatedNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Profile_Created_Email__c'};

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Profile_Created_Email__c') {
                profileCreatedNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());
        List<Map<String, String>> messagesList = new List<Map<String, String>>();
        String body = profileCreatedNotification.DC_Message__c + '\n\n' + profileCreatedNotification.Default__c;
        body = body.replace('[Account Name]', accountName)
                    .replace('[Creator Name]', Userinfo.getName());
        
        if (conName != null && conName != '') {
	        body = body.replace('[Contact Name]', conName);
        } else {
	        body = body.replace('Contact: [Contact Name]\n', '');
        }
        
        if (UtilityController.isNativeChatterSetting && checkChatterSetting) {
        	
            for (User gm : publicGroupMembers) {
                String userId = gm.Id;
                
                if (userId.startsWith('005')) {
                    postFeedItems.add(MailChatterController.preparePost(profileCreatedNotification.Section_Name__c, userId, body, rbiNominationLink + (conName != '' ? crbi.Id : rbi.Id)));
                }
            }
        }
        
        if (checkEmailSetting) {

            for (User gm : publicGroupMembers) {
                String userId = gm.Id;
                
                if (userId.startsWith('005')) {
                    listmail.add(MailChatterController.prepareEmail(profileCreatedNotification.Section_Name__c, userId, body + '\n\n' + profileCreatedNotification.Section_Name__c + '<a href="' + rbiNominationLink + (conName != '' ? crbi.Id : rbi.Id) + '">' + rbiNominationLink + (conName != '' ? crbi.Id : rbi.Id) + '</a>', true, headerDocId, footerDocId));
                }
            }
        }
        
        if (checkSlackSetting) {
            Map<String, String> tempReqBodyMap = new Map<String, String>();
            tempReqBodyMap.put('text', body
                    + '\n<' + rbiNominationLink + (conName != '' ? crbi.Id : rbi.Id) + '|'
                    + profileCreatedNotification.Section_Name__c + '>');
            messagesList.add(tempReqBodyMap);
        }
        
        if (postFeedItems.size() > 0) {
            postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
        }
        
        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
    }
    
    /**
     * Method to create Attributes 
     */
    private static void createRefProfileAttributes(Reference_Basic_Information__c accRbi,
										Reference_Basic_Information__c conRbi, String accountId, String contactId,
										Map<String, List<String>> filterAttributesMap) {
        List<Account_Attribute__c> accAtts = new List<Account_Attribute__c>();
        List<Contact_Attribute__c> conAtts = new List<Contact_Attribute__c>();
        Set<String> attributesAssociatedIds = new Set<String>();
        Set<String> attribIdsToBeCreated = new Set<String>();
        Set<String> filtersToExclude = new Set<String>();
        Map<String, Set<String>> filterAttributes = new Map<String, Set<String>>();
        
        if (conRbi.Id != null) {
        	
            for (Contact_Attribute__c conAtt : WithoutSharingHelperController.getContactAttribute3(new Set<Id>{contactId})) {
                attributesAssociatedIds.add(conAtt.Attribute__c);
            }
            
            for (Attributes_Labels__c attLabel : [SELECT Label__r.Name, Attribute__c FROM Attributes_Labels__c
            										WHERE Attribute__c IN :attributesAssociatedIds]) {
            	
                if (!filterAttributes.containsKey(attLabel.label__r.Name)) {
                    filterAttributes.put(attLabel.label__r.Name, new Set<String>());
                }
                filterAttributes.get(attLabel.label__r.Name).add(attLabel.Attribute__c);
            }
            
            for (String filterName : filterAttributesMap.keySet()) {
                
                if (!filterAttributes.containsKey(filterName)) {
                	
                    for (String attId : filterAttributesMap.get(filterName)) {
                    	
                        if (!attributesAssociatedIds.contains(attId)) {
                            attribIdsToBeCreated.add(attId);
                        }
                    }
                }
            }
            
            for (String attId : attribIdsToBeCreated) {
                conAtts.add(new Contact_Attribute__c(Contact__c = contactId != '' ? contactId : null, Attribute__c = attId));
            }
            
            if (conAtts.size() > 0) {
                conAtts = WithoutSharingHelperController.upsertContactAttributes(conAtts);
            }
        } else {
        	
            for (Account_Attribute__c accAtt : WithoutSharingHelperController.getAccountAttribute3(new Set<Id>{accountId})) {
                attributesAssociatedIds.add(accAtt.Attribute__c);
            }
            
            for (Attributes_Labels__c attLabel : [SELECT Label__r.Name, Attribute__c FROM Attributes_Labels__c
    												WHERE Attribute__c IN :attributesAssociatedIds]) {
            	
                if (!filterAttributes.containsKey(attLabel.label__r.Name)) {
                    filterAttributes.put(attLabel.label__r.Name, new Set<String>());
                }
                filterAttributes.get(attLabel.label__r.Name).add(attLabel.Attribute__c);
            }
            
            for (String filterName : filterAttributesMap.keySet()) {
                
                if (!filterAttributes.containsKey(filterName)) {
                	
                    for (String attId : filterAttributesMap.get(filterName)) {
                    	
                        if (!attributesAssociatedIds.contains(attId)) {
                            attribIdsToBeCreated.add(attId);
                        }
                    }
                }
            }
            Map<String, Set<String>> attribParentIdsMap = new Map<String, Set<String>>();
            Map<String, Boolean> attributeInheritable = new Map<String, Boolean>();
            Set<String> parentAttIds = new Set<String>();
            Map<String, String> attIdNameMap = new Map<String, String>();
            Set<String> tempSet = new Set<String>();
            
            for (Attribute__c att : [SELECT ParentIds__c, Name, Id
            							FROM Attribute__c
            							WHERE Id IN :attribIdsToBeCreated]) {
                tempSet = new Set<String>();
                
                if (att.ParentIds__c != null) {
                    tempSet.addAll(att.ParentIds__c.split(','));
                }
                parentAttIds.addAll(tempSet);
                attribParentIdsMap.put(att.Id, tempSet);
            }
            
            for (Attribute__c att : [SELECT Id, Inheritable__c FROM Attribute__c
            							WHERE Id IN :parentAttIds AND Level__c = 0]) {
            	
                for (String attKey : attribParentIdsMap.keySet()) {
                	
                    if (attribParentIdsMap.get(attKey).contains(att.Id)) {
                        attributeInheritable.put(attKey, att.Inheritable__c);
                    }
                }
            }
            
            for (String attId : attribIdsToBeCreated) {
                accAtts.add(new Account_Attribute__c(Account__c = accountId != '' ? accountId : null,
        										Attribute__c = attId, Inheritable__c = attributeInheritable.get(attId)));
            }
            
            if (accAtts.size() > 0) {
                accAtts = WithoutSharingHelperController.upsertAccountAttributes(accAtts);
            }
        }
    }
    
    public class DataMappingWrapper {
    	public String dataMappingId { get; set; }
    	public String dataMappingName { get; set; }
    	public String fieldAPIName { get; set; }
    	public Integer orderNo { get; set; }
    	public Boolean visible { get; set; }
    	public Boolean required { get; set; }
    	public String refTypeId { get; set; }
    	public Boolean isHeader { get; set; }
    	public String filterId { get; set; }
    	
    	public DataMappingWrapper(Data_Mapping__c dm) {
    		this.dataMappingId = dm.Id;
    		this.dataMappingName = dm.Name != null ? dm.Name : '';
    		this.fieldAPIName = dm.Field_API_Name__c != null ? dm.Field_API_Name__c : '';
    		this.orderNo = Integer.valueOf(dm.Order__c) != null ? Integer.valueOf(dm.Order__c) : -1;
    		this.visible = dm.Visible__c;
    		this.required = dm.Required__c;
    		this.refTypeId = dm.Referenceability_Type__c != null ? (String)dm.Referenceability_Type__c : '';
    		this.isHeader = dm.Field_API_Name__c != null && dm.Filter__c == null && dm.Referenceability_Type__c == null
    						? true : false;
    		this.filterId = dm.Filter__c != null ? (String)dm.Filter__c : '';
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
    		this.refTypeLimitedTo = rt.Ref_Limit_to_Acct_or_Cntct__c != null ? rt.Ref_Limit_to_Acct_or_Cntct__c : '';
    	}
    }
}