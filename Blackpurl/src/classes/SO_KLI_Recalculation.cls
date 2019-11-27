/**
 * Author: Ashish Garg
 * Since: Dec. 25, 2015
 * Name: SO_KLI_Recalculation
 * Description: Class is used for relacultaion logic perform for Service Order Kits line item recalculation
**/
public with sharing class SO_KLI_Recalculation {
    /**
     * Name: SOPriceCalcultaionByPriceLevel
     * Desc: Method to calculate kit price for all Service Orders under csutomer order Id passed in parameters.
     *       Kit price is as per the price level declared on customer added to customer order
     * @param:  1. Id customerId
     *          2. Id customerOrderId
     * @return:
    **
    public static void SOPriceCalcultaionByPriceLevel(Id customerId, Id customerOrderId) {
        SOPriceCalcultaionByPriceLevel(null, customerId, customerOrderId, null, null, null, null);
    }
      
    /**
     * Name: SOPriceCalcultaionByPriceLevelForServiceOrders
     * Desc: Method to calculate kit price for all Service Orders under csutomer order Id passed in parameters.
     *       Kit price is as per the price level declared on customer added to customer order
     * @param:  1. Id customerId
     *          2. Id customerOrderId
     *          3. List<Id> sohIds
     * @return:
    **
    public static void SOPriceCalcultaionByPriceLevelForServiceOrders(Id customerId, Id customerOrderId, List<Id> sohIds) {
        SOPriceCalcultaionByPriceLevel(null, customerId, customerOrderId, sohIds, null, null, null);
    }
    
    /**
     * Name: SOPriceCalcultaionByPriceLevelForSOKitHeaders
     * Desc: Method to calculate kit price for all Service Orders Kit Header records under csutomer order Id passed in parameters.
     *       Kit price is as per the price level declared on customer added to customer order
     * @param:  1. Id customerId
     *          2. Id customerOrderId
     *          3. List<Id> sokhIds
     * @return:
    **    
    public static void SOPriceCalcultaionByPriceLevelForSOKitHeaders(Id customerId, Id customerOrderId, List<Id> sokhIds, String soHeaderId) {
        SOPriceCalcultaionByPriceLevel(null, customerId, customerOrderId, null, sokhIds, null, soHeaderId);
    }
    
    /**
     * Name: SOPriceCalcultaionByPriceLevelForSOKitHeaderLIs
     * Desc: Method to calculate kit price for all Service Orders Kit Header Line Item records under csutomer order Id passed in parameters.
     *       Kit price is as per the price level declared on customer added to customer order
     * @param:  1. Id customerId
     *          2. Id customerOrderId
     *          3. List<Id> sokhIds
     * @return:
    **
    public static void SOPriceCalcultaionByPriceLevelForSOKitHeaderLIs(Id customerId, Id customerOrderId, List<Id> sokhliIds) {
        SOPriceCalcultaionByPriceLevel(null, customerId, customerOrderId, null, null, sokhliIds, null);
    }
    
    /**
     * Name: SOPriceCalcultaionByPriceLevel
     * Desc: Method to calculate kit price for all Service Orders under csutomer order Id passed in parameters.
     *       Kit price is as per the price level declared on customer added to customer order
     * @param:  1. Account customer     - Cutomer record associated with customer order
     *          2. Id customerId        - Customer Id
     *          3. Id customerOrderId   - Customer Order record Id
     *          4. List<Id> sohIds      - Ids list of service order header records for which price need to be calculated
     *          5. List<Id> sokhIds     - Ids list of service order Kit header records for which price need to be calculated
     *          6. List<Id> sokhliIds   - Ids list of service order Kit header Line Items records for which price need to be calculated
     * @return:
    **
    private static void SOPriceCalcultaionByPriceLevel(Account customer, Id customerId, Id customerOrderId, List<Id> sohIds, List<Id> sokhIds, List<Id> sokhliIds, String soHeaderId) {
        List<Service_Order_Header__c> soHeaderList = new List<Service_Order_Header__c>();
        List<Tax_Exemption__c> taxExtemptionList = new List<Tax_Exemption__c>(); 
        Boolean isInternalServiceTypeCO = false;
        if(soHeaderId != null) {
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            soHeaderList = [select Provider__c, Job_Type__c, Provider__r.Price_Level__r.Active__c, Provider__r.Price_Level__r.Discount_Markup__c, 
            							Provider_Discount_Markup__c, Provider_Labour_Rate__c, Provider_Part_Price_Base__c,
            							Provider__r.Price_Level__r.Part_Price_Base__c, 
            							Provider__r.Price_Level__r.Labour_Rate__c, CO_Header__c, CO_Header__r.Customer__c, CO_Header__r.CO_Type__c  
                                    from Service_Order_Header__c where Id = :soHeaderId];
                                    
    		customerOrderId = (String.isBlank(customerOrderId) && soHeaderList.size() > 0) ? soHeaderList[0].CO_Header__c : customerOrderId;
    		customerId = (String.isBlank(customerId) && soHeaderList.size() > 0) ? soHeaderList[0].CO_Header__r.Customer__c : customerId;
        }
        
        // Get the custoemr record by customer id
        if(customer == null && String.isNotBlank(customerId)){
            if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            customer = [SELECT  Id, 
                                Price_Level__c, 
                                Price_Level__r.Active__c, 
                                Price_Level__r.Part_Price_Base__c,
                                Price_Level__r.Discount_Markup__c, 
                                Price_Level__r.Labour_Rate__c 
                                FROM Account
                                WHERE Id =: customerId
                        ];
                       
        } else {
        	customer = new Account();
        }
        
        Price_Level__c priceLevel;
        if(soHeaderList.size() > 0 && soHeaderList[0].Provider__c != null && soHeaderList[0].Provider__r.Price_Level__c != null) {
            priceLevel = new Price_Level__c(Active__c = soHeaderList[0].Provider__r.Price_Level__r.Active__c,
            								Part_Price_Base__c = soHeaderList[0].Provider__r.Price_Level__r.Part_Price_Base__c,
                                            Discount_Markup__c = soHeaderList[0].Provider__r.Price_Level__r.Discount_Markup__c,
                                            Labour_Rate__c = soHeaderList[0].Provider__r.Price_Level__r.Labour_Rate__c
                                        );
            
            if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            taxExtemptionList = [select Id,Sales_Tax_Item__r.Rate__c,Sales_Tax_Item__c, Customer__c from Tax_Exemption__c where CO_Header__c =: soHeaderList[0].CO_Header__c];
        
        } else if(soHeaderList.size() > 0 && ((soHeaderList[0].Job_Type__c == 'Internal' && soHeaderList[0].CO_Header__r.CO_Type__c != 'Internal Service') || 
        	soHeaderList[0].Job_Type__c == 'Deal')) {
            priceLevel = new Price_Level__c(Active__c = true,
            								Part_Price_Base__c = soHeaderList[0].Provider_Part_Price_Base__c,
                                            Discount_Markup__c = soHeaderList[0].Provider_Discount_Markup__c,
                                            Labour_Rate__c = soHeaderList[0].Provider_Labour_Rate__c
                                        );
        	isInternalServiceTypeCO = true;    
        } else if(customer.Price_Level__r != null) {
            
            priceLevel = new Price_Level__c(Active__c = customer.Price_Level__r.Active__c,
											Part_Price_Base__c = customer.Price_Level__r.Part_Price_Base__c,
                                                        Discount_Markup__c = customer.Price_Level__r.Discount_Markup__c,
                                                        Labour_Rate__c = customer.Price_Level__r.Labour_Rate__c
                                                    );
			if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }                                                    
            taxExtemptionList = [select Id,Sales_Tax_Item__r.Rate__c,Sales_Tax_Item__c, Customer__c from Tax_Exemption__c where CO_Header__c =: customerOrderId];
            
        } else {
            if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Price_Level__c> defaultPriceLevel = new List<Price_Level__c>();
            if(soHeaderList.size() > 0 && soHeaderList[0].CO_Header__r.CO_Type__c == Constants.INTERNAL_SERVICE) {
            	String defaultPriceLevelId = GeneralConfiguration.getDefaultPriceLevelOnInternalService();
            	isInternalServiceTypeCO = true;
            	defaultPriceLevel = [SELECT Part_Price_Base__c, Discount_Markup__c, Labour_Rate__c, Active__c from Price_Level__c where Id =: defaultPriceLevelId];
            } else {
            	defaultPriceLevel = [select Part_Price_Base__c, Discount_Markup__c, Labour_Rate__c, Active__c from Price_Level__c where Default__c = true];
            }
            
            if(defaultPriceLevel.size() == 0) {
                return;
            }
            if(customerId !=null){
            	if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            	taxExtemptionList = [select Id,Sales_Tax_Item__r.Rate__c,Sales_Tax_Item__c,Customer__c from Tax_Exemption__c where CO_Header__c =: customerOrderId];
            }
            priceLevel = defaultPriceLevel[0];
        }
        
       //	system.assert(false,priceLevel); 	
        	
        // Get all service order records for customer orders
        String serviceOrderKitHeaderQuery = 'SELECT Id, Deal__c, Fixed_Price__c, Fixed_Price_Flag__c,Service_Order_Header__r.Deal__c, Service_Order_Header__r.Job_Type__c, '+
        	'Service_Order_Header__r.Provider__r.Price_Level__c, Service_Order_Header__r.Provider__c, Service_Order_Header__r.Provider__r.Price_Level__r.Discount_Markup__c, Service_Order_Header__r.Provider__r.Price_Level__r.Labour_Rate__c,'+
        	'Service_Order_Header__r.Provider__r.Price_Level__r.Part_Price_Base__c, ';
        String sokhlisQuery = ' (SELECT Id, Deal__c, Actual_Retail_Price__c, Actual_Kit_Price__c,Fixed_Price__c, Kit_Price__c, Retail_Price__c, Qty_Needed__c, Part__r.Retail_Price__c, Fee__r.Price__c, Labour_Code__r.Rate__c, Part__r.Applicable_Tax__r.Rate__c,Fee__c,Fee__r.Applicable_Tax__r.Rate__c, Labour_Code__c,Labour_Code__r.Fixed_Rate__c, Labour_Code__r.Applicable_Tax__r.Rate__c, Total__c, Service_Order_Kit_Header__c, CO_Line_Item__c FROM Service_Order_Line_Items__r' + ( (sokhliIds != null && sokhliIds.size() > 0) ? ' AND Id IN: sokhliIds': '' ) + ')';
        serviceOrderKitHeaderQuery += sokhlisQuery + ' FROM Service_Order_Kit_Header__c WHERE Service_Order_Header__r.CO_Header__c =: customerOrderId' 
                                      + ( (sohIds != null && sohIds.size() > 0) ? ' AND Service_Order_Header__c IN: sohIds' : '' )
                                      + ( (sokhIds != null && sokhIds.size() > 0) ? ' AND Id IN: sokhIds': '' );
        
        if(CustomerOrderCtrl_V2.isRefreshCOKit) {
        	serviceOrderKitHeaderQuery += ' AND Service_Order_Header__r.Invoice_Number__c = null';
        }
        //System.assert( false, serviceOrderKitHeaderQuery );
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Kit_Header__c> sokhList = Database.query(serviceOrderKitHeaderQuery);
        // List of all service order kit headers to update due to price recalculation:
        List<sObject> soKitHeadersToUpdate = new List<sObject>();
        
        // List of all service order kit header Line Items to update due to price recalculation:
        List<sObject> soKHLineItemsToUpdate = new List<sObject>();
        
        Set<Id> partIdSet = new Set<Id>(); 
        Set<Id> feeIdSet = new Set<Id>();
        Set<Id> laborIdSet = new Set<Id>();
        Set<Id> soliIdSet = new Set<Id>();
       
        Set<String> soHeaderIdSetHavingProvider = new Set<String>();
        Map<Id, Price_Level__c> providerIdToPriceLevelRecMap = new Map<Id, Price_Level__c>();
        for(Service_Order_Kit_Header__c soKitHeader : sokhList) {
        	if(String.isNotBlank(soKitHeader.Service_Order_Header__r.Deal__c) || soKitHeader.Service_Order_Header__r.Job_Type__c == 'Internal') {
        		isInternalServiceTypeCO = true;
        	}
        	if(String.isNotBlank(soKitHeader.Service_Order_Header__r.Provider__c)) {
	        	if(!providerIdToPriceLevelRecMap.containsKey(soKitHeader.Service_Order_Header__r.Provider__c)) {
	        		
	        		Price_Level__c plRec = new Price_Level__c(Id = soKitHeader.Service_Order_Header__r.Provider__r.Price_Level__c);
	        		plRec.Part_Price_Base__c = soKitHeader.Service_Order_Header__r.Provider__r.Price_Level__r.Part_Price_Base__c;
	        		plRec.Discount_Markup__c = soKitHeader.Service_Order_Header__r.Provider__r.Price_Level__r.Discount_Markup__c;
	        		plRec.Labour_Rate__c = soKitHeader.Service_Order_Header__r.Provider__r.Price_Level__r.Labour_Rate__c;
	        		providerIdToPriceLevelRecMap.put(soKitHeader.Service_Order_Header__r.Provider__c, plRec);
	        	}
	        	soHeaderIdSetHavingProvider.add(soKitHeader.Service_Order_Header__c);
        	}
        	
            for(Service_Order_Line_Item__c soli : soKitHeader.Service_Order_Line_Items__r){
                if(soli.Part__c !=null){
                    partIdSet.add(soli.Part__c);
                }else if (soli.Fee__c  !=null){
                     feeIdSet.add(soli.Fee__c);
                }else if (soli.Labour_Code__c  !=null){
                    laborIdSet.add(soli.Labour_Code__c);
                }
                soliIdSet.add(soli.Id);
            }
        }          
        Map<Id, List<Tax_Exemption__c>> soHeaderIdToExemptionListMap = new Map<Id, List<Tax_Exemption__c>>();
         List<Tax_Exemption__c> providersTaxExtemptionList = new List<Tax_Exemption__c>();
        if(soHeaderIdSetHavingProvider.size() > 0) {
        	providersTaxExtemptionList = [select Id,Sales_Tax_Item__r.Rate__c, Sales_Tax_Item__c, Customer__c, Service_Order_Header__c from Tax_Exemption__c where Service_Order_Header__c IN: soHeaderIdSetHavingProvider];
        }
        
        for(Tax_Exemption__c taxExcemptionRec : providersTaxExtemptionList) {
        	if(!soHeaderIdToExemptionListMap.containsKey(taxExcemptionRec.Service_Order_Header__c)) {
        		soHeaderIdToExemptionListMap.put(taxExcemptionRec.Service_Order_Header__c, new List<Tax_Exemption__c>());
        	}
        	soHeaderIdToExemptionListMap.get(taxExcemptionRec.Service_Order_Header__c).add(taxExcemptionRec);
        }
        
        List<Price_Level__c> defaultPriceLevel;
    	Sales_Tax__c defaultSalesTaxRec = new Sales_Tax__c();
 		if(isInternalServiceTypeCO) {
 			defaultPriceLevel = SOTriggerHelper.getInternalDefaultPriceLevel();
	        if(defaultPriceLevel == null || defaultPriceLevel.size() == 0) {
	            defaultPriceLevel = SOTriggerHelper.getDefaultPriceLevel();
	        }

            String defaultSalesTaxId = GeneralConfiguration.getDefaultSalesTaxOnInternalService();
            List<Sales_Tax__c> salesTaxList = [select Rate__c from Sales_Tax__c where Id =: defaultSalesTaxId];
            if(salesTaxList.size() > 0) {
            defaultSalesTaxRec = salesTaxList[0];
			}
        }
        
          if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          if(AccessControl.ifObjectFieldIsAccessible('Labour_Code__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          //if(AccessControl.ifObjectFieldIsAccessible('Applicable_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          List<Part__c>  listPartSalesTax= new list<Part__c> ([Select Id,Applicable_Tax__r.Rate__c,Applicable_Tax__c,Retail_Price__c From Part__c  where Id IN:partIdSet ]);
          List<Fee__c>  listFeeSalesTax= new list<Fee__c> ([Select Id,Applicable_Tax__r.Rate__c,Applicable_Tax__c From Fee__c  where Id IN:feeIdSet ]);
          List<Labour_Code__c>  listLaborPrices = new list<Labour_Code__c> ([Select Id,Fixed_Rate__c,Applicable_Tax__r.Rate__c,Applicable_Tax__c From Labour_Code__c  where Id IN:laborIdSet ]);
          
           Map<Id,Decimal> partIdToPartRateMap = new  Map<Id,Decimal>();
           Map<Id,List<Id>> SalesTaxIdToPartIdMap = new Map<Id,List<Id>>();
           Map<Id,List<Sales_Tax_Item__c>> PartIdToSalesTaxItemMap = new Map<Id,List<Sales_Tax_Item__c>>();
           for(Part__c  partRec : listPartSalesTax){
           		Id applicableTaxId = partRec.Applicable_Tax__c;
           		if(isInternalServiceTypeCO && defaultSalesTaxRec.Id != null) {
           			partIdToPartRateMap.put(partRec.Id, defaultSalesTaxRec.Rate__c);
           			applicableTaxId = defaultSalesTaxRec.Id;
           		} else {
                partIdToPartRateMap.put(partRec.Id,partRec.Applicable_Tax__r.Rate__c);  
                }
                
                if(SalesTaxIdToPartIdMap.containsKey(applicableTaxId)){
                    SalesTaxIdToPartIdMap.get(applicableTaxId).add(partRec.Id);
                }else{
                    SalesTaxIdToPartIdMap.put(applicableTaxId, new List<Id>{partRec.Id});
                }
           } 
           
           for(Fee__c  feeRec : listFeeSalesTax){
           		Id applicableTaxId = feeRec.Applicable_Tax__c;
                if(isInternalServiceTypeCO && defaultSalesTaxRec.Id != null) {
           			partIdToPartRateMap.put(feeRec.Id, defaultSalesTaxRec.Rate__c);
           			applicableTaxId = defaultSalesTaxRec.Id;
           		} else {
                partIdToPartRateMap.put(feeRec.Id,feeRec.Applicable_Tax__r.Rate__c);
                }
                
                if(SalesTaxIdToPartIdMap.containsKey(applicableTaxId)){
                    SalesTaxIdToPartIdMap.get(applicableTaxId).add(feeRec.Id);
                }else{
                    SalesTaxIdToPartIdMap.put(applicableTaxId, new List<Id>{feeRec.Id});
                }
           }
            for(Labour_Code__c  laborRec : listLaborPrices){
            	Id applicableTaxId = laborRec.Applicable_Tax__c;
                if(isInternalServiceTypeCO && defaultSalesTaxRec.Id != null) {
           			partIdToPartRateMap.put(laborRec.Id, defaultSalesTaxRec.Rate__c);
           			applicableTaxId = defaultSalesTaxRec.Id;
           		} else {
                partIdToPartRateMap.put(laborRec.Id,laborRec.Applicable_Tax__r.Rate__c);
                }
                
                if(SalesTaxIdToPartIdMap.containsKey(applicableTaxId)){
                    SalesTaxIdToPartIdMap.get(applicableTaxId).add(laborRec.Id);
                }else{
                    SalesTaxIdToPartIdMap.put(applicableTaxId, new List<Id>{laborRec.Id});
                }
           }
       
          if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          List<Applicable_Taxes__c> applicableTaxJunctionList = [select Id,Sales_Tax__c,Sales_Tax_Item__c,Sales_Tax_Item__r.Rate__c, Sales_Tax_Item__r.Name__c from Applicable_Taxes__c where  Sales_Tax__c IN : SalesTaxIdToPartIdMap.keySet()];
          List<Individual_Tax__c> IndividualTaxToinsert = new List<Individual_Tax__c>();
          for(Applicable_Taxes__c ApplicableTaxRec :  applicableTaxJunctionList){
                    List<Id> PartSalesTaxList = SalesTaxIdToPartIdMap.get(ApplicableTaxRec.Sales_Tax__c);
                    for(Id PartSalesTaxRecId  :  PartSalesTaxList){
                        if(PartSalesTaxRecId != null ){
                            if(PartIdToSalesTaxItemMap.containsKey(PartSalesTaxRecId)){
                                Sales_Tax_Item__c objSalesTaxItem = new Sales_Tax_Item__c( Id = ApplicableTaxRec.Sales_Tax_Item__c,Rate__c =ApplicableTaxRec.Sales_Tax_Item__r.Rate__c, Name__c = ApplicableTaxRec.Sales_Tax_Item__r.Name__c);
                                PartIdToSalesTaxItemMap.get(PartSalesTaxRecId).add(objSalesTaxItem);
                            }else{
                                    Sales_Tax_Item__c objSalesTaxItem = new Sales_Tax_Item__c( Id = ApplicableTaxRec.Sales_Tax_Item__c,Rate__c =ApplicableTaxRec.Sales_Tax_Item__r.Rate__c, Name__c = ApplicableTaxRec.Sales_Tax_Item__r.Name__c);
                                    PartIdToSalesTaxItemMap.put(PartSalesTaxRecId,new List<Sales_Tax_Item__c>{objSalesTaxItem});
                            }  
                        }
                    } 
           }
           
           
            // Iterate all service order kit header records, and recalculate price for kit line items
            for(Service_Order_Kit_Header__c soKitHeader : sokhList){
                if(soKitHeader.Service_Order_Line_Items__r != null && soKitHeader.Service_Order_Line_Items__r.size() > 0){
                    List<sObject> solis = new List<sObject>();
                    if((String.isNotBlank(soKitHeader.Service_Order_Header__r.Deal__c) || soKitHeader.Service_Order_Header__r.Job_Type__c == 'Internal') && defaultPriceLevel != null && defaultPriceLevel.size() > 0) {
                        solis = (List<sObject>) unfixedKHRecalculationOnSOKHLineItems( soKitHeader,  defaultPriceLevel[0] , new List<Tax_Exemption__c>(), partIdToPartRateMap,PartIdToSalesTaxItemMap,IndividualTaxToinsert);
                    } else if(String.isNotBlank(soKitHeader.Service_Order_Header__r.Provider__c)) {
                    	List<Tax_Exemption__c> exemptionList = soHeaderIdToExemptionListMap.containsKey(soKitHeader.Service_Order_Header__c) ? 
                    		soHeaderIdToExemptionListMap.get(soKitHeader.Service_Order_Header__c) : new List<Tax_Exemption__c>();
						solis = (List<sObject>) unfixedKHRecalculationOnSOKHLineItems( soKitHeader,  providerIdToPriceLevelRecMap.get(soKitHeader.Service_Order_Header__r.Provider__c) , exemptionList, partIdToPartRateMap,PartIdToSalesTaxItemMap,IndividualTaxToinsert);
                    } else {
                    	solis = (List<sObject>) unfixedKHRecalculationOnSOKHLineItems( soKitHeader,  priceLevel , taxExtemptionList, partIdToPartRateMap,PartIdToSalesTaxItemMap,IndividualTaxToinsert);
                    }
                    
                    if(solis.size() > 0){
                        soKHLineItemsToUpdate.addAll(solis);
                        soKitHeadersToUpdate.add(new Service_Order_Kit_Header__c(Id = soKitHeader.Id, Fixed_Price__c = soKitHeader.Fixed_Price__c,Tax_amount__c =soKitHeader.Tax_amount__c ));
                        
                         //system.assert(false,soKHLineItemsToUpdate);
                    }
                }
            }  
         
        // A list of records being updated
       
        
        List<sObject> recordsToUpdate = new List<sObject>();
        
        
        if(soKitHeadersToUpdate.size() > 0){
            recordsToUpdate.addAll(soKitHeadersToUpdate);
        }
        if(soKHLineItemsToUpdate.size() > 0){
            recordsToUpdate.addAll(soKHLineItemsToUpdate);
        }
        
        /* START -- Moved this code to up because of Non-invoiced Calculation -> Moved by TK **
        if(AccessControl.ifObjectFieldIsAccessible('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Individual_Tax__c> IndividualListTodelete = new List<Individual_Tax__c>([select Id, Sales_Tax_Item_Name__c,Service_Order_Line_Item__c,Tax_Rate__c from Individual_Tax__c where Service_Order_Line_Item__c IN :soliIdSet]);
        
        if(AccessControl.ifObjectIsDeletable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(IndividualListTodelete.size()>0 ){
			delete IndividualListTodelete;        
        }
        if(AccessControl.ifObjectIsCreateable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(IndividualTaxToinsert.size()>0){
        	insert IndividualTaxToinsert;
        }
        /* END -- Moved this code to up because of Non-invoiced Calculation -> Moved by TK **
        
        if(recordsToUpdate.size() > 0){
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            ServiceOrderLineItemTriggerHelper.isTriggerExecuted =true; 
            update recordsToUpdate;
        }
    }
    
    
    private static List<Service_Order_Line_Item__c> unfixedKHRecalculationOnSOKHLineItems(Service_Order_Kit_Header__c soKitHeader, Price_Level__c priceLevel , List<Tax_Exemption__c> taxExtemptionList, Map<Id,Decimal> partIdToPartRateMap, Map<Id,List<Sales_Tax_Item__c>> PartIdToSalesTaxItemMap, List<Individual_Tax__c> IndividualTaxToinsert) {
        List<Service_Order_Line_Item__c> solisList = new List<Service_Order_Line_Item__c>();
        decimal exTotalUnfixed = 0;
        decimal plAppliedTotalUnfixed = 0;
        decimal withoutPLUnfixedTotal = 0;
        decimal PartRate = 0.00;
        decimal TotalTaxApplicable=0.00;
        decimal KitHeaderTotal = 0.00;
        decimal taxAmount=0.00; 
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();                
        
        if(isTaxIncludingPricing){
            for(Service_Order_Line_Item__c soli : soKitHeader.Service_Order_Line_Items__r) {
            	soli.Kit_Price__c = soli.Actual_Kit_Price__c;
            	soli.Tax_Percent__c = (soli.Tax_Percent__c != null) ? soli.Tax_Percent__c : 0;
                if(soli.Part__c != null) {
                    soli.Kit_Price__c = (soli.Part__c != null) ? soli.Actual_Kit_Price__c : soli.Retail_Price__c;
                    soli.Actual_Retail_Price__c = (soli.Actual_Retail_Price__c != null) ? soli.Actual_Retail_Price__c : soli.Part__r.Retail_Price__c;
                    PartRate = (soli.Part__r.Applicable_Tax__r.Rate__c)!=null ? (soli.Part__r.Applicable_Tax__r.Rate__c) : 0;
                }                
                if(!soli.Fixed_Price__c && soli.Part__c != null) {
                    if(soKitHeader.Fixed_Price_Flag__c) {  
                        TotalTaxApplicable = (soli.Deal__c != null && (soli.Fixed_Price__c || soKitHeader.Fixed_Price_Flag__c)) ? 0 : getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                        Decimal preTaxPricing = soli.Kit_Price__c/ (1 + (TotalTaxApplicable / 100));
                        soli.Kit_Price__c = preTaxPricing;
                  	} else {
                  		String pricingField = TaxCalculation.getPricingFieldByPLBaseValueField(priceLevel.Part_Price_Base__c);
                        Decimal preTaxPricing = (!TaxCalculation.COST_FIELDS_SET.contains(pricingField)) ? soli.Kit_Price__c / (1 + (PartRate / 100)) : soli.Kit_Price__c;
                        soli.Kit_Price__c = preTaxPricing + (preTaxPricing *  priceLevel.Discount_Markup__c / 100);
                        TotalTaxApplicable = getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                    }
                    
                    soli.Tax_Percent__c = String.isBlank(soli.Deal__c) ? TotalTaxApplicable : 0;
                    soli.Price_When_Tax_Included__c = (soli.Kit_Price__c + (((soli.Kit_Price__c * soli.Tax_Percent__c) / 100))).setScale(2, RoundingMode.HALF_UP);
                    KitHeaderTotal += (soli.Qty_Needed__c * soli.Price_When_Tax_Included__c).setscale(2, RoundingMode.HALF_UP);
                    taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
                } else if(soli.Fixed_Price__c && soli.Part__c != null) {
                        TotalTaxApplicable = (soli.Deal__c != null && (soli.Fixed_Price__c || soKitHeader.Fixed_Price_Flag__c)) ? 0 : getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                        Decimal preTaxPricing = soli.Kit_Price__c/ (1 + (TotalTaxApplicable / 100));
                        soli.Kit_Price__c = preTaxPricing;
                        soli.Tax_Percent__c = String.isBlank(soli.Deal__c) ? TotalTaxApplicable : 0;
                        soli.Price_When_Tax_Included__c = (soli.Kit_Price__c + (((soli.Kit_Price__c * soli.Tax_Percent__c) / 100))).setScale(2, RoundingMode.HALF_UP);
                        KitHeaderTotal += (soli.Qty_Needed__c * soli.Price_When_Tax_Included__c).setscale(2, RoundingMode.HALF_UP);  
                        taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
                        
                } else if(soli.Fee__c != null) {
                		Decimal feeRate = (soli.Fee__r.Applicable_Tax__r.Rate__c) != null ? (soli.Fee__r.Applicable_Tax__r.Rate__c) : 0;
                        TotalTaxApplicable = (soli.Deal__c != null && (soli.Fixed_Price__c || soKitHeader.Fixed_Price_Flag__c)) ? 0 : getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                        Decimal preTaxPricing;
                        if(soli.Fixed_Price__c || soKitHeader.Fixed_Price_Flag__c) {
                        	preTaxPricing = soli.Kit_Price__c/ (1 + (TotalTaxApplicable / 100));
                        } else {
                        	preTaxPricing = soli.Kit_Price__c/ (1 + (feeRate / 100));
                        }
                        soli.Kit_Price__c = preTaxPricing;
                        soli.Tax_Percent__c = String.isBlank(soli.Deal__c) ? TotalTaxApplicable : 0;  
                        soli.Price_When_Tax_Included__c = (soli.Kit_Price__c + (((soli.Kit_Price__c * soli.Tax_Percent__c) / 100))).setScale(2, RoundingMode.HALF_UP);
                        KitHeaderTotal += (soli.Qty_Needed__c * soli.Price_When_Tax_Included__c).setscale(2, RoundingMode.HALF_UP);  
                        taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
                        
                } else if(soli.Labour_Code__c != null) { 
                 	if(soli.Actual_Retail_Price__c == null) {
                 		if(soli.Labour_Code__r.Fixed_Rate__c) {
	                 		soli.Actual_Retail_Price__c = soli.Labour_Code__r.Rate__c;
						} else {
	                 	  	soli.Actual_Retail_Price__c = priceLevel.Labour_Rate__c;
	                 	}
                 	}
                 	  
                  	if(!(soli.Fixed_Price__c || soKitHeader.Fixed_Price_Flag__c )) { // Add Price Level 0 Condition
                        TotalTaxApplicable = getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                        Decimal laborRate = (soli.Labour_Code__r.Applicable_Tax__r.Rate__c) != null ? (soli.Labour_Code__r.Applicable_Tax__r.Rate__c) : 0;
                        
                        //Start: Commented and Added by Pooja 2 Dec. 2016
                        //preTaxPricing = priceLevel.Labour_Rate__c/ (1 + (TotalTaxApplicable / 100));
                        Decimal preTaxPricing;
                        if(priceLevel.Labour_Rate__c == null || priceLevel.Labour_Rate__c == 0  || soli.Labour_Code__r.Fixed_Rate__c){
                        	preTaxPricing = soli.Kit_Price__c/ (1 + (laborRate / 100));
                        }else{
                        	preTaxPricing = priceLevel.Labour_Rate__c/ (1 + (laborRate / 100));
                        }
                        //End: Commented and Added by Pooja 2 Dec. 2016
                        
                        soli.Kit_Price__c = preTaxPricing;
                        soli.Tax_Percent__c = String.isBlank(soli.Deal__c) ? TotalTaxApplicable : 0;
                        soli.Price_When_Tax_Included__c = (soli.Kit_Price__c + (((soli.Kit_Price__c * soli.Tax_Percent__c) / 100))).setScale(2, RoundingMode.HALF_UP);
                        KitHeaderTotal += (soli.Qty_Needed__c * soli.Price_When_Tax_Included__c).setscale(2, RoundingMode.HALF_UP);  
                        taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
                          
                    } else {
                        TotalTaxApplicable = (soli.Deal__c != null && (soli.Fixed_Price__c || soKitHeader.Fixed_Price_Flag__c)) ? 0 : getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                        Decimal preTaxPricing = soli.Kit_Price__c/ (1 + (TotalTaxApplicable / 100));
                        soli.Kit_Price__c = preTaxPricing;
                        soli.Tax_Percent__c = String.isBlank(soli.Deal__c) ? TotalTaxApplicable : 0;
                        soli.Price_When_Tax_Included__c = (soli.Kit_Price__c + (((soli.Kit_Price__c * soli.Tax_Percent__c) / 100))).setScale(2, RoundingMode.HALF_UP);
                        KitHeaderTotal += (soli.Qty_Needed__c * soli.Price_When_Tax_Included__c).setscale(2, RoundingMode.HALF_UP);  
                            taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
                        }
                 }
                 solisList.add(soli);
            }
         }else{
                for(Service_Order_Line_Item__c soli : soKitHeader.Service_Order_Line_Items__r){
                	 soli.Kit_Price__c = soli.Actual_Kit_Price__c.setScale(2, RoundingMode.HALF_UP) ;
					if(soli.Part__c !=null){
	                    soli.Actual_Retail_Price__c = (soli.Actual_Retail_Price__c != null) ? soli.Actual_Retail_Price__c : soli.Part__r.Retail_Price__c;
	                }
                    if(!soli.Fixed_Price__c && soli.Part__c !=null ){
                         if(soKitHeader.Fixed_Price_Flag__c ){  
                                    TotalTaxApplicable = getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                                    soli.Tax_Percent__c = TotalTaxApplicable;  
                                    KitHeaderTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);  
                                    (taxAmount +=  (soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setscale(2, RoundingMode.HALF_UP);
                              }else{
                                    soli.Kit_Price__c = soli.Kit_Price__c + (soli.Kit_Price__c *  priceLevel.Discount_Markup__c / 100).setScale(2, RoundingMode.HALF_UP);
                                    soli.Kit_Price__c = soli.Kit_Price__c;
                                    TotalTaxApplicable = getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                                    soli.Tax_Percent__c = TotalTaxApplicable;
                                    KitHeaderTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP); 
                                        taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setscale(2, RoundingMode.HALF_UP);
                                    }
                       } else if (soli.Fixed_Price__c && soli.Part__c !=null ){
                            TotalTaxApplicable = getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                            soli.Tax_Percent__c = TotalTaxApplicable;
                            KitHeaderTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP); 
                                taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setscale(2, RoundingMode.HALF_UP);
                       } else if (soli.Fixed_Price__c && soli.Part__c !=null ){
                            TotalTaxApplicable = getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                            soli.Tax_Percent__c = TotalTaxApplicable;
                            KitHeaderTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);
                                taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setscale(2, RoundingMode.HALF_UP);
                       } else if(soli.Fee__c !=null){
                            TotalTaxApplicable = getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
                            soli.Tax_Percent__c = TotalTaxApplicable;
                            KitHeaderTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);
                                taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setscale(2, RoundingMode.HALF_UP);
                       } else if(soli.Labour_Code__c !=null){
                       		if(soli.Actual_Retail_Price__c == null) {
                                if(soli.Labour_Code__r.Fixed_Rate__c) {
                                    soli.Actual_Retail_Price__c = soli.Labour_Code__r.Rate__c;
                                } else {
                                    soli.Actual_Retail_Price__c = priceLevel.Labour_Rate__c;
                                }
                            }
	                        if(!(soli.Fixed_Price__c || soli.Labour_Code__r.Fixed_Rate__c )){
	                            TotalTaxApplicable = getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
	                            //Start: Added by pooja 2 Dec. 2016
	                            Decimal preTaxPricing;
		                        if(!(priceLevel.Labour_Rate__c == null || priceLevel.Labour_Rate__c == 0 || soli.Fixed_Price__c || soKitHeader.Fixed_Price_Flag__c)){
		                        	preTaxPricing = priceLevel.Labour_Rate__c;
		                        	soli.Kit_Price__c = preTaxPricing.setScale(2, RoundingMode.HALF_UP);
		                        }
		                        //End: Added by pooja 2 Dec. 2016
		                        
	                            soli.Tax_Percent__c = TotalTaxApplicable;
	                            KitHeaderTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);  
	                                taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setscale(2, RoundingMode.HALF_UP);
	                        }else{
	                            TotalTaxApplicable = getApplicableTaxes(PartIdToSalesTaxItemMap,soli,taxExtemptionList,IndividualTaxToinsert);
	                            //Start: Added by pooja 2 Dec. 2016
	                            //Decimal preTaxPricing = soli.Kit_Price__c/ (1 + (TotalTaxApplicable / 100));
		                       // soli.Kit_Price__c = preTaxPricing.setscale(2, RoundingMode.HALF_UP);
		                        //End: Added by pooja 2 Dec. 2016
		                        
	                            soli.Tax_Percent__c = TotalTaxApplicable;
	                            KitHeaderTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);  
	                                taxAmount +=  ((soli.Qty_Needed__c * soli.Kit_Price__c * soli.Tax_Percent__c) / 100).setscale(2, RoundingMode.HALF_UP);
	                            }
	                        }
                       solisList.add(soli);             
                }  
                
            }
          	solisList = resolveRoundOffIssue(solisList, KitHeaderTotal, isTaxIncludingPricing);
          	
            soKitHeader.Fixed_Price__c = KitHeaderTotal;
            soKitHeader.Tax_amount__c = taxAmount;
                        
            return solisList;
    }
    /**
     * Name: unfixedKHRecalculationOnSOKHLineItems
     * Desc: Method to calculate kit price for all service order kit line items for UNFIXED PRICE Service Order Kit Header record passed
     * @param:  1. Service_Order_Kit_Header__c soKitHeader
     *          2. Price_Level__c priceLevel
     * @return: List<Service_Order_Line_Item__c>
    **/
    /*private static List<Service_Order_Line_Item__c> unfixedKHRecalculationOnSOKHLineItems(Service_Order_Kit_Header__c soKitHeader, Price_Level__c priceLevel) {
        List<Service_Order_Line_Item__c> solisList = new List<Service_Order_Line_Item__c>();
        
        decimal exTotalUnfixed = 0;
        decimal plAppliedTotalUnfixed = 0;
        decimal withoutPLUnfixedTotal = 0;

        // Calculate total of ex and desired kit price of all solis
        for(Service_Order_Line_Item__c soli : soKitHeader.Service_Order_Line_Items__r){
            //soli.Kit_Price__c = soli.Qty_Needed__c * ( (soli.Part__c != null) ? soli.Actual_Kit_Price__c : soli.Retail_Price__c );
            soli.Kit_Price__c = (soli.Part__c != null) ? soli.Actual_Kit_Price__c : soli.Retail_Price__c;
            
            // Calculate kit price of service order line item as per assigned price level
            if(soli.Part__c != null){
                withoutPLUnfixedTotal += (soli.Kit_Price__c * soli.Qty_Needed__c);
                exTotalUnfixed += (soli.Kit_Price__c + (soli.Kit_Price__c * priceLevel.Discount_Markup__c / 100)) * soli.Qty_Needed__c;
                soli.Kit_Price__c = soli.Kit_Price__c + (soli.Kit_Price__c * priceLevel.Discount_Markup__c / 100);
            } else {
                withoutPLUnfixedTotal += soli.Kit_Price__c * soli.Qty_Needed__c;
                exTotalUnfixed += priceLevel.Labour_Rate__c;
                
                if(!soli.Labour_Code__r.Fixed_Rate__c) {
                    soli.Kit_Price__c = priceLevel.Labour_Rate__c;
                } else {
                    soli.Kit_Price__c = soli.Labour_Code__r.Rate__c;
                }
            }
            soli.Kit_Price_With_Price_Level__c = soli.Kit_Price__c;
            plAppliedTotalUnfixed += soli.Kit_Price__c * soli.Qty_Needed__c;
        }
        //system.assert(false, plAppliedTotalUnfixed + ' ' + withoutPLUnfixedTotal + ' ' + exTotalUnfixed);
        // The difference factor of desired total kit price to actual kit price total
        decimal differenceFactor = plAppliedTotalUnfixed / exTotalUnfixed;
         
        // Difference amount in both totals and this will be adjusted in kit header total amount
        decimal difference = exTotalUnfixed - plAppliedTotalUnfixed;
        
        if(soKitHeader.Fixed_Price_Flag__c == true) {
            soKitHeader.Fixed_Price__c = soKitHeader.Fixed_Price__c + (soKitHeader.Fixed_Price__c * priceLevel.Discount_Markup__c / 100);
        } else {
            soKitHeader.Fixed_Price__c -= withoutPLUnfixedTotal;
            soKitHeader.Fixed_Price__c += plAppliedTotalUnfixed;
        }
        soKitHeader.Fixed_Price__c -= difference;
        
        // The difference factor is need to be applied to kit price for all kit line items as recalculation logic
        for(Service_Order_Line_Item__c soli : soKitHeader.Service_Order_Line_Items__r){
            soli.Kit_Price__c = soli.Kit_Price__c * differenceFactor;
            solisList.add(soli);
        }
        
        return solisList;
    }*/
    
    /**
     * Name: updateSOKitHeader
     * Desc: Update Service order Kit header
     * @param: SOHeaderWrapper.SOKitHeader soKitHeaderObj
     * @return: String - get Main JSON data.
     **/
    public static Errorhandler updateSOKitHeader(SOHeaderWrapper.SOKitHeader soKitHeaderObj) {
        Service_Order_Kit_Header__c sokitHeaderRec = new Service_Order_Kit_Header__c();
        sokitHeaderRec.Id = soKitHeaderObj.Id;
        sokitHeaderRec.Fixed_Price__c = soKitHeaderObj.FixedPrice;
        Errorhandler error = validateSOKitHeader(soKitHeaderObj, sokitHeaderRec);
        
        if (sokitHeaderRec.Id != null && error.ResponseCode == '200' && sokitHeaderRec.Is_Fixed_Kit_Header_SO__c) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            set<Id> ServiceOrderHeaderSet = new Set<Id>();
            List<Service_Order_Kit_Header__c> ServiceOrderKitHeaderList = [select  Id,Service_Order_Header__c from  Service_Order_Kit_Header__c where Id =:soKitHeaderObj.Id];
            for(Service_Order_Kit_Header__c soKitHeaderRecItem : ServiceOrderKitHeaderList){
                ServiceOrderHeaderSet.add(soKitHeaderRecItem.Service_Order_Header__c);
            }
            UpdateSoTotals(ServiceOrderHeaderSet);                                  
            //update sokitHeaderRec;
        }
                        
        
        return error;
    }
    
    public static void UpdateSoTotals(set<Id> ServiceOrderHeaderSet){
    	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Header__c>   serviceOrderHeaderList = ([select Id,Total__c,Tax_Amount__c,(SELECT Kit_Price__c,Qty_Needed__c ,Total__c,Tax_Percent__c ,Qty_To_Order__c FROM Service_Order_Line_Items__r) from Service_Order_Header__c where Id IN: ServiceOrderHeaderSet]);
        for(Service_Order_Header__c soHeaderRec : serviceOrderHeaderList){
            decimal total =0;
            decimal taxAmount =0;
            boolean IsInvoiceable = true; 
            for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
                if(soliRec.Qty_To_Order__c > 0) {
                    IsInvoiceable = false;
                }
                
                soliRec.Kit_Price__c = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
                soliRec.Qty_Needed__c = (soliRec.Qty_Needed__c != null) ? soliRec.Qty_Needed__c : 0;
                soliRec.Tax_Percent__c = (soliRec.Tax_Percent__c != null) ? soliRec.Tax_Percent__c : 0;
                
                total += (soliRec.Kit_Price__c * soliRec.Qty_Needed__c).setscale(2, RoundingMode.HALF_UP);
                taxAmount += ((soliRec.Kit_Price__c * soliRec.Qty_Needed__c * soliRec.Tax_Percent__c) / 100).setscale(2, RoundingMode.HALF_UP);
            }
            soHeaderRec.Total__c = total;
            soHeaderRec.Tax_Amount__c = taxAmount;
        }
        
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(serviceOrderHeaderList.size() > 0){
            update serviceOrderHeaderList;
        }   
        
    }
    
    /**
     * Name: updateSOKitLineItem
     * Desc: Method related to updation of service order kit line items fixed price value
     * @param: SOHeaderWrapper.SOLineItem sokitLineItemObj - SOHeaderWrapper.SOLineItem JSON
     * @return: String - get Main JSON data.
     **/
    public static Errorhandler updateSOKitLineItem(SOHeaderWrapper.SOLineItem sokitLineItemObj) {
        Service_Order_Line_Item__c sokitLineItemRec = new Service_Order_Line_Item__c();
        sokitLineItemRec.Id = sokitLineItemObj.Id;
        sokitLineItemRec.Qty_Needed__c = sokitLineItemObj.QtyNeeded;
        sokitLineItemRec.Kit_Price__c = sokitLineItemObj.KitPrice;
        
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        String errorMessage = '';
        Id sokitHeaderId = sokitLineItemObj.SOkitHeaderId;
        if(sokitHeaderId != null){
            Errorhandler error = validateSOKitLineItemOnUpdate(sokitHeaderId, sokitLineItemObj, sokitLineItemRec);
            if (sokitHeaderId != null && error.ResponseCode == '200' && sokitLineItemRec.Is_Fixed_Kit_LineItem_SO__c) {
                update sokitLineItemRec;
            }
            
            errorMessage = (error.ResponseCode != '200') ? error.ResponseMeassage : '';
        }
        return (errorMessage.length() != 0) ? new Errorhandler('300', errorMessage) : new Errorhandler('200', 'Success');
    }
    
    /**
     * Name: validateSOKitHeader
     * Desc: Validate Service Order kit Header record being updated here
     * @param: SOHeaderWrapper.SOHeader soKitHeaderObj
     * @return: Errorhandler response result by validation
     **/
    private static Errorhandler validateSOKitHeader(SOHeaderWrapper.SOKitHeader soKitHeaderObj, Service_Order_Kit_Header__c sokitHeaderRec) {
        // Get all service order records for customer orders
        String serviceOrderKitHeaderQuery = 'SELECT Id, Deal__c, Fixed_Price__c, Fixed_Price_Flag__c, Is_Fixed_Kit_Header_SO__c,Tax_Amount__c,';
        String sokhlisQuery = ' (SELECT Id, Fixed_Price__c, Deal__c, Actual_Kit_Price__c, Kit_Price__c,Tax_Amount__c, Qty_Needed__c,Tax_Percent__c, Total__c, Is_Fixed_Kit_LineItem_SO__c, Price_When_Tax_Included__c FROM Service_Order_Line_Items__r)';
        serviceOrderKitHeaderQuery += sokhlisQuery + ' FROM Service_Order_Kit_Header__c WHERE Id = \'' + soKitHeaderObj.Id + '\'';
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Service_Order_Kit_Header__c> sokhList = Database.query(serviceOrderKitHeaderQuery);
        Service_Order_Kit_Header__c databseSOKHRecoord = (sokhList.size() > 0) ? sokhList[0] : null;
        
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        String errorMessage = '';
        if (databseSOKHRecoord != null) {  
            Integer countUnfixedLineItems = 0;
            Decimal totalFixedPrice = 0;
            
            if(databseSOKHRecoord.Fixed_Price_Flag__c == false && databseSOKHRecoord.Service_Order_Line_Items__r != null){
                if(sokitHeaderRec.Fixed_Price__c != databseSOKHRecoord.Fixed_Price__c) {
                  sokitHeaderRec.Is_Fixed_Kit_Header_SO__c = true;
                  databseSOKHRecoord.Is_Fixed_Kit_Header_SO__c = true;
                }else{
                  	return (errorMessage.length() != 0) ? new Errorhandler('300', errorMessage) : new Errorhandler('200', 'Success');
                }
                
                for (Service_Order_Line_Item__c sokhLineItemRec : databseSOKHRecoord.Service_Order_Line_Items__r) {
                    if (!sokhLineItemRec.Fixed_Price__c && !sokhLineItemRec.Is_Fixed_Kit_LineItem_SO__c) {
                        countUnfixedLineItems++;
                    } else {
                        totalFixedPrice += sokhLineItemRec.Total__c;
                    }
                }                            
                if(soKitHeaderObj.FixedPrice < totalFixedPrice ){
                    return  new Errorhandler('300', 'Cannot update item Fixed price must be equal to total');
                } 
                  
                //system.assert(false,countUnfixedLineItems);
                if(soKitHeaderObj.FixedPrice == totalFixedPrice && countUnfixedLineItems == 0){
                    errorMessage = '';
                } else if(soKitHeaderObj.FixedPrice != totalFixedPrice && countUnfixedLineItems == 0){
                    errorMessage = Label.Kit_Header_Less_fixed_price_amount;
                } else if(countUnfixedLineItems == 0) {
                    errorMessage = Label.Kit_Header_No_unfixed_Line_Items;
                } 
                
                //system.assert(false,errorMessage);
                // If update is valid, then recalculate all line items price
                if(errorMessage.length() == 0){
                    databseSOKHRecoord.Fixed_Price__c = soKitHeaderObj.FixedPrice;
                    
                    recalculateSOKHLineItems(new List<Service_Order_Kit_Header__c>{databseSOKHRecoord}, true);
                    
                }
            }
        }
        return (errorMessage.length() != 0) ? new Errorhandler('300', errorMessage) : new Errorhandler('200', 'Success');
    }
    
    /**
     * Name: recalculateSOKHLineItems
     * Desc: Method to recalculate service order kit heder line items price after updations in service order kit header fixed price value
     * @param: Service_Order_Kit_Header__c databseSOKHRecoord
     * @return: 
     **/
    private static void recalculateSOKHLineItems(List<Service_Order_Kit_Header__c> databseSOKHRecoordList, boolean KitHeader ) {
        if(databseSOKHRecoordList.size() == 0) {
        	return;
        }
        Service_Order_Kit_Header__c databseSOKHRecoord = databseSOKHRecoordList[0];
        
        List<Service_Order_Line_Item__c> updateKitLineItems = new List<Service_Order_Line_Item__c>();
        Map<Id, Service_Order_Line_Item__c> unFixedLineItemsMap = new Map<Id, Service_Order_Line_Item__c>();
        List<Service_Order_Line_Item__c> ServicelineItemlist = new List<Service_Order_Line_Item__c>();
        Double fixedItemTotal = 0;
        Double unFixedItemTotal = 0;
        Decimal TotalPrice = 0;
        Decimal TotalTaxAmount = 0;
        //system.assert(false,databseSOKHRecoord);
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        for(Service_Order_Line_Item__c khli : databseSOKHRecoord.Service_Order_Line_Items__r){
            if(khli.Fixed_Price__c || khli.Is_Fixed_Kit_LineItem_SO__c){
            	ServicelineItemlist.add(khli); // Added by richa 23/11/2016
                if(isTaxIncludingPricing && String.isBlank(khli.Deal__c)){
                    //system.assert(false,khli);
                    fixedItemTotal += (khli.Price_When_Tax_Included__c * khli.Qty_Needed__c );
                    /* ServicelineItemlist.add(khli); */ // Commented by richa 23/11/2016
                }else{
                    fixedItemTotal += (khli.Kit_Price__c * khli.Qty_Needed__c );   
                }
                system.debug('%%%%%%%%' + khli.Kit_Price__c  +' '+  khli.Qty_Needed__c +' '+ khli.Tax_Amount__c);
            } else { 
                unFixedLineItemsMap.put(khli.Id, khli);
                if(isTaxIncludingPricing && String.isBlank(khli.Deal__c)){
                    unFixedItemTotal += (khli.Price_When_Tax_Included__c  *  khli.Qty_Needed__c) ;
                }else{
                    unFixedItemTotal += (khli.Kit_Price__c  *  khli.Qty_Needed__c);
                }
                
            }
        } 
        
        Double desiredUnFixedTotal = 0; 
        if(KitHeader){
            desiredUnFixedTotal = databseSOKHRecoord.Fixed_Price__c  - fixedItemTotal;
        }else{
            if((isTaxIncludingPricing && String.isBlank(databseSOKHRecoord.Deal__c))){
                desiredUnFixedTotal = (databseSOKHRecoord.Fixed_Price__c + databseSOKHRecoord.Tax_Amount__c )  - fixedItemTotal;
            }else{
                desiredUnFixedTotal = databseSOKHRecoord.Fixed_Price__c - fixedItemTotal;
            }
            
        }
           
        Double Adjustment = (unFixedItemTotal != 0) ? desiredUnFixedTotal / unFixedItemTotal : 1;
        //system.assert( false, ServicelineItemlist + 'KitFixed price:'+ databseSOKHRecoord.Fixed_Price__c  +'SalesTax'+ databseSOKHRecoord.Tax_Amount__c );
        if(Adjustment != 1){ 
            for(Service_Order_Line_Item__c khli : unFixedLineItemsMap.values()){
                if(isTaxIncludingPricing && String.isBlank(khli.Deal__c)){    
                      khli.Price_When_Tax_Included__c = (khli.Price_When_Tax_Included__c * Adjustment).setscale(2, RoundingMode.HALF_UP);
                      khli.Kit_Price__c =  (khli.Price_When_Tax_Included__c / (1 + ( (khli.Tax_Percent__c / 100))));
                }else{
                     khli.Kit_Price__c =  (khli.Kit_Price__c  * Adjustment).setscale(2, RoundingMode.HALF_UP);
                }
               
                updateKitLineItems.add(khli);
                ServicelineItemlist.add(khli); 
            }
        }         
        
        Decimal unFixedKitHeaderPrice = 0;
        for(Service_Order_Line_Item__c khli : ServicelineItemlist){
        	if(khli.Tax_Percent__c == null) {
	        	khli.Tax_Percent__c = 0;
	        }
            if(!(khli.Fixed_Price__c || khli.Is_Fixed_Kit_LineItem_SO__c)){
            	if(isTaxIncludingPricing && String.isBlank(khli.Deal__c)){
            		unFixedKitHeaderPrice += (khli.Qty_Needed__c * khli.Price_When_Tax_Included__c).setscale(2, RoundingMode.HALF_UP);
	                TotalPrice += (khli.Qty_Needed__c * khli.Price_When_Tax_Included__c).setscale(2, RoundingMode.HALF_UP);
	                TotalTaxAmount += (khli.Qty_Needed__c * ((khli.Price_When_Tax_Included__c)/100)).setscale(2, RoundingMode.HALF_UP); 
            	} else {
            		unFixedKitHeaderPrice += (khli.Qty_Needed__c * khli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);
	                TotalPrice +=  (khli.Qty_Needed__c * khli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);
	                TotalTaxAmount +=  (khli.Qty_Needed__c * ((khli.Kit_Price__c * khli.Tax_Percent__c)/100)).setscale(2, RoundingMode.HALF_UP); 
            	}
            	
            }
            else{  
                if(isTaxIncludingPricing && String.isBlank(khli.Deal__c)){
                    TotalPrice += (khli.Qty_Needed__c * khli.Price_When_Tax_Included__c).setscale(2, RoundingMode.HALF_UP);
                    TotalTaxAmount += (khli.Qty_Needed__c * khli.Price_When_Tax_Included__c).setscale(2, RoundingMode.HALF_UP);
                }else{
                    TotalPrice += (khli.Qty_Needed__c * khli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);
                    TotalTaxAmount +=  (khli.Qty_Needed__c * ((khli.Kit_Price__c * khli.Tax_Percent__c)/100)).setscale(2, RoundingMode.HALF_UP);
                }
            }  
        }         
        if(updateKitLineItems.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            databseSOKHRecoord.Is_Fixed_Kit_Header_SO__c = true;
            databseSOKHRecoord.Fixed_Price__c= TotalPrice;
            databseSOKHRecoord.Tax_amount__c = TotalTaxAmount;
            ServiceOrderLineItemTriggerHelper.isTriggerExecuted =true;
            
            List<SObject> sObjectListToUpdate = new List<SObject>();
            sObjectListToUpdate.add(databseSOKHRecoord);
            
            //updateKitLineItems = resolveRoundOffIssue(updateKitLineItems, unFixedKitHeaderPrice, isTaxIncludingPricing);
            
            sObjectListToUpdate.addAll((List<SObject>) updateKitLineItems);
            //update databseSOKHRecoord;
             
            //update updateKitLineItems;
            if(sObjectListToUpdate.size() > 0) {
            	update sObjectListToUpdate;
            }
        } 
    }
    
    /**
     * Name: validateSOKitLineItemOnUpdate
     * Desc: Validate service order kit Line Item record being updated here
     * @param: 1. Id sokitHeaderId
     *         2. SOHeaderWrapper.SOLineItem sokitLineItemObj
     * @return: Errorhandler response result by validation
     **/
    private static Errorhandler validateSOKitLineItemOnUpdate(Id sokitHeaderId, SOHeaderWrapper.SOLineItem sokitLineItemObj, Service_Order_Line_Item__c sokitLineItemRec) {
        // Get all service order records for customer orders
        String serviceOrderKitHeaderQuery = 'SELECT Id, Deal__c, Fixed_Price__c, Fixed_Price_Flag__c, Is_Fixed_Kit_Header_SO__c,Tax_amount__c,';
        String sokhlisQuery = ' (SELECT Id, Deal__c, Fixed_Price__c, Actual_Kit_Price__c,Tax_Amount__c, Kit_Price__c,Tax_Percent__c, Qty_Needed__c, Total__c, Is_Fixed_Kit_LineItem_SO__c, Price_When_Tax_Included__c FROM Service_Order_Line_Items__r)';
        serviceOrderKitHeaderQuery += sokhlisQuery + ' FROM Service_Order_Kit_Header__c WHERE Id =: sokitHeaderId';
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        //System.assert( false, serviceOrderKitHeaderQuery );  
        List<Service_Order_Kit_Header__c> sokhList = Database.query(serviceOrderKitHeaderQuery); 
        Service_Order_Kit_Header__c databseSOKHRecoord = (sokhList.size() > 0) ? sokhList[0] : null;
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        decimal TotalAmount =0;
        decimal TotalTaxAmount =0;
        List<Service_Order_Line_Item__c> serviceOrderLineItemList = new List<Service_Order_Line_Item__c>();
        String errorMessage = '';
        if (databseSOKHRecoord != null) {
            Integer countUnfixedLineItems = 0;  
            Decimal totalFixedPrice = 0;

            if(databseSOKHRecoord.Fixed_Price_Flag__c  && databseSOKHRecoord.Service_Order_Line_Items__r != null){
                for (Service_Order_Line_Item__c khLineItemRec : databseSOKHRecoord.Service_Order_Line_Items__r) {
                	
                	Decimal price = (isTaxIncludingPricing && String.isBlank(khLineItemRec.Deal__c)) ? khLineItemRec.Price_When_Tax_Included__c : khLineItemRec.Kit_Price__c;
                    // Update current updating record
                    if(khLineItemRec.Id == sokitLineItemObj.Id){
                        if(price != sokitLineItemRec.Kit_Price__c) {
                            sokitLineItemRec.Is_Fixed_Kit_LineItem_SO__c = true;
                            khLineItemRec.Is_Fixed_Kit_LineItem_SO__c = true;
                        }
                        khLineItemRec.Qty_Needed__c = sokitLineItemObj.QtyNeeded;
                        price = sokitLineItemObj.KitPrice;
                        if(isTaxIncludingPricing && String.isBlank(khLineItemRec.Deal__c)){
	                    	khLineItemRec.Price_When_Tax_Included__c = price;
	                    	khLineItemRec.Kit_Price__c = (price / (1 + (khLineItemRec.Tax_Percent__c / 100))); 
	                    } else {
	                    	khLineItemRec.Kit_Price__c = price;
                    }
                    }
                    if (!khLineItemRec.Fixed_Price__c && !khLineItemRec.Is_Fixed_Kit_LineItem_SO__c && price != 0) { // && khLineItemRec.Kit_Price__c != 0 Added by richa 23/11/2016
                        countUnfixedLineItems++;
                    } else {
                        totalFixedPrice += khLineItemRec.Qty_Needed__c * price;
                    }
                    
                }
                if(totalFixedPrice <= databseSOKHRecoord.Fixed_Price__c && countUnfixedLineItems > 0){
                    errorMessage = '';
                } else if(totalFixedPrice > databseSOKHRecoord.Fixed_Price__c){
                    errorMessage = Label.Kit_Line_Item_Exceeded_Total_Price;
                } else if(countUnfixedLineItems <= 1) {
                    errorMessage = Label.Kit_Line_Item_No_Unfixed_Line_Item;
                }
                
                // If no error, then perform recalculation logic for line item records of Kit
                if(errorMessage.length() == 0){
                    recalculateSOKHLineItems(new List<Service_Order_Kit_Header__c>{databseSOKHRecoord},sokitLineItemObj);
                }
                
            } 
            else if (databseSOKHRecoord.Is_Fixed_Kit_Header_SO__c   && databseSOKHRecoord.Service_Order_Line_Items__r != null){
                
                for (Service_Order_Line_Item__c khLineItemRec : databseSOKHRecoord.Service_Order_Line_Items__r) {
                    Decimal price = (isTaxIncludingPricing && String.isBlank(khLineItemRec.Deal__c)) ? khLineItemRec.Price_When_Tax_Included__c : khLineItemRec.Kit_Price__c;
                    
                    // Update current updating record
                    if(khLineItemRec.Id == sokitLineItemObj.Id){
                        if(price != sokitLineItemRec.Kit_Price__c) {
                            sokitLineItemRec.Is_Fixed_Kit_LineItem_SO__c = true;
                            khLineItemRec.Is_Fixed_Kit_LineItem_SO__c = true;
                        }
                        khLineItemRec.Qty_Needed__c = sokitLineItemObj.QtyNeeded;
                        price = sokitLineItemObj.KitPrice;
                        if(isTaxIncludingPricing && String.isBlank(khLineItemRec.Deal__c)){
	                    	khLineItemRec.Price_When_Tax_Included__c = price;
	                    	khLineItemRec.Kit_Price__c = (price / (1 + (khLineItemRec.Tax_Percent__c / 100))); 
	                    } else {
	                    	khLineItemRec.Kit_Price__c = price;
                    }
                    }
                    if (!khLineItemRec.Fixed_Price__c && !khLineItemRec.Is_Fixed_Kit_LineItem_SO__c && price != 0) { // && khLineItemRec.Kit_Price__c != 0 Added by richa 23/11/2016
                        countUnfixedLineItems++;
                    } else {
                        totalFixedPrice += khLineItemRec.Qty_Needed__c * price;
                    }
                }                
                //system.assert(false, totalFixedPrice+'/n/n/n/n'+  countUnfixedLineItems + '/n/n/n'+ databseSOKHRecoord.Fixed_Price__c);
                if(totalFixedPrice <= databseSOKHRecoord.Fixed_Price__c && countUnfixedLineItems > 0){
                    errorMessage = '';
                } else if(totalFixedPrice > databseSOKHRecoord.Fixed_Price__c){
                    errorMessage = Label.Kit_Line_Item_Exceeded_Total_Price;
                } else if(countUnfixedLineItems < 1) {
                    errorMessage = Label.Kit_Line_Item_No_Unfixed_Line_Item;
                }
                
                
                // If no error, then perform recalculation logic for line ite  records of Kit
                if(errorMessage.length() == 0){
                    recalculateSOKHLineItems(new List<Service_Order_Kit_Header__c>{databseSOKHRecoord},sokitLineItemObj);
                }            
            }
            else {
                databseSOKHRecoord.Fixed_Price__c = 0;
                if(databseSOKHRecoord.Service_Order_Line_Items__r != null) {
                    for (Service_Order_Line_Item__c khLineItemRec : databseSOKHRecoord.Service_Order_Line_Items__r) {
                    	Decimal price = (isTaxIncludingPricing && String.isBlank(khLineItemRec.Deal__c)) ? khLineItemRec.Price_When_Tax_Included__c : khLineItemRec.Kit_Price__c;
                    
                    	if(khLineItemRec.Tax_Percent__c == null) {
                        	khLineItemRec.Tax_Percent__c = 0;
                        }
                        // Update current updating record
                        if(khLineItemRec.Id == sokitLineItemObj.Id){
                            if(price != khLineItemRec.Kit_Price__c) {
                                    sokitLineItemRec.Is_Fixed_Kit_LineItem_SO__c = true;
                                    sokitLineItemRec.Is_Fixed_Kit_LineItem_SO__c = true;
                                }
                            price = sokitLineItemObj.KitPrice;
	                        if(isTaxIncludingPricing && String.isBlank(khLineItemRec.Deal__c)){
	                        	khLineItemRec.Price_When_Tax_Included__c = price;
	                        	khLineItemRec.Kit_Price__c = (price / (1 + (khLineItemRec.Tax_Percent__c / 100))); 
                            }else{
	                        	khLineItemRec.Kit_Price__c = price; /* Added by richa 23/11/2016 */ 
                            }
                            khLineItemRec.Qty_Needed__c =  sokitLineItemObj.QtyNeeded;
                            serviceOrderLineItemList.add(khLineItemRec);
                            
                        }
                        TotalAmount += khLineItemRec.Qty_Needed__c * price;
                        TotalTaxAmount +=  (khLineItemRec.Qty_Needed__c * ((price * khLineItemRec.Tax_Percent__c)/100));
                    }
                    databseSOKHRecoord.Fixed_Price__c= TotalAmount;
                    databseSOKHRecoord.Tax_amount__c = TotalTaxAmount;
                }
                
                if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                
                if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                ServiceOrderLineItemTriggerHelper.isTriggerExecuted =true;
                
                //serviceOrderLineItemList = resolveRoundOffIssue(serviceOrderLineItemList, TotalAmount, isTaxIncludingPricing);
                update serviceOrderLineItemList;
                
                update databseSOKHRecoord;
                ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false; // Added by richa #1918 24 april oversold committed quantity was not updating to coli of corresponding soli told by subhrant
            }
            //system.assert(false,sokitLineItemRec);
        }
        return (errorMessage.length() != 0) ? new Errorhandler('300', errorMessage) : new Errorhandler('200', 'Success');
    }
    
    /**
     * Name: recalculateSOKHLineItems
     * Desc: Method to recalculate service order kit heder line items price after updations in service order kit header fixed price value
     * @param: Service_Order_Kit_Header__c databseSOKHRecoord, SOHeaderWrapper.SOLineItem sokitLineItemObj
     * @return: 
     **/
    private static void recalculateSOKHLineItems(List<Service_Order_Kit_Header__c> databseSOKHRecoordList,SOHeaderWrapper.SOLineItem sokitLineItemObj) {
		 if(databseSOKHRecoordList.size() == 0) {
        	return;
        }
        Service_Order_Kit_Header__c databseSOKHRecoord = databseSOKHRecoordList[0];
        List<Service_Order_Line_Item__c> updateKitLineItems = new List<Service_Order_Line_Item__c>();
        Map<Id, Service_Order_Line_Item__c> unFixedLineItemsMap = new Map<Id, Service_Order_Line_Item__c>();
        List<Service_Order_Line_Item__c> ServicelineItemlist = new List<Service_Order_Line_Item__c>();
        Double fixedItemTotal = 0;
        Double unFixedItemTotal = 0;
        Decimal TotalPrice = 0;
        Decimal TotalTaxAmount = 0;
        //system.assert(false,databseSOKHRecoord);
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        for(Service_Order_Line_Item__c khli : databseSOKHRecoord.Service_Order_Line_Items__r){
            if(khli.Fixed_Price__c || khli.Is_Fixed_Kit_LineItem_SO__c){
                if(isTaxIncludingPricing && String.isBlank(khli.Deal__c)){
                    fixedItemTotal += (khli.Price_When_Tax_Included__c * khli.Qty_Needed__c );
                }else{
                    fixedItemTotal += (khli.Kit_Price__c * khli.Qty_Needed__c );   
                }
                ServicelineItemlist.add(khli);
                } else { 
                unFixedLineItemsMap.put(khli.Id, khli);
                if(isTaxIncludingPricing && String.isBlank(khli.Deal__c)){
                    unFixedItemTotal += khli.Price_When_Tax_Included__c  *  khli.Qty_Needed__c;
                }else{
                    unFixedItemTotal += khli.Kit_Price__c  *  khli.Qty_Needed__c;
                }                
            }
        } 
        
        Double desiredUnFixedTotal = 0; 
       
	        desiredUnFixedTotal = databseSOKHRecoord.Fixed_Price__c - fixedItemTotal;
                
        Double Adjustment = (unFixedItemTotal != 0) ? desiredUnFixedTotal / unFixedItemTotal : 1;
        if(Adjustment != 1){ 
            for(Service_Order_Line_Item__c khli : unFixedLineItemsMap.values()){
                if(isTaxIncludingPricing && String.isBlank(khli.Deal__c)){    
                      khli.Price_When_Tax_Included__c = (khli.Price_When_Tax_Included__c * Adjustment).setscale(2, RoundingMode.HALF_UP);
                      khli.Kit_Price__c =  (khli.Price_When_Tax_Included__c / (1 + ( (khli.Tax_Percent__c / 100))));
                }else{
                     khli.Kit_Price__c =  khli.Kit_Price__c  * Adjustment;
                }               
                updateKitLineItems.add(khli);
                ServicelineItemlist.add(khli);                
            }
        }                 
        for(Service_Order_Line_Item__c khli : ServicelineItemlist){   
            if(!(khli.Fixed_Price__c || khli.Is_Fixed_Kit_LineItem_SO__c)){
                if(isTaxIncludingPricing && String.isBlank(khli.Deal__c)){
	                TotalPrice += (khli.Qty_Needed__c * khli.Price_When_Tax_Included__c).setscale(2, RoundingMode.HALF_UP);
	                TotalTaxAmount += (khli.Qty_Needed__c * ((khli.Price_When_Tax_Included__c)/100)).setscale(2, RoundingMode.HALF_UP); 
            	} else {
	                TotalPrice +=  (khli.Qty_Needed__c * khli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);
                TotalTaxAmount +=  (khli.Qty_Needed__c * ((khli.Kit_Price__c * khli.Tax_Percent__c)/100)).setscale(2, RoundingMode.HALF_UP); 
            }
            }
            else{  
                if(isTaxIncludingPricing && String.isBlank(khli.Deal__c)){
                    TotalPrice += (khli.Qty_Needed__c *  khli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);
                    TotalTaxAmount += (khli.Qty_Needed__c * ((khli.Kit_Price__c * khli.Tax_Percent__c)/100)).setscale(2, RoundingMode.HALF_UP);
                }else{
                    TotalPrice += (khli.Qty_Needed__c * khli.Kit_Price__c).setscale(2, RoundingMode.HALF_UP);
                    TotalTaxAmount +=  (khli.Qty_Needed__c * ((khli.Kit_Price__c * khli.Tax_Percent__c)/100)).setscale(2, RoundingMode.HALF_UP);
                }
            }  
        } 
        
        if(updateKitLineItems.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            databseSOKHRecoord.Is_Fixed_Kit_Header_SO__c = true;
            databseSOKHRecoord.Fixed_Price__c= TotalPrice;
            databseSOKHRecoord.Tax_amount__c = TotalTaxAmount;
            ServiceOrderLineItemTriggerHelper.isTriggerExecuted =true;
            List<SObject> sObjectList = new List<SObject>();
            if(!(databseSOKHRecoord.Is_Fixed_Kit_Header_SO__c || databseSOKHRecoord.Fixed_Price_Flag__c )){
                if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                sObjectList.add(databseSOKHRecoord);
                //update databseSOKHRecoord;
            }
            //updateKitLineItems = resolveRoundOffIssue(updateKitLineItems, TotalPrice, isTaxIncludingPricing);
            
            sObjectList.addAll((List<SObject>) updateKitLineItems);
            //update updateKitLineItems;
            update sObjectList;
        } 

    }
    
    // error handling class
    public class Errorhandler {
        public string ResponseCode;
        public string ResponseMeassage;
        
        public Errorhandler(string ResponseCode, string ResponseMeassage){
            this.ResponseCode = ResponseCode;
            this.ResponseMeassage = ResponseMeassage;
        }
        
        public Errorhandler(Errorhandler errorHandler){
            this.ResponseCode = errorHandler.ResponseCode;
            this.ResponseMeassage = errorHandler.ResponseMeassage;
        }
    }
    
    /*
    To calculate Tax  or exeptions
    */
    /*public static Decimal getApplicableTaxes(Map<Id,List<Sales_Tax_Item__c>> PartIdToSalesTaxItemMap,Service_Order_Line_Item__c SoliRec, List<Tax_Exemption__c> taxExtemptionList) {
        decimal TotalTaxApplicable = 0;
        List<Sales_Tax_Item__c> SaleTaxItemListForPart = new List<Sales_Tax_Item__c>();
        if(SoliRec.part__c !=null){
          
            SaleTaxItemListForPart = PartIdToSalesTaxItemMap.get(SoliRec.part__c);
            if(SaleTaxItemListForPart != null ){
                   for(Sales_Tax_Item__c SalestaxItemRec :  SaleTaxItemListForPart){
                        boolean taxExtempt = false;
                        for(Tax_Exemption__c TaxExptemRec :  taxExtemptionList){  
                            if(SalestaxItemRec.Id == TaxExptemRec.Sales_Tax_Item__c){
                                taxExtempt = true;                      
                            }                           
                        }if(taxExtempt == false){  
                            TotalTaxApplicable += SalestaxItemRec.Rate__c !=null ? SalestaxItemRec.Rate__c : 0;
                        }
                   }
            }  
        }
        else if(SoliRec.fee__c !=null){
            SaleTaxItemListForPart = PartIdToSalesTaxItemMap.get(SoliRec.fee__c);
            if(SaleTaxItemListForPart != null ){
                   for(Sales_Tax_Item__c SalestaxItemRec :  SaleTaxItemListForPart){
                        boolean taxExtempt = false;
                        for(Tax_Exemption__c TaxExptemRec :  taxExtemptionList){  
                            if(SalestaxItemRec.Id == TaxExptemRec.Sales_Tax_Item__c){
                                taxExtempt = true;                      
                            }                           
                        }if(taxExtempt == false){  
                            TotalTaxApplicable += SalestaxItemRec.Rate__c !=null ? SalestaxItemRec.Rate__c : 0;
                        }
                   }
            }  
        }else if(SoliRec.Labour_Code__c !=null ){
             SaleTaxItemListForPart = PartIdToSalesTaxItemMap.get(SoliRec.Labour_Code__c);
            if(SaleTaxItemListForPart != null ){
                   for(Sales_Tax_Item__c SalestaxItemRec :  SaleTaxItemListForPart){
                        boolean taxExtempt = false;
                        for(Tax_Exemption__c TaxExptemRec :  taxExtemptionList){  
                            if(SalestaxItemRec.Id == TaxExptemRec.Sales_Tax_Item__c){
                                taxExtempt = true;                      
                            }                           
                        }if(taxExtempt == false){  
                            TotalTaxApplicable += SalestaxItemRec.Rate__c !=null ? SalestaxItemRec.Rate__c : 0;
                        }
                   }
            }   
        
        }       
        return TotalTaxApplicable;
    } */
    
   public static Decimal getApplicableTaxes(Map<Id,List<Sales_Tax_Item__c>> PartIdToSalesTaxItemMap,Service_Order_Line_Item__c SoliRec, List<Tax_Exemption__c> taxExtemptionList,List<Individual_Tax__c> IndividualTaxToinsert ) {        
        decimal TotalTaxApplicable = 0;
       
        List<Sales_Tax_Item__c> SaleTaxItemListForPart = new List<Sales_Tax_Item__c>();
        if(SoliRec.part__c !=null){
            SaleTaxItemListForPart = PartIdToSalesTaxItemMap.get(SoliRec.part__c);
            if(SaleTaxItemListForPart != null ){
                   for(Sales_Tax_Item__c SalestaxItemRec :  SaleTaxItemListForPart){
                        boolean taxExtempt = false;
                        for(Tax_Exemption__c TaxExptemRec :  taxExtemptionList){  
                            if(SalestaxItemRec.Id == TaxExptemRec.Sales_Tax_Item__c){
                                taxExtempt = true;                      
                            }                           
                        }if(taxExtempt == false){  
                            TotalTaxApplicable += SalestaxItemRec.Rate__c !=null ? SalestaxItemRec.Rate__c : 0;
                            if(String.isBlank(SoliRec.Deal__c)) {
                                Individual_Tax__c IndividualTaxItem = new Individual_Tax__c(Service_Order_Line_Item__c = SoliRec.Id,Tax_Rate__c = SalestaxItemRec.Rate__c,Sales_Tax_Item_Name__c= SalestaxItemRec.Name__c, CO_Line_Item__c = SoliRec.CO_Line_Item__c );
                                IndividualTaxToinsert.add(IndividualTaxItem);   
                        	}
                        }
                   }
            }  
        }
        else if(SoliRec.fee__c !=null){
            SaleTaxItemListForPart = PartIdToSalesTaxItemMap.get(SoliRec.fee__c);
            if(SaleTaxItemListForPart != null ){
                   for(Sales_Tax_Item__c SalestaxItemRec :  SaleTaxItemListForPart){
                        boolean taxExtempt = false;
                        for(Tax_Exemption__c TaxExptemRec :  taxExtemptionList){  
                            if(SalestaxItemRec.Id == TaxExptemRec.Sales_Tax_Item__c){
                                taxExtempt = true;                      
                            }                           
                        }if(taxExtempt == false){  
                            TotalTaxApplicable += SalestaxItemRec.Rate__c !=null ? SalestaxItemRec.Rate__c : 0;
                            if(String.isBlank(SoliRec.Deal__c)) {
	                            Individual_Tax__c IndividualTaxItem = new Individual_Tax__c(Service_Order_Line_Item__c = SoliRec.Id,Tax_Rate__c = SalestaxItemRec.Rate__c,Sales_Tax_Item_Name__c= SalestaxItemRec.Name__c, CO_Line_Item__c = SoliRec.CO_Line_Item__c);
	                            IndividualTaxToinsert.add(IndividualTaxItem);
                            }
                        }
                   }
            }  
        }else if(SoliRec.Labour_Code__c !=null ){
             SaleTaxItemListForPart = PartIdToSalesTaxItemMap.get(SoliRec.Labour_Code__c);
            if(SaleTaxItemListForPart != null ){
                   for(Sales_Tax_Item__c SalestaxItemRec :  SaleTaxItemListForPart){
                        boolean taxExtempt = false;
                        for(Tax_Exemption__c TaxExptemRec :  taxExtemptionList){  
                            if(SalestaxItemRec.Id == TaxExptemRec.Sales_Tax_Item__c){
                                taxExtempt = true;                      
                            }                           
                        }if(taxExtempt == false){  
                            TotalTaxApplicable += SalestaxItemRec.Rate__c !=null ? SalestaxItemRec.Rate__c : 0;
                            if(String.isBlank(SoliRec.Deal__c)) {
                                Individual_Tax__c IndividualTaxItem = new Individual_Tax__c(Service_Order_Line_Item__c = SoliRec.Id,Tax_Rate__c = SalestaxItemRec.Rate__c,Sales_Tax_Item_Name__c= SalestaxItemRec.Name__c );
                                IndividualTaxToinsert.add(IndividualTaxItem);
                        	}
                        }
                   }
            }          
        }    
        return TotalTaxApplicable;
   }
   
   // Round Off Adjusting - Added by TK
    private static List<Service_Order_Line_Item__c> resolveRoundOffIssue(List<Service_Order_Line_Item__c> soliList, Decimal unFixedKitHeaderPrice,
    													Boolean isTaxIncludingPricing) {
        Decimal total = 0;
    	for(Service_Order_Line_Item__c solineItemRec : soliList) {
    		if(!isTaxIncludingPricing) {
    			total += (solineItemRec.Kit_Price__c * solineItemRec.Qty_Needed__c);
    		} else {
    			total += (solineItemRec.Price_When_Tax_Included__c * solineItemRec.Qty_Needed__c);
    		}
    	}
    	if(total - unFixedKitHeaderPrice != 0) {
    		if(soliList.size() > 0) {
    			if(!isTaxIncludingPricing) {
	    			soliList[soliList.size() - 1].Kit_Price__c -= ((total - unFixedKitHeaderPrice) / soliList[soliList.size() - 1].Qty_Needed__c).setScale(2, RoundingMode.HALF_UP);
	    		} else {
	    			soliList[soliList.size() - 1].Price_When_Tax_Included__c -= ((total - unFixedKitHeaderPrice)/ soliList[soliList.size() - 1].Qty_Needed__c).setScale(2, RoundingMode.HALF_UP);
	    		}
    		}
    	}
    	return soliList;
    }
    
    //Analysis: Nidhi
    public static void changePriceWhenCustomerIsChanged(Set<Id> soHeaderIdSet, String coHeaderId) {
    	soKitPriceCalculation(null, soHeaderIdSet, coHeaderId);
    }
    
    public static String soKitPriceCalculation(Set<Id> sokhIdSet, Set<Id> soHeaderIdSet, String coHeaderId) {
        List<Service_Order_Kit_Header__c> sokhList = getSOKitRecList(sokhIdSet, soHeaderIdSet, coHeaderId);
		coHeaderId = (String.isBlank(coHeaderId) && (sokhList.size() > 0)) ? sokhList[0].Service_Order_Header__r.CO_Header__c : coHeaderId;
        
        sokhList = applyPriceLevel(sokhList);
        sokhList = applySalesTax(sokhList, soHeaderIdSet, coHeaderId);

        List<Sobject> sobjListToUpdate = new List<Sobject>(); 
        if(sokhList.size() > 0) {
            sobjListToUpdate.addAll((List<Sobject>)sokhList);
            for(Service_Order_Kit_Header__c sokhRec : sokhList) {
                if(sokhRec.Service_Order_Line_Items__r != null) {
                    sobjListToUpdate.addAll((List<Sobject>)sokhRec.Service_Order_Line_Items__r);
                }
            }
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        	if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            update sobjListToUpdate;
        }
        return 'Success';
    }
    
    public static List<Service_Order_Kit_Header__c> applyPriceLevel(List<Service_Order_Kit_Header__c> sokhList) {
        
        Boolean isDealMerchOrIntenalSOKitExists = false;
        for(Service_Order_Kit_Header__c sokhRec : sokhList) {
        	for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
        		if(soliRec.Part__c != null) {
        			soliRec.Part__r.Retail_Price__c = (soliRec.Part__r.Retail_Price__c != null) ? soliRec.Part__r.Retail_Price__c : soliRec.Part__r.Retail_Price__c;
        		}
        	}
        	
            if(String.isNotBlank(sokhRec.Service_Order_Header__r.Deal__c) || sokhRec.Service_Order_Header__r.Job_Type__c == 'Internal') {
        		isDealMerchOrIntenalSOKitExists = true;
        		break;
        	}
        }
        
        Price_Level__c internalDefaultPL = isDealMerchOrIntenalSOKitExists ? getInternalPriceLevel() : null;
        
        Decimal discount;
        String partPriceBase;
        Decimal laborRate; 
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        for(Service_Order_Kit_Header__c sokhRec : sokhList) {
            if(sokhRec.Fixed_Price_Flag__c) {
                continue;
            }
            if(String.isNotBlank(sokhRec.Service_Order_Header__r.Deal__c) || sokhRec.Service_Order_Header__r.Job_Type__c == 'Internal') {
            	partPriceBase = internalDefaultPL.Part_Price_Base__c;
            	discount = internalDefaultPL.Discount_Markup__c;
            	laborRate = internalDefaultPL.Labour_Rate__c;
            } else if(String.isNotBlank(sokhRec.Service_Order_Header__r.Provider__c)) {
            	partPriceBase = sokhRec.Service_Order_Header__r.Provider__r.Price_Level__r.Part_Price_Base__c;
            	discount = sokhRec.Service_Order_Header__r.Provider__r.Price_Level__r.Discount_Markup__c;
            	laborRate = sokhRec.Service_Order_Header__r.Provider__r.Price_Level__r.Labour_Rate__c;
            } else {
            	partPriceBase = sokhRec.Service_Order_Header__r.CO_Header__r.Part_Price_Base_From_Price_Level__c;
            	discount = sokhRec.Service_Order_Header__r.CO_Header__r.Discount_Markup_From_Prive_Level__c;
            	laborRate = sokhRec.Service_Order_Header__r.CO_Header__r.Labour_Rate_From_Price_Level__c;
        	}
            
            for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
                if(soliRec.Fixed_Price__c) {
                    continue;
                }
                if(soliRec.Part__c != null) {
                	String pricingField = TaxCalculation.getPricingFieldByPLBaseValueField(partPriceBase);
                	soliRec.Actual_Kit_Price__c = (soliRec.Part__r.get(pricingField) != null) ? Decimal.valueOf(String.valueOf(soliRec.Part__r.get(pricingField))) : 0;
                	soliRec.Kit_Price__c = (soliRec.Actual_Kit_Price__c != null) ? soliRec.Actual_Kit_Price__c.setScale(2, RoundingMode.HALF_UP) : 0;
                	soliRec.Price_When_Tax_Included__c = isTaxIncludingPricing ? soliRec.Kit_Price__c : 0;
                	
                    if(isTaxIncludingPricing && !TaxCalculation.COST_FIELDS_SET.contains(pricingField) && soliRec.Part__r.Applicable_Tax__c != null && 
                    	soliRec.Part__r.Applicable_Tax__r.Rate__c != null) {
                        Decimal appTaxRate = soliRec.Part__r.Applicable_Tax__r.Rate__c;
                        if(appTaxRate == -100 || appTaxRate == null) { // To handle divide by zero error
                            appTaxRate = 0;
                        }
                        soliRec.Kit_Price__c = (soliRec.Kit_Price__c / (1 + (appTaxRate / 100)));
                    }
                    soliRec.Kit_Price__c = (soliRec.Kit_Price__c + (soliRec.Kit_Price__c * discount / 100));
                    
                } else if(soliRec.Fee__c != null) {
                	/*if(soliRec.Is_Environmental_Fee__c) {
		        		if(isTaxIncludingPricing) {
		        			soliRec.Kit_Price__c = (soliRec.Price_When_Tax_Included__c != null) ? soliRec.Price_When_Tax_Included__c : 0;
		        		} else {
		        			soliRec.Kit_Price__c = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
		        		}
		        	} else {*/
	        		soliRec.Kit_Price__c = soliRec.Fee__r.Price__c != null ? soliRec.Fee__r.Price__c : 0;
	        		soliRec.Price_When_Tax_Included__c = isTaxIncludingPricing ? soliRec.Kit_Price__c : 0;
		        	//}
		        	if(isTaxIncludingPricing) {
	                    Decimal appTaxRate = soliRec.Fee__r.Applicable_Tax__r.Rate__c;
	                    if(appTaxRate == -100 || appTaxRate == null) {
	                        appTaxRate = 0;
	                    }
	                    soliRec.Kit_Price__c = soliRec.Kit_Price__c / (1 + (appTaxRate / 100));
		        	}
                } else if(soliRec.Labour_Code__c != null) {
                	if(soliRec.Labour_Code__r.Fixed_Rate__c || (laborRate == null || laborRate == 0)) {
                        soliRec.Kit_Price__c = soliRec.Labour_Code__r.Rate__c;
                    } else {
                        soliRec.Kit_Price__c = laborRate;
                    }
                    if(isTaxIncludingPricing) {
                        Decimal appTaxRate = soliRec.Labour_Code__r.Applicable_Tax__r.Rate__c;
                        if(appTaxRate == -100 || appTaxRate == null) {
                            appTaxRate = 0;
                        }
                        soliRec.Kit_Price__c = (soliRec.Kit_Price__c / (1 + (appTaxRate / 100)));
                    }
                }  
                //soliRec.Actual_Kit_Price__c = soliRec.Kit_Price__c;
            }
        }
        return sokhList;
    }
    
    private static Price_Level__c getCOPriceLevel(String coHeaderId) {
    	CO_Header__c coHeaderRec = [Select Part_Price_Base_From_Price_Level__c, Discount_Markup_From_Prive_Level__c From CO_Header__c 
    							where Id =: coHeaderId];
		Price_Level__c appliedPriceLevel = new Price_Level__c(Part_Price_Base__c = coHeaderRec.Part_Price_Base_From_Price_Level__c, 
															Discount_Markup__c = coHeaderRec.Discount_Markup_From_Prive_Level__c);
		return appliedPriceLevel;
    }
    
    private static Price_Level__c getInternalPriceLevel() {
		List<Price_Level__c> internalDefaultPLList = SOTriggerHelper.getInternalDefaultPriceLevel();
        if(internalDefaultPLList == null || internalDefaultPLList.size() == 0) {
            internalDefaultPLList = SOTriggerHelper.getDefaultPriceLevel();
        }
		return internalDefaultPLList[0];
    }
    
    public static List<Service_Order_Kit_Header__c> applySalesTax(List<Service_Order_Kit_Header__c> sokhList, Set<Id> soHeaderIdSet, String coHeaderId) {
    	Boolean isIntenalSOKitExists = false;
        Set<Id> thirdPartySOHeaderIdSet = new Set<Id>();
        Set<Id> salesTaxIdSet = new Set<Id>();
        for(Service_Order_Kit_Header__c sokhRec : sokhList) {
        	if(String.isNotBlank(sokhRec.Deal__c)) {
        		continue;
        	}
            if(sokhRec.Service_Order_Header__r.Job_Type__c == 'Internal') {
        		isIntenalSOKitExists = true;
        	} else if(String.isNotBlank(sokhRec.Service_Order_Header__r.Provider__c)) {
    			thirdPartySOHeaderIdSet.add(sokhRec.Service_Order_Header__c);
            }
            
            for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
                if(soliRec.Part__c != null && soliRec.Part__r.Taxable__c && soliRec.Part__r.Applicable_Tax__c != null) {
                    salesTaxIdSet.add(soliRec.Part__r.Applicable_Tax__c);
                } else if(soliRec.Fee__c != null && soliRec.Fee__r.Taxable__c && soliRec.Fee__r.Applicable_Tax__c != null) {
                    salesTaxIdSet.add(soliRec.Fee__r.Applicable_Tax__c);
                } else if(soliRec.Labour_Code__c != null && soliRec.Labour_Code__r.Taxable__c && soliRec.Labour_Code__r.Applicable_Tax__c != null) {
                    salesTaxIdSet.add(soliRec.Labour_Code__r.Applicable_Tax__c);
                }
            }
        }
        
        String internalDefaultSalesTaxId;
        if(isIntenalSOKitExists) {
            internalDefaultSalesTaxId = GeneralConfiguration.getDefaultSalesTaxOnInternalService();
            if(String.isNotBlank(internalDefaultSalesTaxId)) {
                salesTaxIdSet.add(internalDefaultSalesTaxId);
            }
        }
        
        Map<Id, Set<Id>> headerIdToExemptedTaxItemIdSetMap = new Map<Id, Set<Id>>();
        Map<Id, List<Applicable_Taxes__c>> salesTaxIdToAppTaxRecordsMap = new Map<Id, List<Applicable_Taxes__c>>();
        Map<Id, Decimal> salesTaxIdToTaxRateMap = new Map<Id, Decimal>();
        if(salesTaxIdSet.size() > 0) {
	        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        List<Applicable_Taxes__c> applicableTaxList = [SELECT Sales_Tax_Item__c, Sales_Tax__c, Sales_Tax_Item__r.Tax_Parts__c, 
	                                                            Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c 
	                                                            from Applicable_Taxes__c where Sales_Tax__c IN : salesTaxIdSet];
	                                                            
	        for(Applicable_Taxes__c appTax : applicableTaxList) {
	            List<Applicable_Taxes__c> appTaxRecordList = new List<Applicable_Taxes__c>();
	            if(salesTaxIdToAppTaxRecordsMap.containsKey(appTax.Sales_Tax__c)) {
	                appTaxRecordList = salesTaxIdToAppTaxRecordsMap.get(appTax.Sales_Tax__c);
	            } 
	            appTaxRecordList.add(appTax);
	            salesTaxIdToAppTaxRecordsMap.put(appTax.Sales_Tax__c, appTaxRecordList);
	        } 
	        
	        for(Id salesTaxId : salesTaxIdToAppTaxRecordsMap.keyset()) {
	            Decimal salesTaxRate = 0;
	            for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
	                salesTaxRate += ((appTax.Sales_Tax_Item__r.Rate__c != null) ? appTax.Sales_Tax_Item__r.Rate__c : 0);
	            }
	            salesTaxIdToTaxRateMap.put(salesTaxId, salesTaxRate);
	        }
	        
            // Get list of Tax Exemptions for given coHeader and soheader ids
            String queryStr = 'SELECT Id, Sales_Tax_Item__r.Rate__c, Sales_Tax_Item__c, CO_Header__c, Service_Order_Header__c FROM Tax_Exemption__c';
            if(String.isNotBlank(coHeaderId)) {
            	queryStr += ' WHERE CO_Header__c =: coHeaderId';
            }
            if(soHeaderIdSet != null && soHeaderIdSet.size() > 0) {
            	queryStr += ((queryStr.indexOf('WHERE') != -1) ? ' OR' : ' WHERE') + ' Service_Order_Header__c IN: soHeaderIdSet';
            }
            if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Tax_Exemption__c> taxExemptionList = (queryStr.indexOf('WHERE') != -1) ? Database.query(queryStr) : new List<Tax_Exemption__c>();

         	for(Tax_Exemption__c taxExemptionRec : taxExemptionList) {
	        	if(String.isNotBlank(taxExemptionRec.Service_Order_Header__c)) {
	        		if(!headerIdToExemptedTaxItemIdSetMap.containsKey(taxExemptionRec.Service_Order_Header__c)) {
	        			headerIdToExemptedTaxItemIdSetMap.put(taxExemptionRec.Service_Order_Header__c, new Set<Id>{taxExemptionRec.Sales_Tax_Item__c});
		        	} else {
						headerIdToExemptedTaxItemIdSetMap.get(taxExemptionRec.Service_Order_Header__c).add(taxExemptionRec.Sales_Tax_Item__c);		        		
	        		}
	        	} 
	        	if(String.isNotBlank(taxExemptionRec.CO_Header__c)) {
	        		if(!headerIdToExemptedTaxItemIdSetMap.containsKey(taxExemptionRec.CO_Header__c)) {
	        			headerIdToExemptedTaxItemIdSetMap.put(taxExemptionRec.CO_Header__c, new Set<Id>{taxExemptionRec.Sales_Tax_Item__c});
		        	} else {
						headerIdToExemptedTaxItemIdSetMap.get(taxExemptionRec.CO_Header__c).add(taxExemptionRec.Sales_Tax_Item__c);		        		
	        		}
	        	}
	        }
        }

        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Decimal taxAmount = 0;
        Decimal sokhTotal = 0;
        
        List<Individual_Tax__c> individualTaxToInsert = new List<Individual_Tax__c>();
        for(Service_Order_Kit_Header__c sokhRec : sokhList) {
        	sokhTotal = 0;
        	taxAmount = 0;
        	Decimal unfixedKitHeaderTotal = 0;
        	String exemptedSectionId = (sokhRec.Service_Order_Header__r.Job_Type__c == 'Internal') ? null : (String.isNotBlank(sokhRec.Service_Order_Header__r.Provider__c) ? 
        									sokhRec.Service_Order_Header__c : sokhRec.Service_Order_Header__r.CO_Header__c);
            for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
                Decimal rate = 0;
                Decimal exemptionRate = 0;
                if(String.isBlank(sokhRec.Deal__c)) {
                	Id salesTaxId;
	                if(sokhRec.Service_Order_Header__r.Job_Type__c == 'Internal') {
	                	salesTaxId = internalDefaultSalesTaxId;
	                } if(soliRec.Part__r.Applicable_Tax__c != null) {
	                    salesTaxId = soliRec.Part__r.Applicable_Tax__c;
	                } else if(soliRec.Fee__r.Applicable_Tax__c != null) {
	                    salesTaxId = soliRec.Fee__r.Applicable_Tax__c;
	                } else if(soliRec.Labour_Code__r.Applicable_Tax__c != null) {
	                    salesTaxId = soliRec.Labour_Code__r.Applicable_Tax__c;
	                }
	                
	                soliRec.Applicable_Tax__c = salesTaxId;
	                if(salesTaxIdToAppTaxRecordsMap.containsKey(salesTaxId)) {
	                    for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
	                        if(exemptedSectionId != null && headerIdToExemptedTaxItemIdSetMap.containsKey(exemptedSectionId) && 
	                        	headerIdToExemptedTaxItemIdSetMap.get(exemptedSectionId).contains(appTax.Sales_Tax_Item__c)) {
	                            exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
	                        } else {
	                        	Individual_Tax__c individualTaxRec = new Individual_Tax__c();
		                    	individualTaxRec.Service_Order_Line_Item__c = soliRec.Id;
		                    	individualTaxRec.Sales_Tax_Item_Name__c = appTax.Sales_Tax_Item__r.Name__c;
		                    	individualTaxRec.Tax_Rate__c = appTax.Sales_Tax_Item__r.Rate__c;
		                    	individualTaxToInsert.add(individualTaxRec);
	                        } 
	                    } 
	                }
	                      
	                if(salesTaxIdToTaxRateMap.containsKey(salesTaxId)) {
	                    rate = salesTaxIdToTaxRateMap.get(salesTaxId);
	                }
                }
                soliRec.Tax_Percent__c = rate - exemptionRate;
                soliRec.Kit_Price__c = soliRec.Kit_Price__c.setScale(2, RoundingMode.HALF_UP);
                if(isTaxIncludingPricing) {
                    if(sokhRec.Fixed_Price_Flag__c || soliRec.Fixed_Price__c) {
                    	if(soliRec.Price_When_Tax_Included__c != null) {
                    		soliRec.Kit_Price__c = (soliRec.Price_When_Tax_Included__c / (1 + (soliRec.Tax_Percent__c / 100))).setScale(2, RoundingMode.HALF_UP);
                    	} else {
                    		soliRec.Kit_Price__c = (soliRec.Kit_Price__c / (1 + (soliRec.Tax_Percent__c / 100))).setScale(2, RoundingMode.HALF_UP);
                    	}
                    }
                    soliRec.Price_When_Tax_Included__c = (soliRec.Kit_Price__c * (1 + (soliRec.Tax_Percent__c / 100))).setScale(2, RoundingMode.HALF_UP);
                    sokhTotal += (soliRec.Price_When_Tax_Included__c * soliRec.Qty_Needed__c);
                    taxAmount += ((soliRec.Kit_Price__c * soliRec.Qty_Needed__c * soliRec.Tax_Percent__c) / 100);
                    
                    if(!soliRec.Fixed_Price__c) {
	                	unfixedKitHeaderTotal += (soliRec.Price_When_Tax_Included__c * soliRec.Qty_Needed__c);
	                	//unfixedLineItemList.add(soliRec);
	                }
	                
                } else {
                    // Deal Kit Header
                    sokhTotal += (soliRec.Kit_Price__c * soliRec.Qty_Needed__c);
                    taxAmount += ((soliRec.Kit_Price__c * soliRec.Qty_Needed__c * soliRec.Tax_Percent__c) / 100);
                    if(!soliRec.Fixed_Price__c) {
	                	unfixedKitHeaderTotal += (soliRec.Kit_Price__c * soliRec.Qty_Needed__c);
	                	//unfixedLineItemList.add(soliRec);
	                }
                }
                
                //Analysis: ?? soliRec.Fixed_Price__c = soliRec.Kit_Price__c;
            }
        	//resolveRoundOffIssue(sokhRec.Service_Order_Line_Items__r, unfixedKitHeaderTotal, isTaxIncludingPricing);
            sokhRec.Tax_Amount__c = taxAmount.setScale(2, RoundingMode.HALF_UP);
            sokhRec.Fixed_Price__c = sokhTotal.setScale(2, RoundingMode.HALF_UP);
        }
		
        /** START : Added this to delete existing individual tax record - Handling refresh co pricing and tax from co page */
        if(AccessControl.ifObjectFieldIsAccessible('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Individual_Tax__c> individualListTodelete = new List<Individual_Tax__c>([select Id from Individual_Tax__c where Service_Order_Line_Item__r.Service_Order_Kit_Header__c IN :sokhList]);
        
        if(AccessControl.ifObjectIsDeletable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(individualListTodelete.size() > 0) {
			delete individualListTodelete;        
        }
        /** END : Added this to delete existing individual tax record - Handling refresh co pricing and tax from co page */
                
        if(individualTaxToInsert.size() > 0) {
        	if(AccessControl.ifObjectFieldIsCreateable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        	insert individualTaxToInsert;
        }
        return sokhList;
    }
    
    
    private static List<Service_Order_Kit_Header__c> getSOKitRecList(Set<Id> sokhIdSet, Set<Id> soHeaderIdSet, String coHeaderId) {
    	String sokhQueryStr = 'SELECT Id, Deal__c, Fixed_Price__c, Fixed_Price_Flag__c,Service_Order_Header__r.Deal__c, Service_Order_Header__r.Job_Type__c, ' +
        	'Service_Order_Header__r.Provider__r.Price_Level__c, Service_Order_Header__r.Provider__c, Service_Order_Header__r.Provider__r.Price_Level__r.Discount_Markup__c, ' +
        	'Service_Order_Header__r.Provider__r.Price_Level__r.Labour_Rate__c, '+ 'Service_Order_Header__r.Provider__r.Price_Level__r.Part_Price_Base__c, ' +
        	'Service_Order_Header__r.CO_Header__c, Service_Order_Header__r.CO_Header__r.Part_Price_Base_From_Price_Level__c, ' +
        	'Service_Order_Header__r.CO_Header__r.Discount_Markup_From_Prive_Level__c, Service_Order_Header__r.CO_Header__r.Labour_Rate_From_Price_Level__c, ';
        	
        String queryStr = sokhQueryStr + ' (SELECT Id, Deal__c, Actual_Retail_Price__c, Actual_Kit_Price__c, Fixed_Price__c, Kit_Price__c, Retail_Price__c, Qty_Needed__c, ' + 
        	'Part__r.Average_Cost__c, Part__r.Last_Cost__c, Part__r.MSRP__c, Part__r.Retail_Price__c, Part__r.Taxable__c, Part__r.Applicable_Tax__c, ' +
        	'Part__r.Applicable_Tax__r.Rate__c, Fee__c, Fee__r.Price__c, Fee__r.Taxable__c, Fee__r.Applicable_Tax__c, Fee__r.Applicable_Tax__r.Rate__c, ' +
        	'Labour_Code__r.Rate__c, Labour_Code__c, Labour_Code__r.Fixed_Rate__c, Labour_Code__r.Taxable__c, Labour_Code__r.Applicable_Tax__c, Price_When_Tax_Included__c, ' +
        	'Labour_Code__r.Applicable_Tax__r.Rate__c, Total__c, Service_Order_Kit_Header__c, CO_Line_Item__c, Tax_Percent__c '+
        	'FROM Service_Order_Line_Items__r) FROM Service_Order_Kit_Header__c WHERE Service_Order_Header__r.Invoice_Number__c = null';
        	
        queryStr += ((coHeaderId != null) ? ' AND Service_Order_Header__r.CO_Header__c =: coHeaderId' : '');
        queryStr += (soHeaderIdSet != null && soHeaderIdSet.size() > 0) ? ' AND Service_Order_Header__c IN: soHeaderIdSet' : '';
        queryStr += ((sokhIdSet != null && sokhIdSet.size() > 0) ? ' AND Id IN: sokhIdSet' : '');
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Service_Order_Kit_Header__c> sokhList = Database.query(queryStr);
    	return sokhList;
    }
    
}