/**
 * Author: Tarun Khandelwal
 * Since: August 17, 2018
 * Name: FusionLineItemWrapper
 * Description: Wrapper class for Fusion Line Item Object
**/
public with sharing class FusionLineItemWrapper {
    
    public String Id;
    public String Description;
    public String HDNetAccount;
    public Boolean MapAction;
    public Decimal OrderNumber;
    public List<String> MappedGLAccountList;
    public List<List<String>> MappedGLAccountWithNameList;
    public String Source;
    
    public FusionLineItemWrapper(Fusion_Report_Line_Item__c fusionReportLineItemRec) {
        this.Id = fusionReportLineItemRec.Id;
        this.Description = fusionReportLineItemRec.Description__c;
        this.HDNetAccount = fusionReportLineItemRec.HDNet_Account__c;
        this.MapAction = fusionReportLineItemRec.Map_Action__c;
        this.OrderNumber = fusionReportLineItemRec.Order_Number__c;
        this.Source = fusionReportLineItemRec.Source__c;
        this.MappedGLAccountWithNameList = new List<List<String>>();
        for(Fusion_Line_Item_To_GL_Account_Junction__c junctionRec : fusionReportLineItemRec.Fusion_Line_Item_To_GL_Account_Junctions__r) {
            this.MappedGLAccountWithNameList.add(new List<String>{junctionRec.General_Account__r.Account_Number__c, junctionRec.General_Account__r.Account_Name__c});
        }
    }
    
    public static List<String> getFusionLineItemsFields() {
       return new List<String>{'Description__c', 
                                'HDNet_Account__c', 
                                'Map_Action__c',
                                'Order_Number__c', 
                                'Source__c',
                                'Monthly_Value__c',
                                'Yearly_Value__c'
                              };
    }
    
    public class LineItemValueWrapper {
        public Map<Integer, Decimal> OrderNumberToMontlyAmountMap;
        public Map<Integer, Decimal> OrderNumberToYearlyAmountMap;
        
        public LineItemValueWrapper(Map<Integer, Decimal> orderNumberToMontlyAmountMap, Map<Integer, Decimal> orderNumberToYearlyAmountMap) {
            this.OrderNumberToMontlyAmountMap = orderNumberToMontlyAmountMap;
            this.OrderNumberToYearlyAmountMap = orderNumberToYearlyAmountMap;
        }
    }
}