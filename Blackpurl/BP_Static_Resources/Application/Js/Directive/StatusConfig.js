/**
 * @author Rajat Jain <rajat.jain@metacube.com>
 * @since  22/03/2018
 * Description: Angular directive to change status 
 *
 */

"use strict";
var bpStatusConfigHTML =	'<div ng-class="{\'dialog-opacity\': showDialog, \'in\': showDialog}"  style="display: block" class="modal bp-model-dialog fade-scale serviceJobStatusChangeModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" id="job-status-change">' 
						 	+ '<div class="modal-backdrop fade in" ng-click="closeDialog()"></div>'
						 	+ '<div class="modal-dialog" role="document">'
						 		+ '<div class="modal-content">'
						 			+'<div class = "modal-body P0">'
						 				+'<i class=" doneIcon white_FFF_NewCO closeiconWidth" data-dismiss="modal" ng-include="getTrustedUrl(\'/Icons/close.svg \')" ng-click="closeDialog()"> </i>'
						 				+'<div class="content bp-wrapper-container">'
							 				+'<h2 class = "jobStatusTitle text-center text-uppercase">{{jobStatusTitle}}</h2>'
					                        +'<div class = "statusLogWrapper PB0">'
					                            +'<div class = "col-xs-6 P0">'
					                                +'<div ng-if = "statusList.length" ng-repeat="status in statusList">'
					                                    +'<div class = "statusLog">'
					                                        +'<span class="statusTitle {{statusCssConfigList[status]}}">'
					                                        +'{{status}}'
					                                        +'</span>'
					                                        +'<span class="chk_tick" id="isInstall" ng-click="changeJobStatus({statusKey: status})"'
					                                            +'ng-class = "{\'disableCheck \': disableJobStatus({statusKey: status}) }">'
					                                        +'<i ng-if="newWorkStatus == status" class="green_00A3DB doneIcon svg_width closeiconWidth" ng-include="getTrustedUrl(\'/Icons/check-1.svg\')"/>'
					                                        +'</span>'
					                                    +'</div>'
					                                 +'</div>'
					                            +'</div>' 
					                            +'<div class = "col-xs-5 P0"  >'
					                                +'<div class="MT-5" ng-if = "workStatus == \'Complete\' || workStatus === \'Invoiced\'">'
					                                    +'<span class = "bp-font-16 bp-reOpenStatus bp-bold-font">{{reOpen.title}}</span>'
					                                    +'<div class = "statusLog">'
					                                        +'<span class="statusTitle {{statusCssConfigList[reOpen.status]}}">'
					                                            +'{{reOpen.status}}'
					                                        +'</span>'
					                                         +'<span class="chk_tick" ng-class ="{\'disableCheck\':workStatus === \'Invoiced\'}" ng-click = "reOpenStatusService(reOpen.status)">'
					                                        +'<i ng-if="workStatus == reOpen.status" class="green_00A3DB doneIcon svg_width" ng-include="getTrustedUrl(\'/Icons/check-1.svg\')"/>'
					                                        +'</span>'
					                                    +'</div>'
					                                +'</div>'
					                            +'</div>'
					                        +'</div>'
					                        +'<div class="bp-status-btn-save-wrapper bp-changeJobStatusSave col-xs-offset-7">'
					                                 +'<button class="bp-btn bp-btn-normal" data-dismiss="modal" ng-click="saveWorkStatus()">{{okBtnLabel || \'SAVE\'}}</button>'
					                       +'</div>'
					                   +'</div>'
			                    	+'</div>'
						 		+ '</div>'
							+ '</div>'
						 + '</div>';
define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
	Routing_AppJs_PK.directive('statusConfig', ['$sce', function($sce) {
		return {
			restrict: 'E',
			scope: {
				statusList: '=',
				showDialog: '=',
				statusCssConfigList : '=',
				changeJobStatus : '&',
				newWorkStatus: '=',
				workStatus: '=',
				reOpen : '=',
				reOpenStatusService : '&',
				saveWorkStatus : '&',
				jobStatusTitle: '=',
				okBtnLabel:'=',
				canSaveWorkStatus : '=',
				disableJobStatus:'&'
			},
			replace: true, // Replace with the template below
			transclude: true, // We want to insert custom content inside the directive
			template: bpStatusConfigHTML,
			link: function(scope, element, attrs) {
				
				scope.$watch('showDialog', function(newValue, oldValue) {
					if (newValue) {
						angular.element('body').addClass('modal-open');
					} else {
						angular.element('body').removeClass('modal-open');
					}
				}, true);
				
				scope.dailogStyle = {};
				if(attrs.width) {
					scope.dailogStyle.width = attrs.width;
				}
				if(attrs.height) {
					scope.dailogStyle.height = attrs.height;
				}
				scope.closeDialog = function() {
					scope.showDialog = false;
				};
				scope.ApplicationImagePath = $Global.ApplicationImagePath ;
                scope.getTrustedUrl = function (resourceName) {
            		return $sce.trustAsResourceUrl(scope.ApplicationImagePath + resourceName);
                }
			}
		};
	}]);
});
