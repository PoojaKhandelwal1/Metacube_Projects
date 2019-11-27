@isTest
private class EmailScheduleTest {

    static testMethod void emailScheduleTest() {
        EmailTemplate et = new EmailTemplate();  
        et.isActive = true;  
        et.Name = 'BP Welcome Email Template';  
        et.DeveloperName = 'testTemplate' + System.now().getTime();  
        et.TemplateType = 'text';  
        et.FolderId = UserInfo.getUserId();  
        et.Body = ''; 
        insert et;
        
        EmailSchedule emlScheduler = new EmailSchedule();
        Test.startTest();
        DateTime d = System.now().addMinutes(2);
        String sch = String.valueOf(d.second())+' '+String.valueOf(d.minute())+' '+ String.valueOf(d.hour())+' '+ String.valueOf(d.day())+' '+ String.valueOf(d.month())+' ? '+ String.valueOf(d.year());
        system.debug('sch ' + sch);
        String jobID = system.schedule('Email Notification' , sch, emlScheduler); 
        Test.stopTest();
        System.assertNotEquals(null,jobID );
    }
}