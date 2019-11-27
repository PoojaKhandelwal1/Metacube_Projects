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
public with sharing class TestUploadPhotoIconController {
    private Static FINAL String fixedFileName = 'communityPic.jpg';
    static testMethod void updateReferenceabilityType() {
        Referenceability_Type__c rf =  new Referenceability_Type__c(name = 'Test Refrence', Visible__c = true);
        insert rf;
        test.starttest();
     	String iconname = ' assets/icons/asset/doc';
        String jsonObj = jsongenerator(iconname,iconname,iconname,'new Ref1');
        String referenceabilityTypewrapper= jsonObj;
        UploadPhotoIconController.ReferenceabilityTypeWrapper referenceabilityTypeWrapperobj=(UploadPhotoIconController.ReferenceabilityTypeWrapper )JSON.deserialize(referenceabilityTypewrapper,UploadPhotoIconController.ReferenceabilityTypeWrapper.class);
        UploadPhotoIconController.updateReferenceabilityType(referenceabilityTypewrapper);
        String newicon =   geticonFromid(referenceabilityTypeWrapperobj.id);
        System.debug(newicon + 'newicon');
        system.assertnotequals('assets/icons/asset/doc' , newicon);
        iconname = null;    
        jsonObj = jsongenerator(iconname,iconname,iconname,'new Ref2');
        newicon =   geticonFromid(referenceabilityTypeWrapperobj.id);
        system.assertnotequals('', newicon);
        iconname = null;
        jsonObj = jsongenerator(iconname,iconname,iconname,'new Ref3');
        referenceabilityTypeWrapperobj=(UploadPhotoIconController.ReferenceabilityTypeWrapper)Json.deserialize(jsonObj,UploadPhotoIconController.ReferenceabilityTypeWrapper.class);
        String oldid  =  getAttachmentStringFromid(referenceabilityTypeWrapperobj.id);
        String newid =  generateAttachmentData(referenceabilityTypeWrapperobj.id);
        UploadPhotoIconController.updateReferenceabilityType(jsonObj);
        system.assertnotequals(oldid , newid);
        ApexPages.StandardController sc = new ApexPages.StandardController(rf);
        UploadPhotoIconController reftype = new UploadPhotoIconController(sc);
        
        test.stoptest();
    }
    static String jsongenerator(String iconname,String iconvalue,String iconclass,String fileinstring){
        UploadPhotoIconController.IconWrapper iconWrapperobj = new UploadPhotoIconController.IconWrapper(iconname,iconvalue,iconclass);
        String id = generateReferenceabilityType(fileinstring);
        UploadPhotoIconController.ReferenceabilityTypeWrapper referenceabilityTypeWrapperobj = new UploadPhotoIconController.ReferenceabilityTypeWrapper(id,iconWrapperobj, '');
        return Json.serialize(referenceabilityTypeWrapperobj);
    }
    static String  generateReferenceabilityType(String nameval){
        Referenceability_Type__c ref= new Referenceability_Type__c(name = nameval, Visible__c = true);
        insert ref;
        return ref.id;
    }
    static String  geticonFromid(String id){
        Referenceability_Type__c ref =  [Select id,icon__c from Referenceability_Type__c where Visible__c = true AND id =:id];
        return ref.icon__c;
    }
    static String  getAttachmentStringFromid(String id){
        List<attachment> ref =  [Select id,body from Attachment  where parentid= :id AND name = :fixedFileName LIMIT 1];
        if(ref.size() > 0){
            return ref.get(0).id;
        }
        else{
            return '';
        }
    }
    /*
    static String generateIconData(String iconvalue,String nameval){
        Referenceability_Type__c ref= new Referenceability_Type__c(icon__c = iconvalue,name = nameval);
        insert ref;
        return ref.id;
    }
    */
    static String generateAttachmentData(String refid){
        String s = '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';
        Attachment a = new Attachment(parentId = refid, name = fixedFileName, body = EncodingUtil.base64Decode(s));
        insert a;
        return a.id;
    }
}