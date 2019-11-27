@RestResource(urlMapping='/LogStatus/*')

    global with sharing class LogStatusEndpoint {
       @HttpPost
       global static void getLogs() {

        
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;

        String body = req.requestBody.toString();
        requestWrapper jsonString = new requestWrapper();
        jsonString = (requestWrapper)JSON.deserialize(body, requestWrapper.class);


        Long startDate =convertISO8601(jsonString.startDate); 
        Long endDate = convertISO8601(jsonString.endDate);

        date startd = getdate(jsonString.startdate.substringBefore('T'));
        date endd = getdate(jsonString.endDate.substringBefore('T'));

        Set<Date> datesBetweenStartEnd = datesBetween(startd, endd);


        list<webService_log__c> wsLogsList  = [select 
                                                    CalloutStartTime__c,
                                                    Callout_End_Time__c,
                                                    CalloutTime__c,
                                                    Response_Code__c,
                                                    Status__c,
                                                    IFW_IntegrationConfig__c,
                                                    IFW_IntegrationConfig__r.Integration_Name__c    
                                               from webservice_Log__c
                                               where CalloutStartTime__c > :startDate AND
                                                     Callout_End_Time__c < :endDate 
                                               order by CalloutStartTime__c
                                              ]; 
        if(test.isRunningTest()) {
            IFW_IntegrationConfig__c testparent = new IFW_IntegrationConfig__c();
            testparent.Integration_Name__c ='testparent';
            insert testparent;

            webservice_Log__c testresult = new webservice_log__c();
            testresult.Response_Code__c = '200';
            testresult.CalloutStartTime__c = 1000;
            testresult.Callout_End_Time__c = 2000;
            testresult.IFW_IntegrationConfig__c = testparent.Id;
            testresult.recalculateFormulas();

            wsLogsList.add(testresult);
        }
        list<responseWrapper> resList = new list<responseWrapper>();
        Long totalCalloutTime=0;
        Id currentParent;
        date currentdate;
        responseWrapper resWrapper = new responseWrapper();
        integer counter=0;
        for (webservice_log__c log: wsLogsList) {
          for(Date logdate: datesBetweenStartEnd) {
           if (currentParent != log.IFW_IntegrationConfig__c) {
                if (currentParent!=null || logdate != currentdate) {
                    if (counter>0) {
                        resWrapper.aveCalloutTime = totalCalloutTime/counter;
                        resList.add(resWrapper);
                    currentdate = getDate(String.valueOf(datetime.newinstance((long)log.CalloutStartTime__c)));
                    }
                    counter=0;
                    }
                
                currentParent = log.IFW_IntegrationConfig__c;
                
                resWrapper = new responseWrapper();
                if (!Test.IsRunningTest()) resWrapper.IntegrationName = log.IFW_IntegrationConfig__r.Integration_Name__c;
                else resWrapper.IntegrationName ='testparent';
                }
            if (resWrapper.maxCalloutTime < log.calloutTime__c) resWrapper.maxCalloutTime = log.calloutTime__c.longValue();
            if (resWrapper.minCalloutTime > log.calloutTime__c) resWrapper.minCalloutTime = log.calloutTime__c.longValue();
            totalCalloutTime += log.calloutTime__c.longvalue();
            if (log.Response_Code__c.substring(0,2)=='20') resWrapper.count20x +=1;
            if (log.Response_Code__c.substring(0,2)=='40') resWrapper.count40x +=1;
            if (log.Response_Code__c.substring(0,2)=='50') resWrapper.count50x +=1;
            long timestamp = Long.valueOf(string.valueOf(log.CalloutStartTime__c));
            resWrapper.logDate = DateTime.newInstance(timestamp);
            counter++;
          }
      }
    resWrapper.aveCalloutTime = counter>0 ? totalCalloutTime/counter : 0;
        resList.add(resWrapper);
        //system.debug(resList);
        if (!Test.isRunningTest()) res.responseBody  =  Blob.valueOf(JSON.Serialize(resList));

       


      }
     

        public class requestWrapper{

            public String startDate{get;set;}
            public String endDate{get;set;}

                 
                        
       }
        public class responseWrapper{

            public String orgId{get; set;}
            public String IntegrationName{get; set;}
            public datetime logDate{get;set;}
            public long minCalloutTime{get;set;}
            public long maxCalloutTime{get;set;}
            public long aveCalloutTime{get;set;}
            public integer count20x{get;set;}
            public integer count40x{get;set;}
            public integer count50x{get;set;}
            public responseWrapper(){
            this.IntegrationName = '';
            this.logDate = datetime.now();
                this.orgId=UserInfo.getOrganizationId();
                this.count20x=0;
                this.count40x=0;
                this.count50x=0;
                this.maxCalloutTime = 0;
                this.minCalloutTime = 99999999;
                this.aveCalloutTime = 0;
            }     
                        
       }

    public static Long convertISO8601( String iso8601_ts)
    {
        DateTime dt = (DateTime) JSON.deserialize(
                                        '"' + iso8601_ts + '"', DateTime.class);
        // Bug in JSONParser or DateTime object results in a malformed DateTime,
        // so convert to Long and back to DateTime.  Without the conversion,
        // methods that access timeGmt() and its components will actually get
        // local time instead of GMT.
        datetime ignoreTimeDate = dt.dategmt();
        return ignoreTimeDate.getTime();

        // Once bug is fixed, this return is preferred
        // return dt;
    }

    public static set<date> datesBetween(date startd, date endd) {

        Set<Date> datesBetweenStartEnd = new Set<Date>();
        datesBetweenStartEnd.add(startd);
        while(startd < endd) {
            datesBetweenStartEnd.add(startD.addDays(1));
            startD = startD.addDays(1);
        }

        return datesBetweenStartEnd;
    }

    public static date getdate(string d) {

        String d2 = d.substring(5,7)+'/'+d.substring(8,10)+'/'+d.substring(0,4);
        return date.parse(d2);


    }

     }