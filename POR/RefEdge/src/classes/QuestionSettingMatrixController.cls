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
/**
 * VF Page: QuestionSettingMatrix.page
 * Description: controller for adding new interview questions and reordering the interview questions
 * Last modified by: Gaurav Saini (13 June, 2017) for #732
 */
public with sharing class QuestionSettingMatrixController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public List<questionWrapper> questWrapper { get; set; }
    private decimal orderCount;
    private String customSettingId;
    private List<Interview_Question__c> upsertInterviewQuestions;
    public String questionOrder { get; set; }
    
    /**
     * Constructor
     */
    public QuestionSettingMatrixController() {
        checkPermissions();
        questWrapper = new List<questionWrapper>();
        orderCount = 0;
        customSettingId = Apexpages.currentPage().getParameters().get('customSettingId');
        
        for (Interview_Question__c iq : [SELECT Order__c, Question__c FROM Interview_Question__c
        									ORDER BY Order__c LIMIT :limits.getLimitQueryRows()]) {
            orderCount = iq.Order__c;
            questWrapper.add(new questionWrapper(iq));
        }
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Interview_Question__c',
    										new Set<String>{UtilityController.appNamespace() + 'Order__c',
    											UtilityController.appNamespace() + 'Question__c'});
    	
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
        return isUpsertPermission;
    }
    
    /**
     * Method to add Question
     */
    public void addQuestion() {
        ++orderCount;
        questWrapper.add(new questionWrapper(new Interview_Question__c(Order__c = orderCount)));
    }
    
    /**
     * Wrapper Class
     */
    public class questionWrapper {
        public Interview_Question__c institueQuestion { get; set; }
        
        public questionWrapper(Interview_Question__c tempIQ) {
            institueQuestion = tempIQ;
        }
    }
    
    /**
     * Method to save Questions
     */
    public PageReference saveQuestions() {
    	
    	if (checkPermissions()) {
    		
	        upsertInterviewQuestions = new List<Interview_Question__c>();
	        orderCount = 0;
	        
	        for (questionWrapper qw : questWrapper) {
	        	
	            if (qw.institueQuestion.Question__c != null && qw.institueQuestion.Question__c.trim() != '') {
	                ++orderCount;
	                
	                if (qw.institueQuestion.Id == null) {
	                    qw.institueQuestion.Order__c = orderCount;
	                    upsertInterviewQuestions.add(qw.institueQuestion);
	                } else {
	                    upsertInterviewQuestions.add(qw.institueQuestion);
	                }
	            }
	        }
	        
	        if (upsertInterviewQuestions.size() > 0) {
	            upsert upsertInterviewQuestions;
	        }
	        return new PageReference('/' + customSettingId);
    	} else {
    		return null;
    	}
    }
    
    /**
     * Method to save Question order
     */
    public void saveQuestionOrder() {
    	
        if (questionOrder != '') {
            List<String> questionOrders = questionOrder.split(',');
            
            if (questionOrders.size() == 2) {
            	
                for (questionWrapper qw : questWrapper) {
                	
                    if (qw.institueQuestion.Order__c == integer.valueOf(questionOrders[0].split('_')[0])) {
                        qw.institueQuestion.Question__c = questionOrders[0].split('_')[1];
                    } else if (qw.institueQuestion.Order__c == integer.valueOf(questionOrders[1].split('_')[0])) {
                        qw.institueQuestion.Question__c = questionOrders[1].split('_')[1];
                    }
                }
            }
        }
    }
    
    /**
     * Method to cancel
     */
    public pageReference cancel() {
        return new PageReference('/' + customSettingId);
    }
}