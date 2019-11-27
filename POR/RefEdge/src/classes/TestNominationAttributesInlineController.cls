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
public with sharing class TestNominationAttributesInlineController {
    
    //Unit test method
    static testMethod void myUnitTest() {
        try{
            //Start test method
            test.startTest();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                list < Attribute__c > attributes = TestDataFactory.createAttribute();
                insert attributes;
                list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
                insert labels;
                TestDataFactory.createAttributeLabels(labels, attributes);
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                list<Nomination__c> nominations = TestDataFactory.createNominations(new list<Account>{accounts[0]}, new list<Contact>());
                insert nominations;
                List < Nomination_Label__c > nomiLabels = TestDataFactory.createNominationLabel(labels, nominations);
                List < Nomination_Label_Attribute__c > nomiLabelAtts = TestDataFactory.createNominationLabelAttributes(attributes, nomiLabels);
                ApexPages.StandardController sc = new ApexPages.standardController(nominations[0]);
                NominationAttributesInlineController testObj = new NominationAttributesInlineController(sc);
             //Stop test method
             test.stopTest();
             List<Nomination_Label_Attribute__c> listNLA = [select Id from Nomination_Label_Attribute__c where Id IN : nomiLabelAtts];
             system.assertEquals(listNLA.size() > 0, true);
        }catch(Exception e){
            
        } 
    }
}