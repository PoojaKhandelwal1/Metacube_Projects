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
 * VF Page: RefedgeCommunityHome.page
 * Description: controller for community home page
 * Last modified by: Gaurav Saini (14 Feb, 2017)
 */
public with sharing class RefedgeCommunityHome extends RefEdgeEditionFeatures  {
    
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage(String action) {
    	String errorMsg = '';
		checkPermissions(action);
		
    	if (ApexPages.getMessages() != null && ApexPages.getMessages().size() > 0) {
			
			for (ApexPages.Message pgMsg : ApexPages.getMessages()) {
				errorMsg = (errorMsg == '') ? pgMsg.getSummary() : errorMsg + '\n' + pgMsg.getSummary();
			}
			POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
			errorMsg = 'Additional permissions need to be added to your profile so that you can update all your information. '
						+ 'Please copy and paste this message and send to '
						+ (String)appConfig.Community_Admin_Email_Address__c
						+ '\n' + errorMsg;
		}
		return errorMsg;
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(String action) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        
        if (action == 'pageLoad') {
        	fieldMap.put('Contact', new Set<String>());
	        
	        for (Schema.FieldSetMember field : SObjectType.Contact.FieldSets.RefEdgeCommunityFieldSetLeft.getFields()) {
	        	
	        	if (field.getFieldPath() != 'Name') {
		        	fieldMap.get('Contact').add(field.getFieldPath());
	        	}
	        }
	        
	        for (Schema.FieldSetMember field : SObjectType.Contact.FieldSets.RefEdgeCommunityFieldSetRight.getFields()) {
	        	
	        	if (field.getFieldPath() != 'Name') {
		        	fieldMap.get('Contact').add(field.getFieldPath());
	        	}
	        }
	        fieldMap.put(UtilityController.appNamespace() + 'Community_Invite_Contact__c',
	    										new Set<String>{UtilityController.appNamespace() + 'Response__c'});
			fieldMap.put(UtilityController.appNamespace() + 'Referenceability__c',
	    										new Set<String>{UtilityController.appNamespace() + 'Status__c',
	    											UtilityController.appNamespace() + 'Verified__c',
	    											UtilityController.appNamespace() + 'Referenceability_Type__c',
	    											UtilityController.appNamespace() + 'Account__c',
	        										UtilityController.appNamespace() + 'Contact__c'});
        } else if (action == 'saveContact') {
        	fieldMap.put('Contact', new Set<String>());
	        
	        for (Schema.FieldSetMember field : SObjectType.Contact.FieldSets.RefEdgeCommunityFieldSetLeft.getFields()) {
	        	
	        	if (field.getFieldPath() != 'Name') {
		        	fieldMap.get('Contact').add(field.getFieldPath());
	        	}
	        }
	        
	        for (Schema.FieldSetMember field : SObjectType.Contact.FieldSets.RefEdgeCommunityFieldSetRight.getFields()) {
	        	
	        	if (field.getFieldPath() != 'Name') {
		        	fieldMap.get('Contact').add(field.getFieldPath());
	        	}
	        }
	        fieldMap.put(UtilityController.appNamespace() + 'Referenceability__c',
	    										new Set<String>{UtilityController.appNamespace() + 'Status__c',
	    											UtilityController.appNamespace() + 'Verified__c',
	    											UtilityController.appNamespace() + 'Referenceability_Type__c',
	    											UtilityController.appNamespace() + 'Account__c',
	        										UtilityController.appNamespace() + 'Contact__c'});
        } else if (action == 'saveInvite') {
        	fieldMap.put(UtilityController.appNamespace() + 'Community_Invite_Contact__c',
	    										new Set<String>{UtilityController.appNamespace() + 'Response__c'});
        }
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
        return isUpsertPermission;
    }
    
    /**
     * method to get contact id of the commuity user
     */
    @RemoteAction
    public static String getContactId() {
        List<User> userList = [SELECT Name, Id, AccountId, ContactId, Contact.Name, Contact.Email
        							FROM User WHERE Id = :UserInfo.getUserId() AND UserType != 'Guest'];
        return userList.get(0).ContactId;
    }
    
    public static String pageId {
        get {
            
            if (ApexPages.currentPage().getParameters().get('Id') != null
            			&& ApexPages.currentPage().getParameters().get('Id') != '') {
                return ApexPages.currentPage().getParameters().get('Id');
            }
            return '';
        }
        set;
    }
    
    public static String pageresponse {
        get {
        	
            if (ApexPages.currentPage().getParameters().get('response') != null
            			&& ApexPages.currentPage().getParameters().get('response') != '') {
                return ApexPages.currentPage().getParameters().get('response');
            }
            return '';
        }
        set;
    }
    
    public static Date todayDate {
        get {
            return date.Today();
        }
        set;
    }
    
    /**
     * method to disposition the invitation
     * this method is called when user clicks "I'm in" or "No thanks" button
     */
    @RemoteAction
    public static String acceptRejectinvitation(String inviteId, String contactId, String response) {
		Savepoint sp = Database.setSavepoint(); 
		
        try {
        	
            if (contactId != null && contactId != '') {
                List<Community_Invite_Contact__c> newCICrecords = new List<Community_Invite_Contact__c>();
                
                for (Community_Invite_Contact__c cic : communityInviteContacts(contactId)) {
                	
                    if (inviteId != null && inviteId != ''
                    			&& cic.Community_Invite__c == inviteId
                    			&& cic.Contact__c == contactId) {
                        cic.Response__c = response;
                        newCICrecords.add(cic);
                    }
                }
                
                if (deadLineReachedComInvite != null && deadLineReachedComInvite.size() > 0) {
                	
                    for (Community_Invite_Contact__c cic : deadLineReachedComInvite) {
                        cic.Response__c = 'No Response';
                        newCICrecords.add(cic);
                    }
                }
                
                if (newCICrecords.size() > 0) {
                    RefedgeCommunityWithoutSharing.upsertCommunityInviteContact(newCICrecords);
                }
            }
            return 'success';
        } catch(DMLException e) {
            Database.rollback(sp);
            return e.getDmlMessage(0);
        } catch(Exception e) {
            Database.rollback(sp);
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return e.getMessage();
        }
        return '';
    }
    
    /**
     * method to check whether the contact is a program member or not
     */
    @RemoteAction
    public static Boolean isRefedgeProgramMember(String contactId) {
        List<Reference_Basic_Information__c> referenceProfileContact
        			= RefedgeCommunityWithoutSharing.getReferenceProfileContactList(contactId);
        Boolean isRefedgeProgramMember = (referenceProfileContact.size() > 0
        									? ((referenceProfileContact[0].Referenceability_Status__c == 'Active'
    												|| referenceProfileContact[0].Referenceability_Status__c == 'Caution')
    											&& referenceProfileContact[0].Is_Referenceable__c)
											: false);
        return isRefedgeProgramMember;
    }
    
    private static List<Community_Invite_Contact__c> deadLineReachedComInvite;
    
    /**
     * list to store all the active community invites displayed on the community home page
     */
    private static List<Community_Invite_Contact__c> communityInviteContacts(String contactId) {
        Set<String> CommunityInviteIds = new Set<String>();
        deadLineReachedComInvite = new List<Community_Invite_Contact__c>();
        List<Community_Invite_Contact__c> communityInviteContacts = new List<Community_Invite_Contact__c>();
        
        for (Community_Invite_Contact__c cic : RefedgeCommunityWithoutSharing.getCommunityInviteContacts(contactId)) {
            CommunityInviteIds.add(cic.Community_Invite__c);
        }
        
        for (Community_Invite__c ci : RefedgeCommunityWithoutSharing.getCommunityInvites(contactId, CommunityInviteIds)) {
            Integer totalYesResponseNeeded = ci.Hit_Lists__r.size() + ci.Account_Requests__r.size()
            									+ ci.Unspecified_Requests__r.size();
            
            if (ci.Community_Participate_Deadline__c >= date.today() && ci.Community_Yes__c < totalYesResponseNeeded) {
            	
                if (ci.Community_Invite_Contacts__r.size() > 0) {
                	
                    for (Community_Invite_Contact__c cic : ci.Community_Invite_Contacts__r) {
                    	
                        if (cic.Response__c == null) {
                            communityInviteContacts.add(cic);
                        }
                    }
                }
            }
            
            if (ci.Community_Participate_Deadline__c < date.today() && ci.Community_Yes__c < totalYesResponseNeeded) {
            	
                for (Community_Invite_Contact__c cic : ci.Community_Invite_Contacts__r) {
                	
                    if (cic.Response__c == null) {
                        deadLineReachedComInvite.add(cic);
                    }
                }
            }
        }
        return communityInviteContacts;
    }
    
    /**
     * method to get the contact record
     */
    @RemoteAction
    public static String getContact(String contactId) {
        List<Contact> contacts = RefedgeCommunityWithoutSharing.getContacts(contactId);
        
        if (contacts.size() > 0) {
            return JSON.serialize(contacts[0]);
        }
        return '';
    }
    
    /**
     * method to get the left side fields for the contact details view/edit section
     */
    @RemoteAction
    public static String getLeftFields(String contact1) {
        Contact con = new Contact();
        con = (Contact)JSON.deserialize(contact1, Contact.class);
        List<FieldWrapper> leftSideFields = new List<FieldWrapper>();
        List<Schema.FieldSetMember> Fields = SObjectType.Contact.FieldSets.RefEdgeCommunityFieldSetLeft.getFields();
        Map<String, Schema.SObjectField> contactField_map = Schema.sObjectType.Contact.fields.getMap();
        
        for (Schema.FieldSetMember sf : Fields) {
            Schema.DescribeFieldResult dfr = contactField_map.get(sf.getFieldPath()).getDescribe();
            
            if (dfr.isAccessible() && sf.getFieldPath() != 'AccountId' && sf.getFieldPath() != 'Name') {
                leftSideFields.add(new FieldWrapper(dfr.getLabel(),
        											sf.getFieldPath(),
        											String.valueOf(dfr.getType()),
        											String.valueOf(dfr.isUpdateable()),
        											''));
            } else if (dfr.isAccessible() && sf.getFieldPath() == 'AccountId') {
                leftSideFields.add(new FieldWrapper('Company',
                									'AccountId',
                									'REFERENCE',
                									'false',
                									(String)(con != null && con.getSobject(dfr.getRelationshipName()) != null
                										? con.getSobject(dfr.getRelationshipName()).get('Name') : '')));
            } else if (dfr.isAccessible() && sf.getFieldPath() == 'Name') {
                leftSideFields.add(new FieldWrapper('Full Name',
                									'Name',
                									String.valueOf(dfr.getType()),
                									String.valueOf(dfr.isUpdateable()), ''));
                leftSideFields.add(new FieldWrapper('First Name',
                									'FirstName',
                									String.valueOf(dfr.getType()),
                									String.valueOf(contactField_map.get('FirstName').getDescribe().isUpdateable()),
                									''));
                leftSideFields.add(new FieldWrapper('Last Name',
                									'LastName',
                									String.valueOf(dfr.getType()),
                									String.valueOf(contactField_map.get('LastName').getDescribe().isUpdateable()),
                									''));
            }
        }
        return JSON.serialize(leftSideFields);
    }
    
    /**
     * method to get the list of referenceability types for contact profile section
     */
    @RemoteAction
    public static String getRefTypeWrapperList(String contact1) {
        Contact con = new Contact();
        con = (Contact)JSON.deserialize(contact1, Contact.class);
        
        try {
            List<RefTypeWrapper> refTypeWrapperList = new List<RefTypeWrapper>();
            List<Referenceability_Type__c> refTypeList = RefedgeCommunityWithoutSharing.getReferenceabilityType();
            Integer size = refTypeList.size();
            Integer line = size / 3;
            Integer mod = math.mod(size, 3);
            List<Referenceability_Type__c> templist = new List<Referenceability_Type__c>();
            
            for (Integer i = 0; i <= line; i++) {
            	
                if (mod == 0) {
                	
                    if (i != line) {
                        templist.add(refTypeList.get(i));
                        templist.add(refTypeList.get(i + line));
                        templist.add(refTypeList.get(i + line + line));
                    }
                } else if (mod == 1) {
                    templist.add(refTypeList.get(i));
                    
                    if (i != line) {
                        templist.add(refTypeList.get(i + line + 1));
                        templist.add(refTypeList.get(i + line + line + 1));
                    }
                } else if (mod == 2) {
                    templist.add(refTypeList.get(i));
                    templist.add(refTypeList.get(i + line + 1));
                    
                    if (i != line) {
                        templist.add(refTypeList.get(i + line + line + 2));
                    }
                }
            }
            refTypeList = templist;
            Set<String> refPresent = new Set<String>();
            
            for (Referenceability__c ref : con.Referenceabilities__r) {
            	
                if (ref.Status__c == 'Approved') {
                    refPresent.add(ref.Referenceability_Type__c);
                }
            }
            
            for (Referenceability_Type__c ref : refTypeList) {
            	
                if (refPresent.contains(ref.Id)) {
                    refTypeWrapperList.add(new RefTypeWrapper(true, ref));
                } else {
                    refTypeWrapperList.add(new RefTypeWrapper(false, ref));
                }
            }
            return JSON.serialize(refTypeWrapperList);
        } catch(Exception e) {
            return null;
        }
    }
    
    /**
     * method to save the contact details
     */
    @RemoteAction
    public static String saveContact(String contactObj, String refTypeWrapperJSON) {
        refTypeWrapperJSON = refTypeWrapperJSON.remove(',[]');
        String errMsg = 'Error' + ' ';
        
        try {
            Map<String, Referenceability__c> referenceabilitiesPresent = new Map<String, Referenceability__c>();
            Contact contact1 = new Contact();
            contact1 = (Contact)JSON.deserialize(contactObj, Contact.class);
            
            for (Referenceability__c ref : contact1.Referenceabilities__r) {
                referenceabilitiesPresent.put(ref.Referenceability_Type__c, ref);
            }
            List<Referenceability__c> upsertReferenceabilities = new List<Referenceability__c>();
            List<RefTypeWrapper> refTypeWrapperList
            			= (List<RefTypeWrapper>)JSON.deserialize(refTypeWrapperJSON, List<RefTypeWrapper>.class);
            RefedgeCommunityWithoutSharing.updateContact(contact1);
            // shared contact code start
	        Custom_Settings__c cs = UtilityController.getCustomSettings();
	        List<Reference_Basic_Information__c> rbiList
	        			= RefedgeCommunityWithoutSharing.getReferenceProfileContactList(contact1.Id);
	        Reference_Basic_Information__c conRbi = (rbiList.size() > 0
        												? rbiList[0]
        												: new Reference_Basic_Information__c());
	        Set<String> accountsIds = new Set<String>();
	        
	        if (contact1.Id != null && cs.Shared_Contacts__c) {
	        	Boolean addRefToAllAccountsRBI = (conRbi.Roll_up_Referenceability_to_All_Accounts__c
	        										? true
	        										: (conRbi.Roll_up_Referenceability_to_Primary_Acc__c
	        											? false
	        											: (cs.Roll_up_Referenceability_to_All_Accounts__c)));
				
				if (addRefToAllAccountsRBI) {
		            accountsIds = RefedgeCommunityWithoutSharing.getRelatedAccounts(contact1.Id, cs); 
				}
	        }
	        // end
	        
            for (RefTypeWrapper rtw : refTypeWrapperList) {
            	
                if (rtw.isSelected) {
                	
                    if (!referenceabilitiesPresent.containsKey(rtw.refType.Id)) {
                        upsertReferenceabilities.add(new Referenceability__c(Referenceability_Type__c = rtw.refType.Id,
            														Status__c = 'Approved',
            														Verified__c = date.today(),
            														Contact__c = contact1.Id,
            														Account__c = (contact1.AccountId != null
            															? contact1.AccountId : '')));
                        
                        // shared contact code start
		                for (String accId : accountsIds) {
		                    upsertReferenceabilities.add(new Referenceability__c(Referenceability_Type__c = rtw.refType.Id,
		                    										Status__c = 'Approved',
		                    										Verified__c = date.today(),
		                    										Contact__c = contact1.Id,
		                    										Account__c = accId));
		                }
		                // end
                    } else {
                        Referenceability__c tempRef = referenceabilitiesPresent.get(rtw.refType.Id);
                        tempRef.Status__c = 'Approved';
                        tempRef.Verified__c = date.today();
                        upsertReferenceabilities.add(tempRef);
                    }
                } else {
                    
                    if (referenceabilitiesPresent.containsKey(rtw.refType.Id)) {
                        Referenceability__c tempRef = referenceabilitiesPresent.get(rtw.refType.Id);
                        tempRef.Status__c = 'Declined: Unknown reason';
                        tempRef.Verified__c = date.today();
                        upsertReferenceabilities.add(tempRef);
                    }
                }
            }
            
            if (upsertReferenceabilities.size() > 0 ) {
                RefedgeCommunityWithoutSharing.upsertReferenceability(upsertReferenceabilities);
            }
            return JSON.serialize(contact1);
        } catch (DMLException e) {
            errMsg += e.getDmlMessage(0);
            return errMsg;
        } catch (Exception e) {
            errMsg += e.getMessage();
            return errMsg;
        }
        return null;
    }
    
    /**
     * method to get the contact birth date
     */
    @RemoteAction
    public static String getBirthday(String contact1) {
        Contact con = new Contact();
        con = (Contact)JSON.deserialize(contact1, Contact.class);
        Date birthdayDate = con.Birthdate;
        
        if (birthdayDate != null) {
            return (birthdayDate.month() + '/' + birthdayDate.day());
        }
        return '';
    }
    
    /**
     * method to get the right side fields for the contact details view/edit section
     */
    @RemoteAction
    public static String getRightFields() {
        List<FieldWrapper> rightSideFields = new List<FieldWrapper>();
        List<Schema.FieldSetMember> Fields = SObjectType.Contact.FieldSets.RefEdgeCommunityFieldSetRight.getFields();
        Map<String, Schema.SObjectField> contactField_map = Schema.sObjectType.Contact.fields.getMap();
        
        for (Schema.FieldSetMember sf : Fields) {
            Schema.DescribeFieldResult dfr = contactField_map.get(sf.getFieldPath()).getDescribe();
            
            if (dfr.isAccessible()) {
                rightSideFields.add(new FieldWrapper(dfr.getLabel(), sf.getFieldPath(),
                							String.valueOf(dfr.getType()), String.valueOf(dfr.isUpdateable()), ''));
            }
        }
        return JSON.serialize(rightSideFields);
    }
    
    /**
     * method to get the list of community news for the news marquee section
     */
    @RemoteAction
    public static String getNews() {
        List<NewsWrapper> newsWrapper = new List<NewsWrapper>();
        
        for (Community_News__c conNews : RefedgeCommunityWithoutSharing.getCommunityNewsList()) {
            newsWrapper.add(new NewsWrapper(conNews));
        }
        return JSON.serialize(newsWrapper);
    }
    
    /**
     * method called after an invitation is accepted/rejected
     * this method is for creating the community invite contact records
     */
    @RemoteAction
    public static String inviteAcceptedRejected(String inviteId, String response, String contactId) {
        Savepoint sp = Database.setSavepoint(); 
        
        try {
        	
            if (inviteId != null && inviteId != '') {
                List<Community_Invite_Contact__c> newCICrecords = new List<Community_Invite_Contact__c>();
                
                for (Community_Invite_Contact__c cic : communityInviteContacts(contactId)) {
                	
                    if (cic.Community_Invite__c == inviteId && cic.Contact__c == contactId) {
                        cic.Response__c = response;
                        newCICrecords.add(cic);
                    }
                }
                
                if (newCICrecords.size() > 0) {
                    RefedgeCommunityWithoutSharing.upsertCommunityInviteContact(newCICrecords);
                }
            }
            return 'success';
        } catch(DMLException e) {
            Database.rollback(sp);
            return e.getDmlMessage(0);
        } catch(Exception e) {
            Database.rollback(sp);
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return e.getMessage();
        }
    }
    
    /**
     * method to get the list of all the active community invites
     */
    @RemoteAction
    public static String getCommunityInvites(String contactId) {
        List<Community_Invite__c> communityInviteRecords = new List<Community_Invite__c>();
        List<CommunityWrapper> communityInvites = new List<CommunityWrapper>();
        Map<String, String> refImages = new Map<String, String>();
        Set<String> CommunityInviteIds = new Set<String>();
        
        for (Community_Invite_Contact__c cic : RefedgeCommunityWithoutSharing.getCommunityInviteContacts(contactId)) {
            CommunityInviteIds.add(cic.Community_Invite__c);
        }
        
        for (Community_Invite__c ci : RefedgeCommunityWithoutSharing.getCommunityInvites(contactId, CommunityInviteIds)) {
            Integer totalYesResponseNeeded = ci.Hit_Lists__r.size()
            									+ ci.Account_Requests__r.size() + ci.Unspecified_Requests__r.size();
			
            if (ci.Community_Participate_Deadline__c >= date.today() && ci.Community_Yes__c < totalYesResponseNeeded) {
                refImages.put(ci.Referenceability_Type__c,'');
                communityInviteRecords.add(ci);
            }
        }
        refImages = RefedgeCommunityWithoutSharing.getRefImages(refImages.keySet());
        
        for (Community_Invite__c ci : communityInviteRecords) {
            communityInvites.add(new CommunityWrapper(ci, (refImages != null
        														&& refImages.containsKey(ci.Referenceability_Type__c)
    														? refImages.get(ci.Referenceability_Type__c) : '')));
        }
        return JSON.serialize(communityInvites);
    }
    
    /**
     * method to get the list of all the contact requests
     */
    @RemoteAction
    public static String getContactReqList(String contactId) {
        List<Reference_Request_Account_Contact__c> contactReqList = new List<Reference_Request_Account_Contact__c>();
        Set<String> RRIdSet = new Set<String>();
        List<ContactReqWrapper> contactReqWrapperList = new List<ContactReqWrapper>();
        
        for (Reference_Request_Account_Contact__c rrac : RefedgeCommunityWithoutSharing.getRRACList(contactId)) {
            contactReqList.add(rrac);
            RRIdSet.add(rrac.Reference_Request_Account__r.Reference_Request__c);
            contactReqWrapperList.add(new ContactReqWrapper(rrac));
        }
        Map<Id, Reference_Request__c> refRequestMap = RefedgeCommunityWithoutSharing.getReferenceRequestMap(RRIdSet);
        return JSON.serialize(contactReqWrapperList);
    }
    
    /**
     * method to get a mapping of reference reques records
     */
    @RemoteAction
    public static String getRefRequestMap(String contactId) {
        Set<String> RRIdSet = new Set<String>();
        
        for (Reference_Request_Account_Contact__c rrac : RefedgeCommunityWithoutSharing.getRRACList(contactId)) {
            RRIdSet.add(rrac.Reference_Request_Account__r.Reference_Request__c);
        }
        Map<Id, Reference_Request__c> refRequestMap = RefedgeCommunityWithoutSharing.getReferenceRequestMap(RRIdSet);
        return JSON.serialize(refRequestMap);
    }
    
    /**
     * method to get the lifetime points for the contact to display in the activity history section
     */
    @RemoteAction
    public static String getLifetimePoints(String contactId) {
        List<Reference_Basic_Information__c> referenceProfileContact
        			= RefedgeCommunityWithoutSharing.getReferenceProfileContactList(contactId);
        String lifetimePoints = (referenceProfileContact.size() > 0
									? (referenceProfileContact[0].Lifetime_Points__c != null
										? '' + referenceProfileContact[0].Lifetime_Points__c
										: '0')
									: '0');
        return lifetimePoints;
    }
    
    /**
     * method to get the current available points for the contact to display in the activity history section
     */
    @RemoteAction
    public static String getAvailablePoints(String contactId) {
        List<Reference_Basic_Information__c> referenceProfileContact
        			= RefedgeCommunityWithoutSharing.getReferenceProfileContactList(contactId);
        List<Reference_Basic_Information__c> referenceProfileAccount
        			= RefedgeCommunityWithoutSharing.getReferenceProfileAccountList(referenceProfileContact.size() > 0 ? referenceProfileContact[0].Account__c : '');
        String avaliablePoints = (referenceProfileContact.size() > 0
        							? (referenceProfileAccount[0].Current_Available_Balance_Points__c != null
        								? '' + referenceProfileAccount[0].Current_Available_Balance_Points__c
        								: '0')
    								: '0');
        return avaliablePoints;
    }
    
    // wrapper classes used on the page
    public class ContactReqWrapper {
        public String dateValue { get; set; }
        public String typeValue { get; set; }
        public String prospectiveCustomer { get; set; }
        public String outcome { get; set; }
        public String points { get; set; }
        
        public ContactReqWrapper(Reference_Request_Account_Contact__c rrac) {
            this.dateValue = (rrac.Reference_Request_Account__c != null ? (rrac.Reference_Request_Account__r.Activity_Date__c != null ? rrac.Reference_Request_Account__r.Activity_Date__c.format() : 'N/A') : 'N/A');
            this.typeValue = (rrac.Referenceability_Type__c != null ? rrac.Referenceability_Type__r.Name : 'N/A');
            this.prospectiveCustomer = (rrac.Reference_Request_Account__c != null ? (rrac.Reference_Request_Account__r.Reference_Request__c != null ? (rrac.Reference_Request_Account__r.Reference_Request__r.Account_Name_f__c != null ? rrac.Reference_Request_Account__r.Reference_Request__r.Account_Name_f__c : 'N/A') : 'N/A') : 'N/A');
            this.outcome = (rrac.Reference_Request_Account__c != null ? (rrac.Reference_Request_Account__r.Reference_Request__c != null ? (rrac.Reference_Request_Account__r.Reference_Request__r.Opportunity_Stage_f__c != null ? rrac.Reference_Request_Account__r.Reference_Request__r.Opportunity_Stage_f__c : 'N/A') : 'N/A') : 'N/A');
            this.points = (rrac.Referenceability_Type__c != null ? String.valueOf(rrac.Referenceability_Type__r.Reward_points__c) : 'N/A');
        }
    }
    
    public class CommunityWrapper {
        public String refId { get; set; }
        public String refName { get; set; }
        public String refNameWrapped { get; set; }
        public String rewardPoints { get; set; }
        public String participateWith { get; set; }
        public String deadline { get; set; }
        public String details { get; set; }
        public String imageId { get; set; }
        public String icon { get; set; }
        public String id { get; set; }
        public String detailsWrapped { get; set; }
        
        public CommunityWrapper(Community_Invite__c ci, String imageId) {
            this.id = ci.Id;
            this.imageId = imageId;
            this.icon = (ci.Referenceability_Type__c != null ? (ci.Referenceability_Type__r.Icon__c != null && ci.Referenceability_Type__r.Icon__c != '' ? ci.Referenceability_Type__r.Icon__c : '/assets/icons/standard-sprite/svg/symbols.svg#default') : '/assets/icons/standard-sprite/svg/symbols.svg#default');
            this.participateWith  = ci.Community_Participate_With__c;
            this.details = ci.Community_Participate_Details__c;
            this.detailsWrapped = (this.details.length() > 225 ? (this.details.replace(this.details.substring(225,this.details.length()) , '.....')) : this.details);
            this.deadline = (ci.Community_Participate_Deadline__c != null ? ci.Community_Participate_Deadline__c.format() : '');
            this.refName = (ci.Referenceability_Type__c != null ? ci.Referenceability_Type__r.Name : system.Label.See_Details);
            this.rewardPoints = (SObjectType.Referenceability_Type__c.fields.getMap().get('Reward_points__c').getDescribe().isAccessible() && ci.Referenceability_Type__r.Reward_points__c != null ? String.valueOf(ci.Referenceability_Type__r.Reward_points__c)+' points' : '');
        }
    }
    
    public class NewsWrapper {
        public String newaName { get; set; }
        public String newsId { get; set; } 
        public String newsBody { get; set; }
        
        public NewsWrapper(Community_News__c newsObj) {
            this.newaName = newsObj.Name;
            this.newsId = newsObj.Id;
            this.newsBody = newsObj.News_Body__c;
        }
    }
    
    public class RefTypeWrapper {
        public Boolean isSelected { get; set; }
        public Referenceability_Type__c refType { get; set; }
        
        public refTypeWrapper(Boolean isSelected, Referenceability_Type__c refType) {
            this.isSelected = isSelected;
            this.refType = refType;
        }
    }
    
    public class FieldWrapper {
        public String label { get; set; }
        public String apiName { get; set; }
        public String fieldType { get; set; }
        public String isUpdateable { get; set; }
        public String referenceValue { get; set; }
        
        public FieldWrapper(String label, String apiName, String fieldType, String isUpdateable, String referenceValue) {
            this.label = label;
            this.apiName = apiName;
            this.fieldType = fieldType;
            this.isUpdateable = isUpdateable;
            this.referenceValue = referenceValue;
        }
    }
}