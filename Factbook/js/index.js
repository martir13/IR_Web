// JavaScript Document

var globalfield;
var globalurl;
$("document").ready(function() {
    if (window.location.hash) {
        var hash = window.location.hash.substring(1); //Puts hash in variable, and removes the # character
        updatePDF(hash, 'PDF');
        // hash found
    } else {}
    //Apply the Greater Than class to all menu items that have children
    $('div#cssmenu ul li.has-sub ul li.has-sub').has('ul').each(function() {
        $(this).addClass('hasSubElements');
    });
    $('div#cssmenu ul li.has-sub ul li.has-sub').has('ul').click(function() {
        return false;
    });

    //Start script for the MegaMenu controls and settings:
    $('.megamenu').megaMenuReloaded({
        menu_speed_show : 300, // Time (in milliseconds) to show a drop down
        menu_speed_hide : 200, // Time (in milliseconds) to hide a drop down
        menu_speed_delay : 200, // Time (in milliseconds) before showing a drop down
        menu_effect : 'open_close_slide', // Drop down effect, choose between 'hover_fade', 'hover_slide', 'click_fade', 'click_slide', 'open_close_fade', 'open_close_slide'
        menu_easing : 'jswing', // Easing Effect : 'easeInQuad', 'easeInElastic', etc.
        menu_click_outside : 1, // Clicks outside the drop down close it (1 = true, 0 = false)
        menu_show_onload : 0, // Drop down to show on page load (type the number of the drop down, 0 for none)
        menubar_trigger : 0, // Show the menu trigger (button to show / hide the menu bar), only for the fixed version of the menu (1 = show, 0 = hide)
        menubar_hide : 0, // Hides the menu bar on load (1 = hide, 0 = show)
        menu_responsive : 1, // Enables mobile-specific script
        menu_carousel : 0, // Enable / disable carousel
        menu_carousel_groups : 0 // Number of groups of elements in the carousel
    });
    $('#megamenu_form').ajaxForm({target:'#alert'}); 

});

function updatePDF(pdfURL, title) {
    var base_url = window.location.hostname + window.location.pathname;
	var pathArray = window.location.pathname.split( '/' );
	var newPathname = "http://" + window.location.hostname;
		for ( i = 0; i < pathArray.length-1; i++ ) {
  		newPathname += pathArray[i];
		newPathname += "/";
	}
	
	
    var pdf_loc = newPathname + 'PDF/' + pdfURL + '.pdf&embedded=true';
    var download_pdf = 'http://' + base_url + 'PDF/' + pdfURL + '.pdf';
   $("#coverimg").css('display', 'none');
    window.location.hash = pdfURL;
    globalfield = title;
    globalurl = pdf_loc;
    newGoogleURL = "http://docs.google.com/viewer?url=" + pdf_loc;
    $("#submenu").html('<ul><li class="active"><a href="#"><span>Help</span></a></li><li><a id="download" href="' + download_pdf + '" target="_blank"><span>Download</span></a></li><li><a onclick="openPop()"><span>Embed</span></a></li><li><a id="fullscreen" href="http://docs.google.com/viewer?url=' + pdf_loc + '" target="_blank"><span>Full Screen</span></a></li></ul>');
    $("#submenu").show();
    //Update the main PDF area.
    $("#panel").html('<iframe frameborder="0" src="http://docs.google.com/viewer?url=' + pdf_loc + '" style="width:100%; height:600px;"></iframe>');
    // document.getElementById('panel').contentDocument.location.reload(true);
    return true;
}

function updateDOC(pdfURL, title) {
    var base_url = window.location.hostname + window.location.pathname;
    var pdf_loc = 'http://' + base_url + 'PDF/' + pdfURL + '.doc&embedded=true';
    var download_pdf = 'http://' + base_url + 'PDF/' + pdfURL + '.doc';
    $("#coverimg").css('display', 'none');
    window.location.hash = pdfURL;
    globalfield = title;
    globalurl = pdf_loc;
    newGoogleURL = "http://view.officeapps.live.com/op/view.aspx?src=" + pdf_loc;
    $("#submenu").html('<ul><li class="active"><a href="#"><span>Help</span></a></li><li><a id="download" href="' + download_pdf + '" target="_blank"><span>Download</span></a></li><li><a onclick="openPop()"><span>Embed</span></a></li><li><a id="fullscreen" href="http://view.officeapps.live.com/op/view.aspx?src=' + pdf_loc + '" target="_blank"><span>Full Screen</span></a></li></ul>');
    $("#submenu").show();
    //Update the main PDF area.
    $("#panel").html('<iframe frameborder="0" src="http://view.officeapps.live.com/op/view.aspx?src=' + pdf_loc + '" style="width:100%; height:600px;"></iframe>');
    document.getElementById('panel').contentDocument.location.reload(true);
    return true;
}

function openPop() {
    $("#overlay_form").html(" <h2>Embed the " + globalfield + " </h2> <p>Copy the code below and paste it in an HTML editor to embed the " + globalfield + "</p> <textarea rows='3' cols='50' onclick='this.focus();this.select()' readonly='readonly'>&lt;iframe src='" + globalurl + "' width='100%' height='1000px;'&gt;&lt;/iframe&gt;</textarea><a onclick='closePop()' id='close'>Close</a>");
    $("#overlay_form").fadeIn(1000);
    $("#overlay_form").css({
        left: ($(window).width() - $('#overlay_form').width()) / 3,
        top: ($(window).width() - $('#overlay_form').width()) / 7,
        position: 'absolute'
    });
}

function closePop() {
    $("#overlay_form").fadeOut(500);
}

/* Function to allow opening of new windows in MegaMenu */
function openNewTab(url) {
    window.open(url, '_blank');
    return false;
}

/* Function to load google map */
function loadMapIframe() {
    $("#contactForm").html("<iframe height='450px' width='600px' name='zoho-Requests' frameborder='0' scrolling='auto' src='http://creator.zoho.com/instrsch/ir-requests/form-embed/Requests/'></iframe>");
    $("#mapIframe").html('<iframe width="638" height="350" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=en&amp;geocode=&amp;q=erau+isb+annex+West+International+Speedway+Boulevard+Daytona+Beach,+FL+32114&amp;aq=&amp;sll=29.19634,-81.059575&amp;sspn=0.007221,0.009645&amp;ie=UTF8&amp;hq=erau+isb+annex&amp;hnear=W+International+Speedway+Blvd,+Daytona+Beach,+Florida+32114&amp;t=m&amp;ll=29.201285,-81.061034&amp;spn=0.013111,0.02738&amp;z=15&amp;iwloc=A&amp;output=embed"></iframe><br /><small><a href="https://maps.google.com/maps?f=q&amp;source=embed&amp;hl=en&amp;geocode=&amp;q=erau+isb+annex+West+International+Speedway+Boulevard+Daytona+Beach,+FL+32114&amp;aq=&amp;sll=29.19634,-81.059575&amp;sspn=0.007221,0.009645&amp;ie=UTF8&amp;hq=erau+isb+annex&amp;hnear=W+International+Speedway+Blvd,+Daytona+Beach,+Florida+32114&amp;t=m&amp;ll=29.201285,-81.061034&amp;spn=0.013111,0.02738&amp;z=15&amp;iwloc=A" style="color:#0000FF;text-align:left">View Larger Map</a></small>');
}