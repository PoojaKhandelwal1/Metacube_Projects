public without sharing class BRPVehicleIntegration {

    public static String getVehicleSpecification(String vin) {
        List<CustomHttpHeaderWrapper> headerList = getHeaderList();
        Map<String, String> paramsMap = new Map<String, String>();
        if(vin != null) {
        	vin = vin.replace(' ','%20');
        }
        paramsMap.put('VehicleID', vin);
        
        Id IFW_Id = BRPUtility.getIFWConfigItemByEntityName('GetVehicleSpecification', 'GET', 'BRP');
        return parseXML(BaseIntegration.performCallout(IFW_Id, '', headerList, paramsMap));
    }

    private static List<CustomHttpHeaderWrapper> getHeaderList() {
        List<CustomHttpHeaderWrapper> headerList = new List<CustomHttpHeaderWrapper>();
        headerList.add(BRPUtility.buildCustomHttpHeader('Content-Type', BRPUtility.contentType));
        headerList.add(BRPUtility.buildCustomHttpHeader('Accept-Language', 'en-US'));
        headerList.add(BRPUtility.buildCustomHttpHeader('Connection', 'Keep-Alive'));
        headerList.add(BRPUtility.buildCustomHttpHeader('Accept-Charset', 'UTF-8'));
        headerList.add(BRPUtility.buildCustomHttpHeader('Accept', BRPUtility.contentType));
        headerList.add(BRPUtility.buildCustomHttpHeader('Accept-Encoding', 'gzip'));
        headerlist.add(BRPUtility.buildCustomHttpHeader('X-STAR-DealerNumberID', BRPUtility.getDealerId())); 
        headerlist.add(BRPUtility.buildCustomHttpHeader('X-STAR-AuthorizationID', 'asmith01')); 
        headerlist.add(BRPUtility.buildCustomHttpHeader('X-STAR-SenderNameCode', 'BP')); 
        headerlist.add(BRPUtility.buildCustomHttpHeader('X-STAR-releaseID', '5.8.1')); 
        headerlist.add(BRPUtility.buildCustomHttpHeader('X-STAR-BODID', '0a58ef11-eb78-4104-81eb-9cf474d2b7ac')); 
        return headerList;
    }
    
    private static String parseXML(String xmlString) {
        String jsonString;
        BRPVehicleResponseWrapper vehicleObj = (BRPVehicleResponseWrapper)new XMLSerializer().deSerialize(xmlString, BRPVehicleResponseWrapper.class);
        if(vehicleObj.ShowVehicleSpecifications != null && vehicleObj.ShowVehicleSpecifications.ShowVehicleSpecificationsDataArea != null && 
            vehicleObj.ShowVehicleSpecifications.ShowVehicleSpecificationsDataArea.VehicleSpecifications != null && 
            vehicleObj.ShowVehicleSpecifications.ShowVehicleSpecificationsDataArea.VehicleSpecifications.VehicleSpecificationsLine != null &&
            vehicleObj.ShowVehicleSpecifications.ShowVehicleSpecificationsDataArea.VehicleSpecifications.VehicleSpecificationsLine.Vehicle != null) {
            jsonString = system.JSON.serialize(vehicleObj.ShowVehicleSpecifications.ShowVehicleSpecificationsDataArea.VehicleSpecifications.VehicleSpecificationsLine.Vehicle);
        } else {
            jsonString = system.JSON.serialize(new ResponseWrapper(400, 'No such vehicle found'));
        }
        return jsonString;
    }
}