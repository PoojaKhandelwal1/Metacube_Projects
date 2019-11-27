public without sharing class XeroJournalEntryDTO {
	public String SFId;
	public String ManualJournalID;
	public String JournalDate;
	public String Status = 'POSTED';
	public String Narration;
	public String Url;
	public List<JournalLines> JournalLines;
	public Decimal Quantity;

	public class JournalLines {
		public Decimal LineAmount;
		public String AccountCode;
		public String Description;
		public String TaxType;
		public Decimal TaxAmount;
		
		public JournalLines(Decimal LineAmount, String AccountCode, String Description) {
			this.LineAmount = LineAmount;
			this.AccountCode = AccountCode;
			this.Description = Description;
		}
		
		public JournalLines(Decimal LineAmount, String AccountCode, String Description, String TaxType, Decimal TaxAmount) {
			this.LineAmount = LineAmount;
			this.AccountCode = AccountCode;
			this.Description = Description;
			this.TaxType = TaxType;
			this.TaxAmount = TaxAmount;
		}
	}
	
	public XeroJournalEntryDTO(AccountingFIFOBucket accountingFIFOBucketRec) {
		this.SFId = accountingFIFOBucketRec.Id;
		this.JournalLines =  new List<JournalLines>();
		this.ManualJournalID = accountingFIFOBucketRec.AccountingId;
		this.JournalDate = String.ValueOf(accountingFIFOBucketRec.CreatedDate);
		this.Status = 'POSTED';
		this.Narration = accountingFIFOBucketRec.UniqueId + ';' + accountingFIFOBucketRec.PartNumber + ';' + accountingFIFOBucketRec.Reference;
		this.Url = AccountingUtil.getURL(accountingFIFOBucketRec.PartId, 'ViewPart');
		
		Decimal cost = accountingFIFOBucketRec.Cost != null ? accountingFIFOBucketRec.Cost.setScale(2, RoundingMode.HALF_UP) : 0;
		String description = accountingFIFOBucketRec.PartNumber + ' - increased by '+ accountingFIFOBucketRec.QtyIn + '@$' + cost;
		Decimal totalCost = accountingFIFOBucketRec.Total != null ? accountingFIFOBucketRec.Total.setScale(2, RoundingMode.HALF_UP) : 0;
		
		this.JournalLines.add(new JournalLines(totalCost, accountingFIFOBucketRec.Inventory_GL,  description));
		this.JournalLines.add(new JournalLines(totalCost * -1, AccountingUtil.getChartofAccount('Inventory Adjustments'),  description));
	}
	
	public XeroJournalEntryDTO(AccountingFIFOBucketActivityLineItem accountingFIFOBucketActivityLineItemRec) {
		this.SFId = accountingFIFOBucketActivityLineItemRec.Id;
		this.JournalLines =  new List<JournalLines>();
		this.ManualJournalID = accountingFIFOBucketActivityLineItemRec.AccountingId;
		this.JournalDate = String.ValueOf(accountingFIFOBucketActivityLineItemRec.CreatedDate);
		this.Status = 'POSTED';
		accountingFIFOBucketActivityLineItemRec.QtyOut = accountingFIFOBucketActivityLineItemRec.QtyOut != null ? accountingFIFOBucketActivityLineItemRec.QtyOut.setScale(2, RoundingMode.HALF_UP) : accountingFIFOBucketActivityLineItemRec.QtyOut;
		Decimal cost = accountingFIFOBucketActivityLineItemRec.Cost != null  ? accountingFIFOBucketActivityLineItemRec.Cost.setScale(2, RoundingMode.HALF_UP) : 0;
        Decimal totalCost = (cost * accountingFIFOBucketActivityLineItemRec.QtyOut).setScale(2, RoundingMode.HALF_UP);
		if(accountingFIFOBucketActivityLineItemRec.Reference == 'Vendor Return' && String.isNotBlank(accountingFIFOBucketActivityLineItemRec.ReturnVOHeaderId)) {
		    this.Narration = accountingFIFOBucketActivityLineItemRec.UniqueId+';'
		      +accountingFIFOBucketActivityLineItemRec.VendorName+';'
		      +'Vendor Return;'+accountingFIFOBucketActivityLineItemRec.RMANumber;
		    this.Url = AccountingUtil.getURL(accountingFIFOBucketActivityLineItemRec.ReturnVOHeaderId, 'ReturnVO');
		    String description = accountingFIFOBucketActivityLineItemRec.PartDesc + ';Returned ' + accountingFIFOBucketActivityLineItemRec.QtyOut + '@$' + cost;
		    this.JournalLines.add(new JournalLines(totalCost * -1,  accountingFIFOBucketActivityLineItemRec.Inventory_GL,  description));
            this.JournalLines.add(new JournalLines(totalCost, AccountingUtil.getChartofAccount('A/P Inventory Accrual'),  description));
		} else {
		    this.Narration = accountingFIFOBucketActivityLineItemRec.UniqueId + ';' + accountingFIFOBucketActivityLineItemRec.PartNumber + ';' + accountingFIFOBucketActivityLineItemRec.Reference;
	        this.Url = AccountingUtil.getURL(accountingFIFOBucketActivityLineItemRec.PartId, 'ViewPart');
	        String description = accountingFIFOBucketActivityLineItemRec.PartNumber + ' - decreased by ' + accountingFIFOBucketActivityLineItemRec.QtyOut + '@$' + cost;
	        this.JournalLines.add(new JournalLines(totalCost * -1,  accountingFIFOBucketActivityLineItemRec.Inventory_GL,  description));
	        this.JournalLines.add(new JournalLines(totalCost, AccountingUtil.getChartofAccount('Inventory Adjustments'),  description));
		}
	}
	
	public XeroJournalEntryDTO(AccountingDealItem accountingDealItemRec) {
        this.SFId = accountingDealItemRec.Id;
        this.JournalLines =  new List<JournalLines>();
        this.ManualJournalID = accountingDealItemRec.AccountingId;
        this.JournalDate = String.ValueOf(accountingDealItemRec.StockedInDate);
        this.Status = 'POSTED';
        this.Narration = accountingDealItemRec.COHeaderNumber + ';' + 'Stocked Trade In;'+accountingDealItemRec.StockedUnitStockNumber+';'+ accountingDealItemRec.StockedUnitVin; 
        this.Url = AccountingUtil.getURL(accountingDealItemRec.COHeaderId, 'CustomerOrder_V2');
        
        String description = 'Trade In;'+ accountingDealItemRec.StockedUnitStockNumber+';'+ accountingDealItemRec.StockedUnitVin;
        Decimal totalCost = accountingDealItemRec.ActualCashValue != null ? accountingDealItemRec.ActualCashValue.setScale(2, RoundingMode.HALF_UP) : 0;
        List<Category__c> stockTradeClearingCategoryList = AccountingUtil.getSystemDefaultCategory('Stocked Trade');
        String stockedTradeIncomeGL = stockTradeClearingCategoryList.size() > 0 ? stockTradeClearingCategoryList[0].Income_GL__c : '';
        this.JournalLines.add(new JournalLines(totalCost, accountingDealItemRec.InventoryGL,  description));
        this.JournalLines.add(new JournalLines(totalCost * -1, stockedTradeIncomeGL,  description));
    }
	
	public XeroJournalEntryDTO(AccountingCOInvoicePayment accountingCOInvoicePaymentRec) {
        this.SFId = accountingCOInvoicePaymentRec.Id;
        this.JournalLines =  new List<JournalLines>();
        this.ManualJournalID = accountingCOInvoicePaymentRec.AccountingId;
        this.JournalDate = String.ValueOf(accountingCOInvoicePaymentRec.PaymentDate);
        this.Status = 'POSTED';
        if(String.isNotBlank(accountingCOInvoicePaymentRec.customer.Name)){
            accountingCOInvoicePaymentRec.customer.Name = accountingCOInvoicePaymentRec.customer.Name;
        } else if(accountingCOInvoicePaymentRec.COType == Constants.CASH_SALE) {
            accountingCOInvoicePaymentRec.customer.Name = Constants.CASH_SALE;
        } else if(accountingCOInvoicePaymentRec.COType == Constants.INTERNAL_SERVICE) {
            accountingCOInvoicePaymentRec.customer.Name = Constants.INTERNAL_SERVICE;
        }
        this.Narration = accountingCOInvoicePaymentRec.COInvoicePaymentNumber +';'
            + accountingCOInvoicePaymentRec.customer.Name + ';' 
            + accountingCOInvoicePaymentRec.CustomerOrderNumber+ ';';
        if(accountingCOInvoicePaymentRec.IsReverse && String.isNotBlank(accountingCOInvoicePaymentRec.ReverseLink)) {
           this.Narration += accountingCOInvoicePaymentRec.PaymentMethod + ';Payment Reversal';
        } else if(accountingCOInvoicePaymentRec.IsReverse) {
           this.Narration += accountingCOInvoicePaymentRec.PaymentMethod + ';Refund';
        } else {
           this.Narration += accountingCOInvoicePaymentRec.PaymentMethod + ';Payment'; 
        }
        this.Url = AccountingUtil.getURL(accountingCOInvoicePaymentRec.CustomerOrderId, 'CustomerOrder_V2');
        String description = this.Narration;
        
        if(accountingCOInvoicePaymentRec.PaymentMethod == 'Store Credit') {
            this.JournalLines.add(new JournalLines(accountingCOInvoicePaymentRec.Amount,  AccountingUtil.getChartofAccount('Store Credit Accrual'),  description));
        } else if(accountingCOInvoicePaymentRec.PaymentMethod == 'Direct Deposit') {
            this.JournalLines.add(new JournalLines(accountingCOInvoicePaymentRec.Amount,  AccountingUtil.getChartofAccount('Undeposited Direct Deposit'),  description));
        } else if(accountingCOInvoicePaymentRec.PaymentMethod == 'Financing') {
            this.JournalLines.add(new JournalLines(accountingCOInvoicePaymentRec.Amount,  AccountingUtil.getChartofAccount('Undeposited Financing'),  description));
        } else if(accountingCOInvoicePaymentRec.PaymentMethod == 'Cash Rounding') {
            this.JournalLines.add(new JournalLines(accountingCOInvoicePaymentRec.Amount,  AccountingUtil.getChartofAccount('Cash Rounding'),  description));
        } else {
            this.JournalLines.add(new JournalLines(accountingCOInvoicePaymentRec.Amount,  AccountingUtil.getChartofAccount('Undeposited Funds'),  description));
        }
        this.JournalLines.add(new JournalLines((accountingCOInvoicePaymentRec.Amount * -1),  AccountingUtil.getChartofAccount('Customer Deposits'),  description));
    }
    
	public XeroJournalEntryDTO(AccountingPart partRec) {
		this.SFId = partRec.Id;
		this.ManualJournalID = partRec.XeroAccountingId;
		this.JournalLines =  new List<JournalLines>();
		String memo = partRec.PartNumber + ';Category changed';
        String description = partRec.PartNumber + ' - Category changed from ' + partRec.OldCategoryName + ' to ' + partRec.NewCategoryName;
		this.JournalDate = String.ValueOf(partRec.ModifiedDate);
		this.Status = 'POSTED';
		this.Narration = memo;
		this.Url = AccountingUtil.getURL(partRec.Id, 'ViewPart');
		this.JournalLines.add(new JournalLines(partRec.TotalInventoryValuation, partRec.NewCategoryInventoryGL,  description));
		this.JournalLines.add(new JournalLines(partRec.TotalInventoryValuation * -1, partRec.OldCategoryInventoryGL, description));
	}
	
	public XeroJournalEntryDTO(AccountingUnit unitRec) {
        this.SFId = unitRec.Id;
        this.ManualJournalID = unitRec.XeroJEAccountingId;
        this.JournalLines =  new List<JournalLines>();
        String memo = unitRec.UnitId+';' + unitRec.StockNumber+';'+ unitRec.VIN + ';Category changed';
        String description = memo +' from ' + unitRec.OldCategoryName + ' to ' + unitRec.NewCategoryName;
        this.JournalDate = String.ValueOf(unitRec.ModifiedDate);
        this.Status = 'POSTED';
        this.Narration = memo;
        this.Url = AccountingUtil.getURL(unitRec.Id, 'ViewUnit');
        this.JournalLines.add(new JournalLines(unitRec.TotalInventoryValuation * -1, unitRec.OldCategoryInventoryGL, description));
        this.JournalLines.add(new JournalLines(unitRec.TotalInventoryValuation, unitRec.NewCategoryInventoryGL,  description));
        
    }
	
	public XeroJournalEntryDTO(AccountingCODeposit coDepositRec) {
		this.SFId = coDepositRec.CODepositId;
		this.ManualJournalID = coDepositRec.XeroAccountingId;
		this.JournalLines =  new List<JournalLines>();
		String memo = '';
		if(String.isNotBlank(coDepositRec.DepositName)) {
			memo += coDepositRec.DepositName + ';';
		}
        if(String.isNotBlank(coDepositRec.customer.Name)){
            memo += coDepositRec.customer.Name + ';';
        } else if(coDepositRec.COType == Constants.CASH_SALE) {
                memo += Constants.CASH_SALE + ';';
        } else if(coDepositRec.COType == Constants.INTERNAL_SERVICE) {
                memo += Constants.INTERNAL_SERVICE + ';';
        }
        memo += coDepositRec.CustomerOrderNumber + ';';
        if(String.isNotBlank(coDepositRec.ReverseLink)) {
        	memo += coDepositRec.PaymentMethod + ';Deposit Reversal';
        } else if(coDepositRec.Amount < 0 && coDepositRec.PaymentMethod == 'Invoice') {
        	memo += 'Use Deposit' + ';Invoice Payment';
        } else if(coDepositRec.Amount < 0) {
            memo += coDepositRec.PaymentMethod + ';Deposit Refund';
        } else if(coDepositRec.PaymentMethod == 'Invoice') {
        	memo += 'Use Deposit' + ';Invoice Payment Reversal';
        } else {
            memo += coDepositRec.PaymentMethod + ';Deposit';
        } 
		this.JournalDate = String.ValueOf(coDepositRec.PaymentDate);
		this.Status = 'POSTED';
		this.Narration = memo;
		
		this.Url = AccountingUtil.getURL(coDepositRec.COHeaderId, 'CustomerOrder_V2');
		if(coDepositRec.PaymentMethod == 'Store Credit') {
			this.JournalLines.add(new JournalLines(coDepositRec.Amount, AccountingUtil.getChartofAccount('Store Credit Accrual'),  memo));
		} else if(coDepositRec.PaymentMethod == 'Direct Deposit') {
			this.JournalLines.add(new JournalLines(coDepositRec.Amount, AccountingUtil.getChartofAccount('Undeposited Direct Deposit'),  memo));
		} else if(coDepositRec.PaymentMethod == 'Financed') {
			this.JournalLines.add(new JournalLines(coDepositRec.Amount, AccountingUtil.getChartofAccount('Undeposited Financing'),  memo));
		} else {
			this.JournalLines.add(new JournalLines(coDepositRec.Amount, AccountingUtil.getChartofAccount('Undeposited Funds'),  memo));
		}
		this.JournalLines.add(new JournalLines(coDepositRec.Amount * -1, AccountingUtil.getChartofAccount('Customer Deposits'), memo));
	}
	
	public XeroJournalEntryDTO(AccountingStoreCredit storeCreditRec) {
		this.SFId = storeCreditRec.StoreCreditId;
		this.ManualJournalID = storeCreditRec.XeroAccountingId;
		this.JournalLines =  new List<JournalLines>();
		String memo = '';
		if(storeCreditRec.StoreCreditName != null) {
			memo += storeCreditRec.StoreCreditName + ';';
		}
        if(storeCreditRec.customer.Name != null){
            memo += storeCreditRec.customer.Name + ';';
        } 
       if(storeCreditRec.Amount > 0) {
        	memo += 'Store Credit Increase'+ ';';
        }else {
        	memo += 'Store Credit Decrease'+ ';';
        } 
        if(storeCreditRec.StoreCreditReference != null){
            memo += storeCreditRec.StoreCreditReference ;
        } 
		this.JournalDate = String.ValueOf(storeCreditRec.CreatedDate);
		this.Status = 'POSTED';
		this.Narration = memo;
		
		this.Url = AccountingUtil.getURL(storeCreditRec.customer.customerId, 'ViewCustomer');
        this.JournalLines.add(new JournalLines(storeCreditRec.Amount, AccountingUtil.getChartofAccount('Store Credit Expense'),  memo));
        this.JournalLines.add(new JournalLines(storeCreditRec.Amount * -1, AccountingUtil.getChartofAccount('Store Credit Accrual'),  memo));
	}
	
	public XeroJournalEntryDTO(AccountingUnitPriceAndCost unitPriceAndCostRec) {
		this.SFId = unitPriceAndCostRec.Id;
		this.ManualJournalID = unitPriceAndCostRec.XeroAccountingId;
		this.JournalLines =  new List<JournalLines>();
		String memo = '';
		
		if(unitPriceAndCostRec.RefrenceNumber != null) {
			memo += unitPriceAndCostRec.RefrenceNumber + ';';
		}
        if(unitPriceAndCostRec.Type == 'Factory') {
            memo += 'Factory Option Cost Adjustment' + ';';
        } else if(unitPriceAndCostRec.Type == 'Base') { 
        	memo += 'Base Cost Adjustment' + ';';
        }
        if(unitPriceAndCostRec.ItemDescription != null) {
        	memo += unitPriceAndCostRec.ItemDescription + ';';
        }
        if(unitPriceAndCostRec.UnitId != null) {
        	memo += unitPriceAndCostRec.UnitId + ';';
        }
        if(unitPriceAndCostRec.StockNumber != null) {
        	memo += unitPriceAndCostRec.StockNumber + ';';
        }
        if(unitPriceAndCostRec.VIN != null) {
        	memo += unitPriceAndCostRec.VIN;
        }
		this.JournalDate = String.ValueOf(unitPriceAndCostRec.CreatedDate);
		this.Status = 'POSTED';
		this.Narration = memo;
		
		this.Url = AccountingUtil.getURL(unitPriceAndCostRec.CustomerOwnedUnitId, 'ViewUnit');
		Decimal totalCost = unitPriceAndCostRec.TotalCost != null ? unitPriceAndCostRec.TotalCost.setScale(2, RoundingMode.HALF_UP) : 0;
        List<Category__c> defaultCategory = [select Name, Inventory_GL__c, COGS_GL__c from Category__c
                                                    where Type__c = 'Unit' AND Active__c = true AND Default__c = true]; 
	    String inventoryGLNumber;
	    if(unitPriceAndCostRec.UnitStatus == 'Available' || unitPriceAndCostRec.UnitStatus == 'Reserved') {
	        inventoryGLNumber = unitPriceAndCostRec.Inventory_GL != null ? unitPriceAndCostRec.Inventory_GL : defaultCategory[0].Inventory_GL__c;
	    } else {
	        inventoryGLNumber = unitPriceAndCostRec.COGS_GL != null ? unitPriceAndCostRec.COGS_GL : defaultCategory[0].Inventory_GL__c;
	    }
        this.JournalLines.add(new JournalLines(totalCost, inventoryGLNumber ,  memo));
        this.JournalLines.add(new JournalLines(totalCost * -1, AccountingUtil.getChartofAccount('Inventory Adjustments'),  memo));
	}
	
	public XeroJournalEntryDTO(AccountingVendorReceiving vendorReceivingRec) {
		this.JournalLines =  new List<JournalLines>();
		String description = '';
		this.SFId = vendorReceivingRec.AccountingVORHeaderRec.VORId;
		this.ManualJournalID = vendorReceivingRec.AccountingVORHeaderRec.XeroAccountingId;
		this.JournalDate = String.ValueOf(vendorReceivingRec.AccountingVORHeaderRec.FinalizedDate);
		this.Status = 'POSTED';
		String descriptionForCompleteVR = vendorReceivingRec.AccountingVORHeaderRec.VORName + ';'+ 
											vendorReceivingRec.AccountingVORHeaderRec.PackagingSlipNumber + ';'
										 	+ vendorReceivingRec.AccountingVORHeaderRec.VendorName 
                                    		 + ';Total Receiving'; 
		
		String memo = vendorReceivingRec.AccountingVORHeaderRec.VORName + ';' + vendorReceivingRec.AccountingVORHeaderRec.VendorName + ';' +
                                    vendorReceivingRec.AccountingVORHeaderRec.PackagingSlipNumber + ';Product Received';
		this.Narration = memo;
		this.Url = AccountingUtil.getURL(vendorReceivingRec.AccountingVORHeaderRec.VORId, 'VendorOrderReceiving');
		for(AccountingVendorReceiving.AccountingVORGroup VORItemRec : vendorReceivingRec.AccountingVORGroupList) {
	        description = vendorReceivingRec.AccountingVORHeaderRec.VORName + ';'+ 
	                            vendorReceivingRec.AccountingVORHeaderRec.PackagingSlipNumber + ';' + VORItemRec.ItemDesc +
                             	';Received' + ' ' + VORItemRec.ReceivedQty + '@$' + VORItemRec.Cost;
                             	
			this.JournalLines.add(new JournalLines(VORItemRec.Total, VORItemRec.Inventory_GL,  description));
        }
        this.JournalLines.add(new JournalLines(vendorReceivingRec.AccountingVORHeaderRec.ReceivingTotal * -1, AccountingUtil.getChartofAccount('A/P Inventory Accrual'), descriptionForCompleteVR));
	}
	
	public XeroJournalEntryDTO(Deal_Item__c dealItemRec, AccountingCustomerInvoice accCOInvoiceRec) {
		
	}
	
	public XeroJournalEntryDTO(AccountingCustomerInvoice accCOInvoiceRec) {
		this.JournalLines =  new List<JournalLines>();
		this.SFId = accCOInvoiceRec.AccountingCOInvoiceHeaderRec.COInvoiceHeaderId;
		this.ManualJournalID = accCOInvoiceRec.AccountingCOInvoiceHeaderRec.XeroCOInvoiceJEAccountingId;
		this.Status = 'POSTED';
		this.Quantity = 1;
		this.Url = AccountingUtil.getURL(accCOInvoiceRec.AccountingCOInvoiceHeaderRec.COHeaderId, 'CustomerOrder_V2');
		
		this.Narration = accCOInvoiceRec.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber +';' + accCOInvoiceRec.AccountingCOInvoiceHeaderRec.FormattedCustomerName +';' + accCOInvoiceRec.AccountingCOInvoiceHeaderRec.COHeaderNumber;
		if(accCOInvoiceRec.AccountingCOInvoiceHeaderRec.CheckoutType == 'Third-Party') {
			this.Narration += ';Claim Invoice COGS';
		} else if(accCOInvoiceRec.AccountingCOInvoiceHeaderRec.CheckoutType == 'Deal') {
			this.Narration += setNarrationForDealMerchAndService(accCOInvoiceRec);
		}else if(accCOInvoiceRec.AccountingCOInvoiceItemsRecs[0].ServiceJobType == 'Stock Unit') {
			this.Narration = accCOInvoiceRec.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber +';' + 'UNIT INVENTORY;' + accCOInvoiceRec.AccountingCOInvoiceHeaderRec.COHeaderNumber + ';'
								+ 'Internal Service;';
			for(AccountingCustomerInvoice.AccountingCOInvoiceItem coInvItem : accCOInvoiceRec.AccountingCOInvoiceItemsRecs) {
				this.Narration += coInvItem.SkuNumber;
			}				
		} else if(accCOInvoiceRec.AccountingCOInvoiceItemsRecs[0].ServiceJobType == 'Internal') {
			this.Narration = accCOInvoiceRec.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber +';' + accCOInvoiceRec.AccountingCOInvoiceHeaderRec.FormattedCustomerName +';' +
							 accCOInvoiceRec.AccountingCOInvoiceHeaderRec.COHeaderNumber + ';';
			for(AccountingCustomerInvoice.AccountingCOInvoiceItem coInvItem : accCOInvoiceRec.AccountingCOInvoiceItemsRecs) {
				this.Narration += coInvItem.ServiceJobName;
				this.Narration += ';' + coInvItem.VinNumber;
			}				
		} else {
			this.Narration += ';Invoice COGS';
		}
		this.JournalDate =  DateTimeUtility.getFormttedDateFromDateTime(accCOInvoiceRec.AccountingCOInvoiceHeaderRec.COInvoiceDate, 'yyyy-MM-dd');
		for(Object lineItemRec : AccountingCustomerInvoiceService.setAllInvoiceItemRec((AccountingCustomerInvoice) accCOInvoiceRec, IntegrationUtility.CO_INVOICE_JE)) {
			JournalLines journalLinesRec = (JournalLines) lineItemRec;
			if(journalLinesRec.LineAmount != 0) {
				this.JournalLines.add(journalLinesRec);
			}
		}
	}
	
	private String setNarrationForDealMerchAndService(AccountingCustomerInvoice accCOInvoiceRec) {
		String soHeaderId = accCOInvoiceRec.AccountingCOInvoiceItemsRecs.size() > 0 ? accCOInvoiceRec.AccountingCOInvoiceItemsRecs[0].SOHeaderId : '';
		Set<String> skuNumberSet = new Set<String>();
		for(AccountingCustomerInvoice.AccountingCOInvoiceItem coInvItem : accCOInvoiceRec.AccountingCOInvoiceItemsRecs) {
			skuNumberSet.add(coInvItem.SkuNumber);
		}
		skuNumberSet.remove(null);
		if(String.isBlank(soHeaderId)) {
			if(skuNumberSet.size() > 1) {
				return ';Deal Merchandise;Multiple Units';
			} else if(skuNumberSet.size() == 1) {
				return ';Deal Merchandise;' + (new List<String>(skuNumberSet))[0];
			}
		} else {
			return ';Deal Service;' + accCOInvoiceRec.AccountingCOInvoiceItemsRecs[0].SKUNumberonDealService;
		}
		
		return '';
	}
	
}