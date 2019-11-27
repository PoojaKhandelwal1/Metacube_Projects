public without sharing class DP360InventoryWrapper {
	
	public String id {get; set;}
	public String dealer_id {get; set;}
   	public String inv_id {get; set;}
   	public Integer classid {get; set;}
   	
   	public String vehtype {get; set;}
   	public String bodysubtype {get; set;}
   	public String category_name {get; set;}
   	public String condition {get; set;} 
   	public String year {get; set;}
   	
    public String make {get; set;}
    public String model {get; set;}
    public Decimal price {get; set;}
    
    public String dealername {get; set;}
    
    public String address {get; set;}
    public String city {get; set;}
    public String state {get; set;}
    public String zipcode {get; set;}
    public String telephone {get; set;}
    public String email {get; set;}
    public String url {get; set;}
    
    public String stocknumber {get; set;}
    public String color {get; set;}
    		
    public String miles {get; set;}
    public String description {get; set;}
    public Boolean sold {get; set;}
    public String vin {get; set;}
    public String suggested_price {get; set;}
    public String engine_id {get; set;}
    public String fuel_type {get; set;}
    
    public String unit_status {get; set;}
    public Integer inventory_source_id {get; set;}

    //public String hidden {get; set;}
    public String floor_plans {get; set;}
    public String sleeps {get; set;}
    
	public DP360InventoryWrapper(Customer_Owned_Unit__c unitRec) {
		this.id = unitRec.DP360_Inventory_Id__c;
		this.dealer_id = GeneralConfiguration.getDP360DealerId();
		this.inv_id = null;
		this.year = unitRec.Year__c != null ? String.valueOf(unitRec.Year__c) : null;
		this.make = (unitRec.Unit_Make__c != null) ? unitRec.Unit_Make__r.Name : null;
		this.model = (unitRec.Unit_Model__c != null) ? unitRec.Unit_Model__r.Name__c : null;
		this.price = unitRec.Total_Price__c != null ? unitRec.Total_Price__c : 0;
		this.suggested_price = String.valueOf(this.price);
		this.engine_id = unitRec.Engine_Serial_No__c != null ? String.valueOf(unitRec.Engine_Serial_No__c) : null;
		this.color = unitRec.Colour__c;
		
		this.stocknumber = unitRec.Stock_Id__c;
		this.dealername = null;
		this.vin = unitRec.VIN_Number__c;
		this.city = unitRec.Location__c;
		this.miles = unitRec.Mileage_Value__c != null ? String.valueOf(unitRec.Mileage_Value__c) : null;
		this.sold = (unitRec.Status__c != null && unitRec.Status__c == 'Sold') ? true : false;
		this.unit_status = unitRec.Status__c;
		this.inventory_source_id = null;
	}
    
    
    public static List<String> fieldsList() {
        List<String> unitFields = new List<String>{ 'Id'};
        return unitFields;
    }
    
}