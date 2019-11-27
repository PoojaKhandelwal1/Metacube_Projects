public with sharing class UnitSubModel {
	//Id
	public String Id;
	// Sub Model
	public String SubModelName;
	
	public String SubmodelDescription;
	 
	public UnitSubModel(Unit_Sub_Model__c unitModelRec) {
    	this.Id = unitModelRec.Id;
    	this.SubModelName = unitModelRec.Sub_Model_Name__c;
    	this.SubmodelDescription = unitModelRec.Sub_Model_Description__c;
    	
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> unitSubModelFields = new List<String>{ 'Id',
	                                                    'Sub_Model_Name__c',
	                                                    'Sub_Model_Description__c'
                                               		 };
        return unitSubModelFields;
    }
}