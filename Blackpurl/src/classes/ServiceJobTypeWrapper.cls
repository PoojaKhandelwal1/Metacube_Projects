public without sharing class ServiceJobTypeWrapper {
    
    public String Id;
    public String Name;
    public String Type;
    public String PartCategoryId;
    public String PartCategory;
    public String LabourCategoryId;
    public String LabourCategory;
    public String InternalCategoryId;
    public String InternalCategory;
    public String ProviderId;
    public String Provider;
    public Boolean IsActive;
    public Boolean IsDefault;
    
    public ServiceJobTypeWrapper(Transaction_Type__c ttRec) {
    	this.Id = ttRec.Id;
    	this.Name = ttRec.Code_Label__c;
    	this.Type = ttRec.Type__c;
    	this.PartCategoryId = ttRec.Part_Category__c;
    	this.PartCategory = (ttRec.Part_Category__c != null) ? ttRec.Part_Category__r.Name : ServiceJobTypeService.DEFAULT_CATEGORY;
    	this.LabourCategoryId = ttRec.Labour_Category__c;
    	this.LabourCategory = (ttRec.Labour_Category__c != null) ? ttRec.Labour_Category__r.Name : ServiceJobTypeService.DEFAULT_CATEGORY;
    	this.InternalCategoryId = ttRec.Internal_Category__c;
    	if(this.Type == Constants.CHECKOUT_TYPE_INTERNAL) {
    		this.InternalCategory = (ttRec.Internal_Category__c != null) ? ttRec.Internal_Category__r.Name : ServiceJobTypeService.DEFAULT_CATEGORY;
    	}
    	this.ProviderId = ttRec.Third_Party_Customer__c;
    	if(this.Type == Constants.CHECKOUT_TYPE_THIRD_PARTY) {
    		this.Provider = (ttRec.Third_Party_Customer__c != null) ? ttRec.Third_Party_Customer__r.Name : ServiceJobTypeService.DEFAULT_CATEGORY;
    	}
    	this.IsActive = ttRec.Active__c;
    	this.IsDefault = ttRec.Default__c;
    	
    }
    
    public static List<String> getTransactionTypeFieldsList(){
        return new List<String>{ 'Code_Label__c',
                                'Type__c',
                                'Part_Category__c',
                                'Part_Category__r.Name',
                                'Labour_Category__c',
                                'Labour_Category__r.Name',
                                'Internal_Category__c',
                                'Internal_Category__r.Name',
                                'Third_Party_Customer__c',
                                'Third_Party_Customer__r.Name',
                                'Active__c',
                                'Default__c'
                            };
    }
}