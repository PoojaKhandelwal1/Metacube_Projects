/**
* Author: Ankit Jain
* Since: June 30, 2016
* Name: UserSettingCtrl 
* Description: Apex class which contains all remoted methods related to UserSetting Page.
**/
 
global with sharing class UserSettingCtrl {
    
    global UserSettingCtrl (NewHomePageCtrl controller){}
    public UserSettingCtrl() {}
    
    public Boolean IsTrialOrg { get{return GeneralConfiguration.isTrialOrg();} private set;}
    public String communityURL { get{return GeneralConfiguration.communityLink();} private set;}
    public String communityquestionURL { get{return GeneralConfiguration.communityLink();} private set;}
    public String communitycaseURL { get{return GeneralConfiguration.communityLink();} private set;}
    private static final String BLACKPURL_PROFILE_NAME = 'Blackpurl';
    private static final List<String> PROFILE_NAME_LIST = new List<String>{BLACKPURL_PROFILE_NAME};
    private static final Integer MAX_TRAIL_USERS = 5;
    
    
    /**
     * Name: getAllUsers
     * Desc: Method which gives  List of Users which have ChatterFree profile in the org
       @param:    
     * @return: String - JSON String of list of Users which have ChatterFree profile in the org
    **/
    @RemoteAction
    global static String getAllUsers(){
        if(AccessControl.ifObjectFieldIsAccessible('Profile') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Profile> ProfilesList = [Select Id from Profile where Name IN: PROFILE_NAME_LIST];
        List<User> userList = [Select Name, FirstName, LastName, Email, CreatedDate, LastModifiedDate from User where isActive = true and ProfileId IN :ProfilesList order by Name Limit : MAX_TRAIL_USERS];
        List<UserWrapper> userWrapperList = new List<UserWrapper>();
        for(User userRecord : userList){
            //UserWrapper userWrapperRecord = new UserWrapper(userRecord.Name,userRecord.Email,false,userRecord.Id);
            List<Technician__c> techList = [Select Id, Type__c from Technician__c where User__c =: userRecord.Id];
            Boolean isTech = false;
            if(techList.size() > 0) {
                isTech = techList[0].Type__c == Constants.TECHNICIAN ? true : false;
            }
            UserWrapper userWrapperRecord = new UserWrapper(userRecord, false, isTech);
            if(techList.size() > 0) {
                userWrapperRecord.isTechnician = techList[0].Type__c == Constants.TECHNICIAN ? true : false;
            } else {
                userWrapperRecord.isTechnician = false;
            }
            userWrapperList.add(userWrapperRecord);
        }
        return BPUtility.getEncodedString(System.JSON.serialize(userWrapperList));
    }
    /**
     * Name: createUsers
     * Desc: Method which gives  creates new users of the Org
     * @param:  (1) JSONString - String - JSON String of UserWrapperList
     * @return: None
    **/

    @RemoteAction
    global static String createUsers(String userWrapperString){
        userWrapperString = BPUtility.getDecodedString(userWrapperString);
        UserWrapper userWrapperRecord = (UserWrapper)System.JSON.deserialize(userWrapperString,UserWrapper.class);
        if(AccessControl.ifObjectFieldIsAccessible('Profile') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Profile> ProfilesList = [Select id from Profile where name =: BLACKPURL_PROFILE_NAME];
        if(!String.isBlank(userWrapperRecord.firstName) && !String.isBlank(userWrapperRecord.lastName) && !String.isBlank(userWrapperRecord.email)){
            User newUserRecord = new User();
            newUserRecord.FirstName = userWrapperRecord.firstName;
            newUserRecord.LastName = userWrapperRecord.lastName;
            newUserRecord.Email = userWrapperRecord.email;
            String usrname = userWrapperRecord.firstName + ' ' + userWrapperRecord.lastName;
            if(userWrapperRecord.firstName.length() > 6){
                newUserRecord.Alias = userWrapperRecord.firstName.substring(0,6);
            }
            else{
                newUserRecord.Alias = userWrapperRecord.firstName;
            }
            newUserRecord.Username = userWrapperRecord.email;
            //newUserRecord.Username = newUserRecord.Email.split('@').get(0)+ Math.random()+'@blackpurl.com';
            newUserRecord.CommunityNickname = (usrname.substring(0,3) + Math.random()).substring(0,8);
            newUserRecord.LocaleSidKey = 'en_US';
            newUserRecord.TimeZoneSidKey = 'GMT';
            newUserRecord.ProfileID = ProfilesList.get(0).id;
            newUserRecord.LanguageLocaleKey = 'en_US';
            newUserRecord.EmailEncodingKey = 'UTF-8';
            newUserRecord.EmailEncodingKey = 'UTF-8';
            
            List<User> userList = [Select Name from User where isActive = true and ProfileId IN :ProfilesList Limit : MAX_TRAIL_USERS];
            for(User userRec: userList) {
                if(userRec.Name == usrname) {
                    throw new BlackPurlException('User with this name already exists.');
                }
            }
            
            try{
                if(AccessControl.ifObjectFieldIsCreateable('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                Database.DMLOptions dlo = new Database.DMLOptions(); 
			    dlo.EmailHeader.triggerUserEmail   = true; 
				Database.insert(newUserRecord,dlo);
            }
            catch(Exception e){
                if(e.getMessage().contains('DUPLICATE_USERNAME')){
                    throw new BlackPurlException('Username already registered.');
                } else if(e.getMessage().contains('LICENSE_LIMIT_EXCEEDED')){
                    throw new BlackPurlException('You have reached the adding user limit.');
                } else{
                    throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
                }
            }
            
            Technician__c clockingStaffObj = new Technician__c();
            clockingStaffObj.First_Name__c = userWrapperRecord.firstName;
            clockingStaffObj.Last_Name__c = userWrapperRecord.lastName;
            clockingStaffObj.Technician_Name__c = clockingStaffObj.First_Name__c + ' ' + clockingStaffObj.Last_Name__c;
            if(userWrapperRecord.IsTechnician) {
                clockingStaffObj.Type__c = Constants.TECHNICIAN;
            	clockingStaffObj.Role__c = Constants.TECHNICIAN;
            	clockingStaffObj.Working_Days__c = Constants.EVERY_BUSINESS_DAY;
            }
            clockingStaffObj.Active__c = true;
            List<Technician__c> clockingStaffList = SOQLUtil.getTechnicianListByFieldName(new Map<String, String>());
            for(Technician__c staff: clockingStaffList) {
                if(clockingStaffObj.Technician_Name__c == staff.Technician_Name__c) {
                    clockingStaffObj = staff;
                    break;
                }
            }
            
            clockingStaffObj.User__c = newUserRecord.Id;
            if(AccessControl.ifObjectFieldIsCreateable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            upsert clockingStaffObj;
            List<User> newUserList = [Select Id, Name, FirstName, LastName, Email, CreatedDate, LastModifiedDate from User where Id =: newUserRecord.Id];
            if(newUserList.size() > 0) {
            	newUserRecord = newUserList[0];
            	return BPUtility.getEncodedString(System.JSON.serialize(new UserWrapper(newUserRecord, false, userWrapperRecord.IsTechnician)));
            }
            
        }
        return BPUtility.getEncodedString('{}');
    }
    
    /**
     * Name: editUsers
     * Desc: Method which edits user of the Org
     * @param:  (1) JSONString - String - JSON String of UserWrapperList
     * @return: None
    **/

    @RemoteAction
    global static String editUsers(String userWrapperJson){
        userWrapperJson = BPUtility.getDecodedString(userWrapperJson);
        UserWrapper userWrapperRecord = (UserWrapper)System.JSON.deserialize(userWrapperJson,UserWrapper.class);
        User updateUserRecord = new User();
        updateUserRecord.FirstName = userWrapperRecord.firstName;
        updateUserRecord.LastName = userWrapperRecord.lastName;
        updateUserRecord.Email = userWrapperRecord.email;
        updateUserRecord.Id = userWrapperRecord.Id;
        String usrname = userWrapperRecord.firstName + ' ' + userWrapperRecord.lastName;
        
        List<Profile> ProfilesList = [Select id from Profile where name =: BLACKPURL_PROFILE_NAME];
        List<Id> userToEditIdList = new List<Id>{userWrapperRecord.Id};
        List<User> otherUsersList = [Select Name, Email from User where isActive = true and ProfileId IN :ProfilesList and Id NOT IN :userToEditIdList Limit : MAX_TRAIL_USERS];
        for(User userRec: otherUsersList) {
            if(usrname == userRec.Name) {
                throw new BlackPurlException('User with this name already exists.');
            }
            if(userWrapperRecord.email == userRec.Email) {
            	throw new BlackPurlException('User with this email already exists.');
            }
        }
         try{
            if(AccessControl.ifObjectFieldIsUpdateable('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update updateUserRecord;
            
        }
        catch(Exception e){
            if(e.getMessage().contains('DUPLICATE_USERNAME')){
                throw new BlackPurlException('Username already registered.');
            }else{
                throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
            }
        }
        
        List<User> newUserList = [Select Id, Name, FirstName, LastName, Email, CreatedDate, LastModifiedDate from User where Id =: updateUserRecord.Id];
        if(newUserList.size() > 0) {
        	updateUserRecord = newUserList[0];
        	updateTechnician(newUserList[0].Id);
        }
        return BPUtility.getEncodedString(System.JSON.serialize(new UserWrapper(updateUserRecord, false, userWrapperRecord.IsTechnician)));
    }
    
    @future
    private static void updateTechnician(Id userId) {
        List<User> userList = [Select Id, Name, FirstName, LastName from User where Id =: userId];
        List<Technician__c> techToUpdateList = new List<Technician__c>();
        List<Technician__c> updateTechnicianRecord = [Select Id from Technician__c where User__c = :userId];
        String usrname = userList[0].Name;
        if(updateTechnicianRecord.size() > 0) {
            List<Id> techToEditIdList = new List<Id>{updateTechnicianRecord[0].Id};
            List<Technician__c> otherTechnicianList = [Select Id, Technician_Name__c from Technician__c where Id NOT IN : techToEditIdList];
            Boolean isTechnicianExists = false;
            Technician__c existingTech = new Technician__c();
            for(Technician__c staff: otherTechnicianList) {
                if(usrname == staff.Technician_Name__c) {
                    existingTech = staff;
                    isTechnicianExists = true;
                    break;
                    
                }
            }
            
            if(isTechnicianExists) {
                existingTech.User__c = userList[0].Id;
                techToUpdateList.add(existingTech);
                updateTechnicianRecord[0].User__c = null;
                techToUpdateList.add(updateTechnicianRecord[0]);
            } else {
                updateTechnicianRecord[0].First_Name__c = userList[0].FirstName;
                updateTechnicianRecord[0].Last_Name__c = userList[0].LastName;
                updateTechnicianRecord[0].Technician_Name__c = updateTechnicianRecord[0].First_Name__c + ' ' + updateTechnicianRecord[0].Last_Name__c;
                techToUpdateList.add(updateTechnicianRecord[0]);
            }
        }
        
        if(AccessControl.ifObjectFieldIsUpdateable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update techToUpdateList;
    }
    /**
     * Name: deleteUser
     * Desc: Method to deactive user
       @param:    
     * @return: String - id of user to be deactivated
    **/
    @RemoteAction
    global static String deleteUser(String userId){
        userId = BPUtility.getDecodedString(userId);
        
        User userToDel = new User();
        userToDel.Id = userId;
        userToDel.isActive = false;
        
        List<Technician__c> techList = [Select Id from Technician__c where User__c =: userId];
        
        if(techList.size() > 0) {
            Id techId = techList[0].Id;
            String query;    
            query = 'SELECT ';  
            for(String fieldsName : SOHeaderWrapper.getHoursLoggedFieldsList()) {
                fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                query += fieldsName + ', ';  
            }
             
            query = query.substring(0, query.length()-2);
            query += ' FROM ' + Constants.NAMESPACE + 'Hours_Logged__c WHERE Technician__c =: techId ';
            if(AccessControl.ifObjectFieldIsAccessible('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Hours_Logged__c> hoursLoggedList = Database.query(query);
            Boolean isCurrentlyClocked = false;
            Boolean isPreviouslyClocked = false;
            //Boolean isAssigedButNotClocked = false;
            if(hoursLoggedList.size() == 0) {
                // delete
                if(AccessControl.ifObjectFieldIsUpdateable('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update userToDel;
            
                deleteTechnician(new List<Id>{techList[0].Id});
            } else if(hoursLoggedList.size() > 0) {
            	List<Id> hoursLoggedToDel = new List<Id>();
                for(Hours_Logged__c hrsLogged: hoursLoggedList) {
                    if(!isCurrentlyClocked && hrsLogged.Start_Date_Time__c != null && hrsLogged.End_Date_Time__c == null) {
                        isCurrentlyClocked = true;
                    }
                    if(!isPreviouslyClocked && hrsLogged.Start_Date_Time__c != null && hrsLogged.End_Date_Time__c != null) {
                        isPreviouslyClocked = true;
                    }
                    if(hrsLogged.Start_Date_Time__c == null && hrsLogged.End_Date_Time__c == null) { // !isAssigedButNotClocked && 
	                    //isAssigedButNotClocked = true;
	                    hoursLoggedToDel.add(hrsLogged.Id);
	                }
                }
                
                if(isCurrentlyClocked) {
                    throw new BlackPurlException('Technician is currently clocked on some service job');
                } else if(isPreviouslyClocked) {
                    if(AccessControl.ifObjectFieldIsUpdateable('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update userToDel;
                    
                    techList[0].Active__c = false;
                    inactiveTechnician(techList[0].Id);
                } else if(hoursLoggedToDel.size() > 0) {
	                if(AccessControl.ifObjectFieldIsUpdateable('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update userToDel;
	                
	                List<Id> idListToDel = new List<Id>{techList[0].Id}; 
	                idListToDel.addAll(hoursLoggedToDel);
	                deleteTechnician(idListToDel);
	                
	                //delete hoursLoggedToDel;
	                
	            } else {
                    if(AccessControl.ifObjectFieldIsUpdateable('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update userToDel;
            
                    deleteTechnician(new List<Id>{techList[0].Id});
                }
            }
        } else {
            if(AccessControl.ifObjectFieldIsUpdateable('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update userToDel;
        }
        return getAllUsers();
    }
    
    @future
    private static void deleteTechnician(List<Id> idListToDel) {
    	for(Id idValue: idListToDel) {
    		if(idValue.getSobjectType().getDescribe().getName() == Constants.Namespace + 'Technician__c') {
    			Technician__c techToDel = new Technician__c();
        		techToDel.Id = idValue;
        		if(AccessControl.ifObjectIsDeletable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        		delete techToDel;
    		} else if(idValue.getSobjectType().getDescribe().getName() == Constants.Namespace + 'Hours_Logged__c') {
    			Hours_Logged__c hoursLoggedToDel = new Hours_Logged__c();
		        hoursLoggedToDel.Id = idValue;
		        if(AccessControl.ifObjectIsDeletable('Hours_Logged__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
		        delete hoursLoggedToDel;
    		}
    	}
    }
    
    @future
    private static void inactiveTechnician(Id techId) {
        Technician__c techToDel = new Technician__c();
        techToDel.Id = techId;
        techToDel.Active__c = false;
        if(AccessControl.ifObjectFieldIsUpdateable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        update techToDel;
    }
    
    /**
     * Name: getPriceAndTaxMasterData
     * Desc: Method that provides List of all sales tax and price levels
       @param:  
     * @return: String - JSON String of lists of both sales tax and price levels
    **/
    @RemoteAction
    global static String getPriceAndTaxMasterData() {
        List<Sales_Tax__c> salesTaxList = SOQLUtil.getSalesTax(new List<Id>());
        List<Price_Level__c> priceLevelList = SOQLUtil.getPriceLevel(new List<Id>());
        List<Country__c> countryList = SOQLUtil.getAllCountry();
        List<Country__c> countryWrapperList = SOQLUtil.getAllCountryWrapper();
        /*List<Fee__c> feeList = new List<Fee__c>();
        String defaultEnvFeeId = Configurations__c.getOrgDefaults().Default_Environmental_Fee__c;
        if(String.isNotBlank(defaultEnvFeeId)) {
        	feeList = SOQLUtil.getFeeByFieldName(new Map<String, String>{'Id' => defaultEnvFeeId});
        }*/
        PriceAndTaxMasterData priceAndTaxMasterDataObj = new PriceAndTaxMasterData(salesTaxList, priceLevelList,countryList,countryWrapperList);
        return BPUtility.getEncodedString(System.Json.serialize(priceAndTaxMasterDataObj));
    }
    
    @RemoteAction
    global static String getActiveFeeList() {
    	return BPUtility.getEncodedString(ViewFeeCtrl.getActiveFeeList('Env Fee'));
    }
    
    @RemoteAction
    global static String getAllActiveFeeList(String feeType) {
    	feeType = BPUtility.getDecodedString(feeType);
    	return BPUtility.getEncodedString(ViewFeeCtrl.getActiveFeeList(feeType));
    }
    
    /**
     * Name: getCurrentConfiguration
     * Desc: Method that provides current configuration data to show on user setting - price and tax section
       @param:  
     * @return: String - JSON String of current configuration data
    **/
    @RemoteAction
    global static String getCurrentConfiguration() {
        List<Price_Level__c> priceLevelList = [Select Id, Name__c from Price_Level__c where Default__c = true];
        Price_Level__c defaultPriceLevelRec;
        if(priceLevelList.size() > 0) {
            defaultPriceLevelRec = priceLevelList[0];
        } else {
            defaultPriceLevelRec = new Price_Level__c();
        }
        List<Business_Profile__c> businessProfiles = SOQLUtil.getBusinessProfileData(new List<id>());
        PriceAndTaxWrapper priceAndTaxWrapperObj;
        if(businessProfiles.size() > 0) {
        	priceAndTaxWrapperObj = new PriceAndTaxWrapper(defaultPriceLevelRec,businessProfiles[0]);
        } else{
        	priceAndTaxWrapperObj = new PriceAndTaxWrapper(defaultPriceLevelRec,new Business_Profile__c());
        }
        	priceAndTaxWrapperObj.shopSettingConfiguration = AccountSettingService.getShopSettingData();
        return BPUtility.getEncodedString(System.JSON.serialize(priceAndTaxWrapperObj));
    }
    
    /**
     * Name: savePriceAndTax
     * Desc: Method to save new configuration for sales tax and price level
       @param:  
    **/
    @RemoteAction
    global static string savePriceAndTax(String priceAndTaxJsonData){
        if(AccessControl.ifObjectFieldIsUpdateable('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); } //FLS Create Nikhil 31/01/2017
        if(AccessControl.ifObjectFieldIsUpdateable('Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); } //FLS Update Nikhil 31/01/2017
        
        priceAndTaxJsonData = BPUtility.getDecodedString(priceAndTaxJsonData);
        PriceAndTaxWrapper priceAndTaxWrapperObj = (PriceAndTaxWrapper) System.JSON.deserialize(priceAndTaxJsonData, PriceAndTaxWrapper.class);
        //system.assert(false, priceAndTaxWrapperObj);
        update new Price_Level__c(Id = priceAndTaxWrapperObj.defaultPriceLevel, Default__c = true);
        //List<Sobject> sobjList = new List<Sobject>();
           
        Configurations__c configurationSettingObj = Configurations__c.getOrgDefaults();
        configurationSettingObj.Default_Tax_on_Labor__c = priceAndTaxWrapperObj.defaultLaborTax;
        configurationSettingObj.Default_Tax_on_Vendor_Product__c = priceAndTaxWrapperObj.defaultVendorItemTax;
        configurationSettingObj.Default_Tax_on_Part__c = priceAndTaxWrapperObj.defaultPartTax;
        configurationSettingObj.Default_Tax_on_Fee__c = priceAndTaxWrapperObj.defaultFeeTax;
        configurationSettingObj.Ordering_Tax_Rate__c = priceAndTaxWrapperObj.orderingTaxRate;
        configurationSettingObj.Default_Tax_on_Unit__c = priceAndTaxWrapperObj.DefaultUnitTax;
        configurationSettingObj.Tax_Included_Pricing__c = priceAndTaxWrapperObj.priceIncludeTax;
        configurationSettingObj.Country_Id__c = priceAndTaxWrapperObj.regionId;
        configurationSettingObj.State_Id__c = priceAndTaxWrapperObj.stateId;
        configurationSettingObj.Time_Zone__c = priceAndTaxWrapperObj.timezoneId;
        configurationSettingObj.Tax_Id__c = priceAndTaxWrapperObj.taxId;
        
        configurationSettingObj.Default_Price_Level_on_Internal_Service__c = priceAndTaxWrapperObj.DefaultPriceLevelOnInternalService;
        configurationSettingObj.Default_Sales_Tax_on_Internal_Service__c = priceAndTaxWrapperObj.DefaultSalesTaxOnInternalService;
        configurationSettingObj.Default_Environmental_Fee__c = priceAndTaxWrapperObj.DefaultEnvironmentalFee;
        configurationSettingObj.Cash_Payment_Rounding_Factor__c = priceAndTaxWrapperObj.CashPaymentRoundingFactor;// 4th may 2017 kajal
        configurationSettingObj.Stamp_Duty_Rate__c = priceAndTaxWrapperObj.StampDutyRate;
        configurationSettingObj.Accrue_Trade_Tax_Until_Unit_Sold__c = priceAndTaxWrapperObj.AccrueTradeTaxUntilUnitSold;
        configurationSettingObj.Trade_Tax_Pending_Sale_Category__c = priceAndTaxWrapperObj.TradeTaxPendingSaleCategory;
        configurationSettingObj.Trade_Tax_Liability_Category__c = priceAndTaxWrapperObj.TradeTaxLiabilityCategory;
        configurationSettingObj.Trade_Tax_Expense_Category__c = priceAndTaxWrapperObj.TradeTaxExpenseCategory;
        configurationSettingObj.Trade_Tax_Credit_Can_Not_Exceed_Unit_Tax__c = !priceAndTaxWrapperObj.priceIncludeTax ? priceAndTaxWrapperObj.TradeTaxCreditCanNotExceedUnitTax : false;
        //sobjList.add(configurationSettingObj);
        
        Part_Aging_Period__c partAgingObj = Part_Aging_Period__c.getOrgDefaults();
        Boolean isValueChangedForAgeing = false;
        if(priceAndTaxWrapperObj.Period1 != partAgingObj.Period_1__c || priceAndTaxWrapperObj.Period2 != partAgingObj.Period_2__c ||
            priceAndTaxWrapperObj.Period3 != partAgingObj.Period_3__c || priceAndTaxWrapperObj.Period4 != partAgingObj.Period_4__c) {
            isValueChangedForAgeing = true;
        }
        partAgingObj.Period_1__c = priceAndTaxWrapperObj.Period1;
        partAgingObj.Period_2__c = priceAndTaxWrapperObj.Period2;
        partAgingObj.Period_3__c = priceAndTaxWrapperObj.Period3;
        partAgingObj.Period_4__c = priceAndTaxWrapperObj.Period4;
        
        Shop_Supplies__c shopSuppliesObj = Shop_Supplies__c.getOrgDefaults();
        shopSuppliesObj.Applicable_Fee__c = priceAndTaxWrapperObj.ApplicableFee;
        shopSuppliesObj.Calculation_Method__c = priceAndTaxWrapperObj.CalculationMethod;
        shopSuppliesObj.Itemized_by_labor_code__c = priceAndTaxWrapperObj.ItemizedByLaborCode;
        shopSuppliesObj.Maximum_Per_Invoice__c = priceAndTaxWrapperObj.MaximumPerInvoice;
        shopSuppliesObj.Supplies_Rate__c = priceAndTaxWrapperObj.SuppliesRate;
        upsert shopSuppliesObj;
 		upsert configurationSettingObj;
        upsert partAgingObj;
        
        if(isValueChangedForAgeing) {
            Database.executeBatch(new PartSyncAgeBatch_Schedular(), 200); 
        }
        
        List<Business_Profile__c> businessProfiles = SOQLUtil.getBusinessProfileData(new List<id>());
        if(businessProfiles.size() > 0) {
        	Business_Profile__c businessProfileRec =  businessProfiles[0];
        	if(AccessControl.ifObjectFieldIsUpdateable('Business_Profile__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	        
	        businessProfileRec.Customer_Invoice_Warranty_Text__c = priceAndTaxWrapperObj.CustomerInvoiceWarrantyText;
	        businessProfileRec.Service_Job_Warranty_Text__c = priceAndTaxWrapperObj.ServiceJobWarrantyText;
	        businessProfileRec.Order_Deposit_Warranty_Text__c = priceAndTaxWrapperObj.OrderDepositWarrantyText;
	        businessProfileRec.Deal_Documents_Warranty_Text__c = priceAndTaxWrapperObj.DealDocumentsWarrantyText;
	        businessProfileRec.Sales_Receipt_Warranty_Text__c = priceAndTaxWrapperObj.SalesReceiptWarrantyText;
	         
	        businessProfileRec.is_Signature_Line_for_Customer_Invoice__c = priceAndTaxWrapperObj.IsSignatureLineforCustomerInvoice;
	        businessProfileRec.is_Signature_Line_for_Service_Job__c = priceAndTaxWrapperObj.IsSignatureLineforServiceJob;
	        businessProfileRec.is_Signature_Line_for_Order_Deposit__c = priceAndTaxWrapperObj.IsSignatureLineforOrderDeposit;
	        businessProfileRec.Is_Signature_Line_for_Deal_Documents__c = priceAndTaxWrapperObj.IsSignatureLineforDealDocuments;
	        businessProfileRec.Is_Signature_Line_for_Sales_Receipt__c = priceAndTaxWrapperObj.IsSignatureLineforSalesReceipt;
	        
	        update businessProfileRec;
        }
        List<Shop_Settings__c> shopSettingList = new List<Shop_Settings__c>();
        if(priceAndTaxWrapperObj.shopSettingConfiguration != null) {
        	shopSettingList = AccountSettingService.setShopSettingConfigRec(priceAndTaxWrapperObj.shopSettingConfiguration);
        	update shopSettingList;
        }
                     
        return getCurrentConfiguration();
    }
    
    /**
     * Name: getBusinessProfileMasterData
     * Desc: Method that provides master data for business profile section
       @param:  
     * @return: String - JSON String of lists of countries and states along with business profile warpper object
    **/
    @RemoteAction
    global static String getBusinessProfileMasterData(){
        List<Country__c> countryWrapperList = SOQLUtil.getAllCountryWrapper();
        List<Business_Profile__c> businessProfiles = SOQLUtil.getBusinessProfileData(new List<id>());
        BusinessProfileMasterData businessProfileMasterDataObj = new BusinessProfileMasterData(countryWrapperList, businessProfiles);
        
        return BPUtility.getEncodedString(System.JSON.serialize(businessProfileMasterDataObj));
    }
    
     /**
     * Name: getBillingProfile
     * Desc: Method that provides master data for business profile section
       @param:  
     * @return: String - JSON String of lists of countries and states along with business profile warpper object
    **/
     @RemoteAction 
     global static Integer getBillingProfile(){
        if(AccessControl.ifObjectFieldIsAccessible('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<User> userList = [Select id, createddate from user ORDER BY createddate ASC LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
        String namespace = [Select NamespacePrefix, Name, Id From ApexClass where Name = 'Constants'].NamespacePrefix;

        List<PackageLicense> packLicRec = [SELECT Id,Status,Expirationdate, NamespacePrefix FROM PackageLicense WHERE
                             NamespacePrefix = :namespace];
         Integer noOfDays = 0;
         if(packLicRec.size() > 0 && packLicRec[0].Expirationdate != null){
            Date startDate = Date.valueOf(packLicRec[0].Expirationdate);  
            noOfDays = (Date.today().daysBetween(startDate));
         }
        return noOfDays;
    }
    
    
    /**
     * Name: saveBusinessProfile
     * Desc: Method to save new configuration for business profile
       @param:  
    **/
    @RemoteAction
    global static string saveBusinessProfile(String BusinessProfileJsonData){
        BusinessProfileJsonData = BPUtility.getDecodedString(BusinessProfileJsonData);
        
        BusinessProfileWrapper businessProfileObj = (BusinessProfileWrapper) System.JSON.deserialize(BusinessProfileJsonData, BusinessProfileWrapper.class);
        Business_Profile__c businessProfile = new Business_Profile__c();
          
        if(businessProfileObj.Id == null){
            if(AccessControl.ifObjectIsCreateable('Business_Profile__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
        }else{
            if(AccessControl.ifObjectIsUpdateable('Business_Profile__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE);}
            businessProfile.Id = businessProfileObj.Id;
        }
        
        businessProfile.Business_Name__c = businessProfileObj.BusinessName;
        businessProfile.Business_Phone__c = businessProfileObj.BusinessPhone;
        businessProfile.Business_Email__c = businessProfileObj.BusinessEmail;
        businessProfile.Business_Street_Address1__c = businessProfileObj.BusinessStreetAddress1;
        businessProfile.Business_Street_Address2__c = businessProfileObj.BusinessStreetAddress2;
        businessProfile.Business_City__c = businessProfileObj.BusinessCity;
        businessProfile.Business_Postal_Code__c = businessProfileObj.BusinessZipCode;
        businessProfile.Business_Country__c = businessProfileObj.BusinessCountryId;
        businessProfile.Business_State__c = businessProfileObj.BusinessStateId;
        
        businessProfile.Same_As_Business_Address__c = businessProfileObj.IsSameAsBusinessAddress;
        
        if(businessProfileObj.isSameAsBusinessAddress == true){
            businessProfile.Shipping_Street_Address1__c = businessProfileObj.BusinessStreetAddress1;
            businessProfile.Shipping_Street_Address2__c = businessProfileObj.BusinessStreetAddress2;
            businessProfile.Shipping_City__c = businessProfileObj.BusinessCity;
            businessProfile.Shipping_Postal_Code__c = businessProfileObj.BusinessZipCode;
            businessProfile.Shipping_Country__c = businessProfileObj.BusinessCountryId;
            businessProfile.Shipping_State__c = businessProfileObj.BusinessStateId;
        }else{
            businessProfile.Company_Name_Optional__c = businessProfileObj.ShippingCompanyName;
            businessProfile.Shipping_Street_Address1__c = businessProfileObj.ShippingStreetAddress1;
            businessProfile.Shipping_Street_Address2__c = businessProfileObj.ShippingStreetAddress2;
            businessProfile.Shipping_City__c = businessProfileObj.ShippingCity;
            businessProfile.Shipping_Postal_Code__c = businessProfileObj.ShippingZipCode;
            businessProfile.Shipping_Country__c = businessProfileObj.ShippingCountryId;
            businessProfile.Shipping_State__c = businessProfileObj.ShippingStateId;
        }
       
        upsert businessProfile;
        
        return getBusinessProfileMasterData();
    }
    
    
    
    /**
     * Name: sendEmail
     * Desc: Method to send Email for support and contact
       @param:  
    **/
    @RemoteAction
    global static String sendEmail(String subjectKey){
        subjectKey = BPUtility.getDecodedString(subjectKey);
        
        List<Business_Profile__c> businessProfiles = SOQLUtil.getBusinessProfileData(new List<id>());
        Business_Profile__c businessProfileObj = businessProfiles.size() > 0 ? businessProfiles[0] : null;
        String companyName = businessProfileObj != null ? businessProfileObj.Business_Name__c : '';
        String subject = getMailSubject(subjectKey, companyName);
        String htmlBody = getEmailTemplateBody(subjectKey, businessProfileObj);
        
        String defaultEmail = GeneralConfiguration.getSupportEmail();
        List<String> emailStrList = new List<String>{defaultEmail};
        try{
            SendEmail.sendSupportMail(emailStrList, subject, htmlBody); 
        }catch(Exception e){
            throw new BlackPurlException(Label.NewHomePage_Mail_error);
        }
        
        return BPUtility.getEncodedString(Label.NewHomePage_Conatct_Support);
    }
    
    
    /* deprecated */
    global static string sendEmail(String subject, String htmlBody){
        /*subject = BPUtility.getDecodedString(subject);
        htmlBody = BPUtility.getDecodedString(htmlBody);
        String defaultEmail = 'hitesh.gupta@metacube.com';
        List<String> emailStrList = new List<String>{defaultEmail};
        try{
            SendEmail.sendSupportMail(emailStrList, subject, htmlBody); 
        }catch(Exception e){
            throw new BlackPurlException(Label.NewHomePage_Mail_error);
        }
        */
        return BPUtility.getEncodedString('');
    }
    
    public static String getMailSubject(String subjectKey, String companyName) {
        if(subjectKey == 'Add Licences'){
             return '[License Request] : Add user license request for '+ companyName;
        }
        else if(subjectKey == 'Buy More Licenses'){
             return '[License Request] : Add user license request for '+ companyName;
        }
        else if(subjectKey == 'Upgrade Your Account'){
             return ' [Account Upgrade Request] : Upgrade Account status for '+companyName;
        }
        else if(subjectKey == 'Cancel Your Licenses'){
             return '[License Cancel Request] : Cancel user license request for '+companyName;
        }else{
            return '';          
        }
    }
    
    public static String getEmailTemplateBody(String subjectKey, Business_Profile__c businessProfileObj) {
        String htmlBody = '';
        Boolean IsTrialOrg = GeneralConfiguration.isTrialOrg();
        Boolean IsSystemSettingVisited = GeneralConfiguration.isSystemSettingVisited();
        String LicenseStatus = IsTrialOrg ? (IsSystemSettingVisited ? 'Trial with own data' : 'Trial with Demo data') : 'Licensed';
        if(businessProfileObj == null){
            htmlBody = 'No information provided';
        }else{
            if(subjectKey == 'Add Licences'){
                htmlBody += '<p>A request has been sent to add more users licences by </p>';
                htmlBody += '<p>Company Name :-   '+ BusinessProfileObj.Business_Name__c +'</p>';
                htmlBody += '<p>Org ID :-         '+ UserInfo.getOrganizationId() +'</p>';
                htmlBody += '<p>License Status :- '+ LicenseStatus +'</p>';
                htmlBody += '<p>Contact Number :- '+ BusinessProfileObj.Business_Phone__c +'</p>';
                htmlBody += '<p>Email :-          '+ BusinessProfileObj.Business_Email__c +'</p>';
            }
            else if(subjectKey == 'Buy More Licenses'){
                htmlBody += '<p>A request has been sent to add more users licences by </p>';
                htmlBody += '<p>Company Name :-   '+ BusinessProfileObj.Business_Name__c +'</p>';
                htmlBody += '<p>Org ID :-         '+ UserInfo.getOrganizationId() +'</p>';
                htmlBody += '<p>License Status :- '+ LicenseStatus +'</p>';
                htmlBody += '<p>Contact Number :- '+ BusinessProfileObj.Business_Phone__c +'</p>';
                htmlBody += '<p>Email :-          '+ BusinessProfileObj.Business_Email__c +'</p>';
            }
            else if(subjectKey == 'Upgrade Your Account'){
                htmlBody += '<p>A request has been sent to upgrade account status by </p>';
                htmlBody += '<p>Company Name :-   '+ BusinessProfileObj.Business_Name__c +'</p>';
                htmlBody += '<p>Org ID :-         '+ UserInfo.getOrganizationId() +'</p>';
                htmlBody += '<p>License Status :- '+ LicenseStatus +'</p>';
                htmlBody += '<p>Contact Number :- '+ BusinessProfileObj.Business_Phone__c +'</p>';
                htmlBody += '<p>Email :-          '+ BusinessProfileObj.Business_Email__c +'</p>';
            }
            else if(subjectKey == 'Cancel Your Licenses'){
                htmlBody += '<p>A request has been sent to cancel/reduce user licences status by </p>';
                htmlBody += '<p>Company Name :-   '+ BusinessProfileObj.Business_Name__c +'</p>';
                htmlBody += '<p>Org ID :-         '+ UserInfo.getOrganizationId() +'</p>';
                htmlBody += '<p>License Status :- '+ LicenseStatus +'</p>';
                htmlBody += '<p>Contact Number :- '+ BusinessProfileObj.Business_Phone__c +'</p>';
                htmlBody += '<p>Email :-          '+ BusinessProfileObj.Business_Email__c +'</p>';
            }
        }
        return htmlBody;
    }
    
    
    /**
     * Name: upgradeAccount
     * Desc: Method to send Email for upgrade Account
       @param:  
    **/
    @RemoteAction
    global static string upgradeAccount(String billingInfo){
        billingInfo = BPUtility.getDecodedString(billingInfo);
        
        BillingWrapper billingInfoObj = (BillingWrapper)System.JSON.deserialize(billingInfo, BillingWrapper.class);
       //system.assert(false, billingInfoObj);
        List<String> monthNames = new List<String>{'','Jan', 'Feb', 'Mar','Apr', 'May', 'Jun', 'Jul','Aug', 'Sep', 'Oct','Nov', 'Dec'};
       	String dateFormat = BPUtility.getDateFormat();
        String UpgradeDate = '';
        if(billingInfoObj.UpgradeDate != null){
        	List<String> dateFormatList = dateFormat.Split('/');
        	List<String> formattedDate = billingInfoObj.UpgradeDate.split('/');
            if(dateFormatList[0].equals('mm')){
            	formattedDate[0] = monthNames[Integer.valueof(formattedDate[0])];
            }else if(dateFormatList[1].equals('mm')){
            	formattedDate[1] = monthNames[Integer.valueof(formattedDate[1])];
            }
            
            UpgradeDate = formattedDate[0] +'-'+formattedDate[1] +'-'+formattedDate[2];
        }
        Boolean IsTrialOrg = GeneralConfiguration.isTrialOrg();
        Boolean IsSystemSettingVisited = GeneralConfiguration.isSystemSettingVisited();
        String LicenseStatus = IsTrialOrg ? (IsSystemSettingVisited ? 'Trial with own data' : 'Trial with Demo data') : 'Licensed';
        List<Business_Profile__c> businessProfiles = SOQLUtil.getBusinessProfileData(new List<id>());
        Business_Profile__c businessProfileObj = businessProfiles.size() > 0 ? businessProfiles[0] : null;
        String companyName = businessProfileObj != null ? businessProfileObj.Business_Name__c : '';
        String subject = '[Upgrade Account Request] : Upgrade Account request for '+companyName;
        String htmlBody = '';
        
        if(businessProfileObj == null){
            htmlBody = 'No information provided';
        }else{
            htmlBody += '<p>A request has been sent to upgrade Account by </p>';
            htmlBody += '<p>Phone No:-    '+ billingInfoObj.IDDCode+'-'+billingInfoObj.Phone+'</p>';
            htmlBody += '<p>Date :-   '+ UpgradeDate +'</p>';
            htmlBody += '<p>Time :-   '+ billingInfoObj.UpgradeTime +'</p>';
            htmlBody += '<p style="font-weight: bold;">Business Information :-</p>';
            htmlBody += '<p>Company Name :-   '+ BusinessProfileObj.Business_Name__c +'</p>';
            htmlBody += '<p>Org ID :-         '+ UserInfo.getOrganizationId() +'</p>';
            htmlBody += '<p>License Status :- '+ LicenseStatus +'</p>';
            htmlBody += '<p>Contact Number :- '+ BusinessProfileObj.Business_Phone__c +'</p>';
            htmlBody += '<p>Email :-          '+ BusinessProfileObj.Business_Email__c +'</p>';
        }
        
        String defaultEmail = GeneralConfiguration.getSupportEmail();
        List<String> emailStrList = new List<String>{defaultEmail};
        try{
            SendEmail.sendSupportMail(emailStrList, subject, htmlBody); 
        }catch(Exception e){
            throw new BlackPurlException(Label.NewHomePage_Mail_error);
        }
        
        return BPUtility.getEncodedString(Label.NewHomePage_Conatct_Support);
    }
    
    
    /**
     * Name: setSystemSettingVisited
     * Desc: Method to set system setting visited flag to true
       @param:  
    **/
    @RemoteAction
    global static void setSystemSettingVisited(){
        if(AccessControl.ifObjectFieldIsCreateable('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); } //FLS Create Nikhil 31/01/2017 
        if(AccessControl.ifObjectFieldIsUpdateable('General_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); } //FLS Update Nikhil 31/01/2017
        
        Boolean IsSystemSettingVisited = GeneralConfiguration.isSystemSettingVisited();
        if(!IsSystemSettingVisited){
            General_Configurations__c GCObj = General_Configurations__c.getOrgDefaults();
            GCObj.Is_System_Setting_Visited__c = true;
            upsert GCObj;
        }
    }
    
    /**
     * Name: getExportFiles
     * Desc: Method to send Email for support and contact
       @param:  
    **/
    @RemoteAction
    global static string getExportFiles(){
        if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<ExportedData> exportedFiles = new List<ExportedData>();
        
        List<Accounting_Data_Migration__c> admList = [Select Id, Object_Name__c, Last_Synched__c, Records_Processed__c, 
        												(Select Id, Name, CreatedDate, CreatedBy.Name, LastModifiedDate, Description From Attachments order by CreatedDate DESC) 
        											 FROM Accounting_Data_Migration__c limit: SOQLUtil.getAvailableQueryRowsLimit()];
        
        // Get accounting data records with most recent Attachment List
        Map<Id, List<Attachment>> admIdToAttachmentListMap = new Map<Id, List<Attachment>>();
        for(Accounting_Data_Migration__c adm : admList) {
        	Set<String> attchNameSet = new Set<String>();
        	List<Attachment> attachList = new List<Attachment>();
        	for(Attachment attachRec : adm.Attachments) {
    			String attNamePrefix = attachRec.Name.substringBeforeLast('_');
        		if(!attchNameSet.contains(attNamePrefix)) {
        			attachList.add(attachRec);
        			attchNameSet.add(attNamePrefix);
        		}
        	}
        	exportedFiles.add(new ExportedData(adm, attachList));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(exportedFiles));
    }
    
    
    /**
     * Name: exportData
     * Desc: Method to send Email for support and contact
       @param:  
    **/
    @RemoteAction
    global static string exportData(){
        DataExportService DES = new DataExportService();
        DES.objectName = '';
        DES.exportAccountingData();
        return BPUtility.getEncodedString('Export Data scheduled successfully');
        //return System.JSON.serialize(exportedFiles);
    }
    public class UserWrapper{
        private String name;
        private String firstName;
        private String lastName;
        private String email;
        private Boolean isNew;
        private String id;
        private Boolean isTechnician;
        private String createdDate;
        private String lastModifiedDate;
        
        public UserWrapper(String name,String email,Boolean isNew,String id){
            this.name = name;
            this.email = email;
            this.isNew = isNew;
            this.id = id;
        }
        
        public UserWrapper(User userRec, Boolean isNew, Boolean IsTechnician){
            this.name = userRec.Name;
            this.firstName = userRec.FirstName;
            this.lastName = userRec.LastName;
            this.email = userRec.Email;
            this.isNew = isNew;
            this.id = userRec.Id;
            this.isTechnician = IsTechnician;
            String userLocale = UserInfo.getLocale();
            this.createdDate = userRec.CreatedDate != null ? userRec.CreatedDate.format(Constants.localeToDateTimeFmtMap.get(userLocale)) : null;
            this.lastModifiedDate = userRec.LastModifiedDate != null ? userRec.LastModifiedDate.format(Constants.localeToDateTimeFmtMap.get(userLocale)) : null;
        }
    }
    
    public class PriceAndTaxMasterData{
        public List<RecordItem> salesTaxList;
        public List<RecordItem> priceLevelList;
        public List<Country> countryList;
        public List<CountryWrapper> stateList;
        public List<String> timezoneList;
        
        public PriceAndTaxMasterData(List<Sales_Tax__c> salesTaxList, List<Price_Level__c> priceLevelList, List<Country__c> countryList, 
        									List<Country__c> countryWrapperList){  
            this.countryList = new List<Country>();
            this.salesTaxList = new List<RecordItem>();
            this.stateList = new List<CountryWrapper>();
            for(Sales_Tax__c salesTaxObj : salesTaxList){
                this.salesTaxList.add(new RecordItem(salesTaxObj.Name__c, salesTaxObj.Id));
            }
            this.priceLevelList = new List<RecordItem>();
            for(Price_Level__c priceLevelObj : priceLevelList){
                this.priceLevelList.add(new RecordItem(priceLevelObj.Name__c, priceLevelObj.Id));
            }
            for(Country__c countryObj : countryWrapperList){
                this.countryList.add(new Country(countryObj));
            }  
            /*if(feeList.size() > 0) {
            	this.defaultEnvFeeName = feeList[0].Code__c + ((feeList[0].Description__c != null) ? (' - ' + feeList[0].Description__c) : '');
            }*/
        }
    }
    
    public class BusinessProfileMasterData{
        public List<Country> CountryList;
        public BusinessProfileWrapper BusinessProfileObj;
        
        public BusinessProfileMasterData(List<Country__c> countryWrapperList, List<Business_Profile__c> businessProfiles){  
            
            if(businessProfiles.size() > 0){
                BusinessProfileObj = new BusinessProfileWrapper(businessProfiles[0]);
            }else{
                BusinessProfileObj = new BusinessProfileWrapper(new Business_Profile__c());
            }
            
            this.countryList = new List<Country>();
            for(Country__c countryObj : countryWrapperList){
                this.countryList.add(new Country(countryObj));
            }
        }
    }
    
    
    public class BillingWrapper{
        private String IDDCode;
        private String UpgradeTime;
        private String Phone;
        private String UpgradeDate;
        public BillingWrapper(){
            
        }
    }
    
    
    public class ExportedData { 
        // Object name
        public String objectName {get; private set;}
        
        // List of attachments
        public List<AttachmentWrapper> exportedFiles {get; private set;}
        
        /**
         * Name: ExportedData
         * Desc: Constructor which takes a Accounting Data Export record and populate values
        **/
        public ExportedData(Accounting_Data_Migration__c adm, List<Attachment> attachmentList){
            objectName      = adm.Object_Name__c;
            exportedFiles   = new List<AttachmentWrapper>();
            
            for(Attachment att : attachmentList) {
                exportedFiles.add(new AttachmentWrapper(att));
            }
        }
    }
    
    public class AttachmentWrapper{
        public String Id;
        public String Name;
        public String LastModifiedDate;
        public String CreatedBy;
        public String TimePeriod; // Added by richa 1 april
        public Integer NoOfRecords; // Added by richa 1 april
        
        public AttachmentWrapper(Attachment attachObj){
            this.Id = attachObj.Id;
            this.Name = attachObj.Name;
            this.LastModifiedDate = BPUtility.getExtendedDateFormat(attachObj.LastModifiedDate); // Changed by richa 29 march
            this.CreatedBy = attachObj.CreatedBy.Name;
            if(attachObj.Description != null) {
                AttachmentDescriptionJsonWrapper attachmentDescriptionJson = (AttachmentDescriptionJsonWrapper)System.JSON.deserialize(attachObj.Description, AttachmentDescriptionJsonWrapper.class);
                Datetime start_dt;
                Datetime end_dt;
                if(attachmentDescriptionJson.StartDate != null) {
                    start_dt = datetime.newInstance(attachmentDescriptionJson.StartDate.year(), attachmentDescriptionJson.StartDate.month(), attachmentDescriptionJson.StartDate.day());
                }
                if(attachmentDescriptionJson.EndDate != null) {
                    end_dt = datetime.newInstance(attachmentDescriptionJson.EndDate.year(), attachmentDescriptionJson.EndDate.month(), attachmentDescriptionJson.EndDate.day());
                }
                this.TimePeriod = (start_dt != null && end_dt != null) ? BPUtility.getExportFormatedDateTime(start_dt) + ' through ' + BPUtility.getExportFormatedDateTime(end_dt) : '';
                this.NoOfRecords = attachmentDescriptionJson.NoOfRecords;
            }
        }
    }
    
    public class AttachmentDescriptionJsonWrapper{
        public Date StartDate;
        public Date EndDate;
        public Integer NoOfRecords;
        
        public AttachmentDescriptionJsonWrapper(Date StartDate, Date EndDate, Integer NoOfRecords){
            this.StartDate = StartDate;
            this.EndDate = EndDate;
            this.NoOfRecords = NoOfRecords == null ? 0 : NoOfRecords;
        }
    }
    
    public Static Map<String, List<String>> BUSINESS_PROFILE_FIELDS_TO_JSON_MAPPING = 
                                                                    new Map<String, List<String>>{'Business_Profile__c' => new List<String>{'id',
                                                                                                                                            'Business_Name__c',
                                                                                                                                            'Business_Phone__c',
                                                                                                                                            'Business_Email__c','Business_Street_Address1__c',
                                                                                                                                            'Business_Street_Address2__c','Business_City__c',
                                                                                                                                            'Business_Postal_Code__c',
                                                                                                                                            'Business_Country__c',
                                                                                                                                            'Business_Country__r.Name__c',
                                                                                                                                            'Business_State__c',
                                                                                                                                            'Business_State__r.Name__c',
                                                                                                                                            'Same_As_Business_Address__c',
                                                                                                                                            'Company_Name_Optional__c',
                                                                                                                                            'Shipping_Street_Address1__c',
                                                                                                                                            'Shipping_Street_Address2__c',
                                                                                                                                            'Shipping_City__c',
                                                                                                                                            'Shipping_Postal_Code__c',
                                                                                                                                            'Shipping_Country__c',
                                                                                                                                            'Shipping_State__c',
                                                                                                                                            'Formatted_Business_Number__c',
                                                                                                                                            'Customer_Invoice_Warranty_Text__c',
                                                                                                                                            'Service_Job_Warranty_Text__c',
                                                                                                                                            'Order_Deposit_Warranty_Text__c',
                                                                                                                                            'Deal_Documents_Warranty_Text__c',
                                                                                                                                            'Sales_Receipt_Warranty_Text__c',
                                                                                                                                            'Is_Signature_Line_for_Customer_Invoice__c',
                                                                                                                                            'Is_Signature_Line_for_Service_Job__c',
                                                                                                                                            'Is_Signature_Line_for_Order_Deposit__c',
                                                                                                                                            'Is_Signature_Line_for_Deal_Documents__c',
                                                                                                                                            'Is_Signature_Line_for_Sales_Receipt__c',
                                                                                                                                            'Part_Label_Template__c'}};
    
    public class RecordItem{  
        private String id;
        private String name;
        public RecordItem(String name, String id){
            this.name = name;
            this.id = id.substring(0, 15);
        }
    }
    
     
	@RemoteAction
  	global static String getUserGroupPermission(String userGroupId) {   
	  	userGroupId = BPUtility.getDecodedString(userGroupId);
	    List<User_Group__c> userGroupList = SOQLUtil.getUserGroupList(new Map<String, String>{'Id' => userGroupId});
	    UserGroupWrapper UserGroupPermissionRecord = new UserGroupWrapper(userGroupList[0]);
	    //system.assert(false, System.JSON.serialize(UserGroupPermissionRecord ));
	    return BPUtility.getEncodedString(System.JSON.serialize(UserGroupPermissionRecord ));
    
 	}
    
  	@RemoteAction
  	global static String getAllUserPermissionGroup() {   
  		List<User_Group__c> userGroupList = SOQLUtil.getAllUserGroup();
  		List<UserGroupWrapper.UserPermissionGroup> userPermissionRecList = new List<UserGroupWrapper.UserPermissionGroup>();
  		for(User_Group__c userGroupRec : userGroupList){
  			userPermissionRecList.add(new UserGroupWrapper.UserPermissionGroup(userGroupRec));
  		}
  		return BPUtility.getEncodedString(System.JSON.serialize(userPermissionRecList));
  	}
  
	@RemoteAction
  	global static String createUserGroup(String userGroupJson) { 
  		userGroupJson = BPUtility.getDecodedString(userGroupJson);
  		UserGroupWrapper.UserPermissionGroup userGroupRec = (UserGroupWrapper.UserPermissionGroup)System.JSON.deserialize(userGroupJson, UserGroupWrapper.UserPermissionGroup.class);
  	
  		List<User_Group__c> userGroupToInsert = new List<User_Group__c>();
  	
  		if(userGroupRec.CopyGroupId == null){
	  		User_Group__c usrGroupObj = new User_Group__c();
	  		usrGroupObj.Name = userGroupRec.UserGroupName;
	  		usrGroupObj.Colour_Code__c    = userGroupRec.ColorCode;
	  		userGroupToInsert.add(usrGroupObj);
  		}else{
  			String copyId = userGroupRec.CopyGroupId;
	  		Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(Constants.NAMESPACE + 'User_Group__c').getDescribe().fields.getMap();
	        Map<String, String> oppFieldAPINametoFieldTypeMap = new Map<String, String>();
	        List<String> fieldAPIList = new List<String>();
	        for(Schema.SObjectField sfield : fieldMap.Values()){
	            schema.describefieldresult dfield = sfield.getDescribe();
	            fieldAPIList.add(dfield.getname());
  		}
  	
	        String query = 'SELECT Id';
	        for(String fieldname : fieldAPIList) {
	        	if(fieldname.toLowerCase() != 'id') {
	        		query += ', ' + fieldname;
	        	}
	        }
	        query += ' FROM User_Group__c WHERE Id = :copyId';
	        List<User_Group__c> userGroupList = (List<User_Group__c>) Database.query(query);
	        
	        if(userGroupList.size() > 0){
	        	User_Group__c usrGroupObj = userGroupList[0].clone(false, true, false, false);
		  		usrGroupObj.Name = userGroupRec.UserGroupName;
		  		usrGroupObj.Colour_Code__c = userGroupRec.ColorCode;
		  		usrGroupObj.Is_System_Created__c = false;
		  		userGroupToInsert.add(usrGroupObj);
	        }
  		}
  		
  		
	  	if(userGroupToInsert.size() > 0){
	  		if(AccessControl.ifObjectFieldIsCreateable('User_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	  		insert userGroupToInsert;
	  		return userGroupToInsert[0].Id;
	  	}
	  	
  	
  		return '[]';
  	} 
  	
  	@RemoteAction
  	global static String getuserListByGroupId(String groupId) {
  		groupId = BPUtility.getDecodedString(groupId);
  		
  		List<User_To_Group__c> userTogroupJunctionList = SOQLUtil.getUserToGroupList(new Map<String, String>{'User_Group__c' => groupId});
  		List<UserGroupWrapper.UserGroupJunctionWrapper> userGroupJunctionList = new List<UserGroupWrapper.UserGroupJunctionWrapper>();
  		for(User_To_Group__c userToGroupJunctionRec : userTogroupJunctionList){
  			userGroupJunctionList.add(new UserGroupWrapper.UserGroupJunctionWrapper(userToGroupJunctionRec));
  		}
  		
  
  		return BPUtility.getEncodedString(System.JSON.serialize(userGroupJunctionList));
  		
  	}   
  	 
  	@RemoteAction
  	global static String assignUserToGroup(String usersIdList, String groupId ) {
  	
  		usersIdList = BPUtility.getDecodedString(usersIdList);
  		groupId = BPUtility.getDecodedString(groupId);
		List<String> userIdList = (List<String>)System.JSON.deserialize(usersIdList, List<String>.class);
		
  		Map<String, User_To_Group__c> userIdToUserGroupJunctionMap = new Map<String, User_To_Group__c>();
  		List<User_To_Group__c>  userTogroupList = [SELECT Id, User__c,User_Group__c from User_To_Group__c where User__c IN : userIdList ];
  		
  		List<User_To_Group__c> userJunctionListToDelete = new List<User_To_Group__c>();
  		List<User_To_Group__c> userJunctionListToInsert = new List<User_To_Group__c>();
  		
  		for(User_To_Group__c userGroupJunctionRec : userTogroupList){
  			userJunctionListToDelete.add(userGroupJunctionRec);
  		}
  		if(userJunctionListToDelete.size() > 0){
  			if(AccessControl.ifObjectIsDeletable('User_To_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
  			delete userJunctionListToDelete;
  		}
  		
  		for(String userIdRec : userIdList){
  			User_To_Group__c userToGroupRec = new User_To_Group__c();
  			userToGroupRec.User__c = userIdRec;
  			userToGroupRec.User_Group__c = groupId;
  			userJunctionListToInsert.add(userToGroupRec);
  				
  		}
  		
  		if(userJunctionListToInsert.size() > 0){
  			if(AccessControl.ifObjectFieldIsCreateable('User_To_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
  			insert userJunctionListToInsert;
  			
  		}
  		
  		return getuserListByGroupId(BPUtility.getEncodedString(groupId));
  	}
  	
  	
  	@RemoteAction
    global static String getSearchResults(String JSONString) {
    	List<User> usersList = SOQLUtil.getUserListWithGroup();
  		List<UserGroupWrapper.UserGroupJunctionWrapper> userGroupJunctionList = new List<UserGroupWrapper.UserGroupJunctionWrapper>();
  		for(User userObj : usersList){
  			userGroupJunctionList.add(new UserGroupWrapper.UserGroupJunctionWrapper(userObj));
  		}
  		return BPUtility.getEncodedString(System.JSON.serialize(userGroupJunctionList));
    }
    
    @RemoteAction
  	global static String deleteUserGroup(String groupId ) {
  		groupId = BPUtility.getDecodedString(groupId);
  		
  		User_Group__c userGroupRec = new User_Group__c();
  		userGroupRec.Id = groupId;
  		if(AccessControl.ifObjectIsDeletable('User_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
  		delete userGroupRec;
  		
  		return getAllUserPermissionGroup();
  		
    }
    
  	@RemoteAction 
  	global static String updateUserGroup(String UserGroupPermissionJson ) {
	
  		UserGroupPermissionJson = BPUtility.getDecodedString(UserGroupPermissionJson);
  		UserGroupWrapper.UserGroupPermissionList UserGroupPermissionRecord  = (UserGroupWrapper.UserGroupPermissionList)System.JSON.deserialize(UserGroupPermissionJson, UserGroupWrapper.UserGroupPermissionList.class);
		Boolean CheckSystemSetting = false; 
		String UserSettingPermission ='';
		try{  		
	  		List<User_Group__c> userGroupToUpdate = new List<User_Group__c>();
	  		User_Group__c userGroupRec = new User_Group__c();
	  		String CurrentLoggedInUser = UserInfo.getUserId();
	  		if(UserGroupPermissionRecord.UserPermissionGroupDetails.UserGroupId != null){
	  			List<User_To_Group__c>	CurrentUserGroupList = [select User_Group__c,User_Group__r.System_Settings__c from User_To_Group__c where User__c =: CurrentLoggedInUser ];
		  		for(User_To_Group__c   userGroupItem :  CurrentUserGroupList){
		  			if(userGroupItem.User_Group__c ==  UserGroupPermissionRecord.UserPermissionGroupDetails.UserGroupId){
		  				CheckSystemSetting = true;
		  				UserSettingPermission = userGroupItem.User_Group__r.System_Settings__c;
		  				break;
		  			} 
		  		}
		  		userGroupRec.Id = UserGroupPermissionRecord.UserPermissionGroupDetails.UserGroupId;
		  		userGroupRec.Name = UserGroupPermissionRecord.UserPermissionGroupDetails.UserGroupName;
		  		userGroupRec.Colour_Code__c = UserGroupPermissionRecord.UserPermissionGroupDetails.ColorCode;
		  		for(Map<String, UserGroupWrapper.Permission> systemSettingMap : UserGroupPermissionRecord.userGroupPermissions){
		  			for(String  userSetting : systemSettingMap.keySet()){
		  				if(Constants.permissionTypeToFieldAPINameMap.get(userSetting) ==  Constants.permissionTypeToFieldAPINameMap.get('System Settings') && CheckSystemSetting == true){
		  				}
		  				else{
		  					userGroupRec.put(Constants.permissionTypeToFieldAPINameMap.get(userSetting), getPermissionValues(systemSettingMap.get(userSetting).Primary, systemSettingMap.get(userSetting).Secondary));
		  				}
		  			}
		  		}
		  		userGroupToUpdate.add(userGroupRec);
	  		}
	  		//system.assert(false,userGroupRec);
	  		if(userGroupToUpdate.size() > 0){
	  			if(AccessControl.ifObjectFieldIsUpdateable('User_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	  			update userGroupToUpdate;
	  		}
		 }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
            return BPUtility.getEncodedString('Sucess');
        }
  		if(CheckSystemSetting){
  			return BPUtility.getEncodedString(UserSettingPermission);
  		}else{
  			return BPUtility.getEncodedString('Sucess');
  		}
  		//getUserGroupPermission(BPUtility.getEncodedString((UserGroupPermissionRecord.UserPermissionGroupDetails.UserGroupId)));
  	}
  	
  	
  	private static string getPermissionValues(boolean Primary , boolean Secondary){
  			String value = '';
  			if(Primary == null){
  				Primary = false;
  			}
  			if(Secondary == null){
  				Secondary = false;
  			}
  			if(!Primary  &&  !Secondary ) {
                value = 'None';
            } else if(Primary  &&  !Secondary ) {
                value = 'Primary';
            } else if(Primary  &&  Secondary ) {
                value = 'Secondary';
            }
  		return value;
  	}
  	
    /**
     * Name: getBusinessInfo
     * Desc: Method that provides data for business profile section 
       @param:  
     * @return: String - JSON String of with business profile warpper object
    **/
    @RemoteAction
    global static String getBusinessInfo(){
        List<Business_Profile__c> businessProfiles = SOQLUtil.getBusinessProfileData(new List<id>());
        if(businessProfiles.size() > 0){
        String businessInfoJson = System.JSON.serialize(new BusinessProfileWrapper(businessProfiles[0]));
        return BPUtility.getEncodedString(businessInfoJson);
        }else{
           	 Business_Profile__c businessProfileWithNoData = new Business_Profile__c();
    		String businessInfoJson = System.JSON.serialize(new BusinessProfileWrapper(businessProfileWithNoData));
            return BPUtility.getEncodedString(businessInfoJson);
        }
    }
    
    /**
     * Name: getUserPermissions
     * Desc: Method that provides data for user permissions by user id 
       @param: String groupId 
     * @return: String - JSON String of with user permissions warpper object
    **/
    @RemoteAction
    global static String getUserPermissions(String userId){
    	userId = BPUtility.getDecodedString(userId);
        String permissionStr = NewHomePageCtrl.getUserPermissions(userId);
        return BPUtility.getEncodedString(permissionStr);
    }
    
    /**
     * Name: createClockingStaff
     * Desc: Method which creates clocking Staff of the dealership
     * @param:  (1) JSONString - String - JSON String of ClockingStaffWrapperList
     * @return: None
    **/

    @RemoteAction
    global static String createClockingStaff(String clockingStaffJson){
        clockingStaffJson = BPUtility.getDecodedString(clockingStaffJson);
        ClockingStaffWrapper clockingStaffWrapperRec = (ClockingStaffWrapper)System.JSON.deserialize(clockingStaffJson,ClockingStaffWrapper.class);
        Technician__c clockingStaffObj = new Technician__c();
        clockingStaffObj.First_Name__c = clockingStaffWrapperRec.FirstName;
        clockingStaffObj.Last_Name__c = clockingStaffWrapperRec.LastName;
        clockingStaffObj.Technician_Name__c = clockingStaffObj.First_Name__c + ' ' + clockingStaffObj.Last_Name__c;
        if(clockingStaffWrapperRec.IsTechnician) {
            clockingStaffObj.Type__c = Constants.TECHNICIAN;
            clockingStaffObj.Role__c = Constants.TECHNICIAN;
            clockingStaffObj.Working_Days__c = Constants.EVERY_BUSINESS_DAY;
        } else {
            clockingStaffObj.Type__c = null;
        }
        clockingStaffObj.Active__c = true;
        if(clockingStaffWrapperRec.Id != null) {
            clockingStaffObj.Id = clockingStaffWrapperRec.Id;
            
        }
        if(clockingStaffWrapperRec.Id == null) {
            List<Technician__c> clockingStaffList = SOQLUtil.getTechnicianListByFieldName(new Map<String, String>());
            for(Technician__c staff: clockingStaffList) {
                if(clockingStaffObj.Technician_Name__c == staff.Technician_Name__c) {
                    throw new BlackPurlException('Clocking Staff already registered.');
                }
            }
        }
        
        try{
            if(AccessControl.ifObjectFieldIsCreateable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            upsert clockingStaffObj;
            List<Technician__c> newClockingStaffList = SOQLUtil.getTechnicianListByFieldName(new Map<String, String>{'Id' => clockingStaffObj.Id});
            if(newClockingStaffList.size() > 0) {
            	clockingStaffObj = newClockingStaffList[0];
            }
        }
        catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(new ClockingStaffWrapper(clockingStaffObj)));
    }
    
    /**
     * Name: editClockingStaff
     * Desc: Method which edits clocking Staff of the dealership
     * @param:  (1) JSONString - String - JSON String of ClockingStaffWrapperList
     * @return: None
    **/

    @RemoteAction
    global static String editClockingStaff(String clockingStaffJson){
        clockingStaffJson = BPUtility.getDecodedString(clockingStaffJson);
        ClockingStaffWrapper clockingStaffWrapperRec = (ClockingStaffWrapper)System.JSON.deserialize(clockingStaffJson,ClockingStaffWrapper.class);
        
        Technician__c techToUpdate = new Technician__c();
        List<User> userList = new List<User>();
        List<SObject> sObjectListToUpdate = new List<SObject>();
        techToUpdate.Id = clockingStaffWrapperRec.Id;
        techToUpdate.First_Name__c = clockingStaffWrapperRec.FirstName;
        techToUpdate.Last_Name__c = clockingStaffWrapperRec.LastName;
        techToUpdate.Technician_Name__c = techToUpdate.First_Name__c + ' ' + techToUpdate.Last_Name__c;
        if(clockingStaffWrapperRec.IsTechnician) {
            techToUpdate.Type__c = Constants.TECHNICIAN;
            techToUpdate.Role__c = Constants.TECHNICIAN;
        	techToUpdate.Working_Days__c = Constants.EVERY_BUSINESS_DAY;
        } else {
            techToUpdate.Type__c = null;
        }
        sObjectListToUpdate.add(techToUpdate);
        
        List<Id> techToEditIdList = new List<Id>{clockingStaffWrapperRec.Id};
        List<Technician__c> otherTechnicianList = [Select Id, Technician_Name__c from Technician__c where Id NOT IN : techToEditIdList AND Active__c = true];
        for(Technician__c staff: otherTechnicianList) {
            if(techToUpdate.Technician_Name__c == staff.Technician_Name__c) {
                throw new BlackPurlException('Clocking Staff with this name already exists.');
            }
        }
        
        if(clockingStaffWrapperRec.Id != null) {
            List<Technician__c> techList = [Select Id, User__c from Technician__c where Id = :clockingStaffWrapperRec.Id];
            if(techList.size() > 0) {
            	if(techList[0].User__c != null) {
	                userList = [Select Id, Name from User where Id = :techList[0].User__c];
	            }
            }
        }
        
        if(userList.size() > 0) {
            userList[0].FirstName = clockingStaffWrapperRec.FirstName;
            userList[0].LastName = clockingStaffWrapperRec.LastName;
            //String usrname = clockingStaffWrapperRec.FirstName + ' ' + clockingStaffWrapperRec.LastName;
            /*if(clockingStaffWrapperRec.FirstName.length() > 6){
                userList[0].Alias = clockingStaffWrapperRec.FirstName.substring(0,6);
            }
            else{
                userList[0].Alias = clockingStaffWrapperRec.FirstName;
            }
            userList[0].CommunityNickname = (usrname.substring(0,3) + Math.random()).substring(0,8);*/
            sObjectListToUpdate.add(userList[0]);
        }
        try{
            if(AccessControl.ifObjectFieldIsUpdateable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('User') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update sObjectListToUpdate;
            List<Technician__c> newClockingStaffList = SOQLUtil.getTechnicianListByFieldName(new Map<String, String>{'Id' => techToUpdate.Id});
            if(newClockingStaffList.size() > 0) {
            	techToUpdate = newClockingStaffList[0];
            }
        }
        catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        //return getAllClockingStaff();
        return BPUtility.getEncodedString(System.JSON.serialize(new ClockingStaffWrapper(techToUpdate)));
    }
    
    /**
     * Name: getAllClockingStaff
     * Desc: Method which gives  List of Clocking Staff
       @param:    
     * @return: String - JSON String of list of Clocking Staff
    **/
    @RemoteAction
    global static String getAllClockingStaff(){
        if(AccessControl.ifObjectFieldIsAccessible('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Technician__c> clockingStaffList = SOQLUtil.getTechnicianListByFieldName(new Map<String, String>()); //[Select Id, First_Name__c, Last_Name__c, Technician_Name__c, Type__c from Technician__c where Active__c = true];
        List<ClockingStaffWrapper> clockingStaffWrapperList = new List<ClockingStaffWrapper>();
        for(Technician__c clockingStaffRecord : clockingStaffList){
            ClockingStaffWrapper clockingStaffWrapperRecord = new ClockingStaffWrapper(clockingStaffRecord);
            clockingStaffWrapperList.add(clockingStaffWrapperRecord);
        }
        return BPUtility.getEncodedString(System.JSON.serialize(clockingStaffWrapperList));
    }
    
    /**
     * Name: deleteClockingStaff
     * Desc: Method which delete a Clocking Staff
       @param:    
     * @return: String - Id of Clocking Staff to be deleted
    **/
    @RemoteAction
    global static String deleteClockingStaff(String clockingStaffId) {
        clockingStaffId = BPUtility.getDecodedString(clockingStaffId);
        
        Technician__c clockingStaff = new Technician__c();
        clockingStaff.Id = clockingStaffId;
        String query;    
        query = 'SELECT ';  
        for(String fieldsName : SOHeaderWrapper.getHoursLoggedFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
         
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Hours_Logged__c WHERE Technician__c =: clockingStaffId ';
        if(AccessControl.ifObjectFieldIsAccessible('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Hours_Logged__c> hoursLoggedList = Database.query(query);
        Boolean isCurrentlyClocked = false;
        Boolean isPreviouslyClocked = false;
        Boolean isAssigedButNotClocked = false;
        if(hoursLoggedList.size() == 0) {
            // delete
            if(AccessControl.ifObjectIsDeletable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete clockingStaff;
        } else if(hoursLoggedList.size() > 0) {
        	Hours_Logged__c hoursLoggedToDel = new Hours_Logged__c();
            for(Hours_Logged__c hrsLogged: hoursLoggedList) {
                if(!isCurrentlyClocked && hrsLogged.Start_Date_Time__c != null && hrsLogged.End_Date_Time__c == null) {
                    isCurrentlyClocked = true;
                    //throw new BlackPurlException('Technician is currently clocked on some service job');
                }
                if(!isPreviouslyClocked && hrsLogged.Start_Date_Time__c != null && hrsLogged.End_Date_Time__c != null) {
                    isPreviouslyClocked = true;
                }
                
                if(!isAssigedButNotClocked && hrsLogged.Start_Date_Time__c == null && hrsLogged.End_Date_Time__c == null) {
                    isAssigedButNotClocked = true;
                    hoursLoggedToDel = hrsLogged;
                }
            }
            
            if(isCurrentlyClocked) {
                throw new BlackPurlException('Technician is currently clocked on some service job');
            } else if(isPreviouslyClocked) {
                clockingStaff.Active__c = false;
                if(AccessControl.ifObjectFieldIsUpdateable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update clockingStaff;
                
            } else if(isAssigedButNotClocked) {
                if(AccessControl.ifObjectIsDeletable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                delete clockingStaff;
                
                delete hoursLoggedToDel;
                
            } else {
                if(AccessControl.ifObjectIsDeletable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                delete clockingStaff;
            }
        }
        
        
        return getAllClockingStaff();
        
    }
  	
    @RemoteAction
    public static List<CategoryService.CategoryWrapper> getTaxCategoryList() {
    	try {
	        return CategoryService.getFilteredCategoryWrapperList(new Map<String, String>{'Type__c' => 'Tax'});
    	} catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    } 
    /** Method to get data of all account type present in appication
    * CtrlClass -AccountTypeCtrl
    * @Return - String(Json containing all account type data)
    */
    @RemoteAction
    public static String getAllAccountTypeData() {
    	//try {
	        return BPUtility.getEncodedString(system.JSON.serialize(AccountTypeService.getAllAccountTypeData()));
    	/*} catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }*/
    }
    
    @RemoteAction
    public static String getAllActiveSalesTax() { 
    	try {
	        return BPUtility.getEncodedString(system.JSON.serialize(AccountTypeService.getAllActiveSalesTax()));
    	} catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    public static String saveAccountType(String accountTypeJsonStr) { 
		try {
    		accountTypeJsonStr  = BPUtility.getDecodedString(accountTypeJsonStr);
			return BPUtility.getEncodedString(system.JSON.serialize(AccountTypeService.addEditAccountType(accountTypeJsonStr)));
		} catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    } 
    
    @RemoteAction
    public static String getRecForAccountType(String accTypeId) { 
    	try { 
    		accTypeId  = BPUtility.getDecodedString(accTypeId);
	        return BPUtility.getEncodedString(system.JSON.serialize(AccountTypeService.getRecForAccountType(accTypeId)));
    	} catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    } 
    public class ClockingStaffWrapper{
        private String FirstName;
        private String LastName;
        private Boolean IsTechnician;
        private String Id;
        private String createdDate;
        private String lastModifiedDate;
        private Boolean isLicensedUser;
        private String TechnicianName;
        
        public ClockingStaffWrapper(Technician__c staffRecord){
            this.FirstName = staffRecord.First_Name__c;
            this.LastName = staffRecord.Last_Name__c;
            if(staffRecord.Type__c == Constants.TECHNICIAN) {
                this.IsTechnician = true;
            } else {
                this.IsTechnician = false;
            }
            this.Id = staffRecord.Id; 
            this.TechnicianName = staffRecord.Technician_Name__c;
            String userLocale = UserInfo.getLocale();
            this.createdDate = staffRecord.CreatedDate != null ? staffRecord.CreatedDate.format(Constants.localeToDateTimeFmtMap.get(userLocale)) : null;
            this.lastModifiedDate = staffRecord.LastModifiedDate != null ? staffRecord.LastModifiedDate.format(Constants.localeToDateTimeFmtMap.get(userLocale)) : null;
            this.isLicensedUser = staffRecord.User__c != null ? true : false;
            
        }
    }
}