define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
	Routing_AppJs_PK.directive('infoCardComponent',['$sce', function($sce) {
		return {
			restrict: 'E',
	        transclude: true,
	        scope: {
	        	idValue:'@',
	        	classValue:'@',
	        	objectPayload: '=',
	        	headerLinkAction: '&',
	        	hyperlinkAction: '&',
	        	buttonAction: '&',
	        	imageAction: '&',
	        	overrideCss: '@',
	        	carouselId: '@'
	        	},
	        template:   
	        			'<div class="bp-info-card {{overrideCss}}">'
		        			+'<div class="bp-flex-col">'
		        				+ '<div ng-class="{\'info-container\' : objectPayload.unitImage }">'
			        				+'<div class="stocked-in-statue-wrapper bp-flex-col" ng-if="objectPayload.unitStatus">'
		        						+ '<span class="badge-style H300 text-uppercase P3p12p pull-left readyStatus bp-cyan-light">{{objectPayload.unitStatus}}</span>'
		        					+ '</div>'
			                    	+ '<div class="header-content">'
			        					+ '<i class="bp-blue" ng-include="getTrustedUrl(objectPayload.headerImage)" ng-if="objectPayload.headerImage"></i>'
			        					+ '<a class="text-capitalize bp-blue-font header-text" ng-class="{ \'ml-none\' : !(objectPayload.headerImage)}" ng-click="headerLinkAction()">{{objectPayload.headerText}}</a>'
			        				+ '</div>'
			        				+ '<div ng-repeat="primaryField in objectPayload.primaryFields" class="primary-field-items">'
			        					+ '<span ng-if="primaryField.Label">{{primaryField.Label}} : </span>'
			        					+ '<span>{{primaryField.Value}}</span>'
			        					+'<span class="PR4"ng-if="objectPayload.primaryFields[$index + 1].Value"> - </span>'
			        				+ '</div>'
			        			+ '</div>'
		        				+ '<div ng-if="objectPayload.unitImage" class="img-container">'
		        					+ '<img src="{{objectPayload.unitImage}}" ng-if="objectPayload.unitImage" ng-click="imageAction()" class="bp-pointer-cursor" data-toggle="modal" data-target="{{objectPayload.carouselId}}">'
		        				+ '{{hyperlinkAction}}</div>'
		        			+ '</div>'
		                    + '<ng-transclude></ng-transclude>'
		                    + '<div class="pt10 bp-flex-col change-link" ng-if="objectPayload.hyperlinkActionVisible">'
	        					+ '<a class="bp-blue-font bp-font-14 bp-bold-font" ng-click="hyperlinkAction()" href="">{{objectPayload.hyperlinktext}}</a>'
	        				+ '</div>'
	        				+ '<div class="action-btn-container bp-flex-col" ng-if="objectPayload.buttonActionVisible">'
	        					+ '<button class="bp-btn bp-btn-normal bp-font-14 action-btn" ng-click="buttonAction()">{{objectPayload.buttonText}}</button>'
	        				+ '</div>'
	                    + '</div>',
	       link: function(scope) {
	    	   scope.getTrustedUrl = function (resourceName) {
           		return $sce.trustAsResourceUrl($Global.ApplicationImagePath +'/Icons/'+ resourceName);
               }
	       }
		};
    }]);
});   
