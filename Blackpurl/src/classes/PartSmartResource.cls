/**
 * Author: Rajat Jain
 * Since: Oct 3, 2018
 * Name: PartSmartResource
 * Description: PartSmartResource class for part smart.
**/
@RestResource(urlMapping='/bp/PartDetail/*')
global with sharing class PartSmartResource {
	public static final String Version = '$V 4.00 ### ';
	public static Map<String, String> partsmartToBPVendorCodeMap = new Map<String, String>();
	public static Map<String,String> partNumberToIdentiferMap = new Map<String,String>();
	public static Set<String> partNumberFound = new Set<String>();
	public static Set<String> partNumberNotFound = new Set<String>();
    public static List<String> keyToBeSorted = new List<String>{'E', 'B', 'C', 'I', 'S', 'D', 'M', 'O', 'P', 'R'};
    
    @HttpPost
    global static String getPartDetailByPartNumber(RequestWrapper request) {
    	String responseObj = Version ;
    	populateVendorCode();
    	Set<String> partNumberList = getPartNumberList(request);
        List<Part__c> partDetailList = [Select Id, Part_Number__c, Description__c, Vendor_Code__c, MSRP__c,Location__c, Auto_reorder_Min__c, Qty_Committed__c, Qty_In_Stock__c, Retail_Price__c, Average_Cost__c, Total_Cost__c from Part__c where Part_Id__c IN :partNumberList];
		responseObj = populateResponseObjectForPartNumberFound(partDetailList, responseObj);
		responseObj = populateResponseObjectForPartNumberNotFound(responseObj);
		
		return (responseObj != null && responseObj != Version ? responseObj : 'No Part Found');
    }
    
    private static String populateResponseObjectForPartNumberNotFound(String responseObject) {
    	for(String partNumber : partNumberToIdentiferMap.keySet()) {
			String identifier = partNumberToIdentiferMap.get(partNumber);
			if(!partNumberFound.contains(partNumber)) {
				partNumberNotFound.add(partNumber);
				responseObject += ('# ' +partNumber + 'Not Found ### ');
			}
		}
		return responseObject;
    }
    
    private static String populateResponseObjectForPartNumberFound(List<Part__c> partDetailList, String responseObject) {
		if(partDetailList.size() > 0) {
			PartDetailWrapper partDetailObj;
	        for(Part__c partInfo : partDetailList) {
	        	partDetailObj = new PartDetailWrapper(partInfo);
	        	partNumberFound.add(partDetailObj.I);
				Map<String, Object> partDetailKeyToValueMap = (Map<String, Object>) JSON.deserializeUntyped(system.Json.serialize(partDetailObj));
				String identifier = partNumberToIdentiferMap.get(partDetailObj.I);
				
				for(String key : keyToBeSorted) {
					if(partDetailKeyToValueMap.containsKey(key)) {
						if(key == 'E') {
							responseObject += (identifier.toUpperCase() + key + ' ' + partDetailKeyToValueMap.get(key) + ' ### ');
						} else {
							responseObject += (identifier + key + ' ' + partDetailKeyToValueMap.get(key) + ' ### ');
						}
					}
				}
	        }
		}
		return responseObject;
    }
    
    private static void populateVendorCode() {
    	List<Partsmart_To_BP_Vendor_Code_Mapping__c> vendorCodeMappingList = [SELECT Id, Name, BP_Vendor_Code__c FROM Partsmart_To_BP_Vendor_Code_Mapping__c];
    	for(Partsmart_To_BP_Vendor_Code_Mapping__c vendorCodeObj : vendorCodeMappingList) {
    		partsmartToBPVendorCodeMap.put(vendorCodeObj.Name, vendorCodeObj.BP_Vendor_Code__c);
    	}
    }
    
    private static Set<String> getPartNumberList(RequestWrapper request) {
    	Set<String> partNumberList= new Set<String>();
    	String partId ='';
    	if(request.requestData.size() > 0){
    		for(Map<String,String> requestDataMap: request.requestData) {
    			for(String requestData : requestDataMap.keySet()) {
    				if(requestData == 'dP') {
    					partId = requestDataMap.get('dP') + partsmartToBPVendorCodeMap.get(requestDataMap.get('dM'));
    					partNumberToIdentiferMap.put(requestDataMap.get('dP'), 'd');
    				} else if(requestData == 'sI') {
    					partId = requestDataMap.get('sI') + partsmartToBPVendorCodeMap.get(requestDataMap.get('SE'));
    					partNumberToIdentiferMap.put(requestDataMap.get('sI'), 's');
    				} else if(requestData == 'tI') {
    					partId = requestDataMap.get('tI') + partsmartToBPVendorCodeMap.get(requestDataMap.get('TE'));
    					partNumberToIdentiferMap.put(requestDataMap.get('tI'), 't');
    				}
    				if(requestData == 'dP' || requestData == 'sI' || requestData == 'tI' ) {
    					partNumberList.add(partId);
    				}
    			}
    		}
    	} 
    	return partNumberList;
    }
    
    global class RequestWrapper {
		Map<String, String> header ;
		List<Map<String, String>> requestData ;	
	}
	
    public class PartDetailWrapper {
    	String E;//VendorCode
    	Decimal C;//dealer cost => avg cost
    	String B;
    	String D;//description
    	Decimal M;//minimum => auto-reorder-minimum
    	Decimal O;//on hand => in stock
    	Decimal P;//price => Retail_Price__c
    	Decimal R;//Reserved Quantity => Qty committed
    	Decimal S;//Reserved Quantity => Qty committed
    	String I;
    	
    	public PartDetailWrapper(Part__c partDetail) { 
    		this.E = partDetail.Vendor_Code__c;
    		this.B = String.isNotBlank(partDetail.Location__c) ? partDetail.Location__c : '';
    		this.C = Integer.valueOf((partDetail.Average_Cost__c != null ?  partDetail.Average_Cost__c  * 100 : 0 ));
    		this.S = Integer.valueOf((partDetail.MSRP__c != null ?  partDetail.MSRP__c  * 100 : 0 ));
    		this.D = partDetail.Description__c;
    		this.M = Integer.valueOf(partDetail.Auto_reorder_Min__c);
    		this.O = Integer.valueOf(partDetail.Qty_In_Stock__c);
    		this.P = Integer.valueOf((partDetail.Retail_Price__c != null ?  partDetail.Retail_Price__c * 100 : 0 ));
    		this.R = Integer.valueOf(partDetail.Qty_Committed__c);
    		this.I = partDetail.Part_Number__c;
    	}
    	
    }
}