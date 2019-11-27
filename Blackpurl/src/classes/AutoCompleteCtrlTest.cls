/**
 * Author: Nidhi Sharma
 * Since: August 31, 2016
 * Name: AutoCompleteCtrlTest
 * Description: Test class for AutoCompleteCtrl
**/

@isTest
private class AutoCompleteCtrlTest {
    
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
    }
    
    static testMethod void testGetSearchResults1() {
        createTestData();
        String queryJson = '';
        AutoCompleteCtrl.QueryJSON queryJsonObj = new AutoCompleteCtrl.QueryJSON();
        queryJsonObj.ObjectLabel = 'Customer';
        queryJsonObj.SearchText = 'TestCustomer1';
        queryJsonObj.SearchFieldName = 'Name';
        queryJsonObj.FilterValues = null;
        
        queryJson = System.JSON.serialize(queryJsonObj);
        String searchResultJson = BPUtility.getDecodedString(AutoCompleteCtrl.getSearchResults(BPUtility.getEncodedString(queryJson)));
        AutoCompleteCtrl.ResultJSON resultJsonRec = (AutoCompleteCtrl.ResultJSON)Json.deserialize(searchResultJson,AutoCompleteCtrl.ResultJSON.class);
        System.assertEquals(resultJsonRec.CustomerList[0].Email.tolowercase(),'TestCustomer1@gmail.com'.tolowercase());
        queryJsonObj = new AutoCompleteCtrl.QueryJSON();
        queryJsonObj.ObjectLabel = 'Vendor';
        queryJsonObj.SearchText = '1123';
        queryJsonObj.SearchFieldName = 'Preferred_Phone__c';
        queryJsonObj.FilterValues = null;
        queryJson = System.JSON.serialize(queryJsonObj);
        
        // START: edited by kajal 25th april, 2017
        searchResultJson = BPUtility.getDecodedString(AutoCompleteCtrl.getSearchResults(BPUtility.getEncodedString(queryJson)));
        resultJsonRec = (AutoCompleteCtrl.ResultJSON)Json.deserialize(searchResultJson,AutoCompleteCtrl.ResultJSON.class);
        //ayushi start
         String formattedNumber = AutoCompleteCtrl.formatphonenumber(resultJsonRec.CustomerList[0].Phone);
         Sobject testCustomer = TestUtil.createCustomer(true, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123');
         AutoCompleteCtrl.ResultJSON resultJsonRec1 = new AutoCompleteCtrl.ResultJSON(testCustomer);
        //ayushi end
        System.assertEquals(resultJsonRec.CustomerList[0].Phone,'(112) 356-8795');
        System.assertEquals(resultJsonRec.CustomerList[0].Name,'Vendor1');
        //System.assertNotEquals(null, searchResultJson);
        // END: edited by kajal 25th april, 2017
    }
    
    static testMethod void testGetSearchResults2() {
        createTestData();
        String queryJson = '';
        AutoCompleteCtrl.QueryJSON queryJsonObj = new AutoCompleteCtrl.QueryJSON();
        queryJsonObj.ObjectLabel = 'Customer';
        queryJsonObj.SearchText = 'John Wilson';
        queryJsonObj.SearchFieldName = 'Name';
        queryJsonObj.FilterValues = null;
        
        queryJson = System.JSON.serialize(queryJsonObj);
        String searchResultJson = BPUtility.getDecodedString(AutoCompleteCtrl.getSearchResults(BPUtility.getEncodedString(queryJson)));
        AutoCompleteCtrl.ResultJSON resultJsonRec = (AutoCompleteCtrl.ResultJSON)Json.deserialize(searchResultJson,AutoCompleteCtrl.ResultJSON.class);
        System.assertEquals(resultJsonRec.CustomerList[0].Email.tolowercase(),'abc@test.com'.tolowercase());
        
        queryJsonObj = new AutoCompleteCtrl.QueryJSON();
        queryJsonObj.ObjectLabel = 'Customer';
        queryJsonObj.SearchText = 'Customer';
        queryJsonObj.SearchFieldName = 'Name';
        queryJsonObj.FilterValues = null;
        
        queryJson = System.JSON.serialize(queryJsonObj);
        searchResultJson = BPUtility.getDecodedString(AutoCompleteCtrl.getSearchResults(BPUtility.getEncodedString(queryJson)));
        resultJsonRec = (AutoCompleteCtrl.ResultJSON)Json.deserialize(searchResultJson,AutoCompleteCtrl.ResultJSON.class);
        System.assertEquals(resultJsonRec.CustomerList[0].Email.tolowercase(),'test34@test.com'.tolowercase());
    }
    
    static void createTestData(){
         
        Account customer1 = TestUtil.createCustomer(false, 'Test Customer', 'test@gmail.com', 'NY', '5214789631');
        Account customer2 = TestUtil.createCustomer(false, 'Customer', 'test34@test.com', 'NY', '3567789670');
        customer2.Email__c = null;
        customer2.Other_Email__c = 'test34@test.com';
        
        Account customer3 = TestUtil.createCustomer(false, 'John Wilson', 'abc@test.com', 'NY', '4523785638');
        customer3.Email__c = null;
        customer3.Work_Email__c = 'abc@test.com';
        customer3.Work_Number__c = '1123568795';//added by kajal 25th april, 2017
        
        Account customer4 = TestUtil.createCustomer(false, 'TestCustomer1', 'test@gmail.com', 'NY', '5214789631');
        customer4.Preferred_Email__c = 'TestCustomer1@gmail.com';
        customer4.Is_Customer__c = true;
        customer2.Mobile__c = '1123568795';//added by kajal 25th april, 2017
        
        Account customer5 = TestUtil.createCustomer(false, 'TestCustomer1', 'test@gmail.com', 'NY', '5214789631');
        customer5.Preferred_Email__c = '23@gmail.com';
        customer5.Home_Number__c = '1123568795';//added by kajal 25th april, 2017
        customer5.Is_Customer__c = true;
        
        customer1.Is_Customer__c = true;
        
        customer2.Is_Customer__c = true;
        customer3.Is_Customer__c = true;
        
        insert new List<Account>{customer1, customer2, customer3,customer4,customer5};
        
        Account vendor1 = TestUtil.createCustomer(false, 'Test Vendor', 'test@gmail.com', 'NY', '5214789631');
        Account vendor2 = TestUtil.createCustomer(false, 'Vendor1', 'test34@test.com', 'NY', '3567789670');
        vendor2.Preferred_Phone__c = '1123568795';//added by kajal 25th april, 2017
        vendor1.Is_Vendor__c = vendor2.Is_Vendor__c = true;
        
        insert new List<Account>{vendor1, vendor2};
            
            
    }
}