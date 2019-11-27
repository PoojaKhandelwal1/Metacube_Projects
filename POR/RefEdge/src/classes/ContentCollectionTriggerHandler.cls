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
 * Handler: Content Collection Trigger
 * Description: Before insert and update trigger used to apply validation on Content Collection. 	
 * Created By: Rajesh (7 Nov, 2016)
 * Last Modified By: Rajesh (7 Nov, 2016) 
 */
public with sharing class ContentCollectionTriggerHandler {
	/**
    * description: Method called before record inserted.
    * Created By: Rajesh (7 Nov, 2016)
	* Last Modified By: Rajesh (7 Nov, 2016)
   */ 
	 public static void onBeforeInsert(list < Content_Collection__c > collection) {
	 	// Object/Variable declaration 
  		Set< String > collectionSet = new Set< String >(); // Set of collection name.  
  		Map< String, Id > duplicateCollectionMap = new Map< String, Id >(); //Map used to collect duplicate collection.
  		
  		//Get collection
	  	for(Content_Collection__c col : collection ){ 
	  		collectionSet.add(col.Collection__c);
	  	}  
	
	  	for( Content_Collection__c c : [select Id, Collection__c from Content_Collection__c where Collection__c = :collectionSet] ){
	    	duplicateCollectionMap.put(c.Collection__c, c.Id);
	    	
	    	//If collection already exist
	    	if(duplicateCollectionMap.size()>0){
				collection[0].addError(System.Label.Collection_Already_Exist); 
			} 
		} 
		  
	 }
	 
	 /**
    * description: Method called after record inserted.
    * Created By: Rajesh (7 Nov, 2016)
	* Last Modified By: Rajesh (7 Nov, 2016)
   */ 
     public static void onBeforeUpdate(List < Content_Collection__c > collection,Map<Id, Content_Collection__c> newMap) {
	 	// Object/Variable declaration 
	 	Set< String > collectionSet = new Set< String >();// Set of collection name.  
	 	Map< String, Id > duplicateCollectionMap = new Map< String, Id >(); //Map used to collect duplicate collection.
	 	
	 	//Get collection
	  	for(Content_Collection__c col : collection){ 
	  		collectionSet.add(col.Collection__c); 
	  	}  
	  	
	  	for(Content_Collection__c c : [select Id, Collection__c from Content_Collection__c where Id NOT IN :newMap.keySet() and Collection__c = :collectionSet]){
	    	duplicateCollectionMap.put(c.Collection__c, c.Id); 
	    	
	    	//If collection already exist
	    	if(duplicateCollectionMap.size()>0){
				collection[0].addError(System.Label.Collection_Already_Exist); 
			}   
		}
	 }
}