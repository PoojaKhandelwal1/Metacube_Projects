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
 * VF Page : AccountLevelRUL.page
 * Description : Controller used for Account RBI inline.  
 * Last modified by: Rajesh @3 June 2017
 */
global with sharing class AccountLevelRULController extends RefEdgeEditionFeatures { 
    /**
     * Properties and variables
     */
    private Account acc;
    private String accId;
    public String caseId { get; set; }
    public Reference_Basic_Information__c RBI { get; set; }
    public String accountLevelRULValue { get; set; }
    public String RUL_Period { get; set; }
    public String RUL_Activities_will_do { get; set; }
    public Boolean isError { get; set; }
    public Boolean isEdit { get; set; }
    public Boolean isInformationSection { get; set; }
    public Boolean isUseLimitSection { get; set; }
    public Boolean isRewardSection { get; set; }
    public Boolean isExtraSection { get; set; }
    public List<String> informationFields { get; set; }
    public Map<String,FieldWrapper> labelMap { get; set; }
    public List<String> limitFields { get; set; }
    public List<String> rewardFields { get; set; }
    public List<String> extraFields { get; set; }
    public Boolean isAccountExist { get; set; }
    public String lastSectionHeader { get; set; }
    public Boolean isthisBasic {
        get { return isBasic; } set; }
    private list<Schema.FieldSetMember> lastfieldListLeft;
    private list<Schema.FieldSetMember> lastfieldListRight;
    private String query;    
    //Updated code for R11.29, Date : 17/10/2015, Tejpal
    private Custom_Settings__c cs;
    private List<Reference_Basic_Information__c> RBIList;
    public String ownerId { get; set; }
    public String ownerName { get; set; }
    public Boolean isSLDS { get; set; }
    public Boolean isShowSummary { get; set; }
	public Boolean isSharedContactEnabled { get; set; }
	// re #615 - isRefStatusInActive used get RBI status 
    public Boolean isRefStatusInActive { get; set; }  
    // re #615 - inputCSSClass used get set css style 
    public String inputCSSClass { get; set; }
    public String inactiveReason { get; set; }
    public String status { get; set; }
    //  REF-1975
    public String attributes { get; set; }
    
    /**
     * Constructor
     */
    global AccountLevelRULController(ApexPages.StandardController controller) {
    	 
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') { 
            isSLDS = true;
        } else { 
            isSLDS = false;
        }
         
        if (!isSLDS) {
	        isAccountExist = true;
	        
	        //for Account layout
	        if (controller.getId().startsWith('001')) {
	            accId = controller.getId();
	        } else if (controller.getId().startsWith('500')) {  //for case layout
	            caseId = controller.getId();
	            Case caseObj = [SELECT Id, AccountId FROM Case WHERE Id = :caseId];
	            accId = caseObj.AccountId;
	            
	            if (caseObj.AccountId == null) {
	                isAccountExist = false;
	                isInformationSection = true;
	                isUseLimitSection = true;
	                isRewardSection = true;
	            }
	        }
            labelMap = new Map<String,FieldWrapper>();

            for (String field: Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().keySet()) {
                FieldWrapper fw = new FieldWrapper();
                Schema.DescribeFieldResult dfr= Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get(field).getDescribe();
                fw.label = dfr.getLabel();
                fw.name = field;
                fw.inlineHelpText = dfr.getInlineHelpText();
                labelMap.put(field,fw);
            }
	        
	        if (isAccountExist) {
		        cs = UtilityController.getCustomSettings();
		        lastSectionHeader = (cs.Reference_Profile_Section_Header__c != null ? cs.Reference_Profile_Section_Header__c : 'Client-configured Section Heading');
		        isEdit = false;
		        isError = false;
		        isShowSummary = cs.Show_Summary__c;
		        isSharedContactEnabled = cs.Shared_Contacts__c;
		        lastfieldListLeft = SObjectType.Reference_Basic_Information__c.FieldSets.ReferenceProfileAccountLeft.getFields();
		        lastfieldListRight = SObjectType.Reference_Basic_Information__c.FieldSets.ReferenceProfileAccountRight.getFields();
		        //set field's order in their columns
		        setFieldsOrder();
		        Set<String> fieldSet = new Set<String>{'Total_Reference_Use_f__c', 'Profile_Update_Owner__c', 'Reference_Program_Candidate__c', 'Total_Reference_Use__c', 'Referenceability__c', 'Referenceability_Status__c', 'Reference_Owner__c', 'RUL_Period__c', 'RUL_Limit_Reached__c', 'RUL_Last_Updated_By__c', 'RUL_Last_Activity_Date__c', 'RUL_Date_Available_f__c', 'RUL_Date_Available__c', 'RUL_Activities_will_do__c', 'RUL_Activities_used__c', 'RUL_Activities_available__c', 'Managed_Reference_Account__c', 'Lifetime_Points__c','ACV_Influenced__c' ,'Joined_Reference_Program__c', 'Is_Referenceable_f__c', 'Is_Referenceable__c', 'Is_Contact_Limit_Reached__c', 'Id', 'Default_Period_Completed_Uses__c', 'Current_Available_Balance_Points__c', 'Attributes__c', 'Account__c', 'Account_Level_RUL__c', 'Generic_Account__c', 'Ref_Profile_Summary__c'};
		        Set<String> newFieldSet = new Set<String>();
		        query = 'SELECT ';
		       
		        for (Schema.FieldSetMember f : lastfieldListLeft) {
		            query += f.getFieldPath().toLowerCase() + ', ';
		            newFieldSet.add(f.getFieldPath().toLowerCase());
		        }
		        
		        for (Schema.FieldSetMember f : lastfieldListRight) {
		            
		            if (!newFieldSet.contains(f.getFieldPath().toLowerCase())) {
		                query += f.getFieldPath().toLowerCase() + ', ';
		            }
		            newFieldSet.add(f.getFieldPath().toLowerCase());
		        }
		        
		        for (String field : fieldSet) {
		        	
		            if (!newFieldSet.contains(field.toLowerCase()) && !newFieldSet.contains('refedge__'+field.toLowerCase())) {
		                query += field.toLowerCase() + ', ';
		            }
		        }
		        
		        if (!newFieldSet.contains('inactive_reason__c') && !newFieldSet.contains('refedge__inactive_reason__c')) {
		        	query += 'Inactive_Reason__c,';	        	
		        }
		        query += ' Name, Reference_Owner__r.Name FROM Reference_Basic_Information__c r WHERE Contact__c = null AND Account__c = \''+ String.escapeSingleQuotes(accId) +'\' LIMIT 1';
		        RBIList = WithoutSharingHelperController.getRBI(query); 
		        
		        if (RBIList.size() > 0) {
		            RBI = RBIList[0];
		            RUL_Period = (RBI.RUL_Period__c != null ? String.valueOf(RBI.RUL_Period__c) : null);
		            RUL_Activities_will_do = (RBI.RUL_Activities_will_do__c != null ? String.valueOf(RBI.RUL_Activities_will_do__c) : null);
		            
		            if (RBI.Reference_Owner__c != null) {
		                ownerId = RBI.Reference_Owner__c;
		                ownerName = RBI.Reference_Owner__r.Name;
		            }
		            // re #615 NEW - R18.56 - Reference Status “Inactive”, Reason Modal 
	                if (RBI.Referenceability_Status__c != null) { 
	                    isRefStatusInActive = (RBI.Referenceability_Status__c == 'Inactive') ? true : false; 
	                    inputCSSClass = (RBI.Referenceability_Status__c == 'Inactive') ? 'visible' : 'hidden';
	                    inactiveReason = RBI.Inactive_Reason__c;  
	                    status = RBI.Referenceability_Status__c; 
	                }  
                    //  REF-1975
                    attributes = UtilityController.rollUpAttributeMappingRBI(RBI.Account__c, true, null).removeEnd(', ');

                    if(RBI.Attributes__c != null && attributes != '') {
                        attributes = RBI.Attributes__c + ', ' + attributes;
                    } else if(RBI.Attributes__c == null && attributes != '') {
                        attributes = attributes; 
                    } else if(RBI.Attributes__c != null && attributes == '') {
                        attributes = RBI.Attributes__c;
                    }
                                
		        } else {
		            RBI = new Reference_Basic_Information__c(Account__c = accId);
		        } 
	        }
        }
    }
    
    /**
     * Method to update the Account
     */
    public PageReference updateAccount() {
       	
       	if (validation() && checkPermissionsforRBI(true)) {
	        
	        try {
	            
	            if (Boolean.valueof(accountLevelRULValue) == true) {
	                RBI.Account_Level_RUL__c = true;
	            } else {
	                RBI.Account_Level_RUL__c = false;
	            } 
	            
	            upsert RBI;
	            	            
            	//re #615 - Ref note created when referenceability status is set to inactive.
	           	if (checkPermissionsforRefNotes()) {
	           		
	           		if (status != RBI.Referenceability_Status__c && RBI.Referenceability_Status__c == 'Inactive') { 
		            	createReferenceNote(false); 
		            } else  if (inactiveReason != RBI.Inactive_Reason__c) { 
		            	createReferenceNote(true); 
		            }
	           	}
	            RBIList =  WithoutSharingHelperController.getRBI(query); 
	            
	            if (RBIList.size() > 0) {
	                RBI = RBIList[0]; 
	                
	                if (RBI.Reference_Owner__c != null) {
	                    ownerId = RBI.Reference_Owner__c;
	                    ownerName = RBI.Reference_Owner__r.Name;
	                }
	            }
	            isError = false;
	        } catch (Exception e) {
	            isError = true;
	            Apexpages.addMessages(e);
	        }
	        return null;
       	} else {
       		return null;
       	}
    }
    
    
    /**
     * Method to edit the process
     */
    public PageReference editRBI() {
        isEdit = true;
        
        //Updated code for R11.29, Date : 17/10/2015, Tejpal
        if (RBIList.size() == 0) {
            RBI.Managed_Reference_Account__c = cs.Default_Reference_Accounts_Managed__c; 
        }
        
        return null;
    }
    
    /**
     * Method to save the process
     */
    public PageReference saveRBI() {
                
        if (validation() && checkPermissionsforRBI(RBI.Id != null)) {
	       
	        try {
	            RBI.RUL_Period__c = (RUL_Period != null && RUL_Period != '') ? Decimal.valueOf(RUL_Period) : null;
                RBI.ACV_Influenced__c = (RBI.ACV_Influenced__c == null) ? 0 : RBI.ACV_Influenced__c;
	            RBI.RUL_Activities_will_do__c = (RUL_Activities_will_do != null && RUL_Activities_will_do != '') ? Decimal.valueOf(RUL_Activities_will_do) : null;
	            ConstantsController.defaultManagedReferenceAccount = false;// Updated code for R11.29, Date : 21/10/2015, Tejpal	            	                      
	            upsert RBI;	
	                    
	           	//re #615 - Ref note created when referenceability status is set to inactive.
	           	if (checkPermissionsforRefNotes()) {
	           		
		        	if (status != RBI.Referenceability_Status__c && RBI.Referenceability_Status__c == 'Inactive') { 
    					createReferenceNote(false); 
    				} else  if (inactiveReason != RBI.Inactive_Reason__c) { 
    					createReferenceNote(true); 
    				}
	           	}
	            RBIList = Database.query(query);
	            
	            if (RBIList.size() > 0) {
	                RBI = RBIList[0]; 
	                
	                if (RBI.Reference_Owner__c != null) {
	                    ownerId = RBI.Reference_Owner__c;
	                    ownerName = RBI.Reference_Owner__r.Name;
	                }
	            }
	            isEdit = false;
	            isError = false;
	        } catch (Exception e) {
	            isError = true;
	            Apexpages.addMessages(e);  
	        }
        } else {
        	return null;
        }
        return null;
    }
    
    /**
     * Method to validate for required field
     */
    private Boolean validation() {
    	boolean result = true;
    	
    	if (RBI.Referenceability_Status__c != null && RBI.Referenceability_Status__c == 'Inactive' && String.isBlank(RBI.Inactive_Reason__c)) {
    		Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO,'Please Provide the Inactive reason.'));
    		result = false;
    	}
    	
    	return result;        
    }
    
    /**
     * Method to add/update Reference Note
     */
    public void createReferenceNote(Boolean isUpdate) {
    	
    	if (isUpdate) {
    		List<Reference_Note__c> lstSelecedRefNotes = new List<Reference_Note__c>();
    		List<Reference_Note__c> lstRefNotes = [SELECT Id, Note__c FROM Reference_Note__c WHERE Account__c = :RBI.Account__c ORDER BY LastModifiedDate DESC LIMIT 1];
    		
    		if (lstRefNotes.size() > 0) {
	    		
	    		for (Reference_Note__c notes : lstRefNotes) {
	    			
	    			if (notes.Note__c.contains(System.Label.Reason_For_Inactive)) {
	    				lstSelecedRefNotes.add(notes);
	    				break;
	    			} 
	    		}
	    		
	    		if (lstSelecedRefNotes.size() > 0) {
	    			
	    			for (Reference_Note__c selectedNotes : lstSelecedRefNotes) {	    			 
		    			selectedNotes.Note__c = System.Label.Reason_For_Inactive + ' ';
		    			selectedNotes.Note__c += (RBI.inactive_reason__c != null) ? RBI.inactive_reason__c : '';
	    			}
	    		} 
	    		
	    		update lstSelecedRefNotes; 
    		} else if(RBI.inactive_reason__c != null && RBI.Referenceability_Status__c == 'Inactive') { 
    			insertReferenceNote(); 
    		}  	
    	} else {
    		 
    		if (RBI.Inactive_Reason__c != null && RBI.Referenceability_Status__c == 'Inactive') {
	    		insertReferenceNote();
    		}
    	}
    }
    
     /**
     * Method to add Reference Note
     */
    public void insertReferenceNote() {    	 
    	Reference_Note__c note = new Reference_Note__c();          
	 	note.Account__c = RBI.Account__c;
	 	note.Note__c = System.Label.Reason_For_Inactive + ' '+ RBI.inactive_reason__c;
		insert note; 
    }
    	       
    
    /**
     * Method to cancel the process
     */
    public PageReference cancelRBI() {
        isEdit = false;
        isError = false;
        
        if (RBI.Id != null) {
            List<Reference_Basic_Information__c> RBIList = Database.query(query);
            
            if (RBIList.size() > 0) {
                RBI = RBIList[0];
                RUL_Period = (RBI.RUL_Period__c != null ? String.valueOf(RBI.RUL_Period__c) : null);
                RUL_Activities_will_do = (RBI.RUL_Activities_will_do__c != null ? String.valueOf(RBI.RUL_Activities_will_do__c) : null);
            }
        }
        return null;
    }

    /**
     * Method to set order of fields in their columns
     */
    private void setFieldsOrder() {
        //set Reference Information section fields
        informationFields = new List<String>();
        List<String> leftFields = new List<String>();
        List<String> rightFields = new List<String>();
        leftFields.add('Reference_Program_Candidate__c');
        leftFields.add('Is_Referenceable__c');
        leftFields.add('Referenceability_Status__c');        
        leftFields.add('Managed_Reference_Account__c');   
        leftFields.add('ACV_Influenced__c');
        leftFields.add('Inactive_Reason__c'); // re #615 -Added new field 
        if (isSharedContactEnabled)
            leftFields.add('');
        rightFields.add('Total_Reference_Use_f__c');
        rightFields.add('Referenceability__c');
        rightFields.add('Attributes__c');
        rightFields.add('Reference_Owner__c');
        rightFields.add('Profile_Update_Owner__c');
        rightFields.add('Joined_Reference_Program__c');
        if (isSharedContactEnabled)
            rightFields.add('Generic_Account__c');
        
        
        for (Integer index = 0; index < leftFields.size() + rightFields.size(); index++) {
            informationFields.add('');
        }
        String objectName = '';
        String fieldtype = '';
        isInformationSection = false;
        Integer col = 0;
       
        for (String field : leftFields) {
            
            if (field != '' && Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get(field).getDescribe().isAccessible()) {
                informationFields[col] = field;
                col = col + 2;
                isInformationSection = true;
            }
        }
        col = 1;
       
        for (String field : rightFields) {
           
            if (field != '' && Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get(field).getDescribe().isAccessible()) {
                informationFields[col] = field;
                col = col + 2;
                isInformationSection = true;
            }
        }
        
        for (Integer index = leftFields.size() + rightFields.size() - 1; index >= 0; index--) {
           
            if (informationFields[index] == '') {
                informationFields.remove(index);
            } else {
                break;
            }
        }
        
        //set Reference Use Limits section fields
        limitFields = new List<String>();
        leftFields = new List<String>();
        rightFields = new List<String>();
        leftFields.add('RUL_Limit_Reached__c');
        leftFields.add('Is_Contact_Limit_Reached__c');
        leftFields.add('RUL_Last_Activity_Date__c');
        leftFields.add('RUL_Date_Available_f__c');
        leftFields.add('RUL_Last_Updated_By__c');
        rightFields.add('RUL_Period__c');
        rightFields.add('RUL_Activities_will_do__c');
        rightFields.add('RUL_Activities_used__c');
        rightFields.add('RUL_Activities_available__c');
        rightFields.add('Account_Level_RUL__c');
        
        for (Integer index = 0; index < leftFields.size() + rightFields.size(); index++) {
            limitFields.add('');
        }
        col = 0;
        isUseLimitSection = false;
        
        for (String field : leftFields) {
           
            if (field != '' && Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get(field).getDescribe().isAccessible()) {
                limitFields[col] = field;
                col = col + 2;
                isUseLimitSection = true;
            }
        }
        col = 1;
        
        for (String field : rightFields) {
           
            if (field != '' && Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get(field).getDescribe().isAccessible()) {
                limitFields[col] = field;
                col = col + 2;
                isUseLimitSection = true;
            }
        }
       
        for (Integer index = leftFields.size() + rightFields.size() - 1; index >= 0; index--) {
          
            if (limitFields[index] == '') {
                limitFields.remove(index);
            } else {
                break;
            }
        }
        //set Rewards Status section fields
        rewardFields = new List<String>();
        isRewardSection = false;
        
        if (Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get('Lifetime_Points__c').getDescribe().isAccessible()) {
            rewardFields.add('Lifetime_Points__c');
            isRewardSection = true;
        } else {
            rewardFields.add('');
        }
        
        if (Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get('Current_Available_Balance_Points__c').getDescribe().isAccessible()) {
            rewardFields.add('Current_Available_Balance_Points__c');
            isRewardSection = true;
        } else {
            rewardFields.add('');
        }
        
        for (Integer index = 1; index >= 0; index--) {
        	
            if (rewardFields[index] == '') {
                rewardFields.remove(index);
            } else {
                break;
            }
        }
        
        //set last section fields
        extraFields = new List<String>();
        leftFields = new List<String>();
        rightFields = new List<String>();
        
        for (Schema.FieldSetMember f : lastfieldListLeft) {
            leftFields.add(f.getFieldPath());
        }
        
        for (Schema.FieldSetMember f : lastfieldListRight) {
            rightFields.add(f.getFieldPath());
        }
        
        if (leftFields.size() > rightFields.size()) {
            integer difference = (leftFields.size() - rightFields.size()); 
            
            for (integer i = 0; i < difference; i++) {
                rightFields.add('');
            }
        } else if (rightFields.size() > leftFields.size()) {
            integer difference = (rightFields.size() - leftFields.size());
            
            for (integer i = 0; i < difference; i++) {
                leftFields.add('');
            }
        }
        
        for (Integer index = 0; index < leftFields.size() + rightFields.size(); index++) {
            extraFields.add('');
        }
        isExtraSection = false;
        col = 0;
       
        for (String field : leftFields) {
            
            if (field != '' && Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get(field).getDescribe().isAccessible()) {
                extraFields[col] = field;
                col = col + 2;
                isExtraSection = true;
            }
        }
        col = 1;
        
        for (String field : rightFields) {
            
            if (field != '' && Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get(field).getDescribe().isAccessible()) {
                extraFields[col] = field;
                col = col + 2;
                isExtraSection = true;
            }
        }
        
        for (Integer index = leftFields.size() + rightFields.size() - 1; index >= 0; index--) {
            
            if (extraFields[index] == '') {
                extraFields.remove(index);
            } else {
                break;
            }
        }
    }
    
    /**
     * Method to get LookupData By ObjectAndName-Deprecated Code
     */
    @RemoteAction
    global static List<User> getLookupDataByObjectAndName(String searchStringValue) {          
        return new List<User>();
    }
    
    /**
     * Method to check Permissions RBI
     */
    public static Boolean checkPermissionsforRBI(Boolean isUpdate) { 
        return CRUDAndFLSCheckController.checkPermissionsforAccountRBI(isUpdate);
    }
    
    /**
     * Method to check Permissions for Reference Notes
     */
    public static Boolean checkPermissionsforRefNotes() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	fieldMap.put(UtilityController.appNamespace() + 'Reference_Note__c', new Set<String>{ 
    											UtilityController.appNamespace() + 'Account__c',
        										UtilityController.appNamespace() + 'Note__c' });
    	
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true); 
    }
    
    /**
     * Field Wrapper
     */
    global class FieldWrapper { 
        public String label { get; set; }
        public String name { get; set; }
        public String inlineHelpText { get; set; }
    }  
}