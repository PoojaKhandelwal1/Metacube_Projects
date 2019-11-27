public class IFW_IntegrationConfigDTO {
    public String Id{get; set;}
    public String CS_Id{get; set;}
    public String SubscriberRecordId{get; set;}
    public String AccessToken{get; set;}
    public String AuthScheme{get; set;}
    public String BearerToken{get; set;}
    public String CertificatePassword{get; set;}
    public String CertificateName{get; set;}
    public String ConsumerKey{get; set;}
    public String ConsumerSecret{get; set;}
    public Boolean IsEnabled{get; set;}
    public String GrantType{get; set;}
    public String IntegrationName{get; set;}
    public String OrgId{get; set;}
    public String Password{get; set;}
    public String RefreshToken{get; set;}
    public Decimal Timeout{get; set;}
    public Decimal TokenExpiry{get; set;}
    public String TokenType{get; set;}
    public String Username{get; set;}
    public List<IFW_IntegrationConfigItemDTO> IntegrationConfigurationItems;
    public Boolean IsMaster{get; set;}
    
    public IFW_IntegrationConfigDTO() {}
    
    public IFW_IntegrationConfigDTO(IFW_IntegrationConfig__c integrationConfig) {
        this.CS_Id = integrationConfig.Id;
        this.SubscriberRecordId = integrationConfig.Subscriber_Rec_Id__c;
        this.AccessToken = integrationConfig.Access_Token__c;
        this.AuthScheme = integrationConfig.Auth_Scheme__c;
        this.BearerToken = integrationConfig.Bearer_Token__c;
        this.CertificatePassword = integrationConfig.Certifcate_Password__c;
        this.CertificateName = integrationConfig.Certificate_Name__c;
        this.ConsumerKey = integrationConfig.Consumer_Key__c;
        this.ConsumerSecret = integrationConfig.Consumer_Secret__c;
        this.IsEnabled = integrationConfig.Enabled__c;
        this.GrantType = integrationConfig.Grant_Type__c;
        this.IntegrationName = integrationConfig.Integration_Name__c;
        this.OrgId = integrationConfig.Org_Id__c;
        this.Password = integrationConfig.Password__c;
        this.RefreshToken = integrationConfig.Refresh_Token__c;
        this.Timeout = integrationConfig.Timeout__c;
        this.TokenExpiry = integrationConfig.Token_Expiry__c;
        this.TokenType = integrationConfig.Token_Type__c;
        this.Username = integrationConfig.Username__c;
        this.IsMaster = integrationConfig.Is_Master__c;
    }
    
    public static IFW_IntegrationConfig__c getSObjectFromDTO(IFW_IntegrationConfigDTO configDTO) {
        IFW_IntegrationConfig__c configurationRec = new IFW_IntegrationConfig__c();
        //if (configDTO.Id != null) configurationRec.Id = configDTO.Id;
        if (configDTO.SubscriberRecordId != null) configurationRec.Subscriber_Rec_Id__c = configDTO.SubscriberRecordId;
        if (configDTO.AccessToken != null) configurationRec.Access_Token__c = configDTO.AccessToken;
        if (configDTO.AuthScheme != null) configurationRec.Auth_Scheme__c = configDTO.AuthScheme;
        if (configDTO.BearerToken != null) configurationRec.Bearer_Token__c = configDTO.BearerToken;
        if (configDTO.CertificatePassword != null) configurationRec.Certifcate_Password__c = configDTO.CertificatePassword;
        if (configDTO.CertificateName != null) configurationRec.Certificate_Name__c = configDTO.CertificateName;
        if (configDTO.ConsumerKey != null) configurationRec.Consumer_Key__c = configDTO.ConsumerKey;
        if (configDTO.ConsumerSecret != null) configurationRec.Consumer_Secret__c = configDTO.ConsumerSecret;
        if (configDTO.IsEnabled != null) configurationRec.Enabled__c = configDTO.IsEnabled;
        if (configDTO.GrantType != null) configurationRec.Grant_Type__c = configDTO.GrantType;
        if (configDTO.IntegrationName != null) configurationRec.Integration_Name__c = configDTO.IntegrationName;
        if (configDTO.Password != null) configurationRec.Password__c = configDTO.Password;
        if (configDTO.RefreshToken != null) configurationRec.Refresh_Token__c = configDTO.RefreshToken;
        if (configDTO.Timeout != null) configurationRec.Timeout__c = configDTO.Timeout;
        if (configDTO.TokenExpiry != null) configurationRec.Token_Expiry__c = configDTO.TokenExpiry;
        if (configDTO.TokenType != null) configurationRec.Token_Type__c = configDTO.TokenType;
        if (configDTO.Username != null) configurationRec.Username__c = configDTO.Username;
        return configurationRec;
    }
    public static List<String> fieldAPINames(){
        List<String> integrationConfigurationFields = new List<String>{ 
                                                            'Id',
                                                            'Access_Token__c',
                                                            'Auth_Scheme__c',
                                                            'Subscriber_Rec_Id__c',
                                                            'Bearer_Token__c',
                                                            'Certifcate_Password__c',
                                                            'Certificate_Name__c',
                                                            'Consumer_Key__c',
                                                            'Consumer_Secret__c',
                                                            'Enabled__c',
                                                            'Grant_Type__c',
                                                            'Integration_Name__c',
                                                            'Org_Id__c',
                                                            'Password__c',
                                                            'Refresh_Token__c',
                                                            'Timeout__c',
                                                            'Token_Expiry__c',
                                                            'Token_Type__c',
                                                            'Username__c',
                                                            'Is_Master__c'
                                                         };
        return integrationConfigurationFields;
    }
}