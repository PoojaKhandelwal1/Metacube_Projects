define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
	Routing_AppJs_PK.directive('fullPageModal', ['$sce', '$rootScope','$state', function($sce, $rootScope, $state) {
		return {
			restrict: 'E',
	        transclude: true,
	        scope: {
	        	idValue:'@',
	        	classValue:'@',
	        	ngClassValue:'@',
	        	closeAction: '&'
	        },
	        template: '<div class="modal fade-scale bp-model-dialog bp-full-page-container" id="{{idValue}}" ng-class="{{ngClassValue}}" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel">'+
	        			'<div class="modal-dialog modal-lg" role="document">'+
	        			'<div id="" class="bp-full-page-modal">' +
	        		   		'<div class="bp-close-icon-circle">' +
	        		   			'<button type="button" class="bp-close-button" ng-click="closeAction()" aria-label="Close" >'+
	        		   				'<span>'+
	        		   					'<i  class="bp-blue3384ff" ng-include="getTrustedUrl(\'/Icons/close.svg\')"></i>' +
	        		   				'</span>'+
        		   				'</button>'+
    		   				'</div>'+
    		   				'<ng-transclude></ng-transclude>' +
	                  '</div></div></div>',
	        link: function(scope) {
	    	   scope.getTrustedUrl = function (resourceName) {
	    		   return $sce.trustAsResourceUrl($Global.ApplicationImagePath + resourceName);
               }
	    	   
	       }
		};
    }]);
});