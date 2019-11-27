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
public class TestAttributeWrapper {

    //Test method for mapping of all Attribute Label
    static testMethod void mapAllAttributeLabelTest() {
        list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(new list< Attribute__c > {attributes[0]}, 1, 1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributes1;
        list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
        insert childAttributes2;
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        list<Attribute__c> tempAtt = [select Id,level__c from Attribute__c where level__c != 0];
        TestDataFactory.createAttributeLabels(labels, tempAtt);
        
        //Start test method
        Test.startTest();
            AttributeWrapper attWrapObj = new AttributeWrapper();
            Map < String, List < AttributeWrapper.AttributesLabelWrapper >> mapTemp = attWrapObj.mapAllAttributesLabel;
            system.assertNotEquals(mapTemp.size(), 3);
            system.assertEquals((mapTemp.get(labels[0].Id)).size(), 1);
            attWrapObj.selectedLabelId = labels[0].Id;
            //system.assertNotEquals(attWrapObj.labelName, null);
            map < String, set < String >> labelAttrMap = new map < String, set < String >> ();
            labelAttrMap.put(labels[0].Id,new set<String>{tempAtt[0].Id});
            attWrapObj.setDefaultAttributeLabels(labelAttrMap);
            Data_Mapping__c DM = new Data_Mapping__c (Field_API_Name__c=labels[0].Id, From_Mapping__c = true);
            ConstantsController.shouldDataMappingProcessed = true;
            mapTemp = attWrapObj.mapAllAttributesLabel;
            insert DM;
        //stop test method
        Test.stopTest();
    }

    //Test method for setting Attribute
    static testMethod void setAttributeTest() {
        list< Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        list < Attribute__c > attributes = TestDataFactory.createAttribute();
        attributes[0].Level__c = 1;
        attributes[1].Level__c = 2;
        attributes[2].Level__c = 3;
        insert attributes;
        TestDataFactory.createAttributeLabels(labels, attributes);
        //start test method
        Test.startTest();
            AttributeWrapper attWrapObj = new AttributeWrapper();
            attWrapObj.selectedLabelId = labels[0].Id;
            attWrapObj.attributeId = attributes[0].Id;
            List < AttributeWrapper.AttributesLabelWrapper > listTemp = attWrapObj.getAttributesByLabel();
            system.assertEquals(listTemp.size(), 1);
            attWrapObj.setAttributes();
            system.assertEquals(listTemp[0].fontWeight, ConstantsController.BOLD);
            attWrapObj.setAttributes();
            system.assertEquals(listTemp[0].fontWeight, ConstantsController.NORMAL);
        //stop test method
        Test.stopTest();
    }
    
    //Test method 
    static testMethod void clearSelectedAttributeTypesTest() {
        list< Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        list < Attribute__c > attributes = TestDataFactory.createAttribute();
        attributes[0].Level__c = 1;
        attributes[1].Level__c = 2;
        attributes[2].Level__c = 3;
        insert attributes;
        TestDataFactory.createAttributeLabels(labels, attributes);
        Test.startTest();
            AttributeWrapper attWrapObj = new AttributeWrapper();
            attWrapObj.showAttributeAlphabetically();
            attWrapObj.selectedLabelId = labels[0].Id;
            attWrapObj.attributeId = attributes[0].Id;
            List < AttributeWrapper.AttributesLabelWrapper > listTemp = attWrapObj.getAttributesByLabel();
            attWrapObj.setAttributes();
            system.assertEquals(listTemp[0].fontWeight, ConstantsController.BOLD);
            attWrapObj.clearSelectedAttributeTypes();
            system.assertEquals(listTemp[0].fontWeight, ConstantsController.NORMAL);
            attWrapObj.selectAllAttributeTypes();
        Test.stopTest();
    }
    
    //Test method for Character Starts with A
    static testMethod void isCharacterStartWithA() {
        list< Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        list < Attribute__c > attributes = TestDataFactory.createAttribute();
        attributes[0].Level__c = 1;
        attributes[1].Level__c = 2;
        attributes[2].Level__c = 3;
        insert attributes;
        TestDataFactory.createAttributeLabels(labels, attributes);
        Test.startTest();
            AttributeWrapper attWrapObj = new AttributeWrapper();
            attWrapObj.showAttributeAlphabetically();
            attWrapObj.selectedLabelId = labels[0].Id;
            attWrapObj.attributeId = attributes[0].Id;
            attWrapObj.character = 'R';
            List < AttributeWrapper.AttributesLabelWrapper > listTemp = attWrapObj.getAttributesByLabel();
            attWrapObj.setAttributes();
            system.assertEquals(listTemp[0].fontWeight, ConstantsController.BOLD);
            attWrapObj.character = 'other';
            listTemp = attWrapObj.getAttributesByLabel();
        Test.stopTest();
    }
    
}