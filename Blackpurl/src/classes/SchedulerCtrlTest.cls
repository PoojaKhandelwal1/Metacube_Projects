@isTest
private class SchedulerCtrlTest {
    
    @testSetup
    private static void setupTestData() {
        Account testCustomer = TestUtil.createCustomer(false, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123');
        testCustomer.Is_Customer__c = true;
        insert testCustomer;
        
        List<Shop_Settings__c> shopSettingList = new List<Shop_Settings__c>();
        shopSettingList.add(insertShopSettingRecords('1', 1, 'Monday', true));
        shopSettingList.add(insertShopSettingRecords('2', 2, 'Tuesday', true));
        shopSettingList.add(insertShopSettingRecords('3', 3, 'Wednesday', true));
        shopSettingList.add(insertShopSettingRecords('4', 4, 'Thursday', true));
        shopSettingList.add(insertShopSettingRecords('5', 5, 'Friday', true));
        shopSettingList.add(insertShopSettingRecords('6', 6, 'Saturday', true));
        shopSettingList.add(insertShopSettingRecords('7', 7, 'Sunday', true));
        insert shopSettingList;
        
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, testCustomer.Id, UnitMake.Id, UnitModel.Id, null);
        
        Technician__c techRec = new Technician__c(First_Name__c = 'Test', Last_Name__c = 'Name');
        techRec.Technician_Name__c = 'Test Name';
        techRec.Type__c = 'Technician';
        techRec.Active__c = true;
        techRec.Working_Days__c = 'Monday; Tuesday; Wednesday; Thursday; Friday';
        insert techRec;
        
        Leave__c leaveRec = new Leave__c(Name = 'Annual Leave', Technician__c = techRec.Id);
        leaveRec.From__c = datetime.newInstance(2018, 7, 9, 13, 30, 0);
        leaveRec.To__c = datetime.newInstance(2018, 7, 9, 14, 30, 0);
        insert leaveRec;
        
        Event eventRec = new Event();
        eventRec.Subject = 'Test Event';
        eventRec.Customer__c = testCustomer.Id;
        eventRec.Customer_Owned_Unit__c = customerOwnedUnit.Id;
        eventRec.StartDateTime = datetime.newInstance(2018, 7, 9, 8, 0, 0);
        eventRec.Estimated_Hours__c = 2;
        eventRec.DurationInMinutes = 120;
        eventRec.Description = 'Test Description'; 
        insert eventRec;
        
        Event eventRec1 = new Event();
        eventRec1.Subject = 'Test Event';
        eventRec1.Customer__c = testCustomer.Id;
        eventRec1.Customer_Owned_Unit__c = customerOwnedUnit.Id;
        eventRec1.StartDateTime = datetime.newInstance(2018, 7, 9, 10, 0, 0);
        eventRec1.Estimated_Hours__c = 1.5;
        eventRec1.DurationInMinutes = 90;
        eventRec1.Technician__c = techRec.Id;
        eventRec1.Description = 'Test Description'; 
        insert eventRec1;
        system.assert(true,true);
        
    }
    
    private static Shop_Settings__c insertShopSettingRecords(String name, Integer orderNumber, String day, Boolean isWorking) {
        Shop_Settings__c shopSettingRec = new Shop_Settings__c();
        shopSettingRec.Name = name;
        shopSettingRec.Day__c = day;
        shopSettingRec.Is_Working__c = isWorking;
        shopSettingRec.From_Time__c = '8:00AM';
        shopSettingRec.To_Time__c = '5:00PM';
        return shopSettingRec;
    }
    
    static testMethod void technicianDataTest() {
        Technician__c techRec = [Select Id from Technician__c];
        
        Test.startTest();
        SchedulerCtrl sch = new SchedulerCtrl(new NewHomePageCtrl());
        SchedulerCtrl sch1 = new SchedulerCtrl();
        SchedulerCtrl.getShopSettingData();
        SchedulerCtrl.getAppointmentSchedulerDataForDateRange(BPUtility.getEncodedString('07/09/2018'), BPUtility.getEncodedString('07/16/2018'));
        SchedulerCtrl.getTechnicianListForSpecificDay(BPUtility.getEncodedString('07/09/2018'));
        String unassignedAppointentStr = SchedulerCtrl.getUnassignedAppointmentForSpecificDay(BPUtility.getEncodedString('07/09/2018'));
        SchedulerCtrl.getAssignedAppointmentForSpecificDay(BPUtility.getEncodedString('07/09/2018'));
        
        unassignedAppointentStr = BPUtility.getDecodedString(unassignedAppointentStr);
        List<AppointmentWrapper> appObjList = (List<AppointmentWrapper>) system.JSON.deserialize(unassignedAppointentStr, List<AppointmentWrapper>.class);
        SchedulerCtrl.updateAppointment(BPUtility.getEncodedString(unassignedAppointentStr));
        
        system.assertEquals(2, [Select Id from Event].size());
        Test.stopTest();
    }
}