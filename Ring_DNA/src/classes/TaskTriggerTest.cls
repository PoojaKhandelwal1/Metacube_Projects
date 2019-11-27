@isTest
public with sharing class TaskTriggerTest {

	@isTest
	static void createTaskCall() {
		Task t = new Task();
		t.Subject = 'Test';
		t.TaskSubtype = CadenceConstants.ACTION_TYPE_CALL;
		insert t;
		TaskService.isCallTypeTask(t);
		TaskService.isSmsTypeTask(t);
		TaskService.isEmailTypeTask(t);
		TaskService.isTaskType(t);
		TaskService.getTaskType(t);
	} 
}