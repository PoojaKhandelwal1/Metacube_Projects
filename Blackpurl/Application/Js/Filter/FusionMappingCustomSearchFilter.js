define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
	Routing_AppJs_PK.filter('searchFilter', function () {
        return function (GLAccountList, searchString) {
            var selectedAccount = [];
            if(!searchString) {
            	return GLAccountList;
            } else {
            	for(i=0;i<GLAccountList.length;i++){
                	if ((GLAccountList[i].AccountName.toLowerCase()).indexOf(searchString.toLowerCase()) != -1 || (GLAccountList[i].AccountNumber && (GLAccountList[i].AccountNumber).indexOf(searchString) != -1)) {
                		selectedAccount.push(GLAccountList[i]);
                    }
                }
            }
            return selectedAccount;
        	};
    });
});