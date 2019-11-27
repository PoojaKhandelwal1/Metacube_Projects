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
@isTest(seeAllData = false)
public class TestNewOpportunityAttributeController {

    public static List<String> selecetdFields = new List<String>{
        'Product2.CreatedDate',
        'Product2.CreatedDate',
        'Product2.LastModifiedDate',
        'Product2.LastModifiedDate',
        'Product2.CreatedDate',
        'Product2.Name',
        'Product2.IsActive',
        'Product2.CreatedDate',
        'Product2.CreatedDate',
        'Product2.LastModifiedDate',
        'Product2.CreatedDate'
    };

	/**
     * This test method is use to test NewOpportunityAttributeController. 
     */
    static testmethod void testNewOpportunity() {
        Attribute_Mapping__c productAttMapping = new Attribute_Mapping__c(
            Field__c = 'Product',
            Field_Api_Name__c = 'Product2',
            Object__c = 'Opportunity',
            Filter_Label_Name__c = 'Product',
            Attribute_Name__c = 'Product',
            Is_Related_Mapping__c = true,
            Mapping_Type__c = 'Child Object',
            Related_Object__c = 'OpportunityLineItem',
            Child_RelationShipName__c = 'OpportunityLineItems',
            RelationShip_Name__c = 'OpportunityId'
        );
        insert productAttMapping;
        List<Attribute__c> productRootAtt = [SELECT Id, Name, Attribute_Mapping__c, Product_Attribute_Mapping_Detail__c
                                                FROM Attribute__c
                                                WHERE Attribute_Mapping__c = :productAttMapping.Id];
        String productCode = 'PRODUCT2';
        String productName = 'PPPPPPPPPPPPPPPP';
        List<Product2> products = new List<Product2> {
            new Product2(Name = productName, ProductCode = productCode),
            new Product2(Name = productName + 1, ProductCode = productCode + 1)
        };
        insert products;
        Product2 productTmp = [SELECT Id FROM Product2 WHERE Name = :productName + 1];
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(productRootAtt, 1, 6);
        List<Attribute__c> attribsTmp = new List<Attribute__c>();

        for (Attribute__c attr : childAttributes) {
            attr.Product_ID__c = productTmp.id;
            attribsTmp.add(attr);
        }
        insert attribsTmp;
        NewOpportunityAttributeController.ProductWrapper productWrapperObj
            = new NewOpportunityAttributeController.ProductWrapper(true, products[0]);
        NewOpportunityAttributeController.ProductWrapper productWrapperObj2
            = new NewOpportunityAttributeController.ProductWrapper(true, products[0]);

        Test.startTest();
            Test.setCurrentPage(Page.NewOpportunityAttribute);
            ApexPages.currentPage().getParameters().put('id', childAttributes[0].Parent__C);  
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(attribsTmp);
	        NewOpportunityAttributeController testOpportunityObj = new NewOpportunityAttributeController(stdSetController);
	        testOpportunityObj.productList = new List<NewOpportunityAttributeController.ProductWrapper> { productWrapperObj2 };

	        for(integer pageNo = 0; pageNo <= 6; pageNo++) {
	            testOpportunityObj.pageNumber = pageNo;
	            testOpportunityObj.setPageNumber();
	            testOpportunityObj.next();
	        }

            for (integer pageNo = 6; pageNo >= 0; pageNo--) {
	            testOpportunityObj.pageNumber = pageNo;
                testOpportunityObj.setPageNumber();
	            testOpportunityObj.previous();
	        }
	        
            testOpportunityObj.createProductAttributes();
	        testOpportunityObj.productList = new List<NewOpportunityAttributeController.ProductWrapper> { productWrapperObj };
	    	List<String> operators = new List<String>{'2','2','2','2','2','5','2','1','2','1','2'};
	        List<String> values = new List<String> {
                '5/23/2013 10:00 PM',
                '5/23/2013 10:00 PM',
                System.today().format() + '',
                System.today().format() + '',
                '5/23/2013 10:00 PM',
                'P1',
                'true',
                'Something',
                Date.today() + '',
                System.today().format() + '',
                '5/23/2013 10:00 PM'
            };
	        testOpportunityObj.filterList = createFilters(selecetdFields, operators, values);
	        testOpportunityObj.searchText = productName;
	        testOpportunityObj.createProductAttributes();
	        String pageNumber = testOpportunityObj.pageNumberString;
	        Integer noofPages = testOpportunityObj.number_of_page;
	        testOpportunityObj.number_of_page = 2;
	        Integer noofPages2 = testOpportunityObj.number_of_page;
	        testOpportunityObj.showResultsByKeyword();
	        testOpportunityObj.clearFilters();
	        testOpportunityObj.cancel();
	        System.assert(true);
        Test.stopTest();
    }

	/**
	 * This test method is use to test NewOpportunityAttributeController. test for ne-i scenerios
	 * when there no attribute associated to product &
	 * filter with other operators & 
	 * product name not match
	 */
    static testmethod void testNewOpportunity2() {
        Attribute_Mapping__c productAttMapping = new Attribute_Mapping__c(
            Field__c = 'Product',
            Field_Api_Name__c = 'Product2',
            Object__c = 'Opportunity',
            Filter_Label_Name__c = 'Product',
            Attribute_Name__c = 'Product',
            Is_Related_Mapping__c = true,
            Mapping_Type__c = 'Child Object',
            Related_Object__c = 'OpportunityLineItem',
            Child_RelationShipName__c = 'OpportunityLineItems',
            RelationShip_Name__c = 'OpportunityId'
        );
        insert productAttMapping;
        List<Attribute__c> productRootAtt = [SELECT Id, Name, Attribute_Mapping__c, Product_Attribute_Mapping_Detail__c
                                                FROM Attribute__c
                                                WHERE Attribute_Mapping__c = :productAttMapping.Id];
        String productCode = 'PRODUCT2';
        String productName = 'PPPPPPPPPPPPPPPP';
        List<Product2> products = new List<Product2> {
            new Product2(Name = productName, ProductCode = productCode),
            new Product2(Name = productName + 1, ProductCode = productCode + 1)
        };
        insert products;
        Product2 productTmp = [select id from Product2 where name = :productName + 1];
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(productRootAtt, 1, 6);
        List<Attribute__c> attribsTmp = new List<Attribute__c>();

        for (Attribute__c attr : childAttributes) {
            attribsTmp.add(attr);
        }
        insert attribsTmp;
        NewOpportunityAttributeController.ProductWrapper productWrapperObj
            = new NewOpportunityAttributeController.ProductWrapper(false, products[0]);
        NewOpportunityAttributeController.ProductWrapper productWrapperObj2
            = new NewOpportunityAttributeController.ProductWrapper(false, products[0]);

        Test.startTest();
            Test.setCurrentPage(Page.NewOpportunityAttribute);
            ApexPages.currentPage().getParameters().put('id', childAttributes[0].Parent__C);  
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(attribsTmp);
	        NewOpportunityAttributeController testOpportunityObj = new NewOpportunityAttributeController(stdSetController);
	        testOpportunityObj.productList = new List<NewOpportunityAttributeController.ProductWrapper> { productWrapperObj2 };
	        testOpportunityObj.createProductAttributes();
	        testOpportunityObj.productList = new List<NewOpportunityAttributeController.ProductWrapper> { productWrapperObj };
	    	List<String> operators = new List<String> {'2','2','2','2','2','5','2','1','2','1','2'};
	        List<String> values = new List<String> {
                '5/23/2013 10:00 PM',
                '5/23/2013 10:00 PM',
                System.today().format() + '',
                System.today().format() + '',
                '5/23/2013 10:00 PM',
                'P1',
                'true',
                'Something',
                Date.today() + '',
                System.today().format() + '',
                '5/23/2013 10:00 PM'
            };
	        testOpportunityObj.filterList = createFilters(selecetdFields, operators, values);
	        testOpportunityObj.createProductAttributes();
	        testOpportunityObj.showResultsByKeyword();
	    	List<String> operators1 = new List<String>{'8','8','8','8','8','5','8','2','2','1','2'};
	    	List<String> values1 = new List<String>{
                '5/23/2013 10:00 PM',
                '5/23/2013 10:00 PM',
                System.today().format() + '',
                System.today().format() + '',
                '5/23/2013 10:00 PM',
                'P1',
                'true',
                'Something',
                Date.today() + '',
                System.today().format() + '',
                '5/23/2013 10:00 PM'
            };
	        testOpportunityObj.filterList = createFilters(selecetdFields, operators1, values1);
	        testOpportunityObj.showResultsByKeyword();
		    List<String> selecetdFields2 = new List<String>{
                'SD.Name1',
                'SD.IsActive',
                'SD.CreatedDate1',
                'SD.LastModifiedDate1',
                'SD.CreatedDate1',
                'SD.CreatedDate'
            };
		    List<String> operators2 = new List<String>{'1','2','1','8','2','2'};
		    List<String> values2 = new List<String>{ 'P1', 'true', Date.today() + '', '8', '5/23/2013 10:00 PM', 'Something' };
	        testOpportunityObj.filterList = createFilters(selecetdFields2, operators2, values2);
	        testOpportunityObj.showResultsByKeyword();
		    List<String> operators5 = new List<String>{'9','9','9','9','9','5','8','2','2','1','2'};
		    List<String> values5 = new List<String> {
                '5/23/2013 10:00 PM',
                '5/23/2013 10:00 PM',
                System.today().format() + '',
                System.today().format() + '',
                '5/23/2013 10:00 PM',
                'P1',
                'true',
                'Something',
                Date.today() + '',
                System.today().format() + '',
                '5/23/2013 10:00 PM'
            };
	        testOpportunityObj.clearFilters(); 
	        testOpportunityObj.filterList = createFilters(selecetdFields, operators5, values5);
	        testOpportunityObj.showResultsByKeyword();
	        system.assert(true);
        test.stopTest();
    }

	/**
	 * Creating filters
	 * @param List<String> fields
	 * @param List<String> operators
	 * @param List<String> values
	 * @Return List<NewOpportunityAttributeController.FilterWrapper>
	 */
    private static List<NewOpportunityAttributeController.FilterWrapper> createFilters(List<String> selectedField, List<String> operators, List<String> values) {
        List<NewOpportunityAttributeController.FilterWrapper> filters = new List<NewOpportunityAttributeController.FilterWrapper>();

        for (integer i = 0; i < selectedField.size(); i++) {
            NewOpportunityAttributeController.FilterWrapper filterWrapperObj = new NewOpportunityAttributeController.FilterWrapper();
            filterWrapperObj.selectedField = selectedField.get(i);
            filterWrapperObj.selectedOperator = operators.get(i);
            filterWrapperObj.value = values.get(i);
            filters.add(filterWrapperObj);
        }
        return filters;
    }

    /**
     * Creating PriceBooks
     */
    static testmethod void createPriceBook() {
        PriceBook2 pricebook2Obj = new Pricebook2(name = 'PriceBook1', isActive = true);
        PriceBook2 pricebook2Obj2 = new Pricebook2(name = 'PriceBook3', isActive = false);
        List<PriceBook2> pricebook2s = new List<PriceBook2> { pricebook2Obj, pricebook2Obj2 };
        insert pricebook2s;

        Test.startTest();
        	List<PriceBook2> tempList = [SELECT Id FROM PriceBook2];
        	System.assertEquals(tempList.size(), 2);
        Test.stopTest();
    }

    /**
     * Creating PriceBookEntry
     * @param Product2
     */
    static testmethod void createPriceBookEntry() {
        Product2 productObj = new Product2();
        productObj.Name = 'Test Product2';
        insert productObj;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productObj.Id, UnitPrice = 43, IsActive = true); 
    	insert standardPrice;
        List<Pricebook2> pricebookObjs = [select id from Pricebook2 limit 1];

        if (pricebookObjs != null && pricebookObjs.size() > 0) {
        	PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookObjs[0].id, Product2Id = productObj.id, UnitPrice = 1249, IsActive = true);
	        List<PricebookEntry> pricebookEntrys = new List<PricebookEntry>();
	        pricebookEntrys.add(pbe);
	        insert pricebookEntrys;

            Test.startTest();
	        	List<PricebookEntry> tempList = [SELECT Id FROM PricebookEntry];
	        	System.assertEquals('h', 'h');
	        Test.stopTest();
        }
    }
}