$(document).ready(function() 

 var oldHash = window.location.hash;

    var filter = getSecondPart(oldHash);

    var tabHref = getFirstPart(oldHash);

     $('.firstTableauGraph').html('<iframe src="//infogr.am/Educational-Experience/" width="353" height="635px" scrolling="no" frameborder="0" style="border:none;"></iframe><div style="width:353px;border-top:1px solid #acacac;padding-top:3px;font-family:Arial;font-size:10px;text-align:center;"><a target="_blank" href="http://infogr.am/Educational-Experience" style="color:#acacac;text-decoration:none;"></a> <a style="color: red;text-decoration:none;" href="http://infogr.am" target="_blank">Full Report</a></div>');
      $('.secondTableauGraph').html('<iframe src="//infogr.am/961f96623660-4012" width="353" height="642" scrolling="no" frameborder="0" style="border:none;"></iframe><div style="width:353px;border-top:1px solid #acacac;padding-top:3px;font-family:Arial;font-size:10px;text-align:center;"><a target="_blank" href="//infogr.am/961f96623660-4012" style="color:#acacac;text-decoration:none;"></a> <a style="color: red;text-decoration:none;" href="//infogr.am" target="_blank" >Full Report</a></div>');

      //Data to put in second tab for EducationPlans
      var data1 = '<div class="bigTableauPlaceholder" style="width:100%; height:2570px;">'
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

        //Data to put in third tab for Program Skills
        var data2 = '<select name="PS" id="PSComboBox" onchange="setIframeSource()" style="width:250px;">'
                  + '<option value="http://public.tableausoftware.com/views/irweb-AllStudents-Major-Trend-Graph_beta2/Major-Dashboard?">PC BS Aerospace Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/irweb-AllStudents-Major-Trend-Graph_beta2/StateResudency-Dashboard?">DB BS Aerospace Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/irweb-AllStudents-Major-Trend-Graph_beta2/Citizenship-Dashboard?">DB BS Computer Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">PC BS Mechanical Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB BS Software Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB MS Mechanical Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB MS Aerospace Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB BS Civil Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB BS Electrical Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB M Software Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">PC BS Electrical Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB D Engineering Physics</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB BS Mechanical Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">PC BS Computer Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB BS Aerospace Electronics</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">PC BS Software Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB M Aerospace Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">DB M Electrica/ Computer Engineering</option>'
                  + '<option value="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no">PC MS Software Engineering</option>'
                + '</select>'
                + '<div id="PSContent">'
                  + '<div class="bigTableauPlaceholder" style="width:auto; height:750;">'
                  + '<div class="bigTableauGraph">'
                  + '<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS/EducationalPlans?:embed=y&:display_count=no" width="983px" height="750px" frameborder="0" scrolling="yes"></iframe>'
                  + '</div>'
                  + '</div>'
                + '</div>';

      $('#tabs-2').html(data1);
      $('#tabs-3').html(data2);


      // reset everything to default
      $('#tabs li').removeClass('active');
      $('#panels .panel').hide();
      //Apply active class to the current tab:
      $('a[href="' + tabHref + '"]').parent().addClass('active');
      //$('#panels .panel:eq(' + (tab.parent().index()) + ')').show();
      $('#panels .panel:eq(' + ($('#tabs li a[href=' + tabHref + ']').parent().index()) + ')').show();

       

)};

    // function to get the filter from the full hash
    function getSecondPart(str) {
    return str.split('&FILTER=')[1];
    }
    function getFirstPart(str) {
    return str.split('&FILTER=')[0];
    }

    function splitString(stringToSplit, separator) {
      return stringToSplit.split(separator);
    }