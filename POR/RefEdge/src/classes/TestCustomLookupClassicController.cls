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
 * test class for custom lookup field in classic
 * author: Gaurav Saini (22 Jan, 2018) for REF-1238
 */
@isTest(seeAllData = false)
public with sharing class TestCustomLookupClassicController {

    /**
     * method to test constructor
     * author: Gaurav Saini (22 Jan, 2018) for REF-1238
     */
    public static testmethod void testConstructor() {
        Apexpages.currentPage().getParameters().put('searchText', 'test');
        CustomLookupClassicController testObj = new CustomLookupClassicController();
        system.assertEquals(testObj.searchText, 'test');
    }

    /**
     * method to test getItemWrapperList method
     * author: Gaurav Saini (22 Jan, 2018) for REF-1238
     */
    public static testmethod void testGetItemWrapperList() {
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Admin%'];
        User u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
                            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                            localesidkey = 'en_US', profileid = p.Id,
                            timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
        
        System.runAs(u) {
            String itemWrapperListJson = CustomLookupClassicController.getItemWrapperList('');
            List<CustomLookupClassicController.ItemWrapper> itemWrapperList
                    = (List<CustomLookupClassicController.ItemWrapper>)JSON.deserialize(itemWrapperListJson, List<CustomLookupClassicController.ItemWrapper>.class);
            system.assert(itemWrapperList.size() > 0);
            String itemWrapperListJson1 = CustomLookupClassicController.getItemWrapperList('test');
            List<CustomLookupClassicController.ItemWrapper> itemWrapperList1
                    = (List<CustomLookupClassicController.ItemWrapper>)JSON.deserialize(itemWrapperListJson1, List<CustomLookupClassicController.ItemWrapper>.class);
            system.assert(itemWrapperList1.size() > 0);
        }
    }

    /**
     * method to test getMoreItems method
     * author: Gaurav Saini (22 Jan, 2018) for REF-1238
     */
    public static testmethod void testGetMoreItems() {
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%System Admin%'];
        User u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
                            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                            localesidkey = 'en_US', profileid = p.Id,
                            timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
        
        System.runAs(u) {
            String itemWrapperListJson = CustomLookupClassicController.getMoreItems('', JSON.serialize(new List<String>()));
            List<CustomLookupClassicController.ItemWrapper> itemWrapperList
                    = (List<CustomLookupClassicController.ItemWrapper>)JSON.deserialize(itemWrapperListJson, List<CustomLookupClassicController.ItemWrapper>.class);
            system.assert(itemWrapperList.size() > 0);
            String itemWrapperListJson1 = CustomLookupClassicController.getMoreItems('test', JSON.serialize(new List<String>()));
            List<CustomLookupClassicController.ItemWrapper> itemWrapperList1
                    = (List<CustomLookupClassicController.ItemWrapper>)JSON.deserialize(itemWrapperListJson1, List<CustomLookupClassicController.ItemWrapper>.class);
            system.assert(itemWrapperList1.size() > 0);
        }
    }
}