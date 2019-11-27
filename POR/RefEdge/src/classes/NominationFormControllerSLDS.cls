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
 * Page: NominationFormSLDS
 * Description: this class is called FROM NominationFormSLDS page to nominate Account/Contact
 * Last Modified by: Rekha @24 April 2017
 */
public with sharing class NominationFormControllerSLDS extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public String accountId { get; set; }
	public String contactId { get; set; }
    public String refLeadId { get; set; }
    private static Map<String, Account> accountMap = new Map<String, Account>();
    private static Map<String, Schema.SObjectField> fldObjAccMap = schema.SObjectType.Account.fields.getMap();
    private static List<Schema.SObjectField> fldObjMapValues = fldObjAccMap.values();
    private static Map<String, Contact> contactMap = new Map<String, Contact>();
    private static Map<String, Schema.SObjectField> fldObjConMap = schema.SObjectType.Contact.fields.getMap();
    private static List<Schema.SObjectField> fldObjConMapValues = fldObjConMap.values();
    private static Set<String> allFilters = new Set<String>();
    public String showMore { get; set; }
    public String pageNo { get; set; }
    public String userId { get; set; }
    public Boolean isFromProfileUpdate { get; set; }
    public Boolean isSLDS { get; set; }
    
    /**
     * constructor to use this as an extension on RefProspectorResponsePage
     * author: Gaurav Saini (16 Nov, 2017) #1104
     */
    public NominationFormControllerSLDS(RefProspectorResponseController controller) {}
    
	/**
     * Constructor
     */
    public NominationFormControllerSLDS(ApexPages.StandardController controller) {
    	String pageUrl = (String)apexPages.currentPage().getUrl();
    	isFromProfileUpdate = false;
		isSLDS = apexPages.currentPage().getParameters().get('isSLDS') != null
				? apexPages.currentPage().getParameters().get('isSLDS') == 'true' : false;

    	if (apexPages.currentPage().getParameters().get('PUMAccountId') != null && 
        			apexPages.currentPage().getParameters().get('PUMAccountId') != '') {
    		accountId = apexPages.currentPage().getParameters().get('PUMAccountId');
    		contactId = apexPages.currentPage().getParameters().get('PUMContactId');
    		showMore = ApexPages.currentPage().getParameters().get('showMore');
    		pageNo = ApexPages.currentPage().getParameters().get('pageNo');
    		userId = ApexPages.currentPage().getParameters().get('userId');
    		isFromProfileUpdate = true;
    	} else if (pageUrl.contains('refLeadId') && apexPages.currentPage().getParameters().get('refLeadId') != null && 
        			apexPages.currentPage().getParameters().get('refLeadId') != '') {
            refLeadId = apexPages.currentPage().getParameters().get('refLeadId');
        } else if (pageUrl.contains('AccountId') && apexPages.currentPage().getParameters().get('AccountId') != null && 
        			apexPages.currentPage().getParameters().get('AccountId') != '') {
            accountId = apexPages.currentPage().getParameters().get('AccountId');
            
            if (apexPages.currentPage().getParameters().get('ContactId') != null) {
                contactId = apexPages.currentPage().getParameters().get('ContactId');
            }
    	} else {
    		Nomination__c nominationForm = (Nomination__c)controller.getRecord();
    		accountId = nominationForm.Account__c;
    		
            if (nominationForm.Contact__c != null) {
                contactId = nominationForm.Contact__c;
                List<Contact> contactList = [SELECT Id, AccountId, Name FROM Contact WHERE Id = :nominationForm.Contact__c limit 1];
                
                if (contactList.size() > 0) {
                    accountId = contactList[0].AccountId;
                }
            }
    	}
    }
    
    /**
     * Method to get Date Format #1070
     */
    @RemoteAction
    public static String getDateFormat() {   
    		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
    		return dateFormat;
    }
    
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage(String refLeadId) {
		checkPermissions(refLeadId);
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(String refLeadId) {
    	
    	if (refLeadId == null || refLeadId == '') {
	    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
	        fieldMap.put(UtilityController.appNamespace() + 'Nomination__c',
	    										new Set<String>{UtilityController.appNamespace() + 'Contact__c',
	        										UtilityController.appNamespace() + 'Account__c',
	        										UtilityController.appNamespace() + 'Status__c',
	        										UtilityController.appNamespace() + 'Email_Enabled__c',
	        										UtilityController.appNamespace() + 'Referenceability__c'});
	        List<Data_Mapping__c> dataMappingList = [SELECT Name, Id, Visible__c, Order__c, Field_API_Name__c, Required__c
					    								FROM Data_Mapping__c 
														WHERE Object__c = :ConstantsController.NOMINATION
														AND Visible__c = true
														ORDER BY Order__c];
			
	        for (Data_Mapping__c dm : dataMappingList) {
	        	fieldMap.get(UtilityController.appNamespace() + 'Nomination__c').add(dm.Field_API_Name__c);
	        }
	        fieldMap.put(UtilityController.appNamespace() + 'Nomination_Referenceability__c',
	    										new Set<String>{UtilityController.appNamespace() + 'Nomination__c',
	        										UtilityController.appNamespace() + 'Referenceability_Type__c'});
			fieldMap.put(UtilityController.appNamespace() + 'Nomination_Label__c',
	    										new Set<String>{UtilityController.appNamespace() + 'Nomination__c',
	        										UtilityController.appNamespace() + 'Label__c'});
			fieldMap.put(UtilityController.appNamespace() + 'Nomination_Label_Attribute__c',
	    										new Set<String>{UtilityController.appNamespace() + 'Attribute__c',
	        										UtilityController.appNamespace() + 'Nomination_Label__c'});
	        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
	        return isUpsertPermission;
    	}
    	return true;
    }
    
    /**
     * RemoteAction to get all intial information
     */
    @RemoteAction
    public static InfoWrapper fetchInfo(String accountId, String ContactId, String refLeadId, Boolean isFromProfileUpdate) {
    	InfoWrapper infoWp = new InfoWrapper();
    	
    	try {
    		Custom_Settings__c cs = UtilityController.getCustomSettings();
    		Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Nomination__c.fields.getMap();
	        Map<String, Schema.DescribeFieldResult> fieldSet = new Map<String, Schema.DescribeFieldResult>();
	        
	        for (String field : fldObjMap.keyset()) {
	        	Schema.DescribeFieldResult fieldObj = fldObjMap.get(field).getDescribe();
	        	
	            if (fieldObj.isCustom() && fieldObj.isUpdateable()) {
	            	fieldSet.put(fieldObj.getName(), fieldObj);
	            }
	        }
	        List<Data_Mapping__c> dmList = [SELECT Name, Id, Visible__c, Order__c, Field_API_Name__c, Required__c
	        								FROM Data_Mapping__c 
											WHERE Object__c = :ConstantsController.NOMINATION
											AND Visible__c = true
											ORDER BY Order__c];
	        
	        for (Data_Mapping__c dm : dmList) {
	        	
	        	if (fieldSet != null && fieldSet.containsKey(dm.Field_API_Name__c)) {
	                infoWp.nomiFields.add(new FieldWrapper(fieldSet.get(dm.Field_API_Name__c), dm));
	            }
	        }
	        
    		for (Data_Mapping__c dm : [SELECT Name, Id, Visible__c, Order__c, Field_API_Name__c, Required__c FROM Data_Mapping__c 
    												WHERE Object__c = :ConstantsController.NOMINATION_HEADER ORDER BY lastModifiedDate desc, Order__c limit 6]) {
				
				if (dm.Name == ConstantsController.HEADER) {
	                infoWp.header = (dm.Visible__c ? dm.Field_API_Name__c : '');
				} else if (dm.Name == ConstantsController.SUBHEADER) { 
	                infoWp.subHeader = (dm.Visible__c ? dm.Field_API_Name__c : '');
				} else {
                	infoWp.sections.add(new HeaderWrapper(dm));
				}
			}
			
			//changes regarding #570 
			List<Referenceability_Type__c> refTypeList = [SELECT Id, Name, Visible__c, Ref_Limit_to_Acct_or_Cntct__c 
															FROM Referenceability_Type__c WHERE Visible__c = true 
															AND Sales_Reward__c = false AND Id IN (SELECT Referenceability_Type__c 
															FROM Data_Mapping__c WHERE Object__c = :ConstantsController.NOMINATION_REFERENCEABILITY AND Visible__c = true) 
															ORDER BY Name LIMIT :limits.getLimitQueryRows()];
			
	        for (Referenceability_Type__c ref : refTypeList) {
	            infoWp.refTypes.add(new RefTypeWrapper(ref.Id, ref.Name, ref.Ref_Limit_to_Acct_or_Cntct__c));
	        }
	        List<Label__c> labelList = [SELECT Id, Name, Visible__c, Required__c, Ref_Limit_to_Acct_or_Cntct__c, 
	        					(SELECT Id FROM Attributes_Labels__r) FROM Label__c 
	        					WHERE Visible__c = true order by Nomination_Filter_Order__c];
	        for (Label__c label : labelList) {
	            
	            if (label.Attributes_Labels__r.size() > 0) {
	                infoWp.filters.add(new FilterWrapper(label.Id, label.Name, label.Required__c, label.Ref_Limit_to_Acct_or_Cntct__c));
	            }
	        } 
	        
    		if (refLeadId != null && refLeadId != '') {
	    		List<Reference_Lead__c> refLeads = WithoutSharingHelperController.getReferenceLeads(new Set<String> { refLeadId });
	    		
	            if (refLeads.size() > 0) {
	                Reference_Lead__c referenceLead = refLeads[0];
	                
	                if (referenceLead.Contact__c == null && referenceLead.Reference_Lead_Account__c != null) {
		                infoWp.selectedAccount = referenceLead.Reference_Lead_Account__c;
		                infoWp.selectedAccountName = referenceLead.Reference_Lead_Account__r.Name;
		            } else if (referenceLead.Contact__c != null) {
		                infoWp.selectedAccount = referenceLead.Reference_Lead_Account__c;
		                infoWp.selectedAccountName = referenceLead.Reference_Lead_Account__r.Name;
		                infoWp.selectedContact = referenceLead.Contact__c;
		                infoWp.selectedContactName = referenceLead.Contact__r.Name;
		            }
	            }
    		} else if (accountId != null && accountId != '' && !isFromProfileUpdate) {
    			infoWp.selectedAccount = accountId;
    			Set<String> accountsIds = new Set<String>();
    			
    			if (ContactId != null && ContactId != '') {
    				infoWp.selectedContact = ContactId;
    				//changes related to Ticket #637 by rekha 
    				infoWp = fetchSharedAccounts(ContactId, accountId, infoWp, cs);
    				
    				//changes related to Ticket #658 by rekha 
    				for (Contact con : WithoutSharingHelperController.getContacts(new Set<String> { ContactId }).values()) {
    					infoWp.selectedAccountName = con.Account.Name;
    					infoWp.selectedContactName = (con.FirstName != null && con.FirstName != '' ? con.FirstName + ' ' : '') + con.LastName;
    				}
    			}
    			
    			if (infoWp.accountList.size() == 0 && (infoWp.selectedAccountName == null || infoWp.selectedAccountName == '')) {
    				accountsIds.add(accountId);
    				
    				for (Account acc : WithoutSharingHelperController.getAccounts(accountsIds)) {
    					infoWp.selectedAccountName = acc.Name;
    				}
    			}
    		} else if (isFromProfileUpdate) {
    			infoWp.selectedAccount = accountId;
    			Set<String> accountsIds = new Set<String>();
    			
    			if (contactId != null && contactId != '') {
    				infoWp.selectedContact = contactId;
    				
    				//changes related to Ticket #658 by rekha 
    				for (Contact con : WithoutSharingHelperController.getContacts(new Set<String> { ContactId }).values()) {
    					//infoWp.selectedAccountName = con.Account.Name;
    					infoWp.selectedContactName = (con.FirstName != null && con.FirstName != '' ? con.FirstName + ' ' : '') + con.LastName;
    				}
    			}
    			
    			if (infoWp.accountList.size() == 0 && (infoWp.selectedAccountName == null || infoWp.selectedAccountName == '')) {
    				accountsIds.add(accountId);
    				
    				for (Account acc : WithoutSharingHelperController.getAccounts(accountsIds)) {
    					infoWp.selectedAccountName = acc.Name;
    				}
    			}
    		}
    		
    		if (infoWp.selectedContact == null || infoWp.selectedContact == '') {
    			//changes related to Ticket #658 by rekha 
    			infoWp = fetchContacts(accountId, ContactId, infoWp, cs);
    		}
    		// added for #1138 - Gaurav Saini (17 Nov, 2017)
    		String tempAccId = '';
    		
    		if (refLeadId != null && refLeadId != '' && infoWp.selectedAccount != '') {
    			tempAccId = infoWp.selectedAccount;
    		}
    		
    		//changes related to Ticket #658 by rekha 
    		if (contactMap == null || contactMap.size() == 0) {
        		infoWp = fetchContacts(tempAccId, ContactId, infoWp, cs);
    		}
    		
	        if (accountMap == null || accountMap.size() == 0) {
	        	fetchAccounts(new Set<String> {accountId});
	        }
    		infoWp = prePopulateAccountAttribute(infoWp);
    	} catch(Exception e) {
    		infoWp.error = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
    	return infoWp;
    }
    /**
     * Method to get all informations of available contacts
     * Created By: Rekha Jangir @Dec/28/2016
     * Ticket #658
     */
    private static InfoWrapper fetchContacts(String accId, string conId, InfoWrapper infoWp, Custom_Settings__c cs) {
    	Set<Id> contactIdsForAttMapping = new Set<Id>();
    	
    	if (conId == null || conId == '') {
    		contactIdsForAttMapping = WithoutSharingHelperController.getAccountContactsForNomination(accId, cs);
    	} else {
    		contactIdsForAttMapping.add(conId);
    	}
    		
    	//make dynamic query for account to get values of mapped attribute
        String theQuery = 'SELECT Id, Name, Title, Email, Phone, AccountId';
        
        for (Schema.SObjectField s : fldObjConMapValues) {
            Schema.DescribeFieldResult fieldDesc = s.getDescribe();
            
            if (fieldDesc.getName() != 'OtherGeocodeAccuracy' 
            		&& fieldDesc.getName() != 'MailingGeocodeAccuracy' && 
            		(fieldDesc.getType() == Schema.DisplayType.PICKLIST || 
            		fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST)) {
                String theName = fieldDesc.getName();
                // Continue building your dynamic query String
            	theQuery += ', ' + theName;
            }
        }
        //re #992
        theQuery += ', ( SELECT Id, Account__c, Contact__c, Name, Is_Referenceable__c, Referenceability_Status__c,'
                    +'RUL_Last_Activity_Date__c ,Reference_Program_Candidate__c, Roll_up_Referenceability_to_All_Accounts__c,'
                    +'Roll_up_Referenceability_to_Primary_Acc__c FROM Reference_Basic_Informations__r) FROM Contact WHERE ';
        if ((conId == null || conId == '') && accId != null && accId != '') {
        	theQuery += ' AccountId = \'' + accId + '\' OR Id IN :contactIdsForAttMapping ORDER BY LastName LIMIT 1001';
        } else {
        	theQuery += ' Id IN :contactIdsForAttMapping ORDER BY LastName LIMIT 1';
        }
        List<Contact> contacts = WithoutSharingHelperController.getContactsUsingDynamicSOQL(theQuery, contactIdsForAttMapping);
        
        // changes for #1138 - Gaurav Saini (17 Nov, 2017)
        if (infoWp.contactList.size() == 0) {
	        infoWp.contactList.add(new OptionWrapper('', '--None--'));
        }
        Integer size = 1;
        
        for (Contact con : contacts) {
        	
        	if (size < 1000) {
            	infoWp.contactList.add(new OptionWrapper(con.Id, con.Name));
            	contactMap.put(con.Id, con);
        	} else {
        		break;
        	}
            size++;
        }
        
        if (contacts.size() > 999) {
        	infoWp.isLimitExceeded = true;
        }
        return infoWp;
    }
    
    /**
     * Method to get all related accounts to selected contact
     * Created By: Rekha Jangir @Dec/19/2016
     * Ticket #637
     */
    private static InfoWrapper fetchSharedAccounts(String contactId, String accountId, InfoWrapper infoWp, Custom_Settings__c cs) {
    	
    	if (cs.Shared_Contacts__c) {
	    	//get shared accounts of contact
	    	Map<String, Set<String>> contactAccountMap = WithoutSharingHelperController.getRelatedAccounts(new Set<String> { contactId }, cs);
	    	Set<String> accountsIds = new Set<String>();
	            	
	        if (contactAccountMap != null && contactAccountMap.size() > 0 && contactAccountMap.containsKey(contactId) && 
	        		contactAccountMap.get(contactId).size() > 0) {
	        			
	        	for (String accId : contactAccountMap.get(contactId)) {
	        		accountsIds.add(accId);
	        	}
	        	
	        	if (accountsIds.size() > 0) {
	        		accountsIds.add(accountId);
	        	}
	        	Integer size = 0;
	        	
	        	//get information of all accounts
	        	for (Account acc : fetchAccounts(accountsIds)) {
	        		
	        		if (size<1000) {
	        			infoWp.accountList.add(new OptionWrapper(acc.Id, acc.Name));
	        		} else {
	    				infoWp.isLimitExceeded = true;
	    				break;
	        		}
	    			size++;
	        	}
	    	}
    	}
    	return infoWp;
    }
    
    /**
     * Method to get all informations of available accounts
     * Created By: Rekha Jangir @Dec/19/2016
     * Ticket #637
     */
    private static List<Account> fetchAccounts(Set<String> accountIds) {
    	//make dynamic query for account to get values of mapped attribute
        String theQuery = 'SELECT Id, Name';
        
        for (Schema.SObjectField s : fldObjMapValues) {
            Schema.DescribeFieldResult fieldDesc = s.getDescribe();
            
            if (fieldDesc.getName() != 'BillingGeocodeAccuracy' 
            		&& fieldDesc.getName() != 'ShippingGeocodeAccuracy' && 
            		(fieldDesc.getType() == Schema.DisplayType.PICKLIST || 
            		fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST)) {
                String theName = fieldDesc.getName();
                // Continue building your dynamic query String
            	theQuery += ', ' + theName;
            }
        }
        theQuery += ' FROM Account WHERE Id IN :accountIds';
        List<Account> accounts = WithoutSharingHelperController.getAccountUsingDynamicSOQL1(theQuery, accountIds);
        
        for (Account acc : accounts) {
        	accountMap.put(acc.Id, acc);
        }
        return accounts;
    }
    
    /**
     * Method to get selected value of mapped attribute of all availavle accounts
     * Created By: Rekha Jangir @Dec/19/2016
     * Ticket #637
     * Modified By: Rekha Jangir @Dec/28/2016 regarding #658
     */
    private static InfoWrapper prePopulateAccountAttribute(InfoWrapper infoWp) {
    	Set<String> attMappingsAccount = new Set<String>();
    	Map<String, Map<String, String>> accountFieldValues = new Map<String, Map<String, String>>();
    	Set<String> attMappingsContact = new Set<String>();
    	Map<String, Map<String, String>> contactFieldValues = new Map<String, Map<String, String>>();
    	
    	//get all attribute mappings
    	for (Attribute_Mapping__c attMapping : [SELECT Object__c, Id, Related_Object__c, Is_Related_Mapping__c, Filter_Label_Name__c, Field_Api_Name__c, 
    											Field__c, Attribute_Name__c, Is_Related_MultiSelectPicklist__c FROM Attribute_Mapping__c 
    											WHERE (Object__c = :ConstantsController.ACCOUNT OR Object__c = :ConstantsController.CONTACT ) 
    											AND Is_Related_Mapping__c = false]) {

            if (attMapping.Object__c == ConstantsController.ACCOUNT) {
            	
	        	for (Account account : accountMap.values()) {
	        		
	        		if (!accountFieldValues.containsKey(account.Id)) {
	        			accountFieldValues.put(account.Id, new Map<String, String>());
	        		}
	        		
	        		//map attribute name with account field value
		            if (fldObjAccMap.containsKey(attMapping.Field_Api_Name__c) && account.get(attMapping.Field_Api_Name__c) != null) {
		                accountFieldValues.get(account.Id).put(attMapping.Attribute_Name__c, String.valueOf(account.get(attMapping.Field_Api_Name__c)));
		            }
	        	}
	        	attMappingsAccount.add(attMapping.Id);
            } else if (attMapping.Object__c == ConstantsController.CONTACT) {
            	
	        	for (Contact contact : ContactMap.values()) {
	        		
	        		if (!contactFieldValues.containsKey(contact.Id)) {
	        			contactFieldValues.put(contact.Id, new Map<String, String>());
	        		}
	        		
	        		//map attribute name with account field value
		            if (fldObjConMap.containsKey(attMapping.Field_Api_Name__c) && contact.get(attMapping.Field_Api_Name__c) != null) {
		                contactFieldValues.get(contact.Id).put(attMapping.Attribute_Name__c, String.valueOf(contact.get(attMapping.Field_Api_Name__c)));
		            }
	        	}
	        	attMappingsContact.add(attMapping.Id);
            }
        }
        
        if (attMappingsAccount != null && attMappingsAccount.size() > 0) {
        	List<Attribute__c> rootLevelAttributesAcc = new List<Attribute__c>();
        	List<Attribute__c> rootLevelAttributesCon = new List<Attribute__c>();
        	//get all root level attributes of attribute mappings
            List<Attribute__c> rootLevelAttributes = [SELECT Level__c, Name, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Object__c, 
            						Attribute_Mapping__r.Is_Related_Mapping__c, (SELECT Id, Name, Level__c, Product_ID__c FROM Attributes__r WHERE Level__c = 1) 
            						FROM Attribute__c WHERE Level__c = 0 AND (Attribute_Mapping__c IN :attMappingsAccount 
            						OR Attribute_Mapping__c IN :attMappingsContact)];
            Map<String, String> AttributeLabelMap = new Map<String, String>();
            Set<String> attIds = new Set<String>();
            
            for (Attribute__c root : rootLevelAttributes) {
            	
            	if (attMappingsAccount.contains(root.Attribute_Mapping__c)) {
            		rootLevelAttributesAcc.add(root);
            	} else {
            		rootLevelAttributesCon.add(root);
            	}
            	
                for (Attribute__c attribute : root.Attributes__r) {
                    attIds.add(attribute.Id);
                    break;
                }
            }
			allFilters = new Set<String>();
            
            //get attribute filters
            for (Attributes_Labels__c attLabel : [SELECT Label__c, Attribute__r.Parent__c FROM Attributes_Labels__c WHERE Attribute__c IN :attIds]) {
                AttributeLabelMap.put(attLabel.Attribute__r.Parent__c, attLabel.Label__c);
				allFilters.add(attLabel.Label__c);
            }
            
            for (Account account : accountMap.values()) {
            	Map<String, Set<String>> selectedLabelMap = new Map<String, Set<String>>();
            	Map<String, String> accFieldValues = accountFieldValues.get(account.Id);
            	
	            for (Attribute__c root : rootLevelAttributesAcc) {
	            	
	                if (allFilters.contains(AttributeLabelMap.get(root.Id)) && 
	                		root.Attribute_Mapping__r.Object__c == ConstantsController.ACCOUNT) {
						
	                    if (!selectedLabelMap.containsKey(AttributeLabelMap.get(root.Id))) {
	                        selectedLabelMap.put(AttributeLabelMap.get(root.Id), new Set<String>());
						}
						
                        if (accFieldValues.containsKey(root.Name)) {
                        	
		                    for (Attribute__c attribute : root.Attributes__r) {
		                    	
		                    	//if attribute name is matched with account field value then add this attribute id in map
		                        if (accFieldValues.get(root.Name) == attribute.Name) {
		                            selectedLabelMap.get(AttributeLabelMap.get(root.Id)).add(attribute.Id);
		                            break;
		                        } else if (accFieldValues.get(root.Name).contains(';')) {
		                        	
		                            for (String value : accFieldValues.get(root.Name).split(';')) {
		                            	
		                                if (value.trim() == attribute.Name) {
		                                    selectedLabelMap.get(AttributeLabelMap.get(root.Id)).add(attribute.Id);
		                                }
		                            }
		                        }
		                    }
	                	}
	                }
	            }
	            infoWp.accountLabelAttValues.put(account.Id, selectedLabelMap);
	        }
	        
	        for (Contact contact : contactMap.values()) {
            	Map<String, Set<String>> selectedLabelMap = new Map<String, Set<String>>();
            	Map<String, String> conFieldValues = contactFieldValues.get(contact.Id);
            	
	            for (Attribute__c root : rootLevelAttributesCon) {
	            	
	                if (allFilters.contains(AttributeLabelMap.get(root.Id)) && 
	                		root.Attribute_Mapping__r.Object__c == ConstantsController.CONTACT) {
	                		
	                    if (!selectedLabelMap.containsKey(AttributeLabelMap.get(root.Id))) {
	                        selectedLabelMap.put(AttributeLabelMap.get(root.Id), new Set<String>());
	                    }
	                        
                        if (conFieldValues.containsKey(root.Name)) {
		                    
		                    for (Attribute__c attribute : root.Attributes__r) {
		                    	
		                    	//if attribute name is matched with contact field value then add this attribute id in map
		                        if (conFieldValues.get(root.Name) == attribute.Name) {
		                            selectedLabelMap.get(AttributeLabelMap.get(root.Id)).add(attribute.Id);
		                            break;
		                        } else if (conFieldValues.get(root.Name).contains(';')) {
		                        	
		                            for (String value : conFieldValues.get(root.Name).split(';')) {
		                            	
		                                if (value.trim() == attribute.Name) {
		                                    selectedLabelMap.get(AttributeLabelMap.get(root.Id)).add(attribute.Id);
		                                }
		                            }
		                        }
		                    }
                        }
	                }
	            }
	            infoWp.contactLabelAttValues.put(contact.Id, selectedLabelMap);
	        }
        }
        return infoWp;
    }
    
    /**
     * RemoteAction to get all attributes to related Filters
     */
    @RemoteAction
    public static Map<String, List<RefTypeWrapper>> getAllFilterAttributes(String filterIdsJson) {
        Set<String> filterIds = (Set<String>) JSON.deserialize(filterIdsJson, Set<String>.class);
        Map<String, List<RefTypeWrapper>> lstAttributeWrapper = new Map<String, List<RefTypeWrapper>>();
        
        Map<Id, String> attribParentMap = new Map<Id, String>();
        Set<String> parentAttIds = new Set<String>();
        
        List<Attributes_Labels__c> attLables = [SELECT Name, Label__c, Id, Attribute__c, Attribute__r.Name,
    									Attribute__r.ParentIds__c FROM Attributes_Labels__c
    									WHERE Label__c IN :filterIds
    									AND Attribute__c != null
    									ORDER BY Attribute__r.Name
    									LIMIT :limits.getLimitQueryRows()];
        
        for (Attributes_Labels__c al : attLables) {
        	
        	if (al.Attribute__r.parentIds__c != null) {
                parentAttIds.addAll(al.Attribute__r.parentIds__c.split(','));
                attribParentMap.put(al.Attribute__c, al.Attribute__r.parentIds__c);
            }
        }
        
        for (Attribute__c att : [SELECT Id, Ref_Limit_to_Acct_or_Cntct__c, Level__c FROM Attribute__c WHERE Id IN :parentAttIds AND Level__c = 0]) {
        	
        	for (Id attId : attribParentMap.keySet()) {
        		
        		if (attribParentMap.get(attId) != null && attribParentMap.get(attId).contains(att.Id)) {
        			attribParentMap.put(attId, att.Ref_Limit_to_Acct_or_Cntct__c);
        		}
        	}
        }
        
        for (Attributes_Labels__c al : attLables) {
        	
        	if (!lstAttributeWrapper.containsKey(al.Label__c)) {
        		lstAttributeWrapper.put(al.Label__c, new List<RefTypeWrapper>());
        	}
        	lstAttributeWrapper.get(al.Label__c).add(new RefTypeWrapper(al.Attribute__r.Id, al.Attribute__r.Name, attribParentMap.get(al.Attribute__c)));
        }
        return lstAttributeWrapper;
    }
    
    /**
     * Method to prepare Chatter , Email & task data
     */
    private static void prepareChatterTaskItem(Nomination__c nominationForm, Custom_Settings__c cs) {
    	String SUBJECT = 'New @@@ Nomination';
		String NOMINATION_LINK = URL.getSalesforceBaseUrl().toExternalForm() + Page.NominationEditPage.getURL() + '?Id=';
        String NOMINATION_LINK_CHATTERSF1 = NOMINATION_LINK;
        List<sObject> postFeedItems = new List<sObject>();
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        Boolean checkChatterSetting = (UtilityController.isNativeChatterSetting && cs.Nomination_Chatter__c);
        Boolean checkEmailSetting = cs.Nomination_Email__c;
        Boolean checkSlackSetting = cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c;
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c nominationNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Nomination_Email__c'};

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Nomination_Email__c') {
                nominationNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
         
   	 	//REF-1316- Added check for CRP team member should be active	
   	 	List<User> publicGroupMembers = UtilityController.getCustomerReferenceTeam();
        String notificationBody;
        
        if (nominationForm.Contact__c != null) {
            notificationBody = nominationNotification.DC_Message__c + '\n\n' + nominationNotification.Default__c;
            notificationBody = notificationBody.replace('[Account/Contact]', 'Contact')
                                                .replace('[Contact Name]', nominationForm.Contact__r.Name)
                                                .replace('[Account Name]', nominationForm.Account__r.Name)
                                                .replace('[Nominator]', nominationForm.CreatedBy.Name);
        	
            if (checkEmailSetting) {
            	
                for (User member : publicGroupMembers) {
                    String userId = member.Id;
                    
                    if (userId.startsWith('005')) {
                        listmail.add(MailChatterController.prepareEmail(nominationNotification.Section_Name__c.replace('[Account/Contact]', 'Contact'), userId,
                            notificationBody + '\n\n' + nominationNotification.Section_Name__c.replace('[Account/Contact]', 'Contact')
                                + ': <a href="' + NOMINATION_LINK_CHATTERSF1 + nominationForm.Id + '">' + NOMINATION_LINK_CHATTERSF1 + nominationForm.Id + '</a>', false, headerDocId, footerDocId));
                    }
                }
            }
        	
            if (checkChatterSetting) {
            	
                for (User member : publicGroupMembers) {
                    String userId = member.Id;
                    
                    if (userId.startsWith('005')) {
                        postFeedItems.add(MailChatterController.preparePost(nominationNotification.Section_Name__c.replace('[Account/Contact]', 'Contact'), userId,
                            notificationBody, NOMINATION_LINK_CHATTERSF1 + nominationForm.Id));
                    }
                }
            }
        } else {
            notificationBody = nominationNotification.DC_Message__c + '\n\n' + nominationNotification.Default__c;
            notificationBody = notificationBody.replace('[Account/Contact]', 'Account')
                                                .replace('Contact: [Contact Name]\n', '')
                                                .replace('[Account Name]', nominationForm.Account__r.Name)
                                                .replace('[Nominator]', nominationForm.CreatedBy.Name);
        	
            if (checkEmailSetting) {
            	
                for (User member : publicGroupMembers) {
                    String userId = member.Id;
                    
                    if (userId.startsWith('005')) {
                        listmail.add(MailChatterController.prepareEmail(nominationNotification.Section_Name__c.replace('[Account/Contact]', 'Account'), userId,
                            notificationBody + '\n\n' + nominationNotification.Section_Name__c.replace('[Account/Contact]', 'Account')
                                + ': <a href="' + NOMINATION_LINK_CHATTERSF1 + nominationForm.Id + '">' + NOMINATION_LINK_CHATTERSF1 + nominationForm.Id + '</a>', false, headerDocId, footerDocId));
                    }
                }
            }

            if (checkChatterSetting) {
            	
                for (User member : publicGroupMembers) {
                    String userId = member.Id;
                    
                    if (userId.startsWith('005')) {
                        postFeedItems.add(MailChatterController.preparePost(nominationNotification.Section_Name__c.replace('[Account/Contact]', 'Account'), userId,
                            notificationBody, NOMINATION_LINK_CHATTERSF1 + nominationForm.Id));
                    }
                }
            } 
        }

        if (checkSlackSetting) {
            Map<String, Object> slackReqBody = new Map<String, Object>();
            slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
            slackReqBody.put('orgId', UserInfo.getOrganizationId());
            List<Map<String, String>> messagesList = new List<Map<String, String>>();
            Map<String, String> tempReqBodyMap = new Map<String, String>();

            if (nominationForm.Contact__c != null) {
                tempReqBodyMap.put('text', notificationBody
                    + '\n<' + NOMINATION_LINK_CHATTERSF1 + nominationForm.Id + '|'
                    + nominationNotification.Section_Name__c.replace('[Account/Contact]', 'Contact') + '>');
            } else {
                tempReqBodyMap.put('text', notificationBody
                    + '\n<' + NOMINATION_LINK_CHATTERSF1 + nominationForm.Id + '|'
                    + nominationNotification.Section_Name__c.replace('[Account/Contact]', 'Account') + '>');
            }
            messagesList.add(tempReqBodyMap);
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
        }

        // Insert List of postFeedItems
        if (postFeedItems.size() > 0) {
            postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
        }

        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
    }
    
    /**
     * RemoteAction to submit the nomination
     */
    @RemoteAction
    public static String submit(String infoJson, String refLeadId) {
    	Savepoint sp = Database.setSavepoint();
        
        try {
        	
        	if (checkPermissions(refLeadId)) {
	        	InfoWrapper infoWp = (InfoWrapper)JSON.deserialize(infoJson, InfoWrapper.class);
	        	Custom_Settings__c cs = UtilityController.getCustomSettings();
	        	Nomination__c nominationForm = new Nomination__c();
	        	
	        	if (infoWp.selectedContact != null && infoWp.selectedContact != '') {
	                nominationForm.Contact__c = infoWp.selectedContact;
	            }
	            
	            if (infoWp.selectedAccount != null && infoWp.selectedAccount != '') {
	                nominationForm.Account__c = infoWp.selectedAccount;
	            }
	            nominationForm.Status__c = ConstantsController.NOT_STARTED;
	            nominationForm.Email_Enabled__c = cs.Nomination_Email__c;
	            String refValues = '';
	            Set<Id> refIds = new Set<Id>();
	            
	            for (RefTypeWrapper ref : infoWp.refTypes) {
	            	
	            	if (ref.isSelected && ref.isShow) {
	            		refIds.add(ref.id);
	            		refValues = (refValues == '' ? ref.name : refValues + ', ' + ref.name);
	            	}
	            }
	            nominationForm.Referenceability__c = refValues;
	            
	            for (FieldWrapper fw : infoWp.nomiFields) {
	            	
	            	if (fw.type == 'Boolean') {
	            		nominationForm.put(fw.name, (fw.value == 'true' ? true : false));
	            	} else if (fw.type == 'Date') {
	        			
	        			if (fw.value == null || fw.value == '') {
	        				nominationForm.put(fw.name, null);
	        			} else {
		        			Date date1 = (Date)JSON.deserialize(fw.value, Date.class);
		        			nominationForm.put(fw.name, date1);
	        			}
	        		} else if (fw.type == 'DateTime') {
	        			
	        			if (fw.value == null || fw.value == '') {
	        				nominationForm.put(fw.name, null);
	        			} else {
		        			DateTime date1 = (DateTime) JSON.deserialize(fw.value, DateTime.class);
		        			nominationForm.put(fw.name, date1);
	        			}
	        		} else if (fw.type == 'Number' || fw.type == 'Currency' || fw.type == 'Percent') {
	        			nominationForm.put(fw.name, Decimal.valueOf(fw.value));

	        		} else if (fw.type == 'PICKLIST') {
                        nominationForm.put(fw.name, fw.value);
                        
                    } else if (fw.type == 'MULTIPICKLIST') {
                        
                        if (fw.multiPickOptions.size() > 0) {
                            String multiValues = '';
                            Boolean start = true;
                            
                            for(MultiPicklistWrapper val : fw.multiPickOptions) {
                                
                                if (start) {
                                    multiValues = val.value;
                                    start = false;
                                } else { 
                                    multiValues = multiValues + ';' + val.value;
                                }                               
                            }
                            nominationForm.put(fw.name, multiValues);
                        }
                        
                    } else if (fw.type != 'Reference') {
	        			nominationForm.put(fw.name, fw.value);
                    }
	            }
	            nominationForm.Other_Info__c = infoWp.notes;
	            insert nominationForm;
	            nominationForm = [SELECT Id, Name, CreatedBy.Name, Status__c, Contact__c, Contact__r.Name, Account__r.Name, Referenceability__c, Account__c 
	            					FROM Nomination__c WHERE Id = :nominationForm.Id];
	            List<Reference_Lead__c> refLeads = WithoutSharingHelperController.getReferenceLeads(new Set<String> { refLeadId });
	            
	            if (refLeads.size() > 0) {
	                Reference_Lead__c referenceLead = refLeads[0];
	                referenceLead.Nomination__c = nominationForm.Id;
	                referenceLead.Reference_Lead_Status__c = 'Converted to Nomination';
	                referenceLead.Nominated__c = true;
	                referenceLead.Response_received__c = true;
	                referenceLead.Notification_response__c = 'Yes, this is a very happy account';
	                referenceLead = WithoutSharingHelperController.createRefLead(referenceLead);  
	            }
	            // insert referenceabilities for this nomination
	            List<Nomination_Referenceability__c> nominationRefTypeList = new List<Nomination_Referenceability__c>();
	            
		        for (Id ref : refIds) {
	                nominationRefTypeList.add(new Nomination_Referenceability__c(Nomination__c = nominationForm.Id, Referenceability_Type__c = ref));
		        }
		        
		        if (nominationRefTypeList.size() > 0) {
		            ConstantsController.nomReferenceFromPage = true;
		            insert nominationRefTypeList;
		        }
		        // insert filters for this nomination
		        List<Nomination_Label__c> nominationFilterList = new List<Nomination_Label__c>();
		        Map<String, Set<String>> filterMap = new Map<String, Set<String>>();
		        
		        for (FilterWrapper filter : infoWp.filters) {
		        	
		            if (filter.selectedAttIds.size() > 0 && filter.isShow) {
		            	Set<String> attIds = new Set<String>();
		            	attIds.addAll(filter.selectedAttIds);
		            	filterMap.put(filter.id, attIds);
		                Nomination_Label__c nomiLabelObj = new Nomination_Label__c(Label__c = filter.id, Nomination__c = nominationForm.Id);
		                nominationFilterList.add(nomiLabelObj);
		            }
		        }
		        
		        // insert attributes for this nomination
		        List<Nomination_Label_Attribute__c> NominationFilterAttList = new List<Nomination_Label_Attribute__c>();
		        
		        if (nominationFilterList.size() > 0) {
		            insert nominationFilterList;
		            
		            for (Nomination_Label__c nomiObj : [SELECT Label__c, Id FROM Nomination_Label__c WHERE Nomination__c = :nominationForm.Id]) {
		            	
		                if (filterMap != null && filterMap.containsKey(nomiObj.Label__c)){
		                	
			                for (String attId : filterMap.get(nomiObj.Label__c)) {
			                    NominationFilterAttList.add(new Nomination_Label_Attribute__c(Attribute__c = attId, Nomination_Label__c = nomiObj.Id));
			                }
		                }
		            }
		            
		            if (NominationFilterAttList.size() > 0) {
		                insert NominationFilterAttList;
		            }
		        }
		        decimal rewardPoints = 0;
		        String actionMessage = '';
		       
		        if (RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c ==  true) {
		        	List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
		        	List<Referenceability_Type__c> refType = new List<Referenceability_Type__c>();
		        	
		        	if (refLeads.size() > 0) {
		        		refType = [SELECT Name, Id, Sales_Point__c FROM Referenceability_Type__c WHERE Visible__c = true AND Sales_Reward__c = true AND  
		        			(Referenceability_code__c = :ConstantsController.RLF_RESPONSE Or Referenceability_code__c = :ConstantsController.NOMINATION_SUBMITTED) 
		        			ORDER BY CreatedDate LIMIT 2];
		        	} else {
		        		refType = [SELECT Name, Id, Sales_Point__c FROM Referenceability_Type__c WHERE Visible__c = true AND Sales_Reward__c = true AND  
		        						Referenceability_code__c = :ConstantsController.NOMINATION_SUBMITTED ORDER BY Name LIMIT 1];
		        	}
		        	
		        	for (Referenceability_Type__c ref : refType) {
		        		
		        		//re #583 -Null check for User reward points. 
		        		if (ref.Sales_Point__c != Null) {	        			 
			        		rewardsToBeInsert.add(new Reward__c(Amount__c = ref.Sales_Point__c, Referenceability_Type__c = ref.Id, 
			        								Transaction__c = ConstantsController.ISSUE, RewardDate__c = Date.Today() 
													, User__c = UserInfo.getUserId() )); 
					        
					        //re #591 NEW field  Onscreen Notification__c allow for on/off for onscreen notification.
				            if (cs.User_Reward_Onscreen_Notification__c) {
								// re REF-1890 Change position to set reward value 
								rewardPoints += ref.Sales_Point__c;
				            	actionMessage = (actionMessage == '' ? ref.Name : actionMessage + ' and ' + ref.Name);
				            }
		        		}
		        	}	
			        
			        if (rewardsToBeInsert.size() > 0) {
			        	UtilityController.isUserProfileExist(UserInfo.getUserId()); 
		         		WithoutSharingHelperController.insertRewards(rewardsToBeInsert); 
			        } 
		        }
		        prepareChatterTaskItem(nominationForm, cs);
	        	return 'success;points:' + rewardPoints + ';msg:' + actionMessage;
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        } catch(Exception e) {
        	Database.rollback(sp);
        	return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
    }
    
    /**
     * Wrapper class for request and Account request information
     */
 	public class InfoWrapper {
 		public String header { get; set; }
 		public String subHeader { get; set; }
 		public String selectedAccount { get; set; }
 		public String selectedContact { get; set; }
 		public String selectedAccountName { get; set; }
 		public String selectedContactName { get; set; }
 		public Boolean isLimitExceeded { get; set; }
 		public List<OptionWrapper> accountList { get; set; }
 		public Map<String, Map<String, Set<String>>> accountLabelAttValues { get; set; }
 		public Map<String, Map<String, Set<String>>> contactLabelAttValues { get; set; }
 		public List<OptionWrapper> contactList { get; set; }
 		public List<HeaderWrapper> sections { get; set; }
 		public List<RefTypeWrapper> refTypes { get; set; }
 		public List<FilterWrapper> filters { get; set; }
 		public List<FieldWrapper> nomiFields { get; set; }
 		public String notes { get; set; }
 		public String error { get; set; }
	    
	    public InfoWrapper() {
	    	header = '';
	    	subHeader = '';
	    	refTypes = new List<RefTypeWrapper>();
	    	filters = new List<FilterWrapper>();
	    	sections = new List<HeaderWrapper>();
	    	nomiFields = new List<FieldWrapper>();
	    	selectedAccount = '';
            selectedContact = '';
            selectedAccountName = '';
            selectedContactName = '';
            notes = '';
            accountList = new List<OptionWrapper>();
            contactList = new List<OptionWrapper>();
            isLimitExceeded = false;
            accountLabelAttValues = new Map<String, Map<String, Set<String>>>();
            contactLabelAttValues = new Map<String, Map<String, Set<String>>>();
            error = '';
	    }
 	}
 	
 	/**
     * Wrapper Class
     */
 	public class HeaderWrapper {
 		public String name { get; set; }
 		public String label { get; set; }
 		public Boolean visible { get; set; }
 		public Boolean required { get; set; }
 		
 		public HeaderWrapper(Data_Mapping__c dm) {
 			this.name = dm.Name;
 			this.label = dm.Field_API_Name__c;
 			this.visible = dm.Visible__c;
 			this.required = dm.Required__c;
 		}
 	}
 	
 	/**
     * Wrapper Class
     */
 	public class RefTypeWrapper {
 		public Boolean isSelected { get; set; }
 		public String id { get; set; }
 		public String name { get; set; }
 		//changes regarding #570 
		public Boolean avaliableForAccount { get; set; }
		public Boolean avaliableForContact { get; set; }
		public Boolean isShow { get; set; }
 		
 		public RefTypeWrapper(String refId, String refName, String option) {
 			isSelected = false;
 			isShow = true;
 			name = refName;
 			id = refId;
 			this.avaliableForAccount = (option == null || option == '' || option == 'Account' ? true : false);
			this.avaliableForContact = (option == null || option == '' || option == 'Contact' ? true : false);
 		}
 		
 	}
 	
 	/**
     * Wrapper Class
     */
 	public class FilterWrapper {
 		public Boolean required { get; set; }
 		public String id { get; set; }
 		public String name { get; set; }
 		public String selectedAttributes { get; set; }
 		public List<String> selectedAttIds { get; set; }
 		//changes regarding #570 
		public Boolean avaliableForAccount { get; set; }
		public Boolean avaliableForContact { get; set; }
		public Boolean isShow { get; set; }
 		
 		public FilterWrapper(String filterId, String filterName, Boolean required, String option) {
 			this.required = required;
 			isShow = true;
 			name = filterName;
 			id = filterId;
 			selectedAttIds = new List<String>();
 			selectedAttributes = '';
 			this.avaliableForAccount = (option == null || option == '' || option == 'Account' ? true : false);
			this.avaliableForContact = (option == null || option == '' || option == 'Contact' ? true : false);
 		}
 	}
 	
 	/**
     * Wrapper Class
     */
 	public class OptionWrapper {
 		public String id { get; set; }
 		public String name { get; set; }
 		
 		public OptionWrapper(String id, String name) {
 			this.id = id;
 			this.name = name;
 		}
 	}
 	
 	/**
     * Wrapper Class
     */
    public class FieldWrapper {
        public String name { get; set; }
        public String label { get; set; }
		public String inlineHelpText { get; set; }
        public String type { get; set; }
        public List<String> picklistValues { get; set; }
        public String value { get; set; }
        public Boolean required { get; set; }
		public List<MultiPicklistWrapper> multiPickOptions { get; set; }
		public List<MultiPicklistWrapper> multiPickAvailOptions { get; set; }
        
        public FieldWrapper (Schema.DescribeFieldResult field, Data_Mapping__c dm) {
            this.name = field.getName();
            this.label = field.getLabel();
            this.type = String.valueOf(field.getType());
            this.picklistValues = new List<String>();
            this.multiPickOptions = new List<MultiPicklistWrapper>();
            this.multiPickAvailOptions = new List<MultiPicklistWrapper>();
            this.required = dm.Required__c;
			this.inlineHelpText = field.getInlineHelpText();
            value = '';
            
            if (this.type == 'PICKLIST' || this.type == 'MULTIPICKLIST') {
            	
            	for (Schema.PicklistEntry f : field.getPicklistValues()) {
            		
		            if (value == '') {
		            	value = String.valueOf(f.value);
		            }
		            picklistValues.add(String.valueOf(f.value));
                    
                    if (this.type == 'MULTIPICKLIST') {
                       multiPickAvailOptions.add(new MultiPicklistWrapper(String.valueOf(f.label), String.valueOf(f.value)));
                    }
		        }
            }
        }
    }
    
    // class to get multipicklist options
    public class MultiPicklistWrapper { 
        String value { get; set; }
        String name { get; set; }
        
        public MultiPicklistWrapper(String label,String value) { 
            this.name = label; 
            this.value = value;   
        }
    }
}