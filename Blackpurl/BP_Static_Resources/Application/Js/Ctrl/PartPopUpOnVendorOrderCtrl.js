define(['Routing_AppJs_PK', 'PartPopUpOnVendorOrderServices'], function (Routing_AppJs_PK, PartPopUpOnVendorOrderServices) {

    Routing_AppJs_PK.controller("PartPopUpOnVendorOrderCtrl", ['$q', '$scope', '$rootScope', '$stateParams', '$state', 'partOrderReceivingService', function ($q, $scope, $rootScope, $stateParams, $state, partOrderReceivingService) {
        if ($scope.PartPopUp == undefined) {
            $scope.PartPopUp = {};
            $scope.PartPopUp.partModel = {};
        }
        $scope.$on('PartPopUpEvent', function (event, partId) {
            $scope.PartPopUp.partModel = {};
            jsonRectangles = {};
            $scope.PartPopUp.loadData(partId);
            angular.element('.partPopUp-flyout').scrollTop = 0;
        });
        $scope.PartPopUp.hidePopUp = function () {
            angular.element('.Vendor-Order-Part-Popup').hide();
        }
        $scope.PartPopUp.openpartpopup = function () {
            angular.element('.PartPopupOnVenderOrder').show();
        }
        $scope.PartPopUp.loadData = function (partId) {
            partOrderReceivingService.getPartRecord(partId).then(function (partRecord) {
                if (partRecord.PartDetailRec != undefined) {
                    $scope.PartPopUp.partModel = partRecord.PartDetailRec;
                    $scope.PartPopUp.loadChart();
                }
            }, function (errorSearchResult) {
                $scope.VORModel.OverlayInfo = errorSearchResult;
            });
        }
        $scope.PartPopUp.loadChart = function () {
            $scope.PartPopUp.partModel.isZeroTotalValue = false
            d3.selectAll(".PartPopupOnVenderOrder svg").remove();
            var commited = $scope.PartPopUp.partModel.QtyCommited;
            var available = $scope.PartPopUp.partModel.QtyAvailable;
            var onorder = $scope.PartPopUp.partModel.QtyOnOrder;
            var instocktotal = $scope.PartPopUp.partModel.QtyCommited + $scope.PartPopUp.partModel.QtyAvailable;
            var total_instock = commited + available;
            var max = 0;
            if (commited < 0) {
                if (Math.abs(commited) > max)
                    max = Math.abs(commited);
            }
            if (available < 0) {
                if (Math.abs(available) > max)
                    max = Math.abs(available);
            }
            if (onorder < 0) {
                if (Math.abs(onorder) > max)
                    max = Math.abs(onorder);
            }
            if (total_instock < 0) {
                if (Math.abs(total_instock) > max)
                    max = Math.abs(total_instock);
            }
            available = available + max;
            commited = commited + max;
            onorder = onorder + max;
            total_instock = total_instock + max;
            var jsonRectangles = [{
                    "color": "#414449",
                    "commited": commited
                },
                {
                    "color": "#727983",
                    "available": available
                },
                {
                    "color": "#939CA9",
                    "onorder": onorder
                }
            ];
            var total_value = jsonRectangles[0].commited + jsonRectangles[1].available + jsonRectangles[2].onorder;
            if (total_value != 0) {
                jsonRectangles[0].commited = ((jsonRectangles[0].commited) / total_value) * 100
                jsonRectangles[1].available = ((jsonRectangles[1].available) / total_value) * 100
                jsonRectangles[2].onorder = ((jsonRectangles[2].onorder) / total_value) * 100
                var ft1 = (580 * jsonRectangles[0].commited) / 100;
                var ft2 = (580 * jsonRectangles[1].available) / 100;
                var ft3 = (580 * jsonRectangles[2].onorder) / 100;
                var commitedName = "COMMITED:";
                var availablename = "AVAILABLE:";
                var onordername = "ON ORDER:";
                var inStock = "INSTOCK:";
                var instock_tringle = ft1 + ft2;
                var jsonRectangles1 = [{
                    "color": "#71BF3E",
                    "commited": instock_tringle
                }];

                var textsvg = d3.select('#wrapper')
                    .append('svg')
                    .data(jsonRectangles)
                    .attr({
                        'width': 580 + "px",
                        'height': 45 + "px"
                    });

                if (jsonRectangles[0].commited >= 0) {

                    textsvg.append("text").attr("dx", function (d, i) {
                            var p;
                            if (ft1 < 100) {
                                p = 0;
                            } else if ((580 - ft1) > 500) {
                                p = 450;
                            } else {
                                p = (ft1 / 2) - 50;
                            }
                            return p;
                        })
                        .attr("dy", 25)
                        .style('fill', "#414449")
                        .text(function (d) {
                            return commitedName
                        });

                    textsvg.append("text").attr("dx", function (d, i) {
                            var p;
                            if (ft1 < 100) {
                                p = 0;
                            } else if ((580 - ft1) > 500) {
                                p = 450;
                            } else {
                                p = (ft1 / 2) - 50;
                            }
                            return (p + 85);
                        })
                        .attr("dy", 25)
                        .attr("font-weight", "bold")
                        .style('fill', "#414449")
                        .text(function (d) {
                            return $scope.PartPopUp.partModel.QtyCommited
                        });

                }

                if (jsonRectangles[1].available >= 0) {

                    textsvg.append("text")
                        .attr("dx", function (d, i) {
                            if ((ft2 <= 50) && (ft1 > 530)) {
                                p = 450;
                            } else if ((ft1 <= 530) && (ft1 > 50)) {
                                p = ft1 + (ft2 / 2) - 50;
                            } else if ((ft2 <= 100) && (ft1 < 50)) {
                                p = 0;
                            } else {
                                p = ft1 + (ft2 / 2) - 50;
                            }
                            return p;
                        })
                        .attr("dy", 45)
                        .style('fill', "#727983")
                        .text(function (d) {
                            return availablename
                        });

                    textsvg.append("text").attr("dx", function (d, i) {
                            var p;
                            if ((ft2 <= 50) && (ft1 > 530)) {
                                p = 450;
                            } else if ((ft1 <= 530) && (ft1 > 50)) {
                                p = ft1 + (ft2 / 2) - 50;
                            } else if ((ft2 <= 100) && (ft1 < 50)) {
                                p = 0;
                            } else {
                                p = ft1 + (ft2 / 2) - 50;
                            }
                            return (p + 80);
                        })
                        .attr("dy", 45)
                        .attr("font-weight", "bold")
                        .style('fill', "#727983")
                        .text(function (d) {
                            return $scope.PartPopUp.partModel.QtyAvailable
                        });

                }
                if (jsonRectangles[2].onorder >= 0) {


                    textsvg.append("text")
                        .attr("dx", function (d, i) {
                            if ((ft1 + ft2) >= 480) {
                                p = 450;
                            } else if (((ft1 + ft2) < 480) && ((ft1 + ft2) > 50)) {
                                p = ft1 + ft2 + (ft3 / 2) - 50;
                            } else if ((ft1 + ft2) <= 50) {
                                p = ft1 + ft2 + (ft3 / 2) - 50;
                            }
                            return p;
                        })
                        .attr("dy", 30)
                        .style('fill', "#939CA9")
                        .text(function (d) {
                            return onordername
                        });


                    textsvg.append("text").attr("dx", function (d, i) {
                            var p;
                            if ((ft1 + ft2) >= 480) {
                                p = 450;
                            } else if (((ft1 + ft2) < 480) && ((ft1 + ft2) > 50)) {
                                p = ft1 + ft2 + (ft3 / 2) - 50;
                            } else if ((ft1 + ft2) <= 50) {
                                p = ft1 + ft2 + (ft3 / 2) - 50;
                            }
                            return (p + 85);
                        })
                        .attr("dy", 30)
                        .attr("font-weight", "bold")
                        .style('fill', "#939CA9")
                        .text(function (d) {
                            return $scope.PartPopUp.partModel.QtyOnOrder
                        });

                }


                var svg = d3.select('#wrapper')
                    .append('svg')
                    .attr({
                        'width': 580 + "px",
                        'height': 25 + "px"
                    });

                if (jsonRectangles[0].commited >= 0) {
                    var arc = d3.svg.symbol().type('triangle-up')
                        .size(function (d) {
                            return scale(d);
                        });
                    var data = [.5];
                    var scale = d3.scale.linear()
                        .domain([1, 8])
                        .range([100, 580]);
                    var group = svg.append('g');

                    if (ft1 != 0)
                        group.attr('transform', 'translate(' + ft1 / 2 + ',' + 15 + ')');
                    else
                        group.attr('transform', 'translate(' + (ft1 / 2 + 5) + ',' + 15 + ')');

                    var line = group.selectAll('path')
                        .data(data)
                        .enter()
                        .append('path')
                        .attr('d', arc)
                        .attr('stroke', '#FFF')
                        .style("fill", "#414449")
                        .attr('stroke-width', 1)
                        .attr('transform', function (d, i) {
                            return "translate(" + (i * 38) + "," + (5) + ")";
                        });
                }

                if (jsonRectangles[1].available >= 0) {
                    var arc = d3.svg.symbol().type('triangle-up')
                        .size(function (d) {
                            return scale(d);
                        });
                    var data = [.5];
                    var scale = d3.scale.linear()
                        .domain([1, 8])
                        .range([100, 580]);
                    var group = svg.append('g')
                        .attr('transform', 'translate(' + (ft1 + (ft2 / 2)) + ',' + 15 + ')');
                    var line = group.selectAll('path')
                        .data(data)
                        .enter()
                        .append('path')
                        .attr('d', arc)
                        .attr('stroke', '#FFF')
                        .style("fill", "#727983")
                        .attr('stroke-width', 1)
                        .attr('transform', function (d, i) {
                            return "translate(" + (i * 38) + "," + (5) + ")";
                        });
                }

                if (jsonRectangles[2].onorder >= 0) {
                    var arc = d3.svg.symbol().type('triangle-up')
                        .size(function (d) {
                            return scale(d);
                        });
                    var data = [.5];
                    var scale = d3.scale.linear()
                        .domain([1, 8])
                        .range([100, 580]);
                    var group = svg.append('g');

                    if (ft3 != 0)
                        group.attr('transform', 'translate(' + (ft1 + ft2 + (ft3 / 2)) + ',' + 15 + ')');
                    else
                        group.attr('transform', 'translate(' + (ft1 + ft2 + (ft3 / 2) - 5) + ',' + 15 + ')');

                    var line = group.selectAll('path')
                        .data(data)
                        .enter()
                        .append('path')
                        .attr('d', arc)
                        .attr('stroke', '#FFF')
                        .style("fill", "#939CA9")
                        .attr('stroke-width', 1)
                        .attr('transform', function (d, i) {
                            return "translate(" + (i * 38) + "," + (5) + ")";
                        });
                }

                var svgContainer = d3.select("#wrapper").append("svg")
                    .attr("width", 580 + "px")
                    .attr("height", 36 + "px")
                    .attr("class", "rectanglecont")
                var rectangles = svgContainer.selectAll("rect")
                    .data(jsonRectangles)
                    .enter()
                    .append("rect");
                rectangles.append("text")
                    .attr("x", function (d) {
                        return 100
                    })
                    .attr("y", 200)
                    .attr("dy", ".35em")
                    .attr('fill', 'red')
                var rectangleAttributes = rectangles
                    .attr("x", function (d, i) {
                        if (i == 0) {
                            d.x = 0;
                        }
                        if (i == 1) {
                            d.x = (((jsonRectangles[i - 1].commited) * 580) / 100);
                        }
                        if (i == 2) {
                            d.x = (((jsonRectangles[i - 2].commited) * 580) / 100) + (((jsonRectangles[i - 1].available) * 580) / 100);
                        }
                        if (i == 3) {
                            d.x = (((jsonRectangles[i - 3].commited) * 580) / 100) + (((jsonRectangles

                                [i - 2].available) * 580) / 100) + (((jsonRectangles[i - 1].onorder) * 580) / 100);
                        }

                        return d.x;
                    })
                    .attr("y", function (d) {
                        return 10;
                    })
                    .attr("height", function (d) {
                        return 50;
                    })
                    .attr("width", function (d, i) {
                        if (i == 0) {
                            d.width = d.commited + "%";
                        }
                        if (i == 1) {
                            d.width = d.available + "%";
                        }
                        if (i == 2) {
                            d.width = d.onorder + "%";
                        }
                        return d.width;
                    })
                    .style("fill", function (d) {
                        return d.color;
                    });

                var svgContainer1 = d3.select("#wrapper1").append("svg")
                    .attr("width", 580 + "px")
                    .attr("height", 36 + "px")
                    .attr("class", "rectanglecont1")
                var rectangles = svgContainer1.selectAll("rect")
                    .data(jsonRectangles1)
                    .enter()
                    .append("rect");
                var rectangleAttributes = rectangles
                    .attr("x", function (d) {
                        d.x = 0;
                        return d.x;
                    })
                    .attr("y", function (d) {
                        return 10;
                    })
                    .attr("height", function (d) {
                        return 50;
                    })
                    .attr("width", function (d) {
                        d.width = d.commited + "%";
                        return d.width;
                    })
                    .style("fill", function (d) {
                        return d.color;
                    });

                var svg = d3.select('#wrapper1')
                    .append('svg')
                    .attr({
                        'width': 580 + "px",
                        'height': 30 + "px"
                    })
                    .attr("class", "inorder_tringle");

                var arc = d3.svg.symbol().type('triangle-down')
                    .size(function (d) {
                        return scale(d);
                    });
                var data = [.5];
                var scale = d3.scale.linear()
                    .domain([1, 8])
                    .range([100, 580]);
                var group = svg.append('g')
                    .attr('transform', 'translate(' + ((instock_tringle) / 2) + ',' + 5 + ')');
                var line = group.selectAll('path')
                    .data(data)
                    .enter()
                    .append('path')
                    .attr('d', arc)
                    .attr('stroke', "#71BF3E")
                    .style("fill", "#71BF3E")
                    .attr('stroke-width', 1)
                    .attr('transform', function (d, i) {
                        return "translate(" + (i * 38) + "," + (10) + ")";
                    });
                var textsvg = d3.select('#wrapper1')
                    .append('svg')
                    .data(jsonRectangles)
                    .attr("class", "instocktext")
                    .attr({
                        'width': 580 + "px",
                        'height': 30 + "px"
                    });

                if (instock_tringle >= 0) {

                    textsvg.append("text")
                        .attr("dx", function (d, i) {
                            var p;

                            if (instock_tringle < 60) {
                                p = 0;
                            } else {
                                p = ((instock_tringle) / 2) - 40;
                            }
                            return p;
                        })
                        .attr("dy", 30)
                        .style('fill', "#71BF3E")
                        .text(function (d) {
                            return inStock
                        });


                    textsvg.append("text").attr("dx", function (d, i) {
                            var p;
                            if (instock_tringle < 60) {
                                p = 0;
                            } else {
                                p = ((instock_tringle) / 2) - 40;
                            }
                            return (p + 70);
                        })
                        .attr("dy", 30)
                        .attr("font-weight", "bold")
                        .style('fill', "#71BF3E")
                        .text(function (d) {
                            return instocktotal
                        });

                }
            } else {
                $scope.PartPopUp.partModel.isZeroTotalValue = true;
            }
        }
    }]);
});