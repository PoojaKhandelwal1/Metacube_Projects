define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
	Routing_AppJs_PK.directive('bpCarousel', ['$sce', '$rootScope','$state', function($sce, $rootScope, $state) {
		return {
			restrict: 'E',
	        scope: {
	        	idValue:'@',
	        	classValue:'@',
	        	ngClassValue:'@',
	        	imageList:'=',
	        	currentViewingImgId:'=',
	        	currentViewingImgUrl:'='
	        },
	        template: 	'<div class="carousel-container">'+
	        				'<div class="left-arrow" ng-if="imageList.length > 1">'+
	        					'<span class="" data-toggle="tooltip" title="Previous" id="">' +
	        		   				'<i ng-include="getTrustedUrl(\'/Icons/arrow-left-1.svg\')" class="white_FFF_NewCO arrow-size bp-pointer-cursor" ng-click="showPrevImage()"></i>' +
	        		   			'</span>'+
	        		   		'</div>'+
	        		   		'<div class="image-container">' +
	        		   			'<img ng-src="{{currentViewingImgUrl}}" />'+
        		   			'</div>'+
        		   			'<div class="right-arrow" ng-if="imageList.length > 1">'+
        		   				'<span class="" data-toggle="tooltip" title="Next" id="">' +
	        		   				'<i ng-include="getTrustedUrl(\'/Icons/arrow-right-1.svg\')" class="white_FFF_NewCO arrow-size bp-pointer-cursor" ng-click="showNextImage()"></i>' +
	        		   			'</span>'+
	        		   		'</div>'+
	        		   	'</div>',
	        link: function(scope) {
	        	angular.element(document).bind('keyup', function(event) {
	        		var code = event.keyCode;
	        		if(code == 39) {
	        			scope.showNextImage();
	        		}
	        		if(code == 37) {
	        			scope.showPrevImage();
	        		}
	        		if (scope.$root.$$phase != '$apply' && scope.$root.$$phase != '$digest') {
	        			scope.$apply();
                    }
	        	});
	        	
	    	   scope.getTrustedUrl = function (resourceName) {
	    		   return $sce.trustAsResourceUrl($Global.ApplicationImagePath + resourceName);
               }
	    	   scope.showPrevImage = function() {
	    		   	var currentViewingImgIndex = _.findIndex(scope.imageList, {
	                    'DocId': scope.currentViewingImgId
	                });
	            	if(currentViewingImgIndex != -1) {
            			currentViewingImgIndex--;
            			if(currentViewingImgIndex < 0) {
            				currentViewingImgIndex = scope.imageList.length - 1;
            			}
            			scope.currentViewingImgUrl = scope.imageList[currentViewingImgIndex].AttchmentURL;
            			scope.currentViewingImgId = scope.imageList[currentViewingImgIndex].DocId;
	            	}
	    	   }
	    	   scope.showNextImage = function() {
	    		   	var currentViewingImgIndex = _.findIndex(scope.imageList, {
	                    'DocId': scope.currentViewingImgId
	                });
	            	if(currentViewingImgIndex != -1) {
            			currentViewingImgIndex++;
            			if(currentViewingImgIndex > scope.imageList.length - 1) {
            				currentViewingImgIndex = 0;
            			}
            			scope.currentViewingImgUrl = scope.imageList[currentViewingImgIndex].AttchmentURL;
            			scope.currentViewingImgId = scope.imageList[currentViewingImgIndex].DocId;
	            	}
	    	   }
	       }
		};
    }]);
});