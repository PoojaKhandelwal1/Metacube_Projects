/**
 * Author: Richa Mittal
 * Since: June 19, 2017
 * Name: ResponseWrapper
 * Description: Apex class to handle response status of various oprations.
**/
public without sharing class ResponseWrapper {
    
	public String responseStatus;
	public String response;
	public Integer responseCode;
	
	public ResponseWrapper(String responseStatus, String response) {
		this.responseStatus = responseStatus;
		this.response = response;
	}
	
	public ResponseWrapper(Integer responseCode, String response) {
        this.responseCode = responseCode;
        this.response = response;
    }
}