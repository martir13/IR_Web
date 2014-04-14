$(document).ready(function() {

  //hide all filters but 3
  $('#hiddenFilters').hide();
  $('#hiddenFilters1').hide();

  //From tableauMultiselect.js, initializes the multiselect
  setupMultiSelect();

  //Start script for filter options.
  var testarr = new Array();

  $(function(){
    
    $("#CAMPUS").multiselect({
      selectedList: 1,
      noneSelectedText: 'Select Campus'
    });
    
    $("#YEAR").multiselect({
      selectedList: 1,
      noneSelectedText: 'Select Year'
    });
    
    $("#MAJOR").multiselect({
      selectedList: 1,
      noneSelectedText: 'Select Major'
    });

    $("#SEX").multiselect({
      selectedList: 2,
      noneSelectedText: 'Select Gender'
    });

    $("#ETHNIC").multiselect({
      selectedList: 1,
      noneSelectedText: 'Select Ethnicity'
    });

    $("#COLLEGE").multiselect({
      selectedList: 1,
      noneSelectedText: 'Select College'
    });

/* Keep. Uncomment this for international and veteran status */
    $("#VETERAN").multiselect({
      selectedList: 1,
      noneSelectedText: 'Select Veteran Status'
    });

    $("#INTERNATIONAL").multiselect({
      selectedList: 1,
      noneSelectedText: 'Select International Status'
    });

  });

  //Script for Breadcrumb Initialization
  jQuery("#breadCrumb3").jBreadCrumb();

  //Scripts to initialize the tooltips
  setTooltips();

//End document.ready  
});

//Global Variables
var temstrGlobal = '';

//showSelected() updates the URL hash and tableau graphs based on selected filters.
function showSelected(currentGraphForUpdate) {

var outputstr = '';
var iwin;
var temstr = '';
//Update by Nimesh 06/19
var temstr1 = '';
var temstr2 = '';
var temcounter1 = 0;

var temcounter = 0;
var itemsArray=[];
var numArray=[]; 
var strArray = [];
itemsArray.push("Campus");
itemsArray.push("Year");
itemsArray.push("Major");
itemsArray.push("Sex");
itemsArray.push("Ethnic");
itemsArray.push("College");
/* Keep. Uncomment if survey has vet status or international status */
itemsArray.push("Veteran");
itemsArray.push("International");

outputstr_campus = $('#CAMPUS').val();
outputstr_year = $('#YEAR').val();
outputstr_major = $('#MAJOR').val();
outputstr_sex = $('#SEX').val();
outputstr_ethnic = $('#ETHNIC').val();
outputstr_college = $('#COLLEGE').val();
/* Keep. Uncomment if survey has vet status or international status */
outputstr_veteran = $('#VETERAN').val();
outputstr_international = $('#INTERNATIONAL').val();

var $link_param = $("#link_param");

if(outputstr_campus==null || outputstr_campus==undefined || outputstr_campus=='')
{
  outputstr_campus = '';
  numArray[0] = 0;
}
else
{
  numArray[0] = 1;
  strArray[0] = outputstr_campus;
}

if(outputstr_year==null || outputstr_year==undefined || outputstr_year=='')
{
  
  outputstr_year = '';
  numArray[1] = 0;
}
else
{
  numArray[1] = 1;
  strArray[1] = outputstr_year;
}

if(outputstr_major==null || outputstr_major==undefined || outputstr_major=='')
{
  
  outputstr_major = '';
  numArray[2] = 0;
}
else
{
  numArray[2] = 1;
  strArray[2] = outputstr_major;
}

if(outputstr_sex==null || outputstr_sex==undefined || outputstr_sex=='')
{
  
  outputstr_sex = '';
  numArray[3] = 0;
}
else
{
  numArray[3] = 1;
  strArray[3] = outputstr_sex;
}

if(outputstr_ethnic==null || outputstr_ethnic==undefined || outputstr_ethnic=='')
{
  
  outputstr_ethnic = '';
  numArray[4] = 0;
}
else
{
  numArray[4] = 1;
  strArray[4] = outputstr_ethnic;
}

if(outputstr_college==null || outputstr_college==undefined || outputstr_college=='')
{
  
  outputstr_college = '';
  numArray[5] = 0;
}
else
{
  numArray[5] = 1;
  strArray[5] = outputstr_college;
}
/* --------------> Keep. The below 2 are for Vet status and international statu <--------------- */
if(outputstr_veteran==null || outputstr_veteran==undefined || outputstr_veteran=='')
{
  
  outputstr_veteran = '';
  numArray[5] = 0;
}
else
{
  numArray[5] = 1;
  strArray[5] = outputstr_college;
}

if(outputstr_international==null || outputstr_international==undefined || outputstr_international=='')
{
  
  outputstr_international = '';
  numArray[5] = 0;
}
else
{
  numArray[5] = 1;
  strArray[5] = outputstr_college;
}


for(var i=0;i<numArray.length;i++)
{ 
  if(temcounter == 0)
  {
    if(numArray[i] == 1)
    {
      temstr +=itemsArray[i] +"=" + strArray[i];
      temcounter++;
    }
  }
  else
  {
      if(numArray[i] == 1)
      { 
      temstr += "&"+itemsArray[i] +"=" + strArray[i];
      }
  }
}

//Update by Nimesh 06/19
for(var i=0;i<numArray.length;i++)
{ 
  if(temcounter1 == 0)
  {
    if(numArray[i] == 1)
    {
      temstr1 +=itemsArray[i] +"=" + strArray[i];
      temcounter1++;
    }
  }
  else
  {
      if(numArray[i] == 1)
      { 
      temstr1 += ";"+itemsArray[i] +"=" + strArray[i];
      }
  }
}


var top_str = window.parent.location;
  var new_pos = isSubstring(top_str, "#");
  if(temstr != '')
    {
    if(new_pos == -1)
      {
        url1 = top_str + "#";
        url1 = url1 + temstr;
      }
      else
      {
        url1 = getSubstring(top_str, "#") + "#";
        url1 = url1 + temstr; 
      }
    }
  else
  {
    if(new_pos == -1)
    {
      url1 = top_str; 
    }
    else
    {
      url1 = getSubstring(top_str, "#"); 
    }
  } 

//Updated by Nimesh 06/19
temstr2 = temstr + "&Filter=" + temstr1;
temstrGlobal = temstr2;

//Show the filters in the filter breadcrumbs section
var filterToDisplay;
if (temstr == '')
{
  //filterToDisplay = 'None';
}
else
{
  filterToDisplay = temstr;
  $('#filterBreadcrumbs').show();
}
$("#filterBreadcrumbs").html('<p>Current Filter:  ' + filterToDisplay + '</p>');
  
//Append the filter to the URL
window.location.hash = '&FILTER=' + temstr;

//Update the graphs when the Apply Filter is clicked, based on the filters. 
updateGraphs(currentGraphForUpdate);


/* End ShowSelected() */
};


//Start searching script
function isSubstring(haystack, needle)
{
  
  var hay_new = String(haystack);
  
  return hay_new.indexOf(needle);
};

//Returns a substring of the hash split by a '?'
function getSubstring(haystack, needle)
{
  
  var hay_new = String(haystack);
  
  hay_new = hay_new.substr(0, hay_new.indexOf('?'));
  
  return hay_new;
};

//Get the hash for functions outside of scope
function getTemStrGlobal()
{ 
  return temstrGlobal;
};

/* Function to clear select boxes and run showSelected() */
function clearFilters(currentGraph) {
  $("option:selected").prop("selected", false);


  filterForGraphs = '';
  //Click the Uncheck All box for each select box
  $("span:contains('Uncheck all')").click();

  //Run show selected to refresh all graphs with no filters selected.
  showSelected(currentGraph);
}

/* Function to set Iframe SRC when the select box is changed on Program Experience tab */
function setIframeSource() {
     var theSelect = document.getElementById('PSComboBox');
     //var theIframe = document.getElementById('major_param');
     var theUrl;
 
     theUrl = theSelect.options[theSelect.selectedIndex].value;

     $(".bigTableauGraph").html('<iframe id="major_param" src="' + theUrl + '" width="100%" height="750px" frameborder="0" scrolling="yes"></iframe>');
}

function loadGraph(currentGraph, graphNum) {
  //Add the correct graph
  $('div#graph').html('<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphNum + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="934px" frameborder="0" scrolling="no"></iframe>');
  //Set the current graph so tableauFilter.js knows which graph to load.
  currentGraph = currentGraph;
}

function loadTwoGraphs(currentGraph, graphOne, graphTwo) {
  //Add the correct graph
  $('div#graph').html('<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphOne + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="934px" frameborder="0" scrolling="no"></iframe>'
    +                 '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphTwo + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="934px" frameborder="0" scrolling="no"></iframe>');
  //Set the current graph so tableauFilter.js knows which graph to load.
  currentGraph = currentGraph;
}
function loadTwoGraphsOneHeight(currentGraph, graphOne, graphTwo, height) {
  //Add the correct graph
  $('div#graph').html('<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphOne + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="' + height + '" frameborder="0" scrolling="no"></iframe>'
    +                 '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphTwo + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="' + height + '" frameborder="0" scrolling="no"></iframe>');
  //Set the current graph so tableauFilter.js knows which graph to load.
  currentGraph = currentGraph;
}
function loadTwoGraphsTwoHeights(currentGraph, graphOne, graphTwo, heightOne, heightTwo) {
  //Add the correct graph
  $('div#graph').html('<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphOne + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="' + heightOne + '" frameborder="0" scrolling="no"></iframe>'
    +                 '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphTwo + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="' + heightTwo + '" frameborder="0" scrolling="no"></iframe>');
  //Set the current graph so tableauFilter.js knows which graph to load.
  currentGraph = currentGraph;
}

function loadThreeGraphs(currentGraph, graphOne, graphTwo, graphThree) {
  //Add the correct graph
  $('div#graph').html('<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphOne + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="934px" frameborder="0" scrolling="no"></iframe>'
    +                 '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphTwo + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="934px" frameborder="0" scrolling="no"></iframe>'
    +                 '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphThree + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="934px" frameborder="0" scrolling="no"></iframe>');
  //Set the current graph so tableauFilter.js knows which graph to load.
  currentGraph = currentGraph;
}

function loadThreeGraphsThreeHeights(currentGraph, graphOne, graphTwo, graphThree, heightOne, heightTwo, heightThree) {
  //Add the correct graph
  $('div#graph').html('<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphOne + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="' + heightOne + '" frameborder="0" scrolling="no"></iframe>'
    +                 '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphTwo + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="' + heightTwo + '" frameborder="0" scrolling="no"></iframe>'
    +                 '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphThree + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="' + heightThree + '" frameborder="0" scrolling="no"></iframe>');
  //Set the current graph so tableauFilter.js knows which graph to load.
  currentGraph = currentGraph;
}

function loadThreeGraphsOneHeight(currentGraph, graphOne, graphTwo, graphThree, height) {
  //Add the correct graph
  $('div#graph').html('<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphOne + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="' + height + '" frameborder="0" scrolling="no"></iframe>'
    +                 '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphTwo + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="' + height + '" frameborder="0" scrolling="no"></iframe>'
    +                 '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/' + graphThree + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="' + height + '" frameborder="0" scrolling="no"></iframe>');
  //Set the current graph so tableauFilter.js knows which graph to load.
  currentGraph = currentGraph;
}

//This function removes all selected button classes from each floating menu item.
function removeSelectedClass() {
  $("li a button.default").removeClass('default');
}

//This function sets the tooltips for the inner pages.
function setTooltips() {
    $('.tooltip').qtip({
           content: 'The tabs to the left are the different categories of the GSS survey.',
           show: 'mouseover',
           hide: 'mouseout'
    })

    $('.tooltip1').qtip({
           content: 'Getting Started helps you to get familiar with the application.',
           show: 'mouseover',
           hide: 'mouseout'
    })

    $('.tooltip2').qtip({
           content: 'The graph below is completely interactive.',
           show: 'mouseover',
           hide: 'mouseout'
    })
}

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
                           +               '<center>'
                           +           '<h4>How To</h4>'
                           +                  '<ul>'
                           +                    '<li><a href="../Help/overview.html">Overview</a></li>'
                           +                    '<li><a href="../Help/faq.html">Frequently Asked Questions</a></li>'
                           +                    '<li><a href="../Help/navigation.html">Navigation Help</a></li>'
                           +                    '<li><a href="../Help/graphing.html">Graphing Help</a></li>'
                           +                    '<li><a href="../Help/filter.html">Filter Help</a></li>'
                           +                    '<li><a href="../Help/contact.html">Contact Us</a></li>'
                           +                  '</ul>'
                           +           '</div>'
                           +           '<div id="takeTheTourBar" style="width: 100%; clear: both; text-align: center; padding: 5px 0px 5px 0px;">'
                           +           '<a id="startButton" onclick="startTour();"><button style="width: 400px; height: 75px; font-size: 34px;">Take The Tour!</button></a>'
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
                           +                    '<li><a href="../Help/overview.html">Overview</a></li>'
                           +                    '<li><a href="../Help/faq.html">Frequently Asked Questions</a></li>'
                           +                    '<li><a href="../Help/navigation.html">Navigation Help</a></li>'
                           +                    '<li><a href="../Help/graphing.html">Graphing Help</a></li>'
                           +                    '<li><a href="../Help/filter.html">Filter Help</a></li>'
                           +                    '<li><a href="../Help/contact.html">Contact Us</a></li>'
                           +                  '</ul>'
                           +           '</div>'
                           +           '<div id="takeTheTourBar" style="width: 100%; clear: both; text-align: center; padding: 5px 0px 5px 0px;">'
                           +           '<a id="startButton" onclick="startTour();"><button style="width: 400px; height: 75px; font-size: 34px;">Take The Tour!</button></a>'
                           +           '<a id="exitTheTour" href="#">No thanks, just show me the report.</a>'
                           +           '</div>';

    $("#beforeTable").html(threeColumnData);
    $("#beforeTable").lightbox_me({
        centered: true,
        overlayCSS: {background: 'black', opacity: .75}
      });
}

//Function to start the intro tutorial when button is clicked
//This function is for all of the inner pages, not for the Survey Categories.
//The survey categories function is in tableaReportPage.js
function startTour(){
        $('#beforeTable').trigger('close');
        window.location.href = '/Surveys/GSS/Report/index.html?multipage=true';
      }

//Function to keep the filter when new links are clicked.
function appendFilter(wordToReplace, newWord) {
  var currentURL = window.location.href;
  var newURL = currentURL.replace(wordToReplace,newWord);
  self.location=newURL;
}

$('#exitTheTour').live('click', function(){
  $('.close').click();
});