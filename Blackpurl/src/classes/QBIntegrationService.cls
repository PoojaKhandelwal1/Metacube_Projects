/**
 * Author: Pooja Kahndelwal
 * Since: Nov. 30, 2018
 * Name: QBIntegrationService
 * Description: Service Class for QB Integration
**/
public without sharing class QBIntegrationService {
	
	public static final Integer RECORDS_PER_PAGE = 99;
    public static List<QBTaxCodeWrapper> getTaxCodes() {
   		return getTaxCodes(null);
   	}
    public static List<QBTaxCodeWrapper> getTaxCodes(Set<String> taxCodeAccIdSet) {
   		String query;   
        query = 'SELECT '; 
        for(String fieldsName : QBTaxCodeWrapper.getFieldList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'QB_TaxCode__c';
        query += (taxCodeAccIdSet != null && taxCodeAccIdSet.size() > 0) ? ' WHERE Accounting_Id__c IN :taxCodeAccIdSet' : '';
        query += ' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
        
        if(AccessControl.ifObjectFieldIsAccessible('QB_TaxCode__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<QB_TaxCode__c> taxCodeList  = Database.query(query);
        
        List<QBTaxCodeWrapper> taxCodeRecList = new List<QBTaxCodeWrapper>();
        for(QB_TaxCode__c taxCode: taxCodeList) {
        	taxCodeRecList.add(new QBTaxCodeWrapper(taxCode));
        }
        return taxCodeRecList;
   	}
   	
   	public static List<QBTaxCodeWrapper> getNonTaxableTaxCodes() {
   		String query;   
        query = 'SELECT '; 
        for(String fieldsName : QBTaxCodeWrapper.getFieldList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'QB_TaxCode__c WHERE Rate_Value__c = 0';
        query += ' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
        
        if(AccessControl.ifObjectFieldIsAccessible('QB_TaxCode__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<QB_TaxCode__c> nonTaxableTaxCodeList  = Database.query(query);
        
        List<QBTaxCodeWrapper> nonTaxableTaxCodeRecList = new List<QBTaxCodeWrapper>();
        for(QB_TaxCode__c taxCode: nonTaxableTaxCodeList) {
        	nonTaxableTaxCodeRecList.add(new QBTaxCodeWrapper(taxCode));
        }
        return nonTaxableTaxCodeRecList;
   	}
   	
   	
   	public static List<QBTaxRateWrapper> getTaxRates() {
   		String query;   
        query = 'SELECT '; 
        for(String fieldsName : QBTaxRateWrapper.getFieldList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'QB_Tax_Rate__c';
        query += ' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
        
        if(AccessControl.ifObjectFieldIsAccessible('QB_Tax_Rate__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<QB_Tax_Rate__c> taxRateList  = Database.query(query);
        
        List<QBTaxRateWrapper> taxRateRecList = new List<QBTaxRateWrapper>();
        for(QB_Tax_Rate__c taxRate: taxRateList) {
        	taxRateRecList.add(new QBTaxRateWrapper(taxRate));
        }
        return taxRateRecList;
   	}
   	
   	public static void saveSalesTaxMapping(String salesTaxListJson) {
   		List<SalesTax> salesTaxList = (List<SalesTax>) System.JSON.deserialize(salesTaxListJson, List<SalesTax>.class);
   		List<Sales_Tax__c> saleTaxListToUpdate = new List<Sales_Tax__c>();
   		
   		Set<String> mappedTaxCodeAccIdSet = new Set<String>();
        for(SalesTax salesTaxObj : salesTaxList) {
        	if(String.isBlank(salesTaxObj.AccountingId)) throw new BlackPurlException(BlackPurlException.getErrorMessage('Error: Mappings cannot be blank', ''));
        	saleTaxListToUpdate.add(new Sales_Tax__c(Id = salesTaxObj.Id, Accounting_Id__c = salesTaxObj.AccountingId));
        	mappedTaxCodeAccIdSet.add(salesTaxObj.AccountingId);
        }
        
        //validateTaxCodeMappings(salesTaxList, mappedTaxCodeAccIdSet);
    	
        if(saleTaxListToUpdate.size() > 0) {
        	if(AccessControl.ifObjectFieldIsUpdateable('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        	update saleTaxListToUpdate;
        }
   	}
   	
   	private static void validateTaxCodeMappings(List<SalesTax> salesTaxList, Set<String> mappedTaxCodeAccIdSet) {
   		List<QBTaxCodeWrapper> taxCodeObjList = getTaxCodes(mappedTaxCodeAccIdSet);
        
        Map<String, Decimal> accIdToRateValueMap = new Map<String, Decimal>();
    	Map<String, Set<Integer>> taxCodeAccIdToTaxRateAccIdSetMap = new Map<String, Set<Integer>>();
    	for(QBTaxCodeWrapper taxCodeObj : taxCodeObjList) {
    		accIdToRateValueMap.put(taxCodeObj.Id, taxCodeObj.RateValue);
    		taxCodeAccIdToTaxRateAccIdSetMap.put(taxCodeObj.Id, (taxCodeObj.ApplicableTaxRates != null ? taxCodeObj.ApplicableTaxRates : new Set<Integer>()));
    	}
    	
    	for(SalesTax salesTaxObj : salesTaxList) {
            if(!accIdToRateValueMap.containsKey(salesTaxObj.AccountingId)) throw new BlackPurlException(BlackPurlException.getErrorMessage('Error: Incorrect tax code mappings', ''));
            if(salesTaxObj.TaxRate != accIdToRateValueMap.get(salesTaxObj.AccountingId))  throw new BlackPurlException(BlackPurlException.getErrorMessage('Error: Incorrect tax code mappings', ''));
    		
    		List<Integer> qbTaxRateAccIdList = new List<Integer>(taxCodeAccIdToTaxRateAccIdSetMap.get(salesTaxObj.AccountingId));
    		
    		List<Integer> bpSTIAccIdList = new List<Integer>();
    		for(SalesTaxItem salesTaxItemObj : salesTaxObj.salesTaxItemList) {
    			bpSTIAccIdList.add(String.isNotBlank(salesTaxItemObj.AccountingId) ? Integer.valueOf(salesTaxItemObj.AccountingId.trim()) : 0);
    		}
    		
    		qbTaxRateAccIdList.sort();
    		bpSTIAccIdList.sort();
    		
            if(bpSTIAccIdList.size() != qbTaxRateAccIdList.size() && salesTaxObj.TaxRate != 0) throw new BlackPurlException(BlackPurlException.getErrorMessage('Error: Incorrect tax code mappings', ''));
    		for(Integer i = 0; i < bpSTIAccIdList.size(); i++) {
                if(bpSTIAccIdList[i] != qbTaxRateAccIdList[i]) throw new BlackPurlException(BlackPurlException.getErrorMessage('Error: Incorrect tax code mappings', ''));
    		}
    	}
   	}
   	
   	public static void saveNonTaxableTaxCodeMapping(String salesAccountingId, String purchaseAccountingId) {
   		QuickBooks_Configurations__c QBConfig = QuickBooks_Configurations__c.getOrgDefaults();
        QBConfig.Non_Taxable_Tax_Code__c = salesAccountingId;
        QBConfig.Non_Taxable_Purchase_Tax_Code__c = purchaseAccountingId;
        upsert QBConfig;
   	}
   	
   	public static void saveSalesTaxItemMapping(String salesTaxItemListJson) {
   		List<SalesTaxItem> salesTaxItemList = (List<SalesTaxItem>) System.JSON.deserialize(salesTaxItemListJson, List<SalesTaxItem>.class);
   		List<Sales_Tax_Item__c>  salesTaxItemListToUpdate = new List<Sales_Tax_Item__c>();
   		
   		Set<String> mappedAccountingIdSet = new Set<String>();
        for(SalesTaxItem salesTaxItemRec : salesTaxItemList) {
        	if(String.isBlank(salesTaxItemRec.AccountingId)) throw new BlackPurlException(BlackPurlException.getErrorMessage('Error: Mappings cannot be blank', ''));
        	mappedAccountingIdSet.add(salesTaxItemRec.AccountingId);
        	salesTaxItemListToUpdate.add(new Sales_Tax_Item__c(Id = salesTaxItemRec.Id, AccountingId__c = salesTaxItemRec.AccountingId));
        }
            		               
        validateTaxRateMappings(salesTaxItemList, mappedAccountingIdSet);
        
        if(salesTaxItemListToUpdate.size() > 0) {	       
        	if(AccessControl.ifObjectFieldIsUpdateable('Sales_Tax_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        	update salesTaxItemListToUpdate;
        }
   	}
   	   	
   	private static void validateTaxRateMappings(List<SalesTaxItem> salesTaxItemList, Set<String> mappedAccountingIdSet) {
   		List<QB_Tax_Rate__c> taxRateList = [Select Id, Accounting_Id__c, Rate_Value__c from QB_Tax_Rate__c where Accounting_Id__c IN: mappedAccountingIdSet];
    	Map<String, Decimal> accountingIdToRateMap = new Map<String, Decimal>();
    	for(QB_Tax_Rate__c taxRateRec : taxRateList) {
    		accountingIdToRateMap.put(taxRateRec.Accounting_Id__c, (taxRateRec.Rate_Value__c != null ? taxRateRec.Rate_Value__c : 0));
    	}
        
        for(SalesTaxItem salesTaxItemObj : salesTaxItemList) {
        	salesTaxItemObj.TaxRate = (salesTaxItemObj.TaxRate != null ? salesTaxItemObj.TaxRate : 0);
        	if(String.isBlank(salesTaxItemObj.AccountingId) || !accountingIdToRateMap.containsKey(salesTaxItemObj.AccountingId) || 
        		(accountingIdToRateMap.get(salesTaxItemObj.AccountingId) != salesTaxItemObj.TaxRate)) {
            	throw new BlackPurlException(BlackPurlException.getErrorMessage('Error: Incorrect tax rate mappings', ''));
        	}
        }
        
   	}
   	
   	public static void syncTaxCodesWithQuickbooks() {
        Integer pageNumber = 0;
        Set<String> taxRatesAccountingIdSet = new Set<String>(); 
        List<QBTaxCodeWrapper> taxCodesOnQuickbooks = new List<QBTaxCodeWrapper>();
        List<QB_TaxCode__c> qbTaxCodeRecordsToInsert = new List<QB_TaxCode__c>();
        List<QBTaxCodeWrapper>  taxCodeResponseList;
        do{
            taxCodeResponseList = getAllTaxCodesFromQBAPI(pageNumber);
            taxCodesOnQuickbooks.addAll(taxCodeResponseList);
            pageNumber++;
        } while(taxCodeResponseList.size() >= RECORDS_PER_PAGE);
        if(taxCodesOnQuickbooks.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('QB_TaxCode__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            Delete [Select Id from QB_TaxCode__c];
            
            for(QBTaxCodeWrapper qbTaxCode : taxCodesOnQuickbooks){
                String childSalesTaxRateString = '';
                String childPurchaseTaxRateString = '';
                if(qbTaxCode.SalesTaxRateList != null && qbTaxCode.SalesTaxRateList.TaxRateDetail != null && qbTaxCode.SalesTaxRateList.TaxRateDetail.size() > 0) {
                    
                    for(QBTaxCodeWrapper.TaxRateDetailWrapper childSalesTaxRate : qbTaxCode.SalesTaxRateList.TaxRateDetail) {
                        String taxRateAccId = childSalesTaxRate.TaxRateRef.value;
                        taxRatesAccountingIdSet.add(taxRateAccId);
                        childSalesTaxRateString += String.isNotBlank(taxRateAccId)?  (taxRateAccId+';') : '';
                    }
                    
                }
                if(qbTaxCode.PurchaseTaxRateList != null && qbTaxCode.PurchaseTaxRateList.TaxRateDetail != null && qbTaxCode.PurchaseTaxRateList.TaxRateDetail.size() > 0) {
                    
                    for(QBTaxCodeWrapper.TaxRateDetailWrapper childPurchaseTaxRate : qbTaxCode.PurchaseTaxRateList.TaxRateDetail) {
                        String taxRateAccId = childPurchaseTaxRate.TaxRateRef.value;
                        taxRatesAccountingIdSet.add(taxRateAccId);
                        childPurchaseTaxRateString += String.isNotBlank(taxRateAccId)?  (taxRateAccId+';') : '';
                    }
                    
                }
                String originalTaxCodeName = qbTaxCode.Name;
                if(String.isNotBlank(childSalesTaxRateString)) {
                    childSalesTaxRateString = childSalesTaxRateString.removeEnd(';');
                    qbTaxCode.TaxApplicableOn = QBUtil.SALES;
                    if(String.isNotBlank(childPurchaseTaxRateString)) {
                        qbTaxCode.Name = originalTaxCodeName.length() > 68 ? originalTaxCodeName.subString(0, 68) : originalTaxCodeName;
                        qbTaxCode.Name += ' ('+qbTaxCode.TaxApplicableOn+')';
                    }
                    qbTaxCodeRecordsToInsert.add(getTaxCodeWrapperToSObject(qbTaxCode, childSalesTaxRateString));
                }
                if(String.isNotBlank(childPurchaseTaxRateString)) {
                    qbTaxCode.TaxApplicableOn = QBUtil.PURCHASE;
                    childPurchaseTaxRateString = childPurchaseTaxRateString.removeEnd(';');
                    if(String.isNotBlank(childSalesTaxRateString)) {
                        qbTaxCode.Name = originalTaxCodeName.length() > 68 ? originalTaxCodeName.subString(0, 68) : originalTaxCodeName;
                        qbTaxCode.Name += ' ('+qbTaxCode.TaxApplicableOn+')';
                    }
                    qbTaxCodeRecordsToInsert.add(getTaxCodeWrapperToSObject(qbTaxCode, childPurchaseTaxRateString));
                }
                if(String.isBlank(childPurchaseTaxRateString) && String.isBlank(childSalesTaxRateString)) {
                    qbTaxCodeRecordsToInsert.add(getTaxCodeWrapperToSObject(qbTaxCode, null));
                }
            }
            Map<String, QB_Tax_Rate__c> taxRateMap = getAccountingIdToQBTaxRateMap(taxRatesAccountingIdSet);
            for(Integer index=0; index < qbTaxCodeRecordsToInsert.size(); index++){ 
                for(String acctId : qbTaxCodeRecordsToInsert[index].Applicable_QB_Tax_Rates__c.split(';')) {
                    if(String.isNotBlank(acctId) && taxRateMap.containsKey(acctId)) {
                        qbTaxCodeRecordsToInsert[index].Rate_Value__c += taxRateMap.get(acctId).Rate_Value__c != null ? taxRateMap.get(acctId).Rate_Value__c : 0 ;
                    }
                }
            }
            if(AccessControl.ifObjectFieldIsCreateable('QB_TaxCode__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('QB_TaxCode__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            upsert qbTaxCodeRecordsToInsert;
        }
    }
    
    public static QB_TaxCode__c getTaxCodeWrapperToSObject(QBTaxCodeWrapper qbTaxCode, String childRateString) {
        QB_TaxCode__c taxCodeRec = new QB_TaxCode__c();
        taxCodeRec.Name = (qbTaxCode.Name != null && qbTaxCode.Name.length() > 79) ? qbTaxCode.Name.subString(0, 79) : qbTaxCode.Name;
        taxCodeRec.Is_Active__c = qbTaxCode.Active;
        taxCodeRec.Is_Taxable__c = qbTaxCode.Taxable;
        taxCodeRec.Accounting_Id__c = qbTaxCode.Id;
        taxCodeRec.Applicable_QB_Tax_Rates__c = childRateString;
        taxCodeRec.Tax_Applicable_On__c = qbTaxCode.TaxApplicableOn;
        taxCodeRec.Rate_Value__c = 0;
        return taxCodeRec;
    }
    
    public static Map<String, QB_Tax_Rate__c> getAccountingIdToQBTaxRateMap(Set<String> taxRatesAccountingIdSet) {
        Map<String, QB_Tax_Rate__c> accountingIdToQBTaxRateMap = new Map<String, QB_Tax_Rate__c>();
        List<QB_Tax_Rate__c> taxRatesRecs = [SELECT Rate_Value__c, Accounting_Id__c From QB_Tax_Rate__c WHERE Accounting_Id__c IN :taxRatesAccountingIdSet];
        for(QB_Tax_Rate__c taxRateRec : taxRatesRecs) {
            accountingIdToQBTaxRateMap.put(taxRateRec.Accounting_Id__c, taxRateRec);
        }
        return accountingIdToQBTaxRateMap;
    }
    
    public static void syncTaxRatesWithQuickbooks() {
        Integer pageNumber = 0;
        List<QBTaxRateWrapper> taxRatesOnQuickbooks = new List<QBTaxRateWrapper>();
        List<QBTaxRateWrapper>  taxRateResponseList;
        do{
            taxRateResponseList = getAllTaxRatesFromQBAPI(pageNumber);
            taxRatesOnQuickbooks.addAll(taxRateResponseList);
            pageNumber++;
        } while(taxRateResponseList.size() >= RECORDS_PER_PAGE);
        List<QB_Tax_Rate__c> qbTaxRateRecordsToInsert = new List<QB_Tax_Rate__c>();
        if(taxRatesOnQuickbooks.size() > 0) {
            
            if(AccessControl.ifObjectIsDeletable('QB_Tax_Rate__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            Delete [Select Id from QB_Tax_Rate__c];
            
            for(QBTaxRateWrapper qbTaxRate : taxRatesOnQuickbooks){
                QB_Tax_Rate__c taxRateRec = new QB_Tax_Rate__c();
                taxRateRec.Name = qbTaxRate.Name;
                taxRateRec.Rate_Value__c = qbTaxRate.RateValue;
                taxRateRec.Accounting_Id__c = qbTaxRate.Id;
                taxRateRec.Tax_Agency__c = qbTaxRate.AgencyRef.value;
                taxRateRec.Is_Active__c = qbTaxRate.Active;
                qbTaxRateRecordsToInsert.add(taxRateRec);
            }
            
           if(AccessControl.ifObjectFieldIsCreateable('QB_Tax_Rate__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	       if(AccessControl.ifObjectFieldIsUpdateable('QB_Tax_Rate__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
           upsert qbTaxRateRecordsToInsert;
        }
    }
    
    
    public static List<QBTaxCodeWrapper> getAllTaxCodesFromQBAPI(Integer pageNumber) {
        if(Test.isRunningTest()){
        	String resultJson = '[{"Name":"BP Code","Active":true,"Taxable":true,"SalesTaxRateList":{"TaxRateDetail":[{"TaxRateRef":{"value":"47","name":"BP Local Tax - R"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0},{"TaxRateRef":{"value":"48","name":"BP PST - R1"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0},{"TaxRateRef":{"value":"49","name":"BP GST R"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0},{"TaxRateRef":{"value":"50","name":"BP Combi"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0}]},"PurchaseTaxRateList":{"TaxRateDetail":[]},"sparse":true,"Id":"122","SyncToken":"0"},{"Name":"BP Code","Active":true,"Taxable":true,"PurchaseTaxRateList":{"TaxRateDetail":[{"TaxRateRef":{"value":"47","name":"BP Local Tax - R"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0},{"TaxRateRef":{"value":"48","name":"BP PST - R1"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0},{"TaxRateRef":{"value":"49","name":"BP GST R"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0},{"TaxRateRef":{"value":"50","name":"BP Combi"},"TaxTypeApplicable":"TaxOnAmount","TaxOrder":0}]},"SalesTaxRateList":{"TaxRateDetail":[]},"sparse":true,"Id":"121","SyncToken":"0"}]';
    		return (List<QBTaxCodeWrapper>)System.JSON.deserialize(resultJson, List<QBTaxCodeWrapper>.class);
    	}
        QuickBookQueryService.ResponseQuickBooks  qbResponse = QuickBookQueryService.getRecordsByFieldName('TaxCode', 'Active', 'true', '=', pageNumber, RECORDS_PER_PAGE);
        
        if(qbResponse != null && qbResponse.TaxCode != null && qbResponse.TaxCode.size() > 0) {
            return qbResponse.TaxCode;
        } else {
            return new List<QBTaxCodeWrapper>();
        }
    }
    
    public static List<QBTaxRateWrapper> getAllTaxRatesFromQBAPI(Integer pageNumber) {
    	if(Test.isRunningTest()){
        	String resultJson = '[{"Name":"BP BP KST","Active":true,"RateValue":30,"AgencyRef":{"value":"26"},"sparse":true,"Id":"34","SyncToken":"0"},{"Name":"BP BPTax1","Active":true,"RateValue":5,"AgencyRef":{"value":"26"},"sparse":true,"Id":"53","SyncToken":"0"},{"Name":"BP Combi","Active":true,"RateValue":2,"AgencyRef":{"value":"26"},"sparse":true,"Id":"50","SyncToken":"0"}]';
    		return (List<QBTaxRateWrapper>)System.JSON.deserialize(resultJson, List<QBTaxRateWrapper>.class);
    	}
        QuickBookQueryService.ResponseQuickBooks  qbResponse = QuickBookQueryService.getRecordsByFieldName('TaxRate', 'Active', 'true', '=', pageNumber, RECORDS_PER_PAGE);
        
        if(qbResponse != null && qbResponse.TaxRate != null && qbResponse.TaxRate.size() > 0) {
            return qbResponse.TaxRate;
        } else {
            return new List<QBTaxRateWrapper>();
        }
    }
}