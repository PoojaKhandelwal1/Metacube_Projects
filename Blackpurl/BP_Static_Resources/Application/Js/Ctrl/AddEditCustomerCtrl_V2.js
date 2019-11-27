define(['Routing_AppJs_PK', 'AddEditCustomerService_V2','moment'], function(Routing_AppJs_PK, AddEditCustomerService_V2,moment) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditCustomerCtrl_V2', ['$q', '$scope', '$rootScope', '$stateParams', '$state', 'AddeditCustomerV2Service', '$translate', function($q, $scope, $rootScope, $stateParams, $state, AddeditCustomerV2Service, $translate) {
        var Notification = injector.get("Notification");
        $scope.M_AddEditCustomerV2 = $scope.M_AddEditCustomerV2 || {};
        $scope.F_AddEditCustomerV2 = $scope.F_AddEditCustomerV2 || {};
        $scope.M_AddEditCustomerV2.isFocusedCountry = false;
        $scope.M_AddEditCustomerV2.isFocusedState = false;
        $scope.M_AddEditCustomerV2.currentDropDownIndex = -1;
        $scope.M_AddEditCustomerV2.dateFormat = $Global.DateFormat;

        function resetCustomerValidationModel() {
            $scope.M_AddEditCustomerV2.CustomerValidation = {
                FirstName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'firstName,required,Maxlength,Minlength',
                    Maxlength: 80,
                    Minlength: 2,
                    FieldRelatedToCustomerInfoType: 'Individual'
                },
                LastName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'lastName,required,Maxlength,Minlength',
                    Maxlength: 80,
                    Minlength: 2,
                    FieldRelatedToCustomerInfoType: 'Individual'
                },
                HomeEmail: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'email',
                    FieldRelatedToCustomerInfoType: 'Individual'
                },
                WorkEmail: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'email',
                    FieldRelatedToCustomerInfoType: 'Business'
                },
                OtherEmail: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'email',
                    FieldRelatedToCustomerInfoType: 'IndividualOrBusiness'
                },
                HomeNumber: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'phone,Maxlength,Minlength',
                    Maxlength: 10,
                    Minlength: 10,
                    FieldRelatedToCustomerInfoType: 'Individual'
                },
                WorkNumber: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'phone,Maxlength,Minlength',
                    Maxlength: 10,
                    Minlength: 10,
                    FieldRelatedToCustomerInfoType: 'Business'
                },
                OtherPhone: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'phone,Maxlength,Minlength',
                    Maxlength: 10,
                    Minlength: 10,
                    FieldRelatedToCustomerInfoType: 'Business'
                },
                BillingPostalCode: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'PostalCode,Maxlength',
                    Maxlength: 10,
                    FieldRelatedToCustomerInfoType: 'IndividualOrBusiness'
                }
            };
        }

         $scope.M_AddEditCustomerV2.AdditionalFieldsInfo = {
            Birthday: {
                isPrimary: false,
                label: 'Birthday',
                fieldId: 'BirthdayId'
            },
             Company: {
                isPrimary: false,
                label: ' Company',
                fieldId: ' CompanyId'
            },
             JobTitle: {
                isPrimary: false,
                label: ' Job Title',
                fieldId: ' JobTitleId'
            },
             OtherEmail: {
                isPrimary: false,
                label: ' Other Email #',
                fieldId: ' OtherEmailId'
            },
             OtherPhone: {
                isPrimary: false,
                label: ' Other Phone',
                fieldId: ' OtherPhoneId'
            },
             PriceLevel: {
                isPrimary: false,
                label: ' Price Level',
                fieldId: ' PriceLevelId'
            },
             DriversLicense : {
                isPrimary: false,
                label: ' Drivers License#',
                fieldId: ' DriversLicenseId'
            }
        };

         var start = new Date(1900, 0, 1);
         var end = new Date(new Date().getFullYear()-1, 11, 31);
        $scope.M_AddEditCustomerV2.Birthdate = {
            maxDate: end,
            minDate:start,
            dateFormat: $scope.M_AddEditCustomerV2.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };

        $scope.F_AddEditCustomerV2.showAdditionalField = function(fieldName) {
            $scope.M_AddEditCustomerV2.AdditionalFieldsInfo[fieldName].isPrimary = true;
        }
        $scope.M_AddEditCustomerV2.AccountTypeList = {};
        var success = function() {
            var self = this;
            this.arguments = arguments[0];
            this.type = arguments[0].type,
                this.callback = arguments[0].callback,
                this.handler = function(successResult) {
                    switch (self.type) {
                        case 'getMasterData':
                            handleGetMasterDataResponse(successResult);
                            break;
                        case 'getOtherSimilarCustomer':
                            handleGetOtherSimilarCustomerResponse(successResult);
                            break;
                        case 'getAllAccountTypeData':
                            handlegetAllAccountTypeDataResponse(successResult);
                            break;    
                        case 'saveCustomer':
                            handleSaveCustomerResponse(successResult, self.arguments.isCreateCOU);
                            break;
                        default:
                            break;
                    }
                    if (typeof self.callback === 'function') {
                        self.callback();
                    }
                }

            function handleGetMasterDataResponse(masterDataList) {
                $scope.M_AddEditCustomerV2.CustomerMasterData = masterDataList;
                $scope.F_AddEditCustomerV2.SetCustomerFormDefault();
                $scope.F_AddEditCustomerV2.getAllAccountTypeData();
            }
            $(window).resize(function(){
                checkUserSuggestionPosition();
            });
            function checkUserSuggestionPosition() {
                setTimeout(function() {
                    if ($scope.M_AddEditCustomerV2.SimilarCustomers.length > 0 && window.outerWidth > 1024) {
                        angular.element(".customer-order-modal .user-suggestion").css("left", "-195px");
                    } else {
                        angular.element(".customer-order-modal .user-suggestion").css("left", "0px");
                    }
                }, 100);
            }

            function handleGetOtherSimilarCustomerResponse(SimilarCustomer) {
                checkUserSuggestionPosition();
                $scope.M_AddEditCustomerV2.SimilarCustomers = SimilarCustomer;
            }

            function handlegetAllAccountTypeDataResponse (successResult) {
                console.log(successResult);
                $scope.M_AddEditCustomerV2.AccountTypeList = successResult;
                 for(var i=0; i<$scope.M_AddEditCustomerV2.AccountTypeList.length;i++) {
                    if($scope.M_AddEditCustomerV2.AccountTypeList[i].IsDefault) {
                         $scope.M_AddEditCustomerV2.CustomerInfo.AccountType = $scope.M_AddEditCustomerV2.AccountTypeList[i].AccountType;
                          $scope.M_AddEditCustomerV2.CustomerInfo.AccountTypeId = $scope.M_AddEditCustomerV2.AccountTypeList[i].Id;
                    }
                }

            }

            function handleSaveCustomerResponse(CustomerId, isCreateCOU) {
                $scope.M_AddEditCustomerV2.isCreateBtnDisabled = false;
                Notification.success($translate.instant('Generic_Saved'));
                $scope.F_AddEditCustomerV2.hideAddEditCustomerModal();
                if ($state.current.name === 'CustomerOrder_V2.AddEditCustomerV2') {
                    var addCustomerCoBuyer = ($stateParams.AddEditCustomerParams && $stateParams.AddEditCustomerParams.addCustomerCoBuyer) ? true : false;
                    if (!isCreateCOU) {
                        $scope.F_CO.CustomerSaveCallback(CustomerId,addCustomerCoBuyer);
                        loadState($state, $rootScope.$previousState.name, {
                            Id: $rootScope.$previousStateParams.Id
                        });
                    } else {
                        var AddEditUnitParams = {
                            CustomerId: CustomerId,
                            UnitType: 'COU',
                            IsCreateFromAddCustomer: true,
                            COHeaderId: $scope.M_CO.COHeaderId,
                            SellingGroup: $stateParams.AddEditCustomerParams.SellingGroup,
                            addCustomerCoBuyer : addCustomerCoBuyer
                        }
                        $scope.M_CO.isLoading = false;
                        loadState($state, 'AddEditUnitV2', {
                            AddEditTempUnitParams: AddEditUnitParams
                        });
                    }
                } else if($state.current.name === 'AddEditAppointment.AddEditCustomerV2') {
                    if (!isCreateCOU) {
                        $scope.F_AddEditApp.CustomerSaveCallback(CustomerId);
                        loadState($state, 'AddEditAppointment');
                    } else {
                        var AddEditUnitParams = {
                            CustomerId: CustomerId,
                            UnitType: 'COU',
                            IsCreateFromAddCustomer: true,
                        }
                        $scope.M_AddEditApp.isLoading = false;
                        loadState($state, 'AddEditAppointment.AddEditUnitV2', {
                            AddEditTempUnitParams: AddEditUnitParams
                        });
                    }
                }else {
                    if (!isCreateCOU) {
                        if ($state.current.name === 'ViewCustomer.EditCustomerV2') {
                            $scope.ViewCustomer.loadCustomerInfo();
                        }
                        loadState($state, 'ViewCustomer', {
                            Id: CustomerId
                        });
                    } else {
                        var AddEditUnitParams = {
                            CustomerId: CustomerId,
                            UnitType: 'COU',
                            IsCreateFromAddCustomer: true
                        }
                        loadState($state, 'AddEditUnitV2', {
                            AddEditTempUnitParams: AddEditUnitParams
                        });
                    }
                }
            }
        }
        var error = function(errorMessage) { //TODO
            this.handler = function(error) {
                $scope.M_AddEditCustomerV2.isCreateBtnDisabled = false;
                if ($state.current.name === 'CustomerOrder_V2.AddEditCustomerV2') {
                    $scope.M_CO.isLoading = false;
                } else if($state.current.name === 'AddEditAppointment.AddEditCustomerV2') {
                    $scope.M_AddEditApp.isLoading = false;
                }
                if (!errorMessage) {
                    console.log(error);
                } else {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                }
            }
        }

        function openAddEditCustomerModal() {
            setTimeout(function() {
                angular.element('#customerpopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
            $scope.F_AddEditCustomerV2.getMasterData();
        }


         $scope.F_AddEditCustomerV2.getAllAccountTypeData = function() {
              var successJson;
            successJson = {
                'type': 'getAllAccountTypeData'
            };
            AddeditCustomerV2Service.getAllAccountTypeData().then(new success(successJson).handler, new error().handler);
        }

        $scope.F_AddEditCustomerV2.keyPressNavigationOnDropdownElements = function(event, dropdownDivId, templateName, dropdownList) {
            var keyCode = event.which ? event.which : event.keyCode;
            var tempList = angular.copy(dropdownList);
            var dropDownDivId = '#' + dropdownDivId;
            var idSubStr = '';
            var totalRecordsToTraverse = 0;
            if (tempList) {
                totalRecordsToTraverse += tempList.length;
            }
            if (keyCode == 40 && totalRecordsToTraverse > 0) {
                if (totalRecordsToTraverse - 1 > $scope.M_AddEditCustomerV2.currentDropDownIndex) {
                    $scope.M_AddEditCustomerV2.currentDropDownIndex++;
                    if (templateName == 'accountTypeto') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#accounttype_';
                     } else if(templateName == 'pricelevelto') {
                        idSubStr = '#pricelevel_'
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_AddEditCustomerV2.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.M_AddEditCustomerV2.currentDropDownIndex > 0) {
                    $scope.M_AddEditCustomerV2.currentDropDownIndex--;
                    if (templateName == 'accountTypeto') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else  
                        idSubStr = '#accounttype_';
                    }else if(templateName == 'pricelevelto') {
                        idSubStr = '#pricelevel_'
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_AddEditCustomerV2.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode == 13 && $scope.M_AddEditCustomerV2.currentDropDownIndex !== -1) {
                if (templateName == 'accountTypeto') {
                    $scope.F_AddEditCustomerV2.selectAccountType(tempList[$scope.M_AddEditCustomerV2.currentDropDownIndex]);
               }else if(templateName == 'pricelevelto') {
                      $scope.F_AddEditCustomerV2.selectPriceLevelType(tempList[$scope.M_AddEditCustomerV2.currentDropDownIndex]);
                }
                $scope.M_AddEditCustomerV2.currentDropDownIndex = -1;
            }
        }



        $scope.F_AddEditCustomerV2.getMasterData = function() {
            var successJson;
            successJson = {
                'type': 'getMasterData'
            };
            AddeditCustomerV2Service.getMasterData().then(new success(successJson).handler, new error().handler);
        }
        angular.element(document).on("click", "#customerpopup .modal-backdrop", function() {
            $scope.F_AddEditCustomerV2.hideAddEditCustomerModal();
        });
        $scope.F_AddEditCustomerV2.SetCustomerFormDefault = function() {
            for (i = 0; i < $scope.M_AddEditCustomerV2.CustomerMasterData.CountryList.length; i++) {
                if ($scope.M_AddEditCustomerV2.CustomerMasterData.CountryList[i].IsDefault) {
                    $scope.M_AddEditCustomerV2.CustomerInfo.BillingCountry = $scope.M_AddEditCustomerV2.CustomerMasterData.CountryList[i].CountryName;
                }
            }
            $scope.M_AddEditCustomerV2.State = $scope.M_AddEditCustomerV2.CustomerMasterData.StateList[0].countryNameToStateMap[$scope.M_AddEditCustomerV2.CustomerInfo.BillingCountry];
            for (var i = 0; i < $scope.M_AddEditCustomerV2.State.length; i++) {
                if ($scope.M_AddEditCustomerV2.State[i].IsDefault) {
                    $scope.M_AddEditCustomerV2.CustomerInfo.BillingState = $scope.M_AddEditCustomerV2.State[i].StateName;
                }
            }
            for(var i=0;i<$scope.M_AddEditCustomerV2.CustomerMasterData.PriceLevelList.length;i++){
                if($scope.M_AddEditCustomerV2.CustomerMasterData.PriceLevelList[i].IsDefault) {
                    $scope.M_AddEditCustomerV2.CustomerInfo.PriceLevelName = $scope.M_AddEditCustomerV2.CustomerMasterData.PriceLevelList[i].PriceLevelName;
                     $scope.M_AddEditCustomerV2.CustomerInfo.PriceLevelId = $scope.M_AddEditCustomerV2.CustomerMasterData.PriceLevelList[i].Id;
                }
                 
            }
            
        }
        $scope.F_AddEditCustomerV2.setFocus = function(elementId) {
            angular.element("#" + elementId).focus();
        }
        $scope.F_AddEditCustomerV2.showCountry = function() {
            $scope.M_AddEditCustomerV2.isFocusedCountry = true;
        }
        $scope.F_AddEditCustomerV2.hideCountry = function() {
            $scope.M_AddEditCustomerV2.isFocusedCountry = false;
        }
        $scope.F_AddEditCustomerV2.showStateList = function() {
            $scope.M_AddEditCustomerV2.isFocusedState = true;
        }
        $scope.F_AddEditCustomerV2.hideState = function() {
            $scope.M_AddEditCustomerV2.isFocusedState = false;
        }
        $scope.F_AddEditCustomerV2.selectCountryName = function(SelectedCountry) {
            $scope.M_AddEditCustomerV2.CustomerInfo.BillingCountry = SelectedCountry.CountryName;
            $scope.M_AddEditCustomerV2.isFocusedCountry = false;
            $scope.F_AddEditCustomerV2.changeBillingCountry()
        }

        $scope.F_AddEditCustomerV2.selectAccountType = function(selectedAccountType) {
            $scope.M_AddEditCustomerV2.CustomerInfo.AccountType = selectedAccountType.AccountType;
            $scope.M_AddEditCustomerV2.CustomerInfo.AccountTypeId = selectedAccountType.Id;
            $scope.M_AddEditCustomerV2.isFocusedAccountType = false;
        }
         $scope.F_AddEditCustomerV2.selectPriceLevelType = function(selectedPriceLevelRec) {
           $scope.M_AddEditCustomerV2.CustomerInfo.PriceLevelName = selectedPriceLevelRec.PriceLevelName;
           $scope.M_AddEditCustomerV2.CustomerInfo.PriceLevelId = selectedPriceLevelRec.Id;
           $scope.M_AddEditCustomerV2.isFocusedPriceLevel = false;
        }
        $scope.F_AddEditCustomerV2.selectStateName = function(SelectedSate) {
            $scope.M_AddEditCustomerV2.CustomerInfo.BillingState = SelectedSate.StateName;
        }
        $scope.F_AddEditCustomerV2.hideAddEditCustomerModal = function() {
            $scope.M_AddEditCustomerV2.isCreateBtnDisabled = false;
            angular.element('#customerpopup').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
           if($rootScope.$previousState.name !== 'AddEditAppointment') {
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            } else {
                loadState($state, 'AddEditAppointment');
            }
        }
        $scope.F_AddEditCustomerV2.saveCustomer = function(customerJson, isCreateCOU) {
            $scope.M_AddEditCustomerV2.isCreateBtnDisabled = true;
            for (var key in $scope.M_AddEditCustomerV2.CustomerValidation) { 
                if (($scope.M_AddEditCustomerV2.CustomerValidation[key].FieldRelatedToCustomerInfoType).indexOf(customerJson.Type) > -1) {
                    $scope.F_AddEditCustomerV2.validateForm(key);
                }
            }
            for (var key in $scope.M_AddEditCustomerV2.CustomerValidation) {
                if ($scope.M_AddEditCustomerV2.CustomerValidation.hasOwnProperty(key)) {
                    var validationObj = $scope.M_AddEditCustomerV2.CustomerValidation[key];
                    if ($scope.M_AddEditCustomerV2.CustomerValidation[key]['isError'] == true) {
                        Notification.error($scope.M_AddEditCustomerV2.CustomerValidation[key].ErrorMessage);
                        $scope.M_AddEditCustomerV2.isCreateBtnDisabled = false;
                        return;
                    }
                }
            }
            if ($state.current.name === 'CustomerOrder_V2.AddEditCustomerV2') {
                $scope.M_CO.isLoading = true;
            } else if($state.current.name === 'AddEditAppointment.AddEditCustomerV2') {
                $scope.M_AddEditApp.isLoading = true;
            }
            $scope.M_AddEditCustomerV2.CustomerInfo.IsBothAddressSame = true;
            successJson = {
                'type': 'saveCustomer',
                'isCreateCOU': isCreateCOU
            };
            if($scope.M_AddEditCustomerV2.CustomerInfo.Birthdate) {
                if($Global.SchedulingDateFormat === 'DD/MM/YYYY'){
                    $scope.M_AddEditCustomerV2.CustomerInfo.BirthDay = $scope.M_AddEditCustomerV2.CustomerInfo.Birthdate.slice(0,2);
                    $scope.M_AddEditCustomerV2.CustomerInfo.BirthMonth = $scope.M_AddEditCustomerV2.CustomerInfo.Birthdate.slice(3,5);
                    $scope.M_AddEditCustomerV2.CustomerInfo.BirthYear = $scope.M_AddEditCustomerV2.CustomerInfo.Birthdate.slice(6,$scope.M_AddEditCustomerV2.CustomerInfo.Birthdate.length);
                }
                else if($Global.SchedulingDateFormat === 'MM/DD/YYYY'){
                    $scope.M_AddEditCustomerV2.CustomerInfo.BirthMonth = $scope.M_AddEditCustomerV2.CustomerInfo.Birthdate.slice(0,2);
                    $scope.M_AddEditCustomerV2.CustomerInfo.BirthDay = $scope.M_AddEditCustomerV2.CustomerInfo.Birthdate.slice(3,5);
                    $scope.M_AddEditCustomerV2.CustomerInfo.BirthYear = $scope.M_AddEditCustomerV2.CustomerInfo.Birthdate.slice(6,$scope.M_AddEditCustomerV2.CustomerInfo.Birthdate.length);
                }
            }
            AddeditCustomerV2Service.saveCustomer(JSON.stringify($scope.M_AddEditCustomerV2.CustomerInfo)).then(new success(successJson).handler, new error().handler);
        }
       $scope.F_AddEditCustomerV2.UseExistingCustomer = function(CustomerId) {
            if ($state.current.name === 'CustomerOrder_V2.AddEditCustomerV2') {
                $scope.M_CO.isLoading = true;
                $scope.F_CO.CustomerSaveCallback(CustomerId);
                $scope.F_AddEditCustomerV2.hideAddEditCustomerModal();
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            } else if($state.current.name === 'AddEditAppointment.AddEditCustomerV2') {
                $scope.M_AddEditApp.isLoading = true;
                $scope.F_AddEditApp.CustomerSaveCallback(CustomerId);
                $scope.F_AddEditCustomerV2.hideAddEditCustomerModal();
            }
            
        }
        $scope.F_AddEditCustomerV2.clearSimilarCustomer = function(customerType) {
            resetCustomerValidationModel();
            if ($scope.M_AddEditCustomerV2.isEditMode) {
                $scope.M_AddEditCustomerV2.CustomerInfo.Type = customerType;
                return;
            }
            $scope.M_AddEditCustomerV2.CustomerInfo = {};
            $scope.M_AddEditCustomerV2.SimilarCustomers = [];
            $scope.M_AddEditCustomerV2.CustomerInfo = {
                IsCustomer: true,
                Active: true,
                IsVendor: false,
                Type: customerType
            };
            
             angular.forEach($scope.M_AddEditCustomerV2.AdditionalFieldsInfo, function(value, key) {
               $scope.M_AddEditCustomerV2.AdditionalFieldsInfo[key].isPrimary = false;
           });
            $scope.F_AddEditCustomerV2.getAllAccountTypeData();
            $scope.F_AddEditCustomerV2.SetCustomerFormDefault();
        }
        $scope.F_AddEditCustomerV2.changeBillingCountry = function() {
            var IsDefaultFlag = false;
            $scope.M_AddEditCustomerV2.State = $scope.M_AddEditCustomerV2.CustomerMasterData.StateList[0].countryNameToStateMap[$scope.M_AddEditCustomerV2.CustomerInfo.BillingCountry];
            for (var i = 0; i < $scope.M_AddEditCustomerV2.State.length; i++) {
                if ($scope.M_AddEditCustomerV2.State[i].IsDefault) {
                    $scope.M_AddEditCustomerV2.CustomerInfo.BillingState = $scope.M_AddEditCustomerV2.State[i].StateName;
                    IsDefaultFlag = true;
                }
            }
            if (!IsDefaultFlag) {
                $scope.M_AddEditCustomerV2.CustomerInfo.BillingState = ''
            }
        }
        $scope.F_AddEditCustomerV2.getOtherSimilarCustomer = function() {
            if ($scope.M_AddEditCustomerV2.isEditMode) {
                return;
            }
            var successJson;
            var SimilarCustomerJson = {};
            angular.copy($scope.M_AddEditCustomerV2.CustomerInfo, SimilarCustomerJson);
            if (SimilarCustomerJson['Type'] == 'Individual') {
                SimilarCustomerJson['BusinessName'] = "";
                SimilarCustomerJson['WorkEmail'] = "";
                SimilarCustomerJson['WorkNumber'] = "";
                SimilarCustomerJson['OtherPhone'] = "";
            } else {
                SimilarCustomerJson['LastName'] = "";
                SimilarCustomerJson['FirstName'] = "";
                SimilarCustomerJson['HomeEmail'] = "";
                SimilarCustomerJson['HomeNumber'] = "";
            }
            successJson = {
                'type': 'getOtherSimilarCustomer'
            };
            AddeditCustomerV2Service.getOtherSimilarCustomer(JSON.stringify(SimilarCustomerJson)).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_AddEditCustomerV2.validatePhone = function() {
            $scope.F_AddEditCustomerV2.validateForm('HomeNumber');
            $scope.F_AddEditCustomerV2.validateForm('OtherPhone');
            $scope.F_AddEditCustomerV2.validateForm('WorkNumber');
        }
        $scope.F_AddEditCustomerV2.validateForm = function(modelKey) {
            var validationObj = $scope.M_AddEditCustomerV2.CustomerValidation[modelKey];
            if (($scope.M_AddEditCustomerV2.CustomerInfo.BillingCountry == 'Australia') && (validationObj.Type.indexOf('phone') > -1)) {
                validationObj.Minlength = 8;
            } else if (validationObj.Type.indexOf('phone') > -1) {
                validationObj.Minlength = 10;
            }
            var isError = false;
            var ErrorMessage = '';
            var phoneRegEx = /^([0-9\(\)\/\+ \-]*)$/;
            var emailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
            var postalCodeRegEx = /^[a-zA-Z\d\s\-]+$/;
            var nameRegEx = /^[a-zA-Z\d\s]+$/;
            var validateType = validationObj.Type;
            if (validateType.indexOf('Minlength') > -1) {
                if ($scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != undefined && $scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != '' && $scope.M_AddEditCustomerV2.CustomerInfo[modelKey].length < validationObj.Minlength) {
                    isError = true;
                    ErrorMessage = $translate.instant('Min_length_should_be_error_message', {min_length : validationObj.Minlength});
                }
            }
            if (validateType.indexOf('Maxlength') > -1) {
                if ($scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != undefined && $scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != '' && $scope.M_AddEditCustomerV2.CustomerInfo[modelKey].length > validationObj.Maxlength) {
                    isError = true;
                    ErrorMessage = $translate.instant('Max_length_should_be_error_message', {max_length : validationObj.Maxlength});
                }
            }
            if (validateType.indexOf('phone') > -1) {
                if ($scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != undefined && $scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != '' && !phoneRegEx.test($scope.M_AddEditCustomerV2.CustomerInfo[modelKey])) {
                    isError = true;
                    ErrorMessage = $translate.instant('Label_Invalid') + ' ' + $translate.instant('Label_Phone_Number');
                }
                if ($scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != undefined && $scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != '' && $scope.M_AddEditCustomerV2.CustomerInfo[modelKey].length == 9 && ($scope.M_AddEditCustomerV2.CustomerInfo.BillingCountry == 'Australia')) {
                    isError = true;
                      ErrorMessage = $translate.instant(Min_Length_Should_Be) + ' ' + '8 ' + $translate.instant('OR') +' 10';
                }
            }
            if (validateType.indexOf('email') > -1) {
                if ($scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != undefined && $scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != '' && !emailRegEx.test($scope.M_AddEditCustomerV2.CustomerInfo[modelKey])) {
                    isError = true;
                    ErrorMessage = $translate.instant('Label_Invalid') + ' ' + $translate.instant('Label_Email');
                }
            }
            if (validateType.indexOf('PostalCode') > -1) {
                if ($scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != undefined && $scope.M_AddEditCustomerV2.CustomerInfo[modelKey] != '' && !postalCodeRegEx.test($scope.M_AddEditCustomerV2.CustomerInfo[modelKey])) {
                    isError = true;
                    ErrorMessage = $translate.instant('Label_Invalid') + ' ' + $translate.instant('Label_Postal');
                }
            }
            if (validateType.indexOf('required') > -1) {
                if ($scope.M_AddEditCustomerV2.CustomerInfo[modelKey] == undefined || $scope.M_AddEditCustomerV2.CustomerInfo[modelKey] == '') {
                    isError = true;
                    ErrorMessage = $translate.instant('Field_Is_Required');
                }
            }
            $scope.M_AddEditCustomerV2.CustomerValidation[modelKey]['isError'] = isError;
            $scope.M_AddEditCustomerV2.CustomerValidation[modelKey]['ErrorMessage'] = ErrorMessage;
        }
        $scope.F_AddEditCustomerV2.validateUserDetails = function() {
            if ($scope.M_AddEditCustomerV2.CustomerInfo.Type == 'Individual') {
                if ($scope.M_AddEditCustomerV2.CustomerInfo.FirstName == null || $scope.M_AddEditCustomerV2.CustomerInfo.FirstName == '' || $scope.M_AddEditCustomerV2.CustomerInfo.FirstName == undefined) {
                    return true;
                }
                if ($scope.M_AddEditCustomerV2.CustomerInfo.LastName == null || $scope.M_AddEditCustomerV2.CustomerInfo.LastName == '' || $scope.M_AddEditCustomerV2.CustomerInfo.LastName == undefined) {
                    return true;
                }
            } else if ($scope.M_AddEditCustomerV2.CustomerInfo.Type == 'Business') {
                if ($scope.M_AddEditCustomerV2.CustomerInfo.BusinessName == null || $scope.M_AddEditCustomerV2.CustomerInfo.BusinessName == '' || $scope.M_AddEditCustomerV2.CustomerInfo.BusinessName == undefined) {
                    return true;
                }
            }
            return false;
        }

        function loadAddCustomerModalData() {
            $scope.M_AddEditCustomerV2.isEditMode = false;
            $scope.M_AddEditCustomerV2.CustomerInfo = {
                IsCustomer: true,
                Active: true,
                IsVendor: false,
                Type: 'Individual'
            };
            openAddEditCustomerModal();
        }

        function loadEditCustomerModalData() {
            $scope.M_AddEditCustomerV2.isEditMode = true;
            $scope.M_AddEditCustomerV2.CustomerInfo = $stateParams.AddEditCustomerParams.customerRec;
            openAddEditCustomerModal();
        }

        function loadAddEditCustomerModalData() {
            resetCustomerValidationModel();
            if ($stateParams.AddEditCustomerParams && $stateParams.AddEditCustomerParams.isEditMode) { 
                loadEditCustomerModalData();
            } else { 
                loadAddCustomerModalData();
            }
        }
        loadAddEditCustomerModalData();
    }]);
});