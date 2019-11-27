/**
* Author: Ashish Garg
* Since: Nov 20, 2015
* Name: ViewLabourCtrl
* Description: Apex class for Labour record and related records
**/
public with sharing class LabourRecord {
	// Id
	public Id Id {get; private set;}
	
	// Labour number
	public String LabourNumber {get; private set;}
	
	// Labour name
	public String LabourName {get; private set;}
	
	// Labour hours
	public String LabourHours {get; private set;}
	
	// Labour rate
	public String LabourRate {get; private set;}
	
	// Labour code
	public String LabourCode {get; private set;}
	
	// Labour status
	public boolean LabourStatus {get; private set;}
	
	// Labour fixed rate
	public boolean LabourFixedRate {get; private set;}
	
	// Labour taxable
	public boolean LabourTaxable {get; set;}
	
	// Labour Description
	public String LabourDescription {get; private set;}
	
	// Labour Category record
	public Category LabourCategory {get; set;}
	
	public String ApplicableTaxId {get; private set;}
	public String ApplicableTaxName {get; private set;}
	
	public Integer PriorityLevel{get; set;}

    // Shop Supplies related fields
    public Boolean hasShopSuppliesCalculationMethod;
	public Boolean CalculateSupplies;
	public String SuppliesDetail;
	
	//Added by Nikhil 12/07/17
	//Labour Cost Method 
	 public String  CostMethod;
	 public Decimal CostRate;
	 public Decimal FinalCostRate;		
	 
	// Constructor
	public LabourRecord(Id labourId) {
		if(labourId != null && String.valueOf(labourId).trim().length() != 0){
			Map<String, String> sortFieldMap = new Map<String, String>{'LastModifiedDate' => 'DESC'};
			List<Labour_Code__c> labourCodeRecords = SOQLUtil.getLabourRecords(new Set<Id>{labourId}, sortFieldMap);
			
			if(labourCodeRecords.size() > 0){
				Labour_Code__c labourCode = labourCodeRecords[0];
				
				this.Id = labourCode.Id;
				this.LabourNumber = labourCode.Name;
				this.LabourName = labourCode.Name__c;
				this.LabourHours = (labourCode.Hours__c != null) ? (labourCode.Hours__c + '') : '0.0';
				this.LabourRate = (labourCode.Rate__c != null) ? (labourCode.Rate__c + '') : '0.00';
				this.LabourCode = labourCode.Code__c;
				this.LabourStatus = labourCode.Active__c;
				this.LabourTaxable = labourCode.Taxable__c;
				this.LabourFixedRate = labourCode.Fixed_Rate__c;
				this.LabourDescription = labourCode.Description__c;
				
				this.LabourCategory = new Category(labourCode.Category__c, labourCode.Category__r.Name);
				this.ApplicableTaxId = labourCode.Applicable_Tax__c;
				this.ApplicableTaxName = labourCode.Applicable_Tax__r.Name__c;
				//Added by Nikhil - 11/07/2017
				this.CostRate = (labourCode.Cost_Rate__c == null) ? 0 : labourCode.Cost_Rate__c; 
				this.CostMethod = labourCode.Cost_Method__c; 
				this.FinalCostRate = (labourCode.Cost_Method__c == 'Fixed Cost') ? labourCode.Cost_Rate__c : (labourCode.Cost_Method__c == 'Percent Retail' ? (this.CostRate * Decimal.valueOf(this.LabourRate))/100 : 0 );
				this.CalculateSupplies = labourCode.Calculate_Supplies__c;
                this.SuppliesDetail = labourCode.Supplies_Detail__c;
			}
		}
	}
	
	// Constructor
	public LabourRecord(Labour_Code__c labourCode) {
		if(labourCode != null){
			this.Id = labourCode.Id;
			this.LabourNumber = labourCode.Name;
			this.LabourName = labourCode.Name__c;
			this.LabourHours = (labourCode.Hours__c != null) ? (labourCode.Hours__c + '') : '0.0';
			this.LabourRate = (labourCode.Rate__c != null) ? (labourCode.Rate__c + '') : '0.00';
			this.LabourCode = labourCode.Code__c;
			this.LabourStatus = labourCode.Active__c;
			this.LabourTaxable = labourCode.Taxable__c;
			this.LabourFixedRate = labourCode.Fixed_Rate__c;
			this.LabourDescription = labourCode.Description__c;
			//Added by Nikhil - 11/07/2017
			this.CostRate = (labourCode.Cost_Rate__c == null) ? 0 : labourCode.Cost_Rate__c; 
			this.CostMethod = labourCode.Cost_Method__c;
			this.CalculateSupplies = labourCode.Calculate_Supplies__c;
            this.SuppliesDetail = labourCode.Supplies_Detail__c; 
		}
	}
	
	// Constructor
	public LabourRecord(Labour_Code__c labourCode, Integer priorityLevel) {
		if(labourCode != null){
			this.Id = labourCode.Id;
			this.LabourNumber = labourCode.Name;
			this.LabourName = labourCode.Name__c;
			this.LabourHours = (labourCode.Hours__c != null) ? (labourCode.Hours__c + '') : '0.0';
			this.LabourRate = (labourCode.Rate__c != null) ? (labourCode.Rate__c + '') : '0.00';
			this.LabourCode = labourCode.Code__c;
			this.LabourStatus = labourCode.Active__c;
			this.LabourTaxable = labourCode.Taxable__c;
			this.LabourFixedRate = labourCode.Fixed_Rate__c;
			this.LabourDescription = labourCode.Description__c;
			this.PriorityLevel = priorityLevel;
			//Added by Nikhil - 11/07/2017
			this.CostRate = (labourCode.Cost_Rate__c == null) ? 0 : labourCode.Cost_Rate__c; 
			this.CostMethod = labourCode.Cost_Method__c; 
			this.CalculateSupplies = labourCode.Calculate_Supplies__c;
            this.SuppliesDetail = labourCode.Supplies_Detail__c;
		}
	}
	
	// A method to define the list of Labour object fields to be used in queries
	public static List<String> fieldsList(){
		List<String> labourFields = new List<String>{	'Id', 
														'Name', 
														'Code__c',
														'Active__c', 
														'Description__c',
														'Fixed_Rate__c',
														'Hours__c',
														'Name__c',
														'Rate__c',
														'Taxable__c',
														'Category__c',
														'Category__r.Name',
														'Applicable_Tax__c',
														'Applicable_Tax__r.Name__c',
														'Cost_Method__c',
														'Cost_Rate__c',
														'Calculate_Supplies__c',
														'Supplies_Detail__c'
													};
		return labourFields;
	}
	
	/**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: LabourRecord - Class Object
    **/
    public static List<LabourRecord> parse(String JSONString) {
        return (List<LabourRecord>) System.JSON.deserialize(JSONString, List<LabourRecord>.class);
    }
	
	// Labour Category wrapper
	public class Category {
		// Category Id
		public Id Id {get; private set;}
		
		// Category name
		public String Name {get; private set;}
		
		// Category Constructor
		public Category(Category__c category) {
			this.Id = category.Id;
			this.Name = category.Name;
		}
		
		// Categry Id-Value Constructor
		public Category(Id id, String name) {
			this.Id = Id;
			this.Name = name;
		}
	}
}