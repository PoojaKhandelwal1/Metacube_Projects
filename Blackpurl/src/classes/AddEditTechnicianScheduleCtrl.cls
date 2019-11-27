global class AddEditTechnicianScheduleCtrl {
	
	global AddEditTechnicianScheduleCtrl (NewHomePageCtrl controller){}
    public AddEditTechnicianScheduleCtrl() {}
    
    @RemoteAction
    global static String getMasterData() {
        try {
        	List<String> workingDays = AccountSettingService.getShopWorkingDays();
	        return BPUtility.getEncodedString(System.JSON.serialize(workingDays, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
	@RemoteAction
    global static String getTechnicianById(String technicianRecId) {
    	technicianRecId = BPUtility.getDecodedString(technicianRecId);
        try {
        	TechnicianDetailWrapper technicianObj = AddEditTechnicianScheduleService.getTechnicianById(technicianRecId);
	        return BPUtility.getEncodedString(System.JSON.serialize(technicianObj, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String saveTechnicianDetail(String technicianDetailJSON) {
    	technicianDetailJSON = BPUtility.getDecodedString(technicianDetailJSON);
        try {
	        AddEditTechnicianScheduleService.saveTechnicianDetail(technicianDetailJSON);
            return BPUtility.getEncodedString('SUCCESS');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getTechnicianLeavesByTechnicianId(String technicianRecId) {
    	technicianRecId = BPUtility.getDecodedString(technicianRecId);
        try {
        	List<LeaveWrapper> leaveObjList = AddEditTechnicianScheduleService.getTechnicianLeavesByTechnicianId(technicianRecId);
	        return BPUtility.getEncodedString(System.JSON.serialize(leaveObjList, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String saveLeaveDetail(String leaveJSON) {
    	leaveJSON = BPUtility.getDecodedString(leaveJSON);
        try {
        	LeaveWrapper leaveDetailObj = AddEditTechnicianScheduleService.saveLeaveDetail(leaveJSON);
        	return BPUtility.getEncodedString(System.JSON.serialize(leaveDetailObj, true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String deleteLeave(String leaveId) {
    	leaveId = BPUtility.getDecodedString(leaveId);
        try {
        	AddEditTechnicianScheduleService.deleteLeave(leaveId);
        	return BPUtility.getEncodedString('SUCCESS');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
}