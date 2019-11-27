public class CriterionWrapper{
	public CriterionWrapper(){
		GroupName = '';
		IsParent = false;
		fieldsDetail = new List<Criterion>();
	}
	@AuraEnabled public String GroupName;
	@AuraEnabled public Boolean IsParent;
	@AuraEnabled public List<Criterion> fieldsDetail;
}