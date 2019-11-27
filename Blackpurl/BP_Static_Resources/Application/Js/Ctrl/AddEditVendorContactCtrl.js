define(['Routing_AppJs_PK', 'AddEditVendorContactServices', 'AngularNgEnter'], function (Routing_AppJs_PK, AddEditVendorContactServices, AngularNgEnter) {
    var injector = angular.injector(['ui-notification', 'ng']);

    $(document).ready(function () {
        setTimeout(function () {
            $('[data-toggle="tooltip"]').tooltip({
                placement: 'bottom'
            });
        }, 1000);
    });

    Routing_AppJs_PK.controller('AddEditVendorContactCtrl', ['$scope', '$q', '$rootScope', '$stateParams', '$state', 'VendorVendorService', function ($scope, $q, $rootScope, $stateParams, $state, VendorVendorService) {
        var Notification = injector.get("Notification");
        $scope.VendorContactModal.ContactInfo = {};
        $scope.VendorContactModal.ContactInfo.PreferredEmail = false;
        $scope.VendorContactModal.ContactInfo.PreferredPhone = false;
        $scope.VendorContactModal.ContactInfo.PreferredSMS = false;
        $scope.VendorContactModal.ContactInfo.IsSMS = false;
        $scope.VendorContactModal.ContactInfo.ParentVendor;
        $scope.VendorContactModal.Country = '';
        $scope.VendorContactModal.saveButtonClicked = false;

        $scope.VendorContactModal.openAddVendorContactPopup = function (vendorId) {
            $scope.VendorContactModal.saveButtonClicked = false;
            $scope.VendorContactModal.clearAllData();
            $scope.VendorContactModal.ContactInfo.ParentVendor = vendorId;
            $scope.VendorContactModal.openPopup();
        }

        $scope.VendorContactModal.openEditVendorContactPopup = function (contactId, vendorId) {
            $scope.VendorContactModal.saveButtonClicked = false;
            $scope.VendorContactModal.clearAllData();
            $scope.VendorContactModal.ContactInfo.ParentVendor = vendorId;
            $scope.VendorContactModal.getVendorContact(contactId);
            $scope.VendorContactModal.currentContactId = contactId;
        }

        $scope.VendorContactModal.openPopup = function () {
            setTimeout(function () {
                angular.element('#ContactPopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
            setTimeout(function () {
                angular.element(document.getElementById("ContactPopup").querySelector('[tabindex="1"]')).focus();
            }, 1500);
        }

        $scope.VendorContactModal.closePopup = function () {
            angular.element('#ContactPopup').modal('hide');
            setTimeout(function () {
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }, 1000);
        }

        $scope.VendorContactModal.formFieldJustGotFocus = function (Value) {
            showToolTip(Value);
        }
        
        $scope.VendorContactModal.textChangeAction = function (key) {
            if (key == 'Phone' && ($scope.VendorContactModal.ContactInfo.Phone == null || $scope.VendorContactModal.ContactInfo.Phone.length == 0)) {
                $scope.VendorContactModal.ContactInfo.PreferredPhone = false;
                $scope.VendorContactModal.ContactInfo.PreferredSMS = false;
                $scope.VendorContactModal.ContactInfo.IsSMS = false;
            } else if (key == 'Email' && ($scope.VendorContactModal.ContactInfo.Email == null || $scope.VendorContactModal.ContactInfo.Email.length == 0)) {
                $scope.VendorContactModal.ContactInfo.PreferredEmail = false;
            }
        }

        $scope.VendorContactModal.markFavourite = function (key) {
            if (key == 'PreferredPhone' && $scope.VendorContactModal.ContactInfo.Phone != null && $scope.VendorContactModal.ContactInfo.Phone.length != 0) {
                $scope.VendorContactModal.validateFieldWithKey('Phone');
                if ($scope.VendorContactModal.VendorContactFormValidationModal.Email.isError == false) {
                    if ($scope.VendorContactModal.ContactInfo.PreferredPhone == true) {
                        $scope.VendorContactModal.ContactInfo.PreferredPhone = false;
                    } else {
                        $scope.VendorContactModal.ContactInfo.PreferredPhone = true;
                    }
                }
            } else if (key == 'PreferredEmail' && $scope.VendorContactModal.ContactInfo.Email != null && $scope.VendorContactModal.ContactInfo.Email.length != 0) {
                $scope.VendorContactModal.validateFieldWithKey('Email');
                if ($scope.VendorContactModal.VendorContactFormValidationModal.Phone.isError == false) {
                    if ($scope.VendorContactModal.ContactInfo.PreferredEmail == true) {
                        $scope.VendorContactModal.ContactInfo.PreferredEmail = false;
                    } else {
                        $scope.VendorContactModal.ContactInfo.PreferredEmail = true;
                    }
                }
            } else if (key == 'PreferredSMS' && $scope.VendorContactModal.ContactInfo.Phone != null && $scope.VendorContactModal.ContactInfo.Phone.length != 0) {
                $scope.VendorContactModal.validateFieldWithKey('Phone');
                if ($scope.VendorContactModal.VendorContactFormValidationModal.Phone.isError == false) {
                    if ($scope.VendorContactModal.ContactInfo.PreferredSMS == true) {
                        $scope.VendorContactModal.ContactInfo.PreferredSMS = false;
                    } else {
                        $scope.VendorContactModal.ContactInfo.IsSMS = true;
                        $scope.VendorContactModal.ContactInfo.PreferredSMS = true;
                    }
                }
            } else if (key == 'IsSMS' && $scope.VendorContactModal.ContactInfo.Phone != null && $scope.VendorContactModal.ContactInfo.Phone.length != 0) {
                $scope.VendorContactModal.validateFieldWithKey('Phone');
                if ($scope.VendorContactModal.VendorContactFormValidationModal.Phone.isError == false) {
                    if ($scope.VendorContactModal.ContactInfo.IsSMS == true) {
                        $scope.VendorContactModal.ContactInfo.IsSMS = false;
                    } else {
                        $scope.VendorContactModal.ContactInfo.IsSMS = true;
                    }
                }
            }
        }

        /**
         * Method to set default values for validation model
         */
        $scope.VendorContactModal.setDefaultValidationModel = function () {
            $scope.VendorContactModal.VendorContactFormValidationModal = {
                FirstName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required',
                    Maxlength: 80
                },
                LastName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required',
                    Maxlength: 80
                },
                Email: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Email'
                },
                Phone: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'phone,Maxlength,Minlength',
                    Minlength: 10,
                    Maxlength: 10
                }
            };
        }

        $scope.VendorContactModal.validateForm = function () {
            angular.forEach($scope.VendorContactModal.VendorContactFormValidationModal, function (value, key) {
                $scope.VendorContactModal.validateFieldWithKey(key);
                if ($scope.VendorContactModal.VendorContactFormValidationModal[key].isError) {
                    $scope.VendorContactModal.isValidForm = false;
                }
            });
        }

        $scope.VendorContactModal.validateFieldWithKey = function (modelKey) {
            var validationObj = $scope.VendorContactModal.VendorContactFormValidationModal[modelKey];
            if (($scope.VendorContactModal.Country == 'Australia') && (validationObj.Type.indexOf('phone') > -1)) {
                validationObj.Minlength = 8;
            } else if (validationObj.Type.indexOf('phone') > -1) {
                validationObj.Minlength = 10;
            }
            var isError = false;
            var ErrorMessage = '';
            var phoneRegEx = /^([0-9\(\)\/\+ \-]*)$/;
            var emailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;

            var validateType = validationObj.Type;
            if (validateType.indexOf('Minlength') > -1) {
                if ($scope.VendorContactModal.ContactInfo[modelKey] != undefined && $scope.VendorContactModal.ContactInfo[modelKey] != '' && $scope.VendorContactModal.ContactInfo[modelKey].length < validationObj.Minlength) {
                    isError = true;
                    ErrorMessage = 'Min length should be ' + validationObj.Minlength;
                }
            }
            if (validateType.indexOf('Maxlength') > -1) {
                if ($scope.VendorContactModal.ContactInfo[modelKey] != undefined && $scope.VendorContactModal.ContactInfo[modelKey] != '' && $scope.VendorContactModal.ContactInfo[modelKey].length > validationObj.Maxlength) {
                    isError = true;
                    ErrorMessage = 'Max length should be ' + validationObj.Maxlength;
                }
            }
            if (validateType.indexOf('phone') > -1) {
                if ($scope.VendorContactModal.ContactInfo[modelKey] != undefined && $scope.VendorContactModal.ContactInfo[modelKey] != '' && !phoneRegEx.test($scope.VendorContactModal.ContactInfo[modelKey])) {
                    isError = true;
                    ErrorMessage = 'Invalid Phone Number';
                }
                if ($scope.VendorContactModal.ContactInfo[modelKey] != undefined && $scope.VendorContactModal.ContactInfo[modelKey] != '' && $scope.VendorContactModal.ContactInfo[modelKey].length == 9 && ($scope.VendorContactModal.Country == 'Australia')) {
                    isError = true;
                    ErrorMessage = $Label.Min_Length_Should_Be + ' ' + '8 or 10';
                }
            }
            if (validateType.indexOf('Email') > -1) {
                if ($scope.VendorContactModal.ContactInfo[modelKey] != undefined && $scope.VendorContactModal.ContactInfo[modelKey] != '' && !emailRegEx.test($scope.VendorContactModal.ContactInfo[modelKey])) {
                    isError = true;
                    ErrorMessage = 'Invalid Email Id';
                }
            }
            if (validateType.indexOf('Required') > -1) {
                if ($scope.VendorContactModal.ContactInfo[modelKey] == undefined || $scope.VendorContactModal.ContactInfo[modelKey] == '') {
                    isError = true;
                    ErrorMessage = 'Field is Required';
                }
            }
            $scope.VendorContactModal.VendorContactFormValidationModal[modelKey]['isError'] = isError;
            $scope.VendorContactModal.VendorContactFormValidationModal[modelKey]['ErrorMessage'] = ErrorMessage;
        }

        /**
         * Clear and Set Default Values and validations for popup
         */
        $scope.VendorContactModal.clearAllData = function () {
            $scope.VendorContactModal.currentContactId = null;
            $scope.VendorContactModal.ContactInfo = {};
            $scope.VendorContactModal.ContactInfo.PreferredEmail = false;
            $scope.VendorContactModal.ContactInfo.PreferredPhone = false;
            $scope.VendorContactModal.ContactInfo.PreferredSMS = false;
            $scope.VendorContactModal.ContactInfo.IsSMS = false;
            $scope.VendorContactModal.setDefaultValidationModel();
        }

        /**
         * Method to perform CANCEL action for popup
         */
        $scope.VendorContactModal.CancelContactForm = function () {
            angular.element('#ContactPopup').modal('hide');
            setTimeout(function () {
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }, 1000);
        }

        /**
         * Method to perform SAVE operation in database
         */
        $scope.VendorContactModal.saveVendorContactRecord = function () {
            $scope.VendorContactModal.isValidForm = true;
            if ($scope.VendorContactModal.saveButtonClicked) {
                return;
            }
            $scope.VendorContactModal.saveButtonClicked = true;
            $scope.VendorContactModal.validateForm();

            if ($scope.VendorContactModal.isValidForm == false) {
                $scope.VendorContactModal.saveButtonClicked = false;
                angular.element(".redborder")[0].focus();
                return;
            }
            var vendorContactArray = [];
            if ($scope.VendorContactModal.ContactInfo.Extension == "" || $scope.VendorContactModal.ContactInfo.Extension == null) {
                $scope.VendorContactModal.ContactInfo.Extension = 0;
            }
            vendorContactArray.push($scope.VendorContactModal.ContactInfo);
            VendorVendorService.saveVendorContact(angular.toJson(vendorContactArray)).then(function (relatedVendorContactList) {
                if ($scope.$parent.ViewVendor != undefined && $scope.$parent.ViewVendor.RelatedLists_recordSaveCallback != undefined) {
                    angular.element('#ContactPopup').modal('hide');
                    $scope.$parent.ViewVendor.RelatedLists_recordSaveCallback("{!$ObjectType.Contact.label}", relatedVendorContactList);
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                }
                setTimeout(function () {
                    $scope.VendorContactModal.saveButtonClicked = false;
                }, 100);

            }, function (errorSearchResult) {
                Notification.error('Error while saving record.');
                $scope.VendorContactModal.closePopup();
                $scope.VendorContactModal.saveButtonClicked = false;
            });
        }

        /**
         * Method to perform Delete operation in database
         */
        $scope.VendorContactModal.removeVendorContactRecord = function (vendorContactId) {
            VendorVendorService.removeVendorContact(vendorId, vendorContactId).then(function (relatedVendorContactList) {
                //TODO
            }, function (errorSearchResult) {
                $scope.ViewVendor.VendorInfo = errorSearchResult;
            });
        }

        /**
         * Method to get Vendor Contact Record
         */
        $scope.VendorContactModal.getVendorContact = function (vendorContactId) {
            VendorVendorService.getVendorContactById(vendorContactId).then(function (vendorContactRec) {
                $scope.VendorContactModal.ContactInfo = vendorContactRec[0];
                $scope.VendorContactModal.openPopup();
            }, function (errorSearchResult) {
                $scope.ViewVendor.VendorInfo = errorSearchResult;
            });
        }

        $scope.VendorContactModal.openVendorContactPopup = function () {
            var vendorId = $stateParams.AddEditVendorContactParams.vendorId;
            var contactId = $stateParams.AddEditVendorContactParams.contactId;
            $scope.VendorContactModal.Country = $stateParams.AddEditVendorContactParams.country;
            if (contactId != undefined && contactId != null && contactId != '') {
                $scope.VendorContactModal.openEditVendorContactPopup(contactId, vendorId);
            } else {
                $scope.VendorContactModal.openAddVendorContactPopup(vendorId);
            }
        }
        $scope.VendorContactModal.openVendorContactPopup();
    }])
});