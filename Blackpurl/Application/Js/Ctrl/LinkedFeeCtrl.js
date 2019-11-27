define(['Routing_AppJs_PK', 'LinkedFeeServices', 'dirNumberInput'],
    function (Routing_AppJs_PK, LinkedFeeServices, dirNumberInput) {
        var injector = angular.injector(['ui-notification', 'ng']);
        Routing_AppJs_PK.controller('LinkedFeeCtrl', ['$scope', '$timeout', '$rootScope', '$state', '$stateParams', 'LinkedFeeServices','$translate',
            function ($scope, $timeout, $rootScope, $state, $stateParams, LinkedFeeServices,$translate) {
                var Notification = injector.get("Notification");
                var origin = window.location.origin;
                var url = origin + '/apex/';
                $scope.showLoading = true;
                $scope.LinkedFeeModel = {};
                $scope.LinkedFeeModel.UserFirstName = $Global.UserFirstName;
                $scope.LinkedFeeModel.UserLastName = $Global.UserLastName;
                $scope.currentUserGroupName = $Global.userGroupName;
                $scope.currentUserGroupColor = $Global.userGroupColor;
                $scope.LinkedFeeModel.FeeNameStr = "";
                $scope.LinkedFeeModel.CurrentSection = 'Overview';
                $scope.LinkedFeeModel.LinkedFeeList = [];
                $scope.LinkedFeeModel.LinkedFeeOverviewWrapperList = [];
                $scope.LinkedFeeModel.currentSelectedEnvFeeIndex = -1;

                $scope.$on('autoCompleteSelectCallback', function (event, args) {
                    var objectType = args.ObejctType.toUpperCase();
                    var searchResult = args.SearchResult;
                    var validationKey = args.ValidationKey;

                    if (searchResult != null) {
                        $scope.LinkedFeeModel.LinkedFeeRec.FeeId = searchResult.originalObject.Id;
                        if (searchResult.originalObject.feeDetails != undefined) {
                            $scope.LinkedFeeModel.LinkedFeeRec.FeeDescription = searchResult.originalObject.feeDetails.Description;
                            $scope.LinkedFeeModel.LinkedFeeRec.Price = searchResult.originalObject.feeDetails.Price;
                        }
                    }
                });

                $scope.LinkedFeeModel.FeeFieldsFilter = {
                    ActiveFee: [{
                        Field: "Active__c",
                        Value: true,
                        Operator: "="
                    }]
                };
                $scope.LinkedFeeModel.MoveToState = function (stateName, attr) {
                    loadState($state, stateName, attr);
                }
                $scope.LinkedFeeModel.setFocusOnInput = function () {
                    $scope.LinkedFeeModel.isFocused = true;
                }
                $scope.LinkedFeeModel.setBlurOnInput = function () {
                    $scope.LinkedFeeModel.isFocused = false;
                }
                $scope.LinkedFeeModel.selectFee = function (feeObj) {
                    $scope.LinkedFeeModel.LinkedFeeRec.FeeId = feeObj.Id;
                    $scope.LinkedFeeModel.LinkedFeeRec.FeeDescription = feeObj.Description;
                    $scope.LinkedFeeModel.LinkedFeeRec.Price = feeObj.Price;
                    $scope.LinkedFeeModel.feesearchObj = feeObj.Title;
                }
                $scope.LinkedFeeModel.getFeeList = function () {
                    LinkedFeeServices.getFeeResults().then(function (feeList) {
                        for (var i = 0; i < feeList.length; i++) {
                            feeList[i].Title = feeList[i].Code + ' - ' + feeList[i].Description + ' - $' + feeList[i].Price.toFixed(2);
                            if ($scope.LinkedFeeModel.LinkedFeeRec.FeeId == feeList[i].Id) {
                                $scope.LinkedFeeModel.feesearchObj = feeList[i].Title;
                            }
                        }
                        $scope.LinkedFeeModel.totalFeesList = feeList;
                    }, function (errorSearchResult) {

                    });
                }
                $scope.LinkedFeeModel.openLinkFeePopup = function (index) {
                    $scope.LinkedFeeModel.LinkedFeeRec = {};
                    $scope.LinkedFeeModel.feesearchObj = '';
                    $scope.LinkedFeeModel.LinkedFeeRec.RelatedTo = $scope.LinkedFeeModel.CurrentSection;
                    if (index != undefined) {
                        $scope.LinkedFeeModel.LinkedFeeRec = angular.copy($scope.LinkedFeeModel.LinkedFeeList[index]);
                    }
                    $scope.LinkedFeeModel.getFeeList();

                }

                $scope.LinkedFeeModel.disableLinkFeeButton = function () {
                    if ($scope.LinkedFeeModel.LinkedFeeRec != undefined && $scope.LinkedFeeModel.LinkedFeeRec.FeeId != undefined && $scope.LinkedFeeModel.LinkedFeeRec.FeeId != null &&
                        $scope.LinkedFeeModel.LinkedFeeRec.FeeId != '') {
                        return false;
                    }
                    return true;
                }
                $scope.LinkedFeeModel.openDeleteLinkFeePopup = function (index) {
                    $scope.LinkedFeeModel.LinkedFeeRec = angular.copy($scope.LinkedFeeModel.LinkedFeeList[index]);
                }

                $scope.LinkedFeeModel.hidePopup = function (element) {
                    angular.element(element).modal('hide');
                }
                $scope.LinkedFeeModel.showRelatedLinkSection = function (sectionName) {
                    if (sectionName == undefined || sectionName == '' || sectionName == 'Overview') {
                        $scope.LinkedFeeModel.CurrentSection = 'Overview';
                        $scope.LinkedFeeModel.getOverViewDetails();
                    } else {
                        $scope.LinkedFeeModel.CurrentSection = sectionName;
                        $scope.LinkedFeeModel.getLinkedFee();
                    }
                }
                $scope.LinkedFeeModel.saveLinkedFee = function () {
                    if ($scope.LinkedFeeModel.LinkedFeeRec != undefined) {
                        if ($scope.LinkedFeeModel.LinkedFeeRec.Price != undefined) {
                            $scope.LinkedFeeModel.LinkedFeeRec.Price = parseFloat($scope.LinkedFeeModel.LinkedFeeRec.Price);
                        }
                        LinkedFeeServices.saveLinkedFee(angular.toJson($scope.LinkedFeeModel.LinkedFeeRec)).then(function (feeList) {
                            Notification.success($translate.instant('Generic_Saved'));
                            $scope.LinkedFeeModel.LinkedFeeList = feeList;
                            $scope.LinkedFeeModel.hidePopup('#CreateLinkFee');
                            $scope.LinkedFeeModel.LinkedFeeRec = {};
                        }, function (errorSearchResult) {
                            Notification.error(errorSearchResult);
                        });
                    }
                }
                $scope.LinkedFeeModel.changeSeletedEnvFee = function (event) {
                    var keyCode = event.which ? event.which : event.keyCode;
                    if (keyCode === 40) {
                        if (($scope.LinkedFeeModel.FilteredEnvFeeList.length - 1) > $scope.LinkedFeeModel.currentSelectedEnvFeeIndex) {
                            $scope.LinkedFeeModel.currentSelectedEnvFeeIndex++;
                            angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.LinkedFeeModel.currentSelectedEnvFeeIndex)[0].offsetTop - 100;
                        }
                    } else if (keyCode === 38) {
                        if ($scope.LinkedFeeModel.currentSelectedEnvFeeIndex > 0) {
                            $scope.LinkedFeeModel.currentSelectedEnvFeeIndex--;
                            angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.LinkedFeeModel.currentSelectedEnvFeeIndex)[0].offsetTop - 100;
                        }
                    } else if (keyCode === 13) {
                        $scope.LinkedFeeModel.selectFee($scope.LinkedFeeModel.FilteredEnvFeeList[$scope.LinkedFeeModel.currentSelectedEnvFeeIndex]);
                        $scope.LinkedFeeModel.currentSelectedEnvFeeIndex = -1;
                        $scope.LinkedFeeModel.closeAutocomplete('feeDesc');
                    }
                }
                $scope.LinkedFeeModel.closeAutocomplete = function (eleId) {
                    angular.element('#' + eleId).focus();
                }

                $scope.LinkedFeeModel.deleteLinkedFee = function () {
                    if ($scope.LinkedFeeModel.CurrentSection != undefined) {
                        LinkedFeeServices.deleteLinkedFee($scope.LinkedFeeModel.LinkedFeeRec.Id, $scope.LinkedFeeModel.LinkedFeeRec.RelatedTo).then(function (feeList) {

                            $scope.LinkedFeeModel.LinkedFeeList = feeList;
                        }, function (errorSearchResult) {
                            Notification.error(errorSearchResult);
                        });
                        $scope.LinkedFeeModel.LinkedFeeRec = {};

                    }
                }
                $scope.LinkedFeeModel.getLinkedFee = function () {
                    if ($scope.LinkedFeeModel.CurrentSection != undefined) {
                        LinkedFeeServices.getLinkedFeeList($scope.LinkedFeeModel.CurrentSection).then(function (feeList) {
                            $scope.LinkedFeeModel.LinkedFeeList = feeList;
                        }, function (errorSearchResult) {
                            Notification.error(errorSearchResult);
                        });
                        $scope.LinkedFeeModel.LinkedFeeRec = {};
                    }
                }
                $scope.LinkedFeeModel.getOverViewDetails = function () {
                    LinkedFeeServices.getOverViewDetails().then(function (sourceList) {
                        $scope.LinkedFeeModel.LinkedFeeOverviewWrapperList = sourceList;
                    }, function (errorSearchResult) {
                        Notification.error(errorSearchResult);
                    });
                }
                $scope.LinkedFeeModel.getOverViewDetails();
            }
        ])
    });