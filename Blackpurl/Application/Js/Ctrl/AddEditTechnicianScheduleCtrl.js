'use strict';
define(['Routing_AppJs_PK', 'AutoComplete_V2', 'JqueryUI', 'AddEditTechnicianScheduleServices', 'moment', 'underscore_min'], function(Routing_AppJs_PK, AutoComplete_V2, JqueryUI, AddEditTechnicianScheduleServices, moment, underscore_min) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditTechnicianScheduleCtrl', ['$scope', '$q', '$rootScope', '$state', '$stateParams', '$translate', '$filter', 'AddEditTechnicianScheduleService', '$document', function($scope, $q, $rootScope, $state, $stateParams, $translate, $filter, AddEditTechnicianScheduleService, $document) {
        var Notification = injector.get("Notification");
        /*Variables declaration*/
        $scope.M_AddEditTechSchedule = {};
        $scope.F_AddEditTechSchedule = {};
        setLoadingFlag(true);
        $scope.M_AddEditTechSchedule.showSelectedList = false;
        $scope.M_AddEditTechSchedule.Role = 'Technician';
        $scope.M_AddEditTechSchedule.dateFormat = $Global.DateFormat;
        $scope.M_AddEditTechSchedule.dateFormatMoment = $Global.SchedulingDateFormat;
        $scope.M_AddEditTechSchedule.createNewLevaeRec = {};
        $scope.M_AddEditTechSchedule.LeaveDetailJSON = {};
        $scope.M_AddEditTechSchedule.TimeSlot = [];
        $document.click(function(e) {
            // check that your clicked element has no id=globalSearchStrInput
            if ($scope.M_AddEditTechSchedule.isFromTimeDropdownVisible) {
                if (e.target.id != 'fromTime') {
                    $scope.M_AddEditTechSchedule.isFromTimeDropdownVisible = false;
                    $scope.M_AddEditTechSchedule.fromTimeCurrentIndex = -1;
                }
            }
            if ($scope.M_AddEditTechSchedule.isToTimeDropdownVisible) {
                if (e.target.id != 'toTime') {
                    $scope.M_AddEditTechSchedule.isToTimeDropdownVisible = false;
                    $scope.M_AddEditTechSchedule.toTimeCurrentIndex = -1;
                }
            }
        });
        $scope.M_AddEditTechSchedule.FromDateOptions = {
            dateFormat: $scope.M_AddEditTechSchedule.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };
        $scope.M_AddEditTechSchedule.ToDateOptions = {
            minDate: '',
            dateFormat: $scope.M_AddEditTechSchedule.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };
        $scope.M_AddEditTechSchedule.weekDays = [{
            day: 'Every business day',
            isSelected: true
        }];
        $scope.M_AddEditTechSchedule.currentTechnicianId = $stateParams.AddEditTechnicianScheduleParams.TechnicianId;
        $scope.F_AddEditTechSchedule.displayWorkingDayList = function() {
            $scope.M_AddEditTechSchedule.showWorkingDayList = true;
        }

        function selectAllWorkingDayArray() {
            return $scope.M_AddEditTechSchedule.weekDays.map(function(item, index) {
                item.isSelected = true;
                return item;
            });
        }
        $scope.F_AddEditTechSchedule.selectAllWorkingDays = function() {
            if ($scope.M_AddEditTechSchedule.weekDays[0].isSelected) {
                $scope.M_AddEditTechSchedule.weekDays = selectAllWorkingDayArray();
                return;
            }
        }
        
        function setLoadingFlag(booleanVal) {
        	if($state.current.name.indexOf('User') > -1) {
            	$scope.UserModel.isLoading = booleanVal;
            } else if($state.current.name.indexOf('TechScheduler.JobScheduler') > -1) {
            	$scope.M_JobScheduler.isLoading = booleanVal;
            }
        }
        
        $scope.F_AddEditTechSchedule.updateWorkingDayString = function(indexOfLineItem) {
            if (indexOfLineItem === 0 && $scope.M_AddEditTechSchedule.weekDays[0].isSelected) {
                $scope.M_AddEditTechSchedule.weekDays = selectAllWorkingDayArray();
                $scope.M_AddEditTechSchedule.selectedDay = $scope.M_AddEditTechSchedule.weekDays[0].day;
                return;
            }
            var index = _.findIndex($scope.M_AddEditTechSchedule.weekDays.slice(1), { // slice becoz the 0 th index value is meant only for display purpose 
                'isSelected': false
            });
            if (index > -1) {
                $scope.M_AddEditTechSchedule.weekDays[0].isSelected = false;
                $scope.M_AddEditTechSchedule.selectedDay = getDaysStringFromWorkingDays();
            } else {
                $scope.M_AddEditTechSchedule.weekDays[0].isSelected = true;
                $scope.M_AddEditTechSchedule.selectedDay = $scope.M_AddEditTechSchedule.weekDays[0].day; // assign the value for all 
            }
        }

        function getDaysStringFromWorkingDays() {
            var selectedDaysCSV = $scope.M_AddEditTechSchedule.weekDays.slice(1).reduce(getSelectedDaysCSV, "");
            return selectedDaysCSV.substring(0, selectedDaysCSV.length - 2);
        }
        $scope.F_AddEditTechSchedule.isOnlySelectedCheckbox = function(index) {
            if ($scope.M_AddEditTechSchedule.weekDays[0].isSelected != true && $scope.M_AddEditTechSchedule.weekDays[index].isSelected == true) {
                if ($scope.M_AddEditTechSchedule.selectedDay.includes(',')) {
                    return false;
                } else {
                    return true;
                }
            } else {
                return false;
            }
        }
        angular.element(document).on("click", "#techSchedulingPopup .modal-backdrop", function() {
            $scope.F_AddEditTechSchedule.hideAddEditCustomerModal();
        });
        $scope.F_AddEditTechSchedule.hideAddEditCustomerModal = function(isReloadData) {
            angular.element('#techSchedulingPopup').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            
            if(isReloadData && $state.current.name.indexOf('TechScheduler.JobScheduler') > -1) {
            	$scope.F_JobScheduler.saveTechnicianCallback();
            } else {
            	setLoadingFlag(false);
            }
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.F_AddEditTechSchedule.setToDateFormate = function() {
            $scope.M_AddEditTechSchedule.ToDateOptions.minDate = $scope.M_AddEditTechSchedule.createNewLevaeRec.fromDate;
            if (moment($scope.M_AddEditTechSchedule.createNewLevaeRec.toDate, $scope.M_AddEditTechSchedule.dateFormatMoment).diff(moment($scope.M_AddEditTechSchedule.createNewLevaeRec.fromDate, $scope.M_AddEditTechSchedule.dateFormatMoment), 'days') < 0) {
                $scope.M_AddEditTechSchedule.createNewLevaeRec.toDate = $scope.M_AddEditTechSchedule.createNewLevaeRec.fromDate;
            }
        }
        $scope.M_AddEditTechSchedule.TechnicianDetailObject = {};
        $scope.M_AddEditTechSchedule.currentTechnicianId = $stateParams.AddEditTechnicianScheduleParams.CurrentTechId;
        $scope.F_AddEditTechSchedule.displayWorkingDayList = function() {
            $scope.M_AddEditTechSchedule.showWorkingDayList = true;
        }
        $scope.F_AddEditTechSchedule.getTechnicianById = function(technicianId) {
            AddEditTechnicianScheduleService.getTechnicianById(technicianId).then(function(successResult) {
                $scope.M_AddEditTechSchedule.TechnicianDetailObject = successResult;
                createWorkingDays($scope.M_AddEditTechSchedule.TechnicianDetailObject.WorkingDays);
                if (!$scope.M_AddEditTechSchedule.TechnicianDetailObject.Role) {
                    $scope.M_AddEditTechSchedule.TechnicianDetailObject.Role = "Technician";
                }
                loadTechnicianLeaves();
            }, function(errorMessage) {
                Notification.error($translate.instant('GENERIC_ERROR'));
                setLoadingFlag(false);
            });
        }
        $scope.M_AddEditTechSchedule.createNewLevaeRecCopy = {};
        $scope.F_AddEditTechSchedule.createLevaeRec = function() {
            $scope.M_AddEditTechSchedule.createNewLevaeRec = {};
            $scope.M_AddEditTechSchedule.createNewLevaeRec.Type = 'Day off';
            $scope.M_AddEditTechSchedule.createNewLevaeRec.FromTime = '8:00AM';
            $scope.M_AddEditTechSchedule.createNewLevaeRec.ToTime = '5:00PM';
            $scope.M_AddEditTechSchedule.createNewLevaeRec.fromDate = moment().format($scope.M_AddEditTechSchedule.dateFormatMoment);
            $scope.M_AddEditTechSchedule.createNewLevaeRec.toDate = moment().format($scope.M_AddEditTechSchedule.dateFormatMoment);
            $scope.M_AddEditTechSchedule.showCreateLogRow = true;
            $scope.M_AddEditTechSchedule.createNewLevaeRecCopy = angular.copy($scope.M_AddEditTechSchedule.createNewLevaeRec);
        }

        function createWorkingDays(WorkingDays) {
            if (WorkingDays) {
                for (var i = 0; i < $scope.M_AddEditTechSchedule.weekDays.length; i++) {
                    $scope.M_AddEditTechSchedule.weekDays[i].isSelected = WorkingDays.indexOf($scope.M_AddEditTechSchedule.weekDays[i].day) > -1 ? true : false
                }
            }
            $scope.F_AddEditTechSchedule.updateWorkingDayString();
        }

        function loadTechnicianLeaves(isReloadData) {
            AddEditTechnicianScheduleService.getTechnicianLeaves($scope.M_AddEditTechSchedule.currentTechnicianId).then(function(successResult) {
                $scope.M_AddEditTechSchedule.LeaveDetailJSON = successResult;
                if(isReloadData && $state.current.name.indexOf('TechScheduler.JobScheduler') > -1) {
                	$scope.F_JobScheduler.saveTechnicianCallback();
                } else {
                	setLoadingFlag(false);
                }
            }, function(errorMessage) {
            	setLoadingFlag(false);
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }

        function getSelectedDaysCSV(joiner, dayObj) {
            joiner += (dayObj.isSelected) ? dayObj.day + ", " : "";
            return joiner;
        }
        $scope.F_AddEditTechSchedule.loadMasterData = function() {
            AddEditTechnicianScheduleService.getMasterData().then(function(successResult) {
                var listOfWeekDays = successResult;
                for (var i = 0; i < listOfWeekDays.length; i++) {
                    $scope.M_AddEditTechSchedule.weekDays.push({
                        day: listOfWeekDays[i],
                        isSelected: true
                    });
                }
            }, function(errorMessage) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.F_AddEditTechSchedule.saveLeaveDetail = function() {
            $scope.M_AddEditTechSchedule.showCreateLogRow = false;
            setLoadingFlag(true);
            $scope.M_AddEditTechSchedule.createNewLevaeRec.TechnicianId = $scope.M_AddEditTechSchedule.currentTechnicianId;
            AddEditTechnicianScheduleService.saveLeaveDetail(angular.toJson($scope.M_AddEditTechSchedule.createNewLevaeRec)).then(function(successResult) {
                $scope.M_AddEditTechSchedule.LeaveDetailJSON.push(successResult);
                if($state.current.name.indexOf('TechScheduler.JobScheduler') > -1) {
                	$scope.F_JobScheduler.saveTechnicianCallback();
                } else {
                	setLoadingFlag(false);
                }
            }, function(errorMessage) {
            	setLoadingFlag(false);
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.F_AddEditTechSchedule.setCurrentTime = function(timeValue, type) {
            if (type == 'FromTime') {
                $scope.M_AddEditTechSchedule.createNewLevaeRec.FromTime = timeValue;
            } else {
                $scope.M_AddEditTechSchedule.createNewLevaeRec.ToTime = timeValue;
            }
        }
        $scope.F_AddEditTechSchedule.validateTime = function(timeValue, timeVariable) {
            $scope.F_AddEditTechSchedule.setCurrentTime(timeValue, timeVariable);
            var fromTimeVal = moment($scope.M_AddEditTechSchedule.createNewLevaeRec['FromTime'], 'h:mma');
            var toTimeVal = moment($scope.M_AddEditTechSchedule.createNewLevaeRec['ToTime'], 'h:mma');
            if ($scope.M_AddEditTechSchedule.createNewLevaeRec[timeVariable] == "Invalid date") {
                $scope.M_AddEditTechSchedule.createNewLevaeRec[timeVariable] = $scope.M_AddEditTechSchedule.createNewLevaeRecCopy[timeVariable];
            } else {
                if (timeVariable == 'FromTime') {
                    if ($scope.M_AddEditTechSchedule.createNewLevaeRec['ToTime'] && !fromTimeVal.isBefore(toTimeVal)) {
                        $scope.M_AddEditTechSchedule.createNewLevaeRec[timeVariable] = $scope.M_AddEditTechSchedule.createNewLevaeRecCopy[timeVariable];
                    } else {
                        $scope.M_AddEditTechSchedule.createNewLevaeRec[timeVariable] = $scope.M_AddEditTechSchedule.createNewLevaeRec[timeVariable];
                        $scope.M_AddEditTechSchedule.createNewLevaeRecCopy = angular.copy($scope.M_AddEditTechSchedule.createNewLevaeRec);
                    }
                } else if (timeVariable == 'ToTime') {
                    if (!fromTimeVal.isBefore(toTimeVal)) {
                        $scope.M_AddEditTechSchedule.createNewLevaeRec[timeVariable] = $scope.M_AddEditTechSchedule.createNewLevaeRecCopy[timeVariable];
                    } else {
                        $scope.M_AddEditTechSchedule.createNewLevaeRec[timeVariable] = $scope.M_AddEditTechSchedule.createNewLevaeRec[timeVariable];
                        $scope.M_AddEditTechSchedule.createNewLevaeRecCopy = angular.copy($scope.M_AddEditTechSchedule.createNewLevaeRec);
                    }
                } else {
                    $scope.M_AddEditTechSchedule.createNewLevaeRec[timeVariable] = $scope.M_AddEditTechSchedule.createNewLevaeRec[timeVariable];
                    $scope.M_AddEditTechSchedule.createNewLevaeRecCopy = angular.copy($scope.M_AddEditTechSchedule.createNewLevaeRec);
                }
            }
        }
        $scope.F_AddEditTechSchedule.hideTimeList = function(event) {
            if (event.which == 9) {
                if (event.target.id === 'fromTime') {
                    $scope.M_AddEditTechSchedule.isFromTimeDropdownVisible = false;
                    $scope.M_AddEditTechSchedule.fromTimeCurrentIndex = -1;
                } else if (event.target.id === 'toTime') {
                    $scope.M_AddEditTechSchedule.isToTimeDropdownVisible = false;
                    $scope.M_AddEditTechSchedule.toTimeCurrentIndex = -1;
                }
            }
        }
        $scope.F_AddEditTechSchedule.showDatePicker = function(event, Id) {
            angular.element("#" + Id).focus();
        }
        $scope.F_AddEditTechSchedule.keyBoardavigation = function(event, dataList, dropDownName) {
            var keyCode = event.which ? event.which : event.keyCode;
            var dropDownDivId = '#' + dropDownName + 'DropDown';
            var indexName = dropDownName + 'CurrentIndex';
            if ($scope.M_AddEditTechSchedule[indexName] == undefined || isNaN($scope.M_AddEditTechSchedule[indexName])) {
                $scope.M_AddEditTechSchedule[indexName] = -1;
            }
            if (keyCode == 40 && dataList != undefined && dataList != '') {
                if (dataList.length - 1 > $scope.M_AddEditTechSchedule[indexName]) {
                    $scope.M_AddEditTechSchedule[indexName]++;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_AddEditTechSchedule[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode === 38 && dataList != undefined && dataList != '') {
                if ($scope.M_AddEditTechSchedule[indexName] > 0) {
                    $scope.M_AddEditTechSchedule[indexName]--;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_AddEditTechSchedule[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode == 13) {
                if (dropDownName == 'toTime') {
                    $scope.F_AddEditTechSchedule.validateTime(dataList[$scope.M_AddEditTechSchedule[indexName]], 'ToTime');
                    $scope.M_AddEditTechSchedule.isToTimeDropdownVisible = false;
                } else if (dropDownName == 'fromTime') {
                    $scope.F_AddEditTechSchedule.validateTime(dataList[$scope.M_AddEditTechSchedule[indexName]], 'FromTime');
                    $scope.M_AddEditTechSchedule.isFromTimeDropdownVisible = false;
                }
                $scope.M_AddEditTechSchedule[indexName] = -1;
            }
        }
        $scope.F_AddEditTechSchedule.validateFieldWithKey = function(key) {
            var fieldValue = $scope.M_AddEditTechSchedule.createNewLevaeRec[key]
            if (moment(fieldValue, 'h:mmA').format('h:mmA') == "Invalid date") {} else {
                $scope.M_AddEditTechSchedule.createNewLevaeRec[key] = moment(fieldValue, 'h:mmA').format('h:mmA');
            }
        }
        $scope.F_AddEditTechSchedule.deleteLeave = function(leaveId) {
            setLoadingFlag(true);
            AddEditTechnicianScheduleService.deleteLeave(leaveId).then(function(successResult) {
                loadTechnicianLeaves(true);
            }, function(errorMessage) {
            	setLoadingFlag(false);
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.F_AddEditTechSchedule.saveTechnicianDetail = function() {
            setLoadingFlag(true);
            if ($scope.M_AddEditTechSchedule.selectedDay.toLowerCase() != 'Every business day'.toLowerCase()) {
                $scope.M_AddEditTechSchedule.TechnicianDetailObject.WorkingDays = ($scope.M_AddEditTechSchedule.selectedDay).split(", ").join(";");
            } else {
                $scope.M_AddEditTechSchedule.TechnicianDetailObject.WorkingDays = getDaysStringFromWorkingDays().split(", ").join(";");
            }
            AddEditTechnicianScheduleService.saveTechnicianDetail(angular.toJson($scope.M_AddEditTechSchedule.TechnicianDetailObject)).then(function(successResult) {
                $scope.F_AddEditTechSchedule.hideAddEditCustomerModal(true);
            }, function(errorMessage) {
            	setLoadingFlag(false);
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.F_AddEditTechSchedule.showTimeList = function(type) {
            if (type == 'from') {
                $scope.M_AddEditTechSchedule.isFromTimeDropdownVisible = true;
                $scope.M_AddEditTechSchedule.fromTimeCurrentIndex = -1;
                var fromDropDown = angular.element('#fromTimeDropDown');
                setTimeout(function() {
                    fromDropDown[0].scrollTop = 0;
                }, 10);
            } else {
                $scope.M_AddEditTechSchedule.isToTimeDropdownVisible = true;
                $scope.M_AddEditTechSchedule.toTimeCurrentIndex = -1;
                var fromDropDown = angular.element('#toTimeDropDown');
                setTimeout(function() {
                    fromDropDown[0].scrollTop = 0;
                }, 10);
            }
        }
        $scope.M_AddEditTechSchedule.selectedDay = 'Every Business Day';
        $scope.F_AddEditTechSchedule.setFocusOnInput = function(elementId) {
            setTimeout(function() {
                angular.element("#" + elementId).focus();
            }, 100);
        }

        function createTimeDropDown() {
            var timevalue = "23:45";
            var datevalue = moment().format($Global.SchedulingDateFormat);
            for (var i = 0; i < 96; i++) {
                var time = moment(datevalue + ' ' + timevalue,  $Global.SchedulingDateFormat +' HH:mm:ss');
                var newTime = moment(time).add(15, 'minutes');
                $scope.M_AddEditTechSchedule.TimeSlot.push(newTime.format("h:mma"));
                timevalue = moment(newTime, "h:mm A").format("HH:mm");
            }
        }

        function openAddEditTechnicianPopup() {
            setTimeout(function() {
                angular.element('#techSchedulingPopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
        }

        function loadAddEditTechnicianSchedule() {
            $scope.F_AddEditTechSchedule.loadMasterData();
            openAddEditTechnicianPopup();
            if ($scope.M_AddEditTechSchedule.currentTechnicianId) {
                //edit mode
                $scope.F_AddEditTechSchedule.getTechnicianById($scope.M_AddEditTechSchedule.currentTechnicianId);
            } else {
                //add mode
                setLoadingFlag(false);
            }
            createTimeDropDown();
        }
        loadAddEditTechnicianSchedule();
    }])
});