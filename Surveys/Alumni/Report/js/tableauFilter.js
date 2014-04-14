    // functions to get the filter from the full hash
    function getSecondPart(str) {
    return str.split('&FILTER=')[1];
    }
    function getFirstPart(str) {
    return str.split('&FILTER=')[0];
    }
    function splitString(stringToSplit, separator) {
      return stringToSplit.split(separator);
    }

    //This variable is the filter for the graphs to use, not the same as the one needed for the URL hash.
    var filterForGraphs;
    //this variable will be used to determine the current graph we are on.
    var currentGraph;
    //Update the graphs based on the URL's filter
    //Code to update the graphs when the Apply Filter is clicked.
    function updateGraphs(currentGraphs) {

      currentGraph = currentGraphs;
      //Get the old hash and strip the filter out of it.
      var oldHash = window.location.hash;
      //var oldHash = window.location.hash;
      var filter = getSecondPart(oldHash);
      //var tabHref = getFirstPart(oldHash);

      //Set the select boxes base don the URL filter
      setFiltersFromURL(filter);

      //For the graphs so they maintain the filter under each graph.
      temstrGlobal = '';

      //First set the Current Filter section:
      var filterToDisplay;
      if ((filter == undefined) || (filter == ''))
      {
        //filterToDisplay = 'None';
        $('#filterBreadcrumbs').hide();
      }
      else
      {
        $('#filterBreadcrumbs').show();
        filterToDisplay = filter;
        var tempSecondFilter = filter.replace("&", ";");
        filterForGraphs = filter + "&Filter=" + tempSecondFilter;
        temstrGlobal = filter;
      }
      $("#filterBreadcrumbs").html('<p>Current Filter:  ' + filterToDisplay + '</p>');

      //Load the correct graph based on the currentGraph.
      switch(currentGraph)
        {
        case 'overallExp':
          loadGraph('overallExp', 'Overall_Experience');
          break;
        case 'finAid':
          loadTwoGraphs('finAid', 'Financial_Aid_Borrow', 'Financial_Aid_How_Much');
          break;
        case 'rotc':
          loadThreeGraphs('rotc', 'ROTC_Participate', 'ROTC_Commissioned', 'ROTC_Evaluate');
          break;
        case 'genSkills':
          loadTwoGraphs('genSkills', 'General_Skills_Current_Skills', 'General_Skills_Development');
          break;
        case 'profDev':
          loadTwoGraphs('profDev', 'Coop_Complete', 'Coop_During');
          break;
        case 'faaCert':
          loadTwoGraphs('faaCert', 'FAA_Cert', 'FAA_Obtained');
          break;
        default:
          loadGraph('overallExp', 'Overall_Experience');
        }

    //End updateGraphs();
    };

      //Set selected filter options based on URL parameters.
      function setFiltersFromURL(filter) {
        var onlyFilter = filter;
        if ((onlyFilter !== undefined) && (onlyFilter !== '')) {
          var arraySplitByIDs = splitString(onlyFilter, '&');
            for (var i=0; i < arraySplitByIDs.length; i++) {
              var arraySplitByOptions = splitString(arraySplitByIDs[i], '=');
                var arrayOfValues = splitString(arraySplitByOptions[1], ',');
                for (var y=0; y < arrayOfValues.length; y++) {
                  $("option[value='" + arrayOfValues[y] + "']").attr('selected', 'selected');
                }
            }
        }
      }


/*function showHiddenFilters() {
  $('#hiddenFilters, #hiddenFilters1').toggle();
  if ( $('a#moreFiltersLink').text() === 'Show Less Filters' )
  {
    $('a#moreFiltersLink').text('Show More Filters');
  }
  else if ( $('a#moreFiltersLink').text() === 'Show More Filters' )
  {
    $('a#moreFiltersLink').text('Show Less Filters');
  }
}*/

/* Function to set Iframe SRC when the select box is changed on Program Experience tab */
function setIframeSource(selectID) {
     var theSelect = document.getElementById(selectID);
     var graphID;

     graphID = theSelect.options[theSelect.selectedIndex].value;
     $("#graph").html('<iframe id="major_param" src="http://public.tableausoftware.com/views/GSS_PROGSKILLS/' + graphID + '_Dashboard?' + filterForGraphs + '&:toolbar=top" width="100%" height="2500px" frameborder="0" scrolling="no"></iframe>');
}