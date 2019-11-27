public with sharing class CategoryService {
    
    public static List<CategoryService.CategoryWrapper> getFilteredCategoryWrapperList(Map<String, String> fieldAPINameToSearchFieldMap) {
        List<Category__c> categoryList = getFilteredCategory(fieldAPINameToSearchFieldMap);
        List<CategoryService.CategoryWrapper> wrapperList = new List<CategoryService.CategoryWrapper>();
        for(Category__c categoryRec : categoryList) {
            wrapperList.add(new CategoryService.CategoryWrapper(categoryRec));
        }
        return wrapperList;
    }
    
    public static List<Category__c> getFilteredCategory(Map<String, String> fieldAPINameToSearchFieldMap) {
        String query = 'Select Default__c, Name from Category__c Where Active__c = true ';
        for(String fieldName : fieldAPINameToSearchFieldMap.keySet()) {
            query += 'AND ' + fieldName + ' = \'' + fieldAPINameToSearchFieldMap.get(fieldName) + '\'';
        }
        return Database.query(query);
    }
    
    public class CategoryWrapper {
        public String Id;
        public String Name;
        public Boolean IsDefault;
        
        public CategoryWrapper(Category__c categoryRec) {
            this.Id = categoryRec.Id;
            this.Name = categoryRec.Name;
            this.IsDefault = categoryRec.Default__c;
        }
    }
}