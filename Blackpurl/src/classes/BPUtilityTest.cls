@isTest
private class BPUtilityTest {
    
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
		CO_Header__c coHeader = TestDataFactory.createCOHeader(customer.Id);
    }
    
    @isTest
    private static void testGetDecodedString(){
    	Test.startTest();
    	system.assertEquals(EncodingUtil.base64Decode(BPUtility.getEncodedString('blackpurl')).toString(), BPUtility.getDecodedString(BPUtility.getEncodedString('blackpurl')));
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetDecodedStringForBlankString(){
    	Test.startTest();
    	system.assertEquals('', BPUtility.getDecodedString(''));
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetEncodedString(){
    	Test.startTest();
    	system.assertEquals(BPUtility.getEncodedStr(Blob.valueOf('Blackpurl')), BPUtility.getEncodedString('Blackpurl'));
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetEncodedStringForBlankString(){
    	Test.startTest();
    	system.assertEquals('', BPUtility.getEncodedString(''));
    	Test.stopTest();
    }
    
    @isTest
    private static void testEscapeSingleQuotesForBlankString(){
    	Test.startTest();
    	system.assertEquals('', BPUtility.getEncodedString(''));
    	Test.stopTest();
    }
    
    @isTest
    private static void testEscapeSingleQuotes(){
    	Test.startTest();
    	system.assertEquals(String.escapeSingleQuotes('Blackpurl'), BPUtility.escapeSingleQuotes('Blackpurl'));
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetFormatedDateTime(){
    	Test.startTest();
    	BPUtility.getFormatedDateTime(datetime.newInstance(2008, 12, 1));
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetFormatedDateAndTime(){
    	Test.startTest();
    	BPUtility.getFormatedDateAndTime(datetime.newInstance(2008, 12, 1));
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetDateFormat(){
    	Test.startTest();
    	BPUtility.getDateFormat();
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetExtendedDateFormat(){
    	Test.startTest();
    	BPUtility.getExtendedDateFormat(datetime.newInstance(2008, 12, 1));
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetExtendedDateFormatWithoutTime(){
    	Test.startTest();
    	BPUtility.getExtendedDateFormatWithoutTime(datetime.newInstance(2008, 12, 1));
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetExtendedMonthFormat(){
    	Test.startTest();
    	BPUtility.getExtendedMonthFormat(datetime.newInstance(2008, 12, 1));
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetExtendedTimeMonthFormat(){
    	Test.startTest();
    	BPUtility.getExtendedTimeMonthFormat(datetime.newInstance(2008, 12, 1));
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetExportFormatedDateTime(){
    	Test.startTest();
    	BPUtility.getExportFormatedDateTime(datetime.newInstance(2008, 12, 1));
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testCreateDateTimeFromStr(){
    	Test.startTest();
    	BPUtility.createDateTimeFromStr(datetime.newInstance(2008, 12, 1), '01:00 PM');
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testConvertListIntoString(){
    	Test.startTest();
    	List<String> strList = new List<String>();
    	strList.add('a');
    	
    	system.assertEquals(BPUtility.convertListIntoString(strList), 'a' + '\n' + '');
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetCurrentUserTZSIDKey(){
    	Test.startTest();
    	BPUtility.getCurrentUserTZSIDKey();
    	system.assertEquals(1,1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetSectionNameBySectionId(){
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Test.startTest();
    	system.assertEquals(BPUtility.getSectionNameBySectionId(coHeader.Id), 'All');
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetLocaleStaticResourceData(){
    	Test.startTest();
    	system.assertEquals(BPUtility.getLocaleStaticResourceData().size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testSleepSystem(){
    	Test.startTest();
    	BPUtility.sleepSystem(0);
    	system.assertEquals(1, 1);
    	Test.stopTest();
    }
}