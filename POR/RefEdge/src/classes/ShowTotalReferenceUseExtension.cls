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
 * VF Page: ShowTotalReferenceUse 
 * Description: Controller used to show total reference request count;.
 * Last modified by: Rajesh @JUNE 13 2017
 */
public with sharing class ShowTotalReferenceUseExtension extends RefEdgeEditionFeatures {
   /**
	* Properties and variables
	*/
    public Integer mapSize { get; set; }
    public Map<String, Integer> referenceNameCount { get; set; }
    public Map<String, String> referenceIdName { get; set; }
    List<Reference_Request_Account_Contact__c> refRequestAccContact;
    List<Reference_Request_Account__c> refRequestAccount;
    
   /**
	* Constructor
	*/
    public ShowTotalReferenceUseExtension() {
        mapSize = 0;
        String rbi = ApexPages.currentPage().getParameters().get('Id');
        List<Reference_Basic_Information__c> rbis = [SELECT Account__c, Contact__c FROM Reference_Basic_Information__c WHERE Id =:rbi];        
        String objId;
        
        if (rbis.size() > 0) {
            
            if (rbis.get(0).Contact__c != null) {
                objId = rbis.get(0).Contact__c;
            } else {
                objId = rbis.get(0).Account__c;
            }
        }
        
        referenceNameCount = new Map<String, Integer>();
        referenceIdName = new Map<String, String>();
        
        for (Referenceability_Type__c refObj : [SELECT Name, Id FROM Referenceability_Type__c WHERE Sales_Reward__c = false LIMIT :limits.getLimitQueryRows()]) {
            referenceIdName.put(refObj.Id, refObj.Name);
        }
        
        if (objId.substring(0, 3) == '001') {
            
            for (Reference_Request_Account__c tempObj : [SELECT r.Reference_Type_Needed__c, r.Account__c FROM Reference_Request_Account__c r WHERE Account__c = : objId AND Account_Request_Status__c = 'Completed']) {
                
                if (!referenceNameCount.containskey(referenceIdName.get(tempObj.Reference_Type_Needed__c))) {
                    referenceNameCount.put(referenceIdName.get(tempObj.Reference_Type_Needed__c), 1);
                } else {
                    Integer countVar = referenceNameCount.get(referenceIdName.get(tempObj.Reference_Type_Needed__c));
                    referenceNameCount.put(referenceIdName.get(tempObj.Reference_Type_Needed__c), countVar + 1);
                }
            }
            mapSize = referenceNameCount.size();
        } else if (objId.substring(0, 3) == '003') {
            
            for (Reference_Request_Account_Contact__c tempObj : [SELECT r.Referenceability_Type__c, r.Contact__c FROM Reference_Request_Account_Contact__c r WHERE Contact__c = :objId AND Contact_Request_Status__c = 'Completed']) {
                
                if (!referenceNameCount.containskey(referenceIdName.get(tempObj.Referenceability_Type__c))) {
                    referenceNameCount.put(referenceIdName.get(tempObj.Referenceability_Type__c), 1);
                } else {
                    Integer countVar = referenceNameCount.get(referenceIdName.get(tempObj.Referenceability_Type__c));
                    referenceNameCount.put(referenceIdName.get(tempObj.Referenceability_Type__c), countVar + 1);
                }
            }
            mapSize = referenceNameCount.size();
        }
    }
}