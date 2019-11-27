var WeekScheduleGrid = angular.module('WeekScheduleGrid', []);
 var injector = angular.injector(['ui-notification', 'ng']);
WeekScheduleGrid.controller('WeekScheduleGridCtrl', ['$scope', '$q', '$rootScope', 'WeekScheduleGridService', '$translate', '$state', '$stateParams', function($scope, $q, $rootScope, WeekScheduleGridService, $translate, $state, $stateParams) {
var Notification = injector.get("Notification");
    $scope.M_WeekScheduleGrid = $scope.M_WeekScheduleGrid || {};
    $scope.F_WeekScheduleGrid = {};
    $scope.M_WeekScheduleGrid.weekStartDate = {};
    $scope.M_WeekScheduleGrid.dateFormat = $Global.SchedulingDateFormat;
    $scope.M_WeekScheduleGrid.CurrentUserTZSIDKey = $Global.CurrentUserTZSIDKey;
    $scope.M_WeekScheduleGrid.weekEndDate = {};
    $scope.M_WeekScheduleGrid.currentDate = ''; 
    $scope.M_WeekScheduleGrid.isLoading = false;
    $scope.M_WeekScheduleGrid.isShowLegendDropdown = false;
    $scope.M_WeekScheduleGrid.isClickedOnAddeditAppoitmentProgressBar = false;
	if($rootScope.currentStateName == 'AddEditAppointment') {
    	$scope.M_WeekScheduleGrid.StateName = 'AddEditAppointment';
    } else if($rootScope.currentStateName == 'TechScheduler') {
    	$scope.M_WeekScheduleGrid.StateName = 'TechSchedulee';
    }
    $scope.F_WeekScheduleGrid.loadData = function(startDate, endDate) {
	        $scope.M_WeekScheduleGrid.weekStartDate = startDate;
	        $scope.M_WeekScheduleGrid.weekEndDate = endDate;
	        WeekScheduleGridService.getAppointmentSchedulerDataForDateRange($scope.M_WeekScheduleGrid.weekStartDate.format($scope.M_WeekScheduleGrid.dateFormat), $scope.M_WeekScheduleGrid.weekEndDate.format($scope.M_WeekScheduleGrid.dateFormat)).then(function(ProgressBarData) {
	            $scope.M_WeekScheduleGrid.ProgressBarJSON = ProgressBarData;
	            $scope.M_WeekScheduleGrid.isLoading = false;
	            if($rootScope.currentStateName == 'AddEditAppointment') {
	            	$scope.M_AddEditApp.isLoading = false;
	            }
	            if($rootScope.currentStateName == 'AddEditAppointment' 
	    			&& $scope.M_AddEditApp.isLoadedByPlus) {
	            	$scope.F_WeekScheduleGrid.selectDateTimeSchedule($stateParams.AddEditAppointmentParams.weekDataIndex,$stateParams.AddEditAppointmentParams.daySegmentIndex);
	            	$scope.M_AddEditApp.isLoadedByPlus = false;
	    		} 

	            generateDaysData();
	        }, function(error) {
	            Notification.error($translate.instant('GENERIC_ERROR'));
	            $scope.M_WeekScheduleGrid.isLoading = false;
	            if($rootScope.currentStateName == 'AddEditAppointment') {
	            	$scope.M_AddEditApp.isLoading = false;
	            }
	        });
    	
    }
    $scope.M_WeekScheduleGrid.currentWeekdays = [];

    function generateDaysData() {
        var listOfDays = [];
        for(var n=0; n < $scope.M_WeekScheduleGrid.ProgressBarJSON.WeekDataList.length; n++) {
        	var object = {
                    day: moment($scope.M_WeekScheduleGrid.ProgressBarJSON.WeekDataList[n].AppointmentDate,$scope.M_WeekScheduleGrid.dateFormat).format('ddd'),
                    date: moment($scope.M_WeekScheduleGrid.ProgressBarJSON.WeekDataList[n].AppointmentDate,$scope.M_WeekScheduleGrid.dateFormat).format('DD')
                }
           listOfDays.push(object);
        }
        $scope.M_WeekScheduleGrid.currentWeekdays = listOfDays;
    }
    $scope.F_WeekScheduleGrid.isDayBeforeToday = function(weekDataIndex) {
    	dateStr = $scope.M_WeekScheduleGrid.ProgressBarJSON.WeekDataList[weekDataIndex].AppointmentDate;
    	
    	var currentDate = moment(moment().tz($scope.M_WeekScheduleGrid.CurrentUserTZSIDKey).format($scope.M_WeekScheduleGrid.dateFormat), $scope.M_WeekScheduleGrid.dateFormat);
    	
    	if (moment(dateStr, $scope.M_WeekScheduleGrid.dateFormat).diff(currentDate, 'days') < 0) {
    	//if (moment(dateStr).diff(moment(),'days') < 0) {
    		return true;
    	}
    	return false;
    }
    
    $scope.F_WeekScheduleGrid.openAddEditAppointmentPopup = function(weekDataIndex, daySegmentIndex){
    	if($rootScope.currentStateName == 'AddEditAppointment') {
    		return;
    	}
    	var appointmentSchedule = {
    			'weekDataIndex': weekDataIndex,
    			'daySegmentIndex': daySegmentIndex,
    			'isLoadedByPlus': true,
    			'currentDate': $scope.M_WeekScheduleGrid.ProgressBarJSON.WeekDataList[weekDataIndex].AppointmentDate
    	}
   	 	loadState($state, 'AddEditAppointment', {
   	 		AddEditAppointmentParams: appointmentSchedule
        });
   	 	
    }
    $scope.M_WeekScheduleGrid.selectedAppointmentObject = {};
    $scope.F_WeekScheduleGrid.selectDateTimeSchedule = function(weekDataIndex, daySegmentIndex) {
    	if($scope.F_WeekScheduleGrid.isDayBeforeToday(weekDataIndex)) {
    		return;
    	}
        if($rootScope.currentStateName === 'TechScheduler' ) {
        	$scope.M_WeekScheduleGrid.isClickedOnAddeditAppoitmentProgressBar = true;
        	$scope.F_WeekScheduleGrid.openAddEditAppointmentPopup(weekDataIndex, daySegmentIndex);
           	return;
        } 
        if ($rootScope.currentStateName == 'AddEditAppointment' && !$scope.M_WeekScheduleGrid.isClickedOnAddeditAppoitmentProgressBar
        	&& !($scope.M_WeekScheduleGrid.ProgressBarJSON.WeekDataList[weekDataIndex].DaySegments[daySegmentIndex].TotalWorkingHours == 0 && $scope.M_WeekScheduleGrid.ProgressBarJSON.WeekDataList[weekDataIndex].DaySegments[daySegmentIndex].BookedHours == 0)) {
            $scope.M_WeekScheduleGrid.selectedAppointmentObject = {
                    'AppointmentDate': $scope.M_WeekScheduleGrid.ProgressBarJSON.WeekDataList[weekDataIndex].AppointmentDate,
                    'SelectedSegment': daySegmentIndex
                }
            $scope.$emit("getAppointmentTime", $scope.M_WeekScheduleGrid.selectedAppointmentObject);
        }
    }
    
    $scope.$on('resetIsClickedOnAddeditAppoitmentProgressBar', function(event, args) {
 		$scope.M_WeekScheduleGrid.isClickedOnAddeditAppoitmentProgressBar = false;
    });
     
    $scope.F_WeekScheduleGrid.showHideLegendDropdown = function() {
    	$scope.M_WeekScheduleGrid.isShowLegendDropdown = !$scope.M_WeekScheduleGrid.isShowLegendDropdown;
    	$scope.M_WeekScheduleGrid.isRotate = !$scope.M_WeekScheduleGrid.isRotate;
    }
    
   $scope.F_WeekScheduleGrid.hideLegendDropDown = function(){
    		$scope.M_WeekScheduleGrid.isShowLegendDropdown = false;
	    	$scope.M_WeekScheduleGrid.isRotate = false;
    }
}]);