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
 * Page: CopyNominaion 
 * Description: Class used to handle Copy Nominaion
 * Modified by: Rajesh @20 Jan 2017
 */
public with sharing class CopyNominationDetailsController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables 
     */
    public Nomination__c nominationObj { get; set; }
    public Map<String, List<nominationWrapper>> tableMap { get; set; }
    public Map<String, String> rowValuesMap { get; set; }
    public List<String> rowValues { get; set; }
    public Map<String, String> labelAttributes { get; set; }
    private Reference_Basic_Information__c accountRBI;
    private Reference_Basic_Information__c contactRBI;
    public Boolean isReferenceableStatus { get; set; }
    private Account account;
    private Contact contact;
    public Boolean isMakeAccountMember { get; set; }
    private Map<String, Boolean> labelIds;
    private Map<String, Attribute_Mapping__c> attMappingsAccount;
    private Map<String, Attribute_Mapping__c> attMappingsContact;
    private Set<String> singleSelectPicklistAccount;
    private Set<String> multiSelectPicklistAccount;
    private Set<String> singleSelectPicklistContact;
    private Set<String> multiSelectPicklistContact;
    private Set<String> ALREADYaccattIds;
    private Set<String> ALREADYconattIds;
    private List<Reference_Basic_Information__c> upsertRBI;
    private Map<String, Boolean> attributeInheritable;
    private Id accountId;
    public Boolean isSharedContact { get; set; }
    public List<SelectOption> accounts { get; set; }
    public List<SelectOption> selectedAccounts { get; set; }
    public Boolean isAccountReferenceProgramMember { get; set; }
    private Map<String, Reference_Basic_Information__c> accountIsReferenceableMap;
    private String soqlQuery;
    public Boolean isSLDS { get; set; }
    public String alertMsgToMakeMember { get; set; }
    public List<Contact_Attribute__c> contactAttributes { get; set; }
    public Boolean copyExistingAtt { get; set; }
    public Boolean isFromWorkspace { get; set; }
    
    /**
     * Constructor
     */
    public CopyNominationDetailsController(ApexPages.StandardController controller) {
        nominationObj = (Nomination__c) controller.getRecord();
        String isFromWorkspaceString = apexpages.currentpage().getparameters().get('isFromWorkspace');
        isFromWorkspace = (isFromWorkspaceString == null || isFromWorkspaceString != 'true') ? false : true;
        isMakeAccountMember = false;
        copyExistingAtt = true;
        soqlQuery = '';
        Boolean URLIsSLDS = apexpages.currentpage().getparameters().containsKey('isSLDS') ? apexpages.currentpage().getparameters().get('isSLDS') == 'true' : false;
            
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') { 
            isSLDS = true;
        } else { 
            isSLDS = URLIsSLDS;
        }
        attributeInheritable = new Map<String, Boolean>();
        tableMap = new Map<String, List<nominationWrapper>>();
        labelAttributes = new Map<String, String>();
        contactAttributes = new List<Contact_Attribute__c>();
        rowValues = new List<String> {
            'Referenceability', 'Additional Information', 'Comments', 'Attributes'
        };
        rowValuesMap = new Map<String, String>();
        rowValuesMap.put('Referenceability', System.Label.Referenceability);
        rowValuesMap.put('Additional Information', System.Label.Additional_Information.replace('@@@ ', ''));
        rowValuesMap.put('Comments', System.Label.Comments);
        rowValuesMap.put('Attributes', System.Label.Attributes);
        getFields();
        getReferenceability();
        getAttributes();
        isReferenceableStatus = false;
        isSharedContact = false;
        isAccountReferenceProgramMember = false;
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        accountIsReferenceableMap = new Map<String, Reference_Basic_Information__c>();
        alertMsgToMakeMember = system.Label.Make_Member_from_Nomination.replace('@@@', system.Label.Account);
        //Shared Contact code
        isSharedContact = cs.Shared_Contacts__c;
        accounts = new List<SelectOption>();
    	selectedAccounts = new List<SelectOption>();
        
        if (nominationObj.Contact__c == null) {
        	isMakeAccountMember = true;
            List<Account> acc = WithoutSharingHelperController.getAccountRecords(new Set<String> {
                String.valueOf(nominationObj.Account__c)});
            
            if (acc.size() > 0) {
                
                for (Reference_Basic_Information__c rbi : acc[0].Reference_Basic_Informations__r) {
                    accountRBI = rbi;
                    isReferenceableStatus = rbi.Is_Referenceable__c;
                    break;
                }
            }
        } else {
            List<Contact> con = WithoutSharingHelperController.getContact(nominationObj.Contact__c);
            
            if (con.size() > 0) {
                
                for (Reference_Basic_Information__c rbi : con[0].Reference_Basic_Informations__r) {
                    contactRBI = rbi;
                    isReferenceableStatus = rbi.Is_Referenceable__c;
                    break;
                }
                accountId = con[0].AccountId;
            }
            //Shared Contact code start
            if (isSharedContact){
            	Set<String> accountIds = new Set<String>(); 
            	Map<String, Set<String>> contactAccountMap = WithoutSharingHelperController.getRelatedAccounts(new Set<String> {nominationObj.Contact__c}, cs);
            	
            	if(contactAccountMap != null && contactAccountMap.containsKey(nominationObj.Contact__c)) {
                    accountIds.addAll(contactAccountMap.get(nominationObj.Contact__c));
            	}
            	accountIds.add(accountId); 
            	
            	for (Account acc : WithoutSharingHelperController.getAccountRecordsforLookup(accountIds,200)) {            		 
            		
            		if (acc.Reference_Basic_Informations__r.size() > 0) {
	                    accountIsReferenceableMap.put(acc.Id, acc.Reference_Basic_Informations__r[0]);
	                    
	                    if (accountId == acc.Id) {
		            		isAccountReferenceProgramMember = acc.Reference_Basic_Informations__r[0].Is_Referenceable__c;
		            		accountRBI = acc.Reference_Basic_Informations__r[0];
		            	}
	                } else {
	                    accountIsReferenceableMap.put(acc.Id, new Reference_Basic_Information__c());
	                }
	                
                	if (nominationObj.Account__c == acc.Id) {
                		selectedAccounts.add(new SelectOption(acc.Id, acc.Name));
                	} else {
                		accounts.add(new SelectOption(acc.Id, acc.Name));
            		}
        		}
            } else {
            	List<Account> acc = WithoutSharingHelperController.getAccountRecords(new Set<String> {
	                String.valueOf(nominationObj.Account__c)});
	            
	            if (acc.size() > 0) {
	                
	                for (Reference_Basic_Information__c rbi : acc[0].Reference_Basic_Informations__r) {
	                    accountRBI = rbi;
	                    isAccountReferenceProgramMember = accountRBI.Is_Referenceable__c;
	                    break;
	                }
	            }
            }
        }
    }

    /**
     * Method to add all attributes related to this nomination
     */
    private void getAttributes() {
        singleSelectPicklistAccount = new Set<String>();
        multiSelectPicklistAccount = new Set<String>();
        singleSelectPicklistContact = new Set<String>();
        multiSelectPicklistContact = new Set<String>();
        attMappingsAccount = new Map<String, Attribute_Mapping__c>();
        attMappingsContact = new Map<String, Attribute_Mapping__c>();
        Set<String> accAttIDs = new Set<String>();
        Set<String> conAttIDs = new Set<String>();
        Set<String> contactFields = new Set<String>();
        Set<String> accountFields = new Set<String>();
        
        if (nominationObj.Contact__c != null) {
            Map<String, Schema.SObjectField > fldObjMap = schema.SObjectType.Contact.fields.getMap();
            List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
            String theQuery = 'SELECT Id, Name';
            
            for (Schema.SObjectField s : fldObjMapValues) {
                Schema.DescribeFieldResult fieldDesc = s.getDescribe();
                
                if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    String theName = fieldDesc.getName(); 
                    contactFields.add(theName);
                    // Continue building your dynamic query String
                    theQuery += ', ' + theName;
                   
                    if (fieldDesc.getType() == Schema.DisplayType.PICKLIST) {
                        singleSelectPicklistContact.add(theName);
                    } else {
                        multiSelectPicklistContact.add(theName);
                    }
                }
            }
            theQuery += ' FROM Contact WHERE Id = \'' + nominationObj.Contact__c + '\'LIMIT 1';
            List<Contact> contacts = WithoutSharingHelperController.getContactUsingDynamicSOQL(theQuery);
            
            if (contacts.size() > 0) {
                contact = contacts[0];
            }

            for (Attribute_Mapping__c attMapping : [SELECT Object__c, Id, Filter_Label_Name__c, Field_Api_Name__c, Field__c, Attribute_Name__c
                    FROM Attribute_Mapping__c WHERE Object__c = :ConstantsController.CONTACT AND Auto_populate__c = true AND Is_Related_Mapping__c = false
                ]) {
                	
                if (contactFields.contains(attMapping.Field_Api_Name__c))
                    attMappingsContact.put(attMapping.Id, attMapping);
            }

            for (Contact_Attribute__c att : [SELECT Id, Attribute__c, Is_fromMapping__c, Attribute__r.Name, Account__r.Name, Attribute__r.Parent__r.Name 
            								FROM Contact_Attribute__c WHERE Contact__c = :nominationObj.Contact__c]) {
                
                if (att.Is_fromMapping__c) {
                	conAttIDs.add(att.Attribute__c);
                }
            	contactAttributes.add(att);
            }
        }
        
        if (nominationObj.Account__c != null) {
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account.fields.getMap();
            List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
            String theQuery = 'SELECT Id, Name';
            
            for (Schema.SObjectField s : fldObjMapValues) {
                Schema.DescribeFieldResult fieldDesc = s.getDescribe();
                
                if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    String theName = fieldDesc.getName();
                    accountFields.add(theName);
                    // Continue building your dynamic query String
                    theQuery += ', ' + theName;
                    
                    if (fieldDesc.getType() == Schema.DisplayType.PICKLIST) {
                        singleSelectPicklistAccount.add(theName);
                    } else {
                        multiSelectPicklistAccount.add(theName);
                    }
                }
            }
			soqlQuery = theQuery + ' FROM Account ';
            theQuery += ' FROM Account WHERE Id = \'' + nominationObj.Account__c + '\'LIMIT 1';
            List<Account> accounts = WithoutSharingHelperController.getAccountUsingDynamicSOQL(theQuery);
            
            if (accounts.size() > 0) {
                account = accounts[0];
            }
            
            for (Attribute_Mapping__c attMapping : [SELECT Object__c, Id, Filter_Label_Name__c, Field_Api_Name__c, Field__c, Attribute_Name__c
                    FROM Attribute_Mapping__c WHERE Object__c = :ConstantsController.ACCOUNT AND Auto_populate__c = true AND Is_Related_Mapping__c = false
                ]) {
                	
                if (accountFields.contains(attMapping.Field_Api_Name__c)) {
                    attMappingsAccount.put(attMapping.Id, attMapping);
                }
            }
            
            for (Account_Attribute__c att : WithoutSharingHelperController.getAllAccountAttributes(new Set<String> {
                    nominationObj.Account__c
                })) {
                	
                if (att.Is_fromMapping__c) {
                    accAttIDs.add(att.Attribute__c);
                }
            }
        }
        //get attributes of account/contact
        labelIds = new Map<String, Boolean>();

        Set<String> attributeSet = new Set<String>();
        
        if ((attMappingsAccount != null && attMappingsAccount.size() > 0) || (attMappingsContact != null && attMappingsContact.size() > 0)) {
            
            for (Attribute__c att : [SELECT Level__c, Inheritable__c, (SELECT Id, Level__c FROM Attributes__r WHERE Level__c = 1 LIMIT 1) FROM Attribute__c WHERE Level__c = 0 
            						AND (Attribute_Mapping__c IN :attMappingsAccount.keySet() OR Attribute_Mapping__c IN :attMappingsContact.keySet())]) {
              
                for (Attribute__c attr : att.Attributes__r) {
                    attributeSet.add(attr.Id);
                }
            }
        }

        if (attributeSet.size() > 0 || accAttIDs.size() > 0 || conAttIDs.size() > 0) {
            
            for (Attributes_Labels__c attLabel : [SELECT Attribute__c, Attribute__r.Name, Label__c, Label__r.Name FROM Attributes_Labels__c 
            										WHERE Attribute__c IN :attributeSet or Attribute__c IN :accAttIDs OR Attribute__c IN :conAttIDs]) {
                Boolean flag = false;
                
                if (nominationObj.Account__c != null && account != null) {
                    
                    for (Attribute_Mapping__c attMap : attMappingsAccount.values()) {
                        
                        if (attMap.Filter_Label_Name__c == attLabel.Label__r.Name) {
                            
                            if (account.get(attMap.Field_Api_Name__c) != null) {
                                labelAttributes.put(attLabel.Label__r.Name, String.valueOf(account.get(attMap.Field_Api_Name__c)));
                                flag = true;
                            } else {
                                labelAttributes.put(attLabel.Label__r.Name, '');
                            }
                        }
                    }
                } else if (accAttIDs.contains(attLabel.Attribute__c)) {
                    
                    if (labelAttributes.containsKey(attLabel.Label__r.Name)) {
                        String attributes = labelAttributes.get(attLabel.Label__r.Name);
                        
                        if (attributes == '') {
                            attributes = attLabel.Attribute__r.Name;
                        } else {
                            attributes += ', ' + attLabel.Attribute__r.Name;
                        }
                        labelAttributes.put(attLabel.Label__r.Name, attributes);
                    } else {
                        labelAttributes.put(attLabel.Label__r.Name, attLabel.Attribute__r.Name);
                    }
                    flag = true;
                }
                
                if (nominationObj.Contact__c != null && contact != null) {
                	
                    for (Attribute_Mapping__c attMap : attMappingsContact.values()) {
                    	
                        if (attMap.Filter_Label_Name__c == attLabel.Label__r.Name) {
                        	
                            if (contact.get(attMap.Field_Api_Name__c) != null) {
                                labelAttributes.put(attLabel.Label__r.Name, String.valueOf(contact.get(attMap.Field_Api_Name__c)));
                                flag = true;
                            } else {
                                labelAttributes.put(attLabel.Label__r.Name, '');
                            }
                        }
                    }
                } else if (conAttIDs.contains(attLabel.Attribute__c)) {
                    
                    if (labelAttributes.containsKey(attLabel.Label__r.Name)) {
                        String attributes = labelAttributes.get(attLabel.Label__r.Name);
                        
                        if (attributes == '') {
                            attributes = attLabel.Attribute__r.Name;
                        } else {
                            attributes += ', ' + attLabel.Attribute__r.Name;
                        }
                        labelAttributes.put(attLabel.Label__r.Name, attributes);
                    } else {
                        labelAttributes.put(attLabel.Label__r.Name, attLabel.Attribute__r.Name);
                    }
                    flag = true;
                } else {
                    if (!labelAttributes.containsKey(attLabel.Label__r.Name)) {
                        labelAttributes.put(attLabel.Label__r.Name, '');
                    }
                }
                labelIds.put(attLabel.Label__c, flag);
            }
        }
        //get attributes of nomination
        List<nominationWrapper> tempList = new List<nominationWrapper>();
        Map<Id, List<Nomination_Label_Attribute__c>> filterAttributes = new Map<Id, List<Nomination_Label_Attribute__c>>();
        Set<String> labelIdset = new Set<String>();
        List<Nomination_Label__c> nominationLabelList = [SELECT Id, Name, Label__c, Label__r.Name FROM Nomination_Label__c 
        													WHERE Nomination__c = :nominationObj.Id ORDER BY Label__r.Name];
       
        for (Nomination_Label__c NL : nominationLabelList) {
            labelIdset.add(NL.Id);
        }
        Set<String> parentAttIds = new Set<String>();
        Set<String> tempSet = new Set<String>();
        Map<String, Set<String>> attribParentIdsMap = new Map<String, Set<String>>();
       
        for (Nomination_Label_Attribute__c NLA : [SELECT Attribute__c,Attribute__r.ParentIds__c, Attribute__r.Name, Nomination_Label__c 
        													FROM Nomination_Label_Attribute__c WHERE Nomination_Label__c IN :labelIdset]) {
           
            if (!filterAttributes.containsKey(NLA.Nomination_Label__c)) {
                filterAttributes.put(NLA.Nomination_Label__c, new List<Nomination_Label_Attribute__c>());
            }
            filterAttributes.get(NLA.Nomination_Label__c).add(NLA);
            tempSet = new Set<String>();
            
            if (NLA.Attribute__r.ParentIds__c != null) {
                tempSet.addAll(NLA.Attribute__r.ParentIds__c.split(','));
            }
            parentAttIds.addAll(tempSet);
            attribParentIdsMap.put(NLA.Attribute__c, tempSet);
        }
        
        for (Attribute__c att : [SELECT Id, Inheritable__c FROM Attribute__c WHERE Id IN :parentAttIds and Level__c = 0]) {
           
            for (String attKey : attribParentIdsMap.keySet()) {
                
                if (attribParentIdsMap.get(attKey).contains(att.Id)) {
                    
                    if (att.Inheritable__c) {
                        attributeInheritable.put(attKey, att.Inheritable__c);
                    } else {
                        attributeInheritable.put(attKey, false);
                    }
                }
            }
        }
        
        for (Nomination_Label__c NL : nominationLabelList) {
            String attributes = '';
            String attributeIds = '';
            
            if (filterAttributes != null && filterAttributes.containsKey(NL.Id) && filterAttributes.get(NL.Id) != null) {
                
                for (Nomination_Label_Attribute__c NLA : filterAttributes.get(NL.Id)) {
                    attributes = (attributes == '') ? NLA.Attribute__r.Name : attributes + ', ' + NLA.Attribute__r.Name; 
                    attributeIds += NLA.Attribute__c + ',';
                }
            }
            
            if (labelIds != null && labelIds.size() > 0 && labelIds.containsKey(NL.Label__c)) {
                tempList.add(new nominationWrapper(NL.Label__c, NL.Label__r.Name, attributes, attributeIds, labelIds.get(NL.Label__c)));
            } else {
                tempList.add(new nominationWrapper(NL.Label__c, NL.Label__r.Name, attributes, attributeIds, false));
            }
        }
        
        if (tempList.size() == 0) {
            nominationWrapper nw = new nominationWrapper('', '', system.Label.No_Attribute_values_selected, '', false);
            nw.isCopy = null;
            tempList.add(nw);
        }
        tableMap.put('Attributes', tempList);

    }

    /**
     * Method to Get fields of Nomination object and put in map
     */
    private void getFields() {

        Map<String, String> FieldMap = new Map<String, String>();
        Set<String> fieldSet = new Set<String> {
            'account__c', 'contact__c', 'disposition__c', 'email_enabled__c', 'get_current_instance__c', 'new_nomination_URL__c', 'note__c', 'status__c','referenceability__c','influitive_id__c',  'other_info__c', 'test_area_field__c', 'sample_field_01_del__c'
        };
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Nomination__c.fields.getMap();
        
        for (String field : fldObjMap.keyset()) {
           
            if (!fieldSet.contains(field) && fldObjMap.get(field).getDescribe().isCustom() && fldObjMap.get(field).getDescribe().isUpdateable()) {
                FieldMap.put(fldObjMap.get(field).getDescribe().getName(), fldObjMap.get(field).getDescribe().getLabel());
            }
        }
        String query = 'SELECT Id, Name,Account__c,Other_Info__c,Contact__c ,Disposition__c,Note__c,Status__c,CreatedById';
        
        if (FieldMap.size() > 0) {
           
            for (String field : FieldMap.keySet()) {
                query += ',' + field;
            }
        }
        query += ' FROM Nomination__c WHERE Id = \'' + nominationObj.Id + '\'LIMIT 1';
        nominationObj = Database.query(query);
        //adding all fields related to this nomination
        List<nominationWrapper> tempList = new List<nominationWrapper>();
        
        if (FieldMap.size() > 0) {
            
            for (String field : FieldMap.keySet()) {
                String fieldValue = (String.valueof(nominationObj.get(field)) == 'true' ? 'checked' 
                						 : (String.valueof(nominationObj.get(field)) == 'false' ? 'unchecked' : String.valueof(nominationObj.get(field))));
                tempList.add(new nominationWrapper('', FieldMap.get(field), fieldValue, fieldValue, false));
            }
        }
        
        if (tempList.size() == 0) {
            nominationWrapper nw = new nominationWrapper('', '', system.Label.No_Fields_selected, '', false);
            nw.isCopy = null;
            tempList.add(nw);
        }
        tableMap.put('Additional Information', tempList);

        //adding comments related to this nomination
        tempList = new List<nominationWrapper>();
        tempList.add(new nominationWrapper('', '', String.valueof(nominationObj.get('Other_Info__c')), '', false));
        tableMap.put('Comments', tempList);
    }

    /**
     * Method to add all referenceabilities related to this nomination
     */
    private void getReferenceability() {
        //get referenceability types of account/contact
        Set<Id> refIds = new Set<Id>();
        
        if (nominationObj.Contact__c == null) {
            for (Referenceability__c ref : [SELECT Id, Referenceability_Type__c FROM Referenceability__c WHERE Account__c = :nominationObj.Account__c]) {
                refIds.add(ref.Referenceability_Type__c);
            }
        } else {
        	
            for (Referenceability__c ref : [SELECT Id, Referenceability_Type__c FROM Referenceability__c WHERE Contact__c = :nominationObj.Contact__c]) {
                refIds.add(ref.Referenceability_Type__c);
            }
        }
        //get referenceability types of nomination 
        List<nominationWrapper> tempList = new List<nominationWrapper>();
        
        for (Nomination_Referenceability__c NR : [SELECT Id, Referenceability_Type__c, Referenceability_Type__r.Name FROM Nomination_Referenceability__c 
        											WHERE Nomination__c = :nominationObj.Id ORDER BY Referenceability_Type__r.Name]) {
            tempList.add(new nominationWrapper('', '', NR.Referenceability_Type__r.Name, NR.Referenceability_Type__c, refIds.contains(NR.Referenceability_Type__c)));
        }
        
        if (tempList.size() == 0) {
            nominationWrapper nw = new nominationWrapper('', '', system.Label.No_Referenceability_values_selected, '', false);
            nw.isCopy = null;
            tempList.add(nw);
        }
        tableMap.put('Referenceability', tempList);
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
                
                if (!accRbi.Is_Referenceable__c) {
                    accountFlags += 'b';
                }
            }
            
            if (accountFlags == '') {
	            isAccountReferenceProgramMember = true;
	        } else if (accountFlags.contains('b')) {
	            isAccountReferenceProgramMember = false;
	        }
        } 
    }
    /**
     * Method to copy all details to account/Contact
     */
    public pageReference copyDetails() {
        Savepoint sp = Database.setSavepoint();
        try {
            upsertRBI = new List<Reference_Basic_Information__c>();
            Set<String> accountIds = new Set<String>();
           
            if (selectedAccounts.size() + accounts.size()  == 1) {
            	isSharedContact = false;
            	accountIds.add(accountId);
            } else {
	            
	            if (selectedAccounts != null && selectedAccounts.size() > 0) {
		        	
		        	for (SelectOption so : selectedAccounts) {
		        		accountIds.add(so.getValue());
		        	}
	            }
            }
            Boolean isMakeAccountMemberTemp = false;
            
            if ((nominationObj.Contact__c == null || /*isMakeAccountMember*/ !isSharedContact) && isMakeAccountMember) {
            	isMakeAccountMemberTemp = true;
              
                if (accountRBI == null) {
                    accountRBI = new Reference_Basic_Information__c(Account__c = nominationObj.Account__c, Referenceability_Status__c = 'Active', Is_Referenceable__c = true);
                } else {
                   
                    if (!accountRBI.Is_Referenceable__c) {
                        accountRBI.Is_Referenceable__c = true;
                        accountRBI.Reference_Program_Candidate__c = false;
                        accountRBI.Referenceability_Status__c = 'Active';
                    }
                }
                upsertRBI.add(accountRBI);
            } else if (isMakeAccountMember && accountIds.size() > 0) {
            	isMakeAccountMemberTemp = true;
            }
            if (nominationObj.Contact__c != null) {
                
                if (contactRBI == null) {
                    contactRBI = new Reference_Basic_Information__c(Contact__c = nominationObj.Contact__c, Account__c = accountId, 
                    													Referenceability_Status__c = 'Active', Is_Referenceable__c = true);
                } else {
                    
                    if (!contactRBI.Is_Referenceable__c) {
                        contactRBI.Is_Referenceable__c = true;
                        contactRBI.Reference_Program_Candidate__c = false;
                        contactRBI.Referenceability_Status__c = 'Active';
                    }
                }
                upsertRBI.add(contactRBI);
            }
            
            if (upsertRBI.size() > 0) { 
                ConstantsController.stopAfterInsertRBI = true;
                upsertRBI = WithoutSharingHelperController.upsertRBI(upsertRBI);
            } 
            Set<String> atttocreate = createAttribute(accountIds);
            createNote();
            Set<String> reftocreate = createRefer1();
            
            for (Reference_Basic_Information__c rbiObj : upsertRBI) {
	        	ConstantsController.RBIIds.add(rbiObj.Id);
	        }
	        
	        if (accountRBI != null) {
	        	ConstantsController.RBIIds.add(accountRBI.Id);
	        }
	        
	        if (contactRBI != null) {
	        	ConstantsController.RBIIds.add(contactRBI.Id);
	        }
            
			Database.executebatch(new Batch_DataUpdate_RBI(ConstantsController.RBIIds, nominationObj.Account__c, nominationObj.Contact__c, 
													isMakeAccountMemberTemp, accountIds, atttocreate, reftocreate, copyExistingAtt));
            
            if (isFromWorkspace && isSLDS) {
                String selection = apexpages.currentpage().getparameters().get('selection');
                PageReference redirectPage = Page.ReferenceWorkspaceSLDS;
                redirectPage.getParameters().put('selection',selection);
                redirectPage.setRedirect(true);
                return redirectPage;
            } else if (isFromWorkspace) {
                PageReference redirectPage = Page.ReferenceWorkspace;
                redirectPage.getParameters().put('activeTab','nomiTab');
                redirectPage.setRedirect(true);
                return redirectPage;
            } else {
                PageReference redirectPage = Page.RefWorkspaceNominationDetail;
                redirectPage.getParameters().put('Id',nominationObj.Id);
                redirectPage.getParameters().put('isFromWorkspace','false');
                redirectPage.getParameters().put('isSLDS','' + isSLDS);
                redirectPage.setRedirect(true);
                return redirectPage;
            }
        } catch (Exception e) { 
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()); 
            Apexpages.addMessage(message);
            database.rollback(sp);
            return null;
        }
    }

    /**
     * Method to create attribute on account/contact
     */
    private Set<String> createAttribute(Set<String> accountIds) {
        ALREADYaccattIds = new Set<String>();
        ALREADYconattIds = new Set<String>();
        Set<String> atttocreate = new Set<String>();
        List<Account> accToUpdate = new List<Account>();
        
        if (nominationObj.Contact__c == null || isMakeAccountMember) {
            
            for (Account_Attribute__c att : WithoutSharingHelperController.getAccountAttributesInCopyNomi(nominationObj.Account__c)) {
                ALREADYaccattIds.add(att.Attribute__c);
            }
        }
        
        if (nominationObj.Contact__c != null) {
            
            for (Contact_Attribute__c att : WithoutSharingHelperController.getContactAttributesInCopyNomi(new Set<String> {
                    nominationObj.Contact__c
                })) {
                ALREADYconattIds.add(att.Attribute__c);
            }
        }
        Boolean isBreak = false;
        isMakeAccountMember = true;
        
        if (nominationObj.Contact__c != null) {
            List<Account_Attribute__c> accAttList = new List<Account_Attribute__c>();
            List<Contact_Attribute__c> conAttList = new List<Contact_Attribute__c>();
            Boolean isupdateAccount = false;
            Boolean isupdateContact = false;
            List<Account> accounts = new List<Account>();
           
            if (isSharedContact && accountIds.size() > 0) {
            	
            	for (String accId : accountIds) {
            		
            		if(!soqlQuery.contains('WHERE')) {
            			soqlQuery += ' WHERE Id = \'' + accId + '\' ';
            		} else {
        				soqlQuery += ' OR Id = \'' + accId + '\' ';
            		}
            	}
            	accounts = WithoutSharingHelperController.getAccountUsingDynamicSOQL(soqlQuery);
            }
            
            if (tableMap != null && tableMap.containsKey('Attributes')) {
               
                for (nominationWrapper nw : tableMap.get('Attributes')) {
                   
                    if (!nw.isDisable && nw.isCopy == 'true') {
                        isBreak = false;
                       
                        for (String attId : nw.valueId.split(',')) {
                        	 
                            if (isMakeAccountMember) {
                                
                                if (labelIds != null && labelIds.containsKey(nw.labelId)) {
                                   
                                    for (Attribute_Mapping__c attMap : attMappingsAccount.values()) {
                                    	
                                    	if(isSharedContact && accountIds.size() > 0){
	                                    	
	                                    	for(Account accRecord : accounts){
		                                        
		                                        if (attMap.Filter_Label_Name__c == nw.label && (accRecord.get(attMap.Field_Api_Name__c) == null 
		                                        									|| accRecord.get(attMap.Field_Api_Name__c) == '')) {
		                                           
		                                            if (singleSelectPicklistAccount.contains(attMap.Field_Api_Name__c)) {
		                                                isupdateAccount = true;
		                                                accRecord.put(attMap.Field_Api_Name__c, nw.valueName.substringBefore(','));
		                                                isBreak = true;
		                                            } else if (multiSelectPicklistAccount.contains(attMap.Field_Api_Name__c)) {
		                                                isupdateAccount = true;
		                                                accRecord.put(attMap.Field_Api_Name__c, nw.valueName.replaceAll(',',';'));
		                                            } 
		                                        }
	                                    	}
                                    	} else {
                                    		
                                    		if (attMap.Filter_Label_Name__c == nw.label && (account.get(attMap.Field_Api_Name__c) == null 
                                    												|| account.get(attMap.Field_Api_Name__c) == '')) {
	                                           
	                                            if (singleSelectPicklistAccount.contains(attMap.Field_Api_Name__c)) {
	                                                isupdateAccount = true;
	                                                account.put(attMap.Field_Api_Name__c, nw.valueName.substringBefore(','));
	                                                isBreak = true;
	                                            } else if (multiSelectPicklistAccount.contains(attMap.Field_Api_Name__c)) {
	                                                isupdateAccount = true;
	                                                account.put(attMap.Field_Api_Name__c, nw.valueName.replaceAll(',',';'));
	                                            } 
	                                        }
                                    	}
                                    	ALREADYconattIds.add(attId);
                                    }

                                }
                            } else {
                               
                                if (labelIds != null && labelIds.containsKey(nw.labelId)) {
                                    
                                    for (Attribute_Mapping__c attMap : attMappingsAccount.values()) {
                                        
                                        if (attMap.Filter_Label_Name__c == nw.label && (account.get(attMap.Field_Api_Name__c) == null 
                                        									|| account.get(attMap.Field_Api_Name__c) == '')) {
                                           
                                            if (singleSelectPicklistAccount.contains(attMap.Field_Api_Name__c) 
                                            								|| multiSelectPicklistAccount.contains(attMap.Field_Api_Name__c)) {
                                                isBreak = true;
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if (isBreak) {
                                break;
                            }

                            if (labelIds != null && labelIds.containsKey(nw.labelId)) {
                                
                                for (Attribute_Mapping__c attMap : attMappingsContact.values()) {
                                    
                                    if (attMap.Filter_Label_Name__c == nw.label && (contact.get(attMap.Field_Api_Name__c) == null 
                                    									|| contact.get(attMap.Field_Api_Name__c) == '')) {
                                        
                                        if (singleSelectPicklistContact.contains(attMap.Field_Api_Name__c)) {
                                            isupdateContact = true;
                                            contact.put(attMap.Field_Api_Name__c, nw.valueName.substringBefore(','));
                                            isBreak = true;
                                        } else if (multiSelectPicklistContact.contains(attMap.Field_Api_Name__c)) {
                                            isupdateContact = true;
                                            contact.put(attMap.Field_Api_Name__c, nw.valueName.replaceAll(',',';'));
                                        }
                                    }
                                }
                                
                                if (isBreak) {
                                    break;
                                }
                            }
                            
                            if (!ALREADYconattIds.contains(attId)) {
                                Contact_Attribute__c newConAtt = new Contact_Attribute__c();
                                newConAtt.Contact__c = nominationObj.Contact__c;
                                newConAtt.Attribute__c = attId.trim();
                                atttocreate.add(attId.trim());
                                conAttList.add(newConAtt);
                            }
                        }
                    }
                }
            }
            
            if (isSharedContact && accountIds.size() > 0) {
	            
	            for(Account accRecord : accounts){
	            	accToUpdate.add(accRecord);
	            }
            }
            else {
            	accToUpdate.add(account);
            }
            
            if (isupdateAccount && accToUpdate.size() > 0) {
                ConstantsController.isCopyNominationDetailProcess = true;
                accToUpdate = WithoutSharingHelperController.upsertAccount(accToUpdate);
                ConstantsController.isCopyNominationDetailProcess = false;
            }
            
            if (isupdateContact) {
                ConstantsController.isCopyNominationDetailProcess = true;
                contact = WithoutSharingHelperController.upsertContact(contact);
                ConstantsController.isCopyNominationDetailProcess = false;
            }

            if (conAttList.size() > 0) {
                ConstantsController.isCopyNominationDetailProcess = true;
                system.debug('******conAttList************ '+conAttList);
                conAttList = WithoutSharingHelperController.upsertContactAttributes(conAttList);
                ConstantsController.isCopyNominationDetailProcess = false;
            } 
        }
       
        if (nominationObj.Contact__c == null) {
            Boolean isupdateAccount = false;
            List<Account_Attribute__c> accAttList = new List<Account_Attribute__c>();
           
            if (tableMap != null && tableMap.containsKey('Attributes')) {
                
                for (nominationWrapper nw : tableMap.get('Attributes')) {
                    
                    if (!nw.isDisable && nw.isCopy == 'true') {
                        isBreak = false;
                        
                        for (String attId : nw.valueId.split(',')) {
                           
                            if (labelIds != null && labelIds.containsKey(nw.labelId)) {
                                
                                for (Attribute_Mapping__c attMap : attMappingsAccount.values()) {
                                   
                                    if (attMap.Filter_Label_Name__c == nw.label && (account.get(attMap.Field_Api_Name__c) == null 
                                    							|| account.get(attMap.Field_Api_Name__c) == '')) {
                                       
                                        if (singleSelectPicklistAccount.contains(attMap.Field_Api_Name__c)) {
                                            isupdateAccount = true;
                                            account.put(attMap.Field_Api_Name__c, nw.valueName.substringBefore(','));
                                            isBreak = true;
                                        } else if (multiSelectPicklistAccount.contains(attMap.Field_Api_Name__c)) {
                                            isupdateAccount = true;
                                            account.put(attMap.Field_Api_Name__c, nw.valueName.replaceAll(',',';'));
                                        }
                                    }
                                }
                            }
                            
                            if (isBreak) {
                                break;
                            }
                            
                            if (!ALREADYaccattIds.contains(attId) && attId != '' && attId != null) {
                                Account_Attribute__c newAccAtt = new Account_Attribute__c();
                                newAccAtt.Account__c = nominationObj.Account__c;
                                newAccAtt.Attribute__c = attId.trim();
                                newAccAtt.Inheritable__c = (attributeInheritable != null && attributeInheritable.containsKey(attId.trim()) 
                                								? attributeInheritable.get(attId.trim()) : false);
                                
                                if (labelIds != null && labelIds.containsKey(nw.labelId)) {
                                    newAccAtt.Is_fromMapping__c = true;
                                }
                                accAttList.add(newAccAtt);
                            }
                        }
                    }
                }
            }
            
            if (isupdateAccount) {
                ConstantsController.isCopyNominationDetailProcess = true;
                account = (Account) WithoutSharingHelperController.updateSobjectFields(new List<sObject> {
                    account
                })[0];
                ConstantsController.isCopyNominationDetailProcess = false;
            }

            if (accAttList.size() > 0) {
                ConstantsController.isCopyNominationDetailProcess = true;
                accAttList = WithoutSharingHelperController.upsertAccountAttributes(accAttList);
                ConstantsController.isCopyNominationDetailProcess = false;
            } 
        }
        return atttocreate;
    }
    	
    private set<String> createRefer1() {
        List<Referenceability__c > refList = new List<Referenceability__c>();
        Set<String> reftocreate = new Set<String>();  
        Set<String> refIds = new Set<String>();
        Boolean accountActive = (accountRBI != null ? accountRBI.Is_Referenceable__c : false);
        
        if (tableMap != null && tableMap.containsKey('Referenceability')) {
            
            for (nominationWrapper nw : tableMap.get('Referenceability')) {
               
                if (!nw.isDisable && nw.isCopy == 'true' && nw.valueId != null && nw.valueId != '') {
                    Referenceability__c newRefer = new Referenceability__c();
					refIds.add(nw.valueId);
                    
                    if (nominationObj.Contact__c != null){
                        newRefer.Contact__c = nominationObj.Contact__c;
                        reftocreate.add(nw.valueId);
                    }
                    
                	if (nominationObj.Contact__c == null || (!isSharedContact && (accountRBI != null && accountRBI.Is_Referenceable__c))) {
                    	newRefer.Account__c = nominationObj.Account__c;
                	}
                    newRefer.Status__c = 'Approved';
                    newRefer.Comment__c = 'Mapped FROM Nomination';
                    newRefer.Verified__c = system.today();
                    newRefer.Referenceability_Type__c = nw.valueId;
                    refList.add(newRefer); 
                }
            }
        }
        
        if (refList.size() > 0) {
            ConstantsController.isCopyNominationDetailProcess = true;
            WithoutSharingHelperController.upsertReferenceabilities(refList);
            ConstantsController.isCopyNominationDetailProcess = false;
        }
        return reftocreate;
    }
    /**
     * Method to create Reference Note for Account/Contact which have field information of nomination
     */
    private void createNote() {
        List<Reference_Note__c> noteList = new List<Reference_Note__c>();
        List<User> userlist = [SELECT Name FROM User WHERE Id = : nominationObj.CreatedById];
       
        if (nominationObj.Other_Info__c != null && nominationObj.Other_Info__c != '') {
           
            if (tableMap != null && tableMap.containsKey('Comments')) {
                
                for (nominationWrapper nw : tableMap.get('Comments')) {
                    
                    if (!nw.isDisable && nw.isCopy == 'true') {
                        Reference_Note__c note = new Reference_Note__c();
                        
                        if (nominationObj.Contact__c == null) {
                            note.Account__c = nominationObj.Account__c;
                        } else {
                            note.Contact__c = nominationObj.Contact__c;
                        }
                        note.Note__c = '<Strong>Nomination Comments (provided by ' + userlist[0].Name + ')</Strong><br/>' + nominationObj.Other_Info__c;
                        noteList.add(note);
                    }
                }
            }
        }
        String FieldNote = '';
        
        if (tableMap != null && tableMap.containsKey('Additional Information')) {
            
            for (nominationWrapper nw : tableMap.get('Additional Information')) {
               
                if (!nw.isDisable && nw.isCopy == 'true') {
                    FieldNote += '<Strong>' + nw.label + '</Strong> - ' + (nw.valueName != null ? nw.valueName : '') + '<br/>';
                }
            }
        }
        
        if (FieldNote != '') {
            Reference_Note__c note = new Reference_Note__c();
            
            if (nominationObj.Contact__c == null) {
                note.Account__c = nominationObj.Account__c;
            } else {
                note.Contact__c = nominationObj.Contact__c;
            }
            note.Note__c = '<Strong>Nomination Additional Information (provided by ' + userlist[0].Name + ')</Strong><br/>' + FieldNote;
            noteList.add(note);
        }

        if (noteList.size() > 0) {
            noteList = WithoutSharingHelperController.upsertNotes(noteList);
        }
    }
    /**
     * Method to SELECT All data
     */
    public void selectAll() {
        
        if (tableMap != null) {
           
            for (String key : tableMap.keySet()) {
               
                for (nominationWrapper nw : tableMap.get(key)) {
                    
                    if (!nw.isDisable) {
                        nw.isCopy = 'true';
                    }
                }
            }
        }
    }
    /**
     * Method to deselect All data
     */
    public void deSelectAll() {
        
        if (tableMap != null) {
            
            for (String key : tableMap.keySet()) {
               
                for (nominationWrapper nw : tableMap.get(key)) {
                   
                    if (!nw.isDisable) {
                        nw.isCopy = 'false';
                    }
                }
            }
        }
    }
    /**
     * Method to cancel copy Nomination process
     */
    public pageReference cancelNomination() {
        
        if (isFromWorkspace && isSLDS) {
            String selection = apexpages.currentpage().getparameters().get('selection');
            PageReference redirectPage = Page.ReferenceWorkspaceSLDS;
            redirectPage.getParameters().put('selection',selection);
            redirectPage.setRedirect(true);
            return redirectPage;
        } else if (isFromWorkspace) {
            PageReference redirectPage = Page.ReferenceWorkspace;
            redirectPage.getParameters().put('activeTab','nomiTab');
            redirectPage.setRedirect(true);
            return redirectPage;
        } else {
            PageReference redirectPage = Page.RefWorkspaceNominationDetail;
            redirectPage.getParameters().put('Id',nominationObj.Id);
            redirectPage.getParameters().put('isFromWorkspace','false');
            redirectPage.setRedirect(true);
            return redirectPage;
        }
    }
    
    public List<SelectOption> getOptions(){
        List<SelectOption> options = new List<SelectOption >();
        options.add(new SelectOption('true', ''));
        options.add(new SelectOption('false', ''));
        return options;
    }
    /**
     * Wrapper Class
     */
    public class nominationWrapper {

        public String label { get; set; }
        public String labelId { get; set; }
        public String valueName { get; set; }
        public String isCopy { get; set; }
        public String valueId;
        public Boolean isDisable { get; set; }
        
        public nominationWrapper(String labelId, String label, String valueName, String valueId, Boolean isDisable) {
            this.label = label;
            this.labelId = labelId;
            this.valueName = valueName;
            this.valueId = valueId;
            this.isDisable = isDisable;
            if (!isDisable) {
                this.isCopy = 'true';
            }
        }
    }
}