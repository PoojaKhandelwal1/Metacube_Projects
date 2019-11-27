define(['Routing_AppJs_PK', 'PayrollClockingServices', 'JqueryUI', 'moment', 'underscore_min'],
    function (Routing_AppJs_PK, PayrollClockingServices, JqueryUI, moment, underscore_min) {

        var injector = angular.injector(['ui-notification', 'ng']);
        Routing_AppJs_PK.controller('PayrollClockingCtrl', ['$scope', '$rootScope', '$state', 'PayrollClockingServices',
            function ($scope, $rootScope, $state, PayrollClockingServices) {
                var Notification = injector.get("Notification");
                if (!angular.isDefined($scope.PayrollClockingModel)) {
                    $scope.PayrollClockingModel = {};
                }

                $scope.PayrollClockingModel.dateFormat = $Global.DateFormat;
                $scope.PayrollClockingModel.ManagePayrollFromDateOptions = {
                    maxDate: new Date,
                    dateFormat: $scope.PayrollClockingModel.dateFormat,
                    showOtherMonths: true,
                    selectOtherMonths: true,
                    dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                };

                $scope.PayrollClockingModel.ManagePayrollToDateOptions = {
                    minDate: '',
                    maxDate: new Date,
                    dateFormat: $scope.PayrollClockingModel.dateFormat,
                    showOtherMonths: true,
                    selectOtherMonths: true,
                    dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                };
                $scope.PayrollClockingModel.isBlur = true;

                $scope.PayrollClockingModel.loadPayrollClockingPopupData = function () {
                    loadAllTimeClockingStaff();
                }

                function loadAllTimeClockingStaff() {
                    PayrollClockingServices.getAllTimeClockingStaff().then(function (successResult) {
                        $scope.PayrollClockingModel.viewChange = 'time clock';
                        $scope.PayrollClockingModel.TimeClockingStaffList = successResult;
                        openPayrollClockingPopup();
                    }, function (errorMessage) {
                        Notification.error(errorMessage);
                    });
                }

                function openPayrollClockingPopup() {
                    setTimeout(function () {
                        angular.element('#bp-payroll-clocking-id').modal({
                            backdrop: 'static',
                            keyboard: false
                        });
                    }, 100);
                }

                angular.element(document).on("click", "#bp-payroll-clocking-id .modal-backdrop", function () {
                    $scope.PayrollClockingModel.hidePayrollClockingPopup();
                });

                $scope.PayrollClockingModel.hidePayrollClockingPopup = function () {
                    angular.element("body").removeClass("modal-open");
                    angular.element(".click-back-drop").hide();
                    angular.element("body").css("padding", "0px");
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                }

                $scope.PayrollClockingModel.saveClockStatus = function (index) {
                    var TimeClockingStaffRecToSave = angular.toJson($scope.PayrollClockingModel.TimeClockingStaffList[index]);
                    var technicianId = $scope.PayrollClockingModel.TimeClockingStaffList[index].TechnicianId;
                    PayrollClockingServices.saveClockStatus(TimeClockingStaffRecToSave).then(function (successResult) {
                        var indexOriginal = _.findIndex(successResult, {
                            'TechnicianId': technicianId
                        });
                        $scope.PayrollClockingModel.TimeClockingStaffList[index] = successResult[indexOriginal];
                    }, function (errorMessage) {
                        Notification.error(errorMessage);
                    });
                }

                $scope.PayrollClockingModel.changeView = function (viewName) {
                    if (viewName == 'time clock') {
                        loadAllTimeClockingStaff();
                    } else if (viewName == 'manage') {
                        getInitialsOfManagePayrollClocking();
                        loadPayrollClockingEntries();
                    }
                }

                function getInitialsOfManagePayrollClocking() {
                    $scope.PayrollClockingModel.fromDate = moment().format($Global.SchedulingDateFormat);
                    $scope.PayrollClockingModel.toDate = moment().format($Global.SchedulingDateFormat);
                    $scope.PayrollClockingModel.ManagePayrollToDateOptions.minDate = $scope.PayrollClockingModel.fromDate;
                    $scope.PayrollClockingModel.EmployeeObj = {};
                    $scope.PayrollClockingModel.EmployeeObj.Name = '';
                    $scope.PayrollClockingModel.currentSelectedClockingStaffIndex = -1;
                    $scope.PayrollClockingModel.selectedClockingStaff = {};
                    createManagePayrollFilterJson();
                    $scope.PayrollClockingModel.createNewPayrollEntryDiv = false;
                    $scope.PayrollClockingModel.NewEntryEmployeeObj = {};
                    $scope.PayrollClockingModel.NewEntryEmployeeObj.Name = '';
                    $scope.PayrollClockingModel.newEntryCurrentSelectedClockingStaffIndex = -1;
                    $scope.PayrollClockingModel.newEntrySelectedClockingStaff = {};
                    $scope.PayrollClockingModel.newPayrollEntry = {};
                    $scope.PayrollClockingModel.newPayrollEntryCopy = {};
                    $scope.PayrollClockingModel.editManagePayrollEntry = -1;

                }

                function createManagePayrollFilterJson() {
                    $scope.PayrollClockingModel.ManagePayrollFilterJson = {
                        'StartDate': $scope.PayrollClockingModel.fromDate,
                        'EndDate': $scope.PayrollClockingModel.toDate,
                        'EmployeeId': $scope.PayrollClockingModel.selectedClockingStaff.TechnicianId
                    }

                    if ($scope.PayrollClockingModel.fromDate == undefined || $scope.PayrollClockingModel.fromDate == '' || $scope.PayrollClockingModel.fromDate == null) {
                        $scope.PayrollClockingModel.ManagePayrollFilterJson.StartDate = null;
                    }

                    if ($scope.PayrollClockingModel.toDate == undefined || $scope.PayrollClockingModel.toDate == '' || $scope.PayrollClockingModel.toDate == null) {
                        $scope.PayrollClockingModel.ManagePayrollFilterJson.toDate = null;
                    }

                    if ($scope.PayrollClockingModel.selectedClockingStaff.TechnicianId == undefined || $scope.PayrollClockingModel.selectedClockingStaff.TechnicianId == '' || $scope.PayrollClockingModel.selectedClockingStaff.TechnicianId == null) {
                        $scope.PayrollClockingModel.ManagePayrollFilterJson.EmployeeId = '';
                    }
                }

                function loadPayrollClockingEntries() {
                    PayrollClockingServices.getPayrollClockingEntries(angular.toJson($scope.PayrollClockingModel.ManagePayrollFilterJson)).then(function (successResult) {
                        $scope.PayrollClockingModel.viewChange = 'manage';
                        $scope.PayrollClockingModel.PayrollClockingEntries = successResult;
                        $scope.PayrollClockingModel.PayrollClockingEntriesCopy = angular.copy($scope.PayrollClockingModel.PayrollClockingEntries);
                        angular.element('[role ="tooltip"]').hide();
                        setTimeout(function () {
                            angular.element('[data-toggle="tooltip"]').tooltip({
                                placement: 'top',
                                container: '.pageContent'
                            });
                        }, 500);
                    }, function (errorMessage) {
                        Notification.error(errorMessage);
                    });
                }

                $scope.PayrollClockingModel.showDatePicker = function (event, Id) {
                    angular.element("#" + Id).focus();
                }

                $scope.PayrollClockingModel.setToDateFormate = function () {
                    $scope.PayrollClockingModel.ManagePayrollToDateOptions.minDate = $scope.PayrollClockingModel.fromDate;
                    if (moment($scope.PayrollClockingModel.toDate).diff(moment($scope.PayrollClockingModel.fromDate), 'days') < 0) {
                        $scope.PayrollClockingModel.toDate = $scope.PayrollClockingModel.fromDate;
                    }
                }

                $scope.PayrollClockingModel.getInitialsOnFocus = function () {
                    $scope.PayrollClockingModel.currentSelectedClockingStaffIndex = -1;
                    $scope.PayrollClockingModel.selectedClockingStaff = {};
                }

                $scope.PayrollClockingModel.changeSeletedclockingStaff = function (event) {
                    if ($scope.PayrollClockingModel.EmployeeObj.Name == '') {
                        $scope.PayrollClockingModel.getInitialsOnFocus();
                        createManagePayrollFilterJson();
                        loadPayrollClockingEntries();
                    }
                    var keyCode = event.which ? event.which : event.keyCode;
                    if (keyCode === 40) {
                        if (($scope.PayrollClockingModel.TimeClockingStaffList.length - 1) > $scope.PayrollClockingModel.currentSelectedClockingStaffIndex) {
                            $scope.PayrollClockingModel.currentSelectedClockingStaffIndex++;
                            angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#timeClockingStaffRec_' + $scope.PayrollClockingModel.currentSelectedClockingStaffIndex)[0].offsetTop - 100;
                        }
                    } else if (keyCode === 38) {
                        if ($scope.PayrollClockingModel.currentSelectedClockingStaffIndex > 0) {
                            $scope.PayrollClockingModel.currentSelectedClockingStaffIndex--;
                            angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#timeClockingStaffRec_' + $scope.PayrollClockingModel.currentSelectedClockingStaffIndex)[0].offsetTop - 100;
                        }
                    } else if (keyCode === 13) {
                        $scope.PayrollClockingModel.selectClockingstaff($scope.PayrollClockingModel.allUserList[$scope.PayrollClockingModel.currentSelectedClockingStaffIndex]);
                        $scope.PayrollClockingModel.isFocused = false;
                    }
                }
                $scope.PayrollClockingModel.selectClockingstaff = function (clockingStaffRec) {
                    $scope.PayrollClockingModel.selectedClockingStaff = clockingStaffRec;
                    setTimeout(function () {
                        $scope.PayrollClockingModel.EmployeeObj.Name = clockingStaffRec.TechnicianName;
                        if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                            $scope.$apply(); //TODO
                        }
                    }, 700);
                    $scope.PayrollClockingModel.currentSelectedClockingStaffIndex = -1;
                    $scope.PayrollClockingModel.loadPayrollClockingEntriesUsingFilter();
                }
                $scope.PayrollClockingModel.loadPayrollClockingEntriesUsingFilter = function () {
                    createManagePayrollFilterJson();
                    loadPayrollClockingEntries();
                }

                $scope.PayrollClockingModel.editManagePayrollEntries = function (index) {
                    $scope.PayrollClockingModel.editManagePayrollEntry = index;
                    setTimeout(function () {
                        angular.element("#TimeIn_" + index).focus();
                    }, 100);
                }

                $scope.PayrollClockingModel.validateTime = function (index, timeVariable) {

                    if (index == -1) {
                        if (moment($scope.PayrollClockingModel.newPayrollEntry[timeVariable], 'h:mm A').format('h:mm A') == "Invalid date") {
                            $scope.PayrollClockingModel.newPayrollEntry[timeVariable] = $scope.PayrollClockingModel.newPayrollEntryCopy[timeVariable];
                        } else {
                            if (timeVariable == 'TimeIn') {
                                if ($scope.PayrollClockingModel.newPayrollEntry['TimeOut'] != '' &&
                                    $scope.PayrollClockingModel.newPayrollEntry['TimeOut'] != null &&
                                    $scope.PayrollClockingModel.newPayrollEntry['TimeOut'] != undefined &&
                                    moment($scope.PayrollClockingModel.newPayrollEntry['TimeIn'], 'h:mm A').diff(moment($scope.PayrollClockingModel.newPayrollEntry['TimeOut'], 'h:mm A'), 'minutes') > 0) {
                                    $scope.PayrollClockingModel.newPayrollEntry[timeVariable] = $scope.PayrollClockingModel.newPayrollEntryCopy[timeVariable];
                                } else {
                                    $scope.PayrollClockingModel.newPayrollEntry[timeVariable] = moment($scope.PayrollClockingModel.newPayrollEntry[timeVariable], 'h:mm A').format('h:mm A');
                                    $scope.PayrollClockingModel.newPayrollEntryCopy = angular.copy($scope.PayrollClockingModel.newPayrollEntry);
                                }
                            } else if (timeVariable == 'TimeOut') {
                                if ($scope.PayrollClockingModel.newPayrollEntry['TimeIn'] != '' &&
                                    $scope.PayrollClockingModel.newPayrollEntry['TimeIn'] != null &&
                                    $scope.PayrollClockingModel.newPayrollEntry['TimeIn'] != undefined &&
                                    moment($scope.PayrollClockingModel.newPayrollEntry['TimeIn'], 'h:mm A').diff(moment($scope.PayrollClockingModel.newPayrollEntry['TimeOut'], 'h:mm A'), 'minutes') > 0) {
                                    $scope.PayrollClockingModel.newPayrollEntry[timeVariable] = $scope.PayrollClockingModel.newPayrollEntryCopy[timeVariable];
                                } else {
                                    $scope.PayrollClockingModel.newPayrollEntry[timeVariable] = moment($scope.PayrollClockingModel.newPayrollEntry[timeVariable], 'h:mm A').format('h:mm A');
                                    $scope.PayrollClockingModel.newPayrollEntryCopy = angular.copy($scope.PayrollClockingModel.newPayrollEntry);
                                }
                            } else {
                                $scope.PayrollClockingModel.newPayrollEntry[timeVariable] = moment($scope.PayrollClockingModel.newPayrollEntry[timeVariable], 'h:mm A').format('h:mm A');
                                $scope.PayrollClockingModel.newPayrollEntryCopy = angular.copy($scope.PayrollClockingModel.newPayrollEntry);
                            }
                        }
                    } else {
                        if (moment($scope.PayrollClockingModel.PayrollClockingEntries[index][timeVariable], 'h:mm A').format('h:mm A') == "Invalid date") {
                            $scope.PayrollClockingModel.PayrollClockingEntries[index][timeVariable] = $scope.PayrollClockingModel.PayrollClockingEntriesCopy[index][timeVariable];
                        } else {
                            if (timeVariable == 'TimeIn') {
                                if ($scope.PayrollClockingModel.PayrollClockingEntries[index]['TimeOut'] != '' &&
                                    $scope.PayrollClockingModel.PayrollClockingEntries[index]['TimeOut'] != null &&
                                    $scope.PayrollClockingModel.PayrollClockingEntries[index]['TimeOut'] != undefined &&
                                    moment($scope.PayrollClockingModel.PayrollClockingEntries[index]['TimeIn'], 'h:mm A').diff(moment($scope.PayrollClockingModel.PayrollClockingEntries[index]['TimeOut'], 'h:mm A'), 'minutes') > 0) {
                                    $scope.PayrollClockingModel.PayrollClockingEntries[index][timeVariable] = $scope.PayrollClockingModel.PayrollClockingEntriesCopy[index][timeVariable];
                                } else {
                                    $scope.PayrollClockingModel.PayrollClockingEntries[index][timeVariable] = moment($scope.PayrollClockingModel.PayrollClockingEntries[index][timeVariable], 'h:mm A').format('h:mm A');
                                }
                            } else if (timeVariable == 'TimeOut') {
                                if ($scope.PayrollClockingModel.PayrollClockingEntries[index]['TimeIn'] != '' &&
                                    $scope.PayrollClockingModel.PayrollClockingEntries[index]['TimeIn'] != null &&
                                    $scope.PayrollClockingModel.PayrollClockingEntries[index]['TimeIn'] != undefined &&
                                    moment($scope.PayrollClockingModel.PayrollClockingEntries[index]['TimeIn'], 'h:mm A').diff(moment($scope.PayrollClockingModel.PayrollClockingEntries[index]['TimeOut'], 'h:mm A'), 'minutes') > 0) {
                                    $scope.PayrollClockingModel.PayrollClockingEntries[index][timeVariable] = $scope.PayrollClockingModel.PayrollClockingEntriesCopy[index][timeVariable];
                                } else {
                                    $scope.PayrollClockingModel.PayrollClockingEntries[index][timeVariable] = moment($scope.PayrollClockingModel.PayrollClockingEntries[index][timeVariable], 'h:mm A').format('h:mm A');
                                }
                            } else {
                                $scope.PayrollClockingModel.PayrollClockingEntries[index][timeVariable] = moment($scope.PayrollClockingModel.PayrollClockingEntries[index][timeVariable], 'h:mm A').format('h:mm A');
                            }
                        }
                    }
                }
                $scope.PayrollClockingModel.saveManagePayrollEntry = function (index, payrollEntry, event, timeVariable) {
                    $scope.PayrollClockingModel.validateTime(index, timeVariable);
                    createManagePayrollFilterJson();
                    if (index != -1) {
                        focusedElement = event.relatedTarget;
                        if (focusedElement != undefined && focusedElement != '' && focusedElement != null) {
                            if (focusedElement.id == ('TimeIn_' + index) || focusedElement.id == ('TimeOut_' + index)) {
                                $scope.PayrollClockingModel.isBlur = false;
                            }
                        }
                        if (event.type == "blur" && !$scope.PayrollClockingModel.isBlur) {
                            event.preventDefault();
                            $scope.PayrollClockingModel.isBlur = true;
                            return;
                        }

                        if (event.type == "blur" && $scope.PayrollClockingModel.isBlur) {
                            PayrollClockingServices.savePayrollEntry(angular.toJson(payrollEntry), angular.toJson($scope.PayrollClockingModel.ManagePayrollFilterJson)).then(function (successResult) {
                                if (successResult[0].HasError != undefined && successResult[0].HasError != '' &&
                                    successResult[0].HasError != null && successResult[0].HasError == true) {
                                    Notification.error(successResult[0].ErrorMsg);


                                } else {
                                    $scope.PayrollClockingModel.PayrollClockingEntries[index] = successResult[0];
                                    $scope.PayrollClockingModel.PayrollClockingEntriesCopy = angular.copy($scope.PayrollClockingModel.PayrollClockingEntries);
                                    $scope.PayrollClockingModel.editManagePayrollEntry = -1;
                                }
                            }, function (errorMessage) {
                                Notification.error(errorMessage);
                            });
                        }
                    } else {
                        PayrollClockingServices.savePayrollEntry(angular.toJson(payrollEntry), angular.toJson($scope.PayrollClockingModel.ManagePayrollFilterJson)).then(function (successResult) {
                            if (successResult[0].HasError != undefined && successResult[0].HasError != '' &&
                                successResult[0].HasError != null && successResult[0].HasError == true) {
                                Notification.error(successResult[0].ErrorMsg);
                            } else {
                                $scope.PayrollClockingModel.PayrollClockingEntries[$scope.PayrollClockingModel.PayrollClockingEntries.length] = successResult[0];
                                $scope.PayrollClockingModel.PayrollClockingEntriesCopy = angular.copy($scope.PayrollClockingModel.PayrollClockingEntries);
                                $scope.PayrollClockingModel.cancelNewManagePayrollEntry();
                            }
                        }, function (errorMessage) {
                            Notification.error(errorMessage);
                        });
                    }
                }

                $scope.PayrollClockingModel.openDeleteConfirmationPopup = function (index) {
                    $scope.PayrollClockingModel.deletablePayrollClockingEntry = angular.copy($scope.PayrollClockingModel.PayrollClockingEntries[index]);
                }

                $scope.PayrollClockingModel.deletePayrollClockingEntry = function () {
                    var elementId = $scope.PayrollClockingModel.deletablePayrollClockingEntry.Id;
                    createManagePayrollFilterJson();
                    PayrollClockingServices.deletePayrollClockingEntry(elementId,
                        angular.toJson($scope.PayrollClockingModel.ManagePayrollFilterJson)).then(function (successResult) {

                        var deletedElement = angular.element('#' + elementId);
                        if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                            deletedElement.addClass('bp-collapse-deleted-div-transition');
                        }

                        setTimeout(function () {
                            $scope.PayrollClockingModel.PayrollClockingEntries = successResult;
                            $scope.PayrollClockingModel.PayrollClockingEntriesCopy = angular.copy($scope.PayrollClockingModel.PayrollClockingEntries);
                            angular.element('[role ="tooltip"]').hide();
                            setTimeout(function () {
                                angular.element('[data-toggle="tooltip"]').tooltip({
                                    placement: 'top',
                                    container: '.pageContent'
                                });
                            }, 500);
                            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                                $scope.$apply(); //TODO
                            }
                        }, 500);
                        $scope.PayrollClockingModel.deletablePayrollClockingEntry = {};
                    }, function (errorMessage) {
                        Notification.error(errorMessage);
                        $scope.PayrollClockingModel.deletablePayrollClockingEntry = {};
                    });
                }

                $scope.PayrollClockingModel.createManagePayrollEntry = function () {
                    $scope.PayrollClockingModel.createNewPayrollEntryDiv = true;
                    $scope.PayrollClockingModel.NewEntryEmployeeObj.Name = '';
                    $scope.PayrollClockingModel.newPayrollEntry = {};
                    $scope.PayrollClockingModel.getInitialsOfNewEntryOnFocus();
                }

                $scope.PayrollClockingModel.cancelNewManagePayrollEntry = function () {
                    $scope.PayrollClockingModel.createNewPayrollEntryDiv = false;
                    $scope.PayrollClockingModel.NewEntryEmployeeObj.Name = '';
                    $scope.PayrollClockingModel.newPayrollEntry = {};
                    $scope.PayrollClockingModel.getInitialsOfNewEntryOnFocus();
                }


                $scope.PayrollClockingModel.getInitialsOfNewEntryOnFocus = function () {
                    $scope.PayrollClockingModel.newEntryCurrentSelectedClockingStaffIndex = -1;
                    $scope.PayrollClockingModel.newEntrySelectedClockingStaff = {};

                }

                $scope.PayrollClockingModel.changeclockingStaffForNewPayrollEntry = function (event) {
                    var keyCode = event.which ? event.which : event.keyCode;
                    if (keyCode === 40) {
                        if (($scope.PayrollClockingModel.TimeClockingStaffList.length - 1) > $scope.PayrollClockingModel.newEntryCurrentSelectedClockingStaffIndex) {
                            $scope.PayrollClockingModel.newEntryCurrentSelectedClockingStaffIndex++;
                            angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#timeClockingStaffRec_' + $scope.PayrollClockingModel.newEntryCurrentSelectedClockingStaffIndex)[0].offsetTop - 100;
                        }
                    } else if (keyCode === 38) {
                        if ($scope.PayrollClockingModel.newEntryCurrentSelectedClockingStaffIndex > 0) {
                            $scope.PayrollClockingModel.newEntryCurrentSelectedClockingStaffIndex--;
                            angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#timeClockingStaffRec_' + $scope.PayrollClockingModel.newEntryCurrentSelectedClockingStaffIndex)[0].offsetTop - 100;
                        }
                    } else if (keyCode === 13) {
                        $scope.PayrollClockingModel.selectNewEntryClockingstaff($scope.PayrollClockingModel.allUserList[$scope.PayrollClockingModel.newEntryCurrentSelectedClockingStaffIndex]);
                        $scope.PayrollClockingModel.isFocusedNewEntrySearchInput = false;
                    }
                }

                $scope.PayrollClockingModel.selectNewEntryClockingstaff = function (clockingStaffRec) {
                    $scope.PayrollClockingModel.newEntrySelectedClockingStaff = clockingStaffRec;
                    setTimeout(function () {
                        $scope.PayrollClockingModel.NewEntryEmployeeObj.Name = clockingStaffRec.TechnicianName;
                        if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                            $scope.$apply(); //TODO
                        }
                    }, 700);
                    $scope.PayrollClockingModel.newEntryCurrentSelectedClockingStaffIndex = -1;
                }

                $scope.PayrollClockingModel.saveNewPayrollEntry = function () {
                    $scope.PayrollClockingModel.newPayrollEntry.TechnicianId = $scope.PayrollClockingModel.newEntrySelectedClockingStaff.TechnicianId;
                    $scope.PayrollClockingModel.saveManagePayrollEntry(-1, $scope.PayrollClockingModel.newPayrollEntry, null);
                }

                $scope.PayrollClockingModel.disableNewPayrollEntrySaveButton = function () {
                    if ($scope.PayrollClockingModel.newEntrySelectedClockingStaff.TechnicianId == '' ||
                        $scope.PayrollClockingModel.newEntrySelectedClockingStaff.TechnicianId == null ||
                        $scope.PayrollClockingModel.newEntrySelectedClockingStaff.TechnicianId == undefined ||
                        $scope.PayrollClockingModel.newPayrollEntry.StartDate == '' ||
                        $scope.PayrollClockingModel.newPayrollEntry.StartDate == null ||
                        $scope.PayrollClockingModel.newPayrollEntry.StartDate == undefined ||
                        $scope.PayrollClockingModel.newPayrollEntry.TimeIn == '' ||
                        $scope.PayrollClockingModel.newPayrollEntry.TimeIn == null ||
                        $scope.PayrollClockingModel.newPayrollEntry.TimeIn == undefined ||
                        $scope.PayrollClockingModel.newPayrollEntry.TimeOut == '' ||
                        $scope.PayrollClockingModel.newPayrollEntry.TimeOut == null ||
                        $scope.PayrollClockingModel.newPayrollEntry.TimeOut == undefined) {
                        return true;
                    }
                    return false;
                }
                $scope.PayrollClockingModel.loadPayrollClockingPopupData();
            }
        ]);
    });