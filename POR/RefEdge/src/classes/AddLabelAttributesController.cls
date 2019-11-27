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
 * Page: AddLabelAttributesPage
 * Description : this class used to add attributes on Account, Contact, Filter and Reference Content
 * Modified by: Rekha @Feb 16 2017
 */
public with sharing class AddLabelAttributesController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private String Id, labelId, contactAccountId, contentId;
    public Id objId;
    public List<Node> tempTree, childTree;
    public String contactId { get; set; }
    public String accountId { get; set; }
    // Added for #366 - id of the account for which the profile is being updated
    public String PUMAccountId { get; set; }
    public List<Node> treeNodes { get; set; }
    public String childHtml { get; set; }
    public String selectedNodeId { get; set; }
    public String treeRoots { get; set; }
    public String checkedIds { get; set; }
    public String titleName { get; set; }
    public Boolean isAccount { get; set; }
    public Boolean isContact { get; set; }
    public Boolean isLabel { get; set; }
    public Boolean isContent { get; set; }
    public Boolean hasAttribRecords { get; set; }
    public Boolean isInheritable { get; set; }
    public Boolean isContactReferenceProgramMember { get; set; }
    public Boolean isAccountReferenceProgramMember { get; set; }
    public Boolean isContactCandidate { get; set; }
    public Boolean isAccountCandidate { get; set; }
    public List<Account_Attribute__c> accountAttributes { get; set; }
    public List<Contact_Attribute__c> contactAttributes { get; set; }
    public List<Attributes_Labels__c> attributeLabels { get; set; }
    public List<Content_Attribute__c> contentAttribute { get; set; }
    public Decimal level { get; set; }
    public String status { get; set; }
    public Boolean makeAccountMember { get; set; }
    public Boolean makeContactMember { get; set; }
    public Boolean makeAccountCandidate { get; set; }
    public Boolean makeContactCandidate { get; set; }
    public Reference_Refresh__c refRefresh { get; set; }
    private Custom_Settings__c cs;
    public String selectedAttributeId { get; set; }
    private Set<String> deleteAttIds;
    public List<Reference_Refresh_Update__c> quarantineUpdates { get; set; }
    public Boolean showFilterNecessaryMessage { get; set; }
	Set<String> attAttachedWithFilters = new Set<String>();
	public Boolean isfilterExistsForParent { get; set; }
    private Set<String> alreadyCreatedPUAttforAccount;
    private Set<String> alreadyCreatedPUAttforContact;
    private String pageNo = '';
    //Shared Contact code start
    public Boolean isSharedContact { get; set; }
    public List<SelectOption> accounts { get; set; }
    public List<SelectOption> selectedAccounts { get; set; }
    public String contactName { get; set; }
    public String accountName { get; set; }
    private Map<String, Reference_Basic_Information__c> accountIsReferenceableMap;
    public Boolean isSLDS { get; set; }
    //end
	/**
     * Constructor
     */
    public AddLabelAttributesController() {
    	
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        checkedIds = '';
	        PUMAccountId = '';
	        
	        if (Apexpages.currentPage().getParameters().get('PUMAccountId') != null) {
	        	PUMAccountId = Apexpages.currentPage().getParameters().get('PUMAccountId');
	        }
	        Id = Apexpages.currentPage().getParameters().get('Id');
	        String refRefreshId = Apexpages.currentPage().getParameters().get('refRefreshId');
	        pageNo = Apexpages.currentPage().getParameters().get('pageno');
	        objId = Id;
	        quarantineUpdates = new List<Reference_Refresh_Update__c>();
	        makeAccountMember = false;
	        makeAccountCandidate = false;
	        makeContactCandidate = false;
	        makeContactMember = false;
	        isSharedContact = false;
	        isAccountReferenceProgramMember = false;
	        isContactReferenceProgramMember = false;
	        isAccountCandidate = false;
	        isContactCandidate = false;
	        cs = UtilityController.getCustomSettings();
	        //Shared Contact code
	        isSharedContact = cs.Shared_Contacts__c;
	        isContact = false;
	        isAccount = false;
	        isfilterExistsForParent = false;
	        showFilterNecessaryMessage = true;
	        Boolean addRefToAllAccountsRBI = false;
	        
	        if (isSharedContact) {
	        	addRefToAllAccountsRBI = cs.Roll_up_Attributes_to_All_Accounts__c;
	        }
	        status = SYSTEM.LABEL.Reference_Status_for_Attribute;
	        deleteAttIds = new Set<String>();
	        accountIsReferenceableMap = new Map<String, Reference_Basic_Information__c>();
	        alreadyCreatedPUAttforAccount = new Set<String>();
	        alreadyCreatedPUAttforContact = new Set<String>();
	        
	        if (refRefreshId != null && refRefreshId != '') {
	            List<Reference_Refresh__c> refRefreshs = WithoutSharingHelperController.getReferenceRefreshOnAddAtt(refRefreshId);
	            
	            if (refRefreshs.size() > 0) {
	                refRefresh = refRefreshs[0];
	                
	                if (refRefresh.Quarantined__c) {
	                	
	                    for (Reference_Refresh_Update__c rru : refRefresh.Reference_Refresh_Updates__r) {
	                    	
		                    if (rru.Removed__c) {
		                        deleteAttIds.add(rru.RecordToBeDeletedId__c);
		                    }
		                    quarantineUpdates.add(rru);
		                    
		                    if (rru.Contact__c != null && rru.Added__c) {
	                			alreadyCreatedPUAttforContact.add(rru.RecordsToBeInsertedId__c);
		                	} else if (rru.Account__c != null  && rru.Added__c) {
		                		alreadyCreatedPUAttforAccount.add(rru.RecordsToBeInsertedId__c);
		                	}
		                }
	                }
	            }
	        }
	        
	        if (Id.substring(0, 3) == '001') {
	            accountId = Id;
	            isAccount = true;
	            showFilterNecessaryMessage = true;
	            status = status.replace('@@@', System.Label.Account);
	        } else if (Id.substring(0, 3) == '003') {
	            isContact = true;
	            contactId = Id;
	            showFilterNecessaryMessage = true;
	            status = status.replace('@@@', System.Label.Contact);
	        } else {
	            Schema.SObjectType token = objId.getSObjectType();
	            Schema.DescribeSObjectResult dr = token.getDescribe();
	            
	            if (dr.getName().contains('Label__c')) {
	                labelId = Id;
	            	showFilterNecessaryMessage = false;
	            } else {
	                contentId = Id;
	            	showFilterNecessaryMessage = true;
	            }
	        }
	        createRoots();
	        
	        if (labelId != null) {
	            isLabel = true;
	            Label__c tempLabel = [SELECT name, (SELECT Attribute__r.Name, Attribute__r.Parent__r.Name, Attribute__r.level__c 
	            									FROM Attributes_Labels__r ORDER BY Attribute__r.Parent__r.Name) 
	            									FROM Label__c WHERE Id = :labelId LIMIT 1][0];
	            titleName = tempLabel.Name;
	            attributeLabels = tempLabel.Attributes_Labels__r;
	            
	            if (attributeLabels.size() != 0) {
	                hasAttribRecords = true;
	            } else {
	                hasAttribRecords = false;
	            }
	        }
	        
	        if (accountId != null) {
	        	List<Account> accountList = new List<Account>();
	        	
	            //changed for new object
	            if (refRefresh != null) {
	            	accountList = WithoutSharingHelperController.getAccountOnAddAtt(accountId, deleteAttIds);
	            } else {
	            	accountList = [SELECT Name, (SELECT Attribute__r.Name, Attribute__r.Parent__r.Name, Attribute__r.level__c, Is_fromMapping__c 
	            								FROM Account_Attributes__r WHERE Contact__c = null AND Reference_Content__c = null 
	            								ORDER BY Attribute__r.Parent__r.Name), 
	            								(SELECT Name, Account__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c 
	            								FROM Reference_Basic_Informations__r WHERE Contact__c = null) 
	            								FROM Account WHERE Id = :accountId LIMIT 1];
	            }
	        
	        	if (accountList.size() > 0) {
	        		Account tempAccount = accountList[0];
	        	
		            if (tempAccount.Reference_Basic_Informations__r.size() > 0) {
		                isAccountReferenceProgramMember = tempAccount.Reference_Basic_Informations__r[0].Is_Referenceable__c;
		                isAccountCandidate = tempAccount.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c;
		            }
		            titleName = tempAccount.Name;
		            accountName = tempAccount.Name;
		            accountAttributes = tempAccount.Account_Attributes__r;
		            
		            if (accountAttributes.size() != 0) {
		                hasAttribRecords = true;
		            } else {
		                hasAttribRecords = false;
		            }
	        	}
	        }
	        
	        if (contactId != null) {
	        	Set<String> accountIds = new Set<String>();
	        	List<Contact> contacts = new List<Contact>();
	        	
	            //changed for new object
	            if (refRefresh != null) {
	            	contacts = WithoutSharingHelperController.getContactOnAddAtt(contactId, deleteAttIds);
	            } else {
	            	contacts = [SELECT accountId, Name, (SELECT Attribute__r.Name, Account__r.Name, Attribute__r.Parent__r.Name, From_Account__c, 
	            					Attribute__r.level__c, Is_fromMapping__c FROM Contact_Attributes__r ORDER BY Attribute__r.Parent__r.Name),  
	            					(SELECT Name, Account__c, Contact__r.Name, Contact__c, Is_Referenceable__c, Reference_Program_Candidate__c, 
	            					Referenceability_Status__c, Roll_up_Attributes_to_All_Accounts__c, Roll_up_Attributes_to_Primary_Account__c 
	            					FROM Reference_Basic_Informations__r) FROM Contact WHERE Id = :contactId LIMIT 1];
	            }
	            
	            if (contacts.size() > 0) {
		            Contact tempContact = contacts[0];
		            
		            if (tempContact.Reference_Basic_Informations__r.size() > 0) {
		                isContactReferenceProgramMember = tempContact.Reference_Basic_Informations__r[0].Is_Referenceable__c;
		                isContactCandidate = tempContact.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c;
		                addRefToAllAccountsRBI = (tempContact.Reference_Basic_Informations__r[0].Roll_up_Attributes_to_All_Accounts__c 
		                					? true : (tempContact.Reference_Basic_Informations__r[0].Roll_up_Attributes_to_Primary_Account__c 
		            						? false : (cs.Roll_up_Attributes_to_All_Accounts__c)));
		            }
		            titleName = tempContact.Name;
		            contactName = tempContact.Name;
		            contactAccountId = tempContact.accountId;
		            contactId = tempContact.Id;
		            contactAttributes = tempContact.Contact_Attributes__r;
		            
		            if (contactAttributes.size() != 0) {
		                hasAttribRecords = true;
		            } else {
		                hasAttribRecords = false;
		            }
		            
		            //Shared Contact code start
		            if (isSharedContact) {
		            	accounts = new List<SelectOption>();
		            	selectedAccounts = new List<SelectOption>();
		            	Map<String, Set<String>> contactAccountMap = new Map<String, Set<String>>();
		            	
		            	if (refRefresh != null) {
		            		contactAccountMap = WithoutSharingHelperController.getRelatedAccounts(new Set<String> {contactId}, cs);
		            	} else {
		            		contactAccountMap = UtilityController.getRelatedAccounts(new Set<String> {contactId}, cs);
		            	}
		            	
		            	if (contactAccountMap != null && contactAccountMap.containsKey(tempContact.Id)) {
		                    accountIds.addAll(contactAccountMap.get(tempContact.Id));
		            	}
		            	accountIds.add(contactAccountId);
		            	List<Account> accountList = new List<Account>();
		            	
		            	if (refRefresh != null) {
		            		accountList = WithoutSharingHelperController.getAccountRecordsforLookup(accountIds, 200);
		            	} else {
		            		accountList = [SELECT Name, (SELECT Name, Id, Generic_Account__c, Account__c, Reference_Program_Candidate__c,
		            							Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c = null) 
		            							FROM Account WHERE Id IN :accountIds ORDER BY Name LIMIT 200];
		            	}
		            	
		            	for (Account acc : accountList) {
		            		
		            		//to exclude generic account
		            		if (acc.Reference_Basic_Informations__r.size() == 0 || (acc.Reference_Basic_Informations__r.size() > 0 
		            							&& !acc.Reference_Basic_Informations__r[0].Generic_Account__c)) {
			            		
			            		if (contactAccountId == acc.Id) {
				            		accountName = acc.Name;
			            		}
			            		
			            		// added for #366
			            		if (PUMAccountId != '' && PUMAccountId == acc.Id) {
			            			accountName = acc.Name;
			            		}
		
			            		if (acc.Reference_Basic_Informations__r.size() > 0) {
				                    accountIsReferenceableMap.put(acc.Id, acc.Reference_Basic_Informations__r[0]);
				                    
				                    if (contactAccountId == acc.Id) {
					            		isAccountReferenceProgramMember = acc.Reference_Basic_Informations__r[0].Is_Referenceable__c;
										isAccountCandidate = acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c;
					            	}
				                } else {
				                    accountIsReferenceableMap.put(acc.Id, new Reference_Basic_Information__c());
				                }
				                
				                if (addRefToAllAccountsRBI) {
				                	selectedAccounts.add(new SelectOption(acc.Id, acc.Name));
				                } else {
				                	
				                	if (PUMAccountId != '') {
				                		
				                		if (PUMAccountId == acc.Id) {
				                			selectedAccounts.add(new SelectOption(acc.Id, acc.Name));
				                		} else {
				                			accounts.add(new SelectOption(acc.Id, acc.Name));
				                		}
				                	} else {
				                		
					                	if (contactAccountId == acc.Id) {
					                		selectedAccounts.add(new SelectOption(acc.Id, acc.Name));
					                	} else {
					                		accounts.add(new SelectOption(acc.Id, acc.Name));
				                		}
				                	}
				                }
		            		}
		            	}
		            } else {
		            	List<Account> accounts = new List<Account>();
			        	
			            //changed for new object
			            if (refRefresh != null) {
			            	accounts = WithoutSharingHelperController.getContactAccountOnAddAtt(tempContact.accountId);
			            } else {
			            	accounts = [SELECT Name, (SELECT Attribute__r.Name, Attribute__r.Parent__r.Name, Attribute__r.level__c, Is_fromMapping__c 
			            					FROM Account_Attributes__r WHERE contact__c = null AND Reference_Content__c = null), 
			            					(SELECT Name, Account__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c 
			            					FROM Reference_Basic_Informations__r WHERE Contact__c = null) 
			            					FROM Account WHERE Id = :tempContact.accountId LIMIT 1];
			            }
			        
			        	if (accounts.size() > 0) {
			            	Account tempAccount = accounts[0];
				            accountName = tempAccount.Name;
				            
				            if (tempAccount.Reference_Basic_Informations__r.size() > 0) {
				                isAccountReferenceProgramMember = tempAccount.Reference_Basic_Informations__r[0].Is_Referenceable__c;
				                isAccountCandidate = tempAccount.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c;
				            }
			        	}
		            }
	            }
	        }
	        
	        if (contentId != null) {
	            isContent = true;
	            Reference_Content__c refContent = [SELECT Name, (SELECT Attribute__r.Name, Attribute__r.Parent__r.Name, Attribute__r.level__c 
	            										FROM Content_Attributes__r ORDER BY Attribute__r.Parent__r.Name) 
	            										FROM Reference_Content__c WHERE Id = :contentId LIMIT 1][0];
	            titleName = refContent.Name;
	            contentAttribute = refContent.Content_Attributes__r;
	            
	            if (contentAttribute.size() != 0) {
	                hasAttribRecords = true;
	            } else {
	                hasAttribRecords = false;
	            }
	        }
	        
	        if (refRefresh == null) {
	        	checkPermissions();
	        }
        }
    }
	/**
     * Method to get Reference Status
     */
    public void getAccountReferenceStatus() {
        //Shared Contact code start
        String accountFlags = ''; 
        
        if (selectedAccounts != null && selectedAccounts.size() > 0) {
        	
            for (SelectOption so : selectedAccounts) {
                Reference_Basic_Information__c accRbi = accountIsReferenceableMap.get(so.getValue());
                
                if (!accRbi.Reference_Program_Candidate__c && !accRbi.Is_Referenceable__c) {
                    accountFlags += 'b';
                } else if (accRbi.Reference_Program_Candidate__c ) {
                    accountFlags += 'c';
                }
            }
        } 
        
        if (accountFlags == '') {
            isAccountReferenceProgramMember = true;
            isAccountCandidate = false;
        } else if (accountFlags.contains('b')) {
            isAccountReferenceProgramMember = false;
            isAccountCandidate = false;
        } else if (accountFlags.contains('c')) {
            isAccountReferenceProgramMember = false;
            isAccountCandidate = true;
        }
    }
	/**
     * Method to create Root Attribute of tree
     */
    public void createRoots() {
        List<Attribute__c> listRootAtts = new List<Attribute__c>();
        
        //changes regarding #570 
        if (accountId != null) {
        	listRootAtts = [SELECT Id, Name, Level__c, Parent__c, Attribute_Mapping__c, Attribute_Mapping__r.Object__c, 
        									Attribute_Mapping__r.Field__c, Parent__r.Name,
        									(SELECT Id FROM Attributes__r LIMIT 1) FROM Attribute__c 
        									WHERE Level__c = 0 AND (Ref_Limit_to_Acct_or_Cntct__c = null
        									OR Ref_Limit_to_Acct_or_Cntct__c = '' OR
        									Ref_Limit_to_Acct_or_Cntct__c = 'Account') ORDER BY Name];
        }
        
        if (contactId != null) {
        	listRootAtts = [SELECT Id, Name, Level__c, Parent__c, Attribute_Mapping__c, Attribute_Mapping__r.Object__c, 
        									Attribute_Mapping__r.Field__c, Parent__r.Name,
        									(SELECT Id FROM Attributes__r LIMIT 1) FROM Attribute__c 
        									WHERE Level__c = 0 AND (Ref_Limit_to_Acct_or_Cntct__c = null
        									OR Ref_Limit_to_Acct_or_Cntct__c = '' OR
        									Ref_Limit_to_Acct_or_Cntct__c = 'Contact') ORDER BY Name];
        }
        
        if (contentId != null || labelId != null) {
        	listRootAtts = [SELECT Id, Name, Level__c, Parent__c, Attribute_Mapping__c, Parent__r.Name,
        									(SELECT Id FROM Attributes__r LIMIT 1) FROM Attribute__c 
        									WHERE Level__c = 0 ORDER BY Name];
        }
        treeNodes = new List<Node>();
        Node treeRootNode;
        
        for (Attribute__c att : listRootAtts) {
        	if((isContact || isAccount) && (att.Attribute_Mapping__r.Object__c == 'Opportunity' && att.Attribute_Mapping__r.Field__c == 'Stage')) {
        		continue;
        	}
            Boolean hasChild = (att.Attributes__r != null && att.Attributes__r.size() > 0 ? true : false);
            
            if (att.Attribute_Mapping__c == null) {
                treeRootNode = new Node(att.id, att.Name, att.Level__c, att.Parent__c, att.Parent__r.Name, false, hasChild);
            } else {
                treeRootNode = new Node(att.id, att.Name, att.Level__c, att.Parent__c, att.Parent__r.Name, true, hasChild);
            }
            treeNodes.add(treeRootNode);
        }
        treeRoots = '<tr><th style="padding-top: 10px; padding-right: 25px;"><input type="checkbox" id="selectAll" />'
        				+ '&nbsp;&nbsp; Attribute Name</th>'
        				+ '<th style="padding-top: 10px; padding-left: 25px; padding-right: 20px;">Parent</th></tr>';
        treeRoots = treeRoots + createTree(treeNodes);
    }
	
	/**
     * Method to get children of all root Attributes
     */
    public void getChildrenOfSelectedNode() {
        List<Attribute__c> childAttributes = [SELECT id, Name, Level__c, Parent__r.Attribute_Mapping__c, Parent__r.Attribute_Mapping__r.Object__c, 
        										Parent__c, Parent__r.Name, (SELECT Id FROM Attributes__r LIMIT 1) FROM Attribute__c 
        										WHERE Parent__c = :selectedNodeId ORDER BY Name];
        tempTree = treeNodes;
        childTree = new List<Node>();
        treeNodes = new List<Node>();
        Node treeRootNode;
        attAttachedWithFilters = new Set<String>();
        
        for (Attributes_Labels__c attLabel : [SELECT Id, Attribute__c FROM Attributes_Labels__c WHERE Attribute__c In :childAttributes]) {
        	attAttachedWithFilters.add(attLabel.Attribute__c);
        }
        
        for (Attribute__c att : childAttributes) {
            Boolean hasChild = (att.Attributes__r != null && att.Attributes__r.size() > 0 ? true : false);
            
            if (att.Parent__r.Attribute_Mapping__c != null && att.Parent__r.Attribute_Mapping__r.Object__c != ConstantsController.OPPORTUNITY) {
                treeRootNode = new Node(att.id, att.Name, att.Level__c, att.Parent__c, att.Parent__r.Name, true, hasChild);
            } else {
                treeRootNode = new Node(att.id, att.Name, att.Level__c, att.Parent__c, att.Parent__r.Name, false, hasChild);
            }
            childTree.add(treeRootNode);
        }
        
        for (Attribute__c att : childAttributes) {
        	
	        if (childAttributes[0].Level__c == 1) {
	        	isfilterExistsForParent = true;
	        }
        	break;
        }
        
        for (Node tempNode : tempTree) {
        	
            if (tempNode.Id == selectedNodeId) {
            	
                if (childTree.size() > 0) {
                    tempNode.childShown = true;
                    treeNodes.add(tempNode);
                    treeNodes.addAll(childTree);
                } else {
                    treeNodes.add(tempNode);
                }
            } else {
                treeNodes.add(tempNode);
            }
        }
        childHtml = createTree(childTree);
    }
    
	/**
     * Method to create tree with root Attributes
     */
    public String createTree(List<node> childnodes) {
        String tempTree = '';
        String space = '&nbsp';
        
        for (integer i = 0; i < 3; i++) {
            space = space + space;
        }
        Boolean attAttachedFilter = true;
        
        if (childnodes.size() > 0) {
        	
            for (Node childnode : childnodes) {
            	
            	if (attAttachedWithFilters.contains(childnode.Id) && isfilterExistsForParent) {
        			attAttachedFilter = true;
            	} else {
            		attAttachedFilter = false;
            	}
                String labelId = childnode.label.remove(' ');
                String className;
                
                if (childnode.parentName != null) {
                    className = childnode.parentName.remove(' ');
                }
                
                if (childnode.level != null) {
                    Decimal padding = childnode.level * 20;
                    tempTree = temptree + '<tr class="' + childnode.level + ' ' + childnode.id + '" id=' + childnode.id 
                    				+ '><td style="font-size:100%;padding-right:10px;padding-left:' + padding + 'px;">';
                    
                    if (childnode.level != 0) {
                    	
                        if (childnode.fromMapping && cs.Prevent_selection_of_mapped_Attributes__c) {
                        	
                            if (childnode.hasChild) {
                            	tempTree = tempTree + '<image id="plus' + childnode.Id + '" style="margin-left:5px;" class="PlusImage showPlus Plus' 
                        					+ className + '"/><image id="minus' + childnode.Id + '" style="padding-left:5px;" class="MinusImage hideMinus Minus' 
                        					+ className + '"/>' + +space + childnode.label + '</td>';
                            } else {
                        		tempTree = tempTree + space + childnode.label + '</td>';
                        	}
                        } else {
                        	
                            if (childnode.hasChild) {
                            	tempTree = tempTree + '<input type="checkbox" data-FilterPresent="'+attAttachedFilter+'" class="checkBox"   id="' 
                        					+ childnode.id + '"/><image id="plus' + childnode.Id + '" style="margin-left:5px;" class="PlusImage showPlus Plus' 
                        					+ className + '"/><image id="minus' + childnode.Id + '" style="padding-left:5px;" class="MinusImage hideMinus Minus' 
                        					+ className + '"/>' + +space + childnode.label + '</td>';
                            } else {
                        		tempTree = tempTree + '<input type="checkbox" data-FilterPresent="'+attAttachedFilter+'" class="checkBox"   id="' 
                        					+ childnode.id + '"/>' + +space + childnode.label + '</td>';
                            }
                        }
                    } else {
                    	
                        if (childnode.hasChild) {
                        	tempTree = tempTree + '<image id="plus' + childnode.Id + '" style="margin-left:5px;" class="PlusImage showPlus Plus' 
                        					+ className + '"/><image id="minus' + childnode.Id + '" style="padding-left:5px;" class="MinusImage hideMinus Minus' 
                        					+ className + '"/>' + +space + childnode.label + '</td>';
                        } else {
                        	tempTree = tempTree + space + childnode.label + '</td>';
                        }
                    }

                    if (childnode.parentName != null) {
                        tempTree = tempTree + '<td style="padding-right:5px;padding-left:5px;text-align:center;"  id="parentDiv' + childnode.Id 
                        						+ '">' + childnode.parentName + '</td>';
                    } else {
                        tempTree = tempTree + '<td style="padding-right:5px;padding-left:5px;text-align:center;"  id="parentDiv' + childnode.Id 
                        							+ '">' + '-' + '</td>';
                    }
                    tempTree += '</tr>';
                }
            }
        }
        return tempTree;
    }
	
	/**
     * Method to cancel the process
     */
    public PageReference Cancel() {
    	
        if (refRefresh != null) {
            Pagereference returnPage = new Pagereference(Page.ReferenceRefreshPageSLDS.getUrl() + '?userId=' + refRefresh.Reference_Refresh_Owner__c 
            							+ '&helpoverlay=false' + '&accountId=' + refRefresh.Reference_Account__c + '&pageno=' + pageNo);
            returnPage.setRedirect(true);
            return returnPage;
        }
        
        if (labelId != null) {
            return new PageReference('/' + labelId);
        }
        
        if (accountId != null) {
            return new PageReference('/' + accountId);
        }
        
        if (contactId != null) {
            return new PageReference('/' + contactId);
        }
        
        if (contentId != null) {
            return new PageReference('/' + contentId);
        }
        return null;
    }
	
	/**
     * Method to save the process
     */
    public PageReference SaveAtt() {
        Savepoint sp = Database.setSavepoint();
        try {
        	if (refRefresh != null || checkPermissions()) {
	        	
	            if (labelId != null) {
	                addAttributesToLabel();
	                return new PageReference('/' + labelId);
	            }
	            
	            if (accountId != null) {
	                return addAttributeToAccount();
	            }
	            
	            if (contactId != null) {
	                return addAttributeToContact();
	            }
	            
	            if (contentId != null) {
	                addAttributeToContent();
	                return new PageReference('/' + contentId);
	            }
        	}
        } catch (Exception e) {
            Apexpages.addMessages(e);
            database.rollback(sp);
        }
        return null;
    }
    
    /**
     * Method to delete the Attributes
     */
    public void deleteAttribute() {
        List<Reference_Refresh_Update__c> refrefreshUpdate = new List<Reference_Refresh_Update__c>();
        Savepoint sp = Database.setSavepoint();
        try {
        	
            if (isAccount) {
                List<Account_Attribute__c> accAtts = WithoutSharingHelperController.getAccountAttributesOnAddAtt(selectedAttributeId);
                
                for (Account_Attribute__c accAtt : accAtts) {
                    Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                    temp.Account__c = accAtt.Account__c;
                    temp.Removed__c = true;
                    temp.Changed_From__c = accAtt.Attribute__r.Name;
                    temp.Changed_To__c = '';
                    temp.Attribute__c = true;
                    
                    if (!refRefresh.Quarantined__c) {
                        temp.Accept_Reject__c = 'Accept';
                    }
                    temp.Reference_Refresh__c = refRefresh.Id;
                    temp.RecordToBeDeletedId__c = accAtt.Id;
                    deleteAttIds.add(accAtt.Id);
                    refrefreshUpdate.add(temp);
                }
                
                if (refrefreshUpdate.size() > 0) {
                    WithoutSharingHelperController.upsertRefreshUpdateRecords(refrefreshUpdate);
                }
                
                if (!refRefresh.Quarantined__c) {
                    WithoutSharingHelperController.deleteAccountAttributes(accAtts);
                }
                
                if (refrefreshUpdate.size() > 0) {
                    quarantineUpdates.addAll(refrefreshUpdate);
                }
                accountAttributes = new List<Account_Attribute__c>();
                accountAttributes = WithoutSharingHelperController.getAccountAttributesOnAddAtt2(accountId, deleteAttIds);
            }
            
            if (isContact) {
                List<Contact_Attribute__c> accAtts = WithoutSharingHelperController.getContactAttributesOnAddAtt(selectedAttributeId);
                
                for (Contact_Attribute__c accAtt : accAtts) {
                    Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                    temp.Account__c = accAtt.Contact__r.accountId;
                    temp.Contact__c = accAtt.Contact__c;
                    temp.Removed__c = true;
                    temp.Changed_From__c = accAtt.Attribute__r.Name;
                    temp.Changed_To__c = '';
                    temp.Attribute__c = true;
                    
                    if (!refRefresh.Quarantined__c) {
                        temp.Accept_Reject__c = 'Accept';
                    }
                    temp.Reference_Refresh__c = refRefresh.Id;
                    temp.RecordToBeDeletedId__c = accAtt.Id;
                    deleteAttIds.add(accAtt.Id);
                    refrefreshUpdate.add(temp);
                }
                
                if (refrefreshUpdate.size() > 0) {
                    WithoutSharingHelperController.upsertRefreshUpdateRecords(refrefreshUpdate);
                }
                
                if (!refRefresh.Quarantined__c) {
                    WithoutSharingHelperController.deleteContactAttributes(accAtts);
                }
                
                if (refrefreshUpdate.size() > 0) {
                    quarantineUpdates.addAll(refrefreshUpdate);
                }
                contactAttributes = new List<Contact_Attribute__c>();
                contactAttributes = WithoutSharingHelperController.getContactAttributesOnAddAtt2(contactId, deleteAttIds);
            }
        } catch (exception e) {
        	
            for (Account_Attribute__c accAtt : WithoutSharingHelperController.getAccountAttributesOnAddAtt(selectedAttributeId)) {
                deleteAttIds.remove(accAtt.Id);
            }
            
            for (Contact_Attribute__c accAtt : WithoutSharingHelperController.getContactAttributesOnAddAtt(selectedAttributeId)) {
                deleteAttIds.remove(accAtt.Id);
            }
            Apexpages.addMessages(e);
            database.rollback(sp);
        }
    }
	
	/**
     * Method to add Attributes to the Label
     */
    private void addAttributesToLabel() {
        Set<Id> attribIds = new Set<Id>();
        
        for (Attributes_Labels__c attrib : attributeLabels) {
            attribIds.add(attrib.Attribute__r.Id);
        }
        Attributes_Labels__c attLabel;
        List<Attributes_Labels__c> newattLabels = new List<Attributes_Labels__c>();
        
        for (String s : checkedIds.split(';')) {
        	
            if (s != '' && !attribIds.contains(s)) {
                attLabel = new Attributes_Labels__c(Label__c = labelId, Attribute__c = s);
                newattLabels.add(attLabel);
            }
        }
        
        if (newattLabels.size() > 0) {
            insert newattLabels;
        }
    }
	
	/**
     * Method to add Attributes to the Account
     */
    private PageReference addAttributeToAccount() {
        Savepoint sp = Database.setSavepoint();
        
        try {
	        Set<Id> attribIds = new Set<Id>();
	        Set<Id> contctAttrib = new Set<Id>();
	        
	        if (makeAccountMember || makeContactMember || makeAccountCandidate || makeContactCandidate) {
	        	UtilityController.checkRBI(accountId, null, makeAccountMember, makeContactMember, makeAccountCandidate, makeContactCandidate);
	        }
	        
	        for (Account_Attribute__c attrib : WithoutSharingHelperController.getAccountAttributes(accountId)) {
	            attribIds.add(attrib.Attribute__r.Id);
	        }
	        Set<String> newAttributeIds = new Set<String>();
	        newAttributeIds.addAll(checkedIds.split(';'));
	        Map<String, Set<String>> attribParentIdsMap = new Map<String, Set<String>>();
	        Map<String, Boolean> attributeInheritable = new Map<String, Boolean>();
	        Set<String> parentAttIds = new Set<String>();
	        Map<String, String> attIdNameMap = new Map<String, String>();
	        Set<String> tempSet = new Set<String>();
	        Set<Id> parentToBeAdded = new Set<Id>();
	        
	        for (Attribute__c att : [SELECT ParentIds__c, Name, Id FROM Attribute__c WHERE Id IN :newAttributeIds]) {
	            tempSet = new Set<String>();
	            
	            if (att.ParentIds__c != null) {
	            	tempSet.addAll(att.ParentIds__c.split(','));
	            }
	            parentAttIds.addAll(tempSet);
	            attribParentIdsMap.put(att.Id, tempSet);
	            attIdNameMap.put(att.Id, att.Name);
	        }
	        
	        for (Attribute__c att : [SELECT Id, Inheritable__c, Level__c FROM Attribute__c WHERE Id IN :parentAttIds]) {
	        	
	            if (att.level__c == 0) {
	            	
		            for (String attKey : attribParentIdsMap.keySet()) {
		            	
		                if (attribParentIdsMap.get(attKey).contains(att.Id)) {
		                    attributeInheritable.put(attKey, att.Inheritable__c);
		                }
		            }
	            } else if (!newAttributeIds.contains(att.Id)) {
	            	parentToBeAdded.add(att.Id);
	            }
	        }
	        Account_Attribute__c attAccount;
	        List<Account_Attribute__c> newattAccounts = new List<Account_Attribute__c>();
	        
	        for (String s : checkedIds.split(';')) {
	        	
	            if (s != '' && !attribIds.contains(s)) {
	                attAccount = new Account_Attribute__c(Account__c = accountId, Attribute__c = s, Inheritable__c = attributeInheritable.get(s));
	                attribIds.add(s);
	                newattAccounts.add(attAccount);
	                
	                if (attribParentIdsMap.get(s) != null) {
	                	
	        			for (Id attId : attribParentIdsMap.get(s)) {
	        				
	        				if (parentToBeAdded.contains(attId) && !attribIds.contains(attId)) {
	        					attAccount = new Account_Attribute__c(Account__c = accountId, Attribute__c = attId, 
	        														Inheritable__c = attributeInheritable.get(s));
	                			newattAccounts.add(attAccount);
	                			attribIds.add(attId);
	        				}
	        			}
	                }
	            }
	        }
	        
	        if (newattAccounts.size() > 0) {
	        	List<Reference_Refresh_Update__c> refrefreshUpdate = new List<Reference_Refresh_Update__c>();
	        	
                if (refRefresh != null) {
                	
                    if (!refRefresh.Quarantined__c) {
                        WithoutSharingHelperController.upsertAccountAttributes(newattAccounts);
                    }
                    
                    for (Account_Attribute__c accAtt : newattAccounts) {
                    	
                        if (!alreadyCreatedPUAttforAccount.contains(accAtt.Attribute__c)) {
	                        Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
	                        temp.Account__c = accAtt.Account__c;
	                        temp.Added__c = true;
	                        temp.Changed_To__c = attIdNameMap.get(accAtt.Attribute__c);
	                        temp.Attribute__c = true;
	                        temp.RecordsToBeInsertedId__c = accAtt.Attribute__c;
	                        temp.Attribute_Inheritable__c = accAtt.Inheritable__c;
	                        
	                        if (!refRefresh.Quarantined__c) {
	                            temp.Accept_Reject__c = 'Accept';
	                        }
	                        temp.Reference_Refresh__c = refRefresh.Id;
	                        refrefreshUpdate.add(temp);
                        }
                    }
                    
                    if (refrefreshUpdate.size() > 0) {
                        WithoutSharingHelperController.upsertRefreshUpdateRecords(refrefreshUpdate);
                    }
                } else {
                    insert newattAccounts;
                }
	        }
	        
	        if (refRefresh != null) {
	            Pagereference returnPage = new Pagereference(Page.ReferenceRefreshPageSLDS.getUrl() + '?userId=' + refRefresh.Reference_Refresh_Owner__c 
	            								+ '&helpoverlay=false' + '&accountId=' + refRefresh.Reference_Account__c + '&pageno=' + pageNo);
	            returnPage.setRedirect(true);
	            return returnPage;
	        } else
	            return new PageReference('/' + accountId);
        } catch (Exception e) {
            Apexpages.addMessages(e);
            database.rollback(sp);
            return null;
        }
    }
	
	/**
     * Method to add Attributes to the Contact
     */
    private PageReference addAttributeToContact() {
        Set<Id> attribIds = new Set<Id>();
        Set<String> newAttributeIds = new Set<String>();
        Set<Id> accountAttribIds = new Set<Id>();
        
        if (isSharedContact) {
        	
	        if (selectedAccounts != null && selectedAccounts.size() > 0) {
	        	
	        	for (SelectOption so : selectedAccounts) {
	        		ConstantsController.selectedAccounts.add(so.getValue());
	        	}
	        	
	        	if (!ConstantsController.selectedAccounts.contains(contactAccountId)) {
	        		contactAccountId = '';
	        	}
	        }
        }
        
        if (makeAccountMember || makeContactMember || makeAccountCandidate || makeContactCandidate) {
        	
        	if (ConstantsController.selectedAccounts != null && ConstantsController.selectedAccounts.size() > 0) {
        		UtilityController.checkRBI(ConstantsController.selectedAccounts, contactId, makeAccountMember, makeContactMember, 
        																				makeAccountCandidate, makeContactCandidate);
        	} else {
        		UtilityController.checkRBI(contactAccountId, contactId, makeAccountMember, makeContactMember, makeAccountCandidate, makeContactCandidate);
        	}
        }
        
        for (Contact_Attribute__c attrib : [SELECT Attribute__r.Id FROM Contact_Attribute__c WHERE Contact__c = :contactId]) {
            attribIds.add(attrib.Attribute__r.Id);
        }
        Map<Id, Set<Id>> accAttMap = new map<Id, Set<Id>>();
        
        for (Account_Attribute__c attrib : WithoutSharingHelperController.getAllAccountAttributesOfAccountSharedContact(
        															ConstantsController.selectedAccounts, contactId)) {
        	if (!accAttMap.containsKey(attrib.Account__c)) {
        		accAttMap.put(attrib.Account__c, new Set<Id>());
        	}
    		accAttMap.get(attrib.Account__c).add(attrib.Attribute__c);
        }
        Contact_Attribute__c attContact;
        List<Contact_Attribute__c> newattContacts = new List<Contact_Attribute__c>();
        List<Account_Attribute__c> newattAccounts = new List<Account_Attribute__c>();
        
        for (String s : checkedIds.split(';')) {
        	
            if (s != '' && !attribIds.contains(s)) {
                attContact = new Contact_Attribute__c(Contact__c = contactId, Attribute__c = s);
                newattContacts.add(attContact);
                newAttributeIds.add(s);
            } else if (s != '' && attribIds.contains(s)) {
            	
            	for (Id accId : accAttMap.keySet()) {
            		
            		if (!accAttMap.get(accId).contains(s)) {
            			Account_Attribute__c tempObj = new Account_Attribute__c();
		                tempObj.Account__c = accId;
		                tempObj.Attribute__c = s;
		                tempObj.Contact__c = contactId;
		                newattAccounts.add(tempObj);
            		}
            	}
            }
        }
        Map<String, String> attIdNameMap = new Map<String, String>();
        
        for (Attribute__c att : [SELECT ParentIds__c, Name, Id FROM Attribute__c WHERE Id IN :newAttributeIds]) {
            attIdNameMap.put(att.Id, att.Name);
        }

        if (makeAccountMember) {
            ConstantsController.addAttributesToAccount = true;
        }
        
        if (isSharedContact) {
        	ConstantsController.isAccountSelectedfromContact = true; 
        }
        
        if (newattContacts.size() > 0) {
            List<Reference_Refresh_Update__c> refrefreshUpdate = new List<Reference_Refresh_Update__c>();
            Savepoint sp = Database.setSavepoint();
            try {
            	
                if (refRefresh != null) {
                	
                    if (!refRefresh.Quarantined__c) {
                        WithoutSharingHelperController.upsertContactAttributes(newattContacts);
                    }
                    
                    for (Contact_Attribute__c accAtt : newattContacts) {
                    	
                        if (!alreadyCreatedPUAttforContact.contains(accAtt.Attribute__c)) {
                            
                            // Changes for #366 - creating records for each of the selected accounts
                        	if (ConstantsController.selectedAccounts != null && ConstantsController.selectedAccounts.size() > 0) {
                        		
                        		for (String accId : ConstantsController.selectedAccounts) {
		                        	Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
									temp.Account__c = accId;
		                            temp.Contact__c = accAtt.Contact__c;
		                            temp.Added__c = true;
		                            temp.Changed_To__c = attIdNameMap.get(accAtt.Attribute__c);
		                            temp.Attribute__c = true;
		                            temp.RecordsToBeInsertedId__c = accAtt.Attribute__c;
		                            temp.Reference_Refresh__c = refRefresh.Id;
		                            
		                            if (!refRefresh.Quarantined__c) {
		                                temp.Accept_Reject__c = 'Accept';
		                            }
		                            refrefreshUpdate.add(temp);
                        		}
                        	} else if (!isSharedContact) {
                        		Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
								temp.Account__c = contactAccountId;
	                            temp.Contact__c = accAtt.Contact__c;
	                            temp.Added__c = true;
	                            temp.Changed_To__c = attIdNameMap.get(accAtt.Attribute__c);
	                            temp.Attribute__c = true;
	                            temp.RecordsToBeInsertedId__c = accAtt.Attribute__c;
	                            temp.Reference_Refresh__c = refRefresh.Id;
	                            
	                            if (!refRefresh.Quarantined__c) {
	                                temp.Accept_Reject__c = 'Accept';
	                            }
	                            refrefreshUpdate.add(temp);
                        	}
                        }
                	}
                	
                    if (refrefreshUpdate.size() > 0) {
                        WithoutSharingHelperController.upsertRefreshUpdateRecords(refrefreshUpdate);
                    }
                } else {
                	
                    if (newattAccounts.size() > 0) {
                    	insert newattAccounts;
                    }
                    
                    if (newattContacts.size() > 0) {
                    	insert newattContacts;
                    }
                }
            } catch (Exception e) {
                Apexpages.addMessages(e);
                database.rollback(sp);
                return null;
            }
        }
        
        if (refRefresh != null) {
            Pagereference returnPage = new Pagereference(Page.ReferenceRefreshPageSLDS.getUrl() + '?userId=' 
            						+ refRefresh.Reference_Refresh_Owner__c + '&helpoverlay=false' + '&accountId=' + refRefresh.Reference_Account__c + '&pageno=' + pageNo);
            returnPage.setRedirect(true);
            return returnPage;
        } else{
        	Pagereference returnPage = new Pagereference('/' + contactId);
            returnPage.setRedirect(true);
            return returnPage;
        }
    }
	
	/**
     * Method to add Attributes to the Content
     */
    private void addAttributeToContent() {
        Set<Id> attribIds = new Set<Id>();
        
        for (Content_Attribute__c attrib : contentAttribute) {
            attribIds.add(attrib.Attribute__r.Id);
        }
        Content_Attribute__c attContent;
        List<Content_Attribute__c> newattContent = new List<Content_Attribute__c>();
        
        for (String s : checkedIds.split(';')) {
        	
            if (s != '' && !attribIds.contains(s)) {
                attContent = new Content_Attribute__c(Reference_Content__c = contentId, Attribute__c = s);
                newattContent.add(attContent);
            }
        }
        
        if (newattContent.size() > 0) {
            insert newattContent;
        }
    }
	
	
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    
        if (labelId != null) {
	        fieldMap.put(UtilityController.appNamespace() + 'Attributes_Labels__c', new Set<String> {});
        }
        
        if (accountId != null) {
            fieldMap.put(UtilityController.appNamespace() + 'Account_Attribute__c', new Set<String> {
	        										UtilityController.appNamespace() + 'Inheritable__c'});
        }
        
        if (contactId != null) {
            fieldMap.put(UtilityController.appNamespace() + 'Contact_Attribute__c', new Set<String> {});
			fieldMap.put(UtilityController.appNamespace() + 'Account_Attribute__c', new Set<String> {
	        										UtilityController.appNamespace() + 'Contact__c'});
        }
        
        if (contentId != null) {
            fieldMap.put(UtilityController.appNamespace() + 'Content_Attribute__c', new Set<String> {});
        }
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
    }
    /**
     * Wrapper class for storing each
     */
    public class Node {
        public String id { get; set; }
        public String label { get; set; }
        String title;
        public Decimal level { get; set; }
        public Boolean childShown { get; set; }
        public Boolean hasChild { get; set; }
        public Boolean isChecked { get; set; }
        public Id parent { get; set; }
        public String parentName { get; set; }
        public Boolean fromMapping { get; set; }
        
        public Node(Id nodeId, String titleRec, Decimal levelRec, Id ParentId, String ParentName1, Boolean isMApping, Boolean hasChild) {
            id = nodeId;
            label = titleRec != null ? titleRec.escapeHtml4() : '';
            title = titleRec != null ? titleRec.escapeHtml4() : '';
            level = levelRec;
            childShown = false;
            isChecked = false;
            parent = ParentId;
            parentName = ParentName1 != null ? ParentName1.escapeHtml4() : '';
            fromMapping = isMApping;
            this.hasChild = hasChild;
        }
    }
}