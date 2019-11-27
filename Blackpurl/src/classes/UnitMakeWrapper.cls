/**
 * Author: Tarun Khandelwal
 * Since: May 26, 2015
 * Name: UnitMakeWrapper
 * Description: Apex class to handle JSON related oprations of UnitMake Wrapper.
**/
public with sharing class UnitMakeWrapper {
	
	// Map to store the unit make name and unit model record
	public Map<string,List<UnitModel>> unitMakeNameToUnitModelMap = new Map<string,List<UnitModel>>();
	public Map<string,List<UnitSubmodel>> unitModelToUnitSubModelMap = new Map<string,List<UnitSubmodel>>();
	
	// Constructor
    public UnitMakeWrapper(List<Unit_Make__c> unitMakeRecList) {
    	//this.CountryName = countryRec.Name__c;
    	for(Unit_Make__c unitMakeRec : unitMakeRecList) {
	    	List<UnitModel> unitModelList = new List<UnitModel>();
	    	if(unitMakeRec.Unit_Models__r.size() > 0) {
	    		for(Unit_Model__c unitModelRec : unitMakeRec.Unit_Models__r) {
	    			unitModelList.add(new UnitModel(unitModelRec));
	    		}
	    		this.unitMakeNameToUnitModelMap.put(unitMakeRec.Name, unitModelList);
	    	}
    	}
    	
    	/*for(Unit_Make__c unitMakeRec : unitMakeRecList) {
	    	List<UnitSubModel> unitModelList = new List<UnitSubModel>();
	    	if(unitMakeRec.Unit_Models__r.size() > 0) {
	    		for(Unit_Model__c unitModelRec : unitMakeRec.Unit_Models__r) {
					if(unitModelToUnitSubModelMap.containsKey(unitModelRec.Name__c)){
						unitModelToUnitSubModelMap.get(unitModelRec.Name__c).add(new UnitSubModel(unitModelRec));
					}else{
						List<UnitSubModel> UnitSubModelList = new List<UnitSubModel>();
						UnitSubModelList.add(new UnitSubModel(unitModelRec));
						unitModelToUnitSubModelMap.put(unitModelRec.Name__c,UnitSubModelList);
					}
	    		}
	    	}
    	}*/
    }
}