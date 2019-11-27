global class IntegrationLog {
    
    @future(callout=true)
    global static void createLog(String cls, String method, String errMsg, String errorCode, String stackTrace, String methodParams) {
        Error errorLog = new Error(cls, method, errMsg, errorCode, stackTrace, methodParams);
        createLog(errorLog);
    }
    
    public static void createLog(Error errorLog) {
        //IntegrationLogService.createLog(errorLog);
    }
    
    // A Virtual Class that defines the Structure of a Log
    public virtual class Log {
        public String Type;
        public String ApexClass;
        public String Method;
        public String MethodParams;
        public String Info;
        public String ErrorCode;
        public String StackTrace;
        public String OrgId;
        public String OrgName;
    }
    
    // A Class that Extends the Virtual Class - Log to define a log of type - Error
    public class Error extends Log {
        public Error(String cls, String method, String errMsg, String errorCode, String stackTrace, String methodParams) {
            this.Type = 'Error';
            this.ApexClass = cls;
            this.Method = method;
            this.MethodParams = methodParams;
            this.Info = errMsg;
            this.ErrorCode = errorCode;
            this.StackTrace = stackTrace;
            this.OrgId = UserInfo.getOrganizationId();
            this.OrgName = UserInfo.getOrganizationName();
        }
    }
    
    // A Class that Extends the Virtual Class - Log to define a log of type - Information
    public class Information extends Log {
        public Information(String cls, String method, String recId, String msg){
            this.Type = 'Info';
            this.ApexClass = cls;
            this.Method = method;
            this.Info = msg;
            this.OrgId = UserInfo.getOrganizationId();
            this.OrgName = UserInfo.getOrganizationName();
        }
    }
}