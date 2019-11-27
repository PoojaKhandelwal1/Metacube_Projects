/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, 
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, 
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR, 
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF 
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING, 
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS 
 * WRITTEN CONSENT FROM COMPANY.
 */
/**
 * VF Page: ChangeAllNLNRequests.page, DefaultReferenceUseLimits.page
 * Description: controller for changing the default use limits
 * Created By: Rekha Jangir @23 August 2017
 */
public with sharing class ChangeAllNLNRequestsControllerSLDS extends RefEdgeEditionFeatures {
    
    /**
     * Constructor
     */
    public ChangeAllNLNRequestsControllerSLDS(ApexPages.StandardController controller) {}
    
    /**
     * Method to check Permissions
     */
    private static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> { 
        										UtilityController.appNamespace() + 'RUL_Period_Contact__c',
        										UtilityController.appNamespace() + 'RUL_Activities_Contact__c',
        										UtilityController.appNamespace() + 'RUL_Period__c',
        										UtilityController.appNamespace() + 'RUL_Activities__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    /**
     * Method to get Custom Setting field ConsiderNoLongerNeeded
     * Created By: Rekha Jangir @23 August 2017
     */
    @RemoteAction
    public static CustomSettingWrapper getConsiderNoLongerNeeded() { 
        CustomSettingWrapper csw = new CustomSettingWrapper();
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	csw.ConsiderNoLongerNeeded = cs.Consider_No_longer_needed_a_use__c;
        return csw;
    }
    
    /**
     * Method to get Custom Setting field ConsiderNoLongerNeeded
     * Created By: Rekha Jangir @24 August 2017
     */
    @RemoteAction
    public static String saveCS(Boolean ConsiderNoLongerNeeded) { 
    	
    	try {
    		
	    	Custom_Settings__c cs = UtilityController.getCustomSettings();
	    	cs.Consider_No_longer_needed_a_use__c = ConsiderNoLongerNeeded;
	    	update cs;
    	} catch(Exception e) {
    		return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
        return '';
    }
    
    
    /**
     * Method to get Custom Setting field ConsiderNoLongerNeeded
     * Created By: Rekha Jangir @24 August 2017
     */
    @RemoteAction
    public static String saveCSRUL(String cswJSON) { 
    	
    	try {
    		
    		if (checkPermissions()) {
	    		CustomSettingWrapper csw = (CustomSettingWrapper)JSON.deserialize(cswJSON, CustomSettingWrapper.class);
		    	Custom_Settings__c cs = UtilityController.getCustomSettings();
		    	ConstantsController.updateExistingAccounts = csw.updateAllAccount;
	            ConstantsController.updateExistingContacts = csw.updateAllContact;
		    	cs.RUL_Activities__c = csw.accountRULActivities;
		    	cs.RUL_Period__c = csw.accountRULPeriod;
		    	cs.RUL_Activities_Contact__c = csw.contactRULActivities;
		    	cs.RUL_Period_Contact__c = csw.contactRULPeriod;
		    	update cs;
    		} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
    	} catch(Exception e) {
    		return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
        return '';
    }
    
    /**
     * Method to get Custom Setting
     * Created By: Rekha Jangir @23 August 2017
     */
    @RemoteAction
    public static CustomSettingWrapper getCustomSetting() { 
        CustomSettingWrapper csw = new CustomSettingWrapper();
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	csw.updateAllAccount = false;
    	csw.updateAllContact = false;
    	csw.accountRULActivities = cs.RUL_Activities__c;
    	csw.accountRULPeriod = cs.RUL_Period__c;
    	csw.contactRULActivities = cs.RUL_Activities_Contact__c;
    	csw.contactRULPeriod = cs.RUL_Period_Contact__c;
        return csw;
    }
    
    /**
     * Wrapper class for Custom Setting
     * Created By: Rekha Jangir @23 August 2017
     */
    public class CustomSettingWrapper {
    	public Boolean updateAllAccount { get; set; }
    	public Boolean updateAllContact { get; set; }
    	public Decimal accountRULActivities { get; set; }
    	public Decimal contactRULActivities { get; set; }
    	public Decimal accountRULPeriod { get; set; }
    	public Decimal contactRULPeriod { get; set; }
        public Boolean ConsiderNoLongerNeeded { get; set; }
    }
}