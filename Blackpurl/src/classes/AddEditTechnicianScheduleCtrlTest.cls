@isTest
private class AddEditTechnicianScheduleCtrlTest {
    
    @testsetup
    private static void setup(){
    	Technician__c technician = TestDataFactory.createTechnician();
        Leave__c leave = TestDataFactory.createLeave(technician.Id);
    }
    
    @isTest
    private static void testConstructor(){
    	Test.startTest();
    	AddEditTechnicianScheduleCtrl addEditTechnicianScheduleCtrl = new AddEditTechnicianScheduleCtrl();
    	AddEditTechnicianScheduleCtrl addEditTechnicianScheduleCtrlWithHomePage = new AddEditTechnicianScheduleCtrl(new NewHomePageCtrl());
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTechnicianById(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	String technicianDetail = AddEditTechnicianScheduleCtrl.getTechnicianById(BPUtility.getEncodedString(technician.Id));
    	TechnicianDetailWrapper technicianDetailWrapper = (TechnicianDetailWrapper)Json.deserialize(BPUtility.getDecodedString(technicianDetail), TechnicianDetailWrapper.class);
    	system.assertEquals(technicianDetailWrapper.Name , 'Test Name');
    	Test.stopTest();
    }
    
    @isTest
    private static void testSaveTechnicianDetail(){
    	Test.startTest();
    	List<Technician__c> technician = new List<Technician__c>([SELECT Id FROM Technician__c]);
    	technician[0].Working_Days__c = 'Monday';
    	technician[0].Role__c = 'Test Role';
    	technician[0].First_Name__c = 'Test Name';
    	technician[0].Last_Name__c = 'Test Name';
    	TechnicianDetailWrapper techWrapper = new TechnicianDetailWrapper(technician[0]);
    	String technicianDetail = System.JSON.serialize(techWrapper, false);
    	String result = AddEditTechnicianScheduleCtrl.saveTechnicianDetail(BPUtility.getEncodedString(technicianDetail));
    	system.assertEquals('SUCCESS', BPUtility.getDecodedString(result));
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTechnicianLeavesByTechnicianId(){
    	Test.startTest();
    	Technician__c technician = [SELECT Id FROM Technician__c LIMIT 1];
    	String technicianLeaveDetail = AddEditTechnicianScheduleCtrl.getTechnicianLeavesByTechnicianId(BPUtility.getEncodedString(technician.Id));
    	List<LeaveWrapper> leaveWrapper = new List<LeaveWrapper>();
    	leaveWrapper = (List<LeaveWrapper>)System.Json.deserialize(BPUtility.getDecodedString(technicianLeaveDetail), List<LeaveWrapper>.class);
    	system.assertEquals(leaveWrapper[0].Type, 'Annual Leave');
    	Test.stopTest();
    }
    
    @isTest
    private static void testSaveLeaveDetail(){
    	Test.startTest();
    	String query = 'SELECT ';  
    	for(String fieldsName : LeaveWrapper.getLeaveFieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
        	query += fieldsName + ', ';  
    	}
    	query = query.substring(0, query.length()-2);
    	query += ' FROM Leave__c LIMIT 1';
    	Leave__c leave = Database.query(query);
		LeaveWrapper leaveWrapper = new LeaveWrapper(leave);
		String leaveJSON = system.JSON.serialize(leaveWrapper, false);
		String result = AddEditTechnicianScheduleCtrl.saveLeaveDetail(BPUtility.getEncodedString(leaveJSON));
		LeaveWrapper leaveWrapperJson = (LeaveWrapper)Json.deserialize(BPUtility.getDecodedString(result), LeaveWrapper.class);
		system.assertEquals(leaveWrapperJson.Type, 'Annual Leave');
		Test.stopTest();
    }
    
    @isTest
    private static void testDeleteLeave(){
    	Test.startTest();
    	Leave__c leave = [SELECT Id FROM Leave__c LIMIT 1];
    	String result = AddEditTechnicianScheduleCtrl.deleteLeave(BPUtility.getEncodedString(leave.Id));
    	system.assertEquals('SUCCESS', BPUtility.getDecodedString(result));
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetMasterData(){
    	Test.startTest();
    	String workingDays = AddEditTechnicianScheduleCtrl.getMasterData();
    	List<String> shopSettingList = new List<String>((List<String>)Json.deserialize((BPUtility.getDecodedString(workingDays)), List<String>.class));
    	system.assertEquals(0, shopSettingList.size());
    	Test.stopTest();
    }
}