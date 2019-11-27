define(['Routing_AppJs_PK','AccountingIntegrationSettingsServices', 'underscore_min', 'AngularNgEnter', 'CustomToggle'], 
		function (Routing_AppJs_PK, AccountingIntegrationSettingsServices, underscore_min, AngularNgEnter, CustomToggle) {
	
	var injector = angular.injector(['ui-notification','ng']);
	Routing_AppJs_PK.controller('AccountingIntegrationSettingsCtrl', ['$scope','$timeout','$q','$rootScope','$sce','$stateParams','$state', '$window', 'AccountingService', '$translate', function ($scope, $timeout, $q, $rootScope, $sce,$stateParams, $state, $window, AccountingService,$translate) {
		
		var Notification = injector.get("Notification"); 
		$scope.AccountingSetupModel = {};
	    $scope.AccountingSetupModel.QBDataModel = {};
	    $scope.AccountingSetupModel.selectedAccountingChevronIndex = '1'; 
	    $scope.AccountingSetupModel.displaySection = 'Accounting Provider';
	    $scope.AccountingSetupModel.ChangedAccountingProvide = null;
	    $scope.AccountingSetupModel.isQBConnected = false;
	    $scope.AccountingSetupModel.isQBConnectionError = false;
	    $scope.AccountingSetupModel.isAccountingSetupDataSaved = true; 
	    $scope.AccountingSetupModel.isBackBtnClicked = false; 
	    $scope.AccountingSetupModel.selectedProviderValue = ''; 
		$scope.AccountingSetupModel.isScrollInTable = false;
		$scope.AccountingSetupModel.ConstantTableHeight = 340;
		$scope.AccountingSetupModel.AddEditNewServiceJobType = {}
	    $scope.AccountingSetupModel.AccountingIntegrationSetUpStatus = 'Incomplete';
        $scope.AccountingSetupModel.currentDropDownIndex = -1;
        var SJTList = [];
		 function setDefaultValidationModel() {
		        $scope.AccountingSetupModel.formValidationModal = {
		        		Type: {
		                    isError: false,
		                    ErrorMessage: '',
		                    Type: 'Required',
		                },
		                Name: {
		                    isError: false,
		                    ErrorMessage: '',
		                    Type: 'Required'
		                }
		            };
	      }
		 
		 
		 $scope.AccountingSetupModel.validateForm = function() {
	            angular.forEach($scope.AccountingSetupModel.formValidationModal, function(value, key) {
	            		$scope.AccountingSetupModel.validateFieldWithKey(key);
	           });
	       }
	       
	       $scope.AccountingSetupModel.validateFieldWithKey = function(modelKey) {
	           var fieldValue = $scope.AccountingSetupModel.AddEditNewServiceJobType[modelKey];
	           var validateType = $scope.AccountingSetupModel.formValidationModal[modelKey].Type;
	           var isError = false;
	           var ErrorMessage = '';
	           if (validateType.indexOf('Required') > -1) {
	               if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
	                   isError = true;
	                   ErrorMessage = $translate.instant('Field_Is_Required');
	               }
	           }
	           $scope.AccountingSetupModel.formValidationModal[modelKey].isError = isError;
	           $scope.AccountingSetupModel.formValidationModal[modelKey].ErrorMessage = ErrorMessage;
	           if ($scope.AccountingSetupModel.formValidationModal[modelKey].isError == true) {
	               $scope.AccountingSetupModel.isValidForm = false;
	           }
	       }
		 
		 $scope.AccountingSetupModel.openModalWindowAddEditServiceJobType = function(SJTRec) {
			 openSJTModalWindow();
			 if(SJTRec) {
				 $scope.AccountingSetupModel.AddEditNewServiceJobType = angular.copy(SJTRec);
			 }else{
				 $scope.AccountingSetupModel.AddEditNewServiceJobType.IsDefault = false;
                 $scope.AccountingSetupModel.AddEditNewServiceJobType.Name = '';
			 }
		 }
         
		  $scope.AccountingSetupModel.checkUniqueCode = function() {
			 $scope.AccountingSetupModel.isUniqueCode = true;
			  for(var i=0; i<$scope.AccountingSetupModel.serviceJobTypeList.length;i++) {
				  if($scope.AccountingSetupModel.AddEditNewServiceJobType.Id != $scope.AccountingSetupModel.serviceJobTypeList[i].Id) {
					  if($scope.AccountingSetupModel.serviceJobTypeList[i].Name.toLowerCase() == $scope.AccountingSetupModel.AddEditNewServiceJobType.Name.toLowerCase()) {
						  $scope.AccountingSetupModel.isUniqueCode = false;
						  Notification.error("Duplicate code name");
						  break;
					  }  
				  }
				  
			  }
		 }
		          
		 $scope.AccountingSetupModel.saveServiceJobTypeData = function() {
			 $scope.AccountingSetupModel.isValidForm = true;
	            $scope.AccountingSetupModel.validateForm();
                $scope.AccountingSetupModel.checkUniqueCode();
	            if(!$scope.AccountingSetupModel.isUniqueCode) {
	            	return;
	            }
	            if(!$scope.AccountingSetupModel.isValidForm) {
	            	return;
	            }
                $scope.AccountingSetupModel.AddEditNewServiceJobType.IsActive = $scope.AccountingSetupModel.AddEditNewServiceJobType.Id ? $scope.AccountingSetupModel.AddEditNewServiceJobType.IsActive : true;
	            SJTList.push($scope.AccountingSetupModel.AddEditNewServiceJobType);
	            AccountingService.saveJobType(angular.toJson(SJTList)).then(function(successfulResult) {
		    		 $scope.AccountingSetupModel.getAllServiceJobTypes();
		    		 SJTList = [];
		    		 $scope.AccountingSetupModel.hideUploadServiceJobTypeModalWindow();
			        }, function(errorSearchResult) {
			            responseData = errorSearchResult;
			 });
	            
		 }
         
		  $scope.AccountingSetupModel.checkDefaultSJT = function(id, type, code, event) {
			 /**If for actual SJT record Current value (Defualt is true) before click on checkbox and user is 
			   * trying to set Default to false then prevent it, because one default SJT is always required
			   * */
			  var currentSJTIndex = _.findIndex($scope.AccountingSetupModel.serviceJobTypeList, {'Id': id});
			  if(currentSJTIndex != -1 && $scope.AccountingSetupModel.serviceJobTypeList[currentSJTIndex].IsDefault) {  
				  event.preventDefault();
				  Notification.error('You cant deselect of a default job type');
				 return;
			  }
			  
			  $scope.AccountingSetupModel.isValidForm = true;
	          $scope.AccountingSetupModel.validateForm();
	          if(!$scope.AccountingSetupModel.isValidForm) {
	        	  event.preventDefault();
	        	  return;  
	          }
	          
			  var isOthertherDefualtSJTAvailable = false;
			  var defualtSJTIndex = -1;
			  if (!$scope.AccountingSetupModel.AddEditNewServiceJobType.IsDefault) { // Current value (Default false) before click on checkbox and user is trying to set default to true
				  for(var i=0; i<$scope.AccountingSetupModel.serviceJobTypeList.length;i++) {
	                	if($scope.AccountingSetupModel.serviceJobTypeList[i].Type === type && code
	                			&& $scope.AccountingSetupModel.serviceJobTypeList[i].Id != id 
	                			&& $scope.AccountingSetupModel.serviceJobTypeList[i].IsDefault) {
	                		isOthertherDefualtSJTAvailable = true;
	                		defualtSJTIndex = i;
	                		break;
	                	}
	             }
				  
				 if(isOthertherDefualtSJTAvailable && defualtSJTIndex != -1 && event != undefined) {
					 event.preventDefault();
					 SJTList = [];
					 $scope.AccountingSetupModel.defaultSJT = {};
        			 $scope.AccountingSetupModel.defaultSJT = angular.copy($scope.AccountingSetupModel.serviceJobTypeList[defualtSJTIndex]);
        			 angular.element('#change-default-SJT').modal({
                            backdrop: 'static',
                            keyboard: false
                    });
				 } else {
					 $scope.AccountingSetupModel.AddEditNewServiceJobType.IsDefault = true;
					 $scope.AccountingSetupModel.AddEditNewServiceJobType.IsActive = true;
				 }
			 } else { 
				 $scope.AccountingSetupModel.AddEditNewServiceJobType.IsDefault = false;
	        }
		 }
		 
		  $scope.AccountingSetupModel.changeActiveFlagForSJT = function(id, type, event) {
		  	 var isOtherActiveDefaultSJTAvailable = false;
			 if ($scope.AccountingSetupModel.AddEditNewServiceJobType.IsActive) { // Current value (Active true) before click on checkbox and user is trying to deactivate it
				 for(var i=0; i<$scope.AccountingSetupModel.serviceJobTypeList.length;i++) {
	                	if($scope.AccountingSetupModel.serviceJobTypeList[i].Type === type && $scope.AccountingSetupModel.serviceJobTypeList[i].Id != id 
	                			&& $scope.AccountingSetupModel.serviceJobTypeList[i].IsActive && $scope.AccountingSetupModel.serviceJobTypeList[i].IsDefault) {
	                		isOtherActiveDefaultSJTAvailable = true;
	                		break;
	                	}
	             }
				 
				 if(!isOtherActiveDefaultSJTAvailable && event != undefined) {
					 event.preventDefault();
					 Notification.error('Unable to deactivate default Job Type. Change the default Job Type first');
				 } else {
					 $scope.AccountingSetupModel.AddEditNewServiceJobType.IsDefault = false;
					 $scope.AccountingSetupModel.AddEditNewServiceJobType.IsActive = false;
				 }
			 }else {
				 $scope.AccountingSetupModel.AddEditNewServiceJobType.IsActive = true;
			 }
		  }
		 
		 angular.element(document).on("click", "#change-default-SJT .modal-backdrop", function() {
	    	   $scope.AccountingSetupModel.hideDefaultSJTModalWindow();
	       });
		 $scope.AccountingSetupModel.hideDefaultSJTModalWindow = function() {
			 angular.element('#change-default-SJT').modal('hide');
			 setTimeout(function() {
				 angular.element("body").addClass("modal-open"); 
			 }, 350);
		 }
		 
		 $scope.AccountingSetupModel.confirmChangeDefault = function (){
			 $scope.AccountingSetupModel.defaultSJT.IsDefault = false;
			 $scope.AccountingSetupModel.AddEditNewServiceJobType.IsDefault = true;
			 SJTList.push($scope.AccountingSetupModel.defaultSJT);
			 $scope.AccountingSetupModel.hideDefaultSJTModalWindow();
		 }
		 
		  function openSJTModalWindow() {
          	  $scope.AccountingSetupModel.AddEditNewServiceJobType = {};
              $scope.AccountingSetupModel.isUniqueCode = true;
	    	   setDefaultValidationModel();
	           setTimeout(function() {
	               angular.element('#service-job-type').modal({
	                   backdrop: 'static',
	                   keyboard: false
	               });
	           }, 100);
	       }
		  
		    angular.element(document).on("click", "#service-job-type .modal-backdrop", function() {
		    	   $scope.AccountingSetupModel.hideUploadServiceJobTypeModalWindow();
		       });
		       
		       $scope.AccountingSetupModel.hideUploadServiceJobTypeModalWindow = function() {
		    	   angular.element('#service-job-type').modal('hide');
		    	   angular.element("body").removeClass("modal-open"); 
		    	   $scope.AccountingSetupModel.AddEditNewServiceJobType = {};
		       }
	    $scope.AccountingSetupModel.AccountingSetupStepsList = [
	                                                {
	                                                    Name: 'Back',

														isEnable : false,
	                                                    isActive: false,

														isError: false,
	                                                    isCompleted: false
	                                                }, 
	                                                
	                                                {
	                                                    Name: 'Accounting Provider',

														isEnable : false,
	                                                    isActive: true,

														isError: false,
	                                                    isCompleted: false
	                                                },
	                                                
	                                                {
	                                                    Name: 'Chart of Accounts',

														isEnable : false,
	                                                    isActive: false,

														isError: false,
	                                                    isCompleted: false
	                                                },{
	                                                    Name: 'Control Accounts',

														isEnable : false,
	                                                    isActive: false,

														isError: false,
	                                                    isCompleted: false
	                                                },
	                                                 
	                                                {
	                                                    Name: 'Default Accounts',

														isEnable : false,
	                                                    isActive: false,

														isError: false,
	                                                    isCompleted: false
	                                                },
	                                                
	                                                {
	                                                    Name: 'Categories',

														isEnable : false,
	                                                    isActive: false,

														isError: false,
	                                                    isCompleted: false
	                                                },
	                                                
	                                                {
	                                                    Name: 'Service Job Type',

														isEnable : false,
	                                                    isActive: false,

														isError: false,
	                                                    isCompleted: true
	                                                }
	                                            ];
	                                            

	    $scope.AccountingSetupModel.AccountingProvidersList = [
	                                                {
	                                                    Name: 'Xero',
	                                                    isSelected: false,
	                                                },{
	                                                    Name: 'Quickbooks Online',
	                                                    isSelected: false,
	                                                }, 
	                                                
	                                                {
	                                                    Name: 'MYOB Account Right',
	                                                    isSelected: false,
	                                                },
	                                                
	                                                {
	                                                    Name: 'No Integration',
	                                                    isSelected: false,
	                                                }
	                                            ];
	                                            
	    $scope.AccountingSetupModel.GeneralAccountsSearchText = '';  
	    
	    $scope.AccountingSetupModel.isAccountingProviderStepCompleted = function() { 
	        if($scope.AccountingSetupModel.accountingData != undefined) {
	        	if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'No Integration' ||
	        		$scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'MYOB Account Right' ||
	        		(($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online'
	        			|| $scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero' ) &&
	        		$scope.AccountingSetupModel.accountingData.configuration.IsConnected &&
	        		!$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError)) {
	        			$scope.AccountingSetupModel.AccountingSetupStepsList[1].isCompleted = true;
	       		} else {
	       			$scope.AccountingSetupModel.AccountingSetupStepsList[1].isCompleted = false;
	       		}
	       	}
	    }
	    
	    $scope.AccountingSetupModel.isChartOfAccountsStepCompleted = function() { 
	        if($scope.AccountingSetupModel.accountingData != undefined) {
	        	if((($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online'
	        		|| $scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero' )
	        		&& $scope.AccountingSetupModel.LastSyncTime == '---') ||
	        		(($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online' ||
	        				$scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero' )
	        		&& $scope.AccountingSetupModel.accountingData.configuration.IsConnectedError)) {
	        			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted = false;
	       		}else if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Quickbooks Online' && 
	       				$scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Xero' ){
	       			if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Select One'
	       				|| $scope.AccountingSetupModel.accountingData.configuration.AlignmentMethod == 'Select One'){ 
	       				$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted = false; 
	       			}else if($scope.AccountingSetupModel.AccountsUploadSelectedMethod == 'User supplied list'
	            		&& $scope.AccountingSetupModel.accountingData.accountingList.length == 0) {
	            			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted = false;
	           		} else if($scope.AccountingSetupModel.accountingData.configuration.AlignmentMethod == 'None') { 
	            			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted = true;
	           		} else {
	           				$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted = true; 
	           		}
	        	}else if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Select One'){
	        		$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted = false;  
	        	} else {
	       			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted = true;
	       		}
	       	}
	    }
	    
	    $scope.AccountingSetupModel.isControlAccountsStepCompleted = function() { 
	    	if($scope.AccountingSetupModel.disableControlAccountsNextBtn()) {
	    		if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[4].isCompleted = false;
	    		}else {
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = false;	
	    		}
	   			
	   		} else {
	   			if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[4].isCompleted = true;
	    		}else {
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = true;	
	    		}
	   			//$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = true;
	   		}
	    }
	    $scope.AccountingSetupModel.isTaxCodeMappingStepCompleted = function() {
	    	//validateAllTaxRecMappingOnLoad();
	    	if(!$scope.AccountingSetupModel.isValidAllTaxRecMapping || !$scope.AccountingSetupModel.isValidAllSalesTaxMapping || !$scope.AccountingSetupModel.isValidAllSalesTaxItemMapping || !$scope.AccountingSetupModel.accountingData.configuration.NonTaxableTaxCode) {
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = true;
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = 'Please map your sales taxes'
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = false
	    	} else {
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = false;
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = true
	    	}
	    }
	    
	    $scope.AccountingSetupModel.isDefaultAccountsStepCompleted = function() { 
	    	if($scope.AccountingSetupModel.disableDefaultAccountsNextBtn()) {
	   			if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[5].isCompleted = false;
	   			} else {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[4].isCompleted = false;
	   			}
	   			
	   		} else {
	   			if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[5].isCompleted = true;
	   			} else {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[4].isCompleted = true;
	   			}
	   			
	   		}
	    }
	    
	    $scope.AccountingSetupModel.isCategoriesStepCompleted = function() { 
	    	var incomeGLPresent = false;
	    	$scope.AccountingSetupModel.isAccountingProviderStepCompleted();
	    	$scope.AccountingSetupModel.isChartOfAccountsStepCompleted();
	    	if($scope.AccountingSetupModel.categoriesList != undefined) {
	    		incomeGLPresent = true;
	        	for(var i=0; i < $scope.AccountingSetupModel.categoriesList.length; i++){
						if($scope.AccountingSetupModel.categoriesList[i].IncomeGL == null ||
							$scope.AccountingSetupModel.categoriesList[i].IncomeGL == '' ||
							$scope.AccountingSetupModel.categoriesList[i].IncomeGL == undefined){
								incomeGLPresent = false;
								break;
						}
				}
	    	}
	    	if($scope.AccountingSetupModel.AccountingSetupStepsList[1].isCompleted &&
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted &&
	    		incomeGLPresent) {
	    		if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[6].isCompleted = true;
	    		} else {
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[5].isCompleted = true;
	    		}
	   			
	   		} else {
	   			if($scope.AccountingSetupModel.accountingData && $scope.AccountingSetupModel.accountingData.configuration && $scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[6].isCompleted = false;
	   			} else {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[5].isCompleted = false;
	   			}
	   			
	   		}
	    }
	      
	   $scope.AccountingSetupModel.disableDefaultAccountsCategoryBtn = function(){
		   $scope.AccountingSetupModel.isCategoriesStepCompleted();
		  var isStep5Complete = $scope.AccountingSetupModel.accountingData && $scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled ? $scope.AccountingSetupModel.AccountingSetupStepsList[6].isCompleted : $scope.AccountingSetupModel.AccountingSetupStepsList[5].isCompleted;
		   if(isStep5Complete) {
			   return true;
		   }else {
			   return false;
		   }
	   }
	   $scope.AccountingSetupModel.isAccountingSetupCompleted = function() { 
	   		$scope.AccountingSetupModel.isAccountingSetupError = false;
	   		var ErrorMessage = 'You need to complete step ';
	   		for(var i=1; i<=5; i++){
	   			if($scope.AccountingSetupModel.AccountingSetupStepsList[i].isError){
	   				$scope.AccountingSetupModel.isAccountingSetupError = true;
	   			}
	   			if($scope.AccountingSetupModel.AccountingSetupStepsList[i].isError
	   				|| !$scope.AccountingSetupModel.AccountingSetupStepsList[i].isCompleted){
	   				ErrorMessage += i+', ';
	   			}
	   		}
	   		ErrorMessage = ErrorMessage.substring(0, ErrorMessage.length-2);
	   		if(ErrorMessage.lastIndexOf(",") != -1){
	   			ErrorMessage = ErrorMessage.replace('step', 'steps');
	   			ErrorMessage = ErrorMessage.substring(0, ErrorMessage.lastIndexOf(",")) + ' and' +ErrorMessage.substring(ErrorMessage.lastIndexOf(",")+1, ErrorMessage.length);
	   		}
	   		$scope.AccountingSetupModel.isAccountingSetupErrorMessage = ErrorMessage + ' before your accounting transaction will be recorded accurately.';
	   		var accountSetup3isCompleted = $scope.AccountingSetupModel.accountingData && $scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled ? $scope.AccountingSetupModel.AccountingSetupStepsList[4].isCompleted : $scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted;
	    	var accountSetup4isCompleted = $scope.AccountingSetupModel.accountingData && $scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled ? $scope.AccountingSetupModel.AccountingSetupStepsList[5].isCompleted : $scope.AccountingSetupModel.AccountingSetupStepsList[4].isCompleted;
	    	var accountSetup5isCompleted = $scope.AccountingSetupModel.accountingData && $scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled ? $scope.AccountingSetupModel.AccountingSetupStepsList[6].isCompleted : $scope.AccountingSetupModel.AccountingSetupStepsList[5].isCompleted;
	    	
	    	if($scope.AccountingSetupModel.AccountingSetupStepsList[1].isCompleted &&
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted &&
	    		accountSetup3isCompleted && accountSetup4isCompleted && accountSetup5isCompleted) {
	   			$scope.AccountingSetupModel.AccountingIntegrationSetUpStatus = 'completed';
	   			return true;
	   		} else {
	   			$scope.AccountingSetupModel.AccountingIntegrationSetUpStatus = 'incomplete';
	   			return false;
	   		}
	    }
	    
	    
	    // Error Step Methods
	    $scope.AccountingSetupModel.isAccountingProviderStepError = function() { 
	        if($scope.AccountingSetupModel.accountingData != undefined) {
	        	if((($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online' 
	        		|| $scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero' ) &&
	        		!$scope.AccountingSetupModel.accountingData.configuration.IsConnected) ||
	        		(($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online' || 
	        				$scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero' ) && 
	        			$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError)) {
	        			$scope.AccountingSetupModel.AccountingSetupStepsList[1].isError = true;
	        			$scope.AccountingSetupModel.AccountingSetupStepsList[1].ErrorMessage = 'Check the connection to Quickbooks';
	       		} else {
	       			$scope.AccountingSetupModel.AccountingSetupStepsList[1].isError = false;
	       			$scope.AccountingSetupModel.AccountingSetupStepsList[1].ErrorMessage = '';
	       		}
	       	}
	    }
	    
	    $scope.AccountingSetupModel.isChartOfAccountsStepError = function() {
	        if($scope.AccountingSetupModel.accountingData != undefined &&
	        	$scope.AccountingSetupModel.AccountingSetupStepsList[1].isCompleted) {
	        	if(($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online' 
	        		|| $scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero' )
	        		&& $scope.AccountingSetupModel.LastSyncTime == '---') {
	        			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isError = true;
	        			$scope.AccountingSetupModel.AccountingSetupStepsList[2].ErrorMessage = 'Sync to the Quickbooks Chart of Accounts';
	       		}else if(($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online'|| 
	       					$scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero' )
	        				&& $scope.AccountingSetupModel.accountingData.configuration.IsConnectedError){
	        			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isError = true;
	        			$scope.AccountingSetupModel.AccountingSetupStepsList[2].ErrorMessage = 'Check the connection to Quickbooks';
	        	}else if(($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Quickbooks Online' &&  $scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero' )
	        		&& $scope.AccountingSetupModel.AccountsUploadSelectedMethod == 'User supplied list'
	        		&& $scope.AccountingSetupModel.accountingData.accountingList.length == 0) {
	        			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isError = true;
	        			$scope.AccountingSetupModel.AccountingSetupStepsList[2].ErrorMessage = 'Upload your Chart of Accounts';
	        	}else {
	       			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isError = false;
	       			$scope.AccountingSetupModel.AccountingSetupStepsList[2].ErrorMessage = '';
	       		}
	       	} else { 
	   			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isError = false;
	   			$scope.AccountingSetupModel.AccountingSetupStepsList[2].ErrorMessage = '';
	       	}
	    }
	    
	    
	    $scope.AccountingSetupModel.isControlAccountsStepError = function() { 
	    	if($scope.AccountingSetupModel.disableControlAccountsNextBtn() &&
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[1].isCompleted &&
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted) {
	   			if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[4].isError = true;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[4].ErrorMessage = 'Please set your Control Accounts';
	   			} else {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = true;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = 'Please set your Control Accounts';
	   			}
	   			
	   		} else {
	   			if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[4].isError = false;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[4].ErrorMessage = '';
	   			} else {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = false;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = '';
	   			}
	   			
	   		}
	    }
	    
	    
	    $scope.AccountingSetupModel.isDefaultAccountsStepError = function() { 
	    	if($scope.AccountingSetupModel.disableDefaultAccountsNextBtn() &&
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[1].isCompleted &&
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted) {
	   			if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[5].isError = true;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[5].ErrorMessage = 'Please set your Default Accounts';
	   			} else{
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[4].isError = true;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[4].ErrorMessage = 'Please set your Default Accounts';
	   			}
	   			
	   		} else {
	   			if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[5].isError = false;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[5].ErrorMessage = '';
	   			} else {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[4].isError = false;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[4].ErrorMessage = '';
	   			}
	   			
	   		}
	    }
	    
	    
	    $scope.AccountingSetupModel.isCategoriesStepError = function() { 
	    	var incomeGLPresent = true;
	    	$scope.AccountingSetupModel.isAccountingProviderStepCompleted();
	    	$scope.AccountingSetupModel.isChartOfAccountsStepCompleted();
	    	if($scope.AccountingSetupModel.categoriesList != undefined &&
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[1].isCompleted &&
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[2].isCompleted) {
	        	for(var i=0; i < $scope.AccountingSetupModel.categoriesList.length; i++){
						if($scope.AccountingSetupModel.categoriesList[i].IncomeGL == null ||
							$scope.AccountingSetupModel.categoriesList[i].IncomeGL == '' ||
							$scope.AccountingSetupModel.categoriesList[i].IncomeGL == undefined){
								incomeGLPresent = false;
								break;
						}
				}
	    	}
	    	if(!incomeGLPresent) {
	    		if($scope.AccountingSetupModel.accountingData && $scope.AccountingSetupModel.accountingData.configuration && $scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[6].isError = true;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[6].ErrorMessage = 'Assign GL Accounts to your categories';
	    		} else {
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[5].isError = true;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[5].ErrorMessage = 'Assign GL Accounts to your categories';
	    		}
	   			
	   		} else {
	   			if($scope.AccountingSetupModel.accountingData && $scope.AccountingSetupModel.accountingData.configuration && $scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[6].isError = false;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[6].ErrorMessage = '';
	   			} else{
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[5].isError = false;
	   				$scope.AccountingSetupModel.AccountingSetupStepsList[5].ErrorMessage = '';
	   			}
	   			
	   		}
	    }
	    // End Step Error
	    
	    $scope.AccountingSetupModel.NextAction = function(index){
	        $scope.AccountingSetupModel.moveIndextoNext = index;
	        
	        $scope.AccountingSetupModel.selectedAccountingChevronIndex = index;
	        $scope.AccountingSetupModel.displaySection =  $scope.AccountingSetupModel.AccountingSetupStepsList[index].Name;
	    	
            if(index == '6') {
	        	$scope.AccountingSetupModel.getMasterDataForServiceJobType();
	        }
        }

	    $scope.AccountingSetupModel.changeAccountingProvider = false;
	    $scope.AccountingSetupModel.ProviderSelected = function(ProviderValue) {
			$scope.AccountingSetupModel.selectedProviderValue = ProviderValue;
	        if(ProviderValue != $scope.AccountingSetupModel.selectedAccountingProvider) {
	    		$scope.AccountingSetupModel.changeAccountingProvider = true;
	    	}
	        if(ProviderValue != 'Select One' && 
	            	ProviderValue != $scope.AccountingSetupModel.accountingData.configuration.AccountingProvider && 
	            	$scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Select One') { 
	            $scope.AccountingSetupModel.removeAccountingConnectionText = 'change';
	        	$scope.AccountingSetupModel.openChangeAccountingProviderPopup();
	        	$scope.AccountingSetupModel.ChangedAccountingProvide = ProviderValue;
	        }
	        if($scope.AccountingSetupModel.changeAccountingProvider) {
	        	if($scope.AccountingSetupModel.selectedProviderValue != 'Quickbooks Online')	{
	        		$scope.AccountingSetupModel.isAccountingSetupDataSaved  = false; 
	        	}
	        	$scope.AccountingSetupModel.selectedAccountingProvider = ProviderValue;	
	        }
	        if($scope.AccountingSetupModel.selectedAccountingProvider == 'Quickbooks Online') {
	        	$scope.AccountingSetupModel.selectedIntegrationName = 'Quickbooks';
	        } else if($scope.AccountingSetupModel.selectedAccountingProvider == 'Xero') {
	        	$scope.AccountingSetupModel.selectedIntegrationName = 'Xero';
	        } else {
	        	$scope.AccountingSetupModel.selectedIntegrationName = '';
	        }
	        
	    }
	    
	     $scope.AccountingSetupModel.getQBTaxCodes  = function(){
	    	var defer = $q.defer();
	        AccountingService.getQBTaxCodes().then(function(successfulResult) {
	        	$scope.AccountingSetupModel.QBTaxCodeList = successfulResult;
	        	if($scope.AccountingSetupModel.QBTaxCodeList.length > 0) {
	        		$scope.AccountingSetupModel.lastTaxCodeSync = $scope.AccountingSetupModel.QBTaxCodeList[0].LastModifiedDate;
	        	} else {
	        		$scope.AccountingSetupModel.lastTaxCodeSync = '---------'
	        	}
	        	//generateTaxRateIdToTaxCodeRateMap();
	            defer.resolve();
	        }, function(errorSearchResult) {
	            responseData = errorSearchResult;
	            defer.reject($translate.instant('GENERIC_ERROR'));
	        });
	        return defer.promise;
	    }
	    
	    $scope.AccountingSetupModel.getSalesTaxList  = function(){
	    	var defer = $q.defer();
	        AccountingService.getSalesTaxList().then(function(successfulResult) {
	        	$scope.AccountingSetupModel.selesTaxList = successfulResult;
	            defer.resolve();
	        }, function(errorSearchResult) {
	            responseData = errorSearchResult;
	            defer.reject($translate.instant('GENERIC_ERROR'));
	        });
	        return defer.promise;
	    }
	    $scope.AccountingSetupModel.getTaxRates  = function(){
	    	var defer = $q.defer();
	        AccountingService.getTaxRates().then(function(successfulResult) {
	        	$scope.AccountingSetupModel.taxRateList = successfulResult;
	            defer.resolve();
	        }, function(errorSearchResult) {
	            responseData = errorSearchResult;
	            defer.reject($translate.instant('GENERIC_ERROR'));
	        });
	        return defer.promise;
	    }

	    $scope.AccountingSetupModel.getSalesTaxItemList = function(){
	    	var defer = $q.defer();
	        AccountingService.getSalesTaxItemList().then(function(successfulResult) {
	        	$scope.AccountingSetupModel.SalesTaxItemList = successfulResult;
	            defer.resolve();
	        }, function(errorSearchResult) {
	            responseData = errorSearchResult;
	            defer.reject($translate.instant('GENERIC_ERROR'));
	        });
	        return defer.promise;
	    }

	    $scope.AccountingSetupModel.getQBNonTaxableTaxCodes = function(){
	    	var defer = $q.defer();
	        AccountingService.getQBNonTaxableTaxCodes().then(function(successfulResult) {
	        	$scope.AccountingSetupModel.nonTaxableTaxCodeList = successfulResult;
	            defer.resolve();
	        }, function(errorSearchResult) {
	            responseData = errorSearchResult;
	            defer.reject($translate.instant('GENERIC_ERROR'));
	        });
	        return defer.promise;
	    }
	    
	    function generateTaxRateIdToTaxCodeRateMap() {
	    	if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Quickbooks Online') {
	    		return;
	    	}
	    	var salesTaxItemIdToTaxCodeAccountingIdMap = {};
	    	for (var i=0;i<$scope.AccountingSetupModel.taxRateList.length;i++) {
	    		salesTaxItemIdToTaxCodeAccountingIdMap[$scope.AccountingSetupModel.taxRateList[i].Id] = $scope.AccountingSetupModel.taxRateList[i];
	    	}
	    	for(var i=0;i<$scope.AccountingSetupModel.QBTaxCodeList.length;i++) {
	    		$scope.AccountingSetupModel.QBTaxCodeList[i].taxCodeLabel = '';
	    		for(var j=0;j<$scope.AccountingSetupModel.QBTaxCodeList[i].ApplicableTaxRates.length;j++) {
		    		$scope.AccountingSetupModel.QBTaxCodeList[i].taxCodeLabel += (salesTaxItemIdToTaxCodeAccountingIdMap[$scope.AccountingSetupModel.QBTaxCodeList[i].ApplicableTaxRates[j]].RateValue + '%' + ' ' + '-' + ' ' + salesTaxItemIdToTaxCodeAccountingIdMap[$scope.AccountingSetupModel.QBTaxCodeList[i].ApplicableTaxRates[j]].Name + ', ' ) 
		    		if(j == $scope.AccountingSetupModel.QBTaxCodeList[i].ApplicableTaxRates.length - 1) {
		    			$scope.AccountingSetupModel.QBTaxCodeList[i].taxCodeLabel = $scope.AccountingSetupModel.QBTaxCodeList[i].taxCodeLabel.replace(/,\s*$/, "");
		    		}
	    		}
	    	}
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
	     $scope.AccountingSetupModel.loadAccoutingData = function(){
	    	$q.all([$scope.AccountingSetupModel.getAccountingSettingDetails(), 
	    	        $scope.AccountingSetupModel.getCategories(),
	    	        $scope.AccountingSetupModel.getQBTaxCodes(),
	    	        $scope.AccountingSetupModel.getSalesTaxList(),
	    	        $scope.AccountingSetupModel.getTaxRates(),
	    	        $scope.AccountingSetupModel.getSalesTaxItemList(),
	    	        $scope.AccountingSetupModel.getAllServiceJobTypes(),
	    	        $scope.AccountingSetupModel.getQBNonTaxableTaxCodes()
	    	        ]).then(function() {
	    	        	if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	    	    	        validateAllTaxRecMappingOnLoad();
	    	    	        generateTaxRateIdToTaxCodeRateMap();
	    	    	        generateTaxCodeLabelList();
	    	    	        validateOnLoadStepComp();
	    	    	        showTooltip('body');
	    	    	        $scope.AccountingSetupModel.isTaxCodeMappingStepCompleted();

	    	        	}
	        	  setTimeout(function() {
	        		  $scope.AccountingSetupModel.calculateRightPanelHeight()
	        	  }, 10);
	        });
	        setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'bottom'}); }, 2000);
	    }
	    
	    $scope.AccountingSetupModel.showServiceJobTypeDropDown = function(type) {
	    	$scope.AccountingSetupModel.hideServiceJobTypeDropDown();
	    	angular.element("#service-job-"+type+'-dropdown-div').show();
	    }
	    $scope.AccountingSetupModel.hideServiceJobTypeDropDown = function () {
	    	angular.element(".bp-autocomplete-dropdown-wrapper").hide();
	    	$scope.AccountingSetupModel.currentDropDownIndex = -1;
	    }
	    $scope.AccountingSetupModel.editCategory = function(categoryJSON){
			$scope.AccountingSetupModel.isAccountingSetupDataSaved = false;
			loadState($state, 'AccountingIntegrationSettings.AddEditCategory', {AddEditCategoryParams :{categoryJSON: categoryJSON}});
	    }
	    
	    $scope.AccountingSetupModel.openRemoveCategoryPopup = function(categoryJSON){
	        if(categoryJSON.IsDefault == true){
	        	Notification.error("You Can't Delete Category with Default Active");
	        }
	        else{
	           	$scope.AccountingSetupModel.deletecategory = categoryJSON;
	            angular.element('#RemoveCategoryPopup').modal({
	                   backdrop: 'static',
	                   keyboard: false 
	            });
	        }
	    }
	    
	    $scope.AccountingSetupModel.removeCategory = function(categoryJSON){
	    	 AccountingService.removeCategory(categoryJSON.Id).then(function(successResult) {
	            $scope.AccountingSetupModel.categoriesList = successResult;
	            $scope.AccountingSetupModel.closeRemoveCategoryPopup();
	        }, function(errorSearchResult) {
	            Notification.error("Error in saving Default Accounts");
	        });
	    	
	    }

	    $scope.AccountingSetupModel.closeRemoveCategoryPopup = function(){
	        angular.element('#RemoveCategoryPopup').modal('hide');
	    }
	    
	    $scope.AccountingSetupModel.closeRemoveCategoryInUsePopup = function(){
	        angular.element('#RemoveCategoryInUsePopup').modal('hide');
	    }
		
	    $scope.AccountingSetupModel.openRemoveCategoryInUsePopup = function(CategoryJSON){
	        $scope.AccountingSetupModel.deletecategory = CategoryJSON;
	        angular.element('#RemoveCategoryInUsePopup').modal({
	               backdrop: 'static',
	               keyboard: false 
	        });
	    }

	    $scope.AccountingSetupModel.openChangeDefaultCategoryPopup = function(){
	        angular.element('#ChangeDefaultCategoryPopup').modal({
	               backdrop: 'static',
	               keyboard: false 
	        });
	    }
	    
	    $scope.AccountingSetupModel.closeChangeDefaultCategoryPopup = function(){
	        angular.element('#ChangeDefaultCategoryPopup').modal('hide');
	    }
	                                                                
	     $scope.AccountingSetupModel.getCategories  = function(){
	    	var defer = $q.defer();
	        AccountingService.getCategoryDetails().then(function(successfulResult) {
	            $scope.AccountingSetupModel.categoriesList = successfulResult;
	            $scope.AccountingSetupModel.isCategoriesStepCompleted();
	            $scope.AccountingSetupModel.isCategoriesStepError();
	            defer.resolve();
	        }, function(errorSearchResult) {
	            responseData = errorSearchResult;
	            defer.reject($translate.instant('GENERIC_ERROR'));
	        });
	        return defer.promise;
	    }
	    
	    $scope.AccountingSetupModel.getMasterDataForServiceJobType = function() {
	    	AccountingService.getMasterDataForServiceJobType().then(function(successfulResult) {
	    		$scope.AccountingSetupModel.MasterDataForSJType = successfulResult;
	    		for (var key in $scope.AccountingSetupModel.MasterDataForSJType) {
	    			if(key!= 'TransactionTypeList' && key != 'ProviderList') {
	    				var insertDefaultElement = {
	    	    				CategoryName:"Default",
	    	    				Id:null,
	    	    				IsDefault:false
	    	    		}
	    				$scope.AccountingSetupModel.MasterDataForSJType[key].splice(0,0,insertDefaultElement)
	    			}else if(key == 'ProviderList') {
	    				var insertDefaultElement = {
	    	    				Name:"Default",
	    	    				Id:null,
	    	    				IsDefault:false
	    	    		}
	    				$scope.AccountingSetupModel.MasterDataForSJType[key].splice(0,0,insertDefaultElement)
	    			}
	    		}
	        }, function(errorSearchResult) {
	            responseData = errorSearchResult;
	        });
	    }
	    
	    $scope.AccountingSetupModel.setSJTData = function (setSJTDataRec,fieldName){
	    	if(fieldName == 'Type') {
	    		$scope.AccountingSetupModel.AddEditNewServiceJobType[fieldName] = setSJTDataRec
	    	}else if(fieldName == 'Provider'){
	    		$scope.AccountingSetupModel.AddEditNewServiceJobType[fieldName] = setSJTDataRec.Name
	    		$scope.AccountingSetupModel.AddEditNewServiceJobType.ProviderId = setSJTDataRec.Id;
	    	} else{
	    		$scope.AccountingSetupModel.AddEditNewServiceJobType[fieldName] = setSJTDataRec.CategoryName
	    		$scope.AccountingSetupModel.AddEditNewServiceJobType[fieldName+'Id'] = setSJTDataRec.Id;
	    	}
	    	$scope.AccountingSetupModel.hideServiceJobTypeDropDown()
	    	
        } 
	    
	     $scope.AccountingSetupModel.getAllServiceJobTypes = function() {
	    	 var defer = $q.defer();
	    	 AccountingService.getAllServiceJobTypes().then(function(successfulResult) {
	    		 $scope.AccountingSetupModel.serviceJobTypeList = successfulResult;
	    		 defer.resolve();
	         }, function(errorSearchResult) {
	        	  responseData = errorSearchResult;
	        	  defer.reject($translate.instant('GENERIC_ERROR'));
	        });
    	 	return defer.promise;
	    }
	    
	    $scope.AccountingSetupModel.categorySortingArray = [];
	    $scope.AccountingSetupModel.sortCategory = function(key, sortDirection){
	        var ascIndex  = _.indexOf($scope.AccountingSetupModel.categorySortingArray , key);
	        var descIndex = _.indexOf($scope.AccountingSetupModel.categorySortingArray , '-'+key);
	        if(sortDirection == 'ASC'){
	            if(ascIndex != -1){
	                $scope.AccountingSetupModel.categorySortingArray.splice(ascIndex, 1);
	            }else if(descIndex != -1){
	                $scope.AccountingSetupModel.categorySortingArray[descIndex] = key;
	            }else{
	                $scope.AccountingSetupModel.categorySortingArray.push(key);
	            }
	        }else if(sortDirection == 'DESC'){
	            if(ascIndex != -1){
	                $scope.AccountingSetupModel.categorySortingArray[ascIndex] = '-'+key;
	            }else if(descIndex != -1){
	                $scope.AccountingSetupModel.categorySortingArray.splice(descIndex, 1);
	            }else{
	                $scope.AccountingSetupModel.categorySortingArray.push('-'+key);
	            }
	        }
	    }
	    
	    
	    $scope.AccountingSetupModel.isCategorySorted = function(key, sortDirection){
	        var ascIndex  = _.indexOf($scope.AccountingSetupModel.categorySortingArray , key);
	        var descIndex = _.indexOf($scope.AccountingSetupModel.categorySortingArray , '-'+key);
	        if(sortDirection == 'ASC'){
	            if(ascIndex != -1){
	                return true;
	            }
	        }
	        if(sortDirection == 'DESC'){
	            if(descIndex != -1){
	                return true;
	            }
	        }
	        return false;
	    }
	    
	     $scope.AccountingSetupModel.calculateRightPanelHeight = function(){
	        var RightPanelHeight =  $(document).height()  - (angular.element(".app-global-header").height() + 
	                                                         angular.element(".cashSaleCrumbs_UL").height() + 
	                                                         angular.element(".cashSaleCopyright").height() + 13 );
	        angular.element(".rightPanel").css("height", RightPanelHeight);
	        angular.element(".rightPanelContent").css("height", RightPanelHeight - 2); 
	        angular.element(".AccountingContent").css("min-height", RightPanelHeight); 
            var rightPanelHeaderHeight =  angular.element(".rightPanelHeader").height()
	        var rightPanelAccountingSetupStepsContainerHeight = (RightPanelHeight - rightPanelHeaderHeight - 30 - 16)
	        angular.element(".rightPanelAccountingSetupStepsContainer").css("max-height",rightPanelAccountingSetupStepsContainerHeight);
	        setTimeout(function(){
	            if(angular.element('.rightPanel').length > 0) {
	                    angular.element('.rightPanel')[0].scrollIntoView(true);
	            }
	        }, 10);
	    }	    
	    
	   $scope.AccountingSetupModel.calculateRightPanelHeight1 = function(){
	        var deviceHeight;
	         if(getDeviceOrientation() === 'Landscape') {
	            deviceHeight = $(window).height();
	         } else if(getDeviceOrientation() === 'Portrait')   {
	            deviceHeight = $(document).height();
	         }
	        var RightPanelHeight =  deviceHeight  - (angular.element(".headerNav").height() + 
	                                                         angular.element(".cashSaleCrumbs_UL").height() + 
	                                                         angular.element(".cashSaleCopyright").height() + 13 );
	        angular.element(".rightPanel").css("height", RightPanelHeight);
	        angular.element(".rightPanelContent").css("height", RightPanelHeight - 2); 
	        angular.element(".AccountingContent").css("min-height", RightPanelHeight); 
	        var rightPanelHeaderHeight =  angular.element(".rightPanelHeader").height()
	        var rightPanelAccountingSetupStepsContainerHeight = (RightPanelHeight - rightPanelHeaderHeight - 30 - 16)
	        angular.element(".rightPanelAccountingSetupStepsContainer").css("max-height",rightPanelAccountingSetupStepsContainerHeight);
	        setTimeout(function(){
	            if(angular.element('.rightPanel').length > 0) {
	                    angular.element('.rightPanel')[0].scrollIntoView(true);
	            }
	        }, 10);
	    }

	    function getDeviceOrientation() {
	        if (Math.abs(window.orientation) === 90) {
	            return 'Landscape';
	        } else {
	            return 'Portrait';
	        }
	    }
	    angular.element($window).bind('orientationchange', function (event) {
	        $scope.AccountingSetupModel.calculateRightPanelHeight1();
	    });
	    
	    $scope.AccountingSetupModel.showGetIntegrationDataPopup = function(IntegrationName) {
	        if(IntegrationName == 'Quickbooks Online') {
	        	$scope.AccountingSetupModel.IntegrationModalHeaderText = 'Please provide Consumer Key and Consumer Secret of the QB Application';
	        } else{
	        	$scope.AccountingSetupModel.IntegrationModalHeaderText = 'Please provide Consumer Key and Consumer Secret of the ' + IntegrationName + ' Application';
	        }
	    	setTimeout(function(){ 
	            angular.element('#IntegrationConsumerKey').focus();
	        },200);
	        angular.element('#IntegrationDataPopup').modal({
	               backdrop: 'static',
	               keyboard: false 
	        });
	    }
	    
	    $scope.AccountingSetupModel.closeGetIntegrationDataPopup = function() {
	        angular.element('#IntegrationDataPopup').modal('hide');
	    }

	    $scope.AccountingSetupModel.getTaxCodeMappingLabel = function(Name,Rate) {
	    	return Name + ' ('+ Rate + '%)';
	    }
	    
	    $scope.AccountingSetupModel.connectIntegration = function(IntegrationName) {
	        var ConsumerKey = $scope.AccountingSetupModel.QBDataModel.ConsumerKey;
	        var ConsumerSercret = $scope.AccountingSetupModel.QBDataModel.ConsumerSecret; 
	        $scope.AccountingSetupModel.QBDataModel.isErrorConsumerKey = false; 
	        $scope.AccountingSetupModel.QBDataModel.isErrorConsumerSecret = false; 
	        if(ConsumerKey == null || ConsumerKey == '' || ConsumerKey == undefined) {
	        	$scope.AccountingSetupModel.QBDataModel.isErrorConsumerKey = true; 
	        } 
	        if(ConsumerSercret == null || ConsumerSercret == '' || ConsumerSercret == undefined) {
	        	$scope.AccountingSetupModel.QBDataModel.isErrorConsumerSecret = true; 
	        }     
	        if($scope.AccountingSetupModel.QBDataModel.isErrorConsumerSecret || $scope.AccountingSetupModel.QBDataModel.isErrorConsumerKey) { 
	        	return;
	        }
	        if(IntegrationName == 'Quickbooks Online') {
	        	AccountingService.OAuthConnection(ConsumerKey, ConsumerSercret).then(function(res) {
		            if(res.responseStatus == 'success') {
		                var left = $(window).height() / 2;
		                window.open(res.response, "callback", 'height=700,width=900,left='+ left); 
		            } else {
		                $scope.AccountingSetupModel.isQBConnectionError = true;
		                $scope.AccountingSetupModel.isQBConnected = false;
		                $scope.AccountingSetupModel.errorMessage = res.responseStatus;
		                Notification.error(res.responseStatus);
		            }
		            $scope.AccountingSetupModel.closeGetIntegrationDataPopup();
		        },
		        function(errorSearchResult) { 
		        	$scope.AccountingSetupModel.isQBConnectionError = true;
		            $scope.AccountingSetupModel.isQBConnected = false;
		            $scope.AccountingSetupModel.errorMessage = res.responseStatus;
		            Notification.error(res.responseStatus);
		        });
	        } else if(IntegrationName == 'Xero') {
	        	AccountingService.OAuthConnectionStep1(ConsumerKey, ConsumerSercret,'Xero').then(function(res) {
	        		 if(res.responseStatus == 'success') {
			                var left = $(window).height() / 2;
			                window.open(res.response, "callback", 'height=700,width=900,left='+ left); 
			            } else {
			            }
	        		console.log(res);
		            $scope.AccountingSetupModel.closeGetIntegrationDataPopup();
		        },
		        function(errorSearchResult) { 
		        });
	        }
	        
	    }
	    
	    $scope.AccountingSetupModel.getQBCompanyInfo = function() {
	    	AccountingService.getQBCompanyInfo().then(function(successfulResult) {
	            if(successfulResult.responseStatus == 'success') {
	            	$scope.AccountingSetupModel.setData(JSON.parse(successfulResult.response));
	            	Notification.success('Connected successfully');
	            } else {
	            	$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError = true;
	            	$scope.AccountingSetupModel.setRightSidebarVariables();
	            	$scope.AccountingSetupModel.errorMessage = successfulResult.responseStatus;
	            	$scope.AccountingSetupModel.showErrorMsgPopup();
	            }
	        }, function(errorSearchResult) {
	        	$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError = true;
	        	$scope.AccountingSetupModel.setRightSidebarVariables();
	        	$scope.AccountingSetupModel.errorMessage = successfulResult.responseStatus;
	        	$scope.AccountingSetupModel.showErrorMsgPopup();
	        });
	    }
	    
	    $scope.AccountingSetupModel.getConnectedCompanyInfo = function() {
	    	AccountingService.getConnectedCompanyInfo('Xero').then(function(successfulResult) {
	            if(successfulResult.responseStatus == 'success') {
	            	$scope.AccountingSetupModel.accountingData.configuration = JSON.parse(successfulResult.response);
	            	Notification.success('Connected successfully');
	            } else {
	            	$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError = true;
	            	$scope.AccountingSetupModel.setRightSidebarVariables();
	            	$scope.AccountingSetupModel.errorMessage = JSON.parse(successfulResult.response);
	            	$scope.AccountingSetupModel.showErrorMsgPopup();
	            }
	        }, function(errorSearchResult) {
	        	$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError = true;
	        	$scope.AccountingSetupModel.setRightSidebarVariables();
	        	$scope.AccountingSetupModel.errorMessage = successfulResult.responseStatus;
	        	$scope.AccountingSetupModel.showErrorMsgPopup();
	        });
	    }
	    
	    $scope.AccountingSetupModel.showErrorMsgPopup = function() {
	        angular.element('#ErrorMsgPopUp').modal({
	               backdrop: 'static',
	               keyboard: false 
	        });
	    }
	    
	    $scope.AccountingSetupModel.closeErrorMsgPopup = function() {
	        angular.element('#ErrorMsgPopUp').modal('hide');
	    }
	    
	    $scope.AccountingSetupModel.disableSyncNowBtn = false;
	    $scope.AccountingSetupModel.syncAccounts = function() {
	    	$scope.AccountingSetupModel.disableSyncNowBtn = true;
	    	if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online') {
	    		AccountingService.syncAccounts().then(function(successfulResult) {
		    		$scope.AccountingSetupModel.disableSyncNowBtn = false;
		            if(successfulResult.responseStatus == 'success') {
		            	$scope.AccountingSetupModel.setData(JSON.parse(successfulResult.response));
		            	Notification.success('Accounts synced successfully');
		            } else {
		            	$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError = true;
		            	$scope.AccountingSetupModel.setRightSidebarVariables();
		            	Notification.error(successfulResult.responseStatus);
		            }
		        }, function(errorSearchResult) {
		        	$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError = true;
		        	$scope.AccountingSetupModel.setRightSidebarVariables();
		            $scope.AccountingSetupModel.disableSyncNowBtn = false;
		            Notification.error("Error in syncing Accounts");
		        });
	    	} else {
	    		AccountingService.getChartOfAccounts('Xero').then(function(successfulResult) {
		    		$scope.AccountingSetupModel.disableSyncNowBtn = false;
		            if(successfulResult != 'error') {
		            	$scope.AccountingSetupModel.accountingData.accountingList = successfulResult;
		            	$scope.AccountingSetupModel.LastSyncTime = '---';
		    	    	if($scope.AccountingSetupModel.accountingData.accountingList.length > 0){
		    	    		$scope.AccountingSetupModel.LastSyncTime = $scope.AccountingSetupModel.accountingData.accountingList[0].LastModifiedDate
		    	    	}
		            	Notification.success('Accounts synced successfully');
		            } else {
		            	$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError = true;
		            	$scope.AccountingSetupModel.setRightSidebarVariables();
		            	Notification.error(successfulResult.responseStatus);
		            }
		        }, function(errorSearchResult) {
		        	$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError = true;
		        	$scope.AccountingSetupModel.setRightSidebarVariables();
		            $scope.AccountingSetupModel.disableSyncNowBtn = false;
		            Notification.error("Error in syncing Accounts");
		        });
	    	}
	    }
	    
	    $scope.AccountingSetupModel.showAccountsListPopup = function() {
	        angular.element('#AccountsListPopUp').modal({
	               backdrop: 'static',
	               keyboard: false 
	        });
	        setTimeout(function() {
	        	if(angular.element(".AccountsListDataTable tbody").height() > $scope.AccountingSetupModel.ConstantTableHeight) {
	        		$scope.AccountingSetupModel.isScrollInTable = true;
	        	} else {
	        		$scope.AccountingSetupModel.isScrollInTable = false;
	        	}
	        },1000);
	    }
	    
	    $scope.AccountingSetupModel.closeAccountsListPopup = function() {
	        angular.element('#AccountsListPopUp').modal('hide');
	    }
	    
	    $scope.AccountingSetupModel.getAccountingSettingDetails = function() {
	    	var defer = $q.defer();
	        AccountingService.getAccountingSettingDetails().then(function(responseResult) {
	            $scope.AccountingSetupModel.setData(responseResult);
	            $scope.AccountingSetupModel.exitActionFromCOAPage();
	            defer.resolve();
	        }, function(errorSearchResult) {
	        	defer.reject($translate.instant('GENERIC_ERROR'));
	        });
	        return defer.promise;
	    }
	    
	    $scope.AccountingSetupModel.setRightSidebarVariables = function(){
	    	$scope.AccountingSetupModel.isAccountingProviderStepCompleted(); 
	    	$scope.AccountingSetupModel.isChartOfAccountsStepCompleted(); 
	    	$scope.AccountingSetupModel.isControlAccountsStepCompleted(); 	    	 
	    	$scope.AccountingSetupModel.isDefaultAccountsStepCompleted(); 
	    	$scope.AccountingSetupModel.isCategoriesStepCompleted(); 
	    	$scope.AccountingSetupModel.isAccountingProviderStepError(); 
	    	$scope.AccountingSetupModel.isChartOfAccountsStepError(); 
	    	$scope.AccountingSetupModel.isControlAccountsStepError(); 
	    	$scope.AccountingSetupModel.isDefaultAccountsStepError(); 
	    	$scope.AccountingSetupModel.isCategoriesStepError(); 
	    }

	    $scope.AccountingSetupModel.setData = function(result){
	    	$scope.AccountingSetupModel.accountingData = result;
	    	var taxCoeMappingObj = {
                        Name: 'Tax Code Mapping',
						isEnable : false,
                        isActive: false,
						isError: false,
                        isCompleted: false
	    				}
	    	var taxCodeMappingIndex = _.findIndex($scope.AccountingSetupModel.AccountingSetupStepsList, {Name: 'Tax Code Mapping'});
	    	if(taxCodeMappingIndex == -1 && $scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
	    		$scope.AccountingSetupModel.AccountingSetupStepsList.splice(3, 0, taxCoeMappingObj);
	    	}
	    	$scope.AccountingSetupModel.AccountsUploadSelectedMethod = $scope.AccountingSetupModel.accountingData.configuration.AlignmentMethod;
	    	$scope.AccountingSetupModel.selectedAccountingProvider = $scope.AccountingSetupModel.accountingData.configuration.AccountingProvider; 
	    	if($scope.AccountingSetupModel.accountingData.configuration.AlignmentMethod == null) {
	    		$scope.AccountingSetupModel.AccountsUploadSelectedMethod = 'Select One';
	    		$scope.AccountingSetupModel.accountingData.configuration.AlignmentMethod = 'Select One'; 
	    	}
	    	if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == null){
	    		$scope.AccountingSetupModel.accountingData.configuration.AccountingProvider = 'Select One';
	    		$scope.AccountingSetupModel.selectedAccountingProvider = 'Select One'; 
	    		$scope.AccountingSetupModel.selectedIntegrationName = '';
	    	} else {
	    		$scope.AccountingSetupModel.selectedIntegrationName = $scope.AccountingSetupModel.accountingData.configuration.AccountingProvider;
	    	}
	    	if($scope.AccountingSetupModel.ChangedAccountingProvide != null){
	    		$scope.AccountingSetupModel.selectedAccountingProvider = $scope.AccountingSetupModel.ChangedAccountingProvide; 
	    	}
	    	if($scope.AccountingSetupModel.ChangedAlignmentMethod != null){
	    		$scope.AccountingSetupModel.AccountsUploadSelectedMethod = $scope.AccountingSetupModel.ChangedAlignmentMethod;
	    	}
	    	$scope.AccountingSetupModel.LastSyncTime = '---';
	    	if($scope.AccountingSetupModel.accountingData.accountingList.length > 0){
	    		$scope.AccountingSetupModel.LastSyncTime = $scope.AccountingSetupModel.accountingData.accountingList[0].LastModifiedDate
	    	}
	    	$scope.AccountingSetupModel.setRightSidebarVariables();
	    	$scope.AccountingSetupModel.QBDataModel.ConsumerKey = $scope.AccountingSetupModel.accountingData.configuration.ConsumerKey;
	    	$scope.AccountingSetupModel.QBDataModel.ConsumerSecret = $scope.AccountingSetupModel.accountingData.configuration.ConsumerSecret;
	    	$scope.AccountingSetupModel.ChangedAccountingProvide = null;
	    	$scope.AccountingSetupModel.ChangedAlignmentMethod = null;
	    	$scope.AccountingSetupModel.isAlignmentMethodChanged = false;
	    	$scope.AccountingSetupModel.changeAccountingProvider = false;
	    	$scope.AccountingSetupModel.accountingData.configuration.IsConnectedError = false;
	    }
	    
	    $scope.AccountingSetupModel.addOpenClass = function(key) {  
	    	key = key.replace(/\s+/g, '');
	    	angular.element('#' + key + 'UL').addClass('keep_open');
	    	$scope.AccountingSetupModel.GeneralAccountsSearchText = '';
	    	setTimeout(function(){
	    		angular.element('#'+ key + 'Input').focus();
	    	}, 10);
	    }
	    
	    $scope.AccountingSetupModel.validateTaxRecOnSave = function () {
	    	 var isValidate = false;
	    	 if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online') {
	    		 for(var i=0;i<$scope.AccountingSetupModel.SalesTaxItemList.length;i++) {
	 	    	 	var salesTaxelementIdForTooltip = $scope.AccountingSetupModel.SalesTaxItemList[i].Name;
	 	    		var salesTaxelmIdtoolTip = $scope.AccountingSetupModel.generateId(salesTaxelementIdForTooltip,'Tooltip');
	 	    	 	if(!$scope.AccountingSetupModel.SalesTaxItemList[i].AccountingId) {
	 	    			angular.element('#' + salesTaxelmIdtoolTip).css('display', 'block');
	 	    			$scope.AccountingSetupModel.SalesTaxItemList[i].ErrorMessage = 'Quickbooks tax rate not mapped';
	 	    			isValidate = true;
	 	    	 	} else if($scope.AccountingSetupModel.SalesTaxItemList[i].AccountingId) {
	 	    	 		var taxRateIndex = _.findIndex($scope.AccountingSetupModel.taxRateList, {Id: $scope.AccountingSetupModel.SalesTaxItemList[i].AccountingId});
	 	    	 		if(taxRateIndex != -1) {
	 	    	 			var isValidateTaxRate = validateTaxPercentageMapping($scope.AccountingSetupModel.SalesTaxItemList[i].TaxRate,$scope.AccountingSetupModel.taxRateList[taxRateIndex].RateValue,salesTaxelementIdForTooltip);
	 			    		if(!isValidateTaxRate) {
	 				    		//$scope.AccountingSetupModel.isValidAllSalesTaxItemMapping = false;
	 				    		$scope.AccountingSetupModel.SalesTaxItemList[i].ErrorMessage =  $scope.AccountingSetupModel.selectedIntegrationName  + ' tax rate is different than the Blackpurl tax rate';
	 			    			isValidate = true;
	 			    		} else {
	 			    			angular.element('#' + salesTaxelmIdtoolTip).css('display', 'none');
	 			    		}
	 	    	 		}
	 	    	 	} else {
	 	    	 		angular.element('#' + salesTaxelmIdtoolTip).css('display', 'none');
	 	    	 	}
	 	    	 }
	    	 }
	    	 for(var i=0;i<$scope.AccountingSetupModel.selesTaxList.length;i++) {
		    	var elementIdForTooltip = $scope.AccountingSetupModel.selesTaxList[i].SalesTaxName;
	    		var elmIdtoolTip = $scope.AccountingSetupModel.generateId(elementIdForTooltip,'Tooltip');
	    		$scope.AccountingSetupModel.isValidAllSalesTaxMappingFromNext  = true;
		    	if(!$scope.AccountingSetupModel.selesTaxList[i].AccountingId) {
	    			angular.element('#' + elmIdtoolTip).css('display', 'block');
	    			$scope.AccountingSetupModel.selesTaxList[i].ErrorMessage = $scope.AccountingSetupModel.selectedIntegrationName  + ' tax code not mapped';
			    	isValidate = true;
			    } else if($scope.AccountingSetupModel.selesTaxList[i].AccountingId) {
			    	var salesTaxApplicableTaxRateAccIdSet = $scope.AccountingSetupModel.selesTaxList[i].ApplicableTaxRateAccIdSet;
	    	 		var qbTaxRecordList = _.filter($scope.AccountingSetupModel.QBTaxCodeList, function(qbTaxCode) { 
	    				if(qbTaxCode.Id == $scope.AccountingSetupModel.selesTaxList[i].AccountingId && salesTaxApplicableTaxRateAccIdSet.length == 0) {
	    					return true;
	    				} else if(qbTaxCode.Id == $scope.AccountingSetupModel.selesTaxList[i].AccountingId && salesTaxApplicableTaxRateAccIdSet.length != 0) {
	    					var unionSalesTaxAccountingIdSetAndApplicableTaxRates = _.union(salesTaxApplicableTaxRateAccIdSet, qbTaxCode.ApplicableTaxRates);
		        			var intersectionSalesTaxAccountingIdSetAndApplicableTaxRates =  _.intersection(salesTaxApplicableTaxRateAccIdSet,qbTaxCode.ApplicableTaxRates);
		        			var differenceSalesTaxAccountingIdSetAndApplicableTaxRates = _.difference(unionSalesTaxAccountingIdSetAndApplicableTaxRates,intersectionSalesTaxAccountingIdSetAndApplicableTaxRates)
		    				return (differenceSalesTaxAccountingIdSetAndApplicableTaxRates.length == 0);
	    				} else {
	    					return false;
	    				}
	    			});
	    	 		
	    	 		if(qbTaxRecordList.length > 0) {
			    		var isValidateTaxCode = validateTaxPercentageMapping($scope.AccountingSetupModel.selesTaxList[i].TaxRate,qbTaxRecordList[0].RateValue,elementIdForTooltip);
				    	if(!isValidateTaxCode) {
				    		$scope.AccountingSetupModel.isValidAllSalesTaxMapping  = false;
				    		$scope.AccountingSetupModel.selesTaxList[i].ErrorMessage = $scope.AccountingSetupModel.selectedIntegrationName  + ' combined rate  is different than the Blackpurl combined rate';
				    		isValidate = true;
				    	} 
			    		else if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online' && 
			    				!$scope.AccountingSetupModel.validateAllTaxRateMapping(qbTaxRecordList[0],$scope.AccountingSetupModel.selesTaxList[i].Id)) {
				    		$scope.AccountingSetupModel.isValidAllSalesTaxMapping  = false;
				    		angular.element('#' + elmIdtoolTip).css('display', 'block');
				    		$scope.AccountingSetupModel.selesTaxList[i].ErrorMessage = 'Mismatch between the tax rates assigned to the ' + $scope.AccountingSetupModel.selectedIntegrationName  + ' tax code and those assigned to the Blackpurl tax code';
				    		isValidate = true;
			   		 	} else {
			   		 		angular.element('#' + elmIdtoolTip).css('display', 'none');
			   		 	}
	    	 		}
			    } else {
			    	angular.element('#' + elmIdtoolTip).css('display', 'none');
			    }
			}
    		if(!$scope.AccountingSetupModel.accountingData.configuration.NonTaxableTaxCode) {
    			angular.element('#nonTaxableTaxCodeTooltip').css('display', 'block');
    			isValidate = true;
    		} else {
    			angular.element('#nonTaxableTaxCodeTooltip').css('display', 'none');
    		}
    		
    		if(!$scope.AccountingSetupModel.accountingData.configuration.NonTaxablePurchaseTaxCode) {
    			angular.element('#nonTaxablePurchaseTaxCodeTooltip').css('display', 'block');
    			isValidate = true;
    		} else {
    			angular.element('#nonTaxablePurchaseTaxCodeTooltip').css('display', 'none');
    		}
	    		
			if(isValidate || !$scope.AccountingSetupModel.isValidAllSalesTaxMapping || !$scope.AccountingSetupModel.isValidAllTaxRecMapping ||
	   			!$scope.AccountingSetupModel.isValidAllSalesTaxItemMapping) {
				return false;
			} else {
				$scope.AccountingSetupModel.isDisableTaxCodeMappingButton = false;
				return true
				
			}
	    }

	    $scope.AccountingSetupModel.saveSalesTaxItemMappingForQB = function(){
	    	$scope.AccountingSetupModel.isDisableTaxCodeMappingButton = true;
	    	if(!$scope.AccountingSetupModel.validateTaxRecOnSave()) {
	    		return;
	    	} else {
	    		$scope.AccountingSetupModel.isDisableTaxCodeMappingButton = false;
	    	}
	    	if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online') {
	    		AccountingService.saveSalesTaxItemMappingForQB(angular.toJson($scope.AccountingSetupModel.SalesTaxItemList)).then(function(responseResult) {
		            saveSalesTaxMappingForQB();
		        }, function(errorSearchResult) {
		            Notification.error(errorSearchResult);
		        });
	    	} else if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero') {
	    		saveSalesTaxMappingForQB();
	    	}
	    }

	    $scope.AccountingSetupModel.generateId = function(name,elementName) {
	    	name = name.replace(/\s+/g, '');
	    	if(elementName == 'Tooltip') {
	    		return name+'Tooltip';
	    	} else if(elementName == 'Input') {
	    		return name+'Input';
	    	} else if(elementName == 'UL') {
	    		return name+'UL';
	    	}else if(elementName == 'Id') {
	    		return name+'Id';
	    	}else if(elementName == '') {
	    		return name;
	    	}
	    	
	    }
	    function saveSalesTaxMappingForQB () {
	    	AccountingService.saveSalesTaxMappingForQB(angular.toJson($scope.AccountingSetupModel.selesTaxList)).then(function(responseResult) {
	        	saveNonTaxableCode();
	        }, function(errorSearchResult) {
	            Notification.error(errorSearchResult);
	        });
	    }

	    function saveNonTaxableCode() {
	    	AccountingService.saveNonTaxableTaxCodeMappingForQB(angular.toJson($scope.AccountingSetupModel.accountingData.configuration)).then(function(responseResult) {
	        $scope.AccountingSetupModel.isTaxCodeMappingStepCompleted();
	        $scope.AccountingSetupModel.NextAction(4);
	        Notification.success("Tax code Mapping Success"); 
	        }, function(errorSearchResult) {
	            Notification.error(errorSearchResult);
	        });
	    }
	    function validateTaxPercentageMapping (TaxRate,RateValue,elementId) {
	    	var elmId = $scope.AccountingSetupModel.generateId(elementId,'Tooltip');
	    	if(TaxRate != RateValue) {
			    angular.element('#' + elmId).css('display', 'block');
			    return false;
			}else {
				return true;
			}
	    }

	    $scope.AccountingSetupModel.syncTaxes = function() {
		   	$scope.AccountingSetupModel.disableSyncNowBtn = true;
		   	if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online') {
		   		AccountingService.syncTaxRatesWithQuickbooks().then(function(successfulResult) {
			           if(successfulResult == 'Success') {
			            AccountingService.syncTaxCodesWithQuickbooks().then(function(successfulResult) {
			   	   	$scope.AccountingSetupModel.disableSyncNowBtn = false;
			   	           if(successfulResult == 'Success') {
			   	           	$q.all([ 
			    	        
			    	        $scope.AccountingSetupModel.getQBTaxCodes(),
			    	        $scope.AccountingSetupModel.getSalesTaxList(),
			    	        $scope.AccountingSetupModel.getTaxRates(),
			    	        $scope.AccountingSetupModel.getSalesTaxItemList(),
			    	        $scope.AccountingSetupModel.getQBNonTaxableTaxCodes()
		    	        ]).then(function() {
		    	        validateAllTaxRecMappingOnLoad();
		    	        generateTaxRateIdToTaxCodeRateMap();
		    	        $scope.AccountingSetupModel.isTaxCodeMappingStepCompleted();
		    	        showTooltip('body');
		    	        Notification.success('Taxes synced successfully');
			   	           	$scope.AccountingSetupModel.disableSyncNowBtn = false;
		    	        	});
		   	           } else {
		   	           	Notification.error(successfulResult);
		   	           	$scope.AccountingSetupModel.disableSyncNowBtn = false;
		   	           }
			   	       }, function(errorSearchResult) {
			   	           $scope.AccountingSetupModel.disableSyncNowBtn = false;
			   	           Notification.error("Error in syncing Taxes");
			   	       });
			           } else {
			           	Notification.error(successfulResult);
			           }
			       }, function(errorSearchResult) {
			           $scope.AccountingSetupModel.disableSyncNowBtn = false;
			           Notification.error("Error in syncing Taxes");
			   	}); 
		   	} else {
		   		AccountingService.syncTaxCodes($scope.AccountingSetupModel.selectedIntegrationName).then(function(response) {
		   			$scope.AccountingSetupModel.disableSyncNowBtn = false;
		   			
		   			if(response == 'success') {
		   	           	$q.all([ 
		    	        
			    	        $scope.AccountingSetupModel.getQBTaxCodes(),
			    	        $scope.AccountingSetupModel.getSalesTaxList(),
			    	        $scope.AccountingSetupModel.getQBNonTaxableTaxCodes()
		    	        ]).then(function() {
			    	        generateTaxCodeLabelList();
			    	        $scope.AccountingSetupModel.isTaxCodeMappingStepCompleted();
			    	        showTooltip('body');
			    	        Notification.success('Taxes synced successfully');
				   	           	$scope.AccountingSetupModel.disableSyncNowBtn = false;
		    	        	});
		   	           } else {
			   	           	Notification.error(response);
			   	           	$scope.AccountingSetupModel.disableSyncNowBtn = false;
		   	           }
		   	       }, function(errorSearchResult) {
		   	           $scope.AccountingSetupModel.disableSyncNowBtn = false;
		   	           Notification.error("Error in syncing Taxes");
		   	       });
		   	}
		   	
   		}
        
		function generateTaxCodeLabelList() {
			if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Xero') {
				return;
			}
			for(var i=0;i<$scope.AccountingSetupModel.QBTaxCodeList.length;i++) {
	    		$scope.AccountingSetupModel.QBTaxCodeList[i].taxCodeLabel = '';
	    		for(var j=0;j<$scope.AccountingSetupModel.QBTaxCodeList.length;j++) {
		    		$scope.AccountingSetupModel.QBTaxCodeList[i].taxCodeLabel = $scope.AccountingSetupModel.QBTaxCodeList[i].Id + ' - ' + $scope.AccountingSetupModel.QBTaxCodeList[i].RateValue + '%'; 
	    		}
	    	}
		}
	
        function validateAllTaxRecMappingOnLoad() {
   			$scope.AccountingSetupModel.isValidAllTaxRecMapping = false;
   			$scope.AccountingSetupModel.isValidAllSalesTaxItemMapping = false;
   			$scope.AccountingSetupModel.isValidAllSalesTaxMapping = false;
   			var invalidSalesTaxItemList = _.filter($scope.AccountingSetupModel.SalesTaxItemList, function(salesTaxItem){ return $scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Xero' && !salesTaxItem.AccountingId ; });
   			if(invalidSalesTaxItemList.length == 0) {
   				$scope.AccountingSetupModel.isValidAllSalesTaxItemMapping = true;
   				$scope.AccountingSetupModel.isValidAllSalesTaxMappingFromNext = false;
   			} 
   			var invlaidSalesTaxList = _.filter($scope.AccountingSetupModel.selesTaxList, function(selesTaxRec){ 
   				return !selesTaxRec.AccountingId; });
   			if(invlaidSalesTaxList.length == 0) {
   				$scope.AccountingSetupModel.isValidAllSalesTaxMapping = true;
   			}
   			if((invalidSalesTaxItemList.length === 0) && (invlaidSalesTaxList.length === 0)) {
   				$scope.AccountingSetupModel.isValidAllTaxRecMapping = true;
   			}
   		}
	    $scope.AccountingSetupModel.validateAllTaxRateMapping = function (taxCodeRec,salesTaxId) {
	    	if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero') {
	    		return true;
	    	}
	    		if($scope.AccountingSetupModel.isValidAllSalesTaxItemMapping || $scope.AccountingSetupModel.isValidAllSalesTaxMappingFromNext){
	    			var salesTaxIdToTaxRateAccountingIdsMap = {};
	    			for(var i=0;i<$scope.AccountingSetupModel.selesTaxList.length;i++) {
	    				var taxRateAccountingIdsList = [];
	    				for(var j =0;j<$scope.AccountingSetupModel.selesTaxList[i].salesTaxItemList.length;j++) {
	    					var salesTaxItemindex =  _.findIndex($scope.AccountingSetupModel.SalesTaxItemList, {Id: $scope.AccountingSetupModel.selesTaxList[i].salesTaxItemList[j].Id});
	    						$scope.AccountingSetupModel.selesTaxList[i].salesTaxItemList[j].AccountingId = $scope.AccountingSetupModel.SalesTaxItemList[salesTaxItemindex].AccountingId;
	    						taxRateAccountingIdsList.push(parseInt($scope.AccountingSetupModel.selesTaxList[i].salesTaxItemList[j].AccountingId));
	    				}
	    				salesTaxIdToTaxRateAccountingIdsMap[$scope.AccountingSetupModel.selesTaxList[i].Id] = taxRateAccountingIdsList;
	    			}
	    			var TaxRateAccountingIdsSet = salesTaxIdToTaxRateAccountingIdsMap[salesTaxId];
	    			var ApplicableTaxRates = taxCodeRec.ApplicableTaxRates;
	    			var UnionTaxRateAccountingIdsSetAndApplicableTaxRates = _.union(TaxRateAccountingIdsSet,ApplicableTaxRates);
	    			var intersectionTaxRateAccountingIdsSetAndApplicableTaxRates =  _.intersection(TaxRateAccountingIdsSet,ApplicableTaxRates);
	    			var differenceTaxRateAccountingIdsSetAndApplicableTaxRates = _.difference(UnionTaxRateAccountingIdsSetAndApplicableTaxRates,intersectionTaxRateAccountingIdsSetAndApplicableTaxRates)
	    			if(differenceTaxRateAccountingIdsSetAndApplicableTaxRates.length != 0) {
						var salesTaxindex =  _.findIndex($scope.AccountingSetupModel.selesTaxList, {Id: salesTaxId});
					   	if(salesTaxindex != -1 && $scope.AccountingSetupModel.selesTaxList[salesTaxindex].salesTaxItemList.length == 0 &&  $scope.AccountingSetupModel.selesTaxList[salesTaxindex].TaxRate == 0) {
					   		return true;
					   	} else {
					   		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = false;
	    					$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = true;
	    					$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = 'Please map your sales taxes'
					   		return false;
					   	}
	    				
	    			} else {
	    				return true;
	    			}
	    		} else {
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = false;
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = true;
	    			$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = 'Please map your sales taxes'
	    			return false;
	    		}

	    }

	    function openTaxCodeMappingPopup() {
	    	 setTimeout(function() {
               angular.element('#tax-code-mapping-modal-window').modal({
                   backdrop: 'static',
                   keyboard: false
               });
           });
	    }

	    angular.element(document).on("click", "#tax-code-mapping-modal-window .modal-backdrop", function() {
            $scope.AccountingSetupModel.taxCodeMappingclosePopup();
        });
	    $scope.AccountingSetupModel.taxCodeMappingclosePopup = function() {
	    	angular.element('#tax-code-mapping-modal-window').modal('hide');
            angular.element("body").removeClass("modal-open");
	    }
	    function validateOnLoadStepComp() {
            for(var i=0;i<$scope.AccountingSetupModel.selesTaxList.length;i++) {
            	if(!$scope.AccountingSetupModel.selesTaxList[i].AccountingId) {
            		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = false;
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = true;
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = 'Please map your sales taxes'
		    		return;
            	}
            }
            for(var i=0;i<$scope.AccountingSetupModel.SalesTaxItemList.length;i++) {
            	if(!$scope.AccountingSetupModel.SalesTaxItemList[i].AccountingId) {
            		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = false;
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = true;
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = 'Please map your sales taxes'
		    		return;
            	}
            }
        }
	    $scope.AccountingSetupModel.SelectTaxRec = function(event,index,taxRec,isSalesTaxItem,elementId) {
	    	var elmId = $scope.AccountingSetupModel.generateId(elementId,'Tooltip');
	    	if(isSalesTaxItem) {
			    $scope.AccountingSetupModel.SalesTaxItemList[index].AccountingId = taxRec.Id;
	    		for(var i=0;i<$scope.AccountingSetupModel.selesTaxList.length;i++) {
	    			var salesTaxItemindex =  _.findIndex($scope.AccountingSetupModel.selesTaxList[i].salesTaxItemList, {Id: $scope.AccountingSetupModel.SalesTaxItemList[index].Id});
	    			if(salesTaxItemindex != -1) {
	    				$scope.AccountingSetupModel.selesTaxList[i].salesTaxItemList[salesTaxItemindex].AccountingId = $scope.AccountingSetupModel.SalesTaxItemList[index].AccountingId;
	    			}
	    		}
			    var isValidate = validateTaxPercentageMapping($scope.AccountingSetupModel.SalesTaxItemList[index].TaxRate,taxRec.RateValue,elementId);
		    	if(!isValidate) {
		    		$scope.AccountingSetupModel.isValidAllSalesTaxItemMapping = false;
		    		$scope.AccountingSetupModel.SalesTaxItemList[index].ErrorMessage = $scope.AccountingSetupModel.selectedIntegrationName  + ' tax rate is different than the Blackpurl tax rate';
		    		$scope.AccountingSetupModel.TaxModalWindowMappingText = 'The rate assigned to the ' + $scope.AccountingSetupModel.selectedIntegrationName  + 'tax rate you have mapped is different than the rate assigned to the Blackpurl tax rate';
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = false;
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = true;
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = 'Please map your sales taxes'
		    		openTaxCodeMappingPopup();
		    		
		    	} else {
		    		angular.element('#' + elmId).css('display', 'none');
		    		validateAllTaxRecMappingOnLoad();
		    	}
	    		
	    	} else {
	    		$scope.AccountingSetupModel.selesTaxList[index].AccountingId = taxRec.Id;
				$scope.AccountingSetupModel.selesTaxList[index].ApplicableTaxRateAccIdSet = taxRec.ApplicableTaxRates;
				var isValidate = validateTaxPercentageMapping($scope.AccountingSetupModel.selesTaxList[index].TaxRate,taxRec.RateValue,elementId);

		    	if(!isValidate) {
		    		$scope.AccountingSetupModel.isValidAllSalesTaxMapping  = false;
		    		$scope.AccountingSetupModel.selesTaxList[index].ErrorMessage = $scope.AccountingSetupModel.selectedIntegrationName  + 'combined rate  is different than the Blackpurl combined rate';
		    		$scope.AccountingSetupModel.TaxModalWindowMappingText = 'The combined rate for the  ' + $scope.AccountingSetupModel.selectedIntegrationName  + ' tax code you have mapped is different than the combined rate for the Blackpurl tax code';
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = 'Please map your sales taxes'
		    		openTaxCodeMappingPopup();
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = true;
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = false;
		    	} else if(!$scope.AccountingSetupModel.validateAllTaxRateMapping(taxRec,$scope.AccountingSetupModel.selesTaxList[index].Id)) {
		    		$scope.AccountingSetupModel.isValidAllSalesTaxMapping  = false;
		    		angular.element('#' + elmId).css('display', 'block');
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = false;
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = true;
		    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = 'Please map your sales taxes'
		    		$scope.AccountingSetupModel.selesTaxList[index].ErrorMessage = 'Mismatch between the tax rates assigned to the  ' + $scope.AccountingSetupModel.selectedIntegrationName  + ' tax code and those assigned to the Blackpurl tax code';
		    		
		    	} else {
		    		angular.element('#' + elmId).css('display', 'none');
		    		validateAllTaxRecMappingOnLoad();
		    	}
	    		
	    	}
	    	$scope.AccountingSetupModel.getTaxCodeMappingNameFromKey(index,isSalesTaxItem);
	    	if(!$scope.AccountingSetupModel.validateTaxRecOnSave()) {
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = true;
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = false
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].ErrorMessage = 'Please map your sales taxes'
	    	} else {
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isError = false;
	    		$scope.AccountingSetupModel.AccountingSetupStepsList[3].isCompleted = true;
	    	}
	    }

	    
	    $scope.AccountingSetupModel.SelectAccount = function(event, key, accountValue) {
	    	if(event != undefined){
	    		event.preventDefault();
	    	}
			$scope.AccountingSetupModel.isAccountingSetupDataSaved = false;
			if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online') {
				$scope.AccountingSetupModel.accountingData.defaultAccounts[key] = accountValue.AccountingId;
			} else if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero') {
				$scope.AccountingSetupModel.accountingData.defaultAccounts[key] = accountValue.AccountNumber;
			}
	    	angular.element('#' + key + 'UL').removeClass('keep_open'); 
	    	$scope.AccountingSetupModel.GeneralAccountsSearchText = ''; 
	    }
	    
	    $scope.AccountingSetupModel.SelectNonTaxableRec = function(event,nonTaxableCodeRec, type) {
	    		if(type == 'Sales') {
	    			$scope.AccountingSetupModel.accountingData.configuration.NonTaxableTaxCode = nonTaxableCodeRec.Id;
	    		} else {
	    			$scope.AccountingSetupModel.accountingData.configuration.NonTaxablePurchaseTaxCode = nonTaxableCodeRec.Id;
	    		}
	    }

	    $scope.AccountingSetupModel.getTaxCodeMappingNameFromKey = function(index,isSalesTaxItem,isNonTaxableTaxCode, nonTaxableCodeType) {
	    	if(isSalesTaxItem) {
	    		var accountingId = $scope.AccountingSetupModel.SalesTaxItemList[index].AccountingId;
	    		if(accountingId) {
	    			var taxRateIndex = _.findIndex($scope.AccountingSetupModel.taxRateList, {Id: accountingId});
			    	if(taxRateIndex != -1){
			    		var taxNameAndRate = $scope.AccountingSetupModel.taxRateList[taxRateIndex].Name +  " (" + $scope.AccountingSetupModel.taxRateList[taxRateIndex].RateValue + "%)";
			    		return taxNameAndRate;
			    	}
	    		}
	    	} else if(isNonTaxableTaxCode) {
	    		var nonTaxableCodeIndex = -1;
	    		var nameToBeReturned = 'Please Select';
	    		if(nonTaxableCodeType == 'Sales' ) {
	    			nonTaxableCodeIndex = _.findIndex($scope.AccountingSetupModel.nonTaxableTaxCodeList, {Id: $scope.AccountingSetupModel.accountingData.configuration.NonTaxableTaxCode});
	    		} else {
	    			nonTaxableCodeIndex =  _.findIndex($scope.AccountingSetupModel.nonTaxableTaxCodeList, {Id: $scope.AccountingSetupModel.accountingData.configuration.NonTaxablePurchaseTaxCode});
	    		}
	    		if(nonTaxableCodeIndex != -1) {
					nameToBeReturned = $scope.AccountingSetupModel.nonTaxableTaxCodeList[nonTaxableCodeIndex].Name +  " (" + $scope.AccountingSetupModel.nonTaxableTaxCodeList[nonTaxableCodeIndex].RateValue + "%)";
				}
	    		return nameToBeReturned;
	    	} else {
	    		var accountingId = $scope.AccountingSetupModel.selesTaxList[index].AccountingId;
	    		var salesTaxApplicableTaxRateAccIdSet = $scope.AccountingSetupModel.selesTaxList[index].ApplicableTaxRateAccIdSet;
	    		if(accountingId) {
	    			var qbTaxRecordList = _.filter($scope.AccountingSetupModel.QBTaxCodeList, function(qbTaxCode) { 
	    				if(qbTaxCode.Id == accountingId && salesTaxApplicableTaxRateAccIdSet.length == 0) {
	    					return true;
	    				} else if(qbTaxCode.Id == accountingId && salesTaxApplicableTaxRateAccIdSet.length != 0) {
	    					var unionSalesTaxAccountingIdSetAndApplicableTaxRates = _.union(salesTaxApplicableTaxRateAccIdSet, qbTaxCode.ApplicableTaxRates);
		        			var intersectionSalesTaxAccountingIdSetAndApplicableTaxRates =  _.intersection(salesTaxApplicableTaxRateAccIdSet,qbTaxCode.ApplicableTaxRates);
		        			var differenceSalesTaxAccountingIdSetAndApplicableTaxRates = _.difference(unionSalesTaxAccountingIdSetAndApplicableTaxRates,intersectionSalesTaxAccountingIdSetAndApplicableTaxRates)
		    				return (differenceSalesTaxAccountingIdSetAndApplicableTaxRates.length == 0);
	    				} else {
	    					return false;
	    				}
	    			});
	    			if(qbTaxRecordList.length > 0) {
	    				var codeNameAndRate = qbTaxRecordList[0].Name + ' — ' + qbTaxRecordList[0].taxCodeLabel;
			    		return codeNameAndRate;
	    			}
	    		}
	    	}
	    	return 'Please Select';
	    }
	    $scope.AccountingSetupModel.getAccountNameFromKey = function(key){
	    	var accountingId = $scope.AccountingSetupModel.accountingData.defaultAccounts[key];
	    	return $scope.AccountingSetupModel.getAccountNameFromAccountId(accountingId);
	    }
	    
	    $scope.AccountingSetupModel.getAccountNameFromAccountId = function(accountId){
	    	var index = -1;
	    	if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online') {
	    		index = _.findIndex($scope.AccountingSetupModel.accountingData.accountingList, {AccountingId: accountId});
	    	} else if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero') {
	    		index = _.findIndex($scope.AccountingSetupModel.accountingData.accountingList, {AccountNumber: accountId});
	    	}
	    	
	    	if(index != -1){
	    		var accountselectedName = ''
	    		if($scope.AccountingSetupModel.accountingData.accountingList[index].AccountNumber) {
	    			accountselectedName = $scope.AccountingSetupModel.accountingData.accountingList[index].AccountNumber + ' - ';
	    		}
	    		accountselectedName += $scope.AccountingSetupModel.accountingData.accountingList[index].AccountName;
	    		return accountselectedName;
	    	}
	    	return 'Select a GL Account';
	    }
	    
	    $scope.AccountingSetupModel.saveControlAccounts = function() {
	    	var DefaultAccountsJSON = JSON.stringify($scope.AccountingSetupModel.accountingData.defaultAccounts);
	        AccountingService.saveControlAccounts(DefaultAccountsJSON).then(function(responseResult) {
	           if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
					$scope.AccountingSetupModel.NextAction(5);
	           } else {
	           		$scope.AccountingSetupModel.NextAction(4);
	           }
	           
	            $scope.AccountingSetupModel.setData(responseResult);
				$scope.AccountingSetupModel.isAccountingSetupDataSaved = true;
	        }, function(errorSearchResult) {
	            Notification.error("Error in saving Control Accounts");
	        });
	    }
	    
	    $scope.AccountingSetupModel.saveDefaultAccounts = function() {
	    	var DefaultAccountsJSON = JSON.stringify($scope.AccountingSetupModel.accountingData.defaultAccounts);
	        AccountingService.saveDefaultAccounts(DefaultAccountsJSON).then(function(responseResult) {
	           if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
					$scope.AccountingSetupModel.NextAction(6);
	           } else {
	           		$scope.AccountingSetupModel.NextAction(5);
	           }
	            $scope.AccountingSetupModel.setData(responseResult);
				$scope.AccountingSetupModel.isAccountingSetupDataSaved = true;
	        }, function(errorSearchResult) {
	            Notification.error("Error in saving Default Accounts");
	        });
	    }
	    $scope.AccountingSetupModel.goToCatrgory = function () {
	    	 if($scope.AccountingSetupModel.accountingData.configuration.IsTaxCodesEnabled) {
					$scope.AccountingSetupModel.NextAction(7);
	           } else {
	           		$scope.AccountingSetupModel.NextAction(6);
	           }
	    }
	    $scope.AccountingSetupModel.openChangeAccountingProviderPopup = function() {
	    	$scope.AccountingSetupModel.changeAccountingProvider = false;
	        angular.element('#ChangeAccountingProviderPopup').modal({
	               backdrop: 'static',
	               keyboard: false 
	        });
	    }
	    
	    $scope.AccountingSetupModel.closeChangeAccountingProviderPopup = function() {
	        angular.element('#ChangeAccountingProviderPopup').modal('hide');
	    }
	    
	    $scope.AccountingSetupModel.ChangeAccountingProviderConfirmAction = function() {
	    	$scope.AccountingSetupModel.changeAccountingProvider = true;
	    	if($scope.AccountingSetupModel.removeAccountingConnectionText == 'remove') {
	    		$scope.AccountingSetupModel.ChangedAccountingProvide = 'Select One'; 
	    	}
	       	if($scope.AccountingSetupModel.selectedProviderValue != 'Quickbooks Online' && $scope.AccountingSetupModel.selectedProviderValue != 'Xero')	{
	       		$scope.AccountingSetupModel.isAccountingSetupDataSaved  = false; 
	       	}
	        $scope.AccountingSetupModel.removeAccountingData();
	        $scope.AccountingSetupModel.closeChangeAccountingProviderPopup();
	    }
	    
	    $scope.AccountingSetupModel.ChangeAccountingProviderCancelAction = function() {
	    	$scope.AccountingSetupModel.changeAccountingProvider = false;
	        $scope.AccountingSetupModel.closeChangeAccountingProviderPopup();
	    }
	    
	    /*$scope.AccountingSetupModel.RemoveQBConnection = function() {
	    	$scope.AccountingSetupModel.removeAccountingConnectionText = 'remove';
	    	$scope.AccountingSetupModel.openChangeAccountingProviderPopup();
	    }*/
	    
	    $scope.AccountingSetupModel.RemoveConnection = function() {
	    	$scope.AccountingSetupModel.removeAccountingConnectionText = 'remove';
	    	$scope.AccountingSetupModel.openChangeAccountingProviderPopup();
	    }
	    
	    $scope.AccountingSetupModel.removeAccountingData = function() {
	        AccountingService.removeAccountingData().then(function(responseResult) {
	            $scope.AccountingSetupModel.setData(responseResult);
	            $scope.AccountingSetupModel.getCategories(); 
	            Notification.success('Accounting Connection removed successfully');
	        }, function(errorSearchResult) {
	            Notification.error("Error in removing Accounting Connection");
	        });
	    }
	    
	    $scope.AccountingSetupModel.enableAccountingChevron = function(AccountingSetupStep) {
	    	if($scope.AccountingSetupModel.accountingData != null && $scope.AccountingSetupModel.accountingData != undefined &&
	    	$scope.AccountingSetupModel.accountingData != '') {
	    		if(AccountingSetupStep == 'Categories') {
	            	return true;
	            } else if((($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online' && 
	    			$scope.AccountingSetupModel.accountingData.configuration.IsConnected) ||
	    			$scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Select One') && AccountingSetupStep == 'Chart of Accounts') {
					return true;
	            } else if(($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online' && 
	            		$scope.AccountingSetupModel.accountingData.configuration.IsConnected && 
	            		$scope.AccountingSetupModel.accountingData.accountingList.length > 0) ||
	            		($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Select One' && 
	            		$scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Quickbooks Online' &&
	            		$scope.AccountingSetupModel.accountingData.configuration.AlignmentMethod != 'Select One')) { 
	            	return true;
	            }
	    	}
	    	return false;
	        
	    }
	    
	    $scope.AccountingSetupModel.AccountsUploadSelectedMethod = 'Select One';
	    $scope.AccountingSetupModel.isAlignmentMethodChanged = false;
	    $scope.AccountingSetupModel.ChangedAlignmentMethod = null;
	    $scope.AccountingSetupModel.AccountsUploadMethod = function(selectedMethod) {
	    	if(selectedMethod != $scope.AccountingSetupModel.AccountsUploadSelectedMethod) {
	    		$scope.AccountingSetupModel.isAlignmentMethodChanged = true;
	    	}
	    	if(selectedMethod != 'Select One' && 
	    		selectedMethod != $scope.AccountingSetupModel.accountingData.configuration.AlignmentMethod &&
	    		$scope.AccountingSetupModel.accountingData.configuration.AlignmentMethod != 'Select One') { 
	        	$scope.AccountingSetupModel.changeAlignmentMethodHeaderText = 'Change Alignment Method'; 
	        	$scope.AccountingSetupModel.openChangeAlignmentMethodPopup();
	        	$scope.AccountingSetupModel.ChangedAlignmentMethod = selectedMethod;
	        }
	        if($scope.AccountingSetupModel.isAlignmentMethodChanged) {
				$scope.AccountingSetupModel.isAccountingSetupDataSaved = false; 
	        	$scope.AccountingSetupModel.AccountsUploadSelectedMethod = selectedMethod;	
	        }
	    }
	    
	    $scope.AccountingSetupModel.openChangeAlignmentMethodPopup = function() {
	    	$scope.AccountingSetupModel.isAlignmentMethodChanged = false;
	        angular.element('#ChangeAlignmentMethodPopup').modal({
	               backdrop: 'static',
	               keyboard: false 
	        });
	    }
	    
	    $scope.AccountingSetupModel.closeChangeAlignmentMethodPopup = function() {
	        angular.element('#ChangeAlignmentMethodPopup').modal('hide');
	    }
	    
	    $scope.AccountingSetupModel.ChangeAlignmentMethodConfirmAction = function() {
	    	$scope.AccountingSetupModel.isAlignmentMethodChanged = true;
			$scope.AccountingSetupModel.isAccountingSetupDataSaved = false; 
	        $scope.AccountingSetupModel.removeGeneralAccounts();
	        $scope.AccountingSetupModel.closeChangeAlignmentMethodPopup();
	    }
	    
	    $scope.AccountingSetupModel.ChangeAlignmentMethodCancelAction = function() {
	    	$scope.AccountingSetupModel.isAlignmentMethodChanged = false;
	        $scope.AccountingSetupModel.closeChangeAlignmentMethodPopup();
	    }
	    
	    $scope.AccountingSetupModel.saveAccountingAlignmentMethod = function(MethodName) {
	        AccountingService.saveAccountingAlignmentMethod(MethodName).then(function(responseResult) {
	            $scope.AccountingSetupModel.setData(responseResult);
	            $scope.AccountingSetupModel.isAccountingSetupDataSaved = true; 
				$scope.AccountingSetupModel.NextAction(3); 
	        }, function(errorSearchResult) {
	            Notification.error("Error in saving Alignment Method Name");
	        });
	    }
	    
	    $scope.AccountingSetupModel.RemoveChartOfAccounts = function() {
	    	$scope.AccountingSetupModel.changeAlignmentMethodHeaderText = 'Remove Chart of Accounts'; 
	    	$scope.AccountingSetupModel.openChangeAlignmentMethodPopup();
	    }
	    
	    $scope.AccountingSetupModel.showTooltip = function(type) {
	    	type = type.replace(/\s+/g, '')
	    	angular.element('#' + type + 'Tooltip').css('display', 'block');
	    }
	    
	    $scope.AccountingSetupModel.hideTooltip = function(type) {
	    	type = type.replace(/\s+/g, '')
	    	angular.element('#' + type + 'Tooltip').css('display', 'none');
	    }
	    
	    $scope.AccountingSetupModel.removeGeneralAccounts = function() {
	        AccountingService.removeGeneralAccounts().then(function(responseResult) {
	            $scope.AccountingSetupModel.setData(responseResult);
	            $scope.AccountingSetupModel.getCategories(); 
	            Notification.success('General Accounts removed successfully');
	        }, function(errorSearchResult) {
	            Notification.error("Error in removing General Accounts");
	        });
	    }
	    
	    $scope.AccountingSetupModel.saveAccountingProviderName = function(ProviderName) {
	        AccountingService.saveAccountingProviderName(ProviderName).then(function(responseResult) {
	            $scope.AccountingSetupModel.setData(responseResult);
	            $scope.AccountingSetupModel.isAccountingSetupDataSaved = true; 
	            $scope.AccountingSetupModel.selectedProviderValue = '' 
	            $scope.AccountingSetupModel.NextAction(2);
	        }, function(errorSearchResult) {
	            Notification.error("Error in saving Accounting Provider");
	        });
	    }
	    
	    $scope.AccountingSetupModel.disableChartOfAccountsNextBtn = function() {
	    	if($scope.AccountingSetupModel.accountingData != null &&
	    		$scope.AccountingSetupModel.accountingData != undefined &&
	    		$scope.AccountingSetupModel.accountingData != '' &&
	    		(($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online' ||
	    		$scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero') && 
	       		$scope.AccountingSetupModel.accountingData.configuration.IsConnected && 
	       		$scope.AccountingSetupModel.accountingData.accountingList.length > 0) ||
	       		($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Select One' &&
	       		$scope.AccountingSetupModel.AccountsUploadSelectedMethod == 'User supplied list' &&
	       		$scope.AccountingSetupModel.accountingData.accountingList.length > 0) ||
	       		($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider != 'Select One' && 
	       		$scope.AccountingSetupModel.AccountsUploadSelectedMethod == 'None')) {
	    		return false;
    	}
	    	return true;
	    }
	    
	    $scope.AccountingSetupModel.disableControlAccountsNextBtn = function() {
	    	if($scope.AccountingSetupModel.accountingData == null || 
	    		$scope.AccountingSetupModel.accountingData == undefined ||
	    		$scope.AccountingSetupModel.accountingData == '' ||
	    		$scope.AccountingSetupModel.accountingData.defaultAccounts['UndepositedFunds'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['UndepositedFunds'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['UndepositedFunds'] == undefined ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['CustomerDeposits'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['CustomerDeposits'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['CustomerDeposits'] == undefined ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['APInventoryAccrual'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['APInventoryAccrual'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['APInventoryAccrual'] == undefined ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['InventoryAdjustments'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['InventoryAdjustments'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['InventoryAdjustments'] == undefined ||
                $scope.AccountingSetupModel.accountingData.defaultAccounts['CashRounding'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['CashRounding'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['CashRounding'] == undefined ||
                $scope.AccountingSetupModel.accountingData.defaultAccounts['StoreCreditAccural'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['StoreCreditAccural'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['StoreCreditAccural'] == undefined ||
                $scope.AccountingSetupModel.accountingData.defaultAccounts['StoreCreditExpense'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['StoreCreditExpense'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['StoreCreditExpense'] == undefined ||

	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['ClaimDeductibleClearing'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['ClaimDeductibleClearing'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['ClaimDeductibleClearing'] == undefined ||
                
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['StampDutyClearing'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['StampDutyClearing'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['StampDutyClearing'] == undefined ||

	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['StockedTradeClearing'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['StockedTradeClearing'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['StockedTradeClearing'] == undefined ||
	   			
	   			!$scope.AccountingSetupModel.accountingData.defaultAccounts['LienPayoutClearing'] ||

                $scope.AccountingSetupModel.accountingData.defaultAccounts['CashSaleCustomer'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['CashSaleCustomer'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['CashSaleCustomer'] == undefined ||
                $scope.AccountingSetupModel.accountingData.defaultAccounts['InternalServiceCustomer'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['InternalServiceCustomer'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['InternalServiceCustomer'] == undefined ||
	   			
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['UndepositedDirectDeposit'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['UndepositedDirectDeposit'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['UndepositedDirectDeposit'] == undefined ||
	   			
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['UndepositedFinancing'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['UndepositedFinancing'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['UndepositedFinancing'] == undefined ||

	   			!($scope.AccountingSetupModel.accountingData.defaultAccounts['DealOptionClearing'])) {
	    		
	    		return true;
	    	}
			if($rootScope.CompanyLocale == 'Australia' && isBlankValue($scope.AccountingSetupModel.accountingData.defaultAccounts['StampDutyAccrual'])) {
				return true;
			}
	    	return false;
	    }
	    
	    $scope.AccountingSetupModel.disableDefaultAccountsNextBtn = function() {
	    	if($scope.AccountingSetupModel.accountingData == null || 
	    		$scope.AccountingSetupModel.accountingData == undefined ||
	    		$scope.AccountingSetupModel.accountingData == '' ||
	    		$scope.AccountingSetupModel.accountingData.defaultAccounts['SalesIncome'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['SalesIncome'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['SalesIncome'] == undefined ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['CostofGoodsSold'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['CostofGoodsSold'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['CostofGoodsSold'] == undefined ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['Inventory'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['Inventory'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['Inventory'] == undefined ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['MiscellaneousIncome'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['MiscellaneousIncome'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['MiscellaneousIncome'] == undefined ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['SalesTax'] == null || 
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['SalesTax'] == '' ||
	   			$scope.AccountingSetupModel.accountingData.defaultAccounts['SalesTax'] == undefined) {
				return true;
	    	}
	    	return false;
	    }
	    
	    $scope.AccountingSetupModel.getRightPanelState = function() {
	    	
	    }
		$scope.AccountingSetupModel.UploadChartOfAccount = function(){
			 AccountingService.saveAccountingAlignmentMethod($scope.AccountingSetupModel.AccountsUploadSelectedMethod).then(function(responseResult) {
	            $scope.AccountingSetupModel.isAccountingSetupDataSaved = true; 
	            loadState($state, 'COAImport');
	        }, function(errorSearchResult) {
	         $scope.AccountingSetupModel.isAccountingSetupDataSaved = true; 
	            Notification.error("Error in saving Alignment Method Name");
	        });
								
		}
	    $scope.AccountingSetupModel.checkCategory = function(CategoryJSON) { 
	        AccountingService.checkCategory(CategoryJSON.Id).then(function(responseResult) {
	            if(responseResult.responseStatus == 'Success') {
	            	$scope.AccountingSetupModel.openRemoveCategoryPopup(CategoryJSON);
	            } else if(responseResult.responseStatus == 'Error') {
	            	$scope.AccountingSetupModel.removeCategoryInUseErrorMsg = responseResult.response;
	            	$scope.AccountingSetupModel.openRemoveCategoryInUsePopup(CategoryJSON);
	            }

	        }, function(errorSearchResult) {

	        });
	    }

	    $scope.AccountingSetupModel.finishAccountingSetup = function() { 
	    	loadState($state, 'UserSetting', {Id: 'Home'});
	    }

	    $scope.AccountingSetupModel.NextActionOnBack = function()	{
	    	$scope.AccountingSetupModel.isBackBtnClicked = true;
	    	if(!$scope.AccountingSetupModel.isAccountingSetupDataSaved)	{
	    		angular.element('#NavigateConfirmBox').modal({ backdrop: 'static', keyboard: false });
	    		return;
	    	}	else	{
	    			loadState($state, 'UserSetting', {Id: 'Home'});
	    	}
	    }
	    
	    $scope.AccountingSetupModel.exitActionFromCOAPage = function()	{
	    	if($stateParams.myParams != undefined) {
	    		var sectionName = $stateParams.myParams.sectionName;
	    	}
			if(sectionName == 'COA' && $scope.AccountingSetupModel.enableAccountingChevron('Chart of Accounts')) {
	        	$scope.AccountingSetupModel.selectedAccountingChevronIndex = 2;
	        	$scope.AccountingSetupModel.displaySection = 'Chart of Accounts';
        	}
	    }

	    function getUrlVars() {
	        var vars = {};
	        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value) {
	            vars[key] = value;
	        });
	        return vars;
	    }
	    
	    $scope.AccountingSetupModel.ConfirmBox_Response = function(response){
	    	if(response){
	    		loadState($state, 'UserSetting', {Id: 'Home'});
	    	}
	    	if(!response)	{
	    		$scope.AccountingSetupModel.isBackBtnClicked = false; 
	    	}
	    	angular.element('#NavigateConfirmBox').modal('hide');
	    }
	    $(window).bind("beforeunload", function() {
		    if (!$scope.AccountingSetupModel.isAccountingSetupDataSaved && !$scope.AccountingSetupModel.isBackBtnClicked) {
		        return "Unsaved information will be lost if you continue to navigate away from the Accounting Setup screen.";
		    } else	{
		    	$scope.AccountingSetupModel.isBackBtnClicked = false;
		    }
		});
		
    	$scope.AccountingSetupModel.setFocus = function(id) {
	    	setTimeout(function(){
	    		angular.element("#"+ id).focus();	
	    	},100);
	    }  
    
	    $scope.AccountingSetupModel.keyPressNavigationOnDropdownElements = function(event, dropdownDivId, templateName, dropdownList) {
            var keyCode = event.which ? event.which : event.keyCode;
            var tempList = angular.copy(dropdownList);
            var dropDownDivId = '#' + dropdownDivId;
            var idSubStr = '';
            var totalRecordsToTraverse = 0;
            if (tempList) {
                totalRecordsToTraverse += tempList.length;
            }
            if(templateName == 'serviceJobProvider') {
            	tempList.sort(function(a, b){
                    if(a.Name < b.Name) return -1;
                    if(a.Name > b.Name) return 1;
                    return 0;
                });
            } else  {
            	tempList.sort(function(a, b){
                    if(a.CategoryName < b.CategoryName) return -1;
                    if(a.CategoryName > b.CategoryName) return 1;
                    return 0;
                });
            } 
            if (keyCode == 40 && totalRecordsToTraverse > 0) {
                if (totalRecordsToTraverse - 1 > $scope.AccountingSetupModel.currentDropDownIndex) {
                    $scope.AccountingSetupModel.currentDropDownIndex++;
                    if (templateName == 'serviceJobType') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#serviceJobType_';
                    } else if (templateName == 'serviceJobPartCategory') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#serviceJobPartCategory_';
                    }else if (templateName == 'serviceJobLaborCategory') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#serviceJobLaborCategory_';
                    } else if (templateName == 'serviceJobInternalCategory') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#serviceJobInternalCategory_';
                    } else if (templateName == 'serviceJobProvider') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#serviceJobProvider_';
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.AccountingSetupModel.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.AccountingSetupModel.currentDropDownIndex > 0) {
                    $scope.AccountingSetupModel.currentDropDownIndex--;
                    if (templateName == 'serviceJobType') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#serviceJobType_';
                    } else if (templateName == 'serviceJobPartCategory') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#serviceJobPartCategory_';
                    }else if (templateName == 'serviceJobLaborCategory') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#serviceJobLaborCategory_';
                    } else if (templateName == 'serviceJobInternalCategory') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#serviceJobInternalCategory_';
                    } else if (templateName == 'serviceJobProvider') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#serviceJobProvider_';
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.AccountingSetupModel.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode == 13 && $scope.AccountingSetupModel.currentDropDownIndex !== -1) {
                if(templateName == 'serviceJobType') {
                	$scope.AccountingSetupModel.setSJTData(tempList[$scope.AccountingSetupModel.currentDropDownIndex],'Type');
                } else if(templateName == 'serviceJobPartCategory') {
                	$scope.AccountingSetupModel.setSJTData(tempList[$scope.AccountingSetupModel.currentDropDownIndex],'PartCategory');
                } else if(templateName == 'serviceJobLaborCategory') {
                	$scope.AccountingSetupModel.setSJTData(tempList[$scope.AccountingSetupModel.currentDropDownIndex],'LabourCategory');
                } else if(templateName == 'serviceJobInternalCategory') {
                	$scope.AccountingSetupModel.setSJTData(tempList[$scope.AccountingSetupModel.currentDropDownIndex],'InternalCategory');
                } else if(templateName == 'serviceJobProvider') {
                	$scope.AccountingSetupModel.setSJTData(tempList[$scope.AccountingSetupModel.currentDropDownIndex],'Provider');
                }
                $scope.AccountingSetupModel.currentDropDownIndex = -1;
            }
        }
		
	    $scope.AccountingSetupModel.loadAccoutingData();
	}])
});   