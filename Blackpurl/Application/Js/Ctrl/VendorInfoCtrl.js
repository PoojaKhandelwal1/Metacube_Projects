define(['Routing_AppJs_PK', 'VendorInfoServices', 'tel'], function(Routing_AppJs_PK, VendorInfoServices, tel) {
    Routing_AppJs_PK.controller('vendorInfoCtrl', ['$scope', 'VendorInfoService', function($scope, VendorInfoService) {
        if ($scope.vendorInfo == undefined) {
            $scope.vendorInfo = {};
            $scope.vendorInfo.VendorDetailRec = {};
            $scope.vendorInfo.VendorRelatedInfo = {};
            $scope.vendorInfo.VendorOverlay = [];
        }
        $scope.$on('VendorInfoPopUpEvent', function(event, vendorId) {
            $scope.vendorInfo.VendorDetailRec = {};
            $scope.vendorInfo.VendorRelatedInfo = {};
            $scope.vendorInfo.VendorOverlay = [];
            $scope.vendorInfo.loadVendorInfo(vendorId);
        });
        $scope.vendorInfo.hidePopup = function() {
            angular.element('.Vendor-info-overlay').hide();
        }
        $scope.vendorInfo.openHourpopup = function(IdVal) {
            angular.element("#" + IdVal).show();
        }
        $scope.vendorInfo.loadVendorInfo = function(vendorId) {
            VendorInfoService.getVendorInfo(vendorId).then(function(vendorRecord) {
                if (vendorRecord.VendorDetailRec != undefined && vendorRecord.VendorRelatedInfo != undefined) {
                    $scope.vendorInfo.VendorDetailRec = vendorRecord.VendorDetailRec;
                    $scope.vendorInfo.VendorRelatedInfo = vendorRecord.VendorRelatedInfo;
                    if ($scope.vendorInfo.VendorDetailRec.PreferredPhone == "") {
                        if ($scope.vendorInfo.VendorDetailRec.HomeNumber != "") {
                            $scope.vendorInfo.VendorDetailRec.PreferredPhone = $scope.vendorInfo.VendorDetailRec.HomeNumber;
                        } else if ($scope.vendorInfo.VendorDetailRec.WorkNumber != "") {
                            $scope.vendorInfo.VendorDetailRec.PreferredPhone = $scope.vendorInfo.VendorDetailRec.WorkNumber;
                        } else if ($scope.vendorInfo.VendorDetailRec.Mobile != "") {
                            $scope.vendorInfo.VendorDetailRec.PreferredPhone = $scope.vendorInfo.VendorDetailRec.Mobile;
                        }
                    }
                    if ($scope.vendorInfo.VendorDetailRec.PreferredEmail == "") {
                        if ($scope.vendorInfo.VendorDetailRec.HomeEmail != "") {
                            $scope.vendorInfo.VendorDetailRec.PreferredEmail = $scope.vendorInfo.VendorDetailRec.HomeEmail;
                        } else if ($scope.vendorInfo.VendorDetailRec.WorkEmail != "") {
                            $scope.vendorInfo.VendorDetailRec.PreferredEmail = $scope.vendorInfo.VendorDetailRec.WorkEmail;
                        } else if ($scope.vendorInfo.VendorDetailRec.OtherEmail != "") {
                            $scope.vendorInfo.VendorDetailRec.PreferredEmail = $scope.vendorInfo.VendorDetailRec.OtherEmail;
                        }
                    }
                }
            }, function(errorSearchResult) {
                
            });
        }
    }])
});