public class UnitModelWrapper {
    public String Unit_Model_Id;
    public String Unit_Model_Name;
    public Boolean Unit_Model_Active;
    public String Unit_Model_VIN_Code;
    public String Unit_Model_Category_Id;
    public String Unit_Model_Category;
    public String Unit_Model_Model_Description;
    public String Unit_Model_Sub_Model;
    public String Unit_Model_Unit_Make_Id;
    public String Unit_Model_Unit_Make;
    public String Unit_Model_Sub_Model_Id;
    
    public UnitModelWrapper(Unit_Model__c unitModelRec, Unit_Sub_Model__c submodel) {
    	this.Unit_Model_Id = unitModelRec.Id;
    	this.Unit_Model_Name = unitModelRec.Name__c;
    	this.Unit_Model_Active = unitModelRec.Active__c;
    	this.Unit_Model_Unit_Make_Id = unitModelRec.Unit_Make__c;
    	this.Unit_Model_Sub_Model = submodel.Sub_Model_Name__c != null ? submodel.Sub_Model_Name__c : '';
    	this.Unit_Model_Sub_Model_Id = submodel.Id;
    	this.Unit_Model_Model_Description = unitModelRec.Model_Description__c != null? unitModelRec.Model_Description__c : '';
    	this.Unit_Model_VIN_Code = unitModelRec.VIN_Code__c != null? unitModelRec.VIN_Code__c : '';
    	this.Unit_Model_Category = unitModelRec.Category__r.Name;
    	this.Unit_Model_Category_Id = unitModelRec.Category__c;
    }
}