define(['Routing_AppJs_PK', 'AddEditProductServices', 'dirNumberInput', 'underscore_min', 'AngularNgEnter'], function (Routing_AppJs_PK, AddEditProductServices, dirNumberInput, underscore_min, AngularNgEnter) {
    var injector = angular.injector(['ui-notification', 'ng']);

    $(document).ready(function () {
        $('.controls').hide();
        $(".form-control").focus(function () {
            $('.controls').hide();
            $('#' + $(this).attr('rel')).show();
        });

        $(".anguinput").focus(function () {
            $('.controls').hide();
            $('#' + $(this).attr('rel')).show();
        });

        $('[data-toggle="tooltip"]').tooltip({
            placement: 'bottom'
        });
    })

    Routing_AppJs_PK.controller('AddEditProductCtrl', ['$scope', '$q', '$rootScope', '$stateParams', '$state', 'AddEditProductService','$translate', function ($scope, $q, $rootScope, $stateParams, $state, AddEditProductService, $translate) {
        var Notification = injector.get("Notification");
        $scope.ProductCompModal.costMethodValueList = [];
        $scope.ProductCompModal.ProductModal = {};
        $scope.ProductCompModal.isValidForm = true;
        $scope.ProductCompModal.tabIndexValue = 0;
        $scope.ProductCompModal.CategoryNameStr = "";
        $scope.ProductCompModal.saveButtonClicked = false;
        $scope.ProductCompModal.helpText = {
            Save: $translate.instant('Save_infomation'),
            Cancel: $translate.instant('Helptext_cancel_changes'),
            Type: $translate.instant('Product_type'),
            Code: $translate.instant('Product_code'),
            Cost: $translate.instant('Helptext_product_cost_rate_percentage'),
            Price: $translate.instant('Helptext_Product_price'),
            Category: $translate.instant('Helptext_Product_category'),
            Term: $translate.instant('Product_term'),
            Mileage: $translate.instant('Product_mileage'),
            Deductible: $translate.instant('Product_deductible'),
            Description: $translate.instant('Product_description'),
            ProductTaxable: $translate.instant('Product_taxable'),
            ProductApplicableTax: $translate.instant('Product_applicable_tax')
        };
        $scope.ProductCompModal.ProductFieldsFilter = {
            SubletCategory: [{
                Field: "Type__c",
                Value: "Sublet",
                FilterObject: "Category__c"
            }]
        };

        /**
         * Method to set default values for validation model
         */
        $scope.ProductCompModal.setDefaultValidationModal = function () {
            $scope.ProductCompModal.productFormValidationModal = {
                Type: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                Code: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                Cost: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                },
                Price: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                },
                Term: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                },
                Mileage: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                },
                Deductible: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                },
                CategoryName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                Description: {
                	isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                }
            };
        }

        $scope.ProductCompModal.openAddProductPopup = function (vendorId) {
            $scope.ProductCompModal.getAndSetDefaultTax();
            $scope.ProductCompModal.clearAllData();
            $scope.ProductCompModal.ProductModal.vendorId = vendorId;
            $scope.ProductCompModal.getListForProductTypes();
            $scope.ProductCompModal.getAndSetSystemDefaultCategory();
            $scope.ProductCompModal.openPopup();
        }

        $scope.ProductCompModal.openEditProductPopup = function (productId, vendorId) {
            $scope.ProductCompModal.currentProductId = productId;
            $scope.ProductCompModal.ProductModal.Id = productId;
            $scope.ProductCompModal.ProductModal.vendorId = vendorId;
            $scope.ProductCompModal.getListForProductTypes();
            $scope.ProductCompModal.setDataDefault();
            $scope.ProductCompModal.getCurrentProductData();
        }

        $scope.ProductCompModal.openPopup = function () {
            setTimeout(function () {
                angular.element('#AddNewProduct').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
            setTimeout(function () {
                angular.element(document.getElementById("AddNewProduct").querySelector('[tabindex="1"]')).focus();
            }, 500);
        }

        $scope.ProductCompModal.formFieldJustGotFocus = function (Value) {
            showToolTip(Value);
        }

        $scope.ProductCompModal.closePopup = function () {
            angular.element('#AddNewProduct').modal('hide');
            setTimeout(function () {
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }, 1000);
        }

        /**
         * Method to get default category for form
         */
        $scope.ProductCompModal.getAndSetSystemDefaultCategory = function () {
            AddEditProductService.getSystemDefaultCategory('').then(function (categoryRecord) {
                $scope.ProductCompModal.UpdateCategoryInForm(categoryRecord);
            }, function (errorSearchResult) {
                //FIXME
            });
        }

        /**
         * Set default category in form
         */
        $scope.ProductCompModal.UpdateCategoryInForm = function (categoryRecord) {
            if (categoryRecord.DefaultCategoryId != null && categoryRecord.DefaultCategoryId != "") {
                $scope.ProductCompModal.ProductModal.CategoryId = categoryRecord.DefaultCategoryId;
                $scope.ProductCompModal.ProductModal.CategoryName = categoryRecord.DefaultCategoryName;
                $scope.ProductCompModal.CategoryNameStr = categoryRecord.DefaultCategoryName;
            } else {
                $scope.ProductCompModal.ProductModal.CategoryId = null;
                $scope.ProductCompModal.CategoryNameStr = "";
                $scope.ProductCompModal.ProductModal.CategoryName = "";
            }
        }

        /**
         * Method to clear all form fields and set default values
         */
        $scope.ProductCompModal.clearAllData = function () {
            $scope.ProductCompModal.currentProductId = null;
            $scope.ProductCompModal.ProductModal = {};
            $scope.ProductCompModal.ProductModal.Cost = "0.00";
            $scope.ProductCompModal.ProductModal.Price = 0;
            $scope.ProductCompModal.ProductModal.CategoryId = null;
            $scope.ProductCompModal.ProductModal.CategoryName = '';
            $scope.ProductCompModal.CategoryNameStr = '';
            $scope.ProductCompModal.ProductModal.Mileage = 0;
            $scope.ProductCompModal.ProductModal.Term = 0;
            $scope.ProductCompModal.ProductModal.Deductible = 0;
            $scope.ProductCompModal.ProductModal.IsTaxable = false;
            $scope.ProductCompModal.saveButtonClicked = false;
            $scope.ProductCompModal.ProductModal.CostMethod = "Fixed Cost";
            $scope.ProductCompModal.setDataDefault();
        }

        $scope.ProductCompModal.setDataDefault = function () {
            $scope.ProductCompModal.setDefaultValidationModal();
            $scope.ProductCompModal.CategoryNameStr = "";
        }

        /**
         * On click of cancel button, close the popup
         */
        $scope.ProductCompModal.CancelProductForm = function (event) {
            $scope.ProductCompModal.closePopup();
        }

        /**
         * On click of Save button, save form data and close popup
         */
        $scope.ProductCompModal.SaveProductForm = function (event) {
            $scope.ProductCompModal.isValidForm = true;
            $scope.ProductCompModal.validateForm();

            if ($scope.ProductCompModal.isValidForm) {
                var productRecords = [];
                if ($scope.ProductCompModal.ProductModal.Cost == "" || $scope.ProductCompModal.ProductModal.Cost == null) {
                    $scope.ProductCompModal.ProductModal.Cost = 0.00; //cost value changed from 0 to "0.00" buy gourav 14-07-17
                }
                if ($scope.ProductCompModal.ProductModal.Price == "" || $scope.ProductCompModal.ProductModal.Price == null) {
                    $scope.ProductCompModal.ProductModal.Price = 0;
                }
                if ($scope.ProductCompModal.ProductModal.Mileage == "" || $scope.ProductCompModal.ProductModal.Mileage == null) {
                    $scope.ProductCompModal.ProductModal.Mileage = 0;
                }
                if ($scope.ProductCompModal.ProductModal.Term == "" || $scope.ProductCompModal.ProductModal.Term == null) {
                    $scope.ProductCompModal.ProductModal.Term = 0;
                }
                if ($scope.ProductCompModal.ProductModal.Deductible == "" || $scope.ProductCompModal.ProductModal.Deductible == null) {
                    $scope.ProductCompModal.ProductModal.Deductible = 0;
                }
                productRecords.push($scope.ProductCompModal.ProductModal);
                $scope.ProductCompModal.saveProductData(productRecords);
            } else {
                $scope.ProductCompModal.saveButtonClicked = false;
            }
        }

        $scope.ProductCompModal.validateForm = function () {

            angular.forEach($scope.ProductCompModal.productFormValidationModal, function (value, key) {
                $scope.ProductCompModal.validateFieldWithKey(key);
                if ($scope.ProductCompModal.productFormValidationModal[key].isError) {
                    $scope.ProductCompModal.isValidForm = false;
                }
            });
        }

        /**
         * Validation method for a field with modelKey value
         */
        $scope.ProductCompModal.validateFieldWithKey = function (modelKey) {
            var fieldValue = $scope.ProductCompModal.ProductModal[modelKey];
            var numericRegex = /^[0-9]*$/;
            var validateType = $scope.ProductCompModal.productFormValidationModal[modelKey].Type;

            if (validateType.indexOf('Numeric') > -1) {
                if (fieldValue != '' && fieldValue != undefined && !numericRegex.test(fieldValue)) {
                    $scope.ProductCompModal.productFormValidationModal[modelKey].isError = true;
                    $scope.ProductCompModal.productFormValidationModal[modelKey].ErrorMessage = $translate.instant('Invalid_Field_Value');
                } else {
                    $scope.ProductCompModal.productFormValidationModal[modelKey].isError = false;
                    $scope.ProductCompModal.productFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                    $scope.ProductCompModal.productFormValidationModal[modelKey].isError = true;
                    $scope.ProductCompModal.productFormValidationModal[modelKey].ErrorMessage = $translate.instant('Field_Is_Required');
                } else {
                    $scope.ProductCompModal.productFormValidationModal[modelKey].isError = false;
                    $scope.ProductCompModal.productFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            if (validateType.indexOf('Percent') > -1) {
                if (fieldValue < 0 || fieldValue > 100) {
                    $scope.ProductCompModal.productFormValidationModal[modelKey].isError = true;
                    $scope.ProductCompModal.productFormValidationModal[modelKey].ErrorMessage = $translate.instant('Percent_value_between_0_to_100');
                } else {
                    $scope.ProductCompModal.productFormValidationModal[modelKey].isError = false;
                    $scope.ProductCompModal.productFormValidationModal[modelKey].ErrorMessage = '';
                }
            }

            if ($scope.ProductCompModal.productFormValidationModal[modelKey].isError == true) {
                $scope.ProductCompModal.isValidForm = false;
            }
        }

        $scope.ProductCompModal.clearAdditionalFields = function () {
            $scope.ProductCompModal.ProductModal.Deductible = 0;
            $scope.ProductCompModal.ProductModal.Mileage = 0;
            $scope.ProductCompModal.ProductModal.Term = 0;
        }
        
        $scope.ProductCompModal.onKeyUpTaxable = function (event) {
            // If space/enter, then process the checkbox click functionality
            if (event.keyCode == 13) {
                $scope.ProductCompModal.onSelectTaxable();
            }
        }
        $scope.ProductCompModal.getAndSetDefaultTax = function () {
            AddEditProductService.getApplicableTaxList().then(function (taxList) {
                $scope.ProductCompModal.costMethodValueList = taxList.CostPicklistValues;
                $scope.ProductCompModal.IsTaxIncludingPricing = taxList.taxObj.IsTaxIncludingPricing;
                $scope.ProductCompModal.TaxList = taxList.taxObj.SalesTaxList;
                var defaultTaxIndex = _.findIndex(taxList.taxObj.SalesTaxList, {
                    IsDefault: true
                });
                if (defaultTaxIndex > -1) {
                    $scope.ProductCompModal.ProductModal.ApplicableTaxId = $scope.ProductCompModal.TaxList[defaultTaxIndex].Id;
                    $scope.ProductCompModal.Tax_Rate = $scope.ProductCompModal.TaxList[defaultTaxIndex].TaxRate;
                }
            }, function (errorSearchResult) {});
        }
        
        $scope.ProductCompModal.onSelectTaxable = function () {
            $scope.ProductCompModal.ProductModal.IsTaxable = !$scope.ProductCompModal.ProductModal.IsTaxable;
        }
        
        $scope.ProductCompModal.changeApplicableTax = function () {
            var selectedTaxIndex = _.findIndex($scope.ProductCompModal.TaxList, {
                Id: $scope.ProductCompModal.ProductModal.ApplicableTaxId
            });
            if (selectedTaxIndex > -1) {
                $scope.ProductCompModal.Tax_Rate = $scope.ProductCompModal.TaxList[selectedTaxIndex].TaxRate;
            }
        }
        
        $scope.ProductCompModal.getListForProductTypes = function () {
            AddEditProductService.getListOfAllProductTypes().then(function (ListOfAllProductTypes) {
                $scope.ProductCompModal.ProductTypeList = ListOfAllProductTypes;
                $scope.ProductCompModal.ProductTypeList.splice($scope.ProductCompModal.ProductTypeList.indexOf("Third Party"), 1);
            }, function (errorSearchResult) {
                responseData = errorSearchResult;
            });
        }
        
        $scope.$on('autoCompleteSelectCallback', function (event, args) {
            var obejctType = args.ObejctType.toUpperCase();
            var searchResult = args.SearchResult;
            var validationKey = args.ValidationKey;

            if ($scope.ProductCompModal.CategoryNameStr == $scope.ProductCompModal.ProductModal.CategoryName) {
                return;
            } else if (searchResult == null) {
                Notification.error($translate('No_matching_object_type_found', { 'ObejctType}' : args.ObejctType}));
                $scope.ProductCompModal.CategoryNameStr = "";
                $scope.ProductCompModal.ProductModal.CategoryName = "";
                $scope.ProductCompModal.ProductModal.CategoryId = null;
                return;
            }
            var objectsMapping = [{
                CATEGORY: {
                    Id: "CategoryId",
                    Name: "CategoryName",
                    selectMethod: null
                }
            }];
            if (objectsMapping[0][obejctType] != null) {
                $scope.ProductCompModal.ProductModal[objectsMapping[0][obejctType]["Id"]] = searchResult.originalObject.Value;
                $scope.ProductCompModal.ProductModal[objectsMapping[0][obejctType]["Name"]] = searchResult.originalObject.Name;
            }
            $scope.ProductCompModal.validateFieldWithKey(validationKey);
            if ($scope.ProductCompModal.productFormValidationModal[validationKey] == null || $scope.ProductCompModal.productFormValidationModal[validationKey].isError == false) {
                if (objectsMapping[0][obejctType].selectMethod != null) {
                    objectsMapping[0][obejctType].selectMethod(searchResult);
                }
            }
        });
        
        $scope.ProductCompModal.changeCostMethodValidateType = function () {
            if ($scope.ProductCompModal.ProductModal.CostMethod == 'Percent Retail') {
                $scope.ProductCompModal.productFormValidationModal['Cost'].Type = 'Percent';
                $scope.ProductCompModal.ProductModal.Cost = "0";
            } else {
                $scope.ProductCompModal.ProductModal.Cost = "0.00";
                $scope.ProductCompModal.productFormValidationModal['Cost'].Type = '';
                $scope.ProductCompModal.productFormValidationModal['Cost'].isError = false;
                $scope.ProductCompModal.productFormValidationModal['Cost'].ErrorMessage = '';
            }
        }
        
        /**
         * Get Product data from server and fill form
         */
        $scope.ProductCompModal.getCurrentProductData = function () {
            AddEditProductService.getApplicableTaxList().then(function (taxList) {
                $scope.ProductCompModal.costMethodValueList = taxList.CostPicklistValues;
                $scope.ProductCompModal.IsTaxIncludingPricing = taxList.taxObj.IsTaxIncludingPricing;
                $scope.ProductCompModal.TaxList = taxList.taxObj.SalesTaxList;
                AddEditProductService.getProductInfoById($scope.ProductCompModal.currentProductId).then(function (productRecord) {
                        $scope.ProductCompModal.UpdateFormFieldsWithExistingProduct(productRecord);
                    },
                    function (errorSearchResult) {
                        Notification.error($translate.instant('GENERIC_ERROR'));
                    });
            }, function (errorSearchResult) {});
        }

        /**
         * Method to Save product record data
         */
        $scope.ProductCompModal.saveProductData = function (productJSON) {
            AddEditProductService.saveProductInfo(productJSON).then(function (newProductDetails) {
                    if (newProductDetails.indexOf('Product Code already present for vendor') > -1) {
                        Notification.error(newProductDetails);
                    } else {
                        if ($scope.$parent.ViewVendor.RelatedLists_recordSaveCallback != undefined) {
                            angular.element('#AddNewProduct').modal('hide');
                            $scope.$parent.ViewVendor.RelatedLists_recordSaveCallback("{!$ObjectType.Product__c.label}", newProductDetails);
                            loadState($state, $rootScope.$previousState.name, {
                                Id: $rootScope.$previousStateParams.Id
                            });
                        }
                    }
                    // If parent page has product save callback method, then perform the method and close popup
                    $scope.ProductCompModal.saveButtonClicked = false;
                },
                function (errorSearchResult) {
                    Notification.error('GENERIC_ERROR');
                    $scope.ProductCompModal.closePopup();
                });
        }

        /**
         * Set all the form fields with existing Product record
         */
        $scope.ProductCompModal.UpdateFormFieldsWithExistingProduct = function (productRecord) {
            $scope.ProductCompModal.ProductModal = productRecord[0];
            if ($scope.ProductCompModal.ProductModal.CategoryName != null) {
                $scope.ProductCompModal.CategoryNameStr = $scope.ProductCompModal.ProductModal.CategoryName;
            }
            if ($scope.ProductCompModal.ProductModal.CostMethod == 'Percent Retail') {
                $scope.ProductCompModal.productFormValidationModal['Cost'].Type = 'Percent';
            } else {
                $scope.ProductCompModal.productFormValidationModal['Cost'].Type = '';
            }
            $scope.ProductCompModal.openPopup();
        }

        $scope.ProductCompModal.openProductPopup = function () {
            var vendorId = $stateParams.AddEditProductParams.vendorId;
            var productId = $stateParams.AddEditProductParams.productId;
            if (productId != undefined && productId != null && productId != '') {
                $scope.ProductCompModal.openEditProductPopup(productId, vendorId);
            } else {
                $scope.ProductCompModal.openAddProductPopup(vendorId);
            }
        }
        $scope.ProductCompModal.openProductPopup();
    }])
});