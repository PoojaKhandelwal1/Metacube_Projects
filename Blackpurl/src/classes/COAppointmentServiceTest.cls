@isTest
private class COAppointmentServiceTest {
    
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test First Name', 'Test Last Name');
    	CO_Header__c coHeader = TestDataFactory.createCoHeader(customer.Id);
    	Unit_Make__c unitMake = TestDataFactory.createUnitMake('Test Unit Make', 'Tes', true);
    	Unit_Model__c unitModel = TestDataFactory.createUnitModel('Test Unit Model', 'Tes', true, unitMake.Id);
    	Unit_Sub_Model__c unitSubModel = TestDataFactory.createSubModel(unitModel);
    	Customer_Owned_Unit__c customerOwnedUnit = TestDataFactory.createCustomerOwnedUnit(customer.Id, unitMake.Id, unitModel.Id, unitSubModel.Id, 'VIN001');
    	Service_Order_Header__c soHeader = TestDataFactory.createSOHeader(coHeader.Id);
    	
    	List<Event> eventList = new List<Event>();
    	for(Integer i = 0; i < 20; i++) {
    		eventList.add(TestDataFactory.sampleEventWithServiceHeader(customer.Id, customerOwnedUnit.Id, soHeader.Id));
    	}
    	insert eventList;
    	Notes__c notes = TestDataFactory.createNotes();
    }
    
    @isTest
    private static void testGetAppointmentsBySectionId(){
    	Test.startTest();
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	Map<Id, AppointmentWrapper> result = new Map<Id, AppointmentWrapper>(COAppointmentService.getAppointmentsBySectionId(soHeader.Id));
    	system.assertEquals(1, result.size());
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetNewAppointmentMap(){
    	Test.startTest();
    	Account customer = [SELECT Id FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	Map<Id, AppointmentWrapper> result = new Map<Id, AppointmentWrapper>(COAppointmentService.getAppointmentsBySectionId(customer.Id));
    	system.assertEquals(0, result.size());
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetAppointmentsBySectionIdForAllSection(){
    	Test.startTest();
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Map<Id, AppointmentWrapper> result = new Map<Id, AppointmentWrapper>(COAppointmentService.getAppointmentsBySectionId(coHeader.Id));
    	system.assertEquals(1, result.size());
    	Test.stopTest();
    }
    
    @isTest
    private static void testUpdateAppointmentsBySectionId(){
    	Test.startTest();
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	COAppointmentService.updateAppointmentsBySectionId(soHeader.Id);
    	Event event = [SELECT Id, Customer__c, CO_Header__r.Customer__c FROM Event WHERE Service_Order_Header__c =: soHeader.Id LIMIT 1];
    	system.assertEquals(event.Customer__c, event.CO_Header__r.Customer__c);
    	Test.stopTest();
    }
    
    @isTest
    private static void testUpdateAppointmentWithSOHeaderConcern(){
    	Test.startTest();
    	Service_Order_Header__c soHeader = [SELECT Id, SO_Concern__c FROM Service_Order_Header__c LIMIT 1];
    	Event event = [SELECT Id, Event_Concern__c, Service_Order_Header__c FROM Event LIMIT 1];
    	Notes__c notes = [SELECT Id FROM Notes__c LIMIT 1];
    	event.Event_Concern__c = notes.Id;
    	update event;
    	String soHeaderConcern = '';
    	for(Integer i = 0; i < 300; i++){
    		soHeaderConcern = soHeaderConcern + 'a';
    	}
    	soHeader.SO_Concern__c = soHeaderConcern;
    	update soHeader;
    	COAppointmentService.updateAppointmentsBySectionId(soHeader.Id);
    	Event updatedEvent = [SELECT Id, Customer__c, CO_Header__r.Customer__c FROM Event WHERE Service_Order_Header__c =: soHeader.Id LIMIT 1];
    	system.assertEquals(updatedEvent.Customer__c, updatedEvent.CO_Header__r.Customer__c);
    	Test.stopTest();
    }
    
    @isTest
    private static void testUpdateAppointmentWithEventConcern(){
    	Test.startTest();
    	Service_Order_Header__c soHeader = [SELECT Id, SO_Concern__c FROM Service_Order_Header__c LIMIT 1];
    	Event event = [SELECT Id, Event_Concern__c, Service_Order_Header__c FROM Event LIMIT 1];
    	Notes__c notes = [SELECT Id FROM Notes__c LIMIT 1];
    	event.Event_Concern__c = notes.Id;
    	update event;
    	COAppointmentService.updateAppointmentsBySectionId(soHeader.Id);
    	Event updatedEvent = [SELECT Id, Customer__c, CO_Header__r.Customer__c FROM Event WHERE Service_Order_Header__c =: soHeader.Id LIMIT 1];
    	system.assertEquals(updatedEvent.Customer__c, updatedEvent.CO_Header__r.Customer__c);
    	Test.stopTest();
    }
    
    @isTest
    private static void testUpdateForBlankSectionName(){
    	Test.startTest();
    	Account customer = [SELECT FirstName__c, Name FROM Account WHERE Is_Customer__c = true LIMIT 1];
    	COAppointmentService.updateAppointmentsBySectionId(customer.Id);
    	system.assertEquals(customer.FirstName__c, 'Test First Name');
    	Test.stopTest();
    }
}