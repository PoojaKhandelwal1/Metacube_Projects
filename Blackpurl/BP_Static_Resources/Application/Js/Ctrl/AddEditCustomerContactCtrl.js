define(['Routing_AppJs_PK', 'AddEditCustomerContactServices'], function(Routing_AppJs_PK, AddEditCustomerContactServices) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditCustomerContactCtrl', ['$scope', '$q', '$rootScope', '$state', '$stateParams', 'CustomerCustomerService','$translate', function($scope, $q, $rootScope, $state, $stateParams, CustomerCustomerService,$translate) {
        var Notification = injector1.get("Notification");
        $scope.CustomerContact = {};
        $scope.CustomerContact.ContactInfo = {};
        $scope.CustomerContact.ContactInfo.PreferredEmail = false;
        $scope.CustomerContact.ContactInfo.PreferredPhone = false;
        $scope.CustomerContact.ContactInfo.PreferredSMS = false;
        $scope.CustomerContact.ContactInfo.IsSMS = false;
        $scope.CustomerContact.ContactInfo.ParentCustomer;
        $scope.CustomerContact.Country = '';
        $scope.$on('EditContactEvent', function(event, args) {
            $scope.CustomerContact.clearAllData();
            $scope.CustomerContact.ContactInfo.ParentCustomer = args.parentCustomerId;
            $scope.CustomerContact.getCustomerContact(args.contactId);
        });
        $scope.$on('AddContactEvent', function(event, args) {
            $scope.CustomerContact.clearAllData();
            $scope.CustomerContact.ContactInfo.ParentCustomer = args.parentCustomerId;
            angular.element('#ContactPopup').modal({
                backdrop: 'static',
                keyboard: false
            });
        });
        $scope.CustomerContact.formFieldJustGotFocus = function(Value) {
            showToolTip(Value);
        }
        $scope.CustomerContact.markFavourite = function(key) {
            if (key == 'PreferredPhone') {
                if ($scope.CustomerContact.ContactInfo.PreferredPhone == true) {
                    $scope.CustomerContact.ContactInfo.PreferredPhone = false;
                } else {
                    $scope.CustomerContact.ContactInfo.PreferredPhone = true;
                }
            } else if (key == 'PreferredEmail') {
                if ($scope.CustomerContact.ContactInfo.PreferredEmail == true) {
                    $scope.CustomerContact.ContactInfo.PreferredEmail = false;
                } else {
                    $scope.CustomerContact.ContactInfo.PreferredEmail = true;
                }
            } else if (key == 'PreferredSMS') {
                if ($scope.CustomerContact.ContactInfo.PreferredSMS == true) {
                    $scope.CustomerContact.ContactInfo.PreferredSMS = false;
                } else {
                    $scope.CustomerContact.ContactInfo.IsSMS = true;
                    $scope.CustomerContact.ContactInfo.PreferredSMS = true;
                }
            } else if (key == 'IsSMS') {
                if ($scope.CustomerContact.ContactInfo.IsSMS == true) {
                    $scope.CustomerContact.ContactInfo.IsSMS = false;
                } else {
                    $scope.CustomerContact.ContactInfo.IsSMS = true;
                }
            }
        }
        $scope.CustomerContact.setDefaultValidationModel = function() {
            $scope.CustomerContact.CustomerContactFormValidationModal = {
                FirstName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required,Maxlength',
                    Maxlength: 80
                },
                LastName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required,Maxlength',
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
        $scope.CustomerContact.validateForm = function(modelKey) {
            var validationObj = $scope.CustomerContact.CustomerContactFormValidationModal[modelKey];
            if (($scope.CustomerContact.Country == 'Australia') && (validationObj.Type.indexOf('phone') > -1)) {
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
                if ($scope.CustomerContact.ContactInfo[modelKey] != undefined && $scope.CustomerContact.ContactInfo[modelKey] != '' && $scope.CustomerContact.ContactInfo[modelKey].length < validationObj.Minlength) {
                    isError = true;
                    ErrorMessage = $translate.instant('Min_Length_Should_Be')+ ' ' + validationObj.Minlength;
                }
            }
            if (validateType.indexOf('Maxlength') > -1) {
                if ($scope.CustomerContact.ContactInfo[modelKey] != undefined && $scope.CustomerContact.ContactInfo[modelKey] != '' && $scope.CustomerContact.ContactInfo[modelKey].length > validationObj.Maxlength) {
                    isError = true;
                    ErrorMessage = $translate.instant('Max_Length_Should_Be')+ ' ' + validationObj.Maxlength;
                }
            }
            if (validateType.indexOf('phone') > -1) {
                if ($scope.CustomerContact.ContactInfo[modelKey] != undefined && $scope.CustomerContact.ContactInfo[modelKey] != '' && !phoneRegEx.test($scope.CustomerContact.ContactInfo[modelKey])) {
                    isError = true;
                    ErrorMessage = $translate.instant('Invalid_phone_number');
                }
                if ($scope.CustomerContact.ContactInfo[modelKey] != undefined && $scope.CustomerContact.ContactInfo[modelKey] != '' && $scope.CustomerContact.ContactInfo[modelKey].length == 9 && ($scope.CustomerContact.Country == 'Australia')) {
                    isError = true;
                    ErrorMessage = $translate.instant('Min_Length_Should_Be') + ' ' + '8 or 10';
                }
            }
            if (validateType.indexOf('Email') > -1) {
                if ($scope.CustomerContact.ContactInfo[modelKey] != undefined && $scope.CustomerContact.ContactInfo[modelKey] != '' && !emailRegEx.test($scope.CustomerContact.ContactInfo[modelKey])) {
                    isError = true;
                    ErrorMessage = $translate.instant('Invalid_email_id');
                }
            }
            if (validateType.indexOf('Required') > -1) {
                if ($scope.CustomerContact.ContactInfo[modelKey] == undefined || $scope.CustomerContact.ContactInfo[modelKey] == '') {
                    isError = true;
                    ErrorMessage = $translate.instant('Field_Is_Required');
                }
            }
            $scope.CustomerContact.CustomerContactFormValidationModal[modelKey]['isError'] = isError;
            $scope.CustomerContact.CustomerContactFormValidationModal[modelKey]['ErrorMessage'] = ErrorMessage;
        }
        // Clear and Set Default Values and validations for popup
        $scope.CustomerContact.clearAllData = function() {
            $scope.CustomerContact.ContactInfo = {};
            $scope.CustomerContact.ContactInfo.PreferredEmail = false;
            $scope.CustomerContact.ContactInfo.PreferredPhone = false;
            $scope.CustomerContact.ContactInfo.PreferredSMS = false;
            $scope.CustomerContact.ContactInfo.IsSMS = false;
            $scope.CustomerContact.ContactInfo.Relation = 'Employee';
            $scope.CustomerContact.setDefaultValidationModel();
        }
        // Method to perform SAVE action for popup
        $scope.CustomerContact.CancelContactForm = function() {
            angular.element('#ContactPopup').modal('hide');
            hideModelWindow();
            setTimeout(function() {
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }, 1000);
        }
        // Method to perform SAVE operation in database
        $scope.CustomerContact.saveCustomerContactRecord = function() {
            $scope.CustomerContact.validateForm('FirstName');
            $scope.CustomerContact.validateForm('LastName');
            for (var key in $scope.CustomerContact.CustomerContactFormValidationModal) {
                if ($scope.CustomerContact.CustomerContactFormValidationModal.hasOwnProperty(key)) {
                    var validationObj = $scope.CustomerContact.CustomerContactFormValidationModal[key];
                    if (validationObj.isError == true) {
                        return;
                    }
                }
            }
            var customerContactArray = [];
            customerContactArray.push($scope.CustomerContact.ContactInfo);
            CustomerCustomerService.saveCustomerContact(angular.toJson(customerContactArray)).then(function(relatedCustomerContactList) {
                if ($scope.$parent.ViewCustomer != undefined && $scope.$parent.ViewCustomer.UpdateCustomerContactsLists != undefined) {
                    if ($scope.$parent.ViewCustomer.CustomerContacts_recordSaveCallback != undefined) {
                        $scope.$parent.ViewCustomer.CustomerContacts_recordSaveCallback(relatedCustomerContactList);
                    } else if ($scope.$parent.ViewCustomer.UpdateCustomerContactsLists != undefined) {
                        $scope.$parent.ViewCustomer.UpdateCustomerContactsLists(relatedCustomerContactList);
                    }
                    $scope.CustomerContact.CancelContactForm(); 
                }
                if ($scope.$parent.ViewVendor != undefined && $scope.$parent.ViewVendor.RelatedLists_recordSaveCallback != undefined) {
                    $scope.$parent.ViewVendor.RelatedLists_recordSaveCallback("{!JSENCODE($ObjectType.Contact.label)}", relatedCustomerContactList);
                }
            }, function(errorSearchResult) {
            });
        }
        // Method to perform Delete operation in database
        $scope.CustomerContact.removeCustomerContactRecord = function(customerContactId) {
            CustomerCustomerService.removeCustomerContact(customerId, customerContactId).then(function(relatedCustomerContactList) {}, function(errorSearchResult) {
                $scope.ViewCustomer.CustomerInfo = errorSearchResult;
            });
        }
        // Method to get Customer Contact Record
        $scope.CustomerContact.getCustomerContact = function(customerContactId) {
            CustomerCustomerService.getCustomerContactById(customerContactId).then(function(customerContactRec) {
                // Set all the data models
                $scope.CustomerContact.ContactInfo = customerContactRec[0];
                setTimeout(function() {
                    angular.element('#ContactPopup').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                }, 100);
            }, function(errorSearchResult) {
                $scope.ViewCustomer.CustomerInfo = errorSearchResult;
            });
        }
        $scope.CustomerContact.openAddCustomerContact = function() {
            $scope.CustomerContact.clearAllData();
            $scope.CustomerContact.Country = $stateParams.AddEditCustomerContactParams.country;
            $scope.CustomerContact.ContactInfo.ParentCustomer = $stateParams.AddEditCustomerContactParams.parentCustomerId;
            setTimeout(function() {
                angular.element('#ContactPopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
        }
        $scope.CustomerContact.openEditCustomerContact = function(ContactId) {
            $scope.CustomerContact.clearAllData();
            $scope.CustomerContact.Country = $stateParams.AddEditCustomerContactParams.country;
            $scope.CustomerContact.ContactInfo.ParentCustomer = $stateParams.AddEditCustomerContactParams.parentCustomerId;
            $scope.CustomerContact.getCustomerContact(ContactId);
        }
        $scope.CustomerContact.openCustomerContactPopup = function() {
            var contactId = $stateParams.AddEditCustomerContactParams.contactId;
            if (contactId != undefined && contactId != null && contactId != '') {
                $scope.CustomerContact.openEditCustomerContact(contactId);
            } else {
                $scope.CustomerContact.openAddCustomerContact();
            }
        }
        $scope.CustomerContact.openCustomerContactPopup();
    }])
});