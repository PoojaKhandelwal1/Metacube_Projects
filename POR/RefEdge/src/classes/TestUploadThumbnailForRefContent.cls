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
 * Description: test class for Upload Thumbnail inline page on ref content detail page
 * Last modified by: Gaurav Saini (6 June, 2017) for #498
 */
@isTest
private class TestUploadThumbnailForRefContent {
	
    static testMethod void testUploadAttachment() {
        List<Reference_Content__c> refContentList = TestDataFactory.createReferenceContent();
        insert refContentList;
        ApexPages.StandardController sc = new ApexPages.StandardController(refContentList[0]);
        UploadThumbnailForRefContentController testObj = new UploadThumbnailForRefContentController(sc);
        String uploadResult1 = UploadThumbnailForRefContentController.uploadAttachment(refContentList[0].Id, 'testattachmentbody', 'documentThumbnail.jpg', null);
        String uploadResult2 = UploadThumbnailForRefContentController.uploadAttachment(null, 'testattachmentbody', 'documentThumbnail.jpg', null);
        String uploadResult3 = UploadThumbnailForRefContentController.uploadAttachment(refContentList[0].Id, '', 'documentThumbnail.jpg', null);
    	system.assertNotEquals(uploadResult1, '');
    }
    
    static testMethod void testGetContentVersion() {
    	User testUser = TestDataFactory.createUser();
    	insert testUser;
        ContentVersion testCV = TestDataFactory.createContentVersion1(testUser);
        insert testCV;
        String testResult = UploadThumbnailForRefContentController.getContentVersion(testCV.Id);
        system.assertNotEquals('', testResult);
    }
    
    static testMethod void testGetImageSource() {
    	User testUser = TestDataFactory.createUser();
    	insert testUser;
        ContentVersion testCV = TestDataFactory.createContentVersion1(testUser);
        insert testCV;
        Reference_Content__c testRC = new Reference_Content__c(Title__c = 'Test ref content', Is_File_Changed__c = false);
        insert testRC;
        testCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testCV.Id];
        String base64Data1 = UploadThumbnailForRefContentController.getImageSource(testCV.ContentDocumentId);
        String base64Data = UploadThumbnailForRefContentController.getImageSource(testCV.ContentDocumentId, testRC.Id);
        system.assertEquals('', base64Data);
        String saveThumbnailResult = UploadThumbnailForRefContentController.saveThumbnail('test base 64 data', testRC.Id);
        system.assertEquals('success', saveThumbnailResult);
        saveThumbnailResult = UploadThumbnailForRefContentController.saveThumbnail('test base 64 data', '');
        system.assertEquals('failure', saveThumbnailResult);
    }
}