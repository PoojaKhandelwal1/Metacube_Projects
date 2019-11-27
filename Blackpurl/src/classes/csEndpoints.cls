@RestResource(urlMapping='/csEndpoints/*')
   global with sharing class csEndpoints {


      @Httppost
      global static void createSetting( ) {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;

 
        Blob body = req.requestBody;

        string body1 =body.toString();
        //system.debug('request Body: '+body1);





        try {

           List<IFW_IntegrationConfigDTO> responseConfigDTO = new List<IFW_IntegrationConfigDTO>();

 
            List<IFW_IntegrationConfigDTO> wrapperList = parseList(body1);
            List<IFW_IntegrationConfig__c> configList = new List<IFW_IntegrationConfig__c>(); 
            List<IFW_IntegrationConfigItem__c> configItemList = new List<IFW_IntegrationConfigItem__c>(); 
            //system.debug ('Config List: '+configList);
            for(IFW_IntegrationConfigDTO dto : wrapperList) {
                
               IFW_IntegrationConfig__c c = new IFW_IntegrationConfig__c();
               if(dto.Id!=null) c.CS_Id__c = dto.Id;
               if(dto.SubscriberRecordId!=Null) c.id = dto.SubscriberRecordId;
               if(dto.AccessToken!=Null) c.Access_Token__c = dto.AccessToken;
               if(dto.AuthScheme!=Null) c.Auth_Scheme__c = dto.AuthScheme;
               if(dto.BearerToken!=Null) c.Bearer_Token__c = dto.BearerToken;
               if(dto.CertificatePassword!=Null) c.Certifcate_Password__c = dto.CertificatePassword;
               if(dto.CertificateName!=Null) c.Certificate_Name__c = dto.CertificateName;
               if(dto.ConsumerKey!=Null) c.Consumer_Key__c = dto.ConsumerKey;
               if(dto.ConsumerSecret!=Null) c.Consumer_Secret__c = dto.ConsumerSecret;
               if(dto.IsEnabled!=Null) c.Enabled__c = dto.IsEnabled;
               if(dto.GrantType!=Null) c.Grant_Type__c = dto.GrantType;
               if(dto.IntegrationName!=Null) c.Integration_Name__c = dto.IntegrationName;
               if(dto.IsMaster!=Null) c.Is_Master__c = dto.IsMaster;
               if(dto.OrgId!=Null) c.Org_Id__c = dto.OrgId;
               if(dto.Password!=Null) c.Password__c = dto.Password;
               if(dto.RefreshToken!=Null) c.Refresh_Token__c = dto.RefreshToken;
               if(dto.SubscriberRecordId!=Null) c.Subscriber_Rec_Id__c = dto.SubscriberRecordId;
               if(dto.Timeout!=Null) c.Timeout__c = dto.Timeout;
               if(dto.TokenExpiry!=Null) c.Token_Expiry__c = dto.TokenExpiry;
               if(dto.TokenType!=Null) c.Token_Type__c = dto.TokenType;
               if(dto.Username!=Null) c.Username__c = dto.Username;
               configList.add(c);





               if (dto.IntegrationConfigurationItems!=null) {
                   for (IFW_IntegrationConfigItemDTO dtoi: dto.IntegrationConfigurationItems){
                     if (c.Id!= null) {   
                        IFW_IntegrationConfigItem__c i = new IFW_IntegrationConfigItem__c();
                        if(c.id!=null) i.IFW_IntegrationConfig__c = c.Id;
                        if(dtoi.Id!=null) i.CS_Id__c = dtoi.Id;
                        if(dtoi.SubscriberRecordId!=Null) i.id = dtoi.SubscriberRecordId;
                        if (dtoi.EndpointURL!=null) i.Endpoint_URL__c = dtoi.EndpointURL;
                        if (dtoi.HttpActionMethod!=null) i.HTTP_Method__c = dtoi.HttpActionMethod;
                        if (dtoi.SubscriberRecordId!=null) i.Subscriber_Record_Id__c = dtoi.SubscriberRecordId;
                        if (dtoi.Timeout!=null) i.Timeout__c = dtoi.Timeout;
                        if (dtoi.EntityAction!=null) i.Entity_Action__c = dtoi.EntityAction;
                        if (dtoi.EntityName!=null) i.Entity_Name__c = dtoi.EntityName;
                        configItemList.add(i);

                     } else {
                        RestContext.response.statusCode = 500;
                        SalesforceError[] errs = new SalesforceError[]{ 
                            new SalesforceError('BAD_REQUEST', 'You must include a parent Id when inserting Config Line Items')
                        };
                        res.responseBody = Blob.valueOf(JSON.serialize(errs));
                     }
                   }
               
               }
            }
            upsert configList;

            //system.debug('configItemList'+configItemList);
            if (configItemList.size()>0) upsert configItemList;
            
            for (IFW_IntegrationConfig__c resIC : configList) {
                IFW_IntegrationConfigDTO resICItem = new IFW_IntegrationConfigDTO();
                resICItem.Id = resIC.CS_Id__c;
                resICItem.SubscriberRecordId = resIC.Id;
                if (resIC.Enabled__c != null) resICItem.IsEnabled = resIC.Enabled__c;
                resICItem.OrgId = UserInfo.getOrganizationId();
                resICItem.IntegrationConfigurationItems = new List<IFW_IntegrationConfigItemDTO>();
                 for (IFW_IntegrationConfigItem__c resICLI : configItemList) {
                    IFW_IntegrationConfigItemDTO resICLIItem = new IFW_IntegrationConfigItemDTO();
                    resICLIItem.SubscriberRecordId = resICLI.Id;
                    resICLIItem.Id = resICLI.CS_Id__c;
                    //system.debug(resICItem.IntegrationConfigurationItems);
                   resICItem.IntegrationConfigurationItems.add(resICLIItem);
                }
                responseConfigDTO.add(resICItem);
            }


            if (res.responseBody == null && responseConfigDTO.size() > 0) {
                res.responseBody = Blob.valueOf(json.serialize(responseConfigDTO));

            }

            } catch(System.StringException e){
               RestContext.response.statusCode = 400;
               SalesforceError[] errs = new SalesforceError[]{ 
                 new SalesforceError('BAD_REQUEST', 'Param: ParentId or ChildId is not a valid Id')
               };
               res.responseBody = Blob.valueOf(JSON.serialize(errs));

            } catch(Exception e){ //something else happened
               RestContext.response.statusCode = 500;
               SalesforceError[] errs = new SalesforceError[]{ 
                 new SalesforceError('BAD_REQUEST', 'Line '+e.getLineNumber() + ': '+e.getMessage())
               };
               res.responseBody = Blob.valueOf(JSON.serialize(errs));
            }


        }


    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: IntegrationSettingsWrapper.ParentWrapper - Class Object
    **/
    public static List<IFW_IntegrationConfigDTO> parseList(String jsonString) {

        List<IFW_IntegrationConfigDTO> itemList = 
            new List<IFW_IntegrationConfigDTO>();
        JSONParser parser = JSON.createParser(jsonString);
        while(parser.nextToken() != null){
                while(parser.nextToken()!= null){
                    if(parser.getCurrentToken()==JSONToken.START_OBJECT){
                        IFW_IntegrationConfigDTO s = (IFW_IntegrationConfigDTO) parser.readValueAs(IFW_IntegrationConfigDTO.class);
                        itemList.add(s);
                    }
                }
            }


         return itemList;
    }


    //standard salesforce error response structure
    public class SalesforceError {
       public String errorCode;
       public String message;
       public SalesforceError(String errorCode, string message){
          this.errorCode = errorCode;
          this.message = message;
       }
    }



   }