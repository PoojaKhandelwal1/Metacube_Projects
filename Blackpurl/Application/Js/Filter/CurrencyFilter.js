define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
    Routing_AppJs_PK.filter('CurrencyFilter', function () {
        return function (value, fixedVal) {
            return value.toFixed(fixedVal);
        };
    });
});