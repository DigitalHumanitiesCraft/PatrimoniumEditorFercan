
/*
****************************
*     Dropdown menus       *
****************************
*/
 $(function(){
$( "#content" ).on( "click", ".dropdown-menu li a", function( event ) {
    //console.log("menu: " + $(this).attr('menu'));
                  console.log("v: " + $(this).attr('value'));
        /*        var menu = "#" + $(this).attr('id');*/
                var menu = $(this).attr('menu');
                 $(menu).html($(this).text()  + '<span class="caret"></span>');
                 $(menu).attr('value', $(this).attr('value'));
                 $(menu).attr('conceptHierarchy', $(this).attr('conceptHierarchy'));
/*                 console.log("menu: " + menu);*/
        
});
/*$(".dropdown-menu li a").click(function(){
                console.log("1) menu: " + $(this).attr('menu'));
                console.log("2) value: " + $(this).attr('value'));
        /\*        var menu = "#" + $(this).attr('id');*\/
                var menu = $(this).attr('menu');
                 $(menu).html($(this).text()  + '<span class="caret"></span>');
                 $(menu).attr('value', $(this).attr('value'));
        
          });
*/



/*    $(".dropdown-menu li a").click(function(){
        console.log("selection: " + $(this).attr('href'));
        var menu = $(this).attr('href');
         $(menu).html($(this).text() + '<span class="caret"></span>');
         $(menu).attr('value', $(this).attr('value'));

   });
*/
});


function editValue(elementName, lang){
        var displayDiv = "#" + elementName + "_" + lang + "_display";
        var editDiv = "#" + elementName +  "_" + lang +"_edit" ;
        
      $(displayDiv).toggleClass("elementHidden");
      $(editDiv).toggleClass("elementHidden");
}
function cancelEdit(elementName, lang, originalValue){
        var displayDiv = $("#" + elementName + "_" + lang + "_display");
        var editDiv = $("#" + elementName + "_" + lang + "_edit");
        var elementValue = $("#" + elementName + "_" + lang + "_value");
        var elementInput = $("#" + elementName + "_" + lang + "_input");
       
        elementInput.val(originalValue);
        elementInput.html(originalValue);
        displayDiv.toggleClass("elementHidden");
        editDiv.toggleClass("elementHidden");
}


function editNTSortingOrder(){
        $("#ntsorting_nonalpha").toggleClass("disabled");
        $("#ntsorting_alpha").toggleClass("disabled");
        $("#edit_NT_sorting_order").toggleClass("hidden");
        $("#saveNT_sorting_orderButton").toggleClass("hidden");
        $("#editSortingOrderCancelEdit").toggleClass("hidden");
};

function toggleSelectSortingOrder(){
/*        var id = $(e).attr("id");*/
        $("#ntsorting_nonalpha").toggleClass("btn-primary", "btn-secondary");
        $("#ntsorting_alpha").toggleClass("btn-primary", "btn-secondary");

};
function cancelEditSortingOrder(){
      $("#ntsorting_nonalpha").toggleClass("disabled");
        $("#ntsorting_alpha").toggleClass("disabled");
        $("#edit_NT_sorting_order").toggleClass("hidden");
        $("#saveNT_sorting_orderButton").toggleClass("hidden");
        $("#editSortingOrderCancelEdit").toggleClass("hidden");
    
};
function saveNTSortingOrderType(conceptId, lang){
        if($("#ntsorting_nonalpha").hasClass("btn-primary"))
                {var orderingType = 'ordered'}
                else {var orderingType = 'alpha'}
                console.log(orderingType);
                
          var xmlData = "<xml>"
                    + "<orderingType>" + orderingType + "</orderingType>"
                    + "<conceptId>" + conceptId + "</conceptId>"
                    + "<lang>" + lang + "</lang>"
                    +"</xml>";      
         var request = new XMLHttpRequest();
        request.open("POST", "$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=saveNTSortingOrderType" , true);
        var xmlDoc;
        request.onreadystatechange = function() {
            if (request.readyState == 4 && request.status == 200) {
             $("#edit_NT_sorting_order").toggleClass("hidden");
            $("#saveNT_sorting_orderButton").toggleClass("hidden");
             $("#editSortingOrderCancelEdit").toggleClass("hidden");
             //refresh tree
             var currentUrl =window.location.href;
                var currentConcept =currentUrl.substring(currentUrl.lastIndexOf("/")+1);
                var sourceFromXql = "/call-concept/" + currentConcept + "/" + lang;
               $("#conceptContent").load(sourceFromXql);
               var newSourceOption = {
              //        url: '/modules/skosThesau/build-tree.xql?lang=de'
                      url: '/skosThesau/build-tree/' + lang
                      };
                var tree = $('#collection-tree').fancytree('getTree');
                tree.reload(newSourceOption);
  
             
            }
            };

         request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);       
};

function editConceptType(){
        $("#isConceptButton").toggleClass("disabled");
        $("#isCollectionButton").toggleClass("disabled");
        $("#editConceptType").toggleClass("hidden");
        $("#saveConceptType").toggleClass("hidden");
        $("#conceptTypeCancelEdit").toggleClass("hidden");
};
function toggleSelectConceptType(){
/*        var id = $(e).attr("id");*/
        $("#isConceptButton").toggleClass("btn-primary", "btn-secondary");
        $("#isCollectionButton").toggleClass("btn-primary", "btn-secondary");

};

function cancelEditSortingOrder(){
       $("#isConceptButton").toggleClass("disabled");
        $("#isCollectionButton").toggleClass("disabled");
        $("#editConceptType").toggleClass("hidden");
        $("#saveConceptType").toggleClass("hidden");
        $("#conceptTypeCancelEdit").toggleClass("hidden");
};
function saveConceptType(conceptId, lang){
        if($("#isConceptButton").hasClass("btn-primary"))
                {var conceptType = 'skos:Concept'}
                else {var conceptType = 'skos:Collection'}
                
                
          var xmlData = "<xml>"
                    + "<conceptType>" + conceptType + "</conceptType>"
                    + "<conceptId>" + conceptId + "</conceptId>"
                    + "<lang>" + lang + "</lang>"
                    +"</xml>";      
         var request = new XMLHttpRequest();
        request.open("POST", "$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=saveConceptType" , true);
        var xmlDoc;
        request.onreadystatechange = function() {
            if (request.readyState == 4 && request.status == 200) {
             $("#editConceptType").toggleClass("hidden");
            $("#saveConceptType").toggleClass("hidden");
             $("#conceptTypeCancelEdit").toggleClass("hidden"); 
             //refresh tree
             var currentUrl =window.location.href;
                var currentConcept =currentUrl.substring(currentUrl.lastIndexOf("/")+1);
                var sourceFromXql = "/call-concept/" + currentConcept + "/" + lang;
               $("#conceptContent").load(sourceFromXql);
               var newSourceOption = {
              //        url: '/modules/skosThesau/build-tree.xql?lang=de'
                      url: '/skosThesau/build-tree/' + lang
                      };
                var tree = $('#collection-tree').fancytree('getTree');
                tree.reload(newSourceOption);
  
             
            }
            };

         request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);       
};


function saveData(elementName, lang, conceptId, index, originalValue){
        $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        $("button").attr("disabled", true);
        $("input").attr("disabled", true);
        var displayDiv = $("#" + elementName + "_" + lang + "_display");
        var editDiv = $("#" + elementName + "_" + lang + "_edit");
        var elementValue = $("#" + elementName + "_" + lang + "_value");
        var elementInput = $("#" + elementName + "_" + lang + "_input");
        
        var newValue = elementInput.val() 
        
        var xmlData = "<xml>"
                    + "<elementName>" + elementName + "</elementName>"
                    + "<lang>" + lang + "</lang>"
                    + "<conceptId>" + conceptId + "</conceptId>"
                    + "<value>" + newValue + "</value>"
                    + "<originalValue>" + originalValue + "</originalValue>"
                    +"</xml>";
        var request = new XMLHttpRequest();
        request.open("POST", "$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=saveData" , true);
        var xmlDoc;
        request.onreadystatechange = function() {
            if (request.readyState == 4 && request.status == 200) {
            var select = elementInput;
             xmlDoc = request.responseText;
             console.log("TEST element name: " + elementInput.prop("tagName"));
             var tagName = elementInput.prop("tagName");
              newValue2Display = elementInput.val();
             
             displayDiv.replaceWith(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')));    
             displayDiv.toggleClass("elementHidden");
             
             editDiv.toggleClass("elementHidden");
            
              var newSourceOption = {
                            url: '/skosThesau/getTreeJSon/' + lang};
                var tree = $.ui.fancytree.getTree("#collection-tree");      
             var currentLang = tree.getActiveNode().data.lang; 
                   
             
                /*             TODO: update title with if preflabel of current lang*/
             
/*             console.log("currentLang: " + currentLang + " - lang: " + lang);*/
             if(elementName == "prefLabel" && currentLang == lang){
             
            $("#prefLabelCurrentLang").html(newValue2Display)};
            tree.getActiveNode().setTitle(newValue);
/*            tree.reload(newSourceOption);*/
             
            $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        $("button").attr("disabled", false);
        $("input").attr("disabled", false);
             tree.activateKey(conceptId);
                
                
             
            }
            };

         request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
};


function openDialog(dialogId){
    $("#" + dialogId).modal("show");
    
    $("#" + dialogId).find("input,textarea,select").val('').end();


};

function addSelectedNT2Concept(conceptId){
    var ntUri = $("#newNTconceptURI").html();
    var ntLabel = $("#concepts4NTLookupInputModal").val();
    var xmlData = "<xml>"
                    + "<currentConceptId>" + conceptId + "</currentConceptId>"
                    + "<ntUri>" + ntUri  + "</ntUri>"
                    + "<ntLabel>" + ntLabel + "</ntLabel>"
                  + "</xml>";

    var request = new XMLHttpRequest();
    request.open("POST", "$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=addExistingConceptasNT" , true);

var xmlDoc;
     
     if($("#newNTconceptURI").html() == "") { 
        alert("Please look up for a concept first")} 
            else {
            $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        $("button").attr("disabled", true);
        $("input").attr("disabled", true);
                request.onreadystatechange = function() {
                   if (request.readyState == 4 && request.status == 200) {
           /*            var el = document.getElementById(inputName.name.toString());*/
                        xmlDoc = request.responseText;
                         $('#dialogInsertNT').modal('hide');           
                         $("#narrower-list").append('<li class="term-list-item"><a class="coneptLink" onclick="loadOnClickConcept(' + "'"
                         + ntUri.substring(ntUri.lastIndexOf('/'))
                         + "', 'en')" + '"> '
                         + ntLabel
                         +'</a></li>'
                         );             
                          
                          
                          
                            var tree = $('#collection-tree').fancytree('getTree');
                            var currentLang = tree.getActiveNode().data.lang;
                          var newSourceOption = {
                            url: '/skosThesau/getTreeJSon/' + currentLang};
                          tree.reload(newSourceOption);
                              tree.activateKey(conceptId);
                          
                        console.log("Response : Value of xmlDoc" + xmlDoc);
           /*             console.log("Id of element" + idElementValue);*/
                        $("body").css("cursor", "default");
        $("body").css("opacity", "1.5");
        $("button").attr("disabled", false);
        $("body").css("cursor", "default");
        $("input").attr("disabled", false);
                        
                       } // END of (request.readyState == 4 && request.status == 200) {
                       
                   if (request.status == 400) {
                   console.log("Response : Value of xmlDoc" + xmlDoc);
           /*            alert("Concept could not be added as NT. Please check XML.");*/
                   }    
                       };
                
                   request.setRequestHeader('Content-Type', 'text/xml');
                
                   request.send(xmlData);
                   
    }
};

function createConceptAndAddAsNTTEST(conceptId, idPrefix, baseUri){
        /*$("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        $("button").attr("disabled", true);
        $("input").attr("disabled", true);*/
/*    var ntUri = $("#newNTconceptURI").html();*/
    var ntLabelEn = $("#prefLabelEnNT").val();
    var ntLabelFr = $("#prefLabelFrNT").val();
    var ntLabelDe = $("#prefLabelDeNT").val();
    var ntLabelExtraValue = $("#prefLabelExtraValueNT").val();
    var ntLabelExtraLang = $("#prefLabelExtraLangNT").val();
    var xmlData = "<xml>"
                    + "<currentConceptId>" + conceptId + "</currentConceptId>"
/*                    + "<ntUri>" + ntUri  + "</ntUri>"*/
                    + "<label xml:lang='en'>" + ntLabelEn + "</label>"
                    + "<label xml:lang='fr'>" + ntLabelFr + "</label>"
                    + "<label xml:lang='de'>" + ntLabelDe + "</label>"
                    + "<label xml:lang='" + ntLabelExtraLang +"'>" + ntLabelExtraValue + "</label>"
                    + "<idPrefix>" + idPrefix + "</idPrefix>"
                    + "<baseUri>" + baseUri + "</baseUri>"
                  + "</xml>";
    console.log("xml data dans thesaurus: " + xmlData);
    var request = new XMLHttpRequest();
   var url = "/$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=addNewConceptasNT" ;
   
  request.open("POST", url , true);

var xmlDoc;
     
     //if($("#newNTconceptURI").html() == "") { 
     //   alert("Please look up for a concept first")} 
     //       else {
                request.onreadystatechange = function() {
                   if (request.readyState == 4 && request.status == 200) {
                   
           /*            var el = document.getElementById(inputName.name.toString());*/
                        xmlDoc = request.responseText;
           
                              
                          /*$("#prefLabelEnNT").val("");
                          $("#prefLabelFrNT").val("");
                          $("#prefLabelDeNT").val("");
                          $("#prefLabelExtraValueNT").val("");
                          $("#prefLabelExtraLangNT").val("");*/
                         
                        console.log("Response : Value of xmlDoc" + xmlDoc);
                        $('#dialogInsertNT').modal('hide');
                                         $("#dialogInsertNT").on("hidden.bs.modal", function () {
                        $("#narrower-panel").replaceWith(xmlDoc);
                        
                        var tree = $('#collection-tree').fancytree('getTree');
                            var currentLang = tree.getActiveNode().data.lang;
                          var newSourceOption = {
                            url: '/skosThesau/getTreeJSon/' + currentLang
                            };
                          tree.reload(newSourceOption);
                              tree.activateKey(conceptId);
                              $("body").css("cursor", "default");
                    $("body").css("opacity", "1");
                    $("button").attr("disabled", false);
                    $("input").attr("disabled", false);
                        });                      
                         
           /*             console.log("Id of element" + idElementValue);*/
                                 
                        
                       } // END of (request.readyState == 4 && request.status == 200) {
                       
                   if (request.status == 400) {
                   console.log("Response : Value of xmlDoc" + xmlDoc);
                   $("body").css("cursor", "default");
                    $("body").css("opacity", "1");
                    $("button").attr("disabled", false);
                    $("input").attr("disabled", false);
           /*            alert("Concept could not be added as NT. Please check XML.");*/
                   }    
                       };
                
                   request.setRequestHeader('Content-Type', 'text/xml');
                
                   request.send(xmlData);
                   
    //}
};

function createConceptAndAddAsNT(conceptId, idPrefix, baseUri){
        /*$("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        $("button").attr("disabled", true);
        $("input").attr("disabled", true);*/
/*    var ntUri = $("#newNTconceptURI").html();*/
    var ntLabelEn = $("#prefLabelEnNT").val();
    var ntLabelFr = $("#prefLabelFrNT").val();
    var ntLabelDe = $("#prefLabelDeNT").val();
    var ntLabelExtraValue = $("#prefLabelExtraValueNT").val();
    var ntLabelExtraLang = $("#prefLabelExtraLangNT").val();
    var xmlData = "<xml>"
                    + "<currentConceptId>" + conceptId + "</currentConceptId>"
/*                    + "<ntUri>" + ntUri  + "</ntUri>"*/
                    + "<label xml:lang='en'>" + ntLabelEn + "</label>"
                    + "<label xml:lang='fr'>" + ntLabelFr + "</label>"
                    + "<label xml:lang='de'>" + ntLabelDe + "</label>"
                    + "<label xml:lang='" + ntLabelExtraLang +"'>" + ntLabelExtraValue + "</label>"
                    + "<idPrefix>" + idPrefix + "</idPrefix>"
                    + "<baseUri>" + baseUri + "</baseUri>"
                  + "</xml>";
    console.log("xml data dans thesaurus: " + xmlData);
    var request = new XMLHttpRequest();
    
    request.open("POST", "$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=addNewConceptasNT" , true);
    $('#dialogInsertNT').modal('hide');
    $('#addNTButton').hide();
    $("#narrower-list").append("<li><div class='loader'></div>Please wait while data is processed</li>");
var xmlDoc;
     
     //if($("#newNTconceptURI").html() == "") { 
     //   alert("Please look up for a concept first")} 
     //       else {
                request.onreadystatechange = function() {
                   if (request.readyState == 4 && request.status == 200) {
                   
           /*            var el = document.getElementById(inputName.name.toString());*/
                        xmlDoc = request.responseText;
           
                              
                          /*$("#prefLabelEnNT").val("");
                          $("#prefLabelFrNT").val("");
                          $("#prefLabelDeNT").val("");
                          $("#prefLabelExtraValueNT").val("");
                          $("#prefLabelExtraLangNT").val("");*/
                         
                        console.log("Response : Value of xmlDoc" + xmlDoc);
                        
                                         
                        $("#narrower-panel").replaceWith(xmlDoc);
                        
                        var tree = $('#collection-tree').fancytree('getTree');
                            var currentLang = tree.getActiveNode().data.lang;
                          var newSourceOption = {
                            url: '/skosThesau/getTreeJSon/' + currentLang
                            };
                          tree.reload(newSourceOption);
                              tree.activateKey(conceptId);
                              /*$("body").css("cursor", "default");
                    $("body").css("opacity", "1");
                    $("button").attr("disabled", false);
                    $("input").attr("disabled", false);*/
                               
                         
           /*             console.log("Id of element" + idElementValue);*/
                                 
                        
                       } // END of (request.readyState == 4 && request.status == 200) {
                       
                   if (request.status == 400) {
                   console.log("Response : Value of xmlDoc" + xmlDoc);
                   $("body").css("cursor", "default");
                    $("body").css("opacity", "1");
                    $("button").attr("disabled", false);
                    $("input").attr("disabled", false);
           /*            alert("Concept could not be added as NT. Please check XML.");*/
                   }    
                       };
                
                   request.setRequestHeader('Content-Type', 'text/xml');
                
                   request.send(xmlData);
                   
    //}
};


function addNewPrefLabel(conceptId){
        
    var newLabelExtraValue = $("#newPrefLabelExtraValue").val();
    var newLabelExtraLang = $("#newPrefLabelExtraLang").val();
    
    var xmlData = "<xml>"
                    + "<conceptId>" + conceptId + "</conceptId>"
                    + "<prefLabel xml:lang='" + newLabelExtraLang +"'>" + newLabelExtraValue + "</prefLabel>"
                    
                  + "</xml>";
    var request = new XMLHttpRequest();
    request.open("POST", "$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=addNewPrefLabel" , true);
    var listDivId = "#" + "prefLabel-list"
var xmlDoc;
     
     //if($("#newNTconceptURI").html() == "") { 
     //   alert("Please look up for a concept first")} 
     //       else {
                request.onreadystatechange = function() {
                   if (request.readyState == 4 && request.status == 200) {
           /*            var el = document.getElementById(inputName.name.toString());*/
                        xmlDoc = request.responseText;
                         $('#dialogInsertPrefLabel').modal('hide');           
                        
                            
                        $(listDivId).html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))
                        $("#newPrefLabelExtraValue").val("");
                        $("#newPrefLabelExtraLang").val("");
                        
                       } // END of (request.readyState == 4 && request.status == 200) {
                       
                   if (request.status == 400) {
                   console.log("Response : Value of xmlDoc" + xmlDoc);
           
                   }    
                       };
                
                   request.setRequestHeader('Content-Type', 'text/xml');
                
                   request.send(xmlData);
    //}
};

function addNewAltLabel(conceptId){
    var newLabelEn = $("#newAltLabelEn").val();
    var newLabelDe = $("#newAltLabelDe").val();
    var newLabelFr = $("#newAltLabelFr").val();
    
    var newLabelExtraValue = $("#newAltLabelExtraValue").val();
    var newLabelExtraLang = $("#newAltLabelExtraLang").val();
    
    var xmlData = "<xml>"
                    + "<conceptId>" + conceptId + "</conceptId>"
                    + "<altLabel xml:lang='en'>" + newLabelEn + "</altLabel>"
                    + "<altLabel xml:lang='de'>" + newLabelDe + "</altLabel>"
                    + "<altLabel xml:lang='fr'>" + newLabelFr + "</altLabel>"
                    + "<altLabel xml:lang='" + newLabelExtraLang +"'>" + newLabelExtraValue + "</altLabel>"
                    
                  + "</xml>";
    console.log("xmlData: " + xmlData);
    var request = new XMLHttpRequest();
    request.open("POST", "$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=addNewAltLabel" , true);
    var listDivId = "#" + "altLabel-list"
var xmlDoc;
     
     //if($("#newNTconceptURI").html() == "") { 
     //   alert("Please look up for a concept first")} 
     //       else {
                request.onreadystatechange = function() {
                   if (request.readyState == 4 && request.status == 200) {
           /*            var el = document.getElementById(inputName.name.toString());*/
                        xmlDoc = request.responseText;
                         $('#dialogInsertAltLabel').modal('hide');           
                        
                            
                        $(listDivId).html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))
                        
                        
                       } // END of (request.readyState == 4 && request.status == 200) {
                       
                   if (request.status == 400) {
                   console.log("Response : Value of xmlDoc" + xmlDoc);
           
                   }    
                       };
                
                   request.setRequestHeader('Content-Type', 'text/xml');
                
                   request.send(xmlData);
    //}
};


function deleteLabel(labelType, conceptId, lang, index, labelValue){
    if (confirm('Are you sure you want to delete this term?')) {
    var xmlData = "<xml>"
                    + "<conceptId>" + conceptId + "</conceptId>"
                    + "<labelType>" + labelType + "</labelType>"
                    + "<labelValue>" + labelValue + "</labelValue>"
                    + "<lang>" + lang + "</lang>"
                    + "<index>" + index + "</index>"
                    +"</xml>";
    console.log("xmlData in delete label: " + xmlData);
    var listDivId = "#" + labelType + "-list"

    var request = new XMLHttpRequest();
    
    request.open("POST", "$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=deletePrefLabel" , true);
/*    console.log("xmldata: " + xmlData);*/
    var xmlDoc;
    request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             console.log(xmlDoc);
             $(listDivId).html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))
            }
        };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
     }
     else {}
};

function deleteRelatedConcept(relationType, conceptId, relatedConceptId, relatedConceptUri, language){
    if (confirm('Are you sure you want to delete this relationship?')) {
    var xmlData = "<xml>"
                    + "<conceptId>" + conceptId + "</conceptId>"
                    + "<relationType>" + relationType + "</relationType>"
                    + "<relatedConceptId>" + relatedConceptId + "</relatedConceptId>"
                    + "<relatedConceptUri>" + relatedConceptUri + "</relatedConceptUri>"
                    + "<language>" + language + "</language>"
                    +"</xml>";
    
    var panelDiv = "#" + relationType + "-panel"

    var request = new XMLHttpRequest();
    
    request.open("POST", "$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=deleteRelation" , true);
/*    console.log("xmldata: " + xmlData);*/
    var xmlDoc;
    request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             console.log(xmlDoc);
             //$(listDivId).html(xmlDoc);
             $(panelDiv).replaceWith(xmlDoc);
             
             var tree = $('#collection-tree').fancytree('getTree');
                            var currentLang = tree.getActiveNode().data.lang;
                          var newSourceOption = {
                            url: '/skosThesau/getTreeJSon/' + currentLang};
                          tree.reload(newSourceOption);
                              tree.activateKey(conceptId);
            }
        };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
     }
     else {}
};

function downloadCurrentScheme(schemeUri, schemeName){
    var xmlData = "<xml>"
                    + "<schemeUri>" + schemeUri + "</schemeUri>"
                    + "<schemeName>" + schemeName + "</schemeName>"
                    +"</xml>";
    console.log("xmlData: " + xmlData);
    var request = new XMLHttpRequest();
    request.open("POST", "$ausohnum-lib/modules/skosThesau/passDataToLibrary.xql?type=downloadCurrentScheme" , true);
    var xmlDoc;
    console.log(request.readyState);
    request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             console.log(xmlDoc);
             //$(listDivId).html(xmlDoc);
    
             
             
            }
        };

     request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
        console.log(request.readyState);
};



$(document).ready(function(){
var concepts4NTLookupInputModal = document.getElementById("concepts4NTLookupInputModal");
if (concepts4NTLookupInputModal){

$( "#concepts4NTLookupInputModal" ).autocomplete({
    

      source: function( request, response ) {
        var currentUrl = window.location.href;
        var currentConcept =currentUrl.substring(currentUrl.lastIndexOf("/")+1);
        var queryUrl = '/thesaurus/get-data/starts-with-in-scheme/' 
        $.ajax({
            url : queryUrl,
            dataType : 'json',
            data : {
                 query : $('#concepts4NTLookupInputModal').val(),
                 currentConceptIdBis : currentConcept
            },
            success : function(data){
                  response(
                  $.map(
                        data.list.matching, function(object){
                            return {
                                    label: object.label,
                                    id: object.id,
                                    value: object.value
                                    };
                           }
                        ) 
                  );
            },
            dataFilter: function(data) {
                console.log("In filterData: " + data);
                return data; },
            error: function (xhr, ajaxOptions, thrownError) {
                            console.warn(xhr.responseText)
                            console.log(xhr.status);
                            console.log(thrownError);
                            }
        });

      },
      minLength: 2,
/*      create: function () {
   $(this).data('ui-autocomplete-item')._renderItem = function (ul, item) {
      return $('<li>')
        .append( "<a>" + item.value + ' | ' + item.label + "</a>" )
        .appendTo(ul);
    };
  },*/
      select: function( event, ui ) {

        $('#newNTconceptURI').html(ui.item.id);
        $('#selectedConceptURI').toggleClass("hidden");
        console.log( "Selected: " + ui.item.value + " aka " + ui.item.id );
      }}
      ).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
            
        return $( "<li>" )
                .data( "autocomplete-item", item )
				.append( item.label + "<span class='idConceptInSearch'>" + item.id + "</span>" )
				.appendTo( ul )};
  }
  
  
  
});//End of Ready Function

function updateThesaurusTree(){
    if(window.fetch){
        fetch("/skosThesau/build-tree/");
        alert("Thesaurus is in the process of being updated. Please note that this takes time and might send a proxy error.");
    }
    else {alert("This feature does not work with your browser. Please try Chrome or Firefox");}
};