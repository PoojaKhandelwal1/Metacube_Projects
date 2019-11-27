"use strict";
var partLocatorHtml = '<div ng-class="{\'dialog-opacity\': showDialog, \'in\': showDialog}"  style="display: block" class="modal fade bp-cp-modal-dialog {{modalCss}}" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" id="PartLocatorModalDialog">'
							+ '<div class="modal-backdrop fade in" ng-click="closeDialog()"></div>'
							+ '<div class="modal-dialog" role="document">'
								+ '<div class="modal-content">'
									+ '<div class="modal-header">'
										+ '<button type="button" class="close" data-dismiss="modal" aria-label="Close" ng-click="closeDialog()" ng-if="!hideCloseIcon">'
												+ '<span aria-hidden="true">'
													+ '<i class="white_FFF svg_width" ng-include="getTrustedUrl(\'/Icons/close.svg\')"></i>'
												+ '</span>'
										+ '</button>'
									+ '</div>'
									+ '<div class="modal-body">'
										+ '<div>'
											+ '<div ng-if="headingText" class="heading-text text-uppercase">{{headingText}}</div>'
											+ '<div ng-if="partDescription" class="message-info">'
												+ '<span class="bp-dark-grey1-font">{{partDescription}}</span>'
											+ '</div>'
											+ '<div ng-if="availabiltyText" class="part-available-container">'
												+ '<strong class="part-available-number">{{availabiltyNumber}}</strong>'
												+ '<div class="part-available-information">'
													+ '<p class="bp-dark-grey1-font">{{availabiltyText}}</p>'
													+ '<strong class="bp-blue-font">{{phoneNumber}}</strong>'
												+ '</div>'
											+ '</div>'
											+ '<div class="dealer-header" ng-click="showNearDealerDropdown()" ng-class="{\'remove-bottom-border\' : showNearDealer && nearDealerList, \'bp-disabled\':!nearDealerList}">' 
												+'<span class="dealer-header-span" ng-class="{\'bp-dark-grey1-font\' : showNearDealer && nearDealerList}">Show availabilty from dealer near you</span>' 
												+'<span class="dealer-header-span align-icon-to-end"><i class="bp-blue white_FFF_NewCO" ng-class="{\'bp-rotate-svg\': showNearDealer && nearDealerList}" ng-include="getTrustedUrl(\'/Icons/arrowDown.svg\')"></i></span>'
											+ '</div>'
											+ '<div class="dealer-header dealer-dropdown" id="nearDealer">'	
												+ '<ul class="dealer-dropdown-container">'
													+ '<li class="" ng-repeat="dealer in nearDealerList track by $index">'
													+ '<span class=" part-available-number">{{dealer.AvailableQty}}</span>'	
													+ '<div class="part-available-address"> <span class="H300">{{dealer.DealerName}} </span> <span class="H301">{{dealer.DealerAddress}} </span></div>'
													+ '<div class="part-available-away"> <span class="distance">{{dealer.Distance}} </span> <span class="phone-number H300">{{dealer.DealerPhoneNumber}} </span></div>'	
													+ '</li>'
												+ '</ul>'
											+ '</div>'
											+ '<div class="dealer-header dealer-all-header" ng-click="showAllDealerDropdown()" ng-class="{\'remove-bottom-border\' : showAllDealer && allDealerList, \'bp-disabled\':!allDealerList}">' 
											+'<span class="dealer-header-span"ng-class="{\'bp-dark-grey1-font\' : showAllDealer && allDealerList}">Show availabilty from all dealers</span>' 
											+'<span class="dealer-header-span align-icon-to-end"><i class="bp-blue white_FFF_NewCO" ng-class="{\'bp-rotate-svg\': showAllDealer && allDealerList}" ng-include="getTrustedUrl(\'/Icons/arrowDown.svg\')"></i></span>'
											+ '</div>'
											+ '<div class="dealer-header dealer-dropdown" id="allDealer" >'	
												+ '<ul class="dealer-dropdown-container">'
													+ '<li class="" ng-repeat="dealer in allDealerList track by $index">'
													+ '<span class=" part-available-number">{{dealer.AvailableQty}}</span>'	
													+ '<div class="part-available-address"> <span class="H300">{{dealer.DealerName}} </span> <span class="H301">{{dealer.DealerAddress}} </span></div>'
													+ '<div class="part-available-away"> <span class="distance">{{dealer.Distance}}</span> <span class="phone-number H300">{{dealer.DealerPhoneNumber}} </span></div>'	
													+ '</li>'
												+ '</ul>'
											+ '</div>'
						                    + '<ng-transclude></ng-transclude>'
										+ '</div>'
									+ '</div>'
								+ '</div>'
							+ '</div>'
						+ '</div>';
define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
	Routing_AppJs_PK.directive('partLocator', ['$sce', function($sce) {
		return {
			restrict: 'E',
			scope: {
				showDialog: '=',
				headingText: '=',
				partDescription: '=',
				availabiltyText:'=',
				availabiltyNumber:'=',
				phoneNumber:'=',
				payload: '@',
				modalCss: '=',
				hideCloseIcon: '=',
				nearDealList:'=',
				showNearDealerDropdown:'&',
				showAllDealerDropdown:'&',
				nearDealerList:'=',
				allDealerList:'='
			},
			replace: true, // Replace with the template below
			transclude: true, // We want to insert custom content inside the directive
			template: partLocatorHtml,
			link: function(scope, element, attrs) {
				// to remove the scrolling from page body
				scope.showNearDealer = false;
				scope.showAllDealer = false;
				if(scope.nearDealerList && scope.allDealerList) {
					for(var i=0;i<scope.nearDealerList.length;i++) {
						for (var j=0;j<scope.allDealerList.length;j++){
								if(scope.allDealerList[j].DealerName === scope.nearDealerList[i].DealerName) {
										scope.allDealerList.splice(j,1);
										break;
								}
						}
					}
				}
			angular.element("#nearDealer").removeClass("add-tranisition");
			angular.element("#allDealer").removeClass("add-tranisition");
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
				// Default Method to close the modal dialog
				scope.closeDialog = function() {
					scope.showDialog = false;
				};				
				scope.showNearDealerDropdown = function()  {
					scope.showAllDealer = false;
					scope.showNearDealer = !scope.showNearDealer;
					if(scope.showNearDealer && scope.nearDealerList) {
						angular.element("#nearDealer").addClass("add-tranisition");
						angular.element("#nearDealer").scrollTop(0);
						angular.element("#allDealer").removeClass("add-tranisition");
					} else {
						angular.element("#nearDealer").removeClass("add-tranisition");
					}
				}
				scope.showAllDealerDropdown = function()  {
					scope.showAllDealer = !scope.showAllDealer;
					scope.showNearDealer = false;
					if(scope.showAllDealer && scope.allDealerList) {
						angular.element("#allDealer").addClass("add-tranisition");
						angular.element("#allDealer").scrollTop(0);
						angular.element("#nearDealer").removeClass("add-tranisition");
					} else {
						angular.element("#allDealer").removeClass("add-tranisition");
					}
				}
				// To load static resources by adding them as trusted resources
				scope.ApplicationImagePath = $Global.ApplicationImagePath ;
                scope.getTrustedUrl = function (resourceName) {
            		return $sce.trustAsResourceUrl(scope.ApplicationImagePath + resourceName);
                }
			}
		};
	}]);
});
