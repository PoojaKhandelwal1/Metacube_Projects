public without sharing class BRPPartsResponseWrapper {
	
	public ShowPartsLocator ShowPartsLocator;

	public class ShowPartsLocator {
		public ShowPartsLocatorDataArea ShowPartsLocatorDataArea;
	}
	
	public class ShowPartsLocatorDataArea {
		public PartsLocator PartsLocator;
	}
	
	public class PartsLocator {
		public SupplyingPartyLocations SupplyingPartyLocations;
		public LocatedLines LocatedLines;
		public PartsLocatorHeader PartsLocatorHeader;
	}
	
	public class PartsLocatorHeader {
        public String RequestedSearchCriteriaTypeCode;
    }
	
	public class SupplyingPartyLocations {
		public List<SupplyingPartyLocation> SupplyingPartyLocation;
	}
	
	public class SupplyingPartyLocation {
		public String DistanceFromRequestor;
		public String unitCode;
		public Location Location;
		public String SupplyingPartyUIDID;
	}
	
	public class SupplyingParties {
		public List<PartsLocatorSupplyingParty> PartsLocatorSupplyingParty;
	}
	
	public class PartsLocatorSupplyingParty {
		public String PartyTypeCode;
		public String SupplierParty;
		public String SupplyingPartyUIDID;
	}
	
	public class LocatedLines {
		public List<LocatedLine> LocatedLine;
	}
	
	public class LocatedLine {
		public String SupplyingPartyUIDID;
		public LineStatus LineStatus;
		public String ItemQuantity;
		public PartsProductItem PartsProductItem;
	}
	
	public class LineStatus {
		public String StatusText;
		public String StatusCode;
	}
	
	public class PartsProductItem {
		public String PartItemDescription;
	}

	public class PrimaryContact {
		public TelephoneCommunication TelephoneCommunication;
		public String PersonName;
	}

	public class RequestedSearchCriteria {
		public String SearchRadiusQuantity;
	}

	public class LocationAddress {
		public String StateOrProvinceCountrySubDivisionID;
		public String Postcode;
		public String CountryID;
		public String CityName;
		public String LineOne;
	}

	public class RequestedLine {
		public String ItemQuantity;
		public String RequestedLineUIDID;
	}

	public class TelephoneCommunication {
		public String LocalNumber;
		public String ChannelCode;
	}

	public class Location {
		public PrimaryContact PrimaryContact;
		public LocationAddress LocationAddress;
		public String LocationName;
	}
}