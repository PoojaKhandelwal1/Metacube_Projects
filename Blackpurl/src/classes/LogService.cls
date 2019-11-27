/**
 * Author: Tarun Khandelwal
 * Since: May 21, 2018
 * Name: LogService
 * Description: Apex class to insert log.
**/
public with sharing class LogService {
    
    public static String METHOD_PARAM_SEPERATOR = '\n\n';
    public static String QUICKBOOKS = 'QB';
    public static String XERO = 'XERO';
    public static String NOT_APPLICABLE = 'N/A';
    
    public void createErrorLog(String cls, String method, String errMsg, String errorCode, String stackTrace, String methodParams) {
        createErrorLog(cls, method, errMsg, errorCode, stackTrace, methodParams, null);
    }
    
    public void createErrorLog(String cls, String method, String errMsg, Integer errorCode, String stackTrace, String methodParams, String integrationType) {
        createErrorLog(cls, method, errMsg, String.valueOf(errorCode), stackTrace, methodParams, integrationType, true);
    }
    
    public void createErrorLog(String cls, String method, String errMsg, String errorCode, String stackTrace, String methodParams, String integrationType) {
        createErrorLog(cls, method, errMsg, errorCode, stackTrace, methodParams, integrationType, true);
    }
    
    public Log__c createErrorLog(String cls, String method, String errMsg, Integer errorCode, String stackTrace, String methodParams, String integrationType, Boolean isInsert) {
        return createErrorLog(cls, method, errMsg, String.valueOf(errorCode), stackTrace, methodParams, integrationType, isInsert);
    }
    public Log__c createErrorLog(String cls, String method, String errMsg, String errorCode, String stackTrace, String methodParams, 
                                String integrationType, Boolean isInsert) {
        return createErrorLog(cls, method, errMsg, String.valueOf(errorCode), stackTrace, methodParams, integrationType, isInsert, 'Error');                            
   }
    public Log__c createErrorLog(String cls, String method, String errMsg, String errorCode, String stackTrace, String methodParams, 
                                String integrationType, Boolean isInsert, String failureType) {
        Error errorLogObj = new Error(cls, method, errMsg, errorCode, stackTrace, methodParams, integrationType, failureType);
    	if(isInsert) {
        	insert errorLogObj.logRec;
    	}
    	return errorLogObj.logRec;
    }
    
    public virtual class Log {
        public Log__c logRec;
        
        public Log() {
            logRec = new Log__c();
        }
    }
        
    // A Class that Extends the Virtual Class - Log to define a log of type - Error
    public class Error extends Log {
        public Error(String cls, String method, String errMsg, String errorCode, String stackTrace, String methodParams, String integrationType, String failureType) {
            logRec.Type__c = failureType;
            logRec.Apex_Class__c = cls;
            logRec.Method__c = method;
            logRec.Log_Info__c = (errMsg != null && errMsg.length() > 2000) ? errMsg.subString(0, 2000) : errMsg;
            logRec.Error_Code__c = errorCode;
            logRec.Method_Params__c = (methodParams != null && methodParams.length() > 2000) ? methodParams.subString(0, 2000) : methodParams;
            logRec.Stack_Trace__c = (stackTrace != null && stackTrace.length() > 255) ? stackTrace.subString(0, 255) : stackTrace;
            logRec.Integration_Type__c = integrationType;
        }
    }
        
    // A Class that Extends the Virtual Class - Log to define a log of type - Information
    public class Information extends Log {
        public Information(String cls, String method, String recId, String msg){
            logRec.Type__c = 'Info';
            logRec.Apex_Class__c = cls;
            logRec.Method__c = method;
            logRec.Method_Params__c = recId;
            logRec.Log_Info__c = msg;
        }
    }
}