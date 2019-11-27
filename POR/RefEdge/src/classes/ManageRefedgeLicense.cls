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
 * Page : ManageRefedgeLicense
 * Description : This class called from ManageRefedgeLicense page to provide the same behavior as in native license management 
 * this class is for our custom license management, you can assign the full license or community license from this class
 * Modified by: Rajesh @ 21 feb 2017
 */
public with sharing class ManageRefedgeLicense extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Boolean isMainForm { get; set; }
    public String pbsTitle { get; set; }
    public String pbTitle { get; set; }
    public String refedgeLicenseType { get; set; }
    public Integer refedgeAllowdLicense { get; set; }
    public Integer communityAllowdLicense { get; set; }
    public Integer refedgeUsedLicense { get; set; }
    public Integer communityUsedLicense { get; set; }
    public List<User> users { get; set; }
    public List<UserWrapper> addRemoveUser { get; set; }
    public String selectedUserId { get; set; }
    public List<String> alphaList { get; set; }
    public String alphaFilter { get; set; }
    public String sortFieldSave;
    public Integer pagecounter { get; set; }
    public Integer lastPage { get; set; }
    public Boolean isNext { get; set; }
    public Boolean isAdmin { get; set; }
    private Set<String> setUserIds = new Set<String>();
    private Map<Integer, List<UserWrapper>> mapUsers = new Map<Integer, List<UserWrapper>>();
    private Set<String> refedgeUserIds;
    //record limits
    public Integer recordlimits {
        get {
           
            if (recordlimits == null) {
                recordlimits = 5;
            }
            return recordlimits;
        }
        set;
    }

    //sortField
    public String sortField {
        get {
           
            if (sortField == null) {
                sortField = 'LastName';
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
    public Boolean isUpdateUsers { get; set; }
   
    /**
     * Constructor
     */
    public ManageRefedgeLicense() {
        isAdmin = false;
        isUpdateUsers = false;
        List<Profile> proList = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT :limits.getLimitQueryRows()];
        refedgeUserIds = new Set<String>();
        pbTitle = '';
        pbsTitle = system.Label.Licensed_Users;
        
        if (proList.size() > 0) {
            isAdmin = (proList[0].Name == 'System Administrator' ? true : false);
        }
            
        if (isAdmin && isProCom) {
            Boolean isCommunity = false;
            
            if (Apexpages.currentPage().getParameters().get('isCommunity') != null && Apexpages.currentPage().getParameters().get('isCommunity') == 'true') {
                isCommunity = true;
            }
            POR_App_Configuration__c cs = POR_App_Configuration__c.getOrgDefaults();
            refedgeAllowdLicense = 0;
            isUpdateUsers = !cs.Update_All_User_License__c;
            communityAllowdLicense = 0;
            
            if (cs.Edition_Key__c != null && cs.Edition_Key__c != '') {
                String numberOfLicense = RefEdgeDecodingClass.getLicenseNumber(cs.Edition_Key__c);
                String[] licenses = numberOfLicense.split('###');
                refedgeAllowdLicense = Integer.valueOf(licenses[0]);
                communityAllowdLicense = Integer.valueOf(licenses[1]);
            }
            alphaList = new List<String> {
                'A',
                'B',
                'C',
                'D',
                'E',
                'F',
                'G',
                'H',
                'I',
                'J',
                'K',
                'L',
                'M',
                'N',
                'O',
                'P',
                'Q',
                'R',
                'S',
                'T',
                'U',
                'V',
                'W',
                'X',
                'Y',
                'Z',
                'Other',
                'All'
            };
            sortFieldSave = sortField;
            
            for (User userObj : [SELECT Name, Id FROM User WHERE Id IN (SELECT UserId FROM UserPackageLicense WHERE(PackageLicense.NamespacePrefix = 'refedge'))]) {
                refedgeUserIds.add(userObj.Id);
            }
            reset();
            
            if (isCommunity) {
                pbTitle = system.Label.Add_Community_Users;
                pbsTitle = system.Label.Available_Users;
                refedgeLicenseType = 'Community License';
                addRemoveLicense();
            }
        }
    }

    /**
     * Method to call Batch_AssignRefEdgeLicenseToUsers batch class to assign full license to all existing refedge users
     */
    public void updateUsers() {
        Batch_AssignRefEdgeLicenseToUsers newBatchAR = new Batch_AssignRefEdgeLicenseToUsers();
        DataBase.executeBatch(newBatchAR);
        isUpdateUsers = false;
    }

    /**
     * Method to reset all values
     */
    public void reset() {
        isMainForm = true;
        alphaFilter = 'All';
        refedgeLicenseType = '';
        refedgeUsedLicense = [SELECT count() FROM User WHERE Refedge_License_Type__c = 'Full License'];
        communityUsedLicense = [SELECT count() FROM User WHERE Refedge_License_Type__c = 'Community License'];
        alphabetSorting();
    }

    /**
     * Method to provide Alphabet sorting
     */
    public void alphabetSorting() {
        pagecounter = 1;
        lastPage = 1;
        setUserIds = new Set<String>();
        mapUsers = new Map<Integer, List<UserWrapper>>();
        buildQuery();
    }

    /**
     * Method to provide sortToggle
     */
    public void sortToggle() {
        sortDirection = sortDirection.equals('asc') ? 'desc' : 'asc';
        
        if (sortFieldSave != sortField) {
            sortDirection = 'asc';
            alphaFilter = 'All';
            sortFieldSave = sortField;
        }
        alphabetSorting();
    }

    /**
     * Generic Method 
     */
    public void addRemoveLicense() {
        isMainForm = false;
        alphaFilter = 'All';
        alphabetSorting();
    }  
    
    /**
     * Method to build query
     */
    public void buildQuery() {
        //SOQL query
        String queryUser =
            'SELECT Id, Name, FirstName, LastName, UserRoleId, User.UserRole.Name, isActive, ProfileId, Profile.Name, Refedge_License_Type__c FROM User WHERE ID NOT IN :setUserIds ';
        String queryWhereClause = '';

        //CHECK License
        if (refedgeLicenseType == 'Full License') {
            queryWhereClause += buildWhereClause(queryWhereClause, 'Refedge_License_Type__c = null AND UserType = \'Standard\' AND IsActive = true');
        } else if (refedgeLicenseType == 'Community License') {
            queryWhereClause += buildWhereClause(queryWhereClause,
                'Refedge_License_Type__c = null AND Profile.UserLicense.Name = \'Customer Community\' AND Profile.UserType = \'CspLitePortal\' AND ContactId != null AND IsActive = true');
        } else if (refedgeLicenseType == '') {
            queryWhereClause += buildWhereClause(queryWhereClause, 'Refedge_License_Type__c != null ');
        }

        //sorting, alphabet 
        if (alphaFilter == null || alphaFilter.trim().length() == 0) {
            alphaFilter = 'All';
        } else if (alphaFilter == 'Other') {
            queryWhereClause += buildWhereClause(queryWhereClause, '(' + String.escapeSingleQuotes(SortField) + ' < \'A\' OR ' + String.escapeSingleQuotes(
                SortField) + ' > \'Z\') AND (NOT ' + String.escapeSingleQuotes(SortField) + ' LIKE \'Z%\') ');
        } else if (alphaFilter != 'All') {
            queryWhereClause += buildWhereClause(queryWhereClause, '(' + String.escapeSingleQuotes(SortField) + ' LIKE \'' + String.escapeSingleQuotes(
                alphaFilter) + '%\')');
        }
        queryUser += queryWhereClause + ' ORDER BY ' + String.escapeSingleQuotes(SortField) + ' ' + String.escapeSingleQuotes(SortDirection);
        //Pagination
        addRemoveUser = new List<UserWrapper>();
        
        if (mapUsers.containsKey(pagecounter)) {
            isNext = true;
            addRemoveUser.addAll(mapUsers.get(pagecounter));

            if (pagecounter == lastPage) {
                isNext = false;
            }
        } else {
            Integer extraRecordLimits = recordlimits + 1;
            isNext = false;

            for (User user : Database.query(queryUser + ' LIMIT :extraRecordLimits')) {
            	
                if (addRemoveUser.size() < recordlimits) {
                    setUserIds.add(user.Id);
                    addRemoveUser.add(new UserWrapper(false, user));
                } else {
                    isNext = true;
                }
            }

            if (!isNext) {
                lastPage = pagecounter;
            }
            mapUsers.put(pagecounter, addRemoveUser);
        }
    }

    /**
     * Method to next
     */
    public void next() {
        pagecounter++;
        buildQuery();
    }

    /**
     * Method to previous
     */
    public void previous() {
        pagecounter--;
        buildQuery();
    }

    /**
     * Method to build query where
     */
    public String buildWhereClause(String queryWhere, String cond) {
        return queryWhere + ' AND ' + cond;
    }

    /**
     * Method to remove single users LICENSE
     */
    public void removeSingleUserLicense() {
        List<User> users = [SELECT Refedge_License_Type__c FROM User WHERE Id = :selectedUserId];
        
        if (users.size() > 0) {
            users.get(0).Refedge_License_Type__c = '';
            //update users;
            WithoutSharingHelperController.updateUserLicense(users); 
        }
        reset();
    }

    /**
     * Method to SAVE
     */
    public void done() {
        Savepoint sp = Database.setSavepoint();
        try {
            List<User> users = new List<User>();
            
            for (UserWrapper uw : addRemoveUser) {
            	
                if (uw.isSelected) {
                    uw.user.Refedge_License_Type__c = refedgeLicenseType;
                    users.add(uw.user);
                }
            }

            if (users.size() > 0) {
            	WithoutSharingHelperController.updateUserLicense(users);
                //update users;
            }

            reset();
        } catch (Exception e) {
            Database.rollback(sp);
            Apexpages.addMessages(e);
        }
    }
    
	/**
     * User Wrapper Class
     */
    public class UserWrapper {
        public Boolean isSelected { get; set; }
        public User user { get; set; }
        
        public UserWrapper(Boolean isSelected, User user) {
            this.isSelected = isSelected;
            this.user = user;
        }
    }
}