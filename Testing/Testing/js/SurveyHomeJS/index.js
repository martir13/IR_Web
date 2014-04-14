//var globalurl = 'http://ir.erau.edu/Surveys/GSS/PDF/Overall Graduating Students Report 2013.pdf&embedded=true';
//var SIGlobalPDF = 'GSS_DB_SP2012.pdf';

$(document).ready(function(){
        /*//open popup
        $("#pop").click(function(){
          $("#overlay_form").fadeIn(1000);
          positionPopup();
        });

        //close popup
        $("#close").click(function(){
            $("#overlay_form").fadeOut(500);

        });

        //open popup - For 2nd popup ***************************
        $("#pop1").click(function(){
          $("#overlay_form1").fadeIn(1000);
          positionPopup1();
        });

        //close popup
        $("#close1").click(function(){
            $("#overlay_form1").fadeOut(500);
        });

        //open popup - For 3rd popup ***************************
        $("#pop2").click(function(){
          $("#overlay_form2").fadeIn(1000);
          positionPopup2();
        });

        //close popup
        $("#close2").click(function(){
            $("#overlay_form2").fadeOut(500);
        });

        //open popup - For 4th popup ***************************
        $("#pop3").click(function(){
          $("#overlay_form3").fadeIn(1000);
          positionPopup3();
        });

        //close popup
        $("#close3").click(function(){
            $("#overlay_form3").fadeOut(500);
        });

        //open popup - For 5th popup ***************************
        $("#pop4").click(function(){
          $("#overlay_form4").fadeIn(1000);
          positionPopup4();
        });

        //close popup
        $("#close4").click(function(){
            $("#overlay_form4").fadeOut(500);
        });

        //open popup - For 6th popup ***************************
        $("#pop5").click(function(){
          $("#overlay_form5").fadeIn(1000);
          positionPopup5();
        });

        //close popup
        $("#close5").click(function(){
            $("#overlay_form5").fadeOut(500);
        });*/
       
       jQuery(window).on("hashchange", function () {
		    window.scrollTo(window.scrollX, window.scrollY - 50);
		});

        //Script for Breadcrumb Initialization
        jQuery("#breadCrumb3").jBreadCrumb();

        
      });/* END document.ready function */
		
        //Script to toggle hidden content in slider text.
        $("#readMore").click(function(){
          $("#hiddenContent").toggle('slow');

        var text = $('#readMore').text();
        $('#readMore').text(text == "Read More" ? "Read Less" : "Read More");
      });


/* Start function for the archives widget */
function updatePDF(event, pdfName, id, survey) {
	if(event.preventDefault) event.preventDefault();
	
	var base_url = window.location.hostname + window.location.pathname;
	var pathArray = window.location.pathname.split( '/' );
	var newPathname = "http://" + window.location.hostname;
		for ( i = 0; i < pathArray.length-1; i++ ) {
  		newPathname += pathArray[i];
		newPathname += "/";
	}
	
	var downLoadLinkURL = newPathname + 'PDF/' + pdfName;
    var pdfURL = newPathname + 'PDF/' + pdfName + '&embedded=true';
    
    //globalurl = pdfURL;
	
	var el = '#' + id;
	//The classes
	var iFrame = el + ' .widgetIframe';
	var embed = el + ' .embedLink';
	var fullscreen = el + ' .fullScreenLink';
	var download = el + ' .downloadLink';

	  //Update the main PDF area.
      $(iFrame).html('<iframe frameborder="0" src="http://docs.google.com/gview?url=' + pdfURL + '" style="width:100%; height:392px;"></iframe>');
      //Set the Full Screen Link
      $(fullscreen).html('<a target="_blank" href="http://docs.google.com/gview?url=' + pdfURL + '">Full Screen</a>');
      //Set the download link
      $(download).html('<a target="_blank" href="' + downLoadLinkURL + '">Download Full PDF</a>');
      //Set the embed link
      $(embed).attr("onclick", "openPop(event, '/" + pdfName + "', '" + survey + "')");
}

//functions to control the embed popups.
function openPop(e, pdf, survey) {
	e.preventDefault();
	//if pdf is not left blank, use it as the globalurl
	if (pdf !== undefined)
	{
		$("#overlay_form1").html('<h2>Embed the PDF </h2> <p>Copy the code below and paste it in an HTML editor to embed the PDF</p> <textarea rows="3" cols="50" onclick="this.focus();this.select()" readonly="readonly">&lt;iframe src="http://ir.erau.edu/Surveys/'+ survey + pdf + '&embedded=true" style="width:100%; height=1000px;"&gt;&lt;/iframe&gt;</textarea><a href="#" onclick="closePop(event)" id="close">Close</a>');
	}
	/*else
	{
    	$("#overlay_form1").html('<h2>Embed the PDF </h2> <p>Copy the code below and paste it in an HTML editor to embed the PDF</p> <textarea rows="3" cols="50" onclick="this.focus();this.select()" readonly="readonly">&lt;iframe src="' + globalurl + '" style="width:100%; height=1000px;"&gt;&lt;/iframe&gt;</textarea><a href="#" onclick="closePop(event)" id="close">Close</a>');
    }*/
    $("#overlay_form1").fadeIn(1000);
    $("#overlay_form1").css({
        left: ($(window).width() - $('#overlay_form').width()) / 3,
        top: ($(window).width() - $('#overlay_form').width()) / 7,
        position: 'absolute'
    });
    //Scroll to top
    $("html, body").animate({ scrollTop: 0 }, "fast");
}

/*$("#pop2").bind("click", function(e) {
	e.preventDefault();
    openPop(e, SIGlobalPDF); 
});*/

function closePop(e) {
	e.preventDefault();
    $("#overlay_form1").fadeOut(500);
}