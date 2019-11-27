global class EmailSchedule implements Schedulable {
	global void execute(SchedulableContext SC) {
   		 
	    List<EmailTemplate> templateList = [Select Id from EmailTemplate where name = 'BP Welcome Email Template'];
	    if(templateList.size() > 0){
			List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setTemplateID(templateList[0].Id); 
			mail.setTargetObjectId(UserInfo.getUserId());
			mail.setSaveAsActivity(false);
			allmsg.add(mail);
			Messaging.sendEmail(allmsg,false);
	    }
   }

}