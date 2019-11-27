angular.module('hopscotchTour', ['ngHopscotch']);

angular.module('hopscotchTour').directive('hopscotchTour',['HSTour', function(HSTour) {
		return {
		    restrict: 'AE',
		    link: function(scope, element, attr) {

		      
		      var tourConfig = {
		        id: 'angular-hopscotch-test',
		          steps: [
		            {
		              title: 'Begin your search',
		              content: 'Some content about the search header',
		              target: document.querySelector('.sell'),
		              placement: 'bottom'
		            },
		            {
		              title: 'Refind your results',
		              content: 'Here is where I put my content.',
		              target: document.querySelector('.Order'),
		              placement: 'bottom'
		            },
		            {
			              title: 'Schedule',
			              content: 'Here is where Schedule.',
			              target: document.querySelector('.Schedule'),
			              placement: 'bottom'
			            },
			            {
				              title: 'Reporting',
				              content: 'Here is where Reporting.',
				              target: document.querySelector('.Reporting'),
				              placement: 'bottom'
				            }
		          ]
		      };
		     
		      var tour = new HSTour(tourConfig);
		      
		      tour.start();
		    }
		};
}
]);

/*angular.module('ngHopscotch', ['hopscotchTour']);*/
