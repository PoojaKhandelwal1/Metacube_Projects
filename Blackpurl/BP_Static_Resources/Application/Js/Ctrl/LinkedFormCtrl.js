define(['Routing_AppJs_PK',  'underscore_min','LinkedFormServices','HighlightSearchTextFilter'], function (Routing_AppJs_PK, underscore_min , LinkedFormServices,HighlightSearchTextFilter) {
	var injector = angular.injector(['ui-notification', 'ng']);
	Routing_AppJs_PK.controller('LinkedFormCtrl', ['$scope', '$state', '$q', '$translate', 'LinkedFormService', function ($scope, $state, $q, $translate, LinkedFormService) {
		var Notification = injector.get("Notification");
        $scope.M_LinkedForm = $scope.M_LinkedForm || {};
        $scope.F_LinkedForm = $scope.F_LinkedForm || {};
        
        $scope.M_LinkedForm.activeTabName = 'Overview';
        $scope.M_LinkedForm.showTabList = false; 
        $scope.M_LinkedForm.isLoading = false;
        $scope.M_LinkedForm.currentDropDownIndex = -1;
        $scope.M_LinkedForm.showFormListDropdown = false;
        $scope.M_LinkedForm.showVendorProductListDropdown = false;
        resetLinkFromModalData();
        
        $scope.F_LinkedForm.setActiveTab = function(activeTabName) {
        	$scope.M_LinkedForm.activeTabName = activeTabName; 
        	$scope.M_LinkedForm.linkedFormList = [];
        	loadActiveTabData(activeTabName);
        }
        
         $scope.F_LinkedForm.setDefaultValidationModel = function() {
            $scope.M_LinkedForm.formValidationModal = {
            		FormName: {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'Required',
                        Maxlength: 50
                    },
                    VendorProductName: {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'Required'
                    }
                };
            }
        
        function loadActiveTabData(activeTabName) {
        	$scope.M_LinkedForm.isLoading = true;
        	if(activeTabName === 'Overview') {
        		loadOverviewDetails();
        	} else {
        		getActiveSectionData(activeTabName).then(function(formList) {
            		$scope.M_LinkedForm.isLoading = false;
            		// Handling for Individual section goes here
            		$scope.M_LinkedForm.linkedFormList = formList;
            		showTooltip('body');
                }, function(error) {
                	$scope.M_LinkedForm.isLoading = false;
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
        	}
        }
        
        function getActiveSectionData(formGroupName) {
        	var defer = $q.defer();
        	LinkedFormService.getLinkedFormsByGroup(formGroupName).then(function(formList) {
        		defer.resolve(formList);
            }, function(error) {
            	defer.reject($translate.instant('GENERIC_ERROR'));
            });
        	return defer.promise;
        }
        
        $scope.F_LinkedForm.showHideTopNavBarDropDown = function(navTabsInputid) {
        	$scope.M_LinkedForm.showTabList = !$scope.M_LinkedForm.showTabList;
        }
        
        $scope.F_LinkedForm.linkAForm = function() {
        	$scope.M_LinkedForm.isLoading = true;
        	getInitialFormDataAndOpenLinkFormModal();
        }
        
        function getInitialFormDataAndOpenLinkFormModal() {
        	getActiveFormsByGroup($scope.M_LinkedForm.activeTabName).then(function(formList) {
        		if(!formList.length) {
        			$scope.M_LinkedForm.isLoading = false;
        			Notification.error($translate.instant('No_active_form_available_to_link'));
        		} else if($scope.M_LinkedForm.activeTabName !== 'Vendor product') {
        			$scope.M_LinkedForm.isLoading = false;
            		openLinkFormModalWindow();
        		} else {
        			getVendorProducts().then(function(vendorProductList) {
                		$scope.M_LinkedForm.isLoading = false;
                		if(vendorProductList.length) {
                			openLinkFormModalWindow();
                		} else {
                			Notification.error($translate.instant('No_vendor_product_available'));
                		}
                    }, function(error) {
                    	$scope.M_LinkedForm.isLoading = false;
                        Notification.error($translate.instant('GENERIC_ERROR'));
                    });
        		}
            }, function(error) {
            	$scope.M_LinkedForm.isLoading = false;
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        
        function getActiveFormsByGroup(formGroupName) {
        	var defer = $q.defer();
        	LinkedFormService.getActiveFormsByGroup(formGroupName).then(function(formList) {
        		$scope.M_LinkedForm.formList = formList;
        		defer.resolve($scope.M_LinkedForm.formList);
            }, function(error) {
            	defer.reject($translate.instant('GENERIC_ERROR'));
            });
        	return defer.promise;
        }
        
        function getVendorProducts() {
        	var defer = $q.defer();
        	LinkedFormService.getVendorProducts().then(function(vendorProductList) {
        		$scope.M_LinkedForm.vendorProductList = vendorProductList;
        		defer.resolve(vendorProductList);
            }, function(error) {
            	defer.reject($translate.instant('GENERIC_ERROR'));
            });
        	return defer.promise;
        }
        
        function openLinkFormModalWindow() {
        	$scope.F_LinkedForm.setDefaultValidationModel();
        	setTimeout(function() {
                angular.element('#link-form-modal-window').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
        }
        
        angular.element(document).on("click", "#link-form-modal-window .modal-backdrop", function() {
        	$scope.F_LinkedForm.hideLinkFormModalWindow();
        });
        
        $scope.F_LinkedForm.hideLinkFormModalWindow = function() {
            angular.element('#link-form-modal-window').modal('hide');
             resetLinkFromModalData();
        }
        
        $scope.F_LinkedForm.setFocus = function(id) {
        	setTimeout(function(){
        		angular.element("#"+ id).focus();	
        	},100);
        }  
        
        $scope.F_LinkedForm.hideDropdown = function() {
        	$scope.M_LinkedForm.currentDropDownIndex = -1;
        }
        
        $scope.F_LinkedForm.keyPressNavigationOnDropdownElements = function(event, dropdownDivId, templateName, dropdownList) {
            var keyCode = event.which ? event.which : event.keyCode;
            var tempList = angular.copy(dropdownList);
            var dropDownDivId = '#' + dropdownDivId;
            var idSubStr = '';
            var totalRecordsToTraverse = 0;
            if (tempList) {
                totalRecordsToTraverse += tempList.length;
            }
            
            if (keyCode == 40 && totalRecordsToTraverse > 0) {
                if (totalRecordsToTraverse - 1 > $scope.M_LinkedForm.currentDropDownIndex) {
                    $scope.M_LinkedForm.currentDropDownIndex++;
                    if (templateName == 'formRec') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#formRec_';
                    } else if (templateName == 'vendorProduct') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#vendorProduct_';
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_LinkedForm.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.M_LinkedForm.currentDropDownIndex > 0) {
                    $scope.M_LinkedForm.currentDropDownIndex--;
                    if (templateName == 'formRec') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else  
                        idSubStr = '#formRec_';
                    } else if (templateName == 'vendorProduct') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#vendorProduct_';
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_LinkedForm.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode == 13 && $scope.M_LinkedForm.currentDropDownIndex !== -1) {
                if(templateName == 'formRec') {
                	$scope.F_LinkedForm.selectLinkForm(tempList[$scope.M_LinkedForm.currentDropDownIndex]);
                } else if(templateName == 'vendorProduct') {
                	$scope.F_LinkedForm.selectVendorProduct(tempList[$scope.M_LinkedForm.currentDropDownIndex]);
                }
                $scope.M_LinkedForm.currentDropDownIndex = -1;
            }
        }
        
        $scope.F_LinkedForm.selectLinkForm = function (formRec){
        	$scope.M_LinkedForm.selectedLinkForm.FormName = formRec.FormName;
        	$scope.M_LinkedForm.selectedLinkForm.FormId = formRec.Id;
        	$scope.M_LinkedForm.selectedLinkForm.GroupingName = $scope.M_LinkedForm.activeTabName;
        	$scope.M_LinkedForm.showFormListDropdown = false;
        	$scope.F_LinkedForm.hideDropdown();
        } 
        
        $scope.F_LinkedForm.selectVendorProduct = function (vendorProduct){
        	$scope.M_LinkedForm.selectedLinkForm.VendorProductName = vendorProduct.Name;
        	$scope.M_LinkedForm.selectedLinkForm.VendorProductId = vendorProduct.Id;
        	$scope.M_LinkedForm.showVendorProductListDropdown = false;
        	$scope.F_LinkedForm.hideDropdown();
        } 
        
        $scope.F_LinkedForm.validateLinkedFormData = function() {
        	if(!$scope.M_LinkedForm.selectedLinkForm.FormName || ($scope.M_LinkedForm.activeTabName === 'Vendor product' && !$scope.M_LinkedForm.selectedLinkForm.VendorProductName)) {
        		return false;
        	}
        	return true;
        }
        
        $scope.F_LinkedForm.validateForm = function() {
            angular.forEach($scope.M_LinkedForm.formValidationModal, function(value, key) {
            	if((key !== 'VendorProductName') || (key === 'VendorProductName' && $scope.M_LinkedForm.activeTabName === 'Vendor product')) {
            		$scope.F_LinkedForm.validateFieldWithKey(key);
            	}
            });
        }
        
        $scope.F_LinkedForm.validateFieldWithKey = function(modelKey) {
            var fieldValue = $scope.M_LinkedForm.selectedLinkForm[modelKey];
            var validateType = $scope.M_LinkedForm.formValidationModal[modelKey].Type;
            var isError = false;
            var ErrorMessage = '';
            if (validateType.indexOf('Required') > -1) {
                if (modelKey == 'FormName' && (fieldValue == undefined || fieldValue == null || fieldValue == ''|| !$scope.M_LinkedForm.selectedLinkForm.FormId)) {
                    isError = true;
                    ErrorMessage = $translate.instant('Field_Is_Required');
                } else if(modelKey == 'VendorProductName' && (fieldValue == undefined || fieldValue == null || fieldValue == ''|| !$scope.M_LinkedForm.selectedLinkForm.VendorProductId)) {
                    isError = true;
                    ErrorMessage = $translate.instant('Field_Is_Required');
                }
            }
            $scope.M_LinkedForm.formValidationModal[modelKey].isError = isError;
            $scope.M_LinkedForm.formValidationModal[modelKey].ErrorMessage = ErrorMessage;
            if ($scope.M_LinkedForm.formValidationModal[modelKey].isError == true) {
                $scope.M_LinkedForm.isValidForm = false;
            }
        }
        
        $scope.F_LinkedForm.saveLinkedFormData = function(linkFormJson, isEdit) {
        	$scope.M_LinkedForm.isValidForm = true;
             $scope.F_LinkedForm.validateForm();
             if(!$scope.M_LinkedForm.isValidForm) {
             	return;
             }
        	else {
        		$scope.M_LinkedForm.isLoading = true;
            	LinkedFormService.saveLinkedForm(angular.toJson(linkFormJson)).then(function() {
            		//$scope.M_LinkedForm.isLoading = false;
            		$scope.F_LinkedForm.hideLinkFormModalWindow();
            		resetLinkFromModalData();
            		loadActiveTabData($scope.M_LinkedForm.activeTabName);
                }, function(error) {
                	$scope.M_LinkedForm.isLoading = false;
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
        	}
        }
        
        $scope.F_LinkedForm.unlinkFormFromSection = function(linkedFormId) {
        	$scope.M_LinkedForm.isLoading = true;
        	 var index = _.findIndex($scope.M_LinkedForm.linkedFormList, {
                 'Id': linkedFormId
             });
        	LinkedFormService.deleteLinkedForm(linkedFormId).then(function() {
        		$scope.M_LinkedForm.isLoading = false;
        		if(index > -1){
        			$scope.M_LinkedForm.linkedFormList.splice(index, 1);
        		}
        		
            }, function(error) {
            	$scope.M_LinkedForm.isLoading = false;
                Notification.error($translate.instant('GENERIC_ERROR'));
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
        
        function resetLinkFromModalData() {
        	$scope.M_LinkedForm.selectedLinkForm = {};
    		$scope.M_LinkedForm.selectedLinkForm.IsRequired = false;
        }
			
        function loadOverviewDetails() {
        	$scope.M_LinkedForm.isLoading = true;
        	LinkedFormService.getOverviewDetails().then(function(formGroupList) {
        		$scope.M_LinkedForm.isLoading = false;
        		$scope.M_LinkedForm.formGroupList = formGroupList;
            }, function(error) {
            	$scope.M_LinkedForm.isLoading = false;
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        
        loadOverviewDetails();
    }]);
});