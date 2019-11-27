public class Leads  extends SObjectDomain {
    
    List<Lead> records;
    public static Integer flag = 0;
    public static boolean fireTrigger = true;
    
    
    public Leads(List<Lead> sObjectList) { 
        super(sObjectList);
        records = (List<Lead>)sObjectList;
    }
    
    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<SObject> sObjectList) {
            return new Leads(sObjectList);
        }
    }
    
    //public override void onBeforeInsert() {} 
    
    public override void onAfterInsert() {
        if(shouldTriggerFire()) {
            startSequenceEngine();
        }
    }
    
    //public override void onbeforeUpdate(Map<Id,SObject> existingRecords){}
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        if(shouldTriggerFire()) {
            startSequenceEngine();
        }
    }
    
    boolean shouldTriggerFire(){
        return fireTrigger;
    }
    
    private void startSequenceEngine(){
        Map<Id, SObject> contactIdContactMap = New Map<Id, SObject>(records);
        Set<Id> leadIdSet = contactIdContactMap.keyset();
        String query = formLeadSelectQuery(leadIdSet) ;
        List<Lead> leadList = Database.query(query);
        SequenceEngine.processSequences(CadenceConstants.LEAD_OBJECT_NAME, leadList, New List<SObject>(), true);
    }
    
    
    private static String formLeadSelectQuery(Set<Id> leadIdSet) {
        List<String> participantTypeToParentObjectList = PerformCadenceActionBatchHelper.getParticipantTypeToParentObjectListMap().get(CadenceConstants.LEAD_OBJECT_NAME);
        String query = 'Select ';
        Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
        List<Schema.SObjectField> contactFieldList = PerformCadenceActionBatchHelper.getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Lead');
        
        query = PerformCadenceActionBatchHelper.addFieldsInQuery(query, globalDescribedSchemaMap, contactFieldList, participantTypeToParentObjectList);
        
        query = query.subString(0, query.length() - 1);
        query += ' From Lead WHERE Id IN :leadIdSet' ;
        return query;
    }
    
}