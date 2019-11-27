define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {

    Routing_AppJs_PK.filter('customFilter', [function (filterFilter) {
        return function (input, exclude) {
            var isExcludeVal = 0;
            var result = [];
            for (i = 0; i < input.length; i++) {
                var isExcludeVal = 0;
                for (j = 0; j < exclude.length; j++) {
                    if (angular.equals(input[i].label, exclude[j]) || input[i].label == 'None') {
                        var isExcludeVal = 1;
                        break;
                    }
                }
                if (isExcludeVal == 0) {
                    result.push(input[i]);
                }
            }
            return result;
        };
    }]);
});