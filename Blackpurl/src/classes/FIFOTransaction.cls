public with sharing class FIFOTransaction {
    
    public static Map<String, String> sourceIdToApi = new Map<String, String> { 'Part Created' => 'Part__r.Name',
                                                                                  'Vendor Invoice' => 'Vendor_Invoicing_Header__r.Name',
                                                                                  'Vendor Receving' => 'Vendor_Receiving_Header__r.Name',
                                                                                  'Stock Count' => 'Stock_Count__r.Name'
                                                                                };  
                                                                                
        public static Map<String, String> sourceRefrenceToApi = new Map<String, String> { 'Part Created' => 'Part__r.Name',
                                                                                  'Vendor Invoice' => 'Vendor_Invoicing_Header__r.Name',
                                                                                  'Vendor Receving' => 'Vendor_Receiving_Header__r.Name',
                                                                                  'Stock Count' => ''
                                                                                };                                                                              
                                                                                    
        public static Map<String, String> sourceLookupToApi = new Map<String, String> { 'Part Created' => null,
                                                                                  'Vendor Invoice' => 'Vendor_Invoicing_Header__c',
                                                                                  'Vendor Receving' => 'Vendor_Receiving_Header__c',
                                                                                  'Stock Count' => 'Stock_Count__c'
                                                                                };   
        
        public static Set<String> sourceNamesForAdjusmentSet = new Set<String> {'Count Adjust', 'Part Created' ,'Cost Adjust', 'Stock Count'};
        public static Set<String> referenceNamesForAdjusmentSet = new Set<String> {'Count Adjustment', 'Cost Adjustment'};                                                                           
    /*
     * create bucket for Part 
     */                                                                                                                                                             
    public static void createFIFOBucketForPart(List<Part__c> partRecList, String source) {  
        if(AccessControl.ifObjectFieldIsCreateable('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        List<Part_FIFO_Bucket__c> bucketList = new List<Part_FIFO_Bucket__c>();
        for(Part__c partRec : partRecList){
            if(partRec.Qty_In_Stock__c != 0){ 
                Part_FIFO_Bucket__c bucket = new Part_FIFO_Bucket__c();
                bucket.Source_Name__c = source;
                //bucket.Reference__c = '';
                bucket.Qty_In__c = partRec.Qty_In_Stock__c;
                bucket.Cost__c =  partRec.Last_Cost__c;
                bucket.VRCost__c = partRec.Last_Cost__c;
                bucket.Is_FIFO_Bucket__c = true;
                bucket.Part__c = partRec.Id;
                bucketList.add(bucket);
            }
        }
        if(bucketList.size() > 0){
            insert bucketList;
        }
    }
    
    /*
     * create bucket for Part create from popup
     */     
    public static void createFIFOBucketForPartCreate(List<Part__c> partRecList){
        createFIFOBucketForPart(partRecList , 'Part Created');
    }
    
    /*
     * create bucket for Part import
     */     
    public static void createFIFOBucketForPartImport(List<Part__c> partRecList){
        createFIFOBucketForPart(partRecList , 'Part Imported');
    }
    
    /*
     * create bucket for on vendor receiving
     */
    public static void createFIFOBucketForVendorReceiving(Map<Id, Part__c> updateOnOrderIdtoPartMap, String vrHeaderId) {
        if(AccessControl.ifObjectFieldIsCreateable('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        List<Part_FIFO_Bucket__c> bucketList = new List<Part_FIFO_Bucket__c>();
        for(Part__c partRec : updateOnOrderIdtoPartMap.values()) {
            Part_FIFO_Bucket__c bucket = new Part_FIFO_Bucket__c();
            bucket.Source_Name__c = 'Vendor Receiving';
            bucket.Qty_In__c = partRec.Qty_In_Stock__c;
            bucket.Cost__c =  partRec.Last_Cost__c;
            bucket.Is_FIFO_Bucket__c = true;
            bucket.Vendor_Receiving_Header__c = vrHeaderId;
            bucket.Part__c = partRec.Id;
            bucket.VRCost__c = partRec.Last_Cost__c;
            bucketList.add(bucket);
        }
        if(bucketList.size() > 0) {
            insert bucketList;
        }
        if(updateOnOrderIdtoPartMap.size() > 0) {
            updatePartRecord(updateOnOrderIdtoPartMap);
        }
    }
    
    public static void updatePartRecord(Map<Id, Part__c> partIdToPartRecMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<Part_FIFO_Bucket__c> fifoBucketList = [select Remaining_Qty__c, Part__c, Total__c
                                                    from Part_FIFO_Bucket__c
                                                    where Part__c =: partIdToPartRecMap.keyset() and Is_FIFO_Bucket__c = true AND Remaining_Qty__c > 0];
        
        Decimal totalCost;
        Decimal totalRemainingQty; 
        List<Part__c> partListToUpdate = new List<Part__c>();
        for(String partId : partIdToPartRecMap.keyset()) {
            totalCost = 0;
            totalRemainingQty = 0;
            Part__c partRec = partIdToPartRecMap.get(partId); 
            partRec.Qty_In_Stock__c = 0;
            for(Part_FIFO_Bucket__c bucket : fifoBucketList) {
                if(bucket.Part__c == partId) {
                    partRec.Qty_In_Stock__c += (bucket.Remaining_Qty__c != null ? bucket.Remaining_Qty__c : 0);
                    totalCost += bucket.Total__c;
                    totalRemainingQty += (bucket.Remaining_Qty__c != null ? bucket.Remaining_Qty__c : 0);
                }
            }
            
            partRec.Qty_On_Order__c = partIdToPartRecMap.get(PartRec.Id).Qty_On_Order__c;
            partRec.Last_Stocked__c = system.now();
            partRec.Average_Cost__c = ((totalRemainingQty != 0) ? (totalCost/totalRemainingQty) : 0);
            partListToUpdate.add(partRec);
        }
        if(partListToUpdate.size() > 0) {
            update partListToUpdate;            
        }
    }
    
    /*
     * create bucket for on vendor Invoicing
     */ 
    // change for Profitability reports 
    public static void updateFIFOBucketForVendorInvoicing(Map<Id, List<Part__c>> vendorReceivingHeaderToPartMap, String viHeaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<Sobject> partFifoObjects =new List<Sobject>();	
        map<Id,Decimal> FIFOIdToCostMap = new map<Id,Decimal>();
        List<Part_FIFO_Bucket__c> bucketsList = [select Id, Part__r.Id, Part__c, Cost__c, Vendor_Receiving_Header__c,
        										(select Id,Cost__c from Part_FIFO_Bucket_Activity_Line_Items__r) from Part_FIFO_Bucket__c
                                                 where Vendor_Receiving_Header__c IN :vendorReceivingHeaderToPartMap.keySet()];
                                                                                       
        Set<String> partIdSet = new Set<String>(); 
        for(Part_FIFO_Bucket__c bucket : bucketsList){ 
            for(Part__c partRec : vendorReceivingHeaderToPartMap.get(bucket.Vendor_Receiving_Header__c)){
                if(partRec.Id == bucket.Part__c){
                    partIdSet.add(bucket.Part__c);
                    bucket.Source_Name__c = 'Vendor Invoice';
                    bucket.Cost__c =  partRec.Last_Cost__c;
                    bucket.Vendor_Invoicing_Header__c = viHeaderId;
                    for(Part_FIFO_Bucket_Activity_Line_Item__c PartFifoLineItemRec :  bucket.Part_FIFO_Bucket_Activity_Line_Items__r){
                    	partFifoObjects.add(new Part_FIFO_Bucket_Activity_Line_Item__c(Id =PartFifoLineItemRec.Id, Cost__c = partRec.Last_Cost__c));
                    	FIFOIdToCostMap.put(PartFifoLineItemRec.Id, bucket.Cost__c);
                 	}
                 	partFifoObjects.add(bucket);
                    //bucket.Vendor_Receiving_Header__c = null;
                }
            }
        }
        
        List<Coli_Fifo_Line_Item_Junction__c> ColiFifoItemListToUpdate = updateInvoiceParts(FIFOIdToCostMap);
        // addd created and updates	
        if(partFifoObjects.size() > 0){
        	partFifoObjects.sort();
            update partFifoObjects;
        }
        if( ColiFifoItemListToUpdate.size() > 0){
        	update ColiFifoItemListToUpdate;
        }
        
        set<String> coliFifoSet = new set<String>();
        for(Coli_Fifo_Line_Item_Junction__c   ColififoRec : ColiFifoItemListToUpdate){
			coliFifoSet.add(ColififoRec.Id);
		}
		if( coliFifoSet.size() > 0 && !Test.isRunningTest()){
			ajdustPartCost(coliFifoSet);
		}
        
        if(partIdSet.size() > 0){
            updatePartInStock(new List<String>(partIdSet));
        }
        
    }
    // Profitability chnages
    @future
	public static void ajdustPartCost(set<String> coliFifoSet ){
		
		List<Coli_Fifo_Line_Item_Junction__c> coliFifoListToCalculateCost =	[select Id,Qty__c,Avg_Cost__c,Adjusted_Cost_Fifo__c,
																			Part_FIFO_Bucket_Activity_Line_Item__r.CO_Invoice_Header__c,Last_Cost__c,
																			Part_FIFO_Bucket_Activity_Line_Item__r.CO_Invoice_Header__r.Invoice_Cost__c	 from 
																			Coli_Fifo_Line_Item_Junction__c where Id IN : coliFifoSet];
		
		decimal OrginalCost= 0;
		List<CO_Invoice_Header__c>  CoInvoiceHeaderToupdate = new List<CO_Invoice_Header__c>();
		map<Id,decimal> CoInvoiceHeaderToCost = new map<Id,decimal>();
		for(Coli_Fifo_Line_Item_Junction__c ColififoItem : coliFifoListToCalculateCost){
			if(CoInvoiceHeaderToCost.containskey(ColififoItem.Part_FIFO_Bucket_Activity_Line_Item__r.CO_Invoice_Header__c)){
					if(ColififoItem.Qty__c !=null){
						OrginalCost = CoInvoiceHeaderToCost.get(ColififoItem.Part_FIFO_Bucket_Activity_Line_Item__r.CO_Invoice_Header__c);
						OrginalCost +=   (ColififoItem.Adjusted_Cost_Fifo__c -   (ColififoItem.Last_Cost__c !=null ? ColififoItem.Last_Cost__c : ColififoItem.Avg_Cost__c));
						ColififoItem.Last_Cost__c  = (ColififoItem.Adjusted_Cost_Fifo__c != null ? ColififoItem.Adjusted_Cost_Fifo__c : 0);
						CoInvoiceHeaderToCost.put(ColififoItem.Part_FIFO_Bucket_Activity_Line_Item__r.CO_Invoice_Header__c,OrginalCost);
					}
						
			}else{
				if( ColififoItem.Part_FIFO_Bucket_Activity_Line_Item__r.CO_Invoice_Header__c !=null){
					OrginalCost = ColififoItem.Part_FIFO_Bucket_Activity_Line_Item__r.CO_Invoice_Header__r.Invoice_Cost__c;
					OrginalCost +=  (ColififoItem.Adjusted_Cost_Fifo__c != null  ? ColififoItem.Adjusted_Cost_Fifo__c : 0) -  (ColififoItem.Last_Cost__c !=null ? ColififoItem.Last_Cost__c : ColififoItem.Avg_Cost__c);
					ColififoItem.Last_Cost__c  = (ColififoItem.Adjusted_Cost_Fifo__c != null ? ColififoItem.Adjusted_Cost_Fifo__c : 0);
					CoInvoiceHeaderToCost.put(ColififoItem.Part_FIFO_Bucket_Activity_Line_Item__r.CO_Invoice_Header__c,OrginalCost);
				}
			}
			OrginalCost = 0;
		}
		 for(String InvoiceId : CoInvoiceHeaderToCost.keySet()){
           CoInvoiceHeaderToupdate.add(new CO_Invoice_Header__c(Id = InvoiceId , Invoice_Cost__c = CoInvoiceHeaderToCost.get(InvoiceId)));
        }
        if( coliFifoListToCalculateCost.size () > 0){
       		 update	coliFifoListToCalculateCost;
        }
        if(CoInvoiceHeaderToupdate.size() > 0 ){
        	update	CoInvoiceHeaderToupdate;
        }
        		
        //system.assert(false,CoInvoiceHeaderToupdate);																
	}
    
    // get update list of COlifiFoitems
    public  static  List<Coli_Fifo_Line_Item_Junction__c> updateInvoiceParts( map<Id,Decimal> FIFOIdToCostMap) {
     List<Coli_Fifo_Line_Item_Junction__c> ColiFifoItemListToUpdate = [ select Id,Part_FIFO_Bucket_Activity_Line_Item__c,Adjusted_Cost_Fifo__c,Qty__c from  Coli_Fifo_Line_Item_Junction__c where Part_FIFO_Bucket_Activity_Line_Item__c IN :(FIFOIdToCostMap.keySet())];
       for(Coli_Fifo_Line_Item_Junction__c ColiFifoItemRec : ColiFifoItemListToUpdate  ){
       		if(FIFOIdToCostMap.containsKey(ColiFifoItemRec.Part_FIFO_Bucket_Activity_Line_Item__c)){
       			system.debug( '$$$$$' +  FIFOIdToCostMap.get(ColiFifoItemRec.Part_FIFO_Bucket_Activity_Line_Item__c));
       			ColiFifoItemRec.Adjusted_Cost_Fifo__c = FIFOIdToCostMap.get(ColiFifoItemRec.Part_FIFO_Bucket_Activity_Line_Item__c) * ColiFifoItemRec.Qty__c;
       		}
       		
       }
       
       return  ColiFifoItemListToUpdate;
    }
    /*  
     * create bucket for on Customer Return add check to for already exists
     */   
    public static void createFIFOBucketForCustomerReturn(List<Part__c> partRecList, String CoInvoiceHeader,List<CO_Line_Item__c> coLineItemsToUpdated) {
        if(AccessControl.ifObjectFieldIsCreateable('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        List<Part_FIFO_Bucket__c> bucketList = new List<Part_FIFO_Bucket__c>();
         List<CO_Line_Item__c> coLineItemList = new List<CO_Line_Item__c>();
        coLineItemList = coLineItemsToUpdated.deepClone(true, false, false);
        Set<String> PartIdSet = new Set<String>(); 
        for(Part__c partRec : partRecList){
                PartIdSet.add(partRec.Id);
                Part_FIFO_Bucket__c bucket = new Part_FIFO_Bucket__c();
                bucket.Source_Name__c = 'Customer Return';
                bucket.Qty_In__c = partRec.Qty_In_Stock__c;
                bucket.Cost__c =  partRec.Last_Cost__c;
                bucket.VRCost__c = partRec.Last_Cost__c;
                bucket.Customer_Return__c = CoInvoiceHeader;
                bucket.Part__c = partRec.Id;
                bucket.Is_FIFO_Bucket__c = true;
                bucketList.add(bucket);
        }
        if(bucketList.size() > 0){
            insert bucketList;
            List<String> partIdList = new List<String>();
            map<Id,Part_FIFO_Bucket__c> ReturnFifoIdToProfitBucketMap = new  map<Id,Part_FIFO_Bucket__c>();
            map<Id,Id> ProfitFifoTOReturnFifoIdMap = new  map<Id,Id>();
            List<Part_FIFO_Bucket__c>   CustomerReturnProfitFIFOBucketList = new 	List<Part_FIFO_Bucket__c>();
        	for(Part_FIFO_Bucket__c fifoBucket : bucketList){
        		Part_FIFO_Bucket__c bucket = new Part_FIFO_Bucket__c();
            	bucket.Source_Name__c = fifoBucket.Source_Name__c;
            	bucket.Qty_In__c = fifoBucket.Qty_In__c;
            	bucket.Cost__c =  fifoBucket.Cost__c;
            	bucket.VRCost__c = fifoBucket.VRCost__c;
            	bucket.Customer_Return__c = fifoBucket.Customer_Return__c;
            	bucket.Part__c = fifoBucket.Part__c;
            	bucket.Is_FIFO_Bucket__c = false;
            	ReturnFifoIdToProfitBucketMap.put(fifoBucket.Id,bucket);
        	}
			//system.assert(false,ReturnFifoIdToProfitBucketMap);
        	if(ReturnFifoIdToProfitBucketMap.values().size() > 0){
        		insert ReturnFifoIdToProfitBucketMap.values();
        	}
            
			for(String key :ReturnFifoIdToProfitBucketMap.keySet()){
			   		ProfitFifoTOReturnFifoIdMap.put(ReturnFifoIdToProfitBucketMap.get(key).Id,key);
			}
            
            map<Id,Part_FIFO_Bucket_Activity_Line_Item__c> PartIdtoPartFIFOactivityMap  = new   map<Id,Part_FIFO_Bucket_Activity_Line_Item__c>();
            for(Part_FIFO_Bucket__c partFifoActivityRec :  ReturnFifoIdToProfitBucketMap.values()){
				  Part_FIFO_Bucket_Activity_Line_Item__c objFifoActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
	                objFifoActivityLineItemRec.CO_Invoice_Header__c = partFifoActivityRec.Customer_Return__c;
	                objFifoActivityLineItemRec.Part_FIFO_Bucket__c = partFifoActivityRec.Id;
	                objFifoActivityLineItemRec.Qty_Out__c = partFifoActivityRec.Qty_In__c;
	                objFifoActivityLineItemRec.Reference__c = '';
	                objFifoActivityLineItemRec.Cost__c = partFifoActivityRec.Cost__c != null ? partFifoActivityRec.Cost__c : 0;
	                objFifoActivityLineItemRec.Type__c = 'Customer Return Profit';  
	                PartIdtoPartFIFOactivityMap.put(partFifoActivityRec.Part__c,objFifoActivityLineItemRec);
            }
            if(PartIdtoPartFIFOactivityMap.values().size() > 0){
            	insert PartIdtoPartFIFOactivityMap.values();
            }
            
           List<Coli_Fifo_Line_Item_Junction__c> coliFifoJunctionList = new List<Coli_Fifo_Line_Item_Junction__c>();  
           for(CO_Line_Item__c coLineItemRec : coLineItemList){
           		if(coLineItemRec.Qty__c < 0 ){
           			if(PartIdtoPartFIFOactivityMap.containsKey(coLineItemRec.part__c)){
           					Part_FIFO_Bucket_Activity_Line_Item__c objFifoActivityLineItemRec =  PartIdtoPartFIFOactivityMap.get(coLineItemRec.part__c);
           				 	Coli_Fifo_Line_Item_Junction__c  coliFifoJunctionRec = new Coli_Fifo_Line_Item_Junction__c();
						    coliFifoJunctionRec.Part_FIFO_Bucket_Activity_Line_Item__c= objFifoActivityLineItemRec.Id;
						    coliFifoJunctionRec.CO_Line_Item__c =  coLineItemRec.Id;
						    coliFifoJunctionRec.Qty__c =coLineItemRec.Qty__c;
						    if(ProfitFifoTOReturnFifoIdMap.containsKey(objFifoActivityLineItemRec.Part_FIFO_Bucket__c)){
						    	coliFifoJunctionRec.Part_FIFO_Bucket__c = ProfitFifoTOReturnFifoIdMap.get(objFifoActivityLineItemRec.Part_FIFO_Bucket__c);
						    }  
						    coliFifoJunctionRec.Avg_Cost__c = coliFifoJunctionRec.Adjusted_Cost_Fifo__c =  coLineItemRec.Qty__c * (objFifoActivityLineItemRec.Cost__c != null ? objFifoActivityLineItemRec.Cost__c : 0) ;
						    coliFifoJunctionList.add(coliFifoJunctionRec);
           			}
           		}
           }
           
           if(coliFifoJunctionList.size() > 0 ){
           		insert coliFifoJunctionList;
           }
            partIdList.addAll(PartIdSet);
            updatePartInStock(partIdList); 
        }
    }

    
     
       
    // For Creating Buckets Activity Line Items
    public static String CreateFiFoBucketActivityForInvoice( Map<Id,List<Part_FIFO_Bucket__c>> PartToFIFOBucketMap ,String invoiceHeaderId ,List<Part__c> ActivityPartList,Map<Id,Part__c> updateStockedMap, List<CO_Line_Item__c> coLineItemRecList){
        if(AccessControl.ifObjectFieldIsCreateable('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Part_FIFO_Bucket_Activity_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Coli_Fifo_Line_Item_Junction__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        List<CO_Line_Item__c> coLineItemList = new List<CO_Line_Item__c>();
        coLineItemList = coLineItemRecList.deepClone(true, false, false);
        //coLineItemList.addAll(coLineItemRecList);
        List<Part_FIFO_Bucket_Activity_Line_Item__c> partFifoActivityLineItem = new List<Part_FIFO_Bucket_Activity_Line_Item__c>();
        List<Part_FIFO_Bucket__c> FifoBucketListToInsert = new List<Part_FIFO_Bucket__c>();
          List<Part_FIFO_Bucket__c> FifoBucketOverSoldListToInsert = new List<Part_FIFO_Bucket__c>();
        set<String> PartIdset = new set<String>();
        Map<Id,List<Part_FIFO_Bucket_Activity_Line_Item__c>> partIdtoPartFifoBucketLineItemMap  = new Map<Id,List<Part_FIFO_Bucket_Activity_Line_Item__c>>();
        for(Part__c partRec : ActivityPartList){ 
            
            if(partRec.Qty_In_Stock__c > 0 ){
                PartIdset.add(partRec.Id);
                if(PartToFIFOBucketMap.ContainsKey(partRec.Id)) {
                        List<Part_FIFO_Bucket__c> FifoBucketList = PartToFIFOBucketMap.get(partRec.Id);
                        for(Part_FIFO_Bucket__c FifoBucketRec : FifoBucketList){ 
                             
                            if(FifoBucketRec.Remaining_Qty__c >= partRec.Qty_In_Stock__c ){
                                Part_FIFO_Bucket_Activity_Line_Item__c objFifoActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
                                objFifoActivityLineItemRec.CO_Invoice_Header__c = invoiceHeaderId;
                                objFifoActivityLineItemRec.Part_FIFO_Bucket__c = FifoBucketRec.Id;
                                objFifoActivityLineItemRec.Qty_Out__c = partRec.Qty_In_Stock__c;
                                objFifoActivityLineItemRec.Reference__c = '';
                                objFifoActivityLineItemRec.Cost__c = FifoBucketRec.Cost__c;
                                objFifoActivityLineItemRec.Type__c = 'Customer Invoice';
                                partFifoActivityLineItem.add(objFifoActivityLineItemRec);
                                partRec.Qty_In_Stock__c = 0;
                                    
                                if(!partIdtoPartFifoBucketLineItemMap.containsKey(partRec.Id)){
                                    partIdtoPartFifoBucketLineItemMap.put(partRec.Id, new List<Part_FIFO_Bucket_Activity_Line_Item__c>());
                                }
                                partIdtoPartFifoBucketLineItemMap.get(partRec.Id).add(objFifoActivityLineItemRec);
                                break;
                            }
                            else{  
                                Part_FIFO_Bucket_Activity_Line_Item__c objFifoActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
                                objFifoActivityLineItemRec.CO_Invoice_Header__c = invoiceHeaderId;
                                objFifoActivityLineItemRec.Part_FIFO_Bucket__c = FifoBucketRec.Id;
                                partRec.Qty_In_Stock__c = partRec.Qty_In_Stock__c - FifoBucketRec.Remaining_Qty__c;
                                objFifoActivityLineItemRec.Qty_Out__c =   FifoBucketRec.Remaining_Qty__c;
                                objFifoActivityLineItemRec.Reference__c = '';
                                objFifoActivityLineItemRec.Cost__c = FifoBucketRec.Cost__c;
                                objFifoActivityLineItemRec.Type__c = 'Customer Invoice';
                                partFifoActivityLineItem.add(objFifoActivityLineItemRec); 
                                if(!partIdtoPartFifoBucketLineItemMap.containsKey(partRec.Id)){
                                    partIdtoPartFifoBucketLineItemMap.put(partRec.Id, new List<Part_FIFO_Bucket_Activity_Line_Item__c>());
                                }
                                partIdtoPartFifoBucketLineItemMap.get(partRec.Id).add(objFifoActivityLineItemRec);
                            }       
                            
                                    

                        }
                }
            }
                if(partRec.Oversold_Qty__c > 0 ){
                    PartIdset.add(partRec.Id);
                    Part_FIFO_Bucket__c bucket = new Part_FIFO_Bucket__c();  
                    bucket.Source_Name__c = 'Oversold';
                	bucket.Qty_In__c = -partRec.Oversold_Qty__c;
                    bucket.Cost__c =  partRec.Last_Cost__c;
                    bucket.VRCost__c = partRec.Last_Cost__c;
                    bucket.Customer_Return__c = invoiceHeaderId;
                    bucket.Part__c = partRec.Id;
                    bucket.Is_FIFO_Bucket__c = true;
                    FifoBucketListToInsert.add(bucket);
                    
                 
                    Part_FIFO_Bucket__c bucketOverSold = new Part_FIFO_Bucket__c();  
                    bucketOverSold.Source_Name__c = 'Oversold profits';
                    bucketOverSold.Cost__c =  partRec.Last_Cost__c;
                	bucketOverSold.Qty_In__c = partRec.Oversold_Qty__c;
                    bucketOverSold.Part__c = partRec.Id;
                    bucketOverSold.Is_FIFO_Bucket__c = false;
                     
                    FifoBucketOverSoldListToInsert.add(bucketOverSold);
                }
            //system.assert(false,FifoBucketList);
        }
        
        
        if(FifoBucketListToInsert.size() >0 ){
            insert  FifoBucketListToInsert;
        }
        if(partFifoActivityLineItem.size() > 0 ){
            insert partFifoActivityLineItem;
        }
        
       /// can be added in futurew
        if(FifoBucketOverSoldListToInsert.size() > 0 ){
        	insert FifoBucketOverSoldListToInsert;
        }
        //List<Part_FIFO_Bucket_Activity_Line_Item__c> partFifoActivityListForOversoldProfits = new  List<Part_FIFO_Bucket_Activity_Line_Item__c>();
        map<string,Part_FIFO_Bucket_Activity_Line_Item__c>  partIdToFifobucketActivityItemMapOversoldProfit = new  map<string,Part_FIFO_Bucket_Activity_Line_Item__c>();
        for(Part_FIFO_Bucket__c fifoBucketRec : FifoBucketOverSoldListToInsert){
        	 Part_FIFO_Bucket_Activity_Line_Item__c objFifoActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
       		 objFifoActivityLineItemRec.Qty_Out__c = fifoBucketRec.Qty_In__c;
       		 objFifoActivityLineItemRec.Part_FIFO_Bucket__c = FifoBucketRec.Id;
       		 objFifoActivityLineItemRec.Type__c = 'Over Sold Profits';
       		  objFifoActivityLineItemRec.Cost__c = fifoBucketRec.Cost__c;
       		 //partFifoActivityListForOversoldProfits.add(objFifoActivityLineItemRec);
       		 partIdToFifobucketActivityItemMapOversoldProfit.put(fifoBucketRec.Part__c, objFifoActivityLineItemRec);
        }
         
        if(partIdToFifobucketActivityItemMapOversoldProfit.values().size() > 0){
        	 insert partIdToFifobucketActivityItemMapOversoldProfit.values();
        }
        
        //
        List<String> PartIdList = new List<String>();
        for(String  Str: PartIdset ){
            PartIdList.add(Str);
        }
        updatePartCommitedInStock(PartIdList,updateStockedMap);
        //System.assert(false, partIdtoPartFifoBucketLineItemMap);
        // TBD  NOte: Why Activity line item used intead of Part fifo bucket
        CO_Line_Item__c coLineItemObj;
        List<CO_Line_Item__c> coLineItemListToUpdate = new List<CO_Line_Item__c>();
        List<Coli_Fifo_Line_Item_Junction__c> coliFifoListToUpdate = new List<Coli_Fifo_Line_Item_Junction__c>();
        for(CO_Line_Item__c coLineItemRec : coLineItemList){
        	
            Decimal avgCost =0;
            Decimal totalCost = 0;
            Decimal Quantity = coLineItemRec.Qty_Committed__c != null && coLineItemRec.Qty_Committed__c != 0 ? coLineItemRec.Qty_Committed__c : 1;
            if(partIdtoPartFifoBucketLineItemMap.get(coLineItemRec.Part__c)!=null){
                for(Part_FIFO_Bucket_Activity_Line_Item__c partFifoActivityLineItemRec:   partIdtoPartFifoBucketLineItemMap.get(coLineItemRec.Part__c)){
                    //totalcost +=  (coLineItemRec.Qty_Committed__c - partFifoActivityLineItemRec.Qty_Out__c) * partFifoActivityLineItemRec.Cost__c;
                   if(partFifoActivityLineItemRec.Qty_Out__c > 0 ){ 
                   		//system.debug('@@@@@'+   'Activity ID' +  partFifoActivityLineItemRec.Id  +'qty'+ partFifoActivityLineItemRec.Qty_Out__c + 'ColiId'+ coLineItemRec.Id + 'cqty '+  coLineItemRec.Qty_Committed__c);	
						if((partFifoActivityLineItemRec.Qty_Out__c >=  coLineItemRec.Qty_Committed__c) ){
						    totalcost += coLineItemRec.Qty_Committed__c * partFifoActivityLineItemRec.Cost__c;
						    Decimal fifoLineItemQtyOut = partFifoActivityLineItemRec.Qty_Out__c;
						    partFifoActivityLineItemRec.Qty_Out__c -= coLineItemRec.Qty_Committed__c;
						    Coli_Fifo_Line_Item_Junction__c  coliFifoJunctionRec = new Coli_Fifo_Line_Item_Junction__c();
						    coliFifoJunctionRec.Part_FIFO_Bucket_Activity_Line_Item__c= partFifoActivityLineItemRec.Id;
						    coliFifoJunctionRec.CO_Line_Item__c =  coLineItemRec.Id;
						    coliFifoJunctionRec.Qty__c =coLineItemRec.Qty_Committed__c;
						    coliFifoJunctionRec.Avg_Cost__c = coliFifoJunctionRec.Adjusted_Cost_Fifo__c =  coLineItemRec.Qty_Committed__c * partFifoActivityLineItemRec.Cost__c;
							coliFifoListToUpdate.add(coliFifoJunctionRec);
							// fulfill commited
						    coLineItemRec.Qty_Committed__c = 0;
						    break;
						}
						else if(coLineItemRec.Qty_Committed__c > partFifoActivityLineItemRec.Qty_Out__c ){
						    totalcost += partFifoActivityLineItemRec.Qty_Out__c * partFifoActivityLineItemRec.Cost__c;
						    coLineItemRec.Qty_Committed__c -= partFifoActivityLineItemRec.Qty_Out__c;
						    Coli_Fifo_Line_Item_Junction__c  coliFifoJunctionRec = new Coli_Fifo_Line_Item_Junction__c();
						    coliFifoJunctionRec.Part_FIFO_Bucket_Activity_Line_Item__c= partFifoActivityLineItemRec.Id;
						    coliFifoJunctionRec.CO_Line_Item__c =  coLineItemRec.Id;
						    coliFifoJunctionRec.Qty__c = partFifoActivityLineItemRec.Qty_Out__c;
						    coliFifoJunctionRec.Avg_Cost__c = coliFifoJunctionRec.Adjusted_Cost_Fifo__c =  partFifoActivityLineItemRec.Qty_Out__c * partFifoActivityLineItemRec.Cost__c;
						    coliFifoListToUpdate.add(coliFifoJunctionRec);
						    // fulfill  fifo bucket
						    partFifoActivityLineItemRec.Qty_Out__c = 0;
						}
                   }
                }
                avgCost = totalCost/Quantity;
                coLineItemObj = new CO_Line_Item__c();
                coLineItemObj.Id = coLineItemRec.Id;
                coLineItemObj.Avg_Cost__c = avgCost;
                //coLineItemObj.Adjusted_Cost__c = totalCost;
                //coLineItemObj.Original_Cost__c = totalCost;
                coLineItemListToUpdate.add(coLineItemObj);
            }
            
               if(coLineItemRec.Oversold_Qty__c != null &&  coLineItemRec.Oversold_Qty__c > 0){
               	if(partIdToFifobucketActivityItemMapOversoldProfit.containsKey(coLineItemRec.Part__c)){
               		Part_FIFO_Bucket_Activity_Line_Item__c partFifoActivityLineItemOversoldRec =  partIdToFifobucketActivityItemMapOversoldProfit.get(coLineItemRec.Part__c);
               		Decimal fifoLineItemQtyOut = 0 ;
       				
				    if((partFifoActivityLineItemOversoldRec.Qty_Out__c >=  coLineItemRec.Oversold_Qty__c) ){
				    	fifoLineItemQtyOut = coLineItemRec.Oversold_Qty__c;
               			partFifoActivityLineItemOversoldRec.Qty_Out__c -= coLineItemRec.Oversold_Qty__c;
               			Coli_Fifo_Line_Item_Junction__c  coliFifoJunctionRec = new Coli_Fifo_Line_Item_Junction__c();
					    coliFifoJunctionRec.Part_FIFO_Bucket_Activity_Line_Item__c= partFifoActivityLineItemOversoldRec.Id;
					    coliFifoJunctionRec.CO_Line_Item__c =  coLineItemRec.Id;
					    coliFifoJunctionRec.Qty__c = fifoLineItemQtyOut;
					    partFifoActivityLineItemOversoldRec.Cost__c = partFifoActivityLineItemOversoldRec.Cost__c != null ? partFifoActivityLineItemOversoldRec.Cost__c : 0;
					    coliFifoJunctionRec.Avg_Cost__c = coliFifoJunctionRec.Adjusted_Cost_Fifo__c =  fifoLineItemQtyOut  * partFifoActivityLineItemOversoldRec.Cost__c;
					    coliFifoListToUpdate.add(coliFifoJunctionRec);
               			}
               		}
               }
        }
        
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        //system.assert(false,coLineItemListToUpdate);
        if(coLineItemListToUpdate.size()>0){
            update coLineItemListToUpdate;
        }
        if(AccessControl.ifObjectFieldIsCreateable('Coli_Fifo_Line_Item_Junction__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
       	if(coliFifoListToUpdate.size() > 0 ){
        	insert coliFifoListToUpdate;
        }
        
        system.debug('$$$$$' + coliFifoListToUpdate +'  '+ partIdToFifobucketActivityItemMapOversoldProfit);
            
        return 'success';
    }
    
    /*
     * create bucket for Part
     */                                                                                                                                                             
    public static void updatePartCommitedInStock(List<String> partRecList,Map<Id,Part__c> updateStockedMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<Part_FIFO_Bucket__c> fifoBucketList = [select Remaining_Qty__c, Part__c, Total__c
                                                    from Part_FIFO_Bucket__c
                                                    where Part__c = :partRecList and Is_FIFO_Bucket__c = true and Remaining_Qty__c !=0];
        Decimal totalCost;
        Decimal totalRemainingQty; 
        List<part__c> partListToUpdate = new List<Part__c>();
        for(String partId : partRecList){
            totalCost = 0;
            totalRemainingQty = 0;
            Part__c PartRec = new Part__c();
            PartRec.Id = partId; 
            PartRec.Qty_In_Stock__c = 0;
            for(Part_FIFO_Bucket__c bucket : fifoBucketList){
                if(bucket.Part__c == partId){
                    //bucket.recalculateFormulas();
                    PartRec.Qty_In_Stock__c += (bucket.Remaining_Qty__c != null ? (bucket.Remaining_Qty__c < 0 ? 0 : bucket.Remaining_Qty__c)   : 0);
                    totalCost += bucket.Total__c;
                    totalRemainingQty += (bucket.Remaining_Qty__c != null ? bucket.Remaining_Qty__c : 0);
                }
            }
            if(updateStockedMap.containsKey(PartRec.Id)){
                PartRec.Qty_Committed__c = updateStockedMap.get(PartRec.Id).Qty_Committed__c;
            }
            PartRec.Average_Cost__c = totalRemainingQty != 0 ? (totalCost/totalRemainingQty) : 0;
            partListToUpdate.add(PartRec);
        }
        if(partListToUpdate.size() > 0){
            update partListToUpdate;            
        }
    }
        /*
     * create bucket for Part
     */                                                                                                                                                             
    

    /*
     * create bucket for Part
     */                                                                                                                                                             
    public static void updatePartInStock(List<String> partRecList) {
        if(AccessControl.ifObjectFieldIsAccessible('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        List<Part_FIFO_Bucket__c> fifoBucketList = [select Remaining_Qty__c, Part__c, Total__c,Source_Name__c
                                                    from Part_FIFO_Bucket__c
                                                    where Part__c = :partRecList and Is_FIFO_Bucket__c = true and Remaining_Qty__c > 0];
        Decimal totalCost;
        Decimal totalRemainingQty;
        List<part__c> partListToUpdate = new List<Part__c>();
        for(String partId : partRecList){
            totalCost = 0;
            totalRemainingQty = 0;
            Part__c PartRec = new Part__c();
            PartRec.Id = partId;
            PartRec.Qty_In_Stock__c = 0;
            for(Part_FIFO_Bucket__c bucket : fifoBucketList){
                if(bucket.Part__c == partId){
                    PartRec.Qty_In_Stock__c += (bucket.Remaining_Qty__c != null ? bucket.Remaining_Qty__c : 0);
                    totalCost += bucket.Total__c;
                    totalRemainingQty += (bucket.Remaining_Qty__c != null ? bucket.Remaining_Qty__c : 0);
                }
            }
            PartRec.Average_Cost__c = totalRemainingQty != 0 ? (totalCost/totalRemainingQty) : 0;
            PartRec.Last_Counted__c = system.Now();
            partListToUpdate.add(PartRec);
        }
        
        if(partListToUpdate.size() > 0){
            update partListToUpdate;            
        }
    }
        
    // Insert Activity and Deduction from Buckets
    public String insertBucketActivity(){
        return null;
    }
    
    // Get Bucket Records 
    public String getBucket(String PartId,boolean ShowHistory){
        return null;
    }
	
	public static void CreateFiFoBucketActivityForReturnVendor(List<Return_VO_Line_Item__c> returnVOLIList, String returnVOH){
		Map<String, List<Return_VO_Line_Item__c>> partIdToRVOLIListMap = new Map<String, List<Return_VO_Line_Item__c>>();
		for(Return_VO_Line_Item__c returnVOLIRec : returnVOLIList){
			if(!partIdToRVOLIListMap.containsKey(returnVOLIRec.Part__c)) {
				partIdToRVOLIListMap.put(returnVOLIRec.Part__c, new List<Return_VO_Line_Item__c>());
			}
			partIdToRVOLIListMap.get(returnVOLIRec.Part__c).add(returnVOLIRec);
		}
		if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		Map<String, Part__c> partIdToPartRecMap = new Map<String, Part__c>([Select Id, Qty_In_Stock__c, Qty_Committed__c, 
															(Select Id, Part__c, Remaining_Qty__c, Cost__c FROM Part_FIFO_Buckets__r
															where Remaining_Qty__c > 0) 
						 								FROM Part__c Where Id IN : partIdToRVOLIListMap.KeySet()]);
		
		
		List<Part_FIFO_Bucket_Activity_Line_Item__c> partFifoActivityLineItem  = new List<Part_FIFO_Bucket_Activity_Line_Item__c>();
		set<String> PartIdset = new set<String>();
		List<Return_VO_Line_Item__c> rVOLIListToUpsert = new List<Return_VO_Line_Item__c>();
        Map<Id,List<Part_FIFO_Bucket_Activity_Line_Item__c>> partIdtoPartFifoBucketLineItemMap  = new Map<Id,List<Part_FIFO_Bucket_Activity_Line_Item__c>>();
        for(Part__c partRec : partIdToPartRecMap.values()) {
            PartIdset.add(partRec.Id);
            Decimal qtyCommitted = 0;
            Decimal returnVOLIQty; 
        	if(partIdToRVOLIListMap.containsKey(partRec.Id)) {
            	for(Return_VO_Line_Item__c rVOLIRec : partIdToRVOLIListMap.get(partRec.Id)){
            		Decimal cost = 0.00;
            		returnVOLIQty = rVOLIRec.Return_Qty__c;
            		 for(Part_FIFO_Bucket__c FifoBucketRec : partRec.Part_FIFO_Buckets__r){
                    	Part_FIFO_Bucket_Activity_Line_Item__c objFifoActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
                        objFifoActivityLineItemRec.Part_FIFO_Bucket__c = FifoBucketRec.Id;
                        objFifoActivityLineItemRec.Reference__c = 'Vendor Return';
                        objFifoActivityLineItemRec.Cost__c = FifoBucketRec.Cost__c;
                        objFifoActivityLineItemRec.Type__c = 'Vendor Return';
                        objFifoActivityLineItemRec.Return_VO_Header__c = returnVOH;
                        objFifoActivityLineItemRec.Return_VO_Line_Item__c = rVOLIRec.Id;
                        
                        if(FifoBucketRec.Remaining_Qty__c >= returnVOLIQty) {
                            objFifoActivityLineItemRec.Qty_Out__c = returnVOLIQty;
                            partFifoActivityLineItem.add(objFifoActivityLineItemRec);
                            returnVOLIQty = 0;
                		 } else {
                            objFifoActivityLineItemRec.Qty_Out__c =   FifoBucketRec.Remaining_Qty__c;
                            returnVOLIQty = returnVOLIQty - FifoBucketRec.Remaining_Qty__c;
                            partFifoActivityLineItem.add(objFifoActivityLineItemRec); 
                        }
                        if(objFifoActivityLineItemRec.Qty_Out__c != null && objFifoActivityLineItemRec.Qty_Out__c != 0 && FifoBucketRec.Cost__c != null &&
                        		FifoBucketRec.Cost__c != 0) {
                        	cost += FifoBucketRec.Cost__c * objFifoActivityLineItemRec.Qty_Out__c;
                        }
                        qtyCommitted += (objFifoActivityLineItemRec.Qty_Out__c != null) ? objFifoActivityLineItemRec.Qty_Out__c : 0;
                        if(returnVOLIQty == 0){
                        	break;
                        }
                    }
                	rVOLIRec.Inventory_Cost__c = cost;
                	rVOLIListToUpsert.add(rVOLIRec);
				}
       		}
           	partRec.Qty_Committed__c -= qtyCommitted;
           	partRec.Qty_In_Stock__c  -= qtyCommitted;
    	}
    	if(partFifoActivityLineItem.size() > 0 ){
    		if(AccessControl.ifObjectFieldIsCreateable('Part_FIFO_Bucket_Activity_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
			if(AccessControl.ifObjectFieldIsUpdateable('Return_VO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
			if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    		insert partFifoActivityLineItem;
        	update rVOLIListToUpsert;
        	update partIdToPartRecMap.values();
    	}
	}
	
	public static void updatePartFIFODetails(List<Part__c> partList) {
		if(partList.size() > 0) {
    		List<Part_FIFO_Bucket_Activity_Line_Item__c> fifoBktLIList = [Select Id, Qty_Out__c, Part_FIFO_Bucket__r.Cost__c, Part_FIFO_Bucket__r.Part__c, CreatedDate from Part_FIFO_Bucket_Activity_Line_Item__c where Part_FIFO_Bucket__r.Part__c In: partList 
    			AND Part_FIFO_Bucket__r.Is_FIFO_Bucket__c = true Order By CreatedDate ASC];
    		
    		Map<String, List<Part_FIFO_Bucket_Activity_Line_Item__c>> partIdToFIFOLIListMap = new Map<String, List<Part_FIFO_Bucket_Activity_Line_Item__c>>();
    		for(Part_FIFO_Bucket_Activity_Line_Item__c bktLIRec : fifoBktLIList) {
    			if(!partIdToFIFOLIListMap.containsKey(bktLIRec.Part_FIFO_Bucket__r.Part__c)) {
    				partIdToFIFOLIListMap.put(bktLIRec.Part_FIFO_Bucket__r.Part__c, new List<Part_FIFO_Bucket_Activity_Line_Item__c>());
    			}
    			partIdToFIFOLIListMap.get(bktLIRec.Part_FIFO_Bucket__r.Part__c).add(bktLIRec);
    		}
    		
    		Set<String> updatedBktLIIdSet = new Set<String>();
    		List<Part_FIFO_Bucket__c> fifoBktListToUpdate = new List<Part_FIFO_Bucket__c>();
    		List<Part_FIFO_Bucket_Activity_Line_Item__c> fifoBktLIListToUpdate = new List<Part_FIFO_Bucket_Activity_Line_Item__c>();
    		for(Part__c partRec : partList) {
    			Decimal cost = 0;
                Decimal qtyInStockWhenCreated = 0;
                Decimal avgCostWhenCreated = 0;
                for(Part_FIFO_Bucket__c fifoBktRec : partRec.Part_FIFO_Buckets__r) {
                    Boolean isFifoBucketAdded = false;
                    fifoBktRec.Qty_In__c = (fifoBktRec.Qty_In__c != null) ? fifoBktRec.Qty_In__c : 0;
                    if(partIdToFIFOLIListMap.containsKey(partRec.Id)) {
                        for(Part_FIFO_Bucket_Activity_Line_Item__c fifoBktLIRec : partIdToFIFOLIListMap.get(partRec.Id)) {
                        	if(!updatedBktLIIdSet.contains(fifoBktLIRec.Id)) {
	                            if(fifoBktLIRec.CreatedDate < fifoBktRec.CreatedDate) {
	                                fifoBktLIRec.Qty_In_Stock_When_Created__c = qtyInStockWhenCreated;
	                                fifoBktLIRec.Average_Cost_When_Created__c = avgCostWhenCreated;
	                                fifoBktLIListToUpdate.add(fifoBktLIRec);
	                                updatedBktLIIdSet.add(fifoBktLIRec.Id);
	                                fifoBktLIRec.Qty_Out__c = (fifoBktLIRec.Qty_Out__c != null) ? fifoBktLIRec.Qty_Out__c : 0;
	                                
	                                cost = (fifoBktLIRec.Part_FIFO_Bucket__r.Cost__c != null) ? fifoBktLIRec.Part_FIFO_Bucket__r.Cost__c : 0;
	                                qtyInStockWhenCreated = (fifoBktLIRec.Qty_In_Stock_When_Created__c - fifoBktLIRec.Qty_Out__c);
	                                avgCostWhenCreated = qtyInStockWhenCreated != 0 ? ((avgCostWhenCreated * fifoBktLIRec.Qty_In_Stock_When_Created__c) - (fifoBktLIRec.Qty_Out__c * cost)) / (qtyInStockWhenCreated) : 0;
	                                
	                            } else {
	                                fifoBktRec.Qty_In_Stock_When_Created__c = qtyInStockWhenCreated;
	                                fifoBktRec.Average_Cost_When_Created__c = avgCostWhenCreated;
	                                fifoBktListToUpdate.add(fifoBktRec);
	                                fifoBktRec.Qty_In__c = (fifoBktRec.Qty_In__c != null) ? fifoBktRec.Qty_In__c : 0;
	                                
	                                cost = (fifoBktRec.Cost__c != null) ? fifoBktRec.Cost__c : 0;
	                                qtyInStockWhenCreated = (fifoBktRec.Qty_In_Stock_When_Created__c + fifoBktRec.Qty_In__c);
	                                avgCostWhenCreated = qtyInStockWhenCreated != 0 ? ((avgCostWhenCreated * fifoBktRec.Qty_In_Stock_When_Created__c) + 
	                                     (fifoBktRec.Qty_In__c * cost)) / (qtyInStockWhenCreated) : 0;
	                                isFifoBucketAdded = true;
	                                break;
	                            }
                        	}
                        }
                        if(!isFifoBucketAdded) {
                            fifoBktRec.Qty_In_Stock_When_Created__c = qtyInStockWhenCreated;
                            fifoBktRec.Average_Cost_When_Created__c = avgCostWhenCreated;
                            fifoBktListToUpdate.add(fifoBktRec);
                            fifoBktRec.Qty_In__c = (fifoBktRec.Qty_In__c != null) ? fifoBktRec.Qty_In__c : 0;
                            cost = (fifoBktRec.Cost__c != null) ? fifoBktRec.Cost__c : 0;
                            qtyInStockWhenCreated = (fifoBktRec.Qty_In_Stock_When_Created__c + fifoBktRec.Qty_In__c);
                            avgCostWhenCreated = qtyInStockWhenCreated != 0 ? ((avgCostWhenCreated * fifoBktRec.Qty_In_Stock_When_Created__c) + 
                                     (fifoBktRec.Qty_In__c * cost)) / (qtyInStockWhenCreated) : 0;
                        }
                    } else {
                        fifoBktRec.Qty_In_Stock_When_Created__c = qtyInStockWhenCreated;
                        fifoBktRec.Average_Cost_When_Created__c = avgCostWhenCreated;
                        fifoBktListToUpdate.add(fifoBktRec);
                        fifoBktRec.Qty_In__c = (fifoBktRec.Qty_In__c != null) ? fifoBktRec.Qty_In__c : 0;
                        cost = (fifoBktRec.Cost__c != null) ? fifoBktRec.Cost__c : 0;
                        qtyInStockWhenCreated = (fifoBktRec.Qty_In_Stock_When_Created__c + fifoBktRec.Qty_In__c);
                        avgCostWhenCreated = qtyInStockWhenCreated != 0 ? ((avgCostWhenCreated * fifoBktRec.Qty_In_Stock_When_Created__c) + 
                                     (fifoBktRec.Qty_In__c * cost)) / (qtyInStockWhenCreated) : 0;
                        isFifoBucketAdded = true;
                    }
                }
                if(partIdToFIFOLIListMap.containsKey(partRec.Id)) {
                    for(Part_FIFO_Bucket_Activity_Line_Item__c fifoBktLIRec : partIdToFIFOLIListMap.get(partRec.Id)) {
                        if(!updatedBktLIIdSet.contains(fifoBktLIRec.Id)) {
                            fifoBktLIRec.Qty_In_Stock_When_Created__c = qtyInStockWhenCreated;
                            fifoBktLIRec.Average_Cost_When_Created__c = avgCostWhenCreated;
                            fifoBktLIListToUpdate.add(fifoBktLIRec);
                            updatedBktLIIdSet.add(fifoBktLIRec.Id);
                            fifoBktLIRec.Qty_Out__c = (fifoBktLIRec.Qty_Out__c != null) ? fifoBktLIRec.Qty_Out__c : 0;
                            cost = (fifoBktLIRec.Part_FIFO_Bucket__r.Cost__c != null) ? fifoBktLIRec.Part_FIFO_Bucket__r.Cost__c : 0;
                            qtyInStockWhenCreated = (fifoBktLIRec.Qty_In_Stock_When_Created__c - fifoBktLIRec.Qty_Out__c);
                            avgCostWhenCreated = qtyInStockWhenCreated != 0 ? ((avgCostWhenCreated*fifoBktLIRec.Qty_In_Stock_When_Created__c) 
                                     -(fifoBktLIRec.Qty_Out__c * cost)) / (qtyInStockWhenCreated) : 0 ;
                        }
                    }
                }
            }
            //On data load for part buckets were not inserted in next batch (Added by nidhi)
            PartTriggerHelper.isDisableTriggerForSetQtyAndAvgCostOnFIFOBktAndLIBatch = true;
    		update fifoBktListToUpdate;
    		update fifoBktLIListToUpdate;
    		PartTriggerHelper.isDisableTriggerForSetQtyAndAvgCostOnFIFOBktAndLIBatch = false;
    	}
	}
}