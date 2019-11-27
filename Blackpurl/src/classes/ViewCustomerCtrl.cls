/**
 * Author: Tarun Khandelwal
 * Since: June 05, 2015
 * Name: CustomerViewCtrl
 * Description: Controller Class of Customer Detail Page.
**/ 
global with sharing class ViewCustomerCtrl {
	public Decimal Home_Search_Grid_Page_Size { get{return GeneralConfiguration.getHomeSearchGridPageSize();} private set;}
    public Decimal Related_List_Page_Size { get{return GeneralConfiguration.getRelatedListPageSize();} private set;}
    public boolean Is_Widget_Removeable {get{return GeneralConfiguration.isWidgetRemoveable();}}
    public boolean Load_New_Customer_Order {get{return GeneralConfiguration.isLoadNewCustomerOrder();} private set;}
    public boolean Load_New_UI {get{return GeneralConfiguration.isLoadNewUI();} private set;}
    public boolean Load_New_View_Customer {get{return GeneralConfiguration.isLoadNewViewCustomer();} private set;}
    public Decimal Sales_Tax_Rate {get{return GeneralConfiguration.getAustralianMarketSalesTaxRate();} private set;}
    
    global ViewCustomerCtrl (NewHomePageCtrl controller){}
    public ViewCustomerCtrl() {}
    
    /**
     * Name: getCustomerInfo
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction 
    global static String getCustomerInfo(String customerId) {
    	customerId = BPUtility.getDecodedString(customerId); 
    	
        List<Account> customers = SOQLUtil.getCustomer(customerId, 'Customer');
        Map<String, String> accountIdToRelationMap = getRelatedCustomerRelationMap(customerId);
        List<Account> relatedCustomerRecList = SOQLUtil.getRelatedAccountRecs(accountIdToRelationMap.keyset());
        List<Customer_Owned_Unit__c> COUList = SOQLUtil.getCOURecordByFieldName('Account__c', customerId);
        List<Contact> customerContactList = SOQLUtil.getCustomerContactByFieldName('AccountId', customerId);
       	List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
		List<Sales_Tax__c> applicableTaxList = SOQLUtil.getSalesTax(new List<Id>());
        String JSONString = '{}';
        //system.assert(false, ActiveOrder.getAllActiveOrdersForCustomer(customerId, null));
        if(customers.size() > 0) {
            JSONString = System.JSON.serialize(new CustomerDetail(customers[0], relatedCustomerRecList, accountIdToRelationMap, COUList, new List<CO_Header__c>(), 
            										customerContactList, getLastVisitOrderByCustomerId(customerId),
            										new List<Tax_Exemption__c>(), businessProfileList, applicableTaxList, new List<CO_Header__c>(), new List<Store_Credit__c>(), new List<Message_History__c>(), ''));  // new List<CO_Header__c>() Added by richa 26/01/2017 for retrieving all CO's for a customer
        }
        return BPUtility.getEncodedString(JSONString);
    }
    
    /**
     * Name: getOtherSimilarCustomer
     * Desc: 
     * @param:  
     * @return:  
    **/
   @RemoteAction
    global static String getSimilarCOUs(String VINNumber){
    	VINNumber = BPUtility.getDecodedString(VINNumber);
    	
        List<Customer_Owned_Unit__c> custOwnedUnits = SOQLUtil.getSimilarCOUs(VINNumber);
        //System.assert(false,custOwnedUnits );
        List<CustomerOwnedUnit> custOwnedUnitList = new List<CustomerOwnedUnit>();
        for(Customer_Owned_Unit__c custOwnedUnitRec : custOwnedUnits) {
            if(custOwnedUnitRec.VIN_Number__c != null && custOwnedUnitRec.VIN_Number__c != '') {
                custOwnedUnitList.add(new CustomerOwnedUnit(custOwnedUnitRec));
            }
        }
        return BPUtility.getEncodedString(System.JSON.serialize(custOwnedUnitList));
    }
    
    /**
     * Name: getApplicableTaxList
     * Desc: To get Unit Details on Edit Stock unit Pop Up window
     * @param: 
     * @return: String - JSON string of Sales Tax info. 
    **/
    @RemoteAction
    global static String getApplicableTaxList() {
        String defaultUnitTaxId = Configurations__c.getOrgDefaults().Default_Tax_on_Unit__c;
        return BPUtility.getEncodedString(TaxUtility.getApplicableList(defaultUnitTaxId));
    }
    
    @RemoteAction
    global static String getActiveTagList() {
    	return BPUtility.getEncodedString(System.JSON.serialize(TagManagementCtrl.getActiveTagList()));
    }
    
    /**
     * Name: saveCOU
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String saveCOU(String customerId, String couJSONString) {
    	customerId = BPUtility.getDecodedString(customerId);
        couJSONString = BPUtility.getDecodedString(couJSONString);
        List<CustomerOwnedUnit> couObjList = CustomerOwnedUnit.parse(couJSONString);
        if(couObjList.size() == 0) {
        	return BPUtility.getEncodedString('{}');
        }
        Customer_Owned_Unit__c unitRec = NewViewCustomerCtrl.setUnitFields(couObjList[0]);
        
        List<Customer_Owned_Unit__c> unitList = new List<Customer_Owned_Unit__c>();
        if(couObjList[0].UnitType == 'ORDU') {
            unitList = [Select Id from Customer_Owned_Unit__c WHERE Unit_Id__c =: couObjList[0].UnitId];
        } else if(couObjList[0].UnitType == 'STOCK'){
            unitList = [Select Id from Customer_Owned_Unit__c WHERE Stock_Id__c =: couObjList[0].StockId];
        }
        
        if(!String.isBlank(unitRec.Id) && unitRec.Unit_Type__c != 'ORDU' && couObjList.size() > 0 && !couObjList[0].IsActive) {
        	String errorMessage = getErrorMessageForActivelyUsedUnit(unitRec.Id);
        	if(!String.isBlank(errorMessage)) {
        		return BPUtility.getEncodedString('{"HasError" : true, "ErrorMessage" : "'+errorMessage+'"}'); 
        	}
        }
        if(unitList.size() > 0 && unitList[0].Id != couObjList[0].Id && 
            ((couObjList[0].UnitType == 'STOCK' && String.isNotBlank(couObjList[0].StockId)) ||
            (couObjList[0].UnitType == 'ORDU' && String.isNotBlank(couObjList[0].UnitId)))) {
            return BPUtility.getEncodedString('{"HasError" : true, "ErrorMessage" : "Duplicate stock number"}');   
        }
        
        unitRec.Account__c = customerId;
        if(unitRec.Unit_Type__c == 'COU' && (unitRec.Status__c == null || unitRec.Status__c == '')){
        	 unitRec.Status__c = 'Active';
        }
         if(unitRec.Unit_Type__c == 'STOCK' && (unitRec.Status__c == null || unitRec.Status__c == '')){
        	 unitRec.Status__c = 'Available';
        }
         if(unitRec.Unit_Type__c == 'ORDU' && (unitRec.Status__c == null || unitRec.Status__c == '')){
        	 unitRec.Status__c = 'On Order';
        }
        
        if(!String.isBlank(unitRec.Id) && unitRec.Unit_Type__c != 'ORDU' && couObjList.size() > 0 && !couObjList[0].IsActive) {
            unitRec.Status__c = 'Inactive';
        } else if(!String.isBlank(unitRec.Id) && couObjList.size() > 0 && couObjList[0].IsActive && couObjList[0].Status == 'Inactive'){
        	if(unitRec.Unit_Type__c == 'COU') {
        		unitRec.Status__c = 'Active';
	        } else if(unitRec.Unit_Type__c == 'STOCK') {
	        	unitRec.Status__c = 'Available';
	        }
        }
        
        if(couObjList[0].Make == null) {
        	List<Unit_Make__c> makeList = [Select Name from Unit_Make__c where Name =: couObjList[0].MakeName];
        	if(makeList.size() == 0) {
        		Unit_Make__c makeRec = new Unit_Make__c(Name = couObjList[0].MakeName);
        		insert makeRec;
        		unitRec.Unit_Make__c = makeRec.Id;
        	} else {
        		unitRec.Unit_Make__c = makeList[0].Id;
        	}
        }
        if(couObjList[0].Model == null) {
        	List<Unit_Model__c> modelList = [Select Name__c, Unit_Make__c from Unit_Model__c where Name__c =: couObjList[0].ModelName AND Unit_Make__c =: unitRec.Unit_Make__c];
        	if(modelList.size() == 0) {
        		Unit_Model__c modelRec = new Unit_Model__c(Name__c = couObjList[0].ModelName, Unit_Make__c = unitRec.Unit_Make__c);
	        	insert modelRec;
	        	unitRec.Unit_Model__c = modelRec.Id;
        	} else {
        		unitRec.Unit_Model__c = modelList[0].Id;
        	}
        }
        if(couObjList[0].SubModel == null && String.isNotBlank(couObjList[0].SubModelName)) {
        	List<Unit_Sub_Model__c> subModelList = [Select Sub_Model_Name__c, Unit_Model__c from Unit_Sub_Model__c where Sub_Model_Name__c =: couObjList[0].SubModelName AND Unit_Model__c =: unitRec.Unit_Model__c];
	    	if(subModelList.size() == 0) {
	    		Unit_Sub_Model__c subModelRec = new Unit_Sub_Model__c(Sub_Model_Name__c = couObjList[0].SubModelName, Unit_Model__c = unitRec.Unit_Model__c);
	        	insert subModelRec;
	        	unitRec.Sub_Model__c = subModelRec.Id;
	    	} else {
	    		unitRec.Sub_Model__c = subModelList[0].Id;
	    	}
        }
        if(unitRec.Id == null) { 
        	if(AccessControl.ifObjectFieldIsCreateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        } else {
        	if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        }
        upsert unitRec;
        
        // 26th april, 2017 #1937
        if(AccessControl.ifObjectFieldIsCreateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        Unit_Price_Cost__c unitPriceAndCost = new Unit_Price_Cost__c();
        unitPriceAndCost.Id = couObjList[0].BaseUnitId;
        unitPriceAndCost.Type__c = 'Base';
        if(unitRec.Unit_Type__c == 'STOCK') {
        	unitPriceAndCost.Ref_No__c = 'Add Unit';
        }
        unitPriceAndCost.Total_Price__c = couObjList[0].TotalBasePrice;
        unitPriceAndCost.Total_Cost__c = couObjList[0].TotalBaseCost;    
        unitPriceAndCost.Item_Description__c = 'Base unit';    
        unitPriceAndCost.Customer_Owned_Unit__c = unitRec.Id;
    	upsert unitPriceAndCost;
        // 26th april, 2017 #1937
        
        return getCOUListById(unitRec.Id);
    }
    
    private static String getErrorMessageForActivelyUsedUnit(String unitId) {
    	List<Customer_Owned_Unit__c> couList = [Select Id, Unit_Type__c, Total_Cost__c, (SELECT Id FROM Service_Order_Headers__r WHERE Work_Status__c != 'Complete' AND Work_Status__c != 'Invoiced'),
    												(SELECT Id, Type__c FROM Deals_Units_Junction__r WHERE ((Deal__r.Status__c =: 'Quotation' OR Deal__r.Status__c =: 'In Progress') 
    												AND (Type__c =: Constants.DEAL_ITEM_TYPE_UNIT OR (Type__c =: Constants.DEAL_ITEM_TYPE_TRADE_IN 
    												AND Is_Stocked_In__c = false))))
    												from Customer_Owned_Unit__c WHERE Id =: unitId AND (Unit_Type__c =: 'COU' OR Unit_Type__c =: 'STOCK')];
    	
    	String errorMessage = '';
    	if(couList.size() > 0) {
    		if(couList[0].Service_Order_Headers__r.size() > 0) {
    			errorMessage = 'Unit is currently in use on a service job';
    		} else if(couList[0].Deals_Units_Junction__r.size() > 0 && couList[0].Unit_Type__c == 'COU' && couList[0].Deals_Units_Junction__r[0].Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
				errorMessage = 'Unit is currently selected as a trade-in on a deal';
    		} else if(couList[0].Deals_Units_Junction__r.size() > 0 && couList[0].Unit_Type__c == 'STOCK' && couList[0].Deals_Units_Junction__r[0].Type__c == Constants.DEAL_ITEM_TYPE_UNIT) { 
    			errorMessage = 'Unit is being sold on a deal';
    		} else if(couList[0].Unit_Type__c == 'STOCK' && couList[0].Total_Cost__c != 0) {
    			errorMessage = 'Cost of this unit is not zero';
    		}
    	}
    	return errorMessage;
    }
    
    
   /* private static Customer_Owned_Unit__c setCOUnitFields(CustomerOwnedUnit unitInfoObj) {
		
		Customer_Owned_Unit__c couRec = new Customer_Owned_Unit__c();
    	couRec.VIN_Number__c = unitInfoObj.VIN;
    	couRec.Unit_Type__c = unitInfoObj.UnitType;
    	couRec.Year__c = unitInfoObj.Year;
    	couRec.Unit_Make__c = unitInfoObj.Make;
		couRec.Unit_Model__c = unitInfoObj.Model;
		couRec.Sub_Model__c = unitInfoObj.SubModel;
    	couRec.Colour__c = unitInfoObj.Color;
    	couRec.Plate__c = unitInfoObj.Plate;
    	couRec.Mileage_Value__c = unitInfoObj.Mileage;
    	couRec.Mileage_Type__c = unitInfoObj.MileageType;
    	couRec.Key_No__c = unitInfoObj.KeyNo;
    	couRec.Engine_Serial_No__c = unitInfoObj.EngineSerialNumber;
    	couRec.Other_Serial_No__c = unitInfoObj.OtherSerialNumber;
    	couRec.Interior_Colour__c = unitInfoObj.InteriorColour;
    	couRec.Taxable__c = unitInfoObj.IsTaxable;
    	if(couRec.Taxable__c) {
    		couRec.Applicable_Tax__c = unitInfoObj.ApplicableTaxId;
    	} else {
    		couRec.Applicable_Tax__c = null;
    	}
    	couRec.Cylinders__c = unitInfoObj.Cylinders;
    	couRec.Displacement__c = unitInfoObj.Displacement;
    	couRec.Automatic__c = unitInfoObj.IsAutomatic;
    	couRec.Gears__c = unitInfoObj.Gears;
    	couRec.Status__c = unitInfoObj.Status;
    	couRec.New_Unit__c = unitInfoObj.IsNewUnit;
    	couRec.Category__c = unitInfoObj.CategoryId;
    	couRec.Date_Stocked_In__c = unitInfoObj.DateIn;
    	couRec.Date_Stocked_Out__c = unitInfoObj.DateOut;
    	couRec.Location__c = unitInfoObj.Location;
    	
    	return couRec;
	}*/
	
	/**
     * Name: getCOUListById
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    private static String getCOUListById(String unitId) {
        List<Customer_Owned_Unit__c> COUList = SOQLUtil.getUnitByFieldName(new Map<String, String>{'Id' => unitId});
        List<CustomerOwnedUnit> couObjList = new List<CustomerOwnedUnit>();
        for(Customer_Owned_Unit__c couRec : COUList) {
            couObjList.add(new CustomerOwnedUnit(couRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(couObjList));
    }
    
    /**
     * Name: getCOUListByCustomerId
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String getCOUListByCustomerId(String customerId) {
    	customerId = BPUtility.getDecodedString(customerId);
    	
        List<Customer_Owned_Unit__c> COUList = SOQLUtil.getCOURecordByFieldName('Account__c', customerId);
        List<CustomerOwnedUnit> couObjList = new List<CustomerOwnedUnit>();
        for(Customer_Owned_Unit__c couRec : COUList) {
            couObjList.add(new CustomerOwnedUnit(couRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(couObjList));
    }
    
    /**
     * Name: getCOURecordById
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String getCOURecordById(String couId) {
    	couId = BPUtility.getDecodedString(couId);
    	
        List<Customer_Owned_Unit__c> COUList = SOQLUtil.getCOURecordByFieldName('Id', couId);
        List<CustomerOwnedUnit> couObjList = new List<CustomerOwnedUnit>();
        for(Customer_Owned_Unit__c couRec : COUList) {
            couObjList.add(new CustomerOwnedUnit(couRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(couObjList));
    }
    
    /**
     * Name: getRelatedCustomerByCustomerId
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String getRelatedCustomerByCustomerId1(String customerId) {
        customerId = BPUtility.getDecodedString(customerId);
        return BPUtility.getEncodedString('[]');
    }
    
    /**
     * Name: getRelatedCustomerByCustomerId
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String getRelatedCustomerByCustomerId(String customerId) {
    	customerId = BPUtility.getDecodedString(customerId);
    	
        Map<String, String> accountIdToRelationMap = getRelatedCustomerRelationMap(customerId);
        List<Account> relatedCustomerRecList = SOQLUtil.getRelatedAccountRecs(accountIdToRelationMap.keyset());
        List<RelatedCustomer> relatedCustomerObjList = new List<RelatedCustomer>();
        for(Account relatedCustomerRec : relatedCustomerRecList) {
            relatedCustomerObjList.add(new RelatedCustomer(relatedCustomerRec, accountIdToRelationMap));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(relatedCustomerObjList));
    }
    
    /**
     * Name: getRelatedCustomerByCustomerId
     * Desc: To get Customer Inforamtion used in View Customer Page (Used in Test class)
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    public static Map<String, String> getRelatedCustomerRelationMap(String customerId) {
    	List<People__c> parentRelatedCustomerList = SOQLUtil.getRelatedCustomer(customerId, true);
        Map<String, String> accountIdToRelationMap = new Map<String, String>();
        for(People__c peopleRec : parentRelatedCustomerList) {
        	accountIdToRelationMap.put(peopleRec.Parent_Customer2__c, peopleRec.Relationship__c);
        }
        
        List<People__c> childRelatedCustomerList = SOQLUtil.getRelatedCustomer(customerId, false);
        for(People__c peopleRec : childRelatedCustomerList) {
        	if(peopleRec.Relationship__c == 'Employee') {
        		peopleRec.Relationship__c = 'Employer';
        	} 
        	accountIdToRelationMap.put(peopleRec.Parent_Customer1__c, peopleRec.Relationship__c);
        }
        return accountIdToRelationMap;
    }
    
    /**
     * Name: addRelatedCustomer
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String updateRelatedCustomer(String relatedCustomerString) {
    	if(AccessControl.ifObjectFieldIsCreateable('People__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('People__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		if(AccessControl.ifObjectFieldIsCreateable('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		if(AccessControl.ifObjectFieldIsUpdateable('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(AccessControl.ifObjectIsDeletable('People__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('People__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	relatedCustomerString = BPUtility.getDecodedString(relatedCustomerString);
    	
        List<RelatedCustomer> relatedCustomerObjList = RelatedCustomer.parse(relatedCustomerString);
        List<Account> relatedCustomerListToUpsert = new List<Account>();
        List<People__c> peopleRecToInsert = new List<People__c>();
        
        for(RelatedCustomer relatedCustomerObj : relatedCustomerObjList) {
            Account relatedCustomerRec = new Account();
            relatedCustomerRec.Id = relatedCustomerObj.Id;
            List<People__c> peopleList = [select Id from People__c Where (Parent_Customer1__c = :relatedCustomerObj.ParentCustomer AND Parent_Customer2__c = :relatedCustomerObj.Id) OR 
            															(Parent_Customer2__c = :relatedCustomerObj.ParentCustomer AND Parent_Customer1__c = :relatedCustomerObj.Id)]; 
	        if(relatedCustomerObj.Relation != null && relatedCustomerObj.Relation != '') {
	            People__c peopleRec = new People__c();
	            if(peopleList.size() > 0) {
	            	peopleRec.Id = peopleList[0].Id;
	            }
	            peopleRec.Parent_Customer1__c = relatedCustomerObj.ParentCustomer;
	            peopleRec.Parent_Customer2__c = relatedCustomerObj.Id;
	            peopleRec.Relationship__c = relatedCustomerObj.Relation;
	            peopleRecToInsert.add(peopleRec);
	        } else {
	            if(peopleList.size() > 0) {
	            	
	            	delete peopleList[0];
	            }
	        }
	    	relatedCustomerListToUpsert.add(relatedCustomerRec);
        }
        if(relatedCustomerListToUpsert.size() > 0) {
            upsert relatedCustomerListToUpsert;
        }
        if(peopleRecToInsert.size() > 0) {
        	upsert peopleRecToInsert;
        }
        String customerId = '';
        if(relatedCustomerObjList.size() > 0) {
            customerId = relatedCustomerObjList[0].ParentCustomer ;
        }
       
        return getRelatedCustomerByCustomerId(BPUtility.getEncodedString(customerId));
    }
    
    /**
     * Name: getCustomerContactByCustomerId
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String getCustomerContactByCustomerId(String customerId) {
    	customerId = BPUtility.getDecodedString(customerId);
    	
        List<Contact> customerContactList = SOQLUtil.getCustomerContactByFieldName('AccountId', customerId);
        List<CustomerContact> customerContactObjList = new List<CustomerContact>();
        for(Contact customerContactRec : customerContactList) {
            customerContactObjList.add(new CustomerContact(customerContactRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(customerContactObjList));
    }
    
    /**
     * Name: getCustomerContactById
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String getCustomerContactById(String customerContactId) {
    	customerContactId = BPUtility.getDecodedString(customerContactId);
    	
        List<Contact> customerContactList = SOQLUtil.getCustomerContactByFieldName('Id', customerContactId);
        List<CustomerContact> customerContactObjList = new List<CustomerContact>();
        for(Contact customerContactRec : customerContactList) {
            customerContactObjList.add(new CustomerContact(customerContactRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(customerContactObjList));
    }
    
    
    /**     
     * Name: updateCustomerContact
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String updateCustomerContact(String jsonString) {
    	jsonString = BPUtility.getDecodedString(jsonString);
    	
    	//system.assert(false, jsonString);
        List<CustomerContact> customerContactObjList = CustomerContact.parse(jsonString);
        
        List<Contact> customerContactListToInsert = new List<Contact>();
        for(CustomerContact customerContactObj : customerContactObjList) {
            Contact customerContactRec = new Contact();
            
            customerContactRec.FirstName = customerContactObj.FirstName;
            customerContactRec.LastName = customerContactObj.LastName;
            customerContactRec.Work_Email__c = customerContactObj.Email;
            customerContactRec.Phone = customerContactObj.Phone;
            customerContactRec.Preferred_Email__c = (customerContactObj.PreferredEmail == null) ? false : customerContactObj.PreferredEmail;
            customerContactRec.Preferred_Phone__c = (customerContactObj.PreferredPhone == null) ? false : customerContactObj.PreferredPhone;
            customerContactRec.Preferred_SMS__c = (customerContactObj.PreferredSMS == null)? false : customerContactObj.PreferredSMS;
            customerContactRec.Is_SMS__c = (customerContactObj.IsSMS == null) ? false : customerContactObj.IsSMS;
            customerContactRec.Job_Title__c = customerContactObj.JobTitle;
            customerContactRec.Relationship__c = customerContactObj.Relation;
            customerContactRec.AccountId = customerContactObj.ParentCustomer;
            if(customerContactObj.Id != null) {
            	customerContactRec.Id = customerContactObj.Id;
            }
            customerContactListToInsert.add(customerContactRec);
        }
        //system.assert(false, customerContactListToInsert);
        if(customerContactListToInsert.size() > 0) {
        	if(AccessControl.ifObjectIsCreateable('Contact') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
        	if(AccessControl.ifObjectIsUpdateable('Contact') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
            upsert customerContactListToInsert;
        }
        String customerId = '';
        if(customerContactListToInsert.size() > 0) {
            customerId = customerContactListToInsert[0].AccountId ;
        }
       
        return getCustomerContactByCustomerId(BPUtility.getEncodedString(customerId));
    }
    
    /**
     * Name: updateCustomerContactRelation
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String updateCustomerContactRelation(String jsonString) {
    	jsonString = BPUtility.getDecodedString(jsonString);
    	
    	//system.assert(false, jsonString);
        List<CustomerContact> customerContactObjList = CustomerContact.parse(jsonString);
        List<Contact> customerContactListToInsert = new List<Contact>();
        for(CustomerContact customerContactObj : customerContactObjList) {
            Contact customerContactRec = new Contact();
            customerContactRec.Relationship__c = customerContactObj.Relation;
            customerContactRec.AccountId = customerContactObj.ParentCustomer;
            if(customerContactObj.Id != null) {
            	customerContactRec.Id = customerContactObj.Id;
            }
            customerContactListToInsert.add(customerContactRec);
        }
        //system.assert(false, customerContactListToInsert);
        if(customerContactListToInsert.size() > 0) {
        	if(AccessControl.ifObjectIsCreateable('Contact') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
	       	if(AccessControl.ifObjectIsUpdateable('Contact') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
            upsert customerContactListToInsert;
        }
        String customerId = '';
        if(customerContactListToInsert.size() > 0) {
            customerId = customerContactListToInsert[0].AccountId ;
        }
        return getCustomerContactByCustomerId(BPUtility.getEncodedString(customerId));
    }
    
    /**
     * Name: getCustomerContactByCustomerId
     * Desc: To get Customer Inforamtion used in View Customer Page
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    public static String getLastVisitOrderByCustomerId(String customerId) {
        List<CO_Header__c> coHeaderList = SOQLUtil.getLastVisitOrderByCustomerId(customerId);
        String lastTime = '';
        if(coHeaderList.size() > 0) {
        	Long createdDateValue = coHeaderList[0].CreatedDate.getTime();
        	Long currentDateValue = system.now().getTime();
        	lastTime = String.valueOf(Integer.valueOf(((currentDateValue - createdDateValue)/ (1000 * 60 * 60 * 24)) / 30 )) + 'm ';
        	lastTime += String.valueOf(Integer.valueOf( Math.mod(((currentDateValue - createdDateValue)/ (1000 * 60 * 60 * 24)), 30))) + 'd ';
        	lastTime += String.valueOf(Integer.valueOf( Math.mod(((currentDateValue - createdDateValue)/ (1000 * 60 * 60)), 24))) + 'h';
        }
        return lastTime;
    }
    
    /**
     * Name: removeCustomerContactRecord
     * Desc: Remove Record with given Id
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String removeCustomerContactRecord(String customerId, String recordId) {
    	customerId = BPUtility.getDecodedString(customerId);
    	recordId = BPUtility.getDecodedString(recordId);
    	
        List<Sobject> sobjectListToDel = SOQLUtil.getReocrdByGivenId(recordId);
        if(sobjectListToDel.size() > 0) {
        	String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        	if(AccessControl.ifObjectIsDeletable(sObjName) == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
        	delete sobjectListToDel[0];
        }
        return getCustomerContactByCustomerId(BPUtility.getEncodedString(customerId));
    }
    
    /**
     * Name: removeCOURecord
     * Desc: Remove Record with given Id
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String removeCOURecord(String customerId, String recordId) {
    	customerId = BPUtility.getDecodedString(customerId);
    	recordId = BPUtility.getDecodedString(recordId);
    	
        List<Sobject> sobjectListToDel = SOQLUtil.getReocrdByGivenId(recordId);
        if(sobjectListToDel.size() > 0) {
        	String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        	if(AccessControl.ifObjectIsDeletable(sObjName) == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE);}
        	delete sobjectListToDel[0];
        }
        return getCOUListByCustomerId(BPUtility.getEncodedString(customerId));
    }
    
    
    @remoteAction
    global static String getSimilarUnits(String unitJSONString) {
    	unitJSONString = BPUtility.getDecodedString(unitJSONString);
    	//system.assert(false, unitJSONString);
    	CustomerOwnedUnit unitObj = (CustomerOwnedUnit) System.JSON.deserialize(unitJSONString, CustomerOwnedUnit.class);
    	//system.assert(false, unitObj);
    	Customer_Owned_Unit__c unitRecordFilterValue = setUnitFields(unitObj);
    	List<Customer_Owned_Unit__c> unitList = SOQLUtil.getOtherSimilarActiveUnits(unitRecordFilterValue);
    	List<UnitSuggestion> unitSuggestionList = new List<UnitSuggestion>();
    	for(Customer_Owned_Unit__c unitRec : unitList) {
    		if(String.isNotBlank(unitRecordFilterValue.VIN_Number__c) && String.isNotBlank(unitRec.VIN_Number__c)
    			&& unitRec.VIN_Number__c == unitRecordFilterValue.VIN_Number__c) {
    				unitSuggestionList.add(new UnitSuggestion(unitRec, 1));
			
			} else if( String.isNotBlank(unitRecordFilterValue.VIN_Number__c) && String.isNotBlank(unitRec.VIN_Number__c) && 
					unitRec.VIN_Number__c.length() == 17 && unitRecordFilterValue.VIN_Number__c.length() == 17 && 
    				unitRec.VIN_Number__c.subString(11, 17)== unitRecordFilterValue.VIN_Number__c.subString(11, 17)) 
    			{
    				unitSuggestionList.add(new UnitSuggestion(unitRec, 4));
			
			} else if(String.isNotBlank(unitRecordFilterValue.Plate__c) && unitRec.Plate__c == unitRecordFilterValue.Plate__c) {
				unitSuggestionList.add(new UnitSuggestion(unitRec, 2));
    			
    		} else if(String.isNotBlank(unitRecordFilterValue.Engine_Serial_No__c) && unitRec.Engine_Serial_No__c == unitRecordFilterValue.Engine_Serial_No__c) {
    				unitSuggestionList.add(new UnitSuggestion(unitRec, 3));
    			
    		} else if(String.isNotBlank(unitRecordFilterValue.Other_Serial_No__c) && unitRec.Other_Serial_No__c == unitRecordFilterValue.Other_Serial_No__c) {
    				unitSuggestionList.add(new UnitSuggestion(unitRec, 5));
    		}
    	}
    	unitSuggestionList.sort();
		Integer listSizeLimit = 7;
        if(unitSuggestionList.size() > listSizeLimit) {
            List<UnitSuggestion> unitSuggestionLimitedList = new List<UnitSuggestion>();
            for(Integer i = 0 ; i < listSizeLimit ; i++) {
                unitSuggestionLimitedList.add(unitSuggestionList[i]);
            }
            unitSuggestionList = new List<UnitSuggestion>();
            unitSuggestionList.addAll(unitSuggestionLimitedList);
        }
        return BPUtility.getEncodedString(System.JSON.serialize(unitSuggestionList));
    }
    
    private static Customer_Owned_Unit__c setUnitFields(CustomerOwnedUnit unitObj) {
    	Customer_Owned_Unit__c unitRecord = new Customer_Owned_Unit__c();
    	unitRecord.Other_Serial_No__c = unitObj.OtherSerialNo;
    	unitRecord.Engine_Serial_No__c = unitObj.EngineSerialNo;
    	unitRecord.Plate__c = unitObj.Plate;
    	unitRecord.VIN_Number__c = unitObj.VIN;
    	return unitRecord;
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
			if(String.isNotBlank(unitSubModelrec.Sub_Model_Name__c)) {
                unitSubModelItemList.add(new UnitSubModel(unitSubModelrec));
    	    }
    	}  
    	return BPUtility.getEncodedString(System.JSON.serialize(unitSubModelItemList));
    }
    
     /**
     * Name: getDefaultStockUnitData  
     * Desc: Get default data for new Stock Unit records
     * @param:  N/A
     * @return: String - Stock Unit JSON String.
    **/
    @remoteAction
    global static String getDefaultUnitCategory() {
        try{
            List<Category__c> defaultUnitCategories = SOQLUtil.getDefaultCategoryRecords(new Map<String, String>{'Type__c' => 'Unit', 'Status__c' => 'Active'});
            if(defaultUnitCategories.size() > 0) {
                Category__c defaultCategory = defaultUnitCategories[0];
                Category newCategory = new Category(defaultCategory);  
                return BPUtility.getEncodedString(System.JSON.serialize(newCategory));
            }
        }
        catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        
        return BPUtility.getEncodedString('{}');
    }
	
	@RemoteAction 
    global static String getVehicleSpecification(String vin) {
    	try {
            return BPUtility.getEncodedString(BRPVehicleIntegration.getVehicleSpecification(BPUtility.getDecodedString(vin)));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return 'success';
    }
    
    @remoteAction
    global static String getMakeModelSubmodelList() {
        try {
           return BPUtility.getEncodedString(MakeModelSubModelService.getMakeModelSubmodelList());
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    } 
}
