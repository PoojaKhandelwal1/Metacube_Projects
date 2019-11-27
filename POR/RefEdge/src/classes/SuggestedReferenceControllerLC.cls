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
 * Lightning Component : SuggestedReference 
 * Description : Class is used for evoking component action on certain custom setting criteria
 * Created By: Rajneesh @June 10 2019
 */
public with sharing class SuggestedReferenceControllerLC {
    @AuraEnabled
    public static String nameSpace() {
        return UtilityController.appNamespace();
    }
    @AuraEnabled
    public static List<String> opportunityStageChange(id oppid) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();        
        List<String> strList = new List<String>();
        
        //	Get Information of stage change and delete the record simultanously
        if (cs != null && cs.Enable_Reference_Prompt__c) {
          	List<Data_Mapping__c>  dataMapList = new List<Data_Mapping__c>([SELECT Id, Name, Label__c, Field_API_Name__c FROM Data_Mapping__c WHERE Field_API_Name__c =: oppid]);
        	
            if (dataMapList.Size() > 0) {
            	Opportunity oppr = [SELECT Id, Name, StageName, AccountId FROM Opportunity WHERE Id =: oppid];
            		strList.add('isConfirmation@@true');
                	strList.add('stageChangeValue@@'+dataMapList[0].Label__c);
            		strList.add('msgToShow@@'+cs.Prompt_Message__c);
               
            	if (oppr.StageName != null && oppr.StageName != '') {
                
                    if ((cs.Show_Matching_Reference_Accounts_link__c && cs.Account_Stages__c != null && cs.Account_Stages__c != '' && cs.Account_Stages__c.contains(oppr.StageName)) &&
                       (cs.Show_Matching_Reference_Content_link__c && cs.Content_Stages__c != null && cs.Content_Stages__c != '' && cs.Content_Stages__c.contains(oppr.StageName))) {
                    	strList.add('sectionToShow@@Both');
                        
                    } else if (cs.Show_Matching_Reference_Content_link__c && cs.Content_Stages__c != null && cs.Content_Stages__c != '' && cs.Content_Stages__c.contains(oppr.StageName)) {
                      	strList.add('sectionToShow@@Content');
                                        
                    } else if (cs.Show_Matching_Reference_Accounts_link__c && cs.Account_Stages__c != null && cs.Account_Stages__c != '' && cs.Account_Stages__c.contains(oppr.StageName)) {
                        strList.add('sectionToShow@@Account');
                    } else {
            		    strList.clear();
                    }
            	} 
                ConstantsController.shouldDataMappingProcessed = true;
                delete dataMapList;               
        	}            
        }
        return strList;
    }
}