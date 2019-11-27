define(['Routing_AppJs_PK', 'HomePageServices', 'JqueryUI', 'PriceFileImport_Select', 'whenScrolled'], function(Routing_AppJs_PK, HomePageServices, JqueryUI, PriceFileImport_Select, whenScrolled) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('HomePageCtrl', ['$scope', '$window', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', 'NewHomePageService', function($scope, $window, $timeout, $q, $rootScope, $sce, $stateParams, $state, NewHomePageService) {
        var Notification = injector.get("Notification");
        $scope.homePageModel = {};
        $scope.homePageModel.count = 1;
        $scope.homePageModel.currentDate = new Date();
        $scope.homePageModel.IsTrialOrg = $Global.IsTrialOrg;
        $scope.homePageModel.communityURL = $Global.communityURL;
        $scope.homePageModel.IsSystemSettingVisited = $Global.IsSystemSettingVisited;
        $scope.homePageModel.IsSampleDataAvailable = $Global.IsSampleDataAvailable;
        $scope.homePageModel.IsDP360SyncEnabled = $Global.IsDP360SyncEnabled;
        
        $scope.homePageModel.ActiveFilter = [];
        $scope.homePageModel.ActivityList = [];
        $scope.feedLoading = true;
        $scope.homePageModel.DefaultActivityListSize = 12;
        $scope.homePageModel.DefaultActivityActiveJSON = {
            Type: 'My Activity',
            RequiredNumberOfRecords: $scope.homePageModel.ActivityList.length + $scope.homePageModel.DefaultActivityListSize
        }
        $scope.homePageModel.WidgetPermissionMap = {
            'Invoices': ['Customer invoicing'],
            'Payments': ['Customer invoicing'],
            'New Customers': [],
            'New': ['Service job'],
            'Active': ['Service job'],
            'Completed': ['Service job'],
            'Active Orders': ['Vendor order'],
            'Active Receivings': ['Vendor receiving'],
            'Parts Needed': [],
            'Active Orders': ['Merchandise', 'Service job', 'Deal'],
            'Deposits': ['Merchandise', 'Service job', 'Deal'],
            'Balance Due': ['Merchandise', 'Service job', 'Deal']
        };
        $scope.homePageModel.WidgetPermissionMap1 = {
            'Store Summary': {
                'Invoices': ['Customer invoicing'],
                'Payments': ['Customer invoicing'],
                'New Customers': []
            },
            'Service Jobs': {
                'New': ['Service job'],
                'Active': ['Service job'],
                'Completed': ['Service job']
            },
            'Vendor Orders': {
                'Active Orders': ['Vendor order'],
                'Active Receivings': ['Vendor receiving'],
                'Parts Needed': []
            },
            'Customer Orders': {
                'Active Orders': ['Merchandise', 'Service job', 'Deal'],
                'Deposits': ['Merchandise', 'Service job', 'Deal'],
                'Balance Due': ['Merchandise', 'Service job', 'Deal']
            }
        };
        $scope.homePageModel.MockTabs = [{
            Name: 'first'
        }, {
            Name: 'second'
        }, {
            Name: 'three'
        }];
        $scope.homePageModel.MockCardBox = [{
            Name: 'first'
        }, {
            Name: 'second'
        }, {
            Name: 'three'
        }];
        $scope.homePageModel.setFontSizeForBlockData = function(value) {
            value = value.toString();
            var minCharLength = 8;
            var noOfChars = value.length;
            var fontSize = 20;
            var fontSizeValue = "20px";
            if (window.innerWidth >= 768 && window.innerWidth <= 1024) {
                fontSizeValue = (13 - (noOfChars - minCharLength)) + "px";
            } else if (noOfChars <= minCharLength) {
                fontSizeValue = fontSize + "px";
            } else {
                fontSizeValue = (fontSize - (noOfChars - minCharLength)) + "px";
            }
            return fontSizeValue;
        }
        $scope.homePageModel.NewCustomer = function() {
            loadState($state, 'AddEditCustomer');
        }
        $scope.homePageModel.NewVendor = function() {
            loadState($state, 'AddEditVendor');
        }
        $scope.homePageModel.NewPart = function() {
            loadState($state, 'AddEditPart');
        }
        $scope.homePageModel.createVOHeaderOrReceivingOrInvoicing = function(type) {
            $rootScope.$broadcast('CreateVendorPopUpEvent', type);
        }
        $scope.homePageModel.openHeader = function() {
            setTimeout(function() {
                angular.element('.createBtn').parent().addClass('open');
            }, 10);
        }
        $scope.homePageModel.openSearchBar = function() {
            if ($('#searchInputDiv').is(":visible")) {
                angular.element('#searchInputDiv').animate({
                    width: 'toggle'
                }, 350, function() {
                    angular.element('#searchIconOnly').show();
                    angular.element('#advanceSearchDropdownBtnSpan').show();
                    $scope.$emit('searchIconClickForCloseEvent1', "");
                });
            }
            if (!$('#searchInputDiv').is(":visible")) {
                $('#searchIconOnly').hide();
                angular.element('#advanceSearchDropdownBtnSpan').hide();
                $('#searchInputDiv').animate({
                    width: 'toggle'
                }, 350, function() {
                    $scope.$emit('searchIconClickEvent1', "");
                });
            }
        }
        $scope.homePageModel.to_trusted = function(html_code) {
            return $sce.trustAsHtml(html_code);
        }
        $scope.homePageModel.firstTimeLogin = function() {
            NewHomePageService.scheduleEmail().then(function(successResult) {}, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.homePageModel.cardFilder = function(filterName, cardIndex) {
            $scope.homePageModel.filtersJSON = [{
                Name: $scope.homePageModel.cardResponseResult[cardIndex].Name,
                BlockList: [{
                    FilterName: filterName
                }]
            }];
            for (j = 0; j < $scope.homePageModel.cardResponseResult[cardIndex].FilterList.length; j++) {
                if (filterName == $scope.homePageModel.cardResponseResult[cardIndex].FilterList[j].Name) {
                    $scope.homePageModel.cardResponseResult[cardIndex].FilterList[j].IsActive = true;
                } else {
                    $scope.homePageModel.cardResponseResult[cardIndex].FilterList[j].IsActive = false;
                }
            }
            NewHomePageService.getSummaryCardsDetails(angular.toJson($scope.homePageModel.filtersJSON)).then(function(successResult) {
                $scope.homePageModel.currentRefreshCardIndex = cardIndex;
                $scope.homePageModel.cardResponseResult[cardIndex] = successResult[0];
                for (j = 0; j < $scope.homePageModel.cardResponseResult[cardIndex].FilterList.length; j++) {
                    if (filterName == $scope.homePageModel.cardResponseResult[cardIndex].FilterList[j].Name) {
                        $scope.homePageModel.cardResponseResult[cardIndex].FilterList[j].IsActive = true;
                    }
                }
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.homePageModel.loadHomePageData = function() {
            $scope.homePageModel.cardResponseResult = [{
                isLoading: true
            }, {
                isLoading: true
            }, {
                isLoading: true
            }, {
                isLoading: true
            }];
            var widgets = [{
                Name: 'Store Summary',
                BlockList: [{
                    FilterName: 'Today'
                }]
            }, {
                Name: 'Service Jobs',
                BlockList: [{
                    FilterName: 'Customer Pay'
                }]
            }, {
                Name: 'Vendor Orders',
                BlockList: [{
                    FilterName: null
                }]
            }, {
                Name: 'Customer Orders',
                BlockList: [{
                    FilterName: null
                }]
            }];
            widgets.forEach(function(params, index) {
                getWidgetData([params], index);
            });
        }
        var getWidgetData = function(params, index) {
            NewHomePageService.getSummaryCardsDetails(angular.toJson(params)).then(function(response) {
                $scope.homePageModel.cardResponseResult[index] = (response && response[0]) ? response[0] : null;
                for (j = 0; j < $scope.homePageModel.cardResponseResult[index].FilterList.length; j++) {
                    if ($scope.homePageModel.cardResponseResult[index].FilterList[j].FilterOrderNumber == 1) {
                        $scope.homePageModel.cardResponseResult[index].FilterList[j].IsActive = true;
                    } else {
                        $scope.homePageModel.cardResponseResult[index].FilterList[j].IsActive = false;
                    }
                }
            }, function(error) {
                Notification.error(error);
            });
        };
        $scope.homePageModel.loadActivityData = function() {
            $scope.homePageModel.DefaultActivityActiveJSON.RequiredNumberOfRecords = $scope.homePageModel.ActivityList.length + $scope.homePageModel.DefaultActivityListSize;
            NewHomePageService.getActivityHistoryList(angular.toJson($scope.homePageModel.DefaultActivityActiveJSON)).then(function(successResult) {
                $scope.homePageModel.ActivityList = successResult;
                if ($window.innerWidth > 1023) {
                    setTimeout(function() {
                        var ActivityContainerHeight = angular.element(".Bp_home_topCardHead").height();
                        ActivityContainerHeight = ActivityContainerHeight - 14;
                        var ActivityDataContainerHeight = ActivityContainerHeight - 95;
                        angular.element(".Bp_home_LongCardBlockMock").css("height", ActivityContainerHeight + 'px');
                        angular.element(".Bp_home_LongCardBlock").css("height", ActivityContainerHeight + 'px');
                        angular.element(".BP_Home_activity_history_data").css("height", ActivityDataContainerHeight + 'px');
                    }, 10);
                }
                $scope.feedLoading = false;
            }, function(errorMessage) {
                $scope.feedLoading = false;
                Notification.error(errorMessage);
            });
        }
        $scope.homePageModel.ActivityHistoryToggle = function(ActivityName) {
            $scope.homePageModel.DefaultActivityActiveJSON.Type = ActivityName;
            $scope.homePageModel.DefaultActivityActiveJSON.RequiredNumberOfRecords = $scope.homePageModel.DefaultActivityListSize;
            NewHomePageService.getActivityHistoryList(angular.toJson($scope.homePageModel.DefaultActivityActiveJSON)).then(function(successResult) {
                $scope.homePageModel.ActivityList = successResult;
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }

        $scope.homePageModel.syncLeadWithDP360 = function() {
            NewHomePageService.syncLeadWithDP360().then(function(successResult) {
            	//Notification.success('Synched successfully');
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        
        $scope.homePageModel.MoveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
        $scope.homePageModel.widgetPermisssions = function(BlockName, PermissionLabel) {
            var PermissionVal = $scope.homePageModel.WidgetPermissionMap1[BlockName][PermissionLabel];
            if (PermissionVal.length == 0) {
                return true;
            } else {
                var defaultPermission = false;
                for (var i = 0; i < PermissionVal.length; i++) {
                    var PermissionValue = $rootScope.GroupOnlyPermissions[PermissionVal[i]]['view'];
                    defaultPermission = defaultPermission || PermissionValue;
                }
                return defaultPermission;
            }
        }
        $scope.homePageModel.MoveToSourceEntityState = function(sourceEntityName, sourceEntityId) {
            var stateParamJson = {
                Id: sourceEntityId
            };
            $scope.homePageModel.MoveToState($scope.homePageModel.SourceEntityToPageNameMap[sourceEntityName], stateParamJson);
        }
        $scope.homePageModel.SourceEntityToPageNameMap = {
            'Customer Order': $Global.IsLoadNewCustomerOrder ? 'CustomerOrder_V2' : 'CustomerOrder',
            'Customer Invoice': $Global.IsLoadNewCustomerOrder ? 'CustomerOrder_V2' : 'CustomerOrder',
            'Vendor Order': 'VendorOrder',
            'Vendor Receiving': 'VendorOrderReceiving',
            'Vendor Invoicing': 'VendorOrderInvoicing',
            'Customer': 'ViewCustomer',
            'Vendor': 'ViewVendor',
            'Price File': 'ViewVendor'
        };
        angular.element($(window)).bind('resize', function() {
            if ($window.innerWidth > 1023) {
                setTimeout(function() {
                    var ActivityContainerHeight = angular.element(".Bp_home_topCardHead").height();
                    ActivityContainerHeight = ActivityContainerHeight - 14;
                    var ActivityDataContainerHeight = ActivityContainerHeight - 95;
                    angular.element(".Bp_home_LongCardBlockMock").css("height", ActivityContainerHeight + 'px');
                    angular.element(".Bp_home_LongCardBlock").css("height", ActivityContainerHeight + 'px');
                    angular.element(".BP_Home_activity_history_data").css("height", ActivityDataContainerHeight + 'px');
                }, 10);
            } else {
                setTimeout(function() {
                    var ActivityContainerHeight = 560;
                    var ActivityMockHeight = 585;
                    var ActivityDataContainerHeight = ActivityContainerHeight - 95;
                    angular.element(".Bp_home_LongCardBlockMock").css("height", ActivityMockHeight + 'px');
                    angular.element(".Bp_home_LongCardBlock").css("height", ActivityContainerHeight + 'px');
                    angular.element(".BP_Home_activity_history_data").css("height", ActivityDataContainerHeight + 'px');
                }, 10);
            }
        });
        $scope.homePageModel.loadHomePageData();
        $scope.homePageModel.loadActivityData();
    }])
});