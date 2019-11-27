public without sharing class IntegrationServiceFactory {
	
    public static BaseIntegrationService getIntegrationServiceInstance(String integrationType) {
        if(integrationType == 'Accounting') {
            return getAccountingServiceInstance();
        }
        return null;
    }
    
    private static BaseIntegrationService getAccountingServiceInstance() {
        List<IFW_IntegrationConfig__c> integrationConfig = [Select Id, Access_Token__c, Auth_Scheme__c, Bearer_Token__c, Certificate_Name__c, Certifcate_Password__c, 
        													Consumer_Key__c, Consumer_Secret__c, Enabled__c, Integration_Name__c, Grant_Type__c, Password__c,
        													Username__c, Refresh_Token__c, Timeout__c, Token_Expiry__c, Token_Type__c From IFW_IntegrationConfig__c 
        													where Enabled__c = true];
        if(!integrationConfig.isEmpty()) {
	        if(integrationConfig[0].Integration_Name__c == 'Xero') { // Constant
	            return new XeroService(integrationConfig[0]);
	        }
        } else {
            // Exception handling
            //throw new BlackpurlException('No integration active');
        }
        return null;
    }
}