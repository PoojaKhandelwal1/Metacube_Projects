public with sharing class CategoryWrapper {
    
	public String Id;
	public String CategoryName;
    public Boolean IsActive;
    public String COGSGL;
    public Boolean IsDefault;
    public String IncomeGL;
    public String InventoryGL;
    public String Status;
    public String Type;

	public CategoryWrapper(Category__c categoryRec) { 
		this.Id = categoryRec.Id;
		this.IsActive = categoryRec.Active__c;
		this.COGSGL = categoryRec.COGS_GL__c;
		this.IsDefault = categoryRec.Default__c;
		this.CategoryName = categoryRec.Name;
		this.IncomeGL = categoryRec.Income_GL__c;
		this.InventoryGL = categoryRec.Inventory_GL__c;
		this.Status = categoryRec.Status__c;
		this.Type = categoryRec.Type__c;
	}
	
	public static List<String> getCategoryFieldList() {
		List<String> categoryFields = new List<String>{ 'Id',
	                                                    'Active__c', 
	                                                    'COGS_GL__c',
	                                                    'Default__c', 
	                                                    'Name', 
	                                                    'Income_GL__c',
	                                                    'Inventory_GL__c',
	                                                    'Status__c',
	                                                    'Type__c'
													};
		
		return categoryFields;
	}
}