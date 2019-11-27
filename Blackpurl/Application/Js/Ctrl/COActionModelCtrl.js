define(['Routing_AppJs_PK', 'COActionModelServices', 'dirNumberInput'], function(Routing_AppJs_PK, COActionModelServices, dirNumberInput) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('COActionModelCtrl', ['$scope', '$rootScope', '$state', '$stateParams', 'StatusOverrideService',
        function($scope, $rootScope, $state, $stateParams, StatusOverrideService) {
            var Notification = injector.get("Notification");
            $scope.COActionModal = {};
            $scope.closeCOActionPopup = function() {
                angular.element('#coaction').modal('hide');
            }
            $scope.closeCOActionPopup1 = function() {
                $scope.closeCOActionPopup();
                hideModelWindow();
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }
            $scope.$on('OverridenStatus', function(event, appLog) {
                $scope.COActionModal.setData(appLog);
            });
            $scope.COActionModal.openPopup = function() {
                setTimeout(function() {
                    angular.element('#coaction').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                }, 1000)
            }
            $scope.COActionModal.closePopup = function() {
                angular.element('#coaction').modal('hide');
            }
            $scope.COActionModal.setData = function(appLog) {
                $scope.COActionModal.appLog = {};
                $scope.COActionModal.appLog.Label = appLog.label;
                $scope.COActionModal.appLog.newStatus = appLog.newStatus;
                $scope.COActionModal.appLog.oldStatus = appLog.oldStatus;
                $scope.COActionModal.appLog.notes = '';
                $scope.COActionModal.appLog.SOHeaderId = appLog.soHeaderId;
                $scope.COActionModal.type = appLog.type;
                $scope.COActionModal.appLog.soHeaderIndex = appLog.soHeaderIndex; 
                $scope.COActionModal.ExtendedDateFormat = $Global.ExtendedDateFormat;
                $scope.COActionModal.appLog.CurrentDate = new Date();
                if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                    $scope.$digest();
                }
                $scope.COActionModal.openPopup();
            }
            $scope.COActionModal.insertLogRecord = function() {
                StatusOverrideService.insertLogRecord(JSON.stringify($scope.COActionModal.appLog), $scope.COActionModal.type).then(function(successfulSearchResult) {
                    if (successfulSearchResult.indexOf($Label.SetAsCompleteErrorMessage) > -1) {
                        Notification.error($Label.SetAsCompleteErrorMessage);
                        $scope.COActionModal.closePopup();
                        loadState($state, $rootScope.$previousState.name, {
                            Id: $rootScope.$previousStateParams.Id
                        });
                    } else if (successfulSearchResult.indexOf($Label.SignedOutErrorMessage) > -1) {
                        Notification.error($Label.SignedOutErrorMessage);
                        $scope.COActionModal.closePopup();
                        loadState($state, $rootScope.$previousState.name, {
                            Id: $rootScope.$previousStateParams.Id
                        });
                    } else {
                        $scope.COActionModal.closePopup();
                        hideModelWindow();
                        $scope.$emit('Override_Status', {
                            SOHeaderId: $scope.COActionModal.appLog.SOHeaderId,
                            soHeaderIndex: $scope.COActionModal.appLog.soHeaderIndex
                        }); 
                        loadState($state, $rootScope.$previousState.name, {
                            Id: $rootScope.$previousStateParams.Id
                        });
                    }
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                    $scope.COActionModal.closePopup();
                });
            }
            $scope.CurrentDate = new Date();
            $scope.COActionModal.OverridenStatusEvent = function(args) {
                $scope.COActionModal.setData(args.appLog);
            }
            $scope.COActionModal.openCOActionModelPopup = function() {
                $scope.COActionModal.OverridenStatusEvent($stateParams.COActionModelParams);
            }
            $scope.COActionModal.openCOActionModelPopup();
        }
    ])
});