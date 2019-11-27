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
 * Page: ReferenceWorkSpace
 * Description: Class used to display all requests and provide filters on requests.
 * Modified by: Rekha @Feb 6 2017
 */
public with sharing class ReferenceWorkSpaceController extends RefEdgeEditionFeatures {

    /**
     * Properties and variables
     */
    public Custom_Settings__c cs { get; set; }
    public RequestWithOppController requestWithOppCon { get; set; }
    public RequestWithoutOppController requestWithoutOppCon { get; set; }
    public NominationWorkspaceController nominationCon { get; set; }
    public String selectedProcess { get; set; }
    public String selectedRequest { get; set; }
    public Boolean isError { get; set; }
    public Boolean isEdit { get; set; }
    public Boolean isDisplay { get; set; }
    public String selectedMethodRequest { get; set; }
    public String selectedMethodNomination { get; set; }
    public String selectedFilter { get; set; }
    public List<SelectOption> filters { get; set; }
    public String activeTab { get; set; }
	public String nameSpace { get; set; }
    public Boolean isSLDS { get; set; }
    private Set<String> status = new Set<String> {
        ConstantsController.COMPLETED, ConstantsController.NO_LONGER_NEEDED, ConstantsController.ACCOUNT_SPECIFIED, ConstantsController.UNAVAILABLE, ConstantsController.NO_RESPONSE
    };
	
    public Integer allOpenReq { get; set; }
    public Integer criticalReq { get; set; }
    public Integer bwtCriticalCautionReq { get; set; }
    public Integer cautionReq { get; set; }
    public Integer onHoldReq { get; set; }
    public Integer allOpenNom { get; set; }
    public Integer criticalNom { get; set; }
    public Integer cautionNom { get; set; }
    public Integer onHoldNom { get; set; }
    public PageReference redirect() {
        if (isSLDS){
            PageReference pageRef = Page.ReferenceWorkSpaceSLDS;
            return pageRef;
        }
        else{
            return null;
        }
    }

    /**
     * Constructor
     */
    public ReferenceWorkSpaceController() {

        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
       
        if (!isSLDS) {
            isDisplay = true;
            isEdit = false;
            filters = new List<SelectOption>();
            
            if (ApexPages.currentPage().getParameters().get('activeTab') != null) {
                activeTab = ApexPages.currentPage().getParameters().get('activeTab');
            } else {
                activeTab = 'specTab';
            }
            
            cs = UtilityController.getCustomSettings();
            nameSpace = UtilityController.appNamespace();
            selectedFilter = 'All';
            
            if (cs.Caution_deadline_window__c == null || cs.Critical_Deadline_window__c == null || cs.Nomination_disposition_window__c == null) {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.SET_CAUTION_CRITICAL_DEADLINE_WINDOW));
                isError = true;
            } else {
                selectedMethodRequest = 'requestAll';
                selectedMethodNomination = 'nominationAll';
                filters.add(new SelectOption('All', 'All Open Requests & Projects'));
                filters.add(new SelectOption('MyRequests', 'My Requests & Projects'));
                filters.add(new SelectOption('TodayRequests', 'Today\'s Requests'));
                nominationCon = new NominationWorkspaceController();
                reset();
            }
        }
    }

    /**
     * Method to filter all requests which has deadline less than critical date
     */
    public void filterRed() {
        requestWithOppCon.filterRed();
        requestWithoutOppCon.filterRed();
    }

    /**
     * Method to filter all requests which has deadline between caution date and critical date
     */
    public void filterOrange() {
        requestWithOppCon.filterOrange();
        requestWithoutOppCon.filterOrange();
    }

    /**
     * Method to filter all requests which has deadline greater than caution date
     */
    public void filterGreen() {
        requestWithOppCon.filterGreen();
        requestWithoutOppCon.filterGreen();
    }

    /**
     * Method to filter all open requests
     */
    public void filterAllOpen() {
        requestWithOppCon.filterAllOpen();
        requestWithoutOppCon.filterAllOpen();
    }

    /**
     * Method to filter all on hold requests
     */
    public void filterOnHold() {
        requestWithOppCon.filterOnHold();
        requestWithoutOppCon.filterOnHold();
    }

    /**
     * Method to get all process name
     */
    public List<SelectOption> getProcess() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ConstantsController.ALL, ConstantsController.ALL));
        options.add(new SelectOption(ConstantsController.REP2REP, ConstantsController.REP2REP));
        options.add(new SelectOption(ConstantsController.MANAGED, ConstantsController.MANAGED));
        return options;
    }

    /**
     * Method to change the process of list view
     */
    public Pagereference changeProcess() {
        reset();
        requestWithOppCon.selectedFilter = selectedFilter;
    	requestWithoutOppCon.selectedFilter = selectedFilter;
        changeTab();
        requestWithOppCon.reqProcess = selectedProcess;
        requestWithoutOppCon.reqProcess = selectedProcess;
        requestWithOppCon.changeProcess();
        requestWithoutOppCon.changeProcess();
        getCountRequest();
        return null;
    }

    /**
     * Method to call Show More Link
     */
    public pagereference callShowMoreLink() {
        system.debug('******Enter********');
        return null;
    }
    
	/**
     * Method to reset
     */
    private void reset() {
        cs = UtilityController.getCustomSettings();
        requestWithOppCon = new RequestWithOppController();
        requestWithoutOppCon = new RequestWithoutOppController();
        isError = false;
        selectedRequest = '';
    }
    
    /**
     * Method to create New Project
     */
    public pagereference createNewProject() {
        return page.NewProject;
    }
    
    /**
     * Method to change the process of list view
     */
    public Pagereference changeTab() {
    	
        if (selectedMethodRequest == 'requestAll') {
            filterAllOpen();
        } else if (selectedMethodRequest == 'requestRed') {
            filterRed();
        } else if (selectedMethodRequest == 'requestGreen') {
            filterGreen();
        } else if (selectedMethodRequest == 'requestOrange') {
            filterOrange();
        } else if (selectedMethodRequest == 'requestHold') {
            filterOnHold();
        }
        
        if (selectedMethodNomination == 'nominationAll') {
            nominationCon.filterAllOpen();
        } else if (selectedMethodNomination == 'nominationHold') {
            nominationCon.filterOnHold();
        } else if (selectedMethodNomination == 'nominationRed') {
            nominationCon.filterRed();
        } else if (selectedMethodNomination == 'nominationGreen') {
            nominationCon.filterGreen();
        }
        return null;
    }
    /**
     * to get count of all requests
     */
    public void getCountRequest() {
        List<Reference_Request__c> requestListAll = new List<Reference_Request__c>();
        List<Reference_Request__c> requestListRed = new List<Reference_Request__c>();
        List<Reference_Request__c> requestListOrange = new List<Reference_Request__c>();
        List<Reference_Request__c> requestListGreen = new List<Reference_Request__c>();
        List<Reference_Request__c> requestListHold = new List<Reference_Request__c>();
        List<Id> requestIds = new List<Id>();
        String onHold = ConstantsController.ONHOLD ;
        String userInfoId = Userinfo.getUserId();
        Date todayDate = system.today();
        Date criticalDate = todayDate.addDays(Integer.valueOf(cs.Critical_Deadline_window__c));
        Date cautionDate = todayDate.addDays(Integer.valueOf(cs.Caution_deadline_window__c));
        Map<String,String> arWhere = new Map<String,String>{'All' => ' AND Deadline__c != null ', 'Hold' => 'AND Deadline__c != null AND Account_Request_Status__c = :onHold ', 'Red' => 'AND Deadline__c != null AND Deadline__c < :criticalDate ', 'Orange' => ' AND Deadline__c != null AND Deadline__c >= :criticalDate AND Deadline__c <= :cautionDate ', 'Green' => ' AND Deadline__c != null AND Deadline__c > :cautionDate '};
        Map<String,String> urWhere = new Map<String,String>{'All' => ' AND Deadline__c != null ', 'Hold' => 'AND Deadline__c != null AND Unspecified_Request_Status__c = :onHold ', 'Red' => 'AND Deadline__c != null AND Deadline__c < :criticalDate ', 'Orange' => ' AND Deadline__c != null AND Deadline__c >= :criticalDate AND Deadline__c <= :cautionDate ', 'Green' => ' AND Deadline__c != null AND Deadline__c > :cautionDate '};
        Map<String,String> query = new Map<String,String>{'All' => '', 'Hold' => '', 'Red' => '', 'Orange' => '', 'Green' => ''};
        
        if (selectedFilter == 'MyRequests') {
            
            for (String color : urWhere.keySet()) {
                urWhere.put(color, urWhere.get(color) + 'AND Project_Owner__c = :userInfoId ');
                arWhere.put(color, arWhere.get(color) + 'AND Project_Owner__c = :userInfoId ');
            }
        }

        if (selectedFilter == 'TodayRequests') {
            
            for (String color : urWhere.keySet()) {
                urWhere.put(color, urWhere.get(color) + ' AND CreatedDate >= TODAY ');
                arWhere.put(color, arWhere.get(color) + ' AND CreatedDate >= TODAY ');
            }
        }

        if (selectedProcess == ConstantsController.MANAGED) {
            
            for (String color : arWhere.keySet()) {
                arWhere.put(color, arWhere.get(color) + ' AND Managed_Request__c = true ');
            }
        }

        if (selectedProcess == ConstantsController.REP2REP) {
            urWhere = null;
            
            for (String color : arWhere.keySet()) {
                arWhere.put(color, arWhere.get(color) + ' AND Managed_Request__c = false ');
            }
        }

        for (String color : query.keySet()) {
            String queryTemp = 'SELECT Id,';
            
            if (urWhere != null ) {
                queryTemp += '(SELECT Id FROM Unspecified_Requests__r'
                                                + ' WHERE Specified_Account__c = null '
                                                + urWhere.get(color)
                                                + ' AND Unspecified_Request_Status__c NOT IN :status),';
            }                            
            queryTemp += ' (SELECT Id FROM Reference_Request_Accounts__r'
                                                + ' WHERE Approval_Status__c = null '
                                                + arWhere.get(color)
                                                + ' AND Account_Request_Status__c NOT IN :status' 
                                                + ' AND (NOT Account_Request_Status__c LIKE \'Give Up%\')' 
                                                + ' AND Reference_Use__c = false)'
                                                + ' FROM Reference_Request__c'
                                                + ' WHERE Reference_Use__c = false'
                                                + ' AND Reference_Request_Status__c NOT IN :status'
                                                + ' AND (NOT Reference_Request_Status__c LIKE \'Give Up%\')';
            query.put(color,queryTemp);
        }   
        requestListAll = Database.query(query.get('All')) ;       
        requestListHold = Database.query(query.get('Hold')) ; 
        requestListRed = Database.query(query.get('Red')) ; 
        requestListOrange = Database.query(query.get('Orange')) ; 
        requestListGreen = Database.query(query.get('Green')) ;                                
        
        Integer listSize = 0;
        
        for (Reference_Request__c req : requestListAll) {
                
            if (req.Reference_Request_Accounts__r.size() > 0 || req.Unspecified_Requests__r.size() > 0) {
                listSize += req.Reference_Request_Accounts__r.size() + req.Unspecified_Requests__r.size();
            }
        }
        allOpenReq = listSize;
        listSize = 0;

        for (Reference_Request__c req : requestListRed) {
                
            if (req.Reference_Request_Accounts__r.size() > 0 || req.Unspecified_Requests__r.size() > 0) {
                listSize += req.Reference_Request_Accounts__r.size() + req.Unspecified_Requests__r.size();
            }
        }
        criticalReq = listSize;
        listSize = 0;
        
        for (Reference_Request__c req : requestListOrange) {
                
            if (req.Reference_Request_Accounts__r.size() > 0 || req.Unspecified_Requests__r.size() > 0) {
                listSize += req.Reference_Request_Accounts__r.size() + req.Unspecified_Requests__r.size();
            }
        }
        bwtCriticalCautionReq = listSize;
        listSize = 0;
        
        for (Reference_Request__c req : requestListGreen) {
                
            if (req.Reference_Request_Accounts__r.size() > 0 || req.Unspecified_Requests__r.size() > 0) {
                listSize += req.Reference_Request_Accounts__r.size() + req.Unspecified_Requests__r.size();
            }
        }
        cautionReq = listSize;
        listSize = 0;
        
        for (Reference_Request__c req : requestListHold) {
                
            if (req.Reference_Request_Accounts__r.size() > 0 || req.Unspecified_Requests__r.size() > 0) {
                listSize += req.Reference_Request_Accounts__r.size() + req.Unspecified_Requests__r.size();
            }
        }
        onHoldReq = listSize;
    }

    /**
     * to get count of all requests
     */
    public void getCountNomi() {
        
        String onHold = ConstantsController.ONHOLD ;
        String userInfoId = Userinfo.getUserId();
        Date todayDate = system.today();
        String completed = ConstantsController.COMPLETED;
        Date criticalDate = todayDate.addDays(-integer.valueOf(cs.Nomination_disposition_window__c));
        Map<String,String> query = new Map<String,String>();
        Map<String,String> whereNom = new Map<String,String>{'All' => ' AND Status__c != :completed ', 'Hold' => ' AND Status__c = :onHold ', 'Red' => ' AND CreatedDate < :criticalDate AND Status__c != :completed AND Status__c != :onHold ', 'Green' => ' AND CreatedDate >= : criticalDate AND Status__c != :completed AND Status__c != :onHold '};
        
        if (selectedFilter == 'MyRequests') {
            
            for (String color : whereNom.keySet()) {
                whereNom.put(color, whereNom.get(color) + ' AND CreatedById = :userInfoId ');
            }
        }

        if (selectedFilter == 'TodayRequests') {
            
            for (String color : whereNom.keySet()) {
                whereNom.put(color, whereNom.get(color) + ' AND CreatedDate >= TODAY ');
            }
        }

        for (String color : whereNom.keySet()) {
            String queryTemp = 'SELECT Count() FROM Nomination__c'
                                                + ' WHERE Account__c != null '
                                                + whereNom.get(color);
            query.put(color,queryTemp);
        }   
        allOpenNom = Database.countQuery(query.get('All')) ; 
        onHoldNom = Database.countQuery(query.get('Hold')) ; 
        criticalNom = Database.countQuery(query.get('Red')) ; 
        cautionNom = Database.countQuery(query.get('Green')) ;   
    }
    
    /**
     * Method to search by filters
     */
    public pagereference searchByFilter() {
    	requestWithOppCon.selectedFilter = selectedFilter;
    	requestWithoutOppCon.selectedFilter = selectedFilter;
    	nominationCon.selectedFilter = selectedFilter;
    	changeTab();
        getCountRequest();
        getCountNomi();
        return null;
    }
    
    /**
     * Method to set filters
     */
    public pagereference setFilter(){
		List<User_Mapping__c> userMappings = UtilityController.getUserMappings('Workspace');
		
		if (userMappings != null && userMappings.size() > 0 && userMappings[0].Default_Value__c != null && userMappings[0].Default_Value__c != '') {
        	selectedFilter = userMappings[0].Default_Value__c;
    	} else {
        	selectedFilter = 'All';
    	}
		requestWithOppCon.selectedFilter = selectedFilter;
    	requestWithoutOppCon.selectedFilter = selectedFilter;
    	nominationCon.selectedFilter = selectedFilter;
        changeTab();
    	checkPermissions();
        getCountRequest();
        getCountNomi();
        return null;
	}
	
    /**
     * Method to save default filter
     */
    public pagereference saveAsDefaultView() {
    	
    	if (checkPermissions()) {
	    	List<User_Mapping__c> userMappings = UtilityController.getUserMappings('Workspace');
	    	
			if (userMappings != null && userMappings.size() > 0) {
	        	userMappings[0].Default_Value__c = selectedFilter;
			} else {
	        	userMappings = new List<User_Mapping__c>();
	        	userMappings.add(new User_Mapping__c(Default_Value__c = selectedFilter, User__c = Userinfo.getUserId(), Process__c = 'Workspace'));
	    	}
	    	upsert userMappings;
	    	searchByFilter();
    	}
    	return null;
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	fieldMap.put(UtilityController.appNamespace() + 'User_Mapping__c', new Set<String> { 
    										UtilityController.appNamespace() + 'Process__c',
    										UtilityController.appNamespace() + 'Default_Value__c',
        									UtilityController.appNamespace() + 'User__c' });
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
    }
}