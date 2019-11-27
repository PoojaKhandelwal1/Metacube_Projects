public without sharing class XeroTaxRateDTO {
    public String Name;
    public String TaxType;
    public String EffectiveRate;
    public String Status;
    public List<XeroTaxComponentsDTO> TaxComponents;
    
    public without sharing class XeroTaxComponentsDTO {
	    public String Name;
	    public String Rate;
	}
}