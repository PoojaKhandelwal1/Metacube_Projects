@isTest
public class PerformCadenceActionBatchTest {
    public static final String CUSTOM_LOGIC = '1 AND (2 OR 3)';
    Public static Final String ACTION_TYPE_CALL = 'Call';
    public static final String CUSTOM_LOGIC1 = '1 AND (2 AND 3)';
    public static final String CUSTOM_LOGIC2 = '1 OR (2 OR 3)'; 
    public static Cadence__c cadLeadAND;
    public static Cadence__c cadLeadOR;
    public static Cadence__c cadLeadCUSTOM;
    public static Cadence__c cadContactAND; 
    public static Cadence__c cadContactOR;
    public static Action__c action1;
    public static Action__c action2;
    public static Action__c action3;
    public static CadenceAction__c cadenceActionLeadAND;
    public static CadenceAction__c cadenceActionLeadOR;
    public static CadenceAction__c cadenceActionCUSTOM;
    public static String cadJsonAND;
    public static String cadJsonOR;
    public static String cadJsonCUSTOM; 
    
    static {
        cadLeadAND = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        cadLeadOR = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        cadLeadCUSTOM = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        
        List<Criterion> criterionList = new List<Criterion>();
        Criterion c1 = TestDataFactory.createCriterion(1, 'Status', 'PICKLIST', 'equals', 'Open - Not Contacted');
        Criterion c2 = TestDataFactory.createCriterion(2, 'LeadSource', 'PICKLIST', 'equals', 'Web');
        Criterion c3 = TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Test');
        criterionList.add(c1);
        criterionList.add(c2);
        criterionList.add(c3);
        
        cadJsonAND = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
        cadJsonOR = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_OR, '');
        cadJsonCUSTOM = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_CUSTOM, CUSTOM_LOGIC);
        
        cadLeadAND.Entrance_Criteria__c = cadJsonAND;
        cadLeadAND.Exit_Criteria__c=cadJsonAND;
        cadLeadAND.Participent_Activation__c='Automatic';
        cadLeadAND.matching_priority__c = 'P1';
        
        cadLeadOR.Entrance_Criteria__c = cadJsonOR;
        cadLeadOR.Exit_Criteria__c =  cadJsonOR;
        cadLeadOR.Participent_Activation__c = 'Automatic';
        cadLeadOR.matching_priority__c = 'P3';
        cadLeadOR.Entrance_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        cadLeadOR.Exit_Criteria_PE__c=RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        
        cadLeadCUSTOM.Entrance_Criteria__c = cadJsonCUSTOM;
        cadLeadCUSTOM.Exit_Criteria__c = cadJsonCUSTOM;
        cadLeadCUSTOM.Entrance_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        cadLeadCUSTOM.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC2);
        cadLeadCUSTOM.matching_priority__c = 'P2';
        cadLeadCUSTOM.Participent_Activation__c='Automatic';
        insert cadLeadAND;
        insert cadLeadOR;
        insert cadLeadCUSTOM;
        
        action1= TestDataFactory.createAction(ACTION_TYPE_CALL);
        action2= TestDataFactory.createAction(ACTION_TYPE_CALL);
        action3= TestDataFactory.createAction(ACTION_TYPE_CALL);
        
        action1.Activation_Type__c = 'Automatic';
        action2.Activation_Type__c = 'Automatic';
        action3.Activation_Type__c = 'Automatic';
        insert action1;
        insert action2;
        insert action3; 
        
        cadenceActionLeadAND=TestDataFactory.createCadenceAction(cadLeadAND.Id, action1.Id);
        cadenceActionLeadOR=TestDataFactory.createCadenceAction(cadLeadOR.Id, action2.Id);
        cadenceActionCUSTOM=TestDataFactory.createCadenceAction(cadLeadCUSTOM.Id, action3.Id);
        
        cadenceActionLeadAND.Trigger_Type__c = 'Immediate';
        cadenceActionLeadOR.Trigger_Type__c = 'Immediate';
        cadenceActionCUSTOM.Trigger_Type__c = 'Immediate'; 
    }
   	@isTest 
    static void leadMatchesCriterionTest() {
        Lead l1= new Lead();
        l1.Company='COM';
        l1.FirstName='fname';
        l1.LastName='lname';
        l1.Status = 'Open - Not Contacted';
        l1.LeadSource = 'Web';
        l1.Title = 'Test';
        insert l1;
        
        Lead l2 = TestDataFactory.createLead();
        l2.status = 'Open - Not Contacted';
        l2.LeadSource = 'Other';
        l2.Title = 'SecondTest';
        l1.Company='SecondCOM';
        l1.FirstName='fname2';
        l1.LastName='lname2';
        insert l2;
        
        Test.startTest();
        PerformCadenceActionBatch lead=new PerformCadenceActionBatch(new List<string>{CadenceConstants.LEAD_OBJECT_NAME, CadenceConstants.DB_OBJECT_NAME});
        PerformCadenceActionBatch contact=new PerformCadenceActionBatch(new List<string>{CadenceConstants.CONTACT_OBJECT_NAME, CadenceConstants.ACCOUNT_OBJECT_NAME});
        Database.executeBatch(lead,200);
        Test.stopTest();
        l1 = [Select Id, Cadence_Id__c from Lead where Id = :l1.Id];
        l2 = [Select Id, Cadence_Id__c from Lead where Id = :l2.Id];
        
    }  
     @isTest 
    static void OpportunityRoleTest(){
        Opportunity opportunity = TestDataFactory.createOpp('Test-opp-01');
        Opportunity opportunity2 = TestDataFactory.createOpp('Test-opp-02');
        opportunity2.Cadence_Id__c =null;
        insert New List<opportunity>{opportunity,opportunity2};
        System.assertNotEquals(null, opportunity.Id); 
        System.assertNotEquals(null, opportunity2.Id); 
        
        Contact c1= new Contact();
        c1.FirstName='Test';
        c1.LastName='Contact for Role1';
        c1.Department='IT';
        
        Contact c2= new Contact();
        c2.FirstName='Test';
        c2.LastName='Contact for Role2';
        c2.Department='Salesforce';
        
        Contact c3= new Contact();
        c3.FirstName='Test';
        c3.LastName='Contact for Role2';
        c3.Department='Salesforce';
        insert new List<Contact>{c1,c2,c3};
        System.assertNotEquals(null, c1.Id);
        System.assertNotEquals(null, c2.Id);
        System.assertNotEquals(null, c3.Id);
        
        OpportunityContactRole oppRol = new OpportunityContactRole(Role='Decision Maker',ContactId=c1.Id,OpportunityId=opportunity.id);
        OpportunityContactRole oppRol2 = new OpportunityContactRole(Role='Decision Maker',ContactId=c2.Id,OpportunityId=opportunity.id);
        OpportunityContactRole oppRol3 = new OpportunityContactRole(Role='Other',ContactId=c3.Id,OpportunityId=opportunity.id);
        insert new List<OpportunityContactRole>{oppRol,oppRol2,oppRol3};
        System.assertNotEquals(null, oppRol.Id);
        System.assertNotEquals(null, oppRol2.Id);
        System.assertNotEquals(null, oppRol3.Id);

        Cadence__c cadence1 = TestDataFactory.createCadence(CadenceConstants.OPPORTUNITY_OBJECT_NAME);
        cadence1.matching_priority__c= 'P1';
        cadence1.Record_Type__c=CadenceConstants.OPPORTUNITY_OBJECT_NAME;
        String entryJson = TestDataFactory.createCadJsonWithNameCriterionsForOppRole('Decision Maker', CadenceConstants.CONDITION_AND, '');
        String exitJson = TestDataFactory.createCadJsonWithNameCriterionsForOppRole('Business User', CadenceConstants.CONDITION_AND, '');
        cadence1.Entrance_Criteria__c = entryJson;
        cadence1.Exit_Criteria__c = exitJson;
        insert cadence1;
        System.assertNotEquals(null, cadence1);
        
        Cadence__c cadence2 = TestDataFactory.createCadence(CadenceConstants.OPPORTUNITY_OBJECT_NAME);
        cadence2.matching_priority__c= 'P1';
        cadence2.Record_Type__c=CadenceConstants.OPPORTUNITY_OBJECT_NAME;
        String entryJson2 = TestDataFactory.createCadJsonWithNameCriterionsForOppRole('Other', CadenceConstants.CONDITION_AND, '');
        String exitJson2 = TestDataFactory.createCadJsonWithNameCriterionsForOppRole('Decision Maker', CadenceConstants.CONDITION_AND, '');
        cadence2.Entrance_Criteria__c = entryJson;
        cadence2.Exit_Criteria__c = exitJson;
        insert cadence2;
        System.assertNotEquals(null, cadence2);
        
        opportunity2.Cadence_Id__c = cadence2.id;
        update opportunity2;
        c3.Cadence_Id__c = cadence2.id;
        update c3;
        
        oppRol3.Role='Decision Maker';
        update oppRol3;
        action1= TestDataFactory.createAction('Email');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            insert validEmailTemplate;
            System.assertNotEquals(null, validEmailTemplate);
            action1.Template_Id__c= validEmailTemplate.id;
        }
        action1= TestDataFactory.createAction('Email');
        action1.Template_Id__c= null;
        action1.Activation_Type__c = 'Automatic';
        insert action1;
        System.assertNotEquals(null, action1);

        cadenceActionLeadAND =TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
        cadenceActionLeadAND.Day__c= 0;
        cadenceActionLeadAND.Hour__c= 0;
        cadenceActionLeadAND.Trigger_Type__c = 'Immediate';
        cadenceActionLeadAND.Fields_To_Update_Action__c = '{"sobjectType":"Lead","IsPrivate":"false"}';
        insert cadenceActionLeadAND;
        System.assertNotEquals(null, cadenceActionLeadAND.Id);
        
        CadenceAction__c cadenceActionOppAND =TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
        cadenceActionOppAND.Day__c= 0;
        cadenceActionOppAND.Hour__c= 0;
        cadenceActionOppAND.Trigger_Type__c = 'Immediate';
        insert cadenceActionOppAND;
        System.assertNotEquals(null, cadenceActionOppAND.Id);
        
        Sequence_Action__c seqAction  =  new Sequence_Action__c();
        seqAction.CadenceAction_Id__c = cadenceActionLeadAND.id;
        seqAction.isActionPerformed__c =false;
        seqAction.Contact_Id__c = c1.Id;
        insert seqAction;
        System.assertNotEquals(null, seqAction.Id);

        Test.startTest();
        // Schedule batch for opportunity
        PerformCadenceActionBatch oppBatch =new PerformCadenceActionBatch(new List<string>{CadenceConstants.OPPORTUNITY_OBJECT_NAME, CadenceConstants.ACCOUNT_OBJECT_NAME,CadenceConstants.CONTRACT_OBJECT_NAME,CadenceConstants.PRICE_BOOK_OBJECT_NAME});
        Database.executeBatch(oppBatch,500);
        Test.stopTest();
        opportunity = [Select id,Cadence_Id__c from Opportunity where id = :opportunity.Id];
        System.assertNotEquals(null, opportunity.Cadence_Id__c, 'Cadence lookup will populate as its criterion matches');
    }

    @isTest 
    static void codeTest(){
        Test.startTest();
        PerformCadenceActionBatch.getObjectFields(CadenceConstants.CONTACT_OBJECT_NAME, false);
        Test.stopTest();
    }    
}