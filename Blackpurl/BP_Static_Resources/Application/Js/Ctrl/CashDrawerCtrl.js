define(['Routing_AppJs_PK','CashDrawerServices','underscore_min','TooltipLoader'], function(Routing_AppJs_PK,CashDrawerServices,underscore_min,TooltipLoader) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('CashDrawerCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', '$window', '$document', '$location','$translate','CashDrawerServices', function($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, $window, $document, $location,$translate,CashDrawerServices) {
        var Notification = injector1.get("Notification");
        $scope.M_CashDrawer = $scope.M_CashDrawer || {};
        $scope.F_CashDrawer = $scope.F_CashDrawer || {};
        $scope.M_CashDrawer.showAddEditModal = false;
        $scope.M_CashDrawer.newCashDrawer = {};
        $scope.M_CashDrawer.isError = false;
        $scope.F_CashDrawer.openModalWindow = function(EditJson) {
           $scope.M_CashDrawer.showAddEditModal = true;
           if(EditJson) {
            	$scope.M_CashDrawer.newCashDrawer = angular.copy(EditJson);
            	isDeleteCashDrawerActionAvailable(EditJson.Id);
        	   	isCashDrawerCanBeInactive(EditJson);
           }
        }
        angular.element(document).on("click", "#AddEditCashDrawer .app-modal-overlay", function() {
            $scope.F_CashDrawer.hideAddEditModal();
        });
        
        var isCashDrawerCanBeInactive = function(cashDrawerJson) {
        	$scope.M_CashDrawer.isCashDrawerCanBeInactive = false;
        	CashDrawerServices.isCashDrawerCanBeInactive(angular.toJson(cashDrawerJson)).then(function(successResult) {
        		$scope.M_CashDrawer.isCashDrawerCanBeInactive = successResult.isInactiveAllowed;
            }, function(errorMessage) {
            	$scope.M_CashDrawer.isCashDrawerCanBeInactive = false;
            });
        }

        $scope.F_CashDrawer.changeAciveCashDrawer = function(event) {
            if(!$scope.M_CashDrawer.newCashDrawer.IsActive) {
        		if($scope.M_CashDrawer.cashDrawerList.length == 1) {
                    event.preventDefault();
                    Notification.error("One default drawer can not change in active");
        		} else if($scope.M_CashDrawer.cashDrawerList.length > 1 && !$scope.M_CashDrawer.isCashDrawerCanBeInactive) {
        			event.preventDefault();
               		Notification.error("Cash drawer has unreconciled payment entries, So can not be made inactive");
               	}
        	}
        }
        function cashDrawerValidation() {
            var isValidate = true;
            for(var i=0;i<$scope.M_CashDrawer.cashDrawerList.length;i++) {
                if(!$scope.M_CashDrawer.newCashDrawer.CashDrawerName || ($scope.M_CashDrawer.cashDrawerList[i].CashDrawerName).toLowerCase() === ($scope.M_CashDrawer.newCashDrawer.CashDrawerName).toLowerCase() && 
                    (!$scope.M_CashDrawer.newCashDrawer.Id || $scope.M_CashDrawer.cashDrawerList[i].Id != $scope.M_CashDrawer.newCashDrawer.Id )) {
                   isValidate = false;
                }
            }
            if(isValidate) {
                return true;
            } else {
                return false;
            }
        }
        
        $scope.F_CashDrawer.saveCashDrawer = function() {
            if(!cashDrawerValidation()) {
                $scope.M_CashDrawer.isError = true;
                return ;
            }
            if(!$scope.M_CashDrawer.newCashDrawer.Id) {
              $scope.M_CashDrawer.newCashDrawer.IsActive = true;
            }
               CashDrawerServices.saveCashDrawer(angular.toJson($scope.M_CashDrawer.newCashDrawer)).then(function(successResul) {
                   if(!$scope.M_CashDrawer.newCashDrawer.Id) {
                        $scope.M_CashDrawer.cashDrawerList.push($scope.M_CashDrawer.newCashDrawer);
                   }else {
                     var cashDrawerEditIndex = _.findIndex($scope.M_CashDrawer.cashDrawerList, {'Id': $scope.M_CashDrawer.newCashDrawer.Id});
                     if(cashDrawerEditIndex > -1) {
                         $scope.M_CashDrawer.cashDrawerList[cashDrawerEditIndex] = $scope.M_CashDrawer.newCashDrawer;
                     }
                   }

                    loadAllCashDrawer();
                    $scope.F_CashDrawer.hideAddEditModal();
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
        }
        
        var isDeleteCashDrawerActionAvailable = function(cashDrawerId) {
        	$scope.M_CashDrawer.isDeleteAvailable = false;
        	CashDrawerServices.isCashDrawerCanBeDeleted(cashDrawerId).then(function(successResult) {
    			$scope.M_CashDrawer.isDeleteAvailable = successResult.isDeleteAvailable;
            }, function(errorMessage) {
            	$scope.M_CashDrawer.isDeleteAvailable = false;
            });
        }
        
        $scope.F_CashDrawer.deleteCashDrawer = function() {
             CashDrawerServices.deleteCashDrawer($scope.M_CashDrawer.newCashDrawer.Id).then(function(successResul) {
                    var cashDrawerEditIndex = _.findIndex($scope.M_CashDrawer.cashDrawerList, {'Id': $scope.M_CashDrawer.newCashDrawer.Id});
                    if(cashDrawerEditIndex > -1) {
                        $scope.M_CashDrawer.cashDrawerList.splice(cashDrawerEditIndex,1);
                    }
                   $scope.F_CashDrawer.hideAddEditModal(); 
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
        }
        $scope.F_CashDrawer.hideAddEditModal = function() {
            $scope.M_CashDrawer.showAddEditModal = false;
            $scope.M_CashDrawer.newCashDrawer = {};
            $scope.M_CashDrawer.isError = false;
        }
        function loadAllCashDrawer() {
            CashDrawerServices.getAllCashDrawerList().then(function(successResul) {
                    $scope.M_CashDrawer.cashDrawerList = successResul; 
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
            }

        loadAllCashDrawer();
    }])
});