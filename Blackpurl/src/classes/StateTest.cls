@isTest
private class StateTest {

    static testMethod void StateTest() {
        Country__c country1 = TestUtil.createCountry(true, 'India', true, true);
        State__c state1 = TestUtil.createState(true, 'Test State 1', country1.Id, true);
        Test.startTest();
        State stateObj = new State(state1);
        Test.stopTest();
        State__c firstState =[Select Id, Name__c, Default__c, Country__c From State__c c where Id= :state1.Id];
        system.assertEquals(firstState.Name__c, 'Test State 1');      
    }
    
     static testMethod void StateConstructorTest() {
        Country__c country1 = TestUtil.createCountry(true, 'India', true, true);
        State__c state1 = TestUtil.createState(true, 'Test State 1', country1.Id, true);
        Timezone__c timezone = new Timezone__c();
        timezone.Country__c = country1.Id;
        timezone.State__c = state1.Id;
        timezone.Timezone_Label__c = 'IST';
        insert timezone;
        Timezone timeZ = new Timezone(timezone);
        Test.startTest();
        State stateObj = new State(state1,timeZ);
        Test.stopTest();
        State__c firstState =[Select Id, Name__c, Default__c, Country__c From State__c c where Id= :state1.Id];
        system.assertEquals(firstState.Name__c, 'Test State 1');      
    }
    
    static testMethod void fieldList() 
    {   
        Country__c country1 = TestUtil.createCountry(true, 'India', true, true);
        State__c state1 = TestUtil.createState(true, 'Test State 1', country1.Id, true);
        Test.startTest();
        List<String> list1 = State.fieldsList();
        Test.stopTest();
       system.assertEquals(list1[0],'Id');
    }
}