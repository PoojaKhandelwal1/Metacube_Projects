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
public with sharing class TestRefContentAttMappingExtension {
    
    //Unit Test Method
    static testMethod void myUnitTest01() {
        List < Attribute_Mapping__c > attrMapping = setUpAttributeMapping();
        test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(attrMapping[0]);
            RefContentAttMappingExtension testObj = new RefContentAttMappingExtension(sc);
            system.assertEquals(2,testObj.attMappings.size()); 
        test.stopTest();
    }
    //Attribute_Mapping Setup
    private static List < Attribute_Mapping__c > setUpAttributeMapping() {
        List < Attribute_Mapping__c > attMapping = new List < Attribute_Mapping__c > ();
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Reference Content',Field__c = 'Content_Status__c',Attribute_Name__c ='test',Filter_Label_Name__c = 'test',Field_Api_Name__c = 'Content_Status__c',Is_Related_Mapping__c = false));
        attMapping.add(new Attribute_Mapping__c(Object__c = 'Reference Content',Field__c = 'Content_Status__c',Attribute_Name__c ='test',Filter_Label_Name__c = 'test',Field_Api_Name__c = 'Content_Status__c',Is_Related_Mapping__c = false));
        insert attMapping;
        return attMapping;
    }
}