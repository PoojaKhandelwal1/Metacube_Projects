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
 * VF Page: AddContactLookup 
 * Description : Class used to open New Associated Contact page  
 * Last modified date: Rajesh @Feb 27 2017 
 * Modified by: Rajesh for ticket #752
 */  
public with sharing class AddContactLookupController extends RefEdgeEditionFeatures { 
    
    /**
     * Properties and variables
     */
    public string searchText { get; set; }
    public List<Contact> contactList { get; set; }
    public Boolean isMultiSelect { get; set; }
    //REF 2213
    public Boolean showAllContacts { get; set; }
	// re #619
 	public List<ContactWrapper> contactListWrapper { get; set; }
    private Set<String> conIdSet;
    private Set<String> existingConIdSet; 
    
    /**
     * Constructor
     */
    public AddContactLookupController() {
        searchText = '';
        string contactName = ApexPages.currentPage().getParameters().get('strText');
		// re #619
        contactListWrapper = new List<ContactWrapper>();
        contactList = new List<Contact>();
        conIdSet = new Set<String>();
        existingConIdSet = new Set<String>();
        showAllContacts = false;

        if (ApexPages.currentPage().getParameters().get('all') != null) {
            showAllContacts = ApexPages.currentPage().getParameters().get('all') == 'true';  
        }

        if (ApexPages.currentPage().getParameters().get('multiSelect') != null && ApexPages.currentPage().getParameters().get('multiSelect') == 'true') {
            isMultiSelect = true;
            List<String> conId;
            
         	if (ApexPages.currentPage().getParameters().get('selectedContacts') != null) {
                conId = ApexPages.currentPage().getParameters().get('selectedContacts').split(',');   
                conIdSet = new Set<String>(conId);
            }

            if (ApexPages.currentPage().getParameters().get('existingContacts') != null) {
                conId = ApexPages.currentPage().getParameters().get('existingContacts').split(',');  
                existingConIdSet = new Set<String>(conId);
            }  
        } else {
        	isMultiSelect = false;        	
        }
        searchText = contactName;
    	search();
    }
    
    /**
     * Method to Search Contacts
     */
    public Pagereference search() {
        Set<String> setContactIds = new Set<String>();
        String soqlQuery;
        ContactWrapper CW;
        if (showAllContacts) {
            if (searchText != null && searchText.trim().length() > 0) {
                String searchValue = searchText.replace('*', '%') + '%';
                searchValue = String.escapeSingleQuotes(searchValue);
                searchValue = '\'' + searchValue + '\'';
                soqlQuery = 'SELECT Name, Account.Site, Account.Name,AccountId FROM Contact WHERE AccountId != null AND Name LIKE ' + searchValue
            				+ ' ORDER BY Name LIMIT 201';
            } else {
                soqlQuery = 'SELECT Name, Account.Site, Account.Name,AccountId FROM Contact WHERE AccountId != null'
            				+ ' ORDER BY Name LIMIT 201';
            }
            if (!isMultiSelect) {
                contactList = WithoutSharingHelperController.getContactUsingDynamicSOQL(soqlQuery);  
            } else if (conIdSet.size() > 0) {
                contactListWrapper.clear();
                        
                for (Contact con : WithoutSharingHelperController.getContactUsingDynamicSOQL(soqlQuery)) {
                    
                    if (conIdSet.contains(con.Id) || existingConIdSet.contains(con.Id)) {
                        
                        if (existingConIdSet.contains(con.Id)) {
                            CW = new ContactWrapper(con, true, true);
                        } else {
                            CW = new ContactWrapper(con, true, false);
                        }
                    } else {
                        CW = new ContactWrapper(con, false, false);
                    }
                    contactListWrapper.add(CW);    
                } 
            }
        } else {
            if (searchText != null && searchText.trim().length() > 0) {
                String searchValue = searchText.replace('*', '%') + '%';
                searchValue = String.escapeSingleQuotes(searchValue);
                searchValue = '\'' + searchValue + '\'';
                soqlQuery = 'SELECT Contact__c FROM Reference_Basic_Information__c '
                                    + 'WHERE Account__c != null AND Contact__c != null '
                                    + 'AND Contact__r.Name LIKE ' + searchValue
                                    + ' AND Is_Referenceable__c = true '
                                    + 'AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE + '\' '
                                    + 'AND Referenceability_Status__c != \'\') '
                                    + 'ORDER BY Contact__r.Name';
            } else {
                soqlQuery = 'SELECT Contact__c FROM Reference_Basic_Information__c '
                                    + 'WHERE Account__c != null AND Contact__c != null '
                                    + 'AND Is_Referenceable__c = true '
                                    + 'AND (Referenceability_Status__c !=\'' + ConstantsController.INACTIVE + '\' '
                                    + 'AND Referenceability_Status__c != \'\') '
                                    + 'ORDER BY Contact__r.Name';
            }
            
            for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getRBI(soqlQuery)) {
                setContactIds.add(rbi.Contact__c);
            }
        

            // re #619- Check for multiselect 
            if (!isMultiSelect) {
                contactList = WithoutSharingHelperController.getContactRecordsforLookup(setContactIds, 201);  
            } else if (conIdSet.size() > 0) {
                contactListWrapper.clear();
                        
                for (Contact con : WithoutSharingHelperController.getContactRecordsforLookup(setContactIds,201)) {
                    
                    if (conIdSet.contains(con.Id) || existingConIdSet.contains(con.Id)) {
                        
                        if (existingConIdSet.contains(con.Id)) {
                            CW = new ContactWrapper(con, true, true);
                        } else {
                            CW = new ContactWrapper(con, true, false);
                        }
                    } else {
                        CW = new ContactWrapper(con, false, false);
                    }
                    contactListWrapper.add(CW);    
                } 
            }  
        } 
        return null;
    }
    
    /**
     * Wrapper Class
     */
    public class ContactWrapper {
        public Boolean isSelected { get; set; }
        public Contact contact { get; set; }
        public Boolean isExistingContact { get; set; }
        
        public ContactWrapper(Contact con, boolean isSelected, boolean isExistingContact) {
            this.isSelected = isSelected;
            this.contact = con;
            this.isExistingContact = isExistingContact;
        }
    }
}