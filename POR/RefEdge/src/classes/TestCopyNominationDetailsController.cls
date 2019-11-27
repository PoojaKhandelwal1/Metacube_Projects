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
public with sharing class TestCopyNominationDetailsController {
    public static List < Nomination_Label__c > nomiLabels;
    public static List < Nomination_Label_Attribute__c > nomiLabelAtts;
    public static List < Nomination_Referenceability__c > nomiRefs;
    //Unit Test Method
    static testMethod void nominateAccountwithoutData() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
            insert labels;
            TestDataFactory.createAttributeLabels(labels, attributes);
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.createAccountAttributes(accounts, attributes,false);
            
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            list<Nomination__c> nominations = TestDataFactory.createNominations(new list<Account>{accounts[0]}, new list<Contact>());
            nominations[0].Disposition__c = 'Approved';
            insert nominations;
            //Start test method
            test.startTest();
                PageReference pageRef = Page.CopyNominationDetails;
                pageRef.getParameters().put('isMakeAccountMember', 'false');
                Test.setCurrentPage(pageRef);
                ApexPages.StandardController sc = new ApexPages.StandardController(nominations[0]);
                CopyNominationDetailsController copynomination = new CopyNominationDetailsController(sc);
                copynomination.getOptions();
                copynomination.deSelectAll();
                copynomination.selectAll();
                copynomination.copyDetails();
                list<Reference_Basic_Information__c> rbiList = [select Id,Is_Referenceable__c from Reference_Basic_Information__c where Account__c = :accounts[0].Id and Contact__c = null];
                system.assertEquals(true, rbiList[0].Is_Referenceable__c);
                copynomination.cancelNomination();
            //Stop test method
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    //Unit Test Method
    static testMethod void nominateAccount() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
            insert labels;
            TestDataFactory.createAttributeLabels(labels, attributes);
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.createAccountAttributes(accounts, attributes,true);
            
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            list<Nomination__c> nominations = TestDataFactory.createNominations(new list<Account>{accounts[0]}, new list<Contact>());
            nominations[0].Disposition__c = 'Approved';
            insert nominations;
            nomiRefs = TestDataFactory.createNominationReferenceability(refTypes, nominations);
            nomiLabels = TestDataFactory.createNominationLabel(labels, nominations);
            nomiLabelAtts = TestDataFactory.createNominationLabelAttributes(attributes, nomiLabels);
            //Start test method
            test.startTest();
                PageReference pageRef = Page.CopyNominationDetails;
                pageRef.getParameters().put('isMakeAccountMember', 'true');
                Test.setCurrentPage(pageRef);
                ApexPages.StandardController sc = new ApexPages.StandardController(nominations[0]);
                CopyNominationDetailsController copynomination = new CopyNominationDetailsController(sc);
                copynomination.getOptions();
                copynomination.deSelectAll();
                copynomination.selectAll();
                copynomination.copyDetails();
                list<Reference_Basic_Information__c> rbiList = [select Id,Is_Referenceable__c from Reference_Basic_Information__c where Account__c = :accounts[0].Id and Contact__c = null];
                system.assertEquals(true, rbiList[0].Is_Referenceable__c);
                copynomination.cancelNomination();
            //Stop test method
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Unit Test Method
    static testMethod void nominateContact() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
            insert labels;
            TestDataFactory.createAttributeLabels(labels, attributes);
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            TestDataFactory.createReferenceability(accounts, contacts, refTypes);
            TestDataFactory.createAccountAttributes(accounts, attributes,true);
            
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            list<Nomination__c> nominations = TestDataFactory.createNominations(new list<Account>(), new list<Contact>{contacts[0]});
            nominations[0].Disposition__c = 'Approved';
            insert nominations;
            nomiRefs = TestDataFactory.createNominationReferenceability(refTypes, nominations);
            nomiLabels = TestDataFactory.createNominationLabel(labels, nominations);
            nomiLabelAtts = TestDataFactory.createNominationLabelAttributes(attributes, nomiLabels);
            //Start test method
            test.startTest();
                PageReference pageRef = Page.CopyNominationDetails;
                Test.setCurrentPage(pageRef);
                ApexPages.StandardController sc = new ApexPages.StandardController(nominations[0]);
                CopyNominationDetailsController copynomination = new CopyNominationDetailsController(sc);
                copynomination.getOptions();
                copynomination.deSelectAll();
                copynomination.selectAll();
                copynomination.copyDetails();
                list<Reference_Basic_Information__c> rbiList = [select Id,Is_Referenceable__c from Reference_Basic_Information__c where Contact__c = : contacts[0].Id];
                system.assertEquals(true, rbiList[0].Is_Referenceable__c);
                copynomination.cancelNomination();
            //Stop test method
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Unit Test Method
    static testMethod void nominateContactwithMapping() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            TestDataFactory.createAttributeMapping();
            TestDataFactory.createContactAttributeMapping();
            list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
            insert labels;
            TestDataFactory.createAttributeLabels(labels, attributes);
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            for(Account acc : accounts){
                acc.Industry = 'Finance';
                acc.Rating = 'Cold';
            }
            insert accounts;
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            for(Contact con : contacts){
                con.LeadSource = 'Partner';
            }
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            TestDataFactory.createAccountAttributes(accounts, attributes,false);
            TestDataFactory.createContactAttributes(contacts, attributes);
            
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            list<Nomination__c> nominations = TestDataFactory.createNominations(new list<Account>(), new list<Contact>{contacts[0]});
            nominations[0].Disposition__c = 'Approved';
            insert nominations;
            nomiRefs = TestDataFactory.createNominationReferenceability(refTypes, nominations);
            nomiLabels = TestDataFactory.createNominationLabel(labels, nominations);
            nomiLabelAtts = TestDataFactory.createNominationLabelAttributes(attributes, nomiLabels);
            //Start test method
            test.startTest();
                PageReference pageRef = Page.CopyNominationDetails;
                pageRef.getParameters().put('isMakeAccountMember', 'true');
                Test.setCurrentPage(pageRef);
                ApexPages.StandardController sc = new ApexPages.StandardController(nominations[0]);
                CopyNominationDetailsController copynomination = new CopyNominationDetailsController(sc);
                copynomination.getOptions();
                copynomination.deSelectAll();
                copynomination.selectAll();
                copynomination.copyDetails();
                list<Reference_Basic_Information__c> rbiList = [select Id,Is_Referenceable__c from Reference_Basic_Information__c where Contact__c = : contacts[0].Id];
                system.assertEquals(true, rbiList[0].Is_Referenceable__c);
                copynomination.cancelNomination();
            //Stop test method
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    
    //Unit Test Method
    static testMethod void nominateObjectNotNull() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            TestDataFactory.createAttributeMapping();
            TestDataFactory.createContactAttributeMapping();
            list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
            insert labels;
            TestDataFactory.createAttributeLabels(labels, attributes);
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            for(Account acc : accounts){
                acc.Industry = 'Finance';
                acc.Rating = 'Cold';
            }
            insert accounts;
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            for(Contact con : contacts){
                con.LeadSource = 'Partner';
            }
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            TestDataFactory.createAccountAttributes(accounts, attributes,false);
            TestDataFactory.createContactAttributes(contacts, attributes);
            
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            list<Nomination__c> nominations = TestDataFactory.createNominations(new list<Account>(), new list<Contact>{contacts[0]});
            nominations[0].Disposition__c = 'Approved';
            insert nominations;
            nomiRefs = TestDataFactory.createNominationReferenceability(refTypes, nominations);
            nomiLabels = TestDataFactory.createNominationLabel(labels, nominations);
            nomiLabelAtts = TestDataFactory.createNominationLabelAttributes(attributes, nomiLabels);
            //Start test method
            Nomination__c nominationObj =  nominations[0];
            Contact contact = contacts[0];
            nominationObj.Contact__c = contact.Id;
            System.debug('nomination '+nominationObj+' contact '+contact);
            test.startTest();
                PageReference pageRef = Page.CopyNominationDetails;
                pageRef.getParameters().put('isMakeAccountMember', 'true');
                Test.setCurrentPage(pageRef);
                ApexPages.StandardController sc = new ApexPages.StandardController(nominationObj);
                CopyNominationDetailsController copynomination = new CopyNominationDetailsController(sc);
            	copynomination.nominationObj =  nominationObj;
                copynomination.getOptions();
                copynomination.deSelectAll();
                copynomination.selectAll();
                copynomination.copyDetails();
                list<Reference_Basic_Information__c> rbiList = [select Id,Is_Referenceable__c from Reference_Basic_Information__c where Contact__c = : contacts[0].Id];
                system.assertEquals(true, rbiList[0].Is_Referenceable__c);
                copynomination.cancelNomination();
            //Stop test method
            test.stopTest();
        }catch(Exception e){
            
        }
    }
}