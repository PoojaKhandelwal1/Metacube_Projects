define(['Routing_AppJs_PK', 'JobSchedulingServices', 'moment', 'momentTimezone', 'underscore_min', 'JqueryUI', 'shouldFocus', 'JobSchedulingFilters'], function (Routing_AppJs_PK, JobSchedulingServices, moment, momentTimezone, underscore_min, JqueryUI, shouldFocus, JobSchedulingFilters) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('JobSchedulingCtrl', ['$scope', '$rootScope', '$state', '$stateParams', '$compile', 'JobSchedulingPageService', '$document', '$interval', '$window', function ($scope, $rootScope, $state, $stateParams, $compile, JobSchedulingPageService, $document, $interval, $window) {
        var Notification = injector1.get("Notification");
        $scope.JobSchedulingModel = {};
        $scope.JobSchedulingModel.tabIndexValue = 1000;
        $scope.JobSchedulingModel.disableDeleteButton = false;
        $scope.JobSchedulingModel.disableSaveButton = false;
        $scope.JobSchedulingModel.SchedulingStartDay = $Global.SchedulingStartDay;
        $scope.JobSchedulingModel.MiniCalendarWeekDaysPrefixes = [];
        $scope.JobSchedulingModel.adjustTabIndex = function (e) {
            if (e.which == 9) {
                $('#appointmentTitleId').focus();
                e.preventDefault();
            }
        }
        $document.click(function (e) {
            // check that your clicked element has no id=globalSearchStrInput
            if ($scope.JobSchedulingModel.isFromTimeDropdownVisible) {
                if (e.target.id != 'fromTime') {
                    $scope.JobSchedulingModel.isFromTimeDropdownVisible = false;
                    $scope.JobSchedulingModel.fromTimeCurrentIndex = -1;
                }
            }
            if ($scope.JobSchedulingModel.isToTimeDropdownVisible) {
                if (e.target.id != 'toTime') {
                    $scope.JobSchedulingModel.isToTimeDropdownVisible = false;
                    $scope.JobSchedulingModel.toTimeCurrentIndex = -1;
                }
            }
            var popup = $(".BP_popOver");
            if (!popup.is(e.target) && popup.has(e.target).length == 0) {
                popup.hide();
            }

        });

        function fixCalendarColumnHeaders() {
            var tableWidth = angular.element('.calenderDetail').width();
            var theadWidth = tableWidth + 3;
            var noOfDays = $scope.JobSchedulingModel != undefined ? $scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].MainCalendarHeader.length : 7;
            if ($scope.JobSchedulingModel.currentView == 'Month') {
                angular.element('.calenderHeader').width(tableWidth + 10);
                angular.element('table.calenderMonthTable  > thead').width(tableWidth);
                angular.element('table.calenderMonthTable  > tbody').width(tableWidth + 5);
                angular.element('table.calenderMonthTable  > thead > tr > th').width((tableWidth) / 7);
                angular.element('table.calenderMonthTable  > tbody > tr > td').width((tableWidth) / 7);
            } else {
                angular.element('.calenderHeader').width(tableWidth + 10);
                angular.element('table.calenderWeekTable > thead').width(tableWidth + 3);
                angular.element('table.calenderWeekTable > tbody').width(tableWidth + 3);
                angular.element('table.calenderWeekTable > thead > tr:nth-child(1) > th:nth-child(1)').css("float", 'left');
                angular.element('table.calenderWeekTable > thead > tr:nth-child(1) > th:nth-child(1)').css("height", '55px');
                var theadWidthtd = parseFloat((tableWidth - 50)) / parseFloat(noOfDays) - 5;
                var tbodyWidthtd = parseFloat((tableWidth - 53)) / parseFloat(noOfDays) - 5;
                var firstTheadRow = angular.element('table.calenderWeekTable > thead > tr:nth-child(1)> th ');
                var TheadRow = angular.element('table.calenderWeekTable > thead > tr ');
                var b = angular.element('table.calenderWeekTable > tbody > tr');
                for (var i = 0; i < TheadRow.length; i++) {
                    var a = angular.element(TheadRow[i]).find('th');
                    for (var j = 0; j < a.length; j++) {
                        if (j == 0) {
                            angular.element(a[j]).width('50px');
                        } else {
                            var colspan = angular.element(a[j]).attr('colspan')
                            if (colspan == undefined) {
                                angular.element(a[j]).width(theadWidthtd);
                            } else {
                                angular.element(a[j]).width(theadWidthtd * colspan);
                            }
                        }

                    }
                }
                for (var i = 0; i < b.length; i++) {
                    var tbodyTrTdList = angular.element(b[i]).find('td');
                    for (var j = 0; j < firstTheadRow.length; j++) {
                        if (j == 0) {
                            angular.element(tbodyTrTdList[j]).width("50px");
                        } else {
                            angular.element(tbodyTrTdList[j]).width(theadWidthtd);
                        }
                    }
                }
            }
        }

        function calculatescreenTop() {
            var calendarmonthHeaderTop = angular.element(".calenderArea .calenderMonthTable  > thead").css('top');
            var calendarweekHeaderTop = angular.element(".calenderArea .calenderWeekTable > thead").css('top');
            var tempweek = $rootScope.wrapperHeight - 60;
            tempweek = tempweek + calendarweekHeaderTop;
            tempweek = tempweek + parseInt(calendarweekHeaderTop.substring(0, calendarweekHeaderTop.length - 2));
            var tempmonth = $rootScope.wrapperHeight - 60;
            tempmonth = tempmonth + parseInt(calendarmonthHeaderTop.substring(0, calendarmonthHeaderTop.length - 2));
            angular.element("#calenderHeader").css("top", $rootScope.wrapperHeight + "px");
            angular.element("#JobSchedulingWrappercontent .sidebar").css("top", $rootScope.wrapperHeight + "px");
            angular.element(".calenderArea .calenderWeekTable > thead").css('top', tempweek + "px");
            angular.element(".calenderArea .calenderWeekTable > thead").css('top', tempmonth + "px");
        }
        $scope.JobSchedulingModel.hideJobSchedulingTimeList = function (event) {
            if (event.which == 9) {
                if (event.target.id === 'fromTime') {
                    $scope.JobSchedulingModel.isFromTimeDropdownVisible = false;
                    $scope.JobSchedulingModel.fromTimeCurrentIndex = -1;
                } else if (event.target.id === 'toTime') {
                    $scope.JobSchedulingModel.isToTimeDropdownVisible = false;
                    $scope.JobSchedulingModel.toTimeCurrentIndex = -1;
                }
            }
        }
        $scope.JobSchedulingModel.day = moment();
        const NO_Of_DAYS_IN_WEEK = 7;
        const MAX_NO_OF_WEEKS_IN_MONTH = 6;
        $scope.JobSchedulingModel.currentView = 'Week';
        $scope.JobSchedulingModel.dateFormat = $Global.DateFormat;
        $scope.JobSchedulingModel.newCalendereventJSON = {};
        $scope.JobSchedulingModel.isEdit = false;
        $scope.JobSchedulingModel.CalendarViewNames = ['Day', 'Week', 'Month', '3 Days'];
        $scope.JobSchedulingModel.CalendarViewsJSON = {
            'Day': {
                Name: 'Day',
                OrderNo: 1,
                IsActive: false,
                TimePeriodOfMainCalendar: '',
                MainCalendarHeader: [],
                Day: [],
                Date: []
            },
            'Week': {
                Name: 'Week',
                OrderNo: 2,
                IsActive: true,
                TimePeriodOfMainCalendar: '',
                MainCalendarHeader: [],
                Day: [],
                Date: []
            },
            'Month': {
                Name: 'Month',
                OrderNo: 3,
                IsActive: false,
                TimePeriodOfMainCalendar: '',
                MainCalendarHeader: [],
                Day: [],
                Date: []
            },
            '3 Days': {
                Name: '3 Days',
                OrderNo: 4,
                IsActive: false,
                TimePeriodOfMainCalendar: '',
                MainCalendarHeader: [],
                Day: [],
                Date: []
            }
        };
        $(window).resize(function () {
            fixCalendarColumnHeaders();
            calculatescreenTop();
        });
        $scope.JobSchedulingModel.filterJson = {};
        $scope.JobSchedulingModel.filterJson.Appointment = true;
        $scope.JobSchedulingModel.filterJson.Appointmentwithservice = true;
        $scope.JobSchedulingModel.filterJson.Reminder = true;
        $scope.JobSchedulingModel.isFromTimeDropdownVisible = false;
        $scope.JobSchedulingModel.isToTimeDropdownVisible = false;
        $scope.JobSchedulingModel.DeliverydateOptions = {
            dateFormat: $scope.JobSchedulingModel.dateFormat
        };
        $scope.JobSchedulingModel.DeliverydateStartDateOptions = {
            dateFormat: $scope.JobSchedulingModel.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };
        $scope.JobSchedulingModel.DeliverydateEndDateOptions = {
            minDate: '',
            dateFormat: $scope.JobSchedulingModel.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };

        $scope.JobSchedulingModel.setToDateFormate = function () {
            $scope.JobSchedulingModel.DeliverydateEndDateOptions.minDate = $scope.JobSchedulingModel.newCalendereventJSON.StartDate;
            /*if (moment($scope.JobSchedulingModel.newCalendereventJSON.EndDate).diff(moment($scope.JobSchedulingModel.newCalendereventJSON.StartDate), 'days') < 0) {
                $scope.JobSchedulingModel.newCalendereventJSON.EndDate = $scope.JobSchedulingModel.newCalendereventJSON.StartDate;
            }*/
            
        	if (moment($scope.JobSchedulingModel.newCalendereventJSON.EndDate, $Global.SchedulingDateFormat).diff(moment($scope.JobSchedulingModel.newCalendereventJSON.StartDate, $Global.SchedulingDateFormat), 'days') < 0) {
        		$scope.JobSchedulingModel.newCalendereventJSON.EndDate = $scope.JobSchedulingModel.newCalendereventJSON.StartDate;
        	}
        }
        
        $scope.JobSchedulingModel.isDayBeforeToday = function(eventDate) {
        	var currentDate = moment(moment().tz($Global.CurrentUserTZSIDKey).format($Global.SchedulingDateFormat), $Global.SchedulingDateFormat);
        	if (moment(eventDate, $Global.SchedulingDateFormat).diff(currentDate, 'days') < 0) {
            	return true;
        	}
        	return false;
        }
        
        $scope.JobSchedulingModel.createEventOnJobScheduling = function (newCalendereventJSON) {
            $scope.JobSchedulingModel.hidenewAddEditEventPopup();
            //if (moment($scope.JobSchedulingModel.newCalendereventJSON.StartDate).diff(moment().format($Global.SchedulingDateFormat)) < 0) {
            if($scope.JobSchedulingModel.isDayBeforeToday($scope.JobSchedulingModel.newCalendereventJSON.StartDate)) {
                angular.element("#PastDatePopup").show();
                angular.element(".PastDatePopupbackDrop").show();
                setTimeout(function () {
                    var template = '<div class = "modal-backdrop  fade in" ng-click = "JobSchedulingModel.hidenewAddEditEventPopup()"></div>';
                    template = $compile(angular.element(template))($scope);
                    angular.element("#PastDatePopup").prepend(template);
                    angular.element("#PastDatePopup").addClass("in");
                    angular.element("body").addClass("modal-open");
                }, 1000);

                $scope.JobSchedulingModel.tempnewCalendereventJSON = newCalendereventJSON;
            } else {
                $scope.JobSchedulingModel.saveEvent(newCalendereventJSON);
            }
        }
        
        $scope.JobSchedulingModel.createPastEvent = function () {
            angular.element("#PastDatePopup").hide();
            angular.element("#PastDatePopup").removeClass("in");
            angular.element("body").removeClass("modal-open");
            angular.element("#PastDatePopup").hide();
            angular.element("#PastDatePopup").find('.modal-backdrop').remove();
            $scope.JobSchedulingModel.saveEvent($scope.JobSchedulingModel.tempnewCalendereventJSON);
        }
        $scope.JobSchedulingModel.notCreatePastEvent = function () {
            angular.element("#PastDatePopup").hide();
            angular.element("#PastDatePopup").removeClass("in");
            angular.element("body").removeClass("modal-open");
            angular.element("#PastDatePopup").hide();
            angular.element("#PastDatePopup").find('.modal-backdrop').remove();
        }
        $scope.JobSchedulingModel.defaultJSON = {}
        $scope.JobSchedulingModel.defaultJSON.AppointmentFilter = $scope.JobSchedulingModel.filterJson.Appointment;
        $scope.JobSchedulingModel.defaultJSON.AppointmentwithserviceFilter = $scope.JobSchedulingModel.filterJson.Appointmentwithservice;
        $scope.JobSchedulingModel.defaultJSON.ReminderFilter = $scope.JobSchedulingModel.filterJson.Reminder;
        $scope.JobSchedulingModel.TimeJSON = {};
        var eventDivWidth = 100;

        $scope.JobSchedulingModel.showDatePicker = function (event, Id) {
            angular.element("#" + Id).focus();
        }
        $scope.JobSchedulingModel.TimeSlotList = [{
                Time: '7:00',
                TimePeriod: 'AM'
            }, {
                Time: '8:00',
                TimePeriod: 'AM'
            },
            {
                Time: '9:00',
                TimePeriod: 'AM'
            },
            {
                Time: '10:00',
                TimePeriod: 'AM'
            },
            {
                Time: '11:00',
                TimePeriod: 'AM'
            },
            {
                Time: '12:00',
                TimePeriod: 'PM'
            },
            {
                Time: '1:00',
                TimePeriod: 'PM'
            },
            {
                Time: '2:00',
                TimePeriod: 'PM'
            },
            {
                Time: '3:00',
                TimePeriod: 'PM'
            },
            {
                Time: '4:00',
                TimePeriod: 'PM'
            },
            {
                Time: '5:00',
                TimePeriod: 'PM'
            },
            {
                Time: '6:00',
                TimePeriod: 'PM'
            },
            {
                Time: '7:00',
                TimePeriod: 'PM'
            },
            {
                Time: '8:00',
                TimePeriod: 'PM'
            },
            {
                Time: '9:00',
                TimePeriod: 'PM'
            },
            {
                Time: '10:00',
                TimePeriod: 'PM'
            },
            {
                Time: '11:00',
                TimePeriod: 'PM'
            },
            {
                Time: '12:00',
                TimePeriod: 'AM'
            }
        ];

        $scope.JobSchedulingModel.defaultTimeSlotList = [{
                Time: '7:00AM',
            }, {
                Time: '7:30AM',
            }, {
                Time: '8:00AM',
            }, {
                Time: '8:30AM',
            },
            {
                Time: '9:00AM',
            }, {
                Time: '9:30AM',
            },
            {
                Time: '10:00AM',
            }, {
                Time: '10:30AM',
            },
            {
                Time: '11:00AM',
            }, {
                Time: '11:30AM',
            },
            {
                Time: '12:00PM',
            }, {
                Time: '12:30PM',
            },
            {
                Time: '1:00PM',
            }, {
                Time: '1:30PM',
            },
            {
                Time: '2:00PM',
            }, {
                Time: '2:30PM',
            },
            {
                Time: '3:00PM',
            }, {
                Time: '3:30PM',
            },
            {
                Time: '4:00PM',
            }, {
                Time: '4:30PM',
            },
            {
                Time: '5:00PM',
            }, {
                Time: '5:30PM',
            },
            {
                Time: '6:00PM',
            }, {
                Time: '6:30PM',
            },
            {
                Time: '7:00PM',
            }, {
                Time: '7:30PM',
            },
            {
                Time: '8:00PM',
            }, {
                Time: '8:30PM',
            },
            {
                Time: '9:00PM',
            }, {
                Time: '9:30PM',
            },
            {
                Time: '10:00PM',
            }, {
                Time: '10:30PM',
            },
            {
                Time: '11:00PM',
            }, {
                Time: '11:30PM',
            }
        ];

        $scope.JobSchedulingModel.setDefaultValidationModel = function () {
            $scope.JobSchedulingModel.ScheduleEventFormValidationModal = {
                ActualStartTime: { // StartTime
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required,TimeFormat'
                },
                ActualEndTime: { // EndTime
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required,TimeFormat'
                }
            };
        }
        $scope.JobSchedulingModel.changeSelectdtimeSloat = function (selectedTime, Time) {
            var tempStartTime = selectedTime.split(":");
            var tempStartTimeHour = tempStartTime[0];
            var tempStartTimeMin = tempStartTime[1].substring(0, tempStartTime[1].length - 2)
            var tempStartTimePeriod = tempStartTime[1].substring(tempStartTime[1].length - 2, tempStartTime[1].length)
            if (Time == 'StartTime') {
                $scope.JobSchedulingModel.newCalendereventJSON.StartTime = selectedTime;
                $scope.JobSchedulingModel.newCalendereventJSON.ActualStartTime = selectedTime;
                if (tempStartTimeMin == 00) {
                    $scope.JobSchedulingModel.newCalendereventJSON.EndTime = tempStartTimeHour + ':' + '30' + tempStartTimePeriod;
                    $scope.JobSchedulingModel.newCalendereventJSON.ActualEndTime = tempStartTimeHour + ':' + '30' + tempStartTimePeriod;
                } else if (tempStartTimeMin == 30) {
                    if (tempStartTimeHour == 12) {
                        tempStartTimeHour = 0;
                    } else if (tempStartTimeHour == 11) {
                        if (tempStartTimePeriod == 'AM') {
                            tempStartTimePeriod = 'PM';
                        } else {
                            tempStartTimePeriod = 'AM';
                        }
                    }
                    $scope.JobSchedulingModel.newCalendereventJSON.EndTime = (parseInt(tempStartTimeHour) + 1).toString() + ":" + '00' + tempStartTimePeriod;
                    $scope.JobSchedulingModel.newCalendereventJSON.ActualEndTime = (parseInt(tempStartTimeHour) + 1).toString() + ":" + '00' + tempStartTimePeriod;
                }
                $scope.JobSchedulingModel.isFromTimeDropdownVisible = false;
            } else if (Time == 'EndTime') {
                $scope.JobSchedulingModel.newCalendereventJSON.EndTime = selectedTime;
                $scope.JobSchedulingModel.newCalendereventJSON.ActualEndTime = selectedTime;
                $scope.JobSchedulingModel.isToTimeDropdownVisible = false;
            }
        }

        $scope.JobSchedulingModel.showJobSchedulingTimeList = function (event) {
            angular.element(event.target).parent().find(".timeSloatDropdown").show();
        }

        $scope.JobSchedulingModel.MoveToState = function (stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }

        }
        $scope.JobSchedulingModel.addServiceJobAppointment = function (EventId) {
        	if(!$Global.IsLoadNewCustomerOrder){
        		var ServiceJobAppointmentJson = {
                        Type: 'Service Order',
                        AppointmentId: EventId
                    }
   	                 $rootScope.$broadcast('addServiceJobAppointment', ServiceJobAppointmentJson);
        	} else{
        		loadState($state, 'CustomerOrder_V2', {
                	AppointmentId: EventId
                });
        	}
        	$scope.JobSchedulingModel.hideAllPopup();
            $scope.JobSchedulingModel.hidenewAddEditEventPopup();
        	
        }
        $scope.JobSchedulingModel.EventsList = [];
        $scope.JobSchedulingModel.AllDayEventsList = [];
        $scope.JobSchedulingModel.bindAllDayEventsList = function () {
            angular.element('.AllDayEvent').remove();
            angular.element("#calenderWeekTable thead").find("tr:not(:first-child)").remove();
            for (var i = 0; i < $scope.JobSchedulingModel.AllDayEventsList.length; i++) {
                var eventJSON = $scope.JobSchedulingModel.AllDayEventsList[i];
                var cols = 1;

                var tableWidth = angular.element('.calenderDetail').width();
                var theadWidth = tableWidth + 3;
                var noOfDays = $scope.JobSchedulingModel != undefined ? $scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].MainCalendarHeader.length : 7;
                var TheadRow = angular.element('table.calenderWeekTable > thead > tr ');
                var theadWidthtd = parseFloat((tableWidth - 50)) / parseFloat(noOfDays);
                var AllDayEventClass;
                if (eventJSON.Type == "Reminder") {
                    AllDayEventClass = 'LongReminderBackground';
                } else if (eventJSON.Type == "Appointment" && eventJSON.COHeaderId != null) {
                    AllDayEventClass = 'LongAppointmentWithServiceBackground';
                } else if (eventJSON.Type == "Appointment") {
                    AllDayEventClass = 'LongAppointmentBackground';
                }
                var jobType = 'Customer Pay';
                var noOfCols = 0;
                var template = '';
                template += '<tr class="AllDayEvent">';
                template += '<th class="time" style = "width:50px;"></th>';
                for (var j = 0; j < $scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date.length; j++) {
                    if (moment($scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date[j]).diff(moment(eventJSON.CalculatedStartDate), 'days') < 0) {
                        if (moment(moment().format($Global.SchedulingDateFormat)).diff(moment($scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date[j]), 'days') == 0) {
                            template += '<th class="calendarToday" style = "width:' + theadWidthtd + 'px"></th>';
                        } else {
                            template += '<th style = "width:' + theadWidthtd + 'px"></th>';
                        }
                        noOfCols++;
                    }
                    if (moment($scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date[j]).diff(moment(eventJSON.CalculatedStartDate), 'days') == 0) {
                        var colspan = moment(eventJSON.CalculatedEndDate).diff(moment(eventJSON.CalculatedStartDate), 'days') + 1;
                        template += '<th colspan="' + colspan + '" style = "width:' + (theadWidthtd * colspan) + 'px">';
                        noOfCols += colspan;
                        break;
                    }
                }

                template += '<p class="longAppointment ' + AllDayEventClass + '" ng-click = "JobSchedulingModel.editJobSchedulEventPopup($event,\'' + eventJSON.Id + '\', false, true)"> <strong>' + eventJSON.Title + '</strong>' + eventJSON.Notes + ' </p></th>';

                for (var k = 0; k < $scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date.length - noOfCols; k++) {
                    var index = noOfCols + k;
                    if (moment(moment().format($Global.SchedulingDateFormat)).diff(moment($scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date[index]), 'days') == 0) {
                        template += '<th class="calendarToday" style = "width:' + theadWidthtd + 'px"></th>';
                    } else {
                        template += '<th style = "width:' + theadWidthtd + 'px"></th>';
                    }
                }
                template += '</tr>';
                var newEle = angular.element(template);
                newEle = $compile(newEle)($scope);
                angular.element('#calenderWeekTable thead').append(newEle);
            }
        }

        $scope.JobSchedulingModel.openNewEventModelPopup = function (dateSlot, timeSlot, TimePeriod, RepeatEnd) {
            $scope.JobSchedulingModel.hideAllPopup();
            if (RepeatEnd == true) {
                var timeSlot1 = timeSlot.split(":")
                timeSlot1[1] = '30'
                timeSlot = timeSlot1[0] + ':' + timeSlot1[1];
            }
            var EndTimeCal = dateSlot + ' ' + timeSlot + ' ' + TimePeriod;
            var EndTime = moment(EndTimeCal, $Global.SchedulingDateFormat + ' h:mm A').add(30, 'minutes').format('LT');
            var temp = EndTime.split(" ")
            var EndTimePeriod = temp[1];
            var EndTime = temp[0];
            $scope.JobSchedulingModel.newCalendereventJSON = {
                StartDate: dateSlot,
                EndDate: dateSlot,
                StartTime: timeSlot + TimePeriod,
                EndTime: EndTime + EndTimePeriod,
                Title: '',
                Type: 'Appointment',
                Id: null,
                ActualStartTime: timeSlot + TimePeriod,
                ActualEndTime: EndTime + EndTimePeriod,
                Notes: '',
                StartCalendarViewDate: $scope.JobSchedulingModel.defaultJSON.StartCalendarViewDate,
                EndCalendarViewDate: $scope.JobSchedulingModel.defaultJSON.EndCalendarViewDate,
                CalendarViewMonthNumber: $scope.JobSchedulingModel.defaultJSON.CalendarViewMonthNumber,
                CurrentView: $scope.JobSchedulingModel.defaultJSON.CurrentView,
                ReminderFilter: true,
                AppointmentFilter: true,
                AppointmentwithserviceFilter: true
            };
            $scope.JobSchedulingModel.EventTitle = 'Appointment title';
            $scope.JobSchedulingModel.DeliverydateEndDateOptions.minDate = $scope.JobSchedulingModel.newCalendereventJSON.StartDate;
            $scope.JobSchedulingModel.shownewAddEditEventPopup();
            $scope.JobSchedulingModel.setDefaultValidationModel();
        }
        $scope.JobSchedulingModel.showJobSchedulingFromTimeList = function () {
            $scope.JobSchedulingModel.isFromTimeDropdownVisible = true;
            $scope.JobSchedulingModel.fromTimeCurrentIndex = -1;
            var fromDropDown = angular.element('#fromTimeDropDown');
            setTimeout(function () {
                fromDropDown[0].scrollTop = 0;
            }, 10);
        }
        $scope.JobSchedulingModel.showJobSchedulingToTimeList = function () {
            $scope.JobSchedulingModel.isToTimeDropdownVisible = true;
            $scope.JobSchedulingModel.toTimeCurrentIndex = -1;
            var toDropDown = angular.element('#toTimeDropDown');
            setTimeout(function () {
                toDropDown[0].scrollTop = 0;
            }, 10);
        }
        $scope.JobSchedulingModel.shownewAddEditEventPopup = function () {
            angular.element("#appointmentModal").show();
            setTimeout(function () {
                var template = '<div class = "modal-backdrop  fade in" ng-click = "JobSchedulingModel.hidenewAddEditEventPopup()"></div>';
                template = $compile(angular.element(template))($scope);
                angular.element("#appointmentModal").prepend(template);
                angular.element("#appointmentTitleId").focus();
                angular.element("#appointmentModal").addClass("in");
                angular.element("body").addClass("modal-open");
            }, 1000);
        }
        $scope.JobSchedulingModel.hidenewAddEditEventPopup = function () {
            angular.element("#appointmentModal").removeClass("in");
            angular.element("body").removeClass("modal-open");
            angular.element("#appointmentModal").hide();
            angular.element("#appointmentModal").find('.modal-backdrop').remove();
        }
        $scope.JobSchedulingModel.hideAllPopup = function () {
            angular.element(".BP_popOver").css("opacity", "0");
            angular.element(".BP_popOver").css("display", "none");
        }
        $scope.JobSchedulingModel.addNewEvent = function () {
            $scope.JobSchedulingModel.hideAllPopup()
            var dateSlot = moment().format($Global.SchedulingDateFormat);
            var fulltimeSlot = moment().format('LT');
            if (moment($scope.JobSchedulingModel.selectedDay.clone().format($Global.SchedulingDateFormat)).isAfter(moment().format($Global.SchedulingDateFormat))) {
                if ($scope.JobSchedulingModel.currentView != 'Month' &&
                    moment($scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date[0]).isAfter(moment())) {
                    dateSlot = $scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date[0];
                } else {
                    dateSlot = $scope.JobSchedulingModel.selectedDay.clone().date(1).format($Global.SchedulingDateFormat);
                }
                fulltimeSlot = '8:00 AM';
            }
            var temp = fulltimeSlot.split(" ")
            var TimePeriod = temp[1];
            var timeSlot = temp[0];
            $scope.JobSchedulingModel.setDefaultValidationModel();
            $scope.JobSchedulingModel.openNewEventModelPopup(dateSlot, timeSlot, TimePeriod);
        }
        $scope.JobSchedulingModel.openEditEventModelPopup = function (editEventJSON) {
            $scope.JobSchedulingModel.newCalendereventJSON = {
                StartDate: editEventJSON.StartDate,
                EndDate: editEventJSON.EndDate,
                StartTime: editEventJSON.StartTime,
                EndTime: editEventJSON.EndTime,
                Title: editEventJSON.Title,
                Type: editEventJSON.Type,
                Id: editEventJSON.Id,
                ActualStartTime: editEventJSON.ActualStartTime,
                ActualEndTime: editEventJSON.ActualEndTime,
                Notes: editEventJSON.Notes,
                StartCalendarViewDate: $scope.JobSchedulingModel.defaultJSON.StartCalendarViewDate,
                EndCalendarViewDate: $scope.JobSchedulingModel.defaultJSON.EndCalendarViewDate,
                CalendarViewMonthNumber: $scope.JobSchedulingModel.defaultJSON.CalendarViewMonthNumber,
                CurrentView: $scope.JobSchedulingModel.defaultJSON.CurrentView,
                ReminderFilter: $scope.JobSchedulingModel.filterJson.Reminder,
                AppointmentFilter: $scope.JobSchedulingModel.filterJson.Appointment,
                AppointmentwithserviceFilter: $scope.JobSchedulingModel.filterJson.Appointmentwithservice,
                IsAllDayEvent: editEventJSON.IsAllDayEvent,
                CalculatedStartDate: editEventJSON.CalculatedStartDate,
                CalculatedEndDate: editEventJSON.CalculatedEndDate,
                COHeaderId: editEventJSON.COHeaderId
            };
            $scope.JobSchedulingModel.isEdit = true;
            $scope.JobSchedulingModel.disableSaveButton = false;
            $scope.JobSchedulingModel.closeappointmentPopover();
            $scope.JobSchedulingModel.DeliverydateEndDateOptions.minDate = $scope.JobSchedulingModel.newCalendereventJSON.StartDate;
            $scope.JobSchedulingModel.shownewAddEditEventPopup();
            setTimeout(function () {
                angular.element("#appointmentTitleId").focus();
            }, 1000)
            $scope.JobSchedulingModel.setDefaultValidationModel();
        }
        $scope.JobSchedulingModel.deleteJobSchedulingEvent = function (eventId) {
            if ($scope.JobSchedulingModel.disableDeleteButton) {
                return;
            }
            $scope.JobSchedulingModel.disableDeleteButton = true;
            $scope.JobSchedulingModel.closeappointmentPopover();
            $scope.JobSchedulingModel.hidenewAddEditEventPopup();
            $scope.JobSchedulingModel.loadCalendarView($scope.JobSchedulingModel.currentView);
            $scope.JobSchedulingModel.isCalendarLoading = false;
            JobSchedulingPageService.deleteJobSchedulingEvent(eventId, angular.toJson($scope.JobSchedulingModel.defaultJSON)).then(function (successResul) {
                $scope.JobSchedulingModel.EventsList = successResul[0];
                $scope.JobSchedulingModel.AllDayEventsList = successResul[1];
                if ($scope.JobSchedulingModel.currentView != 'Month') {
                    angular.element("#calenderWeekTable tbody tr td").find("div").remove();
                } else {
                    angular.element("#calenderMonthTable tbody tr td").find("div").remove();
                }
                $scope.JobSchedulingModel.bindEventList();
                if ($scope.JobSchedulingModel.currentView != 'Month') {
                    $scope.JobSchedulingModel.bindAllDayEventsList();
                }
                $scope.JobSchedulingModel.calculateTableHeight();
                $scope.JobSchedulingModel.disableDeleteButton = false;
            }, function (errorMessage) {
                $scope.JobSchedulingModel.disableDeleteButton = false;
                Notification.error(errorMessage);
            });
        }

        $scope.JobSchedulingModel.SelectTitle = function (event, selectedTitle) {
            $scope.JobSchedulingModel.newCalendereventJSON.Type = selectedTitle;
            $scope.JobSchedulingModel.EventTitle = selectedTitle + ' title';
        }

        $scope.JobSchedulingModel.validateForm = function () {
            angular.forEach($scope.JobSchedulingModel.ScheduleEventFormValidationModal, function (value, key) {
                $scope.JobSchedulingModel.validateFieldWithKey(key);
            });
        }

        $scope.JobSchedulingModel.validateFieldWithKey = function (modelKey) {
            var fieldValue = $scope.JobSchedulingModel.newCalendereventJSON[modelKey];
            var isError = false;
            var ErrorMessage = '';
            var validateType = $scope.JobSchedulingModel.ScheduleEventFormValidationModal[modelKey].Type;

            if (isError == false && validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                    isError = true;
                    ErrorMessage = "Field is Required";
                }
            }

            if (isError == false && validateType.indexOf('TimeFormat') > -1) {
                if (moment(fieldValue, 'h:mmA').format('h:mmA') == "Invalid date") {
                    isError = true;
                    ErrorMessage = "Invalid time format";
                } else {
                    $scope.JobSchedulingModel.newCalendereventJSON[modelKey] = moment(fieldValue, 'h:mmA').format('h:mmA');
                }
            }

            if (isError == false && modelKey === 'ActualEndTime') { // EndTime
                var startDate = $scope.JobSchedulingModel.newCalendereventJSON['StartDate'];
                var startTime = $scope.JobSchedulingModel.newCalendereventJSON['ActualStartTime']; // StartTime
                var endDate = $scope.JobSchedulingModel.newCalendereventJSON['EndDate'];
                var endTime = fieldValue;
                if (startDate === endDate) {
                    var beginningTime = moment(startTime, 'h:mma');
                    var endTime = moment(endTime, 'h:mma');
                    if (beginningTime.isBefore(endTime) == false) {
                        isError = true;
                        ErrorMessage = "To time can't be less than from time";
                    }
                }
            }

            $scope.JobSchedulingModel.ScheduleEventFormValidationModal[modelKey].isError = isError;
            $scope.JobSchedulingModel.ScheduleEventFormValidationModal[modelKey].ErrorMessage = ErrorMessage;

            // Set validation flag value
            if ($scope.JobSchedulingModel.ScheduleEventFormValidationModal[modelKey].isError == true) {
                $scope.JobSchedulingModel.isValidForm = false;
            }
        }

        $scope.JobSchedulingModel.saveEvent = function (newCalendereventJSON) {
            if ($scope.JobSchedulingModel.disableSaveButton) {
                return;
            }
            $scope.JobSchedulingModel.disableSaveButton = true;
            $scope.JobSchedulingModel.isValidForm = true;
            $scope.JobSchedulingModel.isCalendarLoading = false;
            $scope.JobSchedulingModel.validateForm();

            if (!$scope.JobSchedulingModel.isValidForm) {
                $scope.JobSchedulingModel.disableSaveButton = false;
                Notification.error("There is some error in time field");
                return;
            }
            /* Start: Changes done for issue when a new event is created for day other than in view then after creating event calendar should move to that day */
            $scope.JobSchedulingModel.selectedDay = moment(newCalendereventJSON.StartDate, $Global.SchedulingDateFormat);
            $scope.JobSchedulingModel.loadCalendarView($scope.JobSchedulingModel.currentView);
            $scope.JobSchedulingModel.startDayFromChevron = $scope.JobSchedulingModel.selectedDay.clone();
            _highlightDays($scope.JobSchedulingModel.selectedDay.clone(), $scope.JobSchedulingModel.currentView);
            if ($scope.JobSchedulingModel.currentView != 'Month') {
                newCalendereventJSON.StartCalendarViewDate = $scope.JobSchedulingModel.defaultJSON.StartCalendarViewDate;
                newCalendereventJSON.EndCalendarViewDate = $scope.JobSchedulingModel.defaultJSON.EndCalendarViewDate;
                newCalendereventJSON.CalendarViewMonthNumber = 0;
            } else {
                newCalendereventJSON.StartCalendarViewDate = $scope.JobSchedulingModel.selectedDay.clone().startOf('month').format($Global.SchedulingDateFormat);
                newCalendereventJSON.EndCalendarViewDate = $scope.JobSchedulingModel.selectedDay.clone().endOf('month').format($Global.SchedulingDateFormat);
                newCalendereventJSON.CalendarViewMonthNumber = $scope.JobSchedulingModel.selectedDay.clone().month() + 1;
            }
            JobSchedulingPageService.saveJobSchedulingEvent(angular.toJson(newCalendereventJSON)).then(function (successResul) {
                if ($scope.JobSchedulingModel.isEdit) {
                    var EventId = newCalendereventJSON.Id;
                    if (successResul[0].IsAllDayEvent == true) {
                        var eventIndex = _.findIndex($scope.JobSchedulingModel.AllDayEventsList, {
                            Id: EventId
                        });
                        $scope.JobSchedulingModel.AllDayEventsList[eventIndex] = successResul[0];
                    } else {
                        var eventIndex = _.findIndex($scope.JobSchedulingModel.EventsList, {
                            Id: EventId
                        });
                        $scope.JobSchedulingModel.EventsList[eventIndex] = successResul[0];
                    }
                } else {
                    $scope.JobSchedulingModel.filterJson.Appointment = true;
                    $scope.JobSchedulingModel.filterJson.Appointmentwithservice = true;
                    $scope.JobSchedulingModel.filterJson.Reminder = true;
                    $scope.JobSchedulingModel.EventsList = successResul[0];
                    $scope.JobSchedulingModel.AllDayEventsList = successResul[1];
                }

                if ($scope.JobSchedulingModel.currentView != 'Month') {
                    angular.element("#calenderWeekTable tbody tr td").find("div").remove();
                } else {
                    angular.element("#calenderMonthTable tbody tr td").find("div").remove();
                }

                $scope.JobSchedulingModel.isEdit = false;
                $scope.JobSchedulingModel.hidenewAddEditEventPopup();
                $scope.JobSchedulingModel.bindEventList();
                if ($scope.JobSchedulingModel.currentView != 'Month') {
                    $scope.JobSchedulingModel.bindAllDayEventsList();
                    $scope.JobSchedulingModel.calculateTableHeight();
                }
                $scope.JobSchedulingModel.disableSaveButton = false;
            }, function (errorMessage) {
                $scope.JobSchedulingModel.disableSaveButton = false;
                Notification.error(errorMessage);
            });
        }
        $scope.JobSchedulingModel.calculateTableHeight = function () {
            if ($scope.JobSchedulingModel.currentView != 'Month') {
                var highttable = 1269;
                var tdhead = 55;
                var theadHeight = angular.element('table.calenderWeekTable > thead').height();
                var tableHeight = angular.element('table.calenderWeekTable ').height();
                angular.element('table.calenderWeekTable').css('height', tableHeight + 'px')
                tableHeight = tableHeight + theadHeight;
                highttable += theadHeight - tdhead;
                var calenderDetailHeight = tableHeight + 60;
                angular.element('.calenderDetail').css('height', calenderDetailHeight + 'px');
                angular.element('table.calenderWeekTable').css('position', 'relative')
                angular.element('table.calenderWeekTable ').css('top', theadHeight + 'px');
            } else {
                var tableMonthHeight = angular.element('table.calenderMonthTable ').height() + 97;
                angular.element('.calenderDetail').css('height', tableMonthHeight + 'px');
            }

        }
        $scope.JobSchedulingModel.CreateEventsDateTimeValueToNoOfEventsMapKey = function (evnetJson) {
            var eventStartDate = evnetJson.StartDate.toString();
            var eventEndDate = evnetJson.EndDate.toString();
            var eventStartTime = evnetJson.StartTime.toString();
            var eventEndTime = evnetJson.EndTime.toString();
            var eventDateTimeValue;
            if ($scope.JobSchedulingModel.currentView != 'Month') {
                eventDateTimeValue = eventStartDate + '_' + eventEndDate + '_' + eventStartTime + '_' + eventEndTime;
            } else {
                eventDateTimeValue = eventStartDate + '_' + eventEndDate;
            }
            return eventDateTimeValue;
        }

        $scope.JobSchedulingModel.isCalendarLoading = true;
        var eventDateTimeValue;
        $scope.JobSchedulingModel.loadJobSchedulingEvents = function (multipleEventFlag) {
            if (multipleEventFlag == true) {
                $scope.JobSchedulingModel.isCalendarLoading = false;
            } else {
                $scope.JobSchedulingModel.isCalendarLoading = true;
            }
            JobSchedulingPageService.loadJobSchedulingEvents(angular.toJson($scope.JobSchedulingModel.defaultJSON)).then(function (successResult) {
                if (multipleEventFlag == true) {
                    $scope.JobSchedulingModel.EventsListPopUpModel = successResult[0];
                } else {
                    if ($scope.JobSchedulingModel.currentView != 'Month') {
                        angular.element("#calenderWeekTable tbody tr td").find("div").remove();
                    } else {
                        angular.element("#calenderMonthTable tbody tr td").find("div").remove();
                    }
                    $scope.JobSchedulingModel.EventsList = successResult[0];
                    $scope.JobSchedulingModel.AllDayEventsList = successResult[1];
                    $scope.JobSchedulingModel.bindEventList();
                    if ($scope.JobSchedulingModel.currentView != 'Month') {
                        $scope.JobSchedulingModel.bindAllDayEventsList();
                    }

                    setTimeout(function () {
                        $scope.JobSchedulingModel.calculateTableHeight();

                    }, 500);
                    fixCalendarColumnHeaders();
                    calculatescreenTop();
                    angular.element('body').addClass('bodyBgColorForJobScheduling');
                }
                $scope.JobSchedulingModel.hideAllPopup();
                $scope.JobSchedulingModel.isCalendarLoading = false;
                $scope.JobSchedulingModel.disableToday()
            }, function (errorMessage) {
                Notification.error(errorMessage);
                $scope.JobSchedulingModel.isCalendarLoading = true;
            });
        }

        $scope.JobSchedulingModel.applyFilter = function (FilterValue, event) {
            if (FilterValue == 'Appointment') {
                $scope.JobSchedulingModel.filterJson.Appointment = !$scope.JobSchedulingModel.filterJson.Appointment;
            } else if (FilterValue == 'Appointment With Service') {
                $scope.JobSchedulingModel.filterJson.Appointmentwithservice = !$scope.JobSchedulingModel.filterJson.Appointmentwithservice;
            } else if (FilterValue == 'Reminder') {
                $scope.JobSchedulingModel.filterJson.Reminder = !$scope.JobSchedulingModel.filterJson.Reminder;
            }
            $scope.JobSchedulingModel.loadCalendarView($scope.JobSchedulingModel.currentView);
            $scope.JobSchedulingModel.loadJobSchedulingEvents();
        }

        $scope.JobSchedulingModel.createEventsDateTimeValueToNoOfEventsMap = function () {
            $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap = {};
            for (var i = 0; i < $scope.JobSchedulingModel.EventsList.length; i++) {
                eventDateTimeValue = $scope.JobSchedulingModel.CreateEventsDateTimeValueToNoOfEventsMapKey($scope.JobSchedulingModel.EventsList[i]);

                if (!$scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap.hasOwnProperty(eventDateTimeValue)) {
                    $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue] = {};
                    $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].count = 1;
                    $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].appointmentType = 0;
                    $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].reminderType = 0;
                    $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].eventsList = [];
                    if ($scope.JobSchedulingModel.EventsList[i].Type === 'Appointment') {
                        $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].appointmentType += 1;
                    } else if ($scope.JobSchedulingModel.EventsList[i].Type === 'Reminder') {
                        $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].reminderType += 1;
                    }
                    $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].eventsList.push($scope.JobSchedulingModel.EventsList[i]);
                } else {
                    $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].count += 1;
                    if ($scope.JobSchedulingModel.EventsList[i].Type === 'Appointment') {
                        $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].appointmentType += 1;
                    } else if ($scope.JobSchedulingModel.EventsList[i].Type === 'Reminder') {
                        $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].reminderType += 1;
                    }
                    $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].eventsList.push($scope.JobSchedulingModel.EventsList[i]);
                }
            }
        }

        $scope.JobSchedulingModel.bindEventList = function () {
            var reminderEventIndex = 0;
            var appointmentEventIndex = 0;
            setTimeout(function () {
                $scope.JobSchedulingModel.createEventsDateTimeValueToNoOfEventsMap();
                var keys = Object.keys($scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap);
                for (var i = 0; i < keys.length; i++) {
                    var key = keys[i];
                    var EventsDateTimeValueToNoOfEventsMapObj = $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[key];
                    if ($scope.JobSchedulingModel.currentView == 'Month') {
                        if (EventsDateTimeValueToNoOfEventsMapObj.count >= 1 && EventsDateTimeValueToNoOfEventsMapObj.count <= 2) {
                            for (var j = 0; j < EventsDateTimeValueToNoOfEventsMapObj.eventsList.length; j++) {
                                $scope.JobSchedulingModel.bindEvent(EventsDateTimeValueToNoOfEventsMapObj.eventsList[j]);
                            }
                        } else {
                            if (EventsDateTimeValueToNoOfEventsMapObj.reminderType > 0) {
                                $scope.JobSchedulingModel.NoOfEventOnTimeWithType = EventsDateTimeValueToNoOfEventsMapObj.reminderType + ' Reminders';
                                if (EventsDateTimeValueToNoOfEventsMapObj.reminderType == 1) {
                                    $scope.JobSchedulingModel.NoOfEventOnTimeWithType = $scope.JobSchedulingModel.NoOfEventOnTimeWithType.replace('Reminders', 'Reminder');
                                }
                                reminderEventIndex = _.findIndex(EventsDateTimeValueToNoOfEventsMapObj.eventsList, {
                                    Type: 'Reminder'
                                });
                                $scope.JobSchedulingModel.bindEvent(EventsDateTimeValueToNoOfEventsMapObj.eventsList[reminderEventIndex]);
                            }
                            if (EventsDateTimeValueToNoOfEventsMapObj.appointmentType > 0) {
                                $scope.JobSchedulingModel.NoOfEventOnTimeWithType = EventsDateTimeValueToNoOfEventsMapObj.appointmentType + ' Appointments';
                                if (EventsDateTimeValueToNoOfEventsMapObj.appointmentType == 1) {
                                    $scope.JobSchedulingModel.NoOfEventOnTimeWithType = $scope.JobSchedulingModel.NoOfEventOnTimeWithType.replace('Appointments', 'Appointment');
                                }

                                appointmentEventIndex = _.findIndex(EventsDateTimeValueToNoOfEventsMapObj.eventsList, {
                                    Type: 'Appointment'
                                });
                                $scope.JobSchedulingModel.bindEvent(EventsDateTimeValueToNoOfEventsMapObj.eventsList[appointmentEventIndex]);
                            }
                        }
                    } else {
                        if (EventsDateTimeValueToNoOfEventsMapObj.count >= 1 && EventsDateTimeValueToNoOfEventsMapObj.count <= 3) {
                            for (var j = 0; j < EventsDateTimeValueToNoOfEventsMapObj.eventsList.length; j++) {
                                $scope.JobSchedulingModel.bindEvent(EventsDateTimeValueToNoOfEventsMapObj.eventsList[j]);
                            }
                        } else {
                            if (EventsDateTimeValueToNoOfEventsMapObj.reminderType > 0) {
                                $scope.JobSchedulingModel.NoOfEventOnTimeWithType = EventsDateTimeValueToNoOfEventsMapObj.reminderType + ' Reminders';
                                if (EventsDateTimeValueToNoOfEventsMapObj.reminderType == 1) {
                                    $scope.JobSchedulingModel.NoOfEventOnTimeWithType = $scope.JobSchedulingModel.NoOfEventOnTimeWithType.replace('Reminders', 'Reminder');
                                }

                                reminderEventIndex = _.findIndex(EventsDateTimeValueToNoOfEventsMapObj.eventsList, {
                                    Type: 'Reminder'
                                });
                                $scope.JobSchedulingModel.bindEvent(EventsDateTimeValueToNoOfEventsMapObj.eventsList[reminderEventIndex]);
                            }
                            if (EventsDateTimeValueToNoOfEventsMapObj.appointmentType > 0) {
                                $scope.JobSchedulingModel.NoOfEventOnTimeWithType = EventsDateTimeValueToNoOfEventsMapObj.appointmentType + ' Appointments';
                                if (EventsDateTimeValueToNoOfEventsMapObj.appointmentType == 1) {
                                    $scope.JobSchedulingModel.NoOfEventOnTimeWithType = $scope.JobSchedulingModel.NoOfEventOnTimeWithType.replace('Appointments', 'Appointment');
                                }
                                appointmentEventIndex = _.findIndex(EventsDateTimeValueToNoOfEventsMapObj.eventsList, {
                                    Type: 'Appointment'
                                });
                                $scope.JobSchedulingModel.bindEvent(EventsDateTimeValueToNoOfEventsMapObj.eventsList[appointmentEventIndex]);
                            }
                        }
                    }
                }
                if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                    $scope.$apply(); //TODO
                }
            }, 100);
        }

        $scope.JobSchedulingModel.closeappointmentPopover = function () {
            angular.element("#appointmentPopover").fadeTo(100, 0);

            setTimeout(function () {
                angular.element("#appointmentPopover").css("display", "none");
                if (angular.element("#appointmentWithServicePopover").css("display") == 'block') {
                    angular.element("#appointmentWithServicePopover").css("display", 'none');
                    angular.element("#appointmentPopoverHeader").show();
                }
            }, 500);
        }

        $scope.JobSchedulingModel.appointmentPopoverPosition = 'left';
        $scope.JobSchedulingModel.editJobSchedulEventPopup = function (event, Id, isOenFromMultipleEventPopup, isAllDayEvent) {
            $scope.JobSchedulingModel.editJobSchedulingModel = {};
            $scope.JobSchedulingModel.disableDeleteButton = false;
            $scope.JobSchedulingModel.customerInfoForEditJobSchedulingModel = {};
            event.stopPropagation();
            var editJobSchedulingModel = {};
            $scope.JobSchedulingModel.showEditJobSchedulingPopup();
            if (isOenFromMultipleEventPopup == true) {
                angular.element("#multipleAppointmentsPopover").hide();
            }
            $scope.JobSchedulingModel.isOenFromMultipleEventPopup = isOenFromMultipleEventPopup;
            var eventIndex;
            if (isAllDayEvent == true) {
                eventIndex = _.findIndex($scope.JobSchedulingModel.AllDayEventsList, {
                    Id: Id
                });
                editJobSchedulingModel = $scope.JobSchedulingModel.AllDayEventsList[eventIndex];
            } else {
                eventIndex = _.findIndex($scope.JobSchedulingModel.EventsList, {
                    Id: Id
                });
                editJobSchedulingModel = $scope.JobSchedulingModel.EventsList[eventIndex];
            }

            var targetEle = angular.element(event.target);
            if (!targetEle.is('div')) {
                targetEle = targetEle.parent();
            }
            if (isOenFromMultipleEventPopup) {
                targetEle = $scope.JobSchedulingModel.multipleAppointmentsPopupTargetEle;
            }

            if ((targetEle.offset().left > angular.element("#appointmentPopover").outerWidth() + 25) && ((window.innerHeight - targetEle.offset().top - targetEle[0].clientHeight / 2) > (angular.element("#appointmentPopover").outerHeight(true) / 2))) {
                $scope.JobSchedulingModel.appointmentPopoverPosition = 'left';
                angular.element("#appointmentPopover").css('left', targetEle.offset().left - angular.element("#appointmentPopover").outerWidth() - 20);
                angular.element("#appointmentPopover").css('top', targetEle.offset().top + targetEle[0].clientHeight / 2);
            } else if (targetEle.offset().top > angular.element("#appointmentPopover").outerHeight(true) + 25 && ((window.innerWidth - targetEle.offset().left - targetEle[0].clientWidth / 2) > (angular.element("#appointmentPopover").outerWidth() / 2))) {
                $scope.JobSchedulingModel.appointmentPopoverPosition = 'top';
                angular.element("#appointmentPopover").css('left', targetEle.offset().left - (angular.element("#appointmentPopover").outerWidth() / 2) + targetEle[0].clientWidth / 2);

                angular.element("#appointmentPopover").css('top', event.pageY - (angular.element("#appointmentPopover").outerHeight(true) / 2) - 25);
            } else if (((window.innerHeight - targetEle.offset().top - targetEle[0].clientHeight) > (angular.element("#appointmentPopover").outerHeight(true) + 25)) && ((window.innerWidth - targetEle.offset().left - targetEle[0].clientWidth / 2) > (angular.element("#appointmentPopover").outerWidth() / 2))) {
                $scope.JobSchedulingModel.appointmentPopoverPosition = 'bottom';
                angular.element("#appointmentPopover").css('left', targetEle.offset().left + targetEle[0].clientWidth / 2 - 140);
                angular.element("#appointmentPopover").css('top', targetEle.offset().top + 160);
            } else {
                $scope.JobSchedulingModel.appointmentPopoverPosition = 'top';
                angular.element("#appointmentPopover").css('left', targetEle.offset().left - (angular.element("#appointmentPopover").outerWidth() / 2));
                angular.element("#appointmentPopover").css('top', targetEle.offset().top - (angular.element("#appointmentPopover").outerHeight(true) / 2) - targetEle[0].clientHeight);

            }

            if (editJobSchedulingModel.COHeaderId != null) {
                JobSchedulingPageService.getServiceJobDetailsForForJobScheduling(editJobSchedulingModel.COHeaderId).then(function (successResult) {
                    $scope.JobSchedulingModel.customerInfoForEditJobSchedulingModel = successResult;
                    $scope.JobSchedulingModel.editJobSchedulingModel = editJobSchedulingModel;
                    $scope.JobSchedulingModel.hideAllPopup();
                    angular.element("#appointmentPopover").fadeTo(100, 1);
                    angular.element("#appointmentPopover").css("display", "block");

                }, function (errorMessage) {
                    Notification.error(errorMessage);
                });
            } else {
                $scope.JobSchedulingModel.editJobSchedulingModel = editJobSchedulingModel;
                $scope.JobSchedulingModel.hideAllPopup();
                angular.element("#appointmentPopover").fadeTo(100, 1);
                angular.element("#appointmentPopover").css("display", "block");
            }

        }

        $scope.JobSchedulingModel.bindEvent = function (TimeStampJson) {
            if (TimeStampJson != undefined && TimeStampJson != null) {
                if ($scope.JobSchedulingModel.currentView == 'Month') {
                    var monthName = TimeStampJson.StartDate.split('/')[0];
                    var targetEventId = '#' + $scope.JobSchedulingModel.createEventMonthWrapperID(TimeStampJson.StartDate, monthName, true);
                    var newEle = $scope.JobSchedulingModel.createNewElement(TimeStampJson, targetEventId);
                    $scope.JobSchedulingModel.applyCssToEventContainer(targetEventId, TimeStampJson, '27', newEle);
                } else {
                    var targetEventId = '#' + $scope.JobSchedulingModel.createEventWrapperID(TimeStampJson.StartDate, TimeStampJson.StartTime);
                    var eventHeight = $scope.JobSchedulingModel.calculateEventContainerHeight(targetEventId, TimeStampJson);
                    var newEle = $scope.JobSchedulingModel.createNewElement(TimeStampJson, targetEventId);
                    $scope.JobSchedulingModel.applyCssToEventContainer(targetEventId, TimeStampJson, eventHeight, newEle);
                }
            }
        }

        $scope.JobSchedulingModel.calculateEventContainerHeight = function (targetEventId, TimeStampJson) {
            var targetEventHeight = angular.element(targetEventId).outerHeight();
            var eventStartHours = (TimeStampJson.StartTime).toString().split(":");
            var eventEndHours = (TimeStampJson.EndTime).toString().split(":");
            var eventStartTimePeriod = eventStartHours[1].substring(eventStartHours[1].length - 2, eventStartHours[1].length);
            var eventEndTimePeriod = eventEndHours[1].substring(eventEndHours[1].length - 2, eventEndHours[1].length);

            var eventStartHoursAndMins = parseFloat((TimeStampJson.StartTime).substring(0, TimeStampJson.StartTime.length - 2).replace(":", "."));
            var eventEndHoursAndMins = parseFloat((TimeStampJson.EndTime).substring(0, TimeStampJson.EndTime.length - 2).replace(":", "."));
            if ((eventStartHoursAndMins > eventEndHoursAndMins) && (TimeStampJson.StartDate === TimeStampJson.EndDate)) {
                eventEndHours[0] = parseInt(eventEndHours[0]) + 12;
            }

            eventStartHours[1] = eventStartHours[1].substring(0, eventStartHours[1].length - 2);
            eventEndHours[1] = eventEndHours[1].substring(0, eventEndHours[1].length - 2);
            var eventHourDifference = parseInt(eventEndHours[0]) - parseInt(eventStartHours[0]);
            var eventMinDifference = parseInt(eventEndHours[1] != undefined ? eventEndHours[1] : 0) -
                parseInt(eventStartHours[1] != undefined ? eventStartHours[1] : 0);
            var eventHeight = ((eventHourDifference * 2) + (eventMinDifference / 30)) * targetEventHeight;
            return eventHeight;
        }

        $scope.JobSchedulingModel.applyCssToEventContainer = function (targetEventId, eventJSON, eventHeight, newEle) {
            newEle.css("height", eventHeight);
            angular.element(targetEventId).append(newEle);
            eventDateTimeValue = $scope.JobSchedulingModel.CreateEventsDateTimeValueToNoOfEventsMapKey(eventJSON);
            if ($scope.JobSchedulingModel.currentView != 'Month') {
                if (angular.element(targetEventId).find('div').length >= 2) {
                    angular.element(targetEventId).find('div').css("width", (100 / angular.element(targetEventId).find('div').length) + '%');
                    var count = 0;
                    $(targetEventId).find('div').each(function () {
                        var innerDivId = $(this).attr('id');
                        $(this).css('left', (count * (eventDivWidth / angular.element(targetEventId).find('div').length) + '%'));
                        count++;
                    });
                } else {
                    angular.element(targetEventId).find('div').css("width", eventDivWidth + '%');
                    newEle.css("left", '0%');
                }
            } else {}


        }
        $scope.JobSchedulingModel.openjobschedulingServiceJobPopup = function (CoHeaderId) {
            JobSchedulingPageService.getServiceJobDetailsForForJobScheduling(CoHeaderId).then(function (successResult) {
                $scope.JobSchedulingModel.serviceJobInfo = successResult;
                angular.element("#appointmentPopoverHeader").hide();
                angular.element("#appointmentWithServicePopover").show();
            }, function (errorMessage) {
                Notification.error(errorMessage);
            });
        }

        $scope.JobSchedulingModel.showEditJobSchedulingPopup = function () {
            angular.element("#appointmentWithServicePopover").hide();
            angular.element("#appointmentPopoverHeader").show();
        }

        $scope.JobSchedulingModel.showMultipleEventPopup = function () {
            angular.element("#appointmentPopover").hide();
            angular.element("#multipleAppointmentsPopover").css('opacity', '1');
            angular.element("#multipleAppointmentsPopover").show();
        }

        $scope.JobSchedulingModel.createNewElement = function (eventJSON, targetEventId) {
            var newElement;
            eventDateTimeValue = $scope.JobSchedulingModel.CreateEventsDateTimeValueToNoOfEventsMapKey(eventJSON);
            if ($scope.JobSchedulingModel.currentView != 'Month') {

                if ($scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].count > 3) {
                    if (eventJSON.Type == "Reminder" && $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].reminderType == 1) {
                        newElement = $scope.JobSchedulingModel.createElementForSingleEvent(eventJSON);
                    } else if (eventJSON.Type == "Appointment" && $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].appointmentType == 1) {
                        newElement = $scope.JobSchedulingModel.createElementForSingleEvent(eventJSON);
                    } else {
                        newElement = $scope.JobSchedulingModel.createElementForMultipleEvents(targetEventId, eventJSON);
                    }
                } else {
                    newElement = $scope.JobSchedulingModel.createElementForSingleEvent(eventJSON);
                }
            } else {
                if ($scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].count > 2) {
                    if (eventJSON.Type == "Reminder" && $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].reminderType == 1) {
                        newElement = $scope.JobSchedulingModel.createElementForSingleEvent(eventJSON);
                    } else if (eventJSON.Type == "Appointment" && $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[eventDateTimeValue].appointmentType == 1) {
                        newElement = $scope.JobSchedulingModel.createElementForSingleEvent(eventJSON);
                    } else {
                        newElement = $scope.JobSchedulingModel.createElementForMultipleEvents(targetEventId, eventJSON);
                    }
                } else {
                    newElement = $scope.JobSchedulingModel.createElementForSingleEvent(eventJSON);
                }
            }
            return newElement;
        }

        $scope.JobSchedulingModel.createElementForSingleEvent = function (eventJSON) {
            var EventClass;
            if (eventJSON.Type == "Reminder") {
                EventClass = 'reminder';
            } else if (eventJSON.Type == "Appointment" && eventJSON.COHeaderId != null) {
                EventClass = 'appointmentWithService';
            } else if (eventJSON.Type == "Appointment") {
                EventClass = 'appointment';
            }
            if ($scope.JobSchedulingModel.currentView != 'Month') {
                var template = '<div class = ' + EventClass + '  ng-click = "JobSchedulingModel.editJobSchedulEventPopup($event,\'' + eventJSON.Id + '\')"> <p>' + eventJSON.Title + '<span class = "jobSchedulingNotes">' + eventJSON.Notes + '</span></p>  </div>';
                var newEle = angular.element(template);
            } else {
                var template = '<div class =  ' + EventClass + '  ng-click = "JobSchedulingModel.editJobSchedulEventPopup($event,\'' + eventJSON.Id + '\')"> <p class = "eventMonthTitle col-md-6 col-sm-5 P0">' + eventJSON.Title + '</p>' + '<span class = "time P0 col-md-6 col-sm-6">' + eventJSON.ActualStartTime + '</span>  </div>';
                var newEle = angular.element(template);
            }
            return $compile(newEle)($scope);
        }

        $scope.JobSchedulingModel.createElementForMultipleEvents = function (targetEventId, eventJSON) {
            var EventClass;
            if (eventJSON.Type == "Reminder") {
                EventClass = 'reminder';
            } else if (eventJSON.Type == "Appointment") {
                EventClass = 'appointment';
            }
            var tempViewName = 'Month';
            var template = '<div ng-click = "JobSchedulingModel.showAllMultipleEvents($event,\'' + eventJSON.StartDate + '\',\'' + eventJSON.EndDate + '\',\'' + eventJSON.StartTime + '\',\'' + eventJSON.EndTime + '\',\'' + eventJSON.Type + '\')"  class= ' + EventClass + '  > <p class = "JobSchedulingMultiPleEvent">' + $scope.JobSchedulingModel.NoOfEventOnTimeWithType + ' <span class = "jobSchedulingNotes" ng-if="JobSchedulingModel.currentView != \'' + tempViewName + '\'">Tap to view details </span> </p> </div>';
            var newEle = angular.element(template);
            return $compile(newEle)($scope);
        }

        $scope.JobSchedulingModel.multipleEventPopoverPosition = 'left';
        $scope.JobSchedulingModel.showAllMultipleEvents = function (event, startDate, endDate, startTime, endTime, eventType) {
            $scope.JobSchedulingModel.hideAllPopup();
            event.stopPropagation();
            $scope.JobSchedulingModel.EventsListPopUpModel = [];
            var multipleEventJSON = {
                StartDate: startDate,
                EndDate: endDate,
                StartTime: startTime,
                EndTime: endTime
            };
            var startEndDateTimeVal = $scope.JobSchedulingModel.CreateEventsDateTimeValueToNoOfEventsMapKey(multipleEventJSON);
            if (eventType === 'Appointment') {
                for (var i = 0; i < $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[startEndDateTimeVal].count; i++) {
                    if ($scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[startEndDateTimeVal].eventsList[i].Type === 'Appointment') {
                        $scope.JobSchedulingModel.EventsListPopUpModel.push($scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[startEndDateTimeVal].eventsList[i]);
                    }
                }
            } else if (eventType === 'Reminder') {
                for (var i = 0; i < $scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[startEndDateTimeVal].count; i++) {
                    if ($scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[startEndDateTimeVal].eventsList[i].Type === 'Reminder') {
                        $scope.JobSchedulingModel.EventsListPopUpModel.push($scope.JobSchedulingModel.EventsDateTimeValueToNoOfEventsMap[startEndDateTimeVal].eventsList[i]);
                    }
                }
            }

            var targetEle = angular.element(event.target);
            if (!targetEle.is('div')) {
                targetEle = targetEle.parent();
            }
            $scope.JobSchedulingModel.multipleAppointmentsPopupTargetEle = targetEle;
            if ((targetEle.offset().left > angular.element("#multipleAppointmentsPopover").outerWidth() + 25) && !((window.innerHeight - (targetEle.offset().top + targetEle[0].clientHeight / 2)) < ((angular.element("#multipleAppointmentsPopover").outerHeight() / 2) + 20))) {
                $scope.JobSchedulingModel.multipleEventPopoverPosition = 'left';
                angular.element("#multipleAppointmentsPopover").css('left', targetEle.offset().left - 312.5);
                angular.element("#multipleAppointmentsPopover").css('top', targetEle.offset().top + targetEle[0].clientHeight / 2);
            } else if (targetEle.offset().top > angular.element("#multipleAppointmentsPopover").outerHeight() + 25) {
                $scope.JobSchedulingModel.multipleEventPopoverPosition = 'top';
                angular.element("#multipleAppointmentsPopover").css('left', targetEle.offset().left + targetEle[0].clientWidth / 2 - 140);
                angular.element("#multipleAppointmentsPopover").css('top', targetEle.offset().top - 100);
            } else {
                $scope.JobSchedulingModel.multipleEventPopoverPosition = 'bottom';
                angular.element("#multipleAppointmentsPopover").css('left', targetEle.offset().left + targetEle[0].clientWidth / 2 - 140);
                angular.element("#multipleAppointmentsPopover").css('top', targetEle.offset().top + 160 + 73);
            }

            angular.element("#multipleAppointmentsPopover").fadeTo(100, 1);;
            angular.element("#multipleAppointmentsPopover").css("display", 'block');
        }

        $scope.JobSchedulingModel.closemultipleAppointmentsPopup = function (event, startDate, endDate) {
            angular.element("#multipleAppointmentsPopover").fadeTo(100, 0);
            setTimeout(function () {
                angular.element("#multipleAppointmentsPopover").css("display", 'none');
            }, 200)

        }

        $scope.JobSchedulingModel.createEventWrapperID = function (date, timeSlot, TimePeriod, RepeatEnd) {
            if (RepeatEnd == true) {
                var timeSlot1 = timeSlot.split(":")
                timeSlot1[1] = '30'
                timeSlot = timeSlot1[0] + ':' + timeSlot1[1];
            }
            var newTimeSlot = timeSlot.replace(':', '_');

            date = date.replace(/\//g, "_");
            var id = 'calEventID_' + date + '_' + newTimeSlot + (TimePeriod != undefined ? TimePeriod : '');
            return id;
        }

        $scope.JobSchedulingModel.createEventMonthWrapperID = function (date, monthName, isCurrnetMonth) {
            if (isCurrnetMonth) {

                date = date.replace(/\//g, "_");
                if (monthName.length == 1) {
                    monthName = '0' + monthName;
                }
                var id = 'calEventID_' + date + '_' + monthName;
                return id;
            }
        }


        $scope.JobSchedulingModel.loadCalendar = function (event) {
            $scope.JobSchedulingModel.selectedDay = $scope.JobSchedulingModel.selectedDay || moment();
            $scope.JobSchedulingModel.weekFirstDay = _findFirstDayOfWeek($scope.JobSchedulingModel.selectedDay.clone() || moment());
            $scope.JobSchedulingModel.currentMonth = $scope.JobSchedulingModel.selectedDay.clone(); // current month 

            var calenderStartDate = $scope.JobSchedulingModel.selectedDay.clone();
            calenderStartDate.date(1);
            _findFirstDayOfWeek(calenderStartDate.day($scope.JobSchedulingModel.SchedulingStartDay));

            $scope.JobSchedulingModel.startDayFromChevron = $scope.JobSchedulingModel.selectedDay.clone();


            _buildMonth(calenderStartDate, $scope.JobSchedulingModel.currentMonth);

            $scope.JobSchedulingModel.loadCalendarView($scope.JobSchedulingModel.currentView);
            
            loadMiniCalendarDayPrefixes();
        }
        
        function loadMiniCalendarDayPrefixes() {
        	var weekDaynumberToDayPrefixMap = {
            	0: "S",
            	1: "M",
            	2: "T",
            	3: "W",
            	4: "T",
            	5: "F",
            	6: "S"
            };
            var startIndexForCalendar = $scope.JobSchedulingModel.SchedulingStartDay;
            for(var i=0;i<NO_Of_DAYS_IN_WEEK;i++) {
            	$scope.JobSchedulingModel.MiniCalendarWeekDaysPrefixes.push(weekDaynumberToDayPrefixMap[startIndexForCalendar]);
            	startIndexForCalendar++;
            	if(startIndexForCalendar > 6) {
            		startIndexForCalendar = 0;
            	}
            }
        }

        $scope.JobSchedulingModel.selectDay = function (day) {
            $scope.JobSchedulingModel.selectedDay = day.date;
            $scope.JobSchedulingModel.loadCalendarView($scope.JobSchedulingModel.currentView);
            $scope.JobSchedulingModel.startDayFromChevron = $scope.JobSchedulingModel.selectedDay.clone();

            _highlightDays($scope.JobSchedulingModel.selectedDay.clone(), $scope.JobSchedulingModel.currentView);
            $scope.JobSchedulingModel.loadJobSchedulingEvents();
        };

        $scope.JobSchedulingModel.selectcurrentDay = function () {
            $scope.JobSchedulingModel.selectedDay = moment();
            $scope.JobSchedulingModel.loadCalendarView($scope.JobSchedulingModel.currentView);
            $scope.JobSchedulingModel.loadJobSchedulingEvents();

        }

        $scope.JobSchedulingModel.disableToday = function () {
            if ($scope.JobSchedulingModel.currentView != 'Month') {
                for (var i = 0; i < $scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date.length; i++) {
                    if ($scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date[i] == moment().format($Global.SchedulingDateFormat)) {
                        return true;
                    }
                }
            } else { // ask for month view
                if (moment($scope.JobSchedulingModel.selectedDay.clone()).month() == moment().month()) {
                    return true;
                } else {
                    return false;
                }
            }
            return false;
        }

        $scope.JobSchedulingModel.getNextMonth = function () {
            var nextMonth = $scope.JobSchedulingModel.currentMonth.clone();
            _findFirstDayOfWeek(nextMonth.month(nextMonth.month() + 1).date(1));
            $scope.JobSchedulingModel.currentMonth.month($scope.JobSchedulingModel.currentMonth.month() + 1);
            _buildMonth(nextMonth, $scope.JobSchedulingModel.currentMonth);
            _highlightDays($scope.JobSchedulingModel.selectedDay.clone(), $scope.JobSchedulingModel.currentView);
        };

        $scope.JobSchedulingModel.getPreviousMonth = function () {
            var previousMonth = $scope.JobSchedulingModel.currentMonth.clone();
            _findFirstDayOfWeek(previousMonth.month(previousMonth.month() - 1).date(1));
            $scope.JobSchedulingModel.currentMonth.month($scope.JobSchedulingModel.currentMonth.month() - 1);
            _buildMonth(previousMonth, $scope.JobSchedulingModel.currentMonth);
            _highlightDays($scope.JobSchedulingModel.selectedDay.clone(), $scope.JobSchedulingModel.currentView);
        };

        function _findFirstDayOfWeek(date) {
        	if($scope.JobSchedulingModel.SchedulingStartDay != 0 && date.clone().day() == 0) {
        		return date.day($scope.JobSchedulingModel.SchedulingStartDay-NO_Of_DAYS_IN_WEEK).hour(0).minute(0).second(0).millisecond(0);
            }
        	return date.day($scope.JobSchedulingModel.SchedulingStartDay).hour(0).minute(0).second(0).millisecond(0);
        }

        function _buildMonth(calenderStartDate, month) {
            $scope.JobSchedulingModel.weeksOfMonth = [];
            var date = calenderStartDate.clone();
            for (var i = 0; i < MAX_NO_OF_WEEKS_IN_MONTH; i++) {
                $scope.JobSchedulingModel.weeksOfMonth.push({
                    days: _buildWeek(date.clone(), month)
                });
                date.add(1, "w");
            }
        }

        function _buildWeek(date, month) {
            var daysOfWeek = [];
            for (var i = 0; i < NO_Of_DAYS_IN_WEEK; i++) {
                daysOfWeek.push({
                    name: date.format("dd").substring(0, 1),
                    number: date.date(),
                    isCurrentMonth: date.month() === month.month(), // find name 
                    isToday: date.isSame(new Date(), "day"),
                    startDayForView: false,
                    endDayForView: false,
                    highlightDay: false,
                    date: date,
                    dayDate: date.clone().format($Global.SchedulingDateFormat),
                    monthName: date.clone().format('M')
                });
                date = date.clone();
                date.add(1, "d");
            }
            return daysOfWeek;
        }

        function _highlightDays(date, viewName) {
            var highlightDay = false;
            var weekNumber = 0;
            var dayNumber = 0;
            for (var i = 0; i < $scope.JobSchedulingModel.weeksOfMonth.length; i++) {
                for (var j = 0; j < $scope.JobSchedulingModel.weeksOfMonth[i].days.length; j++) {
                    $scope.JobSchedulingModel.weeksOfMonth[i].days[j].highlightDay = false;
                    $scope.JobSchedulingModel.weeksOfMonth[i].days[j].startDayForView = false;
                    $scope.JobSchedulingModel.weeksOfMonth[i].days[j].endDayForView = false;
                }
            }
            for (var i = 0; i < $scope.JobSchedulingModel.weeksOfMonth.length; i++) {
                for (var j = 0; j < $scope.JobSchedulingModel.weeksOfMonth[i].days.length; j++) {
                    if ($scope.JobSchedulingModel.weeksOfMonth[i].days[j].date.clone().format('DD-MM-YYYY') === date.format('DD-MM-YYYY')) {
                        highlightDay = true;
                        weekNumber = i;
                        dayNumber = j;
                        break;
                    }
                }
            }
            if (highlightDay) {
                if (viewName == 'Day') {
                    $scope.JobSchedulingModel.weeksOfMonth[weekNumber].days[dayNumber].highlightDay = true;
                    $scope.JobSchedulingModel.weeksOfMonth[weekNumber].days[dayNumber].startDayForView = true;
                    $scope.JobSchedulingModel.weeksOfMonth[weekNumber].days[dayNumber].endDayForView = true;
                } else if (viewName == 'Week') {
                    $scope.JobSchedulingModel.weeksOfMonth[weekNumber].days[0].startDayForView = true;
                    $scope.JobSchedulingModel.weeksOfMonth[weekNumber].days[6].endDayForView = true;
                    for (var j = 0; j < NO_Of_DAYS_IN_WEEK; j++) {
                        $scope.JobSchedulingModel.weeksOfMonth[weekNumber].days[j].highlightDay = true;
                    }
                } else if (viewName == 'Month') {
                    $scope.JobSchedulingModel.weeksOfMonth[weekNumber].days[dayNumber].startDayForView = true;
                    $scope.JobSchedulingModel.weeksOfMonth[weekNumber].days[dayNumber].endDayForView = true;
                } else if (viewName == '3 Days') {
                    $scope.JobSchedulingModel.weeksOfMonth[weekNumber + parseInt(dayNumber / NO_Of_DAYS_IN_WEEK)].days[(dayNumber % NO_Of_DAYS_IN_WEEK)].startDayForView = true;
                    $scope.JobSchedulingModel.weeksOfMonth[weekNumber + parseInt((dayNumber + 2) / NO_Of_DAYS_IN_WEEK)].days[((dayNumber + 2) % NO_Of_DAYS_IN_WEEK)].endDayForView = true;
                    for (var j = dayNumber; j < dayNumber + 3; j++) {
                        $scope.JobSchedulingModel.weeksOfMonth[weekNumber + parseInt(j / NO_Of_DAYS_IN_WEEK)].days[(j % NO_Of_DAYS_IN_WEEK)].highlightDay = true;
                    }
                }
            }

        }


        function _buildDays(date, noOfDays, viewName, dateFormatType) {
            for (var i = 0; i < noOfDays; i++) {
                $scope.JobSchedulingModel.CalendarViewsJSON[viewName].MainCalendarHeader.push({
                    "title": date.format(dateFormatType),
                    "isToday": date.format(dateFormatType) === moment().format(dateFormatType) ? true : false
                });
                $scope.JobSchedulingModel.CalendarViewsJSON[viewName].Day.push(date.format('dddd'));
                $scope.JobSchedulingModel.CalendarViewsJSON[viewName].Date.push(date.format($Global.SchedulingDateFormat));
                date.add(1, 'd');
            }
        }

        function _buildTimePeriodForDays(startDate, noOfDays, viewName, startDateFormatType, endDateFormatType) {
            var timePeriod = '';
            timePeriod += startDate.format(startDateFormatType);
            if (noOfDays == 2 || noOfDays == 6) { // for week and 3 days view
                timePeriod += ' - ';
                var endDate = startDate.clone().add(noOfDays, 'days');
                timePeriod += endDate.format(endDateFormatType);
            }
            $scope.JobSchedulingModel.CalendarViewsJSON[viewName].TimePeriodOfMainCalendar = timePeriod;
        }

        $scope.JobSchedulingModel.weeksOfMonthForMainCalendar = [];

        $scope.JobSchedulingModel.loadCalendarView = function (viewName) {
            $scope.JobSchedulingModel.CalendarViewsJSON[viewName].MainCalendarHeader = [];
            $scope.JobSchedulingModel.CalendarViewsJSON[viewName].Day = [];
            $scope.JobSchedulingModel.CalendarViewsJSON[viewName].Date = [];
            var startDate = $scope.JobSchedulingModel.selectedDay.clone();
            var startDateFormatForView = '';
            var endDateFormatForView = '';
            var numberOfDaysInView = 0;
            var timeFormatForMainCalHeader = '';

            $scope.JobSchedulingModel.currentMonth = $scope.JobSchedulingModel.selectedDay.clone();
            var startForMonth = _findFirstDayOfWeek($scope.JobSchedulingModel.selectedDay.clone().date(1).day($scope.JobSchedulingModel.SchedulingStartDay));
            _buildMonth(startForMonth, $scope.JobSchedulingModel.currentMonth);

            if (viewName == 'Day') {
                startDateFormatForView = 'dddd DD MMMM, YYYY';
                endDateFormatForView = '';
                numberOfDaysInView = 1;
                timeFormatForMainCalHeader = 'dddd DD MMMM YYYY';
            } else if (viewName == 'Week') {
                startDate = _findFirstDayOfWeek(startDate);
                startDateFormatForView = 'MMMM DD';
                endDateFormatForView = 'MMMM DD, YYYY';
                numberOfDaysInView = 7;
                timeFormatForMainCalHeader = 'dddd DD';
            } else if (viewName == 'Month') {
                startDateFormatForView = 'MMMM YYYY';
                endDateFormatForView = '';
                timeFormatForMainCalHeader = '';
                $scope.JobSchedulingModel.weeksOfMonthForMainCalendar = angular.copy($scope.JobSchedulingModel.weeksOfMonth);

            } else if (viewName == '3 Days') {
                startDateFormatForView = 'MMMM DD';
                endDateFormatForView = 'MMMM DD, YYYY';
                numberOfDaysInView = 3;
                timeFormatForMainCalHeader = 'dddd DD';
            }

            _buildTimePeriodForDays(startDate, numberOfDaysInView - 1, viewName, startDateFormatForView, endDateFormatForView);
            if (viewName != 'Month') {
                _buildDays(startDate, numberOfDaysInView, viewName, timeFormatForMainCalHeader);
            }

            _highlightDays($scope.JobSchedulingModel.selectedDay.clone(), viewName);
            if ($scope.JobSchedulingModel.currentView == 'Month') {
                $scope.JobSchedulingModel.defaultJSON.StartCalendarViewDate = $scope.JobSchedulingModel.selectedDay.clone().startOf('month').format($Global.SchedulingDateFormat);
                $scope.JobSchedulingModel.defaultJSON.EndCalendarViewDate = $scope.JobSchedulingModel.selectedDay.clone().endOf('month').format($Global.SchedulingDateFormat);
                $scope.JobSchedulingModel.defaultJSON.CalendarViewMonthNumber = $scope.JobSchedulingModel.selectedDay.clone().month() + 1;
                $scope.JobSchedulingModel.defaultJSON.CurrentView = $scope.JobSchedulingModel.currentView;
            } else {
                $scope.JobSchedulingModel.defaultJSON.StartCalendarViewDate = $scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date[0];
                $scope.JobSchedulingModel.defaultJSON.EndCalendarViewDate = $scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date[$scope.JobSchedulingModel.CalendarViewsJSON[$scope.JobSchedulingModel.currentView].Date.length - 1],
                    $scope.JobSchedulingModel.defaultJSON.CalendarViewMonthNumber = 0;
                $scope.JobSchedulingModel.defaultJSON.CurrentView = $scope.JobSchedulingModel.currentView
            }

            $scope.JobSchedulingModel.defaultJSON.AppointmentFilter = $scope.JobSchedulingModel.filterJson.Appointment;
            $scope.JobSchedulingModel.defaultJSON.AppointmentwithserviceFilter = $scope.JobSchedulingModel.filterJson.Appointmentwithservice;
            $scope.JobSchedulingModel.defaultJSON.ReminderFilter = $scope.JobSchedulingModel.filterJson.Reminder;
            $scope.JobSchedulingModel.defaultJSON.StartCalendarViewTime = null;
            $scope.JobSchedulingModel.defaultJSON.EndCalendarViewTime = null;
            setTimeout(function () {
                fixCalendarColumnHeaders();
            }, 100);
        }

        $scope.JobSchedulingModel.changeCalendarView = function (viewName) {
            for (var key in $scope.JobSchedulingModel.CalendarViewsJSON) {
                if ($scope.JobSchedulingModel.CalendarViewsJSON.hasOwnProperty(key)) {
                    $scope.JobSchedulingModel.CalendarViewsJSON[key].IsActive = false;
                }
            }
            $scope.JobSchedulingModel.CalendarViewsJSON[viewName].IsActive = true;
            $scope.JobSchedulingModel.currentView = viewName;


            $scope.JobSchedulingModel.loadCalendarView(viewName);
            $scope.JobSchedulingModel.loadJobSchedulingEvents();
        }

        $scope.JobSchedulingModel.getTimeSlotForSelectedView = function (viewName, operator) {
            $scope.JobSchedulingModel.CalendarViewsJSON[viewName].MainCalendarHeader = [];
            $scope.JobSchedulingModel.CalendarViewsJSON[viewName].Day = [];
            $scope.JobSchedulingModel.CalendarViewsJSON[viewName].Date = [];
            var startDate = $scope.JobSchedulingModel.selectedDay.clone();
            var startDayForViewFromChevron;
            var numberOfDaysInView = 0;
            var startDateFormatForView = '';
            var endDateFormatForView = '';
            var timeFormatForMainCalHeader = '';

            if (viewName == 'Day') {
                if (operator == 'Next') {
                    $scope.JobSchedulingModel.startDayFromChevron = $scope.JobSchedulingModel.startDayFromChevron.add(1, 'd');
                } else if (operator == 'Previous') {
                    $scope.JobSchedulingModel.startDayFromChevron = $scope.JobSchedulingModel.startDayFromChevron.subtract(1, 'd');
                }
                startDayForViewFromChevron = $scope.JobSchedulingModel.startDayFromChevron;
                numberOfDaysInView = 1;
                startDateFormatForView = 'dddd DD MMMM, YYYY';
                endDateFormatForView = '';
                timeFormatForMainCalHeader = 'dddd DD MMMM YYYY';
            } else if (viewName == 'Week') {
                if (operator == 'Next') {
                    $scope.JobSchedulingModel.startDayFromChevron = $scope.JobSchedulingModel.startDayFromChevron.add(7, 'd');
                } else if (operator == 'Previous') {
                    $scope.JobSchedulingModel.startDayFromChevron = $scope.JobSchedulingModel.startDayFromChevron.subtract(7, 'd');
                }

                $scope.JobSchedulingModel.startDayFromChevron = _findFirstDayOfWeek($scope.JobSchedulingModel.startDayFromChevron);
                startDayForViewFromChevron = $scope.JobSchedulingModel.startDayFromChevron;
                numberOfDaysInView = 7;
                startDateFormatForView = 'MMMM DD';
                endDateFormatForView = 'MMMM DD, YYYY';
                timeFormatForMainCalHeader = 'dddd DD';
            } else if (viewName == 'Month') {
                if (operator == 'Next') {
                    $scope.JobSchedulingModel.startDayFromChevron.month($scope.JobSchedulingModel.startDayFromChevron.month() + 1);
                } else if (operator == 'Previous') {
                    $scope.JobSchedulingModel.startDayFromChevron.month($scope.JobSchedulingModel.startDayFromChevron.month() - 1);
                }

                startDayForViewFromChevron = $scope.JobSchedulingModel.startDayFromChevron;
                numberOfDaysInView = 0;
                startDateFormatForView = 'MMMM YYYY';
                endDateFormatForView = '';
                timeFormatForMainCalHeader = '';
            } else if (viewName == '3 Days') {
                if (operator == 'Next') {
                    $scope.JobSchedulingModel.startDayFromChevron = $scope.JobSchedulingModel.startDayFromChevron.add(3, 'd');
                } else if (operator == 'Previous') {
                    $scope.JobSchedulingModel.startDayFromChevron = $scope.JobSchedulingModel.startDayFromChevron.subtract(3, 'd');
                }

                startDayForViewFromChevron = $scope.JobSchedulingModel.startDayFromChevron;
                numberOfDaysInView = 3;
                startDateFormatForView = 'MMMM DD';
                endDateFormatForView = 'MMMM DD, YYYY';
                timeFormatForMainCalHeader = 'dddd DD';
            }

            $scope.JobSchedulingModel.selectedDay = startDayForViewFromChevron.clone();

            _buildTimePeriodForDays(startDayForViewFromChevron, numberOfDaysInView - 1, viewName, startDateFormatForView, endDateFormatForView);
            if (viewName != 'Month') {
                _buildDays(startDayForViewFromChevron.clone(), numberOfDaysInView, viewName, timeFormatForMainCalHeader);
            }
            $scope.JobSchedulingModel.currentMonth = $scope.JobSchedulingModel.selectedDay.clone();
            var startForMonth = _findFirstDayOfWeek($scope.JobSchedulingModel.selectedDay.clone().date(1).day($scope.JobSchedulingModel.SchedulingStartDay));
            _buildMonth(startForMonth, $scope.JobSchedulingModel.currentMonth);
            _highlightDays(startDayForViewFromChevron.clone(), viewName);


            $scope.JobSchedulingModel.loadCalendarView($scope.JobSchedulingModel.currentView);
            $scope.JobSchedulingModel.loadJobSchedulingEvents();
        }

        $scope.JobSchedulingModel.isHighlightedDaysContainToday = function () {
            for (var i = 0; i < $scope.JobSchedulingModel.weeksOfMonth.length; i++) {
                for (var j = 0; j < $scope.JobSchedulingModel.weeksOfMonth[i].days.length; j++) {
                    if ($scope.JobSchedulingModel.weeksOfMonth[i].days[j].highlightDay) {
                        if ($scope.JobSchedulingModel.weeksOfMonth[i].days[j].dayDate === moment().format($Global.SchedulingDateFormat)) {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        $scope.JobSchedulingModel.loadCalendar();


        $scope.JobSchedulingModel.displayCurrentDateTimeTdId = '';
        $scope.JobSchedulingModel.displayCurrentDateTimeIndicator = function () {
            var currDateTime = moment();
            var currDate = currDateTime.clone().format($Global.SchedulingDateFormat);
            var currTime = currDateTime.clone().format('LT');
            var hours = currDateTime.clone().format('h');
            var minutes = currDateTime.clone().format('mm');
            var timePeriod = currDateTime.clone().format('A');
            if (minutes >= '0' && minutes < '30') {
                currTime = hours + ":" + '00' + timePeriod;
            } else {
                currTime = hours + ":" + '30' + timePeriod;
            }

            $scope.JobSchedulingModel.displayCurrentDateTimeTdId = $scope.JobSchedulingModel.createEventWrapperID(currDate, currTime);;
            var tdHeight = 27;
            var indicatorPosition = (tdHeight / 30) * (minutes > 30 ? (minutes - 30) : minutes);
            $scope.JobSchedulingModel.CurrentDateTimeIndicatorStyle = {
                "top": indicatorPosition + "px"
            }
        }

        $scope.JobSchedulingModel.displayCurrentDateTimeIndicator();

        $interval(function () {
            $scope.JobSchedulingModel.displayCurrentDateTimeIndicator();
        }, 60000);

        $scope.JobSchedulingModel.fromTimeCurrentIndex = -1;
        $scope.JobSchedulingModel.toTimeCurrentIndex = -1;
        angular.element('#fromTime').on("keyup", function (event) {
            var totalRecordsToTraverse = 0;
            if ($scope.JobSchedulingModel.defaultTimeSlotList != null) {
                totalRecordsToTraverse = $scope.JobSchedulingModel.defaultTimeSlotList.length;
            }

            if (event.which === 40) {
                if (($scope.JobSchedulingModel.fromTimeCurrentIndex + 1) < totalRecordsToTraverse) {
                    $scope.JobSchedulingModel.fromTimeCurrentIndex++;
                    $scope.$apply();
                    event.preventDefault;
                    event.stopPropagation();
                }
            } else if (event.which == 38) {
                if ($scope.JobSchedulingModel.fromTimeCurrentIndex >= 1) {
                    $scope.JobSchedulingModel.fromTimeCurrentIndex--;
                    $scope.$apply();
                    event.preventDefault;
                    event.stopPropagation();
                }
            } else if (event.which == 13) {
                if ($scope.JobSchedulingModel.fromTimeCurrentIndex >= 0 && $scope.JobSchedulingModel.fromTimeCurrentIndex < totalRecordsToTraverse) {
                    var recordsLengthForKEywords = 0;
                    $scope.JobSchedulingModel.changeSelectdtimeSloat($scope.JobSchedulingModel.defaultTimeSlotList[$scope.JobSchedulingModel.fromTimeCurrentIndex].Time, 'StartTime');

                    $scope.$apply();
                    event.preventDefault;
                    event.stopPropagation();
                }
            } else if (event.which == 27) {
                $scope.JobSchedulingModel.fromTimeCurrentIndex = -1;
                $scope.$apply();
            }
        });

        angular.element('#toTime').on("keyup", function (event) {
            var totalRecordsToTraverse = 0;
            if ($scope.JobSchedulingModel.defaultTimeSlotList != null) {
                totalRecordsToTraverse = $scope.JobSchedulingModel.defaultTimeSlotList.length;
            }

            if (event.which === 40) {
                if (($scope.JobSchedulingModel.toTimeCurrentIndex + 1) < totalRecordsToTraverse) {
                    $scope.JobSchedulingModel.toTimeCurrentIndex++;
                    $scope.$apply();
                    event.preventDefault;
                    event.stopPropagation();
                }
            } else if (event.which == 38) {
                if ($scope.JobSchedulingModel.toTimeCurrentIndex >= 1) {
                    $scope.JobSchedulingModel.toTimeCurrentIndex--;
                    $scope.$apply();
                    event.preventDefault;
                    event.stopPropagation();
                }
            } else if (event.which == 13) {
                if ($scope.JobSchedulingModel.toTimeCurrentIndex >= 0 && $scope.JobSchedulingModel.toTimeCurrentIndex < totalRecordsToTraverse) {
                    var recordsLengthForKEywords = 0;
                    $scope.JobSchedulingModel.changeSelectdtimeSloat($scope.JobSchedulingModel.defaultTimeSlotList[$scope.JobSchedulingModel.toTimeCurrentIndex].Time, 'EndTime');

                    $scope.$apply();
                    event.preventDefault;
                    event.stopPropagation();
                }
            } else if (event.which == 27) {
                $scope.JobSchedulingModel.toTimeCurrentIndex = -1;
                $scope.$apply();
            }
        });

        $scope.JobSchedulingModel.loadJobSchedulingEvents();

    }])
});