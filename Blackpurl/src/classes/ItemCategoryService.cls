public with sharing class ItemCategoryService {
    public static List<Log__c> errorLogToInsert;
    
    public static void syncItemCategories(Set<Id> itemCategoryIds){
        AccSync_ItemCategory_Batch.runItemCategoriesForSync(itemCategoryIds, 10);
    }
       
    public static List<Log__c> syncAccountingServer(List<AccountingItemCategory> categoryObj, List<Category__c> categoryListToUpdate) {
        errorLogToInsert = new List<Log__c>();
        if(QBUtil.isQBEnabled()){
            syncToQuickBooks(categoryObj, categoryListToUpdate);
        }
        return errorLogToInsert;
    }
      
    public static void syncToQuickBooks(List<AccountingItemCategory> categoryObjList, List<Category__c> categoryListToUpdate) {
        if(categoryObjList == null || categoryObjList.size() == 0) {
            return;
        }
        Category__c categoryRec = new Category__c();
        categoryRec.Id = categoryObjList[0].Id;
        try {
            QuickBooksItemCategory itemInfo = null;
            if(String.isNotBlank(categoryObjList[0].AccountingId)) {
                itemInfo = getItemFromQB(categoryObjList[0]);
            }
            categoryRec = setItemInfoToBP(categoryRec, itemInfo, categoryObjList[0]);
            categoryRec = syncCategoryToQB(new List<Category__c>{categoryRec}, categoryObjList[0]);
        } catch(Exception e) {
            categoryRec.availForQBSync__c = true;
            categoryRec.AccountingResponse__c = e.getMessage();
            errorLogToInsert.add(new LogService().createErrorLog('ItemCategoryService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              categoryObjList[0] + LogService.METHOD_PARAM_SEPERATOR + categoryListToUpdate, LogService.QUICKBOOKS, false));
        }
        if(categoryListToUpdate.size() > QBUtil.MAX_RECORDS_UPDATE_LIMIT){
            AccSync_ItemCategory_Batch.updateItemCategories(categoryListToUpdate);
            categoryListToUpdate = new List<Category__c>();
        }
        categoryListToUpdate.add(categoryRec); 
     } 
     
    private static QuickBooksItemCategory getItemFromQB(AccountingItemCategory categoryObj) {
        String query = 'SELECT Id FROM Item Where Id = \'' + categoryObj.AccountingId + '\'';
        query = EncodingUtil.urlEncode(query, 'UTF-8').replaceAll('\\+','%20');
        HttpResponse res = QuickbookConnector.getRequestFromQuickBooks('query?query='+query, null);
        system.debug('######' + res.getBody());
        ResponseQuickBooksItemCategory itemInfo;
        if(res.getStatusCode() == 200) {
            String accountingId;
            QueryResponseWrapper itemInfoObj = (QueryResponseWrapper) system.JSON.deserialize(res.getBody(), QueryResponseWrapper.class);
            if(itemInfoObj.QueryResponse != null && itemInfoObj.QueryResponse.Item != null && itemInfoObj.QueryResponse.Item.size() > 0) {
                accountingId = itemInfoObj.QueryResponse.Item[0].Id;
            }
            
            if(String.isNotBlank(accountingId)) {
                res = QuickbookConnector.getRequestFromQuickBooks('item', accountingId);
                system.debug('###332###' + res.getBody());
                if(res.getStatusCode() == 200) {
                    itemInfo = (ResponseQuickBooksItemCategory) System.JSON.deserialize(res.getBody(), ResponseQuickBooksItemCategory.class);
                    if(itemInfo != null && itemInfo.Item != null) {
                        itemInfo.Item.Id = accountingId;
                    }
                }
            }
        } else {
            errorLogToInsert.add(new LogService().createErrorLog('ItemCategoryService', 'getItemFromQB() - read item category', res.getBody(), res.getStatusCode(), null, 
                                              categoryObj + LogService.METHOD_PARAM_SEPERATOR, LogService.QUICKBOOKS, false));
        }
        return ((itemInfo != null) ? itemInfo.Item : null);
    }
    
    public static Category__c setItemInfoToBP(Category__c categoryRec, QuickBooksItemCategory ItemWrapperObj, AccountingItemCategory categoryObj) {
        if(ItemWrapperObj != null) {
            categoryRec.AccountingId__c = ItemWrapperObj.Id;
            //categoryRec.COGS_GL__c = (categoryObj.ExpenseAccountRef.Id != null) ? categoryObj.ExpenseAccountRef.Id : (ItemWrapperObj.ExpenseAccountRef != null && ItemWrapperObj.ExpenseAccountRef.value != null ? ItemWrapperObj.ExpenseAccountRef.value : '');
            //categoryRec.Income_GL__c = (categoryObj.IncomeAccountRef.Id != null) ? categoryObj.IncomeAccountRef.Id : (ItemWrapperObj.IncomeAccountRef != null && ItemWrapperObj.IncomeAccountRef.value != null ? ItemWrapperObj.IncomeAccountRef.value : '');
            //categoryRec.Inventory_GL__c = (categoryObj.AssetAccountRef.Id != null) ? categoryObj.AssetAccountRef.Id : (ItemWrapperObj.AssetAccountRef != null && ItemWrapperObj.AssetAccountRef.value != null ? ItemWrapperObj.AssetAccountRef.value : '');
            categoryRec.SyncToken__c = ItemWrapperObj.SyncToken;
        }
        return categoryRec;
    }
    
    public static Category__c syncCategoryToQB(List<Category__c> categoryRecList, AccountingItemCategory categoryObj) {
        if(categoryRecList == null || categoryRecList.size() == 0) {
            return new Category__c();
        }
        categoryObj.AccountingId = (categoryRecList[0].AccountingId__c != null) ? categoryRecList[0].AccountingId__c : categoryObj.AccountingId;
        categoryObj.SyncToken = categoryRecList[0].SyncToken__c;
        QuickBooksItemCategory itemObj_QB = new QuickBooksItemCategory(categoryObj);
        String itemJSONBody = system.JSON.serialize(itemObj_QB, true);
        categoryRecList[0].AccountingResponse__c = itemJSONBody;
            
        HttpResponse response = QuickbookConnector.sendRequestToQuickBooks('item?minorversion=4', itemJSONBody);
        system.debug(response);
        if(response.getStatusCode() == 200) { 
            String resParams = response.getBody();
            ResponseQuickBooksItemCategory itemResObj = (ResponseQuickBooksItemCategory) system.JSON.deserialize(resParams, ResponseQuickBooksItemCategory.class);
            
            categoryRecList[0].AccountingId__c = itemResObj.Item.Id;
            categoryRecList[0].SyncToken__c = itemResObj.Item.SyncToken;
            categoryRecList[0].availForQBSync__c = false;
            categoryRecList[0].accountingLastSyncTime__c = system.now();
            categoryRecList[0].QB_Updated_Fields__c = null;
        } else {
            errorLogToInsert.add(new LogService().createErrorLog('ItemCategoryService', 'syncCategoryToQB() - save request', response.getBody(), response.getStatusCode(), null, 
                                              categoryRecList[0] + LogService.METHOD_PARAM_SEPERATOR + categoryObj, LogService.QUICKBOOKS, false));
        }
        categoryRecList[0].AccountingResponse__c += '\n\n' + response.getBody() + '\n\n' + response.getStatusCode();
        
        return categoryRecList[0];
    }
    
    public class QueryResponseWrapper {
        public ItemQueryResponseWrapper QueryResponse;
    }
    
    public class ItemQueryResponseWrapper{
        public List<QuickBooksItemCategory> Item;
        
    }
    public class ResponseQuickBooksItemCategory {
        public QuickBooksItemCategory item;
    }
    
    // Quickbooks Item Category wrapper
    public class QuickBooksItemCategory {
        public String Id;
        public String SyncToken; 
        public String Name;
        public String Description;
        public Boolean Active;
        public String Type;
        public Boolean sparse;
        public QuickBooksCategoryAccountRefWrapper IncomeAccountRef;
        public QuickBooksCategoryAccountRefWrapper ExpenseAccountRef;
        public QuickBooksCategoryAccountRefWrapper AssetAccountRef;
        
        public QuickBooksItemCategory(AccountingItemCategory categoryObj) {
            String updatedFields = categoryObj.QBUpdatedField;
            this.Id = categoryObj.AccountingId;
            this.SyncToken = categoryObj.SyncToken;
            this.sparse = true;
            
            if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && (updatedFields.contains('Name') || updatedFields.contains('Type__c'))) || String.isBlank(categoryObj.AccountingId) ) {
                this.Name = (categoryObj.CategoryName != null && categoryObj.CategoryName.length() > 80) ? categoryObj.CategoryName.substring(0,80) : 
                              categoryObj.CategoryName;
                this.Name = this.Name + ' [' + categoryObj.Type + ']';
                
                if(categoryObj.Type == 'Labour' || categoryObj.Type == 'Internal Expense') {
                    this.Type = 'Service'; 
                } else {
                    this.Type = 'NonInventory'; 
                }
            }
            
            if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Description__c'))) {
                this.Description = categoryObj.Description; 
                if(String.isNotBlank(this.Description) && this.Description.trim().length() > 4000) {
                    this.Description = this.Description.substring(0, 4000);
                }
            }
            if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Active__c'))) {
                this.Active = categoryObj.Active;
            }
            if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Income_GL__c'))) {
                this.IncomeAccountRef = new QuickBooksCategoryAccountRefWrapper(categoryObj.IncomeAccountRef);
            }
            if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('COGS_GL__c'))) {
                this.ExpenseAccountRef = new QuickBooksCategoryAccountRefWrapper(categoryObj.ExpenseAccountRef);
            }
            if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Inventory_GL__c'))) {
                this.AssetAccountRef = new QuickBooksCategoryAccountRefWrapper(categoryObj.AssetAccountRef);
            }
        }
    }
     
    public class QuickBooksCategoryAccountRefWrapper {
        public String value;
        public QuickBooksCategoryAccountRefWrapper(AccountingItemCategory.AccountRefWrapper accountRef) {
            this.value = accountRef.Id;
        }
    }
}