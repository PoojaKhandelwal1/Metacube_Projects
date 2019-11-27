public class sendNativeEmailQueue implements Queueable, Database.AllowsCallouts {
    List<NativeEmailMessage> nativeEmailMessageList;
    public sendNativeEmailQueue(List<NativeEmailMessage> nativeEmailMessageList) {
        this.nativeEmailMessageList = nativeEmailMessageList;
    }
    public void execute(QueueableContext context) {
        RingDNAApiCallouts ringDNAApiCallout = new RingDNAApiCallouts(true);
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Messaging.MassEmailMessage> sfdcEmailMessageList = New List<Messaging.MassEmailMessage>();        
        List<NativeEmailRespose> nativeEmailResposeList = new List<NativeEmailRespose>();
        try{
            system.debug('nativeEmailMessageList in queable ' + nativeEmailMessageList.size());
            nativeEmailResposeList = ringDNAApiCallout.sendNativeMassEmail(nativeEmailMessageList);    
        }catch(exception ex){
            for(NativeEmailMessage nativeEmailMessage : nativeEmailMessageList ){
                sfdcEmailMessageList.add(CadenceService.createEmailMessage(nativeEmailMessage.ParticipantId, nativeEmailMessage.TemplateId));
            }
        }
        // Create map of actionId and nativeEmailMessage
        Map<Id, NativeEmailMessage> actionIdNativeEmailMessageMap = new Map<Id, NativeEmailMessage>();
        for(NativeEmailMessage nativeEmailMessage : nativeEmailMessageList ){
            actionIdNativeEmailMessageMap.put(NativeEmailMessage.ActionId, NativeEmailMessage);
        }
        if (nativeEmailResposeList != null && nativeEmailResposeList.size() > 0 ) {
            for (NativeEmailRespose nativeEmailRespose : nativeEmailResposeList){
                if (nativeEmailRespose.success == false){
                    NativeEmailMessage nativeEmailMessage = actionIdNativeEmailMessageMap.get(nativeEmailRespose.actionId);
                    sfdcEmailMessageList.add(CadenceService.createEmailMessage(nativeEmailMessage.ParticipantId, nativeEmailMessage.TemplateId));                    
                }
            }
        }
        if(sfdcEmailMessageList.isEmpty() == false) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(sfdcEmailMessageList, false);
        }    
    }
}