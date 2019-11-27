@isTest
private class SMSMessageApiTest {

	@isTest static void testSendSingleMessagePositive() {
	    //set mock class
	    SMSHttpCalloutMockImpl mock = new SMSHttpCalloutMockImpl('{"message": "message(s) queued",' +
	    '"message_uuid": ["db3ce55a-7f1d-11e1-8ea7-1231380bc196"],"api_id": "db342550-7f1d-11e1-8ea7-1231380bc196"}', 202);
	    Test.setMock(HttpCalloutMock.class, mock);
        
        SMSRestApi api = new SMSRestApi('MAYMFHYZJKMJG0NJG3AG', 'ZDZlNzI4ZDVkNDkzYWIxMzk5NjU1ODksZWYyZeEx', 'v1');
        
        Map<String, String> params = new Map<String, String> ();
        params.put('src','18583650866');
        params.put('dst','12109206499');
        params.put('text','Testing');
        
        MessageResponse msg = api.sendMessage(params);
        System.debug(msg);
        System.assertEquals(msg.message, 'message(s) queued');
        System.assertEquals(msg.message_uuid[0], 'db3ce55a-7f1d-11e1-8ea7-1231380bc196');
        System.assertEquals(msg.api_id, 'db342550-7f1d-11e1-8ea7-1231380bc196');
        System.assertEquals(msg.server_code, 202);
	}
		
}