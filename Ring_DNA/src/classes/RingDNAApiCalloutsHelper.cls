public class RingDNAApiCalloutsHelper {

	public static String getMessageClauseToSentNativeEmail(List<NativeEmailMessage> nativeEmailMessageList, String API_KEY, String API_SECRET) {
		String result = '{'; 
		result += '"sfOrgId":"' + CadenceConstants.ORANIZATION_ID + '",';
		result += '"apiKey":"' + API_KEY + '",';
		result += '"apiSecret":"' + API_SECRET + '",';
		result += '"messages":[';

		for (NativeEmailMessage nativeEmailMessage : nativeEmailMessageList){
			result += '{';
			result += '"actionId":"' + nativeEmailMessage.ActionId + '",';
			result += '"subject":"' + nativeEmailMessage.Subject + '",';
			result += '"toEmail": [ "' + nativeEmailMessage.MailTo + '" ],'; 
			result += '"body":"' + nativeEmailMessage.Body.replaceAll('(\\r|\\n)+', '<br>') + '",';          
			result += '"sfUserId":"' + nativeEmailMessage.UserId + '",';  
			result = result.removeEnd(',');
			result += '},';
		}        

		result = result.removeEnd(',');
		result += ']}'; 
		return result;
	}  

	public static List<NativeEmailRespose> processApiResponse(httpResponse response) {
		List<NativeEmailRespose> resBodyList = new List<NativeEmailRespose>();
		if (response.getBody() != null){
			resBodyList = (List<NativeEmailRespose>)JSON.deserialize(response.getBody(), List<NativeEmailRespose>.class);
		}
		return resBodyList;
	}  
}