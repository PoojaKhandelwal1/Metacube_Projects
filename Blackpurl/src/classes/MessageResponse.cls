public class MessageResponse {
    public Integer server_code ;
    public String message ;
    public List<String> message_uuid ;
    public String error ;
    public String api_id ;
    public MessageResponse() {}

    public override String toString() {
        return 'MessageResponse [\n serverCode=' + server_code + ',\n message='
                + message + ',\n messageUuids=' + message_uuid + ',\n error='
                + error + ',\n apiId=' + api_id + '\n]';
    }
}