/** 
* Author: Rajat Jain
* Since: Oct 7, 2018 
* Name: AccountTypeService 
* Description: Apex class which contains all methods related to Account Type.
**/
public with sharing class AccountTypeService { 
	/** Method to get data of all account type present in appication
    * CtrlClass -AccountTypeCtrl
    * @Return - list of account type wrapper(Json containing all account type data)
    */
    public static List<AccountTypeWrapper> getAllAccountTypeData() {
    	if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Account_Type__c> accountTypeList = AccountTypeSOQLUtil.getAccountType(new Map<String, String>());
    	return populateAccountTypeWrapperData(accountTypeList);
    }
    
    /** Method to get data of all account type present in appication
    * CtrlClass -AccountTypeCtrl
    * @Return - list of account type wrapper(Json containing all account type data)
    */
    public static List<AccountTypeWrapper> getAllAccountTypeForCustomer() {
    	if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Account_Type__c> accountTypeList = AccountTypeSOQLUtil.getAccountType(new Map<String,String>{'Applies_To__c' => 'Customers', 'Active__c' => 'true'});
    	return populateAccountTypeWrapperData(accountTypeList);
    }
    
    /** Method to get data of all account type present in appication
    * CtrlClass -AccountTypeCtrl
    * @Return - list of account type wrapper(Json containing all account type data)
    */
    public static List<AccountTypeWrapper> getAllAccountTypeForVendor() {
    	if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Account_Type__c> accountTypeList = AccountTypeSOQLUtil.getAccountType(new Map<String,String>{'Applies_To__c' => 'Vendors', 'Active__c' => 'true'});
    	return populateAccountTypeWrapperData(accountTypeList);
    }
    
    /** Method to populate account type wrapper list with account type obj data
    * CtrlClass -AccountTypeCtrl
    * @Return - list of account type wrapper(Json containing all account type data)
    */
    
    private static List<AccountTypeWrapper> populateAccountTypeWrapperData(List<Account_Type__c> accountTypeList) {
    	List<AccountTypeWrapper> accountsData = new List<AccountTypeWrapper>();
    	if(accountTypeList.size() > 0) {
    		for(Account_Type__c accTypeRec : accountTypeList) {
    			accountsData.add(new AccountTypeWrapper(accTypeRec));
    		}
    	} 
    	return accountsData;
    }
    /** Method to get data of all Active Sales Tax i.e invoked when new record is about to be created
    * CtrlClass -AccountTypeCtrl
    * @Return - list of tax exemptions(Json containing all sales tax data)
    */
    
    public static List<TaxExemptions> getAllActiveSalesTax() {
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Sales_Tax_Item__c> salesTaxItemList = AccountTypeSOQLUtil.getAllSalesTaxItemWithExemptions();
        List<TaxExemptions> taxExemptionsList = new List<TaxExemptions>();  
        Map<Id, List<String>> salesTaxItemIdToAppliesToList = getAppliesToList(salesTaxItemList);
        
        for(Sales_Tax_Item__c salesTaxItemRec : salesTaxItemList) {
            taxExemptionsList.add(new TaxExemptions(salesTaxItemRec, salesTaxItemIdToAppliesToList.get(salesTaxItemRec.Id), 'Account type'));
        }
        return taxExemptionsList;
    }
    
    /** Method to get data of all AppliesToList
    * CtrlClass -AccountTypeCtrl
    * @Return - Map<Id, List<String>>
    */
    
    private static Map<Id, List<String>> getAppliesToList(List<Sales_Tax_Item__c> salesTaxItemList) {
        Set<Id> salesTaxItemIdSet = new Set<Id>();
        for(Sales_Tax_Item__c salesTaxItemRec : salesTaxItemList) {
            salesTaxItemIdSet.add(salesTaxItemRec.Id);
        }
        
        if(salesTaxItemIdSet.size() == 0) {
            return new Map<Id, List<String>>();
        }
        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<Id, List<String>> salesTaxItemIdToAppliesToList = new Map<Id, List<String>>(); 
        List<Applicable_Taxes__c> appTaxList = [select Sales_Tax_Item__c, Sales_Tax__c, Sales_Tax__r.Name__c from Applicable_Taxes__c
                                                    where Sales_Tax_Item__c IN: salesTaxItemIdSet];
        
        for(Applicable_Taxes__c appTaxRec : appTaxList) {
            if(appTaxRec.Sales_Tax__c != null) {
                List<String> appliesToList;
                if(!salesTaxItemIdToAppliesToList.containsKey(appTaxRec.Sales_Tax_Item__c)) {
                    salesTaxItemIdToAppliesToList.put(appTaxRec.Sales_Tax_Item__c, new List<String>());
                }
                salesTaxItemIdToAppliesToList.get(appTaxRec.Sales_Tax_Item__c).add(appTaxRec.Sales_Tax__r.Name__c);
            }
        }
        return salesTaxItemIdToAppliesToList;
    }
    
    /** Method to save new Account Type i.e new record insertion
    * CtrlClass -AccountTypeCtrl
    * @Return - String ->Id of newly created account type
    */
    
    public static String addEditAccountType(String accountTypeJsonStr) { 
    	if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectIsUpdateable('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	AccountTypeWrapper rec = (AccountTypeWrapper)JSON.deserialize(accountTypeJsonStr, AccountTypeWrapper.class);
    	if(rec.IsDefault) {
    		validateIsDefaultRecType(rec);
    	}
		
		Account_Type__c accTypeObj = new Account_Type__c();
		accTypeObj.Id = rec.Id;
		accTypeObj.Name = rec.AccountType;
		accTypeObj.Applies_To__c = rec.AppliesTo;
		accTypeObj.Default__c = rec.IsDefault != null ? rec.IsDefault : false;
		accTypeObj.Active__c = rec.IsActive != null ? rec.IsActive : false;
		upsert accTypeObj;
		
		if(String.isBlank(rec.Id)) {
			saveTaxExeptionList(accTypeObj.Id, rec.TaxExemptionsList);
		} else {
			return updateTaxExeptionList(accTypeObj.Id, rec.TaxExemptionsList);
		}
		return accTypeObj.Id;
    }
    private static void validateIsDefaultRecType(AccountTypeWrapper rec) {
    	Account_Type__c accTypeObj = [Select Id,Default__c from Account_Type__c where Default__c = true And Applies_To__c =: rec.AppliesTo];
    	if(accTypeObj.Id != rec.Id ) {
    		accTypeObj.Default__c = false;
    		update accTypeObj;
    	}
    }
    
    /** Method to populate tax exemption on account type in case of insertion of new record
    * CtrlClass -AccountTypeCtrl
    * @Return 
    */
    
    private static void saveTaxExeptionList(String accTypeObjId, List<TaxExemptions> taxExemptionObjList) {
        if(AccessControl.ifObjectFieldIsCreateable('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        
        List<Tax_Exemption__c> taxExemptionListToInsert = new List<Tax_Exemption__c>();
        for(TaxExemptions taxExemptionObj : taxExemptionObjList) {
            Tax_Exemption__c taxExemptionRec = new Tax_Exemption__c();
            if(taxExemptionObj.IsSelected && taxExemptionObj.SalesTaxItemId != null) {
                taxExemptionRec.Account_Type__c = accTypeObjId;
                taxExemptionRec.Sales_Tax_Item__c = taxExemptionObj.SalesTaxItemId;
                taxExemptionListToInsert.add(taxExemptionRec);
            } 
        }
        if(taxExemptionListToInsert.size() > 0) {
            insert taxExemptionListToInsert;
        }
    }
    
    /** Method to update tax exemption on account type.This method inserts new sales tax items and updates i.e deletes/removes tax which are no longer needed
    * CtrlClass -AccountTypeCtrl
    * @Return - no return type
    */
    
    private static String updateTaxExeptionList(String accTypeObjId, List<TaxExemptions> taxExemptionObjList) {
        if(AccessControl.ifObjectIsUpdateable('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Tax_Exemption__c> taxExemptionListToInsert = new List<Tax_Exemption__c>();
        List<String> taxExemptionIdListToDelete = new List<String>();
		Set<String> selectedTaxExemptionIdSet = new Set<String>();
		Set<String> selectedSalexTaxIdSet = new Set<String>();
        List<Account_Type__c> accTypeRec = AccountTypeSOQLUtil.getTaxExemptionRecForAccType(new Map<String,String>{'Id' => accTypeObjId});
        List<Tax_Exemption__c> taxPresentOnAccTypeList = new List<Tax_Exemption__c>();
        if(accTypeRec[0].Tax_Exemptions__r.size() > 0) {
			for(Tax_Exemption__c tax : accTypeRec[0].Tax_Exemptions__r) {
				if(tax.Sales_Tax_Item__r.Name__c != null) {
			    	taxPresentOnAccTypeList.add(tax);
				}
			}
        }
        for(TaxExemptions taxes : taxExemptionObjList) {
        	if(taxes.isSelected) {
        		selectedTaxExemptionIdSet.add(taxes.TaxExemptionId);
        		selectedSalexTaxIdSet.add(taxes.SalesTaxItemId);
        	}
        }
        
        for(Tax_Exemption__c tax : taxPresentOnAccTypeList) {
        	if( !selectedTaxExemptionIdSet.contains(tax.Id)) {
        		taxExemptionIdListToDelete.add(tax.Id);
        	} else {
        		selectedTaxExemptionIdSet.remove(tax.Id);
        	}
        	if( selectedSalexTaxIdSet.contains(tax.Sales_Tax_Item__r.Id)) {
        		selectedSalexTaxIdSet.remove(tax.Sales_Tax_Item__r.Id);
        	}
        }
        
        if(selectedSalexTaxIdSet.size() > 0) {
        	for(String taxToBeInserted : selectedSalexTaxIdSet) {
	            Tax_Exemption__c taxExemptionRec = new Tax_Exemption__c(Account_Type__c = accTypeObjId, Sales_Tax_Item__c = taxToBeInserted);
	            taxExemptionListToInsert.add(taxExemptionRec);
	        }
        }
        if(taxExemptionListToInsert.size() > 0) {
        	if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            insert taxExemptionListToInsert;
        }
        if(taxExemptionIdListToDelete.size() > 0) {
        	List<Tax_Exemption__c> taxExemptionsRecToBeDeletedList = [Select Id from Tax_Exemption__c where Id IN: taxExemptionIdListToDelete And Account_Type__c =: accTypeObjId];
            if(AccessControl.ifObjectIsDeletable('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete taxExemptionsRecToBeDeletedList;
        }
        
        return accTypeRec[0].Id;
    } 
    
   /** Method to get Record of a particular Account Type which is needed before this record is updated
    * CtrlClass -AccountTypeCtrl
    * @Return - account type wrapper object
    */
    
    public static AccountTypeWrapper getRecForAccountType(String accTypeId) {
        List<Account_Type__c> accTypeRec = AccountTypeSOQLUtil.getTaxExemptionRecForAccType(new Map<String,String>{'Id' => accTypeId});
        List<TaxExemptions> taxExemptionsList = new List<TaxExemptions>();  
        List<Sales_Tax_Item__c> salesTaxItemList = new List<Sales_Tax_Item__c>();
        List<Tax_Exemption__c> taxExemptionItemList = new List<Tax_Exemption__c>();
        if(accTypeRec[0].Tax_Exemptions__r.size() > 0) {
	        for(Tax_Exemption__c tax : accTypeRec[0].Tax_Exemptions__r) {
				if(tax.Sales_Tax_Item__r != null && tax.Sales_Tax_Item__r.Name__c != null && String.isNotBlank(tax.Sales_Tax_Item__r.Name__c)) {
			    	taxExemptionItemList.add(tax);
			    	salesTaxItemList.add(tax.Sales_Tax_Item__r);
				}
			}
        }
        Map<Id, List<String>> salesTaxItemIdToAppliesToList = getAppliesToList(salesTaxItemList);
        for(Tax_Exemption__c taxExemptionRec : taxExemptionItemList) {
            taxExemptionsList.add(new TaxExemptions(taxExemptionRec, salesTaxItemIdToAppliesToList.get(taxExemptionRec.Sales_Tax_Item__c), 'Account Type'));
        } 
        return populateTaxExemptionList(taxExemptionsList, accTypeRec[0]);
    }
    
    /** Method to populate all the sales tax present with sales tax present on the record
    * CtrlClass -AccountTypeCtrl
    * @Return - account type wrapper object
    */
    private static AccountTypeWrapper populateTaxExemptionList(List<TaxExemptions> taxeExemptionPresentList, Account_Type__c accTypeRec) {
    	List<TaxExemptions> allTaxesExemptionList =  getAllActiveSalesTax();
    	for(TaxExemptions taxes : allTaxesExemptionList) {
        	for(TaxExemptions taxPresent : taxeExemptionPresentList) {
        		if(taxPresent.IsSelected && taxes.SalesTaxName == taxPresent.SalesTaxName) {
        			taxes.isSelected = true;
        			taxes.TaxExemptionId = taxPresent.TaxExemptionId;
        		} 
        	}
        }
        return new AccountTypeWrapper(accTypeRec, allTaxesExemptionList);
    }
}