public with sharing class SearchLeadResultWrapper {
	
	public Integer code;
	public List<LeadWrapper> data;
	public String message;
	
	public class LeadWrapper {
		public Integer id;
		public String first_name;
		public String last_name;
		public Integer user_id;
		public String company_id;
		public String phone;
		public String mobile;
		public String work_number;
		public String address;
		public String email;
		public String zip;
		public String city;
		public String state;
		public String status;
		public String lead_status;
		public String sales_step;
		public Integer year;
		public String make;
		public String model;
		
		public String makeId;
		public String modelId;
		
		public String vin;
		public String stock_num;
		public String class_replaceKey;
		public String created;
		public String modified;
		public String crm_lead_url;
		public String dealer_id;
		public String dealervu_customer_id;
		public String dealervu_deal_id;
		public String dealervu_inventory_id;
	}

	public static SearchLeadResultWrapper parse(String json){
		return (SearchLeadResultWrapper) System.JSON.deserialize(json, SearchLeadResultWrapper.class);
	}

}