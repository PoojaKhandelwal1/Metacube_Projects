public without sharing class BRPPartsIntegration {

    public static String getPartsLocator(String partId, Integer quantity, String searchType) {
        List<Part__c> partList = [SELECT Part_Number__c, Description__c FROM Part__c WHERE Id =: partId];
        String jsonString;
        if(partList.size() > 0) {
            String partNumber = partList[0].Part_Number__c;
            String body = getPartLocatorString(partNumber, quantity, searchType);
            List<CustomHttpHeaderWrapper> headerList = getHeaderList();
            Id IFW_Id = BRPUtility.getIFWConfigItemByEntityName('GetPartLocator', 'POST', 'BRP');
            
            BRPPartLocatorWrapper partLocatorObj;
            if(searchType != 'Supplier') {
                partLocatorObj = parseXML(BaseIntegration.performCallout(IFW_Id, body, headerList, new Map<String, String>()), searchType, partNumber);
            } else {
                partLocatorObj = parseXMLForSupplierSearch(BaseIntegration.performCallout(IFW_Id, body, headerList, new Map<String, String>()), partNumber);
                partLocatorObj = populateDefaultField(partLocatorObj, partNumber, partList[0].Description__c);
            }
            if(partLocatorObj == null) {
                partLocatorObj = new BRPPartLocatorWrapper();
                partLocatorObj = populateDefaultField(partLocatorObj, partNumber, partList[0].Description__c);
            }
            jsonString = system.JSON.serialize(partLocatorObj);
        } else {
            jsonString = system.JSON.serialize(new ResponseWrapper(400, 'Invalid part number'));
        }
        return jsonString;
    }
    
    private static BRPPartLocatorWrapper populateDefaultField(BRPPartLocatorWrapper partLocatorObj, String partNumber, String partDesc) {
        partLocatorObj.PartNumber = partNumber;
        partLocatorObj.PartDescription = partDesc;
        return partLocatorObj;
    }

    private static List<CustomHttpHeaderWrapper> getHeaderList() {
        List<CustomHttpHeaderWrapper> headerList = new List<CustomHttpHeaderWrapper>();
        headerList.add(BRPUtility.buildCustomHttpHeader('Content-Type', BRPUtility.contentType));
        headerList.add(BRPUtility.buildCustomHttpHeader('Accept-Language', 'en-US'));
        headerList.add(BRPUtility.buildCustomHttpHeader('Connection', 'Keep-Alive'));
        headerList.add(BRPUtility.buildCustomHttpHeader('Accept-Charset', 'UTF-8'));
        headerList.add(BRPUtility.buildCustomHttpHeader('Accept', BRPUtility.contentType));
        headerList.add(BRPUtility.buildCustomHttpHeader('Accept-Encoding', 'gzip'));
        return headerList;
    }

    public static String getPartLocatorString(String itemIdCode, Integer quantity, String searchType) {
        String radius = BRPUtility.getDealerRadius();
        if(searchType != 'Dealer Radius') {
            radius = '0';
        }
        DOM.Document body = new DOM.Document();
        String prefix = 'star';
        String oagis = 'http://www.openapplications.org/oagis/9';
        String nameSpace = 'http://www.starstandard.org/STAR/5';
        String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
        String schemaLocation = 'http://www.starstandard.org/STAR/5 /STAR/Rev5.8.3/BODs/Standalone/GetPartsLocator.xsd';
        String release = '5.8.3';
        String languageCode='en-US';

        DOM.XmlNode root = body.createRootElement('GetPartsLocator', nameSpace, prefix);
        root.setNamespace('star',nameSpace);
        root.setNamespace('oagis',oagis);
        root.setNamespace('xsi',xsi);
        
        root.setAttribute('releaseID', release);
        root.setAttribute('languageCode', languageCode);
        root.setAttributeNS('schemaLocation',schemaLocation, xsi, null);

        dom.XmlNode applicationArea = root.addChildElement('ApplicationArea', nameSpace, prefix);
        dom.XmlNode sender = applicationArea.addChildElement('Sender', nameSpace, prefix);

        dom.XmlNode authorizationId = sender.addChildElement('AuthorizationID', nameSpace, prefix).addTextNode('1');
        dom.XmlNode creatorNameCode = sender.addChildElement('CreatorNameCode', nameSpace, prefix).addTextNode('Blackpurl');
        dom.XmlNode senderNameCode = sender.addChildElement('SenderNameCode', nameSpace, prefix).addTextNode('BP');
        dom.XMLNode senderDealerNumberID = sender.addChildElement('DealerNumberID', nameSpace, prefix).addTextNode(BRPUtility.getDealerId());
        dom.XmlNode serviceId = sender.addChildElement('ServiceID', nameSpace, prefix).addTextNode('GetPartsLocator');

        dom.XmlNode creationDateTime = applicationArea.addChildElement('CreationDateTime', nameSpace, prefix).addTextNode(BRPUtility.creationDateTimeString());
        dom.XmlNode bodID = applicationArea.addChildElement('BODID', nameSpace, prefix).addTextNode(BRPUtility.generateBodId());

        dom.XmlNode destination = applicationArea.addChildElement('Destination', nameSpace, prefix);
        dom.XmlNode destinationNameCode = destination.addChildElement('DestinationNameCode', nameSpace, prefix).addTextNode('BD');

        dom.XmlNode getPartsLocatorDataArea = root.addChildElement('GetPartsLocatorDataArea', nameSpace, prefix);
        dom.XmlNode get = getPartsLocatorDataArea.addChildElement('Get', nameSpace, prefix);
        dom.XmlNode oagisElement = get.addChildElement('oagis:Expression', null, null);
        dom.XmlNode partsLocator = getPartsLocatorDataArea.addChildElement('PartsLocator', nameSpace, prefix);
        dom.XmlNode partsLocatorHeader = partsLocator.addChildElement('PartsLocatorHeader', nameSpace, prefix);
        dom.XmlNode documentIdentificationGroup = partsLocatorHeader.addChildElement('DocumentIdentificationGroup', nameSpace, prefix);
        dom.XmlNode documentIdentification = documentIdentificationGroup.addChildElement('DocumentIdentification', nameSpace, prefix);
        dom.XmlNode documentID = documentIdentification.addChildElement('DocumentID', nameSpace, prefix).addTextNode('GetPartsLocator');
        dom.XmlNode agencyRoleCode = documentIdentification.addChildElement('AgencyRoleCode', nameSpace, prefix).addTextNode('Dealer');
        dom.XmlNode requestedSearchCriteriaTypeCode = partsLocatorHeader.addChildElement('RequestedSearchCriteriaTypeCode', nameSpace, prefix).addTextNode(searchType);
        dom.XmlNode requestedSearchCriteria = partsLocatorHeader.addChildElement('RequestedSearchCriteria', nameSpace, prefix);
        dom.XmlNode searchRadiusQuantity = requestedSearchCriteria.addChildElement('SearchRadiusQuantity', nameSpace, prefix);
        searchRadiusQuantity.setAttribute('unitCode', BRPUtility.getDealerRadiusMeasure());
        dom.XMLNode sr3 = searchRadiusQuantity.addTextNode(radius);
        dom.XmlNode requestedLines = partsLocator.addChildElement('RequestedLines', nameSpace, prefix);

        if (String.isNotBlank(ItemIdCode)) {
            dom.XmlNode requestedLine = requestedLines.addChildElement('RequestedLine', nameSpace, prefix);
            dom.XmlNode requestedLineUIDID = requestedLine.addChildElement('RequestedLineUIDID', nameSpace, prefix).addTextNode(BRPUtility.generateBodId());
            //dom.XmlNode lineNumberString = requestedLine.addChildElement('LineNumberString', nameSpace, prefix).addTextNode('1230');
            dom.XmlNode shipPart = requestedLine.addChildElement('ShipPart', nameSpace, prefix);
            dom.XmlNode itemQuantity = requestedLine.addChildElement('ItemQuantity', nameSpace, prefix);
            itemQuantity.setAttribute('unitCode','ea');
            itemQuantity.addTextNode(String.valueOf(quantity));
            dom.XmlNode itemIdentificationGroup = shipPart.addChildElement('ItemIdentificationGroup', nameSpace, prefix);
            dom.XmlNode itemIdentification = itemIdentificationGroup.addChildElement('ItemIdentification', nameSpace, prefix);
            dom.XmlNode itemID = itemIdentification.addChildElement('ItemID', nameSpace, prefix).addTextNode(itemIdCode);
        }
        return body.toXmlString();
    }
    
    private static BRPPartLocatorWrapper parseXML(String xmlString, String searchType, String partNumber) {
        BRPPartLocatorWrapper partLocatorObj;
        xmlString = xmlString.replace('StateOrProvinceCountrySub-DivisionID', 'StateOrProvinceCountrySubDivisionID');
        BRPPartsResponseWrapper partsObj = (BRPPartsResponseWrapper)new XMLSerializer().deSerialize(xmlString, BRPPartsResponseWrapper.class);
        if(partsObj.ShowPartsLocator != null && partsObj.ShowPartsLocator.ShowPartsLocatorDataArea != null && 
            partsObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator != null &&
            partsObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.LocatedLines != null && 
            partsObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.LocatedLines.LocatedLine != null) {
            List<BRPPartsResponseWrapper.LocatedLine> locatedLineList = partsObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.LocatedLines.LocatedLine;
            for(Integer i = 0; i < locatedLineList.size(); i++) {
                if(locatedLineList[i].LineStatus != null && locatedLineList[i].LineStatus.StatusCode != null && locatedLineList[i].LineStatus.StatusCode == 'Success') {
                    partLocatorObj = convertIntoPartLocatorWrapper(partsObj, searchType, partNumber);
                    break;
                }
            }
        } 
        return partLocatorObj;
    }
    
    private static BRPPartLocatorWrapper parseXMLForSupplierSearch(String xmlString, String partNumber) {
        BRPPartLocatorWrapper partLocatorObj; 
        xmlString = xmlString.replace('StateOrProvinceCountrySub-DivisionID', 'StateOrProvinceCountrySubDivisionID');
        BRPPartsResponseWrapper partsObj = (BRPPartsResponseWrapper)new XMLSerializer().deSerialize(xmlString, BRPPartsResponseWrapper.class);
        if(partsObj.ShowPartsLocator != null && partsObj.ShowPartsLocator.ShowPartsLocatorDataArea != null && 
            partsObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator != null &&
            partsObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.LocatedLines != null && 
            partsObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.LocatedLines.LocatedLine != null) {
            List<BRPPartsResponseWrapper.LocatedLine> locatedLineList = partsObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.LocatedLines.LocatedLine;
            if(locatedLineList.size() > 0) {
                partLocatorObj = new BRPPartLocatorWrapper();
                partLocatorObj.ManufacturerAvailableQty = locatedLineList[0].ItemQuantity;
            }
        } 
        return partLocatorObj;
    }
    
    private static BRPPartLocatorWrapper convertIntoPartLocatorWrapper(BRPPartsResponseWrapper resObj, String searchType, String partNumber) {
        BRPPartLocatorWrapper partObj = new BRPPartLocatorWrapper();
        partObj.PartNumber = partNumber;
        
        partObj.DealerNearList = new List<BRPPartLocatorWrapper.PartInfoFromDealer>();
        partObj.AllDealerList = new List<BRPPartLocatorWrapper.PartInfoFromDealer>(); 
        
        Map<String, String> dealerIdToItemQuantityMap = new Map<String, String>();
        if(resObj.ShowPartsLocator != null && resObj.ShowPartsLocator.ShowPartsLocatorDataArea != null &&
            resObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator != null) {
            if(resObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.LocatedLines != null && 
                    resObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.LocatedLines.LocatedLine != null) {
                List<BRPPartsResponseWrapper.LocatedLine> locatedLineList = resObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.LocatedLines.LocatedLine;
                for(BRPPartsResponseWrapper.LocatedLine line : locatedLineList) {
                    if(line.PartsProductItem != null && line.PartsProductItem.PartItemDescription != null) {
                        partObj.PartDescription = line.PartsProductItem.PartItemDescription;
                    }
                    if(line.SupplyingPartyUIDID != null && line.ItemQuantity != null) {
                        dealerIdToItemQuantityMap.put(line.SupplyingPartyUIDID, line.ItemQuantity);
                    }
                }
            }
            if(resObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.SupplyingPartyLocations != null && 
                   resObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.SupplyingPartyLocations.SupplyingPartyLocation != null ) {
                List<BRPPartsResponseWrapper.SupplyingPartyLocation> locationList = 
                    resObj.ShowPartsLocator.ShowPartsLocatorDataArea.PartsLocator.SupplyingPartyLocations.SupplyingPartyLocation;
                for(BRPPartsResponseWrapper.SupplyingPartyLocation locationObj : locationList) {
                    BRPPartLocatorWrapper.PartInfoFromDealer partInfoFromDealerObj = new BRPPartLocatorWrapper.PartInfoFromDealer();
                    if(locationObj.SupplyingPartyUIDID != null && dealerIdToItemQuantityMap.containsKey(locationObj.SupplyingPartyUIDID)) {
                        partInfoFromDealerObj.AvailableQty = dealerIdToItemQuantityMap.get(locationObj.SupplyingPartyUIDID);
                    }
                    if(locationObj.DistanceFromRequestor != null) {
                        partInfoFromDealerObj.Distance = getFormattedDistance(locationObj.DistanceFromRequestor);
                    }
                    if(locationObj.Location != null) {
                        if(locationObj.Location.LocationName != null) {
                            partInfoFromDealerObj.DealerName = locationObj.Location.LocationName;
                        }
                        if(locationObj.Location.LocationAddress != null) {
                            BRPPartsResponseWrapper.LocationAddress address = locationObj.Location.LocationAddress;
                            partInfoFromDealerObj.DealerAddress = getFormattedAddress(address.LineOne, address.CityName, 
                                    address.StateOrProvinceCountrySubDivisionID, address.CountryID, address.Postcode);
                        }
                        if(locationObj.Location.PrimaryContact != null && locationObj.Location.PrimaryContact.TelephoneCommunication != null) {
                            partInfoFromDealerObj.DealerPhoneNumber = locationObj.Location.PrimaryContact.TelephoneCommunication.LocalNumber;
                        }
                    }
                    if(searchType == 'Dealer Radius') {
                        partObj.DealerNearList.add(partInfoFromDealerObj);
                    } else {
                        partObj.AllDealerList.add(partInfoFromDealerObj);
                    }
                }
            }
        }
        return partObj;
    }
    
    private static String getFormattedAddress(String line1, String city, String state, String country, String zip) {
        return line1 + ', ' + city + ' ' + state + ' ' + country + ' ' + zip;
    }
    
    private static String getFormattedDistance(String distance) {
        return distance + ' ' + BRPUtility.getDealerRadiusMeasure() + ' away';
    }
}