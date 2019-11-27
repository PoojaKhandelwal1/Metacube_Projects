define(['Routing_AppJs_PK', 'LogServiceWorkPopWizardServices', 'dirNumberInput', 'moment'],
    function (Routing_AppJs_PK, LogServiceWorkPopWizardServices, dirNumberInput, moment) {
        $(document).ready(function () {
            $(".datepicker").datepicker();
            $('.btn').click(function () {
                $($(this).parent().find("input")).focus();
            });
        })
        var injector = angular.injector(['ui-notification', 'ng']);
        Routing_AppJs_PK.controller('LogServiceWorkPopWizardCtrl', ['$scope', '$rootScope', '$state', '$stateParams', 'AddEditHourLogService', 'LogServiceWorkService',
            function ($scope, $rootScope, $state, $stateParams, AddEditHourLogService, LogServiceWorkService) {
                var Notification = injector.get("Notification");

                if ($scope.AddEditHourLog == undefined) {
                    $scope.AddEditHourLog = {};
                    $scope.AddEditHourLog.HourLogModel = {};
                }
                $scope.AddEditHourLog.disableSaveButton = false;
                $scope.AddEditHourLog.dateFormat = $Global.DateFormat;
                $scope.dateOptions = {
                    dateFormat: $Global.DateFormat
                };
                $scope.AddEditHourLog.setDefaultValidationModel = function () {
                    $scope.AddEditHourLog.hourLogFormValidationModal = {
                        TimeSpent_H: {
                            isError: false,
                            ErrorMessage: '',
                            Type: 'Maxlength,Maxvalue,Numeric,Minvalue',
                            Maxlength: 2,
                            Maxvalue: 23,
                            Minvalue: 0
                        },
                        TimeSpent_M: {
                            isError: false,
                            ErrorMessage: '',
                            Type: 'Maxlength,Maxvalue,Numeric,Minvalue',
                            Maxlength: 2,
                            Maxvalue: 59,
                            Minvalue: 0
                        },
                        TimeSpent_D: {
                            isError: false,
                            ErrorMessage: '',
                            Type: 'Numeric,Minvalue',
                            Minvalue: 0

                        },
                        RemainingEstimate_D: {
                            isError: false,
                            ErrorMessage: '',
                            Type: 'Numeric,Minvalue',
                            Minvalue: 0

                        },
                        RemainingEstimate_H: {
                            isError: false,
                            ErrorMessage: '',
                            Type: 'Maxlength,Maxvalue,Numeric,Minvalue',
                            Maxlength: 2,
                            Maxvalue: 23,
                            Minvalue: 0

                        },
                        RemainingEstimate_M: {
                            isError: false,
                            ErrorMessage: '',
                            Type: 'Maxlength,Maxvalue,Numeric,Minvalue',
                            Maxlength: 2,
                            Maxvalue: 59,
                            Minvalue: 0

                        },


                        StartDate: {
                            isError: false,
                            ErrorMessage: '',
                            Type: 'Required',
                        },
                    };
                    $scope.AddEditHourLog.SimilarFee = [];
                }

                $scope.AddEditHourLog.helpText = {
                    Code: 'Fee Code',
                    Description: 'Fee Description',
                    FeePrices: 'Fee Prices',
                    FeeFixedRate: 'Fee Fixed Rate',
                    Price: 'Fee Rate, Required if Fixed Rate selected',
                    CategoryName: 'Fee Category',
                    FeeTaxable: 'Fee Taxable'
                }

                $scope.AddEditHourLog.showCalendar = function (IdVal) {
                    angular.element("#" + IdVal).focus();
                }
                $scope.AddEditHourLog.addNewHourLogService = function () {
                    $scope.AddEditHourLog.disableSaveButton = false;
                    $scope.AddEditHourLog.setDefaultValidationModel();
                    $scope.AddEditHourLog.clearAllData();
                    $scope.AddEditHourLog.isEditMode = false;
                    $scope.AddEditHourLog.openPopup();
                }
                $scope.$on('EditHourLogServiceEvent', function (event, logHourObject, coHeaderId, index) {
                    $scope.AddEditHourLog.setDefaultValidationModel();
                    $scope.AddEditHourLog.disableSaveButton = false;
                    $scope.AddEditHourLog.isEditMode = true;
                    $scope.AddEditHourLog.HourLogModel = logHourObject;
                    $scope.AddEditHourLog.HourLogModel.coHeaderId = coHeaderId;
                    $scope.AddEditHourLog.HourLogModel.index = index;
                    $scope.AddEditHourLog.getTechnicianList();
                    $scope.AddEditHourLog.openPopup();
                });
                $scope.$on('AddHourlogServiceEvent', function (event, logHourObject, coHeaderId, index) {
                    $scope.AddEditHourLog.disableSaveButton = false;
                    $scope.AddEditHourLog.HourLogModel = logHourObject;
                    $scope.AddEditHourLog.HourLogModel.coHeaderId = coHeaderId;
                    $scope.AddEditHourLog.HourLogModel.index = index;
                    $scope.AddEditHourLog.getTechnicianList();
                    $scope.AddEditHourLog.addNewHourLogService();
                });
                $scope.AddEditHourLog.clearAllData = function () {
                    $scope.AddEditHourLog.HourLogModel.StartDate = $scope.AddEditHourLog.HourLogModel.WorkPerformedDate = $scope.AddEditHourLog.getCurrentDate();
                    $scope.AddEditHourLog.HourLogModel.Notes = '';
                    $scope.AddEditHourLog.HourLogModel.TimeSpent_D = 0;
                    $scope.AddEditHourLog.HourLogModel.TimeSpent_M = 0;
                    $scope.AddEditHourLog.HourLogModel.TimeSpent_H = 0;
                    $scope.AddEditHourLog.HourLogModel.RemainingEstimate_D = 0;
                    $scope.AddEditHourLog.HourLogModel.RemainingEstimate_M = 0;
                    $scope.AddEditHourLog.HourLogModel.RemainingEstimate_H = 0;
                    $scope.AddEditHourLog.HourLogModel.NotesRequired = false;

                }

                $scope.AddEditHourLog.getCurrentDate = function () {
                    var today = new Date();
                    var dd = today.getDate();
                    var mm = today.getMonth() + 1;
                    var yyyy = today.getFullYear();
                    if (dd < 10) {
                        dd = '0' + dd
                    }
                    if (mm < 10) {
                        mm = '0' + mm
                    }
                    var today = mm + '/' + dd + '/' + yyyy;

                    return today;
                }
                $scope.AddEditHourLog.clearFields = function (key) {
                    $scope.AddEditHourLog.feeModel[key] = '';
                    $scope.AddEditHourLog.getSimilarFees(key);
                }
                $scope.AddEditHourLog.validateNumber = function (e) {
                    var key = e.keyCode ? e.keyCode : e.which;
                    if (!([8, 9, 13, 27, 46, 110, 190].indexOf(key) !== -1 ||
                            (key == 65 && (e.ctrlKey || e.metaKey)) ||
                            (key >= 35 && key <= 40) ||
                            (key >= 48 && key <= 57 && !(e.shiftKey || e.altKey)) ||
                            (key >= 96 && key <= 105)
                        )) e.preventDefault();

                }

                $scope.AddEditHourLog.validateTime = function (timeVariable) {
                    if (moment($scope.AddEditHourLog.HourLogModel[timeVariable], 'h:mm A').format('h:mm A') == "Invalid date") {
                        $scope.AddEditHourLog.HourLogModel[timeVariable] = $scope.AddEditHourLog.HourLogModelCopy[timeVariable];
                    } else {
                        if (timeVariable == 'TimeIn') {
                            if ($scope.AddEditHourLog.HourLogModel['TimeOut'] != '' &&
                                $scope.AddEditHourLog.HourLogModel['TimeOut'] != null &&
                                $scope.AddEditHourLog.HourLogModel['TimeOut'] != undefined &&
                                moment($scope.AddEditHourLog.HourLogModel['TimeIn'], 'h:mm A').diff(moment($scope.AddEditHourLog.HourLogModel['TimeOut'], 'h:mm A'), 'minutes') > 0) {
                                $scope.AddEditHourLog.HourLogModel[timeVariable] = $scope.AddEditHourLog.HourLogModelCopy[timeVariable];
                            } else {
                                $scope.AddEditHourLog.HourLogModel[timeVariable] = moment($scope.AddEditHourLog.HourLogModel[timeVariable], 'h:mm A').format('h:mm A');
                                $scope.AddEditHourLog.HourLogModelCopy = angular.copy($scope.AddEditHourLog.HourLogModel);
                            }
                        } else if (timeVariable == 'TimeOut') {
                            if ($scope.AddEditHourLog.HourLogModel['TimeIn'] != '' &&
                                $scope.AddEditHourLog.HourLogModel['TimeIn'] != null &&
                                $scope.AddEditHourLog.HourLogModel['TimeIn'] != undefined &&
                                moment($scope.AddEditHourLog.HourLogModel['TimeIn'], 'h:mm A').diff(moment($scope.AddEditHourLog.HourLogModel['TimeOut'], 'h:mm A'), 'minutes') > 0) {
                                $scope.AddEditHourLog.HourLogModel[timeVariable] = $scope.AddEditHourLog.HourLogModelCopy[timeVariable];
                            } else {
                                $scope.AddEditHourLog.HourLogModel[timeVariable] = moment($scope.AddEditHourLog.HourLogModel[timeVariable], 'h:mm A').format('h:mm A');
                                $scope.AddEditHourLog.HourLogModelCopy = angular.copy($scope.AddEditHourLog.HourLogModel);
                            }
                        } else {
                            $scope.AddEditHourLog.HourLogModel[timeVariable] = moment($scope.AddEditHourLog.HourLogModel[timeVariable], 'h:mm A').format('h:mm A');
                            $scope.AddEditHourLog.HourLogModelCopy = angular.copy($scope.AddEditHourLog.HourLogModel);
                        }
                    }
                }


                $scope.AddEditHourLog.saveHourLogData = function () {
                    if ($scope.AddEditHourLog.disableSaveButton) {
                        return;
                    }
                    $scope.AddEditHourLog.disableSaveButton = true;
                    if ($scope.AddEditHourLog.HourLogModel.EmployeeName == undefined || $scope.AddEditHourLog.HourLogModel.EmployeeName == '' ||
                        $scope.AddEditHourLog.HourLogModel.EmployeeName == null) {
                        Notification.error("Please select technician first");
                        $scope.AddEditHourLog.disableSaveButton = false;
                        return;
                    }

                    if (!$scope.AddEditHourLog.HourLogModel.TimeIn) {
                        Notification.error("Please enter time in");
                        $scope.AddEditHourLog.disableSaveButton = false;
                        return;
                    } else if (!$scope.AddEditHourLog.HourLogModel.TimeOut) {
                        Notification.error("Please enter time out");
                        $scope.AddEditHourLog.disableSaveButton = false;
                        return;
                    } else if ($scope.AddEditHourLog.validateTime('TimeIn') || $scope.AddEditHourLog.validateTime('TimeOut')) {
                        Notification.error("Please enter valid time");
                        $scope.AddEditHourLog.disableSaveButton = false;
                        return;
                    }

                    if ($scope.AddEditHourLog.HourLogModel.TimeSpent_H === undefined || $scope.AddEditHourLog.HourLogModel.TimeSpent_H === '' ||
                        $scope.AddEditHourLog.HourLogModel.TimeSpent_H === null) {
                        $scope.AddEditHourLog.HourLogModel.TimeSpent_H = 0;
                    } else if (isNaN($scope.AddEditHourLog.HourLogModel.TimeSpent_H)) {
                        Notification.error("Hours log should be number only");
                        $scope.AddEditHourLog.disableSaveButton = false;
                        return;
                    } else {
                        $scope.AddEditHourLog.HourLogModel.TimeSpent_H = (parseFloat($scope.AddEditHourLog.HourLogModel.TimeSpent_H)).toFixed(2);
                    }

                    var pieces = String($scope.AddEditHourLog.HourLogModel.TimeSpent_H).split(".");
                    if (pieces[0].length > 5) {
                        Notification.error("Hours log length should not be greater than 5 digits");
                        $scope.AddEditHourLog.disableSaveButton = false;
                        return;
                    }

                    AddEditHourLogService.saveHourLog($scope.AddEditHourLog.HourLogModel, $scope.AddEditHourLog.HourLogModel.coHeaderId).then(function (hourLogList) {
                        if (hourLogList[0].HasError) {
                            Notification.error(hourLogList[0].ErrorMsg);
                            $scope.AddEditHourLog.disableSaveButton = false;
                        } else {
                            if ($scope.$parent.logHourRecordSaveCallback != undefined) {
                                $scope.$parent.logHourRecordSaveCallback(hourLogList, $scope.AddEditHourLog.HourLogModel.index);
                                Notification.success($Label.Generic_Saved);
                            }
                            $scope.AddEditHourLog.closePopup();
                            hideModelWindow();
                            loadState($state, $rootScope.$previousState.name, {
                                Id: $rootScope.$previousStateParams.Id
                            });
                        }
                    }, function (errorSearchResult) {
                        $scope.AddEditHourLog.disableSaveButton = false;
                        Notification.error($Label.Page_Server_Save_Error);
                    });
                }


                $scope.AddEditHourLog.closePopup = function () {
                    angular.element('#logservice').modal('hide');
                    setTimeout(function () {
                        $scope.AddEditHourLog.disableSaveButton = false;
                    }, 100);
                }

                $scope.AddEditHourLog.closePopup1 = function () {
                    angular.element('#logservice').modal('hide');
                    setTimeout(function () {
                        $scope.AddEditHourLog.disableSaveButton = false;
                    }, 100);
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                }

                $scope.AddEditHourLog.keydownevent = function (event) {
                    if (!event.shiftKey && event.keyCode == 9) {
                        event.preventDefault();
                        angular.element('#closemodalup').focus();
                    }
                };
                $scope.AddEditHourLog.openPopup = function () {
                    setTimeout(function () {
                        angular.element('#logservice').modal({
                            backdrop: 'static',
                            keyboard: false
                        });
                    }, 1000);
                }
                $scope.AddEditHourLog.setCurrentTechnician = function (technicianId) {
                    if ($scope.AddEditHourLog.TechnicianList != undefined) {
                        for (var i = 0; i < $scope.AddEditHourLog.TechnicianList.length; i++) {
                            if ($scope.AddEditHourLog.TechnicianList[i].Id == technicianId) {
                                $scope.AddEditHourLog.HourLogModel.EmployeeId = technicianId;
                                $scope.AddEditHourLog.HourLogModel.EmployeeName = $scope.AddEditHourLog.TechnicianList[i].TechinicianName;
                                angular.element('#hoursLoggedPopupUserAutoComplete').removeClass('open');
                            }
                        }
                    }
                }
                $scope.AddEditHourLog.getTechnicianList = function () {
                    LogServiceWorkService.getTechnicianList()
                        .then(function (technicianList) {
                            $scope.AddEditHourLog.TechnicianList = technicianList;
                        }, function (errorSearchResult) {
                            Notification.error($Label.Page_Server_Save_Error);
                        });
                }

                $scope.AddEditHourLog.showTechnicianList = function (e) {
                    if (!(angular.element('#hoursLoggedPopupUserAutoComplete').hasClass('open'))) {
                        e.stopPropagation();
                        if ($scope.AddEditHourLog.TechnicianList != undefined && $scope.AddEditHourLog.TechnicianList.length > 0) {
                            angular.element('#hoursLoggedPopupUserAutoComplete').addClass('open');
                        } else {
                            Notification.error("No technicians available");
                        }
                    } else {
                        angular.element('#hoursLoggedPopupUserAutoComplete').removeClass('open');
                    }
                }
                $scope.AddEditHourLog.setDefaultValidationModel();
                $scope.AddEditHourLog.AddHourlogServiceEvent = function (args) {
                    $scope.AddEditHourLog.disableSaveButton = false;
                    $scope.AddEditHourLog.HourLogModel = args.logHourObject;
                    $scope.AddEditHourLog.HourLogModelCopy = angular.copy($scope.AddEditHourLog.HourLogModel);
                    $scope.AddEditHourLog.HourLogModel.coHeaderId = args.coHeaderId;
                    $scope.AddEditHourLog.HourLogModel.index = args.index;
                    $scope.AddEditHourLog.getTechnicianList();
                    $scope.AddEditHourLog.addNewHourLogService();
                }
                $scope.AddEditHourLog.EditHourLogServiceEvent = function (args) {
                    $scope.AddEditHourLog.disableSaveButton = false;
                    $scope.AddEditHourLog.setDefaultValidationModel();
                    $scope.AddEditHourLog.isEditMode = true;
                    $scope.AddEditHourLog.HourLogModel = args.logHourObject;
                    $scope.AddEditHourLog.HourLogModelCopy = angular.copy($scope.AddEditHourLog.HourLogModel);
                    $scope.AddEditHourLog.HourLogModel.coHeaderId = args.coHeaderId;
                    $scope.AddEditHourLog.HourLogModel.index = args.index;
                    $scope.AddEditHourLog.getTechnicianList();
                    $scope.AddEditHourLog.openPopup();
                }
                $scope.AddEditHourLog.openHourlogServicePopup = function () {
                    var isEditMode = $stateParams.HourlogParams.isEditMode;
                    if (isEditMode != undefined && isEditMode != null && isEditMode != '' && isEditMode == true) {
                        $scope.AddEditHourLog.EditHourLogServiceEvent($stateParams.HourlogParams);
                    } else {
                        $scope.AddEditHourLog.AddHourlogServiceEvent($stateParams.HourlogParams);
                    }
                }
                $scope.AddEditHourLog.openHourlogServicePopup();
            }
        ]);
    });