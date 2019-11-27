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
 * Test for class: Content Collection Trigger Handler
 * Description: Test class cover all negtive and positive cases. 	
 * Created By: Rajesh (11 Nov, 2016)
 * Last Modified By: Rajesh (11 Nov, 2016) 
 * Last Code Coverage: 100% 
 */
 
@isTest(seeAllData = false)
public with sharing class TestContentCollectionTriggerHandler {
 
	/**
    * description: Test method check validation for duplicate record for befor insert.
    * Created By: Rajesh (7 Nov, 2016)
	* Last Modified By: Rajesh (7 Nov, 2016)
   */ 
    static testMethod void testForBeforeInsertDuplicateRecords() { 
     	Content_Collection__c contColl; 
     	//Start test method
        test.startTest();  
        
        //record insertion 
        contColl = new Content_Collection__c(Description__c = 'Collection 001', Collection__c = 'Collection 001', Active__c = true);
        insert contColl; 
        
        try{
        	//record insertion again with same value for Collection__c
        	contColl = new Content_Collection__c(Description__c = 'Collection 001', Collection__c = 'Collection 001', Active__c = true);
        	insert contColl;
        }
        catch(Exception e){ 
			Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Collection_Already_Exist) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		} 
		
    	//Stop test method
    	test.stopTest();
     }
  
    /**
    * description: Test method check validation for duplicate record for befor update.
    * Created By: Rajesh (7 Nov, 2016)
	* Last Modified By: Rajesh (7 Nov, 2016)
   */
    static testMethod void testForBeforeUpdateDuplicateRecords() { 
     	Content_Collection__c contColl; 
     	//Start test method
        test.startTest();  
        
         //record insertion 
        Content_Collection__c collectionRecordOne = new Content_Collection__c(Description__c='Collection 001', Collection__c='Collection 001', Active__c=true);
        Content_Collection__c collectionRecordTwo = new Content_Collection__c(Description__c='Collection 002', Collection__c='Collection 002', Active__c=true);
        Content_Collection__c collectionRecordThree = new Content_Collection__c(Description__c='Collection 003', Collection__c='Collection 003', Active__c=true);
        //insert contColl; 
        Content_Collection__c[] coll = new Content_Collection__c[] {collectionRecordOne, collectionRecordTwo, collectionRecordThree};
        insert coll;
        // Now make sure that some of these Collection can be changed and 
      	// then bulk updated successfully. Note that collectionRecordOne is not 
      	// being changed, but is still being passed to the update 
      	// call. This should be OK.
        collectionRecordTwo.Collection__c = 'New Collection 002';
        collectionRecordThree.Collection__c = 'New Collection 003';
        
        update coll;
        
        //record update with same value for Collection__c with is already exist will thow an error.
        try{
        	contColl = new Content_Collection__c(Id = collectionRecordOne.Id,Description__c = 'Collection 001', Collection__c = 'New Collection 002', Active__c = true);
        	update contColl;
        }
        catch(Exception e){ 
			Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Collection_Already_Exist) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		}
		 
    	//Stop test method
    	test.stopTest();
     }
     
      /**
    * description: Test method check validation for unique record for befor insert.
    * Created By: Rajesh (7 Nov, 2016)
	* Last Modified By: Rajesh (7 Nov, 2016)
   */
     static testMethod void testForBeforeInsertUniqueRecords() { 
     	Content_Collection__c contColl; 
     	//Start test method
        test.startTest();  
        
        //record insertion
        contColl = new Content_Collection__c(Description__c = 'Collection 001', Collection__c = 'Collection 001', Active__c = true);
        insert contColl; 
    	list<Content_Collection__c> lstCollection=[SELECT Id, Description__c, Collection__c, Active__c FROM Content_Collection__c];
    	System.AssertEquals(1, lstCollection.size());
    	
    	//Stop test method
    	test.stopTest();
     }
     
      /**
    * description: Test method check validation for null records for befor insert.
    * Created By: Rajesh (7 Nov, 2016)
	* Last Modified By: Rajesh (7 Nov, 2016)
   */
     static testMethod void testForBeforeInsertNullRecords() { 
     	Content_Collection__c contColl; 
     	//Start test method
        test.startTest();  
        
        //record insertion with null value
        contColl = new Content_Collection__c(Description__c = null, Collection__c = null, Active__c = true);
        insert contColl; 
    	list<Content_Collection__c> lstCollection=[SELECT Id, Description__c, Collection__c, Active__c FROM Content_Collection__c];
    	System.AssertEquals(1, lstCollection.size());
    	
    	//Stop test method
    	test.stopTest();
     }
     
     /**
    * description: Test method check validation for duplicate record with null values for befor insert.
    * Created By: Rajesh (7 Nov, 2016)
	* Last Modified By: Rajesh (7 Nov, 2016)
   */ 
    static testMethod void testForBeforeInsertDuplicateNullRecords() { 
     	Content_Collection__c contColl; 
     	//Start test method
        test.startTest();  
        
        //record insertion 
        contColl = new Content_Collection__c(Description__c = null, Collection__c = null, Active__c = true);
        insert contColl; 
        
        try{
        	//record insertion again with same value for Collection__c
        	contColl = new Content_Collection__c(Description__c = null, Collection__c = null, Active__c = true);
        	insert contColl;
        }
        catch(Exception e){ 
			Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Collection_Already_Exist) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		} 
		
    	//Stop test method
    	test.stopTest();
     }
}