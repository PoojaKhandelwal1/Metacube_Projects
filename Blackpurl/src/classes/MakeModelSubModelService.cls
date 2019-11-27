public without sharing class MakeModelSubModelService {
    
    public static String getMakeModelSubmodelList() {
        return system.JSON.serialize(new MakeModelSubModelListWrapper(Database.query(getQuery('Unit_Make__c')), 
                                                       Database.query(getQuery('Unit_Model__c')), Database.query(getQuery('Unit_Sub_Model__c'))), true);
    }
    
    private static Map<String, List<String>> objectAPINameToFieldListMap = 
            new Map<String, List<String>> {'Unit_Make__c' => new List<String>{'Name'},
                                     'Unit_Model__c' => new List<String>{'Name__c', 'Unit_Make__c'},
                                     'Unit_Sub_Model__c' => new List<String>{'Sub_Model_Name__c', 'Unit_Model__c'}
                };
    
    public static String getQuery(String objectName) {
        if(!AccessControl.ifObjectFieldIsAccessible(objectName)) {throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
        String query = 'SELECT ';
        for(String field : objectAPINameToFieldListMap.get(objectName)) {
            query += field + ', ';
        }
        query = query.subString(0, query.length() - 2);
        query += ' FROM ' + objectName + ' WHERE ' + objectAPINameToFieldListMap.get(objectName).get(0) + '!= null' + ' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
        return query;
    }
    
    public class MakeModelSubModelListWrapper {
        public List<MakeModelSubmodelWrapper> MakeList;
        public List<MakeModelSubmodelWrapper> ModelList;
        public List<MakeModelSubmodelWrapper> SubModelList;
        
        public MakeModelSubModelListWrapper(List<Unit_Make__c> makeRecList, List<Unit_Model__c> modelRecList, List<Unit_Sub_Model__c> subModelRecList) {
            this.MakeList = new List<MakeModelSubmodelWrapper>();
            this.ModelList = new List<MakeModelSubmodelWrapper>();
            this.SubModelList = new List<MakeModelSubmodelWrapper>();
            for(Unit_Make__c unitMakeRec : makeRecList) {
                MakeList.add(new MakeModelSubmodelWrapper(unitMakeRec));
            }
            for(Unit_Model__c unitModelRec : modelRecList) {
                ModelList.add(new MakeModelSubmodelWrapper(unitModelRec));
            }
            for(Unit_Sub_Model__c unitSubModelRec : subModelRecList) {
                SubModelList.add(new MakeModelSubmodelWrapper(unitSubModelRec));
            }
        }
    }
    
    public class MakeModelSubmodelWrapper {
        public String Id;
        public String UnitMakeName;
        public String UnitModelName;
        public String SubModelName;
        public String MakeId;
        public String ModelId;
        
        public MakeModelSubmodelWrapper(Unit_Make__c unitMakeRec) {
            this.Id = unitMakeRec.Id;
            this.UnitMakeName = unitMakeRec.Name;
        }
        public MakeModelSubmodelWrapper(Unit_Model__c unitModelRec) {
            this.Id = unitModelRec.Id;
            this.UnitModelName = unitModelRec.Name__c;
            this.MakeId = unitModelRec.Unit_Make__c;
        }
        public MakeModelSubmodelWrapper(Unit_Sub_Model__c unitSubModelRec) {
            this.Id = unitSubModelRec.Id;
            this.SubModelName = unitSubModelRec.Sub_Model_Name__c;
            this.ModelId = unitSubModelRec.Unit_Model__c;
        }
    }
}