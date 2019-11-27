'use strict';
define(['Routing_AppJs_PK', 'AutoComplete_V2', 'JqueryUI','BP_Calendar_Nav_Bar','JobSchedulerServices','underscore_min','moment'], function(Routing_AppJs_PK, AutoComplete_V2,JqueryUI,BP_Calendar_Nav_Bar,JobSchedulerService,underscore_min,moment) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('JobSchedulerCtrl', ['$scope', '$q', '$rootScope', '$state', '$stateParams', '$translate','$filter', 'JobSchedulerService','$compile', function($scope, $q, $rootScope, $state, $stateParams, $translate, $filter, JobSchedulerService,$compile) {
        var Notification = injector.get("Notification");
        /*Variables declaration*/
        var expandablePulloutWidth = 315;
         var expandablePulloutHeight = 220;
        $scope.M_JobScheduler = $scope.M_JobScheduler || {};
        $scope.F_JobScheduler = $scope.F_JobScheduler || {};
        $scope.M_JobScheduler.currentDate = '';
        $scope.M_JobScheduler.isLoading = false;
        $scope.M_JobScheduler.isShowLegendDropdown = false;
        $scope.M_JobScheduler.dateFormat = $Global.SchedulingDateFormat;
         $scope.M_JobScheduler.noOfUnassignedAppointment = 0;
         $scope.M_JobScheduler.CurrentUserTZSIDKey = $Global.CurrentUserTZSIDKey;
        $scope.M_JobScheduler.ShopSettingData = [];
        $scope.M_JobScheduler.noOfSlotsOnScalingGrid = 0;
        $scope.M_JobScheduler.TotalBookedHours = 0 ;
         $scope.M_JobScheduler.TotalAvailableHours = 0 ;
		$scope.M_JobScheduler.unAssignedAppointments = {
                'Morning': [],
                'Afternoon': []
        }
		$scope.M_JobScheduler.StateName = 'JobScheduler';
        $scope.M_JobScheduler.flyOutAppointmentData = {};
       $scope.M_JobScheduler.appointmentPopoverPosition = 'left';
        $scope.M_JobScheduler.isToggled = false;
         $scope.M_JobScheduler.isToggledInMobileView = false;
        $scope.M_JobScheduler.showUnAssignedAppointmentPopUp = false;
        $scope.M_JobScheduler.isFromPullOut = false;
        $scope.M_JobScheduler.showToolTip = false;
      $scope.F_JobScheduler.toggle = function(id) {
            if (window.innerWidth <= 767) {
                $scope.M_JobScheduler.isToggledInMobileView = !$scope.M_JobScheduler.isToggledInMobileView;
            } else {
                $scope.M_JobScheduler.isToggled = !$scope.M_JobScheduler.isToggled;
            }
            if($scope.M_JobScheduler.isToggled) {
            	$scope.M_JobScheduler.isToggledInMobileView = false;
                var expandableElement = angular.element('#' + id);
                $scope.M_JobScheduler.showToolTip = false;
                expandElementToLeft(expandableElement, expandablePulloutWidth);
            } else {
                collapsePullOutToRight(id);
            }
            
            if($scope.M_JobScheduler.isToggledInMobileView) {
                var expandableDiv = angular.element('#' + id);
                $scope.M_JobScheduler.isToggled = false;
                var expandableDivChildDivHeight = '';
                expandElement(expandableDiv, expandableDivChildDivHeight, '0.3s');
            } else {
                var collapsableElement = angular.element('#' + id);
                collapseElement(collapsableElement);
            }
            enableOrDisableDraggingOnPullOut();
        }
        
        $scope.F_JobScheduler.showHideLegendDropdown = function() {
            $scope.M_JobScheduler.isShowLegendDropdown = !$scope.M_JobScheduler.isShowLegendDropdown;
            $scope.M_JobScheduler.isRotate = !$scope.M_JobScheduler.isRotate;
        }
        
        $scope.F_JobScheduler.hideLegendDropDown = function(){
            $scope.M_JobScheduler.isShowLegendDropdown = false;
            $scope.M_JobScheduler.isRotate = false;
        }
        
        $scope.F_JobScheduler.openAddEditTechnicianModal = function(technicianRec) {
            var AddEditTechnicianScheduleParams = {
                    CurrentTechId: technicianRec.Id
            };
            loadState($state, 'TechScheduler.JobScheduler.AddEditTechnicianSchedule', {
                AddEditTechnicianScheduleParams: AddEditTechnicianScheduleParams
            });
        }
        
        $scope.F_JobScheduler.saveTechnicianCallback = function() {
        	getTechnicianListForSpecificDay($scope.M_JobScheduler.selectedDate).then(function(sucessResult) {
        		bindAppointmentsOnGrid($scope.M_JobScheduler.selectedDate).then(function(){
        			defineSortable();
        			$scope.M_JobScheduler.isLoading = false;
                });
            });
        }
        
        function collapsePullOutToRight(id) {
            var collapsableElement = angular.element('#' + id);
            collapseElementToRight(collapsableElement);
            $scope.F_JobScheduler.showUnAssignedAppointmentInfo(false);
            $scope.M_JobScheduler.isToggled = false;
            $scope.M_JobScheduler.showToolTip = false;
            enableOrDisableDraggingOnPullOut();
        }
        var scrollTopForAppointmentInfoPopup = 0;
        var widthOfAppointmentInfoPopup = 0;
       $scope.F_JobScheduler.showUnAssignedAppointmentInfo = function(toShow, event, appointmentId, AppointmentDaySegment, isFromUnAssignedPullOut) {
		   if (window.innerWidth <= 767) {
        		if(toShow && $scope.M_JobScheduler.isToggledInMobileView && isFromUnAssignedPullOut) {
                    $scope.M_JobScheduler.isFromPullOut = true;
                    $scope.M_JobScheduler.showUnAssignedAppointmentPopUp = true;
                    getFlyOutAppointmentData(appointmentId,AppointmentDaySegment, true);
                    if(isFromUnAssignedPullOut && event ) {
                        var getAttr = $(event.target).closest("div.appointment-card").attr("rel");
    	             	var divId = $("div.appointment-info-popup").attr("for"); 
    	             	if( divId != getAttr) {
    	                    setTimeout(function(){
    	                        setUnAssignedAppointmentPopUpPosition(event,true);
    	                    },100);
    	             	}
                    }
                }
        	} else if(toShow && $scope.M_JobScheduler.isToggled && isFromUnAssignedPullOut) {
                $scope.M_JobScheduler.isFromPullOut = true;
                $scope.M_JobScheduler.showUnAssignedAppointmentPopUp = true;
                $('#appointmentInfoPopup').fadeIn(800);
                getFlyOutAppointmentData(appointmentId,AppointmentDaySegment, true);
                if(isFromUnAssignedPullOut && event ) {
                    var getAttr = $(event.target).closest("div.appointment-card").attr("rel");
	             	var divId = $("div.appointment-info-popup").attr("for"); 
	             	if( divId != getAttr) {
	                    setTimeout(function(){
	                        setUnAssignedAppointmentPopUpPosition(event,true);
	                    },100);
	             	}
                }
            } else if(toShow && !isFromUnAssignedPullOut) {
                $scope.M_JobScheduler.isFromPullOut = false;
                getFlyOutAppointmentData(appointmentId,AppointmentDaySegment, false);
                if(event) {
                    var getAttr = $(event.target).closest("div.appointment-card").attr("rel");
	             	var divId = $("div.appointment-info-popup").attr("for"); 
	             	var width =  $(event.target).closest("div.appointment-card").outerWidth();
	         		setTimeout(function(){
	                    setUnAssignedAppointmentPopUpPosition(event,false);
                    },100);
                	$('#appointmentInfoPopup').fadeIn(800);
	                    $scope.M_JobScheduler.showUnAssignedAppointmentPopUp = true;
                }
            } else {
            	 $scope.M_JobScheduler.showUnAssignedAppointmentPopUp = false;
            		}
        }
        $scope.F_JobScheduler.isDayBeforeToday = function() {
        	var dateStr = $scope.M_JobScheduler.selectedDate;
        	var currentDate = moment(moment().tz($scope.M_JobScheduler.CurrentUserTZSIDKey).format($scope.M_JobScheduler.dateFormat), $scope.M_JobScheduler.dateFormat);
        	if (moment(dateStr, $scope.M_JobScheduler.dateFormat).diff(currentDate, 'days') < 0) {
        		return true;
        	}
        	return false;
        }
        
        $scope.F_JobScheduler.isAppTimeExceedsShopHours = function(appointmentRecEndTime) {
        	var dayValue = moment($scope.M_JobScheduler.selectedDate).format('dddd');
            var indexVal = _.findIndex($scope.M_JobScheduler.shopSettingDataFromServer, {'Day': dayValue});
            var shopSettingDataForSelectedDay = $scope.M_JobScheduler.shopSettingDataFromServer[indexVal];
            var shopEndTime = moment(shopSettingDataForSelectedDay.ToTime, 'h:mmA');
            var appointmentEndTime = moment(appointmentRecEndTime, 'h:mmA');
            var exceededShopHoursInMinutes = appointmentEndTime.diff(shopEndTime, 'minutes');
            if (exceededShopHoursInMinutes > 0) {
                return true;
            }
            return false;
        } 
       function getFlyOutAppointmentData(appointmentId,AppointmentDaySegment, isFromUnAssignedPullOut) {
            if(isFromUnAssignedPullOut) {
                if(AppointmentDaySegment === 'Morning') {
                    for(var i =0 ; i < $scope.M_JobScheduler.unAssignedAppointments['Morning'].length ; i++) {
                        if($scope.M_JobScheduler.unAssignedAppointments['Morning'][i].Id == appointmentId) {
                            $scope.M_JobScheduler.flyOutAppointmentData = $scope.M_JobScheduler.unAssignedAppointments['Morning'][i];
                        }
                    }
                } else {
                    for(var i =0 ; i < $scope.M_JobScheduler.unAssignedAppointments['Afternoon'].length ; i++) {
                        if($scope.M_JobScheduler.unAssignedAppointments['Afternoon'][i].Id == appointmentId) {
                            $scope.M_JobScheduler.flyOutAppointmentData = $scope.M_JobScheduler.unAssignedAppointments['Afternoon'][i];
                        }
                    }
                }
            } else {
        		Object.keys($scope.M_JobScheduler.technicianIdToAppointmentListMap).forEach(function(key) {
        			var appointmentIdFound = false;
        			for(var j =0 ; j < $scope.M_JobScheduler.technicianIdToAppointmentListMap[key].length ; j++) {
		            	if($scope.M_JobScheduler.technicianIdToAppointmentListMap[key][j].Id == appointmentId) {
		            		$scope.M_JobScheduler.flyOutAppointmentData = $scope.M_JobScheduler.technicianIdToAppointmentListMap[key][j];
		            		appointmentIdFound = true;
		            		break;
		            	}
        			}
        		});
            }
        }
        
        $scope.notSorted = function(obj) {
            if (!obj) {
                return [];
            }
            return Object.keys(obj);
        }
        
        $(document).ready(function(){
            $('[data-toggle="tooltip"]').tooltip();
        });
        
        $scope.F_JobScheduler.setTooltipPosition = function (event) {
        if (window.innerWidth <= 767) {
        		$scope.M_JobScheduler.showToolTip = false;
        		return;
        	}
        	$scope.M_JobScheduler.showToolTip = true;
        	setTimeout(function(){
        		var scrollTopPosition = $(window).scrollTop();
            	console.log(scrollTopPosition);
            	if(scrollTopPosition > 250) {
            		scrollTopPosition = scrollTopPosition - 100;
            		$("#tooltipUnassigned").css('top',scrollTopPosition + 'px');
            	}
        	},100);
        }
        
        $scope.F_JobScheduler.resetTooltipPosition = function () {
        	$scope.M_JobScheduler.showToolTip = false;
        }
        
         function setUnAssignedAppointmentPopUpPosition(event,isFromUnAssigned) {
        	if(isFromUnAssigned) {
        		if(window.innerWidth <= 767 ) {
        			var targetEle = $(event.target).closest("div.appointment-card");
        			if(targetEle.offset().left < (angular.element("#appointmentInfoPopup").outerWidth()/2)) {
        				angular.element("#appointmentInfoPopup").addClass('left-arrrow');
        				angular.element("#appointmentInfoPopup").removeClass('up-arrrow');
	            	    angular.element("#appointmentInfoPopup").removeClass('down-arrrow');
	            	    angular.element("#appointmentInfoPopup").removeClass('right-arrrow');
	            	    angular.element("#appointmentInfoPopup").css('left', targetEle.offset().left + targetEle[0].clientWidth);
	            	    angular.element("#appointmentInfoPopup").css('top', targetEle.offset().top - 240 - (angular.element("#appointmentInfoPopup").outerHeight()/2));
        			} else if(targetEle.offset().left + angular.element("#appointmentInfoPopup").outerWidth() >= window.innerWidth){
        				angular.element("#appointmentInfoPopup").removeClass('up-arrrow');
	            	    angular.element("#appointmentInfoPopup").removeClass('down-arrrow');
	            	    angular.element("#appointmentInfoPopup").removeClass('left-arrrow');
        				angular.element("#appointmentInfoPopup").addClass('right-arrrow');
        				angular.element("#appointmentInfoPopup").css('top', targetEle.offset().top - 240 - (angular.element("#appointmentInfoPopup").outerHeight()/2));
        				angular.element("#appointmentInfoPopup").css('left', targetEle.offset().left - angular.element("#appointmentInfoPopup").outerWidth());
        			} else {
	        			angular.element("#appointmentInfoPopup").removeClass('up-arrrow');
	            	    angular.element("#appointmentInfoPopup").removeClass('right-arrrow');
	            	    angular.element("#appointmentInfoPopup").removeClass('left-arrrow');
	            	    angular.element("#appointmentInfoPopup").css('top', targetEle.offset().top - 240 - angular.element("#appointmentInfoPopup").outerHeight() - 55);
	                	angular.element("#appointmentInfoPopup").css('left', targetEle.offset().left - (angular.element("#appointmentInfoPopup").outerWidth()/2) + (targetEle[0].clientWidth / 2));
	                	angular.element("#appointmentInfoPopup").addClass('down-arrrow');
        			}
        		} else {
        			var targetEle = $(event.target).closest("div.appointment-card");
            	    angular.element("#appointmentInfoPopup").removeClass('up-arrrow');
            	    angular.element("#appointmentInfoPopup").removeClass('down-arrrow');
            	    angular.element("#appointmentInfoPopup").addClass('right-arrrow');
            	    var topPosition = targetEle.offset().top - 220 - 35;
            	    var leftPosition = 725 ;
            	    angular.element("#appointmentInfoPopup").css('left', leftPosition);
            	    angular.element("#appointmentInfoPopup").css('top', topPosition );
        		}
          } else {
        	var targetEle = $(event.target).closest("div.appointment-card");
            if ((((targetEle.offset().top ) - window.scrollY > angular.element("#appointmentInfoPopup").outerHeight() + 50))){
            	angular.element("#appointmentInfoPopup").addClass('down-arrrow');
            	angular.element("#appointmentInfoPopup").removeClass('up-arrrow');
            	angular.element("#appointmentInfoPopup").removeClass('right-arrrow');
            	angular.element("#appointmentInfoPopup").css('top', targetEle.offset().top - 227 - angular.element("#appointmentInfoPopup").outerHeight());
            	angular.element("#appointmentInfoPopup").css('left', targetEle.offset().left - (angular.element("#appointmentInfoPopup").outerWidth() / 2) + targetEle[0].clientWidth / 2);
            }else{
            	angular.element("#appointmentInfoPopup").removeClass('down-arrrow');
            	angular.element("#appointmentInfoPopup").addClass('up-arrrow');
            	angular.element("#appointmentInfoPopup").removeClass('right-arrrow');
            	angular.element("#appointmentInfoPopup").css('left', targetEle.offset().left + targetEle[0].clientWidth / 2 - 160);
            	angular.element("#appointmentInfoPopup").css('top', targetEle.offset().top + targetEle.outerHeight() - 210 );
            	
            }
          }
        }
                
        $scope.F_JobScheduler.openCustomerOrder = function (event) {
        	$scope.M_JobScheduler.showUnAssignedAppointmentPopUp = false; 
        	$scope.F_JobScheduler.moveToState('CustomerOrder_V2',{Id:$scope.M_JobScheduler.flyOutAppointmentData.COId});
        }
        
        function loadAddEditAppointment(appointmentData, isEdit) {
        	loadState($state, 'AddEditAppointment', {
         		AddEditAppointmentParams : {
         				appointmentData : appointmentData,
         				isEdit : isEdit
         		}
             });
        }
        
        $scope.F_JobScheduler.openEditAppointmentPopup = function(isFromPullOut, event, id) {
        	if(event) {
        		event.preventDefault();
        		 var targetEle = angular.element(event.target);
        		 if($(targetEle[0]).closest("p").attr("id") == 'appointmentCOHeaderID') {
             		return;
             	 } else if($(targetEle[0]).closest("div").attr("id") == 'CONumberId') {
             		return;
        		 } else {
             		$scope.M_JobScheduler.showUnAssignedAppointmentPopUp = false; 
             		loadAddEditAppointment(angular.copy($scope.M_JobScheduler.flyOutAppointmentData), true);
             	 }
        	} else {
        		if(window.innerWidth <= 767 && $scope.M_JobScheduler.isToggledInMobileView && isFromPullOut) {
            		collapsePullOutToRight('appointmentNav');
            		$scope.M_JobScheduler.showUnAssignedAppointmentPopUp = false; 
             		loadAddEditAppointment(angular.copy($scope.M_JobScheduler.flyOutAppointmentData), true);
            	}
        		else if($scope.M_JobScheduler.isToggled && isFromPullOut) {
            		collapsePullOutToRight('appointmentNav');
            		$scope.M_JobScheduler.showUnAssignedAppointmentPopUp = false; 
             		loadAddEditAppointment(angular.copy($scope.M_JobScheduler.flyOutAppointmentData), true);
            	} else if (!isFromPullOut) {
            		collapsePullOutToRight('appointmentNav');
            		$scope.M_JobScheduler.showUnAssignedAppointmentPopUp = false; 
             		loadAddEditAppointment(angular.copy($scope.M_JobScheduler.flyOutAppointmentData), true);
            	}
        	}
        }
        
        $scope.F_JobScheduler.moveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
            	var url = $state.href(stateName, attr);
                window.open(url, '_blank');
            } else {
                loadState($state, stateName);
            }
        }
        
        angular.element(document).on("click", function(e) {
            if(e.target && (!angular.element(e.target).closest('div#allignPullOutIcon').length)
            		&& (!angular.element(e.target).closest('p#pullOutIcon').length)
            		&& e.target.id  !== 'appointmentNav'
            		&& angular.element('#appointmentNav').hasClass('expand-div-width-transition') && (!angular.element(e.target).closest('div.appointment-card').length) 
            		&& (!angular.element(e.target).closest('div.un-assigned-infopopup').length)) {
            		collapsePullOutToRight('appointmentNav');
            }
        });
        
        function getShopSettingData(selectedDate) {
            var defer = $q.defer();
            JobSchedulerService.getShopSettingData().then(function(shopSettingData) {
                $scope.M_JobScheduler.ShopSettingData = [];
                $scope.M_JobScheduler.shopSettingDataFromServer = shopSettingData;
                getBusinessHoursForSelectedDay(selectedDate);
                console.log("getShopSettingData");
                defer.resolve();
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
            return defer.promise;
        }
        
        function getBusinessHoursForSelectedDay(selectedDate) {
            var dayValue = moment(selectedDate).format('dddd');
            var indexVal = _.findIndex($scope.M_JobScheduler.shopSettingDataFromServer, {'Day': dayValue});
            var shopSettingDataForSelectedDay = $scope.M_JobScheduler.shopSettingDataFromServer[indexVal];
            var shopStartTime = moment(shopSettingDataForSelectedDay.FromTime, 'h:mmA');
            var shopEndTime = moment(shopSettingDataForSelectedDay.ToTime, 'h:mmA');
            
            $scope.M_JobScheduler.ShopSettingData.push({timeSlot: shopSettingDataForSelectedDay.FromTime});
            if(shopSettingDataForSelectedDay.FromTime.indexOf(':30') > -1) {
        		var newTime = shopStartTime.add(30,'m').format("h:mmA");
                $scope.M_JobScheduler.ShopSettingData.push({timeSlot: newTime});
                shopStartTime = moment(newTime, 'h:mmA');
                //$scope.M_JobScheduler.colspanValueForFirstTimeSlot = 2;
        	}
            var totalBusinessHours = shopEndTime.diff(shopStartTime, 'minutes')/30;
            createTimeDropDown(selectedDate, shopStartTime, shopEndTime, totalBusinessHours);
        }
        
        function createTimeDropDown(selectedDate, FromTime, ToTime, totalHours) {
        	var timevalue = moment(FromTime, 'h:mmA');
            for (var i = 0; i < totalHours; i++) {
                var newTime = timevalue.add(30,'m').format("h:mmA");
                $scope.M_JobScheduler.ShopSettingData.push({timeSlot: newTime});
                timevalue = moment(newTime, 'h:mmA');
            }
        	$scope.M_JobScheduler.noOfSlotsOnScalingGrid = ($scope.M_JobScheduler.ShopSettingData.length * 2) - 2;
        }
        
        $scope.F_JobScheduler.showBusinessHours = function(timeSlot) {
        	var timePeriod;
        	if(timeSlot.indexOf(':00') > -1 && (timeSlot != $scope.M_JobScheduler.ShopSettingData[$scope.M_JobScheduler.ShopSettingData.length - 1].timeSlot)) {
        		timePeriod = ((timeSlot.indexOf('AM') > -1) || timeSlot.indexOf('am') > -1) ? 'am' : 'pm';
        		return timeSlot.split(':')[0] + ' ' + timePeriod;
        	} else {
        		return '';
        	}
        }
        
        function getTechnicianListForSpecificDay(selectedDate) {
            var defer = $q.defer();
            JobSchedulerService.getTechnicianListForSpecificDay(selectedDate.format($scope.M_JobScheduler.dateFormat)).then(function(techniciansData) {
                $scope.M_JobScheduler.technicianList = techniciansData;
                calculateTotalBussinessHours();
               console.log($scope.M_JobScheduler.technicianList)
                defer.resolve();
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
            return defer.promise;
        }
        
        function calculateTotalBussinessHours() {
        	 $scope.M_JobScheduler.TotalBookedHours = 0 ;
             $scope.M_JobScheduler.TotalAvailableHours = 0 ;
        	for(var i=0 ; i < $scope.M_JobScheduler.technicianList.length ; i++) {
        		$scope.M_JobScheduler.TotalBookedHours += $scope.M_JobScheduler.technicianList[i].BookedHours ;
                $scope.M_JobScheduler.TotalAvailableHours += $scope.M_JobScheduler.technicianList[i].AvailableHours ;
        	}
        }
        
        function getAssignedAppointmentForSpecificDay(selectedDate) {
        	$scope.M_JobScheduler.isLoading = true;
            var defer = $q.defer();
            JobSchedulerService.getAssignedAppointmentForSpecificDay(selectedDate.format($scope.M_JobScheduler.dateFormat)).then(function(assignedAppointments) {
                $scope.M_JobScheduler.technicianIdToAppointmentListMap = assignedAppointments;
                increaseBusinessHoursOnView(selectedDate).then(function(){
                	setTimeout(function() {
                		bindAppointmentsOnGrid(selectedDate).then(function(){
                			defineSortable();
                			console.log("getAssignedAppointmentForSpecificDay");
                			defer.resolve();
                        });
                	}, 500);
                });
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
            return defer.promise;
        }
        
          $(window).resize(function(){
           	if(!$scope.M_JobScheduler.isLoading) {
	           	$scope.M_JobScheduler.isLoading = true;
	           	bindAppointmentsOnGrid($scope.M_JobScheduler.selectedDate).then(function(){
	           		defineSortable();
               		$scope.M_JobScheduler.isLoading = false;
               		enableOrDisableDraggingOnPullOut();
               		if(window.innerWidth >= 767) {
               			$scope.M_JobScheduler.isToggledInMobileView = false;
               		} else {
               			$scope.M_JobScheduler.isToggled = false;
               		}
	           	});
           	}
       });
        
        function increaseBusinessHoursOnView(selectedDate) {
        	var defer = $q.defer();
        	var dayValue = moment(selectedDate).format('dddd');
            var indexVal = _.findIndex($scope.M_JobScheduler.shopSettingDataFromServer, {'Day': dayValue});
            var shopSettingDataForSelectedDay = $scope.M_JobScheduler.shopSettingDataFromServer[indexVal];
            var shopEndTime = moment(shopSettingDataForSelectedDay.ToTime, 'h:mmA');
        	var maxTimeForAppointment = shopEndTime;
        	var appointmentEndTime;
        	Object.keys($scope.M_JobScheduler.technicianIdToAppointmentListMap).forEach(function(key) {
    			for(var j = 0; j < $scope.M_JobScheduler.technicianIdToAppointmentListMap[key].length ; j++) {
    				appointmentEndTime = moment($scope.M_JobScheduler.technicianIdToAppointmentListMap[key][j].EndTime, 'h:mmA');
	            	if(maxTimeForAppointment.diff(appointmentEndTime, 'minutes') < 0) {
	            		maxTimeForAppointment = appointmentEndTime;
	            	}
    			}
    		});
        	var totalHours = maxTimeForAppointment.diff(shopEndTime, 'minutes')/30;
        	addTimeSlotsToScaleGrid(shopEndTime, totalHours);
        	defer.resolve();
        	return defer.promise;
        }
        
        function addTimeSlotsToScaleGrid(shopEndTime, totalHours) {
        	var timevalue = moment(shopEndTime, 'h:mmA');
        	for (var i = 0; i < totalHours; i++) {
                var newTime = timevalue.add(30,'m').format("h:mmA");
                $scope.M_JobScheduler.ShopSettingData.push({timeSlot: newTime});
                timevalue = moment(newTime, 'h:mmA');
            }
        	$scope.M_JobScheduler.noOfSlotsOnScalingGrid = ($scope.M_JobScheduler.ShopSettingData.length * 2) - 2;
        }
        
        function createScaleGridAndBindLeaves() {
        	var scalableGridContainer = angular.element(".scale-table");
            $(scalableGridContainer).find("tbody tr:not('.add-new-technician-action-row') td").remove();
            var template1 = '';
            var colspanVal = 1;
            
           for(var i =0; i<$scope.M_JobScheduler.technicianList.length; i++) {
        	   var totalcolOnLeave = 0;
            	var scalableGridtr = $(scalableGridContainer).find('tbody tr:not(.add-new-technician-action-row)')[i];
            	for(var g=0; g < $scope.M_JobScheduler.noOfSlotsOnScalingGrid; g++ ) {
            		var templatetd = "<td class='slot-from-scaling-grid' colspan = 1></td>"
            			var newTableElement1 = $(templatetd);
            		newTableElement1 = $compile(newTableElement1)($scope);
                   $(scalableGridtr).append(newTableElement1[0]);
            	}
            	if($scope.M_JobScheduler.technicianList[i].LeaveList.length > 0) {
            		for(var j=0;j<$scope.M_JobScheduler.technicianList[i].LeaveList.length;j++){
                		var startTime=moment($scope.M_JobScheduler.ShopSettingData[0].timeSlot , "HH:mma");
                		var shopEndTime = moment($scope.M_JobScheduler.ShopSettingData[$scope.M_JobScheduler.ShopSettingData.length-1].timeSlot,"HH:mma");
                    	var leaveStartTime=moment($scope.M_JobScheduler.technicianList[i].LeaveList[j].FromTime, "HH:mma");
                    	var leaveToTime=moment($scope.M_JobScheduler.technicianList[i].LeaveList[j].ToTime, "HH:mma");
                    	if(parseInt(moment.duration(shopEndTime.diff(leaveToTime)).asMinutes())<0) {
                    		leaveToTime = shopEndTime;
                    	}
                    	var duration = moment.duration(leaveStartTime.diff(startTime));
                    	var minutes = parseInt(duration.asMinutes());
                    	var startTdIndex = (minutes /15) - totalcolOnLeave ;
                    	var toTimeDuration = moment.duration(leaveToTime.diff(startTime));
                    	var toTimeminutes = parseInt(toTimeDuration.asMinutes());
                    	var endTdIndex = (toTimeminutes /15)  - totalcolOnLeave;
                    	colspanVal = endTdIndex - startTdIndex;
						if(colspanVal != 0 && startTdIndex <= $(scalableGridtr).find("td").length) {
							$(scalableGridtr).find("td")[startTdIndex].colSpan = colspanVal;
	                    	var addTdClass = $(scalableGridtr).find("td")[startTdIndex];
	                    	$(addTdClass).addClass("P0");
	                        template1 += '<div class="leave-container text-uppercase full-day-leave-tr"> <span ng-if = "' + $(scalableGridtr).find("td")[startTdIndex].colSpan + ' > 5" class = "leave-text">'+$translate.instant('Annual_leave')+'</span></div>';
	                    	var newTableElement1 = $(template1);
	                    	newTableElement1 = $compile(newTableElement1)($scope);
	                        var appendtdIElement = $(scalableGridtr).find("td")[startTdIndex];
	                        if(colspanVal % 2 == 0 ){
	                        	$(appendtdIElement).addClass("leave-right-border");
	                        }
	                        $(appendtdIElement).append(newTableElement1[0]);
	                        if(($(scalableGridtr).find("td").length + totalcolOnLeave) == $scope.M_JobScheduler.noOfSlotsOnScalingGrid){
	                        	for(var k = startTdIndex +1; k<colspanVal + startTdIndex;k++){
	                        		$(scalableGridtr).find("td")[startTdIndex +1].remove();
	                             }
	                        }
                        totalcolOnLeave += colspanVal -1;
						}
                	}
            	}else  {
            	}
            	$(scalableGridtr).find('td').removeClass("left-border")
        		$(scalableGridtr).find('td').removeClass("right-border")
            	for(var count = 0 , col = 0; count<$(scalableGridtr).find('td').length; count++ ){
            		var tdElement = $(scalableGridtr).find('td')[count];
            		if(col%2 == 0 ) {
            			$(tdElement).addClass("left-border")
            		}else {
            			$(tdElement).addClass("right-border")
            		}
            		col+= parseInt($(tdElement).attr('colspan'));
            	}
            	
            }
        }
        
        function bindAppointmentsOnGrid(selectedDate) {
            var defer = $q.defer();
            createScaleGridAndBindLeaves();
            angular.element(".grid-container").find(" table#overlaped-table").remove();
            var template = '';
            template += '<table id="overlaped-table" class="table overlaped-table M0">';
            template += '<tbody>';
            var colspanVal = 1;
            var appointmentCardWidth = 0;
            var overlappedTableTdWidth = 0;
            var count;
           angular.forEach($scope.M_JobScheduler.technicianList, function(technicianRec,index) {
                var count = 0;
        		var tdIndex = 0;
        		console.log(index);
                /*template += '<tr for ="overlappedTableTrId'+technicianRec.Id+'"  id="overlappedTableTrId'+technicianRec.Id+'" class="sortable"' +
                                'ng-class = "{\'lessbooked-state-hover\' : ' +  technicianRec.BookedHours + ' <= '+ technicianRec.AvailableHours + ','+
                                '\'fullDayLeave\': ' + technicianRec.IsFullDayLeave + '\ == true }">';*/
/*        		if(!technicianRec.IsFullDayLeave) {
*/        			template += '<tr for ="overlappedTableTrId'+technicianRec.Id+'"  id="overlappedTableTrId'+technicianRec.Id+'" class="sortable"' +
                    'ng-class = "{\'lessbooked-state-hover\' : ' +  technicianRec.BookedHours + ' <= '+ technicianRec.AvailableHours + ','+
                    '\'fullDayLeave\': ' + technicianRec.IsFullDayLeave + '\ == true }">';
/*} else {
        			template += '<tr for ="overlappedTableTrId'+technicianRec.Id+'"  id="overlappedTableTrId'+technicianRec.Id+'" class=" full-day-leave-tr"' +
                    'ng-class = "{\'lessbooked-state-hover\' : ' +  technicianRec.BookedHours + ' <= '+ technicianRec.AvailableHours + ','+
                    '\'fullDayLeave\': ' + technicianRec.IsFullDayLeave + '\ == true }">';
        		}*/
                if($scope.M_JobScheduler.technicianIdToAppointmentListMap.hasOwnProperty(technicianRec.Id)
                        && $scope.M_JobScheduler.technicianIdToAppointmentListMap[technicianRec.Id].length > 0) {
                    angular.forEach($scope.M_JobScheduler.technicianIdToAppointmentListMap[technicianRec.Id], function(appointmentRec) {
                        var noOfTdsToSkipOnScaleGrid = calculateNoOfTdsToSkipOnScaleGrid(selectedDate, appointmentRec, count);
                        for(var i=0; i<noOfTdsToSkipOnScaleGrid; i++) {
                            overlappedTableTdWidth = calculateOverlappedTableTdWidth(count, 1,$scope.M_JobScheduler.technicianList.length);
                            template += '<td class="sortable-ui-state-disabled" id="overlappedTableTdId'+technicianRec.Id+tdIndex+'" style="width:' + overlappedTableTdWidth + 'px"></td>';
                            count += 1;
                            tdIndex += 1;
                        }
                        colspanVal = (appointmentRec.EstimatedHours * 100)/25;
                        colspanVal = colspanVal ? colspanVal : 1;
                        appointmentCardWidth = calculateAppointmentCardWidth(count, colspanVal,$scope.M_JobScheduler.technicianList.length);
                        overlappedTableTdWidth = calculateOverlappedTableTdWidth(count, colspanVal,$scope.M_JobScheduler.technicianList.length);
                        template += '<td id="overlappedTableTdId'+technicianRec.Id+tdIndex+'" class="appointment-container-td" colspan="' + colspanVal + '" style="width:' + overlappedTableTdWidth + 'px">';
                        template += createAppointmentCard(appointmentCardWidth, appointmentRec);
                        template += '</td>';
                        count += colspanVal ;
                        tdIndex += 1;
                    });
                    if(count > $scope.M_JobScheduler.noOfSlotsOnScalingGrid) {
                    } else if(count < $scope.M_JobScheduler.noOfSlotsOnScalingGrid) {
                        var colspanForRemianingTds = $scope.M_JobScheduler.noOfSlotsOnScalingGrid - count;
                        for(var i=0; i<colspanForRemianingTds; i++) {
                            overlappedTableTdWidth = calculateOverlappedTableTdWidth(count, 1,$scope.M_JobScheduler.technicianList.length);
                            template += '<td class="sortable-ui-state-disabled" id="overlappedTableTdId'+technicianRec.Id+tdIndex+'" style="width:' + overlappedTableTdWidth + 'px"></td>';
                            count += 1;
                            tdIndex += 1;
                        }
                    }
                }/*else if(technicianRec.IsFullDayLeave) {
                    overlappedTableTdWidth = calculateOverlappedTableTdWidth(count, $scope.M_JobScheduler.noOfSlotsOnScalingGrid);
                    template += '<td colspan="' + $scope.M_JobScheduler.noOfSlotsOnScalingGrid + '" id="overlappedTableTdId'+technicianRec.Id+tdIndex+'" style="width:' + overlappedTableTdWidth + 'px">'
                    template += '<div class="leave-container text-uppercase">'+$translate.instant('Annual_leave')+'</div>';
                    template += '</td>';
                    tdIndex += 1;
                }*/ else {
                    for(var i=0; i<$scope.M_JobScheduler.noOfSlotsOnScalingGrid; i++) {
                        overlappedTableTdWidth = calculateOverlappedTableTdWidth(count, 1,$scope.M_JobScheduler.technicianList.length);
                        template += '<td class="sortable-ui-state-disabled" id="overlappedTableTdId'+technicianRec.Id+tdIndex+'" style="width:' + overlappedTableTdWidth + 'px"></td>';
                        count += 1;
                        tdIndex += 1;
                    }
                }
                template += '</tr>';
            });
            template += '<tr class="add-new-technician-action-row">';
            overlappedTableTdWidth = calculateOverlappedTableTdWidth(0, $scope.M_JobScheduler.noOfSlotsOnScalingGrid,$scope.M_JobScheduler.technicianList.length);
            template += '<td colspan="' + $scope.M_JobScheduler.noOfSlotsOnScalingGrid + '" style="width:' + overlappedTableTdWidth + 'px"></td>';
            /*for(var i=0; i<$scope.M_JobScheduler.noOfSlotsOnScalingGrid; i++) {
            	overlappedTableTdWidth = calculateOverlappedTableTdWidth(i, 1,$scope.M_JobScheduler.noOfSlotsOnScalingGrid,$scope.M_JobScheduler.technicianList.length);
                template += '<td style="width:' + overlappedTableTdWidth + 'px"></td>';
            }*/
            template += '</tr>';
            template += '</tbody>';
            template += '</table>';
            var newTableElement = angular.element(template);
            newTableElement = $compile(newTableElement)($scope);
            angular.element('.grid-container').append(newTableElement);
            defer.resolve();
            return defer.promise;
        }
        
        function calculateNoOfTdsToSkipOnScaleGrid(selectedDate, appointmentRec, count) {
        	var noOfTdsToSkipOnScaleGrid = 0;
    		var dayValue = moment(selectedDate).format('dddd');
        	var indexVal = _.findIndex($scope.M_JobScheduler.shopSettingDataFromServer, {'Day': dayValue});
        	var shopSettingDataForSelectedDay = $scope.M_JobScheduler.shopSettingDataFromServer[indexVal];
        	var appointmentStartTime = moment(appointmentRec.StartTime, 'h:mmA');
        	var shopStartTime = moment(shopSettingDataForSelectedDay.FromTime, 'h:mmA');
        	noOfTdsToSkipOnScaleGrid = (appointmentStartTime.diff(shopStartTime, 'm'))/15;
        	noOfTdsToSkipOnScaleGrid = noOfTdsToSkipOnScaleGrid - count;
        	return noOfTdsToSkipOnScaleGrid;
        }
        
        function calculateAppointmentCardWidth(count, colspanVal,trIndex) {
            var appointmentCardWidth = 0;
            for(var i=colspanVal; i>0; i--) {
                appointmentCardWidth += angular.element(angular.element(angular.element('.scale-table > tbody').find('tr')[trIndex]).find('td')[count -1 + i]).outerWidth();
            }
            return appointmentCardWidth;
        }
        
        function calculateOverlappedTableTdWidth(count, colspanVal,trIndex) {
            var tdWidth = 0;
            for(var i=colspanVal; i>0; i--) {
                tdWidth += angular.element(angular.element(angular.element('.scale-table > tbody').find('tr')[trIndex]).find('td')[count -1 + i]).outerWidth();
            }
            return tdWidth;
        }
         
        function createAppointmentCard(cardWidth, appointmentRec) {
            var appointmentCardTemplate = '';
            appointmentCardTemplate += '<div id="'+appointmentRec.Id+'" class="appointment-card bp-cursor-pointer" style="width:' + cardWidth + 'px"' +
       	 	'ng-mouseover="F_JobScheduler.showUnAssignedAppointmentInfo(true, $event, \'' + appointmentRec.Id + '\', null, false)"' + 
       	 	'ng-class = "{'+
       	 	'\'bp-main-bg-cyan\': \'' + appointmentRec.TransactionType + '\' == \'Customer\', ' +
	   	 	'\'bp-main-bg-purple\': \'' + appointmentRec.TransactionType + '\' == \'Deal Service\', ' +
	   	 	' \'bp-main-bg-orange\': \'' + appointmentRec.TransactionType + '\' == \'Internal\' || \'' + appointmentRec.TransactionType + '\' == \'Stock Unit\', ' +
	       	'\'bp-main-bg-green\': \'' + appointmentRec.TransactionType + '\' == \'Third-Party\' }" ' + 
	        ' rel = ' +appointmentRec.Id + ' ng-mouseleave="F_JobScheduler.showUnAssignedAppointmentInfo(false, $event)" ' + 
        	' ng-click="F_JobScheduler.openEditAppointmentPopup(false,$event)" >';
        	appointmentCardTemplate += '<div class="no-of-hours estimated-hours" ng-class="{\'bp-main-bg-coral\' :  (F_JobScheduler.isDayBeforeToday() || F_JobScheduler.isAppTimeExceedsShopHours(\''+appointmentRec.EndTime+'\'))}" ng-if = "' + appointmentRec.EstimatedHours + ' > 0.25">' + appointmentRec.EstimatedHours + '</div>';
        	appointmentCardTemplate += '<div class="appointment-list-container bp-set-text-ellipses" ng-if = "' + appointmentRec.EstimatedHours + ' > 0.5" >';
            appointmentCardTemplate += '<p class="unit-details line-height-large M0 bp-set-text-ellipses text-capitalize bp-font-16">' + appointmentRec.UnitFormattedName + '</p>';
            appointmentCardTemplate += '<p class="customer-name line-height-medium M0 bp-set-text-ellipses text-capitalize bp-font-14">' + appointmentRec.CustomerName + '</p>';
            appointmentCardTemplate += '<p class="line-height-medium M0 CO-number" id="appointmentCOHeaderID"><a class="text-underline bp-font-14" ng-click="F_JobScheduler.openCustomerOrder($event)">' + appointmentRec.CONumber + '</a> </p>';
            appointmentCardTemplate += '</div>';
            appointmentCardTemplate += '</div>';
            return appointmentCardTemplate;
        } 
        
        function overlappedTableTrSortableAction(parentTrId) {
            var appointmentRecList = [];
            var tdNo;
            var dayValue = moment($scope.M_JobScheduler.selectedDate).format('dddd');
            var indexVal = _.findIndex($scope.M_JobScheduler.shopSettingDataFromServer, {'Day': dayValue});
            var shopSettingDataForSelectedDay = $scope.M_JobScheduler.shopSettingDataFromServer[indexVal];
            var shopStartTime = moment(shopSettingDataForSelectedDay.FromTime, 'h:mmA');
            var timevalue = moment(shopStartTime, 'h:mmA');
            var appStartTime;
            var appEndTime;
            //var appointmentRecFound = false;
            var unAssignedAppointmentRecIndex;
            var technicianIndex;
            var technicianId;
            var appointmentIndex;
            var appointmentRecId;
            var colspanValue = 0;
            var totalColspanCount = 0;
        	var unAssignedAppointmentRecToUpdate = {};
            for(var i=0; i<angular.element('#'+parentTrId).find('td').length; i++) {
                if(angular.element(angular.element('#'+parentTrId).find('td')[i]).find('div.appointment-card').length > 0) {
                    timevalue = moment(shopStartTime, 'h:mmA');
                    tdNo = i;
                    appStartTime = timevalue.format("h:mmA");
                    for (var j=0; j<(tdNo+totalColspanCount); j++) {
                        appStartTime = timevalue.add(15,'m').format("h:mmA");
                        timevalue = moment(appStartTime, 'h:mmA');
                    }
                    var appointmentRec = {};
                    var unAssignedAppointmentRec = {};
                    appointmentRecId = angular.element(angular.element('#'+parentTrId).find('td')[i]).find('.appointment-card')[0].id;
                    // Get unAssignedAppointmentRec
                    unAssignedAppointmentRecIndex = _.findIndex($scope.M_JobScheduler.unAssignedAppointments['Morning'], {'Id': appointmentRecId});
                    if(unAssignedAppointmentRecIndex > -1) {
                        unAssignedAppointmentRec = $scope.M_JobScheduler.unAssignedAppointments['Morning'][unAssignedAppointmentRecIndex];
                		unAssignedAppointmentRecToUpdate = angular.copy(unAssignedAppointmentRec);
                    } else {
                        unAssignedAppointmentRecIndex = _.findIndex($scope.M_JobScheduler.unAssignedAppointments['Afternoon'], {'Id': appointmentRecId});
                        if(unAssignedAppointmentRecIndex > -1) {
                            unAssignedAppointmentRec = $scope.M_JobScheduler.unAssignedAppointments['Afternoon'][unAssignedAppointmentRecIndex];
                			unAssignedAppointmentRecToUpdate = angular.copy(unAssignedAppointmentRec);
                        }
                    }
                    technicianIndex = angular.element('#' + parentTrId)[0].rowIndex;
                    technicianId = $scope.M_JobScheduler.technicianList[technicianIndex].Id;
                    if(unAssignedAppointmentRec.Id) { // Set unAssignedAppointmentRec Fields
                        unAssignedAppointmentRecToUpdate.StartTime = appStartTime;
                        timevalue = moment(appStartTime, 'h:mmA');
                        for (var j=0; j<((unAssignedAppointmentRec.EstimatedHours * 100)/25); j++) {
                            appEndTime = timevalue.add(15,'m').format("h:mmA");
                            timevalue = moment(appEndTime, 'h:mmA');
                        }
                        unAssignedAppointmentRecToUpdate.EndTime = appEndTime;
                        unAssignedAppointmentRecToUpdate.TechnicianId = technicianId;
                        appointmentRecList.push(unAssignedAppointmentRecToUpdate);
                    } else { // Get and Set AssignedAppointmentRec Fields
                       Object.keys($scope.M_JobScheduler.technicianIdToAppointmentListMap).forEach(function(techId) {
	                       	appointmentIndex = _.findIndex($scope.M_JobScheduler.technicianIdToAppointmentListMap[techId], {'Id': appointmentRecId});
	                       	if(appointmentIndex > -1) {
	                           	appointmentRec = $scope.M_JobScheduler.technicianIdToAppointmentListMap[techId][appointmentIndex];
	                           	appointmentRec.TechnicianId = technicianId;
	                       	}
                       	});
                        appointmentRec.StartTime = appStartTime;
                        timevalue = moment(appStartTime, 'h:mmA');
                        for (var j=0; j<((appointmentRec.EstimatedHours * 100)/25); j++) {
                        appEndTime = timevalue.add(15,'m').format("h:mmA");
                        timevalue = moment(appEndTime, 'h:mmA');
                        }
                        appointmentRec.EndTime = appEndTime;
                        appointmentRecList.push(appointmentRec);
                    }
                    colspanValue = angular.element(angular.element('#'+parentTrId).find('td')[i]).attr('colspan');
                    colspanValue = colspanValue ? colspanValue : 1;
                    colspanValue = colspanValue - 1;
                    totalColspanCount += colspanValue;
                }
            }
            if(unAssignedAppointmentRecToUpdate.Id) {
                createCOForAppointment(unAssignedAppointmentRecToUpdate, appointmentRecList)
            } else if(appointmentRecList.length > 0) {
                updateAppointment(appointmentRecList);
            }
        }
        function addMoreTdsToScaleAndOverlappedTable(noOfTdsToAdd, trElementId) {
        	var timevalue = $scope.M_JobScheduler.ShopSettingData[$scope.M_JobScheduler.ShopSettingData.length - 1].timeSlot;
        	var endTimeOnView = moment(timevalue, 'h:mmA');
        	addTimeSlotsToScaleGrid(endTimeOnView, noOfTdsToAdd);
        	addTdsToOverlappedTable(endTimeOnView, noOfTdsToAdd, trElementId);
        }
        function addTdsToOverlappedTable(endTimeOnView, noOfTdsToAdd) {
        	var templateTds = '';
        	var timevalue = moment(endTimeOnView, 'h:mmA');
        	for (var i = 0; i < noOfTdsToAdd; i++) {
                var newTime = timevalue.add(30,'m').format("h:mmA");
                templateTds += '<td></td>';
                timevalue = moment(newTime, 'h:mmA');
            }
        	var newTdElements = angular.element(templateTds);
        	newTdElements = $compile(newTdElements)($scope);
            angular.element('table.overlaped-table > tbody > tr').append(newTdElements);
        }
        
        function appendDivToTd(event, uiItem, draggableDivId) {
        	var defer = $q.defer();
        	var result = {};
			var item =  $(uiItem).clone();
			if(draggableDivId) {
				item.attr("id", draggableDivId);
			}
			var sortTableTrElement = $(uiItem).parent();
			var sortTableTrElementId = $(sortTableTrElement).attr("id");
			var sortTableTdPrevElement = $(uiItem).prev();
			var sortTableTdPrevElementID = sortTableTdPrevElement ? $(sortTableTdPrevElement).attr("id") : '';
			var sortTableTdNextElement = $(uiItem).next();
			var sortTableTdNextElementID = sortTableTdNextElement ? $(sortTableTdNextElement).attr("id") : '';
			if(!sortTableTdNextElement[0] || sortTableTdNextElement[0].tagName !== 'TD') {
				$(uiItem).remove();
				defer.resolve(null);
	        	return defer.promise;
			}
			var estimatedHour = $(uiItem).find(".estimated-hours").html();
  			estimatedHour = parseFloat(estimatedHour);
	      	if(isNaN(estimatedHour)) {
  				estimatedHour = 0.25;
	    	}
	      	var colspanVal = (estimatedHour * 100)/25; 
			colspanVal = colspanVal ? colspanVal : 1;
			var tdIndexToStartShifting;
			var tdCount = 0;
			var cloneAppointmentDiv;
			var cloneAppointmentDivEstimatedHour;
			var colSpanValRequiredForCloneAppointmentDiv;
			var noOfTdsToAdd;
			
			//tdIndexToStartShifting = parseInt(sortTableTdNextElementID.slice(37,sortTableTdNextElementID.length));
			tdIndexToStartShifting = $('#' + sortTableTdNextElementID)[0].cellIndex;
			
			$(uiItem).remove();
			
			
			for(var i=tdIndexToStartShifting; i<sortTableTrElement.find('td').length; i++) {
				cloneAppointmentDiv = '';
				cloneAppointmentDivEstimatedHour = 0;
				colSpanValRequiredForCloneAppointmentDiv = 0;
				if($(sortTableTrElement.find('td')[i]).find("div.appointment-card").length > 0 && item) {
					cloneAppointmentDiv = $(sortTableTrElement.find('td')[i]).find("div.appointment-card").clone();
					cloneAppointmentDivEstimatedHour = parseFloat($(sortTableTrElement.find('td')[i]).find(".estimated-hours").html());
					if(isNaN(cloneAppointmentDivEstimatedHour)) {
						cloneAppointmentDivEstimatedHour = 0.25;
	 	    		}
					colSpanValRequiredForCloneAppointmentDiv = (cloneAppointmentDivEstimatedHour * 100)/25;
					colSpanValRequiredForCloneAppointmentDiv = colSpanValRequiredForCloneAppointmentDiv ? colSpanValRequiredForCloneAppointmentDiv : 1;
					($(sortTableTrElement.find('td')[i]).find("div.appointment-card")[0]).remove();//check
				}
				
				if(item) {
					$(sortTableTrElement.find('td')[i]).attr("colspan", colspanVal);
					$(sortTableTrElement.find('td')[i]).append(item);
				}
				
				tdCount = i + colspanVal;
				if((tdCount + colSpanValRequiredForCloneAppointmentDiv) > sortTableTrElement.find('td').length) {
					noOfTdsToAdd = (tdCount + colSpanValRequiredForCloneAppointmentDiv) - sortTableTrElement.find('td').length;
					addMoreTdsToScaleAndOverlappedTable(noOfTdsToAdd, sortTableTrElementId);
				}
				item = cloneAppointmentDiv;
				estimatedHour = cloneAppointmentDivEstimatedHour;
				colspanVal = colSpanValRequiredForCloneAppointmentDiv;
			}
			result.sortTableTrElementId = sortTableTrElementId;
			result.tdIndexWhereItemIsDropped = tdIndexToStartShifting;
			defer.resolve(result);
        	return defer.promise;
        }
        function defineSortable() {
        	$(function() {
        		var draggableAppoitntmentDivId;
        		var originalTdIndexFromWhereItemIsDragged;
        		var originalParentTrId;
        		var performSortAction;
          		$('.overlaped-table tr.sortable').sortable({
          			placeholder: "sortable-ui-state-highlight",
  	      			connectWith: '.overlaped-table tbody tr.sortable',
  	      			cancel: ".sortable-ui-state-disabled",
  	      			cursorAt: { left: 0 },
  	      			scroll: true,
                    tolerance: 'pointer',
                    cursor: "grab",
                    helper: "clone",
                    start: function(event, ui) {
						if(ui.item[0].tagName === 'TD') {
        	        		originalTdIndexFromWhereItemIsDragged = $('#' + ui.item[0].id)[0].cellIndex;
        	        		originalParentTrId = $(ui.item[0]).parent().attr("id");
        	        		var tdElementId = $(ui.item[0]).attr("id");
        	     	    	var colspanTd = $("#"+ tdElementId).attr("colspan") ? $("#"+ tdElementId).attr("colspan") : 1;
        	     	    	var tdWidth = $("#"+ tdElementId).width();
        	        		var templateTds = '';
        	     	    	for(var i=0; i<colspanTd; i++) {
        	     	    		templateTds += '<td  class = "new-sortable-td appointment-container-td" id = "new-sortable-td-'+ i + '" style="width:' + (tdWidth/colspanTd) + 'px"></td>';
        	     	    	}
        		           	var newTdElements = angular.element(templateTds);
        		           	newTdElements = $compile(newTdElements)($scope);
        		           	$('table > tbody > tr#' + originalParentTrId + ' > td').eq(originalTdIndexFromWhereItemIsDragged).before(newTdElements);
        		           	$( ".overlaped-table tr#" + originalParentTrId).sortable( "refresh" );
        		           	$('td.ui-sortable-helper').css('display', 'block');
						}
                    },
  	      			stop: function(event, ui) {
  	      				var element;
	    		    	var itemWidth;
	    		    	var leftPosition; 
	    		    	var performStopAction = performSortAction;
	    		    	if(performStopAction) {
	    		    		overlapedTableUISortableStopAction(event, ui, draggableAppoitntmentDivId, originalTdIndexFromWhereItemIsDragged);
	                    } else {
	                    	$('.overlaped-table tr.sortable').sortable('cancel');
	                    	if(ui.item[0].tagName === 'TD') {
	                    		$scope.M_JobScheduler.isLoading = true;
	            	           	bindAppointmentsOnGrid($scope.M_JobScheduler.selectedDate).then(function(){
	            	           		defineSortable();
	                           		$scope.M_JobScheduler.isLoading = false;
	            	           	});
	                    	} else if(ui.item[0].tagName === 'DIV') {
	                    		/** When User drops appointment on Pull out itself it is dropped, but further calcualtion is restrcited, 
	                    		 * also with 'cancel' option it's not visible in the grid, but it's creating issues with row height when user again starts dragging
	                    		 */
	                    		$('.overlaped-table tr.sortable').find(">div").remove();
	                    	}
	                    }
  	      			},
        		    sort: function(event, ui) {
        		    	var element;
        		    	var itemWidth;
        		    	var leftPosition; 
        		    	var topPosition; 
        		    	var itemHeight;
        		    	if(ui.item[0].tagName === 'DIV') {
        		    		element = $(".ui-draggable-dragging");
            		    	if(window.innerWidth >= 767) {
            		    		itemWidth = element.width() + 22 + 12;
            		    		leftPosition = element.position().left; 
                		    	performSortAction = (leftPosition <= (-1*itemWidth)) ? true : false;
            		    	} else {
            		    		itemHeight = element.height() + 18 + 13;
            		    		topPosition = element.position().top; 
                		    	performSortAction = (topPosition <= (-1*itemHeight)) ? true : false;
            		    	}
        		    	} else if(ui.item[0].tagName === 'TD') {
        		    		var overlappedTableWidth = $(".overlaped-table").width();
        		    		var overlappedTableHeight = $(".overlaped-table").height();
        		    		element = $(".ui-sortable-helper");
        		    		itemWidth = element.width();
        		    		itemHeight = element.height();
            		    	leftPosition = element.position().left; 
            		    	topPosition = element.position().top; 
            		    	
            		    	performSortAction = (((leftPosition <= (-1*itemWidth)) || (leftPosition >= overlappedTableWidth)) || ((topPosition <= (-1*itemHeight)) || (topPosition >= (overlappedTableHeight-60)))) ? false : true;
            		    	if(!performSortAction){
	                			$(".overlaped-table tr").removeClass("overlay-td-hover");
		                	    $(".technician-list .asign-person").removeClass("overlay-td-hover");
    	                	}
        		    	}
        		    	if(performSortAction) {
        		    		overlapedTableUISortableSortAction(event, ui, originalParentTrId);
                        }
        		    },    
        	        receive: function (event, ui) {  
        	        	draggableAppoitntmentDivId = ui.item[0].id;
        	        }
  	      	    }).disableSelection();
          		
          		$( ".un-assigned-infopopup" ).sortable({
        		      revert: true,
        		      connectToSortable: ".overlaped-table tr.sortable",
        		      placeholder: "sortable-ui-state-highlight",
                      scroll: false,
                      disabled: ((!$scope.M_JobScheduler.isToggled && window.innerWidth >= 767) ? true : false)
          		});
        	});  
        }
        
       function defineDraggable() {
        	$(function(){
	        	$( ".un-assigned-infopopup div.appointment-card" ).draggable({
	        	      connectToSortable: ".overlaped-table tr.sortable",
	        	      helper: "clone",
	        	      snap: true,
	        	      scroll: false,
	        	      cursorAt: { left: 0 },
	        	     revert: function(){
	        	    	  $(".overlaped-table tr").removeClass("overlay-td-hover");
	                	  $(".technician-list .asign-person").removeClass("overlay-td-hover");
	                  },
	                  drag: function( event, ui ) {
	                	var appointmentNavWidth = $("#appointmentNav").width();
	                    var itemWidth = $(".ui-draggable-dragging").width() + 22 + 12;
	                    var leftPosition = $(".ui-draggable-dragging").position().left;
          		    	
          		    	if((window.innerWidth >= 767) 
          		    			&& ($(".ui-draggable-dragging").position().top -  $(".ui-draggable-dragging").height() <= 0 
	                			|| $(".ui-draggable-dragging").position().top > ($("#appointmentNav").height() - 60) 
	                			|| $(".ui-draggable-dragging").position().left < (-1 * $(".overall-container").width() + $(".ui-draggable-dragging").width())
	                			|| leftPosition > (-1*itemWidth))){
	                			$(".overlaped-table tr").removeClass("overlay-td-hover");
		                	    $(".technician-list .asign-person").removeClass("overlay-td-hover");
	                	}
	                  },
	        	      disabled: ((!$scope.M_JobScheduler.isToggled && window.innerWidth >= 767) ? true : false)
	        	});
	        	$( ".un-assigned-infopopup").disableSelection();
        	});
        }
       
       function overlapedTableUISortableStopAction(event, ui, draggableAppoitntmentDivId, originalTdIndexFromWhereItemIsDragged) {
    	    $(".default-td").remove();
    	    var parentTrId;
    	    var tdIndexWhereItemIsDropped;
    	    var nextTdIndex;
    	    var tdsListByIdToBeRemoved = [];
			$(".overlaped-table tr").removeClass("overlay-td-hover");
			$(".technician-list .asign-person").removeClass("overlay-td-hover");
			if(ui.item[0].tagName === 'DIV') { //If UI Item is div 
				/*appendDivToTd(event, ui, draggableAppoitntmentDivId).then(function(sortTableTrElementId) {
					if(sortTableTrElementId) {
						parentTrId = sortTableTrElementId;
						tdIndexWhereItemIsDropped = 
						overlappedTableTrSortableAction(parentTrId);
					}
			   });*/
			   appendDivToTd(event, ui.item[0], draggableAppoitntmentDivId).then(function(result) {
					if(result) {
						parentTrId = result.sortTableTrElementId;
						tdIndexWhereItemIsDropped = result.tdIndexWhereItemIsDropped;
						if(parseInt(angular.element(angular.element('#'+parentTrId).find('td')[tdIndexWhereItemIsDropped]).attr('colspan')) > 1) {
							nextTdIndex = tdIndexWhereItemIsDropped + 1;
	                    	for(var k=1; k<parseInt(angular.element(angular.element('#'+parentTrId).find('td')[tdIndexWhereItemIsDropped]).attr('colspan')); k++) {
	                    		if(angular.element('#'+parentTrId).find('td')[nextTdIndex] && !angular.element(angular.element('#'+parentTrId).find('td')[nextTdIndex]).find('div.appointment-card').length) {
	                    			//angular.element(angular.element('#'+parentTrId).find('td')[nextTdIndex]).remove();
	                    			tdsListByIdToBeRemoved.push(angular.element('#'+parentTrId).find('td')[nextTdIndex].id);
	                    			nextTdIndex = nextTdIndex + 1;
	                    		}
	                    	}
	                    	
	                    	angular.forEach(tdsListByIdToBeRemoved, function(removeableTdId) {
	                    		angular.element('#'+removeableTdId).remove();
	                        });
	                    }
						overlappedTableTrSortableAction(parentTrId, tdIndexWhereItemIsDropped);
					}
			   });
			} else if(ui.item[0].tagName === 'TD') { // else if UI Iem is td
				var sortableTrElementID = $(ui.item[0]).parent().attr("id");
				var draggableTdId = ui.item[0].id;
				var actualParentRowTechId = draggableTdId.slice(19,37);				
				$('table > tbody > tr#' + sortableTrElementID + ' > td#' + draggableTdId + '>div').css('display', 'flex');
				if(!sortableTrElementID.includes(actualParentRowTechId)) {
					var uiItem = $('#'+draggableTdId).find("div.appointment-card").clone();
					var draggableTdIndexInCurrentSortableRow = $('#' + draggableTdId)[0].cellIndex;
					$('table.overlaped-table > tbody > tr#' + sortableTrElementID + ' > td').eq(draggableTdIndexInCurrentSortableRow).before(uiItem);
					$('#'+draggableTdId).remove();
					appendDivToTd(event, uiItem).then(function(result) {
						if(result) {
							parentTrId = result.sortTableTrElementId;
							tdIndexWhereItemIsDropped = result.tdIndexWhereItemIsDropped;
							if(parseInt(angular.element(angular.element('#'+parentTrId).find('td')[tdIndexWhereItemIsDropped]).attr('colspan')) > 1) {
								nextTdIndex = tdIndexWhereItemIsDropped + 1;
		                    	for(var k=1; k<parseInt(angular.element(angular.element('#'+parentTrId).find('td')[tdIndexWhereItemIsDropped]).attr('colspan')); k++) {
		                    		if(angular.element('#'+parentTrId).find('td')[nextTdIndex] && !angular.element(angular.element('#'+parentTrId).find('td')[nextTdIndex]).find('div.appointment-card').length) {
		                    			//angular.element(angular.element('#'+parentTrId).find('td')[nextTdIndex]).remove();
		                    			tdsListByIdToBeRemoved.push(angular.element('#'+parentTrId).find('td')[nextTdIndex].id);
		                    			nextTdIndex = nextTdIndex + 1;
		                    		}
		                    	}
		                    	
		                    	angular.forEach(tdsListByIdToBeRemoved, function(removeableTdId) {
		                    		angular.element('#'+removeableTdId).remove();
		                        });
		                    }
							overlappedTableTrSortableAction(parentTrId, tdIndexWhereItemIsDropped);
						}
				   });
				} else {
					var colLength;
					var removedTdCount = 0;
					//$(ui.item[0]).attr("colspan", 1); // If it is not set to 1; then Time Calculations for Appointment after this element disturbs
					parentTrId = $('#'+ui.item[0].id).parent()[0].id;
					tdIndexWhereItemIsDropped = $('#' + ui.item[0].id)[0].cellIndex;
					if(tdIndexWhereItemIsDropped != originalTdIndexFromWhereItemIsDragged) {
						nextTdIndex = tdIndexWhereItemIsDropped + 1;
						colLength = parseInt(angular.element(angular.element('#'+parentTrId).find('td')[tdIndexWhereItemIsDropped]).attr('colspan')) ? parseInt(angular.element(angular.element('#'+parentTrId).find('td')[tdIndexWhereItemIsDropped]).attr('colspan')) : 1;
                    	for(var k=1; k<=colLength; k++) {
                    		if(angular.element('#'+parentTrId).find('td')[nextTdIndex] && !angular.element(angular.element('#'+parentTrId).find('td')[nextTdIndex]).find('div.appointment-card').length) {
                    			//angular.element(angular.element('#'+parentTrId).find('td')[nextTdIndex]).remove();
                    			tdsListByIdToBeRemoved.push(angular.element('#'+parentTrId).find('td')[nextTdIndex].id);
                    			removedTdCount += 1;
                    			nextTdIndex = nextTdIndex + 1;
                    		}
                    	}
                    	
                    	var templateTds = '';
                    	var newTdElements;
                    	if(tdIndexWhereItemIsDropped < originalTdIndexFromWhereItemIsDragged) {
                        $(".new-sortable-td").remove();
                    		templateTds = '';
                    		for(var k=0; k<removedTdCount; k++) {
                    			templateTds += '<td></td>';
                    		}
                        	newTdElements = angular.element(templateTds);
            	           	newTdElements = $compile(newTdElements)($scope);
            	           	$('table.overlaped-table > tbody > tr#' + parentTrId + ' > td').eq(originalTdIndexFromWhereItemIsDragged + 1).before(newTdElements);
            	           	angular.forEach(tdsListByIdToBeRemoved, function(removeableTdId) {
                        		angular.element('#'+removeableTdId).remove();
                            });
                            overlappedTableTrSortableAction(parentTrId, tdIndexWhereItemIsDropped);
                    	}else if(tdIndexWhereItemIsDropped > originalTdIndexFromWhereItemIsDragged) {
                    		/*templateTds = '';
                    		angular.forEach(tdsListByIdToBeRemoved, function(removeableTdId) {
                        		angular.element('#'+removeableTdId).remove();
                            });
                    		for(var k=0; k<colLength; k++) {
                    			templateTds += '<td></td>';
                    		}
                    		newTdElements = angular.element(templateTds);
            	           	newTdElements = $compile(newTdElements)($scope);
            	           	$('table.overlaped-table > tbody > tr#' + parentTrId + ' > td').eq(originalTdIndexFromWhereItemIsDragged).before(newTdElements);*/
                    		
                    		
                    	    tdsListByIdToBeRemoved = [];
                    		var uiItem = $('#'+draggableTdId).find("div.appointment-card").clone();
        					var draggableTdIndexInCurrentSortableRow = $('#' + draggableTdId)[0].cellIndex;
        					$('table.overlaped-table > tbody > tr#' + sortableTrElementID + ' > td').eq(draggableTdIndexInCurrentSortableRow).before(uiItem);
        					$('#'+draggableTdId).remove();
        					appendDivToTd(event, uiItem).then(function(result) {
        						if(result) {
        							parentTrId = result.sortTableTrElementId;
        							tdIndexWhereItemIsDropped = result.tdIndexWhereItemIsDropped;
        							if(parseInt(angular.element(angular.element('#'+parentTrId).find('td')[tdIndexWhereItemIsDropped]).attr('colspan')) > 1) {
        								nextTdIndex = tdIndexWhereItemIsDropped + 1;
        		                    	for(var k=1; k<parseInt(angular.element(angular.element('#'+parentTrId).find('td')[tdIndexWhereItemIsDropped]).attr('colspan')); k++) {
        		                    		if(angular.element('#'+parentTrId).find('td')[nextTdIndex] && !angular.element(angular.element('#'+parentTrId).find('td')[nextTdIndex]).find('div.appointment-card').length) {
        		                    			tdsListByIdToBeRemoved.push(angular.element('#'+parentTrId).find('td')[nextTdIndex].id);
        		                    			nextTdIndex = nextTdIndex + 1;
        		                    		}
        		                    	}
        		                    	
        		                    	angular.forEach(tdsListByIdToBeRemoved, function(removeableTdId) {
        		                    		angular.element('#'+removeableTdId).remove();
        		                        });
        		                    }
        							overlappedTableTrSortableAction(parentTrId, tdIndexWhereItemIsDropped);
        						}
        				   }, function(error){
        					   console.log("error");
        				   });
                    		
					   }
					}
					
					
				}
			}
       }
       
       function overlapedTableUISortableSortAction(event, ui, originalParentTrId) {
    	    $(".default-td").remove();
 	    	var getAttr = $(".sortable-ui-state-highlight").parent().attr("for");
 	    	var elemntId = $(".sortable-ui-state-highlight").parent().attr("id");
 	    	$(".overlaped-table tr").removeClass("overlay-td-hover");
 	    	$(".technician-list .asign-person").removeClass("overlay-td-hover");
 	    	$(".overlaped-table tr").removeClass("lessbooked-state-hover");
 	    	$(".technician-list .asign-person").removeClass("lessbooked-state-hover");
 	    	$(".sortable-ui-state-highlight").parent().addClass("overlay-td-hover");
            $("[rel="+getAttr+"]").addClass("overlay-td-hover");
 	    	$("#" + elemntId).addClass("overlay-td-hover");
 	    	var techId = elemntId.slice(19,37);
 	    	var techIndex = _.findIndex($scope.M_JobScheduler.technicianList, {'Id': techId});
 	    	if(techIndex > -1){
 	    		var UIItemEstimatedHours = parseFloat($(ui.item[0]).find(".estimated-hours").html());
 	    		if(isNaN(UIItemEstimatedHours)) {
 	    			UIItemEstimatedHours = 0.25;
 	    		}
 	    		if(originalParentTrId!==elemntId && $scope.M_JobScheduler.technicianList[techIndex].AvailableHours >= (UIItemEstimatedHours + $scope.M_JobScheduler.technicianList[techIndex].BookedHours) ) {
 	    			$("[rel="+getAttr+"]").addClass("lessbooked-state-hover");
         	    	$("#" + elemntId).addClass("lessbooked-state-hover");
 	    		} else if(originalParentTrId === elemntId && $scope.M_JobScheduler.technicianList[techIndex].AvailableHours >= $scope.M_JobScheduler.technicianList[techIndex].BookedHours) {
 	    			$("[rel="+getAttr+"]").addClass("lessbooked-state-hover");
         	    	$("#" + elemntId).addClass("lessbooked-state-hover");
 	    		}
 	    	}
            if(ui.item[0].tagName === 'TD') {
 	    		var tdElementId = $(ui.item[0]).attr("id");
     	    	var trElementId = tdElementId.slice(0,15) + 'Tr'+ tdElementId.slice(17,37)
     	    	var colspanTd = $("#"+ tdElementId).attr("colspan") ? $("#"+ tdElementId).attr("colspan") : 1;
     	    	var tdWidth = $("#"+ tdElementId).width();
     	    	var tdIndex = $('#' + tdElementId)[0].cellIndex; // Cell Index starts From 0
     	    	/*var templateTds = '';
     	    	for(var i=0; i<colspanTd; i++) {
     	    		templateTds += '<td  class = "default-td appointment-container-td" style="width:' + (tdWidth/colspanTd) + 'px"></td>';
     	    	}
	           	var newTdElements = angular.element(templateTds);
	           	newTdElements = $compile(newTdElements)($scope);
	           	$('table > tbody > tr#' + trElementId + ' > td').eq(tdIndex).before(newTdElements);*/
	        
     	    	//$('table > tbody > tr#' + trElementId + ' > td').eq(tdIndex).css('display', 'table-cell');
     	    	//$('table > tbody > tr#' + trElementId + ' > td').eq(tdIndex).find('>div').css('display', 'none');
     	    	//$('table > tbody > tr#' + trElementId + ' > td#' + tdElementId + '>div').css('display', 'none');
     	    	//$('table > tbody > tr#' + trElementId + ' > td').eq(tdIndex).find('div').css('display', 'none')
 	    	}
       }
       
      function enableOrDisableDraggingOnPullOut() {
    	   if(!$scope.M_JobScheduler.isToggled && window.innerWidth >= 767) {
     			$( ".un-assigned-infopopup div.appointment-card" ).draggable({disabled: true});
     			$( ".un-assigned-infopopup" ).sortable({disabled: true});
     		} else {
     			$( ".un-assigned-infopopup div.appointment-card" ).draggable("enable");
     			$( ".un-assigned-infopopup" ).sortable("enable");
     		}
       } 
       
       function createCOForAppointment(appointmentObj, allAppointmentObjListToUpdate) {
    	    $scope.M_JobScheduler.isLoading = true;
            JobSchedulerService.createCOForAppointment(angular.toJson(appointmentObj)).then(function(coHeaderId) {
               updateAppointment(allAppointmentObjListToUpdate,true);
           }, function(error) {
               Notification.error($translate.instant('GENERIC_ERROR'));
           });
        }
           
        function updateAppointment(allAppointmentObjListToUpdate,isFromcreateCOForAppointment) {
        	$scope.M_JobScheduler.isLoading = true;
            JobSchedulerService.updateAppointment(JSON.stringify(allAppointmentObjListToUpdate)).then(function() {
		       	if(isFromcreateCOForAppointment) {
		       		loadJobSchedulerDataForSpecificDay($scope.M_JobScheduler.selectedDate);
	           	} else {
		           	getGridData($scope.M_JobScheduler.selectedDate).then(function() {
		           		$scope.M_JobScheduler.isLoading = false;
	               });
	           	}
	       	}, function(error) {
               Notification.error($translate.instant('GENERIC_ERROR'));
           });
        }
        
        function getUnassignedAppointmentForSpecificDay(selectedDate) {
            var defer = $q.defer();
            $scope.M_JobScheduler.unAssignedAppointments = {};
            JobSchedulerService.getUnassignedAppointmentForSpecificDay(selectedDate.format($scope.M_JobScheduler.dateFormat)).then(function(unAssignedAppointmentData) {
                $scope.M_JobScheduler.noOfUnassignedAppointment = unAssignedAppointmentData.length;
                $scope.M_JobScheduler.unAssignedAppointments = {
                           'Morning': [],
                           'Afternoon': []
                    }
                for(var i =0 ; i < unAssignedAppointmentData.length ; i++) {
                    if(unAssignedAppointmentData[i].AppointmentDaySegment === 'Morning') {
                        $scope.M_JobScheduler.unAssignedAppointments['Morning'].push(unAssignedAppointmentData[i]);
                    } else {
                         $scope.M_JobScheduler.unAssignedAppointments['Afternoon'].push(unAssignedAppointmentData[i]);
                    }
                }
                
                setTimeout(function() {
               		defineDraggable();
               	},100);
                console.log("getUnassignedAppointmentForSpecificDay")
                defer.resolve();
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
            return defer.promise;
        }
        
        function getGridData(selectedDate) {
        	var defer = $q.defer();
        	getShopSettingData(selectedDate).then(function() {
                getTechnicianListForSpecificDay(selectedDate).then(function() {
              	  getAssignedAppointmentForSpecificDay(selectedDate).then(function() {
              		console.log("getGridData");
              		defer.resolve();
                  });
                });
            });
        	return defer.promise;
        }
      function loadJobSchedulerDataForSpecificDay(selectedDate) {
    	  $q.all([getUnassignedAppointmentForSpecificDay(selectedDate), 
    	          getGridData(selectedDate)]).then(function() {
        	  console.log("ALL PROMISES RESOLVED");
        	  $scope.M_JobScheduler.isLoading = false;
          });
      }
      
      $scope.F_JobScheduler.loadData = function(selectedDate) {
          $scope.M_JobScheduler.selectedDate = selectedDate;
          loadJobSchedulerDataForSpecificDay(selectedDate);
      }
      
      $rootScope.$on('JobSchedulerLoadData', function(event, args) {
          $scope.$broadcast('loadCalendarDayView', {isPreventReloadData: true, selectedDate: $scope.M_JobScheduler.selectedDate});
    	  if(args && args.isReloadAllData) {
    		  $scope.M_JobScheduler.isLoading = true;
    		  loadJobSchedulerDataForSpecificDay($scope.M_JobScheduler.selectedDate);
          } else if(args && args.isReloadPullOutData) {
        	  $scope.M_JobScheduler.isLoading = true;
              getUnassignedAppointmentForSpecificDay($scope.M_JobScheduler.selectedDate).then(function(sucessResult) {
            	  $scope.M_JobScheduler.isLoading = false;
              });
          }
      });
    }])
});