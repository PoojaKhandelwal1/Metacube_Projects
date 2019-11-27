define(['Routing_AppJs_PK', 'HomeSearchServices', 'underscore_min', 'JqueryUI', 'DirPagination', 'UserSearch'], function(Routing_AppJs_PK, HomeSearchServices, underscore_min, JqueryUI, DirPagination, UserSearch) {
    $(document).ready(function() {
        $(document).on('click', '.dropdown-menu', function(e) {
            $(this).hasClass('keep_open') && e.stopPropagation();
        });
    });
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('HomeSearchCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$state', '$stateParams', '$window', 'ngDialog', 'HomeSearchFactory', 'SideBarFactory', '$translate', function($scope, $timeout, $q, $rootScope, $sce, $state, $stateParams, $window, ngDialog, HomeSearchFactory, SideBarFactory, $translate) {
        var Notification = injector1.get("Notification");
        var origin = window.location.origin;
        var url = origin + '/apex/';
        $scope.HomeSearchGrid = {};
        $scope.HomeSearchGrid.ForModel = {};
        $scope.HomeSearchGrid.formMaterData = {};
        $scope.HomeSearchGrid.showContent = false;
        $scope.HomeSearchGrid.displayGrid = false;
        $scope.HomeSearchGrid.recentColumns = {};
        $scope.HomeSearchGrid.initFilterFormJsonCopy = {};
        $scope.HomeSearchGrid.OwnerNameStr = "";
        $scope.HomeSearchGrid.currentActiveFilter = {};
        $scope.HomeSearchGrid.isCriteriaSaved = true;
        $scope.HomeSearchGrid.sidebarSearch = {};
        $scope.HomeSearchGrid.previousObjectList = [];
        $scope.HomeSearchGrid.resetColumn = true;
        $scope.HomeSearchGrid.isfavorite = true;
        $scope.HomeSearchGrid.iscommon = false;
        $scope.HomeSearchGrid.iscustom = false;
        $scope.HomeSearchGrid.isSidePanelToggle = false;
        $scope.HomeSearchGrid.isSummaryInnerDiv = false;
        $scope.HomeSearchGrid.isSummaryActive = false;
        $scope.HomeSearchGrid.isReportMode = false;
        $scope.HomeSearchGrid.summaryDiv = false;
        $scope.HomeSearchGrid.exportDiv = false;
        $scope.HomeSearchGrid.outputResult = "";
        $scope.HomeSearchGrid.groupNameResult = "";
        $scope.HomeSearchGrid.dateFormat = $Global.DateFormat;
        $scope.HomeSearchGrid.dropdownSummaryDisplayedColumns = [];
        $scope.HomeSearchGrid.dropdownExportDisplayedColumns = [];
        $scope.HomeSearchGrid.IsIncludeInactiveRecords = false;
        $scope.HomeSearchGrid.IsSummaryFormat = false;
        $scope.HomeSearchGrid.TagNameStr = '';
        $scope.HomeSearchGrid.isAlreadyFocusedOnTagInput = false;
        $scope.HomeSearchGrid.currentSelectedTagIndex = -1;
        $scope.HomeSearchGrid.selectedObjectList = [];
        $scope.HomeSearchGrid.Aging_PRD1 = '';
        $scope.HomeSearchGrid.Aging_PRD2 = '';
        $scope.HomeSearchGrid.Aging_PRD3 = '';
        $scope.HomeSearchGrid.Aging_PRD4 = '';
        $scope.HomeSearchGrid.LabelChangeMap = {};
        $scope.HomeSearchGrid.defaultFilterFormJson = {};
        
        var newUrl = window.location.origin;
        $scope.HomeSearchGrid.nonGroupableObject = ['Parts Needed', 'Invoiced Items', 'Technician Hours', 'Payroll Hours', 'Technician Performance', 'Part FIFO', 'Tax Detail', 'Deal Units'];
        $scope.dateOptions = {
            maxDate: new Date,
            dateFormat: $Global.DateFormat
        };
        $scope.nodateOptions = {
            dateFormat: $Global.DateFormat
        };
        $scope.nodateOptionsreg = {
            dateFormat: $Global.DateFormat
        };
        $scope.mindateOptions = {
            dateFormat: $Global.DateFormat
        };
        $scope.HomeSearchGrid.FormatNameToColumnsToShowMap = {
            'Summary Format': ['Type', 'Item', 'Description', 'Qty Sold', 'Total Revenue', 'Total Profit', 'Last Sale', 'Average Price', 'Average Profit', 'Category', 'Vendor','Part Type'],
            'Detailed Format': ['Type', 'Item', 'Description', 'Customer', 'Invoice', 'Qty Sold', 'Price', 'Revenue', 'Profit', 'Category', 'Vendor','Part Type']
        };
        $scope.HomeSearchGrid.showColumn = function(label) {
            if (_.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Invoiced Items') != -1) {
                if(label == 'Part Type' && $scope.HomeSearchGrid.filterFormJson.InvoicedItem_Type != 'Part') {
                    return false
                }
                if ($scope.HomeSearchGrid.IsSummaryFormat) {
                    if (_.indexOf($scope.HomeSearchGrid.FormatNameToColumnsToShowMap['Summary Format'], label) != -1) {
                        return true;
                    }
                } else {
                    if (_.indexOf($scope.HomeSearchGrid.FormatNameToColumnsToShowMap['Detailed Format'], label) != -1) {
                        return true;
                    }
                }
            } else if (label != 'Active' || $scope.HomeSearchGrid.IsIncludeInactiveRecords) {
                return true;
            }
            return false;
        }
        $scope.HomeSearchGrid.showExportDisplayColumns = function(label) {
            if (_.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Invoiced Items') != -1) {
                if ($scope.HomeSearchGrid.IsSummaryFormat && (label == 'Qty Sold' || label == 'Total Revenue' || label == 'Total Profit')) {
                    return true;
                } else if (!$scope.HomeSearchGrid.IsSummaryFormat && (label == 'Qty Sold' || label == 'Revenue' || label == 'Profit')) {
                    return true;
                }
                return false;
            }
            return true;
        }
        $scope.HomeSearchGrid.selectregValueminDate = function(Value) {
            if (Value == 'Customer_Unit_Reg_Expiry') {
                $scope.nodateOptions.minDate = $scope.HomeSearchGrid.filterFormJson.Customer_Unit_Reg_Expiry.Value1;
            } else if (Value == 'Inventory_Unit_Reg_Expiry') {
                $scope.nodateOptions.minDate = $scope.HomeSearchGrid.filterFormJson.Inventory_Unit_Reg_Expiry.Value1;
            } else if (Value == 'Service_Job_Scheduled') {
                $scope.nodateOptions.minDate = $scope.HomeSearchGrid.filterFormJson.Service_Job_Scheduled.Value1;
            } else if (Value == 'InvoicedItem_InvoiceDate') {
                $scope.nodateOptions.minDate = $scope.HomeSearchGrid.filterFormJson.InvoicedItem_InvoiceDate.Value1;
            } else if (Value == 'TechinicianHours_Date') {
                $scope.nodateOptions.minDate = $scope.HomeSearchGrid.filterFormJson.TechinicianHours_Date.Value1;
            } else if (Value == 'Payroll_Date') {
                $scope.nodateOptions.minDate = $scope.HomeSearchGrid.filterFormJson.Payroll_Date.Value1;
            } else if (Value == 'TechinicianPerformance_Date') {
                $scope.nodateOptions.minDate = $scope.HomeSearchGrid.filterFormJson.TechinicianPerformance_Date.Value1;
            } else if (Value == 'COInvoice_InvoiceDate') {
                $scope.nodateOptions.minDate = $scope.HomeSearchGrid.filterFormJson.COInvoice_InvoiceDate.Value1;
            }
        }
        $scope.HomeSearchGrid.selectregValuemaxDate = function(Value) {
            if (Value == 'Customer_Unit_Reg_Expiry') {
                $scope.nodateOptionsreg.maxDate = $scope.HomeSearchGrid.filterFormJson.Customer_Unit_Reg_Expiry.Value2;
            } else if (Value == 'Inventory_Unit_Reg_Expiry') {
                $scope.nodateOptionsreg.maxDate = $scope.HomeSearchGrid.filterFormJson.Inventory_Unit_Reg_Expiry.Value2;
            } else if (Value == 'Service_Job_Scheduled') {
                $scope.nodateOptionsreg.maxDate = $scope.HomeSearchGrid.filterFormJson.Service_Job_Scheduled.Value2;
            } else if (Value == 'InvoicedItem_InvoiceDate') {
                $scope.nodateOptionsreg.maxDate = $scope.HomeSearchGrid.filterFormJson.InvoicedItem_InvoiceDate.Value2;
            } else if (Value == 'TechinicianHours_Date') {
                $scope.nodateOptionsreg.maxDate = $scope.HomeSearchGrid.filterFormJson.TechinicianHours_Date.Value2;
            } else if (Value == 'Payroll_Date') {
                $scope.nodateOptionsreg.maxDate = $scope.HomeSearchGrid.filterFormJson.Payroll_Date.Value2;
            } else if (Value == 'TechinicianPerformance_Date') {
                $scope.nodateOptionsreg.maxDate = $scope.HomeSearchGrid.filterFormJson.TechinicianPerformance_Date.Value2;
            } else if (Value == 'COInvoice_InvoiceDate') {
                $scope.nodateOptionsreg.maxDate = $scope.HomeSearchGrid.filterFormJson.COInvoice_InvoiceDate.Value2;
            } 
        }
        $scope.HomeSearchGrid.formMaterData.dateFilterOptions = [{
            label: "Anytime",
            optionValue: "0"
        }, {
            label: "Today",
            optionValue: "1"
        }, {
            label: "Yesterday",
            optionValue: "2"
        }, {
            label: "Last 7 days",
            optionValue: "3"
        }, {
            label: "Last 30 days",
            optionValue: "4"
        }, {
            label: "Custom...",
            optionValue: "5"
        }];
        $scope.HomeSearchGrid.formMaterData.rangeFilterOptions = [{
            label: "Any",
            optionValue: "0"
        }, {
            label: "Equal To",
            optionValue: "1"
        }, {
            label: "Not Equal To",
            optionValue: "2"
        }, {
            label: "Greater than",
            optionValue: "3"
        }, {
            label: "Less Than",
            optionValue: "4"
        }, {
            label: "Between",
            optionValue: "5"
        }];
        $scope.HomeSearchGrid.formMaterData.regdateFilterOptions = [{
            label: "Anytime",
            optionValue: "0"
        }, {
            label: "Today",
            optionValue: "1"
        }, {
            label: "Yesterday",
            optionValue: "2"
        }, {
            label: "Last 7 days",
            optionValue: "3"
        }, {
            label: "Last 30 days",
            optionValue: "4"
        }, {
            label: "Next 30 days",
            optionValue: "6"
        }, {
            label: "Custom...",
            optionValue: "5"
        }];
        $scope.HomeSearchGrid.formMaterData.scheduledDateFilterOptions = [{
            label: "Anytime",
            optionValue: "0"
        }, {
            label: "Today",
            optionValue: "1"
        }, {
            label: "Tomorrow",
            optionValue: "7"
        }, {
            label: "Next 7 days",
            optionValue: "8"
        }, {
            label: "Custom...",
            optionValue: "5"
        }];
        $scope.HomeSearchGrid.MoveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
        $scope.HomeSearchGrid.primaryFieldsList = ['Type', 'SearchText', 'Owner', 'Status', 'ModifiedDate', 'CreatedDate'];
        $scope.$on('HomePage-SearchText', function(event, args) {
            $scope.HomeSearchGrid.filterFormJson.SearchText = args.textToSearch;
            $scope.HomeSearchGrid.getFilteredRecords(true);
        });
        $scope.HomeSearchGrid.MoveToPage = function(value) {
            window.open(newUrl + '/apex/BlackPurlHome?pageName=' + value, '_blank');
        }
        var isOutside = false;
        $scope.dragstart = false;
        $scope.insideHeader = false;
        // Drag-drop configurations for grid columns
        $scope.HomeSearchGrid.insideSortable = {
            placeholder: 'place_holder',
            items: '.draggable',
            cursor: 'move',
            helper: 'clone',
            tolerance: 'pointer',
            cursorAt: {
                left: 10
            },
            connectWith: '.insideDroppable1 ',
            start: function(event, ui) {
                $scope.dragstart = true;
                insideHeader = true;
                ui.item.css('display', ' table-cell');
                ui.helper.css('width', '110px');
                ui.helper.css('height', '35px');
                ui.helper.css('border-bottom', '2px dashed green');
                ui.helper.css('border', '2px dashed green');
            },
            over: function(event, ui) {
                insideHeader = true;
            },
            out: function(event, ui) {
                insideHeader = false;
                angular.element('#dropArrowIcon').css('display', 'none');
            },
            change: function(event, ui) {
                if (insideHeader) {
                    var x = angular.element('.place_holder').next('th').position().left;
                    angular.element('#dropArrowIcon').css('display', 'inline-block');
                    angular.element('#dropArrowIcon').css('left', x - 10);
                }
            },
            stop: function(event, ui) {
                angular.element('#dropArrowIcon').css('display', 'none');
                $scope.dragstart = false;
                $scope.HomeSearchGrid.recentColumns = angular.copy($scope.HomeSearchGrid.columns);
                $scope.HomeSearchGrid.isCriteriaSaved = false;
            }
        };
        $scope.HomeSearchGrid.isDisplayMore = function() {
            angular.element('.searchCriteriaWrapper').addClass('removeOverflow');
            var height = angular.element('.searchCriteriaWrapper').height();
            angular.element('.searchCriteriaWrapper').removeClass('removeOverflow');
            if (height > 40) {
                return true;
            }
            return false;
        }
        // Pagination and sort related JSON
        $scope.HomeSearchGrid.searchResultPageSortAttrsJSON = {};
        // Method to set default page sort attributes JSON
        $scope.HomeSearchGrid.setDefaultPageSortAttrs = function() {
            $scope.HomeSearchGrid.searchResultPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "Modified",
                    FieldLabel: 'Modified',
                    ExportSort: 'Modified',
                    SortDirection: "DESC",
                    Type: "Date"
                }]
            };
            if (!$scope.HomeSearchGrid.isReportMode) {
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting[0].FieldName = 'LastModifiedDate__c';
            }
            try {
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.PageSize = $Global.Home_Search_Grid_Page_Size;
            } catch (ex) {}
        }
        $scope.HomeSearchGrid.setDefaultPageSortAttrs();

        function getUrlVars() {
            var vars = {};
            var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value) {
                vars[key] = value;
            });
            return vars;
        }
        $scope.HomeSearchGrid.LoadGrid = function() {
            $scope.HomeSearchGrid.LoadMasterData();
        }
        $scope.HomeSearchGrid.LoadMasterData = function() {
            HomeSearchFactory.getFilterObjectTypes().then(function(successfulSearchResult) {
                $scope.HomeSearchGrid.objectsList = successfulSearchResult.ObjectList;
                $scope.HomeSearchGrid.ObjectLabelToObjectDisplayNameMap = successfulSearchResult.ObjectLabelToObjectDisplayNameMap;
                $scope.HomeSearchGrid.filterFormJson = successfulSearchResult.FilterFormJSON;
                $scope.HomeSearchGrid.defaultFilterFormJson = angular.copy(successfulSearchResult.FilterFormJSON);
                
                $scope.HomeSearchGrid.filterList = successfulSearchResult.AllFilterJSON;
                $scope.HomeSearchGrid.Aging_PRD1 = successfulSearchResult.PartAgingPRD1 + 'day-';
                $scope.HomeSearchGrid.Aging_PRD2 = successfulSearchResult.PartAgingPRD2 + 'day-';
                $scope.HomeSearchGrid.Aging_PRD3 = successfulSearchResult.PartAgingPRD3 + 'day-';
                $scope.HomeSearchGrid.Aging_PRD4 = '>' + successfulSearchResult.PartAgingPRD3 + 'day-';
                $scope.HomeSearchGrid.setDefaultPageSortAttrs();
                $scope.HomeSearchGrid.LabelChangeMap = {
                        'PRD1 Qty': $scope.HomeSearchGrid.Aging_PRD1 + 'Qty',
                        'PRD1 Cost': $scope.HomeSearchGrid.Aging_PRD1 + 'Cost',
                        'PRD2 Qty': $scope.HomeSearchGrid.Aging_PRD2 + 'Qty',
                        'PRD2 Cost': $scope.HomeSearchGrid.Aging_PRD2 + 'Cost',
                        'PRD3 Qty': $scope.HomeSearchGrid.Aging_PRD3 + 'Qty',
                        'PRD3 Cost': $scope.HomeSearchGrid.Aging_PRD3 + 'Cost',
                        'PRD4 Qty': $scope.HomeSearchGrid.Aging_PRD4 + 'Qty',
                        'PRD4 Cost': $scope.HomeSearchGrid.Aging_PRD4 + 'Cost'
                    };
                if ($scope.HomeSearchGrid.filterFormJson.Owner.OwnerId != null) {
                    $scope.HomeSearchGrid.OwnerNameStr = $scope.HomeSearchGrid.filterFormJson.Owner.OwnerName;
                }
                $scope.HomeSearchGrid.updateFilterFormJSON();
                if ($stateParams.q != undefined) {
                    $scope.HomeSearchGrid.filterFormJson.SearchText = $stateParams.q;
                }
                if ($stateParams.type != undefined) {
                    $scope.HomeSearchGrid.filterFormJson.Type.Objects.push($stateParams.type);
                }
                if ($stateParams.filterparam != undefined) {
                    var filterJSON = $stateParams.filterparam;
                    var filterObj = JSON.parse(filterJSON);
                    angular.forEach(filterObj, function(value, key) {
                        $scope.HomeSearchGrid.filterFormJson[key] = filterObj[key];
                    });
                    HomeSearchFactory.getGridFilterConfigurations(JSON.stringify($scope.HomeSearchGrid.filterFormJson.Type.Objects)).then(function(successfulSearchResult) {
                        $scope.HomeSearchGrid.formMaterData.AdditionalFields = successfulSearchResult.AdditionalFields;
                        if($stateParams.additionalFieldParam) {
                            angular.forEach(JSON.parse($stateParams.additionalFieldParam), function(value, key) {
                                var index = _.findIndex($scope.HomeSearchGrid.formMaterData.AdditionalFields, {
                                    'UIFieldKey': value.UIFieldKey
                                });
                                
                                if(index != -1) {
                                    $scope.HomeSearchGrid.formMaterData.AdditionalFields[index].IsDisplayed = value.IsDisplayed;
                                }
                            });
                        }
                        $scope.HomeSearchGrid.formMaterData.CategoryList = successfulSearchResult.CategoryList;
                        $scope.HomeSearchGrid.formMaterData.POTypeList = successfulSearchResult.POTypeList;
                        $scope.HomeSearchGrid.formMaterData.PriceLevelList = successfulSearchResult.PriceLevelList;
                        $scope.HomeSearchGrid.formMaterData.PurchaseTaxList = successfulSearchResult.PurchaseTaxList;
                        $scope.HomeSearchGrid.formMaterData.VendorAccountTypeList = successfulSearchResult.VendorAccountTypeList;
                        $scope.HomeSearchGrid.formMaterData.CustomerAccountTypeList = successfulSearchResult.CustomerAccountTypeList;
                        $scope.HomeSearchGrid.formMaterData.SalesTaxList = successfulSearchResult.SalesTaxList;
                        $scope.HomeSearchGrid.formMaterData.StatusValues = successfulSearchResult.StatusValues;
                        $scope.HomeSearchGrid.formMaterData.ItemTypeValues = successfulSearchResult.ItemTypeValues;
                        $scope.HomeSearchGrid.formMaterData.CashDrawerList = successfulSearchResult.CashDrawerList;
                        $scope.HomeSearchGrid.formMaterData.DisplayIncludeInactive = successfulSearchResult.DisplayIncludeInactive;
                        $scope.HomeSearchGrid.formMaterData.DisplayTag = successfulSearchResult.DisplayTag;
                        $scope.HomeSearchGrid.formMaterData.SJJobTypes = successfulSearchResult.SJJobTypes;
                        $scope.HomeSearchGrid.formMaterData.PartTypeValues = ['Part', 'Merchandise'];
                        $scope.HomeSearchGrid.formMaterData.InvoiceTypeValues = ['Customer Invoice', 'Vendor Invoice'];
                    }, function(errorSearchResult) {
                        $scope.HomeSearchGrid.searchedResult = errorSearchResult;
                        Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
                    });
                }
                $scope.HomeSearchGrid.showContent = true;
                $scope.HomeSearchGrid.getFilteredRecords(true);
                setTimeout(function() {
                    $scope.HomeSearchGrid.calculateSidepanelHeight();
                }, 1000);
            }, function(errorSearchResult) {
                $scope.HomeSearchGrid.searchedResult = errorSearchResult;
                Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
            });
        }
        angular.element($window).bind('resize', function(event) {
            $scope.HomeSearchGrid.calculateSidepanelHeight();
        });
        $scope.HomeSearchGrid.calculateSidepanelHeight = function() {
            var windowHeight = window.outerHeight;
            var bgHeaderHeight = $rootScope.wrapperHeight;
            var sideBarHeight = windowHeight - bgHeaderHeight;
            var totalsideBarHeight = sideBarHeight - 65;
            angular.element(".sidepanel").css("height", totalsideBarHeight);
            var rightSideBarHeight = sideBarHeight - 118;
            angular.element(".rightSidePanel").css("height", rightSideBarHeight);
            $scope.HomeSearchGrid.preventMouseWheel();
        }
        $scope.HomeSearchGrid.updateFilterFormJSON = function() {
            angular.forEach($scope.HomeSearchGrid.filterFormJson, function(value, key) {
                if (value != null && value.SelectedOption == null) {
                    value.SelectedOption = "0";
                }
            });
            $scope.HomeSearchGrid.initFilterFormJsonCopy = angular.copy($scope.HomeSearchGrid.filterFormJson);
        }
        $scope.HomeSearchGrid.searchCriteriaJson = {};
        $scope.HomeSearchGrid.isFilterCopy = false;
        $scope.HomeSearchGrid.isFilterRename = false;
        $scope.HomeSearchGrid.popUpFilterName = '';
        $scope.HomeSearchGrid.popUpFilterId = null;
        $scope.HomeSearchGrid.clickToOpen = function() {
            $scope.HomeSearchGrid.newFilterName = angular.copy($scope.HomeSearchGrid.popUpFilterName);
            $scope.HomeSearchGrid.isFilterNameError = false;
            $scope.HomeSearchGrid.isHideRadioButton = false;
            $scope.HomeSearchGrid.userChoice = 'Save';
            if ($scope.HomeSearchGrid.isFilterCopy) {
                $scope.HomeSearchGrid.newFilterName = 'Copy of ' + angular.copy($scope.HomeSearchGrid.popUpFilterName);
            }
            $scope.HomeSearchGrid.errorMsg = false;
            if ($scope.HomeSearchGrid.isFilterCopy || $scope.HomeSearchGrid.isFilterRename) {
                $scope.HomeSearchGrid.isHideRadioButton = true;
            }
            var dialog = ngDialog.open({
                template: '<div class="dialogBox"><h2>Save Custom Filter</h2><br/>' + '<form ng-class=" { \'has-error\': HomeSearchGrid.isFilterNameError , \'\': !HomeSearchGrid.isFilterNameError }">' + '<span ng-hide="HomeSearchGrid.isHideRadioButton">' + '<span ng-hide="HomeSearchGrid.iscommon">' + '<input type="radio" ng-model="HomeSearchGrid.userChoice" value="Update" ng-hide="HomeSearchGrid.iscommon"> Update Existing Filter </input>' + '</span>' + '<br/>' + '<input type="radio" ng-model="HomeSearchGrid.userChoice" value="Save"> Save as New Filter </input>' + '</span>' + '<input type="text" ng-disabled="HomeSearchGrid.userChoice == \'Update\' || HomeSearchGrid.userChoice == \'\'" class="form-control" ng-model="HomeSearchGrid.newFilterName" placeholder="Filter Name" id="newFilter" style="width:70%;" />' + '<span class="help-block" ng-if= HomeSearchGrid.isFilterNameError > {{HomeSearchGrid.errorMsg}} </span><hr/>' + '<div style="text-align: right;">' + '<button style="margin-right:10px;" type="button" class="btn btn-default greenBtn" ng-click="HomeSearchGrid.saveFilter()  && closeThisDialog()">Save</button>' + '<button style="margin-right:10px;" type="button" class="btn btn-default grayBtn" ng-click="closeThisDialog()">Cancel</button>' + '</div>' + '</form>' + '</div>',
                showClose: false,
                scope: $scope,
                plain: true
            });
        };
        $scope.HomeSearchGrid.saveFilter = function() {
            var FilterId = null;
            if (typeof $scope.HomeSearchGrid.newFilterName == undefined) {
                $scope.HomeSearchGrid.newFilterName = '';
            }
            if ($scope.HomeSearchGrid.userChoice == 'Save' && $scope.HomeSearchGrid.newFilterName.trim().length == 0) {
                $scope.HomeSearchGrid.isFilterNameError = true;
                $scope.HomeSearchGrid.errorMsg = 'Please enter Filter Name';
                return false;
            }
            if ($scope.HomeSearchGrid.userChoice == 'Save') {
                if ($scope.HomeSearchGrid.checkIfFilterNameAlreadyPresent($scope.HomeSearchGrid.newFilterName.trim()) == false) {
                    $scope.HomeSearchGrid.isFilterNameError = true;
                    $scope.HomeSearchGrid.errorMsg = 'Filter Name - ' + $scope.HomeSearchGrid.newFilterName + ' already exists ';
                    return false;
                }
            }
            if ($scope.HomeSearchGrid.userChoice == 'Update') {
                FilterId = angular.copy($scope.HomeSearchGrid.popUpFilterId);
                $scope.HomeSearchGrid.newFilterName = angular.copy($scope.HomeSearchGrid.popUpFilterName);
                $scope.HomeSearchGrid.filterList.FilterType = 'Custom';
            }
            if ($scope.HomeSearchGrid.isFilterRename || $scope.HomeSearchGrid.isFilterCopy) {
                FilterId = $scope.HomeSearchGrid.popUpFilterId;
                SideBarFactory.renameCopyFilterRecord(FilterId, $scope.HomeSearchGrid.newFilterName, $scope.HomeSearchGrid.isFilterCopy).then(function(successfulSearchResult) {
                    $scope.HomeSearchGrid.filterList.FilterType = successfulSearchResult.FilterType;
                    $scope.HomeSearchGrid.isFilterCopy = false;
                    $scope.HomeSearchGrid.isFilterRename = false;
                    $scope.HomeSearchGrid.popUpFilterName = '';
                    $scope.HomeSearchGrid.popUpFilterId = null;
                    if ($scope.HomeSearchGrid.currentActiveFilter != undefined) {
                        $scope.HomeSearchGrid.currentActiveFilter.Name = $scope.HomeSearchGrid.newFilterName;
                    }
                }, function(errorSearchResult) {
                    $scope.HomeSearchGrid.filterList.FilterType = errorSearchResult;
                });
            } else {
                if ($scope.HomeSearchGrid.formMaterData.AdditionalFields == undefined) {
                    $scope.HomeSearchGrid.formMaterData.AdditionalFields = [];
                }
                var summaryColumnsObject = {
                    visible: $scope.HomeSearchGrid.summaryDisplayedColumns,
                    Hidden: $scope.HomeSearchGrid.summaryHiddenColumns
                };
                var exportColumnsObject = {
                    visible: $scope.HomeSearchGrid.summaryDisplayedColumns,
                    Hidden: $scope.HomeSearchGrid.summaryHiddenColumns
                };
                SideBarFactory.saveFilterRecord(FilterId, $scope.HomeSearchGrid.newFilterName, JSON.stringify($scope.HomeSearchGrid.filterFormJson), JSON.stringify($scope.HomeSearchGrid.searchResultPageSortAttrsJSON), JSON.stringify($scope.HomeSearchGrid.columns), JSON.stringify($scope.HomeSearchGrid.formMaterData.AdditionalFields), JSON.stringify(summaryColumnsObject), JSON.stringify(exportColumnsObject), $scope.HomeSearchGrid.outputResult, $scope.HomeSearchGrid.groupNameResult, $scope.HomeSearchGrid.isReportMode).then(function(successfulSearchResult) {
                    $scope.HomeSearchGrid.filterList.FilterType = successfulSearchResult.AllFilterJSON.FilterType;
                    $scope.HomeSearchGrid.currentActiveFilter = successfulSearchResult.CurrentFilter;
                    $scope.HomeSearchGrid.isFilterCopy = false;
                    $scope.HomeSearchGrid.isFilterRename = false;
                    $scope.HomeSearchGrid.popUpFilterName = '';
                    $scope.HomeSearchGrid.popUpFilterId = null;
                    $scope.HomeSearchGrid.isFilterMatched = true;
                }, function(errorSearchResult) {
                    $scope.HomeSearchGrid.filterList.FilterType = errorSearchResult;
                });
            }
            return true;
        }
        $scope.HomeSearchGrid.saveAsAction = function() {
            $scope.HomeSearchGrid.popUpFilterName = $scope.HomeSearchGrid.currentActiveFilter.Name;
            $scope.HomeSearchGrid.popUpFilterId = $scope.HomeSearchGrid.currentActiveFilter.Id;
            $scope.HomeSearchGrid.clickToOpen();
        }
        $scope.HomeSearchGrid.renameOrCopyCustomFilter = function(FilterId, FilterName, isCopy) {
            $scope.HomeSearchGrid.popUpFilterId = FilterId;
            $scope.HomeSearchGrid.popUpFilterName = FilterName;
            $scope.HomeSearchGrid.isFilterCopy = isCopy;
            $scope.HomeSearchGrid.isFilterRename = !isCopy;
            $scope.HomeSearchGrid.clickToOpen();
        }
        $scope.HomeSearchGrid.confirmDelete = function(customFilterId, customFilterName) {
            var dialog = ngDialog.open({
                template: '<div class="dialogBox"><h3>Delete Filter: ' + customFilterName + '</h3><hr/>' + '<form >' + '<span > Are you sure ? <hr/>' + '<div style="text-align: right;">' + '<button style="margin-right:10px;" type="button" class="btn btn-default greenBtn" ng-click="HomeSearchGrid.deleteCustomFilter(\'' + customFilterId + '\') && closeThisDialog()">Delete</button>' + '<button style="margin-right:10px;" type="button" class="btn btn-default grayBtn" ng-click="closeThisDialog()">Cancel</button>' + '</div>' + '</form>' + '</div>',
                showClose: false,
                scope: $scope,
                plain: true
            });
        };
        $scope.HomeSearchGrid.deleteCustomFilter = function(FilterId) {
            SideBarFactory.deleteFilterRecord(FilterId).then(function(successfulSearchResult) {
                $scope.HomeSearchGrid.filterList.FilterType = successfulSearchResult.FilterType;
                if (FilterId == $scope.HomeSearchGrid.currentActiveFilter.Id) {
                    $scope.HomeSearchGrid.currentActiveFilter = {};
                }
            }, function(errorSearchResult) {
                $scope.filterList = errorSearchResult;
            });
            return true;
        }
        $scope.HomeSearchGrid.applySavedFilter = function(filterObj, filterType) {
            $scope.HomeSearchGrid.selectedObjectList = angular.copy($scope.HomeSearchGrid.filterFormJson.Type.Objects);
            $scope.HomeSearchGrid.displayGrid = false;
            var FilterRecord;
            $scope.HomeSearchGrid.currentActiveFilter = {
                Id: filterObj.Id,
                Name: filterObj.FilterLabel,
                Type: filterType
            };
            setTimeout(function() {
                SideBarFactory.getFilterFields(filterObj.Id).then(function(successfulSearchResult) {
                    FilterRecord = successfulSearchResult;
                    FilterRecord.FieldFilterJson = JSON.parse(FilterRecord.FieldFilterJson);
                    var dateToday = new Date();
                     if(((_.indexOf(FilterRecord.FieldFilterJson.Type.Objects, 'Part FIFO') != -1 && FilterRecord.FilterLabel === 'Part Movement') || (_.indexOf(FilterRecord.FieldFilterJson.Type.Objects, 'Tax Detail') != -1 && FilterRecord.FilterLabel === 'Tax Detail') || FilterRecord.FilterLabel === 'Invoice Summary') && FilterRecord.Common) {
                        var lastMonthStartDate = new Date(dateToday.getFullYear(), dateToday.getMonth() - 1, 1);
                        var lastMonthEndDate = new Date(dateToday.getFullYear(), dateToday.getMonth(), 0);
                        lastMonthStartDate = getDateStringWithFormat(lastMonthStartDate, $scope.HomeSearchGrid.dateFormat);
                        lastMonthEndDate = getDateStringWithFormat(lastMonthEndDate, $scope.HomeSearchGrid.dateFormat);
                        var modifiedDateFilterLastMonth = {
                                SelectedOption : 5,
                                Value1: lastMonthStartDate, 
                                Value2: lastMonthEndDate
                        };
                        if(FilterRecord.FilterLabel === 'Part Movement') {
                            FilterRecord.FieldFilterJson.Part_FIFO_Date = modifiedDateFilterLastMonth;
                        } else if (FilterRecord.FilterLabel === 'Tax Detail'){
                            FilterRecord.FieldFilterJson.Tax_Detail_Invoice_Date = modifiedDateFilterLastMonth;
                        } else if(FilterRecord.FilterLabel === 'Invoice Summary') {
                        	FilterRecord.FieldFilterJson.COInvoice_InvoiceDate = {SelectedOption : 3, Value1: null, Value2: null};
                        }
                    }
                    HomeSearchFactory.getGridFilterConfigurations(JSON.stringify(FilterRecord.FieldFilterJson.Type.Objects)).then(function(successfulSearchResult) {
                        $scope.HomeSearchGrid.formMaterData.CategoryList = successfulSearchResult.CategoryList;
                        $scope.HomeSearchGrid.formMaterData.POTypeList = successfulSearchResult.POTypeList;
                        $scope.HomeSearchGrid.formMaterData.PriceLevelList = successfulSearchResult.PriceLevelList;
                        $scope.HomeSearchGrid.formMaterData.PurchaseTaxList = successfulSearchResult.PurchaseTaxList;
                        $scope.HomeSearchGrid.formMaterData.VendorAccountTypeList = successfulSearchResult.VendorAccountTypeList;
                        $scope.HomeSearchGrid.formMaterData.CustomerAccountTypeList = successfulSearchResult.CustomerAccountTypeList;
                        $scope.HomeSearchGrid.formMaterData.SalesTaxList = successfulSearchResult.SalesTaxList;
                        $scope.HomeSearchGrid.formMaterData.StatusValues = successfulSearchResult.StatusValues;
                        $scope.HomeSearchGrid.formMaterData.ItemTypeValues = successfulSearchResult.ItemTypeValues;
                        $scope.HomeSearchGrid.formMaterData.CashDrawerList = successfulSearchResult.CashDrawerList;
                        $scope.HomeSearchGrid.formMaterData.DisplayIncludeInactive = successfulSearchResult.DisplayIncludeInactive;
                        $scope.HomeSearchGrid.formMaterData.DisplayTag = successfulSearchResult.DisplayTag;
                        $scope.HomeSearchGrid.formMaterData.SJJobTypes = successfulSearchResult.SJJobTypes;
                        $scope.HomeSearchGrid.formMaterData.SalesTaxItemList = successfulSearchResult.SalesTaxItemList ? successfulSearchResult.SalesTaxItemList : [];
                        $scope.HomeSearchGrid.formMaterData.CopySalesTaxItemList = successfulSearchResult.SalesTaxItemList ? successfulSearchResult.SalesTaxItemList : [];
                        $scope.HomeSearchGrid.formMaterData.PartTypeValues = ['Part', 'Merchandise'];
                        $scope.HomeSearchGrid.formMaterData.InvoiceTypeValues = ['Customer Invoice', 'Vendor Invoice'];
                        setTimeout(function() {
                            $scope.HomeSearchGrid.filterFormJson = angular.copy($scope.HomeSearchGrid.defaultFilterFormJson);
                            angular.forEach($scope.HomeSearchGrid.filterFormJson, function(value, key) {
                                if (FilterRecord.FieldFilterJson[key]) {
                                    $scope.HomeSearchGrid.filterFormJson[key] = angular.copy(FilterRecord.FieldFilterJson[key]);
                                }
                            });
                            $scope.HomeSearchGrid.searchResultPageSortAttrsJSON = JSON.parse(FilterRecord.SortJson);
                            FilterRecord.DisplayHiddenColumn = addDynamicColumnsToHomeSearchGrid(JSON.parse(FilterRecord.DisplayHiddenColumn));
                            $scope.HomeSearchGrid.columns = FilterRecord.DisplayHiddenColumn;
                            $scope.HomeSearchGrid.recentColumns = angular.copy(FilterRecord.DisplayHiddenColumn);
                            $scope.HomeSearchGrid.formMaterData.AdditionalFields = JSON.parse(FilterRecord.AdditionalFieldJson);
                            if (JSON.parse(FilterRecord.SummaryFieldsJSON) != undefined) {
                                $scope.HomeSearchGrid.summaryDisplayedColumns = JSON.parse(FilterRecord.SummaryFieldsJSON).visible;
                                $scope.HomeSearchGrid.dropdownSummaryDisplayedColumns = JSON.parse(FilterRecord.SummaryFieldsJSON).visible;
                                $scope.HomeSearchGrid.summaryHiddenColumns = JSON.parse(FilterRecord.SummaryFieldsJSON).Hidden;
                                $scope.HomeSearchGrid.copySummaryDisplayColumns = angular.copy($scope.HomeSearchGrid.summaryDisplayedColumns);
                                $scope.HomeSearchGrid.copySummaryHiddenColumns = angular.copy($scope.HomeSearchGrid.summaryHiddenColumns);
                            }
                            if (JSON.parse(FilterRecord.ExportFieldsJSON) != undefined) {
                                $scope.HomeSearchGrid.exportDisplayedColumns = JSON.parse(FilterRecord.ExportFieldsJSON).visible;
                                $scope.HomeSearchGrid.dropdownExportDisplayedColumns = JSON.parse(FilterRecord.ExportFieldsJSON).visible;
                                $scope.HomeSearchGrid.exportHiddenColumns = JSON.parse(FilterRecord.ExportFieldsJSON).Hidden;
                                $scope.HomeSearchGrid.copyExportDisplayColumns = angular.copy($scope.HomeSearchGrid.exportDisplayedColumns);
                                $scope.HomeSearchGrid.copyExportHiddenColumns = angular.copy($scope.HomeSearchGrid.exportHiddenColumns);
                            }
                            $scope.HomeSearchGrid.outputResult = FilterRecord.ExportFileFormat;
                            $scope.HomeSearchGrid.groupNameResult = FilterRecord.ExportGroupField;
                            if (FilterRecord.ExportGroupField != undefined && FilterRecord.ExportGroupField != '') {
                                var re = new RegExp(' ', 'g');
                                $scope.HomeSearchGrid.groupNameKey = FilterRecord.ExportGroupField.replace(re, '_');
                            }
                            $scope.HomeSearchGrid.isReportMode = FilterRecord.IsReportOn;
                            $scope.HomeSearchGrid.getFilteredRecords(false);
                            $scope.HomeSearchGrid.previousObjectList = $scope.HomeSearchGrid.filterFormJson.Type.Objects;
                        }, 1000);
                    }, function(errorSearchResult) {
                        $scope.HomeSearchGrid.searchedResult = errorSearchResult;
                        Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
                    });
                }, function(errorSearchResult) {
                    $scope.HomeSearchGrid.filterList.FilterType = errorSearchResult;
                });
            }, 1000);
        }
        $scope.HomeSearchGrid.checkIfFilterNameAlreadyPresent = function(customFilterLabel) {
            if ($scope.HomeSearchGrid.filterList.FilterType.Common != undefined && $scope.HomeSearchGrid.filterList.FilterType.Custom != undefined) {
                for (var i = 0; i < $scope.HomeSearchGrid.filterList.FilterType.Custom.length; i++) {
                    if (customFilterLabel.toUpperCase() === $scope.HomeSearchGrid.filterList.FilterType.Custom[i].FilterLabel.toUpperCase()) {
                        $scope.HomeSearchGrid.isFilterNameError = true;
                        $scope.HomeSearchGrid.errorMsg = 'Filter Name - ' + customFilterLabel + ' already exists ';
                        return false;
                    }
                }
                if ($scope.HomeSearchGrid.isFilterNameError == false) {
                    for (var i = 0; i < $scope.HomeSearchGrid.filterList.FilterType.Common.length; i++) {
                        for (var j = 0; j < $scope.HomeSearchGrid.filterList.FilterType.Common[i].subgroupList.length; j++) {
                            if (customFilterLabel.toUpperCase() === $scope.HomeSearchGrid.filterList.FilterType.Common[i].subgroupList[j].FilterLabel.toUpperCase()) {
                                $scope.HomeSearchGrid.isFilterNameError = true;
                                $scope.HomeSearchGrid.errorMsg = 'Filter Name - ' + customFilterLabel + ' already exists ';
                                return false;
                            }
                        }
                    }
                }
            }
            return true;
        }
        $scope.HomeSearchGrid.markFilterFav = function(FilterId, isFav) {
            SideBarFactory.markFilterAsFavorite(FilterId, isFav).then(function(successfulSearchResult) {
                if (isFav) {
                    $scope.HomeSearchGrid.currentActiveFilter.Type = 'favorite';
                } else {
                    $scope.HomeSearchGrid.currentActiveFilter.Type = 'Custom';
                }
                $scope.HomeSearchGrid.filterList.FilterType = successfulSearchResult.FilterType;
            }, function(errorSearchResult) {
                $scope.filterList = [];
            });
        }
        $scope.HomeSearchGrid.isObjectSelectionDisabled = function(objectName) {
            if (typeof $scope.HomeSearchGrid.filterFormJson.Type.Objects != undefined) {
                if ($scope.HomeSearchGrid.filterFormJson.Type.Objects.length == 0) {
                    return false;
                }
                for (var i = 0; i < $scope.HomeSearchGrid.nonGroupableObject.length; i++) {
                    if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, $scope.HomeSearchGrid.nonGroupableObject[i]) != -1) {
                        if (objectName == $scope.HomeSearchGrid.nonGroupableObject[i]) {
                            return false;
                        } else {
                            return true;
                        }
                    } else {
                        if (objectName == $scope.HomeSearchGrid.nonGroupableObject[i]) {
                            return true;
                        }
                    }
                }
                return false;
            }
        }
        $scope.HomeSearchGrid.selectFilterObject = function(objectName) {
            $scope.HomeSearchGrid.selectedObjectList = angular.copy($scope.HomeSearchGrid.filterFormJson.Type.Objects);
            if (_.indexOf($scope.HomeSearchGrid.nonGroupableObject, objectName) == -1 && $scope.HomeSearchGrid.isObjectSelectionDisabled(objectName)) {
                return;
            } else if (_.indexOf($scope.HomeSearchGrid.nonGroupableObject, objectName) != -1 && $scope.HomeSearchGrid.isObjectSelectionDisabled(objectName)) {
                return;
            }
            if (typeof $scope.HomeSearchGrid.filterFormJson.Type.Objects == undefined) {
                $scope.HomeSearchGrid.filterFormJson.Type.Objects = [];
            }
            if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, objectName) == -1) {
                if ($scope.HomeSearchGrid.nonGroupableObject.indexOf(objectName) != -1) {
                    $scope.HomeSearchGrid.filterFormJson.Type.Objects = [];
                }
                $scope.HomeSearchGrid.filterFormJson.Type.Objects.push(objectName);
            } else {
                $scope.HomeSearchGrid.filterFormJson.Type.Objects = _.without($scope.HomeSearchGrid.filterFormJson.Type.Objects, objectName);
            }
            HomeSearchFactory.getGridFilterConfigurations(JSON.stringify($scope.HomeSearchGrid.filterFormJson.Type.Objects)).then(function(successfulSearchResult) {
                $scope.HomeSearchGrid.formMaterData.AdditionalFields = successfulSearchResult.AdditionalFields;
                $scope.HomeSearchGrid.formMaterData.CategoryList = successfulSearchResult.CategoryList;
                $scope.HomeSearchGrid.formMaterData.POTypeList = successfulSearchResult.POTypeList;
                $scope.HomeSearchGrid.formMaterData.PriceLevelList = successfulSearchResult.PriceLevelList;
                $scope.HomeSearchGrid.formMaterData.PurchaseTaxList = successfulSearchResult.PurchaseTaxList;
                $scope.HomeSearchGrid.formMaterData.VendorAccountTypeList = successfulSearchResult.VendorAccountTypeList;
                $scope.HomeSearchGrid.formMaterData.CustomerAccountTypeList = successfulSearchResult.CustomerAccountTypeList;
                $scope.HomeSearchGrid.formMaterData.SalesTaxList = successfulSearchResult.SalesTaxList;
                $scope.HomeSearchGrid.formMaterData.StatusValues = successfulSearchResult.StatusValues;
                $scope.HomeSearchGrid.formMaterData.ItemTypeValues = successfulSearchResult.ItemTypeValues;
                $scope.HomeSearchGrid.formMaterData.CashDrawerList = successfulSearchResult.CashDrawerList;
                $scope.HomeSearchGrid.formMaterData.DisplayIncludeInactive = successfulSearchResult.DisplayIncludeInactive;
                $scope.HomeSearchGrid.formMaterData.DisplayTag = successfulSearchResult.DisplayTag;
                $scope.HomeSearchGrid.formMaterData.SJJobTypes = successfulSearchResult.SJJobTypes;
                $scope.HomeSearchGrid.formMaterData.SalesTaxItemList = successfulSearchResult.SalesTaxItemList ? successfulSearchResult.SalesTaxItemList : [];
                $scope.HomeSearchGrid.formMaterData.PartTypeValues = ['Part', 'Merchandise'];
                $scope.HomeSearchGrid.formMaterData.InvoiceTypeValues = ['Customer Invoice', 'Vendor Invoice'];
                $scope.HomeSearchGrid.filterFormJson.Status = '0';
                angular.forEach($scope.HomeSearchGrid.filterFormJson, function(value, key) {
                    if ($scope.HomeSearchGrid.primaryFieldsList.indexOf(key) == -1) {
                        $scope.HomeSearchGrid.filterFormJson[key] = angular.copy($scope.HomeSearchGrid.initFilterFormJsonCopy[key]);
                    }
                });
                
            }, function(errorSearchResult) {
                $scope.HomeSearchGrid.searchedResult = errorSearchResult;
                Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
            });
        }
        $scope.HomeSearchGrid.isfilterActive = function(filterId, filterType) {
            if (filterId == $scope.HomeSearchGrid.currentActiveFilter.Id) {
                return true;
            }
            return false;
        }
        $scope.HomeSearchGrid.isFilterObjectSelected = function(objectName) {
            if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, objectName) != -1) {
                return true;
            } else {
                return false;
            }
        }
        $scope.$on("userSelectCallBack", function(event, message) {
            $scope.HomeSearchGrid.filterFormJson.Owner.OwnerId = message.SearchResult.originalObject.Value;
            $scope.HomeSearchGrid.filterFormJson.Owner.OwnerName = message.SearchResult.originalObject.Name;
        });
        $scope.HomeSearchGrid.getObjectFilterText = function() {
            if ($scope.HomeSearchGrid.filterFormJson == undefined) {
                $scope.HomeSearchGrid.filterFormJson = {};
                $scope.HomeSearchGrid.filterFormJson.Type = {};
            }
            if ($scope.HomeSearchGrid.filterFormJson.Type.Objects == undefined) {
                $scope.HomeSearchGrid.filterFormJson.Type.Objects = [];
            }
            if ($scope.HomeSearchGrid.filterFormJson.Type.Objects.length == 0) {
                return 'Any';
            } else if ($scope.HomeSearchGrid.filterFormJson.Type.Objects.length == 1) {
                if ($scope.HomeSearchGrid.ObjectLabelToObjectDisplayNameMap.hasOwnProperty($scope.HomeSearchGrid.filterFormJson.Type.Objects[0])) {
                    return $scope.HomeSearchGrid.ObjectLabelToObjectDisplayNameMap[$scope.HomeSearchGrid.filterFormJson.Type.Objects[0]];
                } else {
                    return $scope.HomeSearchGrid.filterFormJson.Type.Objects[0];
                }
            } else {
                return 'Multiple';
            }
        }
        $scope.HomeSearchGrid.showFieldToGroup = function(groupFieldType, groupFieldLabel) {
            if (groupFieldType == 'Icon' && _.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Invoiced Items') != -1) {
                return true;
            }
            return false;
        }
        $scope.HomeSearchGrid.getFilterValue = function(filterKey) {
            if ($scope.HomeSearchGrid.ObjectLabelToObjectDisplayNameMap != undefined && filterKey != undefined && $scope.HomeSearchGrid.ObjectLabelToObjectDisplayNameMap.hasOwnProperty(filterKey)) {
                return $scope.HomeSearchGrid.ObjectLabelToObjectDisplayNameMap[filterKey];
            } else {
                var filterKeyList = filterKey.split(', ');
                var displayObjectNames = '';
                for (var i = 0; i < filterKeyList.length; i++) {
                    if ($scope.HomeSearchGrid.ObjectLabelToObjectDisplayNameMap.hasOwnProperty(filterKeyList[i])) {
                        displayObjectNames += $scope.HomeSearchGrid.ObjectLabelToObjectDisplayNameMap[filterKeyList[i]];
                    } else {
                        displayObjectNames += filterKeyList[i];
                    }
                    if (i < filterKeyList.length - 1) {
                        displayObjectNames += ', ';
                    }
                }
                return displayObjectNames;
            }
        }
        $scope.HomeSearchGrid.showField = function(fieldKey) {
            var index = _.findIndex($scope.HomeSearchGrid.formMaterData.AdditionalFields, {
                UIFieldKey: fieldKey
            });
            if (index != -1) {
                return $scope.HomeSearchGrid.formMaterData.AdditionalFields[index].IsDisplayed;
            }
            return false;
        }
        $scope.HomeSearchGrid.addAdditionalField = function(fieldKey) {
            var index = _.findIndex($scope.HomeSearchGrid.formMaterData.AdditionalFields, {
                UIFieldKey: fieldKey
            });
            if (index != -1) {
                $scope.HomeSearchGrid.formMaterData.AdditionalFields[index].IsDisplayed = true;
                setTimeout(function() {
                    angular.element('#' + fieldKey).focus();
                }, 1000);
            }
        }
        $scope.HomeSearchGrid.removeAdditionalField = function(fieldKey) {
            var index = _.findIndex($scope.HomeSearchGrid.formMaterData.AdditionalFields, {
                UIFieldKey: fieldKey
            });
            if (index != -1) {
                if (fieldKey == 'Customer_Unit_Reg_Expiry' || fieldKey == 'Inventory_Unit_Reg_Expiry' || fieldKey == 'Service_Job_Scheduled') {
                    $scope.nodateOptions.minDate = '';
                    $scope.nodateOptionsreg.maxDate = '';
                }
                $scope.HomeSearchGrid.formMaterData.AdditionalFields[index].IsDisplayed = false;
            }
            $scope.HomeSearchGrid.filterFormJson[fieldKey] = angular.copy($scope.HomeSearchGrid.initFilterFormJsonCopy[fieldKey]);
        }
        $scope.HomeSearchGrid.showFilterForm = function() {
            $scope.HomeSearchGrid.filterFormJsonCopy = angular.copy($scope.HomeSearchGrid.filterFormJson);
            if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, 'Tax Detail') != -1) {
                $scope.HomeSearchGrid.formMaterData.SalesTaxItemList = angular.copy($scope.HomeSearchGrid.formMaterData.CopySalesTaxItemList);
            }
            $scope.HomeSearchGrid.openFilterForm();
        }
        $scope.HomeSearchGrid.closeFilterForm = function() {
            $scope.HomeSearchGrid.filterFormJson = angular.copy($scope.HomeSearchGrid.filterFormJsonCopy);
            $scope.HomeSearchGrid.hideFilterForm();
        }
        $scope.HomeSearchGrid.clearFilterForm = function() {
            $scope.HomeSearchGrid.closeFilterForm();
            $scope.HomeSearchGrid.formMaterData.AdditionalFields = [];
            $scope.HomeSearchGrid.filterFormJson = angular.copy($scope.HomeSearchGrid.initFilterFormJsonCopy);
            $scope.HomeSearchGrid.previousObjectList = angular.copy($scope.HomeSearchGrid.filterFormJson.Type.Objects);
            $scope.HomeSearchGrid.currentActiveFilter = {};
            $scope.HomeSearchGrid.setDefaultPageSortAttrs();
            $scope.HomeSearchGrid.getFilteredRecords(true);
            setTimeout(function() {
                var HomeSearchResultDivWidth = angular.element('#myTable').width();
                HomeSearchResultDivWidth = HomeSearchResultDivWidth + 20 + 'px';
                angular.element('#HomeSearchresultDiv').css('position', 'absolute');
                angular.element('#HomeSearchresultDiv').css('left', HomeSearchResultDivWidth);
            }, 10);
        }
        $scope.HomeSearchGrid.loadingColumn = false;
        $scope.HomeSearchGrid.openColumnsDropdown = function() {
            $scope.HomeSearchGrid.columnSearch = {};
            $scope.HomeSearchGrid.columnSearch.Label = '';
            $scope.HomeSearchGrid.columns = angular.copy($scope.HomeSearchGrid.recentColumns);
        }
        $scope.HomeSearchGrid.closeColumnsDropdown = function() {
            angular.element('#column_dropdown').closest(".dropdown").removeClass("open");
        }
        $scope.HomeSearchGrid.updateColumnsDropdown = function() {
            $scope.HomeSearchGrid.isFilterMatched = false;
            var DisplayedCols = [];
            var HiddenCols = [];
            for (i = 0; i < $scope.HomeSearchGrid.columns.DisplayedColumns.length; i++) {
                if ($scope.HomeSearchGrid.columns.DisplayedColumns[i].IsDisplayed) {
                    DisplayedCols.push($scope.HomeSearchGrid.columns.DisplayedColumns[i]);
                } else {
                    HiddenCols.push($scope.HomeSearchGrid.columns.DisplayedColumns[i]);
                }
            }
            for (i = 0; i < $scope.HomeSearchGrid.columns.HiddenColumns.length; i++) {
                if ($scope.HomeSearchGrid.columns.HiddenColumns[i].IsDisplayed) {
                    DisplayedCols.push($scope.HomeSearchGrid.columns.HiddenColumns[i]);
                } else {
                    HiddenCols.push($scope.HomeSearchGrid.columns.HiddenColumns[i]);
                }
            }
            $scope.HomeSearchGrid.columns.DisplayedColumns = DisplayedCols;
            $scope.HomeSearchGrid.columns.HiddenColumns = HiddenCols;
            $scope.HomeSearchGrid.recentColumns = angular.copy($scope.HomeSearchGrid.columns);
            $scope.HomeSearchGrid.getActiveSummaryRecord();
            if(_.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Tax Detail') != -1) {
                getTotalGridSummaryRecordForTaxDetails();
            }
            $scope.HomeSearchGrid.closeColumnsDropdown();
            setTimeout(function() {
                var HomeSearchResultDivWidth = angular.element('#myTable').width();
                HomeSearchResultDivWidth = HomeSearchResultDivWidth + 20 + 'px';
                angular.element('#HomeSearchresultDiv').css('position', 'absolute');
                angular.element('#HomeSearchresultDiv').css('left', HomeSearchResultDivWidth);
            }, 10);
        }
        $scope.HomeSearchGrid.restoreColumns = function() {
            HomeSearchFactory.getGridColumnsConfiguration(JSON.stringify($scope.HomeSearchGrid.filterFormJson.Type.Objects), JSON.stringify($scope.HomeSearchGrid.filterFormJson)).then(function(successfulResult) {
                $scope.HomeSearchGrid.columns.DisplayedColumns = successfulResult.DisplayedColumns;
                $scope.HomeSearchGrid.columns.HiddenColumns = successfulResult.HiddenColumns;
                if (successfulResult.MatchFilter == null) {
                    $scope.HomeSearchGrid.isFilterMatched = false;
                } else {
                    $scope.HomeSearchGrid.isFilterMatched = true;
                    $scope.HomeSearchGrid.currentActiveFilter = successfulResult.MatchFilter;
                }
                successfulResult = addDynamicColumnsToHomeSearchGrid(successfulResult);
                $scope.HomeSearchGrid.recentColumns = angular.copy(successfulResult);
                $scope.HomeSearchGrid.closeColumnsDropdown();
                $scope.HomeSearchGrid.getActiveSummaryRecord();
            }, function(errorSearchResult) {
                $scope.HomeSearchGrid.searchedResult = errorSearchResult;
                Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
                $scope.HomeSearchGrid.closeColumnsDropdown
            });
        }
        $scope.HomeSearchGrid.changeSort = function(Field, Direction) {
            var FieldApiName = Field.FieldAPIName;
            var FieldLabel = Field.Label;
            var RecordKey = Field.RecordKey;
            var Type = Field.Type;
            if (!$scope.HomeSearchGrid.isReportMode) {
                if (FieldApiName == null) {
                    Notification.error($translate.instant('HomeSearch_Sorting_can_t_be_applied_on_this_column'));
                    return;
                }
                var SortingArray = angular.copy($scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting);
                var index = _.findIndex(SortingArray, {
                    FieldName: FieldApiName
                });
                if (index != -1) {
                    SortingArray[index].SortDirection = Direction;
                } else {
                    SortingArray.push({
                        FieldName: FieldApiName,
                        FieldLabel: FieldLabel,
                        ExportSort: RecordKey,
                        SortDirection: Direction,
                        Type: Type
                    });
                }
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = SortingArray;
                $scope.HomeSearchGrid.getFilteredRecords(false);
            } else {
                if (RecordKey == null) {
                    Notification.error($translate.instant('HomeSearch_Sorting_can_t_be_applied_on_this_column'));
                    return;
                }
                var SortingArray = angular.copy($scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting);
                var index = _.findIndex(SortingArray, {
                    FieldName: RecordKey
                });
                if (index != -1) {
                    SortingArray[index].SortDirection = Direction;
                } else {
                    SortingArray.push({
                        FieldName: RecordKey,
                        FieldLabel: FieldLabel,
                        ExportSort: RecordKey,
                        SortDirection: Direction,
                        Type: Type
                    });
                }
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = SortingArray;
                $scope.HomeSearchGrid.SearchedReportData.sort($scope.dynamicSortMultiple($scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting));
                $scope.HomeSearchGrid.HSGrid_paginationControlsAction();
            }
        }
        $scope.HomeSearchGrid.getSortDirection = function(FieldApiName, RecordKey) {
            var SortingArray = angular.copy($scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting);
            var index;
            if (!$scope.HomeSearchGrid.isReportMode) {
                index = _.findIndex(SortingArray, {
                    FieldName: FieldApiName
                });
            } else {
                index = _.findIndex(SortingArray, {
                    FieldName: RecordKey
                });
            }
            if (index != -1) {
                return SortingArray[index].SortDirection;
            } else {
                return '';
            }
        }
        $scope.HomeSearchGrid.isSummaryActiveToggle = function() {
            $scope.HomeSearchGrid.isSummaryActive = !$scope.HomeSearchGrid.isSummaryActive;
        }
        $scope.HomeSearchGrid.removeFilterCriteria = function(event, key, index) {
            event.stopPropagation();
            var resetColumn = false;
            if (key == 'Owner') {
                $scope.HomeSearchGrid.OwnerNameStr = '';
            }
            $scope.HomeSearchGrid.filterFormJson[key] = angular.copy($scope.HomeSearchGrid.initFilterFormJsonCopy[key]);
            if (key == 'Type') {
                $scope.HomeSearchGrid.filterFormJson = angular.copy($scope.HomeSearchGrid.initFilterFormJsonCopy);
                $scope.HomeSearchGrid.previousObjectList = angular.copy($scope.HomeSearchGrid.filterFormJson.Type.Objects);
                $scope.HomeSearchGrid.setDefaultPageSortAttrs();
                resetColumn = true;
            }
            if (index != undefined && index != null && (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, 'Invoiced Items') != -1) && $scope.HomeSearchGrid.searchCriteriaJson[index].Key == 'IsSummaryFormat') {
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = SortingListForDetailInvoicedItems;
            }
            if (key == 'Customer_Unit_Reg_Expiry' || key == 'Inventory_Unit_Reg_Expiry' || key == 'Service_Job_Scheduled') {
                $scope.nodateOptions.minDate = '';
                $scope.nodateOptionsreg.maxDate = '';
            }
            $scope.HomeSearchGrid.getFilteredRecords(resetColumn);
        }
        $scope.HomeSearchGrid.removeSortCriteria = function(index) {
            var SortingArray = angular.copy($scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting);
            if (index != -1) {
                SortingArray.splice(index, 1);
            }
            $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = SortingArray;
            if (!$scope.HomeSearchGrid.isReportMode) {
                $scope.HomeSearchGrid.getFilteredRecords(false);
            } else {
                $scope.HomeSearchGrid.SearchedReportData.sort($scope.dynamicSortMultiple($scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting));
                $scope.HomeSearchGrid.HSGrid_paginationControlsAction();
            }
        }
        var SortingListForDetailInvoicedItems = [{
            FieldName: "Type",
            FieldLabel: 'Type',
            ExportSort: 'Type',
            SortDirection: "ASC",
            Type: "Icon"
        }, {
            FieldName: "Item_Code__c",
            FieldLabel: 'Item',
            ExportSort: 'Item',
            SortDirection: "ASC",
            Type: "Link"
        }, {
            FieldName: "Invoice_Number__r.Invoice_Number__c",
            FieldLabel: 'Invoice',
            ExportSort: 'Invoice',
            SortDirection: "DESC",
            Type: "Text"
        }];
        var SortingListForPayrollItems = [{
            FieldName: "Technician__r.Technician_Name__c",
            FieldLabel: 'Employee',
            ExportSort: 'Employee',
            SortDirection: "ASC",
            Type: "Text"
        }, {
            FieldName: "Payroll_Date__c",
            FieldLabel: 'Clocked Date',
            ExportSort: 'Clocked Date',
            SortDirection: "ASC",
            Type: "Date"
        }, {
            FieldName: "In_Time__c",
            FieldLabel: 'Time In',
            ExportSort: 'Time In',
            SortDirection: "ASC",
            Type: "Text"
        }];
        var SortingListForSummaryInvoicedItems = [{
            FieldName: "Type",
            FieldLabel: 'Type',
            ExportSort: 'Type',
            SortDirection: "ASC",
            Type: "Icon"
        }, {
            FieldName: "Item_Code__c",
            FieldLabel: 'Item',
            ExportSort: 'Item',
            SortDirection: "ASC",
            Type: "Link"
        }];
        var SortingListForTechnicianPerfromance = [{
            FieldName: "Technician_Name__c",
            FieldLabel: 'Technician',
            ExportSort: 'Technician',
            SortDirection: "ASC",
            Type: "Text"
        }];
        var SortingListForTechnicianHours = [{
            FieldName: "Technician__r.Technician_Name__c",
            FieldLabel: "Technician",
            ExportSort: "Technician",
            SortDirection: "ASC",
            Type: "Text"
        }, {
            FieldName: "Work_Performed_Date__c",
            FieldLabel: 'Clocked Date',
            ExportSort: 'Clocked Date',
            SortDirection: "ASC",
            Type: "Date"
        }, {
            FieldName: "Start_Date_Time__c",
            FieldLabel: 'Time In',
            ExportSort: 'Time In',
            SortDirection: "ASC",
            Type: "Date"
        }];
         var SortingListForPartFIFO = [{
            FieldName: "Name",
            ExportSort: "Name",
            SortDirection: "ASC",
            Type: "Text"
        },{
            FieldName: "CreatedDate",
            ExportSort: "Part Number",
            SortDirection: "ASC",
            Type: "Date"
        }];
         var SortingListForTaxDetail = [{
             FieldName: "Invoice_Date__c",
             FieldLabel: 'Invoice Date',
             ExportSort: "Invoice Date",
             SortDirection: "ASC",
             Type: "Date"
         }];
        $scope.HomeSearchGrid.applyFilter = function() {
            if (angular.equals($scope.HomeSearchGrid.filterFormJsonCopy, $scope.HomeSearchGrid.filterFormJson)) {
                $scope.HomeSearchGrid.hideFilterForm();
                return;
            }
            $scope.HomeSearchGrid.selectedObjectList = angular.copy($scope.HomeSearchGrid.filterFormJson.Type.Objects);
            if (!angular.equals($scope.HomeSearchGrid.previousObjectList, $scope.HomeSearchGrid.filterFormJson.Type.Objects)) {
                $scope.HomeSearchGrid.previousObjectList = angular.copy($scope.HomeSearchGrid.filterFormJson.Type.Objects);
                $scope.HomeSearchGrid.resetColumn = true;
                $scope.HomeSearchGrid.groupNameResult = "";
                $scope.HomeSearchGrid.groupNameKey = "";
                $scope.HomeSearchGrid.outputResult = "";
                $scope.HomeSearchGrid.setDefaultPageSortAttrs();
            } else if($scope.HomeSearchGrid.filterFormJson.Type.Objects.includes('Tax Detail')) {
                $scope.HomeSearchGrid.resetColumn = true;
            } else {
                $scope.HomeSearchGrid.resetColumn = false;
            }
            if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, 'Invoiced Items') != -1) {
                if ($scope.HomeSearchGrid.filterFormJson.IsSummaryFormat) {
                    $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = [];
                } else {
                    $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = SortingListForDetailInvoicedItems;
                }
            } else if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, 'Technician Hours') != -1) {
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = SortingListForTechnicianHours;
            } else if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, 'Payroll Hours') != -1) {
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = SortingListForPayrollItems;
            } else if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, 'Technician Performance') != -1) {
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = SortingListForTechnicianPerfromance;
            } else if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, 'Part FIFO') != -1) {
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = SortingListForPartFIFO;
                if(!isDateRangeForPartFifoValid()) {
                    return;
                }
            } else if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, 'Tax Detail') != -1) {
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = SortingListForTaxDetail;
                 $scope.HomeSearchGrid.formMaterData.CopySalesTaxItemList = angular.copy($scope.HomeSearchGrid.formMaterData.SalesTaxItemList)
            }
           
            $scope.HomeSearchGrid.getFilteredRecords($scope.HomeSearchGrid.resetColumn);
        }
        var MAX_DAYS_PART_FIFO_SEARCH_LIMIT = 365;
        function isDateRangeForPartFifoValid() {
            if($scope.HomeSearchGrid.filterFormJson.Part_FIFO_Date && $scope.HomeSearchGrid.filterFormJson.Part_FIFO_Date.SelectedOption 
                    && $scope.HomeSearchGrid.filterFormJson.Part_FIFO_Date.SelectedOption == '5') {
                var date1 = new Date($scope.HomeSearchGrid.filterFormJson.Part_FIFO_Date.Value1);
                var date2 = new Date($scope.HomeSearchGrid.filterFormJson.Part_FIFO_Date.Value2);
                var timeDiff = date2.getTime() - date1.getTime();
                var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
                if(diffDays > MAX_DAYS_PART_FIFO_SEARCH_LIMIT) {
                    Notification.error($translate.instant('Narrow_search_date_range_message'));
                    return false;
                } else if(diffDays < 0) {
                    Notification.error($translate.instant('Invalid_date_range_message_1'));
                    return false;
                } else {
                    return true;
                }
            }
            return true;
        }
        $scope.HomeSearchGrid.isObjectSelected = function(objName) {
            if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, objName) != -1) {
                return true;
            }
            return false;
        }
        
        $scope.HomeSearchGrid.getFilteredRecords = function(isUpdateColumns) {
            if (!$scope.HomeSearchGrid.isReportMode) {
                var totalRecordsCount = ($scope.HomeSearchGrid.searchResultPageSortAttrsJSON.CurrentPage + 1) * $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.PageSize
                if (totalRecordsCount >= 50000) {
                    Notification.info($translate.instant('HomeSearch_Sorting_Limit'));
                    $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.CurrentPage--;
                    setTimeout(function() {
                        angular.element('[data-toggle="tooltip"]').tooltip();
                        $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.ChangesCount++;
                        if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') $scope.$apply();
                    }, 10);
                    return;
                }
            }
            $scope.HomeSearchGrid.DEFAULT_PAGE_SIZE = 50;
            $scope.HomeSearchGrid.currentPageNumber = 1;
            $scope.HomeSearchGrid.getPaginatedRecords = function(pageNumber) {
                $scope.HomeSearchGrid.isLocalPaginationAdded = true;
                $scope.HomeSearchGrid.currentPageNumber = pageNumber;
                endIndexForPaginatedRecords = (pageNumber-1) * $scope.HomeSearchGrid.DEFAULT_PAGE_SIZE + $scope.HomeSearchGrid.DEFAULT_PAGE_SIZE;
                endIndexForPaginatedRecords = endIndexForPaginatedRecords > ($scope.HomeSearchGrid.AllRecordsBeforePagination.length) 
                    ? ($scope.HomeSearchGrid.AllRecordsBeforePagination.length) : endIndexForPaginatedRecords;
                $scope.HomeSearchGrid.SearchedResult = $scope.HomeSearchGrid.AllRecordsBeforePagination.slice((pageNumber-1)*$scope.HomeSearchGrid.DEFAULT_PAGE_SIZE, endIndexForPaginatedRecords);
            } 
            $scope.HomeSearchGrid.isLocalPaginationAdded = false;
            $scope.HomeSearchGrid.displayGrid = false;
            $scope.HomeSearchGrid.hideFilterForm();
            HomeSearchFactory.getGridColumnsConfiguration(JSON.stringify($scope.HomeSearchGrid.filterFormJson.Type.Objects), JSON.stringify($scope.HomeSearchGrid.filterFormJson)).then(function(successfulResult) {
                if (isUpdateColumns) {
                    $scope.HomeSearchGrid.columns = {};
                    $scope.HomeSearchGrid.columns.DisplayedColumns = successfulResult.DisplayedColumns;
                    $scope.HomeSearchGrid.columns.HiddenColumns = successfulResult.HiddenColumns;
                    successfulResult = addDynamicColumnsToHomeSearchGrid(successfulResult);
                    $scope.HomeSearchGrid.recentColumns = angular.copy(successfulResult);
                    $scope.HomeSearchGrid.selectedObjectList = angular.copy($scope.HomeSearchGrid.filterFormJson.Type.Objects);
                }
                if (_.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Invoiced Items') != -1) {
                    if ($scope.HomeSearchGrid.IsSummaryFormat) {
                        $scope.HomeSearchGrid.groupNameResult = 'Type';
                        $scope.HomeSearchGrid.groupNameKey = 'Type';
                    } else {
                        $scope.HomeSearchGrid.groupNameResult = 'Item';
                        $scope.HomeSearchGrid.groupNameKey = 'Item';
                    }
                } else if (_.indexOf($scope.HomeSearchGrid.filterFormJson.Type.Objects, 'Technician Hours') != -1) {
                    $scope.HomeSearchGrid.groupNameResult = 'Technician';
                    $scope.HomeSearchGrid.groupNameKey = 'Technician';
                } else if (_.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Payroll Hours') != -1) {
                    $scope.HomeSearchGrid.groupNameResult = 'Employee';
                    $scope.HomeSearchGrid.groupNameKey = 'Employee';
                }
                if (successfulResult.MatchFilter == null) {
                    $scope.HomeSearchGrid.isFilterMatched = false;
                } else {
                    var a = successfulResult.MatchFilter.GridDisplayHiddenColumnsJSON;
                    $scope.HomeSearchGrid.isFilterMatched = true;
                    $scope.HomeSearchGrid.currentActiveFilter = successfulResult.MatchFilter;
                }
                $scope.HomeSearchGrid.isReportMode = false;
                if (!$scope.HomeSearchGrid.isReportMode) {
                    HomeSearchFactory.getFilteredRecords(JSON.stringify($scope.HomeSearchGrid.filterFormJson), JSON.stringify($scope.HomeSearchGrid.searchResultPageSortAttrsJSON)).then(function(successfulSearchResult) {
                        $scope.HomeSearchGrid.Total_Records = successfulSearchResult['Total_Records'];
                        $scope.HomeSearchGrid.isLocalPaginationAdded = false;
                        if(successfulSearchResult.RecordsVariableName === 'PartMovementRecords' || successfulSearchResult.RecordsVariableName ==='TaxDetailRecords') {
                            $scope.HomeSearchGrid.AllRecordsBeforePagination = successfulSearchResult[successfulSearchResult.RecordsVariableName];
                            if(successfulSearchResult.RecordsVariableName ==='TaxDetailRecords') {
                                sortingTaxDetailRecords().then(function(success) {
                                    $scope.HomeSearchGrid.getPaginatedRecords(1);
                                    $scope.HomeSearchGrid.isLocalPaginationAdded = true;
                                    $scope.HomeSearchGrid.groupNameResult = 'Invoice Type';
                                    $scope.HomeSearchGrid.groupNameKey = 'Invoice_Type';
                                }, function(error) {
                                    Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
                                });
                            }
                            else {
                                sortingPartMovementRecords().then(function(success) {
                                    $scope.HomeSearchGrid.getPaginatedRecords(1);
                                    $scope.HomeSearchGrid.isLocalPaginationAdded = true;
                                    $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting = [];
                                }, function(error) {
                                    Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
                                });
                            }
                        } else {
                            $scope.HomeSearchGrid.SearchedResult = successfulSearchResult[successfulSearchResult.RecordsVariableName];
                            $scope.HomeSearchGrid.currentPageNumber = 1;
                        }
                        $scope.HomeSearchGrid.searchCriteriaJson = successfulSearchResult.FilterLabelList;
                        $scope.HomeSearchGrid.displayGrid = true;
                        $scope.HomeSearchGrid.IsIncludeInactiveRecords = successfulSearchResult.IsIncludeInactiveRecords;
                        $scope.HomeSearchGrid.IsSummaryFormat = successfulSearchResult.IsSummaryFormat;
                        $scope.HomeSearchGrid.getGridSummary();
                        if (_.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Invoiced Items') != -1) {
                            if ($scope.HomeSearchGrid.IsSummaryFormat) {
                                $scope.HomeSearchGrid.Total_Records = $scope.HomeSearchGrid.SearchedResult.length;
                                $scope.HomeSearchGrid.groupNameResult = 'Type';
                                $scope.HomeSearchGrid.groupNameKey = 'Type';
                            } else {
                                $scope.HomeSearchGrid.groupNameResult = 'Item';
                                $scope.HomeSearchGrid.groupNameKey = 'Item';
                            }
                        }
                        setTimeout(function() {
                            angular.element('[data-toggle="tooltip"]').tooltip();
                            $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.ChangesCount++;
                            var HomeSearchResultDivWidth = angular.element('#myTable').width();
                            HomeSearchResultDivWidth = HomeSearchResultDivWidth + 20 + 'px';
                            angular.element('#HomeSearchresultDiv').css('position', 'absolute');
                            angular.element('#HomeSearchresultDiv').css('left', HomeSearchResultDivWidth);
                            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') $scope.$apply();
                        }, 10);
                    }, function(errorSearchResult) {
                        $scope.HomeSearchGrid.SearchedResult = [];
                        Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
                        $scope.HomeSearchGrid.displayGrid = true;
                    });
                } else {
                    $scope.HomeSearchGrid.SearchedReportData = [];
                    var ObjectsList;
                    if ($scope.HomeSearchGrid.filterFormJson.Type.Objects.length != 0) {
                        ObjectsList = angular.copy($scope.HomeSearchGrid.filterFormJson.Type.Objects);
                    } else {
                        ObjectsList = angular.copy($scope.HomeSearchGrid.objectsList);
                    }
                    ObjectsList = ObjectsList.remove('Any');
                    $scope.HomeSearchGrid.objectsReportingDataCall(ObjectsList);
                }
                $scope.HomeSearchGrid.getActiveTag();
            }, function(errorSearchResult) {
                $scope.HomeSearchGrid.searchedResult = errorSearchResult;
                Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
                $scope.HomeSearchGrid.displayGrid = true;
            });
        }
        function addDynamicColumnsToHomeSearchGrid(successfullResult) {
            if($scope.HomeSearchGrid.filterFormJson.Type.Objects.includes('Tax Detail')) {
                for(var j = 0; j <$scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items.length; j++) {
                    if(successfullResult) {
                        successfullResult.DisplayedColumns.push(
                                {
                                    'Label': 'Taxable:'+ $scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items[j],
                                    'IsDisplayed': true,
                                    'Type': 'Dynamic Currency',
                                    'RecordKey': 'Taxable:' + $scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items[j] 
                                },
                                {
                                    'Label': 'Tax:'+ $scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items[j],
                                    'IsDisplayed': true,
                                    'Type': 'Dynamic Currency',
                                    'RecordKey': 'Tax:'+ $scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items[j] 
                                });
                    } else {
                        $scope.HomeSearchGrid.columns.DisplayedColumns.push(
                                {
                                    'Label': 'Taxable:'+ $scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items[j],
                                    'IsDisplayed': true,
                                    'Type': 'Dynamic Currency',
                                    'RecordKey': 'Taxable:'+$scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items[j] 
                                },
                                {
                                    'Label': 'Tax:'+ $scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items[j],
                                    'IsDisplayed': true,
                                    'Type': 'Dynamic Currency',
                                    'RecordKey': 'Tax:'+$scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items[j] 
                                });
                    }
                    }
                    
            }
            if(successfullResult) {
                return successfullResult;
            }
        }
        function sortingPartMovementRecords() {
            var defer = $q.defer();
            defer.resolve($scope.HomeSearchGrid.AllRecordsBeforePagination.sort(function(a, b){
                if(a.Part_Number.toUpperCase() < b.Part_Number.toUpperCase()) return -1;
                if(a.Part_Number.toUpperCase() > b.Part_Number.toUpperCase()) return 1;
                return 0;
            }));
            return defer.promise;
        }
        function sortingTaxDetailRecords() {
            var defer = $q.defer();
            defer.resolve($scope.HomeSearchGrid.AllRecordsBeforePagination.sort(function(a, b){
                if(a.Invoice_Date.toUpperCase() < b.Invoice_Date.toUpperCase()) return -1;
                if(a.Invoice_Date.toUpperCase() > b.Invoice_Date.toUpperCase()) return 1;
                return 0;
            }));
            return defer.promise;
        }
        $scope.HomeSearchGrid.objectsReportingDataCall = function(ObjectsList) {
            if (ObjectsList.length != 0) {
                $scope.HomeSearchGrid.getAllReportData(ObjectsList[0], null, ObjectsList);
            } else {
                return;
            }
        }
        $scope.HomeSearchGrid.getAllReportData = function(objectName, uniqueValueFieldLastValue, ObjectsList) {
            HomeSearchFactory.getReportData(JSON.stringify($scope.HomeSearchGrid.filterFormJson), objectName, uniqueValueFieldLastValue).then(function(reportResult) {
                $scope.HomeSearchGrid.SearchedReportData = $scope.HomeSearchGrid.SearchedReportData.concat(reportResult.ResultData[reportResult.ResultData.RecordsVariableName]);
                if (!reportResult.IsProcessCompleted) {
                    $scope.HomeSearchGrid.getAllReportData(objectName, reportResult.UniqueFieldName, ObjectsList);
                } else {
                    if (ObjectsList.length > 1) {
                        ObjectsList.splice(0, 1);
                        $scope.HomeSearchGrid.objectsReportingDataCall(ObjectsList);
                    } else {
                        // All Process got completed here to get reporting data
                        $scope.HomeSearchGrid.Total_Records = $scope.HomeSearchGrid.SearchedReportData.length;
                        $scope.HomeSearchGrid.searchCriteriaJson = reportResult.FilterLabelList;
                        setTimeout(function() {
                            angular.element('[data-toggle="tooltip"]').tooltip();
                            $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.ChangesCount++;
                            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') $scope.$apply();
                        }, 10);
                        $scope.HomeSearchGrid.SearchedReportData.sort($scope.dynamicSortMultiple($scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting));
                        $scope.HomeSearchGrid.HSGrid_paginationControlsAction();
                        $scope.HomeSearchGrid.getGridSummary();
                    }
                    return true;
                }
            }, function(errorSearchResult) {
                $scope.HomeSearchGrid.GridSummaryData = [];
                Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
            });
        }
        function getTotalGridSummaryRecordForTaxDetails() {
            var taxDetail = {};
            var tempJSon = {};
            var tempJSon1 = {}
                $scope.HomeSearchGrid.TaxDetailTaxItemToValueMap = {};
                for(var i = 0; i < $scope.HomeSearchGrid.AllRecordsBeforePagination.length; i++) {
                    angular.forEach($scope.HomeSearchGrid.AllRecordsBeforePagination[i].TaxItemRecs, function(value, keyTax) {
                        taxDetail = {Taxable : 0, TaxAmount : 0};
                        if($scope.HomeSearchGrid.TaxDetailTaxItemToValueMap.hasOwnProperty(keyTax)) {
                            taxDetail = $scope.HomeSearchGrid.TaxDetailTaxItemToValueMap[keyTax];
                        }
                        taxDetail.Taxable += value[0];
                        taxDetail.TaxAmount += value[1];
                        $scope.HomeSearchGrid.TaxDetailTaxItemToValueMap[keyTax] = taxDetail;
                    });
                }
                  angular.forEach($scope.HomeSearchGrid.TaxDetailTaxItemToValueMap, function(value, key) {
                    for(var i=0; i<$scope.HomeSearchGrid.columns.DisplayedColumns.length;i++){
                        if($scope.HomeSearchGrid.columns.DisplayedColumns[i].Type == 'Dynamic Currency' && $scope.HomeSearchGrid.columns.DisplayedColumns[i].RecordKey == "Taxable:" + key) {
                            tempJSon = {
                                IsDisplayed: $scope.HomeSearchGrid.columns.DisplayedColumns[i].IsDisplayed,
                                Label: "Taxable:" + key,
                                RecordKey: "Taxable:" + key,
                                TotalValue: value.Taxable,
                                Type: "Currency"
                            }
                             $scope.HomeSearchGrid.exportDisplayedColumns.push(tempJSon);
                             $scope.HomeSearchGrid.summaryDisplayedColumns.push(tempJSon);
                             $scope.HomeSearchGrid.copySummaryDisplayColumns.push(tempJSon);
                             $scope.HomeSearchGrid.copyExportDisplayColumns.push(tempJSon);
                        } else if($scope.HomeSearchGrid.columns.DisplayedColumns[i].Type == 'Dynamic Currency' && $scope.HomeSearchGrid.columns.DisplayedColumns[i].RecordKey == "Tax:" + key) {
                            tempJSon1 = {
                                IsDisplayed: $scope.HomeSearchGrid.columns.DisplayedColumns[i].IsDisplayed,
                                Label: "Tax:" + key,
                                RecordKey: "Tax:" + key,
                                TotalValue: value.TaxAmount,
                                Type: "Currency"
                            }
                            $scope.HomeSearchGrid.exportDisplayedColumns.push(tempJSon1);
                            $scope.HomeSearchGrid.summaryDisplayedColumns.push(tempJSon1);
                            $scope.HomeSearchGrid.copySummaryDisplayColumns.push(tempJSon1);
                            $scope.HomeSearchGrid.copyExportDisplayColumns.push(tempJSon1)
                        }
                        
                    }
                });

        }

        $scope.HomeSearchGrid.getGridSummary = function() {
            $scope.HomeSearchGrid.selectedObjectList = angular.copy($scope.HomeSearchGrid.filterFormJson.Type.Objects);
            if (_.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Technician Performance') == -1 &&  _.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Part FIFO') == -1) {
                HomeSearchFactory.getReportingRecords(JSON.stringify($scope.HomeSearchGrid.filterFormJson)).then(function(GridSummaryResult) {
                    $scope.HomeSearchGrid.GridSummaryData = GridSummaryResult;
                    var index = _.findIndex(GridSummaryResult, {
                        RecordKey: "TotalRecords"
                    });
                    if ($scope.HomeSearchGrid.filterFormJson.Type.Objects.length == 0 && $scope.HomeSearchGrid.Total_Records != -1) {
                        $scope.HomeSearchGrid.TotalRecords = $scope.HomeSearchGrid.Total_Records;
                    } else {
                        $scope.HomeSearchGrid.TotalRecords = $scope.HomeSearchGrid.GridSummaryData[index].TotalValue;
                    }
                    if (_.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Invoiced Items') != -1) {
                        if ($scope.HomeSearchGrid.IsSummaryFormat) {
                            $scope.HomeSearchGrid.TotalRecords = $scope.HomeSearchGrid.Total_Records;
                        }
                    }
                    $scope.HomeSearchGrid.GridSummaryData.splice(index, 1);
                    $scope.HomeSearchGrid.GridSummaryDataForExport = angular.copy($scope.HomeSearchGrid.GridSummaryData);
                    if (!$scope.HomeSearchGrid.isFilterMatched) {
                        $scope.HomeSearchGrid.getActiveSummaryRecord();
                    } else {
                        var filterObj = $scope.HomeSearchGrid.currentActiveFilter;
                        var FilterRecord;
                        $scope.HomeSearchGrid.currentActiveFilter = {
                            Id: filterObj.Id,
                            Name: filterObj.FilterLabel,
                            Type: filterObj.Type
                        };
                        if ($scope.HomeSearchGrid.currentActiveFilter.Name == null || $scope.HomeSearchGrid.currentActiveFilter.Name == "") {
                            $scope.HomeSearchGrid.currentActiveFilter.Name = filterObj.Name;
                        }
                        SideBarFactory.getFilterFields(filterObj.Id).then(function(successfulSearchResult) {
                            FilterRecord = successfulSearchResult;
                            FilterRecord.FieldFilterJson = JSON.parse(FilterRecord.FieldFilterJson);
                            HomeSearchFactory.getGridFilterConfigurations(JSON.stringify(FilterRecord.FieldFilterJson.Type.Objects)).then(function(successfulSearchResult) {
                                $scope.HomeSearchGrid.filterFormJson = FilterRecord.FieldFilterJson;
                                $scope.HomeSearchGrid.formMaterData.DisplayIncludeInactive = successfulSearchResult.DisplayIncludeInactive;
                                $scope.HomeSearchGrid.formMaterData.DisplayTag = successfulSearchResult.DisplayTag;
                                $scope.HomeSearchGrid.formMaterData.SJJobTypes = successfulSearchResult.SJJobTypes;
                                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON = JSON.parse(FilterRecord.SortJson);
                                $scope.HomeSearchGrid.formMaterData.AdditionalFields = JSON.parse(FilterRecord.AdditionalFieldJson);
                                if (JSON.parse(FilterRecord.SummaryFieldsJSON) != undefined) {
                                    $scope.HomeSearchGrid.summaryDisplayedColumns = JSON.parse(FilterRecord.SummaryFieldsJSON).visible;
                                    $scope.HomeSearchGrid.dropdownSummaryDisplayedColumns = JSON.parse(FilterRecord.SummaryFieldsJSON).visible;
                                    var i;
                                    if ($scope.HomeSearchGrid.summaryDisplayedColumns != undefined) {
                                        for (i = 0; i < $scope.HomeSearchGrid.summaryDisplayedColumns.length; i++) {
                                            var index = _.findIndex($scope.HomeSearchGrid.GridSummaryData, {
                                                RecordKey: $scope.HomeSearchGrid.summaryDisplayedColumns[i].RecordKey
                                            });
                                            if (index != -1) {
                                                $scope.HomeSearchGrid.summaryDisplayedColumns[i].TotalValue = $scope.HomeSearchGrid.GridSummaryData[index].TotalValue;
                                            }
                                        }
                                    }
                                    $scope.HomeSearchGrid.summaryHiddenColumns = JSON.parse(FilterRecord.SummaryFieldsJSON).Hidden;
                                    var j;
                                    if ($scope.HomeSearchGrid.summaryHiddenColumns != undefined) {
                                        for (j = 0; j < $scope.HomeSearchGrid.summaryHiddenColumns.length; j++) {
                                            var index = _.findIndex($scope.HomeSearchGrid.GridSummaryData, {
                                                RecordKey: $scope.HomeSearchGrid.summaryHiddenColumns[j].RecordKey
                                            });
                                            if (index != -1) {
                                                $scope.HomeSearchGrid.summaryHiddenColumns[j].TotalValue = $scope.HomeSearchGrid.GridSummaryData[index].TotalValue;
                                            }
                                        }
                                    }
                                    $scope.HomeSearchGrid.copySummaryDisplayColumns = angular.copy($scope.HomeSearchGrid.summaryDisplayedColumns);
                                    $scope.HomeSearchGrid.copySummaryHiddenColumns = angular.copy($scope.HomeSearchGrid.summaryHiddenColumns);
                                }
                                if (JSON.parse(FilterRecord.ExportFieldsJSON) != undefined) {
                                    $scope.HomeSearchGrid.exportDisplayedColumns = JSON.parse(FilterRecord.ExportFieldsJSON).visible;
                                    $scope.HomeSearchGrid.dropdownExportDisplayedColumns = JSON.parse(FilterRecord.ExportFieldsJSON).visible;
                                    var i;
                                    if ($scope.HomeSearchGrid.exportDisplayedColumns != undefined) {
                                        for (i = 0; i < $scope.HomeSearchGrid.exportDisplayedColumns.length; i++) {
                                            var index = _.findIndex($scope.HomeSearchGrid.GridSummaryData, {
                                                RecordKey: $scope.HomeSearchGrid.exportDisplayedColumns[i].RecordKey
                                            });
                                            if (index != -1) {
                                                $scope.HomeSearchGrid.exportDisplayedColumns[i].TotalValue = $scope.HomeSearchGrid.GridSummaryData[index].TotalValue;
                                            }
                                        }
                                    }
                                    $scope.HomeSearchGrid.exportHiddenColumns = JSON.parse(FilterRecord.ExportFieldsJSON).Hidden;
                                    var j;
                                    if ($scope.HomeSearchGrid.exportHiddenColumns != undefined) {
                                        for (j = 0; j < $scope.HomeSearchGrid.exportHiddenColumns.length; j++) {
                                            var index = _.findIndex($scope.HomeSearchGrid.GridSummaryData, {
                                                RecordKey: $scope.HomeSearchGrid.exportHiddenColumns[j].RecordKey
                                            });
                                            if (index != -1) {
                                                $scope.HomeSearchGrid.exportHiddenColumns[j].TotalValue = $scope.HomeSearchGrid.GridSummaryData[index].TotalValue;
                                            }
                                        }
                                    }
                                    $scope.HomeSearchGrid.copyExportDisplayColumns = angular.copy($scope.HomeSearchGrid.exportDisplayedColumns);
                                    $scope.HomeSearchGrid.copyExportHiddenColumns = angular.copy($scope.HomeSearchGrid.exportHiddenColumns);
                                }
                                $scope.HomeSearchGrid.outputResult = FilterRecord.ExportFileFormat;
                                $scope.HomeSearchGrid.groupNameResult = FilterRecord.ExportGroupField;
                                $scope.HomeSearchGrid.isReportMode = FilterRecord.IsReportOn;
                            }, function(errorSearchResult) {
                                $scope.HomeSearchGrid.searchedResult = errorSearchResult;
                                Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
                            });
                        }, function(errorSearchResult) {
                            $scope.HomeSearchGrid.filterList.FilterType = errorSearchResult;
                        });
                    }
                    setTimeout(function() {
                        angular.element('[data-toggle="tooltip"]').tooltip();
                        $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.ChangesCount++;
                        if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') $scope.$apply(); //TODO
                    }, 10);
                    if(_.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Tax Detail') != -1) {
                         getTotalGridSummaryRecordForTaxDetails();
                    }
                    
                }, function(errorSearchResult) {
                    $scope.HomeSearchGrid.GridSummaryData = [];
                    Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
                });
            } else if(_.indexOf($scope.HomeSearchGrid.selectedObjectList, 'Part FIFO') != -1) {
                var totalOpeningQty, totalOpeningValue, totalPurchasedQty, totalSalesQty, totalAdjustedQty, 
                    totalClosingQty, grossTotalSales, totalClosingValue, totalPurchasedCost, totalCostOfSales, totalAdjustedCost ; 
                totalOpeningQty = totalOpeningValue = totalPurchasedQty = totalSalesQty = totalAdjustedQty 
                    = totalClosingQty = grossTotalSales = totalClosingValue = totalPurchasedCost = totalCostOfSales = totalAdjustedCost = 0.00;
                var partFoundIdSet = [];
                for(var i = 0; i < $scope.HomeSearchGrid.AllRecordsBeforePagination.length; i++) {
                    totalOpeningQty += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Opening_Qty) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Opening_Qty : 0.00;
                    totalOpeningValue += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Opening_Value) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Opening_Value : 0.00;
                    totalPurchasedQty += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Purchased_Qty) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Purchased_Qty : 0.00;
                    totalSalesQty += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Sales_Qty) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Sales_Qty : 0.00;
                    totalAdjustedQty += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Adjusted_Qty) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Adjusted_Qty : 0.00;
                    totalClosingQty += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Closing_Qty) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Closing_Qty : 0.00;
                    grossTotalSales += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Total_Sales) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Total_Sales : 0.00;
                    totalClosingValue += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Closing_Value) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Closing_Value : 0.00;
                    totalPurchasedCost += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Purchased_Cost) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Purchased_Cost : 0.00; 
                    totalCostOfSales += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Cost_of_Sales) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Cost_of_Sales : 0.00;
                    totalAdjustedCost += !isBlankValue($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Adjusted_Cost) ? $scope.HomeSearchGrid.AllRecordsBeforePagination[i].Adjusted_Cost : 0.00;
                    partFoundIdSet.push($scope.HomeSearchGrid.AllRecordsBeforePagination[i].Id);
                }
                $scope.HomeSearchGrid.TotalRecords = $scope.HomeSearchGrid.AllRecordsBeforePagination.length;
                $scope.HomeSearchGrid.GridSummaryData = [];
                console.log('partFoundIdSet',partFoundIdSet);
                HomeSearchFactory.getPartWithNoActivity(JSON.stringify(partFoundIdSet), JSON.stringify($scope.HomeSearchGrid.filterFormJson)).then(function(result) {
                	console.log('result', result);
            		totalOpeningQty += !isBlankValue(result[0]) ? result[0] : 0.00;
                    totalOpeningValue += !isBlankValue(result[1]) ? result[1] : 0.00;
                    totalClosingQty += !isBlankValue(result[0]) ? result[0] : 0.00;
                    totalClosingValue += !isBlankValue(result[1]) ? result[1] : 0.00;
                    $scope.HomeSearchGrid.TotalRecords += result[2];
                	$scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Opening_Qty',
                        'Label': 'Opening Qty',
                        'TotalValue': totalOpeningQty,
                        'IsDisplayed': true,
                        'Type': 'Number'
                    });
                    $scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Opening_Value',
                        'Label': 'Opening Value',
                        'TotalValue': totalOpeningValue,
                        'IsDisplayed': true,
                        'Type': 'Number'
                    });
                    $scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Purchased_Qty',
                        'Label': 'Purchased Qty',
                        'TotalValue': totalPurchasedQty,
                        'IsDisplayed': true,
                        'Type': 'Number'
                    });
                    $scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Sales_Qty',
                        'Label': 'Sales Qty',
                        'TotalValue': totalSalesQty,
                        'IsDisplayed': true,
                        'Type': 'Number'
                    });
                    $scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Adjusted_Qty',
                        'Label': 'Adjusted Qty',
                        'TotalValue': totalAdjustedQty,
                        'IsDisplayed': true,
                        'Type': 'Number'
                    });
                    $scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Closing_Qty',
                        'Label': 'Closing Qty',
                        'TotalValue': totalClosingQty,
                        'IsDisplayed': true,
                        'Type': 'Number'
                    });
                    $scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Total_Sales',
                        'Label': 'Total Sales',
                        'TotalValue': grossTotalSales,
                        'IsDisplayed': true,
                        'Type': 'Number'
                    });
                    $scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Closing_Value',
                        'Label': 'Closing Value',
                        'TotalValue': totalClosingValue,
                        'IsDisplayed': true,
                        'Type': 'Number'
                    });
                    $scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Purchased_Cost',
                        'Label': 'Purchased Cost',
                        'TotalValue': totalPurchasedCost,
                        'IsDisplayed': false,
                        'Type': 'Number'
                    });
                    $scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Cost_of_Sales',
                        'Label': 'Cost of Sales',
                        'TotalValue': totalCostOfSales,
                        'IsDisplayed': false,
                        'Type': 'Number'
                    });
                    $scope.HomeSearchGrid.GridSummaryData.push({
                        'RecordKey': 'Adjusted_Cost',
                        'Label': 'Adjusted Cost',
                        'TotalValue': totalAdjustedCost,
                        'IsDisplayed': false,
                        'Type': 'Number'
                    });
                    
                    $scope.HomeSearchGrid.summaryDisplayedColumns = $scope.HomeSearchGrid.GridSummaryData;
                    $scope.HomeSearchGrid.dropdownSummaryDisplayedColumns = $scope.HomeSearchGrid.GridSummaryData;
                    $scope.HomeSearchGrid.summaryHiddenColumns = [];
                    $scope.HomeSearchGrid.copySummaryDisplayColumns = angular.copy($scope.HomeSearchGrid.summaryDisplayedColumns);
                    $scope.HomeSearchGrid.copySummaryHiddenColumns = angular.copy($scope.HomeSearchGrid.summaryHiddenColumns);
                    $scope.HomeSearchGrid.GridSummaryDataForExport = angular.copy($scope.HomeSearchGrid.GridSummaryData);
                    $scope.HomeSearchGrid.exportDisplayedColumns = $scope.HomeSearchGrid.GridSummaryData;
                    $scope.HomeSearchGrid.dropdownExportDisplayedColumns = $scope.HomeSearchGrid.GridSummaryData;
                    $scope.HomeSearchGrid.exportHiddenColumns = [];
                    $scope.HomeSearchGrid.copyExportDisplayColumns = angular.copy($scope.HomeSearchGrid.exportDisplayedColumns);
                    $scope.HomeSearchGrid.copyExportHiddenColumns = angular.copy($scope.HomeSearchGrid.exportHiddenColumns);
                });
                
            } else {
                $scope.HomeSearchGrid.TotalRecords = $scope.HomeSearchGrid.SearchedResult.length;
                var clockedHrsInvoiced = 0.00;
                var hrsWorked = 0.00;
                var hrsClockedOn = 0.00;
                var invoiceHrs = 0.00;
                var otherTaskHrs = 0.00;
                var uninvoicedClockedHrs = 0.00;
                for (var i = 0; i < $scope.HomeSearchGrid.SearchedResult.length; i++) {
                    if (!isBlankValue($scope.HomeSearchGrid.SearchedResult[i].Clocked_Hrs_Invoiced)) {
                        clockedHrsInvoiced += $scope.HomeSearchGrid.SearchedResult[i].Clocked_Hrs_Invoiced;
                    }
                    if (!isBlankValue($scope.HomeSearchGrid.SearchedResult[i].Hours_Worked)) {
                        hrsWorked += $scope.HomeSearchGrid.SearchedResult[i].Hours_Worked;
                    }
                    if (!isBlankValue($scope.HomeSearchGrid.SearchedResult[i].Hrs_Clocked_On)) {
                        hrsClockedOn += $scope.HomeSearchGrid.SearchedResult[i].Hrs_Clocked_On;
                    }
                    if (!isBlankValue($scope.HomeSearchGrid.SearchedResult[i].Invoice_Hrs)) {
                        invoiceHrs += $scope.HomeSearchGrid.SearchedResult[i].Invoice_Hrs;
                    }
                    if (!isBlankValue($scope.HomeSearchGrid.SearchedResult[i].Other_Tasks_Hrs)) {
                        otherTaskHrs += $scope.HomeSearchGrid.SearchedResult[i].Other_Tasks_Hrs;
                    }
                    if (!isBlankValue($scope.HomeSearchGrid.SearchedResult[i].Uninvoiced_Clocked_Hrs)) {
                        uninvoicedClockedHrs += $scope.HomeSearchGrid.SearchedResult[i].Uninvoiced_Clocked_Hrs;
                    }
                }
                $scope.HomeSearchGrid.GridSummaryData = [];
                $scope.HomeSearchGrid.GridSummaryData.push({
                    'RecordKey': 'Hours_Worked',
                    'Label': 'Hrs Worked',
                    'TotalValue': hrsWorked,
                    'IsDisplayed': true,
                    'Type': 'Number'
                });
                $scope.HomeSearchGrid.GridSummaryData.push({
                    'RecordKey': 'Hrs_Clocked_On',
                    'Label': 'Hrs Clocked On',
                    'TotalValue': hrsClockedOn,
                    'IsDisplayed': true,
                    'Type': 'Number'
                });
                $scope.HomeSearchGrid.GridSummaryData.push({
                    'RecordKey': 'Clocked_Hrs_Invoiced',
                    'Label': 'Clocked Hrs Invoiced',
                    'TotalValue': clockedHrsInvoiced,
                    'IsDisplayed': true,
                    'Type': 'Number'
                });
                $scope.HomeSearchGrid.GridSummaryData.push({
                    'RecordKey': 'Invoice_Hrs',
                    'Label': 'Invoice Hrs',
                    'TotalValue': invoiceHrs,
                    'IsDisplayed': true,
                    'Type': 'Number'
                });
                $scope.HomeSearchGrid.GridSummaryData.push({
                    'RecordKey': 'Uninvoiced_Clocked_Hrs',
                    'Label': 'Uninvoiced Clocked Hrs',
                    'TotalValue': uninvoicedClockedHrs,
                    'IsDisplayed': true,
                    'Type': 'Number'
                });
                $scope.HomeSearchGrid.GridSummaryData.push({
                    'RecordKey': 'Other_Tasks_Hrs',
                    'Label': 'Other Tasks Hrs',
                    'TotalValue': otherTaskHrs,
                    'IsDisplayed': true,
                    'Type': 'Number'
                });
                $scope.HomeSearchGrid.summaryDisplayedColumns = $scope.HomeSearchGrid.GridSummaryData;
                $scope.HomeSearchGrid.dropdownSummaryDisplayedColumns = $scope.HomeSearchGrid.GridSummaryData;
                $scope.HomeSearchGrid.summaryHiddenColumns = [];
                $scope.HomeSearchGrid.copySummaryDisplayColumns = angular.copy($scope.HomeSearchGrid.summaryDisplayedColumns);
                $scope.HomeSearchGrid.copySummaryHiddenColumns = angular.copy($scope.HomeSearchGrid.summaryHiddenColumns);
                $scope.HomeSearchGrid.GridSummaryDataForExport = angular.copy($scope.HomeSearchGrid.GridSummaryData);
                $scope.HomeSearchGrid.exportDisplayedColumns = $scope.HomeSearchGrid.GridSummaryData;
                $scope.HomeSearchGrid.dropdownExportDisplayedColumns = $scope.HomeSearchGrid.GridSummaryData;
                $scope.HomeSearchGrid.exportHiddenColumns = [];
                $scope.HomeSearchGrid.copyExportDisplayColumns = angular.copy($scope.HomeSearchGrid.exportDisplayedColumns);
                $scope.HomeSearchGrid.copyExportHiddenColumns = angular.copy($scope.HomeSearchGrid.exportHiddenColumns);
            }
        }
        // Keyboard Handling of Tags autocomplete
        $scope.HomeSearchGrid.changeSeletedTag = function(event) {
            var keyCode = event.which ? event.which : event.keyCode;
            if (keyCode === 40) {
                if (($scope.HomeSearchGrid.FilteredTagList.length - 1) > $scope.HomeSearchGrid.currentSelectedTagIndex) {
                    $scope.HomeSearchGrid.currentSelectedTagIndex++;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.HomeSearchGrid.currentSelectedTagIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.HomeSearchGrid.currentSelectedTagIndex > 0) {
                    $scope.HomeSearchGrid.currentSelectedTagIndex--;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.HomeSearchGrid.currentSelectedTagIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 13) {
                $scope.HomeSearchGrid.selectTag($scope.HomeSearchGrid.FilteredTagList[$scope.HomeSearchGrid.currentSelectedTagIndex]);
                $scope.HomeSearchGrid.currentSelectedTagIndex = -1;
                $scope.HomeSearchGrid.closeAutocomplete('applyBtn');
            }
        }
        $scope.HomeSearchGrid.closeAutocomplete = function(eleId) {
            angular.element('#' + eleId).focus();
        }
        $scope.HomeSearchGrid.onFocusOnTagInput = function() {
            $scope.HomeSearchGrid.isFocused = true;
            if (!$scope.HomeSearchGrid.isAlreadyFocusedOnTagInput) {
                $scope.HomeSearchGrid.isAlreadyFocusedOnTagInput = true;
                $scope.HomeSearchGrid.resetTagList();
            }
            angular.element('.fixedHeight').stop().animate({
                scrollTop: 400
            }, 400);
        }
        $scope.HomeSearchGrid.resetTagList = function() {
            for (var i = 0; i < $scope.HomeSearchGrid.filterFormJson.AssignedTags.length; i++) {
                var index = _.findIndex($scope.HomeSearchGrid.ActiveTagList, {
                    Name: $scope.HomeSearchGrid.filterFormJson.AssignedTags[i]
                });
                if (index > -1) {
                    $scope.HomeSearchGrid.ActiveTagList.splice(index, 1);
                }
            }
        }
        $scope.HomeSearchGrid.selectTag = function(tagObj) {
            var index = _.findIndex($scope.HomeSearchGrid.ActiveTagList, {
                Name: tagObj.Name
            });
            if (index > -1) {
                if ($scope.HomeSearchGrid.filterFormJson.AssignedTags.length < 20) {
                    $scope.HomeSearchGrid.filterFormJson.AssignedTags.push(tagObj.Name);
                    $scope.HomeSearchGrid.ActiveTagList.splice(index, 1);
                } else {
                    Notification.error('Cannot add more than 20 tags');
                }
            }
            $scope.HomeSearchGrid.TagNameStr = '';
        };
        $scope.HomeSearchGrid.removeTag = function(tagObj, index) {
            if (index > -1) {
                $scope.HomeSearchGrid.filterFormJson.AssignedTags.splice(index, 1);
                $scope.HomeSearchGrid.ActiveTagList.push({
                    Name: tagObj,
                    Id: tagObj
                });
            }
        };
        $scope.HomeSearchGrid.removeAllTag = function() {
            for (var i = 0; i < $scope.HomeSearchGrid.filterFormJson.AssignedTags.length; i++) {
                $scope.HomeSearchGrid.ActiveTagList.push({
                    'Name': $scope.HomeSearchGrid.filterFormJson.AssignedTags[i]
                });
            }
            $scope.HomeSearchGrid.filterFormJson.AssignedTags = [];
        }
        $scope.HomeSearchGrid.getActiveTag = function() {
            HomeSearchFactory.getActiveTagList().then(function(tagList) {
                $scope.HomeSearchGrid.ActiveTagList = tagList;
                $scope.HomeSearchGrid.isAlreadyFocusedOnTagInput = false;
            }, function(errorSearchResult) {
                $scope.HomeSearchGrid.searchedResult = errorSearchResult;
                Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
            });
        }
        $scope.HomeSearchGrid.getActiveSummaryRecord = function() {
            angular.forEach($scope.HomeSearchGrid.GridSummaryData, function(value, key) {
                var index = _.findIndex($scope.HomeSearchGrid.columns.DisplayedColumns, {
                    RecordKey: value['RecordKey']
                });
                if (index >= 0) {
                    value['IsDisplayed'] = $scope.HomeSearchGrid.columns.DisplayedColumns[index].IsDisplayed;
                } else {
                    value['IsDisplayed'] = false;
                }
            });
            var DisplayedCols = [];
            var HiddenCols = [];
            for (i = 0; i < $scope.HomeSearchGrid.GridSummaryData.length; i++) {
                if ($scope.HomeSearchGrid.GridSummaryData[i].Type == 'Number' || $scope.HomeSearchGrid.GridSummaryData[i].Type == 'Currency') {
                    if ($scope.HomeSearchGrid.GridSummaryData[i].IsDisplayed) {
                        DisplayedCols.push($scope.HomeSearchGrid.GridSummaryData[i]);
                    } else {
                        HiddenCols.push($scope.HomeSearchGrid.GridSummaryData[i]);
                    }
                }
            }
            $scope.HomeSearchGrid.summaryDisplayedColumns = DisplayedCols;
            $scope.HomeSearchGrid.dropdownSummaryDisplayedColumns = DisplayedCols;
            $scope.HomeSearchGrid.summaryHiddenColumns = HiddenCols;
            $scope.HomeSearchGrid.copySummaryDisplayColumns = angular.copy($scope.HomeSearchGrid.summaryDisplayedColumns);
            $scope.HomeSearchGrid.copySummaryHiddenColumns = angular.copy($scope.HomeSearchGrid.summaryHiddenColumns);
            angular.forEach($scope.HomeSearchGrid.GridSummaryDataForExport, function(value, key) {
                var index = _.findIndex($scope.HomeSearchGrid.columns.DisplayedColumns, {
                    RecordKey: value['RecordKey']
                });
                if (index >= 0) {
                    value['IsDisplayed'] = $scope.HomeSearchGrid.columns.DisplayedColumns[index].IsDisplayed;
                } else {
                    value['IsDisplayed'] = false;
                }
            });
            var DisplayedExportCols = [];
            var HiddenExportCols = [];
            for (i = 0; i < $scope.HomeSearchGrid.GridSummaryDataForExport.length; i++) {
                if ($scope.HomeSearchGrid.GridSummaryDataForExport[i].Type == 'Number' || $scope.HomeSearchGrid.GridSummaryDataForExport[i].Type == 'Currency') {
                    if ($scope.HomeSearchGrid.GridSummaryDataForExport[i].IsDisplayed) {
                        DisplayedExportCols.push($scope.HomeSearchGrid.GridSummaryDataForExport[i]);
                    } else {
                        HiddenExportCols.push($scope.HomeSearchGrid.GridSummaryDataForExport[i]);
                    }
                }
            }
            $scope.HomeSearchGrid.exportDisplayedColumns = DisplayedExportCols;
            $scope.HomeSearchGrid.dropdownExportDisplayedColumns = DisplayedExportCols;
            $scope.HomeSearchGrid.exportHiddenColumns = HiddenExportCols;
            $scope.HomeSearchGrid.copyExportDisplayColumns = angular.copy($scope.HomeSearchGrid.exportDisplayedColumns);
            $scope.HomeSearchGrid.copyExportHiddenColumns = angular.copy($scope.HomeSearchGrid.exportHiddenColumns);
        }
        $scope.HomeSearchGrid.seeMoreTotalsDropdown = function() {
            $scope.HomeSearchGrid.summaryMoreTotal = {};
            $scope.HomeSearchGrid.summaryMoreTotal.Label = '';
            $scope.HomeSearchGrid.summaryDisplayedColumns = angular.copy($scope.HomeSearchGrid.copySummaryDisplayColumns);
            $scope.HomeSearchGrid.dropdownSummaryDisplayedColumns = angular.copy($scope.HomeSearchGrid.copySummaryDisplayColumns);
            $scope.HomeSearchGrid.summaryHiddenColumns = angular.copy($scope.HomeSearchGrid.copySummaryHiddenColumns);
        }
        $scope.HomeSearchGrid.ExportTotalsDropdown = function() {
            $scope.HomeSearchGrid.summaryMoreTotal = {};
            $scope.HomeSearchGrid.summaryMoreTotal.Label = '';
            $scope.HomeSearchGrid.exportDisplayedColumns = angular.copy($scope.HomeSearchGrid.copyExportDisplayColumns);
            $scope.HomeSearchGrid.dropdownExportDisplayedColumns = angular.copy($scope.HomeSearchGrid.copyExportDisplayColumns);
            $scope.HomeSearchGrid.exportHiddenColumns = angular.copy($scope.HomeSearchGrid.copyExportHiddenColumns);
        }
        $scope.HomeSearchGrid.collapseAllFilter = function() {
            $scope.HomeSearchGrid.isfavorite = true;
            $scope.HomeSearchGrid.iscommon = true;
            $scope.HomeSearchGrid.iscustom = true;
        }
        $scope.HomeSearchGrid.summaryDropDownClose = function() {
            angular.element('#summaryDropDown').closest(".summaryDropdownList").removeClass("open");
        }
        $scope.HomeSearchGrid.exportDropDownClose = function() {
            angular.element('#exportDropDown').closest(".exportDropdownList").removeClass("open");
        }
        $scope.HomeSearchGrid.updateSummaryRecord = function() {
            var DisplayedCols = [];
            var HiddenCols = [];
            for (i = 0; i < $scope.HomeSearchGrid.dropdownSummaryDisplayedColumns.length; i++) {
                if ($scope.HomeSearchGrid.dropdownSummaryDisplayedColumns[i].IsDisplayed) {
                    DisplayedCols.push($scope.HomeSearchGrid.dropdownSummaryDisplayedColumns[i]);
                } else {
                    HiddenCols.push($scope.HomeSearchGrid.dropdownSummaryDisplayedColumns[i]);
                }
            }
            for (i = 0; i < $scope.HomeSearchGrid.summaryHiddenColumns.length; i++) {
                if ($scope.HomeSearchGrid.summaryHiddenColumns[i].IsDisplayed) {
                    DisplayedCols.push($scope.HomeSearchGrid.summaryHiddenColumns[i]);
                } else {
                    HiddenCols.push($scope.HomeSearchGrid.summaryHiddenColumns[i]);
                }
            }
            $scope.HomeSearchGrid.summaryDisplayedColumns = DisplayedCols;
            $scope.HomeSearchGrid.dropdownSummaryDisplayedColumns = DisplayedCols;
            $scope.HomeSearchGrid.summaryHiddenColumns = HiddenCols;
            $scope.HomeSearchGrid.copySummaryDisplayColumns = angular.copy($scope.HomeSearchGrid.summaryDisplayedColumns);
            $scope.HomeSearchGrid.copySummaryHiddenColumns = angular.copy($scope.HomeSearchGrid.summaryHiddenColumns);
            $scope.HomeSearchGrid.summaryDropDownClose();
        }
        $scope.HomeSearchGrid.updateExportRecord = function() {
            var DisplayedExportCols = [];
            var HiddenExportCols = [];
            for (i = 0; i < $scope.HomeSearchGrid.dropdownExportDisplayedColumns.length; i++) {
                if ($scope.HomeSearchGrid.dropdownExportDisplayedColumns[i].IsDisplayed) {
                    DisplayedExportCols.push($scope.HomeSearchGrid.dropdownExportDisplayedColumns[i]);
                } else {
                    HiddenExportCols.push($scope.HomeSearchGrid.dropdownExportDisplayedColumns[i]);
                }
            }
            for (i = 0; i < $scope.HomeSearchGrid.exportHiddenColumns.length; i++) {
                if ($scope.HomeSearchGrid.exportHiddenColumns[i].IsDisplayed) {
                    DisplayedExportCols.push($scope.HomeSearchGrid.exportHiddenColumns[i]);
                } else {
                    HiddenExportCols.push($scope.HomeSearchGrid.exportHiddenColumns[i]);
                }
            }
            $scope.HomeSearchGrid.exportDisplayedColumns = DisplayedExportCols;
            $scope.HomeSearchGrid.dropdownExportDisplayedColumns = DisplayedExportCols;
            $scope.HomeSearchGrid.exportHiddenColumns = HiddenExportCols;
            $scope.HomeSearchGrid.copyExportDisplayColumns = angular.copy($scope.HomeSearchGrid.exportDisplayedColumns);
            $scope.HomeSearchGrid.copyExportHiddenColumns = angular.copy($scope.HomeSearchGrid.exportHiddenColumns);
            $scope.HomeSearchGrid.exportDropDownClose();
        }
        // Method to handle any updates in sort controls
        $scope.HomeSearchGrid.HSGrid_PageSortControlsAction = function() {
            var newSortOrder = sortOrderMap[$scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting[0].SortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.Sorting[0].SortDirection = newSortOrder;
            // Set current page to 1
            $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.CurrentPage = 1;
            $scope.HomeSearchGrid.HSGrid_paginationControlsAction();
        }
        // Method to handle any updates in pagination controls
        $scope.HomeSearchGrid.HSGrid_paginationControlsAction = function(pageSizeParam) {
            if (pageSizeParam != undefined) {
                $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.PageSize = pageSizeParam;
            }
            if ($scope.HomeSearchGrid.isReportMode) {
                $scope.HomeSearchGrid.SearchedResult = [];
                var currentPage = $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.CurrentPage;
                var pageSize = $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.PageSize;
                for (var i = ((currentPage - 1) * pageSize); i < (currentPage * pageSize); i++) {
                    if (i < $scope.HomeSearchGrid.Total_Records) {
                        $scope.HomeSearchGrid.SearchedResult.push($scope.HomeSearchGrid.SearchedReportData[i]);
                    }
                }
                setTimeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip();
                    $scope.HomeSearchGrid.searchResultPageSortAttrsJSON.ChangesCount++;
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') $scope.$apply();
                }, 10);
                $scope.HomeSearchGrid.displayGrid = true;
            } else {
                $scope.HomeSearchGrid.getFilteredRecords(false);
            }
        }
        $scope.dynamicSort = function(propertyObject) {
            return function(obj1, obj2) {
                if (propertyObject.Type == "Number" || propertyObject.Type == "Currency" || propertyObject.Type == "Icon") {
                    var obj1Val = parseFloat(obj1[propertyObject.ExportSort]);
                    var obj2Val = parseFloat(obj2[propertyObject.ExportSort]);
                    if (propertyObject.SortDirection == 'DESC') {
                        obj1Val = isNaN(obj1Val) ? -1 : obj1Val;
                        obj2Val = isNaN(obj2Val) ? -1 : obj2Val;
                        return (obj1Val < obj2Val) ? 1 : (obj1Val > obj2Val) ? -1 : 0;
                    } else {
                        obj1Val = isNaN(obj1Val) ? Number.MAX_VALUE : obj1Val;
                        obj2Val = isNaN(obj2Val) ? Number.MAX_VALUE : obj2Val;
                        return (obj1Val < obj2Val) ? -1 : (obj1Val > obj2Val) ? 1 : 0;
                    }
                } else {
                    var obj1Val = (obj1[propertyObject.ExportSort] != null) ? obj1[propertyObject.ExportSort].toLowerCase() : obj1[propertyObject.ExportSort];
                    var obj2Val = (obj2[propertyObject.ExportSort] != null) ? obj2[propertyObject.ExportSort].toLowerCase() : obj2[propertyObject.ExportSort];
                    if (propertyObject.SortDirection == 'DESC') {
                        return (obj1Val == null || obj1Val == '') ? 1 : ((obj2Val == null || obj2Val == '') ? -1 : ((obj1Val < obj2Val) ? 1 : ((obj1Val > obj2Val) ? -1 : 0)));
                    } else {
                        return (obj1Val == null || obj1Val == '') ? -1 : ((obj2Val == null || obj2Val == '') ? 1 : ((obj1Val < obj2Val) ? -1 : ((obj1Val > obj2Val) ? 1 : 0)));
                    }
                }
            }
        }
        $scope.dynamicSortMultiple = function() {
            /**
             * save the arguments object as it will be overwritten
             * note that arguments object is an array-like object
             * consisting of the names of the properties to sort by
             */
            var props = arguments[0];
            return function(obj1, obj2) {
                // Add grouped result in "gridGroupResult" model simultaneously
                var i = 0,
                    result = 0,
                    numberOfProperties = props.length;
                /**
                 *  try getting a different result from 0 (equal)
                 *  as long as we have extra properties to compare
                 */
                while (result === 0 && i < numberOfProperties) {
                    result = $scope.dynamicSort(props[i])(obj1, obj2);
                    i++;
                }
                return result;
            }
        }
        $scope.HomeSearchGrid.changeUserReportMode = function() {
            HomeSearchFactory.updateUserReportMode(JSON.stringify(!$scope.HomeSearchGrid.isReportMode)).then(function(GridSummaryResult) {
                $scope.HomeSearchGrid.isReportMode = !$scope.HomeSearchGrid.isReportMode;
                $scope.HomeSearchGrid.setDefaultPageSortAttrs();
                $scope.HomeSearchGrid.getFilteredRecords(true);
            }, function(errorSearchResult) {
                $scope.HomeSearchGrid.GridSummaryData = [];
                Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
            });
        }
        $scope.HomeSearchGrid.PreviewGridRecordsAction = function(type) {
            if ($scope.HomeSearchGrid.groupNameKey == undefined) {
                $scope.HomeSearchGrid.groupNameKey = '';
            }
            var summaryColumnsObject = {
                visible: $scope.HomeSearchGrid.exportDisplayedColumns,
                Hidden: $scope.HomeSearchGrid.exportHiddenColumns
            };
            HomeSearchFactory.previewExportRecords(JSON.stringify($scope.HomeSearchGrid.filterFormJson), JSON.stringify($scope.HomeSearchGrid.searchResultPageSortAttrsJSON), JSON.stringify($scope.HomeSearchGrid.columns), JSON.stringify(summaryColumnsObject), $scope.HomeSearchGrid.outputResult, $scope.HomeSearchGrid.groupNameKey).then(function(previewResult) {
                if (type == 'Preview') {
                    window.open(url + 'PreviewGridRecords?filterId=' + previewResult, "", "scrollbars=1, width=1200, height=600");
                } else if (type == 'Export') {
                    var newWin = null;
                    if ($scope.HomeSearchGrid.outputResult == 'Excel (.xls)') {
                        newWin = window.open(url + 'ExportGridRecords?filterId=' + previewResult, "_blank");
                    } else if ($scope.HomeSearchGrid.outputResult == 'Excel (.csv)') {
                        newWin = window.open(url + 'ExportGridRecords?filterId=' + previewResult, "_blank");
                    } else if ($scope.HomeSearchGrid.outputResult == 'PDF File') {
                        newWin = window.open(url + 'ExportGridRecords_PDF?filterId=' + previewResult, "_blank");
                    } else if ($scope.HomeSearchGrid.outputResult == 'Printer') {
                        window.open(url + 'PreviewGridRecords?filterId=' + previewResult + '&IsPrint=' + $scope.HomeSearchGrid.outputResult, "_blank");
                    }
                }
            }, function(errorSearchResult) {
                $scope.HomeSearchGrid.GridSummaryData = [];
                Notification.error($translate.instant('HomeSearch_Some_error_occurred'));
            });
        }
        $scope.HomeSearchGrid.hideFilterForm = function() {
            angular.element('#homeSearchFilterWrapper').hide();
            angular.element(".backdropsSearchFilter").hide();
        }
        $scope.HomeSearchGrid.openFilterForm = function() {
            angular.element('#homeSearchFilterWrapper').show();
            angular.element(".backdropsSearchFilter").show();
        }
        $scope.HomeSearchGrid.showSummarySidePanel = function() {
            $scope.HomeSearchGrid.isSidePanelToggle = true;
            $scope.HomeSearchGrid.exportDiv = false;
            $scope.HomeSearchGrid.summaryDiv = true;
        }
        $scope.HomeSearchGrid.showExportSidePanel = function() {
            $scope.HomeSearchGrid.isSidePanelToggle = true;
            $scope.HomeSearchGrid.summaryDiv = false;
            $scope.HomeSearchGrid.exportDiv = true;
        }
        $scope.HomeSearchGrid.hideSidePanel = function() {
            $scope.HomeSearchGrid.isSidePanelToggle = false;
            $scope.HomeSearchGrid.summaryDiv = false;
            $scope.HomeSearchGrid.exportDiv = false;
            $scope.HomeSearchGrid.outputResult = '';
        }
        $scope.HomeSearchGrid.outputExport = function(outputName) {
            $scope.HomeSearchGrid.outputResult = outputName;
            $scope.HomeSearchGrid.closeCreateDropDown();
        }
        $scope.HomeSearchGrid.GroupExport = function(groupName, groupKeyName) {
            $scope.HomeSearchGrid.groupNameResult = groupName;
            $scope.HomeSearchGrid.groupNameKey = groupKeyName;
            $scope.HomeSearchGrid.closeCreateDropDown();
        }
        $scope.HomeSearchGrid.ClearGroup = function() {
            $scope.HomeSearchGrid.groupNameResult = '';
            $scope.HomeSearchGrid.groupNameKey = '';
        }
        $scope.HomeSearchGrid.ClearGroupIcon = function() {
            if ($scope.HomeSearchGrid.groupNameResult != '' && $scope.HomeSearchGrid.groupNameResult != null && $scope.HomeSearchGrid.groupNameResult != undefined) {
                return true;
            }
            return false;
        }
        $scope.HomeSearchGrid.closeCreateDropDown = function() {
            angular.element(".customDropdownDiv").removeClass("open");
        }
        $scope.HomeSearchGrid.saveSummarySidePanel = function() {
            var FilterId = $scope.HomeSearchGrid.currentActiveFilter.Id;
            var FilterName = $scope.HomeSearchGrid.currentActiveFilter.Name;
            var filterFormJson = '';
            var searchResultPageSortAttrsJSON = '';
            var columns = '';
            var AdditionalFields = '';
            var summaryColumnsObject = '';
            var exportColumnsObject = '';
            var outputResult = '';
            var groupNameResult = '';
            var isReportMode = $scope.HomeSearchGrid.isReportMode;
            if ($scope.HomeSearchGrid.summaryDiv) {
                summaryColumnsObject = {
                    visible: $scope.HomeSearchGrid.summaryDisplayedColumns,
                    Hidden: $scope.HomeSearchGrid.summaryHiddenColumns
                };
            } else if ($scope.HomeSearchGrid.exportDiv) {
                exportColumnsObject = {
                    visible: $scope.HomeSearchGrid.exportDisplayedColumns,
                    Hidden: $scope.HomeSearchGrid.exportHiddenColumns
                };
                outputResult = $scope.HomeSearchGrid.outputResult;
                groupNameResult = $scope.HomeSearchGrid.groupNameResult
            }
            SideBarFactory.saveFilterRecord(FilterId, FilterName, filterFormJson, searchResultPageSortAttrsJSON, columns, AdditionalFields, JSON.stringify(summaryColumnsObject), JSON.stringify(exportColumnsObject), outputResult, groupNameResult, isReportMode).then(function(successfulSearchResult) {
                $scope.HomeSearchGrid.filterList.FilterType = successfulSearchResult.AllFilterJSON.FilterType;
                $scope.HomeSearchGrid.currentActiveFilter = successfulSearchResult.CurrentFilter;
                $scope.HomeSearchGrid.isFilterCopy = false;
                $scope.HomeSearchGrid.isFilterRename = false;
                $scope.HomeSearchGrid.popUpFilterName = '';
                $scope.HomeSearchGrid.popUpFilterId = null;
                $scope.HomeSearchGrid.isFilterMatched = true;
            }, function(errorSearchResult) {
                $scope.HomeSearchGrid.filterList.FilterType = errorSearchResult;
            });
        }
        $scope.HomeSearchGrid.notSorted = function(obj) {
            if (!obj) {
                return [];
            }
            return Object.keys(obj);
        }
        $scope.HomeSearchGrid.addRemoveSalesTaxItemFromFilter = function(salesTaxItem) {
            if($scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items.includes(salesTaxItem)) {
                $scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items.remove(salesTaxItem);
            } else {
                $scope.HomeSearchGrid.filterFormJson.Selected_Sales_Tax_Items.push(salesTaxItem);
            }
        }
        $scope.HomeSearchGrid.preventMouseWheel = function() {
            angular.element('.sidepanel').bind('mousewheel', function(e, d) {
                var toolbox = $('.sidepanel'),
                    height = toolbox.height(),
                    scrollHeight = toolbox.get(0).scrollHeight;
                if ((this.scrollTop === (scrollHeight - height) && d < 0) || (this.scrollTop === 0 && d > 0)) {
                    e.preventDefault();
                }
            });
            angular.element('#TypeFixedHeight').bind('mousewheel', function(e, d) {
                var toolbox = angular.element('#TypeFixedHeight'),
                    height = toolbox.height(),
                    scrollHeight = toolbox.get(0).scrollHeight;
                $scope.HomeSearchGrid.isTypeScroll = true;
                if ((this.scrollTop === (scrollHeight - height) && d < 0) || (this.scrollTop === 0 && d > 0)) {
                    e.preventDefault();
                }
            });
            angular.element('.homeSearchFilterWrapper').bind('mousewheel', function(e, d) {
                if (e.target.closest("#additionalFieldFixHeight") != null) {} else if (e.target.closest(".fixedHeight") == null) {
                    e.preventDefault();
                }
            });
            angular.element('.fixedHeight').bind('mousewheel', function(e, d) {
                var toolbox = angular.element('.fixedHeight'),
                    height = toolbox.height(),
                    scrollHeight = toolbox.get(0).scrollHeight;
                if (e.target.closest("#TypeFixedHeight") != null) {} else if ((this.scrollTop === (scrollHeight - height) && d < 0) || (this.scrollTop === 0 && d > 0)) {
                    e.preventDefault();
                }
            });
            angular.element('#additional_column_fix').bind('mousewheel', function(e, d) {
                var toolbox = angular.element('#additional_column_fix'),
                    height = toolbox.height(),
                    scrollHeight = toolbox.get(0).scrollHeight;
                if ((this.scrollTop === (scrollHeight - height) && d < 0) || (this.scrollTop === 0 && d > 0)) {
                    e.preventDefault();
                }
            });
        }
        $scope.HomeSearchGrid.LoadGrid();
    }])
});