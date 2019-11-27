@isTest
private class XMLSerializerTest {
    
    static string xmlString = '<catalog><books><book><title>BlackPurl</title><subTitle>Dealer management system</subTitle><authors><author>Dan Appleman</author></authors><price>39.95</price></book><book><title>Design Patterns</title><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><price>37.88</price></book></books></catalog>';
   
    static testMethod void serializeTest() {
        clsLibrary library = new clsLibrary();
        clsCatalog catalog = new clsCatalog();
        clsBooks books = new clsBooks();
        List<clsBook> book = new List<clsBook>();
        
        clsBook book1 = new clsBook();
        book1.title = 'BlackPurl';
        clsAuthors apexAuthors = new clsAuthors();
        List<String> apexAuthor = new List<String>();
        apexAuthor.add('Dan Appleman');
        apexAuthors.author = apexAuthor;
        book1.authors = apexauthors;
        book.add(book1);
        books.book = book;
        catalog.books = books;
        library.catalog = catalog;
        
        XmlSerializer serializer = new XmlSerializer();
        String serializedWithDefaultOptions = serializer.serialize(library);
        system.assert(serializedWithDefaultOptions.containsIgnoreCase('<subTitle></subTitle>'));
        
        string serializedXMLWithOptions = serializer.serialize(library, true, 'Root');
        system.assert(!serializedXMLWithOptions.containsIgnoreCase('<subTitle></subTitle>'));
        system.assert(serializedXMLWithOptions.contains('<Root>'));
        system.assert(serializedXMLWithOptions.contains('</Root>'));
    }

    static testMethod void deSerializeTest() {
        XmlSerializer serializer = new XmlSerializer();
        clsLibrary library = (clsLibrary)serializer.deSerialize(xmlString, clsLibrary.class,new Set<String>{'author'});  
        
        System.assertEquals(2, library.catalog.books.book.size());
        
        for(clsBook b: library.catalog.books.book) {            
            if(b.title == 'BlackPurl') system.assertEquals(1, b.authors.author.size()); 
            else system.assertEquals(4, b.authors.author.size());
        }
    }
    
    static testMethod void deSerializeUnTypedTest() {
       	XmlSerializer serializer = new XmlSerializer();
       	object o = serializer.deSerializeUnTyped(xmlString, new Set<String>{'author'});          
	    System.assert(o instanceOf Map<String,Object>);
	    Map<String,Object> libraryMap = (Map<string,Object>)o;
	    System.assert(libraryMap.containsKey('catalog'));
	    serializer.resetDefaults(); 
	    object xmlToUnTypedObjectDefault = serializer.deSerializeUnTyped(xmlString);
     	Map<String,Object> libraryMap1 = (Map<string,Object>)xmlToUnTypedObjectDefault;
        System.assert(libraryMap1.containsKey('catalog'));
        
        object xmlToUnTypedObjectWithOptions = serializer.deSerializeUnTyped(xmlString,new Set<String>{'author'});
     	Map<String,Object> libraryMap2 = (Map<string,Object>)xmlToUnTypedObjectWithOptions;
        system.assert(libraryMap2.containsKey('catalog'));        
    }
    
   	static testMethod void XMLToJSonConversionTest() {
   	
        XmlSerializer serializer = new XmlSerializer();
        String jsonString = serializer.XMLToJSON(xmlString);               
        String expectedOutput = '{"catalog":{"books":{"book":[{"price":"39.95","authors":{"author":"Dan Appleman"},"subTitle":"Dealer management system","title":"BlackPurl"},{"price":"37.88","authors":{"author":["Erich Gamma","Richard Helm","Ralph Johnson","John Vlissides"]},"title":"Design Patterns"}]}}}';
        System.assertEquals(expectedOutput, jsonString);
       
       String jsonStringWithConvertAsArray = serializer.XMLToJSON(xmlString,new Set<String>{'author'}); 
       String expectedOutputWithArray ='{"catalog":{"books":{"book":[{"price":"39.95","authors":{"author":["Dan Appleman"]},"subTitle":"Dealer management system","title":"BlackPurl"},{"price":"37.88","authors":{"author":["Erich Gamma","Richard Helm","Ralph Johnson","John Vlissides"]},"title":"Design Patterns"}]}}}';
       system.assertNotEquals(expectedOutput, jsonStringWithConvertAsArray);
       system.assertEquals(expectedOutputWithArray, jsonStringWithConvertAsArray);
    }
    
    static testMethod void JsonToXMLConversionTest() {        
        String jsonString = '{"catalog":{"books":{"book":[{"price":"39.95","authors":{"author":"Dan Appleman"},"subTitle":"Dealer management system","title":null},{"price":"37.88","authors":{"author":["Erich Gamma","Richard Helm","Ralph Johnson","John Vlissides"]},"title":"Design Patterns"}]}}}';
		XmlSerializer serializer = new XmlSerializer();
        String convertedXmlString = serializer.JSONToXML(jsonString);   

        String expectedOutputWithDefaultOptions = '<catalog><books><book><price>39.95</price><authors><author>Dan Appleman</author></authors><subTitle>Dealer management system</subTitle><title></title></book><book><price>37.88</price><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><title>Design Patterns</title></book></books></catalog>';
        system.assertEquals(expectedOutputWithDefaultOptions, convertedXmlString);
        
        string convertedStringWithOptions = serializer.JsonToXML(jsonString, true);
        String expectedOutputWithOptions = '<catalog><books><book><price>39.95</price><authors><author>Dan Appleman</author></authors><subTitle>Dealer management system</subTitle></book><book><price>37.88</price><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><title>Design Patterns</title></book></books></catalog>';
        system.assertEquals(expectedOutputWithOptions, convertedStringWithOptions);
    }
    
    public class clsLibrary {        
    	public clsCatalog catalog;
    }
    
    public class clsCatalog {
        public clsBooks books;
    }
    
    public class clsBooks {
        public List<clsBook> book;
    }
    
    public class clsBook {
        public String title;
        public String subTitle;
        public clsAuthors authors;
        public String price;
    }
    
    public class clsAuthors {
        public List<String> author;
    }
}