@isTest
private class BaseIntegrationTest {
    
    private static list<customHttpHeaderWrapper> generateHeaderList(){
        customHttpHeaderWrapper header = new customHttpHeaderWrapper('Content-Type', 'applications/json');
        return new List<customHttpHeaderWrapper>{header};
    }
    
    private static testmethod void basicAuthTest(){
        IFW_IntegrationConfig__c parent = TestUtil.sampleIFWConfigForXero();
        parent.Username__c = 'test@test.com';
        parent.Password__c = 'password';
        parent.Auth_Scheme__c = 'Basic';
        insert parent;

        IFW_IntegrationConfigItem__c child = TestUtil.createIFWConfigItemForXero('Journal Entry' , parent.Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationMockHttpResponseGenerator());
        BaseIntegration.performCallout(parent, child, '{}', generateHeaderList());
        Test.stopTest();
        system.assertEquals(child.Entity_Name__c, 'Journal Entry');
    }
    
    private static testmethod void oAuth1Test(){
        IFW_IntegrationConfig__c parent = TestUtil.sampleIFWConfigForXero();
        parent.Consumer_Key__c = 'AHSKJHGHJGSHJGS';
        parent.Certificate_Name__c = 'XeroCertificate';
        parent.Auth_Scheme__c = 'OAuth1.0';
        parent.Integration_Name__c = 'Test';
        insert parent;

        IFW_IntegrationConfigItem__c child = TestUtil.createIFWConfigItemForXero('Journal Entry' , parent.Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationMockHttpResponseGenerator());
        BaseIntegration.performCallout(parent,child, '{}', generateHeaderList());
        Test.stopTest();
        system.assertEquals(child.Entity_Name__c, 'Journal Entry');
    }
}