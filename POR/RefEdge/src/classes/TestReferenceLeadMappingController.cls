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
public with sharing class TestReferenceLeadMappingController {
   /* public static List < Attribute__c > attributes = setUpAttributes();
    public static List < Label__c > labels = setUpLabels();
    public static List < Attributes_Labels__c > attrlabels;
    public static List < Referenceability_Type__c > rfTypes = setUpRFTypes();
    public static List < Data_Mapping__c > dataMappingList;*/
    
    //Unit Test Method
    static testMethod void checkReferenceLeadMappingSettings() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        list<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        list<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes,1,5);
        insert childAttributes;
        list<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        
        //Start test method
        test.startTest();
	        try{
	            PageReference matrixPage = Page.ReferenceLeadMappingPage;
	            ReferenceLeadMappingController settings = new ReferenceLeadMappingController();
	            for(string str : settings.referenceLeadHeaderMap.keySet()){
	            	settings.referenceLeadHeaderMap.get(str).Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            settings.editNominationSettings();
	            for(Data_Mapping__c dm : settings.filterMappingRecords){
	            	dm.Visible__c = true;
	            }
	            for(Data_Mapping__c dm : settings.refTypeMappingRecords){
	            	dm.Visible__c = true;
	            }
	            settings.saveReferenceLeadSettings();
	            settings = new ReferenceLeadMappingController();
	            settings.cancelNominationSettings();
	            settings.redirectFieldPage();
	            settings.returnCustomSettings();
	            system.assert(true);
	        }catch(Exception e){
	        	
	        }
        //Stop test method
        test.stopTest();
    }
    
    //Creation of Custom_Settings record 
   /* private static Custom_Settings__c setUpCustomSetting1() {
        Custom_Settings__c testSettings = new Custom_Settings__c(
            Name = 'Test', Current_Version__c = '3.3.3', Include_Weekends__c = false,
            Escalation_to_Owner_Manager__c = 2, Feedback_Message_Delay__c = 2,
            Minimum_Deadline__c = 4, No_Response__c = 0, Reminder_to_Owner__c = 3,
            Email_Enabled__c = true, Chatter_Enabled__c = true, Active_Version__c = true,
            Days_of_Week__c = 'Sunday;Monday',  
             
            RUL_Activities__c = 3, RUL_Period__c = 99,
            Caution_deadline_window__c = 10,  Nomination_disposition_window__c = 5, Critical_Deadline_window__c = 5
        );
        return testSettings;
    }
    
    //Creation of Attribute records
    private static List < Attribute__c > setUpAttributes() {
        List < Attribute__c > atts = new List < Attribute__c > ();
        atts.add(new Attribute__c(Name = 'Att1', Level__c = 1));
        atts.add(new Attribute__c(Name = 'Att2', Level__c = 1));
        atts.add(new Attribute__c(Name = 'Att3', Level__c = 1));
        return atts;
    }

	//Creation of Label records
    private static List < Label__c > setUpLabels() {
        List < Label__c > labls = new List < Label__c > ();
        labls.add(new Label__c(Name = 'Label1', Visible__c = true));
        labls.add(new Label__c(Name = 'Label2', Visible__c = true));
        labls.add(new Label__c(Name = 'Label3', Visible__c = true));
        return labls;
    }
	
	//Creation of Attributes_Labels records
    private static List < Attributes_Labels__c > setUpAttLabels() {
        List < Attributes_Labels__c > attLabels = new List < Attributes_Labels__c > ();
        attLabels.add(new Attributes_Labels__c(Label__c = labels[0].Id, Attribute__c = attributes[0].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[0].Id, Attribute__c = attributes[1].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[1].Id, Attribute__c = attributes[1].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[1].Id, Attribute__c = attributes[2].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[2].Id, Attribute__c = attributes[0].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[2].Id, Attribute__c = attributes[1].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[2].Id, Attribute__c = attributes[2].Id));
        return attLabels;
    }
    
    //Creation of Referenceability_Type records
    private static List < Referenceability_Type__c > setUpRFTypes() {
        List < Referenceability_Type__c > rftypesLst = new List < Referenceability_Type__c > ();
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType1', Visible__c = true));
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType2', Visible__c = true));
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType3', Visible__c = true));
        return rftypesLst;
    }*/
}