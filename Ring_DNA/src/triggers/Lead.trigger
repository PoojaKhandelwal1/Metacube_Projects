trigger Lead on Lead (after insert, after update, before insert, before update) {
	//if(!Test.isRunningTest()) {
	 	SObjectDomain.triggerHandler(Leads.class);
	//}
}