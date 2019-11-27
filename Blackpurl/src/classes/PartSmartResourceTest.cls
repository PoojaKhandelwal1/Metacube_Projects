/**
 * Author: Rajat Jain
 * Since: Oct 5, 2018
 * Name: PartSmartResourceTest 
 * Description: test Class for PartSmartResourceTest.
**/

@isTest
public class PartSmartResourceTest {

  static testmethod void partSmartResourceTest() {
		String request = '{"header":{"$V":"4.0"},"requestData":[{"tD":"BATTERY STRAP ASY","TE":"HDM","tI":"66000032","tZ":"US","tC":"819","tS":"1654"},{"SE":"HDM","sI":"66000032","s*":""}]}';
        PartSmartResource.RequestWrapper requestData = (PartSmartResource.RequestWrapper)system.JSON.deserialize(request, PartSmartResource.RequestWrapper.class);
        String response = PartSmartResource.getPartDetailByPartNumber(requestData);
		system.assert(true, response.contains('$V'));
	}
}