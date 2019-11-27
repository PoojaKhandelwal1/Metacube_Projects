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
 * Page: InvitationCoworkersLookup
 * Description: Class to show all Users on Invitation page when clicked on co-workers lookup
 * Modified by: Rekha @Feb 4 2017
 */
public with sharing class InvitationCoworkersLookupController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public String searchText { get; set; }
    public List<userWrapper> listUsers { get; set; }
    public String selectedUsersIds { get; set; }
    public String selectedUsersEmails { get; set; }
    private Map<Id, User> selectedUserMap;
    private Set<Id> communityUsers;
    private Set<String> selectedUserIdSet;
    
    /**
     * Constructor
     */
    public InvitationCoworkersLookupController() {
        selectedUserIdSet = new Set<String>();
        listUsers = new List<userWrapper>();
        selectedUsersIds = '';
        selectedUsersEmails = '';
        selectedUserMap = new Map<Id, User>();
        communityUsers = new Set<Id>();
       	communityUsers = WithoutSharingHelperController.getCommunityUsersForCoWorkers();
       	
        // if no search criteria present get all records else filter on the basis of search text
        if (ApexPages.currentPage().getParameters().get('strText') == null || ApexPages.currentPage().getParameters().get('strText') == '') {
            getUsers();
        } else {
            searchText = ApexPages.currentPage().getParameters().get('strText');
            selectedUserIdSet.addAll(searchText.split(','));
            getUsers();
        }
    }

    /**
     * Method to search on the basis of search text
     */
    public void getUsers() {
        String QueryString;
        List<User> tempList;
        updateMap();
        
        if (searchText != null && searchText.trim() != '') {
            listUsers = new List<userWrapper>();
            
            if (selectedUserIdSet.size() == 0) {
            	
                if (SearchText.contains('Guest User')) {
                	SearchText = '';
                }
                QueryString = 'SELECT Id, Name, Email FROM User where IsActive = true AND ProfileId NOT IN :communityUsers AND ((Name != null  AND Name LIKE ' 
                				+ searchableText(SearchText) + ' ) OR Email LIKE ' + searchableText(SearchText) + ') order by Name limit 1000'; 
                tempList = WithoutSharingHelperController.getSearchedUsersForCoWorkers(QueryString,communityUsers);
            } else {
                tempList = WithoutSharingHelperController.getSelectedUsersForCoWorkers(selectedUserIdSet,communityUsers);
            }
            
            for (User u : tempList) {
            	
                if (!u.Name.contains('Guest User')) {
                	
	                if (selectedUserIdSet.contains(u.Id) || selectedUserMap.containsKey(u.Id)) {
	                    listUsers.add(new userWrapper(u, true));
	                } else {
	                    listUsers.add(new userWrapper(u, false));
	                }
                }
            }

        } else {
            listUsers = new List<userWrapper>();
            
            for (User u : WithoutSharingHelperController.getAllUsersForCoWorkers(communityUsers)) {
            	
                if (!u.Name.contains('Guest User')) {
                	
	                if (selectedUserMap.containsKey(u.Id)) {
	                    listUsers.add(new userWrapper(u, true));
	                } else {
	                    listUsers.add(new userWrapper(u, false));
	                }
                }
            }
        }
        selectedUserIdSet = new Set<String>();
        searchText = null;
    }
    
    /**
     * Method to search users
     */
    public Pagereference search() {
        return null;
    }
    
    /**
     * Method to get Searchble Text
     */
    public String searchableText(String textValue) {
        String searchValue = '%' + textValue.replace('*', '%') + '%';
        searchValue = String.escapeSingleQuotes(searchValue);
        searchValue = '\'' + searchValue + '\'';
        return searchValue;
    }
    
    /**
     * Method to update user map
     */
    private void updateMap() {
    	
        if (listUsers.size() > 0) {
        	
            for (userWrapper uw : listUsers) {
            	
                if (uw.isSelected) {
                    selectedUserMap.put(uw.u.Id, uw.u);
                } else {
                	
                    if (selectedUserMap.containsKey(uw.u.Id)) {
                        selectedUserMap.remove(uw.u.Id);
                    }
                }
            }
        }
    }
    /**
     * Method to save user ids
     */
    public void save() {
        updateMap();
        
        for (User u : selectedUserMap.values()) {
        	
            if (selectedUsersEmails == '') {
                selectedUsersEmails = u.Email;
            } else {
                selectedUsersEmails = selectedUsersEmails + ',' + u.Email;
            }
            
            if (selectedUsersIds == '') {
                selectedUsersIds = u.Id;
            } else {
                selectedUsersIds = selectedUsersIds + ',' + u.Id;
            }
        }
    }
    
    /**
     * Wrapper Class
     */
    public Class userWrapper {
        public User u { get; set; }
        public boolean isSelected { get; set; }
        public userWrapper(User obj, boolean selected) {
            u = obj;
            isSelected = selected;
        }
    }
}