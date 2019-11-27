global class CadenceScheduler implements schedulable {
	// Next schedule time must be in minutes
	public static Integer nextScheduleTime  = 30;
	global void execute(SchedulableContext SC) {
		List<AsyncApexJob> allRunningBatchJobList = CadenceSchedulerHelper.getAllBatchJobs(new Map<String, Set<String>>{'ApexClass.Name' => new Set<String>{'PerformContactActionBatch', 'PerformOpportunityActionBatch', 'PerformLeadActionBatch'}, 
																							'Status' => new Set<String>{'Processing','Preparing','Queued'}});
		Set<String> batchClassNameSet = new Set<String>();
		for(AsyncApexJob batchJob : allRunningBatchJobList) {
			batchClassNameSet.add(batchJob.ApexClass.Name);
		}
		
		/*// Schedule batch for Contact
		if(batchClassNameSet.size() == 0 ||  !batchClassNameSet.contains('PerformContactActionBatch')) {
			PerformContactActionBatch con = new PerformContactActionBatch(); 
			Database.executeBatch(con,100);
		}
		
		// Schedule batch for lead
		if(batchClassNameSet.size() == 0 ||  !batchClassNameSet.contains('PerformLeadActionBatch')) {
			PerformLeadActionBatch led = new PerformLeadActionBatch();
			Database.executeBatch(led,100);
		}
		
		// Schedule batch for opportunity
		if(batchClassNameSet.size() == 0 ||  !batchClassNameSet.contains('PerformOpportunityActionBatch')) {
			PerformOpportunityActionBatch opportunity = new PerformOpportunityActionBatch();
			Database.executeBatch(opportunity,100);
		} */
			
		// Schedule next cadence scheduler
		CadenceUtil.scheduleNextCadenceScheduler(nextScheduleTime);
	}
}