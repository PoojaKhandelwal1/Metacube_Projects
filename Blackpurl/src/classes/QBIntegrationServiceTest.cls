/**
 * Author: Pooja Khandelwal
 * Since: Dec. 10, 2014
 * Name: QBIntegrationServiceTest
 * Description: Static util class to test QB Integration
**/
public with sharing class QBIntegrationServiceTest {
    public static void createQBTaxRates() {
    	List<QB_Tax_Rate__c> qbTaxRateRecordsToInsert = new List<QB_Tax_Rate__c>();
    	
    	Integer accId = 0;
    	for(Integer i = 0; i < 2; i++) {
    		QB_Tax_Rate__c taxRateRec = new QB_Tax_Rate__c();
    		taxRateRec.Name = 'TaxRate(Sales) - ' + i;
            taxRateRec.Rate_Value__c = i * 5;
            taxRateRec.Accounting_Id__c = '' + accId + '';
            taxRateRec.Is_Active__c = true;
            qbTaxRateRecordsToInsert.add(taxRateRec);
            accId++;
    	} 
    	
    	for(Integer j = 0; j < 2; j++) {
    		QB_Tax_Rate__c taxRateRec = new QB_Tax_Rate__c();
    		taxRateRec.Name = 'TaxRate(Purchase) - ' + j;
            taxRateRec.Rate_Value__c = j * 5;
            taxRateRec.Accounting_Id__c = ''+ accId + '';
            taxRateRec.Is_Active__c = true;
            qbTaxRateRecordsToInsert.add(taxRateRec);
            accId++;
    	}
    	insert qbTaxRateRecordsToInsert;
    }
    
    private static Map<String, Decimal> generateQBTaxRatesCombinations(List<QB_Tax_Rate__c> qbTaxRateList) {
    	Map<String, Decimal> qbTaxRateCombinationsToToalRateValueMap = new Map<String, Decimal>(); // Semicolon separated tax rate combination list like ({1;2}, {1;2;3})
    	String taxRatesAccountingIdsStr;
    	Decimal totalRateValue;
    	for(Integer i = 0; i < (1 << qbTaxRateList.size()); i++) {
            taxRatesAccountingIdsStr = '';
            totalRateValue = 0;
            for(Integer j = 0; j < qbTaxRateList.size(); j++) {
                if((i & (1 << j)) > 0) {
                    taxRatesAccountingIdsStr += qbTaxRateList[j].Accounting_Id__c + ';';
                    totalRateValue += qbTaxRateList[j].Rate_Value__c;
                }
            }
            qbTaxRateCombinationsToToalRateValueMap.put(taxRatesAccountingIdsStr, totalRateValue);
        }
        return qbTaxRateCombinationsToToalRateValueMap;
    }
    
    public static void createQBTaxCodes() {
    	List<QB_Tax_Rate__c> qbSalesTaxRateList = [SELECT ID, Accounting_Id__c, Rate_Value__c FROM QB_Tax_Rate__c WHERE Name like '%Sales%'];
    	List<QB_Tax_Rate__c> qbPurchaseTaxRateList = [SELECT ID, Accounting_Id__c, Rate_Value__c FROM QB_Tax_Rate__c WHERE Name like '%Purchase%'];
    	
    	Map<String, Decimal> qbSalesTaxRateCombinationsToToalRateValueMap = generateQBTaxRatesCombinations(qbSalesTaxRateList);
    	Map<String, Decimal> qbPurchaseTaxRateCombinationsToToalRateValueMap = generateQBTaxRatesCombinations(qbPurchaseTaxRateList);
    	
    	List<QB_TaxCode__c> qbTaxCodeRecordsToInsert = new List<QB_TaxCode__c>();
    	
    	Integer accId = 0;
    	Integer counter = 0;
    	for (String applicableQBTaxRatesAccIds : qbSalesTaxRateCombinationsToToalRateValueMap.keySet()) {
		    if(String.isNotBlank(applicableQBTaxRatesAccIds)) {
		    	QB_TaxCode__c qbSalesTaxCode = new QB_TaxCode__c();
		    	qbSalesTaxCode.Name = 'TaxCode - ' + counter;
		        qbSalesTaxCode.Is_Active__c = true;
		        qbSalesTaxCode.Is_Taxable__c = true;
		        qbSalesTaxCode.Accounting_Id__c = ''+ accId + '';
		        qbSalesTaxCode.Applicable_QB_Tax_Rates__c = applicableQBTaxRatesAccIds;
		        qbSalesTaxCode.Tax_Applicable_On__c = 'Sales';
		        qbSalesTaxCode.Rate_Value__c = qbSalesTaxRateCombinationsToToalRateValueMap.get(applicableQBTaxRatesAccIds);
		        qbTaxCodeRecordsToInsert.add(qbSalesTaxCode);
		        accId++;
		        counter++;
		    }
		}
		
		counter = 0;
		for (String applicableQBTaxRatesAccIds : qbPurchaseTaxRateCombinationsToToalRateValueMap.keySet()) {
			if(String.isNotBlank(applicableQBTaxRatesAccIds)) {
				QB_TaxCode__c qbSalesTaxCode = new QB_TaxCode__c();
		    	qbSalesTaxCode.Name = 'TaxCode - ' + counter;
		        qbSalesTaxCode.Is_Active__c = true;
		        qbSalesTaxCode.Is_Taxable__c = true;
		        qbSalesTaxCode.Accounting_Id__c = ''+ accId + '';
		        qbSalesTaxCode.Applicable_QB_Tax_Rates__c = applicableQBTaxRatesAccIds;
		        qbSalesTaxCode.Tax_Applicable_On__c = 'Purchase';
		        qbSalesTaxCode.Rate_Value__c = qbPurchaseTaxRateCombinationsToToalRateValueMap.get(applicableQBTaxRatesAccIds);
		        qbTaxCodeRecordsToInsert.add(qbSalesTaxCode);
		        accId++;
		        counter++;
			}
		}
        
        insert qbTaxCodeRecordsToInsert;
    }
    
    public static void saveNonTaxableTaxCodeMapping() {
    	List<QBTaxCodeWrapper> nonTaxableTaxCodeRecList = QBIntegrationService.getNonTaxableTaxCodes();
    	if(nonTaxableTaxCodeRecList.size() > 0) {
    		QBIntegrationService.saveNonTaxableTaxCodeMapping(nonTaxableTaxCodeRecList[0].Id, nonTaxableTaxCodeRecList[0].Id);
    	}
    }
    
    public static void createSalesTaxItemsAndPopulateQBAccIds() {
    	Category__c categoryObj = TestUtil.createCategory(true, 'TaxCategory', 'Tax', 'TaxCategory', true, true);
    	
    	List<Sales_Tax_Item__c> bpSalesTaxItemRecordsToInsert = new List<Sales_Tax_Item__c>();
    	
    	for(Integer i = 0; i < 2; i++) {
    		Sales_Tax_Item__c salesTaxItemRec = new Sales_Tax_Item__c();
    		salesTaxItemRec.Name__c = 'STI(Sales) - ' + i;
            salesTaxItemRec.Rate__c = i * 5;
            salesTaxItemRec.Forms_Label__c = 'STI(Sales) - ' + i;
            salesTaxItemRec.Active__c = true; 
            salesTaxItemRec.Category__c = categoryObj.Id;
            bpSalesTaxItemRecordsToInsert.add(salesTaxItemRec);
    	} 
    	 
    	for(Integer j = 0; j < 2; j++) { 
    		Sales_Tax_Item__c salesTaxItemRec = new Sales_Tax_Item__c();
    		salesTaxItemRec.Name__c = 'STI(Purchase) - ' + j;
            salesTaxItemRec.Rate__c = j * 5;
            salesTaxItemRec.Forms_Label__c = 'STI(Purchase) - ' + j;
            salesTaxItemRec.Active__c = true; 
            salesTaxItemRec.Category__c = categoryObj.Id;
            bpSalesTaxItemRecordsToInsert.add(salesTaxItemRec);
    	}
    	insert bpSalesTaxItemRecordsToInsert;
    	
    	getSalesTaxItemAndPopulateQBAccId();
    }
    
    private static void  getSalesTaxItemAndPopulateQBAccId() {
    	List<SalesTaxItem> salesTaxItemList = (List<SalesTaxItem>) System.JSON.deserialize(BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.getSalesTaxItemList()), List<SalesTaxItem>.class);
    	
    	Integer accId = 0;
    	for(SalesTaxItem salesTaxItemRec : salesTaxItemList) {
    		salesTaxItemRec.AccountingId = '' + accId + '';
    		accId++;
    	}
    	QBIntegrationService.saveSalesTaxItemMapping(system.JSON.serialize(salesTaxItemList, true));
    }
    
    public static void createSalesTaxAndApplicableTaxRecordsAndPopulateQBAccIds() {
    	List<Sales_Tax__c> bpSalesTaxRecordsToInsert = new List<Sales_Tax__c>();
    	
    	for(Integer i = 0; i < 3; i++) { 
    		Sales_Tax__c salesTaxRec = new Sales_Tax__c();
    		salesTaxRec.Name__c = 'salesTax(Sales) - ' + i;
	        salesTaxRec.Default__c = false;
	        salesTaxRec.Active__c = true; 
	        bpSalesTaxRecordsToInsert.add(salesTaxRec);
    	}
    	
        for(Integer j = 0; j < 3; j++) { 
    		Sales_Tax__c salesTaxRec = new Sales_Tax__c();
    		salesTaxRec.Name__c = 'salesTax(Purchase) - ' + j;
	        salesTaxRec.Default__c = false;
	        salesTaxRec.Active__c = true; 
	        bpSalesTaxRecordsToInsert.add(salesTaxRec);
    	}
    	
    	// SalesTax With No Sales Tax Item
    	/**Sales_Tax__c salesTaxRec3 = new Sales_Tax__c();
		salesTaxRec3.Name__c = 'zsalesTax(Sales) - 3';
        salesTaxRec3.Default__c = false;
        salesTaxRec3.Active__c = true; 
        salesTaxRec3.Rate__c = 0; 
        bpSalesTaxRecordsToInsert.add(salesTaxRec3);
        
        Sales_Tax__c purchaseTaxRec3 = new Sales_Tax__c();
		purchaseTaxRec3.Name__c = 'zsalesTax(Purchase) - 3';
        purchaseTaxRec3.Default__c = false;
        purchaseTaxRec3.Active__c = true; 
        purchaseTaxRec3.Rate__c = 0; 
        bpSalesTaxRecordsToInsert.add(purchaseTaxRec3);*/
       
    	insert bpSalesTaxRecordsToInsert;
        
        createApplicableTaxRecs(bpSalesTaxRecordsToInsert);
        getSalesTaxRecsAndPopulateQBAccIds();
    }
    
    private static void createApplicableTaxRecs(List<Sales_Tax__c> salesTaxList) {
    	List<Sales_Tax_Item__c> salesTaxItemList = [Select Id FROM Sales_Tax_Item__c WHERE Name__c like '%Sales%'];
    	Applicable_Taxes__c appTax1 = TestUtil.createApplicableTax(false, salesTaxList[0].Id, salesTaxItemList[0].Id);
    	Applicable_Taxes__c appTax2 = TestUtil.createApplicableTax(false, salesTaxList[1].Id, salesTaxItemList[1].Id);
    	Applicable_Taxes__c appTax3 = TestUtil.createApplicableTax(false, salesTaxList[2].Id, salesTaxItemList[0].Id);
    	Applicable_Taxes__c appTax4 = TestUtil.createApplicableTax(false, salesTaxList[2].Id, salesTaxItemList[1].Id);
    	
    	List<Sales_Tax_Item__c> purchaseTaxItemList = [Select Id FROM Sales_Tax_Item__c WHERE Name__c like '%Purchase%'];
    	Applicable_Taxes__c appTax5 = TestUtil.createApplicableTax(false, salesTaxList[3].Id, purchaseTaxItemList[0].Id);
    	Applicable_Taxes__c appTax6 = TestUtil.createApplicableTax(false, salesTaxList[4].Id, purchaseTaxItemList[1].Id);
    	Applicable_Taxes__c appTax7 = TestUtil.createApplicableTax(false, salesTaxList[5].Id, purchaseTaxItemList[0].Id);
    	Applicable_Taxes__c appTax8 = TestUtil.createApplicableTax(false, salesTaxList[5].Id, purchaseTaxItemList[1].Id);
    	insert new List<Applicable_Taxes__c> {appTax1, appTax2, appTax3, appTax4, appTax5, appTax6, appTax7, appTax8};
    }
    
    public static void getSalesTaxRecsAndPopulateQBAccIds() {
    	List<SalesTax> salesTaxList = (List<SalesTax>) System.JSON.deserialize(BPUtility.getDecodedString(AccountingIntegrationSettingsCtrl.getSalesTaxList()), List<SalesTax>.class);
    	
    	Integer accId = 0;
    	for(SalesTax salesTaxRec : salesTaxList) { 
    		/**if(accId == 7) {
    			salesTaxRec.AccountingId = '' + 0 + '';
    		} else if(accId == 8) {
    			salesTaxRec.AccountingId = '' + 3 + '';
    		} else {*/
    			salesTaxRec.AccountingId = '' + accId + '';
    		//}
    		accId++;
    	}
    	QBIntegrationService.saveSalesTaxMapping(system.JSON.serialize(salesTaxList, true));
    }
    
}