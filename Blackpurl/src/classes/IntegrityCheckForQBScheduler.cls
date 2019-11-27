/**
 * Author: Rajat Jain
 * Since: May 30, 2018
 * Name: IntegrityCheckForQBScheduler
 * Description: Scheduler class for IntegrityCheckForQBScheduler
**/ 
global with sharing class IntegrityCheckForQBScheduler implements Schedulable {
	
    global void execute(SchedulableContext sc) {
    	new IntegrityCheckForQBCtrl().sendIntegrityCheckMailToSupportTeam();
    }
    
    global void executeEmailScheduler() {
	    String CRON_EXP = '0 0 0 * * ? *';
	    system.schedule('Integrity Check For QB', CRON_EXP, new IntegrityCheckForQBScheduler() );
    }
}