define(['Routing_AppJs_PK','FusionMappingServices','HighlightSearchTextFilter','FusionMappingCustomSearchFilter'], function(Routing_AppJs_PK,FusionMappingServices,HighlightSearchTextFilter,FusionMappingCustomSearchFilter) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('FusionMappingCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state','FusionMappingService', '$filter', function($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state,FusionMappingService, $filter) {
        var Notification = injector1.get("Notification");
        $scope.M_FusionMapping = $scope.M_FusionMapping || {};
        $scope.F_FusionMapping = $scope.M_FusionMapping || {};
        $scope.M_FusionMapping.selectedFusionLineItemRecord = {};
        $scope.M_FusionMapping.showGLAccountList = false;
        $scope.M_FusionMapping.GLAccountList = [];
        $scope.M_FusionMapping.GLAccountListMasterData = [];
        $scope.M_FusionMapping.selectedGLAccountListForMapping = [];
        $scope.M_FusionMapping.searchedString = '';
        $scope.M_FusionMapping.saveActionAvailableList = [];
		$scope.M_FusionMapping.isSaveAndMapActionAvailable = false;
		
        $scope.F_FusionMapping.loadFormData = function() {
        	FusionMappingService.getFusionLineItems().then(function(result) {
        		$scope.M_FusionMapping.listData = result;
        		showTooltip('body');
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        	FusionMappingService.getGeneralAccounts().then(function(result) {
        		$scope.M_FusionMapping.GLAccountListMasterData = result;
        		$scope.M_FusionMapping.GLAccountList = angular.copy(result);
        		$scope.M_FusionMapping.GLAccountList.sort(function(a, b){
                    if(a.AccountName < b.AccountName) return -1;
                    if(a.AccountName > b.AccountName) return 1;
                    return 0;
                });
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        
        function setFusionLineItemToSaveActionMap() {
        	$scope.M_FusionMapping.saveActionAvailableList = [];
        	angular.forEach($scope.M_FusionMapping.listData, function(lineItem, key){
				if(lineItem.MapAction && ( !lineItem.MappedGLAccountWithNameList.length)) {
					$scope.M_FusionMapping.saveActionAvailableList.push(lineItem);
				}
    	    });
        	if($scope.M_FusionMapping.saveActionAvailableList.length > 1 || ($scope.M_FusionMapping.saveActionAvailableList.length == 1 && $scope.M_FusionMapping.selectedFusionLineItemRecord.HDNetAccount != $scope.M_FusionMapping.saveActionAvailableList[0].HDNetAccount)) {
        		$scope.M_FusionMapping.isSaveAndMapActionAvailable = true;
        	} 
        }
        
        function showTooltip(containerName) {
            angular.element('[role ="tooltip"]').hide();
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'top',
                    container: containerName
                });
                    setToolTipPosition();
                    
            }, 500);
        }
         setToolTipPosition = function() {
        	if (window.innerWidth <= 767) {
                $("[data-toggle=tooltip]").hover(function(e){
                   	$('.tooltip').css('left', "10%");
                   	var targetElement = e.target;
                   	$('.tooltip > .tooltip-arrow').css('left', "50%");
                   	$('.tooltip').css('top', $(targetElement).offset().top - $(targetElement).height() - $('.tooltip').height());
                   	
               	});
            }
        	
        	if (window.innerWidth <= 400) {
                $("[data-toggle=tooltip]").hover(function(e){
                	var targetElement = e.target;
                   	$('.tooltip').css('left', "5%");
                   	$('.tooltip > .tooltip-arrow').css('left', "50%");
                 	$('.tooltip').css('top', $(targetElement).offset().top - $(targetElement).height()  - $('.tooltip').height());
               	});
            }
        	if(window.innerWidth > 767) {
        		 $("[data-toggle=tooltip]").hover(function(e){
                 	var targetElement = e.target;
                    	$('.tooltip').css('left', "30%");
                    	$('.tooltip > .tooltip-arrow').css('left', "50%");
                	});
        	}
        }
        $( window ).resize(function() {
        	setToolTipPosition();
          });
        $scope.F_FusionMapping.showFusionMappingModal = function(fusionLineItemRecord,isFrom) {
        	if((isFrom === 'Mapped' && !fusionLineItemRecord.MapAction)) {
        		return ;
        	} 
        	angular.element("#fusionMappingModal")[0].scrollTop = 0;
    		angular.element('#fusionMappingModal').modal({
                backdrop: 'static',
                keyboard: false
            });
            angular.element('#fusionMappingModal').show();
            $scope.M_FusionMapping.selectedFusionLineItemRecord = fusionLineItemRecord;
            setFusionLineItemToSaveActionMap();
            $scope.M_FusionMapping.GLAccountList = angular.copy($scope.M_FusionMapping.GLAccountListMasterData);
            if(fusionLineItemRecord.MappedGLAccountWithNameList && fusionLineItemRecord.MappedGLAccountWithNameList.length) {
            	for(var i=0 ; i < fusionLineItemRecord.MappedGLAccountWithNameList.length ; i++) {
            		var obj= {};
            		obj.AccountNumber = fusionLineItemRecord.MappedGLAccountWithNameList[i][0];
            		obj.AccountName = fusionLineItemRecord.MappedGLAccountWithNameList[i][1];
            		$scope.F_FusionMapping.selectGLAccount(obj,'MappedAccountExists');
            	} 
            } else {
        		$scope.M_FusionMapping.selectedGLAccountListForMapping = [];
        	}
        }
        angular.element(document).on("click", "#fusionMappingModal .modal-backdrop", function() {
            $scope.F_FusionMapping.closeFusionMappingModal();
        });
        $scope.F_FusionMapping.closeFusionMappingModal = function(){
        	angular.element('#fusionMappingModal').modal('hide');
        	$scope.M_FusionMapping.selectedGLAccountListForMapping = [];
        }
        
        $scope.F_FusionMapping.getGLAccountList = function() {
        	$scope.M_FusionMapping.showGLAccountList = true;
        }
        $scope.F_FusionMapping.hideGLAccountList = function() {
        	$scope.M_FusionMapping.showGLAccountList = false;
        	$scope.M_FusionMapping.searchedString = '';
        }
        $scope.F_FusionMapping.selectGLAccount = function(account,isMappedAccount) {
        	
        	if(isMappedAccount === 'MappedAccountExists') {
        		for(var i=0 ; i< $scope.M_FusionMapping.GLAccountList.length ; i++) {
        			if(($scope.M_FusionMapping.GLAccountList[i].AccountName === account.AccountName)) {
        				$scope.M_FusionMapping.selectedGLAccountListForMapping.push($scope.M_FusionMapping.GLAccountList[i]);
        				$scope.M_FusionMapping.GLAccountList.splice(i, 1);
        			}
        		}
        	} else {
        		$scope.M_FusionMapping.searchedString = '';
            	var index = $scope.M_FusionMapping.GLAccountList.indexOf(account);
    			if (index > -1) {
    				$scope.M_FusionMapping.GLAccountList.splice(index, 1);
    			}
            	$scope.M_FusionMapping.selectedGLAccountListForMapping.push(account);
        	}
        }
        $scope.F_FusionMapping.setFocusOnElement = function(elementId) {
        	setTimeout(function() {
        		angular.element("#" + elementId).focus();
        	},200);
        }
        $scope.F_FusionMapping.removeGLAccountFromList = function(glAccountRecord) {
        	$scope.M_FusionMapping.GLAccountList.push(glAccountRecord);
        	var index = $scope.M_FusionMapping.selectedGLAccountListForMapping.indexOf(glAccountRecord);
			if (index > -1) {
				$scope.M_FusionMapping.selectedGLAccountListForMapping.splice(index, 1);
			}
        }
        $scope.F_FusionMapping.saveMapping = function() {
        	FusionMappingService.saveFusionLineItem($scope.M_FusionMapping.selectedFusionLineItemRecord.Id, angular.toJson($scope.M_FusionMapping.selectedGLAccountListForMapping)).then(function(result) {
        		$scope.F_FusionMapping.closeFusionMappingModal();
        		$scope.F_FusionMapping.loadFormData();
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        	
        }
        $scope.F_FusionMapping.saveAndNextMapping= function() {
        	var orderNumberOfSelectedFusionLineItem = $scope.M_FusionMapping.selectedFusionLineItemRecord.OrderNumber;
        	FusionMappingService.saveFusionLineItem($scope.M_FusionMapping.selectedFusionLineItemRecord.Id, angular.toJson($scope.M_FusionMapping.selectedGLAccountListForMapping)).then(function(result) {
        		$scope.M_FusionMapping.listData[orderNumberOfSelectedFusionLineItem - 1].MappedGLAccountWithNameList = [];
        		if($scope.M_FusionMapping.selectedGLAccountListForMapping.length) {
        			for(var i=0; i < $scope.M_FusionMapping.selectedGLAccountListForMapping.length ; i++) {
        				var obj = [];
            			obj.push($scope.M_FusionMapping.selectedGLAccountListForMapping[i].AccountNumber);
            			obj.push($scope.M_FusionMapping.selectedGLAccountListForMapping[i].AccountName);
            			$scope.M_FusionMapping.listData[orderNumberOfSelectedFusionLineItem - 1].MappedGLAccountWithNameList.push(obj);
            		}
        		} 
        		getNextFusionLineItemToMap();
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        function getNextFusionLineItemToMap() {
        	$scope.M_FusionMapping.GLAccountList = angular.copy($scope.M_FusionMapping.GLAccountListMasterData);
    		var selectedRecord = {};
        	if(isSaveAndMapActionAvailable())  {
        		var isFromAlreadyMappedAccount = true;
        		for(var i=0 ; i < $scope.M_FusionMapping.saveActionAvailableList.length ; i++) {
            		if($scope.M_FusionMapping.selectedFusionLineItemRecord.OrderNumber == $scope.M_FusionMapping.saveActionAvailableList[i].OrderNumber) {
            			isFromAlreadyMappedAccount = false;
            			if(i == $scope.M_FusionMapping.saveActionAvailableList.length - 1 ){
            				selectedRecord =  $scope.M_FusionMapping.saveActionAvailableList[0];
            			} else {
            				selectedRecord = $scope.M_FusionMapping.saveActionAvailableList[i+1];
            			}
            			var index = $scope.M_FusionMapping.saveActionAvailableList.indexOf(selectedRecord);
            			if (index > -1) {
            				$scope.M_FusionMapping.saveActionAvailableList.splice(index, 1);
            			}
            			break;
        			}
        		}
        		if(isFromAlreadyMappedAccount)  {
        			var isLastAccountEdited = true;
        			for(var i=0 ; i < $scope.M_FusionMapping.saveActionAvailableList.length ; i++) {
        				if($scope.M_FusionMapping.saveActionAvailableList[i].OrderNumber > $scope.M_FusionMapping.selectedFusionLineItemRecord.OrderNumber) {
        					isLastAccountEdited = false;
        					selectedRecord = $scope.M_FusionMapping.saveActionAvailableList[i];
        					break;
        				} 
        			}
        			if(isLastAccountEdited) {
        				selectedRecord =  $scope.M_FusionMapping.saveActionAvailableList[0];
        			}
        		}
        		if($scope.M_FusionMapping.saveActionAvailableList.length == 1) {
        			$scope.M_FusionMapping.isSaveAndMapActionAvailable = false;
        		} else {
        			$scope.M_FusionMapping.isSaveAndMapActionAvailable = true;
        		}
        		$scope.F_FusionMapping.showFusionMappingModal(selectedRecord);
        	} else {
        		$scope.M_FusionMapping.isSaveAndMapActionAvailable = false;
        	}
        	
    	}
        function isSaveAndMapActionAvailable() {
        	if($scope.M_FusionMapping.saveActionAvailableList.length == 1 && $scope.M_FusionMapping.selectedFusionLineItemRecord.OrderNumber == $scope.M_FusionMapping.saveActionAvailableList[0].OrderNumber) {
        		return false;
        	}
        	return true;
        }
        $scope.F_FusionMapping.showAddButton = function(accountRec,toshow) {
        	var index = $scope.M_FusionMapping.GLAccountList.indexOf(accountRec);
			if (index > -1) {
				$scope.M_FusionMapping.GLAccountList[index].showAddButton = toshow;
			}
        }
        
        $scope.F_FusionMapping.keyBoardNavigation = function (event, dataList, dropDownName,searchString) {
            var keyCode = event.which ? event.which : event.keyCode;
            var dropDownDivId = '#' + dropDownName + 'DropDownDiv';
            var indexName = dropDownName + 'CurrentIndex';
            if ($scope.M_FusionMapping[indexName] == undefined || isNaN($scope.M_FusionMapping[indexName])) {
            	$scope.M_FusionMapping[indexName] = -1;
            }

            if (dropDownName === 'glAccount') {
            	$scope.M_FusionMapping.showGLAccountList = true;
            } 
            
            dataList.sort(function(a, b){
                if(a.AccountName < b.AccountName) return -1;
                if(a.AccountName > b.AccountName) return 1;
                return 0;
            });
            var highlightedAccount = [];
            if (keyCode == 40 && dataList != undefined && dataList != '') {
                if (dataList.length - 1 > $scope.M_FusionMapping[indexName]) {
                	$scope.M_FusionMapping[indexName]++;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_FusionMapping[indexName])[0].offsetTop - 100;
                    highlightedAccount = [];
                	for(i=0;i<dataList.length;i++){
                    	if ((dataList[i].AccountName).indexOf(searchString) != -1 || (dataList[i].AccountNumber && (dataList[i].AccountNumber).indexOf(searchString) != -1)) {
                    		highlightedAccount.push(dataList[i]);
                        }
                    	$scope.F_FusionMapping.showAddButton(dataList[i], false);
                    }
                	$scope.F_FusionMapping.showAddButton(highlightedAccount[$scope.M_FusionMapping[indexName]], true);
                }
            } else if (keyCode === 38 && dataList != undefined && dataList != '') {
                if ($scope.M_FusionMapping[indexName] > 0) {
                	$scope.M_FusionMapping[indexName]--;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_FusionMapping[indexName])[0].offsetTop - 100;
                    highlightedAccount = [];
                	for(i=0;i<dataList.length;i++){
                    	if ((dataList[i].AccountName).indexOf(searchString) != -1 || (dataList[i].AccountNumber && (dataList[i].AccountNumber).indexOf(searchString) != -1)) {
                    		highlightedAccount.push(dataList[i]);
                        }
                    	$scope.F_FusionMapping.showAddButton(dataList[i], false);
                    }
                	$scope.F_FusionMapping.showAddButton(highlightedAccount[$scope.M_FusionMapping[indexName]], true);
                }
            } else if (keyCode == 13 && $scope.M_FusionMapping[indexName] !== -1) {
                if (dropDownName === 'glAccount') {
                	var selectedAccount = [];
                	for(i=0;i<dataList.length;i++){
                    	if ((dataList[i].AccountName).indexOf(searchString) != -1 || (dataList[i].AccountNumber && (dataList[i].AccountNumber).indexOf(searchString) != -1)) {
                    		selectedAccount.push(dataList[i]);
                        }
                    	$scope.F_FusionMapping.showAddButton(dataList[i], false);
                    }
                	$scope.F_FusionMapping.selectGLAccount(selectedAccount[$scope.M_FusionMapping[indexName]]);
                	$scope.F_FusionMapping.hideGLAccountList();
                }
                
                $scope.M_FusionMapping[indexName] = -1;
            }
        }
        $scope.F_FusionMapping.loadFormData();
    }])
});
