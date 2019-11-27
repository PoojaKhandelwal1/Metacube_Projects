/** 
* Author: Richa Mittal <richa.mittal@metacube.com>
* Since: Dec 13, 2018 
* Name: CashDrawerCtrl
* Description: Apex class which contains all remoted methods related to cash Drawer
**/
global with sharing class CashDrawerCtrl {
    public CashDrawerCtrl() {}
    global CashDrawerCtrl(NewHomePageCtrl controller) {} 
    
    @RemoteAction
    global static String getAllCashDrawerList() {
        try {
            List<CashDrawerWrapper> cashDrawerObjList = CashDrawerService.getAllCashDrawerList();
            return BPUtility.getEncodedString(system.JSON.serialize(cashDrawerObjList, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String saveCashDrawer(String cashDrawerJson) {
        cashDrawerJson = BPUtility.getDecodedString(cashDrawerJson);
        try {
            return CashDrawerService.saveCashDrawer(cashDrawerJson);
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String deleteCashDrawer(String cashDrawerId) {
        cashDrawerId = BPUtility.getDecodedString(cashDrawerId);
        try {
            return CashDrawerService.deleteCashDrawer(cashDrawerId);
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String isCashDrawerCanBeDeleted(String cashDrawerId) {
        cashDrawerId = BPUtility.getDecodedString(cashDrawerId);
        try {
            return CashDrawerService.isCashDrawerCanBeDeleted(cashDrawerId);
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String isCashDrawerCanBeInactive(String cashDrawerJson) {
        cashDrawerJson = BPUtility.getDecodedString(cashDrawerJson);
        CashDrawerWrapper cashDrawerObj = (CashDrawerWrapper)System.JSON.deserialize(cashDrawerJson, CashDrawerWrapper.class);
        try {
            Boolean isCashDrawerCanBeInactive = CashDrawerService.isCashDrawerCanBeInactive(cashDrawerObj);
            return BPUtility.getEncodedString('{"isInactiveAllowed" : ' + isCashDrawerCanBeInactive + '}');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
}