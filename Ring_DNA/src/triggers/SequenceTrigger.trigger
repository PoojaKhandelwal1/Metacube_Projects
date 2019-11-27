trigger SequenceTrigger on Cadence__c (after update) {
	SObjectDomain.triggerHandler(Sequences.class);
}