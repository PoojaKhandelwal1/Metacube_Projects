public class PerformDMLActionBatch implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {
	String queryDML = '';
	String DMLType = '';
	String otherOperation = '';
	String nameSpace = CadenceConstants.NAMESPACE;

	public PerformDMLActionBatch(String query,String dmltype,String otherOperation) { 
		this.queryDML = query; 
		this.DMLType = dmltype;
		this.otherOperation = otherOperation;
	}

	public Database.QueryLocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(queryDML);    
	}

	public void execute(Database.BatchableContext bc, List<sObject> objList) {
		if(!string.isBlank(otherOperation)){
			UpdateSobject(objList);    
		}

		if(DMLType.toLowerCase() == CadenceConstants.DMLUPDATE){
			Database.update(objList, false);
		}else if(DMLType.toLowerCase() == CadenceConstants.DMLDELETE){
			Database.delete(objList, false);
		}
	}

	public void finish(Database.BatchableContext bc) {

	}

	public void UpdateSobject(List<sObject> objList){
		if(otherOperation == CadenceConstants.SETCONTACTOPPNULL){
			if(objList != null && objList.size() > 0){
				for(sObject sObj : objList){
					sObj.put(nameSpace+'Opportunity_Id__c',null);
				}

			}    
		}
	}
}