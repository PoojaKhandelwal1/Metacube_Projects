public without sharing class IntegrationCompanyWrapper {
    public String CompanyName;
    public String CompanyId;
    
    public IntegrationCompanyWrapper(XeroOrganisationDTO xeroOrganisationObj) {
    	this.CompanyName = xeroOrganisationObj.Name;
    	this.CompanyId = xeroOrganisationObj.OrganisationID;
    }
}
