@isTest
public with sharing class GlobalControllerTest {
    
    static testMethod void getStaticResourceURLTest() {
        BP_Configurations__c BPConfigurationsRec = new BP_Configurations__c();
        BPConfigurationsRec.isLoadStaticResource__c = true;
        insert BPConfigurationsRec;
        GlobalController globalControllerObj = new GlobalController();
        system.assertEquals(GlobalController.Application.length() > 0, true);
    }
    
    static testMethod void gettResourceURLTest() {
        GlobalController globalControllerObj = new GlobalController();
        system.assertEquals(GlobalController.Application.length() > 0, true);
    }
        
}