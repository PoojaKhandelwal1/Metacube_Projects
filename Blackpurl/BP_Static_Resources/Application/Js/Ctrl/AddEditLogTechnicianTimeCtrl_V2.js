define(['Routing_AppJs_PK', 'AddEditLogTechnicianTimeServices_V2', 'JqueryUI', 'moment'], function (Routing_AppJs_PK, AddEditLogTechnicianTimeServices_V2, JqueryUI, moment) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditLogTechnicianTimeCtrl_V2', ['$scope', '$rootScope', '$state', '$stateParams', 'AddEditLogTechnicianTimeService', function ($scope, $rootScope, $state, $stateParams, AddEditLogTechnicianTimeService) {
        var Notification = injector.get("Notification");
        $scope.M_AddEditLTT = $scope.M_AddEditLTT || {};
        $scope.F_AddEditLTT = $scope.F_AddEditLTT || {};

        $scope.M_AddEditLTT.dateFormat = $Global.DateFormat;
        $scope.M_AddEditLTT.dateOptions = {
            maxDate: new Date,
            dateFormat: $scope.M_AddEditLTT.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };

        var success = function () {
            var self = this;
            this.arguments = arguments[0];
            this.calleeMethodName = arguments[0].calleeMethodName,
                this.callback = arguments[0].callback,
                this.handler = function (successResult) {
                    switch (self.calleeMethodName) {
                        case 'getTechnicianList':
                            handleGetTechnicianListResponse(successResult);
                            break;
                        case 'saveHourLogData':
                            handleSaveHourLogDataResponse(successResult);
                            break;
                        default:
                            break;
                    }
                    if (typeof self.callback === 'function') {
                        self.callback();
                    }
                }

            function handleGetTechnicianListResponse(technicianList) {
                $scope.M_AddEditLTT.TechnicianList = technicianList;
            }

            function handleSaveHourLogDataResponse(hourLogList) {
                if (hourLogList[0].HasError) {
                    Notification.error(hourLogList[0].ErrorMsg);
                    $scope.M_CO.isLoading = false;
                } else {
                    $scope.F_CO.logHourRecordSaveCallback(hourLogList, $scope.M_AddEditLTT.soHeaderIndex);
                    Notification.success($Label.Generic_Saved);
                    $scope.F_AddEditLTT.hideLogTechnicianTimeModal();
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                }
            }
        }

        //TODO Common handling
        var error = function (errorMessage) {
            this.handler = function (error) {
                $scope.M_CO.isLoading = false;
                if (!errorMessage) {
                    console.log(error);
                } else {
                    console.log(errorMessage);
                }
            }
        }

        $scope.F_AddEditLTT.setFocusOnElement = function (elementId) {
            angular.element("#" + elementId).focus();
        }

        function openLogTechnicianTimeModal() {
            setTimeout(function () {
                angular.element('#logTechnicianTimeModal').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                $scope.M_CO.isLoading = false;
            }, 100);
        }

        angular.element(document).on("click", "#logTechnicianTimeModal .modal-backdrop", function () {
            $scope.F_AddEditLTT.hideLogTechnicianTimeModal();
        });

        $scope.F_AddEditLTT.hideLogTechnicianTimeModal = function () {
            angular.element('#logTechnicianTimeModal').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            $scope.M_CO.isLoading = false;
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }

        function loadAddLogTechnicianTimeModalData(args) {
            $scope.M_AddEditLTT.isEditMode = false;
            $scope.M_AddEditLTT.soHeaderId = $stateParams.AddEditLogTechnicianTimeParams.soHeaderId;
            $scope.M_AddEditLTT.HourLogModel = {};
            $scope.M_AddEditLTT.HourLogModel.StartDate = moment().format($Global.SchedulingDateFormat);
            $scope.M_AddEditLTT.HourLogModel.NotesRequired = false;
            $scope.M_AddEditLTT.HourLogModel.SOHeaderId = $scope.M_AddEditLTT.soHeaderId;
            $scope.M_AddEditLTT.HourLogModel.TotalHours = 0;
            $scope.M_AddEditLTT.HourLogModelCopy = angular.copy($scope.M_AddEditLTT.HourLogModel);
            getTechnicianList();
            openLogTechnicianTimeModal();
        }

        function loadEditLogTechnicianTimeModalData() {
            $scope.M_AddEditLTT.isEditMode = true;
            $scope.M_AddEditLTT.soHeaderId = $stateParams.AddEditLogTechnicianTimeParams.soHeaderId;
            $scope.M_AddEditLTT.HourLogModel = $stateParams.AddEditLogTechnicianTimeParams.HourLogRec;
            $scope.M_AddEditLTT.HourLogModelCopy = angular.copy($scope.M_AddEditLTT.HourLogModel);
            getTechnicianList();
            openLogTechnicianTimeModal();
        }

        function getTechnicianList() {
            var successJson = {
                'calleeMethodName': 'getTechnicianList'
            };
            AddEditLogTechnicianTimeService.getTechnicianList().then(new success(successJson).handler, new error().handler);
        }

        $scope.F_AddEditLTT.selectTechnician = function (index) {
            if ($scope.M_AddEditLTT.TechnicianList && $scope.M_AddEditLTT.TechnicianList.length > 0) {
                $scope.M_AddEditLTT.HourLogModel.EmployeeName = $scope.M_AddEditLTT.TechnicianList[index].TechinicianName;
                $scope.M_AddEditLTT.HourLogModel.EmployeeId = $scope.M_AddEditLTT.TechnicianList[index].Id;
            }
        }

        function validateTime(timeVariable) {
            if (moment($scope.M_AddEditLTT.HourLogModel[timeVariable], 'h:mm A').format('h:mm A') == "Invalid date") {
                $scope.M_AddEditLTT.HourLogModel[timeVariable] = $scope.M_AddEditLTT.HourLogModelCopy[timeVariable];
            } else {
                if (timeVariable == 'TimeIn') {
                    if ($scope.M_AddEditLTT.HourLogModel['TimeOut'] != '' &&
                        $scope.M_AddEditLTT.HourLogModel['TimeOut'] != null &&
                        $scope.M_AddEditLTT.HourLogModel['TimeOut'] != undefined &&
                        moment($scope.M_AddEditLTT.HourLogModel['TimeIn'], 'h:mm A').diff(moment($scope.M_AddEditLTT.HourLogModel['TimeOut'], 'h:mm A'), 'minutes') > 0) {
                        $scope.M_AddEditLTT.HourLogModel[timeVariable] = $scope.M_AddEditLTT.HourLogModelCopy[timeVariable];
                    } else {
                        $scope.M_AddEditLTT.HourLogModel[timeVariable] = moment($scope.M_AddEditLTT.HourLogModel[timeVariable], 'h:mm A').format('h:mm A');
                        $scope.M_AddEditLTT.HourLogModelCopy = angular.copy($scope.M_AddEditLTT.HourLogModel);
                    }
                } else if (timeVariable == 'TimeOut') {
                    if ($scope.M_AddEditLTT.HourLogModel['TimeIn'] != '' &&
                        $scope.M_AddEditLTT.HourLogModel['TimeIn'] != null &&
                        $scope.M_AddEditLTT.HourLogModel['TimeIn'] != undefined &&
                        moment($scope.M_AddEditLTT.HourLogModel['TimeIn'], 'h:mm A').diff(moment($scope.M_AddEditLTT.HourLogModel['TimeOut'], 'h:mm A'), 'minutes') > 0) {
                        $scope.M_AddEditLTT.HourLogModel[timeVariable] = $scope.M_AddEditLTT.HourLogModelCopy[timeVariable];
                    } else {
                        $scope.M_AddEditLTT.HourLogModel[timeVariable] = moment($scope.M_AddEditLTT.HourLogModel[timeVariable], 'h:mm A').format('h:mm A');
                        $scope.M_AddEditLTT.HourLogModelCopy = angular.copy($scope.M_AddEditLTT.HourLogModel);
                    }
                } else {
                    $scope.M_AddEditLTT.HourLogModel[timeVariable] = moment($scope.M_AddEditLTT.HourLogModel[timeVariable], 'h:mm A').format('h:mm A');
                    $scope.M_AddEditLTT.HourLogModelCopy = angular.copy($scope.M_AddEditLTT.HourLogModel);
                }
            }
        }

        $scope.F_AddEditLTT.disablesaveHourLogBtn = function () {
            if (!$scope.M_AddEditLTT.HourLogModel.EmployeeName) {
                return true;
            }
            if (!$scope.M_AddEditLTT.HourLogModel.TimeIn) {
                return true;
            } else if (!$scope.M_AddEditLTT.HourLogModel.TimeOut) {
                return true;
            } else {
                return false;
            }
        }

        $scope.F_AddEditLTT.calculateTotalHours = function (timeVariable) {
            validateTime(timeVariable);
            if ($scope.M_AddEditLTT.HourLogModel.TimeIn && $scope.M_AddEditLTT.HourLogModel.TimeOut) {
                var timeOut = moment($scope.M_AddEditLTT.HourLogModel.TimeOut, "h:mm A");
                var timeIn = moment($scope.M_AddEditLTT.HourLogModel.TimeIn, "h:mm A");
                var timeDiff = timeOut.diff(timeIn, 'minutes');
                $scope.M_AddEditLTT.HourLogModel.TotalHours = Math.round((timeDiff / 60) * 100) / 100;
            }
        }

        $scope.F_AddEditLTT.saveHourLogData = function () {
            $scope.M_CO.isLoading = true;
            var successJson = {
                'calleeMethodName': 'saveHourLogData'
            };
            AddEditLogTechnicianTimeService.saveHourLog($scope.M_AddEditLTT.HourLogModel, $scope.M_AddEditLTT.coHeaderId).then(new success(successJson).handler, new error().handler);
        }

        function loadLogTechnicianTimeModalData() {
            var isEditMode = $stateParams.AddEditLogTechnicianTimeParams.isEditMode;
            $scope.M_AddEditLTT.coHeaderId = $stateParams.AddEditLogTechnicianTimeParams.coHeaderId;
            $scope.M_AddEditLTT.soHeaderIndex = $stateParams.AddEditLogTechnicianTimeParams.soHeaderIndex;
            if (isEditMode && isEditMode == true) {
                loadEditLogTechnicianTimeModalData($stateParams.AddEditLogTechnicianTimeParams);
            } else {
                loadAddLogTechnicianTimeModalData($stateParams.AddEditLogTechnicianTimeParams);
            }
        }

        loadLogTechnicianTimeModalData();
    }])
});