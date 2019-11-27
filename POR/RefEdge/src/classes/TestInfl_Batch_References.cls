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
public class TestInfl_Batch_References {

    private static final String API_URL = 'https://pointofreference.influitive.com:443';
    private static final String API_AUTH_TOKEN = 'b3431ebb96d5248c8f78dad57a9c41e1ffe1b38b';
    
    //Getting reference from influitive  and create reference use and respective reward.
    static testmethod void getInflReferences(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();
        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Is_Influitive_Integration_Enabled__c = true;
            customSetting.Influitive_API_URL__c = API_URL;
            customSetting.Influitive_Auth_Token__c = API_AUTH_TOKEN;
            customSetting.Infl_Reference_Cursor__c = '2015-12-22T10:56:49Z';
            update customSetting;
            Database.executeBatch(new INfl_Batch_References());
            System.assertEquals(customSetting.Is_Influitive_Integration_Enabled__c, true);
        }
         //Stop test method
        test.stopTest();
    }
}