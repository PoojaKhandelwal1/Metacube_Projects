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
/**
 * VF Page: Add Opportunity Attributes  
 * Description: Controller for Add Opportunity Attributes
 * Last modified by: Rajesh @Jan/20/2017
 */
public with sharing class NewOpportunityAttributeController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public List<ProductWrapper> productList { get; set; }
    public Integer number_of_page {
        get {
            if (number_of_page == null) {
                return 0;
            } else {
                return number_of_page;
            }
        }
        set;
    }
    public Integer totalPage {
        get {
            if (totalPage == null) {
                return 0;
            } else {
                return totalPage;
            }
        }
        set;
    }
    public Integer noOfRecords {
        get {
            if (noOfRecords == null) {
                return 0;
            } else {
                return noOfRecords;
            }
        }
        set;
    }
    public Integer size {
        get {
            if (size == null) {
                return 0;
            } else {
                return size;
            }
        }
        set;
    }
    public Boolean hasPrevious { get; set; }
    public Boolean hasNext { get; set; }
    public Integer pageNumber { get; set; }
    public String pageNumberString {
        get {
            return String.valueOf(pageNumber);
        }
        set;
    }
    public Integer currentPageNumber { get; set; }
    public List<String> alphabets { get; set; }
    public String character { get; set; }
    public String errorMsg { get; set; }
    public String appliedFilter { get; set; }
    public String searchText { get; set; }
    public List<FilterWrapper> filterList { get; set; }
    public List<SelectOption> productFields { get; set; }
    public List<SelectOption> operators { get; set; } 
    private Set<String> selectedProducts;
    private String attId;
    private String characterString;
    private String whereClauseProduct;
    private Set<String> alreadyCreatedProductAttributes;
    private Map<String, String> operatorMap;
    private Map<String, String> productFieldMap;
    private Map<Integer, List<Id>> mapProduct;
    private Set<String> allProductIds;
    public Boolean isOpportunityProductAttribute { get; set; }
    
    /**
     * Constructor
     */
    public NewOpportunityAttributeController(ApexPages.StandardSetController controller) {
        attId = ApexPages.currentPage().getParameters().get('id');
        Attribute__c rootAtt = [SELECT Id, Attribute_Mapping__c, Product_Attribute_Mapping_Detail__c
                                FROM Attribute__c WHERE Id = :attId];

        if (rootAtt != null && rootAtt.Attribute_Mapping__c != null
                && rootAtt.Product_Attribute_Mapping_Detail__c == 'OpportunityOpportunityLineItemProduct2') {
            isOpportunityProductAttribute = true;
            //Check User premission
            checkPermissions();
            size = 20;
            pageNumber = 0;
            currentPageNumber = 0;
            searchText = '';
            errorMsg = '';
            appliedFilter = '';
            character = 'All';
            characterString = '';
            whereClauseProduct = '';
            mapProduct = new Map<Integer, List<Id>>();
            productList = new List<ProductWrapper>();
            selectedProducts = new Set<String>();
            allProductIds = new Set<String>();        
            productFields = new List<SelectOption>();
            productFields.add(new SelectOption('', system.Label.None));
            productFields.add(new SelectOption('Name', Product2.Name.getDescribe().getLabel()));
            productFields.add(new SelectOption('ProductCode', Product2.ProductCode.getDescribe().getLabel()));
            productFields.add(new SelectOption('Family', Product2.Family.getDescribe().getLabel()));
            productFields.add(new SelectOption('Description', Product2.Description.getDescribe().getLabel()));        
            productFieldMap = new Map<String, String>();
            
            for (SelectOption so : productFields) {
                productFieldMap.put(so.getValue(), so.getLabel());
            }
            
            operators = new List<SelectOption>();
            operators.add(new SelectOption('0', system.Label.None));
            operators.add(new SelectOption('1', system.Label.equals));
            operators.add(new SelectOption('2', system.Label.not_equals_to));
            operators.add(new SelectOption('3', system.Label.starts_with));
            operators.add(new SelectOption('4', system.Label.contains));
            operators.add(new SelectOption('5', system.Label.does_not_contain));
            operators.add(new SelectOption('6', system.Label.less_than));
            operators.add(new SelectOption('7', system.Label.greater_than));
            operators.add(new SelectOption('8', system.Label.less_or_equal));
            operators.add(new SelectOption('9', system.Label.greater_or_equal));
            operators.add(new SelectOption('10', system.Label.includes));
            operators.add(new SelectOption('11', system.Label.excludes));
            operators.add(new SelectOption('12', system.Label.within));
            
            operatorMap = new Map<String, String>();
            operatorMap.put('0', '');
            operatorMap.put('1', '=');
            operatorMap.put('2', '!=');
            operatorMap.put('3', 'like \'');
            operatorMap.put('4', 'like \'%');
            operatorMap.put('5', 'not');
            operatorMap.put('6', '<');
            operatorMap.put('7', '>');
            operatorMap.put('8', '<=');
            operatorMap.put('9', '>=');
            operatorMap.put('10', 'includes');
            operatorMap.put('11', 'excludes');
            operatorMap.put('12', 'within');
            
            filterList = new List<FilterWrapper>();
            filterList.add(new FilterWrapper());
            filterList.add(new FilterWrapper());
            filterList.add(new FilterWrapper());
            filterList.add(new FilterWrapper());
            filterList.add(new FilterWrapper());
            
            alphabets = new List<String> {
                'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', System.Label.other, System.Label.All
            };
            searchProduct();
            alreadyCreatedProductAttributes = new Set<String>();
        
            for (Attribute__c att : [SELECT Id, Product_ID__c FROM Attribute__c
                                        WHERE Parent__c = :attId LIMIT :Limits.getLimitQueryRows()]) {
                alreadyCreatedProductAttributes.add(att.Product_ID__c);
            }
        } else {
            isOpportunityProductAttribute = false;
        }
    }

    /**
     * Method to Show by alphabets
     */
    public void showResultsByAlphabet() {
        characterString = '';
        
        if (character.trim().length() != 0) {
            
            if (character == 'other') {
                characterString = ' Name like \'%[^0-9]%\' ';
            }
                
            if (character == 'all') {
                characterString = '';
            } else {
                characterString = ' Name like \'' + String.escapeSingleQuotes(character) + '%\' ';
            }
            searchProduct();
        }
    }
    
    /**
     * Method to clear filters
     */
    public PageReference clearFilters() {
        errorMsg = '';
        appliedFilter = '';
        whereClauseProduct = '';
        
        if (searchText != null && searchText.trim().length() > 0) {
            String searchValue = '%' + searchText.replace('*', '%') + '%';
            searchValue = String.escapeSingleQuotes(searchValue);
            searchValue = '\'' + searchValue + '\'';
            whereClauseProduct = ' WHERE Name LIKE ' + searchValue + ' ';
        }
        filterList = new List<FilterWrapper>();
        filterList.add(new FilterWrapper());
        filterList.add(new FilterWrapper());
        filterList.add(new FilterWrapper());
        filterList.add(new FilterWrapper());
        filterList.add(new FilterWrapper());
        searchProduct();
        return null;
    }
    
    /**
     * Method to search by String and filters
     */
    public PageReference showResultsByKeyword() {
        try {
            errorMsg = '';
            appliedFilter = '';
            whereClauseProduct = '';
            
            if (searchText != null && searchText.trim().length() > 0) {
                String searchValue = '%' + searchText.replace('*', '%') + '%';
                searchValue = String.escapeSingleQuotes(searchValue);
                searchValue = '\'' + searchValue + '\'';
                whereClauseProduct = ' WHERE Name LIKE ' + searchValue + ' ';
            }
            
            
            if (filterList != null) {
                String filetrString = '';
                Integer index = 1;
                
                for (FilterWrapper FW : filterList) {
                    
                    if (FW.selectedOperator != null) {
                        String operator = operatorMap.get(FW.selectedOperator);
                        system.debug(FW.selectedField + ' &&&&&&&&&& ' + operator);
                       
                        if (operator != null && operator != '' && FW.selectedField != null && FW.selectedField != '' && !operator.contains('within') 
                        							&& !operator.contains('includes') && !operator.contains('excludes')) {
                            filetrString = createFilter(FW, index);
                            
                            if (filetrString != '') {
                                whereClauseProduct += (whereClauseProduct.contains('WHERE') ? ' and ' : ' WHERE ') + filetrString;
                            }
                        }
                    }
                    index++;
                }
            }
            searchProduct();
        } catch (Exception e) {
            Apexpages.addMessages(e);
        }
        return null;
    }
    
    /**
     * Method to create filter for query String
     */
    private String createFilter(FilterWrapper FW, Integer index) {
        String tempString = '';
        
        if (FW.selectedField != '' && FW.selectedOperator != '') {
            String operator = String.escapeSingleQuotes(operatorMap.get(FW.selectedOperator));
            FW.value = String.escapeSingleQuotes(FW.value);
            FW.selectedField = String.escapeSingleQuotes(FW.selectedField); 
            
            if (operator.contains('like')) {
                tempString = FW.selectedField + ' ' + operator + FW.value + '%\'';
                
                if (appliedFilter == '') {
                    appliedFilter = productFieldMap.get(FW.selectedField) + '(' + FW.value + ')';
                } else {
                    appliedFilter += ', ' + productFieldMap.get(FW.selectedField) + '(' + FW.value + ')';
                }
            } else if (operator.contains('not')) {
                tempString = '(' + operator + ' ' + FW.selectedField + ' like \'%' + FW.value + '%\')';
                
                if (appliedFilter == '') {
                    appliedFilter = productFieldMap.get(FW.selectedField) + '(' + FW.value + ')';
                } else {
                    appliedFilter += ', ' + productFieldMap.get(FW.selectedField) + '(' + FW.value + ')';
                }
            } else {
                tempString = FW.selectedField + ' ' + operator + ' \'' + FW.value + '\'';
                
                if (appliedFilter == '') {
                    appliedFilter = productFieldMap.get(FW.selectedField) + '(' + FW.value + ')';
                } else {
                    appliedFilter += ', ' + productFieldMap.get(FW.selectedField) + '(' + FW.value + ')';
                }
            }
        }
        return tempString;
    }
    
    /**
     * Method to search products
     */
    public void searchProduct() {
        pageNumber = 0;
        currentPageNumber = pageNumber;
        noOfRecords = 0;
        hasNext = false;
        hasPrevious = false;
        mapProduct = new Map<Integer, List<Id>>();
        allProductIds = new Set<String>();
        Set<String> priceBookIds = new Set<String>();        
        
        if (whereClauseProduct == '' && characterString == '') {
            List<Product2> tempProductList = [SELECT Id FROM Product2 ORDER BY Name LIMIT :limits.getLimitQueryRows()];
            allProductIds = new Set<String>();
            
            for (Product2 pbe : tempProductList) {
                allProductIds.add(pbe.Id);
            }
        } else {
            String tempQuery = '';
            tempQuery = 'SELECT Id FROM Product2 ' + whereClauseProduct + (characterString != '' ? (whereClauseProduct.contains('where') ? ' and ' : ' where ') 
            									+ characterString : '') + ' ORDER BY Name LIMIT 49900';
            List<Product2> tempProductList = database.query(tempQuery);
            allProductIds = new Set<String>();
            
            for (Product2 pbe : tempProductList) {
                allProductIds.add(pbe.Id);
            }
        }
        noOfRecords = allProductIds.size();
        totalPage = noOfRecords / size;
        
        if (math.mod(noOfRecords, size) > 0) {
            totalPage += 1;
        }
        next();
    }
    
    /**
     * Method to jump on any page
     */
    public void setPageNumber() {
        Integer nextPage = PageNumber;
        
        if (PageNumber < 1) {
            PageNumber = 0;
            nextPage = 1;
            currentpageNumber = 0;
        } else {
            PageNumber = currentpageNumber;
        }
        
        if (nextPage < currentpageNumber) {
            List<Product2> tempList;
            pageNumber = nextPage;
            Set<Id> productIds = new Set<Id>();
            
            if (mapProduct != null && mapProduct.size() > 0 && mapProduct.containsKey(nextPage)) {
                productIds.addAll(mapProduct.get(nextPage));
            }
            
            for (ProductWrapper PW : productList) {
                
                if (PW.isSelected) {
                    selectedProducts.add(PW.product.Id);
                } else {
                	selectedProducts.remove(PW.product.Id);
                } 
            }
            productList = new List<ProductWrapper>();
            tempList = [SELECT Id, Name, ProductCode, Description, Family FROM Product2 WHERE Id IN :allProductIds and Id IN :productIds ORDER BY Name LIMIT :size];
            
            for (Product2 product : tempList) {
                
                if (productList.size() < size) {
                    productList.add(new ProductWrapper((selectedProducts.contains(product.Id) ? true : false), product));
                }
            }
            
            if (pageNumber == 1) {
                hasPrevious = false;
            }
            hasNext = true;
            currentPageNumber = nextPage; 
        } else if (nextPage > currentpageNumber) {
           
            if (nextPage > totalPage) {
                nextPage = totalPage;
                
                if (PageNumber == totalPage) {
                    PageNumber--;
                    currentpageNumber--;
                }
            }
            
            if (currentpageNumber < nextPage) {
                Integer totalSize = (nextPage - currentpageNumber) * size;
                Integer tempPageNo = pageNumber + 1;
                List<Product2> tempList;
                pageNumber = nextPage;
                Set<Id> productIds = new Set<Id>();
                
                if (mapProduct != null && mapProduct.size() > 0) {
                    
                    for (Integer pageNo : mapProduct.keySet()) {
                       
                        if (pageNo < pageNumber) {
                            productIds.addAll(mapProduct.get(pageNo));
                        }
                        
                        if (pageNumber == totalPage && pageNo == (pageNumber - 1)) {
                            tempPageNo = pageNumber;
                        }
                    }
                }
                
                for (ProductWrapper PW : productList) {
                   
                    if (PW.isSelected) {
                        selectedProducts.add(PW.product.Id);
                    } else {
                        selectedProducts.remove(PW.product.Id);
                    }
                }
                productList = new List<ProductWrapper>();
                tempList = [SELECT Id, Name, ProductCode, Description, Family FROM Product2 WHERE Id IN :allProductIds and Id NOT IN :productIds ORDER BY Name LIMIT :totalSize + 1];
                List<id> tempProductIds = new List<Id>();
                
                for (Product2 product : tempList) {
                    
                    if (tempProductIds.size() < size) {
                        tempProductIds.add(product.Id);
                        
                        if (tempPageNo == nextPage) {
                            productList.add(new ProductWrapper((selectedProducts.contains(product.Id) ? true : false), product));
                        }
                    } 
                   
					if (tempProductIds.size() == size) {
                        
                        if (!mapProduct.containsKey(tempPageNo)) {
                            mapProduct.put(tempPageNo, new List<Id>());
                        }
                        mapProduct.get(tempPageNo).addAll(tempProductIds);
                        tempPageNo++;
                        tempProductIds.clear();
                    }
                }
                
                if (tempList.size() > totalSize) {
                    hasNext = true;
                } else {
                    hasNext = false;
                }
                
                if (pageNumber > 1) {
                    hasPrevious = true;
                }
        
                currentPageNumber = pageNumber;
            } 
        }
    }

    /**
     * Method to move on next page
     */
    public void next() {
        List<Product2> tempList;
        pageNumber++;
        Set<Id> productIds = new Set<Id>();
        
        if (mapProduct != null && mapProduct.size() > 0) {
            
            for (Integer pageNo : mapProduct.keySet()) {
                
                if (pageNo < pageNumber) {
                    productIds.addAll(mapProduct.get(pageNo));
                }
            }
        }
        
        for (ProductWrapper PW : productList) {
            
            if (PW.isSelected) {
                selectedProducts.add(PW.product.Id);
            } else {
                selectedProducts.remove(PW.product.Id);
            }
        }
        productList = new List<ProductWrapper>();
        tempList = [SELECT Id, Name, ProductCode, Description, Family FROM Product2 WHERE Id IN :allProductIds and Id NOT IN :productIds ORDER BY Name LIMIT :size + 1];
        
        if (!mapProduct.containsKey(pageNumber)) {
            mapProduct.put(pageNumber, new List<Id>());
        }
        
        for (Product2 product : tempList) {
            
            if (productList.size() < size) {
                hasNext = false;
                hasPrevious = false;
                mapProduct.get(pageNumber).add(product.Id);
                productList.add(new ProductWrapper((selectedProducts.contains(product.Id) ? true : false), product));
            } else {
                hasNext = true;
                break;
            }
        }
        
        if (pageNumber > 1) {
            hasPrevious = true;
        } 
        currentPageNumber = pageNumber;
    }
    
    /**
     * Method to move on previous page
     */
    public void previous() {
        List<Product2> tempList;
        pageNumber--;
        Set<Id> productIds = new Set<Id>();
        
        if (mapProduct != null && mapProduct.size() > 0) {
           
            for (Integer pageNo : mapProduct.keySet()) {
                
                if (pageNo == pageNumber) {
                    productIds.addAll(mapProduct.get(pageNo));
                }
            }
        }
        
        for (ProductWrapper PW : productList) {
            
            if (PW.isSelected) {
                selectedProducts.add(PW.product.Id);
            } else {
                selectedProducts.remove(PW.product.Id);
            }
        }
        productList = new List<ProductWrapper>();
        tempList = [SELECT Id, Name, ProductCode, Description, Family FROM Product2 WHERE Id IN :allProductIds and Id IN :productIds ORDER BY Name LIMIT :size];
        
        for (Product2 product : tempList) {
            
            if (productList.size() < size) {
                productList.add(new ProductWrapper((selectedProducts.contains(product.Id) ? true : false), product));
            }
        }
        
        if (pageNumber == 1) {
            hasPrevious = false;
        }
        hasNext = true;
        currentPageNumber = pageNumber;
    }

    /**
     * Method to create product Attributes
     */
    public PageReference createProductAttributes() {
        Savepoint sp = Database.setSavepoint();
        //Check User premission
        if (checkPermissions()) {
        	
	        try {
	            String labelId = '';
	            Attributes_Labels__c attributeLabel;
	            List<Attribute__c> productAttributes = new List<Attribute__c>();
	            
	            for (ProductWrapper PW : productList) {
	               
	                if (PW.isSelected) {
	                    selectedProducts.add(PW.product.Id);
	                } else {
	                    selectedProducts.remove(PW.product.Id);
	                }
	            }
	            
	            if (selectedProducts.size() == 0) {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, system.Label.select_one_product));
	                return null;
	            }
	            Set<String> productIds = new Set<String>();
	            String productNames = '';
	            
	            for (Product2 product : [SELECT Id, Name FROM Product2 WHERE Id IN :selectedProducts]) {
	               
	                if (alreadyCreatedProductAttributes.contains(product.Id)) {
	                    
	                    if (productNames == '') {
	                        productNames = product.Name;
	                    } else {
	                        productNames += ', ' + product.Name;
	                    }
	                }
	                
	                if (product.Name.length() <= 80) {
	                    productAttributes.add(new Attribute__c(name = product.Name, Parent__c = attId, Product_ID__c = product.Id));
	                    productIds.add(product.Id);
	                }
	            }
	            
	            if (productNames != null && productNames != '') {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, system.Label.Duplicate_product_check+'<br/><br/>' + productNames));
	                return null;
	            } else if(selectedProducts.size()+alreadyCreatedProductAttributes.size() > 500) {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, system.Label.More_than_500_error));
	                return null;
	            }
	            
	            //re #988
	            //re #988
	            if (attId != null && attId != '') {
	                List<Attribute__c> tempList = [SELECT Id, Product_ID__c, (SELECT Label__c, Attribute__c FROM Attributes_Labels__r LIMIT 1) FROM Attribute__c WHERE Id = :attId LIMIT 1];
	                
	                if (tempList.size() > 0) {
	                    labelId = tempList[0].Product_ID__c;
	                    attributeLabel = (tempList[0].Attributes_Labels__r.size() > 0 ? tempList[0].Attributes_Labels__r[0] : null);
	                }
	            }
	            
	            if (productAttributes.size() > 0) {
	                insert productAttributes;
	                List<Attributes_Labels__c> attFilters = new List<Attributes_Labels__c>();
	               
	                for (Attribute__c att : productAttributes) {
	                    attFilters.add(new Attributes_Labels__c(Attribute__c = att.Id, Label__c = labelId));
	                }
	                
	                if (attFilters.size() > 0) {
	                    insert attFilters;
	                }
	               
	                if (attributeLabel != null) {
	                    delete attributeLabel;
	                }
	                //re #946
	                database.executeBatch(new Batch_AddProductAttributesToAccount(productIds), 10);
	            }
	            return new Pagereference('/' + attId);
	        } catch (Exception e) {
	            Apexpages.addMessages(e);
	            database.rollback(sp);
	        }
	        return null;
        } else {
        	return null;
        }
    }

    /**
     * Method to cancel
     */
    public PageReference cancel() {
        return new Pagereference('/' + attId);
    }
    
    /**
     * Product Wrapper Class
     */
    public class ProductWrapper {
        public Boolean isSelected { get; set; }
        public Product2 product { get; set; }
        public ProductWrapper(Boolean isSelected, Product2 product) {
            this.product = product;
            this.isSelected = isSelected;
        }
    }

    /**
     * Filter Wrapper Class
     */
    public class FilterWrapper {
        public String selectedField { get; set; }
        public String selectedOperator { get; set; }
        public String value { get; set; }
        public FilterWrapper() {
            selectedField = '';
            selectedOperator = '';
            value = '';
        }
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Boolean isDeletePermission = false;
    	Boolean isUpsertPermission = false; 
    	
    	fieldMap.put(UtilityController.appNamespace() + 'Attribute__c', new Set<String> { 'Name',
            										UtilityController.appNamespace() + 'Parent__c',
            										UtilityController.appNamespace() + 'Product_ID__c'}); 
    	 
    	       		
        fieldMap.put(UtilityController.appNamespace() + 'Attributes_Labels__c', new Set<String> { 
            										UtilityController.appNamespace() + 'Attribute__c',
            										UtilityController.appNamespace() + 'Label__c'}); 
      
    	isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Attributes_Labels__c'}); 
        
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);  
                 
        return (isUpsertPermission && isDeletePermission);  
    }
}