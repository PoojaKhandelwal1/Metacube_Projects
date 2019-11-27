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
public with sharing class TestRequestSettingMatrixController {
    public static Custom_Settings__c customSetting;
    public static list < Reference_Type_Mapping__c > rtmapping;
    public static list < Label__c > labels;
    public static list < Attribute__c > attributes;
    public static list < Attributes_Labels__c > attLabels;
    public static List < Referenceability_Type__c > rfTypes;
    public static List < Reference_Content_Type__c > rfContentTypes;
    public static list < Reference_Request_Field__c > refFields;
    public static RequestSettingMatrixController controllerObj;
    
    //Unit Test Method
    static testMethod void testRefTypesPicklistAndSelectedRefTypesList () {
        setUpData();
    	test.startTest();
        Pagereference pgref = Page.RequestSettingMatrix;
        Apexpages.currentPage().getParameters().put('customSettingId', customSetting.Id);
        Apexpages.currentPage().getParameters().put('isContentSetting', 'false');
        controllerObj = new RequestSettingMatrixController();
        controllerObj.passSelectedReferenceTypeToController();
        system.assertEquals(true, controllerObj.ReferenceTypesPicklist.size() > 0);
        system.assertEquals(true, controllerObj.SelectedReferenceTypesList.size() > 0);
    	test.stopTest();
    }
    
    //Unit Test Method
    static testMethod void testConTypesPicklistAndSelectedConTypesList () {
        setUpData();
    	test.startTest();
        Pagereference pgref = Page.ReferenceContentTypeSettingMatrix;
        Apexpages.currentPage().getParameters().put('customSettingId', customSetting.Id);
        Apexpages.currentPage().getParameters().put('isContentSetting', 'true');
        controllerObj = new RequestSettingMatrixController();
        controllerObj.passSelectedReferenceContentTypeToController();
        system.assertEquals(true, controllerObj.ReferenceContentTypesPicklist.size() > 0);
        system.assertEquals(true, controllerObj.SelectedReferenceContentTypesList.size() > 0);
    	test.stopTest();
    }
    
    //Unit Test Method
    static testMethod void testRequestSettingMatrixController() {
        setUpData();
        test.startTest();
            Pagereference pgref = Page.RequestSettingMatrix;
            Apexpages.currentPage().getParameters().put('customSettingId', customSetting.Id);
            Apexpages.currentPage().getParameters().put('isContentSetting', 'false');
            controllerObj = new RequestSettingMatrixController();
            controllerObj.saveMatrix();
            controllerObj.backToCustomSetting();
            controllerObj.cancelMatrix();
            controllerObj.redirectFieldPage();
            controllerObj.deleteMappings();
            system.assertEquals(false, controllerObj.isEdit);
            controllerObj.editMatrix();
            system.assertEquals(true, controllerObj.isEdit);
            delete labels;
        test.stopTest();
    }
    //Unit Test Method
    static testMethod void testRequestSettingMatrixController2() {
        setUpData();
        Reference_Content_Type__c rct = new Reference_Content_Type__c(name__c = 'test',active__c=true);
        insert rct;
        test.startTest();
            Pagereference pgref = Page.ReferenceContentTypeSettingMatrix;
            Apexpages.currentPage().getParameters().put('customSettingId', customSetting.Id);
            Apexpages.currentPage().getParameters().put('isContentSetting', 'true');
            controllerObj = new RequestSettingMatrixController();
            for (String key: controllerObj.matrixMap.keySet()) {
                controllerObj.matrixMap.get(key).Visible__c = true;
            }
            controllerObj.saveMatrix();
            controllerObj = new RequestSettingMatrixController();
            controllerObj.backToCustomSetting();
            controllerObj.cancelMatrix();
            controllerObj.redirectFieldPage();
            controllerObj.deleteMappings();
            system.assertEquals(false, controllerObj.isEdit);
            controllerObj.editMatrix();
            system.assertEquals(true, controllerObj.isEdit);
            delete labels;
        test.stopTest();
    }
    //Data Setup
    static void setUpData() {
        customSetting = TestDataFactory.createCustomSetting();
        rfTypes = setUpRFTypes();
        insert rfTypes;
        rfContentTypes = setUpRFContentTypes();
        insert rfContentTypes;
        labels = createLabels();
        insert labels;
        attributes = createAttributes();
        insert attributes;
        attLabels = createAttributeLabel();
        insert attLabels;
        refFields = createRefFields();
        insert refFields;
        rtmapping = createReferenceTypeMapping();
        insert rtmapping;
    }
    
    //Referenceability_Type Setup
    static List < Referenceability_Type__c > setUpRFTypes() {
        List < Referenceability_Type__c > rftypesLst = new List < Referenceability_Type__c > ();
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType1'));
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType2'));
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType3'));
        return rftypesLst;
    }
    
    //Reference Content Type Setup
    static List <Reference_Content_Type__c> setUpRFContentTypes() {
        List <Reference_Content_Type__c> rfContentTypeList = new List <Reference_Content_Type__c> ();
        rfContentTypeList.add(new Reference_Content_Type__c(Name__c = 'RFContentType1'));
        rfContentTypeList.add(new Reference_Content_Type__c(Name__c = 'RFContentType2'));
        rfContentTypeList.add(new Reference_Content_Type__c(Name__c = 'RFContentType3'));
        return rfContentTypeList;
    }
    
    //Label Setup
    static list < Label__c > createLabels() {
        list < Label__c > tempList = new list < Label__c > ();
        tempList.add(new Label__c(name = 'testLabel1'));
        tempList.add(new Label__c(name = 'testLabel2'));
        return tempList;
    }
    
    //Attribute Setup
    static list < Attribute__c > createAttributes() {
        list < Attribute__c > tempAtt = new list < Attribute__c > ();
        tempAtt.add(new Attribute__c(name = 'testAtt1'));
        tempAtt.add(new Attribute__c(name = 'testAtt2'));
        tempAtt.add(new Attribute__c(name = 'testAtt3'));
        tempAtt.add(new Attribute__c(name = 'testAtt4'));
        return tempAtt;
    }
    
    //Attributes_Labels Setup
    static list < Attributes_Labels__c > createAttributeLabel() {
        list < Attributes_Labels__c > tempAttLabel = new list < Attributes_Labels__c > ();
        tempAttLabel.add(new Attributes_Labels__c(Attribute__c = attributes.get(0).Id, Label__c = labels.get(0).Id));
        tempAttLabel.add(new Attributes_Labels__c(Attribute__c = attributes.get(1).Id, Label__c = labels.get(0).Id));
        tempAttLabel.add(new Attributes_Labels__c(Attribute__c = attributes.get(2).Id, Label__c = labels.get(1).Id));
        tempAttLabel.add(new Attributes_Labels__c(Attribute__c = attributes.get(3).Id, Label__c = labels.get(1).Id));
        return tempAttLabel;
    }
    
    //Reference_Type_Mapping Setup
    static list < Reference_Type_Mapping__c > createReferenceTypeMapping() {
        list < Reference_Type_Mapping__c > tempRefMapping = new list < Reference_Type_Mapping__c > ();
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Name = 'OwnerId'));
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Label__c = labels.get(0).Id));
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Label__c = labels.get(1).Id));
        return tempRefMapping;
    }
    
    //Reference_Request_Field Setup
    static list < Reference_Request_Field__c > createRefFields() {
        list < Reference_Request_Field__c > tempFields = new list < Reference_Request_Field__c > ();
        tempFields.add(new Reference_Request_Field__c(order__c = 1, Field_API_Name__c = 'OwnerId', Name = 'OwnerId'));
        return tempFields;
    }
    
}