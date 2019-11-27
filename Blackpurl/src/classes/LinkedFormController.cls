/** 
* Author: Richa Mittal <richa.mittal@metacube.com>
* Since: July 19, 2018
* Name: LinkedFormController
* Description: Apex class which contains all remoted methods related to linked form
**/
global  with sharing class LinkedFormController {
    global LinkedFormController(NewHomePageCtrl controller){} 
    public LinkedFormController() {}
    
    @RemoteAction
    global static String getActiveFormsByGroup(String groupingName) {
        groupingName = BPUtility.getDecodedString(groupingName);
        try {
            List<FormRepositoryWrapper> activeFormsList = LinkedFormService.getActiveFormsByGroup(groupingName);
            return BPUtility.getEncodedString(system.JSON.serialize(activeFormsList, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getVendorProducts() {
        try {
            List<LinkedFormWrapper.VendorProductWrapper> vendorProductsList = LinkedFormService.getVendorProducts();
            return BPUtility.getEncodedString(system.JSON.serialize(vendorProductsList, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String saveLinkedForm(String linkedFormJson) {
        linkedFormJson = BPUtility.getDecodedString(linkedFormJson);
        try {
            LinkedFormWrapper linkedForm = LinkedFormService.saveLinkedForm(linkedFormJson);
            return BPUtility.getEncodedString(system.JSON.serialize(linkedForm, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getLinkedFormsByGroup(String groupingName) {
        groupingName = BPUtility.getDecodedString(groupingName);
        try {
            List<LinkedFormWrapper> linkedFormsList = LinkedFormService.getLinkedFormsByGroup(groupingName);
            return BPUtility.getEncodedString(system.JSON.serialize(linkedFormsList, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String deleteLinkedForm(String linkedFormId) {
        linkedFormId = BPUtility.getDecodedString(linkedFormId);
        try {
            LinkedFormService.deleteLinkedForm(linkedFormId);
            return BPUtility.getEncodedString('Success');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getOverviewDetails() {
        try {
            return BPUtility.getEncodedString(System.JSON.serialize(LinkedFormService.getOverviewDetails(), true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
}