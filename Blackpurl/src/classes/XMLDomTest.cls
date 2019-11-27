@isTest
private class XMLDomTest {

    static string xmlString = '<catalog><books><book><title>BlackPurl</title><subTitle>Dealer management system</subTitle><authors><author>Dan Appleman</author></authors><price>39.95</price></book><book><title>Design Patterns</title><authors><author>Erich Gamma</author><author>Richard Helm</author><author>Ralph Johnson</author><author>John Vlissides</author></authors><price>37.88</price></book></books></catalog>';
    
    static testMethod void xmlDomAllMethodsTest(){
	    xmldom xd = new xmldom(xmlString);
	    xmldom.Element document = xd.ownerDocument();
	    List<xmldom.element> elements = xd.getElementsByTagName('book');
	    String s = xd.toXmlString();
	    xd.dumpAll();
	    xd.getElementByTagName('book');
	    xmldom.Element bookElement = document.getElementByTagName('book');
	    document.removeChild(bookElement);
	    document.dump();
	    document.getElementsByPath('book/title');
	    document.getValue('title');
	    document.hasAttributes();
	    document.hasChildNodes();
	    document.firstChild();
	    document.cloneNode();
	    document.textContent();
	    document.isEqualNode(bookElement);
	    document.isSameNode(bookElement);
	    document.ownerDocument();
    }
}