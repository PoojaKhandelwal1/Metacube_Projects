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
 * Class: NewAttributeController
 * Description : class to test and cover NewAttributeController
 * Modified by: Rekha Jangir @19 June 2017
 */
@isTest(seeAllData = false)
private class TestNewAttributeController {
    
    /*
     * Method to cover edit attribute functionality
     * Modified By: Rekha Jangir @19 June 2017
     */
    static testMethod void testSaveAttributeEdit() {
        Attribute__c att1 = new Attribute__c(name = 'TestAtt');
        insert att1;
        Attribute__c att2 = new Attribute__c(name = 'TestAtt other');
        insert att2;
        Attribute__c att21 = new Attribute__c(name = 'TestAtt child', Level__c = 1, Parent__c = att2.Id);
        insert att21;
        Attribute__c att = new Attribute__c(name = 'TestAtt', Inheritable__c = true, Parent__c = att1.Id);
        insert att;
        System.assertEquals(att2.id,att21.Parent__c);
        //Start test method
        test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(att);
            NewAttributeController newAttObj = new NewAttributeController(controller);
            PageReference pg = newAttObj.saveAttribute(); 
            newAttObj.att.parent__c = att2.Id;
            newAttObj.att.Inheritable__c = false;            
            pg = newAttObj.saveAttribute(); 
            
            newAttObj.att.parent__c = att21.Id;
            pg = newAttObj.saveAttribute(); 
        //Stop test method
        test.stopTest();
    }
    
    /*
     * Method to cover create attribute functionality
     * Modified By: Rekha Jangir @19 June 2017
     */
    static testMethod void testSaveAttributeNew() {
        Attribute__c att1 = new Attribute__c(name = 'TestAtt');
        insert att1;
        system.assertEquals('TestAtt',att1.Name);
        //Start test method
        test.startTest();
            PageReference pageRef = Page.NewAttribute;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', String.valueOf(att1.Id));
            ApexPages.StandardController controller = new ApexPages.StandardController(new Attribute__c());
            NewAttributeController newAttObj = new NewAttributeController(controller);
            PageReference pg = newAttObj.saveAttribute(); 
            
        //Stop test method
        test.stopTest();
    }
    
    /*
     * Method to cover edit attribute functionality with save and new
     * Modified By: Rekha Jangir @19 June 2017
     */
    static testMethod void testSaveAndNewEdit() {
        Attribute__c att1 = new Attribute__c(name = 'TestAtt');
        insert att1;
        Attribute__c att2 = new Attribute__c(name = 'TestAtt other');
        insert att2;
        Attribute__c att21 = new Attribute__c(name = 'TestAtt child', Level__c = 1, Parent__c = att2.Id);
        insert att21;
        System.assertEquals(att2.id,att21.Parent__c);
        Attribute__c att = new Attribute__c(name = 'TestAtt', Inheritable__c = true, Parent__c = att1.Id);
        insert att;
        
        //Start test method
        test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(att);
            NewAttributeController newAttObj = new NewAttributeController(controller);
            PageReference pg = newAttObj.saveAndNew(); 
            newAttObj.att.parent__c = att2.Id;
            newAttObj.att.Inheritable__c = false;
            pg = newAttObj.saveAndNew(); 
            newAttObj.att.parent__c = att21.Id;
            pg = newAttObj.saveAndNew(); 
            newAttObj.cancel();
        //Stop test method
        test.stopTest();
    }
    
    /*
     * Method to cover create attribute functionality with save and new
     * Modified By: Rekha Jangir @19 June 2017
     */
    static testMethod void testSaveAndNewAdd() {
        Attribute__c att1 = new Attribute__c(name = 'TestAtt');
        insert att1;
        system.assertEquals('TestAtt',att1.Name);
        //Start test method
        test.startTest();
            PageReference pageRef = Page.NewAttribute;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', String.valueOf(att1.Id));
            ApexPages.StandardController controller = new ApexPages.StandardController(new Attribute__c());
            NewAttributeController newAttObj = new NewAttributeController(controller);
            PageReference pg = newAttObj.saveAndNew();
            newAttObj.cancel();
        //Stop test method
        test.stopTest();
    }
    
    /*
     * Method to cover exceptions
     * Modified By: Rekha Jangir @19 June 2017
     */
    static testMethod void testException() {
        Attribute__c att1 = new Attribute__c(name = 'TestAtt');
        insert att1;
        system.assertEquals('TestAtt',att1.Name);
        //Start test method
        test.startTest();
            PageReference pageRef = Page.NewAttribute;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', String.valueOf(att1.Id));
            ApexPages.StandardController controller = new ApexPages.StandardController(new Attribute__c());
            NewAttributeController newAttObj = new NewAttributeController(controller);
            delete att1;
            
            try {
                newAttObj.saveAttribute();
            } catch (Exception e) {}
            
            try {
                newAttObj.saveAndNew();
            } catch (Exception e) {}
            
            newAttObj.cancel();
        //Stop test method
        test.stopTest();
    }
    
    /*
     * Method to cover edit inheritable attribute functionality
     * Modified By: Rekha Jangir @19 June 2017
     */
    static testMethod void testParentInheritableChange() {
        Attribute__c att = new Attribute__c(name = 'TestAtt');
        insert att;
        system.assertEquals('TestAtt',att.Name);
        //Start test method
        test.startTest();
        	
            ApexPages.StandardController controller = new ApexPages.StandardController(att);
            NewAttributeController newAttObj = new NewAttributeController(controller);
            newAttObj.att.Inheritable__c = true;
            newAttObj.answer = true;
            PageReference pg = newAttObj.saveAttribute();
            pg = newAttObj.saveAndNew();
        	newAttObj.Cancel();
        //Stop test method
        test.stopTest();
    }
    
    
    /*
     * Method to cover edit attribute name functionality in mapped attribute
     * Modified By: Rekha Jangir @19 June 2017
     */
    static testMethod void testMappedParentNameChange() {
        List<Attribute_Mapping__c> mappings = TestDataFactory.createAttributeMapping();
        List<Attribute__c> attributes = [SELECT Id FROM Attribute__c WHERE Level__c = 1];
        //Start test method
        test.startTest();
        	
            ApexPages.StandardController controller = new ApexPages.StandardController(attributes[0]);
            NewAttributeController newAttObj = new NewAttributeController(controller);
            newAttObj.att.Name = 'Test new name';
            PageReference pg = newAttObj.saveAttribute();
            pg = newAttObj.saveAndNew();
            
            attributes = [SELECT Id FROM Attribute__c WHERE Level__c = 0];
            system.assertNotEquals(0,attributes.size());
            controller = new ApexPages.StandardController(attributes[0]);
            newAttObj = new NewAttributeController(controller);
            newAttObj.att.Name = 'Test new name';
            pg = newAttObj.saveAttribute();
            pg = newAttObj.saveAndNew();
        //Stop test method
        test.stopTest();
    }
}