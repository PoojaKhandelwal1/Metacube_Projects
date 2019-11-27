define(['Routing_AppJs_PK', 'UserServices'], function(Routing_AppJs_PK, UserServices) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('UserCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$stateParams', '$state', 'UserPageService','$translate', function($scope, $timeout, $q, $rootScope, $stateParams, $state, UserPageService,$translate) {
        var Notification = injector.get("Notification");
        if ($scope.UserModel == undefined) {
            $scope.UserModel = {};
        }
        $scope.UserModel.newTech = {};
        $scope.UserModel.newUser = {};
        $scope.UserModel.LicensedUsers = true;
        $scope.UserModel.ClockingStaff = false;
        $scope.UserModel.enableAddButton = false;
        $scope.UserModel.enableAddUserButton = false;
        $scope.UserModel.newTech.IsTechnician = false;
        $scope.UserModel.isClockingStaffEdit = -1;
        $scope.UserModel.isUserEdit = -1;
        $scope.UserModel.setBGColor = -1;
        $scope.UserModel.setUserBGColor = -1;
        $scope.UserModel.newUser.isTechnician = false;
        $scope.UserModel.UserFirstName = $Global.UserFirstName;
        $scope.UserModel.UserLastName = $Global.UserLastName;
        $scope.currentUserGroupName = $Global.userGroupName;
        $scope.currentUserGroupColor = $Global.userGroupColor;
        $scope.UserModel.isBlur = true;
        $scope.isLoadTechScheduling = $Global.IsLoadTechScheduling;
        var focusedElement;
        $scope.UserModel.validateUserDetails = function() {
            var EmailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
            var IsValidEmail = EmailRegEx.test($scope.UserModel.newUser.email);
            if (!IsValidEmail) {
                return true;
            }
            if ($scope.UserModel.newUser.firstName == null || $scope.UserModel.newUser.firstName == '' || $scope.UserModel.newUser.firstName == undefined) {
                return true;
            }
            if ($scope.UserModel.newUser.lastName == null || $scope.UserModel.newUser.lastName == '' || $scope.UserModel.newUser.lastName == undefined) {
                return true;
            }
            if ($scope.UserModel.allUserList.length >= 5) {
                return true;
            }
            return false;
        }
        $scope.UserModel.loadAllClockingStaff = function() {
            $scope.UserModel.newUser = {};
            $scope.UserModel.LicensedUsers = false;
            $scope.UserModel.ClockingStaff = true;
            $scope.UserModel.newTech.IsTechnician = false;
            $scope.UserModel.isUserEdit = -1;
            UserPageService.getAllClockingStaff().then(function(successResult) {
                $scope.UserModel.ClockingStaffList = successResult;
                angular.element('[role ="tooltip"]').hide();
                setTimeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: 'body'
                    });
                }, 500);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.UserModel.openEditMode = function(index) {
            $scope.UserModel.newTech.FirstName = '';
            $scope.UserModel.newTech.LastName = '';
            $scope.UserModel.newTech.IsTechnician = false;
            $scope.UserModel.isClockingStaffEdit = index;
            $scope.UserModel.setBGColor = index;
            $scope.UserModel.ClockingStaffListCopy = angular.copy($scope.UserModel.ClockingStaffList);
            setTimeout(function() {
                angular.element('#edit-tech-first-name' + index).focus();
            }, 1000);
        }
        $scope.UserModel.saveEditTechStaff = function(index, event) {
            focusedElement = event.relatedTarget;
            if (focusedElement != undefined && focusedElement != '' && focusedElement != null) {
                if (focusedElement.id == ('edit-tech-first-name' + index) || focusedElement.id == ('edit-tech-last-name' + index) || focusedElement.id == ('isTechnicianFlag_' + index)) {
                    $scope.UserModel.isBlur = false;
                }
            }
            if (event.type == "blur" && !$scope.UserModel.isBlur) {
                event.preventDefault();
                $scope.UserModel.isBlur = true;
                return;
            }
            if (event.type == "blur" && $scope.UserModel.isBlur) {
                if ($scope.UserModel.ClockingStaffList[index].FirstName != null && $scope.UserModel.ClockingStaffList[index].FirstName != '' && $scope.UserModel.ClockingStaffList[index].FirstName != undefined) {
                    $scope.UserModel.IsRedBorderActiveForEditTechFirstName = false;
                } else {
                    $scope.UserModel.IsRedBorderActiveForEditTechFirstName = true;
                }
                if ($scope.UserModel.ClockingStaffList[index].LastName != null && $scope.UserModel.ClockingStaffList[index].LastName != '' && $scope.UserModel.ClockingStaffList[index].LastName != undefined) {
                    $scope.UserModel.IsRedBorderActiveForEditTechLastName = false;
                } else {
                    $scope.UserModel.IsRedBorderActiveForEditTechLastName = true;
                }
                if ($scope.UserModel.IsRedBorderActiveForEditTechLastName || $scope.UserModel.IsRedBorderActiveForEditTechFirstName) {
                    if ($scope.UserModel.IsRedBorderActiveForEditTechFirstName) {
                        Notification.error($translate.instant('Invalid_staff_first_name'));
                        if ($scope.UserModel.ClockingStaffListCopy != undefined) {
                            $scope.UserModel.ClockingStaffList[index].FirstName = $scope.UserModel.ClockingStaffListCopy[index].FirstName;
                        }
                        setTimeout(function() {
                            angular.element('#edit-tech-first-name' + index).select();
                        }, 500);
                    }
                    if ($scope.UserModel.IsRedBorderActiveForEditTechLastName) {
                        Notification.error($translate.instant('Invalid_staff_last_name'));
                        if ($scope.UserModel.ClockingStaffListCopy != undefined) {
                            $scope.UserModel.ClockingStaffList[index].LastName = $scope.UserModel.ClockingStaffListCopy[index].LastName;
                        }
                        setTimeout(function() {
                            angular.element('#edit-tech-last-name' + index).select();
                        }, 500);
                    }
                    event.preventDefault();
                    return;
                }
                for (var i = 0; i < $scope.UserModel.ClockingStaffList.length; i++) {
                    if ($scope.UserModel.ClockingStaffListCopy) {
                        if (($scope.UserModel.ClockingStaffList[index].FirstName).toLowerCase() == ($scope.UserModel.ClockingStaffListCopy[i].FirstName).toLowerCase() && ($scope.UserModel.ClockingStaffList[index].LastName).toLowerCase() == ($scope.UserModel.ClockingStaffListCopy[i].LastName).toLowerCase() && i != index) {
                            Notification.error($translate.instant('Duplicate_staff_name'));
                            $scope.UserModel.ClockingStaffList[index].FirstName = $scope.UserModel.ClockingStaffListCopy[index].FirstName;
                            $scope.UserModel.ClockingStaffList[index].LastName = $scope.UserModel.ClockingStaffListCopy[index].LastName;
                            setTimeout(function() {
                                angular.element('#edit-tech-first-name' + index).select();
                            }, 1000);
                            event.preventDefault();
                            return;
                        }
                    }
                }
                UserPageService.editClockingStaff(angular.toJson($scope.UserModel.ClockingStaffList[index])).then(function(successResult) {
                    $scope.UserModel.isClockingStaffEdit = -1;
                    $scope.UserModel.ClockingStaffList[index] = successResult;
                    setTimeout(function() {
                        $scope.UserModel.setBGColor = -1;
                        if (!$scope.$$phase) {
                            $scope.$digest();
                        }
                    }, 1000);
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
            }
        }
        $scope.UserModel.MoveToState = function(stateName, attr) {
            loadState($state, stateName, attr);
        }
        $scope.UserModel.loadAllLicensedUsers = function() {
            $scope.UserModel.newTech = {};
            $scope.UserModel.LicensedUsers = true;
            $scope.UserModel.ClockingStaff = false;
            $scope.UserModel.newTech.IsTechnician = false;
            $scope.UserModel.IsRedBorderActiveForEditEmail = false;
            $scope.UserModel.isClockingStaffEdit = -1;
            $scope.UserModel.IsRedBorderActiveForEditFirstName = false;
            $scope.UserModel.IsRedBorderActiveForEditLastName = false;
            $scope.UserModel.IsRedBorderActiveForEditTechFirstName = false;
            $scope.UserModel.IsRedBorderActiveForEditTechLastName = false;
            $scope.UserModel.noofUserInTrialOrg = 0;
            UserPageService.getAllUsers().then(function(successResult) {
                $scope.UserModel.allUserList = successResult;
                if ($scope.UserModel.noofUserInTrialOrg >= 0) {
                    $scope.UserModel.noofUserInTrialOrg = 5 - $scope.UserModel.allUserList.length;
                }
                angular.element('[role ="tooltip"]').hide();
                setTimeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: 'body'
                    });
                }, 500);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.UserModel.deleteClockingStaff = function(clockingStaffId) {
            $scope.UserModel.newTech.FirstName = '';
            $scope.UserModel.newTech.LastName = '';
            $scope.UserModel.newTech.IsTechnician = false;
            $scope.UserModel.IsRedBorderActiveForEditTechFirstName = false;
            $scope.UserModel.IsRedBorderActiveForEditTechLastName = false;
            var deletedElement = angular.element('#' + clockingStaffId);
            deletedElement.addClass('bp-collapse-deleted-div-transition');
            UserPageService.deleteClockingStaff(clockingStaffId).then(function(successResult) {
                $scope.UserModel.isClockingStaffEdit = -1;
                $scope.UserModel.setBGColor = -1;
                $scope.UserModel.ClockingStaffList = successResult;
                angular.element('[role ="tooltip"]').hide();
                setTimeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: 'body'
                    });
                    Notification.success($translate.instant('Staff_deleted'));
                }, 500);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.UserModel.editTechStaffmode = function(index, event) {
            $scope.UserModel.isBlur = false;
        }
        $scope.UserModel.disableEditMode = function(index) {
            if ($scope.UserModel.isClockingStaffEdit == index) {
                return false;
            } else {
                return true;
            }
        }
        $scope.UserModel.validateAddBut = function() {
            if ($scope.UserModel.newTech.FirstName != null && $scope.UserModel.newTech.FirstName != '' && $scope.UserModel.newTech.FirstName != undefined && $scope.UserModel.newTech.LastName != null && $scope.UserModel.newTech.LastName != '' && $scope.UserModel.newTech.LastName != undefined) {
                $scope.UserModel.enableAddButton = true;
            } else {
                $scope.UserModel.enableAddButton = false;
            }
        }
        $scope.UserModel.toggleTechnician = function() {
            $scope.UserModel.newTech.IsTechnician = !$scope.UserModel.newTech.IsTechnician;
        }
        $scope.UserModel.addclockingStaff = function() {
            $scope.UserModel.enableAddButton = false;
            var lastIndex = $scope.UserModel.ClockingStaffList.length;
            var NewTechUserName = $scope.UserModel.newTech.FirstName + ' ' + $scope.UserModel.newTech.LastName;
            for (var i = 0; i < $scope.UserModel.ClockingStaffList.length; i++) {
                var TechUserName = $scope.UserModel.ClockingStaffList[i].FirstName + ' ' + $scope.UserModel.ClockingStaffList[i].LastName;
                if (TechUserName.toLowerCase() == NewTechUserName.toLowerCase()) {
                    Notification.error($translate.instant('Staff_name_already_registered'));
                    setTimeout(function() {
                        angular.element('#tech-first-name').select();
                    }, 1000);
                    event.preventDefault();
                    return;
                }
            }
            UserPageService.createClockingStaff(angular.toJson($scope.UserModel.newTech)).then(function(successResult) {
                for (var i = lastIndex; i > 0; i--) {
                    $scope.UserModel.ClockingStaffList[i] = $scope.UserModel.ClockingStaffList[i - 1];
                }
                $scope.UserModel.ClockingStaffList[0] = successResult;
                $scope.UserModel.setBGColor = 0;
                $scope.UserModel.newTech.FirstName = '';
                $scope.UserModel.newTech.LastName = '';
                $scope.UserModel.newTech.IsTechnician = false;
                angular.element('[role ="tooltip"]').hide();
                setTimeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: 'body'
                    });
                }, 500);
                setTimeout(function() {
                    $scope.UserModel.setBGColor = -1;
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }, 1000);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.UserModel.createUsers = function() {
            var lastIndex = $scope.UserModel.allUserList.length;
            if ($scope.UserModel.newUser.isTechnician == undefined || $scope.UserModel.newUser.isTechnician == '' || $scope.UserModel.newUser.isTechnician == null) {
                $scope.UserModel.newUser.isTechnician = false;
            }
            //requires
            var NewUserName = $scope.UserModel.newUser.firstName + ' ' + $scope.UserModel.newUser.lastName;
            for (var i = 0; i < $scope.UserModel.allUserList.length; i++) {
                if (($scope.UserModel.allUserList[i].name).toLowerCase() == (NewUserName).toLowerCase() || ($scope.UserModel.allUserList[i].email).toLowerCase() == ($scope.UserModel.newUser.email).toLowerCase()) {
                    Notification.error($translate.instant('User_name_already_registered'));
                    setTimeout(function() {
                        angular.element('#user-first-name').select();
                    }, 500);
                    event.preventDefault();
                    return;
                }
            }
            UserPageService.createUsers(angular.toJson($scope.UserModel.newUser)).then(function(successResult) {
                for (var i = lastIndex; i > 0; i--) {
                    $scope.UserModel.allUserList[i] = $scope.UserModel.allUserList[i - 1];
                }
                //check the response before binding.
                $scope.UserModel.allUserList[0] = successResult;
                $scope.UserModel.newUser = {};
                $scope.UserModel.newUser.isTechnician = false;
                $scope.UserModel.enableAddUserButton = false;
                $scope.UserModel.setUserBGColor = 0;
                setTimeout(function() {
                    $scope.UserModel.setUserBGColor = -1;
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }, 1000);
                if ($scope.UserModel.noofUserInTrialOrg >= 0) {
                    $scope.UserModel.noofUserInTrialOrg = 5 - $scope.UserModel.allUserList.length;
                }
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.UserModel.toggleuserTechnician = function() {
            $scope.UserModel.newUser.isTechnician = !$scope.UserModel.newUser.isTechnician;
        }
        $scope.UserModel.validateAddUserButton = function() {
            if ($scope.UserModel.allUserList.length < 5 && $scope.UserModel.newUser.firstName != null && $scope.UserModel.newUser.firstName != '' && $scope.UserModel.newUser.firstName != undefined && $scope.UserModel.newUser.lastName != null && $scope.UserModel.newUser.lastName != '' && $scope.UserModel.newUser.lastName != undefined && $scope.UserModel.newUser.email != null && $scope.UserModel.newUser.email != '' && $scope.UserModel.newUser.email != undefined) {
                $scope.UserModel.enableAddUserButton = true;
            } else {
                $scope.UserModel.enableAddUserButton = false;
            }
        }
        $scope.UserModel.editUser = function(index) {
            $scope.UserModel.isUserEdit = index;
            $scope.UserModel.IsRedBorderActiveForEditEmail = false;
            $scope.UserModel.IsRedBorderActiveForEditFirstName = false;
            $scope.UserModel.IsRedBorderActiveForEditLastName = false;
            $scope.UserModel.IsRedBorderActiveForEditTechFirstName = false;
            $scope.UserModel.IsRedBorderActiveForEditTechLastName = false;
            $scope.UserModel.newUser = {};
            $scope.UserModel.setUserBGColor = index;
            $scope.UserModel.UserListCopy = angular.copy($scope.UserModel.allUserList);
            setTimeout(function() {
                angular.element('#edit-first-name' + index).focus();
            }, 100);
        }
        $scope.UserModel.saveEditUser = function(index, event) {
            var IsDuplicate = false;
            var DuplicateIndex = '';
            focusedElement = event.relatedTarget;
            if (focusedElement != undefined && focusedElement != '' && focusedElement != null) {
                if (focusedElement.id == ('edit-first-name' + index) || focusedElement.id == ('edit-last-name' + index) || focusedElement.id == ('edit-email' + index)) {
                    $scope.UserModel.isBlur = false;
                }
            }
            if (event.type == "blur" && !$scope.UserModel.isBlur) {
                event.preventDefault();
                $scope.UserModel.isBlur = true;
                return;
            }
            if (event.type == "blur" && $scope.UserModel.isBlur) {
                var EmailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
                var IsValidEmail = EmailRegEx.test($scope.UserModel.allUserList[index].email);
                if ($scope.UserModel.allUserList[index].firstName != null && $scope.UserModel.allUserList[index].firstName != '' && $scope.UserModel.allUserList[index].firstName != undefined) {
                    $scope.UserModel.IsRedBorderActiveForEditFirstName = false;
                } else {
                    $scope.UserModel.IsRedBorderActiveForEditFirstName = true;
                }
                if ($scope.UserModel.allUserList[index].lastName != null && $scope.UserModel.allUserList[index].lastName != '' && $scope.UserModel.allUserList[index].lastName != undefined) {
                    $scope.UserModel.IsRedBorderActiveForEditLastName = false;
                } else {
                    $scope.UserModel.IsRedBorderActiveForEditLastName = true;
                }
                if (IsValidEmail) {
                    $scope.UserModel.IsRedBorderActiveForEditEmail = false;
                } else {
                    $scope.UserModel.IsRedBorderActiveForEditEmail = true;
                }
                if ($scope.UserModel.IsRedBorderActiveForEditFirstName || $scope.UserModel.IsRedBorderActiveForEditLastName || $scope.UserModel.IsRedBorderActiveForEditEmail) {
                    if ($scope.UserModel.IsRedBorderActiveForEditFirstName) {
                        Notification.error($translate.instant('Invalid_user_first_name'));
                        if ($scope.UserModel.UserListCopy != undefined) {
                            $scope.UserModel.allUserList[index].firstName = $scope.UserModel.UserListCopy[index].firstName;
                        }
                        setTimeout(function() {
                            angular.element('#edit-first-name' + index).select();
                        }, 500);
                    }
                    if ($scope.UserModel.IsRedBorderActiveForEditLastName) {
                        Notification.error($translate.instant('Invalid_user_last_name'));
                        if ($scope.UserModel.UserListCopy != undefined) {
                            $scope.UserModel.allUserList[index].lastName = $scope.UserModel.UserListCopy[index].lastName;
                        }
                        setTimeout(function() {
                            angular.element('#edit-last-name' + index).select();
                        }, 500);
                    }
                    if ($scope.UserModel.IsRedBorderActiveForEditEmail) {
                        Notification.error($translate.instant('Invalid_user_email'));
                        if ($scope.UserModel.UserListCopy != undefined) {
                            $scope.UserModel.allUserList[index].email = $scope.UserModel.UserListCopy[index].email;
                        }
                        setTimeout(function() {
                            angular.element('#edit-email' + index).select();
                        }, 500);
                    }
                    event.preventDefault();
                    return;
                }
                for (var i = 0; i < $scope.UserModel.allUserList.length; i++) {
                    if ($scope.UserModel.UserListCopy != undefined) {
                        if (($scope.UserModel.allUserList[index].firstName).toLowerCase() == ($scope.UserModel.UserListCopy[i].firstName).toLowerCase() && ($scope.UserModel.allUserList[index].lastName).toLowerCase() == ($scope.UserModel.UserListCopy[i].lastName).toLowerCase() && i != index) {
                            Notification.error($translate.instant('Duplicate_user_name'));
                            $scope.UserModel.allUserList[index].firstName = $scope.UserModel.UserListCopy[index].firstName;
                            $scope.UserModel.allUserList[index].lastName = $scope.UserModel.UserListCopy[index].lastName;
                            IsDuplicate = true;
                            DuplicateIndex = index;
                            break;
                        }
                    }
                }
                if (IsDuplicate) {
                    setTimeout(function() {
                        angular.element('#edit-first-name' + index).select();
                    }, 1000);
                    event.preventDefault();
                    return;
                }
                UserPageService.editUsers(angular.toJson($scope.UserModel.allUserList[index])).then(function(successResult) {
                    $scope.UserModel.isUserEdit = -1;
                    $scope.UserModel.allUserList[index] = successResult;
                    setTimeout(function() {
                        $scope.UserModel.setUserBGColor = -1;
                        if (!$scope.$$phase) {
                            $scope.$digest();
                        }
                    }, 1000);
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
            }
        }
        
        $scope.UserModel.openAddEditTechSchedulePopup = function(techStaff) {
			if(!techStaff.IsTechnician) {
				return;
			}
            var AddEditTechnicianScheduleParams = {
            		CurrentTechId:techStaff.Id
            };
            loadState($state, 'User.AddEditTechnicianSchedule', {
            	AddEditTechnicianScheduleParams: AddEditTechnicianScheduleParams
            });
        }
        $scope.UserModel.deleteUser = function(userId) {
            UserPageService.deleteUser(userId).then(function(successResult) {
                $scope.UserModel.isUserEdit = -1;
                $scope.UserModel.setUserBGColor = -1;
                $scope.UserModel.IsRedBorderActiveForEditEmail = false;
                $scope.UserModel.IsRedBorderActiveForEditFirstName = false;
                $scope.UserModel.IsRedBorderActiveForEditLastName = false;
                $scope.UserModel.IsRedBorderActiveForEditTechFirstName = false;
                $scope.UserModel.IsRedBorderActiveForEditTechLastName = false;
                $scope.UserModel.newUser = {};
                $scope.UserModel.allUserList = successResult;
                var deletedElement = angular.element('#' + userId);
                deletedElement.addClass('bp-collapse-deleted-div-transition');
                angular.element('[role ="tooltip"]').hide();
                setTimeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: 'body'
                    });
                    Notification.success($translate.instant('User_deactivated'));
                }, 500);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        
        function loadData() {
        	if($stateParams && $stateParams.Id === 'timeClockingStaff') {
        		 $scope.UserModel.loadAllClockingStaff();
        	} else {
        		$scope.UserModel.loadAllLicensedUsers();
        	}
        }
        
        loadData();
    }])
});