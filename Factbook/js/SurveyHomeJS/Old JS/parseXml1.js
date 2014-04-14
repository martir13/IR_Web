$(document).ready(function()  
      {  
        //For majors
        $.get('XML/major.xml', function(d){  
        $('#filterOptions').append('<select name="example-list" id="MAJOR" multiple="multiple" style="width:100px;">');  
        $(d).find('major').each(function(){  
            var $major = $(this);    
            var description = $major.text();
            var html = '<option value="'+description+'">'+description+'</option>';  
            $('#MAJOR').append($(html));   
        });  
        $('#filterOptions').append('</select>');
    });

        //For campuses
        $.get('XML/campus.xml', function(e){  
        $('#filterOptions').append('<select name="example-list" id="CAMPUS" multiple="multiple" style="width:100px;">');  
        $(e).find('campus').each(function(){  
            var $campus = $(this);    
            var campus_description = $campus.text();
            var campus_html = '<option value="'+campus_description+'">'+campus_description+'</option>';  
            $('#CAMPUS').append($(campus_html));   
        });  
        $('#filterOptions').append('</select>');
    });

        //For years
        $.get('XML/year.xml', function(d){  
        $('#filterOptions').append('<select name="example-list" id="YEAR" multiple="multiple" style="width:100px;">');  
        $(d).find('year').each(function(){  
            var $year = $(this);    
            var year_description = $year.text();
            var year_html = '<option value="'+year_description+'">'+year_description+'</option>';  
            $('#YEAR').append($(year_html));   
        });  
        $('#filterOptions').append('</select>');
    });

        //For colleges
        $.get('XML/college.xml', function(d){  
        $('#filterOptions').append('<select name="example-list" id="COLLEGE" multiple="multiple" style="width:100px;">');  
        $(d).find('college').each(function(){  
            var $college = $(this);    
            var college_description = $college.text();
            var college_html = '<option value="'+college_description+'">'+college_description+'</option>';  
            $('#COLLEGE').append($(college_html));   
        });  
        $('#filterOptions').append('</select>');
    });

        //For gender
        $.get('XML/sex.xml', function(d){  
        $('#filterOptions').append('<select name="example-list" id="SEX" multiple="multiple" style="width:100px;">');  
        $(d).find('sex').each(function(){  
            var $sex = $(this);    
            var sex_description = $sex.text();
            var sex_html = '<option value="'+sex_description+'">'+sex_description+'</option>';  
            $('#SEX').append($(sex_html));   
        });  
        $('#filterOptions').append('</select>');
    });

        //For ethnicity
        $.get('XML/sex.xml', function(d){  
        $('#filterOptions').append('<select name="example-list" id="ETHNIC" multiple="multiple" style="width:100px;">');  
        $(d).find('ethnic').each(function(){  
            var $ethnic = $(this);    
            var ethnic_description = $ethnic.text();
            var ethnic_html = '<option value="'+ethnic_description+'">'+ethnic_description+'</option>';  
            $('#ETHNIC').append($(ethnic_html));   
        });  
        $('#filterOptions').append('</select>');
    });
});  