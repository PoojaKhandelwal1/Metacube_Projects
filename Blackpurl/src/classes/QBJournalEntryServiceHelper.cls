public with sharing class QBJournalEntryServiceHelper {
    
     public class QuickBooksJournalEntry{
        public String Id;
        public String SyncToken;
        public String DocNumber;
        public Date TxnDate;
        public List<LineWrapper> Line;
        public String PrivateNote; 
         
        public QuickBooksJournalEntry(AccountingCustomerInvoice customerInvoiceRecord) {
            String description = '';
            this.PrivateNote = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.Customer.Name + ';' + customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COHeaderNumber + ';Costing';
            description += this.PrivateNote + ';';
            this.Id = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.JournalEntryAccountingId;
            this.SyncToken = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.JournalEntrySyncToken;
            this.DocNumber = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber; 
            this.TxnDate =  DateTimeUtility.getDateFromFormattedDateStr(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.ClosedInvoiceDate);
            this.Line = new List<LineWrapper>();
            
            for(COInvoiceJournalEntryService.QuickBooksCustomerInvoiceItemsHelper coInvoiceItemRec : COInvoiceJournalEntryService.getAllAccountingCOInvoiceItemsRecs(customerInvoiceRecord)) {
                Decimal CostAmount = (coInvoiceItemRec.Qty != null ? (coInvoiceItemRec.Qty).setScale(2, RoundingMode.HALF_UP) : 0) * (coInvoiceItemRec.UnitCost).setScale(2, RoundingMode.HALF_UP);
                Decimal PriceAmount = (coInvoiceItemRec.Qty != null ? (coInvoiceItemRec.Qty).setScale(2, RoundingMode.HALF_UP) : 0) * (coInvoiceItemRec.UnitPrice).setScale(2, RoundingMode.HALF_UP);
                if(coInvoiceItemRec.IsInternalServiceTax) {
                    PriceAmount = coInvoiceItemRec.UnitPrice;
                }
                
                if(coInvoiceItemRec.IsBillToInternalClaimLI) {
                	if(CostAmount != 0) {  
                		String accountRef = (coInvoiceItemRec.PostingType == 'Credit') ? coInvoiceItemRec.Income_GL : coInvoiceItemRec.Income_GL; //debit variance desposition category
                		this.Line.add(new LineWrapper(coInvoiceItemRec.Description, CostAmount, accountRef, coInvoiceItemRec.PostingType));
                	}
                } else if(!coInvoiceItemRec.IsDealMerchOrService && !coInvoiceItemRec.IsInternalService) {
                    if(CostAmount != 0) { // Added for JE is not created for 0 cost 10 aug 2017
                        if(CostAmount > 0) {
                            this.Line.add(new LineWrapper(description, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.Inventory_GL, 'Credit', false, false)); //Debit Changed by richa 19/01/2017
                            this.Line.add(new LineWrapper(description, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.COGS_GL, 'Debit', false, false)); //Credit Changed by richa 19/01/2017
                        } else {
                            this.Line.add(new LineWrapper(description, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.Inventory_GL, 'Debit', false, false));
                            this.Line.add(new LineWrapper(description, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.COGS_GL, 'Credit', false, false));
                        }
                    }
                } else if(coInvoiceItemRec.IsDealMerchOrService) {
                    String dealDesc = '';
                    if(coInvoiceItemRec.Qty > 0) {
                        if(CostAmount != 0 && coInvoiceItemRec.EntityType != 'Fee') {
                            this.Line.add(new LineWrapper(dealDesc, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.COGS_GL, 'Debit', false, false));
                            this.Line.add(new LineWrapper(dealDesc, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.Inventory_GL, 'Credit', false, false));
                        }
                        
                        if(PriceAmount != 0) {
                            this.Line.add(new LineWrapper(dealDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.Income_GL, 'Credit', false, false));
                            this.Line.add(new LineWrapper(dealDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.DealUnit_Inventory_GL, 'Debit', true, false));
                        }
                    } else {
                        if(CostAmount != 0 && coInvoiceItemRec.EntityType != 'Fee') {
                            this.Line.add(new LineWrapper(dealDesc, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.COGS_GL, 'Credit', false, false));
                            this.Line.add(new LineWrapper(dealDesc, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.Inventory_GL, 'Debit', false, false));
                        }
                        
                        if(PriceAmount != 0) {
                            this.Line.add(new LineWrapper(dealDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.Income_GL, 'Debit', false, false));
                            this.Line.add(new LineWrapper(dealDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.DealUnit_Inventory_GL, 'Credit', true, false));
                        }
                    }
                } else if(coInvoiceItemRec.IsInternalService) {
                    String internalServiceDesc = '';
                    if(coInvoiceItemRec.IsInternalServiceTax && PriceAmount != 0) {
                        if(PriceAmount > 0) {
                            this.Line.add(new LineWrapper(internalServiceDesc, coInvoiceItemRec.UnitPrice, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.Income_GL, 'Credit', false, true));
                            this.Line.add(new LineWrapper(internalServiceDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.DealUnit_Inventory_GL, 'Debit', true, false));
                        } else {
                            this.Line.add(new LineWrapper(internalServiceDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.Income_GL, 'Debit', false, true));
                            this.Line.add(new LineWrapper(internalServiceDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.DealUnit_Inventory_GL, 'Credit', true, false));
                        }
                        
                    } else {
                        if(coInvoiceItemRec.Qty > 0) {
                            if(CostAmount != 0 && String.isNotBlank(coInvoiceItemRec.COGS_GL)) {
                                this.Line.add(new LineWrapper(internalServiceDesc, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.COGS_GL, 'Debit', false, false));
                                this.Line.add(new LineWrapper(internalServiceDesc, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.Inventory_GL, 'Credit', false, false));
                            }
                            
                            if(PriceAmount != 0) {
                                this.Line.add(new LineWrapper(internalServiceDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.Income_GL, 'Credit', false, false));
                                this.Line.add(new LineWrapper(internalServiceDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.DealUnit_Inventory_GL, 'Debit', true, false));
                            }
                        } else {
                            if(CostAmount != 0 && String.isNotBlank(coInvoiceItemRec.COGS_GL)) {
                                this.Line.add(new LineWrapper(internalServiceDesc, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.COGS_GL, 'Credit', false, false));
                                this.Line.add(new LineWrapper(internalServiceDesc, CostAmount, coInvoiceItemRec.UnitCost, coInvoiceItemRec, coInvoiceItemRec.Inventory_GL, 'Debit', false, false));
                            }
                            
                            if(PriceAmount != 0) {
                                this.Line.add(new LineWrapper(internalServiceDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.Income_GL, 'Debit', false, false));
                                this.Line.add(new LineWrapper(internalServiceDesc, PriceAmount, coInvoiceItemRec.UnitPrice, coInvoiceItemRec, coInvoiceItemRec.DealUnit_Inventory_GL, 'Credit', true, false));
                            }
                        }
                    }
                }
            }
        }
         
        public QuickBooksJournalEntry(AccountingVendorReceiving VORRecord) {
            String description = '';
            String descriptionForCompleteVR = VORRecord.AccountingVORHeaderRec.VendorName + ';' +
                                    VORRecord.AccountingVORHeaderRec.PackagingSlipNumber + ';Total Receiving';
            String memo = VORRecord.AccountingVORHeaderRec.VendorName + ';' +
                                    VORRecord.AccountingVORHeaderRec.PackagingSlipNumber + ';Receiving';
            this.Id = VORRecord.AccountingVORHeaderRec.JournalEntryAccountingId;
            this.SyncToken = VORRecord.AccountingVORHeaderRec.JournalEntrySyncToken;
            this.DocNumber = VORRecord.AccountingVORHeaderRec.VORName; 
            this.TxnDate = VORRecord.AccountingVORHeaderRec.FinalizedDate;
            this.PrivateNote = memo;
            this.Line = new List<LineWrapper>();
            AccountingVendorReceiving.EntityRefWrapper VOREntityRefRec;
            for(AccountingVendorReceiving.AccountingVORGroup VORItemRec : VORRecord.AccountingVORGroupList) {
                description = VORRecord.AccountingVORHeaderRec.VendorName + ';' +
                                    VORRecord.AccountingVORHeaderRec.PackagingSlipNumber + ';Receiving;' +
                                    VORItemRec.ItemDesc + ' ' + VORItemRec.ReceivedQty + '@$' + VORItemRec.Cost;
                if(VORItemRec.ReceivedQty > 0) {
                    this.Line.add(new LineWrapper(description, VORItemRec.Total, VORItemRec.Inventory_GL, 'Debit', VOREntityRefRec)); //null
                } else{
                    this.Line.add(new LineWrapper(description, VORItemRec.Total * -1, VORItemRec.Inventory_GL, 'Credit', VOREntityRefRec)); //null
                }
            }
            String APInvAccrualAccId = AccountingUtil.getChartofAccount('A/P Inventory Accrual');
            if(VORRecord.AccountingVORHeaderRec.ReceivingTotal > 0) {
               this.Line.add(new LineWrapper(descriptionForCompleteVR, VORRecord.AccountingVORHeaderRec.ReceivingTotal, APInvAccrualAccId, 'Credit',  VORRecord.EntityRef)); 
            } else {
                this.Line.add(new LineWrapper(descriptionForCompleteVR, VORRecord.AccountingVORHeaderRec.ReceivingTotal * -1, APInvAccrualAccId, 'Debit',  VORRecord.EntityRef));
            }
            
        }
         
        public QuickBooksJournalEntry(AccountingFIFOBucket FIFOBucketRecord) {
            String memo = FIFOBucketRecord.PartNumber + ';' +
                                    FIFOBucketRecord.SourceName;
            this.Id = FIFOBucketRecord.AccountingId;
            this.SyncToken = FIFOBucketRecord.SyncToken;
            this.DocNumber = FIFOBucketRecord.UniqueId; // FIFOBucketRecord.Name
            this.TxnDate = FIFOBucketRecord.CreatedDate;
            this.PrivateNote = memo;
            this.Line = new List<LineWrapper>();
            AccountingFIFOBucket.EntityRefWrapper FIFOBucketEntityRefRec;
            String invAdjustmentsAccId = AccountingUtil.getChartofAccount('Inventory Adjustments');
            this.Line.add(new LineWrapper(FIFOBucketRecord, invAdjustmentsAccId, 'Credit', null)); // null -> FIFOBucketRecord.EntityRef
            this.Line.add(new LineWrapper(FIFOBucketRecord, FIFOBucketRecord.Inventory_GL, 'Debit', null)); //null - >FIFOBucketEntityRefRec
        }
         
        public QuickBooksJournalEntry(AccountingFIFOBucketActivityLineItem FIFOBucketActivityLineItemRecord) {
            String memo = FIFOBucketActivityLineItemRecord.PartNumber + ';' +
                                    FIFOBucketActivityLineItemRecord.Reference;
            if(FIFOBucketActivityLineItemRecord.Reference == 'Vendor Return'){
                memo += ';'+FIFOBucketActivityLineItemRecord.RMANumber;
            }
            this.Id = FIFOBucketActivityLineItemRecord.AccountingId;
            this.SyncToken = FIFOBucketActivityLineItemRecord.SyncToken;
            this.DocNumber = FIFOBucketActivityLineItemRecord.UniqueId; // FIFOBucketActivityLineItemRecord.Name
            this.TxnDate = FIFOBucketActivityLineItemRecord.CreatedDate;
            this.PrivateNote = memo;
            this.Line = new List<LineWrapper>();
            String invAdjustmentsAccId = AccountingUtil.getChartofAccount('Inventory Adjustments');
            String APInvAccrualAccId = AccountingUtil.getChartofAccount('A/P Inventory Accrual');
            AccountingFIFOBucketActivityLineItem.EntityRefWrapper FIFOBucketActivityLineItemEntityRefRec;
            if(FIFOBucketActivityLineItemRecord.FIFOSource == 'Oversold') {
                this.Line.add(new LineWrapper(FIFOBucketActivityLineItemRecord, invAdjustmentsAccId, 'Credit', FIFOBucketActivityLineItemRecord.EntityRef)); //FIFOBucketActivityLineItemRecord.COGS_GL
                this.Line.add(new LineWrapper(FIFOBucketActivityLineItemRecord, FIFOBucketActivityLineItemRecord.Inventory_GL, 'Debit', null)); //null - > FIFOBucketActivityLineItemEntityRefRec
            } else if(FIFOBucketActivityLineItemRecord.Reference == 'Vendor Return') {
                this.Line.add(new LineWrapper(FIFOBucketActivityLineItemRecord, APInvAccrualAccId, 'Debit', FIFOBucketActivityLineItemRecord.EntityRef)); //FIFOBucketActivityLineItemRecord.COGS_GL
                this.Line.add(new LineWrapper(FIFOBucketActivityLineItemRecord, FIFOBucketActivityLineItemRecord.Inventory_GL, 'Credit', null)); //null -> FIFOBucketActivityLineItemEntityRefRec
            } else {
                this.Line.add(new LineWrapper(FIFOBucketActivityLineItemRecord, invAdjustmentsAccId, 'Debit', FIFOBucketActivityLineItemRecord.EntityRef)); //FIFOBucketActivityLineItemRecord.COGS_GL
                this.Line.add(new LineWrapper(FIFOBucketActivityLineItemRecord, FIFOBucketActivityLineItemRecord.Inventory_GL, 'Credit', null)); //null -> FIFOBucketActivityLineItemEntityRefRec
            }
        }
        
        public QuickBooksJournalEntry(AccountingCOInvoicePayment COInvoicePaymentRecord) {
            String description = '';
            String memo = '';
            if(COInvoicePaymentRecord.customer.Name != null){
                memo += COInvoicePaymentRecord.customer.Name + ';';
            } else if(COInvoicePaymentRecord.COType == Constants.CASH_SALE) {
                memo += Constants.CASH_SALE + ';';
            } else if(COInvoicePaymentRecord.COType == Constants.INTERNAL_SERVICE) {
                memo += Constants.INTERNAL_SERVICE + ';';
            }
            memo +=  COInvoicePaymentRecord.CustomerOrderNumber + ';Payment';

            this.Id = COInvoicePaymentRecord.JournalEntryAccountingId;
            this.SyncToken = COInvoicePaymentRecord.JournalEntrySyncToken;
            this.DocNumber = COInvoicePaymentRecord.COInvoicePaymentNumber; 
            this.TxnDate = COInvoicePaymentRecord.PaymentDate;
            this.PrivateNote = memo;
            this.Line = new List<LineWrapper>();
            String undepFundsAccId = AccountingUtil.getChartofAccount('Undeposited Funds');
            String customerDepAccId = AccountingUtil.getChartofAccount('Customer Deposits');
            String cashRoundingAccId = AccountingUtil.getChartofAccount('Cash Rounding');
            String storeCreditAccrualAccId = AccountingUtil.getChartofAccount('Store Credit Accrual');
            String undepositedDirectDepositAccId = AccountingUtil.getChartofAccount('Undeposited Direct Deposit');
            String undepositedFinancingAccId = AccountingUtil.getChartofAccount('Undeposited Financing');
            
            if(COInvoicePaymentRecord.Amount > 0) {
                if(COInvoicePaymentRecord.PaymentMethod == 'Cash Rounding'){
                    this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount, cashRoundingAccId, 'Debit', COInvoicePaymentRecord.customer)); //Cash Rounding
                    this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount, customerDepAccId, 'Credit', COInvoicePaymentRecord.customer)); //Undeposited Funds
                } else if(COInvoicePaymentRecord.PaymentMethod == 'Store Credit') {
                    this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount, customerDepAccId, 'Credit', COInvoicePaymentRecord.customer)); //Customer Deposits
                    this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount, storeCreditAccrualAccId, 'Debit', COInvoicePaymentRecord.customer)); //Store Credit Accrual
                } else{
            		if(COInvoicePaymentRecord.PaymentMethod == 'Direct Deposit') {
        				this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount, undepositedDirectDepositAccId, 'Debit', COInvoicePaymentRecord.customer)); //Undeposited Direct Deposit Funds
            		} else if(COInvoicePaymentRecord.PaymentMethod == 'Financing') {
            			this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount, undepositedFinancingAccId, 'Debit', COInvoicePaymentRecord.customer)); //Undeposited Financing Funds
            		} else {
                    this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount, undepFundsAccId, 'Debit', COInvoicePaymentRecord.customer)); //Undeposited Funds
                }
            		this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount, customerDepAccId, 'Credit', COInvoicePaymentRecord.customer)); //Customer Deposits	
            	}
            } else {
                if(COInvoicePaymentRecord.PaymentMethod == 'Cash Rounding'){
                    this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount * -1, cashRoundingAccId, 'Credit', COInvoicePaymentRecord.customer)); //Customer Deposits
                    this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount * -1, customerDepAccId, 'Debit', COInvoicePaymentRecord.customer)); //Undeposited Funds
                } else if(COInvoicePaymentRecord.PaymentMethod == 'Store Credit') {
                    this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount * -1, customerDepAccId, 'Debit', COInvoicePaymentRecord.customer)); //Customer Deposits
                    this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount * -1, storeCreditAccrualAccId, 'Credit', COInvoicePaymentRecord.customer)); //Store Credit Accrual
                } else{
            		if(COInvoicePaymentRecord.PaymentMethod == 'Direct Deposit') {
        				this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount * -1, undepositedDirectDepositAccId, 'Credit', COInvoicePaymentRecord.customer)); //Undeposited Funds
            		} else if(COInvoicePaymentRecord.PaymentMethod == 'Financing') {
            			this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount * -1, undepositedFinancingAccId, 'Credit', COInvoicePaymentRecord.customer)); //Undeposited Funds
            		} else {
                    this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount * -1, undepFundsAccId, 'Credit', COInvoicePaymentRecord.customer)); //Undeposited Funds
                }
            		this.Line.add(new LineWrapper(memo, COInvoicePaymentRecord.Amount * -1, customerDepAccId, 'Debit', COInvoicePaymentRecord.customer)); //Customer Deposits
            		
            	}
            }
        }
         
       
        
        public QuickBooksJournalEntry(AccountingCODeposit CODepositRecord) {
            String description = '';
            String memo = '';
            if(CODepositRecord.customer.Name != null){
                memo += CODepositRecord.customer.Name + ';';
            } else if(CODepositRecord.COType == Constants.CASH_SALE) {
                memo += Constants.CASH_SALE + ';';
            } else if(CODepositRecord.COType == Constants.INTERNAL_SERVICE) {
                memo += Constants.INTERNAL_SERVICE + ';';
            }
            memo += CODepositRecord.CustomerOrderNumber + ';Deposit';

            this.Id = CODepositRecord.JournalEntryAccountingId;
            this.SyncToken = CODepositRecord.JournalEntrySyncToken;
            this.DocNumber = CODepositRecord.DepositName; 
            this.TxnDate = CODepositRecord.PaymentDate; //date.parse(CODepositRecord.CreatedDate);
            this.PrivateNote = memo;
            this.Line = new List<LineWrapper>();
            String undepFundsAccId = AccountingUtil.getChartofAccount('Undeposited Funds');
            String customerDepAccId = AccountingUtil.getChartofAccount('Customer Deposits');
            String storeCreditAccrualAccId = AccountingUtil.getChartofAccount('Store Credit Accrual');
            String undepositedDirectDepositAccId = AccountingUtil.getChartofAccount('Undeposited Direct Deposit');
			String undepositedFinancingAccId = AccountingUtil.getChartofAccount('Undeposited Financing');
            
            if(CODepositRecord.Amount > 0) {
                if(CODepositRecord.PaymentMethod == 'Store Credit') {
                    this.Line.add(new LineWrapper(memo, CODepositRecord.Amount, customerDepAccId, 'Credit', CODepositRecord.customer)); //Customer Deposits
                    this.Line.add(new LineWrapper(memo, CODepositRecord.Amount, storeCreditAccrualAccId, 'Debit', CODepositRecord.customer)); //Store Credit Accrual
                } else {
                	if(CODepositRecord.PaymentMethod == 'Direct Deposit') {
        				this.Line.add(new LineWrapper(memo, CODepositRecord.Amount, undepositedDirectDepositAccId, 'Debit', CODepositRecord.customer)); //Undeposited Direct Deposit Funds
            		} else if(CODepositRecord.PaymentMethod == 'Financed') {
            			this.Line.add(new LineWrapper(memo, CODepositRecord.Amount, undepositedFinancingAccId, 'Debit', CODepositRecord.customer)); //Undeposited Financing Funds
            		} else {
                	this.Line.add(new LineWrapper(memo, CODepositRecord.Amount, undepFundsAccId, 'Debit', CODepositRecord.customer)); //Undeposited Funds
                }
                	this.Line.add(new LineWrapper(memo, CODepositRecord.Amount, customerDepAccId, 'Credit', CODepositRecord.customer)); //Customer Deposits
                }
            } else {
                if(CODepositRecord.PaymentMethod == 'Store Credit') {
                    this.Line.add(new LineWrapper(memo, CODepositRecord.Amount * -1, customerDepAccId, 'Debit', CODepositRecord.customer)); //Customer Deposits
                	this.Line.add(new LineWrapper(memo, CODepositRecord.Amount * -1, storeCreditAccrualAccId, 'Credit', CODepositRecord.customer)); //Undeposited Funds
                } else {
                	if(CODepositRecord.PaymentMethod == 'Direct Deposit') {
        				this.Line.add(new LineWrapper(memo, CODepositRecord.Amount * -1, undepositedDirectDepositAccId, 'Credit', CODepositRecord.customer)); //Undeposited Direct Deposit Funds
            		} else if(CODepositRecord.PaymentMethod == 'Financed') {
            			this.Line.add(new LineWrapper(memo, CODepositRecord.Amount * -1, undepositedFinancingAccId, 'Credit', CODepositRecord.customer)); //Undeposited Financing Funds
            		} else {
                this.Line.add(new LineWrapper(memo, CODepositRecord.Amount * -1, undepFundsAccId, 'Credit', CODepositRecord.customer)); //Undeposited Funds
                }
                	this.Line.add(new LineWrapper(memo, CODepositRecord.Amount * -1, customerDepAccId, 'Debit', CODepositRecord.customer)); //Customer Deposits
                }
            }
        }
        
        
        public QuickBooksJournalEntry(AccountingStoreCredit StoreCreditRecord){
            String description = '';
            String memo = StoreCreditRecord.customer.Name + ';' +
                                    StoreCreditRecord.StoreCreditReference + ';StoreCredit';

            this.Id = StoreCreditRecord.JournalEntryAccountingId;
            this.SyncToken = StoreCreditRecord.JournalEntrySyncToken; 
            this.DocNumber = StoreCreditRecord.StoreCreditName; 
            this.TxnDate = StoreCreditRecord.CreatedDate; //date.parse(CODepositRecord.CreatedDate);
            this.PrivateNote = memo;
            this.Line = new List<LineWrapper>();
            String storeCreditAccrualAccId = AccountingUtil.getChartofAccount('Store Credit Accrual');
            String storeCreditExpenseAccId = AccountingUtil.getChartofAccount('Store Credit Expense');
            if(StoreCreditRecord.Amount > 0) {
                this.Line.add(new LineWrapper(memo, StoreCreditRecord.Amount, storeCreditAccrualAccId, 'Credit', StoreCreditRecord.customer)); //Customer Deposits
                this.Line.add(new LineWrapper(memo, StoreCreditRecord.Amount, storeCreditExpenseAccId, 'Debit', StoreCreditRecord.customer)); //Undeposited Funds
            } else {
                this.Line.add(new LineWrapper(memo, StoreCreditRecord.Amount * -1, storeCreditAccrualAccId, 'Debit', StoreCreditRecord.customer)); //Customer Deposits
                this.Line.add(new LineWrapper(memo, StoreCreditRecord.Amount * -1, storeCreditExpenseAccId, 'Credit', StoreCreditRecord.customer)); //Undeposited Funds
            }
        }
        
        public QuickBooksJournalEntry(AccountingUnitPriceAndCost adjstmentRec){
            String memo = adjstmentRec.UnitId + ' - ' + adjstmentRec.Type;
            if(adjstmentRec.Type == 'Factory' || adjstmentRec.Type == 'Dealer') {
                memo += ' Option';
            }
            memo += ' cost';
            memo += ' adjusted by $' + (adjstmentRec.TotalCost != null ? adjstmentRec.TotalCost : 0);
            this.DocNumber = adjstmentRec.RefrenceNumber; // FIFOBucketRecord.Name
            this.TxnDate = adjstmentRec.CreatedDate;
            this.PrivateNote = memo;
            this.Line = new List<LineWrapper>();
            String invAdjustmentsAccId = AccountingUtil.getChartofAccount('Inventory Adjustments');
            
            List<Category__c> defaultCategory = [select Name, Inventory_GL__c, COGS_GL__c from Category__c
                                                    where Type__c = 'Unit' AND Active__c = true AND Default__c = true]; 
            
            String glNumber;
            if(adjstmentRec.UnitStatus == 'Available' || adjstmentRec.UnitStatus == 'Reserved') {
                glNumber = adjstmentRec.Inventory_GL != null ? adjstmentRec.Inventory_GL : defaultCategory[0].Inventory_GL__c;
            } else {
                glNumber = adjstmentRec.COGS_GL != null ? adjstmentRec.COGS_GL : defaultCategory[0].Inventory_GL__c;
            }
            
            AccountingUnitPriceAndCost.EntityRefWrapper entity; // null entity
            if(adjstmentRec.TotalCost > 0) {
                this.Line.add(new LineWrapper(memo, adjstmentRec.TotalCost, invAdjustmentsAccId, 'Credit', adjstmentRec.EntityRef));
                this.Line.add(new LineWrapper(memo, adjstmentRec.TotalCost, glNumber, 'Debit', entity));
            } else {
                this.Line.add(new LineWrapper(memo, adjstmentRec.TotalCost * -1, invAdjustmentsAccId, 'Debit', adjstmentRec.EntityRef));
                this.Line.add(new LineWrapper(memo, adjstmentRec.TotalCost * -1, glNumber, 'Credit', entity));
            }
        }
        
        public QuickBooksJournalEntry(AccountingPart partRec) {
            partRec.PartNumber = partRec.PartNumber != null ? partRec.PartNumber : '';
            String memo = partRec.PartNumber + ';Category changed';
            String description = partRec.PartNumber + ' - Category changed from ' + partRec.OldCategoryName + ' to ' + partRec.NewCategoryName;
            this.DocNumber = partRec.PartNumber.length() > 21 ? partRec.PartNumber.substring(0, 21) : partRec.PartNumber;
            this.TxnDate = partRec.ModifiedDate;
            this.PrivateNote = memo;
            this.Line = new List<LineWrapper>();
            String entityRef = null;
            if(partRec.TotalInventoryValuation > 0) {
                this.Line.add(new LineWrapper(description, partRec.TotalInventoryValuation, partRec.OldCategoryInventoryGL, 'Credit', entityRef));
                this.Line.add(new LineWrapper(description, partRec.TotalInventoryValuation, partRec.NewCategoryInventoryGL, 'Debit', entityRef));
            } else {
                this.Line.add(new LineWrapper(description, partRec.TotalInventoryValuation * -1, partRec.OldCategoryInventoryGL, 'Debit', entityRef));
                this.Line.add(new LineWrapper(description, partRec.TotalInventoryValuation * -1, partRec.NewCategoryInventoryGL, 'Credit', entityRef));
            }
        }
        
        public QuickBooksJournalEntry(AccountingUnit unitRec) {
            unitRec.StockNumber = unitRec.StockNumber != null ? unitRec.StockNumber : '';
            String memo = unitRec.StockNumber + ';Category changed';
            String description = unitRec.StockNumber + ' - Category changed from ' + unitRec.OldCategoryName + ' to ' + unitRec.NewCategoryName;
            this.DocNumber = unitRec.StockNumber.length() > 21 ? unitRec.StockNumber.substring(0, 21) : unitRec.StockNumber;
            this.TxnDate = unitRec.ModifiedDate;
            this.PrivateNote = memo;
            this.Line = new List<LineWrapper>();
            String entityRef = null;
            if(unitRec.TotalInventoryValuation > 0) {
                this.Line.add(new LineWrapper(description, unitRec.TotalInventoryValuation, unitRec.OldCategoryInventoryGL, 'Credit', entityRef));
                this.Line.add(new LineWrapper(description, unitRec.TotalInventoryValuation, unitRec.NewCategoryInventoryGL, 'Debit', entityRef));
            } else {
                this.Line.add(new LineWrapper(description, unitRec.TotalInventoryValuation * -1, unitRec.OldCategoryInventoryGL, 'Debit', entityRef));
                this.Line.add(new LineWrapper(description, unitRec.TotalInventoryValuation * -1, unitRec.NewCategoryInventoryGL, 'Credit', entityRef));
            }
        }
        
        public QuickBooksJournalEntry(AccountingDealItem dealItemRec) {
            String memo = dealItemRec.COHeaderNumber + ';Stocked Trade In';
            String description = 'Trade In-';
            description += dealItemRec.UnitDescription;
            description += String.isNotBlank(dealItemRec.UnitDescription) ? '-' : '';
            description += 'Trade Value @';
            description += String.valueOf(dealItemRec.ActualCashValue);
            this.DocNumber = dealItemRec.COHeaderNumber.length() > 21 ? dealItemRec.COHeaderNumber.substring(0, 21) : dealItemRec.COHeaderNumber;
            this.TxnDate = dealItemRec.StockedInDate;
            this.PrivateNote = memo;
            this.Line = new List<LineWrapper>();
            String entityRef = null;
            if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Category__c> defaultStockedTradeCategoryList = [SELECT Income_GL__c FROM Category__c WHERE Type__c = 'Stocked Trade' AND Default__c = true AND Active__c = true];
            String stockedTradeIncomeGL = defaultStockedTradeCategoryList.size() > 0 ? defaultStockedTradeCategoryList[0].Income_GL__c : '';
            if(dealItemRec.ActualCashValue > 0) {
                this.Line.add(new LineWrapper(description, dealItemRec.ActualCashValue, dealItemRec.InventoryGL, 'Debit', entityRef));
                this.Line.add(new LineWrapper(description, dealItemRec.ActualCashValue, stockedTradeIncomeGL, 'Credit', entityRef));
            } else {
                this.Line.add(new LineWrapper(description, dealItemRec.ActualCashValue * -1, dealItemRec.InventoryGL, 'Credit', entityRef));
                this.Line.add(new LineWrapper(description, dealItemRec.ActualCashValue * -1, stockedTradeIncomeGL, 'Debit', entityRef));
            }
        }
     }

     public class LineWrapper {
        public String Description;
        public Decimal Amount;
        public String DetailType;
        public JournalEntryLineDetailWrapper JournalEntryLineDetail;
        
        public LineWrapper(String description, Decimal Amount, Decimal UnitQtyAmount, COInvoiceJournalEntryService.QuickBooksCustomerInvoiceItemsHelper COInvoiceJournalEntryRecord, String AccountRef, String postingType, Boolean DealUnitLineForDealMerchOrService, Boolean isInternalServiceTax) {
            UnitQtyAmount = UnitQtyAmount != null ? UnitQtyAmount.setScale(2, RoundingMode.HALF_UP) : 0;
            COInvoiceJournalEntryRecord.Qty = COInvoiceJournalEntryRecord.Qty != null ? COInvoiceJournalEntryRecord.Qty.setScale(2, RoundingMode.HALF_UP) : 0;
            if(isInternalServiceTax) {
                this.Description = COInvoiceJournalEntryRecord.Description;
            } else if(DealUnitLineForDealMerchOrService) {
                this.Description = COInvoiceJournalEntryRecord.DealUnitDescription;
            } else {
                this.Description = description + COInvoiceJournalEntryRecord.Description + ' ' + COInvoiceJournalEntryRecord.Qty + '@' + UnitQtyAmount; /////////
            }
            this.Amount = Amount.setScale(2, RoundingMode.HALF_UP);
            if(this.Amount < 0) {
                this.Amount *= -1;
            }
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType);   
                
        }

        public LineWrapper(String description, Decimal Amount, String AccountRef, String postingType, AccountingVendorReceiving.EntityRefWrapper EntityRef) {
            this.Description = description ;
            this.Amount = Amount.setScale(2, RoundingMode.HALF_UP);
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType, EntityRef);   
        } 
        
        public LineWrapper(AccountingFIFOBucket FIFOBucketRecord, String AccountRef, String postingType, AccountingFIFOBucket.EntityRefWrapper EntityRef) {
            FIFOBucketRecord.Cost = FIFOBucketRecord.Cost != null ? FIFOBucketRecord.Cost.setScale(2, RoundingMode.HALF_UP) : 0;
            String description = FIFOBucketRecord.PartNumber + ' - increased by '+ FIFOBucketRecord.QtyIn + '@$' + FIFOBucketRecord.Cost;
            this.Description = description;
            if(FIFOBucketRecord.Total < 0) {
                this.Amount = FIFOBucketRecord.Total * -1;
            } else {
                this.Amount = FIFOBucketRecord.Total;
            }
            this.Amount = this.Amount.setScale(2, RoundingMode.HALF_UP);
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType, EntityRef);   
        }
         
        public LineWrapper(AccountingFIFOBucketActivityLineItem FIFOBucketActivityLineItemRecord, String AccountRef, String postingType, AccountingFIFOBucketActivityLineItem.EntityRefWrapper EntityRef) {
            FIFOBucketActivityLineItemRecord.Cost = FIFOBucketActivityLineItemRecord.Cost != null ? FIFOBucketActivityLineItemRecord.Cost.setScale(2, RoundingMode.HALF_UP) : 0;
            String description = FIFOBucketActivityLineItemRecord.PartNumber + ' - reduced by '+ FIFOBucketActivityLineItemRecord.QtyOut + '@$' + FIFOBucketActivityLineItemRecord.Cost;
            if(FIFOBucketActivityLineItemRecord.FIFOSource == 'Oversold'){
                description = FIFOBucketActivityLineItemRecord.PartNumber + ' - resolved oversold of '+ (FIFOBucketActivityLineItemRecord.QtyOut*-1) + '@$' + FIFOBucketActivityLineItemRecord.Cost;
            }
            if(FIFOBucketActivityLineItemRecord.Reference == 'Vendor Return'){
                description = FIFOBucketActivityLineItemRecord.PartNumber + ' - Returned '+ FIFOBucketActivityLineItemRecord.QtyOut + '@$' + FIFOBucketActivityLineItemRecord.Cost;
            }
            this.Description = description;
            this.Amount = FIFOBucketActivityLineItemRecord.Cost * FIFOBucketActivityLineItemRecord.QtyOut; /////////
            if(this.Amount < 0) {
                this.Amount = this.Amount * -1;
                this.Amount = this.Amount.setScale(2, RoundingMode.HALF_UP);
            }
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType, EntityRef);   
        }
        
        public LineWrapper(String description, Decimal Amount, String AccountRef, String postingType, AccountingCOInvoicePayment.CustomerWrapper EntityRef) {
            this.Description = description ; 
            this.Amount = Amount.setScale(2, RoundingMode.HALF_UP);
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType, EntityRef);   
        }
         
        public LineWrapper(String description, Decimal Amount, String AccountRef, String postingType, AccountingVendorInvoice.VendorWrapper EntityRef) {
            this.Description = description ; 
            this.Amount = Amount.setScale(2, RoundingMode.HALF_UP);
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType, EntityRef);   
        }
        
        public LineWrapper(String description, Decimal Amount, String AccountRef, String postingType, AccountingCODeposit.CustomerWrapper EntityRef) {
            this.Description = description ; 
            this.Amount = Amount.setScale(2, RoundingMode.HALF_UP);
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType, EntityRef);
        }
        
        public LineWrapper(String description, Decimal Amount, String AccountRef, String postingType, AccountingStoreCredit.CustomerWrapper EntityRef) {
            this.Description = description ; 
            this.Amount = Amount.setScale(2, RoundingMode.HALF_UP);
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType, EntityRef);    
        }
        
        public LineWrapper(String description, Decimal Amount, String AccountRef, String postingType, AccountingUnitPriceAndCost.EntityRefWrapper EntityRef) {
            this.Description = description ; 
            this.Amount = Amount.setScale(2, RoundingMode.HALF_UP);
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType, EntityRef); 
        }
        
        public LineWrapper(String description, Decimal Amount, String AccountRef, String postingType, String EntityRef) {
            this.Description = description ; 
            this.Amount = Amount.setScale(2, RoundingMode.HALF_UP);
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType, EntityRef);   
        }
        
        public LineWrapper(String description, Decimal Amount, String AccountRef, String postingType) {
            this.Description = description;
            this.Amount = Amount.setScale(2, RoundingMode.HALF_UP);
            if(this.Amount < 0) {
            	this.Amount *= -1;
            }
            this.DetailType = 'JournalEntryLineDetail';   
            this.JournalEntryLineDetail = new JournalEntryLineDetailWrapper(AccountRef, postingType); 
        }
     }
     
     public class JournalEntryLineDetailWrapper{
        
        public String PostingType;
        public AccountRefWrapper AccountRef;
        public EntityWrapper Entity;
        
        public JournalEntryLineDetailWrapper(String AccountRef, String postingType) { //AccountingCustomerInvoice.AccountingCOInvoiceItem
            this.PostingType = postingType; 
            this.AccountRef = new AccountRefWrapper(AccountRef);
        }
         
        public JournalEntryLineDetailWrapper(String AccountRef, String postingType, AccountingVendorReceiving.EntityRefWrapper EntityRef) { //AccountingCustomerInvoice.AccountingCOInvoiceItem
            this.PostingType = postingType; 
            this.AccountRef = new AccountRefWrapper(AccountRef);
            if(EntityRef != null) {
                this.Entity = new EntityWrapper(EntityRef);
            }
        }
         
        public JournalEntryLineDetailWrapper(String AccountRef, String postingType, AccountingFIFOBucket.EntityRefWrapper EntityRef) { //AccountingCustomerInvoice.AccountingCOInvoiceItem
            this.PostingType = postingType; 
            this.AccountRef = new AccountRefWrapper(AccountRef);
            if(EntityRef != null) {
                this.Entity = new EntityWrapper(EntityRef);
            }
        }
         
        public JournalEntryLineDetailWrapper(String AccountRef, String postingType, AccountingFIFOBucketActivityLineItem.EntityRefWrapper EntityRef) { //AccountingCustomerInvoice.AccountingCOInvoiceItem
            this.PostingType = postingType; 
            this.AccountRef = new AccountRefWrapper(AccountRef);
            if(EntityRef != null) {
                this.Entity = new EntityWrapper(EntityRef);
            }
        }
         
        public JournalEntryLineDetailWrapper(String AccountRef, String postingType, AccountingCOInvoicePayment.CustomerWrapper EntityRef) { //AccountingCustomerInvoice.AccountingCOInvoiceItem
            this.PostingType = postingType; 
            this.AccountRef = new AccountRefWrapper(AccountRef);
            if(EntityRef != null) {
                this.Entity = new EntityWrapper(EntityRef);
            }
        }
         
        public JournalEntryLineDetailWrapper(String AccountRef, String postingType, AccountingVendorInvoice.VendorWrapper EntityRef) { //AccountingCustomerInvoice.AccountingCOInvoiceItem
            this.PostingType = postingType; 
            this.AccountRef = new AccountRefWrapper(AccountRef);
            if(EntityRef != null) {
                this.Entity = new EntityWrapper(EntityRef);
            }
        }

        public JournalEntryLineDetailWrapper(String AccountRef, String postingType, AccountingCODeposit.CustomerWrapper EntityRef) { //AccountingCustomerInvoice.AccountingCOInvoiceItem
            this.PostingType = postingType; 
            this.AccountRef = new AccountRefWrapper(AccountRef);
            if(EntityRef != null) {
                this.Entity = new EntityWrapper(EntityRef);
            }
        }
        
        public JournalEntryLineDetailWrapper(String AccountRef, String postingType, AccountingStoreCredit.CustomerWrapper EntityRef) {
            this.PostingType = postingType; 
            this.AccountRef = new AccountRefWrapper(AccountRef);
            if(EntityRef != null) {
                this.Entity = new EntityWrapper(EntityRef);
            }
        }
        
        public JournalEntryLineDetailWrapper(String AccountRef, String postingType, AccountingUnitPriceAndCost.EntityRefWrapper EntityRef) {
            this.PostingType = postingType; 
            this.AccountRef = new AccountRefWrapper(AccountRef);
            if(EntityRef != null) {
                this.Entity = new EntityWrapper(EntityRef);
            }
        }
        
        public JournalEntryLineDetailWrapper(String AccountRef, String postingType, String EntityRef) {
            this.PostingType = postingType; 
            this.AccountRef = new AccountRefWrapper(AccountRef);
            if(EntityRef != null) {
                this.Entity = new EntityWrapper(EntityRef);
            }
        }
     }
    
     public class AccountRefWrapper{
        public String value;
        
        public AccountRefWrapper(String AccountRef) {
            this.value = AccountRef;
        }
     }
    
     public class EntityWrapper{
        public EntityRefWrapper EntityRef;
        
        public EntityWrapper(AccountingVendorReceiving.EntityRefWrapper EntityRef) {
            this.EntityRef = new EntityRefWrapper(EntityRef);
        }
         
        public EntityWrapper(AccountingFIFOBucket.EntityRefWrapper EntityRef) {
            this.EntityRef = new EntityRefWrapper(EntityRef);
        }
         
        public EntityWrapper(AccountingFIFOBucketActivityLineItem.EntityRefWrapper EntityRef) {
            this.EntityRef = new EntityRefWrapper(EntityRef);
        }
        
        public EntityWrapper(AccountingCOInvoicePayment.CustomerWrapper EntityRef) {
            this.EntityRef = new EntityRefWrapper(EntityRef);
        }
         
        public EntityWrapper(AccountingVendorInvoice.VendorWrapper EntityRef) {
            this.EntityRef = new EntityRefWrapper(EntityRef);
        }

        public EntityWrapper(AccountingCODeposit.CustomerWrapper EntityRef) {
            this.EntityRef = new EntityRefWrapper(EntityRef);
        }
        
        public EntityWrapper(AccountingStoreCredit.CustomerWrapper EntityRef) {
            this.EntityRef = new EntityRefWrapper(EntityRef);
        }
        
        public EntityWrapper(AccountingUnitPriceAndCost.EntityRefWrapper EntityRef) {
            this.EntityRef = new EntityRefWrapper(EntityRef);
        }
        
        public EntityWrapper(String EntityRef) {
            this.EntityRef = new EntityRefWrapper(EntityRef);
        }
     }
     
     public class EntityRefWrapper{
        public String value;
        
        public String name;
        
        public EntityRefWrapper(AccountingVendorReceiving.EntityRefWrapper EntityRef) {
            this.value = EntityRef.AccountingId;
            this.name = EntityRef.Name;
        }
         
        public EntityRefWrapper(AccountingFIFOBucket.EntityRefWrapper EntityRef) {
            this.value = EntityRef.AccountingId;
            this.name = EntityRef.Name;
        }
         
        public EntityRefWrapper(AccountingFIFOBucketActivityLineItem.EntityRefWrapper EntityRef) {
            this.value = EntityRef.AccountingId;
            this.name = EntityRef.Name;
        }
        
        public EntityRefWrapper(AccountingCOInvoicePayment.CustomerWrapper EntityRef) {
            this.value = EntityRef.AccountingId;
            this.name = EntityRef.Name;
        }
         
        public EntityRefWrapper(AccountingVendorInvoice.VendorWrapper EntityRef) {
            this.value = EntityRef.AccountingId;
            this.name = EntityRef.Name;
        }

        public EntityRefWrapper(AccountingCODeposit.CustomerWrapper EntityRef) {
            this.value = EntityRef.AccountingId;
            this.name = EntityRef.Name;
        }
        
        public EntityRefWrapper(AccountingStoreCredit.CustomerWrapper EntityRef) {
            this.value = EntityRef.AccountingId;
            this.name = EntityRef.Name;
        }
        
        public EntityRefWrapper(AccountingUnitPriceAndCost.EntityRefWrapper EntityRef) {
            this.value = EntityRef.AccountingId;
            this.name = EntityRef.Name;
        }
        
        public EntityRefWrapper(String EntityRef) {
            this.value = EntityRef;
        }
     }

     
     public class ResponseQuickBooksJournalEntry {
        public QuickBooksJournalEntry JournalEntry;
     }
}