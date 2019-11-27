@isTest
private class PayrollCtrlTest {
    @testsetup
    private static void setup(){
    	Technician__c technicianRec = TestDataFactory.createTechnician();
    	Payroll_Time__c payrollTimeRec = TestDataFactory.createPayrollTime(technicianRec.Id);
    	technicianRec.Active__c = true;
    	update technicianRec;
    	Hours_Logged__c hoursLoggedRec = TestDataFactory.createHoursLogged(technicianRec.Id, null, null);
    }
    
    @isTest
    private static void testConstructor(){
    	Test.startTest();
    	PayrollCtrl payrollCtrl = new PayrollCtrl();
    	PayrollCtrl payrollCtrlWithNewHomePageController = new PayrollCtrl(new NewHomePageCtrl());
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTechnicianList(){
    	Test.startTest();
    	String result = BPUtility.getDecodedString(PayrollCtrl.getTechnicianList());
    	List<PayrollWrapper> payrollWrapperList = new List<PayrollWrapper>((List<PayrollWrapper>)json.deserialize(result, List<PayrollWrapper>.class));
    	system.assertEquals('Test', payrollWrapperList[0].TechnicianFirstName);
    	Test.stopTest();
    }
    
    @isTest
    private static void testSaveClockStatus(){
    	Test.startTest();
		String query;   
        query = 'SELECT '; 
        for(String fieldsName : PayrollWrapper.getPayrollFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Payroll_Time__c LIMIT 1';
        Payroll_Time__c payrollTimeRec = Database.query(query);
        PayrollWrapper payrollWrapper = new PayrollWrapper(payrollTimeRec);
        payrollWrapper.IsClockedOn = false;
        String jsonString = json.serialize(payrollWrapper);
        String result = BPUtility.getDecodedString(PayrollCtrl.saveClockStatus(BPUtility.getEncodedString(jsonString)));
        List<PayrollWrapper> payrollWrapperList = new List<PayrollWrapper>((List<PayrollWrapper>)json.deserialize(result, List<PayrollWrapper>.class));
    	system.assertEquals('Test', payrollWrapperList[0].TechnicianFirstName);
    	Test.stopTest();
    }
    
    @isTest
    private static void testSaveClockStatusWithClockedOnTrue(){
    	Test.startTest();
		String query;   
        query = 'SELECT '; 
        for(String fieldsName : PayrollWrapper.getPayrollFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Payroll_Time__c LIMIT 1';
        Payroll_Time__c payrollTimeRec = Database.query(query);
        PayrollWrapper payrollWrapper = new PayrollWrapper(payrollTimeRec);
        payrollWrapper.IsClockedOn = true;
        String jsonString = json.serialize(payrollWrapper);
        String result = BPUtility.getDecodedString(PayrollCtrl.saveClockStatus(BPUtility.getEncodedString(jsonString)));
        List<PayrollWrapper> payrollWrapperList = new List<PayrollWrapper>((List<PayrollWrapper>)json.deserialize(result, List<PayrollWrapper>.class));
    	system.assertEquals('Test', payrollWrapperList[0].TechnicianFirstName);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPayrollOnForTechnician(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	PayrollCtrl.payrollOnForTechnician(technician.Id);
    	List<Payroll_Time__c> payrollTimeList = new List<Payroll_Time__c>([SELECT Id FROM Payroll_Time__c]);
    	system.assertEquals(payrollTimeList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPayrollOnForNewTechnician(){
    	Test.startTest();
    	Technician__c technician = TestDataFactory.createTechnician();
    	PayrollCtrl.payrollOnForTechnician(technician.Id);
    	List<Payroll_Time__c> payrollTimeList = new List<Payroll_Time__c>([SELECT Id FROM Payroll_Time__c]);
    	system.assertEquals(payrollTimeList.size(), 2);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetPayrollList(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	PayrollWrapper.PayrollFilterWrapper payrollFilterObj = new PayrollWrapper.PayrollFilterWrapper();
    	payrollFilterObj.StartDate = '15/03/2019';
    	payrollFilterObj.EndDate = '15/03/2019';
    	payrollFilterObj.EmployeeId = technician.Id;
    	String jsonString = json.serialize(payrollFilterObj);
    	String result = BPUtility.getDecodedString(PayrollCtrl.getPayrollList(BPutility.getEncodedString(jsonString)));
    	List<PayrollWrapper> payrollWrapperList = new List<PayrollWrapper>((List<PayrollWrapper>)json.deserialize(result, List<PayrollWrapper>.class));
    	system.assertEquals(payrollWrapperList.size(), 0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testSavePayrollRec(){
    	Test.startTest();
    	String query;   
        query = 'SELECT '; 
        for(String fieldsName : PayrollWrapper.getPayrollFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Payroll_Time__c LIMIT 1';
        Payroll_Time__c payrollTimeRec = Database.query(query);
        PayrollWrapper payrollWrapper = new PayrollWrapper(payrollTimeRec);
        payrollWrapper.IsClockedOn = false;
        String jsonString = json.serialize(payrollWrapper);
        String result = BPUtility.getDecodedString(PayrollCtrl.savePayrollRec(BPutility.getEncodedString(jsonString), BPUtility.getEncodedString('')));
        List<PayrollWrapper> payrollWrapperList = new List<PayrollWrapper>((List<PayrollWrapper>)json.deserialize(result, List<PayrollWrapper>.class));
    	system.assertEquals(payrollWrapperList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testDeletePayrollRec(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	PayrollWrapper.PayrollFilterWrapper payrollFilterObj = new PayrollWrapper.PayrollFilterWrapper();
    	payrollFilterObj.StartDate = '15/03/2019';
    	payrollFilterObj.EndDate = '15/03/2019';
    	payrollFilterObj.EmployeeId = technician.Id;
    	String filterWrapperString = json.serialize(payrollFilterObj);
    	
        Payroll_Time__c payrollTime = [SELECT Id FROM Payroll_Time__c LIMIT 1];
        
        String result = BPUtility.getDecodedString(PayrollCtrl.deletePayrollRec(BPUtility.getEncodedString(payrollTime.Id), BPUtility.getEncodedString(filterWrapperString)));
        List<PayrollWrapper> payrollWrapperList = new List<PayrollWrapper>((List<PayrollWrapper>)json.deserialize(result, List<PayrollWrapper>.class));
    	system.assertEquals(payrollWrapperList.size(), 0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPayrollWrapperSorting(){
    	Test.startTest();
    	Technician__c technicianRec = TestDataFactory.createTechnician();
    	Payroll_Time__c payrollTimeRec = TestDataFactory.createPayrollTime(technicianRec.Id);
    	technicianRec.Active__c = true;
    	update technicianRec;
    	
    	String query;   
        query = 'SELECT '; 
        for(String fieldsName : PayrollWrapper.getPayrollFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Payroll_Time__c';
        List<Payroll_Time__c> payrollTimeRecList= Database.query(query);
		List<PayrollWrapper> payrollWrapperList = new List<PayrollWrapper>();
		for(Payroll_Time__c payrollTime : payrollTimeRecList){
			payrollWrapperList.add(new PayrollWrapper(payrollTime));
		}
		payrollWrapperList.sort();
		system.assertEquals(payrollWrapperList.size(), 2);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPayrollWrapperSortingWithClockedOnNotNull(){
    	Test.startTest();
    	Technician__c technicianRec = TestDataFactory.createTechnician();
    	Payroll_Time__c payrollTimeRec = TestDataFactory.createPayrollTime(technicianRec.Id);
    	technicianRec.Active__c = true;
    	update technicianRec;
    	
    	String query;   
        query = 'SELECT '; 
        for(String fieldsName : PayrollWrapper.getPayrollFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Payroll_Time__c';
        List<Payroll_Time__c> payrollTimeRecList= Database.query(query);
		List<PayrollWrapper> payrollWrapperList = new List<PayrollWrapper>();
		for(Payroll_Time__c payrollTime : payrollTimeRecList){
			PayrollWrapper payrollWrapper = new PayrollWrapper(payrollTime);
			payrollWrapper.IsClockedOn = true;
			payrollWrapper.TimeIn = null;
			payrollWrapperList.add(payrollWrapper);
		}
		payrollWrapperList.sort();
		system.assertEquals(payrollWrapperList.size(), 2);
    	Test.stopTest();
    }
}