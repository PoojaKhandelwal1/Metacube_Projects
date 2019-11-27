public with sharing class LinkedFormService {
    
    public static List<FormRepositoryWrapper> getActiveFormsByGroup(String groupingName) {
        List<Form__c> activeFormList = FormSOQLUtil.getUnlinkedActiveFormsByGroup(groupingName);
        List<FormRepositoryWrapper> activeFormObjList = new List<FormRepositoryWrapper>();
        for(Form__c formRec: activeFormList) {
            activeFormObjList.add(new FormRepositoryWrapper(formRec));
        }
        return activeFormObjList;
    }
    
    public static List<LinkedFormWrapper.VendorProductWrapper> getVendorProducts() {
        List<Product__c> vendorProductList = FormSOQLUtil.getVendorProducts();
        List<LinkedFormWrapper.VendorProductWrapper> vendorProductObjList = new List<LinkedFormWrapper.VendorProductWrapper>();
        for(Product__c productRec: vendorProductList) {
            vendorProductObjList.add(new LinkedFormWrapper.VendorProductWrapper(productRec));
        }
        return vendorProductObjList;
    }
    
    public static LinkedFormWrapper saveLinkedForm(String linkedFormJson) {
        LinkedFormWrapper LinkedFormWrapperObj = (LinkedFormWrapper) System.JSON.deserialize(linkedFormJson, LinkedFormWrapper.class);
        Linked_Form__c linkedForm = new Linked_Form__c();
        linkedForm.Id = LinkedFormWrapperObj.Id;
        linkedForm.Form__c = LinkedFormWrapperObj.FormId;
        linkedForm.Is_Required__c = LinkedFormWrapperObj.IsRequired;
        linkedForm.Grouping_Name__c = LinkedFormWrapperObj.GroupingName;
        linkedForm.Vendor_Product__c = LinkedFormWrapperObj.VendorProductId;
        if(AccessControl.ifObjectFieldIsCreateable('Linked_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Linked_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        upsert linkedForm;
        
        return new LinkedFormWrapper(FormSOQLUtil.getLinkedFormById(linkedForm.Id));
    }
    
    public static List<LinkedFormWrapper> getLinkedFormsByGroup(String groupingName) {
        List<Linked_Form__c> linkedFormList = FormSOQLUtil.getLinkedFormsByGroup(groupingName);
        List<LinkedFormWrapper> linkedFormObjList = new List<LinkedFormWrapper>();
        for(Linked_Form__c linkedFormRec: linkedFormList) {
            linkedFormObjList.add(new LinkedFormWrapper(linkedFormRec));
        }
        return linkedFormObjList;
    }
    
    public static void deleteLinkedForm(String linkedFormId) {
        if(AccessControl.ifObjectIsDeletable('Linked_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        Linked_Form__c linkedFormRec = new Linked_Form__c();
        linkedFormRec.Id = linkedFormId;
        delete linkedFormRec;
    }
    
    public static List<LinkedFormWrapper.LinkedFormOverviewWrapper> getOverviewDetails() {
        AggregateResult[] groupedResults = [select Grouping_Name__c form, count(Id)
                                                from Linked_Form__c 
                                                group by Grouping_Name__c];
        List<LinkedFormWrapper.LinkedFormOverviewWrapper> overViewList = new List<LinkedFormWrapper.LinkedFormOverviewWrapper>();
        
        for(AggregateResult res : groupedResults){
            sectionNameToRecordsCountMap.put(String.valueOf(res.get('form')), Integer.valueOf(res.get('expr0')));
        }   
        for(String sectionName : sectionNameToRecordsCountMap.keySet()){
            overViewList.add(new LinkedFormWrapper.LinkedFormOverviewWrapper(sectionName,
                                                                            sectionNameToRecordsCountMap.get(sectionName)));
        }
        return overViewList;
    }
    
    private static Map<String, Integer> sectionNameToRecordsCountMap = new Map<String, Integer>{
                                                                    'Deal' => 0,
                                                                    'Vendor product' => 0,
                                                                    'Financing' => 0, 
                                                                    'Service' => 0
                                                        };
}