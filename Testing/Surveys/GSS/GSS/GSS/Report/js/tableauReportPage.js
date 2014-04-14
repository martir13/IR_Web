$(document).ready(function() {

  //Initialize the data table on the first tab.
  $('#mainDataTable').dataTable({
      "bPaginate": false,
      "bLengthChange": false,
      "bFilter": true,
	    "bJQueryUI": true,
      "bInfo": true
  }).rowGrouping({
	  iGroupingColumnIndex: 0,
      sGroupingColumnSortDirection: "desc",
      iGroupingOrderByColumnIndex: 0,
      bExpandableGrouping: true,
      asExpandedGroups: "University Experience"
  });

  //Script for Breadcrumb Initialization
  jQuery("#breadCrumb3").jBreadCrumb();

  //Load the lightbox if the user has not already seen it:
  applyLightboxWithCookie();

  //Disable minor learning outcomes and acad experience tabs
  $('#minorProgramSkillsTab').addClass('disabled');
  $('#minorProgramSkillsTab').removeAttr('href');
      
  $('#academicExperienceTab').addClass('disabled');
  $('#academicExperienceTab').removeAttr('href');

//End document.ready  
});

//Function to apply lightbox to the 3-columns
function applyLightboxWithCookie() {
  //if the user has already seen the lightbox in the last 365 days, do nothing...
  if ($.cookie('has_seen_three_column_lightbox') == 'Has_Seen')
  {

  }
  //if the user has not seen the lightbox in the last 365 days, install the cookie and show them...
  else
  {
    $.cookie('has_seen_three_column_lightbox', 'Has_Seen', { expires: 365 });

    var threeColumnData = '<div class="oneThird">'
                           +   '<h4>Description</h4>'
                           +               '<p>'
                           +                   'Take a quick tour of the interactive reporting tool! See how to use categories and filters to produce tables and graphs that gets you the data that is important to you!'
                           +               '</p>'
                           +           '</div>'
                           +           '<div id="takeTheTourBar" style="width: 100%; clear: both; text-align: center; padding: 5px 0px 5px 0px;">'
                           +           '<a id="startButton" onclick="startTheTour();"><button style="width: 150px; height: 40px; font-size: 18px;">Take The Tour!</button></a>'
                           +           '<a id="exitTheTour" href="#">No thanks, just show me the report.</a>'
                           +           '</div>';

    $("#beforeTable").html(threeColumnData);
    $("#beforeTable").lightbox_me({
        centered: true,
        overlayCSS: {background: 'black', opacity: .75}
      });
  }
}

//Function to show lightbox regardless if the user has seen ti before. It is used by the link
function applyLightbox(e) {
  e.preventDefault ? e.preventDefault() : e.returnValue = false;
  var threeColumnData = '<div class="oneThird">'
                           +   '<h4>Description</h4>'
                           +               '<p>'
                           +                   'Take a quick tour of the interactive reporting tool! See how to use categories and filters to produce tables and graphs that gets you the data that is important to you!'
                           +               '</p>'
                           +           '</div>'
                           +           '<div id="takeTheTourBar" style="width: 100%; clear: both; text-align: center; padding: 5px 0px 5px 0px;">'
                           +           '<a id="startButton" onclick="startTheTour();"><button style="width: 150px; height: 40px; font-size: 18px;">Take The Tour!</button></a>'
                           +           '<a id="exitTheTour" href="#">No thanks, just show me the report.</a>'
                           +           '</div>';

    $("#beforeTable").html(threeColumnData);
    $("#beforeTable").lightbox_me({
        centered: true,
        overlayCSS: {background: 'black', opacity: .75}
      });
}

//Function to start the intro tutorial when button is clicked
//This is for the Survey Categories tab index page
//The one for the inner pages is in main.js
function startTheTour(){
        $('#beforeTable').trigger('close');
        introJs().setOptions({doneLabel: "Continue", skipLabel: "Stop"}).start().oncomplete(function() {
          window.location.href = 'http://ir.erau.edu/Surveys/GSS/Report/UnivExp/overall.html?multipage=true';
        }).onexit(function() {
          window.location.href = 'http://ir.erau.edu/Surveys/GSS/Report/index.html';
          //history.go(0);
        });
      }

//Function to stop the intro when the 'Stop' button is clicked on the 3rd step. (The button we had to manually create.)
$(".introjs-tooltiptext span").live('click', function(){
  introJs().exit();
  window.location.href = 'http://ir.erau.edu/Surveys/GSS/Report/index.html';
});

$('#exitTheTour').live('click', function(){
  history.go(0);
});
