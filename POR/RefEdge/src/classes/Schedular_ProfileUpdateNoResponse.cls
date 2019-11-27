/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, 
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, 
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR, 
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF 
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING, 
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS 
 * WRITTEN CONSENT FROM COMPANY.
 */
public class Schedular_ProfileUpdateNoResponse implements Schedulable {
    /**
     * Execute Method of scheduler
     */
    public void execute(SchedulableContext sc) {
        Integer enqueuedJobs = WithoutSharingHelperController.getEnqueuedJobsCountForSchedulars();
        
        if (enqueuedJobs < 5) {
            //Call "Batch_ProfileUpdateNoResponse" Batch Class
            Database.executeBatch(new Batch_ProfileUpdateNoResponse());
        } else {
            //schedule this same schedulable class again in 13 mins
            Schedular_ProfileUpdateNoResponse scheduler = new Schedular_ProfileUpdateNoResponse ();
            Datetime dt = Datetime.now().addMinutes(13);
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
            
            if (!Test.isRunningTest()) {
                Id schedId = System.Schedule('Retry : RefEdge_ProfileUpdateNoResponse Schedular'+timeForScheduler, timeForScheduler, scheduler);
            }
        }
    }
}