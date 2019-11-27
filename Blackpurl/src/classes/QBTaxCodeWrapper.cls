/**
 * Author: Nikhil Kumar Srivastava
 * Since: Novenmeber 29, 2018
 * Name: QBTaxCodeWrapper
 * Description: Wrapper class to handle JSON variables for QBTaxCode
**/

public class QBTaxCodeWrapper {
    
    public String Name;
    public Boolean Active;
    public Boolean Taxable;
    public String Id;
    public String Description;
    public Boolean TaxGroup;
    public Set<Integer> ApplicableTaxRates;  //for internal purpose 
    public SalesTaxRateWrapper SalesTaxRateList;
    public SalesTaxRateWrapper PurchaseTaxRateList;
    public Decimal RateValue;
    public String TaxApplicableOn;
    public String LastModifiedDate;
    
    public QBTaxCodeWrapper(){}
    public QBTaxCodeWrapper(QB_TaxCode__c taxCodeRec) {
    
    	this.Name = (taxCodeRec.Name == null) ? '' : taxCodeRec.Name;
    	this.Active = taxCodeRec.Is_Active__c;
    	this.Taxable = taxCodeRec.Is_Taxable__c;
    	this.Id = (taxCodeRec.Accounting_Id__c == null) ? '' : taxCodeRec.Accounting_Id__c;
    	
    	this.ApplicableTaxRates = new Set<Integer>();
    	if(String.isNotBlank(taxCodeRec.Applicable_QB_Tax_Rates__c)){
    	    List<String> taxRates = taxCodeRec.Applicable_QB_Tax_Rates__c.split(';');
    	    for(String taxRateAccId : taxRates) {
    	        this.ApplicableTaxRates.add(Integer.valueOf(taxRateAccId.trim()));
    	    }
    	}
    	this.RateValue = (taxCodeRec.Rate_Value__c != null ? taxCodeRec.Rate_Value__c : 0);
    	this.TaxApplicableOn = taxCodeRec.Tax_Applicable_On__c;
    	
    	String timeZone = USerInfo.getTimeZone().getDisplayName();
    	if(timeZone != null){
            List<String> timeZoneList = timeZone.split(' ');
            timeZone = '';
            for(String s : timeZoneList){
                if(s.length() > 0){
                    timeZone += s.substring(0,1);
                }
            }
        }
    	this.LastModifiedDate = (taxCodeRec.LastModifiedDate != null) ? 
                                BPUtility.getExtendedDateFormat(taxCodeRec.LastModifiedDate) + ' ' + timeZone : '';
    }
    
    public class SalesTaxRateWrapper {
        public List<TaxRateDetailWrapper> TaxRateDetail;        
    }    
    
    public class TaxRateDetailWrapper {
        
        public QBInternalEntityWrapper TaxRateRef;
        public String TaxTypeApplicable;
        public Integer TaxOrder;
    }
    
    public class QBInternalEntityWrapper {
       public String value;
       public String name; 
    }
    
    /**
    * Name: getFieldsList
    * Desc: Method Which contains all the field list to be quried
    * @param:  
    * @return: List<String> - Fields List
   **/
   public static List<String> getFieldList(){
       List<String> taxCodeFields = new List<String>{ 
       													'Id',
       													'Accounting_Id__c',
       													'Is_Taxable__c',
       													'Is_Active__c',
       													'Name',
       													'Applicable_QB_Tax_Rates__c',
       													'Rate_Value__c',
       													'Tax_Applicable_On__c',
       													'LastModifiedDate'
       	};
       return taxCodeFields;
   }
    
}