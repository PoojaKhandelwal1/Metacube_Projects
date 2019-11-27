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
public with sharing class TestSelectReferenceUseAttribute {
    public static List < Referenceability_Type__c > rfTypes;
    public static list < Reference_Type_Mapping__c > rtmapping;
    public static list < Label__c > labels;
    public static list < Attribute__c > attributes;
    public static SelectReferenceUseAttribute controllerObj;

    //Deprecated REF-2366
    static testMethod void testSelectReferenceUseAttribute() {}
    static testMethod void testSelectReferenceUseAttributeSF1() {}
    static testMethod void testBackToRequestMethods() {}
	
	//Data Setup
    static void setUpData() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        labels = TestDataFactory.createLabels();
        insert labels;
        attributes = TestDataFactory.createAttribute();
        insert attributes;
        TestDataFactory.createAttributeLabels(labels,attributes);
        rtmapping = createReferenceTypeMapping();
        insert rtmapping;
    }
    
    //Reference_Type_Mapping Setup
    static list < Reference_Type_Mapping__c > createReferenceTypeMapping() {
        list < Reference_Type_Mapping__c > tempRefMapping = new list < Reference_Type_Mapping__c > ();
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Name = 'OwnerId'));
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = true, Referenceability_Type__c = rfTypes.get(0).Id, Label__c = labels.get(0).Id));
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Label__c = labels.get(1).Id));
        return tempRefMapping;
    }
    
    @isTest static void testCreateMapAllAttributesLabel() {
        setUpData();
        
        test.startTest();
        controllerObj = new SelectReferenceUseAttribute();
        controllerObj.refTypeIdsSet = new Set<Id> {rfTypes[0].Id};
        List<Label__c> resultLabels = controllerObj.getAttributeLabels();
        controllerObj.mapRequiredLabel.put(labels[0].Id, true);
        controllerObj.getMapAllAttrributesLabel();
        controllerObj.getMapAttributeSize();
        controllerObj.selectedLabelId = labels[0].Id;
        controllerObj.selectedAttributeId = attributes[0].Id;
        controllerObj.setAttributes();
        controllerObj.getMapAttrributesLabels();
        Pagereference resultPR = controllerObj.backToRequest();
        Pagereference resultPRCancel = controllerObj.backToRequestOnCancel();
        Pagereference resultPRSF1 = controllerObj.backToSF1ReferenceUseRequestOnDone();
        controllerObj.isAdvRouting = true;
        controllerObj.isP2PRequest = true;
        controllerObj.setLabelAtrr();
        controllerObj.groupsIds = new List<String> {labels[0].Id};
        controllerObj.setLabelAtrr();
        controllerObj.labelAttributesToBeSelected = '{"' + labels[0].Id + '":["' + attributes[0].Id + '"]}';
        controllerObj.labelAttributesToBeSelectedFromAttributeResults ='{"' + labels[0].Id + '":["' + attributes[1].Id + '"]}';
        List<Attributes_Labels__c> listAttributeLabels = [SELECT Id, Label__c FROM Attributes_Labels__c WHERE Label__c =: labels[0].Id];
        controllerObj.selectedAttributeLabelsIdsFromAttributeResults = '{"' + labels[0].Id + '":["' + listAttributeLabels[0].Id + '"]}';
        controllerObj.setSelectedAttributes();
        //REF-2653
        controllerObj.setPreviouslySelectedAttributes();
        System.assertEquals(true, resultLabels != null);
        test.stopTest();
    }
}