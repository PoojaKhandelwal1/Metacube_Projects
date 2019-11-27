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
 * VF Page: ReferenceLeadForm
 * Description: Class used for RLF.
 * Modified by: Rajesh for ticket #841
 */
public with sharing class ReferenceLeadFormController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public Reference_Lead__c referenceLead { get; set; } 
    public Boolean showMessage { get; set; }
    public List<refTypeWrapper> refTypeWrapperList { get; set; }
    public SelectReferenceLeadAttributes refUseAttr { get; set; }
    public List<Data_Mapping__c> fieldMappings { get; set; }
    public List<Data_Mapping__c> referenceLeadHeaders { get; set; }
    public Data_Mapping__c header { get; set; }
    public Data_Mapping__c subHeader { get; set; }
    public String selectedContact { get; set; }
    private List<Contact> contactList;
    public String answerChoice { get; set; }
    public String refLeadMessage { get; set; }
    private Custom_Settings__c cs { get; set; }
    // This field is use to show reward points in disolving alert for sales reward issue to user
    public transient Decimal rewardPoints { get; set; }
    // This field is use to show action message in disolving alert for sales reward issue to user
    public transient String actionMessage { get; set; }
    private List<sObject> postFeedItems = new List<sObject>();
    private String accountName, conName, OpportunityName, OpportunityOwnerName;
    private String selectedContactName;
    private Boolean checkChatterSetting;
    private Boolean checkEmailSetting;
    private List<Referenceability_Type__c> allRefTypeList;
    public static String rbiNominationLink = URL.getSalesforceBaseUrl().toExternalForm() + '/';
    private static String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.referencebylead.getURL() + '?id=';

    //  REF-2008    To check whether to show notification on screen or not
    public Boolean isScreenNotification{ get; set; }
    
    public List<SelectOption> getContactList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        Integer size = 1;
        
        for (Contact con : contactList) {
        	
        	if (size < 1000) {
            	options.add(new SelectOption(con.Id, con.Name));
        	}
            size++;
        }
        return options;
    }
    public Boolean isLimitExceeded { get; set; }
    private Set<String> accFiltersToExclude, conFiltersToExclude;
    
    /**
     * Constructor
     */
    public ReferenceLeadFormController(ApexPages.StandardController controller) {
        showMessage = false;
        refLeadMessage = '';        
        cs = UtilityController.getCustomSettings();
        isScreenNotification = cs.User_Reward_Onscreen_Notification__c;
        refTypeWrapperList = new List<refTypeWrapper>();
        referenceLeadHeaders = new List<Data_Mapping__c>();
        accFiltersToExclude = new Set<String>();
        conFiltersToExclude = new Set<String>();
        checkChatterSetting = (UtilityController.isNativeChatterSetting);
        String refLeadId = ApexPages.currentPage().getParameters().get('Id');
        answerChoice = ApexPages.currentPage().getParameters().get('option');
        Set<String> refTypeIds = new Set<String>();
		isLimitExceeded = false;
        fieldMappings = new List<Data_Mapping__c>();
        
        for (Attribute_Mapping__c attMap : [SELECT Filter_Label_Name__c, Object__c FROM Attribute_Mapping__c
        									WHERE Object__c = :ConstantsController.CONTACT
        									AND Is_Related_Mapping__c = false]) {
            conFiltersToExclude.add(attMap.Filter_Label_Name__c);
        }
        
        for (Attribute_Mapping__c attMap : [SELECT Filter_Label_Name__c, Object__c FROM Attribute_Mapping__c
        									WHERE Object__c = :ConstantsController.ACCOUNT
        									AND Is_Related_Mapping__c = false]) {
            accFiltersToExclude.add(attMap.Filter_Label_Name__c);
        }
        
        if (refLeadId != null && refLeadId != '') {
        	
            for (Data_Mapping__c dm : [SELECT Visible__c, Required__c, Referenceability_Type__c, Order__c,
            							Object__c, Name, Label__c, Id, Filter__c, Field_API_Name__c
            							FROM Data_Mapping__c
            							WHERE Object__c = :ConstantsController.REFERENCE_LEAD
            							AND Filter__c = null
            							AND visible__c = true]) {
                
                if (dm.Referenceability_Type__c != null) {
                    refTypeIds.add(dm.Referenceability_Type__c);
                } else if (dm.Field_API_Name__c != null) {
                    fieldMappings.add(dm);
                }
            }
            String query = 'SELECT Id, Nomination__c, Other_Info__c, Notification_response__c, Response_Received__c, '
    					+ 'Reference_Lead_Status__c, Nominated__c, Reference_Profile__c, Reference_Lead_Opportunity__c, '
    					+ 'No_Response_Date__c, Reference_Lead_Opportunity__r.Owner.Name, Reference_Lead_Opportunity__r.Name, '
    					+ 'Reference_Lead_Owner__c, Follow_up_timeframe__c, Reference_Lead_Account__c, '
    					+ 'Reference_Lead_Account__r.Name, Contact__r.Name, Contact__c, Reference_Lead_Owner__r.Email ';
    		
            for (Data_Mapping__c dm : fieldMappings) {
                query += ', ' + dm.Field_API_Name__c;
            }
            query += ' FROM Reference_Lead__c WHERE Id = :refLeadId';
            List<Reference_Lead__c> refLeads = WithoutSharingHelperController.getRefLeadRecords(query, refLeadId);
            
            if (refLeads.size() > 0) {
                referenceLead = refLeads[0];
                accountName = referenceLead.Reference_Lead_Account__r.Name;
                OpportunityName = referenceLead.Reference_Lead_Opportunity__r.Name;
                OpportunityOwnerName = referenceLead.Reference_Lead_Opportunity__r.Owner.Name;
                conName = (referenceLead.Contact__c != null ? referenceLead.Contact__r.Name : '');
                
                if (answerChoice == '1') {
                    // Changes for #366
                    List<Contact> tempContactList = WithoutSharingHelperController.getAccountContacts(referenceLead.Reference_Lead_Account__c, cs);
                    
                    if (tempContactList != null && tempContactList.size() > 0) {
	                    contactList = new List<Contact>();
	                    contactList.addAll(tempContactList);
                    } else {
                    	contactList = WithoutSharingHelperController.getContactInRBI1(new Set<String> {referenceLead.Reference_Lead_Account__c});
                    }
                    contactList.sort();
                    
                    if (contactList.size() > 999) {
        				isLimitExceeded = true;
                    }
                    refUseAttr = new SelectReferenceLeadAttributes();
                    
                    allRefTypeList = [SELECT Id, Name, Visible__c, Ref_Limit_to_Acct_or_Cntct__c 
                    										FROM Referenceability_Type__c WHERE Visible__c = true AND Id In: refTypeIds ORDER BY Name];
                    setRefTypeAndAttribute();
                    referenceLeadHeaders = [SELECT Name, Id, Visible__c, Order__c, Field_API_Name__c, Required__c
											FROM Data_Mapping__c
											WHERE Object__c = :ConstantsController.REFERENCE_LEAD_HEADER
											ORDER BY Order__c];
                    
                    for (Data_Mapping__c dm : referenceLeadHeaders) {
                    	
                        if (dm.Name == ConstantsController.HEADER) {
			                header = dm;
			            }
			                
			            if (dm.Name == ConstantsController.SUBHEADER) {
			                subHeader = dm;
			            }
                    }
                } else if (answerChoice == '2') {
                    refLeadMessage = system.label.Time_to_referenceable.replace('@@@',
                    										referenceLead.Reference_Lead_Account__r.Name);
                } else if (answerChoice == '3') {
                    refLeadMessage = system.label.Provide_the_name_of_responsible_person.replace('@@@',
                    										referenceLead.Reference_Lead_Account__r.Name);
                }
            } else {
                ApexPages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, system.label.Record_does_not_exists));
            }
        }
    }
    
    /**
     * Method to setup Data for PRO Edition
     * Created By: Rekha @24 April 2017 regarding #570 
     */
    public void setRefTypeAndAttribute() {
    	Set<String> selectedIds = new Set<String>();
        List<Referenceability_Type__c> refTypeList = new List<Referenceability_Type__c>();
        
        for (RefTypeWrapper ref : refTypeWrapperList) {
        	
            if (ref.isSelected) {
            	selectedIds.add(ref.refType.Id);
            }
        }
        refTypeWrapperList = new List<RefTypeWrapper>();
        String conId = (selectedContact != null && selectedContact != '' ? selectedContact : 
    					(referenceLead.Contact__c != null ? referenceLead.Contact__c : null));
    					
        for (Referenceability_Type__c ref : allRefTypeList) {

        	//if reftype available for both
			if (ref.Ref_Limit_to_Acct_or_Cntct__c == null || ref.Ref_Limit_to_Acct_or_Cntct__c == '') {
				refTypeList.add(ref);
			//if reftype available for contact only
			} else if (conId != null && conId != '' && ref.Ref_Limit_to_Acct_or_Cntct__c == 'Contact') {
				refTypeList.add(ref);
			//if reftype available only for account
			} else if ((conId == null || conId == '') && referenceLead.Reference_Lead_Account__c != null 
							&& ref.Ref_Limit_to_Acct_or_Cntct__c == 'Account') {
    			refTypeList.add(ref);
			}
        }
        
    	refUseAttr.mapAllAttributesLabel.clear();

    	for (String key : refUseAttr.mapAllAttributesLabelforBoth.keySet()) {
        	refUseAttr.mapAllAttributesLabel.put(key, new List<SelectReferenceLeadAttributes.AttributesLabelWrapper>());
        	
            for (SelectReferenceLeadAttributes.AttributesLabelWrapper alw : refUseAttr.mapAllAttributesLabelforBoth.get(key)) {
            	
				//if reftype available for contact only
				if (conId != null && conId != '' && alw.isForContact) {
					refUseAttr.mapAllAttributesLabel.get(key).add(alw);
				//if reftype available only for account
				} else if ((conId == null || conId == '') && referenceLead.Reference_Lead_Account__c != null && alw.isForAccount) {
	    			refUseAttr.mapAllAttributesLabel.get(key).add(alw);
				} else {
					alw.fontWeight = ConstantsController.NORMAL;
				}
            }
        }
		
		refUseAttr.labels.clear();
        
        for (Label__c label : refUseAttr.allLabels) {
        	
			//regarding #893
			if (refUseAttr.mapAllAttributesLabel.containsKey(label.Id) && refUseAttr.mapAllAttributesLabel.get(label.Id).size() > 0) {
					
	    		//if reftype available for both
				if (label.Ref_Limit_to_Acct_or_Cntct__c == null || label.Ref_Limit_to_Acct_or_Cntct__c == '') {
					refUseAttr.labels.add(label);
				//if reftype available for contact only
				} else if (conId != null && conId != '' && label.Ref_Limit_to_Acct_or_Cntct__c == 'Contact') {
					refUseAttr.labels.add(label);
				//if reftype available only for account
				} else if ((conId == null || conId == '') && referenceLead.Reference_Lead_Account__c != null 
								&& label.Ref_Limit_to_Acct_or_Cntct__c == 'Account') {
	    			refUseAttr.labels.add(label);
				}
			}
    	}
    	
        //changes regarding #570 
        for (String key : refUseAttr.mapAttributesLabels.keySet()) {
        	
            for (Integer i = 0; i < refUseAttr.mapAttributesLabels.get(key).size(); i++) {
            	
				//if reftype available for contact only
				if (conId != null && conId != '' && !refUseAttr.mapAttributesLabels.get(key)[i].isForContact) {
					refUseAttr.mapAttributesLabels.get(key).remove(i);
				//if reftype available only for account
				} else if ((conId == null || conId == '') && referenceLead.Reference_Lead_Account__c != null 
										&& !refUseAttr.mapAttributesLabels.get(key)[i].isForAccount) {
	    			refUseAttr.mapAttributesLabels.get(key).remove(i);
				}
            }
            
            for (Integer i = 0; i < refUseAttr.tempmapAttributesLabels.get(key).size(); i++) {
            	
				//if reftype available for contact only
				if (conId != null && conId != '' && !refUseAttr.tempmapAttributesLabels.get(key)[i].isForContact) {
					refUseAttr.tempmapAttributesLabels.get(key).remove(i);
				//if reftype available only for account
				} else if ((conId == null || conId == '') && referenceLead.Reference_Lead_Account__c != null 
										&& !refUseAttr.tempmapAttributesLabels.get(key)[i].isForAccount) {
	    			refUseAttr.tempmapAttributesLabels.get(key).remove(i);
				}
            }
        }
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
                    templist.add(refTypeList.get(i + line + 1 + line + 1));
                }
            }
        }
        
        for (Referenceability_Type__c ref : templist) {
        	
        	if (selectedIds.contains(ref.Id)) {
        		refTypeWrapperList.add(new RefTypeWrapper(true, ref));
        	} else {
        		refTypeWrapperList.add(new RefTypeWrapper(false, ref));
        	}
        }
    }
    
    /**
     * Method to redirect to SelectReferenceLeadAttribute
     */
    public pageReference selectRefUseAttr() {
        return Page.SelectReferenceLeadAttribute;
    }
    
    /**
     * Method to save
     */
    public pageReference saveRecord() {
        Savepoint sp = Database.setSavepoint();
        
        try {
        	
            for (Data_Mapping__c DM : referenceLeadHeaders) {
            	
            	if (DM.Name == ConstantsController.FREEFROMTEXT && DM.Required__c && referenceLead.Other_Info__c == null) {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.ERROR_SELECT_REQUIRED_VALUE));
                    return null;
                }
                
                if (DM.Name == ConstantsController.ATTRIBUTES && DM.Visible__c) {
                	//changes regarding #833
			        Set<Id> labelIds = new Set<Id>();
			        
			        for (Label__c label : refUseAttr.labels) {
			        	labelIds.add(label.Id);
			        }
				        
                    for (String str : refUseAttr.mapRequiredLabel.keyset()) {
                    	
                        if (refUseAttr.mapRequiredLabel.get(str) && refUseAttr.mapAttributesLabels.get(str).size() < 1 && labelIds.contains(str)) {
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO,
                            											ConstantsController.ERROR_SELECT_REQUIRED_VALUE));
                            return null;
                        }
                    }
                }
                
                if (DM.Name == ConstantsController.CUSTOMFIELDS && DM.Visible__c) {
                	
                    for (Data_Mapping__c DMN : fieldMappings) {
                    	
                        if (DMN.Required__c) {
                        	
                            if (referenceLead.get(DMN.Field_API_Name__c) == null
                            			|| referenceLead.get(DMN.Field_API_Name__c) == '') {
                                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO,
                                											System.Label.ERROR_SELECT_REQUIRED_VALUE));
                                return null;
                            }
                        }
                    }
                }
            }
            
            if (selectedContact != null && selectedContact != '') {
                referenceLead.Contact__c = selectedContact;
            }
            conName = (referenceLead.Contact__c != null
            			? WithoutSharingHelperController.getSelectedContactsForInvitation(new List<String>{referenceLead.Contact__c})[0].Name : '');
            referenceLead.Response_Received__c = true;
            referenceLead.Notification_response__c = 'Yes, this is a very happy account';
            referenceLead = WithoutSharingHelperController.createRefLead(referenceLead);
            createFilterAndRefType();
            
            if (cs.Create_Reference_Profile__c) {
                // moved this method to utility controller for using on the lightning page controller also
                UtilityController.createRBI1(referenceLead.Reference_Lead_Account__c, referenceLead.Contact__c, referenceLead.Id, conFiltersToExclude, accFiltersToExclude, accountName, conName);
            }
            showMessage = true; 
            
            // re #119 - Added sales rewards for User
            if (!RefEdgeEditionFeatures.isBasic && cs.Enable_Sales_Rewards_Notification__c) {
            	List<String> lstUserAction = new List<String>();
            	lstUserAction.add(ConstantsController.RLF_RESPONSE);
	            List<Referenceability_Type__c> refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);
	            
	            // re #583 - null check for User reward points.
	            if (refType.size() > 0 && showMessage && refType[0].Sales_Point__c != null) {
	                Custom_Settings__c cs = UtilityController.getCustomSettings();
	                List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
	                
	                if (referenceLead.Response_Received__c) {
	                    Reference_Lead__c refId = [SELECT ownerId FROM Reference_Lead__c
	                    							WHERE Id = :referenceLead.Id LIMIT 1];
	                    rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c,
	                    									Referenceability_Type__c = refType[0].Id,
	                    									Transaction__c = ConstantsController.ISSUE,
	                    									RewardDate__c = Date.Today(),
	                    									User__c = UserInfo.getUserId()));	// re #240 
	                    UtilityController.isUserProfileExist(refId.ownerId);  
	                    
	                    // re #591 - NEW field User_Reward_Onscreen_Notification__c allow for on/off for onscreen notification.
		            	if (cs.User_Reward_Onscreen_Notification__c) {
		                    rewardPoints = refType[0].Sales_Point__c; 
		                    actionMessage =  refType[0].Name;   
		            	}                                   
					} 
	                
					if (rewardsToBeInsert.size() > 0) {
                    	WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
	                }
	            }
			}
        } catch (Exception e) {
            showMessage = false;
            Database.rollback(sp);
            Apexpages.addMessages(e);
            return null;
        }
        return null;
    }
    /**
     * Method to create Filter and Referenceability Type
     */
    private void createFilterAndRefType() {
        List<ReferenceLeadFilter__c> referenceLeadFilterList = new List<ReferenceLeadFilter__c>();
        List<ReferenceLeadAttributes__c> refLeadFilterAttList = new List<ReferenceLeadAttributes__c>();
        //changes regarding #570 
        Set<Id> labelIds = new Set<Id>();
        
        for (Label__c label : refUseAttr.labels) {
        	labelIds.add(label.Id);
        }
        
        for (String labelId : refUseAttr.mapAttributesLabels.keySet()) {
        	
            if (refUseAttr.mapAttributesLabels.get(labelId).size() > 0 && labelIds.contains(labelId)) {
                ReferenceLeadFilter__c refiLabelObj = new ReferenceLeadFilter__c(Filter__c = labelId,
            																	Reference_Lead__c = referenceLead.Id);
                referenceLeadFilterList.add(refiLabelObj);
            }
        }
        
        if (referenceLeadFilterList.size() > 0) {
        	// DML moved to w/o sharing - Gaurav Saini (20 March, 2017)
            WithoutSharingHelperController.insertRefLeadFilters(referenceLeadFilterList);
            
            for (ReferenceLeadFilter__c refiLableObj : [SELECT Filter__c, Id FROM ReferenceLeadFilter__c
    													WHERE Reference_Lead__c = :referenceLead.Id]) {
                
                for (SelectReferenceLeadAttributes.AttributesLabelWrapper aw : refUseAttr.mapAttributesLabels.get(refiLableObj.Filter__c)) {
                    refLeadFilterAttList.add(new ReferenceLeadAttributes__c(Attribute__c = aw.attributeLabel.Attribute__c, ReferenceLeadFilter__c = refiLableObj.Id));
                }
            }
            
            if (refLeadFilterAttList.size() > 0) {
                // DML moved to w/o sharing - Gaurav Saini (20 March, 2017)
            	WithoutSharingHelperController.insertRefLeadAttributes(refLeadFilterAttList);
            }
        }
        List<ReferenceLeadReferenceability__c> refiRefTypeList = new List<ReferenceLeadReferenceability__c>();
        
        for (refTypeWrapper ref : refTypeWrapperList) {
        	
            if (ref.isSelected) {
                refiRefTypeList.add(new ReferenceLeadReferenceability__c(Reference_Lead__c = referenceLead.Id, Referenceability_Type__c = ref.refType.Id));
            }
        }
        
        // for SF1
        if (refiRefTypeList.size() > 0) {
            // DML moved to w/o sharing - Gaurav Saini (20 March, 2017)
        	WithoutSharingHelperController.insertRefLeadReferenceabilities(refiRefTypeList);
        }
    }
    
    /**
     * Method to save Reference Lead Record
     */
    public pageReference saveRefLeadRecord() {
        Savepoint sp = Database.setSavepoint();
        
        try {
        	Custom_Settings__c cs = UtilityController.getCustomSettings();
            List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
            List<sObject> postFeedItems = new List<sObject>();
            String body;
            String headerDocId = '';
            String footerDocId = '';
            Data_Mapping__c checkBackNotification = new Data_Mapping__c();
            Data_Mapping__c ownerUpdateNotification = new Data_Mapping__c();
            Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Check_back_in_Email__c', UtilityController.appNamespace() + 'Ref_Lead_Owner_Update_Email__c'};

            for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                        FROM Data_Mapping__c
                                        WHERE Object__c = 'Notification'
                                        AND (Field_API_Name__c IN :notificationFieldNames
                                            OR Section_Name__c = 'email header doc'
                                            OR Section_Name__c = 'email footer doc')]) {

                if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Check_back_in_Email__c') {
                    checkBackNotification = dm;
                } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Ref_Lead_Owner_Update_Email__c') {
                    ownerUpdateNotification = dm;
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
            
            if (answerChoice == '2') {
            	
                if (referenceLead.Follow_up_timeframe__c == null || referenceLead.Follow_up_timeframe__c == '') {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, system.label.Select_value_in_check_back));
                    return null;
                }
                body = checkBackNotification.DC_Message__c;
                body = body.replace('[Opportunity Account]', accountName)
                            .replace('[Specified Timeframe]', referenceLead.Follow_up_timeframe__c);
                String days = referenceLead.Follow_up_timeframe__c.split(' ')[0];
                referenceLead.Response_received__c = true;
                referenceLead.Notification_response__c = 'Check back with me later';
                referenceLead.Follow_up_date__c = date.today() + Integer.valueOf(days);
                referenceLead.Reminder_Date__c = (cs.RLF_Reminder_Days__c != null
                									? date.today().addDays(Integer.valueOf(days) + Integer.Valueof(cs.RLF_Reminder_Days__c))
                									: null);
                referenceLead.Reference_Lead_Status__c = 'Follow up';
                
                if (cs.No_Response_days__c != null) {
                    referenceLead.No_Response_Date__c = referenceLead.Follow_up_date__c.addDays(Integer.valueOf(cs.No_Response_days__c));
                }
                // DML moved to w/o sharing - Gaurav Saini (20 March, 2017)
                WithoutSharingHelperController.updateRefLead(referenceLead);
                
                if (cs.Check_back_in_Chatter__c && checkChatterSetting) {
                    postFeedItems.add(MailChatterController.preparePost(checkBackNotification.Section_Name__c.replace('[Opportunity Account]', accountName),
                                                                            referenceLead.Reference_Lead_Owner__c, body, ''));
                }
                
                if (cs.Check_back_in_Email__c) {
                    listmail.add(MailChatterController.prepareEmail(checkBackNotification.Section_Name__c.replace('[Opportunity Account]', accountName), referenceLead.Reference_Lead_Owner__c, body, true, headerDocId, footerDocId));
                }
                
                if (cs.Enable_Slack_Integration__c && cs.Check_back_in_Slack__c) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('userEmail', referenceLead.Reference_Lead_Owner__r.Email);
                    tempReqBodyMap.put('text', '*' + checkBackNotification.Section_Name__c.replace('[Opportunity Account]', accountName) + '*\n' + body);
                    messagesList.add(tempReqBodyMap);
                }
            } else if (answerChoice == '3') {
                
                if (referenceLead.Reference_Lead_Owner__c == null) {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, system.label.Select_reference_lead_owner));
                    return null;
                }
                referenceLead.Response_received__c = true;
                referenceLead.Notification_response__c = 'I don\'t know, I\'m not the right person to ask';
                // DML moved to w/o sharing - Gaurav Saini (20 March, 2017)
                WithoutSharingHelperController.updateRefLead(referenceLead);
                body = ownerUpdateNotification.DC_Message__c;
                body = body.replace('[Opportunity Account]', accountName)
                            .replace('[Opportunity Owner]', OpportunityOwnerName)
                            .replace('[Opportunity Name]', OpportunityName);
                Map<Id, User> newOwnerMap = WithoutSharingHelperController.getUserMap(new Set<Id> { referenceLead.Reference_Lead_Owner__c });
                
                if (cs.Ref_Lead_Owner_Update_Chatter__c && checkChatterSetting) {
                    postFeedItems.add(MailChatterController.preparePost(ownerUpdateNotification.Section_Name__c.replace('[Opportunity Account]', accountName),
                            referenceLead.Reference_Lead_Owner__c, body, LINK_URL + referenceLead.Id));
                }
                
                if (cs.Ref_Lead_Owner_Update_Email__c) {
                    listmail.add(MailChatterController.prepareEmail(ownerUpdateNotification.Section_Name__c.replace('[Opportunity Account]', accountName),
                            referenceLead.Reference_Lead_Owner__c, body + '\n\n' + ownerUpdateNotification.Section_Name__c.replace('[Opportunity Account]', accountName)
                            + ': <a href="' + LINK_URL + referenceLead.Id + '">' + LINK_URL + referenceLead.Id + '</a>', true, headerDocId, footerDocId));
                }

                if (cs.Enable_Slack_Integration__c && cs.Ref_Lead_Owner_Update_Slack__c) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('userEmail', newOwnerMap.get(referenceLead.Reference_Lead_Owner__c).Email);
                    tempReqBodyMap.put('text', body + '\n<' + LINK_URL + referenceLead.Id + '|'
                            + ownerUpdateNotification.Section_Name__c.replace('[Opportunity Account]', accountName) + '>');
                    messagesList.add(tempReqBodyMap);
                }
                
                // re #119 - Added sales rewards for User  
                if (RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c == true) {
                	List<String> lstUserAction = new List<String>();
            		lstUserAction.add(ConstantsController.RLF_REFERRED);
	            	List<Referenceability_Type__c> refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);
	             
	                // re #633 - Check null value for Sales point 
	                if (refType.size() > 0 && refType[0].Sales_Point__c != null) {
	                    List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
	                    
	                    if (referenceLead.Response_Received__c == true ) {
	                        Reference_Lead__c refId = [SELECT ownerId FROM Reference_Lead__c
	                        							WHERE Id = :referenceLead.Id LIMIT 1];
	                        rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c,
	                        									Referenceability_Type__c = refType[0].Id,
	                        									Transaction__c = ConstantsController.ISSUE,
	                        									RewardDate__c = Date.Today(),
	                        									User__c = UserInfo.getUserId()));	// re #240 
	                        UtilityController.isUserProfileExist(refId.ownerId);  
	                        rewardPoints = refType[0].Sales_Point__c; 
	                        actionMessage =  refType[0].Name;                                      
	                    }
	                    
	                    if (rewardsToBeInsert.size() > 0) {
	                        WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
	                    }
					}
				}
            }
            
            if (listmail.size() > 0) {
                Messaging.sendEmail(listmail);
            }
            
            if (postFeedItems.size() > 0) {
                postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
            }

            if (messagesList != null && messagesList.size() > 0) {
            	slackReqBody.put('messages', messagesList);
            	UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
            }
            showMessage = true;
        } catch (Exception e) { 
            showMessage = false;
            Database.rollback(sp);
            Apexpages.addMessages(e);
        }
        return null;
    }
    
    /**
     * Method to cancel
     */
    public pageReference cancel() {
        return new pageReference('/home/home.jsp');
    }
    
    /**
     * Wrapper Class
     */
    public class refTypeWrapper {
        public Boolean isSelected { get; set; }
        public Referenceability_Type__c refType { get; set; }
        
        public refTypeWrapper(Boolean isSelected, Referenceability_Type__c refType) {
            this.isSelected = isSelected;
            this.refType = refType;
        }
    }
}