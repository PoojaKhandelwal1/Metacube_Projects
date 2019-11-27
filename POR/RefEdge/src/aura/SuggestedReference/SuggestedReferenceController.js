({
	doInit : function(component, event, helper) {
        
        // Prepare the action to load account record
        var action = component.get("c.opportunityStageChange");
        action.setParams({"oppid": component.get("v.recordId")});
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnedResult = response.getReturnValue();
                
                if (returnedResult.length == 4) {   
                    component.set("v.isVisible", returnedResult[0].substring(returnedResult[0].indexOf("@@")+2,returnedResult[0].length)); 
                    component.set("v.messageContent", returnedResult[1].substring(returnedResult[1].indexOf("@@")+2,returnedResult[1].length));
                    component.set("v.messageDisplay", returnedResult[2].substring(returnedResult[2].indexOf("@@")+2,returnedResult[2].length));
                    component.set("v.toShowBlock", returnedResult[3].substring(returnedResult[3].indexOf("@@")+2,returnedResult[3].length)); 
                } 
            } else {
                console.log('Problem response state: ' + state);
            }
        });
        $A.enqueueAction(action);
     },
    
    cancelbtn : function(component, event, helper) {
    	component.set("v.isVisible", false);
	},
    goToNewPage: function(component, event, helper) {
        var namespace = '';
        var action = component.get("c.nameSpace");
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                namespace = response.getReturnValue();
                console.log(response.getReturnValue());
            } else {
                namespace = '';
            }
            var recordId = component.get("v.recordId");
            component.set("v.isVisible", false);
            var redirectTo = component.get("v.toShowBlock");
            var urlEvent = $A.get("e.force:navigateToURL");
            
            //	Condition where to redirect
            if (redirectTo == 'Both') {
                urlEvent.setParams({
                    "url":'/apex/' + namespace + 'RfSearchLightning?opportunityId='+recordId+'&forAccount=false&forContent=false&PreFilter=false&SF1=false',
                    "isredirect": "true"
                });
            } else if (redirectTo == 'Account') {
                urlEvent.setParams({
                    "url":'/apex/' + namespace + 'RfSearchLightning?opportunityId='+recordId+'&forAccount=true&forContent=false&PreFilter=false&SF1=false',
                    "isredirect": "true"
                });
            } else if(redirectTo == 'Content') {
                urlEvent.setParams({
                    "url":'/apex/' + namespace + 'RfSearchLightning?opportunityId='+recordId+'&forAccount=false&forContent=true&PreFilter=false&SF1=false',
                    "isredirect": "true"
                });
            }
            urlEvent.fire(); 
        });
        $A.enqueueAction(action);
    }
})