public without sharing class ProfitabilityWrapper {
    
    public Decimal COTotalSales;
    public Decimal COTotalCost;
    public Decimal COGrossProfit;
    public Decimal COProfitPercentage;
    public List<SectionProfitabilityWrapper> SectionProfitabilityList;
    
    public ProfitabilityWrapper(List<SectionProfitabilityWrapper> sectionproductProfitabilityObjList) {
    	this.COTotalSales = 0;
    	this.COTotalCost = 0;
    	this.SectionProfitabilityList = sectionproductProfitabilityObjList;
    	for(SectionProfitabilityWrapper sectionProfitabilityObj : SectionProfitabilityList) {
    		this.COTotalSales += sectionProfitabilityObj.TotalSales;
    		this.COTotalCost += sectionProfitabilityObj.TotalCost;
    	}
    	this.COGrossProfit = (this.COTotalSales - this.COTotalCost).setScale(2, RoundingMode.HALF_UP);
    	this.COProfitPercentage = ((this.COTotalSales == 0 || this.COGrossProfit == 0) ? 0 : (this.COGrossProfit / this.COTotalSales) * 100).setScale(2, RoundingMode.HALF_UP);
    }
    public class SectionProfitabilityWrapper {
    	public String Section;
	    public Decimal TotalSales;
	    public Decimal TotalCost;
	    public Decimal TotalProfit;
	    public Decimal TotalProfitPercentage;
	    public List<ProductProfitabilityWrapper> ProductProfitabilityList;
	    
    	public SectionProfitabilityWrapper(String sectionName, List<ProductProfitabilityWrapper> productProfitabilityObjList) {
    		this.Section = sectionName;
	    	this.ProductProfitabilityList = productProfitabilityObjList;
	    	this.TotalSales = 0;
	    	this.TotalCost = 0;
	    	for(ProductProfitabilityWrapper entityProfitabilityObj : productProfitabilityObjList) {
	    		this.TotalSales += entityProfitabilityObj.Sale;
	    		this.TotalCost += entityProfitabilityObj.Cost;
	    	}
	    	this.TotalProfit = (this.TotalSales - this.TotalCost).setScale(2, RoundingMode.HALF_UP);
	    	this.TotalProfitPercentage = ((this.TotalSales == 0 || this.TotalProfit == 0) ? 0 : (this.TotalProfit / this.TotalSales) * 100).setScale(2, RoundingMode.HALF_UP);
    	}
    }
    
    public class ProductProfitabilityWrapper {
    	public String Product;
    	public Decimal Sale;
    	public Decimal Cost;
    	public Decimal GrossProfit;
    	public Decimal ProfitPercent;
    	
    	public ProductProfitabilityWrapper(String productName, Decimal totalSales, Decimal totalCost) {
    		this.Product = productName;
    		this.Sale = totalSales != null ? totalSales.setScale(2, RoundingMode.HALF_UP) : 0;
    		this.Cost = totalCost != null ? totalCost.setScale(2, RoundingMode.HALF_UP) : 0;
    		this.GrossProfit = (this.Sale - this.Cost).setScale(2, RoundingMode.HALF_UP);
    		this.ProfitPercent = ((this.Sale == 0 || this.GrossProfit == 0) ? 0 : (this.GrossProfit / this.Sale) * 100).setScale(2, RoundingMode.HALF_UP);
    	}
    }
}