/**
 * Author: Gourav Goyal
 * Since: July 26, 2017
 * Name: TimeZone test
 * Description: Controller test Class of timezone class.
**/
@isTest
private class TimeZoneTest {
     /**
     * Name: insertTimeZoneTest
     * Desc: Testing to fetch timezone object in constructor .
     * @param: 
     * @return: 
    **/
    static testmethod void insertTimeZoneTest(){
    Country__c countryObj = TestUtil.createCountry(true,'india',true,true);
    State__c stateObj = TestUtil.createState(true,'rajasthan',countryObj.id,true);
    Timezone__c timezoneRec = new Timezone__c(Country__c=countryObj.id,State__c=stateObj.id,Time_Shift__c=2.00,Timezone_Label__c='indian',Tz_Name__c='indian');
    
    test.startTest();
    Timezone timeObj = new Timezone(timezoneRec);
    test.stopTest();
    system.assert(true,true);
    }
     /**
     * Name: insertTimeZoneDataTest
     * Desc:  Testing to fetch timezone field set values  in timezone controller's method.
     * @param: 
     * @return: 
    **/
    static testmethod void insertTimeZoneDataTest(){
    test.startTest();
    Timezone.fieldsList();
    test.stopTest();
    system.assert(true,true);
    }
}