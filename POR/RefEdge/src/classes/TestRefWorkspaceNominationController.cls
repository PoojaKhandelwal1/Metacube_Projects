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
* Description: Test class for RefWorkspaceNominationDetailController
* Created By: Dixita(Feb, 2018)
*/
@isTest(seeAllData = false)
public with sharing class TestRefWorkspaceNominationController {
    public static Nomination__c nom;

    @testSetup static void methodName() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        
        List<Nomination__c> nominations = TestDataFactory.createNominations(accounts, contacts);
        insert nominations;
        
        List<Label__c> labels = TestDataFactory.createLabels();
        for (Label__c label : labels) {
            label.Visible__c = true;
        }
        insert labels; 
        
        List<Nomination_Label__c> nomLabel = TestDataFactory.createNominationLabel(labels, nominations);
        
        List<Attribute__c> attributeList = TestDataFactory.createAttribute();
        insert attributeList;
        List<Attribute__c> tempList = new List<Attribute__c>();
        tempList.add(attributeList.get(0));
        List<Attribute__c> attributeListChild = TestDataFactory.createChildAttributes(tempList,3,2);
        attributeList.addAll(attributeListChild);
        
        TestDataFactory.createAttributeLabels(labels, attributeList);
        List<Nomination_Label_Attribute__c> nomLabelAttrs = TestDataFactory.createNominationLabelAttributes(attributeList, nomLabel);
        List<Referenceability_Type__c> referenceability = TestDataFactory.createReferenceabilityType();
        insert referenceability;
        
        List<Nomination_Referenceability__c> nomReferenceability = TestDataFactory.createNominationReferenceability(referenceability,nominations);
        List<Data_Mapping__c> nominationMapping = TestDataFactory.createDataMappings();
        
        for (Integer index = 0 ; index < nominationMapping.size() && index < referenceability.size() ; index++) {
            nominationMapping[index].Object__c = ConstantsController.NOMINATION_REFERENCEABILITY;
            nominationMapping[index].Referenceability_Type__c = referenceability[index].Id;
            nominationMapping[index].Visible__c = true;
        }
        insert nominationMapping;
        
        system.assertEquals(true, nominationMapping.size() > 0);
    }
    //Unit Test Method
    static testMethod void nominateAccount() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            List<String> filterIds = new List<String>();
            List<Label__c> labels = [SELECT Id FROM Label__c];
            List<Nomination__c> nominationsContact = [SELECT Id FROM Nomination__c WHERE Contact__c != null ];
            List<Nomination__c> nominationsAccount = [SELECT Id FROM Nomination__c WHERE Contact__c = null ];
            ApexPages.StandardController stdcontroller = new ApexPages.StandardController(nom);
             
            //Start test method
            test.startTest();
                Id nominationId = nominationsAccount.get(0).Id;
                PageReference pageRef = new PageReference(Page.RefWorkspaceNominationDetail.getURL() + '?Id=' + nominationId);
                Test.setCurrentPage(pageRef);
                RefWorkspaceNominationDetailController controller = new RefWorkspaceNominationDetailController(stdcontroller);
                System.assertNotEquals(0, RefWorkspaceNominationDetailController.getFilters().size());
                List<RefWorkspaceNominationDetailController.RefTypeWrapper> refTypes = RefWorkspaceNominationDetailController.getRef();
                System.assertNotEquals(0, refTypes.size());
                for (Label__c filter :labels) {
                    filterIds.add(filter.Id);
                }
                Map<String, List<RefWorkspaceNominationDetailController.RefTypeWrapper>> filterAttributes = RefWorkspaceNominationDetailController.getAllFilterAttributes(JSON.serialize(filterIds));
                String defaultString = RefWorkspaceNominationDetailController.getDefaults(nominationsContact.get(0).Id);
                defaultString = RefWorkspaceNominationDetailController.getDefaults(nominationId);
                List<String> defaultsList = (List<String>)JSON.deserialize(defaultString, List<String>.class);
                String namespace = String.valueOf(defaultsList.get(1));
                Boolean isReferenceable = (Boolean)JSON.deserialize(defaultsList.get(3),Boolean.class);
                System.assertEquals(false, isReferenceable);
                
                Map<String,String> nominationMap = (Map<String,String>) JSON.deserialize(defaultsList.get(4),Map<String,String>.class); 
                nominationMap.put(namespace + 'Note__c','Test Note');
                RefWorkspaceNominationDetailController.updateNomination('InvalidData');
                String nominationIdNew = RefWorkspaceNominationDetailController.updateNomination(JSON.serialize(nominationMap));
                
                system.assertEquals(nominationId + '', nominationIdNew);
                List<Nomination_Label__c> filterString = (List<Nomination_Label__c>) JSON.deserialize(defaultsList.get(5),List<Nomination_Label__c>.class);
                Map<Id, List<RefWorkspaceNominationDetailController.NominationFilterAttributeWrapper>> attributestoLabel = (Map<Id, List<RefWorkspaceNominationDetailController.NominationFilterAttributeWrapper>>) JSON.deserialize(defaultsList.get(6),Map<Id, List<RefWorkspaceNominationDetailController.NominationFilterAttributeWrapper>>.class);
                nominationIdNew = RefWorkspaceNominationDetailController.saveAttributes(String.valueOf(nominationId),'','true',JSON.serialize(filterAttributes),JSON.serialize(filterString),JSON.serialize(attributestoLabel));
                system.assertEquals(nominationId + '', nominationIdNew);   
                
                for (String key : filterAttributes.keySet()) {
                    filterAttributes.get(key).get(0).isSelected = true;
                }
                attributestoLabel = new Map<Id, List<RefWorkspaceNominationDetailController.NominationFilterAttributeWrapper>>();
                nominationIdNew = RefWorkspaceNominationDetailController.saveAttributes(String.valueOf(nominationId),'','true',JSON.serialize(filterAttributes),JSON.serialize(filterString),JSON.serialize(attributestoLabel));
                system.assertEquals(nominationId + '', nominationIdNew); 
                //Exception Condition
                //RefWorkspaceNominationDetailController.saveAttributes(String.valueOf(nominationId),'Invalid data',JSON.serialize(filterString),JSON.serialize(attributestoLabel));
                
                List<Nomination_Referenceability__c> refString = (List<Nomination_Referenceability__c>) JSON.deserialize(defaultsList.get(7),List<Nomination_Referenceability__c>.class);
                for (RefWorkspaceNominationDetailController.RefTypeWrapper refType : refTypes) { 
                    refType.isSelected = true;
                    break;
                }
                nominationIdNew = RefWorkspaceNominationDetailController.saveRef(String.valueOf(nominationId),'','true',JSON.serialize(refTypes),JSON.serialize(refString));
                system.assertEquals(nominationId + '', nominationIdNew);
                refString = new List<Nomination_Referenceability__c>();
                nominationIdNew = RefWorkspaceNominationDetailController.saveRef(String.valueOf(nominationId),'','true',JSON.serialize(refTypes),JSON.serialize(refString));
                system.assertEquals(nominationId + '', nominationIdNew);
                system.assertEquals(null,RefWorkspaceNominationDetailController.saveRef(String.valueOf(nominationId),'','false','Invalid Data',JSON.serialize(refString)));
                
                system.assertNotEquals(null, RefWorkspaceNominationDetailController.redirectToDetail(String.valueOf(nominationId)));
                system.assertEquals(null,RefWorkspaceNominationDetailController.deleteNominationRecord('InvalidData'));
                system.assertNotEquals(null,RefWorkspaceNominationDetailController.deleteNominationRecord(nominationId));
            //Stop test method
            test.stopTest();
        }catch(Exception ex){
            System.debug(ex.getLineNumber() + ex.getMessage() + '::' + ex.getStackTraceString());
        }
    }
}