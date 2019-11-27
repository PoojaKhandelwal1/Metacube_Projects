define(['Routing_AppJs_PK', 'ViewFeeServices', 'DirPagination'], function (Routing_AppJs_PK, ViewFeeServices, DirPagination) {

    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('ViewFeeCtrl', ['$scope', '$q', '$rootScope', '$stateParams', '$state', 'FeeInfoService', '$translate', function ($scope, $q, $rootScope, $stateParams, $state, FeeInfoService, $translate) {
        var Notification = injector.get("Notification");

        $scope.viewFee = {};
        $scope.viewFee.currentPageSize = 1;
        $scope.viewFee.currentPageNumber = 1;
        $scope.viewFee.totalPages = 10;
        $scope.viewFee.sortJson = [];
        $scope.viewFee.searchedResult;
        $scope.viewFee.isSearchToAddVisible = false;
        $scope.viewFee.ActiveOrderPageSortAttrsJSON = {};

        $scope.viewFee.setDefaultPageSortAttrs = function () {
            $scope.viewFee.ActiveOrderPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "LastModifiedDate",
                    SortDirection: "DESC"
                }]
            };
            try {
                $scope.viewFee.ActiveOrderPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size; 
            } catch (ex) {}
        }

        $scope.viewFee.feeActiveOrder_paginationControlsAction = function () {
            FeeInfoService.getFeeDetails($scope.viewFee.feeId, $scope.viewFee.ActiveOrderPageSortAttrsJSON)
                .then(function (feeInfo) {
                    $scope.viewFee.ActiveOrderList = feeInfo.ActiveOrderList;
                    $scope.viewFee.ShowContent = true;
                    setTimeout(function () {
                        $scope.viewFee.ActiveOrderPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.viewFee.ShowContent = false;
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
        }

        $scope.viewFee.feeId = $stateParams.Id;
        $scope.viewFee.activeSidepanelink = '#ViewFeeInfoSection';
        angular.element(document).off("scroll");
        angular.element(document).on("scroll", function () {
            $scope.viewFee.onScroll();
        });

        $scope.viewFee.sidepanelLink = function (event, relatedContent) {
            event.preventDefault();
            angular.element(document).off("scroll");
            var target = angular.element(angular.element(event.target.closest('a'))).attr("href");
            angular.element('html, body').stop().animate({
                scrollTop: angular.element(target).offset().top - 120
            }, 500, function () {
                angular.element(document).on("scroll", function () {
                    $scope.viewFee.onScroll();
                });
                $scope.viewFee.onScroll();
            });
        }

        $scope.viewFee.onScroll = function () {
            if ($state.current.name === 'ViewFee') {
                var activeSidepanelink;
                var scrollPos = angular.element(document).scrollTop();

                if (isElementDefined('#ViewFeeInfoSection') && (scrollPos < angular.element('#ViewFeeInfoSection').position().top + angular.element('#ViewFeeInfoSection').height() + 50)) {
                    activeSidepanelink = '#ViewFeeInfoSection';
                } else {
                    if (($scope.viewFee.ActiveOrderList != undefined && $scope.viewFee.ActiveOrderList.length != 0) || ($scope.viewFee.LinkedFeeList != undefined && $scope.viewFee.LinkedFeeList.length != 0)) {
                        if (isElementDefined('#ViewFeeRelatedSection') && (scrollPos < angular.element('#ViewFeeRelatedSection').position().top + angular.element('#ViewFeeRelatedSection').height() + 50)) {

                            activeSidepanelink = '#ViewFeeRelatedSection';
                        } else {
                            activeSidepanelink = '#ViewFeeRelatedSection';
                        }
                    } else {
                        activeSidepanelink = '#ViewFeeInfoSection';
                    }
                }
                $scope.viewFee.activeSidepanelink = activeSidepanelink;
                if (!$scope.$$phase) {
                    $scope.$digest();
                }
            }
        }

        $scope.viewFee.editFeeDetails = function () {
            var feeId = $scope.viewFee.feeId;
            var feeRelated_Json = {
                Id: feeId
            };
            loadState($state, 'ViewFee.AddEditFee', {
                feeParams: feeRelated_Json
            });
        }

        $scope.viewFee.displaySections = {
            'Info': true,
            'Related': true,
            'Statistics': true,
            'ActivityStream': true
        };

        $scope.viewFee.helpTooltips = {
            Info: "Info section",
            Info_Gen: "General info for Fee",
            Description: "Fee description",
            Related: "Related section",
            Related_Gen: "Related info for Fee",
            Statistics: "Statistics section",
            Statistics_Vital: "Vital Stats for Fee",
            Statistics_Tele: "Telementry Stats for Fee",
            Activity_Stream: "Activity Stream section",
            Activity_Stream_Gen: "Activity Stream info for Fee"
        };

        $scope.viewFee.LoadFeeData = function () {
            $scope.viewFee.setDefaultPageSortAttrs();
            FeeInfoService.getFeeDetails($scope.viewFee.feeId, $scope.viewFee.ActiveOrderPageSortAttrsJSON)
                .then(function (feeInfo) {
                    $scope.viewFee.feeInfo = feeInfo.FeeRec;
                    $scope.viewFee.TotalActiveOrder = feeInfo.TotalActiveOrder;
                    $scope.viewFee.ActiveOrderList = feeInfo.ActiveOrderList;
                    $scope.viewFee.LinkedFeeList = feeInfo.LinkedFeeList;
                    $scope.viewFee.ShowContent = true;
                    setTimeout(function () {
                        $scope.viewFee.ActiveOrderPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.viewFee.ShowContent = false;
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
        }

        $scope.viewFee.createNewFee = function () {
            $rootScope.$broadcast('AddFeeEvent');
        }

        $scope.feeRecordSaveCallback = function (FeeHeaderRec) {
            if ($scope.viewFee.feeId.substring(0, 15) == FeeHeaderRec.Id.substring(0, 15)) {
                $scope.viewFee.feeInfo = FeeHeaderRec;
            }
        }
        $scope.viewFee.LoadFeeData();
    }])
});