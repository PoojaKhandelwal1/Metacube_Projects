public with sharing class AccountingPartFIFOWrapper {
    public static String FIFOBucketId;
	public static String UniqueId;
	public static String CreatedDate;
	public static String Memo;
	public static String Gst = 'P';
	public static String Inclusive = 'X';
	public static String GLAccountNumber;
	public static String No = 'N';
	public static String Yes = 'Y';
	public static Decimal Amount;
	public static String TaxCode = 'N-T';
	public static String AllocationMemo; 
	public static String InventoryAdjustmentGLCode = String.isNotBlank(AccountingUtil.getChartofAccount('Inventory Adjustments')) ? 
											AccountingUtil.getChartofAccount('Inventory Adjustments') : '';
	public static String InventoryAccrualCode = String.isNotBlank(AccountingUtil.getChartofAccount('A/P Inventory Accrual')) ? 
											AccountingUtil.getChartofAccount('A/P Inventory Accrual') : '';										
	public static String value;
	public static String amountEntry;
	public static String amountReverseEntry;
	
	public static string AccountingPartFIFOWrapperRec(Part_FIFO_Bucket__c partFifoBucketRec){
		UniqueId = partFifoBucketRec.Unique_Id__c;
		CreatedDate = partFifoBucketRec.CreatedDate.format(DataExportService.dateFormat);
		FIFOBucketId = partFifoBucketRec.Id;
		GLAccountNumber = (partFifoBucketRec.Part__r.Category__r != null && partFifoBucketRec.Part__r.Category__r.Inventory_GL__c != null) ? 
								partFifoBucketRec.Part__r.Category__r.Inventory_GL__c : ''; 
		Memo = partFifoBucketRec.Part__r.Part_ID__c + ';' + 'Count Adjustment';
		Amount = ((partFifoBucketRec.Qty_In__c == null ? 0 :partFifoBucketRec.Qty_In__c) * (partFifoBucketRec.Cost__c == null ? 0 : partFifoBucketRec.Cost__c)).setScale(2, RoundingMode.HALF_UP);
		AllocationMemo = partFifoBucketRec.Part__r.Part_ID__c + ' - increased by ' + (partFifoBucketRec.Qty_In__c == null? 0: partFifoBucketRec.Qty_In__c).setScale(2, RoundingMode.HALF_UP) + '@$'+ (partFifoBucketRec.cost__c == null ? 0: partFifoBucketRec.cost__c).setScale(2, RoundingMode.HALF_UP);
		
		amountEntry = (Amount > 0) ? (No +'\t'+ '$'+Amount) : (Yes +'\t'+ '$'+(-1 * Amount));
		amountReverseEntry = (Amount > 0) ? (Yes +'\t'+ '$'+Amount) : (No +'\t'+ '$'+(-1 * Amount));
		if(partFifoBucketRec.Source_Name__c.toLowerCase() == 'oversold') {
			InventoryAdjustmentGLCode = partFifoBucketRec.Part__r.Category__r.COGS_GL__c != null ? 
												partFifoBucketRec.Part__r.Category__r.COGS_GL__c : '';
			UniqueId = (partFifoBucketRec.Customer_Return__r.Invoice_Number__c != null) ? partFifoBucketRec.Customer_Return__r.Invoice_Number__c.replace('INV-', '') : '';
		}
		
		value = UniqueId + '\t' + CreatedDate + '\t' + Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+GLAccountNumber+'\t' + amountEntry +'\t'+ TaxCode +'\t'+ AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+InventoryAdjustmentGLCode+'\t' + amountReverseEntry +'\t'+ TaxCode +'\t'+ AllocationMemo;
		return value;
	}

	public static string PartFIFOActivityLineItemRec(Part_FIFO_Bucket_Activity_Line_Item__c partFifoActivityLineItemRec, Part_FIFO_Bucket__c partFifoBucketRec){
		UniqueId = partFifoActivityLineItemRec.Unique_Id__c == null ? partFifoBucketRec.Unique_Id__c : partFifoActivityLineItemRec.Unique_Id__c ;
		CreatedDate = partFifoActivityLineItemRec.CreatedDate.format(DataExportService.dateFormat);
		FIFOBucketId =  partFifoActivityLineItemRec.Id;
		
        GLAccountNumber = (partFifoBucketRec.Part__r.Category__r != null && partFifoBucketRec.Part__r.Category__r.Inventory_GL__c != null) 
									? partFifoBucketRec.Part__r.Category__r.Inventory_GL__c : ''; 
		Memo = partFifoBucketRec.Part__r.Part_ID__c+ ';' + 'Count Adjustment';
		Amount = ((partFifoActivityLineItemRec.Qty_Out__c == null ? 0 :partFifoActivityLineItemRec.Qty_Out__c) * (partFifoBucketRec.Cost__c == null ? 0 : partFifoBucketRec.Cost__c)).setScale(2, RoundingMode.HALF_UP);
		AllocationMemo = partFifoBucketRec.Part__r.Part_ID__c + ' - reduced by ' + (partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c).setScale(2, RoundingMode.HALF_UP)  + '@$'+ (partFifoBucketRec.cost__c == null ?0:partFifoBucketRec.cost__c).setScale(2, RoundingMode.HALF_UP);
		
		amountEntry = (Amount > 0) ? (Yes +'\t'+ '$'+Amount) : (No +'\t'+ '$'+(-1 * Amount));
		amountReverseEntry = (Amount > 0) ? (No +'\t'+ '$'+Amount) : (Yes +'\t'+ '$'+(-1 * Amount));
		
		value =  UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+GLAccountNumber+'\t' + amountEntry+'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+InventoryAdjustmentGLCode+'\t' + amountReverseEntry +'\t'+ TaxCode+'\t'+AllocationMemo;
		return value;
	}
		
	public static string AccountingPartFIFOWrapperCostRec(Part_FIFO_Bucket__c partFifoBucketRec){
		UniqueId = partFifoBucketRec.Unique_Id__c;
		CreatedDate = partFifoBucketRec.CreatedDate.format(DataExportService.dateFormat);
		FIFOBucketId =  partFifoBucketRec.Id;
		GLAccountNumber = (partFifoBucketRec.Part__r.Category__r != null && partFifoBucketRec.Part__r.Category__r.Inventory_GL__c != null) ? 
											partFifoBucketRec.Part__r.Category__r.Inventory_GL__c : ''; 
		Memo = partFifoBucketRec.Part__r.Part_ID__c+ ';' + 'Cost Adjustment';
		Amount = ((partFifoBucketRec.Qty_In__c == null? 0 :partFifoBucketRec.Qty_In__c) * (partFifoBucketRec.Cost__c == null ? 0 : partFifoBucketRec.Cost__c)).setScale(2, RoundingMode.HALF_UP);
		AllocationMemo = partFifoBucketRec.Part__r.Part_ID__c + ' - increased by ' + (partFifoBucketRec.Qty_In__c==null? 0: partFifoBucketRec.Qty_In__c).setScale(2, RoundingMode.HALF_UP)  + '@$'+ (partFifoBucketRec.cost__c == null ?0:partFifoBucketRec.cost__c).setScale(2, RoundingMode.HALF_UP);
	 	
	 	amountEntry = (Amount > 0) ? (No +'\t'+ '$'+Amount) : (Yes +'\t'+ '$'+(-1 * Amount));
		amountReverseEntry = (Amount > 0) ? (Yes +'\t'+ '$'+Amount) : (No +'\t'+ '$'+(-1 * Amount));
		
		value =  UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+GLAccountNumber+'\t' + amountEntry+'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+InventoryAdjustmentGLCode+'\t' + amountReverseEntry +'\t'+ TaxCode+'\t'+AllocationMemo;
		return value;
	}

	public static string PartFIFOActivityCostLineItemRec(Part_FIFO_Bucket_Activity_Line_Item__c partFifoActivityLineItemRec, Part_FIFO_Bucket__c partFifoBucketRec){
		UniqueId = partFifoActivityLineItemRec.Unique_Id__c ==  NULL ? partFifoBucketRec.Unique_Id__c: partFifoActivityLineItemRec.Unique_Id__c ;
		CreatedDate = partFifoActivityLineItemRec.CreatedDate!= null ? partFifoActivityLineItemRec.CreatedDate.format(DataExportService.dateFormat) : System.now().format(DataExportService.dateFormat) ;
		FIFOBucketId =  partFifoBucketRec.Id;
		GLAccountNumber = (partFifoBucketRec.Part__r.Category__r != null && partFifoBucketRec.Part__r.Category__r.Inventory_GL__c != null) ? partFifoBucketRec.Part__r.Category__r.Inventory_GL__c : ''; 
		Memo = partFifoBucketRec.Part__r.Part_ID__c+ ';' + 'Cost Adjustment';
		Amount = ((partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c) * (partFifoBucketRec.Cost__c == null ? 0 : partFifoBucketRec.Cost__c)).setScale(2, RoundingMode.HALF_UP);
		AllocationMemo = partFifoBucketRec.Part__r.Part_ID__c + ' - reduced by ' + (partFifoBucketRec.Qty_Out__c == null? 0 :partFifoBucketRec.Qty_Out__c).setScale(2, RoundingMode.HALF_UP)  + '@$'+ (partFifoBucketRec.cost__c == null ?0:partFifoBucketRec.cost__c).setScale(2, RoundingMode.HALF_UP);
		amountEntry = (Amount > 0) ? (Yes +'\t'+ '$'+Amount) : (No +'\t'+ '$'+(-1 * Amount));
		amountReverseEntry = (Amount > 0) ? (No +'\t'+ '$'+Amount) : (Yes +'\t'+ '$'+(-1 * Amount));
		
		value =  UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+GLAccountNumber+'\t' + amountEntry+'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+InventoryAdjustmentGLCode+'\t' + amountReverseEntry +'\t'+ TaxCode+'\t'+AllocationMemo;
		return value;
	}
	
	
	public static string PartFIFOActivityCostAdjustItemRec(Part_FIFO_Bucket_Activity_Line_Item__c partFifoActivityLineItemRec){
		UniqueId = partFifoActivityLineItemRec.Unique_Id__c == null ? partFifoActivityLineItemRec.Part_Adjustment__r.Unique_Id__c :partFifoActivityLineItemRec.Unique_Id__c  ;
		CreatedDate = partFifoActivityLineItemRec.CreatedDate!= null ? partFifoActivityLineItemRec.CreatedDate.format(DataExportService.dateFormat) : System.now().format(DataExportService.dateFormat) ;
		FIFOBucketId =  partFifoActivityLineItemRec.Id;
		GLAccountNumber = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c != null ? 
								partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c : ''; 
		Memo = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Part_ID__c+ ';' + 'Cost Adjustment';
		Amount = ((partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c) * (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Cost__c == null ? 0 : partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Cost__c)).setScale(2, RoundingMode.HALF_UP);
		AllocationMemo = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Part_Id__c + ' - reduced by ' + (partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c).setScale(2, RoundingMode.HALF_UP)  + '@$'+ (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.cost__c == null ?0:partFifoActivityLineItemRec.Part_FIFO_Bucket__r.cost__c).setScale(2, RoundingMode.HALF_UP);
		amountEntry = (Amount > 0) ? (Yes +'\t'+ '$'+Amount) : (No +'\t'+ '$'+(-1 * Amount));
		amountReverseEntry = (Amount > 0) ? (No +'\t'+ '$'+Amount) : (Yes +'\t'+ '$'+(-1 * Amount));
		
		value =  UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+GLAccountNumber+'\t' + amountEntry +'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+InventoryAdjustmentGLCode+'\t' + amountReverseEntry +'\t'+ TaxCode+'\t'+AllocationMemo;
		return value;
	}
	
	public static string UnitCostAdjustItemRec(Unit_Price_Cost__c adjstmentRec) {
		Amount = (adjstmentRec.Total_Cost__c == null ? 0 : adjstmentRec.Total_Cost__c).setScale(2, RoundingMode.HALF_UP);
		
		GLAccountNumber = adjstmentRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null ? 
								adjstmentRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c : ''; 
		Memo = adjstmentRec.Customer_Owned_Unit__r.Unit_Id__c + ';' + adjstmentRec.Customer_Owned_Unit__r.Stock_Id__c + ';' + adjstmentRec.Type__c;
		AllocationMemo = adjstmentRec.Customer_Owned_Unit__r.Unit_Id__c + ' - ' + adjstmentRec.Type__c;
		if(adjstmentRec.Type__c == 'Factory' || adjstmentRec.Type__c == 'Dealer') {
			Memo += ' Option';
			AllocationMemo += ' Option';
		}
		Memo += ' Cost Adjustment';
		
		AllocationMemo += ' Cost adjusted by $' + adjstmentRec.Total_Cost__c;
		//AllocationMemo += (Amount > 0) ? (' adjusted by $' + adjstmentRec.Total_Cost__c) : (' adjusted by $' + adjstmentRec.Total_Cost__c);
		CreatedDate = adjstmentRec.CreatedDate != null ? adjstmentRec.CreatedDate.format(DataExportService.dateFormat) : System.now().format(DataExportService.dateFormat);
		
		UniqueId = adjstmentRec.Ref_No__c == null ? '' : adjstmentRec.Ref_No__c;
		
		FIFOBucketId =  adjstmentRec.Id;
		
		amountEntry = (Amount > 0) ? (Yes +'\t'+ '$'+Amount) : (No +'\t'+ '$'+(-1 * Amount));
		amountReverseEntry = (Amount > 0) ? (No +'\t'+ '$'+Amount) : (Yes +'\t'+ '$'+(-1 * Amount));
		
		String invAdjustmentGLAccNumber = String.isNotBlank(AccountingUtil.getChartofAccount('Inventory Adjustments')) ? 
											AccountingUtil.getChartofAccount('Inventory Adjustments') : '';
											
		value =  UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+invAdjustmentGLAccNumber+'\t' + amountEntry +'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+GLAccountNumber+'\t' + amountReverseEntry +'\t'+ TaxCode+'\t'+AllocationMemo;
		return value;
	}
	
	public static string PartFIFOActivityCountAdjustItemRec(Part_FIFO_Bucket_Activity_Line_Item__c partFifoActivityLineItemRec){
		UniqueId = partFifoActivityLineItemRec.Unique_Id__c == null ? 
						(partFifoActivityLineItemRec.Part_Adjustment__r.Unique_Id__c != null ? partFifoActivityLineItemRec.Part_Adjustment__r.Unique_Id__c : 
							(partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Unique_Id__c != null ? partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Unique_Id__c
							 : '')) : partFifoActivityLineItemRec.Unique_Id__c;
		CreatedDate = partFifoActivityLineItemRec.CreatedDate!= null ? partFifoActivityLineItemRec.CreatedDate.format(DataExportService.dateFormat) : System.now().format(DataExportService.dateFormat) ;
		FIFOBucketId =  partFifoActivityLineItemRec.Id;
		GLAccountNumber = (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r != null && 
								partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c != null) ? 
									partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c : '';
									
		String invAdjstmntGLAcc = InventoryAdjustmentGLCode;
		String statusUpdateText = '';
		if(String.isBlank(partFifoActivityLineItemRec.Return_VO_Header__c)) {
		Memo = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Part_ID__c+ ';' + 'Count Adjustment';
			statusUpdateText = ' - reduced by ';
		} else {
			invAdjstmntGLAcc = InventoryAccrualCode;
			Memo = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Part_ID__c+ ';' + 'Vendor Return;' + partFifoActivityLineItemRec.Return_VO_Header__r.RMA__c;
			statusUpdateText = ' - returned ';
		}
		
		Amount = ((partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c) * (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Cost__c == null ? 0 : partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Cost__c)).setScale(2, RoundingMode.HALF_UP);
		
		AllocationMemo = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Part_Id__c + statusUpdateText + 
							(partFifoActivityLineItemRec.Qty_Out__c == null? 0 :partFifoActivityLineItemRec.Qty_Out__c).setScale(2, RoundingMode.HALF_UP) + 
							'@$'+ (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.cost__c == null ? 0 : 
									partFifoActivityLineItemRec.Part_FIFO_Bucket__r.cost__c).setScale(2, RoundingMode.HALF_UP);
		
		if(partFifoActivityLineItemRec.Qty_Out__c < 0 && partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Source_Name__c.toLowerCase() == 'oversold'){
			AllocationMemo = partFifoActivityLineItemRec.Part_FIFO_Bucket__r.Part__r.Part_Id__c + ' - resolved oversold of ' + 
							(partFifoActivityLineItemRec.Qty_Out__c == null ? 0 : (-1 * partFifoActivityLineItemRec.Qty_Out__c)).setScale(2, RoundingMode.HALF_UP) + 
								'@$'+ (partFifoActivityLineItemRec.Part_FIFO_Bucket__r.cost__c == null ? 0 : 
										partFifoActivityLineItemRec.Part_FIFO_Bucket__r.cost__c).setScale(2, RoundingMode.HALF_UP);
		}
		
		amountEntry = (Amount > 0) ? (Yes +'\t'+ '$'+Amount) : (No +'\t'+ '$'+(-1 * Amount));
		amountReverseEntry = (Amount > 0) ? (No +'\t'+ '$'+Amount) : (Yes +'\t'+ '$'+(-1 * Amount));
		
		value =  UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+GLAccountNumber+'\t' + amountEntry +'\t'+ TaxCode+'\t'+AllocationMemo+'\n';
		value += UniqueId + '\t' + CreatedDate + '\t'+ Memo+ '\t'+Gst+'\t'+ Inclusive+'\t'+invAdjstmntGLAcc+'\t' + amountReverseEntry +'\t'+ TaxCode+'\t'+AllocationMemo;
		return value;
	}
}