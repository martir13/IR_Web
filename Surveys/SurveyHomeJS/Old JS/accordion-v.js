// JavaScript Document
$(function(){
(function($) {
	var bodyPanels = $('#body .accordion > dd').hide();
	var bodyTitles = $('#body .accordion > dt > a');
	$('#body .accordion > dt > a').addClass("accordion-closed");
	$('#body .accordion > dt > a').click(function() {
		$this = $(this);
		$target = $this.parent().next();

		//	Allow only one open at a time
		/*if (!$target.hasClass('active')) {
			bodyPanels.removeClass('active').slideUp(); // Close all the open panels
			bodyTitles.removeClass("accordion-open").addClass("accordion-closed"); // Set all the panel titles to closed
			$target.addClass('active').slideDown(); // Open the targeted panel
			$this.removeClass("accordion-closed").addClass("accordion-open"); // Set the targeted panel title to open
		} else {
			$this.removeClass("accordion-open").addClass("accordion-closed");
			bodyPanels.removeClass('active').slideUp();
		}*/

		//	Allow multiple open at a time
		if (!$target.hasClass('active')) {
		//	bodyPanels.removeClass('active').slideUp(); // Close all the open panels
		//	bodyTitles.removeClass("accordion-open").addClass("accordion-closed"); // Set all the panel titles to closed
			$target.addClass('active').slideDown(); // Open the targeted panel
			$this.removeClass("accordion-closed").addClass("accordion-open"); // Set the targeted panel title to open
		} else {
			$this.removeClass("accordion-open").addClass("accordion-closed");
			$target.removeClass('active').slideUp();
		}

		return false;
	});
	if ($(window).width() < 480)	{
		var footerPanels = $('#footer-holder .accordion > dd').hide();
		$('#footer-holder .accordion > dt > a > h4').addClass("accordion-closed");
		$('#footer-holder .accordion > dt > a').click(function() {
			$this = $(this);
			$target = $this.parent().next();
			if (!$target.hasClass('active')) {
				$target.addClass('active').slideDown();
				$target = $this.closest();
				$target = $this.children();
				$target.removeClass("accordion-closed").addClass("accordion-open");
			} else {
				$target.removeClass('active').slideUp();
				$target = $this.closest();
				$target = $this.children();
				$target.removeClass("accordion-open").addClass("accordion-closed");
			}
			return false;
		});
	} else {
		// The window is wider than 700 so
		$('#footer-holder .accordion > dt > a').attr("href", "javascript:void(0)");
	}
})(jQuery);
});