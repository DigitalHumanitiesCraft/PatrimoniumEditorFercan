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
    $("#collection-tree").fancytree({
        extensions: ["glyph", "filter"],
        glyph: glyph_opts,
        clickFolderMode: 3,
        minExpandLevel: 2,
        focusOnSelect: true, // Set focus when node is checked by a mouse click
        autoCollapse: true,//
        activeVisible: true,// Make sure, active nodes are visible (expanded).
        tooltip: true, // Use title as tooltip (also a callback could be specified)
/*        autoScroll: true,*/


        //imagePath: "/resources/images/",
        quicksearch: true,
        //initAjax: {
        //url: "/modules/jsontree.xql"
        //}
        source: {
        url: "/geo/build-archaeotree/"
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
                var resource= url.substr(url.lastIndexOf('/') + 1);
/*                    var resource = url + "#this";*/
                if (resource == ""){var concept2display = "c1"; var resource="c1"}
                  else
                  {var concept2display = resource}
                  console.log("Resource: " + resource);
                  console.log("concept2display: " + concept2display);
              // console.log("Uni = " +thotNoUni );

/*                    $("#collection-tree").fancytree("getTree").activateKey(thotNoUni);*/
            
            $("#collection-tree").fancytree("getTree").activateKey(concept2display);
            
            var activeNode = $("#collection-tree").fancytree("getTree").getActiveNode();
                    
             if(concept2display == "new") {var sourceFromXql = "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=newArchaeoForm"}
             else {
             activeNode.makeVisible({scrollIntoView: true});
             var sourceFromXql = "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getArchaeoHTML&resource=" + encodeURIComponent(activeNode.data.uri);}
            $("#placeEditor").load(sourceFromXql);
  
/*        $( ".nodeTitleen" ).addClass( "displayedNodeTitle" );        */
        },

       activate: function(node) {
        
            $("body").toggleClass("wait");
            //console.log("Wait");

            var treeroot = $("#collection-tree").fancytree("getRootNode").getFirstChild()
            var lang = treeroot.data.lang;
            console.log("language in tree: " + lang);
            var tree = $("#collection-tree").fancytree("getTree")
            var activeNode = tree.getActiveNode();
            
            var nodeId = activeNode.data.id;
            if(activeNode.data.lng != null) {var lng =activeNode.data.lng};
            if(activeNode.data.lng != null) {var lat =activeNode.data.lat};
            /*console.log("key: " + activeNode.key
            + "\n" + "lng: " + lng + " - lat: " + lat);*/
            var currentZoom = displayMap.getZoom();
/*             console.log("Zoom: " + currentZoom);*/
             
             if(activeNode.data.lng != null) {displayMap.setView([lat, lng], 12);}
             
              var nodeUri = activeNode.data.uri;
              var nodeKey = activeNode.key;
/*              console.log("node URI: " + nodeUri); */
               
               if(nodeId==undefined){nodeId2Use = 'intro'} else{nodeId2Use = nodeId};
            var nodeLang = activeNode.data.lang;
/*            console.log("lang in activate: " + nodeLang); */
            var nodeTitle=activeNode.title;
            var currentUrl =window.location.href;
            var currentConcept =currentUrl.substring(currentUrl.lastIndexOf("/")+1);
                if(currentConcept == ""){currentConcept ="apcc0"}
                   else {currentConcept = currentConcept}
/*            console.log("Current concept: " +  currentConcept);*/
/*            console.log("Node ID: " +  nodeId);*/
            if (currentConcept == nodeId) {
/*              console.log("No load as same concept");*/
            }
            else{

/*               var nodeLang = "en";*/
            // console.log("In activate test: Node id 2 use=" + nodeId2Use + " - data.lang =" + lang);

           var templatepath = treeroot.data.url4transform;

             //var source = "/templates/processConcept.html?concept=" + nodeId2Use + "&lang=" + lang;

/*             var source2 = templatepath + nodeId2Use + "&lang=" + lang;*/
             if(nodeId == "new") {var sourceFromXql = "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=newArchaeoForm"}
             else {var sourceFromXql = "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getArchaeoHTML&resource=" + encodeURIComponent(nodeUri);}
             
             
/*             var conceptFromXqlWithURI = "/place-record/" + encodeURI(nodeUri); */
/*             console.log("Source=" + sourceFromXql);*/
             document.title = "Place "+ nodeId2Use+ " - " + nodeTitle;
/*             console.log("node URI= " + nodeUri + " - Key = " + nodeKey);*/
             history.pushState(null, null,  "/archaeo/" + nodeId);

            $("#placeEditor").load(sourceFromXql);
          }
                    $("body").removeClass("wait");

        },//End of Activate


        toggleEffect: { effect: "blind", options: {direction: "left"}, duration: 3 },
      wide: {
        iconWidth: "1.5em",     // Adjust this if @fancy-icon-width != "16px"
        iconSpacing: "0.5em", // Adjust this if @fancy-icon-spacing != "3px"
        levelOfs: "1.3em"     // Adjust this if ul padding != "16px"
      },
        icon: function(event, data){
         if( data.node.isFolder() ) {
           return "glyphicon glyphicon-book";
         }
      },
      /*renderNode: function(event, data) {
				// Optionally tweak data.node.span
                var node = data.node;
                if(node.data.status!="publish"){
/\*              $(data.node.span).html(data.node.data.status + ": " + data.node.title);*\/
              $(node.span).closest('li').addClass('hide');
/\*				logEvent(event, data);*\/

}else{}
			}
      */
renderNode: function(event, data) {
    var node = data.node;
    if (node.data) {
        var $span = $(node.span);
        $span.find("span.fancytree-title").text(node.title).css({
            "white-space": "normal",
            "margin": "0 30px 0 5px"
        });
    }
}


        });//End of FancyTree

//FILTER
        var tree = $("#collection-tree").fancytree("getTree");

        /*
        * Event handlers for fancytree filter
        */


        $("input[name=searchTree]").keyup(function(e){
            var n,
            tree = $.ui.fancytree.getTree(),

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
			console.log("regex = " + n);

         $("button#btnResetSearch").attr("disabled", false);
         $("span#matches").text("(" + n + " matches)");
       }).focus();


        $("button#btnResetSearch").click(function(e){
        $("input[name=searchTree]").val("");
        $("span#matches").text("");
        tree.clearFilter();
        }).attr("disabled", true);


        //FIN TEST FILTER




});