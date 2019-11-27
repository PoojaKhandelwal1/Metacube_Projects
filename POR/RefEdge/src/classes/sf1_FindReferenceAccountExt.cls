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
 * VF Page: sf1_FindReferenceAccounts
 * Description: Class to check minimum stage of opportunity on redirection on Refsearch
 * Modified by: Rekha @Feb 3 2017
 */
public with sharing class sf1_FindReferenceAccountExt {
    /**
     * Properties and variables
     */
    public String minimumStageError { get; set; }
    private Custom_Settings__c cs;
    public Opportunity opp { get; set; }
    public boolean isSLDS { get; set; }
	public boolean isSF1 { get; set; }
	
    /**
     * Constructor
     */
    public sf1_FindReferenceAccountExt(ApexPages.standardController controller) {
        cs = UtilityController.getCustomSettings();
        minimumStageError = '';
        
        if (cs.Minimum_Sales_Stage__c != null && cs.Minimum_Sales_Stage__c != '') {
            Decimal minimumStageCount, opporunityStageCount, currentCount;
            opp = (Opportunity) controller.getRecord();
            List<Opportunity> opps = [SELECT StageName FROM Opportunity WHERE Id = : opp.Id];
            List<String> lstPickvals = new List<String>();
            Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get('Opportunity'); //From the Object Api name retrieving the SObject
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pick_list_values = field_map.get('StageName').getDescribe().getPickListValues();
            minimumStageCount = opporunityStageCount = currentCount = 0;
            
            for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            	
                if (cs.Minimum_Sales_Stage__c == a.getValue()) {
                    minimumStageCount = currentCount;
                }
                
                if (opps[0].StageName == a.getValue()) {
                    opporunityStageCount = currentCount;
                }
                ++currentCount;
            }
            
            if (opporunityStageCount < minimumStageCount) {
                minimumStageError = label.MinimumSalesStage.replace('@@@', cs.Minimum_Sales_Stage__c);
            }
        }
        
        if (UserInfo.getUiTheme() == 'Theme4d') {
            system.debug('*********SLDS');
            isSLDS = true;
            isSF1 = false;
        } 
        else if (UserInfo.getUiTheme() == 'Theme4t') {
        	system.debug('*********SF1');
        	isSF1 = true;
        	isSLDS = false;
        } else {
            system.debug('********normal');
            isSLDS = false;
            isSF1 = false;
        }
    }
}