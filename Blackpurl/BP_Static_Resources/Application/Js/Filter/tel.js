define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
    Routing_AppJs_PK.filter('tel', [function () {
        return function (tel) {
            return formatTel(tel);
        };
    }]);
});