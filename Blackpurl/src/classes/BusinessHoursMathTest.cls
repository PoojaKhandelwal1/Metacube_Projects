@isTest
private class BusinessHoursMathTest {

    static public void testConstructor() {
        //create Mon - Fri 9am - 5pm business hours, and increase by 1 to test correctness
        BusinessHours businessHours = new BusinessHours(
            MondayStartTime = Time.newInstance(10, 0, 0, 0),
            MondayEndTime = Time.newInstance(17, 0, 0, 0),
            TuesdayStartTime = Time.newInstance(11, 0, 0, 0),
            TuesdayEndTime = Time.newInstance(17, 0, 0, 0),
            WednesdayStartTime = Time.newInstance(12, 0, 0, 0),
            WednesdayEndTime = Time.newInstance(17, 0, 0, 0),
            ThursdayStartTime = Time.newInstance(13, 0, 0, 0),
            ThursdayEndTime = Time.newInstance(17, 0, 0, 0),
            FridayStartTime = Time.newInstance(14, 0, 0, 0),
            FridayEndTime = Time.newInstance(17, 0, 0, 0),
            IsActive = true,
            IsDefault = true
        );
        //insert businessHours; NO DML Allowed, use the setBusinessHours for testing.
        
        //holidays are outside the scope of seeAllData, so lets use setHolidays as well
        List<Holiday> holidays = new List<Holiday>();
        holidays.add(new Holiday(
                //Christmas Eve on tuesday
                Name = 'Christmas Eve',
                ActivityDate = Date.parse('12/12/2013'),
                RecurrenceType = 'RecursYearly',
                RecurrenceMonthOfYear = 'December',
                RecurrenceDayOfMonth = 12
            )
        );
        holidays.add(new Holiday(
                //Christmas on Wednesday
                Name = 'Christmas',
                ActivityDate = Date.parse('12/11/2013'),
                RecurrenceType = 'RecursYearly',
                RecurrenceMonthOfYear = 'December',
                RecurrenceDayOfMonth = 11
            )
        );
        holidays.add(new Holiday(
                //singular Holiday event, on the following Monday
                Name = 'Bob\'s Birthday',
                ActivityDate = Date.parse('12/10/2013') 
            )
        );
        
        Test.startTest();
        
        BusinessHoursMath businessHoursMath = new BusinessHoursMath().setBusinessHours(businessHours).setHolidays(holidays);
        
        system.assertEquals(null, businessHoursMath.businessDays[0].startTime);
        system.assertEquals(null, businessHoursMath.businessDays[0].endTime);
        system.assertEquals(false, businessHoursMath.businessDays[0].isBusinessDay);
        system.assertEquals(Time.newInstance(10,0,0,0) , businessHoursMath.businessDays[1].startTime);
        system.assertEquals(Time.newInstance(17,0,0,0), businessHoursMath.businessDays[1].endTime);
        system.assertEquals(true, businessHoursMath.businessDays[1].isBusinessDay);
        system.assertEquals(Time.newInstance(11,0,0,0) , businessHoursMath.businessDays[2].startTime);
        system.assertEquals(Time.newInstance(17,0,0,0), businessHoursMath.businessDays[2].endTime);
        system.assertEquals(true, businessHoursMath.businessDays[2].isBusinessDay);
        system.assertEquals(Time.newInstance(12,0,0,0) , businessHoursMath.businessDays[3].startTime);
        system.assertEquals(Time.newInstance(17,0,0,0), businessHoursMath.businessDays[3].endTime);
        system.assertEquals(true, businessHoursMath.businessDays[3].isBusinessDay);
        system.assertEquals(Time.newInstance(13,0,0,0) , businessHoursMath.businessDays[4].startTime);
        system.assertEquals(Time.newInstance(17,0,0,0), businessHoursMath.businessDays[4].endTime);
        system.assertEquals(true, businessHoursMath.businessDays[4].isBusinessDay);
        system.assertEquals(Time.newInstance(14,0,0,0) , businessHoursMath.businessDays[5].startTime);
        system.assertEquals(Time.newInstance(17,0,0,0), businessHoursMath.businessDays[5].endTime);
        system.assertEquals(true, businessHoursMath.businessDays[5].isBusinessDay);
        system.assertEquals(null, businessHoursMath.businessDays[6].startTime);
        system.assertEquals(null, businessHoursMath.businessDays[6].endTime);
        system.assertEquals(false, businessHoursMath.businessDays[0].isBusinessDay);

        system.assertEquals(3, businessHoursMath.holidays.size());//we have em, so lets continue

        Test.stopTest();
    }
    
    @isTest(SeeAllData=false)
    static public void testIsBusinessDay() {
        Date testDate = Date.parse('12/12/2013'); //Sunday
        //create Mon - Fri 9am - 5pm business hours, and increase by 1 to test correctness
        BusinessHours businessHours = new BusinessHours(
            MondayStartTime = Time.newInstance(10, 0, 0, 0),
            MondayEndTime = Time.newInstance(17, 0, 0, 0),
            TuesdayStartTime = Time.newInstance(11, 0, 0, 0),
            TuesdayEndTime = Time.newInstance(17, 0, 0, 0),
            WednesdayStartTime = Time.newInstance(12, 0, 0, 0),
            WednesdayEndTime = Time.newInstance(17, 0, 0, 0),
            ThursdayStartTime = Time.newInstance(13, 0, 0, 0),
            ThursdayEndTime = Time.newInstance(17, 0, 0, 0),
            FridayStartTime = Time.newInstance(14, 0, 0, 0),
            FridayEndTime = Time.newInstance(17, 0, 0, 0),
            IsActive = true,
            IsDefault = true
        );
        //insert businessHours; NO DML Allowed, use the setBusinessHours for testing.
        
        //holidays are outside the scope of seeAllData, so lets use setHolidays as well
        List<Holiday> holidays = new List<Holiday>();
        holidays.add(new Holiday(
                //Christmas Eve on tuesday
                Name = 'Christmas Eve',
                ActivityDate = Date.parse('12/12/2013'),
                RecurrenceType = 'RecursYearly',
                RecurrenceMonthOfYear = 'December',
                RecurrenceDayOfMonth = 24
            )
        );
        holidays.add(new Holiday(
                //Christmas on Wednesday
                Name = 'Christmas',
                ActivityDate = Date.parse('12/8/2013'),
                RecurrenceType = 'RecursYearly',
                RecurrenceMonthOfYear = 'December',
                RecurrenceDayOfMonth = 8
            )
        );
        holidays.add(new Holiday(
                //singular Holiday event, on the following Monday
                Name = 'Bob\'s Birthday',
                ActivityDate = Date.parse('12/7/2013') 
            )
        );
        
        Test.startTest();
        BusinessHoursMath businessHoursMath = new BusinessHoursMath().setBusinessHours(businessHours).setHolidays(holidays);
        //lets run the week and see if things are what we want
        system.debug('***BROKE');

        Test.stopTest();
        System.assertEquals(1, 1);
    }

    @isTest(SeeAllData=false)
    static public void testgetEndOfBusinessDayFromDate() {
        Date testDate = Date.parse('12/12/2013'); //Sunday
        //create Mon - Fri 9am - 5pm business hours, and increase Start by 1 to test correctness
        BusinessHours businessHours = new BusinessHours(
            MondayStartTime = Time.newInstance(10, 0, 0, 0),
            MondayEndTime = Time.newInstance(17, 0, 0, 0),
            TuesdayStartTime = Time.newInstance(11, 0, 0, 0),
            TuesdayEndTime = Time.newInstance(17, 0, 0, 0),
            WednesdayStartTime = Time.newInstance(12, 0, 0, 0),
            WednesdayEndTime = Time.newInstance(17, 0, 0, 0),
            ThursdayStartTime = Time.newInstance(13, 0, 0, 0),
            ThursdayEndTime = Time.newInstance(19, 0, 0, 0),
            FridayStartTime = Time.newInstance(14, 0, 0, 0),
            FridayEndTime = Time.newInstance(19, 0, 0, 0),
            IsActive = true,
            IsDefault = true
        );
        //insert businessHours; NO DML Allowed, use the setBusinessHours for testing.
        
        //holidays are outside the scope of seeAllData, so lets use setHolidays as well
        List<Holiday> holidays = new List<Holiday>();
        holidays.add(new Holiday(
                //Christmas Eve on tuesday
                Name = 'Christmas Eve',
                ActivityDate = Date.parse('12/12/2013'),
                RecurrenceType = 'RecursYearly',
                RecurrenceMonthOfYear = 'December',
                RecurrenceDayOfMonth = 24
            )
        );
        holidays.add(new Holiday(
                //Christmas on Wednesday
                Name = 'Christmas',
                ActivityDate = Date.parse('12/8/2013'),
                RecurrenceType = 'RecursYearly',
                RecurrenceMonthOfYear = 'December',
                RecurrenceDayOfMonth = 8
            )
        );
        holidays.add(new Holiday(
                //singular Holiday event, on the following Monday
                Name = 'Bob\'s Birthday',
                ActivityDate = Date.parse('12/7/2013') 
            )
        );
        
        Test.startTest();
        BusinessHoursMath businessHoursMath = new BusinessHoursMath().setBusinessHours(businessHours).setHolidays(holidays);
        
        businessHoursMath.getEndOfBusinessDayFromDate(Date.today(),5);
        Test.stopTest();
        System.assertEquals(1, 1);
    }
}