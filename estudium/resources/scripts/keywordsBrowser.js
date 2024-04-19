glyph_opts = {
    map: {
      doc: "glyphicon glyphicon-asterisk",
      //doc: "glyphicon glyphicon-pencil",
      docOpen: "glyphicon glyphicon-asterisk",
      checkbox: "glyphicon glyphicon-unchecked",
      checkboxSelected: "glyphicon glyphicon-check",
      checkboxUnknown: "glyphicon glyphicon-share",
      dragHelper: "glyphicon glyphicon-play",
      dropMarker: "glyphicon glyphicon-arrow-right",
      error: "glyphicon glyphicon-warning-sign",
      expanderClosed: "glyphicon glyphicon-menu-right",
      expanderLazy: "glyphicon glyphicon-chevron-right",  // glyphicon-plus-sign
      expanderOpen: "glyphicon glyphicon-menu-down",  // glyphicon-collapse-down
      folder: "glyphicon glyphicon-folder-close",
      folderOpen: "glyphicon glyphicon-folder-open",
      loading: "glyphicon glyphicon-refresh glyphicon-spin"

    }
  };
$(document).ready(function () {
        var conceptUrisForTree = $("#conceptUrisForTree").text();
        var labelForTree = $("#labelForTree").text();
        var lang = $("#lang").text();

    $("#thesaurus").fancytree({
        extensions: ["glyph", "filter"],
        glyph: glyph_opts,
        clickFolderMode: 3,
        minExpandLevel: 2,
        focusOnSelect: true, // Set focus when node is checked by a mouse click
        autoCollapse: true,//
        activeVisible: true,// Make sure, active nodes are visible (expanded).
        tooltip: true, // Use title as tooltip (also a callback could be specified)
        autoScroll: true,


        //imagePath: "/resources/images/",
        quicksearch: true,
        //initAjax: {
        //url: "/modules/jsontree.xql"
        //}
        source: {
        url: "/thesaurus/getTreeFromMultipleConcepts/",
        data: {
            conceptUris: conceptUrisForTree,
            label: labelForTree,
            lang4Thesaurus: lang
        }
/*         url: "http://thot.philo.ulg.ac.be/data/coll/admin/collections.json"*/


//        url: "./modules/jsonTreeCollections.xql"
       // url: "./modules/jsontree.xql"

        },
        filter: {
                autoApply: false,   // Re-apply last filter if lazy data is loaded
                autoExpand: true, // Expand all branches that contain matches while filtered
                counter: false,     // Show a badge with number of matching child nodes near parent icons
                fuzzy: false,      // Match single characters in order, e.g. 'fb' will match 'FooBar'
                hideExpandedCounter: false,  // Hide counter badge if parent is expanded
                hideExpanders: false,       // Hide expanders if all child nodes are hidden by filter
                highlight: true,   // Highlight matches by wrapping inside <mark> tags
                leavesOnly: false, // Match end nodes only
                nodata: true,      // Display a 'no data' status node if result is empty
                mode: "hide"       // Grayout unmatched nodes (pass "hide" to remove unmatched node instead)
        },
        init: function(node){

                var url = window.location.href;
                var thotNoUni = url.substring(url.indexOf("apcc") + 0);
                var resource= url.substr(url.lastIndexOf('/') + 1);
              // console.log("Uni = " +thotNoUni );

/*                    $("#thesaurus").fancytree("getTree").activateKey(thotNoUni);*/
                    $("#thesaurus").fancytree("getTree").activateKey(resource);
                    var activeNode = $("#thesaurus").fancytree("getTree").getActiveNode();
/*                    activeNode.makeVisible({scrollIntoView: true});*/
/*        $( ".nodeTitleen" ).addClass( "displayedNodeTitle" );        */
        },

       activate: function(node) {
            $("body").toggleClass("wait");
            //console.log("Wait");

            var treeroot = $("#thesaurus").fancytree("getRootNode").getFirstChild()
            var lang = treeroot.data.lang;
            var tree = $("#thesaurus").fancytree("getTree")
            var activeNode = tree.getActiveNode();
            var nodeId = activeNode.data.id;
               if(nodeId==undefined){nodeId2Use = 'intro'} else{nodeId2Use = nodeId};
            var nodeLang = activeNode.data.lang;
            var nodeTitle=activeNode.title;
            var currentUrl =window.location.href;
            var currentConcept =currentUrl.substring(currentUrl.lastIndexOf("/")+1);

            console.log("Current concept: " +  currentConcept);
            console.log("Node ID: " +  nodeId);
            if (currentConcept == nodeId) {
              //console.log("Yo");
            }
            else{

/*               var nodeLang = "en";*/
            // console.log("In activate test: Node id 2 use=" + nodeId2Use + " - data.lang =" + lang);

           var templatepath = treeroot.data.url4transform;

             //var source = "/templates/processConcept.html?concept=" + nodeId2Use + "&lang=" + lang;

             var source2 = templatepath + nodeId2Use + "&lang=" + lang;
             var sourceFromXql = "/getConceptDetails/" + nodeId /* + "/" + lang */;
             console.log("Source=" + sourceFromXql);
            
            

            $("#conceptDetails").load(sourceFromXql);
          }
                    $("body").removeClass("wait");

        },//End of Activate


        toggleEffect: { effect: "blind", options: {direction: "left"}, duration: 300 },
      wide: {
        iconWidth: "1.5em",     // Adjust this if @fancy-icon-width != "16px"
        iconSpacing: "0.5em", // Adjust this if @fancy-icon-spacing != "3px"
        levelOfs: "1.3em"     // Adjust this if ul padding != "16px"
      },
        icon: function(event, data){
         if( data.node.isFolder() ) {
           return "glyphicon glyphicon-book";
         }
      }
      



        });

        $("input[name=searchTree]").keyup(function(e){
            var n,
            tree = $.ui.fancytree.getTree("#thesaurus"),

            args = "autoApply autoExpand fuzzy hideExpanders highlight leavesOnly nodata".split(" "),
            opts = {},
            filterFunc = tree.filterNodes,
            match = $(this).val();


/*        console.log("match= " + match);*/
        /*
        $.each(args, function(i, o) {
			opts[o] = $("#" + o).is(":checked");
		});
		*/

      opts.mode = "hide";

      if(e && e.which === $.ui.keyCode.ESCAPE || $.trim(match) === ""){
			$("button#btnResetSearch").click();
			return;
		}



			// Pass function to perform match
			n = filterFunc.call(tree, function(node) {
				return new RegExp(match, "i").test(node.title);
				node.titleWithHighlight;
			}, opts);
/*			console.log("regex = " + n);*/

         $("button#btnResetSearch").attr("disabled", false);
         $("span#matches").text("(" + n + " matches)");
       }).focus();


        $("button#btnResetSearch").click(function(e){
        $("input[name=searchTree]").val("");
        $("span#matches").text("");
        tree.clearFilter();
        }).attr("disabled", true);


        //FIN TEST FILTER

        $(".subChildrenPreview").accordion({
        header: ".subChildrenHeader",
        heightStyle: "content",
        collapsible: true,
        active: true,
        navigation: false
        });




});//End of document ready