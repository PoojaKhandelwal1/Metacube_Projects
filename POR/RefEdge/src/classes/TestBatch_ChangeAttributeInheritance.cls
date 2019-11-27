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
@isTest(SeeAllData=false)
public with sharing class TestBatch_ChangeAttributeInheritance {
	public static list < Attribute__c > attributes;
	/**
     * Unit Test Method
     */
    static testMethod void myUnitTest01() {
        try{
            createData();
            attributes[0].Inheritable__c = false;
            Batch_ChangeAttributeInheritance batchrrf = new Batch_ChangeAttributeInheritance(attributes[0],true);
        	ID batchprocessid = database.executebatch(batchrrf);
            test.startTest();
            	System.assertEquals(attributes[0].Inheritable__c, false);
            test.stopTest();
        }Catch(Exception e){
            
        }
    }
    /**
     * Unit Test Method
     */
    static testMethod void myUnitTest02() {
        try{
            createData();
            test.startTest();
                attributes[0].Inheritable__c = false;
                Batch_ChangeAttributeInheritance batchrrf = new Batch_ChangeAttributeInheritance(attributes[0],false);
            	ID batchprocessid = database.executebatch(batchrrf);
            	System.assertEquals(attributes[0].Inheritable__c, false);
            test.stopTest();
        }Catch(Exception e){
            
        }
    }
    /**
     * Unit Test Method
     */
    static testMethod void myUnitTest03() {
        try{
            createData();
            test.startTest();
                attributes[0].Inheritable__c = true;
                Batch_ChangeAttributeInheritance batchrrf = new Batch_ChangeAttributeInheritance(attributes[0],false);
            	ID batchprocessid = database.executebatch(batchrrf);
            	System.assertEquals(attributes[0].Inheritable__c, true);
            test.stopTest();
        }Catch(Exception e){
            
        }
    }
   	/**
     * create test data
     */
	private static void createData(){
		try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
            insert labels;
            attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
            attributes[0].Inheritable__c = true;
            attributes[0].Level__c = 0;
            insert attributes;
            list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
            insert childAttributes;
            list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
            insert childAttributes1;
            list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
            insert childAttributes2;
            list<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
            insert refContents;
            list < Account_Reference_Content__c > accountContents = TestDataFactory.createAccountRefContents(new list< Account > {accounts[0]}, refContents);
            insert accountContents;
            list<Attribute__c> childatts = [select Id from Attribute__c where Id != :attributes[0].Id];
            TestDataFactory.createAttributeLabels(labels, childatts);
            TestDataFactory.createAccountAttributes(new list< Account > {accounts[0]}, childAttributes2,true);
        }Catch(Exception e){
            
        }
	} 	
}