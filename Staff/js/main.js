// Create the tooltips only on document load
$(document).ready(function() 
{
   // Match all link elements with href attributes within the content div
   $('#maria').qtip(
   {
      content: '<table width="292" border="0" align="left">'
			  + '<tr>'
			  +  '<td width="292"><div align="left"><span style="font-weight:bold;" class="style7">Education </span></div></td>'
			  +'</tr>'
			  +'<tr>'
			  +  '<td>'
			  +    '<div align="left">'
			  +      '<UL>'
			  +        '<LI class="style8">'
			  +          '<FONT face=Arial>MS Statistical Computing - University of Central Florida</FONT>'
			  +       '<LI class="style8">'
			  +            '<FONT face=Arial>BS Statistics - University of Central Florida</FONT> </LI>'
			  +      '</UL>'
			  +  '</div></td>'
			  +'</tr>'
			  +'</table>'
			  +'<table width="292" border="0" align="center">'
  +'<tr>'
  +  '<td width="292"><div align="left"><span style="font-weight:bold;" class="style7">Contact Information</span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="292"><div align="center" class="style8">'
  +    '<div align="left">Embry-Riddle Aeronautical University </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="292"><div align="center" class="style8">'
  +    '<div align="left">600 S. Clyde Morris Blvd </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="292"><div align="center" class="style8">'
  +    '<div align="left">Daytona Beach, FL 32114 </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="292"><div align="center" class="style8">'
  +    '<div align="left">Ph: (386) 226-6225</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="292"><div align="center" class="style8">'
  +    '<div align="left">Fax: (386) 226-6055</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="292"><div align="center" class="style8">'
  +    '<div align="left">Email: <a href="mailto:francom@erau.edu" target="_blank">Maria Franco</a></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +'  <td width="292"><div align="center" class="style8">'
  +    '<div align="left">Website: <a href="/" target="_blank"> /</a></div>'
  +  '</div></td>'
  +'</tr>'
  +'</table>',
  position: {
      corner: {
         target: 'rightMiddle',
         tooltip: 'leftMiddle'
      }
   },
   style: { 
    width: 490,
    border: {
         width: 1,
         radius: 5,
         color: '#F0B631'
      },
    name: 'light' // Inherit from preset style
   },
   show: {
    solo: true,
   },
   hide: {
        //delay: 100,
        fixed: true, // <--- add this
        //effect: function() { $(this).fadeOut(250); }
    }
  });


// Match all link elements with href attributes within the content div
   $('#dale').qtip(
   {
      content: '<table width="232" border="0" align="left">'
  +'<tr>'
  +  '<td width="250"><div align="left"><span style="font-weight:bold;" class="style7">Education </span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td>'
  +    '<div align="left">'
  +      '<UL>'
  +        '<LI class="style8">'
  +          '<FONT face=Arial>Ed.D. Educational Leadership - University of Central Florida</FONT>   '         
  +    '<LI class="style8"><FONT face=Arial>MS Business Intelligence - Saint Joseph\'s University</FONT> </LI>'
  +    '<LI class="style8"><FONT face=Arial>MBA Management - University of Louisville</FONT> </LI>'
  +    '<LI class="style8"><FONT face=Arial>BA Business Administration - Transylvania University</FONT> </LI>'
  +      '</UL>'
  +  '</div></td>'
  +'</tr>'
  +'</table>'
  +'<table width="261" border="0" align="center">'
  +'<tr>'
  +  '<td width="227"><div align="left"><span style="font-weight:bold;" class="style7">Contact Information</span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Embry-Riddle Aeronautical University </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">600 S. Clyde Morris Blvd </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Daytona Beach, FL 32114 </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Ph: (386) 226-7278</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Fax: (386) 226-6055</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Email: <a href="mailto:amburged@erau.edu" target="_blank">Dale O. Amburgey </a></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Website: <a href="/" target="_blank"> /</a></div>'
  +  '</div></td>'
  +'</tr>'
  +'</table>'
  +'<table width="426" border="0">'
  +'<tr>'
  +  '<td width="348"><strong class="style8">Membership</strong></td>'
  +'</tr>'
  +'<tr>'
  +  '<td><ul>'
  +    '<li>Association for Institutional Research (AIR) </li>'
  +    '<li>Data mining and predictive modeling</li>'
  +  '</ul></td>'
  +'</tr>'
  +'</table>'
  +'</table>',
  position: {
      corner: {
         target: 'leftMiddle',
         tooltip: 'rightMiddle'
      }
   },
  style: { 
    width: 490,
    border: {
         width: 1,
         radius: 5,
         color: '#F0B631'
      },
    name: 'light' // Inherit from preset style
   },
   show: {
    solo: true,
   },
   hide: {
        //delay: 100,
        fixed: true, // <--- add this
        //effect: function() { $(this).fadeOut(250); }
    }
  });



// Match all link elements with href attributes within the content div
   $('#kathy').qtip(
   {
      content: '<table width="232" border="0" align="left">'
  +'<tr>'
  + '<td width="250"><div align="left"><span style="font-weight:bold;" class="style7">Education </span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td>'
  +   '<div align="left">'
  +      '<UL>'
  +        '<LI class="style8">'
  +          '<FONT face=Arial>MS Business Education - University of Wisconsin </FONT> '           
  +        '<LI class="style8">'
  +            '<FONT face=Arial>BS Business Education - Northern Illinois University </FONT></LI>'
  +      '</UL>'
  +  '</div></td>'
  +'</tr>'
+'</table>'
+'<table width="261" border="0" align="center">'
  +'<tr>'
  +  '<td width="227"><div align="left"><span style="font-weight:bold;" class="style7">Contact Information</span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Embry-Riddle Aeronautical University </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">600 S. Clyde Morris Blvd </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Daytona Beach, FL 32114 </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Ph: (386) 226-6227</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Fax: (386) 226-6055</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Email: <a href="mailto:ottosonk@erau.edu" target="_blank">Kathy Ottoson </a></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Website:<a href="/" target="_blank"> /</a></div>'
  +  '</div></td>'
  +'</tr>'
+'</table>',
  position: {
      corner: {
         target: 'rightMiddle',
         tooltip: 'leftMiddle'
      }
   },
   style: { 
    width: 490,
    border: {
         width: 1,
         radius: 5,
         color: '#F0B631'
      },
    name: 'light' // Inherit from preset style
   },
   show: {
    solo: true,
   },
   hide: {
        //delay: 100,
        fixed: true, // <--- add this
        //effect: function() { $(this).fadeOut(250); }
    }
  });



// Match all link elements with href attributes within the content div
   $('#michael').qtip(
   {
      content: '<table width="232" border="0" align="left">'
  +'<tr>'
  +  '<td width="250"><div align="left"><span style="font-weight:bold;" class="style7">Education </span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td>'
  +    '<div align="left">'
  +      '<UL>'
  +        '<LI class="style8"><SPAN class=348091520-14022008 style9><FONT face=Arial>BA Sociology and American Studies - Stetson University</FONT></SPAN>'            
  +      '</UL>'
  +  '</div></td>'
  +'</tr>'
+'</table>'
+'<table width="261" border="0" align="center">'
  +'<tr>'
  +  '<td width="227"><div align="left"><span style="font-weight:bold;" class="style7">Contact Information</span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Embry-Riddle Aeronautical University </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">600 S. Clyde Morris Blvd </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Daytona Beach, FL 32114 </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Ph: (386) 323-5099</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Fax: (386) 226-6055</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Email: <a href="mailto:michael.chronister@erau.edu" target="_blank">Michael Chronister </a></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Website: <a href="/" target="_blank">/</a></div>'
  +  '</div></td>'
  +'</tr>'
+'</table>',
  position: {
      corner: {
         target: 'leftMiddle',
         tooltip: 'rightMiddle'
      }
   },
   style: { 
    width: 490,
    border: {
         width: 1,
         radius: 5,
         color: '#F0B631'
      },
    name: 'light' // Inherit from preset style
   },
   show: {
    solo: true,
   },
   hide: {
        //delay: 100,
        fixed: true, // <--- add this
        //effect: function() { $(this).fadeOut(250); }
    }
  });



// Match all link elements with href attributes within the content div
   $('#kim').qtip(
   {
      content: '<table width="232" border="0" align="left">'
  +'<tr>'
  +  '<td width="250"><div align="left"><span style="font-weight:bold;" class="style7">Education </span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td>'
  +    '<div align="left">'
  +      '<UL>'
  +        '<LI class="style8">          <SPAN><FONT face=Arial size=2>MS Human Factors and Systems - Embry-Riddle Aeronautical University </FONT></SPAN>'
  +        '<LI class="style8"><SPAN><FONT face=Arial size=2>BA Psychology - Flagler College</FONT></SPAN>'
  +        '</UL>'
  +  '</div></td>'
  +'</tr>'
+'</table>'
+'<table width="261" border="0" align="center">'
  +'<tr>'
  +  '<td width="227"><div align="left"><span style="font-weight:bold;" class="style7">Contact Information</span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Embry-Riddle Aeronautical University </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">600 S. Clyde Morris Blvd </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Daytona Beach, FL 32114 </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Ph: <SPAN style="FONT-SIZE: 10pt; FONT-FAMILY: Arial">(386) 226-6623</SPAN></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Fax: (386) 226-6055</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Email: <a href="mailto:branteeb@erau.edu" target="_blank">Kimberly Brantley</a></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Website: <a href="/" target="_blank">/</a></div>'
  +  '</div></td>'
  +'</tr>'
+'</table>'
+'<table width="426" border="0">'
  +'<tr>'
  +  '<td width="348"><strong class="style8">Professional Societies</strong></td>'
  +'</tr>'
  +'<tr>'
  +  '<td><ul>'
  +    '<li>Work Enviornment Quality Council (WEQC) - Co-Chair </li>'
  +    '<li>Building Liason</li>'
  +    '<li>Florida Association of Institutional Research (FAIR)</li>'
  +    '<li>Southern Association of Institutional Research (SAIR)</li>'
  +    '<li>Association of Institutional Research (AIR) </li>'
  + '</ul></td>'
  +'</tr>'
+'</table>',
  position: {
      corner: {
         target: 'rightMiddle',
         tooltip: 'leftMiddle'
      }
   },
   style: { 
    width: 490,
    border: {
         width: 1,
         radius: 5,
         color: '#F0B631'
      },
    name: 'light' // Inherit from preset style
   },
   show: {
    solo: true,
   },
   hide: {
        //delay: 100,
        fixed: true, // <--- add this
        //effect: function() { $(this).fadeOut(250); }
    }
  });



// Match all link elements with href attributes within the content div
   $('#nathan').qtip(
   {
      content: '<table width="232" border="0" align="left">'
  +'<tr>'
  +  '<td width="250"><div align="left"><span style="font-weight:bold;" class="style7">Education </span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td>'
  +    '<div align="left">'
  +      '<UL class="style8">'
  +        '<LI class="style8"><FONT face=Arial><FONT size=2><SPAN class=style8>BS </SPAN>Engineering Technology </FONT></FONT>'
  + '- Daytona State College'
  +      '</UL>'
  +  '</div></td>'
  +'</tr>'
+'</table>'
+'<table width="261" border="0" align="center">'
  +'<tr>'
  +  '<td width="227"><div align="left"><span style="font-weight:bold;" class="style7">Contact Information</span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Embry-Riddle Aeronautical University </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">600 S. Clyde Morris Blvd </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Daytona Beach, FL 32114 </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Ph: <SPAN style="FONT-SIZE: 10pt; FONT-FAMILY: Arial">(386) 226-6228</SPAN></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Fax: (386) 226-6055</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Email: <a href="mailto:feesern@erau.edu" target="_blank">Nathan Feeser </a></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Website: <a href="/" target="_blank">/</a></div>'
  +  '</div></td>'
  +'</tr>'
+'</table>',
  position: {
      corner: {
         target: 'leftMiddle',
         tooltip: 'rightMiddle'
      }
   },
   style: { 
    width: 490,
    border: {
         width: 1,
         radius: 5,
         color: '#F0B631'
      },
    name: 'light' // Inherit from preset style
   },
   show: {
    solo: true,
   },
   hide: {
        //delay: 100,
        fixed: true, // <--- add this
        //effect: function() { $(this).fadeOut(250); }
    }
  });



// Match all link elements with href attributes within the content div
   $('#lesley').qtip(
   {
      content: '<table width="232" border="0" align="left">'
  +'<tr>'
  +  '<td width="250"><div align="left"><span style="font-weight:bold;" class="style7">Education </span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td>'
  +    '<div align="left">'
  +      '<UL>'
  +        '<LI class="style8">          <SPAN><FONT face=Arial size=2>BS Business Administration - <FONT face=Arial size=2>University of Central Florida</FONT></FONT></SPAN> '         
  +      '</UL>'
  +  '</div></td>'
 +'</tr>'
+'</table>'
+'<table width="261" border="0" align="center">'
  +'<tr>'
  +  '<td width="227"><div align="left"><span style="font-weight:bold;" class="style7">Contact Information</span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Embry-Riddle Aeronautical University </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">600 S. Clyde Morris Blvd </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Daytona Beach, FL 32114 </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Ph: <SPAN style="FONT-SIZE: 10pt; FONT-FAMILY: Arial">(386) 226-6194</SPAN></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Fax: (386) 226-6055</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Email: <a href="mailto:AL-HAJEL@erau.edu" target="_blank">Lesley Al-Hajeri </a></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Website: <a href="/" target="_blank">/</a></div>'
  +  '</div></td>'
  +'</tr>'
+'</table>'
+'<table width="426" border="0">'
  +'<tr>'
  +  '<td width="348"><strong class="style8">Professional Societies</strong></td>'
  +'</tr>'
  +'<tr>'
  +  '<td><ul>'
  +  '<ul>Work Enviornment Quality Council (WEQC) – Online Administrator </ul>'
  +'<ul>Building Liason</ul>'
  +'<ul>Southern Association of Institutional Research (SAIR)</ul>'
  +'<ul>Association of Institutional Research (AIR)</ul>'
+'</ul>'
+'</li>'
  +  '</ul></td>'
  +'</tr>'
+'</table>',
  position: {
      corner: {
         target: 'rightMiddle',
         tooltip: 'leftMiddle'
      }
   },
   style: { 
    width: 490,
    border: {
         width: 1,
         radius: 5,
         color: '#F0B631'
      },
    name: 'light' // Inherit from preset style
   },
   show: {
    solo: true,
   },
   hide: {
        //delay: 100,
        fixed: true, // <--- add this
        //effect: function() { $(this).fadeOut(250); }
    }
  });



// Match all link elements with href attributes within the content div
   $('#alex').qtip(
   {
      content: '<table width="232" border="0" align="left">'
  +'<tr>'
  +  '<td width="250"><div align="left"><span style="font-weight:bold;" class="style7">Education </span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td>'
  +    '<div align="left">'
  +      '<UL>'
  +        '<LI class="style8">'
  +          '<FONT face=Arial>MA Psychology - University of North Carolina Wilmington</FONT>  ' 
  +           '<LI class="style8">'
  +          '<FONT face=Arial>BA Psychology - University of North Carolina Asheville</FONT>  '          
  +        '</UL>'
  +  '</div></td>'
  +'</tr>'
+'</table>'
+'<table width="261" border="0" align="center">'
  +'<tr>'
  +  '<td width="227"><div align="left"><span style="font-weight:bold;" class="style7">Contact Information</span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Embry-Riddle Aeronautical University </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">600 S. Clyde Morris Blvd </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Daytona Beach, FL 32114 </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Ph: (386) 226-6224</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Fax: (386) 226-6055</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Email: <a href="mailto:heatonj1@erau.edu" target="_blank">Jennifer Heaton </a></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Website:<a href="/" target="_blank"> /</a></div>'
  +  '</div></td>'
  +'</tr>'
+'</table>',
  position: {
      corner: {
         target: 'leftMiddle',
         tooltip: 'rightMiddle'
      }
   },
   style: { 
    width: 490,
    border: {
         width: 1,
         radius: 5,
         color: '#F0B631'
      },
    name: 'light' // Inherit from preset style
   },
   show: {
    solo: true,
   },
   hide: {
        //delay: 100,
        fixed: true, // <--- add this
        //effect: function() { $(this).fadeOut(250); }
    }
  });




// Match all link elements with href attributes within the content div
   $('#chantil').qtip(
   {
      content: '<table width="232" border="0" align="left">'
  +'<tr>'
  +  '<td width="250"><div align="left"><span style="font-weight:bold;" class="style7">Education </span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td>'
  +    '<div align="left">'
  +      '<UL>'
  +        '<LI class="style8">          <SPAN><FONT face=Arial size=2>AS Business Administration - <FONT face=Arial size=2>University of Central Florida</FONT></FONT></SPAN> '         
  +      '</UL>'
  +  '</div></td>'
 +'</tr>'
+'</table>'
+'<table width="261" border="0" align="center">'
  +'<tr>'
  +  '<td width="227"><div align="left"><span style="font-weight:bold;" class="style7">Contact Information</span></div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Embry-Riddle Aeronautical University </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">600 S. Clyde Morris Blvd </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Daytona Beach, FL 32114 </div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Ph: <SPAN style="FONT-SIZE: 10pt; FONT-FAMILY: Arial">(386) 226-6873</SPAN></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Fax: (386) 226-6055</div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Email: <a href="mailto:YGLESIAC@erau.edu@erau.edu" target="_blank">Chantil Yglesias </a></div>'
  +  '</div></td>'
  +'</tr>'
  +'<tr>'
  +  '<td width="227"><div align="center" class="style8">'
  +    '<div align="left">Website: <a href="/" target="_blank">/</a></div>'
  +  '</div></td>'
  +'</tr>'
+'</table>',
  position: {
      corner: {
         target: 'rightMiddle',
         tooltip: 'leftMiddle'
      }
   },
   style: { 
    width: 490,
    border: {
         width: 1,
         radius: 5,
         color: '#F0B631'
      },
    name: 'light' // Inherit from preset style
   },
   show: {
    solo: true,
   },
   hide: {
        //delay: 100,
        fixed: true, // <--- add this
        //effect: function() { $(this).fadeOut(250); }
    }
  });

});