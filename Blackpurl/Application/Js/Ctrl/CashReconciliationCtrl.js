define(['Routing_AppJs_PK', 'moment', 'NumberOnlyInput_New', 'CashReconciliationServices', 'underscore_min'], function(Routing_AppJs_PK, moment, NumberOnlyInput_New, CashReconciliationServices, underscore_min) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('CashReconciliationCtrl', ['$scope', '$rootScope', '$stateParams', '$state', '$translate', 'CashReconciliationService',
        function($scope, $rootScope, $stateParams, $state, $translate, CashReconciliationService) {
            var Notification = injector1.get("Notification");
            $scope.CashReconciliationModel = {};
            $scope.CashReconciliationModel.UserFirstName = $Global.UserFirstName;
            $scope.CashReconciliationModel.UserLastName = $Global.UserLastName;
            $scope.CashReconciliationModel.tabIndexValue = 500;
            $scope.CashReconciliationModel.isContentLoading = true;
            $scope.currentUserGroupName = $Global.userGroupName;
            $scope.currentUserGroupColor = $Global.userGroupColor;
            $scope.CashReconciliationModel.viewName = 'Drawer';
            $scope.CashReconciliationModel.selectedCashDrawerId = null;
            $scope.CashReconciliationModel.isSingleCashDrawer = false;
            $scope.CashReconciliationModel.isLoading = false;
            $scope.CashReconciliationModel.isFirstSaveForTheDate = false;
            
            const NO_Of_DAYS_IN_WEEK = 7;
            const MAX_NO_OF_WEEKS_IN_MONTH = 6;
            $scope.CashReconciliationModel.dateFormat = $Global.DateFormat;
            $scope.CashReconciliationModel.ActualAmount = 0;
            $scope.CashReconciliationModel.MoveToState = function(stateName, attr) {
                if (attr != undefined && attr != null && attr != '') {
                    loadState($state, stateName, attr);
                } else {
                    loadState($state, stateName);
                }
            }
            $scope.CashReconciliationModel.loadCalendar = function() {
                $scope.CashReconciliationModel.selectedDay = $scope.CashReconciliationModel.selectedDay || moment();
                $scope.CashReconciliationModel.loadCashReconciliationData(true);
                $scope.CashReconciliationModel.currentDay = $scope.CashReconciliationModel.selectedDay.clone().format('dddd DD MMMM YYYY');
                $scope.CashReconciliationModel.weekFirstDay = _findFirstDayOfWeek($scope.CashReconciliationModel.selectedDay.clone() || moment());
                $scope.CashReconciliationModel.currentMonth = $scope.CashReconciliationModel.selectedDay.clone(); // current month 
                var calenderStartDate = $scope.CashReconciliationModel.selectedDay.clone(); // Startdate 
                calenderStartDate.date(1);
                _findFirstDayOfWeek(calenderStartDate.day(0)); // start date  calenderStartDate
                $scope.CashReconciliationModel.startDayFromChevron = $scope.CashReconciliationModel.selectedDay.clone();
                _buildMonth(calenderStartDate, $scope.CashReconciliationModel.currentMonth);
            }
            $scope.CashReconciliationModel.selectDay = function(day) {
                var previousSelectedMonth = angular.copy($scope.CashReconciliationModel.currentMonth);
                $scope.CashReconciliationModel.selectedDay = day.date;
                $scope.CashReconciliationModel.currentMonth = $scope.CashReconciliationModel.selectedDay.clone();
                if (!(moment(previousSelectedMonth).month() == moment($scope.CashReconciliationModel.currentMonth).month() && moment(previousSelectedMonth).year() == moment($scope.CashReconciliationModel.currentMonth).year())) {
                    var startForMonth = _findFirstDayOfWeek($scope.CashReconciliationModel.selectedDay.clone().date(1).day(0));
                    _buildMonth(startForMonth, $scope.CashReconciliationModel.currentMonth);
                }
                $scope.CashReconciliationModel.startDayFromChevron = $scope.CashReconciliationModel.selectedDay.clone();
                _highlightDays($scope.CashReconciliationModel.selectedDay.clone());
                $scope.CashReconciliationModel.loadCashReconciliationData();
            };
            $scope.CashReconciliationModel.getNextMonth = function() {
                var nextMonth = $scope.CashReconciliationModel.currentMonth.clone();
                _findFirstDayOfWeek(nextMonth.month(nextMonth.month() + 1).date(1));
                $scope.CashReconciliationModel.currentMonth.month($scope.CashReconciliationModel.currentMonth.month() + 1);
                _buildMonth(nextMonth, $scope.CashReconciliationModel.currentMonth);
                _highlightDays($scope.CashReconciliationModel.selectedDay.clone());
            };
            $scope.CashReconciliationModel.getPreviousMonth = function() {
                var previousMonth = $scope.CashReconciliationModel.currentMonth.clone();
                _findFirstDayOfWeek(previousMonth.month(previousMonth.month() - 1).date(1));
                $scope.CashReconciliationModel.currentMonth.month($scope.CashReconciliationModel.currentMonth.month() - 1);
                _buildMonth(previousMonth, $scope.CashReconciliationModel.currentMonth);
                _highlightDays($scope.CashReconciliationModel.selectedDay.clone());
            };
            $scope.CashReconciliationModel.getDayFromChevrons = function(operator) {
                var previousSelectedMonth = angular.copy($scope.CashReconciliationModel.currentMonth);
                var startDate = $scope.CashReconciliationModel.selectedDay.clone();
                var startDayForViewFromChevron;
                if (operator == 'Next') {
                    $scope.CashReconciliationModel.startDayFromChevron = $scope.CashReconciliationModel.startDayFromChevron.add(1, 'd');
                } else if (operator == 'Previous') {
                    $scope.CashReconciliationModel.startDayFromChevron = $scope.CashReconciliationModel.startDayFromChevron.subtract(1, 'd');
                }
                startDayForViewFromChevron = $scope.CashReconciliationModel.startDayFromChevron;
                $scope.CashReconciliationModel.selectedDay = startDayForViewFromChevron.clone();
                $scope.CashReconciliationModel.currentMonth = $scope.CashReconciliationModel.selectedDay.clone();
                $scope.CashReconciliationModel.loadCashReconciliationData();
                if (!(moment(previousSelectedMonth).month() == moment($scope.CashReconciliationModel.currentMonth).month() && moment(previousSelectedMonth).year() == moment($scope.CashReconciliationModel.currentMonth).year())) {
                    var startForMonth = _findFirstDayOfWeek($scope.CashReconciliationModel.selectedDay.clone().date(1).day(0));
                    _buildMonth(startForMonth, $scope.CashReconciliationModel.currentMonth);
                }
                _highlightDays(startDayForViewFromChevron.clone());
            }
            $scope.CashReconciliationModel.selectCurrentDay = function() {
                var temp = {
                    date: moment(),
                }
                $scope.CashReconciliationModel.selectDay(temp);
            }

            function _findFirstDayOfWeek(date) {
                return date.day(0).hour(0).minute(0).second(0).millisecond(0);
            }

            function _buildMonth(calenderStartDate, month) {
                $scope.CashReconciliationModel.weeksOfMonth = [];
                var date = calenderStartDate.clone();
                for (var i = 0; i < MAX_NO_OF_WEEKS_IN_MONTH; i++) {
                    $scope.CashReconciliationModel.weeksOfMonth.push({
                        days: _buildWeek(date.clone(), month)
                    });
                    date.add(1, "w");
                }
                $scope.CashReconciliationModel.getMinicalenderData();
            }

            function _buildWeek(date, month) {
                var daysOfWeek = [];
                for (var i = 0; i < NO_Of_DAYS_IN_WEEK; i++) {
                    daysOfWeek.push({
                        name: date.format("dd").substring(0, 1),
                        number: date.date(),
                        isCurrentMonth: date.month() === month.month(), // find name 
                        isToday: date.isSame(new Date(), "day"),
                        highlightDay: false,
                        date: date,
                        dayDate: date.clone().format($Global.SchedulingDateFormat),
                        monthName: date.clone().format('M'),
                        isReconciled: false,
                        isDisabled: (moment(date).startOf('day')).diff((moment().startOf('day')), 'days') > 0
                    });
                    date = date.clone();
                    date.add(1, "d");
                }
                return daysOfWeek;
            }

            function _highlightDays(date) {
                var highlightDay = false;
                var weekNumber = 0;
                var dayNumber = 0;
                for (var i = 0; i < $scope.CashReconciliationModel.weeksOfMonth.length; i++) {
                    for (var j = 0; j < $scope.CashReconciliationModel.weeksOfMonth[i].days.length; j++) {
                        $scope.CashReconciliationModel.weeksOfMonth[i].days[j].highlightDay = false;
                    }
                }
                for (var i = 0; i < $scope.CashReconciliationModel.weeksOfMonth.length; i++) {
                    for (var j = 0; j < $scope.CashReconciliationModel.weeksOfMonth[i].days.length; j++) {
                        if ($scope.CashReconciliationModel.weeksOfMonth[i].days[j].date.clone().format('DD-MM-YYYY') === date.format('DD-MM-YYYY')) {
                            $scope.CashReconciliationModel.weeksOfMonth[i].days[j].highlightDay = true;
                            break;
                        }
                    }
                }
            }
            $scope.CashReconciliationModel.loadCashReconciliationData = function(isPreventLoadMinicalendarData) {
                var reconciliationDate = $scope.CashReconciliationModel.selectedDay.clone().format($Global.SchedulingDateFormat);
                $scope.CashReconciliationModel.showAnimation = false;
                CashReconciliationService.getReconciliationList(reconciliationDate, $scope.CashReconciliationModel.viewName).then(function(successfulResult) {
                    $scope.CashReconciliationModel.currentDay = $scope.CashReconciliationModel.selectedDay.clone().format('dddd DD MMMM YYYY');
                    $scope.CashReconciliationModel.showAnimation = true;
                    $scope.CashReconciliationModel.isContentLoading = false;
                    if($scope.CashReconciliationModel.viewName === 'Drawer') {
                    	$scope.CashReconciliationModel.selectedCashDrawerId = null;
                    	bindDrawerViewData(successfulResult);
                    	
                    	if(successfulResult.CashDrawerReconcilationObjList.length == 1) {
                    		$scope.CashReconciliationModel.isSingleCashDrawer = true;
                    		$scope.CashReconciliationModel.selectedCashDrawerId = successfulResult.CashDrawerReconcilationObjList[0].DrawerId;
                    	} else {
                    		$scope.CashReconciliationModel.isSingleCashDrawer = false;
                    	}
                    	
                    	if(!isPreventLoadMinicalendarData) {
                    		$scope.CashReconciliationModel.getMinicalenderData();
                    	}
                    } else {
                    	$scope.CashReconciliationModel.TransactionTypeList = successfulResult;
                    }
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
            }
            
            function bindDrawerViewData(successfulResult) {
            	$scope.CashReconciliationModel.ReconciliationData = successfulResult;
                $scope.CashReconciliationModel.ReconciliationDataForDate = successfulResult.ReconciliationInfo;
                
                if(successfulResult.CashDrawerReconcilationObjList.length == 1) {
                	$scope.CashReconciliationModel.CashReconciliationPaymentList = successfulResult.CashDrawerReconcilationObjList[0].CashReconciliationPaymentList;
                    $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList = successfulResult.CashDrawerReconcilationObjList[0].OtherReconciliationPaymentList;
                    $scope.CashReconciliationModel.calculateAmountTotals();
                    for (var i = 0; i < $scope.CashReconciliationModel.CashReconciliationPaymentList.length; i++) {
                        $scope.CashReconciliationModel.CashReconciliationPaymentList[i].isEdit = false;
                    }
                    for (var i = 0; i < $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList.length; i++) {
                        $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[i].isEdit = false;
                    }
                }
                
                angular.element('html, body').stop().animate({
                    scrollTop: 0
                }, 500);
            }
            
            $scope.CashReconciliationModel.getCashDrawerReconciliationPaymentsByDrawerId = function(drawerId) {
            	var reconciliationDate = $scope.CashReconciliationModel.selectedDay.clone().format($Global.SchedulingDateFormat);
            	CashReconciliationService.getCashDrawerReconciliationPaymentsByDrawerId(reconciliationDate, $scope.CashReconciliationModel.selectedCashDrawerId).then(function(paymentMethodNameToIdMap) {
                   if(paymentMethodNameToIdMap && Object.keys(paymentMethodNameToIdMap).length > 0) {
                	   for (var i = 0; i < $scope.CashReconciliationModel.CashReconciliationPaymentList.length; i++) {
                           $scope.CashReconciliationModel.CashReconciliationPaymentList[i].Id = paymentMethodNameToIdMap.hasOwnProperty($scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualPaymentMethodName) 
                           																			? paymentMethodNameToIdMap[$scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualPaymentMethodName] : null;
                       }
                       for (var i = 0; i < $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList.length; i++) {
                    	   $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[i].Id = paymentMethodNameToIdMap.hasOwnProperty($scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[i].ActualPaymentMethodName) 
																											? paymentMethodNameToIdMap[$scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[i].ActualPaymentMethodName] : null;
                       }
                        $scope.CashReconciliationModel.isLoading = false;
                    	$scope.CashReconciliationModel.isFirstSaveForTheDate = false;
                    }
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                    $scope.CashReconciliationModel.isLoading = false;
                	$scope.CashReconciliationModel.isFirstSaveForTheDate = false;
                });
            }
            
            $scope.CashReconciliationModel.loadDrawerView = function(drawerId) {
            	$scope.CashReconciliationModel.viewName = 'Drawer';
            	if(drawerId) {
            		$scope.CashReconciliationModel.selectedCashDrawerId = drawerId;
                	var reconciliationDate = $scope.CashReconciliationModel.selectedDay.clone().format($Global.SchedulingDateFormat);
                    $scope.CashReconciliationModel.showAnimation = false;
                	CashReconciliationService.getCashDrawerReconciliationByDrawerId(reconciliationDate, $scope.CashReconciliationModel.selectedCashDrawerId).then(function(successfulResult) {
                        $scope.CashReconciliationModel.currentDay = $scope.CashReconciliationModel.selectedDay.clone().format('dddd DD MMMM YYYY');
                        $scope.CashReconciliationModel.showAnimation = true;
                        $scope.CashReconciliationModel.isContentLoading = false;
                        bindDrawerViewData(successfulResult);
                        $scope.CashReconciliationModel.getMinicalenderData();
                    }, function(errorMessage) {
                        Notification.error(errorMessage);
                    });
            	} else {
            		$scope.CashReconciliationModel.loadCashReconciliationData();
            	}
            }
            
            $scope.CashReconciliationModel.printCashReconciliationData = function() {
	           	var reconciliationDate = $scope.CashReconciliationModel.selectedDay.clone().format($Global.SchedulingDateFormat);
	            window.open('/apex/PrintCashReconciliation?ReconciledDate=' + reconciliationDate + ($scope.CashReconciliationModel.selectedCashDrawerId ? ('&CashDrawerId=' + $scope.CashReconciliationModel.selectedCashDrawerId) : ''), '_blank');
            }
            
            /**
             * Button would be conditionally visible:
             *  a.) SUBMIT FOR REVIEW(Without the "reconcile"(primary) permission): Till the status is not set to 'Reviewed' or 'Reconciled'
             *  b.) REVIEWED(With the “reconcile”(primary and secondary) permission): Till the status not set to 'Reconciled'
             * Alterring actual values:
             *  a.) Without the "reconcile"(primary) permission): Till the status is not set to 'Reviewed' or 'Reconciled'
             *  b.) With the “reconcile”(primary and secondary) permission): Till the status not set to 'Reconciled'
			*/
            $scope.CashReconciliationModel.isIndividualDrawerEditReconcileActionAvailable = function() {
            	if($scope.CashReconciliationModel.isSingleCashDrawer && $scope.CashReconciliationModel.ReconciliationDataForDate.Status === 'Reconciled') {
            		return false;
            	} else if(!$scope.CashReconciliationModel.isSingleCashDrawer) {
            		if(!$scope.GroupOnlyPermissions['Cash reconciliation']['reconcile'] 
            			&& ($scope.CashReconciliationModel.ReconciliationData.CashDrawerReconcilationObjList[0].Status === 'Reviewed' 
            				|| $scope.CashReconciliationModel.ReconciliationData.CashDrawerReconcilationObjList[0].Status === 'Reconciled')) {
	            		return false;
	            	}  else if($scope.GroupOnlyPermissions['Cash reconciliation']['reconcile'] 
	            			&& $scope.CashReconciliationModel.ReconciliationData.CashDrawerReconcilationObjList[0].Status === 'Reconciled') {
	            		return false;
	            	} 
            	}
            	return true;
            }
			
            $scope.CashReconciliationModel.disableReconcileDayActionBtn = function() {
            	for(var i = 0; i < $scope.CashReconciliationModel.ReconciliationData.CashDrawerReconcilationObjList.length; i++) {
            		if($scope.CashReconciliationModel.ReconciliationData.CashDrawerReconcilationObjList[i].Status === 'Unreconciled') {
            			return true;
            		}
            	}
            	return false;
            }
            
            $scope.CashReconciliationModel.loadCashReconciliation = function() {
                $scope.CashReconciliationModel.loadCalendar();
            }
            
            /** Mehtod to prevent Typing on line item actual value field when 
             * Cash Reconciliation record is record is 'creating' for the date. 
             */
            $scope.CashReconciliationModel.disableTypingOnActualValue = function(event) {
            	if($scope.CashReconciliationModel.isFirstSaveForTheDate) {
            		event.preventDefault();
            	}
            }
            
            $scope.CashReconciliationModel.saveCashReconciliationData = function(index, gridName) {
            	if($scope.CashReconciliationModel.isFirstSaveForTheDate) {
            		return; 
            	}
            	
            	if($scope.CashReconciliationModel.selectedCashDrawerId) {
            		for (var i = 0; i < $scope.CashReconciliationModel.CashReconciliationPaymentList.length; i++) {
                        if ($scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount == '' || $scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount == undefined) {
                            $scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount = null;
                        }
                    }
            	}
            	
            	if(gridName == 'Line Item' && !$scope.CashReconciliationModel.CashReconciliationPaymentList[index].Id) {
            		$scope.CashReconciliationModel.isLoading = true;
            		$scope.CashReconciliationModel.isFirstSaveForTheDate = true;
            	} 
                
                CashReconciliationService.saveReconciliation(angular.toJson($scope.CashReconciliationModel.ReconciliationData), null).then(function(successfulResult) {
                    if (gridName == null && successfulResult === 'Success' && !$scope.CashReconciliationModel.selectedCashDrawerId) {
                    	$scope.CashReconciliationModel.loadCashReconciliationData();
                    } else if (gridName == null && successfulResult === 'Success' && $scope.CashReconciliationModel.selectedCashDrawerId) {
                    	$scope.CashReconciliationModel.loadDrawerView($scope.CashReconciliationModel.selectedCashDrawerId);
                    } else if(gridName == 'Line Item' && successfulResult === 'Success' && !$scope.CashReconciliationModel.CashReconciliationPaymentList[index].Id) {
                    	$scope.CashReconciliationModel.getCashDrawerReconciliationPaymentsByDrawerId($scope.CashReconciliationModel.selectedCashDrawerId);
                    } else {
                    	$scope.CashReconciliationModel.isLoading = false;
                    	$scope.CashReconciliationModel.isFirstSaveForTheDate = false;
                    }
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                    $scope.CashReconciliationModel.isLoading = false;
                	$scope.CashReconciliationModel.isFirstSaveForTheDate = false;
                });
            }
            $scope.CashReconciliationModel.getMinicalenderData = function() {
                var temp = {
                    StartDate: $scope.CashReconciliationModel.weeksOfMonth[0].days[0].dayDate,
                    EndDate: $scope.CashReconciliationModel.weeksOfMonth[MAX_NO_OF_WEEKS_IN_MONTH - 1].days[NO_Of_DAYS_IN_WEEK - 1].dayDate
                };
                var monthNumber = moment($scope.CashReconciliationModel.selectedDay).month() + 1;
                CashReconciliationService.getMiniCalenderDataByDrawerId(angular.toJson(temp),  $scope.CashReconciliationModel.selectedCashDrawerId).then(function(successfulResult) {
                    $scope.CashReconciliationModel.MinicalenderMonthData = successfulResult;
                    for (var i = 0; i < $scope.CashReconciliationModel.weeksOfMonth.length; i++) {
                        for (var j = 0; j < $scope.CashReconciliationModel.weeksOfMonth[i].days.length; j++) {
                            var reconciled = false;
                            var submitted =  false;
                            var reviewed = false;
                            for (var k = 0; k < $scope.CashReconciliationModel.MinicalenderMonthData.length; k++) {
                                if ($scope.CashReconciliationModel.weeksOfMonth[i].days[j].dayDate == $scope.CashReconciliationModel.MinicalenderMonthData[k].ReconciliationDate) {
                                    if ($scope.CashReconciliationModel.MinicalenderMonthData[k].Status == 'Reconciled') {
                                        reconciled = true;
                                    } else if($scope.CashReconciliationModel.MinicalenderMonthData[k].Status == 'Submitted') {
                                    	submitted = true;
                                    } else if($scope.CashReconciliationModel.MinicalenderMonthData[k].Status == 'Reviewed') {
                                    	reviewed = true;
                                    }
                                    break;
                                }
                            }
                            $scope.CashReconciliationModel.weeksOfMonth[i].days[j].isReconciled = reconciled;
                            $scope.CashReconciliationModel.weeksOfMonth[i].days[j].isSubmitted = submitted;
                            $scope.CashReconciliationModel.weeksOfMonth[i].days[j].isReviewed = reviewed;
                        }
                    }
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
            }

            function expandElement(expandableElement, expandableElementHeightToBeApplied, transitionDelay) {
                if (expandableElement != undefined && expandableElement != null && expandableElement != '') {
                    if (transitionDelay != undefined && transitionDelay != null && transitionDelay != '') {
                        expandableElement.css('transition-delay', transitionDelay);
                    }
                    expandableElement.css('height', expandableElementHeightToBeApplied);
                    expandableElement.addClass('bp-expand-div-transition');
                }
            }

            function collapseElement(collapsableElement) {
                if (collapsableElement != undefined && collapsableElement != null && collapsableElement != '') {
                    collapsableElement.removeAttr('style');
                    collapsableElement.removeClass('bp-expand-div-transition');
                }
            }

            function addTransitionWhileExpandPaymentDetailsRow(expandableRowId, expandedRowFlag) {
                var expandableRowDiv = angular.element(angular.element(expandableRowId + ' > td.payment-details-wrapper > div')[0]);
                var expandableRowTableHeight = angular.element(angular.element(expandableRowId + ' > td.payment-details-wrapper > div > table')[0]).outerHeight();
                var transitionDelay;
                if (expandedRowFlag) {
                    transitionDelay = '0.3s';
                }
                expandElement(expandableRowDiv, expandableRowTableHeight, transitionDelay);
            }

            function addTransitionWhileCollapsePaymentDetailsRow(collapsableRowId) {
                var collapsableRowDiv = angular.element(angular.element(collapsableRowId + ' > td.payment-details-wrapper > div')[0]);
                collapseElement(collapsableRowDiv);
            }
            var collapsableRowId;
            var expandableRowId;
            var expandedRowFlag;
            $scope.CashReconciliationModel.expandEditablePaymentMethods = function(index) {
                expandedRowFlag = false;
                for (var i = 0; i < $scope.CashReconciliationModel.CashReconciliationPaymentList.length; i++) {
                    if ($scope.CashReconciliationModel.CashReconciliationPaymentList[i].isEdit) {
                        collapsableRowId = '#payment-details-wrapper-tr_1_' + i;
                        addTransitionWhileCollapsePaymentDetailsRow(collapsableRowId);
                        expandedRowFlag = true;
                    }
                    $scope.CashReconciliationModel.CashReconciliationPaymentList[i].isEdit = false;
                }
                for (var i = 0; i < $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList.length; i++) {
                    if ($scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[i].isEdit) {
                        collapsableRowId = '#payment-details-wrapper-tr_2_' + i;
                        addTransitionWhileCollapsePaymentDetailsRow(collapsableRowId);
                        expandedRowFlag = true;
                    }
                    $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[i].isEdit = false;
                }
                $scope.CashReconciliationModel.CashReconciliationPaymentList[index].isEdit = true;
                expandableRowId = '#payment-details-wrapper-tr_1_' + index;
                addTransitionWhileExpandPaymentDetailsRow(expandableRowId, expandedRowFlag);
            }
            $scope.CashReconciliationModel.expandNotEditablePaymentMethods = function(index) {
                expandedRowFlag = false;
                for (var i = 0; i < $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList.length; i++) {
                    if ($scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[i].isEdit) {
                        collapsableRowId = '#payment-details-wrapper-tr_2_' + i;
                        addTransitionWhileCollapsePaymentDetailsRow(collapsableRowId);
                        expandedRowFlag = true;
                    }
                    $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[i].isEdit = false;
                }
                for (var i = 0; i < $scope.CashReconciliationModel.CashReconciliationPaymentList.length; i++) {
                    if ($scope.CashReconciliationModel.CashReconciliationPaymentList[i].isEdit) {
                        collapsableRowId = '#payment-details-wrapper-tr_1_' + i;
                        addTransitionWhileCollapsePaymentDetailsRow(collapsableRowId);
                        expandedRowFlag = true;
                    }
                    $scope.CashReconciliationModel.CashReconciliationPaymentList[i].isEdit = false;
                }
                $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[index].isEdit = true;
                expandableRowId = '#payment-details-wrapper-tr_2_' + index;
                addTransitionWhileExpandPaymentDetailsRow(expandableRowId, expandedRowFlag);
            }
            $scope.CashReconciliationModel.hideNotEditablePaymentMethods = function(index) {
                $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[index].isEdit = false;
                collapsableRowId = '#payment-details-wrapper-tr_2_' + index;
                addTransitionWhileCollapsePaymentDetailsRow(collapsableRowId);
            }
            $scope.CashReconciliationModel.hideEditablePaymentMethods = function(index) {
                $scope.CashReconciliationModel.CashReconciliationPaymentList[index].isEdit = false;
                collapsableRowId = '#payment-details-wrapper-tr_1_' + index;
                addTransitionWhileCollapsePaymentDetailsRow(collapsableRowId);
            }
            $scope.CashReconciliationModel.calculateAmountTotals = function() {
                var TotalProcessedAmount = 0;
                var TotalActualAmount = 0;
                for (var i = 0; i < $scope.CashReconciliationModel.CashReconciliationPaymentList.length; i++) {
                    var VarianceAmount = 0;
                    var ActualAmount = 0;
                    TotalProcessedAmount += parseFloat($scope.CashReconciliationModel.CashReconciliationPaymentList[i].ProcessedAmount);
                    if (!isNaN(parseFloat($scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount))) {
                        if (typeof $scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount == 'number') {
                            $scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount = $scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount.toFixed(2);
                        }
                        TotalActualAmount += parseFloat($scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount);
                        ActualAmount = parseFloat($scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount);
                        VarianceAmount = parseFloat($scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount) - parseFloat($scope.CashReconciliationModel.CashReconciliationPaymentList[i].ProcessedAmount)
                    }
                    VarianceAmount = ActualAmount - parseFloat($scope.CashReconciliationModel.CashReconciliationPaymentList[i].ProcessedAmount)
                    $scope.CashReconciliationModel.CashReconciliationPaymentList[i].VarianceAmount = VarianceAmount;
                }
                if ($scope.CashReconciliationModel.ReconciliationDataForDate != undefined && $scope.CashReconciliationModel.ReconciliationDataForDate != null && $scope.CashReconciliationModel.ReconciliationDataForDate != '') {
                    $scope.CashReconciliationModel.ReconciliationDataForDate.TotalProcessedAmount = parseFloat(TotalProcessedAmount);
                    $scope.CashReconciliationModel.ReconciliationDataForDate.TotalActualAmount = parseFloat(TotalActualAmount);
                    $scope.CashReconciliationModel.ReconciliationDataForDate.TotalVarianceAmount = TotalActualAmount - TotalProcessedAmount;
                }
            }

            function addTransitionWhileExpandWarningTemplateDiv(expandableDivId) {
                var expandableDiv = angular.element(expandableDivId);
                var expandableDivChildDivHeight = angular.element(angular.element(expandableDivId + ' > div')[0]).outerHeight();
                expandElement(expandableDiv, expandableDivChildDivHeight);
            }

            function addTransitionWhileCollapseWarningTemplateDiv(collapsableDivId) {
                var collapsableDiv = angular.element('#warning-template-container-id');
                collapseElement(collapsableDiv);
            }
            $scope.CashReconciliationModel.disableToday = function() {
                if ($scope.CashReconciliationModel.showAnimation) {
                    var expandableOrCollapsableDivId = '#warning-template-container-id';
                    if ($scope.CashReconciliationModel.selectedDay.format($Global.SchedulingDateFormat) === moment().format($Global.SchedulingDateFormat)) {
                        addTransitionWhileExpandWarningTemplateDiv(expandableOrCollapsableDivId);
                        return true;
                    } else {
                        addTransitionWhileCollapseWarningTemplateDiv(expandableOrCollapsableDivId);
                        return false;
                    }
                }
            }
            $scope.CashReconciliationModel.disableCommitButton = function() {
                if(!$scope.CashReconciliationModel.isIndividualDrawerEditReconcileActionAvailable()) {
            		return true;
            	} 
            	
                for (var i = 0; i < $scope.CashReconciliationModel.CashReconciliationPaymentList.length; i++) {
                    if (isBlankValue($scope.CashReconciliationModel.CashReconciliationPaymentList[i].ActualAmount)) {
                        return true;
                    }
                }
                
                return false;
            }
            
            $scope.CashReconciliationModel.CommitIndividualDrawerChanges = function() {
                $scope.CashReconciliationModel.ReconciliationData.CashDrawerReconcilationObjList[0].Status = $translate.instant($rootScope.GroupOnlyPermissions['Cash reconciliation']['reconcile'] ? 'Reviewed' : 'Submitted');
            	
            	$scope.CashReconciliationModel.saveCashReconciliationData('', null);
            }
            
            $scope.CashReconciliationModel.CommitReconciliationChanges = function() {
                $scope.CashReconciliationModel.ReconciliationDataForDate.Status = 'Reconciled';
            	$scope.CashReconciliationModel.saveCashReconciliationData('', null);
            }
            
            $scope.CashReconciliationModel.disableRightChevron = function() {
                if ((moment($scope.CashReconciliationModel.selectedDay.clone()).startOf('day')).diff((moment().startOf('day')), 'days') === 0) {
                    return true;
                }
                return false;
            }
            $scope.CashReconciliationModel.disableNextMonthChevron = function() {
                if (moment($scope.CashReconciliationModel.currentMonth.clone()).month() == moment().month() && moment($scope.CashReconciliationModel.currentMonth.clone()).year() == moment().year()) {
                    return true;
                }
                return false;
            }
            window.onresize = function(event) { 
                if($scope.CashReconciliationModel.selectedCashDrawerId) {
                	var expandedDiv;
                    var expandedDivChildDivHeight;
                    /*Start: Calculate Height For Warning Template */
                    if ($scope.CashReconciliationModel.selectedDay.format($Global.SchedulingDateFormat) === moment().format($Global.SchedulingDateFormat)) {
                        expandedDiv = angular.element('#warning-template-container-id');
                        expandedDivChildDivHeight = angular.element(angular.element('#warning-template-container-id > div')[0]).outerHeight();
                        expandedDiv.css('height', expandedDivChildDivHeight);
                    }
                    /*End: Calculate Height For Warning Template */
                    /*Start: Calculate Height For expanded row of OtherReconciliationPaymentMethodsList */
                    for (var i = 0; i < $scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList.length; i++) {
                        if ($scope.CashReconciliationModel.OtherReconciliationPaymentMethodsList[i].isEdit) {
                            expandedDiv = angular.element(angular.element('#payment-details-wrapper-tr_2_' + i + ' > td.payment-details-wrapper > div')[0]);
                            expandedDivChildDivHeight = angular.element(angular.element('#payment-details-wrapper-tr_2_' + i + ' > td.payment-details-wrapper > div > table')[0]).outerHeight();
                            expandedDiv.css('height', expandedDivChildDivHeight);
                            break;
                        }
                    }
                    /*End: Calculate Height For expanded row of OtherReconciliationPaymentMethodsList */
                    /*Start: Calculate Height For expanded row of CashReconciliationPaymentList */
                    for (var i = 0; i < $scope.CashReconciliationModel.CashReconciliationPaymentList.length; i++) {
                        if ($scope.CashReconciliationModel.CashReconciliationPaymentList[i].isEdit) {
                            expandedDiv = angular.element(angular.element('#payment-details-wrapper-tr_1_' + i + ' > td.payment-details-wrapper > div')[0]);
                            expandedDivChildDivHeight = angular.element(angular.element('#payment-details-wrapper-tr_1_' + i + ' > td.payment-details-wrapper > div > table')[0]).outerHeight();
                            expandedDiv.css('height', expandedDivChildDivHeight);
                            break;
                        }
                    }
                    /*End: Calculate Height For expanded row of CashReconciliationPaymentList */
                }
            }  
            $scope.CashReconciliationModel.loadCashReconciliation();
        }
    ])
});