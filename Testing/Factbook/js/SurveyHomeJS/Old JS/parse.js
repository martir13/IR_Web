$(function(){
    
    var sUrl = window.parent.location;

    var strurl = decodeURI(unescape(sUrl))
   
    sUrl = String(sUrl);
   strurl = String(strurl); 
    if(sUrl.indexOf("?") == -1)
    {
    	$('#filter').replaceWith('');
    }
    else
    {
	var myString = sUrl.substr(sUrl.indexOf("?") + 1);
	var myString1 = strurl.substr(strurl.indexOf("?") + 1);
	var myString_tem = myString.replace("%20"," ");
	var $this = $(this);
	var $major_param = $("#major_param");
	var $major = $("#major");
	var $load = $("#load");
	var $gender = $("#gender");	
	var $citizenship = $("#citizenship");
	var $ethnicity = $("#ethnicity");
	var $class = $("#class");
	var $state_residency = $("#state_residency");
	var $major_quick = $("#major_quick");
	var $load_quick = $("#load_quick");
	var $gender_quick = $("#gender_quick");	
	var $citizenship_quick = $("#citizenship_quick");
	var $ethnicity_quick = $("#ethnicity_quick");
	var $class_quick = $("#class_quick");
	var $state_residency_quick = $("#state_residency_quick");			
	var $load_param = $("#load_param");
	var $sex_param = $("#sex_param");
	var $class_param = $("#class_param");
	var $citizenship_param = $("#citizenship_param");
	var $ethnicity_param = $("#ethnicity_param");
	var $state_residency_param = $("#state_residency_param");
	var $back_dashboard = $("#back_dashboard");
	var $link_param = $("#link_param");
	
	

	$('#filter').append('<span class="ulstyle">Filter: </span>');
	$('#filter').append(myString1);
	
	$major_param.attr("src",$major_param.attr("src")+"&"+myString);
	$load_param.attr("src",$load_param.attr("src")+"&"+myString);
	$sex_param.attr("src",$sex_param.attr("src")+"&"+myString);
	$class_param.attr("src",$class_param.attr("src")+"&"+myString);
	$citizenship_param.attr("src",$citizenship_param.attr("src")+"&"+myString);
	$ethnicity_param.attr("src",$ethnicity_param.attr("src")+"&"+myString);
	$state_residency_param.attr("src",$state_residency_param.attr("src")+"&"+myString);
	$major.attr("href",$major.attr("href")+"?"+myString);
	$load.attr("href",$load.attr("href")+"?"+myString);
	$gender.attr("href",$gender.attr("href")+"?"+myString);
	$citizenship.attr("href",$citizenship.attr("href")+"?"+myString);
	$ethnicity.attr("href",$ethnicity.attr("href")+"?"+myString);
	$class.attr("href",$class.attr("href")+"?"+myString);
	$state_residency.attr("href",$state_residency.attr("href")+"?"+myString);
	$major_quick.attr("href",$major_quick.attr("href")+"?"+myString);
	$load_quick.attr("href",$load_quick.attr("href")+"?"+myString);
	$gender_quick.attr("href",$gender_quick.attr("href")+"?"+myString);
	$citizenship_quick.attr("href",$citizenship_quick.attr("href")+"?"+myString);
	$ethnicity_quick.attr("href",$ethnicity_quick.attr("href")+"?"+myString);
	$class_quick.attr("href",$class_quick.attr("href")+"?"+myString);
	$state_residency_quick.attr("href",$state_residency_quick.attr("href")+"?"+myString);
	$back_dashboard.attr("href",$back_dashboard.attr("href")+"?"+myString);
	$link_param.attr("href",$link_param.attr("href")+"?"+myString);
	}
	

	
	$("#campus").multiselect({
		selectedList: 3,
		noneSelectedText: 'Select Campus'
			});
	
	$("#program").multiselect({
		selectedList: 8,
		noneSelectedText: 'Select Program'
	});
	
	$("#college").multiselect({
		selectedList: 8,
		noneSelectedText: 'Select College'
		
	});
	
	$("#major").multiselect({
		selectedList: 8,
		noneSelectedText: 'Select Major'
		
	});
	
	

  });

