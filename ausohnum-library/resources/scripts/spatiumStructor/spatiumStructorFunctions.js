var pleiadesPreviewMap;

function getCurrentDocId() { return $('#currentDocId').html() };
function getCurrentPlaceUri() { return $('#currentPlaceUri').html() };
function getCurrentPlaceCoordinates() { return $('#currentPlaceCoordinates').html() };
function getCurrentProject() { return $('#currentProject').text(); };
function getPlaceEditorType(){ return $("#placeEditorType").text();};
function getDocumentPlacesGeoJSon(geojson, callback){
    
    console.log("DocId: " + getCurrentDocId());
    var url = "/geo/document/" + getCurrentDocId();
    $.getJSON(url, function(json){
            geojsonFeatureDocument = json[0];
                           callback(geojsonFeatureDocument);
                           });
        }

function getEditorType(){
    return $("#placeEditorType").html();
}
function getDocumentPlacesGeoJSon(geojson, callback){
    
    console.log("DocId: " + getCurrentDocId());
    var url = "/geo/document/" + getCurrentDocId();
    $.getJSON(url, function(json){
            geojsonFeatureDocument = json[0];
                           callback(geojsonFeatureDocument);
                           });
        }
        
/*function getDocumentPlacesGeoJSon(docId){
    console.log("DocId: " + docId);
    var url = "/geo/document/" + docId;
    $.getJSON(url, function(json){
            return  json[0];});
}*/                       
function getProjectPlaces(geojson, callback){
/*     var url = "/geo/places/json";*/
     var url="/geo/gazetteer/all";
    /*    var url = "/geo/production-units";*/
    /*var url = "/geo/project-places/" ;*/
        $.getJSON(url, function(json){
                geojsonFeatureProject = json[0];
                           callback(geojsonFeatureProject);  
                           });
};



function getDocumentPlaces(geojson, callback){
    var docId = getCurrentDocId();
    var url2getPlaces = "/geo/document/" + docId;
    $.getJSON(url2getPlaces, function(json){
            geojsonFeatureDocument = json[0];               
             callback(geojsonFeatureDocument);  
            });
};

function getProdUnitsPlaces(geojson, callback){
/*    var url2getPlaces = "/geo/production-units" ;*/
    var url2getPlaces = "/geo/gazetteer/production-units";
    $.getJSON(url2getPlaces, function(json){
            geojsonFeatureProdUnits = json[0];               
             callback(geojsonFeatureProdUnits);  
            });
};

/*function getProductionUnitsPlaces(geojson, callback){
    var url2getPlaces = "/geo/production-units";
    
    $.getJSON(url2getPlaces, function(json){
            var clusters = L.markerClusterGroup();
            var productionUnits = L.geoJson(json, {
                     pointToLayer: function(feature, latlng) {
            var marker = L.marker(latlng);
            marker.bindPopup('Trial' + feature.properties.name);
            return marker;
            },
            onEachFeature: function (feature, layer) {
            layer.addTo(clusters);
          }
        });
        displayMap.addLayer(clusters);
      });
      
      
/\*
            
            
            
            geojsonFeatureProductionUnits = json[0];               
             callback(geojsonFeatureProductionUnits);  
                       }
                       
                       );
         *\/                
};
*/
function getGeonamesCitiesBound(east, west, north, south, geojson, callback){
var geonamesUrl = "https://secure.geonames.org/citiesJSON?north=" + north
                                                    + "&south=" + south + "&east=" + east + "&west=" + west
                                                   + "&lang=en&" + "&maxRows=100"+ "&username=vrazanajao";


    $.getJSON(geonamesUrl, function(json){
    
/*    var geojson = {};*/
    geojson["type"] = "FeatureCollection";
     geojson["features"] = [];
                        console.log("Geonames :" + JSON.stringify(json));
               
            for(var i = 0; i < json.geonames.length; i++)
                        {
                            console.log("Geonames :" + json.geonames[i].geonameId);
                            var place = json.geonames[i];//change
                            
                           var newFeature = {
                                 "type": "Feature",
                                 "geometry": {
                                   "type": "MultiPoint",
                                   "coordinates": [[parseFloat(place.lng), parseFloat(place.lat)]]
                                         },
                                 "properties": {
                                   "name": place.name,
                                   "popupContent": "<p>"
                                    + "<strong>" + place.name + "</strong><br/>"
                                    + "<span class='pullright'>Geoname ID : " + place.geonameId + "</span>"
                                    + "<br/>"
                                    + " lat. " + place.lat + "- long. " + place.lng
                                    +  "<br/>"
                                    + "<a href='http://geonames.org/" + place.geonameId + "' target='_about'><i class='glyphicon glyphicon-new-window'/>http://geonames.org/" + place.geonameId + "</a>"
                                    +"</p>"
                                 }
                               }
                         geojson['features'].push(newFeature);
                       };
                       console.log("return = " + JSON.stringify(geojson));
                       callback(geojson);  
                       }
                       
                       );
                         
}


function getAjax() {
console.log("a" );
  $.ajax({
       type: "POST",
       url: '/geo/places/json',
       async: true,
       success: function(response) {
        
        return response;
        console.log("a" + response)
        
  }});
};

/*function showGeonames(map, layer){
    layer.remove;
}*/

/*
Commented on 21/05/2019
 *
 */ 
console.log($('#xml-editor-file'));
var geonamesControl = L.control.geonames({
    //position: 'topcenter', // In addition to standard 4 corner Leaflet control layout, this will position and size from top center.
    position: 'topleft',
    geonamesSearch: 'https://secure.geonames.org/searchJSON', // Override this if using a proxy to get connection to geonames.
    geonamesPostalCodesSearch: 'https://secure.geonames.org/postalCodeSearchJSON', // Override this if using a proxy to get connection to geonames.
    username: 'vrazanajao', // Geonames account username.  Must be provided.
    maxresults: 10, // Maximum number of results to display per search.
    zoomLevel: null, // Max zoom level to zoom to for location. If null, will use the map's max zoom level.
    className: 'leaflet-geonames-icon', // Class for icon.
    workingClass: 'leaflet-geonames-icon-working', // Class for search underway.
    featureClasses: ['A', 'H', 'L', 'P', 'R', 'T', 'U', 'V'], // Feature classes to search against.  See: http://www.geonames.org/export/codes.html.
    baseQuery: 'isNameRequired=true', // The core query sent to GeoNames, later combined with other parameters above.
    showMarker: true, // Show a marker at the location the selected location.
    showPopup: true, // Show a tooltip at the selected location.
    adminCodes: {}, // Filter results by the specified admin codes mentioned in `ADMIN_CODES`. Each code can be a string or a function returning a string. `country` can be a comma-separated list of countries.
    bbox: {}, // An object in form of {east:..., west:..., north:..., south:...}, specifying the bounding box to limit the results to.
    lang: 'en', // Locale of results.
    alwaysOpen: false, // If true, search field is always visible.
    enablePostalCodes: true, // If true, use postalCodesRegex to test user provided string for a postal code.  If matches, then search against postal codes API instead.
    postalCodesRegex: POSTALCODE_REGEX_US, // Regex used for testing user provided string for a postal code.  If this test fails, the default geonames API is used instead.
    title: 'Search in Geonnames.org by location name or postcode', // Search input title value.
    placeholder: 'Enter a location name' // Search input placeholder text.
});


function searchByAjax(text, callResponse)//callback for 3rd party ajax requests
	{
		return $.ajax({
			url: 'https://peripleo.pelagios.org/peripleo/search?object_type=place',	//read comments in search.php for more information usage
			type: 'GET',
			data: {query: text},
			dataType: 'json',
			success: function(json) {
                          			 //console.log(JSON.stringify(json));
                          			     var geojson = {};
                          			     geojson["type"] = "FeatureCollection";
                                                               geojson["features"] = [];
                          		                  for(var i = 0; i < json.items.length; i++)
                                                                             {  var place = json.items[i];//change
                                                                                 console.log(JSON.stringify(place));
                                                                                var newFeature = {
                                                                                      "type": "Feature",
                                                                                      "geometry": {
                                                                                        "type": "Point",
                                                                                        "coordinates": [parseFloat(place.geo_bounds.min_lat), parseFloat(place.geo_bounds.min_lon)]
                                                                                              },
                                                                                      "properties": {
                                                                                        "name": place.title,
                                                                                        "popupContent": "<p>"
                                                                                         + "<strong>" + place.title + "</strong>"
                                                                                         + "<span class='pullright'>Pleiades ID : " + place.identifier + "</span>"
                                                                                         + "<lb/>"
                                                                                         + " lat. " + place.geo_bounds.min_lat + " - long. " + place.geo_bounds.min_lon
                                                                                         +"</p>"
                                                                                      }
                                                                                    }
                                                                              geojson['features'].push(newFeature);
                                                                              };
                                                                                console.log(JSON.stringify(geojson));
                                              			callResponse(geojson);
                                              	              }
                    		});
	};

/*Commented on 21/05/2019
 * 
 */
 var peripleoSearchControl = L.control.search({
		url: 'https://peripleo.pelagios.org/peripleo/search?object_type=place&query=',
		textPlaceholder: 'Search Peripleo',
		position: 'topleft',
		hideMarkerOnCollapse: true,
		marker: {
			icon: new L.Icon({iconUrl:'data/custom-icon.png', iconSize: [20,20]}),
			circle: {
				radius: 20,
				color: '#0a0',
				opacity: 1
			}
		}
	});





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
        console.log("idElementValue= " + idElementValue);
        /*console.log("idElementValue= " + idElementValue);
        console.log("idElementInput= " + idElementInput);*/
        $(idElementValue).toggleClass("xmlElementHidden");
        $(idElementInput).toggleClass("xmlElementHidden");

};


function cancelEdit(xmlElementNickname, index, originalValue, type, cardinality){
        console.log("Cancel edit")
        if(index == null) { ind =""} else {var ind = index}
        if(cardinality != null) {var card = "_" + cardinality} else{var card =""};
        var idElementAddItem = "#" +xmlElementNickname;
        var idElementDisplay= "#" +xmlElementNickname+"_display_"+ ind + card;
        var idElementEdit= "#" +xmlElementNickname+"_edit_" + ind + card;
        var elementInput= $("#" + xmlElementNickname + "_" + ind + card);
        /*console.log("idElementValue= " + idElementValue);
        console.log("idElementInput= " + idElementInput);*/
        console.log ("idElementDisplay: " + idElementDisplay);
        console.log($(idElementAddItem).length);
        console.log(idElementAddItem);
        if($(idElementDisplay).length>0){
        $(idElementDisplay).toggleClass("xmlElementHidden");
        $(idElementEdit).toggleClass("xmlElementHidden");
        }
        if($(idElementAddItem).length>0){
                console.log("ffff");
                $(idElementAddItem).addClass("xmlElementHidden");
        }
        if(type=='input'){
        elementInput.val(originalValue);
        elementInput.html(originalValue);
        }

};

function cancelEditLocation(){
    $("#placeLocation_display").toggleClass("hidden");
    $("#placeLocation_edit").toggleClass("hidden");
}

function addData(element,
                            placeUri,
                            input,
                            xmlElementNickname,
                            xpath,
                            contentType,
                            index,
                            topConceptId){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");
$("button").attr("disabled", true);
console.log("contentType: " + contentType);
/*    console.log("element (normally this): " + element);*/
    var elementInput;
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
                            var elementInput =$("#" + input).find("button.elementWithValue");
/*                            console.log("elementGroup: " + $(elementGroup).attr('id'));
                            console.log("input varaible: " + input);
*/                            
                            var tagName = elementInput.prop("tagName");
                          break;
                      case "attribute":
                            var elementGroup = $(element).parents().closest('.xmlElementGroup');
                            var elementInput =$("#" + input);
                                    //.find("button.elementWithValue");
                            console.log("elementGroup: " + $(elementGroup).attr('id'));
                            console.log("input varaible: " + input);
                            
                            var tagName = elementInput.prop("tagName");
                            console.log("tagName: " + tagName);
                      break;
                      case "text":
                                console.log("Case text!!!!!!");
                            var elementGroup = $(element).parents().closest('.xmlElementGroup');
                            var elementInput =$("#" + input);
/*                            console.log("elementGroup: " + $(elementGroup).attr('id'));
                            console.log("input : " + input);
*/                            
                            var tagName = elementInput.prop("tagName");
                          break;
                      default:
                      
/*                      var elementInput = $(element).siblings().children().find('.elementWithValue');*/
                        var elementGroup = $(element).parents().closest('.xmlElementGroup');
                        var elementAddGroup = $(element).parents().closest('.xmlElementAddItem');
                        var elementGroupId = $(elementGroup).attr('id');
                        var elementGroupAddId = $(elementAddGroup).attr('id');
                /*        console.log("elementGroup: " + $(elementGroup).attr('id'));
                        console.log("Input: " + $("#" + elementGroupId).find('.elementWithValue').text());*/
                       elementInput = $(elementAddGroup).find('.elementWithValue');
                       
                       var tagName = elementInput.prop("tagName");
                                     console.log("tagName in Default: " + tagName)
                        var newValue = elementInput.attr('value');
                      
                        var newValueTxt =  elementInput.text().trim();
/*                        console.log("test with prop" + elementInput.prop("value");)*/
                        break;
                }//End switch(contentType)
      
      if($("#lang_" + xmlElementNickname + "_add"))
                            {
                                if($("#lang_" + xmlElementNickname + "_add option:selected"))
                                            {var lang =$("#lang_" + xmlElementNickname + "_add option:selected").text().trim();}                            
/*                                    Case there is a skosThesau DropDown*/
                                    var lang = $("#lang_" + xmlElementNickname + "_add").find("button.elementWithValue").val();
                            
                            }
      
      /*console.log("Tagname: " + tagName);
      console.log("contentType: " + contentType);*/
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
/*                                 console.log("text= " + newValueTxt + " | attrib= " + newValue);*/
                                 break;
                               case "attribute":
/*                                 console.log("attribute: " +  "#" + xmlElementNickname + "_add_attrib_" + index + "_1")*/
                                 newValue = elementInput.val();
                                 
/*                                 console.log("text= " + newValueTxt + " | attrib= " + newValue);*/
                                 break;
                               default: 
                                 newValue = elementInput.val();
                                 break;
                            }
                        break;
                       
                   case "SELECT":
                      newValue = elementInput.val();
                      break;
                    case "DIV":  /*Case dropdown thesau*/
                    
                    break;
                   default:
                      newValue = elementInput.attr('value') ;
                      break;
               }
      //console.log("Value:: " + newValue);
                if (newValueTxt != "") {var valueText = newValueTxt}
                else {var valueText = elementInput.text()}
/*                console.log("newValueTxt: " + newValueTxt);*/
/*                console.log("valueText: " + valueText);*/
/*                console.log("elementInput.text(): " + elementInput.text().trim);*/
   // console.log("value textual value= " + input.text());
        var xmlData = "<xml>"
                        + "<placeUri>" + placeUri + "</placeUri>"
                        + "<inputName>" + input + "</inputName>"
                        + "<value>" + newValue + "</value>"
                        + "<valueTxt>" + valueText + "</valueTxt>"
                        + "<valueConceptHierarchy>" + elementInput.attr("concepthierarchy") + "</valueConceptHierarchy>"
                        + "<langNewData>" + $("#selectDropDownc21856_1_9999").val() + "</langNewData>"
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
         request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=addData" , true);
         /*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                    //+ "&project=" + "patrimonium" + "&xpath=" + xpath
         /*                , true);*/
         var xmlDoc;

         request.onreadystatechange = function() {


           //TODOAPPEND TO GROUP
            if (request.readyState == 4 && request.status == 200) {
                var select = elementInput;
                 //xmlDoc = request.responseText;
                 //$(elementGroup).replaceWith(xmlDoc);
                 xmlDoc = request.responseXML;
                newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
                $(elementGroup).replaceWith(newElement2Display);
                xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('rdf:RDF')[1]);
                refreshXmlFile(xmlString);
                $("body").css("cursor", "default");
                $("body").css("opacity", "1");
                $("button").attr("disabled", false);
/*                  console.log("xmlDoc: " + xmlDoc);*/
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

function addGroupItem(element, item, index){
/*          teiElementNickname --> used as prefix of input name
 *          index -->   index no of corresponding TEI div/@type='textpart'; default = 1
 *
 * */

        $(element).parents().closest(".xmlElementGroup").find('.xmlElementAddGroupItem').toggleClass("xmlElementHidden");

};

function saveData(element,
                                resourceURI,
                                inputName_text,
                                input_name_attrib,
                                elementNickName,
                                xpath,
                                contentType,
                                index, 
                                cardinality){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");
$("button").attr("disabled", true);
/*    console.log("Value of " + inputName.name.toString()  + ": " + $(inputName).val());*/
/*console.log("contentType" + contentType);*/
/*console.log("#" + inputName_text + "_" + index + "_" + cardinality);*/
/*console.log("#" + input_name_attrib+ "_" + index + "_" + cardinality);*/
/*var inputElementForText = $("#" + inputName_text + "_" + index + "_" + cardinality);*/
var inputElementForText = $("#" + elementNickName+ "_" + index + "_" + cardinality);
console.log("INPUT ID:   " +"#" + inputName_text + "_" + index + "_" + cardinality);
var inputElementForAttrib = $("#" + input_name_attrib+ "_" + index + "_" + cardinality);
if(index == null) { ind =""} else {var ind = index}
if(inputElementForText.prop("tagName") === null)
                            {var tagName = "INPUT"}
                            else{
                                var tagName = inputElementForText.prop("tagName");
                            };
/*                    var elementGroup = $(inputElementForText).parents().closest('.xmlElementGroup');*/
                    var elementGroup = $(element).parents().closest('.xmlElementGroup');
                    
                            
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
/*                    console.log("newValueTxt: " + newValueTxt + "newValue: " +newValue);*/
                    break;
                 case "INPUT": case "TEXTAREA":
                    switch(contentType){
                      case "text": 
                        newValue = elementInput.val();
                        newValueTxt = elementInput.val();  
/*                        console.log("New value in 470" + newValueTxt);*/
                      break;
                    case "textNodeAndAttribute":
                        newValue = inputElementForAttrib.val();
                        newValueTxt = inputElementForText.val();
/*                        console.log("text= " + newValueTxt + " | attrib= " + newValue);*/
                        break;
                      case "nodes":
                        newValue = inputElementForText.val();
                        newValueTxt = inputElementForText.val();
/*                        console.log("text= " + newValueTxt + " | attrib= " + newValue);*/
                        break;
                      default: 
                        newValue = elementInput.val();
/*                        console.log("In switch tagname default return: " + newValueTxt );*/
                        break;
                        }  
                    break;
                 case "SELECT":
                        switch(contentType){
                        case("textNodeAndAttribute"):
                            newValue = $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality + ' option:selected').val();
                            newValueTxt = $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality + ' option:selected').attr("textValue");
/*                            console.log("newValue: " + newValue );*/
/*                            console.log("newValueTxt: " + newValueTxt );*/
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
                    + "<valueConceptHierarchy>" + elementInput.attr("concepthierarchy") + "</valueConceptHierarchy>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<contentType>" + contentType + "</contentType>"
                    + "<index>" + cardinality + "</index>"
                    +"</xml>";
/*     console.log("xmlData = " + xmlData);*/

     //var input = inputName;
     //var inputId = "#" + inputName.name.toString();

     var request = new XMLHttpRequest();
/*     console.log("docURI = " + resourceURI);*/
/*     request.open("POST", "/$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=saveData", true);*/
     request.open("POST", "/getfunction/?type=stsaveData", true);
     
     
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            var select = elementInput;
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('rdf:RDF')[1]);
             newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
/*             console.log("newElement2Display: " + newElement2Display);*/
             oldValueTxt = xmlDoc.getElementsByTagName('oldContent')[0].textContent;
/*             console.log("oldValueTxt:" + oldValueTxt);*/
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
/*                               console.log("NEW VAlUE in case Input: " + newValue2Display);*/
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
/*                        console.log("NEW VALUE: " + newValue2Display);*/
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
/*             console.log("newElement2Display: " + newElement2Display);*/
             elementGroup.html(newElement2Display);
             
/*             console.log("newValue2Display: " + newValue2Display);*/
             elementDisplay.toggleClass("xmlElementHidden");
             //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
             //console.log("Response : Value of xmlDoc" + xmlDoc);
             //console.log("Id of element" + idElementValue);

             //$(idElementValue).text(xmlDoc.xml.value)
             elementEdit.toggleClass("xmlElementHidden");
             if(elementNickName == "title"){$("#resourceTitle").html(newValue2Display)};
             
             refreshXmlFile(xmlString);
             $("body").css("cursor", "default");
             $("body").css("opacity", "1");
             $("button").attr("disabled", false);
            }

            };

     request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function saveDataWithConceptHierarchy(element,
                                resourceURI,
                                inputName_text,
                                input_name_attrib,
                                elementNickName,
                                xpath,
                                contentType,
                                index, 
                                cardinality){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");
$("button").attr("disabled", true);

var inputElementForText = $("#" + elementNickName+ "_" + index + "_" + cardinality);

var inputElementForAttrib = $("#" + input_name_attrib+ "_" + index + "_" + cardinality);
if(index == null) { ind =""} else {var ind = index}
if(inputElementForText.prop("tagName") === null)
                            {var tagName = "INPUT"}
                            else{
                                var tagName = inputElementForText.prop("tagName");
                            };
/*                    var elementGroup = $(inputElementForText).parents().closest('.xmlElementGroup');*/
                    var elementGroup = $(element).parents().closest('.xmlElementGroup');
                    
                            
        console.log("Tagnme: " + tagName);
        console.log($(elementGroup).attr('id'));
        
        var elementDisplay= $("#" +elementNickName +"_display_" + ind.toString()+ "_" + cardinality);
        var elementValue= $("#" + elementNickName +"_value_"+ ind.toString()+ "_" + cardinality);
        var elementEdit= $("#" +elementNickName +"_edit_" + ind.toString()+ "_" + cardinality);
        var elementInput= $("#" +elementNickName + "_" + ind.toString() + "_" + cardinality);
        
        
                    newValue = inputElementForText.attr('value');
                    console.log("new value: " + newValue);
                    newValueTxt = inputElementForText.text().trim();
/*                    console.log("newValueTxt: " + newValueTxt + "newValue: " +newValue);*/
                    
                    
             
    //console.log("Value:: " + newValue);
    //console.log("Input Id:: " + elementNickName + "_" + index + "_" + cardinality );
    var xmlData = "<xml>"
                    + "<elementNickname>" + elementNickName + "</elementNickname>"
                    + "<inputName>" + inputName_text + "</inputName>"
                    + "<resourceURI>" + resourceURI + "</resourceURI>"
                    + "<value>" + newValue + "</value>"
                    + "<valueTxt>" + newValueTxt + "</valueTxt>"
                    + "<valueConceptHierarchy>" + elementInput.attr("conceptHierarchyUris") + "</valueConceptHierarchy>"
                    + "<xpath>" + xpath + "</xpath>"
                    + "<contentType>" + contentType + "</contentType>"
                    + "<index>" + cardinality + "</index>"
                    +"</xml>";
     console.log("xmlData = " + xmlData);

     //var input = inputName;
     //var inputId = "#" + inputName.name.toString();

     var request = new XMLHttpRequest();
/*     console.log("docURI = " + resourceURI);*/
/*     request.open("POST", "/$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=saveData", true);*/
     request.open("POST", "/getfunction/?type=stsaveDataConceptHierarchy", true);
     
     
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            var select = elementInput;
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('rdf:RDF')[1]);
             
             newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
/*             console.log("newElement2Display: " + newElement2Display);*/
             oldValueTxt = xmlDoc.getElementsByTagName('oldContent')[0].textContent;
/*             console.log("oldValueTxt:" + oldValueTxt);*/
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
/*                               console.log("NEW VAlUE in case Input: " + newValue2Display);*/
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
/*                        console.log("NEW VALUE: " + newValue2Display);*/
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
/*             console.log("newElement2Display: " + newElement2Display);*/
             elementGroup.html(newElement2Display);
             
/*             console.log("newValue2Display: " + newValue2Display);*/
             elementDisplay.toggleClass("xmlElementHidden");
             //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
             //console.log("Response : Value of xmlDoc" + xmlDoc);
             //console.log("Id of element" + idElementValue);

             //$(idElementValue).text(xmlDoc.xml.value)
             elementEdit.toggleClass("xmlElementHidden");
             if(elementNickName == "title"){$("#resourceTitle").html(newValue2Display)};
             
             refreshXmlFile(xmlString);
             $("body").css("cursor", "default");
             $("body").css("opacity", "1");
             $("button").attr("disabled", false);

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
        $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");     
        $("button").attr("disabled", true);
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
        
        var elementGroup = $("#" + inputName + "_group_" +  ind.toString() );
        switch(contentType){
                      case "textNodeAndAttribute":
                      case "attribute":
                        //var elementGroup = $(inputName).parents().closest('.xmlElementGroup');
                        console.log("inputName: " + inputName);
                        console.log("elementInput.prop('tagName')" + elementInput.prop("tagName"));
                        console.log("elementGroup: " + $(elementGroup).attr('id'));
                        if(elementInput.prop("tagName") === undefined || elementInput.prop("tagName") === null)
                            {var tagName = "INPUT"}
                            else{
                                var tagName = elementInput.prop("tagName");
                                
                            };
                            
                      break;
                      
                      
                      default:
                        var tagName = elementInput.prop("tagName");
                        console.log("Tganame: " + tagName);              
                        }              
        console.log("tagname " + tagName);
             switch(tagName){
                 case "BUTTON":
                    newValue = elementInput.attr('value');
                    newValueTxt = elementInput.text()
                    break;
                 case "INPUT":
                    switch(contentType){
                      case "text":
                      case "attribute":
                        newValue = $("#" + inputName + "_" + index + "_" + cardinality).val();
                        
                        newValueTxt = $("#" + inputName + "_" + index + "_" + cardinality).val(); 
/*                        console.log("text= " + newValueTxt + " | newValue= " + newValue);*/
                        break;
                       /* case "attribute":
                        newValue = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val();
                        
                        newValueTxt = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val(); 
                        console.log("text= " + newValueTxt + " | newValue= " + newValue);
                      break;*/
                      case "textNodeAndAttribute":
                        newValue = $("#" + inputName + "_attrib_" + index + "_" + cardinality).val();
                        newValueTxt = $("#" + inputName + "_text_" + index + "_" + cardinality).val();
                        console.log("text= " + newValueTxt + " | attrib= " + newValue);
                        break;
                        
                      default: 
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
     
/*     request.open("POST", "/$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=saveData", true);*/
     request.open("POST", "/getfunction/?type=stsaveData", true);
/*                request.open("POST", "/admin/edit/document/save-data/"+docId*/
                //+ "&project=" + "patrimonium" + "&xpath=" + xpath
/*                , true);*/
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            var select = elementInput;
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('rdf:RDF')[1]);
             newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
/*             console.log("newElement2Display: " + newElement2Display);*/
             oldValueTxt = xmlDoc.getElementsByTagName('oldContent')[0].textContent;
             
             elementIdToReplace = xmlDoc.getElementsByTagName('elementIdToReplace')[0].textContent;
             newElement = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
              newValue2Display = xmlDoc.getElementsByTagName('newValue2Display')[0].textContent;
             console.log("newElement (updated element): " + newElement);
             console.log("elementIdToReplace ="+ elementIdToReplace);
             $("#" +elementIdToReplace).html(newElement);
             
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
                            
                            
/*             elementGroup.html(newElement2Display);*/
/*             console.log("elementGroup " + elementGroup.html());*/
             //console.log("newValue2Display: " + newValue2Display);
             elementDisplay.toggleClass("xmlElementHidden");
             //console.log("Response : Value of " + inputName.name.toString() + ": " + $(inputName).val());
             //console.log("Response : Value of xmlDoc" + xmlDoc);
             //console.log("Id of element" + idElementValue);

             //$(idElementValue).text(xmlDoc.xml.value)
             elementEdit.toggleClass("xmlElementHidden");
             if(inputName === "title"){$("#resourceTitle").html(newValue2Display)};
             
             refreshXmlFile(xmlString);
             $("body").css("cursor", "default");
             $("body").css("opacity", "1");     
             $("button").attr("disabled", false);
            }

            };

     request.setRequestHeader('Content-Type', 'text/xml');
        
        request.send(xmlData.toString());


};

function addGroupData(element,
                            resourceUri,
                            xmlElementNickname,
                            index){
                $("body").css("cursor", "wait");
                  $("body").css("opacity", "0.5");     
                  $("button").attr("disabled", true);
              console.log("element (normally this): " + element);
            var xmlDataItems = "";
            var elementGroup = $(element).parents().closest('.xmlElementAddGroup ');
            var wholeGroup = $(element).parents().closest('.xmlElementGroup');
            console.log(JSON.stringify(elementGroup));
            
            elementGroup.children().find('.elementWithValue').each(function(i, el){
                
                var elementInput = $(el);
                console.log("elementWithValue: " + elementInput);
                var xmlElementNickname = elementInput.attr("name");
                if(elementInput.prop("tagName") === null)
                            {var tagName = "INPUT"}
                            else{
                                var tagName = elementInput.prop("tagName");
                                
                            };
                console.log("tagname = " + tagName);
                switch(tagName){
                 case "BUTTON":
                    newValue = elementInput.attr('value');
                    newValueTxt = elementInput.text()
                    xmlItem = '\r\n<groupItem xmlElement="' + xmlElementNickname + '">' + newValue + '</groupItem>';
                    console.log(xmlItem);
                   xmlDataItems = xmlDataItems  + xmlItem;
                    break;
             case "INPUT":
             case "TEXTAREA":
                value = elementInput.val();
                xmlItem = '\r\n<groupItem xmlElement="' + xmlElementNickname + '">' + value + '</groupItem>';
                console.log(xmlItem);
                xmlDataItems = xmlDataItems  + xmlItem;
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
                
            }
            
            );
            console.log(xmlDataItems);
            var xmlData = "<xml>"
                        + xmlDataItems
                        + "<resourceUri>" + resourceUri + "</resourceUri>"
                        + "<index>" + index + "</index>"
                        + "<xmlElementNickname>" + xmlElementNickname + "</xmlElementNickname>"
                        +"</xml>"
           var request = new XMLHttpRequest();
    console.log("xmlData: " + xmlData);
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=addGroupData", true);
     var xmlDoc;
     request.onreadystatechange = function() {

            if (request.readyState == 4 && request.status == 200) {
                xmlDoc = request.responseXML;
                newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedElement')[0]);
                console.log("XML doc: " + newElement2Display);
                wholeGroup.replaceWith(newElement2Display);
                xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('rdf:RDF')[1]);
                refreshXmlFile(xmlString);
                $("body").css("cursor", "default");
                $("body").css("opacity", "1");
                $("button").attr("disabled", false);
                   }

                };

            request.setRequestHeader('Content-Type', 'text/xml');

            request.send(xmlData);

};
        
function saveXmlFile(resourceURI){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");
$("button").attr("disabled", true);
console.log(getXmlEditorContent());
var xmlData = "<xml>"
                    + "<resourceURI>" + resourceURI + "</resourceURI>"
                    + "<newContent>" + getXmlEditorContent() + "</newContent>"
                    +"</xml>";
        console.log("NEw content to be saved: " + xmlData);
     var request = new XMLHttpRequest();
     request.open("POST", "/$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=saveXmlFile", true);
     
     var xmlDoc;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
            
             xmlDoc = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('newContent')[0]);
             newFile2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('updatedFile')[0]);
             $("#placeEditor").html(newFile2Display);
             
             $("body").css("cursor", "default");
             $("body").css("opacity", "1");
             $("button").attr("disabled", false);

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
    $("body").css("opacity", "0.5");
    $("button").attr("disabled", true);
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
    request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=saveTextarea" , true);

var xmlDoc;
var xmlDocXML;

     request.onreadystatechange = function() {
        if (request.readyState == 4 && request.status == 200) {
/*            var el = document.getElementById(inputName.name.toString());*/
             xmlDoc = request.responseText;
             xmlDocXML = request.responseXML;
             xmlString = (new XMLSerializer()).serializeToString(xmlDocXML.getElementsByTagName('rdf:RDF')[1]);
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
            $("body").css("opacity", "1");
            $("button").attr("disabled", false);

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
            $("#messageZone").fadeOut(1);
            $("#fileModifiedAlert" ).fadeOut(1);
            $("#saveFileButton" ).fadeOut(1);
/*             $("#body").toggleClass('overlap');*/
                $("#messageZone").css('background-color', '#8c0000');
            $("#messageZone").css('color', 'white');
    
};

function openDialog(dialogId){
    dialogElement = "#" + dialogId;
    console.log("dialogId= " + dialogId)
    $(dialogElement).modal('show');
    if (dialogId ="addSubPlace"){ $("#placeTypeSelection").val("hasInItsVincinity")}
    else if (dialogId =="addSubPlace"){$("#placeTypeSelection").val("IsInVincinityOf")}
    };
function openDialog(dialogId, option){
    dialogElement = "#" + dialogId;
    console.log("dialogId= " + dialogId)
    $(dialogElement).modal('show');
    $("#placeTypeSelection").val(option);
    };
 
function removeItem(resourceURI,
                                    elementNickname, 
                                    xpathBase,
                                    xpathSelector,
                                    index){
     
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");
$("button").attr("disabled", true);
    
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
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=removeItem" , true);
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
            newElement2Display = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedElement')[0]);
            xmlString = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('rdf:RDF')[1]);
             refreshXmlFile(xmlString);
/*            $("#placeEditor").html(updatedPlace);*/
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            console.log("GoupID: " + "#" + elementNickname + "_group_1");
            console.log("updated element: " + newElement2Display)
            $("#" + elementNickname + "_group_1").html(newElement2Display);
            $("body").css("cursor", "default");
            $("body").css("opacity", "1");
            $("button").attr("disabled", false);

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
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=removeResourceFromList" , true);
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
            updatedPlace = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedPlace')[0]);
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
 
function removeSubPlace(element, currentPlaceUri,
                                    subPlaceUri, 
                                    placeRelationType
                                    ){
     
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<currentPlaceUri>" + currentPlaceUri + "</currentPlaceUri>"
                    + "<subPlaceUri>" + subPlaceUri + "</subPlaceUri>"
                    + "<placeRelationType>" + placeRelationType +"</placeRelationType>"
                    +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=removeSubPlace" , true);
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
            updatedPlace = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedPlace')[0]);
/*            $(element).parents().closest('.xmlElementGroup').remove();*/
            $("#placeEditor").html(updatedPlace);
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            
            $("body").css("cursor", "default");
            $("body").css("opacity", "1");
        

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


 };
    
$( ".zoteroLookup" ).attr('autocomplete','on');
$( ".zoteroLookup" ).autocomplete({
      source: function( request, response ) {
        var zoteroGroup = $("#zoteroGroupNo").text();
        
        $.ajax({
            url : 'https://api.zotero.org/groups/' + zoteroGroup + '/items?',
            dataType : 'json',
            data : {
                q: $('#zoteroLookupInputModal').val()
                //types: "place"

            },

            success : function(data){
            console.log("group: " +zoteroGroup);
                console.log("sucess: " + JSON.stringify(data));
                response(
                $.map(
                    data, function(object){
                    
                           /*if(object.data.creators!=undefined) 
                                    { if(object.data.creators[0].lastName[0] != undefined)
                                            
                                            {var author = object.data.creators[0].lastName} else {var author=""};
                                    }
                                    else {var author =""};
                                     * */
                           if(typeof object.data.title!= undefined) {var title = object.data.title};

/*                           console.log("title: " + title);*/
/*                           console.log("Author: " + author);*/
/*                           console.log("ID: " + object.key);*/
                    console.log("Fulldata de Zotero: " + JSON.stringify(object.data));
                    console.log("OWLSAMEAS: " + JSON.stringify(object.data.relations["owl:sameAs"]));
                           return {
                                label: title + ' (Zotero key: ' + object.key + ')',
                                //author: author,
                                //author: object.data.creators[0].lastName,
                                date: object.data.date,
                                title: title,
                                //title: object.data.title,
                                value: object.key,
                                key: object.data.key,
                                fullData: object.data
                                };

                       }
                    )
                  );

            },
            error: console.log("Erreur")
        });

      },
      minLength: 3,
      select: function( event, ui ) {
            event.preventDefault();
            var zoteroGroup = $("#zoteroGroupNo").text();
            $('#zoteroLookupInputModal').val(ui.item.label);


/*              $("#selectedBiblioAuthor").html("Author: " + ui.item.fullData.creator[0].firstName + " " + ui.item.fullData.creator[0].lastName);*/
              //$("#selectedBiblioAuthor").html("Author: " + ui.item.author);
              //$("#selectedBiblioDate").html("Date: " + ui.item.fullData.date);
              $("#selectedResourceTitle").append('Title: <em>' + ui.item.title + '</em>')
              $("#selectedResourceUri").html("https://www.zotero.org/groups/"+ zoteroGroup + "/" + getCurrentProject() + "/items/itemKey/" + ui.item.value);
              $("#selectedResourceId").html(ui.item.value);
              ;

            }
    } );


function addResourceToPlace(zoteroGroup, type){
    event.preventDefault();  
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");
    $("button").attr("disabled", true);
    
/*    if($('#addResourceForm').valid() == true) { */
    
    var resourceId = $('#selectedResourceId').html();
    var citedRange = $('#citedRange').val();
    var request = new XMLHttpRequest();
    var placeUri = getCurrentPlaceUri();

    var xmlData="<xml>"
                    + "<placeUri>" + placeUri + "</placeUri>"
                    + "<zoteroGroup>" + zoteroGroup + "</zoteroGroup>"
                    + "<type>" + type + "</type>"
                    + "<resourceId>" + resourceId + "</resourceId>"
                    + "<citedRange>" + citedRange + "</citedRange>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=addResourceToPlace" , true);
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
     request.open("POST", "$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=addResource" , true);
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
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");

    var xmlData="<xml>"
                    + "<resourceUri>" + resourceUri + "</resourceUri>"
                    + "<placeUri>" + placeUri + "</placeUri>"
                    +"</xml>";
     var request = new XMLHttpRequest();
     request.open("POST", "$ausohnum-lib-dev/modules/spatiumStructor/getFunctions.xql?type=changePlaceToNearTo" , true);
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
        $("body").css("opacity", "1");
        $("body").css("cursor", "default");
};

function openPlaceFromLink(uri){
 $("body").toggleClass("wait");
 var sourceFromXql = "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getPlaceHTML&resource=" + encodeURIComponent(uri);
    var conceptFromXqlWithURI = "/place-record/" + encodeURI(uri); 
    $("#placeEditor").load(sourceFromXql);
  var id = uri.toString().substring(uri.toString().lastIndexOf("/")).replace("#this", "");
  history.pushState(null, null,  "/places" + id);
    document.title = "Place " + " - " + id;
  $("body").removeClass("wait");
};

/*
****************************
*     Dropdown menus       *
****************************
*/
 $(function(){
$( "#content" ).on( "click", ".dropdown-menu li a", function( event ) {
    //console.log("menu: " + $(this).attr('menu'));
                  console.log("v: " + $(this).attr('value'));
                  console.log("text: " + $(this).text());
        /*        var menu = "#" + $(this).attr('id');*/
                var menu = $(this).attr('menu');
                 $(menu).html($(this).text()  + '<span class="caret"></span>');
                 $(menu).attr('value', $(this).attr('value'));
                 $(menu).attr('conceptHierarchyUris', $(this).attr('conceptHierarchyUris'));        
});
});

function selectPeripleoPlace(){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

    var placeUri = $('#newPlaceUri').val();
    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<docId>" + docId + "</docId>"
                    + "<placeUri>" + placeUri + "</placeUri>"
                    
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getPeripleoPlaceDetails" , true);
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
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            if(xmlDocXml.getElementsByTagName('geo:long')[0]){
            longitude= xmlDocXml.getElementsByTagName('geo:long')[0].childNodes[0].nodeValue;
            latitude= xmlDocXml.getElementsByTagName('geo:lat')[0].childNodes[0].nodeValue;
            $("#latNewPlace").val(latitude);
            $("#longNewPlace").val(longitude);
            }
          
          altLabels= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('altLabels')[0]);
            placeLabel= xmlDocXml.getElementsByTagName('placeLabel')[0].childNodes[0].nodeValue;
           exactMatch= xmlDocXml.getElementsByTagName('exactMatch')[0].childNodes[0].nodeValue;
          console.log("altLabels: " + altLabels);
          
          $("#dialogSearchPeripleo").modal('hide');    
           
            $("#newPlaceStandardizedNameEn").val(placeLabel);
            $("#exactMatch").val(exactMatch);
            $("#altLabelImport").replaceWith(altLabels);
            $("#geometryType").val("Point");
            $("#addPlaceButtonDocPlaces").toggleClass("hidden");
            $("#newPlaceTypeContainer").toggleClass("hidden");
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        
        

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function selectPleiadesPlace(){
    if($('input[name=selectedPlace]:checked').val()===undefined){alert("Please select a place first");}
    else{
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");
    $("button").attr("disabled", true);

    var placeUri = "https://pleiades.stoa.org/places/" + $('input[name=selectedPlace]:checked').val();
    var request = new XMLHttpRequest();
    var xmlData="<xml>"
                + "<docId>" + docId + "</docId>"
                + "<placeUri>" + placeUri + "</placeUri>"
                +"</xml>";
    console.log("xmldata: " + xmlData);
    
    /*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
         request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getPeripleoPlaceDetails" , true);
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
    /*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
                if(xmlDocXml.getElementsByTagName('geo:long')[0]){
                longitude= xmlDocXml.getElementsByTagName('geo:long')[0].childNodes[0].nodeValue;
                latitude= xmlDocXml.getElementsByTagName('geo:lat')[0].childNodes[0].nodeValue;
                $("#latNewPlace").val(latitude);
                $("#longNewPlace").val(longitude);
                }
              
              altLabels= (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('altLabels')[0]);
                placeLabel= xmlDocXml.getElementsByTagName('placeLabel')[0].childNodes[0].nodeValue;
               exactMatch= xmlDocXml.getElementsByTagName('exactMatch')[0].childNodes[0].nodeValue;
              console.log("altLabels: " + altLabels);
              
              $("#dialogSearchPleiades").modal('hide');    
               
                $("#newPlaceStandardizedNameEn").val(placeLabel);
                $("#exactMatch").val(exactMatch);
                $("#altLabelImport").replaceWith(altLabels);
                $("#geometryType").val("Point");
                $("#addPlaceButtonDocPlaces").toggleClass("hidden");
                $("#newPlaceTypeContainer").toggleClass("hidden");
            $("body").css("cursor", "default");
            $("body").css("opacity", "1");
            $("button").attr("disabled", false);
            
            
    
                }
                };
    
            request.setRequestHeader('Content-Type', 'text/xml');
    
            request.send(xmlData);
            }
};

function addDrawnFeatureToPlace(geojson){
    
    var featureType = geojson.geometry.type;
console.log(featureType);
console.log(geojson);

if($("#newPlaceStandardizedNameEn").length){
            $("#geometryType").val(featureType);
                if(featureType == "Point") {
                    $("#longNewPlace").val(geojson.geometry.coordinates[0]);
                    $("#latNewPlace").val(geojson.geometry.coordinates[1]);
                } else if(featureType == "Polygon") {
                    console.log(geojson.geometry.coordinates)  
/*                    $("#geometryType").val("Polygon");*/
            var coordinates = geojson.geometry.coordinates[0].toString();
                      var firstCornerLong = coordinates.substr(0, coordinates.indexOf(','));
                      var firstCornerLat = coordinates.substr(coordinates.indexOf(',')+1, coordinates.indexOf(',', 2));
                    $("#polygonCoordinatesNewPlace").val(geojson.geometry.coordinates[0]);
                    
                }
    }//end If
if($("#placeLocationTypeValue").length){
            $("#placeLocationTypeValue").val(featureType);
                if(featureType == "Point") {
                $("#geometryType").val("POINT");
                    $("#placeLocationLongitudeValue").val(geojson.geometry.coordinates[0]);
                    $("#placeLocationLatitudeValue").val(geojson.geometry.coordinates[1]);
                } else if(featureType == "Polygon") {
                            console.log("geojson.geometry.coordinates[0]; " +geojson.geometry.coordinates[0]);
                      var coordinates = geojson.geometry.coordinates[0].toString();
                      var firstCornerLong = coordinates.substr(0, coordinates.indexOf(','));
                      var firstCornerLat = coordinates.substr(coordinates.indexOf(',')+1, coordinates.indexOf(',', 2));
                      $("#placeLocationLongitudeValue").val(firstCornerLong);
                    $("#placeLocationLatitudeValue").val(firstCornerLat);
                    $("#geometryType").val(featureType );
                    $("#polygonCoordinatesValue").val(geojson.geometry.coordinates[0]);
                    
                }
    }//end If    
    
    
    
};

function updateFeature(geojson){
    
    var featureType = geojson.geometry.type;
console.log(featureType);
console.log(geojson);
$("#featureType").val(featureType);
    if(featureType == "Point") {
        $("#placeLocationLongitudeValue").val(geojson.geometry.coordinates[0]);
        $("#placeLocationLatitudeValue").val(geojson.geometry.coordinates[1]);
    } else if(featureType == "Polygon") {
        console.log(geojson.geometry.coordinates)  
        $("#geometryType").val("Polygon");
        $("#polygonCoordinatesValue").val(geojson.geometry.coordinates[0]);
        
    }
    
    
    
    
};

function createNewPlace(){
    var coordinates= $("#polygonCoordinatesNewPlace").val();
    var longitude = $("#longNewPlace").val();
    var latitude = $("#latNewPlace").val();
    var title = $("#newPlaceStandardizedNameEn").val();
    var exactMatch= $("#exactMatch").val();
    var geometryType =$("#geometryType").val();
    var prefLabelLa = $("#prefLabelLa").val();
    var prefLabelGrc = $("#prefLabelGrc").val();
    
    /*$( ".alt" ).each(function(i, el) {
                el = $(el);
                
      });
    */
/*    var = $("").val();*/
    
    var placeType =$("#hasFeatureTypeMain_1_").val();
    var productionType=$("#productionType_1_").val();
    var request = new XMLHttpRequest();

        if(title != ""){
         if(
         (((latitude !== "") || (longitude!== "")
         ) 
           && 
           (
           latitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g)) && (longitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g))
           )==null
           )
                {alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111" );}
      else {
      if( (latitude.match(/(°|\')/g)) || (longitude.match(/(°|\')/g))){
        alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111\n"
        +"They must NOT contain ° or ' characters");
        return false;
        };
      $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        
        var xmlData="<xml>"
                    + "<title>" + title + "</title>"
                    + "<prefLabelLa>" + prefLabelLa + "</prefLabelLa>"
                    + "<prefLabelGrc>" + prefLabelGrc + "</prefLabelGrc>"
                    + "<geometryType>" + geometryType + "</geometryType>"
                    + "<coordinates>" + coordinates + "</coordinates>"
                    + "<longitude>" + longitude + "</longitude>"
                    + "<latitude>" + latitude+ "</latitude>"
                    + "<placeTypeMain>" + placeType + "</placeTypeMain>"
                    + "<productionType>" + productionType + "</productionType>"
                    + "<exactMatch>" + exactMatch + "</exactMatch>"
                    
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=createNewPlace" , true);
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
            newPlaceId= xmlDocXml.getElementsByTagName('newId')[0].childNodes[0].nodeValue;
            
            $("#placeEditor").html(newHtml);
              history.pushState(null, null,  "/edit-places/" + newPlaceId);
        
        
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        var tree = $("#collection-tree").fancytree("getTree");
        var newSourceOption = {
                            url: '/geo/build-tree/'};
        tree.reload(newSourceOption);
        $("#collection-tree").fancytree("getTree").activateKey(newPlaceId);
/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
   }

    } else {alert("Please enter at least one standardized name in English");}

};
function createNewPlace(type){
    var coordinates= $("#polygonCoordinatesNewPlace").val();
    var longitude = $("#longNewPlace").val();
    var latitude = $("#latNewPlace").val();
    var title = $("#newPlaceStandardizedNameEn").val();
    var exactMatch= $("#exactMatch").val();
    var geometryType =$("#geometryType").val();
    var prefLabelLa = $("#prefLabelLa").val();
    var prefLabelGrc = $("#prefLabelGrc").val();
    var altLabelList =[];
    $(".altLabelImport").each(function(){
        value = $(this).children(".altLabelExtResource").text();
        lang = $(this).children(".altLabelLangFromExtResource").text();
        altLabelList.push(value);
    });
    //console.log(altLabelList);
    /*$( ".alt" ).each(function(i, el) {
                el = $(el);
                
      });
    */
/*    var = $("").val();*/
    
    var placeType =$("#hasFeatureTypeMain_1_").val();
    var productionType=$("#productionType_1_").val();
    var request = new XMLHttpRequest();

        if(title != ""){
         if(
         (((latitude !== "") || (longitude!== "")
         ) 
           && 
           (
           latitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g)) && (longitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g))
           )==null
           )
                {alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111" );}
      else {
      if( (latitude.match(/(°|\')/g)) || (longitude.match(/(°|\')/g))){
        alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111\n"
        +"They must NOT contain ° or ' characters");
        return false;
        };
      $("body").css("cursor", "wait");
        $("body").css("opacity", "0.5");
        
        var xmlData="<xml>"
                    + "<type>" + type + "</type>"
                    + "<title>" + title + "</title>"
                    + "<prefLabelLa>" + prefLabelLa + "</prefLabelLa>"
                    + "<prefLabelGrc>" + prefLabelGrc + "</prefLabelGrc>"
                    + "<geometryType>" + geometryType + "</geometryType>"
                    + "<coordinates>" + coordinates + "</coordinates>"
                    + "<longitude>" + longitude + "</longitude>"
                    + "<latitude>" + latitude+ "</latitude>"
                    + "<placeTypeMain>" + placeType + "</placeTypeMain>"
                    + "<productionType>" + productionType + "</productionType>"
                    + "<exactMatch>" + exactMatch + "</exactMatch>"
                    
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=createNewPlace" , true);
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
            newPlaceId= xmlDocXml.getElementsByTagName('newId')[0].childNodes[0].nodeValue;
            $("#placeEditor").html(newHtml);
            if(type == "archaeo-manager"){
                history.pushState(null, null,  "/archaeo/" + newPlaceId);
                document.title = "Place " + " - " + newPlaceId;
                var tree = $("#collection-tree").fancytree("getTree");
                var newSourceOption = {
                            url: '/geo/build-archaeotree/'};
                tree.reload(newSourceOption);
                $("#collection-tree").fancytree("getTree").activateKey(newPlaceId);
                }
            else if(type == "places-manager"){
                history.pushState(null, null,  "/edit-places/" + newPlaceId);
                document.title = "Place " + " - " + newPlaceId;
//                var tree = $("#collection-tree").fancytree("getTree");
//                var newSourceOption = {
//                            url: '/geo/build-tree/'};
//                tree.reload(newSourceOption);//
//                $("#collection-tree").fancytree("getTree").activateKey(newPlaceId);
                }
        else {
                history.pushState(null, null,  "/edit-places/" + newPlaceId);
                document.title = "Place " + " - " + newPlaceId;
                if($("#collection-tree").length>0)
                    {var tree = $("#collection-tree").fancytree("getTree");
                         var newSourceOption = {url: '/geo/build-tree/'};
                        tree.reload(newSourceOption);
                        $("#collection-tree").fancytree("getTree").activateKey(newPlaceId);
                    }
                  }
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        
/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
   }

    } else {alert("Please enter at least one standardized name in English");}

};
function createNewSubPlace(){
    var coordinates= $("#polygonCoordinatesNewPlace").val();
    var longitude = $("#longNewPlace").val();
    var latitude = $("#latNewPlace").val();
    var title = $("#newPlaceStandardizedNameEn").val();
    var exactMatch= $("#exactMatch").val();
    var geometryType =$("#geometryType").val();
    var prefLabelLa = $("#prefLabelLa").val();
    var prefLabelGrc = $("#prefLabelGrc").val();
    
    /*$( ".alt" ).each(function(i, el) {
                el = $(el);
                
      });
    */
/*    var = $("").val();*/
    
    var placeType =$("#hasFeatureTypeMainSubPlace_1_").val();
    var productionType=$("#productionType_1_").val();
    var request = new XMLHttpRequest();

        if(title != ""){
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

var xmlData="<xml>"
                    + "<title>" + title + "</title>"
                    + "<parentPlaceUri>" + getCurrentPlaceUri() + "</parentPlaceUri>"
                    + "<prefLabelLa>" + prefLabelLa + "</prefLabelLa>"
                    + "<prefLabelGrc>" + prefLabelGrc + "</prefLabelGrc>"
                    + "<geometryType>" + geometryType + "</geometryType>"
                    + "<coordinates>" + coordinates + "</coordinates>"
                    + "<longitude>" + longitude + "</longitude>"
                    + "<latitude>" + latitude+ "</latitude>"
                    + "<placeTypeMain>" + placeType + "</placeTypeMain>"
                    + "<productionType>" + productionType + "</productionType>"
                    + "<exactMatch>" + exactMatch + "</exactMatch>"
                    
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=createNewSubPlace" , true);
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
            newPlaceId= xmlDocXml.getElementsByTagName('newId')[0].childNodes[0].nodeValue;
              $("#placeEditor").html(newHtml);
              history.pushState(null, null,  "/archaeo/" + newPlaceId);
        $("body").css("cursor", "default");
        $("body").css("opacity", "1");
        $("#dialogAddNewSubPlace").modal('hide');
        var tree = $("#collection-tree").fancytree("getTree");
        var newSourceOption = {
                            url: '/geo/build-archaeotree/'};
        tree.reload(newSourceOption);
        $("#collection-tree").fancytree("getTree").activateKey(newPlaceId);
/*             console.log("Response : Value of xmlDoc" + xmlDoc);*/
/*             console.log("Id of element" + idElementValue);*/


            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);
} else {alert("Please enter at least one standardized name in English");}

};


function addPlaceToPlace(updatedPlaceURI){
event.preventDefault();
$("body").css("cursor", "wait");
$("body").css("opacity", "0.5");

    var placeUri = $('#newPlaceUri').val();
    
    var request = new XMLHttpRequest();


    var xmlData="<xml>"
                    + "<currentPlaceUri>" + getCurrentPlaceUri() + "</currentPlaceUri>"
                    + "<placeToBeAddedUri>" + $("#selectedPlaceUri").val() + "</placeToBeAddedUri>"
                    + "<placeRelationType>" + $("#placeTypeSelection").val() +"</placeRelationType>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
     request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=addPlaceToPlace" , true);
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
/*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            updatedPlace = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedPlace')[0]);
            
            
             /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
            $("#addPlaceButtonDocPlaces").toggleClass("hidden");
            $("#newPlaceTypeContainer").toggleClass("hidden");
            $("#dialogAddSubPlace").modal('hide');
            $("#placeEditor").html(updatedPlace);
            $("body").css("cursor", "default");
            $("body").css("opacity", "1");
        

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);


};

function editLocation(longitude, latitude){
    $("#editLocationButton").click();
    /*$("#placeLocation_display").toggleClass("hidden");
    $("#placeLocation_edit").toggleClass("hidden");
    */
/*addEditionMarker(longitude, latitude);    */
    
};


function saveLocation(){
    event.preventDefault();
    var latitude = $("#placeLocationLatitudeValue").val(); 
    var longitude = $("#placeLocationLongitudeValue").val() ;
        
    if( latitude.match(/(°|\')/g) ||
     longitude.match(/(°|\')/g)){
        alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111\n"
        +"They must NOT contain ° or ' characters");
        return false;
        };
if( (latitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g)) && (longitude.match(/(^\-?[0-9]{1,2}\.[0-9]+$)?/g))){
            
    $("body").css("cursor", "wait");
    $("body").css("opacity", "0.5");

    var placeUri = getCurrentPlaceUri();
    
    var request = new XMLHttpRequest();


    var xmlData=
                 "<xml>"
                    + "<type>" + $("#placeLocationTypeValue").val() + "</type>"
                    + "<longitude>" + $("#placeLocationLongitudeValue").val() + "</longitude>"
                    + "<latitude>" + $("#placeLocationLatitudeValue").val() + "</latitude>"
                    + "<coordinates>" + $("#polygonCoordinatesValue").val() + "</coordinates>"
                    + "<placeUri>" + placeUri +"</placeUri>"
                +"</xml>";

     console.log("xmldata: " + xmlData);

/*     request.open("POST", "http://patrimonium.huma-num.fr/admin/save/document/addBiblio", true);*/
       request.open("POST", "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=updateLocation" , true);
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
   /*            console.log(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
               updatedPlace = (new XMLSerializer()).serializeToString(xmlDocXml.getElementsByTagName('updatedPlace')[0]);
               
               $("#placeEditor").html(updatedPlace);
                /*$("#listOfPlacesOverview").html(xmlDocXml.getElementsByTagName('newList')[0].getElementsByTagName( 'div' )[0].childNodes);*/
               $("#addPlaceButtonDocPlaces").toggleClass("hidden");
               $("#newPlaceTypeContainer").toggleClass("hidden");
               $("#dialogAddSubPlace").modal('hide');
               $("body").css("cursor", "default");
               $("body").css("opacity", "1");
               var url = window.location.href;
               if(url.includes("places")) {var newSourceOption = {
                                    url: '/geo/build-tree/'};}
               else if (url.includes("archaeo")) {var newSourceOption = {
                                    url: '/geo/build-archaeotree/'};}
               
                var tree = $("#collection-tree").fancytree("getTree");
                
                tree.reload(newSourceOption);
                $("#collection-tree").fancytree("getTree").activateKey(placeUri);

            }
            };

        request.setRequestHeader('Content-Type', 'text/xml');

        request.send(xmlData);

} else {alert("Geocoordinates must be expressed in Decimal Degrees (WGS 84).\n e.g. : 11.11111 \n"
        +"-11.11111" );}
    
};


function openBiblioDialog(){
    $('#dialogInsertBiblio').modal('show');
};

/*$( ".zoteroLookup" ).attr('autocomplete','on');*/
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
                            
                            success : function(data){
                        
                                console.log("group: " +zoteroGroup);
                                console.log("sucess: " + JSON.stringify(data));
                                response(
                                $.map(
                                    data, function(object){
                                        console.log(JSON.stringify(object.data));
                                var creators = 'creators' in data && data.creators[0] || "nocreators"
                                 if(creators !== "nocreators")
                                    {
                                        if(object.data.creators[0].lastName)
                                               {var author = object.data.creators[0].lastName}
                                                else if (object.data.creators[0].surname){var author = object.data.creators[0].surname}
                                    }
                                    else{var author =""}
                                 
                                 
                                 /*   if(object.data['creators'][0])
                                            {if(object.data.creators[0].lastName){var author = object.data.creators[0].lastName}
                                                else if (object.data.creators[0].surname){var author = object.data.creators[0].surname}
                                            }
                                            else{var author =""}*/
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

function displayPlace(placename, uri){

    var id = uri.toString().substring(uri.toString().lastIndexOf("/")+1).replace("#this", "");
    var currentZoom = displayMap.getZoom();
    if(currentZoom > 7) { var zoom = currentZoom} else {var zoom = 9}
   /* if(lat != undefined || lng != undefined )
            { if(lat != "" || lng != "" ) {displayMap.setView([lat, lng], 12);}};*/
    //console.log(uri.replace("#this", ""));
     var regex = '#this';
/*     console.log("Test regec: " + uri.replace(regex, ""));*/
        
     var markerCoordinates = markerMap[uri.replace(regex, "")].getLatLng();
    displayMap.setView([markerCoordinates.lat, markerCoordinates.lng], zoom);
    if(getEditorType() =="archaeo"){
        $("#placeEditor").load("/archaeo/get-record/" + id);
        history.pushState(null, null,  "/archaeo/" + id);
    }
    else{
    $("#placeEditor").load("/places/get-record/" + id);
    history.pushState(null, null,  "/edit-places/" + id);
    }
    document.title = placename + " - " + id;
    
};
function openNewPlaceForm(){
    $("#placeEditor").load("$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=newPlaceForm&placeEditorType=places-manager");
    history.pushState(null, null,  "/edit-places/new");
    document.title = "Creation of a new place";
};

function toDegreesMinutesAndSeconds(coordinate) {
    var absolute = Math.abs(coordinate);
    var degrees = Math.floor(absolute);
    var minutesNotTruncated = (absolute - degrees) * 60;
    var minutes = Math.floor(minutesNotTruncated);
    var seconds = Math.floor((minutesNotTruncated - minutes) * 60);

    return degrees + "° " + minutes + "' " + seconds + "''";
}

function convertDMS(lat, lng) {
    var latitude = toDegreesMinutesAndSeconds(lat);
    var latitudeCardinal = lat >= 0 ? "N" : "S";

    var longitude = toDegreesMinutesAndSeconds(lng);
    var longitudeCardinal = lng >= 0 ? "E" : "W";

    return latitude + " " + latitudeCardinal + "\n" + longitude + " " + longitudeCardinal;
};

                       

function showPlaceOnMapAndDisplayRecord(uri){
        if($("#atlasMap").length){
        
        atlasMap.closePopup();
        //atlasMap.removeLayer(tempLayerGroup);
        tempLayerGroup.clearLayers()
    var id = uri.toString().substring(uri.toString().lastIndexOf("/")+1).replace("#this", "");
    var currentZoom = atlasMap.getZoom();
    if(currentZoom > 7) { var zoom = currentZoom} else {var zoom = 9}
   /* if(lat != undefined || lng != undefined )
            { if(lat != "" || lng != "" ) {displayMap.setView([lat, lng], 12);}};*/
    
     var markerCoordinates = markerMap[uri].getLatLng();
//console.log(markerMap[uri].id)

     atlasMap.setView([markerCoordinates.lat, markerCoordinates.lng], zoom);
       if($("#placeRecordContainer").length) {
                $("#placeRecordContainer").removeClass("hidden");
              };
       $("#mapPlaceRecord").load("/places/get-place-record/" + id,
                            function( ) {
                                $("#loaderBig").hide();
                                $("#mapPlaceRecord").load("/places/get-place-record/" + id);
                                //document.title = "APC Place " + id + " - " + placename;
                            });
                            
       //markerMap[uri].getPopup().openOn(atlasMap);
console.log(markerMap[uri].__parent._bounds);
/*var rectangle = new L.rectangle(markerMap[uri].__parent._bounds, {fillColor: "green",
                                                  weight: 0,
                                                  fillOpacity: .1
                                                  
                                                  }).addTo(atlasMap);*/
    if(markerMap[uri].options.isMadeOf== null || markerMap[uri].options.placeType != "Province"){
                                        var popup = L.popup({keepInView: false, closeButton: true, autoClose: false, autoPan: false, closeOnClick: false })
                                            .setLatLng([markerCoordinates.lat, markerCoordinates.lng])
                                            .setContent(markerMap[uri].getPopup().getContent())
                                            .openOn(atlasMap);
                                    }
     if(markerMap[uri].options.isMadeOf != null){
         if(markerMap[uri].options.isMadeOf.split(" ").length > 1 && markerMap[uri].options.placeType != "Province"){
            var popup = L.popup({keepInView: false, closeButton: true, autoClose: false, autoPan: false, closeOnClick: true })
                            .setLatLng([markerCoordinates.lat, markerCoordinates.lng])
                            .setContent(markerMap[uri].getPopup().getContent())
                            .openOn(atlasMap);
          $(markerMap[uri].options.isMadeOf.split(" ")).each(function(i, uri){
                    var tempMarker = markerMap[uri];
                    var latlngs =[[markerCoordinates.lat, markerCoordinates.lng],
                                          tempMarker.getLatLng()  ]
                    var polyline = L.polyline(latlngs, {color: 'red', weight: 1, opacity: 0.8});
                    tempLayerGroup.addLayer(polyline);
                    //tempClusterMarkers.addLayer(tempMarker);      
                });
             
             //var parentMarker = L.marker([markerCoordinates.lat, markerCoordinates.lng]);
              //tempClusterMarkers.addLayer(parentMarker);
              
           atlasMap.addLayer(tempLayerGroup);
              }
              }
    
    }
    else {
        window.open(uri, "_blank");
    }
};

L.Control.removeLinesControl = L.Control.extend({
              onAdd: function(map) {
                var el = L.DomUtil.create('div', 'leaflet-bar removeLineControl');
            
                el.type="button";
                el.style.border = "2px solid rgba(0,0,0,0.2)";
                el.style.padding = "2px";
                el.style.backgroundClip = "padding-box";
                el.style.color = "white";
                el.style.backgroundColor = '#7d1d20';     
                el.innerHTML = 'Remove lines';
                
                el.onclick = function(){
                      tempLayerGroup.clearLayers();
                      el.remove(atlasMap);
                          }
                return el;
              },
            
              onRemove: function(map) {
                // Nothing to do here
              }
            });
            
            L.control.removeLinesControl = function(opts) {
              return new L.Control.removeLinesControl(opts);
            }
            
function closeAtlasSearchPanel(){    $("#atlasSearchPanel").addClass("hidden");};
function closeAtlasLegendPanel(){    $("#atlasMapLegend").addClass("hidden");};            