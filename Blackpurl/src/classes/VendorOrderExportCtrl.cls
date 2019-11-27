global with sharing class VendorOrderExportCtrl {
	public String fileContent {get; private set;}
	public String contentType {get; private set;}
	private final String GENERIC = 'Generic';
	private final String PARTS_CANADA = 'Parts Canada';
	private final String HDNET_AUSTRALIA = 'HDnet Australia';
	private final String BOSSWEB = 'BossWeb';

    public VendorOrderExportCtrl() {
    	String voHeaderId = ApexPages.currentPage().getParameters().get('id');
    	String exportType = ApexPages.currentPage().getParameters().get('type');
    	if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

    	List<Vendor_Order_Header__c> voHeaderlist = [SELECT Name, Ordered_Date__c, Purchase_Order_Type__r.Code__c, (SELECT Part__r.Part_Number__c, Part__r.Description__c,
    		Need__c, Part__r.Package_Unit__c, Part__r.Packaged_Part__c, Part__r.Package_Qty__c, Cost__c FROM Vendor_Order_Line_Item_Groups__r where Part__c != null)
    		FROM Vendor_Order_Header__c WHERE Id =: voHeaderId ORDER BY LastModifiedDate Desc];

			system.debug('Export Type: '+exportType);

    	fileContent = '';
    	contentType = exportTypeToContentTypeMap.get(exportType);
    	if(voHeaderlist.size() > 0) {
    		if(exportType == GENERIC) {
	    		generateGenericExportFile(voHeaderlist[0].Vendor_Order_Line_Item_Groups__r);
	    	} else if(exportType == PARTS_CANADA) {
	    		generatePartsCanadaExportFile(voHeaderlist[0].Vendor_Order_Line_Item_Groups__r);
	    	} else if(exportType == HDNET_AUSTRALIA) {
	    		generateHDnetAustraliaExportFile(voHeaderlist[0]);
		    } else if(exportType == BOSSWEB) {
	    		generateBosswebExportFile(voHeaderlist[0].Vendor_Order_Line_Item_Groups__r, voHeaderList);
	    	}
		}
    }

    private Map<String, String> exportTypeToContentTypeMap = new Map<String, String>{
    																					GENERIC => 'text/csv#Vendor Order.csv',
    																					PARTS_CANADA => 'text/csv#Vendor Order.csv',
																						HDNET_AUSTRALIA => 'text/plain/#Vendor Order.txt',
																						BOSSWEB => 'text/plain/#Vendor Order.txt'
    																				};

    private void generateGenericExportFile(List<Vendor_Order_Line_Item_Group__c> voliGroupList) {
    	fileContent += 'Part#,Description,Qty Ordered,Unit Measure,Cost\n';
    	for(Vendor_Order_Line_Item_Group__c voliGroupRec : voliGroupList) {
    		Decimal qtyOrdered = calculatePackagedQty(voliGroupRec.Need__c, voliGroupRec.Part__r);
    		Decimal cost = (voliGroupRec.Cost__c != null) ? voliGroupRec.Cost__c.setScale(2, RoundingMode.HALF_UP) : 0;
    		if(voliGroupRec.Part__r.Packaged_Part__c) {
	        	if(voliGroupRec.Part__r.Package_Qty__c == null) {
	        		voliGroupRec.Part__r.Package_Qty__c = 1;
	        	}
	            cost = (cost * voliGroupRec.Part__r.Package_Qty__c).setScale(2, RoundingMode.HALF_UP);
	        }
    		fileContent += ((voliGroupRec.Part__r.Part_Number__c != null) ? voliGroupRec.Part__r.Part_Number__c.escapeCsv() : '') + ',';
    		fileContent += ((voliGroupRec.Part__r.Description__c != null) ? voliGroupRec.Part__r.Description__c.escapeCsv() : '') + ',';
    		fileContent += String.valueOf(qtyOrdered) + ',';
    		if(String.isNotBlank(voliGroupRec.Part__r.Package_Unit__c)) {
    			fileContent += voliGroupRec.Part__r.Package_Unit__c + ',';
    		} else if(voliGroupRec.Part__r.Packaged_Part__c) {
    			fileContent += 'PKG' + ',';
    		} else {
    			fileContent += 'EA' + ',';
    		}
    		fileContent += String.valueOf(cost) + '\n';
    	}
    }

	private void generatePartsCanadaExportFile(List<Vendor_Order_Line_Item_Group__c> voliGroupList) {
    	fileContent += 'Part#,Qty Ordered\n';
    	for(Vendor_Order_Line_Item_Group__c voliGroupRec : voliGroupList) {
	    	Decimal qtyOrdered = calculatePackagedQty(voliGroupRec.Need__c, voliGroupRec.Part__r);
			fileContent += ((voliGroupRec.Part__r.Part_Number__c != null) ? voliGroupRec.Part__r.Part_Number__c.escapeCsv() : '') + ',';
			fileContent += String.valueOf(qtyOrdered) + '\n';
    	}
    }

	private void generateBosswebExportFile(List<Vendor_Order_Line_Item_Group__c> voliGroupList, List<Vendor_Order_Header__c> voHeaderlist) {
		Vendor_Order_Header__c voHeader = voHeaderlist[0];
		system.debug('voHeader: '+voHeader.name);
		contentType= 'text/plain/#'+voHeader.name+'.txt';
		String tabStr = '\t';
		String lfStr = '\n';

		//fileContent += 'Required Quantity'+tabStr+'Part No'+lfStr;
		fileContent = '';

    	for(Vendor_Order_Line_Item_Group__c voliGroupRec : voliGroupList) {
	    	Decimal qtyOrdered = calculatePackagedQty(voliGroupRec.Need__c, voliGroupRec.Part__r);
			fileContent += String.valueOf(qtyOrdered) + tabStr;
			fileContent += voliGroupRec.Part__r.Part_Number__c +lfStr;
    	}
    }

    private void generateHDnetAustraliaExportFile(Vendor_Order_Header__c voHeader) {
    	String mailBoxId = HDnet_Australia_Config__c.getOrgDefaults().Dealer_Mailbox_Id__c;
    	String orderType = HDnet_Australia_Config__c.getOrgDefaults().Order_Type__c;
    	String shipTo = HDnet_Australia_Config__c.getOrgDefaults().Ship_To__c;

    	if(String.isNotBlank(voHeader.Purchase_Order_Type__r.Code__c)) {
    		if(voHeader.Purchase_Order_Type__r.Code__c.containsIgnoreCase('STANDARD')) {
    			orderType = 'SO';
    		} else if(voHeader.Purchase_Order_Type__r.Code__c.containsIgnoreCase('PREMIUM')) {
    			orderType = 'UU';
    		} else if(voHeader.Purchase_Order_Type__r.Code__c.containsIgnoreCase('LINKED')) {
    			orderType = 'SM';
    		}  else if(voHeader.Purchase_Order_Type__r.Code__c.containsIgnoreCase('DOWN VEHICLE')) {
    			orderType = 'SU';
    		}
    	}
    	// Start: header content
    	String headerTag = 'HEADER';
    	String edicode = 'HDE-NET-EUROPE';
    	edicode += createStringToAppend(' ', 35, edicode.length());

    	String agency = 'C';
    	String version = 'WS10';
    	version += createStringToAppend(' ', 12, version.length());

    	String transactionValue = 'BORDER';
    	String release = '0';
    	String dealerMailBoxId = mailBoxId != null ? mailBoxId : '';
    	dealerMailBoxId = createStringToAppend('0', 8, dealerMailBoxId.length()) + dealerMailBoxId;

    	String testMode = 'P';
    	String currentFormattedDate = DateTime.now().format('YYYYMMdd');
    	String currentFormattedTime = DateTime.now().format('kkmmss');
    	String dealerRefHeader = voHeader.Name != null ? voHeader.Name : '';
    	dealerRefHeader += createStringToAppend(' ', 35, dealerRefHeader.length());

    	String secRefHeader = createStringToAppend(' ', 35, 0);
    	fileContent += headerTag + edicode + agency + version + transactionValue + release + dealerMailBoxId + testMode + currentFormattedDate + currentFormattedTime + dealerRefHeader + secRefHeader + '\r\n';
    	// End: header content

    	// Start: vendor content
    	String vendorTag = '0100';
    	shipTo = shipTo != null ? shipTo : '';
    	shipTo = createStringToAppend('0', 8, shipTo.length()) + shipTo;

    	String dealerRefVendor = voHeader.Name != null ? voHeader.Name : '';
    	dealerRefVendor += createStringToAppend(' ', 25, dealerRefVendor.length());

    	orderType = orderType != null ? orderType : '';
    	orderType += createStringToAppend(' ', 2, orderType.length());

    	String vinNumber = createStringToAppend(' ', 18, 0);
    	String error = createStringToAppend(' ', 30, 0);
    	String reqDate = voHeader.Ordered_Date__c != null ? datetime.newInstance(voHeader.Ordered_Date__c.year(), voHeader.Ordered_Date__c.month(), voHeader.Ordered_Date__c.day()).format('YYYYMMdd') : currentFormattedDate;
    	String headerNote = createStringToAppend(' ', 59, 0);

    	fileContent += vendorTag + shipTo + dealerRefVendor + orderType + vinNumber + error + reqDate + headerNote + '\r\n';
    	// End: vendor content

    	// Start: line item content
    	for(Vendor_Order_Line_Item_Group__c voliGroupRec : voHeader.Vendor_Order_Line_Item_Groups__r) {
	    	String lineItemTag = '0101';
	    	String partId = voliGroupRec.Part__r.Part_Number__c != null ? voliGroupRec.Part__r.Part_Number__c : '';
	    	if(partId.length() > 20) {
	    		partId = partId.substring(0, 20);
	    	} else {
	    		partId += createStringToAppend(' ', 20, partId.length());
	    	}

	    	Decimal qtyOrdered = calculatePackagedQty(voliGroupRec.Need__c, voliGroupRec.Part__r);
	    	String qtyOrderedStr = String.valueOf(qtyOrdered);
	    	qtyOrderedStr = createFormattedStringForQtyOrdered(qtyOrderedStr);
	    	qtyOrderedStr = createStringToAppend('0', 5, qtyOrderedStr.length()) + qtyOrderedStr;

	    	String linkOrd = createStringToAppend(' ', 30, 0);
	    	String lineItemNote = createStringToAppend(' ', 49, 0);

	    	fileContent += lineItemTag + shipTo + partId + qtyOrderedStr + linkOrd + error + reqDate + lineItemNote + '\r\n';
    	}
    	// End: line item content

    	// Start: footer content
    	String trailerTag = 'TRAILER';
    	fileContent += trailerTag;
    	// End: footer content
    }

    private String createStringToAppend(String chracterToAdd, Integer maxLength, Integer currentLength) {
    	String str = '';
    	if(currentLength < maxLength) {
    		Integer noOfChars = maxLength - currentLength;
    		if(noOfChars > 0) {
    			for(Integer i=0; i<noOfChars; i++) {
					str += chracterToAdd;
				}
    		}
    	}
		return str;
    }

    private String createFormattedStringForQtyOrdered(String qtyOrdered) {
    	List<String> splittedString = qtyOrdered.split('\\.');
    	if(splittedString.size() == 2) {
    		List<String> splittedSubString = splittedString[1].split('');
    		if(splittedSubString.size() > 0) {
    			for(Integer i=splittedSubString.size()-1; i>=0; i--) {
    				String strToAppend = '';
    				if(Integer.valueOf(splittedSubString[i]) == 0) {
    					strToAppend = splittedString[1].subString(0, i);
    				} else {
    					break;
    				}
    				qtyOrdered = splittedString[0] + (strToAppend.length() > 0 ? ('.' + strToAppend) : strToAppend);
    			}
    		}
    	}
		return qtyOrdered;
    }

    private Decimal calculatePackagedQty(Decimal need, Part__c partRec) {
    	Decimal qtyOrdered = need != null ? need : 0;
    	if(partRec.Packaged_Part__c) {
        	if(partRec.Package_Qty__c == null) {
        		partRec.Package_Qty__c = 1;
        	}
            qtyOrdered = qtyOrdered / partRec.Package_Qty__c;
        }
        return qtyOrdered;
    }
}