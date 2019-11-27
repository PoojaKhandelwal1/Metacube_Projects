define(['Routing_AppJs_PK', 'TagManagementServices', 'underscore_min'], function(Routing_AppJs_PK, TagManagementServices, underscore_min) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('TagManagementCtrl', ['$scope', '$timeout', '$rootScope', '$state', '$stateParams', '$compile', 'TagManagementServices',
        function($scope, $timeout, $rootScope, $state, $stateParams, $compile, TagManagementServices) {
            var Notification = injector.get("Notification");
            var origin = window.location.origin;
            var url = origin + '/apex/';
            $scope.showLoading = true;
            $scope.TagMgntModel = {};
            $scope.TagMgntModel.UserFirstName = $Global.UserFirstName;
            $scope.TagMgntModel.UserLastName = $Global.UserLastName;
            $scope.currentUserGroupName = $Global.userGroupName;
            $scope.currentUserGroupColor = $Global.userGroupColor;
            $scope.TagMgntModel.SortJson = {
                SortBy: 'CreatedDate',
                Reverse: true
            };
            $scope.TagMgntModel.isFocusOnCreateNewTagInput = false;
            $scope.TagMgntModel.getTagList = function() {
                TagManagementServices.getTagList().then(function(tagList) {
                    $scope.TagMgntModel.bindData(tagList);
                }, function(errorSearchResult) {});
            }
            $scope.TagMgntModel.MoveToState = function(stateName, attr) {
                loadState($state, stateName, attr);
            }
            $scope.TagMgntModel.populateTagEditableModel = function(tagList) {
                $scope.TagMgntModel.TagList_editRow = [];
                for (var i = 0; i < tagList.length; i++) {
                    $scope.TagMgntModel.TagList_editRow.push({
                        isEdit: false
                    });
                }
            }
            $scope.TagMgntModel.changeOrder = function() {
                $scope.TagMgntModel.SortJson.Reverse = !$scope.TagMgntModel.SortJson.Reverse;
                $scope.TagMgntModel.setTooltipDirection();
            }
            $scope.TagMgntModel.loadData = function() {
                $scope.TagMgntModel.getTagList();
            }
            $scope.TagMgntModel.loadData();
            $scope.TagMgntModel.saveTagAction = function(event) {
                if (event.keyCode == '13' && $scope.TagMgntModel.newTagStr != undefined && $scope.TagMgntModel.newTagStr.trim().length > 0) {
                    var tagObj = {
                        'Name': $scope.TagMgntModel.newTagStr.trim(),
                        'IsActive': true
                    };
                    $scope.TagMgntModel.saveTagRecord(tagObj);
                }
            }
            $scope.TagMgntModel.saveTagAfterEdit = function(index, tagObj, event) {
                var indexOriginal = _.findIndex($scope.TagMgntModel.TagList, {
                    'Id': tagObj.Id
                });
                if ((index > -1 && !$scope.TagMgntModel.isDeleteTagCalled && event == undefined) || (event != undefined && event.keyCode == '13')) {
                    var tagObj = $scope.TagMgntModel.TagList[indexOriginal];
                    if ($scope.TagMgntModel.isDeactiveTagCalled) {
                        tagObj.IsActive = !tagObj.IsActive;
                    }
                    if (tagObj.Name == $scope.TagMgntModel.editedTagName_Before && !$scope.TagMgntModel.isDeactiveTagCalled) {
                        $scope.TagMgntModel.TagList_editRow[indexOriginal].isEdit = false;
                    } else if (tagObj.Name == undefined || tagObj.Name.trim().length == 0) {
                        Notification.error($translate.instant('Cannot_be_empty'));
                        $scope.TagMgntModel.TagList[indexOriginal].Name = $scope.TagMgntModel.editedTagName_Before;
                        $scope.TagMgntModel.setFocus("tag" + index);
                    } else {
                        $scope.TagMgntModel.saveTagRecord(tagObj, indexOriginal, index);
                    }
                }
            }
            $scope.TagMgntModel.saveTagRecord = function(tagObj, editedIndex, listIndex) {
                TagManagementServices.saveTag(angular.toJson(tagObj)).then(function(tagList) {
                    if (tagList.length == 1 && tagList[0].ErrorMessage != null && tagList[0].ErrorMessage != undefined && tagList[0].ErrorMessage != '') {
                        Notification.error(tagList[0].ErrorMessage);
                        if (editedIndex != undefined && editedIndex > -1) {
                            $scope.TagMgntModel.setFocus("tag" + listIndex);
                        }
                    } else {
                        $scope.TagMgntModel.bindData(tagList);
                        Notification.success($translate.instant('Generic_Saved'));
                        if (editedIndex != undefined && editedIndex > -1) {
                            $scope.TagMgntModel.TagList_editRow[editedIndex].isEdit = false;
                        }
                    }
                }, function(errorSearchResult) {});
            }
            $scope.TagMgntModel.createNewTagFocus = function() {
                $scope.TagMgntModel.isFocusOnCreateNewTagInput = true;
            }
            $scope.TagMgntModel.createNewTagFocusOut = function() {
                $scope.TagMgntModel.isFocusOnCreateNewTagInput = false;
            }
            $scope.TagMgntModel.bindData = function(tagList) {
                $scope.TagMgntModel.TagList = tagList;
                $scope.TagMgntModel.populateTagEditableModel(tagList);
                $scope.TagMgntModel.newTagStr = '';
                $scope.TagMgntModel.setTooltipDirection();
                $scope.TagMgntModel.isDeactiveTagCalled = false;
                $scope.TagMgntModel.isDeleteTagCalled = false;
            }
            $scope.TagMgntModel.editTagRecord = function(event, index, tagObj) {
                var isEditModeEnabled = false;
                if (event.target['type'] != 'text') {
                    for (var i = 0; i < $scope.TagMgntModel.TagList_editRow.length; i++) {
                        if ($scope.TagMgntModel.TagList_editRow[i].isEdit) {
                            isEditModeEnabled = true;
                        }
                        $scope.TagMgntModel.TagList_editRow[i].isEdit = false;
                    }
                    if (!isEditModeEnabled) {
                        $scope.TagMgntModel.TagList_editRow[index].isEdit = true;
                        $scope.TagMgntModel.editedTagName_Before = tagObj.Name;
                        $scope.TagMgntModel.setFocus("tag" + index);
                    }
                    $scope.TagMgntModel.setTooltipDirection();
                }
            }
            $scope.TagMgntModel.deactiveTag = function(index) {
                $scope.TagMgntModel.isDeactiveTagCalled = true;
            }
            $scope.TagMgntModel.cancelButtonAction = function() {
                $scope.TagMgntModel.isDeleteTagCalled = false;
                $scope.TagMgntModel.hideRemovePopUp();
            }
            $scope.TagMgntModel.openDeleteTagPopup = function(tagObj) {
                $scope.TagMgntModel.isDeleteTagCalled = true;
                var index = _.findIndex($scope.TagMgntModel.TagList, {
                    'Name': tagObj.Name
                });
                $scope.TagMgntModel.TagRec = angular.copy($scope.TagMgntModel.TagList[index]);
            }
            $scope.TagMgntModel.openRemovePopup = function(tagObj) {
                TagManagementServices.getTagUsedCounter(angular.toJson(tagObj)).then(function(result) {
                    $scope.TagMgntModel.TagUsedCounter = result.UsedCounter;
                    if ($scope.TagMgntModel.TagUsedCounter > 0) {
                        $scope.TagMgntModel.showRemovePopUp();
                    } else {
                        $scope.TagMgntModel.removeTag();
                    }
                }, function(errorSearchResult) {});
            }
            $scope.TagMgntModel.showRemovePopUp = function() {
                angular.element("#deleteConfirmPopup").show();
                setTimeout(function() {
                    var template = '<div class="modal-backdrop fade in" ng-click="TagMgntModel.hideRemovePopUp()"></div>';
                    template = $compile(angular.element(template))($scope);
                    angular.element("#deleteConfirmPopup").prepend(template);
                    angular.element("#deleteConfirmPopup").addClass("in");
                    angular.element("body").addClass("modal-open");
                }, 1000);
            }
            $scope.TagMgntModel.hideRemovePopUp = function() {
                angular.element("#deleteConfirmPopup").removeClass("in");
                angular.element("body").removeClass("modal-open");
                angular.element("#deleteConfirmPopup").hide();
                angular.element("#deleteConfirmPopup").find('.modal-backdrop').remove();
            }
            $scope.TagMgntModel.removeTag = function() {
                TagManagementServices.removeTag(angular.toJson($scope.TagMgntModel.TagRec)).then(function(tagList) {
                    $scope.TagMgntModel.hideRemovePopUp();
                    $scope.TagMgntModel.bindData(tagList);
                }, function(errorSearchResult) {});
            }
            $scope.TagMgntModel.setFocus = function(elementId) {
                $timeout(function() {
                    angular.element("#" + elementId).focus();
                    angular.element("#" + elementId).select();
                }, 100);
            }
            $scope.TagMgntModel.setTooltipDirection = function() {
                angular.element('.tooltip').hide();
                $timeout(function() {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: 'body'
                    });
                }, 100);
            }
        }
    ])
});