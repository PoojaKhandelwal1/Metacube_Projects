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
public class TestInfl_Member {
    
    static testmethod void createNomination(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();
        system.runAs(u) {
            List<Reference_Basic_Information__c>  rbiList = new List<Reference_Basic_Information__c>();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Is_Influitive_Integration_Enabled__c = true;
            update customSetting;
            
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            
            //if contact is exist with below email id
            contacts.get(0).email = 'metacube.narendra@gmail.com';
            update contacts;
            
            rbiList.add(new Reference_Basic_Information__c(Contact__c = contacts[0].Id, Account__c = contacts[0].AccountId, Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE));
            rbiList.add(new Reference_Basic_Information__c(Contact__c = contacts[1].Id, Account__c = contacts[1].AccountId, Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE));
            insert rbiList;
            System.assert(rbiList[0].id != null);
        }
         //Stop test method
        test.stopTest();
    }
}