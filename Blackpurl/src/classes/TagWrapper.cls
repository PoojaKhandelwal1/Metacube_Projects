/**
 * Author: Tarun Khandelwal
 * Since: Sept 14, 2017 
 * Name: TagWrapper
 * Description: Used to handle all JSON related work
**/
public with sharing class TagWrapper {
    
    public String Id;
	public String Name;
	public Boolean IsActive;
	public DateTime CreatedDate;
	
	public TagWrapper(Tag__c tagRec) {
		this.Id = tagRec.Id;
		this.Name = tagRec.Name__c;
		this.IsActive = tagRec.Active__c;
		this.CreatedDate = tagRec.CreatedDate;
	}
	
	/**
     * Name: fieldsList
     * Desc: Method to get all fields related to Tag object
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getTagFieldList(){
        return new List<String>{ 'Name__c',
                                'Active__c',
                                'CreatedDate'
                        };
    }
}