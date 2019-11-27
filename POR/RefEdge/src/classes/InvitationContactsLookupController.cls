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
 * VF Page: Invitation_New.page, InvitationContactsLookup.page
 * Description: controller for selecting contacts for invitation on invitation page(classic only)
 * Last modified by: Gaurav Saini (13 June, 2017) for #732
 */
public with sharing class InvitationContactsLookupController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public string userId { get; set; }
    public string selectedEmailIds { get; set; }
    public string selectedConIds { get; set; }
    public string searchText { get; set; }
    public List<ContactWrapper> contactListWrapper { get; set; }
    private Map<String, Contact> selectedContactMap;
    private List<String> userIdSet;
    public Contact newContact { get; set; }
    public string newContactEmail;
    public Boolean isNewContact { get; set; }
    private List<Contact> listContacts;
    
    /**
     * Constructor
     */
    public InvitationContactsLookupController() {
        searchText = '';
        userId = '';
        selectedEmailIds = '';
        selectedConIds = '';
        isNewContact = false;
        newContactEmail = '';
        selectedContactMap = new Map<String, Contact>();
        contactListWrapper = new List<ContactWrapper>();
        listContacts = new List<Contact>();
        
        // if no search criteria present get all records else filter on the basis of search text
        if (ApexPages.currentPage().getParameters().get('strText') != null
        			|| ApexPages.currentPage().getParameters().get('strText') != '') {
            userId = ApexPages.currentPage().getParameters().get('strText');
        }
        
        if (userId.trim() != '') {
            userIdSet = userId.split(',');
            // changes for #732 - moved contacts query to with sahring (Gaurav Saini (21 Feb, 2017))
            listContacts = [SELECT Id, Name, Email FROM Contact WHERE Id IN :userIdSet ORDER BY Name LIMIT 201];
            getWrapperList();
        } else {
            searchContacts();
        }
    }
    
    /**
     * Method to search contacts
     */
    public Pagereference search() {
        searchContacts();
        isNewContact = false;
        return null;
    }
    
    /**
     * Method to set Email Ids
     */
    public Pagereference setEmailIds() {
        setAllSelectedContacts();
        
        if (selectedContactMap.size() > 0) {
        	
            for (string con : selectedContactMap.keyset()) {
            	
                if (selectedEmailIds == '') {
                    selectedEmailIds = selectedContactMap.get(con).Email;
                    selectedConIds = con;
                } else {
                    selectedEmailIds += ',' + selectedContactMap.get(con).Email;
                    selectedConIds += ',' + con;
                }
            }
        }
        return null;
    }
    
	/**
     * Method to set All selected contacts
     */
    private void setAllSelectedContacts() {
    	
        if (contactListWrapper.size() > 0) {
        	
            for (ContactWrapper con : contactListWrapper) {
            	
                if (con.isSelected) {
                    selectedContactMap.put(con.contact.Id, con.contact);
                } else {
                	
                    if (selectedContactMap.containsKey(con.contact.Id)) {
                        selectedContactMap.remove(con.contact.Id);
                    }
                }
            }
        }
    }
    
    /**
     * Method to search on the basis of search text
     */
    public void searchContacts() {
        listContacts.clear();
        String QueryString = '';
        
        if (searchText.trim().length() != 0) {
            String searchValue = '%' + searchText.replace('*', '%') + '%';
            searchValue = String.escapeSingleQuotes(searchValue);
            searchValue = '\'' + searchValue + '\'';
            // Add the records to the list  
            QueryString = 'SELECT Id, Name, Email FROM Contact WHERE Email != null AND (Name LIKE ' + searchValue
            				+ ' OR Name LIKE ' + searchValue
            				+ ' OR Email LIKE ' + searchValue
            				+ ') ORDER BY Name LIMIT 201';

        } else {
            QueryString = 'SELECT Id, Name, Email FROM Contact WHERE Email != null AND Email != \'\' '
            				+ 'ORDER BY Name LIMIT 201';
        }
        
        // changes for #732 - moved contacts query to with sahring (Gaurav Saini (21 Feb, 2017))
        for (Contact con : Database.query(QueryString)) {
            listContacts.add(con);
        }
        getWrapperList();
    }
    
	/**
     * Method to get contact wrapper list
     */
    public void getWrapperList() {
        setAllSelectedContacts();
        contactListWrapper.clear();
        ContactWrapper CW;
        
        for (Contact con : listContacts) {
        	
            if (userId.trim() != '') {
            	
                if (con.Email != null && userId.trim() != '' && userId.contains(con.Id)) {
                    CW = new ContactWrapper(con, true);
                } else {
                    CW = new ContactWrapper(con, false);
                }
            } else {
            	
                if (con.Email != null && newContactEmail.trim() != '' && newContactEmail.contains(con.Email)) {
                    CW = new ContactWrapper(con, true);
                } else if (selectedContactMap.containsKey(con.Id)) {
                    CW = new ContactWrapper(con, true);
                } else {
                    CW = new ContactWrapper(con, false);
                }
            }
            contactListWrapper.add(CW);
        }
        userId = '';
    }
    
    /**
     * Method to save new contact
     */
    public void saveNewContact() {
        
        try {
            insert newContact;
            
            if (newContactEmail == '') {
                newContactEmail = newContact.Email;
            } else {
                newContactEmail += ',' + newContact.Email;
            }
            selectedContactMap.put(newContact.Id, newContact);
            
            if (newContact.FirstName != null && newContact.FirstName != '') {
                searchText = newContact.FirstName + ' ' + newContact.LastName;
            } else {
                searchText = newContact.LastName;
            }
            searchContacts();
            isNewContact = false;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }
    
	/**
     * Method to cancel the new contact
     */
    public void cancelNewContact() {
        isNewContact = false;
    }
    
    /**
     * Method to create new contact
     */
    public void createNewContact() {
        newContact = new Contact();
        isNewContact = true;
    }
    
    /**
     * Wrapper Class
     */
    public class ContactWrapper {
        public Boolean isSelected { get; set; }
        public Contact contact { get; set; }
        
        public ContactWrapper(Contact con, boolean isSelected) {
            this.isSelected = isSelected;
            this.contact = con;
        }
    }
}