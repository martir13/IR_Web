$(document).ready(function() {
//Function to make widgets on homepage bigger when submenu is clicked.

//For Data Infographic Widget
$("a#dataInfoLink").click(function (event) {
  event.preventDefault();

  //Hide all other widgets
  $("li#methodologyWidget, li#surveyInstrWidget, li#dataTablesWidget").hide();

  //Hide the Accordion Slider
  $(".jAccordion-slidesWrapper, .jaccordion").slideUp("medium");

  //Show this particular widget in case it was hidden.
  $("li#dataInfographicWidget").show();

  //Resize the widgets containers to avoid blank space.
  $("div#grid.gridster ul").css('height', '950px');
  $("li#dataInfographicWidget").css('height', '950px');

  //Resize the specific widget and add html.
  $("li#dataInfographicWidget").attr('data-sizex', '6');
  $("li#dataInfographicWidget").attr('data-sizey', '6');
  $("li#dataInfographicWidget").html('<div class="handle">Survey Instrument</div><object id="_ds_118642055" name="_ds_118642055" width="100%" height="900px" type="application/x-shockwave-flash" data="http://viewer.docstoc.com/"><param name="FlashVars" value="doc_id=118642055&mem_id=601161&showrelated=1&showotherdocs=1&doc_type=pdf&allowdownload=1" /><param name="movie" value="http://viewer.docstoc.com/"/><param name="allowScriptAccess" value="always" /><param name="wmode" value="opaque"/><param name="allowFullScreen" value="true" /></object><br /><script type="text/javascript">var docstoc_docid="118642055";var docstoc_title="GSS_DB_SP2012";var docstoc_urltitle="GSS_DB_SP2012";</script><script type="text/javascript" src="http://i.docstoccdn.com/js/check-flash.js"></script><div class="bottom"><div class="fb-like" data-href="http://irweb.erau.edu/irstudies/GSS/Beta/img/Infographic%20db.png" data-send="false" data-layout="button_count" data-width="100" data-show-faces="false"></div><div class="fb-send" data-href="http://irweb.erau.edu/irstudies/GSS/Beta/img/Infographic db.png"></div><div class="thumbnail"><a class="uibutton" href="#facebooksend" data-toggle="modal">Embed</a></div></div>');
});

//For Methodology widget
$("a#methodologyLink").click(function (event) {
  event.preventDefault();

  //Hide all other widgets
  $("li#dataInfographicWidget, li#surveyInstrWidget, li#dataTablesWidget").hide();

  //Hide the Accordion Slider
  $(".jAccordion-slidesWrapper, .jaccordion").slideUp("medium");

  //Show this particular widget in case it was hidden.
  $("li#methodologyWidget").show();

  //Resize the widgets containers to avoid blank space.
  $("div#grid.gridster ul").css('height', '950px');
  $("li#methodologyWidget").css('height', '950px');

  //Resize the specific widget and add html.
  $("li#methodologyWidget").attr('data-col', '1');
  $("li#methodologyWidget").attr('data-sizex', '6');
  $("li#methodologyWidget").attr('data-sizey', '6');
  $("li#methodologyWidget").html('<div class="handle">Methodology</div><object id="_ds_118642055" name="_ds_118642055" width="100%" height="900px" type="application/x-shockwave-flash" data="http://viewer.docstoc.com/"><param name="FlashVars" value="doc_id=118642055&mem_id=601161&showrelated=1&showotherdocs=1&doc_type=pdf&allowdownload=1" /><param name="movie" value="http://viewer.docstoc.com/"/><param name="allowScriptAccess" value="always" /><param name="wmode" value="opaque"/><param name="allowFullScreen" value="true" /></object><br /><script type="text/javascript">var docstoc_docid="118642055";var docstoc_title="GSS_DB_SP2012";var docstoc_urltitle="GSS_DB_SP2012";</script><script type="text/javascript" src="http://i.docstoccdn.com/js/check-flash.js"></script><div class="bottom"><div class="fb-like" data-href="http://irweb.erau.edu/irstudies/GSS/Beta/img/Infographic%20db.png" data-send="false" data-layout="button_count" data-width="100" data-show-faces="false"></div><div class="fb-send" data-href="http://irweb.erau.edu/irstudies/GSS/Beta/img/Infographic db.png"></div><div class="thumbnail"><a class="uibutton" href="#facebooksend" data-toggle="modal">Embed</a></div></div>');
});

//For Survey Instrument widget
$("a#surveyInstrLink").click(function (event) {
  event.preventDefault();

  //Hide all other widgets
  $("li#dataInfographicWidget, li#methodologyWidget, li#dataTablesWidget").hide();

  //Hide the Accordion Slider
  $(".jAccordion-slidesWrapper, .jaccordion").slideUp("medium");

  //Show this particular widget in case it was hidden.
  $("li#surveyInstrWidget").show();

  //Resize the widgets containers to avoid blank space.
  $("div#grid.gridster ul").css('height', '950px');
  $("li#surveyInstrWidget").css('height', '950px');

  //Resize the specific widget and add html.
  $("li#surveyInstrWidget").attr('data-col', '1');
  $("li#surveyInstrWidget").attr('data-sizex', '6');
  $("li#surveyInstrWidget").attr('data-sizey', '6');
  $("li#surveyInstrWidget").html('<div class="handle">Survey Instrument</div><object id="_ds_118642055" name="_ds_118642055" width="100%" height="900px" type="application/x-shockwave-flash" data="http://viewer.docstoc.com/"><param name="FlashVars" value="doc_id=118642055&mem_id=601161&showrelated=1&showotherdocs=1&doc_type=pdf&allowdownload=1" /><param name="movie" value="http://viewer.docstoc.com/"/><param name="allowScriptAccess" value="always" /><param name="wmode" value="opaque"/><param name="allowFullScreen" value="true" /></object><br /><script type="text/javascript">var docstoc_docid="118642055";var docstoc_title="GSS_DB_SP2012";var docstoc_urltitle="GSS_DB_SP2012";</script><script type="text/javascript" src="http://i.docstoccdn.com/js/check-flash.js"></script><div class="bottom"><div class="fb-like" data-href="http://irweb.erau.edu/irstudies/GSS/Beta/img/Infographic%20db.png" data-send="false" data-layout="button_count" data-width="100" data-show-faces="false"></div><div class="fb-send" data-href="http://irweb.erau.edu/irstudies/GSS/Beta/img/Infographic db.png"></div><div class="thumbnail"><a class="uibutton" href="#facebooksend" data-toggle="modal">Embed</a></div></div>');
});

//For Data Tables widget
$("a#dataTablesLink").click(function (event) {
  event.preventDefault();

  //Hide all other widgets
  $("li#dataInfographicWidget, li#methodologyWidget, li#surveyInstrWidget").hide();

  //Hide the Accordion Slider
  $(".jAccordion-slidesWrapper, .jaccordion").slideUp("medium");

  //Show this particular widget in case it was hidden.
  $("li#dataTablesWidget").show();

  //Resize the widgets containers to avoid blank space.
  $("div#grid.gridster ul").css('height', '950px');
  $("li#dataTablesWidget").css('height', '950px');

  //Resize the specific widget and add html.
  $("li#dataTablesWidget").attr('data-col', '1');
  $("li#dataTablesWidget").attr('data-row', '1');
  $("li#dataTablesWidget").attr('data-sizex', '6');
  $("li#dataTablesWidget").attr('data-sizey', '6');
  $("li#dataTablesWidget").html('<div class="handle">Data Tables</div><object id="_ds_118642055" name="_ds_118642055" width="100%" height="900px" type="application/x-shockwave-flash" data="http://viewer.docstoc.com/"><param name="FlashVars" value="doc_id=118642055&mem_id=601161&showrelated=1&showotherdocs=1&doc_type=pdf&allowdownload=1" /><param name="movie" value="http://viewer.docstoc.com/"/><param name="allowScriptAccess" value="always" /><param name="wmode" value="opaque"/><param name="allowFullScreen" value="true" /></object><br /><script type="text/javascript">var docstoc_docid="118642055";var docstoc_title="GSS_DB_SP2012";var docstoc_urltitle="GSS_DB_SP2012";</script><script type="text/javascript" src="http://i.docstoccdn.com/js/check-flash.js"></script><div class="bottom"><div class="fb-like" data-href="http://irweb.erau.edu/irstudies/GSS/Beta/img/Infographic%20db.png" data-send="false" data-layout="button_count" data-width="100" data-show-faces="false"></div><div class="fb-send" data-href="http://irweb.erau.edu/irstudies/GSS/Beta/img/Infographic db.png"></div><div class="thumbnail"><a class="uibutton" href="#facebooksend" data-toggle="modal">Embed</a></div></div>');
});

});