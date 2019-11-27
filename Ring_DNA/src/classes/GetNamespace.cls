public class GetNamespace {
	public String namespace{get; set;}
	private String orgNamespace = [select NamespacePrefix from ApexClass where Name = 'TargetListController'].NamespacePrefix;

	public GetNamespace(ApexPages.StandardController stdController) {
		namespace = orgNamespace == null ? 'c' : orgNamespace;
	} 
    public GetNamespace(ApexPages.StandardSetController stdController) {
        namespace = orgNamespace == null ? 'c' : orgNamespace;
    }
	public GetNamespace() {
		namespace = orgNamespace == null ? 'c' : orgNamespace;
	}
}