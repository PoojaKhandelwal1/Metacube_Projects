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
 * Page: NominationWorkspace 
 * Description: Class used to handle NominationWorkspace   
 * Modified by: Rajesh @20 Jan 2017
 */
public with sharing class NominationWorkspaceController {
    /**
     * Properties and variables
     */
    public Custom_Settings__c cs;
    public transient List<Nomination__c> nominationList { get; set; }
    public String QueryString { get; set; }
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
    public Boolean isSettingPage { get; set; }
    public Integer pageNumber { get; set; }
    public String pageNumberString {
        get {
            return String.valueOf(pageNumber);
        }
        set;
    }
    public Integer currentPageNumber { get; set; }
    private Date todayDate;
    private Date criticalDate;
    private List<Id> listOfReq;
    public transient List<NominationWrapper> allNomination { get; set; }
    public String selectedFilter { get; set; }
    private Map<Integer, List<Id>> nominationPageMap;
    
    /**
     * Constructor
     */
    public NominationWorkspaceController() {
        cs = UtilityController.getCustomSettings();
        allNomination = getallNomination();
        size = 10;
        pageNumber = 0;
        currentPageNumber = 0;
        isSettingPage = false;
        todayDate = system.today();
        selectedFilter = 'All';
        nominationPageMap = new Map<Integer, List<Id>>();
        criticalDate = todayDate.addDays(-integer.valueOf(cs.Nomination_disposition_window__c));
        filterOnHold();
        filterRed();
        filterGreen();
        filterAllOpen();
    }
    
    /**
     * Method to filter all completed nominations
     */
    public void filterAllOpen() {
    	
        if (selectedFilter == 'All') {
            nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                FROM Nomination__c WHERE Status__c != :ConstantsController.COMPLETED AND Account__c != null ORDER BY CreatedDate DESC];
        } else if (selectedFilter == 'MyRequests') {
            nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                				FROM Nomination__c WHERE Status__c != :ConstantsController.COMPLETED AND Account__c != null And Manager__c = :Userinfo.getUserId() 
                				ORDER BY CreatedDate DESC];
        } else if (selectedFilter == 'TodayRequests') {
            nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                			FROM Nomination__c WHERE Status__c != :ConstantsController.COMPLETED AND Account__c != null AND CreatedDate >= today ORDER BY CreatedDate DESC ];
        }
        search();
    }

    /**
     * Method to filter all on hold nominations
     */
    public void filterOnHold() {
        
        if (selectedFilter == 'All') {
            nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                			FROM Nomination__c WHERE Status__c = :ConstantsController.ONHOLD AND Account__c != null ORDER BY CreatedDate DESC ];
        } else if (selectedFilter == 'MyRequests') {
            nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                			FROM Nomination__c WHERE Status__c = :ConstantsController.ONHOLD AND Manager__c = :Userinfo.getUserId() AND Account__c != null 
                			ORDER BY CreatedDate DESC ];
        } else if (selectedFilter == 'TodayRequests') {
            nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                			FROM Nomination__c WHERE Status__c = :ConstantsController.ONHOLD AND CreatedDate >= today AND Account__c != null ORDER BY CreatedDate DESC ];
        }
        search();
    }

    /**
     * Method to filter all nominations which has date less than Nomination Disposition Goa
     */
    public void filterRed() {
        
        if (criticalDate != null) {
            
            if (selectedFilter == 'All') {
                nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                    				FROM Nomination__c WHERE CreatedDate < :criticalDate AND Status__c != :ConstantsController.COMPLETED 
                    				AND Status__c != :ConstantsController.ONHOLD  AND Account__c != null ORDER BY CreatedDate DESC ];
            } else if (selectedFilter == 'MyRequests') {
                nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                    				FROM Nomination__c WHERE CreatedDate < :criticalDate AND Status__c != : ConstantsController.COMPLETED 
                    				AND Status__c != :ConstantsController.ONHOLD AND Account__c != null And Manager__c = :Userinfo.getUserId() ORDER BY CreatedDate DESC ];
            } else if (selectedFilter == 'TodayRequests') {
                nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                    				FROM Nomination__c WHERE CreatedDate < :criticalDate AND Status__c != :ConstantsController.COMPLETED 
                    				AND Status__c != :ConstantsController.ONHOLD AND Account__c != null AND CreatedDate >= today ORDER BY CreatedDate DESC ];
            }
            search();
        }
    }

    /**
     * Method to filter all nominations which has date greater than Nomination Disposition Goal 
     */
    public void filterGreen() {
        
        if (criticalDate != null) {
            
            if (selectedFilter == 'All') {
                nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                   					 FROM Nomination__c WHERE CreatedDate >= : criticalDate AND Status__c != :ConstantsController.COMPLETED 
                   					 AND Status__c != :ConstantsController.ONHOLD AND Account__c != null ORDER BY CreatedDate DESC ];
            } else if (selectedFilter == 'MyRequests') {
                nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                   					 FROM Nomination__c WHERE CreatedDate >= :criticalDate AND Status__c != :ConstantsController.COMPLETED 
                   					 AND Status__c != : ConstantsController.ONHOLD AND Account__c != null And CreatedById = : Userinfo.getUserId() ORDER BY CreatedDate DESC ];
            } else if (selectedFilter == 'TodayRequests') {
                nominationList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
                    				FROM Nomination__c WHERE CreatedDate >= :criticalDate AND Status__c != :ConstantsController.COMPLETED 
                    				AND Status__c != :ConstantsController.ONHOLD AND CreatedDate >= today AND Account__c != null ORDER BY CreatedDate DESC
                ];
            }
            search();
        }
    }

    /**
     * Method to set the pagination and return no of records
     */
    public void search() {
        try {
            listOfReq = new List<Id>();
            nominationPageMap = new Map<Integer, List<Id>>();
            
            for (Nomination__c req : nominationList) {
                listOfReq.add(req.Id);
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
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }
    
    /**
     * getter for list of NominationWrapper
     */
    public List<NominationWrapper> getallNomination() {
       
        if (nominationList != null && nominationList.size() > 0) {
            integer tempSize = 0;
            List<NominationWrapper> allNomination = new List<NominationWrapper>();
            
            for (Nomination__c nomi : nominationList) {
                String backgroundColor = '#FFFFFF';
                
                if (nomi.CreatedDate < criticalDate) {
                    backgroundColor = '#FF0000';
                }
                
                if (nomi.CreatedDate > criticalDate) {
                    backgroundColor = '#00FF00';
                }
                allNomination.add(new NominationWrapper(nomi, backgroundColor));
            }

            return allNomination;
        } else
            return null;
    }
    /**
     * Method to set page Number
     */
    public void setPageNumber() {
        isSettingPage = true;
        Integer nextPage = PageNumber;
        
        if (PageNumber < 1) {
            PageNumber = 0;
            nextPage = 1;
            currentpageNumber = 0;
        } else {
            PageNumber = currentpageNumber;
        }
        
        if (nextPage < currentpageNumber) {
        	
            for (integer i = currentpageNumber; i > nextPage; i--) {
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
            
            for (integer i = currentpageNumber; i < nextPage; i++) {
                next();
            }
        }
        isSettingPage = false;
        allNomination = getallNomination();
    }
    /**
     * Method to next link
     */
    public void next() {
        List<Nomination__c> tempList;
        pageNumber++;
        Set<Id> reqIds = new Set<Id>();
        
        if (nominationPageMap != null && nominationPageMap.size() > 0) {
           
            for (Integer pageNo : nominationPageMap.keySet()) {
                
                if (pageNo < pageNumber) {
                    reqIds.addAll(nominationPageMap.get(pageNo));
                }
            }
        }
        nominationList = new List<Nomination__c>();
        tempList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
            FROM Nomination__c WHERE(Id IN :listOfReq AND Id NOT IN :reqIds) AND Account__c != null ORDER BY CreatedDate DESC LIMIT :size + 1
        ];
        
        if (!nominationPageMap.containsKey(pageNumber)) {
            nominationPageMap.put(pageNumber, new List<Id>());
        }
       
        for (Nomination__c req : tempList) {
        	
            if (nominationList.size() < size) {
                hasNext = false;
                hasPrevious = false;
                nominationPageMap.get(pageNumber).add(req.Id);
                nominationList.add(req);
            } else {
                hasNext = true;
                break;
            }
        }
        
        if (pageNumber > 1) {
            hasPrevious = true;
        }
        currentPageNumber = pageNumber;
        
        if (!isSettingPage) {
            allNomination = getallNomination();
        }
    }
    /**
     * Method to previous link
     */
    public void previous() {
        List<Nomination__c> tempList;
        pageNumber--;
        Set<Id> reqIds = new Set<Id>();
        
        if (nominationPageMap != null && nominationPageMap.size() > 0) {
           
            for (Integer pageNo : nominationPageMap.keySet()) {
               
                if (pageNo == pageNumber) {
                    reqIds.addAll(nominationPageMap.get(pageNo));
                }
            }
        }
        nominationList = new List<Nomination__c>();
        tempList = [SELECT Id, Name, Account__c, Contact__c, Other_Info__c, Status__c, OwnerId, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Manager__c
            FROM Nomination__c WHERE (Id IN :listOfReq AND Id IN :reqIds) AND Account__c != null ORDER BY CreatedDate DESC LIMIT :size
        ];

        for (Nomination__c req : tempList) {
            
            if (nominationList.size() < size) {
                nominationList.add(req);
            }
        }
        
        if (pageNumber == 1) {
            hasPrevious = false;
        }
        hasNext = true;
        currentPageNumber = pageNumber;
        
        if (!isSettingPage) {
            allNomination = getallNomination();
        }
    }
    
    /**
     * Wrapper Class
     */
    public class NominationWrapper {
        public Nomination__c nomination { get; set; }
        public String backgroundColor { get; set; }
        
        public NominationWrapper(Nomination__c nomination, String backgroundColor) {
            this.nomination = nomination;
            this.backgroundColor = backgroundColor;
        }
    }
}