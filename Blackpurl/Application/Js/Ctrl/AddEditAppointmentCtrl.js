'use strict';
define(['Routing_AppJs_PK', 'FullPageModal', 'AutoComplete_V2', 'InfoCardComponent', 'NumberOnlyInput_New', 'AddEditAppointmentServices', 'underscore_min', 'addEditTextTag', 'moment','BP_Calendar_Nav_Bar','HighlightSearchTextFilter'], function(Routing_AppJs_PK, FullPageModal, AutoComplete_V2, InfoCardComponent, NumberOnlyInput_New, AddEditAppointmentServices, underscore_min, addEditTextTag, moment,BP_Calendar_Nav_Bar,HighlightSearchTextFilter) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditAppointmentCtrl', ['$scope', '$rootScope', '$translate', '$state', 'AppointmentService','$stateParams',
        function($scope, $rootScope, $translate, $state, AppointmentService, $stateParams) {
            var Notification = injector.get("Notification");
            $scope.M_AddEditApp = $scope.M_AddEditApp || {};
            $scope.M_AddEditApp.isLoading = true;
            $scope.F_AddEditApp = $scope.F_AddEditApp || {};
            $scope.M_AddEditApp.dateFormat = $Global.SchedulingDateFormat;
            $scope.M_AddEditApp.isEdit = false;
            $scope.M_AddEditApp.isLoadedByPlus = false;
            $scope.M_AddEditApp.loadAddEditTextTagBlock = false;
            $scope.$on('getAppointmentTime', function(event, args) {
                $scope.M_AddEditApp.SelectedAppointmentDate = args.AppointmentDate;
                $scope.M_AddEditApp.selectedAppointmentSegment = args.SelectedSegment;
                $scope.M_AddEditApp.SelectedAppointmentDateStr = moment(args.AppointmentDate, $Global.SchedulingDateFormat).format('dddd, Do MMMM YYYY') + " - " 
                	+ "<span class=\"mobile-segment-label\">"+((args.SelectedSegment === 1) ? $translate.instant('Afternoon') : $translate.instant('Morning'))+"</span>";
                $scope.F_AddEditApp.openOrCloseDayTimeSelectorView('collapsedAppointmentSelector');
                getAllTechnicianListData();
            });
            //Local Var Initializations
            $scope.M_AddEditApp = {
                'loading': false,
                'currentDayTimeSelectionView': 'timeSelector',
                'defaultAppointmentTitle': $translate.instant('Untitled_appointment'),
                'customerRec': {},
                'customerCardInfoPayload': {}, // Payload Object for infoCardComponent
                'COUList': [],
                'COURec': {},
                'COUCardInfoPayload': {}, // Payload Object for infoCardComponent
                'jobTypeList': [],
                'jobTypeListForLinkSOModal': [],
                'appointmentJSON': {
                    Title: 'Untitled appointment',
                    estimatedHours: 1
                }
            }
            /* Assign Technician functionality start here*/
            $scope.M_AddEditApp.currentAssignTechnicianSelectionView = 'collapsedAssignTechnicianSelector';
            $scope.M_AddEditApp.assignTechnicianJSON = {};
            $scope.M_AddEditApp.currentDropDownIndex = -1;
            $scope.M_AddEditApp.assignTimeJSON = {};
                $scope.F_AddEditApp.openOrCloseAssignTechniSelectorView = function(viewName) {
                    $scope.M_AddEditApp.currentAssignTechnicianSelectionView = viewName;
                    if (viewName == 'collapsedAssignTechnicianSelector') {
                        addTransitionCollapse("#assign-technician-grid");
                    } else {
                        addTransitionExpand('#assign-technician-grid');
                    }
                }

                $scope.F_AddEditApp.keyPressNavigationOnDropdownElements = function(event, dropdownDivId, templateName, dropdownList) {
                    var keyCode = event.which ? event.which : event.keyCode;
                    var tempList = angular.copy(dropdownList);
                    var dropDownDivId = '#' + dropdownDivId;
                    var idSubStr = '';
                    var totalRecordsToTraverse = 0;
                    if (tempList) {
                        totalRecordsToTraverse += tempList.length;
                    }
                    
                    if (keyCode == 40 && totalRecordsToTraverse > 0) {
                        if(templateName == 'assigntech' && $scope.M_AddEditApp.currentDropDownIndex != -1 && tempList[$scope.M_AddEditApp.currentDropDownIndex + 1].AvailableHoursMorning == 0 && tempList[$scope.M_AddEditApp.currentDropDownIndex + 1].AvailableHoursAfternoon == 0) {
                            return ;
                        }
                        if (totalRecordsToTraverse - 1 > $scope.M_AddEditApp.currentDropDownIndex) {
                            $scope.M_AddEditApp.currentDropDownIndex++;
                            if (templateName == 'assigntech') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                                idSubStr = '#assigntech_';
                            } else if(templateName == 'timeslot') {
                                idSubStr = '#timeslot_';
                            }
                            angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_AddEditApp.currentDropDownIndex)[0].offsetTop - 100;
                        }
                    } else if (keyCode === 38) {
                        if(templateName == 'assigntech' && $scope.M_AddEditApp.currentDropDownIndex != -1 && tempList[$scope.M_AddEditApp.currentDropDownIndex].AvailableHoursMorning == 0 && tempList[$scope.M_AddEditApp.currentDropDownIndex].AvailableHoursAfternoon == 0) {
                            return ;
                        }
                        if ($scope.M_AddEditApp.currentDropDownIndex > 0) {
                            $scope.M_AddEditApp.currentDropDownIndex--;
                            if (templateName == 'assigntech') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else  
                                idSubStr = '#assigntech_';
                            }else if(templateName == 'timeslot') {
                                idSubStr = '#timeslot_';
                            }
                            angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_AddEditApp.currentDropDownIndex)[0].offsetTop - 100;
                        }
                    } else if (keyCode == 13 && $scope.M_AddEditApp.currentDropDownIndex !== -1) {
                        if(templateName == 'assigntech') {
                             $scope.F_AddEditApp.selectAssignTechnician(tempList[$scope.M_AddEditApp.currentDropDownIndex]);
                        }else if(templateName == 'timeslot') {
                            $scope.F_AddEditApp.selectAssignTimeSlot(tempList[$scope.M_AddEditApp.currentDropDownIndex]);
                        }
                        $scope.M_AddEditApp.currentDropDownIndex = -1;
                    }
                }

                $scope.F_AddEditApp.hideDropdown = function() {
                    $scope.M_AddEditApp.currentDropDownIndex = -1;
                }
                $scope.F_AddEditApp.selectAssignTimeSlot = function(timeRec,event) {
                    $scope.M_AddEditApp.assignTimeJSON = timeRec;
                    $scope.M_AddEditApp.assignTimeJSON.selectedTechnicianTime = timeRec.TimeSlotRec;
                    $scope.F_AddEditApp.hideDropdown();
                    $scope.M_AddEditApp.showAssignTimeDropdown = false;
                    $scope.M_AddEditApp.isError = false;
                    $scope.M_AddEditApp.showSelectTimeError = false;
                }
                $scope.F_AddEditApp.selectAssignTechnician = function(techRec,event) {
                    $scope.M_AddEditApp.assignTechnicianJSON = techRec;
                    $scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianName = techRec.Name;
                    $scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianId = techRec.Id;
                    $scope.M_AddEditApp.assignTimeJSON.selectedTechnicianTime = '';
                    $scope.F_AddEditApp.hideDropdown();
                    $scope.M_AddEditApp.showAssignTechnicianDropdown = false;
                    var timeSlotJSON = {
                        'EstimatedHours': $scope.M_AddEditApp.appointmentJSON.estimatedHours,
                        'AppointmentDate': $scope.M_AddEditApp.SelectedAppointmentDate,
                        "TechnicianId" : $scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianId,
                        "AppointmentDay":$scope.M_AddEditApp.SelectedAppointmentDateStr.split(",")[0]
                    }
                    AppointmentService.getTimeSlotAndStateForTechnician(angular.toJson(timeSlotJSON)).then(function(successResult) {
                        console.log(successResult);
                        console.log("successResult");
                        $scope.M_AddEditApp.timeSlotJSON = successResult;
                        angular.element("#time-slot-input").focus();

                    }, function(error) {
                        Notification.error($translate.instant('GENERIC_ERROR'));
                        $scope.M_AddEditApp.isLoading = false;
                    });
                   
                    
                }


            /*Assign Technician functionality End Here*/


            $scope.M_AddEditApp.currentDayTimeSelectionView = 'collapsedAppointmentSelector';
            $scope.F_AddEditApp.openOrCloseDayTimeSelectorView = function(viewName) {
                $scope.M_AddEditApp.currentDayTimeSelectionView = viewName;
                if (viewName == 'collapsedAppointmentSelector') {
                    addTransitionCollapse("#appointment_schedule_grid");
                } else {
                    addTransitionExpand('#appointment_schedule_grid');
                }
            }
            
            $scope.F_AddEditApp.selectInputText = function(elementId) {
                angular.element("#"+ elementId).select();
            }
            function addTransitionExpand(expandableDivId) {
                var expandableDiv = angular.element(expandableDivId);
                var expandableDivChildDivHeight = angular.element(angular.element(expandableDivId + ' > div')[0]).outerHeight();
                expandElement(expandableDiv, expandableDivChildDivHeight);
                setTimeout(function() {
                    if (checkForDevice('iPad')) {
                        expandableDiv.css('transition', 'none');
                    }
                }, 500);
            }
            
            function addTransitionCollapse(collapsableDivId) {
                var collapsableDiv = angular.element(collapsableDivId);
                collapseElement(collapsableDiv);
            }
            $scope.$on('AutoCompleteCallbackHandler', function(event, args) {
                var selectedId = args.selectedId;
                if (args.type == 'addCustomer') {
                    if (selectedId) {
                        getCustomerRecByCustomerId(selectedId);
                    } else {
                    	createCustomerCardInfoPayload();
                    }
                	$scope.M_AddEditApp.isCustomerSelectedFromAutocomplete = true;
                	$scope.M_AddEditApp.selectedCOUUnitRec = {};
                } else if (args.type == 'addCustomerOwnedUnit') {
                    if (selectedId) {
                        defaultActionAfterSelectCOU(selectedId);
                    }
                }
               if (args.type == 'selectJobType' && args.selectedJobType) {
                    $scope.M_AddEditApp.appointmentJSON.selectedJobTypeLabel = args.selectedJobType.CodeLabel; //Transaction type rec Code Label
                    $scope.M_AddEditApp.appointmentJSON.selectedJobTypeId = args.selectedJobType.Id; //Transaction type rec Id
                    $scope.M_AddEditApp.appointmentJSON.selectedTransactionType = args.selectedJobType.Type; //Transaction type rec Type
                } else if(args.type == 'selectLinkedSOJobType' && args.selectLinkedSOJobType) {
                    $scope.M_AddEditApp.appointmentJSON.selectLinkedSOJobTypeLabel = args.selectLinkedSOJobType.CodeLabel; //Transaction type rec Code Label
                    
                    $scope.M_AddEditApp.appointmentJSON.selectLinkedSOJobTypeId = args.selectLinkedSOJobType.Id; //Transaction type rec Id
                    if($scope.F_AddEditApp.dirRefreshFnOnParamChange) {
                    	setTimeout(function() {
                    		$scope.F_AddEditApp.dirRefreshFnOnParamChange('linkedSoJobTypeId'); // Refresh directive(Autocompete_v2 - STA) on linked So Job Type Id change
                    	}, 1);
                    }
                    
                    $scope.M_AddEditApp.appointmentJSON.selectLinkedSOJobType = args.selectLinkedSOJobType.Type; //Transaction type rec Type
               		$scope.M_AddEditApp.appointmentJSON.selectedSODescription = '';
                    $scope.M_AddEditApp.appointmentJSON.selectedLinkedSORecord = '';
               } else if (args.type == 'LinkedServiceJob' && selectedId && args.selectedJSON) {
                    $scope.M_AddEditApp.appointmentJSON.selectedSODescription = args.selectedJSON.Description;
                    $scope.M_AddEditApp.appointmentJSON.selectedLinkedSORecord = args.selectedJSON;
                } 
            });
            $scope.M_AddEditApp.IsNewCustomerCreatedFromAutoComplete = false;
            $scope.$on('createCustomerAutoCompleteCallback', function(event, args) {
                $scope.M_AddEditApp.IsNewCustomerCreatedFromAutoComplete = true;
                loadState($state, 'AddEditAppointment.AddEditCustomerV2');
            });
            $scope.F_AddEditApp.CustomerSaveCallback = function(customerId) {
                getCustomerRecByCustomerId(customerId);
            }
            $scope.F_AddEditApp.setRoundedValueForEstimatedHours = function(valueToRoundOff) {// Change to positive
                var decimal = valueToRoundOff - Math.floor(valueToRoundOff);
                decimal = parseFloat(0.25*Math.round(parseFloat((decimal*100.0)/25.00)));
                $scope.M_AddEditApp.appointmentJSON.estimatedHours = decimal + Math.floor(valueToRoundOff);
                if($stateParams.AddEditAppointmentParams.appointmentData.EstimatedHours != $scope.M_AddEditApp.appointmentJSON.estimatedHours) {
                	getAllTechnicianListData();
                } 
                
            }
            $scope.M_AddEditApp.showSelectTimeError = false;
            function getAllTechnicianListData() {
                if($scope.M_AddEditApp.appointmentJSON.estimatedHours && $scope.M_AddEditApp.SelectedAppointmentDate) {
                	if($scope.M_AddEditApp.isEdit) {
                		$scope.M_AddEditApp.assignTimeJSON.selectedTechnicianTime = '';
                		$scope.F_AddEditApp.hideDropdown();
                		$scope.M_AddEditApp.showSelectTimeError = true;
                		var timeSlotJSON = {
                            'EstimatedHours': $scope.M_AddEditApp.appointmentJSON.estimatedHours,
                            'AppointmentDate': $scope.M_AddEditApp.SelectedAppointmentDate,
                            "TechnicianId" : $scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianId,
                            "AppointmentDay":$scope.M_AddEditApp.SelectedAppointmentDateStr.split(",")[0]
                        }
                		AppointmentService.getTimeSlotAndStateForTechnician(angular.toJson(timeSlotJSON)).then(function(successResult) {
                            console.log(successResult);
                            console.log("successResult");
                            $scope.M_AddEditApp.timeSlotJSON = successResult;
                            $scope.F_AddEditApp.openOrCloseAssignTechniSelectorView('expandedAssignTechnicianSelector');
                            $scope.M_AddEditApp.isError = true;

                        }, function(error) {
                            Notification.error($translate.instant('GENERIC_ERROR'));
                            $scope.M_AddEditApp.isLoading = false;
                        });
                		
                	} else {
                		var assignappoitmentRec = {
                            'EstimatedHours': $scope.M_AddEditApp.appointmentJSON.estimatedHours,
                            'StartDate': $scope.M_AddEditApp.SelectedAppointmentDate,
                            "AppointmentDaySegment" : $scope.M_AddEditApp.selectedAppointmentSegment === 0 ? 'Morning' : 'Afternoon'
                        }
                        AppointmentService.getTechnicianListWithAvailableHours(angular.toJson(assignappoitmentRec)).then(function(successResult) {
                            $scope.M_AddEditApp.technicianList = successResult
                            $scope.M_AddEditApp.assignTimeJSON = {};
                            $scope.M_AddEditApp.assignTechnicianJSON = {};
                            $scope.F_AddEditApp.openOrCloseAssignTechniSelectorView('collapsedAssignTechnicianSelector')

                        }, function(error) {
                            Notification.error($translate.instant('GENERIC_ERROR'));
                            $scope.M_AddEditApp.isLoading = false;
                        });
                	}
                }
            }
             $scope.F_AddEditApp.restoreCustomerCard = function() {
            	 if($scope.M_AddEditApp.IsNewCustomerCreatedFromAutoComplete) {
            		 $scope.M_AddEditApp.IsNewCustomerCreatedFromAutoComplete = false;
					 $scope.M_AddEditApp.selectedCOUUnitRec = {};
            		 return;
            	 }
            	if(!$scope.M_AddEditApp.isCustomerSelectedFromAutocomplete) {
            		$scope.M_AddEditApp.isChangeCOU = false;
            		$scope.M_AddEditApp.isChangeCustomer = false;
            	}
            }
            function getCustomerRecByCustomerId(customerId) {
                $scope.M_AddEditApp.isLoading = true;
                $scope.M_AddEditApp.isError = false;
                AppointmentService.getCustomerRecByCustomerId(customerId).then(function(customerData) {
                    $scope.M_AddEditApp.customerRec = customerData.CustomerRecord;
                    $scope.M_AddEditApp.COUList = customerData.COURecords;
                    if($scope.M_AddEditApp.COUList.length == 1) {
                        defaultActionAfterSelectCOU($scope.M_AddEditApp.COUList[0].UnitId);
                    }
                    $scope.M_AddEditApp.isChangeCustomer = false;
                    defaultActionAfterSelectCustomer();
                    $scope.M_AddEditApp.isLoading = false;
                }, function(error) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                    $scope.M_AddEditApp.isLoading = false;
                });
            }
            
            function defaultActionAfterSelectCustomer() {
                createCustomerCardInfoPayload();
            }
            
            function getFormatePhoneNumber() {
                var customerPhoneNumber;
                if ($scope.M_AddEditApp.customerRec.PreferredPhone) {
                    if ($scope.M_AddEditApp.customerRec.PreferredPhone === 'HomeNumber') {
                        customerPhoneNumber = $scope.M_AddEditApp.customerRec.FormattedHomeNumber;
                    } else if ($scope.M_AddEditApp.customerRec.PreferredPhone === 'OtherPhone') {
                        customerPhoneNumber = $scope.M_AddEditApp.customerRec.OtherPhone;
                    } else if ($scope.M_AddEditApp.customerRec.PreferredPhone === 'WorkNumber') {
                        customerPhoneNumber = $scope.M_AddEditApp.customerRec.WorkNumber;
                    }
                } else {
                    if ($scope.M_AddEditApp.customerRec.HomeNumber) {
                        customerPhoneNumber = $scope.M_AddEditApp.customerRec.FormattedHomeNumber;
                    } else if ($scope.M_AddEditApp.customerRec.WorkNumber) {
                        customerPhoneNumber = $scope.M_AddEditApp.customerRec.FormattedWorkNumber;
                    } else if ((!$scope.M_AddEditApp.customerRec.WorkNumber && $scope.M_AddEditApp.customerRec.OtherPhone && $scope.M_AddEditApp.customerRec.Type == 'Business') || (!$scope.M_AddEditApp.customerRec.HomeNumber && $scope.M_AddEditApp.customerRec.OtherPhone && $scope.M_AddEditApp.customerRec.Type == 'Individual')) {
                        customerPhoneNumber = $scope.M_AddEditApp.customerRec.FormattedOtherPhone;
                    }
                }
                return customerPhoneNumber;
            }
            
           function getFormateEmail() {
                var customerEmail;
                if ($scope.M_AddEditApp.customerRec.PreferredEmail == '') {
                    if ($scope.M_AddEditApp.customerRec.HomeEmail) {
                        customerEmail = $scope.M_AddEditApp.customerRec.HomeEmail;
                    } else if ($scope.M_AddEditApp.customerRec.WorkEmail) {
                        customerEmail = $scope.M_AddEditApp.customerRec.WorkEmail;
                    } else if ($scope.M_AddEditApp.customerRec.OtherEmail) {
                        customerEmail = $scope.M_AddEditApp.customerRec.OtherEmail;
                    }
                } else {
                    if ($scope.M_AddEditApp.customerRec.PreferredEmail === 'HomeEmail') {
                        customerEmail = $scope.M_AddEditApp.customerRec.HomeEmail;
                    } else if ($scope.M_AddEditApp.customerRec.PreferredEmail === 'OtherEmail') {
                        customerEmail = $scope.M_AddEditApp.customerRec.OtherEmail;
                    } else if ($scope.M_AddEditApp.customerRec.PreferredEmail === 'WorkEmail') {
                        customerEmail = $scope.M_AddEditApp.customerRec.WorkEmail;
                    }
                }
                return customerEmail;
            }
            
            function createCustomerCardInfoPayload() {
                $scope.M_AddEditApp.customerCardInfoPayload = {
                    headerText: ($scope.M_AddEditApp.customerRec && $scope.M_AddEditApp.customerRec.BusinessName) ? $scope.M_AddEditApp.customerRec.BusinessName: 'UNIT INVENTORY',
                    headerImage: 'customer.svg',
                    hyperlinkActionVisible: ($scope.M_AddEditApp.appointmentJSON && $scope.M_AddEditApp.appointmentJSON.SOHeaderId) || ($scope.M_AddEditApp.previousStateName === 'CustomerOrder_V2') ? false :true,
                    primaryFields: ($scope.M_AddEditApp.customerRec && $scope.M_AddEditApp.customerRec.BusinessName) ? ([{
                        Label: '',
                        Value: getFormateEmail()
                    }, {
                        Label: '',
                        Value: getFormatePhoneNumber()
                    }]) : ([{
                        Label: '',
                        Value: 'Internal Service'
                    }]),
                    hyperlinktext: $translate.instant('Change_customer_label')
                }
            }
            var segmentToStartTime = [moment('8:00AM', 'hh:mma'), moment('1:00PM', 'hh:mma')];
            $scope.F_AddEditApp.saveAppointment = function() {
                $scope.M_AddEditApp.isError = false;
                   if((!$scope.M_AddEditApp.customerRec.Id &&  $scope.M_AddEditApp.customerCardInfoPayload.headerText != 'UNIT INVENTORY') || !$scope.M_AddEditApp.selectedCOUUnitRec || !$scope.M_AddEditApp.selectedCOUUnitRec.Id  || !$scope.M_AddEditApp.appointmentJSON.estimatedHours
                       ||!$scope.M_AddEditApp.SelectedAppointmentDate || isNaN($scope.M_AddEditApp.selectedAppointmentSegment)) {
                       $scope.M_AddEditApp.isError = true;
                       return;
                 }
               if($scope.M_AddEditApp.appointmentJSON.estimatedHours > 8) {
            	   $scope.M_AddEditApp.isError = true;
            	   return;
               }
                $scope.M_AddEditApp.appoitmentRec = {
                    'CustomerId': $scope.M_AddEditApp.customerRec.Id,
                    'COUId': $scope.M_AddEditApp.selectedCOUUnitRec.Id,
                    'EstimatedHours': $scope.M_AddEditApp.appointmentJSON.estimatedHours,
                    'TransactionTypeId': $scope.M_AddEditApp.appointmentJSON.selectedJobTypeId,
                    'Title': $scope.M_AddEditApp.appointmentJSON.Title,
                    'StartDate': $scope.M_AddEditApp.SelectedAppointmentDate,
                    "EndDate": $scope.M_AddEditApp.SelectedAppointmentDate,
                    "StartTime": segmentToStartTime[$scope.M_AddEditApp.selectedAppointmentSegment].format("hh:mma"),
                    "EndTime": segmentToStartTime[$scope.M_AddEditApp.selectedAppointmentSegment].format("hh:mma"),
                    "Id": $scope.M_AddEditApp.appointmentJSON.appointmentId,
                    "SOHeaderId": $scope.M_AddEditApp.appointmentJSON.SOHeaderId,
                    "COId":$scope.M_AddEditApp.appointmentJSON.COId
                }
               
               if(!$scope.M_AddEditApp.appointmentJSON.SOHeaderId) {
            	   $scope.M_AddEditApp.appoitmentRec.Concern = $scope.directivePayload.Tags;
               } else {
            	   $scope.M_AddEditApp.appoitmentRec.Concern = $scope.soManualConcerns
               }
               if($scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianId) {
                $scope.M_AddEditApp.appoitmentRec.TechnicianId = $scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianId;
               }
               if($scope.M_AddEditApp.assignTimeJSON.selectedTechnicianTime) {
                    $scope.M_AddEditApp.appoitmentRec.StartTime = moment($scope.M_AddEditApp.assignTimeJSON.selectedTechnicianTime,"hh:mma").format("hh:mmA");
                    $scope.M_AddEditApp.appoitmentRec.EndTime = moment($scope.M_AddEditApp.assignTimeJSON.selectedTechnicianTime,"hh:mma").format("hh:mmA");
                    if($scope.M_AddEditApp.assignTimeJSON.availabiltyStatus == 'Push') {
                        $scope.M_AddEditApp.appoitmentRec.isConflictExists = true;
                    } else {
                        $scope.M_AddEditApp.appoitmentRec.isConflictExists = false;
                    }
                }
                
                if($scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianId) {
                    if(!$scope.M_AddEditApp.assignTimeJSON.selectedTechnicianTime) {
                        $scope.M_AddEditApp.isError = true;
                        return;
                    }
                 }
                  AppointmentService.saveAppointment(angular.toJson($scope.M_AddEditApp.appoitmentRec)).then(function(appointmentRec) {
                	
                    if($scope.M_AddEditApp.previousStateName === 'TechScheduler') {
                        $rootScope.$broadcast('reloadTechScheduleGridData',{ currentDate: $scope.M_AddEditApp.appoitmentRec.StartDate});
                    } else if($scope.M_AddEditApp.previousStateName === 'CustomerOrder_V2') {
                        var coArgs = {
                    			SOHeaderId: $scope.M_AddEditApp.appoitmentRec.SOHeaderId, 
                    			ManualConcern: $scope.soManualConcerns,
                    			UnitId:$scope.M_AddEditApp.selectedCOUUnitRec.Id, 
                    			Unitname:$scope.M_AddEditApp.selectedCOUUnitRec.FormattedName
                    	}
                        $rootScope.$broadcast('reloadAppontmentOnCustomerOrder', coArgs);
                    }
                    $scope.F_AddEditApp.closeAction(true);
                }, function(error) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                    $scope.M_AddEditApp.isLoading = false;
                });
            }
            
            function createCOUCardInfoPayload() {
                $scope.M_AddEditApp.isChangeCOU = false;
                $scope.M_AddEditApp.COUCardInfoPayload = {
                    headerText: $scope.M_AddEditApp.selectedCOUUnitRec.FormattedName,
                    headerImage: 'Unit_V2.svg',
                    hyperlinkActionVisible: ($scope.M_AddEditApp.appointmentJSON && $scope.M_AddEditApp.appointmentJSON.SOHeaderId) || ($scope.M_AddEditApp.previousStateName === 'CustomerOrder_V2') ? false :true,
                    primaryFields: [{
                        Label: $translate.instant('Unit_number'),
                        Value: $scope.M_AddEditApp.selectedCOUUnitRec.UnitId
                    }, {
                        Label: $translate.instant('Label_VIN'),
                        Value: $scope.M_AddEditApp.selectedCOUUnitRec.VIN
                    }],
                    hyperlinktext: $translate.instant('Change_unit')
                }
            }
            $scope.F_AddEditApp.setFocusOnInput = function(elementId) {
                angular.element("#" + elementId).focus();
            }
            $scope.F_AddEditApp.MoveToState = function(stateName, attr, openInNewTab) {
                if (attr != undefined && attr != null && attr != '' && !openInNewTab) {
                    loadState($state, stateName, attr);
                } else if (attr != undefined && attr != null && attr != '' && openInNewTab) {
                    var url = $state.href(stateName, attr);
                    window.open(url, '_blank');
                } else {
                    loadState($state, stateName);
                }
            }
            $scope.F_AddEditApp.moveToViewCustomer = function(customerId, openInNewTab) {
                $scope.F_AddEditApp.MoveToState('ViewCustomer', {
                    Id: customerId
                }, openInNewTab);
            }
            $scope.F_AddEditApp.moveToViewUnit = function(unitId, openInNewTab) {
                $scope.F_AddEditApp.MoveToState('ViewUnit', {
                    Id: unitId
                }, openInNewTab);
            }
            $scope.$on('createCOUAutoCompleteCallback', function(event, args) {
                openAddEditCOUPopup();
            });
           $scope.F_AddEditApp.closeAction = function(isReloadData) {
                angular.element("body").removeClass(' modal-open ').css('padding', '0px');
                if($scope.M_AddEditApp.previousStateName === 'TechScheduler.JobScheduler') {
                    loadState($state,'TechScheduler.JobScheduler');
                    if($scope.M_AddEditApp.isEdit) {
                        $rootScope.$broadcast('JobSchedulerLoadData', {isReloadAllData: isReloadData});
                    } else {
                        if($scope.M_AddEditApp.appoitmentRec.TechnicianId) {
                            $rootScope.$broadcast('JobSchedulerLoadData', {isReloadAllData: isReloadData});
                        } else {
                            $rootScope.$broadcast('JobSchedulerLoadData', {isReloadPullOutData: isReloadData});
                        }
                        
                    }
                } else if($scope.M_AddEditApp.previousStateName === 'CustomerOrder_V2') {
                     loadState($state, 'CustomerOrder_V2', {
                        Id: $scope.M_AddEditApp.previousStateId
                    });
                } else {
                    loadState($state,'TechScheduler');
                }
            }
            
            function openAddEditCOUPopup() {
                var AddEditTempUnitParams = {
                    CustomerId: $scope.M_AddEditApp.customerRec.Id,
                    UnitType: 'COU',
                    IsCreateFromAddCustomer: true,
                };
                loadState($state, 'AddEditAppointment.AddEditUnitV2', {
                    AddEditTempUnitParams: AddEditTempUnitParams
                });
            }
            
            function defaultActionAfterSelectCOU(couId) {
                $scope.M_AddEditApp.selectedCOUUnitRec = _.find($scope.M_AddEditApp.COUList, function(o) {
                    return o.UnitId == couId;
                })
                createCOUCardInfoPayload();
            }
            $scope.F_AddEditApp.changeCustomer = function(param) {
                $scope.M_AddEditApp.isChangeCustomer = true;
                $scope.M_AddEditApp.isChangeCOU = false;
                $scope.M_AddEditApp.isCustomerSelectedFromAutocomplete = false;
                setTimeout(function() {
                	$scope.F_AddEditApp.selectInputText('autocompleteCustomer');
                },100);
            }
            $scope.directivePayload = {
                Tags: []
            }
            $scope.nonEditableConcern = {
                    Tags: []
            }
            $scope.F_AddEditApp.changeUnit = function(param) {
                $scope.M_AddEditApp.isChangeCOU = true;
            }
            angular.element(document).mouseup(function(e) {
                if(e.target && ((e.target.id === 'ui-datepicker-div')
                           || $(e.target).closest('#ui-datepicker-div').length)) {
                    return;
                   }
                var container = angular.element("#appointment_schedule_grid");
                if ((e.target.id ===  'week_grid_header') || (!container.is(e.target) && container.has(e.target).length === 0))
                {
                    $scope.F_AddEditApp.openOrCloseDayTimeSelectorView('collapsedAppointmentSelector')
                }
            });
            
            $scope.F_AddEditApp.COUSaveCallback = function(customerId, unitId, isCreatedFromAddCustomerModal) {
                if (isCreatedFromAddCustomerModal) {
                    $scope.M_AddEditApp.isLoading = true;
                    $scope.F_AddEditApp.CustomerSaveCallback(customerId);
                } else {
                    AppointmentService.getUnitById(unitId).then(function(couRec) {
                        $scope.M_AddEditApp.COUList.push(couRec);
                        defaultActionAfterSelectCOU(couRec.UnitId);
                        $scope.M_AddEditApp.isLoading = false;
                    }, function(error) {
                        Notification.error($translate.instant('GENERIC_ERROR'));
                        $scope.M_AddEditApp.isLoading = false;
                    });
                }
            }
            function setAppoitmentDetailInEdit(editAppointmemtData) {
                  if(editAppointmemtData.CustomerId) {
                	  getCustomerRecByCustomerId(editAppointmemtData.CustomerId);  
                  } else {
                	  createCustomerCardInfoPayload();
                  }
                  
                  $scope.F_AddEditApp.COUSaveCallback(editAppointmemtData.CustomerId, editAppointmemtData.COUId, false) ;
                  $scope.M_AddEditApp.appointmentJSON.estimatedHours = editAppointmemtData.EstimatedHours;
                  $scope.M_AddEditApp.appointmentJSON.appointmentId = editAppointmemtData.Id;
                  $scope.M_AddEditApp.appointmentJSON.selectedJobTypeLabel = editAppointmemtData.TransactionTypeLabel; //Transaction type rec Code Label
                  $scope.M_AddEditApp.appointmentJSON.selectedJobTypeId = editAppointmemtData.TransactionTypeId; //Transaction type rec Id
                  $scope.M_AddEditApp.appointmentJSON.selectedTransactionType = editAppointmemtData.TransactionType; //Transaction type rec Type
                  $scope.M_AddEditApp.appointmentJSON.Title = editAppointmemtData.Title;
                  $scope.M_AddEditApp.SelectedAppointmentDate = editAppointmemtData.StartDate;
                  $scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianName = editAppointmemtData.TechnicianName;
                  $scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianId = editAppointmemtData.TechnicianId;
                  $scope.M_AddEditApp.assignTimeJSON.selectedTechnicianTime = ($scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianId ? editAppointmemtData.StartTime : '');
                  $scope.M_AddEditApp.selectedAppointmentSegment = editAppointmemtData.AppointmentDaySegment === 'Morning' ? 0 : 1;
                  $scope.M_AddEditApp.SelectedAppointmentDateStr = moment(editAppointmemtData.StartDate, $Global.SchedulingDateFormat).format('dddd, Do MMMM YYYY') + " - " +  $translate.instant(editAppointmemtData.AppointmentDaySegment);
                  $scope.M_AddEditApp.appointmentJSON.SOHeaderId = (editAppointmemtData.SOHeaderId )? editAppointmemtData.SOHeaderId : null;
                  $scope.M_AddEditApp.appointmentJSON.COId = (editAppointmemtData.COId) ? editAppointmemtData.COId : null;
                  $scope.M_AddEditApp.appointmentJSON.CONumber = (editAppointmemtData.CONumber) ? editAppointmemtData.CONumber : null;    
                  setConcernsOnAppointmentRecord(editAppointmemtData.Concern, editAppointmemtData.SOKitConcern, !isBlankValue($scope.M_AddEditApp.appointmentJSON.SOHeaderId));
                  getDefaultTechnicianData();
            }            
            
            function getDefaultTechnicianData() {
            	var assignappoitmentRec = {
                        'EstimatedHours': $scope.M_AddEditApp.appointmentJSON.estimatedHours,
                        'StartDate': $scope.M_AddEditApp.SelectedAppointmentDate,
                        "AppointmentDaySegment" : $scope.M_AddEditApp.selectedAppointmentSegment === 0 ? 'Morning' : 'Afternoon'
                    }
                    AppointmentService.getTechnicianListWithAvailableHours(angular.toJson(assignappoitmentRec)).then(function(successResult) {
                        $scope.M_AddEditApp.technicianList = successResult
                    }, function(error) {
                        Notification.error($translate.instant('GENERIC_ERROR'));
                        $scope.M_AddEditApp.isLoading = false;
                    });
                var timeSlotJSON = {
                        'EstimatedHours': $scope.M_AddEditApp.appointmentJSON.estimatedHours,
                        'AppointmentDate': $scope.M_AddEditApp.SelectedAppointmentDate,
                        "TechnicianId" : $scope.M_AddEditApp.assignTechnicianJSON.selectedTechnicianId,
                        "AppointmentDay":$scope.M_AddEditApp.SelectedAppointmentDateStr.split(",")[0]
                    }
            		AppointmentService.getTimeSlotAndStateForTechnician(angular.toJson(timeSlotJSON)).then(function(successResult) {
                        $scope.M_AddEditApp.timeSlotJSON = successResult;
                    }, function(error) {
                        Notification.error($translate.instant('GENERIC_ERROR'));
                        $scope.M_AddEditApp.isLoading = false;
                    });
            }
            
            function setAppointmentDataWhenCreatingFromCO() {
            	$scope.M_AddEditApp.appointmentJSON =  $stateParams.AddEditAppointmentParams.SoInfo;
                var currentDate = moment().format($Global.SchedulingDateFormat);
                var TimeSlot =  moment().format("a");
                var SlotName;
                if(TimeSlot == 'am') {
            		SlotName = 'Morning'
                } else {
                  SlotName = 'Afternoon'
                }

                $scope.M_AddEditApp.SelectedAppointmentDate = currentDate;
                $scope.M_AddEditApp.selectedAppointmentSegment = TimeSlot === 'am' ? 0 : 1;
                $scope.M_AddEditApp.SelectedAppointmentDateStr = moment(currentDate, $Global.SchedulingDateFormat).format('dddd, Do MMMM YYYY') + " - " +  $translate.instant(SlotName);
                
                if($scope.M_AddEditApp.appointmentJSON.CusotmerId) {
                	getCustomerRecByCustomerId($scope.M_AddEditApp.appointmentJSON.CusotmerId);
                } else {
                	createCustomerCardInfoPayload();
                }
                if($scope.M_AddEditApp.appointmentJSON.COUId) {
                	$scope.F_AddEditApp.COUSaveCallback($scope.M_AddEditApp.appointmentJSON.CusotmerId, $scope.M_AddEditApp.appointmentJSON.COUId, false) ;
                }  
                setConcernsOnAppointmentRecord($stateParams.AddEditAppointmentParams.SoInfo.Concern, $stateParams.AddEditAppointmentParams.SoInfo.KitHeaderConcern, true);
            }
            
            /**
             * Set Concerns while Editng the appointment record from Scehduler or CO page 
             * Set Concerns while Creating the appointment record from CO Page
             * Set Concerns while Linking SO to appointment record
            */
            function setConcernsOnAppointmentRecord(concern, soKitConcern, isSOLinkedToAppointment) {
            	if(!isSOLinkedToAppointment) {
            		$scope.directivePayload.Tags = concern;
            		$scope.nonEditableConcern.Tags = [];
            	} else {
            		$scope.nonEditableConcern.Tags = concern;
            		$scope.nonEditableConcern.Tags = $scope.nonEditableConcern.Tags.concat(soKitConcern);
            		$scope.soManualConcerns = concern;
            		$scope.directivePayload.Tags = [];
            	}
            }
            
            function openAddEditAppModal() {
            	/**
            	 * When load customer or Unit Modal from this state, then after closing
            	 * those modal windows, previous state for 'AddEditAppointment'
            	 * becomes either 'AddEditAppointment.AddEditCustomerV2' or 'AddEditAppointment.AddEditUnitV2',
            	 * but we need 'A-View state name which is opened behind this modal window
            	*/
            	$scope.M_AddEditApp.previousStateName = $rootScope.$previousState.name; 
                $scope.M_AddEditApp.previousStateId  = $rootScope.$previousStateParams.Id;
                setTimeout(function() {
                    angular.element('#full-page-modal-window').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                     if($stateParams.AddEditAppointmentParams && $stateParams.AddEditAppointmentParams.isEdit) { // Update From Scheduler Page
                        $scope.M_AddEditApp.isEdit = $stateParams.AddEditAppointmentParams.isEdit;
                        setAppoitmentDetailInEdit($stateParams.AddEditAppointmentParams.appointmentData);
                    }  else { // Create From Scheduer/CO page or Update from CO Page
                        $scope.M_AddEditApp.isEdit = false; // Create From Scheduler Page
                        if($scope.M_AddEditApp.previousStateName === 'CustomerOrder_V2' && $stateParams.AddEditAppointmentParams) {
                            $scope.$evalAsync(function() {
                                $scope.M_AddEditApp.isLoading = true;
                            });
                            if($stateParams.AddEditAppointmentParams.eventJson) { // Update From CO Page
                                $scope.M_AddEditApp.isEdit = true;
                                setAppoitmentDetailInEdit($stateParams.AddEditAppointmentParams.eventJson);
                            } else if($stateParams.AddEditAppointmentParams.SoInfo) { // Create From CO Page
                            	setAppointmentDataWhenCreatingFromCO();
                            }
                            getAllTechnicianListData();
                        }
                    }
                    showTooltip('#full-page-modal-window');
                    $scope.M_AddEditApp.loadAddEditTextTagBlock = true;
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply();
                    }
                    
                    setTimeout(function() {
                    	 angular.element('#ConcernNewTag').blur();
                    }, 10);
                }, 100);
                $scope.$broadcast("resetIsClickedOnAddeditAppoitmentProgressBar");
            }
            $scope.F_AddEditApp.setFocusOnInput = function(elmId) {
                setTimeout(function(){
                    angular.element("#"+elmId).focus();
                },100);
            }
            $scope.F_AddEditApp.scrollTopDtopDown = function(elmId) {
                setTimeout(function(){
                angular.element("#"+elmId).scrollTop(0);
                },100);
            }

            function showTooltip(containerName) {
                angular.element('[role ="tooltip"]').hide();
                setTimeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: containerName
                    });
                }, 1000);
            }
            
            $scope.F_AddEditApp.deleteAppointment = function(appointmentId){
                console.log($scope.M_AddEditApp);
                AppointmentService.deleteAppointmentById(appointmentId).then(function(successResult) {
                    if(successResult == "SUCCESS"){
                        $scope.F_AddEditApp.closeAction(true);
                        Notification.success($translate.instant('Generic_Deleted')); 
                    }
                    else{

                    }
                }, function(error) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                    $scope.M_AddEditApp.isLoading = false;
                });
            }
            function setFlagToPreSelectDateString() {
            	if($stateParams.AddEditAppointmentParams && $stateParams.AddEditAppointmentParams.isLoadedByPlus) {
            		$scope.M_AddEditApp.isLoadedByPlus = true;
            	} else {
            		$scope.M_AddEditApp.isLoadedByPlus = false;
            	}
            }
            
            // Start: Link Service Job Modal Window
            $scope.F_AddEditApp.openLinkServiceJobModalWindow = function() {
            	angular.element("#LinkServiceJobModal")[0].scrollTop = 0;
                angular.element('#LinkServiceJobModal').modal({
                           backdrop: 'static',
                           keyboard: false
                       });
                angular.element('#LinkServiceJobModal').show();
                
                if($scope.F_AddEditApp.dirRefreshFnOnParamChange) {
                	setTimeout(function(){
                		$scope.F_AddEditApp.dirRefreshFnOnParamChange('linkedSoJobTypeId'); // Refresh directive(Autocompete_v2 - STA) on linked So Job Type Id change
                	}, 1);
                }
            }
            
            angular.element(document).on("click", "#LinkServiceJobModal .modal-backdrop", function() {
            	$scope.F_AddEditApp.hideLinkedServiceJobModal();
            });
            
            $scope.F_AddEditApp.hideLinkedServiceJobModal = function() {
            	angular.element('#LinkServiceJobModal').modal('hide');
                angular.element("body").removeClass("modal-open");
                angular.element("body").css("padding", "0px");
                $scope.M_AddEditApp.appointmentJSON.selectedSODescription = '';
                $scope.M_AddEditApp.appointmentJSON.selectedLinkedSORecord = '';
                $scope.M_AddEditApp.appointmentJSON.selectLinkedSOJobTypeLabel = '';
                $scope.M_AddEditApp.appointmentJSON.selectLinkedSOJobTypeId = '';
                $scope.M_AddEditApp.appointmentJSON.selectLinkedSOJobType = '';
            }
            
            $scope.F_AddEditApp.linkServiceJobToAppointmentRec = function(selectedLinkedSORecord) {
            	$scope.F_AddEditApp.hideLinkedServiceJobModal();
            	$scope.M_AddEditApp.appointmentJSON.Title = selectedLinkedSORecord.Description;
            	$scope.M_AddEditApp.appointmentJSON.selectedJobTypeLabel = selectedLinkedSORecord.Info; //Transaction type rec Code Label
            	$scope.M_AddEditApp.appointmentJSON.SOHeaderId = selectedLinkedSORecord.Id;
                 $scope.M_AddEditApp.appointmentJSON.CONumber = selectedLinkedSORecord.Name;
            	if(selectedLinkedSORecord && selectedLinkedSORecord.AdditionalInfoObj) {
            		setConcernsOnAppointmentRecord(selectedLinkedSORecord.AdditionalInfoObj.Concern, selectedLinkedSORecord.AdditionalInfoObj.KitConcern, true);
            		$scope.M_AddEditApp.appointmentJSON.selectedJobTypeId = selectedLinkedSORecord.AdditionalInfoObj.JobTypeId; //Transaction type rec Id
                	$scope.M_AddEditApp.appointmentJSON.selectedTransactionType = selectedLinkedSORecord.AdditionalInfoObj.JobType; //Transaction type rec Type
                	var cusotmerId = selectedLinkedSORecord.AdditionalInfoObj.CustomerId;
                	var unitId = selectedLinkedSORecord.AdditionalInfoObj.UnitId;
                    $scope.M_AddEditApp.appointmentJSON.COId = selectedLinkedSORecord.AdditionalInfoObj.COHeaderId;
                	if(cusotmerId) {
                		getCustomerRecByCustomerId(cusotmerId);
                	} else {
                		createCustomerCardInfoPayload();
                	}
                	if(unitId) {
            			$scope.F_AddEditApp.COUSaveCallback(cusotmerId, unitId, false) ;
                	}
            	}
            	
            	$scope.M_AddEditApp.isNewInputTagNotAvailableForConcern = true;
            }
            // End: Link Service Job Modal Window
            
            function loadAppointmentMasterData() {
            	AppointmentService.getJobTypeList().then(function(ttList) {
            		/**'Stock Unit', 'Quote' TT options would never be available on AddEditAppointment page; 
            		 * 'Deal Service' TT option would only and only be available when user performs Create Appointment 
            		 * action from CO Deal Service and in this case this option is not required in this list
            		 * as we set Job type data from CO itself which is non editable and never select from list
            		 * But 'Deal Service' & 'Stock Unit' TT option should always be available on Link SO modal winodw.
            		*/
            		$scope.M_AddEditApp.jobTypeList = _.filter(ttList, function(ttRec) {
            		    return (ttRec.Type !== 'Stock Unit' && ttRec.Type !== 'Deal Service' && ttRec.Type !== 'Quote' );
            		});
            		$scope.M_AddEditApp.jobTypeListForLinkSOModal = _.filter(ttList, function(ttRec) {
            		    return (ttRec.Type !== 'Quote');
            		});
                    
            		if($scope.M_AddEditApp.jobTypeList.length) {
            			$scope.M_AddEditApp.appointmentJSON.selectedJobTypeLabel = $scope.M_AddEditApp.jobTypeList[0].CodeLabel; //Transaction type rec Code Label
                    	$scope.M_AddEditApp.appointmentJSON.selectedJobTypeId = $scope.M_AddEditApp.jobTypeList[0].Id; //Transaction type rec Id
                    	$scope.M_AddEditApp.appointmentJSON.selectedTransactionType = $scope.M_AddEditApp.jobTypeList[0].Type; //Transaction type rec Type
                    }
            		openAddEditAppModal();
            	}, function(error) {
            		Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }
            
            loadAppointmentMasterData();
            setFlagToPreSelectDateString();
            
            /** It will set the refresh method of directive(Autocompete_v2 - STA) which would be 
             * called whenever there is any change in directive parameters 
             * 
             * and directive needs to be refreshed
            */
            $scope.F_AddEditApp.setDirRefreshFnForParamChange = function(directiveFn) {
                $scope.F_AddEditApp.dirRefreshFnOnParamChange = directiveFn;
            };
        }
    ])
});