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
    * Page: AutoAddPermission 
    * Description: Class is used to build to assign all custom permissions to profile and permission set.
    * Created by: Rajneesh @25 April 2019
*/
public with sharing class AutoAddPermissionController {
   
    /**
     * Properties and variables
     */
    public Boolean isEdit { get; set; }
    public Boolean isSLDS { get; set; }
    public String profilesToInclude { get; set; }
    public List<SelectOption> allProfile { get; set; }
    public String currentSelectedProfile { get; set; }
    public List<SelectOption> selectedProfile { get; set; }
    public String permissionToInclude { get; set; }
    public List<SelectOption> allPermissionSet { get; set; }
    public String currentSelectedPermission { get; set; }
    public List<SelectOption> selectedPermission { get; set; }
    public Boolean isprofile { get; set; }
    public String selectedVal {get;set;}
    public Integer columnSize { get; set; }
    public String RMLabel {get; set;}
    public String SULabel {get; set;}
    public Custom_Settings__c cs { get; set; }
    private List<Profile> profileList;
    private List<PermissionSet> psetList;
    private Map<String, String> permissionSetMap;
    private String suProfile;
    private String suPermissionset;
    private String rmProfile;
    private String rmPermissionset;

    public AutoAddPermissionController(ApexPages.StandardController controller) {
        cs = UtilityController.getCustomSettings();
        suProfile = '';
        rmProfile = '';
        suPermissionset = '';
        rmPermissionset = '';

        if(cs.SU_Profiles__c != null && cs.SU_Profiles__c != '') {

            for(String str : cs.SU_Profiles__c.split(',')) {
                suProfile += '@'+str+'@'+',';
            }
            suProfile.removeEnd(',');
        }

        if(cs.RM_Profiles__c != null && cs.RM_Profiles__c != '') {

            for(String str : cs.RM_Profiles__c.split(',')) {
                rmProfile += '@'+str+'@'+',';
            }
            rmProfile.removeEnd(',');
        }

        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            //  For SF1
            isSLDS = true;
            columnSize = 1;
        } else {
            // for Normal
            isSLDS = false;
            columnSize = 1;
        }    
        isEdit = false;
        RMLabel = ConstantsController.REFERENCE_MANAGER;
        SULabel = ConstantsController.STANDARD_USER;        
        loadData();       

        if(cs.SU_Permission_Sets__c != null && cs.SU_Permission_Sets__c != '') {
            
            for(String str : cs.SU_Permission_Sets__c.split(',')) {
                suPermissionset += '@'+str+'@'+',';
            }  
            suPermissionset.removeEnd(',');              
        }

        if(cs.RM_Permission_Sets__c != null && cs.RM_Permission_Sets__c != '') {
            
            for(String str : cs.RM_Permission_Sets__c.split(',')) {
                rmPermissionset += '@'+str+'@'+',';
            }
            rmPermissionset.removeEnd(',');
        }
        Map<String, Schema.SObjectType> sObjectsMap = CRUDAndFLSCheckController.sObjectsMap;
        String objectName = UtilityController.appNamespace() + 'Custom_Settings__c';
        Schema.DescribeSObjectResult sObj = sObjectsMap.get(objectName).getDescribe();
        
        if(!sObj.IsUpdateable()) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, 'Insufficient Update access rights on '+objectName+' Object.');
	        Apexpages.addMessage(message);
        }
    }

    /**
     * Method used to get record
     */
     public void loadData() {
        selectedVal = '';
        allProfile = new List<SelectOption>();
        selectedProfile = new List<SelectOption>();
        allPermissionSet =  new List<SelectOption>(); 
        selectedPermission = new List<SelectOption>();
        profileList = new List<Profile>();   
        psetList = new List<PermissionSet>();
        permissionSetMap = new Map<String, String>();

        for(profile pro : [SELECT Id, Name, CreatedDate FROM Profile LIMIT : limits.getLimitQueryRows() ]) {
            profileList.add(pro);
            allProfile.add(new SelectOption(pro.Name, pro.Name));
        }          
        
        for(PermissionSet ps : [SELECT id, Name, Label, iSCustom FROM PermissionSet WHERE IsOwnedByProfile = false]) {
            psetList.add(ps);
            allPermissionSet.add(new SelectOption(ps.Name, ps.Label));
            permissionSetMap.put(ps.Name, ps.Label);
        }         
     }

    public List<SelectOption> getSelectlist() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        options.add(new SelectOption(ConstantsController.REFERENCE_MANAGER, ConstantsController.REFERENCE_MANAGER));
        options.add(new SelectOption(ConstantsController.STANDARD_USER, ConstantsController.STANDARD_USER));
        return options;
    }
    
    /**
     * Method used to edit fields on the form :  OpportunityStageChangeAlertPage
     */
    public PageReference editForm() {        
        isEdit = true; 
        loadData();
        return null;
    }

    /**
     * Method used to update the select Lists
     */
    public void addToList() {

        if (isprofile) {

            if (profilesToInclude != null && profilesToInclude != '') {
                profilesToInclude = profilesToInclude.replace('[', '').replace(']', '');
                String[] listofGroups = profilesToInclude.split(',');  

                if (listofGroups.size() > 0 && profilesToInclude != '') {

                    for (Integer i = 0; i < listofGroups.size(); i++) {
                        selectedProfile.add(new SelectOption(listofGroups[i].trim(), listofGroups[i].trim()));

                        for (integer j = 0; j < allProfile.size(); j++) {

                            if (allProfile[j].getValue().trim() == listofGroups[i].trim()) {
                                allProfile.remove(j);
                            }
                        }
                    }
                }
            }
        } else {

            if (permissionToInclude != null && permissionToInclude != '') {
                permissionToInclude = permissionToInclude.replace('[', '').replace(']', '');
                String[] listofGroups = permissionToInclude.split(',');  

                if (listofGroups.size() > 0 && permissionToInclude != '') {

                    for (Integer i = 0; i < listofGroups.size(); i++) {
                        selectedPermission.add(new SelectOption(listofGroups[i].trim(), permissionSetMap.get(listofGroups[i].trim())));

                        for (integer j = 0; j < allPermissionSet.size(); j++) {

                            if (allPermissionSet[j].getValue().trim() == listofGroups[i].trim()) {
                                allPermissionSet.remove(j);
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Method used to update the object Lists : DMInline
     */
    public void removeFromList() {

        if (isprofile) {

            if (currentSelectedProfile != null && currentSelectedProfile != '') {
                currentSelectedProfile = currentSelectedProfile.replace('[',  '').replace(']',  '');
                String[] listofGroups = currentSelectedProfile.split(',');   
            
                if (listofGroups.size() > 0 && currentSelectedProfile != '') {
                    
                    for (Integer i = 0; i < listofGroups.size(); i++) {
                        allProfile.add(new SelectOption(listofGroups[i].trim(), listofGroups[i].trim()));
                        
                        for (integer j = 0; j < selectedProfile.size(); j++) {
                            
                            if (selectedProfile[j].getValue().trim() == listofGroups[i].trim()) {
                                selectedProfile.remove(j);
                            }
                        }
                    }
                }
            }
        } else {

            if (currentSelectedPermission != null && currentSelectedPermission != '') {
                currentSelectedPermission = currentSelectedPermission.replace('[',  '').replace(']',  '');
                String[] listofGroups = currentSelectedPermission.split(',');   
            
                if (listofGroups.size() > 0 && currentSelectedPermission != '') {
                    
                    for (Integer i = 0; i < listofGroups.size(); i++) {
                        allPermissionSet.add(new SelectOption(listofGroups[i].trim(), permissionSetMap.get(listofGroups[i].trim())));
                        
                        for (integer j = 0; j < selectedPermission.size(); j++) {
                            
                            if (selectedPermission[j].getValue().trim() == listofGroups[i].trim()) {
                                selectedPermission.remove(j);
                            }
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Method used cancel edit functionality
     */
    public PageReference cancelForm() {
        cs = UtilityController.getCustomSettings();
        loadData();
        isEdit = false;
        return null;
    }

    
    /**
     * Method used to save fields on the form 
     */
    public PageReference saveForm() {  

        Map<String, String> permissionInfoMap = new Map<String, String>();

        if(selectedVal == ConstantsController.STANDARD_USER) {
        
            if(selectedProfile != null) {
                cs.SU_Profiles__c = '';

                for (SelectOption val : selectedProfile) {
                    cs.SU_Profiles__c = cs.SU_Profiles__c + val.getValue() + ',' ;               
                }
                cs.SU_Profiles__c = cs.SU_Profiles__c.removeEnd(',');
            }
            
            if(selectedPermission != null) {
                cs.SU_Permission_Sets__c = '';
            
                for (SelectOption val : selectedPermission) {
                    cs.SU_Permission_Sets__c = cs.SU_Permission_Sets__c + val.getLabel() + ',' ; 

                    if(permissionSetMap.containsKey(val.getValue())) {
                        permissionInfoMap.put(val.getValue(), permissionSetMap.get(val.getValue()));
                    }                                      
                }
                cs.SU_Permission_Sets__c = cs.SU_Permission_Sets__c.removeEnd(','); 
            }
            operatePermission(true, cs.SU_Profiles__c, permissionInfoMap);

        } else if(selectedVal == ConstantsController.REFERENCE_MANAGER) {
            
            if(selectedProfile != null) {
                cs.RM_Profiles__c = '';

                for (SelectOption val : selectedProfile) {
                    cs.RM_Profiles__c = cs.RM_Profiles__c + val.getValue() + ',' ;               
                }
                cs.RM_Profiles__c = cs.RM_Profiles__c.removeEnd(',');
            }
            
            if(selectedPermission != null) {
                cs.RM_Permission_Sets__c = '';
            
                for (SelectOption val : selectedPermission) {
                    cs.RM_Permission_Sets__c = cs.RM_Permission_Sets__c + val.getLabel() + ',' ;
                    
                    if(permissionSetMap.containsKey(val.getValue()))
                    permissionInfoMap.put(val.getValue(), permissionSetMap.get(val.getValue()));                
                }
                cs.RM_Permission_Sets__c = cs.RM_Permission_Sets__c.removeEnd(',');
            } 
            operatePermission(false, cs.RM_Profiles__c, permissionInfoMap);
        }
        update cs;
        isEdit = false;
        return null;
    }

    /**
    * Generic method to operate for profiles and permission sets to extend access
    **/
    public void operatePermission(Boolean isStandardUsr, String ProfileInfo, Map<String, String> psInfoMap) {
		
		//Retrive static resource and from body get contents
        String resourceName = 'PermissionCheck'; 
        String nameSpace = UtilityController.appNamespace().removeEnd('__');
        StaticResource sr = Database.query('SELECT Id, Name, Body FROM StaticResource WHERE Name = :resourceName AND NamespacePrefix =: nameSpace LIMIT 1');
        blob tempBlob = sr.Body;
        String tempString = tempBlob.toString();
        tempString = tempSTring.replace('"', '');
        String[] stringArray = tempString.split('\n');
		MetadataService.MetadataPort service = createService();    
        List<MetadataService.Profile> profList = new List<MetadataService.Profile>();
		List<MetadataService.PermissionSet> permissionSetList = new List<MetadataService.PermissionSet>();
		
		if(isStandardUsr) {
			
			if(ProfileInfo != '' && ProfileInfo != null) {

				for(String profle : ProfileInfo.split(',')) {
					MetadataService.Profile profl = new MetadataService.Profile();
					
					if(profle == 'System Administrator') {
						profl.fullName = 'Admin';
					} else {
						profl.fullName = profle;
					}
					profList.add(profl);
				}
			  
				List<MetadataService.ProfileFieldLevelSecurity> fldList = new List<MetadataService.ProfileFieldLevelSecurity>();
				List<MetadataService.ProfileObjectPermissions> objList = new List<MetadataService.ProfileObjectPermissions>();
				List<MetadataService.ProfileApexPageAccess> pageLevelAccessList = new List<MetadataService.ProfileApexPageAccess>();
				List<MetadataService.ProfileApexClassAccess> classLevelAccessList = new List<MetadataService.ProfileApexClassAccess>();

				for(Integer i = 2; i < stringArray.size(); i++) {
					//  For object
					if(stringArray[i].split(';')[0].trim() != '') {
                        system.debug('===>>   '+stringArray[i].split(';')[0].trim());
						MetadataService.ProfileObjectPermissions fieldSec = new MetadataService.ProfileObjectPermissions();
						fieldSec.object_x = UtilityController.appNamespace() + stringArray[i].split(';')[0].split('/')[0].trim();
						
						if(stringArray[i].split(';')[0].split('/')[1].split('#')[0].trim() == 'Read' && Boolean.valueOf(stringArray[i].split(';')[0].split('/')[1].split('#')[1].trim())) {
							fieldSec.allowRead = true;
						} else {
							fieldSec.allowRead = false;
						}
						if(stringArray[i].split(';')[0].split('/')[2].split('#')[0].trim() == 'Edit' && Boolean.valueOf(stringArray[i].split(';')[0].split('/')[2].split('#')[1].trim())) {
							fieldSec.allowEdit = true;
						} else {
							fieldSec.allowEdit = false;
						}
						if(stringArray[i].split(';')[0].split('/')[3].split('#')[0].trim() == 'Create' && Boolean.valueOf(stringArray[i].split(';')[0].split('/')[3].split('#')[1].trim())) {
							fieldSec.allowCreate = true;
						} else {
							fieldSec.allowCreate = false;
						}
						if(stringArray[i].split(';')[0].split('/')[4].split('#')[0].trim() == 'modifyAllRecords' && Boolean.valueOf(stringArray[i].split(';')[0].split('/')[4].split('#')[1].trim())) {
							fieldSec.modifyAllRecords = true;
						} else {
							fieldSec.modifyAllRecords = false;
						}
						if(stringArray[i].split(';')[0].split('/')[5].split('#')[0].trim() == 'viewAllRecords' && Boolean.valueOf(stringArray[i].split(';')[0].split('/')[5].split('#')[1].trim())) {
							fieldSec.viewAllRecords = true;
						} else {
							fieldSec.viewAllRecords = false;
						}
						if(stringArray[i].split(';')[0].split('/')[6].split('#')[0].trim() == 'Delete' && Boolean.valueOf(stringArray[i].split(';')[0].split('/')[6].split('#')[1].trim())) {
							fieldSec.allowDelete = true;
						} else {
							fieldSec.allowDelete = false;
						}						
						objList.add(fieldSec);
					} 

					if(stringArray[i].split(';')[5].trim() != '') {
						MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();					
						fieldSec.field = UtilityController.appNamespace() + stringArray[i].split(';')[5].split('@#')[0].split('\\.')[0].trim() +'.'+
                                         UtilityController.appNamespace() + stringArray[i].split(';')[5].split('@#')[0].split('\\.')[1].trim();

						if(stringArray[i].split(';')[5].split('@#')[1].trim() == 'W') {
                            fieldSec.editable = true;
                            fieldSec.readable = true;
                        } else {
                            fieldSec.readable = true;
                            fieldSec.editable = false;
                        }   
						fldList.add(fieldSec);
					}	
					// for page Permission
					if(stringArray[i].split(';')[10].trim() != '') {
						MetadataService.ProfileApexPageAccess profPagePermission = new MetadataService.ProfileApexPageAccess();
						profPagePermission.apexPage = UtilityController.appNamespace()+stringArray[i].split(';')[10].trim();
						profPagePermission.enabled = true;
						pageLevelAccessList.add(profPagePermission);
					}

					
					// for class Permission
					if(stringArray[i].split(';')[15].trim() != '') {
						MetadataService.ProfileApexClassAccess profClassPermission = new MetadataService.ProfileApexClassAccess();
						profClassPermission.apexClass = UtilityController.appNamespace()+stringArray[i].split(';')[15].trim();
						profClassPermission.enabled = true;
						classLevelAccessList.add(profClassPermission);
					} 			
				}

				for(MetadataService.Profile mp : profList) {
					mp.fieldPermissions  = fldList ;
					mp.objectPermissions  = objList ;
					mp.pageAccesses  = pageLevelAccessList;
					mp.classAccesses  = classLevelAccessList;
				}
			} 

            if(psInfoMap.size() > 0) {
                List<MetadataService.PermissionSetObjectPermissions> objLevelAccessList = new List<MetadataService.PermissionSetObjectPermissions>();
				List<MetadataService.PermissionSetFieldPermissions> fldlevelAccessList = new List<MetadataService.PermissionSetFieldPermissions>();
				List<MetadataService.PermissionSetApexPageAccess> pageLevelAccessList = new List<MetadataService.PermissionSetApexPageAccess>();
				List<MetadataService.PermissionSetApexClassAccess> classLevelAccessList = new List<MetadataService.PermissionSetApexClassAccess>();
				
				for(String ps : psInfoMap.keySet()) {
					MetadataService.PermissionSet prmsn = new MetadataService.PermissionSet();
					prmsn.fullName = ps;
					prmsn.label = psInfoMap.get(ps);
                    permissionSetList.add(prmsn);
				}
				
				for(Integer i = 2; i < stringArray.size(); i++) {

                    //  for object permission
                    if(stringArray[i].split(';')[1].trim() != '') {
						MetadataService.PermissionSetObjectPermissions profObjectPermission = new MetadataService.PermissionSetObjectPermissions(); 
                        profObjectPermission.object_x = UtilityController.appNamespace() + stringArray[i].split(';')[1].split('/')[0].trim();
						
						if(stringArray[i].split(';')[1].split('/')[1].split('#')[0].trim() == 'Read' && Boolean.valueOf(stringArray[i].split(';')[1].split('/')[1].split('#')[1].trim())) {
							profObjectPermission.allowRead = true;
						} else {
							profObjectPermission.allowRead = false;
						}
						if(stringArray[i].split(';')[1].split('/')[2].split('#')[0].trim() == 'Edit' && Boolean.valueOf(stringArray[i].split(';')[1].split('/')[2].split('#')[1].trim())) {
							profObjectPermission.allowEdit = true;
						} else {
							profObjectPermission.allowEdit = false;
						}
						if(stringArray[i].split(';')[1].split('/')[3].split('#')[0].trim() == 'Create' && Boolean.valueOf(stringArray[i].split(';')[1].split('/')[3].split('#')[1].trim())) {
							profObjectPermission.allowCreate = true;
						} else {
							profObjectPermission.allowCreate = false;
						}
						if(stringArray[i].split(';')[1].split('/')[4].split('#')[0].trim() == 'modifyAllRecords' && Boolean.valueOf(stringArray[i].split(';')[1].split('/')[4].split('#')[1].trim())) {
							profObjectPermission.modifyAllRecords = true;
						} else {
							profObjectPermission.modifyAllRecords = false;
						}
						if(stringArray[i].split(';')[1].split('/')[5].split('#')[0].trim() == 'viewAllRecords' && Boolean.valueOf(stringArray[i].split(';')[1].split('/')[5].split('#')[1].trim())) {
							profObjectPermission.viewAllRecords = true;
						} else {
							profObjectPermission.viewAllRecords = false;
						}
						if(stringArray[i].split(';')[1].split('/')[6].split('#')[0].trim() == 'Delete' && Boolean.valueOf(stringArray[i].split(';')[1].split('/')[6].split('#')[1].trim())) {
							profObjectPermission.allowDelete = true;
						} else {
							profObjectPermission.allowDelete = false;
						}						
						objLevelAccessList.add(profObjectPermission);
					}

                    //  for field permission
                    if(stringArray[i].split(';')[6].trim() != '') {
                        MetadataService.PermissionSetFieldPermissions profFieldPermission = new MetadataService.PermissionSetFieldPermissions();
                        profFieldPermission.field = UtilityController.appNamespace() + stringArray[i].split(';')[6].split('@#')[0].split('\\.')[0].trim() +'.'+
                                                    UtilityController.appNamespace() + stringArray[i].split(';')[6].split('@#')[0].split('\\.')[1].trim();

                        if(stringArray[i].split(';')[6].split('@#')[1].trim() == 'W') {
                            profFieldPermission.editable = true;
                            profFieldPermission.readable = true;
                        } else {
                            profFieldPermission.readable = true;
                            profFieldPermission.editable = false;
                        }                        
                        fldlevelAccessList.add(profFieldPermission);
                    }

                    // for page Permission
                    if(stringArray[i].split(';')[11].trim() != '') {
                        MetadataService.PermissionSetApexPageAccess profPagePermission = new MetadataService.PermissionSetApexPageAccess();
                        profPagePermission.apexPage = UtilityController.appNamespace() + stringArray[i].split(';')[11].trim();
                        profPagePermission.enabled = true;
                        pageLevelAccessList.add(profPagePermission);
                    }

                    //  for class permission
                    if(stringArray[i].split(';')[16].trim() != '') {
                        MetadataService.PermissionSetApexClassAccess fieldSec = new MetadataService.PermissionSetApexClassAccess();            
                        fieldSec.apexClass = UtilityController.appNamespace() + stringArray[i].split(';')[16].trim();
                        fieldSec.enabled = true;            
                        classLevelAccessList.add(fieldSec);
                    } 
                    
                }

                for(MetadataService.PermissionSet ps : permissionSetList) {
					ps.fieldPermissions  = fldlevelAccessList;
					ps.objectPermissions = objLevelAccessList;
					ps.pageAccesses  = pageLevelAccessList;
					ps.classAccesses  = classLevelAccessList;
				}
            }
		} else {

            if(ProfileInfo != '' && ProfileInfo != null) {

				for(String profle : ProfileInfo.split(',')) {
					MetadataService.Profile profl = new MetadataService.Profile();
					
					if(profle == 'System Administrator') {
						profl.fullName = 'Admin';
					} else {
						profl.fullName = profle;
					}
					profList.add(profl);
				}
			  
				List<MetadataService.ProfileFieldLevelSecurity> fldList = new List<MetadataService.ProfileFieldLevelSecurity>();
				List<MetadataService.ProfileObjectPermissions> objList = new List<MetadataService.ProfileObjectPermissions>();
				List<MetadataService.ProfileApexPageAccess> pageLevelAccessList = new List<MetadataService.ProfileApexPageAccess>();
				List<MetadataService.ProfileApexClassAccess> classLevelAccessList = new List<MetadataService.ProfileApexClassAccess>();

				for(Integer i = 2; i < stringArray.size(); i++) {
					
                    //  For object
					if(stringArray[i].split(';')[2].trim() != '') {
						MetadataService.ProfileObjectPermissions fieldSec = new MetadataService.ProfileObjectPermissions(); 
                        fieldSec.object_x = UtilityController.appNamespace()+stringArray[i].split(';')[2].split('/')[0].trim();
						
						if(stringArray[i].split(';')[2].split('/')[1].split('#')[0].trim() == 'Read' && Boolean.valueOf(stringArray[i].split(';')[2].split('/')[1].split('#')[1].trim())) {
							fieldSec.allowRead = true;
						} else {
							fieldSec.allowRead = false;
						}
						if(stringArray[i].split(';')[2].split('/')[2].split('#')[0].trim() == 'Edit' && Boolean.valueOf(stringArray[i].split(';')[2].split('/')[2].split('#')[1].trim())) {
							fieldSec.allowEdit = true;
						} else {
							fieldSec.allowEdit = false;
						}
						if(stringArray[i].split(';')[2].split('/')[3].split('#')[0].trim() == 'Create' && Boolean.valueOf(stringArray[i].split(';')[2].split('/')[3].split('#')[1].trim())) {
							fieldSec.allowCreate = true;
						} else {
							fieldSec.allowCreate = false;
						}
						if(stringArray[i].split(';')[2].split('/')[4].split('#')[0].trim() == 'modifyAllRecords' && Boolean.valueOf(stringArray[i].split(';')[2].split('/')[4].split('#')[1].trim())) {
							fieldSec.modifyAllRecords = true;
						} else {
							fieldSec.modifyAllRecords = false;
						}
						if(stringArray[i].split(';')[2].split('/')[5].split('#')[0].trim() == 'viewAllRecords' && Boolean.valueOf(stringArray[i].split(';')[2].split('/')[5].split('#')[1].trim())) {
							fieldSec.viewAllRecords = true;
						} else {
							fieldSec.viewAllRecords = false;
						}
						if(stringArray[i].split(';')[2].split('/')[6].split('#')[0].trim() == 'Delete' && Boolean.valueOf(stringArray[i].split(';')[2].split('/')[6].split('#')[1].trim())) {
							fieldSec.allowDelete = true;
						} else {
							fieldSec.allowDelete = false;
						}						
						objList.add(fieldSec);
					}

                    //  for Field 
					if(stringArray[i].split(';')[7].trim() != '') {
                        //system.assert(false, '=====>>>> '+stringArray[i].split(';')[7].trim());
						MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();					
						fieldSec.field = UtilityController.appNamespace() + stringArray[i].split(';')[7].split('@#')[0].split('\\.')[0].trim() +'.'+
                                         UtilityController.appNamespace() + stringArray[i].split(';')[7].split('@#')[0].split('\\.')[1].trim();

						if(stringArray[i].split(';')[7].split('@#')[1].trim() == 'W') {
                            fieldSec.editable = true;
                            fieldSec.readable = true;
                        } else {
                            fieldSec.readable = true;
                            fieldSec.editable = false;
                        }   
						fldList.add(fieldSec);
					}	
					// for page Permission
					if(stringArray[i].split(';')[12].trim() != '') {
						MetadataService.ProfileApexPageAccess profPagePermission = new MetadataService.ProfileApexPageAccess();
						profPagePermission.apexPage = UtilityController.appNamespace() + stringArray[i].split(';')[12].trim();
						profPagePermission.enabled = true;
						pageLevelAccessList.add(profPagePermission);
					}

					
					// for class Permission
					if(stringArray[i].split(';')[17].trim() != '') {
						MetadataService.ProfileApexClassAccess profClassPermission = new MetadataService.ProfileApexClassAccess();
						profClassPermission.apexClass = UtilityController.appNamespace() + stringArray[i].split(';')[17].trim();
                        profClassPermission.enabled = true;
						classLevelAccessList.add(profClassPermission);
					} 			
				}

				for(MetadataService.Profile mp : profList) {
					mp.fieldPermissions  = fldList ;
					mp.objectPermissions  = objList ;
					mp.pageAccesses  = pageLevelAccessList;
					mp.classAccesses  = classLevelAccessList;
				}
			} 

            if(psInfoMap.size() > 0) {
                List<MetadataService.PermissionSetObjectPermissions> objLevelAccessList = new List<MetadataService.PermissionSetObjectPermissions>();
				List<MetadataService.PermissionSetFieldPermissions> fldlevelAccessList = new List<MetadataService.PermissionSetFieldPermissions>();
				List<MetadataService.PermissionSetApexPageAccess> pageLevelAccessList = new List<MetadataService.PermissionSetApexPageAccess>();
				List<MetadataService.PermissionSetApexClassAccess> classLevelAccessList = new List<MetadataService.PermissionSetApexClassAccess>();
				
				for(String ps : psInfoMap.keySet()) {
					MetadataService.PermissionSet prmsn = new MetadataService.PermissionSet();
					prmsn.fullName = ps;
					prmsn.label = psInfoMap.get(ps);
					permissionSetList.add(prmsn);
				}
				
				for(Integer i = 2; i < stringArray.size(); i++) {

                    //  for object permission
                    if(stringArray[i].split(';')[3].trim() != '') {
						MetadataService.PermissionSetObjectPermissions profObjectPermission = new MetadataService.PermissionSetObjectPermissions(); 
                        profObjectPermission.object_x = UtilityController.appNamespace()+stringArray[i].split(';')[3].split('/')[0].trim();
						
						if(stringArray[i].split(';')[3].split('/')[1].split('#')[0].trim() == 'Read' && Boolean.valueOf(stringArray[i].split(';')[3].split('/')[1].split('#')[1].trim())) {
							profObjectPermission.allowRead = true;
						} else {
							profObjectPermission.allowRead = false;
						}
						if(stringArray[i].split(';')[3].split('/')[2].split('#')[0].trim() == 'Edit' && Boolean.valueOf(stringArray[i].split(';')[3].split('/')[2].split('#')[1].trim())) {
							profObjectPermission.allowEdit = true;
						} else {
							profObjectPermission.allowEdit = false;
						}
						if(stringArray[i].split(';')[3].split('/')[3].split('#')[0].trim() == 'Create' && Boolean.valueOf(stringArray[i].split(';')[3].split('/')[3].split('#')[1].trim())) {
							profObjectPermission.allowCreate = true;
						} else {
							profObjectPermission.allowCreate = false;
						}
						if(stringArray[i].split(';')[3].split('/')[4].split('#')[0].trim() == 'modifyAllRecords' && Boolean.valueOf(stringArray[i].split(';')[3].split('/')[4].split('#')[1].trim())) {
							profObjectPermission.modifyAllRecords = true;
						} else {
							profObjectPermission.modifyAllRecords = false;
						}
						if(stringArray[i].split(';')[3].split('/')[5].split('#')[0].trim() == 'viewAllRecords' && Boolean.valueOf(stringArray[i].split(';')[3].split('/')[5].split('#')[1].trim())) {
							profObjectPermission.viewAllRecords = true;
						} else {
							profObjectPermission.viewAllRecords = false;
						}
						if(stringArray[i].split(';')[3].split('/')[6].split('#')[0].trim() == 'Delete' && Boolean.valueOf(stringArray[i].split(';')[3].split('/')[6].split('#')[1].trim())) {
							profObjectPermission.allowDelete = true;
						} else {
							profObjectPermission.allowDelete = false;
						}						
						objLevelAccessList.add(profObjectPermission);
					}

                    //  for field permission
                    if(stringArray[i].split(';')[8].trim() != '') {
                        MetadataService.PermissionSetFieldPermissions profFieldPermission = new MetadataService.PermissionSetFieldPermissions();
                        profFieldPermission.field = UtilityController.appNamespace() + stringArray[i].split(';')[8].split('@#')[0].split('\\.')[0].trim() +'.'+
                                                    UtilityController.appNamespace() + stringArray[i].split(';')[8].split('@#')[0].split('\\.')[1].trim();

                        if(stringArray[i].split(';')[8].split('@#')[1].trim() == 'W') {
                            profFieldPermission.editable = true;
                            profFieldPermission.readable = true;
                        } else {
                            profFieldPermission.readable = true;
                            profFieldPermission.editable = false;
                        }                        
                        fldlevelAccessList.add(profFieldPermission);
                    }

                    // for page Permission
                    if(stringArray[i].split(';')[13].trim() != '') {
                        MetadataService.PermissionSetApexPageAccess profPagePermission = new MetadataService.PermissionSetApexPageAccess();
                        profPagePermission.apexPage = UtilityController.appNamespace() + stringArray[i].split(';')[13].trim();
                        profPagePermission.enabled = true;
                        pageLevelAccessList.add(profPagePermission);
                    }

                    // For class
                    if(stringArray[i].split(';')[18].trim() != '') {
                        MetadataService.PermissionSetApexClassAccess fieldSec = new MetadataService.PermissionSetApexClassAccess();            
                        fieldSec.apexClass = UtilityController.appNamespace() + stringArray[i].split(';')[18].trim();
                        fieldSec.enabled = true;            
                        classLevelAccessList.add(fieldSec);
                    } 
                    
                }

                for(MetadataService.PermissionSet ps : permissionSetList) {
					ps.fieldPermissions  = fldlevelAccessList;
					ps.objectPermissions = objLevelAccessList;
					ps.pageAccesses  = pageLevelAccessList;
					ps.classAccesses  = classLevelAccessList;
				}
            }
        }
		
        if(profList.size() > 0 && !Test.isRunningTest()) {
            List<MetadataService.SaveResult> results = service.updateMetadata(profList);
            handleSaveResults(results[0]);
        }
        
        if(permissionSetList.size() > 0 && !Test.isRunningTest()) {
            List<MetadataService.SaveResult> results1 = service.updateMetadata(permissionSetList);
            handleSaveResults(results1[0]);
        }
    }

    /**
    * Method called onChange of selection
    **/
    public void onChangeType() {
        allProfile = new List<SelectOption>();
        selectedProfile = new List<SelectOption>();
        allPermissionSet = new List<SelectOption>();
        selectedPermission = new List<SelectOption>();

        // on change of selection of picklist value.
        if(selectedVal == ConstantsController.STANDARD_USER) {
           
            for(Profile prfl : profileList) {

                if(cs.SU_Profiles__c != null && cs.SU_Profiles__c != '') {
                
                    if (!suProfile.contains('@'+prfl.Name+'@')) {
                        allProfile.add(new SelectOption(prfl.Name, prfl.Name));
                    }
                } else {
                    allProfile.add(new SelectOption(prfl.Name, prfl.Name));
                }
            }         

            if(cs.SU_Profiles__c != null && cs.SU_Profiles__c != '') {
                
                for (String obj : cs.SU_Profiles__c.split(',')) {
                    selectedProfile.add(new SelectOption(obj, obj));                               
                }
            }   

            for(PermissionSet pset : psetList) {

                if(cs.SU_Permission_Sets__c != null && cs.SU_Permission_Sets__c != '') {

                    if (!suPermissionset.contains('@'+pset.Label+'@')) {
                        allPermissionSet.add(new SelectOption(pset.Name, pset.Label));
                    }

                    String strValue = '@'+pset.Label+'@';
                    for (String obj : suPermissionset.split(',')) {
                        if(obj == strValue)
                        selectedPermission.add(new SelectOption(pset.Name, pset.Label));                               
                    }
                } else {
                    allPermissionSet.add(new SelectOption(pset.Name, pset.Label));
                }
            }

            
            
        } else if(selectedVal == ConstantsController.REFERENCE_MANAGER) {
            
            for(Profile prfl : profileList) {

                if(cs.RM_Profiles__c != null && cs.RM_Profiles__c != '') {
                
                    if (!rmProfile.contains('@'+prfl.Name+'@')) {
                        allProfile.add(new SelectOption(prfl.Name, prfl.Name));
                    }
                } else {
                    allProfile.add(new SelectOption(prfl.Name, prfl.Name));
                }
            }            

            if(cs.RM_Profiles__c != null && cs.RM_Profiles__c != '') {
                
                for (String obj : cs.RM_Profiles__c.split(',')) {
                    selectedProfile.add(new SelectOption(obj, obj));                               
                }
            }

            for(PermissionSet pset : psetList) {

                if(cs.RM_Permission_Sets__c != null && cs.RM_Permission_Sets__c != '') {

                    if (!rmPermissionset.contains('@'+pset.Label+'@')) {
                        allPermissionSet.add(new SelectOption(pset.Name, pset.Label));
                    }
                    
                    String strValue = '@'+pset.Label+'@';
                    for (String obj : rmPermissionset.split(',')) {
                        if(obj == strValue)
                        selectedPermission.add(new SelectOption(pset.Name, pset.Label));                               
                    }
                } else {
                    allPermissionSet.add(new SelectOption(pset.Name, pset.Label));
                }
            }
        } else {
            loadData();
        }
    }

    public class MetadataServiceExamplesException extends Exception { }

    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
    **/
    public static void handleSaveResults(MetadataService.SaveResult saveResult) {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null) {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');

            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }

    public static void handleUpsertResults(MetadataService.UpsertResult upsertResult) {
        // Nothing to see?
        if(upsertResult==null || upsertResult.success)
            return;
        // Construct error message and throw an exception
        if(upsertResult.errors!=null) {
            List<String> messages = new List<String>();
            messages.add(
                (upsertResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + upsertResult.fullName + '.');

            for(MetadataService.Error error : upsertResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );

            if(messages.size()>0)
                throw new MetadataServiceExamplesException(String.join(messages, ' '));
        }

        if(!upsertResult.success)
            throw new MetadataServiceExamplesException('Request failed with no specified error.');
    }
}