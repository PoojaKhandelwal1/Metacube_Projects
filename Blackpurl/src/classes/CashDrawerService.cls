public with sharing class CashDrawerService {
    public static List<CashDrawerWrapper> getAllCashDrawerList() {
        List<Cash_Drawer__c> cashDrawerList = CashDrawerSOQLUtil.getAllCashDrawerList(true);
        List<CashDrawerWrapper> cashDrawerObjList = new List<CashDrawerWrapper>();
        for(Cash_Drawer__c cashDrawerRec: cashDrawerList) {
            cashDrawerObjList.add(new CashDrawerWrapper(cashDrawerRec));
        }
        return cashDrawerObjList;
    }
    
    public static List<CashDrawerWrapper> getActiveCashDrawerList() {
        List<Cash_Drawer__c> cashDrawerList = CashDrawerSOQLUtil.getAllCashDrawerList(false);
        List<CashDrawerWrapper> cashDrawerObjList = new List<CashDrawerWrapper>();
        for(Cash_Drawer__c cashDrawerRec: cashDrawerList) {
            cashDrawerObjList.add(new CashDrawerWrapper(cashDrawerRec));
        }
        return cashDrawerObjList;
    }
    
    public static String saveCashDrawer(String cashDrawerJson) {
        CashDrawerWrapper cashDrawerObj = (CashDrawerWrapper) System.JSON.deserialize(cashDrawerJson, CashDrawerWrapper.class);
        Cash_Drawer__c cashDrawerRec = new Cash_Drawer__c();
        cashDrawerRec.Id = cashDrawerObj.Id;
        cashDrawerRec.Name = cashDrawerObj.CashDrawerName;
        cashDrawerRec.Active__c = cashDrawerObj.IsActive;
        if(validateDuplicateCashDrawerName(cashDrawerRec)) {
            if(AccessControl.ifObjectIsCreateable('Cash_Drawer__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Cash_Drawer__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(String.isNotBlank(cashDrawerRec.Id) && !cashDrawerRec.Active__c) {
                if(isCashDrawerCanBeInactive(cashDrawerObj)) {
                    upsert cashDrawerRec;
                    return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('success', 'success')));
                } else {
                    return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'Cash drawer has unreconciled payment entries, So can not be made inactive')));
                }
            }
            upsert cashDrawerRec;
            return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('success', 'success')));
        } else {
            return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'Duplicate cash drawer name')));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('success', 'success')));
    }
    
    public static String deleteCashDrawer(String cashDrawerId) {
        Cash_Drawer__c cashDrawerRec = new Cash_Drawer__c(Id = cashDrawerId);
        if(AccessControl.ifObjectIsDeletable('Cash_Drawer__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        delete cashDrawerRec;
        return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('success', 'success')));
    }
    
    private static Boolean validateDuplicateCashDrawerName(Cash_Drawer__c cashDrawerRec) {
        List<Cash_Drawer__c> cashDrawerList = CashDrawerSOQLUtil.getAllCashDrawerList(true);
        for(Cash_Drawer__c cashDrawer: cashDrawerList) {
            if(String.isNotBlank(cashDrawerRec.Id) && (cashDrawer.Id).equals(cashDrawerRec.Id)) {
                continue;
            }
            if((cashDrawer.Name).equalsIgnoreCase(cashDrawerRec.Name)) {
                return false;
            }
        }
        return true;
    }
    
    public static String isCashDrawerCanBeDeleted(String cashDrawerId) {
        List<CO_Invoice_Payment__c> paymentList = [SELECT Id FROM CO_Invoice_Payment__c WHERE Cash_Drawer__c = :cashDrawerId];
        List<CO_Deposit__c> depositList = [SELECT Id FROM CO_Deposit__c WHERE Cash_Drawer__c = :cashDrawerId];
        if(paymentList.size() == 0 && depositList.size() == 0) {
            return BPUtility.getEncodedString('{"isDeleteAvailable" : true}'); 
        }
        return BPUtility.getEncodedString('{"isDeleteAvailable" : false}');
    }
    
    public static Boolean isCashDrawerCanBeInactive(CashDrawerWrapper cashDrawerObj) {
        List<Cash_Reconciliation_Payment__c> cashReconciliationPaymentList = [SELECT Id FROM Cash_Reconciliation_Payment__c WHERE  Cash_Drawer_Reconciliation__r.Cash_Drawer__r.Name = :cashDrawerObj.CashDrawerName AND Cash_Reconciliation__r.Status__c != 'Reconciled'];
        if(cashReconciliationPaymentList.size() > 0) {
            return false;
        }
        return true;
    }
}