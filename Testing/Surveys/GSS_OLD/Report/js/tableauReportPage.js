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
                           +                   'This interactive report produces tables and graphs for each question from all administrations. The report is fully interactive and can be modified to fit the needs of each user. Filters can be applied to display certain responses based on several demographic variables. Furthermore, applied filters will remain active when exporting, or embedding the selected table or graph outside of this reporting tool'
                           +               '</p>'
                           +           '</div>'
                           +           '<div class="oneThird">'
                           +           '<h4>Getting Started</h4>'
                           +               '<ol id="usageList">'
                           +                  '<li>Use the table below to search for the category, sub-category and questions. Click on the sub-category to take you to the category page to slice and dice the data.</li>'
                           +                  '<li>Watch the How To video on the right to get familiar with all the features of the web app.</li>'
                           +                  '<li>Be adventurous and start playing with the categories by clicking on the tabs above and dive deep into the reporting fun.</li>'
                           +               '</ol>'
                           +           '</div>'
                           +           '<div class="oneThird">'
                           +           '<div class="close">X</div>'
                           +           '<h4>How To</h4>'
                           +                  '<ul>'
                           +                    '<li><a href="Help/overview.html">Overview</a></li>'
                           +                    '<li><a href="Help/faq.html">Frequently Asked Questions</a></li>'
                           +                    '<li><a href="Help/navigation.html">Navigation Help</a></li>'
                           +                    '<li><a href="Help/graphing.html">Graphing Help</a></li>'
                           +                    '<li><a href="Help/filter.html">Filter Help</a></li>'
                           +                    '<li><a href="Help/contact.html">Contact Us</a></li>'
                           +                  '</ul>'
                           +           '</div>'
                           +           '<div id="takeTheTourBar" style="width: 100%; clear: both; text-align: center; padding: 5px 0px 5px 0px;">'
                           +           '<a id="startButton" onclick="startTheTour();"><button style="width: 400px; height: 75px; font-size: 34px;">Take The Tour!</button></a>'
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
  e.preventDefault();
  var threeColumnData = '<div class="oneThird">'
                           +   '<h4>Description</h4>'
                           +               '<p>'
                           +                   'This interactive report produces tables and graphs for each question from all administrations. The report is fully interactive and can be modified to fit the needs of each user. Filters can be applied to display certain responses based on several demographic variables. Furthermore, applied filters will remain active when exporting, or embedding the selected table or graph outside of this reporting tool'
                           +               '</p>'
                           +           '</div>'
                           +           '<div class="oneThird">'
                           +           '<h4>Getting Started</h4>'
                           +               '<ol id="usageList">'
                           +                  '<li>Use the table below to search for the category, sub-category and questions. Click on the sub-category to take you to the category page to slice and dice the data.</li>'
                           +                  '<li>Watch the How To video on the right to get familiar with all the features of the web app.</li>'
                           +                  '<li>Be adventurous and start playing with the categories by clicking on the tabs above and dive deep into the reporting fun.</li>'
                           +               '</ol>'
                           +           '</div>'
                           +           '<div class="oneThird">'
                           +           '<div class="close">X</div>'
                           +           '<h4>How To</h4>'
                           +                  '<ul>'
                           +                    '<li><a href="Help/overview.html">Overview</a></li>'
                           +                    '<li><a href="Help/faq.html">Frequently Asked Questions</a></li>'
                           +                    '<li><a href="Help/navigation.html">Navigation Help</a></li>'
                           +                    '<li><a href="Help/graphing.html">Graphing Help</a></li>'
                           +                    '<li><a href="Help/filter.html">Filter Help</a></li>'
                           +                    '<li><a href="Help/contact.html">Contact Us</a></li>'
                           +                  '</ul>'
                           +           '</div>'
                           +           '<div id="takeTheTourBar" style="width: 100%; clear: both; text-align: center; padding: 5px 0px 5px 0px;">'
                           +           '<a id="startButton" onclick="startTheTour();"><button style="width: 400px; height: 75px; font-size: 34px;">Take The Tour!</button></a>'
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
        introJs().setOptions({doneLabel: "Next page", skipLabel: "Stop"}).start().oncomplete(function() {
          window.location.href = 'http://ir.erau.edu/Surveys/GSS/Report/UnivExp/overall.html?multipage=true';
        }).onexit(function() {
          window.location.href = 'http://ir.erau.edu/Surveys/GSS/Report/index.html';
        });
      }

//Function to stop the intro when the 'Stop' button is clicked on the 3rd step. (The button we had to manually create.)
$(".introjs-tooltiptext span").live('click', function(){
  introJs().exit();
  window.location.href = 'http://ir.erau.edu/Surveys/GSS/Report/index.html';
});

$('#exitTheTour').live('click', function(){
  $('.close').click();
});
