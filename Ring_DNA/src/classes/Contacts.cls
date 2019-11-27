public class Contacts  extends SObjectDomain {

	List<Contact> records = new List<Contact>();
	public static boolean fireTrigger = true;
	
	//Need to remove
	public static boolean flag = false;

	public Contacts(List<Contact> sObjectList) {
		super(sObjectList);
		records = (List<Contact>)sObjectList;
	}

	public class Constructor implements SObjectDomain.IConstructable {
		public SObjectDomain construct(List<SObject> sObjectList) {
			return new Contacts(sObjectList);
		}
	}


	/*public override void onBeforeInsert() {        
		
	}*/

	public override void onAfterInsert() {
		if(shouldTriggerFire()) {
            startSequenceEngine();
		}
	}

	/*public override void onbeforeUpdate(Map<Id,SObject> existingRecords){
	
	}*/
	
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
        Set<Id> contactIdSet = contactIdContactMap.keyset();
        String query = formContactSelectQuery(contactIdSet) ;
        List<Contact> contactList = Database.query(query);
        SequenceEngine.processSequences(CadenceConstants.CONTACT_OBJECT_NAME, contactList, New List<SObject>(), true);
    }
    
    
    private static String formContactSelectQuery(Set<Id> contactIdSet) {
        List<String> participantTypeToParentObjectList = PerformCadenceActionBatchHelper.getParticipantTypeToParentObjectListMap().get(CadenceConstants.CONTACT_OBJECT_NAME);
		String query = 'Select ';
		Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
		List<Schema.SObjectField> contactFieldList = PerformCadenceActionBatchHelper.getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Contact');
		
		query = PerformCadenceActionBatchHelper.addFieldsInQuery(query, globalDescribedSchemaMap, contactFieldList, participantTypeToParentObjectList);
		
		query = query.subString(0, query.length() - 1);
		query += ' From Contact WHERE Id IN :contactIdSet' ;
		return query;
	}
}