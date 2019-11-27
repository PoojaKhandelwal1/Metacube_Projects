var angularMultiSelectList = angular.module('angularMultiSelectList', []);

angularMultiSelectList.directive('multiSelect', function($q) {
	return {
		restrict: 'E',
		require: 'ngModel',
		scope: {
			selectedLabel : "@",
			availableLabel : "@",
			displayAttr : "@",
			available : "=",
			model : "=ngModel",
			isSlds : "=?"
		},
		template:	'<div id="multiSelectBox" class="slds-picklist--draggable slds-grid" style="display:inline-flex; align-items: flex-end;">' +
						'<div class="slds-form-element" style="width: 12rem;display: inline-block;">' +
							'<label class="slds-form-element__static multiSelectHeader">{{ availableLabel }} ({{ available.length }})</label>' +
							'<div class="slds-form-element__control">' +
								'<div class="slds-picklist slds-picklist--multi">' +
									'<select style="width: 12rem;height: 8rem;" ng-class="{\'slds-picklist__options slds-picklist__options--multi slds-scrollable--y\' : isSlds}" ' +
											' multiple="multiple" ' +
											' ng-model="selected.available" ' +
											' ng-options="e as e[displayAttr] for e in available">' +
									'</select>' +
								'</div>' +
							'</div>' +
						'</div>' +
						'<div class="slds-grid slds-grid--vertical buttons-div"  style="display: inline-flex;flex-direction: column;">' +
							'<a ng-class="{\'slds-button slds-button--icon-container\' : isSlds, \'classicButton btn\' : !isSlds, \'disabledAnchor\' : selected.available.length == 0}" ng-click="add()">' +
								'<i class="fa fa-caret-right fa-lg" aria-hidden="true"></i>' +
							'</a>' +
							'<a ng-class="{\'slds-button slds-button--icon-container\' : isSlds, \'classicButton btn\' : !isSlds, \'disabledAnchor\': selected.current.length == 0}" ng-click="remove()">' +
								'<i class="fa fa-caret-left fa-lg" aria-hidden="true"></i>' +
							'</a>' +
						'</div>' +
						'<div class="slds-form-element" style="width: 12rem;display: inline-block;">' +
							'<label class="slds-form-element__static multiSelectHeader">{{ selectedLabel }} ({{ model.length }})</label>' +
							'<div class="slds-form-element__control">' +
								'<div class="slds-picklist slds-picklist--multi">' +
									'<select  style="width: 12rem;height: 8rem;" ng-class="{\'slds-picklist__options slds-picklist__options--multi slds-scrollable--y\' : isSlds}" ' +
											' multiple="multiple" ' +
											' ng-model="selected.current" ' +
											' ng-change="calcIndex()" ' +
											' ng-options="e as e[displayAttr] for e in model">' +
									'</select>' +
								'</div>' +
							'</div>' +
						'</div>' +
						'<div class="slds-grid slds-grid--vertical buttons-div" style="display: inline-flex;flex-direction: column;">' +
							'<a ng-class="{\'slds-button slds-button--icon-container\' : isSlds, \'classicButton btn\' : !isSlds, \'disabledAnchor\': disableUp}" ng-click="moveUp()">' +
								'<i class="fa fa-caret-up fa-lg" aria-hidden="true"></i>' +
							'</a>' +
							'<a ng-class="{\'slds-button slds-button--icon-container\' : isSlds, \'classicButton btn\' : !isSlds, \'disabledAnchor\': disableDown}" ng-click="moveDown()">' +
								'<i class="fa fa-caret-down fa-lg" aria-hidden="true"></i>' +
							'</a>' +
						'</div>' +
					'</div>',
	link:
		function(scope, elm, attrs,$scope) {
			scope.selected = {
				available: [],
				current: []
			};
			scope.index = -1;
			scope.tempSelected = [];
			scope.disableUp = true;
			scope.disableDown = true;
			
			if (scope.isSlds == null || (typeof scope.isSlds == 'undefined')) {
				scope.isSlds = true;
			}

			scope.calcIndex = function() {
				scope.index = scope.model.indexOf(scope.selected.current[0]);
				scope.tempSelected = scope.selected.current;
				scope.enableDisableReordering();
			}
			scope.enableDisableReordering = function() {
				if (scope.index > 0 && scope.selected.current.length > 0) {
					scope.disableUp = false;
				} else {
					scope.disableUp = true;
				}
				if (scope.selected.current[scope.selected.current.length - 1] == scope.model[scope.model.length - 1] || scope.selected.current.length == 0) {
					scope.disableDown = true;
				} else {
					scope.disableDown = false;
				}
			}
			scope.moveUp = function() {
				
				for (var i = 0; i < scope.tempSelected.length; i++) {
					var tempIndex = scope.model.indexOf(scope.tempSelected[i]);
					scope.model.splice(tempIndex, 1);
					scope.model.splice(tempIndex - 1, 0, scope.tempSelected[i]);
					scope.model = [].concat.apply([], scope.model);
				}
				scope.index = scope.index - 1;
				scope.enableDisableReordering();
				scope.selected.current = scope.tempSelected;
			}
			scope.moveDown = function() {
				
				for (var i = scope.tempSelected.length - 1; i >= 0; i--) {
					var tempIndex = scope.model.indexOf(scope.tempSelected[i]);
					scope.model.splice(tempIndex, 1);
					scope.model.splice(tempIndex + 1, 0, scope.tempSelected[i]);
					scope.model = [].concat.apply([], scope.model);
				}
				scope.index = scope.index + 1;
				scope.enableDisableReordering();
				scope.selected.current = scope.tempSelected;
			}
			var dataLoading = function(scopeAttr) {
				var loading = $q.defer();
				if(scope[scopeAttr]) {
					loading.resolve(scope[scopeAttr]);
				} else {
					scope.$watch(
						scopeAttr,
						function(newValue, oldValue) {
							if (newValue !== undefined) {
								loading.resolve(newValue);
							}
						}
					);
				}
				return loading.promise;
			};
			var filterOut = function(original, toFilter) {
				var filtered = [];
				angular.forEach(
					original,
					function(entity) {
						var match = false;
						for (var i = 0; i < toFilter.length; i++) {
							if (toFilter[i][attrs.displayAttr] == entity[attrs.displayAttr]) {
								match = true;
								break;
							}
						}
						if (!match) {
							filtered.push(entity);
						}
					}
				);
				return filtered;
			};
			scope.refreshAvailable = function() {
				scope.available = filterOut(scope.available, scope.model);
				scope.selected.available = [];
				scope.selected.current = [];
			};
			scope.add = function() {
				scope.model = scope.model.concat(scope.selected.available);
				scope.refreshAvailable();
				scope.disableUp = true;
				scope.disableDown = true;
			};
			scope.remove = function() {
				scope.available = scope.available.concat(scope.selected.current);
				scope.model = filterOut(scope.model, scope.selected.current);
				scope.refreshAvailable();
				scope.disableUp = true;
				scope.disableDown = true;
			};
			$q.all([dataLoading("model"), dataLoading("available")]).then(
				function(results) {
					scope.refreshAvailable();
				}
			);
		}
	};
})