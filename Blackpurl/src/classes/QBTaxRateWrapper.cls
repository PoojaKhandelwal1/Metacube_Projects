/**
 * Author: Nikhil Kumar Srivastava
 * Since: Novenmeber 30, 2018
 * Name: QBTaxRateWrapper
 * Description: Wrapper class to handle JSON variables for QB_Tax_Rate__c
**/

public class QBTaxRateWrapper {
	
	public String Name;
    public Boolean Active;
    public Decimal RateValue;
    public String Id;
    public QuickBookInternalEntity AgencyRef; 
    
    public QBTaxRateWrapper(QB_Tax_Rate__c taxRateRec) {
    
    	this.Name = (taxRateRec.Name == null) ? '' : taxRateRec.Name;
    	this.Active = taxRateRec.Is_Active__c;
    	this.RateValue = (taxRateRec.Rate_Value__c == null) ? 0.00 : taxRateRec.Rate_Value__c;
    	this.Id = (taxRateRec.Accounting_Id__c == null) ? '' : taxRateRec.Accounting_Id__c;
    }
    
    /**
    * Name: getFieldsList
    * Desc: Method Which contains all the field list to be quried
    * @param:  
    * @return: List<String> - Fields List
   **/
   public static List<String> getFieldList(){
       List<String> taxRateFields = new List<String>{ 
       													'Id',
       													'Accounting_Id__c',
       													'Is_Active__c',
       													'Rate_Value__c',
       													'Tax_Agency__c',
       													'Name'
       	};
       return taxRateFields;
   }
   
   public class QuickBookInternalEntity {
       public String value;
       public STring Name;
   }
    
}