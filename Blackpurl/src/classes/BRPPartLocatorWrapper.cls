public without sharing class BRPPartLocatorWrapper {
    
    public String PartNumber;
    public String PartDescription;
    public String ManufacturerAvailableQty;
    public String ManufacturerPhoneNumber;
    public List<PartInfoFromDealer> DealerNearList;
    public List<PartInfoFromDealer> AllDealerList;
    
    public class PartInfoFromDealer {
        public String AvailableQty;
        public String DealerName;
        public String DealerAddress;
        public String Distance;
        public String DealerPhoneNumber;
    }
}