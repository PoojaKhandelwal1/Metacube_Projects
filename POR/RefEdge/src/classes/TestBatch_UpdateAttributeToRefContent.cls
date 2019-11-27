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
public class TestBatch_UpdateAttributeToRefContent {
	
	 /**
     * Method to call Constructor
     */
    static testmethod void myUnitTest01() {
		
		List<Reference_Content__c> referObjects = TestDataFactory.createMultipleReferenceContent();
		insert referObjects;
		
		List<Attribute__c > attriList = New List<Attribute__c >();
		Attribute__c industAttribute = new Attribute__c();
		industAttribute.Name = 'Industry';
		attriList.add(industAttribute);
		Attribute__c fruitAttribute = new Attribute__c();
		fruitAttribute.Name = 'Fruit';
		attriList.add(fruitAttribute);
		insert attriList; 
		system.assertNotEquals(0,attriList.size());
		
		List<Attribute__c > childAttriList = New List<Attribute__c >();
		for (integer i = 0; i < 2 ; i++) {
				for (integer j = 0; j < 2 ; j++ ) {
					Attribute__c childAttribute = new Attribute__c();
					childAttribute.Name = 'ChildAttribute'+ i;
					childAttribute.Parent__c = attriList[i].Id;
					childAttriList.add(childAttribute);
				}				
		}
		insert childAttriList;
		system.assertNotEquals(0,childAttriList.Size());
		
		list<Content_Attribute__c> conAttList = New list<Content_Attribute__c>();
		For (integer index = 0 ; index < 2 ; index++) {
			Content_Attribute__c contentAttri = new Content_Attribute__c();			
					contentAttri.Attribute__c = childAttriList[index].id;
					contentAttri.Reference_Content__c = referObjects[index].id;
					conAttList.add(contentAttri);
		}
		insert conAttList;
		
		 //Start Test Method
		test.startTest();
			Batch_UpdateAttributeToReferenceContent batchrrf = new Batch_UpdateAttributeToReferenceContent();
			ID batchprocessid = database.executebatch(batchrrf);
			system.assertNotEquals(null,batchprocessid);
		//Stop Test method
		test.stopTest();	
		
	}

	
	 /**
     * Method to call Constructor
     */
    static testmethod void myUnitTest02() {
		
		List<Reference_Content__c> referObjects = TestDataFactory.createMultipleReferenceContent();
		insert referObjects;
		
		List<Attribute__c > attriList = New List<Attribute__c >();
		Attribute__c industAttribute = new Attribute__c();
		industAttribute.Name = 'Industry';
		attriList.add(industAttribute);
		Attribute__c fruitAttribute = new Attribute__c();
		fruitAttribute.Name = 'Fruit';
		attriList.add(fruitAttribute);
		insert attriList; 
		system.assertNotEquals(0,attriList.size());
		
		List<Attribute__c > childAttriList = New List<Attribute__c >();
		for (integer i = 0; i < 2 ; i++) {
				for (integer j = 0; j < 2 ; j++ ) {
					Attribute__c childAttribute = new Attribute__c();
					childAttribute.Name = 'ChildAttribute'+ i;
					childAttribute.Parent__c = attriList[i].Id;
					childAttriList.add(childAttribute);
				}				
		}
		insert childAttriList;
		
		list<Content_Attribute__c> conAttList = New list<Content_Attribute__c>();
		For (integer index = 0 ; index < 2 ; index++) {
			Content_Attribute__c contentAttri = new Content_Attribute__c();			
					contentAttri.Attribute__c = childAttriList[index].id;
					contentAttri.Reference_Content__c = referObjects[0].id;
					conAttList.add(contentAttri);
		}
		insert conAttList;
		system.assertNotEquals(0,conAttList.size());
		
		 //Start Test Method
		test.startTest();
			Batch_UpdateAttributeToReferenceContent batchrrf = new Batch_UpdateAttributeToReferenceContent();
			ID batchprocessid = database.executebatch(batchrrf);
			system.assertNotEquals(null,batchprocessid);
		//Stop Test method
		test.stopTest();	
		
	}	
}