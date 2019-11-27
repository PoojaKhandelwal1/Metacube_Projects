public class AddEditTechnicianScheduleService {

    public static TechnicianDetailWrapper getTechnicianById(String technicianRecId) {
    	if(AccessControl.ifObjectFieldIsAccessible('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Technician__c> technicianRecList = SOQLUtil.getTechnicianListByFieldName(new Map<String, String>{'Id' => technicianRecId, 'Type__c' => 'Technician'});
        TechnicianDetailWrapper technicianDetailObj;
        if(technicianRecList.size() > 0) {
        	technicianDetailObj = new TechnicianDetailWrapper(technicianRecList[0]);
        }
        return technicianDetailObj;
    }
    
    public static void saveTechnicianDetail(String technicianDetailJSON) {
    	if(AccessControl.ifObjectFieldIsCreateable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        //system.assert(false, technicianDetailJSON);
        TechnicianDetailWrapper technicianDetailObj = (TechnicianDetailWrapper)System.JSON.deserialize(technicianDetailJSON, TechnicianDetailWrapper.class);
        
        Technician__c technicianRec = new Technician__c(Id = technicianDetailObj.Id);
        technicianRec.Role__c = technicianDetailObj.Role;
        technicianRec.Working_Days__c = technicianDetailObj.WorkingDays;
        upsert technicianRec;
    }
    
    public static List<LeaveWrapper> getTechnicianLeavesByTechnicianId(String technicianRecId) {
    	if(AccessControl.ifObjectFieldIsAccessible('Leave__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Leave__c> leaveList = SOQLUtil.getTechnicianLeavesByTechnicianId(new Set<String>{technicianRecId});
        List<LeaveWrapper> leaveObjList = new List<LeaveWrapper>();
    	for(Leave__c leaveRec : leaveList) {
    		leaveObjList.add(new LeaveWrapper(leaveRec));
    	}
        return leaveObjList;
    }
    
    public static LeaveWrapper saveLeaveDetail(String leaveJSON) {
    	if(AccessControl.ifObjectFieldIsCreateable('Leave__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Leave__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        LeaveWrapper leaveDetailObj = (LeaveWrapper)System.JSON.deserialize(leaveJSON, LeaveWrapper.class);
    	Leave__c leaveRec = new Leave__c(Id = leaveDetailObj.Id);
    	leaveRec.Name = leaveDetailObj.Type;
    	leaveRec.Technician__c = leaveDetailObj.TechnicianId;
    	leaveRec.From__c = DateTimeUtility.getConvertedDateTime(leaveDetailObj.FromDate, leaveDetailObj.FromTime);
    	leaveRec.To__c = DateTimeUtility.getConvertedDateTime(leaveDetailObj.ToDate, leaveDetailObj.ToTime);
    
        upsert leaveRec;
        return new LeaveWrapper(leaveRec);
    }
    
    public static void deleteLeave(String leaveId) {
    	if(AccessControl.ifObjectIsDeletable('Leave__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        delete new Leave__c(Id = leaveId);
    }
}