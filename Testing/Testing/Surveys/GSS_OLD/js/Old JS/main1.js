$(document).ready(function() {
//Function to make widgets on homepage bigger when submenu is clicked.

  //For Data Infographic Widget
  $("a#dataInfoLink").click(function (event) {
    event.preventDefault();

    //Hide all other widgets
    $("li#methodologyWidget, li#surveyInstrWidget, li#dataTablesWidget, div.hiddenContent, li#surveyInstrWidgetHidden").hide();

    //Hide the Accordion Slider
    $(".jAccordion-slidesWrapper, .jaccordion").slideUp("medium");

    //Show this particular widget in case it was hidden.
    $("li#dataInfographicWidget").show();

    //Resize the widgets containers to avoid blank space.
    $("div.bottomWidgets ul").css('height', '950px');
    $("li#dataInfographicWidget").css({'height' : '950px', 'width' : '100%', 'padding-left' : '0px'});

    //Add html.
    $("li#dataInfographicWidget").html('<div class="handle">Data Infographic</div><iframe src="http://docs.google.com/gview?url=http://irweb.erau.edu/Factbook/Alumni/Placement_Rates/PDF/AllMajorAssoc.pdf&embedded=true" style="width:100%; height:900px;" frameborder="0"></iframe>');
  });

  //For Methodology widget
  $("a#methodologyLink").click(function (event) {
    event.preventDefault();

    //Hide all other widgets
    $("li#dataInfographicWidget, li#surveyInstrWidget, li#dataTablesWidget, div.hiddenContent, li#surveyInstrWidgetHidden").hide();

    //Hide the Accordion Slider
    $(".jAccordion-slidesWrapper, .jaccordion").slideUp("medium");

    //Show this particular widget in case it was hidden.
    $("li#methodologyWidget").show();

    //Resize the widgets containers to avoid blank space.
    $("div.bottomWidgets ul").css('height', '950px');
    $("li#methodologyWidget").css({'height' : '950px', 'width' : '100%', 'padding-left' : '0px'});

    //Add html.
    $("li#methodologyWidget").html('<div class="handle">Methodology</div><iframe src="http://docs.google.com/gview?url=http://irweb.erau.edu/irstudies/GSS/PDF/methods.pdf&embedded=true" style="width:100%; height:900px;" frameborder="0"></iframe>');
  });

  //For Survey Instrument widget
  $("a#surveyInstrLink").click(function (event) {
    event.preventDefault();

    //Hide all other widgets
    $("li#dataInfographicWidget, li#methodologyWidget, li#dataTablesWidget, div.hiddenContent, li#surveyInstrWidgetHidden").hide();

    //Hide the Accordion Slider
    $(".jAccordion-slidesWrapper, .jaccordion").slideUp("medium");

    //Show this particular widget in case it was hidden.
    $("li#surveyInstrWidget").show();

    //Resize the widgets containers to avoid blank space.
    $("div.bottomWidgets ul").css('height', '950px');
    $("li#surveyInstrWidget").css({'height' : '950px', 'width' : '100%', 'padding-left' : '0px'});

    //Add html.
    $("li#surveyInstrWidget").html('<div class="handle">Survey Instrument<br /> <a id="surveyInstrumentFullScreenDB" href="#">Daytona Beach</a> | <a id="surveyInstrumentFullScreenPrescott" href="#">Prescott</a></div><iframe id="surveyInstrIFrame" src="http://docs.google.com/gview?url=http://irweb.erau.edu/irstudies/GSS/PDF/GSS_DB_SP2012.pdf&embedded=true" style="width:100%; height:900px;" frameborder="0"></iframe>');
    
        //Displays Daytona Beach PDF in FULL SCREEN Survey Instrument Widget.
      $("a#surveyInstrumentFullScreenDB").click(function (event) {
        event.preventDefault();

        //Add html.
        //$("li#surveyInstrWidget").html('<div class="handle">Survey Instrument<br /> <a id="surveyInstrumentFullScreenDB" href="#">Daytona Beach</a> <a id="surveyInstrumentFullScreenPrescott" href="#">Prescott</a></div><iframe src="http://docs.google.com/gview?url=http://irweb.erau.edu/irstudies/GSS/PDF/GSS_DB_SP2012.pdf&embedded=true" style="width:100%; height:900px;" frameborder="0"></iframe>');
        //Change iframe src
        $('iframe#surveyInstrIFrame').attr('src', 'http://docs.google.com/gview?url=http://irweb.erau.edu/irstudies/GSS/PDF/GSS_DB_SP2012.pdf&embedded=true');

      });
      //Displays Prescott PDF in FULL SCREEN Survey Instrument Widget.
      $("a#surveyInstrumentFullScreenPrescott").click(function (event) {
        event.preventDefault();

        //Change iframe src
        $('iframe#surveyInstrIFrame').attr('src', 'http://docs.google.com/gview?url=http://irweb.erau.edu/irstudies/GSS/PDF/GSS_PCSurveySP12.pdf&embedded=true');
      });

  });

  //For Data Tables widget
  $("a#dataTablesLink").click(function (event) {
    event.preventDefault();

    //Hide all other widgets
    $("li#dataInfographicWidget, li#methodologyWidget, li#surveyInstrWidget, div.hiddenContent, li#surveyInstrWidgetHidden").hide();

    //Hide the Accordion Slider
    $(".jAccordion-slidesWrapper, .jaccordion").slideUp("medium");

    //Show this particular widget in case it was hidden.
    $("li#dataTablesWidget").show();

    //Resize the widgets containers to avoid blank space.
    $("div.bottomWidgets ul").css('height', '950px');
    $("li#dataTablesWidget").css({'height' : '950px', 'width' : '100%', 'padding-left' : '0px'});

    //Add html.
    $("li#dataTablesWidget").html('<div class="handle">Data Tables</div><iframe src="http://docs.google.com/gview?url=http://irweb.erau.edu/irstudies/GSS/PDF/Overall%20Tables-ShortVersion.pdf&embedded=true" style="width:100%; height:900px;" frameborder="0"></iframe><div class="widgetsDownload"><a href="http://irweb.erau.edu/irstudies/GSS/PDF/Overall%20Tables%2011_12.pdf">Download Full Data Tables PDF</a></div>');
  });



  //Displays hidden content when Read More link is clicked.
  $("a.more-link-lg").click(function (event) {
    event.preventDefault();

    //Hide all widgets
    $("li#dataInfographicWidget, li#methodologyWidget, li#surveyInstrWidget, li#dataTablesWidget, #surveyInstrWidgetHidden").hide();

    //Show the hidden content.
    $("div.hiddenContent").fadeIn("slow");
  });

  //Displays Daytona Beach PDF in Survey Instrument Widget.
  $("a#surveyDB").click(function (event) {
    event.preventDefault();

    //Hide Prescott PDF.
    $("#surveyInstrWidgetHidden").hide();

    //Show DB Survey PDF.
    $("li#surveyInstrWidget").fadeIn("slow");
  });
  //Displays Prescott PDF in Survey Instrument Widget.
  $("a#surveyPrescott").click(function (event) {
    event.preventDefault();

    //Hide DB PDF.
    $("#surveyInstrWidget").hide();

    //Add html.
    $("li#surveyInstrWidgetHidden").fadeIn("slow");
  });

  //Displays Daytona Beach PDF in FULL SCREEN Survey Instrument Widget.
  $("a#surveyInstrumentFullScreenDB").click(function (event) {
    event.preventDefault();

    //Add html.
    $("li#surveyInstrWidget").html('<div class="handle">Survey Instrument<br /> <a id="surveyInstrumentFullScreenDB" href="#">Daytona Beach</a> <a id="surveyInstrumentFullScreenPrescott" href="#">Prescott</a></div><iframe src="http://docs.google.com/gview?url=http://irweb.erau.edu/irstudies/GSS/PDF/GSS_DB_SP2012.pdf&embedded=true" style="width:100%; height:900px;" frameborder="0"></iframe>');
  });
  //Displays Prescott PDF in FULL SCREEN Survey Instrument Widget.
  $("a#surveyInstrumentFullScreenPrescott").click(function (event) {
    event.preventDefault();

    //Add html.
    $("li#surveyInstrWidgetHidden").fadeIn("slow");
  });

});