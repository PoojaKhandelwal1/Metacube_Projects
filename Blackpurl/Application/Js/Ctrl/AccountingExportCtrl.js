define(['Routing_AppJs_PK', 'AccountingExportServices', 'JqueryUI', 'underscore_min'], function(Routing_AppJs_PK, newHomePageServices, JqueryUI, underscore_min) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AccountingExportCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', 'AccountingExportService','$translate', function($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, AccountingExportService,$translate) {
        var Notification = injector1.get("Notification");
        if ($scope.AccountingExportModel == undefined) {
            $scope.AccountingExportModel = {};
        }
        $scope.AccountingExportModel.selectedcashSaleChevronIndex = '1';
        $scope.AccountingExportModel.displaySection = 'Export Selection';
        $scope.AccountingExportModel.selectedExportFoarmat = 'Select One';
        $scope.AccountingExportModel.fromDate = '';
        $scope.AccountingExportModel.toDate = '';
        $scope.AccountingExportModel.isExportProcessed = false;
        $scope.AccountingExportModel.isExportProcessing = false;
        $scope.AccountingExportModel.isAnyUnsavedData = false;
        $scope.AccountingExportModel.DateFormat = $Global.DateFormat;
        $scope.dateOptions = {
            maxDate: new Date,
            showOtherMonths: true,
            selectOtherMonths: false,
            dateFormat: $scope.AccountingExportModel.DateFormat
        };
        $scope.AccountingExportModel.AccountingExportChevronList = [{
            Name: 'Back',
            isActive: true
        }, {
            Name: 'Export Selection',
            isActive: false
        }, {
            Name: 'Export Filters',
            isActive: false
        }, {
            Name: 'Results',
            isActive: false
        }];
        $scope.AccountingExportModel.AccountingExportFormatList = [{
            Name: 'MYOB Account Right (preferred)'
        }, {
            Name: 'Generic Text File'
        }, {
            Name: 'Generic CSV File'
        }];
        $scope.AccountingExportModel.DataToExportList = [];
        $scope.AccountingExportModel.DataToExportToDescriptionMap = {
            'Customers': $translate.instant('Export_customer_information_message'),
            'Vendors': $translate.instant('Export_vendor_information_message'),
            'Money Received': $translate.instant('Export_deposits_message'),
            'Customer Invoices': $translate.instant('Export_customer_invoices_message'),
            'Vendor Invoices': $translate.instant('Export_vendor_invoices_message'),
            'Journal Entries': $translate.instant('Export_journal_entries_message')
        };
        $scope.AccountingExportModel.TimePeriodForExportList = [{
            Name: 'All since last exported',
            isRadioButtonSelected: true
        }, {
            Name: 'This week',
            isRadioButtonSelected: false
        }, {
            Name: 'Last week',
            isRadioButtonSelected: false
        }, {
            Name: 'This month',
            isRadioButtonSelected: false
        }, {
            Name: 'Last month',
            isRadioButtonSelected: false
        }, {
            Name: 'Specific date range',
            isRadioButtonSelected: false
        }];
        $scope.AccountingExportModel.calculateContentPanelHeight = function() {
            var ContentPanelHeight = $(document).height() - (angular.element(".headerNav").height() + angular.element(".cashSaleCrumbs_UL").height() + angular.element(".cashSaleCopyright").height() + 13);
            angular.element(".rightPanel").css("height", ContentPanelHeight);
            angular.element(".AccountingExportContent").css("height", ContentPanelHeight);
        }
        $scope.AccountingExportModel.loadAccoutingExportData = function() {
            $scope.AccountingExportModel.calculateContentPanelHeight();
            $scope.AccountingExportModel.getPreviousExportDetails();
            $scope.AccountingExportModel.getTimePeriodForExport();
        }
        $scope.AccountingExportModel.getPreviousExportDetails = function() {
            AccountingExportService.getPreviousExportDetails().then(function(successfulResult) {
                for (var i = 0; i < successfulResult.length; i++) {
                    if(successfulResult[i].ObjectName != null) {
                        $scope.AccountingExportModel.DataToExportList.push(successfulResult[i]);
                    }
                }
                $scope.AccountingExportModel.setExportData();
            }, function(errorSearchResult) {});
        }
        $scope.AccountingExportModel.setExportData = function(index) {
            for (var i = 0; i < $scope.AccountingExportModel.DataToExportList.length; i++) {
                $scope.AccountingExportModel.DataToExportList[i].isRightPanelActive = false;
                $scope.AccountingExportModel.DataToExportList[i].isRadioButtonSelected = true;
                if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Customers') {
                    $scope.AccountingExportModel.DataToExportList[i].priorityValue = 1;
                } else if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Vendors') {
                    $scope.AccountingExportModel.DataToExportList[i].priorityValue = 2;
                } else if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Money Received') {
                    $scope.AccountingExportModel.DataToExportList[i].priorityValue = 3;
                } else if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Customer Invoices') {
                    $scope.AccountingExportModel.DataToExportList[i].priorityValue = 4;
                } else if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Vendor Invoices') {
                    $scope.AccountingExportModel.DataToExportList[i].priorityValue = 5;
                } else if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Journal Entries') {
                    $scope.AccountingExportModel.DataToExportList[i].priorityValue = 6;
                }
            }
        }
        $scope.AccountingExportModel.getTimePeriodForExport = function() {
            AccountingExportService.getTimePeriodForExport().then(function(successfulResult) {
                $scope.AccountingExportModel.ExportTimePeriodData = successfulResult;
            }, function(errorSearchResult) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.AccountingExportModel.setTimePeriodForExport = function(selectedFilter) {
            for (var i = 0; i < $scope.AccountingExportModel.DataToExportList.length; i++) {
                if ($scope.AccountingExportModel.ExportTimePeriodData != undefined) {
                    if (selectedFilter == 'All since last exported') {
                        if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Customers') {
                            $scope.AccountingExportModel.DataToExportList[i].TimePeriod = $scope.AccountingExportModel.ExportTimePeriodData.CustomerAllSinceLastExport;
                        } else if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Vendors') {
                            $scope.AccountingExportModel.DataToExportList[i].TimePeriod = $scope.AccountingExportModel.ExportTimePeriodData.VendorAllSinceLastExport;
                        } else if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Money Received') {
                            $scope.AccountingExportModel.DataToExportList[i].TimePeriod = $scope.AccountingExportModel.ExportTimePeriodData.MoneyReceivedAllSinceLastExport;
                        } else if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Customer Invoices') {
                            $scope.AccountingExportModel.DataToExportList[i].TimePeriod = $scope.AccountingExportModel.ExportTimePeriodData.CustomerInvoiceAllSinceLastExport;
                        } else if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Vendor Invoices') {
                            $scope.AccountingExportModel.DataToExportList[i].TimePeriod = $scope.AccountingExportModel.ExportTimePeriodData.VendorInvoiceAllSinceLastExport;
                        } else if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == 'Journal Entries') {
                            $scope.AccountingExportModel.DataToExportList[i].TimePeriod = $scope.AccountingExportModel.ExportTimePeriodData.JournalEntryAllSinceLastExport;
                        }
                    } else if (selectedFilter == 'This week') {
                        $scope.AccountingExportModel.DataToExportList[i].TimePeriod = $scope.AccountingExportModel.ExportTimePeriodData.ThisWeek;
                    } else if (selectedFilter == 'Last week') {
                        $scope.AccountingExportModel.DataToExportList[i].TimePeriod = $scope.AccountingExportModel.ExportTimePeriodData.LastWeek;
                    } else if (selectedFilter == 'This month') {
                        $scope.AccountingExportModel.DataToExportList[i].TimePeriod = $scope.AccountingExportModel.ExportTimePeriodData.ThisMonth;
                    } else if (selectedFilter == 'Last month') {
                        $scope.AccountingExportModel.DataToExportList[i].TimePeriod = $scope.AccountingExportModel.ExportTimePeriodData.LastMonth;
                    } else if (selectedFilter == 'Specific date range') {
                        $scope.AccountingExportModel.DataToExportList[i].TimePeriod = '';
                        if ($scope.AccountingExportModel.fromDate != '' && $scope.AccountingExportModel.toDate != '' && $scope.AccountingExportModel.fromDate != null && $scope.AccountingExportModel.toDate != null && $scope.AccountingExportModel.fromDate != undefined && $scope.AccountingExportModel.toDate != undefined) {
                            $scope.AccountingExportModel.DataToExportList[i].TimePeriod = formatDate($scope.AccountingExportModel.fromDate) + ' through ' + formatDate($scope.AccountingExportModel.toDate);
                        }
                    }
                }
            }
        }

        function formatDate(date) {
            var completeDate = date.split("/");
            var formatDate = $scope.AccountingExportModel.DateFormat.split("/");
            var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            if (formatDate[1].indexOf("mm") != -1) {
                completeDate[1] = monthNames[parseInt(completeDate[1]) - 1];
            } else if (formatDate[0].indexOf("mm") != -1) {
                completeDate[0] = monthNames[parseInt(completeDate[0]) - 1];
            }
            return completeDate[0] + ' ' + completeDate[1] + '/' + completeDate[2];
        }
        $scope.AccountingExportModel.NextAction = function(index) {
            $scope.AccountingExportModel.selectedcashSaleChevronIndex = index;
            $scope.AccountingExportModel.displaySection = $scope.AccountingExportModel.AccountingExportChevronList[index].Name;
            if (index == 2) { 
                $scope.AccountingExportModel.fromDate = ''; 
                $scope.AccountingExportModel.toDate = ''; 
                for (var i = 0; i < $scope.AccountingExportModel.TimePeriodForExportList.length; i++) {
                    if (i == 0) {
                        $scope.AccountingExportModel.TimePeriodForExportList[i].isRadioButtonSelected = true;
                    } else {
                        $scope.AccountingExportModel.TimePeriodForExportList[i].isRadioButtonSelected = false;
                    }
                }
                $scope.AccountingExportModel.setTimePeriodForExport('All since last exported'); 
            }
        }
        $scope.AccountingExportModel.backAction = function(index) {
            if ($scope.AccountingExportModel.isAnyUnsavedData) {
                loadState($state, 'UserSetting', {
                    Id: 'Import_And_Export'
                });
            } else {
                loadState($state, 'UserSetting', {
                    Id: 'Home'
                });
            }
        }
        $scope.AccountingExportModel.showProcessExportConfirmationPopup = function() {
            var d = new Date($scope.AccountingExportModel.fromDate);
            var d1 = new Date($scope.AccountingExportModel.toDate);
            if (d > d1) {
                Notification.error($translate.instant('From_date_to_date_restriction'));
                return;
            }
            angular.element('#ProcessExportConfirmationPopup').modal({
                backdrop: 'static',
                keyboard: false
            });
        }
        $scope.AccountingExportModel.closeProcessExportConfirmationPopup = function() {
            angular.element('#ProcessExportConfirmationPopup').modal('hide');
        }
        $scope.AccountingExportModel.processExport = function() {
            $scope.AccountingExportModel.isExportProcessing = true;
            var selectedFilter = '';
            var exportDataJSON = JSON.stringify($scope.AccountingExportModel.DataToExportList);
            var fromDate = $scope.AccountingExportModel.fromDate;
            var toDate = $scope.AccountingExportModel.toDate;
            for (var i = 0; i < $scope.AccountingExportModel.TimePeriodForExportList.length; i++) {
                if ($scope.AccountingExportModel.TimePeriodForExportList[i].isRadioButtonSelected) {
                    selectedFilter = $scope.AccountingExportModel.TimePeriodForExportList[i].Name;
                }
            }
            $scope.AccountingExportModel.closeProcessExportConfirmationPopup();
            $scope.AccountingExportModel.NextAction(3);
            AccountingExportService.processExport(exportDataJSON, selectedFilter, fromDate, toDate).then(function(successfulResult) {
                $scope.AccountingExportModel.isExportProcessed = true;
                $scope.AccountingExportModel.isExportProcessing = false;
            }, function(errorSearchResult) {
                $scope.AccountingExportModel.isExportProcessed = false;
                $scope.AccountingExportModel.isExportProcessing = false;
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.AccountingExportModel.selectExportFormat = function(formatType) {
            $scope.AccountingExportModel.selectedExportFoarmat = formatType;
            $scope.AccountingExportModel.isAnyUnsavedData = true;
        }
        $scope.AccountingExportModel.selectDataToExport = function(ObjectName) {
            for (var i = 0; i < $scope.AccountingExportModel.DataToExportList.length; i++) {
                if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == ObjectName) {
                    $scope.AccountingExportModel.DataToExportList[i].isRadioButtonSelected = !$scope.AccountingExportModel.DataToExportList[i].isRadioButtonSelected;
                    if ($scope.AccountingExportModel.DataToExportList[i].isRadioButtonSelected) {
                        $scope.AccountingExportModel.showRightPanelDescription(ObjectName);
                    }
                    break;
                }
            }
        }
        $scope.AccountingExportModel.showRightPanelDescription = function(ObjectName) {
            for (var i = 0; i < $scope.AccountingExportModel.DataToExportList.length; i++) {
                if ($scope.AccountingExportModel.DataToExportList[i].ObjectName == ObjectName) {
                    $scope.AccountingExportModel.DataToExportList[i].isRightPanelActive = true;
                } else {
                    $scope.AccountingExportModel.DataToExportList[i].isRightPanelActive = false;
                }
            }
        }
        $scope.AccountingExportModel.selectAllDataList = function() {
            for (var i = 0; i < $scope.AccountingExportModel.DataToExportList.length; i++) {
                $scope.AccountingExportModel.DataToExportList[i].isRadioButtonSelected = true;
            }
        }
        $scope.AccountingExportModel.clearAllDataList = function() {
            for (var i = 0; i < $scope.AccountingExportModel.DataToExportList.length; i++) {
                $scope.AccountingExportModel.DataToExportList[i].isRadioButtonSelected = false;
                $scope.AccountingExportModel.DataToExportList[i].isRightPanelActive = false;
            }
        }
        $scope.AccountingExportModel.isExportSelectionNextActionEnabled = function() {
            for (var i = 0; i < $scope.AccountingExportModel.DataToExportList.length; i++) {
                if ($scope.AccountingExportModel.DataToExportList[i].isRadioButtonSelected) {
                    return true;
                }
            }
            return false;
        }
        $scope.AccountingExportModel.selectTimePeriodForExport = function(index) {
            $scope.AccountingExportModel.fromDate = '';
            $scope.AccountingExportModel.toDate = '';
            for (var i = 0; i < $scope.AccountingExportModel.TimePeriodForExportList.length; i++) {
                if (i == index) {
                    $scope.AccountingExportModel.TimePeriodForExportList[index].isRadioButtonSelected = !$scope.AccountingExportModel.TimePeriodForExportList[index].isRadioButtonSelected;
                } else {
                    $scope.AccountingExportModel.TimePeriodForExportList[i].isRadioButtonSelected = false;
                }
            }
            $scope.AccountingExportModel.setTimePeriodForExport($scope.AccountingExportModel.TimePeriodForExportList[index].Name);
        }
        $scope.AccountingExportModel.isExportFiltersNextActionEnabled = function() {
            for (var i = 0; i < $scope.AccountingExportModel.TimePeriodForExportList.length; i++) {
                if ($scope.AccountingExportModel.TimePeriodForExportList[i].isRadioButtonSelected && $scope.AccountingExportModel.TimePeriodForExportList[i].Name != 'Specific date range') {
                    return true;
                } else if ($scope.AccountingExportModel.TimePeriodForExportList[i].isRadioButtonSelected && $scope.AccountingExportModel.TimePeriodForExportList[i].Name == 'Specific date range') {
                    if ($scope.AccountingExportModel.fromDate != '' && $scope.AccountingExportModel.fromDate != null && $scope.AccountingExportModel.fromDate != undefined && $scope.AccountingExportModel.toDate != '' && $scope.AccountingExportModel.toDate != null && $scope.AccountingExportModel.toDate != undefined) {
                        return true;
                    }
                }
            }
            return false;
        }
        $scope.AccountingExportModel.cancelAction = function() {
            loadState($state, 'UserSetting', {
                Id: 'Import_And_Export'
            });
        }
        setTimeout(function() {
            $scope.AccountingExportModel.loadAccoutingExportData();
        }, 100);
    }])
});