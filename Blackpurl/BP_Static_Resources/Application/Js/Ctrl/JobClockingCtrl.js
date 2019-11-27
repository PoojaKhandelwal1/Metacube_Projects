define(['Routing_AppJs_PK', 'JobClockingServices','underscore_min','JqueryUI', 'moment'], function(Routing_AppJs_PK, JobClockingServices,underscore_min,JqueryUI, moment) {

    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('JobClockingCtrl', ['$q', '$scope', '$rootScope', '$stateParams', '$sce', '$state', 'JobClockingPageService', '$compile','$filter','$translate', function($q, $scope, $rootScope, $stateParams, $sce, $state, JobClockingPageService, $compile,$filter,$translate) {
        var Notification = injector.get("Notification");
        if (angular.isDefined($scope.jobClockingModel)) {
        } else {;
            $scope.jobClockingModel = {};
        }
        $scope.jobClockingModel.isEdit = -1;
        $scope.jobClockingModel.selectedClockingStaff = {};
        $scope.jobClockingModel.newTaskEntryCopy = {};
        $scope.jobClockingModel.isTechnicianMode = false;
        $scope.jobClockingModel.showHistory = false;
        $scope.jobClockingModel.clockedDay = false;
        $scope.jobClockingModel.dateFormat = $Global.DateFormat;
        $scope.jobClockingModel.fromDate = '';
        $scope.jobClockingModel.toDate = ''
        $scope.jobClockingModel.isBlur = true;
        var focusedElement;
		$scope.jobClockingModel.FromDateOptions = {
        		maxDate: new Date,
        		dateFormat: $scope.jobClockingModel.dateFormat,
                showOtherMonths: true,
                selectOtherMonths: true,
                dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        		  
		};
        $scope.jobClockingModel.toDateOptions = {
        		minDate: '',
        		maxDate: new Date,
    			dateFormat: $scope.jobClockingModel.dateFormat,
                showOtherMonths: true,
                selectOtherMonths: true,
                dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        		  
		};
		$scope.jobClockingModel.showDatePicker = function(event,Id){
          angular.element("#"+ Id).focus();
		}
        $scope.jobClockingModel.openjobClockingPopup = function() {
            setTimeout(function() {
                angular.element('#bp-job-clocking').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
            $scope.jobClockingModel.TechinicianObj = {};
            $scope.jobClockingModel.TechinicianObj.Name = '';
            $scope.jobClockingModel.taskFilterValue = '';
        }
        $scope.jobClockingModel.loadPopupData = function() {
			$scope.jobClockingModel.openjobClockingPopup();
            $scope.jobClockingModel.currentSelectedClockingStaffIndex = -1;
            $scope.jobClockingModel.currentTechIndexForAddNewTsk = -1;
            $scope.jobClockingModel.currentTaskIndexForFilter = -1;
            $scope.jobClockingModel.viewChange = 'service jobs'
            JobClockingPageService.getServiceJobs(null).then(function(successResult) {
                $scope.jobClockingModel.jobClockingDefaultList = successResult;
                angular.element('[role ="tooltip"]').hide()
                setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
      			 }, 500);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        angular.element(document).on("click", "#bp-job-clocking .modal-backdrop", function() {
            $scope.jobClockingModel.hideRelatedPartPopup();
        });
        $scope.jobClockingModel.hideRelatedPartPopup = function() {
            angular.element("body").removeClass("modal-open");
            angular.element(".click-back-drop").hide();
        	 angular.element("body").css("padding","0px");
        	loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.jobClockingModel.backToAllServiceJons = function() {
            $scope.jobClockingModel.currentSelectedClockingStaffIndex = -1;
            $scope.jobClockingModel.selectedClockingStaff = {};
            if($scope.jobClockingModel.viewChange == 'service jobs'){ 
	            JobClockingPageService.getServiceJobs(null).then(function(successResult) {
	                $scope.jobClockingModel.isTechnicianMode = false;
	                $scope.jobClockingModel.isEdit = -1;
	                $scope.jobClockingModel.jobClockingDefaultList = successResult;
	                angular.element('[role ="tooltip"]').hide()
	                setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
	                	angular.element(".jobsList").scrollTop = 0;
	                }, 500);
	            }, function(errorMessage) {
	                Notification.error(errorMessage);
	            });
            }
			if($scope.jobClockingModel.viewChange == 'other tasks'){
				JobClockingPageService.getTaskListWithTechnicianId(null).then(function(successResult) {
					$scope.jobClockingModel.isTechnicianMode = false;
	                $scope.jobClockingModel.isEdit = -1;
					$scope.jobClockingModel.defaultTaskList = successResult;
					angular.element('[role ="tooltip"]').hide()
						setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
						}, 500);
				}, function(errorMessage) {
					Notification.error(errorMessage);
				});
			}
        }
        $scope.jobClockingModel.getTechnicianList = function(soHeaderId, event,isAssignTech) {
            var toppopupposition = 0;
            var leftpopupposition = 0;
            var heightofcircle = 0;
            var widthofcircle = 0;
            var getCurrentBtnOffset = 0;
            if(isAssignTech != undefined){
            	toppopupposition = angular.element("#" + soHeaderId + " .bp-btn-Assign-Tech ").offset().top;
                leftpopupposition = angular.element("#" + soHeaderId + " .bp-btn-Assign-Tech ").offset().left;
				heightofcircle = angular.element("#" + soHeaderId + " .bp-btn-Assign-Tech").outerHeight() - 10;
				widthofcircle = Math.round(angular.element("#" + soHeaderId + " .bp-btn-Assign-Tech").width()/2) + 10;
				angular.element(".clockingStaffPopup").css("max-width", '805px');
				getCurrentBtnOffset = toppopupposition;
            }else{
					toppopupposition = angular.element("#" + soHeaderId + " .techniciansList .addNew ").find(".circle").offset().top;
					leftpopupposition = angular.element("#" + soHeaderId + " .techniciansList .addNew ").find(".circle").offset().left;
					heightofcircle = angular.element("#" + soHeaderId + " .techniciansList .addNew ").find(".circle").outerHeight();
					widthofcircle = Math.round(angular.element("#" + soHeaderId + " .techniciansList .addNew ").find(".circle").width()/2);
					angular.element(".clockingStaffPopup").css("max-width", '600px');
					angular.element("#" + soHeaderId + " .techniciansList .addNew ").find(".circle").addClass("rotate");
					getCurrentBtnOffset = toppopupposition;
            }
            var getTotalHeight = (angular.element("#bp-job-clocking").find(".modal-dialog").height() + 60);
            angular.element(".clockingStaffremoveTech").css("visibility", 'hidden');
            angular.element(".clockingStaffremoveTech").css("opacity", 0);
            $scope.jobClockingModel.soHeaderId = soHeaderId;
            JobClockingPageService.getTechnicianList(soHeaderId).then(function(successResult) {
                $scope.jobClockingModel.technicianList = successResult;
                if($scope.jobClockingModel.technicianList.length == 0){
                	Notification.error($translate.instant('All_technician_assigned_error_message'));
                	return;
                }
                var clockingStaffPopuplength = $scope.jobClockingModel.technicianList.length * 70;
                angular.element(".clockingStaffPopup").css("visibility", 'visible');
                angular.element(".clockingStaffPopup").css("width", (clockingStaffPopuplength + 40) + 'px');
                angular.element(".clockingStaffPopup").css("visibility", 'visible');
                angular.element(".clockingStaffPopup").css("opacity", 1);
                angular.element(".clockingStaffPopup").css("z-index", -1);
            	setTimeout(function(){
            		var getpopHeight = angular.element(".clockingStaffPopup").height();
            		var showPopposition = toppopupposition + getpopHeight - (parseInt(angular.element(window).scrollTop()));
            	if(showPopposition < getTotalHeight){
                	if(isAssignTech != undefined){
                		angular.element(".clockingStaffPopup").addClass("reversePopup");
                		if(parseInt(angular.element(".clockingStaffPopup").css("width")) < parseInt(angular.element(".clockingStaffPopup").css("max-width"))){
                			angular.element(".clockingStaffPopup").css("left", (leftpopupposition + widthofcircle + 12) - (parseInt(angular.element(".clockingStaffPopup").css("width")) / 2) - 100 + 'px');
                		}
                		else{
                		angular.element(".clockingStaffPopup").css("left", (leftpopupposition + widthofcircle + 12) - (parseInt(angular.element(".clockingStaffPopup").css("max-width")) / 2) - 100 + 'px');
                		}
                    	angular.element(".clockingStaffPopup").css("top", (toppopupposition + heightofcircle - (angular.element(".clockingStaffPopup").height()) / 2) - 50 - (parseInt(angular.element(window).scrollTop())) + 'px');
                	}else{
                		angular.element(".clockingStaffPopup").css("left", (leftpopupposition + widthofcircle + 12) + 'px');
                    	angular.element(".clockingStaffPopup").css("top", (toppopupposition + heightofcircle + 20) -  (parseInt(angular.element(window).scrollTop())) + 'px');
                	}
                	
                	angular.element(".clockingStaffPopup").css("z-index", 100000);
                	
                }else{
                		angular.element(".clockingStaffPopup").addClass("reversePopup");
                		if(isAssignTech != undefined){
                					
                			if(parseInt(angular.element(".clockingStaffPopup").css("width")) < parseInt(angular.element(".clockingStaffPopup").css("max-width"))){
                				angular.element(".clockingStaffPopup").css("left", (leftpopupposition + widthofcircle + 12) - (parseInt(angular.element(".clockingStaffPopup").css("width")) / 2) - 100 + 'px');
                			}else{
                			angular.element(".clockingStaffPopup").css("left", (leftpopupposition + widthofcircle + 12) - (parseInt(angular.element(".clockingStaffPopup").css("max-width")) / 2) - 100 + 'px');
                			}
                			angular.element(".clockingStaffPopup").css("top", (toppopupposition - heightofcircle - (angular.element(".clockingStaffPopup").height()) / 2) -  (parseInt(angular.element(window).scrollTop())) + 'px');
                		}else{
                			angular.element(".clockingStaffPopup").css("left", (leftpopupposition + widthofcircle + 12) - (parseInt(angular.element(".clockingStaffPopup").css("max-width")) / 2) - 30  + 'px');
                			angular.element(".clockingStaffPopup").css("top", (toppopupposition - heightofcircle - (angular.element(".clockingStaffPopup").height()) / 2) + 35 -  (parseInt(angular.element(window).scrollTop())) + 'px');
                		}
                    	angular.element(".clockingStaffPopup").css("z-index", 100000);
                }
            	
            	},100);
                $scope.jobClockingModel.addTechBackdrop();
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.jobClockingModel.selfassignToTechnician = function(soHeaderId) {
            var viewTechId = $scope.jobClockingModel.selectedClockingStaff.Id; 
            var soHeaderIndex = -1;
        	for(var i=0;i<$scope.jobClockingModel.jobClockingDefaultList.length;i++) {
            	if($scope.jobClockingModel.jobClockingDefaultList[i].Id == soHeaderId) {
            		soHeaderIndex = i;
            		break;
            	}
            }
           JobClockingPageService.assignTechnician(soHeaderId, $scope.jobClockingModel.selectedClockingStaff.Id,viewTechId).then(function(successResult) {
                $scope.jobClockingModel.jobClockingDefaultList[soHeaderIndex] = successResult;
                soHeaderIndex = -1;
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.jobClockingModel.addTechBackdrop = function() {
            setTimeout(function() {
                var template = '<div class = "bp-modal-backdrop " ng-click = "jobClockingModel.hidetechpopup()"></div>';
                template = $compile(angular.element(template))($scope);
                angular.element("#bp-job-clocking").prepend(template);

            }, 500);
        }
        $scope.jobClockingModel.hidetechpopup = function() {
            angular.element(".clockingStaffPopup").css("visibility", 'hidden');
            angular.element(".clockingStaffPopup").css("opacity", 0);
            angular.element(".clockingStaffremoveTech").css("visibility", 'hidden');
            angular.element(".clockingStaffremoveTech").css("opacity", 0);
            angular.element("#bp-job-clocking").find('.bp-modal-backdrop').remove();
            angular.element(".techniciansList .addNew ").find(".circle").removeClass("rotate");
            angular.element(".clockingStaffPopup").removeClass("reversePopup");
        }

        $scope.jobClockingModel.clockONTechnician = function(soHeaderId) {
            for(var i=0;i<$scope.jobClockingModel.jobClockingDefaultList.length;i++) {
            	if($scope.jobClockingModel.jobClockingDefaultList[i].IsServiceJobClocked == true) {
            		$scope.jobClockingModel.jobClockingDefaultList[i].IsServiceJobClocked = false;
            		for(var j=0;j<$scope.jobClockingModel.jobClockingDefaultList[i].TechnicianList.length;j++) {
            			if($scope.jobClockingModel.jobClockingDefaultList[i].TechnicianList[j].TechnicianId == $scope.jobClockingModel.selectedClockingStaff.Id) {
            				$scope.jobClockingModel.jobClockingDefaultList[i].TechnicianList[j].IsClocked = false;
            				break;
            			}
            		}
            		break;
            	}
            }
            
            for(var i=0;i<$scope.jobClockingModel.jobClockingDefaultList.length;i++) {
            	if($scope.jobClockingModel.jobClockingDefaultList[i].Id == soHeaderId) {
            		$scope.jobClockingModel.jobClockingDefaultList[i].IsServiceJobClocked = true;
            		$scope.jobClockingModel.jobClockingDefaultList[i].ServiceJobStatus = "In Progress";
            		for(var j=0;j<$scope.jobClockingModel.jobClockingDefaultList[i].TechnicianList.length;j++) {
            			if($scope.jobClockingModel.jobClockingDefaultList[i].TechnicianList[j].TechnicianId == $scope.jobClockingModel.selectedClockingStaff.Id) {
            				$scope.jobClockingModel.jobClockingDefaultList[i].TechnicianList[j].IsClocked = true;
            				break;
            			}
            		}
            		break;
            	}
            }
            
            
            JobClockingPageService.clockONTechnician(soHeaderId, $scope.jobClockingModel.selectedClockingStaff.Id).then(function(successResult) {
                for(var i=0; i < $scope.jobClockingModel.jobClockingDefaultList.length;i++){
                	if($scope.jobClockingModel.jobClockingDefaultList[i].IsServiceJobClocked == true){
                		$scope.jobClockingModel.clockedDay = true;
                		break;
                	}
                 }
                
                
                $scope.jobClockingModel.getPayrollEntryForTechnician();
                
            }, function(errorMessage) {
            	JobClockingPageService.getServiceJobs($scope.jobClockingModel.selectedClockingStaff.Id).then(function(successResult) {
            		$scope.jobClockingModel.jobClockingDefaultList = successResult;
            	});
                Notification.error(errorMessage);
            });
        }
        $scope.jobClockingModel.setClockkOnforTask = function(taskId){
            for(var i=0;i<$scope.jobClockingModel.defaultTaskList.length;i++) {
            	if($scope.jobClockingModel.defaultTaskList[i].IsClockedOn == true) {
            		$scope.jobClockingModel.defaultTaskList[i].IsClockedOn = false;
            		for(var j=0;j<$scope.jobClockingModel.defaultTaskList[i].TechnicianList.length;j++) {
            			if($scope.jobClockingModel.defaultTaskList[i].TechnicianList[j].TechnicianId == $scope.jobClockingModel.selectedClockingStaff.Id) {
            				$scope.jobClockingModel.defaultTaskList[i].TechnicianList[j].IsClocked = false;
            				break;
            			}
            		}
            		break;
            	}
            }
            for(var i=0;i<$scope.jobClockingModel.defaultTaskList.length;i++) {
            	if($scope.jobClockingModel.defaultTaskList[i].Id == taskId) {
            		$scope.jobClockingModel.defaultTaskList[i].IsClockedOn = true;
            		for(var j=0;j<$scope.jobClockingModel.defaultTaskList[i].TechnicianList.length;j++) {
            			if($scope.jobClockingModel.defaultTaskList[i].TechnicianList[j].TechnicianId == $scope.jobClockingModel.selectedClockingStaff.Id) {
            				$scope.jobClockingModel.defaultTaskList[i].TechnicianList[j].IsClocked = true;
            				break;
            			}
            		}
            		break;
            	}
            }
        	 JobClockingPageService.clockONTechnician(taskId, $scope.jobClockingModel.selectedClockingStaff.Id).then(function(successResult) {
                 for(var i=0; i < $scope.jobClockingModel.defaultTaskList.length;i++){
                	if($scope.jobClockingModel.defaultTaskList[i].IsClockedOn == true){
                		$scope.jobClockingModel.clockedDay = true;
                	}
                 }
                 $scope.jobClockingModel.getPayrollEntryForTechnician();
             }, function(errorMessage) {
            	 JobClockingPageService.getTaskListWithTechnicianId($scope.jobClockingModel.selectedClockingStaff.Id).then(function(successResult) {
            		 $scope.jobClockingModel.defaultTaskList = successResult;
            	 });
                 Notification.error(errorMessage);
             });
        }
        $scope.jobClockingModel.setPayrollForTechnician = function() {
        	$scope.jobClockingModel.IsPayrollOn = !$scope.jobClockingModel.IsPayrollOn;
        	if(!$scope.jobClockingModel.IsPayrollOn) {
        		for(var i=0;i<$scope.jobClockingModel.jobClockingDefaultList.length;i++) {
            		if($scope.jobClockingModel.jobClockingDefaultList[i].IsServiceJobClocked == true) {
                		$scope.jobClockingModel.jobClockingDefaultList[i].IsServiceJobClocked = false;
                		for(var j=0;j<$scope.jobClockingModel.jobClockingDefaultList[i].TechnicianList.length;j++) {
                			if($scope.jobClockingModel.jobClockingDefaultList[i].TechnicianList[j].TechnicianId == $scope.jobClockingModel.selectedClockingStaff.Id) {
                				$scope.jobClockingModel.jobClockingDefaultList[i].TechnicianList[j].IsClocked = false;
                				break;
                			}
                		}
                		break;
                	}
            	}
        	}
        	var jsonObject = {IsClockedOn : $scope.jobClockingModel.IsPayrollOn, 
        					 TechnicianId : $scope.jobClockingModel.selectedClockingStaff.Id,
        					 Id : $scope.jobClockingModel.PayrollOnId};
        	
        	JobClockingPageService.setPayrollForTechnician(angular.toJson(jsonObject), $scope.jobClockingModel.selectedClockingStaff.Id)
        					.then(function(successResult) {
            	if(successResult.IsPayrollOn != undefined) {
            		$scope.jobClockingModel.IsPayrollOn = successResult.IsPayrollOn;
            	}
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.jobClockingModel.setClockOffForTask = function(taskId){
        	var taskIndex = -1;
        	for(var i=0; i < $scope.jobClockingModel.defaultTaskList.length;i++){
        		if($scope.jobClockingModel.defaultTaskList[i].Id == taskId) {
        			taskIndex = i;
        			break;
        		}
        	}
        	  JobClockingPageService.clockOFFTechnicianWithNotes(taskId, $scope.jobClockingModel.selectedClockingStaff.Id,null).then(function(successResult) {
                  $scope.jobClockingModel.defaultTaskList[taskIndex] = successResult;
                  taskIndex = -1;
                  		$scope.jobClockingModel.clockedDay = false;
              }, function(errorMessage) {
                  Notification.error(errorMessage);
              });
        }
        $scope.jobClockingModel.clockOFFTechnician = function(soHeaderId,index) {
            var soHeaderIndex = -1;
        	for(var i=0;i<$scope.jobClockingModel.jobClockingDefaultList.length;i++) {
            	if($scope.jobClockingModel.jobClockingDefaultList[i].Id == soHeaderId) {
            		soHeaderIndex = i;
            		break;
            	}
            }
            JobClockingPageService.clockOFFTechnicianWithNotes(soHeaderId, $scope.jobClockingModel.selectedClockingStaff.Id,$scope.jobClockingModel.notesModel).then(function(successResult) {
                $scope.jobClockingModel.jobClockingDefaultList[soHeaderIndex] = successResult;
                soHeaderIndex = -1;
                $scope.jobClockingModel.clockedDay = false;
                $scope.jobClockingModel.closeEditModeclocking(index);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.jobClockingModel.skipNotes = function(soHeaderId,index){
        	$scope.jobClockingModel.notesModel = null;
        	 $scope.jobClockingModel.clockOFFTechnician(soHeaderId,index);
        	 
        }
        $scope.jobClockingModel.getAllTechnicianList = function() {
            $scope.jobClockingModel.isFocused = true;
            $scope.jobClockingModel.TechinicianObj = {};
            $scope.jobClockingModel.TechinicianObj.Name = '';
            JobClockingPageService.getTechnicianList(null).then(function(successResult) {
                if($scope.jobClockingModel.selectedClockingStaff != undefined && $scope.jobClockingModel.selectedClockingStaff != null 
                	&& $scope.jobClockingModel.selectedClockingStaff != ''){
                	var j  = _.findIndex(successResult, {Id: $scope.jobClockingModel.selectedClockingStaff.Id});
                    if(j != -1) {
                    	successResult.splice(j, 1);
                    }
                }
                $scope.jobClockingModel.allUserList = successResult;
                angular.element('#autocompleteScrollDiv').animate({
                    scrollTop: 0
                }, 10);
                
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.jobClockingModel.setBlurOnInput = function() {
            $scope.jobClockingModel.isFocused = false;
        }

        $scope.jobClockingModel.changeSeletedclockingStaff = function(event) {
            var keyCode = event.which ? event.which : event.keyCode;
            if (keyCode === 40) {
                if (($scope.jobClockingModel.allUserList.length - 1) > $scope.jobClockingModel.currentSelectedClockingStaffIndex) {
                    $scope.jobClockingModel.currentSelectedClockingStaffIndex++;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.jobClockingModel.currentSelectedClockingStaffIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.jobClockingModel.currentSelectedClockingStaffIndex > 0) {
                    $scope.jobClockingModel.currentSelectedClockingStaffIndex--;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.jobClockingModel.currentSelectedClockingStaffIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 13) {
            	var filterList = $filter("filter")($scope.jobClockingModel.allUserList, $scope.jobClockingModel.TechinicianObj.Name)
                $scope.jobClockingModel.selectClockingstaff(filterList[$scope.jobClockingModel.currentSelectedClockingStaffIndex]);
                $scope.jobClockingModel.currentSelectedClockingStaffIndex = -1;
                $scope.jobClockingModel.isFocused = false;
            }
        }

        $scope.jobClockingModel.checkshowStopBut = function(index){
        	if( $scope.jobClockingModel.isTechnicianMode){
        			for(var j=0;j<$scope.jobClockingModel.jobClockingDefaultList[index].TechnicianList.length;j++){
        				if($scope.jobClockingModel.selectedClockingStaff.Id == $scope.jobClockingModel.jobClockingDefaultList[index].TechnicianList[j].TechnicianId){
        					return true;
        				}
        		}
        	}
        	return false;
        }

        $scope.jobClockingModel.selectClockingstaff = function(clockingStaffRec) {
            $scope.jobClockingModel.showHistory = false;
            if($scope.jobClockingModel.viewChange == 'service jobs'){
	            JobClockingPageService.getServiceJobs(clockingStaffRec.Id).then(function(successResult) {
	                $scope.jobClockingModel.isEdit = -1;
	                $scope.jobClockingModel.TechinicianObj = {};
	                $scope.jobClockingModel.TechinicianObj.Name = ''
	                $scope.jobClockingModel.jobClockingDefaultList = successResult;
	                $scope.jobClockingModel.selectedClockingStaff = clockingStaffRec;
	                $scope.jobClockingModel.isTechnicianMode = true;
	                for(var i=0; i<$scope.jobClockingModel.jobClockingDefaultList.length;i++){
	                	if($scope.jobClockingModel.jobClockingDefaultList[i].IsServiceJobClocked == true){
	                		$scope.jobClockingModel.clockedDay = true;
	                		break;
	                	}
	                }
	                
		            $scope.jobClockingModel.getPayrollEntryForTechnician();
	            }, function(errorMessage) {
	                Notification.error(errorMessage);
	            });
         }
            if($scope.jobClockingModel.viewChange == 'other tasks'){
            	JobClockingPageService.getTaskListWithTechnicianId(clockingStaffRec.Id).then(function(successResult) {
                    $scope.jobClockingModel.isTechnicianMode = true;
	                $scope.jobClockingModel.isEdit = -1;
	                $scope.jobClockingModel.TechinicianObj = {};
	                $scope.jobClockingModel.TechinicianObj.Name = ''
                   $scope.jobClockingModel.defaultTaskList = successResult;
	                $scope.jobClockingModel.selectedClockingStaff = clockingStaffRec;
	                for(var i=0; i<$scope.jobClockingModel.defaultTaskList.length;i++){
	                	if($scope.jobClockingModel.defaultTaskList[i].IsClockedOn == true){
	                		$scope.jobClockingModel.clockedDay = true;
	                		break;
	                	}
	                }
	                $scope.jobClockingModel.getPayrollEntryForTechnician();
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
            	
            }
            
            
            angular.element('[role ="tooltip"]').hide()
            setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
            angular.element('.bp-job-clocking-wrapper .pageContent').animate({
                scrollTop: 0
            }, 10);
            
 			 }, 500);
        }
        $scope.jobClockingModel.getPayrollEntryForTechnician = function() {
        	if($scope.jobClockingModel.selectedClockingStaff.Id != null 
        			&& $scope.jobClockingModel.selectedClockingStaff.Id != '' 
        			&& $scope.jobClockingModel.selectedClockingStaff.Id != undefined)	{
        		JobClockingPageService.getPayrollEntryForTechnician($scope.jobClockingModel.selectedClockingStaff.Id).then(function(successResult) {
                	if(successResult.IsPayrollOn != undefined) {
                		$scope.jobClockingModel.IsPayrollOn = successResult.IsPayrollOn;
                		$scope.jobClockingModel.PayrollOnId = successResult.PayrollId;
                	}
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
        	}
        }
        
        $scope.jobClockingModel.openEditModeclocking = function(index, soHeaderId) {
        	 $scope.jobClockingModel.showHistory = true;
            JobClockingPageService.getHoursLoggedBySOHeaderId(soHeaderId).then(function(successResult) {
                $scope.jobClockingModel.isEdit = index;
                var getDetailsElement = angular.element("#jobDetails__"+index);
				  var globalDetails = angular.element(".jobDetails");
				  collapseElement(globalDetails);
                $scope.jobClockingModel.loginUserList = successResult;
                var getDetailsUlHeight;
                var getDetailsliHeight = getDetailsElement.find('.userActivityList li[0]').outerHeight();
                setTimeout(function(){ 
                	getDetailsUlHeight = getDetailsElement.find('.userActivityList').outerHeight() + 20;
            		var getDetailsHeight = 62*$scope.jobClockingModel.loginUserList.length;
    				if($scope.jobClockingModel.isEdit != -1){
    					expandElement(getDetailsElement, getDetailsUlHeight, '0.3s');
    				}else{
    					expandElement(getDetailsElement, getDetailsUlHeight);
    				}
   			    }, 500);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.jobClockingModel.openEditModeclockingStaff = function(index, soHeaderId) {
            $scope.jobClockingModel.isEdit = index;
        }
        $scope.jobClockingModel.showNotesSection = function(index,soHeaderId){
        	 $scope.jobClockingModel.notesModel = ''
        	 $scope.jobClockingModel.showHistory = false; 
        	 $scope.jobClockingModel.isEdit = index;
        	 var getDetailsElement = angular.element("#jobDetailsTech__"+index);
        	 var otherClaass = angular.element(".jobDetails");
			  var globalDetails =  getDetailsElement.find('.jobClckingNoteWrapper');
			  collapseElement(otherClaass);
             var getDetailsHeight = angular.element(globalDetails).outerHeight();
             setTimeout(function(){ 
 				if($scope.jobClockingModel.isEdit != -1){
 					expandElement(getDetailsElement, getDetailsHeight, '0.3s');
 				}else{
 					expandElement(getDetailsElement, getDetailsHeight);
 				}
			    }, 500);
        }
        $scope.jobClockingModel.to_trusted = function(html_code) {
            return $sce.trustAsHtml(html_code);
        }
        $scope.jobClockingModel.closeEditModeclocking = function(index, fromServiceJob) {
            $scope.jobClockingModel.isEdit = -1;
            $scope.jobClockingModel.showHistory = false;
            var getDetailsElement = null
            if( $scope.jobClockingModel.selectedClockingStaff.Id != undefined && $scope.jobClockingModel.selectedClockingStaff.Id != null &&  $scope.jobClockingModel.selectedClockingStaff.Id != '' && fromServiceJob == undefined){
            	getDetailsElement = angular.element("#jobDetailsTech__"+index);
            }else if($scope.jobClockingModel.selectedClockingStaff.Id != undefined && $scope.jobClockingModel.selectedClockingStaff.Id != null &&  $scope.jobClockingModel.selectedClockingStaff.Id != '' && fromServiceJob != undefined){
            	getDetailsElement = angular.element("#jobDetails__"+index);
            }else{
            	getDetailsElement = angular.element("#jobDetails__"+index);
            }
            collapseElement(getDetailsElement);
        }
        $scope.jobClockingModel.removeTechnician = function(soHeaderId, event, IsClocked, techId) {
            if (!IsClocked && $rootScope.GroupOnlyPermissions['Manage job clocking']['enabled']) {
                $scope.jobClockingModel.removeTechSoHeaderId = soHeaderId;
                $scope.jobClockingModel.removeTechTechId = techId;
                $scope.jobClockingModel.addTechBackdrop();
                angular.element(".clockingStaffPopup").css("visibility", 'hidden');
                angular.element(".clockingStaffPopup").css("opacity", 0);
                angular.element(".clockingStaffremoveTech").css("visibility", 'visible');
                angular.element(".clockingStaffremoveTech").css("opacity", 1);
                angular.element(".clockingStaffremoveTech").css("left", event.clientX + 'px');
                angular.element(".clockingStaffremoveTech").css("top", (event.clientY + 20) + 'px');
            }
        }
        $scope.jobClockingModel.removeTechnicianfromassign = function() {
            var currentTechId = null;
            if($scope.jobClockingModel.isTechnicianMode){
            	currentTechId = $scope.jobClockingModel.selectedClockingStaff.Id;;
            }
              var soHeaderIndex = -1;
        	for(var i=0;i<$scope.jobClockingModel.jobClockingDefaultList.length;i++) {
            	if($scope.jobClockingModel.jobClockingDefaultList[i].Id == $scope.jobClockingModel.removeTechSoHeaderId) {
            		soHeaderIndex = i;
            		break;
            	}
            }
            JobClockingPageService.removeTechnician($scope.jobClockingModel.removeTechSoHeaderId, $scope.jobClockingModel.removeTechTechId,currentTechId).then(function(successResult) {
                $scope.jobClockingModel.jobClockingDefaultList[soHeaderIndex] = successResult;
                soHeaderIndex = -1;
                angular.element('[role ="tooltip"]').hide()
                setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
    			 }, 500);
                $scope.jobClockingModel.hidetechpopup()
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.jobClockingModel.assignTechnician = function(techId) {
        	var viewTechId = null;
            var soHeaderIndex = -1;
        	for(var i=0;i<$scope.jobClockingModel.jobClockingDefaultList.length;i++) {
            	if($scope.jobClockingModel.jobClockingDefaultList[i].Id == $scope.jobClockingModel.soHeaderId) {
            		soHeaderIndex = i;
            		break;
            	}
            }
            JobClockingPageService.assignTechnician($scope.jobClockingModel.soHeaderId, techId,viewTechId).then(function(successResult) {
                $scope.jobClockingModel.jobClockingDefaultList[soHeaderIndex] = successResult;
                soHeaderIndex = -1;
                angular.element(".clockingStaffPopup").css("visibility", 'hidden');
                angular.element(".clockingStaffPopup").css("opacity", 0);
                $scope.jobClockingModel.hidetechpopup();
                angular.element('[role ="tooltip"]').hide()
                setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
    			 }, 500);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.jobClockingModel.changeView = function(viewName){
        	$scope.jobClockingModel.viewChange = viewName;
        	if($scope.jobClockingModel.viewChange == 'service jobs'){
        		 var currentTechId = null
	                 if($scope.jobClockingModel.isTechnicianMode){
	                 	currentTechId = $scope.jobClockingModel.selectedClockingStaff.Id;
	                 }
        		 JobClockingPageService.getServiceJobs(currentTechId).then(function(successResult) {
                     $scope.jobClockingModel.jobClockingDefaultList = successResult;
                     angular.element('[role ="tooltip"]').hide()
                     setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
           			 }, 500);
                 }, function(errorMessage) {
                     Notification.error(errorMessage);
                 });

        	}else if($scope.jobClockingModel.viewChange == 'other tasks'){
        		$scope.jobClockingModel.createnewTaskDiv = false;
        		$scope.jobClockingModel.newOtherTaskList = {};
        		$scope.jobClockingModel.editOtherTaskList = -1;
        		var techId = null;
        		if($scope.jobClockingModel.selectedClockingStaff.Id != undefined && $scope.jobClockingModel.selectedClockingStaff.Id != null && $scope.jobClockingModel.selectedClockingStaff.Id != ''){
        			techId = $scope.jobClockingModel.selectedClockingStaff.Id;
        		}
        		JobClockingPageService.getTaskListWithTechnicianId(techId).then(function(successResult) {
                   $scope.jobClockingModel.defaultTaskList = successResult;
                   angular.element('[role ="tooltip"]').hide()
                    setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
          			 }, 500);
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
        	}else if($scope.jobClockingModel.viewChange == 'manage tasks'){
        		$scope.jobClockingModel.selectedTaskIdForFilter = '';
        		$scope.jobClockingModel.fromDate = moment().format($Global.SchedulingDateFormat);
        		$scope.jobClockingModel.toDate = moment().format($Global.SchedulingDateFormat);
        		$scope.jobClockingModel.toDateOptions.minDate = $scope.jobClockingModel.fromDate;
        		$scope.jobClockingModel.taskFilterValue = '';
        		$scope.jobClockingModel.selectedTaskForFilter = {};
        		$scope.jobClockingModel.createTaskEntryDiv = false;
        		createManagejobClockingEntryOrFilterJson();
        		$scope.jobClockingModel.editManageTask = -1;
        		JobClockingPageService.getOtherTasks(angular.toJson($scope.jobClockingModel.filterJson)).then(function(successResult) {
                    $scope.jobClockingModel.manageTaskList = successResult;
                    $scope.jobClockingModel.manageTaskListCopy = angular.copy($scope.jobClockingModel.manageTaskList);
                    angular.element('[role ="tooltip"]').hide()
                    setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
          			 }, 500);
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
        	}
            $scope.jobClockingModel.getPayrollEntryForTechnician();
        }
        function createManagejobClockingEntryOrFilterJson()	{
        	$scope.jobClockingModel.filterJson = {
        			'FromDate': $scope.jobClockingModel.fromDate,
    				'ToDate': $scope.jobClockingModel.toDate,
    				'TaskId': $scope.jobClockingModel.selectedTaskIdForFilter
		    }
        	if($scope.jobClockingModel.fromDate == undefined || $scope.jobClockingModel.fromDate == '' || $scope.jobClockingModel.fromDate == null)	{
        		$scope.jobClockingModel.filterJson.FromDate = null;
        	}
        	if($scope.jobClockingModel.toDate == undefined || $scope.jobClockingModel.toDate == '' || $scope.jobClockingModel.toDate == null)	{
        		$scope.jobClockingModel.filterJson.ToDate = null;
        	}
        	if($scope.jobClockingModel.selectedTaskIdForFilter == undefined || $scope.jobClockingModel.selectedTaskIdForFilter == '' || $scope.jobClockingModel.selectedTaskIdForFilter == null)	{
        		$scope.jobClockingModel.filterJson.TaskId = '';
        	}
        }
        $scope.jobClockingModel.setToDateFormate = function(){
        	$scope.jobClockingModel.toDateOptions.minDate = $scope.jobClockingModel.fromDate;
        	if(moment($scope.jobClockingModel.toDate).diff(moment($scope.jobClockingModel.fromDate), 'days') < 0) {
        		$scope.jobClockingModel.toDate = $scope.jobClockingModel.fromDate;
        	}
        }
        $scope.jobClockingModel.loadJobClockingEntriesUsingFilter = function(){
				createManagejobClockingEntryOrFilterJson();
				JobClockingPageService.getOtherTasks(angular.toJson($scope.jobClockingModel.filterJson)).then(function(successResult) {
					$scope.jobClockingModel.editManageTask = -1;
					$scope.jobClockingModel.manageTaskList = successResult;
					$scope.jobClockingModel.manageTaskListCopy = angular.copy($scope.jobClockingModel.manageTaskList);
					angular.element('[role ="tooltip"]').hide()
					 setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
					 }, 500);
				 }, function(errorMessage) {
                 Notification.error(errorMessage);
             });
        }
        $scope.jobClockingModel.editManageTaskList = function(index){
        	$scope.jobClockingModel.editManageTask = index;
        	setTimeout(function(){
        		angular.element("#InTime_"+index).focus();
        	},100);
        	$scope.jobClockingModel.createTaskEntryDiv = false;
        }
        $scope.jobClockingModel.saveManajeTask = function(index,taskRec,event, timeVariable){
        	if(timeVariable != null) {
        		$scope.jobClockingModel.validateTime(index, timeVariable);
        	}
        	if(index != -1) {
        		focusedElement =  event.relatedTarget;
	           	  if(focusedElement != undefined && focusedElement != '' && focusedElement != null)   {
	                     if(focusedElement.id == ('InTime_'+index) || focusedElement.id == ('EndTime_'+index))    {
	                         $scope.jobClockingModel.isBlur = false;
	                     }
	                 }
	           	  if(event.type == "blur" && !$scope.jobClockingModel.isBlur){
	                     event.preventDefault();
	                     $scope.jobClockingModel.isBlur = true;
	                     return;
	                  }
	           	  if(event.type == "blur" && $scope.jobClockingModel.isBlur)  {
	           		  JobClockingPageService.addEditTaskHoursLogged(angular.toJson(taskRec)).then(function(successResult) {
	                         if(successResult[0].HasError != undefined && successResult[0].HasError != '' 
	                             && successResult[0].HasError != null && successResult[0].HasError) {
	                        	 Notification.error(successResult[0].ErrorMsg);
	                         } else {
	                        	 $scope.jobClockingModel.editManageTask = -1;
		                         $scope.jobClockingModel.manageTaskList[index] = successResult[0];
	                         }
	                        
	                     }, function(errorMessage) {
	                         Notification.error(errorMessage);
	                     });
	           	  }
        	} else {
        		JobClockingPageService.addEditTaskHoursLogged(angular.toJson(taskRec)).then(function(successResult) {
                    if(successResult[0].HasError != undefined && successResult[0].HasError != '' 
                        && successResult[0].HasError != null && successResult[0].HasError) {
                   	 	Notification.error(successResult[0].ErrorMsg);
                    } else {
                    	$scope.jobClockingModel.createTaskEntryDiv = false;
                        
                        $scope.jobClockingModel.manageTaskList.push(successResult[0]);
                        $scope.jobClockingModel.setBGColorForManageTask = $scope.jobClockingModel.manageTaskList.length - 1;
                        setTimeout(function() {
                        	$scope.jobClockingModel.setBGColorForManageTask = -1;
                        	 if (!$scope.$$phase) {
                                 $scope.$digest();
                             }
                        }, 1000);
                    }
                    
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
        	}
        	
        }
        $scope.jobClockingModel.createNewTask = function(){
        	$scope.jobClockingModel.createnewTaskDiv = true;
        	$scope.jobClockingModel.newOtherTaskList = {};
        	
        	setTimeout(function() {
        		angular.element("#newTaskInput").focus();
            }, 1000);
        	
        	
        }
        $scope.jobClockingModel.cancelNewTask = function(){
        	$scope.jobClockingModel.createnewTaskDiv = false;
        	$scope.jobClockingModel.newOtherTaskList = {};
        }
        $scope.jobClockingModel.editTaskList = function(index){
        	$scope.jobClockingModel.cancelNewTask();
        	$scope.jobClockingModel.editOtherTaskList = index;
        	 setTimeout(function(){ 
        		 angular.element("#" + $scope.jobClockingModel.defaultTaskList[index].Id).find("input").focus();
  			 }, 500);
        	
        	$scope.jobClockingModel.defaultTaskListCopy = angular.copy($scope.jobClockingModel.defaultTaskList);
        }
        
        $scope.jobClockingModel.enterTaskSave = function(taskId,taskName,event){
        	if(event.keyCode == 13){
        		$scope.jobClockingModel.addEditTask(taskId,taskName);
        	}
        }
        
        $scope.jobClockingModel.addEditTask = function(taskId,taskName){
        	for(var i=0; i < $scope.jobClockingModel.defaultTaskList.length;i++){
        		if(taskId != null && (taskName == null || taskName == '' || taskName == undefined)) {
            		if($scope.jobClockingModel.defaultTaskList[i].Id == taskId) {
            			$scope.jobClockingModel.defaultTaskList[i].Name = $scope.jobClockingModel.defaultTaskListCopy[i].Name;
            			setTimeout(function(){ 
                   		 angular.element("#" + taskId).find("input").focus();
             			 }, 500);
            			return;
            		}
            	}
                if(taskId == null  && ($scope.jobClockingModel.defaultTaskList[i].Name).toLowerCase() == taskName.toLowerCase()){
        			$scope.jobClockingModel.newOtherTaskList.Name = '';
        			Notification.error($translate.instant('Duplicate_task_name'));
        			setTimeout(function(){ 
                  		 angular.element("#newTaskInput").focus();
            		}, 500);
        			return;
        		}else if(taskId != null && taskName != null && (($scope.jobClockingModel.defaultTaskList[i].Name).toLowerCase() == taskName.toLowerCase()) && $scope.jobClockingModel.defaultTaskList[i].Id != taskId ){
        			$scope.jobClockingModel.defaultTaskList[$scope.jobClockingModel.editOtherTaskList].Name = $scope.jobClockingModel.defaultTaskListCopy[$scope.jobClockingModel.editOtherTaskList].Name;
        			Notification.error($translate.instant('Duplicate_task_name'));
        			setTimeout(function(){ 
                 		 angular.element("#" + taskId).find("input").focus();
           		}, 500);
        			return;
        		}
        	}
        	
        	var taskIndex = -1;
        	if(taskId == null) {
    			taskIndex = $scope.jobClockingModel.defaultTaskList.length;
    		} else {
    			for(var i=0; i < $scope.jobClockingModel.defaultTaskList.length;i++){
            		if($scope.jobClockingModel.defaultTaskList[i].Id == taskId) {
            			taskIndex = i;
            			break;
            		}
            	}
    		}
        	
        	JobClockingPageService.addEditTask(taskId,taskName).then(function(successResult) {
                $scope.jobClockingModel.defaultTaskList[taskIndex] = successResult;
                taskIndex = -1;
               $scope.jobClockingModel.createnewTaskDiv = false;
               if(taskId != null){
           		$scope.jobClockingModel.editOtherTaskList = -1
               }
               Notification.success($translate.instant('Generic_Saved'));
               angular.element('[role ="tooltip"]').hide()
                setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
      			 }, 500);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
      }
        
        
        $scope.jobClockingModel.openDeleteConfirmationPopup = function(gridName, lineItemId)    {
        	var deletableElementId = '';
        	if(gridName === 'defaultTaskGrid')	{
        		$scope.jobClockingModel.deletableTaskId = lineItemId;
        		$scope.jobClockingModel.deletableElementId = lineItemId;
        		$scope.jobClockingModel.deletedItemName = 'this task';
        		$scope.jobClockingModel.deletedItemGridName = gridName;
        		deletableElementId = lineItemId;
        	}else if(gridName === 'manageTaskGrid')	{
        		$scope.jobClockingModel.deletableManageTaskId = lineItemId;
        		$scope.jobClockingModel.deletableElementId = lineItemId;
        		$scope.jobClockingModel.deletedItemName = 'this entry';
        		$scope.jobClockingModel.deletedItemGridName = gridName;
        		deletableElementId = lineItemId;
        	}
        	
            addDeletePopupBackdrop();
	        toppopupposition = (angular.element("#" + deletableElementId + " .LIDeleteBtn ").offset().top) + 20;
	        leftpopupposition = (angular.element("#" + deletableElementId + " .LIDeleteBtn ").offset().left) + 5;
	        angular.element(".deleteConfiramtionPopup").css("left", leftpopupposition + 'px');
	        angular.element(".deleteConfiramtionPopup").css("top", toppopupposition + 'px');
	        setTimeout(function(){
	            angular.element(".deleteConfiramtionPopup").css("visibility", 'visible');
	            angular.element(".deleteConfiramtionPopup").css("opacity", 1);
	        },100);
        }
        
        
        function addDeletePopupBackdrop() {
            setTimeout(function() {
                var template = '<div class = "bp-modal-backdrop" ng-click = "jobClockingModel.hideDeleteConfirmationPopup()"></div>';
                template = $compile(angular.element(template))($scope);
                angular.element("#bp-job-clocking").prepend(template);
            }, 500);
        }
        
        $scope.jobClockingModel.hideDeleteConfirmationPopup = function() {
            angular.element(".deleteConfiramtionPopup").css("visibility", 'hidden');
            angular.element(".deleteConfiramtionPopup").css("opacity", 0);
            angular.element("#bp-job-clocking").find('.bp-modal-backdrop').remove();
        }
        
		$scope.jobClockingModel.deleteItem = function(){
			if($scope.jobClockingModel.deletedItemGridName === 'defaultTaskGrid')	{
				$scope.jobClockingModel.deleteTask();
			}else if($scope.jobClockingModel.deletedItemGridName === 'manageTaskGrid')	{
				$scope.jobClockingModel.deleteManageTaskList();
			}
		}
		
      $scope.jobClockingModel.deleteTask = function(){
    	 JobClockingPageService.deleteTask($scope.jobClockingModel.deletableTaskId).then(function(successResult) {
             $scope.jobClockingModel.hideDeleteConfirmationPopup();
             setTimeout(function()    {
            	var deletedElement =  angular.element('#' + $scope.jobClockingModel.deletableElementId);
 	            if(deletedElement != undefined && deletedElement != null && deletedElement != ''){
 	                deletedElement.addClass('bp-collapse-deleted-div-transition');
 	            }
             }, 100);
             
             setTimeout(function()    {
            	 $scope.jobClockingModel.defaultTaskList = successResult;
            	 $scope.jobClockingModel.editOtherTaskList = -1;
            	 Notification.success($translate.instant('Task_deleted'));
                 angular.element('[role ="tooltip"]').hide();
                 setTimeout(function(){ 
                      angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
                  }, 500);
                  if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                       $scope.$apply(); //TODO
                  } 
                  
                  $scope.jobClockingModel.deletableTaskId = '';
	     		  $scope.jobClockingModel.deletableElementId = '';
	     		  $scope.jobClockingModel.deletedItemName = '';
	     		  $scope.jobClockingModel.deletedItemGridName = '';
              }, 600);
         }, function(errorMessage) {
             Notification.error(errorMessage);
         });
     }
     
     $scope.jobClockingModel.createManageTaskEntry = function(){
     	$scope.jobClockingModel.createTaskEntryDiv = true;
     	$scope.jobClockingModel.newTaskEntry = {};
        $scope.jobClockingModel.newTaskEntryCopy = {};
     	$scope.jobClockingModel.newTaskEntryTechName = '';
     	$scope.jobClockingModel.newTaskEntryTaskName = '';
     }
     
     $scope.jobClockingModel.cancelManageTaskEntry = function(){
     	$scope.jobClockingModel.createTaskEntryDiv = false;
     	$scope.jobClockingModel.newOtherTaskList = {};
     }
     
     $scope.jobClockingModel.validateTime = function(index, timeVariable) {
    	 if(index == -1) {
    		 if(moment($scope.jobClockingModel.newTaskEntry[timeVariable], 'h:mm A').format('h:mm A') == "Invalid date") {
    			 $scope.jobClockingModel.newTaskEntry[timeVariable] = $scope.jobClockingModel.newTaskEntryCopy[timeVariable];
             } else {
         		 if(timeVariable == 'StartTime') {
         			 if($scope.jobClockingModel.newTaskEntry['EndTime'] != '' &&
         					$scope.jobClockingModel.newTaskEntry['EndTime'] != null &&
         					$scope.jobClockingModel.newTaskEntry['EndTime'] != undefined &&
         					moment($scope.jobClockingModel.newTaskEntry['StartTime'], 'h:mm A').diff(moment($scope.jobClockingModel.newTaskEntry['EndTime'], 'h:mm A'), 'minutes') > 0) {
         				$scope.jobClockingModel.newTaskEntry[timeVariable] = $scope.jobClockingModel.newTaskEntryCopy[timeVariable];
         			 } else {
         				$scope.jobClockingModel.newTaskEntry[timeVariable] = moment($scope.jobClockingModel.newTaskEntry[timeVariable], 'h:mm A').format('h:mm A');
         				$scope.jobClockingModel.newTaskEntryCopy = angular.copy($scope.jobClockingModel.newTaskEntry);
         			 }
         		 } else if(timeVariable == 'EndTime') {
         			if($scope.jobClockingModel.newTaskEntry['StartTime'] != '' &&
         					$scope.jobClockingModel.newTaskEntry['StartTime'] != null &&
         					$scope.jobClockingModel.newTaskEntry['StartTime'] != undefined &&
         					moment($scope.jobClockingModel.newTaskEntry['StartTime'], 'h:mm A').diff(moment($scope.jobClockingModel.newTaskEntry['EndTime'], 'h:mm A'), 'minutes') > 0) {
         				$scope.jobClockingModel.newTaskEntry[timeVariable] = $scope.jobClockingModel.newTaskEntryCopy[timeVariable];
	     			} else {
	     				$scope.jobClockingModel.newTaskEntry[timeVariable] = moment($scope.jobClockingModel.newTaskEntry[timeVariable], 'h:mm A').format('h:mm A');
	     				$scope.jobClockingModel.newTaskEntryCopy = angular.copy($scope.jobClockingModel.newTaskEntry);
	     			}
         		 } else {
         			$scope.jobClockingModel.newTaskEntry[timeVariable] = moment($scope.jobClockingModel.newTaskEntry[timeVariable], 'h:mm A').format('h:mm A');
         			$scope.jobClockingModel.newTaskEntryCopy = angular.copy($scope.jobClockingModel.newTaskEntry);
         		 }
             }
    	 } else {
    		 if(moment($scope.jobClockingModel.manageTaskList[index][timeVariable], 'h:mm A').format('h:mm A') == "Invalid date") {
                 $scope.jobClockingModel.manageTaskList[index][timeVariable] = $scope.jobClockingModel.manageTaskListCopy[index][timeVariable];
             } else {
            	 if(timeVariable == 'StartTime') {
         			 if($scope.jobClockingModel.manageTaskList[index]['EndTime'] != '' &&
         					$scope.jobClockingModel.manageTaskList[index]['EndTime'] != null &&
         					$scope.jobClockingModel.manageTaskList[index]['EndTime'] != undefined &&
         					moment($scope.jobClockingModel.manageTaskList[index]['StartTime'], 'h:mm A').diff(moment($scope.jobClockingModel.manageTaskList[index]['EndTime'], 'h:mm A'), 'minutes') > 0) {
         				$scope.jobClockingModel.manageTaskList[index][timeVariable] = $scope.jobClockingModel.manageTaskListCopy[index][timeVariable];
         			 } else {
         				$scope.jobClockingModel.manageTaskList[index][timeVariable] = moment($scope.jobClockingModel.manageTaskList[index][timeVariable], 'h:mm A').format('h:mm A');
         			 }
         		 } else if(timeVariable == 'EndTime') {
         			if($scope.jobClockingModel.manageTaskList[index]['StartTime'] != '' &&
         					$scope.jobClockingModel.manageTaskList[index]['StartTime'] != null &&
         					$scope.jobClockingModel.manageTaskList[index]['StartTime'] != undefined &&
         					moment($scope.jobClockingModel.manageTaskList[index]['StartTime'], 'h:mm A').diff(moment($scope.jobClockingModel.manageTaskList[index]['EndTime'], 'h:mm A'), 'minutes') > 0) {
         				$scope.jobClockingModel.manageTaskList[index][timeVariable] = $scope.jobClockingModel.manageTaskListCopy[index][timeVariable];
	     			} else {
	     				$scope.jobClockingModel.manageTaskList[index][timeVariable] = moment($scope.jobClockingModel.manageTaskList[index][timeVariable], 'h:mm A').format('h:mm A');
	     			}
         		 } else {
         			$scope.jobClockingModel.manageTaskList[index][timeVariable] = moment($scope.jobClockingModel.manageTaskList[index][timeVariable], 'h:mm A').format('h:mm A');
         		 }
             }
    	 }
     }
     
     $scope.jobClockingModel.disableTaskEntrySaveButton = function() {
    	 if($scope.jobClockingModel.newTaskEntry.TechId == '' || $scope.jobClockingModel.newTaskEntry.TechId == null || $scope.jobClockingModel.newTaskEntry.TechId == undefined ||
    	 $scope.jobClockingModel.newTaskEntry.StartDate == '' || $scope.jobClockingModel.newTaskEntry.StartDate == null || $scope.jobClockingModel.newTaskEntry.StartDate == undefined ||
    	 $scope.jobClockingModel.newTaskEntry.StartTime == '' || $scope.jobClockingModel.newTaskEntry.StartTime == null || $scope.jobClockingModel.newTaskEntry.StartTime == undefined ||
    	 $scope.jobClockingModel.newTaskEntry.EndTime == '' || $scope.jobClockingModel.newTaskEntry.EndTime == null || $scope.jobClockingModel.newTaskEntry.EndTime == undefined ||
    	 $scope.jobClockingModel.newTaskEntry.TaskId == '' || $scope.jobClockingModel.newTaskEntry.TaskId == null || $scope.jobClockingModel.newTaskEntry.TaskId == undefined) {
    		 return true;
    	 }
    	 return false;
     }
     
     $scope.jobClockingModel.getTechnicianListForAddTaskEntry = function() {
         $scope.jobClockingModel.isTechFieldFocused = true;
         JobClockingPageService.getTechnicianList(null).then(function(successResult) {
             $scope.jobClockingModel.techListForAddTaskEntry = successResult;
             angular.element('#autocompleteScrollTechDiv').animate({
                 scrollTop: 0
             }, 10);
             
         }, function(errorMessage) {
             Notification.error(errorMessage);
         });
     }
     
     $scope.jobClockingModel.deleteManageTaskList = function(){
    	createManagejobClockingEntryOrFilterJson();
  	    JobClockingPageService.deleteTaskHoursLogged($scope.jobClockingModel.deletableManageTaskId, angular.toJson($scope.jobClockingModel.filterJson)).then(function(successResult) {
             $scope.jobClockingModel.hideDeleteConfirmationPopup();
             setTimeout(function()    {
              	var deletedElement =  angular.element('#' + $scope.jobClockingModel.deletableElementId);
                   if(deletedElement != undefined && deletedElement != null && deletedElement != ''){
                       deletedElement.addClass('bp-collapse-deleted-div-transition');
                   }
               }, 100);
               
             setTimeout(function()    {
            	 $scope.jobClockingModel.manageTaskList = successResult;
                  angular.element('[role ="tooltip"]').hide();
                  setTimeout(function(){ 
                       angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
                   }, 500);
                   if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply(); //TODO
                   } 
                   
                    $scope.jobClockingModel.deletableManageTaskId = '';
	           		$scope.jobClockingModel.deletableElementId = '';
	           		$scope.jobClockingModel.deletedItemName = '';
	           		$scope.jobClockingModel.deletedItemGridName = '';
               }, 600);
         }, function(errorMessage) {
             Notification.error(errorMessage);
         });
     }
     
     $scope.jobClockingModel.setTechBlurForNewTaskEntry = function() {
         $scope.jobClockingModel.isTechFieldFocused = false;
         $scope.jobClockingModel.currentTechIndexForAddNewTsk = -1;
     }
     
     $scope.jobClockingModel.changeTechForNewTaskEntry = function(event) {
         var keyCode = event.which ? event.which : event.keyCode;
         if($scope.jobClockingModel.selectedTechForAddTaskEntry != null && $scope.jobClockingModel.selectedTechForAddTaskEntry != '' && 
        		 $scope.jobClockingModel.selectedTechForAddTaskEntry != undefined && $scope.jobClockingModel.newTaskEntryTechName != $scope.jobClockingModel.selectedTechForAddTaskEntry.TechinicianName) {
        	 $scope.jobClockingModel.selectedTechForAddTaskEntry = null;
        	 $scope.jobClockingModel.newTaskEntry.TechId = '';
         }
         if (keyCode === 40) {
             if (($scope.jobClockingModel.techListForAddTaskEntry.length - 1) > $scope.jobClockingModel.currentTechIndexForAddNewTsk) {
                 $scope.jobClockingModel.currentTechIndexForAddNewTsk++;
                 angular.element('#autocompleteScrollTechDiv')[0].scrollTop = angular.element('#tech_' + $scope.jobClockingModel.currentTechIndexForAddNewTsk)[0].offsetTop - 100;
             }
         } else if (keyCode === 38) {
             if ($scope.jobClockingModel.currentTechIndexForAddNewTsk > 0) {
                 $scope.jobClockingModel.currentTechIndexForAddNewTsk--;
                 angular.element('#autocompleteScrollTechDiv')[0].scrollTop = angular.element('#tech_' + $scope.jobClockingModel.currentTechIndexForAddNewTsk)[0].offsetTop - 100;
             }
         } else if (keyCode === 13) {
             $scope.jobClockingModel.selectTechForAddTaskEntry($scope.jobClockingModel.techListForAddTaskEntry[$scope.jobClockingModel.currentTechIndexForAddNewTsk]);
             $scope.jobClockingModel.currentTechIndexForAddNewTsk = -1;
             $scope.jobClockingModel.isTechFieldFocused = false;

         }
     }
     
     $scope.jobClockingModel.selectTechForAddTaskEntry = function(techRec) {
    	 setTimeout(function() {
    		 $scope.jobClockingModel.newTaskEntryTechName = techRec.TechinicianName;
	       if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
	             $scope.$apply(); //TODO
                } 
            }, 700);
    	 
    	 $scope.jobClockingModel.newTaskEntry.TechId = techRec.Id;
    	 $scope.jobClockingModel.selectedTechForAddTaskEntry = techRec;
     }
     
     
     $scope.jobClockingModel.getAllTasksForTaskFilter = function() {
    	 $scope.jobClockingModel.isTaskFilterFocused = true;
    	 $scope.jobClockingModel.createTaskEntryDiv = false;
         $scope.jobClockingModel.getAllTasks('Task Filter');
         angular.element('#autocompleteScrollTaskFilterDiv').animate({
             scrollTop: 0
         }, 10);
     }
     
     $scope.jobClockingModel.getAllTasksForAddTaskEntry = function() {
    	 $scope.jobClockingModel.isTaskFieldFocused = true;
         $scope.jobClockingModel.getAllTasks('Add entry');
         angular.element('#autocompleteScrollTaskDiv').animate({
             scrollTop: 0
         }, 10);
     }
     
     $scope.jobClockingModel.getAllTasks = function(gridName) {
         JobClockingPageService.getTaskListWithTechnicianId(null).then(function(successResult) {
             if(gridName == 'Task Filter') {
            	 $scope.jobClockingModel.taskList = successResult;
             } else if(gridName == 'Add entry') {
            	 $scope.jobClockingModel.taskListForAddTaskEntry = successResult;
             }
             return successResult;
         }, function(errorMessage) {
             Notification.error(errorMessage);
         });
     }
     
     $scope.jobClockingModel.setBlurOnInputForTaskFilter = function() {
         $scope.jobClockingModel.isTaskFilterFocused = false;
         $scope.jobClockingModel.currentTaskIndexForFilter = -1;
     }
     $scope.jobClockingModel.setTaskBlurForNewTaskEntry = function() {
         $scope.jobClockingModel.isTaskFieldFocused = false;
     }
     $scope.jobClockingModel.changeTaskForFilter= function(event) {
    	 var keyCode = event.which ? event.which : event.keyCode;
         if($scope.jobClockingModel.taskFilterValue == '' || $scope.jobClockingModel.taskFilterValue == undefined || $scope.jobClockingModel.taskFilterValue == null){
        	 $scope.jobClockingModel.selectedTaskForFilter = {};
        	 $scope.jobClockingModel.selectedTaskIdForFilter = '';
        	 createManagejobClockingEntryOrFilterJson();
        	 $scope.jobClockingModel.getAllTasks('Task Filter');
             JobClockingPageService.getOtherTasks(angular.toJson($scope.jobClockingModel.filterJson)).then(function(successResult) {
                 $scope.jobClockingModel.editManageTask = -1;
                 $scope.jobClockingModel.manageTaskList = successResult;
                 $scope.jobClockingModel.manageTaskListCopy = angular.copy($scope.jobClockingModel.manageTaskList);
             }, function(errorMessage) {
                 Notification.error(errorMessage);
             });
         }
         if (keyCode === 40) {
             if (($scope.jobClockingModel.taskList.length - 1) > $scope.jobClockingModel.currentTaskIndexForFilter) {
                 $scope.jobClockingModel.currentTaskIndexForFilter++;
                 angular.element('#autocompleteScrollTaskFilterDiv')[0].scrollTop = angular.element('#taskFilter_' + $scope.jobClockingModel.currentTaskIndexForFilter)[0].offsetTop - 100;
             }
         } else if (keyCode === 38) {
             if ($scope.jobClockingModel.currentTaskIndexForFilter > 0) {
                 $scope.jobClockingModel.currentTaskIndexForFilter--;
                 angular.element('#autocompleteScrollTaskFilterDiv')[0].scrollTop = angular.element('#taskFilter_' + $scope.jobClockingModel.currentTaskIndexForFilter)[0].offsetTop - 100;
             }
         } else if (keyCode === 13) {
             $scope.jobClockingModel.selectTaskForFilter($scope.jobClockingModel.taskList[$scope.jobClockingModel.currentTaskIndexForFilter]);
             $scope.jobClockingModel.currentTaskIndexForFilter = -1;
             $scope.jobClockingModel.isTaskFilterFocused = false;
         }
     }
     $scope.jobClockingModel.selectTaskForFilter = function(taskRec) {
    	 setTimeout(function() {
    		 $scope.jobClockingModel.taskFilterValue = taskRec.Name;
	       if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
	             $scope.$apply(); //TODO
                } 
            }, 700);
    	 $scope.jobClockingModel.selectedTaskIdForFilter = taskRec.Id;
    	 createManagejobClockingEntryOrFilterJson();
         JobClockingPageService.getOtherTasks(angular.toJson($scope.jobClockingModel.filterJson)).then(function(successResult) {
            $scope.jobClockingModel.editManageTask = -1;
            $scope.jobClockingModel.manageTaskList = successResult;
            angular.element('[role ="tooltip"]').hide()
            	setTimeout(function(){ angular.element('[data-toggle="tooltip"]').tooltip({placement : 'top', container: '#bp-job-clocking'});
            }, 500);
            $scope.jobClockingModel.manageTaskListCopy = angular.copy($scope.jobClockingModel.manageTaskList);
            $scope.jobClockingModel.selectedTaskForFilter = taskRec;
        }, function(errorMessage) {
            Notification.error(errorMessage);
        });
     }
     $scope.jobClockingModel.changeTaskForNewTaskEntry = function(event) {
         var keyCode = event.which ? event.which : event.keyCode;
         if($scope.jobClockingModel.selectedTaskForAddTaskEntry != null && $scope.jobClockingModel.selectedTaskForAddTaskEntry != '' &&
        		 $scope.jobClockingModel.selectedTaskForAddTaskEntry != undefined && $scope.jobClockingModel.newTaskEntryTaskName != $scope.jobClockingModel.selectedTaskForAddTaskEntry.Name) {
        	 $scope.jobClockingModel.newTaskEntry.TaskId = '';
        	 $scope.jobClockingModel.selectedTaskForAddTaskEntry = null;
         }
         if (keyCode === 40) {
             if (($scope.jobClockingModel.taskListForAddTaskEntry.length - 1) > $scope.jobClockingModel.currentTaskIndexForAddNewTsk) {
                 $scope.jobClockingModel.currentTaskIndexForAddNewTsk++;
                 angular.element('#autocompleteScrollTaskDiv')[0].scrollTop = angular.element('#task_' + $scope.jobClockingModel.currentTaskIndexForAddNewTsk)[0].offsetTop - 100;
             }
         } else if (keyCode === 38) {
             if ($scope.jobClockingModel.currentTaskIndexForAddNewTsk > 0) {
                 $scope.jobClockingModel.currentTaskIndexForAddNewTsk--;
                 angular.element('#autocompleteScrollTaskDiv')[0].scrollTop = angular.element('#task_' + $scope.jobClockingModel.currentTaskIndexForAddNewTsk)[0].offsetTop - 100;
             }
         } else if (keyCode === 13) {
             $scope.jobClockingModel.selectTaskForAddTaskEntry($scope.jobClockingModel.taskListForAddTaskEntry[$scope.jobClockingModel.currentTaskIndexForAddNewTsk]);
             $scope.jobClockingModel.currentTaskIndexForAddNewTsk = -1;
             $scope.jobClockingModel.isTaskFieldFocused = false;
         }
     }
     $scope.jobClockingModel.selectTaskForAddTaskEntry = function(taskRec) {
    	 setTimeout(function() {
    		 $scope.jobClockingModel.newTaskEntryTaskName = taskRec.Name;
	       if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
	             $scope.$apply(); //TODO
                } 
            }, 700);
    	 $scope.jobClockingModel.isTaskFieldFocused = false;
    	
    	 $scope.jobClockingModel.newTaskEntry.TaskId = taskRec.Id;
    	 $scope.jobClockingModel.selectedTaskForAddTaskEntry = taskRec;
    	
     }
     $scope.jobClockingModel.saveAddNewTaskEntry = function() {
    	 $scope.jobClockingModel.saveManajeTask(-1, $scope.jobClockingModel.newTaskEntry, null, null);
     }
     $scope.jobClockingModel.loadPopupData();
    }]);
});