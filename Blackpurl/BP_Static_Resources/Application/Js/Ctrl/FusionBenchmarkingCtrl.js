define(['Routing_AppJs_PK', 'moment', 'FusionBenchmarkingServices','NumberOnlyInput_New'], function(Routing_AppJs_PK,moment, FusionBenchmarkingServices,NumberOnlyInput_New) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('FusionBenchmarkingCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state','FusionBenchmarkingService', '$translate', function($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, FusionBenchmarkingService,$translate) {
        var Notification = injector1.get("Notification");
        
        $scope.M_FusionBenchmarking = $scope.M_FusionBenchmarking || {};
        $scope.F_FusionBenchmarking = $scope.F_FusionBenchmarking || {};
        $scope.M_FusionBenchmarking.monthList = [];
        $scope.M_FusionBenchmarking.Years = [];
        $scope.M_FusionBenchmarking.isLoading = false;
        $scope.M_FusionBenchmarking.monthList = (Array.apply(0, Array(12)).map(function(_,i){return moment().month(i).format('MMMM')}));
        var Currentyear = parseInt(new Date().getFullYear());
        function setDefaultValidationModel() {
	        $scope.M_FusionBenchmarking.formValidationModal = {
	        		WorkingDaysInPeriod: {
	                    isError: false,
	                    ErrorMessage: '',
	                    Type: 'Required',
	                    Maxlength: 50
	                },
	                EmployeeNoSales: {
	                    isError: false,
	                    ErrorMessage: '',
	                    Type: 'Required'
	                },
	                EmployeeNoServiceTechnical: {
	                	 isError: false,
	                     ErrorMessage: '',
	                     Type: 'Required'
	                },
	                EmployeeNoServiceNonTechnical: {
	                	 isError: false,
	                     ErrorMessage: '',
	                     Type: 'Required'
	                },
	                EmployeeNoParts: {
	                	 isError: false,
	                     ErrorMessage: '',
	                     Type: 'Required'
	                },
	                EmployeeNoAdministrationAndOther: {
	                	 isError: false,
	                     ErrorMessage: '',
	                     Type: 'Required'
	                },
	                NoSalesPeople: {
	                	 isError: false,
	                     ErrorMessage: '',
	                     Type: 'Required'
	                },
	                NoInsuranceContractsWritten: {
	                	 isError: false,
	                     ErrorMessage: '',
	                     Type: 'Required'
	                },
	                NoOfWorkingDays: {
	                	 isError: false,
	                     ErrorMessage: '',
	                     Type: 'Required'
	                },
	                AverageTechnicianPrimeLaborCost: {
	                	 isError: false,
	                     ErrorMessage: '',
	                     Type: 'Required'
	                }
	            };
      }
        const monthNames = ["January", "February", "March", "April", "May", "June",
        	  "July", "August", "September", "October", "November", "December"
        	];
        
        function getMonthAndYearForReporting() {
        	var today = new Date();
        	var date = today.getDate();
        	var month = today.getMonth(); //January is 0!
        	var year = today.getFullYear();
        	
        	if(month == 0) {
        		year = year -1;
        		$scope.M_FusionBenchmarking.Info.SelectedMonth = "December";
        	} else {
        		$scope.M_FusionBenchmarking.Info.SelectedMonth = monthNames[month - 1];
        	}
        	$scope.M_FusionBenchmarking.Info.SelectedYear = year;
        }
        
        /* Load modals values which needs be loaded only once while page lifetime */
        for (i = Currentyear ; i > (Currentyear - 100 + 2); i--) {
            var year = {
                year: i
            };
            $scope.M_FusionBenchmarking.Years.push(year);
        }
        $scope.F_FusionBenchmarking.validateForm = function() {
        	 angular.forEach($scope.M_FusionBenchmarking.formValidationModal, function(value, key) {
          	   $scope.F_FusionBenchmarking.validateFieldWithKey(key);
             });
        }
        $scope.F_FusionBenchmarking.validateFieldWithKey = function(modelKey) {
        	var fieldValue = $scope.M_FusionBenchmarking.Info[modelKey];
            var validateType = $scope.M_FusionBenchmarking.formValidationModal[modelKey].Type;
            var isError = false;
            var ErrorMessage = '';
            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                    isError = true;
                    ErrorMessage = $translate.instant('Field_Is_Required');
                }
            }
            $scope.M_FusionBenchmarking.formValidationModal[modelKey].isError = isError;
            $scope.M_FusionBenchmarking.formValidationModal[modelKey].ErrorMessage = ErrorMessage;
            if ($scope.M_FusionBenchmarking.formValidationModal[modelKey].isError == true) {
                $scope.M_FusionBenchmarking.isValidForm = false;
            }
        }
        
        $scope.F_FusionBenchmarking.saveBenchmarkingData = function() {
        	 $scope.M_FusionBenchmarking.isValidForm = true;
        	 $scope.F_FusionBenchmarking.validateForm();
             if(!$scope.M_FusionBenchmarking.isValidForm) {
             	return;
             }
             $scope.M_FusionBenchmarking.isLoading = true;
         	 FusionBenchmarkingService.saveFusionBenchMarking(angular.toJson($scope.M_FusionBenchmarking.Info)).then(function(result) {
         		console.log(JSON.stringify($scope.M_FusionBenchmarking.Info.SelectedMonth), JSON.stringify($scope.M_FusionBenchmarking.Info.SelectedYear));
         		if(result == 'Success') {
         			FusionBenchmarkingService.getProfitAndLossFromQB(($scope.M_FusionBenchmarking.Info.SelectedMonth), JSON.stringify($scope.M_FusionBenchmarking.Info.SelectedYear)).then(function(result) {
         				if(result == 'Success') {
         					FusionBenchmarkingService.getBalanceSheetFromQB(($scope.M_FusionBenchmarking.Info.SelectedMonth), JSON.stringify($scope.M_FusionBenchmarking.Info.SelectedYear)).then(function(result) {
         						if(result == 'Success') {
         							FusionBenchmarkingService.getOtherAccountInfoFromQB(($scope.M_FusionBenchmarking.Info.SelectedMonth), JSON.stringify($scope.M_FusionBenchmarking.Info.SelectedYear)).then(function(result) {
         								if(result == 'Success') {
         									FusionBenchmarkingService.getOtherAccountInfoFromQB_Yearly(($scope.M_FusionBenchmarking.Info.SelectedMonth), JSON.stringify($scope.M_FusionBenchmarking.Info.SelectedYear)).then(function(result) {
         										if(result == 'Success') {
                 									FusionBenchmarkingService.populateBlackpurlData(($scope.M_FusionBenchmarking.Info.SelectedMonth), JSON.stringify($scope.M_FusionBenchmarking.Info.SelectedYear)).then(function(result) {
                 										FusionBenchmarkingService.saveFusionLineItemValues(JSON.stringify(result)).then(function(result) {
                 										if(result == 'Success') {
                         									FusionBenchmarkingService.populateBlackpurlData2(($scope.M_FusionBenchmarking.Info.SelectedMonth), JSON.stringify($scope.M_FusionBenchmarking.Info.SelectedYear)).then(function(result) {
	                         										FusionBenchmarkingService.saveFusionLineItemValues(JSON.stringify(result)).then(function(result) {
                         										if(result == 'Success') {
                                 									FusionBenchmarkingService.populateCalculatedData().then(function(result) {
                                 										if(result == 'Success') {
                                 											window.open('/apex/FusionReport','_blank');
                                                                    		Notification.success($translate.instant('Report_generation_msg'));
                                                                    		$scope.M_FusionBenchmarking.isLoading = false;
                                 										}
                                                                    }, function(error) {
                                                                    	$scope.M_FusionBenchmarking.isLoading = false;
                                                                        Notification.error($translate.instant('Error_msg_qb'));
                                                                    });
                                 								}
                                                            }, function(error) {
                                                            	$scope.M_FusionBenchmarking.isLoading = false;
                                                                Notification.error($translate.instant('Error_msg_qb'));
                                                            });
	                                                            }, function(error) {
	                                                            	$scope.M_FusionBenchmarking.isLoading = false;
	                                                                Notification.error($translate.instant('Error_msg_qb'));
	                                                            });
                         								}
                 										}, function(error) {
                                                        	$scope.M_FusionBenchmarking.isLoading = false;
                                                            Notification.error($translate.instant('Error_msg_qb'));
                                                        });
                                                    }, function(error) {
                                                    	$scope.M_FusionBenchmarking.isLoading = false;
                                                        Notification.error($translate.instant('Error_msg_qb'));
                                                    });
                 								}
                                            }, function(error) {
                                            	$scope.M_FusionBenchmarking.isLoading = false;
                                                Notification.error($translate.instant('Error_msg_qb'));
                                            });
         								}
                                    }, function(error) {
                                    	$scope.M_FusionBenchmarking.isLoading = false;
                                        Notification.error($translate.instant('Error_msg_qb'));
                                    });
         						}
                            }, function(error) {
                            	$scope.M_FusionBenchmarking.isLoading = false;
                                Notification.error($translate.instant('Error_msg_qb'));
                            });
         				}
                    }, function(error) {
                    	$scope.M_FusionBenchmarking.isLoading = false;
                        Notification.error($translate.instant('Error_msg_qb'));
                    });
         		}
            }, function(error) {
            	$scope.M_FusionBenchmarking.isLoading = false;
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        
        $scope.F_FusionBenchmarking.loadData = function() {
        	FusionBenchmarkingService.getFusionBenchMarkingDetail().then(function(result) {
        		$scope.M_FusionBenchmarking.Info = result;
        		setDefaultValidationModel();
        		getMonthAndYearForReporting();
        		showTooltip('body');
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.F_FusionBenchmarking.keyBoardNavigation = function (event, dataList, dropDownName) {
            var keyCode = event.which ? event.which : event.keyCode;
            var dropDownDivId = '#' + dropDownName + 'DropDownDiv';
            var indexName = dropDownName + 'CurrentIndex';
            if ($scope.M_FusionBenchmarking[indexName] == undefined || isNaN($scope.M_FusionBenchmarking[indexName])) {
            	$scope.M_FusionBenchmarking[indexName] = -1;
            }

            if (dropDownName === 'monthFusionBenchmarking') {
            	$scope.M_FusionBenchmarking.showMonth = true;
            } else if (dropDownName === 'YearFusionBenchmarking') {
            	$scope.M_FusionBenchmarking.showYear = true;
            }
            
            if (keyCode == 40 && dataList != undefined && dataList != '') {
                if (dataList.length - 1 > $scope.M_FusionBenchmarking[indexName]) {
                	$scope.M_FusionBenchmarking[indexName]++;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_FusionBenchmarking[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode === 38 && dataList != undefined && dataList != '') {
                if ($scope.M_FusionBenchmarking[indexName] > 0) {
                	$scope.M_FusionBenchmarking[indexName]--;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_FusionBenchmarking[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode == 13 && $scope.M_FusionBenchmarking[indexName] !== -1) {
                if (dropDownName === 'monthFusionBenchmarking') {
                	$scope.F_FusionBenchmarking.selectMonthForReport(dataList[$scope.M_FusionBenchmarking[indexName]]);
                	$scope.M_FusionBenchmarking.showMonth = false;
                } else if (dropDownName === 'YearFusionBenchmarking') {
                	$scope.F_FusionBenchmarking.selectYearForReport(dataList[$scope.M_FusionBenchmarking[indexName]].year);
                	$scope.M_FusionBenchmarking.showYear = false;
                }
                
                $scope.M_FusionBenchmarking[indexName] = -1;
            }
        }
        $scope.F_FusionBenchmarking.selectMonthForReport = function(monthValue) {
        	$scope.M_FusionBenchmarking.Info.SelectedMonth = monthValue;
        }
        $scope.F_FusionBenchmarking.selectYearForReport = function(yearValue) {
        	$scope.M_FusionBenchmarking.Info.SelectedYear = yearValue;
        }
        $scope.F_FusionBenchmarking.setFocusOnElement = function(elementId) {
        	setTimeout(function() {
        		angular.element("#" + elementId).focus();
        	},200);
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
        
        $scope.F_FusionBenchmarking.loadData();
    }])
});