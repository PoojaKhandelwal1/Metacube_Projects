define(['Routing_AppJs_PK', 'UserSettingsServices', 'underscore_min'], function(Routing_AppJs_PK, UserSettingsServices, underscore_min) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('EditGroupPermissionsCtrl', ['$scope', '$rootScope', '$stateParams', '$state', 'UserSettingService','$translate',
        function($scope, $rootScope, $stateParams, $state, UserSettingService,$translate) {
            var Notification = injector1.get("Notification");
            $scope.EditGroupPermissionsModel = {};
            $scope.EditGroupPermissionsModel.userGroupId = $stateParams.Id;
            $scope.EditGroupPermissionsModel.UserFirstName = $Global.UserFirstName;
            $scope.EditGroupPermissionsModel.UserLastName = $Global.UserLastName;
            $scope.currentUserGroupName = $Global.userGroupName;
            $scope.currentUserGroupId = $Global.userGroupId;
            $scope.currentUserGroupColor = $Global.userGroupColor;
            $scope.currentUserId = $Global.currentUserId;
            $scope.EditGroupPermissionsModel.isUnSavedChanges = false;
            $scope.EditGroupPermissionsModel.GroupNameInputCharacterLimit = 16;
            $scope.EditGroupPermissionsModel.ChangedColorCode = '';
            $scope.EditGroupPermissionsModel.UserGroupColorsList = {
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
            $scope.EditGroupPermissionsModel.MoveToState = function(stateName, attr) {
                if (attr != undefined && attr != null && attr != '') {
                    loadState($state, stateName, attr);
                } else {
                    loadState($state, stateName);
                }
            }
            $scope.EditGroupPermissionsModel.currentView = 'Permissions';
            $scope.EditGroupPermissionsModel.changeView = function(view) {
                $scope.EditGroupPermissionsModel.currentView = view;
            }
            $scope.EditGroupPermissionsModel.scrollPermissionTop = function() {
                var scrolly = window.scrollY;
                angular.element('html, body').stop().animate({
                    scrollTop: scrolly + 60
                }, 500);
            }
            $scope.EditGroupPermissionsModel.openAssignUserPopup = function() {
                $scope.EditGroupPermissionsModel.usersForCurrentGroup = [];
                $scope.EditGroupPermissionsModel.usersearchObj = {};
                $scope.EditGroupPermissionsModel.usersearchObj.Name = '';
                $scope.EditGroupPermissionsModel.getUsersList();
            }
            $scope.EditGroupPermissionsModel.scrollTop = function() {
                angular.element('html, body').stop().animate({
                    scrollTop: 0
                }, 500);
            }
            $scope.EditGroupPermissionsModel.assignMembersToUserGroup = function() {
                var idListOfSelectedMembers = [];
                angular.forEach($scope.EditGroupPermissionsModel.usersForCurrentGroup, function(selectedUser) {
                    idListOfSelectedMembers.push(selectedUser.UserId);
                });
                UserSettingService.assignMembersToUserGroup(JSON.stringify(idListOfSelectedMembers), $scope.EditGroupPermissionsModel.userGroupId).then(function(membersList) {
                    $scope.EditGroupPermissionsModel.userGroupMembersList = membersList;
                    var currentUserIndexInMemberList = _.findIndex($scope.EditGroupPermissionsModel.userGroupMembersList, {
                        UserId: $scope.currentUserId
                    });
                    if (currentUserIndexInMemberList != -1) {
                        $scope.currentUserGroupName = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName;
                        $Global.userGroupName = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName;
                        $scope.currentUserGroupId = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupId;
                        $Global.userGroupId = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupId;
                        $scope.currentUserGroupColor = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.ColorCode;
                        $Global.userGroupColor = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.ColorCode;
                        UserSettingService.getUserPermissions($scope.currentUserId).then(function(UserPermissions) {
                            $Global.Permission = UserPermissions;
                            $rootScope.GroupOnlyPermissions = $Global.Permission.GroupOnlyPermissions;
                            $rootScope.setBpGlobalHeaderMenuItems();
                        }, function(errorSearchResult) {
                            Notification.error($translate.instant('GENERIC_ERROR'));
                        });
                    }
                    angular.element('#assignUsersModal').hide();
                    angular.element("body").removeClass('modal-open');
                    angular.element("body").css("padding", "0px");
                    $scope.EditGroupPermissionsModel.scrollTop();
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }
            $scope.EditGroupPermissionsModel.getMembersOfUserGroup = function() {
                UserSettingService.getMembersOfUserGroup($scope.EditGroupPermissionsModel.userGroupId).then(function(membersList) {
                    $scope.EditGroupPermissionsModel.userGroupMembersList = membersList;
                    setTimeout(function() {
                        angular.element('[data-toggle="tooltip"]').tooltip({
                            placement: 'top'
                        });
                    }, 500);
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }
            $scope.EditGroupPermissionsModel.getUsersList = function() {
                var searchQueryJson = {
                    "ObjectLabel": 'User',
                    "SearchText": '',
                    "SearchFieldName": 'Name',
                    "FilterValues": [{
                        'Field': 'IsActive',
                        'Value': true,
                        'Operator': '='
                    }]
                }
                UserSettingService.getSearchResults(JSON.stringify(searchQueryJson)).then(function(usersList) {
                    $scope.EditGroupPermissionsModel.totalUsersList = usersList;
                    $scope.EditGroupPermissionsModel.totalUsersList = _.reject($scope.EditGroupPermissionsModel.totalUsersList, function(value) {
                        var j = _.findIndex($scope.EditGroupPermissionsModel.userGroupMembersList, {
                            UserId: value.UserId
                        });
                        if (j != -1) {
                            return true;
                        }
                    });
                }, function(errorSearchResult) {});
            }
            $scope.EditGroupPermissionsModel.selectUser = function(userObj) {
                var isSystemSettingEnabledForCurrentUser = $scope.EditGroupPermissionsModel.userGroupRecord.userGroupPermissions[0]['General Permissions'][0]['System Settings']['Primary'];
                if (userObj.UserId === $scope.currentUserId && !isSystemSettingEnabledForCurrentUser) {
                    Notification.error($translate.instant('Disabled_group_assignment_error'));
                    return;
                }
                $scope.EditGroupPermissionsModel.usersForCurrentGroup.push(userObj);
                var j = _.findIndex($scope.EditGroupPermissionsModel.totalUsersList, {
                    UserId: userObj.UserId
                });
                if (j != -1) {
                    $scope.EditGroupPermissionsModel.totalUsersList.splice(j, 1);
                }
                $scope.EditGroupPermissionsModel.usersearchObj.Name = '';
            }
            $scope.EditGroupPermissionsModel.removeUserFromSelectedUserList = function(userObj, index) {
                $scope.EditGroupPermissionsModel.usersForCurrentGroup.splice(index, 1);
                $scope.EditGroupPermissionsModel.totalUsersList.push(userObj);
            }
            $scope.EditGroupPermissionsModel.setFocusOnInput = function() {
                $scope.EditGroupPermissionsModel.isFocused = true;
            }
            $scope.EditGroupPermissionsModel.setBlurOnInput = function() {
                $scope.EditGroupPermissionsModel.isFocused = false;
            }
            $scope.EditGroupPermissionsModel.userGroupRecord = {};
            $scope.EditGroupPermissionsModel.userGroupRecord.userGroupPermissions = [];
            $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails = [];
            $scope.EditGroupPermissionsModel.loadUserGroupDetails = function() {
                $scope.EditGroupPermissionsModel.scrollTop();
                UserSettingService.loadUserGroupDetails($scope.EditGroupPermissionsModel.userGroupId).then(function(successresult) {
                    $scope.EditGroupPermissionsModel.userGroupRecord.userGroupPermissions = [];
                    $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails = [];
                    var userGroupPermissionNames = Object.keys(successresult.UserGroupPermissions);
                    angular.forEach(userGroupPermissionNames, function(permissionName) {
                        var userGroupPermissionRec = {};
                        var userGroupPermissionCategoryNames = Object.keys(successresult.UserGroupPermissions[permissionName]);
                        if (permissionName === 'Transaction Permissions') {
                            userGroupPermissionRec[permissionName] = {};
                            userGroupPermissionRec[permissionName]['Sales'] = [];
                            userGroupPermissionRec[permissionName]['Ordering'] = [];
                            var count = 0;
                            for (var i = 0; i < 6; i++) {
                                var userGroupPermissionCategoryRec = {};
                                userGroupPermissionCategoryRec[userGroupPermissionCategoryNames[i]] = successresult.UserGroupPermissions[permissionName][userGroupPermissionCategoryNames[i]];
                                userGroupPermissionRec[permissionName]['Sales'].push(userGroupPermissionCategoryRec);
                            }
                            var totalTransactionPermissions = successresult.UserGroupPermissions[permissionName].length;
                            for (var j = i; j < 10; j++) {
                                var userGroupPermissionCategoryRec = {};
                                userGroupPermissionCategoryRec[userGroupPermissionCategoryNames[j]] = successresult.UserGroupPermissions[permissionName][userGroupPermissionCategoryNames[j]];
                                userGroupPermissionRec[permissionName]['Ordering'].push(userGroupPermissionCategoryRec);
                            }
                        } else {
                            userGroupPermissionRec[permissionName] = [];
                            angular.forEach(userGroupPermissionCategoryNames, function(permissionCategoryName) {
                                var userGroupPermissionCategoryRec = {};
                                userGroupPermissionCategoryRec[permissionCategoryName] = successresult.UserGroupPermissions[permissionName][permissionCategoryName];
                                userGroupPermissionRec[permissionName].push(userGroupPermissionCategoryRec);
                            });
                        }
                        $scope.EditGroupPermissionsModel.userGroupRecord.userGroupPermissions.push(userGroupPermissionRec);
                    });
                    $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails = successresult.UserPermissionGroupDetails;
                    angular.forEach($scope.EditGroupPermissionsModel.UserGroupColorsList, function(value, key) {
                        $scope.EditGroupPermissionsModel.UserGroupColorsList[key].IsSelected = false;
                        if ($scope.EditGroupPermissionsModel.UserGroupColorsList[key].ColorCode == $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.ColorCode) {
                            $scope.EditGroupPermissionsModel.UserGroupColorsList[key].IsSelected = true;
                        }
                    });
                    $scope.EditGroupPermissionsModel.ChangedColorCode = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.ColorCode;
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }
            $scope.EditGroupPermissionsModel.loadUserGroupList = function() {
                UserSettingService.loadUserGroupList().then(function(successresult) {
                    $scope.EditGroupPermissionsModel.userGroupList = successresult;
                },function(errorSearchResult) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }
            $scope.EditGroupPermissionsModel.isSaveChangesButtonDisabled = false;
            $scope.EditGroupPermissionsModel.updateUserGroupRecord = function() {
                if ($scope.EditGroupPermissionsModel.isSaveChangesButtonDisabled) {
                    return;
                }
                for(var index = 0; index<  $scope.EditGroupPermissionsModel.userGroupList.length;index++){
                    var groupNameFromList =  $scope.EditGroupPermissionsModel.userGroupList[index].UserGroupName.trim().toLowerCase();
                    var groupNameFromModel = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName.trim().toLowerCase();
                    if((groupNameFromList == groupNameFromModel) && ($scope.EditGroupPermissionsModel.userGroupList[index].UserGroupId != $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupId)){
                        Notification.error($translate.instant('Duplicate_group_already_exist'));
                         return;  
                    } 
                }
                $scope.EditGroupPermissionsModel.isSaveChangesButtonDisabled = true;
                var userGroupPermissionCategories = [];
                angular.forEach($scope.EditGroupPermissionsModel.userGroupRecord.userGroupPermissions, function(permissionRecord) {
                    var permissionName = Object.keys(permissionRecord)[0];
                    if (permissionName === 'Transaction Permissions') {
                        angular.forEach(permissionRecord[permissionName]['Sales'], function(categoryRecord) {
                            userGroupPermissionCategories.push(categoryRecord);
                        });
                        angular.forEach(permissionRecord[permissionName]['Ordering'], function(categoryRecord) {
                            userGroupPermissionCategories.push(categoryRecord);
                        });
                    } else {
                        angular.forEach(permissionRecord[permissionName], function(categoryRecord) {
                            userGroupPermissionCategories.push(categoryRecord);
                        });
                    }
                });
                $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.ColorCode = $scope.EditGroupPermissionsModel.ChangedColorCode;
                var userGroupRecord = {};
                userGroupRecord.userPermissionGroupDetails = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails;
                userGroupRecord.userGroupPermissions = userGroupPermissionCategories;
                var userGroupJson = angular.toJson(userGroupRecord);
                UserSettingService.updateUserGroup(userGroupJson).then(function(successresult) {
                    if (successresult != 'Sucess') {
                        if (successresult == 'None') {
                            userGroupRecord.userGroupPermissions[0]['System Settings'].Primary = false;
                        } else if (successresult == 'Primary') {
                            userGroupRecord.userGroupPermissions[0]['System Settings'].Primary = true;
                        }
                    }
                    $scope.EditGroupPermissionsModel.isSaveChangesButtonDisabled = false;
                    $scope.EditGroupPermissionsModel.isUnSavedChanges = false;
                    if ($scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupId === $scope.currentUserGroupId) {
                        $scope.currentUserGroupName = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName;
                        $Global.userGroupName = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName;
                        $scope.currentUserGroupColor = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.ColorCode;
                        $Global.userGroupColor = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.ColorCode;
                        UserSettingService.getUserPermissions($scope.currentUserId).then(function(UserPermissions) {
                            $Global.Permission = UserPermissions;
                            $rootScope.GroupOnlyPermissions = $Global.Permission.GroupOnlyPermissions;
                            $rootScope.setBpGlobalHeaderMenuItems();
                        }, function(errorSearchResult) {
                            Notification.error($translate.instant('GENERIC_ERROR'));
                        });
                    }
                    Notification.success($translate.instant('Generic_Saved'));
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                    $scope.EditGroupPermissionsModel.isSaveChangesButtonDisabled = false;
                    $scope.EditGroupPermissionsModel.isUnSavedChanges = true;
                });
            }
            $scope.EditGroupPermissionsModel.SelectUserGroupColor = function(index) {
                angular.forEach($scope.EditGroupPermissionsModel.UserGroupColorsList, function(value, key) {
                    if (parseInt(key) != (index + 1)) {
                        $scope.EditGroupPermissionsModel.UserGroupColorsList[key].IsSelected = false;
                    } else {
                        $scope.EditGroupPermissionsModel.UserGroupColorsList[key].IsSelected = true;
                        $scope.EditGroupPermissionsModel.ChangedColorCode = $scope.EditGroupPermissionsModel.UserGroupColorsList[key].ColorCode;
                        if ($scope.EditGroupPermissionsModel.ChangedColorCode != $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.ColorCode) {
                            $scope.EditGroupPermissionsModel.isUnSavedChanges = true;
                        }
                    }
                });
            }
            $scope.EditGroupPermissionsModel.GroupProfileNameKeyPressed = function(event) {
                var groupNameLength = 0;
                if ($scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName != undefined && $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName != null && $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName != '') {
                    groupNameLength = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName.length;
                }
                if (event.keyCode != 8 && groupNameLength >= $scope.EditGroupPermissionsModel.GroupNameInputCharacterLimit) {
                    event.preventDefault();
                    return;
                } else {
                    $scope.EditGroupPermissionsModel.isUnSavedChanges = true;
                }
            }
            $scope.EditGroupPermissionsModel.isGroupNameHasValue = function() {
                var groupName = '';
                if ($scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName != undefined && $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName != null && $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName != '') {
                    groupName = $scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupName;
                }
                return (groupName.trim().length == 0);
            }
            $scope.EditGroupPermissionsModel.disableEditGroupPermissions = function(permissionCategoryName) {
                if ($scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.IsSystemCreated) { //For Admin Group(Created Automatically) disable edit permissions
                    return true;
                } else if ($scope.EditGroupPermissionsModel.userGroupRecord.userPermissionGroupDetails.UserGroupId == $scope.currentUserGroupId && permissionCategoryName === 'System Settings') {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.EditGroupPermissionsModel.loadData = function() {
                $scope.EditGroupPermissionsModel.loadUserGroupDetails();
                $scope.EditGroupPermissionsModel.getMembersOfUserGroup();
                $scope.EditGroupPermissionsModel.loadUserGroupList();
            }
            $scope.EditGroupPermissionsModel.loadData();
        }
    ])
});