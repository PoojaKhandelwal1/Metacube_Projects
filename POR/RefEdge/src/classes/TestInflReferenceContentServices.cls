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
* Class: nflRewardsAndNominationServices
* Description : class to test and cover InflRewardsAndNominationServices
* Modified by: Rajesh @17 Sept 2018
*/
@isTest(seeAllData = false)
public with sharing class TestInflReferenceContentServices {
    /**
     * Test method to test API for nomination creation
     * author: Rajesh (17 Sept, 2018) for #1842
     */
    /* static testmethod void testPatchMethod(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();

        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Enabled_Content_Integration__c= true;  
            customSetting.Manage_ContentVersion_Custom_Fields__c = 'Boolean_Field__c,Date_Field__c,Getting_Started_Kit__c,Native_Content_field__c,Test_Field__c';
            update customSetting; 
          
            // Insert Ref Content 
            Reference_Content_Type__c customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
            insert customRefContent;
            List <ContentVersion> ContentVersionLst = TestDataFactory.setUpNativeContents();
            insert ContentVersionLst;
            Reference_Content__c tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c = customRefContent.Id,Custom_Reference_Content__c = true,
                                                                    Content_id__c=ContentVersionLst[0].id,External_Source_Id__c='testid',Content_URL__c ='testURL');
            insert tempObj; 
            
            String reqBody = '{"contentIds":["'+tempObj.id+'"]}';
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge/Content', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            
            req.requestBody = Blob.valueof(reqBody);
            req.httpMethod = 'Patch'; 
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response= res;  
            InflReferenceContentServices.getAllReferenceContentDetails(); 
            system.assert(res!= null); 
        }
         //Stop test method
        test.stopTest();
    } */
    
     /* static testmethod void testPatchMethodWithStartAndEndDate(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();

        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Enabled_Content_Integration__c= true;  
            customSetting.Manage_ContentVersion_Custom_Fields__c = 'Boolean_Field__c,Date_Field__c,Getting_Started_Kit__c,Native_Content_field__c,Test_Field__c';
            update customSetting; 
          
            // Insert Ref Content 
            Reference_Content_Type__c customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
            insert customRefContent;
            List <ContentVersion> ContentVersionLst = TestDataFactory.setUpNativeContents();
            insert ContentVersionLst;
            Reference_Content__c tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c = customRefContent.Id,Custom_Reference_Content__c = true,
                                                                    Content_id__c=ContentVersionLst[0].id,External_Source_Id__c='testid',Content_URL__c ='testURL');
            insert tempObj; 
            
            String reqBody = '{"startAt": "2017-09-20","endAt": "2018-07-20"}'; 
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge/Content', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            
            req.requestBody = Blob.valueof(reqBody);
            req.httpMethod = 'Patch'; 
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response= res;  
            InflReferenceContentServices.getAllReferenceContentDetails(); 
            system.assert(res!= null); 
        }
         //Stop test method
        test.stopTest();
    } */
    
    /* static testmethod void testDeleteMethod(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest(); 

        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Enabled_Content_Integration__c= true;             
            update customSetting; 
          
            // Insert Ref Content 
            Reference_Content_Type__c customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
            insert customRefContent;
            Reference_Content__c tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c = customRefContent.Id,Custom_Reference_Content__c = true);
            insert tempObj; 
            
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge/Content', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            req.addParameter('contentId', tempObj.Id);
            req.httpMethod = 'DELETE'; 
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response= res;  
            InflReferenceContentServices.deleteReferenceContnets(); 
            
            List<Reference_Content__c> lst = [SELECT ID FROM Reference_Content__c]; 
            if (lst != null) {
                system.assertEquals(lst.size(), 0);
            }
        }
         //Stop test method
        test.stopTest();
    } */
    
    static testmethod void testPostMethod() {
        User u = TestDataFactory.CreateUser();
        
        // start test method
        Test.startTest();
            System.runAs(u) {
                List<Reference_Content_Type__c> listRCT = TestDataFactory.createContentTypes();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                customSetting.Enabled_Content_Integration__c = true;
                customSetting.Default_Library__c = u.id;
                customSetting.Default_Reference_Content_Type__c = listRCT[0].id;
                update customSetting;
                Account testAcc = new Account(Name = 'test account 1');
                insert testAcc;
                Opportunity testOpp = new Opportunity(Name = 'test opp 1', AccountId = testAcc.Id, CloseDate = System.today(), StageName = 'Closed Won');
                insert testOpp;
                
                Reference_Content_Type__c customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
                insert customRefContent;
                List <ContentVersion> ContentVersionLst = TestDataFactory.setUpNativeContents();
                insert ContentVersionLst;
                Reference_Content__c tempObj = new Reference_Content__c(title__c = 'tempObj', Reference_Content_Type__c = customRefContent.Id, Custom_Reference_Content__c = true,
                                                                        Content_id__c = ContentVersionLst[0].id, External_Source_Id__c = 'testid1', Content_URL__c = 'https://www.google.com');
                insert tempObj;
                List<Attribute__c> rootAttsList = new List<Attribute__c>();
                rootAttsList.add(new Attribute__c(Name = 'Color', Parent__c = null, ParentIds__c = null));
                rootAttsList.add(new Attribute__c(Name = 'Technology', Parent__c = null, ParentIds__c = null));
                insert rootAttsList;
                List<Attribute__c> childAttsList = new List<Attribute__c>();
                childAttsList.add(new Attribute__c(Name = 'Red', Parent__c = rootAttsList[0].Id, Level__c = 1));
                childAttsList.add(new Attribute__c(Name = 'Blue', Parent__c = rootAttsList[0].Id, Level__c = 1));
                childAttsList.add(new Attribute__c(Name = 'Java', Parent__c = rootAttsList[1].Id, Level__c = 1));
                childAttsList.add(new Attribute__c(Name = 'JSP', Parent__c = rootAttsList[1].Id, Level__c = 1));
                insert childAttsList;
                List<Content_Attribute__c> contentAttList = new List<Content_Attribute__c>();
                contentAttList.add(new Content_Attribute__c(Attribute__c = childAttsList[0].Id, Reference_Content__c = tempObj.Id));
                insert contentAttList;

                String reqBody = '{"deletedContent":null,'
                                + '"contents":['
                                    + '{"title":"Date correct","summary":"new summary","substitute_account_name":null,'
                                        + '"search_terms_keywords":null,"review_date":null,"result":null,'
                                        + '"reference_content_type":"","publish_date":"2018-03-13","publication_name":null,'
                                        + '"language":"English","isSuccess":null,"internal_use":false,"featured_content":false,'
                                        + '"external_summary":null,"external_source_id":"testid1","expiration_date":null,'
                                        + '"content_version_custom_fields":[{"field_value": "fdsf","field_name": "Test Field"}],'
                                        + '"crm_content_Id":null,"content_url":"www.newContent1.com","content_status":"Inactive",'
                                        + '"content_id":"","author":null,"article_publication_date":null,"allow_social_sharing":false},'
                                    + '{"title":"Date correct","summary":null,"substitute_account_name":null,'
                                        + '"search_terms_keywords":null,"review_date":null,"result":null,'
                                        + '"reference_content_type":"Test1","publish_date":"2018-03-13","publication_name":null,'
                                        + '"language":null,"isSuccess":null,"internal_use":false,"featured_content":false,'
                                        + '"external_summary":null,"external_source_id":"testid2","expiration_date":null,'
                                        + '"content_version_custom_fields":[{"field_value": "fdsf","field_name": "Test Field"}],'
                                        + '"crm_content_Id":null,"content_url":"www.newContent1.com","content_status":"Inactive",'
                                        + '"content_id":"","author":null,"article_publication_date":null,"allow_social_sharing":false,'
                                        + '"attributes_map":{"Color":"Red;Blue","Technology":"Java;Salesforce"}},'
                                    + '{"title":"Date correct","summary":null,"substitute_account_name":null,'
                                        + '"search_terms_keywords":null,"review_date":null,"result":null,'
                                        + '"reference_content_type":"","publish_date":"2018-03-13","publication_name":null,'
                                        + '"language":null,"isSuccess":null,"internal_use":false,"featured_content":false,'
                                        + '"external_summary":null,"external_source_id":"testid3","expiration_date":null,'
                                        + '"content_version_custom_fields":[{"field_value": "fdsf","field_name": "Test Field"}],'
                                        + '"crm_content_Id":null,"content_url":"www.newContent1.com","content_status":"Inactive",'
                                        + '"content_id":"","author":null,"article_publication_date":null,"allow_social_sharing":false,'
                                        + '"opportunity_id":"' + testOpp.Id + '"}]}';
                
                RestRequest req = new RestRequest();
                req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge/Content',
                                                    new List<String>{URL.getSalesforceBaseURL().toExternalForm()});
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueof(reqBody);
                RestContext.request = req;
                RestResponse res = new RestResponse();
                RestContext.response = res;
                InflReferenceContentServices.createReferenceContent();
                system.assert(res != null);
            }
        // Stop test method
        Test.stopTest();
    }
    
    /* static testmethod void testPostMethodWithContentId(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();
        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Enabled_Content_Integration__c = true;  
            List<Reference_Content_Type__c> listRCT = TestDataFactory.createContentTypes();
            customSetting.Default_Library__c = listRCT[0].id; 
            customSetting.Default_Reference_Content_Type__c = listRCT[0].id; 
            update customSetting; 
            
            Reference_Content_Type__c customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
            insert customRefContent;
            List <ContentVersion> ContentVersionLst = TestDataFactory.setUpNativeContents();
            insert ContentVersionLst;
            Reference_Content__c tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c = customRefContent.Id,Custom_Reference_Content__c = true,
                                                                    Content_id__c=ContentVersionLst[0].id,External_Source_Id__c='testid',Content_URL__c ='testURL');
            insert tempObj; 
            
            String reqBody ='{"deletedContent":null,"contents":[{"title":"Date correct","summary":null,"substitute_account_name":null,"search_terms_keywords":null,"review_date":null,"result":null,"reference_content_type":"","publish_date":"2018-03-13","publication_name":null,"language":null,"isSuccess":null,"internal_use":false,"featured_content":false,"external_summary":null,"external_source_id":"abcd","expiration_date":null,"content_version_custom_fields":[{"field_value": "fdsf","field_name": "Test Field"}],"crm_content_Id":"'+tempObj.id+'","content_url":"www.newContent1.com","content_status":"Inactive","content_id":"'+tempObj.Content_ID__c+'","author":null,"article_publication_date":null,"allow_social_sharing":false}]}';   
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge/Content', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()});  
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(reqBody);
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response = res;  
            InflReferenceContentServices.createReferenceContent();    
            system.assert(res!= null);
        }
         //Stop test method
        test.stopTest();
    } */
    
    /* static testmethod void testGetMethod(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest(); 

        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Enabled_Content_Integration__c= true;      
            customSetting.Manage_ContentVersion_Custom_Fields__c = 'Boolean_Field__c,Date_Field__c,Getting_Started_Kit__c,Native_Content_field__c,Test_Field__c';         
            update customSetting; 
          
            // Insert Ref Content 
            Reference_Content_Type__c customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
            insert customRefContent;
            List <ContentVersion> ContentVersionLst = TestDataFactory.setUpNativeContents();
            insert ContentVersionLst;
            Reference_Content__c tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c = customRefContent.Id,Custom_Reference_Content__c = true,
                                                                    Content_id__c=ContentVersionLst[0].id,External_Source_Id__c='testid',Content_URL__c ='testURL');
            insert tempObj; 
            
            RestRequest req = new RestRequest();
            req.requestURI = String.format('{0}/services/apexrest/v1.0/ReferenceEdge/Content', 
                                                new List<String>{URL.getSalesforceBaseURL().toExternalForm()}); 
            req.addParameter('contentId', tempObj.Id);
            req.httpMethod = 'GET'; 
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response= res;   
            InflReferenceContentServices.getReferenceContentDetails(); 
            system.assert(res!= null); 
        }
         //Stop test method
        test.stopTest();
    } */
    
    /* static testmethod void testDeleteContentDocument() {
        test.startTest(); 
            List <ContentVersion> ContentVersionLst = TestDataFactory.setUpNativeContents();
            insert ContentVersionLst;
            system.assert(ContentVersionLst.size() != 0);
            InflReferenceContentServices.deleteContentDocument(new List<Id> {ContentVersionLst[0].Id});
        test.stopTest();
    } */
    
}