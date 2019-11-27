trigger Contact on Contact (after insert, after update, before insert, before update) {
	//if(!Test.isRunningTest()) {
		SObjectDomain.triggerHandler(Contacts.class);
	//}
}