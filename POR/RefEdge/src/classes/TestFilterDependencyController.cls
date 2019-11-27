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
 * Class: TestFilterDependencyController
 * Description: class to test AND cover FilterDependencyController
 * Created by: Dixita @April 2019
 */
@isTest
    
public with sharing class TestFilterDependencyController {
    public static User u;
    public static Profile p;
    /**
     * Method to create page load data and set properties
     * Created By: Dixita
     */
    @testSetup static void setupData() {
        List<Label__c> labels = TestDataFactory.createLabels();
        for (Label__c label : labels) {
            label.Visible__c = true;
        }
        insert labels; 
        
        List<Attribute__c> attributeList = TestDataFactory.createAttribute();
        insert attributeList;
        TestDataFactory.setUpAttributeLabels(labels, attributeList);
    }
    public static testMethod void testMethods () {
        
        p = [select id from profile where name like '%System Admin%'];
        u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
                     emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                     localesidkey = 'en_US', profileid = p.Id,
                     timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
        insert u;
        system.runAs(u) {
            test.startTest();
            System.assertNotEquals(null,FilterDependencyController.isSLDS);
            FilterDependencyController fdc = new FilterDependencyController();
            System.assertNotEquals(null,FilterDependencyController.checkPermissions(true));
            System.assertNotEquals(null,FilterDependencyController.checkPermissions(false));
            List<String> returnList = (List<String>)JSON.deserialize(FilterDependencyController.getFilterDependencyList(),List<String>.class);
            List<FilterDependencyController.FilterDependecyWrapper> filterList = (List<FilterDependencyController.FilterDependecyWrapper>)JSON.deserialize(returnList[0],List<FilterDependencyController.FilterDependecyWrapper>.class);
            Map<Id,String> filterId = (Map<Id,String>)JSON.deserialize(returnList[1],Map<Id,String>.class);
            List<Id> filterIdList = new List<Id>(filterId.keySet());
            returnList = (List<String>)JSON.deserialize(FilterDependencyController.getAttributeDependencyList(filterIdList[0] + ';' + filterIdList[1],'','true'),List<String>.class);
            //Map<Id,FilterDependencyController.DependentWrapper> dependentAttributes = (Map<Id,FilterDependencyController.DependentWrapper>)JSON.deserialize(returnList[0],Map<Id,FilterDependencyController.DependentWrapper>.class);
            List<FilterDependencyController.ControllingWrapper> controllingList = (List<FilterDependencyController.ControllingWrapper>)JSON.deserialize(returnList[1],List<FilterDependencyController.ControllingWrapper>.class);
            FilterDependencyController.FilterDependecyWrapper dmwrapper = (FilterDependencyController.FilterDependecyWrapper)JSON.deserialize(returnList[2],FilterDependencyController.FilterDependecyWrapper.class);
            String result = FilterDependencyController.saveFilterDependency(JSON.serialize(controllingList),'true',JSON.serialize(dmwrapper));
            System.assertEquals(result,'true');
            returnList = (List<String>)JSON.deserialize(FilterDependencyController.getFilterDependencyList(),List<String>.class);
            filterList = (List<FilterDependencyController.FilterDependecyWrapper>)JSON.deserialize(returnList[0],List<FilterDependencyController.FilterDependecyWrapper>.class);
            for (String attId : controllingList[0].dependentWrapperList) {
                controllingList[0].dependentWrapperList.add(attId);
            }
            result = FilterDependencyController.saveFilterDependency(JSON.serialize(controllingList),'false',JSON.serialize(dmwrapper));
            System.assertEquals(result,'true');
            result = FilterDependencyController.saveFilterDependency(JSON.serialize(controllingList),'false',JSON.serialize(dmwrapper));
            returnList = (List<String>)JSON.deserialize(FilterDependencyController.getAttributeDependencyList(JSON.serialize(dmwrapper),'','false'),List<String>.class);
            
            String dmrecordId = '';
            if (filterList.size() > 0) {
                dmrecordId = filterList[0].dmRecord;
                System.assertEquals('true',FilterDependencyController.deleteFilterDependency(dmrecordId));
            }
        }
    }
}