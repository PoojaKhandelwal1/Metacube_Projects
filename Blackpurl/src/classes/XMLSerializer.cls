public class XMLSerializer{
    
    private Boolean serializeNulls = true;
    private String rootElement;
    private Set<String> deSerializeAsArrayNodes = new Set<string>();
    
    public String serialize(object objectToSerialize) {
        object deSerialized = JSON.deserializeUntyped(JSON.serialize(objectToSerialize));               
        return !string.isEmpty(rootElement) ? Wrap(rootElement,serialize((Map<string,object>)deSerialized)) : serialize((Map<string,object>)deSerialized);     
    }
    
    public String serialize(object objectToSerialize, boolean suppressApexObjectNulls, String addRootElementName) {
        this.serializeNulls = !suppressApexObjectNulls;
        this.rootElement = addRootElementName;
        return serialize(objectToSerialize);
    }
    
    public String jsonToXML(String jsonString){
        object deSerialized = JSON.deserializeUntyped(jsonString);               
        return !string.isEmpty(rootElement) ? Wrap(rootElement,serialize((Map<string,object>)deSerialized)) : serialize((Map<string,object>)deSerialized);
    }
    
    public string jsonToXML(String jsonString,boolean suppressNulls){
        this.serializeNulls = !suppressNulls;       
        return jsonToXML(jsonString);
    }
    
    public object deSerialize(String xmlString, System.Type apexType){   
        string json = XMLToJson(xmlString); 
        return System.JSON.deserialize(json, apexType);          
    }
    
    public object deSerialize(String xmlString, System.Type apexType,Set<String> deSerializeNodesAsArray){   
        this.deSerializeAsArrayNodes = toLower(deSerializeNodesAsArray);
        return deSerialize(xmlString,apexType);     
    }    
    
    public object deSerializeUnTyped(String xmlString){  
        return xmlToUnTyped(xmlString);         
    }
    
    public object deSerializeUnTyped(String xmlString, Set<String> deSerializeNodesAsArray){  
        this.deSerializeAsArrayNodes = toLower(deSerializeNodesAsArray);
        return xmlToUnTyped(xmlString);         
    }
    
    public String XMLToJSON(String xmlString){
        return System.JSON.serialize(XMLToUnTyped(xmlString));
    } 
    
    public String xmlToJSON(String xmlString, Set<String> deSerializeNodesAsArray){  
        this.deSerializeAsArrayNodes = toLower(deSerializeNodesAsArray);
        return System.JSON.serialize(XMLToUnTyped(xmlString));
    }   
    
    public void resetDefaults() {
        this.serializeNulls = true;
        this.rootElement = null;
        this.deSerializeAsArrayNodes.clear();
    }
    
    //Helpers
    private String serialize(Map<string,object> objectMap){
        string xmlString = '';    
        for(string key:objectMap.keySet()){  
            object o = objectMap.get(key);
            if(o == null) { if(this.SerializeNulls)     xmlString += wrap(key,null); }                       
            else if(o InstanceOf List<object> )         xmlString += serialize((List<object>) o,key);
            else if(o InstanceOf Map<string,object> )   xmlString += wrap(key,serialize((Map<string,object>) o));
            else                                        xmlString += wrap(key,string.valueOf(o));                               
        }
        return xmlString;
    }
    
    private String serialize(List<object> objectList, string key){
        String xmlString = '';      
        for(object o:objectList){    
            if (o InstanceOf string)                xmlString += wrap(key,string.valueOf(o));   
            else if(o InstanceOf List<object> )     xmlString += wrap(key,serialize((List<object>) o, key));
            else                                    xmlString += wrap(key,serialize((Map<string,object>) o));                
        }     
        return xmlString;
    }
    
    private String wrap(string key, string value){
        return (string.isNotBlank(value) || serializeNulls) ? ('<' + key + '>' + (string.isBlank(value)?'':value) + '</' + key + '>') : value;
    }
    
    private Map<string,object> XMLToUnTyped(string xmlString){
        xmldom xd = new xmldom(xmlString);
        xmldom.Element document = xd.ownerDocument();
        return (Map<string,object>)parseNode(document);
    }  
    
    private object parseNode(xmldom.Element e){
        if(e.childNodes.size()>0) return complexNodeToMap(e); 
        else  return e.nodeValue;  
    }
    
    private Map<string,object> complexNodeToMap(xmldom.Element e){       
        Map<string,object> cNodeMap = new Map<string,object>();
        for(xmldom.Element cNode : e.childNodes){                  
            if(cNodeMap.containsKey(cNode.nodeName)){                    
                object o = cNodeMap.get(cNode.nodeName);                    
                if(o InstanceOf List<object>) ((List<object>) o).add(parseNode(cNode));
                else cNodeMap.put(cNode.nodeName,new List<object>{o,parseNode(cNode)});                    
            }
            else {
            	if(cNode.nodeName == 'LocatedLine' || cNode.nodeName == 'SupplyingPartyLocation' || cNode.nodeName == 'PartsLocatorSupplyingParty') {
	                cNodeMap.put(cNode.nodeName, new List<object>{parseNode(cNode)});
	            } else {
	                cNodeMap.put(cNode.nodeName, deSerializeAsArrayNodes.contains(cNode.nodeName.toLowerCase())? new List<object>{parseNode(cNode)} : parseNode(cNode));
	            }
            }
        }
        return cNodeMap;
    } 
    
    private Set<String> toLower(Set<String> stringSet){
        Set<String> lowerStringSet = new Set<String>();
        for(String s:stringSet) lowerStringSet.add(s.toLowerCase());
        return lowerStringSet;
    }
}