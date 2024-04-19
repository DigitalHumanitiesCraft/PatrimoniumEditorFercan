xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";

import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/commonsApp.xql";

import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0/functx/functx.xql";

import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/spatiumStructor/spatiumStructor.xql";


declare namespace apc = "https://ausohnum.huma-num.fr/apps/eStudium/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace local = "local";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace foaf = "http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace spatial="http://geovocab.org/spatial#";

let $placeNumber := count($spatiumStructor:project-place-collection//pleiades:Place)
let $placeId := request:get-parameter("resource", "")
let $placeUriShort := $spatiumStructor:uriBase || "/places/" || $placeId
let $placeUri := $spatiumStructor:uriBase || "/places/" || $placeId || "#this"

let $place := $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about= $placeUri]


let $moveToPlaceScript := "$(document).ready( function () {{
                var markerCoordinates = markerMap['" || $placeUriShort || "'].getLatLng();
                console.log('lat: ' + markerCoordinates.lat);
                displayMap.flyTo([markerCoordinates.lat, markerCoordinates.lng], 12);
               
                    }});"
let $updateTitleWindow :=
                        if ($placeId != "") then '$(document).ready( function () {{
                document.title = "' || $place//pleiades:Place/dcterms:title[1]/text() || '" + " - " + "' || $placeId || '";
                    }});' 
                    else '$(document).ready( function () {{
                document.title = "' || "APC Places" || '";
                    }});'
return

 <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
    <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.css" />
    <script src="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.js"></script>

 <!--Script for fancytree-->
        <div id="spatiumStructor" class="">
            <div class="row">
                <div class="col-xs5 col-sm-5 col-md-5">
                            <div class="col-xs-4 col-sm-4 col-md-4" style="font-size: smaller;">
                                <button class="btn btn-sm btn-primary" onclick="openNewPlaceForm()">Create a new place</button>
                                    { spatiumStructor:listPlacesAsTable() }
                            </div>
                            <div class="col-xs-8 col-sm-8 col-md-8">
                <!--<input name="searchTree" id="searchTree" placeholder="Filter { $placeNumber } places" title="Filter places" autocomplete="off"/>
                <button id="btnResetSearch" class="btn btn-default" title="Clear filter">
                                    <i class="glyphicon glyphicon-remove-sign"/>
                             </button>
                   -->
                   </div>
                   <div class="row">
                   
                        <div id="editLocationButton" class="btn btn-primary editbutton hidden"
                      
                             appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                       editConceptIcon"></i></div>
                        <div id="placeEditor" class="col-xs-7 col-sm-7 col-md-7">
                        
                        { if($placeId ="") then (
                        <div>
                        <h1 class="display-4">Welcome to the Places Manager</h1>
                        <p>Total of places: {$placeNumber}</p>
                        </div>)
                        else if($placeId ="new") then
                        spatiumStructor:newPlaceForm()
                        else spatiumStructor:getPlaceHTML2( $placeId)}</div>
                    </div>
                </div>
                <div class="col-xs-7 col-sm-7 col-md-7">

            <div id="placeManagerMap" ></div>
            <div id="positionInfo"/>
            <div id="savedPositionInfo">Click to store current position: </div>

{ spatiumStructor:searchPeripleoModal() }
{ spatiumStructor:searchProjectPlacesModal() }
{ spatiumStructor:addResourceDialog("seeFurther") }

</div>
            </div><!--End of row-->
<!--    <div id="mapid"></div>-->
            </div>



 <!--       <link rel="stylesheet" href="https://unpkg.com/leaflet@1.4.0/dist/leaflet.css"
            integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA=="
            crossorigin=""/>
            -->
        <!-- Make sure you put this AFTER Leaflet's CSS -->
<!--        <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"
   integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg=="
   crossorigin=""/>
-->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" integrity="sha512-07I2e+7D8p6he1SIM+1twR5TIrhUQn9+I6yjqD53JQjFiMf8EtC93ty0/5vJTZGF8aAocvHYNEDJajGdNx1IsQ==" crossorigin="" />

<script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet-src.js" integrity="sha512-WXoSHqw/t26DszhdMhOXOkI7qCiv5QWXhH9R7CgvgZMHz1ImlkVQ3uNsiQKu5wwbbxtPzFXd1hK4tzno2VqhpA==" crossorigin=""></script>

  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-providers.js"></script>
   <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.css"/>

<!--Markercluster -->
<!-- 
<link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markercluster/MarkerCluster.css"/>
<link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markercluster/MarkerCluster.Default.css"/>
--> 

  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.js"></script>
  <!--  Leaflet Draw  -->

 <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.draw/leaflet.draw.css"/>
<!--Markercluster -->
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.css" />
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.Default.css" />
<script src="https://leaflet.github.io/Leaflet.markercluster/dist/leaflet.markercluster-src.js"></script>

<!--
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.3.0/dist/MarkerCluster.css"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.3.0/dist/MarkerCluster.Default.css"/>
 <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.markercluster/leaflet.markercluster.js"></script>
-->

 <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/Leaflet.draw.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/Leaflet.Draw.Event.js"></script>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/Toolbar.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/Tooltip.js"></script>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/GeometryUtil.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/LatLngUtil.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/LineUtil.Intersect.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/Polygon.Intersect.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/Polyline.Intersect.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/ext/TouchEvents.js"></script>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/DrawToolbar.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Feature.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.SimpleShape.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Polyline.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Marker.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Circle.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.CircleMarker.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Polygon.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/draw/handler/Draw.Rectangle.js"></script>


    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/EditToolbar.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/EditToolbar.Edit.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/EditToolbar.Delete.js"></script>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/Control.Draw.js"></script>

    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.Poly.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.SimpleShape.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.Rectangle.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.Marker.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.CircleMarker.js"></script>
    <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.draw/edit/handler/Edit.Circle.js"></script>

 
 <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/L.Control.Geonames.min.js"/>

        <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
        
        <script type="text/javascript">{ $updateTitleWindow }
                
        </script>


 </div>
