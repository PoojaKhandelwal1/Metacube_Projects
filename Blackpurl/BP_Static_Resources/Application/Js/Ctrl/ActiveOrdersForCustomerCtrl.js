define(['Routing_AppJs_PK', 'ActiveOrdersForCustomerServices', 'JqueryUI'], function(Routing_AppJs_PK, ActiveOrdersForCustomerServices, JqueryUI) {
    $(document).ready(function() {
        $(".form-control").focus(function() {
            $('.controls').hide();
            $('#' + $(this).attr('rel')).show();
        })
        $('#closemodal').click(function() {
            $('#pop').modal('hide');
        });
        setTimeout(function() {
            $('[data-toggle="tooltip"]').tooltip({
                placement: 'bottom'
            });
        }, 2000);
    });
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('ActiveOrdersForCustomerCtrl', ['$scope', '$rootScope', '$stateParams', '$state', 'ActiveOrdersService', function($scope, $rootScope, $stateParams, $state, ActiveOrdersService) {
        var Notification = injector.get("Notification");
        if ($scope.ActiveOrders == undefined) {
            $scope.ActiveOrders = {};
        }
        $scope.ActiveOrders.ActiveOrders = [];
        $scope.$on('ActiveOrdersOpenPopupEvent', function(event, args) {
            if (args.CoType == 'Part Sale') {
                $scope.ActiveOrders.selectesText = 'Select Parts Customer';
            } else if (args.CoType == 'Service Order') {
                $scope.ActiveOrders.selectesText = 'Select Service Customer';
            } else if (args.CoType == 'Unit Deal') {
                $scope.ActiveOrders.selectesText = 'Select Deal Customer';
            } else if (args.CoType == 'Cash Sale') {} else if (args.CoType == 'Internal Service') {}
            $scope.ActiveOrders.openActiveOrdersPopup();
            $scope.ActiveOrders.CoType = args.CoType;
            $scope.ActiveOrders.customerId = args.CustomerId;
            $scope.ActiveOrders.AppointmentId = args.AppointmentId;
        });
        $scope.$on('ActiveOrdersLoadJsonEvent', function(event, args) {
            $scope.ActiveOrders.ActiveOrders = args.ActiveOrdersJson;
        });
        $scope.ActiveOrders.openActiveOrdersPopup = function() {
            angular.element('.controls').hide();
            setTimeout(function() {
                angular.element('#ActiveOrdersPopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
            setTimeout(function() {
                if (angular.element('.activeOrdersPopup .popupinside .popupright .tabconainer').length > 0) {
                    angular.element('.activeOrdersPopup .popupinside .popupright .tabconainer')[0].scrollTop = 0;
                }
            }, 500);
        }
        $scope.ActiveOrders.cancelActiveOrdersPopup = function() {
            angular.element('#ActiveOrdersPopup').modal('hide');
        }
        $scope.ActiveOrders.cancelActiveOrdersPopup1 = function() {
            angular.element('#ActiveOrdersPopup').modal('hide');
            if ($stateParams.myParams != undefined && $stateParams.myParams != '' && $stateParams.myParams.A_View_StateName != undefined && $stateParams.myParams.A_View_StateName != '') {
                var previousStateName = $stateParams.myParams.A_View_StateName;
                var previousState_iDParams = $stateParams.myParams.A_View_StateParams.Id;
            } else {
                var previousStateName = $rootScope.$previousState.name;
                var previousState_iDParams = $rootScope.$previousStateParams.Id;
            }
            loadState($state, previousStateName, {
                Id: previousState_iDParams
            });
        }
        $scope.ActiveOrders.openCustomerOrder = function(COHeaderId) {
            loadState($state, 'CustomerOrder', {
                Id: COHeaderId
            });
            $scope.ActiveOrders.cancelActiveOrdersPopup();
        }
        $scope.ActiveOrders.createCO = function(customerId) {
            $scope.ActiveOrders.cancelActiveOrdersPopup();
            ActiveOrdersService.addNewCustomerOrder(customerId, $scope.ActiveOrders.CoType).then(function(successfulSearchResult) {
                if ($scope.ActiveOrders.CoType == 'Part Sale') {
                    loadState($state, 'CustomerOrder', {
                        Id: successfulSearchResult
                    });
                } else if ($scope.ActiveOrders.CoType == 'Service Order') {
                    if ($scope.ActiveOrders.AppointmentId != undefined && $scope.ActiveOrders.AppointmentId != null && $scope.ActiveOrders.AppointmentId != '') {
                        var addServiceJobForJobSchedulingJson = {
                            COHeaderId: successfulSearchResult,
                            Id: $scope.ActiveOrders.AppointmentId
                        };
                        ActiveOrdersService.addServiceJobForJobScheduling(angular.toJson(addServiceJobForJobSchedulingJson)).then(function() {}, function(errorSearchResult) {
                            responseData = errorSearchResult;
                        });
                    }
                    loadState($state, 'CustomerOrder', {
                        Id: successfulSearchResult
                    });
                } else if ($scope.ActiveOrders.CoType == 'Unit Deal') {
                    loadState($state, 'CustomerOrder', {
                        Id: successfulSearchResult
                    });
                } else if ($scope.ActiveOrders.CoType == 'Cash Sale') {
                    loadState($state, 'CashSaleCO', {
                        Id: successfulSearchResult
                    });
                } else if ($scope.ActiveOrders.CoType == 'Internal Service') {
                    var myWindow = window.open("{!$Page.newCustomerOrder}?id=" + successfulSearchResult, "_self");
                    loadState($state, 'CustomerOrder', {
                        Id: successfulSearchResult
                    });
                }
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
            });
        }
        $scope.ActiveOrders.ActiveOrdersOpenPopupEvent = function(args) {
            if (args.CoType == 'Part Sale') {
                $scope.ActiveOrders.selectesText = 'Select Parts Customer';
            } else if (args.CoType == 'Service Order') {
                $scope.ActiveOrders.selectesText = 'Select Service Customer';
            } else if (args.CoType == 'Unit Deal') {
                $scope.ActiveOrders.selectesText = 'Select Deal Customer';
            } else if (args.CoType == 'Cash Sale') {} else if (args.CoType == 'Internal Service') {}
            $scope.ActiveOrders.openActiveOrdersPopup();
            $scope.ActiveOrders.CoType = args.CoType;
            $scope.ActiveOrders.customerId = args.CustomerId;
            $scope.ActiveOrders.AppointmentId = args.AppointmentId;
        }
        $scope.ActiveOrders.ActiveOrdersLoadJsonEvent = function(args) {
            $scope.ActiveOrders.ActiveOrders = args.ActiveOrdersJson;
        }
        $scope.ActiveOrders.openActiveOrdersForCustomerPopup = function() {
            $scope.ActiveOrders.ActiveOrdersOpenPopupEvent($stateParams.myParams);
            $scope.ActiveOrders.ActiveOrdersLoadJsonEvent($stateParams.myParams);
        }
        $scope.ActiveOrders.openActiveOrdersForCustomerPopup();
    }]);
});