$(document).ready(function(){
        //open popup
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
        });


        //Script for Breadcrumb Initialization
        jQuery("#breadCrumb3").jBreadCrumb();

        
      });/* END document.ready function */

        //position the popup at the center of the page
        function positionPopup(){
          if(!$("#overlay_form").is(':visible')){
            return;
          } 
          $("#overlay_form").css({
              left: ($(window).width() - $('#overlay_form').width()) / 3,
              top: ($(window).width() - $('#overlay_form').width()) / 7,
              position:'absolute'
          });
        }

        //For 2nd popup****************************************
        function positionPopup1(){
          if(!$("#overlay_form1").is(':visible')){
            return;
          } 
          $("#overlay_form1").css({
              left: ($(window).width() - $('#overlay_form1').width()) / 3,
              top: ($(window).width() - $('#overlay_form1').width()) / 7,
              position:'absolute'
          });
        }

        //For 3rd popup****************************************
        function positionPopup2(){
          if(!$("#overlay_form2").is(':visible')){
            return;
          } 
          $("#overlay_form2").css({
              left: ($(window).width() - $('#overlay_form2').width()) / 3,
              top: ($(window).width() - $('#overlay_form2').width()) / 7,
              position:'absolute'
          });
        }

        //For 4th popup****************************************
        function positionPopup3(){
          if(!$("#overlay_form3").is(':visible')){
            return;
          } 
          $("#overlay_form3").css({
              left: ($(window).width() - $('#overlay_form3').width()) / 3,
              top: ($(window).width() - $('#overlay_form3').width()) / 7,
              position:'absolute'
          });
        }

        //For 5th popup****************************************
        function positionPopup4(){
          if(!$("#overlay_form4").is(':visible')){
            return;
          } 
          $("#overlay_form4").css({
              left: ($(window).width() - $('#overlay_form4').width()) / 3,
              top: ($(window).width() - $('#overlay_form4').width()) / 7,
              position:'absolute'
          });
        }

        //For 6th popup****************************************
        function positionPopup5(){
          if(!$("#overlay_form5").is(':visible')){
            return;
          } 
          $("#overlay_form5").css({
              left: ($(window).width() - $('#overlay_form5').width()) / 3,
              top: ($(window).width() - $('#overlay_form5').width()) / 7,
              position:'absolute'
          });
        }

        //maintain the popup at center of the page when browser resized
        $(window).bind('resize',positionPopup);


        //Script to toggle hidden content in slider text.
        $("#readMore").click(function(){
          $("#hiddenContent").toggle('slow');

        var text = $('#readMore').text();
        $('#readMore').text(text == "Read More" ? "Read Less" : "Read More");
      });


/* Start function for the archives widget */
function updatePDF(event, archiveType, pdfURL) {
if(event.preventDefault) event.preventDefault();
  var strSelectedYear = pdfURL;

  switch(archiveType)
  {
    case 'methodology':
      loadMethodology(strSelectedYear);
      break;
    case 'dataTables':
      loadDataTables(strSelectedYear);
      break;
    case 'instrument':
      loadInstrument(strSelectedYear);
      break;
    default:
      loadMethodology(strSelectedYear);
    
  }
}

//Load methodology pdf based on the selected year
function loadMethodology(pdfURL) {
  switch(pdfURL)
    {
    case '/Testing/SurveyReporting/GSS/PDF/GSS_DB_SP2012.pdf':
      //Update the main PDF area.
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/viewer?url=' + pdfURL + '" style="width:100%; height:392px;"></iframe>');
      //Set the Embed link properly
      $("#overlay_form5 textarea").html('&lt;iframe src="http://docs.google.com/viewer?url=' + pdfURL + '" width="100%" height="1000px;"&gt;&lt;/iframe&gt;');
      //Set the Full Screen Link
      $("#archiveFullScreenLink").html('<a href="http://docs.google.com/viewer?url=' + pdfURL + '">Full Screen</a>');
      //Set the download link
      $("#archiveDownloadLink").html('<a href="http://docs.google.com/viewer?url=' + pdfURL + '">Download Full PDF</a>');
      //Refresh the archives area.
      document.getElementById('archivesIframe').contentDocument.location.reload(true);
      break;

    case 'http://irweb.db.erau.edu/Testing/SurveyReporting/GSS/PDF/infographic.pdf':
      //Set the google URL
      var pdfURL = 'http://docs.google.com/gview?url='+pdfURL;
      //Update the main PDF area.
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=' + pdfURL + '" style="width:100%; height:392px;"></iframe>');
      //Set the Embed link properly
      $("#overlay_form5 textarea").html('&lt;iframe src="http://docs.google.com/gview?url=' + pdfURL + '" width="100%" height="1000px;"&gt;&lt;/iframe&gt;');
      //Set the Full Screen Link
      $("#archiveFullScreenLink").html('<a href="' + pdfURL + '">Full Screen</a>');
      //Set the download link
      $("#archiveDownloadLink").html('<a href="' + pdfURL + '">Download Full PDF</a>');
      //Refresh the archives area.
      document.getElementById('archivesIframe').contentDocument.location.reload(true);
      break;

    case '2012':
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=/irstudies/GSS/PDF/GSS_DB_SP2012.pdf&amp;embedded=true" style="width:100%; height:392px;"></iframe>');
      break;

    default:
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=/irstudies/GSS/PDF/GSS_DB_SP2012.pdf&amp;embedded=true" style="width:100%; height:392px;"></iframe>');
    }
}

//load data tables pdf based on selected year
function loadDataTables(year) {
  switch(year)
    {
    case '2010':
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=/irstudies/GSS/PDF/methods.pdf&amp;embedded=true" style="width:100%; height:392px;"></iframe>');
      document.getElementById('archivesIframe').contentDocument.location.reload(true);
      break;
    case '2011':
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=/irstudies/GSS/PDF/methods.pdf&amp;embedded=true" style="width:100%; height:392px;"></iframe>');
      document.getElementById('archivesIframe').contentDocument.location.reload(true);
      break;
    case '2012':
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=/irstudies/GSS/PDF/methods.pdf&amp;embedded=true" style="width:100%; height:392px;"></iframe>');
      document.getElementById('archivesIframe').contentDocument.location.reload(true);
      break;
    default:
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=/irstudies/GSS/PDF/methods.pdf&amp;embedded=true" style="width:100%; height:392px;"></iframe>');
      document.getElementById('archivesIframe').contentDocument.location.reload(true);
    }
}

//load survey instrument pdf based on selected year
function loadInstrument(year) {
  switch(year)
    {
    case '2010':
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=/irstudies/GSS/PDF/Infographic.pdf&amp;embedded=true" style="width:100%; height:392px;"></iframe>');
      document.getElementById('archivesIframe').contentDocument.location.reload(true);
      break;
    case '2011':
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=/irstudies/GSS/PDF/Infographic.pdf&amp;embedded=true" style="width:100%; height:392px;"></iframe>');
      document.getElementById('archivesIframe').contentDocument.location.reload(true);
      break;
    case '2012':
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=/irstudies/GSS/PDF/Infographic.pdf&amp;embedded=true" style="width:100%; height:392px;"></iframe>');
      document.getElementById('archivesIframe').contentDocument.location.reload(true);
      break;
    default:
      $("#archivesIframe").html('<iframe frameborder="0" src="http://docs.google.com/gview?url=/irstudies/GSS/PDF/Infographic.pdf&amp;embedded=true" style="width:100%; height:392px;"></iframe>');
      document.getElementById('archivesIframe').contentDocument.location.reload(true);
    }
}