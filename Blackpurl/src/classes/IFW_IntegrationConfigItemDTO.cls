public class IFW_IntegrationConfigItemDTO {
    public String Id {get; set;}
    public String CS_Id {get; set;}
    public String EndpointURL {get; set;}
    public Decimal Timeout {get; set;}
    public String HttpActionMethod {get; set;}
    public String SubscriberRecordId {get; set;}
    public String EntityAction {get; set;}
    public String EntityName {get; set;}
    
    public IFW_IntegrationConfigItemDTO() {}
    
    public IFW_IntegrationConfigItemDTO(IFW_IntegrationConfigItem__c integrationConfigItem ) {
        this.Id = integrationConfigItem.Id;
        this.EndpointURL = integrationConfigItem.Endpoint_URL__c;
        this.Timeout = integrationConfigItem.Timeout__c;
        this.HttpActionMethod = integrationConfigItem.HTTP_Method__c;
        this.SubscriberRecordId = integrationConfigItem.Subscriber_Record_Id__c;
        this.EntityAction = integrationConfigItem.Entity_Action__c;
        this.EntityName = integrationConfigItem.Entity_Name__c;
    }
    public static IFW_IntegrationConfigItem__c getSObjectFromDTO(IFW_IntegrationConfigItemDTO configDTO) {
        IFW_IntegrationConfigItem__c configurationRec = new IFW_IntegrationConfigItem__c();
        if (configDTO.Id != null) configurationRec.Id = configDTO.Id;
        if (configDTO.SubscriberRecordId != null) configurationRec.Subscriber_Record_Id__c = configDTO.SubscriberRecordId;
        if (configDTO.EndpointURL != null) configurationRec.Endpoint_URL__c = configDTO.EndpointURL;
        if (configDTO.HttpActionMethod != null) configurationRec.HTTP_Method__c = configDTO.HttpActionMethod;
        if (configDTO.Timeout != null) configurationRec.Timeout__c = configDTO.Timeout;
        if (configDTO.EntityAction != null) configurationRec.Entity_Action__c = configDTO.EntityAction;
        if (configDTO.EntityName != null) configurationRec.Entity_Name__c = configDTO.EntityName;
        return configurationRec;
    }
    public static List<String> fieldAPINames(){
        return new List<String>{ 'Endpoint_URL__c', 
            'Timeout__c', 
            'HTTP_Method__c',
            'Subscriber_Record_Id__c',
            'Entity_Name__c',
            'Entity_Action__c'};
    }
}