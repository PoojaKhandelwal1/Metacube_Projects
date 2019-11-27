/** 
* Author: Rajat Jain
* Since: Oct 7, 2018 
* Name: AccountTypeCtrl 
* Description: Apex class which contains all methods related to Account Type.
**/
global with sharing class AccountTypeBatch implements Database.Batchable<sobject>, Database.Stateful {
    
   	public Integer customerCount = 1;
   	public Integer vendorCount = 1;
   	public static final String RETAIL_CUSTOMER = 'Retail Customer';
   	public static final String SUPPLIER = 'Supplier';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        String baseQuery = 'SELECT Name, Is_Customer__c, Is_Vendor__c, (SELECT Name, Sales_Tax_Item__r.Name__c FROM Tax_Exemptions__r) FROM Account';
        return Database.getQueryLocator(baseQuery); 
    }

    global void execute(Database.batchableContext bc, List<Account> accountList) {
    	if(accountList.size() > 0) {
    		List<Account> accHavingTaxExemptionList = new List<Account>();
   			List<Account> accHavingNoTaxExemptionList = new List<Account>();
   			String supplierAccTypeId;
			String customerAccTypeId;
			
			List<Account_Type__c> defaultAccountTypeList = [SELECT Id, Name, Applies_To__c FROM Account_Type__c WHERE Name =: RETAIL_CUSTOMER OR Name =: SUPPLIER];
			for(Account_Type__c accTypeRec : defaultAccountTypeList) {
				if(accTypeRec.Name == RETAIL_CUSTOMER) {
					customerAccTypeId = accTypeRec.Id;
				} else {
					supplierAccTypeId = accTypeRec.Id;
				}
			}
    		for(Account accRec : accountList) {
    			if(accRec.Tax_Exemptions__r.size() == 0) {
    				//accRec.Account_Type__c = (accRec.Is_Vendor__c ? supplierAccTypeId : customerAccTypeId);
    				if(accRec.Is_Vendor__c) {
    					accRec.Vendor_Account_Type__c = supplierAccTypeId;
    				}
    				if(accRec.Is_Customer__c) {
    					accRec.Account_Type__c = customerAccTypeId;
    				}
    				accHavingNoTaxExemptionList.add(accRec);
    			} else {
    				accHavingTaxExemptionList.add(accRec);
    			}
    		}
    		if(accHavingNoTaxExemptionList.size() > 0) {
    			update accHavingNoTaxExemptionList;
    		}
			 
    		updateAccountWithNewOrExistingAccountType(accHavingTaxExemptionList);
    	}
    }  
 	
    private void updateAccountWithNewOrExistingAccountType(List<Account> accountList) {
		List<Account_Type__c> accTypeList = [SELECT Name, (SELECT Name, Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c FROM Tax_Exemptions__r) FROM Account_Type__c
											limit: SOQLUtil.getAvailableQueryRowsLimit()];
		updateInsertAccountAndAccountTypes(accTypeList, accountList);
    }
    
    private void updateInsertAccountAndAccountTypes(List<Account_Type__c> accTypeList, List<Account> accountList) {
    	
    	Map<String, String> salesTaxItemToAccTypeIdMap = new Map<String, String>();
		List<String> salesTaxNameList;
		Map<String, String> accountIdToAccountTypeIdListToBeUpdatedMap = new Map<String, String>();
		Map<String, List<Account>> salesTaxNameToAccountListMap = new Map<String, List<Account>>();
   		Map<String, Account_Type__c> salesTaxNameToNewAccountTypeToInsertMap = new Map<String, Account_Type__c>();
   		
		for(Account_Type__c accTypeRec : accTypeList) {
   			salesTaxNameList = new List<String>();
   			for(Tax_Exemption__c taxExemptionRec : accTypeRec.Tax_Exemptions__r) {
			    salesTaxNameList.add(taxExemptionRec.Sales_Tax_Item__r.Name__c);
			}
			salesTaxNameList.sort();
			salesTaxItemToAccTypeIdMap.put(String.join(salesTaxNameList, ','), accTypeRec.Id);
   		}
    	String salesTaxPresentOnAccountRec;
    	List<Account> accountsToBeUpdated = new List<Account>();
    	for(Account accRec : accountList) {
    		salesTaxNameList = new List<String>();
	   		for(Tax_Exemption__c taxExemptionRec : accRec.Tax_Exemptions__r) {
	   			if(String.isNotBlank(taxExemptionRec.Sales_Tax_Item__r.Name__c)) {
	   				salesTaxNameList.add(taxExemptionRec.Sales_Tax_Item__r.Name__c);
	   			}
			}
			salesTaxNameList.sort();
			salesTaxPresentOnAccountRec = String.join(salesTaxNameList,',');
			
			if(salesTaxItemToAccTypeIdMap.containsKey(salesTaxPresentOnAccountRec)) {
				if(accRec.Is_Vendor__c) {
					accRec.Vendor_Account_Type__c = salesTaxItemToAccTypeIdMap.get(salesTaxPresentOnAccountRec);
				}
				if(accRec.Is_Customer__c) {
					accRec.Account_Type__c = salesTaxItemToAccTypeIdMap.get(salesTaxPresentOnAccountRec);
				}
				//accRec.Account_Type__c = salesTaxItemToAccTypeIdMap.get(salesTaxPresentOnAccountRec);
				accountsToBeUpdated.add(accRec);
			} else {
				if(!salesTaxNameToNewAccountTypeToInsertMap.containsKey(salesTaxPresentOnAccountRec)) {
					Account_Type__c accType = createNewAccountType(accRec);
					salesTaxNameToNewAccountTypeToInsertMap.put(salesTaxPresentOnAccountRec, accType);
				}
				if(salesTaxNameToAccountListMap.containsKey(salesTaxPresentOnAccountRec)) {
					salesTaxNameToAccountListMap.get(salesTaxPresentOnAccountRec).add(accRec);
				} else {
					salesTaxNameToAccountListMap.put(salesTaxPresentOnAccountRec, new List<Account>{accRec});
				}
			}
    	}
    	insert salesTaxNameToNewAccountTypeToInsertMap.values();
    	
    	accountsToBeUpdated.addAll(updateAccountTypesAndInsertTaxExemptions(salesTaxNameToNewAccountTypeToInsertMap, salesTaxNameToAccountListMap));
		update accountsToBeUpdated;
	}
    
    private List<Account> updateAccountTypesAndInsertTaxExemptions(Map<String, Account_Type__c> salesTaxNameToNewAccountTypeToInsertMap,Map<String, List<Account>> salesTaxNameToAccountListMap) {
    	List<Account> accountsToBeUpdated = new List<Account>();
    	List<Tax_Exemption__c> taxExemptionListToUpdate = new List<Tax_Exemption__c>();
    	//Update Tax exemption (Customer to Account Type)
    	for(String salesTaxNameRec : salesTaxNameToAccountListMap.keySet()) {
    		if(salesTaxNameToNewAccountTypeToInsertMap.containsKey(salesTaxNameRec)) {
    			if(salesTaxNameToAccountListMap.get(salesTaxNameRec)[0].Tax_Exemptions__r.size() > 0) {
	    			for(Tax_Exemption__c taxExemptionRec : salesTaxNameToAccountListMap.get(salesTaxNameRec)[0].Tax_Exemptions__r) {
						taxExemptionRec.Account_Type__c = salesTaxNameToNewAccountTypeToInsertMap.get(salesTaxNameRec).Id;
						taxExemptionListToUpdate.add(taxExemptionRec);
					}
    			}
    			for(Account accRec : salesTaxNameToAccountListMap.get(salesTaxNameRec)) {
					//accRec.Account_Type__c = salesTaxNameToNewAccountTypeToInsertMap.get(salesTaxNameRec).Id;
					if(accRec.Is_Vendor__c) {
						accRec.Vendor_Account_Type__c = salesTaxNameToNewAccountTypeToInsertMap.get(salesTaxNameRec).Id;
					}
					if(accRec.Is_Customer__c) {
						accRec.Account_Type__c = salesTaxNameToNewAccountTypeToInsertMap.get(salesTaxNameRec).Id;
					}
					accountsToBeUpdated.add(accRec);
					
				}
    		}
    	}
    	update taxExemptionListToUpdate;
    	return accountsToBeUpdated; 
    }
    
    private Account_Type__c createNewAccountType(Account accRec) {
    	Account_Type__c accTypeRec = new Account_Type__c(Active__c = true);
		if(accRec.Is_Customer__c) {
			accTypeRec.Name = 'Customer' + getTrailingZeros(9, customerCount);
			customerCount++;
		} else {
			accTypeRec.Name = 'Supplier' + getTrailingZeros(9, vendorCount);
			vendorCount++;
		}
		
		return accTypeRec;
    }
     
    private String getTrailingZeros(Integer maxValue, Integer counter) {
    	return (counter > maxValue ? String.valueOf(counter) : '0' + counter);
    }
    global void finish(Database.batchableContext bc) {
    	emptyTaxExemptionReferenceOnCustomer();
    }
    
    private void emptyTaxExemptionReferenceOnCustomer() {
    	List<Tax_Exemption__c> taxExemptionList = [Select Id,Customer__c from Tax_Exemption__c where Customer__c != null];
		for(Tax_Exemption__c taxRec : taxExemptionList) {
			taxRec.Customer__c = null;
		}
		update taxExemptionList;
    }
}