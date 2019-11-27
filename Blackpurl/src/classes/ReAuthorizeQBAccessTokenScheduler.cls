/**
 * Author: Tarun Khandelwal
 * Since: July 20, 2018
 * Name: ReAuthorizeQBAccessTokenScheduler
 * Description: Scheduler class for regenrating Authorise token used for QB
**/
global with sharing class ReAuthorizeQBAccessTokenScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
        if(qbConfig.Access_Token_Generation_Date__c != null) {
            Integer dayDiff = qbConfig.Access_Token_Generation_Date__c.daysBetween(system.today());
            if(dayDiff > 151 && dayDiff < 179) {
                regerateToken();
            }
        }
    }
    
    @future(callout=true)
    private static void regerateToken() {
        String message = new ReAuthorizeQBAccessTokenCtrl().regenerateAccessToken();
        sendEmail(message);
    }
    
    private static void sendEmail(String message) {
        String defaultEmail = GeneralConfiguration.getSupportEmailRecipient();
        List<String> emailStrList = new List<String>();
        if(String.isNotBlank(defaultEmail)) {
            emailStrList = defaultEmail.split(';');
        } else {
            String supportMail = GeneralConfiguration.getSupportEmail();
            emailStrList = new List<String>{supportMail};
        }
        SendEmail.sendSupportMail(emailStrList, 'Regenerate QB Access Token Result', setHTMLBody(message));
    }
    
    private static String setHTMLBody(String message) {
        String htmlBody = '';
        htmlBody += '<table style="width:400px; border-collapse: collapse;" >';
        htmlBody +=   '<tr >';
        htmlBody +=     '<td style="border : 1px solid ">Company Name </td>';
        htmlBody +=     '<td style="border : 1px solid ">' + UserInfo.getOrganizationName() + '</td>';
        htmlBody +=   '</tr>';
        htmlBody +=   '<tr >';
        htmlBody +=     '<td style="border : 1px solid ">Org Id </td>';
        htmlBody +=     '<td style="border : 1px solid ">' + UserInfo.getOrganizationId() + '</td>';
        htmlBody +=   '</tr>';
        htmlBody +=   '<tr >';
        htmlBody +=     '<td style="border : 1px solid ">Result</td>';
        htmlBody +=     '<td style="border : 1px solid ">' + message + '</td>';
        htmlBody +=   '</tr>';
        htmlBody +=  '</table>';
        return htmlbody;
    }
}