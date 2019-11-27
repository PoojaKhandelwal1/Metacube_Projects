define(['Routing_AppJs_PK', 'AddEditTaxExemptionServices', 'underscore_min'], function (Routing_AppJs_PK, AddEditTaxExemptionServices, underscore_min) {

    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditTaxExemptionCtrl', ['$scope', '$q', '$rootScope', '$state', '$stateParams', 'TaxExemptionService', function ($scope, $q, $rootScope, $state, $stateParams, TaxExemptionService) {
        var Notification = injector.get("Notification");

        $scope.TaxExemptionModel = {};
        $scope.TaxExemptionModel.TaxExemptionPageSortAttrsJSON = {
            ChangesCount: 0,
            CurrentPage: 1,
            PageSize: 10,
            Sorting: [{
                FieldName: "ItemDesc",
                SortDirection: "ASC"
            }]
        };
        try {
            $scope.TaxExemptionModel.TaxExemptionPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
        } catch (ex) {}

        $scope.TaxExemptionModel.CancelTaxExemptionPopup = function () {
            angular.element('#TaxExemptionPopup').modal('hide');
            setTimeout(function () {
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }, 1000);
        }
        $scope.TaxExemptionModel.disableSaveButton = false;		

        $scope.TaxExemptionModel.saveTaxExemptionRecords = function () {
            if ($scope.TaxExemptionModel.disableSaveButton) {
                return;
            }
            $scope.TaxExemptionModel.disableSaveButton = true;
            TaxExemptionService.saveTaxExeptionList($scope.TaxExemptionModel.parentObjectId,
                    JSON.stringify($scope.TaxExemptionModel.TaxExemptionList),
                    JSON.stringify($scope.TaxExemptionModel.TaxExemptionPageSortAttrsJSON))
                .then(function (parentTaxExemptionList) {
                    if ($state.current.name === 'ViewCustomer.TaxExemption') {
                        $scope.$emit('TaxExemptionCallback', parentTaxExemptionList);
                    } else if ($state.current.name === 'ViewVendor.TaxExemption') {
                        $scope.$parent.ViewVendorRelatedListModal.TaxExemptionCallback(parentTaxExemptionList);
                    }
                    $scope.TaxExemptionModel.disableSaveButton = false;
                    $scope.TaxExemptionModel.CancelTaxExemptionPopup();
                }, function (errorSearchResult) {
                    $scope.TaxExemptionModel.disableSaveButton = false;
                });
        }

        $scope.$on('TaxExemptionPopupEvent', function (event, args) {
            $scope.TaxExemptionModel.parentObjectId = args;
            TaxExemptionService.getAllActiveSalesTax($scope.TaxExemptionModel.parentObjectId).then(function (TaxExemptionList) {
                $scope.TaxExemptionModel.TaxExemptionList = TaxExemptionList;
                angular.element('#TaxExemptionPopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, function (errorSearchResult) {});
        });

        $scope.TaxExemptionModel.openTaxExemptionPopup = function () {
            $scope.TaxExemptionModel.disableSaveButton = false;
            $scope.TaxExemptionModel.parentObjectId = $stateParams.TaxExemptionParams.parentObjectId;

            TaxExemptionService.getAllActiveSalesTax($scope.TaxExemptionModel.parentObjectId).then(function (TaxExemptionList) {
                $scope.TaxExemptionModel.TaxExemptionList = TaxExemptionList;
                setTimeout(function () {
                    angular.element('#TaxExemptionPopup').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                }, 1000);
            }, function (errorSearchResult) {});
        }

        $scope.TaxExemptionModel.openTaxExemptionPopup();
    }])
});