define(['Routing_AppJs_PK', 'DealerLookUpServices'], function (Routing_AppJs_PK, DealerLookUpServices) {
    Routing_AppJs_PK.controller('DealerLookupCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', '$translate', 'DealerLookUpService', function ($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, $translate, DealerLookUpService) {
        $scope.M_DealerLookup = $scope.M_DealerLookup || {};
        $scope.F_DealerLookup = $scope.F_DealerLookup || {};
        $scope.M_DealerLookup.showDropDown = false;
        $scope.M_DealerLookup.selectedDealerLookUpJSON = {}
        $scope.M_DealerLookup.currentDropDownIndex = -1;
        $scope.F_DealerLookup.selectDealerLookUp = function (dealerRec) {
            $scope.M_DealerLookup.selectedDealerLookUpJSON = dealerRec;
            $scope.M_DealerLookup.searchDealerName = dealerRec.Company;
            $scope.M_DealerLookup.showDropDown = false;
        }
        $scope.F_DealerLookup.keyPressNavigationOnDropdownElements = function (event, dropdownDivId, templateName, dropdownList) {
            var keyCode = event.which ? event.which : event.keyCode;
            var tempList = angular.copy(dropdownList);
            var dropDownDivId = '#' + dropdownDivId;
            var idSubStr = '';
            var totalRecordsToTraverse = 0;
            if (tempList) {
                totalRecordsToTraverse += tempList.length;
            }
            if (keyCode == 40 && totalRecordsToTraverse > 0) {
                if (totalRecordsToTraverse - 1 > $scope.M_DealerLookup.currentDropDownIndex) {
                    $scope.M_DealerLookup.currentDropDownIndex++;
                    if (templateName == 'dealer') {
                        idSubStr = '#dealer_';
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_DealerLookup.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.M_DealerLookup.currentDropDownIndex > 0) {
                    $scope.M_DealerLookup.currentDropDownIndex--;
                    if (templateName == 'dealer') {
                        idSubStr = '#dealer_';
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_DealerLookup.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode == 13 && $scope.M_DealerLookup.currentDropDownIndex !== -1) {
                if (templateName == 'dealer') {
                    $scope.F_DealerLookup.selectDealerLookUp(tempList[$scope.M_DealerLookup.currentDropDownIndex]);
                }
                $scope.M_DealerLookup.currentDropDownIndex = -1;
            }
        }
        $scope.F_DealerLookup.removeDealerSElected = function() {
            $scope.M_DealerLookup.selectedDealerLookUpJSON = {};
            $scope.M_DealerLookup.searchDealerName = '';
        }
        function getDealerData() {
            DealerLookUpService.getDealer().then(function (Result) {
                $scope.M_DealerLookup.dealerLookUpList = Result;
                console.log(Result);
                console.log("Result");

            }, function (errorMessage) {
            });
        }
        getDealerData();
    }])
});