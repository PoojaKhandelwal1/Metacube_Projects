/**
 * Author: Hitesh Gupta
 * Since: Aug 30, 2017 
 * Name: LinkedFeeWrapper
 * Description:  Used to convert LinkedFee serialize and deserialize operations
**/
public with sharing class LinkedFeeWrapper {
    
	public String Id;
	public String FeeCode;
	public String FeeId;
	public String FeeDescription;
	public String RelatedTo;
	public Decimal Price;
	
	public LinkedFeeWrapper(Linked_Fee__c linkfee){
		Id = linkfee.Id;
		FeeCode = linkfee.Fee__r.Code__c;
		FeeId = linkfee.Fee__c;
		FeeDescription = linkfee.Description__c == null ? linkfee.Fee__r.Description__c : linkfee.Description__c;
		Price = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
		RelatedTo = linkfee.Related_To__c;
	}
	
	
	public class LinkedFeeOverviewWrapper{
		String SectionName;
		Integer Count;
		
		public LinkedFeeOverviewWrapper(String SectionName, Integer Count){
			this.SectionName = SectionName;
			this.Count = Count;
		}
	}
	
	
	/**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> LinkedFeeFieldList = new List<String>{ 'Id', 
                                                        'Description__c',
                                                        'Fee__c',
                                                        'Fee__r.Code__c',
                                                        'Fee__r.Description__c',
                                                        'Fee__r.Price__c',
                                                        'Price__c',
                                                        'Related_To__c'
                                                };
        return LinkedFeeFieldList;
    }
}