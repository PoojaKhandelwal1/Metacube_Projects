define(['Routing_AppJs_PK', 'AddEditCategoryServices'], function(Routing_AppJs_PK, AddEditCategoryServices) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditCategoryCtrl', ['$q', '$scope', '$rootScope', '$stateParams', '$state', 'AddEditCategoryService', function($q, $scope, $rootScope, $stateParams, $state, AddEditCategoryService) {
        var Notification = injector.get("Notification");
        /****** Modals initialization ******/
        if ($scope.CategoryCompModal == undefined) {
            $scope.CategoryCompModal = {};
            $scope.CategoryCompModal.accountType = [];
        }
        $scope.CategoryCompModal.GeneralAccountsSearchText = ''; 
        
        var categoryTypeWithoutCOGSAndInventoryGL = ['Fee',
                                                     'Internal Expense',
                                                     'Miscellaneous',
                                                     'Tax',
                                                     'Trade-in',
                                                     'Stamp Duty',
                                                     'Deductible',
                                                     'Stocked Trade'
                                                     ];
        
        $scope.CategoryCompModal.addOpenClass = function(key) { 
            angular.element('#' + key + 'UL').addClass('keep_open');
            $scope.CategoryCompModal.GeneralAccountsSearchText = '';
            setTimeout(function() {
                angular.element('#' + key + 'Input').focus();
            }, 10);
        }
        $scope.$on('EditCategoryEvent', function(event, categoryJSON) {
            $scope.CategoryCompModal.openPopup(categoryJSON);
        });
        $scope.CategoryCompModal.openPopup = function(categoryJSON) {
            $scope.CategoryCompModal.setData();
            if (categoryJSON != undefined) {
                $scope.CategoryCompModal.categoryInfo = angular.copy(categoryJSON);
            }
            angular.element('.controls').hide();
            setTimeout(function() { 
                angular.element('#addEditCategory').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
            AddEditCategoryService.getCategoryMasterData().then(function(successfulSearchResult) {
                $scope.CategoryCompModal.accountingData = successfulSearchResult;
                $scope.CategoryCompModal.accountingData.accountingList = successfulSearchResult.accountingList;
                $scope.CategoryCompModal.accountingData.selectedAccountType = 'Select Type';
                AddEditCategoryService.getCategoryDetails().then(function(successfulResult) {
                    $scope.CategoryCompModal.defaultCategoryList = successfulResult;
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }, function(errorSearchResult) {});
            $scope.CategoryCompModal.accountType = [{
                Name: 'Fee'
            }, {
                Name: 'Internal Expense'
            }, {
                Name: 'Labour'
            }, {
                Name: 'Miscellaneous'
            }, {
                Name: 'Part'
            }, {
                Name: 'Sublet'
            }, {
                Name: 'Tax'
            }, {
                Name: 'Unit'
            }];
            $scope.CategoryCompModal.checkIsActive = false;
        }
        $scope.CategoryCompModal.changeCategoryType = function(CategoryType) {
            $scope.CategoryCompModal.categoryInfo.Type = CategoryType;
            if (CategoryType == 'Tax') {
                $scope.CategoryCompModal.categoryInfo.IncomeGL = $scope.CategoryCompModal.accountingData.defaultAccounts.SalesTax;
                $scope.CategoryCompModal.categoryInfo.COGSGL = '';
                $scope.CategoryCompModal.categoryInfo.InventoryGL = '';
            }
            if (CategoryType == 'Fee' || CategoryType == 'Internal Expense' || CategoryType == 'Miscellaneous') {
                $scope.CategoryCompModal.categoryInfo.IncomeGL = $scope.CategoryCompModal.accountingData.defaultAccounts.MiscellaneousIncome;
                $scope.CategoryCompModal.categoryInfo.COGSGL = '';
                $scope.CategoryCompModal.categoryInfo.InventoryGL = '';
            }
            if (CategoryType == 'Labour' || CategoryType == 'Part' || CategoryType == 'Sublet' || CategoryType == 'Unit') {
                $scope.CategoryCompModal.categoryInfo.IncomeGL = $scope.CategoryCompModal.accountingData.defaultAccounts.SalesIncome;
                $scope.CategoryCompModal.categoryInfo.COGSGL = $scope.CategoryCompModal.accountingData.defaultAccounts.CostofGoodsSold;
                $scope.CategoryCompModal.categoryInfo.InventoryGL = $scope.CategoryCompModal.accountingData.defaultAccounts.Inventory;
            }
        }
        $scope.CategoryCompModal.setData = function() {
            $scope.CategoryCompModal.categoryInfo = {};
            $scope.CategoryCompModal.categoryInfo.Type = 'Select type';
            $scope.CategoryCompModal.categoryInfo.IsDefault = false;
            $scope.CategoryCompModal.categoryInfo.IsActive = true;
        }
        $scope.CategoryCompModal.closeCategoryPopup = function() {
            $scope.$parent.AccountingSetupModel.isAccountingSetupDataSaved = true;  
            $scope.CategoryCompModal.closePopup();
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name);
        }
        $scope.CategoryCompModal.SelectAccount = function(event, key, accountValue) {
            if (event != undefined) {
                event.preventDefault();
            }
            if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online') {
	    		$scope.CategoryCompModal.categoryInfo[key] = accountValue.AccountingId;
	    	} else if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero') {
	    		$scope.CategoryCompModal.categoryInfo[key] = accountValue.AccountNumber;
	    	}
            angular.element('#' + key + 'UL').removeClass('keep_open'); 
            $scope.CategoryCompModal.GeneralAccountsSearchText = ''; 
        }
        $scope.CategoryCompModal.disableCOGSAndInventoryGLAccount = function() {
            if ($scope.CategoryCompModal.categoryInfo && ($scope.CategoryCompModal.categoryInfo.Type == 'Select type' || categoryTypeWithoutCOGSAndInventoryGL.indexOf($scope.CategoryCompModal.categoryInfo.Type) > -1)) {
                return true;
            }
            return false;
        }
        $scope.CategoryCompModal.getAccountNameFromKey = function(key) {
            if ($scope.CategoryCompModal.categoryInfo != undefined) {
                var accountingId = $scope.CategoryCompModal.categoryInfo[key];
                return $scope.CategoryCompModal.getAccountNameFromAccountId(accountingId);
            }
        }
        $scope.CategoryCompModal.getAccountNameFromAccountId = function(accountId) {
            var index = -1;
            if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Quickbooks Online') {
	    		index = _.findIndex($scope.CategoryCompModal.accountingData.accountingList, {
	                AccountingId: accountId
	            });
	    	} else if($scope.AccountingSetupModel.accountingData.configuration.AccountingProvider == 'Xero') {
	    		index = _.findIndex($scope.CategoryCompModal.accountingData.accountingList, {
	    			AccountNumber: accountId
	            });
	    	}
            if (index != -1) {
	        	var accountselectedName = ''
	    		if($scope.CategoryCompModal.accountingData.accountingList[index].AccountNumber) {
	    			accountselectedName = $scope.CategoryCompModal.accountingData.accountingList[index].AccountNumber + ' - ';
	    		}
	    		accountselectedName += $scope.CategoryCompModal.accountingData.accountingList[index].AccountName;
	    		return accountselectedName;
            }
            return 'Select a GL Account';
        }
        $scope.CategoryCompModal.changeIsDefault = function(event) {
            if ($scope.CategoryCompModal.categoryInfo.IsDefault == false) {
                if (event != undefined) {
                    event.preventDefault();
                }
                for (var i = 0; i < $scope.CategoryCompModal.defaultCategoryList.length; i++) {
                    if ($scope.CategoryCompModal.defaultCategoryList[i].Type == $scope.CategoryCompModal.categoryInfo.Type) {
                        if ($scope.CategoryCompModal.defaultCategoryList[i].IsDefault == true) {
                            $scope.CategoryCompModal.defaultCategoryName = $scope.CategoryCompModal.defaultCategoryList[i].CategoryName;
                            angular.element('#ChangeDefaultCategoryPopupOnAddEditCategory').modal({
                                backdrop: 'static',
                                keyboard: false
                            });
                        }
                    }
                }
            } else {
                $scope.CategoryCompModal.categoryInfo.IsDefault = !$scope.CategoryCompModal.categoryInfo.IsDefault;
                $scope.CategoryCompModal.checkIsActive = false;
            }
        }
        $scope.CategoryCompModal.changeIsActive = function(event) {
            if ($scope.CategoryCompModal.categoryInfo.IsDefault == true) {
                if ($scope.CategoryCompModal.categoryInfo.IsActive == true) {
                    if (event != undefined) {
                        event.preventDefault();
                    }
                    $scope.CategoryCompModal.checkIsActive = true;
                } else {
                    $scope.CategoryCompModal.categoryInfo.IsActive = !$scope.CategoryCompModal.categoryInfo.IsActive;
                }
            } else {
                $scope.CategoryCompModal.categoryInfo.IsActive = !$scope.CategoryCompModal.categoryInfo.IsActive;
            }
        }
        $scope.CategoryCompModal.closeChangeDefaultCategoryPopup = function() {
            angular.element('#ChangeDefaultCategoryPopupOnAddEditCategory').modal('hide');
        }
        $scope.CategoryCompModal.confirmChangeDefaultCategoryPopup = function() {
            $scope.CategoryCompModal.categoryInfo.IsDefault = true;
            $scope.CategoryCompModal.closeChangeDefaultCategoryPopup();
        }
        $scope.CategoryCompModal.saveCategory = function() {
            AddEditCategoryService.saveCategoryData(JSON.stringify($scope.CategoryCompModal.categoryInfo)).then(function(successfulSearchResult) {
                if (successfulSearchResult == 'success') {
                    $scope.$parent.AccountingSetupModel.getCategories();
                    $scope.CategoryCompModal.closePopup();
                    hideModelWindow();
                    $scope.$parent.AccountingSetupModel.isAccountingSetupDataSaved = true;
                    loadState($state, $rootScope.$previousState.name);
                } else {
                    Notification.error(successfulSearchResult);
                }
            }, function(errorSearchResult) {});
        }
        $scope.CategoryCompModal.closePopup = function() {
            angular.element('#addEditCategory').modal('hide');
        }
        $scope.CategoryCompModal.openAddEditCategoryPopUp = function() {
            var categoryJSON;
            if ($stateParams.AddEditCategoryParams != undefined) {
                categoryJSON = $stateParams.AddEditCategoryParams.categoryJSON;
            }
            $scope.CategoryCompModal.openPopup(categoryJSON);
        }
        $scope.CategoryCompModal.openAddEditCategoryPopUp();
    }]);
});