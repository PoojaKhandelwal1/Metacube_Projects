public without sharing class AccountingCustomerInvoiceService {
	
	public static Map<Id, List<F_I_Product__c>> dealIdToFIProductsMap = new Map<Id, List<F_I_Product__c>>();
	
    public static List<Object> setAllInvoiceItemRec(AccountingCustomerInvoice customerInvoiceRecord) {
		return setAllInvoiceItemRec(customerInvoiceRecord, 'Invoice');
	} 
    public static List<Object> setAllInvoiceItemRec(AccountingCustomerInvoice customerInvoiceRecord, String entityType) {
    	List<Object> xeroItemDtoList = new List<Object>();
    	if(customerInvoiceRecord.AccountingCOInvoiceItemsRecs != null && customerInvoiceRecord.AccountingCOInvoiceItemsRecs.size() > 0) {
            List<Id> coliIds = new List<Id>();
            List<Id> sohIds = new List<Id>();
            List<Id> cokhIds = new List<Id>();
            List<Id> dealIds = new List<Id>();
            List<Id> soHeadersWithThirdPartyCheckoutList = new List<Id>();
            for(AccountingCustomerInvoice.AccountingCOInvoiceItem coInvoiceItem : customerInvoiceRecord.AccountingCOInvoiceItemsRecs) {
                if(coInvoiceItem.COLineItemId != null) {
                    coliIds.add(coInvoiceItem.COLineItemId);
                }
                if(coInvoiceItem.SOHeaderId != null) {
                    sohIds.add(coInvoiceItem.SOHeaderId);
                    if(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CheckoutType == 'Third-Party') {
                        soHeadersWithThirdPartyCheckoutList.add(coInvoiceItem.SOHeaderId);
                    } 
                }
                if(coInvoiceItem.COKitHeaderId != null) {
                    cokhIds.add(coInvoiceItem.COKitHeaderId);
                }
                if(coInvoiceItem.DealId != null) {
                    dealIds.add(coInvoiceItem.DealId);
                }
                if(coInvoiceItem.SOPaymentRoleId != null && customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CheckoutType == 'Customer') {
                    List<Category__c> deductibleCategoryList = AccountingUtil.getSystemDefaultCategory('Deductible');
                    if(entityType == 'Invoice') {
                    	String deductibleGL = deductibleCategoryList.size() > 0 ? deductibleCategoryList[0].Income_GL__c : null;
                    	xeroItemDtoList.add(new XeroLineItemDTO('Claim Deductible', coInvoiceItem.Total, deductibleGL));
                    }
                     
                    /*for(AccountingCustomerInvoice.TaxDetail taxDetailRec : customerInvoiceRecord.taxDetails) {
                        taxDetailRec.TaxAmount = 0;
                    }
                    taxCodeAccountingId = QBUtil.nonTaxableCodeAccId;
                    isNonTaxableLIExists = true;*/
                }
            }
            
            Id coId = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COHeaderId;
            List<CO_Header__c> coHeadersList = getCustomerOrderHeaders(new List<Id>{coId}, coliIds);
            List<Service_Order_Header__c> soHeadersList = getServiceOrderHeaders(new List<Id>{coId}, sohIds);
            List<CO_Kit_Header__c> coKitHeadersList = getKitHeaders(new List<Id>{coId}, cokhIds);
            List<Deal_Item__c> dealItemList = getDealHeaders(new List<Id>{coId}, dealIds);
            
            Map<Id, Service_Order_Line_Item__c> soliIdToSOLIRecordWithClaimLIMap = new Map<Id, Service_Order_Line_Item__c>();
            if(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CheckoutType == 'Third-Party' && sohIds.size() > 0) {
            	soliIdToSOLIRecordWithClaimLIMap = getSoliIdToSOLIRecordWithClaimLIMap(sohIds);
            }
            List<F_I_Product__c> dealFIProductList = new List<F_I_Product__c>();
            
            for(Id dealId: dealIds) {
                if(dealIdToFIProductsMap != null && dealIdToFIProductsMap.containsKey(dealId)) {
                    for(F_I_Product__c FIProduct: dealIdToFIProductsMap.get(dealId)) {
                        dealFIProductList.add(FIProduct);
                    }
                }
            }
            if(coHeadersList.size() > 0) {
            	xeroItemDtoList.addAll(setColiInvoiceItemRec(coHeadersList, customerInvoiceRecord, entityType));
            }
            if(soHeadersList.size() > 0) {
            	xeroItemDtoList.addAll(setDataForServiceJob(soHeadersList, soliIdToSOLIRecordWithClaimLIMap, customerInvoiceRecord, entityType));
            }
            if(coKitHeadersList.size() > 0) {
            	xeroItemDtoList.addAll(setDataForKit(coKitHeadersList, customerInvoiceRecord, entityType));
            }
            if(dealItemList.size() > 0) {
            	xeroItemDtoList.addAll(setDataForDealItem(dealItemList, customerInvoiceRecord, entityType));
            }
            if(dealFIProductList.size() > 0) {
    			xeroItemDtoList.addAll(setDataForFIProducts(dealFIProductList, customerInvoiceRecord, entityType));
    		}
    	}
    	return xeroItemDtoList;
    }
    public static List<Object> setColiInvoiceItemRec(List<CO_Header__c> coHeadersList, AccountingCustomerInvoice customerInvoiceRecord, String entityType) {
    	List<Object> xeroItemDtoList = new List<Object>();
    	for(CO_Header__c coHeaderRec: coHeadersList) {
            for(CO_Line_Item__c coLIRec: coHeaderRec.CO_Line_Items__r) {
            	if(entityType == 'Invoice') {
            		xeroItemDtoList.add(new XeroLineItemDTO(coLIRec, customerInvoiceRecord));
            	} else { // We are assuming that entity type will be Invoice JE
            		setDataForColiJE(coLIRec, customerInvoiceRecord, xeroItemDtoList);	 
        		}
            }
        }
        return xeroItemDtoList;
    }
    
    public static List<Object> setDataForServiceJob(List<Service_Order_Header__c> soHeadersList, Map<Id, Service_Order_Line_Item__c> soliIdToSOLIRecordWithClaimLIMap, AccountingCustomerInvoice customerInvoiceRecord, String entityType) {
    	List<Object> xeroItemDtoList = new List<Object>();
    	for(Service_Order_Header__c soHeaderRec: soHeadersList) {
    		Boolean isInternalServiceJob = (soHeaderRec.Transaction_Type__r.Type__c != null && soHeaderRec.Transaction_Type__r.Type__c == 'Internal') ? true : false;
			Boolean isStockUnitServiceJob = (soHeaderRec.Transaction_Type__r.Type__c != null && soHeaderRec.Transaction_Type__r.Type__c == 'Stock Unit') ? true : false;
    		if((soHeaderRec.Transaction_Type__r.Type__c != null) && !(soHeaderRec.Transaction_Type__r.Type__c == 'Third-Party' && customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CheckoutType == 'Customer')) {
		        for(Service_Order_Line_Item__c soLIRec: soHeaderRec.Service_Order_Line_Items__r) {
		        	if(entityType == 'Invoice') {
            			xeroItemDtoList.add(new XeroLineItemDTO(soLIRec, customerInvoiceRecord));
	            	} else {
	            		setDataForSoliJE(soHeaderRec, soLIRec, customerInvoiceRecord, xeroItemDtoList);
	            		if(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CheckoutType == 'Third-Party' && soliIdToSOLIRecordWithClaimLIMap.containsKey(soLIRec.Id) 
                        	&& soliIdToSOLIRecordWithClaimLIMap.get(soLIRec.Id).Claim_Line_Items__r.size() > 0) {
                    		setDataForThirdPartyClaimVariance(soLIRec, soliIdToSOLIRecordWithClaimLIMap.get(soLIRec.Id), customerInvoiceRecord, xeroItemDtoList);
                    	}
            		}
		        }
		        if(entityType == 'Invoice' && customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CheckoutType == 'Third-Party') {
		        	List<Category__c> deductibleCategoryList = AccountingUtil.getSystemDefaultCategory('Deductible');
                    String deductibleGL = deductibleCategoryList.size() > 0 ? deductibleCategoryList[0].Income_GL__c : null;
                    AggregateResult[] result = [SELECT SUM(Total_Amount__c) FROM SO_Payment_Role__c WHERE Service_Order_Header__c =:soHeaderRec.Id AND RecordType.DeveloperName = 'Deductible'];
	                Decimal total = result[0].get('expr0') != null ? (Decimal)result[0].get('expr0') : 0;
                	xeroItemDtoList.add(new XeroLineItemDTO('Claim Deductible', total*-1, deductibleGL));
		        }
		        Boolean IsDealServiceJob = (soHeaderRec.Deal__c != null) ? true : false;
		        Decimal invoiceTotal = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.InvoiceTotal;
		        if(IsDealServiceJob) {
		        	String invoiceTotalDesc = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber +';' + customerInvoiceRecord.AccountingCOInvoiceHeaderRec.FormattedCustomerName +';' + customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COHeaderNumber;
			        invoiceTotalDesc = invoiceTotalDesc + ';Deal Service;' + customerInvoiceRecord.AccountingCOInvoiceItemsRecs[0].SKUNumberonDealService;
					String InventoryAccountCodeForDealServiceJob;
					if(soHeaderRec.Deal__r.Is_Deal_Fulfilled__c) {
					 	InventoryAccountCodeForDealServiceJob = AccountingUtil.getChartofAccount('Deal Option Clearing');
					} else {
					    InventoryAccountCodeForDealServiceJob = soHeaderRec.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;    
					}
					xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(invoiceTotal, InventoryAccountCodeForDealServiceJob, invoiceTotalDesc));
		        }
	    	}
	    	if(entityType == IntegrationUtility.CO_INVOICE_JE) {
	    		List<AccountingSalesTax> salesTaxList = getSalesTaxList(soHeaderRec.Id);
	    		Decimal invoiceTotal = (customerInvoiceRecord.AccountingCOInvoiceHeaderRec.InvoiceTotal).setScale(2, RoundingMode.HALF_UP);
	    		if(isStockUnitServiceJob) {
	    			for(AccountingSalesTax salesTax : salesTaxList) {
		        		xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(salesTax.SalesTaxAmount * -1, salesTax.CategoyRef, salesTax.SalesTaxName));
		    			xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(salesTax.SalesTaxAmount, soHeaderRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c, salesTax.SalesTaxName));
		        	}
			    	String invoiceTotalJEDesc = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber +';' + 'UNIT INVENTORY;' +
			    									customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COHeaderNumber + ';' + 'Internal Service;' 
			    									+ customerInvoiceRecord.AccountingCOInvoiceItemsRecs[0].SkuNumber;
			    	xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(invoiceTotal, soHeaderRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c, invoiceTotalJEDesc));
		    	} else if(isInternalServiceJob) {
		        	for(AccountingSalesTax salesTax : salesTaxList) {
		        		xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(salesTax.SalesTaxAmount * -1, salesTax.CategoyRef, salesTax.SalesTaxName));
		        	}
			    	String invoiceTotalJEDesc = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber +';'+
			    									customerInvoiceRecord.AccountingCOInvoiceHeaderRec.FormattedCustomerName +';' +
			    									customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COHeaderNumber + ';' + soHeaderRec.Transaction_Type__r.Code_Label__c + ';' 
			    									+ customerInvoiceRecord.AccountingCOInvoiceItemsRecs[0].VinNumber;
			    	xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(invoiceTotal, soHeaderRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c, invoiceTotalJEDesc));
		    	}
	    	}
    	}
        return xeroItemDtoList;
    }
    
    
    public static List<Object> setDataForKit(List<CO_Kit_Header__c> coKitHeadersList, AccountingCustomerInvoice customerInvoiceRecord, String entityType) {
    	List<Object> xeroItemDtoList = new List<Object>();
    	for(CO_Kit_Header__c coKitHeaderRec: coKitHeadersList) {
            for(CO_Line_Item__c coKitHeaderLIRec: coKitHeaderRec.CO_Line_Items__r) {
            	if(entityType == 'Invoice') {
            		xeroItemDtoList.add(new XeroLineItemDTO(coKitHeaderLIRec, customerInvoiceRecord));
            	} else if(coKitHeaderLIRec.Fee__c == null)  {
            		Decimal cost = 0;
					Decimal invoiceTotal = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.InvoiceTotal;
			        if(coKitHeaderLIRec.Part__c != null) {
						if(coKitHeaderLIRec.Adjusted_Cost_Coli__c == null || coKitHeaderLIRec.Adjusted_Cost_Coli__c == 0) { 
				            cost = (coKitHeaderLIRec.Part__r.Average_Cost__c != null) ? coKitHeaderLIRec.Part__r.Average_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0 ;
				        } else {
			            	cost = (coKitHeaderLIRec.Qty__c != null && coKitHeaderLIRec.Qty__c != 0) ? (coKitHeaderLIRec.Adjusted_Cost_Coli__c/coKitHeaderLIRec.Qty__c).setScale(2) : 0;  // Changed setScale(2) => setcale(3) rounding issue #3187
			        	}
			        }
			        
					String description = (coKitHeaderLIRec.Item_Code__c != null) ? coKitHeaderLIRec.Item_Code__c + '-' : '';
			        description += (coKitHeaderLIRec.Item_Description__c != null) ? coKitHeaderLIRec.Item_Description__c : '';
			        description += ';' + (coKitHeaderLIRec.Qty__c != null ? (invoiceTotal < 0 ? coKitHeaderLIRec.Qty__c*-1 : coKitHeaderLIRec.Qty__c) : 0) + ' @ ';
			        description += ' $' + cost;
					
					if(coKitHeaderLIRec.Part__c != null) {
						xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(cost, coKitHeaderLIRec.Part__r.Category__r.COGS_GL__c , description, QBUtil.nonTaxableCodeAccId, 0));
						xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(cost * -1, coKitHeaderLIRec.Part__r.Category__r.Inventory_GL__c , description, QBUtil.nonTaxableCodeAccId, 0));
					}
					Boolean IsDealMerch = coKitHeaderLIRec.Deal__c != null ? true : false;
					
					if(IsDealMerch) { // for deal merch and service we do not have taxes so Price include tax does not matter and only this price is populated so added this
			            Decimal price = 0;
						String accountCodeForIncomeGL,accountCodeForInventoryGL;
			            Boolean isDealInvoiced = IsDealMerch ? (coKitHeaderLIRec.Deal__r.Invoice_Number__r != null && coKitHeaderLIRec.Deal__r.Invoice_Number__r.CreatedDate < customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CreatedDate):false;
			            price = (coKitHeaderLIRec.Price__c != null ? coKitHeaderLIRec.Price__c : 0);
			            if(coKitHeaderLIRec.Part__c != null) {
			                accountCodeForIncomeGL = coKitHeaderLIRec.Part__r.Category__r.Income_GL__c;
			                accountCodeForInventoryGL = coKitHeaderLIRec.Part__r.Category__r.Inventory_GL__c;
			            } else if(coKitHeaderLIRec.Fee__c != null) {
			                accountCodeForIncomeGL = coKitHeaderLIRec.Fee__r.Category__r.Income_GL__c;
			                accountCodeForInventoryGL = coKitHeaderLIRec.Fee__r.Category__r.Inventory_GL__c;
			            }
			            
			            if(isDealInvoiced) {
							accountCodeForInventoryGL = AccountingUtil.getChartofAccount('Deal Option Clearing');
						} else {
							accountCodeForInventoryGL = coKitHeaderLIRec.Option_Fee__r.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
						}
			            description = (coKitHeaderLIRec.Item_Code__c != null) ? coKitHeaderLIRec.Item_Code__c + '-' : '';
			            description += (coKitHeaderLIRec.Item_Description__c != null) ? coKitHeaderLIRec.Item_Description__c : '';
			            description += ';' + (coKitHeaderLIRec.Qty__c != null ? (invoiceTotal < 0 ? coKitHeaderLIRec.Qty__c*-1 : coKitHeaderLIRec.Qty__c) : 0) + ' @ ';
			            description += ' $' + price;
			            price = price.setScale(2, RoundingMode.HALF_UP);
			            xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(price * -1 * coKitHeaderLIRec.Qty__c, accountCodeForIncomeGL , description));
			            xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(price * coKitHeaderLIRec.Qty__c, accountCodeForInventoryGL , description));
			        }
            	}
            }
    	}
    	return xeroItemDtoList;
    }
    
    private static void setDataForColiJE(CO_Line_Item__c coLIRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroItemDtoList) {
    	Decimal cost = 0, price = 0;
    	Boolean IsDealMerch = coLIRec.Deal__c != null ? true : false;
		Decimal invoiceTotal = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.InvoiceTotal;
		String accountCodeForIncomeGL, description, accountCodeForInventoryGL;
        if(coLIRec.Part__c != null) {
			if(coLIRec.Adjusted_Cost_Coli__c == null || coLIRec.Adjusted_Cost_Coli__c == 0) { 
	            cost = (coLIRec.Part__r.Average_Cost__c != null) ? coLIRec.Part__r.Average_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0 ;
	        } else {
            	cost = (coLIRec.Qty__c != null && coLIRec.Qty__c != 0) ? (coLIRec.Adjusted_Cost_Coli__c/coLIRec.Qty__c).setScale(2) : 0;  // Changed setScale(2) => setcale(3) rounding issue #3187
        	}
        }
        coliRec.Qty__c = coliRec.Qty__c != null ? coliRec.Qty__c.setScale(2, RoundingMode.HALF_UP) : 0;
        if(IsDealMerch) { // for deal merch and service we do not have taxes so Price include tax does not matter and only this price is populated so added this
            Boolean isDealInvoiced = IsDealMerch ? (coLIRec.Deal__r.Invoice_Number__r != null && coLIRec.Deal__r.Invoice_Number__r.CreatedDate < customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CreatedDate):false;
            price = (coLIRec.Price__c != null ? coLIRec.Price__c : 0);
            if(coLIRec.Part__c != null) {
                accountCodeForIncomeGL = coLIRec.Part__r.Category__r.Income_GL__c;
                accountCodeForInventoryGL = coLIRec.Part__r.Category__r.Inventory_GL__c;
            } else if(coLIRec.Fee__c != null) {
                accountCodeForIncomeGL = coLIRec.Fee__r.Category__r.Income_GL__c;
                accountCodeForInventoryGL = coLIRec.Fee__r.Category__r.Inventory_GL__c;
            }
            
            if(isDealInvoiced) {
				accountCodeForInventoryGL = AccountingUtil.getChartofAccount('Deal Option Clearing');
			} else {
				accountCodeForInventoryGL = coLIRec.Option_Fee__r.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
			}
            description = (coliRec.Item_Code__c != null) ? coliRec.Item_Code__c + '-' : '';
            description += (coliRec.Item_Description__c != null) ? coliRec.Item_Description__c : '';
            description += ';' + (coliRec.Qty__c != null ? (invoiceTotal < 0 ? coliRec.Qty__c*-1 : coliRec.Qty__c) : 0) + ' @ ';
            description += ' $' + price;
            price = price.setScale(2, RoundingMode.HALF_UP);
            xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(price * -1 * coliRec.Qty__c, accountCodeForIncomeGL , description));
            xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(price * coliRec.Qty__c, accountCodeForInventoryGL , description));
        } 
        
        
		description = (coLIRec.Item_Code__c != null) ? coLIRec.Item_Code__c + '-' : '';
        description += (coLIRec.Item_Description__c != null) ? coLIRec.Item_Description__c : '';
        description += ';' + (coLIRec.Qty__c != null ? (invoiceTotal < 0 ? coLIRec.Qty__c*-1 : coLIRec.Qty__c) : 0) + ' @ ';
        description += ' $' + cost;
		cost = cost.setScale(2, RoundingMode.HALF_UP);
		if(coLIRec.Part__c != null) {
			xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(cost * coliRec.Qty__c, coLIRec.Part__r.Category__r.COGS_GL__c , description, QBUtil.nonTaxableCodeAccId, 0));
			xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(cost * -1 * coliRec.Qty__c, coLIRec.Part__r.Category__r.Inventory_GL__c , description, QBUtil.nonTaxableCodeAccId, 0));
		}
    }
    
    private static void setDataForSoliJE(Service_Order_Header__c soHeaderRec, Service_Order_Line_Item__c soLIRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroItemDtoList) {
    	Boolean isInternalServiceJob = (soHeaderRec.Transaction_Type__r.Type__c != null && soHeaderRec.Transaction_Type__r.Type__c == 'Internal') ? true : false;
		Boolean isStockUnitServiceJob = (soHeaderRec.Transaction_Type__r.Type__c != null && soHeaderRec.Transaction_Type__r.Type__c == 'Stock Unit') ? true : false;
    	Boolean IsDealServiceJob = (soHeaderRec.Deal__c != null) ? true : false; 
    	Decimal price = 0;
    	Decimal priceIncludingTax = 0;
    	Decimal priceWithoutIncludingTax = 0;
		Decimal invoiceTotal = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.InvoiceTotal;
		Decimal cost = 0;
		Decimal lineItemTotalPrice = 0; 
		
		String COGSAccountCode;
		String InventoryAccountCode;
		String IncomeGLAccountCode;
		soLIRec.Tax_Percent__c = soLIRec.Tax_Percent__c != null ? soLIRec.Tax_Percent__c : 0;
		if(GeneralConfiguration.getTaxIncludingPricing()) {
	        price = (soLIRec.Price_When_Tax_Included__c != null ? soLIRec.Price_When_Tax_Included__c : 0).setScale(2, RoundingMode.HALF_UP);
	        priceIncludingTax = price;
	        priceWithoutIncludingTax = (price / (1 + (soLIRec.Tax_Percent__c / 100))).setScale(2, RoundingMode.HALF_UP);
	    } else {
	        price = (soLIRec.Kit_Price__c != null ? soLIRec.Kit_Price__c.setScale(2, RoundingMode.HALF_UP) : 0);
	        priceIncludingTax = (price + (price * soLIRec.Tax_Percent__c/100)).setScale(2, RoundingMode.HALF_UP);
	        priceWithoutIncludingTax = price;
	    }
	    
	    if(soLIRec.Part__c != null) {
	    	String accCodeCOGS = soLIRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.COGS_GL__c;
	    	COGSAccountCode = accCodeCOGS != null ? accCodeCOGS : soLIRec.Part__r.Category__r.COGS_GL__c;
	        InventoryAccountCode = soLIRec.Part__r.Category__r.Inventory_GL__c;
	        String accCodeIncomeGL = soLIRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c;
	        IncomeGLAccountCode = accCodeIncomeGL != null ? accCodeIncomeGL : soLIRec.Part__r.Category__r.Income_GL__c;
	        
	    	if(soLIRec.CO_Line_Item__r.Adjusted_Cost_Coli__c == null || soLIRec.CO_Line_Item__r.Adjusted_Cost_Coli__c == 0) { // soLIRec.Qty_Needed__c < 0 || removed for #3186
	            cost = (soLIRec.CO_Line_Item__r.Part__r.Average_Cost__c != null) ? soLIRec.CO_Line_Item__r.Part__r.Average_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0 ;
	        } else {
	            cost = (soLIRec.Qty_Needed__c != null && soLIRec.Qty_Needed__c != 0) ? (soLIRec.CO_Line_Item__r.Adjusted_Cost_Coli__c/soLIRec.Qty_Needed__c).setScale(2, RoundingMode.HALF_UP) : 0;  // Changed setScale(2) => setcale(3) rounding issue #3187
	        }
	    } else if(soLIRec.Labour_Code__c != null) {
	    	Decimal perItemCost = soLIRec.Labour_Code__r.Cost_Rate__c != null ? (soLIRec.Labour_Code__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP) : 0;
	    	if(soLIRec.Labour_Code__r.Cost_Method__c == 'Fixed Cost') {
	            cost = perItemCost;
	        } else if(soLIRec.Labour_Code__r.Cost_Method__c == 'Percent Retail') {
	            cost = (priceWithoutIncludingTax * perItemCost)/100;
	        }
	        
	        String accCodeCOGS = soLIRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.COGS_GL__c;
	    	COGSAccountCode = accCodeCOGS != null ? accCodeCOGS : soLIRec.Labour_Code__r.Category__r.COGS_GL__c;
	        InventoryAccountCode = soLIRec.Labour_Code__r.Category__r.Inventory_GL__c;
	        String accCodeIncomeGL = soLIRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c;
	        IncomeGLAccountCode = accCodeIncomeGL != null ? accCodeIncomeGL : soLIRec.Labour_Code__r.Category__r.Income_GL__c;
	        
	    } else if(soLIRec.Sublet__c != null) {
	    	Decimal perItemCost = 0;
	        if(soLIRec.Cost__c != null) {
	            cost = soLIRec.Cost__c;
	        } else {
	            perItemCost = soLIRec.Sublet__r.Cost__c != null ? soLIRec.Sublet__r.Cost__c : 0;
	            if(soLIRec.Sublet__r.Cost_Method__c == 'Fixed Cost') {
	                cost = perItemCost;
	            } else if(soLIRec.Sublet__r.Cost_Method__c == 'Percent Retail') {
	                cost = (priceWithoutIncludingTax * perItemCost)/100;
	            }
	        }
	        
	    	COGSAccountCode = soLIRec.Sublet__r.Category__r.COGS_GL__c;
	        InventoryAccountCode = soLIRec.Sublet__r.Category__r.Inventory_GL__c;
	        String accCodeIncomeGL = soLIRec.Service_Order_Header__r.Transaction_Type__r.Sublet_Category__r.Income_GL__c;
	        IncomeGLAccountCode = accCodeIncomeGL != null ? accCodeIncomeGL : soLIRec.Sublet__r.Category__r.Income_GL__c;
	    } else if(soLIRec.Fee__c != null) {
            Decimal perItemCost = soLIRec.Fee__r.Cost_Rate__c != null ? (soLIRec.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP) : 0;
            if(soLIRec.Fee__r.Cost_Method__c == 'Fixed Cost') {
                cost = perItemCost;
            } else if(soLIRec.Fee__r.Cost_Method__c == 'Percent Retail') {
                cost = (priceWithoutIncludingTax * perItemCost)/100;
            }
            COGSAccountCode = soLIRec.Fee__r.Category__r.COGS_GL__c;
            IncomeGLAccountCode = soLIRec.Fee__r.Category__r.Income_GL__c;
            InventoryAccountCode = soLIRec.Fee__r.Category__r.Inventory_GL__c;
        }
	    
	    String description = (soLIRec.Item_Code__c != null) ? soLIRec.Item_Code__c : '';
	    description += (soLIRec.Item_Description__c != null) ? ' - ' + soLIRec.Item_Description__c : '';
	    description += ';' + (soLIRec.Qty_Needed__c != null ? (invoiceTotal < 0 ? soLIRec.Qty_Needed__c*-1 : soLIRec.Qty_Needed__c).setScale(2, RoundingMode.HALF_UP) : 0) + ' @ $';
	    Decimal quantity = (soLIRec.Qty_Needed__c != null ? (soLIRec.Qty_Needed__c).setScale(2, RoundingMode.HALF_UP) : 0);
	    Decimal totalCost = (cost * quantity).setScale(2, RoundingMode.HALF_UP);
	    if(isStockUnitServiceJob) {
	    	String invoiceAmtJEDesc = description + (priceIncludingTax).setScale(2, RoundingMode.HALF_UP);
	    	description += (cost).setScale(2, RoundingMode.HALF_UP);
	    	lineItemTotalPrice = (quantity * priceIncludingTax).setScale(2, RoundingMode.HALF_UP);
	        
	        xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(lineItemTotalPrice * -1, IncomeGLAccountCode , invoiceAmtJEDesc));
	        xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(totalCost * -1, InventoryAccountCode, description));
	    	xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(totalCost, COGSAccountCode, description));
	    } else if(isInternalServiceJob) {
	    	String invoiceAmtJEDesc = description + (priceWithoutIncludingTax).setScale(2, RoundingMode.HALF_UP);
	    	description += (cost).setScale(2, RoundingMode.HALF_UP);
	    	lineItemTotalPrice = (quantity * priceWithoutIncludingTax).setScale(2, RoundingMode.HALF_UP);
	        
	        xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(lineItemTotalPrice * -1, IncomeGLAccountCode , invoiceAmtJEDesc));
	        xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(totalCost * -1, InventoryAccountCode, description));
	    	xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(totalCost, COGSAccountCode, description));
	    } else if(IsDealServiceJob) {
	    	Decimal totalPrice = soLIRec.Kit_Price__c.setScale(2, RoundingMode.HALF_UP);
	    	String invoiceAmtJEDesc = description + totalPrice;
	    	description = description + cost;
	    	lineItemTotalPrice = (quantity * totalPrice).setScale(2, RoundingMode.HALF_UP);
	        xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(lineItemTotalPrice * -1, IncomeGLAccountCode , invoiceAmtJEDesc));
	        xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(totalCost * -1, InventoryAccountCode, description));
	    	xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(totalCost, COGSAccountCode, description));
		} else if(soLIRec.Fee__c == null)   {
			description += ' ' + (cost).setScale(2, RoundingMode.HALF_UP);
	    	if(soLIRec.Part__c != null || soLIRec.Labour_Code__c != null || soLIRec.Sublet__c != null) {
		    	xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(totalCost, COGSAccountCode, description, QBUtil.nonTaxableCodeAccId, 0));
		    	xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(totalCost * -1, InventoryAccountCode , description, QBUtil.nonTaxableCodeAccId, 0));
	    	}
	    }
    }
    
    private static List<AccountingSalesTax> getSalesTaxList(String soHeaderId){
        Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>(); 
        Map<String, Sales_Tax_Item__c> salesTaxNameToSalesTax = new Map<String, Sales_Tax_Item__c>();  
        List<Sales_Tax_Item__c> salesTaxList = [SELECT AccountingId__c, Name__c, Category__r.Income_GL__c
                                                FROM Sales_Tax_Item__c where Active__c = true];
        
        for(Sales_Tax_Item__c STI : salesTaxList){
            salesTaxNameToSalesTax.put(STI.Name__c, STI);
        }
        List<Individual_Tax__c> individualItemsList = [select CO_Line_Item__c, Tax_Rate__c, Sales_Tax_Item_Name__c, 
                                                        Taxable_Amount__c, Tax_Amount__c,
                                                        Applicable_Tax__c, List_Tax_items_on_forms__c
                                                        from Individual_Tax__c where Service_Order_Line_Item__r.Service_Order_Header__c = :soHeaderId];
        
        salesTaxNameToTaxValue = TaxCalculation.getTaxAmount(individualItemsList);  
        List<AccountingSalesTax> taxDetails = new List<AccountingSalesTax>();
        for(String salesTaxName : salesTaxNameToTaxValue.keyset()){
            taxDetails.add(new AccountingSalesTax(salesTaxName, salesTaxNameToTaxValue.get(salesTaxName), salesTaxNameToSalesTax.get(salesTaxName).Category__r.Income_GL__c));
        }
        
        return taxDetails;
    }
    
    private static void setDataForThirdPartyClaimVariance(Service_Order_Line_Item__c soLIRec, Service_Order_Line_Item__c soliRecWithClaimLI, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroItemDtoList) {
    	String description = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.FormattedCustomerName;
    	description += customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COHeaderNumber != null ? ';' + customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COHeaderNumber : '';
    	description += ';Claim Variance';
    	description += (soLIRec.Item_Code__c != null) ? ';' + soLIRec.Item_Code__c : '';
	    description += (soLIRec.Item_Description__c != null) ? ' - ' + soLIRec.Item_Description__c : '';
	    
    	for(Claim_Line_Item__c billToInternalClaimLI : soliRecWithClaimLI.Claim_Line_Items__r) {
    		Decimal cost = billToInternalClaimLI.Total_Variance_Amount__c != null ? billToInternalClaimLI.Total_Variance_Amount__c : 0;
    		String incomeGLAccountCode;
    		if(soLIRec.Part__c != null) {
	    		incomeGLAccountCode = soLIRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c != null ? soLIRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c : soLIRec.Part__r.Category__r.Income_GL__c;
            } else if(soLIRec.Labour_Code__c != null) {
	    		incomeGLAccountCode = soLIRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c != null ? soLIRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c : soLIRec.Labour_Code__r.Category__r.Income_GL__c;
            } else if(soLIRec.Sublet__c != null) {
	    		incomeGLAccountCode = soLIRec.Sublet__r.Category__r.Income_GL__c;
            }
            if(soLIRec.Part__c != null || soLIRec.Labour_Code__c != null || soLIRec.Sublet__c != null) {
		    	xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(cost * -1, incomeGLAccountCode, description, QBUtil.nonTaxableCodeAccId, 0));
		    	xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(cost, billToInternalClaimLI.Category__r.Income_GL__c , description, QBUtil.nonTaxableCodeAccId, 0));
		    }
    	}
    }
    
    private static List<Object> setDataForDealItem(List<Deal_Item__c> dealItemList, AccountingCustomerInvoice customerInvoiceRecord, String entityType) {
    	List<Object> xeroItemDtoList = new List<Object>();
    	Map<String, List<Unit_Price_Cost__c>> dealItemIdToPriceCostListMap = AccountingUtil.setDealItemIdToPriceCostListMap(dealItemList);
    	String firstUnitSoldOnDealCategoryIncomeGLAccId;
    	for(Deal_Item__c dealItemRec : dealItemList) {
            if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_UNIT) {
                firstUnitSoldOnDealCategoryIncomeGLAccId = dealItemRec.Customer_Owned_Unit__r.Category__r.Income_GL__c != null ? dealItemRec.Customer_Owned_Unit__r.Category__r.Income_GL__c:  AccountingUtil.getSystemDefaultCategory('Unit')[0].Income_GL__c;
                break;
            }
        }
    	
    	for(Deal_Item__c dealItemRec: dealItemList) {
            if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
            	if(entityType == 'Invoice') {
            		setDataForTradeIn(dealItemRec, customerInvoiceRecord, xeroItemDtoList);
            	} else {
            		setDataForTradeInJE(dealItemRec, customerInvoiceRecord, xeroItemDtoList, firstUnitSoldOnDealCategoryIncomeGLAccId);
            	}
            } else {
            	if(entityType == 'Invoice') {
            		setDataForUnit(dealItemRec, customerInvoiceRecord, xeroItemDtoList);
            		
            		if(dealItemRec.Stamp_Duty_Total__c != null && dealItemRec.Stamp_Duty_Total__c != 0) {
            			setDataForStampDuty(dealItemRec, customerInvoiceRecord, xeroItemDtoList);
            		}
            	} else {
            		setDataForUnitJE(dealItemRec, customerInvoiceRecord, xeroItemDtoList, dealItemIdToPriceCostListMap);
            	}
            }
    	}
    	return xeroItemDtoList;
    }
    
    private static void setDataForTradeIn(Deal_Item__c dealItemRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroInvoiceLineItemDtoList) {
    	xeroInvoiceLineItemDtoList.add(new XeroLineItemDTO(dealItemRec, customerInvoiceRecord, 'Trade In'));
    	if(dealItemRec.Lien_Payout__c != null && dealItemRec.Lien_Payout__c > 0) {
    		xeroInvoiceLineItemDtoList.add(new XeroLineItemDTO(dealItemRec, customerInvoiceRecord, 'Lien Payout'));
    	}
    }
    
    private static void setDataForTradeInJE(Deal_Item__c dealItemRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroJEDtoList, String firstUnitSoldOnDealCategoryIncomeGLAccId) {
    	String description = 'Trade-in: ';
		description += dealItemRec.Stocked_In_Unit__r.Stock_Id__c != null ? dealItemRec.Stocked_In_Unit__r.Stock_Id__c + ';' : '';
		description += dealItemRec.Customer_Owned_Unit__r.Year__c != null ? dealItemRec.Customer_Owned_Unit__r.Year__c + ' ' : '';
		description += dealItemRec.Customer_Owned_Unit__r.Unit_Make__r.Name != null ? ' ' + dealItemRec.Customer_Owned_Unit__r.Unit_Make__r.Name : '';
		description += dealItemRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c != null ? ' ' + dealItemRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c : '';
		description += dealItemRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c != null ? ' ' + dealItemRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c : '';
		description += dealItemRec.Customer_Owned_Unit__r.VIN_Number__c != null ? ';' + dealItemRec.Customer_Owned_Unit__r.VIN_Number__c : '';
		
		Decimal agreedValue = (dealItemRec.Agreed_Value__c != null) ? dealItemRec.Agreed_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
        Decimal salesTaxPercentageOnAgreedValue = (dealItemRec.Default_Unit_Sales_Tax_Percentage__c != null) ? dealItemRec.Default_Unit_Sales_Tax_Percentage__c : 0;
        Decimal preTaxAgreedValue = customerInvoiceRecord.isTaxIncludingPricing ? (agreedValue / (1 + (salesTaxPercentageOnAgreedValue / 100))).setScale(2, RoundingMode.HALF_UP) : agreedValue;
        Decimal variance = preTaxAgreedValue - dealItemRec.Actual_Cash_Value__c;
		String accountCode;
		
		
		
		if(!dealItemRec.Is_Stocked_In__c && variance == 0) {
			accountCode = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null ? dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c : AccountingUtil.getSystemDefaultCategory('Unit')[0].Inventory_GL__c;
            xeroJEDtoList.add(new XeroJournalEntryDTO.JournalLines(dealItemRec.Actual_Cash_Value__c.setScale(2, RoundingMode.HALF_UP), accountCode , description, QBUtil.nonTaxableCodeAccId, 0));
	    	
	    	accountCode = AccountingUtil.getSystemDefaultCategory('Stocked Trade').size() > 0 ? AccountingUtil.getSystemDefaultCategory('Stocked Trade')[0].Income_GL__c : '';
	    	xeroJEDtoList.add(new XeroJournalEntryDTO.JournalLines(dealItemRec.Actual_Cash_Value__c.setScale(2, RoundingMode.HALF_UP) * -1, accountCode , description, QBUtil.nonTaxableCodeAccId, 0));
        } else if(!dealItemRec.Is_Stocked_In__c && variance != 0) {
            accountCode = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null ? dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c : AccountingUtil.getSystemDefaultCategory('Unit')[0].Inventory_GL__c;
            xeroJEDtoList.add(new XeroJournalEntryDTO.JournalLines(dealItemRec.Actual_Cash_Value__c.setScale(2, RoundingMode.HALF_UP), accountCode , description, QBUtil.nonTaxableCodeAccId, 0));
            
            xeroJEDtoList.add(new XeroJournalEntryDTO.JournalLines(variance.setScale(2, RoundingMode.HALF_UP), firstUnitSoldOnDealCategoryIncomeGLAccId , description, QBUtil.nonTaxableCodeAccId, 0));
            
            accountCode = AccountingUtil.getSystemDefaultCategory('Stocked Trade').size() > 0 ? AccountingUtil.getSystemDefaultCategory('Stocked Trade')[0].Income_GL__c : '';
            xeroJEDtoList.add(new XeroJournalEntryDTO.JournalLines(preTaxAgreedValue.setScale(2, RoundingMode.HALF_UP) * -1, accountCode , description, QBUtil.nonTaxableCodeAccId, 0));
        } else if(dealItemRec.Is_Stocked_In__c && variance != 0) {
        	xeroJEDtoList.add(new XeroJournalEntryDTO.JournalLines(variance.setScale(2, RoundingMode.HALF_UP), firstUnitSoldOnDealCategoryIncomeGLAccId , description, QBUtil.nonTaxableCodeAccId, 0));
        	
        	accountCode = AccountingUtil.getSystemDefaultCategory('Stocked Trade').size() > 0 ? AccountingUtil.getSystemDefaultCategory('Stocked Trade')[0].Income_GL__c : '';
	    	xeroJEDtoList.add(new XeroJournalEntryDTO.JournalLines(variance.setScale(2, RoundingMode.HALF_UP) * -1, accountCode , description, QBUtil.nonTaxableCodeAccId, 0));
        }
    }
    
    private static void setDataForOptionAndFees(Deal_Item__c dealItemRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroInvoiceLineItemDtoList) {
    	for(Option_Fee__c optionAndFee : dealItemRec.Options_Fees__r) {
    		xeroInvoiceLineItemDtoList.add(new XeroLineItemDTO(dealItemRec, optionAndFee, customerInvoiceRecord));
    	}
    }
    
    private static void setDataForOptionAndFeesJE(Deal_Item__c dealItemRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroJournalLineDtoList) {
		for(Option_Fee__c optionAndFee : dealItemRec.Options_Fees__r) {
            Decimal cost = 0, price = 0, total = 0;
            if(GeneralConfiguration.getTaxIncludingPricing()) {
                price = (optionAndFee.Price_When_Tax_Included__c != null ? optionAndFee.Price_When_Tax_Included__c : 0);
            } else {
                price = (optionAndFee.Price__c != null ? optionAndFee.Price__c : 0);
            }
            String COGS_GL, Inventory_GL;
            COGS_GL = optionAndFee.Deal_Item__r.Customer_Owned_Unit__r.Category__r.COGS_GL__c;
            if(optionAndFee.Deal__r.Is_Deal_Fulfilled__c) {
                Inventory_GL = optionAndFee.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;    
            } else {
                Inventory_GL = AccountingUtil.getChartofAccount('Deal Option Clearing');
            }
                
            if(optionAndFee.Part__c != null) {
                if(optionAndFee.Deal__r.Is_Deal_Fulfilled__c) {
                    cost = (optionAndFee.Per_Item_Cost__c != null ? optionAndFee.Per_Item_Cost__c : 0);
                } else {
                    if(GeneralConfiguration.getTaxIncludingPricing()) {
                        cost = (optionAndFee.Price_When_Tax_Included__c != null ? optionAndFee.Price_When_Tax_Included__c : 0);
                    } else {
                        cost = (optionAndFee.Price__c != null ? optionAndFee.Price__c : 0);
                    }
                    COGS_GL = optionAndFee.Part__r.Category__r.COGS_GL__c;
                }
            } else if(optionAndFee.Fee__c != null) {
                COGS_GL = optionAndFee.Fee__r.Category__r.COGS_GL__c;
                Inventory_GL = optionAndFee.Fee__r.Category__r.Inventory_GL__c;
                Decimal perItemCost = optionAndFee.Fee__r.Cost_Rate__c != null ? optionAndFee.Fee__r.Cost_Rate__c : 0;
                if(optionAndFee.Fee__r.Cost_Method__c == 'Fixed Cost') {
                    cost = perItemCost;
                } else if(optionAndFee.Fee__r.Cost_Method__c == 'Percent Retail') {
                    cost = (price * perItemCost)/100;
                }
            } else if(optionAndFee.Labour_Code__c != null) {
                if(optionAndFee.Deal__r.Is_Deal_Fulfilled__c) {
                    cost = (optionAndFee.Per_Item_Cost__c != null ? optionAndFee.Per_Item_Cost__c : 0);
                } else {
                    if(GeneralConfiguration.getTaxIncludingPricing()) {
                        cost = (optionAndFee.Price_When_Tax_Included__c != null ? optionAndFee.Price_When_Tax_Included__c : 0);
                    } else {
                        cost = (optionAndFee.Price__c != null ? optionAndFee.Price__c : 0);
                    }
                    COGS_GL = optionAndFee.Labour_Code__r.Category__r.COGS_GL__c;
                }
            } else if(optionAndFee.Product__c != null) {
                if(optionAndFee.Product__r.Type__c == Constants.SUBLET) {
                    if(optionAndFee.Deal__r.Is_Deal_Fulfilled__c) {
                        cost = (optionAndFee.Per_Item_Cost__c != null ? optionAndFee.Per_Item_Cost__c : 0);
                    } else {
                        if(GeneralConfiguration.getTaxIncludingPricing()) {
                            cost = (optionAndFee.Price_When_Tax_Included__c != null ? optionAndFee.Price_When_Tax_Included__c : 0);
                        } else {
                            cost = (optionAndFee.Price__c != null ? optionAndFee.Price__c : 0);
                        }
                        COGS_GL = optionAndFee.Product__r.Category__r.COGS_GL__c;
                    }
                } else {
                    COGS_GL = optionAndFee.Product__r.Category__r.COGS_GL__c;
                    Inventory_GL = optionAndFee.Product__r.Category__r.Inventory_GL__c;
                    Decimal perItemCost = optionAndFee.Product__r.Cost__c != null ? optionAndFee.Product__r.Cost__c : 0;
                    if(optionAndFee.Product__r.Cost_Method__c == 'Fixed Cost') {
                        cost = perItemCost;
                    } else if(optionAndFee.Product__r.Cost_Method__c == 'Percent Retail') {
                        cost = (price * perItemCost)/100;
                    }
                }
            }
            optionAndFee.Qty__c = (optionAndFee.Qty__c != null ? optionAndFee.Qty__c.setScale(2, RoundingMode.HALF_UP) : 1);
            cost = cost.setScale(2, RoundingMode.HALF_UP);
            String description = 'Option: ';
	    	description +=  (optionAndFee.Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c != null ? optionAndFee.Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c + ';' : '');
	    	description +=  (optionAndFee.Item_Code__c != null) ? optionAndFee.Item_Code__c : '';
	    	description +=  ((optionAndFee.Item_Description__c != null) ? ' - ' + optionAndFee.Item_Description__c   : '') + ';';
	    	description +=  optionAndFee.Qty__c + ' @ $' + cost;
            
            if(optionAndFee.Part__c != null || optionAndFee.Labour_Code__c != null || optionAndFee.Product__c != null) {
                xeroJournalLineDtoList.add(new XeroJournalEntryDTO.JournalLines(cost * optionAndFee.Qty__c, COGS_GL , description, QBUtil.nonTaxableCodeAccId, 0));
            	xeroJournalLineDtoList.add(new XeroJournalEntryDTO.JournalLines(cost * -1 * optionAndFee.Qty__c, Inventory_GL , description, QBUtil.nonTaxableCodeAccId, 0));
            }
        }
	}
    
     private static List<Object> setDataForFIProducts(List<F_I_Product__c> dealFIProductList, AccountingCustomerInvoice customerInvoiceRecord, String entityType) {
    	List<Object> xeroItemDtoList = new List<Object>();
    	if(entityType == 'Invoice') {
    		for(F_I_Product__c fiProduct : dealFIProductList) {
	    		xeroItemDtoList.add(new XeroLineItemDTO(fiProduct, customerInvoiceRecord));
	    	}
    	} else {
            for(F_I_Product__c FIProduct : dealFIProductList) {
                String description = 'Financing: ' +  FIProduct.Item_Description__c;
                Decimal price = (FIProduct.Price__c != null ? FIProduct.Price__c : 0);
                Decimal cost = 0;
                Decimal perItemCost = FIProduct.Vendor_Product__r.Cost__c != null ? FIProduct.Vendor_Product__r.Cost__c : 0;
                if(FIProduct.Vendor_Product__r.Cost_Method__c == 'Fixed Cost') {
                    cost = perItemCost;
                } else if(FIProduct.Vendor_Product__r.Cost_Method__c == 'Percent Retail') {
                    cost = (price * perItemCost)/100;
                }
                xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(cost, FIProduct.Vendor_Product__r.Category__r.COGS_GL__c , description, QBUtil.nonTaxableCodeAccId, 0));
            	xeroItemDtoList.add(new XeroJournalEntryDTO.JournalLines(cost * -1, FIProduct.Vendor_Product__r.Category__r.Inventory_GL__c , description, QBUtil.nonTaxableCodeAccId, 0));
            }
    	}
    	
    	return xeroItemDtoList;
    }
    
    private static void setDataForStampDuty(Deal_Item__c dealItemRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroInvoiceLineItemDtoList) {
		xeroInvoiceLineItemDtoList.add(new XeroLineItemDTO(dealItemRec, customerInvoiceRecord, 'Stamp Duty'));
    }
    
    private static void setDataForUnit(Deal_Item__c dealItemRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroInvoiceLineItemDtoList) {
    	setDataForUnitPriceAndCosts(dealItemRec, customerInvoiceRecord, xeroInvoiceLineItemDtoList);
    	setDataForOptionAndFees(dealItemRec, customerInvoiceRecord, xeroInvoiceLineItemDtoList);
    }
    
    private static void setDataForUnitJE(Deal_Item__c dealItemRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroInvoiceLineItemDtoList, Map<String, List<Unit_Price_Cost__c>> dealItemIdToPriceCostListMap) {
    	setDataForUnitPriceAndCostsJE(dealItemRec, customerInvoiceRecord, xeroInvoiceLineItemDtoList, dealItemIdToPriceCostListMap);
    	setDataForOptionAndFeesJE(dealItemRec, customerInvoiceRecord, xeroInvoiceLineItemDtoList);
    }
    
    private static List<Object> setDataForUnitPriceAndCosts(Deal_Item__c dealItemRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroInvoiceLineItemDtoList) {
    	for(Deal_Unit_Price_Cost__c dealUnitPriceandCost : dealItemRec.Deal_Unit_Prices_Costs__r){
            xeroInvoiceLineItemDtoList.add(new XeroLineItemDTO(dealItemRec, dealUnitPriceandCost, customerInvoiceRecord));
        }
        return xeroInvoiceLineItemDtoList;
    }
    
    private static List<Object> setDataForUnitPriceAndCostsJE(Deal_Item__c dealItemRec, AccountingCustomerInvoice customerInvoiceRecord, List<Object> xeroJournalLineDtoList, Map<String, List<Unit_Price_Cost__c>> dealItemIdToPriceCostListMap) {
        for(Deal_Unit_Price_Cost__c dealUnitPriceandCost : dealItemRec.Deal_Unit_Prices_Costs__r) {
	    	
	    	Decimal qty = (dealUnitPriceandCost.Qty__c != null && dealUnitPriceandCost.Qty__c != 0) ? (dealUnitPriceandCost.Qty__c).setScale(2, RoundingMode.HALF_UP) : 1;
            dealUnitPriceandCost.Unit_Price_Cost__r.Total_Cost__c = dealUnitPriceandCost.Unit_Price_Cost__r.Total_Cost__c != null ? (dealUnitPriceandCost.Unit_Price_Cost__r.Total_Cost__c).setScale(2, RoundingMode.HALF_UP) : 0;
            dealUnitPriceandCost.Unit_Price_Cost__r.Total_Price__c = dealUnitPriceandCost.Unit_Price_Cost__r.Total_Price__c != null ? (dealUnitPriceandCost.Unit_Price_Cost__r.Total_Price__c).setScale(2, RoundingMode.HALF_UP) : 0;
	    	Decimal cost = 0;
	    	
	    	String description = 'Unit: ';
	    	description += dealItemRec.Customer_Owned_Unit__r.Stock_Id__c != null ? dealItemRec.Customer_Owned_Unit__r.Stock_Id__c + ';' : '';
	    	if(dealUnitPriceandCost.Type__c == 'Base') {
	    		description += dealItemRec.Customer_Owned_Unit__r.Year__c != null ? dealItemRec.Customer_Owned_Unit__r.Year__c + ' ' : '';
	    		description += dealItemRec.Customer_Owned_Unit__r.Unit_Make__r.Name != null ? ' ' + dealItemRec.Customer_Owned_Unit__r.Unit_Make__r.Name : '';
	    		description += dealItemRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c != null ? ' ' + dealItemRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c : '';
	    		description += dealItemRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c != null ? ' ' + dealItemRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c : '';
	    		description += dealItemRec.Customer_Owned_Unit__r.VIN_Number__c != null ? ';' + dealItemRec.Customer_Owned_Unit__r.VIN_Number__c : '';
	    		for(Unit_Price_Cost__c unitPriceCostRec : dealItemIdToPriceCostListMap.get(dealItemRec.Id)) {
	            	if(unitPriceCostRec.Type__c == 'Base') {
	            		Decimal qtyOfUnitPrice = (unitPriceCostRec.Qty__c != null && unitPriceCostRec.Qty__c != 0) ? unitPriceCostRec.Qty__c : 1;
		                unitPriceCostRec.Total_Cost__c = unitPriceCostRec.Total_Cost__c != null ? unitPriceCostRec.Total_Cost__c : 0;
		                cost += (unitPriceCostRec.Cost__c != null) ? unitPriceCostRec.Cost__c : (unitPriceCostRec.Total_Cost__c/qtyOfUnitPrice);
	            	}
	            }
	    	} else {
	    		description += dealUnitPriceandCost.Item_Description__c;
	    		cost = (dealUnitPriceandCost.Unit_Price_Cost__r.Cost__c != null) ? (dealUnitPriceandCost.Unit_Price_Cost__r.Cost__c).setScale(2, RoundingMode.HALF_UP) : (dealUnitPriceandCost.Unit_Price_Cost__r.Total_Cost__c/qty).setScale(2, RoundingMode.HALF_UP);
	    	}
            
            Decimal totalcost = qty * cost;
            
            xeroJournalLineDtoList.add(new XeroJournalEntryDTO.JournalLines(totalcost, dealItemRec.Customer_Owned_Unit__r.Category__r.COGS_GL__c , description, QBUtil.nonTaxableCodeAccId, 0));
            xeroJournalLineDtoList.add(new XeroJournalEntryDTO.JournalLines(totalcost * -1, dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c , description, QBUtil.nonTaxableCodeAccId, 0));
        }
        return xeroJournalLineDtoList;
    }
    
    private static List<CO_Header__c> getCustomerOrderHeaders(List<Id> coIdsList, List<Id> coliIds) {
        List<CO_Header__c> coHeadersList = new List<CO_Header__c>();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
       
        if(coIdsList != null && coIdsList.size() > 0) {
            String query = 'SELECT ';
            for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('COHeader')){
                fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                query += fieldsName + ', ';
            }
            query += '(SELECT ';
            for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('COLineItem')){
                fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                query += fieldsName + ', ';
            }
            query = query.substring(0, query.length()-2);
            
            query += ' FROM CO_Line_Items__r WHERE Service_Order_Line_Item__c = NULL AND Id IN: coliIds) FROM CO_Header__c WHERE Id IN: coIdsList';
            coHeadersList = Database.query(query);
        }
        return coHeadersList;
    }
    
    private static List<Service_Order_Header__c> getServiceOrderHeaders(List<Id> coIdsList, List<Id> sohIds) {
        List<Service_Order_Header__c> soHeadersList = new List<Service_Order_Header__c>();
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(coIdsList != null && coIdsList.size() > 0) {
            soHeadersList = [SELECT Name__c, Total__c, Correction__c, Cause__c, Concern__c, Customer_Owned_Unit__c, Customer_Owned_Unit__r.VIN_Number__c,
                                    Customer_Owned_Unit__r.Unit_Make__r.Name, Customer_Owned_Unit__r.Unit_Model__r.Name__c, Customer_Owned_Unit__r.Year__c,
                                    Odometer_on_Arrival__c, Odometer_on_Departure__c, CO_Header__c, Notes_For_Customer__c, Transaction_Type__r.Type__c,
                                    Transaction_Type__r.Part_Category__r.AccountingId__c, Transaction_Type__r.Part_Category__r.Name,Transaction_Type__r.Code_Label__c,Deal__c,
                                    Transaction_Type__r.Labour_Category__r.AccountingId__c, Transaction_Type__r.Labour_Category__r.Name,Customer_Owned_Unit__r.Category__r.Inventory_GL__c,
                                    Deal__r.Is_Deal_Fulfilled__c,Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c,
                                    (SELECT Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c,
                                    		Service_Order_Header__r.Transaction_Type__r.Part_Category__r.COGS_GL__c,
                                    		Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Inventory_GL__c,
                                    		Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c,
                                    		Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.COGS_GL__c,
                                    		Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Inventory_GL__c,
                                    		Service_Order_Header__r.Transaction_Type__r.Sublet_Category__r.Income_GL__c,
                                    		Service_Order_Header__r.Transaction_Type__r.Sublet_Category__r.COGS_GL__c,
                                    		Service_Order_Header__r.Transaction_Type__r.Sublet_Category__r.Inventory_GL__c,Cost__c,
                                    		Item_Code__c, Item_Description__c, Item_Desc__c, Kit_Price__c, Labour_Code__c, Part__c, Qty_Needed__c, Total__c,
                                    		Fee__r.Cost_Rate__c,Fee__r.Cost_Method__c,
                                    		Labour_Code__r.Cost_Rate__c, Labour_Code__r.Cost_Method__c, 
                                            Price_When_Tax_Included__c, Fee__c, Tax_Percent__c, Tax_Amount__c, Part__r.Taxable__c, Part__r.Category__c,
                                            Part__r.Category__r.AccountingId__c, Part__r.Category__r.Name, Fee__r.Taxable__c, Fee__r.Category__c,
                                            Fee__r.Category__r.AccountingId__c, Fee__r.Category__r.Name, Labour_Code__r.Taxable__c,
                                            Labour_Code__r.Category__c, Labour_Code__r.Category__r.AccountingId__c, Labour_Code__r.Category__r.Name,
                                            Sublet__c, Sublet__r.Cost__c, Sublet__r.Cost_Method__c, Sublet__r.Category__c, Sublet__r.Category__r.AccountingId__c, Sublet__r.Category__r.Name,
                                            Applicable_Tax__c, Applicable_Tax__r.Accounting_Id__c, Part__r.Category__r.Income_GL__c,Part__r.Category__r.COGS_GL__c,Part__r.Category__r.Inventory_GL__c,
                                            Labour_Code__r.Category__r.COGS_GL__c,Labour_Code__r.Category__r.Inventory_GL__c,Sublet__r.Category__r.COGS_GL__c,Sublet__r.Category__r.Inventory_GL__c, 
                                            Labour_Code__r.Category__r.Income_GL__c, Fee__r.Category__r.Income_GL__c, Fee__r.Category__r.COGS_GL__c, Fee__r.Category__r.Inventory_GL__c, Sublet__r.Category__r.Income_GL__c,
                                            CO_Line_Item__r.Adjusted_Cost_Coli__c, CO_Line_Item__r.Part__r.Average_Cost__c,Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c,Deal__r.Is_Deal_Fulfilled__c
                                            FROM Service_Order_Line_Items__r )
                                    FROM Service_Order_Header__c WHERE Id IN: sohIds ];
        }
        return soHeadersList;
    }
    
    private static Map<Id, Service_Order_Line_Item__c> getSoliIdToSOLIRecordWithClaimLIMap(List<Id> sohIds) { 
    	Map<ID, Service_Order_Line_Item__c> soliIdToSOLIRecordWithClaimLIMap = new Map<ID, Service_Order_Line_Item__c>([SELECT Id, Service_Order_Header__r.Provider__r.Name, 
    																	Service_Order_Header__r.CO_Header__r.Name, (SELECT Total_Variance_Amount__c, Category__r.COGS_GL__c, 
    																	Category__r.Income_GL__c, Category__r.Inventory_GL__c FROM Claim_Line_Items__r 
    																	WHERE SO_Payment_Role__r.RecordType.DeveloperName = 'Internal') FROM Service_Order_Line_Item__c WHERE Service_Order_Header__c IN: sohIds]);
    	return soliIdToSOLIRecordWithClaimLIMap;
    }
    
    private static List<CO_Kit_Header__c> getKitHeaders(List<Id> coIdsList, List<Id> cokhIds) {
        List<CO_Kit_Header__c> coKitHeadersList = new List<CO_Kit_Header__c>();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(coIdsList != null && cokhIds.size() > 0) {
            coKitHeadersList = [SELECT CO_Header__c, Kit_Header__c, Price__c, Tax_Amount__c, Actual_Kit_Price__c, CreatedDate, Kit_Header__r.Kit_Unique_Name__c,
                                    Can_Split__c, Service_Kit__c, Fixed_Price_Flag__c, CO_Fixed_KitHeader__c, Deal_Kit_Header__c, Deal_Kit_Header__r.Deal_Item__c, Deal_Kit_Header__r.Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c,
                                    (SELECT Name, Item_ID__c, CO_Header__c, CO_Header__r.Name, CO_Header__r.Customer__c, CO_Header__r.Customer__r.Name,
                                            CO_Header__r.Owner__c, CO_Header__r.Owner__r.Name, CO_Header__r.Order_status__c, Qty__c, Qty_Committed__c,
                                            Item_Code__c, Item_Description__c, Price__c, Part__r.Name, Part__r.Part_Id__c, Part__r.Part_Number__c,
                                            Part__r.Description__c, Part__r.AvailableParts__c, Part__r.Vendor__c, Special_Order__c, Tax__c, Retail__c,
                                            Closed_CO_Invoice_link__c, VO_Number__c, VO_Status__c, Expected_Delivery_Date__c, CreatedDate, Fee__c,
                                            Fee__r.Fee_Unique_Name__c, Fixed_Price__c, CO_Fixed_KitLineItem__c, Actual_Kit_Price__c, Kit_Price_With_Price_Level__c,
                                            CO_Kit_Header__r.Id, Sub_Total_With_Tax__c, Sub_Total_Without_Tax__c, Price_When_Tax_Included__c, Tax_Amount__c,
                                            Oversold_Qty__c, Is_Temporary__c, Part__r.Taxable__c, Part__r.Category__c, Part__r.Category__r.AccountingId__c,
                                            Part__r.Category__r.Name, Fee__r.Taxable__c, Fee__r.Category__c, Fee__r.Category__r.AccountingId__c,
                                            Fee__r.Category__r.Name, Applicable_Tax__c, Applicable_Tax__r.Accounting_Id__c,
                                            Part__r.Category__r.Income_GL__c, Adjusted_Cost_Coli__c, Part__r.Category__r.COGS_GL__c,
                                            Part__r.Category__r.Inventory_GL__c,  Fee__r.Category__r.Income_GL__c,
                                            Deal__c, Option_Fee__r.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c,
                                            Fee__r.Category__r.Inventory_GL__c, Deal__r.Invoice_Number__r.CreatedDate
                                            FROM CO_Line_Items__r WHERE Is_In_Service_Order__c = false)
                                    FROM CO_Kit_Header__c WHERE Id IN: cokhIds];
        }
        return coKitHeadersList;
    }
    
    private static List<Deal_Item__c> getDealHeaders(List<Id> coIdsList, List<Id> dealIds) {
        List<Deal_Item__c> dealItemList = new List<Deal_Item__c>();
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(dealIds != null && dealIds.size() > 0) {
            String query = 'SELECT Id, (SELECT Id FROM Deal_Items__r), ';
            // Child Query For Deal F&I Products
            query += '(SELECT ';
            for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('DealFIProduct')){
                fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                query += fieldsName + ', ';
            }
            query = query.substring(0, query.length()-2);
            query += ' FROM F_I_Products__r) FROM Deal__c WHERE Id IN: dealIds';
            
            List<Deal__c> dealList = Database.query(query);
            if(dealList.size() > 0) {
                Set<String> dealItemId = new Set<String>();
                for(Deal__c dealRec : dealList) {
                    for(Deal_Item__c dealItemRec : dealRec.Deal_Items__r) {
                        dealItemId.add(dealItemRec.Id);
                    }
                    
                    if(dealIdToFIProductsMap != null) {
                        dealIdToFIProductsMap.put(dealRec.Id, dealRec.F_I_Products__r);
                    }
                }
                query = 'SELECT ';
                for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('DealItems')){
                    fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                    query += fieldsName + ', ';
                }
                query += '(SELECT ';
                for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('OptionAndFees')){
                    fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                    query += fieldsName + ', ';
                }
                query = query.substring(0, query.length() - 2);
                query += ' FROM Options_Fees__r), ';
                query += '(SELECT ';
                
                for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('DealUnitPriceCost')){
                    fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                    query += fieldsName + ', ';
                }
                query = query.substring(0, query.length()-2);
                query += ' FROM Deal_Unit_Prices_Costs__r) FROM Deal_Item__c WHERE Id IN: dealItemId';
                dealItemList = Database.query(query);
            }
        }
        return dealItemList;
    }
    
    public class AccountingSalesTax {
        public String SalesTaxName {get; set;}        
        public Decimal SalesTaxAmount {get; set;}       
        public String CategoyRef {get; set;}
        
        // Constructor
        public AccountingSalesTax(String SalesTaxName, Decimal SalesTaxAmount, String CategoyRef) { 
            this.SalesTaxName = SalesTaxName;
            this.SalesTaxAmount = SalesTaxAmount;
            this.CategoyRef = CategoyRef;
        }
    }	
}