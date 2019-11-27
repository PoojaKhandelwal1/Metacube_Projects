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
public class TestPostInstallController {
    
    //Unit Test Method 
    static testMethod void testInstallScript01() {
        Test.startTest();
            PostInstallController postinstall = new PostInstallController();
            Test.testInstall(postinstall, null);
        Test.stopTest();
        List < Custom_Settings__c > cs = [SELECT Id, Name FROM Custom_Settings__c];
        system.assertEquals(cs.size(), 1);
    }

    //Unit Test Method 
    static testMethod void testInstallScript02() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Test.startTest();
            PostInstallController postinstall = new PostInstallController();
            Test.testInstall(postinstall, new Version(1, 0), true);
        Test.stopTest();
        List < Custom_Settings__c > cs = [SELECT Id, Name FROM Custom_Settings__c];
        system.assertEquals(cs.size(), 1);
    }
    /*
    //Unit Test Method 
    static testMethod void testInstallScript03() {
        Test.startTest();
            PostInstallController postinstall = new PostInstallController();
            Test.testInstall(postinstall, new Version(1, 0), true);
        Test.stopTest();
        List < Custom_Settings__c > cs = [SELECT Id, Name FROM Custom_Settings__c];
        system.assertEquals(cs.size(), 1);
    }*/
}