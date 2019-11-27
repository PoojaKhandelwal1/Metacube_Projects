trigger Task on Task (before insert, after insert, before update, after update) {
	
    SObjectDomain.triggerHandler(Tasks.class);
}