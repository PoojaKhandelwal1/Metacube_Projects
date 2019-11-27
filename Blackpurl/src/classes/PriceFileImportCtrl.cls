/**
* Author: Tarun Khandelwal
* Since: Dec 23, 2016
* Name: PriceFileImportCtrl
* Description: Apex class which contains all remoted methods related to Price File Import Page.
**/
global with sharing class PriceFileImportCtrl {
    
    global PriceFileImportCtrl (NewHomePageCtrl controller){}
    public PriceFileImportCtrl() {}
    
    
    @RemoteAction
    global static String getSearchResults(String JSONString) {
        return CustomerOrderCtrl.getSearchResults(JSONString);
    }
    
    @RemoteAction
    global static String importPriceFile(String vendorId, String recordJSON) {
      
        vendorId = BPUtility.getDecodedString(vendorId);
        recordJSON = BPUtility.getDecodedString(recordJSON);
        decimal sucessCount = 0;
        decimal errorCount = 0;
        decimal newRecords =  0;
       
        List<FieldMapping> recordList = (List<FieldMapping>) System.JSON.deserialize(recordJSON, List<FieldMapping>.class);
        String defaultCategoryId = getDefaultCategoryForVendor(vendorId);
        Set<String> partNumberSet = new Set<String>();
        Set<String> duplicateSet = new Set<String>();
        for(FieldMapping record : recordList) {
            partNumberSet.add(record.PartNumber);
        } 
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Part__c> existingPartList = [select Id, Part_Number__c from Part__c where Part_Number__c IN: partNumberSet and Vendor__c =:vendorId];
        List<Account> vendorList = [SELECT Id, Is_Calculate_Part_Retail_Price__c, Retail_Base_Value__c, Retail_Rate__c, Retail_Rounding__c, Retail_Round_To__c FROM Account WHERE Id =:vendorId];
        Map<String, String> partNumberToPartIdMap = new Map<String, String>();
        for(Part__c partRec : existingPartList) {
            partNumberToPartIdMap.put(partRec.Part_Number__c, partRec.Id);
        }
        
        String defaultPartTaxId = Configurations__c.getOrgDefaults().Default_Tax_on_Part__c;
        if(String.isBlank(defaultPartTaxId)){
            if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Sales_Tax__c> defaultSalesTaxList = [select Id from Sales_Tax__c where Default__c = true];
            if(defaultSalesTaxList.size() > 0) {
                defaultPartTaxId = defaultSalesTaxList[0].Id;
            }
        }
        
        List<Part__c> partRecordListToUpsert = new List<Part__c>();
        for(FieldMapping record : recordList) {
            try{
                Part__c partRec = new Part__c();
                partRec.Part_Number__c =record.PartNumber;
                partRec.Description__c = record.Description;
                
                // Start: Superseded Parts Fields: Added By Pooja  16 Oct 2017 
                partRec.Replaced_By_Part__c = record.ReplacedByPart; 
                partRec.Replaces_Part__c = record.ReplacesPart; 
                // End: Superseded Parts Fields: Added By Pooja  16 Oct 2017 
                
                partRec.MSRP__c = decimal.valueof(record.MSRP);
                //partRec.Retail_Price__c = decimal.valueof(record.Retail);
                if(record.EnviroFee != null ){
                    partRec.Enviro_Fee__c = decimal.valueof(record.EnviroFee);  
                }
                
                // Start: Ticket#2370: Added By Pooja 27 Jun 2017
                if(record.SKU != null ){
                    partRec.SKU_Number__c = record.SKU;  
                }
                
                if(record.MfgPart != null ){
                    partRec.Mfg_Part__c = record.MfgPart;  
                }

                 if(record.PackageQty != null && record.PackageQty.length() <= 16 && record.PackageQty.isNumeric() 
               		&& decimal.valueOf(record.PackageQty).scale() == 0 && decimal.valueof(record.PackageQty) > 1){
                    partRec.Packaged_Part__c = true; 
                    partRec.Package_Unit__c = 'PKG'; 
                    partRec.Package_Qty__c = decimal.valueof(record.PackageQty);  
                    
                    //partRec.MSRP__c = partRec.MSRP__c/partRec.Package_Qty__c;
                    //partRec.Package_Cost__c = decimal.valueof(record.ItemCost);
                    //partRec.Last_Cost__c = partRec.Package_Cost__c/partRec.Package_Qty__c;
                    //partRec.Retail_Price__c = decimal.valueof(record.Retail)/partRec.Package_Qty__c;
                    
                    // Start: Package Part Price and Cost Calculations: Added By Pooja  16 Oct 2017
                    if(!record.AllPricesArePerItem) 	{
                    	partRec.MSRP__c = partRec.MSRP__c/partRec.Package_Qty__c;
                    	partRec.Retail_Price__c = decimal.valueof(record.Retail)/partRec.Package_Qty__c;
                    }else	{
                    	partRec.Retail_Price__c = decimal.valueof(record.Retail);
                    }
                    
                   
                    if(!record.AllCostsArePerItem) 	{
                    	partRec.Package_Cost__c = decimal.valueof(record.ItemCost);
                    	partRec.Last_Cost__c = partRec.Package_Cost__c/partRec.Package_Qty__c;
                    }else	{
                    	partRec.Last_Cost__c = decimal.valueof(record.ItemCost);
                    	partRec.Package_Cost__c = partRec.Last_Cost__c * partRec.Package_Qty__c;
                    }
                    // End: Package Part Price and Cost Calculations: Added By Pooja  16 Oct 2017
                }else	{
                	partRec.Packaged_Part__c = false; 
                    partRec.Package_Unit__c = ''; 
                    partRec.Package_Qty__c = 0;  
                    partRec.Package_Cost__c = 0;
                	partRec.Last_Cost__c = decimal.valueof(record.ItemCost);
                    
                    partRec.Retail_Price__c = decimal.valueof(record.Retail);
                }
                // End: Ticket#2370: Added By Pooja 27 Jun 2017
                
                //partRec.Last_Cost__c = decimal.valueof(record.ItemCost); // Ticket#2370: Commented By Pooja 27 Jun 2017
                partRec.Category__c = defaultCategoryId;
                partRec.Vendor__c = vendorId;
                if(partNumberToPartIdMap.containsKey(record.PartNumber)) {
                    if(!duplicateSet.contains(record.PartNumber)){
                        partRec.Id = partNumberToPartIdMap.get(record.PartNumber);
                        duplicateSet.add(record.PartNumber);
                    }
                }else{
                    partRec.Applicable_Tax__c = defaultPartTaxId;
                    partRec.Taxable__c = true;
                }
                
                if(vendorList[0].Is_Calculate_Part_Retail_Price__c){
                	ViewPartCtrl.calculatePartRetailPriceOnUpsert(partRec, vendorList[0]);  
                }
                
                partRecordListToUpsert.add(partRec);
            }catch(exception ex){
                errorCount++;
            }
        }
                
        if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        Database.UpsertResult [] cr  = Database.upsert(partRecordListToUpsert ,false);
        Set<Id> ImportedPartIdSet = new Set<Id>();//(new Map<Id,SObject>(partRecordListToUpsert)).keySet();
        for(Database.UpsertResult Result : cr){
             if (result.isSuccess()) {
                    if(result.isCreated()){
                        newRecords++;
                    }
                    sucesscount++;
                    ImportedPartIdSet.add(result.Id);
             }else{
                errorcount++;   
             }
        }
        String SuccessCounter = String.valueOf(sucesscount);
        String ErrorCounter = String.valueOf(errorcount);
        String newRecordsCounter = String.valueOf(newRecords);
        return BPUtility.getEncodedString(System.JSON.serialize( new UploadResult(SuccessCounter,ErrorCounter,newRecordsCounter, ImportedPartIdSet)));
    }
    
    @RemoteAction
    global static void importSupersessionPart(String ImportedPartIdList) {
    	ImportedPartIdList = BPUtility.getDecodedString(ImportedPartIdList);
    	List<String> ImportedPartIds = (List<String>)System.JSON.deserialize(ImportedPartIdList, List<String>.class);
    	
    	if(ImportedPartIds.size() > 0) {
    		ImportSupersessionPart_Batch batchObj = new ImportSupersessionPart_Batch(ImportedPartIds, 200);
    	} 
    	//invokeBatch(ImportedPartIds);
    }
    
    @RemoteAction
    global static void createActivityHistory(String vendorId) {
      vendorId = BPUtility.getDecodedString(vendorId);
      
      // Create Activity History in case of Insert.
      if(!Test.isRunningTest()) {
      ActivityHistory.createActivityHistory('Price File Import', 'Vendor', vendorId, 'Vendor', vendorId, null);
      }
    }
    
    private static String getDefaultCategoryForVendor(String vendorId) {
        String defaultCategoryId;
        
        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Category__c> categoryList = new List<Category__c>();
        if(String.isBlank(vendorId)) {
            categoryList = [select Id, Name from Category__c WHERE default__c = true and Type__c = 'Part'];
            if(categoryList.size() > 0) {
                defaultCategoryId = categoryList[0].Id;
            }
        } else {
            List<Account> vendorList = [select Id, Part_Category_Default__c from Account where Id = :vendorId AND Is_Vendor__c = true];
            if(vendorList.size() > 0 && vendorList[0].Part_Category_Default__c != null) {
                defaultCategoryId = vendorList[0].Part_Category_Default__c;
            } else {
                categoryList = [select Id, Name from Category__c WHERE default__c = true and Type__c = 'Part'];
                if(categoryList.size() > 0) {
                    defaultCategoryId = categoryList[0].Id;
                }
            }
        } 
        return defaultCategoryId;
    }
    
    public class FieldMapping {
        
        public String PartNumber;
        public String Description;
        public String MSRP;
        public String Retail;
        public String EnviroFee;
        public String ItemCost;
        
        // Start: Ticket#2370: Added By Pooja 27 Jun 2017
        public String SKU;
        public String MfgPart;
        public String PackageQty;
        // End: Ticket#2370: Added By Pooja 27 Jun 2017
       
        //Start: Superseded Parts Fields: Added By Pooja  16 Oct 2017 
        public String ReplacedByPart;
        public String ReplacesPart; 
        //End: Superseded Parts Fields: Added By Pooja  16 Oct 2017 
        
        // Start: Package Part Flag: Added By Pooja  16 Oct 2017 
        public Boolean AllPricesArePerItem;
        public Boolean AllCostsArePerItem;
        // End: Package Part Flag: Added By Pooja  16 Oct 2017
        
        public FieldMapping() {
            
        }
    }
    public class UploadResult{
        public String SucessCount;
        public String ErrorCount;
        public string NewRecords;
        public Set<Id> ImportedPartIdSet;
        public UploadResult( String sucessCount,String errorCount,String newRecords, Set<Id> ImportedPartIdSet) {
            this.SucessCount = sucessCount;
            this.ErrorCount = errorCount;
            this.newRecords = newRecords;
            this.ImportedPartIdSet = ImportedPartIdSet;
        }
    }
}