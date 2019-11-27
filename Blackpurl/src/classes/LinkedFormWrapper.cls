/**
 * Author: Richa Mittal
 * Since: Aug 3, 2018
 * Name: LinkedFormWrapper
 * Description:  Used to convert Linked Form serialize and deserialize operations
**/
public with sharing class LinkedFormWrapper {
    
    public String Id;
    public String FormId;
    public String FormName;
    public Boolean IsRequired;
    public String GroupingName;
    public String VendorProductId;
    public String VendorProductName;
    
    public LinkedFormWrapper(Linked_Form__c linkForm) {
        this.Id = linkForm.Id;
        this.FormId = linkForm.Form__c;
        this.FormName = linkForm.Form__r.Name;
        this.IsRequired = linkForm.Is_Required__c;
        this.GroupingName = linkForm.Grouping_Name__c;
        this.VendorProductId = linkForm.Vendor_Product__c;
        this.VendorProductName = linkForm.Vendor_Product__r.Product_Unique_Name__c;
    }
    
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList() {
        List<String> LinkedFormFieldList = new List<String>{ 'Id',
                                                        'Form__c',
                                                        'Is_Required__c',
                                                        'Grouping_Name__c',
                                                        'Form__r.Name',
                                                        'Vendor_Product__c',
                                                        'Vendor_Product__r.Product_Unique_Name__c'
                                                };
        return LinkedFormFieldList;
    }
    
    public class LinkedFormOverviewWrapper {
        String SectionName;
        Integer Count;
        
        public LinkedFormOverviewWrapper(String sectionName, Integer noOfRecords){
            this.SectionName = sectionName;
            this.Count = noOfRecords;
        }
    }
    
    public class VendorProductWrapper {
        String Name;
        String Id;
        
        public VendorProductWrapper(Product__c productRec){
            this.Name = productRec.Product_Unique_Name__c;
            this.Id = productRec.Id;
        }
    }
}