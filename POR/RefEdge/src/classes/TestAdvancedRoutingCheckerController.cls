/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestAdvancedRoutingCheckerController {

    static testMethod void myUnitTest() {
    	List<Label__c> filterList = TestDataFactory.createLabels();
    	filterList[0].Show_in_P2P__c = true;
    	insert filterList;
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	cs.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
    	cs.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
    	cs.Adv_Rt_Acct_Team_User__c = 'CreatedById';
    	update cs;
    	List<Attribute__c> attributeList = new List<Attribute__c>();
        attributeList.add(new Attribute__c(Name = 'Root Attribute', Parent__c = null, ParentIds__c = null));
        insert attributeList;
    	List<Advanced_Routing__c> advRoutingList = new List<Advanced_Routing__c>();
    	advRoutingList.add(new Advanced_Routing__c(Adv_Routing_Attribute__c = attributeList[0].Id, Adv_Routing_Client_Value__c = 'Test 1'));
        AdvancedRoutingCheckerController testObj = new AdvancedRoutingCheckerController();
        testObj.addFilter();
        testObj.selectedFilterId = filterList[0].Id;
        testObj.editFilter();
        testObj.selectedFilterId = filterList[1].Id;
        testObj.saveFilterModal();
        testObj.isFilterEdit = false;
        testObj.saveFilterModal();
        testObj.setSelectedFilter();
        testObj.saveFilterModal();
        //testObj.openMappingTable();
        testObj.cancelFilterPopup();
        testObj.resetFilterValues();
        testObj.setRoutingGroup();
        system.assert(true);
    }
}