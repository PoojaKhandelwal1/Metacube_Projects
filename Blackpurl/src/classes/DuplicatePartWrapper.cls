/**
 * Author: Tarun Khandelwal
 * Since: Jan 25, 2017
 * Name: DuplicatePartWrapper
 * Description: Class is used for the Creating Json For Duplicate Parts
**/
public with sharing class DuplicatePartWrapper {
    
	public Decimal Qty;
	public String SectionName;
   
   	public DuplicatePartWrapper(CO_Line_Item__c coliRec) {
   		if(coliRec.Service_Order_Line_Item__c == null) {
	   		this.Qty = coliRec.Qty__c;
	   		this.SectionName = 'Merchandise';
	   		if(coliRec.Deal__c != null) {
	   			this.SectionName = 'Deal Merchandise';
	   		}
   		} else {
   			this.Qty = coliRec.Service_Order_Line_Item__r.Qty_Needed__c;
   			this.SectionName = coliRec.Service_Order_Line_Item__r.Service_Order_Header__r.Name__c;
   		}
   	}
   	
   	public DuplicatePartWrapper(Option_Fee__c optionFeeRec) {
   		this.Qty = optionFeeRec.Qty__c;
   		this.SectionName = 'Deal : ' + optionFeeRec.Deal_Item__r.Name__c + ' Options & Fees';
   	}
}