global with sharing class AddeditCategoryCtrl {
    
    global AddeditCategoryCtrl (NewHomePageCtrl controller){}
    public AddeditCategoryCtrl() {} 
    
    
    @remoteAction 
    global static String getCategoryMasterData() {
    	Accounting_Settings__c accConfig = Accounting_Settings__c.getOrgDefaults(); 
    	QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
    	Accounting_Default_Accounts__c accDefaultAccount = Accounting_Default_Accounts__c.getOrgDefaults();
    	List<General_Account__c> existingGeneralAccountList = [select Id, Accounting_Id__c, Account_Name__c,
    															Account_Type__c, LastModifiedDate, Account_Number__c
    															 from General_Account__c WHERE Is_Active__c = true 
    															 order by Account_Name__c ASC LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
    	AccountingSettingWrapper accWrap = new AccountingSettingWrapper(accConfig, qbConfig, 
    																	existingGeneralAccountList, accDefaultAccount);
        return BPUtility.getEncodedString(System.JSON.serialize(accWrap));  
    }
    
    @remoteAction 
    global static String getCategoryDetails() {
        List<Category__c> categoryList = SOQLUtil.getAllCategoryDetails();
        if(categoryList.size() == 0) {
            return BPUtility.getEncodedString('{}');
        }
        List<CategoryWrapper> CategoryObjList = new List<CategoryWrapper>();
        for(Category__c categoryRec : categoryList) {
            CategoryObjList.add(new CategoryWrapper(categoryRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(CategoryObjList));
    }
    
    @remoteAction 
    global static String saveCategoryData(String categoryJSON){
    	categoryJSON = BPUtility.getDecodedString(categoryJSON);
    	CategoryWrapper cw = (CategoryWrapper)System.JSON.deserialize(categoryJSON, CategoryWrapper.class);
    	Category__c categoryObj = new Category__c();
    	String response = '';
    	try{
    		if(String.isNotBlank(cw.Id)){
	    		categoryObj.Id = cw.Id;
	    	}
	    	categoryObj.Type__c = cw.Type;
	    	categoryObj.Name = cw.CategoryName;
	    	categoryObj.Description__c = cw.CategoryName;
	    	categoryObj.Active__c = cw.IsActive;
	    	categoryObj.Default__c = cw.IsDefault;
	    	categoryObj.COGS_GL__c = cw.COGSGL;
	    	categoryObj.Income_GL__c = cw.IncomeGL;
	    	categoryObj.Inventory_GL__c = cw.InventoryGL; 
    		upsert categoryObj;
    		response = 'success';
    	}catch(Exception e){
    		if(e.getMessage().contains('duplicate')){
    			response = 'Duplicate Category Type and Name';
    		}else if(e.getMessage().contains('You can\'t make inactive category as default')){
    			response = 'You can\'t make inactive Category as default';
    		}
    		// START: added by kajal 15th june 2017 #2328
    		else if(e.getMessage().contains('You can\'t deselect of a default category')){
    			response = 'You can\'t deselect of a default category';
    		}
    		// END: added by kajal 15th june 2017 #2328
    		else{
    			response = e.getMessage();
    		}
    	}
    	return BPUtility.getEncodedString(response);
    }
}