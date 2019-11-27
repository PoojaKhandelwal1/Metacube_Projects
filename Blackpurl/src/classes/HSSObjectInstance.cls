public with sharing class HSSObjectInstance implements Comparable{
    public sObject record {get; private set;}
    
    public HSSObjectInstance(sObject record){
        this.record = record;
    }
    
    // Compare opportunities based on the opportunity amount.
    public Integer compareTo(Object compareToObj) {
        HSSObjectInstance compareToWrapper = (HSSObjectInstance)compareToObj;
        sObject compareTo = compareToWrapper.record;
        //System.assert(false, String.valueOf(record.get('Id'))  + '   ' + String.valueOf(compareTo.get('Id')));
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        
        // Object names
        String comparableObjName = String.valueOf(record.getSObjectType());
        String compareToObjName = String.valueOf(compareTo.getSObjectType());
        
        //system.assert(false, HomeSearchUtil.sortMapping);
        List<SortByMapping> sortMapping = new List<SortByMapping>();
        if(HomeSearchUtil.sortMapping != null) { 
            for(PaginationSorting.SortAttrs sm : HomeSearchUtil.sortMapping) { 
                sortMapping.add(new SortByMapping(sm.FieldName, sm.SortDirection, sm.Type));
            }
        }
        //system.assert(false, '@@@@@\n\n' + sortMapping);
        for(SortByMapping sortField : sortMapping){
            Integer fieldCompareResult = 0;
            
            if( sortField.fieldName != null && returnValue == 0){
                String comapreableFieldName = getSortFieldNameForObject(comparableObjName, sortField.FieldName);
                //system.assert(false, comapreableFieldName + '  ' + comparableObjName + '  ' + sortField.FieldName);
                List<String> comapreableOwnerFields = comapreableFieldName.split('\\.');
                
                String comapreToFieldName = getSortFieldNameForObject(compareToObjName, sortField.FieldName);
                List<String> comapreToOwnerFields = comapreToFieldName.split('\\.');
                
                System.debug('@#@#@#@#\n\n' + comparableObjName + '\n' + comapreableFieldName + '\n' + comapreableOwnerFields);
                System.debug('@#@#@#@#\n\n' + compareToObjName + '\n' + comapreToFieldName + '\n' + comapreToOwnerFields);
                
                if(sortField.Type == 'Number' || sortField.Type == 'Currency') {
                    Decimal comparableFieldValue = 0;
                    Decimal comapreToFieldValue = 0;
                    
                    // Comaparable Field
                    if( comapreableFieldName.contains('CreatedBy') ){
                        if(comapreableOwnerFields.size() == 1) {
                            comparableFieldValue = convertStringToDecimal(String.valueOf(record.get(comapreableOwnerFields[0])));
                        } else if(comapreableOwnerFields.size() == 2 && record.getSObject(comapreableOwnerFields[0]) != null) {
                            comparableFieldValue = convertStringToDecimal(String.valueOf(record.getSObject(comapreableOwnerFields[0]).get(comapreableOwnerFields[1])));
                        }
                    } /*else if( !comapreableFieldName.contains('Owner') ){
                        comparableFieldValue = convertStringToDecimal(String.valueOf(record.get(comapreableFieldName)));
                    } */else if(comapreableOwnerFields.size() == 1 && String.isNotBlank(comapreableOwnerFields[0])) {
                        comparableFieldValue = convertStringToDecimal(String.valueOf(record.get(comapreableOwnerFields[0])));
                    } else if(comapreableOwnerFields.size() == 2) {
                        if(record.getSObject(comapreableOwnerFields[0]) != null) {
                            comparableFieldValue = convertStringToDecimal(String.valueOf(record.getSObject(comapreableOwnerFields[0]).get(comapreableOwnerFields[1])));
                        }
                    } else if(comapreableOwnerFields.size() == 3){
                        if(record.getSObject(comapreableOwnerFields[0]) != null && record.getSObject(comapreableOwnerFields[0]).getSObject(comapreableOwnerFields[1]) != null) {
                            comparableFieldValue = convertStringToDecimal(String.valueOf(record.getSObject(comapreableOwnerFields[0]).getSObject(comapreableOwnerFields[1]).get(comapreableOwnerFields[2])));
                        }
                    }
                    
                    // Compare To Field
                    /*if( !comapreToFieldName.contains('Owner') ){
                        comapreToFieldValue = convertStringToDecimal(String.valueOf(compareTo.get(comapreToFieldName)));
                    } else */if(comapreToOwnerFields.size() == 1 && String.isNotBlank(comapreToOwnerFields[0])) {
                        comapreToFieldValue = convertStringToDecimal(String.valueOf(compareTo.get(comapreToOwnerFields[0])));
                    } else if(comapreToOwnerFields.size() == 2) {
                        if(compareTo.getSObject(comapreToOwnerFields[0]) != null) {
                            comapreToFieldValue = convertStringToDecimal(String.valueOf(compareTo.getSObject(comapreToOwnerFields[0]).get(comapreToOwnerFields[1])));
                        }
                    } else if(comapreToOwnerFields.size() == 3){
                        if(compareTo.getSObject(comapreToOwnerFields[0]) != null && compareTo.getSObject(comapreToOwnerFields[0]).getSObject(comapreToOwnerFields[1]) != null) {
                            comapreToFieldValue = convertStringToDecimal(String.valueOf(compareTo.getSObject(comapreToOwnerFields[0]).getSObject(comapreToOwnerFields[1]).get(comapreToOwnerFields[2])));
                        }
                    }
                    
                    if( comparableFieldValue > comapreToFieldValue ){
                        fieldCompareResult = 1;
                    } else if( comparableFieldValue < comapreToFieldValue ){
                        fieldCompareResult = -1;
                    }
                    
                    if(sortField.direction == 'DESC'){
                        fieldCompareResult *= -1;
                    }
                    
                    returnValue += fieldCompareResult;
                    
                    
                } else {
                
                    String comparableFieldValue = '';
                    String comapreToFieldValue = '';
                    
                    // Comaparable Field
                    system.debug('12312312312 ' + comparableObjName);
                    if(comapreableFieldName.contains('Type') && HomeSearchUtil.displayObjectAPINameToObjectNameMap.containsKey(comparableObjName)) {
                        comparableFieldValue = HomeSearchUtil.displayObjectAPINameToObjectNameMap.get(comparableObjName);
                        if(comparableObjName == 'Account'){
                            if(record.get(CONSTANTS.NAMESPACE + 'Is_Customer__c') == true){
                                comparableFieldValue = 'Customer';
                            }else{
                                comparableFieldValue = 'Vendor';
                            }
                        } 
                        if(comparableObjName == CONSTANTS.NAMESPACE + 'CO_Line_Item__c' || comparableObjName == CONSTANTS.NAMESPACE + 'Service_Order_Line_Item__c' || 
                        	comparableObjName == CONSTANTS.NAMESPACE + 'Option_Fee__c') {
                        	comparableFieldValue = getTypeNameForInvoicedItem(comparableObjName, record);
                        }
                        
                    } else if( comapreableFieldName.contains('CreatedBy') ){
                        if(comapreableOwnerFields.size() == 1) {
                            comparableFieldValue = String.valueOf(record.get(comapreableOwnerFields[0]));
                        } else if(comapreableOwnerFields.size() == 2 && record.getSObject(comapreableOwnerFields[0]) != null) {
                            comparableFieldValue = String.valueOf(record.getSObject(comapreableOwnerFields[0]).get(comapreableOwnerFields[1]));
                        }
                    } /*else if( !comapreableFieldName.contains('Owner') ){
                        comparableFieldValue = String.valueOf(record.get(comapreableFieldName));
                    } */else if(comapreableOwnerFields.size() == 1 && String.isNotBlank(comapreableOwnerFields[0])) {
                        System.debug('HItesh Ka Debug\n' + record.get(comapreableOwnerFields[0]));
                        comparableFieldValue = String.valueOf(record.get(comapreableOwnerFields[0]));
                    } else if(comapreableOwnerFields.size() == 2) {
                        if(record.getSObject(comapreableOwnerFields[0]) != null) {
                            comparableFieldValue = String.valueOf(record.getSObject(comapreableOwnerFields[0]).get(comapreableOwnerFields[1]));
                        }
                    } else if(comapreableOwnerFields.size() == 3){
                        System.debug('$$$$$$\n' + record.getSObject(comapreableOwnerFields[0]));
                        System.debug('%%%%%%\n' + record.getSObject(comapreableOwnerFields[0]).getSObject(comapreableOwnerFields[1]));
                        if(record.getSObject(comapreableOwnerFields[0]) != null && record.getSObject(comapreableOwnerFields[0]).getSObject(comapreableOwnerFields[1]) != null) {
                            comparableFieldValue = String.valueOf(record.getSObject(comapreableOwnerFields[0]).getSObject(comapreableOwnerFields[1]).get(comapreableOwnerFields[2]));
                        }
                    }
                    
                    // Compare To Field
                    /*if( !comapreToFieldName.contains('Owner') ){
                        comapreToFieldValue = String.valueOf(compareTo.get(comapreToFieldName));
                    } else */
                    if(comapreToFieldName.contains('Type') && HomeSearchUtil.displayObjectAPINameToObjectNameMap.containsKey(compareToObjName)) {
                        comapreToFieldValue = HomeSearchUtil.displayObjectAPINameToObjectNameMap.get(compareToObjName);
                        if(compareToObjName == 'Account'){
                            if(compareTo.get(CONSTANTS.NAMESPACE + 'Is_Customer__c') == true){
                                comapreToFieldValue = 'Customer';
                            }else{
                                comapreToFieldValue = 'Vendor';
                            }
                        }
                        if(compareToObjName == CONSTANTS.NAMESPACE + 'CO_Line_Item__c' || compareToObjName == CONSTANTS.NAMESPACE + 'Service_Order_Line_Item__c' || 
                        	compareToObjName == CONSTANTS.NAMESPACE + 'Option_Fee__c') {
                        	comapreToFieldValue = getTypeNameForInvoicedItem(compareToObjName, compareTo);
                        }
                        
                    } else if(comapreToOwnerFields.size() == 1 && String.isNotBlank(comapreToOwnerFields[0])) {
                        comapreToFieldValue = String.valueOf(compareTo.get(comapreToOwnerFields[0]));
                    } else if(comapreToOwnerFields.size() == 2) {
                        if(compareTo.getSObject(comapreToOwnerFields[0]) != null) {
                            comapreToFieldValue = String.valueOf(compareTo.getSObject(comapreToOwnerFields[0]).get(comapreToOwnerFields[1]));
                        }
                    } else if(comapreToOwnerFields.size() == 3){
                        if(compareTo.getSObject(comapreToOwnerFields[0]) != null && compareTo.getSObject(comapreToOwnerFields[0]).getSObject(comapreToOwnerFields[1]) != null) {
                            comapreToFieldValue = String.valueOf(compareTo.getSObject(comapreToOwnerFields[0]).getSObject(comapreToOwnerFields[1]).get(comapreToOwnerFields[2]));
                        }
                    }
                    
                    if( comparableFieldValue > comapreToFieldValue ){
                        fieldCompareResult = 1;
                    } else if( comparableFieldValue < comapreToFieldValue ){
                        fieldCompareResult = -1;
                    }
                    
                    if(sortField.direction == 'DESC'){
                        fieldCompareResult *= -1;
                    }
                    
                    returnValue += fieldCompareResult;
                }
            }
        }
        
        if(returnValue > 0){
            return 1;
        } else if(returnValue < 0){
            return -1;
        }
        
        return returnValue;       
    }
    
    private static String getTypeNameForInvoicedItem(String objectAPIName, sObject record) {
    	String fieldValue = '';
    	if(objectAPIName == CONSTANTS.NAMESPACE + 'CO_Line_Item__c' || objectAPIName == CONSTANTS.NAMESPACE + 'Service_Order_Line_Item__c' || 
        	objectAPIName == CONSTANTS.NAMESPACE + 'Option_Fee__c' ) {
        	if(record.get(CONSTANTS.NAMESPACE + 'Part__c') != null) {
        		fieldValue = 'Part';
        	} else if(record.get(CONSTANTS.NAMESPACE + 'Fee__c') != null) {
        		fieldValue = 'Fee';
        	}
        } 
        if(String.isBlank(fieldValue) && (objectAPIName == CONSTANTS.NAMESPACE + 'Service_Order_Line_Item__c' || 
        								objectAPIName == CONSTANTS.NAMESPACE + 'Option_Fee__c')) {
        	if(record.get(CONSTANTS.NAMESPACE + 'Labour_Code__c') != null) {
        		fieldValue = 'Labour Code';
        	}
        } 
        if(String.isBlank(fieldValue) && objectAPIName == CONSTANTS.NAMESPACE + 'Service_Order_Line_Item__c' && 
        										record.get(CONSTANTS.NAMESPACE + 'Sublet__c') != null) {
    		fieldValue = 'Sublet';
        } 
		if(String.isBlank(fieldValue) && objectAPIName == CONSTANTS.NAMESPACE + 'Option_Fee__c' && 
										record.get(CONSTANTS.NAMESPACE + 'Product__c') != null) {
        	if(String.valueOf(record.getSobject(CONSTANTS.NAMESPACE + 'Product__r').get(CONSTANTS.NAMESPACE + 'Type__c')) == 'Sublet') {
        		fieldValue = 'Sublet';
        	} else if(String.valueOf(record.getSobject(CONSTANTS.NAMESPACE + 'Product__r').get(CONSTANTS.NAMESPACE + 'Type__c')) == 'Warranty Plan') {
        		fieldValue = 'Warranty Plan';
        	} else {
        		fieldValue = 'Other Product';
        	}
        }
        return fieldValue;
    }
    
    
    private static Decimal convertStringToDecimal(String str) {
        return (str != null) ? Decimal.valueOf(str) : 0;        
    }
    
    private static String getSortFieldNameForObject(String objName, String fieldLabel) {
        String fieldAPIName;
        system.debug('objName' + objName + '    fieldLabel ' + fieldLabel);
        if(String.isNotBlank(CONSTANTS.NAMESPACE) && objName.contains(CONSTANTS.NAMESPACE)) {
            objName = objName.replace(CONSTANTS.NAMESPACE, '');
        }
        if(fieldLabel != null 
            && HomeSearchUtil.searchableObjectToFieldsMap.containsKey(objName) 
            && HomeSearchUtil.searchableObjectToFieldsMap.get(objName).contains(fieldLabel)
        ){
            fieldAPIName = fieldLabel;
        } else if(fieldLabel != null 
                    && HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.containsKey(HomeSearchUtil.implementNameSpace(objName)) 
                    && HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.get(HomeSearchUtil.implementNameSpace(objName)).containsKey(fieldLabel)
                ) {
            fieldAPIName = HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.get(HomeSearchUtil.implementNameSpace(objName)).get(fieldLabel);
        } else if(fieldLabel != null &&
                    HomeSearchUtil.groupFieldNameToObjAPINameToFieldAPINameMap.containsKey(fieldLabel) &&
                    HomeSearchUtil.groupFieldNameToObjAPINameToFieldAPINameMap.get(fieldLabel).containsKey(objName)) {
            
            fieldAPIName = HomeSearchUtil.groupFieldNameToObjAPINameToFieldAPINameMap.get(fieldLabel).get(objName);
        } else if(fieldLabel != null && fieldLabel == 'Type') {
            fieldAPIName = fieldLabel;
        } else if(fieldLabel != null
	        	&& HomeSearchUtil.objectNameToCommonApiToAPINameMap.containsKey(objName) 
	            && HomeSearchUtil.objectNameToCommonApiToAPINameMap.get(objName).containsKey(fieldLabel)) {
        	fieldAPIName = HomeSearchUtil.objectNameToCommonApiToAPINameMap.get(objName).get(fieldLabel);
        }
        system.debug(fieldAPIName); 
        return (fieldAPIName != null) ? fieldAPIName : '';
    }
    
    /**
     * Name: SortByMapping Class
     * Desc: Class used for JSON objects in sorting
    **/
    public class SortByMapping {
        public String FieldName {get; set;}
        public String Direction {get; set;}
        public String Type {get; set;}
        
        public SortByMapping(String FieldName, String Direction, String dataType){
            this.FieldName = FieldName;
            this.Direction = Direction;
            this.Type = dataType;
        }
    }
}