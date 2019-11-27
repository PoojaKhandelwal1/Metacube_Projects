define(['Routing_AppJs_PK', 'tel', 'dirNumberInput', 'AutoComplete'], function(Routing_AppJs_PK, tel, dirNumberInput, AutoComplete) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('SelectCustomerCtrl', ['$scope', '$rootScope', '$stateParams', '$state', function($scope, $rootScope, $stateParams, $state) {
        var Notification = injector.get("Notification");
        if ($scope.selectCustomer == undefined) {
            $scope.selectCustomer = {};
            $scope.selectCustomer.custModel = {};
        }
        $scope.selectCustomer.isVendor = false;
        $scope.selectCustomer.searchFieldName = 'Name';
        $scope.$on('autoCompleteSelectCustomerCallback', function(event, args) {
            var obejctType = args.ObejctType.toUpperCase();
            var searchResult = args.SearchResult;
            var validationKey = args.ValidationKey;
            if ($scope.selectCustomer.CustomerNameStr == $scope.selectCustomer.custModel.customerName) {
                return;
            } else if (searchResult == null) {
                $scope.selectCustomer.CustomerNameStr = "";
                $scope.selectCustomer.custModel.CustomerNameStr = "";
                $scope.selectCustomer.custModel.customerId = null;
                return;
            }
            var objectsMapping = [{
                CUSTOMER: {
                    Id: "CustomerId",
                    Name: "CustomerName",
                    selectMethod: $scope.selectCustomer.setCategoryRecordDataByForm
                },
                VENDOR: {
                    Id: "CustomerId",
                    Name: "CustomerName",
                    selectMethod: $scope.selectCustomer.setCategoryRecordDataByForm
                }
            }];
            if (objectsMapping[0][obejctType] != null) {
                $scope.selectCustomer.custModel[objectsMapping[0][obejctType]["Id"]] = searchResult.originalObject.Value;
                $scope.selectCustomer.custModel[objectsMapping[0][obejctType]["Name"]] = searchResult.originalObject.Name;
            }
            if (objectsMapping[0][obejctType].selectMethod != null) {
                objectsMapping[0][obejctType].selectMethod(searchResult);
            }
        });
        $scope.selectCustomer.setCategoryRecordDataByForm = function(searchResult) {
            $scope.selectCustomer.custModel.customerId = searchResult.originalObject.Id;
            $scope.selectCustomer.custModel.CustomerNameStr = searchResult.originalObject.Name;
            if (searchResult.originalObject.Id != null && $scope.selectCustomer.isOpenFromUnitOrdering) {
                $scope.$emit('selectedCustomerForUOCallback', $scope.selectCustomer.custModel.customerId);
            } else if (searchResult.originalObject.Id != null && $scope.selectCustomer.COHeaderIdOfQCS != null) {
                var idParams = {
                    customerId: $scope.selectCustomer.custModel.customerId,
                    Id: $scope.selectCustomer.COHeaderIdOfQCS
                };
                $scope.$emit('selectedCustomerForQCSCallback', $scope.selectCustomer.custModel.customerId);
                $scope.selectCustomer.COHeaderIdOfQCS = null;
                var previousStateName;
                var previousState_iDParams;
                if ($stateParams.myParams != undefined && $stateParams.myParams.A_View_StateName != undefined && $stateParams.myParams.A_View_StateName != '' && $stateParams.myParams.A_View_StateParams != undefined) {
                    previousStateName = $stateParams.myParams.A_View_StateName;
                    previousState_iDParams = $stateParams.myParams.A_View_StateParams.Id;
                } else {
                    previousStateName = $rootScope.$previousState.name;
                    previousState_iDParams = $rootScope.$previousStateParams.Id;
                }
                $scope.selectCustomer.MoveToState(previousStateName, {
                    Id: previousState_iDParams
                });
            } else if (searchResult.originalObject.Id != null) {
                if ($scope.selectCustomer.sellingType == 'Part Sale' || $scope.selectCustomer.sellingType == 'Service Order' || $scope.selectCustomer.sellingType == 'Unit Deal') {
                    var BpGlobalHeaderJson = {
                        customerId: $scope.selectCustomer.custModel.customerId,
                        AppointmentId: $scope.selectCustomer.AppointmentId
                    };
                    $scope.$emit('selectedCustomerCallback', BpGlobalHeaderJson);
                } else {
                    $scope.$emit('selectedCustomerCallback', $scope.selectCustomer.custModel.customerId);
                }
            }
            $scope.selectCustomer.closePopup();
        }
        $rootScope.$on('selectedCustomerOrder', function(event, args) {
            $scope.$emit('selectedCustomerCallback', args);
        });
        $scope.$on('SelectCustomerPopUpEvent', function(event, args) {
            $scope.selectCustomer.sellingType = args;
            if (args == 'Part Sale') {
                if (args.COHeaderId != null || args.COHeaderId != '' || args.COHeaderId != undefined) {
                    $scope.selectCustomer.COHeaderIdOfQCS = args.COHeaderId;
                }
                $scope.selectCustomer.isVendor = false;
                $scope.selectCustomer.selectesText = 'Select Parts Customer';
            } else if (args == 'Service Order') {
                $scope.selectCustomer.isVendor = false;
                $scope.selectCustomer.selectesText = 'Select Service Customer';
            } else if (args == 'Unit Deal') {
                $scope.selectCustomer.isVendor = false;
                $scope.selectCustomer.selectesText = 'Select Deal Customer';
            } else if (args == $Label.Vendor_Order || args == $Label.Vendor_Order_Receiving || args == $Label.Vendor_Order_Invoicing) {
                $scope.selectCustomer.isVendor = true;
                $scope.selectCustomer.selectesText = 'Select a Vendor';
            }
            $scope.selectCustomer.openCustomerSearchPopup();
        });
        $scope.$on('SelectCustomerPopUpFromQCSEvent', function(event, args) {
            $scope.selectCustomer.sellingType = args.type;
            $scope.selectCustomer.COHeaderIdOfQCS = args.COHeaderId;
            if (args.type == 'Part Sale') {
                $scope.selectCustomer.selectesText = 'Select Parts Customer';
            }
            $scope.selectCustomer.openCustomerSearchPopup();
        });
        $scope.selectCustomer.openCustomerSearchPopup = function() {
            $scope.selectCustomer.CustomerNameStr = "";
            $scope.selectCustomer.custModel.CustomerNameStr = "";
            $scope.selectCustomer.openPopup();
            setTimeout(function() {
                angular.element('#searchCustomer_Input').focus();
            }, 1500);
        }
        $scope.selectCustomer.openPopup = function() {
            angular.element('.controls').hide();
            angular.element('body').addClass("modal-open");
            setTimeout(function() {
                angular.element('#selectCustomerModel').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }
        $scope.selectCustomer.closePopup = function() {
            angular.element('#selectCustomerModel').modal('hide');
            hideModelWindow();
        }
        $scope.selectCustomer.closePopup1 = function() {
            $scope.selectCustomer.closePopup();
            var previousStateName;
            var previousState_iDParams;
            if ($stateParams.myParams != undefined && $stateParams.myParams.A_View_StateName != undefined && $stateParams.myParams.A_View_StateName != '' && $stateParams.myParams.A_View_StateParams != undefined) {
                previousStateName = $stateParams.myParams.A_View_StateName;
                previousState_iDParams = $stateParams.myParams.A_View_StateParams.Id;
            } else {
                previousStateName = $rootScope.$previousState.name;
                previousState_iDParams = $rootScope.$previousStateParams.Id;
            }
            loadState($state, previousStateName, {
                Id: previousState_iDParams
            });
        }
        $scope.selectCustomer.CreateCustomerFromCO = function() {
            $scope.selectCustomer.closePopup();
            setTimeout(function() {
                var AddCustomer_Json = {
                    isOpenFromSelectCustomerCustomer: 'isOpenFromSelectCustomerCustomer',
                    sellingType: $scope.selectCustomer.sellingType,
                    A_View_StateName: $rootScope.$previousState.name,
                    A_View_StateParams: $rootScope.$previousStateParams
                };
                var nextStateName;
                if ($state.current.name === 'CashSaleCO.SelectCustomer') {
                    nextStateName = 'CashSaleCO.AddCustomer';
                } else {
                    nextStateName = 'AddEditCustomer';
                    AddCustomer_Json.AppointmentId = $scope.selectCustomer.AppointmentId;
                }
                $scope.selectCustomer.MoveToState(nextStateName, {
                    myParams: AddCustomer_Json
                });
            }, 1000);
        }
        $scope.selectCustomer.CreateNewVendorFromVendorPopUp = function() {
            $scope.selectCustomer.closePopup();
            setTimeout(function() {
                var AddVendor_Json = {
                    isOpenFromSelectVendor: 'isOpenFromSelectVendor',
                    sellingType: $scope.selectCustomer.sellingType,
                    A_View_StateName: $rootScope.$previousState.name,
                    A_View_StateParams: $rootScope.$previousStateParams
                };
                $scope.selectCustomer.MoveToState('AddEditVendor', {
                    myParams: AddVendor_Json
                });
            }, 1000);
        }
        $scope.selectCustomer.MoveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
        $scope.selectCustomer.SelectCustomerPopUpEvent = function(args) {
            $scope.selectCustomer.sellingType = args.type;
            $scope.selectCustomer.AppointmentId = args.AppointmentId;
            $scope.selectCustomer.additionalFiltervalues = args.additionalFiltervalues;
            if (args.type == 'Part Sale') {
                if (args.COHeaderId != null || args.COHeaderId != '' || args.COHeaderId != undefined) {
                    $scope.selectCustomer.COHeaderIdOfQCS = args.COHeaderId;
                }
                $scope.selectCustomer.isVendor = false;
                $scope.selectCustomer.selectesText = 'Select Parts Customer';
            } else if (args.type == 'Service Order') {
                $scope.selectCustomer.isVendor = false;
                $scope.selectCustomer.selectesText = 'Select Service Customer';
            } else if (args.type == 'Unit Deal') {
                $scope.selectCustomer.isVendor = false;
                $scope.selectCustomer.selectesText = 'Select Deal Customer';
            } else if (args.type == $Label.Vendor_Order || args.type == $Label.Vendor_Order_Receiving || args.type == $Label.Vendor_Order_Invoicing || args.type == 'Return Vendor Order' || args.type == 'Unit Ordering') {
                $scope.selectCustomer.isVendor = true;
                $scope.selectCustomer.selectesText = 'Select a Vendor';
                if (args.isOpenFromUnitOrdering != null || args.isOpenFromUnitOrdering != '' || args.isOpenFromUnitOrdering != undefined) {
                    $scope.selectCustomer.isOpenFromUnitOrdering = args.isOpenFromUnitOrdering;
                }
            }
            $scope.selectCustomer.source = args.type;
            $scope.selectCustomer.openCustomerSearchPopup();
        }
        $scope.selectCustomer.openSelectCustomerPopup = function() {
            $scope.selectCustomer.SelectCustomerPopUpEvent($stateParams.myParams);
        }
        $scope.selectCustomer.openSelectCustomerPopup();
    }]);
});