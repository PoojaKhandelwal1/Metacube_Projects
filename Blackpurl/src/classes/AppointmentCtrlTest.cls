@isTest
private class AppointmentCtrlTest {
	
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test First Name', 'Test Last Name');
    	Unit_Make__c unitMake = TestDataFactory.createUnitMake('Test Unit Make', 'Tes', true);
    	Unit_Model__c unitModel = TestDataFactory.createUnitModel('Test Unit Model', 'Tes', true, unitMake.Id);
    	Unit_Sub_Model__c unitSubModel = TestDataFactory.createSubModel(unitModel);
    	Customer_Owned_Unit__c customerOwnedUnit = TestDataFactory.createCustomerOwnedUnit(customer.Id, unitMake.Id, unitModel.Id, unitSubModel.Id, 'VIN001');
    	CO_Header__c coHeader = TestDataFactory.createCoHeader(customer.Id);
    	Service_Order_Header__c soHeader = TestDataFactory.createSOHeader(coHeader.Id);
    	Event eventRecForMorning = TestDataFactory.createEventForMorning(customer.Id, customerOwnedUnit.Id);
    	Event eventRecForEvening = TestDataFactory.createEventForAfternoon(customer.Id, customerOwnedUnit.Id);
    	Event eventRecWithSOHeader = TestDataFactory.createEventWithServiceHeader(customer.Id, customerOwnedUnit.Id, soHeader.Id);
    	Shop_Settings__c shopSettings = TestDataFactory.createShopSettings('Monday');
    }
    
    @isTest
    private static void testConstructor(){
    	Test.startTest();
    	AppointmentCtrl appointmentCtrl = new AppointmentCtrl();
    	AppointmentCtrl appointmentCtrlWithHomePage = new AppointmentCtrl(new NewHomePageCtrl());
    	Event eventRec = [SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Morning' LIMIT 1];
    	AppointmentWrapper appointmentWrapper = new AppointmentWrapper(eventRec);
    	Account customer = [SELECT Id FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	system.assertEquals(appointmentWrapper.CustomerId, customer.Id);
    	Test.stopTest();
    }
    
    @isTest
    private static void testSaveAppointmentForMorning(){
    	Test.startTest();
    	Event eventRec = [SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Morning' LIMIT 1];
    	AppointmentWrapper appWrapper = new AppointmentWrapper(eventRec, true);
    	String appointmentDetailJSON = System.JSON.serialize(appWrapper, false);
    	String result = AppointmentCtrl.saveAppointment(BPUtility.getEncodedString(appointmentDetailJSON));
    	system.assertEquals('SUCCESS', BPUtility.getDecodedString(result));
    	Test.stopTest();
    }
    
    @isTest
    private static void testSaveAppointmentForAfternoon(){
    	Test.startTest();
    	Event eventRec = [SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Afternoon' LIMIT 1];
    	AppointmentWrapper appWrapper = new AppointmentWrapper(eventRec, true);
    	String appointmentDetailJSON = System.JSON.serialize(appWrapper, false);
    	String result = AppointmentCtrl.saveAppointment(BPUtility.getEncodedString(appointmentDetailJSON));
    	system.assertEquals('SUCCESS', BPUtility.getDecodedString(result));
    	Test.stopTest();
    }
    
    @isTest
    private static void testSaveAppointmentWithConflict(){
    	Test.startTest();
    	Event eventRec = [SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Afternoon' LIMIT 1];
    	AppointmentWrapper appWrapper = new AppointmentWrapper(eventRec, true);
    	appWrapper.isConflictExists = true;
    	String appointmentDetailJSON = System.JSON.serialize(appWrapper, false);
    	String result = AppointmentCtrl.saveAppointment(BPUtility.getEncodedString(appointmentDetailJSON));
    	system.assertEquals('SUCCESS', BPUtility.getDecodedString(result));
    	Test.stopTest();
    }
    
    @isTest
    private static void testSaveAppointmentWithServiceOrderHeader(){
    	Test.startTest();
    	Event eventRec = [SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Service_Order_Header__c != null LIMIT 1];
    	AppointmentWrapper appWrapper = new AppointmentWrapper(eventRec, true);
    	String appointmentDetailJSON = System.JSON.serialize(appWrapper, false);
    	String result = AppointmentCtrl.saveAppointment(BPUtility.getEncodedString(appointmentDetailJSON));
    	system.assertEquals('SUCCESS', BPUtility.getDecodedString(result));
    	Test.stopTest();
    }
    
    @isTest
    private static void testSaveAppointmentWithEventConcern(){
    	Test.startTest();
    	Event eventRec = [SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Morning' LIMIT 1];
    	String appointmentConcern = '';
    	for(Integer i = 0; i < 255; i++){
    		appointmentConcern = appointmentConcern + 'a';
    	}
    	eventRec.Appointment_Concern__c = appointmentConcern;
    	update eventRec;
    	AppointmentWrapper appWrapper = new AppointmentWrapper(eventRec, true);
    	String appointmentDetailJSON = System.JSON.serialize(appWrapper, false);
    	String result = AppointmentCtrl.saveAppointment(BPUtility.getEncodedString(appointmentDetailJSON));
    	system.assertEquals('SUCCESS', BPUtility.getDecodedString(result));
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetCustomerRecByCustomerId(){
    	Test.startTest();
    	Account customer = [SELECT Id FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	String customerRecord = AppointmentCtrl.getCustomerRecByCustomerId(BPUtility.getEncodedString(customer.Id));
    	CustomerWrapper customerWrapper = (CustomerWrapper)Json.deserialize(BPUtility.getDecodedString(customerRecord), CustomerWrapper.class);
    	system.assertEquals(customerWrapper.CustomerRecord.FirstName, 'Test First Name');
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetUnitById(){
    	Test.startTest();
    	Customer_Owned_Unit__c customerOwnedUnit = [SELECT Id FROM Customer_Owned_Unit__c LIMIT 1];
    	String unitDetail = AppointmentCtrl.getUnitById(BPUtility.getEncodedString(customerOwnedUnit.Id));
    	CustomerOwnedUnit customerOwnedUnitJson = (CustomerOwnedUnit)Json.deserialize(BPUtility.getDecodedString(unitDetail), CustomerOwnedUnit.class);
    	system.assertEquals('Test Unit Make', customerOwnedUnitJson.MakeName);
    	Test.stopTest();
    }
    
    @isTest
    private static void testDeleteAppointmentById(){
    	Test.startTest();
    	Event eventRec = [SELECT Id FROM Event LIMIT 1];
    	String deleteAppointmentRec = AppointmentCtrl.deleteAppointmentById(BPUtility.getEncodedString(eventRec.Id));
    	system.assertEquals('SUCCESS', BPUtility.getDecodedString(deleteAppointmentRec));
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetJobTypeList(){
    	Test.startTest();
    	String jobType = AppointmentCtrl.getJobTypeList();
    	List<ServiceOrderWrapper.TTType> serviceOrder = (List<ServiceOrderWrapper.TTType>)Json.deserialize(BPUtility.getDecodedString(jobType), List<ServiceOrderWrapper.TTType>.class);
    	system.assertEquals(serviceOrder.size(), 0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTechnicianListWithAvailableHours(){
    	Test.startTest();
    	Event eventRec = [SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event LIMIT 1];
    	AppointmentWrapper appointmentWrapper = new AppointmentWrapper(eventRec, true);
    	String appointmentDetailJSON = System.JSON.serialize(appointmentWrapper, true);
    	String result = AppointmentCtrl.getTechnicianListWithAvailableHours(BPUtility.getEncodedString(appointmentDetailJSON));
    	List<TechnicianDetailWrapper> technicianDetailWrapper = (List<TechnicianDetailWrapper>)System.Json.deserialize(BPUtility.getDecodedString(result), List<TechnicianDetailWrapper>.class);
    	system.assertEquals(technicianDetailWrapper.size(), 0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTechnicianListWithAvailableHoursWithSortingTechnicianForMorning(){
    	Test.startTest();
    	Technician__c technician = TestdataFactory.createTechnician();
    	Leave__c leave = TestDataFactory.createLeave(technician.Id);
    	Event eventRec = [SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Morning' LIMIT 1];
    	leave.From__c = eventRec.StartDateTime;
    	update leave;
    	AppointmentWrapper appointmentWrapper = new AppointmentWrapper(eventRec, true);
    	String appointmentDetailJSON = System.JSON.serialize(appointmentWrapper, true);
    	String result = AppointmentCtrl.getTechnicianListWithAvailableHours(BPUtility.getEncodedString(appointmentDetailJSON));
    	List<TechnicianDetailWrapper> technicianDetailWrapper = (List<TechnicianDetailWrapper>)System.Json.deserialize(BPUtility.getDecodedString(result), List<TechnicianDetailWrapper>.class);
    	system.assertEquals(technicianDetailWrapper.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTechnicianListWithAvailableHoursWithSortingTechnicianForAfternoon(){
    	Test.startTest();
    	Technician__c technician = TestdataFactory.createTechnician();
    	Leave__c leave = TestDataFactory.createLeave(technician.Id);
    	Event eventRec = [SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Afternoon' LIMIT 1];
    	leave.From__c = eventRec.StartDateTime;
    	update leave;
    	AppointmentWrapper appointmentWrapper = new AppointmentWrapper(eventRec, true);
    	String appointmentDetailJSON = System.JSON.serialize(appointmentWrapper, true);
    	String result = AppointmentCtrl.getTechnicianListWithAvailableHours(BPUtility.getEncodedString(appointmentDetailJSON));
    	List<TechnicianDetailWrapper> technicianDetailWrapper = (List<TechnicianDetailWrapper>)System.Json.deserialize(BPUtility.getDecodedString(result), List<TechnicianDetailWrapper>.class);
    	system.assertEquals(technicianDetailWrapper.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testUpdateRelatedSORecord(){
    	Test.startTest();
    	system.assertEquals('', AppointmentCtrl.updateRelatedSORecord('Id'));
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetTimeSlotAndStateForTechnician(){
    	Test.startTest();
    	DateTime dt = System.today();
		Time timeSlot = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
		AppointmentService appointmentService = new AppointmentService();
		appointmentService.TimeSlotWrapper timeSlotWrapper = new appointmentService.TimeSlotWrapper(timeSlot, 'Available');
		timeSlotWrapper.AppointmentDay = 'Monday';
		timeSlotWrapper.AppointmentDate = '07/09/2018';
		timeSlotWrapper.EstimatedHours = 3;
		String result = AppointmentCtrl.getTimeSlotAndStateForTechnician(BPUtility.getEncodedString(Json.serialize(timeSlotWrapper, true)));
		List<appointmentService.TimeSlotWrapper> timeSlotWrapperResult = new List<appointmentService.TimeSlotWrapper>((List<appointmentService.TimeSlotWrapper>)system.Json.deserialize((BPUtility.getDecodedString(result)), List<appointmentService.TimeSlotWrapper>.class));
		system.assertEquals(timeSlotWrapperResult.size(), 37);
		Test.stopTest();
    }
    
    @isTest
    public static void testPopulateSOKitConcernsOnAppointment(){
    	Test.startTest();
    	Event eventRec = [SELECT Id, Customer__c, Event_Concern__c, Customer_Owned_Unit__c, Estimated_Hours__c, Transaction_Type__r.Code_Label__c, Transaction_Type__c, Transaction_Type__r.Type__c, Subject, Technician__c, Customer__r.Name, Service_Order_Header__c, EndDateTime,Appointment_Concern__c, Customer_Owned_Unit__r.Formatted_Name__c, Appointment_Day_Segment__c, CO_Header__r.Name, StartDateTime FROM Event WHERE Appointment_Day_Segment__c = 'Afternoon' LIMIT 1];
    	AppointmentWrapper appointmentWrapper = new AppointmentWrapper(eventRec, true);
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	AppointmentService.populateSOKitConcernsOnAppointment(appointmentWrapper, soHeader.Id);
    	system.assertEquals(appointmentWrapper.SOKitConcern.size(), 0);
    	Test.stopTest();
    }
}