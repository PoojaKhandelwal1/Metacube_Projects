public with sharing class FormRepositoryWrapper {
    
    public String Id;
    public String FormName;
    public String Description;
    public String GroupingName;
    public Boolean IsManualUpload;
    public Boolean IsActive;
    public String FormAttachmentId;
    public String FormAttachmentURL;
    public String FormNameWithExtension;
    public Boolean IsEditable;
    public String FormEditConfig;
    public String EditModalName;
    
    public FormRepositoryWrapper(Form__c FormRec) {
        this.Id = FormRec.Id;
        this.FormName = FormRec.Name;
        this.Description = FormRec.Description__c;
        this.GroupingName = FormRec.Grouping_Name__c;
        this.IsManualUpload = FormRec.Is_Manual_Upload__c;
        this.IsActive = FormRec.Is_Active__c;
        if(FormRec.Attachments.size() > 0) {
            this.FormAttachmentId = FormRec.Attachments[0].Id;
            this.FormAttachmentURL = '/servlet/servlet.FileDownload?file='+FormAttachmentId;
        }
        this.IsEditable = FormRec.Is_Editable__c;
        this.FormEditConfig = FormRec.Is_Editable__c ? FormRec.Form_Edit_Config__c : null;
        this.EditModalName = FormRec.Edit_Modal_Name__c;
    }
    
    public static List<String> getFormFieldsList() {
       return new List<String>{ 'Id', 'Name', 'Description__c', 'Grouping_Name__c', 'Is_Active__c', 'Is_Manual_Upload__c', 'Is_Editable__c', 'Form_Edit_Config__c', 'Edit_Modal_Name__c'};
    }
}