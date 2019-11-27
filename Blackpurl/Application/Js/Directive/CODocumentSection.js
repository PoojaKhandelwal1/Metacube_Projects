define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
	Routing_AppJs_PK.directive('coDocumentSection', ['$sce', function($sce) {
		return {
			restrict : 'EA',
			scope : {
				innerAccordianWrapperClassValue: '@',
				expandCollapseInnerAccordian: '&',
				isInnerSectionExpanded: '=',
				innerAccordianBodyWrapperIdValue: '@',
				isCoClosed: '=',
				formList: '=',
				addFormAction: '&',
				deleteFormAction: '&',
				printDocumentAction: '&',
				attachmentList: '=',
				attachmentFileUploadInterfaceModal: '=',
				setAddAttachmentData: '&',
				deleteAttachmentAction: '&',
				activeFormCount: '=',
				activeForms: '='
			},
			template : ' \
						<div class="{{innerAccordianWrapperClassValue}}"  ng-class="{\'bp-inner-accordian-opened\': isInnerSectionExpanded}"> \
		                	<div class="inner-accordian-header col-md-12" ng-click = "expandCollapseInnerAccordian()"> \
			                   <div class="inner-accordian-header-left"> \
			                       <h2 class="accordian-left-details">{{\'Documents\' | translate}}</h2> \
			                   </div> \
			                   <div class="accordian-right-details"> \
			                       <a class="down-arrow-icon" ng-if = "!isInnerSectionExpanded"> \
			                       		<i ng-include="trustImageSrc(\'arrowDown\')" class="blue_008DC1"></i> \
			                       </a> \
			                       <a class="down-arrow-icon" ng-if = "isInnerSectionExpanded"> \
			                       		<i ng-include="trustImageSrc(\'arrowUp\')" class="blue_008DC1"></i> \
			                       </a> \
			                   </div> \
		                   </div> \
		                   <div class="inner-accordian-body  document-table-wrapper dfWrapper bp-light-gray4 col-md-12 bp-collapse-div-transition" id="{{innerAccordianBodyWrapperIdValue}}" \
		                   		ng-class="{\'bp-expand-div-transition\': isInnerSectionExpanded}"> \
		                   		<div class="expandableContainer"> \
		                        <!-- Start: Document - Form Section --> \
		                        <div class="table-responsive f-iTable document-table" ng-class="{\'PB67\' : isCoClosed, \'PB10\' : !formList.length }" ng-if="formList.length || (!formList.length && activeFormCount > 0 && activeForms.length && (activeForms.length != activeFormCount))"> \
		                            <p class="search-entity-text H400">{{\'Forms\' | translate}}</p> \
		                            <table class = "bp-editable-table dfFIProducttable SOJobItemsGrid" ng-if="formList.length"> \
		                               <col width="5%"/> \
		                               <col width="30%"/> \
		                               <col width="18%"/> \
		                               <col width="17%"/> \
		                               <col width="20%"/> \
		                               <col width="10%"/> \
		                               <thead> \
		                                   <tr> \
		                                      <th></th> \
		                                      <th class = "bp-text-uppercase">{{\'Name_Description\' | translate}}</th> \
		                                      <th class = "bp-text-uppercase ">{{\'Date_added\' | translate}}</th> \
		                                      <th class = "bp-text-uppercase">{{\'Last_modified\' | translate}}</th> \
		                                      <th class = "bp-text-uppercase ">{{\'Label_Source\' | translate}}</th> \
		                                      <th class = "bp-text-uppercase"></th> \
		                                  </tr> \
		                               </thead> \
		                               <tbody> \
		                                  <tr id="form{{form.Id}}Id" class="bp-expanded-deletable-div-transition" ng-repeat="form in formList"> \
		                                      <td></td> \
		                                      <td> \
		                                          <div class="liItemDesc_setTextEllipsis bp-first-letter-capitalize"> \
		                                             <a class="bp-blue-font H300 display-flex-element" ng-click="printDocumentAction({docUrl: form.AttachmentURL})"> \
														<i ng-if="form.IsManualUpload" ng-include="trustImageSrc(\'user\')"  class="manualUpload bp-blue3384ff bp-pointer-cursor"></i><span class="setTextEllipsis">{{form.FormName}}</span> \
		                                              </a> \
		                                              <span>{{form.Description}}</span> \
		                                          </div> \
		                                       </td> \
		                                      <td > \
		                                          <span>{{form.CreatedDate}}</span> \
		                                      </td> \
		                                      <td > \
		                                          <span>{{form.ModifiedDate}}</span> \
		                                      </td> \
		                                      <td class=" bp-first-letter-capitalize"> \
		                                          <span>{{form.Source}}</span> \
		                                      </td> \
		                                      <td class="partInvIconAdjustment"> \
												<div class = "pull-right"> \
		                                              <span data-toggle="tooltip" title="Print" ng-if="!false"> \
		                                                  <i ng-click="printDocumentAction({docUrl: form.AttachmentURL, coFormId: form.Id, isEditable: form.IsEditable, formEditConfig: form.FormEditConfig, editModalName: form.EditModalName})" ng-include="trustImageSrc(\'print\')" class="print-icon-fill blue_00A3DB bp-pointer-cursor"></i> \
		                                              </span> \
	                                                  <span data-toggle="tooltip" title="Delete" ng-if="!false"> \
	                                                      <i ng-include="trustImageSrc(\'trash_filled\')" ng-click="deleteFormAction({formId: form.Id})" ng-if="!form.IsRequired" class="icon_fill_blue bp-pointer-cursor LIDeleteBtn"></i> \
	                                                  </span> \
		                                         </div> \
		                                      </td> \
		                                  </tr> \
		                               </tbody> \
		                           </table> \
		                       </div> \
							  <div class="search-entity-wrapper" ng-if="activeFormCount > 0 && activeForms.length != activeFormCount"> \
								<button class="bp-btn bp-btn-normal" ng-click="addFormAction();">{{\'Add_forms\' | translate}}</button> \
							  </div> \
		                       <!-- End: Document - Form Section --> \
								<!-- Start: Document - Attachments Section --> \
				                <div class="table-responsive f-iTable document-table" ng-class="{\'PB67\' : isCoClosed , \'PB10\' : !attachmentList.length}"> \
				                     <p class="search-entity-text H400">{{\'Attachments\' | translate}}</p> \
				                     <table class = "bp-editable-table dfFIProducttable SOJobItemsGrid" ng-if="attachmentList.length"> \
				                           <col width="5%"/> \
				                         <col width="30%"/> \
										<col width="37%"/> \
				                         <col width="18%"/> \
				                         <col width="10%"/> \
				                         <thead> \
				                             <tr> \
				                                <th></th> \
												  <th class = "bp-text-uppercase">{{\'Name\' | translate}}</th> \
												  <th class = "bp-text-uppercase ">{{\'Description\' | translate}}</th> \
												  <th class = "bp-text-uppercase ">{{\'Date_added\' | translate}}</th> \
				                                <th class = "bp-text-uppercase"></th> \
				                            </tr> \
				                         </thead> \
				                         <tbody> \
				                            <tr id="attachment{{attachment.Id}}Id" class="bp-expanded-deletable-div-transition" ng-repeat="attachment in attachmentList"> \
				                                 <td></td> \
				                                 <td> \
				                                     <div class="liItemDesc_setTextEllipsis"> \
				                                         <a class="bp-blue-font H300 display-flex-element" target = "_blank" href="{{attachment.AttachmentURL}}">{{attachment.Name}} </a> \
				                                     </div> \
				                                  </td> \
				                                 <td> \
														<span>{{attachment.Description}}</span> \
				                                 </td> \
				                                 <td> \
				                                     <span>{{attachment.CreatedDate}}</span> \
				                                 </td> \
				                                 <td class="partInvIconAdjustment"> \
				                                     <div class = "pull-right"> \
				                                         <span data-toggle="tooltip" title="Print" ng-if="!false"> \
				                                             <i ng-include="trustImageSrc(\'print\')" ng-click="printDocumentAction({docUrl: attachment.AttachmentURL})" class="print-icon-fill blue_00A3DB bp-pointer-cursor"></i> \
				                                         </span> \
														<span data-toggle="tooltip" title="Delete" ng-if="!false"> \
											                <i ng-include="trustImageSrc(\'trash_filled\')" ng-click="deleteAttachmentAction({attachmentId: attachment.Id})" class="icon_fill_blue bp-pointer-cursor LIDeleteBtn"></i> \
											            </span> \
				                                      </div> \
				                                 </td> \
				                             </tr> \
				                         </tbody> \
				                     </table> \
				                 </div> \
								<droplet class ="" ng-model="attachmentFileUploadInterfaceModal"> \
					           		<div class="search-entity-wrapper browse_but"> \
										<droplet-upload-single ng-model="attachmentFileUploadInterfaceModal" ng-click="setAddAttachmentData()"> \
						                </droplet-upload-single> \
					                     <button class="bp-btn bp-btn-normal">{{\'Attach_Files\' | translate}}</button> \
					                 </div> \
					            </droplet> \
								  <!-- End: Document - Attachments Section --> \
				              </div> \
				         </div> \
				     </div> \
						',
			
			
			link : function (scope, el, attrs) {
				scope.ApplicationImagePath = $Global.ApplicationImagePath;
                scope.trustImageSrc = function(imageName) {
                	return $sce.trustAsResourceUrl(scope.ApplicationImagePath + '/Icons/' + imageName + '.svg');
                }
			}
		};
    }]);
});   