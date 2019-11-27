define(['Routing_AppJs_PK', 'underscore_min'], function (Routing_AppJs_PK, underscore_min) {
	var injector = angular.injector(['ui-notification', 'ng']);
	Routing_AppJs_PK.directive('unitSpecification',['$rootScope', function($rootScope) {
		var Notification = injector.get("Notification");
		return {
            restrict: 'EA',
            scope: {
                unitSpecification: "="
             },
            template: '<div class="unit-specification-container bg-white" ng-if = "unitSpecification && checkIfChangeExists()">' + 
                        '<span class="H300 line-height-medium bp-orange-font"> Fields don’t match our records. Try another VIN number or correct the field(s) below</span>'+
                        '<div class="unit-specification-data"> '+
                        '<table class="unit-specification-table"><thead><tr>'+
                            '<th class="bp-grey-font">You’ve entered:</th><th class="bp-grey-font">Suggested:</th><th></th><th ng-if = "!unitSpecification.isHideIgnore"></th></tr></thead>'+
                            '<tbody><tr ng-repeat=" (key, value) in unitSpecification " ng-hide="value.isHideRecord || key == \'isHideIgnore\'">'+
                            '<td><label class="col-xs-12 P0 H300" ng-if="key != \'NumberOfCyclinder\'">{{key}}:</label>'+ 
                            '<label class="col-xs-12 P0 H300" ng-if="key == \'NumberOfCyclinder\'">Cylinders:</label>'+
                            '<span class="H301" ng-if = "value[0]">{{value[0]}}</span> <span class="H301" ng-if = "!value[0]">- - - - - - - - -</span>'+
                            '</td>'+
                            '<td class="vertical-align-bottom">'+
                            '<span class="H301" ng-if = "value[1]">{{value[1]}}</span> <span class="H301" ng-if = "!value[1]">- - - - - - - - -</span>'+
                            '</td>'+
                            '<td class="vertical-align-bottom"><a class="bp-blue-font pull-right" ng-click="changeAction(key)">Change</a></td>'+
                            '<td class="vertical-align-bottom" ng-if = "!unitSpecification.isHideIgnore"><a class="bp-blue-font pull-right" ng-click="ignoreAction(key)">Ignore</a></td>'+
                            '</tr>'+
                            '</tbody></table>'+
                         '</div>' +
                        '</div>',
            link: function($scope, elem, attrs) {
            	$scope.changeAction = function(key) {
            		$scope.unitSpecification[key][0] = $scope.unitSpecification[key][1];
            		$scope.unitSpecification[key]['isHideRecord'] = true;
            		if($rootScope.currentStateName == 'UnitOrdering.AddeditUnitOrder') {
            			$rootScope.$broadcast('updateUnitDetailFromDirective',{ key: key, value:$scope.unitSpecification[key][1] });
            		} else if($rootScope.currentStateName == 'UnitOrdering.AddeditUnitOrder.UnitReceivingDialog' || $rootScope.currentStateName == 'UnitOrdering.ViewVendorOrderUnits.UnitReceivingDialog') {
            			var index = $(event.target).closest("tr").parent().parent().parent().parent().parent().siblings().eq(0).find("input").val();
            			$rootScope.$broadcast('updateUnitDetailFromDirective',{ key: key, value:$scope.unitSpecification[key][1], index: index });
            		}
            	}
            	
            	$scope.ignoreAction = function(key) {
            		$scope.unitSpecification[key]['isHideRecord'] = true;
            		if($rootScope.currentStateName == 'UnitOrdering.AddeditUnitOrder.UnitReceivingDialog' || $rootScope.currentStateName == 'UnitOrdering.ViewVendorOrderUnits.UnitReceivingDialog') {
            			var index = $(event.target).closest("tr").parent().parent().parent().parent().parent().siblings().eq(0).find("input").val();
            			$rootScope.$broadcast('ignoreChangeUnitDetailFromDirective',{ index: index });
            		}
            	}
            	
            	$scope.checkIfChangeExists = function() {
            		var arr = Object.entries($scope.unitSpecification);
            		for(var i=0; i<arr.length; i++) {
            			if(arr[i][0] != 'isHideIgnore' && arr[i][1] && !arr[i][1].isHideRecord) {
            				return true;
            			}
            		}
            		return false;
            	}
            }  
        }
    }]);
});   

