global class testScheduler implements schedulable{
    // Next schedule time must be in minutes
    public static Integer nextScheduleTime  = 30;
    global void execute(SchedulableContext SC) {
        Integer runningBatch = CadenceUtil.getAllRunningBatch();
        if (runningBatch == 0){
            testBatch Con=new testBatch(new List<string>{CadenceConstants.CONTACT_OBJECT_NAME});
            Database.executeBatch(Con,1);
        }
        CadenceUtil.scheduleNextCadenceScheduler(nextScheduleTime);
        // We also create a log if Batch is skipped.
    }
}