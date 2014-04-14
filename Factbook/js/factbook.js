$("document").ready(function() {
	//Init the tabs
	$('#tab-container').easytabs();

	$( ".menuLinks" ).click(function( event ) {
		event.preventDefault();

		//Get the ID and make it a class
		var classLink = "." + this.id;
		//Get the ID of the currently active element
		var oldClass = "." + $('.active').closest('a').attr("id");

		//Remove active class
		$( ".menuLinks li" ).each(function() {
			$(this).removeClass('active');
		});

		//add active class to the currently selected element
		$(this).find('li').each(function() {
			$(this).addClass('active');
		});

		//hide the current content
		$(oldClass).fadeOut('fast', function() {
			//Show the correct data
			$( classLink ).fadeIn('fast');
		})

	});

	$( ".menuLinkss .active" ).click(function( event ) {
		event.preventDefault();
	});

	$('a[href$="#tabs1-WWall"]').click(function(event) {
		event.preventDefault();
	});

//End Document.Ready
});