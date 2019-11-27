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
public with sharing class TestAttributeMappingTrigger {
    
    //Test Method for Insertion
    static testMethod void testAttMappingInsert(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        list<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
        insert referObjects;
        TestDataFactory.createAttributeMapping();
        TestDataFactory.createContactAttributeMapping();
        TestDataFactory.createRefconAttributeMapping();
        //Start Test Method
        test.startTest();
            try{
                list<Attribute_Mapping__c> createdAttMappings = [select Id from Attribute_Mapping__c];
                system.assertEquals(3,createdAttMappings.size());
            }catch(Exception e){
                
            }
    }
    //Test method for Deletion
    static testMethod void testAttMappingDelete(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        list<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
        insert referObjects;
        TestDataFactory.createAttributeMapping();
        TestDataFactory.createContactAttributeMapping();
        TestDataFactory.createRefconAttributeMapping();
        //Start test method
        test.startTest();
            try{
                list<Attribute_Mapping__c> attMappingRecords = [select Id from Attribute_Mapping__c];
                delete attMappingRecords[0];
                list<Attribute_Mapping__c> createdAttMappings = [select Id from Attribute_Mapping__c];
                system.assertEquals(2,createdAttMappings.size());
            }catch(Exception e){
                
            }
    }
}