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
 * Page : UploadPhotoIcon.page
 * Description: controller for page to upload community image and icon for referenceability type
 * Last Modified By: Gaurav Saini (15 June) for #776
 */
global with sharing class UploadPhotoIconController {
    /**
     * Properties and variables
     */
    private Static FINAL String fixedFileName = 'communityPic.jpg';
    private static final String baseiconurlpath= '/assets/icons/';
    public Id currentPicture { get; set; }
    public static String showimg { get; set; }
    public static String iconurl { get; set; }
    public Boolean isAllowedPremission { get; set; }
    public Boolean isSLDS { get; set; }
    
    /**
     * Deprecated Constructor
     */
    global UploadPhotoIconController() {}
    
    /**
     * Constructor
     */
    global UploadPhotoIconController(ApexPages.StandardController controller) {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        Referenceability_Type__c pageContact = (Referenceability_Type__c)controller.getRecord();
        // Check User premissions.
    	isAllowedPremission = (checkPermissions()) ? true : false;
        String id = pageContact.Id;
        String downloadurl = '';
        iconurl = '';
        pageContact = new Referenceability_Type__c();
        List<Referenceability_Type__c> refts = [SELECT Id, Icon__c FROM Referenceability_Type__c WHERE Visible__c = true AND Id = :id];
        
        if (refts.size() > 0) {
        	pageContact = refts[0];
        }
        iconurl = pageContact.Icon__c;
        List<attachment> currentPictures = [SELECT Id, Body FROM Attachment
    										WHERE ParentId = :id AND Name = :fixedFileName LIMIT 1];
        
        if (currentPictures.size() != 0) {
            currentPicture = currentPictures.get(0).Id;
        }
    }
    
    /**
     * Method used to update referenceabilityType
     */
    @RemoteAction
    global static void updateReferenceabilityType(String referenceabilityTypeWrapperstring) {
    	
    	if (checkPermissions()) {
	        ReferenceabilityTypeWrapper referenceabilityTypeWrapperobj
        			= (ReferenceabilityTypeWrapper)Json.deserialize(referenceabilityTypeWrapperstring, ReferenceabilityTypeWrapper.class);
	        String currentPicture = ''; 
	        
	        if (referenceabilityTypeWrapperobj.fileinstring != '' && referenceabilityTypeWrapperobj.fileinstring != null) {
	            List<attachment> savedPicture = [SELECT Id, Name, Body FROM Attachment
	            									WHERE parentId = :referenceabilityTypeWrapperobj.Id
	            									AND name = :fixedFileName];
	            
	            if (savedPicture.size() > 0) {
	                delete savedPicture;
	            }
	            Attachment a = new Attachment(ParentId = referenceabilityTypeWrapperobj.Id, Name = fixedFileName, 
	            								Body = EncodingUtil.base64Decode(referenceabilityTypeWrapperobj.fileinstring));
	            insert a;
	            showimg= referenceabilityTypeWrapperobj.fileinstring;
	            currentPicture = a.Id;
	        } 
	        
	        if (referenceabilityTypeWrapperobj.iconwrapper != null && referenceabilityTypeWrapperobj.iconwrapper.value != null) {
	            List<Referenceability_Type__c> reflist = [SELECT Id, Icon__c FROM Referenceability_Type__c
	            											WHERE Visible__c = true AND Id = :referenceabilityTypeWrapperobj.Id LIMIT 1];
	            
	            if (reflist.size() > 0) {
	                Referenceability_Type__c refobj = reflist.get(0);
	                refobj.Icon__c = baseiconurlpath + referenceabilityTypeWrapperobj.iconwrapper.value;
	                update refobj;
	            }
	        }
    	}
    }
    
    /**
     * Method to check Permissions-Check parent object premissions
     */
    public static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	fieldMap.put(UtilityController.appNamespace() + 'Referenceability_Type__c', new Set<String> { UtilityController.appNamespace() + 'icon__c' }); 
    	Boolean isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> { UtilityController.appNamespace() + 'Referenceability_Type__c'});    	
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
        return (isUpsertPermission && isDeletePermission);
    }
    
    /**
     * ReferenceabilityType Wrapper class
     */ 
    public class ReferenceabilityTypeWrapper {
        public String id { get; set; }
        public IconWrapper iconwrapper { get; set; }
        public String fileinstring { get; set; }
        
        public ReferenceabilityTypeWrapper(String id, Iconwrapper iconwrapperobj, String fileinstring) {
            this.id = id;
            this.iconwrapper = iconwrapperobj;
            this.fileinstring = fileinstring;
        }
    }
    
    /**
     * Icon Wrapper class
     */ 
    public class IconWrapper {
        public String name;
        String value;
        String cssclass;
        
        public IconWrapper(String name, String value, String cssclass) {
            this.name = name;
            this.value = value;
            this.cssclass = cssclass;
        }
    } 
}