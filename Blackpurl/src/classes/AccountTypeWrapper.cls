public class AccountTypeWrapper {
	public String Id;
	public String AccountType;
	public String AppliesTo;
	public String TaxExemptions;
	public Boolean IsDefault;
	public Boolean IsActive;
	public Boolean IsUpdatable;
	public List<TaxExemptions> TaxExemptionsList;
	
	public AccountTypeWrapper(Account_Type__c accTypeRec) {
		this.Id = accTypeRec.Id;
		this.AccountType = accTypeRec.Name;
		this.AppliesTo = accTypeRec.Applies_To__c;
		this.TaxExemptions = '';
		if(accTypeRec.Tax_Exemptions__r.size() == 0) {
			this.TaxExemptions = 'None';
		} else {
			for(Tax_Exemption__c tax : accTypeRec.Tax_Exemptions__r) {
				if(tax.Sales_Tax_Item__r.Name__c != null && String.isNotBlank(tax.Sales_Tax_Item__r.Name__c)) {
			    	this.TaxExemptions += tax.Sales_Tax_Item__r.Name__c + ', ' ;
				}
			}
			this.TaxExemptions = this.TaxExemptions.length() > 2 ? this.TaxExemptions.subString(0,this.TaxExemptions.length() - 2) :  this.TaxExemptions;
		}
		this.IsDefault = accTypeRec.Default__c;
		this.IsActive = accTypeRec.Active__c;
		this.IsUpdatable = (accTypeRec.Accounts__r.size() > 0 || accTypeRec.Accounts1__r.size()> 0) ? false : true; 
	}
	
	public AccountTypeWrapper(Account_Type__c accTypeRec,List<TaxExemptions> taxExemptionsList) {
		this.Id = accTypeRec.Id;
		this.AccountType = accTypeRec.Name;
		this.AppliesTo = accTypeRec.Applies_To__c;
		this.TaxExemptionsList = taxExemptionsList;
		this.IsDefault = accTypeRec.Default__c;
		this.IsActive = accTypeRec.Active__c;
		this.IsUpdatable = (accTypeRec.Accounts__r.size() > 0 || accTypeRec.Accounts1__r.size()> 0) ? false : true;
		
		this.TaxExemptions = '';
		if(accTypeRec.Tax_Exemptions__r.size() == 0) {
			this.TaxExemptions = 'None';
		} else {
			for(Tax_Exemption__c tax : accTypeRec.Tax_Exemptions__r) {
				if(tax.Sales_Tax_Item__r.Name__c != null && String.isNotBlank(tax.Sales_Tax_Item__r.Name__c)) {
			    	this.TaxExemptions += tax.Sales_Tax_Item__r.Name__c + ', ' ;
				}
			}
			this.TaxExemptions = this.TaxExemptions.length() > 2 ? this.TaxExemptions.subString(0,this.TaxExemptions.length() - 2) :  this.TaxExemptions;
		}
	}
	public static List<String> getAccountTypeFields() {
       return new List<String>{'Name', 
                                'Active__c', 
                                'Applies_To__c',
                                'Default__c'
                              };
    }
}