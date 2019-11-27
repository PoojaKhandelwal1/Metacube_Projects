public with sharing class MerchandiseService {
    
    public static String deleteCOLI(String coLineItemId) {
    	try{
    		String dealId;
	    	if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        
	        coLineItemId = BPUtility.escapeSingleQuotes(coLineItemId);
	        List<CO_Line_Item__c> coLineItemToDelete = [select CO_Header__c, Closed_CO_Invoice_link__c, Deal__c from CO_Line_Item__c where Id = :coLineItemId];
	        String coHeaderId = coLineItemToDelete.size() > 0 ? coLineItemToDelete[0].CO_Header__c : '';
	        if(coLineItemToDelete.size() > 0 && String.isBlank(coLineItemToDelete[0].Closed_CO_Invoice_link__c)) {
	            dealId = coLineItemToDelete[0].Deal__c;
	            CustomerOrderCtrl.createDealUnresolvedFulfillment(new List<String>{coLineItemToDelete[0].Id}, dealId, Constants.UNRESOLVED_FULFILLMENT_TYPE_REMOVED);
	            if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
	            delete coLineItemToDelete;
	            COService.validateAndCloseCO(coHeaderId);
	        }
	        
	        return dealId;
       	}catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    public static String insertMerchKit(String lineItemId, String coHeaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsCreateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            
            if(String.isBlank(coHeaderId)) {
                coHeaderId = BPUtility.getDecodedString(BPGlobalHeaderCtrl.createCustomerOrder());  
            }
            List<Kit_Header__c> kitHeaderList = SOQLUtil.getKitHeaderRec(new Map<String, String>{ 'Id' => lineItemId });
            if(kitHeaderList.size() == 0 || kitHeaderList[0].Service_Kit__c) {
                return coHeaderId;
            }
            
            CO_Kit_Header__c cokhRec = new CO_Kit_Header__c();
            cokhRec.CO_Header__c = coHeaderId;
            cokhRec.Kit_Header__c = kitHeaderList[0].Id;
            cokhRec.Price__c = kitHeaderList[0].Fixed_Price__c;
            cokhRec.Actual_Kit_Price__c = kitHeaderList[0].Fixed_Price__c;
            cokhRec.Can_Split__c = kitHeaderList[0].Can_Split__c;
            cokhRec.Fixed_Price_Flag__c = kitHeaderList[0].Fixed_Price_Flag__c;
            cokhRec.Service_Kit__c = kitHeaderList[0].Service_Kit__c;
            
            insert cokhRec;
            COLineItemTriggerHelper.isTotalCalculated = true;
            insertAllKitLineItemsInMerchGrid(lineItemId, coHeaderId, cokhRec.Id, null);            
            COLineItemTriggerHelper.isTotalCalculated = false;
            
        //COKH_Recalcualtion.CoKitInsert(cokhRec.Id, coHeaderId) ;
        COKH_Recalcualtion.calculatePriceForCOKitInsertion(cokhRec.Id, coHeaderId);
            COService.updateMerchSectionToDisplay(coHeaderId, false);
            return (!COLineItemTriggerHelper.isMoveLineItem ? coHeaderId : cokhRec.Id);
    }
    
    /**
    * Name: insertAllKitLineItemsInMerchGrid
    * Desc: Method to insert all line item in merch Grid
    * @param:   (1) lineItemId - String - id of line item
                (2) coHeaderId - String - id of coHeader 
                (3) cokhRecId - String - id of co kit header 
    * @return: void 
    **/
    public static void insertAllKitLineItemsInMerchGrid(String lineItemId, String coHeaderId, String cokhRecId, String dealId) {
        if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        
        List<Kit_Header_Line_Item__c> khLineItemList = SOQLUtil.getKHLineItemRec(new Map<String, String>{ 'Kit_Header__c' => lineItemId });
        if(khLineItemList.size() == 0) {
            return;
        }
        //system.assert(false,khLineItemList);
        List<CO_Line_Item__c> coliListToInsert = new List<CO_Line_Item__c>();
        for(Kit_Header_Line_Item__c khliRec : khLineItemList) {
            CO_Line_Item__c coliRec = new CO_Line_Item__c(Kit_Header_Line_Item__c = khliRec.Id);
            
            coliRec.CO_Header__c = coHeaderId;
            coliRec.CO_Kit_Header__c = cokhRecId;
            coliRec.Deal__c = dealId;
            if(khliRec.Part__c != null) {
                coliRec.Part__c = khliRec.Part__c;
                coliRec.Actual_Retail_Price__c = khliRec.Part__r.Retail_Price__c;
            } else if(khliRec.Fee__c != null) { // Removed else if comment by Pooja 21 Nov. 2016 (Issue# '$' icon is not displayed for Fee in Kit in CO Merchandise section)
                coliRec.Fee__c = khliRec.Fee__c;
            }
            coliRec.Fixed_Price__c = khliRec.Fixed_Price__c;
            coliRec.Price_When_Tax_Included__c = coliRec.Price__c = coliRec.Actual_Kit_Price__c = khliRec.Kit_Price__c;
            coliRec.Qty__c = khliRec.Qty_Needed__c;
            coliRec.Item_Code__c = khliRec.Item_Code__c;
            coliRec.Item_Description__c = khliRec.Item_Description__c;
            coliListToInsert.add(coliRec);
        }
        if(coliListToInsert.size() > 0) {
            insert coliListToInsert;
        }
    }
    
    
    /**
    * Name: removeCOKHItems
    * Desc: Method to remove kit header items
    * @param:   (1) lineItemId - String - id of line item
    * @return: void
    **/
    public static String removeCOKHItems(String lineItemId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        lineItemId = BPUtility.escapeSingleQuotes(lineItemId);
        List<CO_Kit_Header__c> cokhList = [select Id, Deal__c, CO_Header__c, (Select Id from CO_Line_Items__r) from CO_Kit_Header__c where Id =: lineItemId];
        String coHeaderId = cokhList.size() > 0 ? cokhList[0].CO_Header__c : '';
        String dealId;
        if(cokhList.size() > 0) {
            dealId = cokhList[0].Deal__c;
        }
        List<CO_Line_Item__c> coliListToDelete = new List<CO_Line_Item__c>();
        for(CO_Kit_Header__c cokhRec : cokhList) {
            if(cokhRec.CO_Line_Items__r != null && cokhRec.CO_Line_Items__r.size() > 0) {
                coliListToDelete.addAll(cokhRec.CO_Line_Items__r);
            }
        }
        
        CustomerOrderCtrl.createDealUnresolvedFulfillment(new List<String>{cokhList[0].Id}, dealId, Constants.UNRESOLVED_FULFILLMENT_TYPE_REMOVED);
        
        if(coliListToDelete.size() > 0) {
            delete coliListToDelete;
        }
        if(cokhList.size() > 0) {
            delete cokhList;
            COService.validateAndCloseCO(coHeaderId);
        }
        
        return dealId;
    }
    
    
    public static void splitCOKHItem(String lineItemId, String coHeaderId) {
    	if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectIsDeletable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        lineItemId = BPUtility.escapeSingleQuotes(lineItemId);
        List<CO_Kit_Header__c> cokhList = [select Id,
                                            (select CO_Header__c, Qty__c, Part__c, Fee__c from CO_Line_items__r)     
                                            from CO_Kit_Header__c where Id =: lineItemId];
        
        List<CO_Line_Item__c> coLineItemListToInsert = new List<CO_Line_Item__c>();
        List<CO_Line_Item__c> coLineItemListToDelete = new List<CO_Line_Item__c>();
        
        for(CO_Kit_Header__c cokhRec : cokhList) {
            for(CO_Line_Item__c coliRec : cokhRec.CO_Line_items__r) {
                CO_Line_Item__c newCOLIRec = new CO_Line_Item__c();
                newCOLIRec.CO_Header__c = coliRec.CO_Header__c;
                newCOLIRec.Qty__c = coliRec.Qty__c;
                newCOLIRec.Part__c = coliRec.Part__c;
                newCOLIRec.Fee__c = coliRec.Fee__c;
                //CO_Line_Item__c newCOLIRec = coliRec.clone(false, true, false, false);
                coLineItemListToInsert.add(newCOLIRec);
                coLineItemListToDelete.add(coliRec);
            }
        }
        
        if(coLineItemListToDelete.size() > 0) {
            delete coLineItemListToDelete;
        }
        
        if(cokhList.size() > 0) {
            delete cokhList;
        }
        
        if(coLineItemListToInsert.size() > 0) {
            insert coLineItemListToInsert;
        }
	}
	
    public static String updateCOKHLineItemsRecalculation(String cokhJSON, String coHeaderId, String cokliJson) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        COHeaderWrapper.COKitHeader cokhObj = (COHeaderWrapper.COKitHeader) System.JSON.deserialize(cokhJSON, COHeaderWrapper.COKitHeader.class);            
        if(cokliJson != 'null') {    
			COLineItem  coli = (COLineItem) System.JSON.deserialize(cokliJson, COLineItem.class);
            if(String.isNotBlank(coli.FeeId)) {
                CO_Line_Item__c  coliToUpdate  = [select Id, Item_Description__c from CO_Line_Item__c where Id =:coli.CoLineItemId ];
                if(coliToUpdate.Item_Description__c != coli.ItemDescription){
                    coliToUpdate.Item_Description__c = coli.ItemDescription;
                    if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update coliToUpdate;
                }                       
            }
            if(!coli.IsFixedPrice && (String.isNotBlank(coli.PartId) || String.isNotBlank(coli.FeeId))) {
                String Result = COKH_Recalcualtion.UpdateKitLineItem(cokhObj, coli, coHeaderId);
                SO_KLI_Recalculation.Errorhandler error = (Result != 'Success') ? new SO_KLI_Recalculation.Errorhandler('300',Result) : new SO_KLI_Recalculation.Errorhandler('200','Saved Successfully');
            }
        } else {    
            if(!cokhObj.IsFixedPrice){
                String Result = COKH_Recalcualtion.UpdateKitHeader(cokhObj);                                
                SO_KLI_Recalculation.Errorhandler error = (Result != 'Success') ? new SO_KLI_Recalculation.Errorhandler('300',Result) : new SO_KLI_Recalculation.Errorhandler('200','Saved Successfully');
            }  
        }
        
        return cokhObj.DealId;           
    }
    
    public static void insertKitHeaderInDealMerchGrid(String kitHeaderId, String dealId, String coHeaderId) {
    	if(AccessControl.ifObjectFieldIsCreateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
    	List<Kit_Header__c> kitHeaderList = SOQLUtil.getKitHeaderRec(new Map<String, String>{ 'Id' => kitHeaderId });
        if(kitHeaderList.size() == 0 || kitHeaderList[0].Service_Kit__c) {
            return;
        }
        
        CO_Kit_Header__c cokhRec = new CO_Kit_Header__c();
        cokhRec.CO_Header__c = coHeaderId;
        cokhRec.Kit_Header__c = kitHeaderList[0].Id;
        cokhRec.Price__c = kitHeaderList[0].Fixed_Price__c;
        cokhRec.Actual_Kit_Price__c = kitHeaderList[0].Fixed_Price__c;
        cokhRec.Can_Split__c = kitHeaderList[0].Can_Split__c;
        cokhRec.Fixed_Price_Flag__c = kitHeaderList[0].Fixed_Price_Flag__c;
        cokhRec.Service_Kit__c = kitHeaderList[0].Service_Kit__c;
        cokhRec.Deal__c = dealId;
        insert cokhRec;
        MerchandiseService.insertAllKitLineItemsInMerchGrid(kitHeaderId, coHeaderId, cokhRec.Id, dealId);
        
        //COKH_Recalcualtion.CoKitInsert(cokhRec.Id, coHeaderId);
        COKH_Recalcualtion.calculatePriceForCOKitInsertion(cokhRec.Id, coHeaderId);
        CustomerOrderCtrl.createDealUnresolvedFulfillment(new List<String>{cokhRec.Id}, dealId, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);            
    }
    
    public static List<ViewKitCtrl.KitHeaderLineItem> getOutOfStockPartsInKit(String kitHeaderId) {
		List<ViewKitCtrl.KitHeaderLineItem> khliObjList = new List<ViewKitCtrl.KitHeaderLineItem>();
		List<Kit_Header_Line_Item__c> khliRecList = SOQLUtil.getKHLineItemRec(new Map<String, String>{'Kit_Header__c' => kitHeaderId});
		for(Kit_Header_Line_Item__c khliRec : khliRecList) {
			if(khliRec.Part__r.AvailableParts__c < khliRec.Qty_Needed__c) {
				khliObjList.add(new ViewKitCtrl.KitHeaderLineItem(khliRec));
			}
		}
		return khliObjList;
    }
    
    public static void oversoldKit(String kitHeaderJSON) {
		COHeaderWrapper.COKitHeader cokhObj = (COHeaderWrapper.COKitHeader) System.JSON.deserialize(kitHeaderJSON, COHeaderWrapper.COKitHeader.class);
		List<CO_Line_Item__c> coliListToUpdate = new List<CO_Line_Item__c>();
		for(COLineItem coliObj : cokhObj.COLIList) {
			coliListToUpdate.add(new CO_Line_Item__c(Id = coliObj.CoLineItemId, Qty_Committed__c = coliObj.Qty));
		}
        update coliListToUpdate;
    }
    
    public static Map<String, ProfitabilityWrapper.SectionProfitabilityWrapper> getMerchAndDealMerchProfitability(String coId) {
    	Map<String, ProfitabilityWrapper.SectionProfitabilityWrapper> sectionTypeToProfitabilityWrapperMap = 
    		new Map<String, ProfitabilityWrapper.SectionProfitabilityWrapper>();
    	
    	List<CO_Line_Item__c> coliList = [SELECT Item_ID__c, Closed_CO_Invoice_link__c, Part__r.Average_Cost__c, Part__c, Fee__c, Part__r.Part_Type__c, Qty__c, Price__c, Deal__c, Price_When_Tax_Included__c, 
        	Fee_Cost__c, Adjusted_Cost_Coli__c, Fee__r.Is_Include_In_Profit_Calculation__c, Fee__r.Cost_Method__c, Fee__r.Cost_Rate__c FROM CO_Line_Item__c WHERE Service_Order_Line_Item__c = null AND CO_Header__c =: coId];
       
        Boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Decimal partTotal = 0;      
       	if(coliList.size() > 0) {
       		Decimal totalCOPartSales, totalCOMerchSales, totalDealPartSales, totalDealMerchSales, totalCOFeeSales, totalDealFeeSales;
	       	Decimal totalCOPartCost, totalCOMerchCost, totalDealPartCost, totalDealMerchCost, totalCOFeeCost, totalDealFeeCost = 0;
	       	totalCOPartCost = totalCOMerchCost = totalDealPartCost = totalDealMerchCost = totalCOFeeCost = totalDealFeeCost = 0;
	       	
			for(CO_Line_Item__c coli : coliList) {
	        	coli.Price__c = (coli.Price__c != null) ? coli.Price__c : 0;
	           	coli.Qty__c = (coli.Qty__c != null) ? coli.Qty__c : 0;
	           	if(coli.Part__c != null) {
	           		if(String.isNotBlank(coli.Part__r.Part_Type__c) && coli.Part__r.Part_Type__c == 'Merchandise') {
	           			if(String.isNotBlank(coli.Deal__c)) {
	           				totalDealMerchSales = (totalDealMerchSales != null) ? totalDealMerchSales : 0;
							totalDealMerchSales += (coli.Qty__c * coli.Price__c).setScale(2, RoundingMode.HALF_UP);
		               		totalDealMerchCost += (coli.Closed_CO_Invoice_link__c != null ? (coli.Adjusted_Cost_Coli__c != null ? coli.Adjusted_Cost_Coli__c : 0) :
		               			(coli.Part__r.Average_Cost__c != null ? (coli.Part__r.Average_Cost__c * coli.Qty__c) : 0));
		               	} else {
		               		totalCOMerchSales = (totalCOMerchSales != null) ? totalCOMerchSales : 0;
		               		totalCOMerchSales += (coli.Qty__c * coli.Price__c).setScale(2, RoundingMode.HALF_UP);
		               		totalCOMerchCost += (coli.Closed_CO_Invoice_link__c != null ? (coli.Adjusted_Cost_Coli__c != null ? coli.Adjusted_Cost_Coli__c : 0) :
		               			(coli.Part__r.Average_Cost__c != null ? (coli.Part__r.Average_Cost__c * coli.Qty__c) : 0));
		               	}
	           		} else {
		               	if(String.isNotBlank(coli.Deal__c)) {
		               		totalDealPartSales = (totalDealPartSales != null) ? totalDealPartSales : 0;
							totalDealPartSales += (coli.Qty__c * coli.Price__c).setScale(2, RoundingMode.HALF_UP);
		               		totalDealPartCost += (coli.Closed_CO_Invoice_link__c != null ? (coli.Adjusted_Cost_Coli__c != null ? coli.Adjusted_Cost_Coli__c : 0) :
		               			(coli.Part__r.Average_Cost__c != null ? (coli.Part__r.Average_Cost__c * coli.Qty__c) : 0));              		
		               	} else {
		               		totalCOPartSales = (totalCOPartSales != null) ? totalCOPartSales : 0;
		               		totalCOPartSales += (coli.Qty__c * coli.Price__c).setScale(2, RoundingMode.HALF_UP);
		               		totalCOPartCost += (coli.Closed_CO_Invoice_link__c != null ? (coli.Adjusted_Cost_Coli__c != null ? coli.Adjusted_Cost_Coli__c : 0) :
		               			(coli.Part__r.Average_Cost__c != null ? (coli.Part__r.Average_Cost__c * coli.Qty__c) : 0));
		               	}
	           		}
	    		} else if(coli.Fee__c != null && coli.Fee__r.Is_Include_In_Profit_Calculation__c) {
	           		if(String.isNotBlank(coli.Deal__c)) {
	           			totalDealFeeSales = (totalDealFeeSales != null) ? totalDealFeeSales : 0;
	               		totalDealFeeSales += (coli.Qty__c * coli.Price__c).setScale(2, RoundingMode.HALF_UP);
	               		if(coli.Fee__r.Cost_Method__c == 'Fixed Cost' && coli.Fee__r.Cost_Rate__c != null && coli.Qty__c != null) {
	                		totalDealFeeCost += (coli.Closed_CO_Invoice_link__c != null ? (coli.Fee_Cost__c != null ? coli.Fee_Cost__c : 0) 
	                								: (coli.Qty__c * coli.Fee__r.Cost_Rate__c));  
	                	} else if(coli.Fee__r.Cost_Method__c == 'Percent Retail' && coli.Fee__r.Cost_Rate__c != null && coli.Qty__c != null) {
	                    	totalDealFeeCost += (coli.Closed_CO_Invoice_link__c != null ? (coli.Fee_Cost__c != null ? coli.Fee_Cost__c : 0) 
	                								: (coli.Qty__c * ((coli.Price__c * coli.Fee__r.Cost_Rate__c) /100))); 
	                	} 
	               	} else {
	               		totalCOFeeSales = (totalCOFeeSales != null) ? totalCOFeeSales : 0;
	               		totalCOFeeSales += (coli.Qty__c * coli.Price__c).setScale(2, RoundingMode.HALF_UP);
						if(coli.Fee__r.Cost_Method__c == 'Fixed Cost' && coli.Fee__r.Cost_Rate__c != null && coli.Qty__c != null) {
		                    totalCOFeeCost += (coli.Closed_CO_Invoice_link__c != null ? (coli.Fee_Cost__c != null ? coli.Fee_Cost__c : 0) 
	                								: (coli.Qty__c * coli.Fee__r.Cost_Rate__c)); 
		                } else if(coli.Fee__r.Cost_Method__c == 'Percent Retail' && coli.Fee__r.Cost_Rate__c != null && coli.Qty__c != null) {
		                    totalCOFeeCost += (coli.Closed_CO_Invoice_link__c != null ? (coli.Fee_Cost__c != null ? coli.Fee_Cost__c : 0) 
	                								: (coli.Qty__c * ((coli.Price__c * coli.Fee__r.Cost_Rate__c) /100))); 
	                	}
	               	}
	       		}
			}
            
			List<ProfitabilityWrapper.ProductProfitabilityWrapper> merchProductProfitabilityObjList = new List<ProfitabilityWrapper.ProductProfitabilityWrapper>(); 
			List<ProfitabilityWrapper.ProductProfitabilityWrapper> dealMerchProductProfitabilityObjList = new List<ProfitabilityWrapper.ProductProfitabilityWrapper>();
			
            //Merchandise
			if(totalCOPartSales != null) {
				merchProductProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Parts', totalCOPartSales, totalCOPartCost));
			}
			if(totalCOMerchSales != null) { 
				merchProductProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Merchandise', totalCOMerchSales, totalCOMerchCost));
			}
			if(totalCOFeeSales != null) {
				merchProductProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Fees', totalCOFeeSales, totalCOFeeCost));
			}
			
			//Deal Merchandise
			if(totalDealPartSales != null) {
				dealMerchProductProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Parts', totalDealPartSales, totalDealPartCost));
			}
			if(totalDealMerchSales != null) {
				dealMerchProductProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Merchandise', totalDealMerchSales, totalDealMerchCost));
			}
       		if(totalDealFeeSales != null) {
				dealMerchProductProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Fees', totalDealFeeSales, totalDealFeeCost));
			}
       		if(merchProductProfitabilityObjList.size() > 0) {
       			sectionTypeToProfitabilityWrapperMap.put('Parts & Accessories', new ProfitabilityWrapper.SectionProfitabilityWrapper('Parts & Accessories', merchProductProfitabilityObjList));
			}
			if(dealMerchProductProfitabilityObjList.size() > 0) {
				sectionTypeToProfitabilityWrapperMap.put('Deal Merchandise', new ProfitabilityWrapper.SectionProfitabilityWrapper('Deal Merchandise', dealMerchProductProfitabilityObjList));
			}
       	}
       	return sectionTypeToProfitabilityWrapperMap;
    }
    
     public static void populateMerchIndividualsCostTotalsAfterFinalize(String coInvoiceId) {
    	List<CO_Line_Item__c> coliList = [SELECT Fee__c, Qty__c, Price__c, Deal__c, Fee__r.Is_Include_In_Profit_Calculation__c, Fee__r.Cost_Method__c, 
    										Fee__r.Cost_Rate__c FROM CO_Line_Item__c WHERE Service_Order_Line_Item__c = null AND Invoice_Number__c =: coInvoiceId];
       
       	if(coliList.size() > 0) {
        	for(CO_Line_Item__c coli : coliList) {
	        	coli.Price__c = (coli.Price__c != null) ? coli.Price__c : 0;
	           	coli.Qty__c = (coli.Qty__c != null) ? coli.Qty__c : 0;
	           	if(coli.Fee__c != null && coli.Fee__r.Is_Include_In_Profit_Calculation__c) {
                	if(coli.Fee__r.Cost_Method__c == 'Fixed Cost' && coli.Fee__r.Cost_Rate__c != null && coli.Qty__c != null) {
                		coli.Fee_Cost__c = (coli.Qty__c * coli.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
                	} else if(coli.Fee__r.Cost_Method__c == 'Percent Retail' && coli.Fee__r.Cost_Rate__c != null && coli.Qty__c != null) {
                    	coli.Fee_Cost__c = (coli.Qty__c * ((coli.Price__c * coli.Fee__r.Cost_Rate__c) /100)).setScale(2, RoundingMode.HALF_UP);
                	}
	       		} 
			}
			update coliList;
       	}
    }
    
    public static String updatePartsAndAccessoriesSetting(String coHeaderJson) {
    	CustomerOrderWrapper.COHeader coHeaderObj = (CustomerOrderWrapper.COHeader) system.JSON.deserialize(coHeaderJson, CustomerOrderWrapper.COHeader.class);
    	if(String.isBlank(coHeaderObj.COHeaderId)) {
    		return 'Error: Customer order id is blank';
     	}
    	List<CO_Header__c> coHeaderRecList = [Select Id, Merchandise_Commit_Order_controls__c, (Select Id from CO_Line_Items__r 
    										where Is_In_Merch_Section__c = true AND Closed_CO_Invoice_link__c = null) 
    										from CO_Header__c where Id =: coHeaderObj.COHeaderId];
    	if(coHeaderRecList.size() > 0 ) {
    		CO_Header__c coHeaderRec = new CO_Header__c(Id = coHeaderObj.COHeaderId, Merchandise_Commit_Order_controls__c = coHeaderObj.MerchandiseCommitOrdercontrols, 
    										Merchandise_Transaction_Type__c= coHeaderObj.MerchandiseTransactionType);
    		if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }								
    		update coHeaderRec;
    		
    		if(coHeaderRecList[0].Merchandise_Commit_Order_controls__c != coHeaderObj.MerchandiseCommitOrdercontrols && coHeaderRecList[0].CO_Line_Items__r.size() > 0) {
    			if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }	
    			for(CO_Line_Item__c coliRec : coHeaderRecList[0].CO_Line_Items__r) {
    				coliRec.Merchandise_Commit_Order_controls__c = coHeaderObj.MerchandiseCommitOrdercontrols;
    			}
    			update coHeaderRecList[0].CO_Line_Items__r;
    		}
    	} else {
    		return 'Error: Customer order does not exists';
    	}
    	return 'Success';
    }
}