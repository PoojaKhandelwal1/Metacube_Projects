define(['Routing_AppJs_PK', 'UserSettingsServices'], function(Routing_AppJs_PK, UserSettingsServices) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('GroupSummaryCtrl', ['$scope', '$stateParams', '$state', 'UserSettingService','$translate', function($scope, $stateParams, $state, UserSettingService,$translate) {
        var Notification = injector1.get("Notification");
        $scope.GroupSummaryModel = {};
        $scope.GroupSummaryModel.UserFirstName = $Global.UserFirstName;
        $scope.GroupSummaryModel.UserLastName = $Global.UserLastName;
        $scope.currentUserGroupName = $Global.userGroupName;
        $scope.currentUserGroupColor = $Global.userGroupColor;
        $scope.GroupSummaryModel.SortJson = {
            SortBy: 'CreatedDate',
            Reverse: false
        };
        $scope.GroupSummaryModel.UserGroupColorsList = {
            '1': {
                ColorCode: 'rgba(54,199,155,1)',
                IsSelected: false,
                HoverState: 'rgba(54,199,155,0.5)',
                IsCircleHover: false
            },
            '2': {
                ColorCode: 'rgba(176,123,224,1)',
                IsSelected: false,
                HoverState: 'rgba(176,123,224,0.5)',
                IsCircleHover: false
            },
            '3': {
                ColorCode: 'rgba(255,100,88,1)',
                IsSelected: false,
                HoverState: 'rgba(255,100,88,0.5)',
                IsCircleHover: false
            },
            '4': {
                ColorCode: 'rgba(252,132,74,1)',
                IsSelected: true,
                HoverState: 'rgba(252,132,74,0.5)',
                IsCircleHover: false
            },
            '5': {
                ColorCode: 'rgba(245,166,35,1)',
                IsSelected: false,
                HoverState: 'rgba(245,166,35,0.5)',
                IsCircleHover: false
            },
            '6': {
                ColorCode: 'rgba(159,205,109,1)',
                IsSelected: false,
                HoverState: 'rgba(159,205,109,0.5)',
                IsCircleHover: false
            },
            '7': {
                ColorCode: 'rgba(0,102,139,1)',
                IsSelected: false,
                HoverState: 'rgba(0,102,139,0.5)',
                IsCircleHover: false
            },
            '8': {
                ColorCode: 'rgba(0,0,0,1)',
                IsSelected: false,
                HoverState: 'rgba(0,0,0,0.5)',
                IsCircleHover: false
            }
        };
        $scope.GroupSummaryModel.UserGroup = {};
        $scope.GroupSummaryModel.GroupNameInputCharacterLimit = 16;
        $scope.GroupSummaryModel.SelectUserGroupColor = function(index) {
            angular.forEach($scope.GroupSummaryModel.UserGroupColorsList, function(value, key) {
                if (parseInt(key) != (index + 1)) {
                    $scope.GroupSummaryModel.UserGroupColorsList[key].IsSelected = false;
                } else {
                    $scope.GroupSummaryModel.UserGroupColorsList[key].IsSelected = true;
                    $scope.GroupSummaryModel.UserGroup.ColorCode = $scope.GroupSummaryModel.UserGroupColorsList[key].ColorCode;
                }
            });
        }
        $scope.GroupSummaryModel.MoveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
        $scope.GroupSummaryModel.deleteUserGroup = function(userGroupId, NoOfUser) {
            if (NoOfUser > 0) {
                Notification.error($translate.instant('Delete_group_error_message'));
                return;
            }
            UserSettingService.deleteUserGroup(userGroupId).then(function(successresult) {
                $scope.GroupSummaryModel.userGroupList = successresult;
                angular.element('[role ="tooltip"]').hide();
                setTimeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: 'body'
                    });
                }, 500);
                Notification.success($translate.instant('Generic_Deleted'));
            }, function(errorSearchResult) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.GroupSummaryModel.loadUserGroupList = function() {
            $scope.GroupSummaryModel.scrollTop();
            UserSettingService.loadUserGroupList().then(function(successresult) {
                $scope.GroupSummaryModel.userGroupList = successresult;
                $scope.GroupSummaryModel.formatDate();
                setTimeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: 'body'
                    });
                }, 500);
            }, function(errorSearchResult) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.GroupSummaryModel.scrollTop = function() {
            angular.element('html, body').stop().animate({
                scrollTop: 0
            }, 500);
        }
        $scope.GroupSummaryModel.disableUserCreateButton = false;
        $scope.GroupSummaryModel.CreateUserGroup = function() {
            if ($scope.GroupSummaryModel.disableUserCreateButton) {
                return;
            }
            for(var index = 0; index< $scope.GroupSummaryModel.userGroupList.length;index++){
                var groupNameFromList = $scope.GroupSummaryModel.userGroupList[index].UserGroupName.trim().toLowerCase();
                var groupNameFromModel = $scope.GroupSummaryModel.UserGroup.UserGroupName.trim().toLowerCase();
                if(groupNameFromList == groupNameFromModel){
                    Notification.error($translate.instant('Duplicate_group_already_exist'));
                     return;  
                } 
            }
            $scope.GroupSummaryModel.disableUserCreateButton = true;
            var userGroupJson = angular.toJson($scope.GroupSummaryModel.UserGroup);
            UserSettingService.createUserGroup(userGroupJson).then(function(successresult) {
                $scope.GroupSummaryModel.hideCreateUserGroupPupup();
                $scope.GroupSummaryModel.disableUserCreateButton = false;
                angular.element("body").removeClass('modal-open');
                angular.element("body").css("padding", "0px");
                setTimeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: 'body'
                    });
                }, 200);
                $scope.GroupSummaryModel.MoveToState('EditGroupPermissions', {
                    Id: successresult
                });
            }, function(errorSearchResult) {
                $scope.GroupSummaryModel.disableUserCreateButton = false;
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.GroupSummaryModel.formatDate = function() {
            for (var i = 0; i < $scope.GroupSummaryModel.userGroupList.length; i++) {
                $scope.GroupSummaryModel.userGroupList[i].CreatedDate = new
                Date($scope.GroupSummaryModel.userGroupList[i].CreatedDate);
                $scope.GroupSummaryModel.userGroupList[i].LastModifiedDate = new Date($scope.GroupSummaryModel.userGroupList[i].LastModifiedDate);
            }
        }
        $scope.GroupSummaryModel.CreateUserGroupCopy = function(userGroupRec) {
            $scope.GroupSummaryModel.UserGroup.CopyGroupId = userGroupRec.UserGroupId;
            var CopyUserName = 'Copy of ' + userGroupRec.UserGroupName;
            CopyUserName = CopyUserName.substring(0, $scope.GroupSummaryModel.GroupNameInputCharacterLimit);
            $scope.GroupSummaryModel.UserGroup.UserGroupName = CopyUserName;
            $scope.GroupSummaryModel.UserGroup.ColorCode = userGroupRec.ColorCode;
            angular.forEach($scope.GroupSummaryModel.UserGroupColorsList, function(value, key) {
                $scope.GroupSummaryModel.UserGroupColorsList[key].IsSelected = false;
                if ($scope.GroupSummaryModel.UserGroupColorsList[key].ColorCode == userGroupRec.ColorCode) {
                    $scope.GroupSummaryModel.UserGroupColorsList[key].IsSelected = true;
                }
            });
            setTimeout(function() {
                angular.element('#GroupNameInput').focus();
            }, 500);
        }
        $scope.GroupSummaryModel.ChangeOrder = function() {
            $scope.GroupSummaryModel.SortJson.Reverse = !$scope.GroupSummaryModel.SortJson.Reverse;
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'top',
                    container: 'body'
                });
            }, 500);
        }
        $scope.GroupSummaryModel.openCreateUserGroupPupup = function() {
            $scope.GroupSummaryModel.UserGroup = {};
            $scope.GroupSummaryModel.setUserGroupData();
            setTimeout(function() {
                angular.element('#GroupNameInput').focus();
            }, 500);
        }
        $scope.GroupSummaryModel.hideCreateUserGroupPupup = function() {
            angular.element('#CreateGroup').modal('hide');
        }
        $scope.GroupSummaryModel.CreateGroupKeyPressed = function(event) {
            var groupNameLength = 0;
            if ($scope.GroupSummaryModel.UserGroup.UserGroupName != undefined && $scope.GroupSummaryModel.UserGroup.UserGroupName != null && $scope.GroupSummaryModel.UserGroup.UserGroupName != '') {
                groupNameLength = $scope.GroupSummaryModel.UserGroup.UserGroupName.length;
            }
            if (groupNameLength >= $scope.GroupSummaryModel.GroupNameInputCharacterLimit) {
                event.preventDefault();
                return;
            }
        }
        $scope.GroupSummaryModel.isGroupNameHasValue = function() {
            var groupName = '';
            if ($scope.GroupSummaryModel.UserGroup.UserGroupName != undefined && $scope.GroupSummaryModel.UserGroup.UserGroupName != null && $scope.GroupSummaryModel.UserGroup.UserGroupName != '') {
                groupName = $scope.GroupSummaryModel.UserGroup.UserGroupName;
            }
            return (groupName.trim().length == 0);
        }
        $scope.GroupSummaryModel.setUserGroupData = function() {
            $scope.GroupSummaryModel.UserGroup.UserGroupName = '';
            angular.forEach($scope.GroupSummaryModel.UserGroupColorsList, function(value, key) {
                $scope.GroupSummaryModel.UserGroupColorsList[key].IsSelected = false;
            });
            $scope.GroupSummaryModel.UserGroupColorsList[4].IsSelected = true;
            $scope.GroupSummaryModel.UserGroup.ColorCode = $scope.GroupSummaryModel.UserGroupColorsList[4].ColorCode;
        }
        $scope.GroupSummaryModel.loadUserGroupList();
    }])
});