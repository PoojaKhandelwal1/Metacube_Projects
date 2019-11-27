public with sharing class GenericSearchUtil {
    
    public static final Integer MAX_RECORDS_TO_DISPLAY = 10;
    public static final Integer MIN_SEARCH_CHAR_TO_SEARCH = 3;
    
    public static List<String> matchingCriteriaPriorityList = new List<String>{'Exact', 'StartsWith', 'Contains'};
    
    public static map<String, String> objectNameToObjectDisplayLabel = new map<String, String>{
                                                                            'Customer' => Label.Customer_Object_Display_Label,
                                                                            'Vendor' => Label.Vendor_Object_Display_Label,
                                                                            'Part__c' => Label.Part_Object_Display_Label,
                                                                            'Labour_Code__c' => Label.Labour_Object_Display_Label,
                                                                            'Kit_Header__c' => Label.Kit_Object_Display_Label,
                                                                            'Fee__c' => Label.Fee_Object_Display_Label,
                                                                            'Customer_Owned_Unit__c' => 'Unit',
                                                                            'Product__c' => 'Product'
                                                                        };
                                                                        
    public static String getObjectAPIName(String objectLabel) {
        String objectApiName = objectLabel;
        if(objectLabel == 'Customer' || objectLabel == 'Vendor') {
            objectApiName = 'Account';
        }
        return objectApiName;
    }
    
    public class QueryJSON {
        public String ObjectLabel;
        public String SearchText;
        public String SearchableObjects;
        public Boolean IsSpecialSearch;
        public List<FilterJSON> FilterValues;
    }
    
    public class FilterJSON {
        public String Field;
        public String Operator;
        public String Value;
        public String FilterObject;
        
        public FilterJSON(String Field, String operator, String value, String filterObject){
            this.Field = Field;
            this.Operator = operator;
            this.Value = value;
            this.FilterObject = filterObject;
         }
    }
    
    public class FieldFilter {
        public String FieldName;
        public String Operator;
        public Object FieldValue;
        
        public FieldFilter(String fieldName, String operator, Object value){
            this.FieldName = fieldName;
            this.Operator = operator;
            this.FieldValue = value;
         }
    }
    
    public class SearchedSObjectWrapper implements Comparable {
        public SObject SearchedObj;
        public Decimal PriorityValue;
        Public String objectName;
        
        public SearchedSObjectWrapper(SObject searchedObj, Decimal priorityNumber, String objectName) {
            this.SearchedObj = searchedObj;
            this.PriorityValue = priorityNumber;
            this.objectName = objectName;
        } 
        
        public Integer compareTo(Object compareTo) {
            SearchedSObjectWrapper compareToWrapperObj = ((SearchedSObjectWrapper)compareTo);
            Integer returnValue = 0;
            if (PriorityValue == compareToWrapperObj.PriorityValue) return 0;
            if (PriorityValue > compareToWrapperObj.PriorityValue) return 1;
            return -1; 
        }
     }
}