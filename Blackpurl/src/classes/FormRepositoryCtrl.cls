/** 
* Author: Richa Mittal <richa.mittal@metacube.com>
* Since: July 18, 2018 
* Name: FormRepositoryCtrl
* Description: Apex class which contains all remoted methods related to form repository
**/
global  with sharing class FormRepositoryCtrl {
    public static Decimal MAX_HEAP_SIZE = 5000000;
    global FormRepositoryCtrl(NewHomePageCtrl controller){} 
    public FormRepositoryCtrl() {}
    
    @RemoteAction
    global static String getFormsListBasedOnType(String formType) {
        formType = BPUtility.getDecodedString(formType);
        try {
            Map<String, List<FormRepositoryWrapper>> formRepositoryTypeToRecordListMap = FormRepositoryService.getFormsListBasedOnType(formType);
            return BPUtility.getEncodedString(system.JSON.serialize(formRepositoryTypeToRecordListMap, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    // Deprecated
    @RemoteAction
    global static void activateForm(String formId, Boolean isActivate, Boolean isManualUpload) {
        
    }
    
    // Deprecated
    @RemoteAction
    global static void deleteForm(String formId) {
        
    }
    
    @RemoteAction
    global static String removeForm(String formId) {
        formId = BPUtility.getDecodedString(formId);
        try {
            return FormRepositoryService.deleteForm(formId);
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    // Deprecated
    @RemoteAction
    global static void activateForms(String formJson) {
        
    }
    
    @RemoteAction
    global static String activateFormList(String formJson) {
        formJson = BPUtility.getDecodedString(formJson);
        try {
            return FormRepositoryService.activateForm(formJson);
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String uploadForm(String formJson, String fileData) {
        formJson = BPUtility.getDecodedString(formJson);
        fileData = BPUtility.getDecodedString(fileData);
        if(Limits.getHeapSize() > MAX_HEAP_SIZE) {
            return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'File size is large')));
        }
        if(fileData == null) {
            return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'Invalid file data')));
        }
        try {
            FormRepositoryService.uploadForm(formJson, fileData);
            return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('success', 'success')));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String saveForm(String formJson) {
        formJson = BPUtility.getDecodedString(formJson);
        try {
            return FormRepositoryService.saveForm(formJson);
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
}