$(document).ready(function()  
      {  

        $.get('XML/major.xml', function(d){  
        $('body').append('<div id="majordiv">');  
        $('body').append('<select id="select1">');  
        $(d).find('major').each(function(){  
  
            var $major = $(this);    
            var description = $major.text();
            
            var html = '<option>' + description + '</option>';  
  
            $('#select1').append($(html));  
               
        });  

        $('body').append('</select>');
        $('body').append('</div>');

    });

        $.get('XML/campus.xml', function(e){  
        $('body').append('<div id="campusdiv">');  
        $('body').append('<select id="select2">');  
        $(e).find('campus').each(function(){  
  
            var $campus = $(this);    
            var campus_description = $campus.text();
            
            var campus_html = '<option>' + campus_description + '</option>';  
  
            $('#select2').append($(campus_html));  
               
        });  

        $('body').append('</select>');
        $('body').append('</div>');
    }); 
});  