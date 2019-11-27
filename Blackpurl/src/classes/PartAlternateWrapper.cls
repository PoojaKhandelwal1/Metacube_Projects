public class PartAlternateWrapper implements Comparable {
    
    public String PartId;
    public String ItemDesc;
    public String Vendor;
    public String RelationShip;
    public Decimal Available;
    public Decimal Price;
    public Boolean IsSelected;
    public Integer PriorityIndex;
    
    public PartAlternateWrapper(Part__c partRec, Integer PriorityIndex, String RelationShip, boolean IsSelected){ 
    	this.PartId = partRec.Id;
    	this.ItemDesc = partRec.Item_Description__c;
    	this.Vendor = partRec.Vendor__r.Vendor_Code__c;
    	this.RelationShip = RelationShip;
    	this.Available = partRec.AvailableParts__c; 
    	this.Price = partRec.Retail_Price__c;
    	this.IsSelected = IsSelected;
    	
    	this.PriorityIndex = PriorityIndex;
    }
    
    public Integer compareTo(Object compareTo) {
    	PartAlternateWrapper compareToWrapperObj = ((PartAlternateWrapper)compareTo);
    	Integer returnValue = 0;
    	if (PriorityIndex == compareToWrapperObj.PriorityIndex) return 0;
        if (PriorityIndex > compareToWrapperObj.PriorityIndex) return 1;
        return -1; 
	}
}