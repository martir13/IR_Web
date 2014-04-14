 (function() {
     "use strict";
     var globalfield;
     var globalurl;
     $("document").ready(function() {
         if (window.location.hash) {
             var hash = window.location.hash.substring(1); //Puts hash in variable, and removes the # character
             updatePDF(hash, 'PDF');
             // hash found
         }
         //Apply the Greater Than class to all menu items that have children
         $('div#cssmenu ul li.has-sub ul li.has-sub').has('ul').each(function() {
             $(this).addClass('hasSubElements');
         });
         $('div#cssmenu ul li.has-sub ul li.has-sub').has('ul').click(function() {
             return false;
         });
     });

     function updatePDF(pdfURL, title) {
         var base_url = window.location.hostname + window.location.pathname;
         var pdf_loc = 'http://' + base_url + 'PDF/' + pdfURL + '.pdf&embedded=true';
         var download_pdf = 'http://' + base_url + 'PDF/' + pdfURL + '.pdf';
         $("#coverimg").css({
             display: 'none'
         });
         window.location.hash = pdfURL;
         globalfield = title;
         globalurl = pdf_loc;
         var newGoogleURL = "http://docs.google.com/viewer?url=" + pdf_loc;
         $("#submenu").html('<ul><li class="active"><a href="#"><span>Help</span></a></li><li><a id="download" href="' + download_pdf + '" target="_blank"><span>Download</span></a></li><li><a onclick="openPop()"><span>Embed</span></a></li><li><a id="fullscreen" href="http://docs.google.com/viewer?url=' + pdf_loc + '" target="_blank"><span>Full Screen</span></a></li></ul>');
         $("#submenu").show();
         //Update the main PDF area.
         $("#panel").html('<iframe frameborder="0" src="http://docs.google.com/viewer?url=' + pdf_loc + '" style="width:100%; height:500px;"></iframe>');
         document.getElementById('panel').contentDocument.location.reload(true);
         return true;
     }

     function updateDOC(pdfURL, title) {
         var base_url = window.location.hostname + window.location.pathname;
         var pdf_loc = 'http://' + base_url + 'PDF/' + pdfURL + '.doc&embedded=true';
         var download_pdf = 'http://' + base_url + 'PDF/' + pdfURL + '.doc';
         $("#coverimg").css({
             display: 'none'
         });
         window.location.hash = pdfURL;
         globalfield = title;
         globalurl = pdf_loc;
         var newGoogleURL = "http://view.officeapps.live.com/op/view.aspx?src=" + pdf_loc;
         $("#submenu").html('<ul><li class="active"><a href="#"><span>Help</span></a></li><li><a id="download" href="' + download_pdf + '" target="_blank"><span>Download</span></a></li><li><a onclick="openPop()"><span>Embed</span></a></li><li><a id="fullscreen" href="http://docs.google.com/viewer?url=' + pdf_loc + '" target="_blank"><span>Full Screen</span></a></li></ul>');
         $("#submenu").show();
         //Update the main PDF area.
         $("#panel").html('<iframe frameborder="0" src="http://view.officeapps.live.com/op/view.aspx?src=' + pdf_loc + '" style="width:100%; height:392px;"></iframe>');
         document.getElementById('panel').contentDocument.location.reload(true);
         return true;
     }

     function openPop() {
         $("#overlay_form").html(" <h2>Embed the " + globalfield + " </h2> <p>Copy the code below and paste it in an HTML editor to embed the " + globalfield + "</p> <textarea rows='3' cols='50' onclick='this.focus();this.select()' readonly='readonly'>&lt;iframe src='" + globalurl + "' width='100%' height='1000px;'&gt;&lt;/iframe&gt;</textarea><a onclick='closePop()' id='close'>Close</a>");
         $("#overlay_form").fadeIn(1000);
         $("#overlay_form").css({
             left: ($(window).width() - $('#overlay_form').width()) / 3,
             top: ($(window).width() - $('#overlay_form').width()) / 7,
             position: 'absolute'
         });
     }

     function closePop() {
         $("#overlay_form").fadeOut(500);
     }
 }());