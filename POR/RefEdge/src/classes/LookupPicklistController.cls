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
 * VF Component: LookupPicklistSLDS
 * Description: this class used to provide custom lookup in lightning pages
 * Created by: Gaurav Saini (21 June, 2017) for #886
 */
public with sharing class LookupPicklistController {
    
    /**
     * Constructor
     */
    public LookupPicklistController(ApexPages.StandardController controller) {}
    public LookupPicklistController() {}
    
    /**
     * RemoteAction to get searched records
     */
    @RemoteAction
    public static List<RecordWrapper> fetchData(String searchText, String objectName) {
		List<RecordWrapper> recordList = new List<RecordWrapper>();
		String queryString = '';
		
		if (objectName == 'MemberAccounts') {
			
			//if there is a text string to search
		    	if (searchText != null && searchText.trim().length() > 0) {
		            String searchValue = searchText.replace('*', '%') + '%';
		            searchValue = String.escapeSingleQuotes(searchValue);
		            String searchValueNext = '\'% ' + searchValue + '\'';
		            searchValue = '\'' + searchValue + '\'';
		            queryString = 'SELECT Account__c, Account__r.Name FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null ' 
	                			+ 'AND (Account__r.Name LIKE ' + searchValue + ' OR Account__r.Name LIKE ' + searchValueNext 
	                			+ ') AND Is_Referenceable__c = true AND Referenceability_Status__c != \'\' ORDER BY Account__r.Name LIMIT 20';
		    	} else {
		    		queryString = 'SELECT Account__c, Account__r.Name FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null ' 
	                			+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'\' ORDER BY Account__r.Name LIMIT 20';
		    	}
	    	
			for (Reference_Basic_Information__c rbi : Database.query(queryString)) {
	    		recordList.add(new RecordWrapper(rbi.Account__c, rbi.Account__r.Name));
	    	}
		//this is for Active accounts WithoutSharing
		} else if (objectName == 'ActiveAccounts') {
			
			//if there is a text string to search
		    	if (searchText != null && searchText.trim().length() > 0) {
		            String searchValue = searchText.replace('*', '%') + '%';
		            searchValue = String.escapeSingleQuotes(searchValue);
		            String searchValueNext = '\'% ' + searchValue + '\'';
		            searchValue = '\'' + searchValue + '\'';
		            queryString = 'SELECT Account__c, Account__r.Name FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null ' 
	                			+ 'AND (Account__r.Name LIKE ' + searchValue + ' OR Account__r.Name LIKE ' + searchValueNext 
	                			+ ') AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' 
	                			+ ConstantsController.INACTIVE + '\' AND Referenceability_Status__c != \'\') ORDER BY Account__r.Name LIMIT 20';
		    	} else {
		    		queryString = 'SELECT Account__c, Account__r.Name FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null ' 
	                			+ 'AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' 
	                			+ ConstantsController.INACTIVE + '\' AND Referenceability_Status__c != \'\') ORDER BY Account__r.Name LIMIT 20';
		    	}
	    	
			for (Reference_Basic_Information__c rbi : Database.query(queryString)) {
	    		recordList.add(new RecordWrapper(rbi.Account__c, rbi.Account__r.Name));
	    	}
		//this is for candidate accounts WithoutSharing
		} else if (objectName == 'CandidateAccounts') {
			
			if (searchText != null && searchText.trim().length() > 0) {
	            String searchValue = searchText.replace('*', '%') + '%';
	            searchValue = String.escapeSingleQuotes(searchValue);
				String searchValueNext = '\'% ' + searchValue + '\'';
	            searchValue = '\'' + searchValue + '\'';
	            queryString = 'SELECT Account__r.Name, Reference_Program_Candidate__c, '
    					+ 'Is_Referenceable__c, Referenceability_Status__c '
    					+ 'FROM Reference_Basic_Information__c '
    					+ 'WHERE Contact__c = null '
    					+ 'AND Account__c != null '
    					+ 'AND (Account__r.Name LIKE ' + searchValue
    					+ ' OR Account__r.Name LIKE ' + searchValueNext 
    					+ ') AND Reference_Program_Candidate__c = true LIMIT 20';
		    	} else {
	    			queryString = 'SELECT Account__r.Name, Reference_Program_Candidate__c, '
    					+ 'Is_Referenceable__c, Referenceability_Status__c '
    					+ 'FROM Reference_Basic_Information__c '
    					+ 'WHERE Contact__c = null '
    					+ 'AND Account__c != null '
    					+ ' AND Reference_Program_Candidate__c = true LIMIT 20';
			}
			
			List<Reference_Basic_Information__c> rbiList = WithoutSharingHelperController.getRBI(queryString);
				
			for (Reference_Basic_Information__c rbi : rbiList) {
				recordList.add(new RecordWrapper(rbi.Account__c, rbi.Account__r.Name));
			}
		} else if (objectName.contains('ContactsFromAccount')) {
			String accountId = objectName.split(',').get(1);
			Boolean isMember = objectName.split(',').get(2) == 'true' ? true : false;
			Boolean checkMember = objectName.split(',').get(2) == 'null' ? true : false;
			
			if (checkMember) {
				Reference_Basic_Information__c rbi = WithoutSharingHelperController.getRBIReferenceable(accountId).get(0);
				isMember = rbi.Is_Referenceable__c;
			}
			
            String searchValue = searchText.replace('*', '%') + '%';
			searchValue = String.escapeSingleQuotes(searchValue);
			String searchValueNext = '\'% ' + searchValue + '\'';
			searchValue = '\'' + searchValue + '\'';
			
			List<Contact> contactList = new List<Contact>();
	        Set<Id> contactIds = WithoutSharingHelperController.getAccountContactsForNomination(accountId, UtilityController.getCustomSettings());
	        String contactQuery = 'SELECT Id, Name, (SELECT Id, Reference_Program_Candidate__c, Is_Referenceable__c FROM Reference_Basic_Informations__r) ' +
	        						'FROM Contact WHERE (AccountId =: accountId OR Id IN :contactIds) ';
	        						
	        if (searchText != null && searchText.trim().length() > 0) {
	        	contactQuery += 'AND (Name LIKE ' + searchValue
    							+ ' OR Name LIKE ' + searchValueNext 
    							+ ') ';
	        } 
	        contactQuery += 'ORDER BY LastName';
	        
	        for (Contact contactRec : Database.query(contactQuery)) {
	        	if(contactRec.Reference_Basic_Informations__r.size() == 0 
	        		|| (isMember && contactRec.Reference_Basic_Informations__r[0].Is_Referenceable__c)
	        		|| (!isMember && contactRec.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c))
				recordList.add(new RecordWrapper(contactRec.Id, contactRec.Name));
			}
		} else if (objectName == 'ActiveContacts') {
			
			//if there is a text string to search
	    	if (searchText != null && searchText.trim().length() > 0) {
	            String searchValue = searchText.replace('*', '%') + '%';
	            searchValue = String.escapeSingleQuotes(searchValue);
	            String searchValueNext = '\'% ' + searchValue + '\'';
	            searchValue = '\'' + searchValue + '\'';
	            queryString = 'SELECT Contact__c, Contact__r.Name FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c != null ' 
                			+ 'AND (Contact__r.Name LIKE ' + searchValue + ' OR Contact__r.Name LIKE ' + searchValueNext 
                			+ ') AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' 
                			+ ConstantsController.INACTIVE + '\' AND Referenceability_Status__c != \'\') ORDER BY Contact__r.Name LIMIT 20';
	    	} else {
	    		queryString = 'SELECT Contact__c, Contact__r.Name FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c != null ' 
                			+ 'AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' 
                			+ ConstantsController.INACTIVE + '\' AND Referenceability_Status__c != \'\') ORDER BY Contact__r.Name LIMIT 20';
	    	}
	    	
			for (Reference_Basic_Information__c rbi : Database.query(queryString)) {
	    		recordList.add(new RecordWrapper(rbi.Contact__c, rbi.Contact__r.Name));
	    	}
	    	
		//this is for future use when we need lookup for candidate contacts
		} else if (objectName == 'CandidateContacts') {
		
		//changes regarding #860
		} else if (objectName == 'Reference_Content__c') {
			
			//if there is a text string to search
		    	if (searchText != null && searchText.trim().length() > 0) {
		            String searchValue = searchText.replace('*', '%') + '%';
		            searchValue = String.escapeSingleQuotes(searchValue);
		            String searchValueNext = '\'% ' + searchValue + '\'';
		            searchValue = '\'' + searchValue + '\'';
		            queryString = 'SELECT Id, Name, Title__c, Reference_Content_Type__r.Name__c FROM ' + objectName + 
		            						' WHERE Name LIKE ' + searchValue  + ' OR Name LIKE ' + searchValueNext +
		            						' OR Title__c LIKE ' + searchValue  + ' OR Title__c LIKE ' + searchValueNext +
		            						' OR Reference_Content_Type__r.Name__c LIKE ' + searchValue  + 
		            						' OR Reference_Content_Type__r.Name__c LIKE ' + searchValueNext +
		            						'ORDER BY Name LIMIT 20';
		    	} else {
		    		queryString = 'SELECT Id, Name, Title__c, Reference_Content_Type__r.Name__c FROM ' + objectName + ' ORDER BY Name LIMIT 20';
		    	}
	    	
		    	for (Reference_Content__c rc : Database.query(queryString)) {
		    		RecordWrapper rw = new RecordWrapper(rc.Id, rc.Name);
		    		rw.title = rc.Title__c;
		    		rw.conType = rc.Reference_Content_Type__r.Name__c;
		    		recordList.add(rw);
		    	}
		} else if (objectName == 'Active_Non_Community_Users') {
			String communityProfileName = '\'%Community%\'';
			String siteProfileName = '\'%Guest%\'';
			
			if (searchText != null && searchText.trim().length() > 0) {
				String searchValue = searchText.replace('*', '%') + '%';
	            searchValue = String.escapeSingleQuotes(searchValue);
	            String searchValueNext = '\'% ' + searchValue + '\'';
	            searchValue = '\'' + searchValue + '\'';
				queryString = 'SELECT Id, Name, IsActive, Profile.Name, ProfileId FROM User '
								+ 'WHERE IsActive = true '
								+ 'AND (NOT Profile.Name LIKE ' + communityProfileName + ') '
								+ 'AND (NOT Profile.Name LIKE ' + siteProfileName + ') '
								+ 'AND (NOT Name LIKE ' + siteProfileName + ') '
								+ 'AND (Name LIKE ' + searchValue + ' '
        						+ 'OR Name LIKE ' + searchValueNext + ') ORDER BY Name LIMIT 20';
			} else {
				queryString = 'SELECT Id, Name, IsActive, Profile.Name, ProfileId FROM User '
								+ 'WHERE IsActive = true '
								+ 'AND (NOT Profile.Name LIKE ' + communityProfileName + ') '
								+ 'AND (NOT Profile.Name LIKE ' + siteProfileName + ') '
								+ 'AND (NOT Name LIKE ' + siteProfileName + ') '
								+ 'ORDER BY Name LIMIT 20';
			}
			
			for (Sobject sObj : Database.query(queryString)) {
	    			recordList.add(new RecordWrapper(String.valueOf(sObj.get('Id')), String.valueOf(sObj.get('Name'))));
	    		}
		} else if (objectName == 'ContentDocument') {
			
			if (searchText != null && searchText.trim().length() > 0) {
				String searchValue = searchText.replace('*', '%') + '%';
	            searchValue = String.escapeSingleQuotes(searchValue);
	         
	            searchValue = '\'' + searchValue + '\'';
				queryString = 'SELECT Title FROM ContentDocument '
								+ 'WHERE ' + 'Title LIKE ' + searchValue + ' AND PublishStatus != \'R\' ORDER BY Title LIMIT 20 '; 
								
				for (Sobject sObj : Database.query(queryString)) {
	    			recordList.add(new RecordWrapper(String.valueOf(sObj.get('Title')), String.valueOf(sObj.get('Title'))));
	    		} 
			}
		} else if (objectName == 'Case') {//for search purpose on case 'Subject' has been included in the name and should be removed from the 'selectedName'
			
				//if there is a text string to search
		    	if (searchText != null && searchText.trim().length() > 0) {
		            String searchValue = searchText.replace('*', '%') + '%';
		            searchValue = String.escapeSingleQuotes(searchValue);
		            String searchValueNext = '\'%' + searchValue + '\'';
		            searchValue = '\'' + searchValue + '\'';
		            queryString = 'SELECT Id, Subject, CaseNumber FROM Case WHERE CaseNumber LIKE ' + searchValue 
		            						+ ' OR CaseNumber LIKE ' + searchValueNext
											+ ' OR Subject LIKE ' + searchValueNext
											+ 'ORDER BY CaseNumber LIMIT 20';
		    	} else {
		    		queryString = 'SELECT Id, Subject , CaseNumber FROM Case ORDER BY CaseNumber LIMIT 20';
		    	}
		    	
		    	for (Sobject sObj : Database.query(queryString)) {
		    		recordList.add(new RecordWrapper(String.valueOf(sObj.get('Id')), String.valueOf(sObj.get('CaseNumber')) + ((sObj.get('Subject') == null || String.valueOf(sObj.get('Subject')).trim() == '') ? '' :  ' : ' + String.valueOf(sObj.get('Subject')))));
		    	}
		} else {
			
				//if there is a text string to search
		    	if (searchText != null && searchText.trim().length() > 0) {
		            String searchValue = searchText.replace('*', '%') + '%';
		            searchValue = String.escapeSingleQuotes(searchValue);
		            String searchValueNext = '\'% ' + searchValue + '\'';
		            searchValue = '\'' + searchValue + '\'';
		            queryString = 'SELECT Id, Name FROM ' + objectName + ' WHERE Name LIKE ' + searchValue 
		            						+ ' OR Name LIKE ' + searchValueNext + 'ORDER BY Name LIMIT 20';
		    	} else {
		    		queryString = 'SELECT Id, Name FROM ' + objectName + ' ORDER BY Name LIMIT 20';
		    	}
		    	
		    	for (Sobject sObj : Database.query(queryString)) {
		    		recordList.add(new RecordWrapper(String.valueOf(sObj.get('Id')), String.valueOf(sObj.get('Name'))));
		    	}
		}
    	return recordList;
    }
    
    /**
     * Wrapper class for all information
     */
 	public class RecordWrapper {
 		public String id { get; set; }
 		public String name { get; set; }
 		//changes regarding #860
 		public String title { get; set; }
 		public String conType { get; set; }
 		
 	    public RecordWrapper(String id, String name) {
            this.id = id;
            this.name = name;
	    }
 	}
}