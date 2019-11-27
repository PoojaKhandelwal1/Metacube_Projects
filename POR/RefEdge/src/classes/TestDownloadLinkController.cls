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
 * Description: test class for DownloadLinkController
 * Last modified by: Gaurav Saini (20 Dec, 2016)
 */
@isTest(seeAllData = false)
public with sharing class TestDownloadLinkController {
    
    static testMethod void testContentDownload() {
        User u = TestDataFactory.CreateUser();
        insert u;
        
        Test.startTest();
        
	        system.runAs(u) {
	        	// creating custom settings
	            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
	            insert cs;
	            
	            // creating content version
	            ContentVersion cv = TestDataFactory.createContentVersion(u);
	            Reference_Content_Type__c customRefContent = TestDataFactory.createContentType();
	            insert customRefContent;
	            
	            // creating reference content
	            List<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
	            referObject[0].Reference_Content_Type__c = customRefContent.Id;
	            insert referObject;
	            
	            // setting page parameters
	            Apexpages.currentPage().getParameters().put('ContentId', '');
	            
	            // instance of the controller
	            DownloadLinkController controllerObj = new DownloadLinkController();
	            controllerObj.selectedRefContentId = referObject[0].Id;
	            
	            // calling the download count increment method
	            controllerObj.updateContentDownloadCount();
	            
	            // getting the data from DB to verify
	            referObject = [SELECT Id, Number_of_Download__c, Ref_Content_Open_Clicks__c
	            				FROM Reference_Content__c
	            				WHERE Id = :referObject[0].Id];
	            
	            // verifying the new values in the open/download count fields on ref content
	            system.assertEquals(1, referObject[0].Number_of_Download__c);
	        }
        Test.stopTest();
    }
    
    static testMethod void testContentOpen() {
        User u = TestDataFactory.CreateUser();
        insert u;
        
        Test.startTest();
        
	        system.runAs(u) {
	        	// creating custom settings
	            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
	            insert cs;
	            
	            // creating content version
	            ContentVersion cv = TestDataFactory.createContentVersion(u);
	            Reference_Content_Type__c customRefContent = TestDataFactory.createContentType();
	            insert customRefContent;
	            
	            // creating reference content
	            List<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
	            referObject[0].Reference_Content_Type__c = customRefContent.Id;
	            insert referObject;
	            
	            // setting page parameters
	            Apexpages.currentPage().getParameters().put('ContentURL', '');
	            
	            // instance of the controller
	            DownloadLinkController controllerObj = new DownloadLinkController();
	            controllerObj.selectedRefContentId = referObject[0].Id;
	            
	            // calling the open count increment method
	            controllerObj.updateContentOpenCount();
	            
	            // getting the data from DB to verify
	            referObject = [SELECT Id, Number_of_Download__c, Ref_Content_Open_Clicks__c
	            				FROM Reference_Content__c
	            				WHERE Id = :referObject[0].Id];
	            
	            // verifying the new values in the open/download count fields on ref content
	            system.assertEquals(1, referObject[0].Ref_Content_Open_Clicks__c);
	        }
        Test.stopTest();
    }
}