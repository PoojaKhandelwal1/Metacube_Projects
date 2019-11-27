public class testBatch implements Database.Batchable<sObject>, Database.stateful {
    
    public static String nameSpace = CadenceConstants.NAMESPACE;
    public String objType;
    public String parentObj;
    public list<string> listOfobjecttype;
    
    public testBatch(List<String> listOfObjTypeAndParent) { 
        this.listOfobjecttype = listOfObjTypeAndParent; 
         if(listOfObjTypeAndParent != null && listOfObjTypeAndParent.size() > 0)
             this.objType=listOfObjTypeAndParent[0];
    }
     
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id, Name, OwnerId From Contact Limit 2' ;
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> objList) {
        system.debug('in execute');
        list<Contact> conList = (list<Contact>)objList;
        for(Contact con : conList){
            Id sobjId = Id.valueOf('00Q0o00001Tc55xEAB');
            Task t = new Task();
            t.Subject = 'Action Creaated From Batch';
            t.Description =  'owner id is : ' + String.valueOf(con.OwnerId) 
                + 'And Org Id :  ' + String.valueOf(UserInfo.getOrganizationId());
            t.WhoId = sobjId;
            t.TaskSubtype = 'Email' ; 
            t.Status = 'Completed';
            system.debug('task ' + t);
            insert t;
            system.debug('Task Created');
        }
    }
    
    public void finish(Database.BatchableContext bc) {
    }
    
    public static String formQuery(List<String> objList){
        List<CriterionWrapper> criterionWrapperList =  CadenceService.getFieldsWithLabelsForBatch(objList);
        String objecttype;
        if(objList != null && objList.size() > 0)
            objecttype=objList[0];
        String query = 'Select ';
        Set<String> allowedFields = new Set<String>();
        for(CriterionWrapper wrapper : criterionWrapperList ){
            for(Criterion criteria : wrapper.fieldsDetail ){
                allowedFields.add(criteria.fieldName);
            }
        }
        //query = query.substring(0,query.length()-1);
        if(nameSpace != ''  && allowedFields.size() > 0){
            String apiNameWithNamespace;
            for(String fld : allowedFields){
                apiNameWithNamespace = nameSpace + fld;
                if(allowedFields.contains(apiNameWithNamespace)){
                    allowedFields.remove(fld); 
                }
            }
        }
        query += String.join(new List<String>(allowedFields), ',');
        query += ' FROM '+ objecttype + ' LIMIT 10';
        return query;
    }
    
    public static Set<String> getObjectFields(String objType, Boolean parentField) {
        Set<String> allowedFields = new Set<String>();
        SObjectType r;
        try {
            r = ((SObject)(Type.forName('Schema.'+objType).newInstance())).getSObjectType();
        } catch(Exception e) {
            return allowedFields;
        }
        
        Map<String, Schema.SObjectField> fieldMap  = r.getDescribe().fields.getMap();
        for (Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (!fieldDescribe.isAccessible()) {
                continue; 
            }
            if(parentField) {
            	allowedFields.add(objType + '.' + fieldDescribe.getName());    
            } else {
                allowedFields.add(fieldDescribe.getName());
            } 
        }
        return allowedFields;
    }
    
    
}