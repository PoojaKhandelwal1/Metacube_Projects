define(['Routing_AppJs_PK', 'PrintServiceWorkSheetPopUpServices'], function(Routing_AppJs_PK, PrintServiceWorkSheetPopUpServices) {
    $(document).ready(function() {
        hideFlyout = function() {
            $('#PrintServiceWorksheetPopUp').hide();
        }
    });
    Routing_AppJs_PK.controller('PrintServiceWorkSheetPopUpCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$state', '$stateParams', 'PrintServiceWorksheetService', 'SOPrintWorkSheetService', function($scope, $timeout, $q, $rootScope, $state, $stateParams, PrintServiceWorksheetService, SOPrintWorkSheetService) {
        var origin = window.location.origin;
        if ($scope.PrintServiceWorksheetServicePopUp == undefined) {
            $scope.PrintServiceWorksheetServicePopUp = {};
            $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel = {};
        }
        $scope.$on('PrintServiceWorksheetPopUpEvent', function(event, COHeaderId) {
            $scope.PrintServiceWorksheetServicePopUp.COHeaderId = COHeaderId;
            $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel = {};
            $scope.PrintServiceWorksheetServicePopUp.loadData(COHeaderId);
        });
        $scope.PrintServiceWorksheetServicePopUp.updateCheckBoxForUnit = function(rowNumber) {
            $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[rowNumber].IsUnitSelected = !$scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[rowNumber].IsUnitSelected;
            if (!$scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[rowNumber].IsUnitSelected) {
                var i;
                for (i = 0; i < $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[rowNumber].SOInfoWrapperList.length; i++) {
                    $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[rowNumber].SOInfoWrapperList[i].IsSOHeaderSelected = false;
                }
            } else {
                var i;
                for (i = 0; i < $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[rowNumber].SOInfoWrapperList.length; i++) {
                    $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[rowNumber].SOInfoWrapperList[i].IsSOHeaderSelected = true;
                }
            }
        }
        $scope.PrintServiceWorksheetServicePopUp.updateCheckBoxForEachSO = function(rowNumber, parentRowNumber) {
            $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[parentRowNumber].SOInfoWrapperList[rowNumber].IsSOHeaderSelected = !$scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[parentRowNumber].SOInfoWrapperList[rowNumber].IsSOHeaderSelected;
            var i, childSelected;
            for (i = 0; i < $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[parentRowNumber].SOInfoWrapperList.length; i++) {
                if ($scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[parentRowNumber].SOInfoWrapperList[i].IsSOHeaderSelected) {
                    childSelected = true;
                    $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[parentRowNumber].IsUnitSelected = true;
                    break;
                } else {
                    childSelected = false;
                }
            }
            if (!childSelected) {
                $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[parentRowNumber].IsUnitSelected = false;
            }
        }
        $scope.PrintServiceWorksheetServicePopUp.closePopup = function() {
            angular.element('#PrintServiceWorksheetPopUp').modal('hide');
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.PrintServiceWorksheetServicePopUp.disablePrintButton = function() {
            var i, parentDeselected;
            for (i = 0; i < $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel.length; i++) {
                if (!$scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[i].IsUnitSelected) {
                    parentDeselected = true;
                } else {
                    parentDeselected = false;
                    break;
                }
            }
            if (parentDeselected) {
                return true;
            } else {
                return false;
            }
        }
        $scope.PrintServiceWorksheetServicePopUp.printServiceWorkSheet = function(COHeaderId, IsPrintPreview) {
            for (var i = 0; i < $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel.length; i++) {
                $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel[i].IsPrintPreview = IsPrintPreview;
            }
            var saveWorkseetSelectionJson = JSON.stringify($scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel);
            SOPrintWorkSheetService.getSaveWorkseetSelectionJson(COHeaderId, saveWorkseetSelectionJson).then(function(result) {
                window.open(origin + "/apex/ServiceWorkSheet?id=" + COHeaderId, "", "width=1200, height=600");
                $scope.PrintServiceWorksheetServicePopUp.closePopup();
            }, function(errorSearchResult) {});
        }
        $scope.PrintServiceWorksheetServicePopUp.loadData = function(COHeaderId) {
            PrintServiceWorksheetService.getServiceWorksheetPrintDetail(COHeaderId).then(function(SORecord) {
                $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel = SORecord;
                setTimeout(function() {
                    angular.element('#PrintServiceWorksheetPopUp').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                }, 100);
            }, function(errorSearchResult) {});
        }
        $scope.PrintServiceWorksheetServicePopUp.openPrintServiceWorkSheetPopup = function() {
            $scope.PrintServiceWorksheetServicePopUp.COHeaderId = $stateParams.PrintServiceWorksheetParams.COHeaderId;
            $scope.PrintServiceWorksheetServicePopUp.PrintServiceWorksheetServiceModel = {};
            $scope.PrintServiceWorksheetServicePopUp.loadData($stateParams.PrintServiceWorksheetParams.COHeaderId);
        }
        $scope.PrintServiceWorksheetServicePopUp.openPrintServiceWorkSheetPopup();
    }])
});