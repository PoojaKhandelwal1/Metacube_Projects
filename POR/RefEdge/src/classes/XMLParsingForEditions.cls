/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, 
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, 
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR, 
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF 
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING, 
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS 
 * WRITTEN CONSENT FROM COMPANY.
 */
public with sharing class XMLParsingForEditions {

    private map < String, List < String >> featureMap;
    public String edition {
        get;
        set;
    }
    
    public XMLParsingForEditions() {
        featureMap = new map < String, List < String >> ();
    }
    
    public map < String, List < String >> getAllFeatures(string str) {
        String r = parse(str);
        return featureMap;
    }
    
    private String parse(String toParse) {
        DOM.Document doc = new DOM.Document();
        try {
            doc.load(toParse);
            DOM.XMLNode root = doc.getRootElement();
            return walkThrough(root, '');
        } catch (System.XMLException e) { // invalid XML
            return e.getMessage();
        }
    }

    private String walkThrough(DOM.XMLNode node, String feature) {
        String result = '\n';
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            result += 'Element: ' + node.getName();
            if (node.getName() == 'edition') {
                if (node.getAttributeCount() > 0) {
                    for (Integer i = 0; i < node.getAttributeCount(); i++) {
                        if (node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)) == edition) {
                            for (Dom.XMLNode child: node.getChildElements()) {
                                result += walkThrough(child, '');
                            }
                        }
                    }
                }
            } else if (node.getName() == 'feature') {
                if (node.getAttributeCount() > 0) {
                    for (Integer i = 0; i < node.getAttributeCount(); i++) {
                        featureMap.put(node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)), new list < String > ());
                        feature = node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
                        for (Dom.XMLNode child: node.getChildElements()) {
                            result += walkThrough(child, feature);
                        }
                    }
                }
            } else if (node.getName() == 'subfeature') {
                if (node.getAttributeCount() > 0) {
                    for (Integer i = 0; i < node.getAttributeCount(); i++) {
                        featureMap.get(feature).add(node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i)));
                    }
                }
            } else {
                for (Dom.XMLNode child: node.getChildElements()) {
                    result += walkThrough(child, feature);
                }
            }
            return result;
        }
        return ''; //should never reach here 
    }
}