define(['Routing_AppJs_PK', 'ViewLabourServices', 'DirPagination'], function (Routing_AppJs_PK, ViewLabourServices, DirPagination) {
    var injector = angular.injector(['ui-notification', 'ng']);

    Routing_AppJs_PK.controller('ViewLabourCtrl', ['$scope', '$q', '$rootScope', '$stateParams', '$state', 'LabourInfoService', '$translate', function ($scope, $q, $rootScope, $stateParams, $state, LabourInfoService, $translate) {
        var Notification = injector.get("Notification");

        $scope.viewLabour = {};
        $scope.viewLabour.isSearchToAddVisible = false;
        $scope.viewLabour.activeSidepanelink = '#ViewLabourInfoSection';

        angular.element(document).off("scroll");
        angular.element(document).on("scroll", function () {
            $scope.viewLabour.onScroll();
        });

        $scope.viewLabour.sidepanelLink = function (event, relatedContent) {
            event.preventDefault();
            angular.element(document).off("scroll");
            var target = angular.element(angular.element(event.target.closest('a'))).attr("href");
            angular.element('html, body').stop().animate({
                scrollTop: angular.element(target).offset().top - 120
            }, 500, function () {
                angular.element(document).on("scroll", function () {
                    $scope.viewLabour.onScroll();
                });
                $scope.viewLabour.onScroll();
            });
        }

        $scope.viewLabour.onScroll = function () {
            if ($state.current.name === 'ViewLabour') {
                var activeSidepanelink;
                var scrollPos = angular.element(document).scrollTop();

                if (isElementDefined('#ViewLabourInfoSection') && (scrollPos < angular.element('#ViewLabourInfoSection').position().top + angular.element('#ViewLabourInfoSection').height() + 50)) {
                    activeSidepanelink = '#ViewLabourInfoSection';
                } else {
                    if ($scope.viewLabour.ActiveOrderList != undefined && $scope.viewLabour.ActiveOrderList.length != 0) {
                        if (isElementDefined('#ViewLabourRelatedSection') && (scrollPos < angular.element('#ViewLabourRelatedSection').position().top + angular.element('#ViewLabourRelatedSection').height() + 50)) {
                            activeSidepanelink = '#ViewLabourRelatedSection';
                        } else {
                            activeSidepanelink = '#ViewLabourRelatedSection';
                        }
                    } else {
                        activeSidepanelink = '#ViewLabourInfoSection';
                    }
                }

                $scope.viewLabour.activeSidepanelink = activeSidepanelink;
                if (!$scope.$$phase) {
                    $scope.$digest();
                }
            }
        }

        $scope.viewLabour.displaySections = {
            'Info': true,
            'Related': true,
            'Statistics': true,
            'ActivityStream': true
        };

        $scope.viewLabour.helpTooltips = {
            Info: $translate.instant('Helptext_info_section'),
            Info_Gen: $translate.instant("Helptext_general_info"),
            Description: $translate.instant("Helptext_labor_description"),
            Related: $translate.instant("Helptext_related_section"),
            Related_Gen: $translate.instant("Helptext_related_info_labor"),
            Statistics: $translate.instant("Helptext_statistics_section"),
            Statistics_Vital: $translate.instant("Helptext_vital_stats_labor"),
            Statistics_Tele: $translate.instant("Helptext_telementry_stats_labor"),
            Activity_Stream: $translate.instant("Helptext_activity_stream_section"),
            Activity_Stream_Gen: $translate.instant("Helptext_activity_stream_info_labor")
        };

        var sortOrderMap = {
            "ASC": "DESC",
            "DESC": ""
        };

        $scope.viewLabour.ActiveOrderPageSortAttrsJSON = {};

        /**
         * Method to set default page sort attributes JSON
         */
        $scope.viewLabour.setDefaultPageSortAttrs = function () {
            $scope.viewLabour.ActiveOrderPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "LastModifiedDate",
                    SortDirection: "DESC"
                }]
            };
            try {
                $scope.viewLabour.ActiveOrderPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size; /*'{!JSENCODE(TEXT(Related_List_Page_Size))}'; */
            } catch (ex) {}

        }

        /**
         * Method to handle any updates in pagination controls
         */
        $scope.viewLabour.ActiveOrders_paginationControlsAction = function () {
            LabourInfoService.getLabourDetails($scope.viewLabour.labourId, $scope.viewLabour.ActiveOrderPageSortAttrsJSON).then(function (labourInfo) {
                $scope.viewLabour.ActiveOrderList = labourInfo.ActiveOrderList;
                setTimeout(function () {
                    $scope.viewLabour.ActiveOrderPageSortAttrsJSON.ChangesCount++;
                }, 10);
            }, function (errorSearchResult) {});
        }

        /**
         * Method to load all page data on load
         */
        $scope.viewLabour.LoadLabourData = function () {
            $scope.viewLabour.labourId = ($scope.viewLabour.labourId == null) ? $stateParams.Id : $scope.viewLabour.labourId;
            $scope.viewLabour.setDefaultPageSortAttrs();

            if ($scope.viewLabour.labourId != null && $scope.viewLabour.labourId != "") {
                LabourInfoService.getLabourDetails($scope.viewLabour.labourId, $scope.viewLabour.ActiveOrderPageSortAttrsJSON)
                    .then(function (successfulSearchResult) {
                        $scope.viewLabour.LabourRecord = successfulSearchResult.LabourRecord;
                        $scope.viewLabour.ActiveOrderList = successfulSearchResult.ActiveOrderList;
                        $scope.viewLabour.TotalActiveOrder = successfulSearchResult.TotalActiveOrder;
                        $scope.viewLabour.SuppliesDetailList = successfulSearchResult.SuppliesDetailList;
                        $scope.viewLabour.hasShopSuppliesCalculationMethod = successfulSearchResult.LabourRecord.hasShopSuppliesCalculationMethod;
                        setTimeout(function () {
                            $scope.viewLabour.ActiveOrderPageSortAttrsJSON.ChangesCount++;
                        }, 100);
                    }, function (errorSearchResult) {
                        responseData = errorSearchResult;
                        Notification.error($translate.instant('Generic_Error'));
                    });
            }
        }

        $scope.viewLabour.createNewLabour = function () {
            $rootScope.$broadcast('AddLabourEvent');
        }

        $scope.viewLabour.editLabour = function () {
            var labourRelated_Json = {
                labourRecord: $scope.viewLabour.LabourRecord
            };
            loadState($state, 'ViewLabour.EditLabour', {
                EditLabourParams: labourRelated_Json
            });
        }

        $scope.labourRecordSaveCallback = function (labourId) {
            if ($scope.viewLabour.labourId.substring(0, 15) == labourId.substring(0, 15)) {
                $scope.viewLabour.labourId = labourId;
                $scope.viewLabour.LoadLabourData();
            }
        }
        $scope.viewLabour.LoadLabourData();
    }])
});