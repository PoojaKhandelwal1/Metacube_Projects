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
 * Class: ProductTrigger
 * Description : This class is called from ProductTrigger to update attribute name which are associated to product and when product name is updated 
 * Created by: Rekha Jangir @Dec/9/2016
 * Created regarding Ticket #572
 */
public with sharing class ProductTriggerHandler {
    
    /**
     * Method called on after update of Account
     */
    public static void onAfterUpdate(List<Product2> newProducts, List<Product2> oldProducts, Map<Id, Product2> newProductMap, Map<Id, Product2> oldProductMap) {
        
        Set<Id> changedProducts = new Set<Id>();
        
        for (Product2 product : newProducts) {
        	
        	if (product.Name != null && (product.Name != oldProductMap.get(product.Id).Name)) {
        		changedProducts.add(product.Id);
        	}
        }
        
        List<Attribute__c> attributes = WithoutSharingHelperController.getProductAttributes(changedProducts);
        
        for (Attribute__c att : attributes) {
        	att.Name = newProductMap.get(att.Product_ID__c).Name;
        }
        
        if (attributes.size() > 0) {
        	WithoutSharingHelperController.updateAttributes(attributes);
        }
    }
}