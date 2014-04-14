$(document).ready(function() {

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
  
  $("#COLLEGE").multiselect({
    selectedList: 1,
    noneSelectedText: 'Select College'
    
  });
  
  $("#MAJOR").multiselect({
    selectedList: 1,
    noneSelectedText: 'Select Major'
    
  });

  $("#SEX").multiselect({
    selectedList: 2,
    noneSelectedText: 'Select Sex'
    
  });

  $("#ETHNIC").multiselect({
    selectedList: 1,
    noneSelectedText: 'Select Ethnicity'
    
  });

  $("#PSKILLS").multiselect({
    selectedList: 1,
    noneSelectedText: 'Select Program'
      });
  
});

});


//Global Variables
var temstrGlobal = '';

function showSelected() {

var outputstr = '';
var iwin;
var temstr = '';
var temcounter = 0;
var itemsArray=[];
var numArray=[]; 
var strArray = [];
itemsArray.push("CAMPUS");
itemsArray.push("YEAR");
itemsArray.push("COLLEGE");
itemsArray.push("MAJOR");
itemsArray.push("SEX");
itemsArray.push("ETHNIC");

outputstr_campus = $('#CAMPUS').val();
outputstr_year = $('#YEAR').val();
outputstr_college = $('#COLLEGE').val();
outputstr_major = $('#MAJOR').val();
outputstr_sex = $('#SEX').val();
outputstr_ethnic = $('#ETHNIC').val();

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


if(outputstr_college==null || outputstr_college==undefined || outputstr_college=='')
{
  
  outputstr_college = '';
  numArray[2] = 0;
}
else
{
  numArray[2] = 1;
  strArray[2] = outputstr_college;
}

if(outputstr_major==null || outputstr_major==undefined || outputstr_major=='')
{
  
  outputstr_major = '';
  numArray[3] = 0;
}
else
{
  numArray[3] = 1;
  strArray[3] = outputstr_major;
}

if(outputstr_sex==null || outputstr_sex==undefined || outputstr_sex=='')
{
  
  outputstr_sex = '';
  numArray[4] = 0;
}
else
{
  numArray[4] = 1;
  strArray[4] = outputstr_sex;
}

if(outputstr_ethnic==null || outputstr_ethnic==undefined || outputstr_ethnic=='')
{
  
  outputstr_ethnic = '';
  numArray[5] = 0;
}
else
{
  numArray[5] = 1;
  strArray[5] = outputstr_ethnic;
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

temstrGlobal = temstr;
  
var tabsHash = $('#tabs ul li.active a').attr('href');

window.location.hash = tabsHash + '&FILTER=' + temstr;

//Code to update the graphs when the Apply Filter is clicked.
$('.firstTableauGraph').html('<iframe src="//infogr.am/Educational-Experience/" width="353" height="635px" scrolling="no" frameborder="0" style="border:none;"></iframe><div style="width:353px;border-top:1px solid #acacac;padding-top:3px;font-family:Arial;font-size:10px;text-align:center;"><a target="_blank" href="http://infogr.am/Educational-Experience" style="color:#acacac;text-decoration:none;"></a> <a style="color: red;text-decoration:none;" href="http://infogr.am" target="_blank">Full Report</a></div>');
$('.secondTableauGraph').html('<iframe src="//infogr.am/961f96623660-4012" width="353" height="642" scrolling="no" frameborder="0" style="border:none;"></iframe><div style="width:353px;border-top:1px solid #acacac;padding-top:3px;font-family:Arial;font-size:10px;text-align:center;"><a target="_blank" href="//infogr.am/961f96623660-4012" style="color:#acacac;text-decoration:none;"></a> <a style="color: red;text-decoration:none;" href="//infogr.am" target="_blank" >Full Report</a></div>');
//$('.lastTableauGraph').html('<iframe id="major_param" src="http://public.tableausoftware.com/views/irweb-AllStudents-Major-Trend-Graph_beta2/Citizenship-Dashboard?' + temstr + '" width="100%" height="380px" frameborder="0" scrolling="no"></iframe><a id="major" href="http://localhost/GSS_3-28-13/Beta/DegreeProgram.html" target="_blank" class="large button red" style="margin-right: 1%; color: #333333;">Option 1</a><a id="major" href="http://localhost/GSS_3-28-13/Beta/DegreeProgram.html" target="_blank" class="large button red" style="margin-right: 1%; color: #333333;">Option 2</a><a id="major" href="http://localhost/GSS_3-28-13/Beta/DegreeProgram.html" target="_blank" class="large button red" style="margin-right: 1%; color: #333333;">Option 3</a>');
};


//Start searching script
function isSubstring(haystack, needle)
{
  
  var hay_new = String(haystack);
  
  return hay_new.indexOf(needle);
};

function getSubstring(haystack, needle)
{
  
  var hay_new = String(haystack);
  
  hay_new = hay_new.substr(0, hay_new.indexOf('?'));
  
  return hay_new;
};

//Get temStrGlobal
function getTemStrGlobal()
{ 
  return temstrGlobal;
};


//Start of script to show hidden content under 2nd tab.
jQuery(function($){
      $("#educationPlansTab").click(function() {
        var data = '<div class="bigTableauPlaceholder" style="width:100%; height:2570px;">'
                + '<div class="bigTableauGraph">' 
        + '<div id="container">'
        + '<div  id="floatingbar">'
            + '<ul style="margin-left:2%;">'
          + '<li><a href="http://www.addyosmani.com"><button>Number of Years to Graduate</button></a></li>'
          + '<li><a href=""><button class="default">Money Borrowed</button></a></li>'
        + '<li><a href=""><button class="default">ROTC Program</button></a></li>'
          + '<li><a href=""><button class="default">General Skills</button></a></li>'
          + '</ul>'
        + '</div>'    
        + '<div id="postcontent">'
                + '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no" width="91%" height="2500px" frameborder="0" scrolling="no"></iframe>'
                + '</div>'
                + '</div>'
        + '</div>';
        $("#tabs-2").html(data).fadeIn('fast');
      });
});
//Start of script to show hidden content under third tab.
jQuery(function($){
      $("#programSkillsTab").click(function() {
        var data = '<div class="bigTableauPlaceholder" style="width:1080; height:750;">'
            + '<div class="bigTableauGraph">'
            + '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no" width="100%" height="750px" frameborder="0" scrolling="yes"></iframe>'
            + '</div>'
            + '</div>';
        $("#PSContent").html(data).fadeIn('fast');
      });
});

//Function to maintain URL hash when new tabs are clicked.
jQuery(function($){
      $("#tabs ul li a").click(function() {
        var newHash = $(this).attr('href') + '#FILTER=' + temstrGlobal;
        window.location.hash = newHash;
        $('#tableauMainContent #filterArea a#link_param').click();
      });
});



/* Function to set Iframe SRC when the select box is changed on Program Experience tab */
function setIframeSource() {
     var theSelect = document.getElementById('PSComboBox');
     //var theIframe = document.getElementById('major_param');
     var theUrl;
 
     theUrl = theSelect.options[theSelect.selectedIndex].value;
     //theIframe.src = theUrl;

     $(".bigTableauGraph").html('<iframe id="major_param" src="' + theUrl + '" width="983px" height="750px" frameborder="0" scrolling="yes"></iframe>');
}


/*Function to check for and parse hash:
jQuery(function($){
      var oldHash = window.location.hash;
      alert(oldHash)

    // function to get 
    function getSecondPart(str) {
    return str.split('-')[1];
}
});
*/