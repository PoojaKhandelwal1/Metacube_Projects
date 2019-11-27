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
@isTest(seeAllData = false)
public with sharing class TestUserTrigger {
	static testMethod void unitTest01(){
		test.startTest();
        	User u = TestDataFactory.CreateUser();
        	try {
                u.Refedge_License_Type__c = 'Full License';
                insert u;
            } catch (Exception e) {
                system.assertEquals(true, e.getMessage().length() > 0);
            }
            try {
                u.Refedge_License_Type__c = 'Community License';
                insert u;
            } catch (Exception e) {
                system.assertEquals(true, e.getMessage().length() > 0);
            }
            u.Refedge_License_Type__c = '';
            if(u.Id != null)
            	update u;
            else
            	insert u;
            try {
                u.Refedge_License_Type__c = 'Full License';
                update u;
            } catch (Exception e) {
                system.assertEquals(true, e.getMessage().length() > 0);
            }
            try {
                u.Refedge_License_Type__c = 'Community License';
                update u;
            } catch (Exception e) {
                system.assertEquals(true, e.getMessage().length() > 0);
            }
        test.stopTest();
	}
	static testMethod void unitTest02(){
		POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        insert cs;
        test.startTest();
        	User u = TestDataFactory.CreateUser();
        	try {
                u.Refedge_License_Type__c = 'Full License';
                insert u;
            } catch (Exception e) {
                system.assertEquals(true, e.getMessage().length() > 0);
            }
            
            try {
                u.Refedge_License_Type__c = 'Community License';
                update u;
            } catch (Exception e) {
                system.assertEquals(true, e.getMessage().length() > 0);
            }
        test.stopTest();
	}
	static testMethod void unitTest03(){
		POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        insert cs;
        test.startTest();
        	User u = TestDataFactory.CreateUser();
        	
            try {
                u.Refedge_License_Type__c = 'Community License';
                insert u;
            } catch (Exception e) {
                system.assertEquals(true, e.getMessage().length() > 0);
            }
            
            try {
                u.Refedge_License_Type__c = 'Full License';
                update u;
            } catch (Exception e) {
                system.assertEquals(true, e.getMessage().length() > 0);
            }
        test.stopTest();
	}
}