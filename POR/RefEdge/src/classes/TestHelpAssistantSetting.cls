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
 * Class: TestHelpAssistantSetting
 * Description: class to test AND cover HelpAssistantSetting
 * Created by: Dixita @Sept 2018
 */
@isTest
    /**
     * Method to create page load data and set properties
     * Created By: Dixita
     */
public with sharing class TestHelpAssistantSetting {
    public static User u;
    public static Profile p;
    private static void Createdm() {
        List<String> pageName = new List<String>();
        pageName.add(UtilityController.appNamespace() + 'RfSearchPage');
        pageName.add(UtilityController.appNamespace() + 'RfSearchLightning');
        pageName.add(UtilityController.appNamespace() + 'Invitation_New');
        pageName.add(UtilityController.appNamespace() + 'Invitation_NewSLDS');
        pageName.add(UtilityController.appNamespace() + 'ReferenceUseRequest');
        pageName.add(UtilityController.appNamespace() + 'ReferenceUseRequestSLDS');
        UtilityController.helpAssistant(pageName);
    }
    private static void CreateUser() {
        p = [select id from profile where name like '%System Admin%'];
        u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
                     emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                     localesidkey = 'en_US', profileid = p.Id,
                     timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
        insert u;
    }
    public static testMethod void testMethods () {
        CreateUser();
        Createdm();
        test.startTest();
        
        system.runAs(u) {
            System.assertNotEquals(null, HelpAssistantSetting.isSLDS);
            List<String> dataList = (List<String>)JSON.deserialize(HelpAssistantSetting.getData(), List<String>.class);
            List<HelpAssistantSetting.PageWrapper> PageWrapperList = (List<HelpAssistantSetting.PageWrapper>)JSON.deserialize(dataList[0], List<HelpAssistantSetting.PageWrapper>.class);
        	System.assertNotEquals(null, PageWrapperList);
            Map<String,List<Data_Mapping__c>> helpListClassic = (Map<String,List<Data_Mapping__c>>)JSON.deserialize(dataList[1], Map<String,List<Data_Mapping__c>>.class);
            Map<String,List<Data_Mapping__c>> helpListLightning = (Map<String,List<Data_Mapping__c>>)JSON.deserialize(dataList[2], Map<String,List<Data_Mapping__c>>.class);
            System.assertNotEquals(0, helpListClassic.keySet().size());
            Set<String> classicKeys = helpListClassic.keySet();
            Data_Mapping__c dm = helpListClassic.get(new List<String>(classicKeys)[0])[0];
            dm.Label__c = 'Test';
            HelpAssistantSetting has = new HelpAssistantSetting();
            System.assertEquals(UtilityController.appNamespace(), has.namespace);
            HelpAssistantSetting.saveEdit(JSON.serialize(dm));
            System.assertEquals('Test', dm.Label__c);
        }
    }
}