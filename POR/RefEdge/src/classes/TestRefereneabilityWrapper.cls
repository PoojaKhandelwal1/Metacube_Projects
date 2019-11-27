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
public class TestRefereneabilityWrapper {

    //Test Method
    static testMethod void setReferenceabilityTypesTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        //Start test method
        test.startTest();
            ReferenceabilityWrapper refWrapObj = new ReferenceabilityWrapper();
            refWrapObj.referenceabilityTypeId = refTypes[0].Id;
            List < ReferenceabilityWrapper.ReferenceabilityTypeWrapper > listRefTypeWrap = refWrapObj.referenceabilityTypeWrapper;
            system.assertEquals(listRefTypeWrap.size(), 5);
            refWrapObj.setReferenceabilityTypes();
            system.assertEquals(refWrapObj.selectedReferenceabilityTypes.size(), 1);
            refWrapObj.setReferenceabilityTypes();
            system.assertEquals(refWrapObj.selectedReferenceabilityTypes.size(), 0);
        //Stop test method
        test.stopTest();
    }
	//Test Method
    static testMethod void selectAllReferenceabilityTypesTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        //Start test method
        test.startTest();
            ReferenceabilityWrapper refWrapObj = new ReferenceabilityWrapper();
            refWrapObj.selectAllReferenceabilityTypes();
            system.assertEquals(refWrapObj.selectedReferenceabilityTypes.size(), 5);
        //Stop test method
        test.stopTest();
    }
	
	//Test Method
    static testMethod void clearAllReferenceabilityTypesTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        //Start test method
        test.startTest();
            ReferenceabilityWrapper refWrapObj = new ReferenceabilityWrapper();
            refWrapObj.selectAllReferenceabilityTypes();
            system.assertEquals(refWrapObj.selectedReferenceabilityTypes.size(), 5);
            refWrapObj.clearAllReferenceabilityTypes();
            system.assertEquals(refWrapObj.selectedReferenceabilityTypes.size(), 0);
            refWrapObj.setDefaultReferenceabilityType(new set<Id>{refTypes[0].Id});
        //Stop test method
        test.stopTest();
    }
	
	//Test Method
    static testMethod void showReferenceabilityAlphabetTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
		//Start test method       
        test.startTest();
            ReferenceabilityWrapper refWrapObj = new ReferenceabilityWrapper();
            refWrapObj.character = 'A';
            refWrapObj.showReferenceabilityAlphabet();
            List < ReferenceabilityWrapper.ReferenceabilityTypeWrapper > listRefTypeWrap = refWrapObj.referenceabilityTypeWrapper;
            system.assertEquals(listRefTypeWrap.size(), 1);
            refWrapObj.character = 'All';
            refWrapObj.showReferenceabilityAlphabet();
            listRefTypeWrap = refWrapObj.referenceabilityTypeWrapper;
            system.assertEquals(listRefTypeWrap.size(), 5);
            refWrapObj.character = 'other';
            refWrapObj.showReferenceabilityAlphabet();
            listRefTypeWrap = refWrapObj.referenceabilityTypeWrapper;
            //system.assertEquals(1, listRefTypeWrap.size());
        //Stop test method
        test.stopTest();
    }
}