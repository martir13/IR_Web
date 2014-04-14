var opt;
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
itemsArray.push("INTL");

outputstr_campus = $('#CAMPUS').val();
outputstr_year = $('#YEAR').val();
outputstr_major = $('#MAJOR').val();
outputstr_sex = $('#SEX').val();
outputstr_ethnic = $('#ETHNIC').val();
outputstr_college = $('#COLLEGE').val();
/* Keep. Uncomment if survey has vet status or international status */
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


if(outputstr_international==null || outputstr_international==undefined || outputstr_international=='')
{
  
  outputstr_international = '';
  numArray[6] = 0;
}
else
{
  numArray[6] = 1;
  strArray[6] = outputstr_international;
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
function loadTwoGraphsNew(currentGraph, graphOne, graphTwo) {
  //Add the correct graph
  $('div#graph').html('<iframe id="major_param" src="http://public.tableausoftware.com/views/' + graphOne + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="934px" frameborder="0" scrolling="no"></iframe>'
    +                 '<iframe id="major_param" src="http://public.tableausoftware.com/views/' + graphTwo + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="934px" frameborder="0" scrolling="no"></iframe>');
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
                           +           '<a id="startButton" onclick="startTour();"><button style="width: 150px; height: 40px; font-size: 18px;">Take The Tour!</button></a>'
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
  if(e.preventDefault) e.preventDefault();
  var threeColumnData = '<div class="oneThird">'
                           +   '<h4>Description</h4>'
                           +               '<p>'
                           +                   'Take a quick tour of the interactive reporting tool! See how to use categories and filters to produce tables and graphs that gets you the data that is important to you!'
                           +               '</p>'
                           +           '</div>'
                           +           '<div id="takeTheTourBar" style="width: 100%; clear: both; text-align: center; padding: 5px 0px 5px 0px;">'
                           +           '<a id="startButton" onclick="startTour();"><button style="width: 150px; height: 40px; font-size: 18px;">Take The Tour!</button></a>'
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
  $("#beforeTable").trigger('close');
});


//Script to make filters only allow certain sections based on previous filters.
//Also contains sticky navigation functionality.
function makeFiltersDynamic()
{
  //Global variable to check if sticky menu has been hidden
var isMenuHidden = 1;

$(function() {
 
   $("#CAMPUS").change(function() {
          
        var campuschange = $(this).val();
        campuschange = $.trim(new String(campuschange)
                .toLowerCase()
                .replace(/ /g, "_")
        .replace(/,/g, "_")
                .replace(/\./g, '_')); 
        $("#COLLEGE").multiselect('destroy');
        $("#MAJOR").multiselect('destroy');
        
        var origcollege =  $.ajax({
                    url: "college.txt",
                    async: false
                 }).responseText;
         
         var origmajor =  $.ajax({
                    url: "major.txt",
                    async: false
                 }).responseText;
        
        
        if(campuschange.length == 4)
        {
          $("#COLLEGE").html(origcollege);
          $("#MAJOR").html(origmajor);
          
          $("#MAJOR").multiselect({
                selectedList: 1,
                noneSelectedText: 'Select Major'
            });
          $("#COLLEGE").multiselect({
                selectedList: 1,
                noneSelectedText: 'Select College'
              });
        }
        
        else
        {
        var optmaj =  $.ajax({
                    url: campuschange + "_major.txt",
                    async: false
                 }).responseText;
         
        
         
          $("#MAJOR").html(optmaj);
          $("#MAJOR").multiselect({
                selectedList: 1,
                noneSelectedText: 'Select Major'
             });
        

        var opt = $.ajax({
                    url: campuschange + ".txt",
                    async: false
                 }).responseText;
         
         
        
         $("#COLLEGE").html(opt);
        
        
        $("#COLLEGE").multiselect({
                selectedList: 1,
                noneSelectedText: 'Select College'
            });
        
      }
      });
      
   $("#COLLEGE").change(function() {
          
        var campuschoice = $("#CAMPUS").val();
        campuschoice = $.trim(new String(campuschoice)
                .toLowerCase()
                .replace(/ /g, "_")
        .replace(/,/g, "_")
                .replace(/\./g, '_')); 
        
        var strmajor = $(this).val();
        strmajor = $.trim(new String(strmajor)
                .toLowerCase()
                .replace(/ /g, "_")
        .replace(/,/g, "_")
                .replace(/\./g, '_')); 
        $("#MAJOR").multiselect('destroy');
        var origimajor =  $.ajax({
                    url: "major.txt",
                    async: false
                 }).responseText;
         
    if(campuschoice.length == 4)
    {
         if(strmajor.length == 4)
         {
        
          $("#MAJOR").html(origimajor);
          $("#MAJOR").multiselect({
                selectedList: 1,
                noneSelectedText: 'Select Major'
              });
         }
         else
         {
         
        var optmajor = $.ajax({
                    url: strmajor + ".txt",
                    async: false
                 }).responseText;
        
         $("#MAJOR").html(optmajor);
        
        
        $("#MAJOR").multiselect({
                selectedList: 1,
                noneSelectedText: 'Select Major'
                      });
        }
    }
    else
    {
      if(strmajor.length == 4)
      {
        var optmaj =  $.ajax({
                    url: campuschoice + "_major.txt",
                    async: false
                 }).responseText;
         
         
         
          $("#MAJOR").html(optmaj);
          $("#MAJOR").multiselect({
                selectedList: 1,
                noneSelectedText: 'Select Major'
             });
        
      }
      else
      {
      var com_campus_college = campuschoice + "_" + strmajor;
      
      var optmaj =  $.ajax({
                    url: com_campus_college + ".txt",
                    async: false
                 }).responseText;
         
         
         
          $("#MAJOR").html(optmaj);
          $("#MAJOR").multiselect({
                selectedList: 1,
                noneSelectedText: 'Select Major'
             });
      }
    }
        
  });
    // grab the initial top offset of the navigation 
    var sticky_navigation_offset_top = $('#container').offset().top;
  
     
    // our function that decides weather the navigation bar should have "fixed" css position or not.
    var sticky_navigation = function(){
        var scroll_top = $(window).scrollTop(); // our current vertical position from the top
         

        //if we have scrolled past a certain point and menu is not hidden...
        if ((scroll_top >= sticky_navigation_offset_top) && (isMenuHidden === 1)) { 

            $('#filterArea').css({ 'margin-left': '-6px', 'position': 'fixed', 'top':0, 'width': '90%', '-moz-box-shadow':    '0px 4px 4px #666666', '-webkit-box-shadow': '0px 4px 4px #666666', 'box-shadow': '0px 4px 4px #666666' });
       $('#filterOptions').css({ 'background-color': 'white'});
             $('#hideFilters').show();
        } 
        //if we are not past the certain point and menu is shown...
        else if ((scroll_top < sticky_navigation_offset_top)) {
            $('#filterArea').css({ 'position': 'relative', 'border': 'none', 'width': '100%', 'box-shadow': 'none', '-moz-box-shadow': 'none', '-webkit-box-shadow': 'none' }); 
             $('#filterOptions').css({ 'background-color': 'white'});
             $('#hideFilters').hide();
             $( "#showFiltersLink").hide();
        }
        //if we are not past the certain point and menu is hidden...
        /*
        else if ((scroll_top < sticky_navigation_offset_top) && (isMenuHidden === 0)) {
            $('#filterArea').css({ 'position': 'relative', 'border': 'none', 'width': '100%', 'box-shadow': 'none', '-moz-box-shadow': 'none', '-webkit-box-shadow': 'none' }); 
             $('#filterOptions').css({ 'background-color': 'white'});
             $('#hideFilters').hide();
             $( "#showFiltersLink").hide();
        }
        */
        else {
            $('#filterArea').css({ 'position': 'relative', 'border': 'none', 'width': '100%', 'box-shadow': 'none', '-moz-box-shadow': 'none', '-webkit-box-shadow': 'none' }); 
       $('#filterOptions').css({ 'background-color': 'white'});
             $('#hideFilters').hide();
             $( "#showFiltersLink").show();
        }   
    };

    //If Hide is clicked, hide the filters
    $( "#hideFilters" ).click(function(e) {
        e.preventDefault();
        $('#filterArea').css({ 'position': 'relative', 'border': 'none', 'width': '100%', 'box-shadow': 'none', '-moz-box-shadow': 'none', '-webkit-box-shadow': 'none' }); 
        $('#filterOptions').css({ 'background-color': 'white'});
        $( "#showFiltersLink").show().css({ 'position': 'fixed', 'top':0, 'right': '20%', 'background-color': '#F0B93A', 'color': '#000000' });
        //Set the global variable to 0 to signify the sticky menu is hidden.
        isMenuHidden = 0;
    });

    //Show menu again when Show Filters is clicked.
  $( "#showFiltersLink").click(function(e) {
        e.preventDefault();
        $('#filterArea').css({ 'margin-left': '-6px', 'position': 'fixed', 'top':0, 'width': '90%', '-moz-box-shadow':    '0px 4px 4px #666666', '-webkit-box-shadow': '0px 4px 4px #666666', 'box-shadow': '0px 4px 4px #666666' });
        $('#filterOptions').css({ 'background-color': 'white'});
        $('#hideFilters').show();
        $( "#showFiltersLink").hide();
        //Set the global variable to 1 to signify the sticky menu is shown.
        isMenuHidden = 1;
    });
     
    // run our function on load
    sticky_navigation();
     
    // and run it again every time you scroll
    $(window).scroll(function() {
         sticky_navigation();
    });
 
});
};