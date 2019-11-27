@isTest
private class JobSchedulingCtrlTest {
	@testsetup
	private static void setup(){
		Account customerRec = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
		Customer_Owned_Unit__c unitRec = TestDataFactory.createCustomerOwnedUnit(customerRec.Id, 'VIN001');
		Event eventRec = TestDataFactory.createEventForAfternoon(customerRec.Id, unitRec.Id);
		CO_Header__c coHeaderRec = TestDataFactory.createCoHeader(customerRec.Id);
	}   
	
	@isTest
	private static void testLoadJobSchedulingEvents(){
		Test.startTest();
		Event event = [SELECT Id, Title__c, Notes__c, AdditionalNotes__c, Subject, Type, WhatId, IsMultiDayEvent__c, StartDateTime, EndDateTime FROM Event LIMIT 1];
		Datetime startDateTime = Datetime.newInstance(2019, 3, 10, 05, 30, 0);
		Datetime endDateTime = Datetime.newInstance(2019, 3, 12, 05, 30, 0);
		event.StartDateTime = startDateTime;
		event.EndDateTime = endDateTime;
		update event;
		JobSchedulingWrapper jobSchedulingWrapper = new JobSchedulingWrapper(event, startDateTime, endDateTime);
		system.assertEquals(JobSchedulingCtrl.loadJobSchedulingEvents(), BPUtility.getEncodedString(''));
		Test.stopTest();
	}
	
	@isTest
	private static void testSOWrappper(){
		Test.startTest();
		CO_Header__c coHeaderRec = [SELECT Id FROM CO_Header__c LIMIT 1];
		Service_Order_Header__c soHeader = TestDataFactory.createSOheader(coHeaderRec.Id);
		JobSchedulingWrapper.SOWrapper soWrapper = new JobSchedulingWrapper.SOWrapper(soHeader);
		system.assertEquals(soWrapper.SectionName, soHeader.Name__c);
		Test.stopTest();
	}
	
	@isTest
	private static void testLoadSchedulingEvents(){
		Test.startTest();
		Event event = [SELECT Id, Title__c, Notes__c, AdditionalNotes__c, Subject, Type, WhatId, IsMultiDayEvent__c, StartDateTime, EndDateTime FROM Event LIMIT 1];
		JobSchedulingWrapper jobSchedulingWrapper = new JobSchedulingWrapper(event);
		String eventJson = json.serialize(jobSchedulingWrapper);
		eventJson = BPUtility.getEncodedString(eventJson);
		String result = BPUtility.getDecodedString(JobSchedulingCtrl.loadSchedulingEvents(eventJson));
		List<JobSchedulingWrapper> allEventList = (List<JobSchedulingWrapper>)json.deserialize(result, List<JobSchedulingWrapper>.class);
		system.assertEquals('Test Event', allEventList[0].Subject);
		Test.stopTest();
	}
	
	@isTest
	private static void testLoadSchedulingEventsForCurrentViewMonth(){
		Test.startTest();
		Event event = [SELECT Id, Title__c, Notes__c, AdditionalNotes__c, Subject, Type, WhatId, IsMultiDayEvent__c, StartDateTime, EndDateTime FROM Event LIMIT 1];
		event.Type = 'Appointment';
		event.IsMultiDayEvent__c = true;
		update event;
		JobSchedulingWrapper jobSchedulingWrapper = new JobSchedulingWrapper(event);
		jobSchedulingWrapper.CurrentView = 'Month';
		jobSchedulingWrapper.Id = null;
		jobSchedulingWrapper.ReminderFilter = true;
		jobSchedulingWrapper.AppointmentFilter = true;
		jobSchedulingWrapper.AppointmentwithserviceFilter = true;
		String eventJson = json.serialize(jobSchedulingWrapper);
		eventJson = BPUtility.getEncodedString(eventJson);
		String result = BPUtility.getDecodedString(JobSchedulingCtrl.loadSchedulingEvents(eventJson));
		List<List<JobSchedulingWrapper>> allEventList = (List<List<JobSchedulingWrapper>>)json.deserialize(result, List<List<JobSchedulingWrapper>>.class);
		system.assertEquals(2, allEventList.size());
		Test.stopTest();
	}
	
	@isTest
	private static void testLoadSchedulingEventsWithStartDateNotNull(){
		Test.startTest();
		Event event = [SELECT Id, Title__c, Notes__c, AdditionalNotes__c, Subject, Type, WhatId, IsMultiDayEvent__c, StartDateTime, EndDateTime FROM Event LIMIT 1];
		JobSchedulingWrapper jobSchedulingWrapper = new JobSchedulingWrapper(event);
		jobSchedulingWrapper.StartCalendarViewDate = '03/03/2019';
		jobSchedulingWrapper.StartCalendarViewTime = '02:00AM';
		jobSchedulingWrapper.EndCalendarViewDate = '03/03/2019';
		jobSchedulingWrapper.EndCalendarViewTime = '03:00AM';
		String eventJson = json.serialize(jobSchedulingWrapper);
		eventJson = BPUtility.getEncodedString(eventJson);
		String result = BPUtility.getDecodedString(JobSchedulingCtrl.loadSchedulingEvents(eventJson));
		List<JobSchedulingWrapper> allEventList = (List<JobSchedulingWrapper>)json.deserialize(result, List<JobSchedulingWrapper>.class);
		system.assertEquals('Test Event', allEventList[0].Subject);
		Test.stopTest();
	}
	
	@isTest
	private static void testLoadSchedulingEventsWithEventIdNull(){
		Test.startTest();
		Event event = [SELECT Id, Title__c, Notes__c, AdditionalNotes__c, Subject, Type, WhatId, IsMultiDayEvent__c, StartDateTime, EndDateTime FROM Event LIMIT 1];
		JobSchedulingWrapper jobSchedulingWrapper = new JobSchedulingWrapper(event);
		jobSchedulingWrapper.Id = null;
		jobSchedulingWrapper.ReminderFilter = true;
		jobSchedulingWrapper.AppointmentFilter = true;
		jobSchedulingWrapper.AppointmentwithserviceFilter = true;
		String eventJson = json.serialize(jobSchedulingWrapper);
		eventJson = BPUtility.getEncodedString(eventJson);
		String result = BPUtility.getDecodedString(JobSchedulingCtrl.loadSchedulingEvents(eventJson));
		List<List<JobSchedulingWrapper>> allEventList = (List<List<JobSchedulingWrapper>>)json.deserialize(result, List<List<JobSchedulingWrapper>>.class);
		system.assertEquals(2, allEventList.size());
		Test.stopTest();
	}
	
	@isTest
	private static void testSaveJobSchedulingEvent(){
		Test.startTest();
		Event event = [SELECT Id, Title__c, Notes__c, AdditionalNotes__c, Subject, Type, WhatId, IsMultiDayEvent__c, StartDateTime, EndDateTime FROM Event LIMIT 1];
		JobSchedulingWrapper jobSchedulingWrapper = new JobSchedulingWrapper(event);
		String eventJson = json.serialize(jobSchedulingWrapper);
		eventJson = BPUtility.getEncodedString(eventJson);
		String result = BPUtility.getDecodedString(JobSchedulingCtrl.saveJobSchedulingEvent(eventJson));
		List<JobSchedulingWrapper> allEventList = (List<JobSchedulingWrapper>)json.deserialize(result, List<JobSchedulingWrapper>.class);
		system.assertEquals('Meeting', allEventList[0].Subject);
		Test.stopTest();
	}
	
	@isTest
	private static void testDeleteJobSchedulingEvent(){
		Test.startTest();
		Event event = [SELECT Id, Title__c, Notes__c, AdditionalNotes__c, Subject, Type, WhatId, IsMultiDayEvent__c, StartDateTime, EndDateTime FROM Event LIMIT 1];
		JobSchedulingWrapper jobSchedulingWrapper = new JobSchedulingWrapper(event);
		String eventJson = json.serialize(jobSchedulingWrapper);
		eventJson = BPUtility.getEncodedString(eventJson);
		String result = BPUtility.getDecodedString(JobSchedulingCtrl.deleteJobSchedulingEvent(BPUtility.getEncodedString(event.Id),eventJson));
		List<JobSchedulingWrapper> allEventList = (List<JobSchedulingWrapper>)json.deserialize(result, List<JobSchedulingWrapper>.class);
		system.assertEquals(0, allEventList.size());
		
		Test.stopTest();
	}
	
	@isTest
	private static void testAddServiceJobForJobScheduling(){
		Test.startTest();
		CO_Header__c coHeaderRec = [SELECT Id FROM CO_Header__c LIMIT 1];
		Event event = [SELECT Id, Title__c, Notes__c, AdditionalNotes__c, Subject, Type, WhatId, IsMultiDayEvent__c, StartDateTime, EndDateTime FROM Event LIMIT 1];
		JobSchedulingWrapper jobSchedulingWrapper = new JobSchedulingWrapper(event);
		jobSchedulingWrapper.COHeaderId = coHeaderRec.Id;
		String eventJson = json.serialize(jobSchedulingWrapper);
		eventJson = BPUtility.getEncodedString(eventJson);
		JobSchedulingCtrl.addServiceJobForJobScheduling(eventJSON);
		Event eventRec = [SELECT WhatId FROM Event LIMIT 1];
		system.assertEquals(eventRec.WhatId, jobSchedulingWrapper.COHeaderId);
		Test.stopTest();
	}
	
	@isTest
	private static void testGetServiceJobDetailsForForJobScheduling(){
		Test.startTest();
		CO_Header__c coHeaderRec = [SELECT Id FROM CO_Header__c LIMIT 1];
		String resultJSON = BPUTility.getDecodedString(JobSchedulingCtrl.getServiceJobDetailsForForJobScheduling(BPUtility.getEncodedString(coHeaderRec.Id)));
		JobSchedulingWrapper.COHeaderWrapper result = (JobSchedulingWrapper.COHeaderWrapper)json.deserialize(resultJSON, JobSchedulingWrapper.COHeaderWrapper.class);
		system.assertEquals('Test001', result.CustomerName);
		Test.stopTest();
	}
}