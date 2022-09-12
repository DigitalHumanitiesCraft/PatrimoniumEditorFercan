
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
        extensions: [
                "glyph", 
                "filter"],
        glyph: glyph_opts,
        clickFolderMode: 3,
        minExpandLevel: 2,
        focusOnSelect: true, // Set focus when node is checked by a mouse click
        autoCollapse: true,//
        activeVisible: true,// Make sure, active nodes are visible (expanded).
        tooltip: true, // Use title as tooltip (also a callback could be specified)
        //imagePath: "/resources/images/",
        quicksearch: true,
        //initAjax: {
        //url: "/modules/jsontree.xql"
        //}
        
        source: {
            url: "/skosThesau/getTreeJSon/en"
            ,
           cache: true
            /*         url: "http://thot.philo.ulg.ac.be/data/coll/admin/collections.json"*/
         //        url: "./modules/jsonTreeCollections.xql"
       // url: "./modules/jsontree.xql"
                 },
        
        init: function(node){

                var url = window.location.href;
                var resource= url.substr(url.lastIndexOf('/') + 1);
                
                if (resource == ""){var concept2display = "c1"; var resource="c1"}
                  else{var concept2display = resource}
                  console.log("Resource: " + resource);
                  console.log("concept2display: " + concept2display);
              // console.log("Uni = " +thotNoUni );

/*                 $("#collection-tree").fancytree("getTree").activateKey(thotNoUni);*/
/*              $("#collection-tree").fancytree("getTree").activateKey(concept2display);*/
/*            var activeNode = $("#collection-tree").fancytree("getTree").getActiveNode();*/
            
            var tree = $.ui.fancytree.getTree("#collection-tree");
            tree.activateKey(concept2display);
            var activeNode = tree.getActiveNode();      
            
            
/*                    activeNode.makeVisible({scrollIntoView: true});*/
/*        $( ".nodeTitleen" ).addClass( "displayedNodeTitle" );        */
        },

       activate: function(node) {
            $("body").toggleClass("wait");
            //console.log("Wait");
            var tree = $.ui.fancytree.getTree("#collection-tree");
            var treeroot = tree.getRootNode().getFirstChild();
            var lang = treeroot.data.lang;
/*            console.log("language in tree: " + lang);*/
            
            var activeNode = tree.getActiveNode();
            var nodeId = activeNode.data.id;
               if(nodeId==undefined){nodeId2Use = 'intro'} else{nodeId2Use = nodeId};
            var nodeLang = activeNode.data.lang;
            console.log("lang in activate: " + nodeLang); 
            var nodeTitle=activeNode.title;
            var currentUrl =window.location.href;
            var currentConcept =currentUrl.substring(currentUrl.lastIndexOf("/")+1);
                if(currentConcept == ""){currentConcept ="apcc0"}
                   else {currentConcept = currentConcept}
            console.log("Current concept: " +  currentConcept);
            console.log("Node ID: " +  nodeId);
            if (currentConcept == nodeId) {
              console.log("No load as same concept");
                            }
                            else{
                    
                    /*               var nodeLang = "en";*/
                                // console.log("In activate test: Node id 2 use=" + nodeId2Use + " - data.lang =" + lang);
                    
                                                var templatepath = treeroot.data.url4transform;
                    
                                 //var source = "/templates/processConcept.html?concept=" + nodeId2Use + "&lang=" + lang;
                    
                    /*             var source2 = templatepath + nodeId2Use + "&lang=" + lang;*/
                                 var sourceFromXql = "/call-concept/" + nodeId + "/" + nodeLang;
                                 console.log("Source=" + sourceFromXql);
                                 document.title = "Concept "+ nodeId2Use+ " - " + nodeTitle;
                                 history.pushState(null, null,  "/concept/"+ nodeId2Use);
                    
                                $("#conceptContent").load(sourceFromXql);
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
     var tree = $.ui.fancytree.getTree("#collection-tree");
            var treeroot = tree.getRootNode().getFirstChild();
            var lang = treeroot.data.lang;
            
        var $span = $(node.span);
                var titleCurrentLang = "";
        if ( node.title != null) {
        var titles = node.title;
          
        if ( titles[lang] != null )
            {title2display = node.title[lang]}
            else {title2display = node.title["fr"]};
        };
        $span.find("span.fancytree-title").text(node.title).css({
            "white-space": "normal",
            "margin": "0 30px 0 5px"
        });
    }
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
        }


        });//End of FancyTree

        //FILTER
/*        var tree = $.ui.fancytree.getTree("#collection-tree");*/

        /*
        * Event handlers for fancytree filter
        */


        $("input[name=searchTree]").keyup(function(e){
            var n,
            tree = $.ui.fancytree.getTree("#collection-tree"),

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

        //Multilanguages





$( "#lang-de" ).click(function() {
  var currentUrl =window.location.href;
  var currentConcept =currentUrl.substring(currentUrl.lastIndexOf("/")+1);
  var sourceFromXql = "/call-concept/" + currentConcept + "/de";
  $("#conceptContent").load(sourceFromXql);

  var newSourceOption = {
//        url: '/modules/skosThesau/build-tree.xql?lang=de'
        url: '/skosThesau/getTreeJSon/de'
        };
  var tree = $.ui.fancytree.getTree("#collection-tree");
  tree.reload(newSourceOption);
  });


$( "#lang-fr" ).click(function() {
  var currentUrl =window.location.href;
  var currentConcept =currentUrl.substring(currentUrl.lastIndexOf("/")+1);
  var sourceFromXql = "/call-concept/" + currentConcept + "/fr";
  console.log("source in Reload tree" + sourceFromXql);
  $("#conceptContent").load(sourceFromXql);
  var newSourceOption = {
    url: '/skosThesau/getTreeJSon/fr'

  };
  var tree = $.ui.fancytree.getTree("#collection-tree");
  tree.reload(newSourceOption);


});
$( "#lang-en" ).click(function() {
  var currentUrl =window.location.href;
  var currentConcept =currentUrl.substring(currentUrl.lastIndexOf("/")+1);
  var sourceFromXql = "/call-concept/" + currentConcept + "/en";
  $("#conceptContent").load(sourceFromXql);
  var newSourceOption = {
    url: '/skosThesau/getTreeJSon/en'

  };
  var tree = $.ui.fancytree.getTree("#collection-tree");
  tree.reload(newSourceOption);


});
$( "#lang-ar" ).click(function() {
               var newSourceOption = { url: '/skosThesau/getTreeJSon/en'};
             
               var newActiveOptions =  function(node) {
                          var activeNode = tree.getActiveNode();
                          var nodeId = activeNode.data.id;
                          //alert(nodeId + "data.id = " + activeNode.data.id);
             
                          var source = "/templates/processConcept.html?concept=" + nodeId;
                          history.pushState(null, null,  "/concept/"+ activeNode.data.id);
                         $("#conceptContent").load(source);
                         //alert('test');
                         };
             
             
             
               var tree = $.ui.fancytree.getTree("#collection-tree");
               alert('Arabic has not been implemented yet');
               tree.reload(newSourceOption, newActiveOptions);
});

$('#langflags').css( 'cursor', 'pointer' );

    var thotNo = getURLParameter("concept");
    var url = window.location.href;
    var thotNoBis = url.substr(url.lastIndexOf('/') + 1);
    var qm = "\?";
    console.log("Thot no: " + thotNo + "From URL: " + thotNoBis);
/*    var testQM = console.log(url.indexOf(qm) > -1);*/

  // alert("url: " + url + "\n ThotNo: " + thotNo + "\n thotNoBis: " + thotNoBis);

 
 /*switch(thotNoBis.substring(0, 1)){
        case "":
          console.log("null");
          var source = "/thesauri-intro.html";
            $("#conceptContent").load(source);
        case "i":
        var source = "/thesauri-intro.html";
            $("#conceptContent").load(source);
    }*/

 })

function loadOnClickConcept(conceptId, lang) {
    var sourceFromXql = "/call-concept/" + conceptId + "/" + lang;
     $("#conceptContent").load(sourceFromXql);
     document.title = "Patrimonium - Concept "+ conceptId;
     history.pushState(null, null,  "/concept/"+ conceptId);
     $.ui.fancytree.getTree("#collection-tree").activateKey(conceptId);
};
function reloadPage(){
           location.reload();
       }

function loadConcept(concept){
  var url = "/concept/" + concept;
  window.location.href =url;
};
function loadDashboard(){
  var url = "/admin/";
  window.location.href =url;


};
function getURLParameter(name) { return unescape(
                  (RegExp(name + '=' + '(.+?)($)').exec(location.search)||[,null])[1] ); };
