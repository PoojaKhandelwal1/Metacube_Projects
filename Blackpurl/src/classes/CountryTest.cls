@isTest
private class CountryTest {
    
    /**
     * Name: CountryInsert
     * Desc: Test the new country record insert.
     * @param: 
     * @return: 
    **/
    static testMethod void Country() {   
        Country__c test1 = TestUtil.createCountry(true, 'India', true, true);
        State__c state = TestUtil.createState(true, 'Test State 1', test1.Id, true);
        Timezone__c timezone = new Timezone__c();
        timezone.Country__c = test1.Id;
        timezone.State__c = state.Id;
        timezone.Timezone_Label__c = 'IST';
        insert timezone;
        List<Country__C> countryList =[select Name__c,Default__c,Id,( select id,Default__c,Country__c, Name__c from states__r ),( select id,State__c,Timezone_Label__c,Tz_Name__c,Country__c,Time_Shift__c from Timezones__r ) from country__c];
        Test.startTest();
        country country1 = new country(countryList[0]);
        Test.stopTest();
        
        Country__c firstCountry=[Select Id, Name__c, Default__c, Visible__c From Country__c c where Id= :test1.Id];
       system.assertEquals(firstCountry.Name__c, 'India');
    }
     
    static testMethod void fieldList() {   
        Country__c test1 = TestUtil.createCountry(true, 'India', true, true);
        Test.startTest();
        List<String> list1 = country.fieldsList();
        Test.stopTest();
        //Country__c firstCountry=[Select Id, Name__c, Default__c, Visible__c From Country__c c where Id= :test1.Id];
       system.assertEquals(list1[0],'Id');
    }
    
    static testMethod void CountryCreate() {
        Country__c Country1 = TestUtil.createCountry(true, 'Canada', true, true);
        Country__c firstCountry=[Select Name__c, Id From Country__c c where Id= :Country1.Id];
        system.assertEquals(firstCountry.Name__c, 'Canada');
    }
}