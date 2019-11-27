public class CustomHttpHeaderWrapper {
    
    public string headerType{get;set;}
    public string headerValue{get;set;}
    
    /* Default constructor */
    public CustomHttpHeaderWrapper() { }
    
    public CustomHttpHeaderWrapper(String key, String value) {
        this.headerType = key;
        this.headerValue= value;
    }
}