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
global class ACVSelectionController extends RefEdgeEditionFeatures {
    public boolean isSLDS { get; set; }

     /**
     * Constructor
     */
    global ACVSelectionController(ApexPages.StandardController controller) {
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
    }
    
    /**
     * Method to check Permissions
     */
    private static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> { 
        										UtilityController.appNamespace() + 'ACV_Amount_Field__c',
        										UtilityController.appNamespace() + 'ACV_Basis__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    /**
     * Method to get Custom Setting and Opportunity Fields
     * Created By: Dixita @August 2019
     */
    @RemoteAction
    global static String getFields() {
        if (checkPermissions() || !test.isRunningTest()) {
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            cs.ACV_Amount_Field__c = cs.ACV_Amount_Field__c == null ? 'Amount' : cs.ACV_Amount_Field__c;
            cs.ACV_Basis__c = cs.ACV_Basis__c == null ? ConstantsController.CALENDAR_YEAR : cs.ACV_Basis__c;
            Map<String,String> oppFields = new Map<String,String>();
            oppFields.put('ACV_Amount_Field',cs.ACV_Amount_Field__c);
            oppFields.put('ACV_Basis',cs.ACV_Basis__c);
            Schema.SObjectType objType = CRUDAndFLSCheckController.sObjectsMap.get('Opportunity');
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Map <String,Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            for (String key : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(key).getDescribe();
                if (dfr.getType().name() == 'Currency' || dfr.getType().name() == 'Double' || dfr.getType().name() == 'Integer' || dfr.getType().name() == 'Long') {
                    oppFields.put(dfr.getName(),dfr.getLabel());
                }
            }
            return JSON.serialize(oppFields);
        } else {
            return 'error@@' + CRUDAndFLSCheckController.getErrorMsg();
        }
    }
    /**
     * Method to get Custom Setting field ConsiderNoLongerNeeded
     * Created By: Dixita @August 2019
     */
    @RemoteAction
    global static String saveCS(String aCV_Amount_Field, String aCV_Basis) { 
    	
    	try {
	    	Custom_Settings__c cs = UtilityController.getCustomSettings();
	    	cs.ACV_Amount_Field__c = aCV_Amount_Field;
            cs.ACV_Basis__c = aCV_Basis;
	    	update cs;
    	} catch(Exception e) {
    		return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
        return 'Success';
    }
}