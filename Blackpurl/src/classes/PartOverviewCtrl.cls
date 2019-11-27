/**
 * Author: Tarun Khandelwal
 * Since: June 05, 2015
 * Name: PartOverviewCtrl
 * Description: Controller Class of Part Detail Page.
**/
global with sharing class PartOverviewCtrl {

	global PartOverviewCtrl (NewHomePageCtrl controller){}
    public PartOverviewCtrl() {}
    
	/**
     * Name: getPartDetail
     * Desc: To get Part Details on Edit Part Pop Up window
     * @param: (1) partRecordId - String - Id of Part 
     * @return: String - JSON string of Part info. 
    **/
    @RemoteAction
    global static String getPartDetail(String partRecordId) {
    	partRecordId = BPUtility.getDecodedString(partRecordId);
        List<Part__c> partList = SOQLUtil.getPartDetailRecordsByFieldName('Id', partRecordId);
        List<PartDetail> partObjList = new List<PartDetail>();
        for(Part__c partRec : partList) {
            partObjList.add(new PartDetail(partRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(partObjList));
    }
	
	@RemoteAction
    global static String getActiveFeeList() {
    	return BPUtility.getEncodedString(ViewFeeCtrl.getActiveFeeList('Env Fee'));
    }
    
    @RemoteAction
    global static String getActiveTagList() {
    	return BPUtility.getEncodedString(System.JSON.serialize(TagManagementCtrl.getActiveTagList()));
    }
    
	/**
     * Name: getApplicableTaxList
     * Desc: To get Part Details on Edit Part Pop Up window
     * @param: (1) partRecordId - String - Id of Part 
     * @return: String - JSON string of Part info. 
    **/
    @RemoteAction
    global static String getApplicableTaxList() {
        String defaultPartTaxId = Configurations__c.getOrgDefaults().Default_Tax_on_Part__c;
        return BPUtility.getEncodedString(TaxUtility.getApplicableList(defaultPartTaxId));
    }
    
    @RemoteAction
    global static String getDefaultEnvFeeList() {
        String defaultEnvFeeId = Configurations__c.getOrgDefaults().Default_Environmental_Fee__c;
        List<Fee__c> feeList = SOQLUtil.getFeeByFieldName(new Map<String, String>{'Id' => defaultEnvFeeId});
        String jsonString = '{}'; 
		if(feeList.size() > 0) {
			JSONGenerator gen = JSON.createGenerator(true);
	        gen.writeStartObject();
	        gen.writeStringField('DefaultEnvFeeId', feeList[0].Id); 
	        gen.writeStringField('DefaultEnvFeeName', feeList[0].Code__c + ((feeList[0].Description__c != null) ? (' - ' + feeList[0].Description__c) : ''));
	        gen.writeEndObject();
	        jsonString = gen.getAsString();
		}
    	return BPUtility.getEncodedString(jsonString);
    }
    
	/**
     * Name: savePart
     * Desc: To save Part Record in database 
     * @param: (1) partJSONString - String - JSON String of Part Record
     * @return: String - Id of Inserted or updated part Record. 
    **/
    @RemoteAction
    global static String savePart(String partJSONString) {
    	partJSONString = BPUtility.getDecodedString(partJSONString);
    	if(AccessControl.ifObjectFieldIsCreateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
		if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<PartDetail> partObjList = PartDetail.parse(partJSONString);
        
        Boolean isInsert = true;
        List<Part__c> partListToInsert = new List<Part__c>();
        Part__c partRec;
        for(PartDetail partObj : partObjList) {
            partRec = new Part__c();
            partRec.Part_Number__c = partObj.PartNumber;
            partRec.Description__c = partObj.Description;
            partRec.Vendor__c = partObj.VendorId;
            partRec.Category__c = partObj.CategoryId;
            partRec.Packaged_Part__c = partObj.IsPackagedPart;
            if(!partRec.Packaged_Part__c){
            	partRec.Package_Qty__c = 0;
            	partRec.Package_Unit__c = null;
            	partRec.Package_Cost__c = 0;
            } else {
	            partRec.Package_Qty__c = partObj.PackagedQty;
	            partRec.Package_Unit__c = partObj.PackagedUnit;
            	partRec.Package_Cost__c = partObj.PackagedCost;
            }
            partRec.Qty_In_Stock__c = partObj.InStockQty;
            partRec.Taxable__c = partObj.IsTaxable;
            if(partObj.IsTaxable) {
            	partRec.Applicable_Tax__c = partObj.ApplicableTaxId;
            } else {
            	partRec.Applicable_Tax__c = null;
            }
            partRec.Location__c = partObj.Location;
            partRec.Last_Cost__c = partObj.Cost;
            partRec.Package_Cost__c = partObj.PackagedCost;
            partRec.MSRP__c = partObj.MSRP;
            partRec.Retail_Price__c = partObj.Retail;
            partRec.Enviro_Fee__c = partObj.EnviroFee;
            if(partRec.Enviro_Fee__c != null && partRec.Enviro_Fee__c > 0) {
            	partRec.Enviro_Fee_Code__c = (String.isNotBlank(partObj.EnvFeeId)) ? partObj.EnvFeeId
            												: Configurations__c.getOrgDefaults().Default_Environmental_Fee__c;
            } else {
            	partRec.Enviro_Fee_Code__c = null;
            }
            
            partRec.Auto_reorder_Min__c = partObj.AutoReorderAt;
            partRec.Auto_reorder_Max__c = partObj.AutoReorderTo;
            partRec.Is_OrderLot__c = partObj.IsOrderLot;
            if(partRec.Is_OrderLot__c) {
            	partRec.Order_Lots__c = partObj.OrderLots;
            } else {
            	partRec.Order_Lots__c = 1; 
            }
            
            if(partObj.Id != null) {
            	isInsert = false;
                partRec.Id = partObj.Id;
            } else {
            	partRec.Average_Cost__c = partObj.Cost;
            }
            if(partRec.Superseded_By__c != null && partRec.Id == partRec.Superseded_By__c) {
            	return BPUtility.getEncodedString('1001');
            }
            
            partRec.Mfg_Part__c = partObj.MfgPart; // Added by richa 25/11/2016
            partRec.SKU_Number__c = partObj.SKUNumber; // Added by richa 25/11/2016
            partRec.Non_Inventory_Part__c = partObj.IsNonInventoryPart != null ? partObj.IsNonInventoryPart : false; // Added by richa 25/11/2016
			partRec.Active__c = partObj.Active != null ? partObj.Active : true; // Added by richa 04/02/2017
            if(partObj.AssignedTags.size() > 0) {
            	List<String> tagStrListForFields = TagUtil.convertTagListIntoTagString(partObj.AssignedTags);
            	if(tagStrListForFields.size() == 2) {
            		partRec.Assigned_Tag_1__c = tagStrListForFields[0];
            		partRec.Assigned_Tag_2__c = tagStrListForFields[1];
            	}
            } else {
            	partRec.Assigned_Tag_1__c = partRec.Assigned_Tag_2__c = '';
            }
            partRec.Part_Type__c = String.isNotBlank(partObj.PartType) ? partObj.PartType : 'Part';
            partListToInsert.add(partRec);
        } 
        String upsertedPartRecordId = ''; 
        if(partListToInsert.size() > 0) {
            try {
            	PartTriggerHelper.isPartFromImport = false;
            	upsert partListToInsert;
            	if(isInsert && !partRec.Non_Inventory_Part__c) { // && !partRec.Non_Inventory_Part__c Added by richa 25/11/2016
            		FIFOTransaction.createFIFOBucketForPartCreate(partListToInsert);
            	}
            } catch(Exception e) {
            	return BPUtility.getEncodedString('1002');
            }
            upsertedPartRecordId = partListToInsert[0].Id;
        }
        return BPUtility.getEncodedString(upsertedPartRecordId);
    }
    
    /**
     * Name: getJSONForFilteredUnitMakes
     * Desc: Method used to return JSON String in case of filtereing
     * @param: (1) searchingString - String - Seraching Keywork
     *		   (2) fieldName - Stirng - Field Name for which filter is applied  
     		   (3) isInactiveIncluded - Boolean - true if Inactive records are included 
     * @return: String - JSON Fromatted String of filtered Unit Makes records
    **/
    /*@RemoteAction
    global static String getJSONForSuggestion(String searchingString, String ObjectName) {
		searchingString = String.escapeSingleQuotes(searchingString);
		
		String fieldAPIName = Constants.UNIT_MAKE_LIST_JSON_TO_FIELDS_MAPPING.get(fieldName);
		List<Unit_Make__c> searchedUnitMakes = SOQLUtil.getFilteredUnitMakes(searchingString, fieldAPIName, isInactiveIncluded);
    	return Utility.createJSONForFilteredResult(searchedUnitMakes, fieldAPIName);
    }*/
    
    /**
     * Name: getJSONForFilteredUnitMakes
     * Desc: Method used to return JSON String in case of filtereing
     * @param: (1) searchingString - String - Seraching Keywork
     *		   (2) fieldName - Stirng - Field Name for which filter is applied  
     		   (3) isInactiveIncluded - Boolean - true if Inactive records are included 
     * @return: String - JSON Fromatted String of filtered Unit Makes records
    **/
    @RemoteAction
    global static String getDefaultCategory(String vendorId) {
    	vendorId = BPUtility.getDecodedString(vendorId);
    	vendorId = BPUtility.escapeSingleQuotes(vendorId);
    	if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		List<Category__c> categoryList = new List<Category__c>();
		Map<String, Category__c> categoryMap = new Map<String, Category__c>();
		List<Account> vendorList = new List<Account>();
		if(vendorId == '') {
			categoryList = [select Id, Name from Category__c WHERE default__c = true and Type__c = 'Part' AND Active__c = true];
		} else {
			vendorList = [select Id, Merchandise_Purchases__c, Part_Purchases__c, 
										Part_Category_Default__c, Part_Category_Default__r.Name, 
										Merchandise_Category_Default__c, Merchandise_Category_Default__r.Name 
										from Account where Id = :vendorId AND Is_Vendor__c = true
										AND (Part_Category_Default__r.Active__c = true OR Merchandise_Category_Default__r.Active__c = true)];
			if(vendorList.size() > 0) {
				if(vendorList[0].Part_Category_Default__c != null) {
					Category__c partCategoryRec = new Category__c (Name = vendorList[0].Part_Category_Default__r.Name, Id = vendorList[0].Part_Category_Default__c);
					categoryMap.put('Part', partCategoryRec);
				}
				if(vendorList[0].Merchandise_Category_Default__c != null) {
					Category__c merchCategoryRec = new Category__c (Name = vendorList[0].Merchandise_Category_Default__r.Name, Id = vendorList[0].Merchandise_Category_Default__c);
					categoryMap.put('Merchandise', merchCategoryRec);
				}
			} else {
				categoryList = [select Id, Name from Category__c WHERE default__c = true and Type__c = 'Part' AND Active__c = true];
			}
		} 
		String jsonString = '{}'; 
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		if(categoryList.size() > 0) {
	        gen.writeStringField('DefaultPartCategoryId', categoryList[0].Id); 
	        gen.writeStringField('DefaultPartCategoryName', categoryList[0].Name);
	        gen.writeStringField('DefaultMerchandiseCategoryId', categoryList[0].Id); 
	        gen.writeStringField('DefaultMerchandiseCategoryName', categoryList[0].Name);
		} else {
			if(categoryMap.containsKey('Part')) {
				gen.writeStringField('DefaultPartCategoryId', categoryMap.get('Part').Id); 
	        	gen.writeStringField('DefaultPartCategoryName', categoryMap.get('Part').Name);
			}
			if(categoryMap.containsKey('Merchandise')) {
				gen.writeStringField('DefaultMerchandiseCategoryId', categoryMap.get('Merchandise').Id); 
	        	gen.writeStringField('DefaultMerchandiseCategoryName', categoryMap.get('Merchandise').Name);
			}
		}
		if(vendorList.size() > 0) {
			gen.writeBooleanField('IsMerchandisePurchases', vendorList[0].Merchandise_Purchases__c ); 
	    	gen.writeBooleanField('IsPartPurchases', vendorList[0].Part_Purchases__c );
		}
		gen.writeEndObject();
		jsonString = gen.getAsString();
    	return BPUtility.getEncodedString(jsonString);
    }
    
    @RemoteAction   
	global static String isNonInventoryFieldEditable(String partId) {
		partId = BPUtility.getDecodedString(partId);
		if(String.isBlank(partId)) {
			return BPUtility.getEncodedString('{"isAllowed" : true}'); 
		}
		
		// Change Query into one.
		List<Part__c> partList = [Select Qty_In_Stock__c,  
										(Select Id from Kit_Header_Line_Items__r where Kit_Header__r.Active__c = true),
										(Select Id from CO_Line_Items__r where CO_Header__r.Order_status__c = 'Open'),
										(Select Id from Vendor_Order_Line_Items__r where Is_Received__c = false AND Vendor_Order_Header__r.Status__c != 'Received'),
										(Select Id from Vendor_Receiving_Group_Parts__r where (Vendor_Receiving_Header__r.Status__c NOT IN ('Received', 'Invoiced') AND Vendor_Receiving_Header__r.In_Progress_VI__r.Status__c != 'Invoiced'))
									from Part__c where Id =: partId];
		
		if(partList.size() > 0 && (partList[0].Qty_In_Stock__c > 0 || partList[0].Kit_Header_Line_Items__r.size() > 0 || partList[0].CO_Line_Items__r.size() > 0 || 
									partList[0].Vendor_Order_Line_Items__r.size() > 0 || partList[0].Vendor_Receiving_Group_Parts__r.size() > 0)) {
			return BPUtility.getEncodedString('{"isAllowed" : false}');
		}
		return BPUtility.getEncodedString('{"isAllowed" : true}');  
	}
}