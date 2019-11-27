@isTest
private class ManualSequenceAssociateControllerTest {
    public static Cadence__c cadenceLead;
    public static Lead lead1;
    public static Lead lead2;
    public static Contact contact1;
    public static Cadence__c cadenceContact;
    static{
        List<SObject> objectsToInsert=new List<SObject>();
        cadenceLead = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
        String entryJsonLead = TestDataFactory.createCadJsonWithNameCriterions('Test', 'Test', CadenceConstants.CONDITION_OR, '');
        String exitJsonLead = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
        cadenceLead.Entrance_Criteria__c = entryJsonLead;
        cadenceLead.Exit_Criteria__c = exitJsonLead;
        objectsToInsert.add(cadenceLead);
        
        cadenceContact = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
        String entryJsonContact = TestDataFactory.createCadJsonWithNameCriterions('Test', 'Test', CadenceConstants.CONDITION_OR, '');
        String exitJsonContact = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
        cadenceContact.Entrance_Criteria__c = entryJsonContact;
        cadenceContact.Exit_Criteria__c = exitJsonContact;
        objectsToInsert.add(cadenceContact);
        
        lead1=new Lead(LastName='Lead1',Company='Lead1 Company');
        lead2=new Lead(LastName='Lead2',Company='Lead2 Company');
        contact1=new Contact(LastName='Contact1');
        objectsToInsert.add(lead1);
        objectsToInsert.add(lead2);
        objectsToInsert.add(contact1);   
        insert objectsToInsert;
    }
    @isTest
    public static void testGetCadenceDataByRecordType(){
        List<CadenceActionListController.CadenceWrapper> cadenceWrapperLead;
        List<CadenceActionListController.CadenceWrapper> cadenceWrapperContact;
        Test.startTest();
        cadenceWrapperLead=ManualSequenceAssociateController.getCadenceDataByRecordType('Lead');
        cadenceWrapperContact=ManualSequenceAssociateController.getCadenceDataByRecordType('Contact');
        Test.stopTest();
        System.assertEquals(cadenceLead.Id, cadenceWrapperLead[0].cadId);
        System.assertEquals(cadenceContact.Id, cadenceWrapperContact[0].cadId);
    }
    @isTest
    public static void testSaveParticipantsWhenPreviouslyNotAssociated(){
        Integer previouslyAssociatedLeads;
        Integer previouslyAssociatedContacts;
        String leadId='['+lead1.Id+']'; 
        String contactId='['+contact1.Id+']'; 
        Test.startTest();
        previouslyAssociatedLeads=ManualSequenceAssociateController.saveParticipants((String)cadenceLead.Id,leadId);
        previouslyAssociatedContacts=ManualSequenceAssociateController.saveParticipants((String)cadenceContact.Id,contactId);
        Test.stopTest();
        Lead lead=[SELECT Cadence_Id__c FROM Lead WHERE LastName='Lead1'];
        Contact contact=[SELECT Cadence_Id__c FROM Contact WHERE LastName='Contact1'];
        System.assertEquals(cadenceLead.Id, lead.Cadence_Id__c);
        System.assertEquals(0, previouslyAssociatedLeads);
        System.assertEquals(cadenceContact.Id, contact.Cadence_Id__c);
        System.assertEquals(0, previouslyAssociatedContacts);
    }
    @isTest
    public static void testSaveParticipantsWhenPreviouslyAssociated(){
        Integer previouslyAssociatedLeads;
        String leadId='['+lead1.Id+','+lead2.Id+']'; 
        Test.startTest();
        //to associate 1 lead before 2nd
        ManualSequenceAssociateController.saveParticipants((String)cadenceLead.Id,'['+lead1.Id+']');
        previouslyAssociatedLeads=ManualSequenceAssociateController.saveParticipants((String)cadenceLead.Id,leadId);
        Test.stopTest();
        Lead lead=[SELECT Cadence_Id__c FROM Lead WHERE LastName='Lead2'];
        System.assertEquals(cadenceLead.Id, lead.Cadence_Id__c);
        System.assertEquals(1, previouslyAssociatedLeads);
    }
    @isTest
    public static void testStandardSetControllerConstructor(){
        List<Contact> contacts=new List<Contact>();
        contacts.add(contact1);
        Test.startTest();
        Test.setCurrentPage(Page.ContactSequenceList);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(contacts);
        stdSetController.setSelected(contacts);
        ManualSequenceAssociateController controller = new ManualSequenceAssociateController(stdSetController);
        Test.stopTest();
    }
    @isTest
    public static void testStandardControllerConstructor(){
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(contact1);
        PageReference pageRef = Page.ContactSequenceList;
        pageRef.getParameters().put('id', String.valueOf(contact1.Id));
        Test.setCurrentPage(pageRef);
        ManualSequenceAssociateController controller = new ManualSequenceAssociateController(sc);
        Test.stopTest();
    }
}