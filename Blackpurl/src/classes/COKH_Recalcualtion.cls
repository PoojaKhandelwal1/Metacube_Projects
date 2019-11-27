/**
 * Author: Ashish Garg
 * Since: Feb 18, 2016
 * Name: COKH_Recalcualtion
 * Description: Apex class to handle Customer Order Kit Header 
**/
public with sharing class COKH_Recalcualtion {

     /**
     * Name: AddCustomerCoForKititemUpdate
     * Desc: updating kit item
     * @param:  (1) customerId - String - Customer Id
     *          (2) coHeaderId - String - Customer Header Id
     * @return: void
    **/
    public class SalesTaxItemPart{ 
        Id  salestaxItemId = null; 
        Decimal salestaxItemTax =0;
        String salesTaxItemName = '';
        public SalesTaxItemPart(Id ApplicableTax,Decimal ApplicaleTaxRate, string SalesTaxItemName ){
            this.salestaxItemId = ApplicableTax;
            this.salestaxItemTax = ApplicaleTaxRate;
            this.salesTaxItemName = SalesTaxItemName;
        }
    }
    /*Analysis: Nidhi
    public static void AddCustomerCoForKititemUpdate(string  customerId ,string coHeaderId  ){
         COKHPriceLevelCalculationByMerchandise(null,customerId,coHeaderId);
    }*/
    
    /**
     * Name: CoKitInsert
     * Desc: Customer kit insert
     * @param:  (1) kitheaderId - String - Kit Header Record Id
     *          (2) coHeaderId - String - Customer Header Id
     * @return: String success or not
    **Analysis: Nidhi
     public static String CoKitInsert(String kitheaderId, String coHeaderId) {
        COKHPriceLevelCalculationByMerchandise(new List<Id>{kitheaderId}, null, coHeaderId);
        return 'Success'; 
    } 
    
     /**
     * Name: COKHPriceLevelCalculationByMerchandise
     * Desc: calculate price by merchandise
     * @param:  (1) listkitheaderId - List<Id> - List of kit header id
                (2) customerId - String - Customer Id
     *          (3) coHeaderId - String - Customer Header Id
     * @return: String success or not
    **Analysis: Nidhi
    public static String COKHPriceLevelCalculationByMerchandise(List<Id> listkitheaderId, String customerId, String coHeaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        Price_Level__c priceLevel = new Price_Level__c();
        Sales_Tax__c salesTax = new Sales_Tax__c();
        List<Tax_Exemption__c> taxExtemptionList = new List<Tax_Exemption__c>();
        if(String.isNotBlank(customerId)) {
            if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            Account customer = [SELECT Id, Price_Level__c, Price_Level__r.Active__c, Price_Level__r.Part_Price_Base__c, Price_Level__r.Discount_Markup__c,   
                                Price_Level__r.Labour_Rate__c, Sales_Tax__c FROM Account WHERE Id =: customerId];
            priceLevel = new Price_Level__c(Part_Price_Base__c = customer.Price_Level__r.Part_Price_Base__c, Active__c = customer.Price_Level__r.Active__c,
                                            Discount_Markup__c = (customer.Price_Level__r.Discount_Markup__c != null) ? customer.Price_Level__r.Discount_Markup__c : 0,
                                            Labour_Rate__c = customer.Price_Level__r.Labour_Rate__c);
            salesTax = new Sales_Tax__c(Id = customer.Sales_Tax__c); 
        } else {
        	if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                            
            CO_Header__c Coheader = [Select Part_Price_Base_From_Price_Level__c, Discount_Markup_From_Prive_Level__c, Customer__r.Sales_Tax__c,Customer__c 
                        From CO_Header__c  where Id =: coHeaderId ];
            
            if(Coheader.Customer__r.Sales_Tax__c !=null ){
                 salesTax =new Sales_Tax__c( Id = Coheader.Customer__r.Sales_Tax__c);   
            } else {
                List<Sales_Tax__c> listDefaultSalesTax = [select Id from Sales_Tax__c where default__c = true];
                if(listDefaultSalesTax.size() > 0) {
                	salesTax = new Sales_Tax__c(Id = listDefaultSalesTax[0].Id);   
                } else {
                	salesTax = new Sales_Tax__c();
                }
        	}
			priceLevel = new Price_Level__c(Part_Price_Base__c = Coheader.Part_Price_Base_From_Price_Level__c, Discount_Markup__c = Coheader.Discount_Markup_From_Prive_Level__c);
        }
        taxExtemptionList = [select Id,Sales_Tax_Item__r.Rate__c,Sales_Tax_Item__c from Tax_Exemption__c where CO_Header__c =: coHeaderId];
             
        if(listkitheaderId == null || listkitheaderId.size() < 0){
        	listkitheaderId = new List<Id>();
             Map<Id,CO_Kit_Header__c>  IdToCokhMap = new  Map<Id,CO_Kit_Header__c> ([Select Id, (Select Id, CO_Invoice_Header__r.Invoice_Status__c from CO_Invoice_Items__r) From CO_Kit_Header__c  where CO_Header__c =:coHeaderId]);
             for(Id cokhId : IdToCokhMap.keySet()) {
             	if(CustomerOrderCtrl_V2.isRefreshCOKit && IdToCokhMap.get(cokhId).CO_Invoice_Items__r.size() > 0 && IdToCokhMap.get(cokhId).CO_Invoice_Items__r[0].CO_Invoice_Header__r.Invoice_Status__c == 'Closed') {
             		continue;
             	}
             	listkitheaderId.add(cokhId);
             }
        }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Kit_Header__c> CoKitHeaderList = [Select Id,Price__c,Fixed_Price_Flag__c,Deal__c, (Select Deal__c,Price__c,Part__c,Fixed_Price__c,Actual_Kit_Price__c,Qty__c,Tax__c,Part__r.Retail_Price__c,Fee__r.Price__c,Part__r.Applicable_Tax__r.Rate__c,Fee__c,Fee__r.Applicable_Tax__r.Rate__c, Actual_Retail_Price__c From CO_Line_Items__r)
                                                    From CO_Kit_Header__c where CO_Kit_Header__c.Id IN : listkitheaderId];
        
        List<CO_Line_Item__c> ColiToUpdate = new List<CO_Line_Item__c>(); 
      
		Set<Id> partIdSet = new Set<Id>(); 
       	Set<Id> feeIdSet = new Set<Id>(); 
       	Set<Id> ColiSetForIndTax = new  set<Id>();
        
        Boolean isDealItemExists = false;
           // Create Set for Part Ids 
		   for(CO_Kit_Header__c CoKitHeaderRec : CoKitHeaderList ){
		        if(CoKitHeaderRec.CO_Line_Items__r != null &&   CoKitHeaderRec.CO_Line_Items__r.size() > 0){
		            if(String.isNotBlank(CoKitHeaderRec.Deal__c)) {
		        		isDealItemExists = true;
		        	}
                    for(CO_Line_Item__c coliRec : CoKitHeaderRec.CO_Line_Items__r){
		                if(coliRec.Part__c !=null){
		                    partIdSet.add(coliRec.Part__c);
		                    ColiSetForIndTax.add(coliRec.Id);
		                }else if (coliRec.Fee__c  !=null){
		                     feeIdSet.add(coliRec.Fee__c);
		                     ColiSetForIndTax.add(coliRec.Id);
		                }
		            }
		        }
		   }
          
          List<Price_Level__c> defaultPriceLevel;
          Sales_Tax__c defaultInternalSalesTaxRec = new Sales_Tax__c();
	        if(isDealItemExists) {
	        	defaultPriceLevel = SOTriggerHelper.getInternalDefaultPriceLevel();
		        if(defaultPriceLevel == null || defaultPriceLevel.size() == 0) {
		            defaultPriceLevel = SOTriggerHelper.getDefaultPriceLevel();
		        }
                
	 			String defaultSalesTaxId = GeneralConfiguration.getDefaultSalesTaxOnInternalService();
	      		List<Sales_Tax__c> salesTaxList = [select Rate__c from Sales_Tax__c where Id =: defaultSalesTaxId];
	      		if(salesTaxList.size() > 0) {
	      			defaultInternalSalesTaxRec = salesTaxList[0];
	      		}
	        }
          if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          List<Part__c> listPartSalesTax = new list<Part__c>([Select Id,Applicable_Tax__r.Rate__c,Applicable_Tax__c From Part__c where Id IN:partIdSet]);
           List<Fee__c> listFeeSalesTax = new list<Fee__c>([Select Id,Applicable_Tax__r.Rate__c,Applicable_Tax__c From Fee__c where Id IN:feeIdSet]);
         
         // List<Individual_Tax__c>  IndividualTaxList = new list<Part__c> ([Select Sales_Tax_Item_Name__c From Individual_Tax__c  where Id IN:partIdSet ]); 
                
           Map<Id,Decimal> partIdToPartRateMap = new  Map<Id,Decimal>();
           Map<Id,List<Id>> SalesTaxIdToPartIdMap = new Map<Id,List<Id>>();
           Map<Id,List<Sales_Tax_Item__c>> PartIdToSalesTaxItemMap = new Map<Id,List<Sales_Tax_Item__c>>();
           for(Part__c  partRec : listPartSalesTax){
                partIdToPartRateMap.put(partRec.Id,partRec.Applicable_Tax__r.Rate__c);
                if(SalesTaxIdToPartIdMap.containsKey(partRec.Applicable_Tax__c)){
                    SalesTaxIdToPartIdMap.get(partRec.Applicable_Tax__c).add(partRec.Id);
                }else{
                    SalesTaxIdToPartIdMap.put(partRec.Applicable_Tax__c, new List<Id>{partRec.Id});
                }
           }
           
           for(Fee__c  feeRec : listFeeSalesTax){
                partIdToPartRateMap.put(feeRec.Id,feeRec.Applicable_Tax__r.Rate__c);
                if(SalesTaxIdToPartIdMap.containsKey(feeRec.Applicable_Tax__c)){
                    SalesTaxIdToPartIdMap.get(feeRec.Applicable_Tax__c).add(feeRec.Id);
                }else{
                    SalesTaxIdToPartIdMap.put(feeRec.Applicable_Tax__c, new List<Id>{feeRec.Id});
                }
           }
           
           
           List<Applicable_Taxes__c> applicableTaxJunctionList = [select Id,Sales_Tax__c,Sales_Tax_Item__c,Sales_Tax_Item__r.Rate__c, Sales_Tax_Item__r.Name__c from Applicable_Taxes__c where  Sales_Tax__c IN : SalesTaxIdToPartIdMap.keySet()];
            
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
           
          if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
          List<Sales_Tax__c>  salesTaxList   = new list<Sales_Tax__c>([Select Id,(Select Id, Name, Sales_Tax_Item__r.Tax_Parts__c,Sales_Tax_Item__r.Rate__c  From Applicable_Taxes__r) From Sales_Tax__c  where  Id =: salesTax.Id]);
          Decimal SalesTaxRate =0.00;
          for(Sales_Tax__c  saleTaxRec : salesTaxList){
                for(Applicable_Taxes__c PartTaxItemRec : saleTaxRec.Applicable_Taxes__r){  
                    if(PartTaxItemRec.Sales_Tax_Item__r.Tax_Parts__c){
                    	SalesTaxRate = SalesTaxRate + PartTaxItemRec.Sales_Tax_Item__r.Rate__c;
                    }
                }         
           }
            
           for(CO_Kit_Header__c CoKitHeaderRec : CoKitHeaderList ){
           		List<CO_Line_Item__c> coliList;
            	if(String.isNotBlank(CoKitHeaderRec.Deal__c) && defaultPriceLevel != null && defaultPriceLevel.size() > 0) {
                    coliList = applyPriceLevelUpdate(CoKitHeaderRec,defaultPriceLevel[0],taxExtemptionList,partIdToPartRateMap,PartIdToSalesTaxItemMap, defaultInternalSalesTaxRec);
                } else {
                    coliList = applyPriceLevelUpdate(CoKitHeaderRec,priceLevel,taxExtemptionList,partIdToPartRateMap,PartIdToSalesTaxItemMap, null);
                }
                ColiToUpdate.addAll(coliList); 
            }
              
           // System.assert(false,'000000000'+ColiToUpdate +'\n\n\n'+ CoKitHeaderList);      
            if(ColiToUpdate.size()>0){
                update ColiToUpdate;
                update CoKitHeaderList;
            }  
            return 'Success'; 
        
    }     
    
	public static List<CO_Line_Item__c> applyPriceLevelUpdate(CO_Kit_Header__c CoKitHeaderRec,Price_Level__c PriceLevel, List<Tax_Exemption__c> taxExtemptionList, 
    									Map<Id,Decimal> partIdToPartRateMap, Map<Id,List<Sales_Tax_Item__c>> PartIdToSalesTaxItemMap, Sales_Tax__c defaultInternalSalesTaxRec) {
        Decimal KitHeaderTotal = 0.00;
        Decimal PartRate = 0.00;
        Decimal taxAmount = 0;
        Decimal totalDiscount = 0;
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();        
        //Call For Invdivdual taxes
       // isTaxIncludingPricing = true;
       if(isTaxIncludingPricing) {
                
            for(CO_Line_Item__c  ColiRec : CoKitHeaderRec.CO_Line_Items__r) {
                Decimal TotalTaxApplicable = 0;
                PartRate = (ColiRec.Part__r.Applicable_Tax__r.Rate__c)!=null ? (ColiRec.Part__r.Applicable_Tax__r.Rate__c) : 0;
                partRate = ColiRec.Part__r.Applicable_Tax__r.Rate__c;
                ColiRec.Price__c = 	ColiRec.Actual_Kit_Price__c;
                
                ColiRec.Actual_Retail_Price__c = (ColiRec.Actual_Retail_Price__c != null) ? ColiRec.Actual_Retail_Price__c : 0;
                if(!ColiRec.Fixed_Price__c && ColiRec.Part__c !=null) {
                    if(CoKitHeaderRec.Fixed_Price_Flag__c){
                        TotalTaxApplicable = (ColiRec.Deal__c != null && (ColiRec.Fixed_Price__c || CoKitHeaderRec.Fixed_Price_Flag__c)) ? 0 :
                        				getApplicableTaxes(PartIdToSalesTaxItemMap,ColiRec,taxExtemptionList, defaultInternalSalesTaxRec);
                    	Decimal preTaxPricing = ColiRec.Price__c/ (1 + (TotalTaxApplicable / 100));
                        ColiRec.Price__c = preTaxPricing.setScale(2, RoundingMode.HALF_UP);
                        
            		}else{
            			String pricingField = TaxCalculation.getPricingFieldByPLBaseValueField(priceLevel.Part_Price_Base__c);
            			Decimal preTaxPricing = ColiRec.Price__c;
            			if(!TaxCalculation.COST_FIELDS_SET.contains(pricingField)) {
			            	if(PartRate == null || PartRate == -100) {
			            		PartRate = 0;
			            	}
			                preTaxPricing = ColiRec.Price__c / (1 + (PartRate / 100));
            			}
		                ColiRec.Price__c = preTaxPricing + (preTaxPricing *  priceLevel.Discount_Markup__c / 100);
		                ColiRec.Price__c = ColiRec.Price__c.setScale(2, RoundingMode.HALF_UP);
		                TotalTaxApplicable = getApplicableTaxes(PartIdToSalesTaxItemMap,ColiRec,taxExtemptionList, defaultInternalSalesTaxRec);                    
		            }
		            ColiRec.Tax__c = (ColiRec.Deal__c != null) ? 0 : TotalTaxApplicable;
                    ColiRec.Price_When_Tax_Included__c = ColiRec.Price__c + (((ColiRec.Price__c * ColiRec.Tax__c) / 100).setScale(2, RoundingMode.HALF_UP));
                    KitHeaderTotal += (ColiRec.Qty__c * ColiRec.Price_When_Tax_Included__c);  
                    if(ColiRec.Tax__c != null) {
                        taxAmount +=  (ColiRec.Qty__c * ColiRec.Price__c * ColiRec.Tax__c) / 100;
                    }
		            if(ColiRec.Qty__c > 0) {
	            		totalDiscount += ((ColiRec.Actual_Retail_Price__c * ColiRec.Qty__c) - ((ColiRec.Price__c * ColiRec.Qty__c) * (1 + ColiRec.Tax__c/100))).setScale(2, RoundingMode.HALF_UP);
		            }
               }else if (ColiRec.Fixed_Price__c && ColiRec.Part__c !=null ){
                    TotalTaxApplicable = (ColiRec.Deal__c != null && (ColiRec.Fixed_Price__c || CoKitHeaderRec.Fixed_Price_Flag__c)) ? 0 : 
                    	getApplicableTaxes(PartIdToSalesTaxItemMap,ColiRec,taxExtemptionList, defaultInternalSalesTaxRec);
                    ColiRec.Price_When_Tax_Included__c = ColiRec.Price__c;
                    Decimal preTaxPricing = ColiRec.Price__c/ (1 + (TotalTaxApplicable / 100));
                    ColiRec.Price__c = preTaxPricing.setScale(2, RoundingMode.HALF_UP);
                    ColiRec.Tax__c = (ColiRec.Deal__c != null) ? 0 : TotalTaxApplicable;
                    ColiRec.Price_When_Tax_Included__c = ColiRec.Price__c + (((ColiRec.Price__c * ColiRec.Tax__c) / 100).setScale(2, RoundingMode.HALF_UP));
                    
                    KitHeaderTotal += (ColiRec.Qty__c * ColiRec.Price_When_Tax_Included__c);  
                    if(ColiRec.Tax__c == null) {
                        ColiRec.Tax__c = 0;
                    }
                    taxAmount +=  (ColiRec.Qty__c * ColiRec.Price__c * ColiRec.Tax__c) / 100;
                    if(ColiRec.Qty__c > 0) {
                    totalDiscount += ((ColiRec.Actual_Retail_Price__c * ColiRec.Qty__c) - ((ColiRec.Price__c * ColiRec.Qty__c) * (1 + ColiRec.Tax__c/100))).setScale(2, RoundingMode.HALF_UP);
                    }
               }else if(ColiRec.Fee__c !=null){ // Condition Removed by Pooja 21 Nov. 2016: ColiRec.Fixed_Price__c && 
                    TotalTaxApplicable = (ColiRec.Deal__c != null && (ColiRec.Fixed_Price__c || CoKitHeaderRec.Fixed_Price_Flag__c)) ? 0 : 
                    					getApplicableTaxes(PartIdToSalesTaxItemMap,ColiRec,taxExtemptionList, defaultInternalSalesTaxRec);
                    Decimal feeRate = TotalTaxApplicable;
                    if(!ColiRec.Fixed_Price__c && !CoKitHeaderRec.Fixed_Price_Flag__c) {
                    	feeRate = (ColiRec.Fee__r.Applicable_Tax__r.Rate__c != null) ? ColiRec.Fee__r.Applicable_Tax__r.Rate__c : 0;
                    }
                    Decimal preTaxPricing = ColiRec.Price__c/ (1 + (feeRate / 100));
                    ColiRec.Price__c = preTaxPricing.setScale(2, RoundingMode.HALF_UP);
                    ColiRec.Tax__c = (ColiRec.Deal__c != null) ? 0 : TotalTaxApplicable;
                    
                    ColiRec.Price_When_Tax_Included__c = ColiRec.Price__c + (((ColiRec.Price__c * ColiRec.Tax__c) / 100).setScale(2, RoundingMode.HALF_UP));
                    KitHeaderTotal += (ColiRec.Qty__c * ColiRec.Price_When_Tax_Included__c);  
                    if(ColiRec.Tax__c != null) {
                        taxAmount +=  (ColiRec.Qty__c * ColiRec.Price__c * ColiRec.Tax__c) / 100;
					}
                }
        	}
        } else {
            for(CO_Line_Item__c  ColiRec : CoKitHeaderRec.CO_Line_Items__r ) {
                 Decimal TotalTaxApplicable =0;
                 ColiRec.Price__c = 	ColiRec.Actual_Kit_Price__c;
                 ColiRec.Actual_Retail_Price__c = (ColiRec.Actual_Retail_Price__c != null) ? ColiRec.Actual_Retail_Price__c : 0;
                 
                 if(!ColiRec.Fixed_Price__c && ColiRec.Part__c !=null ){
                    if(CoKitHeaderRec.Fixed_Price_Flag__c){    
                 		TotalTaxApplicable = (ColiRec.Deal__c != null) ? 0 : getApplicableTaxes(PartIdToSalesTaxItemMap,ColiRec,taxExtemptionList, defaultInternalSalesTaxRec);
                        ColiRec.Tax__c = TotalTaxApplicable;
                        KitHeaderTotal += (ColiRec.Qty__c * ColiRec.Price__c);  
                        if(ColiRec.Tax__c != null) {  
                            taxAmount +=  (ColiRec.Qty__c * ColiRec.Price__c * ColiRec.Tax__c) / 100;
                        }
                 	
                 	}else{
                 		ColiRec.Price__c =  ColiRec.Price__c + (ColiRec.Price__c * priceLevel.Discount_Markup__c / 100);
                        TotalTaxApplicable = (ColiRec.Deal__c != null) ? 0 : getApplicableTaxes(PartIdToSalesTaxItemMap,ColiRec,taxExtemptionList, defaultInternalSalesTaxRec);
                        ColiRec.Tax__c = TotalTaxApplicable;
                        KitHeaderTotal += (ColiRec.Qty__c * ColiRec.Price__c); 
                        if(ColiRec.Tax__c != null) {
                            taxAmount +=  (ColiRec.Qty__c * ColiRec.Price__c * ColiRec.Tax__c) / 100;
                        }
                 	}
                 	if(ColiRec.Qty__c > 0) {
                 	totalDiscount += ((ColiRec.Actual_Retail_Price__c * ColiRec.Qty__c) - (ColiRec.Price__c * ColiRec.Qty__c)).setScale(2, RoundingMode.HALF_UP);	 
                 	} 
                 }else if (ColiRec.Fixed_Price__c && ColiRec.Part__c !=null ){
                    TotalTaxApplicable = (ColiRec.Deal__c != null) ? 0 : getApplicableTaxes(PartIdToSalesTaxItemMap,ColiRec,taxExtemptionList, defaultInternalSalesTaxRec);
                    ColiRec.Tax__c = TotalTaxApplicable;
                    KitHeaderTotal += (ColiRec.Qty__c * ColiRec.Price__c);  
                    if(ColiRec.Tax__c != null) {  
                        taxAmount +=  (ColiRec.Qty__c * ColiRec.Price__c * ColiRec.Tax__c) / 100;
                    }
                    if(ColiRec.Qty__c > 0) {
                    totalDiscount += ((ColiRec.Actual_Retail_Price__c * ColiRec.Qty__c) - (ColiRec.Price__c * ColiRec.Qty__c)).setScale(2, RoundingMode.HALF_UP);	
                    }
                 }else if (ColiRec.Fixed_Price__c && ColiRec.Part__c !=null ){
                    TotalTaxApplicable = (ColiRec.Deal__c != null) ? 0 : getApplicableTaxes(PartIdToSalesTaxItemMap,ColiRec,taxExtemptionList, defaultInternalSalesTaxRec);
                    ColiRec.Tax__c = TotalTaxApplicable;
                    KitHeaderTotal += (ColiRec.Qty__c * ColiRec.Price__c);  
                    if(ColiRec.Tax__c != null) {  
                        taxAmount +=  (ColiRec.Qty__c * ColiRec.Price__c * ColiRec.Tax__c) / 100;
                    }
                    if(ColiRec.Qty__c > 0) {
                    totalDiscount += ((ColiRec.Actual_Retail_Price__c * ColiRec.Qty__c) - (ColiRec.Price__c * ColiRec.Qty__c)).setScale(2, RoundingMode.HALF_UP);	
                    }
                 } else if(ColiRec.Fee__c !=null){ // else if Added by Pooja 21 Nov. 2016
                    TotalTaxApplicable = (ColiRec.Deal__c != null) ? 0 : getApplicableTaxes(PartIdToSalesTaxItemMap,ColiRec,taxExtemptionList, defaultInternalSalesTaxRec);
                    ColiRec.Tax__c = TotalTaxApplicable;
                    KitHeaderTotal += (ColiRec.Qty__c * ColiRec.Price__c);  
                    if(ColiRec.Tax__c != null) {  
                        taxAmount +=  (ColiRec.Qty__c * ColiRec.Price__c * ColiRec.Tax__c) / 100;
                	}               
        		} 
        	} 
        }
            
        CoKitHeaderRec.Price__c = KitHeaderTotal.setScale(2, RoundingMode.HALF_UP);
        CoKitHeaderRec.Tax_Amount__c = taxAmount.setScale(2, RoundingMode.HALF_UP);
        CoKitHeaderRec.Total_Discount__c = totalDiscount.setScale(2, RoundingMode.HALF_UP);
        //system.assert(false,CoKitHeaderRec +'/n/n/n/n'+  CoKitHeaderRec.CO_Line_Items__r);
        return  CoKitHeaderRec.CO_Line_Items__r;  
        
     }
     
    public static Decimal getApplicableTaxes(Map<Id,List<Sales_Tax_Item__c>> PartIdToSalesTaxItemMap,CO_Line_Item__c ColiRec, List<Tax_Exemption__c> taxExtemptionList, Sales_Tax__c defaultInternalSalesTaxRec) {
        decimal TotalTaxApplicable = 0;
        List<Sales_Tax_Item__c> SaleTaxItemListForPart = new List<Sales_Tax_Item__c>();
        
        if(ColiRec.Deal__c != null) {
        	TotalTaxApplicable = defaultInternalSalesTaxRec != null ? defaultInternalSalesTaxRec.Rate__c : 0;
        } else {
	        if(ColiRec.part__c !=null){
	            SaleTaxItemListForPart = PartIdToSalesTaxItemMap.get(ColiRec.part__c);
	            if(SaleTaxItemListForPart != null ){
	                   for(Sales_Tax_Item__c SalestaxItemRec :  SaleTaxItemListForPart){
	                        boolean taxExtempt = false;
	                        for(Tax_Exemption__c TaxExptemRec :  taxExtemptionList){  
	                            if(SalestaxItemRec.Id == TaxExptemRec.Sales_Tax_Item__c){
	                                taxExtempt = true;                      
	                            }                           
	                        }
	                        if(taxExtempt == false){  
	                            TotalTaxApplicable += SalestaxItemRec.Rate__c !=null ? SalestaxItemRec.Rate__c : 0;
	                        }
	                   }
	            }
	            
	        }
	        if(ColiRec.fee__c !=null){
	            SaleTaxItemListForPart = PartIdToSalesTaxItemMap.get(ColiRec.fee__c);
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
        }
        
        return TotalTaxApplicable;
    } Analysis: Nidhi*/
    
     /**
     * Name: UpdateKitHeader
     * Desc:  Update Kit Header
     * @param:  (1) CoKitObj - COHeaderWrapper.COKitHeader - Kit Header Record
     * @return: String - Success or Error
    **/  
    public static String UpdateKitHeader(COHeaderWrapper.COKitHeader CoKitObj){
                    Decimal KitHeaderTotal = 0.00;
                    Decimal FixedTotal =0.00;
                    Decimal UnFixedTotal =0.00;
                    Decimal DesiredTotal=0.00;
                    Decimal Adjustment =0.00;
                    Decimal counter = 0; 
                    Decimal TotalTaxAmount = 0;
                    Decimal TotalPrice = 0;
                    Decimal totalDiscount = 0;
                    
                    if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    CO_Kit_Header__c CheckToUpdatedHeader =[select Id, Deal__c, Price__c,Tax_Amount__c from CO_Kit_Header__c where Id =:CoKitObj.Id  ];
                    Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
                    if(CheckToUpdatedHeader.Price__c == null) {
		                CheckToUpdatedHeader.Price__c = 0;
		            }
		            Decimal prePrice = CheckToUpdatedHeader.Price__c.setScale(2, RoundingMode.HALF_UP);
		            Decimal updatedPrice = (CoKitObj.Price).setScale(2, RoundingMode.HALF_UP);
		            if(updatedPrice == prePrice) {
		                return 'Success';
		            }
                    
                    List<COLineItem> ColiList = CoKitObj.COLIList;    
                               
                    for(COLineItem ColirecItem : ColiList ) {
                        if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice))   {
                            UnFixedTotal  += (ColirecItem.Qty *  ColirecItem.Price);
                        } else {
                            FixedTotal +=(ColirecItem.Qty * ColirecItem.Price) ;
                        }
                    }
                    if(CoKitObj.Price < FixedTotal){
                        return 'Kit Header Total cannot Less than Line Item Total';
                    } else if(UnFixedTotal < 0){
                        return 'Incorrect item inserted';
                    } else if(UnFixedTotal == 0){ // Added by Pooja 24 Nov. 2016: (Issue# Edit KH price when no unfixed line item with price greater than 0 is present in a kit -> price is not
                        return 'Kit Header price cannot be updated because no unfixed line item with price greater than 0 is present to adjust the total price';
                    } else {
                        UnFixedTotal = UnFixedTotal==0 ? 1 : UnFixedTotal; 
                        Adjustment = (CoKitObj.Price - FixedTotal) / UnFixedTotal;
                        for(COLineItem ColirecItem : ColiList ) {
                            if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice )){
                                  ColirecItem.Price = (Adjustment * ColirecItem.Price);
                                  if(isTaxIncludingPricing && String.isBlank(ColirecItem.DealId)){
                                       // ColirecItem.Price =   (ColirecItem.Price / (1 + (ColirecItem.Tax / 100))).setScale(2, RoundingMode.HALF_UP);
                                  }
                                  counter = counter + 1;
                            }
                        }
                    }
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                             
                CO_Kit_Header__c CoKitHeaderListToUpdate =new CO_Kit_Header__c();
                List<CO_Line_Item__c> ColiToUpdate  =new List<CO_Line_Item__c>(); 
                
                Decimal unFixedKitHeaderPrice = 0;
                
                for(COLineItem ColirecItem : ColiList ){
                    CO_Line_Item__c ObjeToadd= new CO_Line_Item__c();
                    ObjeToadd.Id=ColirecItem.CoLineItemId;
                    if(ColirecItem.Qty != null ){
		            	ObjeToadd.Qty__c = ColirecItem.Qty;
		            }
                    if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice )) {
                        if(isTaxIncludingPricing && String.isBlank(ColirecItem.DealId)) {
                        	ObjeToadd.Price_When_Tax_Included__c = ColirecItem.Price.setScale(2, RoundingMode.HALF_UP);
                        	TotalPrice += (ObjeToadd.Price_When_Tax_Included__c * ColirecItem.Qty);
                        	unFixedKitHeaderPrice += (ObjeToadd.Price_When_Tax_Included__c * ColirecItem.Qty);
                        } else {
                        	ObjeToadd.Price__c = ColirecItem.Price.setScale(2, RoundingMode.HALF_UP);
                        	TotalPrice += (ColirecItem.price * ColirecItem.Qty);
                        	unFixedKitHeaderPrice += (ColirecItem.price * ColirecItem.Qty);
                        }
                        ColiToUpdate.add(ObjeToadd);
                        TotalTaxAmount +=  (ColirecItem.qty * ((ColirecItem.price * ColirecItem.Tax)/100)); 
                    }
                    else {
                    	TotalPrice += (ColirecItem.Price * ColirecItem.Qty);
                        if(isTaxIncludingPricing && String.isBlank(ColirecItem.DealId)){
                            decimal  Currentprice = (ColirecItem.Price / (1 + (ColirecItem.Tax / 100)));
                            TotalTaxAmount +=  (ColirecItem.qty * ((Currentprice * ColirecItem.Tax)/100)); 
                        }else{
                            TotalTaxAmount +=  (ColirecItem.qty * ((ColirecItem.price * ColirecItem.Tax)/100)); 
                        }
                    }
                    if(String.isNotBlank(ColirecItem.partId) && ColirecItem.Qty > 0) {
                    	totalDiscount += (ColirecItem.ActualRetailPrice * ColirecItem.Qty) - (ColirecItem.price * ColirecItem.Qty);
                    	if(isTaxIncludingPricing) {
                    		totalDiscount -= (ColirecItem.qty * ((ColirecItem.price * ColirecItem.Tax)/100));
                    	}
                    }
                }
                
                //system.assert(false, TotalPrice);
                
                if(ColiToUpdate.size() > 0  &&  counter > 0){  
                        CoKitHeaderListToUpdate.Id= CoKitObj.Id;
                        CoKitHeaderListToUpdate.Price__c = TotalPrice.setScale(2, RoundingMode.HALF_UP);
                        CoKitHeaderListToUpdate.Total_Discount__c = totalDiscount.setScale(2, RoundingMode.HALF_UP);
                        CoKitHeaderListToUpdate.Tax_Amount__c = TotalTaxAmount.setScale(2, RoundingMode.HALF_UP);
                        CoKitHeaderListToUpdate.CO_Fixed_KitHeader__c =true;
                        
                        ColiToUpdate = resolveRoundOffIssue(ColiToUpdate, unFixedKitHeaderPrice, isTaxIncludingPricing);
                        
                        update ColiToUpdate;
                        update CoKitHeaderListToUpdate;
                }
               
                if( counter ==  0){
                     return 'Error';
                }
        
          
        return 'Success';
    }
    
    
     
     /**
     * Name: UpdateKitLineItem
     * Desc:  Update Kit Header    
     * @param:  (1) CoKitObj - COHeaderWrapper.COKitHeader - Kit Header Record
     *          (2) ColiRec -  COLineItem - Line Item Record
     *          (3) coHeaderId- String  - Header Record
     * @return: String - Success or Error  
     **/
    public static String UpdateKitLineItem(COHeaderWrapper.COKitHeader CoKitObj,COLineItem ColiRec,String coHeaderId ){
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
           	if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            
            CO_Line_Item__c  ColiChecktoUpdate  = [select Id, Deal__c, price__c,Tax__c, Qty_Committed__c  from CO_Line_Item__c where Id =:ColiRec.CoLineItemId ];
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
           	// update  By Subhrant  #1917
            if(isTaxIncludingPricing && ColiChecktoUpdate.Deal__c == null){        
                if((ColiChecktoUpdate.Price__c * (1 + ColiChecktoUpdate.Tax__c /100)).setScale(2, RoundingMode.HALF_UP) == ColiRec.price.setScale(2, RoundingMode.HALF_UP)){
                  if(ColiChecktoUpdate.Qty_Committed__c !=  ColiRec.QtyCommitted){
                  		ColiChecktoUpdate.Qty_Committed__c =   ColiRec.QtyCommitted;
		            	 update ColiChecktoUpdate;
		          } 
		         //  system.assert(false,ColiChecktoUpdate);
                    return 'Success'; 
                }
            }else{
                 if( ColiChecktoUpdate.price__c== ColiRec.price ){
	                 if(ColiChecktoUpdate.Qty_Committed__c !=  ColiRec.QtyCommitted){
	                 		 ColiChecktoUpdate.Qty_Committed__c =   ColiRec.QtyCommitted;
			            	 update ColiChecktoUpdate;
			         } 
			        // system.assert(false,ColiChecktoUpdate);
                    return 'Success';
                }
            }
            CO_Header__c Coheader = [Select Part_Price_Base_From_Price_Level__c, Discount_Markup_From_Prive_Level__c 
                                        From CO_Header__c  where Id =: coHeaderId ];
                                        
            List<COLineItem> ColiList = CoKitObj.COLIList;                  
            Decimal KitHeaderTotal = 0.00;
            Decimal FixedTotal =0.00;
            Decimal UnFixedTotal =0.00;
            Decimal DesiredTotal=0.00;
            Decimal Adjustment =0.00;
            Decimal TotalTaxAmount = 0;
            Decimal TotalPrice = 0;
            Decimal totalDiscount = 0;
            
            if(CoKitObj.IsFixedPrice  || CoKitObj.IsFixedKitHeaderCO){    
                        for(COLineItem ColirecItem : ColiList ){
                            if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice || ColirecItem.CoLineItemId== ColiRec.CoLineItemId ))   {
                                UnFixedTotal  += (ColirecItem.Qty * ColirecItem.Price);
                            }
                            else{
                                FixedTotal +=(ColirecItem.Qty * ColirecItem.Price) ;
                            }
                        }
                        if(CoKitObj.Price < FixedTotal){
                            return 'Kit Header Total cannot Less than Line Item Total';
                        }
                        else if(UnFixedTotal < 0){
                            return 'Inccorect item inserted';
                        } else if(UnFixedTotal == 0)	{ //Added by Pooja 23 Nov. 2016 : Issue# [When KH fixed and editing part -> edited but price not adjusted with unfixed KHLI 
                        															//(when none of them, has price > 0) instead it changes fixed KH price ]
                        	return 'Kit Header Line Item price cannot be updated because no unfixed line item with price greater than 0 is present to adjust the total price';
                        }
                        else{
                            UnFixedTotal = UnFixedTotal==0 ? 1 :UnFixedTotal; 
                            Adjustment = (CoKitObj.Price - FixedTotal)/UnFixedTotal;
                            for(COLineItem ColirecItem : ColiList ){
                                if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice || ColirecItem.CoLineItemId== ColiRec.CoLineItemId )){
                                      ColirecItem.Price = (Adjustment *  ColirecItem.Price);
                                      if(isTaxIncludingPricing && String.isBlank(ColirecItem.DealId)){
                                            //ColirecItem.Price =   (ColirecItem.Price / (1 + (ColirecItem.Tax / 100))).setScale(2, RoundingMode.HALF_UP);
                                      }
                                      
                                } else if(ColirecItem.CoLineItemId == ColiRec.CoLineItemId){
                                    ColirecItem.IsFixedPriceForCO =true;
                                }
                            }
                        }
            }
            else{  
                    for(COLineItem ColirecItem : ColiList ){
                            if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice || ColirecItem.CoLineItemId== ColiRec.CoLineItemId )){
                                if(isTaxIncludingPricing && String.isBlank(ColirecItem.DealId)){
                                    //Decimal preTaxPricing = ColirecItem.Price / (1 + (ColirecItem.Tax / 100));
                                    //ColirecItem.Price = preTaxPricing + (preTaxPricing *  Coheader.Discount_Markup_From_Prive_Level__c / 100);
                                    //ColirecItem.Price = preTaxPricing.setScale(2, RoundingMode.HALF_UP);
                                }else{
                                    //ColirecItem.Price =  ColirecItem.ActualKitPrice + (ColirecItem.ActualKitPrice * Coheader.Discount_Markup_From_Prive_Level__c / 100);
                                }
                            }
                            else if(ColirecItem.CoLineItemId== ColiRec.CoLineItemId ){
                                  ColirecItem.IsFixedPriceForCO =true;
                            }
                        }  
            }
        
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        CO_Kit_Header__c CoKitHeaderListToUpdate =new CO_Kit_Header__c();
        List<CO_Line_Item__c> ColiToUpdate  =new List<CO_Line_Item__c>(); 
        
        for(COLineItem ColirecItem : ColiList ){
            CO_Line_Item__c ObjeToadd= new CO_Line_Item__c();
            ObjeToadd.Id= ColirecItem.CoLineItemId;
            ObjeToadd.Deal__c= ColirecItem.DealId;
            	// Added By Subhrant  #1917
            if( ColirecItem.QtyCommitted != null ){
            	ObjeToadd.Qty_Committed__c= ColirecItem.QtyCommitted;
            }
            if(ColirecItem.Qty != null ){
            	ObjeToadd.Qty__c= ColirecItem.Qty;
            }
            
            if(!(ColirecItem.IsFixedPriceForCO ||  ColirecItem.IsFixedPrice )){
                if(isTaxIncludingPricing && String.isBlank(ColirecItem.DealId)) {
                	ObjeToadd.Price_When_Tax_Included__c = ColirecItem.Price.setScale(2, RoundingMode.HALF_UP);
                	TotalPrice += (ObjeToadd.Price_When_Tax_Included__c * ColirecItem.Qty);
                } else {
                	ObjeToadd.Price__c = ColirecItem.Price.setScale(2, RoundingMode.HALF_UP);
                	TotalPrice += (ColirecItem.price * ColirecItem.Qty);
                }
                ObjeToadd.CO_Fixed_KitLineItem__c = ColirecItem.IsFixedPriceForCO;
                TotalTaxAmount +=  (ColirecItem.qty * ((ColirecItem.price * ColirecItem.Tax)/100)); 
            }
            else{
            	TotalPrice += (ColirecItem.Price * ColirecItem.Qty);
                ObjeToadd.CO_Fixed_KitLineItem__c = ColirecItem.IsFixedPriceForCO;  
                if(isTaxIncludingPricing && String.isBlank(ColirecItem.DealId)){
                    ObjeToadd.Price_When_Tax_Included__c = ColirecItem.Price.setScale(2, RoundingMode.HALF_UP);
                    decimal Currentprice = (ColirecItem.Price / (1 + (ColirecItem.Tax / 100)));
                    /*ObjeToadd.Price__c = Currentprice.setScale(2, RoundingMode.HALF_UP);
                    ObjeToadd.CO_Fixed_KitLineItem__c = ColirecItem.IsFixedPriceForCO;    
                    TotalPrice += (ColirecItem.qty *  (ColirecItem.Price / (1 + (ColirecItem.Tax / 100))));*/
                    TotalTaxAmount +=  (ColirecItem.qty * ((Currentprice * ColirecItem.Tax)/100)); 
                }else{ 
                	
                	/*decimal  Currentprice = ColirecItem.Price; */// Added by Pooja 23 Nov. 2016: Issue# (When KH fixed or unfixed and editing part -> part is not edited but marked as fixed or other KHLI 
                																						//price updated)
                    ObjeToadd.Price__c = ColirecItem.Price.setScale(2, RoundingMode.HALF_UP); // Added by Pooja 23 Nov. 2016 (When KH fixed or unfixed and editing part -> part is not edited but marked as fixed or other KHLI 
                																						//price updated)
                    /*TotalPrice += (ColirecItem.price * ColirecItem.Qty);*/
                    TotalTaxAmount +=  (ColirecItem.qty * ((ColirecItem.price * ColirecItem.Tax)/100)); 
                }
            }
            ColiToUpdate.add(ObjeToadd);
            if(String.isNotBlank(ColirecItem.partId) && ColirecItem.Qty > 0) {
            	totalDiscount += (ColirecItem.ActualRetailPrice * ColirecItem.Qty) - (ColirecItem.price * ColirecItem.Qty);
            	if(isTaxIncludingPricing) {
            		totalDiscount -= (ColirecItem.qty * ((ColirecItem.price * ColirecItem.Tax)/100));
            	}
            }
        }   
        CoKitHeaderListToUpdate.Id = CoKitObj.Id;
        CoKitHeaderListToUpdate.Price__c = TotalPrice.setScale(2, RoundingMode.HALF_UP);
        CoKitHeaderListToUpdate.Total_Discount__c = totalDiscount.setScale(2, RoundingMode.HALF_UP);
        CoKitHeaderListToUpdate.Tax_Amount__c = TotalTaxAmount.setScale(2, RoundingMode.HALF_UP);
        
        ColiToUpdate = resolveRoundOffIssue(ColiToUpdate, TotalPrice, isTaxIncludingPricing);
        
        if(ColiToUpdate.size() > 0 ){
         update ColiToUpdate;
         update CoKitHeaderListToUpdate;
        }
    
        return 'Success'; 
    }          
    
    // Round Off Adjusting - Added by TK
    private static List<CO_Line_Item__c> resolveRoundOffIssue(List<CO_Line_Item__c> coLineItemList, Decimal unFixedKitHeaderPrice,
    													Boolean isTaxIncludingPricing) {
        Decimal total = 0;
    	for(CO_Line_Item__c colineItemRec : coLineItemList) {
    		if(!isTaxIncludingPricing || String.isNotBlank(colineItemRec.Deal__c)) {
    			total += (colineItemRec.Price__c * colineItemRec.Qty__c);
    		} else {
    			total += (colineItemRec.Price_When_Tax_Included__c * colineItemRec.Qty__c);
    		}
    	}
    	
    	if(total - unFixedKitHeaderPrice != 0) {
    		if(coLineItemList.size() > 0) {
    			if(!isTaxIncludingPricing || String.isNotBlank(coLineItemList[coLineItemList.size() - 1].Deal__c)) {
	    			coLineItemList[coLineItemList.size() - 1].Price__c -= (total - unFixedKitHeaderPrice);
	    		} else {
	    			coLineItemList[coLineItemList.size() - 1].Price_When_Tax_Included__c -= (total - unFixedKitHeaderPrice);
	    		}
    		}
    	}
    	return coLineItemList;
    }
    
    //Analysis: Nidhi
    public static String calculatePriceForCOKitInsertion(String coKHId, String coHeaderId) {
        String result = COKitPriceCalculation(new Set<Id>{coKHId}, coHeaderId);
        return result; 
    }
    
    public static void changePriceWhenCustomerIsChanged(String coHeaderId) {
    	COKitPriceCalculation(null, coHeaderId);
    }
    
    public static String COKitPriceCalculation(Set<Id> coKHIdSet, String coHeaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        Map<Id, CO_Kit_Header__c> cokhIdToRecMap = getCOKitRecList(coKHIdSet, coHeaderId);

        List<CO_Kit_Header__c> cokhList = new List<CO_Kit_Header__c>();
        for(Id cokhId : cokhIdToRecMap.keySet()) {
 			if(CustomerOrderCtrl_V2.isRefreshCOKit && cokhIdToRecMap.get(cokhId).CO_Invoice_Items__r.size() > 0) {
 				continue;
 			}
 			cokhList.add(cokhIdToRecMap.get(cokhId));
 		}
        
        cokhList = applyPriceLevel(cokhList);
        cokhList = applySalesTax(cokhList, coHeaderId);

        List<Sobject> sobjListToUpdate = new List<Sobject>(); 
        if(cokhList.size() > 0) {
            sobjListToUpdate.addAll((List<Sobject>)cokhList);
            for(CO_Kit_Header__c coKHRec : cokhList) {
                if(coKHRec.CO_Line_Items__r != null) {
                    sobjListToUpdate.addAll((List<Sobject>)coKHRec.CO_Line_Items__r);
                }
            }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        	if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            update sobjListToUpdate;
        }
        return 'Success';
    }
    
    private static Map<Id, CO_Kit_Header__c> getCOKitRecList(Set<Id> coKHIdSet, String coHeaderId) {
    	String queryStr = 'Select Id, Price__c, Fixed_Price_Flag__c, Deal__c, ' +
        			'CO_Header__c, CO_Header__r.Part_Price_Base_From_Price_Level__c, CO_Header__r.Discount_Markup_From_Prive_Level__c, ' +
        			'(Select Id, CO_Invoice_Header__r.Invoice_Status__c from CO_Invoice_Items__r where CO_Invoice_Header__r.Invoice_Status__c = \'Closed\'), ' +
        			'(Select Deal__c, Price__c, Price_When_Tax_Included__c, Fixed_Price__c, Actual_Kit_Price__c, Qty__c, Tax__c, ' +
        			'Part__c, Part__r.Average_Cost__c, Part__r.Last_Cost__c, Part__r.MSRP__c, Part__r.Retail_Price__c, Part__r.Taxable__c, Part__r.Applicable_Tax__r.Rate__c, ' +
        			'Fee__c, Fee__r.Price__c, Fee__r.Taxable__c, Fee__r.Applicable_Tax__r.Rate__c, ' +
        			'Is_Environmental_Fee__c, Actual_Retail_Price__c From CO_Line_Items__r) '+
                    'From CO_Kit_Header__c where CO_Header__c =: coHeaderId';
                    
        queryStr += (coKHIdSet != null && coKHIdSet.size() > 0) ? ' AND Id IN: coKHIdSet' : '';
    	Map<Id, CO_Kit_Header__c> cokhIdToRecMap = new Map<Id, CO_Kit_Header__c>((List<CO_Kit_Header__c>)Database.query(queryStr));
    	return cokhIdToRecMap;
    }
    
    public static List<CO_Kit_Header__c> applyPriceLevel(List<CO_Kit_Header__c> cokhList) {
        
        Boolean isDealMerchKitExists = false;
        for(CO_Kit_Header__c cokhRec : cokhList) {
        	for(CO_Line_Item__c coliRec : cokhRec.CO_Line_Items__r) {
        		if(coliRec.Part__c != null) {
        			coliRec.Actual_Retail_Price__c = (coliRec.Part__r.get(TaxCalculation.PART_PRICE_FIELD_API_NAME) != null) ? 
                									Decimal.valueOf(String.valueOf(coliRec.Part__r.get(TaxCalculation.PART_PRICE_FIELD_API_NAME))) : 0;
        		}
        	}
            if(String.isNotBlank(cokhRec.Deal__c)) {
        		isDealMerchKitExists = true;
        	}
        }
        
        Price_Level__c internalDefaultPL = isDealMerchKitExists ? getInternalPriceLevel() : null;
        
        Decimal discount;
        String partPriceBase; 
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        for(CO_Kit_Header__c cokhRec : cokhList) {
            if(cokhRec.Fixed_Price_Flag__c) {
                continue;
            }
            partPriceBase = String.isNotBlank(cokhRec.Deal__c) ? internalDefaultPL.Part_Price_Base__c : cokhRec.CO_Header__r.Part_Price_Base_From_Price_Level__c;
            discount = String.isNotBlank(cokhRec.Deal__c) ? internalDefaultPL.Discount_Markup__c : cokhRec.CO_Header__r.Discount_Markup_From_Prive_Level__c;
            
            for(CO_Line_Item__c coliRec : cokhRec.CO_Line_Items__r) {
                if(coliRec.Fixed_Price__c) {
                    continue;
                }
                if(coliRec.Part__c != null) {
                	String pricingField = TaxCalculation.getPricingFieldByPLBaseValueField(partPriceBase);
                	coliRec.Retail__c = (coliRec.Part__r.get(pricingField) != null) ? Decimal.valueOf(String.valueOf(coliRec.Part__r.get(pricingField))) : 0;
                	coliRec.Price__c = coliRec.Actual_Kit_Price__c = (coliRec.Retail__c != null) ? coliRec.Retail__c.setScale(2, RoundingMode.HALF_UP) : 0;
                	coliRec.Price_When_Tax_Included__c = isTaxIncludingPricing ? coliRec.Price__c : 0;
                	
                    if(isTaxIncludingPricing && !TaxCalculation.COST_FIELDS_SET.contains(pricingField) && coliRec.Part__r.Applicable_Tax__c != null && 
                    	coliRec.Part__r.Applicable_Tax__r.Rate__c != null) {
                        Decimal appTaxRate = coliRec.Part__r.Applicable_Tax__r.Rate__c;
                        if(appTaxRate == -100 || appTaxRate == null) { // To handle divide by zero error
                            appTaxRate = 0;
                        }
                        coliRec.Price__c = (coliRec.Price__c / (1 + (appTaxRate / 100)));
                    }
                    coliRec.Price__c = (coliRec.Price__c + (coliRec.Price__c * discount / 100));
                    
                } else if(coliRec.Fee__c != null) {
                	/*if(coliRec.Is_Environmental_Fee__c) {
		        		if(isTaxIncludingPricing) {
		        			coliRec.Price__c = (coliRec.Price_When_Tax_Included__c != null) ? coliRec.Price_When_Tax_Included__c : 0;
		        		} else {
		        			coliRec.Price__c = (coliRec.Price__c != null) ? coliRec.Price__c : 0;
		        		}
		        	} else {*/
	        		coliRec.Price__c = coliRec.Fee__r.Price__c != null ? coliRec.Fee__r.Price__c : 0;
	        		coliRec.Price_When_Tax_Included__c = isTaxIncludingPricing ? coliRec.Price__c : 0;
		        	//}
		        	if(isTaxIncludingPricing) {
	                    Decimal appTaxRate = coliRec.Fee__r.Applicable_Tax__r.Rate__c;
	                    if(appTaxRate == -100 || appTaxRate == null) {
	                        appTaxRate = 0;
	                    }
	                    coliRec.Price__c = coliRec.Price__c / (1 + (appTaxRate / 100));
		        	}
                }
                coliRec.Actual_Kit_Price__c = coliRec.Price__c;
            }
        }
        return cokhList;
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
    
    public static List<CO_Kit_Header__c> applySalesTax(List<CO_Kit_Header__c> cokhList, String coHeaderId) {
        Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap = new Map<Id, Set<Id>>();
        if(!cokhList.isEmpty()) {
            coHeaderId = (coHeaderId != null) ? coHeaderId : cokhList[0].CO_Header__c;
            // Get list of Tax Exemptions for given coHeader ids
            coHeaderIdToSalesTaxItemIdsMap = TaxCalculation.getCOHeaderIdToTaxExemptionsIds(new Set<Id>{coHeaderId});
        }
        
        // Entity Tax Rate
        List<Id> salesTaxIdList = new List<Id>();
        for(CO_Kit_Header__c cokhRec : cokhList) {
        	if(String.isNotBlank(cokhRec.Deal__c)) {
        		continue;
        	}
            for(CO_Line_Item__c coliRec : cokhRec.CO_Line_Items__r) {
                if(coliRec.Part__c != null && coliRec.Part__r.Taxable__c && coliRec.Part__r.Applicable_Tax__c != null) {
                    salesTaxIdList.add(coliRec.Part__r.Applicable_Tax__c);
                } else if(coliRec.Fee__c != null && coliRec.Fee__r.Taxable__c && coliRec.Fee__r.Applicable_Tax__c != null) {
                    salesTaxIdList.add(coliRec.Fee__r.Applicable_Tax__c);
                }
            }
        }
        
        Map<Id, List<Applicable_Taxes__c>> salesTaxIdToAppTaxRecordsMap = new Map<Id, List<Applicable_Taxes__c>>();
        Map<Id, Decimal> salesTaxIdToTaxRateMap = new Map<Id, Decimal>();
        if(salesTaxIdList.size() > 0) {
	        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        List<Applicable_Taxes__c> applicableTaxList = [SELECT Sales_Tax_Item__c, Sales_Tax__c, Sales_Tax_Item__r.Tax_Parts__c, 
	                                                            Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c 
	                                                            from Applicable_Taxes__c where Sales_Tax__c IN : salesTaxIdList];
	                                                            
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
        }
                                                       
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        Decimal taxAmount = 0;
        Decimal cokhTotal = 0;
        
        List<Individual_Tax__c> individualTaxToInsert = new List<Individual_Tax__c>();
        for(CO_Kit_Header__c cokhRec : cokhList) {
        	Decimal unfixedKitHeaderTotal = 0;
            for(CO_Line_Item__c coliRec : cokhRec.CO_Line_Items__r) {
            	Decimal rate = 0;
            	Decimal exemptionRate = 0;
            	if(String.isBlank(cokhRec.Deal__c)) {
	                Id salesTaxId;
	                if(coliRec.Part__r.Applicable_Tax__c != null) {
	                    salesTaxId = coliRec.Part__r.Applicable_Tax__c;
	                } else if(coliRec.Fee__r.Applicable_Tax__c != null) {
	                    salesTaxId = coliRec.Fee__r.Applicable_Tax__c;
	                }       
	                coliRec.Applicable_Tax__c = salesTaxId;
	                if(salesTaxIdToAppTaxRecordsMap.containsKey(salesTaxId)) {
	                    for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
	                        if(coHeaderId != null && coHeaderIdToSalesTaxItemIdsMap.get(coHeaderId).contains(appTax.Sales_Tax_Item__c)) {
	                            exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
	                        } else {
	                        	Individual_Tax__c individualTaxRec = new Individual_Tax__c();
		                    	individualTaxRec.CO_Line_Item__c = coliRec.Id;
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
                
                coliRec.Tax__c = rate - exemptionRate;
                coliRec.Price__c = coliRec.Price__c.setScale(2, RoundingMode.HALF_UP);
                if(isTaxIncludingPricing) {
                    if(cokhRec.Fixed_Price_Flag__c || coliRec.Fixed_Price__c) {
                    	if(coliRec.Price_When_Tax_Included__c != null) {
                    		coliRec.Price__c = (coliRec.Price_When_Tax_Included__c / (1 + (coliRec.Tax__c / 100))).setScale(2, RoundingMode.HALF_UP);
                    	} else {
                    		coliRec.Price__c = (coliRec.Price__c / (1 + (coliRec.Tax__c / 100))).setScale(2, RoundingMode.HALF_UP);
                    	}
                    }
                    coliRec.Price_When_Tax_Included__c = (coliRec.Price__c * (1 + (coliRec.Tax__c / 100))).setScale(2, RoundingMode.HALF_UP);
                    cokhTotal += (coliRec.Price_When_Tax_Included__c * coliRec.Qty__c);
                    taxAmount += ((coliRec.Price__c * coliRec.Qty__c * coliRec.Tax__c) / 100);
                    
                    if(!coliRec.Fixed_Price__c) {
	                	unfixedKitHeaderTotal += (coliRec.Price_When_Tax_Included__c * coliRec.Qty__c);
	                	//unfixedLineItemList.add(coliRec);
	                }
	                
                } else {
                    // Deal Kit Header
                    cokhTotal += (coliRec.Price__c * coliRec.Qty__c);
                    taxAmount += ((coliRec.Price__c * coliRec.Qty__c * coliRec.Tax__c) / 100);
                    if(!coliRec.Fixed_Price__c) {
	                	unfixedKitHeaderTotal += (coliRec.Price__c * coliRec.Qty__c);
	                	//unfixedLineItemList.add(coliRec);
	                }
                }
                
                //Analysis: ?? coliRec.Fixed_Price__c = coliRec.Price__c;
            }
        	//resolveRoundOffIssue(cokhRec.CO_Line_Items__r, unfixedKitHeaderTotal, isTaxIncludingPricing);
            cokhRec.Tax_Amount__c = taxAmount.setScale(2, RoundingMode.HALF_UP);
            cokhRec.Price__c = cokhTotal.setScale(2, RoundingMode.HALF_UP);
        }
		
        /** START : Added this to delete existing individual tax record - Handling refresh co pricing and tax from co page */
        if(AccessControl.ifObjectFieldIsAccessible('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Individual_Tax__c> individualListTodelete = new List<Individual_Tax__c>([select Id from Individual_Tax__c where CO_Line_Item__r.CO_Kit_Header__c IN :cokhList]);
        
        if(AccessControl.ifObjectIsDeletable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(individualListTodelete.size() > 0) {
			delete individualListTodelete;        
        }
        /** END : Added this to delete existing individual tax record - Handling refresh co pricing and tax from co page */
                
        if(individualTaxToInsert.size() > 0) {
        	if(AccessControl.ifObjectFieldIsCreateable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        	insert individualTaxToInsert;
        }
        return cokhList;
    }
    
}