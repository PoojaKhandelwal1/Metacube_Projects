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
 * Class: LeadTriggerHandler and LeadTrigger
 * Description : class to test and cover LeadTriggerHandler and LeadTrigger 
 * Created by: Rekha Jangir @14 April 2017
 */
@isTest(seeAllData = false)
public with sharing class TestLeadTriggerHandler {
    
    /*
     * Method to cover trigger when lead is converted
     * Created By: Rekha Jangir @14 April 2017
     */
    public static testMethod void assignOppInReferenceReqOnLeadConvert() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Lead leadObj = new Lead(LastName = 'test Lead', Company = 'metacube');
        insert leadObj;
        
        Reference_Request__c refReq = new Reference_Request__c(Reference_Request_Status__c = 'In Progress', Lead__c = leadObj.Id);
        insert refReq;
        
        //Start test method
        test.startTest();
        	Database.LeadConvert lc = new database.LeadConvert();
			lc.setLeadId(leadObj.id);
			
			LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
			lc.setConvertedStatus(convertStatus.MasterLabel);
			
			Database.LeadConvertResult lcr = Database.convertLead(lc);
			System.assert(lcr.isSuccess());
			
        //Stop test method
        test.stopTest();
    }
}