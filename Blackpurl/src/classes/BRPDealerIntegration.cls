global with sharing class BRPDealerIntegration {

  
    public static String DealerId = BRPUtility.getDealerId();
    
    @future(callout=true)
    global static void getDealerLocator() {
        if(AccessControl.ifObjectIsCreateable('BRP_Dealers__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); } 

        String returnStr = '';
        //String endPoint = 'http://services.motiveintegrator.com/PDS/services/DealerLocator/Get';

        String endPoint = BRPUtility.getEndpoint()+'/facade/star/services/DealerLocator/Get';

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', BRPUtility.contentType);
        req.setHeader('Accept-Language', 'en-US');
        req.setHeader('Accept-Charset', 'UTF-8');
        req.setCompressed(true);
        //req.setHeader('Content-Encoding', 'gzip');
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('User-Agent','Apache-HttpClient/4.1.1 (java 1.5)');

        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('Accept', BRPUtility.contentType);

        String username = 'BLACKPURL';
        String password = 'brp';

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        //req.setHeader('Authorization', 'Basic QkxBQ0tQVVJMOmJycA==');
        req.setEndpoint(endPoint);
        req.setBody(getDealerLocatorString());
        /*req.setBody('<?xml version="1.0" encoding="UTF-8"?><star:GetDealerLocator releaseID="5.9.3" languageCode="en-US" xmlns:oagis="http://www.openapplications.org/oagis/9" xmlns:star="http://www.starstandard.org/STAR/5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"xsi:schemaLocation="http://www.starstandard.org/STAR/5 /schemas/STAR/Rev5.9.3/BODs/Standalone/GetDealerLocator.xsd"><star:ApplicationArea><star:Sender><star:AuthorizationID>1</star:AuthorizationID><star:CreatorNameCode>Blackpurl</star:CreatorNameCode><star:SenderNameCode>BP</star:SenderNameCode><star:DealerNumberID>0000999999</star:DealerNumberID><star:ServiceID>GetDealerLocator</star:ServiceID></star:Sender><star:CreationDateTime>2015-03-11T00:00:00-00:00</star:CreationDateTime><star:BODID>0a58ef11-eb78-4104-81eb-9cf474d2b7ac</star:BODID><star:Destination><star:DestinationNameCode>BD</star:DestinationNameCode></star:Destination></star:ApplicationArea><star:GetDealerLocatorDataArea><star:Get><oagis:Expression/></star:Get><star:DealerLocator><star:DealerLocatorHeader><star:DocumentIdentificationGroup><star:DocumentIdentification><star:DocumentID>GetDealerLocator</star:DocumentID><star:AgencyRoleCode>Dealer</star:AgencyRoleCode></star:DocumentIdentification></star:DocumentIdentificationGroup></star:DealerLocatorHeader></star:DealerLocator></star:GetDealerLocatorDataArea></star:GetDealerLocator>');*/

        //system.debug(Limits.getHeapSize() + ' ' + req.getHeader('Accept-Encoding'));
        HttpResponse response = new HttpResponse();
        try {
          response = h.send(req);
        } catch (System.Exception c) {
          System.debug('Callout error: '+ c);


        }
          //XmlStreamReader xsr = new XmlStreamReader(response.getBody());
          parseXML(response.getXmlStreamReader(), DealerId);
          
    }


    public static String getDealerLocatorString() {
        DOM.Document body = new DOM.Document();
        String prefix = 'star';
        String oagis = 'http://www.openapplications.org/oagis/9';
        String nameSpace = 'http://www.starstandard.org/STAR/5';
        String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
        String schemaLocation = 'http://www.starstandard.org/STAR/5 /STAR/Rev5.9.3/BODs/Standalone/GetDealerLocator.xsd " "';
        String release = '5.9.3';
        String languageCode='en-US';
        string createorNameCodeString='Blackpurl';
        string senderNameCodeString='BP';
        String destinationNameCodeString = 'BD';
        string agencyRoleCodeString = 'Operator';

        DOM.XmlNode root = body.createRootElement('GetDealerLocator', nameSpace, prefix);
        root.setAttribute('releaseID', release);
        root.setAttribute('languageCode', languageCode);
        root.setNamespace('oagis',oagis);
        root.setNamespace('star',nameSpace);
        root.setNamespace('xsi',xsi);
        root.setAttributeNS('schemaLocation',schemaLocation, xsi, null);


        dom.XmlNode applicationArea = root.addChildElement('ApplicationArea', nameSpace, prefix);
        dom.XmlNode sender = applicationArea.addChildElement('Sender', nameSpace, prefix);
        dom.XmlNode authorizationId = sender.addChildElement('AuthorizationID', nameSpace, prefix).addTextNode('India123');
        dom.XmlNode creationDateTime = applicationArea.addChildElement('CreationDateTime', nameSpace, prefix).addTextNode(BRPUtility.creationDateTimeString());
        dom.XmlNode creatorNameCode = sender.addChildElement('CreatorNameCode', nameSpace, prefix).addTextNode(createorNameCodeString);
        dom.XmlNode senderNameCode = sender.addChildElement('SenderNameCode', nameSpace, prefix).addTextNode(senderNameCodeString);
        dom.XmlNode dealerNumberID = sender.addChildElement('DealerNumberID', nameSpace, prefix).addTextNode(DealerId); //'0000694305'
        dom.XmlNode serviceId = sender.addChildElement('ServiceID', nameSpace, prefix).addTextNode('GetDealerLocator');

        dom.XmlNode BODID = applicationArea.addChildElement('BODID', nameSpace, prefix).addTextNode(BRPUtility.generateBodId());
        dom.XmlNode destination = applicationArea.addChildElement('Destination', nameSpace, prefix);
        dom.XmlNode destinationNameCode = destination.addChildElement('DestinationNameCode', nameSpace, prefix).addTextNode(destinationNameCodeString);

        dom.XmlNode getDealerLocatorDataArea = root.addChildElement('GetDealerLocatorDataArea', nameSpace, prefix);
        dom.XmlNode get = getDealerLocatorDataArea.addChildElement('Get', nameSpace, prefix);
        dom.XmlNode oagisElement = get.addChildElement('oagis:Expression', null, null);
        dom.XmlNode dealerLocator = getDealerLocatorDataArea.addChildElement('DealerLocator', nameSpace, prefix);
        dom.XmlNode dealerLocatorHeader = dealerLocator.addChildElement('DealerLocatorHeader', nameSpace, prefix);
        dom.XmlNode documentIdentificationGroup = dealerLocatorHeader.addChildElement('DocumentIdentificationGroup', nameSpace, prefix);
        dom.XmlNode documentIdentification = documentIdentificationGroup.addChildElement('DocumentIdentification', nameSpace, prefix);
        dom.XmlNode documentID = documentIdentification.addChildElement('DocumentID', nameSpace, prefix).addTextNode('GetDealerLocator');
        dom.XmlNode agencyRoleCode = documentIdentification.addChildElement('AgencyRoleCode', nameSpace, prefix).addTextNode(agencyRoleCodeString);
        return body.toXmlString();
    }


    public static void parseXML(XmlStreamReader reader, String dealerId) {
        //extract xml

        String ChannelType;
        String StoredURI;
        boolean isSafeToGetNextXmlElement = true;
        List<BRP_Dealers__c> dealers = new List<BRP_Dealers__c>();
        BRP_Dealers__c d  = new BRP_Dealers__c();
        List<BRP_Dealer_Product_Line__c> productLines = new List<BRP_Dealer_Product_Line__c>();
        BRP_Dealer_Product_Line__c p = new BRP_Dealer_Product_Line__c();
        while(isSafeToGetNextXmlElement) {
            // Start at the beginning of the dealer and make sure that it is a dealer

            if (reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'DealerLocatorDetail') {
              dealers.add(d);
              d = new BRP_Dealers__c();
            }

            if (reader.getEventType() == XmlTag.START_ELEMENT) {
              switch on reader.getLocalName() {
                  when 'PartyID' { d.Party_Id__c=parseValues(reader); }
                  when 'PersonName' { d.Person_Name__c =parseValues(reader); }
                  when 'CompanyName' { d.Company_Name__c =parseValues(reader); }
                  when 'TypeCode' { d.Type_Code__c = parseValues(reader); }
                  when 'LineOne' { d.Street__c = parseValues(reader); }
                  when 'LineTwo' { d.Line_two__c = parseValues(reader); }
                  when 'CityName' { d.City__c = parseValues(reader); }
                  when 'StateOrProvinceCountrySub-DivisionID' { d.state__c = parseValues(reader); }
                  when 'Postcode' { d.Postcode__c = parseValues(reader); }
                  when 'CountryID' { d.country__c = getCountryFromCode(parseValues(reader)); }
                  when 'ChannelCode' { 
                    ChannelType = parseValues(reader); 
                    if (ChannelType == 'email') d.email__c = StoredURI;
                    else if (ChannelType == 'website') d.website__c = StoredURI;
                  }
                  when 'LocalNumber' { 
                      if (ChannelType == 'telephone') d.telephone__c = parseValues(reader);
                      else if (ChannelType == 'fax') d.fax__c = parseValues(reader);
                  }      
                  when 'AreaNumberCode' {
                      if (ChannelType == 'telephone') d.telephone__c = '('+parseValues(reader)+')' + ' ' + d.telephone__c;
                      else if (ChannelType == 'fax') d.fax__c = '('+parseValues(reader)+')' + ' ' + d.fax__c;
                  }
                  when 'URIID' { 
                    StoredURI = parseValues(reader);
                  }
                  when 'ProductsCarried' {
                    p = new BRP_Dealer_Product_Line__c();
                    p.Party_Id__c = d.Party_Id__c;
                    p.name = parseValues(reader);
                    p.Unique_Id__c = p.Party_Id__c+'-'+p.name;
                    productLines.add(p);
                    system.debug(parseValues(reader));
                  }
                  when 'ErrorProcessMessage' { parseDealerErrors(reader, dealerId);}
              }
          }
            // Always use hasNext() before calling next() to confirm
            // that we have not reached the end of the stream
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }

        }
        Schema.SObjectField key = BRP_Dealers__c.Party_Id__c;
        Database.UpsertResult [] cr = Database.upsert (dealers, key, false);

        Map<String, String> dealerMap = new Map<string,String>();
        for(BRP_Dealers__c dlr: dealers) {
          dealerMap.put(dlr.Party_Id__c,dlr.Id);
        }
        List<BRP_Dealer_Product_Line__c> ListToUpsert = new List<BRP_Dealer_Product_Line__c>();
        
        for(BRP_Dealer_Product_Line__c prod: productLines) {
            
            
            if (dealerMap.containsKey(prod.Party_Id__c)) prod.BRP_Dealer__c = dealerMap.get(prod.Party_Id__c);
            listToUpsert.add(prod);
        }
        
        If (ListToUpsert.size()>0) Database.upsert (ListToUpsert, BRP_Dealer_Product_Line__c.Unique_Id__c, false);
    
    }

    public static string  getCountryFromCode(String CountryCode) {

      switch on countryCode {
        when 'US' { return 'USA'; } 
        when 'CA' { return 'Canada'; }
        when else { return CountryCode; }
      }

    }

    public static String parseValues(XmlStreamReader xls) {

      while (xls.getEventType() != XmlTag.CHARACTERS) {
        xls.next();
      }
      return xls.getText();
    }

    public static String HandleErrors(HttpResponse response) {
        String returnStr = '';
        if(response.getStatusCode() == 401){
            //IntegrationLog.createLog('BRPIntegration', 'getDealerLocator()', 'Unauthorized', String.valueOf(response.getStatusCode()), null, 'dealerId');
            returnStr = response.getStatusCode() + ' Unauthorized - ' + response.getBody();
        } else if(response.getStatusCode() == 400){
            //IntegrationLog.createLog('BRPIntegration', 'getDealerLocator()', 'Client Fault (Bad Request)', String.valueOf(response.getStatusCode()), null, 'dealerId');
            returnStr = response.getStatusCode() + ' Client Fault (Bad Request)'+response.getBody();
        } else if(response.getStatusCode() == 500){
            //IntegrationLog.createLog('BRPIntegration', 'getDealerLocator()', 'Server Fault', String.valueOf(response.getStatusCode()), null, 'dealerId');
            returnStr = response.getStatusCode() + ' Server Fault';
        } else {
            //IntegrationLog.createLog('BRPIntegration', 'getDealerLocator()', 'Response indicating an unknown fault', String.valueOf(response.getStatusCode()), null, 'dealerId');
            returnStr = response.getStatusCode() + ' Response indicating a unknown fault - ' + response.getBody();
        }
        return returnStr;
    }

    // Parse errors in Vehicle Spec Requests
    public static void parseDealerErrors(XmlStreamReader reader, String dealerCode) {

      boolean isSafeToGetNextXmlElement = true;
      string title = '';
      string type = '';
      string descr = '';
 
      while(isSafeToGetNextXmlElement) {
          switch on reader.getLocalName() {
            when 'title' {

              title = parseValues(reader);
            }
            when 'Type' {

              type = parseValues(reader);
            }
            when 'Description' {

              descr = parseValues(reader);
            }
          }
          if (reader.hasNext()) {
              reader.next();
          } else {
              isSafeToGetNextXmlElement = false;
              break;
          }
      }

      //IntegrationLog.createLog('BRPDealerIntegration', 'getDealer', title, type+' '+descr, null, dealerCode);
    }

}