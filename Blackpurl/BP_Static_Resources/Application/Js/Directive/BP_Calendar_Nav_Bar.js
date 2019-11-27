define(['Routing_AppJs_PK', 'JqueryUI', 'moment', 'momentTimezone'], function (Routing_AppJs_PK,  JqueryUI, moment, momentTimezone) {
	Routing_AppJs_PK.directive('bpCalendarNavBar',['$sce','$rootScope', '$stateParams', function($sce,$rootScope, $stateParams) {
		return {
			restrict: 'E',
	        scope: {
	        	idValue:'@',
	        	classValue:'@',
	        	objectPayload: '=',
	        	onLoadAction: '&',
	        	currentPeriodicView: '@',
	        	isLoading: '=',
	        	focusOn: '&',
	        	currentDate: '='
	        	},
	        template: '<div class="bp-periodwise-calendar bp-pointer-cursor">'
	                  		+ '<div class="col-xs-1 bp-cal-arrow bp-cal-right-border" ng-click="changeVisibleTimePeriod(\'prev\')">'
	                  			+ '<i class = "bp-blue" ng-include = "getTrustedUrl(\'arrow-left-1.svg\')"></i>'
	                  		+ '</div>'
	                  		+ '<div class="period-duration bp-blue-font col-xs-10 ">'
								+ '<input type="text" id = "cal-input-{{idValue}}" name="cal-week" ui-date="dateOptions"'
		                              + 'ui-date-format="{{dateFormat}}"'
		                              + 'class="cal-input"'
		                              + 'ng-change="changeDateToWeek(currentDate, true)"'
		                              + 'ng-model="currentDate" readonly="readonly"/>'
		                        + '<div class="cal-overlap-container" ng-click="focusOn(\'cal-week\')">'
		                        	+ '<i class="bp-blue" ng-include="getTrustedUrl(\'calendar-filled.svg\')"></i><span>{{currentPeriod}}</span>'
	        					+ '</div>'
	                  		+ '</div>'
	                  		+ '<div class="col-xs-1 bp-cal-arrow bp-cal-left-border" ng-click="changeVisibleTimePeriod(\'next\')">'
	                  			+'<i class = "bp-blue" ng-include = "getTrustedUrl(\'arrow-right-1.svg\')"></i>'
	                  		+'</div>'
	                  	+ '</div>',
	       link: function(scope) {
	    	   scope.dateOptions = {
	                    dateFormat: scope.dateFormat,
	                    showOtherMonths: true,
	                    selectOtherMonths: true,
	                    dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
	                    firstDay: 1,
	                    beforeShow: function (inputElement, inst) {
		    		        setTimeout(function () {
		    					calculateTopPositionForJqueryCalUI(scope.idValue);
		    		        }, 10);
		    		    }
	                };
                    
	    	   scope.focusOn = function(id) {
	    			setTimeout(function(){
	    				angular.element('[name="cal-week"]').focus();
	    				if(scope.currentPeriodicView === 'weekly') {
	    					if(!angular.element('#ui-datepicker-div table').hasClass('ui-weekSelector-table')) {
	    						angular.element('#ui-datepicker-div table').addClass('ui-weekSelector-table');
	    					}
	    					highlightWeek();
	    				}
	    			},100);
	    	   }
	    	   
	    	   function calculateTopPositionForJqueryCalUI(inputElement) {
	    		   var calInputTopPosition = angular.element("#cal-input-"+ inputElement).offset().top;
	    		   
	    		   if(inputElement === 'AddEditAppointment') {
	    			   calInputTopPosition -= $(window).scrollTop();
	    		   }
	    		   angular.element(".ui-datepicker.ui-widget.ui-widget-content").css('top', (calInputTopPosition + 56));
	    	   }
	    	   
	    	   $(document).off('click', '.ui-datepicker-next').on('click', '.ui-datepicker-next', function () {
	    		   actionOnNextOrPrevBtnClickOnJqueryCalUI('next');
	    	   });
	    	   
	    	   $(document).off('click', '.ui-datepicker-prev').on('click', '.ui-datepicker-prev', function () {
	    		   actionOnNextOrPrevBtnClickOnJqueryCalUI('prev');
	    	   });
    		 
	    	   function actionOnNextOrPrevBtnClickOnJqueryCalUI(eventName) {
	    		   if(scope.currentPeriodicView === 'weekly') {
	    			   if(!angular.element('#ui-datepicker-div table').hasClass('ui-weekSelector-table')) {
	    				   angular.element('#ui-datepicker-div table').addClass('ui-weekSelector-table');
	    			   }
	    			   highlightWeek();
	   			   }
	    	   }

	    	   function highlightWeek() {
	    		   var startDateOfSelectedWeek = new Date(scope.currentPeriodStartDate);
	    		   var startDayOfSelectedWeek = startDateOfSelectedWeek.getDate(); //this is the value from where we want to select the week days in calendar 
	    		   var MonthOfStartDateOfSelectedWeek = startDateOfSelectedWeek.getMonth(); //this is the value from where we want to select the week days in calendar 
	    		   $('.ui-datepicker-calendar > tbody > tr').each(function() {
	    			   var isWeekRowOfCurrentPeriod = false;
	    			   $(this).children('td').each(function() {
	    				   var dy = $(this).first('a');
	    				   var dyText = dy.text();
	    				   var dyMonth = dy.attr('data-month');
	    				   if((dy.text() == startDayOfSelectedWeek) && (dy.attr('data-month') == MonthOfStartDateOfSelectedWeek)) {
	    					   isWeekRowOfCurrentPeriod = true;
	    				   }  
	    				   
	    				   if(isWeekRowOfCurrentPeriod) {
	    					   $(this).parent().addClass('ui-week-row-state-active');
	    				   }
	    			   }); 
	    			   
	    			   if(isWeekRowOfCurrentPeriod)	{ // To break the loop once the selected week row is highlighted
	    				   isWeekRowOfCurrentPeriod = false;
		    			   return false;
	    			   }
	    		   });
	    	   }
               
	    	   scope.dateFormat = $Global.DateFormat;
	    	   scope.dateFormatMoment = $Global.SchedulingDateFormat;
	    	   scope.currentDay = moment().format('LT'); // unable to get local time from moment
	    	   scope.currentPeriodStartDate;
	    	   scope.currentPeriodEndDate;
	    	   var startDate;
	    	   scope.getCurrentPeriodString = function(isPreventReloadData) {
	    		   if(scope.currentPeriodicView === 'weekly') {
                   		scope.isLoading = true;
	    			   scope.onLoadAction({startDate: angular.copy(scope.currentPeriodStartDate), endDate: angular.copy(scope.currentPeriodEndDate)});
	    			   scope.currentPeriod = scope.currentPeriodStartDate.format("MMMM DD") + ' - ' + scope.currentPeriodEndDate.format("LL");
	    		   } else if(scope.currentPeriodicView === 'day') {
                       if(!isPreventReloadData) {
                           scope.isLoading = true;
                           scope.onLoadAction({selectedDate: angular.copy(scope.currentPeriodStartDate)});
                       } 
                       scope.currentPeriod = scope.currentPeriodStartDate.format('dddd, DD MMMM YYYY');
                   }
	    	   }
	    	   scope.changeDateToWeek = function(date, isFromMiniCalender) {
				   if(isFromMiniCalender) {
						date = moment(date).format(scope.dateFormatMoment);
				   }
	    		   if(scope.currentPeriodicView === 'weekly') {
	    			   scope.currentPeriodStartDate = moment(date, scope.dateFormatMoment).startOf('isoWeek').startOf('day');
	    		   } else if(scope.currentPeriodicView === 'day') {
	    			   scope.currentPeriodStartDate = moment(date, scope.dateFormatMoment).startOf('day');
	    		   }
    	    	   startDate = angular.copy(scope.currentPeriodStartDate);
    	    	   scope.currentPeriodEndDate = startDate.add(no_of_days_in_period-1,'days');
    	    	   scope.getCurrentPeriodString();
	    	   }
	    	   scope.changeVisibleTimePeriod = function(passedAction) {
	    		   if (passedAction === 'prev') {
	    			   scope.currentPeriodStartDate.subtract(no_of_days_in_period,'days');
	    		   } else if(passedAction === 'next') {
	    			   scope.currentPeriodStartDate.add(no_of_days_in_period,'days');
	    		   }
    			   startDate = angular.copy(scope.currentPeriodStartDate);
    	    	   scope.currentPeriodEndDate = startDate.add(no_of_days_in_period - 1 ,'days');
    	    	   scope.currentDate = scope.currentPeriodStartDate.format(scope.dateFormatMoment);
	    		   scope.getCurrentPeriodString();
	    	   }
	    	   scope.getTrustedUrl = function (resourceName) {
           			return $sce.trustAsResourceUrl($Global.ApplicationImagePath +'/Icons/'+ resourceName);
               }
	    	   $rootScope.$on('reloadTechScheduleGridData',function(event, args) {
	    		   if(args && args.currentDate) {
	    			   scope.changeDateToWeek(args.currentDate);
	    		   } else {
	    			   scope.getCurrentPeriodString();
	    		   } 	    		   
 	    	    });
                
                scope.$on('loadCalendarDayView',function(event, args) {
	    		   scope.currentPeriodicView = 'day';
	    		   if(angular.element('#ui-datepicker-div table').hasClass('ui-weekSelector-table')) {
	    			   angular.element('#ui-datepicker-div table').removeClass('ui-weekSelector-table');
	    		   }
	    		   scope.setPeriodicView(args.selectedDate, args.isPreventReloadData);
	    		   $(document).off('click', '.ui-datepicker-next');
		    	   $(document).off('click', '.ui-datepicker-prev');
 	    	    });
                
	    	   scope.setPeriodicView = function(currentdate, isPreventReloadData) {
	    		   if(scope.currentPeriodicView === 'weekly') {
	    			   no_of_days_in_period = 7;
	    			   scope.currentPeriodStartDate = moment().startOf('isoWeek').startOf('day');
	    		   } else if(scope.currentPeriodicView === 'day') {
	    			   no_of_days_in_period = 1;
	    			   if(currentdate) {
	    				   scope.currentPeriodStartDate = moment(currentdate,scope.dateFormatMoment).startOf('day');
	    			   } else {
	    				   scope.currentPeriodStartDate = moment().startOf('day');
	    			   }
	    		   }
                   startDate = angular.copy(scope.currentPeriodStartDate);
	    	    scope.currentPeriodEndDate = startDate.add(no_of_days_in_period-1,'days');
                       
	    		   if($rootScope.currentStateName == 'AddEditAppointment' 
	    			   && scope.$parent
                       && scope.$parent.M_AddEditApp
	    			   && scope.$parent.M_AddEditApp.isLoadedByPlus) {
	    			   	var currentDate = $stateParams.AddEditAppointmentParams.currentDate;
	    			   	scope.changeDateToWeek(currentDate);
	    		   } else {
	    			   scope.getCurrentPeriodString(isPreventReloadData);
	    		   }
	    	   }
	    	   scope.setPeriodicView();
	       }
		};
    }]);
}); 