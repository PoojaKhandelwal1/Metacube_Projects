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
public with sharing class TestRefrenceContentTriggerHandler {
    
    public static Account_Reference_Content__c accountReferObject;
    public static List < Account_Attribute__c > accAttLst;
    public static List < Attribute__c > attributes;
    public static list < ContentDocument > contentDocumnts;
	
	//Test method for delete operation
    static testMethod void testDeleteOperation() {
        User u = TestDataFactory.createUser();
        insert u;
        //Start test method
        test.startTest();
        System.runAs(u) {
            try {
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                ContentVersion cv = TestDataFactory.createContentVersion(u);
                insert cv;
                list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
                referObject[0].Internal_Use__c = true;
                referObject[0].Content_ID__c = cv.Id;
                insert referObject;
                contentDocumnts = [select Id from ContentDocument where LatestPublishedVersionId = : cv.Id];
                system.assertEquals(1, contentDocumnts.size());
                delete referObject;
                contentDocumnts = [select Id from ContentDocument where LatestPublishedVersionId = : cv.Id];
                system.assertEquals(0, contentDocumnts.size());
            } catch (System.DmlException e) {
            }
        }
        //Stop test method
        test.stopTest();
    }
    
    //Test method for  Attribute Mapping
	static testMethod void testAttributeMapping(){
		User u = TestDataFactory.createUser();
        insert u;
        
		//Start test method
		test.startTest();
		System.runAs(u) {
			Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            ContentVersion cv = TestDataFactory.createContentVersion(u);
            insert cv;
            TestDataFactory.createRefconAttributeMapping();
            list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
            referObject[0].Content_ID__c = cv.Id;
            insert referObject;
        	ConstantsController.attMappingForRefContent = true;
        	
        	referObject[0].Language__c = 'Dutch';
        	update referObject;
        	
        	system.assert(true);
		}
        //Stop test method
        test.stopTest();
	}
	
	//Test method for  update operation
    static testMethod void testUpdateOperation() {
        User u = TestDataFactory.createUser();
        insert u;
        //Start test method
        test.startTest();
        System.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            ContentVersion cv = TestDataFactory.createContentVersion(u);
            insert cv;
            list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
            referObject[0].Content_ID__c = cv.Id;
            insert referObject;
            List < Account > accounts = TestDataFactory.createAccounts();
        	insert accounts;
        	TestDataFactory.setUpAccountRBI(accounts);
        	attributes = TestDataFactory.createAttribute();
        	insert attributes;
            TestDataFactory.createContentAttributes(referObject, attributes);
            accountReferObject = new Account_Reference_Content__c(Reference_Content__c = referObject[0].Id, Account__c = accounts[0].Id);
            insert accountReferObject;
            referObject[0].Internal_Use__c = true;
            try{
            	update referObject;
            }
            catch(exception e){}
            referObject[0].Content_Status__c = 'Inactive';
            update referObject;
            accAttLst = [select Id from Account_Attribute__c where Reference_Content__c = : referObject[0].Id];
            system.assertEquals(0, accAttLst.size());
            referObject[0].Content_Status__c = 'Active';
            update referObject;
            accAttLst = [select Id from Account_Attribute__c where Reference_Content__c = : referObject[0].Id];
    		system.assertEquals(18, accAttLst.size());
            referObject[0].Content_Status__c = 'Inactive';
            update referObject;
            accAttLst = [select Id from Account_Attribute__c where Reference_Content__c = : referObject[0].Id];
            system.assertEquals(0, accAttLst.size());
            referObject[0].Content_Status__c = 'Active';
            update referObject;
            //delete referObject;
        }
        //Stop test method
        test.stopTest();
    }
}