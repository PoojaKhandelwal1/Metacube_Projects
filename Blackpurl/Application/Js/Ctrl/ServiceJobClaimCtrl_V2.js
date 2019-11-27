define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('ServiceJobClaimCtrl_V2', ['$scope', '$rootScope', '$state', '$stateParams', 'SOClaimService', 'SOHeaderService', function($scope, $rootScope, $state, $stateParams, SOClaimService, SOHeaderService) {
        var Notification = injector.get("Notification");
        $scope.M_SOClaim = $scope.M_SOClaim || {};
        $scope.F_SOClaim = $scope.F_SOClaim || {};
        $scope.M_SOClaim.isInformationReviewed = false;
        $scope.M_SOClaim.StatusUniqueKey = 'Claim_Submission';
        $scope.M_SOClaim.isSubmitSOClaimClicked = false;
        var success = function() {
            var self = this;
            this.arguments = arguments[0];
            this.calleeMethodName = arguments[0].calleeMethodName,
            this.callback = arguments[0].callback,
            this.handler = function(successResult) {
                switch (self.calleeMethodName) {
                    case 'getServiceJobTotals':
                        handleGetServiceJobTotalsResponse(successResult);
                        break;
                    case 'submitClaimRecords':
                        handleSubmitClaimRecordsResponse(successResult);
                        break;
                    case 'getSOHeaderDetails':
                        handleGetSOHeaderDetailsResponse(successResult);
                        break;
                    default:
                        break;
                }
                if (typeof self.callback === 'function') {
                    self.callback();
                }
            }

            function handleGetServiceJobTotalsResponse(serviceJobDetails) {
                $scope.M_SOClaim.isLoading = false;
                $scope.M_SOClaim.serviceJobDetails = serviceJobDetails;
            }

            function handleSubmitClaimRecordsResponse(serviceJobDetails) {
                var successJson = {
                    'calleeMethodName': 'getSOHeaderDetails'
                };
                SOHeaderService.getSOHeaderDetails($scope.M_SOClaim.WizardSOHeaderId, null).then(new success(successJson).handler, new error().handler);
            }

            function handleGetSOHeaderDetailsResponse(serviceOrderHeader) {
                $scope.M_CO.SOHeaderList[$stateParams.ServiceJobClaimParams.soHeaderIndex] = serviceOrderHeader[0];
                if (!isBlankValue($scope.M_CO.SOHeaderList[$stateParams.ServiceJobClaimParams.soHeaderIndex].SOInfo.UnitId)) {
                	if($stateParams.ServiceJobClaimParams.coType != 'Internal Service') {
                		var index = _.findIndex($scope.M_CO.COUList, {
                            'Id': $scope.M_CO.SOHeaderList[$stateParams.ServiceJobClaimParams.soHeaderIndex].SOInfo.UnitId
                        });
                        $scope.M_CO.SOHeaderList[$stateParams.ServiceJobClaimParams.soHeaderIndex].SOInfo.UnitName = $scope.M_CO.COUList[index].FormattedName;
                	}
                }
                $scope.F_SOClaim.closeSOClaimModal();
            }
        }
        var error = function(errorMessage) {
            this.handler = function(error) {
                $scope.M_SOClaim.isLoading = false;
                if (!errorMessage) {
                    console.log(error);
                } else {
                    console.log(errorMessage);
                }
            }
        }
        angular.element(document).on("click", "#ServiceJobClaimPopup .modal-backdrop", function() {
            $scope.F_SOClaim.closeSOClaimModal();
        });
        $scope.F_SOClaim.closeSOClaimModal = function() {
            angular.element('#ServiceJobClaimPopup').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.F_SOClaim.submitSOClaim = function() {
            $scope.M_SOClaim.wizardJson = {};
            $scope.M_SOClaim.wizardJson.Approval_Method = [];
            $scope.M_SOClaim.wizardJson.Approval_Method.push({
                ApprovalType: 'Submit_Claim'
            });
            var successJson = {
                'calleeMethodName': 'submitClaimRecords'
            };
            SOClaimService.submitClaimRecords($scope.M_SOClaim.WizardSOHeaderId).then(new success(successJson).handler, new error().handler);
        }

        function getServiceJobTotals(soHeaderId) {
            $scope.M_SOClaim.isLoading = true;
            var successJson = {
                'calleeMethodName': 'getServiceJobTotals'
            };
            SOClaimService.getServiceJobTotals(soHeaderId).then(new success(successJson).handler, new error().handler);
        }

        function openSOClaimModal() {
            setTimeout(function() {
                angular.element('#ServiceJobClaimPopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
            if ($stateParams.ServiceJobClaimParams.soHeaderIndex != undefined) {
                $scope.M_SOClaim.WizardSOHeaderIndex = $stateParams.ServiceJobClaimParams.soHeaderIndex;
                $scope.M_SOClaim.WizardSOHeaderId = $scope.M_CO.SOHeaderList[$scope.M_SOClaim.WizardSOHeaderIndex].SOInfo.Id;
                $scope.M_SOClaim.ProviderId = $scope.M_CO.SOHeaderList[$scope.M_SOClaim.WizardSOHeaderIndex].SOInfo.ProviderId;
                $scope.M_SOClaim.WizardSOHeader = angular.copy($scope.M_CO.SOHeaderList[$scope.M_SOClaim.WizardSOHeaderIndex]);
                $scope.M_SOClaim.WizardSOHeader.CustomerName = $scope.M_CO.CustomerCardInfo.CustomerName;
                getServiceJobTotals($scope.M_SOClaim.WizardSOHeaderId);
            }
        }
        openSOClaimModal();
    }])
});