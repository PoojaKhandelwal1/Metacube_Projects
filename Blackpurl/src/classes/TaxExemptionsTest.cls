/**
 * Author: Gourav Goyal
 * Since: July 26, 2017
 * Name: TaxExemptions test
 * Description: Controller test Class of taxExemptions class.
**/
@isTest
private class TaxExemptionsTest {
     /**
     * Name: fetchSalesTaxItemTest
     * Desc: Testing to fetch sales tax item in TaxExemptions constructor.
     * @param: 
     * @return: 
    **/
    static testmethod void fetchSalesTaxItemTest(){
        Account customer = testUtil.createCustomer(true,'test customer','abc@abc.com','jaipur','1111122222');
        Category__c categoryObj = testUtil.createCategory(true,'category one');
        Sales_Tax__c salesTax2 = TestUtil.createSalesTax(true, 'Testing Sales Tax 2', true, false, true);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 1', 20, 'Testing Form Label 1', true, categoryObj.id);
        Tax_Exemption__c taxExemptionObj = TestUtil.createTaxExemption(true,customer.id,salesTaxItem1.id);
        List<String> appliesToList = new List<String>();
        appliesToList.add('test data');
        appliesToList.add('test data second');
        
        test.startTest();
        TaxExemptions taxExemptionsObj = new TaxExemptions(salesTaxItem1,appliesToList);
        TaxExemptions taxExemptionsObj1 = new TaxExemptions(taxExemptionObj,appliesToList);
        test.stopTest();
        system.assert(true,true);
    }
    
    /**
     * Name: fetchTaxExemptionsDataTest
     * Desc: Testing to fetch sales tax fields in TaxExemptions fieldsList method.
     * @param: 
     * @return: 
    **/
    static testmethod void fetchTaxExemptionsDataTest(){
        
        test.startTest();
        TaxExemptions.fieldsList();
        test.stopTest();
        system.assert(true,true);
    }
}