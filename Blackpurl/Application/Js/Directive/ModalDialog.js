"use strict";
var bpModalDialogHTML = '<div ng-class="{\'dialog-opacity\': showDialog, \'in\': showDialog}"  style="display: block" class="modal fade bp-cp-modal-dialog {{modalCss}}" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" id="bp-cp-modal-dialog">'
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
											+ '<div ng-if="messageText" class="message-info">'
												+ '<span class="bp-dark-grey2-font"><p ng-bind-html="messageText"></p></span>'
											+ '</div>'
											+ '<div ng-if="helperText" class="helper-text">'
												+ '<span class="bp-dark-grey2-font"><p ng-bind-html="helperText"></p></span>'
											+ '</div>'
											+ '<div ng-if="warningText" class="helper-text">'
												+ '<span class="bp-dark-grey2-font warning-text"><p ng-bind-html="warningText"></p></span>'
											+ '</div>'
						                    + '<ng-transclude></ng-transclude>'
											+ '<div class="action-section">'
												+ '<button ng-if="!isAlert" class="bp-btn bp-btn-secondaryCTA bp-btn-medium text-uppercase" ng-click="closeDialog();">{{cancelBtnLabel || \'CANCEL\'}}</button>'
												+ '<button class="action-button bp-btn bp-btn-normal bp-btn-medium text-uppercase {{okBtnCss}}" ng-click="okBtnFunc(payload); closeDialog();">{{okBtnLabel || \'OK\'}}</button>'
											+ '</div>'
										+ '</div>'
									+ '</div>'
								+ '</div>'
							+ '</div>'
						+ '</div>';
define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
	Routing_AppJs_PK.directive('modalDialog', ['$sce', function($sce) {
		return {
			restrict: 'E',
			scope: {
				showDialog: '=',
				headingText: '=',
				messageText: '=',
				helperText: '=',
				warningText: '=',
				okBtnLabel: '=',
				cancelBtnLabel: '=',
				okBtnCss: '=',
				isAlert: '=',
				okBtnFunc: '&',
				cancelBtnFunc: '&',
				payload: '@',
				modalCss: '=',
				hideCloseIcon: '='
			},
			replace: true, // Replace with the template below
			transclude: true, // We want to insert custom content inside the directive
			template: bpModalDialogHTML,
			link: function(scope, element, attrs) {
				// to remove the scrolling from page body
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
					scope.cancelBtnFunc();
				};				
				// To load static resources by adding them as trusted resources
				scope.ApplicationImagePath = $Global.ApplicationImagePath ;
                scope.getTrustedUrl = function (resourceName) {
            		return $sce.trustAsResourceUrl(scope.ApplicationImagePath + resourceName);
                }
			}
		};
	}]);
});
