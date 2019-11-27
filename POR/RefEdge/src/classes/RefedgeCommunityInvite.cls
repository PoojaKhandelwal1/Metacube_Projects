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
 * VF Page : RefedgeCommunityInvite 
 * Description : Class is used to handle Invite Community Members.
 * Last Modified By : Rajesh @Feb 14 2017
 */
public with sharing class RefedgeCommunityInvite extends RefEdgeEditionFeatures {
	/**
     * Properties and variables
     */
    private List<String> alreadyUsers = new List<String>();
    private Set<String> rbiSet = new Set<String>();
    private Map<Integer, List<ContactRBIToInvite>> mapContactRBIToInvite = new Map<Integer, List<ContactRBIToInvite>>();    
    public List<ContactRBIToInvite> contactRBIs { get; set; }
    public integer pagecounter { get; set; }
    public integer recordlimits { get; set; }    
    public Boolean isPrevious { get; set; }
    public Boolean isNext { get; set; }    
    public User user { get; set; }
    public List<SelectOption> profiles { get; set; }
    public String selectedProfile { get; set; }
    public List<User> users { get; set; }    
    public Boolean isBlockChange { get; set;}
    public List<ContactRBIToInvite> selectedContacts { get; set; }    
    public List<String> alphaList { get; set; }
    public String alphaFilter { get; set; }
    public String sortFieldSave;
    //sortField
	public String sortField {
		get { 
			
			if (sortField == null) {
				sortField = 'Contact__r.LastName'; 
			} 
			return sortField;  
		}
		set; 
	}
	
    //sortDirection
    public String sortDirection {
		get { 
			if (sortDirection == null) {  
				sortDirection = 'asc'; 
			} 
			return sortDirection;  
		}
		set;
	}
	
    /**
     * Constructor
     */
    public RefedgeCommunityInvite() {
    	//check User premissions
    	checkPermissions();
        isBlockChange = false;
        recordlimits = 25;
        alphaList = new List<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Other', 'All'};
        sortFieldSave = sortField;  
        users = new List<User>([SELECT ProfileId, Name, Email, ContactId, AccountId FROM User WHERE Profile.UserLicense.Name = 'Customer Community' 
        							AND Profile.UserType = 'CspLitePortal' AND ContactId != null AND IsActive = true ORDER BY Name]);

        for (User users : [SELECT ContactId FROM user WHERE ContactId != null]) {
            alreadyUsers.add(users.ContactId);
        }
        pagecounter = 1;
        searchresult();
        alphaFilter = 'All';
    }
    
    public void alphabetSorting(){
    	pagecounter = 1;
        rbiSet = new Set<String>();
    	mapContactRBIToInvite = new Map<Integer, List<ContactRBIToInvite>>();
        searchresult();
    }
    
    public void sortToggle() {
		sortDirection = sortDirection.equals('asc') ? 'desc' : 'asc';
        
        if (sortFieldSave != sortField) {
            sortDirection = 'asc';
            alphaFilter = 'All';
            sortFieldSave = sortField;
        }
        alphabetSorting();
	}
	
	public String buildWhereClause(String queryWhere, String cond) {
    	return queryWhere + ' AND ' + cond;
    }
    
    /**
     * Method to Searched RBI records
     */ 
    public void searchresult(){
        contactRBIs = new List<ContactRBIToInvite>();
        
        if (mapContactRBIToInvite.containsKey(pagecounter)) {        	 
            isNext = true;
            contactRBIs.addAll(mapContactRBIToInvite.get(pagecounter));
        } else {
            Integer extraRecordLimits = recordlimits+1; 
            isNext = false;
            String queryUser = 'SELECT Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.AccountId, ';
            queryUser += 'Contact__r.Account.OwnerId, Contact__r.Account.Owner.UserRole.Name FROM Reference_Basic_Information__c Where ID NOT IN :rbiSet AND Contact__c NOT IN :alreadyUsers ';
            queryUser += 'AND Is_Referenceable__c = true AND (Referenceability_Status__c = \'Active\' OR Referenceability_Status__c = \'Caution\') AND Contact__r.Account.Owner.UserRoleId != null AND Contact__r.Email != null ';
        	String queryWhereClause = '';
        	
        	if (alphaFilter == null || alphaFilter.trim().length() == 0) {
	            alphaFilter = 'All';
	        } else if (alphaFilter == 'Other') {
	            queryWhereClause += buildWhereClause(queryWhereClause, '(' + String.escapeSingleQuotes(SortField) + ' < \'A\' OR ' + String.escapeSingleQuotes(SortField) + ' > \'Z\') AND (NOT ' + String.escapeSingleQuotes(SortField) + ' LIKE \'Z%\') ');
	        } else if (alphaFilter != 'All') {
	            queryWhereClause += buildWhereClause(queryWhereClause, '(' + String.escapeSingleQuotes(SortField) + ' LIKE \'' + String.escapeSingleQuotes(alphaFilter) + '%\')' );
	        }
        
        	queryUser +=  queryWhereClause+' ORDER BY ' + String.escapeSingleQuotes(SortField) + ' ' + String.escapeSingleQuotes(SortDirection);
        	
        	for (Reference_Basic_Information__c r : Database.query(queryUser + ' LIMIT :extraRecordLimits')) {
        		
                if (contactRBIs.size() < recordlimits) {
                    rbiSet.add(r.Id);
                    contactRBIs.add(new ContactRBIToInvite(false, r));
                } else {
                    isNext = true;
                }
            }
            mapContactRBIToInvite.put(pagecounter, contactRBIs);
        }
    }
    
    /**
     * Method to next
     */ 
    public void next(){
        pagecounter++;
        searchresult();
    }
    
    /**
     * Method to previous
     */ 
    public void previous(){
        pagecounter--;
        searchresult();
    }
    
    /**
     * Method to Select & continue
     */  
    public void selectAndContinue(){        
        profiles = new List<SelectOption>();
        
        for (Profile p : [SELECT id, name FROM Profile WHERE UserLicense.Name = 'Customer Community' AND UserType = 'CspLitePortal' ORDER BY Name]) {
            profiles.add(new SelectOption(p.id, p.Name));
            
            if (p.Name == 'RefEdge Customer Community') {
            	selectedProfile = p.id;
            }
        }
        
        if (selectedProfile == '') {
        	selectedProfile = (profiles.size() > 0 ? profiles[0].getValue() : '');
        }
        
        user = new User(emailencodingkey = 'UTF-8', languagelocalekey = 'en_US', localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');        
        selectedContacts = new List<ContactRBIToInvite>();
        
        for (List<ContactRBIToInvite> crbi : mapContactRBIToInvite.values()) {
            
            for (ContactRBIToInvite cri : crbi) {
                
                if (cri.isSelected) {
                    User contactuser = new User(contactId = cri.rbi.Contact__c, firstname = cri.rbi.Contact__r.FirstName, lastname = cri.rbi.Contact__r.LastName, 
						                        email = cri.rbi.Contact__r.Email, alias = cri.rbi.Contact__r.LastName, username = cri.rbi.Contact__r.Email+ '_community', 
						                        communityNickname = cri.rbi.Contact__r.LastName + '_community');
                    cri.usr = contactuser;
                    selectedContacts.add(cri);
                }
            }
        }
        
        if (selectedContacts.size() > 0) {
            isBlockChange = true;
        } else {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, 'Select atleast one contact.');
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to Select & continue
     */ 
    public void back() {
        isBlockChange = false;
    }
    
    /**
     * Method to invite
     */  
    public PageReference inviteContactRBIs() {
        Savepoint sp = Database.setSavepoint(); 
                
        try {
        	
        	if (checkPermissions()) {
	            List<User> users = new List<User>();
	            List<Database.DMLOptions> dloList = new List<Database.DMLOptions>();
	                        
	            for (ContactRBIToInvite cri : selectedContacts) {
	            	
	                if (cri.usr != null) {
	                    cri.usr.profileid = selectedProfile;                    
	                    cri.usr.emailencodingkey = user.emailencodingkey;
	                    cri.usr.languagelocalekey = user.languagelocalekey; 
	                    cri.usr.localesidkey = user.localesidkey; 
	                    cri.usr.timezonesidkey = user.timezonesidkey;
	                    users.add(cri.usr); 
	                    //Trigger Email to user
	                    Database.DMLOptions dlo = new Database.DMLOptions();
	                    dlo.EmailHeader.triggerUserEmail= true;
	                    dloList.add(dlo);
	                }
	            }
	            
	            if (users.size() > 0) {
	                List<Database.saveresult> srList = Database.insert(users, dloList); 
	                Integer i = 1;
	                String errorMsg = '';
	                
	                for (Database.SaveResult sr : srList) {            
	                    String error = '';
	                    
	                    if (!sr.isSuccess()) {
	                    	
	                        for (Database.Error e : sr.getErrors()){
	                            error = 'Row '+ i + ' : '+ e.getMessage()+'\n\n'; 
	                        }
	                        errorMsg += error;
	                        i++;
	                    }
	                }
	                
	                if (errorMsg != '') { 
	                    throw new CustomException(errorMsg.replace('<br>','\n')); 
	                }
	            }
	            return new PageReference(Page.ManageRefedgeLicense.getUrl()+'?isCommunity=true');
        	} else {
        		return null;
        	}
        } catch(Exception e) {
            Database.rollback(sp);
            Apexpages.addMessages(e);
            return null;
        }
    }
    
    /**
     * Wrapper Class for Contact RBI To Invite
     */ 
    public class ContactRBIToInvite {
       /**
     	* Properties and variables
     	*/
        public Boolean isSelected { get; set; }
        public User usr { get; set; }
        public Reference_Basic_Information__c rbi { get; set; }
        public ContactRBIToInvite(Boolean isSelected, Reference_Basic_Information__c rbi) {
            this.isSelected = isSelected;
            this.rbi = rbi;
        }
    }    
    
    /**
     * Method to check Permissions
     */
     public static Boolean checkPermissions() { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	Boolean isUpsertPermission = false; 
    	       		
        fieldMap.put('User', new Set<String> { 'profileid','emailencodingkey','languagelocalekey','localesidkey','timezonesidkey' });  
        										
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);           
        return isUpsertPermission; 
    }
}