public with sharing class GlobalController	{
    
    public static String Application{get;}
    public static String Assests{get;}
    public static String Application_Images{get;}
    public Boolean IsLoadNewCustomerOrder {get{return GeneralConfiguration.isLoadNewCustomerOrder();} set;}
    public Boolean IsLoadTechScheduling {get{return GeneralConfiguration.isLoadTechnicianScheduling();} set;}  
    public GlobalController(){
    	Application = GetResourceURL('Application');
    	Application_Images = GetResourceURL('Application_Images');
    	Assests = GetResourceURL('Assests');
    }
   
    public static String GetResourceURL(String resourceName) {
    	String url = '';
    	if(BP_Configurations__c.getOrgDefaults().isLoadStaticResource__c){
    		url = GetStaticResourceURL(resourceName);
    	}else{
    		url = 'https://localhost/Blackpurl/'+resourceName;
    	}
    	return url;
    }
    
    /**public static String GetResourceURL(String resourceName) {
    	String url = '';
    	if(resourceName == 'Application' || resourceName == 'Locale') {
    		if(Constants.NAMESPACE == 'BlackPurlCore__') {
	    		url = 'https://ui.blackpurl.com/prod/'+resourceName;
	    	} else if(Constants.NAMESPACE == 'BPTest__') {
	    		url = 'https://ui.blackpurl.com/rest/'+resourceName;
	    	} else {
	    		url = 'https://ui.blackpurl.com/rest/'+resourceName;
	    	}
    	} else {
    		if(BP_Configurations__c.getOrgDefaults().isLoadStaticResource__c){
	    		url = GetStaticResourceURL(resourceName);
	    	}else{
	    		url = 'https://localhost/Blackpurl/'+resourceName;
	    	}
    	}
    	return url;
    }*/
    
    private static String GetStaticResourceURL(String resourceName) {
		List<StaticResource> resourceList = [
		   SELECT Name, NamespacePrefix, SystemModStamp 
		   FROM StaticResource 
		   WHERE Name = :resourceName
		];
		                    
		if (resourceList.size() == 1) {
		   String namespace = resourceList[0].NamespacePrefix;
		   return '/resource/' 
		      + resourceList[0].SystemModStamp.getTime() + '/' 
		      + (namespace != null && namespace != '' ? namespace + '__' : '') 
		      + resourceName; 
		} else return '';
	
	}
}