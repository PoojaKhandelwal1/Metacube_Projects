/** 
* Author: Tarun Khandelwal
* Since: March 13, 2015 
* Name: CustomerOrderCtrl 
* Description: Apex class which contains all remoted methods related to Customer Order Page.
**/
global with sharing class CustomerOrderCtrl {
    public static SO_KLI_Recalculation.Errorhandler error;
    
    global CustomerOrderCtrl (NewHomePageCtrl controller){}
    public CustomerOrderCtrl() {}
    
    public Decimal Home_Search_Grid_Page_Size { get{return GeneralConfiguration.getHomeSearchGridPageSize();} private set;}
    public Decimal Related_List_Page_Size { get{return GeneralConfiguration.getRelatedListPageSize();} private set;}
    public boolean Is_Widget_Removeable {get{return GeneralConfiguration.isWidgetRemoveable();}}
    public boolean Load_New_Customer_Order {get{return GeneralConfiguration.isLoadNewCustomerOrder();} private set;}
    public boolean Load_New_UI {get{return GeneralConfiguration.isLoadNewUI();} private set;}
    public boolean Load_New_View_Customer {get{return GeneralConfiguration.isLoadNewViewCustomer();} private set;}
    public Decimal Sales_Tax_Rate {get{return GeneralConfiguration.getAustralianMarketSalesTaxRate();} private set;}
    private static final String BLACKPURL_PROFILE_NAME = 'Blackpurl'; // Added by richa #1972
    private static final List<String> PROFILE_NAME_LIST = new List<String>{BLACKPURL_PROFILE_NAME}; // Added by richa #1972
    public Decimal Cash_Paymenmt_Rounding_Factor { get{return GeneralConfiguration.getCashPaymenmtRoundingFactor();} private set;} // Added by richa #1991
    
    // New STA searching function
    @RemoteAction
    global static String getSearchResult(String JSONString) {
        String searchJSONString = GenericSearchCtrl.getSearchResults(JSONString);
        return BPUtility.getEncodedString(searchJSONString);
    }
    
    /**
     * Name: getSearchResults
     * Desc: Method which gives records according to the search critaria
     * @param:  (1) JSONString - String - JSON String of searched Value
     * @return: String - JSON String of searched records     
    **/
    @RemoteAction
    global static String getSearchResults(String JSONString) {
        // Parse the search JSON for object label and searc string
        JSONString = BPUtility.getDecodedString(JSONString);
        //System.assert(false, JSONString);
        SearchSuggestionJSON.QueryJSON searchQueryJSON = SearchSuggestionJSON.parseQuery(JSONString);
        String searchJSONString = '';
        searchJSONString = SearchSuggestionUtil.getSearchSuggestionJSON(searchQueryJSON);
        /*try{
            
        }catch(Exception e){
            system.assert(false, e);
            return BPUtility.getEncodedString('');


        }*/
        return BPUtility.getEncodedString(searchJSONString);
    }
 
    /**
    * Name: getRecordById
    * Desc: Method which gives Sobject Record By its Id
    * @param:  (1) recordId - String - record Id 
    * @return: String - JSON String of searched records
    **/
    @RemoteAction
    global static String getRecordById(String recordId){
        recordId = BPUtility.getDecodedString(recordId);
        try{
            String objectName = String.valueOf(Id.valueOf(recordId).getSobjectType());
            Map<String, String> objectFieldsToJsonMap;
            Map<String, String> objectFieldsToDataTypeMap;
            if(objectName == 'Account') {
                objectFieldsToJsonMap = Constants.CUSTOMER_FIELDS_TO_JSON_MAPPING;
                objectFieldsToDataTypeMap = Constants.CUSTOMER_FIELDS_TO_DATA_TYPE_MAPPING;
            } else if(objectName == 'User') {
                objectFieldsToJsonMap = Constants.USER_FIELDS_TO_JSON_MAPPING;
                objectFieldsToDataTypeMap = Constants.USER_FIELDS_TO_DATA_TYPE_MAPPING;
            }
            List<Sobject> sobjectRecords = SOQLUtil.getRecordById(new List<String>{recordId}, objectFieldsToJsonMap, objectName);
            return BPUtility.getEncodedString(Utility.createJSON(sobjectRecords, objectFieldsToJsonMap, objectFieldsToDataTypeMap, new List<Sobject>(), new map<String, String>(), new map<String, String>()));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }

    /**
    * Name: getPartDetails
    * Desc: Method which gives a part detail as per part Id
    * @param:  (1) partId - String - Id for the part record
    * @return: String - JSON String of part detail
    **/
    @RemoteAction
    global static String getPartDetails(String partId){
        partId = BPUtility.getDecodedString(partId);
        try{
            List<Part__c> partRecords = SOQLUtil.getPartRecord(new List<Id>{partId});
            if(partRecords.size() == 0){
                return BPUtility.getEncodedString('');


            }
            Part partDetail = new Part(partRecords[0]);
            return BPUtility.getEncodedString(System.JSON.serialize(partDetail));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }

    /**
    * Name: getCOHeaderDetails
    * Desc: Method to get json string of All parameters used in Customer Order Page
    * @param:  (1) coHeaderId - String - Id of CO Header Record
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction  
    global static String getCOHeaderDetails(String coHeaderId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }

            List<CO_Header__c> coHeaderRec = SOQLUtil.getCOHeaderDetails(coHeaderId) ;
            List<CO_Line_Item__c> coLineItems = SOQLUtil.getCOLineItemByCOHeaderId(coHeaderId);
            List<CO_Kit_Header__c> coKitHeaders = SOQLUtil.getCOKHByCOHeaderId(coHeaderId);
            List<Vendor_Order_Line_Item__c> specialOrders = SOQLUtil.getSpecialOrderByCOHeaderId(coHeaderId);   
            List<User> currentUser = SOQLUtil.getCurrentUserInfo();
            List<CO_Deposit__c> coDeposits = SOQLUtil.getCODepositByCOHeaderId(coHeaderId);
            List<CO_Invoice_Header__c> coInvoiceHeaders = SOQLUtil.getCOInvoiceHeaderByCOHeaderId(coHeaderId);     
            List<CO_Invoice_Payment__c> coInvoicePayments = new List<CO_Invoice_Payment__c>();
            List<CO_Invoice_Item__c> coInvoiceItems = new List<CO_Invoice_Item__c>();
            List<Account> customerRecords = new List<Account>();
            List<CO_Invoice_Header__c> closedCOInvoiceHeaders = SOQLUtil.getInvoiceHistory(coHeaderId);
            List<Price_Level__c> priceLevelList = new List<Price_Level__c>();
            List<Customer_Owned_Unit__c> couRecords = new List<Customer_Owned_Unit__c>();
            
            if(coHeaderRec.size() > 0 && coHeaderRec[0].Customer__c != null) {
                couRecords = SOQLUtil.getCOUListByCustomerId(coHeaderRec[0].Customer__c);
            } 
             
            if(coHeaderRec.size() > 0 && coHeaderRec[0].CO_Type__c == 'Customer' && coHeaderRec[0].Customer__c != null){
                customerRecords = SOQLUtil.getCardDetails(new Map<String, String>{'Id' => coHeaderRec[0].Customer__c});  
            }else if(coHeaderRec.size() > 0 && coHeaderRec[0].CO_Type__c == 'Cash Sale'){
                priceLevelList = SOQLUtil.getCardDetailsForCO(null);  
            }else if(coHeaderRec.size() > 0 && coHeaderRec[0].CO_Type__c == 'Internal Service'){
                String defaultPriceLevelId = GeneralConfiguration.getDefaultPriceLevelOnInternalService();
                priceLevelList = SOQLUtil.getCardDetailsForCO(defaultPriceLevelId);    
            }
                
            if(coLineItems == null) {
                coLineItems = new List<CO_Line_Item__c>();
            }
            if(coDeposits == null) {
                coDeposits = new List<CO_Deposit__c>();
            }
            if(coInvoiceHeaders == null) {
                coInvoiceHeaders = new List<CO_Invoice_Header__c>();
            } else if(coInvoiceHeaders.size() > 0) {
                coInvoicePayments = SOQLUtil.getCOInvoicePaymentsByCOInvoiceHeaderId(coInvoiceHeaders[0].Id);
                coInvoiceItems = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coInvoiceHeaders[0].Id);
            }
            
            List<Id> vendorIdList = new List<Id>();
            for(CO_Line_Item__c coLineItemRec : coLineItems) {
                if(coLineItemRec.Part__r != null && coLineItemRec.Part__r.Vendor__c != null) {
                    vendorIdList.add(coLineItemRec.Part__r.Vendor__c);
                }
            }
            
            List<Vendor_Order_Header__c> voHeaderList = SOQLUtil.getVOHeaderByFieldName(new Map<String, List<String>>{'Vendor__c'=> vendorIdList});
            Map<Id, List<Vendor_Order_Header__c>> vendorIdToVOHeadesListMap = new Map<Id, List<Vendor_Order_Header__c>>();
            List<Vendor_Order_Header__c> voHeadersList;
            
            for(Vendor_Order_Header__c voHeaderRec : voHeaderList) {
                if(!vendorIdToVOHeadesListMap.containsKey(voHeaderRec.Vendor__c)) {
                    voHeadersList = new List<Vendor_Order_Header__c>();
                } else {
                    voHeadersList = vendorIdToVOHeadesListMap.get(voHeaderRec.Vendor__c);
                }
                voHeadersList.add(voHeaderRec);
                vendorIdToVOHeadesListMap.put(voHeaderRec.Vendor__c, voHeadersList);
            }

            COHeaderWrapper coHeaderWrapperObj;
            if(coHeaderRec.size() > 0) {
                coHeaderWrapperObj = new COHeaderWrapper(coHeaderRec[0], coLineItems, coKitHeaders, currentUser[0].LocaleSidKey, coDeposits, coInvoiceHeaders, 
                                                            coInvoicePayments, coInvoiceItems, closedCOInvoiceHeaders, vendorIdToVOHeadesListMap, couRecords, specialOrders, customerRecords, priceLevelList);
            }
            if(coHeaderRec.size() > 0 && coHeaderRec[0].Owner__c == currentUser[0].Id){
                CO_Header__c currentCOHeader = new CO_Header__c(Id = coHeaderId);
                currentCOHeader.Owner_Last_Visited__c = System.now();
                update currentCOHeader;
                
            }
            return BPUtility.getEncodedString(System.JSON.serialize(coHeaderWrapperObj));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
    * Name: getCOHeaderDetailsByGridName
    * Desc: Method to get json string of All parameters used in Customer Order Page
    * @param:  (1) coHeaderId - String - Id of CO Header Record 
               (2) gridName - String - name of grid
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction 
    global static String getCOHeaderDetailsByGridName(String coHeaderId, String gridName){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        gridName = BPUtility.getDecodedString(gridName);
        try{            
            List<CO_Header__c> coHeaderRec = new List<CO_Header__c>();
            List<CO_Line_Item__c> coLineItems = new List<CO_Line_Item__c>();
            List<CO_Kit_Header__c> coKitHeaders = new List<CO_Kit_Header__c>();
            List<Vendor_Order_Line_Item__c> specialOrders = new List<Vendor_Order_Line_Item__c>();
            List<User> currentUser = new List<User>();
            List<CO_Deposit__c> coDeposits = new List<CO_Deposit__c>();
            List<CO_Invoice_Header__c> coInvoiceHeaders = new List<CO_Invoice_Header__c>();
            List<CO_Invoice_Payment__c> coInvoicePayments = new List<CO_Invoice_Payment__c>();
            List<CO_Invoice_Item__c> coInvoiceItems = new List<CO_Invoice_Item__c>();
            List<CO_Invoice_Header__c> closedCOInvoiceHeaders = new List<CO_Invoice_Header__c>();
            List<Customer_Owned_Unit__c> couRecords = new List<Customer_Owned_Unit__c>();
            List<Account> customerRecords = new List<Account>();
            List<Price_Level__c> priceLevelList = new List<Price_Level__c>();
            
            coHeaderRec = SOQLUtil.getCOHeaderDetails(coHeaderId) ;
            if(gridName == null || gridName.contains('coHeader')) {
                if(coHeaderRec.size() > 0 && coHeaderRec[0].CO_Type__c == 'Customer' && coHeaderRec[0].Customer__c != null){
                    customerRecords = SOQLUtil.getCardDetails(new Map<String, String>{'Id' => coHeaderRec[0].Customer__c});  
                }else if(coHeaderRec.size() > 0 && coHeaderRec[0].CO_Type__c == 'Cash Sale'){
                    priceLevelList = SOQLUtil.getCardDetailsForCO(null);  
                }else if(coHeaderRec.size() > 0 && coHeaderRec[0].CO_Type__c == 'Internal Service'){
                    String defaultPriceLevelId = GeneralConfiguration.getDefaultPriceLevelOnInternalService();
                    priceLevelList = SOQLUtil.getCardDetailsForCO(defaultPriceLevelId);  
                }
            }
            if(gridName == null || gridName.contains('coLineItem')) {
                coLineItems = SOQLUtil.getCOLineItemByCOHeaderId(coHeaderId);
                coKitHeaders = SOQLUtil.getCOKHByCOHeaderId(coHeaderId);
            }
            
            if(gridName == null || gridName.contains('specialOrder')) {
                specialOrders = SOQLUtil.getSpecialOrderByCOHeaderId(coHeaderId);
            }
            if(gridName == null ||  gridName.contains('user')) {
                currentUser = SOQLUtil.getCurrentUserInfo();
            }
            if(gridName == null ||  gridName.contains('coDeposit')) {
                coDeposits = SOQLUtil.getCODepositByCOHeaderId(coHeaderId);
            }
            if(gridName == null || gridName.contains('coInvoiceHeader')) {
                coInvoiceHeaders = SOQLUtil.getCOInvoiceHeaderByCOHeaderId(coHeaderId);
            }
            if(gridName == null || gridName.contains('closedCOInvoiceHeader')) {
                closedCOInvoiceHeaders = SOQLUtil.getInvoiceHistory(coHeaderId);
            }
            if(gridName == null || gridName.contains('cou')) {
                if(coHeaderRec.size() > 0 && coHeaderRec[0].Customer__c != null) {
                    couRecords = SOQLUtil.getCOUListByCustomerId(coHeaderRec[0].Customer__c);
                }
            }
            
            if(coInvoiceHeaders.size() > 0) {
                coInvoicePayments = SOQLUtil.getCOInvoicePaymentsByCOInvoiceHeaderId(coInvoiceHeaders[0].Id);
                coInvoiceItems = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coInvoiceHeaders[0].Id);
            }
            
            Map<Id, List<Vendor_Order_Header__c>> vendorIdToVOHeadesListMap = new Map<Id, List<Vendor_Order_Header__c>>();
            if(gridName == null || gridName.contains('coLineItem')) {
                List<Id> vendorIdList = new List<Id>();
                for(CO_Line_Item__c coLineItemRec : coLineItems) {
                    if(coLineItemRec.Part__r != null && coLineItemRec.Part__r.Vendor__c != null) {
                        vendorIdList.add(coLineItemRec.Part__r.Vendor__c);
                    }
                }
                List<Vendor_Order_Header__c> voHeaderList = SOQLUtil.getVOHeaderByFieldName(new Map<String, List<String>>{'Vendor__c'=> vendorIdList});
                List<Vendor_Order_Header__c> voHeadersList; 
                
                for(Vendor_Order_Header__c voHeaderRec : voHeaderList) {
                    if(!vendorIdToVOHeadesListMap.containsKey(voHeaderRec.Vendor__c)) {
                        voHeadersList = new List<Vendor_Order_Header__c>();
                    } else {
                        voHeadersList = vendorIdToVOHeadesListMap.get(voHeaderRec.Vendor__c);
                    }
                    voHeadersList.add(voHeaderRec);
                    vendorIdToVOHeadesListMap.put(voHeaderRec.Vendor__c, voHeadersList);
                }
            }
            
            COHeaderWrapper coHeaderWrapperObj;
            if(coHeaderRec.size() > 0) { 
                coHeaderWrapperObj = new COHeaderWrapper(coHeaderRec[0], coLineItems, coKitHeaders, currentUser[0].LocaleSidKey, coDeposits, coInvoiceHeaders, 
                                                            coInvoicePayments, coInvoiceItems, closedCOInvoiceHeaders, vendorIdToVOHeadesListMap, couRecords, specialOrders, customerRecords, priceLevelList);
            } else {
                coHeaderWrapperObj = new COHeaderWrapper(null, coLineItems, coKitHeaders, currentUser[0].LocaleSidKey, coDeposits, coInvoiceHeaders, 
                                                            coInvoicePayments, coInvoiceItems, closedCOInvoiceHeaders, vendorIdToVOHeadesListMap, couRecords, specialOrders, customerRecords, priceLevelList);
            }
            //system.assert(false, coHeaderWrapperObj);   
            return BPUtility.getEncodedString(System.JSON.serialize(coHeaderWrapperObj));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(''); 


    }
    

    /**
    * Name: getSOHeaderDetails
    * Desc: Method to get json string related to Service Header Order
    * @param:  (1) recordId - String - Id of CO Header Record
               (2) gridName - String - name of grid
    * @return: String - JSON String of SO Header Detail Record
    **/
    @RemoteAction 
    global static String getSOHeaderDetails(String recordId, String gridName){
        recordId = BPUtility.getDecodedString(recordId);
        gridName = BPUtility.getDecodedString(gridName);
        try{
            List<Service_Order_Header__c> soHeaderRecList = new List<Service_Order_Header__c>();
            List<Service_Order_Kit_Header__c> soKitHeaderList = new List<Service_Order_Kit_Header__c>();
            List<CO_Invoice_Header__c> coInvoiceHeaders = new List<CO_Invoice_Header__c>();
            List<CO_Invoice_Item__c> coInvoiceItems = new List<CO_Invoice_Item__c>();
            List<Vendor_Order_Line_Item__c> specialOrders = new List<Vendor_Order_Line_Item__c>();
            List<CO_Line_Item__c> coLineItems = new List<CO_Line_Item__c>();
            
            Map<Id, List<Service_Order_Line_Item__c>> soHeaderIdToSOLIListMap = new Map<Id, List<Service_Order_Line_Item__c>>();
            Map<Id, List<Service_Order_Kit_Header__c>> soHeaderIdToSOKHListMap = new Map<Id, List<Service_Order_Kit_Header__c>>();
            
            List<String> pinItems = new List<String>();
            String objectName = (Id.valueOf(recordId)).getSObjectType().getDescribe().getName();
            
            Map<Id, Service_Order_Line_Item__c> soliIdToRecMap = new Map<Id, Service_Order_Line_Item__c>();
            if(gridName == null || gridName.contains('soHeader')) {
                if(objectName == Constants.NAMESPACE + 'CO_Header__c') {
                    soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'CO_Header__c' => recordId});
                    soliIdToRecMap = new Map<Id, Service_Order_Line_Item__c>([Select Id, 
                    	(Select Id, Variance__c from Claim_Line_Items__r where Is_Variance__c = false AND Variance__c != 0) 
                    	from Service_Order_Line_Item__c where Service_Order_Header__r.CO_Header__c =: recordId]);
                } else if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                    soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => recordId});
                    soliIdToRecMap = new Map<Id, Service_Order_Line_Item__c>([Select Id, 
                    	(Select Id, Variance__c from Claim_Line_Items__r where Is_Variance__c = false AND Variance__c != 0) 
                    	from Service_Order_Line_Item__c where Service_Order_Header__c =: recordId]);
                }
            }
            //system.assert(false, soHeaderRecList);
            
            if(gridName == null || gridName.contains('pinItems')) {
                List<User> currentUserInfo = SOQLUtil.getCurrentUserInfo();
                if(currentUserInfo.size() > 0 && currentUserInfo[0].SO_Pinned_Info__c != null) {
                    pinItems = currentUserInfo[0].SO_Pinned_Info__c.split(',');
                }
            }
            
            Map<Id, List<Service_Order_Kit_Header__c>> soHeaderIdToSOKIListMap = new Map<Id, List<Service_Order_Kit_Header__c>>();
            
            if(gridName == null || gridName.contains('soItemGrid')) {
                if(objectName == Constants.NAMESPACE + 'CO_Header__c') {
                    soKitHeaderList = SOQLUtil.getSOKitHeaderByFieldName(new Map<String, String>{'Service_Order_Header__r.CO_Header__c' => recordId});
                } else if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                    soKitHeaderList = SOQLUtil.getSOKitHeaderByFieldName(new Map<String, String>{'Service_Order_Header__c' => recordId});
                }
                
                for(Service_Order_Kit_Header__c soKitHeaderRec : soKitHeaderList) {
                    List<Service_Order_Kit_Header__c> sokhList;
                    if(!soHeaderIdToSOKIListMap.containsKey(soKitHeaderRec.Service_Order_Header__c)) {
                        sokhList = new List<Service_Order_Kit_Header__c>();
                    } else {
                        sokhList = soHeaderIdToSOKIListMap.get(soKitHeaderRec.Service_Order_Header__c);
                    }
                    sokhList.add(soKitHeaderRec);
                    soHeaderIdToSOKIListMap.put(soKitHeaderRec.Service_Order_Header__c, sokhList);
                }
            }
            
            if(gridName == null || gridName.contains('checkOut')) {
                coInvoiceHeaders = SOQLUtil.getCOInvoiceHeaderByCOHeaderId(recordId);
                if(coInvoiceHeaders.size() > 0) {
                    coInvoiceItems = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coInvoiceHeaders[0].Id);
                }
            }
            
            if(gridName == null || gridName.contains('specialOrder')) {
                specialOrders = SOQLUtil.getSpecialOrderByCOHeaderId(recordId);
            }
            
            SOHeaderWrapper soHeaderObj = new SOHeaderWrapper(soHeaderRecList, pinItems, soHeaderIdToSOKIListMap, coInvoiceHeaders, coInvoiceItems, specialOrders);
            
            for(SOHeaderWrapper.SOWrapper soObj : soHeaderObj.SOList) {
             	for(SOHeaderWrapper.SOGrid soGridObj : soObj.SOGridItems) {
             		for(SOHeaderWrapper.SOLineItem soliObj : soGridObj.SOKH.SOLIList) {
             			if(soliIdToRecMap.containsKey(soliObj.Id) && soliIdToRecMap.get(soliObj.Id).Claim_Line_Items__r.size() > 0) {
			    			//soliObj.IsVariance = true;
			    		}
             		}
             	}
            }
            //system.assert(false, soHeaderObj);
            system.debug('###############\n\n' + soHeaderObj.SOList);
            return BPUtility.getEncodedString(System.JSON.serialize(soHeaderObj));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


         
    }
      /*
      *Name : getVendorOrderByVendorId
    * Desc : get vendor by id of the vendor
    * param : vendorId- String - id of vendor
    * return : Json  string list of vendor order
    */
     @RemoteAction 
    global static String getVendorOrderByVendorId(string vendorId){
        vendorId = BPUtility.getDecodedString(vendorId);
        try{
            List<Vendor_Order_Header__c> voHeaderList = SOQLUtil.getVOHeaderByFieldId(new Map<String, String> {'Vendor__c'=> vendorId} );
            List<Map<String, String>> vendorOrderListToJSON = new List<Map<String, String>>();
            
            for(Vendor_Order_Header__c voHeaderRec :  voHeaderList){
                Map<String, String> voJsonMap = new Map<String, String>();
                voJsonMap.put('VOId',voheaderrec.Id);
                voJsonMap.put('VOName',voheaderrec.Name);
                vendorOrderListToJSON.add(voJsonMap);
            }
            return BPUtility.getEncodedString(System.JSON.serialize(vendorOrderListToJSON)); 
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(''); 


     } 
     
    
    /**
    * Name: getSOMasterData
    * Desc: Method to get json string related to Service Header Order
    * @param:  (1) coHeaderId - String - Id of CO Header Record
    * @return: String - JSON String of SO Header Detail Record
    **/
    @RemoteAction 
    global static String getSOMasterData(String coHeaderId) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            List<CO_Header__c> coHeaderRec = SOQLUtil.getCOHeaderDetails(coHeaderId);
            List<Transaction_Type__c> ttList = SOQLUtil.getTransactionTypesWithProvider(new List<Id>());
            List<Account> providerList = SOQLUtil.getProviderList();
            
            List<Customer_Owned_Unit__c> couRecords = new List<Customer_Owned_Unit__c>();
            if(coHeaderRec.size() > 0 && coHeaderRec[0].Customer__c != null) {
                couRecords = SOQLUtil.getCOUListByCustomerId(coHeaderRec[0].Customer__c);
            }
            
            if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Category__c> internalDefaultCategoryList = [select Id, Name, Default__c from Category__c where Type__c = 'Internal Expense' AND Default__c = true
                                                                            AND Active__c = true];
            
            SOHeaderWrapper.SOMasterData masterDateObj = new SOHeaderWrapper.SOMasterData(ttList, couRecords, providerList, internalDefaultCategoryList);
            return BPUtility.getEncodedString(System.JSON.serialize(masterDateObj));  
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    * Name: saveSOHeaderInfo
    * Desc: Method Which saves CO Line Items in Database 
    * @param:   (1) coHeaderId - String - CO Header record Id
    *           (2) jSONString - String - JSON String of CO Line Items
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction
    global static String saveSOHeaderInfo(String coHeaderId, String jSONString) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        jSONString = BPUtility.getDecodedString(jSONString);
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            

            //System.assert(false, 'abc');
            SOHeaderWrapper.SOHeader soHeaderObj = (SOHeaderWrapper.SOHeader) System.JSON.deserialize(jSONString, SOHeaderWrapper.SOHeader.class);
            Service_Order_Header__c soHeaderRec = new Service_Order_Header__c();
            String soHeaderId = soHeaderObj.Id;
            soHeaderRec.Id = soHeaderObj.Id;
            soHeaderRec.Name__c = soHeaderObj.Name;
            //soHeaderRec.Total__c = soHeaderObj.Total;
            
            if(String.isNotBlank(soHeaderObj.COUId)) {
                soHeaderRec.Customer_Owned_Unit__c = soHeaderObj.COUId;
            }
            soHeaderRec.Transaction_Type__c = soHeaderObj.TransactionTypeId;
            soHeaderRec.Category__c = soHeaderObj.CategoryId;
            
            if(soHeaderObj.TransactionType == 'Internal' || soHeaderObj.TransactionType == 'Stock Unit') {
                if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Category__c> categoryList = [select Id, Name, Default__c from Category__c where Type__c = 'Internal Expense' AND Default__c = true
                                                                            AND Active__c = true];
                String defaultCategoryId;
                if(categoryList.size() > 0) {
                    defaultCategoryId = categoryList[0].Id;
                }
                soHeaderRec.Category__c = defaultCategoryId;
            }
            
            soHeaderRec.Provider__c = soHeaderObj.ProviderId;
            soHeaderRec.Estimated_Hours__c = soHeaderObj.EstimatedHours;
            if(soHeaderObj.PromisedBy != null) {
                DateTime promisedByDateTime = SOHeaderWrapper.getDateTimeFromString(soHeaderObj.PromisedBy);
                //system.assert(false, promisedByDateTime);
                if(promisedByDateTime >= system.Now()) {
                    soHeaderRec.Promised_By__c = promisedByDateTime;
                    //soHeaderRec.Estimated_Hours__c = ((soHeaderRec.Promised_By__c.getTime() - system.Now().getTime()) / (1000.0 * 60.0 * 60.0));
                    soHeaderRec.IsPromisedBy_AmPm__c = soHeaderObj.IsPromisedByAmPm;
                }
            }
            
            if(soHeaderObj.ManualConcern.size() == 0) {
                soHeaderRec.SO_Concern__c = null;
            }
            if(soHeaderObj.ManualCorrection.size() == 0) { 
                soHeaderRec.SO_Correction__c = null;
            }
            if(soHeaderObj.ManualCause.size() == 0) {
                soHeaderRec.SO_Cause__c = null;
            }
            
            for(String concernStr : soHeaderObj.ManualConcern) {
                concernStr = (concernStr.contains('\n')) ? concernStr.replaceAll('\n', '') : concernStr;
                if (soHeaderRec.SO_Concern__c == null) {
                    soHeaderRec.SO_Concern__c = '';
                }
                soHeaderRec.SO_Concern__c += concernStr + '\n';
            }
    
            for(String correctionStr : soHeaderObj.ManualCorrection) {
                correctionStr = (correctionStr.contains('\n')) ? correctionStr.replaceAll('\n', '') : correctionStr;
                if (soHeaderRec.SO_Correction__c == null) {
                    soHeaderRec.SO_Correction__c = '';
                }
                soHeaderRec.SO_Correction__c += correctionStr + '\n';
            }
            for (String causeStr : soHeaderObj.ManualCause) {
                causeStr = (causeStr.contains('\n')) ? causeStr.replaceAll('\n', '') : causeStr;
                if (soHeaderRec.SO_Cause__c == null) {
                    soHeaderRec.SO_Cause__c = '';
                }
                soHeaderRec.SO_Cause__c += causeStr + '\n';
            }
            
            
            //Start: Ticket#129: Added by Tarun 
             /*if(soHeaderObj.TransactionType == 'Customer' || soHeaderObj.TransactionType == 'Internal') {
                soHeaderRec.SO_Cause__c = null;
                soHeaderRec.SO_Correction__c = null;
            }*/
            //End: Ticket#129: Added by Tarun
            
            //system.assert(false, soHeaderRec);
            if(soHeaderRec.Id != null) {
                update soHeaderRec;
            }
            
            List<Service_Order_Header__c> soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => soHeaderId});
            if(soHeaderRecList.size() == 0) {
                return BPUtility.getEncodedString('{}');
            }
            
            return BPUtility.getEncodedString(System.JSON.serialize(new SOHeaderWrapper.SOHeader(soHeaderRecList[0])));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


        
        // return JSON
        //return getSOHeaderDetails(coHeaderId, null);
    }
    
    
    /**
    * Name: saveSOSignIn
    * Desc: Method Which saves CO Line Items in Database 
    * @param:   (1) coHeaderId - String - CO Header record Id
    *           (2) jSONString - String - JSON String of CO Line Items
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction
    global static String saveSOSignIn(String coHeaderId, String jSONString){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        jSONString = BPUtility.getDecodedString(jSONString);
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            SOHeaderWrapper.SOSignIn soSignInObj = (SOHeaderWrapper.SOSignIn) System.JSON.deserialize(jSONString, SOHeaderWrapper.SOSignIn.class);
            
            String soHeaderId = soSignInObj.Id;
            soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
            List<Service_Order_Header__c> soHeaderList = [select Status__c from Service_Order_Header__c where Id =: soHeaderId];
            if(soHeaderList.size() > 0) {
                Service_Order_Header__c soHeaderRec = soHeaderList[0];
                soHeaderRec.Odometer_on_Arrival__c = soSignInObj.Odometer;
                if(Constants.SOStatusToPriorityMap.get(soHeaderRec.Status__c) < 2) {
                    soHeaderRec.Status__c = 'Ready';
                }
                update soHeaderRec;
            }


            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    * Name: saveSOReviewInfo
    * Desc: Method Which saves CO Line Items in Database 
    * @param:   (1) coHeaderId - String - CO Header record Id
    *           (2) jSONString - String - JSON String of CO Line Items
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction
    global static String saveSOReviewInfo(String coHeaderId, String jSONString){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        jSONString = BPUtility.getDecodedString(jSONString);
        //system.assert(false, jSONString);
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

            SOHeaderWrapper.SOReview soReviewObj = (SOHeaderWrapper.SOReview) System.JSON.deserialize(jSONString, SOHeaderWrapper.SOReview.class);
            String soHeaderId = soReviewObj.Id;
            soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
            List<Service_Order_Header__c> soHeaderList = [select Status__c, Odometer_on_Departure__c, Odometer_on_Arrival__c, Notes_For_Customer__c from Service_Order_Header__c where Id =: soHeaderId]; 
            
            if(soHeaderList.size() > 0) {
                Service_Order_Header__c soHeaderRec = soHeaderList[0];
                if(soReviewObj.OdometerOnDeparture >= soHeaderRec.Odometer_on_Arrival__c) {
                    soHeaderRec.Odometer_on_Departure__c = soReviewObj.OdometerOnDeparture;
                } 
                
                if(soReviewObj.ManualNotes.size() == 0) {
                    soHeaderRec.SO_Notes_For_Customer__c = null;
                }
                
                //system.assert(false, soReviewObj.ManualNotes);
                String notesCustomer = '';
                for(String notesStr : soReviewObj.ManualNotes) {
                    notesStr = (notesStr.contains('\n')) ? notesStr.replaceAll('\n', '') : notesStr;
                    if (soHeaderRec.SO_Notes_For_Customer__c == null) {
                        soHeaderRec.SO_Notes_For_Customer__c = '';
                    }
                    notesCustomer += notesStr + '\n';
                }
                soHeaderRec.SO_Notes_For_Customer__c = notesCustomer;
                
                for(String notesStr : soReviewObj.KitHeaderNotes) {
                    notesStr = (notesStr.contains('\n')) ? notesStr.replaceAll('\n', '') : notesStr;
                    if (soHeaderRec.SO_Notes__c == null) {
                        soHeaderRec.SO_Notes__c = '';
                    }
                    soHeaderRec.SO_Notes__c += notesStr + '\n';
                }
                
                /*if(soHeaderRec.SO_Notes_For_Customer__c != null) {
                    if(soHeaderRec.SO_Notes__c == null) {
                        soHeaderRec.SO_Notes__c = '';
                    }
                    soHeaderRec.SO_Notes__c += soHeaderRec.SO_Notes_For_Customer__c + '\n';
                }*/
                
                
                if(soHeaderRec.SO_Notes__c != null && soHeaderRec.Odometer_on_Departure__c != null && Constants.SOStatusToPriorityMap.get(soHeaderRec.Status__c) < 5) {
                    soHeaderRec.Status__c = 'Reviewed';
                }
                
                update soHeaderRec;
            }
            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(null));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    * Name: saveSOName
    * Desc: Method Which saves CO Line Items in Database 
    * @param:   (1) coHeaderId - String - CO Header record Id
                (2) soName - String - name of Service Order
                (3) soId - String - id of Service Order
    * @return: String - service order record is update or not
    **/
    @RemoteAction
    global static String saveSOName(String coHeaderId, String soName, String soId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        soName = BPUtility.getDecodedString(soName);
        soId = BPUtility.getDecodedString(soId);
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            

            Service_Order_Header__c soHeaderRec = new Service_Order_Header__c();
            soHeaderRec.Id = soId;
            soHeaderRec.Name__c = soName;
            
            if(soHeaderRec.Id != null) {
                update soHeaderRec;
            }
            return BPUtility.getEncodedString('Saved');


        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    * Name: addCustomer
    * Desc: Methos which adds customer in CO Header Record
    * @param:   (1) coHeaderId - String - CO Header record Id
    *           (2) customerId - String - Id of customer Record
    * @return: String - JSON String of all CO Line Items of CO Header Record
    **/
    @RemoteAction
    global static String addCustomer(String COHeaderId, String customerId){
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        COHeaderId = BPUtility.getDecodedString(COHeaderId);
        customerId = BPUtility.getDecodedString(customerId);
        try{
            if(String.isBlank(COHeaderId)) {
                COHeaderId = BPUtility.getDecodedString(BPGlobalHeaderCtrl.createCustomerOrder());  
            }
            COHeaderId = BPUtility.escapeSingleQuotes(COHeaderId);
            List<CO_Invoice_Header__c> coInvoiceHeaderList = [select Id, (select Id, Amount__c from CO_Invoice_Payments__r) // Amount__c Added by richa
                                                                    from CO_Invoice_Header__c 
                                                                    where Invoice_Status__c = 'Active' AND CO_Header__c =:COHeaderId];
            
            /* Start: Added by richa */
            Decimal totalPayment = 0;
            if(coInvoiceHeaderList.size() > 0) {
                for(CO_Invoice_Payment__c payment: coInvoiceHeaderList[0].CO_Invoice_Payments__r) {
                    totalPayment += (payment.Amount__c != null ? payment.Amount__c : 0);
                }
            }
            /* End: Added by richa */
            
            if(coInvoiceHeaderList.size() > 0 && totalPayment != 0) { // coInvoiceHeaderList[0].CO_Invoice_Payments__r.size() > 0  Removed and totalPayment != 0 Added by richa
                throw new BlackPurlException(BlackPurlException.getErrorMessage('Customer Can\'t be changed since payment is already added', null));
            }
            
            CO_Header__c coHeaderRec = new CO_Header__c(Id = COHeaderId, Customer__c = customerId);
            if(String.isBlank(customerId)) {
                coHeaderRec.CO_Type__c = 'Cash Sale';
                coHeaderRec.Selling_Group__c = 'Cash Sale';
            } else {
                List<CO_Header__c> coHeaderList =[Select Id, CO_Type__c, Customer__c, (Select Id from CO_Invoice_Headers__r where Invoice_Status__c = 'Closed'), (Select Id, Work_Status__c, Customer_Owned_Unit__c from Service_Order_Headers__r) from CO_Header__c where Id = :COHeaderId];
                
                if(coHeaderList.size() > 0  && coHeaderList[0].CO_Type__c == 'Internal Service'){
                    throw new BlackPurlException(BlackPurlException.getErrorMessage('Cannot add customer to Internal Service CO', null));
                } else if(coHeaderList.size() > 0 && coHeaderList[0].CO_Invoice_Headers__r.size() > 0) {
                    throw new BlackPurlException(BlackPurlException.getErrorMessage(Label.Changing_Customer_After_Invoicing_Error_Message, null));
                }
                
                if(coHeaderList.size() > 0  && coHeaderList[0].CO_Type__c == 'Cash Sale'){
                    coHeaderRec.Selling_Group__c = 'Part Sale';
                }
                if(coHeaderList.size() > 0  && ((String.isNotBlank(coHeaderList[0].Customer__c)) && 
                                (coHeaderList[0].Customer__c != customerId)) && coHeaderList[0].Service_Order_Headers__r.size() > 0) {
                    for(Service_Order_Header__c soHeaderRec : coHeaderList[0].Service_Order_Headers__r) {
                        if(String.isNotBlank(soHeaderRec.Work_Status__c) && soHeaderRec.Work_Status__c == Constants.SERVICE_ORDER_STATUS_TO_CHECKOUT) {
                            throw new BlackPurlException(BlackPurlException.getErrorMessage(Label.Cannot_Change_Customer_With_Service_Job_Completed_Error_Message, null));
                        }
                        soHeaderRec.Customer_Owned_Unit__c = null;
                    }
                    update coHeaderList[0].Service_Order_Headers__r;
                }
                coHeaderRec.CO_Type__c = 'Customer';
            }
            updateCOPricingAndTax(new List<CO_Header__c> {coHeaderRec}, customerId, true);
            COService.updateCOPricingAndTaxOnKit(COHeaderId, customerId);
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderRec.Id), BPUtility.getEncodedString('coHeader,coLineItem,cou,user,specialOrder,coInvoiceHeader'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
            
    @RemoteAction
    global static String refreshCOPricingAndTax(String coHeaderId, String customerId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        customerId = BPUtility.getDecodedString(customerId);
        CO_Header__c coHeaderRec = new CO_Header__c(Id = coHeaderId, Customer__c = customerId);
        updateCOPricingAndTax(new List<CO_Header__c> {coHeaderRec}, customerId, true);
        COService.updateCOPricingAndTaxOnKit(coHeaderId, customerId);
        return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coHeader,coLineItem,cou,user,specialOrder,coInvoiceHeader'));
    }
    
    @RemoteAction
    global static String refreshCOPricingAndTaxOnKit(String coHeaderId, String customerId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        customerId = BPUtility.getDecodedString(customerId);
        COService.updateCOPricingAndTaxOnKit(coHeaderId, customerId);
        return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coHeader,coLineItem,cou,user,specialOrder,coInvoiceHeader'));
    }
             
    public static void updateCOPricingAndTax(List<CO_Header__c> COHeaderRecList, String customerId, Boolean isCalculatePLandTax){ 
            
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        try{
            CO_Header__c COHeaderRec;
            if(COHeaderRecList.size() > 0){
                COHeaderRec = COHeaderRecList[0];
            }
            COTriggerHelper.isCalculatePLandTax = isCalculatePLandTax; 
            update COHeaderRec;
            
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }

    /*
     * Added by nidhi 
      
    @RemoteAction
    global static String changeCOType(String COHeaderId, String COType){
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        COHeaderId = BPUtility.getDecodedString(COHeaderId);
        COType = BPUtility.getDecodedString(COType);
        try{
            COHeaderId = BPUtility.escapeSingleQuotes(COHeaderId);
            List<CO_Header__c> coHeaderList = [select Id, CO_Type__c, Customer__c from CO_Header__c where Id =:COHeaderId];
            //System.assert(false, 'COType  '+COType+ '  '+coHeaderList);
            if(coHeaderList.size() > 0){
                if(coHeaderList[0].CO_Type__c == 'Customer' && COType == 'Cash Sale' && coHeaderList[0].Customer__c != null){
                    coHeaderList[0].Customer__c = null;
                }
                coHeaderList[0].CO_Type__c = COType;
                update coHeaderList[0];
            }
            
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coHeader,coLineItem,cou,user,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }*/ 
    /**
    * Name: getCOLineItemByCOHeaderId
    * Desc: Method which give JSOn string of all CO Line Items Records
    * @param:  (1) coHeaderId - String - CO Header record Id
    * @return: String - JSON String of all CO Line Items of CO Header Record
    **/
    @RemoteAction
    global static String getCOLineItemByCOHeaderId(String coHeaderId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            List<CO_Line_Item__c> coLineItems = SOQLUtil.getCOLineItemByCOHeaderId(coHeaderId);
            List<COLineItem> coLineItemObjList = new List<COLineItem>();
            for(CO_Line_Item__c coLineItemRec : coLineItems) {
                coLineItemObjList.add(new COLineItem(coLineItemRec));
            }
            return BPUtility.getEncodedString(System.JSON.serialize(coLineItemObjList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }

    /**
    * Name: saveCOLineItem
    * Desc: Method Which saves CO Line Items in Database 
    * @param:   (1) coHeaderId - String - CO Header record Id
    *           (2) jSONString - String - JSON String of CO Line Items
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction
    global static String saveCOLineItem(String coHeaderId, String jSONString) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        jSONString = BPUtility.getDecodedString(jSONString);
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        try{
            if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(String.isBlank(COHeaderId)) {
                COHeaderId = BPUtility.getDecodedString(BPGlobalHeaderCtrl.createCustomerOrder());  
            }            
            List<COLineItem> coLineItemObjList = (List<COLineItem>) System.JSON.deserialize(jSONString, List<COLineItem>.class);
            List<CO_Line_Item__c> coLineItemListToUpdate = new List<CO_Line_Item__c>();
            Decimal previousQty;
            
            if(coLineItemObjList.size() > 0 && coLineItemObjList[0].CoLineItemId == null) {
                List<CO_Header__c> coHeaderList = [Select Id, Hide_Merchandise_Section__c, (Select Id from CO_Line_Items__r where Service_Order_Line_Item__c = null)
                                             from CO_Header__c where Id =: coHeaderId];
                
                if(coHeaderList.size() > 0 && coHeaderList[0].CO_Line_Items__r.size() == 0) {
                    List<SObject> sObjectListToInsert = addLinkedFee(coHeaderId, null, 'Merchandise');
                    if(sObjectListToInsert != null && sObjectListToInsert.size() > 0) {
                        coLineItemListToUpdate.addAll((List<CO_Line_Item__c>) sObjectListToInsert);
                    }
                    if(coHeaderList[0].Hide_Merchandise_Section__c) {
                        updateMerchSectionToDisplay(coHeaderId, false);
                    }
                }
            }
                
            for(COLineItem coLineItemObj : coLineItemObjList) {
                CO_Line_Item__c coLineItemRec = new CO_Line_Item__c();
                coLineItemRec.Qty__c = coLineItemObj.Qty ;
                coLineItemRec.Deal__c = coLineItemObj.DealId;
                if(isTaxIncludingPricing && String.isBlank(coLineItemObj.DealId)) {
                    if(coLineItemObj.Tax == null) {
                        coLineItemObj.Tax = 0;
                    }   
                    coLineItemRec.Price_When_Tax_Included__c = coLineItemObj.Price;
                    coLineItemRec.Price__c = (coLineItemObj.Price / (1 + (coLineItemObj.Tax / 100))).setScale(2, RoundingMode.HALF_UP);
                } else {
                    coLineItemRec.Price__c = coLineItemObj.Price;
                }
                coLineItemRec.CO_Header__c = coHeaderId;
                coLineItemRec.Part__c = (coLineItemObj.PartId != '') ? coLineItemObj.PartId : null;
                coLineItemRec.Fee__c = (coLineItemObj.FeeId != '') ? coLineItemObj.FeeId : null;
                
                /* START: Added By Tarun - #170 - 09/23/2016 */
                if(coLineItemRec.Fee__c != null) {
                    coLineItemRec.Item_Description__c = coLineItemObj.ItemDescription;
                }
                
                if(coLineItemObj.PartId != null && coLineItemObj.IsNonInventoryPart != null && coLineItemObj.IsNonInventoryPart) {
                    coLineItemRec.Status__c = 'In Stock';
                }
                
                if(coLineItemObj.isSpecialOrder == null) {
                    coLineItemRec.Special_Order__c = false; // Special Order Flag
                } else {
                    coLineItemRec.Special_Order__c = coLineItemObj.isSpecialOrder; // Special Order Flag
                }
                if(coLineItemObj.CoLineItemId != null) {
                    coLineItemRec.Id = coLineItemObj.CoLineItemId;
                    List<CO_Line_Item__c> coliList = [select Qty__c from CO_Line_Item__c where Id = :coLineItemObj.CoLineItemId];
                    if(coliList.size() > 0) {
                        previousQty = coliList[0].Qty__c;
                    }
                }                
                if(coLineItemObj.QtyCommitted != null && coLineItemObj.Qty > 0) {
                    if( coLineItemObj.QtyCommitted  > coLineItemObj.Qty) {
                        coLineItemRec.Qty_Committed__c = coLineItemObj.Qty;
                    } else {
                        coLineItemRec.Qty_Committed__c = coLineItemObj.QtyCommitted;    
                    }
                }
                coLineItemListToUpdate.add(coLineItemRec);
                
                // Create one Extra line for Env Fee
                if(coLineItemObj.CoLineItemId == null && coLineItemObj.PartId != null) {
                    CO_Line_Item__c envFeeLineItemRec = createEnvFeeLineItem(coLineItemObj.PartId, coHeaderId);
                    if(envFeeLineItemRec.Fee__c != null) {
                        coLineItemListToUpdate.add(envFeeLineItemRec);
                    }
                }
            }
            
            if(coLineItemListToUpdate.size() > 0) {
                upsert coLineItemListToUpdate;
                String dealId = coLineItemListToUpdate[0].Deal__c;
                Set<String> coliIdSet = new Set<String>();
                for(CO_Line_Item__c coliRec : coLineItemListToUpdate) {
                    coliIdSet.add(coliRec.Id);
                }
                if(String.isNotBlank(coLineItemObjList[0].CoLineItemId)) {
                    if(previousQty != coLineItemListToUpdate[0].Qty__c) {
                        createDealUnresolvedFulfillment(new List<String>(coliIdSet), dealId, Constants.UNRESOLVED_FULFILLMENT_TYPE_UPDATED);
                    }
                } else {
                    createDealUnresolvedFulfillment(new List<String>(coliIdSet), dealId, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);
                }
                
                if(String.isNotBlank(dealId)) {
                    return getDealDetails(BPUtility.getEncodedString(dealId), BPUtility.getEncodedString('dealUnresolvedFulfillmentAndDealFulfillment'));
                }
            }
            
            // return JSON
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coHeader,coLineItem,user,coInvoiceHeader,specialOrder'));
        }catch(Exception e){

            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    private static CO_Line_Item__c createEnvFeeLineItem(String partId, String coHeaderId) {
        CO_Line_Item__c envFeeLineItemRec = new CO_Line_Item__c();
        List<Part__c> partList = [select Part_Number__c, Enviro_Fee__c, Enviro_Fee_Code__c, Enviro_Fee_Code__r.Code__c, 
                                        Enviro_Fee_Code__r.Description__c from Part__c where Id =: partId];
        if(partList.size() > 0 && partList[0].Enviro_Fee__c != null && partList[0].Enviro_Fee_Code__c != null) {
            envFeeLineItemRec.Fee__c = partList[0].Enviro_Fee_Code__c;
            envFeeLineItemRec.Item_Code__c = partList[0].Enviro_Fee_Code__r.Code__c;
            envFeeLineItemRec.Item_Description__c = partList[0].Part_Number__c + ' ' + partList[0].Enviro_Fee_Code__r.Description__c;
            envFeeLineItemRec.CO_Header__c = coHeaderId;
            envFeeLineItemRec.Price__c = partList[0].Enviro_Fee__c;
            envFeeLineItemRec.Qty__c = envFeeLineItemRec.Qty_Committed__c = 1;
            if(GeneralConfiguration.getTaxIncludingPricing()) {
                envFeeLineItemRec.Price_When_Tax_Included__c = partList[0].Enviro_Fee__c;
            }
            envFeeLineItemRec.Is_Environmental_Fee__c = true;
        }
        return envFeeLineItemRec;
    }
    
    private static Option_Fee__c createEnvFeeLineItemInDealSection(String partId, String dealId, String dealItemId) {
        Option_Fee__c envFeeLineItemRec = new Option_Fee__c();
        List<Part__c> partList = [select Part_Number__c, Enviro_Fee__c, Enviro_Fee_Code__c, Enviro_Fee_Code__r.Code__c, 
                                            Enviro_Fee_Code__r.Description__c from Part__c where Id =: partId];
        if(partList.size() > 0 && partList[0].Enviro_Fee__c != null && partList[0].Enviro_Fee_Code__c != null) {
            envFeeLineItemRec.Fee__c = partList[0].Enviro_Fee_Code__c;
            envFeeLineItemRec.Deal__c = dealId;
            envFeeLineItemRec.Deal_Item__c = dealItemId;  
            envFeeLineItemRec.Price__c = partList[0].Enviro_Fee__c;
            envFeeLineItemRec.Qty__c = 1;
            envFeeLineItemRec.Price_When_Tax_Included__c = envFeeLineItemRec.Price__c;
            envFeeLineItemRec.Item_Code__c = partList[0].Enviro_Fee_Code__r.Code__c;
            envFeeLineItemRec.Item_Description__c = partList[0].Part_Number__c + ' ' + partList[0].Enviro_Fee_Code__r.Description__c;
            envFeeLineItemRec.Price__c = partList[0].Enviro_Fee__c;
            if(GeneralConfiguration.getTaxIncludingPricing()) {
                envFeeLineItemRec.Price_When_Tax_Included__c = partList[0].Enviro_Fee__c;
            }
            envFeeLineItemRec.Is_Environmental_Fee__c = true;
        }
        return envFeeLineItemRec;
    }
    
    /**
    * Name: deleteCOLineItem
    * Desc: Method to delete CO Line items From database
    * @param:   (1) coLineItemId - String - CO Line Item Id hich is to be deleted.
    *           (2) coHeaderId - String - CO Header record Id
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction
    global static String deleteCOLineItem(String coLineItemId, String coHeaderId){
        coLineItemId = BPUtility.getDecodedString(coLineItemId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            String dealId = MerchandiseService.deleteCOLI(coLineItemId);
            if(String.isNotBlank(dealId)) {
            return getDealDetails(BPUtility.getEncodedString(dealId), BPUtility.getEncodedString('dealUnresolvedFulfillmentAndDealFulfillment'));
            }
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coHeader,coLineItem,coInvoiceHeader,user,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }

    /**
     * Name: getCODepositByCOHeaderId
     * Desc: Method to get CO Deposits from CO Header Record Id
     * @param:  (1) coHeaderId - String - CO Header record Id
     * @return: String - JSON String of all CO Deposits 
     **/
    @RemoteAction
    global static String getCODepositByCOHeaderId(String coHeaderId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            List<CO_Deposit__c> coDeposits = SOQLUtil.getCODepositByCOHeaderId(coHeaderId);
            List<CODeposit> coDepositObjList = new List<CODeposit>();
            coDeposits = COHeaderWrapper.sortCODeposit(coDeposits);
            for(CO_Deposit__c coDepositRec : coDeposits) {
                coDepositObjList.add(new CODeposit(coDepositRec));
            }
            return BPUtility.getEncodedString(System.JSON.serialize(coDepositObjList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }

    /**
    * Name: saveCODeposit
    * Desc: Method to save CO Deposits in database
    * @param:  (1) jsonString - String - jsonString of CO Deposits which is to be saved.
    * @return: String - JSON String of all CO Deposits 
    **/
    @RemoteAction
    global static String saveCODeposit(String jsonString){
        jsonString = BPUtility.getDecodedString(jsonString);
        try{
            String COHeaderId = COService.saveCODeposit(jsonString);
            return getCODepositByCOHeaderId(BPUtility.getEncodedString(COHeaderId));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
     * Name: getCOInvoicePaymentsByCOInvoiceHedaerId
     * Desc: Method to get All CO Invoice Payments from CO Header Id
     * @param:  (1) COInvoiceHeaderId - String - CO Invoice Header Id
     * @return: String - JSON String of all CO Invoice Payments
     **/
    @RemoteAction
    global static String getCOInvoicePaymentsByCOInvoiceHedaerId(String COInvoiceHeaderId){
        COInvoiceHeaderId = BPUtility.getDecodedString(COInvoiceHeaderId);
        try{
            List<CO_Invoice_Payment__c> coInvoicePayments = SOQLUtil.getCOInvoicePaymentsByCOInvoiceHeaderId(COInvoiceHeaderId);
            List<COInvoicePayment> coInvoicePaymentList = new List<COInvoicePayment>();
            coInvoicePayments = COHeaderWrapper.sortCOPayment(coInvoicePayments);
            for(CO_Invoice_Payment__c coInvoicePaymentRec : coInvoicePayments) {
                coInvoicePaymentList.add(new COInvoicePayment(coInvoicePaymentRec));
            }
            return BPUtility.getEncodedString(System.JSON.serialize(coInvoicePaymentList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
     * Name: saveCOInvoicePayment
     * Desc: Method to save CO Invoice Payment in database
     * @param:  (1) jsonString - String - jsonString of all CO Invoice Payments Records
     * @return: String - JSON String of all CO Invoice Payments
    **/
    @RemoteAction
    global static String saveCOInvoicePayment(String jsonString){
        jsonString = BPUtility.getDecodedString(jsonString);
        try{
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsCreateable('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            
            List<COInvoicePayment> coInvoicePaymentsObjList = COInvoicePayment.parse(jsonString);
            List<CO_Invoice_Payment__c> coInvoicePaymentListToUpdate = new List<CO_Invoice_Payment__c>();
            List<Id> reversePaymentIds = new List<Id>();
            //Added by Nidhi
            List<CO_Invoice_Header__c> coInvHeaderList = new List<CO_Invoice_Header__c>();
            if(coInvoicePaymentsObjList.size() > 0) {
                coInvHeaderList = [Select CO_Header__c from CO_Invoice_Header__c where Id =: coInvoicePaymentsObjList[0].COInvoiceHeaderId];
            }
            List<CO_Deposit__c> coDepositsListToInsert = new List<CO_Deposit__c>();
            
            for(COInvoicePayment coInvoicePaymentObj : coInvoicePaymentsObjList) {
                if(coInvoicePaymentObj.PaymentMethod != null && (coInvoicePaymentObj.PaymentMethod == Constants.USE_DEPOSIT || coInvoicePaymentObj.PaymentMethod =='Use Deal Deposit')) {
                    CO_Deposit__c coDepositRec = new CO_Deposit__c();
                    coDepositRec.Payment_Method__c = 'Invoice';
                    coDepositRec.CO_Invoice_Header__c = coInvoicePaymentObj.COInvoiceHeaderId;
                    coDepositRec.CO_Header__c = coInvHeaderList[0].CO_Header__c;
                    coDepositRec.Amount__c = -1 * coInvoicePaymentObj.Amount;
                    if(coInvoicePaymentObj.DealId !=null ){
                        coDepositRec.Deal__c =coInvoicePaymentObj.DealId; 
                    }
                    coDepositsListToInsert.add(coDepositRec);
                }
            }
            if(coDepositsListToInsert.size() > 0) {
                if(AccessControl.ifObjectFieldIsCreateable('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                insert coDepositsListToInsert;
            }
             
            for(COInvoicePayment coInvoicePaymentObj : coInvoicePaymentsObjList) {
                if(coInvoicePaymentObj.PaymentMethod != 'Cash Rounding'){
                    CO_Invoice_Payment__c coInvoicePaymentRec = new CO_Invoice_Payment__c();
                    coInvoicePaymentRec.Amount__c = coInvoicePaymentObj.Amount ;
                    coInvoicePaymentRec.Payment_Method__c = coInvoicePaymentObj.PaymentMethod ;
                    coInvoicePaymentRec.CO_Invoice_Header__c = coInvoicePaymentObj.COInvoiceHeaderId;
                    if(coInvoicePaymentObj.IsReverse != null) {
                        coInvoicePaymentRec.Is_Reverse__c = coInvoicePaymentObj.IsReverse; // 05/11/2016
                    }
                    
                    if(coInvoicePaymentObj.COInvoicePaymentId != null) {
                        coInvoicePaymentRec.Id = coInvoicePaymentObj.COInvoicePaymentId ;
                    }
                    if(coInvoicePaymentObj.ReverseLink != null) {
                        coInvoicePaymentRec.Reverse_Link__c = coInvoicePaymentObj.ReverseLink;
                        coInvoicePaymentRec.Reverse_Payment_From__c = coInvoicePaymentObj.ReverseLink;
                        reversePaymentIds.add(coInvoicePaymentObj.ReverseLink);
                    }
                    coInvoicePaymentListToUpdate.add(coInvoicePaymentRec);
                }
                
            }
            if(coInvoicePaymentListToUpdate.size() > 0) {
                if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                
                upsert coInvoicePaymentListToUpdate;
            }
            if(reversePaymentIds.size() > 0) {
                List<CO_Invoice_Payment__c> roundingPaymentList = [select Id, Amount__c, Cash_Rounding_Payment__c,
                                                                     CO_Invoice_Header__c, Is_Reverse__c, 
                                                                     Payment_Method__c, Reverse_Link__c, 
                                                                     Reverse_Payment_From__c  from CO_Invoice_Payment__c 
                                                                     where Cash_Rounding_Payment__c IN :reversePaymentIds];
                if(roundingPaymentList.size() > 0){
                    CO_Invoice_Payment__c clonedRoundingPayment = roundingPaymentList[0].clone(false, true);
                    clonedRoundingPayment.Is_Reverse__c = true;
                    clonedRoundingPayment.Reverse_Link__c = roundingPaymentList[0].Id;  
                    clonedRoundingPayment.Reverse_Payment_From__c = roundingPaymentList[0].Id;
                    if(roundingPaymentList[0].Amount__c != null){
                        clonedRoundingPayment.Amount__c = -1 * roundingPaymentList[0].Amount__c;    
                    }
                    insert clonedRoundingPayment;   
                    roundingPaymentList[0].Reverse_Link__c = clonedRoundingPayment.Id;
                    roundingPaymentList[0].Reverse_Payment_From__c = clonedRoundingPayment.Id;
                    update roundingPaymentList;
                }   
                
            }
            
            List<CO_Invoice_Payment__c> coInvoicePaymentListForRounding = new List<CO_Invoice_Payment__c>();
            for(COInvoicePayment coInvoicePaymentObj : coInvoicePaymentsObjList) {
                if(coInvoicePaymentObj.PaymentMethod == 'Cash Rounding' && coInvoicePaymentObj.Amount != 0){
                    CO_Invoice_Payment__c coInvoicePaymentRec = new CO_Invoice_Payment__c();
                    coInvoicePaymentRec.Amount__c = coInvoicePaymentObj.Amount ;
                    coInvoicePaymentRec.Payment_Method__c = coInvoicePaymentObj.PaymentMethod ;
                    coInvoicePaymentRec.CO_Invoice_Header__c = coInvoicePaymentObj.COInvoiceHeaderId;
                    if(coInvoicePaymentObj.IsReverse != null) {
                        coInvoicePaymentRec.Is_Reverse__c = coInvoicePaymentObj.IsReverse; // 05/11/2016
                    }
                    if(coInvoicePaymentObj.COInvoicePaymentId != null) {
                        coInvoicePaymentRec.Id = coInvoicePaymentObj.COInvoicePaymentId ;
                    }
                    if(coInvoicePaymentObj.ReverseLink != null) {
                        coInvoicePaymentRec.Reverse_Link__c = coInvoicePaymentObj.ReverseLink;
                        coInvoicePaymentRec.Reverse_Payment_From__c = coInvoicePaymentObj.ReverseLink;
                        reversePaymentIds.add(coInvoicePaymentObj.ReverseLink);
                    }
                    coInvoicePaymentRec.Cash_Rounding_Payment__c = coInvoicePaymentListToUpdate[0].Id;
                    coInvoicePaymentListForRounding.add(coInvoicePaymentRec);
                }
            }
            if(coInvoicePaymentListForRounding.size() > 0){
                upsert coInvoicePaymentListForRounding;
            }
            
            if(reversePaymentIds.size() > 0) {
                if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<CO_Invoice_Payment__c> COInvoicePaymentsToBeReversed = [select Id, Reverse_Link__c from CO_Invoice_Payment__c where Id IN :reversePaymentIds];
                for(CO_Invoice_Payment__c coInvoicePaymentRec : COInvoicePaymentsToBeReversed) {
                    coInvoicePaymentRec.Reverse_Link__c = coInvoicePaymentListToUpdate[0].Id;
                    coInvoicePaymentRec.Reverse_Payment_From__c = coInvoicePaymentListToUpdate[0].Id;
                }
                if(COInvoicePaymentsToBeReversed.size() > 0) {
                    if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update COInvoicePaymentsToBeReversed;
                }
            }           
            String COInvoiceHeaderId;
            if(coInvoicePaymentsObjList.size() > 0) {
                COInvoiceHeaderId = coInvoicePaymentsObjList[0].COInvoiceHeaderId;
            } else {
                COInvoiceHeaderId = null;
            }
            if((coInvHeaderList.size() > 0) && (coInvHeaderList[0].CO_Header__c != null)) {
                return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coInvHeaderList[0].CO_Header__c), BPUtility.getEncodedString('coDeposit, coInvoiceHeader, user'));
            } else {
                return getCOInvoicePaymentsByCOInvoiceHedaerId(BPUtility.getEncodedString(COInvoiceHeaderId));
            }
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
     * Name: getCOInvoiceItemsByCOInvoiceHeaderId
     * Desc: Method to get all CO Invoice Items from Co Invoice Header Id
     * @param:  (1) coInvoiceHeaderId - String - CO Invoice Header Id
     * @return: String - JSON String of all CO Invoice Item List
    **/
    @RemoteAction
    global static String getCOInvoiceItemsByCOInvoiceHeaderId(String coInvoiceHeaderId){
        coInvoiceHeaderId = BPUtility.getDecodedString(coInvoiceHeaderId);
        try{
            List<CO_Invoice_Item__c> coInvoiceItems = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coInvoiceHeaderId);
            List<COInvoiceItem> coInvoiceItemList = new List<COInvoiceItem>();
            for(CO_Invoice_Item__c coInvoiceItemRec : coInvoiceItems) {
                coInvoiceItemList.add(new COInvoiceItem(coInvoiceItemRec));
            }
            return BPUtility.getEncodedString(System.JSON.serialize(coInvoiceItemList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
     * Name: getCOInvoiceItemsByCOInvoiceHeaderId
     * Desc: 
     * @param:  
     * @return: 
    **/
    /*private static List<COInvoiceItemWrapper> getCOInvoiceItemWrapperList(String coHeaderId, String coInvoiceHeaderId){
        //List<CO_Invoice_Item__c> coInvoiceItems = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coInvoiceHeaderId);
        List<CO_Line_Item__c> coLineItems = [select Qty_Committed__c, Price__c, Item_ID__c, Part__c, Part__r.Name, 
                                                (select Id, CO_Invoice_Header__c from CO_Invoice_Items__r Where CO_Invoice_Header__c = :coInvoiceHeaderId) 
                                                 from CO_Line_Item__c where CO_Header__c = :coHeaderId];
        
        Map<String, List<Sobject>> coLineItemIdToCOInvoiceItemsMap = new Map<String, List<Sobject>>();
        for(CO_Line_Item__c coLineItemRec : coLineItems) {
            List<Sobject> coInvoiceItemsList = new List<Sobject>();
            for(CO_Invoice_Item__c coInvoiceItem : coLineItemRec.CO_Invoice_Items__r) {
                coInvoiceItemsList.add(coInvoiceItem);
            }
            coLineItemIdToCOInvoiceItemsMap.put(coLineItemRec.Id, coInvoiceItemsList);
        }
        List<COInvoiceItemWrapper> coInvoiceItemWrapperList = new List<COInvoiceItemWrapper>();
        for(CO_Line_Item__c coLineItemRec : coLineItems) {
            if(coLineItemRec.Qty_Committed__c > 0) {
                coInvoiceItemWrapperList.add(new COInvoiceItemWrapper(coLineItemRec, coLineItemIdToCOInvoiceItemsMap));
            }
        }
        //system.assert(false, coInvoiceItemWrapperList);
        return coInvoiceItemWrapperList;
    }*/
    
    /**
     * Name: updateCOInvoiceItem
     * Desc: Method to update CO Invoice Item 
     * @param:  (1) isActive - Boolean - Is Invoice Item be added in CO Invoice Header
     *          (2) jsonString - String - jSONString of CO Invoice Items
     *          (3) b - String - Arbitary Parameter
     * @return: String - JSON String of all CO Invoice Item List
     * update by :Subhrant 06/04/2016
    **/
     @RemoteAction
    global static String updateCOInvoiceItem(String jsonString, String coHeaderId){
        jsonString = BPUtility.getDecodedString(jsonString);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            List<COInvoiceItem> coInvoiceItemObjList = (List<COInvoiceItem>) System.JSON.deserialize(jsonString, List<COInvoiceItem>.class);
            List<CO_Invoice_Item__c> coInvoiceItemListToUpdate = new List<CO_Invoice_Item__c>();
                

            for(COInvoiceItem coIIObj : coInvoiceItemObjList) {
                CO_Invoice_Item__c coInvoiceItemRec = new CO_Invoice_Item__c(Id = coIIObj.COInvoiceItemId);
                if(coIIObj.IsActive != null) {
                    coInvoiceItemRec.IsActive__c = coIIObj.IsActive;
                } else {

                    coInvoiceItemRec.IsActive__c = false;
                }

                coInvoiceItemListToUpdate.add(coInvoiceItemRec);
            }
           
            if(coInvoiceItemListToUpdate.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update coInvoiceItemListToUpdate;
            }
            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('checkOut'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }  
         
         //<> coInvoiceItems = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coInvoiceItemRec.CO_Invoice_Header__c);
        //return getCOInvoiceItemsByCOInvoiceHeaderId(coInvoiceItemObj.COInvoiceHeaderId);
    }
    
    /**
     * Name: getInvoiceHistoryWrapperList
     * Desc: Method to get Invoice History Wrapper List
     * @param:  (1) coInvoiceHeaderId - String - Id of Co Invoice Header Record
     * @return:  String - JSON String of CO Invoice History List
    **/
    @RemoteAction
    global static String getInvoiceHistoryWrapperList(String coInvoiceHeaderId){
        coInvoiceHeaderId = BPUtility.getDecodedString(coInvoiceHeaderId);
        try{
            CO_Invoice_Header__c coInvoiceHeader = (CO_Invoice_Header__c)SOQLUtil.getCOInvoiceHeaderRecord(coInvoiceHeaderId);
            List<CO_Invoice_Item__c> coInvoiceItems = SOQLUtil.getCOInvoiceItemsByCOInvoiceHeaderId(coInvoiceHeaderId);
            List<COInvoiceHistoryWrapper> coInvoiceHistoryWrapperList = new List<COInvoiceHistoryWrapper>();
            coInvoiceHistoryWrapperList.add(new COInvoiceHistoryWrapper(coInvoiceHeader, coInvoiceItems));
            return BPUtility.getEncodedString(System.JSON.serialize(coInvoiceHistoryWrapperList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    Name:closedOrderAction
    
    **/
    @RemoteAction
    global static String closedOrderAction(String coInvoiceItemsJsonString, String coHeaderId, String currentCheckoutType){
        String currentFormattedDate = BPutility.getFormatedDateTime(datetime.newinstance(System.now().date(), System.now().time()));
        return closeOrder(coInvoiceItemsJsonString, coHeaderId, currentCheckoutType, currentFormattedDate);
    }
    
    public static String closeOrder(String coInvoiceItemsJsonString, String coHeaderId, String currentCheckoutType, String invoiceDate){
        try{
            COService.finalizeOrder(coInvoiceItemsJsonString, coHeaderId, currentCheckoutType, invoiceDate);
            return getCOHeaderDetails(coHeaderId);
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    public static void updateSOHeaderList(Set<Id> soHeaderIdSet, String closedInvoiceId) {
        if(soHeaderIdSet.size() > 0) {
            List<Service_Order_Header__c> soHeaderList = new List<Service_Order_Header__c>();
            for(Id soId : soHeaderIdSet) {
                soHeaderList.add(new Service_Order_Header__c(Id = soId, Work_Status__c = 'Invoiced', Invoice_Number__c = closedInvoiceId));
            }
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update soHeaderList;
            COService.updateMileageOnUnitsWithSoOdometerOut(soHeaderIdSet);
        }
    }
    /**
     * Name: closedInvoiceAction
     * Desc: Method to do calculation after Closed Invoice Button click.
     * @param:  (1) coInvoiceItemsJsonString - String - json string of coInvoice items
     *          (2) coHeaderId -String - id of coHeader
     * @return:  String - JSON String of CO Invoice History List
    **/
 @RemoteAction
  global static String closedInvoiceAction(String coInvoiceItemsJsonString, String coHeaderId, String currentCheckoutType){
        String currentFormattedDate = BPutility.getFormatedDateTime(datetime.newinstance(System.now().date(), System.now().time()));
        return closeInvoice(coInvoiceItemsJsonString, coHeaderId, currentCheckoutType, currentFormattedDate);
    }
    
    public static String closeInvoice(String coInvoiceItemsJsonString, String coHeaderId, String currentCheckoutType, String invoiceDateString){
        try{
            String response = COService.finalizeInvoice(coInvoiceItemsJsonString, coHeaderId, currentCheckoutType, invoiceDateString);
            if(response == null) {
                return BPUtility.getEncodedString('');
            }
            return getCOHeaderDetails(coHeaderId);
            
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));           
        }
    }
    
       /**
     * Name: UpdateOptionFeeStatus
     * Desc: set Status of deal and dealitems
     * @param:  
     *          (2) coHeaderId -String - id of coHeader
     * @return:  String - JSON String of CO Invoice History List
    **/
     public static String UpdateOptionFeeStatus(String coHeaderId) {
        List<CO_Invoice_Item__c> DealInvoiceListToUpdate = new  List<CO_Invoice_Item__c>();
        Boolean isDealFullFilled = updateOptionFeeStatusAndDealStatus(coHeaderId);
        if(isDealFullFilled){
            List<CO_Invoice_Item__c> DealInvoiceItemList = new List<CO_Invoice_Item__c>([select Id, Deal__r.Status__c, isActive__c,Is_Invoiceable__c from CO_Invoice_Item__c where 
                                                            Deal__c  = : dealIdToDealMap.KeySet() AND Deal_Finance__c = null]);
            for(CO_Invoice_Item__c InvoiceItem : DealInvoiceItemList) {
                if(GeneralConfiguration.isLoadNewCustomerOrder()) {
                    if(String.isNotBlank(InvoiceItem.Deal__r.Status__c) && InvoiceItem.Deal__r.Status__c == 'Approved') {
                        InvoiceItem.isActive__c = true;
                        InvoiceItem.Is_Invoiceable__c = true;
                        DealInvoiceListToUpdate.add(InvoiceItem);
                    }
                } else {
                    InvoiceItem.isActive__c = true;
                    InvoiceItem.Is_Invoiceable__c = true;
                    DealInvoiceListToUpdate.add(InvoiceItem);
                }
            }                                                           
        } else {
            if(dealIdToDealMap.size() > 0) {
                String dealId;
                for(String dealRecordId : dealIdToDealMap.keyset()) {
                    dealId = dealRecordId;
                }
                List<CO_Invoice_Item__c> dealInvoiceItemList = [SELECT Deal__r.Status__c, isActive__c, Is_Invoiceable__c FROM CO_Invoice_Item__c 
                                                            WHERE Deal__c =: dealId AND Deal_Finance__c = null];
	            Map<String, Boolean> optionNameToOptionValueMap = isDealInvoiceable(dealId);
	            dealInvoiceItemList[0].Is_Invoiceable__c = optionNameToOptionValueMap.get('Invoiceable');
	            dealInvoiceItemList[0].isActive__c = optionNameToOptionValueMap.get('Active');
	            dealInvoiceListToUpdate.add(dealInvoiceItemList[0]);
            }
        }
        
        if(DealInvoiceListToUpdate.size() > 0 ){
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update DealInvoiceListToUpdate;
        } 
        return 'success';
     } 
     
     private static Map<Id, Deal__c> dealIdToDealMap; 
     
     public static Boolean updateOptionFeeStatusAndDealStatus(String coHeaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); } 
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Finance__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }   
        
        dealIdToDealMap = new Map<Id,Deal__c>([select Id, Status__c, Is_Deal_Fulfilled__c, (Select Id, Deal_Item__c from Deal_Unresolved_Fulfillments__r 
        where Is_Resolved__c = false) From Deal__c where  CO_Header__c =: coHeaderId]);
    
        List<Deal_Item__c> DealItemList = [select Id, Deal__c, Option_And_Fee_Status__c, (select Id, Status__c, Part__c, Labour_Code__c, Product__c, Product__r.Type__c 
            from Options_Fees__r) From Deal_Item__c where  Deal__c =: dealIdToDealMap.KeySet()];
    
        List<Deal_Item__c> DealItemListToUpdate = new List<Deal_Item__c>();
        List<Deal__c> DealListToUpdate = new List<Deal__c>(); 
            
        Set<String> dealItemOrDealIdHavingUnresolvedFulfillmentSet = new Set<String>();
        for(Deal__c dealRec : dealIdToDealMap.values()) {
            for(Deal_Unresolved_Fulfillment__c unrslvedFulfillmentRec : dealRec.Deal_Unresolved_Fulfillments__r) {
                if(String.isNotBlank(unrslvedFulfillmentRec.Deal_Item__c)) {
                    dealItemOrDealIdHavingUnresolvedFulfillmentSet.add(unrslvedFulfillmentRec.Deal_Item__c);
                } else {
                    dealItemOrDealIdHavingUnresolvedFulfillmentSet.add(dealRec.Id);
                }
            }
        }
            
        for(Deal_Item__c dealItemRec : DealItemList ){
            boolean isFullFilled = true; 
            for(Option_Fee__c  optionFeeRec  : dealItemRec.Options_Fees__r ){
                if(optionFeeRec.Status__c != 'Fulfilled'  && (optionFeeRec.Labour_Code__c != null || optionFeeRec.Part__c != null || (optionFeeRec.Product__c != null && optionFeeRec.Product__r.Type__c == 'Sublet'))){
                    isFullFilled = false;
                    break;
                }
            }
            if(isFullFilled && dealItemOrDealIdHavingUnresolvedFulfillmentSet.contains(dealItemRec.Id)) {
                isFullFilled = false;
            }
            if(isFullFilled){
                dealItemRec.Option_And_Fee_Status__c= 'Fulfilled';
                DealItemListToUpdate.add(dealItemRec);
            } else if(dealItemRec.Option_And_Fee_Status__c == 'Fulfilled') {
                dealItemRec.Option_And_Fee_Status__c = 'Committed';
                DealItemListToUpdate.add(dealItemRec);
            }
        }
            
        Boolean isDealFullFilled = false;
        for(Deal_Item__c DealItemRec: DealItemList){
                if(DealItemRec.Option_And_Fee_Status__c !='Fulfilled'){
                    isDealFullFilled = false;
                    break;
                }else{
                    isDealFullFilled =true;
                }
        }
            
        if(isDealFullFilled && !GeneralConfiguration.isLoadNewCustomerOrder()) {
        Map<Id, Deal__c> dealIdToFinanceStatus = new Map<Id,Deal__c>([Select Id, Type__c, (Select Status__c from Deal_Finances__r) from Deal__c where Id In :dealIdToDealMap.keySet()]);
            for( Deal__c dealRec : dealIdToDealMap.values() ){
                if(dealIdToFinanceStatus.containsKey(dealRec.Id) && dealIdToFinanceStatus.get(dealRec.Id).Type__c == 'Financed' && dealIdToFinanceStatus.get(dealRec.Id).Deal_Finances__r.size() > 0 && dealIdToFinanceStatus.get(dealRec.Id).Deal_Finances__r[0].Status__c != 'Paid') {        //If condition added by nidhi -09/12-2016
                isDealFullFilled = false;
                }
            }
        }
            
	    for( Deal__c dealRec : dealIdToDealMap.values() ){
	        if(isDealFullFilled && dealItemOrDealIdHavingUnresolvedFulfillmentSet.contains(dealRec.Id)) {
	            isDealFullFilled = false;
	        }
	        
	        if(GeneralConfiguration.isLoadNewCustomerOrder()) {
	            if(isDealFullFilled) {
	                dealRec.Is_Deal_Fulfilled__c = true;
	                DealListToUpdate.add(dealRec);
	            } else if(dealRec.Is_Deal_Fulfilled__c) {
	                dealRec.Is_Deal_Fulfilled__c = false;
	                DealListToUpdate.add(dealRec);
	            }
	        } else {
	            if(isDealFullFilled) {
	                dealRec.status__c = 'Fulfilled';
	                DealListToUpdate.add(dealRec);
	            } else if(dealRec.status__c == 'Fulfilled') {
	                dealRec.status__c = 'In Progress';
	                DealListToUpdate.add(dealRec);
	            }
	        }
        }
        
        if(DealItemListToUpdate.Size() > 0 ){
            if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update DealItemListToUpdate;
        }
        
        if(DealListToUpdate.size() > 0){
             if(AccessControl.ifObjectFieldIsUpdateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update DealListToUpdate;
        }
        
        return isDealFullFilled;
     }
      
     
    /**
     * Name: UpdateOptionFeeInvoice
     * Desc: Method to do calculation after Closed Invoice Button click.
     * @param:  (1) coInvoiceItemsJsonString - String - json string of coInvoice items
     *          (2) coHeaderId -String - id of coHeader
     * @return:  String - JSON String of CO Invoice History List
    **/
    public static List<Option_Fee__c> UpdateOptionFeeInvoice(List<CO_Line_Item__c> coLineItemDealservice, List<Service_Order_Line_Item__c> soLineItemDealservice, 
        List<Option_Fee__c> optionAndFeeRecListWithDoNotInvOption) {
        List<Option_Fee__c>  optionFeeListToUpdate = new List<Option_Fee__c>();
        
        Set<String> optionAndFeeIdSet = new Set<String>();
        for(CO_Line_Item__c coliRec :  coLineItemDealservice) {
            if(String.isNotBlank(coliRec.Related_Option_And_Fees__c)) {
                List<String> OptionFeeIdList =  coliRec.Related_Option_And_Fees__c.split(';');
                for(String optionFeeId : OptionFeeIdList){
                    if(String.isNotBlank(optionFeeId) && !optionAndFeeIdSet.contains(optionFeeId)){
                        Option_Fee__c optionfeeItem = new Option_Fee__c();
                        optionfeeItem.Id = optionFeeId;
                        optionfeeItem.Per_Item_Cost__c = coliRec.Price__c;
                        optionfeeItem.status__c = 'Fulfilled';
                        optionFeeListToUpdate.add(optionfeeItem);
                        optionAndFeeIdSet.add(optionFeeId);
                    }
                }
            }
        }
        for(Service_Order_Line_Item__c soliRec : soLineItemDealservice) {
            if(String.isNotBlank(soliRec.Option_Fee__c) && !optionAndFeeIdSet.contains(soliRec.Option_Fee__c)) {
                Option_Fee__c optionfeeItem = new Option_Fee__c(Id = soliRec.Option_Fee__c);
                optionfeeItem.Per_Item_Cost__c = soliRec.Kit_Price__c;
                optionfeeItem.status__c = 'Fulfilled';
                optionFeeListToUpdate.add(optionfeeItem);
                optionAndFeeIdSet.add(soliRec.Option_Fee__c);
            }
        }
        
        for(Option_Fee__c optionfeeItem : optionAndFeeRecListWithDoNotInvOption) {
            if(!optionAndFeeIdSet.contains(optionfeeItem.Id)) {
                optionfeeItem.Per_Item_Cost__c = optionfeeItem.Service_Order_Line_Item__r.Kit_Price__c;
                optionfeeItem.status__c = 'Fulfilled';
                optionFeeListToUpdate.add(optionfeeItem);
                optionAndFeeIdSet.add(optionfeeItem.Id);
            }
        }
        
        return optionFeeListToUpdate;
    }
        
      public static void AddPartToPartMap( Map<Id,Part__c> updateStockedMap, Map<Id,Part__c> updateStockBucketMap ,decimal QuantityNeed,decimal quantityComitted ,Part__c PartRecordObj , List<Part__c> PartForPartReturnBuckets  ,decimal PartReturnPrice,decimal qtyOverSold){
        if(AccessControl.ifObjectFieldIsCreateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            
            Part__c PartRecord = PartRecordObj.clone(false, false, false, false);
            PartRecord.Id = PartRecordObj.Id;  
            if(!(updateStockedMap.containsKey(PartRecordObj.Id))){ 
                updateStockedMap.put(PartRecordObj.Id,PartRecordObj);
            }
            
            if(QuantityNeed > 0 ) {
                 if(qtyOverSold > 0){
                        quantityComitted = quantityComitted - qtyOverSold;
                        
                 }
                updateStockedMap.get(PartRecordObj.Id).Qty_Committed__c = updateStockedMap.get(PartRecordObj.Id).Qty_Committed__c - quantityComitted;
                if(updateStockBucketMap.containsKey(PartRecordObj.Id)) {
                    updateStockBucketMap.get(PartRecord.Id).Qty_In_Stock__c = updateStockBucketMap.get(PartRecord.Id).Qty_In_Stock__c + quantityComitted;
                    updateStockBucketMap.get(PartRecord.Id).Qty_Committed__c = updateStockBucketMap.get(PartRecord.Id).Qty_Committed__c + quantityComitted;
                    updateStockBucketMap.get(PartRecord.Id).Oversold_Qty__c = updateStockBucketMap.get(PartRecord.Id).Oversold_Qty__c + qtyOverSold;
                    
                } else {
                    updateStockBucketMap.put(PartRecord.Id,PartRecord);
                    updateStockBucketMap.get(PartRecord.Id).Qty_In_Stock__c = quantityComitted;
                    updateStockBucketMap.get(PartRecord.Id).Qty_Committed__c = quantityComitted;
                    updateStockBucketMap.get(PartRecord.Id).Oversold_Qty__c = qtyOverSold;
                }
            }else{
                updateStockedMap.get(PartRecordObj.Id).Qty_In_Stock__c = updateStockedMap.get(PartRecordObj.Id).Qty_In_Stock__c - QuantityNeed;
                part__c partRecForBucket  = new part__c( Id = PartRecord.Id,Qty_In_Stock__c =  - (QuantityNeed!=null ? QuantityNeed : 0), Last_Cost__c =  PartReturnPrice, Description__c ='Part Return');
                PartForPartReturnBuckets.add(partRecForBucket);  
            }
            /*
           if(updateStockedMap.containsKey(PartRecordObj.Id)){ 
                if(QuantityNeed > 0 ) {
                    updateStockedMap.get(PartRecordObj.Id).Qty_Committed__c = updateStockedMap.get(PartRecordObj.Id).Qty_Committed__c - quantityComitted;
                    if(updateStockBucketMap.containsKey(PartRecordObj.Id)) {
                        updateStockBucketMap.get(PartRecord.Id).Qty_In_Stock__c = updateStockBucketMap.get(PartRecord.Id).Qty_In_Stock__c + quantityComitted;
                        updateStockBucketMap.get(PartRecord.Id).Qty_Committed__c = updateStockBucketMap.get(PartRecord.Id).Qty_Committed__c + quantityComitted;
                    } else {
                        updateStockBucketMap.put(PartRecord.Id,PartRecord);
                        updateStockBucketMap.get(PartRecord.Id).Qty_In_Stock__c = quantityComitted;
                        updateStockBucketMap.get(PartRecord.Id).Qty_Committed__c = quantityComitted;
                    }
                }else{
                    updateStockedMap.get(PartRecordObj.Id).Qty_In_Stock__c = updateStockedMap.get(PartRecordObj.Id).Qty_In_Stock__c - QuantityNeed;
                    part__c partRecForBucket  = new part__c( Id = PartRecord.Id,Qty_In_Stock__c =  - (QuantityNeed!=null ? QuantityNeed : 0), Last_Cost__c =  PartReturnPrice, Description__c ='Part Return');
                    PartForPartReturnBuckets.add(partRecForBucket);  
                }
            } else {
                updateStockedMap.put(PartRecordObj.Id,PartRecordObj); 
                if(QuantityNeed > 0 ) {
                    updateStockedMap.get(PartRecordObj.Id).Qty_Committed__c = updateStockedMap.get(PartRecordObj.Id).Qty_Committed__c - quantityComitted;
                    updateStockBucketMap.put(PartRecord.Id,PartRecord);
                    updateStockBucketMap.get(PartRecord.Id).Qty_In_Stock__c = quantityComitted;
                    updateStockBucketMap.get(PartRecord.Id).Qty_Committed__c = quantityComitted;
                } else {
                    updateStockedMap.get(PartRecordObj.Id).Qty_In_Stock__c = updateStockedMap.get(PartRecordObj.Id).Qty_In_Stock__c - QuantityNeed;
                    part__c partRecForBucket  = new part__c( Id = PartRecord.Id,Qty_In_Stock__c =  - (QuantityNeed!=null ? QuantityNeed : 0), Last_Cost__c =  PartReturnPrice, Description__c ='Part Return');
                    PartForPartReturnBuckets.add(partRecForBucket); 
                }   
           }*/
  }
    /**
     * Name: getCustomer
     * Desc: Method to get Customer From customer Id
     * @param:  (1) customerId - String - Customer Id
     * @return:  String - JSON String of Customer Record
    **/
    @RemoteAction
    global static String getCustomer(String customerId){
        customerId = BPUtility.getDecodedString(customerId);
        try{
            List<Account> customers = SOQLUtil.getCustomer(customerId, 'Customer');
            List<Customer> customerList = new List<Customer>();
            for(Account customerRec : customers) {
                customerList.add(new Customer(customerRec));
            }
            return BPUtility.getEncodedString(System.JSON.serialize(customerList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
     * Name: getOtherSimilarCustomer
     * Desc: Method to find similar Customer. Defination of Similar customer will be given in corresponding user story
     * @param:  (1) customerJSONString - Customer JSON String on which search has to be performed
     * @return:  String - Filtered Customers JSON String
    **/
   @RemoteAction
    global static String getOtherSimilarCustomer(String customerJSONString){
        customerJSONString = BPUtility.getDecodedString(customerJSONString);
        try{
            Customer customerObj = (Customer) System.JSON.deserialize(customerJSONString, Customer.class);
            Account customerRecordFilterValue = (Account) setCustomerfields(customerObj, customerObj.Type);
            List<Account> customers = SOQLUtil.getOtherSimilarCustomer(customerRecordFilterValue);
    
            List<CustomerSuggestion> customerSuggestionList = new List<CustomerSuggestion>();
            for(Account customerRec : customers) {
                if(customerRec.Type__c == 'Individual') {
                    if(customerRec.LastName__c != null && customerRec.LastName__c != '' && customerRec.LastName__c == customerRecordFilterValue.LastName__c) {
                        if(customerRec.FirstName__c == customerRecordFilterValue.FirstName__c) {
                            customerSuggestionList.add(new CustomerSuggestion(customerRec, 4));
                            continue;
                        } else if(customerRec.FirstName__c != null && customerRec.FirstName__c.length() > 1 && customerRec.FirstName__c.subString(0,1) == customerRecordFilterValue.FirstName__c) {
                            customerSuggestionList.add(new CustomerSuggestion(customerRec, 5));
                            continue;
                        } else {
                            customerSuggestionList.add(new CustomerSuggestion(customerRec, 6));
                            continue;
                        }
                    } 
                } else if(customerRec.Type__c == 'Business') {
                    if(customerRec.Name ==  customerRecordFilterValue.Name) {
                        customerSuggestionList.add(new CustomerSuggestion(customerRec, 4));
                        continue;
                    }
                }
                if(( customerRec.Email__c !=null  && customerRec.Email__c !='' && (customerRec.Email__c == customerRecordFilterValue.Email__c || 
                                                                                    customerRec.Email__c == customerRecordFilterValue.Other_Email__c))  || 
                                                                                    
                        (customerRec.Work_Email__c != null && customerRec.Work_Email__c != '' && (customerRec.Work_Email__c == customerRecordFilterValue.Work_Email__c ||
                                                                                                  customerRec.Work_Email__c == customerRecordFilterValue.Other_Email__c)) ||
                            
                        (customerRec.Other_Email__c != null && customerRec.Other_Email__c != '' && (customerRec.Other_Email__c == customerRecordFilterValue.Other_Email__c ||
                                                                                                     customerRec.Other_Email__c == customerRecordFilterValue.Work_Email__c || 
                                                                                                     customerRec.Other_Email__c == customerRecordFilterValue.Email__c))) {
                    
                    customerSuggestionList.add(new CustomerSuggestion(customerRec, 1));
                    continue;
                }
                
                if((customerRec.Home_Number__c != null && customerRec.Home_Number__c != '' && (customerRec.Home_Number__c == customerRecordFilterValue.Home_Number__c  ||
                                                                                               customerRec.Home_Number__c == customerRecordFilterValue.Mobile__c )) || 
                                                                                               
                        (customerRec.Work_Number__c != null && customerRec.Work_Number__c != '' && (customerRec.Work_Number__c == customerRecordFilterValue.Work_Number__c || 
                                                                                                    customerRec.Work_Number__c == customerRecordFilterValue.Mobile__c))  ||
                                                                                                     
                        (customerRec.Mobile__c != null && customerRec.Mobile__c != '' && (customerRec.Mobile__c == customerRecordFilterValue.Mobile__c ||
                                                                                          customerRec.Mobile__c == customerRecordFilterValue.Home_Number__c ||
                                                                                          customerRec.Mobile__c == customerRecordFilterValue.Work_Number__c ))) {
                            
                    customerSuggestionList.add(new CustomerSuggestion(customerRec, 2));
                    continue;
                }
                
                if((customerRec.Facebook__c != null && customerRec.Facebook__c != '' && customerRec.Facebook__c == customerRecordFilterValue.Facebook__c) || 
                        (customerRec.Twitter__c != null && customerRec.Twitter__c != '' && customerRec.Twitter__c == customerRecordFilterValue.Twitter__c) || 
                        (customerRec.LinkedIn__c != null && customerRec.LinkedIn__c != '' && customerRec.LinkedIn__c == customerRecordFilterValue.LinkedIn__c)) {
                    customerSuggestionList.add(new CustomerSuggestion(customerRec, 3));
                    continue;
                }
                
                String billingStreet = (customerRec.BillingStreet == null ) ? '' : customerRec.BillingStreet;
                List<String> bsList = billingStreet.split('\n');
                String billingStreet1 = (bsList.size() > 0) ? bsList[0] : '';
                
                String filterBillingStreet = (customerRecordFilterValue.BillingStreet == null ) ? '' : customerRecordFilterValue.BillingStreet;
                List<String> filterBSList = filterBillingStreet.split('\n');
                String filterBillingStreet1 = (filterBSList.size() > 0) ? filterBSList[0] : '';
                if(filterBillingStreet1 != '' && filterBillingStreet1 != null && filterBillingStreet1 != 'null' && filterBillingStreet1 == billingStreet1) {
                    customerSuggestionList.add(new CustomerSuggestion(customerRec, 7));
                }
            }
            //system.assert(false, customerSuggestionList);
            customerSuggestionList.sort();
            Integer listSizeLimit = 7;
            if(customerSuggestionList.size() > listSizeLimit) {
                List<CustomerSuggestion> customerSuggestionLimitedList = new List<CustomerSuggestion>();
                for(Integer i = 0 ; i < listSizeLimit ; i++) {
                    customerSuggestionLimitedList.add(customerSuggestionList[i]);
                }
                customerSuggestionList = new List<CustomerSuggestion>();
                customerSuggestionList.addAll(customerSuggestionLimitedList);
            }
            //system.assert(false, customerSuggestionList);
            return BPUtility.getEncodedString(System.JSON.serialize(customerSuggestionList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
     * Name: getSimilarCOUs
     * Desc: Method to get Similar COUs based on VIN Number
     * @param:  (1) VINNumber - String - VInNumber as String
     * @return:  String - JSONString of similar COUs.
    **/
   @RemoteAction
    global static String getSimilarCOUs(String VINNumber){
        VINNumber = BPUtility.getDecodedString(VINNumber);
        try{
            Customer_Owned_Unit__c couRec = new Customer_Owned_Unit__c(VIN_Number__c = VINNumber);
            List<Customer_Owned_Unit__c> custOwnedUnits = SOQLUtil.getOtherSimilarActiveUnits(couRec);
            //List<Customer_Owned_Unit__c> custOwnedUnits = SOQLUtil.getSimilarCOUs(VINNumber);
            List<CustomerOwnedUnit> custOwnedUnitList = new List<CustomerOwnedUnit>();
            for(Customer_Owned_Unit__c custOwnedUnitRec : custOwnedUnits) {
                if(custOwnedUnitRec.VIN_Number__c != null && custOwnedUnitRec.VIN_Number__c != '' && custOwnedUnitRec.VIN_Number__c == VINNumber) {
                    custOwnedUnitList.add(new CustomerOwnedUnit(custOwnedUnitRec));
                }
            }
            return BPUtility.getEncodedString(System.JSON.serialize(custOwnedUnitList));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    * Name: getAllLookupFieldsJSON
    * Desc: Method to get JSON String of all look up fields JSON
    * @param:  
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String getAllLookupFieldsJSON(){
        try{
            List<Country__c> countryList = SOQLUtil.getAllCountry();
            List<Country__c> countryWrapperList = SOQLUtil.getAllCountryWrapper();
            List<Sales_Tax__c> salesTaxList = SOQLUtil.getSalesTax(new List<Id>());
            List<Price_Level__c> priceLevelList = SOQLUtil.getPriceLevel(new List<Id>());
            List<Unit_Make__c> unitMakeList = new List<Unit_Make__c>();
            List<Unit_Make__c> unitMakeWrapperList = new List<Unit_Make__c>();
            
            COUFieldWrapper cOUFieldWrapperObj = new COUFieldWrapper(countryList, countryWrapperList, salesTaxList, priceLevelList, unitMakeList, unitMakeWrapperList, new List<Category__c>());
            cOUFieldWrapperObj.DefaultOrderingTaxId = GeneralConfiguration.getOrderingTaxRate();
            return BPUtility.getEncodedString(System.JSON.serialize(cOUFieldWrapperObj));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
     * Name: saveCustomer
     * Desc: Method to save customer into Database
     * @param:  (1) customerJSONString - String - customer JSOn String 
     *          (2) couJSONString - String - Customer Ownend Unit String
     * @return:  String - JSON String of Customer with ID and Name of Customer
    **/
   @RemoteAction
    global static String saveCustomer(String customerJSONString, String couJSONString){
        customerJSONString = BPUtility.getDecodedString(customerJSONString);
        couJSONString = BPUtility.getDecodedString(couJSONString);
        try{
            Savepoint sp = Database.setSavepoint();
            if(AccessControl.ifObjectFieldIsCreateable('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsCreateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            
            Customer customerObj = Customer.parse(customerJSONString);
            List<CustomerOwnedUnit> couObjList = CustomerOwnedUnit.parse(couJSONString);
            Account customerToInsert = new Account();
            customerToInsert = (Account) setCustomerfields(customerObj, customerObj.Type);
            if(customerToInsert.Name != null ) {
                Boolean isInsert = String.isBlank(customerToInsert.Id); 
                upsert customerToInsert;
                
                // Create Activity History in case of Insert.
                if(isInsert && !Test.isRunningTest()) {
                    ActivityHistory.createActivityHistory('Add Customer', 'Customer', customerToInsert.Id, 'Customer', customerToInsert.Id, null);
                }
            }
            String customerId = customerToInsert.Id;
            Map<String, Unit_Make__c> makeNameToMakeRecMap = new Map<String, Unit_Make__c>();
            Map<String, Map<String, Unit_Model__c>> makeIdToModelNameToModelRecMap = new Map<String, Map<String, Unit_Model__c>>();
            Map<String, Map<String, Unit_Sub_Model__c>> modelIdToSubModelNameToSubModelRecMap = new Map<String, Map<String, Unit_Sub_Model__c>>();
            
            List<Customer_Owned_Unit__c> couListToInsert = new List<Customer_Owned_Unit__c>();
            List<CustomerOwnedUnit> couList = new List<CustomerOwnedUnit>();
            for(CustomerOwnedUnit couObj : couObjList) {
                if(String.isNotBlank(couObj.Make) && String.isNotBlank(couObj.Model)) {
                    if(String.isBlank(couObj.SubModel) && String.isNotBlank(couObj.SubModelName)) {
                        modelIdToSubModelNameToSubModelRecMap.put(couObj.Model, new Map<String, Unit_Sub_Model__c>{couObj.SubModelName => 
                                                                                                                new Unit_Sub_Model__c(Sub_Model_Name__c = couObj.SubModelName, Unit_Model__c = couObj.Model)});
                        couList.add(couObj);
                    } else {
                        Customer_Owned_Unit__c couRec = new Customer_Owned_Unit__c();
                        couRec.VIN_Number__c = couObj.VIN;
                        couRec.Account__c = customerId;
                        couRec.Colour__c = couObj.Color;
                        couRec.Mileage_Value__c = couObj.Mileage;
                        couRec.Plate__c = couObj.Plate;
                        
                        couRec.Unit_Make__c = couObj.Make;
                        couRec.Reg_Expiry_Date__c = (String.isNotBlank(couObj.RegExpiryDate)) ? Date.parse(couObj.RegExpiryDate) : null;/* added by kajal 1st may, 2017 #1975 */
                        couRec.Unit_Model__c = couObj.Model;
                        
                        couRec.Sub_Model__c = couObj.SubModel;
                        couRec.Year__c = couObj.Year;
                        couRec.Status__c = couObj.Status;
                        couRec.Unit_Type__c = couObj.UnitType;
                        couRec.Mileage_Type__c = couObj.MileageType;
                        couListToInsert.add(couRec);
                    }
                } else if(String.isNotBlank(couObj.MakeName) && String.isNotBlank(couObj.ModelName)) {
                    if(couObj.Make != null) {
                        if(makeIdToModelNameToModelRecMap.containsKey(couObj.Make)) {
                            Map<String, Unit_Model__c> modelNameToModelRecMap = makeIdToModelNameToModelRecMap.get(couObj.Make);
                            if(!modelNameToModelRecMap.containsKey(couObj.ModelName)) {
                                modelNameToModelRecMap.put(couObj.ModelName, new Unit_Model__c(Name__c = couObj.ModelName, Unit_Make__c = couObj.Make));
                            }
                            makeIdToModelNameToModelRecMap.put(couObj.Make, modelNameToModelRecMap);
                        } else {
                            makeIdToModelNameToModelRecMap.put(couObj.Make, new Map<String, Unit_Model__c>{couObj.ModelName => new Unit_Model__c(Name__c = couObj.ModelName, Unit_Make__c = couObj.Make)});
                        }
                    } else {
                        if(!makeNameToMakeRecMap.containsKey(couObj.MakeName)) {
                            makeNameToMakeRecMap.put(couObj.MakeName, new Unit_Make__c(Name = couObj.MakeName));
                        }
                    }
                    couList.add(couObj);
                }
             }
             if(makeNameToMakeRecMap.size() > 0) {
                insert makeNameToMakeRecMap.values();
                
                for(CustomerOwnedUnit couObj : couList) {
                    if(makeNameToMakeRecMap.containsKey(couObj.MakeName)) {
                        couObj.Make = makeNameToMakeRecMap.get(couObj.MakeName).Id;
                        if(makeIdToModelNameToModelRecMap.containsKey(couObj.Make)) {
                            Map<String, Unit_Model__c> modelNameToModelRecMap = makeIdToModelNameToModelRecMap.get(couObj.Make);
                            if(!modelNameToModelRecMap.containsKey(couObj.ModelName)) {
                                modelNameToModelRecMap.put(couObj.ModelName, new Unit_Model__c(Name__c = couObj.ModelName, Unit_Make__c = couObj.Make));
                            }
                            makeIdToModelNameToModelRecMap.put(couObj.Make, modelNameToModelRecMap);
                        
                        } else {
                            makeIdToModelNameToModelRecMap.put(couObj.Make, new Map<String, Unit_Model__c>{couObj.ModelName => new Unit_Model__c(Name__c = couObj.ModelName, Unit_Make__c = couObj.Make)});
                        }
                    }
                 }
             }
             
             if(makeIdToModelNameToModelRecMap.size() > 0) {
                List<Unit_Model__c> modelListToInsert = new List<Unit_Model__c>();
                for(Map<String, Unit_Model__c> modelNameToModelRecMap : makeIdToModelNameToModelRecMap.values()) {
                    modelListToInsert.addAll(modelNameToModelRecMap.values());
                }
                insert modelListToInsert;
                
                
                for(Unit_Model__c modelRec : modelListToInsert) {
                    if(makeIdToModelNameToModelRecMap.containsKey(modelRec.Unit_Make__c)) {
                        Map<String, Unit_Model__c> modelNameToModelRecMap = makeIdToModelNameToModelRecMap.get(modelRec.Unit_Make__c);
                        if(modelNameToModelRecMap.containsKey(modelRec.Name__c)) {
                            modelNameToModelRecMap.put(modelRec.Name__c, modelRec);
                        }
                    }
                }
             }
             //Database.rollback(sp);
             //system.assert(false, makeIdToModelNameToModelRecMap);
             
             for(CustomerOwnedUnit couObj : couList) {
                if(makeNameToMakeRecMap.containsKey(couObj.MakeName)) {
                    couObj.Make = makeNameToMakeRecMap.get(couObj.MakeName).Id;
                }
                
                if(makeIdToModelNameToModelRecMap.containsKey(couObj.Make)) {
                    Map<String, Unit_Model__c> modelNameToModelRecMap = makeIdToModelNameToModelRecMap.get(couObj.Make);
                    
                    if(modelNameToModelRecMap.containsKey(couObj.ModelName)) {
                        couObj.Model = modelNameToModelRecMap.get(couObj.ModelName).Id;
                    }
                }
                if(String.isNotBlank(couObj.SubModelName)) {
                    if(modelIdToSubModelNameToSubModelRecMap.containsKey(couObj.Model)) {
                        Map<String, Unit_Sub_Model__c> submodelNameToSubModelRecMap = modelIdToSubModelNameToSubModelRecMap.get(couObj.Model);
                        
                        if(!submodelNameToSubModelRecMap.containsKey(couObj.SubModelName)) {
                            submodelNameToSubModelRecMap.put(couObj.SubModelName, new Unit_Sub_Model__c(Sub_Model_Name__c = couObj.SubModelName, Unit_Model__c = couObj.Model));
                        }
                        modelIdToSubModelNameToSubModelRecMap.remove(couObj.Model);
                        modelIdToSubModelNameToSubModelRecMap.put(couObj.Model, submodelNameToSubModelRecMap);
                    
                    } else {
                        modelIdToSubModelNameToSubModelRecMap.put(couObj.Model, new Map<String, Unit_Sub_Model__c>{couObj.SubModelName => new Unit_Sub_Model__c(Sub_Model_Name__c = couObj.SubModelName, Unit_Model__c = couObj.Model)});
                    }
                }
             }
             
             if(modelIdToSubModelNameToSubModelRecMap.size() > 0) {
                List<Unit_Sub_Model__c> submodelListToInsert = new List<Unit_Sub_Model__c>();
                for(Map<String, Unit_Sub_Model__c> submodelNameToSubModelRecMap : modelIdToSubModelNameToSubModelRecMap.values()) {
                    submodelListToInsert.addAll(submodelNameToSubModelRecMap.values());
                }
                insert submodelListToInsert;
                for(Unit_Sub_Model__c submodelRec : submodelListToInsert) {
                    if(modelIdToSubModelNameToSubModelRecMap.containsKey(submodelRec.Unit_Model__c)) {
                        Map<String, Unit_Sub_Model__c> submodelNameToSubModelRecMap = modelIdToSubModelNameToSubModelRecMap.get(submodelRec.Unit_Model__c);
                        if(submodelNameToSubModelRecMap.containsKey(submodelRec.Sub_Model_Name__c)) {
                            submodelNameToSubModelRecMap.put(submodelRec.Sub_Model_Name__c, submodelRec);
                        }
                        modelIdToSubModelNameToSubModelRecMap.put(submodelRec.Unit_Model__c, submodelNameToSubModelRecMap);
                    }
                }
             }
             
             for(CustomerOwnedUnit couObj : couList) {
                Customer_Owned_Unit__c couRec = new Customer_Owned_Unit__c();
                if(modelIdToSubModelNameToSubModelRecMap.containsKey(couObj.Model) && String.isNotBlank(couObj.SubModelName)) {
                    Map<String, Unit_Sub_Model__c> submodelNameToSubModelRecMap = modelIdToSubModelNameToSubModelRecMap.get(couObj.Model);
                    if(submodelNameToSubModelRecMap.containsKey(couObj.SubModelName)) {
                        couRec.Sub_Model__c = submodelNameToSubModelRecMap.get(couObj.SubModelName).Id;
                    }
                }
                couRec.VIN_Number__c = couObj.VIN;
                couRec.Account__c = customerId;
                couRec.Colour__c = couObj.Color;
                couRec.Mileage_Value__c = couObj.Mileage;
                couRec.Plate__c = couObj.Plate;
                couRec.Reg_Expiry_Date__c = (String.isNotBlank(couObj.RegExpiryDate)) ? Date.parse(couObj.RegExpiryDate) : null;/* added by kajal 1st may, 2017 #1975 */
                couRec.Unit_Make__c = couObj.Make;
                couRec.Unit_Model__c = couObj.Model;
                //couRec.Sub_Model__c = couObj.SubModel;
                couRec.Year__c = couObj.Year;
                couRec.Status__c = couObj.Status;
                couRec.Unit_Type__c = couObj.UnitType;
                couRec.Mileage_Type__c = couObj.MileageType;
                couListToInsert.add(couRec);
             }
             if(couListToInsert.size() > 0) {
                insert couListToInsert ;
             }
             JSONGenerator gen = JSON.createGenerator(true);
             gen.writeStartObject();
             gen.writeStringField('Id', customerId);
             gen.writeStringField('CustomerName', customerToInsert.Name);
             gen.writeEndObject();
             return BPUtility.getEncodedString(gen.getAsString());


        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
     * Name: setCustomerfields
     * Desc: Method to set fields of Customer Object
     * @param:  (1) custObj - Customer - Customer Obj
     *          (2) typeOfCustomer - String - Type of Customer in Database
     * @return:  Sobject - Sobject with populated values of account object
    **/
    private static Sobject setCustomerfields(Customer custObj, String typeOfCustomer){
        try{
            SObject customerToInsert = new Account();
            
            if(typeOfCustomer == 'Individual') {
                customerToInsert.put('FirstName__c', custObj.FirstName);
                customerToInsert.put('LastName__c', BPUtility.escapeSingleQuotes(custObj.LastName));
                if(custObj.FirstName != null && custObj.LastName != null) {
                    customerToInsert.put('Name', custObj.FirstName + ' ' + custObj.LastName);
                }
                customerToInsert.put('Company_Name__c', custObj.Company);
                customerToInsert.put('Job_Title__c', custObj.JobTitle);
                customerToInsert.put('Nickname__c', custObj.Nickname);
            } else if(typeOfCustomer == 'Business'){
                customerToInsert.put('Name', custObj.BusinessName);
            }
            
            customerToInsert.put('Home_Number__c', custObj.HomeNumber);
            customerToInsert.put('Mobile__c', custObj.OtherPhone);
            customerToInsert.put('Work_Number__c', custObj.WorkNumber);
            customerToInsert.put('Email__c', custObj.HomeEmail);
            
            if(custObj.BirthDay != null && custObj.BirthMonth != null && custObj.BirthYear != null) {
                Date birth_Date = Date.newInstance(custObj.BirthYear, custObj.BirthMonth, custObj.BirthDay);
                customerToInsert.put('Birth_Date__c', birth_Date);
            } else {
                customerToInsert.put('Birth_Date__c', null);
            }
                
            customerToInsert.put('Type__c', custObj.Type);
            customerToInsert.put('Active__c', custObj.Active);
            customerToInsert.put('Is_Customer__c', custObj.IsCustomer);
            customerToInsert.put('Is_Vendor__c', custObj.IsVendor);
            customerToInsert.put('Work_Email__c', custObj.WorkEmail);
            customerToInsert.put('Other_Email__c', custObj.OtherEmail);
            customerToInsert.put('SA_same_as_BA__c', custObj.IsBothAddressSame);
            customerToInsert.put('Account_Type__c', custObj.AccountTypeId);
            
            customerToInsert.put('Home_Number_SMS__c', custObj.HomeNumberSMS);
            customerToInsert.put('Work_Number_SMS__c', custObj.WorkNumberSMS);
            customerToInsert.put('Mobile_Number_SMS__c', custObj.MobileNumberSMS);
            customerToInsert.put('Drivers_License__c', custObj.DriversLicense);
            
            if(custObj.PreferredEmail == 'HomeEmail') {
                customerToInsert.put('Preferred_Email__c', custObj.HomeEmail);
            } else if(custObj.PreferredEmail == 'WorkEmail') {
                customerToInsert.put('Preferred_Email__c', custObj.WorkEmail);
            } else if(custObj.PreferredEmail == 'OtherEmail') {
                customerToInsert.put('Preferred_Email__c', custObj.OtherEmail);
            } else if(custObj.PreferredEmail == '') {
                customerToInsert.put('Preferred_Email__c', null);
            }
            
            if(custObj.PreferredPhone == 'HomeNumber') {
                customerToInsert.put('Preferred_Phone__c', custObj.HomeNumber);
            } else if(custObj.PreferredPhone == 'OtherPhone') {
                customerToInsert.put('Preferred_Phone__c', custObj.OtherPhone);
            } else if(custObj.PreferredPhone == 'WorkNumber') {
                customerToInsert.put('Preferred_Phone__c', custObj.WorkNumber);
            } else if(custObj.PreferredPhone == '') {
                customerToInsert.put('Preferred_Phone__c', null);
            } 
            
            if(custObj.PreferredSMS == 'HomeNumber') {
                customerToInsert.put('Preferred_SMS__c', custObj.HomeNumber);
            } else if(custObj.PreferredSMS == 'OtherPhone') {
                customerToInsert.put('Preferred_SMS__c', custObj.OtherPhone);
            } else if(custObj.PreferredSMS == 'WorkNumber') {
                customerToInsert.put('Preferred_SMS__c', custObj.WorkNumber);
            } else if(custObj.PreferredSMS == '') {
                customerToInsert.put('Preferred_SMS__c', null);
            } 
            
            customerToInsert.put('Facebook__c', custObj.FacebookLink);
            customerToInsert.put('Twitter__c', custObj.TwitterLink);
            customerToInsert.put('LinkedIn__c', custObj.LinkedInLink);
            
            if(custObj.BillingStreet1 == null && custObj.BillingStreet2 != null) {
                customerToInsert.put('BillingStreet', '\n' + custObj.BillingStreet2);
            } else if(custObj.BillingStreet2 == null && custObj.BillingStreet1 != null) {
                customerToInsert.put('BillingStreet', custObj.BillingStreet1 + '\n');
            } else if(custObj.BillingStreet1 != null && custObj.BillingStreet2 != null) {
                customerToInsert.put('BillingStreet', custObj.BillingStreet1 + '\n' + custObj.BillingStreet2);
            }
            customerToInsert.put('BillingCity', custObj.BillingCity);
            customerToInsert.put('BillingCountry', custObj.BillingCountry);
            customerToInsert.put('BillingState', custObj.BillingState);
            customerToInsert.put('BillingPostalCode', custObj.BillingPostalCode);
            
            if(!custObj.IsBothAddressSame) {
                if(custObj.ShippingStreet1 == null && custObj.ShippingStreet2 != null) {
                    customerToInsert.put('ShippingStreet', '\n' + custObj.ShippingStreet2);
                } else if(custObj.ShippingStreet2 == null && custObj.ShippingStreet1 != null) {
                    customerToInsert.put('ShippingStreet', custObj.ShippingStreet1 + '\n');
                } else if(custObj.ShippingStreet1 != null && custObj.ShippingStreet2 != null) {
                    customerToInsert.put('ShippingStreet', custObj.ShippingStreet1 + '\n' + custObj.ShippingStreet2);
                }
                customerToInsert.put('ShippingCity', custObj.ShippingCity);
                customerToInsert.put('ShippingCountry', custObj.ShippingCountry);
                customerToInsert.put('ShippingState', custObj.ShippingState);
                customerToInsert.put('ShippingPostalCode', custObj.ShippingPostalCode);
            } else {
                customerToInsert.put('ShippingStreet', customerToInsert.get('BillingStreet'));
                customerToInsert.put('ShippingCity', custObj.BillingCity);
                customerToInsert.put('ShippingCountry', custObj.BillingCountry);
                customerToInsert.put('ShippingState', custObj.BillingState);
                customerToInsert.put('ShippingPostalCode', custObj.BillingPostalCode);
            }

            customerToInsert.put('Price_Level__c', custObj.PriceLevelId);
            customerToInsert.put('Sales_Tax__c', custObj.SalesTaxId);
            customerToInsert.put('Purchase_Tax__c', custObj.PurchaseTaxId);
             if(custObj.PriceLevelId == null && String.isBlank(custObj.Id)) {
                if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Price_Level__c> defaultPriceLevel = [select Id from Price_Level__c where Default__c = true];
                if(defaultPriceLevel.size() > 0) {
                    customerToInsert.put('Price_Level__c', defaultPriceLevel[0].Id);
                }
            }
            
            if(custObj.SalesTaxId == null && String.isBlank(custObj.Id)) {
                if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Sales_Tax__c> defaultSalesTax = [select Id from Sales_Tax__c where Default__c = true];
                if(defaultSalesTax.size() > 0) {
                    customerToInsert.put('Sales_Tax__c', defaultSalesTax[0].Id);
                }
            }
            if(custObj.Id != null && custObj.Id != '') {
                customerToInsert.put('Id', custObj.Id);
            }   
            return customerToInsert;
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return null;
    }
    
    /**
    * Name: addVOHeaderToCOLI
    * Desc: Method to add VO Header Rec to Special Order CO Line Item Rec.
    * @param:   (1) partId - String - Id of Part
    *           (2) coliId - Id -CO Line Item record Id
    *           (3) voHeaderId - String - id of voHeader
    *           (4) coHeaderId - String - id of coHeader
    *           (5)itemsPageSortAttrsJSON - String - page sort attributes of item
    *           (6)customersPageSortAttrsJSON- String - page sort attributes of customer
    *           (7)stocksPageSortAttrsJSON- String - page sort attributes of stock
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String addVOHeaderToCOLI(String partId, String coliId, String voHeaderId, String coHeaderId, String itemsPageSortAttrsJSON, String customersPageSortAttrsJSON, String stocksPageSortAttrsJSON){
        partId = BPUtility.getDecodedString(partId);
        coliId = BPUtility.getDecodedString(coliId);
        voHeaderId = BPUtility.getDecodedString(voHeaderId);  
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
        customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
        stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
         try{

          if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
          

            voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
            Vendor_Order_Header__c voh = [Select Name, Status__c, Vendor__c from Vendor_Order_Header__c where Id =: voHeaderId];
            CO_Line_Item__c coli = new CO_Line_Item__c(Id = coliId);
            coli.VO_Number__c = voh.Name;
            coli.Vendor_Order_Header__c = voh.Id;
            coli.VO_Status__c = voh.Status__c;
            update coli;
            
            List<Vendor_Order_Line_Item__c> voLineItemList = [select Id from Vendor_Order_Line_Item__c where CO_Line_Item__c =: coliId
                                                                        AND CO_Line_Item__r.Status__c = 'Required' limit 1];
            if(voLineItemList.size() > 0) {
                List<String> voLineItemIdList = new List<String>();
                for(Vendor_Order_Line_Item__c voliRec : voLineItemList) {
                    voLineItemIdList.add(voliRec.Id);
                }
                VendorOrderCtrl.addSelectedLineItems(BPUtility.getEncodedString(JSON.serialize(voLineItemIdList)), BPUtility.getEncodedString(voh.Vendor__c), BPUtility.getEncodedString(voHeaderId),
                                BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString( customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON));
            }
            
            /*VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(voh.Vendor__c), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voHeaderId), BPUtility.getEncodedString(itemsPageSortAttrsJSON),
                                                        BPUtility.getEncodedString( customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON));
            */
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coLineItem,user,coInvoiceHeader,specialOrder'));
        }
        catch(Exception e){

            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    

    
    /**
    * Name: addVOHeaderToCOLIServiceOrder
    * Desc: Method to add VO Header Rec to Special Order CO Line Item Rec.
    * @param: (1) partId - String - Id of Part
    *         (2) coliId - Id -CO Line Item record Id
    *         (3) voHeaderId - String - id of voHeader
    *         (4) coHeaderId - String - id of coHeader
    *         (5)itemsPageSortAttrsJSON - String - page sort attributes of item
    *         (6)customersPageSortAttrsJSON- String - page sort attributes of customer
    *         (7)stocksPageSortAttrsJSON- String - page sort attributes of stock
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
   
    @RemoteAction
    global static String addVOHeaderToCOLIServiceOrder (String partId,String coliId, String voHeaderId, String coHeaderId,String itemsPageSortAttrsJSON,String customersPageSortAttrsJSON,String stocksPageSortAttrsJSON) {
        partId = BPUtility.getDecodedString(partId);
        coliId = BPUtility.getDecodedString(coliId);
        voHeaderId = BPUtility.getDecodedString(voHeaderId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        itemsPageSortAttrsJSON = BPUtility.getDecodedString(itemsPageSortAttrsJSON);
        customersPageSortAttrsJSON = BPUtility.getDecodedString(customersPageSortAttrsJSON);
        stocksPageSortAttrsJSON = BPUtility.getDecodedString(stocksPageSortAttrsJSON);
        try{
            if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            
            voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
            Vendor_Order_Header__c voh = [Select Id, Name, Status__c, Vendor__c from Vendor_Order_Header__c where Id =: voHeaderId];
            CO_Line_Item__c coli = new CO_Line_Item__c(Id = coliId);
            coli.VO_Number__c = voh.Name;  
            coli.VO_Status__c = voh.Status__c;  
            update coli;
            VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(voh.Vendor__c), BPUtility.getEncodedString(partId), BPUtility.getEncodedString(voHeaderId), 
                                                     BPUtility.getEncodedString(itemsPageSortAttrsJSON), BPUtility.getEncodedString(customersPageSortAttrsJSON), BPUtility.getEncodedString(stocksPageSortAttrsJSON));
            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


        
    }
    
    // ALL SO related Methods
    /**
    * Name: createSOHeader
    * Desc: Method to add VO Header Rec to Special Order CO Line Item Rec.
    * @param:   (1) coHeaderId - String - id of coHeader
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String createSOHeader(String coHeaderId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            if(AccessControl.ifObjectFieldIsAccessible('AggregateResult') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Transaction_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            coHeaderId = BPUtility.escapeSingleQuotes(coHeaderId);
            List<AggregateResult> soHeaderList = [select count(Id) from Service_Order_Header__c where CO_Header__c = :coHeaderId AND Deal__c = null];
            Integer totalSO = Integer.valueOf(soHeaderList[0].get('expr0'));
            List<Service_Order_Header__c> soHeaderNameList = [select Name__c from Service_Order_Header__c where CO_Header__c = :coHeaderId AND Deal__c = null];
            List<Category__c> categoryList = [select Id, Name, Default__c from Category__c where Type__c = 'Internal Expense' AND Default__c = true
                                                                            AND Active__c = true];
            // Added By Subhrant #1241
            List<CO_Invoice_Header__c> coInvoiceHeaderList = [select Id, Invoice_Status__c, CO_Header__c from CO_Invoice_Header__c where CO_Header__c =: coHeaderId AND Invoice_Status__c = 'Active'];
            // List<SO_Payment_Role__c> coInvoiceHeaderList = [select Id, Invoice_Status__c, CO_Header__c from CO_Invoice_Header__c where CO_Header__c IN :coHeaderIdList AND Invoice_Status__c = 'Active'];
            //End
            Map<Id, CO_Invoice_Header__c> coHeaderIdToCOInvoiceHeaderRecMap = new Map<Id, CO_Invoice_Header__c>();
            for(CO_Invoice_Header__c coInvoiceHeaderRec : coInvoiceHeaderList) {
                coHeaderIdToCOInvoiceHeaderRecMap.put(coInvoiceHeaderRec.CO_Header__c, coInvoiceHeaderRec); 
            }
            String defaultCategoryId;
            if(categoryList.size() > 0) {
                defaultCategoryId = categoryList[0].Id;
            }
            
            Service_Order_Header__c soHeaderToInsert = new Service_Order_Header__c();
            Boolean isSoHeaderNameAlreadyExist = false;
            String soHeaderName = 'Service Job ' + (totalSO + 1);
            for(Service_Order_Header__c soHeaderRec : soHeaderNameList) {
                if(soHeaderRec.Name__c == soHeaderName) {
                    isSoHeaderNameAlreadyExist = true;
                    break;
                }
            }
            if(isSoHeaderNameAlreadyExist) {  
                soHeaderToInsert.Name__c = 'Service Job ' + (totalSO + 2);
            } else {
                soHeaderToInsert.Name__c = 'Service Job ' + (totalSO + 1);
            }
            //soHeaderToInsert.Name__c = 'Service Job ' + (totalSO + 1);
            soHeaderToInsert.CO_Header__c = coHeaderId;
            soHeaderToInsert.Status__c = 'New';
            soHeaderToInsert.Work_Status__c = 'New';
            soHeaderToInsert.Category__c = defaultCategoryId;
            
            List<CO_Header__c> coHeaderList = [Select CO_Type__c, Customer__c, Order_Status__c, Selling_Group__c from CO_Header__c where Id = :coHeaderId];
            if(coHeaderList.size() > 0){
                soHeaderToInsert.SO_Type__c = coHeaderList[0].CO_Type__c;
                String transactionType;
                if(coHeaderList[0].CO_Type__c == 'Customer' && String.isNotBlank(coHeaderList[0].Order_Status__c) && (coHeaderList[0].Order_Status__c == 'Quote')) {
                    transactionType = 'Quote';
                    soHeaderToInsert.Work_Status__c = 'Estimate';
                } else if(coHeaderList[0].CO_Type__c == 'Internal Service') {
                    transactionType = 'Stock Unit';
                } else {
                    transactionType = 'Customer';
                }
                
                if(String.isNotBlank(transactionType)) {
                    List<Transaction_Type__c> transactionTypeList = [select Id from Transaction_Type__c where Type__c = :transactionType AND Default__c = true];
                    if(transactionTypeList.size() > 0) {
                        soHeaderToInsert.Transaction_Type__c = transactionTypeList[0].Id;
                    }
                }
                
                //Check for Single Unit
                List<Account> customerList = [Select Id, (Select Id from Customer_Owned_Units__r WHERE Status__c = 'Active') from Account where Id =: coHeaderList[0].Customer__c];
                if(customerList.size() > 0 && customerList[0].Customer_Owned_Units__r.size() == 1) {
                    soHeaderToInsert.Customer_Owned_Unit__c = customerList[0].Customer_Owned_Units__r[0].Id;
                }
            }
            insert soHeaderToInsert;
            
            if(coHeaderList.size() > 0 && coHeaderList[0].Selling_Group__c == 'Service Order') {
                COFormService.insertDefaultCOForms(coHeaderId, soHeaderToInsert.Id);
            }
            
            // Added By Subhrant #1241
            if(soHeaderToInsert.Id !=null ){
                CO_Invoice_Item__c coInvoiceItem = new CO_Invoice_Item__c();
                coInvoiceItem.Is_Invoiceable__c = false;
                coInvoiceItem.isActive__c = false;
                coInvoiceItem.Service_Order_Header__c = soHeaderToInsert.Id;
                if(coHeaderIdToCOInvoiceHeaderRecMap.containsKey(coHeaderId) ) {
                        coInvoiceItem.CO_Invoice_Header__c = coHeaderIdToCOInvoiceHeaderRecMap.get(coHeaderId).Id;
                 }else{ 
                        CO_Invoice_Header__c coInvoiceHeaderRec = COLineItemTriggerHelper.insertCOInvoiceHeader(coHeaderId);
                        coInvoiceItem.CO_Invoice_Header__c = coInvoiceHeaderRec.Id;
                        coHeaderIdToCOInvoiceHeaderRecMap.put(coHeaderId, coInvoiceHeaderRec);
                }
                 if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                 
                insert coInvoiceItem;
            }   
            List<SObject> sObjectListToInsert = addLinkedFee(soHeaderToInsert.Id, null, 'Service Job');
            if(sObjectListToInsert != null) {
                insert sObjectListToInsert;
            }
            //system.assert(false, soHeaderToInsert);
            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,pinItems,checkOut'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    * Name: saveCOU
    * Desc: Method to add VO Header Rec to Special Order CO Line Item Rec.
    * @param:   (1)couJSONString - String - customer owned unit string
    *           (2)customerId - String - id of Customer Record
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String saveCOU(String couJSONString, String customerId) {
        couJSONString = BPUtility.getDecodedString(couJSONString);
        customerId = BPUtility.getDecodedString(customerId);
        try{
            NewViewCustomerCtrl.saveCOU(BPUtility.getEncodedString(customerId), BPUtility.getEncodedString(couJSONString), BPUtility.getEncodedString('{}')); 
            
            List<Customer_Owned_Unit__c> couRecords = SOQLUtil.getCOUListByCustomerId(customerId);
            SOHeaderWrapper.SOMasterData masterDateObj = new SOHeaderWrapper.SOMasterData(new List<Transaction_Type__c>(), couRecords, new List<Account>(), new List<Category__c>());
            return BPUtility.getEncodedString(System.JSON.serialize(masterDateObj)); 
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    * Name: savePinItems
    * Desc: Method to add VO Header Rec to Special Order CO Line Item Rec.
    * @param:  (1)pinItemsJSONStr - String - pin items string 
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String savePinItems(String pinItemsJSONStr){
        pinItemsJSONStr = BPUtility.getDecodedString(pinItemsJSONStr);
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            

            SOHeaderWrapper soHeaderObj = (SOHeaderWrapper) System.JSON.deserialize(pinItemsJSONStr, SOHeaderWrapper.class);
            User currentUser = new User();
            currentUser.Id = UserInfo.getUserId();
            
            String pinItemStr = '';
            for(Integer i = 0; i < soHeaderObj.PinnedItemList.size(); i++) {
                if(i == soHeaderObj.PinnedItemList.size() - 1) {
                    pinItemStr += soHeaderObj.PinnedItemList[i];
                } else {
                    pinItemStr += soHeaderObj.PinnedItemList[i] + ',';
                }
            }
            
            currentUser.SO_Pinned_Info__c = pinItemStr;
            update currentUser;
            
            return BPUtility.getEncodedString('Saved');


        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    * Name: addLineItems
    * Desc: Method to add Line Items in Items Grid.
    * @param:   (1) lineItemId - String - id of line item
    *           (2) soHeaderId - String - id of Service Order Header
    *           (3) coHeaderId - String - id of coHeader
    *           (4) customerId - String - id of Customer 
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String addLineItems(String lineItemId, String soHeaderId, String coHeaderId, String customerId) {
        lineItemId = BPUtility.getDecodedString(lineItemId);
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        customerId = BPUtility.getDecodedString(customerId);
        try{
            addServiceJobLineItems(lineItemId, soHeaderId, coHeaderId, customerId);
            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    public static void addServiceJobLineItems(String lineItemId, String soHeaderId, String coHeaderId, String customerId) {
        
        String objectName = (Id.valueOf(lineItemId)).getSObjectType().getDescribe().getName();
        if(objectName == Constants.NAMESPACE + 'Kit_Header__c') {
            Id soKHId = insertKitHeaderInGrid(lineItemId, soHeaderId);
            //SO_KLI_Recalculation.SOPriceCalcultaionByPriceLevelForSOKitHeaders(customerId, coHeaderId, new List<Id>{soKHId}, soHeaderId);
            SO_KLI_Recalculation.soKitPriceCalculation(new Set<Id>{soKHId}, new Set<Id>{soHeaderId}, coHeaderId);
            if(hasLabor) {
                ShopSuppliesService.shopSuppliesCalculation(soHeaderId);
            }
        } else if(objectName == Constants.NAMESPACE + 'Part__c') {
            insertPartInGrid(lineItemId, soHeaderId, 1);
        } else if(objectName == Constants.NAMESPACE + 'Labour_Code__c') {
            Labour_Code__c laborRecToCalculateShopSupplies = insertLabourInGrid(lineItemId, soHeaderId, null);
            if(laborRecToCalculateShopSupplies != null) {
                ShopSuppliesService.calculateShopSupplies(laborRecToCalculateShopSupplies, soHeaderId);
            }
        } else if(objectName == Constants.NAMESPACE + 'Fee__c') {
            insertFeeInGrid(lineItemId, soHeaderId, false, new Part__c(), 1);  
        } else if(objectName == Constants.NAMESPACE + 'Product__c') {
            insertProductInGrid(lineItemId, soHeaderId, 1);
            COFormService.insertDefaultCOForms(coHeaderId, soHeaderId, lineItemId);
        }
        
        soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Header__c> soHeaderList = [select Status__c, Deal__c, (select Id,Kit_Price__c,Actual_Kit_Price__c,Qty_Needed__c from Service_Order_Line_Items__r) from Service_Order_Header__c where Id =: soHeaderId];
        if(soHeaderList.size() > 0 && soHeaderList[0].Service_Order_Line_Items__r != null && soHeaderList[0].Service_Order_Line_Items__r.size() > 0) {
            if(Constants.SOStatusToPriorityMap.get(soHeaderList[0].Status__c) < 3) {
                soHeaderList[0].Status__c = 'In Progress';
            }
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update soHeaderList[0];
        }    
    }
    
    /**
    * Name: changeSOHeaderStatusToComplete
    * Desc: change status of service order header
    * @param:  (1) soHeaderId - String - id of Service Order Header
    *          (2) coHeaderId - String - id of coHeader
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String changeSOHeaderStatusToComplete(String soHeaderId, String coHeaderId) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            
            soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
            List<Service_Order_Header__c> soHeaderList = [select Status__c from Service_Order_Header__c where Id =: soHeaderId];
            if(soHeaderList.size() > 0 && Constants.SOStatusToPriorityMap.get(soHeaderList[0].Status__c) < 4) {
                soHeaderList[0].Status__c = 'Complete';
                update soHeaderList[0];
            }
            
            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,checkOut'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    
    /**
    * Name: updateSOLineItems
    * Desc: update service order line items
    * @param:   (1)lineItemJSON - String - line item string
    *           (2) coHeaderId - String - id of coHeader
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String updateSOLineItems(String lineItemJSON, String coHeaderId) {
        lineItemJSON = BPUtility.getDecodedString(lineItemJSON);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

            SOHeaderWrapper.SOLineItem soHeaderObj = (SOHeaderWrapper.SOLineItem) System.JSON.deserialize(lineItemJSON, SOHeaderWrapper.SOLineItem.class);
            //System.assert(false,soHeaderObj);
            if(soHeaderObj.Id == null) {
                return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder'));
            } 
            

            error = SO_KLI_Recalculation.updateSOKitLineItem(soHeaderObj);
            system.debug('!!!!!!!!!!!!!!!!' + error);
            if(error == null || error.ResponseCode == '200') {
                // Special condition :- Related to updation of service order kit line items fixed price value
                Service_Order_Line_Item__c soliToUpdate = new Service_Order_Line_Item__c();
                soliToUpdate.Id = soHeaderObj.Id;
                soliToUpdate.Qty_Needed__c = soHeaderObj.QtyNeeded;
                if(soHeaderObj.IsFee || soHeaderObj.IsLabour || soHeaderObj.IsSublet) {
                    soliToUpdate.Item_Description__c = soHeaderObj.ItemDescription;
                }
                if(soHeaderObj.StockCommited > soHeaderObj.QtyNeeded) {
                    soliToUpdate.Qty_Committed__c = soHeaderObj.QtyNeeded;
                } else {  
                    soliToUpdate.Qty_Committed__c = soHeaderObj.StockCommited;
                }
                if(isTaxIncludingPricing && String.isBlank(soHeaderObj.DealId)) {
                    if(soHeaderObj.Tax == -100) { // To Prevent Divide by zero error
                        soHeaderObj.Tax = 0;
                    }
                    
                    soliToUpdate.Price_When_Tax_Included__c = soHeaderObj.KitPrice;
                    soliToUpdate.kit_Price__c = (soHeaderObj.KitPrice / (1 + soHeaderObj.Tax / 100 ));

                } else {
                    soliToUpdate.kit_Price__c = soHeaderObj.KitPrice;
                }
                
                List<Service_Order_Line_Item__c> soliList = [SELECT Service_Order_Header__r.Deal__c, Qty_Needed__c, Service_Order_Header__c,
                                                                Labour_Code__c, Labour_Code__r.Calculate_Supplies__c
                                                            FROM Service_Order_Line_Item__c WHERE Id =: soliToUpdate.Id];
                update soliToUpdate;
                
                if(soliList.size() > 0 && soliList[0].Labour_Code__c != null && soliList[0].Labour_Code__r.Calculate_Supplies__c) {
                    ShopSuppliesService.shopSuppliesCalculation(soliList[0].Service_Order_Header__c);
                }
                
                if(soliList.size() > 0) {
                    Decimal previousQty = soliList[0].Qty_Needed__c;               
                    if(String.isNotBlank(soliList[0].Service_Order_Header__r.Deal__c)) {
                    if(previousQty != soHeaderObj.QtyNeeded) {
                        createDealUnresolvedFulfillment(new List<String>{soliToUpdate.Id}, soHeaderObj.DealId, Constants.UNRESOLVED_FULFILLMENT_TYPE_UPDATED);
                    }
                    return getDealDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('dealUnresolvedFulfillmentSection'));
                }
            }
            }
            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
    * Name: updateSOKHLineItems
    * Desc: Method to update service order kit header line items
    * @param:       (1)soKHItemJSON - String service order kit header
                    (2) coHeaderId - String - id of coHeader
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String updateSOKHLineItems(String soKHItemJSON, String coHeaderId) {
        soKHItemJSON = BPUtility.getDecodedString(soKHItemJSON);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            SOHeaderWrapper.SOGrid soGridObj = (SOHeaderWrapper.SOGrid) System.JSON.deserialize(soKHItemJSON, SOHeaderWrapper.SOGrid.class);
            SOHeaderWrapper.SOKitHeader sokhObj = soGridObj.SOKH;
    
            if(sokhObj.Id != null) {
                if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                
                Service_Order_Kit_Header__c soKH = [SELECT Id, Service_Order_Header__c, Service_Order_Header__r.Deal__c, Fixed_Price__c FROM Service_Order_Kit_Header__c WHERE Id =: sokhObj.Id];
                //system.assert(false, soKH.Fixed_Price__c + '  ' + sokhObj.FixedPrice);
                
                if(soKH.Fixed_Price__c.SetScale(3) != sokhObj.FixedPrice) {
                    error = SO_KLI_Recalculation.updateSOKitHeader(sokhObj);
                    ShopSuppliesService.shopSuppliesCalculation(soKH.Service_Order_Header__c);
                }
                if(String.isNotBlank(soKH.Service_Order_Header__r.Deal__c)) {
                    return getDealDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('dealUnresolvedFulfillmentSection'));
                }
            }
            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    



    /**
    * Name: removeLineItems
    * Desc: Method to remove Line Items in Items Grid.
    * @param:   (1) lineItemId - String - id of line item
                (2) coHeaderId - String - id of coHeader
                (3) soHeaderId - String - id of Service Order Header
    *         
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String removeLineItems(String lineItemId, String coHeaderId, String soHeaderId) {
        lineItemId = BPUtility.getDecodedString(lineItemId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        try{
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            

            String objectName = (Id.valueOf(lineItemId)).getSObjectType().getDescribe().getName();
            if(objectName == CONSTANTS.NAMESPACE + 'Service_Order_Line_Item__c') {
                removeSOLineItem(lineItemId);
            } else if(objectName == CONSTANTS.NAMESPACE + 'Service_Order_Kit_Header__c') {
                removeSOKHItems(lineItemId);
                ShopSuppliesService.shopSuppliesCalculation(soHeaderId);
            }
            soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
            List<Service_Order_Header__c> soHeaderList = [select Deal__c, Status__c, (select Id from Service_Order_Line_Items__r) from Service_Order_Header__c where Id =: soHeaderId];
            if(soHeaderList.size() > 0 && soHeaderList[0].Service_Order_Line_Items__r != null && soHeaderList[0].Service_Order_Line_Items__r.size() == 0 && Constants.SOStatusToPriorityMap.get(soHeaderList[0].Status__c) < 2) {
                soHeaderList[0].Status__c = 'Ready';
                update soHeaderList[0];
            }
            
            if(String.isNotBlank(soHeaderList[0].Deal__c)) {
                if(soHeaderList[0].Service_Order_Line_Items__r.size() == 0) {
                    if(AccessControl.ifObjectIsDeletable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                    delete soHeaderList[0];
                }
                return getDealDetails(BPUtility.getEncodedString(soHeaderList[0].Deal__c), BPUtility.getEncodedString('dealUnresolvedFulfillmentSection'));
            }
            
            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    * Name: splitSOKHItem
    * Desc: Method to split service order kit header 
    * @param:   (1)lineItemId - String - id of line item
                (2) coHeaderId - String - id of coHeader
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String splitSOKHItem(String lineItemId, String coHeaderId) {
        lineItemId = BPUtility.getDecodedString(lineItemId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            ServiceJobService.splitSOKHItem(lineItemId);
            return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
    * Name: removeSOLineItem
    * Desc: Method to remove service order line item
    * @param:  (1)lineItemId - String - id of line item
    * @return: void
    **/
    public static void removeSOLineItem(String lineItemId) {
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        lineItemId = BPUtility.escapeSingleQuotes(lineItemId);

        List<Service_Order_Line_Item__c> soliList = [SELECT Service_Order_Header__r.Work_Status__c, Deal__c, Labour_Code__c, Sublet__c, 
                                                            Labour_Code__r.Calculate_Supplies__c, 
                                                            (Select Id from Vendor_Order_Line_Items__r 
																where Sublet__c != null AND Vendor_Order_Line_Item_Group__c != null 
																AND Vendor_Order_Header__r.Status__c != 'Open' AND 
																Vendor_Order_Header__r.Status__c != 'Locked') 
                                                            FROM Service_Order_Line_Item__c WHERE Id =: lineItemId];
        
        if(soliList.size() > 0 && soliList[0].Service_Order_Header__r.Work_Status__c != 'Invoiced') {
        	if(soliList[0].Sublet__c != null && soliList[0].Vendor_Order_Line_Items__r.size() > 0) {
        		throw new BlackpurlException('{"HasError" : true, "ErrorMsg" : "Can not remove sublet that is already ordered."}');
        	}
            String dealId = soliList[0].Deal__c;
            if(String.isNotBlank(dealId)) {
                createDealUnresolvedFulfillment(new List<String>{soliList[0].Id}, dealId, Constants.UNRESOLVED_FULFILLMENT_TYPE_REMOVED);
            }
            
            String serviceJobId;
            Boolean isRecalculateShopSupply = false;
            if(soliList[0].Labour_Code__c != null && soliList[0].Labour_Code__r.Calculate_Supplies__c) {
                isRecalculateShopSupply = true;
                serviceJobId = soliList[0].Service_Order_Header__c;
            }
            
            if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete soliList;
            
            if(isRecalculateShopSupply) {
                ShopSuppliesService.shopSuppliesCalculation(serviceJobId);
            }
        }
    }
    
    /**
    * Name: removeSOKHItems
    * Desc: Method to add Line Items in Items Grid.
    * @param:  (1)lineItemId - String - id of line item
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    public static void removeSOKHItems(String lineItemId) {
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        lineItemId = BPUtility.escapeSingleQuotes(lineItemId);

        List<Service_Order_Kit_Header__c> sokhList = [select Service_Order_Header__r.Work_Status__c, Deal__c, 
                                    (Select Id from Service_Order_Line_Items__r) from Service_Order_Kit_Header__c where Id =: lineItemId];
        
        List<SObject> sObjectListToDelete = new List<SObject>();
        if(sokhList.size() > 0 && sokhList[0].Service_Order_Header__r.Work_Status__c != 'Invoiced') {
        for(Service_Order_Kit_Header__c sokhRec : sokhList) {
            if(sokhRec.Service_Order_Line_Items__r != null && sokhRec.Service_Order_Line_Items__r.size() > 0) {
                sObjectListToDelete.addAll((List<SObject>) sokhRec.Service_Order_Line_Items__r);
            }
        }
        sObjectListToDelete.addAll((List<SObject>) sokhList);
        }
        if(sObjectListToDelete.size() > 0) {
            if(sokhList.size() > 0) {
                if(String.isNotBlank(sokhList[0].Deal__c)) {
                    createDealUnresolvedFulfillment(new List<String>{sokhList[0].Id}, sokhList[0].Deal__c, Constants.UNRESOLVED_FULFILLMENT_TYPE_REMOVED);
                }
            }
            if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete sObjectListToDelete;
        }
    }  
    
    /**
    * Name: insertKitHeaderInGrid
    * Desc: Method to insert kit header in Grid
    * @param:   (1)lineItemId - String - id of line item
    *           (2)soHeaderId - String - id of Service Order Header
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    public static Id insertKitHeaderInGrid(String lineItemId, String soHeaderId) {
        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        String dealId;
        String dealItemId;
        List<Service_Order_Header__c> serviceOrderHeaderList = [Select Deal__c, Deal_Item__c from Service_Order_Header__c where Id = :soHeaderId];
        if(serviceOrderHeaderList.size() > 0) {
            dealId = serviceOrderHeaderList[0].Deal__c;
            dealItemId = serviceOrderHeaderList[0].Deal_Item__c;
        }
        List<Kit_Header__c> kitHeaderList = SOQLUtil.getKitHeaderRec(new Map<String, String>{ 'Id' => lineItemId });
        if(kitHeaderList.size() == 0) {
            return null;
        }
        Service_Order_Kit_Header__c sokhRec = new Service_Order_Kit_Header__c();
        sokhRec.Service_Order_Header__c = soHeaderId;
        sokhRec.Kit_Header__c = kitHeaderList[0].Id;
        sokhRec.Can_Split__c = kitHeaderList[0].Can_Split__c;
        sokhRec.Code__c = kitHeaderList[0].Code__c;
        sokhRec.Description__c = kitHeaderList[0].Description__c;
        sokhRec.Fixed_Price__c = kitHeaderList[0].Fixed_Price__c;
        sokhRec.Fixed_Price_Flag__c = kitHeaderList[0].Fixed_Price_Flag__c;
        sokhRec.Is_Fixed_Kit_Header_SO__c = false; // kitHeaderList[0].Fixed_Price_Flag__c Changed by richa 23/11/2016
        sokhRec.Service_Kit__c = kitHeaderList[0].Service_Kit__c;
        sokhRec.Actual_Kit_Price__c = kitHeaderList[0].Fixed_Price__c;
        sokhRec.Deal_Item__c = dealItemId;
        sokhRec.Deal__c = dealId;
        insert sokhRec;
        insertAllKitLineItems(lineItemId, soHeaderId, sokhRec.Id, dealItemId, dealId);
        
        
        if(String.isNotBlank(dealId)) {
            createDealUnresolvedFulfillment(new List<String>{sokhRec.Id}, dealId, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);
        }
        // system.assert(false,soliListToInsert);
        return sokhRec.Id;
    }
    
    private static Boolean hasLabor = false;
    /**
    * Name: insertAllKitLineItems
    * Desc: Method to add Kit Line Items in Items Grid.
    * @param:   (1)lineItemId - String - id of line item
    *           (2)soHeaderId - String - id of Service Order Header
    *           (3)sokhRecId - String - id of service order kit header
                (4)dealItemId - String - id of deal Item
    * @return: void
    **/
    private static void insertAllKitLineItems(String lineItemId, String soHeaderId, String sokhRecId, String dealItemId, String dealId) {
        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        

        List<Kit_Header_Line_Item__c> khLineItemList = SOQLUtil.getKHLineItemRec(new Map<String, String>{ 'Kit_Header__c' => lineItemId });
        if(khLineItemList.size() == 0) {
            return;
        }
        //system.assert(false,khLineItemList);  
        List<Service_Order_Line_Item__c> soliListToInsert = new List<Service_Order_Line_Item__c>();
        for(Kit_Header_Line_Item__c khliRec : khLineItemList) {
            Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c(Kit_Header_Line_Item__c = khliRec.Id);
            
            soliRec.Service_Order_Header__c = soHeaderId;
            soliRec.Service_Order_Kit_Header__c = sokhRecId;
            soliRec.Fixed_Price__c = khliRec.Fixed_Price__c;
            soliRec.Is_Fixed_Kit_LineItem_SO__c = false; // khliRec.Fixed_Price__c Changed by richa 23/11/2016
            soliRec.Part__c = khliRec.Part__c;
            soliRec.Labour_Code__c = khliRec.Labour_Code__c;
            if(soliRec.Labour_Code__c != null) {
                hasLabor = true;
            }
            soliRec.Deal_Item__c = dealItemId;
            if(khliRec.Labour_Code__c != null) {
                //soliRec.Fixed_Price__c = khliRec.Labour_Code__r.Fixed_Rate__c;
            }            
            if(khliRec.Fee__c != null) { // Richa Added 16/11/2016
                soliRec.Fee__c = khliRec.Fee__c;
            }
            soliRec.Kit_Price__c = (khliRec.Kit_Price__c != null) ? khliRec.Kit_Price__c : 0;
            soliRec.Price_When_Tax_Included__c = soliRec.Kit_Price__c;
            soliRec.Actual_Kit_Price__c = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
            soliRec.Qty_Needed__c = khliRec.Qty_Needed__c;
            soliRec.Item_Code__c = khliRec.Item_Code__c;
            soliRec.Item_Description__c = khliRec.Item_Description__c;
            soliRec.Deal__c = dealId;
            soliListToInsert.add(soliRec);
        }
        if(soliListToInsert.size() > 0) {
            insert soliListToInsert;
        }

    }
    
    /**
    * Name: insertPartInGrid
    * Desc: Method to insert part in Grid.
    * @param:   (1)lineItemId - String - id of line item
    *           (2)soHeaderId - String - id of Service Order Header
    * @return: void
    **/
    public static List<Service_Order_Line_Item__c> insertPartInGrid(String lineItemId, String soHeaderId, Decimal qty) {
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Part__c> partList = [select Part_Number__c, Enviro_Fee__c, Enviro_Fee_Code__c, Enviro_Fee_Code__r.Code__c, 
                                            Enviro_Fee_Code__r.Description__c from Part__c where Id =: lineItemId];
        if(partList.size() == 0) {
            return null;
        }
        
        List<Service_Order_Header__c> serviceOrderHeaderList = [Select Deal__c, Deal_Item__c from Service_Order_Header__c where Id = :soHeaderId];
        Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c();
        soliRec.Service_Order_Header__c = soHeaderId;
        soliRec.Part__c = partList[0].Id;
        soliRec.Qty_Needed__c = qty;
        if(serviceOrderHeaderList.size() > 0) {
            soliRec.Deal__c = serviceOrderHeaderList[0].Deal__c;
            soliRec.Deal_Item__c = serviceOrderHeaderList[0].Deal_Item__c;
        }
        //soliRec.Kit_Price__c = (partList[0].Retail_Price__c != null) ? partList[0].Retail_Price__c : 0;
        soliRec.Actual_Kit_Price__c = (soliRec.Kit_Price__c == null) ? 0 : soliRec.Kit_Price__c;
        //insert soliRec;
        
        List<Service_Order_Line_Item__c> soliListToInsert = new List<Service_Order_Line_Item__c>();
        soliListToInsert.add(soliRec);
        Service_Order_Line_Item__c relatedEnvFeeRec = new Service_Order_Line_Item__c();
        if(partList[0].Enviro_Fee__c != null && partList[0].Enviro_Fee_Code__c != null) {
            relatedEnvFeeRec = insertFeeInGrid(partList[0].Enviro_Fee_Code__c, soHeaderId, true, partList[0], 1);
            soliListToInsert.add(relatedEnvFeeRec);
        }
        
        insert soliListToInsert;
        createDealUnresolvedFulfillment(new List<String>{soliRec.Id}, soliRec.Deal__c, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);
        
        // Create Deal Unresoled Fulfillment for Env Fee Line item.
        if(partList[0].Enviro_Fee__c != null && soliListToInsert.size() > 1) {
            createDealUnresolvedFulfillment(new List<String>{relatedEnvFeeRec.Id}, relatedEnvFeeRec.Deal__c, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);
        }
        return soliListToInsert;
    }
    
    
    /**
    * Name: insertLabourInGrid
    * Desc: Method to insert labour in Grid
    * @param:   (1)lineItemId - String - id of line item
    *           (2)soHeaderId - String - id of Service Order Header
    * @return: void
    **/
    public static Labour_Code__c insertLabourInGrid(String lineItemId, String soHeaderId, Decimal qty) {
        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        

        List<Labour_Code__c> labourList = SOQLUtil.getLabourRecords(new Set<Id>{lineItemId}, null);
        if(labourList.size() == 0) {
            return null;
        }
        
        List<Service_Order_Header__c> serviceOrderHeaderList = [Select Deal__c, Deal_Item__c from Service_Order_Header__c where Id = :soHeaderId];
        
        Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c();
        soliRec.Service_Order_Header__c = soHeaderId;
        soliRec.Labour_Code__c = labourList[0].Id;
        soliRec.Qty_Needed__c = (qty != null) ? qty : labourList[0].Hours__c; // Ticket#1841: 1-> labourList[0].Hours__c: Changed By Pooja 10 Apr. 2017;
        soliRec.Qty_Committed__c = 1;
        soliRec.Kit_Price__c = (labourList[0].Rate__c != null) ? labourList[0].Rate__c : 0;
        soliRec.Actual_Kit_Price__c = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
        if(serviceOrderHeaderList.size() > 0) {
            soliRec.Deal__c = serviceOrderHeaderList[0].Deal__c;
            soliRec.Deal_Item__c = serviceOrderHeaderList[0].Deal_Item__c;
        }
        insert soliRec;
        createDealUnresolvedFulfillment(new List<String>{soliRec.Id}, soliRec.Deal__c, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);
        
        return labourList[0];
    }
    
    /**
    * Name: insertFeeInGrid
    * Desc: Method to insert fee in Grid
    * @param:   (1)lineItemId - String - id of line item
    *           (2)soHeaderId - String - id of Service Order Header
    * @return: void
    **/
    public static Service_Order_Line_Item__c insertFeeInGrid(String lineItemId, String soHeaderId, Boolean isEnvFee, Part__c partRecHavingEnvFee, Decimal qty) {
        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Fee__c> feeList = SOQLUtil.getFeeByFieldName(new Map<String, String>{'Id' => lineItemId});
        if(feeList.size() == 0) {
            return new Service_Order_Line_Item__c();
        }
        
        List<Service_Order_Header__c> serviceOrderHeaderList = [Select Deal__c, Deal_Item__c from Service_Order_Header__c where Id = :soHeaderId];
        
        Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c();
        soliRec.Service_Order_Header__c = soHeaderId;
        soliRec.Fee__c = feeList[0].Id;
        soliRec.Qty_Needed__c = qty;
        soliRec.Qty_Committed__c = 1;
        soliRec.Kit_Price__c = (feeList[0].Price__c != null) ? feeList[0].Price__c : 0;
        soliRec.Actual_Kit_Price__c = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
        if(isEnvFee && partRecHavingEnvFee.Id != null) {
            soliRec.Is_Environmental_Fee__c = isEnvFee;
            soliRec.Kit_Price__c = (partRecHavingEnvFee.Enviro_Fee__c != null) ? partRecHavingEnvFee.Enviro_Fee__c : 0;
            soliRec.Actual_Kit_Price__c = soliRec.Kit_Price__c;
            soliRec.Price_When_Tax_Included__c = soliRec.Kit_Price__c;
            soliRec.Item_Code__c = partRecHavingEnvFee.Enviro_Fee_Code__r.Code__c;
            soliRec.Item_Description__c = partRecHavingEnvFee.Part_Number__c + ' ' + partRecHavingEnvFee.Enviro_Fee_Code__r.Description__c;
        } 
        
        if(serviceOrderHeaderList.size() > 0) {
            soliRec.Deal__c = serviceOrderHeaderList[0].Deal__c;
            soliRec.Deal_Item__c = serviceOrderHeaderList[0].Deal_Item__c;
        }
        if(!isEnvFee) {
            insert soliRec;
            createDealUnresolvedFulfillment(new List<String>{soliRec.Id}, soliRec.Deal__c, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);
        }
        return soliRec;
    }
    
    /**
    * Name: insertProductInGrid
    * Desc: Method to insert product in Grid
    * @param:   (1)lineItemId - String - id of line item
    *           (2)soHeaderId - String - id of Service Order Header
    * @return: void
    **/
    public static String insertProductInGrid(String lineItemId, String soHeaderId, Decimal qty) {
        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        

        List<Product__c> productList = SOQLUtil.getProductRecordsById(new List<Id>{lineItemId});
        if(productList.size() == 0) {
            return null;
        }
        
        List<Service_Order_Header__c> serviceOrderHeaderList = [Select Deal__c, Deal_Item__c from Service_Order_Header__c where Id = :soHeaderId];
        
        Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c();
        soliRec.Service_Order_Header__c = soHeaderId;
        soliRec.Sublet__c = productList[0].Id;
        soliRec.Status__c = soliRec.Id != null ? soliRec.Status__c : 'Required';
        soliRec.Qty_Committed__c = 0;
        soliRec.Qty_Needed__c = (qty != null && qty != 0) ? qty : 1;
        soliRec.Kit_Price__c = (productList[0].Price__c != null) ? productList[0].Price__c : 0;
        soliRec.Actual_Kit_Price__c = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
        if(serviceOrderHeaderList.size() > 0) {
            soliRec.Deal__c = serviceOrderHeaderList[0].Deal__c;
            soliRec.Deal_Item__c = serviceOrderHeaderList[0].Deal_Item__c;
        }
        insert soliRec;
        
        createDealUnresolvedFulfillment(new List<String>{soliRec.Id}, soliRec.Deal__c, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);
        return soliRec.Id;
    }
    
    /**
    * Name: saveHoursLogged
    * Desc: Method to save hours logged
    * @param:   (1)hoursLoggedJSONString - String - hours Logged 
    *           (2)coHeaderId - String - id of coHeader
    * @return: String -Hours Logged List
    **/
    @remoteAction
    global static String saveHoursLogged(String hoursLoggedJSONString, String coHeaderId) {
        hoursLoggedJSONString = BPUtility.getDecodedString(hoursLoggedJSONString);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);        
        try{
            String reponse = saveHoursLoggedRec(hoursLoggedJSONString, coHeaderId);         
            if(reponse.contains('[]') || reponse.contains('HasError')) {
                return BPUtility.getEncodedString(reponse);
            }
            List<Service_Order_Header__c> soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => reponse});
            
            List<SOHeaderWrapper.HoursLogged> hoursLoggedList = new List<SOHeaderWrapper.HoursLogged>();
            for(Hours_Logged__c hourLoggedRec : soHeaderRecList[0].Hours_Logged__r) {
                hoursLoggedList.add(new SOHeaderWrapper.HoursLogged(hourLoggedRec));
            }
            return BPUtility.getEncodedString(System.JSON.serialize(hoursLoggedList));  
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    public static String saveHoursLoggedRec(String hoursLoggedJSONString, String coHeaderId) {      
        if(AccessControl.ifObjectFieldIsCreateable('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        SOHeaderWrapper.HoursLogged hoursLoggedObj = (SOHeaderWrapper.HoursLogged) System.JSON.deserialize(hoursLoggedJSONString, SOHeaderWrapper.HoursLogged.class);
        Hours_Logged__c hours = new Hours_Logged__c();
        hours.Id = hoursLoggedObj.Id;
        hours.Technician__c = hoursLoggedObj.EmployeeId;
        hours.Notes__c = hoursLoggedObj.Notes;
        /*hours.Remaining_Estimate_d__c = hoursLoggedObj.RemainingEstimate_D;
        hours.Remaining_Estimate_h__c = hoursLoggedObj.RemainingEstimate_H;
        hours.Remaining_Estimate_m__c = hoursLoggedObj.RemainingEstimate_M;
        hours.Original_Estimate__c = hoursLoggedObj.OriginalEstimate;
        hours.Previously_Logged__c = hoursLoggedObj.PreviouslyLogged;*/
        
        hours.Service_Order_Header__c = hoursLoggedObj.SOHeaderId;
        Integer hoursValue = 0;
        Integer minutesValue = 0;
        if(hoursLoggedObj.TimeSpent_H != null) {
            hoursValue = hoursLoggedObj.TimeSpent_H.intValue();
            minutesValue = ((hoursLoggedObj.TimeSpent_H - hoursLoggedObj.TimeSpent_H.intValue())*60).intValue();
        }
        hours.Time_Spent_d__c = hoursLoggedObj.TimeSpent_D;
        hours.Time_Spent_h__c = (Decimal)hoursValue;
        hours.Time_Spent_m__c = (Decimal)minutesValue;
        
        if(hoursLoggedObj.StartDate != null) {
            DateTime dtValue = HomeSearchFilterInterface.getDateFromString(hoursLoggedObj.StartDate);
            hours.Work_Performed_Date__c = (dtValue != null) ? Date.valueOf(dtValue) : null;
            hours.Start_Date_Time__c = BPUtility.createDateTimeFromStr(dtValue, hoursLoggedObj.TimeIn);
            hours.End_Date_Time__c = BPUtility.createDateTimeFromStr(dtValue, hoursLoggedObj.TimeOut);
        } else {
            hours.Work_Performed_Date__c = null;
            hours.Start_Date_Time__c = hours.End_Date_Time__c = null;
        }
        hours.Notes_Required__c = hoursLoggedObj.NotesRequired;            
        List<Hours_Logged__c> existingHoursLoggedList = [Select Id from Hours_Logged__c where Technician__c =: hours.Technician__c
                                                            AND ((Start_Date_Time__c >=: hours.Start_Date_Time__c AND Start_Date_Time__c <=: hours.Start_Date_Time__c.addSeconds(59))
                                                                    OR (End_Date_Time__c >=: hours.End_Date_Time__c AND End_Date_Time__c <=: hours.End_Date_Time__c.addSeconds(59))) 
                                                            AND Id !=: hours.Id];
        if(existingHoursLoggedList.size() > 0) {
            return '[{"HasError" : true, "ErrorMsg" : "' + Label.Payroll_Already_exists_error + '"}]';
        } else {
            Long dt1Long = hours.Start_Date_Time__c.getTime();
            Long dt2Long = hours.End_Date_Time__c.getTime();
            Long milliseconds = dt2Long - dt1Long;
            Long seconds = milliseconds / 1000;
            Long minutes = (seconds / 60);
            Long hoursVal = minutes / 60;
            Long days = hoursVal / 24;
            hours.Time_Spent_d__c = days;
            hours.Time_Spent_h__c = math.mod(hoursVal, 24);
            hours.Time_Spent_m__c = math.mod(minutes, 60);
            
            upsert hours;
            calculateTechinicianHours(new Set<Id>{hours.Id}, null);
        
            // Return Hours Logged List in JSON Format for current SO Header Record.
            String soHeaderId = hoursLoggedObj.SOHeaderId;
            List<Service_Order_Header__c> soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => soHeaderId});
            if(soHeaderRecList.size() == 0) {
                return '[]';
            }
        
            Service_Order_Header__c soHeaderRec = soHeaderRecList[0];
            if(Constants.SOStatusToPriorityMap.get(soHeaderRec.Work_Status__c) < 3) {
                soHeaderRec.Work_Status__c = 'In Progress';
                soHeaderRec.Status__c = 'In Progress';
                update soHeaderRec;
            }
        }
        return hoursLoggedObj.SOHeaderId;  
    }
        
    public static void calculateTechinicianHours(Set<Id> hoursLoggedIdList, Set<Id> soHeaderIds){
        if(AccessControl.ifObjectFieldIsAccessible('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Technician_Hour__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Technician_Hour__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Technician_Hour__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                
        Set<Id> soHeaderIdSet = new Set<Id>();
        if(hoursLoggedIdList != null){
            List<Hours_Logged__c> hoursLoggedList = [select Id, Service_Order_Header__c 
                                                            from Hours_Logged__c
                                                            where Id IN : hoursLoggedIdList];
                                                            
            for(Hours_Logged__c hourlog : hoursLoggedList){
                if(hourlog.Service_Order_Header__c != null){
                    soHeaderIdSet.add(hourlog.Service_Order_Header__c);
                }
            }
        }else if(soHeaderIds != null){
            soHeaderIdSet = soHeaderIds;
        }else{
            return;
        }
        
        List<Service_Order_Header__c> serviceOrderList = [select Id, 
                                                            (select Id, Total_Hours__c, Time_Spent_d__c, Time_Spent_h__c, Time_Spent_m__c, Technician__c, Service_Order_Header__c
                                                            from Hours_Logged__r),
                                                            (select Qty_Needed__c 
                                                            from Service_Order_Line_Items__r
                                                            where Labour_Code__c != NULL),
                                                            (select Id, Technician__c, Service_Order_Header__c, Total_Hours__c 
                                                            from Technician_Hours__r)
                                                            from Service_Order_Header__c
                                                            where Id IN : soHeaderIdSet];
                                            
        Map<String,Decimal> soHeaderIdtoBilledHoursMap = new Map<String, Decimal>();    
        Map<String,Map<String, Decimal>> soHeaderIdtoEmployeeIdtoHoursLogMap = new Map<String, Map<String, Decimal>>();
        Map<String,Map<String, String>> soHeaderIdtoEmployeeIdtoTechnicianHourIdMap = new Map<String, Map<String, String>>();
        Map<String,Decimal> soHeaderIdHoursLoggedMap = new Map<String, Decimal>();  
        Set<Id> employeeIdSet = new Set<Id>();  
        for(Service_Order_Header__c soHeader : serviceOrderList){
            for(Service_Order_Line_Item__c soli : soHeader.Service_Order_Line_Items__r){
                if(!soHeaderIdtoBilledHoursMap.containsKey(soHeader.Id)){
                    soHeaderIdtoBilledHoursMap.put(soHeader.Id, 0);
                }
                if(soli.Qty_Needed__c != null){
                    soHeaderIdtoBilledHoursMap.put(soHeader.Id, (soHeaderIdtoBilledHoursMap.get(soHeader.Id)+soli.Qty_Needed__c));
                }
            }   
            for(Hours_Logged__c HL : soHeader.Hours_Logged__r){
                if(!soHeaderIdtoEmployeeIdtoHoursLogMap.containsKey(HL.Service_Order_Header__c)){
                    soHeaderIdtoEmployeeIdtoHoursLogMap.put(HL.Service_Order_Header__c, new Map<String, Decimal>());
                }
                if(HL.Technician__c != null && !soHeaderIdtoEmployeeIdtoHoursLogMap.get(HL.Service_Order_Header__c).containsKey(HL.Technician__c)){
                    soHeaderIdtoEmployeeIdtoHoursLogMap.get(HL.Service_Order_Header__c).put(HL.Technician__c, 0);
                    employeeIdSet.add(HL.Technician__c);
                }
                if(HL.Technician__c != null && HL.Total_Hours__c != null){
                    soHeaderIdtoEmployeeIdtoHoursLogMap.get(HL.Service_Order_Header__c).put(HL.Technician__c, soHeaderIdtoEmployeeIdtoHoursLogMap.get(HL.Service_Order_Header__c).get(HL.Technician__c)+HL.Total_Hours__c);
                }
                
                if(!soHeaderIdHoursLoggedMap.containsKey(HL.Service_Order_Header__c)){
                    soHeaderIdHoursLoggedMap.put(HL.Service_Order_Header__c, 0);
                }
                if(HL.Total_Hours__c != null){
                    soHeaderIdHoursLoggedMap.put(HL.Service_Order_Header__c, soHeaderIdHoursLoggedMap.get(HL.Service_Order_Header__c)+HL.Total_Hours__c);
                }
            }
            for(Technician_Hour__c TH : soHeader.Technician_Hours__r){
                if(!soHeaderIdtoEmployeeIdtoTechnicianHourIdMap.containsKey(TH.Service_Order_Header__c)){
                    soHeaderIdtoEmployeeIdtoTechnicianHourIdMap.put(TH.Service_Order_Header__c, new Map<String, String>());
                }
                if(!soHeaderIdtoEmployeeIdtoTechnicianHourIdMap.get(TH.Service_Order_Header__c).containsKey(TH.Technician__c)){
                    soHeaderIdtoEmployeeIdtoTechnicianHourIdMap.get(TH.Service_Order_Header__c).put(TH.Technician__c, null);
                }
                soHeaderIdtoEmployeeIdtoTechnicianHourIdMap.get(TH.Service_Order_Header__c).put(TH.Technician__c, TH.Id);
            }       
        }                               
        if(AccessControl.ifObjectFieldIsAccessible('user') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        Map<Id, Technician__c> employeeIdtoNameMap = new Map<Id, Technician__c>([select Id, Technician_Name__c
                                                                    from Technician__c
                                                                    where Id IN :employeeIdSet]);
                                                                    
        List<Service_Order_Header__c> soHeaderListToUpdate = new List<Service_Order_Header__c>();                                                           
        Service_Order_Header__c soHeaderRec;
        List<Technician_Hour__c> technicianHoursList = new List<Technician_Hour__c>();
        Technician_Hour__c technicianHoursObj;
        for(String soHeaderId : soHeaderIdtoEmployeeIdtoHoursLogMap.keySet()){ 
            Decimal TotalHoursLogged = 0;
            soHeaderRec = new Service_Order_Header__c();
            soHeaderRec.Id = soHeaderId;
            String techniciansNames = '';
            for(String employeeId : soHeaderIdtoEmployeeIdtoHoursLogMap.get(soHeaderId).keySet()){
                TotalHoursLogged += soHeaderIdtoEmployeeIdtoHoursLogMap.get(soHeaderId).get(employeeId);
            }
            for(String employeeId : soHeaderIdtoEmployeeIdtoHoursLogMap.get(soHeaderId).keySet()){
                if(String.isBlank(employeeId)) {
                    continue;
                }
                techniciansNames += employeeIdtoNameMap.get(employeeId).Technician_Name__c+';';
                technicianHoursObj = new Technician_Hour__c();
                if(soHeaderIdtoEmployeeIdtoTechnicianHourIdMap.containsKey(soHeaderId) 
                    && soHeaderIdtoEmployeeIdtoTechnicianHourIdMap.get(soHeaderId).containsKey(employeeId)){
                    technicianHoursObj.Id = soHeaderIdtoEmployeeIdtoTechnicianHourIdMap.get(soHeaderId).get(employeeId);
                }else{
                    technicianHoursObj.Service_Order_Header__c = soHeaderId;
                }
                technicianHoursObj.Technician__c = employeeId;
                //System.assert(false, soHeaderIdtoBilledHoursMap);
                if(TotalHoursLogged == 0 || !soHeaderIdtoBilledHoursMap.containsKey(soHeaderId)){
                    technicianHoursObj.Total_Hours__c = 0;
                }else{
                    technicianHoursObj.Total_Hours__c = (soHeaderIdtoEmployeeIdtoHoursLogMap.get(soHeaderId).get(employeeId)/TotalHoursLogged)*soHeaderIdtoBilledHoursMap.get(soHeaderId);
                }
                technicianHoursList.add(technicianHoursObj);
            }
            if(techniciansNames.length() >= 1){
                techniciansNames = techniciansNames.substring(0, techniciansNames.length() > 255 ? 255 :techniciansNames.length()-1);
                soHeaderRec.Technician_Name__c = techniciansNames; 
            }
            if(soHeaderIdHoursLoggedMap.containsKey(soHeaderId)){
                soHeaderRec.Hrs_Logged__c = soHeaderIdHoursLoggedMap.get(soHeaderId);
            }
            soHeaderListToUpdate.add(soHeaderRec);
        }
        //System.assert(false, technicianHoursList);        
        upsert soHeaderListToUpdate;
        upsert technicianHoursList;  
         
    }
    
    // Merchandise section
   /**
    * Name: insertFeeInMerchGrid
    * Desc: Method to insert Fee in Merch Grid
    * @param:   (1)lineItemId - String - id of line item
                (2)coHeaderId - String - id of coHeader
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @remoteAction
    global static String insertFeeInMerchGrid(String lineItemId, String coHeaderId) {
        lineItemId = BPUtility.getDecodedString(lineItemId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            

            List<Fee__c> feeList = SOQLUtil.getFeeByFieldName(new Map<String, String>{'Id' => lineItemId});
            if(feeList.size() == 0) {
                return getCOHeaderDetailsByGridName(coHeaderId, 'coHeader,coLineItem,user,coInvoiceHeader,checkOut,specialOrder');
            }
            
            List<CO_Line_Item__c> coliListToInsert = new List<CO_Line_Item__c>();
            List<CO_Line_Item__c> coliList = [Select Id from CO_Line_Item__c where Service_Order_Line_Item__c = null AND CO_Header__c =: coHeaderId];
            if(coliList.size() == 0) {
                List<SObject> sObjectListToInsert = addLinkedFee(coHeaderId, null, 'Merchandise');
                if(sObjectListToInsert != null && sObjectListToInsert.size() > 0) {
                    coliListToInsert.addAll((List<CO_Line_Item__c>) sObjectListToInsert);
                }
            }
            
            if(String.isBlank(coHeaderId)) {
                coHeaderId = BPUtility.getDecodedString(BPGlobalHeaderCtrl.createCustomerOrder());  
            }
            
            CO_Line_Item__c coliRec = new CO_Line_Item__c();
            coliRec.CO_Header__c = coHeaderId;
            coliRec.Fee__c = feeList[0].Id;
            coliRec.Qty__c = 1;
            coliRec.Qty_Committed__c = coliRec.Qty__c;
            coliRec.Price__c = (feeList[0].Price__c != null) ? feeList[0].Price__c : 0;
            coliRec.Retail__c = coliRec.Price__c;
            coliListToInsert.add(coliRec);
            insert coliListToInsert;
            
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coHeader,coLineItem,user,coInvoiceHeader,checkOut,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    
    /**
    * Name: insertKitHeaderInMerchGrid
    * Desc: Method to insert kit header Merch Grid
    * @param:   (1) lineItemId - String - id of line item
                (2) coHeaderId - String - id of coHeader 
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @remoteAction
    global static String insertKitHeaderInMerchGrid(String lineItemId, String coHeaderId) {
        lineItemId = BPUtility.getDecodedString(lineItemId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            MerchandiseService.insertMerchKit(lineItemId, coHeaderId);
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coLineItem,user,coInvoiceHeader,checkOut,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
        
    /**
    * Name: updateCOKHLineItems
    * Desc: Method to update line items.
    * @param:   (1)coKHItemJSON - String - kit header string 
                (2)coHeaderId - String - id of coHeader
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String updateCOKHLineItems(String coKHItemJSON, String coHeaderId) {
        coKHItemJSON = BPUtility.getDecodedString(coKHItemJSON);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            COHeaderWrapper.COKitHeader coGridObj = (COHeaderWrapper.COKitHeader) System.JSON.deserialize(coKHItemJSON, COHeaderWrapper.COKitHeader.class);
    
            if(coGridObj.Id == null) {
                return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coLineItem,coInvoiceHeader,user,checkOut,specialOrder'));
            }
            
            //error = SO_KLI_Recalculation.updateSOKitHeader(sokhObj);
            
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coLineItem,coInvoiceHeader,user,checkOut,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    
     /**
    * Name: updateCOKHLineItemsRecalculation
    * Desc: Method to add Line Items in Items Grid.
    * @param:   (1) coKHItemJSON - String - kit header items string
                (2) coHeaderId - id of coHeader
                (3) CokHLineItemJson -  kit header line items 
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String updateCOKHLineItemsRecalculation(String coKHItemJSON, String coHeaderId,String CokHLineItemJson) {
        coKHItemJSON = BPUtility.getDecodedString(coKHItemJSON);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        CokHLineItemJson = BPUtility.getDecodedString(CokHLineItemJson);
        try{
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            COHeaderWrapper.COKitHeader coGridObj = (COHeaderWrapper.COKitHeader) System.JSON.deserialize(coKHItemJSON, COHeaderWrapper.COKitHeader.class);            
            if (CokHLineItemJson != 'null'){    
                 COLineItem  coLi = (COLineItem) System.JSON.deserialize(CokHLineItemJson,COLineItem.class);
                 //system.assert(false, coli);
                    if(coLi.IsFee){ // if Added by pooja 23 Nov. 2016 (Issue# Fee description is not editable either when it is fixed or unfixed)
                        CO_Line_Item__c  ColiChecktoUpdate  = [select Id, Item_Description__c from CO_Line_Item__c where Id =:coLi.CoLineItemId ]; //Added by Hitesh 23 Nov. 2016: (Issue# Fee 
                        if(ColiChecktoUpdate.Item_Description__c != coLi.ItemDescription){ //If Added by Hitesh 23 Nov. 2016: (Issue# Fee description is not editable)
                            ColiChecktoUpdate.Item_Description__c = coLi.ItemDescription;
                            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                            update ColiChecktoUpdate;
                        }                       
                    }
                    if(!coLi.IsFixedPrice && coLi.partId !=null ){
                        String Result = COKH_Recalcualtion.UpdateKitLineItem(coGridObj,coLi,coHeaderId);
                        if(Result != 'Success'){
                                error =new SO_KLI_Recalculation.Errorhandler('300',Result);
                        }else{
                            error =new SO_KLI_Recalculation.Errorhandler('200','Saved Successfully');                       
                            }                            
                        }   else if(!coLi.IsFixedPrice && coLi.partId ==null && coLi.IsFee){ // else if Added by pooja 23 Nov. 2016: (Issue# Fee is not editable)
                                String Result = COKH_Recalcualtion.UpdateKitLineItem(coGridObj,coLi,coHeaderId);
                                if(Result != 'Success'){
                                        error =new SO_KLI_Recalculation.Errorhandler('300',Result);
                                }else{
                                    error =new SO_KLI_Recalculation.Errorhandler('200','Saved Successfully');                               
                                    }                             
                        } 
                }else{    
                            if(!coGridObj.IsFixedPrice){
                                 String Result = COKH_Recalcualtion.UpdateKitHeader(coGridObj);                                
                                    if(Result != 'Success'){
                                        error =new SO_KLI_Recalculation.Errorhandler('300',Result);
                                    }else{
                                        error =new SO_KLI_Recalculation.Errorhandler('200','Saved Successfully');                                    
                                    }
                        }  
            }                
            if(String.isNotBlank(coGridObj.DealId)) {
                return getDealDetails(BPUtility.getEncodedString(coGridObj.DealId), BPUtility.getEncodedString('dealUnresolvedFulfillmentAndDealFulfillment'));
            }        
            if(coGridObj.Id == null) {
                return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coLineItem,coInvoiceHeader,user,specialOrder'));//,specialOrder added by pooja 25 Nov. 2016
            }            
            //error = SO_KLI_Recalculation.updateSOKitHeader(sokhObj);            
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coLineItem,coInvoiceHeader,user,specialOrder'));//,specialOrder added by pooja 25 Nov. 2016               
                                        // (Issue# special order grid removed                                                                                                                                                                           // after editing KH or KHLI)
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
        
    /**
    * Name: removeLineItemsInMerchGrid
    * Desc: Method to remove line items in Merch Grid
    * @param:   (1) lineItemId - String - id of line item
                (2) coHeaderId - String - id of coHeader 
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String removeLineItemsInMerchGrid(String lineItemId, String coHeaderId) {
        lineItemId = BPUtility.getDecodedString(lineItemId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            String objectName = (Id.valueOf(lineItemId)).getSObjectType().getDescribe().getName();
            if(objectName == CONSTANTS.NAMESPACE + 'CO_Line_Item__c') {
                return deleteCOLineItem(BPUtility.getEncodedString(lineItemId), BPUtility.getEncodedString(coHeaderId));
            } else if(objectName == CONSTANTS.NAMESPACE + 'CO_Kit_Header__c') {
                String dealId = MerchandiseService.removeCOKHItems(lineItemId);
                if(String.isNotBlank(dealId)) {
                    return getDealDetails(BPUtility.getEncodedString(dealId), BPUtility.getEncodedString('dealUnresolvedFulfillmentAndDealFulfillment'));
                }
            } 
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coHeader,coLineItem,coInvoiceHeader,user,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');


    }
    
    /**
    * Name: splitCOKHItem
    * Desc: Method to split kit header itmes
    * @param:   (1) lineItemId - String - id of line item
                (2) coHeaderId - String - id of coHeader 
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @RemoteAction
    global static String splitCOKHItem(String lineItemId, String coHeaderId) {
        lineItemId = BPUtility.getDecodedString(lineItemId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            MerchandiseService.splitCOKHItem(lineItemId, coHeaderId);
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coLineItem,coInvoiceHeader,user'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
    * Name: getGridTotal
    * Desc: Method to get grid total    
    * @param:   (1) coHeaderId - String - id of coHeader
                (2) gridId - String - id of grid
                (3) gridName - String - name of grid
                (4) isAustralianMarket - Boolean - is australian markert or not 
    * @return: String - grid total
    **/
    @RemoteAction
    global static String getGridTotal(String coHeaderId, String gridId, String gridName, Boolean isAustralianMarket) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        gridId = BPUtility.getDecodedString(gridId);
        gridName = BPUtility.getDecodedString(gridName);
        try{
            Decimal total = 0;
            Decimal salesTax = 0;
            Decimal total_Part = 0;
            Decimal total_Laobur = 0;
            Decimal total_Sublet = 0;
            Decimal total_Fee = 0;
            Decimal total_ShopSupplies = 0;
            
            Map<String, Decimal> salesTaxNameToTaxRateValue = new Map<String, Decimal>();
            Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>();            
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            
            if((gridId == null && gridName == 'merchandise') || (gridId != null && gridName == 'dealMerchandise')) {
                List<CO_Line_Item__c> coLineItems;
                if(String.isBlank(gridId)) {
                    coLineItems = SOQLUtil.getCOLineItemByCOHeaderId(coHeaderId); 
                } else {
                    coLineItems = SOQLUtil.getCOLineItemByFieldValue(new Map<String, String>{'Deal__c' => gridId,
                                                                                            'Service_Order_Line_Item__c' => null});
                }
                if(!isTaxIncludingPricing) {
                    for(CO_Line_Item__c coLineItemRec : coLineItems) {
                        if(coLineItemRec.Part__c != null) {
                                total_Part += (coLineItemRec.Qty__c * coLineItemRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                        } else if(coLineItemRec.Fee__c != null) {
                                total_Fee += (coLineItemRec.Qty__c * coLineItemRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                        }
                    }
                } else {
                    for(CO_Line_Item__c coLineItemRec : coLineItems) {
                        if(coLineItemRec.Part__c != null) {
                            total_Part += (coLineItemRec.Qty__c * coLineItemRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                        } else if(coLineItemRec.Fee__c != null) {
                            total_Fee += (coLineItemRec.Qty__c * coLineItemRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                        }
                    }
                }
                /*List<Individual_Tax__c> individualItemsList = TaxCalculation.getApplicableTaxListFromCOLIList(coLineItems);
                salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemsList);*/
                
            } else if(gridId != null) {
                List<Service_Order_Line_Item__c> soLineItemList = SOQLUtil.getServiceOrderLineItemBySOHeader(gridId);
                if(!isTaxIncludingPricing) {
                    for(Service_Order_Line_Item__c soliRec : soLineItemList) {
                        soliRec.Qty_Needed__c = (soliRec.Qty_Needed__c != null) ? soliRec.Qty_Needed__c : 0;
                        soliRec.Kit_Price__c = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
                        if(soliRec.Labour_Code__c != null ) {
                            total_Laobur += (soliRec.Qty_Needed__c * soliRec.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
                        } else if(soliRec.Part__c != null) {
                            total_Part += (soliRec.Qty_Needed__c * soliRec.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
                        } else if(soliRec.Fee__c != null) {
                            if(soliRec.Type__c == Constants.SHOP_SUPPLY) {
                                total_ShopSupplies += (soliRec.Qty_Needed__c * soliRec.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
                            } else {
                                total_Fee += (soliRec.Qty_Needed__c * soliRec.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
                            }
                        } else if(soliRec.Sublet__c != null) {
                            total_Sublet += (soliRec.Qty_Needed__c * soliRec.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
                        }
                    }
                } else {
                    for(Service_Order_Line_Item__c soliRec : soLineItemList) {
                        soliRec.Qty_Needed__c = (soliRec.Qty_Needed__c != null) ? soliRec.Qty_Needed__c : 0;
                        soliRec.Price_When_Tax_Included__c = (soliRec.Price_When_Tax_Included__c != null) ? soliRec.Price_When_Tax_Included__c : 0;
                        if(soliRec.Labour_Code__c != null ) {
                            total_Laobur += (soliRec.Qty_Needed__c * soliRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                        } else if(soliRec.Part__c != null) {
                            total_Part += (soliRec.Qty_Needed__c * soliRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                        } else if(soliRec.Fee__c != null) {
                            if(soliRec.Type__c == Constants.SHOP_SUPPLY) {
                                total_ShopSupplies += (soliRec.Qty_Needed__c * soliRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                            } else {
                                total_Fee += (soliRec.Qty_Needed__c * soliRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                            }
                        } else if(soliRec.Sublet__c != null) {
                            total_Sublet += (soliRec.Qty_Needed__c * soliRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                        }
                    }
                }
                
                /*List<Individual_Tax__c> individualItemsList = TaxCalculation.getApplicableTaxListFromSOLIList(soLineItemList);
                salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemsList);*/
            }           
            total = total_Part + total_Laobur + total_Sublet + total_Fee + total_ShopSupplies;
            COHeaderWrapper.GridTotal gridTotal = new COHeaderWrapper.GridTotal(total, total_Part, total_Laobur, total_Sublet, total_Fee, total_ShopSupplies, salesTaxNameToTaxValue);
            return BPUtility.getEncodedString(System.JSON.serialize(gridTotal)); 
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(''); 
    }
        
    /*public static void UpdateServiceOrderTotals(Id ServiceOrderHeaderId, Id CoheaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        ServiceOrderHeaderId = BPUtility.escapeSingleQuotes(ServiceOrderHeaderId);

        list <Service_Order_Header__c> serviceOrderKitHeaderListToMove = new list <Service_Order_Header__c> ([select Id, Total__c, Tax_Amount__c,
                                                                                                                (select Id, Total__c, Tax_Amount__c from Service_Order_Line_Items__r)
                                                                                                                from Service_Order_Header__c
                                                                                                                where Id =  : ServiceOrderHeaderId]
                                                                                                            );
        for (Service_Order_Header__c serviceOrderHeaderRec : serviceOrderKitHeaderListToMove) {
            decimal total = 0;
            decimal taxAmount = 0;
            for (Service_Order_Line_Item__c serviceItemRec : serviceOrderHeaderRec.Service_Order_Line_Items__r) {
                total += serviceItemRec.Total__c;
                taxAmount += serviceItemRec.Tax_Amount__c;
            }
            serviceOrderHeaderRec.Total__c = total;
            serviceOrderHeaderRec.Tax_Amount__c = taxAmount;
        }   
        if (serviceOrderKitHeaderListToMove.size() > 0) {
            update serviceOrderKitHeaderListToMove;
        }   
    }*/

    public static String MoveFromSokhCOKH(String kitIdToMove,String sectionToMove,String CoheaderId){
        Savepoint sp = Database.setSavepoint();
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        

        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        

        if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        

        if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        kitIdToMove = BPUtility.escapeSingleQuotes(kitIdToMove);
        list<Service_Order_Kit_Header__c> serviceOrderKitHeaderListToMove = new list<Service_Order_Kit_Header__c>([select Id, Actual_Kit_Price__c,Service_Order_Header__r.CO_Header__r.Customer__c,Can_Split__c,Code__c,Description__c,Fixed_Price__c,
                                                                                                                Fixed_Price_Flag__c,Is_Fixed_Kit_Header_SO__c,Kit_Header__c,Service_Kit__c, Tax_amount__c,Service_Order_Header__r.CO_Header__c,
                                                                                                                Service_Order_Header__c, (Select Id, Service_Order_Header__c,CO_Line_Item__c,Actual_Kit_Price__c, Tax_Percent__c, Fixed_Price__c, Labour_Code__c, Labour_Code__r.Fixed_Rate__c, 
                                                                                                                Kit_Header_Line_Item__c, CO_Line_Item__r.Status__c, 
                                                                                                                CO_Line_Item__r.Vendor_Order_Header__c, 
                                                                                                                CO_Line_Item__r.VO_Number__c, CO_Line_Item__r.VO_Status__c, 
                                                                                                                CO_Line_Item__r.Expected_Delivery_Date__c
                                                                                                                From Service_Order_Line_Items__r)                                                                                                                 from Service_Order_Kit_Header__c where  Id =:kitIdToMove]);//, Labour_Code__r.Fixed_Rate__c: Added by pooja 6 Dec. 2016: in Service_Order_Line_Items__r
        boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();                                                                                                        
        if(sectionToMove!=null) {
        	
        	List<Vendor_Order_Line_Item__c> voliRecListToUpdate = new List<Vendor_Order_Line_Item__c>();
        	if(String.isNotBlank(serviceOrderKitHeaderListToMove[0].Id)) {
        		voliRecListToUpdate = [Select Id, CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c From Vendor_Order_Line_Item__c 
        																WHERE CO_Line_Item__r.Service_Order_Line_Item__r.Service_Order_Kit_Header__c =: serviceOrderKitHeaderListToMove[0].Id];
        	}
            COLineItemTriggerHelper.isMoveLineItem = true;
            removeSOKHItems(serviceOrderKitHeaderListToMove[0].Id);
            Id soKHId = insertKitHeaderInGrid(serviceOrderKitHeaderListToMove[0].Kit_Header__c, sectionToMove);
            COLineItemTriggerHelper.isMoveLineItem = false;
            
            //SO_KLI_Recalculation.SOPriceCalcultaionByPriceLevelForSOKitHeaders(serviceOrderKitHeaderListToMove[0].Service_Order_Header__r.CO_Header__r.Customer__c, CoheaderId, new List<Id>{soKHId}, sectionToMove);
            SO_KLI_Recalculation.soKitPriceCalculation(new Set<Id>{soKHId}, new Set<Id>(), CoheaderId);
            
            if(voliRecListToUpdate.size() > 0) {
            	updateVOLIANDCOLIOnMoveFromSokhCOKH(new Map<String, Id>{'Service_Order_Line_Item__r.Service_Order_Kit_Header__c' => soKHId}, serviceOrderKitHeaderListToMove, voliRecListToUpdate);
            }
            
            /**if(hasLabor) {
                //ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
                ShopSuppliesService.shopSuppliesCalculation(sectionToMove);
            }
            
                    Id serviceOrderHeaderOldId = serviceOrderKitHeaderListToMove[0].Service_Order_Header__c;
                    if(serviceOrderKitHeaderListToMove.size() > 0 ){ 

                            list<Service_Order_Line_Item__c> serviceOrderLineItemListToMove =new  list<Service_Order_Line_Item__c>();
                            Service_Order_Kit_Header__c serviceOrderKitHeaderRecToMove = serviceOrderKitHeaderListToMove[0];
                            serviceOrderKitHeaderRecToMove.Service_Order_Header__c = sectionToMove;                            
                                System.debug(serviceOrderKitHeaderRecToMove.Actual_Kit_Price__c);
                                serviceOrderKitHeaderRecToMove.Fixed_Price__c = serviceOrderKitHeaderRecToMove.Actual_Kit_Price__c;
                            
                            for(Service_Order_Line_Item__c soliItemToMoveRec : serviceOrderKitHeaderRecToMove.Service_Order_Line_Items__r ) {
                                soliItemToMoveRec.Service_Order_Header__c = sectionToMove;
                                if(IsTaxIncludingPricing){
                                    Decimal preTaxPricing = soliItemToMoveRec.Actual_Kit_Price__c/ (1 + (soliItemToMoveRec.Tax_Percent__c == null ? 0 : soliItemToMoveRec.Tax_Percent__c / 100)); 
                                    soliItemToMoveRec.Kit_Price__c = preTaxPricing;
                                    
                                    //Start: Added by Pooja 6 Dec. 2016
                                    String CoheaderId1 = BPUtility.escapeSingleQuotes(CoheaderId);
                                    list<CO_Header__c> coHeaderListWithPriceLevel = new list<CO_Header__c>([select Id, Labour_Rate_From_Price_Level__c from CO_Header__c where  Id =:CoheaderId1]);
                                    
                                    if(soliItemToMoveRec.Labour_Code__c !=null) {
                                        System.debug(serviceOrderKitHeaderRecToMove.Fixed_Price__c);
                                        if(!(soliItemToMoveRec.Fixed_Price__c || soliItemToMoveRec.Labour_Code__r.Fixed_Rate__c || serviceOrderKitHeaderRecToMove.Fixed_Price_Flag__c ) ){
                                            Decimal preTaxPricing1;
                                            if(!(coHeaderListWithPriceLevel[0].Labour_Rate_From_Price_Level__c == null || coHeaderListWithPriceLevel[0].Labour_Rate_From_Price_Level__c == 0)){
                                                serviceOrderKitHeaderRecToMove.Fixed_Price__c = serviceOrderKitHeaderRecToMove.Fixed_Price__c - soliItemToMoveRec.Actual_Kit_Price__c;
                                                preTaxPricing1 = coHeaderListWithPriceLevel[0].Labour_Rate_From_Price_Level__c/ (1 + (soliItemToMoveRec.Tax_Percent__c / 100)); 
                                                soliItemToMoveRec.Kit_Price__c = preTaxPricing1.setScale(2, RoundingMode.HALF_UP);
                                                serviceOrderKitHeaderRecToMove.Fixed_Price__c += coHeaderListWithPriceLevel[0].Labour_Rate_From_Price_Level__c;
                                            }
                                        }
                                    }
                                    //End: Added by Pooja 6 Dec. 2016
                                    
                                }else{
                                    soliItemToMoveRec.Kit_Price__c = soliItemToMoveRec.Actual_Kit_Price__c;
                                    
                                    //Start: Added by Pooja 6 Dec. 2016
                                    String CoheaderId1 = BPUtility.escapeSingleQuotes(CoheaderId);
                                    list<CO_Header__c> coHeaderListWithPriceLevel = new list<CO_Header__c>([select Id, Labour_Rate_From_Price_Level__c from CO_Header__c where  Id =:CoheaderId1]);
                                    
                                    if(soliItemToMoveRec.Labour_Code__c !=null) {
                                        if(!(soliItemToMoveRec.Fixed_Price__c || soliItemToMoveRec.Labour_Code__r.Fixed_Rate__c || serviceOrderKitHeaderRecToMove.Fixed_Price_Flag__c ) ){
                                            Decimal preTaxPricing1;
                                            if(!(coHeaderListWithPriceLevel[0].Labour_Rate_From_Price_Level__c == null || coHeaderListWithPriceLevel[0].Labour_Rate_From_Price_Level__c == 0)){
                                                serviceOrderKitHeaderRecToMove.Fixed_Price__c = serviceOrderKitHeaderRecToMove.Fixed_Price__c - soliItemToMoveRec.Actual_Kit_Price__c;
                                                preTaxPricing1 = coHeaderListWithPriceLevel[0].Labour_Rate_From_Price_Level__c;
                                                soliItemToMoveRec.Kit_Price__c = preTaxPricing1.setScale(2, RoundingMode.HALF_UP);
                                                serviceOrderKitHeaderRecToMove.Fixed_Price__c += soliItemToMoveRec.Kit_Price__c;
                                            }
                                        }
                                    }
                                    //End: Added by Pooja 6 Dec. 2016
                                    
                                    
                                }
                                //soliItemToMoveRec.Kit_Price__c = soliItemToMoveRec.Actual_Kit_Price__c;
                                serviceOrderLineItemListToMove.add(soliItemToMoveRec );                                
                            } 
                            
                            if(IsTaxIncludingPricing){
                                Decimal preTaxPricingHeader = serviceOrderKitHeaderRecToMove.Fixed_Price__c; 
                                if(serviceOrderKitHeaderRecToMove.Tax_amount__c != null){
                                    preTaxPricingHeader = preTaxPricingHeader - serviceOrderKitHeaderRecToMove.Tax_amount__c;
                                }
                                serviceOrderKitHeaderRecToMove.Fixed_Price__c = preTaxPricingHeader;
                            }
                            
                            //System.debug(serviceOrderLineItemListToMove);
                            //System.assert(false, serviceOrderLineItemListToMove);
                            
                            ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
                            update serviceOrderKitHeaderRecToMove;
                            if(serviceOrderLineItemListToMove.Size() > 0){
                                update serviceOrderLineItemListToMove;                              
                            }
                            
                            // Shop Supplies - 
                            //if(isLabor) {
                                ShopSuppliesService.shopSuppliesCalculation(serviceOrderHeaderOldId);
                                ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
                                ShopSuppliesService.shopSuppliesCalculation(sectionToMove);
                            //}
                
                            sectionToMove = BPUtility.escapeSingleQuotes(sectionToMove);
                            list<Service_Order_Header__c> serviceOrderList =[select Id,(Select Id, CO_Invoice_Header__c, isActive__c From CO_Invoice_Items__r),CO_Header__c
                                                                         from  Service_Order_Header__c where Id =:sectionToMove ];
                            Service_Order_Header__c ServiceOrderHeaderRec=  serviceOrderList[0];                                                  
                            if(ServiceOrderHeaderRec.CO_Invoice_Items__r.size()==0){
                                    CoheaderId = BPUtility.escapeSingleQuotes(CoheaderId);
                                    list<CO_Invoice_Header__c>  coInvoiceHeaderRec =new list<CO_Invoice_Header__c>([select Id from  CO_Invoice_Header__c where 
                                                                                                            CO_Header__c =:CoheaderId and status__c =:'Active' ]);
                                    CO_Invoice_Item__c coInvoiceItem = new CO_Invoice_Item__c();
                                    if(coInvoiceHeaderRec.size() > 0 ){  
                                        coInvoiceItem.CO_Invoice_Header__c = coInvoiceHeaderRec[0].Id;
                                        coInvoiceItem.isActive__c = true;
                                        coInvoiceItem.Is_Invoiceable__c = true;
                                        for(Service_Order_Line_Item__c serviceOrderLineItemRec :  ServiceOrderHeaderRec.Service_Order_Line_Items__r){
                                            if(serviceOrderLineItemRec.Qty_To_Order__c > 0){
                                                coInvoiceItem.Is_Invoiceable__c =false;
                                                break;
                                            }
                                        }
                                        coInvoiceItem.Service_Order_Header__c = ServiceOrderHeaderRec.Id;
                                        insert coInvoiceItem;
                                    }
                                
                            }                                                                           
                                serviceOrderHeaderOldId = BPUtility.escapeSingleQuotes(serviceOrderHeaderOldId);
                                list <CO_Invoice_Item__c> invoiceItemToDelete= new  list <CO_Invoice_Item__c>();
                                list<Service_Order_Header__c> ServiceOrderHeaderOldRecList =  new list<Service_Order_Header__c>([Select Id,CO_Header__c,(Select Id, CO_Invoice_Header__c, isActive__c From CO_Invoice_Items__r),
                                                                                             (Select Id,Qty_To_Order__c,Actual_Kit_Price__c From Service_Order_Line_Items__r)  
                                                                                             from Service_Order_Header__c
                                                                                             where  Id =: serviceOrderHeaderOldId]);
                            
                                Service_Order_Header__c ServiceOrderHeaderOldRec = ServiceOrderHeaderOldRecList[0];
                                if(ServiceOrderHeaderOldRec.Service_Order_Line_Items__r.size() == 0 ){
                                    for(CO_Invoice_Item__c coInvoiceItem : ServiceOrderHeaderOldRec.CO_Invoice_Items__r ){
                                        invoiceItemToDelete.add( coInvoiceItem);
                                    }
                                    if(invoiceItemToDelete.size() > 0 ){                                        
                                        delete invoiceItemToDelete;
                                    }
                                }
                            }**/
        } else{
        	List<Vendor_Order_Line_Item__c> voliRecListToUpdate = new List<Vendor_Order_Line_Item__c>();
        	if(String.isNotBlank(serviceOrderKitHeaderListToMove[0].Id)) {
        		voliRecListToUpdate = [Select Id, CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c From Vendor_Order_Line_Item__c 
        																WHERE CO_Line_Item__r.Service_Order_Line_Item__r.Service_Order_Kit_Header__c =: serviceOrderKitHeaderListToMove[0].Id];
        	}
        	COLineItemTriggerHelper.isMoveLineItem = true;
            Id cokhId = MerchandiseService.insertMerchKit(serviceOrderKitHeaderListToMove[0].Kit_Header__c, serviceOrderKitHeaderListToMove[0].Service_Order_Header__r.CO_Header__c);
            removeSOKHItems(serviceOrderKitHeaderListToMove[0].Id);
            COLineItemTriggerHelper.isMoveLineItem = false;
            
            if(voliRecListToUpdate.size() > 0) {
            	updateVOLIANDCOLIOnMoveFromSokhCOKH(new Map<String, Id>{'CO_Kit_Header__c' => cokhId}, serviceOrderKitHeaderListToMove, voliRecListToUpdate);
            }
            
            /**Commented as now trigger will run, and related items will be upserted. #3957                    
                    if(serviceOrderKitHeaderListToMove.size() > 0 ){
                            list<Service_Order_Line_Item__c> serviceOrderLineItemListToMove =new  list<Service_Order_Line_Item__c>();
                            ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
                            
                            list<CO_Kit_Header__c> coKitHeaderToInsert = new list<CO_Kit_Header__c>();
                            Service_Order_Kit_Header__c serviceOrderKitHeaderRecToMove = serviceOrderKitHeaderListToMove[0];
                            for(Service_Order_Kit_Header__c serviceOrderKitHeaderRec  : serviceOrderKitHeaderListToMove){
                                CO_Kit_Header__c coKitHeaderRec = new CO_Kit_Header__c();
                                coKitHeaderRec.Actual_Kit_Price__c =  serviceOrderKitHeaderRec.Actual_Kit_Price__c;
                                coKitHeaderRec.Can_Split__c= serviceOrderKitHeaderRec.Can_Split__c ;
                                coKitHeaderRec.Price__c = serviceOrderKitHeaderRec.Fixed_Price__c ;
                                coKitHeaderRec.Tax_amount__c = serviceOrderKitHeaderRec.Tax_amount__c ; 
                                coKitHeaderRec.Fixed_Price_Flag__c = serviceOrderKitHeaderRec.Fixed_Price_Flag__c ;
                                coKitHeaderRec.CO_Fixed_KitHeader__c = false ;
                                coKitHeaderRec.Kit_Header__c = serviceOrderKitHeaderRec.Kit_Header__c;
                                coKitHeaderRec.Service_Kit__c = serviceOrderKitHeaderRec.Service_Kit__c ; 
                                coKitHeaderRec.CO_Header__c = CoheaderId;
                                coKitHeaderToInsert.add(coKitHeaderRec);
                            } 
                            
                            
                            map<Id,Service_Order_Line_Item__c> coliIdToSoliMap =  new map<Id,Service_Order_Line_Item__c>();
                            for(Service_Order_Line_Item__c soliItemToMoveRec : serviceOrderKitHeaderRecToMove.Service_Order_Line_Items__r ) {
                                serviceOrderLineItemListToMove.add(soliItemToMoveRec );
                                coliIdToSoliMap.put(soliItemToMoveRec.CO_Line_Item__c ,soliItemToMoveRec);
                            }
                            
                            List<CO_Line_Item__c> coliList = [Select Id from CO_Line_Item__c where Service_Order_Line_Item__c = null and
                                                                                 CO_Header__c =: CoheaderId];
                            List<SObject> sObjectListToInsert;
                            if(coliList.size() == 0) {
                                sObjectListToInsert = addLinkedFee(coHeaderId, null, 'Merchandise');
                                if(sObjectListToInsert != null && sObjectListToInsert.size() > 0) {
                                    insert sObjectListToInsert;
                                }
                            }
                
                            list<CO_Line_Item__c> coliItemListForNewCOKitHeader  = new list<CO_Line_Item__c>([select Id,CO_Kit_Header__c,Qty_To_Order__c from CO_Line_Item__c where Id IN : coliIdToSoliMap.keySet()]);
                            ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
                            if(coKitHeaderToInsert.size() > 0 && coliItemListForNewCOKitHeader.size() > 0){
                                insert coKitHeaderToInsert;
                                CO_Kit_Header__c CokitHeaderRecInserted = coKitHeaderToInsert[0];
                                for(CO_Line_Item__c  coliRec: coliItemListForNewCOKitHeader ){
                                    coliRec.CO_Kit_Header__c = CokitHeaderRecInserted.Id;
                                    if(coliIdToSoliMap.ContainsKey(coliRec.Id)){
                                        Service_Order_Line_Item__c  ServiceOrderRec = coliIdToSoliMap.get(coliRec.Id);
                                        if(IsTaxIncludingPricing){
                                            Decimal preTaxPricing = ServiceOrderRec.Actual_Kit_Price__c/ (1 + (ServiceOrderRec.Tax_Percent__c == null ? 0 : ServiceOrderRec.Tax_Percent__c / 100)); 
                                            coliRec.Price__c = preTaxPricing;
                                        }else{
                                            coliRec.Price__c = ServiceOrderRec.Actual_Kit_Price__c;
                                        }
                                        coliRec.Fixed_Price__c = ServiceOrderRec.Fixed_Price__c;
                                        coliRec.Actual_Kit_Price__c = ServiceOrderRec.Actual_Kit_Price__c;
                                        coliRec.Is_In_Service_Order__c = false;
                                    }
                                    
                                }
                                update coliItemListForNewCOKitHeader;
                            }
                            
                            Id serviceOrderHeaderId = serviceOrderKitHeaderListToMove[0].Service_Order_Header__c;
                                                        
                            if(serviceOrderLineItemListToMove.Size() > 0){
                                delete serviceOrderLineItemListToMove;  
                                list <CO_Invoice_Item__c> invoiceItemToDelete= new  list <CO_Invoice_Item__c>();
                                serviceOrderHeaderId = BPUtility.escapeSingleQuotes(serviceOrderHeaderId);
                                list<Service_Order_Header__c> ServiceOrderHeaderRecList =  new list<Service_Order_Header__c>([Select Id,CO_Header__c,(Select Id, CO_Invoice_Header__c, isActive__c From CO_Invoice_Items__r),
                                                                                             (Select Id,Qty_To_Order__c From Service_Order_Line_Items__r)  
                                                                                             from Service_Order_Header__c
                                                                                             where  Id =: serviceOrderHeaderId]);
                            
                                Service_Order_Header__c ServiceOrderHeaderRec =ServiceOrderHeaderRecList[0];
                                if(ServiceOrderHeaderRec.Service_Order_Line_Items__r.size() == 0 ){
                                    for(CO_Invoice_Item__c coInvoiceItem : ServiceOrderHeaderRec.CO_Invoice_Items__r ){
                                        invoiceItemToDelete.add( coInvoiceItem);
                                    }
                                    if(invoiceItemToDelete.size() > 0 ){
                                        delete invoiceItemToDelete;
                                    }
                                }
                                                            
                            }
                             
                            delete serviceOrderKitHeaderListToMove;
                            //UpdateServiceOrderTotals( Id.valueOf(serviceOrderHeaderId) , null);
                    } **/  
        }   
        return null;                                                                                                        
                     
     }
    
    // function to move kit item
    public static String MoveFromCokhSokh(String kitIdToMove,String sectionToMove){
            Savepoint sp = Database.setSavepoint();
            if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

            if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            

            if(AccessControl.ifObjectIsDeletable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            
            kitIdToMove = BPUtility.escapeSingleQuotes(kitIdToMove);
            list<CO_Kit_Header__c> coKitHeaderToMovelist =new  list<CO_Kit_Header__c>([select Id,Tax_amount__c,Actual_Kit_Price__c,Can_Split__c,CO_Fixed_KitHeader__c,Kit_Header__r.Code__c,
                                                                                      Kit_Header__r.Description__c,CO_Header__c,CO_Header__r.Customer__c,Fixed_Price_Flag__c,Kit_Header__c,Price__c,Service_Kit__c,
                                                                                      (select Id,Actual_Kit_Price__c,Fixed_Price__c,CO_Fixed_KitLineItem__c,Price__c,Item_Code__c, Fee__c, Price_When_Tax_Included__c,
                                                                                      Item_Description__c,Qty_Committed__c,Qty__c,Qty_To_Order__c,Part__c, Tax__c, Is_Environmental_Fee__c, Is_Linked_Fee__c,
                                                                                      Kit_Header_Line_Item__c, Status__c, Vendor_Order_Header__c, VO_Number__c, VO_Status__c, Expected_Delivery_Date__c   
                                                                                      from CO_Line_Items__r ) ,
                                                                                      (Select Id, CO_Invoice_Header__c, isActive__c From CO_Invoice_Items__r)                       
                                                                                      from CO_Kit_Header__c where Id =: kitIdToMove]);
            
            List<Vendor_Order_Line_Item__c> voliRecListToUpdate = new List<Vendor_Order_Line_Item__c>();
        	if(String.isNotBlank(coKitHeaderToMovelist[0].Id)) {
        		voliRecListToUpdate = [Select Id, Vendor_Order_Line_Item_Group__c, Is_Received__c, CO_Line_Item__r.Kit_Header_Line_Item__c From Vendor_Order_Line_Item__c WHERE CO_Line_Item__r.CO_Kit_Header__c =: coKitHeaderToMovelist[0].Id];
        	}
            COLineItemTriggerHelper.isMoveLineItem = true;
            
            MerchandiseService.removeCOKHItems(coKitHeaderToMovelist[0].Id);
            Id soKHId = insertKitHeaderInGrid(coKitHeaderToMovelist[0].Kit_Header__c, sectionToMove);
            COLineItemTriggerHelper.isMoveLineItem = false;
            
            if(voliRecListToUpdate.size() > 0) {
            	updateVOLIANDCOLIOnMoveFromCokhSokh(soKHId, coKitHeaderToMovelist, voliRecListToUpdate);
            }
            
            //SO_KLI_Recalculation.SOPriceCalcultaionByPriceLevelForSOKitHeaders(coKitHeaderToMovelist[0].CO_Header__r.Customer__c, coKitHeaderToMovelist[0].CO_Header__c, new List<Id>{soKHId}, sectionToMove);
            SO_KLI_Recalculation.soKitPriceCalculation(new Set<Id>{soKHId}, new Set<Id>{sectionToMove}, null);
            if(hasLabor) {
                ShopSuppliesService.shopSuppliesCalculation(sectionToMove);
            }
             
        return null;
    }   
    
     //Fucntion to soli to coli
     public static String  MoveFromSoliToColi(String soliToMove,String sectionToMove) {
        Savepoint sp = Database.setSavepoint();
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        

        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        

        if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        soliToMove = BPUtility.escapeSingleQuotes(soliToMove);
        
        List<Service_Order_Line_Item__c> soliItemToMovelist = [SELECT Actual_Kit_Price__c, Service_Order_Header__c, CO_Line_Item__c, 
        		Status__c, Vendor_Order_Header__c, VO_Number__c, 
        		VO_Status__c, Expected_Delivery_Date__c, 
        		CO_Line_Item__r.Status__c, CO_Line_Item__r.Vendor_Order_Header__c, CO_Line_Item__r.VO_Number__c, 
        		CO_Line_Item__r.VO_Status__c, CO_Line_Item__r.Expected_Delivery_Date__c, 
                Service_Order_Header__r.CO_Header__c, Item_Code__c, Item_Description__c, Qty_Needed__c, Part__c, Labour_Code__c,
                Part__r.Retail_price__c, Part__r.Non_Inventory_Part__c, Part__r.Applicable_Tax__r.Rate__c, Sublet__c, Fee__c,
                (SELECT Id from Vendor_Order_Line_Items__r WHERE Sublet__c != null AND Is_Received__c = true) 
                 FROM Service_Order_Line_Item__c WHERE Id =: soliToMove];
                 
        if(sectionToMove != null) {
            Id sectionFromHeaderId = null;
            
            if(soliItemToMovelist.size() >  0) {
                sectionFromHeaderId = soliItemToMovelist[0].Service_Order_Header__c;
            }
            Boolean isLabor = false;
            for(Service_Order_Line_Item__c soliItemToMoveRec : soliItemToMovelist) {
                soliItemToMoveRec.Service_Order_Header__c = sectionToMove;
                if(soliItemToMoveRec.Labour_Code__c != null) {
                    isLabor = true;
                }
            }   
            //ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
            if(soliItemToMovelist.size() > 0) {
            	String coHeaderId = soliItemToMovelist[0].Service_Order_Header__r.CO_Header__c;    
            	String voliId;
                if(soliItemToMovelist[0].Vendor_Order_Line_Items__r.size() > 0) {
                    voliId = soliItemToMovelist[0].Vendor_Order_Line_Items__r[0].Id;
                }
                
                List<Vendor_Order_Line_Item__c> voliRecListToUpdate = new List<Vendor_Order_Line_Item__c>();
            	String query = 'Select Id, Vendor_Order_Line_Item_Group__c, Is_Received__c, CO_Line_Item__c From Vendor_Order_Line_Item__c';
            	
            	if(String.isNotBlank(soliItemToMovelist[0].Part__c) && String.isNotBlank(soliItemToMovelist[0].CO_Line_Item__c)) {
            		query += ' WHERE CO_Line_Item__c = \'' + soliItemToMovelist[0].CO_Line_Item__c + '\'';
            		voliRecListToUpdate = DataBase.query(query);
            	} else if(String.isNotBlank(soliItemToMovelist[0].Sublet__c) && String.isNotBlank(soliItemToMovelist[0].Id)) {
            		query += ' WHERE Service_Order_Line_Item__c = \'' + soliItemToMovelist[0].Id + '\'';
            		voliRecListToUpdate = DataBase.query(query);
            	}
                
                COLineItemTriggerHelper.isMoveLineItem = String.isNotBlank(soliItemToMovelist[0].Part__c);
                ServiceOrderLineItemTriggerHelper.isMoveLineItem = String.isNotBlank(soliItemToMovelist[0].Sublet__c);
                delete soliItemToMovelist;
                
                List<Service_Order_Line_Item__c> soliListToInsert = new List<Service_Order_Line_Item__c>();
                String soliId = null;
                
                if(String.isNotBlank(soliItemToMovelist[0].Part__c)) {
                    soliListToInsert = insertPartInGrid(soliItemToMovelist[0].Part__c, soliItemToMovelist[0].Service_Order_Header__c, soliItemToMovelist[0].Qty_Needed__c);
                } else if(String.isNotBlank(soliItemToMovelist[0].Fee__c)) {
                    insertFeeInGrid(soliItemToMovelist[0].Fee__c, soliItemToMovelist[0].Service_Order_Header__c, false, new Part__c(), soliItemToMovelist[0].Qty_Needed__c);
                } else if(String.isNotBlank(soliItemToMovelist[0].Labour_Code__c)) {
                    insertLabourInGrid(soliItemToMovelist[0].Labour_Code__c, soliItemToMovelist[0].Service_Order_Header__c, soliItemToMovelist[0].Qty_Needed__c);
                } else if(String.isNotBlank(soliItemToMovelist[0].Sublet__c)) {
                    soliId = insertProductInGrid(soliItemToMovelist[0].Sublet__c, soliItemToMovelist[0].Service_Order_Header__c, soliItemToMovelist[0].Qty_Needed__c);
                	if(voliId != null) {
                        updateRelatedVOLineItem(soliId, voliId, coHeaderId);
                    }
                }
                
                COLineItemTriggerHelper.isMoveLineItem = false;
                ServiceOrderLineItemTriggerHelper.isMoveLineItem = false;
                
                if(voliRecListToUpdate.size() > 0) {
                	if(String.isNotBlank(soliItemToMovelist[0].Part__c)) {
		            	List<CO_Line_Item__c>  newlyInsertedCOLIList = [Select Id, Service_Order_Line_Item__c From CO_Line_Item__c 
		            													WHERE Service_Order_Line_Item__c IN: soliListToInsert AND Part__c != null];
		            	
		            	updateVOLIANDCOLIOnPartMoveFromSoliTOColi(voliRecListToUpdate, newlyInsertedCOLIList, soliItemToMovelist);
	            	} else if(String.isNotBlank(soliItemToMovelist[0].Sublet__c)) {
	            		updateVOLIANDCOLIOnSubletMoveFromSoliTOColi(voliRecListToUpdate, soliId, soliItemToMovelist);
	            	}
	            }
            }                        
        }else{
            // Changes Made by TK - Refactor code. - 07/13/2017
            if(soliItemToMovelist.size() == 0 ){
                return null;
            }   
                                                                                                
            String coHeaderId =  soliItemToMovelist[0].Service_Order_Header__r.CO_Header__c;                                                                                       
            String soHeaderId;
            String relatedCOLLineItemId;
            
            List<CO_Line_Item__c> coliToUpsert = new List<CO_Line_Item__c>();
            if(soliItemToMovelist.size() > 0 ){
                soHeaderId = soliItemToMovelist[0].Service_Order_Header__c;
                relatedCOLLineItemId = soliItemToMovelist[0].CO_Line_Item__c;
                
                COService.createMerchSectionIfNotExist(coHeaderId); 
                
                List<Vendor_Order_Line_Item__c> voliRecListToUpdate = new List<Vendor_Order_Line_Item__c>();
                if(String.isNotBlank(soliItemToMovelist[0].Part__c) && String.isNotBlank(soliItemToMovelist[0].CO_Line_Item__c)) {
                	voliRecListToUpdate = [Select Id, Vendor_Order_Line_Item_Group__c, Is_Received__c From Vendor_Order_Line_Item__c WHERE CO_Line_Item__c =: soliItemToMovelist[0].CO_Line_Item__c];
                }
                
                if(String.isNotBlank(soliItemToMovelist[0].Part__c)) {
                    Boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
                    CO_Line_Item__c coLineItemRec = new CO_Line_Item__c(CO_Header__c = coHeaderId);
                    coLineItemRec.Qty__c = soliItemToMovelist[0].Qty_Needed__c ;
                    coLineItemRec.Price__c = (soliItemToMovelist[0].Part__r.Retail_price__c == null) ? 0 : soliItemToMovelist[0].Part__r.Retail_price__c;
                    if(isTaxIncludingPricing) {
                        soliItemToMovelist[0].Part__r.Applicable_Tax__r.Rate__c = (soliItemToMovelist[0].Part__r.Applicable_Tax__r.Rate__c != null) ? soliItemToMovelist[0].Part__r.Applicable_Tax__r.Rate__c : 0;
                        coLineItemRec.Price_When_Tax_Included__c = coLineItemRec.Price__c;
                        coLineItemRec.Price__c = (coLineItemRec.Price__c / (1 + (soliItemToMovelist[0].Part__r.Applicable_Tax__r.Rate__c / 100))).setScale(2, RoundingMode.HALF_UP);
                    }
                    coLineItemRec.Part__c = soliItemToMovelist[0].Part__c;
                    if(soliItemToMovelist[0].Part__r.Non_Inventory_Part__c != null && soliItemToMovelist[0].Part__r.Non_Inventory_Part__c) {
                        coLineItemRec.Status__c = 'In Stock';
                        coLineItemRec.Qty_Committed__c = soliItemToMovelist[0].Qty_Needed__c;
                    }
                    coliToUpsert.add(coLineItemRec);
                }
                
                delete soliItemToMovelist;
                
                if(String.isNotBlank(soliItemToMovelist[0].Part__c)) {
                	COLineItemTriggerHelper.isMoveLineItem = true;
                    upsert coliToUpsert;
                } else if(String.isNotBlank(soliItemToMovelist[0].Fee__c)) {
                 	CustomerOrderCtrl_V2.insertFeeInMerchGrid(soliItemToMovelist[0].Fee__c, coHeaderId, false, soliItemToMovelist[0].Qty_Needed__c);
                }
                
                COLineItemTriggerHelper.isMoveLineItem = false;
                
                if(voliRecListToUpdate.size() > 0 && String.isNotBlank(soliItemToMovelist[0].Part__c)) {
	            	updateVOLIANDCOLIOnPartMoveFromSoliTOColi(voliRecListToUpdate, coliToUpsert, soliItemToMovelist);
	            } 
            }           
        }
        return null; 
     }
     
     private static void updateRelatedVOLineItem(String soliId, String voliId, String coHeaderId) {
        List<Service_Order_Line_Item__c> newInsertedSOLIList = 
                [SELECT Id, (SELECT Id from Vendor_Order_Line_Items__r WHERE Sublet__c != null) from Service_Order_Line_Item__c
                    WHERE Id =: soliId];
        if(newInsertedSOLIList.size() > 0 && newInsertedSOLIList[0].Vendor_Order_Line_Items__r.size() > 0) {
            ServiceOrderLineItemTriggerHelper.shouldTriggerRunStop = true;
            VendorOrderLineItemTriggerHelper.shouldTriggerRunStop = true;
            
            delete newInsertedSOLIList[0].Vendor_Order_Line_Items__r;
            
            Vendor_Order_Line_Item__c voliRec = new Vendor_Order_Line_Item__c(Id = voliId);
            voliRec.Service_Order_Line_Item__c = newInsertedSOLIList[0].Id;
            voliRec.Is_Service__c = true;
	        voliRec.Is_Required_For_Customer__c = true;
	        voliRec.CO_Header__c = coHeaderId;
	        voliRec.Is_Excess__c = false;
            update voliRec;
            
            newInsertedSOLIList[0].Status__c = 'Ready';
            update newInsertedSOLIList[0];
            
            ServiceOrderLineItemTriggerHelper.shouldTriggerRunStop = false;
            VendorOrderLineItemTriggerHelper.shouldTriggerRunStop = false;
        }
     }
     
     //function to create SoliForColi
     public static list<Service_Order_Line_Item__c> CreateSoliForColi(map<Id,Id> coliToSoliMap,list<CO_Line_Item__c> coliListToMove,String soKitheader,String ServiceOrderId ){
            if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
             
            boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            list<Service_Order_Line_Item__c> soliListToInsert = new list<Service_Order_Line_Item__c>();
            for(CO_Line_Item__c coliRecToMove : coliListToMove ){
                Service_Order_Line_Item__c solirec = new Service_Order_Line_Item__c();
                solirec.CO_Line_Item__c= coliRecToMove.Id;
                solirec.Actual_Kit_Price__c =coliRecToMove.Actual_Kit_Price__c;     
                solirec.Fee__c = coliRecToMove.Fee__c;
                solirec.Fixed_Price__c = coliRecToMove.Fixed_Price__c;
                solirec.Is_Fixed_Kit_LineItem_SO__c = coliRecToMove.CO_Fixed_KitLineItem__c;
                solirec.Is_Environmental_Fee__c = coliRecToMove.Is_Environmental_Fee__c;
                solirec.Is_Linked_Fee__c = coliRecToMove.Is_Linked_Fee__c;
                Decimal actualKitPrice = coliRecToMove.Price__c;
                if(IsTaxIncludingPricing){
                    Decimal preTaxPricing = actualKitPrice / (1 + ((coliRecToMove.Tax__c == null ? 0 : coliRecToMove.Tax__c)/ 100)); 
                    solirec.Kit_Price__c = coliRecToMove.Price__c;
                    solirec.Price_When_Tax_Included__c = coliRecToMove.Price_When_Tax_Included__c;
                }else{
                    solirec.Kit_Price__c = actualKitPrice;
                }
                solirec.Part__c = coliRecToMove.Part__c;
                solirec.Qty_Committed__c = coliRecToMove.Qty_Committed__c;
                solirec.Qty_Needed__c =  coliRecToMove.Qty__c;
                solirec.Tax_Percent__c =  coliRecToMove.Tax__c;
                solirec.Service_Order_Header__c = Id.valueOf(ServiceOrderId);
                solirec.Service_Order_Kit_Header__c = soKitheader;
                solirec.Item_Code__c  = coliRecToMove.Item_Code__c;
                solirec.Item_Description__c = coliRecToMove.Item_Description__c;
                soliListToInsert.add(solirec);
            }
            
            if(soliListToInsert.size()>0){
                ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
                insert soliListToInsert;
            }
            List<Service_Order_Line_Item__c> soliListToUpdate = new list<Service_Order_Line_Item__c>();                
                
            for(Service_Order_Line_Item__c soliRec : soliListToInsert ){
                Service_Order_Line_Item__c SoliRecToupdate = new Service_Order_Line_Item__c();
                SoliRecToupdate.Id  = soliRec.Id;
                SoliRecToupdate.Item_Code__c  = soliRec.Item_Code__c;
                SoliRecToupdate.Item_Description__c = soliRec.Item_Description__c;
                soliListToUpdate.add(SoliRecToupdate);
            }
            if(soliListToUpdate.size() > 0) {
                update soliListToUpdate;
            }
            for(Service_Order_Line_Item__c solirec: soliListToInsert ){
                coliToSoliMap.put(solirec.CO_Line_Item__c,solirec.Id );
            }   
            
            for(CO_Line_Item__c coliRecToMove : coliListToMove ){
                coliRecToMove.Service_Order_Line_Item__c = coliToSoliMap.get(coliRecToMove.Id);
                coliRecToMove.Is_In_Service_Order__c = true;
            }                               
            
            
            List<Individual_Tax__c> individualTaxListToUpdate = [select Service_Order_Line_Item__c, CO_Line_Item__c from Individual_Tax__c where CO_Line_Item__c IN :coliListToMove];
            if(individualTaxListToUpdate.size() > 0) {
                for(Individual_Tax__c tax : individualTaxListToUpdate) {
                    if(tax.Service_Order_Line_Item__c == null && coliToSoliMap.containsKey(tax.CO_Line_Item__c)){
                        tax.Service_Order_Line_Item__c = coliToSoliMap.get(tax.CO_Line_Item__c);
                    }
                }
                update individualTaxListToUpdate;
            }
            if(coliListToMove.Size()>0 ){
                update coliListToMove;
            }
            
            return soliListToInsert;
     }
     
     
     //Function to move coli to soli  
     public static String  MoveFromColiToSoli(String coliToMove,String ServiceOrderId) {
            Savepoint sp = Database.setSavepoint();
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            coliToMove = BPUtility.escapeSingleQuotes(coliToMove);
            ServiceOrderId = BPUtility.escapeSingleQuotes(ServiceOrderId);
            List<CO_Line_Item__c>  coliListToMove = new List<CO_Line_Item__c>([select Id,Actual_Kit_Price__c,Fixed_Price__c,CO_Fixed_KitLineItem__c,Price__c, Fee__c, Price_When_Tax_Included__c,
                                                                                Part__r.Retail_Price__c,Qty_Committed__c,Qty__c,Qty_To_Order__c,Part__c, Tax__c,Item_Code__c,Item_Description__c, Is_Environmental_Fee__c, Is_Linked_Fee__c,
                                                                                Status__c, Vendor_Order_Header__c, VO_Number__c, VO_Status__c, Expected_Delivery_Date__c,
                                                                                (Select Id, Vendor_Order_Line_Item_Group__c, Is_Received__c From Vendor_Order_Line_Items__r), 
                                                                                (Select Id, CO_Invoice_Header__c, isActive__c From CO_Invoice_Items__r) 
                                                                                from CO_Line_Item__c where Id =:coliToMove]);
                                                                    
            list<Service_Order_Header__c> ServiceOrderHeaderRecList =  new list<Service_Order_Header__c>([Select Id,CO_Header__c,(Select Id, CO_Invoice_Header__c, isActive__c From CO_Invoice_Items__r),
                                                                                         (Select Qty_To_Order__c From Service_Order_Line_Items__r)  
                                                                                         from Service_Order_Header__c
                                                                                         where  Id =: ServiceOrderId]);
            Service_Order_Header__c ServiceOrderHeaderRec;
            if(ServiceOrderHeaderRecList.size() > 0){
                 ServiceOrderHeaderRec= ServiceOrderHeaderRecList[0];
            }else{
                return 'errorId';
            }
            
            Service_Order_Line_Item__c solirec = new Service_Order_Line_Item__c();
            solirec.Part__c = coliListToMove[0].Part__c;
            solirec.Fee__c = coliListToMove[0].Fee__c;
            solirec.Kit_Price__c = coliListToMove[0].Part__r.Retail_Price__c;
            solirec.Qty_Needed__c =  coliListToMove[0].Qty__c;
            solirec.Service_Order_Header__c = Id.valueOf(ServiceOrderId);
            
            COLineItemTriggerHelper.isMoveLineItem = true;
            delete coliListToMove;
            insert solirec;
			COLineItemTriggerHelper.isMoveLineItem = false;

            if(coliListToMove[0].Vendor_Order_Line_Items__r != null && coliListToMove[0].Vendor_Order_Line_Items__r.size() > 0) {
            	updateVOLIANDCOLIOnMoveFromColiToSoli(solirec, coliListToMove);
            } 
            
        return 'Sucess';
     }  
     
     // Function to Move COLI   
    @RemoteAction
    global static String moveLineItem(String sectionFrom, String sectionTo, String idToMove, String coHeaderId) {
        COService.moveLineItem(sectionFrom, sectionTo, idToMove, coHeaderId);
        return getCOHeaderDetailsByGridName(coHeaderId, BPUtility.getEncodedString(null));
    }
    
    
     /**
    * Name: deleteServiceOrder
    * Desc: Method to delete Service Order From database
    * @param:   (1) coLineItemId - String - CO Line Item Id hich is to be deleted.
    *           (2) coHeaderId - String - CO Header record Id
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction
    global static String deleteServiceOrder(String coHeaderId, String soHeaderId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        try{
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(AccessControl.ifObjectIsDeletable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            

            List<Service_Order_Header__c> soHeaderRecList = new List<Service_Order_Header__c>();
            soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => soHeaderId});
            
            if(soHeaderRecList != null && soHeaderRecList.size() > 0 && soHeaderRecList[0].Status__c!= 'Complete' && 
                soHeaderRecList[0].Status__c!= 'Reviewed' && soHeaderRecList[0].Hours_Logged__r.size() == 0 &&
                 soHeaderRecList[0].Service_Order_Line_Items__r.size() == 0) {
                List<CO_Header__c> coHeader = SOQLUtil.getCOHeaderDetails(coHeaderId);
                if(coHeader[0].Status__c == 'Open' || coHeader[0].Status__c == 'Quote') {
                    soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
                    if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<CO_Invoice_Item__c> coInvoiceItems = [Select Id From CO_Invoice_Item__c where Service_Order_Header__c =:soHeaderId];
                                                                        
                    if(coInvoiceItems.size() > 0 ){
                            delete coInvoiceItems;
                    }
                    delete soHeaderRecList;
                } else {
                    //throw new BlackPurlException('Please check Status of Service job'); // Commented by richa #2289
                    return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'Please check Status of Service job'))); // Added by richa #2289
                }
            }
            else
            {
                //throw new BlackPurlException('First remove line item to remove service job'); // Commented by richa #2289
                return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'First remove line item to remove service job'))); // Added by richa #2289
            }
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder'));
    }    
    
  /*  @remoteAction
    global static String getOverridenStatusResults(String workStatus) {
        String overridenStatus = '';
        if(overridenStatusToNextStatusMap.containsKey(workStatus)){
            overridenStatus = overridenStatusToNextStatusMap.get(workStatus);
        }
        return overridenStatus;
    }*/
     
    
    /**
     * Name: insertLogRecord
     * Desc: Method which gives Inserts the record 
     * @param:  (1) jSONString - String - JSON String of Value to be Inserted
     * @return: String - Id Of the Record  Inserted
    **/
   @RemoteAction
    global static String insertLogRecord(String jSONString, String statusType){
        jSONString = BPUtility.getDecodedString(jSONString);
        statusType = BPUtility.getDecodedString(statusType);
        if(AccessControl.ifObjectFieldIsCreateable('App_Log__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        //system.assert(false,jSONString);
        SOWizard.AppLog appLogObj = (SOWizard.AppLog)System.JSON.deserialize(jSONString, SOWizard.AppLog.class);
        
        boolean errorMsg = false;
        if((appLogObj.NewStatus).equalsIgnoreCase('Set As Complete') || (appLogObj.NewStatus).equalsIgnoreCase('Complete') || (appLogObj.NewStatus).equalsIgnoreCase('Signed Out')){
            List<Service_Order_Header__c> SOHeaderList =  [SELECT Id, (SELECT Id, Qty_Needed__c, Part__c, Part__r.Non_Inventory_Part__c, Qty_Committed__c From Service_Order_Line_Items__r) From Service_Order_Header__c where Id = :appLogObj.SOHeaderId];
            for(Service_Order_Line_Item__c SOLineItemRec : SOHeaderList[0].Service_Order_Line_Items__r){
                if(SOLineItemRec.Part__c != null && !SOLineItemRec.Part__r.Non_Inventory_Part__c && SOLineItemRec.Qty_Needed__c > SOLineItemRec.Qty_Committed__c){
                    errorMsg = true;
                    break;
                }
            }

            if(errorMsg && (appLogObj.NewStatus).equalsIgnoreCase('Complete')){




                return Label.SetAsCompleteErrorMessage;
            } else if(errorMsg && (appLogObj.NewStatus).equalsIgnoreCase('Signed Out')){
                return Label.SignedOutErrorMessage;
            }


        }
        
        //system.assert(false,appLogObj);
        App_Log__c appLogRec = new App_Log__c();
        appLogRec.Field__c = appLogObj.Field;
        appLogRec.Old_Value__c = appLogObj.OldStatus;
        appLogRec.New_Value__c = appLogObj.NewStatus;
        appLogRec.Notes__c = appLogObj.Notes;
        appLogRec.Service_Order_Header__c = appLogObj.SOHeaderId;
        
        insert appLogRec;
        
        changeStatus(BPUtility.getEncodedString(appLogObj.SOHeaderId),  BPUtility.getEncodedString(appLogRec.New_Value__c), BPUtility.getEncodedString(statusType));
        return BPUtility.getEncodedString('');   


    }
    
    
    /**
     * Name: getStatusResults
     * Desc: Method which gives records according to the Status Specified Of Work And Claim
     * @param:  (1) JSONString - String - JSON String of searched Value
     * @return: String - JSON String of Work And CLaim
    **/
    @remoteAction
    global static String getStatusResults(String workStatus, String claimStatus) {
        workStatus = BPUtility.getDecodedString(workStatus);
        claimStatus = BPUtility.getDecodedString(claimStatus);
        List<String> availableWorkStatusList = new List<String>();
        List<String> availableClaimStatusList = new List<String>();
        if(Constants.workStatusToAvailableStatusMap.containsKey(workStatus)){
            availableWorkStatusList = Constants.workStatusToAvailableStatusMap.get(workStatus);
        }
        if(Constants.claimStatusToAvailableStatusMap.containsKey(claimStatus)){
            availableClaimStatusList = Constants.claimStatusToAvailableStatusMap.get(claimStatus);
        }
        //system.assert(false, new SOInfoWrapper(workStatus, claimStatus, availableWorkStatusList, availableClaimStatusList));
        return BPUtility.getEncodedString(JSON.serialize(new SOWizard.SOInfoWrapper(workStatus, claimStatus, availableWorkStatusList, availableClaimStatusList)));
    }
    
    /**
     * Name: getAppLogRecById
     * Desc: Method which gives records according to the Id
     * @param:  (1) appLogId - String - Id Of App Log
     * @return: String - JSON String of the Object of the Id Specified.
    **/
    @RemoteAction
    global static String getAppLogRecById(String appLogId){
        appLogId = BPUtility.getDecodedString(appLogId);
        List<App_Log__c> appLogRecList = SOQLUtil.getAppLogRecById(appLogId); 
        List<SOWizard.AppLog> applogObjList = new List<SOWizard.AppLog>();
        for(App_Log__c appLogRec : appLogRecList) {
            applogObjList.add(new SOWizard.AppLog(appLogRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(applogObjList));
    }
    
    @RemoteAction
    global static String getWizardInfo(String soHeaderId, String wizardName) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        wizardName = BPUtility.getDecodedString(wizardName);
        if(wizardName == 'Claim_Response'|| wizardName == 'View_Claim_Response' ){
                return getClaimRecById(BPUtility.getEncodedString(soHeaderId));
        
        }else{
            List<Service_Order_Header__c> soHeaderList = SOQLUtil.getSOHeaderById(soHeaderId, wizardName);
            if(soHeaderList.size() == 0) {
                return BPUtility.getEncodedString('{}');


            }
            Service_Order_Header__c soHeaderRec = soHeaderList[0];
            return BPUtility.getEncodedString(System.JSON.serialize(new SOWizard(soHeaderRec, wizardName)));
        }   
    }
    
    /**
     * Name: saveWizardDetails
     * Desc: Save Wizard info to Db
     * @param:  (1) Wizard name to save,Json Pameter
     * @return: Retun Service records
    **/
    @remoteAction
    global static String saveWizardDetails(String soHeaderId, String wizardKey, String wizardJsonToSave, String deleteRecordsJson) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        wizardKey = BPUtility.getDecodedString(wizardKey);
        wizardJsonToSave = BPUtility.getDecodedString(wizardJsonToSave);
        deleteRecordsJson = BPUtility.getDecodedString(deleteRecordsJson);
        SOWizard.SOSignInWizard SOSignInWizardSOInfoObj = (SOWizard.SOSignInWizard) System.JSON.deserialize(wizardJsonToSave, SOWizard.SOSignInWizard.class);
        List<CustomerApproval> approvalList = SOSignInWizardSOInfoObj.Approval_Method;
        
        if(wizardKey == 'Sign_In'){
            // Save Approval Type List
            saveCustomerApprovalInfo(soHeaderId, wizardKey, approvalList, 'Ready');
        } else if(wizardKey == 'Service_Sign_Out') {
            
            saveCustomerApprovalInfo(soHeaderId, wizardKey, approvalList, 'Signed Out');
        
        } else if(wizardKey == 'Claim_Submission') {
            saveCustomerApprovalInfo(soHeaderId, wizardKey, approvalList, 'Ready to Submit');
        }
        return getWizardInfo(BPUtility.getEncodedString(soHeaderId), BPUtility.getEncodedString(wizardKey));
    }
    
     


    private static void saveCustomerApprovalInfo(String soHeaderId, String wizardKey, List<CustomerApproval> approvalList, String newWorkStatus) {
        if(AccessControl.ifObjectFieldIsAccessible('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectIsDeletable('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
        List<CustomerApproval__c> existingApprovalList = [select Id, Section_key__c, ApprovalType__c 
                                                                                            from CustomerApproval__c where Service_Order_Header__c =: soHeaderId
                                                                                            and Section_key__c =: wizardKey]; 
        
        Map<String, CustomerApproval__c> approvalTypeToApprovalRecordMap = new Map<String, CustomerApproval__c>();
        for(CustomerApproval__c custApprovalRec : existingApprovalList) {
            approvalTypeToApprovalRecordMap.put(custApprovalRec.ApprovalType__c, custApprovalRec);
        }                                                   
        
        List<CustomerApproval__c> approvalListToUpsert = new List<CustomerApproval__c>();
        Boolean isStatusToBeChanged = false;
        for(CustomerApproval custApprovalObj : approvalList) {
            CustomerApproval__c custApprovalRec = new CustomerApproval__c();
            custApprovalRec.Service_Order_Header__c = soHeaderId;
            custApprovalRec.Section_key__c = wizardKey;
            custApprovalRec.Section_Name__c = (wizardKey != null) ? wizardKey.replaceAll('_', '-') : null;
            
            if(custApprovalObj.IsApprovalObtained != null && custApprovalObj.IsApprovalObtained) {
                custApprovalRec.Status__c = 'Approved';
                isStatusToBeChanged = true;
            } else {
                custApprovalRec.Status__c = 'Pending';
            }
            custApprovalRec.Notes__c = custApprovalObj.Notes;
            custApprovalRec.ApprovalType__c = custApprovalObj.ApprovalType;
            if(approvalTypeToApprovalRecordMap.containsKey(custApprovalObj.ApprovalType)) {
                custApprovalRec.Id = approvalTypeToApprovalRecordMap.get(custApprovalObj.ApprovalType).Id;
                approvalTypeToApprovalRecordMap.remove(custApprovalObj.ApprovalType);
            } 
            approvalListToUpsert.add(custApprovalRec);
        }
        
        if(approvalListToUpsert.size() > 0) {
            upsert approvalListToUpsert;
        }
        if(approvalTypeToApprovalRecordMap.values().size() > 0) {
            delete approvalTypeToApprovalRecordMap.values();
        }
        if(isStatusToBeChanged) {
            if(wizardKey == 'Claim_Submission') {
                changeStatus(BPUtility.getEncodedString(soHeaderId), BPUtility.getEncodedString(newWorkStatus), BPUtility.getEncodedString('claim'));


            } else {
                changeStatus(BPUtility.getEncodedString(soHeaderId), BPUtility.getEncodedString(newWorkStatus), BPUtility.getEncodedString('work'));


            }
        }
    }
    
    
    @remoteAction
    global static String sendOnSignInWizard(String custJsonStr, String notes, String soHeaderId, String customerName) {
        custJsonStr = BPUtility.getDecodedString(custJsonStr);
        notes = BPUtility.getDecodedString(notes);
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        customerName = BPUtility.getDecodedString(customerName);
        if(AccessControl.ifObjectFieldIsAccessible('Organization') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        

        List<SOWizard.CustInfo> custJSONList = (List<SOWizard.CustInfo>) System.JSON.deserialize(custJsonStr, List<SOWizard.CustInfo>.class);
        List<String> emailStrList = new List<String>();
        
        for(SOWizard.CustInfo custInfoObj : custJSONList) {
            if(custInfoObj.IsSelected && custInfoObj.Label != null && custInfoObj.Type == 'EMAIL' && custInfoObj.Value != null) {
                emailStrList.add(custInfoObj.Value);
            } 
        }
        
        List<Organization> companyInformationList = [SELECT Id, LanguageLocaleKey, Name, Phone FROM Organization where Id = :UserInfo.getOrganizationId()];
        if(companyInformationList.size() == 0) {
            return BPUtility.getEncodedString('Please set Company Information first');
        }
        
        Organization company = companyInformationList[0];
        
        String subject = company.Name + ' - Service Update';
        String body = 'Hello '+ customerName +'<br/><br/>We need to get your approval before continuing to service your unit.  Please review the following information and let us know if we can proceed.<br/><br/>';
        body += 'If you have any questions on anything you see, don\'t hesitate to contact us. <br/><br/> Looking forward to hearing from you soon,<br/><br/>';
        body += UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '<br/>' + company.Name + '<br/>' + company.Phone + '<br/>';
        try {
            SendEmail.send(emailStrList, subject, body, soHeaderId);
            if(emailStrList.size() > 0) {
                return BPUtility.getEncodedString('Sent');

            }


        } catch(Exception e) {
            

        }
        return BPUtility.getEncodedString('Not Sent');

    }
    
    @remoteAction
    global static void changeStatus(String soHeaderId, String newStatus, String statusType) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        newStatus = BPUtility.getDecodedString(newStatus);
        statusType = BPUtility.getDecodedString(statusType);
        if(String.isNotBlank(soHeaderId)) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            

            Service_Order_Header__c soHeader = new Service_Order_Header__c(Id = soHeaderId);
            if(statusType.equalsIgnoreCase('work')) {
                soHeader.Work_Status__c = newStatus;
            } else {
                soHeader.Claim_Status__c = newStatus;
            }
            update soHeader;
        } 
    }
    
    @RemoteAction
    global static string addDeductibleAmount(String deductibleJson) {
        deductibleJson = BPUtility.getDecodedString(deductibleJson);
        SOHeaderWrapper.Deductible soPaymentWrapperObj = (SOHeaderWrapper.Deductible)System.JSON.deserialize(deductibleJson, SOHeaderWrapper.Deductible.class);
        String soPaymentRoleRecId = ServiceJobService.saveDeductibleAmount(soPaymentWrapperObj);
        return getSOHeaderDetails(BPUtility.getEncodedString(soPaymentWrapperObj.coHeaderId), BPUtility.getEncodedString('checkOut'));
    }
    
    @RemoteAction
    global static String getSoPaymentRoleById(String soHeaderId){
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        List<SOPaymentWrapper> soPaymentRoleObjList = ServiceJobService.getSoPaymentRoleById(soHeaderId, 'Owing');
        return BPUtility.getEncodedString(System.JSON.serialize(soPaymentRoleObjList));
    }
    
    @RemoteAction
    global static String getAttachmentListByParentId(String parentId) {
        parentId = BPUtility.getDecodedString(parentId);
        parentId = BPUtility.escapeSingleQuotes(parentId);
        if(AccessControl.ifObjectFieldIsAccessible('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Attachment> attList = [select Description, Name, CreatedDate from Attachment where ParentId = : parentId];
        if(attList.size() == 0) {
            return BPUtility.getEncodedString('{}');


        }
        
        List<SOHeaderWrapper.Attachments> attachList = new List<SOHeaderWrapper.Attachments>();
        for(Attachment att : attList) {
            attachList.add(new SOHeaderWrapper.Attachments(att));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(attachList));
    }
    
    @remoteAction
    global static String removeAttachment(String attachmentId, String soHeaderId) {
        attachmentId = BPUtility.getDecodedString(attachmentId);
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        if(AccessControl.ifObjectIsDeletable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        attachmentId = BPUtility.escapeSingleQuotes(attachmentId);
        List<Attachment> attList = [select Id from Attachment where Id = : attachmentId];
        if(attList.size() > 0) {
            delete attList;
        }
        return getAttachmentListByParentId(BPUtility.getEncodedString(soHeaderId));
    }
    
    @RemoteAction
    global static String uploadAttachment(String filename, String fileData, String recordId, String description) {
        filename = BPUtility.getDecodedString(filename);
        fileData = BPUtility.getDecodedString(fileData);
        recordId = BPUtility.getDecodedString(recordId);
        description = BPUtility.getDecodedString(description);
        if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        

        String user = UserInfo.getUserID();
        if(fileData == null) {
            return BPUtility.getEncodedString(String.valueOf('Invalid file data.'));
        }
        String base64 = fileData.substring(fileData.indexOf(',') + 1);
        Blob actualdata = EncodingUtil.base64Decode(base64);
        if(actualdata.size()<=0) {
            return BPUtility.getEncodedString(String.valueOf('File size cannot be greater then 10 MB.'));
        }
        
        Attachment att = new Attachment(ParentId = recordId, Body = actualdata);
        att.Name = filename;
        att.Description = description;
        insert(att);
        
        return getAttachmentListByParentId(BPUtility.getEncodedString(recordId));
    }
    
      
    @RemoteAction
    global static String getClaimRecById(String soHeaderId){
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        List<Claim__c> claimRecList = SOQLUtil.getClaimDetailsBySOHeaderId(soHeaderId); 
        if(claimRecList.size() == 0) {
            return BPUtility.getEncodedString('{}');


        }
        List<SO_Payment_Role__c> soPaymentRoles = SOQLUtil.getSOPaymentWrapperById(soHeaderId, null);
        List<Category__c> internalCategoryList = SOQLUtil.getCategoryById('Internal Expense');
        List<SO_Payment_Role__c> deductibleList = new List<SO_Payment_Role__c>();
        
        for(SO_Payment_Role__c soPaymentRec : soPaymentRoles) {
            if(soPaymentRec.RecordType.DeveloperName == 'Deductible') {
                deductibleList.add(soPaymentRec);
            }
        }
        ClaimWizard claimObj = new ClaimWizard(claimRecList[0], deductibleList,internalCategoryList);
        return BPUtility.getEncodedString(System.JSON.serialize(claimObj));
    }
    
    @RemoteAction
    global static String getCustomerApprovalInfo(String soHeaderId, String sectionKey, Decimal approvalCount){
        if(AccessControl.ifObjectFieldIsAccessible('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        sectionKey = BPUtility.getDecodedString(sectionKey);
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);

        List<CustomerApproval> custApprovalList = new List<CustomerApproval>();
        List<CustomerApproval__c> customerApprovalList = new List<CustomerApproval__c>();
        
        if(sectionKey == 'Get_Approval' && approvalCount != null) {
            customerApprovalList = [select Approval_Count__c, ApprovalDetailJson__c, ApprovalType__c, Notes__c, Section_key__c, Name, LastModifiedDate,
                                                Section_Name__c, Service_Order_Header__c, Status__c from CustomerApproval__c 
                                                where Service_Order_Header__c =: soHeaderId AND Approval_Count__c = :approvalCount];
        
        } else if(sectionKey != 'Get_Approval') {
            customerApprovalList = [select Approval_Count__c, ApprovalDetailJson__c, ApprovalType__c, Notes__c, Section_key__c, Name, LastModifiedDate,
                                                Section_Name__c, Service_Order_Header__c, Status__c from CustomerApproval__c 
                                                where Service_Order_Header__c =: soHeaderId AND Section_key__c =: sectionKey];
        
        } 
        
        for(CustomerApproval__c custApproval : customerApprovalList) {
            custApprovalList.add(new CustomerApproval(custApproval));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(custApprovalList));
    }
    
    @RemoteAction
    global static String saveCustomerApprovalInfo(String soHeaderId, String JSONString) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        JSONString = BPUtility.getDecodedString(JSONString);
        if(AccessControl.ifObjectFieldIsAccessible('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectIsDeletable('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
        List<CustomerApproval> custApprovalObjList = (List<CustomerApproval>)System.JSON.deserialize(JSONString, List<CustomerApproval>.class);
        List<CustomerApproval__c> custApprovalList = new List<CustomerApproval__c>();
        Decimal approvalCount;
        for(CustomerApproval custApprovalObj : custApprovalObjList) {
            //soHeaderId = custApprovalObj.ServiceOrderHeader;
            if(custApprovalObj.ApprovalCount != null) {
                approvalCount = custApprovalObj.ApprovalCount;
            }   
        }
        List<CustomerApproval__c> existingApprovalList;
        if(approvalCount == null) {
            
            existingApprovalList = [select Id, Approval_Count__c from CustomerApproval__c where Service_Order_Header__c =: soHeaderId 
                                                                        AND Section_key__c = 'Get_Approval'

                                                                        Order By Approval_Count__c DESC nulls last];
            approvalCount = (existingApprovalList.size() == 0) ? 1 : (existingApprovalList[0].Approval_Count__c + 1);                                                      
        }
        
        
        existingApprovalList = [select Id, Section_key__c, ApprovalType__c, Approval_Count__c
                                        from CustomerApproval__c where Service_Order_Header__c =: soHeaderId
                                        and Approval_Count__c =: approvalCount]; 
        
        Map<String, CustomerApproval__c> approvalTypeToApprovalRecordMap = new Map<String, CustomerApproval__c>();
        for(CustomerApproval__c custApprovalRec : existingApprovalList) {
            approvalTypeToApprovalRecordMap.put(custApprovalRec.ApprovalType__c, custApprovalRec);
        }                                                   
        
        List<CustomerApproval__c> approvalListToUpsert = new List<CustomerApproval__c>();
        for(CustomerApproval custApprovalObj : custApprovalObjList) {
            CustomerApproval__c custApprovalRec = new CustomerApproval__c();
            custApprovalRec.Service_Order_Header__c = soHeaderId;
            custApprovalRec.Section_key__c = 'Get_Approval';
            custApprovalRec.Section_Name__c = 'Get-Approval';
            
            if(custApprovalObj.IsApprovalObtained != null && custApprovalObj.IsApprovalObtained) {
                custApprovalRec.Status__c = 'Approved';
            } else {
                custApprovalRec.Status__c = 'Pending';
            }
            custApprovalRec.Notes__c = custApprovalObj.Notes;
            custApprovalRec.ApprovalType__c = custApprovalObj.ApprovalType;
            custApprovalRec.Approval_Count__c = approvalCount;
            if(approvalTypeToApprovalRecordMap.containsKey(custApprovalObj.ApprovalType)) {
                custApprovalRec.Id = approvalTypeToApprovalRecordMap.get(custApprovalObj.ApprovalType).Id;
                approvalTypeToApprovalRecordMap.remove(custApprovalObj.ApprovalType);
            } 
            approvalListToUpsert.add(custApprovalRec);
        }
        
        if(approvalListToUpsert.size() > 0) {
            upsert approvalListToUpsert;
        }
        if(approvalTypeToApprovalRecordMap.values().size() > 0) {
            delete approvalTypeToApprovalRecordMap.values();
        }
        
        return getCustomerApprovalInfo(BPUtility.getEncodedString(soHeaderId), BPUtility.getEncodedString('Get_Approval'),approvalCount);
    }
    
    @RemoteAction
    global static String getProviderInfo(String vendorId){
        vendorId = BPUtility.getDecodedString(vendorId);
        return ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(vendorId));    
    }
    
    @RemoteAction
    global static String getPrintingInfo(String soHeaderId){
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        return SOHeaderPrintPreviewCtrl.getPrinitngInfo(BPUtility.getEncodedString(soHeaderId));    
    }
    
    
    @RemoteAction
    global static void createClaim(Service_Order_Header__c soHeaderRec){
        Claim__c claimRec = new Claim__c(Service_Order_Header__c = soHeaderRec.Id);
        if(AccessControl.ifObjectFieldIsCreateable('Claim__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert claimRec;
    }
    
    
    @RemoteAction
    global static String submitClaimRecords(String soHeaderId) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        if(AccessControl.ifObjectFieldIsAccessible('Claim__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Claim__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);
        List<Service_Order_Line_Item__c> soLineItemList = SOQlUtil.getServiceOrderLineItemBySoHeader(soHeaderId);
        List<Claim__c> claimRecords = [select Id from Claim__c where Service_Order_Header__c =: soHeaderId];
        if(claimRecords.size() > 0 || soLineItemList.size() == 0) {
            return BPUtility.getEncodedString('{}');
        }  
        
        Claim__c claimRec = new Claim__c();
        claimRec.Service_Order_Header__c = soHeaderId;
        claimRec.Claim_Disposition__c = 'Accepted';
        insert claimRec;
        
        List<RecordType> ThirdPartRecordTypeList =  SOQLUtil.getRecordTypeId(Constants.NAMESPACE + 'SO_Payment_Role__c', 'Third_Party');
        SO_Payment_Role__c sopaymetntRoleRec = new SO_Payment_Role__c(Service_Order_Header__c = soHeaderId, Claim__c = claimRec.Id,
                                                                        RecordTypeId = ThirdPartRecordTypeList[0].Id);
        insert sopaymetntRoleRec;                                                               
        
        List<Claim_Line_Item__c> claimLineItemList = new List<Claim_Line_Item__c>();
        Decimal TotalAmount = 0;
        Decimal TotalTaxamount = 0;
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        for(Service_Order_Line_Item__c soLineItemRec : soLineItemList) {
            Claim_Line_Item__c  claimLineItemRec= new Claim_Line_Item__c();
            Decimal Amount = 0;
            claimLineItemRec.Approved_Price__c = isTaxIncludingPricing ? soLineItemRec.Price_When_Tax_Included__c : soLineItemRec.Kit_Price__c;
            claimLineItemRec.Approved_Qty__c = soLineItemRec.Qty_Needed__c;
            claimLineItemRec.Claimed_Price__c = isTaxIncludingPricing ? soLineItemRec.Price_When_Tax_Included__c : soLineItemRec.Kit_Price__c; 
            claimLineItemRec.Claimed_Qty__c = soLineItemRec.Qty_Needed__c;
            
            /* START: Added By Tarun - #170 - 09/23/2016 */
            claimLineItemRec.Item_Code__c = soLineItemRec.Item_Code__c ;
            claimLineItemRec.Item_Description__c = soLineItemRec.Item_Description__c ;
            
            claimLineItemRec.Item_Desc__c = soLineItemRec.Item_Desc__c ;
            claimLineItemRec.Service_Order_Line_Item__c = soLineItemRec.Id;
            claimLineItemRec.SO_Payment_Role__c = sopaymetntRoleRec.Id;
            
            //claimLineItemRec.Tax__c = soLineItemRec.Tax__c;
            Decimal soLineItemRecTaxRate = 0;
            for(Individual_Tax__c individualTaxItem: soLineItemRec.Individual_Taxes__r) {
                soLineItemRecTaxRate += individualTaxItem.Tax_Rate__c;
            }
            claimLineItemRec.Tax__c = soLineItemRecTaxRate;
            
            claimLineItemRec.Claim__c = claimRec.Id;
            Amount = (soLineItemRec.Kit_Price__c !=null) ? soLineItemRec.Kit_Price__c : 0;
            TotalAmount += (Amount *claimLineItemRec.Approved_Qty__c);
            TotalTaxamount += Amount * ((soLineItemRec.Tax__c != null) ? soLineItemRec.Tax__c : 0) / 100;
            claimLineItemList.add(claimLineItemRec);
        }
                
        if(claimLineItemList.size() > 0){
            insert claimLineItemList;
        }
        
        if(claimLineItemList.size() > 0 && sopaymetntRoleRec.Id !=null){
            sopaymetntRoleRec.Total_Amount__c = TotalAmount;
            sopaymetntRoleRec.Tax_Amount__c = TotalTaxamount;
            update sopaymetntRoleRec;
        }
        changeStatus(BPUtility.getEncodedString(soHeaderId), BPUtility.getEncodedString('Submitted'), BPUtility.getEncodedString('claim'));
        return BPUtility.getEncodedString('{}');
    }
    
      @RemoteAction
    global static String saveClaimResponse(String soHeaderId,String ClaimWizardJson,String StepNumber){
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        ClaimWizardJson = BPUtility.getDecodedString(ClaimWizardJson);
        if(StepNumber == '1'){
            if(AccessControl.ifObjectFieldIsUpdateable('Claim__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            

            ClaimWizard claimWizardObj = (ClaimWizard)System.JSON.deserialize(ClaimWizardJson, ClaimWizard.class);
             
            Claim__c claimRec =  new  Claim__c();
            if(claimWizardObj.ClaimId != null ){
                claimRec.Id = claimWizardObj.ClaimId;
            }
            claimRec.Provider_Claim_Number__c = claimWizardObj.ProviderClaimNumber;
            claimRec.Notes__c =claimWizardObj.Notes;
            if(claimWizardObj.ResponseDate != null) {
                claimRec.Response_Date__c = (String.isNotBlank(claimWizardObj.ResponseDate)) ? Date.parse(claimWizardObj.ResponseDate) : null;
                //claimRec.Response_Date__c = DateTime.valueOf(claimWizardObj.ResponseDate).format('MM/dd/yyyy');
            }
            claimRec.Claim_Disposition__c =claimWizardObj.ClaimDisposition;
            claimRec.Service_Order_Header__c = soHeaderId;
            update claimRec;
        }
        if(StepNumber == '2'){
            CreateNewVariance( soHeaderId, ClaimWizardJson);
        } else if(StepNumber == '3'){
             updateVariance(soHeaderId, ClaimWizardJson, false);
             //changeStatus(BPUtility.getEncodedString(soHeaderId), BPUtility.getEncodedString('Approved'), BPUtility.getEncodedString('claim'));
        }
        return getWizardInfo(BPUtility.getEncodedString(soHeaderId), BPUtility.getEncodedString('Claim_Response'));
    }
    
    // Update Bill to information for Variable
     public Static String updateVariance(String soHeaderId, String ClaimWizardJson, Boolean isFinalize) {
        if(AccessControl.ifObjectFieldIsAccessible('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('RecordType') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Claim_Line_item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('So_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('So_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectIsDeletable('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        soHeaderId = BPUtility.escapeSingleQuotes(soHeaderId);

        ClaimWizard claimWizardObj = (ClaimWizard)System.JSON.deserialize(ClaimWizardJson, ClaimWizard.class);
        List<ClaimWizard.ClaimLineItem>  claimLineItemClassList = claimWizardObj.VarianceLineItemList;
        
        //If Finalize
        Map<Id, ClaimWizard.ClaimLineItem> soliIdToNonVarianceClaimLIRecordMap = new Map<Id, ClaimWizard.ClaimLineItem>();
        List<Service_Order_Line_Item__c> soliListToUpdate = new List<Service_Order_Line_Item__c>();
    	if(isFinalize) {
    		if(claimWizardObj.NonVarianceLineItemList != null && claimWizardObj.NonVarianceLineItemList.size() > 0) {
    			for(ClaimWizard.ClaimLineItem nonVarianceClaimLI : claimWizardObj.NonVarianceLineItemList) {
    				soliIdToNonVarianceClaimLIRecordMap.put(nonVarianceClaimLI.ServiceOrderLineItem, nonVarianceClaimLI);
    			}
    		}
    	}
    	
        map<Id,SO_Payment_Role__c> CategoryToSoPaymentRoleMap = new   map<Id,SO_Payment_Role__c>();
        if( claimWizardObj.ClaimId == null) {
            return 'ID Doesnt Exits';
        } else {
            map<Id,Claim_Line_Item__c> claimLineOldmap = new map<Id,Claim_Line_Item__c> ([select Id,SO_Payment_Role__r.Status__c, Approved_Price__c,Is_Variance__c,
            			Service_Order_Line_Item__r.Actual_Kit_Price__c, 
            			Approved_Qty__c, Variance_Qty__c, Variance_Amount__c, Service_Order_Line_Item__r.Service_Order_Header__r.CO_Header__c, Service_Order_Line_Item__c, 
            			Service_Order_Line_Item__r.Service_Order_Header__r.Customer_Owned_Unit__c, SO_Payment_Role__c, SO_Payment_Role__r.RecordType.DeveloperName,
            			Service_Order_Line_Item__r.Part__c, Service_Order_Line_Item__r.Fee__c, Service_Order_Line_Item__r.Labour_Code__c, Service_Order_Line_Item__r.Sublet__c 
                        From Claim_Line_Item__c where Claim__c =: claimWizardObj.ClaimId and Is_Variance__c = true]);
                                                                                        
            List<SO_Payment_Role__c> SoPaymentList = [select Id,Status__c,RecordType.DeveloperName,Category__c from SO_Payment_Role__c where Service_Order_Header__c =: soHeaderId and
                                                     RecordType.DeveloperName ='Internal' and Status__c !='Invoiced' order by LastModifiedDate];
            List<RecordType> RecordTypeList =([select Id,DeveloperName from RecordType where RecordType.DeveloperName ='Internal' or  RecordType.DeveloperName ='customer']);
            String CustomerRecordType;
            String InternalRecordType;
            
            for(RecordType recordItem :  RecordTypeList) {
                if(recordItem.DeveloperName =='Internal') {
                    InternalRecordType = recordItem.Id;
                } else if(recordItem.DeveloperName =='Customer') {
                    CustomerRecordType = recordItem.Id;
                }
            }
            
            for(SO_Payment_Role__c SoPaymentRecord : SoPaymentList) {
	            if(SoPaymentRecord.Category__c != null) {
	                CategoryToSoPaymentRoleMap.put(SoPaymentRecord.Category__c, SoPaymentRecord);
	            }
            }
            String coHeaderId;
            String couId;
            List<Claim_Line_Item__c> InternalSoPaymentClaimLineItemList = new List<Claim_Line_Item__c>();
            map<Id,SO_Payment_Role__c> ClaimLineItemIdToSopayment = new map<Id,SO_Payment_Role__c>();
            map<Id,Claim_Line_Item__c> IdToClaimLineItemMap = new map<Id,Claim_Line_Item__c>();
            List<Claim_Line_Item__C> CategoryIdToClaimLineList = new List<Claim_Line_Item__C> ();
            List<Service_Order_Header__c> soHeaderListToInsert = new List<Service_Order_Header__c>();
            
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            for(ClaimWizard.ClaimLineItem ClaimLineItemVarianceRec :  claimLineItemClassList) {
                if(claimLineOldmap.ContainsKey(ClaimLineItemVarianceRec.Id)) {
                	if(coHeaderId == null) {
                		coHeaderId = claimLineOldmap.get(ClaimLineItemVarianceRec.Id).Service_Order_Line_Item__r.Service_Order_Header__r.CO_Header__c;
                		couId = claimLineOldmap.get(ClaimLineItemVarianceRec.Id).Service_Order_Line_Item__r.Service_Order_Header__r.Customer_Owned_Unit__c;
                	}
                    Claim_Line_Item__c claimRec =  claimLineOldmap.get(ClaimLineItemVarianceRec.Id);
                    if(claimRec.SO_Payment_Role__r.RecordType.DeveloperName !=  ClaimLineItemVarianceRec.BillTo){
                    	Claim_Line_Item__c ClaimRecordsTosave =  new Claim_Line_Item__c();
                        ClaimRecordsTosave.Id= ClaimLineItemVarianceRec.Id;
                        ClaimRecordsTosave.Variance_Amount__c= ClaimLineItemVarianceRec.VarianceAmount; 
                        ClaimRecordsTosave.Variance_Qty__c= ClaimLineItemVarianceRec.VarianceQuantity;
                        ClaimRecordsTosave.Claim__c = ClaimLineItemVarianceRec.Claim;
                        ClaimRecordsTosave.Category__c = ClaimLineItemVarianceRec.Category;  
                        ClaimRecordsTosave.Total_Variance_Amount__c = ClaimLineItemVarianceRec.TotalVariance;  
                        ClaimRecordsTosave.Tax__c =  ClaimLineItemVarianceRec.Tax;
                        ClaimRecordsTosave.Bill_To__c = ClaimLineItemVarianceRec.BillTo;
                        if(ClaimLineItemVarianceRec.BillTo =='Customer') {
                            IdToClaimLineItemMap.put(ClaimRecordsTosave.Id, ClaimRecordsTosave);
                        } else if(ClaimLineItemVarianceRec.BillTo =='Internal') {
                            if(CategoryToSoPaymentRoleMap.containsKey(ClaimRecordsTosave.Category__c)) {
                                CategoryIdToClaimLineList.add(ClaimRecordsTosave);
                            } else{
                                SO_Payment_Role__c soPaymentRec = new SO_Payment_Role__c(Service_Order_Header__c = claimWizardObj.soHeaderId,
                                RecordTypeId = InternalRecordType,Status__c='Pending',Category__c = ClaimRecordsTosave.Category__c,
                                Claim__c =ClaimRecordsTosave.Claim__c); 
                                CategoryToSoPaymentRoleMap.put(ClaimRecordsTosave.Category__c,soPaymentRec);
                                CategoryIdToClaimLineList.add(ClaimRecordsTosave);
                            }
                            
                        	if(isFinalize && soliIdToNonVarianceClaimLIRecordMap.containsKey(ClaimLineItemVarianceRec.ServiceOrderLineItem)) {
                        		ClaimWizard.ClaimLineItem nonVarianceClaimLI = soliIdToNonVarianceClaimLIRecordMap.get(ClaimLineItemVarianceRec.ServiceOrderLineItem);
		                        Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c(Id = ClaimLineItemVarianceRec.ServiceOrderLineItem);
		                        if(isTaxIncludingPricing) {
		                        	soliRec.Price_when_Tax_Included__c = nonVarianceClaimLI.ApprovedPrice;
		                        	soliRec.kit_Price__c = (nonVarianceClaimLI.ApprovedPrice / (1 + nonVarianceClaimLI.Tax / 100));
		                        } else {
		                        	soliRec.Kit_Price__c = nonVarianceClaimLI.ApprovedPrice;
		                        }
		                        soliListToUpdate.add(soliRec);
                        	}
                        }
                    }
                }
            }

            List<Claim_Line_Item__c> ClaimLineItemListToUpdate = new List<Claim_Line_Item__c>();
            List<So_Payment_Role__c>  SoPaymentRoleInternal =new  List<So_Payment_Role__c>();
           
			if(CategoryToSoPaymentRoleMap.Size() > 0 ){
			    upsert CategoryToSoPaymentRoleMap.Values();  
			    for(Claim_Line_Item__c claimLineItemRec :  CategoryIdToClaimLineList){
		            So_Payment_Role__C SopaymentRec = CategoryToSoPaymentRoleMap.get(claimLineItemRec.Category__c);
		            claimLineItemRec.SO_Payment_Role__c = SopaymentRec.Id;
		            ClaimLineItemListToUpdate.add(claimLineItemRec);
			     }
			     
			     if(isFinalize) {
				     update ClaimLineItemListToUpdate;
				     ServiceOrderLineItemTriggerHelper.isUpdateClaimLI = false;
				     update soliListToUpdate;
				     ServiceOrderLineItemTriggerHelper.isUpdateClaimLI = true;
			     }
			}
			if(IdToClaimLineItemMap.Size() > 0) {
				if(isFinalize) {
					ServiceJobService.handleBillToCustomerVariance(IdToClaimLineItemMap, claimLineOldmap, coHeaderId, couId);
				} else {
					update IdToClaimLineItemMap.values();
				}
            }
            
            List<SO_Payment_Role__c> SoPaymentAllList =[select Id,Total_Amount__c,Tax_Amount__c ,RecordType.DeveloperName,(select Id,Approved_Qty__c,Approved_Price__c,
            			Tax__c, Variance_Qty__c,Variance_Amount__c, Service_Order_Line_Item__r.Kit_Price__c, Total_Variance_Amount__c from Claim_Line_items__r ) 
            			from SO_Payment_Role__c where Service_Order_Header__c =: soHeaderId  and RecordType.DeveloperName !='Deductible'];

            List<SO_Payment_Role__c> SoPaymentListToDelete = new  List<SO_Payment_Role__c>();
            List<SO_Payment_Role__c> SoPaymentListToUpdate = new  List<SO_Payment_Role__c>();

            for(SO_Payment_Role__c  SolPayemtRec : SoPaymentAllList){
                if(SolPayemtRec.Claim_Line_Items__r.size()==0){
                    SoPaymentListToDelete.add(SolPayemtRec);
                } else {
                    SoPaymentListToUpdate.add(SolPayemtRec);
                }
            }
            UpdateSoPaymentTotal(SoPaymentListToUpdate);
            if(SoPaymentListToDelete.size() > 0 ){
                delete SoPaymentListToDelete;
            }                   
        }
        return '{}';
	}
         
     // create new Variance For SOLI's
     public Static String CreateNewVariance(String soHeaderId, String ClaimWizardJson){
        if(AccessControl.ifObjectFieldIsAccessible('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        

        if(AccessControl.ifObjectFieldIsCreateable('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Claim__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectIsDeletable('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        

        ClaimWizard claimWizardObj = (ClaimWizard)System.JSON.deserialize(ClaimWizardJson, ClaimWizard.class);
        Claim__c claimRec =  new  Claim__c();
        claimRec.Id = claimWizardObj.ClaimId;
        claimRec.Claim_Number__c =  claimWizardObj.ClaimNumber;
        claimRec.Provider_Claim_Number__c = claimWizardObj.ProviderClaimNumber;
        claimRec.Notes__c =claimWizardObj.Notes;
        //claimRec.Response_Date__c = DateTime.valueOf(claimWizardObj.ResponseDate).format('MM/dd/yyyy');
        claimRec.Claim_Disposition__c =claimWizardObj.ClaimDisposition;
        claimRec.Service_Order_Header__c = soHeaderId;
        update claimRec;
        
        List<ClaimWizard.ClaimLineItem>  claimLineItemClassList = claimWizardObj.NonVarianceLineItemList ;
        
        List<Claim_Line_Item__c> claimLineOldList=new List<Claim_Line_Item__c> ([select Id,SO_Payment_Role__r.Status__c, Approved_Price__c, Is_Variance__c,
                                                                                SO_Payment_Role__r.RecordType.DeveloperName,Approved_Qty__c, 
                                                                                Claimed_Qty__c, Claimed_Price__c, Variance_Qty__c,
                                                                                Variance_Amount__c, Service_Order_Line_Item__c
                                                                                From Claim_Line_Item__c where  Claim__c =: claimRec.Id]);
        Map<Id,Claim_Line_Item__c> SoliToClaimLineItemMap =  new Map<Id,Claim_Line_Item__c>();  
        Map<Id,Claim_Line_Item__c> SoliToCaimVarinceLineItemMap =  new Map<Id,Claim_Line_Item__c>();  
        set<Id> SoPaymentRoleToUpdateSet = new set<Id>();
        for(Claim_Line_Item__c claimLineItemRec : claimLineOldList){
            if(claimLineItemRec.Is_Variance__c) {
                SoliToCaimVarinceLineItemMap.put(claimLineItemRec.Service_Order_Line_Item__c,claimLineItemRec );
            } else {
                if(claimLineItemRec.SO_Payment_Role__c !=null) {
                    SoPaymentRoleToUpdateSet.add(claimLineItemRec.SO_Payment_Role__c);
                }
                SoliToClaimLineItemMap.put(claimLineItemRec.Service_Order_Line_Item__c,claimLineItemRec );
            }
        } 
        List<Claim_Line_Item__c> claimLineItemList = new List<Claim_Line_Item__c>();
        List<Claim_Line_Item__c> claimLineItemVarianceList = new List<Claim_Line_Item__c>();
        List<Claim_Line_Item__c> claimLineItemVarianceListToDelete = new List<Claim_Line_Item__c>();
        
        for(ClaimWizard.ClaimLineItem  claimLineItemobj :claimLineItemClassList  ){
            Claim_Line_Item__c claimLineItemRec = new Claim_Line_Item__c();
            Claim_Line_Item__c claimLineItemVarRec = new Claim_Line_Item__c();
            Claim_Line_Item__c claimLineItemVarRecToDelete = new Claim_Line_Item__c();
            
            if(SoliToClaimLineItemMap.get(claimLineItemobj.ServiceOrderLineItem).Approved_Price__c != claimLineItemobj.ApprovedPrice ||  
                SoliToClaimLineItemMap.get(claimLineItemobj.ServiceOrderLineItem).Approved_Qty__c != claimLineItemobj.ApprovedQty || 
                SoliToClaimLineItemMap.get(claimLineItemobj.ServiceOrderLineItem).Claimed_Qty__c != claimLineItemobj.ClaimedQty || 
                SoliToClaimLineItemMap.get(claimLineItemobj.ServiceOrderLineItem).Claimed_Price__c != claimLineItemobj.ClaimedPrice) {
                    
                if(SoliToClaimLineItemMap.get(claimLineItemobj.ServiceOrderLineItem).SO_Payment_Role__r.Status__c =='Invoiced'){
                    return'{}';
                } else if( SoliToCaimVarinceLineItemMap.containsKey(claimLineItemobj.ServiceOrderLineItem) && SoliToCaimVarinceLineItemMap.get(claimLineItemobj.ServiceOrderLineItem).SO_Payment_Role__c  !=null && SoliToCaimVarinceLineItemMap.get(claimLineItemobj.ServiceOrderLineItem).SO_Payment_Role__r.Status__c  =='Invoiced'  ){
                    return'{}';
                } else{   
                    claimLineItemRec.Id = claimLineItemobj.Id; 
                    claimLineItemRec.Claimed_Price__c =  claimLineItemobj.ClaimedPrice;
                    claimLineItemRec.Claimed_Qty__c   =  claimLineItemobj.ClaimedQty;
                    claimLineItemRec.Approved_Price__c =  claimLineItemobj.ApprovedPrice;
                    claimLineItemRec.Approved_Qty__c   =  claimLineItemobj.ApprovedQty;  
                    if(claimLineItemobj.ClaimedQty > claimLineItemobj.ApprovedQty ||  claimLineItemobj.ClaimedPrice >  claimLineItemobj.ApprovedPrice){
                        if( SoliToCaimVarinceLineItemMap.ContainsKey(claimLineItemobj.ServiceOrderLineItem)){
                            claimLineItemVarRec.Id = SoliToCaimVarinceLineItemMap.get(claimLineItemobj.ServiceOrderLineItem).Id;
                        }
                        /* START: Added By Tarun - #170 - 09/24/2016 */
                        claimLineItemVarRec.Item_Code__c =  claimLineItemobj.ItemCode;
                        claimLineItemVarRec.Item_Description__c =  claimLineItemobj.ItemDescription;
                         
                        claimLineItemVarRec.Item_Desc__c =  claimLineItemobj.Itemdesc;
                        claimLineItemVarRec.Claim__c = claimWizardObj.ClaimId;
                        claimLineItemVarRec.Approved_Qty__c   =  claimLineItemobj.ApprovedQty;  
                        claimLineItemVarRec.Approved_Price__c =  claimLineItemobj.ApprovedPrice;
                        claimLineItemVarRec.Variance_Amount__c = claimLineItemobj.ClaimedPrice -claimLineItemobj.ApprovedPrice;
                        claimLineItemVarRec.Variance_Qty__c = claimLineItemobj.ClaimedQty - claimLineItemobj.ApprovedQty;
                        claimLineItemVarRec.Is_Variance__c= true;
                        claimLineItemVarRec.Bill_To__c = (claimLineItemobj.ClaimedQty > claimLineItemobj.ApprovedQty) ? 'Customer' : 'Internal';
                        claimLineItemVarRec.Service_Order_Line_Item__c = claimLineItemobj.ServiceOrderLineItem;
                        claimLineItemVarRec.Total_Variance_Amount__c   =
                        ((claimLineItemobj.ClaimedPrice * claimLineItemobj.ClaimedQty) - (claimLineItemobj.ApprovedPrice *  ((claimLineItemobj.ApprovedQty == 0) ? 1 : claimLineItemobj.ApprovedQty)));
                        claimLineItemVarRec.Tax__c   = claimLineItemobj.Tax;
                        claimLineItemVarianceList.add(claimLineItemVarRec);
                    } else {
		            	if(SoliToCaimVarinceLineItemMap.containsKey(claimLineItemobj.ServiceOrderLineItem)){
		                   claimLineItemVarRecToDelete.Id = SoliToCaimVarinceLineItemMap.get(claimLineItemobj.ServiceOrderLineItem).Id;
		                   claimLineItemVarianceListToDelete.add(claimLineItemVarRecToDelete);
		                }
                    }
                	claimLineItemList.add(claimLineItemRec);
                }
            }
        }
            
        if(claimLineItemList.size() > 0){
            upsert claimLineItemList;
        }
        
      
        if(claimLineItemVarianceList.size() > 0){
            upsert claimLineItemVarianceList;
        } 
        
        if(claimLineItemVarianceListToDelete.size() > 0){
            delete claimLineItemVarianceListToDelete;
        }
        
        List<SO_Payment_Role__c>  SoPaymentListToUpdate = ([select Id,Total_Amount__c,Tax_Amount__c ,RecordType.DeveloperName,(select Id,Approved_Qty__c,Approved_Price__c,
        													Tax__c, Variance_Qty__c,Variance_Amount__c, Total_Variance_Amount__c, Service_Order_Line_Item__r.Kit_Price__c
                                                            from Claim_Line_items__r)  From  SO_Payment_Role__c where Id IN:SoPaymentRoleToUpdateSet]);
        UpdateSoPaymentTotal(SoPaymentListToUpdate);
        //
        return'{}';
    }

    public Static List<So_Payment_Role__c> UpdateSoPaymentTotal(List<So_Payment_Role__c> SoPaymentListToUpdate) {
        if(AccessControl.ifObjectFieldIsUpdateable('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        for(SO_Payment_Role__c SoRolePaymentRec :  SoPaymentListToUpdate){
            decimal Amount = 0.00;
            decimal Tax = 0.00; 
            if(SoRolePaymentRec.RecordType.DeveloperName == 'Third_Party' ){    
                for(Claim_Line_item__c ClaimLineItemRec :  SoRolePaymentRec.Claim_Line_items__r){
                    Amount += ClaimLineItemRec.Approved_Qty__c * ClaimLineItemRec.Service_Order_Line_Item__r.Kit_Price__c;
                    Tax += (ClaimLineItemRec.Approved_Qty__c * ClaimLineItemRec.Service_Order_Line_Item__r.Kit_Price__c) * (ClaimLineItemRec.Tax__c / 100);
                }
            } else if( SoRolePaymentRec.RecordType.DeveloperName == 'Customer' || SoRolePaymentRec.RecordType.DeveloperName == 'Internal') {
                for(Claim_Line_item__c ClaimLineItemRec :  SoRolePaymentRec.Claim_Line_items__r){
                    Amount += ClaimLineItemRec.Total_Variance_Amount__c;
                    Tax += ClaimLineItemRec.Total_Variance_Amount__c *(ClaimLineItemRec.Tax__c/100);
                }
}
            SoRolePaymentRec.Total_Amount__c = Amount;
            SoRolePaymentRec.Tax_Amount__c = Tax;
        }
        
        if(SoPaymentListToUpdate.Size() > 0){
            update SoPaymentListToUpdate;
        }
        
        return SoPaymentListToUpdate;
    }
    
    public static List<Customer_Owned_Unit__c> calculateDealOptionsWIPCost(Id coInvoiceId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Header__c> coInvoiceList = [SELECT Name, (SELECT CO_Line_Item__c, Service_Order_Header__c, CO_Kit_Header__c, 
                                                            CO_Line_Item__r.Deal__c, Service_Order_Header__r.Deal__c, CO_Kit_Header__r.Deal__c,
                                                            CO_Line_Item__r.Related_Option_And_Fees__c
                                                            FROM CO_Invoice_Items__r)
                                                    FROM CO_Invoice_Header__c WHERE Id =: coInvoiceId ];
        
        List<Customer_Owned_Unit__c> unitListToUpdate = new List<Customer_Owned_Unit__c>();
        if(coInvoiceList.size() == 0) { return unitListToUpdate; }                                                    
        Set<Id> dealIdSet = new Set<Id>();
        // find whether the item invoiced is a deal merch or deal service
        for(CO_Invoice_Item__c coInvoiceItem : coInvoiceList[0].CO_Invoice_Items__r) {
            if(coInvoiceItem.CO_Line_Item__c != null && coInvoiceItem.CO_Line_Item__r.Deal__c != null) { 
                dealIdSet.add(coInvoiceItem.CO_Line_Item__r.Deal__c);
            } else if(coInvoiceItem.Service_Order_Header__c != null && coInvoiceItem.Service_Order_Header__r.Deal__c != null) {
                dealIdSet.add(coInvoiceItem.Service_Order_Header__r.Deal__c);
            } else if(coInvoiceItem.CO_Kit_Header__c != null && coInvoiceItem.CO_Kit_Header__r.Deal__c != null) {
                dealIdSet.add(coInvoiceItem.CO_Kit_Header__r.Deal__c);
            }
        }
        if(dealIdSet.size() == 0) { return unitListToUpdate; }
        
        Map<Id, Decimal> skuIdToDealOptionsWIPCostMap = new Map<Id, Decimal>();
        calculateDealMerchOptionsWIPCost(dealIdSet, skuIdToDealOptionsWIPCostMap);
        calculateDealServiceOptionsWIPCost(dealIdSet, skuIdToDealOptionsWIPCostMap);
        
        if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        for(Id skuId : skuIdToDealOptionsWIPCostMap.keySet()) {
            Customer_Owned_Unit__c unitRec = new Customer_Owned_Unit__c(Id = skuId, Deal_Options_WIP__c = skuIdToDealOptionsWIPCostMap.get(skuId));
            unitListToUpdate.add(unitRec);
        }
        return unitListToUpdate;
    }
    
    // get all option and fees to find option and fees which belong to deal merch and are invoiced then add price for deal merch option and fees
    private static void calculateDealMerchOptionsWIPCost(Set<Id> dealIdSet, Map<Id, Decimal> skuIdToDealOptionsWIPCostMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Option_Fee__c> optionFeeList = [Select Status__c, Is_Install__c, Deal_Kit_Header__c, Deal_Kit_Header__r.Is_Install__c, Qty__c, Per_Item_Cost__c, Deal_Item__r.Customer_Owned_Unit__c from Option_Fee__c where Deal__c IN : dealIdSet];
        
        for(Option_Fee__c optionFeeRec: optionFeeList) {
            if(String.isNotBlank(optionFeeRec.Status__c) && optionFeeRec.Status__c.equalsIgnoreCase(Constants.FULFILLED) && 
                ((optionFeeRec.Deal_Kit_Header__c != null && !optionFeeRec.Deal_Kit_Header__r.Is_Install__c) ||
                (optionFeeRec.Deal_Kit_Header__c == null && !optionFeeRec.Is_Install__c)) && 
                String.isNotBlank(optionFeeRec.Deal_Item__r.Customer_Owned_Unit__c)) 
            {
                optionFeeRec.Per_Item_Cost__c = (optionFeeRec.Per_Item_Cost__c != null ? (optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP) : 0);
                optionFeeRec.Qty__c = (optionFeeRec.Qty__c != null ? optionFeeRec.Qty__c : 0);
                Decimal cost = (optionFeeRec.Per_Item_Cost__c * optionFeeRec.Qty__c).setScale(2, RoundingMode.HALF_UP);
                String skuId = optionFeeRec.Deal_Item__r.Customer_Owned_Unit__c;
                if(skuIdToDealOptionsWIPCostMap.containsKey(skuId)) {
                    skuIdToDealOptionsWIPCostMap.put(skuId, skuIdToDealOptionsWIPCostMap.get(skuId) + cost);
                } else {
                    skuIdToDealOptionsWIPCostMap.put(skuId, cost);
                }
            }
        }
    }
    
    // get all solis realted to deal services which are invoiced then add price for deal merch service items
    private static void calculateDealServiceOptionsWIPCost(Set<Id> dealIdSet, Map<Id, Decimal> skuIdToDealOptionsWIPCostMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Line_Item__c> soLineItemList = 
              [SELECT Kit_Price__c, Qty_Needed__c, Deal_Item__r.Customer_Owned_Unit__c FROM Service_Order_Line_Item__c 
                   WHERE Service_Order_Header__r.Deal__c IN: dealIdSet AND Service_Order_Header__r.Work_Status__c = 'Invoiced'];
                   
        for(Service_Order_Line_Item__c soliRec: soLineItemList) {
            if(String.isNotBlank(soliRec.Deal_Item__r.Customer_Owned_Unit__c)) {
                soliRec.Kit_Price__c = (soliRec.Kit_Price__c != null ? (soliRec.Kit_Price__c).setScale(2, RoundingMode.HALF_UP) : 0);
                soliRec.Qty_Needed__c = (soliRec.Qty_Needed__c != null ? soliRec.Qty_Needed__c : 0);
                Decimal cost = (soliRec.Kit_Price__c*soliRec.Qty_Needed__c).setScale(2, RoundingMode.HALF_UP);
                String skuId = soliRec.Deal_Item__r.Customer_Owned_Unit__c;
                if(skuIdToDealOptionsWIPCostMap.containsKey(soliRec.Deal_Item__r.Customer_Owned_Unit__c)) {
                    skuIdToDealOptionsWIPCostMap.put(skuId, skuIdToDealOptionsWIPCostMap.get(skuId) + cost);
                } else {
                    skuIdToDealOptionsWIPCostMap.put(skuId, cost);
                }
            }
        }
    }
    
    //function to calculate invoice cost
    @future
    public static void calculateInvoiceCost(string coInvoiceId){
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<CO_Invoice_Header__c> coInvoiceList = [SELECT Name, (SELECT CO_Line_Item__c, Service_Order_Header__c, CO_Kit_Header__c, Deal__c 
                                                            FROM CO_Invoice_Items__r)
                                                    FROM CO_Invoice_Header__c WHERE Id =: coInvoiceId ];
        if(coInvoiceList.size() == 0) { return; }
        List<Id> coliIds = new List<Id>();  
        List<Id> sohIds = new List<Id>();                                                
        List<Id> cokhIds = new List<Id>();
        List<Id> dealIds = new List<Id>();
        if(coInvoiceList.size() == 0) { return; }
        Boolean isDealInvoiced = false;
        for(CO_Invoice_Item__c coInvoiceItem : coInvoiceList[0].CO_Invoice_Items__r) {
            if(coInvoiceItem.CO_Line_Item__c != null) { 
                coliIds.add(coInvoiceItem.CO_Line_Item__c);
            } else if(coInvoiceItem.CO_Kit_Header__c != null) { 
                cokhIds.add(coInvoiceItem.CO_Kit_Header__c);
            } else if(coInvoiceItem.Service_Order_Header__c != null) {
                sohIds.add(coInvoiceItem.Service_Order_Header__c);
            } else if(coInvoiceItem.Deal__c != null) {
                isDealInvoiced = true;
                dealIds.add(coInvoiceItem.Deal__c);
            }
        }
        
        List<CO_Line_Item__c> coliList = new List<CO_Line_Item__c>();
        List<Service_Order_Line_Item__c> soLineItemList = new List<Service_Order_Line_Item__c>();
        List<Option_Fee__c> optionFeeList = new List<Option_Fee__c>();
        List<Deal_Unit_Price_Cost__c> dupcList = new List<Deal_Unit_Price_Cost__c>();
        
        // covers part and Fee for coli
        if(coliIds.size() > 0 || cokhIds.size() > 0) {
            coliList = [SELECT Item_ID__c, Part__c, Fee__c, Qty__c, Price__c, Deal__c, Adjusted_Cost_Coli__c,
                                    Fee__r.Cost_Method__c, Fee__r.Cost_Rate__c, Fee__r.Is_Include_In_Profit_Calculation__c
                             FROM CO_Line_Item__c WHERE Service_Order_Line_Item__c = null AND (Id IN: coliIds OR CO_Kit_Header__c IN: cokhIds)];
        }
                                         
        if(sohIds.size() > 0 ) {
            soLineItemList = [SELECT Labour_Code__c, Part__c, Cost__c, Fee__c, Sublet__c, Kit_Price__c, Qty_Needed__c,
                                Fee__r.Cost_Method__c, Fee__r.Cost_Rate__c, Labour_Code__r.Cost_Method__c, Labour_Code__r.Cost_Rate__c,
                                Sublet__r.Cost_Method__c, Sublet__r.Cost__c, Fee__r.Is_Include_In_Profit_Calculation__c,
                                    (select Adjusted_Cost_Coli__c from CO_Line_Items__r)  
                                    FROM Service_Order_Line_Item__c WHERE Service_Order_Header__c IN: sohIds ];
        }
        
        if(dealIds.size() > 0 ) {
            optionFeeList = [Select Qty__c, Fee__r.Cost_Method__c, Fee__r.Cost_Rate__c, Product__r.Cost__c, Product__r.Cost_Method__c, 
                                        Deal_Kit_Header__c, Fee__r.Is_Include_In_Profit_Calculation__c, 
                                        Part__c, Labour_Code__c, Price__c, Per_Item_Cost__c, Product__r.Type__c from Option_Fee__c 
                                        WHERE Deal__c IN : dealIds];
                                        
            dupcList = [Select Unit_Price_Cost__r.Total_Cost__c from Deal_Unit_Price_Cost__c where Deal_Item__r.Deal__c IN : dealIds];                  
        }
        
        Decimal totalInvoiceCost = 0;     
        for(CO_Line_Item__c coliRec : coliList) {
            if(coliRec.Part__c != null) {
                totalInvoiceCost += (coliRec.Adjusted_Cost_Coli__c != null) ? coliRec.Adjusted_Cost_Coli__c : 0 ;
            } else if(coliRec.Fee__c != null && coliRec.Fee__r.Is_Include_In_Profit_Calculation__c) {
                if(coliRec.Fee__r.Cost_Method__c == 'Fixed Cost' && coliRec.Fee__r.Cost_Rate__c != null && coliRec.Qty__c != null) {
                    totalInvoiceCost += (coliRec.Qty__c * coliRec.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
                } else if(coliRec.Fee__r.Cost_Method__c == 'Percent Retail' && coliRec.Fee__r.Cost_Rate__c != null && coliRec.Qty__c != null) {
                    totalInvoiceCost += (coliRec.Qty__c * ((coliRec.Price__c * coliRec.Fee__r.Cost_Rate__c) /100)).setScale(2, RoundingMode.HALF_UP);
                }
            }
        }
        
        for(Service_Order_Line_Item__c soliRec : soLineItemList) {
            if(soliRec.Part__c != null){
                for(CO_Line_Item__c coliRec : soliRec.CO_Line_Items__r) {
                    totalInvoiceCost += (coliRec.Adjusted_Cost_Coli__c != null) ? coliRec.Adjusted_Cost_Coli__c : 0;
                }
                
            } else if(soliRec.Fee__c != null && soliRec.Fee__r.Is_Include_In_Profit_Calculation__c) {
                if(soliRec.Fee__r.Cost_Method__c == 'Fixed Cost' && soliRec.Fee__r.Cost_Rate__c !=null && soliRec.Qty_Needed__c != null) {
                    totalInvoiceCost += (soliRec.Qty_Needed__c * soliRec.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
                } else if(soliRec.Fee__r.Cost_Method__c == 'Percent Retail'  && soliRec.Fee__r.Cost_Rate__c !=null &&  soliRec.Qty_Needed__c !=null ){
                    totalInvoiceCost += (soliRec.Qty_Needed__c * ((soliRec.Kit_Price__c *  soliRec.Fee__r.Cost_Rate__c)/100)).setScale(2, RoundingMode.HALF_UP);
                }
            
            } else if(soliRec.Labour_Code__c != null) {
                if(soliRec.Labour_Code__r.Cost_Method__c == 'Fixed Cost' && soliRec.Labour_Code__r.Cost_Rate__c != null && soliRec.Qty_Needed__c !=null){
                    totalInvoiceCost += (soliRec.Qty_Needed__c * soliRec.Labour_Code__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
                } else if(soliRec.Labour_Code__r.Cost_Method__c == 'Percent Retail' && soliRec.Labour_Code__r.Cost_Rate__c !=null && soliRec.Qty_Needed__c !=null ){
                    totalInvoiceCost += (soliRec.Qty_Needed__c * ((soliRec.Kit_Price__c *  soliRec.Labour_Code__r.Cost_Rate__c)/100)).setScale(2, RoundingMode.HALF_UP);
                }
            } else if(soliRec.Sublet__c != null ) {
                if(soliRec.Cost__c != null) {
                    totalInvoiceCost += soliRec.Cost__c;
                } else if(soliRec.Sublet__r.Cost_Method__c == 'Fixed Cost' && soliRec.Sublet__r.Cost__c != null && soliRec.Qty_Needed__c !=null){
                    totalInvoiceCost += (soliRec.Qty_Needed__c * soliRec.Sublet__r.Cost__c).setScale(2, RoundingMode.HALF_UP);
                } else if(soliRec.Sublet__r.Cost_Method__c == 'Percent Retail' && soliRec.Sublet__r.Cost__c !=null && soliRec.Qty_Needed__c !=null ){
                    totalInvoiceCost += (soliRec.Qty_Needed__c * ((soliRec.Kit_Price__c *  soliRec.Sublet__r.Cost__c)/100)).setScale(2, RoundingMode.HALF_UP);
                }
            }
        }
        
        Decimal totalDealInvoiceCost = 0;
        for(Option_Fee__c optionFeeRec : optionFeeList) {
            if(optionFeeRec.Fee__c != null && optionFeeRec.Fee__r.Is_Include_In_Profit_Calculation__c) {
                if(optionFeeRec.Deal_Kit_Header__c != null) {
                    totalDealInvoiceCost += ((optionFeeRec.Per_Item_Cost__c != null) ? (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c) : 0).setScale(2, RoundingMode.HALF_UP);
                } else {
                    if(optionFeeRec.Fee__r.Cost_Method__c == 'Fixed Cost' && optionFeeRec.Fee__r.Cost_Rate__c != null && optionFeeRec.Qty__c != null) {
                        totalDealInvoiceCost += (optionFeeRec.Qty__c * optionFeeRec.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(optionFeeRec.Fee__r.Cost_Method__c == 'Percent Retail'  && optionFeeRec.Fee__r.Cost_Rate__c != null && optionFeeRec.Qty__c != null) {
                        totalDealInvoiceCost += (optionFeeRec.Qty__c * ((optionFeeRec.Price__c * optionFeeRec.Fee__r.Cost_Rate__c)/100)).setScale(2, RoundingMode.HALF_UP);
                    }
                }
            } else if(optionFeeRec.Product__c != null ) {
                if(optionFeeRec.Product__r.Type__c == Constants.SUBLET) {
                    totalDealInvoiceCost += ((optionFeeRec.Per_Item_Cost__c != null) ? optionFeeRec.Per_Item_Cost__c : 0).setScale(2, RoundingMode.HALF_UP);
                } else {
                    if(optionFeeRec.Product__r.Cost_Method__c == 'Fixed Cost' && optionFeeRec.Product__r.Cost__c != null && optionFeeRec.Qty__c != null) {
                        totalDealInvoiceCost += (optionFeeRec.Qty__c * optionFeeRec.Product__r.Cost__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(optionFeeRec.Product__r.Cost_Method__c == 'Percent Retail'  && optionFeeRec.Product__r.Cost__c != null && optionFeeRec.Qty__c != null) {
                        totalDealInvoiceCost += (optionFeeRec.Qty__c * ((optionFeeRec.Price__c * optionFeeRec.Product__r.Cost__c)/100)).setScale(2, RoundingMode.HALF_UP);
                    }
                }
            } else if((optionFeeRec.Part__c != null || optionFeeRec.Labour_Code__c != null) && optionFeeRec.Per_Item_Cost__c != null) {
                totalDealInvoiceCost += (optionFeeRec.Qty__c * optionFeeRec.Per_Item_Cost__c).setScale(2, RoundingMode.HALF_UP);
            }
        }
        
        for(Deal_Unit_Price_Cost__c dealUnitPriceCostRec : dupcList) {
            if(dealUnitPriceCostRec.Unit_Price_Cost__r.Total_Cost__c != null) {
                totalDealInvoiceCost += dealUnitPriceCostRec.Unit_Price_Cost__r.Total_Cost__c.setScale(2, RoundingMode.HALF_UP);
            }
        }
        totalInvoiceCost += totalDealInvoiceCost;
        
        CO_Invoice_Header__c coInvoiceHeaderRec = new CO_Invoice_Header__c(Id = coInvoiceId, Is_Deal_Invoiced__c = isDealInvoiced);
        coInvoiceHeaderRec.Deal_Cost__c = totalDealInvoiceCost;
        coInvoiceHeaderRec.Invoice_Cost__c = totalInvoiceCost;
        update coInvoiceHeaderRec;
        
        List<Customer_Owned_Unit__c> unitListToUpdate = calculateDealOptionsWIPCost(coInvoiceId);
        if(unitListToUpdate.size() > 0) {
            update unitListToUpdate;
        }
        
        // Popualte Fee Price
        populateFeePriceUsedInProfitability(coInvoiceId);
    }
    
    public static void populateFeePriceUsedInProfitability(String coInvoiceId) {
        List<CO_Invoice_Header__c> coInvoiceHeaderList = setFeePriceUsedInProfitability(coInvoiceId);
        if(coInvoiceHeaderList != null) {
            update coInvoiceHeaderList;
        }
    }
    
    private static List<CO_Invoice_Header__c> setFeePriceUsedInProfitability(String coInvoiceId) {
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<CO_Invoice_Header__c> coInvoiceList = [SELECT Name, (SELECT CO_Line_Item__c, Service_Order_Header__c, CO_Kit_Header__c, Deal__c 
                                                            FROM CO_Invoice_Items__r)
                                                    FROM CO_Invoice_Header__c WHERE Id =: coInvoiceId ];
        if(coInvoiceList.size() == 0) { return null; }
        List<Id> coliIds = new List<Id>();  
        List<Id> sohIds = new List<Id>();                                                
        List<Id> cokhIds = new List<Id>();
        List<Id> dealIds = new List<Id>();
        Boolean isDealInvoiced = false;
        for(CO_Invoice_Item__c coInvoiceItem : coInvoiceList[0].CO_Invoice_Items__r) {
            if(coInvoiceItem.CO_Line_Item__c != null) { 
                coliIds.add(coInvoiceItem.CO_Line_Item__c);
            } else if(coInvoiceItem.CO_Kit_Header__c != null) { 
                cokhIds.add(coInvoiceItem.CO_Kit_Header__c);
            } else if(coInvoiceItem.Service_Order_Header__c != null) {
                sohIds.add(coInvoiceItem.Service_Order_Header__c);
            } else if(coInvoiceItem.Deal__c != null) {
                dealIds.add(coInvoiceItem.Deal__c);
            }
        }
        
        List<CO_Line_Item__c> coliList = new List<CO_Line_Item__c>();
        List<Service_Order_Line_Item__c> soLineItemList = new List<Service_Order_Line_Item__c>();
        List<Option_Fee__c> optionFeeList = new List<Option_Fee__c>();
        
        // covers part and Fee for coli
        if(coliIds.size() > 0 || cokhIds.size() > 0) {
            coliList = [SELECT Fee__c, Qty__c, Qty_Committed__c, Price__c, Deal__c, Price_When_Tax_Included__c, 
                                Fee__r.Is_Include_In_Profit_Calculation__c
                             FROM CO_Line_Item__c WHERE Service_Order_Line_Item__c = null AND (Id IN: coliIds OR CO_Kit_Header__c IN :cokhIds) AND Fee__c != null AND Fee__r.Is_Include_In_Profit_Calculation__c = false];
        }
                                         
        if(sohIds.size() > 0 ) {
           soLineItemList = [SELECT Qty_Needed__c, Kit_Price__c, Fee__c, Part__c, Actual_Retail_Price__c, Price_When_Tax_Included__c,
                                Fee__r.Is_Include_In_Profit_Calculation__c
                                FROM Service_Order_Line_Item__c WHERE Service_Order_Header__c IN: sohIds AND Fee__c != null AND Fee__r.Is_Include_In_Profit_Calculation__c = false];
        }
        
        if(dealIds.size() > 0 ) {
            optionFeeList = [Select Qty__c, Price__c, Fee__c, Price_When_Tax_Included__c, Fee__r.Is_Include_In_Profit_Calculation__c
                                    FROM Option_Fee__c WHERE Deal__c IN : dealIds AND Fee__c != null AND Fee__r.Is_Include_In_Profit_Calculation__c = false];
        }
        
        Decimal feeTotal = 0;
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();     
        for(CO_Line_Item__c coliRec : coliList) {
            feeTotal += (coliRec.Qty__c * coliRec.Price__c).setScale(2, RoundingMode.HALF_UP);
        }
        
        for(Service_Order_Line_Item__c soliRec : soLineItemList) {
            feeTotal += (soliRec.Qty_Needed__c * soliRec.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
        }
                    
        for(Option_Fee__c optionFeeRec : optionFeeList) {
            feeTotal += (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
        }
        coInvoiceList[0].Fee_Total_Excluded_In_Profitability__c = feeTotal.setScale(2, RoundingMode.HALF_UP);
        return coInvoiceList;
    }
    
    public static List<Unit_Price_Cost__c> createPriceAndCostLineItem(String unitId, List<Service_Order_Line_Item__c> soliItems, String InvoiceId){
        List<Unit_Price_Cost__c> unitPriceAndCostList = new List<Unit_Price_Cost__c>();
        Unit_Price_Cost__c unitPriceAndCost;
        for(Service_Order_Line_Item__c soli : soliItems) {
            unitPriceAndCost = new Unit_Price_Cost__c();
            unitPriceAndCost.Type__c = 'Dealer';
            unitPriceAndCost.CO_Invoice_Header__c = InvoiceId;
            
            String itemCode = (soli.Item_Code__c != null) ? soli.Item_Code__c : '';
            String itemDescription = (soli.Item_Description__c != null) ? soli.Item_Description__c : '';
            unitPriceAndCost.Item_Description__c = itemCode + ' - ' + itemDescription;
            
            /*if(soli.Fee__c != null){
                unitPriceAndCost.Item_Description__c = soli.Fee__r.Description__c;
            }else if(soli.Part__c != null){
                unitPriceAndCost.Item_Description__c = soli.Part__r.Description__c;
            }else if(soli.Labour_Code__c != null){
                unitPriceAndCost.Item_Description__c = soli.Labour_Code__r.Description__c;
            }*/
            unitPriceAndCost.Qty__c = soli.Qty_Needed__c;
            unitPriceAndCost.Price__c = soli.Retail_Price__c;
            unitPriceAndCost.Total_Price__c = (soli.Qty_Needed__c != null && soli.Retail_Price__c != null) ? (soli.Qty_Needed__c * soli.Retail_Price__c) : 0;
            unitPriceAndCost.Cost__c = soli.Kit_Price__c;
            unitPriceAndCost.Total_Cost__c = (soli.Qty_Needed__c != null && soli.Kit_Price__c != null) ? (soli.Qty_Needed__c * soli.Kit_Price__c) : 0;
            unitPriceAndCost.Service_Order_Line_Item__c = soli.id;
            unitPriceAndCost.Customer_Owned_Unit__c = unitId;
            unitPriceAndCostList.add(unitPriceAndCost);
        }
        return unitPriceAndCostList;
    }
    
    
    /* NIDHI : DEAL RELATED METHODS */
    @RemoteAction
    global static String createDeal(String coHeaderId) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        createDealHeader(coHeaderId);
        
        return getDealDetails(BPUtility.getEncodedString(coHeaderId), null);
    }
    
    public static void createDealHeader(String coHeaderId) {
        if(AccessControl.ifObjectFieldIsCreateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        Deal__c dealRec = new Deal__c(CO_Header__c = coHeaderId, Status__c = Constants.QUOTATION, Type__c = Constants.CASH_DEAL);
        dealRec.Unit_Status__c = Constants.TEMPORARY;
        insert dealRec;
        
		Deal_Item__c dealItemObj = new Deal_Item__c(Deal__c = dealRec.Id);        
        DealService.saveTemporaryUnit(dealRec.Id, system.JSON.serialize(dealItemObj));
        
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coHeaderList = [Select CO_Type__c, Selling_Group__c from CO_Header__c where Id = :coHeaderId];
        if(coHeaderList.size() > 0 && coHeaderList[0].Selling_Group__c == 'Unit Deal') {
            COFormService.insertDefaultCOForms(coHeaderId, dealRec.Id);
        }
    }
    
    /**
     * Name: getDealDetails
     * Desc: Method which gives deal rec using co header id
     * @param:  (1) coHeaderId - String - CO header id
     * @return: String - JSON String of deal
    **/
    @RemoteAction
    global static String getDealDetails(String objectId, String gridName) {
        objectId = BPUtility.getDecodedString(objectId);
        gridName = BPUtility.getDecodedString(gridName);
        
        if(AccessControl.ifObjectFieldIsAccessible('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        if(String.isBlank(objectId)){
            return BPUtility.getEncodedString('{}');
        }
        List<Deal__c> dealList = new List<Deal__c>();
        
        String objectName = (Id.valueOf(objectId)).getSObjectType().getDescribe().getName();
        if(objectName == Constants.NAMESPACE + 'CO_Header__c') {
            dealList = SOQLUtil.getDealDetails(new Map<String, String>{'CO_Header__c' => objectId});
        } else if(objectName == Constants.NAMESPACE + 'Deal__c') {
            dealList = SOQLUtil.getDealDetails(new Map<String, String>{'Id' => objectId});
        } 
        
        if(dealList.size() == 0) {
            return BPUtility.getEncodedString('{}');
        } 
        
        String jsonString;
        if(gridName == null) {
        Set<Id> dealItemIds = new Set<Id>();
        
        for(Deal_Item__c dealItemRec : dealList[0].Deal_Items__r) {
            dealItemIds.add(dealItemRec.Id);
        }
        List<Deal_Item__c> dealItemList = SOQLUtil.getDealItemDetails(new Set<Id>(dealItemIds));
        
            Map<Id, List<Deal_Kit_Header__c>> dealItemIdToDKHListMap = new Map<Id, List<Deal_Kit_Header__c>>();
            List<Deal_Kit_Header__c> dealKitHeaderList = SOQLUtil.getDealKitHeaderDetailsByDealItemId(new Set<Id>(dealItemIds));
            for(Deal_Kit_Header__c dealKitHeaderRec : dealKitHeaderList) {
                if(dealItemIdToDKHListMap.containsKey(dealKitHeaderRec.Deal_Item__c)) {
                    List<Deal_Kit_Header__c> dealKitHeaders = dealItemIdToDKHListMap.get(dealKitHeaderRec.Deal_Item__c);
                    dealKitHeaders.add(dealKitHeaderRec);
                    dealItemIdToDKHListMap.put(dealKitHeaderRec.Deal_Item__c, dealKitHeaders);
                } else {
                    dealItemIdToDKHListMap.put(dealKitHeaderRec.Deal_Item__c, new List<Deal_Kit_Header__c>{dealKitHeaderRec});
                }
            }
            
            List<CO_Line_Item__c> coliList = SOQLUtil.getCOLineItemByFieldValue(new Map<String, String>{'Deal__c' => dealList[0].Id, 'CO_Kit_Header__c' => null
                                                                                        , 'Service_Order_Line_Item__c' => null});
            List<CO_Kit_Header__c> cokhList = SOQLUtil.getCOKHByFieldValue(new Map<String, String>{'Deal__c' => dealList[0].Id});
            
            List<Vendor_Order_Line_Item__c> specialOrders = SOQLUtil.getSpecialOrderByCOHeaderId(dealList[0].CO_Header__c);
            List<Deal_Unresolved_Fulfillment__c> dealUnresolvedFulfillmentList = SOQLUtil.getDealUnresolvedFulfillment(new Map<String, String>{'Deal__c' => dealList[0].Id});
            List<Profile> ProfilesList = [Select Id from Profile where Name IN: PROFILE_NAME_LIST]; // Added by richa #1972
            List<User> userList = [Select Name, Email from User where isActive = true and ProfileId IN :ProfilesList]; // and ProfileId IN :ProfilesList Added by richa #1972
            List<Deal_Finance__c> dealFinanceList = SOQLUtil.getDealFinanceRecord(new Map<String, String>{'Deal__c' => dealList[0].Id});
            if(!(dealFinanceList.size() > 0)) {
                dealFinanceList.add(new Deal_Finance__c());
            }
            DealWrapper dealWrapperObj = new DealWrapper(dealList[0], dealItemList, coliList, cokhList, specialOrders, userList, dealUnresolvedFulfillmentList, dealFinanceList[0], dealItemIdToDKHListMap);
            jsonString = System.JSON.serialize(dealWrapperObj);
        } else if(gridName.contains('dealInfo')) {
            DealWrapper.DealInfoWrapper dealWrapperInfoObj = new DealWrapper.DealInfoWrapper(dealList[0]);
            jsonString = System.JSON.serialize(dealWrapperInfoObj);
            
        } else if(gridName.contains('dealMerchandise')) {
            List<CO_Line_Item__c> coliList = SOQLUtil.getCOLineItemByFieldValue(new Map<String, String>{'Deal__c' => dealList[0].Id, 'CO_Kit_Header__c' => null
                                                                                        , 'Service_Order_Line_Item__c' => null});
            List<CO_Kit_Header__c> cokhList = SOQLUtil.getCOKHByFieldValue(new Map<String, String>{'Deal__c' => dealList[0].Id});
             
            List<Vendor_Order_Line_Item__c> specialOrders = SOQLUtil.getSpecialOrderByCOHeaderId(dealList[0].CO_Header__c);
            DealWrapper.DealFulfillmentSectionWrapper DealFulfillmentSectionObj = new DealWrapper.DealFulfillmentSectionWrapper(coliList, cokhList, specialOrders); 
            jsonString = System.JSON.serialize(DealFulfillmentSectionObj);
            
        }  else if(gridName.contains('dealUnresolvedFulfillmentAndDealFulfillment')) {
            List<CO_Line_Item__c> coliList = SOQLUtil.getCOLineItemByFieldValue(new Map<String, String>{'Deal__c' => dealList[0].Id, 'CO_Kit_Header__c' => null
                                                                                        , 'Service_Order_Line_Item__c' => null});
            List<CO_Kit_Header__c> cokhList = SOQLUtil.getCOKHByFieldValue(new Map<String, String>{'Deal__c' => dealList[0].Id});
            
            List<Vendor_Order_Line_Item__c> specialOrders = SOQLUtil.getSpecialOrderByCOHeaderId(dealList[0].CO_Header__c);
            List<Deal_Unresolved_Fulfillment__c> dealUnresolvedFulfillmentList = SOQLUtil.getDealUnresolvedFulfillment(new Map<String, String>{'Deal__c' => dealList[0].Id});
            DealWrapper DealWrapperObj = new DealWrapper(dealUnresolvedFulfillmentList, coliList, cokhList, specialOrders); 
            jsonString = System.JSON.serialize(DealWrapperObj);
            
        } else if(gridName.contains('dealUnresolvedFulfillmentSection')) {
            List<Deal_Unresolved_Fulfillment__c> dealUnresolvedFulfillmentList = SOQLUtil.getDealUnresolvedFulfillment(new Map<String, String>{'Deal__c' => dealList[0].Id});
            List<DealWrapper.DealUnresolvedFulfillmentWrapper> DealUnresolvedFulfillmentWrapperList = new List<DealWrapper.DealUnresolvedFulfillmentWrapper>();
            if((dealUnresolvedFulfillmentList.size() == 0) && (error != null)) {
                if(error.ResponseCode == '300') {
                jsonString = System.JSON.serialize(new DealWrapper.DealUnresolvedFulfillmentWrapper());
                } else if((error.ResponseCode == '200') && (objectName == Constants.NAMESPACE + 'CO_Header__c')) {
                    return getSOHeaderDetails(BPUtility.getEncodedString(objectId), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder'));
                }
            }
            for(Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec : dealUnresolvedFulfillmentList){
                DealUnresolvedFulfillmentWrapperList.add(new DealWrapper.DealUnresolvedFulfillmentWrapper(dealUnresolvedFulfillmentRec));
            jsonString = System.JSON.serialize(DealUnresolvedFulfillmentWrapperList);
            }
        } else if(gridName.contains('dealFinanceSection')) {
            List<Deal_Finance__c> dealFinanceList = SOQLUtil.getDealFinanceRecord(new Map<String, String>{'Deal__c' => dealList[0].Id});
            if(!(dealFinanceList.size() > 0)) {
                dealFinanceList.add(new Deal_Finance__c());
            }
            DealWrapper.DealFinanceWrapper dealFinanceSectionObj = new DealWrapper.DealFinanceWrapper(dealFinanceList[0]);
            jsonString = System.JSON.serialize(dealFinanceSectionObj);
        } else if(gridName.contains('dealFAndIProductSection')) {
            List<F_I_Product__c> dealFAndIProductList = SOQLUtil.getDealFAndIProductRecord(new Map<String, String>{'Deal__c' => dealList[0].Id});
            if(dealFAndIProductList.size() == 0) {
                dealFAndIProductList.add(new F_I_Product__c());
            }
            
            DealWrapper.FIProductWrapper dealFAndISectionObj = new DealWrapper.FIProductWrapper(dealFAndIProductList[dealFAndIProductList.size() -1]);
            jsonString = System.JSON.serialize(dealFAndISectionObj);
        }
        
        return BPUtility.getEncodedString(jsonString);
    }
    
    /**
     * Name: getDealCoDeposits
     * Desc: Method which gives deal deposits Item
     * @param:  (1) deald - String - deal item id
     * @return: String - JSON String of deal deposits list
    **/
    @RemoteAction
    global static String getDealCoDeposits(String DealId){
        DealId = BPUtility.getDecodedString(DealId);
        List<CO_Deposit__c> CoDepositList =  SoqlUtil.getDealDeposits(new Map<String, String>{'Deal__c' => DealId});
        List<CODeposit> DealDepositList = new List<CODeposit>();  
        CoDepositList = COHeaderWrapper.sortCODeposit(CoDepositList);// added by kajal 17th april, 2017
        for(CO_Deposit__c coDepositRec : CoDepositList){
            DealDepositList.add(new CODeposit(coDepositRec));
        }
        String jsonString = System.JSON.serialize(DealDepositList);
        return BPUtility.getEncodedString(jsonString);
    }
    
    /** 11/24 by subhrant
     * Name: getDealCoDeposits
     * Desc: Method which gives deal deposits Item
     * @param:  (1) deald - String - deal item id
     * @return: String - JSON String of deal deposits list
    **/
    @RemoteAction
    global static String saveCODealDeposit(String jsonString,String DealId){
        jsonString = BPUtility.getDecodedString(jsonString);
        DealId = BPUtility.getDecodedString(DealId);
        try{
            List<CODeposit> coDepositObjList = CODeposit.parse(jsonString);
            List<CO_Deposit__c> coDepositListToUpdate = new List<CO_Deposit__c>();
            Decimal dealDepositTotal = 0;
            for(CODeposit coDepositObj : coDepositObjList) {
                CO_Deposit__c coDepositRec = new CO_Deposit__c();
                coDepositRec.Amount__c = coDepositObj.Amount ;
                coDepositRec.Payment_Method__c = coDepositObj.PaymentMethod ;
                coDepositRec.CO_Header__c = coDepositObj.coHeaderId;
                coDepositRec.Deal__c = coDepositObj.Deal;
                coDepositRec.Reverse_Link__c = coDepositObj.ReverseLink; 
                if( coDepositRec.Deal__c != null){
                    coDepositRec.Recorded_From__c = 'Customer';
                    dealDepositTotal += (coDepositObj.Amount != null) ? coDepositObj.Amount : 0;
                }  
                if(coDepositObj.CODepositId != null) {
                    coDepositRec.Id = coDepositObj.CODepositId ;
                }
                coDepositListToUpdate.add(coDepositRec);
            }
            if(coDepositListToUpdate.size() > 0) {
                if(AccessControl.ifObjectFieldIsCreateable('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                upsert coDepositListToUpdate;
                
                if(String.isNotBlank(coDepositListToUpdate[0].Reverse_Link__c)) {
                    CO_Deposit__c coDepositRec = new CO_Deposit__c(Id = coDepositListToUpdate[0].Reverse_Link__c);
                    coDepositRec.Reverse_Link__c = coDepositListToUpdate[0].Id;
                    update coDepositRec;
                }
                if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Deal__c> dealList = [Select Total_Deposit_And_Payment__c from Deal__c where Id = :DealId];
                if(dealList.size() > 0) {
                    if(dealList[0].Total_Deposit_And_Payment__c != null) {
                        dealList[0].Total_Deposit_And_Payment__c += dealDepositTotal;
                    } else {
                        dealList[0].Total_Deposit_And_Payment__c = dealDepositTotal;
            }
                    if(AccessControl.ifObjectFieldIsUpdateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update dealList[0];
                }
            }
            String coHeaderId;
            if(coDepositObjList.size() > 0) {
                coHeaderId = coDepositObjList[0].COHeaderId;
            } else {
                COHeaderId = null;
            }          
            return getDealCoDeposits(BPUtility.getEncodedString(DealId));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
     * Name: getDealItemDetails
     * Desc: Method which gives deal item rec using deal item id
     * @param:  (1) dealItemId - String - deal item id
     * @return: String - JSON String of deal item
    **/
    public static String getDealItemDetails(String dealItemId) {
        List<Deal_Item__c> dealItemList = SOQLUtil.getDealItemDetails(new Set<Id>{dealItemId});
        /*
        DealWrapper.UnitSectionWrapper unitSectionObj = new DealWrapper.UnitSectionWrapper(new Deal_Item__c());
        if(dealItemList.size() > 0) {
            unitSectionObj = new DealWrapper.UnitSectionWrapper(dealItemList[0]);
        }
        return BPUtility.getEncodedString(System.JSON.serialize(unitSectionObj));
        */
        //START: Added by Nidhi - 26-11-2016
        if(dealItemList.size() > 0) {
            if(String.isNotBlank(dealItemList[0].Type__c) && dealItemList[0].Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
                DealItem tradeInObj = new DealItem(dealItemList[0]);
                return BPUtility.getEncodedString(System.JSON.serialize(tradeInObj));
            } else {
                Map<Id, List<Deal_Kit_Header__c>> dealItemIdToDKHListMap = new Map<Id, List<Deal_Kit_Header__c>>();
                List<Deal_Kit_Header__c> dealKitHeaderList = SOQLUtil.getDealKitHeaderDetailsByDealItemId(new Set<Id>{dealItemId});
                
                DealWrapper.UnitSectionWrapper unitSectionObj = new DealWrapper.UnitSectionWrapper(dealItemList[0], dealKitHeaderList);
                
                return BPUtility.getEncodedString(System.JSON.serialize(unitSectionObj));
            }
        }
        return BPUtility.getEncodedString('{}');
        //END: Added by Nidhi - 26-11-2016
    }
    
    /**
     * Name: saveDealInfoDetails
     * Desc: Method which gives provide deal rec using co header id
     * @param:  (1) dealId - String - deal id
     * @param:  (2) json - String - deal info json
     * @return: String - JSON String of deal
    **/
    @RemoteAction
    global static String saveDealInfoDetails(String coHeaderId, String dealId, String json) {
        dealId = BPUtility.getDecodedString(dealId);
        json = BPUtility.getDecodedString(json);
        
        if(String.isBlank(dealId)) {
            return BPUtility.getEncodedString('{}');
        }
        DealWrapper.DealInfoWrapper dealObj = (DealWrapper.DealInfoWrapper) System.JSON.deserialize(json, DealWrapper.DealInfoWrapper.class);
        Deal__c dealRec = setDealValues(dealObj);
        dealRec.Id = dealId;
        if(AccessControl.ifObjectFieldIsUpdateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update dealRec;
        return getDealDetails(BPUtility.getEncodedString(dealId), BPUtility.getEncodedString('dealInfo'));
    }
    
    /**
     * Name: updateDealStatus
     * Desc: Method to update deal status
     * @param:  (1) dealId - String - deal id
     * @param:  (2) dealStatus - String - deal status
     * @return: String - JSON String of deal info section
    **/
    @RemoteAction
    global static String updateDealStatus(String dealId, String dealStatus) {
        dealId = BPUtility.getDecodedString(dealId);
        dealStatus = BPUtility.getDecodedString(dealStatus);
        
        if(String.isBlank(dealId)) {
            return BPUtility.getEncodedString('{}');
        }
        
        List<SObject> sObjectListToUpdate = new List<SObject>();
        
        Deal__c dealRec = new Deal__c(Id = dealId, Status__c = dealStatus);
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Item__c> dealItemList = [Select Deal__r.Status__c, Deal__r.Is_Deal_Fulfilled__c, Unit_Make__c, Customer_Owned_unit__c, Customer_Owned_unit__r.Status__c, Deal__r.CO_Header__c, 
            (Select Id from Options_Fees__r where (Part__c != null OR Labour_Code__c != null OR (Product__c != null AND Product__r.Type__c = 'Sublet'))), (Select Id from Deal_Kit_Headers__r) from Deal_Item__c where 
            Deal__c = :dealId AND Type__c = :Constants.DEAL_ITEM_TYPE_UNIT];
        
        String skuStatus = (dealStatus == 'Quotation') ? 'Available' : 'Reserved';
        dealRec.Unit_Status__c = (dealStatus == 'Quotation') ? getDealWithUpdatedStatus(dealId, dealItemList).Unit_Status__c : Constants.COMMITTED;
        
        if(dealStatus == 'Quotation' || (dealItemList[0].Deal__r.Status__c == 'Quotation' && (dealStatus == 'In progress' || dealStatus == 'Approved'))) {
            for(Deal_Item__c dealItemRec : dealItemList) {
                if(dealItemRec.Customer_Owned_unit__c != null) {
                    //changes made for on ordered units 
                    Customer_Owned_unit__c unitRec  = new Customer_Owned_unit__c(Id = dealItemRec.Customer_Owned_unit__c);
                    if(dealItemRec.Customer_Owned_unit__r.Status__c == Constants.ON_ORDER_STATUS) {
                        unitRec.Status__c = Constants.ON_ORDER_STATUS;
                    } else {
                        unitRec.Status__c = skuStatus;
                    }
                    if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    sObjectListToUpdate.add(unitRec);
                }
            }
        }
        
        if((dealStatus == 'Quotation' || dealStatus == 'In progress') && dealItemList[0].Deal__r.Status__c == 'Approved') {
            List<CO_Invoice_Item__c> invItemList = [Select Id, isActive__c, Is_Invoiceable__c from CO_Invoice_Item__c where Deal__c =: dealId];
            if(invItemList.size() > 0) {
                for(CO_Invoice_Item__c invItemRec : invItemList) {
                    //invItemRec.isActive__c = false;
                    invItemRec.Is_Invoiceable__c = false;
                }
                sObjectListToUpdate.addAll((List<SObject>) invItemList);
            }
        }
        
        sObjectListToUpdate.add(dealRec);
        if(AccessControl.ifObjectFieldIsUpdateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update sObjectListToUpdate;
        
        if(dealStatus == 'Approved') {
            List<CO_Invoice_Header__c> activeCOInvHeaderList = [Select Id, (Select Id, isActive__c, Is_Invoiceable__c from CO_Invoice_Items__r where Deal__c =: dealId) 
                    from CO_Invoice_Header__c where CO_Header__c =: dealItemList[0].Deal__r.CO_Header__c AND Invoice_Status__c = 'Active'];  
                
            if(!(activeCOInvHeaderList.size() > 0 && activeCOInvHeaderList[0].CO_Invoice_Items__r.size() > 0 && activeCOInvHeaderList[0].CO_Invoice_Items__r[0].Is_Invoiceable__c && 
                activeCOInvHeaderList[0].CO_Invoice_Items__r[0].isActive__c)) {
                
                CO_Invoice_Item__c invItem = new CO_Invoice_Item__c(isActive__c = true, Is_Invoiceable__c = true, Deal__c = dealId);
                        
                if(activeCOInvHeaderList.size() == 0) {
                    CO_Invoice_Header__c invHeaderRec = new CO_Invoice_Header__c(CO_Header__c = dealItemList[0].Deal__r.CO_Header__c, Invoice_Status__c = 'Active');
                    if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                    insert invHeaderRec;
                    invItem.CO_Invoice_Header__c = invHeaderRec.Id;
                } else {
                    invItem.CO_Invoice_Header__c = activeCOInvHeaderList[0].Id;
                    if(activeCOInvHeaderList[0].CO_Invoice_Items__r.size() > 0) {
                        invItem.Id = activeCOInvHeaderList[0].CO_Invoice_Items__r[0].Id;
                    }
                }
                Map<String, Boolean> optionNameToOptionValueMap = isDealInvoiceable(dealId);
                invItem.Is_Invoiceable__c = optionNameToOptionValueMap.get('Invoiceable');
                invItem.isActive__c = optionNameToOptionValueMap.get('Active');
                upsert invItem;
            }
        }
        return getDealDetails(BPUtility.getEncodedString(dealId), BPUtility.getEncodedString('dealInfo'));
    }
    
    public static Map<String, Boolean> isDealInvoiceable(String dealId) {
        Map<String, Boolean> optionNameToOptionValueMap = new Map<String, Boolean>{'Invoiceable' => false, 'Active' => false};
        List<Deal__c> dealList = [SELECT Status__c, Is_Deal_Fulfilled__c, Type__c, (SELECT Id, Status__c from Deal_Finances__r), 
                                        (SELECT Id from CO_Invoice_Items__r), (SELECT Id from Deal_Unresolved_Fulfillments__r WHERE Is_Resolved__c = false)
                                        FROM Deal__c WHERE Id =: dealId];    
        Boolean isInvoiceable = false;
        if(dealList.size() > 0 && dealList[0].Status__c == 'Approved' && (dealList[0].Type__c == 'Cash Deal' || (dealList[0].Deal_Finances__r.size() > 0 && dealList[0].Deal_Finances__r[0].Status__c == 'Approved'))) {
            // Check for commit install options
	        List<Deal_Item__c> dealItemList = [SELECT Option_And_Fee_Status__c, (SELECT Id from Options_Fees__r WHERE (Part__c != null OR 
	                                                            Labour_Code__c != null OR (Product__c != null AND Product__r.Type__c = 'Sublet'))), 
	                                                      (SELECT Id from Deal_Kit_Headers__r)
	                                            FROM Deal_Item__c 
	                                            WHERE Deal__c =: dealId AND Type__c =: Constants.DEAL_ITEM_TYPE_UNIT];
	        
	        if(dealItemList.size() > 0) {
	            if(isDealInstallOptionExist(dealItemList)) {
		            if(String.isNotBlank(dealItemList[0].Option_And_Fee_Status__c) && dealItemList[0].Option_And_Fee_Status__c != 'Uncommitted') {
		                if(!isUnresolvedFulfillmentExist(dealList)) {
			                optionNameToOptionValueMap.put('Invoiceable', true);
			                if(dealList[0].Is_Deal_Fulfilled__c) {
			                    optionNameToOptionValueMap.put('Active', true);
			                }
		                }
		            }
	            } else {
	                optionNameToOptionValueMap.put('Invoiceable', true);
	                optionNameToOptionValueMap.put('Active', true);
	            }
	        }
        }
        return optionNameToOptionValueMap;
    }
    
    /*public static Boolean isDealInvoiceable(String dealId, List<Deal_Item__c> dealItemList) {
        List<Deal__c> dealList = [Select Id, Status__c, Is_Deal_Fulfilled__c, Type__c, (Select Id, Status__c from Deal_Finances__r), (Select Id from CO_Invoice_Items__r) from Deal__c where Id =: dealId];     
        if(dealList.size() > 0 && dealList[0].Status__c == 'Approved' && (dealList[0].Type__c == 'Cash Deal' || (dealList[0].Deal_Finances__r.size() > 0 && dealList[0].Deal_Finances__r[0].Status__c == 'Approved'))) {
            if(dealList[0].Is_Deal_Fulfilled__c) {
                return true;
            } else {
                if(dealItemList == null) {
                    dealItemList = [Select Id, (Select Id from Options_Fees__r where (Part__c != null OR Labour_Code__c != null OR (Product__c != null AND Product__r.Type__c = 'Sublet'))), (Select Id from Deal_Kit_Headers__r) from Deal_Item__c where 
                    Deal__c = :dealId AND Type__c = :Constants.DEAL_ITEM_TYPE_UNIT];
                }
                if(!isDealInstallOptionExist(dealItemList)) {
                    return true;
                }
            }
        }
        return false;
    }*/
    
    private static Boolean isDealInstallOptionExist(List<Deal_Item__c> dealItemList) {
        Boolean isDealOptionExist = false;
        for(Deal_Item__c dealItemRec : dealItemList) {
            if(dealItemRec.Deal_Kit_Headers__r.size() > 0 || dealItemRec.Options_Fees__r.size() > 0) {
                isDealOptionExist = true;
                break;
            }
        }
        return isDealOptionExist;
    }
    
    private static Boolean isUnresolvedFulfillmentExist(List<Deal__c> dealList) {
        Boolean isUnresolvedFulfillmentExist = false;
        for(Deal__c dealRec : dealList) {
            if(dealRec.Deal_Unresolved_Fulfillments__r.size() > 0) {
                isUnresolvedFulfillmentExist = true;
                break;
            }
        }
        return isUnresolvedFulfillmentExist;
    }
    
    /**
     * Name: setDealValues
     * Desc: Method which convert DealInfoWrapper obj value into Deal__c object rec
     * @param:  (1) dealObj - DealWrapper.DealInfoWrapper - Deal Info wrapper obj
     * @return: Deal__c - Deal object
    **/
    private static Deal__c setDealValues(DealWrapper.DealInfoWrapper dealObj) {
        Deal__c dealRec = new Deal__c();
        dealRec.Id = dealObj.Id;
        dealRec.Status__c = dealObj.DealStatus;
        dealRec.Type__c = dealObj.DealType;
        dealRec.Delivery_Date__c = String.isNotBlank(dealObj.DeliveryDate) ? Date.parse(dealObj.DeliveryDate) : null;
        dealRec.Down_Payment__c = dealObj.DownPayment;
        dealRec.Total__c = dealObj.Total;
        dealRec.CO_Header__c = dealObj.CoHeaderId;
        dealRec.Deal_Commission__c = dealObj.DealCommission;
        dealRec.Salesperson__c= dealObj.SalespersonId;
        return dealRec;
    }
    
    /**
     * Name: saveTemporaryUnit
     * Desc: Method which saves temporary unit deatils
     * @param:  (1) dealId - String - Deal id
     * @param:  (2) jSONString - String - Deal item in json form
     * @return: String - JSON String of deal item
    **/
    @RemoteAction
    global static String saveTemporaryUnit(String dealId, String jSONString) {
        dealId = BPUtility.getDecodedString(dealId); 
        jSONString = BPUtility.getDecodedString(jSONString);   
        
        DealService.saveTemporaryUnit(dealId, jSONString);
        return getDealDetails(BPUtility.getEncodedString(dealId), null); 
    }
    
    /**
     * Name: setDealItemValues
     * Desc: Method which convert DealItem wrapper obj value into Deal_Item__c customer object rec
     * @param:  (1) dealItemObj - DealItem - Deal Item wrapper obj
     * @param:  (2) dealId - String - Deal Id
     * @return: Deal_Item__c - Deal Item object
    **/
    public static Deal_Item__c setDealItemValues(DealItem dealItemObj, String dealId) {
        Deal_Item__c dealItemRec = new Deal_Item__c(); 
        dealItemRec.Id = dealItemObj.Id;
        dealItemRec.Customer_Owned_Unit__c = dealItemObj.UnitId;
        dealItemRec.Deal__c = dealId;
        dealItemRec.Type__c = dealItemObj.Type;
        if(String.isNotBlank(dealItemObj.Type) && dealItemObj.Type == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
            dealItemRec.Agreed_Value__c = dealItemObj.AgreedValue;
            if(GeneralConfiguration.getTaxIncludingPricing() || !GeneralConfiguration.isTradeTaxCreditCanNotExceedUnitTax()) {
                dealItemRec.Agreed_Value_Taxable_Amount__c = dealItemRec.Agreed_Value__c;
            }
            dealItemRec.Actual_Cash_Value__c = dealItemObj.ActualCashValue;
            dealItemRec.Appraisal_Method__c = dealItemObj.AppraisalMethod;
            dealItemRec.Appraisal_Notes__c = dealItemObj.AppraisalNotes;
            dealItemRec.Appraisal_Status__c = String.isBlank(dealItemObj.Id) ? Constants.APPRAISAL_STATUS_PENDING_APPRAISAL :
                                                            dealItemObj.AppraisalStatus;
            dealItemRec.Approved_By__c = dealItemObj.ApprovedBy;
            dealItemRec.Lien_Payout__c = dealItemObj.LienPayout;
            dealItemRec.Finance_Company__c = dealItemObj.FinanceCompanyId;
        } else if(String.isNotBlank(dealItemObj.Type) && dealItemObj.Type == Constants.DEAL_ITEM_TYPE_UNIT){
            dealItemRec.Unit_Make__c = dealItemObj.Make;
            dealItemRec.Unit_Model__c = dealItemObj.Model;
            dealItemRec.Sub_Model__c = dealItemObj.SubModel;
            dealItemRec.Year__c = dealItemObj.Year;
            dealItemRec.Colour__c = dealItemObj.ExteriorColour;
            dealItemRec.Option_And_Fee_Status__c = Constants.UNCOMIITTED;
        }
        return dealItemRec;
    }
    
    /**
     * Name: addUnitToDeal
     * Desc: Method that add unit to deal as deal item
     * @param:  (1) dealItemId - String - Deal Item Id
     * @param:  (2) unitId - String - Unit Id
     * @return: String - Unit details
    **/
    global static String addUnitToDeal(String dealItemId, String unitId) {
        // Not in used
        return null;
    }
    
    @RemoteAction
    global static String addUnitToDeal(String dealItemId, String unitId, String dealId) {
        if(AccessControl.ifObjectFieldIsCreateable('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectIsDeletable('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        unitId = BPUtility.getDecodedString(unitId);
        dealItemId = BPUtility.getDecodedString(dealItemId);
        dealId = BPUtility.getDecodedString(dealId);   
        List<Customer_Owned_Unit__c> unitListToUpdate = new List<Customer_Owned_Unit__c>();
        
        if(String.isBlank(dealItemId)) {
            Deal_Item__c dealItemRec = new Deal_Item__c(Deal__c = dealId, Customer_Owned_Unit__c = unitId, Type__c = Constants.DEAL_ITEM_TYPE_UNIT, Option_And_Fee_Status__c = Constants.UNCOMIITTED);
            
            if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Customer_Owned_Unit__c> unitList = [SELECT Applicable_Tax__c, Taxable__c from Customer_Owned_Unit__c WHERE Id =: unitId];
            if(unitList.size() > 0) {
                dealItemRec.Taxable__c = unitList[0].Taxable__c;
                dealItemRec.Applicable_Tax__c = unitList[0].Applicable_Tax__c;
            }
            insert dealItemRec;
            
            List<SObject> sObjectListToInsert = addLinkedFee(dealItemId, dealId, 'Deal');
            if(sObjectListToInsert != null) {
                insert sObjectListToInsert;
            }
            List<Deal_Unit_Price_Cost__c> dealUnitPriceListToInsert = DealService.addDealUnitCostPrice(new Set<Id>{unitId}, dealItemRec.Id);
            if(dealUnitPriceListToInsert.size() > 0) {
                insert dealUnitPriceListToInsert;
                if(!GeneralConfiguration.getTaxIncludingPricing() && GeneralConfiguration.isTradeTaxCreditCanNotExceedUnitTax()) {
                    DealService.limitDealItemSalesTax(dealId);
                }
            }
            dealItemId = dealItemRec.Id;
        } else {
            List<Deal_Item__c> dealItemRecList = [SELECT Customer_Owned_Unit__c, Unit_Make__c, Customer_Owned_Unit__r.Status__c from Deal_Item__c WHERE Id =: dealItemId];
            if(dealItemRecList.size() > 0) {
                if(String.isBlank(dealItemRecList[0].Unit_Make__c) && String.isBlank(dealItemRecList[0].Customer_Owned_Unit__c)) {
                    List<SObject> sObjectListToInsert = addLinkedFee(dealItemId, dealId, 'Deal');
                    if(sObjectListToInsert != null) {
                        insert sObjectListToInsert;
                    }
                } else if(String.isNotBlank(dealItemRecList[0].Customer_Owned_Unit__c) && String.isNotBlank(unitId) && dealItemRecList[0].Customer_Owned_Unit__c != unitId) {
                    //For changing unit-1 to unit-2
                    if(dealItemRecList[0].Customer_Owned_Unit__r.Status__c != Constants.ON_ORDER_STATUS ) {
                        unitListToUpdate.add(new Customer_Owned_Unit__c(Id = dealItemRecList[0].Customer_Owned_Unit__c, Status__c = 'Available'));
                    } else if(dealItemRecList[0].Customer_Owned_Unit__r.Status__c == Constants.ON_ORDER_STATUS) {
                        unitListToUpdate.add(new Customer_Owned_Unit__c(Id = dealItemRecList[0].Customer_Owned_Unit__c, Is_Ordered_Unit_Added_To_Deal__c = false));
                    }
                }
            }
            
            Deal_Item__c dealItemRec = new Deal_Item__c(Id = dealItemId, Customer_Owned_Unit__c = unitId, Type__c = Constants.DEAL_ITEM_TYPE_UNIT,
                                                Is_Rideaway_Pricing_Enabled__c = false, Rideaway_Pricing_Total__c = 0);
            if(unitId != null) {
                dealItemRec.Colour__c = null;
                dealItemRec.Unit_Make__c = null;
                dealItemRec.Unit_Model__c = null;
                dealItemRec.Year__c = null;
                dealItemRec.Sub_Model__c = null; 
            }
            
            List<Customer_Owned_Unit__c> unitList = [SELECT Applicable_Tax__c, Taxable__c,Status__c from Customer_Owned_Unit__c WHERE Id =: unitId];
            //is_Ordered_Unit_Added_To_Deal__c update this 
            if(unitList.size() > 0) {
                if(unitList[0].Status__c == Constants.ON_ORDER_STATUS ) {
                    unitList[0].Is_Ordered_Unit_Added_To_Deal__c = true;
                    update unitList;
                }
                dealItemRec.Taxable__c = unitList[0].Taxable__c;
                dealItemRec.Applicable_Tax__c = unitList[0].Applicable_Tax__c;
            }
            if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update dealItemRec;
            
            if(AccessControl.ifObjectFieldIsAccessible('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Deal_Unit_Price_Cost__c>  DealUnitPriceCostTodelete = [select Id  from Deal_Unit_Price_Cost__c where Deal_Item__c =:dealItemId];
            if(DealUnitPriceCostTodelete.size() > 0){
                delete DealUnitPriceCostTodelete;
            }
            set<Id> unitIds =  new set<Id>{unitId };
            List<Deal_Unit_Price_Cost__c> dealUnitPriceListToinsert = DealService.addDealUnitCostPrice(unitIds, dealItemRec.Id);
            if(dealUnitPriceListToinsert.size() > 0) {
                DealUnitPriceAndCostTriggerHelper.isTriggerExecute = true;
                insert dealUnitPriceListToinsert;
                if(!GeneralConfiguration.getTaxIncludingPricing() && GeneralConfiguration.isTradeTaxCreditCanNotExceedUnitTax()) {
                    DealService.limitDealItemSalesTax(dealId);
                }
            }
        }
        updateStatusForDeal(dealId);
        
        if(String.isNotBlank(unitId)) {
            List<Deal_Item__c> dealItemList = [Select Id, Deal__r.Status__c,Customer_Owned_Unit__r.Status__c from Deal_Item__c where Id =: dealItemId];
            if(dealItemList.size() > 0 && dealItemList[0].Deal__r.Status__c == 'In Progress' && dealItemList[0].Customer_Owned_Unit__r.Status__c != Constants.ON_ORDER_STATUS) {
                unitListToUpdate.add(new Customer_Owned_Unit__c(Id = unitId, Status__c = 'Reserved'));
            }
        }
        if(unitListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update unitListToUpdate;
        }
        //OptionAndFeeTriggerHelper.updateDealTotal(new Set<String>{dealId});
        return getDealDetails(BPUtility.getEncodedString(dealId), null);
    }
    
    // Added by Subhrant
    @RemoteAction
    global static String updateDealUnitCostPrice(String DealUnitCostPriceItemjson, String dealId, String dealItemId) { 
        dealItemId = BPUtility.getDecodedString(dealItemId); 
        dealId = BPUtility.getDecodedString(dealId);   
        DealUnitCostPriceItemjson = BPUtility.getDecodedString(DealUnitCostPriceItemjson);
        List<DealWrapper.FactoryOption>  DealUnitCostPriceList = (List<DealWrapper.FactoryOption>) System.JSON.deserialize(DealUnitCostPriceItemjson, List<DealWrapper.FactoryOption>.class);
        //List<Deal_Unit_Price_Cost__c> DealUnitPriceCostList = new List<Deal_Unit_Price_Cost__c>();
        
        List<Deal_Unit_Price_Cost__c> dealUnitPriceCostListToInsert = new List<Deal_Unit_Price_Cost__c>();
        List<Deal_Unit_Price_Cost__c> dealUnitPriceCostListToUpdate = new List<Deal_Unit_Price_Cost__c>();
        
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        for(DealWrapper.FactoryOption unitPriceCostRec : DealUnitCostPriceList) {
            Deal_Unit_Price_Cost__c dealUnitPriceCostRec = new Deal_Unit_Price_Cost__c();
            dealUnitPriceCostRec.Id = unitPriceCostRec.Id;
            dealUnitPriceCostRec.Deal_Item__c = dealItemId;
            dealUnitPriceCostRec.Type__c = unitPriceCostRec.Type;
            dealUnitPriceCostRec.Price__c = unitPriceCostRec.Price;
            dealUnitPriceCostRec.Qty__c = unitPriceCostRec.Qty;
            dealUnitPriceCostRec.Price_When_Tax_Included__c = unitPriceCostRec.Price; 
            if(isTaxIncludingPricing) {
                if(unitPriceCostRec.Price == null) {
                    unitPriceCostRec.Price = 0;
                }
                if(unitPriceCostRec.SalesTaxPercentage == null) {
                    unitPriceCostRec.SalesTaxPercentage = 0;
                }
                if(String.isNotBlank(unitPriceCostRec.Id)) {
                    dealUnitPriceCostRec.Price__c = (unitPriceCostRec.Price / (1 + unitPriceCostRec.SalesTaxPercentage / 100));
                    dealUnitPriceCostListToUpdate.add(dealUnitPriceCostRec);
                } else {
                    if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<Deal_Item__c> dealItemList = [Select Customer_Owned_Unit__c, Customer_Owned_Unit__r.Applicable_Tax__r.Rate__c from Deal_Item__c where Id =: dealItemId];
                    if(dealItemList.size() > 0 && dealItemList[0].Customer_Owned_Unit__c != null) {
                        if(dealItemList[0].Customer_Owned_Unit__r.Applicable_Tax__r.Rate__c != null) {
                        unitPriceCostRec.SalesTaxPercentage = dealItemList[0].Customer_Owned_Unit__r.Applicable_Tax__r.Rate__c;
                    }
                    }  else {
                        String defaultSalesTaxId = Configurations__c.getInstance().Default_Tax_on_Unit__c;
                        if(String.isNotBlank(defaultSalesTaxId)) {
                            List<Sales_Tax__c> defaultSalesTaxList = [select Id, Rate__c from Sales_Tax__c where Id =: defaultSalesTaxId];
                            unitPriceCostRec.SalesTaxPercentage = defaultSalesTaxList[0].Rate__c;
                        } else {
                            List<Sales_Tax__c> defaultSalesTaxList = [select Id, Rate__c from Sales_Tax__c where Default__c = true];
                            if(defaultSalesTaxList.size() > 0) {
                                unitPriceCostRec.SalesTaxPercentage = defaultSalesTaxList[0].Rate__c;
                            }
                        }
                    }
                    dealUnitPriceCostRec.Price__c = (unitPriceCostRec.Price * (1 + unitPriceCostRec.SalesTaxPercentage / 100));
                    dealUnitPriceCostListToInsert.add(dealUnitPriceCostRec);
                }
            } else {
                if(String.isNotBlank(unitPriceCostRec.Id)) {
                    dealUnitPriceCostListToUpdate.add(dealUnitPriceCostRec);
                } else {
                     dealUnitPriceCostListToInsert.add(dealUnitPriceCostRec);
                }
            }
        }
        if(AccessControl.ifObjectFieldIsCreateable('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        if(dealUnitPriceCostListToInsert.size() > 0){
            insert dealUnitPriceCostListToInsert;
            if(isTaxIncludingPricing) {
                Set<String> idList = new Set<String>();
                for(Deal_Unit_Price_Cost__c unitPriceCostRec : dealUnitPriceCostListToInsert) {
                    idList.add(unitPriceCostRec.Id);
                }
                dealUnitPriceCostListToInsert.clear();
                dealUnitPriceCostListToInsert =  [Select Price__c, Sales_Tax_Percentage__c from Deal_Unit_Price_Cost__c where Id In :idList];
                for(Deal_Unit_Price_Cost__c unitPriceCostRec : dealUnitPriceCostListToInsert) {
                    if(unitPriceCostRec.Price__c == null) {
                        unitPriceCostRec.Price__c = 0;
                    }
                    if(unitPriceCostRec.Sales_Tax_Percentage__c == null) {
                        unitPriceCostRec.Sales_Tax_Percentage__c = 0;
                    }
                    unitPriceCostRec.Price__c = (unitPriceCostRec.Price__c / (1 + unitPriceCostRec.Sales_Tax_Percentage__c / 100));
                    dealUnitPriceCostListToUpdate.add(unitPriceCostRec);
                }
            }
        }
        if(dealUnitPriceCostListToUpdate.size() > 0) {
            update dealUnitPriceCostListToUpdate;
            if(!GeneralConfiguration.getTaxIncludingPricing() && GeneralConfiguration.isTradeTaxCreditCanNotExceedUnitTax()) {
                DealService.limitDealItemSalesTax(dealId);
            }
        }
        //OptionAndFeeTriggerHelper.updateDealTotal(new Set<String>{dealId});
        return getDealItemDetails(dealItemId);  
    }
    
    /**
     * Name: removeUnitFromDeal
     * Desc: Method which delets temporary unit
     * @param:  (1) dealId - String - Deal id
     * @param:  (2) dealItemId - String - Deal item Id
     * @return: String - JSON String of deal items
    **/
    @RemoteAction
    global static String removeUnitFromDeal(String dealId, String dealItemId) { 
        dealItemId = BPUtility.getDecodedString(dealItemId); 
        dealId = BPUtility.getDecodedString(dealId);    
        
        if(String.isNotBlank(dealItemId)) {
            List<Deal_Item__c> dealItemList = [Select Deal__r.Status__c From Deal_Item__c where Id =: dealItemId];
            if(dealItemList.size() > 0 && dealItemList[0].Deal__r.Status__c != 'Invoiced') {
            if(AccessControl.ifObjectIsDeletable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete new Deal_Item__c(Id = dealItemId);
        
        updateStatusForDeal(dealId);
            }
        }
        return getDealDetails(BPUtility.getEncodedString(dealId), null);
    }
    
    //START: Added By Nidhi - #129 - 09/24/2016 
    @RemoteAction
    global static String getServiceWorksheetPrintDetail(String coHeaderId) { 
        coHeaderId = BPUtility.getDecodedString(coHeaderId); 
        
        if(String.isNotBlank(coHeaderId)) {
            List<CO_Header__c> coHeaderList = SOQLUtil.getSOHeaderListByCOHeaderId(new Set<Id>{coHeaderId});
            if(coHeaderList.size() > 0) {
                Map<Id, Customer_Owned_Unit__c> unitIdToUnitMap = new Map<Id, Customer_Owned_Unit__c>();
                Map<Id, List<Service_Order_Header__c>> unitIdToSOHeaderMap = new Map<Id, List<Service_Order_Header__c>>();
                
                for(Service_Order_Header__c soHeaderRec : coHeaderList[0].Service_Order_Headers__r) {
                    if(soHeaderRec.Customer_Owned_Unit__c != null) {
                        String formattedName = ((soHeaderRec.Customer_Owned_Unit__r.Unit_Make__c != null) ? soHeaderRec.Customer_Owned_Unit__r.Unit_Make__r.Name + ' ' : '') + 
                                       ((soHeaderRec.Customer_Owned_Unit__r.Unit_Model__c != null) ? soHeaderRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c + ' ' : '') + 
                                       ((soHeaderRec.Customer_Owned_Unit__r.Sub_Model__c != null && soHeaderRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c != null) 
                                                       ? soHeaderRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c + ' ' : '') +
                                       ((soHeaderRec.Customer_Owned_Unit__r.Year__c != null) ? STring.valueOf(soHeaderRec.Customer_Owned_Unit__r.Year__c) : '');
                        Customer_Owned_Unit__c unitRec = new Customer_Owned_Unit__c(Id = soHeaderRec.Customer_Owned_Unit__c, 
                                                                                    VIN_Number__c = soHeaderRec.Customer_Owned_Unit__r.VIN_Number__c,
                                                                                    Search_Tag__c = formattedName);                                                                                    
                        unitIdToUnitMap.put(unitRec.Id, unitRec);
                        if(unitIdToSOHeaderMap.containsKey(soHeaderRec.Customer_Owned_Unit__c)) {
                            unitIdToSOHeaderMap.get(soHeaderRec.Customer_Owned_Unit__c).add(soHeaderRec);
                        } else {
                            unitIdToSOHeaderMap.put(soHeaderRec.Customer_Owned_Unit__c, new List<Service_Order_Header__c>{soHeaderRec});
                        }
                    }
                } 
                List<SOWorkSheetWrapper.ServiceWorkSheetPrintDetail> soWorksheetWrapperList = new List<SOWorkSheetWrapper.ServiceWorkSheetPrintDetail>();
                for(Id unitId : unitIdToUnitMap.keySet()) {
                    SOWorkSheetWrapper.ServiceWorkSheetPrintDetail soWorksheetPrintDetailObj = new SOWorkSheetWrapper.ServiceWorkSheetPrintDetail(unitIdToUnitMap.get(unitId), unitIdToSOHeaderMap.get(unitId));
                    soWorksheetWrapperList.add(soWorksheetPrintDetailObj); 
                }
                return BPUtility.getEncodedString(JSON.serialize(soWorksheetWrapperList));
            }
        }
        return '{}';   
    }
    
    @RemoteAction
    global static void saveWorkseetSelectionJson(String coHeaderId, String jsonString) { 
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        jsonString = BPUtility.getDecodedString(jsonString);
        
        if(coHeaderId != null) {
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            CO_Header__c coHeaderRec = new CO_Header__c(Id = coHeaderId, SO_Worksheet_User_selection__c = jsonString);
            update coHeaderRec;
        }
    }
    
    //END: Added By Nidhi - #129 - 09/24/2016
    
    
    
    
    //START: Added By Hitesh - Quick Cash sale - 10/13/2016
    
    /**
    * Name: insertFeeInMerchGrid
    * Desc: Method to insert Fee in Merch Grid
    * @param:   (1)lineItemId - String - id of line item
                (2)coHeaderId - String - id of coHeader
    * @return: String - Wrapper JSON String of all Lookup fields of Customer
    **/
    @remoteAction
    global static String insertFeeInQuickCashSale(String lineItemId, String coHeaderId) {
        lineItemId = BPUtility.getDecodedString(lineItemId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            deleteTemporaryCoLineItems(coHeaderId, null);
            if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            

            List<Fee__c> feeList = SOQLUtil.getFeeByFieldName(new Map<String, String>{'Id' => lineItemId});
            if(feeList.size() == 0) {
                return getCOHeaderDetailsByGridName(coHeaderId, 'coHeader,coLineItem,user,coInvoiceHeader,checkOut,specialOrder');
            }
            
            if(String.isBlank(coHeaderId)) {
                coHeaderId = BPUtility.getDecodedString(BPGlobalHeaderCtrl.createCustomerOrder());  
            }
            
            CO_Line_Item__c coliRec = new CO_Line_Item__c();
            coliRec.CO_Header__c = coHeaderId;
            coliRec.Fee__c = feeList[0].Id;
            coliRec.Qty__c = 1;
            coliRec.Qty_Committed__c = coliRec.Qty__c;
            coliRec.Price__c = (feeList[0].Price__c != null) ? feeList[0].Price__c : 0;
            coliRec.Retail__c = coliRec.Price__c;
            //coliRec.Is_Temporary__c = true;
            insert coliRec; 
            
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coHeader,coLineItem,user,coInvoiceHeader,checkOut,specialOrder'));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    } 
    
    
    /**
    * Name: saveCOLineItem
    * Desc: Method Which saves CO Line Items in Database 
    * @param:   (1) coHeaderId - String - CO Header record Id
    *           (2) jSONString - String - JSON String of CO Line Items
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction
    global static String saveLineItemInQuickCashSale(String coHeaderId, String jSONString) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        jSONString = BPUtility.getDecodedString(jSONString);
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        try{
            if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(String.isBlank(COHeaderId)) {
                COHeaderId = BPUtility.getDecodedString(BPGlobalHeaderCtrl.createCustomerOrder());  
            }
            
            System.debug('@@@ jSONString jSONString jSONString:\n'+ jSONString);
            List<COLineItem> coLineItemObjList = (List<COLineItem>) System.JSON.deserialize(jSONString, List<COLineItem>.class);
            List<CO_Line_Item__c> coLineItemListToUpdate = new List<CO_Line_Item__c>();
            for(COLineItem coLineItemObj : coLineItemObjList) {
                CO_Line_Item__c coLineItemRec = new CO_Line_Item__c();
                coLineItemRec.Qty__c = coLineItemObj.Qty ;
                if(isTaxIncludingPricing) {
                    if(coLineItemObj.Tax == null) {
                        coLineItemObj.Tax = 0;
                    }   
                    coLineItemRec.Price_When_Tax_Included__c = coLineItemObj.Price;
                    coLineItemRec.Price__c = (coLineItemObj.Price / (1 + (coLineItemObj.Tax / 100)));
                } else {
                    coLineItemRec.Price__c = coLineItemObj.Price;
                }
                
                coLineItemRec.CO_Header__c = coHeaderId;
                coLineItemRec.Part__c = (coLineItemObj.PartId != '') ? coLineItemObj.PartId : null;
                coLineItemRec.Fee__c = (coLineItemObj.FeeId != '') ? coLineItemObj.FeeId : null;
                
                /* START: Added By Tarun - #170 - 09/23/2016 */
                if(coLineItemRec.Fee__c != null) {
                    coLineItemRec.Item_Description__c = coLineItemObj.ItemDescription;
                }
                
                if(coLineItemObj.isSpecialOrder == null) {
                    coLineItemRec.Special_Order__c = false; // Special Order Flag
                } else {
                    coLineItemRec.Special_Order__c = coLineItemObj.isSpecialOrder; // Special Order Flag
                }
                if(coLineItemObj.CoLineItemId != null) {
                    coLineItemRec.Id = coLineItemObj.CoLineItemId;
                    //coLineItemRec.Is_Temporary__c = false;
                }else{
                    //coLineItemRec.Is_Temporary__c = true;
                    //deleteTemporaryCoLineItems(coHeaderId, null);
                }
                if(coLineItemObj.QtyCommitted != null && coLineItemObj.Qty > 0) {
                    if( coLineItemObj.QtyCommitted  > coLineItemObj.Qty) {
                        coLineItemRec.Qty_Committed__c = coLineItemObj.Qty;
                    } else {
                        coLineItemRec.Qty_Committed__c = coLineItemObj.QtyCommitted;    
                    }
                }
                coLineItemListToUpdate.add(coLineItemRec);
            }
            if(coLineItemListToUpdate.size() > 0) {
                upsert coLineItemListToUpdate;
            }
            
            // return JSON
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coHeader,coLineItem,user,coInvoiceHeader,specialOrder'));
        }catch(Exception e){

            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    // Start: Added By Pooja 2 Feb. 2017
    /**
    * Name: updateLineItemDescInQuickCashSale
    * Desc: Method Which updates CO Line Items Desc for quick cash sale in Database 
    * @param:   (1) coHeaderId - String - CO Header record Id
    *           (2) jSONString - String - JSON String of CO Line Items
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction
    global static String updateLineItemDescInQuickCashSale(String coHeaderId, String jSONString) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        jSONString = BPUtility.getDecodedString(jSONString);
        try{
            if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(String.isBlank(COHeaderId)) {
                COHeaderId = BPUtility.getDecodedString(BPGlobalHeaderCtrl.createCustomerOrder());  
            }
            
            System.debug('**************** jSONString jSONString jSONString:\n'+ jSONString);
            List<COLineItem> coLineItemObjList = (List<COLineItem>) System.JSON.deserialize(jSONString, List<COLineItem>.class);
            List<CO_Line_Item__c> coLineItemListToUpdate = new List<CO_Line_Item__c>();
            for(COLineItem coLineItemObj : coLineItemObjList) {
                CO_Line_Item__c coLineItemRec = new CO_Line_Item__c();
                coLineItemRec.CO_Header__c = coHeaderId;
                coLineItemRec.Part__c = (coLineItemObj.PartId != '') ? coLineItemObj.PartId : null;
                coLineItemRec.Fee__c = (coLineItemObj.FeeId != '') ? coLineItemObj.FeeId : null;
                
                if(coLineItemRec.Fee__c != null) {
                    coLineItemRec.Item_Description__c = coLineItemObj.ItemDescription;
                }
                
                if(coLineItemObj.CoLineItemId != null) {
                    coLineItemRec.Id = coLineItemObj.CoLineItemId;
                }
                
                coLineItemListToUpdate.add(coLineItemRec);
            }
            if(coLineItemListToUpdate.size() > 0) {
                upsert coLineItemListToUpdate;
            }
            
            // return JSON
            return getCOHeaderDetailsByGridName(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('coHeader,coLineItem,user,coInvoiceHeader,specialOrder'));
        }catch(Exception e){

            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    // End: Added By Pooja 2 Feb. 2017
    
    public static void deleteTemporaryCoLineItems(String coHeaderId, String ColineItemId){
        /*if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        String query = 'SELECT Id From CO_Line_Item__c Where CO_Header__c = :coHeaderId AND Is_Temporary__c = true';
        if(ColineItemId != null){
            query += 'AND Id = :ColineItemId';
        }
        List<CO_Line_Item__c> coliList = (List<CO_Line_Item__c>)Database.query(query);
        if(coliList.size() > 0){
            delete coliList;
        }*/
    }
    
    @RemoteAction
    global static String finalizeQuickSale(String coInvoiceItemsJsonString, String coHeaderId, String currentCheckoutType){
        coInvoiceItemsJsonString = BPUtility.getDecodedString(coInvoiceItemsJsonString);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        currentCheckoutType = BPUtility.getDecodedString(currentCheckoutType);
        List<COInvoiceItem> coInvoiceItemObjList = (List<COInvoiceItem>) System.JSON.deserialize(coInvoiceItemsJsonString, List<COInvoiceItem>.class);
            
        for(COInvoiceItem CI : coInvoiceItemObjList){
            CI.IsInvoiceable = true;
            CI.IsFinalizable = true;
            CI.IsActive = true;
        }
        coInvoiceItemsJsonString = BPUtility.getEncodedString(System.JSON.serialize(coInvoiceItemObjList));
        coHeaderId = BPUtility.getEncodedString(coHeaderId);
        currentCheckoutType = BPUtility.getEncodedString(currentCheckoutType);
        updateCOInvoiceItem(coInvoiceItemsJsonString, coHeaderId);
        
        String jsonStr = closedOrderAction(coInvoiceItemsJsonString, coHeaderId, currentCheckoutType);
        // Create Activity History.
        if(!Test.isRunningTest()) {
            //ActivityHistory.createActivityHistory('Checkout Quick Sale', 'Customer Order', BPUtility.getDecodedString(coHeaderId), 'Customer', null, null);
        }
        
        return jsonStr;
    }
    
    //END: Added By Hitesh - Quick Cash sale - 10/13/2016
    
    /* START: Added by Tarun 10/15/2016 */
    /**
    * Name: saveOptionFeesLineItem
    * Desc: Method Which saves Option & Fees Line Items in Database 
    * @param:   (1) dealId - String - Deal id   
    * @param:   (2) jSONString - String - JSON String of Option & Fees Line Items
    * @return: String - JSON String of Option & Fees Record
    **/
    @RemoteAction
    global static String saveOptionFeesLineItem(String dealId, String dealItemId, String jSONString) {
        dealId = BPUtility.getDecodedString(dealId);
        dealItemId = BPUtility.getDecodedString(dealItemId);
        jSONString = BPUtility.getDecodedString(jSONString);
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
       
        Decimal price = 0.00;
        Boolean isNewOptionAndFee = false;
        Boolean previousIsInstall;
        DealWrapper.OptionAndFeeInfo optionAndFeeInfoObjRec = (DealWrapper.OptionAndFeeInfo) System.JSON.deserialize(jSONString, DealWrapper.OptionAndFeeInfo.class);
        Option_Fee__c envFeeLineItemRec = new Option_Fee__c();
        if(optionAndFeeInfoObjRec.Id == null) {
            if(String.isNotBlank(optionAndFeeInfoObjRec.KitHeaderId)) {
                Id DealKitHeaderId = insertDealKitHeaderInGrid(optionAndFeeInfoObjRec.KitHeaderId, dealItemId, dealId, null);
                return getDealItemDetails(dealItemId);
            } else if(String.isNotBlank(optionAndFeeInfoObjRec.FeeId)) {
                if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Fee__c> feeList = [Select Code__c, Description__c, Price__c from Fee__c where Id = :optionAndFeeInfoObjRec.FeeId];
                if(feeList.size() > 0) {
                    price = feeList[0].Price__c;
                    optionAndFeeInfoObjRec.ItemCode = feeList[0].Code__c;
                    optionAndFeeInfoObjRec.ItemDescription = feeList[0].Description__c;
                }
            } else if(String.isNotBlank(optionAndFeeInfoObjRec.LabourId)) {
                if(AccessControl.ifObjectFieldIsAccessible('Labour_Code__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Labour_Code__c> labourList = [Select Code__c, Description__c, Rate__c, Hours__c from Labour_Code__c where Id = :optionAndFeeInfoObjRec.LabourId];
                if(labourList.size() > 0) {
                    price = labourList[0].Rate__c;
                    optionAndFeeInfoObjRec.ItemCode = labourList[0].Code__c;
                    optionAndFeeInfoObjRec.ItemDescription = labourList[0].Description__c;
                    //Start: Ticket#1841: Added By Pooja 10 Apr. 2017
                    if(optionAndFeeInfoObjRec.Id == null)   {
                        optionAndFeeInfoObjRec.Qty = labourList[0].Hours__c;
                    }
                    //End: Ticket#1841: Added By Pooja 10 Apr. 2017
                }
            } else if(String.isNotBlank(optionAndFeeInfoObjRec.ProductId)) {
                if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Product__c> productList = [Select Code__c, Description__c, Price__c from Product__c where Id = :optionAndFeeInfoObjRec.ProductId];
                if(productList.size() > 0) {
                    price = productList[0].Price__c;
                    optionAndFeeInfoObjRec.ItemCode = productList[0].Code__c;
                    optionAndFeeInfoObjRec.ItemDescription = productList[0].Description__c;
                }
            } else if(String.isNotBlank(optionAndFeeInfoObjRec.PartId)){
                if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Part__c> partList = [Select Part_Number__c, Description__c from Part__c where Id = :optionAndFeeInfoObjRec.PartId];
                if(partList.size() > 0) {
                    optionAndFeeInfoObjRec.ItemCode = partList[0].Part_Number__c;
                    optionAndFeeInfoObjRec.ItemDescription = partList[0].Description__c;
                }
                price = optionAndFeeInfoObjRec.Price;
                
                // Create one Extra line for Env Fee
                if(optionAndFeeInfoObjRec.Id == null) {
                    envFeeLineItemRec = createEnvFeeLineItemInDealSection(optionAndFeeInfoObjRec.PartId, dealId, dealItemId);
                }
            }
        } else {
            price = optionAndFeeInfoObjRec.Price;
        }
        if(price == null) {
            price = 0;
        }
        if(isTaxIncludingPricing) {
            if(optionAndFeeInfoObjRec.SalesTaxPercentage == null) {
                optionAndFeeInfoObjRec.SalesTaxPercentage = 0;
            } 
            price = (price / (1 + (optionAndFeeInfoObjRec.SalesTaxPercentage / 100))).setScale(2, RoundingMode.HALF_UP);
        } 
        Option_Fee__c optionAndFeeInfoRecToUpsert = setOptionAndFeeRecord(dealId, optionAndFeeInfoObjRec, price);
        if(String.isBlank(optionAndFeeInfoRecToUpsert.Id)) {
            if(AccessControl.ifObjectFieldIsCreateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            isNewOptionAndFee = true;
            List<Option_Fee__c> optionFeeListToInsert = new List<Option_Fee__c>();
            optionFeeListToInsert.add(optionAndFeeInfoRecToUpsert);
            if(envFeeLineItemRec.Fee__c != null) {
                optionFeeListToInsert.add(envFeeLineItemRec);
            }
            insert optionFeeListToInsert;
            if(optionAndFeeInfoRecToUpsert.Product__c != null) {
                COFormService.insertDefaultCOForms(null, dealId, optionAndFeeInfoRecToUpsert.Product__c);
            }
        } else {
            if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Option_fee__c> optionAndFeeList =  [Select Is_Install__c from Option_Fee__c where Id = :optionAndFeeInfoRecToUpsert.Id];
            if(optionAndFeeList.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                previousIsInstall = optionAndFeeList[0].Is_Install__c;
                update optionAndFeeInfoRecToUpsert;
            }
        }
        //OptionAndFeeTriggerHelper.updateDealTotal(new Set<String>{dealId});
        //Modified by nidhi - 11-09-2016
        //To insert new Deal Merchandise Or Deal Service line Item, when unit is already committed
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        //List<Deal__c> dealList = [Select Status__c, Unit_Status__c, CO_Header__c from Deal__c where Id = :dealId];
        List<Deal_Item__c> dealItemList = [Select Option_And_Fee_Status__c, Deal__r.Status__c, Deal__r.Unit_Status__c, Deal__r.CO_Header__c from Deal_Item__c where Deal__c = :dealId];
        
        if(isNewOptionAndFee || (!isNewOptionAndFee && previousIsInstall != optionAndFeeInfoRecToUpsert.Is_Install__c)) {
            if(dealItemList.size() > 0 && (dealItemList[0].Deal__r.Status__c == Constants.IN_PROGRESS || dealItemList[0].Deal__r.Status__c == 'Approved') && dealItemList[0].Option_And_Fee_Status__c == Constants.COMMITTED) {
                return moveDealMerchAndServiceLineItems(BPUtility.getEncodedString(optionAndFeeInfoRecToUpsert.Id), BPUtility.getEncodedString(dealItemList[0].Deal__r.CO_Header__c));
            }
        }
        
        return getDealItemDetails(dealItemId);
    }
    
    private static Option_Fee__c setOptionAndFeeRecord(String dealId, DealWrapper.OptionAndFeeInfo optionAndFeeInfoObjRec, Decimal price) {
        Option_Fee__c optionAndFeeInfoRecToUpsert = new Option_Fee__c();
        optionAndFeeInfoRecToUpsert.Deal__c = dealId;
        optionAndFeeInfoRecToUpsert.Deal_Item__c = optionAndFeeInfoObjRec.DealItemId;  
        optionAndFeeInfoRecToUpsert.Qty__c = (optionAndFeeInfoObjRec.Qty != null) ? optionAndFeeInfoObjRec.Qty : 1;
        optionAndFeeInfoRecToUpsert.Price__c = price;
        optionAndFeeInfoRecToUpsert.Part__c = (optionAndFeeInfoObjRec.PartId != '') ? optionAndFeeInfoObjRec.PartId : null;
        optionAndFeeInfoRecToUpsert.Fee__c = (optionAndFeeInfoObjRec.FeeId != '') ? optionAndFeeInfoObjRec.FeeId : null;
        optionAndFeeInfoRecToUpsert.Labour_Code__c = (optionAndFeeInfoObjRec.LabourId != '') ? optionAndFeeInfoObjRec.LabourId : null;
        optionAndFeeInfoRecToUpsert.Product__c = (optionAndFeeInfoObjRec.ProductId != '') ? optionAndFeeInfoObjRec.ProductId : null;
        optionAndFeeInfoRecToUpsert.Item_Code__c = optionAndFeeInfoObjRec.ItemCode;
        optionAndFeeInfoRecToUpsert.Item_Description__c = optionAndFeeInfoObjRec.ItemDescription;
        optionAndFeeInfoRecToUpsert.Price_When_Tax_Included__c = optionAndFeeInfoObjRec.Price;
        //optionAndFeeInfoRecToUpsert.Kit_Header__c = (optionAndFeeInfoObjRec.KitId != '') ? optionAndFeeInfoObjRec.KitId : null;
        if(String.isNotBlank(optionAndFeeInfoObjRec.LabourId)) {
            optionAndFeeInfoRecToUpsert.Is_Install__c = true;
        } else {
            optionAndFeeInfoRecToUpsert.Is_Install__c = optionAndFeeInfoObjRec.IsInstall;
        }
        if(String.isNotBlank(optionAndFeeInfoObjRec.Id)) {
            optionAndFeeInfoRecToUpsert.Id = optionAndFeeInfoObjRec.Id;
        }
        return optionAndFeeInfoRecToUpsert;
    }
    
    @RemoteAction
    global static String removeOptionFeesLineItem(String dealItemId, String lineItemId) {
        dealItemId = BPUtility.getDecodedString(dealItemId);
        lineItemId = BPUtility.getDecodedString(lineItemId);
        
        String dealId = '';
        String objectName = (Id.valueOf(lineItemId)).getSObjectType().getDescribe().getName();
        if(objectName == CONSTANTS.NAMESPACE + 'Option_Fee__c') {
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Option_Fee__c> optionFeeRecordToDelete = [select Deal__r.Status__c, Deal__c from Option_Fee__c where Id =: lineItemId];
            dealId = optionFeeRecordToDelete[0].Deal__c;
            if(optionFeeRecordToDelete.size() > 0 && optionFeeRecordToDelete[0].Deal__r.Status__c != 'Invoiced') {
            if(AccessControl.ifObjectIsDeletable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete optionFeeRecordToDelete[0];
        }
        } else if(objectName == CONSTANTS.NAMESPACE + 'Deal_Kit_Header__c') {
            dealId = removeDealKHItems(lineItemId);
        }
        //OptionAndFeeTriggerHelper.updateDealTotal(new Set<String>{dealId});
        return getDealItemDetails(dealItemId);
    }
    /* END: Added by Tarun 10/15/2016 */
     
    //Trade-Ins Section   
    //START: Added by Nidhi - 26-11-2016
    @RemoteAction
    global static String updateTradeIn(String dealId, String jsonString) {
        dealId = BPUtility.getDecodedString(dealId);
        jsonString = BPUtility.getDecodedString(jsonString);
        
        if(AccessControl.ifObjectFieldIsCreateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        DealItem dealItemObj = DealItem.parse(jsonString);
        dealItemObj.Type = Constants.DEAL_ITEM_TYPE_TRADE_IN;
        Deal_Item__c dealItemRec = setDealItemValues(dealItemObj, dealId);
        
        if(dealItemObj.Id == null) {
            String defaultUnitSalesTaxId = Configurations__c.getInstance().Default_Tax_on_Unit__c;
            if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Sales_Tax__c> salesTaxList = [Select Id, Rate__c from Sales_Tax__c WHERE Id = :defaultUnitSalesTaxId];
            if(salesTaxList.size() > 0) {
                dealItemRec.Default_Unit_Sales_Tax_Percentage__c = salesTaxList[0].Rate__c;
                dealItemRec.Applicable_Tax__c = salesTaxList[0].Id;
                dealItemRec.Taxable__c = true;
            }
        }
        upsert dealItemRec;
        
        if(!GeneralConfiguration.getTaxIncludingPricing() && GeneralConfiguration.isTradeTaxCreditCanNotExceedUnitTax()) {
            DealService.limitDealItemSalesTax(dealId);
        }
        
        if(GeneralConfiguration.getAccrueTradeTaxUntilUnitSold()) {
            List<Deal_Item__c> dealItemRecList = [SELECT Id, Stocked_In_Unit__c, Agreed_Value__c, Default_Unit_Sales_Tax_Percentage__c FROM Deal_Item__c 
                                                    WHERE Id =: dealItemRec.Id AND Stocked_In_Unit__c != null];
            if(dealItemRecList.size() > 0) {
                Customer_Owned_Unit__c skuRecToUpdate = new Customer_Owned_Unit__c(Id = dealItemRecList[0].Stocked_In_Unit__c);
                DealService.populateTradeInAndSalesTaxOnSku(dealItemRecList[0], skuRecToUpdate);
                update skuRecToUpdate;
            }
        }
        //OptionAndFeeTriggerHelper.updateDealTotal(new Set<String>{dealId});
        return getDealItemDetails(dealItemRec.Id);
    }
    
    //END: Added by Nidhi - 26-11-2016
   
   // Added by TK - 11/04/2016
    @RemoteAction
    global static String createDealMerchAndServiceSetion(String dealId, String coHeaderId) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        dealId = BPUtility.getDecodedString(dealId);
        List<Deal_Item__c> dealItemList = SOQLUtil.getDealItemDetailsByFieldName(new Map<String, String>{'Deal__c' => dealId,
                                                                                                        'Type__c' => Constants.DEAL_ITEM_TYPE_UNIT});
        Map<Id, Deal_Item__c> dealIdToOptionFeeMap = new Map<Id, Deal_Item__c>();
        Set<String> couIdSet = new Set<String>();
        for(Deal_Item__c dealItemRec : dealItemList) {
            dealIdToOptionFeeMap.put(dealItemRec.Id, dealItemRec);
            couIdSet.add(dealItemRec.Customer_Owned_Unit__c);
        }
        
        List<Deal_Kit_Header__c> dealKHList = SOQLUtil.getDealKitHeaderDetailsByDealItemId(new Set<Id>(dealIdToOptionFeeMap.keySet()));
        Map<Id, Deal_Kit_Header__c> dealKHIdToDKHMap = new Map<Id, Deal_Kit_Header__c>(dealKHList);
        
        //Map<Id, Option_Fee__c> partIdToDealMerchOptionFeeRecMap = new Map<Id, Option_Fee__c>();
        //Map<Id, String> partIdToSimilarOptionFeeRecMap = new Map<Id, String>();
        List<Option_Fee__c> merchOptionAndFeeList = new List<Option_Fee__c>();
        Map<Id, List<Option_Fee__c>> dealItemIdToDealServiceOptionAndFeeListMap = new Map<Id, List<Option_Fee__c>>();
        
        List<Deal_Kit_Header__c> dealKitHeaderToAddInMerchList = new List<Deal_Kit_Header__c>();
        Map<Id, List<Deal_Kit_Header__c>> dealItemIdToServiceDKHListMap = new Map<Id, List<Deal_Kit_Header__c>>();

        Set<String> dealItemIdToInsertDealServiceSet = new Set<String>();
        for(Deal_Item__c dealItemRec : dealItemList) {
            List<Option_Fee__c> installedOptionAndFeeRecList = new List<Option_Fee__c>();
            for(Option_Fee__c optionAndFeeRec : dealItemRec.Options_Fees__r) {
                if(optionAndFeeRec.Part__c != null || optionAndFeeRec.Labour_Code__c != null || (optionAndFeeRec.Product__c != null && optionAndFeeRec.Product__r.Type__c == 'Sublet')) {
                    if(!optionAndFeeRec.Is_Install__c) { // Deal Merch Section
                        /*if(partIdToDealMerchOptionFeeRecMap.containsKey(optionAndFeeRec.Part__c)) {
                            Option_Fee__c existingOptionFeeRec = partIdToDealMerchOptionFeeRecMap.get(optionAndFeeRec.Part__c);
                            if(existingOptionFeeRec.Qty__c == null) {
                                existingOptionFeeRec.Qty__c = 0;
                            }
                            existingOptionFeeRec.Qty__c += (optionAndFeeRec.Qty__c != null) ? optionAndFeeRec.Qty__c : 0;
                            
                            String optionFeeIdStr = partIdToSimilarOptionFeeRecMap.get(optionAndFeeRec.Part__c);
                            optionFeeIdStr = optionFeeIdStr + ';' + optionAndFeeRec.Id;
                            partIdToSimilarOptionFeeRecMap.put(optionAndFeeRec.Part__c, optionFeeIdStr);
                            
                        } else {
                            partIdToDealMerchOptionFeeRecMap.put(optionAndFeeRec.Part__c, optionAndFeeRec); 
                            partIdToSimilarOptionFeeRecMap.put(optionAndFeeRec.Part__c, optionAndFeeRec.Id);
                        }*/
                        merchOptionAndFeeList.add(optionAndFeeRec);
                        
                    } else { // Deal Service Section
                        installedOptionAndFeeRecList.add(optionAndFeeRec);
                        dealItemIdToDealServiceOptionAndFeeListMap.put(dealItemRec.Id, installedOptionAndFeeRecList);
                        dealItemIdToInsertDealServiceSet.add(dealItemRec.Id);
                    }
                }
            }
            
            List<Deal_Kit_Header__c> dkhList = new List<Deal_Kit_Header__c>();
            for(Deal_Kit_Header__c dealKitHeaderRec : dealItemRec.Deal_Kit_Headers__r) {
                if(dealKitHeaderRec.Is_Install__c) {
                    if(dealKHIdToDKHMap.containsKey(dealKitHeaderRec.Id)) {
                        dkhList.add(dealKHIdToDKHMap.get(dealKitHeaderRec.Id));
                        dealItemIdToServiceDKHListMap.put(dealItemRec.Id, dkhList);
                        dealItemIdToInsertDealServiceSet.add(dealItemRec.Id);
                    }
                } else {
                    if(dealKHIdToDKHMap.containsKey(dealKitHeaderRec.Id)) {
                        dealKitHeaderToAddInMerchList.add(dealKHIdToDKHMap.get(dealKitHeaderRec.Id));
                    }
                }
            }
            dealItemRec.Option_And_Fee_Status__c = Constants.COMMITTED;
        }
        
        // Insert Line Items q-4
        List<CO_Line_Item__c> coLineItemListToInsert = new List<CO_Line_Item__c>();
        List<Service_Order_Header__c> soHeaderListToInsert = new List<Service_Order_Header__c>();
        List<Service_Order_Line_Item__c> soliListToInsert = new List<Service_Order_Line_Item__c>();
        
        //Non-kit part
        for(Option_Fee__c optionAndFeeRec : merchOptionAndFeeList) {
            CO_Line_Item__c coliRec = setColiFields(optionAndFeeRec, coHeaderId, null, dealId);
            coLineItemListToInsert.add(coliRec);
        }
        /*for(Option_Fee__c optionAndFeeRec : partIdToDealMerchOptionFeeRecMap.values()) {
            CO_Line_Item__c coliRec = setColiFields(optionAndFeeRec, coHeaderId, null, dealId);
            coliRec.Related_Option_And_Fees__c = (partIdToSimilarOptionFeeRecMap.containsKey(optionAndFeeRec.Part__c)) ? 
                                                    partIdToSimilarOptionFeeRecMap.get(optionAndFeeRec.Part__c) : null;
            coLineItemListToInsert.add(coliRec);
        }*/
        
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coHeaderList = [Select CO_Type__c, Selling_Group__c from CO_Header__c where Id = :coHeaderId];
        String coType;
        if(coHeaderList.size() > 0) {
            coType = coHeaderList[0].CO_Type__c;
        }
        Integer counter = 1;
        /*
        for(String dealItemRecId : dealItemIdToDealServiceOptionAndFeeListMap.keySet()) {
            soHeaderListToInsert.add(setSOHeaderFields(dealItemRecId, coHeaderId, counter, dealId, dealIdToOptionFeeMap.get(dealItemRecId).Customer_Owned_Unit__c));
            counter++;
        }*/
        //SOHeader for all required deal items
        for(String dealItemRecId : dealItemIdToInsertDealServiceSet) {
            soHeaderListToInsert.add(setSOHeaderFields(dealItemRecId, coHeaderId, counter, dealId, dealIdToOptionFeeMap.get(dealItemRecId).Customer_Owned_Unit__c));
            counter++;
        }
        //q-7
        if(coLineItemListToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert coLineItemListToInsert;
        }
        if(soHeaderListToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert soHeaderListToInsert;
        }       
        //q-19
        //Invoice item
        
        //Map to contain DealItem id to so Header id map
        Map<String, String> dealItemIdToSOHeaderIdMap = new Map<String, String>();
        for(Service_Order_Header__c soHeaderRec : soHeaderListToInsert) {
            dealItemIdToSOHeaderIdMap.put(soHeaderRec.Deal_Item__c, soHeaderRec.Id);
        }
        
        //Insert Kit in Merch grid
        List<CO_Kit_Header__c> cokhList = new List<CO_Kit_Header__c>();
        for(Deal_Kit_Header__c dealKitHeaderRec : dealKitHeaderToAddInMerchList) {
            cokhList.add(setCOKitHeaderFields(dealKitHeaderRec, coHeaderId, dealId));
        }
        //q-19
        if(cokhList.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert cokhList;
        }
        
        //Insert invoice item for so and deal
        List<CO_Invoice_Item__c> coInvoiceItemListToInsert = new List<CO_Invoice_Item__c>();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Header__c> coInvoiceHeaderList = [Select Id, (Select Id from CO_Invoice_Items__r where Deal__c =: dealId) from CO_Invoice_Header__c where CO_Header__c = :coHeaderId AND Invoice_Status__c = 'Active'];
        if(coInvoiceHeaderList.size() == 0) {
            coInvoiceHeaderList.add(new CO_Invoice_Header__c(CO_Header__c = coHeaderId, Invoice_Status__c = 'Active'));
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert coInvoiceHeaderList;
        }
        
        Boolean isLoadingNewCO = GeneralConfiguration.isLoadNewCustomerOrder();
        
        String dealStatus = Constants.IN_PROGRESS;
        CO_Invoice_Item__c coInvoiceItem;
        if(coInvoiceHeaderList[0].CO_Invoice_Items__r.size() > 0) {
            coInvoiceItem = coInvoiceHeaderList[0].CO_Invoice_Items__r[0];
        } else {
            coInvoiceItem = new CO_Invoice_Item__c(CO_Invoice_Header__c = coInvoiceHeaderList[0].Id, isActive__c = true, Is_Invoiceable__c = false, Deal__c = dealId);
        }
        
        // Changed according to Ticket #6543 - TK
        Map<String, Boolean> optionNameToOptionValueMap = isDealInvoiceable(dealId);
        coInvoiceItem.Is_Invoiceable__c = optionNameToOptionValueMap.get('Invoiceable');
        coInvoiceItem.isActive__c = optionNameToOptionValueMap.get('Active');
        
        if(coLineItemListToInsert.size() == 0 && soHeaderListToInsert.size() == 0 && cokhList.size() == 0) {
            dealStatus = Constants.FULFILLED; 
            /*if(!isLoadingNewCO || dealItemList[0].Deal__r.Status__c == 'Approved') {
                coInvoiceItem.isActive__c = true;
                coInvoiceItem.Is_Invoiceable__c = true;
            }*/
        }
        coInvoiceItemListToInsert.add(coInvoiceItem);
        for(Service_Order_Header__c soHeaderRec :  soHeaderListToInsert){
             CO_Invoice_Item__c coInvoiceItemRec = new CO_Invoice_Item__c(CO_Invoice_Header__c = coInvoiceHeaderList[0].Id, isActive__c = true, Is_Invoiceable__c = false, Service_Order_Header__c = soHeaderRec.Id);
             coInvoiceItemListToInsert.add(coInvoiceItemRec);
        }
        if(coInvoiceItemListToInsert.size() > 0){
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            upsert coInvoiceItemListToInsert;
        }
        
        //q-20
        //Merch grid kit line item
        List<Co_Line_Item__c> coliList = new List<CO_Line_Item__c>();
        for(CO_Kit_Header__c coKitHeaderRec : cokhList) {
            if(dealKHIdToDKHMap.containsKey(coKitHeaderRec.Deal_Kit_Header__c)) {
                for(Option_Fee__c optionAndFeeRec : dealKHIdToDKHMap.get(coKitHeaderRec.Deal_Kit_Header__c).Options_Fees__r) {
                    coliList.add(setColiFields(optionAndFeeRec, coHeaderId, coKitHeaderRec.Id, dealId));
                }
            }
        }
        //q-20
        if(coliList.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Co_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert coliList;
        }
        
        if(GeneralConfiguration.getTaxIncludingPricing()) {
            Map<Id, CO_Kit_Header__c> cokhIdToCokhListMap = new Map<Id, CO_Kit_Header__c>();
            for(CO_Line_Item__c coLineItemRec : coliList) {
                
                Decimal price = 0;
                if(cokhIdToCokhListMap.containsKey(coLineItemRec.CO_Kit_Header__c)) {
                    price = (cokhIdToCokhListMap.get(coLineItemRec.CO_Kit_Header__c).Price__c != null) ? cokhIdToCokhListMap.get(coLineItemRec.CO_Kit_Header__c).Price__c : 0;
                }
                coLineItemRec.Price_When_Tax_Included__c = (coLineItemRec.Price_When_Tax_Included__c != null) ? coLineItemRec.Price_When_Tax_Included__c : 0;
                coLineItemRec.Qty__c = (coLineItemRec.Qty__c != null) ? coLineItemRec.Qty__c : 0;
                price += (coLineItemRec.Price_When_Tax_Included__c * coLineItemRec.Qty__c);
                cokhIdToCokhListMap.put(coLineItemRec.CO_Kit_Header__c, new CO_Kit_Header__c(Id = coLineItemRec.CO_Kit_Header__c, Price__c = price));
            }
            
            if(cokhIdToCokhListMap.keySet().size() > 0) {
                update cokhIdToCokhListMap.values();
            }
        }
        
        
        //q-34
        
        List<Service_Order_Kit_Header__c> sokhList = new List<Service_Order_Kit_Header__c>();
        
        //Non-kit soli and sokit header formation
        for(String dealItemRecId : dealItemIdToInsertDealServiceSet) {
            //Non kit soli
            if(dealItemIdToDealServiceOptionAndFeeListMap.containsKey(dealItemRecId)) {
                for(Option_Fee__c optionFeeRec : dealItemIdToDealServiceOptionAndFeeListMap.get(dealItemRecId)) {
                    if(dealItemIdToSOHeaderIdMap.containsKey(dealItemRecId)) {
                        soliListToInsert.add(setSoliFields(optionFeeRec, dealItemIdToSOHeaderIdMap.get(dealItemRecId), null));
                    }
                }
            }
            //so kit header
            if(dealItemIdToServiceDKHListMap.containsKey(dealItemRecId)) {
                for(Deal_Kit_Header__c dealKitHeaderRec : dealItemIdToServiceDKHListMap.get(dealItemRecId)) {
                    if(dealItemIdToSOHeaderIdMap.containsKey(dealItemRecId)) {
                        sokhList.add(setSOKitHeaderFields(dealKitHeaderRec, dealItemIdToSOHeaderIdMap.get(dealItemRecId), dealId)); 
                    }
                }
            }
        }
        //q-71
        if(sokhList.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert sokhList;
        }
        //q-71
        //so kit line item 
        for(Service_Order_Kit_Header__c soKitHeaderRec : sokhList) {
            if(dealKHIdToDKHMap.containsKey(soKitHeaderRec.Deal_Kit_Header__c)) {
                for(Option_Fee__c optionAndFeeRec : dealKHIdToDKHMap.get(soKitHeaderRec.Deal_Kit_Header__c).Options_Fees__r) {
                    soliListToInsert.add(setSoliFields(optionAndFeeRec, soKitHeaderRec.Service_Order_Header__c, soKitHeaderRec.Id));
                }
            }
        }
        
        if(soliListToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert soliListToInsert;
        }
        
        List<Option_Fee__c> optionFeeRecUpdateList = new List<Option_Fee__c>();
        for(CO_Line_Item__c coliRec: coLineItemListToInsert) {
            optionFeeRecUpdateList.add(new Option_Fee__c(Id = coliRec.Option_Fee__c, CO_Line_Item__c = coliRec.Id));
            
        }
        
        List<Option_Fee__c> optionFeeUpdateList = new List<Option_Fee__c>();
        for(CO_Line_Item__c coliRec: coLineItemListToInsert) {
            optionFeeUpdateList.add(new Option_Fee__c(Id = coliRec.Option_Fee__c, CO_Line_Item__c = coliRec.Id));
        }
        for(Service_Order_Line_Item__c soliRec: soliListToInsert) {
            optionFeeUpdateList.add(new Option_Fee__c(Id = soliRec.Option_Fee__c, Service_Order_Line_Item__c = soliRec.Id));
        }
        
        if(optionFeeUpdateList.size() > 0) {
            BPScriptUtility.disbaleTrigger('OptionAndFeeTrigger');
            update optionFeeUpdateList;
            BPScriptUtility.enableTrigger('OptionAndFeeTrigger');
        }
        
        if(GeneralConfiguration.getTaxIncludingPricing()) {
            Map<Id, Service_Order_Kit_Header__c> sokhIdToSokhListMap = new Map<Id, Service_Order_Kit_Header__c>();
            for(Service_Order_Line_Item__c soLineItemRec : soliListToInsert) {
                if(String.isNotBlank(soLineItemRec.Service_Order_Kit_Header__c)) {
                    Decimal price = 0;
                    if(sokhIdToSokhListMap.containsKey(soLineItemRec.Service_Order_Kit_Header__c)) {
                        price = (sokhIdToSokhListMap.get(soLineItemRec.Service_Order_Kit_Header__c).Fixed_Price__c != null) ? sokhIdToSokhListMap.get(soLineItemRec.Service_Order_Kit_Header__c).Fixed_Price__c : 0;
                    }
                    soLineItemRec.Price_When_Tax_Included__c = (soLineItemRec.Price_When_Tax_Included__c != null) ? soLineItemRec.Price_When_Tax_Included__c : 0;
                    soLineItemRec.Qty_Needed__c = (soLineItemRec.Qty_Needed__c != null) ? soLineItemRec.Qty_Needed__c : 0;
                    price += (soLineItemRec.Price_When_Tax_Included__c * soLineItemRec.Qty_Needed__c);
                    
                    sokhIdToSokhListMap.put(soLineItemRec.Service_Order_Kit_Header__c, new Service_Order_Kit_Header__c(Id = soLineItemRec.Service_Order_Kit_Header__c, Fixed_Price__c = price));
                }
                
            }
            
            if(sokhIdToSokhListMap.keySet().size() > 0) {
                update sokhIdToSokhListMap.values();
            }
        }
        
        if(AccessControl.ifObjectFieldIsUpdateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<SObject> sObjectListToUpdate = new List<SObject>((List<SObject>)dealItemList);
        
        Deal__c dealRec = new Deal__c(Id = dealId, Unit_Status__c = Constants.COMMITTED);
        
        if(isLoadingNewCO) {
            dealRec.Is_Deal_Fulfilled__c = (dealStatus == Constants.FULFILLED) ? true : false;
        } else {
            dealRec.Status__c = dealStatus;
        }
        sObjectListToUpdate.addAll((List<SObject>)(new List<Deal__c>{dealRec}));
        
        List<Customer_Owned_Unit__c> couList = [Select Status__c from Customer_Owned_Unit__c where Id In :couIdSet];
        for(Customer_Owned_Unit__c couRec : couList) {
            if(couRec.Status__c != Constants.ON_ORDER_STATUS) {
                couRec.Status__c = Constants.UNIT_STATUS_RESERVED;
            }
        }
        sObjectListToUpdate.addAll((List<SObject>)couList);
        update sObjectListToUpdate;
        
        //OptionAndFeeTriggerHelper.updateDealTotal(new Set<String>{dealId});
        return getDealDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('dealMerchandise'));
    }
    
    public static CO_Line_Item__c setColiFields(Option_Fee__c optionAndFeeRec, String coHeaderId, String cokhId, String dealId) {
        CO_Line_Item__c coliRec = new CO_Line_Item__c();
        coliRec.Qty__c = (optionAndFeeRec.Qty__c == null) ? 1 : optionAndFeeRec.Qty__c;
        coliRec.Item_Code__c = optionAndFeeRec.Item_Code__c;
        coliRec.Item_Description__c = optionAndFeeRec.Item_Description__c;
        coliRec.Deal__c = dealId;
        coliRec.Kit_Header_Line_Item__c = optionAndFeeRec.Kit_Header_Line_Item__c;
        coliRec.Option_Fee__c = optionAndFeeRec.Id;
        coliRec.Part__c = optionAndFeeRec.Part__c;
        coliRec.CO_Header__c = coHeaderId;
        coliRec.Fee__c = optionAndFeeRec.Fee__c;
        coliRec.Related_Option_And_Fees__c = optionAndFeeRec.Id;
        coliRec.Price__c = optionAndFeeRec.Price__c;
        coliRec.Price_When_Tax_Included__c = optionAndFeeRec.Price__c;
        coliRec.Actual_Kit_Price__c = optionAndFeeRec.Price__c;
        
        if(cokhId != null) {
            coliRec.CO_Kit_Header__c = cokhId;
            coliRec.Fixed_Price__c = optionAndFeeRec.Is_Fixed_Price__c;
            coliRec.Actual_Kit_Price__c = optionAndFeeRec.Actual_Kit_Price__c;
        }            
        return coliRec;
    }
    
    public static Service_Order_Header__c setSOHeaderFields(String dealItemRecId, String coHeaderId, Integer counter, String dealId, String unitId) {
        Service_Order_Header__c soHeaderToInsert = new Service_Order_Header__c();
        soHeaderToInsert.Name__c = 'Deal Service ' + counter;
        soHeaderToInsert.CO_Header__c = coHeaderId;
        soHeaderToInsert.Status__c = 'New';
        soHeaderToInsert.Work_Status__c = 'New';
        soHeaderToInsert.SO_Concern__c = CONSTANTS.INSTALL_DEAL_OPTION;
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coHeaderList = [Select CO_Type__c, Selling_Group__c from CO_Header__c where Id = :coHeaderId];
        String coType;
        if(coHeaderList.size() > 0) {
            soHeaderToInsert.SO_Type__c = coHeaderList[0].CO_Type__c;
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Transaction_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Transaction_Type__c> ttList = [Select Code__c, Code_Label__c from Transaction_Type__c where Type__c = 'Deal Service' AND Default__c = true];
        if(ttList.size() > 0) {
            soHeaderToInsert.Transaction_Type__c = ttList[0].Id;
        }
        
        soHeaderToInsert.Customer_Owned_Unit__c = unitId;
        soHeaderToInsert.Deal__c = dealId;
        soHeaderToInsert.Deal_Item__c = dealItemRecId;
        soHeaderToInsert.SO_Type__c = 'Deal';
        return soHeaderToInsert;
    }
    
    public static Service_Order_Line_Item__c setSoliFields(Option_Fee__c optionAndFeeRec, String soHeaderId, String sokhRecId) {
        Service_Order_Line_Item__c soliToInsert = new Service_Order_Line_Item__c();
        soliToInsert.Qty_Needed__c = optionAndFeeRec.Qty__c;
        soliToInsert.Item_Code__c = optionAndFeeRec.Item_Code__c;
        soliToInsert.Item_Description__c = optionAndFeeRec.Item_Description__c;
        soliToInsert.Deal__c = optionAndFeeRec.Deal__c;
        soliToInsert.Kit_Header_Line_Item__c = optionAndFeeRec.Kit_Header_Line_Item__c;
        soliToInsert.Deal_Item__c = optionAndFeeRec.Deal_Item__c;
        soliToInsert.Option_Fee__c = optionAndFeeRec.Id;
        soliToInsert.Part__c = optionAndFeeRec.Part__c;
        soliToInsert.Labour_Code__c = optionAndFeeRec.Labour_Code__c;
        soliToInsert.Service_Order_Header__c = soHeaderId;
        soliToInsert.Kit_Price__c = optionAndFeeRec.Price__c;
        soliToInsert.Price_When_Tax_Included__c = optionAndFeeRec.Price__c;
        soliToInsert.Sublet__c = optionAndFeeRec.Product__c;
        
        if(sokhRecId != null) {
            soliToInsert.Service_Order_Kit_Header__c = sokhRecId;
            soliToInsert.Fixed_Price__c = optionAndFeeRec.Is_Fixed_Price__c;
            soliToInsert.Is_Fixed_Kit_LineItem_SO__c = optionAndFeeRec.Is_Fixed_Kit_Line_Item_CO__c;
            soliToInsert.Fee__c = optionAndFeeRec.Fee__c;
            soliToInsert.Tax_Percent__c = (optionAndFeeRec.Sales_Tax_Percentage__c != null) ? optionAndFeeRec.Sales_Tax_Percentage__c : 0;
            soliToInsert.Actual_Kit_Price__c = optionAndFeeRec.Actual_Kit_Price__c;
        }
        return soliToInsert;
    }
    
    public static CO_Kit_Header__c setCOKitHeaderFields(Deal_Kit_Header__c dkhRec, String coHeaderId, String dealId) {
        CO_Kit_Header__c cokhRec = new CO_Kit_Header__c();
        cokhRec.CO_Header__c = coHeaderId;
        cokhRec.Deal__c = dealId;
        cokhRec.Kit_Header__c = dkhRec.Kit_Header__r.Id;
        cokhRec.Price__c = dkhRec.Fixed_Price__c;
        cokhRec.Actual_Kit_Price__c = dkhRec.Actual_Kit_Price__c;
        cokhRec.Can_Split__c = dkhRec.Can_Split__c;
        cokhRec.Fixed_Price_Flag__c = dkhRec.Is_Fixed_Price__c;
        cokhRec.Service_Kit__c = dkhRec.Service_Kit__c;
        cokhRec.Deal_Kit_Header__c = dkhRec.Id;
        cokhRec.CO_Fixed_KitHeader__c = dkhRec.Is_Fixed_Kit_Header_CO__c;
        
        return cokhRec;
    }
    
    public static Service_Order_Kit_Header__c setSOKitHeaderFields(Deal_Kit_Header__c dkhRec, String soHeaderId, String dealId) {
        Service_Order_Kit_Header__c sokhRec = new Service_Order_Kit_Header__c();
        sokhRec.Service_Order_Header__c = soHeaderId;
        sokhRec.Kit_Header__c = dkhRec.Kit_Header__r.Id;
        sokhRec.Can_Split__c = dkhRec.Can_Split__c;
        sokhRec.Code__c = dkhRec.Code__c;
        sokhRec.Description__c = dkhRec.Description__c;
        sokhRec.Fixed_Price__c = dkhRec.Fixed_Price__c;
        sokhRec.Fixed_Price_Flag__c = dkhRec.Is_Fixed_Price__c;
        sokhRec.Is_Fixed_Kit_Header_SO__c = dkhRec.Is_Fixed_Kit_Header_CO__c;
        sokhRec.Service_Kit__c = dkhRec.Service_Kit__c;
        sokhRec.Actual_Kit_Price__c = dkhRec.Fixed_Price__c;
        sokhRec.Deal_Kit_Header__c = dkhRec.Id;
        sokhRec.Deal_Item__c = dkhRec.Deal_Item__c;
        sokhRec.Deal__c = dealId;
        
        return sokhRec;
    }
    
    @RemoteAction
    global static String moveDealMerchAndServiceLineItems(String optionFeeRecId, String coHeaderId) {
        optionFeeRecId = BPUtility.getDecodedString(optionFeeRecId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        Savepoint sp = Database.setSavepoint();
        try {
            String objectName = (Id.valueOf(optionFeeRecId)).getSObjectType().getDescribe().getName();
            if(objectName == Constants.NAMESPACE + 'Deal_Kit_Header__c') {
                moveDealKit(optionFeeRecId, coHeaderId);
            } else if(objectName == Constants.NAMESPACE + 'Option_Fee__c') {
                moveOptionAndFeeLineItem(optionFeeRecId, coHeaderId);
            }
        } catch(Exception e) {
            Database.rollback(sp);
            system.assert(false, e);
        }
        return getDealDetails(BPUtility.getEncodedString(coHeaderId), null);
    }
    
    private static void moveOptionAndFeeLineItem(String optionFeeRecId, String coHeaderId) {
        List<Option_Fee__c> optionAndFeeList = SOQLUtil.getOptionAndFeeRecord(new Map<String, String>{'Id' => optionFeeRecId});
        if(optionAndFeeList.size() == 0) {
            return;
        }
        List<Sobject> sobjectList = new List<Sobject>();
        Option_Fee__c optionFeeRec = optionAndFeeList[0];
        
        //Added by nidhi - 27-11-2016
        /*Boolean dealMerchLineItemExist = false;
        List<Sobject> sobjectListToUpdate = new List<Sobject>();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Line_Item__c> coliList = [Select Qty__c, Part__c, Option_Fee__c, Related_Option_And_Fees__c from CO_Line_Item__c where Deal__c = :optionAndFeeList[0].Deal__c];
        for(CO_Line_Item__c coliRec : coliList) {
            if(String.isNotBlank(coliRec.Related_Option_And_Fees__c)) {
                Set<String> optionAndFeeIdSet = new Set<String>(coliRec.Related_Option_And_Fees__c.split(';'));
                if(optionAndFeeIdSet.contains(optionFeeRecId)) {
                    if(coliRec.Qty__c == optionAndFeeList[0].Qty__c) {
                        sobjectList.add(coliRec);
                    } else {
                        coliRec.Qty__c -= optionAndFeeList[0].Qty__c;
                        optionAndFeeIdSet.remove(optionFeeRecId);
                        coliRec.Related_Option_And_Fees__c = string.join((new List<String>(optionAndFeeIdSet)),';');
                        sobjectListToUpdate.add(coliRec);
                        break;
                    }
                } else {
                    if(!optionAndFeeList[0].Is_Install__c && String.isNotBlank(optionAndFeeList[0].Part__c) && optionAndFeeList[0].Part__c == coliRec.Part__c) {
                        coliRec.Qty__c += optionAndFeeList[0].Qty__c;
                        coliRec.Related_Option_And_Fees__c += ';'+optionAndFeeList[0].Id;
                        sobjectListToUpdate.add(coliRec);
                        dealMerchLineItemExist = true;
                        break;
                    }
                }
            }
        }
        if(sobjectListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update sobjectListToUpdate;
        }*/

        if(optionFeeRec.CO_Line_Items__r.size() > 0 ) {
            sobjectList.add(optionFeeRec.CO_Line_Items__r);
        }

        if(optionFeeRec.Service_Order_Line_Items__r.size() > 0 ) {
            sobjectList.add(optionFeeRec.Service_Order_Line_Items__r);
            Set<Id> soIdSet = new Set<Id>();
            for(Service_Order_Line_Item__c soliRec : optionFeeRec.Service_Order_Line_Items__r) {
                soIdSet.add(soliRec.Service_Order_Header__c);
            }
            
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Header__c> soHeaderList = [select Deal_Item__c, (select Id from Service_Order_Line_Items__r), (select Id from CO_Invoice_Items__r) 
                                                            from Service_Order_Header__c where Id IN: soIdSet];
            
            if(soHeaderList.size() > 0) {
                for(Service_Order_Header__c soHeaderRec : soHeaderList) {
                    if(soHeaderRec.Service_Order_Line_Items__r.size() == 1) {
                        sobjectList.add(soHeaderRec);
                        sobjectList.add(soHeaderRec.CO_Invoice_Items__r);
                    }
                }
            } 
        }
        
        if(sobjectList.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(AccessControl.ifObjectIsDeletable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete sobjectList;
        }
        
        if(optionFeeRec.Part__c != null || optionFeeRec.Labour_Code__c != null) {
            if(!optionFeeRec.Is_Install__c) {
                if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                insert setColiFields(optionFeeRec, coHeaderId, null, optionAndFeeList[0].Deal__c);
            } else {
                if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Service_Order_Header__c> soHeaderList = [select Deal_Item__c from Service_Order_Header__c where Deal__c =: optionFeeRec.Deal_Item__r.Deal__c];
                Map<Id, Service_Order_Header__c> dealItemIdToSOHeaderRecMap = new Map<Id, Service_Order_Header__c>();
                for(Service_Order_Header__c soHeaderRec : soHeaderList) {
                    dealItemIdToSOHeaderRecMap.put(soHeaderRec.Deal_Item__c, soHeaderRec);
                }
                dealItemIdToSOHeaderRecMap.remove(null);
                
                Service_Order_Header__c soHeaderRec;
                if(!dealItemIdToSOHeaderRecMap.containsKey(optionFeeRec.Deal_Item__c)) {
                    soHeaderRec = setSOHeaderFields(optionFeeRec.Deal_Item__c, coHeaderId, dealItemIdToSOHeaderRecMap.keySet().size() + 1, optionFeeRec.Deal_Item__r.Deal__c,
                                                    optionFeeRec.Deal_Item__r.Customer_Owned_Unit__c);
                    if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                    insert soHeaderRec;
                } else {
                    soHeaderRec = dealItemIdToSOHeaderRecMap.get(optionFeeRec.Deal_Item__c);
                }
                if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                insert setSoliFields(optionFeeRec, soHeaderRec.Id, null);
            } 
        }
    }
    
    private static void moveDealKit(String dealKHId, String coHeaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Deal_Kit_Header__c> dealkhList = SOQLUtil.getDealKitHeaderByFieldName(new Map<String, String>{'Id' => dealKHId});
        if(dealkhList.size() == 0) {
            return;
        }
        List<Sobject> sobjectList = new List<Sobject>();
        Set<Id> soIdSet = new Set<Id>();
            
        if((dealkhList[0].CO_Kit_Headers__r).size() > 0) {
            List<CO_Kit_Header__c> cokhList = [Select Id, (Select Id from CO_Line_Items__r), (select Id from CO_Invoice_Items__r) from CO_Kit_Header__c where Deal_Kit_Header__c =: dealKHId];
            if(cokhList.size() > 0) {
                for(CO_Kit_Header__c cokhRec : cokhList) {
                    sobjectList.addAll((List<Sobject>) cokhRec.CO_Line_Items__r);
                    sobjectList.addAll((List<Sobject>) cokhRec.CO_Invoice_Items__r);
                }
            }
            sobjectList.addAll((List<Sobject>) cokhList);
        }
        if((dealkhList[0].Service_Order_Kit_Headers__r).size() > 0) {
            List<Service_Order_Kit_Header__c> sokhList = [Select Id, Service_Order_Header__c, (Select Id from Service_Order_Line_Items__r) from Service_Order_Kit_Header__c where Deal_Kit_Header__c =: dealKHId];
            if(sokhList.size() > 0) {
                for(Service_Order_Kit_Header__c sokhRec : sokhList) {
                    soIdSet.add(sokhRec.Service_Order_Header__c);
                    sobjectList.addAll((List<Sobject>) sokhRec.Service_Order_Line_Items__r);
                }
                sobjectList.addAll((List<Sobject>) sokhList);
            }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Header__c> soHeaderList = [select Deal_Item__c, (select Id from Service_Order_Line_Items__r where Service_Order_Kit_Header__c = null), (select Id from Service_Order_Kit_Headers__r), (select Id from CO_Invoice_Items__r) 
                                                            from Service_Order_Header__c where Id IN: soIdSet];
            
            if(soHeaderList.size() > 0) {
                for(Service_Order_Header__c soHeaderRec : soHeaderList) {
                    if(soHeaderRec.Service_Order_Kit_Headers__r.size() == 1) {
                        sobjectList.add((SObject) soHeaderRec);
                        sobjectList.add((SObject) soHeaderRec.CO_Invoice_Items__r);
                    }
                }
            }
        }
        
        if(sobjectList.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(AccessControl.ifObjectIsDeletable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(AccessControl.ifObjectIsDeletable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            if(AccessControl.ifObjectIsDeletable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete sobjectList;
        }
        
        if(!dealkhList[0].Is_Install__c) {
            CO_Kit_Header__c cokhRec = setCOKitHeaderFields(dealkhList[0], coHeaderId, dealkhList[0].Deal_Item__r.Deal__c);
            
            if(cokhRec != null) {
                if(AccessControl.ifObjectFieldIsCreateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                insert cokhRec;
            }
            List<Co_Line_Item__c> coliList = new List<CO_Line_Item__c>();
            for(Option_Fee__c optionAndFeeRec : dealkhList[0].Options_Fees__r) {
                coliList.add(setColiFields(optionAndFeeRec, coHeaderId, cokhRec.Id, dealkhList[0].Deal_Item__r.Deal__c));
            }
            if(coliList.size() > 0) {
                if(AccessControl.ifObjectFieldIsCreateable('Co_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                insert coliList;
            }
            //COKH_Recalcualtion.CoKitInsert(cokhRec.Id, coHeaderId);
            COKH_Recalcualtion.calculatePriceForCOKitInsertion(cokhRec.Id, coHeaderId);
        } else {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Header__c> soHeaderList = [select Deal_Item__c from Service_Order_Header__c where Deal__c =: dealkhList[0].Deal_Item__r.Deal__c];
            Map<Id, Service_Order_Header__c> dealItemIdToSOHeaderRecMap = new Map<Id, Service_Order_Header__c>();
            for(Service_Order_Header__c soHeaderRec : soHeaderList) {
                dealItemIdToSOHeaderRecMap.put(soHeaderRec.Deal_Item__c, soHeaderRec);
            }
            dealItemIdToSOHeaderRecMap.remove(null);
            
            Service_Order_Header__c soHeaderRec;
            if(!dealItemIdToSOHeaderRecMap.containsKey(dealkhList[0].Deal_Item__c)) {
                soHeaderRec = setSOHeaderFields(dealkhList[0].Deal_Item__c, coHeaderId, dealItemIdToSOHeaderRecMap.keySet().size() + 1, dealkhList[0].Deal_Item__r.Deal__c,
                                                dealkhList[0].Deal_Item__r.Customer_Owned_Unit__c);
                if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                insert soHeaderRec;
            } else {
                soHeaderRec = dealItemIdToSOHeaderRecMap.get(dealkhList[0].Deal_Item__c);
            }
            if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            
            Service_Order_Kit_Header__c sokhRec = setSOKitHeaderFields(dealkhList[0], soHeaderRec.Id, dealkhList[0].Deal_Item__r.Deal__c); 
            
            if(sokhRec != null) {
                if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                insert sokhRec;
                
                List<Service_Order_Line_Item__c> soliList = new List<Service_Order_Line_Item__c>();
                for(Option_Fee__c optionAndFeeRec : dealkhList[0].Options_Fees__r) {
                    soliList.add(setSoliFields(optionAndFeeRec, soHeaderRec.Id, sokhRec.Id));
                }
                if(soliList.size() > 0) {
                    insert soliList;
                }
                //SO_KLI_Recalculation.SOPriceCalcultaionByPriceLevelForSOKitHeaders(dealkhList[0].Deal_Item__r.Deal__r.CO_Header__r.Customer__c, coHeaderId, new List<Id>{sokhRec.Id}, soHeaderRec.Id);
            	SO_KLI_Recalculation.soKitPriceCalculation(new Set<Id>{sokhRec.Id}, new Set<Id>{soHeaderRec.Id}, coHeaderId);
            }
        }
    }
    
    public static void updateStatusForDeal(String dealId) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Item__c> dealItemList = [Select Id, Deal__r.Status__c, Customer_Owned_Unit__c, Unit_Make__c from Deal_Item__c where Deal__c = :dealId AND Type__c = :Constants.DEAL_ITEM_TYPE_UNIT];
        
         if(AccessControl.ifObjectFieldIsUpdateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update getDealWithUpdatedStatus(dealId, dealItemList);
    }
    
    public static Deal__c getDealWithUpdatedStatus(String dealId, List<Deal_Item__c> dealItemList) {
        String dealStatus = (dealItemList.size() == 0) ? 'Quotation' : dealItemList[0].Deal__r.Status__c;
        String status = (dealItemList.size() == 0 || dealItemList[0].Deal__r.Status__c == 'Quotation') ? Constants.TEMPORARY : Constants.COMMITTED;
        
        if(dealItemList.size() > 0) {
        	Boolean isTempUnitExist = false;
	        for(Deal_Item__c dealItemRec : dealItemList) {
        		if(String.isBlank(dealItemRec.Customer_Owned_Unit__c)) {
	        		isTempUnitExist = true;
	        		break;
	        	}
	        }
	        
	        if(!isTempUnitExist) {
	            status = Constants.UNCOMIITTED;
	            dealStatus = 'Quotation';
	        }
        }
        
        return new Deal__c(Id = dealId, Status__c = dealStatus, Unit_Status__c = status);
    }
    
   /**Ticket #1284 04/11/2016 Subhrant singh
     * Name: getMakeList
     * Desc: To get Make List
     * @param: 0
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction 
    global static String getMakeList() {
        List<Unit_Make__c> unitMakeList = SOQLUtil.getUnitMake();
        List<UnitMake> unitmakeItemList = new List<UnitMake>();
        for(Unit_Make__c unitmakerec : unitMakeList  ){
            UnitMake ObjMake = new UnitMake(unitmakerec);
            unitmakeItemList.add(ObjMake );
        }
        return BPUtility.getEncodedString(System.JSON.serialize(unitmakeItemList));
    }
    
    /**Ticket #1284 04/11/2016 Subhrant singh
     * Name: getModelList   
     * Desc: To get Make List
     * @param: 0
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction 
    global static String getModelList(String MakeId) {
        MakeId = BPUtility.getDecodedString(MakeId);
        List<Unit_Model__c> unitModelList = SOQLUtil.getUnitModel(MakeId);
        List<UnitModel> unitModelItemList = new List<UnitModel>();
        Set<String> UnitModelKey = new Set<String>(); 
        for(Unit_Model__c unitModelrec : unitModelList  ){
            if(UnitModelKey.contains(unitModelrec.Name__c)){
            
            }else{
                UnitModelKey.add(unitModelrec.Name__c);
                UnitModel objUnitModel = new UnitModel(unitModelrec);
                unitModelItemList.add(objUnitModel );
            }  
        }  
        return BPUtility.getEncodedString(System.JSON.serialize(unitModelItemList));
    }
    
     /** 
     * Name: getRelatedCustomerByCustomerId
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String getSubModelList(String ModelName,String MakeId) {
        ModelName = BPUtility.getDecodedString(ModelName);
        MakeId = BPUtility.getDecodedString(MakeId);
        List<Unit_Sub_Model__c> unitSubModelList = SOQLUtil.getUnitSubModel( ModelName, MakeId) ;
        List<UnitSubModel> unitSubModelItemList = new List<UnitSubModel>();
        for(Unit_Sub_Model__c unitSubModelrec : unitSubModelList  ){
                UnitSubModel objSubUnitModel = new UnitSubModel(unitSubModelrec);
                unitSubModelItemList.add(objSubUnitModel );
        }  
        return BPUtility.getEncodedString(System.JSON.serialize(unitSubModelItemList));
    }
    
    /*private static void createDealUnresolvedFulfillment(String lineItemId, String DealId, String actionType) {
        Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec;
        
        if(String.isBlank(lineItemId)) {
            return;
        }
        if(String.isBlank(DealId)) {
            return;
        }
        
        if(actionType == Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED) {
            dealUnresolvedFulfillmentRec = createUnresolvedFulfillmentWhenAdded(lineItemId);
        } else if(actionType == Constants.UNRESOLVED_FULFILLMENT_TYPE_UPDATED) {
            dealUnresolvedFulfillmentRec = createUnresolvedFulfillmentWhenUpdated(lineItemId);
        } else if(actionType == Constants.UNRESOLVED_FULFILLMENT_TYPE_REMOVED) {
            dealUnresolvedFulfillmentRec = createUnresolvedFulfillmentWhenRemoved(lineItemId);
        }
        if(dealUnresolvedFulfillmentRec != null) {
            dealUnresolvedFulfillmentRec = setFieldsForUnresolvedFulfillment(new List<Deal_Unresolved_Fulfillment__c> {dealUnresolvedFulfillmentRec}, actionType);
            
            if(AccessControl.ifObjectFieldIsCreateable('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert dealUnresolvedFulfillmentRec;
            
            if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Deal_Unresolved_Fulfillment__c> unresolvedFulfillmentList = [Select CO_Line_Item__c, Service_Order_Line_Item__r.Service_Order_Header__c, CO_Kit_Header__c, Service_Order_Kit_Header__r.Service_Order_Header__c from Deal_Unresolved_Fulfillment__c where Id = :dealUnresolvedFulfillmentRec.Id];
            if(unresolvedFulfillmentList.size() > 0) {
                if(String.isNotBlank(unresolvedFulfillmentList[0].CO_Line_Item__c)) {
                    updateUnresolvedCOLIForCheckout(unresolvedFulfillmentList[0].CO_Line_Item__c, false);
                } else if(String.isNotBlank(unresolvedFulfillmentList[0].Service_Order_Line_Item__c)) {
                    updateUnresolvedSOHeaderForCheckout(unresolvedFulfillmentList[0].Service_Order_Line_Item__r.Service_Order_Header__c, false);
                } else if(String.isNotBlank(unresolvedFulfillmentList[0].CO_Kit_Header__c)) {
                    updateUnresolvedCOKHForCheckout(unresolvedFulfillmentList[0].CO_Kit_Header__c, false);
                } else if(String.isNotBlank(unresolvedFulfillmentList[0].Service_Order_Kit_Header__c)) {
                    updateUnresolvedSOKHForCheckout(unresolvedFulfillmentList[0].Service_Order_Kit_Header__r.Service_Order_Header__c, false);
                }
            }
        }
    }*/
    
    public static void createDealUnresolvedFulfillment(List<String> lineItemIdList, String DealId, String actionType) {
        List<Deal_Unresolved_Fulfillment__c> dealUnresolvedFulfillmentRecList = new List<Deal_Unresolved_Fulfillment__c>();
        
        if(lineItemIdList == null || lineItemIdList.size() <= 0) {
            return;
        }
        if(String.isBlank(DealId)) {
            return;
        }
        
        Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec; 
        if(actionType == Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED) {
            dealUnresolvedFulfillmentRecList = createUnresolvedFulfillmentWhenAdded(lineItemIdList);
        } else if(actionType == Constants.UNRESOLVED_FULFILLMENT_TYPE_UPDATED) {
            dealUnresolvedFulfillmentRec = createUnresolvedFulfillmentWhenUpdated(lineItemIdList[0]);
        } else if(actionType == Constants.UNRESOLVED_FULFILLMENT_TYPE_REMOVED) {
            dealUnresolvedFulfillmentRec = createUnresolvedFulfillmentWhenRemoved(lineItemIdList[0]);
        }
        
        if(dealUnresolvedFulfillmentRec != null) {
            dealUnresolvedFulfillmentRecList.add(dealUnresolvedFulfillmentRec);
        }
        
        if(dealUnresolvedFulfillmentRecList != null && dealUnresolvedFulfillmentRecList.size() > 0) {
            dealUnresolvedFulfillmentRecList = setFieldsForUnresolvedFulfillment(dealUnresolvedFulfillmentRecList, actionType);
            
            if(AccessControl.ifObjectFieldIsCreateable('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert dealUnresolvedFulfillmentRecList;
            
            //system.assert(false,[Select id from Service_Order_Line_Item__c where Id =: dealUnresolvedFulfillmentRecList[0].Service_Order_Line_Item__c]);
            Set<String> unresolvedRecIdSet = new Set<String>();
            for(Deal_Unresolved_Fulfillment__c unresolvedFulfillmentRec : dealUnresolvedFulfillmentRecList) {
                unresolvedRecIdSet.add(unresolvedFulfillmentRec.Id);
            }
            
            if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Deal_Unresolved_Fulfillment__c> unresolvedFulfillmentList = [Select CO_Line_Item__c, Service_Order_Line_Item__r.Service_Order_Header__c, CO_Kit_Header__c, Service_Order_Kit_Header__r.Service_Order_Header__c from Deal_Unresolved_Fulfillment__c where Id IN :unresolvedRecIdSet];
            if(unresolvedFulfillmentList.size() > 0) { 
                
                if(String.isNotBlank(unresolvedFulfillmentList[0].CO_Line_Item__c)) {
                    
                    Map<String, Boolean> lineItemIdToIsResolvingRecMap = new Map<String, Boolean>();
                    for(Deal_Unresolved_Fulfillment__c unresolvedRec : unresolvedFulfillmentList) {
                        lineItemIdToIsResolvingRecMap.put(unresolvedRec.CO_Line_Item__c, false);
                    }
                    
                    updateUnresolvedCOLIForCheckout(lineItemIdToIsResolvingRecMap);
                } else if(String.isNotBlank(unresolvedFulfillmentList[0].Service_Order_Line_Item__c)) {
                    
                    Map<String, Boolean> lineItemIdToIsResolvingRecMap = new Map<String, Boolean>();
                    for(Deal_Unresolved_Fulfillment__c unresolvedRec : unresolvedFulfillmentList) {
                        lineItemIdToIsResolvingRecMap.put(unresolvedRec.Service_Order_Line_Item__r.Service_Order_Header__c, false);
                    }
                    updateUnresolvedSOHeaderForCheckout(lineItemIdToIsResolvingRecMap);
                    
                } else if(String.isNotBlank(unresolvedFulfillmentList[0].CO_Kit_Header__c)) {
                    Map<String, Boolean> lineItemIdToIsResolvingRecMap = new Map<String, Boolean>();
                    for(Deal_Unresolved_Fulfillment__c unresolvedRec : unresolvedFulfillmentList) {
                        lineItemIdToIsResolvingRecMap.put(unresolvedRec.CO_Kit_Header__c, false);
                    }
                    updateUnresolvedCOKHForCheckout(lineItemIdToIsResolvingRecMap);
                } else if(String.isNotBlank(unresolvedFulfillmentList[0].Service_Order_Kit_Header__c)) {
                    Map<String, Boolean> lineItemIdToIsResolvingRecMap = new Map<String, Boolean>();
                    for(Deal_Unresolved_Fulfillment__c unresolvedRec : unresolvedFulfillmentList) {
                        lineItemIdToIsResolvingRecMap.put(unresolvedRec.Service_Order_Kit_Header__r.Service_Order_Header__c, false);
                    }
                    updateUnresolvedSOKHForCheckout(lineItemIdToIsResolvingRecMap);
                }
                updateDealInvoiceItem(DealId);
            }
        }
    }
    
    private static void updateDealInvoiceItem(String dealId) {
        List<CO_Invoice_Item__c> dealInvoiceItemList = [SELECT isActive__c, Is_Invoiceable__c FROM CO_Invoice_Item__c 
                                                            WHERE Deal__c =: dealId AND Deal_Finance__c = null];
	    Map<String, Boolean> optionNameToOptionValueMap = isDealInvoiceable(dealId);
	    dealInvoiceItemList[0].Is_Invoiceable__c = optionNameToOptionValueMap.get('Invoiceable');
	    dealInvoiceItemList[0].isActive__c = optionNameToOptionValueMap.get('Active');
	    update dealInvoiceItemList[0];
    }
        
    private static void updateUnresolvedCOLIForCheckout(String coliId, Boolean isResolving) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        CO_Line_Item__c coliRec = new CO_Line_Item__c(Id = coliId);
        if(isResolving) {
            List<CO_Line_Item__c> coliList = [Select Is_Unresolved_Fulfillment_Exists__c, (Select Is_Resolved__c from Deal_Unresolved_Fulfillments__r) from CO_Line_Item__c where Id = :coliId];
            if(coliList.size() > 0) {
                for(Deal_Unresolved_Fulfillment__c unresolvedFulfillment : coliList[0].Deal_Unresolved_Fulfillments__r) {
                    if(!unresolvedFulfillment.Is_Resolved__c) {
                        return;
                    }
                }
            }
            coliRec.Is_Unresolved_Fulfillment_Exists__c = false;
        } else {
            coliRec.Is_Unresolved_Fulfillment_Exists__c = true;
        }
        if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        update coliRec;
    }
    
    private static void updateUnresolvedCOLIForCheckout(Map<String, Boolean> coliIdToIsResolvingMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<CO_Line_Item__c> coliList = [Select Is_Unresolved_Fulfillment_Exists__c, (Select Is_Resolved__c from Deal_Unresolved_Fulfillments__r) from CO_Line_Item__c where Id IN :coliIdToIsResolvingMap.keySet()];
        List<CO_Line_Item__c> coliListToUpdate = new List<CO_Line_Item__c>();
        for(CO_Line_Item__c coliRec : coliList) {
            if(coliIdToIsResolvingMap.containsKey(coliRec.Id) && coliIdToIsResolvingMap.get(coliRec.Id)) {
                 Boolean isUnresolvedFulfillmentExists = false;
                 for(Deal_Unresolved_Fulfillment__c unresolvedFulfillment : coliRec.Deal_Unresolved_Fulfillments__r) {
                    if(!unresolvedFulfillment.Is_Resolved__c) {
                        isUnresolvedFulfillmentExists = true;
                        break;
                    }
                }
                if(!isUnresolvedFulfillmentExists) {
                    coliRec.Is_Unresolved_Fulfillment_Exists__c = false;
                }
            } else {
                coliRec.Is_Unresolved_Fulfillment_Exists__c = true;
            }
            coliListToUpdate.add(coliRec);
        }
        
        if(coliListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update coliListToUpdate;
        }
    }
    
    private static void updateUnresolvedSOHeaderForCheckout(String soHeaderId, Boolean isResolving) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderId);
        if(isResolving) {
            List<Service_Order_Line_Item__c> soliList = [Select Id, (Select Is_Resolved__c from Deal_Unresolved_Fulfillments__r) from Service_Order_Line_Item__c where Service_Order_Header__c = :soHeaderId];
            for(Service_Order_Line_Item__c soliRec : soliList) {
                for(Deal_Unresolved_Fulfillment__c unresolvedFulfillment : soliRec.Deal_Unresolved_Fulfillments__r) {
                    if(!unresolvedFulfillment.Is_Resolved__c) {
                        return;
                    }
                }
            }
            soHeaderRec.Is_Unresolved_Fulfillment_Exists__c = false;
        } else {
            soHeaderRec.Is_Unresolved_Fulfillment_Exists__c = true;
        }
        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update soHeaderRec;
    }
    
    private static void updateUnresolvedSOHeaderForCheckout(Map<String, Boolean> soHeaderIdToIsResolvingMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        Map<String, List<Service_Order_Line_Item__c>> soIdToSOLIRecMap = new Map<String, List<Service_Order_Line_Item__c>>();
        for(Service_Order_Line_Item__c soliRec : [Select Id, Service_Order_Header__c, (Select Is_Resolved__c from Deal_Unresolved_Fulfillments__r) 
                                                from Service_Order_Line_Item__c where Service_Order_Header__c In :soHeaderIdToIsResolvingMap.keySet()]) {
            if(!soIdToSOLIRecMap.containsKey(soliRec.Service_Order_Header__c)) {
                soIdToSOLIRecMap.put(soliRec.Service_Order_Header__c, new List<Service_Order_Line_Item__c>());
            }
            soIdToSOLIRecMap.get(soliRec.Service_Order_Header__c).add(soliRec);
        }
        
        List<Service_Order_Header__c> soHeaderListToUpdate = new List<Service_Order_Header__c>();
        for(String soHeaderId : soHeaderIdToIsResolvingMap.keySet()) {
            if(soHeaderIdToIsResolvingMap.get(soHeaderId)) {
                Boolean isUnresolvedFulfillmentExists = false;
                if(soIdToSOLIRecMap.containsKey(soHeaderId)) {
                    for(Service_Order_Line_Item__c soliRec : soIdToSOLIRecMap.get(soHeaderId)) {
                        for(Deal_Unresolved_Fulfillment__c unresolvedFulfillment : soliRec.Deal_Unresolved_Fulfillments__r) {
                            if(!unresolvedFulfillment.Is_Resolved__c) {
                                isUnresolvedFulfillmentExists = true;
                                break;
                            }
                        }
                    }
                }
                if(!isUnresolvedFulfillmentExists) {
                    soHeaderListToUpdate.add(new Service_Order_Header__c(Id = soHeaderId, Is_Unresolved_Fulfillment_Exists__c = false));
                }
            } else {
                soHeaderListToUpdate.add(new Service_Order_Header__c(Id = soHeaderId, Is_Unresolved_Fulfillment_Exists__c = true));
            }
        }
        
        if(soHeaderListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update soHeaderListToUpdate;
        }
    }
    
    private static void updateUnresolvedCOKHForCheckout(String cokhId, Boolean isResolving) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        CO_Kit_Header__c cokhRec = new CO_Kit_Header__c(Id = cokhId); 
        List<CO_Kit_Header__c> cokhList = [Select Is_Unresolved_Fulfillment_Exists__c, (Select Id, Is_Unresolved_Fulfillment_Exists__c from CO_Line_Items__r), (Select Is_Resolved__c from Deal_Unresolved_Fulfillments__r) from CO_Kit_Header__c where Id = :cokhId];
        if(isResolving) {
            if(cokhList.size() > 0) {
                for(Deal_Unresolved_Fulfillment__c unresolvedFulfillment : cokhList[0].Deal_Unresolved_Fulfillments__r) {
                    if(!unresolvedFulfillment.Is_Resolved__c) {
                        return;
                    }
                }
            }
            cokhRec.Is_Unresolved_Fulfillment_Exists__c = false;
        } else {
            cokhRec.Is_Unresolved_Fulfillment_Exists__c = true;
        }
        
        for(CO_Line_Item__c coliRec : cokhList[0].CO_Line_Items__r) {
            coliRec.Is_Unresolved_Fulfillment_Exists__c = cokhRec.Is_Unresolved_Fulfillment_Exists__c;
        }
        if(AccessControl.ifObjectFieldIsCreateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<SObject> sObjectListToUpdate =  new List<SObject>((List<SObject>) cokhList[0].CO_Line_Items__r);
        sObjectListToUpdate.add(cokhRec);
        update sObjectListToUpdate;
    }
    
    private static void updateUnresolvedCOKHForCheckout(Map<String, Boolean> cokhIdToIsResolvingMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<SObject> sObjectListToUpdate = new List<SObject>(); 
        
        Map<String, CO_Kit_Header__c> cokhIdToCOKHRecMap = new Map<String, CO_Kit_Header__c>([Select Id, Is_Unresolved_Fulfillment_Exists__c, 
                                (Select Is_Resolved__c from Deal_Unresolved_Fulfillments__r), (Select Id, Is_Unresolved_Fulfillment_Exists__c from CO_Line_Items__r) from CO_Kit_Header__c where Id IN :cokhIdToIsResolvingMap.keySet()]);
        
        for(String cokhId : cokhIdToIsResolvingMap.keySet()) {
            
            Boolean isUnresolvedFulfillmentExists = false;
            if(cokhIdToIsResolvingMap.get(cokhId)) {
                if(cokhIdToCOKHRecMap.containsKey(cokhId)) {
                    for(Deal_Unresolved_Fulfillment__c unresolvedFulfillment : cokhIdToCOKHRecMap.get(cokhId).Deal_Unresolved_Fulfillments__r) {
                        if(!unresolvedFulfillment.Is_Resolved__c) {
                            isUnresolvedFulfillmentExists = true;
                            break;
                        }
                    }
                }
                if(!isUnresolvedFulfillmentExists) {
                    sObjectListToUpdate.add(new CO_Kit_Header__c(Id = cokhId, Is_Unresolved_Fulfillment_Exists__c = false));
                }
            } else {
                sObjectListToUpdate.add(new CO_Kit_Header__c(Id = cokhId, Is_Unresolved_Fulfillment_Exists__c = true));
                isUnresolvedFulfillmentExists = true;
            }
            if(cokhIdToCOKHRecMap.containsKey(cokhId)) {
                for(CO_Line_Item__c coliRec : cokhIdToCOKHRecMap.get(cokhId).CO_Line_Items__r) {
                    coliRec.Is_Unresolved_Fulfillment_Exists__c = isUnresolvedFulfillmentExists;
                    sObjectListToUpdate.add((SObject) coliRec);
                }
            }
        }
        
        if(sObjectListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update sObjectListToUpdate;
        }
    }
    
    private static void updateUnresolvedSOKHForCheckout(String soHeaderId, Boolean isResolving) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c(Id = soHeaderId);
        if(isResolving) {
            List<Service_Order_Kit_Header__c> sokhList = [Select Id, (Select Is_Resolved__c from Deal_Unresolved_Fulfillments__r) from Service_Order_Kit_Header__c where Service_Order_Header__c = :soHeaderId];
            for(Service_Order_Kit_Header__c sokhRec : sokhList) {
                for(Deal_Unresolved_Fulfillment__c unresolvedFulfillment : sokhRec.Deal_Unresolved_Fulfillments__r) {
                    if(!unresolvedFulfillment.Is_Resolved__c) {
                        return;
                    }
                }
            }
            soHeaderRec.Is_Unresolved_Fulfillment_Exists__c = false;
        } else {
            soHeaderRec.Is_Unresolved_Fulfillment_Exists__c = true;
        }
        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update soHeaderRec;
    }
      
    private static void updateUnresolvedSOKHForCheckout(Map<String, Boolean> soHeaderIdToIsResolvingMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        Map<String, List<Service_Order_Kit_Header__c>> soIdToSOKHRecMap = new Map<String, List<Service_Order_Kit_Header__c>>();
        for(Service_Order_Kit_Header__c sokhRec : [Select Id, Service_Order_Header__c, (Select Is_Resolved__c from Deal_Unresolved_Fulfillments__r) from Service_Order_Kit_Header__c 
                                                        where Service_Order_Header__c In :soHeaderIdToIsResolvingMap.keySet()]) {
            if(!soIdToSOKHRecMap.containsKey(sokhRec.Service_Order_Header__c)) {
                soIdToSOKHRecMap.put(sokhRec.Service_Order_Header__c, new List<Service_Order_Kit_Header__c>());
            }
            soIdToSOKHRecMap.get(sokhRec.Service_Order_Header__c).add(sokhRec);
        }
        
        List<Service_Order_Header__c> soHeaderListToUpdate = new List<Service_Order_Header__c>();
        
        for(String soHeaderId : soHeaderIdToIsResolvingMap.keySet()) {
            if(soHeaderIdToIsResolvingMap.get(soHeaderId)) {
                Boolean isUnresolvedFulfillmentExists = false;
                if(soIdToSOKHRecMap.containsKey(soHeaderId)) {
                    for(Service_Order_Kit_Header__c sokhRec : soIdToSOKHRecMap.get(soHeaderId)) {
                        for(Deal_Unresolved_Fulfillment__c unresolvedFulfillment : sokhRec.Deal_Unresolved_Fulfillments__r) {
                            if(!unresolvedFulfillment.Is_Resolved__c) {
                                isUnresolvedFulfillmentExists = true;
                                break;
                            }
                        }
                    }
                }
                if(!isUnresolvedFulfillmentExists) {
                    soHeaderListToUpdate.add(new Service_Order_Header__c(Id = soHeaderId, Is_Unresolved_Fulfillment_Exists__c = false));
                }
            } else {
                soHeaderListToUpdate.add(new Service_Order_Header__c(Id = soHeaderId, Is_Unresolved_Fulfillment_Exists__c = true));
            }
        }
        
        if(soHeaderListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update soHeaderListToUpdate;
        }
    }
    
    private static List<Deal_Unresolved_Fulfillment__c> setFieldsForUnresolvedFulfillment(List<Deal_Unresolved_Fulfillment__c> unresolvedRecList, String actionType) {
        if(unresolvedRecList.size() > 0) {
            String couId = null;
            String requiredForUnit = '';
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
            if(String.isNotBlank(unresolvedRecList[0].Deal_Item__c)) {
                List<Deal_Item__c> dealItemList = [Select Name__c, Customer_Owned_Unit__c, Customer_Owned_Unit__r.Stock_Id__c from Deal_Item__c where Id =:unresolvedRecList[0].Deal_Item__c];
            if(dealItemList.size() > 0) {
                    couId = dealItemList[0].Customer_Owned_Unit__c;
                    requiredForUnit = dealItemList[0].Name__c + ' - ' + dealItemList[0].Customer_Owned_Unit__r.Stock_Id__c;
            }
        } else {
        
                List<Deal_Item__c> dealItemList = [Select Id, Customer_Owned_Unit__c, Name__c, Customer_Owned_Unit__r.Stock_Id__c from Deal_Item__c where Deal__c = :unresolvedRecList[0].Deal__c];
            if(dealItemList.size() == 1) {
                    couId = dealItemList[0].Customer_Owned_Unit__c;
                    requiredForUnit = dealItemList[0].Name__c + ' - ' + dealItemList[0].Customer_Owned_Unit__r.Stock_Id__c;
                }
            }
        
            for(Deal_Unresolved_Fulfillment__c unresolvedRec : unresolvedRecList) {
                unresolvedRec.Action_Required__c = Constants.actionTypeToActionNameMap.get(actionType);
                unresolvedRec.User__c = UserInfo.getUserId();
                unresolvedRec.Type__c = actionType;
                unresolvedRec.Is_Resolved__c = false;
                unresolvedRec.Customer_Owned_unit__c = couId;
                unresolvedRec.Required_For_Unit__c =requiredForUnit;
            }
        }
        
        return unresolvedRecList;
    }
    
    /*private static Deal_Unresolved_Fulfillment__c createUnresolvedFulfillmentWhenAdded(String lineItemId) {
        Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec = new Deal_Unresolved_Fulfillment__c();
        String itemCode = '';
        String itemDesc = '';
        String objectName = (Id.valueOf(lineItemId)).getSObjectType().getDescribe().getName();
        if(objectName == Constants.NAMESPACE + 'CO_Line_Item__c') {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Line_Item__c> coLineItemList = [Select Qty__c, Part__c, Part__r.Part_Number__c, Part__r.Description__c, Deal__c from CO_Line_Item__c where Id = :lineItemId];
            
            if(coLineItemList.size() > 0) {
                if(String.isNotBlank(coLineItemList[0].Part__c)) {
                    itemCode = coLineItemList[0].Part__r.Part_Number__c;
                    itemDesc = (coLineItemList[0].Part__r.Description__c != null) ? coLineItemList[0].Part__r.Description__c : '';
                }
                dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, coLineItemList[0].Deal__c, coLineItemList[0].Qty__c, 1);
                dealUnresolvedFulfillmentRec.CO_Line_Item__c = lineItemId;
            }
        } else if(objectName == Constants.NAMESPACE + 'Service_Order_Line_Item__c') {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Line_item__c> soliList = [Select Qty_Needed__c, Part__c, Part__r.Part_Number__c, Part__r.Description__c, Fee__c, Item_Code__c,
                                                            Item_Description__c, Labour_Code__c, Labour_Code__r.Code__c, Labour_Code__r.Description__c, Deal__c, Deal_Item__c, 
                                                            Deal_Item__r.Customer_Owned_Unit__c from Service_Order_Line_Item__c where Id = :lineItemId];

            if(soliList.size() > 0) {
                
                if(String.isNotBlank(soliList[0].Item_Code__c)) {
                    itemCode = soliList[0].Item_Code__c;
                }
                if(String.isNotBlank(soliList[0].Item_Description__c)) {
                    itemDesc = soliList[0].Item_Description__c;
                }
                dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, soliList[0].Deal__c, soliList[0].Qty_Needed__c, 1);
                dealUnresolvedFulfillmentRec.Service_Order_Line_Item__c = lineItemId;
                dealUnresolvedFulfillmentRec.Customer_Owned_Unit__c = soliList[0].Deal_Item__r.Customer_Owned_Unit__c;
                dealUnresolvedFulfillmentRec.Deal_Item__c = soliList[0].Deal_Item__c;
                dealUnresolvedFulfillmentRec.Customer_Owned_Unit__c = soliList[0].Deal_Item__r.Customer_Owned_Unit__c;
            }
        } else if(objectName == Constants.NAMESPACE + 'CO_Kit_Header__c') {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Kit_Header__c> coKitHeaderList = [Select Kit_Header__c, Kit_Header__r.Kit_Unique_Name__c, Deal__c from CO_Kit_Header__c where Id = :lineItemId];
            
            if(coKitHeaderList.size() > 0) {
                if((coKitHeaderList[0].Kit_Header__c != null) && (coKitHeaderList[0].Kit_Header__r.Kit_Unique_Name__c != null)) {
                    List<String> codeDescList = (coKitHeaderList[0].Kit_Header__r.Kit_Unique_Name__c).split(' - ', 2);
                    itemCode = codeDescList[0];
                    itemDesc = codeDescList[1];
                }
                dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, coKitHeaderList[0].Deal__c, 1, 1);
                dealUnresolvedFulfillmentRec.CO_Kit_Header__c = lineItemId;
            }
        } else if(objectName == Constants.NAMESPACE + 'Service_Order_Kit_Header__c') {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Kit_Header__c> soKitHeaderList = [Select Kit_Header__c, Kit_Header__r.Kit_Unique_Name__c, Deal__c, Deal_Item__c, Deal_Item__r.Customer_Owned_Unit__c from Service_Order_Kit_Header__c where Id = :lineItemId];
            if(soKitHeaderList.size() > 0) {
                if((soKitHeaderList[0].Kit_Header__c != null) && (soKitHeaderList[0].Kit_Header__r.Kit_Unique_Name__c != null)) {
                    List<String> codeDescList = (soKitHeaderList[0].Kit_Header__r.Kit_Unique_Name__c).split(' - ', 2);
                    itemCode = codeDescList[0];
                    itemDesc = codeDescList[1];
                }
                dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, soKitHeaderList[0].Deal__c, 1, 1);
                dealUnresolvedFulfillmentRec.Service_Order_Kit_Header__c = lineItemId;
                dealUnresolvedFulfillmentRec.Deal_Item__c = soKitHeaderList[0].Deal_Item__c;
                dealUnresolvedFulfillmentRec.Customer_Owned_Unit__c = soKitHeaderList[0].Deal_Item__r.Customer_Owned_Unit__c;
            }
        }
        return dealUnresolvedFulfillmentRec;
    }*/
    
    private static List<Deal_Unresolved_Fulfillment__c> createUnresolvedFulfillmentWhenAdded(List<String> lineItemIdList) {
        List<Deal_Unresolved_Fulfillment__c> dealUnresolvedFulfillmentRecList = new List<Deal_Unresolved_Fulfillment__c>();
          
        String itemCode = '';
        String itemDesc = '';
        String objectName = (Id.valueOf(lineItemIdList[0])).getSObjectType().getDescribe().getName();
        
        if(objectName == Constants.NAMESPACE + 'CO_Line_Item__c') {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            
            List<CO_Line_Item__c> coLineItemList = [Select Qty__c, Part__c, Part__r.Part_Number__c, Part__r.Description__c, Deal__c from CO_Line_Item__c where Id IN :lineItemIdList];
            
            if(coLineItemList.size() > 0) {
                for(CO_Line_Item__c coliRec : coLineItemList) {
                    Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec = new Deal_Unresolved_Fulfillment__c();
                    itemCode = '';
                    itemDesc = '';
                    if(String.isNotBlank(coliRec.Part__c)) {
                        itemCode = coliRec.Part__r.Part_Number__c;
                        itemDesc = (coliRec.Part__r.Description__c != null) ? coliRec.Part__r.Description__c : '';
                    }
                    dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, coliRec.Deal__c, coliRec.Qty__c, 1);
                    dealUnresolvedFulfillmentRec.CO_Line_Item__c = coliRec.Id;
                    dealUnresolvedFulfillmentRecList.add(dealUnresolvedFulfillmentRec);
    }
    
            }
            
        } else if(objectName == Constants.NAMESPACE + 'Service_Order_Line_Item__c') {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Line_item__c> soliList = [Select Qty_Needed__c, Part__c, Part__r.Part_Number__c, Part__r.Description__c, Fee__c, Item_Code__c,
                                                            Item_Description__c, Labour_Code__c, Labour_Code__r.Code__c, Labour_Code__r.Description__c, Deal__c, Deal_Item__c, 
                                                            Deal_Item__r.Customer_Owned_Unit__c from Service_Order_Line_Item__c where Id IN :lineItemIdList];

            if(soliList.size() > 0) {
                for(Service_Order_Line_item__c soliRec : soliList) {
                    Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec = new Deal_Unresolved_Fulfillment__c();
                    itemCode = '';
                    itemDesc = '';
                    
                    if(String.isNotBlank(soliRec.Item_Code__c)) {
                        itemCode = soliRec.Item_Code__c;
                    }
                    if(String.isNotBlank(soliRec.Item_Description__c)) {
                        itemDesc = soliRec.Item_Description__c;
                    }
                    dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, soliRec.Deal__c, soliRec.Qty_Needed__c, 1);
                    dealUnresolvedFulfillmentRec.Service_Order_Line_Item__c = soliRec.Id;
                    dealUnresolvedFulfillmentRec.Customer_Owned_Unit__c = soliRec.Deal_Item__r.Customer_Owned_Unit__c;
                    dealUnresolvedFulfillmentRec.Deal_Item__c = soliRec.Deal_Item__c;
                    dealUnresolvedFulfillmentRec.Customer_Owned_Unit__c = soliRec.Deal_Item__r.Customer_Owned_Unit__c;
                    dealUnresolvedFulfillmentRecList.add(dealUnresolvedFulfillmentRec);
                }
            }
        } else if(objectName == Constants.NAMESPACE + 'CO_Kit_Header__c') {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Kit_Header__c> coKitHeaderList = [Select Kit_Header__c, Kit_Header__r.Kit_Unique_Name__c, Deal__c from CO_Kit_Header__c where Id IN :lineItemIdList];
            
            if(coKitHeaderList.size() > 0) {
                Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec = new Deal_Unresolved_Fulfillment__c();
                if((coKitHeaderList[0].Kit_Header__c != null) && (coKitHeaderList[0].Kit_Header__r.Kit_Unique_Name__c != null)) {
                    List<String> codeDescList = (coKitHeaderList[0].Kit_Header__r.Kit_Unique_Name__c).split(' - ', 2);
                    itemCode = codeDescList[0];
                    itemDesc = codeDescList[1];
                }
                dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, coKitHeaderList[0].Deal__c, 1, 1);
                dealUnresolvedFulfillmentRec.CO_Kit_Header__c = coKitHeaderList[0].Id;
                dealUnresolvedFulfillmentRecList.add(dealUnresolvedFulfillmentRec);
            }
        } else if(objectName == Constants.NAMESPACE + 'Service_Order_Kit_Header__c') {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Kit_Header__c> soKitHeaderList = [Select Kit_Header__c, Kit_Header__r.Kit_Unique_Name__c, Deal__c, Deal_Item__c, Deal_Item__r.Customer_Owned_Unit__c from Service_Order_Kit_Header__c where Id IN :lineItemIdList];
            if(soKitHeaderList.size() > 0) {
                Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec = new Deal_Unresolved_Fulfillment__c();
                if((soKitHeaderList[0].Kit_Header__c != null) && (soKitHeaderList[0].Kit_Header__r.Kit_Unique_Name__c != null)) {
                    List<String> codeDescList = (soKitHeaderList[0].Kit_Header__r.Kit_Unique_Name__c).split(' - ', 2);
                    itemCode = codeDescList[0];
                    itemDesc = codeDescList[1];
                }
                dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, soKitHeaderList[0].Deal__c, 1, 1);
                dealUnresolvedFulfillmentRec.Service_Order_Kit_Header__c = soKitHeaderList[0].Id;
                dealUnresolvedFulfillmentRec.Deal_Item__c = soKitHeaderList[0].Deal_Item__c;
                dealUnresolvedFulfillmentRec.Customer_Owned_Unit__c = soKitHeaderList[0].Deal_Item__r.Customer_Owned_Unit__c;
                dealUnresolvedFulfillmentRecList.add(dealUnresolvedFulfillmentRec);
            }
        }
        return dealUnresolvedFulfillmentRecList;
    }
    
    private static Deal_Unresolved_Fulfillment__c createUnresolvedFulfillmentWhenUpdated(String lineItemId) {
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec = new Deal_Unresolved_Fulfillment__c();
        String itemCode = '';
        String itemDesc = '';
        Decimal actualQty = 0;
        String objectName = (Id.valueOf(lineItemId)).getSObjectType().getDescribe().getName();
        if(objectName == Constants.NAMESPACE + 'CO_Line_Item__c') {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Line_Item__c> coLineItemList = [Select Qty__c, Related_Option_And_Fees__c, Part__c, Part__r.Part_Number__c, Part__r.Description__c, Deal__c, Option_Fee__c, Option_Fee__r.Deal_Item__c, Option_Fee__r.Qty__c from CO_Line_Item__c where Id = :lineItemId];
            
            if(coLineItemList.size() > 0) {
                if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Deal_Unresolved_Fulfillment__c> unresolvedFulfillmentList = [Select Id, Type__c, Updated_Quantity__c from Deal_Unresolved_Fulfillment__c where CO_Line_Item__c = :coLineItemList[0].Id AND Is_Resolved__c = false Order By CreatedDate DESC LIMIT 1];
                if(unresolvedFulfillmentList.size() > 0 && String.isBlank(coLineItemList[0].Option_Fee__c)) {
                    dealUnresolvedFulfillmentRec.Id = unresolvedFulfillmentList[0].Id;
                    dealUnresolvedFulfillmentRec.Updated_Quantity__c = coLineItemList[0].Qty__c;
                    update dealUnresolvedFulfillmentRec;
                    return null;
                } else {
                    if(String.isNotBlank(coLineItemList[0].Part__c)) {
                        itemCode = coLineItemList[0].Part__r.Part_Number__c;
                        itemDesc = (coLineItemList[0].Part__r.Description__c != null) ? coLineItemList[0].Part__r.Description__c : '';
                    }
                    if(unresolvedFulfillmentList.size() > 0) { 
                        actualQty = unresolvedFulfillmentList[0].Updated_Quantity__c;
                    } else if(String.isNotBlank(coLineItemList[0].Option_Fee__c)) {
                        if(AccessControl.ifObjectFieldIsAccessible('Option_fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                        List<AggregateResult> aggList = [Select Sum(Qty__c)totalQty from Option_fee__c where Id = : coLineItemList[0].Option_Fee__c];
                        if(aggList.size() > 0) {
                            actualQty = (Decimal) aggList[0].get('totalQty');
                        }
                    }         
                    if(actualQty != coLineItemList[0].Qty__c) {
                        dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, coLineItemList[0].Deal__c, coLineItemList[0].Qty__c, actualQty);
                        dealUnresolvedFulfillmentRec.CO_Line_Item__c = coLineItemList[0].Id;
                        dealUnresolvedFulfillmentRec.Option_Fee__c = coLineItemList[0].Option_Fee__c;
                        dealUnresolvedFulfillmentRec.Related_Option_And_Fees__c = coLineItemList[0].Related_Option_And_Fees__c;
                        dealUnresolvedFulfillmentRec.Deal_Item__c = coLineItemList[0].Option_Fee__r.Deal_Item__c;
                        dealUnresolvedFulfillmentRec.Customer_Owned_unit__c = coLineItemList[0].Option_Fee__r.Deal_Item__c;
                    } else {
                        return null;
                    }
                }
            }
        } else if(objectName == Constants.NAMESPACE + 'Service_Order_Line_Item__c') {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Line_item__c> soliList = [Select Qty_Needed__c, Part__c, Part__r.Part_Number__c, Part__r.Description__c, Fee__c, Item_Code__c, Item_Description__c,
                                                        Item_Desc__c, Labour_Code__c, Labour_Code__r.Code__c, Labour_Code__r.Description__c, Deal__c, 
                                                        Deal_Item__c, Deal_Item__r.Customer_Owned_Unit__c, Option_Fee__c, Option_Fee__r.Qty__c, 
                                                        Option_Fee__r.Deal_Item__c from Service_Order_Line_Item__c where Id = :lineItemId];

            if(soliList.size() > 0) {
                if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Deal_Unresolved_Fulfillment__c> unresolvedFulfillmentList = [Select Id, Updated_Quantity__c from Deal_Unresolved_Fulfillment__c where Service_Order_Line_Item__c = :soliList[0].Id AND Is_Resolved__c = false Order By CreatedDate DESC LIMIT 1];
                if(unresolvedFulfillmentList.size() > 0 && String.isBlank(soliList[0].Option_Fee__c)) {
                    dealUnresolvedFulfillmentRec.Id = unresolvedFulfillmentList[0].Id;
                    dealUnresolvedFulfillmentRec.Updated_Quantity__c = soliList[0].Qty_Needed__c;
                    update dealUnresolvedFulfillmentRec;
                    return null;
                } else {
                    actualQty = soliList[0].Option_Fee__r.Qty__c;
                    if(unresolvedFulfillmentList.size() > 0) {
                        actualQty = unresolvedFulfillmentList[0].Updated_Quantity__c;
                    }
                    if(actualQty != soliList[0].Qty_Needed__c) {
                        if(String.isNotBlank(soliList[0].Item_Code__c)) {
                            itemCode = soliList[0].Item_Code__c;
                        }
                        if(String.isNotBlank(soliList[0].Item_Description__c)) {
                            itemDesc = soliList[0].Item_Description__c;
                        }
                        dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, soliList[0].Deal__c, soliList[0].Qty_Needed__c, actualQty);
                        dealUnresolvedFulfillmentRec.Service_Order_Line_Item__c = soliList[0].Id;
                        dealUnresolvedFulfillmentRec.Option_Fee__c = soliList[0].Option_Fee__c;
                        dealUnresolvedFulfillmentRec.Related_Option_And_Fees__c = soliList[0].Option_Fee__c;
                        dealUnresolvedFulfillmentRec.Deal_Item__c = soliList[0].Deal_Item__c;
                        dealUnresolvedFulfillmentRec.Customer_Owned_Unit__c = soliList[0].Deal_Item__r.Customer_Owned_Unit__c;
                    } else {
                        return null;
                    }
                }
            }
        }
        
        return dealUnresolvedFulfillmentRec;
    }
    
    private static Deal_Unresolved_Fulfillment__c createUnresolvedFulfillmentWhenRemoved(String lineItemId) {
        Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec = new Deal_Unresolved_Fulfillment__c();
        String itemCode = '';
        String itemDesc = '';
        String objectName = (Id.valueOf(lineItemId)).getSObjectType().getDescribe().getName();
        if(AccessControl.ifObjectIsDeletable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Option_fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(objectName == Constants.NAMESPACE + 'CO_Line_Item__c') {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Line_Item__c> coLineItemList = [Select Qty__c, Part__c, Related_Option_And_Fees__c, (Select Id from Options_Fees__r), Part__r.Part_Number__c, Part__r.Description__c, Deal__c, Option_Fee__c, Option_Fee__r.Deal_Item__c, Option_Fee__r.Qty__c from CO_Line_Item__c where Id = :lineItemId];
            
            if(coLineItemList.size() > 0) {
                List<Deal_Unresolved_Fulfillment__c> unresolvedFulfillmentList = [Select Id from Deal_Unresolved_Fulfillment__c where CO_Line_Item__c = :coLineItemList[0].Id AND Is_Resolved__c = false];
                if(unresolvedFulfillmentList.size() > 0) {
                    delete unresolvedFulfillmentList;
                }
                if(String.isNotBlank(coLineItemList[0].Option_Fee__c)) {
                    if(String.isNotBlank(coLineItemList[0].Part__c)) {
                        itemCode = coLineItemList[0].Part__r.Part_Number__c;
                        itemDesc = (coLineItemList[0].Part__r.Description__c != null) ? coLineItemList[0].Part__r.Description__c : '';
                    }
                    Decimal qtyToDelete = coLineItemList[0].Qty__c;
                    if(String.isNotBlank(coLineItemList[0].Option_Fee__c)) {
                        List<AggregateResult> aggList = [Select Sum(Qty__c)totalQty from Option_fee__c where Id = :coLineItemList[0].Option_Fee__c];
                        if(aggList.size() > 0) {
                            qtyToDelete = (Decimal) aggList[0].get('totalQty');
                        }
                    }
                    dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, coLineItemList[0].Deal__c, qtyToDelete, coLineItemList[0].Option_Fee__r.Qty__c);
                    dealUnresolvedFulfillmentRec.Option_Fee__c = coLineItemList[0].Option_Fee__c;
                    
                    Set<String> relatedOptionAndFeeSet = new Set<String>(coLineItemList[0].Related_Option_And_Fees__c.split(';'));
                    for(Option_Fee__c optionAndFeeRec : coLineItemList[0].Options_Fees__r) {
                        relatedOptionAndFeeSet.add(optionAndFeeRec.Id);
                    }
                    dealUnresolvedFulfillmentRec.Related_Option_And_Fees__c = string.join((new List<String>(relatedOptionAndFeeSet)),';');
                        
                    //dealUnresolvedFulfillmentRec.Related_Option_And_Fees__c = coLineItemList[0].Related_Option_And_Fees__c;
                    dealUnresolvedFulfillmentRec.Deal_Item__c = coLineItemList[0].Option_Fee__r.Deal_Item__c;
                } else {
                    return null;
                }
            }
        } else if(objectName == Constants.NAMESPACE + 'Service_Order_Line_Item__c') {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Line_item__c> soliList = [Select Item_Code__c, (Select Id from Options_Fees__r), Item_Description__c, Part__c, Part__r.Part_Number__c, Part__r.Description__c, Fee__c, Item_Desc__c, Labour_Code__c, Labour_Code__r.Code__c, Labour_Code__r.Description__c, Deal__c, Deal_Item__c, Deal_Item__r.Customer_Owned_Unit__c, Option_Fee__c, Option_Fee__r.Qty__c, Option_Fee__r.Deal_Item__c from Service_Order_Line_Item__c where Id = :lineItemId];

            if(soliList.size() > 0) {
                List<Deal_Unresolved_Fulfillment__c> unresolvedFulfillmentList = [Select Id from Deal_Unresolved_Fulfillment__c where Service_Order_Line_Item__c = :soliList[0].Id AND Is_Resolved__c = false];
                if(unresolvedFulfillmentList.size() > 0) {
                    delete unresolvedFulfillmentList;
                }
                if(String.isNotBlank(soliList[0].Option_Fee__c)) {
                    itemDesc = '';
                    if(String.isNotBlank(soliList[0].Item_Code__c)) {
                        itemCode = soliList[0].Item_Code__c;
                    }
                    if(String.isNotBlank(soliList[0].Item_Description__c)) {
                        itemDesc = soliList[0].Item_Description__c;
                    }
                    dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, soliList[0].Deal__c, soliList[0].Option_Fee__r.Qty__c, soliList[0].Option_Fee__r.Qty__c);
                    
                    dealUnresolvedFulfillmentRec.Option_Fee__c = soliList[0].Option_Fee__c;
                    
                    
                    Set<String> relatedOptionAndFeeSet = new Set<String>{soliList[0].Option_Fee__c};
                    for(Option_Fee__c optionAndFeeRec : soliList[0].Options_Fees__r) {
                        relatedOptionAndFeeSet.add(optionAndFeeRec.Id);
                    }
                    dealUnresolvedFulfillmentRec.Related_Option_And_Fees__c = string.join((new List<String>(relatedOptionAndFeeSet)),';');
                        
                    //dealUnresolvedFulfillmentRec.Related_Option_And_Fees__c = soliList[0].Option_Fee__c;
                    dealUnresolvedFulfillmentRec.Deal_Item__c = soliList[0].Option_Fee__r.Deal_Item__c;
                    dealUnresolvedFulfillmentRec.Customer_Owned_Unit__c = soliList[0].Deal_Item__r.Customer_Owned_Unit__c;
                } else {
                    return null;
                }
            }
        } else if(objectName == Constants.NAMESPACE + 'CO_Kit_Header__c') {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Kit_Header__c> cokhList = [Select Deal_Kit_Header__c, Deal_Kit_Header__r.Kit_Header__c, Deal_Kit_Header__r.Kit_Header__r.Kit_Unique_Name__c, Deal__c, Deal_Kit_Header__r.Deal_Item__c from CO_Kit_Header__c where Id = :lineItemId];
            
            if(cokhList.size() > 0) {
                List<Deal_Unresolved_Fulfillment__c> unresolvedFulfillmentList = [Select Id from Deal_Unresolved_Fulfillment__c where CO_Kit_Header__c = :cokhList[0].Id AND Is_Resolved__c = false];
                if(unresolvedFulfillmentList.size() > 0) {
                    delete unresolvedFulfillmentList;
                }
                if(String.isNotBlank(cokhList[0].Deal_Kit_Header__c)) {
                    if((cokhList[0].Deal_Kit_Header__r.Kit_Header__c != null) && (cokhList[0].Deal_Kit_Header__r.Kit_Header__r.Kit_Unique_Name__c != null)) {
                        List<String> codeDescList = (cokhList[0].Deal_Kit_Header__r.Kit_Header__r.Kit_Unique_Name__c).split(' - ', 2);
                        itemCode = codeDescList[0];
                        itemDesc = codeDescList[1];
                    }
                    dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, cokhList[0].Deal__c, 1, 1);
                    dealUnresolvedFulfillmentRec.Deal_Kit_Header__c = cokhList[0].Deal_Kit_Header__c;
                    dealUnresolvedFulfillmentRec.CO_Kit_Header__c = cokhList[0].Id;
                    dealUnresolvedFulfillmentRec.Deal_Item__c = cokhList[0].Deal_Kit_Header__r.Deal_Item__c;
                } else {
                    return null;
                }
            }
        } else if(objectName == Constants.NAMESPACE + 'Service_Order_Kit_Header__c') {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Service_Order_Kit_Header__c> sokhList = [Select Deal_Kit_Header__c, Deal_Kit_Header__r.Kit_Header__c, Deal_Kit_Header__r.Kit_Header__r.Kit_Unique_Name__c, Deal__c, Deal_Item__c, Deal_Item__r.Customer_Owned_Unit__c, Deal_Kit_Header__r.Deal_Item__c from Service_Order_Kit_Header__c where Id = :lineItemId];

            if(sokhList.size() > 0) {
                List<Deal_Unresolved_Fulfillment__c> unresolvedFulfillmentList = [Select Id from Deal_Unresolved_Fulfillment__c where Service_Order_Kit_Header__c = :sokhList[0].Id AND Is_Resolved__c = false];
                if(unresolvedFulfillmentList.size() > 0) {
                    delete unresolvedFulfillmentList;
                }
                if(String.isNotBlank(sokhList[0].Deal_Kit_Header__c)) {
                    if((sokhList[0].Deal_Kit_Header__r.Kit_Header__c != null) && (sokhList[0].Deal_Kit_Header__r.Kit_Header__r.Kit_Unique_Name__c != null)) {
                        List<String> codeDescList = (sokhList[0].Deal_Kit_Header__r.Kit_Header__r.Kit_Unique_Name__c).split(' - ', 2);
                        itemCode = codeDescList[0];
                        itemDesc = codeDescList[1];
                    }
                    dealUnresolvedFulfillmentRec = setUnresolvedFulfillmentFields(itemCode, itemDesc, sokhList[0].Deal__c, 1, 1);
                    
                    dealUnresolvedFulfillmentRec.Deal_Kit_Header__c = sokhList[0].Deal_Kit_Header__c;
                    dealUnresolvedFulfillmentRec.Service_Order_Kit_Header__c = sokhList[0].Id;
                    dealUnresolvedFulfillmentRec.Deal_Item__c = sokhList[0].Deal_Item__c;
                    dealUnresolvedFulfillmentRec.Customer_Owned_Unit__c = sokhList[0].Deal_Item__r.Customer_Owned_Unit__c;
                } else {
                    return null;
                }
            }
        }
        return dealUnresolvedFulfillmentRec;
    }

    private static Deal_Unresolved_Fulfillment__c setUnresolvedFulfillmentFields(String itemCode, String itemDesc, String dealId, Decimal updatedQty, Decimal actualQty) {
        Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec = new Deal_Unresolved_Fulfillment__c();
        
        dealUnresolvedFulfillmentRec.Item_Code__c = itemCode;
        dealUnresolvedFulfillmentRec.Item_Description__c = itemDesc;
        dealUnresolvedFulfillmentRec.Deal__c = dealId;
        dealUnresolvedFulfillmentRec.Updated_Quantity__c = updatedQty;
        dealUnresolvedFulfillmentRec.Actual_Quantity__c = actualQty;
        
        return dealUnresolvedFulfillmentRec;
    }
    
    @RemoteAction
    global static String resolveFulfillment(String dealId, String unresolvedFulfillmentObjJSON, String chargeMethod, String selectedUnitId) {
        dealId = BPUtility.getDecodedString(dealId);
        unresolvedFulfillmentObjJSON = BPUtility.getDecodedString(unresolvedFulfillmentObjJSON);
        chargeMethod = BPUtility.getDecodedString(chargeMethod);
        selectedUnitId = BPUtility.getDecodedString(selectedUnitId);
        DealWrapper.DealUnresolvedFulfillmentWrapper unresolvedFulfillmentObj = (DealWrapper.DealUnresolvedFulfillmentWrapper) System.JSON.deserialize(unresolvedFulfillmentObjJSON, DealWrapper.DealUnresolvedFulfillmentWrapper.class);
        unresolvedFulfillmentObj.ChargeMethod = chargeMethod;
        //Update Unresolved fulfillment record
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(String.isNotBlank(selectedUnitId)) {
            List<Deal_Item__c> dealItemList = [Select Id from Deal_Item__c where Deal__c = :unresolvedFulfillmentObj.DealId And Customer_Owned_Unit__c = :selectedUnitId];
            if(dealItemList.size() > 0) {
                unresolvedFulfillmentObj.DealItemId = dealItemList[0].Id;
            }
        }
        if(unresolvedFulfillmentObj.Type == Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED) {
            resolveFulfillmentWithAddAction(unresolvedFulfillmentObj, chargeMethod);
        } else if(unresolvedFulfillmentObj.Type == Constants.UNRESOLVED_FULFILLMENT_TYPE_REMOVED) {
            resolveFulfillmentWithRemoveAction(unresolvedFulfillmentObj);
        } else if(unresolvedFulfillmentObj.Type == Constants.UNRESOLVED_FULFILLMENT_TYPE_UPDATED) {
            resolveFulfillmentWithUpdateAction(unresolvedFulfillmentObj);
        }
        
        Deal_Unresolved_Fulfillment__c dealUnresolvedFulfillmentRec = new Deal_Unresolved_Fulfillment__c();
        
        dealUnresolvedFulfillmentRec.Id = unresolvedFulfillmentObj.Id;
        dealUnresolvedFulfillmentRec.Charge_Method__c = chargeMethod;
        dealUnresolvedFulfillmentRec.Customer_Owned_Unit__c = selectedUnitId;
        dealUnresolvedFulfillmentRec.Is_Resolved__c = true;
        dealUnresolvedFulfillmentRec.Deal_Item__c = unresolvedFulfillmentObj.DealItemId;
        
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Unresolved_Fulfillment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update dealUnresolvedFulfillmentRec;
        
        List<Deal_Unresolved_Fulfillment__c> unresolvedFulfillmentList = [Select Deal__r.CO_Header__c, CO_Line_Item__c, Service_Order_Line_Item__r.Service_Order_Header__c, 
                                                                            CO_Kit_Header__c, Service_Order_Kit_Header__c, Service_Order_Kit_Header__r.Service_Order_Header__c from 
                                                                            Deal_Unresolved_Fulfillment__c where Id = :dealUnresolvedFulfillmentRec.Id];
        if(unresolvedFulfillmentList.size() > 0) {
            if(String.isNotBlank(unresolvedFulfillmentList[0].CO_Line_Item__c)) {
                updateUnresolvedCOLIForCheckout(unresolvedFulfillmentList[0].CO_Line_Item__c, true);
            } else if(String.isNotBlank(unresolvedFulfillmentList[0].Service_Order_Line_Item__r.Service_Order_Header__c)) {
                updateUnresolvedSOHeaderForCheckout(unresolvedFulfillmentList[0].Service_Order_Line_Item__r.Service_Order_Header__c, true);
            } else if(String.isNotBlank(unresolvedFulfillmentList[0].CO_Kit_Header__c)) {
                updateUnresolvedCOKHForCheckout(unresolvedFulfillmentList[0].CO_Kit_Header__c, true);
            } else if(String.isNotBlank(unresolvedFulfillmentList[0].Service_Order_Kit_Header__c)) {
                updateUnresolvedSOKHForCheckout(unresolvedFulfillmentList[0].Service_Order_Kit_Header__r.Service_Order_Header__c, true);
            }
            UpdateOptionFeeStatus(unresolvedFulfillmentList[0].Deal__r.CO_Header__c);
        }
        
        //OptionAndFeeTriggerHelper.updateDealTotal(new Set<String>{dealId});
        return getDealDetails(BPUtility.getEncodedString(dealId), BPUtility.getEncodedString(null));
    }
    
    private static void resolveFulfillmentWithAddAction(DealWrapper.DealUnresolvedFulfillmentWrapper unresolvedFulfillmentObj, String chargeMethod) {
        if(AccessControl.ifObjectFieldIsCreateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        String lineItemId = null;
        if(String.isNotBlank(unresolvedFulfillmentObj.DealMerchandiseLineItemId)) {
            lineItemId = unresolvedFulfillmentObj.DealMerchandiseLineItemId;
        } else if(String.isNotBlank(unresolvedFulfillmentObj.DealServiceLineItemId)) {
            lineItemId = unresolvedFulfillmentObj.DealServiceLineItemId;
        }
        Option_Fee__c optionAndFeeRec;
        if(String.isNotBlank(lineItemId)) {
            optionAndFeeRec = setOptionAndFeeLineItem(lineItemId, unresolvedFulfillmentObj.DealItemId);
        
            if(String.isNotBlank(chargeMethod) && chargeMethod.equalsIgnoreCase(Constants.CHARGE_METHOD_DO_NOT_INVOICE)) {
                optionAndFeeRec.Price__c = optionAndFeeRec.Price_When_Tax_Included__c = 0;
                
                OptionAndFeeTriggerHelper.isTriggerExecute = true;
            }
            insert optionAndFeeRec;
        }
        
        //update existed coli or soli
        if(String.isNotBlank(unresolvedFulfillmentObj.DealMerchandiseLineItemId)) {
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Line_Item__c> coliList = [Select Option_Fee__c, Related_Option_And_Fees__c from CO_Line_Item__c where Id = :unresolvedFulfillmentObj.DealMerchandiseLineItemId];
            if(coliList.size() > 0) {
                coliList[0].Option_Fee__c = optionAndFeeRec.Id;
                if(coliList[0].Related_Option_And_Fees__c == null) {
                    coliList[0].Related_Option_And_Fees__c = '';
                }
                coliList[0].Related_Option_And_Fees__c += ';' + optionAndFeeRec.Id;
                update coliList[0];
            }
            
        } else if(String.isNotBlank(unresolvedFulfillmentObj.DealServiceLineItemId)) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update new Service_Order_Line_Item__c(Id = unresolvedFulfillmentObj.DealServiceLineItemId, Option_Fee__c = optionAndFeeRec.Id);
        } else if(String.isNotBlank(unresolvedFulfillmentObj.COKitHeaderId)) {
            
            String dkhId = insertDealKHByCOKH(unresolvedFulfillmentObj.KitHeaderId, unresolvedFulfillmentObj.DealItemId, unresolvedFulfillmentObj.DealId, chargeMethod, false, unresolvedFulfillmentObj.COKitHeaderId);
            
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update new CO_Kit_Header__c(Id = unresolvedFulfillmentObj.COKitHeaderId, Deal_Kit_Header__c = dkhId);
        } else if(String.isNotBlank(unresolvedFulfillmentObj.SOKitHeaderId)) {
            
            String dkhId = insertDealKHByCOKH(unresolvedFulfillmentObj.KitHeaderId, unresolvedFulfillmentObj.DealItemId, unresolvedFulfillmentObj.DealId, chargeMethod, true, unresolvedFulfillmentObj.SOKitHeaderId);
            
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update new Service_Order_Kit_Header__c(Id = unresolvedFulfillmentObj.SOKitHeaderId, Deal_Kit_Header__c = dkhId);
        }
    }
    
    private static void resolveFulfillmentWithRemoveAction(DealWrapper.DealUnresolvedFulfillmentWrapper unresolvedFulfillmentObj) {
        List<String> optionAndFeeIdList;
        List<SObject> sObjectList = new List<SObject>();
        if(unresolvedFulfillmentObj.DealKitHeaderId != null) {
            optionAndFeeIdList = new List<String>{unresolvedFulfillmentObj.DealKitHeaderId};
            
            if(AccessControl.ifObjectFieldIsAccessible('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Deal_Kit_Header__c> dealKHList = [Select Id, (Select Id from Options_Fees__r), (Select Id from Service_Order_Kit_Headers__r), (Select Id from CO_Kit_Headers__r) from Deal_Kit_Header__c where Id In :optionAndFeeIdList];
            optionAndFeeIdList.clear();
            if(dealKHList.size() > 0) {
                for(Deal_Kit_Header__c dkhRec : dealKHList) {
                    sObjectList.addAll((List<SObject>)dkhRec.CO_Kit_Headers__r);
                    sObjectList.addAll((List<SObject>)dkhRec.Service_Order_Kit_Headers__r);
                    sObjectList.add((SObject)dkhRec);
                    for(Option_Fee__c optionAndFeeRec : dkhRec.Options_Fees__r) {
                        optionAndFeeIdList.add(optionAndFeeRec.Id);
                    }
                }
            }
        } else {
            optionAndFeeIdList = unresolvedFulfillmentObj.RelatedOptionAndFeeIdList;
        }
        if(optionAndFeeIdList.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            
            List<Option_Fee__c> optionAndFeeList;
            String query = 'Select Id, CO_Line_Item__c, Service_Order_Line_Item__c, (Select Id from CO_Line_Items__r), (Select Id from Service_Order_Line_Items__r) from '+
                'Option_Fee__c where (Id IN: optionAndFeeIdList)';
                
            query += String.isNotBlank(unresolvedFulfillmentObj.DealMerchandiseLineItemId) ? 
                    ' OR (Do_Not_Invoice__c = true AND (CO_Line_Item__c =: unresolvedFulfillmentObj.DealMerchandiseLineItemId) '
                : (String.isNotBlank(unresolvedFulfillmentObj.DealMerchandiseLineItemId) ? ' OR (Do_Not_Invoice__c = true AND (Service_Order_Line_Item__c =: unresolvedFulfillmentObj.DealServiceLineItemId))' : '');
            optionAndFeeList = Database.query(query);
            if(optionAndFeeList.size() > 0) {
                for(Option_Fee__c optionAndFeeRec : optionAndFeeList) {
                    if(String.isNotBlank(optionAndFeeRec.CO_Line_Item__c)) {
                        sObjectList.add((SObject) new CO_Line_Item__c(Id = optionAndFeeRec.CO_Line_Item__c));
                    }
                    if(String.isNotBlank(optionAndFeeRec.Service_Order_Line_Item__c)) {
                        sObjectList.add((SObject) new Service_Order_Line_Item__c(Id = optionAndFeeRec.Service_Order_Line_Item__c));
                    }
                    sObjectList.addAll((List<SObject>)optionAndFeeRec.CO_Line_Items__r);
                    sObjectList.addAll((List<SObject>)optionAndFeeRec.Service_Order_Line_Items__r);
                    sObjectList.add((SObject)optionAndFeeRec);
                }
            }
        }
        if(AccessControl.ifObjectIsDeletable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        delete sObjectList;
    }
    
    private static void resolveFulfillmentWithUpdateAction(DealWrapper.DealUnresolvedFulfillmentWrapper unresolvedFulfillmentObj) {
        String lineItemId = null;
        Boolean isMerchandise = false;
        if(String.isNotBlank(unresolvedFulfillmentObj.DealMerchandiseLineItemId)) {
            isMerchandise = true;
            lineItemId = unresolvedFulfillmentObj.DealMerchandiseLineItemId;
        } else if(String.isNotBlank(unresolvedFulfillmentObj.DealServiceLineItemId)) {
            isMerchandise = false;
            lineItemId = unresolvedFulfillmentObj.DealServiceLineItemId;
        }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Co_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Option_Fee__c optionAndFeeRec = null;
        List<CO_Line_Item__c> coLineItemList = [Select Option_Fee__c, Related_Option_And_Fees__c from Co_Line_Item__c where Id = :lineItemId];
        Set<String> optionAndFeeIdSet = null;
        if(unresolvedFulfillmentObj.ChargeMethod == Constants.CHARGE_METHOD_INVOICE) {
            List<Option_Fee__c> optionAndFeeList = new List<Option_Fee__c>();
            if(isMerchandise) {
                if(coLineItemList.size() > 0) {
                if(String.isNotBlank(coLineItemList[0].Related_Option_And_Fees__c)) {
                    optionAndFeeIdSet = new Set<String>(coLineItemList[0].Related_Option_And_Fees__c.split(';'));
                    optionAndFeeList = [Select Id, Qty__c, Deal_Item__c from Option_Fee__c where Id In :optionAndFeeIdSet And Deal_Item__c = :unresolvedFulfillmentObj.DealItemId];
                }
                }
            } else {
                optionAndFeeList = [Select Id, Qty__c, Deal_Item__c from Option_Fee__c where Id = :unresolvedFulfillmentObj.OptionAndFeeId];
            }
            if(optionAndFeeList.size() > 0) {
                optionAndFeeList[0].Qty__c += (unresolvedFulfillmentObj.UpdatedQty - unresolvedFulfillmentObj.ActualQty);
                optionAndFeeList[0].Deal_Item__c = unresolvedFulfillmentObj.DealItemId;
                if(optionAndFeeList[0].Qty__c > 0) {
                update optionAndFeeList[0];
                return;
                } else if(optionAndFeeList[0].Qty__c == 0){
                    if(AccessControl.ifObjectIsDeletable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                    delete optionAndFeeList[0];
                    if(isMerchandise) {
                        if(optionAndFeeIdSet != null) {
                            optionAndFeeIdSet.remove(optionAndFeeList[0].Id);
                            coLineItemList[0].Related_Option_And_Fees__c = string.join((new List<String>(optionAndFeeIdSet)),';');
                        }
                        update coLineItemList[0];
                    }
                }
            } else {
                optionAndFeeRec = setOptionAndFeeLineItem(lineItemId, unresolvedFulfillmentObj.DealItemId);
                optionAndFeeRec.Qty__c = (unresolvedFulfillmentObj.UpdatedQty - unresolvedFulfillmentObj.ActualQty);
                insert optionAndFeeRec;
                if(isMerchandise) {
                    if(optionAndFeeIdSet == null) {
                        optionAndFeeIdSet = new Set<String>();
                    }
                    optionAndFeeIdSet.add(optionAndFeeRec.Id);
                    coLineItemList[0].Related_Option_And_Fees__c = string.join((new List<String>(optionAndFeeIdSet)),';');
                    coLineItemList[0].Option_Fee__c = optionAndFeeRec.Id;
                    update coLineItemList[0];
                } else {
                    update new Service_Order_Line_Item__c(Id = lineItemId, Option_Fee__c = optionAndFeeRec.Id);
                }
            }
        } else if(unresolvedFulfillmentObj.ChargeMethod == Constants.CHARGE_METHOD_DO_NOT_INVOICE) {
            optionAndFeeRec = setOptionAndFeeLineItem(lineItemId, unresolvedFulfillmentObj.DealItemId);
            optionAndFeeRec.Do_Not_Invoice__c = true;
            optionAndFeeRec.Price__c = optionAndFeeRec.Price_When_Tax_Included__c = 0;
            optionAndFeeRec.Qty__c = (unresolvedFulfillmentObj.UpdatedQty - unresolvedFulfillmentObj.ActualQty);
            optionAndFeeRec.CO_Line_Item__c = String.isNotBlank(unresolvedFulfillmentObj.DealMerchandiseLineItemId) ? unresolvedFulfillmentObj.DealMerchandiseLineItemId : null;
            optionAndFeeRec.Service_Order_Line_Item__c = String.isNotBlank(unresolvedFulfillmentObj.DealServiceLineItemId) ? unresolvedFulfillmentObj.DealServiceLineItemId : null;
            OptionAndFeeTriggerHelper.isTriggerExecute = true;
            insert optionAndFeeRec;
            if(isMerchandise) {
                optionAndFeeIdSet = new Set<String>(coLineItemList[0].Related_Option_And_Fees__c.split(';'));
                optionAndFeeIdSet.add(optionAndFeeRec.Id);
                coLineItemList[0].Related_Option_And_Fees__c = string.join((new List<String>(optionAndFeeIdSet)),';');
                coLineItemList[0].Option_Fee__c = optionAndFeeRec.Id;
                update coLineItemList[0];
            } else {
                //update new Service_Order_Line_Item__c(Id = lineItemId, Option_Fee__c = optionAndFeeRec.Id);
            }
        }
        
    }
    
    private static Option_Fee__c setOptionAndFeeLineItem(String unresolvedFulfillmentId, String dealItemId) {
        Option_Fee__c optionAndFeeRec = new Option_Fee__c();
        
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        String objectName = (Id.valueOf(unresolvedFulfillmentId)).getSObjectType().getDescribe().getName();
        if(objectName == Constants.NAMESPACE + 'CO_Line_Item__c') {
            List<CO_Line_Item__c> coliList = [Select Deal__c, Closed_CO_Invoice_link__c, Qty__c, Part__c,Item_Code__c, Item_Description__c, Part__r.Part_Number__c, Part__r.Description__c, Part__r.Retail_Price__c, Price__c from CO_Line_Item__c where Id = :unresolvedFulfillmentId];
            if(coliList.size() > 0) {
                optionAndFeeRec.Part__c = coliList[0].Part__c;
                optionAndFeeRec.Deal__c = coliList[0].Deal__c;
                optionAndFeeRec.Price__c = coliList[0].Part__r.Retail_Price__c;
                optionAndFeeRec.Qty__c = coliList[0].Qty__c;
                optionAndFeeRec.Is_Install__c = false;
                optionAndFeeRec.Item_Code__c = coliList[0].Part__r.Part_Number__c;
                optionAndFeeRec.Item_Description__c = coliList[0].Part__r.Description__c;
                optionAndFeeRec.Per_Item_Cost__c = coliList[0].Price__c;
                if(String.isNotBlank(coliList[0].Closed_CO_Invoice_link__c)) {
                    optionAndFeeRec.Status__c = 'Fulfilled';
                }
            }
        } else if(objectName == Constants.NAMESPACE + 'Service_Order_Line_Item__c') {
            List<Service_Order_Line_Item__c> soliList = [Select Item_Code__c, Service_Order_Header__r.Work_Status__c, CO_Line_Item__r.Closed_CO_Invoice_link__c, Item_Description__c, Deal__c, Kit_Price__c, Qty_Needed__c, Part__c, Part__r.Retail_Price__c, Fee__c, Fee__r.Price__c, Labour_Code__c, Labour_Code__r.Rate__c, Sublet__c, Sublet__r.Price__c from Service_Order_Line_Item__c where Id = :unresolvedFulfillmentId];
            if(soliList.size() > 0) {
                optionAndFeeRec.Part__c = soliList[0].Part__c;
                if(String.isNotBlank(soliList[0].Part__c)) {
                    optionAndFeeRec.Price__c = soliList[0].Part__r.Retail_Price__c;
                } else if(String.isNotBlank(soliList[0].Labour_Code__c)) {
                    optionAndFeeRec.Price__c = soliList[0].Labour_Code__r.Rate__c;
                } else if(String.isNotBlank(soliList[0].Fee__c)) {
                    optionAndFeeRec.Price__c = soliList[0].Fee__r.Price__c;
                } else if(String.isNotBlank(soliList[0].Sublet__c)) {
                    optionAndFeeRec.Price__c = soliList[0].Sublet__r.Price__c;
                }
                optionAndFeeRec.Item_Code__c = soliList[0].Item_Code__c;
                optionAndFeeRec.Item_Description__c = soliList[0].Item_Description__c;
                optionAndFeeRec.Labour_Code__c = soliList[0].Labour_Code__c;
                optionAndFeeRec.Is_Install__c = true;
                optionAndFeeRec.Qty__c = soliList[0].Qty_Needed__c;
                optionAndFeeRec.Deal__c = soliList[0].Deal__c;
                //optionAndFeeRec.Price__c = soliList[0].Kit_Price__c;
                optionAndFeeRec.Fee__c = soliList[0].Fee__c;
                optionAndFeeRec.Product__c = soliList[0].Sublet__c;
                optionAndFeeRec.Per_Item_Cost__c = soliList[0].Kit_Price__c;
                if(String.isNotBlank(soliList[0].CO_Line_Item__r.Closed_CO_Invoice_link__c)) {
                    optionAndFeeRec.Status__c = 'Fulfilled';
                } else {
                    if(String.isNotBlank(soliList[0].Service_Order_Header__r.Work_Status__c) && soliList[0].Service_Order_Header__r.Work_Status__c == 'Invoiced') {
                        optionAndFeeRec.Status__c = 'Fulfilled';
                    }
                }
            }
        }
        optionAndFeeRec.Deal_Item__c = dealItemId;
        return optionAndFeeRec;
    }
    
    /**
    * Name: getDealFinanceMasterData
    * Desc: Method to get json string related to Service Header Order
    * @param:  (1) coHeaderId - String - Id of CO Header Record
    * @return: String - JSON String of SO Header Detail Record
    **/
    @RemoteAction 
    global static String getDealFinanceMasterData() {
        try{
            List<Account> financeCompanyList = SOQLUtil.getFinanceCompanyList();
            List<SOHeaderWrapper.VendorAsProvider> financeCompanyObjList = new List<SOHeaderWrapper.VendorAsProvider>();
            for(Account financeCompanyRec : financeCompanyList) {
                financeCompanyObjList.add(new SOHeaderWrapper.VendorAsProvider(financeCompanyRec));
            }
            return BPUtility.getEncodedString(System.JSON.serialize(financeCompanyObjList));  
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    //Added by Nidhi -28-11-2016
    @RemoteAction
    global static String updateDealFinanceDetails(String dealId, String dealFinanceJSON) { 
        dealId = BPUtility.getDecodedString(dealId);
        dealFinanceJSON = BPUtility.getDecodedString(dealFinanceJSON);
        DealService.updateDealFinanceDetails(dealId, dealFinanceJSON);
        return getDealDetails(BPUtility.getEncodedString(dealId), BPUtility.getEncodedString('dealFinanceSection'));
    }
    
    public static Deal_Finance__c setDealFinanceField(DealWrapper.DealFinanceWrapper dealFinanceObj) {
        Deal_Finance__c dealFinanceRec = new Deal_Finance__c();
        
        dealFinanceRec.Id = dealFinanceObj.Id;
        dealFinanceRec.Finance_Company__c = dealFinanceObj.FinanceCompanyId;
        dealFinanceRec.Deal__c = dealFinanceObj.DealId;
        dealFinanceRec.Down_Payment__c = dealFinanceObj.DownPayment;
        dealFinanceRec.Interest_Rate__c = dealFinanceObj.InterestRate;
        dealFinanceRec.Loan_Term__c = dealFinanceObj.LoanTerm;
        dealFinanceRec.Term_Type__c = dealFinanceObj.TermType;
        dealFinanceRec.Payment_Frequency__c = dealFinanceObj.PaymentFrequency;
        dealFinanceRec.Estimated_Payment__c = dealFinanceObj.EstimatedPayment;
        dealFinanceRec.Finance_Commission__c = dealFinanceObj.FinanceCommission;
        dealFinanceRec.Co_Buyer__c = String.isNotBlank(dealFinanceObj.CoBuyerId) ? dealFinanceObj.CoBuyerId : null;
        return dealFinanceRec;
    }
    
    @RemoteAction
    global static String removeFAndIProductLineItem(String dealId, String fAndIProductId) {
        dealId = BPUtility.getDecodedString(dealId);
        fAndIProductId = BPUtility.getDecodedString(fAndIProductId);
        if(AccessControl.ifObjectFieldIsAccessible('F_I_Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<F_I_Product__c> fAndIproductRecordToDelete = [select Id from F_I_Product__c where Id =: fAndIProductId];
        
        if(fAndIproductRecordToDelete.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('F_I_Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete fAndIproductRecordToDelete[0];
        }
        return getDealDetails(BPUtility.getEncodedString(dealId), BPUtility.getEncodedString('dealFinanceSection'));
    }
    
    @RemoteAction
    global static String saveDealFAndIProduct(String dealId, String dealFAndIProductJSON) {
        dealId = BPUtility.getDecodedString(dealId);
        dealFAndIProductJSON = BPUtility.getDecodedString(dealFAndIProductJSON);
        DealWrapper.FIProductWrapper dealFAndIProductObj = (DealWrapper.FIProductWrapper) System.JSON.deserialize(dealFAndIProductJSON, DealWrapper.FIProductWrapper.class);
         
        if(String.isBlank(dealFAndIProductObj.Id)) {
            if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Product__c> productList = [Select Price__c, Code__c, Description__c from Product__c where Id = :dealFAndIProductObj.ProductId];
            if(productList.size() > 0) {
                dealFAndIProductObj.Price = productList[0].Price__c;
                dealFAndIProductObj.ItemDescription =  productList[0].Code__c + ' - ' + productList[0].Description__c;
            }
        }
        
        F_I_Product__c dealFAndIProductRec = setDealFAndIProductField(dealFAndIProductObj);
        if(AccessControl.ifObjectFieldIsCreateable('F_I_Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('F_I_Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(dealFAndIProductRec.Id == null) {
            COFormService.insertDefaultCOForms(null, dealFAndIProductRec.Deal_Finance__c, dealFAndIProductRec.Vendor_Product__c);
        }
        upsert dealFAndIProductRec;
        return BPUtility.getEncodedString(getFAndIProductDetails(dealFAndIProductRec.Id));
    }
        
    private static String getFAndIProductDetails(String fAndIProductId) {
        List<F_I_Product__c> dealFAndIProductList = SOQLUtil.getDealFAndIProductRecord(new Map<String, String>{'Id' => fAndIProductId});
        if(dealFAndIProductList.size() == 0) {
            return '{}';
        }       
        DealWrapper.FIProductWrapper dealFAndISectionObj = new DealWrapper.FIProductWrapper(dealFAndIProductList[0]);
        return System.JSON.serialize(dealFAndISectionObj);
    }
    
    private static F_I_Product__c setDealFAndIProductField(DealWrapper.FIProductWrapper dealFAndIProductObj) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        dealFAndIProductObj.SalesTaxPercentage = (dealFAndIProductObj.SalesTaxPercentage == null) ? 0 : dealFAndIProductObj.SalesTaxPercentage;
        dealFAndIProductObj.Price = (dealFAndIProductObj.Price == null) ? 0 : dealFAndIProductObj.Price;
        
        F_I_Product__c dealFAndIProductRec = new F_I_Product__c();
        if(isTaxIncludingPricing) {
            dealFAndIProductRec.Price_When_Tax_Included__c = dealFAndIProductObj.Price;
            dealFAndIProductObj.Price = (dealFAndIProductObj.Price / (1 + (dealFAndIProductObj.SalesTaxPercentage / 100))).setScale(2, RoundingMode.HALF_UP);
            dealFAndIProductObj.SalesTax = (dealFAndIProductObj.Price * dealFAndIProductObj.SalesTaxPercentage / 100);
        } 
        
        dealFAndIProductRec.Id = dealFAndIProductObj.Id;
        dealFAndIProductRec.Price__c = dealFAndIProductObj.Price;
        dealFAndIProductRec.Sales_Tax__c = dealFAndIProductObj.SalesTax;
        dealFAndIProductRec.Vendor_Product__c = dealFAndIProductObj.ProductId;
        dealFAndIProductRec.Item_Description__c = dealFAndIProductObj.ItemDescription;
        dealFAndIProductRec.Deal_Finance__c = dealFAndIProductObj.DealFinanceId;
        dealFAndIProductRec.Deal__c = dealFAndIProductObj.DealId;
        
        return dealFAndIProductRec;
    }
    
    public static void finalizeDeal(String dealId, String coInvoiceNumber, DateTime invoiceDate) {
        if(String.isNotBlank(dealId)) {
            if(AccessControl.ifObjectFieldIsCreateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Deal__c> dealList = [Select Id, CO_Header__r.Customer__c, (Select Id, Type__c, Agreed_value__c, Default_Unit_Sales_Tax_Percentage__c, Actual_Cash_Value__c, Is_Stocked_In__c, Customer_Owned_Unit__c, Customer_Owned_Unit__r.Status__c from Deal_Items__r) from Deal__c where Id = :dealId];
            
            if(dealList.size() > 0) {
                Map<Id, Deal_Item__c> couIdToDealItemRecMap = new Map<Id, Deal_Item__c>();
                Map<Id, Customer_Owned_Unit__c> couIdToRelatedCOUMap = new Map<Id, Customer_Owned_Unit__c>();
                List<Customer_Owned_Unit__c> unitListToUpdateStatus = new List<Customer_Owned_Unit__c>();
                List<String> unitIdList = new List<String>();
                List<String> dealItemIdList = new List<String>();
                List<Unit_Price_Cost__c> unitPriceAndCostList = new List<Unit_Price_Cost__c>();
                Map<Id, Id> dealItemIdToStockedInUnitIdMap = new Map<Id, Id>();
                
                for(Deal_Item__c dealItemRec : dealList[0].Deal_Items__r) {
                    if(String.isNotBlank(dealItemRec.Customer_Owned_Unit__c) && !dealItemRec.Is_Stocked_In__c) {
                        unitIdList.add(dealItemRec.Customer_Owned_Unit__c);
                    }
                    
                    if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_UNIT) {
                        dealItemIdList.add(dealItemRec.Id);
                    } else if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN && !dealItemRec.Is_Stocked_In__c) {
                        couIdToDealItemRecMap.put(dealItemRec.Customer_Owned_Unit__c, dealItemRec);
                    }
                }
                
                if(unitIdList.size() > 0) {
                    String query = 'Select ';
                    for(String fieldName : CustomerOwnedUnit.fieldsList()) {
                        query += fieldName + ', ';
                    }
                    query += '(Select ';
                    for(String fieldName : UNitWrapper.fieldsListForUnitPriceAndCostTracking()) {
                        query += fieldName + ', ';
                    }
                    
                    query = query.substring(0, query.length()-2);
                    query += ' from Unit_Prices_Costs__r where Type__c = \'Base\')';
                    query += ' from Customer_Owned_Unit__c where Id In :unitIdList';
                    
                    unitListToUpdateStatus = Database.query(query);
                }
                
                if(dealItemIdList.size() > 0) {
                    String query = 'Select ';
                    for(String fieldName : DealWrapper.getDealUnitPriceCost()) {
                        query += fieldName + ', ';
                    }
                    
                    query = query.substring(0, query.length()-2);
                    query += ' from Deal_Unit_Price_Cost__c where Deal_Item__c In :dealItemIdList';
                    
                    List<Deal_Unit_Price_Cost__c> dealUnitPriceAndCostList = Database.query(query);
                    
                    List<Unit_Price_Cost__c> unitPriceAndCostListToUpsert = new List<Unit_Price_Cost__c>();
                    Map<String, Unit_Price_Cost__c> unitIdToBaseUPCRecToInsertMap = new Map<String, Unit_Price_Cost__c>();
                    Map<String, Unit_Price_Cost__c> priceAndCostIdToRecMap = new Map<String, Unit_Price_Cost__c>();
                    Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
                    
                    for(Deal_Unit_Price_Cost__c dealUnitPriceAndCostRec : dealUnitPriceAndCostList) {
                    	Decimal price = isTaxIncludingPricing ? dealUnitPriceAndCostRec.Price_When_Tax_Included__c : dealUnitPriceAndCostRec.Price__c;
                    	price = price != null ? price : 0;
                    	
                        Unit_Price_Cost__c unitPriceAndCostRec = new Unit_Price_Cost__c(Id = dealUnitPriceAndCostRec.Unit_Price_Cost__c, Price__c = price);
                        if(dealUnitPriceAndCostRec.Type__c == 'Base' || dealUnitPriceAndCostRec.Type__c == 'Factory') {
                            unitPriceAndCostRec.Total_Price__c = price;
                        } else {
                        	dealUnitPriceAndCostRec.Qty__c = (dealUnitPriceAndCostRec.Qty__c != null && dealUnitPriceAndCostRec.Qty__c != 0) ? dealUnitPriceAndCostRec.Qty__c : 1;
                        	dealUnitPriceAndCostRec.Price__c = price;
                        	unitPriceAndCostRec.Total_Price__c = (price.setScale(2, RoundingMode.HALF_UP) * dealUnitPriceAndCostRec.Qty__c);
                        }
                        if(dealUnitPriceAndCostRec.Type__c == 'Base' && String.isBlank(unitPriceAndCostRec.Id)) {
                        	unitPriceAndCostRec.Customer_Owned_Unit__c = dealUnitPriceAndCostRec.Deal_Item__r.Customer_Owned_Unit__c;
                        	unitPriceAndCostRec.Type__c = dealUnitPriceAndCostRec.Type__c;
                        	unitIdToBaseUPCRecToInsertMap.put(dealUnitPriceAndCostRec.Deal_Item__r.Customer_Owned_Unit__c, unitPriceAndCostRec);
                        } else {
	                        unitPriceAndCostListToUpsert.add(unitPriceAndCostRec);
	                        priceAndCostIdToRecMap.put(unitPriceAndCostRec.Id, unitPriceAndCostRec);
                        }
                    }
                    if(unitPriceAndCostListToUpsert.size() > 0 || unitIdToBaseUPCRecToInsertMap.size() > 0) {
                        for(Customer_Owned_Unit__c unitRec : unitListToUpdateStatus) {
                            if(unitRec.Unit_Type__c.toLowerCase() == 'stock') {
                                for(Unit_Price_Cost__c priceAndCostRec : unitRec.Unit_Prices_Costs__r) {
                    				if(priceAndCostRec.Type__c == 'Base' && !priceAndCostIdToRecMap.containsKey(priceAndCostRec.Id)) {
                    					if(unitIdToBaseUPCRecToInsertMap.containsKey(unitRec.Id) && String.isBlank(unitIdToBaseUPCRecToInsertMap.get(unitRec.Id).Id)) {
                    						unitIdToBaseUPCRecToInsertMap.get(unitRec.Id).Id = priceAndCostRec.Id;
                    					} else {
                                        priceAndCostRec.Total_Price__c = priceAndCostRec.Price__c = 0;
                    						unitPriceAndCostListToUpsert.add(priceAndCostRec);
                    					}
                                    }
                                }
                            }
                        }
                        if(AccessControl.ifObjectFieldIsCreateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                        if(AccessControl.ifObjectFieldIsUpdateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                        if(unitIdToBaseUPCRecToInsertMap.size() > 0) {
                        	unitPriceAndCostListToUpsert.addAll(unitIdToBaseUPCRecToInsertMap.values());
                        }
                        upsert unitPriceAndCostListToUpsert;
                    }
                }
                String defaultUnitSalesTaxId = Configurations__c.getInstance().Default_Tax_on_Unit__c;
                for(Customer_Owned_Unit__c unitRec : unitListToUpdateStatus) {
                    SObject unitToInsert = unitRec.clone(false, false, false, false);
                    if(unitRec.Unit_Type__c != null && unitRec.Unit_Type__c.toLowerCase() == 'stock') {
                        unitRec.Status__c = 'Sold';
                        unitRec.Date_Stocked_Out__c = date.newinstance(invoiceDate.year(), invoiceDate.month(), invoiceDate.day());
                        
                        unitToInsert.put('Id',null);
                        unitToInsert.put('Unit_Type__c','COU');
                        unitToInsert.put('Status__c','Active');
                        unitToInsert.put('Notes__c','');
                        unitToInsert.put('Account__c', dealList[0].CO_Header__r.Customer__c);
                        
                        unitToInsert.put('Stock_Id__c',null);
                        unitToInsert.put('Unit_Id__c',null);
                        unitToInsert.put('New_Unit__c',false);
                        unitToInsert.put('Category__c',null);
                        unitToInsert.put('Date_Stocked_In__c', null);
                        unitToInsert.put('Date_Stocked_Out__c',null);
                        unitToInsert.put('Location__c',null);
                        
                        unitToInsert.put('Total_Base_Unit_Price__c',null);
                        unitToInsert.put('Total_Base_Units_Cost__c',null);
                        unitToInsert.put('Total_Dealer_Options_Cost__c',null);
                        unitToInsert.put('Total_Dealer_Options_Price__c', null);
                        unitToInsert.put('Total_Factory_Options_Cost__c',null);
                        unitToInsert.put('Total_Factory_Options_Price__c',null);
                        unitToInsert.put('Manufactured_Date__c',null);
                        unitToInsert.put('Total_Cost__c',null);
                        unitToInsert.put('Total_Price__c',null);                        
                    } 
                    else if(unitRec.Unit_Type__c != null && unitRec.Unit_Type__c.toLowerCase() == 'cou') {
                        unitRec.Status__c = 'Transferred';
                        
                        unitToInsert.put('Id',null);
                        unitToInsert.put('Unit_Type__c', 'STOCK');
                        unitToInsert.put('Status__c','Available');
                        unitToInsert.put('New_Unit__c',false);
                        unitToInsert.put('Account__c', null);
                        
                        unitToInsert.put('Taxable__c',true);
                        unitToInsert.put('Applicable_Tax__c', defaultUnitSalesTaxId);
                        
                        unitToInsert.put('Stock_Id__c',null);
                        unitToInsert.put('Unit_Id__c',null);
                        unitToInsert.put('Date_Stocked_In__c', date.newinstance(invoiceDate.year(), invoiceDate.month(), invoiceDate.day()));
                        
                        if(GeneralConfiguration.getAccrueTradeTaxUntilUnitSold()) {
                            DealService.populateTradeInAndSalesTaxOnSku(couIdToDealItemRecMap.get(unitRec.Id), unitToInsert);
                        }
                    }
                    couIdToRelatedCOUMap.put(unitRec.Id, (Customer_Owned_Unit__c)unitToInsert);
                }

                if(couIdToRelatedCOUMap.values().size() > 0) {
                    if(AccessControl.ifObjectFieldIsCreateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                    insert couIdToRelatedCOUMap.values();
                }
                
                if(unitListToUpdateStatus.size() > 0) {
                    if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update unitListToUpdateStatus;
                }
                
                for(String unitId : couIdToDealItemRecMap.keySet()) {
                    Customer_Owned_Unit__c unitRec = couIdToRelatedCOUMap.get(unitId);
                    Unit_Price_Cost__c untPriceCostRec = new Unit_Price_Cost__c(Customer_Owned_Unit__c = unitRec.Id);
                    untPriceCostRec.Type__c = 'Base';
                    untPriceCostRec.Item_Description__c = Constants.CUSTOMER_TRADE_IN;
                    // added by subhrant 
                    untPriceCostRec.CO_Invoice_Header__c = coInvoiceNumber;
                    untPriceCostRec.Ref_No__c = coInvoiceNumber;
                    untPriceCostRec.Total_Price__c = couIdToDealItemRecMap.get(unitId).Agreed_Value__c;
                    untPriceCostRec.Total_Cost__c = couIdToDealItemRecMap.get(unitId).Actual_Cash_Value__c;
                    
                    unitPriceAndCostList.add(untPriceCostRec);
                    
                    dealItemIdToStockedInUnitIdMap.put(couIdToDealItemRecMap.get(unitId).Id, couIdToRelatedCOUMap.get(unitId).Id);
                }
                
                if(unitPriceAndCostList.size() > 0) {
                    if(AccessControl.ifObjectFieldIsCreateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                    insert unitPriceAndCostList;
                }
                
                List<Deal_Item__c> dealItemToUpdateList = new List<Deal_Item__c>();
                for(Id dealItemId: dealItemIdToStockedInUnitIdMap.keySet()) {
                    dealItemToUpdateList.add(new Deal_Item__c(Id = dealItemId, Stocked_In_Unit__c = dealItemIdToStockedInUnitIdMap.get(dealItemId)));
                }
                
                if(dealItemToUpdateList.size() > 0) {
                    if(AccessControl.ifObjectFieldIsCreateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                    update dealItemToUpdateList;
                }
                
                dealList[0].Status__c = Constants.DEAL_STATUS_INVOICED;
                dealList[0].Invoice_Number__c = coInvoiceNumber;
                if(AccessControl.ifObjectFieldIsUpdateable('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update dealList;
                
            }
        }
    }
    
    //Sprint 36
    @RemoteAction
    global static String updateDealFinanceStatus(String coHeaderId, String dealId, String dealFinanceObjJson, String financeStatus) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        dealId = BPUtility.getDecodedString(dealId);
        dealFinanceObjJson = BPUtility.getDecodedString(dealFinanceObjJson);
        financeStatus = BPUtility.getDecodedString(financeStatus);
        DealWrapper.DealFinanceWrapper dealFinanceObj = (DealWrapper.DealFinanceWrapper) System.JSON.deserialize(dealFinanceObjJson, DealWrapper.DealFinanceWrapper.class);
        
        if(String.isBlank(dealFinanceObj.Id)) {
            return BPUtility.getEncodedString('{}');
        }  
        DealService.updateFinanceStatus(coHeaderId, dealId, dealFinanceObj, financeStatus);      
        return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,pinItems,checkOut'));
    }
    
    private static String insertDealKHByCOKH(String kitHeaderId, String dealItemId, String dealId, String chargeMethod, Boolean isInstall, String fullfilmentRecId) {
        if(dealItemId == null) {
            return null;
        }
        if(AccessControl.ifObjectFieldIsAccessible('Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Kit_Header__c> kitHeaderList = SOQLUtil.getKitHeaderRec(new Map<String, String>{ 'Id' => kitHeaderId });
        String status = Constants.COMMITTED;
        List<SObject> sObjectListToUpdate = new List<SObject>();
        if(isInstall) {
            List<Service_Order_Kit_Header__c> sokitHeaderList = [Select Id, Service_Order_Header__r.Work_Status__c, (Select Id, Kit_Price__c, Price_When_Tax_Included__c, Kit_Header_Line_Item__c from Service_Order_Line_Items__r) from Service_Order_Kit_Header__c where Id =: fullfilmentRecId];
            if(sokitHeaderList.size() > 0) {
                status = ((sokitHeaderList[0].Service_Order_Header__r.Work_Status__c != null) && (sokitHeaderList[0].Service_Order_Header__r.Work_Status__c == Constants.DEAL_STATUS_INVOICED)) ?
                                                 Constants.FULFILLED : null;
                sObjectListToUpdate.addAll((List<SObject>)sokitHeaderList[0].Service_Order_Line_Items__r);
            }
        } else {
            List<CO_Kit_Header__c> cokitHeaderList = [Select Id,(Select Id, Closed_CO_Invoice_link__c, Price__c, Price_When_Tax_Included__c, Kit_Header_Line_Item__c from CO_Line_Items__r) from CO_Kit_Header__c where Id =: fullfilmentRecId];
            if(cokitHeaderList.size() > 0 && cokitHeaderList[0].CO_Line_Items__r.size() > 0) {
                status = (cokitHeaderList[0].CO_Line_Items__r[0].Closed_CO_Invoice_link__c != null) ? Constants.FULFILLED : null;
                sObjectListToUpdate.addAll((List<SObject>)cokitHeaderList[0].CO_Line_Items__r);
            }
        }
        
        if(kitHeaderList.size() == 0) {
            return null;
        }
        
        Deal_Kit_Header__c dkhRec = setDealKitHeaderFields(kitHeaderList[0]);
        dkhRec.Deal_Item__c = dealItemId;
        if(chargeMethod == Constants.CHARGE_METHOD_DO_NOT_INVOICE) {
            dkhRec.Fixed_Price__c = 0;
            dkhRec.Actual_Kit_Price__c = 0;
        }
        
        dkhRec.Is_Install__c = isInstall;
        if(AccessControl.ifObjectFieldIsCreateable('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert dkhRec;
        
        List<Option_Fee__c> optionAndFeeList = insertAllKitLineItemsInDeal(kitHeaderId, dealItemId, dealId, dkhRec.Id, status, chargeMethod, sObjectListToUpdate);
        for(SObject sObjRec : sObjectListToUpdate) {
            for(Option_Fee__c oandFRec : optionAndFeeList) {
                if(oandFRec.Kit_Header_Line_Item__c == sObjRec.get('Kit_Header_Line_Item__c')) {
                    sObjRec.put('Option_Fee__c', oandFRec.Id);
                    if(!isInstall) {
                        sObjRec.put('Related_Option_And_Fees__c', oandFRec.Id);
                    }
                    break;
                }
            }
        }
        update sObjectListToUpdate;
        
        if(chargeMethod != Constants.CHARGE_METHOD_DO_NOT_INVOICE) {
            DealKH_Recalculation.calculatePriceForDealKitInsertion(dkhRec.Id, dealItemId);
        }
        
        return dkhRec.Id;
    }
    
    private static Deal_Kit_Header__c setDealKitHeaderFields(Kit_Header__c kitHeaderRec) {
        Deal_Kit_Header__c dkhRec = new Deal_Kit_Header__c();
        
        dkhRec.Kit_Header__c = kitHeaderRec.Id;
        dkhRec.Can_Split__c = kitHeaderRec.Can_Split__c;
        dkhRec.Code__c = kitHeaderRec.Code__c;
        dkhRec.Description__c = kitHeaderRec.Description__c;
        dkhRec.Is_Fixed_Price__c = kitHeaderRec.Fixed_Price_Flag__c;
        dkhRec.Service_Kit__c = kitHeaderRec.Service_Kit__c;
        dkhRec.Fixed_Price__c = kitHeaderRec.Fixed_Price__c;
        dkhRec.Actual_Kit_Price__c = kitHeaderRec.Fixed_Price__c;
        return dkhRec;
    }
    
    
    //Sprint 37
    private static Id insertDealKitHeaderInGrid(String lineItemId, String dealItemId, String dealId, String coHeaderId) {
        if(AccessControl.ifObjectFieldIsCreateable('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        Savepoint sp = Database.setSavepoint();
        try {
            
            if(AccessControl.ifObjectFieldIsAccessible('Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Kit_Header__c> kitHeaderList = SOQLUtil.getKitHeaderRec(new Map<String, String>{ 'Id' => lineItemId });
            if(kitHeaderList.size() == 0) {
                return null;
            }
            
            Deal_Kit_Header__c dkhRec = setDealKitHeaderFields(kitHeaderList[0]);
            dkhRec.Deal_Item__c = dealItemId;
            if(kitHeaderList[0].Service_Kit__c != null && kitHeaderList[0].Service_Kit__c) {
                dkhRec.Is_Install__c = true;
            } else {
                dkhRec.Is_Install__c = false;
            }
            insert dkhRec;
            
            insertAllKitLineItemsInDeal(lineItemId, dealItemId, dealId, dkhRec.Id, null, null, null);
            
            DealKH_Recalculation.calculatePriceForDealKitInsertion(dkhRec.Id, dealItemId);
            return dkhRec.Id;
        } catch(Exception e) {
            Database.rollback(sp);
            system.assert(false, e);
        }
        
        return null;
    }
   
    private static List<Option_Fee__c> insertAllKitLineItemsInDeal(String lineItemId, String dealItemId, String dealId, String dkhRecId, String status, String chargeMethod, 
            List<SObject> sObjectListToUpdate) {
        if(AccessControl.ifObjectFieldIsCreateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Kit_Header_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Option_Fee__c> optionAndFeeListToInsert = new List<Option_Fee__c>();
        
        List<Kit_Header_Line_Item__c> khLineItemList = SOQLUtil.getKHLineItemRec(new Map<String, String>{ 'Kit_Header__c' => lineItemId });
        if(khLineItemList.size() == 0) {
            return null;
        }
        
        for(Kit_Header_Line_Item__c khliRec : khLineItemList) {
            Option_Fee__c optionAndFeeRec = new Option_Fee__c(Kit_Header_Line_Item__c = khliRec.Id);
            optionAndFeeRec.Deal__c = dealId;
            optionAndFeeRec.Deal_Item__c = dealItemId;
            optionAndFeeRec.Deal_Kit_Header__c = dkhRecId;
            optionAndFeeRec.Fixed_Price__c = khliRec.Kit_Price__c;
            optionAndFeeRec.Is_Fixed_Price__c = khliRec.Fixed_Price__c;
            optionAndFeeRec.Is_Fixed_Kit_Line_Item_CO__c = false;
            optionAndFeeRec.Part__c = khliRec.Part__c;
            optionAndFeeRec.Status__c = (status != null) ? status : Constants.COMMITTED;
            optionAndFeeRec.Labour_Code__c = khliRec.Labour_Code__c;
            optionAndFeeRec.Fee__c = khliRec.Fee__c;
            optionAndFeeRec.Price__c = (khliRec.Kit_Price__c != null) ? khliRec.Kit_Price__c : 0;
            optionAndFeeRec.Qty__c = (khliRec.Qty_Needed__c == null) ? 1 : khliRec.Qty_Needed__c;
            if(optionAndFeeRec.Fee__c != null) {
                optionAndFeeRec.Price__c = khliRec.Kit_Price__c;
                optionAndFeeRec.Qty__c = (khliRec.Qty_Needed__c == null) ? 1 : khliRec.Qty_Needed__c;
            }
            optionAndFeeRec.Actual_Kit_Price__c = khliRec.Kit_Price__c;
            optionAndFeeRec.Price_When_Tax_Included__c = optionAndFeeRec.Price__c;
            optionAndFeeRec.Item_Code__c = khliRec.Item_Code__c;
            optionAndFeeRec.Item_Description__c = khliRec.Item_Description__c;
            if(chargeMethod != null && chargeMethod == Constants.CHARGE_METHOD_DO_NOT_INVOICE) {
                optionAndFeeRec.Price__c = optionAndFeeRec.Price_When_Tax_Included__c = 0;
            }
            if(sObjectListToUpdate != null) {
                for(SObject sObjRec : sObjectListToUpdate) {
                    if(sObjRec.get('Kit_Header_Line_Item__c') == khliRec.Id) {
                        if((Id.valueOf(string.valueOf(sObjRec.get('Id')))).getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Service_Order_Line_Item__c') {
                            optionAndFeeRec.Per_Item_Cost__c = Decimal.valueOf(String.valueOf(sObjRec.get('Kit_Price__c')) != null ? String.valueOf(sObjRec.get('Kit_Price__c')) : 
                                String.valueOf(sObjRec.get('Price_When_Tax_Included__c')));
                        } else {
                            optionAndFeeRec.Per_Item_Cost__c = Decimal.valueOf(String.valueOf(sObjRec.get('Price__c')) != null ? String.valueOf(sObjRec.get('Price__c')) : 
                                String.valueOf(sObjRec.get('Price_When_Tax_Included__c')));
                        }
                    }
                }
            }
            optionAndFeeListToInsert.add(optionAndFeeRec);
        }
        
        if(optionAndFeeListToInsert.size() > 0) {
            insert optionAndFeeListToInsert;
        }
        
        return optionAndFeeListToInsert;
    }
    
    private static String removeDealKHItems(String lineItemId) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        lineItemId = BPUtility.escapeSingleQuotes(lineItemId);

        List<Deal_Kit_Header__c> dealKHList = [select Id, Deal_Item__r.Deal__c, Deal_Item__r.Deal__r.Status__c, 
                                                    (Select Id from Options_Fees__r) from Deal_Kit_Header__c where Id =: lineItemId];
        String dealId = dealKHList[0].Deal_Item__r.Deal__c;
        if(dealKHList[0].Deal_Item__r.Deal__r.Status__c != 'Invoiced') {
        List<SObject> sObjectListToDelete = new List<SObject>();
        sObjectListToDelete.addAll((List<SObject>) dealKHList);
        for(Deal_Kit_Header__c dealKHRec : dealKHList) {
            if(dealKHRec.Options_Fees__r != null && dealKHRec.Options_Fees__r.size() > 0) {
                sObjectListToDelete.addAll((List<SObject>) dealKHRec.Options_Fees__r);
            }
        }
        if(sObjectListToDelete.size() > 0) {
            delete sObjectListToDelete;
        }
        }
        return dealId;
    } 
    
    @RemoteAction
    global static String recalculationOfDealKHLineItems(String dealKHJSON, String dealKHLineItemJSON) {
        dealKHJSON = BPUtility.getDecodedString(dealKHJSON);
        dealKHLineItemJSON = BPUtility.getDecodedString(dealKHLineItemJSON);
        
        DealWrapper.DealKitHeader dealKHObj = (DealWrapper.DealKitHeader) System.JSON.deserialize(dealKHJSON, DealWrapper.DealKitHeader.class);
        String resultStr;
        
        if(dealKHLineItemJSON != 'null') {
            DealWrapper.OptionAndFeeInfo dealKHLineItemObj = (DealWrapper.OptionAndFeeInfo) System.JSON.deserialize(dealKHLineItemJSON, DealWrapper.OptionAndFeeInfo.class);            
            if(String.isNotBlank(dealKHLineItemObj.FeeId) || String.isNotBlank(dealKHLineItemObj.LabourId)) {
                if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Option_Fee__c> optionFeeList = [select Item_Description__c from Option_Fee__c where Id =: dealKHLineItemObj.Id];
                if(optionFeeList.size() > 0 && optionFeeList[0].Item_Description__c != dealKHLineItemObj.ItemDescription) {
                    Option_Fee__c optionFeeToUpdate = new Option_Fee__c(Id = dealKHLineItemObj.Id);
                    optionFeeToUpdate.Item_Description__c = dealKHLineItemObj.ItemDescription;
                    if(AccessControl.ifObjectFieldIsUpdateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update optionFeeToUpdate;
                }
            }
            
            if(!dealKHLineItemObj.IsFixedPrice) {
                resultStr = DealKH_Recalculation.updateDealKitLineItem(dealKHObj, dealKHLineItemObj);
            } 
        } else if(!dealKHObj.IsFixedPrice){
            resultStr = DealKH_Recalculation.updateDealKitHeader(dealKHObj);  
        } else {
            if(AccessControl.ifObjectFieldIsAccessible('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Deal_Kit_Header__c> dealKHList = [Select Is_Install__c, Deal_Item__r.Option_And_Fee_Status__c, Deal_Item__r.Deal__r.Status__c from Deal_Kit_Header__c where Id =: dealKHObj.Id];
            if(dealKHList.size() > 0) {
                if(dealKHList[0].Is_Install__c != dealKHObj.IsInstall) {
                    dealKHList[0].Is_Install__c = dealKHObj.IsInstall;
                    if(AccessControl.ifObjectFieldIsUpdateable('Deal_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update dealKHList;
                    if((dealKHList[0].Deal_Item__r.Deal__r.Status__c == Constants.IN_PROGRESS || dealKHList[0].Deal_Item__r.Deal__r.Status__c == 'Approved') && dealKHList[0].Deal_Item__r.Option_And_Fee_Status__c == Constants.COMMITTED) {
                        CustomerOrderCtrl.moveDealMerchAndServiceLineItems(BPUtility.getEncodedString(dealKHObj.Id), BPUtility.getEncodedString(dealKHObj.CoHeaderId));
                    }
                    resultStr = 'Success';
                }
            }
        }
        if(String.isNotBlank(resultStr) && resultStr == 'Success') {
            error = new SO_KLI_Recalculation.Errorhandler('200', 'Saved Successfully');
        } else if(String.isNotBlank(resultStr)){
            error = new SO_KLI_Recalculation.Errorhandler('300', resultStr);
        }        
         return getDealItemDetails(dealKHObj.DealItemId);
    }
    
    @remoteAction
    global static String insertKitHeaderInDealMerchGrid(String kitHeaderId, String dealId, String coHeaderId) {
        kitHeaderId = BPUtility.getDecodedString(kitHeaderId);
        dealId = BPUtility.getDecodedString(dealId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        Savepoint sp = Database.setSavepoint();
        try{
            MerchandiseService.insertKitHeaderInDealMerchGrid(kitHeaderId, dealId, coHeaderId);
            return getDealDetails(BPUtility.getEncodedString(dealId), BPUtility.getEncodedString('dealUnresolvedFulfillmentAndDealFulfillment'));
        }catch(Exception e){
            Database.rollback(sp);
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
     /**
    * Name: isSuppressLineItemOnCO
    * Desc: Method Which saves CO Line Items in Database 
    * @param:   (1) coHeaderId - String - CO Header record Id
    *           (2) partId - String - JSON String of CO Line Items
    * @return: String - JSON String of CO Header Detail Record
    **/
    public static boolean isSuppressLineItemOnCO(String coHeaderId, String partId){
        if(AccessControl.ifObjectFieldIsAccessible('Suppress_CO_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Suppress_CO_Item__c> suppressCOItemList = [SELECT Id FROM Suppress_CO_Item__c where CO_Header__c =: coHeaderId 
                                                                    AND Part__c =: partId AND User__c =: UserInfo.getUserId()];   
        return (suppressCOItemList.size() > 0);
    }
    
     /**
    * Name: InsertSuppressLineItem
    * Desc: Method Which saves CO Line Items in Database 
    * @return: void 
    **/
    public static void insertSuppressLineItem(String coHeaderId, String partId){
        if(coHeaderId != null &&  partId != null){
            Suppress_CO_Item__c SuppressCoItemRec = new Suppress_CO_Item__c(CO_Header__c = coHeaderId, Part__c = partId, User__c = UserInfo.getUserId());
            if(AccessControl.ifObjectFieldIsCreateable('Suppress_CO_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert SuppressCoItemRec;
        }   
    }
    
    @remoteAction
    global static String insertCOLineItems(String partId, String coHeaderId, String jSONString, Boolean isSuppress, Boolean isDuplicateCheck, String soHeaderId, String customerId) {
        partId = BPUtility.getDecodedString(partId);
        
        String resultStr = '{}';
        
        if(isSuppress || String.isBlank(partId)) {
            if(isSuppress) {
                insertSuppressLineItem(BPUtility.getDecodedString(coHeaderId), partId);
            }
            if(String.isNotBlank(BPUtility.getDecodedString(soHeaderId)) && BPUtility.getDecodedString(soHeaderId) != 'null') {
                resultStr = addLineItems(BPUtility.getEncodedString(partId), soHeaderId, coHeaderId, customerId);
            } else {
                resultStr = saveCOLineItem(coHeaderId, jSONString);
            }
        } else if(String.isNotBlank(partId)) {
            coHeaderId = BPUtility.getDecodedString(coHeaderId);
            if(isDuplicateCheck && !isSuppressLineItemOnCO(coHeaderId, partId) && isDuplicatePartOnCO(coHeaderId, partId)) {
                resultStr = BPUtility.getEncodedString('{"DuplicatePart" : true}');
            } else { 
                if(String.isNotBlank(BPUtility.getDecodedString(soHeaderId)) && BPUtility.getDecodedString(soHeaderId) != 'null') {
                    resultStr = addLineItems(BPUtility.getEncodedString(partId), soHeaderId, BPUtility.getEncodedString(coHeaderId), customerId);
                } else {
                    resultStr = saveCOLineItem(BPUtility.getEncodedString(coHeaderId), jSONString);
                }
            }
        }
        return resultStr;
    }
    
    @remoteAction
    global static String insertOptionAndFeeLineItems(String partId, String coHeaderId, String dealId, String dealItemId, String jSONString, Boolean isSuppress, Boolean isDuplicateCheck) {
        partId = BPUtility.getDecodedString(partId);    
        String resultStr = '{}';
        if(isSuppress || String.isBlank(partId)) {
            if(isSuppress) {
                insertSuppressLineItem(BPUtility.getDecodedString(coHeaderId), partId);
            }
            resultStr = saveOptionFeesLineItem(dealId, dealItemId, jSONString);
        } else if(String.isNotBlank(partId)) {
            coHeaderId = BPUtility.getDecodedString(coHeaderId);
            if(isDuplicateCheck && !isSuppressLineItemOnCO(coHeaderId, partId) && isDuplicatePartOnCO(coHeaderId, partId)) {
                resultStr = BPUtility.getEncodedString('{"DuplicatePart" : true}');
            } else { 
                resultStr = saveOptionFeesLineItem(dealId, dealItemId, jSONString);
            }
        }
        return resultStr;
    }
    
    public static Boolean isDuplicatePartOnCO(String coHeaderId, String partId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        
        //Analysis : Limit in each query for size chk
        List<CO_Header__c> coHeaderList = [Select Id, (Select Id from CO_Line_Items__r where Part__c =: partId LIMIT 1), (Select Id from Deals__r) from CO_Header__c where Id =: coHeaderId];
        if(coHeaderList.size() > 0) {
            if(coHeaderList[0].CO_Line_Items__r.size() > 0) {
                return true;
            }
            if(coHeaderList[0].Deals__r.size() > 0) {
                List<Deal_Item__c> dealItemList = [Select Id, (Select Id from Options_Fees__r where Part__c =: partId LIMIT 1) from Deal_Item__c where Deal__c =: coHeaderList[0].Deals__r[0].Id];
                for(Deal_Item__c dealItemRec : dealItemList) {
                    if(dealItemRec.Options_Fees__r.size() > 0) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    @remoteAction 
    global static String showHistoryOnSuppressPopup(String partId, String coHeaderId) {
        partId = BPUtility.getDecodedString(partId);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        
        List<DuplicatePartWrapper> duplicatePartList = new List<DuplicatePartWrapper>(); 
        List<CO_Line_Item__c> coliList = [Select Id, Qty__c, Service_Order_Line_Item__c, Deal__c,
                                                Service_Order_Line_Item__r.Service_Order_Header__r.Name__c, Service_Order_Line_Item__r.Qty_Needed__c
                                                 from CO_Line_Item__c where Part__c =: partId
                                                AND CO_Header__c =: coHeaderId ];
        for(CO_Line_Item__c coliRec : coliList) {
            duplicatePartList.add(new DuplicatePartWrapper(coliRec));
        }
        
        List<Option_Fee__c> optionFeeList = [Select Qty__c, Deal_Item__c, Deal_Item__r.Name__c
                                                 from Option_Fee__c where Part__c =: partId
                                                AND Deal_Item__r.Deal__r.CO_Header__c =: coHeaderId
                                                AND Deal_Item__r.Deal__r.Status__c = 'Quotation'];
        for(Option_Fee__c optionFeeRec : optionFeeList) {
            duplicatePartList.add(new DuplicatePartWrapper(optionFeeRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(duplicatePartList));
        
    }
    
    @remoteAction 
    global static String getCOUListByCustomerId(String customerId) {
        customerId = BPUtility.getDecodedString(customerId);
        List<Customer_Owned_Unit__c> couList = (List<Customer_Owned_Unit__c>) SOQLUtil.getCOUListByFieldName('Account__c', customerId);
        List<CustomerOwnedUnit> couObjList = new List<CustomerOwnedUnit>();
        for(Customer_Owned_Unit__c couRec : couList) {
            couObjList.add(new CustomerOwnedUnit(couRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(couObjList));
    }
    
    @remoteAction 
    global static String getTechnicianList() {
        List<Technician__c> technicianRecList = SOQLUtil.getTechnicianListByFieldName(new Map<String, String>{'Type__c' => Constants.TECHNICIAN});
        List<SOHeaderWrapper.TechnicianWrapper> technicianObjList = new List<SOHeaderWrapper.TechnicianWrapper>();
        for(Technician__c technicianRec : technicianRecList) {
            technicianObjList.add(new SOHeaderWrapper.TechnicianWrapper(technicianRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(technicianObjList));
    }
    
     @remoteAction
    global static void saveScheduleDate(String soHeaderId, String scheduledDate) {
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        scheduledDate = BPUtility.getDecodedString(scheduledDate);
       
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            
 
        Service_Order_Header__c soHeader = new Service_Order_Header__c(Id = soHeaderId);
            
        soHeader.Scheduled_Date__c = String.isNotBlank(scheduledDate) ? Date.parse(scheduledDate) : null;
            
        update soHeader;
      
    }
    /* START: added by Kajal - 14th june 2017 #2344 */
    /**
    * Name: removeMerchandiseSection 
    * Desc: Method to set flag to delete emplty merchandise section on Customer Order Page
    * @param:  (1) coHeaderId - String - Id of CO Header Record
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction  
    global static void removeMerchandiseSection(String coHeaderId, Boolean flag){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        if(coHeaderId != null) {
            updateMerchSectionToDisplay(coHeaderId, flag);
        }
    }
    
    private static void updateMerchSectionToDisplay(String coHeaderId, Boolean flag){
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        CO_Header__c coHeaderRec = new CO_Header__c(Id = coHeaderId, Hide_Merchandise_Section__c = flag);
        COTriggerHelper.isTriggerExecute = true;
        update coHeaderRec;
    }
    
    /* END: added by Kajal - 14th june 2017 #2344 */
    
    
    @remoteAction
    global static String getCheckoutSalesTax(String coInvoiceId){ 
        coInvoiceId = BPUtility.getDecodedString(coInvoiceId);
        List<CO_Invoice_Header__c> coInvoices = [select Id, Invoice_Status__c,
                                                (SELECT isActive__c, CO_Line_Item__c, CO_Kit_Header__c, Service_Order_Header__c, Deal__c,
                                                Service_Order_Header__r.Transaction_Type__r.Type__c,
                                                Deal__r.Type__c FROM CO_Invoice_Items__r)
                                                FROM CO_Invoice_Header__c 
                                                WHERE Id = :coInvoiceId];
        List<PrintCustomerOrderInvoiceCtrl.TaxDetail> taxDetails = new  List<PrintCustomerOrderInvoiceCtrl.TaxDetail>();
        
        if(coInvoices.size() > 0) {
            Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>();  
            List<Id> coliIds = new List<Id>();
            List<Id> sohIds = new List<Id>();
            List<Id> cokhIds = new List<Id>();
            List<Id> dealIds = new List<Id>();
            String PermissionStr = NewHomePageCtrl.getUserPermissions(UserInfo.getUserId());// Added By Pooja for Checkout Payment section related changes: 14 Sep 2017
            UserGroupWrapper PermissionObj = (UserGroupWrapper) System.JSON.deserialize(PermissionStr, UserGroupWrapper.class); // Added By Pooja for Checkout Payment section related changes: 14 Sep 2017
            if(coInvoices[0].CO_Invoice_Items__r != null) {
                for(CO_Invoice_Item__c coInvoiceItem : coInvoices[0].CO_Invoice_Items__r){
                    if(coInvoiceItem.isActive__c){
                        // Start: Commented And Changed By Pooja for Checkout Payment section related changes: 14 Sep 2017
                        /**if(coInvoiceItem.CO_Line_Item__c != null) {
                            coliIds.add(coInvoiceItem.CO_Line_Item__c);
                        }
                        if(coInvoiceItem.Service_Order_Header__c != null) {
                            sohIds.add(coInvoiceItem.Service_Order_Header__c);
                        }
                        if(coInvoiceItem.CO_Kit_Header__c != null) {
                            cokhIds.add(coInvoiceItem.CO_Kit_Header__c);
                        }
                        if(coInvoiceItem.Deal__c != null) {
                            dealIds.add(coInvoiceItem.Deal__c);
                        }*/
                        
                        if(coInvoiceItem.CO_Line_Item__c != null) {
                            // Source Section: Merchandise, Checkout type: Customer && Merchandise>create/modify true
                            // Source Section: Deal Merchandise, Checkout type: Deal && Merchandise>create/modify true
                            if(PermissionObj.GroupOnlyPermissions.get('Merchandise').get('create/modify')) {
                                coliIds.add(coInvoiceItem.CO_Line_Item__c);
                            } 
                        }
                        if(coInvoiceItem.Service_Order_Header__c != null) {
                            // Source Section: Service job (type=internal), Checkout type: Internal && Internal Service>create/modify true
                            if(coInvoiceItem.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Internal' 
                                && PermissionObj.GroupOnlyPermissions.get('Internal Service').get('create/modify')) {
                                sohIds.add(coInvoiceItem.Service_Order_Header__c);
                            }else {
                                // Source Section: Service job, Checkout type: Customer && Service job>create/modify true
                                // Source Section: Deal Service, Checkout type: Deal && Service job>create/modify true
                                if(PermissionObj.GroupOnlyPermissions.get('Service job').get('create/modify'))    {
                                    sohIds.add(coInvoiceItem.Service_Order_Header__c);
                                }
                            }
                        }
                        if(coInvoiceItem.CO_Kit_Header__c != null) {
                            // Source Section: Merchandise, Checkout type: Customer && Merchandise>create/modify true
                            // Source Section: Deal Merchandise, Checkout type: Deal && Merchandise>create/modify true
                            if(PermissionObj.GroupOnlyPermissions.get('Merchandise').get('create/modify')) {
                                cokhIds.add(coInvoiceItem.CO_Kit_Header__c);
                            }   
                        }
                        if(coInvoiceItem.Deal__c != null) {
                            // Source Section: Deal, Checkout type: Customer && Deal>create/modify true
                            if(coInvoiceItem.Deal__r.Type__c == Constants.CASH_DEAL && PermissionObj.GroupOnlyPermissions.get('Deal').get('create/modify')) {
                                dealIds.add(coInvoiceItem.Deal__c);
                            } /**else if(coInvoiceItemRec.Deal__r.Type__c == Constants.FINANCED) {
                                this.CheckoutType = Constants.CHECKOUT_TYPE_THIRD_PARTY;
                            }*/
                        }
                    }
                }
            }
            
            List<Individual_Tax__c> individualItemsList = [select CO_Line_Item__c, Tax_Rate__c, Form_Label__c, Tax_Amount_To_Invoice__c,
                                                            Sales_Tax_Item_Name__c, Taxable_Amount__c, Tax_Amount__c, Taxable_Amount_To_Invoice__c, 
                                                            Applicable_Tax__c, List_Tax_items_on_forms__c
                                                            from Individual_Tax__c where CO_Line_Item__c IN : coliIds
                                                                OR Service_Order_Line_Item__r.Service_Order_Header__c IN :sohIds
                                                                OR CO_Line_Item__r.CO_Kit_Header__c IN :cokhIds
                                                                OR Option_Fee__r.Deal__c IN: dealIds
                                                                OR Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c IN: dealIds
                                                                OR F_I_Product__r.Deal_Finance__r.Deal__c IN: dealIds
                                                                OR (Deal_Item__r.Deal__c IN: dealIds AND Deal_Item__r.Type__c = 'Trade In')];
            TaxCalculation.isInvoiced = coInvoices[0].Invoice_Status__c == 'Active' ? false : true;
            salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemsList);
            TaxCalculation.isInvoiced = true;
            for(String taxName : salesTaxNameToTaxValue.keySet()){
                taxDetails.add(new PrintCustomerOrderInvoiceCtrl.TaxDetail(taxName, salesTaxNameToTaxValue.get(taxName)));
            }           
        }
        return BPUtility.getEncodedString(System.JSON.serialize(taxDetails));
    }
    
    @RemoteAction
    global static String removeDeal(String dealId) { 
        dealId = BPUtility.getDecodedString(dealId);    
        String coHeaderId;
        String coHeaderStatus = '';
        
        List<SObject> sObjectListToDelete = new List<SObject>{new Deal__c(Id = dealId)};
        if(String.isNotBlank(dealId)) {
            List<Deal__c> dealList = [Select Id, CO_Header__c, (Select Id from Deal_Items__r), (Select Id from Options_Fees__r) From Deal__c where Id =: dealId];
            if(dealList.size() > 0) {
                coHeaderId = dealList[0].CO_Header__c;
                if(dealList[0].Options_Fees__r.size() > 0) {
                    return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'First remove option and fee to remove deal')));
                }
                
                if(dealList[0].Deal_Items__r.size() > 0) {
                    List<Deal_Item__c> dealItemList = [Select Type__c, Customer_Owned_Unit__c From Deal_Item__c where Id In: dealList[0].Deal_Items__r];
                    for(Deal_Item__c dealItemRec : dealItemList) {
                        if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
                            return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'First remove trade-In to remove deal')));
                        } else if(dealItemRec.Customer_Owned_Unit__c != null) {
                            return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'First remove unit to remove deal')));
                        }else {
                            sObjectListToDelete.add(dealItemRec);
                        }
                    }
                }
                if(AccessControl.ifObjectIsDeletable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                delete sObjectListToDelete;
                coHeaderStatus = COService.validateAndCloseCO(coHeaderId);
            }
        }
        return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('success', coHeaderStatus)));
    }
    
    
    @RemoteAction
    global static String deleteCustomerOrder(String coHeaderId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
    	if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
    	if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        
        List<CO_Header__c> coHeaderList = [SELECT Status__c,
                                            	(select Id from CO_Line_Items__r limit 1),
                                            	(select Id from Service_Order_Headers__r limit 1),
                                            	(select Id from Deals__r limit 1),
                                            	(select Amount__c from CO_Deposits__r WHERE Amount__c != null),
                                            	(select Id from CO_Invoice_Headers__r where Invoice_Status__c = 'Closed' limit 1)
                                            FROM CO_Header__c
                                            WHERE Id =: coHeaderId];
                                            
        List<CO_Invoice_Payment__c> paymentList = [SELECT Amount__c from CO_Invoice_Payment__c 
        													WHERE CO_Invoice_Header__r.CO_Header__c =: coHeaderId AND Amount__c != null];                         
        
        String response = 'Error';
        if(coHeaderList.size() > 0) {
            Decimal totalCoDeposits = 0;
            for(CO_Deposit__c coDeposit : coHeaderList[0].CO_Deposits__r) {
                totalCoDeposits += coDeposit.Amount__c;
            }
            
            Decimal totalCoPayments = 0;
	        if(paymentList.size() > 0) {
	            response = 'Error';
	        } else {
	            if(coHeaderList[0].Status__c == 'Open' 
	                && coHeaderList[0].CO_Line_Items__r.size() == 0
	                && coHeaderList[0].Service_Order_Headers__r.size() == 0
	                && coHeaderList[0].Deals__r.size() == 0
	                && (coHeaderList[0].CO_Deposits__r.size() == 0 || totalCoDeposits == 0)
	                && coHeaderList[0].CO_Invoice_Headers__r.size() == 0
	                && (paymentList.size() == 0 || totalCoPayments == 0))
	           {
	           		InternalCommentService.deleteInternalCommentsFromCO(coHeaderId);
	           		
	                CO_Header__c coHeaderRec = new CO_Header__c(Id = coHeaderId);
	                if(AccessControl.ifObjectIsDeletable('CO_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
	                delete coHeaderRec;
	                response = 'Success';
	            }
	        }
        }
        return BPUtility.getEncodedString(response);
    }
    
    @RemoteAction
    global static String setCOStatusAsQuote(String coHeaderId) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        
        // #5353 - update the line items, so that they have qty committed value reset and then delete VOLI
        PartTriggerHelper.isCoToQuoteAction = true;
        List<CO_Line_Item__c> coliList = [Select Id from CO_Line_Item__c where Is_In_Merch_Section__c = true AND CO_Header__c =: coHeaderId];
        update coliList;
        List<Service_Order_Line_Item__c> soliList = [Select Id from Service_Order_Line_Item__c where Service_Order_Header__r.CO_Header__c =: coHeaderId];
        update soliList;
        PartTriggerHelper.isCoToQuoteAction = false;
        //delete VOLIs
        delete [Select Id from Vendor_Order_Line_Item__c where CO_Header__c =: coHeaderId];
        
        List<CO_Header__c> coHeaderList = [Select Order_Status__c, (Select Transaction_Type__c, Work_Status__c from Service_Order_Headers__r), 
                (Select Status__c from Deals__r) from CO_Header__c where Id =: coHeaderId];
        if(coHeaderList.size() > 0) {
            List<SObject> sObjectListToUpdate = new List<SObject>();
            coHeaderList[0].Order_Status__c = 'Quote';
            sObjectListToUpdate.add(coHeaderList[0]);
            
            if(coHeaderList[0].Service_Order_Headers__r.size() > 0) {
                List<Transaction_Type__c> ttRecList = [Select Id from Transaction_Type__c where Type__c = 'Quote' AND Default__c = true];
                String quoteTTRecId = (ttRecList.size() > 0) ? ttRecList[0].Id : null;
                
                for(Service_Order_Header__c soHeaderRec : coHeaderList[0].Service_Order_Headers__r) {
                    soHeaderRec.Transaction_Type__c = quoteTTRecId;
                    soHeaderRec.Work_Status__c = 'Estimate';
                }
                sObjectListToUpdate.addAll((List<SObject>) coHeaderList[0].Service_Order_Headers__r);
            }
            
            for(Deal__c dealRec : coHeaderList[0].Deals__r) {
                dealRec.Status__c = 'Quotation';
            }
            sObjectListToUpdate.addAll((List<SObject>) coHeaderList[0].Deals__r);
            update sObjectListToUpdate;
            return BPUtility.getEncodedString('Status updated successfully');
        }
        return BPUtility.getEncodedString('Error updating status');
    }
    
    @RemoteAction
    global static String activateQuoteCO(String coHeaderId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        
        List<CO_Header__c> coHeaderList = [Select Order_Status__c, 
                                                (Select Id from CO_Line_Items__r where Is_In_Merch_Section__c = true), 
                                                (Select Transaction_Type__c, Work_Status__c from Service_Order_Headers__r), 
                                                (Select Status__c from Deals__r) from CO_Header__c where Id =: coHeaderId];
        if(coHeaderList.size() > 0) {
            List<SObject> sObjectListToUpdate = new List<SObject>();
            List<CO_Line_Item__c> coLineItemToUpdate = new List<CO_Line_Item__c>();
            Set<Id> soHeaderIdSet = new Set<Id>();
            
            coHeaderList[0].Order_Status__c = 'Open';
            sObjectListToUpdate.add(coHeaderList[0]);
            
            coLineItemToUpdate.addAll(coHeaderList[0].CO_Line_Items__r);
            
            if(coHeaderList[0].Service_Order_Headers__r.size() > 0) {
                List<Transaction_Type__c> ttRecList = [Select Id from Transaction_Type__c where Type__c = 'Customer' AND Default__c = true];
                String customerPayTTRecId = (ttRecList.size() > 0) ? ttRecList[0].Id : null;
                
                for(Service_Order_Header__c soHeaderRec : coHeaderList[0].Service_Order_Headers__r) {
                    soHeaderRec.Transaction_Type__c = customerPayTTRecId;
                    soHeaderRec.Work_Status__c = 'New';
                    soHeaderIdSet.add(soHeaderRec.Id);
                }
                sObjectListToUpdate.addAll((List<SObject>) coHeaderList[0].Service_Order_Headers__r);
            }
            update sObjectListToUpdate;
            
            List<Service_Order_Line_Item__c> soliList = [select Id from Service_Order_Line_Item__c where Service_Order_Header__c IN: soHeaderIdSet
                                                                    AND Part__c != null];
            
            if(coLineItemToUpdate.size() > 0) {
                COLineItemTriggerHelper.isActivateQuoteCO = true;
                ServiceOrderLineItemTriggerHelper.isActivateQuoteCO = true;
                update coLineItemToUpdate;
            }
            
            if(soliList.size() > 0) {
                COLineItemTriggerHelper.isActivateQuoteCO = true;
                ServiceOrderLineItemTriggerHelper.isActivateQuoteCO = true;
                update soliList;
            }
            
            return BPUtility.getEncodedString('Success');
        }
        return '';
    }
    
    @RemoteAction
    global static String deleteQuoteCustomerOrder(String coHeaderId){
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    
        List<CO_Header__c> coHeaderList = [select Status__c,
                                            (select Id from CO_Line_Items__r where Service_Order_Line_Item__c = null),
                                            (select Id from Service_Order_Headers__r),
                                            (select Id from Deals__r),
                                            (select Id from CO_Deposits__r),
                                            (select Id from CO_Invoice_Headers__r)
                                            from CO_Header__c
                                            where Id = :coHeaderId];
        
        String response = 'Error';
        if(coHeaderList.size() > 0){
            List<SObject> sOjectListToDelete = new List<SObject>();
            if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
            sOjectListToDelete.addAll((List<SObject>) coHeaderList[0].CO_Line_Items__r);
            
            if(coHeaderList[0].Service_Order_Headers__r.size() > 0) {
                List<Service_Order_Header__c> soHeaderList = [select Id, (Select Id from Service_Order_Line_Items__r), (Select Id from Claims__r), 
                                            (Select Id from SO_Payment_Roles__r) from Service_Order_Header__c where Id IN: coHeaderList[0].Service_Order_Headers__r];
                if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                if(AccessControl.ifObjectIsDeletable('Claim__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                if(AccessControl.ifObjectIsDeletable('SO_Payment_Role__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                if(AccessControl.ifObjectIsDeletable('Service_Order_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                for(Service_Order_Header__c soHeaderRec : soHeaderList) {
                    sOjectListToDelete.addAll((List<SObject>) soHeaderRec.Service_Order_Line_Items__r);
                    sOjectListToDelete.addAll((List<SObject>) soHeaderRec.Claims__r);
                    sOjectListToDelete.addAll((List<SObject>) soHeaderRec.SO_Payment_Roles__r);
                }
                sOjectListToDelete.addAll((List<SObject>) coHeaderList[0].Service_Order_Headers__r);
            }
            
            if(coHeaderList[0].Deals__r.size() > 0) {
                List<Deal_Item__c> dealItemList = [select Id, (Select Id from Options_Fees__r), (Select Id from Deal_Unit_Prices_Costs__r)
                                                                                 from Deal_Item__c where Deal__c IN: coHeaderList[0].Deals__r];
                if(AccessControl.ifObjectIsDeletable('Option_Fee__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                if(AccessControl.ifObjectIsDeletable('Deal_Unit_Price_Cost__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                if(AccessControl.ifObjectIsDeletable('Deal_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                if(AccessControl.ifObjectIsDeletable('Deal__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                for(Deal_Item__c dealItemRec : dealItemList) {
                    sOjectListToDelete.addAll((List<SObject>) dealItemRec.Options_Fees__r);
                    sOjectListToDelete.addAll((List<SObject>) dealItemRec.Deal_Unit_Prices_Costs__r);
                }
                sOjectListToDelete.addAll((List<SObject>) dealItemList);
                sOjectListToDelete.addAll((List<SObject>) coHeaderList[0].Deals__r);
            }
            
            delete sOjectListToDelete;
            sOjectListToDelete.clear();
            
            if(coHeaderList[0].CO_Invoice_Headers__r.size() > 0) {
                List<CO_Invoice_Header__c> invHeaderList = [select Id, (Select Id from CO_Invoice_Payments__r), (Select Id from CO_Invoice_Items__r) from CO_Invoice_Header__c
                                                    where CO_Header__c = :coHeaderId];
                if(AccessControl.ifObjectIsDeletable('CO_Invoice_Payment__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                if(AccessControl.ifObjectIsDeletable('CO_Invoice_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
                for(CO_Invoice_Header__c invHeaderRec : invHeaderList) {
                    sOjectListToDelete.addAll((List<SObject>) invHeaderRec.CO_Invoice_Payments__r);
                    sOjectListToDelete.addAll((List<SObject>) invHeaderRec.CO_Invoice_Items__r);
                }
                sOjectListToDelete.addAll((List<SObject>) coHeaderList[0].CO_Invoice_Headers__r);
            }
            
            if(AccessControl.ifObjectIsDeletable('CO_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
            if(AccessControl.ifObjectIsDeletable('CO_Deposit__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
            sOjectListToDelete.addAll((List<SObject>) coHeaderList);
            sOjectListToDelete.addAll((List<SObject>) coHeaderList[0].CO_Deposits__r);
            
            delete sOjectListToDelete;
            response = 'Success';
        }
        return BPUtility.getEncodedString(response);
    }
            
    public static List<Sobject> addLinkedFee(String recordId, String dealId, String objectType) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        if(String.isNotBlank(objectType)){
            List<Linked_Fee__c> linkedFeeList = SOQLUtil.getLinkedFeeList(new Map<String, String>{'Related_To__c' => objectType});
            if(linkedFeeList.size() == 0) {
                return null;
            }
            if(objectType == 'Merchandise') {
                List<CO_Line_Item__c> coliList = new List<CO_Line_Item__c>();
                CO_Line_Item__c coLineItemRec;
                for(Linked_Fee__c linkFee : linkedFeeList){
                    coLineItemRec = new CO_Line_Item__c();
                    coLineItemRec.Qty__c = 1 ;
                    coLineItemRec.Qty_Committed__c = 1;
                    if(isTaxIncludingPricing){
                        coLineItemRec.Price_When_Tax_Included__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    } else {
                        coLineItemRec.Price__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    }
                    coLineItemRec.CO_Header__c = recordId;
                    coLineItemRec.Fee__c = linkFee.Fee__c;
                    coLineItemRec.Item_Description__c = linkfee.Description__c == null ? linkfee.Fee__r.Description__c : linkfee.Description__c;
                    coLineItemRec.Is_Linked_Fee__c = true;
                    coliList.add(coLineItemRec);
                }
                if(coliList.size() > 0){
                    return coliList;
                }
            } else if(objectType == 'Service Job') {
                List<Service_Order_Line_Item__c> soliList = new List<Service_Order_Line_Item__c>();
                Service_Order_Line_Item__c soliRec;
                for(Linked_Fee__c linkFee : linkedFeeList){
                    soliRec = new Service_Order_Line_Item__c();
                    soliRec.Service_Order_Header__c = recordId;
                    soliRec.Fee__c = linkFee.Fee__c;
                    soliRec.Item_Code__c = linkFee.Fee__r.Code__c;
                    soliRec.Item_Description__c = linkfee.Description__c == null ? linkfee.Fee__r.Description__c : linkfee.Description__c;
                    soliRec.Qty_Needed__c = 1;
                    soliRec.Qty_Committed__c = 1;
                    if(isTaxIncludingPricing){
                        soliRec.Price_When_Tax_Included__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    } else {
                        soliRec.Kit_Price__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    }
                    soliRec.Actual_Kit_Price__c = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
                    soliRec.Is_Linked_Fee__c = true;
                    soliList.add(soliRec);
                }
                if(soliList.size() > 0){
                    return soliList;
                }
            } else if(objectType == 'Deal') {
                List<Option_Fee__c> optionAndFeeRecList = new List<Option_Fee__c>();
                Option_Fee__c optionAndFeeRec;
                for(Linked_Fee__c linkFee : linkedFeeList){
                    optionAndFeeRec = new Option_Fee__c();
                    optionAndFeeRec.Deal__c = dealId;
                    optionAndFeeRec.Deal_Item__c = recordId;
                    optionAndFeeRec.Fee__c = linkFee.Fee__c;
                    optionAndFeeRec.Item_Code__c = linkFee.Fee__r.Code__c;
                    optionAndFeeRec.Item_Description__c = linkfee.Description__c == null ? linkfee.Fee__r.Description__c : linkfee.Description__c;
                    optionAndFeeRec.Qty__c = 1;
                    if(isTaxIncludingPricing){
                        optionAndFeeRec.Price_When_Tax_Included__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    } else {
                        optionAndFeeRec.Price__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    }
                    optionAndFeeRecList.add(optionAndFeeRec);
                    optionAndFeeRec.Is_Linked_Fee__c = true;
                } 
                if(optionAndFeeRecList.size() > 0){
                    return optionAndFeeRecList;
                }
            }
        }
            
        return null;
    }
    
    
    @RemoteAction
    global static String updateStampDuty(String dealItemId, String stampDutyTotal) {
        dealItemId = BPUtility.getDecodedString(dealItemId);
        stampDutyTotal = BPUtility.getDecodedString(stampDutyTotal); 
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update new Deal_Item__c(Id = dealItemId, Stamp_Duty_Total__c = Decimal.valueOf(stampDutyTotal), Is_Override_Stamp_Duty__c = true);
        return getDealItemDetails(dealItemId);
    }
    
    @RemoteAction
    global static String toggleRideawayPricingEnabled(String dealItemId, Decimal totalEnforceRideawayPrice, Boolean IsRideawayPricingEnabled) {
        try{
            dealItemId = BPUtility.getDecodedString(dealItemId);
            
            if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            Deal_Item__c dealItemRec = new Deal_Item__c(Id = dealItemId);
            dealItemRec.Is_Rideaway_Pricing_Enabled__c = IsRideawayPricingEnabled;
            dealItemRec.Rideaway_Pricing_Total__c = totalEnforceRideawayPrice.setScale(2, RoundingMode.HALF_UP);
            update dealItemRec;
            
            return getDealItemDetails(dealItemId);
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return null;
    }
    
    @RemoteAction
    global static String updateRideawayPricing(String dealItemId, String unitJsonString) {
        try{
            dealItemId = BPUtility.getDecodedString(dealItemId);
            unitJsonString = BPUtility.getDecodedString(unitJsonString);
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            
            DealWrapper.UnitSectionWrapper unitSectionObj = (DealWrapper.UnitSectionWrapper) System.JSON.deserialize(unitJsonString, DealWrapper.UnitSectionWrapper.class);
            List<Deal_Item__c>  dealItemList = [Select Stamp_Duty_Total__c, Is_Override_Stamp_Duty__c, Rideaway_Pricing_Total__c, 
                                                    (Select Id, Price__c, Price_When_Tax_Included__c, Qty__c, Type__c, Sales_Tax_Percentage__c from Deal_Unit_Prices_Costs__r where Type__c = 'Base') 
                                                FROM Deal_Item__c where Id =: dealItemId];          
            if(dealItemList.size() > 0){
                Deal_Item__c dealItemRec = dealItemList[0];
                if(unitSectionObj.IsRideawayPricingEnabled) {                   
                                        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    Decimal stampDutyRate = GeneralConfiguration.getStampDutyRate();
                    
                    Decimal subTotal = (unitSectionObj.TotalEnforceRideawayPrice != null ? unitSectionObj.TotalEnforceRideawayPrice : 0) - unitSectionObj.TotalFee - unitSectionObj.TotalSublet;
                    subTotal = (subTotal / (1+(stampDutyRate/100))).setScale(2, RoundingMode.HALF_UP);

                    Decimal stampDutyTotal = 0;
                    if(subTotal > 100) {
                        Decimal roundedUpAmount = (math.ceil(subTotal/100)* 100);
                        stampDutyTotal = (roundedUpAmount * (stampDutyRate/100)).setScale(2, RoundingMode.HALF_UP);
                    }
                    Decimal totalBasePrice = (unitSectionObj.TotalEnforceRideawayPrice != null ? unitSectionObj.TotalEnforceRideawayPrice : 0) - 
                                            (stampDutyTotal + 
                                            (unitSectionObj.TotalFactoryOption != null ? unitSectionObj.TotalFactoryOption : 0) 
                                            + (unitSectionObj.TotalDealerInstalledOption != null ? unitSectionObj.TotalDealerInstalledOption : 0)
                                            + (unitSectionObj.TotalPartAndLabor != null ? unitSectionObj.TotalPartAndLabor : 0)
                                            + unitSectionObj.TotalFee + unitSectionObj.TotalSublet);
                    
                    dealItemRec.Rideaway_Pricing_Total__c = (unitSectionObj.TotalEnforceRideawayPrice != null ? unitSectionObj.TotalEnforceRideawayPrice : 0);
                    dealItemRec.Stamp_Duty_Total__c = stampDutyTotal;
                    
                    List<Deal_Unit_Price_Cost__c> dealUnitPriceCostList = new List<Deal_Unit_Price_Cost__c>();
                    if(dealItemRec.Deal_Unit_Prices_Costs__r.size() > 0)    {
                        for(Deal_Unit_Price_Cost__c dealUnitpriceCostRec : dealItemRec.Deal_Unit_Prices_Costs__r) {
                                if(isTaxIncludingPricing) {
                                    dealUnitpriceCostRec.Price_When_Tax_Included__c = (totalBasePrice/((DealUnitpriceCostRec.Qty__c != null||DealUnitpriceCostRec.Qty__c == 0) ? DealUnitpriceCostRec.Qty__c : 1));
                                    dealUnitpriceCostRec.Price__c = (dealUnitpriceCostRec.Price_When_Tax_Included__c / (1 + dealUnitpriceCostRec.Sales_Tax_Percentage__c / 100));
                                } else {
                                    dealUnitpriceCostRec.Price__c = (totalBasePrice/((DealUnitpriceCostRec.Qty__c != null||DealUnitpriceCostRec.Qty__c == 0) ? DealUnitpriceCostRec.Qty__c : 1));
                                }
                                dealUnitPriceCostList.add(dealUnitpriceCostRec);
                        }
                        if(dealUnitPriceCostList.size() > 0) {
                            if(AccessControl.ifObjectFieldIsUpdateable('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                            update dealUnitPriceCostList;
                        }
                        
                    } else {
                        List<DealWrapper.BaseUnitPrice> baseUnitPriceList = new List<DealWrapper.BaseUnitPrice>();
                        DealWrapper.BaseUnitPrice baseUnitPrice = new DealWrapper.BaseUnitPrice();
                        baseUnitPrice.Type = 'Base';
                        baseUnitPrice.Qty = 1;
                        baseUnitPrice.Price = totalBasePrice;
                        
                        baseUnitPriceList.add(baseUnitPrice);
                        String baseUnitPriceJsonString = System.JSON.serialize(baseUnitPriceList);
                        
                        // TO Do - Improve Performace.
                        updateDealUnitCostPrice(BPUtility.getEncodedString(baseUnitPriceJsonString), BPUtility.getEncodedString(unitSectionObj.DealItemObj.Deal), BPUtility.getEncodedString(unitSectionObj.DealItemObj.Id));
                    }
                    update dealItemRec;
                }
            }
            return getDealItemDetails(dealItemId);
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return null;
    }
    
    
    @RemoteAction
    global static String getAlternatePartsList(String partId) {
        partId = BPUtility.getDecodedString(partId);
        List<Part_Alternates__c> alternatePartsList = [SELECT Alternate_Part_ID__c, Relation__c FROM Part_Alternates__c
                                                        WHERE Part_ID__c = :partId
                                                            AND (Relation__c = 'Replaces' OR Relation__c = 'Alternate')];
        Map<String, String> partIdToRelationMap = new Map<String, String>();
        partIdToRelationMap.put(partId, 'Actual');
        for(Part_Alternates__c alterPart : alternatePartsList){
            partIdToRelationMap.put(alterPart.Alternate_Part_ID__c, alterPart.Relation__c);
        }
        
        Part__c partRec = [SELECT SKU_Number__c, Mfg_Part__c, Part_Number__c from Part__c WHERE Id =: partId];
        List<Part__c> matchedParts = [SELECT Part_Number__c, Item_Description__c, Vendor__r.Vendor_Code__c, AvailableParts__c, 
                                        Retail_Price__c, Mfg_Part__c, SKU_Number__c FROM Part__c
                                        WHERE Id IN :partIdToRelationMap.keySet()
                                            OR (Part_Number__c = :partRec.SKU_Number__c AND Part_Number__c != null) 
                                            OR (Part_Number__c = :partRec.Mfg_Part__c AND Part_Number__c != null) 
                                            OR (SKU_Number__c = :partRec.SKU_Number__c AND SKU_Number__c != null) 
                                            OR (Mfg_Part__c = :partRec.Mfg_Part__c AND Mfg_Part__c != null)
                                            OR (Part_Number__c =: partRec.Part_Number__c AND Part_Number__c != null)];                                                  
        List<PartAlternateWrapper> partAlternateList = new List<PartAlternateWrapper>();
        Integer priorityIndex = 0;
        String relation = '';
        Boolean isSelected;
        for(Part__c part : matchedParts){
            isSelected = false;
            if(part.Id == partId){
                priorityIndex = 1;
                relation = 'Active Part';
                isSelected = true;
            }else if(partIdToRelationMap.containsKey(part.Id) && partIdToRelationMap.get(part.Id) == 'Replaces'){
                priorityIndex = 2;
                relation = 'Replaces';
            }else if(partIdToRelationMap.containsKey(part.Id) && partIdToRelationMap.get(part.Id) == 'Alternate'){
                priorityIndex = 3;
                relation = 'Alternate';
            }else if(part.Part_Number__c == partRec.Part_Number__c){
                priorityIndex = 4;
                relation = 'Other Vendor';
            }else if(part.Part_Number__c == partRec.Mfg_Part__c){
                priorityIndex = 5;
                relation = 'Actual MFG Part#';
            }else if(part.Part_Number__c == partRec.SKU_Number__c){
                priorityIndex = 6;
                relation = 'Actual SKU #';
            }else if(part.Mfg_Part__c == partRec.Mfg_Part__c){
                priorityIndex = 7;
                relation = 'Same MFG Part#';
            }else if(part.SKU_Number__c == partRec.SKU_Number__c){
                priorityIndex = 8;
                relation = 'Same SKU #';
            }else{
                priorityIndex = 9;
                relation = 'Other relation'; 
            }
            partAlternateList.add(new PartAlternateWrapper(part, priorityIndex, relation, isSelected));
        }
        partAlternateList.sort();
        return BPUtility.getEncodedString(System.JSON.serialize(partAlternateList));
    }
    
    @RemoteAction
    global static String addServiceOrderLineItems(String partIdsString, String soHeaderId) {
        partIdsString = BPUtility.getDecodedString(partIdsString);
        soHeaderId = BPUtility.getDecodedString(soHeaderId);
        try{
            String coHeaderId = COService.addRelatedPartInSO(partIdsString, soHeaderId);
            if(String.isNotBlank(coHeaderId)) {
                return getSOHeaderDetails(BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString('soHeader,soItemGrid,checkOut,specialOrder'));
            }
            return BPUtility.getEncodedString('');
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
        
        /*
        createDealUnresolvedFulfillment(new List<String>{soliRec.Id}, soliRec.Deal__c, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);
        // Create Deal Unresoled Fulfillment for Env Fee Line item.
        if(partList[0].Enviro_Fee__c != null && soliListToInsert.size() > 1) {
            createDealUnresolvedFulfillment(new List<String>{relatedEnvFeeRec.Id}, relatedEnvFeeRec.Deal__c, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);
        }
        */
    }
    
    public static void createStoreCredit(List<Id> coDepositIdList){
        if(AccessControl.ifObjectFieldIsCreateable('Store_Credit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        List<CO_Deposit__c> coDepositList = [select Id, CO_Header__r.Customer__c,
                                                        Payment_Method__c, Amount__c
                                                        from CO_Deposit__c
                                                        where Id IN : coDepositIdList]; 
        List<Store_Credit__c> storeCreditListToInsert = new List<Store_Credit__c>();
        Store_Credit__c storeCreditObj;
        for(CO_Deposit__c deposit : coDepositList){ 
            if(deposit.Payment_Method__c == 'Store Credit'){
                if(deposit.CO_Header__r.Customer__c == null){
                    deposit.addError('Store Credit can be used for Customer Only'); 
                }else{
                    storeCreditObj = new Store_Credit__c();
                    storeCreditObj.Customer__c = deposit.CO_Header__r.Customer__c;
                    storeCreditObj.Amount__c = -1 * deposit.Amount__c;
                    storeCreditObj.Reference__c = 'Order Deposit';
                    storeCreditObj.CO_Header__c = deposit.CO_Header__c;
                    storeCreditListToInsert.add(storeCreditObj);
                }
            }
        }
        insert storeCreditListToInsert;     
    }
    
    /** Method to get data of all account type present in appication
    * CtrlClass -AccountTypeCtrl
    * @Return - String(Json containing all account type data)
    */
    @RemoteAction
    public static String getAllAccountTypeForCustomer() {
        try {
            return BPUtility.getEncodedString(system.JSON.serialize(AccountTypeService.getAllAccountTypeForCustomer()));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    private static void updateVOLIANDCOLIOnMoveFromColiToSoli(Service_Order_Line_Item__c solirec, List<CO_Line_Item__c> coliListToMove) {
    	List<CO_Line_Item__c>  newlyInsertedCOLIList = [Select Id, Service_Order_Line_Item__c From CO_Line_Item__c WHERE Service_Order_Line_Item__c =: solirec.Id];
	            
        List<Vendor_Order_Line_Item__c> voliRecListToUpdate = new List<Vendor_Order_Line_Item__c>();
        voliRecListToUpdate.addAll(coliListToMove[0].Vendor_Order_Line_Items__r);
        
        for(Vendor_Order_Line_Item__c voliRec : voliRecListToUpdate) {
    		voliRec.CO_Line_Item__c = newlyInsertedCOLIList[0].Id;
        	if(newlyInsertedCOLIList[0].Service_Order_Line_Item__c != null){
                voliRec.Is_Service__c = true;
                voliRec.Is_required_For_Customer__c = false;
            } else {
                voliRec.Is_required_For_Customer__c = true;
                voliRec.Is_Service__c = false;
            }
        }
        newlyInsertedCOLIList[0].Status__c = coliListToMove[0].Status__c;
        newlyInsertedCOLIList[0].Vendor_Order_Header__c = coliListToMove[0].Vendor_Order_Header__c;
        newlyInsertedCOLIList[0].VO_Number__c = coliListToMove[0].VO_Number__c;
        newlyInsertedCOLIList[0].VO_Status__c = coliListToMove[0].VO_Status__c;
		newlyInsertedCOLIList[0].Expected_Delivery_Date__c = coliListToMove[0].Expected_Delivery_Date__c;
       
        upsert voliRecListToUpdate;
        upsert newlyInsertedCOLIList;																
    }
    															
    private static void updateVOLIANDCOLIOnMoveFromCokhSokh(Id soKHId, List<CO_Kit_Header__c> coKitHeaderToMovelist, List<Vendor_Order_Line_Item__c> voliRecListToUpdate) {
    	List<CO_Line_Item__c>  newlyInsertedCOLIList = [Select Id, Service_Order_Line_Item__c, Kit_Header_Line_Item__c From CO_Line_Item__c WHERE Service_Order_Line_Item__r.Service_Order_Kit_Header__c =: soKHId];
        List<CO_Line_Item__c>  newlyInsertedCOLIListToUpdate = new List<CO_Line_Item__c>();
        
        Map<Id, CO_Line_Item__c> khliIdToNewlyInsertedCOLIRecMap = new Map<Id, CO_Line_Item__c>();
        for(CO_Line_Item__c coliRec : newlyInsertedCOLIList) {
        	khliIdToNewlyInsertedCOLIRecMap.put(coliRec.Kit_Header_Line_Item__c, coliRec);
        }
        
        Map<Id, CO_Line_Item__c> khliIdToCOLIRecToMoveMap = new Map<Id, CO_Line_Item__c>();
        for(CO_Line_Item__c coliRec : coKitHeaderToMovelist[0].CO_Line_Items__r) {
        	khliIdToCOLIRecToMoveMap.put(coliRec.Kit_Header_Line_Item__c, coliRec);
        }
        
        for(Vendor_Order_Line_Item__c voliRec : voliRecListToUpdate) {
        	if(khliIdToNewlyInsertedCOLIRecMap.containsKey(voliRec.CO_Line_Item__r.Kit_Header_Line_Item__c)) {
        		voliRec.CO_Line_Item__c = khliIdToNewlyInsertedCOLIRecMap.get(voliRec.CO_Line_Item__r.Kit_Header_Line_Item__c).Id;
        		if(khliIdToNewlyInsertedCOLIRecMap.get(voliRec.CO_Line_Item__r.Kit_Header_Line_Item__c).Service_Order_Line_Item__c != null){
                    voliRec.Is_Service__c = true;
                    voliRec.Is_required_For_Customer__c = false;
                } else {
                    voliRec.Is_required_For_Customer__c = true;
                    voliRec.Is_Service__c = false;
                }
                
        		CO_Line_Item__c newlyInsertedCOLIToUpdate = new CO_Line_Item__c();
                newlyInsertedCOLIToUpdate.Id = khliIdToNewlyInsertedCOLIRecMap.get(voliRec.CO_Line_Item__r.Kit_Header_Line_Item__c).Id;
                
                if(khliIdToCOLIRecToMoveMap.containsKey(voliRec.CO_Line_Item__r.Kit_Header_Line_Item__c)) {
                	newlyInsertedCOLIToUpdate.Status__c = khliIdToCOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Kit_Header_Line_Item__c).Status__c;
		            newlyInsertedCOLIToUpdate.Vendor_Order_Header__c = khliIdToCOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Kit_Header_Line_Item__c).Vendor_Order_Header__c;
		            newlyInsertedCOLIToUpdate.VO_Number__c = khliIdToCOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Kit_Header_Line_Item__c).VO_Number__c;
		            newlyInsertedCOLIToUpdate.VO_Status__c = khliIdToCOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Kit_Header_Line_Item__c).VO_Status__c;
					newlyInsertedCOLIToUpdate.Expected_Delivery_Date__c = khliIdToCOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Kit_Header_Line_Item__c).Expected_Delivery_Date__c;
                }
                newlyInsertedCOLIListToUpdate.add(newlyInsertedCOLIToUpdate);
        	}
        }
        
        upsert voliRecListToUpdate;
        upsert newlyInsertedCOLIListToUpdate;
    }			
    												
    private static void updateVOLIANDCOLIOnPartMoveFromSoliTOColi(List<Vendor_Order_Line_Item__c> voliRecListToUpdate, List<CO_Line_Item__c> coliToUpsert, 
    															List<Service_Order_Line_Item__c> soliItemToMovelist) {
    	for(Vendor_Order_Line_Item__c voliRec : voliRecListToUpdate) {
    		voliRec.CO_Line_Item__c = coliToUpsert[0].Id;
    	
        	if(coliToUpsert[0].Service_Order_Line_Item__c != null){
                voliRec.Is_Service__c = true;
                voliRec.Is_required_For_Customer__c = false;
            } else {
                voliRec.Is_required_For_Customer__c = true;
                voliRec.Is_Service__c = false;
            }
    	}
    	
    	coliToUpsert[0].Status__c = soliItemToMovelist[0].CO_Line_Item__r.Status__c;
    	coliToUpsert[0].Vendor_Order_Header__c = soliItemToMovelist[0].CO_Line_Item__r.Vendor_Order_Header__c;
    	coliToUpsert[0].VO_Number__c = soliItemToMovelist[0].CO_Line_Item__r.VO_Number__c;
    	coliToUpsert[0].VO_Status__c =  soliItemToMovelist[0].CO_Line_Item__r.VO_Status__c;
    	coliToUpsert[0].Expected_Delivery_Date__c = soliItemToMovelist[0].CO_Line_Item__r.Expected_Delivery_Date__c;
    	upsert voliRecListToUpdate;
    	upsert coliToUpsert;
    }
    
    private static void updateVOLIANDCOLIOnSubletMoveFromSoliTOColi(List<Vendor_Order_Line_Item__c> voliRecListToUpdate, String soliId, List<Service_Order_Line_Item__c> soliItemToMovelist) {
    	
    	List<Service_Order_Line_Item__c>  newlyInsertedSOLIList = [Select Id From Service_Order_Line_Item__c WHERE Id =: soliId];
    	
    	for(Vendor_Order_Line_Item__c voliRec : voliRecListToUpdate) {
    		voliRec.Service_Order_Line_Item__c = newlyInsertedSOLIList[0].Id;
            voliRec.Is_Service__c = true;
            voliRec.Is_required_For_Customer__c = false;
    	}
    	
    	newlyInsertedSOLIList[0].Status__c = soliItemToMovelist[0].Status__c;
    	newlyInsertedSOLIList[0].Vendor_Order_Header__c = soliItemToMovelist[0].Vendor_Order_Header__c;
    	newlyInsertedSOLIList[0].VO_Number__c = soliItemToMovelist[0].VO_Number__c;
    	newlyInsertedSOLIList[0].VO_Status__c =  soliItemToMovelist[0].VO_Status__c;
    	newlyInsertedSOLIList[0].Expected_Delivery_Date__c = soliItemToMovelist[0].Expected_Delivery_Date__c;
    	
    	upsert voliRecListToUpdate;
    	upsert newlyInsertedSOLIList;
    }
    
    private static void updateVOLIANDCOLIOnMoveFromSokhCOKH(Map<String, Id> fieldNameToFieldValueMap, List<Service_Order_Kit_Header__c> serviceOrderKitHeaderListToMove, 
    															List<Vendor_Order_Line_Item__c> voliRecListToUpdate) {
       	String query = 'Select Id, Service_Order_Line_Item__c, Kit_Header_Line_Item__c From CO_Line_Item__c ';
       	for(String fieldName : fieldNameToFieldValueMap.keySet()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            if(fieldNameToFieldValueMap.get(fieldName) == null) {
                query += 'WHERE '+ fieldName + ' = ' + fieldNameToFieldValueMap.get(fieldName);
            } else {
            	query += 'WHERE '+ fieldName + ' = \'' + BPUtility.escapeSingleQuotes(fieldNameToFieldValueMap.get(fieldName)) + '\'';
            }
        }
            
        //List<CO_Line_Item__c>  newlyInsertedCOLIList = [Select Id, Service_Order_Line_Item__c, Kit_Header_Line_Item__c From CO_Line_Item__c WHERE CO_Kit_Header__c =: cokhId];
        //List<CO_Line_Item__c>  newlyInsertedCOLIList = [Select Id, Service_Order_Line_Item__c, Kit_Header_Line_Item__c From CO_Line_Item__c WHERE Service_Order_Line_Item__r.Service_Order_Kit_Header__c =: soKHId];
        
        List<CO_Line_Item__c>  newlyInsertedCOLIList = Database.query(query);
        
        List<CO_Line_Item__c>  newlyInsertedCOLIListToUpdate = new List<CO_Line_Item__c>();
        
        Map<Id, CO_Line_Item__c> khliIdToNewlyInsertedCOLIRecMap = new Map<Id, CO_Line_Item__c>();
        for(CO_Line_Item__c coliRec : newlyInsertedCOLIList) {
        	khliIdToNewlyInsertedCOLIRecMap.put(coliRec.Kit_Header_Line_Item__c, coliRec);
        }
        
        Map<Id, Service_Order_Line_Item__c> khliIdToSOLIRecToMoveMap = new Map<Id, Service_Order_Line_Item__c>();
        for(Service_Order_Line_Item__c soliRec : serviceOrderKitHeaderListToMove[0].Service_Order_Line_Items__r) {
        	khliIdToSOLIRecToMoveMap.put(soliRec.Kit_Header_Line_Item__c, soliRec);
        }
        
        for(Vendor_Order_Line_Item__c voliRec : voliRecListToUpdate) {
        	voliRec.CO_Line_Item__c = khliIdToNewlyInsertedCOLIRecMap.containsKey(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c) ? 
        								khliIdToNewlyInsertedCOLIRecMap.get(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c).Id : null;
        
        	if(khliIdToNewlyInsertedCOLIRecMap.containsKey(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c)) {
        		if(khliIdToNewlyInsertedCOLIRecMap.get(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c).Service_Order_Line_Item__c != null){
                    voliRec.Is_Service__c = true;
                    voliRec.Is_required_For_Customer__c = false;
                } else {
                    voliRec.Is_required_For_Customer__c = true;
                    voliRec.Is_Service__c = false;
                }
                
        		CO_Line_Item__c newlyInsertedCOLIToUpdate = new CO_Line_Item__c();
                newlyInsertedCOLIToUpdate.Id = khliIdToNewlyInsertedCOLIRecMap.get(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c).Id;
                
                if(khliIdToSOLIRecToMoveMap.containsKey(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c) 
                	&& khliIdToSOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c).CO_Line_Item__c != null) {
                	newlyInsertedCOLIToUpdate.Status__c = khliIdToSOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c).CO_Line_Item__r.Status__c;
		            newlyInsertedCOLIToUpdate.Vendor_Order_Header__c = khliIdToSOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c).CO_Line_Item__r.Vendor_Order_Header__c;
		            newlyInsertedCOLIToUpdate.VO_Number__c = khliIdToSOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c).CO_Line_Item__r.VO_Number__c;
		            newlyInsertedCOLIToUpdate.VO_Status__c = khliIdToSOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c).CO_Line_Item__r.VO_Status__c;
					newlyInsertedCOLIToUpdate.Expected_Delivery_Date__c = khliIdToSOLIRecToMoveMap.get(voliRec.CO_Line_Item__r.Service_Order_Line_Item__r.Kit_Header_Line_Item__c).CO_Line_Item__r.Expected_Delivery_Date__c;
                }
                newlyInsertedCOLIListToUpdate.add(newlyInsertedCOLIToUpdate);
        	}
        }
        upsert voliRecListToUpdate;
        upsert newlyInsertedCOLIListToUpdate;
    }
}
