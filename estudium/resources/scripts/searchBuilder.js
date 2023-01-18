$(document).ready( function () {
    var dataTable = $('#hitsTable').DataTable({
        scrollX:        false,
        scrollCollapse: true,
        responsive: true,
        paging: true,
        pageLength: 50,
        lengthMenu: [[25, 50, 100, 200, -1], [25, 50, 100, 200, "All"]],
        dom: "<'row'<'col-sm-2'l><'col-sm-4'B><'col-sm-6'f>>" +
                                                "<'row'<'col-sm-5'i><'col-sm-7'p>>" +
                                                "<'row'<'col-sm-12'tr>>" +
                                             "<'row'<'col-sm-5'i><'col-sm-7'p>>"
                                                ,
        columns: [
            { data: 'no' },
            { data: 'docId' },
            { data: 'summary',
                render: function ( data, type, row ) {
                    return decodeHTML(data)}
                },
            { data: 'text' },

            { data: 'provenance' },
            { data: 'provenanceUri' },
            { data: 'province' },
            { data: 'provinceUri' },
            { data: 'datingNotBefore' },
            { data: 'datingNotAfter' },
            { data: 'keywords',
                render: function ( data, type, row ) {
                    return decodeHTML(data)}}
            ],
            "columnDefs": [
                {
                    "targets": [ 1, 3, 5, 7, 10 ],
                    "visible": false,
                    "searchable": true
                }
                
            ],
            buttons: [
                    {
                        extend: 'csv',
                        className: 'exportButton',
                        text: '<i class="glyphicon glyphicon-export"/> csv'
                        },
                        {
                        extend: 'excel',
                        className: 'exportButton',
                        text: '<i class="glyphicon glyphicon-export"/> excel'
                        },
                        {
                        extend: 'copy',
                        className: 'exportButton',
                        text: '<i class="glyphicon glyphicon-copy"/> copy'
                        },
                    //, 'excel', 'pdf', 'print'
                    ],
            language: {
                                    search: "",
                                    searchPlaceholder: "Filter results by title, place or keywords..."
                                        }  
        
        
    }
    )
    
    $("#searchResultsMap").mouseover(function() {
      searchResultsMap.scrollWheelZoom.disable();
    });
    
$('[data-toggle="popover"]').popover({
    
    html: true,
    content: function() {
        var content = $(this).attr("data-popover-content");
        return $("#popover-body").html();
    },
    title: function() {
      
      return $("#popover-title").html();
    }
  });
  
  





});   



function addElementToQuery(type){
    switch(type){
        case "keyword": 
            
            var $keywordLabel = $("#addElementToQuery-" + type).find('button.elementWithValue').text().trim();
            var $keywordUri = $("#addElementToQuery-" + type).find('button.elementWithValue').val();
            var $origLabel = $("#addElementToQuery-" + type).find('button.elementWithValue').attr("label").trim();
            console.log("keywordLabel=" + $keywordLabel 
                + " OrigLabel=" + $origLabel + ($keywordLabel != $origLabel));
            if($keywordLabel != $origLabel){ 
                    var $elementForQuery = '<a class="btn btn-xs btn-default elementForQuery keyword" title="' + $keywordLabel + ' [' + $keywordUri
                        + ']" keywordLabel="' + $keywordLabel + '" keywordUri="' + $keywordUri + '"><span class="" style="margin: 0 5px 0 0">'
                            + $keywordLabel
                        + '<button class="removeItem btn btn-xs btn-warning pull-right" onclick ="removeElementFromQuery(this)">'
                        + '<i class="glyphicon glyphicon-trash" title="Remove element from query" /></button >'
                        + '</a>';
                    
                    
                    $("#addElementToQuery-" + type).find('button.elementWithValue').html($origLabel + ' <span class="caret"></span>');
                    $("#addElementToQuery-" + type).find('button.elementWithValue').val("");
            }
            else{alert("Please select an item first");
                exit();}
            break;
            case "word": 
            
           
            break;
        default:
    }
    var $queryElementNumber = $("#queryPanel").find(".elementForQuery").length + 1;
    var $htmlElement = '<span class="queryBlock panel panel-default">';
    
    if ($queryElementNumber > 2) {
        $htmlElement = $htmlElement + '<select name="operator' + $queryElementNumber + '" id="operator' + $queryElementNumber + '" class="queryOperator">'
            + '<option value="or" selected="selected">OR</option>'
            + '<option value="and" >AND</option>'
            + '</select>'
    }
    else if($queryElementNumber = 1){
        $htmlElement = $htmlElement + '<select name="operator' + $queryElementNumber + '" id="operator' + $queryElementNumber 
        
        + '" class="queryOperator">'
            + '<option value="and" selected="selected">AND</option>'
            + '<option value="or" >OR</option>'
            + '</select>'
    }
    $htmlElement = $htmlElement + $elementForQuery + '</span>';
    $("#queryPanel").append($htmlElement);
}

function removeElementFromQuery($this){
    $($this).parents().closest('.elementForQuery').closest('.queryBlock').remove();
    var $queryElementNumber = $("#queryPanel").find(".elementForQuery").length;
    if ($queryElementNumber < 2) { $("#queryPanel").find(".queryBlock").find(".queryOperator").remove()}
}

function executeBuiltQuery(){
    if(!$("#load-indicator").hasClass('hidden')){$("#load-indicator").toggleClass("hidden");};
    
    var $keywords = "";
    
    $("#queryPanel").find(".queryBlock").each(function (i, element) {
            var elementForQuery = $(element).find(".elementForQuery");
            var operatorForQuery = $(element).find(".queryOperator");
            var $operatorForQuery;
            console.log("keywordUri: " + elementForQuery.attr("keywordUri"));
            console.log("operator: " + operatorForQuery.val());

        if (operatorForQuery.val() == undefined) { $operatorForQuery = "or" } else { $operatorForQuery = operatorForQuery.val()}
            $keywords = $keywords
                + "<keyword>"
                + "<keywordUri>" + elementForQuery.attr("keywordUri") + "</keywordUri>"
                + "<keywordLabel>" + elementForQuery.attr("keywordLabel") + "</keywordLabel>"
                + "<operator>" + $operatorForQuery + "</operator>"
                + "</keyword>"
    });
    
    var xmlData = "<xml>"
                + "<keywords>" + $keywords + "</keywords>"
                + "</xml>"
    console.log(xmlData);
                var request = new XMLHttpRequest();
    request.open("POST", "/search/query/", true);
    request.onreadystatechange = function () {


        //TODOAPPEND TO GROUP
        if (request.readyState == 4 && request.status == 200) {
            xmlDoc = request.responseXML;
            newElement2Display = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('html')[0]);
            /* newElement2Display = xmlDoc.getElementsByTagName('html'); */
            /* geojson = (new XMLSerializer()).serializeToString(xmlDoc.getElementsByTagName('geojson')[0]); */
            geojsonStrg = xmlDoc.getElementsByTagName('geojson')[0].textContent;
            geojson = JSON.parse(geojsonStrg.substring(1, geojsonStrg.lastIndexOf("]")));
            console.log(geojson);
            
            geojsonFeatureCollection =
                /* L.geoJSON(geojson); */
                L.geoJSON(geojson, { onEachFeature: onEachFeatureSearchResults, pointToLayer: pointToLayerProjectPlace });
            
            if($("#load-indicator").hasClass('hidden')){$("#load-indicator").toggleClass("hidden");};

            $("#searchResultsPanel").html(newElement2Display);
           
            if (jQuery.isEmptyObject(geojson) !=true){
                geojsonFeatureCollection.addTo(searchResultsMap);
            };
            
        }
        else if (request.readyState == 4 && request.status == 400) {
            if($("#load-indicator").hasClass('hidden')){$("#load-indicator").toggleClass("hidden");};

            $("#searchResultsPanel").html(xmlDoc.toString());
        }
    };
    request.setRequestHeader('Content-Type', 'text/xml');

    request.send(xmlData);
}

function executeftSearch(){
    $("#load-indicator").toggleClass("hidden");
    var query = $("#query").val();
    var mode = $("#mode").val();
    console.log(query + " " + mode)
    /* var datatable = new $.fn.dataTable.Api( "#hitsTable" ); */
    var datatable = $('#hitsTable').DataTable();
    
    $.ajax({
        url: "/executeftSearch/",
        type: "post",
        dataType: "json",
        dataSrc: "data",
        data: { 
          query: query, 
          mode: mode,
          lemmataMode: 'no'
          
        },
        complete: function(newDataArray) {
            datatable.clear().draw();
            if(newDataArray.responseJSON.results!==null){
            if($(".searchResultsPaneElement").hasClass('hidden')){$(".searchResultsPaneElement").toggleClass("hidden");};
            datatable.rows.add(newDataArray.responseJSON.results.data);
            datatable.columns.adjust().draw(); 
            
            geojson = newDataArray.responseJSON.geojson.root;
            
            var searchResultsNo = newDataArray.responseJSON.summary.match;
            var searchResultsNoString ="";
                if(searchResultsNo>1){
                    searchResultsNoString = "Found " + newDataArray.responseJSON.summary.match + " matches"}
                    else{searchResultsNoString = "Found 1 match" }
                if(newDataArray.responseJSON.summary.docsTotal >1){
                        searchResultsNoString = searchResultsNoString + " in " + newDataArray.responseJSON.summary.docsTotal + " documents."}
                        else{searchResultsNoString = searchResultsNoString + " in 1 document"}

            geojsonFeatureCollection =
                /* L.geoJSON(geojson); */
                L.geoJSON(geojson, { onEachFeature: onEachFeatureSearchResults, pointToLayer: pointToLayerProjectPlace });
                
                if (jQuery.isEmptyObject(geojson) !=true){
                    geojsonFeatureCollection.addTo(searchResultsMap);
                    if(Object.keys(geojsonFeatureCollection.getBounds()).length!== 0){searchResultsMap.fitBounds(geojsonFeatureCollection.getBounds(),{maxZoom: 18});}
                };
                $("#load-indicator").toggleClass("hidden");
                $("#searchResultsNo").text(searchResultsNoString);
            }
            else{
                $("#load-indicator").toggleClass("hidden");
                $("#searchResultsNo").text("No match");

            }
        },
         error: function(xhr) {
             console.log(xhr.statusText);
             $("#load-indicator").toggleClass("hidden");
             alert("Error in http request:  " + xhr.statusText)
          //Do Something to handle error
        }
      });

      $( "#slider-range" ).slider({
        range: true,
        min: -50,
        max: 500,
        values: [ -50, 500 ],
        slide: function( event, ui ) {
          //console.log("date: " + $( "#amount" ).val( "$" + ui.values[ 0 ] + " - $" + ui.values[ 1 ] ));
          var notBefore = ui.values[ 0 ];
          var notAfter = ui.values[ 1 ];
          //console.log("notBefore= " + notBefore + " NotAfter= " + notAfter);
          $('#min').val(notBefore);
          $('#max').val(notAfter)
          
          
          
          datatable.draw();
          console.log(datatable.data());
          var places2Display=[];
          datatable.data().each( function (row) {
                if(places2Display.includes(row.provenanceUri)!==true)
                    {places2Display.push(row.provenanceUri)}
                });
             
                console.log(places2Display);
                /* searchResultsMap.getPane('filteredMarkers'); */

                searchResultsMap.eachLayer(function (layer) { 
                    console.log(layer.feature);
                        if(typeof layer.feature !== 'undefined'){
                            console.log(layer.feature !== 'undefined');
                        var placeInArray=places2Display.includes(layer.feature.properties.uri) === false;
                            console.log("layer=" + layer.feature.properties.uri);
                        // + "in places3Display: "
                  
                        console.log("in array: "+ placeInArray);
                            
                            if 
                        (placeInArray === false) {
                            /* markerMap[layer.feature.properties.uri].remove(); */
                            
                            layer.setStyle({color: 'rgba(0,0,0,0)'});

                        /* searchResultsMap.removeLayer(layer); */
        } }
        });
        }
      });

};

function decodeHTML(html) {
	var txt = document.createElement('textarea');
	txt.innerHTML = html;
	return txt.value;
};
var places2Display=[];

//* Custom filtering function which will search data in 2 columns between two values */
$.fn.dataTable.ext.search.push(
    function( settings, data, dataIndex ) {
        var maxMin = -50;
        var maxMax = 500;
        var min = parseInt( $('#min').val(), 10 );
        var max = parseInt( $('#max').val(), 10 );
  
        var notBefore = parseFloat( data[8] ) || 0;
        var notAfter = parseFloat( data[9] ) || 0; 
        if ( ( isNaN( min ) && isNaN( max ) ) ||
            ( isNaN( min ) && notAfter <= max ) ||
            ( min <= notBefore   && isNaN( max ) ) 
            ||
            ( min <= notBefore && notAfter <= max ) 
            )
        {
            /* console.log(data);
            console.log("Keep place " + data[2]);
            places2Display.push(data[3]);
            console.log(places2Display); */
            return true;
        }
        /* console.log("Discard place " + data[2]); */
        return false;
    
    }
);

function displayTextPreview(index, docId){
if($("#textPreview-" + index).is(':empty')){
    $("#textPreview-" + index).load("/search/getTextPreview/" + docId);
    }
};

/*Basemaps for maps*/
var satelliteMap = L.tileLayer.provider('MapBox', {
    id: 'mapbox.satellite',
    accessToken: 'pk.eyJ1IjoidnJhemFuYWphbyIsImEiOiJjanR0dzU5a2ExMnR5NDRsOHVsdGk2cjdoIn0.3UtNLHIkJ96HSp8qLyFZUA'
});

/* ************************* */
/*            MAP            */
/* ************************* */
if(document.getElementById("searchResultsMap")){

searchResultsMap = L.map('searchResultsMap', {
    fullscreenControl: {
        pseudoFullscreen: false
    }
});
searchResultsMap.setView([41.891775, 12.486137], 4);
searchResultsMap.createPane('markerPanelBottom');
searchResultsMap.getPane('markerPanelBottom').style.zIndex = 300;
searchResultsMap.createPane('filteredMarkers');
var geojsonFeatureProject;
var geojsonFeatureProdUnits;

var clusterMarkersOptions =
{
    showCoverageOnHover: false,
    zoomToBoundsOnClick: true,
    removeOutsideVisibleBounds: true,
    disableClusteringAtZoom: 8,
    spiderfyOnMaxZoom: 15
}
var markers = L.markerClusterGroup(
    //{  disableClusteringAtZoom: 7 }
);

var projectPlacesMarkers = L.markerClusterGroup(clusterMarkersOptions
    //{  disableClusteringAtZoom: 12 }
);

var openStreetMap = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
});

var AWMCBaseMapMap = L.tileLayer(
    'http://a.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png',
    {
        attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
        id: 'isawnyu.map-knmctlkh'
        //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
    });
var AWMCRoadsMap = L.tileLayer(
    'http://a.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png',
    {
        attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
        id: 'isawnyu.awmc-roads'
        //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
    });


var imperiumMap = L.tileLayer('https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {
    attribution: 'Digital Atlas of the Roman Empire (DARE) project<a href="http://dare.ht.lu.se">http://dare.ht.lu.se</a> <a href="http://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>'
    //maxZoom: 0,
    //id: 'isawnyu.map-knmctlkh',
    //accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
});

var opentopomap = L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
    attribution: 'Kartendaten: © <a href="https://openstreetmap.org/copyright">OpenStreetMap</a>-Mitwirkende, SRTM | Kartendarstellung: © <a href="http://opentopomap.org">OpenTopoMap</a> (<a href="https://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA</a>)'
});


 mapLink =  '<a href="http://www.esri.com/">Esri</a>';
    wholink =  'i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community';
    var esriMap = L.tileLayer(
            'http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            attribution: '&copy; '+mapLink+', '+wholink,
            maxZoom: 18
            });



var markers = L.markerClusterGroup({ disableClusteringAtZoom: 7 });
var geojsonProject = new Object();
markerMap = {};
projectPlacesLayerCluster = L.markerClusterGroup({ disableClusteringAtZoom: 5 });
projectPlacesLayerCluster = L.geoJSON(false, { onEachFeature: onEachFeatureProjectCluster, pointToLayer: pointToLayerProjectPlace });

/* getProjectPlaces(geojsonProject, function (geojsonProject) {
    projectPlacesLayerCluster.addData(geojsonProject);
    projectPlacesLayerCluster.addData(geojsonProject);
}); */

/*
/*ADD base maps and layers*/
var baseMaps = {
    //"AWMC BaseMap": AWMCBaseMapMap,
    "MapBox satellite": satelliteMap,
    "OpenStreetMap": openStreetMap,
    "OpenTopoMap": opentopomap,
    "ESRI World Imagery": esriMap,
    "DARE": imperiumMap
};
var overlayMaps;
overlayMaps = {
    "Project places": projectPlacesLayerCluster,
    /*"Production units": productionUnitsMarkers,
    "Roman provinces 117AD": romanProvinces117, */
    "AWMC Roads": AWMCRoadsMap
    /*"Geonames": geonamesLayer,
    "AWMC Coastlines": AWMCCoastlinesMap,
    "Peripleo Result": peripleoSearchSelect,
    "edit":editableLayers*/
};

L.control.layers(baseMaps, overlayMaps
    , { position: 'topleft' }
).addTo(searchResultsMap);

L.control.scale().addTo(searchResultsMap);

searchResultsMap.addLayer(openStreetMap
        /* , projectPlacesLayerCluster, productionUnitsLayer */
        );
}

    function getProjectPlaces(geojson, callback) {
        /*     var url = "/geo/places/json";*/
        var url = "/exist/apps/estudium/geo/gazetteer/all";
        /*    var url = "/geo/production-units";*/
        /*var url = "/geo/project-places/" ;*/
        $.getJSON(url, function (json) {
            geojsonFeatureProject = json[0];
            callback(geojsonFeatureProject);
        });
    };

function onEachFeatureProjectCluster(feature, layer) {
    if (feature) {

        /*                    console.log("Feature: " + feature);*/
        // does this feature have a property named popupContent?
        if (feature.properties
            //&& feature.properties.popupContent
        ) {
            var placeType = "";
            var productionType = "";
            if (feature.properties.placeType) {
                placeType = " (" + feature.properties.placeType + ")";

            }
            if (feature.properties.productionType) {
                productionType =
                "<div>Production: " + feature.properties.productionType + "</div>"
            }

            var placeDetails =
                "<dl><dt><strong>" + feature.properties.name + "</strong>"
                + placeType + "</dt>"
                + '<dt><span class="uri">' + feature.properties.uri + "</span></dt>"
                + "<hr/>"
                
                // + "<hr/>" 
                //+ '<span class="spanLink" onclick="displayPlaceRecord(' + "'" + feature.properties.id +"'" +')">Read more...</span>'
                + "</dl>"




            if (feature.properties.uri != getCurrentPlaceUri()) { layer.bindPopup(placeDetails); }
            else {
                layer.bindPopup(placeDetails
                    /*                        feature.properties.popupContent.toString().replace("&lt;", "<").replace("&gt;", ">"*/
                    /*                        ) */

                );

            };
            var permanentToolip;
            if (feature.properties.uri === getCurrentPlaceUri()) {
                permanentToolip = true
            } else { permanentToolip = false }

            layer.bindTooltip(placeDetails,
                /*                         " " + feature.properties.popupContent, */
                {
                    permanent: false,
                    direction: 'top'
                }
            );

            layer.id = feature.properties.id;
            layer.uri = feature.properties.uri;


            /*/\*                        Icons*\/*/
            /*        var iconName = feature.properties.icon;
                    layer.setIcon(new placeIcon({ 
                       iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + iconName,
                     }));*/

            /*if (feature.properties.placeType == "province") {
              layer.setIcon(provinceIcon);
            }
            else if (feature.properties.placeType == "area") {
              layer.setIcon(areaIcon);
            }
            else if (feature.properties.placeType == "city") {
              layer.setIcon(wheatIcon);
            }
            else if (feature.properties.placeType == "administrative") {
              layer.setIcon(adminIcon);
            }
            else if (feature.properties.placeType == "Landed estate") {
              layer.setIcon(pigIcon);
            }
            else 
              layer.setIcon(defaultIcon);
            */
        }
        var label = String(feature.properties.name);
        var uri = String(feature.properties.uri);
        var id = uri.toString().substring(uri.toString().lastIndexOf("/") + 1);
        //bind click  to Fancytree

        layer.on('click', function (e) {
            // e = event
            console.log(id);
            //var sourceFromXql = "$ausohnum-lib/modules/spatiumStructor/getFunctions.xql?type=getPlaceHTML2&resource=" + encodeURIComponent(uri);
            if ($("#placeEditor").length) {
                var placeEditorType = $("#placeEditorType").text();
                $("#placeEditor").load("/" + placeEditorType + "/get-record/" + id);
                history.pushState(null, null, "/" + placeEditorType + "/" + id);
                document.title = placename + " - " + id;
            }
            else if ($("#mapPlaceRecord").length) {
                if ($("#placeRecordContainer").length) { $("#placeRecordContainer").removeClass("hidden"); };
                $("#mapPlaceRecord").html("")
                $("#loaderBig").show();
                $("#mapPlaceRecord").load("/places/get-place-record/" + id, function () { $("#loaderBig").hide(); });
                document.title = "APC Place " + " - " + id;
            }

            if ($("#collection-tree").length) {
                $("#collection-tree").fancytree("getTree").activateKey(id)
            }

            //    $("#collection-tree").fancytree("getTree").activateKey(uri);
            // layer.setIcon(new blueIcon);
            // this.setIcon(new redIcon);

            // console.log(this); 

        });
        layer.on("mouseover", function () {
            layer.openTooltip();
        });
        layer.on("mouseout", function () {
            //layer.closeTooltip();
        });

    }


};

function onEachFeatureSearchResults(feature, layer) {
if (feature){
    
    /* var listOfDocs = [];
    for (var docId in feature.properties.hits.docId) {
        listOfDocs.push('<a href="' + docId + '">' + docId[0] + '</a>');
    } */
    /* docIds = Array.from(feature.properties.hits.docId); */
    docIds = feature.properties.hits.docId;
    /* console.log(JSON.stringify(docIds)) */
    var listOfDocs = [];
    $(docIds).each(function (index, value) {
        
            listOfDocs.push('<li><a href="' + value + '">Doc. ' + value + '</a></li>');
        });
    /* listOfDocs = docIds.forEach(val => {
        return
        '<a href="' + val +'">' + val + '</a>'
    }); */

/*                    console.log("Feature: " + feature);*/
                    // does this feature have a property named popupContent?
                    if (feature.properties && feature.properties.popupContent) {
                        layer.bindPopup(
                         
                           "<dl><dt>" + feature.properties.name + " (" + feature.properties.placeType + ")</dt>"
                            + "<ol>"
                            + listOfDocs
                            + "</ol>"
                            + "</dl>"
                            
                            );
                        layer.bindTooltip( 
                         /* feature.properties.popupContent, */
                            "<dl><dt>" + feature.properties.name + " (zz" + feature.properties.placeType + ")</dt>"
                            + listOfDocs
                            + "</dl>",
                                           {
                                               permanent: false, 
                                               direction: 'right'
                                           }
                                       );

                        layer.id=feature.properties.id;
                        layer.urid=feature.properties.uri;
                        
                        
                                      
/*/\*                        Icons*\/*/
                       
/*                          layer.setIcon(greyIcon);*/
                      /*  var iconName = feature.properties.icon;
                            layer.setIcon(new placeIcon({ 
                               iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers-placetypes/" + iconName,
                             }));*/
                        
                 }
                     var label = String(feature.properties.name);
                     var uri = String(feature.properties.uri) + "#this";
                     
                                     
    }
    
                    
};

function pointToLayerProjectPlace(feature, latlng) {
    /*  let markerOptions ;*/
    /*  console.log(feature.properties.placeType);*/
    var markerpane = "";
    var placeType = feature.properties.placeType;
    switch (placeType) {
        case 'city': markerOptions = cityMarkerOptions; break;

        //Patrimoium
        case "Area":
        case 'Modern place':
        case 'Village/Settlement':


        case "Villa":
            markerOptions = modernPlaceMarkerOptions; break;
        case 'Patrimonial district':
            markerOptions = administrativeMarkerOptions; break;
        case 'Patrimonial supradistrict':
            markerOptions = supraDistrictMarkerOptions; break;
        case 'Landed estate':
        case 'estate':
        case 'Production units':
        case 'Forest':
        case "Quarry": markerOptions =
            productionUnitMarkerOptions;
            /*                                landedEstateCampMarkerOptions; */
            break;
        case 'Workshop': markerOptions = productionUnitMarkerOptions
            /*                                markerOptions = workshopCampMarkerOptions;*/
            break;
        case 'Mine': markerOptions = productionUnitMarkerOptions
            /*                                    mineCampMarkerOptions; */
            break;

        case 'Military camp/outpost':
        case "Station": markerOptions = militaryCampMarkerOptions; break;

        case 'Roman provinces':
        case 'Province':
        case "Italic region": markerOptions = provinceMarkerOptions;

            break;
        case "Egyptian nomos": markerOptions = nomosMarkerOptions; break;
        case "Ethnic region": markerOptions = ethnicRegionMarkerOptions; break;
        case 'untyped place': markerOptions = untypedPlaceOptions; break;
        default: markerOptions = archaeoFeatureMarkerOptions; break;
    }
    var newLatLng = [];
    if (feature.geometry.coordinates.length > 1) {
        var lngLat = feature.geometry.coordinates;
        lngLat.forEach(function (e) {
            array = [e[1], e[0]]
            newLatLng.push(array);
        }
        );
        /*            console.log(lngLat);*/
        /*            console.log(newLatLng);*/
        var bounds = new L.LatLngBounds(newLatLng);
        var boundCenter = bounds.getCenter();
        /*            console.log(feature.properties.id + " latLng = " + latlng + "Coordinates: "+ feature.geometry.coordinates + " ==> center: " + boundCenter);*/



        //Marker: circle or square?
        switch (feature.properties.placeType) {
            case "dministrative district"://typo on purpose to disable feature
                var marker = new L.rectangle([newLatLng, newLatLng], {
                    fillColor: "blue",
                    weight: 1,

                    fillOpacity: 0.1
                });
                break;
            default:
                var marker = new L.circleMarker(boundCenter, markerOptions);
                break;
        };

        var productionType = "";
        if (feature.properties.placeType) { placeType = " (" + feature.properties.placeType + ")" }
        if (feature.properties.productionType) {
            productionType =
            "<div>Production: " + feature.properties.productionType + "</div>"
        }

        var placeDetails =
            "<dl><dt><strong>" + feature.properties.name + "</strong>"
            + placeType + "</dt>"
            + '<dt><span class="uri">' + feature.properties.uri + "</span></dt>"
            + "<hr/>"
            + productionType
            // + "<hr/>" 
            //+ '<span class="spanLink" onclick="displayPlaceRecord(' + "'" + feature.properties.id +"'" +')">Read more...</span>'
            + "</dl>"

        marker = marker.bindPopup(placeDetails, { keepInView: true, closeButton: true, autoClose: false, autoPan: true, closeOnClick: false })
        /* marker = marker.bindTooltip(placeDetails, { permanent: false, direction: 'top' }) */
        markerMap[feature.properties.uri] = marker;

        return marker;
    }
    else {
        /*        console.log("NO: " +feature.properties.id + " " + latlng);*/


        var marker = new L.circleMarker(latlng, markerOptions);
    }
    if (feature.properties.id.toString() == getCurrentPlaceUri()) {
        //          console.log("Current: " +  getCurrentPlaceUri());
        marker.openPopup()
    };

    var productionType = "";
    if (feature.properties.placeType) { placeType = " (" + feature.properties.placeType + ")" }
    if (feature.properties.productionType) {
        productionType =
        "<div>Production: " + feature.properties.productionType + "</div>"
    }

    var placeDetails =
        "<dl><dt><strong>" + feature.properties.name + "</strong>"
        + placeType + "</dt>"
        + '<dt><span class="uri">' + feature.properties.uri + "</span></dt>"
        + "<hr/>"
        + productionType
        // + "<hr/>" 
        //+ '<span class="spanLink" onclick="displayPlaceRecord(' + "'" + feature.properties.id +"'" +')">Read more...</span>'
        + "</dl>"


    marker = marker.bindPopup(placeDetails)
    /* marker = marker.bindTooltip(placeDetails, { permanent: false, direction: 'top' }) */
    markerMap[feature.properties.uri] = marker;
    return marker;



};