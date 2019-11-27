define(['Routing_AppJs_PK', 'FormRepositoryServices','underscore_min'], function(Routing_AppJs_PK, FormRepositoryServices,underscore_min) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('FormRepositoryCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$stateParams', '$state', '$translate', 'FormRepositoryService', function($scope, $timeout, $q, $rootScope, $stateParams, $state, $translate, FormRepositoryService) {
        var Notification = injector.get("Notification");
        $scope.M_FormRepository = $scope.M_FormRepository || {};
        $scope.F_FormRepository = $scope.M_FormRepository || {};
        $scope.M_FormRepository.isSelectedNav = 'Active';
        $scope.M_FormRepository.expandedSectionName = '';
        $scope.M_FormRepository.expandedSectionName = '';
        $scope.M_FormRepository.expandedDivFlag = false;
        $scope.M_FormRepository.expandedDivId = '';
        $scope.M_FormRepository.isLoading = false;
        $scope.M_FormRepository.selectedFormGroup = {};
        $scope.M_FormRepository.showFormGroupDropdown = false;
        $scope.M_FormRepository.currentDropDownIndex = -1;
        $scope.M_FormRepository.fileUpload = {};
        $scope.M_FormRepository.formJson = {};
        $scope.M_FormRepository.sectionNameToSectionKey = {
        		'Deal': 'Deal',
        		'Financing': 'Financing',
        		'Service': 'Service',
        		'Vendor product': 'Vendor_product'
        }
        $scope.M_FormRepository.formGroupList = [{'FormName': 'Deal'}, 
                                                 {'FormName': 'Financing'}, 
                                                 {'FormName': 'Service'}, 
                                                 {'FormName': 'Vendor product'}
                                                ];
        $scope.M_FormRepository.selectedFormCount = 0;
        $scope.M_FormRepository.updatedFormList = [];
        $scope.F_FormRepository.MoveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
        $scope.F_FormRepository.expandOrCollapseSection = function(sectionId, sectionName) {
        	console.log(sectionName);
            if ($scope.M_FormRepository.expandedDivFlag && $scope.M_FormRepository.expandedDivId == sectionId && $scope.M_FormRepository.expandedSectionName == sectionName) {
                $scope.F_FormRepository.collapseSection();
            } else {
                $scope.F_FormRepository.expandedSection(sectionId, sectionName);
            }
        }
        
        $scope.F_FormRepository.expandedSection = function(sectionId, sectionName) {
            var expandableDiv;
            var expandableDivChildDivHeight;
            var transitionDelay;
            if ($scope.M_FormRepository.expandedDivFlag && $scope.M_FormRepository.expandedDivId == sectionId) {
                return;
            }
            if ($scope.M_FormRepository.expandedDivFlag) {
                transitionDelay = '0.3s';
                $scope.F_FormRepository.collapseSection();
            }
            expandableDiv = angular.element('#' + sectionId);
            expandableDivChildDivHeight = angular.element(angular.element('#' + sectionId + ' > div')[0]).outerHeight();
            expandElement(expandableDiv, expandableDivChildDivHeight, transitionDelay);
            $scope.M_FormRepository.expandedDivFlag = true;
            $scope.M_FormRepository.expandedDivId = sectionId;
            $scope.M_FormRepository.expandedSectionName = sectionName;
            //TODO Update this and test - use $evalAsync
            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                $scope.$apply(); //TODO
            }
            var TimeoutVal = 500;
            if (transitionDelay) {
                TimeoutVal = 800;
            }
            setTimeout(function() {
                if (checkForDevice('iPad')) {
                    expandableDiv.css('transition', 'none');
                }
                expandableDiv.css('height', 'auto');
                expandableDiv.css('overflow', 'visible');
            }, TimeoutVal);
        }
        
        //For Outer Accordian
        $scope.F_FormRepository.collapseSection = function() {
            if ($scope.M_FormRepository.expandedDivId) {
                var collapsableDiv = angular.element('#' + $scope.M_FormRepository.expandedDivId);
                var expandableDivChildDivHeight = angular.element(angular.element('#' + $scope.M_FormRepository.expandedDivId + ' > div')[0]).outerHeight();
                collapsableDiv.css('height', expandableDivChildDivHeight);
                collapsableDiv.css('overflow', 'hidden');
                setTimeout(function() {
                    collapseElement(collapsableDiv);
                }, 20)
                $scope.M_FormRepository.expandedDivFlag = false;
                $scope.M_FormRepository.expandedDivId = '';
                $scope.M_FormRepository.expandedSectionName = '';
            }
        }
        
        $scope.F_FormRepository.setFocus = function(id) {
        	setTimeout(function(){
        		angular.element("#"+ id).focus();	
        	},100);
        }  
        
        $scope.F_FormRepository.keyPressNavigationOnDropdownElements = function(event, dropdownDivId, templateName, dropdownList) {
            var keyCode = event.which ? event.which : event.keyCode;
            var tempList = angular.copy(dropdownList);
            var dropDownDivId = '#' + dropdownDivId;
            var idSubStr = '';
            var totalRecordsToTraverse = 0;
            if (tempList) {
                totalRecordsToTraverse += tempList.length;
            }
            
            if (keyCode == 40 && totalRecordsToTraverse > 0) {
                if (totalRecordsToTraverse - 1 > $scope.M_FormRepository.currentDropDownIndex) {
                    $scope.M_FormRepository.currentDropDownIndex++;
                    if (templateName == 'formGroup') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#formGroup_';
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_FormRepository.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.M_FormRepository.currentDropDownIndex > 0) {
                    $scope.M_FormRepository.currentDropDownIndex--;
                    if (templateName == 'formGroup') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else  
                        idSubStr = '#formGroup_';
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_FormRepository.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode == 13 && $scope.M_FormRepository.currentDropDownIndex !== -1) {
                if(templateName == 'formGroup') {
                	$scope.F_FormRepository.selectFormGroup(tempList[$scope.M_FormRepository.currentDropDownIndex]);
                }
                $scope.M_FormRepository.currentDropDownIndex = -1;
            }
        }
        
        $scope.F_FormRepository.hideDropdown = function() {
        	$scope.M_FormRepository.currentDropDownIndex = -1;
        }
        
        $scope.F_FormRepository.selectFormGroup = function (selectedFormGroup){
        	$scope.M_FormRepository.selectedFormGroup = angular.copy(selectedFormGroup);
        	$scope.M_FormRepository.formJson.GroupingName = $scope.M_FormRepository.selectedFormGroup.FormName;
        	$scope.M_FormRepository.showFormGroupDropdown = false;
        	$scope.F_FormRepository.hideDropdown();
        } 
        
        $scope.F_FormRepository.showFormAvailable = function() {
        	var noList = true;
        	//console.log($scope.M_FormRepository.ActiveFormList);
        	if($scope.M_FormRepository.ActiveFormList !== undefined) {
        		if(   !_.isEmpty($scope.M_FormRepository.ActiveFormList.Deal)
        		   || !_.isEmpty($scope.M_FormRepository.ActiveFormList.Financing)
        		   || !_.isEmpty($scope.M_FormRepository.ActiveFormList.Service)
        		   || !_.isEmpty($scope.M_FormRepository.ActiveFormList.Vendor_product)
        		  )
        		{
        			noList = false;
        		};
        	}
        	return noList;
        }
        
        /* Start: Form Upload */
        //Constants
       var allowedExtensions = [];
       var allowedFileTypesType;
       var maxStringSize;
       var maxFileSize;
       var maxFileSizeText;
       var chunkSize;
       var isBrowseFile = false;
       
       //Uploaded file instance
       $scope.FileUpload = {};
       $scope.FileUpload.attachment = '';
       $scope.FileUpload.attachmentName = '';
       $scope.FileUpload.fileSize = 0;
       $scope.FileUpload.positionIndex = 0;
       
       //This is the code for ng-droplet
       /**
        * @property interface
        * @type {Object}
        */
       $scope.FileUpload.interface = {};
       /**
        * @property uploadCount
        * @type {Number}
        */
       $scope.FileUpload.uploadCount = 0;
       /**
        * @property success
        * @type {Boolean}
        */
       $scope.FileUpload.success = false;
       /**
        * @property error
        * @type {Boolean}
        */
       $scope.FileUpload.error = false;
       
       $scope.$on('$dropletReady', function whenDropletReady() {
           	$('.browse_but input').attr('title', ' ');
       });
       
       $scope.$on('$dropletFileAdded', function onDropletFileAdded(event, singlefile) {
       	$scope.FileUpload.fileToBeUploaded = singlefile.file;
           var fileExtension = getExtension($scope.FileUpload.fileToBeUploaded);
           var fileType = $scope.FileUpload.fileToBeUploaded.type;
           if(allowedExtensions.indexOf(fileExtension) != -1 && allowedFileTypesType.test(fileType)) {
        	   	$scope.M_FormRepository.isLoading = true;
           		uploadAttachmentFile();
           } else {
           		Notification.error($translate.instant('Please_select_a_pdf_file'));
           }
       });
       
       function uploadAttachmentFile() {
           uploadFile($scope.FileUpload.fileToBeUploaded);
       }
       
       function uploadFile(file) {
           if (file != undefined) {
               if (file.size <= maxFileSize) {
                   $scope.FileUpload.attachmentName = file.name;
                   var fileReader = new FileReader();
                   fileReader.onload = function (e) {};
                   fileReader.onloadend = function(e) {
                       $scope.FileUpload.attachment = window.btoa(this.result); //Base 64 encode the file before sending it
                       $scope.FileUpload.positionIndex = 0;
                       $scope.FileUpload.fileSize = $scope.FileUpload.attachment.length;
                       $scope.FileUpload.doneUploading = false;
                       if ($scope.FileUpload.fileSize < maxStringSize) {
                           $scope.FileUpload.tempattachmentbody = $scope.FileUpload.attachment;
                           afterUploadAction();
                       } else {
                    	   $scope.M_FormRepository.isLoading = false;
                       }
                   }
                   fileReader.onerror = function(e) {
                	   $scope.M_FormRepository.isLoading = false;
                   }
                   fileReader.onabort = function(e) {
                   	afterUploadAction();
                   }
                   fileReader.readAsBinaryString(file); //Read the body of the file
               } else {
            	   $scope.M_FormRepository.isLoading = false;
            	   $translate('File_size_should_be_less_than_parameterized_size',{ maxFileSize : maxFileSizeText}).then(function(success) {
            		   Notification.error(success);
            	   }, function(error) {
            		   Notification.error($translate.instant('File_size_should_be_less_than_max_size'));
            	   });
               }
           } else {
           	afterUploadAction();
           }
       }
       
       function afterUploadAction() {
       		$scope.M_FormRepository.isLoading = false;
	       	uploadAttachmentCallback($scope.FileUpload);
       }
       
       function uploadAttachmentCallback(FileUploadObj) {
           $scope.M_FormRepository.fileUpload = FileUploadObj;
           $scope.M_FormRepository.formJson.FormName = FileUploadObj.attachmentName;
           $scope.M_FormRepository.formJson.FormNameWithExtension = FileUploadObj.attachmentName;
           $scope.M_FormRepository.formJson.Description = '';
           $scope.M_FormRepository.isLoading = false;
           openUploadFormModalWindow();
           if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
               $scope.$apply();
           }
        }
       
       function setDefaultValidationModel() {
	        $scope.M_FormRepository.formValidationModal = {
	        		FormName: {
	                    isError: false,
	                    ErrorMessage: '',
	                    Type: 'Required',
	                    Maxlength: 50
	                },
	                Description: {
	                    isError: false,
	                    ErrorMessage: '',
	                    Type: 'Required'
	                },
	                GroupingName: {
	                	 isError: false,
	                     ErrorMessage: '',
	                     Type: 'Required'
	                }
	            };
      }
      
       function openUploadFormModalWindow() {
    	   setDefaultValidationModel();
           setTimeout(function() {
               angular.element('#upload-form-modal-window').modal({
                   backdrop: 'static',
                   keyboard: false
               });
           }, 100);
       }
       
       angular.element(document).on("click", "#upload-form-modal-window .modal-backdrop", function() {
    	   $scope.F_FormRepository.hideUploadFormModalWindow();
       });
       
       $scope.F_FormRepository.hideUploadFormModalWindow = function() {
    	   angular.element('#upload-form-modal-window').modal('hide');
    	   resetAttachmentModalData();
       }
       
       function resetAttachmentModalData() {
   	    	allowedExtensions = [];
			maxStringSize = null; //Maximum String size is 6,000,000 characters
			maxFileSize = null; //After Base64 Encoding, this is the max file size (750 KB max)
			maxFileSizeText = '';
			chunkSize = null; //Maximum Javascript Remoting message size is 1,000,000 characters
			allowedFileTypesType = null;
			$scope.M_FormRepository.formJson = {};
      }
       
       $scope.F_FormRepository.validateForm = function() {
           angular.forEach($scope.M_FormRepository.formValidationModal, function(value, key) {
        	   $scope.F_FormRepository.validateFieldWithKey(key);
           });
       }
       
       $scope.F_FormRepository.validateFieldWithKey = function(modelKey) {
           var fieldValue = $scope.M_FormRepository.formJson[modelKey];
           var validateType = $scope.M_FormRepository.formValidationModal[modelKey].Type;
           var isError = false;
           var ErrorMessage = '';
           if (validateType.indexOf('Required') > -1) {
               if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                   isError = true;
                   ErrorMessage = $translate.instant('Field_Is_Required');
               }
           }
           $scope.M_FormRepository.formValidationModal[modelKey].isError = isError;
           $scope.M_FormRepository.formValidationModal[modelKey].ErrorMessage = ErrorMessage;
           if ($scope.M_FormRepository.formValidationModal[modelKey].isError == true) {
               $scope.M_FormRepository.isValidForm = false;
           }
       }
       
       $scope.F_FormRepository.setDefaultAddAttachmentModalData = function() {
    	   	allowedExtensions = ['pdf'];
			maxStringSize = 6000000; //Maximum String size is 6,000,000 characters
			maxFileSize = 750000; //After Base64 Encoding, this is the max file size (750 KB max)
			maxFileSizeText = $translate.instant('750_KB');
			chunkSize = 950000; //Maximum Javascript Remoting message size is 1,000,000 characters
			allowedFileTypesType = /pdf/i;
       }
        
       $scope.F_FormRepository.saveFormData = function() {
            $scope.M_FormRepository.isValidForm = true;
            $scope.F_FormRepository.validateForm();
            if(!$scope.M_FormRepository.isValidForm) {
            	return;
            }
            $scope.M_FormRepository.isLoading = true;
            //Edit Mode
            if($scope.M_FormRepository.formJson.Id){
            	FormRepositoryService.saveForm(angular.toJson($scope.M_FormRepository.formJson)).then(function(result) {
            		if(result.responseStatus == 'success') {
            			$scope.F_FormRepository.hideUploadFormModalWindow();
                        $scope.F_FormRepository.loadFormData();
            		} else if(result.responseStatus == 'error') {
            			$scope.M_FormRepository.isLoading = false;
            			Notification.error($translate.instant(result.response));
            			$scope.M_FormRepository.formJson.GroupingName = $scope.M_FormRepository.formJsonCopy.GroupingName;
            		} else {
            			$scope.M_FormRepository.isLoading = false;
            		}
                }, function(error) {
                	$scope.M_FormRepository.isLoading = false;
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }else{
            	//Add Mode
            	FormRepositoryService.uploadForm(angular.toJson($scope.M_FormRepository.formJson), $scope.M_FormRepository.fileUpload.tempattachmentbody).then(function() {
                    $scope.F_FormRepository.hideUploadFormModalWindow();
                    $scope.F_FormRepository.loadFormData();
                }, function(error) {
                	$scope.M_FormRepository.isLoading = false;
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }
        }
        
		$scope.F_FormRepository.openModalWindowEditMode = function(formRec) {
			openUploadFormModalWindow();
			$scope.M_FormRepository.formJson = angular.copy(formRec);
			console.log($scope.M_FormRepository.formJson);
		}
        /* End: Form Upload */
        
		$scope.F_FormRepository.viewForm = function(FormAttachmentURL) {
			var myWindow = window.open(FormAttachmentURL, '_blank');
		}
		
        $scope.F_FormRepository.resetAndLoadActiveTabData = function() {
			$scope.F_FormRepository.collapseSection();
            $scope.M_FormRepository.expandedDivId = '';
			$scope.F_FormRepository.loadFormData();
		}
        
        $scope.F_FormRepository.loadFormData = function() {
        	$scope.M_FormRepository.isLoading = true;
            $scope.M_FormRepository.updatedFormList = [];
            	$scope.M_FormRepository.selectedFormCount = 0;
            FormRepositoryService.getFormsListBasedOnType($scope.M_FormRepository.isSelectedNav).then(function(result) {
                if ($scope.M_FormRepository.isSelectedNav == 'Active') {
                    $scope.M_FormRepository.ActiveFormList = result;
                } else {
                    $scope.M_FormRepository.AvailableFormList = result;
                    Object.keys($scope.M_FormRepository.AvailableFormList).forEach(function(key) {
                       		for(var i=0; i<$scope.M_FormRepository.AvailableFormList[key].length;i++) {
                       			$scope.M_FormRepository.AvailableFormList[key][i].isSelected = false;
                       		}
                       	});
                }                
                $scope.M_FormRepository.isLoading = false;
                showTooltip('body');
            }, function(error) {
            	$scope.M_FormRepository.isLoading = false;
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        
        $scope.F_FormRepository.selectedDeselectForm = function(key,index) {
    		$scope.M_FormRepository.AvailableFormList[key][index].isSelected = !$scope.M_FormRepository.AvailableFormList[key][index].isSelected;
    		$scope.M_FormRepository.selectedFormCount += 1;
    		$scope.M_FormRepository.updatedFormList.push($scope.M_FormRepository.AvailableFormList[key][index]);
        }
        
        $scope.F_FormRepository.activateForm = function() {
        	$scope.M_FormRepository.isLoading = true;
        	for(var j=0; j<$scope.M_FormRepository.updatedFormList.length;j++) {
        		if($scope.M_FormRepository.updatedFormList[j].isSelected){
        			$scope.M_FormRepository.updatedFormList[j].IsActive = true;
        		}
        	}
        	FormRepositoryService.activateForm(JSON.stringify($scope.M_FormRepository.updatedFormList)).then(function(result) {
        		Object.keys($scope.M_FormRepository.AvailableFormList).forEach(function(key) {
               		for(var i=0; i<$scope.M_FormRepository.AvailableFormList[key].length;i++) {
               			$scope.M_FormRepository.AvailableFormList[key][i].isSelected = false;
               		}
               	});
        		$scope.M_FormRepository.updatedFormList = [];
        		$scope.M_FormRepository.selectedFormCount = 0;
        		$scope.M_FormRepository.isLoading = false;
        		
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        
        $scope.F_FormRepository.dactivateForm = function(key, index, event) {
        	event.stopPropagation();
        	$scope.M_FormRepository.updatedFormList = [];
        	$scope.M_FormRepository.isLoading = true;
        	if($scope.M_FormRepository.isSelectedNav == 'Active') {
        		$scope.M_FormRepository.ActiveFormList[key][index].IsActive = false;
        		$scope.M_FormRepository.updatedFormList.push($scope.M_FormRepository.ActiveFormList[key][index]);
        	} else {
        		$scope.M_FormRepository.AvailableFormList[key][index].IsActive = false;
        		$scope.M_FormRepository.updatedFormList.push($scope.M_FormRepository.AvailableFormList[key][index]);
        	}
        	FormRepositoryService.activateForm(JSON.stringify($scope.M_FormRepository.updatedFormList)).then(function(result) {
        		if(result.responseStatus == 'success') {
            		$scope.F_FormRepository.loadFormData();
        		} else if(result.responseStatus == 'error') {
        			$scope.M_FormRepository.isLoading = false;
        			Notification.error($translate.instant(result.response));
        		} else {
        			$scope.M_FormRepository.isLoading = false;
        		}
        		$scope.M_FormRepository.updatedFormList = [];
        		
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        
        $scope.F_FormRepository.deleteForm = function(formId, event) {
        	event.stopPropagation();
        	$scope.M_FormRepository.isLoading = true;
        	FormRepositoryService.deleteForm(formId).then(function(result) {
        		if(result.responseStatus == 'success') {
        			$scope.F_FormRepository.loadFormData();
        		} else if(result.responseStatus == 'error') {
        			$scope.M_FormRepository.isLoading = false;
        			Notification.error($translate.instant(result.response));
        		} else {
        			$scope.M_FormRepository.isLoading = false;
        		}
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
                $scope.M_FormRepository.isLoading = false;
            });
        }
        
        function showTooltip(containerName) {
            angular.element('[role ="tooltip"]').hide();
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'top',
                    container: containerName
                });
            }, 500);
        }
        $scope.F_FormRepository.loadFormData();
    }])
});