public without sharing class ServiceJobTypeService {
    
    public static final String DEFAULT_CATEGORY = 'Default';
    
    public static JobTypeMasterDataWrapper getMasterDataForServiceJobType() {
    	List<Category__c> partCategories = new List<Category__c>();
    	List<Category__c> labourCategories = new List<Category__c>();
    	List<Category__c> internalCategories = new List<Category__c>();
	   	Set<String> categoryTypeSet = new Set<String>{'Part', 'Labour', 'Internal Expense'};
	   	List<Category__c> categories = Database.query('SELECT Id, Name, Active__c, Type__c, Default__c FROM Category__c WHERE Active__c = true AND Type__c IN: categoryTypeSet'); 
	   	for(Category__c categoryRec : categories) {
	   		if(categoryRec.Type__c == 'Part') {
	   			partCategories.add(categoryRec);
	   		} else if(categoryRec.Type__c == 'Labour') {
	   			labourCategories.add(categoryRec);
	   		} else if(categoryRec.Type__c == 'Internal Expense') {
	   			internalCategories.add(categoryRec);
	   		}
	   	}
	   	List<Account> providers = SOQLUtil.getProviderList();
	   	
    	JobTypeMasterDataWrapper masterData = new JobTypeMasterDataWrapper(partCategories, labourCategories, internalCategories, providers);
    	return masterData;
    }
    
    public static List<ServiceJobTypeWrapper> getAllServiceJobTypes() {
    	List<Transaction_Type__c> transactionTypeList = (List<Transaction_Type__c>)SOQLUtil.getTransactionTypes(new List<Id>());
    	transactionTypeList = sortJobTypes(transactionTypeList);
    	List<ServiceJobTypeWrapper> ttWrapperList = new List<ServiceJobTypeWrapper>();
    	for(Transaction_Type__c ttRec :transactionTypeList) {
    		if(ttRec.Type__c != 'Quote') {
    			ttWrapperList.add(new ServiceJobTypeWrapper(ttRec));
    		}
    	}
    	return ttWrapperList;
    }
    
    public static String saveJobType(String ttListJSON) {
    	List<ServiceJobTypeWrapper> ttObjList = (List<ServiceJobTypeWrapper>) System.JSON.deserialize(ttListJSON, List<ServiceJobTypeWrapper>.class);
    	List<Transaction_Type__c> transactionTypeList = setTransactionTypeFields(ttObjList);
    	upsert transactionTypeList;
    	return 'Success';
    }
    
    public static List<Transaction_Type__c> sortJobTypes(List<Transaction_Type__c> jobTypes) {
    	Map<String, Map<String, Transaction_Type__c>> transactionTypeToJobTypeListMap = new Map<String, Map<String, Transaction_Type__c>>();
    	for(Transaction_Type__c ttRec : jobTypes) {
			if(!transactionTypeToJobTypeListMap.containskey(ttRec.Type__c)) {
    			transactionTypeToJobTypeListMap.put(ttRec.Type__c, new Map<String, Transaction_Type__c>());
    		}
    		transactionTypeToJobTypeListMap.get(ttRec.Type__c).put(ttRec.Code_Label__c.toUpperCase(), ttRec);
    	}
    	
    	List<Transaction_Type__c> sortedTTList = new List<Transaction_Type__c>();
    	List<String> jobTypeSortingBaseList = new List<String>{'Customer', 'Third-Party', 'Internal', 'Deal Service', 'Stock Unit', 'Quote'};
    	List<String> jobTypesNameList;
    	for(String transactionType : jobTypeSortingBaseList) {
    		if(transactionTypeToJobTypeListMap.containsKey(transactionType)) {
	    		(jobTypesNameList = new List<String>(transactionTypeToJobTypeListMap.get(transactionType).keySet())).sort();
	    		for(String jobTypeName : jobTypesNameList) {
	    			sortedTTList.add(transactionTypeToJobTypeListMap.get(transactionType).get(jobTypeName));
	    		}
	    	}
    	}
    	return sortedTTList;
    }
    
    private static List<Transaction_Type__c> setTransactionTypeFields(List<ServiceJobTypeWrapper> ttObjList) {
    	List<Transaction_Type__c> transactionTypeList = new List<Transaction_Type__c>();
    	for(ServiceJobTypeWrapper ttObj : ttObjList) {
    		if(String.isNotBlank(ttObj.Type) && String.isNotBlank(ttObj.Name)) {
    			Transaction_Type__c ttRec = new Transaction_Type__c(Id = ttObj.Id);
	    		ttRec.Type__c = ttObj.Type;
	    		ttRec.Code_Label__c = ttObj.Name;
	    		ttRec.Active__c = ttObj.IsActive;
	    		ttRec.Default__c = ttObj.IsDefault;
	    		ttRec.Part_Category__c = ttObj.PartCategoryId;
	    		ttRec.Labour_Category__c = ttObj.LabourCategoryId;
	    		ttRec.Internal_Category__c = ttObj.InternalCategoryId;
	    		ttRec.Third_Party_Customer__c = ttObj.ProviderId;
	    		transactionTypeList.add(ttRec);
    		}
    	}
    	return transactionTypeList;
    }
    
    public class JobTypeMasterDataWrapper {
    	public List<String> TransactionTypeList;
    	public List<Category> PartCategoryList;
    	public List<Category> LabourCategoryList;
    	public List<Category> InternalCategoryList;
    	public List<SOHeaderWrapper.VendorAsProvider> ProviderList;
    	
    	public JobTypeMasterDataWrapper(List<Category__c> partCategories, List<Category__c> labourCategories, List<Category__c> internalCategories, List<Account> providers) {
    		this.TransactionTypeList = new List<String>{'Customer', 'Third-Party', 'Internal'};
    		this.PartCategoryList = new List<Category>();
    		for(Category__c categoryRec : partCategories) {
    			PartCategoryList.add(new Category(categoryRec));
    		}
    		this.LabourCategoryList = new List<Category>();
    		for(Category__c categoryRec : labourCategories) {
    			LabourCategoryList.add(new Category(categoryRec));
    		}
    		this.InternalCategoryList = new List<Category>();
    		for(Category__c categoryRec : internalCategories) {
    			InternalCategoryList.add(new Category(categoryRec));
    		}
    		this.ProviderList = new List<SOHeaderWrapper.VendorAsProvider>();
    		for(Account accRec : providers) {
    			ProviderList.add(new SOHeaderWrapper.VendorAsProvider(accRec));
    		}
    	}
    }
}