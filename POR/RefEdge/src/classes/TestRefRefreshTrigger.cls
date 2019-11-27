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
public with sharing class TestRefRefreshTrigger {
    
    public static Custom_Settings__c customSetting;
    static testMethod void testBatchMethod(){
        customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name = 'testacc');
        insert acc;
        Reference_Basic_Information__c rbi = new Reference_Basic_Information__c(Last_Refresh_Sent__c = date.today().addDays(-3),Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = acc.Id);
        insert rbi;
        Reference_Refresh__c refr =  new Reference_Refresh__c(Reference_Account__c = acc.Id,Reference_Profile__c = rbi.Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId());
        insert refr;
        test.startTest();
            Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
            temp.Reference_Refresh__c = refr.Id;
                temp.Account__c = acc.Id;
            insert temp;
        //Stop test method
        test.stopTest();
        list<Reference_Basic_Information__c> rbiList = [select Id from Reference_Basic_Information__c];
        system.assertEquals(rbiList.size(),1);
         
    }
}