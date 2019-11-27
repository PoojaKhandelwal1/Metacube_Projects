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
public with sharing class RequestWithoutOppController {
    // Properties
    public Custom_Settings__c cs;
    public transient List<Reference_Request__c> requestListWithoutOpp { get; set; }
    public String QueryString { get; set; }
    public String reqProcess { get; set; }
    public Integer number_of_page {
        get {
            
            if (number_of_page == null) {
                return 0;
            } else {
                return number_of_page;
            }
        }
        set;
    }
    public Integer totalPage {
        get {
            
            if (totalPage == null) {
                return 0;
            } else {
                return totalPage;
            }
        }
        set;
    }
    public Integer noOfRecords {
        get {
            
            if (noOfRecords == null) {
                return 0;
            } else {
                return noOfRecords;
            }
        }
        set;
    }
    public Integer size {
        get {
            
            if (size == null) {
                return 0;
            } else {
                return size;
            }
        }
        set;
    }
    public Boolean hasPrevious { get; set; }
    public Boolean hasNext { get; set; }
    public Integer allOpenReq { get; set; }
    public Integer criticalReq { get; set; }
    public Integer bwtCriticalCautionReq { get; set; }
    public Integer cautionReq { get; set; }
    public Integer onHoldReq { get; set; }
    public Integer pageNumber { get; set; }
    public String pageNumberString {
        get {
        	return String.valueOf(pageNumber);
    	}
        set;
    }
    public Integer currentPageNumber {
        get;
        set;
    }
    public String selectedFilter { get; set; }
    private Date todayDate;
    private Date criticalDate;
    private Date cautionDate;
    private Set<Id> accReqList;
    private Set<Id> unSpeReqList;
    private Set<Id> reqList;
    public Boolean isSettingPage { get; set; }
    private Set<String> status = new Set<String> { ConstantsController.COMPLETED, ConstantsController.NO_LONGER_NEEDED, ConstantsController.ACCOUNT_SPECIFIED, ConstantsController.UNAVAILABLE, ConstantsController.NO_RESPONSE};
    
    /**
     * Constructor
     */
    public RequestWithoutOppController() {
        cs = UtilityController.getCustomSettings();
        DateTime dT = System.now();
        todayDate = date.newinstance(dT.year(), dT.month(), dT.day());
        accReqList = new Set<Id>();
        unSpeReqList = new Set<Id>();
        reqList = new Set<Id>();
        size = 10;
        pageNumber = 0;
        currentPageNumber = 0;
        isSettingPage = false;
        selectedFilter = 'All';
        reqProcess = ConstantsController.ALL;
        criticalDate = todayDate.addDays(Integer.valueOf(cs.Critical_Deadline_window__c));
        cautionDate = todayDate.addDays(Integer.valueOf(cs.Caution_deadline_window__c));
        filterOnHold();
        filterRed();
        filterOrange();
        filterGreen();
        filterAllOpen();
    }
    
    /**
     * to filter all open requests
     */
    public void filterAllOpen() {
    	
        if (selectedFilter == 'All') {
            requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
        								(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c, 
                							Unspecified_Request_Status__c FROM Unspecified_Requests__r
                							WHERE Specified_Account__c = null
                							AND Deadline__c != null
                							AND Unspecified_Request_Status__c NOT IN :status
                							ORDER BY Deadline__c DESC),
            							(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            								Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
            								FROM Reference_Request_Accounts__r
            								WHERE Approval_Status__c = null
            								AND Deadline__c != null
            								AND Reference_Use__c = false
            								AND Account_Request_Status__c NOT IN :status
            								AND (NOT Account_Request_Status__c LIKE 'Give Up%')
            								AND Reference_Use__c = false
            								ORDER BY Deadline__c DESC, Approval_Status__c ASC)
        								FROM Reference_Request__c
        								WHERE Opportunity__c = null
        								AND Reference_Use__c = false
        								AND Reference_Request_Status__c NOT IN :status
        								AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
        								ORDER BY CreatedDate DESC];
        } else if (selectedFilter == 'MyRequests') {
            requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
            							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c,Project_Owner__c,
            								Unspecified_Request_Status__c FROM Unspecified_Requests__r
            								WHERE Specified_Account__c = null
            								AND Deadline__c != null
            								AND Project_Owner__c = :Userinfo.getUserId()
            								AND Unspecified_Request_Status__c NOT IN :status
            								ORDER BY Deadline__c DESC),
        								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
                							Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
                							FROM Reference_Request_Accounts__r
                							WHERE Approval_Status__c = null
                							AND Deadline__c != null
                							AND Reference_Use__c = false
                							AND Project_Owner__c = :Userinfo.getUserId()
                							AND Account_Request_Status__c NOT IN :status
                							AND (NOT Account_Request_Status__c LIKE 'Give Up%')
                							AND Reference_Use__c = false
                							ORDER BY Deadline__c DESC, Approval_Status__c ASC)
            							FROM Reference_Request__c
            							WHERE Opportunity__c = null
            							AND Reference_Use__c = false
            							AND Reference_Request_Status__c NOT IN :status
            							AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
            							ORDER BY CreatedDate DESC];
        } else if (selectedFilter == 'TodayRequests') {
            requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
            							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c,Project_Owner__c, 
                							Unspecified_Request_Status__c FROM Unspecified_Requests__r
                							WHERE Specified_Account__c = null
                							AND Deadline__c != null
                							AND Unspecified_Request_Status__c NOT IN :status
                							AND CreatedDate >= today
                							ORDER BY Deadline__c DESC),
            							(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c, 
                							Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
                							FROM Reference_Request_Accounts__r
                							WHERE Approval_Status__c = null
                							AND Deadline__c != null
                							AND Reference_Use__c = false
                							AND Account_Request_Status__c NOT IN :status
                							AND (NOT Account_Request_Status__c LIKE 'Give Up%')
                							AND CreatedDate >= TODAY
                							AND Reference_Use__c = false
                							ORDER BY Deadline__c DESC, Approval_Status__c ASC)
            							FROM Reference_Request__c
            							WHERE Opportunity__c = null
            							AND Reference_Use__c = false
            							AND Reference_Request_Status__c NOT IN :status
            							AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
            							ORDER BY CreatedDate DESC];
        }
        storeAllRecords();
        allOpenReq = changeProcess();
    }
    
    /**
     * to filter all on hold requests
     */
    public void filterOnHold() {
        
        if (selectedFilter == 'All') {
            requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
            							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c,Project_Owner__c,
                							Unspecified_Request_Status__c FROM Unspecified_Requests__r
                							WHERE Specified_Account__c = null
                							AND Unspecified_Request_Status__c = :ConstantsController.ONHOLD
                							AND Unspecified_Request_Status__c NOT IN :status
                							ORDER BY Deadline__c DESC),
            							(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
                							Reference_Owner__c, Project_Owner__c, Reference_Type_Needed__c, Account_Request_Status__c
                							FROM Reference_Request_Accounts__r
                							WHERE Approval_Status__c = null
                							AND Reference_Use__c = false
                							AND Account_Request_Status__c NOT IN :status
                							AND (NOT Account_Request_Status__c LIKE 'Give Up%')
                							AND Reference_Use__c = false
                							AND Account_Request_Status__c = :ConstantsController.ONHOLD
                							ORDER BY Deadline__c DESC)
            							FROM Reference_Request__c
            							WHERE Opportunity__c = null
            							AND Reference_Use__c = false
            							AND Reference_Request_Status__c
            							NOT IN :status
            							AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
            							ORDER BY CreatedDate DESC];
        } else if (selectedFilter == 'MyRequests') {
            requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
            							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
            								Unspecified_Request_Status__c FROM Unspecified_Requests__r
            								WHERE Specified_Account__c = null
            								AND Project_Owner__c = :Userinfo.getUserId()
            								AND Unspecified_Request_Status__c = :ConstantsController.ONHOLD
            								AND Unspecified_Request_Status__c NOT IN :status
            								ORDER BY Deadline__c DESC),
        								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
        									Reference_Owner__c, Project_Owner__c, Reference_Type_Needed__c, Account_Request_Status__c
        									FROM Reference_Request_Accounts__r
        									WHERE Approval_Status__c = null
        									AND Project_Owner__c = :Userinfo.getUserId()
        									AND Reference_Use__c = false
        									AND Account_Request_Status__c NOT IN :status
        									AND (NOT Account_Request_Status__c LIKE 'Give Up%')
        									AND Reference_Use__c = false
        									AND Account_Request_Status__c = :ConstantsController.ONHOLD
        									ORDER BY Deadline__c DESC)
    									FROM Reference_Request__c
    									WHERE Opportunity__c = null
    									AND Reference_Use__c = false
    									AND Reference_Request_Status__c NOT IN :status
    									AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
    									ORDER BY CreatedDate DESC];
        } else if (selectedFilter == 'TodayRequests') {
            requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
            							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
            								Unspecified_Request_Status__c FROM Unspecified_Requests__r
            								WHERE Specified_Account__c = null
            								AND Unspecified_Request_Status__c = :ConstantsController.ONHOLD
            								AND CreatedDate >= TODAY
            								AND Unspecified_Request_Status__c NOT IN :status
            								ORDER BY Deadline__c DESC),
        								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
        									Reference_Owner__c, Project_Owner__c, Reference_Type_Needed__c, Account_Request_Status__c
        									FROM Reference_Request_Accounts__r
        									WHERE Approval_Status__c = null
        									AND Reference_Use__c = false
        									AND Account_Request_Status__c NOT IN :status
        									AND (NOT Account_Request_Status__c LIKE 'Give Up%')
        									AND Reference_Use__c = false
        									AND CreatedDate >= TODAY
        									AND Account_Request_Status__c = :ConstantsController.ONHOLD
        									ORDER BY Deadline__c DESC)
    									FROM Reference_Request__c
    									WHERE Opportunity__c = null
    									AND Reference_Use__c = false
    									AND Reference_Request_Status__c NOT IN :status
    									AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
    									ORDER BY CreatedDate DESC];
        }
        storeAllRecords();
        onHoldReq = changeProcess();
    }
    
    /**
     * to filter all requests which has deadline less than critical date
     */
    public void filterRed() {
        
        if (criticalDate != null) {
            if (selectedFilter == 'All') {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Specified_Account__c = null
                								AND Deadline__c < :criticalDate
                								AND Unspecified_Request_Status__c NOT IN :status
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
            									FROM Reference_Request_Accounts__r
            									WHERE Approval_Status__c = null
            									AND Reference_Use__c = false
            									AND Account_Request_Status__c NOT IN :status
            									AND (NOT Account_Request_Status__c LIKE 'Give Up%')
            									AND Reference_Use__c = false
            									AND Deadline__c < :criticalDate
            									ORDER BY Deadline__c DESC)
        									FROM Reference_Request__c
        									WHERE Opportunity__c = null
        									AND Reference_Use__c = false
        									AND Reference_Request_Status__c NOT IN :status
        									AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
        									ORDER BY CreatedDate DESC];
            } else if (selectedFilter == 'MyRequests') {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Specified_Account__c = null
                								AND Deadline__c < :criticalDate
                								AND Project_Owner__c = :Userinfo.getUserId()
                								AND Unspecified_Request_Status__c NOT IN :status
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
            									FROM Reference_Request_Accounts__r
            									WHERE Approval_Status__c = null
            									AND Project_Owner__c = :Userinfo.getUserId()
            									AND Reference_Use__c = false
            									AND Account_Request_Status__c NOT IN :status
            									AND (NOT Account_Request_Status__c LIKE 'Give Up%')
            									AND Reference_Use__c = false
            									AND Deadline__c < :criticalDate
            									ORDER BY Deadline__c DESC)
        									FROM Reference_Request__c
    										WHERE Opportunity__c = null
    										AND Reference_Use__c = false
    										AND Reference_Request_Status__c NOT IN :status
    										AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
    										ORDER BY CreatedDate DESC];
            } else if (selectedFilter == 'TodayRequests') {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Specified_Account__c = null
                								AND Deadline__c < :criticalDate
                								AND CreatedDate >= TODAY
                								AND Unspecified_Request_Status__c NOT IN :status
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
            									FROM Reference_Request_Accounts__r
            									WHERE Approval_Status__c = null
            									AND CreatedDate >= TODAY
            									AND Reference_Use__c = false
            									AND Account_Request_Status__c NOT IN :status
            									AND (NOT Account_Request_Status__c LIKE 'Give Up%')
            									AND Reference_Use__c = false
            									AND Deadline__c < :criticalDate
            									ORDER BY Deadline__c DESC)
        									FROM Reference_Request__c
        									WHERE Opportunity__c = null
        									AND Reference_Use__c = false
        									AND Reference_Request_Status__c NOT IN :status
        									AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
        									ORDER BY CreatedDate DESC];
            }
            storeAllRecords();
            criticalReq = changeProcess();
        }
    }
    
    /**
     * to filter all requests which has deadline between caution date and critical date
     */
    public void filterOrange() {
        
        if (criticalDate != null && cautionDate != null) {
        	
            if (selectedFilter == 'All') {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Specified_Account__c = null
                								AND Deadline__c >= :criticalDate
                								AND Deadline__c <= :cautionDate
                								AND Unspecified_Request_Status__c NOT IN :status
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
            									FROM Reference_Request_Accounts__r
            									WHERE Approval_Status__c = null
            									AND Reference_Use__c = false
            									AND Account_Request_Status__c NOT IN :status
            									AND (NOT Account_Request_Status__c LIKE 'Give Up%')
            									AND Reference_Use__c = false
            									AND Deadline__c >= :criticalDate
            									AND Deadline__c <= :cautionDate
            									ORDER BY Deadline__c DESC)
        									FROM Reference_Request__c
        									WHERE Opportunity__c = null
        									AND Reference_Use__c = false
        									AND Reference_Request_Status__c NOT IN :status
        									AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
        									ORDER BY CreatedDate DESC];
            } else if (selectedFilter == 'MyRequests') {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Specified_Account__c = null
                								AND Deadline__c >= :criticalDate
                								AND Project_Owner__c = :Userinfo.getUserId()
                								AND Deadline__c <= :cautionDate
                								AND Unspecified_Request_Status__c NOT IN :status
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
            									FROM Reference_Request_Accounts__r
            									WHERE Approval_Status__c = null
            									AND Project_Owner__c = :Userinfo.getUserId()
            									AND Reference_Use__c = false
            									AND Account_Request_Status__c NOT IN :status
            									AND (NOT Account_Request_Status__c LIKE 'Give Up%')
            									AND Reference_Use__c = false
            									AND Deadline__c >= :criticalDate
            									AND Deadline__c <= :cautionDate
            									ORDER BY Deadline__c DESC)
        									FROM Reference_Request__c
        									WHERE Opportunity__c = null
        									AND Reference_Use__c = false
        									AND Reference_Request_Status__c NOT IN :status
        									AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
        									ORDER BY CreatedDate DESC];
            } else if (selectedFilter == 'TodayRequests') {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Specified_Account__c = null
                								AND Deadline__c >= :criticalDate
                								AND CreatedDate >= TODAY
                								AND Deadline__c <= :cautionDate
                								AND Unspecified_Request_Status__c NOT IN :status
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
            									FROM Reference_Request_Accounts__r
            									WHERE Approval_Status__c = null
            									AND CreatedDate >= TODAY
            									AND Reference_Use__c = false
            									AND Account_Request_Status__c NOT IN :status
            									AND (NOT Account_Request_Status__c LIKE 'Give Up%')
            									AND Reference_Use__c = false
            									AND Deadline__c >= :criticalDate
            									AND Deadline__c <= :cautionDate
            									ORDER BY Deadline__c DESC)
        									FROM Reference_Request__c
        									WHERE Opportunity__c = null
        									AND Reference_Use__c = false
        									AND Reference_Request_Status__c NOT IN :status
        									AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
        									ORDER BY CreatedDate DESC];
            }
            storeAllRecords();
            bwtCriticalCautionReq = changeProcess();
        }
    }
    
    /**
     * to filter all requests which has deadline greater than caution date
     */
    public void filterGreen() {
    	
        if (cautionDate != null) {
        	
            if (selectedFilter == 'All') {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Specified_Account__c = null
                								AND Deadline__c > :cautionDate
                								AND Unspecified_Request_Status__c NOT IN :status
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
            									FROM Reference_Request_Accounts__r
            									WHERE Approval_Status__c = null
            									AND Reference_Use__c = false
            									AND Account_Request_Status__c NOT IN :status
            									AND (NOT Account_Request_Status__c LIKE 'Give Up%')
            									AND Reference_Use__c = false
            									AND Deadline__c > :cautionDate
            									ORDER BY Deadline__c DESC)
        									FROM Reference_Request__c
        									WHERE Opportunity__c = null
        									AND Reference_Use__c = false
        									AND Reference_Request_Status__c NOT IN :status
        									AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
        									ORDER BY CreatedDate DESC];
            } else if (selectedFilter == 'MyRequests') {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
            								(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
            									Unspecified_Request_Status__c FROM Unspecified_Requests__r
            									WHERE Specified_Account__c = null
            									AND Deadline__c > :cautionDate
            									AND Project_Owner__c = :Userinfo.getUserId()
            									AND Unspecified_Request_Status__c NOT IN :status
            									ORDER BY Deadline__c DESC),
        									(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
        										Reference_Owner__c, Project_Owner__c, Reference_Type_Needed__c, Account_Request_Status__c
        										FROM Reference_Request_Accounts__r
        										WHERE Approval_Status__c = null
        										AND Project_Owner__c = :Userinfo.getUserId()
        										AND Reference_Use__c = false
        										AND Account_Request_Status__c NOT IN :status
        										AND (NOT Account_Request_Status__c LIKE 'Give Up%')
        										AND Reference_Use__c = false
        										AND Deadline__c > :cautionDate
        										ORDER BY Deadline__c DESC)
    										FROM Reference_Request__c
    										WHERE Opportunity__c = null
    										AND Reference_Use__c = false
    										AND Reference_Request_Status__c NOT IN :status
    										AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
    										ORDER BY CreatedDate DESC];
            } else if (selectedFilter == 'TodayRequests') {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Specified_Account__c = null
                								AND Deadline__c > :cautionDate
                								AND CreatedDate >= TODAY
                								AND Unspecified_Request_Status__c NOT IN :status
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
        										FROM Reference_Request_Accounts__r
        										WHERE Approval_Status__c = null
        										AND CreatedDate >= TODAY
        										AND Reference_Use__c = false
        										AND Account_Request_Status__c NOT IN :status
        										AND (NOT Account_Request_Status__c LIKE 'Give Up%')
        										AND Reference_Use__c = false
        										AND Deadline__c > :cautionDate
        										ORDER BY Deadline__c DESC)
    										FROM Reference_Request__c
    										WHERE Opportunity__c = null
    										AND Reference_Use__c = false
    										AND Reference_Request_Status__c NOT IN :status
    										AND (NOT Reference_Request_Status__c LIKE 'Give Up%')
    										ORDER BY CreatedDate DESC];
            }
            storeAllRecords();
            cautionReq = changeProcess();
        }
    }

    private void storeAllRecords() {
        accReqList = new Set<Id>();
        unSpeReqList = new Set<Id>();
        reqList = new Set<Id>();
        requestPageMap = new Map<Integer, List<Id>>();
        
        for (Reference_Request__c req : requestListWithoutOpp) {
            reqList.add(req.Id);
            
            if (req.Reference_Request_Accounts__r.size() > 0 || req.Unspecified_Requests__r.size() > 0) {
            	
                for (Reference_Request_Account__c rra: req.Reference_Request_Accounts__r) {
                    accReqList.add(rra.Id);
                }
                
                for (Unspecified_Request__c unSpec: req.Unspecified_Requests__r) {
                    unSpeReqList.add(unSpec.Id);
                }
            }
        }
    }
    
    /**
     * method to change list according to the process
     */
    public Integer changeProcess() {
        
        if (reqProcess != '') {
        	
            if (reqProcess == ConstantsController.MANAGED) {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Id IN :unSpeReqList
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
        										FROM Reference_Request_Accounts__r
        										WHERE Managed_Request__c = true
        										AND Id IN :accReqList
        										ORDER BY Deadline__c DESC)
    										FROM Reference_Request__c
    										WHERE Id IN :reqList
    										ORDER BY CreatedDate DESC];
            } else if (reqProcess == ConstantsController.REP2REP) {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Id IN :accReqList
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
        										FROM Reference_Request_Accounts__r
        										WHERE Managed_Request__c = false
        										AND Id IN :accReqList
        										ORDER BY Deadline__c DESC)
    										FROM Reference_Request__c
    										WHERE Id IN :reqList
    										ORDER BY CreatedDate DESC];
            } else {
                requestListWithoutOpp = [SELECT Name, Title__c, Requester__c,
                							(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                								Unspecified_Request_Status__c FROM Unspecified_Requests__r
                								WHERE Id IN :unSpeReqList
                								ORDER BY Deadline__c DESC),
            								(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            									Reference_Type_Needed__c, Reference_Owner__c, Project_Owner__c, Account_Request_Status__c
            									FROM Reference_Request_Accounts__r
            									WHERE Id IN :accReqList
            									ORDER BY Deadline__c DESC)
        									FROM Reference_Request__c
        									WHERE Id IN :reqList
        									ORDER BY CreatedDate DESC];
            }
            return search();
        }
        return 0;
    }
    
    private List<Id> listOfReq;
    
    /**
     * method to set the pagination and return no of records
     */
    public Integer search() {
    	
        try {
            Integer listSize = 0;
            listOfReq = new List<Id>();
            
            for (Reference_Request__c req : requestListWithoutOpp) {
            	
                if (req.Reference_Request_Accounts__r.size() > 0 || req.Unspecified_Requests__r.size() > 0) {
                    listOfReq.add(req.Id);
                    listSize += req.Reference_Request_Accounts__r.size() + req.Unspecified_Requests__r.size();
                }
            }
            pageNumber = 0;
            currentPageNumber = pageNumber;
            noOfRecords = 0;
            noOfRecords = listOfReq.size();
            totalPage = noOfRecords / size;
            
            if (math.mod(noOfRecords, size) > 0) {
                totalPage += 1;
            }
            next();
            return listSize;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return 0;
    }
    
    public transient List<ReferenceRequestWrapper> allReqWithoutOpp { get; set; }
    
    /**
     * getter for list of ReferenceRequestWrapper
     */
    public void fetchAllRequests() {
    	
	    if (requestListWithoutOpp != null && requestListWithoutOpp.size() > 0) {
	        Map<Id, List<ReferenceRequestWrapper>> requestMap = new Map<Id, List<ReferenceRequestWrapper>>();
	        allReqWithoutOpp = new List<ReferenceRequestWrapper>();
	        List<ReferenceRequestWrapper> tempRequestList = new List<ReferenceRequestWrapper>();
	        
	        for (Reference_Request__c req : requestListWithoutOpp) {
	        	
	            for (Reference_Request_Account__c rra : req.Reference_Request_Accounts__r) {
	                String backgroundColor = '#FFFFFF';
	                
	                if (rra.Deadline__c < criticalDate) {
	                    backgroundColor = '#FF0000';
	                }
	                
	                if (rra.Deadline__c >= criticalDate && rra.Deadline__c <= cautionDate) {
	                    backgroundColor = '#FFCC00';
	                }
	                
	                if (rra.Deadline__c > cautionDate) {
	                    backgroundColor = '#00FF00';
	                }
	                
	                if (rra.Managed_Request__c) {
	                    tempRequestList.add(new ReferenceRequestWrapper(false, false, req, rra, backgroundColor, ConstantsController.MANAGED));
	                } else {
	                    tempRequestList.add(new ReferenceRequestWrapper(false, false, req, rra, backgroundColor, ConstantsController.REP2REP));
	                }
	            }
	            
	            for (Unspecified_Request__c unSpec : req.Unspecified_Requests__r) {
	                String backgroundColor = '#FFFFFF';
	                
	                if (unSpec.Deadline__c < criticalDate) {
	                    backgroundColor = '#FF0000';
	                }
	                
	                if (unSpec.Deadline__c >= criticalDate && unSpec.Deadline__c <= cautionDate) {
	                    backgroundColor = '#FFCC00';
	                }
	                
	                if (unSpec.Deadline__c > cautionDate) {
	                    backgroundColor = '#00FF00';
	                }
	                tempRequestList.add(new ReferenceRequestWrapper(false, false, req, unSpec, backgroundColor, ConstantsController.MANAGED));
	            }
	            requestMap.put(req.Id, new List<ReferenceRequestWrapper> (tempRequestList));
	            tempRequestList.clear();
	        }
	        ReferenceRequestWrapper temp;
	        
	        for (Reference_Request__c req : requestListWithoutOpp) {
	            tempRequestList = requestMap.get(req.Id);
	            
	            if (tempRequestList.size() == 0) {
	            	
	                if (tempRequestList.size() > 2) {
	                    
	                    for (Integer i = 0; i < tempRequestList.size() - 1; i++) {
	                        
	                        for (Integer j = i + 1; j < tempRequestList.size(); j++) {
	                        	
	                            if (tempRequestList.get(i).deadline < tempRequestList.get(j).deadline) {
	                                temp = tempRequestList.get(i);
	                                tempRequestList.set(i, tempRequestList.get(j));
	                                tempRequestList.set(j, temp);
	                            }
	                        }
	                    }
	                }
	            }
	            tempRequestList[0].isReq = true;
	            
	            for (ReferenceRequestWrapper tempreq : tempRequestList) {
	                allReqWithoutOpp.add(tempreq);
	            }
	        }
	    }
	}
	
    private Map<Integer, List<Id>> requestPageMap;
    
    public void setPageNumber() {
        isSettingPage = true;
        Integer nextPage = PageNumber;
        
        if (PageNumber < 1) {
            PageNumber = 0;
            nextPage = 1;
            currentpageNumber=0;
        } else {
            PageNumber = currentpageNumber;
        }
        
        if (nextPage < currentpageNumber) {
            
            for (Integer i = currentpageNumber; i > nextPage; i--) {
                previous();
            }
        } else if (nextPage > currentpageNumber) {
        	
            if (nextPage > totalPage) {
                nextPage = totalPage;
                
                if (PageNumber == totalPage) {
                    PageNumber--;
                    currentpageNumber--;
                }
            }
            
            for (Integer i = currentpageNumber; i < nextPage; i++) {
                next();
            }
        }
        isSettingPage = false;
        fetchAllRequests();
    }
    
    public void next() {
        List<Reference_Request__c> tempList;
        pageNumber ++;
        Set<Id> reqIds = new Set<Id>();
        
        if (requestPageMap != null && requestPageMap.size() > 0) {
        	
            for (Integer pageNo : requestPageMap.keySet()) {
            	
                if (pageNo < pageNumber) {
                    reqIds.addAll(requestPageMap.get(pageNo));
                }
            }
        }
        
        if (reqProcess != '') {
            requestListWithoutOpp = new List<Reference_Request__c>();
            
            if (reqProcess == ConstantsController.MANAGED) {
                tempList = [SELECT Name, Title__c, Requester__c,
                				(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                					Unspecified_Request_Status__c FROM Unspecified_Requests__r
                					WHERE Id IN :unSpeReqList
                					ORDER BY Deadline__c DESC),
            					(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            						Reference_Owner__c, Reference_Type_Needed__c, Project_Owner__c, Account_Request_Status__c
            						FROM Reference_Request_Accounts__r
            						WHERE Managed_Request__c = true
            						AND Id IN :accReqList
            						ORDER BY Deadline__c DESC)
        						FROM Reference_Request__c
        						WHERE (Id IN :listOfReq AND Id NOT IN :reqIds)
        						ORDER BY CreatedDate DESC LIMIT :size + 1];
            } else if (reqProcess == ConstantsController.REP2REP) {
                tempList = [SELECT Name, Title__c, Requester__c,
                				(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                					Unspecified_Request_Status__c FROM Unspecified_Requests__r
                					WHERE Id IN :accReqList
                					ORDER BY Deadline__c DESC),
            					(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            						Reference_Owner__c, Reference_Type_Needed__c, Project_Owner__c, Account_Request_Status__c
        							FROM Reference_Request_Accounts__r
        							WHERE Managed_Request__c = false
        							AND Id IN :accReqList
        							ORDER BY Deadline__c DESC)
    							FROM Reference_Request__c
    							WHERE (Id IN :listOfReq AND Id NOT IN :reqIds)
    							ORDER BY CreatedDate DESC LIMIT :size + 1];
            } else {
                tempList = [SELECT Name, Title__c, Requester__c,
                				(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                					Unspecified_Request_Status__c FROM Unspecified_Requests__r
                					WHERE Id IN :unSpeReqList
                					ORDER BY Deadline__c DESC),
            					(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            						Reference_Owner__c, Reference_Type_Needed__c, Project_Owner__c, Account_Request_Status__c
            						FROM Reference_Request_Accounts__r
            						WHERE Id IN :accReqList
            						ORDER BY Deadline__c DESC)
        						FROM Reference_Request__c
        						WHERE (Id IN :listOfReq AND Id NOT IN :reqIds)
        						ORDER BY CreatedDate DESC LIMIT :size + 1];
            }
            
            if (!requestPageMap.containsKey(pageNumber)) {
                requestPageMap.put(pageNumber, new List<Id>());
            }
            
            for (Reference_Request__c req : tempList) {
            	
                if (requestListWithoutOpp.size() < size) {
                    hasNext = false;
                    hasPrevious = false;
                    requestPageMap.get(pageNumber).add(req.Id);
                    requestListWithoutOpp.add(req);
                } else {
                    hasNext = true;
                    break;
                }
            }
            
            if (pageNumber > 1) {
                hasPrevious = true;
            }
        }
        currentPageNumber = pageNumber;
        
        if (!isSettingPage) {
            fetchAllRequests();
        }
    }
    
    public void previous() {
        List<Reference_Request__c> tempList;
        pageNumber--;
        Set<Id> reqIds = new Set<Id>();
        
        if (requestPageMap != null && requestPageMap.size() > 0) {
        	
            for (Integer pageNo : requestPageMap.keySet()) {
            	
                if (pageNo == pageNumber) {
                    reqIds.addAll(requestPageMap.get(pageNo));
                }
            }
        }
        
        if (reqProcess != '') {
            requestListWithoutOpp = new List<Reference_Request__c>();
            
            if (reqProcess == ConstantsController.MANAGED) {
                tempList = [SELECT Name, Title__c, Requester__c,
                				(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                					Unspecified_Request_Status__c FROM Unspecified_Requests__r
                					WHERE Id IN :unSpeReqList
                					ORDER BY Deadline__c DESC),
            					(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            						Reference_Owner__c, Reference_Type_Needed__c, Project_Owner__c, Account_Request_Status__c
            						FROM Reference_Request_Accounts__r
            						WHERE Managed_Request__c = true
            						AND Id IN :accReqList
            						ORDER BY Deadline__c DESC)
        						FROM Reference_Request__c
        						WHERE (Id IN :listOfReq AND Id IN :reqIds)
        						ORDER BY CreatedDate DESC LIMIT :size];
            } else if (reqProcess == ConstantsController.REP2REP) {
                tempList = [SELECT Name, Title__c, Requester__c,
                				(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                					Unspecified_Request_Status__c FROM Unspecified_Requests__r
                					WHERE Id IN :accReqList
                					ORDER BY Deadline__c DESC),
            					(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
            						Reference_Owner__c, Reference_Type_Needed__c, Project_Owner__c, Account_Request_Status__c
            						FROM Reference_Request_Accounts__r
            						WHERE Managed_Request__c = false
            						AND Id IN :accReqList
            						ORDER BY Deadline__c DESC)
        						FROM Reference_Request__c
        						WHERE (Id IN :listOfReq AND Id IN :reqIds)
        						ORDER BY CreatedDate DESC LIMIT :size];
            } else {
                tempList = [SELECT Name, Title__c, Requester__c,
                				(SELECT CreatedById, Deadline__c, Reference_Type_Needed__c, Project_Owner__c,
                					Unspecified_Request_Status__c FROM Unspecified_Requests__r
                					WHERE Id IN :unSpeReqList
                					ORDER BY Deadline__c DESC),
            					(SELECT CreatedById, Account__c, Deadline__c, Managed_Request__c, Process__c,
        							Reference_Owner__c, Reference_Type_Needed__c, Project_Owner__c, Account_Request_Status__c
        							FROM Reference_Request_Accounts__r
        							WHERE Id IN :accReqList
        							ORDER BY Deadline__c DESC)
    							FROM Reference_Request__c
    							WHERE (Id IN :listOfReq AND Id IN :reqIds)
    							ORDER BY CreatedDate DESC LIMIT :size];
            }
            
            for (Reference_Request__c req : tempList) {
            	
                if (requestListWithoutOpp.size() < size) {
                    requestListWithoutOpp.add(req);
                }
            }
            
            if (pageNumber == 1) {
                hasPrevious = false;
            }
            hasNext = true;
        }
        currentPageNumber = pageNumber;
        
        if (!isSettingPage) {
            fetchAllRequests();
        }
    }
}