define(['Routing_AppJs_PK', 'JqueryUI', 'moment'], function (Routing_AppJs_PK,  JqueryUI, moment) {
	var injector = angular.injector(['ui-notification', 'ng']);
	Routing_AppJs_PK.directive('addEditTextTag',['$sce','$translate', 'focusElement', function($sce, $translate, focusElement ) {
		var Notification = injector.get("Notification");
		return {
			restrict: 'E',
	        scope: {
	        	tagName:'@',
		        objectPayload: '=',
		        nonEditableConcern: '=',
		        maxLength: '@',
		        updateTagMethod: '&',
		        isEditable: '=',
		        isNewInputTagNotAvailable: '='
	        	},
	        template:
	        '<div class="bp-addEditTagWrapper" ng-click="displayNewInput()" ng-class="{\'bp-border\': isFocusInput}">'+
	            '<div ng-class="{\'P10\': objectPayload.Tags.length > 0 || nonEditableConcern.Tags.length > 0,\'PB0\': !toDisplayNewTagInput}">'+
	                '<div ng-repeat="tag in objectPayload.Tags track by $index" class="d-flex">' + 
	                    '<input id="{{tagName}}Tag{{$index}}" type="text" class="bp-input-text MB10" ng-show="editModeIndexMultiSelect === $index"' + 
	                           'ng-model="objectPayload.Tags[$index]"'+
	                           'ng-blur="updateMultiSelect($event,$index)"' +
	                           'ng-keydown="updateMultiSelect($event,$index)"' +
	                           'maxlength="{{maxLength}}" ng-focus = "focusInputAction()" />' +
	                    '<span ng-click="editMultiselectTag($event,$index);" ng-show="editModeIndexMultiSelect != $index">' +
	                        '{{tag}}' +
		                    '<i class="blue_3384FF" ng-include="getTrustedUrl(\'close.svg\')"' + 
		                        'ng-click="removeFromMultiSelect($index,$event)"></i>' +
	                    '</span>' +
	                '</div>' +
	                '<div ng-repeat="tag in nonEditableConcern.Tags track by $index" class="d-flex">' + 
	                    '<span>' +
	                        '{{tag}}' +
		                    '<i class="blue_3384FF" ng-include="getTrustedUrl(\'lock-fill.svg\')" ></i>' +
	                    '</span>' +
	                '</div>' +
	                '<input id="{{tagName}}NewTag" type="text" class="bp-input-text" ' +
	                    'ng-model="objectPayload.newTag"' +
	                    'ng-if="(toDisplayNewTagInput && !isNewInputTagNotAvailable)"' +
	                    'ng-keydown="addAndRemoveFromMultiSelect($event)"' +
	                    'ng-blur="addAndRemoveFromMultiSelect($event)" ng-focus = "focusInputAction()"' +
	                    'placeholder="{{ \'Type your notes here\' | translate }}"' +
	                    'maxlength="{{maxLength}}" />' +
	            '</div>' +
	       '</div>',
	       link: function(scope) {
	    	   scope.toDisplayNewTagInput = false;
	    	   scope.isTaglistEmpty = function() {
	    		   if(scope.objectPayload.Tags && scope.objectPayload.Tags.length) {
	    			   scope.toDisplayNewTagInput = false;
		    		   return false;
		    	   } else {
		    		   scope.displayNewInput();
		    		   return true;
		    	   }
	    	   } 
               scope.focusInputAction = function (){
	    		   scope.isFocusInput = true;
	    	   }
	    	   scope.displayNewInput = function() {
	    		   //permission check
	    		   if(!scope.isEditable) {
	    			   scope.toDisplayNewTagInput = false;
	    			   return;
	    		   }
	    		   scope.toDisplayNewTagInput = true;
	    		   focusElement(scope.tagName +'NewTag');
	    	   }
	    	   scope.currentTagValue = ''; // will store the original value of tag when its open for editing 
	    	   scope.updateMultiSelect = function(event, editedFieldIndex) {
	               var isAlreadyExist = false;
	               var fieldValue = scope.objectPayload.Tags[editedFieldIndex];
	               if ((event.keyCode == 13 || event.keyCode == 9 || event.type === 'blur')) {
	                   if (fieldValue != '' && fieldValue != undefined) {
	                       for (var i = 0; i < scope.objectPayload.Tags.length; i++) {
	                           if (i != editedFieldIndex && scope.objectPayload.Tags[i].toLowerCase() === scope.objectPayload.Tags[editedFieldIndex].toLowerCase()) {
	                               isAlreadyExist = true;
	                               Notification.error($translate.instant('Same_tag_already_exist'));
	                               scope.objectPayload.Tags[editedFieldIndex] = scope.currentTagValue;
	                               focusElement(scope.tagName+'Tag' + editedFieldIndex);
	                           }
	                       }
	                       if (!isAlreadyExist) {
	                    	   scope.editModeIndexMultiSelect = -1;
	                    	   scope.toDisplayNewTagInput = false;
	                    	   scope.updateTagMethod();
                                if(event.keyCode == 9) {
	                    		   scope.isFocusInput = false;  
	                    	   }
	                       }
	                   } else {
	                       scope.removeFromMultiSelect(editedFieldIndex, event);
	                       scope.editModeIndexMultiSelect = -1;
	                   }
	               }
	               event.stopPropagation();
                    if(event.type === 'blur') {
	            	   scope.isFocusInput = false;
	               }
	           }
	    	   scope.editModeIndexMultiSelect = -1;
	    	   scope.removeFromMultiSelect = function(index, event) {
	    		   scope.objectPayload.Tags.splice(index, 1);
	               scope.editModeIndexMultiSelect = -1;
	               scope.toDisplayNewTagInput = false;
                    if(scope.objectPayload.Tags.length != 0) {
	            	   scope.isFocusInput = false;
	               }
	               scope.updateTagMethod();
	               if(event) {
	            	   event.stopPropagation();
	               }
	               scope.isTaglistEmpty();
	           }
	    	   scope.addAndRemoveFromMultiSelect = function(event) {
	               var isAlreadyExist = false;
	               var fieldValue = scope.objectPayload.newTag;
	               if ((event.keyCode == 13 || event.keyCode == 9 || event.type === 'blur') && fieldValue != '' && fieldValue != undefined) {
	                   for (var i = 0; i < scope.objectPayload.Tags.length; i++) {
	                       if (scope.objectPayload.Tags[i].toLowerCase() === fieldValue) {
	                           isAlreadyExist = true;
                               Notification.error($translate.instant('Same_tag_already_exist'));
	                           focusElement(scope.tagName+'NewTag');
	                       }
	                   }
	                   if (!isAlreadyExist) {
	                	   scope.objectPayload.Tags.push(fieldValue);
	                	   scope.objectPayload.newTag = '';
	                	   scope.toDisplayNewTagInput = false;
	                	   scope.updateTagMethod();
	                	   if(event.keyCode == 13) {
	                		   scope.displayNewInput(); 
	                	   }
	                	  if(event.keyCode == 9) {
	                		   scope.isFocusInput = false;
	                	   }
	                   }
	               } else if ((event.keyCode == 13 || event.keyCode == 9 || event.type === 'blur') && (fieldValue == '' || fieldValue == undefined)) {
	            	   if(!(scope.objectPayload.Tags.length==0)) {
	            		   scope.isTaglistEmpty();
	            	   }
	               }
	               /*remove using backspace */
	               var length = scope.objectPayload.Tags.length;
	               if (event.keyCode === 8 && (fieldValue == undefined || fieldValue == '')) {
	            	   scope.removeFromMultiSelect(length-1);
	               }
                    if(event.type === 'blur') {
	            	   scope.isFocusInput = false;
	               }
	           }
	           scope.editMultiselectTag = function(event, multiselectTagIndex) {
	        	   //permission check
	        	   if(!scope.isEditable) {
	    			   return;
	    		   }
	        	   scope.toDisplayNewTagInput = false;
	               scope.currentTagValue = angular.copy(scope.objectPayload.Tags[multiselectTagIndex]);
	               scope.editModeIndexMultiSelect = multiselectTagIndex;
	               focusElement(scope.tagName +'Tag' + multiselectTagIndex);
	               event.stopPropagation();
	           }
	    	   
	    	   scope.getTrustedUrl = function (resourceName) {
           			return $sce.trustAsResourceUrl($Global.ApplicationImagePath +'/Icons/'+ resourceName);
               }
	    	   scope.isTaglistEmpty();
	       }
		};
    }]);
});   