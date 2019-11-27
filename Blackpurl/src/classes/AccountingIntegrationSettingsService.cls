public without sharing class AccountingIntegrationSettingsService {
    
    public static ResponseWrapper OAuthConnectionStep1(String consumerKey, String consumerSecret, String integrationName) {
        List<Log__c> errorLogList = new List<Log__c>();
        HttpResponse res;
        if(integrationName == 'Xero') {
            res = XeroPublicUtility.OAuthConnection(consumerKey, consumerSecret);
        }
        String responseStatus = '';
        String redirectUrl = '';
        if(res.getStatusCode() == 200) {
            Map<String, String> responseItemMap = parseOAuthStep1Response(res.getBody());
            String OAuth_Token;
            try {
                OAuth_Token = responseItemMap.get('oauth_token');
                saveAccountSettingsData(integrationName);
                saveOauthTokenSecret(null, responseItemMap.get('oauth_token_secret'), integrationName);
                responseStatus = 'success';
            } catch(Exception e) {
                responseStatus = e.getMessage();
                errorLogList.add(new LogService().createErrorLog('oAuth step 1', 'OAuthConnectionStep1()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              ConsumerKey + LogService.METHOD_PARAM_SEPERATOR + ConsumerSecret, LogService.QUICKBOOKS, false));
            }
            
            if(integrationName == 'Xero') {
                redirectUrl = 'https://api.xero.com/oauth/Authorize?oauth_token=' + OAuth_Token;
            }
        } else {
        	resetAccessTokenSecret(integrationName);
            responseStatus = res.getBody();
            errorLogList.add(new LogService().createErrorLog('AccountingIntegrationSettingsService', 'OAuthConnectionStep1()', res.getBody(), res.getStatusCode(), null, 
                                              ConsumerKey + LogService.METHOD_PARAM_SEPERATOR + ConsumerSecret, LogService.QUICKBOOKS, false));
        }
        if(errorLogList.size() > 0) {
            insert errorLogList;
        }
        return new ResponseWrapper(responseStatus, redirectUrl);
    }
    
    public static String getConnectedCompanyInfo(String integrationName) {
    	List<Log__c> errorLogList = new List<Log__c>();
        HttpResponse response;
        String responseStatus = '';
        String responseString = '';
        
        List<IFW_IntegrationConfig__c> integrationConfigList = getIntegrationConfigWithItems(integrationName, new Map<String, String>{IntegrationUtility.ORGANISATION => null});
        if(integrationConfigList.size() == 0) throw new BlackpurlException('No active integration');
        
        List<IFW_IntegrationConfigItem__c> configItemList = integrationConfigList[0].IFW_IntegrationConfigItems__r;
        if(configItemList.size() == 0) throw new BlackpurlException('Config item for Organization not defined');
        
        if(integrationName == 'Xero') {
            // public app
            /*response = XeroPublicUtility.executeOauth1Callout(configItemList[0].HTTP_Method__c, '', integrationConfigList[0].Consumer_Key__c, integrationConfigList[0].Consumer_Secret__c,
            												integrationConfigList[0].Access_Token__c, integrationConfigList[0].Access_Token_Secret__c, configItemList[0].Endpoint_URL__c);*/
        	// private app
            response = BaseIntegration.performCallout(integrationConfigList[0], configItemList[0], '', new List<customHttpHeaderWrapper>());
        	if(response.getStatusCode() == 200) {
        		try {
        			XeroResponseWrapper xeroResponseWrapper = (XeroResponseWrapper)System.JSON.deserialize(response.getBody(), XeroResponseWrapper.class);
    				responseStatus = 'success';
    				List<IntegrationCompanyWrapper> companyJsonList = new List<IntegrationCompanyWrapper>();
    				for(XeroOrganisationDTO organisationObj: xeroResponseWrapper.Organisations) {
    					companyJsonList.add(new IntegrationCompanyWrapper(organisationObj));
    				}
    				
    				if(companyJsonList.size() == 0) throw new BlackpurlException('Unable to get connected company info');
    				saveCompanyInfo(companyJsonList[0]);
    				responseString = System.JSON.serialize(new AccountingSettingWrapper.ConfigurationWrapper(Accounting_Settings__c.getOrgDefaults(), QuickBooks_Configurations__c.getOrgDefaults()));
        		} catch(Exception e) {
	                responseStatus = 'error';
	                errorLogList.add(new LogService().createErrorLog('AccountingIntegrationSettingsService', 'getConnectedCompanyInfo()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
	                                              integrationName, LogService.XERO, false));
	            }
            } else {
            	responseString = System.JSON.serialize((HttpErrorDTO)System.JSON.deserialize(response.getBody(), HttpErrorDTO.class));
                responseStatus = 'error';
                errorLogList.add(new LogService().createErrorLog('AccountingIntegrationSettingsService', 'getConnectedCompanyInfo()', response.getBody(), response.getStatusCode(), null, 
                                              integrationName, LogService.XERO, false));
            }
        }
        if(errorLogList.size() > 0) {
            insert errorLogList;
        }
        return System.JSON.serialize(new ResponseWrapper(responseStatus, responseString));
    }
    
    public static String getChartOfAccounts(String integrationName) {
    	List<Log__c> errorLogList = new List<Log__c>();
        HttpResponse response;
        String responseStatus = '';
        
        List<IFW_IntegrationConfig__c> integrationConfigList = getIntegrationConfigWithItems(integrationName, new Map<String, String>{IntegrationUtility.ACCOUNT => null});
        if(integrationConfigList.size() == 0) throw new BlackpurlException('No active integration');
        
        List<IFW_IntegrationConfigItem__c> configItemList = integrationConfigList[0].IFW_IntegrationConfigItems__r;
        if(configItemList.size() == 0) throw new BlackpurlException('Config item for Organization not defined');
    	if(integrationName == 'Xero') {
    		// public app
    		/*response = XeroPublicUtility.executeOauth1Callout(configItemList[0].HTTP_Method__c, '', integrationConfigList[0].Consumer_Key__c, integrationConfigList[0].Consumer_Secret__c,
            												integrationConfigList[0].Access_Token__c, integrationConfigList[0].Access_Token_Secret__c, configItemList[0].Endpoint_URL__c);*/
            // private app
            response = BaseIntegration.performCallout(integrationConfigList[0], configItemList[0], '', new List<customHttpHeaderWrapper>());
        	if(response.getStatusCode() == 200) {
        		try {
        			XeroResponseWrapper xeroResponseWrapper = (XeroResponseWrapper) System.JSON.deserialize(response.getBody(), XeroResponseWrapper.class);
    				responseStatus = 'success';
    				/*List<IntegrationCOAWrapper> coaJsonList = new List<IntegrationCOAWrapper>();
    				for(XeroAccountDTO accObj: xeroResponseWrapper.Accounts) {
    					coaJsonList.add(new IntegrationCOAWrapper(accObj));
    				}*/
    				List<General_Account__c> existingGeneralAccountList = [SELECT Id, Accounting_Id__c from General_Account__c LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
		            Map<String, String> existingGeneralAccountIdToSFIdMap = new Map<String, String>();
		            for(General_Account__c GLAcc : existingGeneralAccountList){
		                existingGeneralAccountIdToSFIdMap.put(GLAcc.Accounting_Id__c, GLAcc.Id);
		            }
		            List<General_Account__c> glAccountList = new List<General_Account__c>();
		            List<String> glAccountAvailableOnXero = new List<String>();
		            for(XeroAccountDTO accObj: xeroResponseWrapper.Accounts){
		                General_Account__c glAccount = new General_Account__c(); 
		                if(existingGeneralAccountIdToSFIdMap.containsKey(accObj.AccountID)){
		                    glAccount.Id = existingGeneralAccountIdToSFIdMap.get(accObj.AccountID);
		                    glAccountAvailableOnXero.add(existingGeneralAccountIdToSFIdMap.get(accObj.AccountID));
		                }
		                glAccount.Accounting_Id__c = accObj.AccountID;
		                glAccount.Account_Number__c = accObj.Code;
		                glAccount.Account_Name__c = accObj.Name;
		                glAccount.Account_Type__c = accObj.Type;
		                glAccount.Is_Active__c = (accObj.Status).equalsIgnoreCase('Active') ? true : false;
		                glAccountList.add(glAccount);
		            }
		            for(General_Account__c glAcc : existingGeneralAccountList) {
		            	if(!glAccountAvailableOnXero.contains(String.valueOf(glAcc.Id))) {
		            		glAccountList.add(new General_Account__c(Id = glAcc.Id, Is_Active__c = false));
		            	}
		            }
		            if(glAccountList.size() > 0){
		                upsert glAccountList;
		            }
    				return system.JSON.serialize(getChartOfAccountsList());
        		} catch(Exception e) {
	                responseStatus = 'error';
	                errorLogList.add(new LogService().createErrorLog('AccountingIntegrationSettingsService', 'getChartOfAccounts()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
	                                              integrationName, LogService.XERO, false));
	            }
            } else {
                responseStatus = 'error';
                errorLogList.add(new LogService().createErrorLog('AccountingIntegrationSettingsService', 'getChartOfAccounts()', response.getBody(), response.getStatusCode(), null, 
                                              integrationName, LogService.XERO, false));
            }
    	}
    	return 'success';
    }
    
    public static String syncTaxCodes(String integrationName) {
    	List<Log__c> errorLogList = new List<Log__c>();
        HttpResponse response;
        String responseStatus = '';
        
        List<IFW_IntegrationConfig__c> integrationConfigList = getIntegrationConfigWithItems(integrationName, new Map<String, String>{IntegrationUtility.TAX_RATE => null});
        if(integrationConfigList.size() == 0) throw new BlackpurlException('No active integration');
        
        List<IFW_IntegrationConfigItem__c> configItemList = integrationConfigList[0].IFW_IntegrationConfigItems__r;
        if(configItemList.size() == 0) throw new BlackpurlException('Config item for Tax rates is not defined');
    	
    	List<QB_TaxCode__c> taxCodeToUpsertList = new List<QB_TaxCode__c>();
    	if(integrationName == 'Xero') {
    		// public app
    		/*response = XeroPublicUtility.executeOauth1Callout(configItemList[0].HTTP_Method__c, '', integrationConfigList[0].Consumer_Key__c, integrationConfigList[0].Consumer_Secret__c,
            												integrationConfigList[0].Access_Token__c, integrationConfigList[0].Access_Token_Secret__c, configItemList[0].Endpoint_URL__c);*/
            // private app
            response = BaseIntegration.performCallout(integrationConfigList[0], configItemList[0], '', new List<customHttpHeaderWrapper>());
        	if(response.getStatusCode() == 200) {
        		try {
        			XeroResponseWrapper xeroResponseWrapper = (XeroResponseWrapper)System.JSON.deserialize(response.getBody(), XeroResponseWrapper.class);
    				responseStatus = 'success';
    				List<QBTaxCodeWrapper> taxCodeJsonList = new List<QBTaxCodeWrapper>();
    				for(XeroTaxRateDTO taxRateObj: xeroResponseWrapper.TaxRates) {
    					taxCodeToUpsertList.add(saveTaxCode(taxRateObj.Name, taxRateObj.Status == 'ACTIVE', true, taxRateObj.TaxType, '', '', taxRateObj.EffectiveRate));
    				}
    				
    				if(taxCodeToUpsertList.size() == 0) throw new BlackpurlException('No tax rates defined');
    				
    				if(AccessControl.ifObjectIsDeletable('QB_TaxCode__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            		delete [Select Id from QB_TaxCode__c];
    				upsert taxCodeToUpsertList;
        		} catch(Exception e) {
	                responseStatus = 'error';
	                errorLogList.add(new LogService().createErrorLog('AccountingIntegrationSettingsService', 'getTaxCodes()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
	                                              integrationName, LogService.XERO, false));
	            }
            } else {
                responseStatus = 'error';
                errorLogList.add(new LogService().createErrorLog('AccountingIntegrationSettingsService', 'getTaxCodes()', response.getBody(), response.getStatusCode(), null, 
                                              integrationName, LogService.XERO, false));
            }
    	}
    	return responseStatus;
    }
    
    public static Map<String, String> parseOAuthStep1Response(String resParams) {
        Map<String, String> responseItemMap = new Map<String, String>();
        for(String s : resParams.split('&')) {
            responseItemMap.put(s.split('=')[0], s.split('=')[1]);
        }
        return responseItemMap;
    }
    
    public static void saveOauthTokenSecret(String oauthToken, String oauthTokenSecret, String integrationName) {
        IFW_IntegrationConfig__c configRec = getIntegrationConfig(integrationName);
        if(oauthToken != null) configRec.Access_Token__c = oauthToken;
        configRec.Access_Token_Secret__c = oauthTokenSecret;
        update configRec;
    }
    
    public static void resetAccessTokenSecret(String integrationName) {
        IFW_IntegrationConfig__c configRec = getIntegrationConfig(integrationName);
    	configRec.Access_Token_Secret__c = null;
    	update configRec;
    }
    
    public static IFW_IntegrationConfig__c getIntegrationConfig(String integrationName) {
        List<IFW_IntegrationConfig__c> integrationConfigList = [SELECT Consumer_Key__c, Consumer_Secret__c, Access_Token__c, Access_Token_Secret__c From IFW_IntegrationConfig__c 
                                                                        WHERE Integration_Name__c =: integrationName AND Enabled__c = false]; // Enabled__c = true AND 
        if(integrationConfigList.size() > 0) {
            return integrationConfigList[0];
        } else {
        	throw new BlackpurlException('No active integration');
        }
        
    }
    
    private static List<IFW_IntegrationConfig__c> getIntegrationConfigWithItems(String integrationName, Map<String, String> integrationEntityNameToActionMap) {
    	if(String.isBlank(integrationName)) {
    		throw new BlackpurlException('No active integration');
    	}
    	String query = 'SELECT Access_Token__c, Access_Token_Secret__c, Auth_Scheme__c, Bearer_Token__c, Certificate_Name__c, Certifcate_Password__c, ' +
    	    'Consumer_Key__c, Consumer_Secret__c, Enabled__c, Integration_Name__c, Grant_Type__c, Password__c, ' +
			'Username__c, Refresh_Token__c, Timeout__c, Token_Expiry__c, Token_Type__c, ' +
    					'(SELECT IFW_IntegrationConfig__c, Endpoint_URL__c, HTTP_Method__c, Timeout__c FROM IFW_IntegrationConfigItems__r ';
    	if(integrationEntityNameToActionMap != null && integrationEntityNameToActionMap.size() > 0) {
    		query += 'WHERE ';
    		for(String xeroEntityName : integrationEntityNameToActionMap.keySet()) {
    			if(integrationEntityNameToActionMap.get(xeroEntityName) == null) {
    				query += '(Entity_Name__c = \'' + xeroEntityName + '\' AND (Entity_Action__c = null)) OR ';
    			} else {
    				query += '(Entity_Name__c = \'' + xeroEntityName + '\' AND (Entity_Action__c includes (\'' + integrationEntityNameToActionMap.get(xeroEntityName) + '\'))) OR ';
    			}
    		}
    		query = query.subString(0, query.length() - 4);
    	}
    	
    	query += ') FROM IFW_IntegrationConfig__c WHERE Integration_Name__c =: integrationName AND Enabled__c = true';
    	return Database.query(query);													
    }
    
    private static List<GeneralAccountWrapper> getChartOfAccountsList() {
    	List<General_Account__c> generalAccountList = [SELECT Accounting_Id__c, Account_Name__c, Account_Number__c,
                                                                Account_Type__c, LastModifiedDate
                                                                 from General_Account__c 
                                                                 WHERE Is_Active__c = true 
                                                                 LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
		    
	    List<GeneralAccountWrapper> accountingList = new List<GeneralAccountWrapper>();
	    for(General_Account__c generalAcc : GeneralAccountList) {
	        accountingList.add(new GeneralAccountWrapper(generalAcc, USerInfo.getTimeZone().getDisplayName()));
	    }
	    return accountingList;
    }
    
    private static void saveAccountSettingsData(String providerName) {
    	Accounting_Settings__c accConfig = Accounting_Settings__c.getOrgDefaults();
    	accConfig.Provider_Name__c = providerName;
    	upsert accConfig;
    }
    
    private static void saveCompanyInfo(IntegrationCompanyWrapper companyJson) {
    	QuickBooks_Configurations__c integrationConfig = QuickBooks_Configurations__c.getOrgDefaults();
    	integrationConfig.Company_Name__c = companyJson.CompanyName;
    	integrationConfig.Company_Id__c = companyJson.CompanyId;
    	integrationConfig.Enable_QuickBooks__c = true;
    	upsert integrationConfig;
    }
    
    private static QB_TaxCode__c saveTaxCode(String taxCodeName, Boolean isActive, Boolean isTaxable, String accId, String applicableTaxRateStr, String taxApplicableOn, String rateValue) {
		QB_TaxCode__c taxCodeRec = new QB_TaxCode__c();
		taxCodeRec.Name = taxCodeName;
		taxCodeRec.Is_Active__c = isActive;
		taxCodeRec.Is_Taxable__c = isTaxable;
		taxCodeRec.Accounting_Id__c = accId;
        taxCodeRec.Applicable_QB_Tax_Rates__c = applicableTaxRateStr;
        taxCodeRec.Tax_Applicable_On__c = taxApplicableOn;
        taxCodeRec.Rate_Value__c = Decimal.valueOf(rateValue);
		return taxCodeRec;
    }
}
