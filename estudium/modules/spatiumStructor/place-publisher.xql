xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";


import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/commonsApp.xql";

import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/spatiumStructor/spatiumStructor.xql";

import module namespace placeRecordGenerator ="http://ausonius.huma-num.fr/placeRecordGenerator"
      at "./placeRecordGenerator.xql";

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

let $origin:= request:get-parameter("origin", "")
(:let $placeNumber := count($spatiumStructor:project-place-collection//pleiades:Place):)
let $placeId := request:get-parameter("resource", "")
let $placeUriShort := $spatiumStructor:uriBase || "/places/" || $placeId
let $placeUri := $spatiumStructor:uriBase || "/places/" || $placeId || "#this"

let $gazetteerRecord := $spatiumStructor:placeGazetteer//features[.//uri = normalize-space($placeUriShort)]
let $coordinates := $gazetteerRecord//coordList/coordinates[1]/text()
let $moveToPlaceScript := "$(document).ready( function () {{
                //var markerCoordinates = markerMap['" || $placeUriShort || "'].getLatLng();
                console.log('coordinates: ' + " || $coordinates || ");
                editorMap.flyTo(" || $coordinates ||", 12);
               
                    }});"
let $updateTitleWindow :=
                        if ($placeId != "") then '$(document).ready( function () {{
                document.title = "' || $gazetteerRecord//name/text() || '" + " - " + "' || $placeId || '";
                    }});' 
                    else '$(document).ready( function () {{
                document.title = "' || "APC Places" || '";
                    }});'
return
switch($origin)
case "call" return 
placeRecordGenerator:recordForDisplay($placeUriShort)

case "controller"
return
 <div data-template="templates:surround" data-template-with="templates/page-apc.html" data-template-at="content">
    <div class="container">
        <div class="row" data-template="app:navBar"/>
        
               <div class="row">
                    <div id="placeRecord" class="col-xs-7 col-sm-7 col-md-7">
                    { placeRecordGenerator:recordForDisplay($placeUriShort) }</div>
                    <!--<div id="editorMap" class="col-xs-5 col-sm-5 col-md-5"></div>
                    <div id="currentPlaceCoordinates" class="hidden">{ $coordinates }</div>-->
                </div>
                <!--<div id="positionInfo"/>
                <div id="savedPositionInfo">Click to store current position: </div>
                -->
        
            <script>$("#datanavbar-places").addClass("active");</script>
        </div>
        <!-- Make sure you put this AFTER Leaflet's CSS -->
<!--        <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"
   integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg=="
   crossorigin=""/>
-->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" integrity="sha512-07I2e+7D8p6he1SIM+1twR5TIrhUQn9+I6yjqD53JQjFiMf8EtC93ty0/5vJTZGF8aAocvHYNEDJajGdNx1IsQ==" crossorigin="" />

<script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet-src.js" integrity="sha512-WXoSHqw/t26DszhdMhOXOkI7qCiv5QWXhH9R7CgvgZMHz1ImlkVQ3uNsiQKu5wwbbxtPzFXd1hK4tzno2VqhpA==" crossorigin=""></script>

  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-providers.js"></script>
   <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.css"/>

<link href='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/leaflet.fullscreen.css' rel='stylesheet' />
        <script src='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/Leaflet.fullscreen.min.js'></script>
  
<!--Markercluster -->
<!-- 
<link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markercluster/MarkerCluster.css"/>
<link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markercluster/MarkerCluster.Default.css"/>
--> 

  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.js"></script>
  <!--  Leaflet Draw  -->

 
<!--Markercluster -->
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.css" />
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.Default.css" />
<script src="https://leaflet.github.io/Leaflet.markercluster/dist/leaflet.markercluster-src.js"></script>
<script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.featuregroup.subgroup.js"></script>
<!--
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.3.0/dist/MarkerCluster.css"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.3.0/dist/MarkerCluster.Default.css"/>
 <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.markercluster/leaflet.markercluster.js"></script>
-->
 
 <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/L.Control.Geonames.min.js"/>

        <!--<link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>-->
        
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
        
        <link href="$ausohnum-lib/resources/css/ausohnumCommons.css" rel="stylesheet" type="text/css"/>
        <script type="text/javascript">{ $updateTitleWindow }
          
        </script>

    <script>
    $("#logoForMenu").removeClass("hidden");
        if($("#apcMenu").hasClass("active")){{}} else{{$("#apcMenu").addClass("active");}}
    $("#datanavbar-places").addClass("active");
    </script>
 </div>
 
 default return
 <div data-template="templates:surround" data-template-with="templates/page-apc.html" data-template-at="content">
    <div class="container">
        <div class="row" data-template="app:navBar"/>
        <div class="container">
               <div class="row">
                    <div id="placeRecord" class="col-xs-7 col-sm-7 col-md-7">
                    { placeRecordGenerator:recordForDisplay($placeUriShort) }</div>
                    <div id="mapHolder" class="col-xs-5 col-sm-5 col-md-5 rightSideBorder">
                    <div id="editorMap"></div>
                    </div>
                </div>
                <!--<div id="positionInfo"/>
                <div id="savedPositionInfo">Click to store current position: </div>
                -->
        
        </div>
        </div>
        <!-- Make sure you put this AFTER Leaflet's CSS -->
<!--        <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"
   integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg=="
   crossorigin=""/>
-->
    <script>
    $("#logoForMenu").removeClass("hidden");
        if($("#apcMenu").hasClass("active")){{}} else{{$("#apcMenu").addClass("active");}}
    $("#datanavbar-places").addClass("active");
    </script>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" integrity="sha512-07I2e+7D8p6he1SIM+1twR5TIrhUQn9+I6yjqD53JQjFiMf8EtC93ty0/5vJTZGF8aAocvHYNEDJajGdNx1IsQ==" crossorigin="" />

<script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet-src.js" integrity="sha512-WXoSHqw/t26DszhdMhOXOkI7qCiv5QWXhH9R7CgvgZMHz1ImlkVQ3uNsiQKu5wwbbxtPzFXd1hK4tzno2VqhpA==" crossorigin=""></script>

  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-providers.js"></script>
   <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.css"/>

<link href='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/leaflet.fullscreen.css' rel='stylesheet' />
        <script src='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/Leaflet.fullscreen.min.js'></script>
  
<!--Markercluster -->
<!-- 
<link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markercluster/MarkerCluster.css"/>
<link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markercluster/MarkerCluster.Default.css"/>
--> 

  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.js"></script>
  <!--  Leaflet Draw  -->

 
<!--Markercluster -->
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.css" />
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.Default.css" />
<script src="https://leaflet.github.io/Leaflet.markercluster/dist/leaflet.markercluster-src.js"></script>
<script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.featuregroup.subgroup.js"></script>
<!--
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.3.0/dist/MarkerCluster.css"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.3.0/dist/MarkerCluster.Default.css"/>
 <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.markercluster/leaflet.markercluster.js"></script>
-->
 
 <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/L.Control.Geonames.min.js"/>

        <!--<link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>-->
<script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructorFunctions.js"/>        
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
        
        <link href="$ausohnum-lib/resources/css/ausohnumCommons.css" rel="stylesheet" type="text/css"/>
        <script type="text/javascript">{ $updateTitleWindow }
          
        </script>


 </div>