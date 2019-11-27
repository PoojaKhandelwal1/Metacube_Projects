define(['Routing_AppJs_PK', 'UnitOrderingServices'], function (Routing_AppJs_PK, UnitOrderingServices) {

    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('ViewVendorOrderUnitsCtrl', ['$scope', '$stateParams', '$state', 'UnitOrderingService', '$compile', '$rootScope',
        function ($scope, $stateParams, $state, UnitOrderingService, $compile, $rootScope) {
            var Notification = injector1.get("Notification");

            $scope.M_ViewVOUs = $scope.M_ViewVOUs || {};
            $scope.F_ViewVOUs = $scope.F_ViewVOUs || {};
            $scope.M_ViewVOUs.ActiveOrderList = [];
            $scope.M_ViewVOUs.OrderHistoryList = [];
            $scope.M_ViewVOUs.enableReceivedUnitsBtnFlag = false;
            $scope.M_UO.isLoading = true;
            $scope.M_UO.isViewChanged = false;

            var success = function () {
                var self = this;
                this.arguments = arguments[0];
                this.calleeMethodName = arguments[0].calleeMethodName,
                    this.callback = arguments[0].callback,
                    this.handler = function (successResult) {
                        switch (self.calleeMethodName) {
                            case 'getActiveOrderListForVendor':
                                handleGetActiveOrderListForVendorResponse(successResult);
                                break;
                            case 'applySortingOnActiveOrderList':
                                handleGetActiveOrderListForVendorResponse(successResult);
                                break;
                            case 'getOrderHistoryForVendor':
                                handleGetOrderHistoryForVendorResponse(successResult);
                                break;
                            case 'applySortingOnOrderHistoryList':
                                handleGetOrderHistoryForVendorResponse(successResult);
                                break;
                            case 'getVendorDetails':
                                handleGetVendorDetailsResponse(successResult);
                                break;
                            case 'removeActiveOrder':
                                handleRemoveActiveOrderResponse(successResult);
                                break;
                            default:
                                break;
                        }

                        if (typeof self.callback === 'function') {
                            self.callback();
                        }
                    }

                function handleGetActiveOrderListForVendorResponse(ActiveOrderList) {
                	console.log(ActiveOrderList);
                    $scope.M_ViewVOUs.ActiveOrderList = ActiveOrderList;
                    $scope.M_ViewVOUs.viewName = 'ActiveOrders';
                    angular.element('[role ="tooltip"]').hide();
                    setTimeout(function () {
                        angular.element('[data-toggle="tooltip"]').tooltip({
                            placement: 'top',
                            container: 'body'
                        });
                    }, 500);

                    for (var i = 0; i < $scope.M_ViewVOUs.ActiveOrderList.length; i++) {
                        $scope.M_ViewVOUs.ActiveOrderList[i].isSelected = false;
                    }

                    $scope.M_ViewVOUs.enableReceivedUnitsBtnFlag = false;
                    $scope.M_UO.isLoading = false;
                    $scope.M_UO.isViewChanged = false;
                }

                function handleGetOrderHistoryForVendorResponse(OrderHistoryList) {
                    $scope.M_ViewVOUs.OrderHistoryList = OrderHistoryList;
                    $scope.M_ViewVOUs.viewName = 'OrderHistory';
                    $scope.M_ViewVOUs.enableReceivedUnitsBtnFlag = false;
                    $scope.M_UO.isLoading = false;
                    $scope.M_UO.isViewChanged = false;
                }

                function handleGetVendorDetailsResponse(vendorRec) {
                    $scope.M_UO.vendorName = vendorRec.VendorName;
                    $scope.M_ViewVOUs.vendorName = vendorRec.VendorName;
                }

                function handleRemoveActiveOrderResponse(ActiveOrderList) {
                    $scope.F_ViewVOUs.hideDeleteConfirmationPopup();
                    setTimeout(function () {
                        var deletedElement = angular.element('#' + self.arguments.elementId);
                        if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                            deletedElement.addClass('bp-collapse-deleted-div-transition');
                        }
                    }, 100);

                    setTimeout(function () {
                        $scope.M_ViewVOUs.ActiveOrderList = ActiveOrderList;
                        angular.element('[role ="tooltip"]').hide();
                        setTimeout(function () {
                            angular.element('[data-toggle="tooltip"]').tooltip({
                                placement: 'top',
                                container: 'body'
                            });
                        }, 500);
                        if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                            $scope.$apply(); //FIXME
                        }
                    }, 600);

                    $scope.F_ViewVOUs.deletableActiveOrderId = '';
                    $scope.F_ViewVOUs.deletableElementId = '';
                }
            }

            //FIXME
            var error = function (errorMessage) {
                this.handler = function (error) {
                    $scope.M_UO.isLoading = false;
                    $scope.M_UO.isViewChanged = false;
                    if (!errorMessage) {
                        console.log(error);
                    } else {
                        console.log(errorMessage);
                    }
                }
            }

            function createDefaultSortJson() {
                $scope.M_ViewVOUs.UnitsListSortJson = {
                    'unitId': {
                        'fieldName': 'UnitNumber',
                        'isSortingApplied': false,
                        'sortOrder': '',
                    },
                    'year': {
                        'fieldName': 'Year',
                        'isSortingApplied': false,
                        'sortOrder': '',
                    },
                    'make': {
                        'fieldName': 'Make',
                        'isSortingApplied': false,
                        'sortOrder': '',
                    },
                    'model': {
                        'fieldName': 'Model',
                        'isSortingApplied': false,
                        'sortOrder': '',
                    },
                    'factoryOrder': {
                        'fieldName': 'FactoryOrder',
                        'isSortingApplied': false,
                        'sortOrder': '',
                    },
                    'date': {
                        'fieldName': 'CreatedDate',
                        'isSortingApplied': false,
                        'sortOrder': '',
                    },
                    'StockedInDateTime': {
                        'fieldName': 'StockedInDateTime',
                        'isSortingApplied': false,
                        'sortOrder': '',
                    },
                    'totalCost': {
                        'fieldName': 'TotalCost',
                        'isSortingApplied': false,
                        'sortOrder': '',
                    },
                    'status': {
                        'fieldName': 'Status',
                        'isSortingApplied': false,
                        'sortOrder': '',
                    }
                }
            }

            function setDefaultSortJsonFieldsForActiveOrders() {
                $scope.M_ViewVOUs.UnitsListSortJson['unitId'].isSortingApplied = true;
                $scope.M_ViewVOUs.UnitsListSortJson['unitId'].sortOrder = 'ASC';
            }

            function setDefaultSortJsonFieldsForOrderHistory() {
                $scope.M_ViewVOUs.UnitsListSortJson['StockedInDateTime'].isSortingApplied = true;
                $scope.M_ViewVOUs.UnitsListSortJson['StockedInDateTime'].sortOrder = 'DESC';
            }

            function loadViewVendorOrderUnitsData() {
                if ($stateParams.vendorId) {
                    $scope.M_ViewVOUs.vendorId = $stateParams.vendorId;
                    $scope.M_UO.vendorId = $stateParams.vendorId;
                    getVendorDetails();
                    createDefaultSortJson();
                    setDefaultSortJsonFieldsForActiveOrders();

                    if ($stateParams.ViewVendorOrderUnitsParams && $stateParams.ViewVendorOrderUnitsParams.subTab === 'OrderHistory') {
                        getOrderHistoryForVendor();
                    } else {
                        getActiveOrderListForVendor();
                    }
                } else if ($rootScope.ViewVendorOrderUnitsParams && $rootScope.ViewVendorOrderUnitsParams.vendorId) {
                    $state.go('UnitOrdering.ViewVendorOrderUnits', {
                        'vendorId': $rootScope.ViewVendorOrderUnitsParams.vendorId
                    });
                }
            }

            function getVendorDetails() {
                if ($scope.M_ViewVOUs.vendorId) {
                    var successJson = {
                        'calleeMethodName': 'getVendorDetails'
                    };
                    UnitOrderingService.getVendorDetails($scope.M_ViewVOUs.vendorId).then(new success(successJson).handler, new error().handler);
                }
            }

            $scope.F_ViewVOUs.sortUnitsByColumnHeadings = function (gridName, columnHeaderName) {
                var sortJson = {};

                Object.keys($scope.M_ViewVOUs.UnitsListSortJson).forEach(function (key) {

                    if (key === columnHeaderName && $scope.M_ViewVOUs.UnitsListSortJson[key].isSortingApplied) {
                        if ($scope.M_ViewVOUs.UnitsListSortJson[key].sortOrder === 'ASC') {
                            $scope.M_ViewVOUs.UnitsListSortJson[key].sortOrder = 'DESC';
                        } else {
                            $scope.M_ViewVOUs.UnitsListSortJson[key].sortOrder = 'ASC';
                        }
                    } else if (key === columnHeaderName && !$scope.M_ViewVOUs.UnitsListSortJson[key].isSortingApplied) {
                        $scope.M_ViewVOUs.UnitsListSortJson[key].isSortingApplied = true;
                        $scope.M_ViewVOUs.UnitsListSortJson[key].sortOrder = 'ASC';
                    } else {
                        $scope.M_ViewVOUs.UnitsListSortJson[key].isSortingApplied = false;
                        $scope.M_ViewVOUs.UnitsListSortJson[key].sortOrder = '';
                    }
                });

                sortJson.FieldLabel = $scope.M_ViewVOUs.UnitsListSortJson[columnHeaderName].fieldName;
                sortJson.SortingOrder = $scope.M_ViewVOUs.UnitsListSortJson[columnHeaderName].sortOrder;

                if (gridName === 'ActiveOrders') {
                    if ($scope.M_ViewVOUs.ActiveOrderList.length > 1) {
                        $scope.M_UO.isViewChanged = true;
                        $scope.M_UO.isLoading = true;
                        applySortingOnActiveOrderList(sortJson);
                    }

                } else if (gridName === 'OrderHistory') {
                    if ($scope.M_ViewVOUs.OrderHistoryList.length > 1) {
                        $scope.M_UO.isViewChanged = true;
                        $scope.M_UO.isLoading = true;
                        applySortingOnOrderHistoryList(sortJson);
                    }
                }
            }

            function applySortingOnActiveOrderList(sortJson) {
                var successJson = {
                    'calleeMethodName': 'applySortingOnActiveOrderList'
                };
                UnitOrderingService.applySortingOnActiveOrderList($scope.M_ViewVOUs.vendorId, angular.toJson(sortJson)).then(new success(successJson).handler, new error().handler);
            }

            function applySortingOnOrderHistoryList(sortJson) {
                var successJson = {
                    'calleeMethodName': 'applySortingOnOrderHistoryList'
                };
                UnitOrderingService.applySortingOnOrderHistoryList($scope.M_ViewVOUs.vendorId, angular.toJson(sortJson)).then(new success(successJson).handler, new error().handler);
            }

            function getActiveOrderListForVendor() {
                if ($scope.M_ViewVOUs.vendorId) {
                    var successJson = {
                        'calleeMethodName': 'getActiveOrderListForVendor'
                    };
                    UnitOrderingService.getActiveOrderListForVendor($scope.M_ViewVOUs.vendorId).then(new success(successJson).handler, new error().handler);
                }
            }

            $scope.F_ViewVOUs.changeView = function (viewName) {
                $scope.M_UO.isViewChanged = true;
                $scope.M_UO.isLoading = true;
                createDefaultSortJson();
                if (viewName === 'ActiveOrders') {
                    setDefaultSortJsonFieldsForActiveOrders();
                    getActiveOrderListForVendor();
                } else if (viewName === 'OrderHistory') {
                    setDefaultSortJsonFieldsForOrderHistory();
                    getOrderHistoryForVendor();
                }
            }

            function getOrderHistoryForVendor() {
                if ($scope.M_ViewVOUs.vendorId) {
                    var successJson = {
                        'calleeMethodName': 'getOrderHistoryForVendor'
                    };
                    UnitOrderingService.getOrderHistoryForVendor($scope.M_ViewVOUs.vendorId).then(new success(successJson).handler, new error().handler);
                }
            }
            $scope.M_ViewVOUs.COExists = false;
            $scope.F_ViewVOUs.openActiveOrderDeleteConfirmationPopup = function (activeOrderId, deletableElementId, CoNumber, DealItemId) {
                $scope.F_ViewVOUs.deletableActiveOrderId = activeOrderId;
                $scope.F_ViewVOUs.deletableElementId = deletableElementId;
                if(CoNumber && DealItemId) {
                	$scope.M_ViewVOUs.COExists = true;
                } else {
                	$scope.M_ViewVOUs.COExists = false;
                }
                addBackdrop();
                var toppopupposition = (angular.element("#" + deletableElementId + " .trDeleteBtn ").offset().top) + 20;
                var leftpopupposition = (angular.element("#" + deletableElementId + " .trDeleteBtn ").offset().left) + 5;
                angular.element(".deleteConfiramtionPopup").css("left", leftpopupposition + 'px');
                angular.element(".deleteConfiramtionPopup").css("top", toppopupposition + 'px');
                setTimeout(function () {
                    angular.element(".deleteConfiramtionPopup").css("visibility", 'visible');
                    angular.element(".deleteConfiramtionPopup").css("opacity", 1);
                }, 100);
            }

            function addBackdrop() {
                setTimeout(function () {
                    var template = '<div class = "bp-modal-backdrop unitOrderingBackdrop" ng-click = "F_ViewVOUs.hideDeleteConfirmationPopup()"></div>';
                    template = $compile(angular.element(template))($scope);
                    angular.element("#viewVendorOrderUnitsWrapperId").prepend(template);
                }, 500);
            }

            $scope.F_ViewVOUs.hideDeleteConfirmationPopup = function () {
                angular.element(".deleteConfiramtionPopup").css("visibility", 'hidden');
                angular.element(".deleteConfiramtionPopup").css("opacity", 0);
                angular.element("#viewVendorOrderUnitsWrapperId").find('.bp-modal-backdrop').remove();
                setTimeout(function() {
                	$scope.M_ViewVOUs.COExists = false;
                },50);
            }

            $scope.F_ViewVOUs.removeActiveOrder = function () {
                var successJson = {
                    'calleeMethodName': 'removeActiveOrder',
                    'elementId': $scope.F_ViewVOUs.deletableElementId
                };
                createDefaultSortJson();
                setDefaultSortJsonFieldsForActiveOrders();
                UnitOrderingService.removeOrderUnit($scope.F_ViewVOUs.deletableActiveOrderId, $scope.M_ViewVOUs.vendorId).then(new success(successJson).handler, new error().handler);
            }

            $scope.F_ViewVOUs.enableReceivedUnitsBtn = function () {
                var enableReceivedUnitsBtnFlag = false;
                var selectedActiveOrdersCount = 0;
                $scope.M_ViewVOUs.selectedActiveOrdersCount = '';
                for (var i = 0; i < $scope.M_ViewVOUs.ActiveOrderList.length; i++) {
                    if ($scope.M_ViewVOUs.ActiveOrderList[i].isSelected == true) {
                        enableReceivedUnitsBtnFlag = true;
                        selectedActiveOrdersCount++;
                    }
                }

                $scope.M_ViewVOUs.selectedActiveOrdersCount = selectedActiveOrdersCount + ' Unit';
                if (selectedActiveOrdersCount > 1) {
                    $scope.M_ViewVOUs.selectedActiveOrdersCount = $scope.M_ViewVOUs.selectedActiveOrdersCount + 's';
                }
                return enableReceivedUnitsBtnFlag;
            }

            $scope.F_ViewVOUs.changeActiveOrderSelectedStatus = function (index) {
                $scope.M_ViewVOUs.ActiveOrderList[index].isSelected = !$scope.M_ViewVOUs.ActiveOrderList[index].isSelected;
                $scope.M_ViewVOUs.enableReceivedUnitsBtnFlag = $scope.F_ViewVOUs.enableReceivedUnitsBtn();
            }

            loadViewVendorOrderUnitsData();
        }
    ])
});