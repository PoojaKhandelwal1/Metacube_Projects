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
 * Page: AddReferenceNote
 * Description : Class used to insert and update Reference Note.
 * Created by: Rekha @7 June 2017
 */
public with sharing class AddReferenceNoteControllerSLDS extends RefEdgeEditionFeatures {
	/**
     * Properties and variables
     */
    public String returnId { get; set; }
    public String recordId { get; set; }
    public String fromWhere { get; set; }
    public Boolean fromDetailPage { get; set; }
    // added for #660 - Gaurav Saini (25 Sep, 2017)
    public String dateString { get; set; }
    
    /**
     * Constructor
     */
    public AddReferenceNoteControllerSLDS(ApexPages.StandardController controller){
    	Reference_Note__c refNote = (Reference_Note__c) controller.getRecord();
    	fromDetailPage = false;
    	dateString = String.valueOf(Date.today());
    	
    	if (ApexPages.currentPage().getParameters().get('fromDetail') != null && ApexPages.currentPage().getParameters().get('fromDetail') != '') {
			fromDetailPage = (ApexPages.currentPage().getParameters().get('fromDetail') == 'true' ? true : false);
		}
    	
    	if (refNote.Id != null) {
    		recordId = refNote.Id;
    	} else {
    		recordId = '';
    		
	    	if (refNote.Account__c != null) {
	        	returnId = refNote.Account__c;
	        	fromWhere = 'Account';
	        }
	        
	        if (refNote.Contact__c != null) {
	        	returnId = refNote.Contact__c;
	        	fromWhere = 'Contact';
	        }
	        
	        if (refNote.Reference_Content__c != null) {
	        	returnId = refNote.Reference_Content__c; 
	        	fromWhere = 'Content';
	        }
	        
	        if (refNote.Reference_Request__c != null) {
	        	returnId = refNote.Reference_Request__c;
	        	fromWhere = 'RR';
	        }
	        
	        if (refNote.Account_Request__c != null) {
	        	returnId = refNote.Account_Request__c;
	        	fromWhere = 'AR';
	        }
	        
	        if (refNote.Unspecified_Request__c != null) {
	        	returnId = refNote.Unspecified_Request__c;
	        	fromWhere = 'UR';
	        }

			if (refNote.Nomination__c != null) {
	        	returnId = refNote.Nomination__c;
	        	fromWhere = 'NC';
	        }
    	}
    	
    }
    
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage(String recordId) {
    	//re #903
		checkPermissions(recordId);
    	return CRUDAndFLSCheckController.getErrorMsg();
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
     * Method to check Permissions
     */
    public static Boolean checkPermissions(String recordId) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		fieldMap.put(UtilityController.appNamespace() + 'Reference_Note__c', new Set<String>());
		
		//re #903
        if (recordId != null && recordId != '') {
			return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
		} else {
        	return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
		}
    }
    
    /**
     * RemoteAction to get all intial information
     */
    @RemoteAction
    public static InfoWrapper fetchInfo(String recordId, String returnId, String fromWhere) {
    	InfoWrapper infoWp = new InfoWrapper();
    	
    	try {
    		List<Reference_Note__c> refNotes = [SELECT Name, Id, Account__c, Account__r.Name, Contact__c, Contact__r.Name, Reference_Content__c,
    						Reference_Content__r.Name, Reference_Request__c, Reference_Request__r.Name, Account_Request__r.Name,
    						Account_Request__c, Unspecified_Request__c, Unspecified_Request__r.Name, Nomination__c, Nomination__r.Name, 
	             			Note__c, Note_Date__c FROM Reference_Note__c WHERE Id = :recordId];
	       	
	       	if (refNotes.size() > 0) {

	       		if (refNotes[0].Account__c != null) {
	       			infoWp.parentName = refNotes[0].Account__r.Name;
		        	infoWp.returnId = refNotes[0].Account__c;
		        	infoWp.fromWhere = 'Account';
		        }
		        
		        if (refNotes[0].Contact__c != null) {
		        	infoWp.parentName = refNotes[0].Contact__r.Name;
		        	infoWp.returnId = refNotes[0].Contact__c;
		        	infoWp.fromWhere = 'Contact';
		        }
		        
		        if (refNotes[0].Reference_Content__c != null) {
		        	infoWp.parentName = refNotes[0].Reference_Content__r.Name;
		        	infoWp.returnId = refNotes[0].Reference_Content__c;
		        	infoWp.fromWhere = 'Content';
		        }
		        
		        if (refNotes[0].Reference_Request__c != null) {
		        	infoWp.parentName = refNotes[0].Reference_Request__r.Name;
		        	infoWp.returnId = refNotes[0].Reference_Request__c;
		        	infoWp.fromWhere = 'RR';
		        }
		        
		        if (refNotes[0].Account_Request__c != null) {
		        	infoWp.parentName = refNotes[0].Account_Request__r.Name;
		        	infoWp.returnId = refNotes[0].Account_Request__c;
		        	infoWp.fromWhere = 'AR';
		        }
		        
		        if (refNotes[0].Unspecified_Request__c != null) {
		        	infoWp.parentName = refNotes[0].Unspecified_Request__r.Name;
		        	infoWp.returnId = refNotes[0].Unspecified_Request__c;
		        	infoWp.fromWhere = 'UR';
		        }

				if (refNotes[0].Nomination__c != null) {
		        	infoWp.parentName = refNotes[0].Nomination__r.Name;
		        	infoWp.returnId = refNotes[0].Nomination__c;
		        	infoWp.fromWhere = 'NC';
		        }
		        infoWp.id = refNotes[0].Id;
		        infoWp.name = refNotes[0].Name;
	       		infoWp.noteDate = (refNotes[0].Note_Date__c != null ? JSON.serialize(refNotes[0].Note_Date__c) : '');
	       		infoWp.noteDateNew = refNotes[0].Note_Date__c;
	       		infoWp.note = refNotes[0].Note__c;
	       	} else {
	       		
	       		if (fromWhere == 'Account') {
	       			List<Account> accounts = [SELECT Name FROM Account WHERE Id = :returnId];
	       			infoWp.parentName = accounts.size() > 0 ? accounts[0].Name : '';
	       		} else if (fromWhere == 'Contact') {
	       			List<Contact> contacts = [SELECT Name FROM Contact WHERE Id = :returnId];
	       			infoWp.parentName = contacts.size() > 0 ? contacts[0].Name : '';
	       		} else if (fromWhere == 'Content') {
	       			List<Reference_Content__c> contents = [SELECT Name FROM Reference_Content__c WHERE Id = :returnId];
	       			infoWp.parentName = contents.size() > 0 ? contents[0].Name : '';
	       		} else if (fromWhere == 'RR') {
	       			List<Reference_Request__c> reqs = [SELECT Name FROM Reference_Request__c WHERE Id = :returnId];
	       			infoWp.parentName = reqs.size() > 0 ? reqs[0].Name : '';
	       		} else if (fromWhere == 'AR') {
	       			List<Reference_Request_Account__c> reqs = [SELECT Name FROM Reference_Request_Account__c WHERE Id = :returnId];
	       			infoWp.parentName = reqs.size() > 0 ? reqs[0].Name : '';
	       		} else if (fromWhere == 'UR') {
	       			List<Unspecified_Request__c> reqs = [SELECT Name FROM Unspecified_Request__c WHERE Id = :returnId];
	       			infoWp.parentName = reqs.size() > 0 ? reqs[0].Name : '';
	       		} else if (fromWhere == 'NC') {
	       			List<Nomination__c> reqs = [SELECT Name FROM Nomination__c WHERE Id = :returnId];
	       			infoWp.parentName = reqs.size() > 0 ? reqs[0].Name : '';
	       		}
	       		infoWp.fromWhere = fromWhere;
	       		infoWp.returnId = returnId;
	       	}
    	} catch(Exception e) {
			infoWp.error = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
    	return infoWp;
    }
    
    /**
     * RemoteAction to submit the reward
     */
    @RemoteAction
    public static String submit(String infoJson) {
        
        try {
        	InfoWrapper infoWp = (InfoWrapper)JSON.deserialize(infoJson, InfoWrapper.class);
        	
        	//re #903
        	if (checkPermissions(infoWp.id)) {
        		Reference_Note__c refNote = new Reference_Note__c(Id = infoWp.id, Note__c = infoWp.note, Note_Date__c = infoWp.noteDateNew);
				
	       		if (infoWp.fromWhere == 'Account') {
	       			refNote.Account__c = infoWp.returnId;
	       		} else if (infoWp.fromWhere == 'Contact') {
	       			refNote.Contact__c = infoWp.returnId;
	       		} else if (infoWp.fromWhere == 'Content') {
	       			refNote.Reference_Content__c = infoWp.returnId;
	       		} else if (infoWp.fromWhere == 'RR') {
	       			refNote.Reference_Request__c = infoWp.returnId;
	       		} else if (infoWp.fromWhere == 'AR') {
	       			refNote.Account_Request__c = infoWp.returnId;
	       		} else if (infoWp.fromWhere == 'UR') {
	       			refNote.Unspecified_Request__c = infoWp.returnId;
	       		} else if (infoWp.fromWhere == 'NC') {
	       			refNote.Nomination__c = infoWp.returnId;
	       		}
				upsert refNote;
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        	return '';
        } catch(Exception e) {
			return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
    }
    
    /**
     * Wrapper class
     */
 	public class InfoWrapper {
 		public String id { get; set; }
 		public String name { get; set; }
 		public String fromWhere { get; set; }
 		public String returnId { get; set; }
 		public String parentName { get; set; }
 		public String error { get; set; }
 		public String note { get; set; }
 		public String noteDate { get; set; }
 		public Date noteDateNew { get; set; }
	    
	    public InfoWrapper() {
            error = '';
	    }
 	}
}