// document-ready.js
// Embry-Riddle Aeronautical University

$(document).ready(function() {
	$('*').removeClass("hspan_12");
	$('.perc-region').css("min-height", "0px");
		
	//Meganizr add click functionality
	$('.meganizr').addClass('mzr-js-click').removeClass('mzr-slide mzr-fade');
	$('.mzr-js-click > li.mzr-drop > a').on('click', function() {
		$('.mzr-js-click > li.mzr-drop > a').removeClass('mzr-js-arrow');
		$('.mzr-js-click > li.mzr-drop > div, .mzr-js-click > li.mzr-drop > ul, .mzr-js-click > li > ul li > ul').fadeOut();
		$(this).addClass('mzr-js-arrow');
		$(this).siblings('div, ul').fadeIn();
	});
	$('.mzr-js-click > li > ul li.mzr-drop > a').on('click', function() {
		$('.mzr-js-click > li.mzr-drop > div').fadeOut();
		$(this).siblings('ul').fadeIn();
	});
	$(document).on('click', function() {
		$('.mzr-js-click > li.mzr-drop > div, .mzr-js-click > li.mzr-drop > ul, .mzr-js-click > li > ul li > ul').fadeOut();
		$('.mzr-js-click > li.mzr-drop > a').removeClass('mzr-js-arrow');
	});
	$('.mzr-js-click').on('click', function(event) {
		event.stopPropagation();
	});
	
	// Footer Event Tabs
	$(".tab_content").hide();
	$("#footer-title-events > ul.tabs li:first").addClass("active").show(); 
	$(".tab_content:first").show(); 
	//On Click Event
	$("#footer-title-events > ul.tabs li").click(function() {
		$("#footer-title-events > ul.tabs li").removeClass("active");
		$(this).addClass("active"); 
		$(".tab_content").hide(); 
		var activeTab = $(this).find("a").attr("href"); 
		$(activeTab).fadeIn();
		return false;
	});
	
	$('#location').resize(function(){
		var maxHeight = 0;
		var locationHeight;
		var resourcesHeight;
		var eventsHeight;
			$('#location').height('auto');
			$('#resources').height('auto');
			$('#events').height('auto');
					
		if ($(window).width() > 768)	{
			locationHeight = $('#location').height();
			resourcesHeight = $('#resources').height();
			eventsHeight = $('#events').height();
			if (locationHeight > resourcesHeight)	{
				maxHeight = locationHeight;
				if (locationHeight > eventsHeight)	{
					maxHeight = locationHeight;
				} else {
					maxHeight = eventsHeight;
				}
			} else {
				if (resourcesHeight > eventsHeight)	{
					maxHeight = resourcesHeight
				} else {
					maxHeight = eventsHeight; 
				}
			}
			$('#location').height(maxHeight + 10 + 'px');
			$('#resources').height(maxHeight + 10 + 'px');
			$('#events').height(maxHeight + 10 + 'px');
		}

		if ($(window).width() <= 768 && $(window).width() >= 481)	{
			locationHeight = $('#location').height();
			resourcesHeight = $('#resources').height();
			if (locationHeight > resourcesHeight)	{
				maxHeight = locationHeight;
			} else {
				maxHeight = resourcesHeight;
			}
			$('#location').height(maxHeight + 10 + 'px');
			$('#resources').height(maxHeight + 10 + 'px');
		}
	});
	$('#location').resize();
});