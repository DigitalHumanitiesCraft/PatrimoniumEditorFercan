function getCurrentPeopleUri(){    return $('#currentPeopleUri').html() };
function getCurrentProject(){ $('#currentProject').text(); };

var docId = $("#currentDocId").text();

$( document ).ready(function() {
    
 
if($('#xml-editor-file').length){
var editor4File = ace.edit("xml-editor-file");
      editor4File.session.setMode("ace/mode/xml");
      editor4File.setOptions({
            maxLines: Infinity});
};

$( ".projectPeopleSearch" ).attr('autocomplete','off');
$( ".projectPeopleSearch" ).each(function(i, el) {
                el = $(el);
                lookUpId = el.attr("id");
                
            el.autocomplete({
        source: function( request, response ) {
                    console.log("Dans lookup");
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        //url : 'geo/search-place/' 
                        url: '/people/search/'
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'json',
                        data : {
                                    'query': el.val()
                                    //types: "place"
                                    },
                        success : function(data){
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title,
                                                    uri: object.identifier,
                                                    persname: object.title,
                                                    
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    //title: title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object
                                                    //refType : type
                                                    };
                                                   
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
/*            $( ".projectPeopleSearch" ).val(ui.item.label);*/
               $("#LoadingImage").show();         
              $("#peopleSearchResult").html("<strong>"+ ui.item.persname + "</strong> <em>" + ui.item.uri +"</em>");
              $("#peopleEditor").html('<strong><img src="$shared/resources/scripts/jquery/skin/loading.gif" /> Retrieving data for ' + ui.item.persname + " <em>" + ui.item.uri +'</em> ... </strong>')
/*              console.log(ui.item.uri.indexOf("#"));*/
              
/*              $("#peopleEditor").load("/people/get-record/" +ui.item.uri.substring(ui.item.uri.lastIndexOf("/")+1, ui.item.uri.indexOf("#")));*/
/*              console.log(ui.item.uri.substring(ui.item.uri.lastIndexOf("/")+1, ui.item.uri.indexOf("#")));*/
              var url = "/people/get-record/" + ui.item.uri.substring(ui.item.uri.lastIndexOf("/")+1, ui.item.uri.indexOf("#"));
/*              console.log(url);*/
              $.ajax({
      url: url,
       
       dataType: "html",
      cache: false,
      
      success: function(html){
      $("#LoadingImage").hide();         
        $("#peopleEditor").html(html);
/*        $('.info').append(html);*/
      },
      complete: function(){
/*        $('#loading-image').hide();*/
      }
    });

              /*$.ajax({
                        //url : 'geo/search-place/' 
                        url: '/people/get-record/' + ui.item.uri.substring(ui.item.uri.lastIndexOf("/")+1, ui.item.uri.indexOf("#"))
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'html',
                        
                        success : function(data){
                            console.log("sucess: " + JSON.stringify(data));
                            
                            $("#peopleEditor").html(data)
/\*                                $.map(*\/
                                   /\* data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title,
                                                    uri: object.identifier,
                                                    persname: object.title,
                                                    
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    //title: title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object
                                                    //refType : type
                                                    };
                                                   
                                        })*\/
                                        
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
              */
                
                        }
                    } );
                } );



$( ".projectPeopleLookup" ).attr('autocomplete','off');
$( ".projectPeopleLookup" ).each(function(i, el) {
                el = $(el);
                lookUpId = el.attr("id");
                
            el.autocomplete({
        source: function( request, response ) {
                    console.log("Dans lookup");
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        //url : 'geo/search-place/' 
                        url: '/people/search/'
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'json',
                        data : {
                                    'query': el.val()
                                    //types: "place"
                                    },
                        success : function(data){
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title,
                                                    uri: object.identifier,
                                                    persname: object.title,
                                                    
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    //title: title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object
                                                    //refType : type
                                                    };
                                                   
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
            $( ".projectPeopleLookup" ).val(ui.item.label);
                        
              $("#selectedPeopleUri").val(ui.item.uri);
              $("#projectPeopleDetailsPreview").html("<strong>"+ ui.item.persname + "</strong> <em>" + ui.item.uri +"</uri>");
                if ($('#addProjectPeopleButtonDocPlaces').hasClass('hidden') === true) {
                                $("#addProjectPeopleButtonDocPlaces").toggleClass("hidden");
                                
                         
                            } else {
                                
                         };
                        }
                    } );
                } );

$( ".functionsLookup" ).attr('autocomplete','off');
$( ".functionsLookup" ).autocomplete({
        source: function( request, response ) {
                    console.log("Dans lookup");
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        //url : 'geo/search-place/' 
                        url: '/people-functions/search/'
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'json',
                        data : {
                                    'query': $('#functionsLookup').val()
                                    //types: "place"
                                    },
                        success : function(data){
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title + " " + object.identifier,
                                                    uri: object.identifier,
                                                    persname: object.title,
                                                    
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    title:  object.title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object
                                                    //refType : type
                                                    };
                                                   
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
                    $(this).val(ui.item.label);
              $("#selectedFunctionUri").val(ui.item.uri);
              $("#functionDetailsPreview").html("<strong>"+ ui.item.persname + "</strong> <em>[" + ui.item.uri +"]</em>");
              
             
            

            }
    } );
    
$( ".functionTargetLookup" ).attr('autocomplete','off');
$( ".functionTargetLookup" ).autocomplete({
        source: function( request, response ) {
                    console.log("Dans lookup");
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        //url : 'geo/search-place/' 
                        url: '/people-functionTarget/search/'
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'json',
                        data : {
                                    'query': $('#functionTargetLookup').val()
                                    //types: "place"
                                    },
                        success : function(data){
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title + " " + object.identifier,
                                                    uri: object.identifier,
                                                    persname: object.title,
                                                    
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    //title: title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object
                                                    //refType : type
                                                    };
                                                   
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
             $(this).val(ui.item.label);
                    $("#detailsPreview").toggleClass("hidden");
              $("#targetUri").val(ui.item.uri);
              $("#targetDetailsPreview").html("<strong>"+ ui.item.persname + "</strong> <em>[" + ui.item.uri +"]</em>");
               
            }
    } );

$( ".bondTypesLookup" ).attr('autocomplete','off');
$( ".bondTypesLookup" ).each(function(i, el) {
                el = $(el);
                lookUpId = el.attr("id");
                     
            el.autocomplete({
        source: function( request, response ) {
                    var elementId = $(this.element).prop("id");
               
                    console.log("in bond type lookup " + elementId);
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        //url : 'geo/search-place/' 
                        url: '/people-bondtypes/search/'
                                //+$('#projectPlacesLookUp').val()
                                ,
                        dataType : 'json',
                        data : {
                                    'query': el.val()
                                    //types: "place"
                                    },
                        success : function(data){
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            response(
                                $.map(
                                    data.list.items, function(object){
                                    
                                       return {
                                                    
                                                    label: object.title + " " + object.identifier,
                                                    uri: object.identifier,
                                                    persname: object.title,
                                                    
                                                    //author: object.data.creators[0].lastName,
                                                    //date: object.data.date,
                                                    title:  object.title,
                                                    //title: object.data.title,
                                                    //value: object.key,
                                                   // key: object.data.key,
                                                    fullData: object
                                                    //refType : type
                                                    };
                                                   
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
      
            event.preventDefault();
            var elementId = $(this.element).prop("id");
                    $(this).val(ui.item.label);
              $("#selected" + $(this).attr("id")).val(ui.item.uri);
/*              $("#functionDetailsPreview").html("<strong>"+ ui.item.persname + "</strong> <em>[" + ui.item.uri +"]</em>");*/
              
             
            

            }
    } );
    });
    
    
    // Trigger queryPeople.xql on enter in input searchPeople
$('#searchPeople').bind("enterKey",function(e){
    console.log($(this).val());
     $("#LoadingImage").show();
    

/*   $("#peopleSearchResult").load("/people/query/" + $(this).val() + "*");*/
   $.ajax({
      url: "/people/query/",
       data : {
            'query': $(this).val() + "*"
                        
                                    },
      dataType: "html",
      cache: false,
      
      success: function(html){
      $("#LoadingImage").hide();
      $(this).autocomplete("destroy");
        $("#peopleSearchResult").html(html)
/*        $('.info').append(html);*/
      },
      complete: function(){
        $('#loading-image').hide();
      }
    });
   
   
});
$('#searchPeople').keyup(function(e){
    if(e.keyCode == 13)
    {
        $(this).trigger("enterKey");
    }
});

 });/*   End of ready Function*/



function displayPerson(id){
    $("#peopleEditor").load("/people/get-record/" + id);
    history.pushState(null, null,  "/people/" + id);
    document.title = "People " + " - " + id;
};

function openNewPersonForm(){
    $("#peopleEditor").load("$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=newPersonForm");
    history.pushState(null, null,  "/people/new");
    document.title = "Creation of a new person";
};


function openBiblioDialog(){
    $('#dialogInsertBiblio').modal('show');
};






function editValue(xmlElementNickname, index, cardinality){
/*          xmlElementNickname --> used as prefix of input name
 *          index -->   index no of corresponding xml div/@type='textpart'; default = 1
 *          cardinality  --> used when a cardinality of field is > 1
 * */

        if(cardinality != null) {var card = "_" + cardinality} else{var card =""};
        console.log("card : " + card);
        console.log("Input Element Value: " + "#" +xmlElementNickname+"_display_"+ index + card);
        console.log("Input Element Input: " + "#" +xmlElementNickname+"_edit_" + index + card);
        var idElementValue= "#" +xmlElementNickname+"_display_"+ index + card;
        var idElementInput= "#" +xmlElementNickname+"_edit_" + index + card;
        /*console.log("idElementValue= " + idElementValue);
        console.log("idElementInput= " + idElementInput);*/
        $(idElementValue).toggleClass("xmlElementHidden");
        $(idElementInput).toggleClass("xmlElementHidden");

};


function cancelEdit(xmlElementNickname,
            index,
            originalValue,
            type,
            cardinality){
        console.log("Cancel edit")
        if(index == null) { ind =""} else {var ind = index}
        if(cardinality != null) {var card = "_" + cardinality} else{var card =""};
        var idElementDisplay= "#" +xmlElementNickname+"_display_"+ ind + card;
        var idElementEdit= "#" +xmlElementNickname+"_edit_" + ind + card;
        var elementInput= $("#" + xmlElementNickname + "_" + ind + card);
/*        console.log("idElementValue= " + idElementValue);*/
/*        console.log("idElementInput= " + idElementInput);*/
        console.log ("idElementDisplay: " + idElementDisplay);
        $(idElementDisplay).toggleClass("xmlElementHidden");
        $(idElementEdit).toggleClass("xmlElementHidden");
        if(type=='input'){
        elementInput.val(originalValue);
        elementInput.html(originalValue);
        }

};


function addData(element,
                            personUri,
                            input,
                            xmlElementNickname,
                            xpath,
                            contentType,
                            index,
                            topConceptId){
    /* console.log("element (normally this): " + element); */
/*  console.log("UsRI= " + $(element).siblings().children().find('.elementWithValue').prop("tagName"));*/
/*  console.log("Textual value= " );*/

  // if(index == null) { ind =""} else {var ind = index}
  //         var elementDisplay= $("#" +inputName +"_display_" + ind.toString()+ "_" + cardinality);
  //         var elementValue= $("#" + inputName +"_value_"+ ind.toString()+ "_" + cardinality);
  //         var elementEdit= $("#" +inputName +"_edit_" + ind.toString()+ "_" + cardinality);
  //         var elementInput= $("#" +inputName + "_" + ind.toString() + "_" + cardinality);

      switch(contentType){
                      case "textNodeAndAttribute":
                            var elementGroup = $(element).parents().closest('.xmlElementGroup');
                            var elementInput =$("#" + input).find(".elementWithValue");
                            console.log("elementGroup: " + $(elementGroup).attr('id'));
                            console.log("input varaible: " + input);
                            
                            var tagName = elementInput.prop("tagName");
                          break;
                      default:
                      
                        if($("#lang_" + xmlElementNickname + "_add"))
                            {var lang =$("#lang_" + xmlElementNickname + "_add option:selected").text().trim();}
                            
                         console.log("test select: " + lang);
                        
                        
                        console.log($('#' + xmlElementNickname + "_text_" + index + "_1").text());
/*                      var elementInput = $(element).siblings().children().find('.elementWithValue');*/
                        var elementGroup = $(element).parents().closest('.xmlElementGroup');
                        var elementGroupId = $(elementGroup).attr('id');
                        console.log("elementGroup: " + $(elementGroup).attr('id'));
                        console.log("Input: " + $("#" + elementGroupId).find('.elementWithValue').text());
                       var elementInput = $(elementGroup).find('.elementWithValue');
                       var tagName = elementInput.prop("tagName");
                        break;
      }
      
      
      
      console.log("Tagname: " + tagName);
      console.log("contentType: " + contentType);
               switch(tagName){
                   case "BUTTON":
                      var newValue = elementInput.attr('value');
                      
                        var newValueTxt =  elementInput.text().trim();
                        console.log("NewValueTxt in button: " +newValueTxt );
                      console.log("newValue:" + newValue);
                      break;
                      
                   case "INPUT":
                            switch(contentType){
                               case "text": 
                                 newValue = elementInput.val();
                                 newValueTxt = elementInput.val();
                                 break;
                               
                               case "textNodeAndAttribute":
                                 newValue = $("#" + xmlElementNickname + "_add_attrib_" + index + "_1").val();
                                 newValueTxt = $("#" + xmlElementNickname + "_add_text_" + index + "_1").val();
                                 console.log("text= " + newValueTxt + " | attrib= " + newValue);
                                 break;
                               default: 
                                 newValue = elementInput.val();
                                 break;
                            }
                        break;
                       
                   case "SELECT":
                      newValue = elementInput.val();
                      break;
                   default:
                      newValue = elementInput.attr('value') ;
                      break;
               }
      //console.log("Value:: " + newValue);
                if (newValueTxt != "") {var valueText = newValueTxt}
                else {var valueText = elementInput.text()}
                console.log("newValueTxt: " + newValueTxt);
                console.log("valueText: " + valueText);
                console.log("elementInput.text(): " + elementInput.text().trim);
   // console.log("value textual value= " + input.text());
        var xmlData = "<xml>"
                        + "<personUri>" + getCurrentPeopleUri() + "</personUri>"
                        + "<inputName>" + input + "</inputName>"

                        + "<value>" + newValue + "</value>"
                        + "<valueTxt>" + valueText + "</valueTxt>"
                        + "<xmlElementNickname>" + xmlElementNickname + "</xmlElementNickname>"
                        + "<xpath>" + xpath + "</xpath>"
                        + "<contentType>" + contentType + "</contentType>"
                        + "<topConceptId>" + topConceptId + "</topConceptId>"
                        + "<lang>" + lang + "</lang>"
                        +"</xml>";
         console.log("xmlData = " + xmlData);

         //var input = inputName;
         //var inputId = "#" + inputName.name.toString();

         var request = new XMLHttpRequest();
         request.open("POST", "$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=addData" , true);
         /*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                    //+ "&project=" + "patrimonium" + "&xpath=" + xpath
         /*                , true);*/
         var xmlDoc;

         request.onreadystatechange = function() {


           //TODOAPPEND TO GROUP
            if (request.readyState == 4 && request.status == 200) {
                var select = elementInput;
                xmlDoc = request.responseXML;
                xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
                newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
                elementGroup.html(newElement2Display);
                refreshXmlFile(xmlString);
                /*            
/*                 $(elementGroup).replaceWith(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')));
                 console.log("xmlDoc: " + xmlDoc);
                 var tagName = elementInput.prop("tagName");
                 switch(tagName){
                     case "BUTTON":
                        newValue2Display = elementInput.text();
                        break;
                     case "INPUT":
                        newValue2Display = elementInput.val();
                        console.log("NEW VAlUE: " + newValue2Display);
                        break;
                     case "SELECT":
                        //var el = document.getElementById(inputName.name.toString());
                        newValue2Display = elementInput.find(":selected").text();
                        break;
                     default:
                        newValue2Display = elementInput.attr('value') ;
                        break;
                 }
*/


                 //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*                 elementDisplay.toggleClass("xmlElementHidden");*/
                 //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
                 //console.log("Response : Value of xmlDoc" + xmlDoc);
                 //console.log("Id of element" + idElementValue);

                 //$(idElementValue).text(xmlDoc.xml.value)
/*                 elementEdit.toggleClass("xmlElementHidden");*/
/*                 if(inputName == "docTitle"){$("#docMainTitle").html(newValue2Display)};*/
                }

                };

         request.setRequestHeader('Content-Type', 'text/xml');

            request.send(xmlData);




};

function addItem(element, item, index){
/*          xmlElementNickname --> used as prefix of input name
 *          index -->   index no of corresponding xml div/@type='textpart'; default = 1
 *
 * */

        $(element).parents().closest(".xmlElementGroup").find('.xmlElementAddItem').toggleClass("xmlElementHidden");

};


function saveData(resourceURI,
                                inputName_text,
                                input_name_attrib,
                                elementNickName,
                                xpath,
                                contentType,
                                index, 
                                cardinality){
/*    console.log("Value of " + inputName.name.toString()  + ": " + $(inputName).val());*/
console.log("contentType" + contentType);
console.log("#" + inputName_text + "_" + index + "_" + cardinality);
console.log("#" + input_name_attrib+ "_" + index + "_" + cardinality);
var inputElementForText = $("#" + inputName_text + "_" + index + "_" + cardinality);
var inputElementForAttrib = $("#" + input_name_attrib+ "_" + index + "_" + cardinality);
if(index == null) { ind =""} else {var ind = index}
if(inputElementForText.prop("tagName") === null)
                            {var tagName = "INPUT"}
                            else{
                                var tagName = inputElementForText.prop("tagName");
                    var elementGroup = $(inputElementForText).parents().closest('.xmlElementGroup');                          
                            };
                            
        console.log("Tagnme: " + tagName);
        console.log($(elementGroup).attr('id'));
        
        var elementDisplay= $("#" +elementNickName +"_display_" + ind.toString()+ "_" + cardinality);
        var elementValue= $("#" + elementNickName +"_value_"+ ind.toString()+ "_" + cardinality);
        var elementEdit= $("#" +elementNickName +"_edit_" + ind.toString()+ "_" + cardinality);
        var elementInput= $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality);
        
        /*switch(contentType){
                      case "textNodeAndAttribute":
                        //var elementGroup = $(inputName).parents().closest('.xmlElementGroup');
                        //console.log("elementGroup: " + $(elementGroup).attr('id'));
                       //console.log("tagname loop" + tagName);
                      break;
                      
                      default:
/\*                        var tagName = elementInput.prop("tagName");*\/
                        console.log("Tganame: " + tagName);              
                        };      */        
        
             switch(tagName){
                 case "BUTTON":
                    newValue = inputElementForText.attr('value');
                    console.log("new value: " + newValue);
                    newValueTxt = inputElementForText.text().trim();
                    console.log("newValueTxt: " + newValueTxt + "newValue: " +newValue);
                    break;
                 case "INPUT": case "TEXTAREA":
                    switch(contentType){
                      case "text": 
                        newValue = elementInput.val();
                        newValueTxt = elementInput.val();  
                        console.log("New value in 470" + newValueTxt);
                      break;
                    case "textNodeAndAttribute":
                        newValue = inputElementForAttrib.val();
                        newValueTxt = inputElementForText.val();
                        console.log("text= " + newValueTxt + " | attrib= " + newValue);
                        break;
                      case "nodes":
                        newValue = inputElementForText.val();
                        newValueTxt = inputElementForText.val();
                        console.log("text= " + newValueTxt + " | attrib= " + newValue);
                        break;
                      default: 
                        newValue = elementInput.val();
                        console.log("In switch tagname default return: " + newValueTxt );
                        break;
                        }  
                    break;
                 case "SELECT":
                        switch(contentType){
                        case("textNodeAndAttribute"):
                            newValue = $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality + ' option:selected').val();
                            newValueTxt = $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality + ' option:selected').attr("textValue");
                            console.log("newValue: " + newValue );
                            console.log("newValueTxt: " + newValueTxt );
                          break;}
                    break; //for case select
                 default:
                    newValue = elementInput.val() ;
                    newValueTxt = elementInput.val();
                    break;
             };
             
    //console.log("Value:: " + newValue);
    //console.log("Input Id:: " + elementNickName + "_" + index + "_" + cardinality );
    var xmlData = "<xml>"
                    + "<elementNickname>" + elementNickName + "</elementNickname>"
                    + "<inputName>" + inputName_text + "</inputName>"
                    + "<resourceURI>" + resourceURI + "</resourceURI>"
                    + "<value>" + newValue + "</value>"
                    + "<valueTxt>" + newValueTxt + "</valueTxt>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<contentType>" + contentType + "</contentType>"
                    + "<index>" + cardinality + "</index>"
                    +"</xml>";
     console.log("xmlData = " + xmlData);

     //var input = inputName;
     //var inputId = "#" + inputName.name.toString();

     var request = new XMLHttpRequest();
     console.log("docURI = " + resourceURI);
     request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=saveData", true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            var select = elementInput;
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
             newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
/*             console.log("newElement2Display: " + newElement2Display);*/
             oldValueTxt = xmlDoc.getElementsByTagName('oldContent')[0].textContent;
             console.log("oldValueTxt:" + oldValueTxt);
/*             console.log("TEST element name: " + elementInput.prop("tagName"));*/
/*             console.log("newElement2Display" + newElement2Display);*/
             var tagName = elementInput.prop("tagName");
             switch(tagName){
                 case "BUTTON":
                    newValue2Display = elementInput.text();
                    break;
                 case "INPUT":
                    switch(contentType){
                            case "text":
                               newValue2Display = elementInput.val();
                               console.log("NEW VAlUE in case Input: " + newValue2Display);
/*                               console.log("new content" + xmlString) ; */
                            break;
                            case "textNodeAndAttribute":
                                newValue = $("#" + elementNickName + "_attrib_" + index + "_" + cardinality).val();
                                newValueTxt = $("#" + elementNickName + "_text_" + index + "_" + cardinality).val();
                                newValue2Display = newValueTxt + " " + newValue;
                            break;};
                       break;
                    case "TEXTAREA":
                        newValue2Display = elementInput.val();
                        console.log("NEW VALUE: " + newValue2Display);
                        break;
                   case "SELECT":
                    //var el = document.getElementById(inputName.name.toString());
                    newValue2Display = elementInput.find(":selected").text();
                    break;
                 default:
                    newValue2Display = elementInput.attr('value') ;
                    break;
             }
/*            var xmlFile =  */


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");
             
             
             /*elementValue.html(function(i,t){
                            return t.replace(oldValueTxt, newValue2Display)});*/
             console.log("newElement2Display: " + newElement2Display);
             elementGroup.html(newElement2Display);
             
/*             console.log("newValue2Display: " + newValue2Display);*/
             elementDisplay.toggleClass("xmlElementHidden");
             //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
             //console.log("Response : Value of xmlDoc" + xmlDoc);
             //console.log("Id of element" + idElementValue);

             //$(idElementValue).text(xmlDoc.xml.value)
             elementEdit.toggleClass("xmlElementHidden");
             if(elementNickName == "docTitle"){$("#docMainTitle").html(newValue2Display)};
             
             refreshXmlFile(xmlString);
            }

            };

     request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function saveDataSimple(resourceURI,
                                            inputName,
                                            xpath,
                                            contentType,
                                            index,
                                            cardinality){
/*    console.log("Value of " + inputName.name.toString()  + ": " + $(inputName).val());*/
        console.log("contentType" + contentType);
        if(index == null) { ind =""} else {var ind = index};
        var elementDisplay= $("#" +inputName +"_display_" + ind.toString()+ "_" + cardinality);
        var elementValue= $("#" + inputName +"_value_"+ ind.toString()+ "_" + cardinality);
        var elementEdit= $("#" +inputName +"_edit_" + ind.toString()+ "_" + cardinality);
        var elementInput= $("#" +inputName + "_" + ind.toString() + "_" + cardinality);
        
        /*
        if($(inputName).parents().closest('.xmlElementGroup')) {
                        var elementGroup = $(inputName).parents().closest('.xmlElementGroup');}
                        else {var elementGroup = $("#" + inputName + "_group_" +  ind.toString() )};
        */
        console.log("elementInput: " + $(elementInput).attr('id'));
        
/*        var elementGroup = $("#" + inputName + "_group_" +  ind.toString() );*/
        var elementGroup = elementDisplay.parents().closest('.xmlElementGroup');
        console.log("elementGroup : " + JSON.stringify(elementGroup));
        switch(contentType){
                      case "textNodeAndAttribute":
                        //var elementGroup = $(inputName).parents().closest('.xmlElementGroup');
                        console.log("inputName: " + inputName);
                        console.log("elementGroup: " + $(elementGroup).attr('id'));
                        if(elementInput.prop("tagName") === null)
                            {var tagName = "INPUT"}
                            else{
                                var tagName = elementInput.prop("tagName");
                                
                            };
                            console.log("tagname loop" + tagName);
                      break;
                      default:
                        var tagName = elementInput.prop("tagName");
                        console.log("Tganame: " + tagName);              
                        }              
        
             switch(tagName){
                 case "BUTTON":
                    newValue = elementInput.attr('value');
                    newValueTxt = elementInput.text()
                    break;
                 case "INPUT":
                    switch(contentType){
                      case "text":
                      case "attribute":
                        newValue = elementInput.val();
                        newValueTxt = elementInput.val();  
                      break;
                      case "textNodeAndAttribute":
                        newValue = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val();
                        newValueTxt = $("#" + inputName + "_text_" + index + "_" + cardinality).val();
                        console.log("text= " + newValueTxt + " | attrib= " + newValue);
                        break;
                      default: 
                      newValueTxt = elementInput.val(); 
                        newValue = elementInput.val();
                        break;
                        }  
                    break;
                 case "SELECT":
                    newValue = elementInput.val();
                    newValueTxt = elementInput.val();
                    break;
                 default:
                    newValue = elementInput.val() ;
                    newValueTxt = elementInput.val();
                    break;
             }
             
    console.log("Value:: " + newValue);
    console.log("Input Id:: " + inputName + "_" + index + "_" + cardinality );
    var xmlData = "<xml>"
                    + "<elementNickname>" + inputName + "</elementNickname>"
                    + "<inputName>" + inputName + "_" + index + "_" + cardinality + "</inputName>"
                    + "<resourceURI>" + encodeURI(resourceURI) + "</resourceURI>"
                    + "<value>" + newValue + "</value>"
                    + "<valueTxt>" + newValueTxt + "</valueTxt>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<contentType>" + contentType + "</contentType>"
                    + "<index>" + cardinality + "</index>"
                    +"</xml>";
     console.log("xmlData = " + xmlData);

     //var input = inputName;
     //var inputId = "#" + inputName.name.toString();

     var request = new XMLHttpRequest();
     
     request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=saveData", true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            var select = elementInput;
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
             newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
/*             console.log("newElement2Display: " + newElement2Display);*/
             oldValueTxt = xmlDoc.getElementsByTagName('oldContent')[0].textContent;
             
             elementIdToReplace = xmlDoc.getElementsByTagName('elementIdToReplace')[0].textContent;
            /*  newElement = xmlDoc.getElementsByTagName('updatedElement')[0].textContent; */
             /* console.log("newElement2Display for " + elementIdToReplace +": " + newElement); */
             
/*             generalCommentary_value_1_1*/
             /* $("#" +elementIdToReplace).replaceWith(newElement); */
             
             /*console.log("elementIdToReplace:" + elementIdToReplace);
             console.log("TEST element name: " + elementInput.prop("tagName"));
             var tagName = elementInput.prop("tagName");
             switch(tagName){
                 case "BUTTON":
                    newValue2Display = elementInput.text();
                    break;
                 case "INPUT":
                    switch(contentType){
                      case "text":
                        newValue2Display = elementInput.val();
                        console.log("NEW VAlUE: " + newValue2Display);
                        
                        console.log("new content" + xmlString) ; 
                        
                        
                        break;
                      case "textNodeAndAttribute":
                          newValue = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val();
                          newValueTxt = $("#" + inputName + "_text_" + index + "_" + cardinality).val();
                          newValue2Display = nexValueTxt + " " + newValue;
                      break;}
                    case "TEXTAREA":
                    newValue2Display = elementInput.val();
                    console.log("NEW VAlUE: " + newValue2Display);
                    break;
                   case "SELECT":
                    //var el = document.getElementById(inputName.name.toString());
                    newValue2Display = elementInput.find(":selected").text();
                    break;
                 default:
                    newValue2Display = elementInput.attr('value') ;
                    break;
             }*/
/*            var xmlFile =  */


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");
             
             /*
             elementValue.html(function(i,t){
                            return t.replace(oldValueTxt, newValue2Display)});
                            */
                            
                            
             elementGroup.html(newElement2Display);
/*             console.log("elementGroup " + elementGroup.html());*/
             //console.log("newValue2Display: " + newValue2Display);
             elementDisplay.toggleClass("xmlElementHidden");
             //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
             //console.log("Response : Value of xmlDoc" + xmlDoc);
             //console.log("Id of element" + idElementValue);

             //$(idElementValue).text(xmlDoc.xml.value)
             elementEdit.toggleClass("xmlElementHidden");
             if(inputName == "docTitle"){$("#docMainTitle").html(newValue2Display)};
             
             refreshXmlFile(xmlString);
            }

            };

     request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData.toString());


};

function saveXmlFile(resourceURI){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");
console.log(getXmlEditorContent());
var xmlData = "<xml>"
                    + "<resourceURI>" + resourceURI + "</resourceURI>"
                    + "<newContent>" + getXmlEditorContent() + "</newContent>"
                    +"</xml>";
        console.log("NEw content to be saved: " + xmlData);
     var request = new XMLHttpRequest();
     request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=saveXmlFile", true);
     
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
             newFile2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedFile')[0]);
             $("#peopleEditor").html(newFile2Display);
             
             $("body").css("cursor", "default");
             $("body").css("opacity", "1");

            }

            };

     request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function saveTextarea(resourceUri, textareaId, elementNickName, xpath, index){
    
    var no = index;
/*    console.log("Index= " + index + " *** no= " + no);*/
  var elementInput= $("#" +textareaId);  
  var newText = newValueTxt = elementInput.val().replace('<br>', '<br/>').replace('&nbsp;', ''); 
  
  var oParser = new DOMParser();
  var oDOM = oParser.parseFromString("<text>" + newText + "</text>", "text/xml");
    
    if(isParseError(oDOM)) {
            alert(getXMLError(oDOM.documentElement));
    }
    else{
    $("body").css("cursor", "wait");
console.log("newText: " + newText);
    var xmlData = "<xml>"
                    + "<inputName>" + textareaId + "</inputName>"
                    + "<resourceUri>" + resourceUri + "</resourceUri>"
                    + "<elementNickName>" + elementNickName  + "</elementNickName>"
                    + "<index>" + no + "</index>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<newText>" + newText + "</newText>"
                    +"</xml>";

    var request = new XMLHttpRequest();
    request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=saveTextarea" , true);

var xmlDoc;
var xmlDocXML;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);
            refreshXmlFile(xmlString);
            $("#body").removeClass('overlap');

            $("#" + textareaId + "_message").css("display", "block");
            $("#" + textareaId + "_message").html("Text has been saved...");
            $("#" + textareaId + "_message").css('background-color', '#a8fa78');
/*            $("#" + textareaId + "_message").css('color', 'white');*/
/*            $("#messageZone").css('top', '0');*/
            $("#" + textareaId + "_message").fadeOut(3000);
/*            $("#editionAlert" + no).fadeOut(500);*/
            
/*            $("#saveTextButton" + no).fadeOut(1000);*/
/*            $("#messageZone").css("display", "none");*/


             //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");

/*             $(idElementValue).html(newValue2Display);*/


/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/
            $("body").css("cursor", "default");

            } // END of (request.readyState == 4 && request.status == 200) {

        if (request.status == 400) {
            alert("Text could not be saved. \n" + "Error " + request.status + ".\n" + request.responseText);
        }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
};
};



function isParseError(parsedDocument) {
    // parser and parsererrorNS could be cached on startup for efficiency
    var parser = new DOMParser(),
        errorneousParse = parser.parseFromString('<', 'text/xml'),
        parsererrorNS = errorneousParse.getElementsByTagName("parsererror")[0].namespaceURI;

    if (parsererrorNS === 'http://www.w3.org/1999/xhtml') {
        // In PhantomJS the parseerror element doesn't seem to have a special namespace, so we are just guessing here :(
        return parsedDocument.getElementsByTagName("parsererror").length > 0;
    }

    return parsedDocument.getElementsByTagNameNS(parsererrorNS, 'parsererror').length > 0;
};

function refreshXmlFile(newContent){
    var xmlFileEditor = ace.edit("xml-editor-file");
    xmlFileEditor.setValue(newContent);
/*            $("#messageZone").fadeOut(1);*/
/*            $("#fileModifiedAlert" ).fadeOut(1);*/
/*            $("#saveFileButton" ).fadeOut(1);*/
/*             $("#body").toggleClass('overlap');*/
/*                $("#messageZone").css('background-color', '#8c0000');*/
/*            $("#messageZone").css('color', 'white');*/
    
};

function openDialog(dialogId){
    dialogId = "#" + dialogId;
    $(dialogId).modal('show');
    };
function openDialog(dialogId, option){
    dialogElement = "#" + dialogId;
    console.log("dialogId= " + dialogId)
    $(dialogElement).modal('show');
/*    $("#placeTypeSelection").val(option)*/
    
    };
    

$( ".zoteroLookup" ).attr('autocomplete','off');
$( ".zoteroLookup" ).autocomplete({
        source: function( request, response ) {
                    var zoteroGroup = $("#zoteroGroupNo").text();
                    var elementId = $(this.element).prop("id");
                    var type = elementId.substr(elementId.lastIndexOf('Modal')+ 5);
                    
                    $.ajax({
                        url : 'https://api.zotero.org/groups/' + zoteroGroup + '/items?',
                        dataType : 'json',
                        data : {
                                    q: $('#zoteroLookupInputModal' + type).val(),
                                    qmode: "everything"
                                    //types: "place"
                                    },
                        beforeSend: function(){
                        
                        $('html, body').css("cursor", "progress");},
                        success : function(data){
                    
                    /*console.log("group: " +zoteroGroup);*/
                            /*console.log("sucess: " + JSON.stringify(data));*/
                            $('html, body').css("cursor", "default");
                            response(
                            $.map(
                                data, function(object){
                                    console.log(JSON.stringify(object.data));
                                       if(object.data['creators'])
                                        {if(object.data.creators[0].lastName){var author = object.data.creators[0].lastName}
                                            else if (object.data.creators[0].surname){var author = object.data.creators[0].surname}
                                        }
                                        else{var author =""}
                                       if(object.data.title!='') {var title = object.data.title}
            
            /*                           console.log("title: " + title);*/
            /*                           console.log("Author: " + author);*/
            /*                           console.log("ID: " + object.key);*/
                                            console.log("Fulldata de Zotero: " + JSON.stringify(object.data));
                                            console.log("OWLSAMEAS: " + JSON.stringify(object.data.relations["owl:sameAs"]));
                                              
                                       return {
                                                    label: author + "  " + object.data.date + ", " + title + ' (Zotero key: ' + object.key + ')',
                                                    author: author,
                                                    //author: object.data.creators[0].lastName,
                                                    date: object.data.date,
                                                    title: title,
                                                    //title: object.data.title,
                                                    value: object.key,
                                                    key: object.data.key,
                                                    fullData: object.data,
                                                    refType : type
                                                    };
                                        }));
            
                            },
                                error:function(){ 
                                console.log("Erreur");
                                }
                        });
        }, //End of Source
      minLength: 3,
      select: function( event, ui ) {
                                            console.log("refType: " + ui.item.refType); 
            var type = ui.item.refType;
            event.preventDefault();
            $('#zoteroLookupInputModal' + type).val(ui.item.label);


/*              $("#selectedBiblioAuthor").html("Author: " + ui.item.fullData.creator[0].firstName + " " + ui.item.fullData.creator[0].lastName);*/
              $("#selectedResourceAuthor" + type).html("Author: " + ui.item.author);
              $("#selectedResourceDate"+ type).html("Date: " + ui.item.fullData.date);
              $("#selectedResourceTitle"+ type).append('Title: <em>' + ui.item.title + '</em>')
              $("#selectedResourceUri"+ type).html("URI: " + ui.item.uri);
              $("#selectedResourceId"+ type).html(ui.item.value);
              ;

            }
    } );




function createNewPerson(){
    var standardizedName= $("#newPersonStandardizedNameEn").val();
    var sex = $("#sex_1_").text().trim();
    var sexUri = $("#sex_1_").val();
    //$("#newPersonSex").val();
    
    var personalStatusText = $("#personalStatus_1_").text().trim();
    var socialStatusText = $("#socialStatus_1_").text().trim();
    var juridicalStatusText= $("#juridicalStatus_1_").text().trim();
    var personalStatusUri = $("#personalStatus_1_").val();
    var socialStatusUri = $("#socialStatus_1_").val();
    var juridicalStatusUri= $("#juridicalStatus_1_").val();
    var request = new XMLHttpRequest();

        if(standardizedName != ""){
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");

    var xmlData="<xml>"
                    + "<standardizedName>" + standardizedName + "</standardizedName>"
                    + "<sex>" + sex + "</sex>"
                    + "<sexUri>" + sexUri + "</sexUri>"
                    + "<personalStatus>" + personalStatusText + "</personalStatus>"
                    + "<socialStatus>" + socialStatusText + "</socialStatus>"
                    + "<juridicalStatus>" + juridicalStatusText + "</juridicalStatus>"
                    + "<personalStatusUri>" + personalStatusUri + "</personalStatusUri>"
                    + "<socialStatusUri>" + socialStatusUri + "</socialStatusUri>"
                    + "<juridicalStatusUri>" + juridicalStatusUri + "</juridicalStatusUri>"
                 +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=createNewPerson" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log("xmlDoc: " + xmlDocXml);
             
             
            console.log(xmlDocXml.getElementsByTagName('newHtml')[0].getElementsByTagName( 'div' )[0].childNodes);
            newHtml= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newHtml')[0]);
            newPersonId= xmlDocXml.getElementsByTagName('newId')[0].childNodes[0].nodeValue;
              $("#peopleEditor").html(newHtml);
              history.pushState(null, null,  "/edit-people/" + newPersonId);
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        //var tree = $("#collection-tree").fancytree("getTree");
        var newSourceOption = {
                            url: '/people/build-tree/'};
        //tree.reload(newSourceOption);
        //$("#collection-tree").fancytree("getTree").activateKey(newPersonId);
/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
} else {alert("Please enter at least one standardized name in English");}

};


function addResourceToPerson(zoteroGroup, type){
    event.preventDefault();  
    $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        $("button").attr("disabled", true);
        $("input").attr("disabled", true);
/*    if($('#addResourceForm').valid() == true) { */
    
    var resourceId = $('#selectedResourceId').html();
    var citedRange = $('#citedRange').val();
    var request = new XMLHttpRequest();
    var personUri = getCurrentPeopleUri();

    var xmlData="<xml>"
                    + "<personUri>" + personUri + "</personUri>"
                    + "<zoteroGroup>" + zoteroGroup + "</zoteroGroup>"
                    + "<type>" + type + "</type>"
                    + "<resourceId>" + resourceId + "</resourceId>"
                    + "<citedRange>" + citedRange + "</citedRange>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=addResourceToPerson" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             console.log("xmlDocXML: " + JSON.stringify(xmlDocXML));
             console.log("xmlDocText: " + xmlDoc);
             responseStatus = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('status')[0]);
             console.log("responseStatus : " + responseStatus);
             
             if(responseStatus.includes("errorAlready")){
                    $("body").css("cursor", "default");
                    $("body").css("opacity", "1");
                    $("button").attr("disabled", false);
                    alert("This reference is already in your document");
             }
                 else{
                        
/*                        xmlString = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);*/
                        newContent= (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);
                        /*console.log(newContent);*/
                        $("#zoteroLookupInputModal").val("")
                        $("#citedRange").val("")
                        $(".valueField").html("");
                        $("body").css("cursor", "default");
                        $("body").css("opacity", "1");
                        $("button").attr("disabled", false);
                        $("input").attr("disabled", false);
                          
                       $('#dialogInsertResource' + type).modal('hide');
           /*            $('#mainBiblioList').html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))*/
           /*            $('#mainBiblioList').html(newBiblList);*/
/*                       console.log("New biblio list: " + newBiblList);*/
                  
                  $('#resourcesManager' + type).replaceWith(newContent);
                        //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");
           
           /*             $(idElementValue).html(newValue2Display);*/
           
           
           /*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*                        refreshXmlFile(xmlString);*/
           /*             console.log("Id of element" + idElementValue);*/
                  
                 
    
                  };

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
        
};

function addResourceRef(docId, zoteroGroup, type){
    
/*    if($('#addResourceForm').valid() == true) { */
    
    var resourceId = $('#selectedResourceId').html();
    var citedRange = $('#citedRange').val();
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<docId>" + docId + "</docId>"
                    + "<zoteroGroup>" + zoteroGroup + "</zoteroGroup>"
                    + "<type>" + type + "</type>"
                    + "<resourceId>" + resourceId + "</resourceId>"
                    + "<citedRange>" + citedRange + "</citedRange>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=addResource" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             console.log("xmlDocXML: " + JSON.stringify(xmlDocXML));
             console.log("xmlDocText: " + xmlDoc);
             responseStatus = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('status')[0]);
             console.log("responseStatus : " + responseStatus);
             if(responseStatus.includes("errorAlready")){
             alert("This reference is already in your document")}
             else{
                        
                        xmlString = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);
                        newBiblList= (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newBiblList')[0]);
                       $('#dialogInsertResource' + type).modal('hide');
           /*            $('#mainBiblioList').html(xmlDoc.substring(5, xmlDoc.lastIndexOf('<')))*/
           /*            $('#mainBiblioList').html(newBiblList);*/
                       console.log("New biblio list: " + newBiblList);
                       $('#mainBiblioList').html(newBiblList);
                        //$(idElementValue).html(el.options[el.selectedIndex].innerHTML + " (" + $(inputName).val().substring(1) + ")");
           
           /*             $(idElementValue).html(newValue2Display);*/
           
           
           /*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
                        refreshXmlFile(xmlString);
           /*             console.log("Id of element" + idElementValue);*/
                    };

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
        
/*}//End of valid form*/
/*else {console.log("Not OK")};*/
};

function changePlaceToNearTo(resourceUri, placeUri){
    
    var xmlData="<xml>"
                    + "<resourceUri>" + resourceUri + "</resourceUri>"
                    + "<placeUri>" + placeUri + "</placeUri>"
                    +"</xml>";
     var request = new XMLHttpRequest();
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=changePlaceToNearTo" , true);
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             
             responseStatus = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('status')[0]);
             console.log("respoqnseStatus : " + responseStatus);
                       newContent = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('newContent')[0]);
                       console.log(newContent);
                       $("#placeEditor").html(newContent);
            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
        
};
function checkReverse(){
    event.preventDefault();
    if($("#hasBondType_1_").val() != "" || $('#bondTypesLookup').val() !=""){
                    $("body").css("cursor", "wait");
                    $("body").css("opacity", "0.5");
                    $("button").attr("disabled", true);
                    var bondUri = $("#selectedPeopleUri").val();
                    if($('#bondTypesLookup').val() !="") {var bondTypeUri = $('#selectedbondTypesLookup').val()}
                                                    else {var bondTypeUri = $("#hasBondType_1_").val()};
                    
                    var request = new XMLHttpRequest();
                    var xmlData="<xml>"
                                    + "<currentPeopleUri>" + getCurrentPeopleUri() + "</currentPeopleUri>"
                                    + "<bondUri>" + bondUri + "</bondUri>"
                                    + "<bondTypeUri>" + bondTypeUri +"</bondTypeUri>"
                                +"</xml>";
                        console.log("xmldata: " + xmlData);
                        request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=getBondTypeReverse" , true);
                        var xmlDoc;
                
                     request.onreadystatechange = function() {
                        if (request.readyState == 4 && request.status == 200) {
                        xmlDoc = request.responseText;
                             xmlDocXml = request.responseXML;
                             console.log(xmlDocXml);
                        if(xmlDocXml.getElementsByTagName('bondReverseUri')[0].childNodes[0]) 
                                    {bondReverseUri= xmlDocXml.getElementsByTagName('bondReverseUri')[0].childNodes[0].nodeValue;}
                                    else {bondReverseUri = ""};
                        if(xmlDocXml.getElementsByTagName('bondReverseCode')[0].childNodes[0])
                                    {bondReverseCode = xmlDocXml.getElementsByTagName('bondReverseCode')[0].childNodes[0].nodeValue}
                                    
                                    else {bondReverseCode = ""};
                        bondReversePrefLabel= xmlDocXml.getElementsByTagName('bondReversePrefLabel')[0].childNodes[0].nodeValue;
                        if(bondReverseUri != ""){ var bondReverseCodeToDisplay = " (" + bondReverseUri + ")"}
                                    else {var bondReverseCodeToDisplay = ""};
                        $("#reverseSuggestion").html("<strong>Suggested reverse bond type: </strong>" + bondReversePrefLabel + bondReverseCodeToDisplay); 
                                        
                        $("#bondTypeReverseCode").val(bondReverseCode);
                        $("#bondReverseUri").val(bondReverseUri);
                        $("#selectReverseBondType").toggleClass("hidden");
                        $("#bondReverseTypesLookupDiv").toggleClass("hidden");
                        $("#checkReverseButton").toggleClass("hidden");
                        $("#addBondButton").toggleClass("hidden");
                        $("body").css("cursor", "default");
                        $("body").css("opacity", "1");
                        $("button").attr("disabled", false);
                }
                            };
                
                        request.setRequestHeader('Content-Type', 'text/xml');
                
                        request.send(xmlData);
            } else {alert("Please select a bond type");}

};

function addBond(){
    event.preventDefault();
    console.log('$("#selectedbondReverseTypesLookup").val(): ' + $("#selectedbondReverseTypesLookup").val());
    console.log('$("#hasBondType_1_").val(): ' + $("#hasBondType_1_").val());
    
   if($("#selectedPeopleUri").val()=="") 
    {alert("No person has been selected")}
    else{
    if((($("#bondTypeReverseCode").val() =="") || ($("#bondTypeReverseCode").val() === undefined)) 
            && ($("#hasBondTypeReverse_1_").val() == "") 
            && ($("#selectedbondReverseTypesLookup").val() == ""))
                    {alert("Please a reverse bond type ()");}
       /*else if ( ($("#hasBondTypeReverse_1_").val() == "") && ($("#selectedbondReverseTypesLookup").val() == ""))
                {alert("Please a reverse bond type -");}*/
                else {
                    $("body").css("cursor", "wait");
                    $("body").css("opacity", "0.5");
                    $("button").attr("disabled", true);
                    var bondUri = $("#selectedPeopleUri").val();
                    if($('#bondTypesLookup').val() !="") {var bondTypeUri = $('#selectedbondTypesLookup').val()}
                                                                    else {var bondTypeUri = $("#hasBondType_1_").val()};
                                    
                    if($("#selectedbondReverseTypesLookup").val() != "")
                            {var bondTypeReverseUri = $("#selectedbondReverseTypesLookup").val()}
                            else if ($("#hasBondTypeReverse_1_").val() != ""){ var bondTypeReverseUri =  $("#hasBondTypeReverse_1_").val();}
                            else {var bondTypeReverseUri =""}
                    var bondTypeReverseCode = $("#bondTypeReverseCode").val();
                    var request = new XMLHttpRequest();
                    var xmlData="<xml>"
                                    + "<currentPeopleUri>" + getCurrentPeopleUri() + "</currentPeopleUri>"
                                    + "<bondUri>" + bondUri + "</bondUri>"
                                    + "<bondTypeUri>" + bondTypeUri +"</bondTypeUri>"
                                    
                                    + "<bondTypeReverseUri>" + bondTypeReverseUri +"</bondTypeReverseUri>"
                                    + "<bondTypeReverseCode>" + bondTypeReverseCode +"</bondTypeReverseCode>"
                                +"</xml>";
                        console.log("xmldata: " + xmlData);
                        
                        console.log("bondTypeReverseUri: " + bondTypeReverseUri );
                        console.log("bondTypeUri : " + bondTypeUri );
                        console.log("bondTypeReverseCode: " + bondTypeReverseCode);
                        request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=addBond" , true);
                        var xmlDoc;
                
                     request.onreadystatechange = function() {
                        if (request.readyState == 4 && request.status == 200) {
                        xmlDoc = request.responseText;
                             xmlDocXml = request.responseXML;
                             console.log(xmlDocXml);
                        
                        newBondList= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newBondList')[0]);
     
                        $("#selectedPeopleUri").val("");
                        $("#projectPeopleLookup").val("");
                        $("#reverseSuggestion").html("");
                        $("#bondReverseCode").val("");
                        $("#bondReverseUri").val("");
                        $("#hasBondTypeReverse_1_").val("");
                        $("#hasBondType_1_").val("");
                        $("#bondTypesLookup").val("");
                        //$("#hasBondTypeReverse_1_").toggleClass("hidden");
                        $("#hasBondType_1_").html('Select an item<span class="caret"></span>');
                        $('#projectPeopleDetailsPreview').html("");
                        $('#reverseSuggestion').html("");
                        $("#selectedbondTypesLookup").val("");
                        $("#selectedbondReverseTypesLookup").val("");
                        $("#bondReverseTypesLookupDiv").toggleClass("hidden");
                        
                        
                        $("#selectReverseBondType").toggleClass("hidden");
                        
                        $("#checkReverseButton").toggleClass("hidden");
                        $("#addBondButton").toggleClass("hidden");
/*                        $('#reverseSuggestion').toggleClass("hidden");*/
                        $("#bondList").html(newBondList);
                        $("#dialogAddBond").modal('hide');
                        xmlString = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newContent')[0]);
                        refreshXmlFile(xmlString.substring(109).substring(0, xmlString.indexOf("</newContent>")-109));
                        $("body").css("cursor", "default");
                        $("body").css("opacity", "1");
                        $("button").attr("disabled", false);
                };
                            };
                
                        request.setRequestHeader('Content-Type', 'text/xml');
                
                        request.send(xmlData);
                            };
           
           };
           
};

function closeAddBondModal(){
        $("#projectPeopleLookup").val("");
        $("#reverseSuggestion").html("");
        $("#bondTypeReverseCode").val("");
        $("#bondReverseUri").val("");
        $("#projectPeopleDetailsPreview").html("");
        $("#hasBondType_1_").html('<em>Select an item</em><span class="caret"></span>');
        $("#hasBondType_1_").val("")
        $("#hasBondTypeReverse_1_").toggleClass("hidden");
        $("#selectReverseBondType").toggleClass("hidden");
        $("#checkReverseButton").toggleClass("hidden");
        $("#addBondButton").toggleClass("hidden");
        $("#bondReverseTypesLookupDiv").toggleClass("hidden");
        $("#bondTypesLookup").val("");
        $("#hasBondTypeReverse_1_").toggleClass("hidden");
        $("#bondReverseTypesLookup").val("");
    $("#dialogAddBond").modal('hide');
};

function addFunction(){
    event.preventDefault();
    if(($("#selectedFunctionUri").val() !="")){
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");
    var functionUri = $("#selectedFunctionUri").val();
    var targetUri = $("#targetUri").val();
    
    var request = new XMLHttpRequest();
    var xmlData="<xml>"
                                + "<currentPeopleUri>" + getCurrentPeopleUri() + "</currentPeopleUri>"
                                + "<functionUri>" + functionUri + "</functionUri>"
                                + "<targetUri>" + targetUri +"</targetUri>"
                            +"</xml>";
        console.log("xmldata: " + xmlData);
        request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=addFunction" , true);
        var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
        xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
             console.log(xmlDocXml);
        
        newFunctionList= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newFunctionList')[0]);
        
        $("#functionsLookup").val("");
        $("#targetUri").val("")
        $("#functionTargetLookup").val("");
        $("#functionDetailsPreview").html("");
        $("#targetDetailsPreview").html("");
        $("#detailsPreview").toggleClass("hidden");
        $("#functionList").html(newFunctionList);
        $("#dialogAddFunction").modal('hide');
        xmlString = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newContent')[0]);
        console.log("newContent: " + xmlString);
        refreshXmlFile(xmlString.substring(109).substring(0, xmlString.indexOf("</newContent>")-109));
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
}
            };

        request.setRequestHeader('Content-Type', 'text/xml');
        request.setRequestHeader('Cache-Control', 'no-cache');
        request.send(xmlData);
            } else {alert("Please a reverse bond type");}

};

function functionMove(functionPosition, moveDirection){
        $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
    var request = new XMLHttpRequest();
    var xmlData="<xml>"
                            + "<currentPeopleUri>" + getCurrentPeopleUri() + "</currentPeopleUri>"
                            + "<functionPosition>" + functionPosition + "</functionPosition>"
                            + "<moveDirection>" + moveDirection + "</moveDirection>"
                    +"</xml>";
        console.log("xmldata: " + xmlData);
        request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=moveFunction" , true);
        var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
        xmlDoc = request.responseText;
        console.log("xml rsponse: " + xmlDoc);
             xmlDocXml = request.responseXML;
             /*console.log(xmlDocXml);*/
        
        newFunctionList= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newFunctionList')[0]);
        $("#functionList").html(newFunctionList);
        xmlString = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newContent')[0]);
        refreshXmlFile(xmlString);
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
}
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
            

    
};

function removeResourceFromList(resourceURI,
                                    type, 
                                    xpathBase,
                                    xpathSelector,
                                    index){
   event.preventDefault();  
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");
$("button").attr("disabled", true);
    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<resourceURI>" + resourceURI + "</resourceURI>"
                    + "<type>" + type + "</type>"
                    + "<xpathBase>" + xpathBase +"</xpathBase>"
                    + "<xpathSelector>" + xpathSelector +"</xpathSelector>"
                    + "<index>" + index +"</index>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=removeResourceFromList" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
/*             console.log("xmlDoc: " + xmlDocXml);*/
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
/*            updatedPlace = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedPlace')[0]);*/
            newElement2Display = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedElement')[0]);
/*            $("#placeEditor").html(updatedPlace);*/
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            
            console.log("updated element: " + newElement2Display)
            $("#resourcesManager" + type ).html(newElement2Display);
            $("body").css("cursor", "default");
            $("body").css("opacity", "1");
        $("button").attr("disabled", false);

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


 };
function removeItem(element, resourceURI,
                                    elementNickname, 
                                    xpathBase,
                                    xpathSelector,
                                    index){
     if (confirm('Are you sure you want to delete this term?')) {
    
                $("body").css("cursor", "wait");
                $("body").css("opacity", "0.5");
                
                    
                    var request = new XMLHttpRequest();
                
                
                    var xmlData="<xml>"
                                    + "<resourceURI>" + resourceURI + "</resourceURI>"
                                    + "<elementNickname>" + elementNickname + "</elementNickname>"
                                    + "<xpathBase>" + xpathBase +"</xpathBase>"
                                    + "<xpathSelector>" + xpathSelector +"</xpathSelector>"
                                    + "<index>" + index +"</index>"
                                +"</xml>";
                
                     console.log("xmldata: " + xmlData);
                
                /*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
                     request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=removeItem" , true);
                /*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
                /*                , true);*/
                     var xmlDoc;
                
                     request.onreadystatechange = function() {
                        if (request.readyState == 4 && request.status == 200) {
                /*            var el = document.getElementById(inputName.name.toString());*/
                             xmlDoc = request.responseText;
                             xmlDocXml = request.responseXML;
/*                             $(element).parents().closest('.xmlElementGroupItem').remove();*/
                /*             console.log("xmlDoc: " + xmlDocXml);*/
                /*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
                            
                            updatedResource = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedResource')[0]);
                            newElement2Display = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedElement')[0]);
                
                /*            $("#placeEditor").html(updatedPlace);*/
                             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
                /*            console.log("GoupID: " + "#" + elementNickname + "_group_1");
                            console.log("updated element: " + newElement2Display)*/
/*                            $("#" + elementNickname + "_group_1").html(newElement2Display);*/
                            
                            $(element).parents().closest('.xmlElementGroup').replaceWith(newElement2Display);
                            $("body").css("cursor", "default");
                            $("body").css("opacity", "1");
                        
                
                            }
                            };
                
                        request.setRequestHeader('Content-Type', 'text/xml');
                
                        request.send(xmlData);

            } else{}
 };

function resetValue(element, resourceURI,
                    inputName_text,
                    input_name_attrib,
                    elementNickName,
                    xpath,
                    contentType,
                    index, 
                    cardinality){
        console.log(element);
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");
    $("button").attr("disabled", true);
    newValue = "";
    newValueTxt = "";
    var xmlData = "<xml>"
    + "<elementNickname>" + elementNickName + "</elementNickname>"
    + "<inputName>" + inputName_text + "</inputName>"
    + "<resourceURI>" + resourceURI + "</resourceURI>"
    + "<value>" + newValue + "</value>"
    + "<valueTxt>" + newValueTxt + "</valueTxt>"
    + "<xpath>" + xpath + "</xpath>"
    + "<contentType>" + contentType + "</contentType>"
    + "<index>1</index>"
    +"</xml>";

var request = new XMLHttpRequest();
console.log("docURI = " + resourceURI);
request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=saveData", true);

var xmlDoc;

request.onreadystatechange = function() {
    if (request.readyState == 4 && request.status == 200) {
        xmlDoc = request.responseXML;
        xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
        var newValue2Display = "";
        var inputElementForText = $("#" + inputName_text + "_" + index + "_" + cardinality);
        var elementGroup = $(inputElementForText).parents().closest('.xmlElementGroup');
        elementGroup.find(".xmlElementValue").text("");
        refreshXmlFile(xmlString);
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        $("button").attr("disabled", false);
        }
    };
    request.setRequestHeader('Content-Type', 'text/xml');
    request.send(xmlData);
};

function removeFunction(element, personUri,
                                    functionUri
                                    ){
     
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<personUri>" + personUri + "</personUri>"
                    + "<functionUri>" + functionUri + "</functionUri>"
                    +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=removeFunction" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
/*             console.log("xmlDoc: " + xmlDocXml);*/
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            updatedResource = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedResource')[0]);
            $(element).parents().closest('.xmlElementGroup').remove();
/*            $("#placeEditor").html(updatedPlace);*/
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            
            $("body").css("cursor", "default");
            $("body").css("opacity", "1");
        

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


 };

function removeRelationship(element, personUri,
                                    bondUri,
                                    bondType
                                    ){
     

    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<personUri>" + personUri + "</personUri>"
                    + "<bondUri>" + bondUri + "</bondUri>"
                    + "<bondType>" + bondType + "</bondType>"
                    +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=removeRelationship" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
/*             console.log("xmlDoc: " + xmlDocXml);*/
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            
            
            $("#dialogDeleteRelationship").modal('show');
            
            suggestion = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('response')[0]);
            
            $('#suggestionForRelation').html(suggestion);
/*            $("#placeEditor").html(updatedPlace);*/
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            
        

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


 };

function confirmRelationshipDeletion(){
     
    if( ($("#relatedBondType").val() === undefined) &&
        ($('input[name="relatedBondType"]:checked').val() === undefined)
        ){
            alert("Please select at least one relation");
        }
    
    
    else{
    
    var request = new XMLHttpRequest();
    if($("#relatedBondType").val() === undefined){var relatedBondType = $('input[name="relatedBondType"]:checked').val()}
    else { var relatedBondType = $("#relatedBondType").val() };

    var xmlData="<xml>"
                    + "<personUri>" + $("#personUri").val() + "</personUri>"
                    + "<bondUri>" + $("#bondUri").val() + "</bondUri>"
                    + "<bondType>" + $('#bondType').val() + "</bondType>"
                    + "<relatedBondType>" + relatedBondType  + "</relatedBondType>"
                    
                    +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "/$ausohnum-lib/modules/prosopoManager/getFunctions.xql?type=confirmRelationshipDeletion" , true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXml = request.responseXML;
/*             console.log("xmlDoc: " + xmlDocXml);*/
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            newBondList = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newBondList')[0]);
            console.log("new list:" + newBondList);
/*            $(element).parents().closest('.xmlElementItem').remove();*/
            $("#dialogDeleteRelationship").modal('hide');
        
            $("#bondList").html(newBondList);
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            xmlString = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('newContent')[0]);
           refreshXmlFile(xmlString.substring(109).substring(0, xmlString.indexOf("</newContent>")-109));
            

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);

        };
 };
function openPlaceFromLink(uri){
 $("body").toggleClass("wait");
 var sourceFromXql = "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getPlaceHTML&resource=" + encodeURIComponent(uri);
    var conceptFromXqlWithURI = "/place-record/" + encodeURI(uri); 
    $("#placeEditor").load(sourceFromXql);
  
  $("body").removeClass("wait");
};

function closeAddFunctionModal(){
    $("#functionsLookup").val("");
        $("#functionTargetLookup").val("");
        $("#selectedFunctionUri").val("");
        $("#targetUri").val("");
    $("#dialogAddFunction").modal('hide');
};



/*
****************************
*     Dropdown menus       *
****************************
*/
 $(function(){
$( "#content" ).on( "click", ".dropdown-menu li a", function( event ) {
    //console.log("menu: " + $(this).attr('menu'));
    //              console.log("v: " + $(this).attr('value'));
        /*        var menu = "#" + $(this).attr('id');*/
                var menu = $(this).attr('menu');
                 $(menu).html($(this).text()  + '<span class="caret"></span>');
                 $(menu).attr('value', $(this).attr('value'));
                
});
});
