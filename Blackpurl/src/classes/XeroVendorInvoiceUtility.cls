public without sharing class XeroVendorInvoiceUtility {
    public static List<XeroLineItemDTO> setAllInvoiceItemRec(AccountingVendorInvoice vendorInvoiceRecord) {
        
        Map<Id, List<AccountingFIFOBucket>> partIdToFIFOBucketMap = new Map<Id, List<AccountingFIFOBucket>>();
        for(AccountingFIFOBucket partFIFOBucketRec : vendorInvoiceRecord.AccountingPartFIFOBucketList) {
            if(!partIdToFIFOBucketMap.containsKey(partFIFOBucketRec.PartId)) {
                partIdToFIFOBucketMap.put(partFIFOBucketRec.PartId,new List<AccountingFIFOBucket>());
            }
            partIdToFIFOBucketMap.get(partFIFOBucketRec.PartId).add(partFIFOBucketRec);
        }
        
        List<XeroLineItemDTO> xeroInvoiceLineItemDtoList = new List<XeroLineItemDTO>();
        
	    for(AccountingVendorInvoice.AccountingVIGroup viGroupRec : vendorInvoiceRecord.AccountingVIGroupsList) {
	        /*default line item*/
	        xeroInvoiceLineItemDtoList.add(new XeroLineItemDTO(viGroupRec, vendorInvoiceRecord.AppliedQBTaxCode, vendorInvoiceRecord.AppliedTaxRate));
	        
	        
	        /*variance Line Item*/
	        Boolean isVariance = false;
	        isVariance = viGroupRec.DiscountAmout != 0 ? true : ( viGroupRec.InvoiceCost != viGroupRec.ReceivingCost ? true : false);
	        if(isVariance) {
	            //add cost variance line items here
	            Decimal totalCostVariance = viGroupRec.InvoiceTotalQty * (viGroupRec.ReceivingCost - viGroupRec.InvoiceCostMinusDiscount);
	            xeroInvoiceLineItemDtoList.add(
	               new XeroLineItemDTO(viGroupRec.ItemDesc+';Receiving Adjustment', 1, totalCostVariance, AccountingUtil.getChartofAccount('A/P Inventory Accrual'), QBUtil.nonTaxablePurchaseCodeAccId)
	            );
	            xeroInvoiceLineItemDtoList.add(
                   new XeroLineItemDTO(viGroupRec.ItemDesc+';Inventory Adjustment', 1, -1 * totalCostVariance, viGroupRec.Inventory_GL, QBUtil.nonTaxablePurchaseCodeAccId)
                );
	        }
	        
	        /* 
	        * sold on CO before vendor invoicing 
	        */
	        Decimal totalQtyOut = 0;
	        if(partIdToFIFOBucketMap.containsKey(viGroupRec.PartId)) {
                for(AccountingFIFOBucket PartFIFOBucketRec : partIdToFIFOBucketMap.get(viGroupRec.PartId)) {
                    totalQtyOut += PartFIFOBucketRec.QtyOut;
                }
            }
            
            /*part*/
            if(isVariance && totalQtyOut > 0) {
                Decimal totalQtyOutVariance = totalQtyOut * (viGroupRec.ReceivingCost - viGroupRec.InvoiceCostMinusDiscount);
                xeroInvoiceLineItemDtoList.add(
                   new XeroLineItemDTO(viGroupRec.ItemDesc+';pre-sold Cost Adjustment', 1, totalQtyOutVariance, viGroupRec.Inventory_GL, QBUtil.nonTaxablePurchaseCodeAccId)
                );
                xeroInvoiceLineItemDtoList.add(
                   new XeroLineItemDTO(viGroupRec.ItemDesc+';pre-sold Cost Adjustment', 1, -1 * totalQtyOutVariance, viGroupRec.COGS_GL, QBUtil.nonTaxablePurchaseCodeAccId)
                );
            }
            
            /*sublet*/
            if(viGroupRec.SubletId != null && isVariance && viGroupRec.IsReceivingGroupSOLIInvoiced) {
                    //need to check when same sublet is required by different CO, then if they are received together otherwise this code works perfectly
                Decimal totalSoldQtyVariance = viGroupRec.ReceivingQty * (viGroupRec.ReceivingCost - viGroupRec.InvoiceCostMinusDiscount);
                xeroInvoiceLineItemDtoList.add(
                   new XeroLineItemDTO(viGroupRec.ItemDesc+';pre-sold Cost Adjustment', 1, totalSoldQtyVariance, viGroupRec.Inventory_GL, QBUtil.nonTaxablePurchaseCodeAccId)
                );
                xeroInvoiceLineItemDtoList.add(
                   new XeroLineItemDTO(viGroupRec.ItemDesc+';pre-sold Cost Adjustment', 1, -1 * totalSoldQtyVariance, viGroupRec.COGS_GL, QBUtil.nonTaxablePurchaseCodeAccId)
                );
            }
            
	    }
	    
	    /*other charges handling*/
        for(AccountingVendorInvoice.OtherChargesWrapper otherChargesRec : vendorInvoiceRecord.AccountingOtherChargesList) {
            otherChargesRec.Cost = otherChargesRec.Cost != null ? otherChargesRec.Cost : 0;
            if(otherChargesRec.IsTaxable) {
                xeroInvoiceLineItemDtoList.add(
                    new XeroLineItemDTO('Other Charge;'+otherChargesRec.ItemDesc, 1, otherChargesRec.Cost, otherChargesRec.CategoyRef, vendorInvoiceRecord.AppliedQBTaxCode)
                );
            } else {
                xeroInvoiceLineItemDtoList.add(
                    new XeroLineItemDTO('Other Charge;'+otherChargesRec.ItemDesc, 1, otherChargesRec.Cost, otherChargesRec.CategoyRef, QBUtil.nonTaxablePurchaseCodeAccId)
                );
            }
        }
        return xeroInvoiceLineItemDtoList;
    }
    
    public static List<XeroLineItemDTO> setAllInvoiceItemRec(AccountingVendorReturn vendorReturn) {
        List<XeroLineItemDTO> xeroInvoiceLineItemDtoList = new List<XeroLineItemDTO>();
        for(AccountingVendorReturn.ReturnVoLineItemWrapper returnVOLI : vendorReturn.ReturnVOLIList) {
            xeroInvoiceLineItemDtoList.add(new XeroLineItemDTO(returnVOLI, vendorReturn.TaxCodeAccountingId));
            
            Decimal variance = ((returnVOLI.ReturnQty * returnVOLI.ItemCost) - returnVOLI.InventoryCost);
            String description = returnVOLI.ItemDescription;
            if(variance != 0) {
                xeroInvoiceLineItemDtoList.add(new XeroLineItemDTO(description+';Return Cost Variance', 1, -1 * variance,  AccountingUtil.getChartofAccount('A/P Inventory Accrual'), QBUtil.nonTaxablePurchaseCodeAccId, 0));
                xeroInvoiceLineItemDtoList.add(new XeroLineItemDTO(description+';Return Inventory Adjustment', 1, variance,  AccountingUtil.getChartofAccount('Inventory Adjustments'), QBUtil.nonTaxablePurchaseCodeAccId, 0));
            } 
        }
        return xeroInvoiceLineItemDtoList;
    }
    
     public static List<XeroLineItemDTO> setAllInvoiceItemRec(AccountingUnit unitRecord) {
        List<XeroLineItemDTO> xeroInvoiceLineItemDtoList = new List<XeroLineItemDTO>();
            xeroInvoiceLineItemDtoList.add(new XeroLineItemDTO(unitRecord));
        return xeroInvoiceLineItemDtoList;
    }
}