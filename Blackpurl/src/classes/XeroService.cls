/**
 * Author: Gaurav Tak
 * Since: February 15, 2019
 * Name: XeroService
**/
public without sharing class XeroService extends BaseIntegrationService {
    
    public XeroService(IFW_IntegrationConfig__c integrationConfigRec) {
        this.integrationConfigRec = integrationConfigRec;
        this.integrationName = integrationConfigRec.Integration_Name__c;
        this.failedRecordsMap = new Map<String, List<Object>>();
        
       /*to be removed*/
        /*BP_Configurations__c config = BP_Configurations__c.getOrgDefaults();
        config.Org_Base_Url__c = System.Url.getSalesforceBaseUrl().toExternalForm();
        upsert config;*/
    }
    
    public override Map<String, List<Object>> getAndResetFailedRecordsMap() {
        Map<String, List<Object>> failedMap = this.failedRecordsMap.clone();
        this.failedRecordsMap = new Map<String, List<Object>>();
        return failedMap;
    }
    
    public void writeToFailedRecordsMap(String key, List<Object> failedObjects) {
        if(!this.failedRecordsMap.containsKey(key)) {
            this.failedRecordsMap.put(key, new List<Object>());
        }
        this.failedRecordsMap.get(key).addAll(failedObjects);
    }
    
    public override List<WebService_Log__c> sync(List<Object> syncObjList, List<sObject> sobjListToSync, String entityType, Map<String, String> xeroEntityNameToActionMap) {
        List<IFW_IntegrationConfigItem__c> integrationConfigItemList = getIntegrationConfigItemByFieldValues(integrationConfigRec.Id, xeroEntityNameToActionMap);
        try {
            if(integrationConfigItemList.size() == 0) throw new BlackpurlException('Endpoint configurations not defined');
            Map<String, List<Object>> payload;
            if(entityType == IntegrationUtility.ITEM_CATEGORY) {
                payload = createItemCategoryPayload(syncObjList);
            } else if(entityType == IntegrationUtility.PART_FIFO) {
                payload = createPartFifoBucketPayload(syncObjList);
            } else if(entityType == IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM) {
                payload = createPartFifoBucketActivityLineItemPayload(syncObjList);
            } else if(entityType == IntegrationUtility.PART_CATEGORY) {
                payload = createPartCategoryPayload(syncObjList);
            } else if(entityType == IntegrationUtility.CO_DEPOSIT) {
                payload = createCODepositPayload(syncObjList);
            } else if(entityType == IntegrationUtility.VENDOR) {
                payload = createVendorPayload(syncObjList);
            } else if(entityType == IntegrationUtility.CO_INVOICE_PAYMENT) {
                payload = createCOInvoicePaymentPayload(syncObjList);
            } else if(entityType == IntegrationUtility.CUSTOMER) {
                payload = createCustomerPayload(syncObjList);
            } else if(entityType == IntegrationUtility.STORE_CREDIT) {
                payload = createStoreCreditPayload(syncObjList);
            } else if(entityType == IntegrationUtility.UNIT_PRICE_COST) {
                payload = createUnitPriceAndCostPayload(syncObjList);
            } else if(entityType == IntegrationUtility.VENDOR_RECEIVING) {
                //system.assert(false, syncObjList);
                payload = createVendorReceivingPayload(syncObjList);
            } else if(entityType == IntegrationUtility.STOCK_UNIT_CATEGORY) {
                payload = createStockUnitCategoryPayload(syncObjList);
            } else if(entityType == IntegrationUtility.INVOICE) {
                payload = createCOInvoicePayload(syncObjList);
            } else if(entityType == IntegrationUtility.STOCK_TRADE_IN) {
                payload = createStockTradeInPayload(syncObjList);
            } else if(entityType == IntegrationUtility.LIEN_PAYOUT) {
                payload = createLienpayoutPayload(syncObjList);
            } else if(entityType == IntegrationUtility.VO_INVOICE) {
                payload = createVOInvoicePayload(syncObjList);
            } else if(entityType == IntegrationUtility.INVOICE_PAYMENT) {
                payload = createInvoicePaymentPayload(syncObjList, sobjListToSync);
            } else if(entityType == IntegrationUtility.CO_INVOICE_JE) {
                payload = createCOInvoiceJEPayload(syncObjList);
                List<XeroJournalEntryDTO> requestCOJEList = (List<XeroJournalEntryDTO>)payload.get('ManualJournals');
                for(Object obj: payload.get('ManualJournals')) {
		            XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
		            if(reqJournalEntryObj != null && reqJournalEntryObj.JournalLines != null && reqJournalEntryObj.JournalLines.size() == 0) {
		            	CO_Invoice_Header__c coInvoiceHeaderToUpdate = new CO_Invoice_Header__c();
		                coInvoiceHeaderToUpdate.Id = requestCOJEList[0].SFId;
		                coInvoiceHeaderToUpdate.Available_For_Xero_CO_Invoice_JE_Sync__c = false;
		                coInvoiceHeaderToUpdate.AccountingResponseForJournalEntry__c = QBUtil.CO_INVOICE_NO_JE_MSG;
		                coInvoiceHeaderToUpdate.accountingLastSyncTimeForJE__c = system.now();
		                sobjListToSync.add(coInvoiceHeaderToUpdate);
		                return (BaseIntegration.webServiceLogs != null ? BaseIntegration.webServiceLogs : new List<WebService_Log__c>());
		            }
		        }
            } else if(entityType == IntegrationUtility.VO_RETURN) {
                payload = createVOReturnPayload(syncObjList);
            } else if(entityType == IntegrationUtility.UNIT_INVOICE) {
                payload = createUnitInvoicePayload(syncObjList);
            }
            
            String requestBody = System.JSON.serialize(payload, true);
            if(entityType == IntegrationUtility.INVOICE || entityType == IntegrationUtility.VO_INVOICE || entityType == IntegrationUtility.LIEN_PAYOUT || entityType == IntegrationUtility.INVOICE_PAYMENT || entityType == IntegrationUtility.UNIT_INVOICE) {
                requestBody = requestBody.replace('"InvDate":', '"Date":');
            }
             if(entityType == IntegrationUtility.PART_FIFO || entityType == IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM || entityType == IntegrationUtility.STOCK_TRADE_IN || entityType == IntegrationUtility.CO_INVOICE_PAYMENT || entityType == IntegrationUtility.PART_CATEGORY || entityType == IntegrationUtility.UNIT_PRICE_COST || entityType == IntegrationUtility.CO_DEPOSIT || entityType == IntegrationUtility.VENDOR_RECEIVING || entityType == IntegrationUtility.VENDOR_RECEIVING || entityType == IntegrationUtility.CO_INVOICE_JE) {
                requestBody = requestBody.replace('"JournalDate":', '"Date":');
            }
            HttpResponse response = BaseIntegration.performCallout(integrationConfigRec, integrationConfigItemList[0], requestBody, new List<customHttpHeaderWrapper>());
            handleResponse(response, payload, sobjListToSync, entityType);
            if(entityType == IntegrationUtility.INVOICE) {
            	AccountingCustomerInvoice customerInvoiceRec = (AccountingCustomerInvoice)syncObjList[0];
            	if(customerInvoiceRec.AccountingCOInvoiceHeaderRec.totalPaymentExcludingChargeAccount != 0) {
            		syncCOInvoicePayment(syncObjList, sobjListToSync, IntegrationUtility.INVOICE_PAYMENT); 
            	}
            }
        } catch(HttpRequestException e) {
            // request has an failure http response code
            // a webservice log is already created for http request failure
            // therefore we do not need a log to be inserted here 
            this.writeToFailedRecordsMap(e.getMessage(), syncObjList);
        } catch (Exception e) {
            //insert BP logs
            this.errorLogs.add(new LogService().createErrorLog('XeroService', 'sync()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              syncObjList+'', LogService.XERO, false,'Error'));
        }
        return (BaseIntegration.webServiceLogs != null ? BaseIntegration.webServiceLogs : new List<WebService_Log__c>());
    }
    
    private Map<String, List<XeroItemDTO>> createItemCategoryPayload(List<Object> syncObjList) {
        List<XeroItemDTO> xeroDTOList = new List<XeroItemDTO>();
        for(Object accCategoryObj : syncObjList) {
            xeroDTOList.add(new XeroItemDTO((AccountingItemCategory)accCategoryObj));
        }
        return new Map<String, List<XeroItemDTO>>{'Items' => xeroDTOList};
    }
    
    private Map<String, List<XeroJournalEntryDTO>> createPartFifoBucketPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object accPartFifoBucketObj : syncObjList) {
            xeroDTOList.add(new XeroJournalEntryDTO((AccountingFIFOBucket) accPartFifoBucketObj)); 
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
    private Map<String, List<XeroJournalEntryDTO>> createCOInvoicePaymentPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object accCOInvoicePayment : syncObjList) {
            xeroDTOList.add(new XeroJournalEntryDTO((AccountingCOInvoicePayment) accCOInvoicePayment)); 
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
    private Map<String, List<XeroJournalEntryDTO>> createPartFifoBucketActivityLineItemPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object accPartFifoBucketActivityLineitemObj : syncObjList) {
            xeroDTOList.add(new XeroJournalEntryDTO((AccountingFIFOBucketActivityLineItem)accPartFifoBucketActivityLineitemObj)); 
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
    private Map<String, List<XeroJournalEntryDTO>> createPartCategoryPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object accPartObj : syncObjList) {
            xeroDTOList.add(new XeroJournalEntryDTO((AccountingPart) accPartObj)); 
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
    private Map<String, List<XeroJournalEntryDTO>> createCODepositPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object coDepositObj : syncObjList) {
            xeroDTOList.add(new XeroJournalEntryDTO((AccountingCODeposit) coDepositObj)); 
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
    private Map<String, List<XeroContactDTO>> createVendorPayload(List<Object> syncObjList) {
        List<XeroContactDTO> xeroDTOList = new List<XeroContactDTO>();
        for(Object vendorObj : syncObjList) {
            xeroDTOList.add(new XeroContactDTO((AccountingVendor) vendorObj)); 
        }
        return new Map<String, List<XeroContactDTO>>{'Contacts' => xeroDTOList};
    }
    
     private Map<String, List<XeroContactDTO>> createCustomerPayload(List<Object> syncObjList) {
        List<XeroContactDTO> xeroDTOList = new List<XeroContactDTO>();
        for(Object customerObj : syncObjList) {
            xeroDTOList.add(new XeroContactDTO((AccountingCustomer) customerObj)); 
        }
        return new Map<String, List<XeroContactDTO>>{'Contacts' => xeroDTOList};
    }
    
     private Map<String, List<XeroJournalEntryDTO>> createStoreCreditPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object accStoreCreditObj : syncObjList) {
            xeroDTOList.add(new XeroJournalEntryDTO((AccountingStoreCredit)accStoreCreditObj)); 
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
     private Map<String, List<XeroJournalEntryDTO>> createUnitPriceAndCostPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object accUnitPriceAndCostObj : syncObjList) {
            xeroDTOList.add(new XeroJournalEntryDTO((AccountingUnitPriceAndCost)accUnitPriceAndCostObj)); 
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
    private Map<String, List<XeroJournalEntryDTO>> createVendorReceivingPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object vendorReceivingObj : syncObjList) {
        	//system.assert(false,vendorReceivingObj);
            xeroDTOList.add(new XeroJournalEntryDTO((AccountingVendorReceiving) vendorReceivingObj)); 
            //system.assert(false,xeroDTOList);
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
    private Map<String, List<XeroJournalEntryDTO>> createStockUnitCategoryPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object stockUnitObj : syncObjList) {
            xeroDTOList.add(new XeroJournalEntryDTO((AccountingUnit) stockUnitObj)); 
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
   private Map<String, List<XeroJournalEntryDTO>> createStockTradeInPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object dealItemObj : syncObjList) {
            xeroDTOList.add(new XeroJournalEntryDTO((AccountingDealItem) dealItemObj)); 
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
    private Map<String, List<XeroBaseInvoiceDTO>> createCOInvoicePayload(List<Object> syncObjList) {
    	AccountingCustomerInvoice accountingCustomerInvoiceObj = (AccountingCustomerInvoice)syncObjList[0];
    	String syncObjectName = '';
    	XeroBaseInvoiceDTO xeroInvoiceDTOObj;
        if(accountingCustomerInvoiceObj.AccountingCOInvoiceHeaderRec.InvoiceTotal < 0) {
        	syncObjectName = 'CreditNotes';
        	xeroInvoiceDTOObj = new XeroCreditNoteDTO(accountingCustomerInvoiceObj);
        } else {
        	syncObjectName = 'Invoices';
        	xeroInvoiceDTOObj = new XeroInvoiceDTO(accountingCustomerInvoiceObj);
        }
        return new Map<String, List<XeroBaseInvoiceDTO>>{syncObjectName => new List<XeroBaseInvoiceDTO>{xeroInvoiceDTOObj}};
    }
    
    private Map<String, List<XeroBaseInvoiceDTO>> createVOInvoicePayload(List<Object> syncObjList) {
        AccountingVendorInvoice vendorInvoiceObj = (AccountingVendorInvoice)syncObjList[0];
        return new Map<String, List<XeroBaseInvoiceDTO>>{'Invoices' => new List<XeroBaseInvoiceDTO>{new XeroInvoiceDTO(vendorInvoiceObj)}};
    }
    
    private Map<String, List<XeroBaseInvoiceDTO>> createVOReturnPayload(List<Object> syncObjList) {
        AccountingVendorReturn vendorReturnObj = (AccountingVendorReturn)syncObjList[0];
        return new Map<String, List<XeroCreditNoteDTO>>{'CreditNotes' => new List<XeroCreditNoteDTO>{new XeroCreditNoteDTO(vendorReturnObj)}};
    }
    
	private Map<String, List<XeroBaseInvoiceDTO>> createUnitInvoicePayload(List<Object> syncObjList) {
		List<XeroBaseInvoiceDTO> xeroDTOList = new List<XeroBaseInvoiceDTO>();
		for(Object unitObj : syncObjList) {
			xeroDTOList.add(new XeroInvoiceDTO((AccountingUnit) unitObj));
		}	
		return new Map<String, List<XeroBaseInvoiceDTO>>{'Invoices' => xeroDTOList};
	}
    
    private Map<String, List<XeroInvoicePaymentDTO>> createInvoicePaymentPayload(List<Object> syncObjList, List<sObject> sobjListToSync) {
        AccountingCustomerInvoice customerInvoiceObj = (AccountingCustomerInvoice)syncObjList[0];
        CO_Invoice_Header__c coInvoiceRecObj = (CO_Invoice_Header__c)sobjListToSync[0];
        return new Map<String, List<XeroInvoicePaymentDTO>>{'Payments' => new List<XeroInvoicePaymentDTO>{new XeroInvoicePaymentDTO(customerInvoiceObj, coInvoiceRecObj)}};
    }
    
    private Map<String, List<XeroLienPayoutDTO>> createLienpayoutPayload(List<Object> syncObjList) {
    	List<XeroLienPayoutDTO> xeroDTOList = new List<XeroLienPayoutDTO>();
    	for(Object lienPayout : syncObjList) {
            xeroDTOList.add(new XeroLienPayoutDTO((AccountingLienPayout) lienPayout)); 
        }
        return new Map<String, List<XeroLienPayoutDTO>>{'Invoices' => xeroDTOList};
    }
    
    private Map<String, List<XeroJournalEntryDTO>> createCOInvoiceJEPayload(List<Object> syncObjList) {
        List<XeroJournalEntryDTO> xeroDTOList = new List<XeroJournalEntryDTO>();
        for(Object coInvoiceJEObj : syncObjList) {
			xeroDTOList.add(new XeroJournalEntryDTO((AccountingCustomerInvoice)coInvoiceJEObj)); 
        }
        return new Map<String, List<XeroJournalEntryDTO>>{'ManualJournals' => xeroDTOList};
    }
    
    private void handleResponse(HttpResponse response, Map<String, List<Object>> payload, List<sObject> sobjListToSync, String entityType) {
        if(String.valueOf(response.getStatusCode()) == '200') {
            handleSuccessResponse(response.getBody(), payload, sobjListToSync, entityType);
        } else {
            //Error Handling
            handleErrorResponse(response);
        }
    }
    
    private void handleSuccessResponse(String responseBody, Map<String, List<Object>> payload, List<sObject> sobjListToSync, String entityType) {
        XeroResponseWrapper xeroResponseWrapper = (XeroResponseWrapper) System.JSON.deserialize(responseBody, XeroResponseWrapper.class);
        if(entityType == IntegrationUtility.ITEM_CATEGORY) {
            handleItemCategoryResponse(xeroResponseWrapper, payload, (List<Category__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.PART_FIFO) {
            handlePartFIFOBucketResponse(xeroResponseWrapper, payload, (List<Part_FIFO_Bucket__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM) {
            handlePartFIFOBucketActivityLineItemResponse(xeroResponseWrapper, payload, (List<Part_FIFO_Bucket_Activity_Line_Item__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.PART_CATEGORY) {
            handlePartCategoryResponse(xeroResponseWrapper, payload, (List<Part__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.CO_DEPOSIT) {
            handleCODepositResponse(xeroResponseWrapper, payload, (List<CO_Deposit__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.VENDOR) {
            handleVendorResponse(xeroResponseWrapper, payload, (List<Account>)sobjListToSync);
        } else if(entityType == IntegrationUtility.CO_INVOICE_PAYMENT) {
            handleCOInvoicePaymentResponse(xeroResponseWrapper, payload, (List<CO_Invoice_Payment__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.CUSTOMER) {
            handleCustomerResponse(xeroResponseWrapper, payload, (List<Account>)sobjListToSync);
        } else if(entityType == IntegrationUtility.STORE_CREDIT) {
            handleStoreCreditResponse(xeroResponseWrapper, payload, (List<Store_Credit__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.UNIT_PRICE_COST) {
            handleUnitPriceAndCostResponse(xeroResponseWrapper, payload, (List<Unit_Price_Cost__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.STOCK_UNIT_CATEGORY) {
            handleStockUnitCategoryResponse(xeroResponseWrapper, payload, (List<Customer_Owned_Unit__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.VENDOR_RECEIVING) {
            handleVendorReceivingResponse(xeroResponseWrapper, payload, (List<Vendor_Receiving_Header__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.INVOICE) {
            handleCOInvoiceResponse(xeroResponseWrapper, payload, (List<CO_Invoice_Header__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.STOCK_TRADE_IN) {
            handleStockTradeInResponse(xeroResponseWrapper, payload, (List<Deal_Item__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.VO_INVOICE) {
            handleVOInvoiceResponse(xeroResponseWrapper, payload, (List<Deal_Item__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.INVOICE_PAYMENT) {
            handleInvoicePaymentResponse(xeroResponseWrapper, payload, (List<CO_Invoice_Header__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.LIEN_PAYOUT) {
            handleLienPayoutResponse(xeroResponseWrapper, payload, (List<Deal_Item__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.CO_INVOICE_JE) {
            handleCOInvoiceJEResponse(xeroResponseWrapper, payload, (List<CO_Invoice_Header__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.VO_RETURN) {
            handleVOReturnResponse(xeroResponseWrapper, payload, (List<Return_VO_Header__c>)sobjListToSync);
        } else if(entityType == IntegrationUtility.UNIT_INVOICE) {
            handleUnitInvoiceResponse(xeroResponseWrapper, payload, (List<Customer_Owned_Unit__c>)sobjListToSync);
        }   
    }
    
    private void handleErrorResponse(HttpResponse httpResponse) {
        HttpErrorDTO errorResponse = (HttpErrorDTO) System.JSON.deserialize(httpResponse.getBody(), HttpErrorDTO.class);
        throw new HttpRequestException(errorResponse.Type);
    }
    
    private void handleItemCategoryResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.Items != null && !xeroResponseWrapper.Items.isEmpty()) {
        	for(Object obj: payload.get('Items')) { // assuming there is a single request and response object
	            XeroItemDTO reqItemObj = (XeroItemDTO)obj;
	            Category__c categoryObjToUpdate = new Category__c();
		        categoryObjToUpdate.Id = reqItemObj.SFId;
		        categoryObjToUpdate.Available_For_Xero_Sync__c = false;
		        categoryObjToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.Items[0].ItemID;
		        categoryObjToUpdate.AccountingResponse__c = (xeroResponseWrapper.Items[0] + '').abbreviate(32768);
		        categoryObjToUpdate.accountingLastSyncTime__c = system.now();
            	categoryObjToUpdate.QB_Updated_Fields__c = null;
		        sobjListToSync.add(categoryObjToUpdate);
	        }
        }
    }
    
    private void handlePartFIFOBucketResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
        	for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
	            XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
	            Part_FIFO_Bucket__c partFIFOBucketToUpdate = new Part_FIFO_Bucket__c();
	            partFIFOBucketToUpdate.Id = reqJournalEntryObj.SFId;
	            partFIFOBucketToUpdate.Available_For_Xero_Sync__c = false;
	            partFIFOBucketToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
	            partFIFOBucketToUpdate.AccountingResponse__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
		        partFIFOBucketToUpdate.accountingLastSyncTime__c = system.now();
		        sobjListToSync.add(partFIFOBucketToUpdate);
	        }
        }
    }
    
    private void handlePartFIFOBucketActivityLineItemResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
        	for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
	            XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
	            Part_FIFO_Bucket_Activity_Line_Item__c partFIFOBucketActivityLineItemToUpdate = new Part_FIFO_Bucket_Activity_Line_Item__c();
	            partFIFOBucketActivityLineItemToUpdate.Id = reqJournalEntryObj.SFId;
	            partFIFOBucketActivityLineItemToUpdate.Available_For_Xero_Sync__c = false;
	            partFIFOBucketActivityLineItemToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
	            partFIFOBucketActivityLineItemToUpdate.AccountingResponse__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
		        partFIFOBucketActivityLineItemToUpdate.accountingLastSyncTime__c = system.now();
		        sobjListToSync.add(partFIFOBucketActivityLineItemToUpdate);
	        }
        }
    }
    
    private void handlePartCategoryResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
        	for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
	            XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
	            Part__c partCategoryToUpdate = new Part__c();
	            partCategoryToUpdate.Id = reqJournalEntryObj.SFId;
	            partCategoryToUpdate.Available_For_Xero_Sync__c = false;
	            partCategoryToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
	            partCategoryToUpdate.Accounting_Response_Category__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
		        partCategoryToUpdate.Accounting_Last_Sync_Time_Category__c = system.now();
		        sobjListToSync.add(partCategoryToUpdate);
	        }
        }
    }
    
    private void handleCODepositResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
        	for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
	            XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
	            CO_Deposit__c coDepositToUpdate = new CO_Deposit__c();
	            coDepositToUpdate.Id = reqJournalEntryObj.SFId;
	            coDepositToUpdate.Available_For_Xero_Sync__c = false;
	            coDepositToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
	            coDepositToUpdate.AccountingResponseForJournalEntry__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
		        coDepositToUpdate.accountingLastSyncTime__c = system.now();
		        sobjListToSync.add(coDepositToUpdate);
	        }
        }
    }
    
private void handleVendorResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<Account> sobjListToSync) {
        Map<String, XeroContactDTO> contactNumberToContactResponseMap = new Map<String, XeroContactDTO>();
        for(XeroContactDTO xeroObj : xeroResponseWrapper.Contacts) {
        	contactNumberToContactResponseMap.put(xeroObj.ContactNumber,xeroObj);
        }
        if(xeroResponseWrapper.Contacts != null && !xeroResponseWrapper.Contacts.isEmpty()) {
            for(Object obj: payload.get('Contacts')) { 
                XeroContactDTO reqVendorObj = (XeroContactDTO)obj;
                Account accToUpdate = new Account();
                accToUpdate.Id = reqVendorObj.SFId;
                accToUpdate.Available_For_Xero_Vendor_Sync__c = false;
                accToUpdate.Xero_Vendor_Accounting_Id__c = contactNumberToContactResponseMap.get(reqVendorObj.ContactNumber).ContactID;
                accToUpdate.Vendor_AccountingResponse__c = (contactNumberToContactResponseMap.get(reqVendorObj.ContactNumber) + '').abbreviate(32768);
                accToUpdate.Vendor_AccountingLastSyncTime__c = system.now();
                accToUpdate.Vendor_QB_Updated_Fields__c = null;
                accToUpdate.QB_Updated_Fields__c = null;
                sobjListToSync.add(accToUpdate);
            }
        } 
    }
    private void handleCustomerResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<Account> sobjListToSync) {
        Map<String, XeroContactDTO> contactNumberToContactResponseMap = new Map<String, XeroContactDTO>();
        for(XeroContactDTO xeroObj : xeroResponseWrapper.Contacts) {
        	contactNumberToContactResponseMap.put(xeroObj.ContactNumber,xeroObj);
        }
        if(xeroResponseWrapper.Contacts != null && !xeroResponseWrapper.Contacts.isEmpty()) {
            for(Object obj: payload.get('Contacts')) { 
                XeroContactDTO reqCustomerObj = (XeroContactDTO)obj;
                Account accToUpdate = new Account();
                accToUpdate.Id = reqCustomerObj.SFId;
                accToUpdate.Available_For_Xero_Customer_Sync__c = false;
                accToUpdate.Xero_Customer_Accounting_Id__c = contactNumberToContactResponseMap.get(reqCustomerObj.ContactNumber).ContactID;
                accToUpdate.AccountingResponse__c = (contactNumberToContactResponseMap.get(reqCustomerObj.ContactNumber) + '').abbreviate(32768);
                accToUpdate.accountingLastSyncTime__c = system.now();
                accToUpdate.QB_Updated_Fields__c = null;
                accToUpdate.Vendor_QB_Updated_Fields__c = null;
                sobjListToSync.add(accToUpdate);
            }
        } 
    }
    
    private void handleCOInvoicePaymentResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
            for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
                XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
                CO_Invoice_Payment__c coInvoicePaymentUpdate = new CO_Invoice_Payment__c();
                coInvoicePaymentUpdate.Id = reqJournalEntryObj.SFId;
                coInvoicePaymentUpdate.Available_For_Xero_Sync__c = false;
                coInvoicePaymentUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
                coInvoicePaymentUpdate.AccountingResponseForJournalEntry__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
                coInvoicePaymentUpdate.accountingLastSyncTime__c = system.now();
                sobjListToSync.add(coInvoicePaymentUpdate);
            }
        }
    }
    
   private void handleStoreCreditResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
        	for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
	            XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
	            Store_Credit__c storeCreditToUpdate = new Store_Credit__c();
	            storeCreditToUpdate.Id = reqJournalEntryObj.SFId;
	            storeCreditToUpdate.Available_For_Xero_Sync__c = false;
	            storeCreditToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
	            storeCreditToUpdate.AccountingResponse__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
		        storeCreditToUpdate.accountingLastSyncTime__c = system.now();
		        sobjListToSync.add(storeCreditToUpdate);
	        }
        }
    }
      
   private void handleUnitPriceAndCostResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
        	for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
	            XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
	            Unit_Price_Cost__c unitPriceAndCostToUpdate = new Unit_Price_Cost__c();
	            unitPriceAndCostToUpdate.Id = reqJournalEntryObj.SFId;
	            unitPriceAndCostToUpdate.Available_For_Xero_Sync__c = false;
	            unitPriceAndCostToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
	            unitPriceAndCostToUpdate.AccountingResponse__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
		        unitPriceAndCostToUpdate.accountingLastSyncTime__c = system.now();
		        sobjListToSync.add(unitPriceAndCostToUpdate);
	        }
        }
    }
    
    private void handleVendorReceivingResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
            for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
                XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
                Vendor_Receiving_Header__c vendorReceivingHeaderToUpdate = new Vendor_Receiving_Header__c();
                vendorReceivingHeaderToUpdate.Id = reqJournalEntryObj.SFId;
                vendorReceivingHeaderToUpdate.Available_For_Xero_Sync__c = false;
                vendorReceivingHeaderToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
                vendorReceivingHeaderToUpdate.AccountingResponseForJournalEntry__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
                vendorReceivingHeaderToUpdate.accountingLastSyncTime__c = system.now();
                sobjListToSync.add(vendorReceivingHeaderToUpdate);
            }
        }
    } 
    
    private void handleStockUnitCategoryResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
            for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
                XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
                Customer_Owned_Unit__c stockUnitToUpdate = new Customer_Owned_Unit__c();
                stockUnitToUpdate.Id = reqJournalEntryObj.SFId;
                stockUnitToUpdate.Available_For_Xero_JE_Sync__c = false;
                stockUnitToUpdate.Xero_JE_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
                stockUnitToUpdate.Accounting_Response_Category__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
                stockUnitToUpdate.Accounting_Last_Sync_Time_Category__c = system.now();
                sobjListToSync.add(stockUnitToUpdate);
            }
        }
    }
    
    private void handleCOInvoiceResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
    	String syncingObjectName;
    	if(xeroResponseWrapper.Invoices != null && !xeroResponseWrapper.Invoices.isEmpty()) {
    		syncingObjectName = 'Invoices';
        } else if(xeroResponseWrapper.CreditNotes != null && !xeroResponseWrapper.CreditNotes.isEmpty()) {
        	syncingObjectName = 'CreditNotes';
        }
        if(String.isNotBlank(syncingObjectName)) {
            for(Object obj: payload.get(syncingObjectName)) { // assuming there is a single request and response object
                XeroBaseInvoiceDTO reqCOInvoiceObj = (XeroBaseInvoiceDTO)obj;
                CO_Invoice_Header__c coInvoiceToUpdate = new CO_Invoice_Header__c();
                coInvoiceToUpdate.Id = reqCOInvoiceObj.SFId;
                coInvoiceToUpdate.Available_For_Xero_Sync__c = false;
                if(syncingObjectName == 'Invoices') {
                	coInvoiceToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.Invoices[0].InvoiceID;
                	coInvoiceToUpdate.AccountingResponse__c = (xeroResponseWrapper.Invoices[0] + '').abbreviate(32768);
                } else if(syncingObjectName == 'CreditNotes') {
                	coInvoiceToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.CreditNotes[0].CreditNoteID;
                	coInvoiceToUpdate.AccountingResponse__c = (xeroResponseWrapper.CreditNotes[0] + '').abbreviate(32768);
                }
                coInvoiceToUpdate.accountingLastSyncTime__c = system.now();
                sobjListToSync.add(coInvoiceToUpdate);
            }
        }
    }
    
    private void handleVOInvoiceResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        for(Object obj: payload.get('Invoices')) { // assuming there is a single request and response object
            XeroInvoiceDTO reqVOInvoiceObj = (XeroInvoiceDTO)obj;
            Vendor_Invoicing_Header__c voInvoiceRec = new Vendor_Invoicing_Header__c(Id = reqVOInvoiceObj.SFId);
            voInvoiceRec.Available_For_Xero_Sync__c = false;
            voInvoiceRec.Xero_Accounting_Id__c = xeroResponseWrapper.Invoices[0].InvoiceID;
            voInvoiceRec.AccountingResponse__c = (xeroResponseWrapper.Invoices[0] + '').abbreviate(32768);
            voInvoiceRec.accountingLastSyncTime__c = system.now();
            sobjListToSync.add(voInvoiceRec);
        }
    }
    
    private void handleInvoicePaymentResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.Payments != null && !xeroResponseWrapper.Payments.isEmpty()) {
            for(Object obj: payload.get('Payments')) { // assuming there is a single request and response object
            	CO_Invoice_Header__c coInvoiceToUpdate = (CO_Invoice_Header__c)sobjListToSync[0];
                coInvoiceToUpdate.Available_For_Xero_Invoice_Payment_Sync__c = false;
                coInvoiceToUpdate.Xero_CO_Invoice_Payment_Accounting_Id__c = xeroResponseWrapper.Payments[0].PaymentID;
                coInvoiceToUpdate.AccountingResponseForCOInvoicePayment__c = (xeroResponseWrapper.Payments[0] + '').abbreviate(32768);
                coInvoiceToUpdate.accountingLastSyncTimeForCOInvPayment__c = system.now();
            }
        }
    }
    
    private void handleLienPayoutResponse(XeroResponseWrapper xeroResponseWrapper,Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
    	for(Object obj: payload.get('Invoices')) { 
            XeroLienPayoutDTO reqLienPayoutObj = (XeroLienPayoutDTO)obj;
            Deal_Item__c dealItemRec = new Deal_Item__c(Id = reqLienPayoutObj.SFId);
            dealItemRec.Lien_Payout_Avail_For_Xero_Sync__c = false;
            dealItemRec.Lien_Payout_Xero_Accounting_Id__c = xeroResponseWrapper.Invoices[0].InvoiceID;
            dealItemRec.Lien_Payout_Accounting_Response__c = (xeroResponseWrapper.Invoices[0] + '').abbreviate(32768);
            dealItemRec.Lien_Payout_Accounting_Last_Sync_Time__c = system.now();
            sobjListToSync.add(dealItemRec);
        }
    }
    
    private void handleStockTradeInResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
            for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
                XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
                Deal_Item__c dealItemToUpdate = new Deal_Item__c();
                dealItemToUpdate.Id = reqJournalEntryObj.SFId;
                dealItemToUpdate.Available_For_Xero_Sync__c = false;
                dealItemToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
                dealItemToUpdate.Accounting_Response__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
                dealItemToUpdate.Accounting_Last_Sync_Time__c = system.now();
                sobjListToSync.add(dealItemToUpdate);
            }
        }
    }
    
    private void handleCOInvoiceJEResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        if(xeroResponseWrapper.ManualJournals != null && !xeroResponseWrapper.ManualJournals.isEmpty()) {
            for(Object obj: payload.get('ManualJournals')) { // assuming there is a single request and response object
                XeroJournalEntryDTO reqJournalEntryObj = (XeroJournalEntryDTO)obj;
                CO_Invoice_Header__c coInvoiceHeaderToUpdate = new CO_Invoice_Header__c();
                coInvoiceHeaderToUpdate.Id = reqJournalEntryObj.SFId;
                coInvoiceHeaderToUpdate.Available_For_Xero_CO_Invoice_JE_Sync__c = false;
                coInvoiceHeaderToUpdate.Xero_CO_Invoice_JE_Accounting_Id__c = xeroResponseWrapper.ManualJournals[0].ManualJournalID;
                coInvoiceHeaderToUpdate.AccountingResponseForJournalEntry__c = (xeroResponseWrapper.ManualJournals[0] + '').abbreviate(32768);
                coInvoiceHeaderToUpdate.accountingLastSyncTimeForJE__c = system.now();
                //system.assert(false, dealItemToUpdate);
                sobjListToSync.add(coInvoiceHeaderToUpdate);
            }
        }
    }
    
    private void handleVOReturnResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        for(Object obj: payload.get('CreditNotes')) { // assuming there is a single request and response object
            XeroBaseInvoiceDTO reqVOReturnObj = (XeroBaseInvoiceDTO)obj;
            
            Return_VO_Header__c voReturnToUpdate = new Return_VO_Header__c();
            voReturnToUpdate.Id = reqVOReturnObj.SFId;
            voReturnToUpdate.Available_For_Xero_Sync__c = false;
            voReturnToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.CreditNotes[0].CreditNoteID;
            voReturnToUpdate.AccountingResponse__c = (xeroResponseWrapper.CreditNotes[0] + '').abbreviate(32768);
            voReturnToUpdate.accountingLastSyncTime__c = system.now();
            sobjListToSync.add(voReturnToUpdate);
        }
    }
    
     private void handleUnitInvoiceResponse(XeroResponseWrapper xeroResponseWrapper, Map<String, List<Object>> payload, List<sObject> sobjListToSync) {
        for(Object obj: payload.get('Invoices')) { // assuming there is a single request and response object
            XeroBaseInvoiceDTO reqUnitInvoiceObj = (XeroBaseInvoiceDTO)obj;
            
            Customer_Owned_Unit__c unitToUpdate = new Customer_Owned_Unit__c();
            unitToUpdate.Id = reqUnitInvoiceObj.SFId;
            unitToUpdate.Available_For_Xero_Sync__c = false;
            unitToUpdate.Xero_Accounting_Id__c = xeroResponseWrapper.Invoices[0].InvoiceID;
            unitToUpdate.AccountingResponse__c = (xeroResponseWrapper.Invoices[0] + '').abbreviate(32768);
            unitToUpdate.accountingLastSyncTime__c = system.now();
            sobjListToSync.add(unitToUpdate);
        }
    }
    
    private List<WebService_Log__c> syncCOInvoicePayment(List<Object> syncObjList, List<sObject> sobjListToSync, String entityType) {
		Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{entityType => IntegrationUtility.CREATE_ACTION};
    	return sync(syncObjList, sobjListToSync, entityType, integrationEntityNameToActionMap);
    }
}