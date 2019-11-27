'use strict';
define(['Routing_AppJs_PK', 'AutoComplete_V2', 'JqueryUI','BP_Calendar_Nav_Bar'], function(Routing_AppJs_PK, AutoComplete_V2,JqueryUI,BP_Calendar_Nav_Bar) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('TechSchedulerCtrl', ['$scope', '$q', '$rootScope', '$state', '$stateParams', '$translate','$filter', function($scope, $q, $rootScope, $state, $stateParams, $translate,$filter) {
        var Notification = injector.get("Notification");
        /*Variables declaration*/
        $scope.M_TechSchedule = $scope.M_TechSchedule || {};
        $scope.F_TechSchedule = $scope.F_TechSchedule || {};
        $scope.M_TechSchedule.isAppointmentSelected = true;
        $scope.M_TechSchedule.showDropDown = false;
        $scope.M_TechSchedule.selectedType = 'Appointment Scheduler';
        /*Methods declaration*/
        $scope.F_TechSchedule.setActiveTab = function (selectedType) {
        	$scope.M_TechSchedule.selectedType = selectedType;
        	if(window.innerWidth <= 767){
        		$scope.M_TechSchedule.selectedType = selectedType;
        	}else {
        		if (selectedType === 'Appointment Scheduler') {
                    $scope.M_TechSchedule.isAppointmentSelected = true;
                } else {
                	$scope.M_TechSchedule.isAppointmentSelected = false;
                }
        	}
        	
        	if($scope.M_TechSchedule.selectedType === 'Job Scheduler') {
        		$scope.F_TechSchedule.MoveToState('TechScheduler.JobScheduler');
        	} else if($scope.M_TechSchedule.selectedType === 'Appointment Scheduler') {
        		$scope.F_TechSchedule.MoveToState('TechScheduler');
        	}
        }
        
        $scope.F_TechSchedule.switchToOtherSchedulerTab = function () {
        	if($scope.M_TechSchedule.selectedType === 'Appointment Scheduler') {
        		$scope.F_TechSchedule.setActiveTab('Job Scheduler');
        	} else {
        		$scope.F_TechSchedule.setActiveTab('Appointment Scheduler');
        	}
        }
        
        $scope.F_TechSchedule.setFocusOnInput = function(elementId) {
            angular.element("#" + elementId).focus();
        }
        
        $scope.F_TechSchedule.openAddEditAppointmentPopup = function(){
        	 loadState($state, 'AddEditAppointment');
        }
        
        $scope.F_TechSchedule.MoveToState = function(stateName, attr) {
            if(attr) {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
    }])
});