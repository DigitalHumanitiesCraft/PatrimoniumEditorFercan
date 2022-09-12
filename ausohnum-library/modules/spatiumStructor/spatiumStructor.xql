(:~
: AusoHNum Library - spatial data manager module
: This module contains the main functions of the spatial data manager module.
: @author Vincent Razanajao
:)

xquery version "3.1";


module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor";

import module namespace config="http://ausonius.huma-num.fr/ausohnum-library/config" at "../config.xqm";

import module namespace dbutil="http://exist-db.org/xquery/dbutil" at "/db/apps/shared-resources/content/dbutils.xql";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor" at "../teiEditor/teiEditorApp.xql";

import module namespace functx="http://www.functx.com";

import module namespace http="http://expath.org/ns/http-client";

(:import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";:)

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
(:import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";:)
import module namespace zoteroPlugin="http://ausonius.huma-num.fr/zoteroPlugin" at "../zoteroPlugin/zoteroPlugin.xql";
(:import module namespace tan="http://alpheios.net/namespaces/text-analysis" at "./cts-3/textanalysis_utils.xquery";:)
(:import module namespace templates="http://exist-db.org/xquery/templates" ;:)
(:import module namespace config="http://patrimonium.huma-num.fr/config" at "../config.xqm";:)


declare boundary-space preserve;

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace ausohnum= "http://ausonius.huma-num.fr/onto";
declare namespace bib="http://purl.org/net/biblio#";
declare namespace bibo="http://purl.org/ontology/bibo/";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace cito="http://purl.org/spar/cito/";
declare namespace err = "http://www.w3.org/2005/xqt-errors";
declare namespace foaf="http://xmlns.com/foaf/0.1/";

declare namespace json="http://www.json.org";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace prism="http://prismstandard.org/namespaces/basic/2.0/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace spatium="http://ausonius.huma-num.fr/spatium-ontoology";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace prov="http://www.w3.org/TR/prov-o/#";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace z = "http://www.zotero.org/namespaces/export#";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:indent "yes";
declare option output:method 'adaptive';
(:declare option output:item-separator "&#xa;";:)

declare variable $spatiumStructor:library-path := "/db/apps/ausohnum-library/";
declare variable $spatiumStructor:project :=request:get-parameter('project', ());
declare variable $spatiumStructor:appVariables := doc("/db/apps/" || $spatiumStructor:project || "/data/app-general-parameters.xml");
declare variable $spatiumStructor:uriBase := $spatiumStructor:appVariables//uriBase[@type="app"]/text();
declare variable $spatiumStructor:data := request:get-data();
declare variable $spatiumStructor:docId :=  request:get-parameter('docid', ());
declare variable $spatiumStructor:placeId :=  request:get-parameter('placeid', ());
declare variable $spatiumStructor:placeURI :=  request:get-parameter('placeuri', ());
declare variable $spatiumStructor:lang :=request:get-parameter('lang', "en");
declare variable $spatiumStructor:languages := $spatiumStructor:appVariables//languages;

declare variable $spatiumStructor:editorLabels := doc($spatiumStructor:library-path || "data/teiEditor/teiEditorLabels.xml");
(:declare variable $spatiumStructor:project := "patrimonium";:)
declare variable $spatiumStructor:data-collection-path := "/db/apps/" || $spatiumStructor:project || "Data";
declare variable $spatiumStructor:data-collection := collection($spatiumStructor:data-collection-path);
declare variable $spatiumStructor:place-collection :=collection($spatiumStructor:data-collection-path|| "/places");
declare variable $spatiumStructor:project-place-collection := collection("/db/apps/" || $spatiumStructor:project || "Data/places/" || $spatiumStructor:project );
declare variable $spatiumStructor:placeGazetteer := doc("/db/apps/" || $spatiumStructor:project || "Data/places/project-places-gazetteer.xml");
declare variable $spatiumStructor:doc-collection-path := $spatiumStructor:data-collection-path || "/documents";
declare variable $spatiumStructor:doc-collection:= collection($spatiumStructor:data-collection-path || "/documents");
declare variable $spatiumStructor:place-collection-path-root := $spatiumStructor:data-collection-path || "/places/" ;
declare variable $spatiumStructor:project-place-collection-path := $spatiumStructor:data-collection-path || "/places/" || $spatiumStructor:project ;
declare variable $spatiumStructor:currentPlace := $spatiumStructor:project-place-collection//spatial:feature[@rdf:about = $spatiumStructor:uriBase || $spatiumStructor:docId || "#this"];


declare variable $spatiumStructor:concept-collection-path := "/db/data/" || $spatiumStructor:appVariables//thesaurus-app/text() || "/concepts";

declare variable $spatiumStructor:biblioRepo := doc($spatiumStructor:data-collection-path || "/biblio/biblio.xml");
declare variable $spatiumStructor:resourceRepo := collection($spatiumStructor:data-collection-path || "/resources");
declare variable $spatiumStructor:peopleRepo := doc($spatiumStructor:data-collection-path || "/people/people.xml");
declare variable $spatiumStructor:peopleCollection:= collection($spatiumStructor:data-collection-path || "/people");

declare variable $spatiumStructor:placeCollection := collection($spatiumStructor:data-collection-path || "/places");
declare variable $spatiumStructor:placeRepo := doc($spatiumStructor:data-collection-path || "/places/listOfPlaces.xml");
declare variable $spatiumStructor:romanProvincesDoc := doc($spatiumStructor:place-collection-path-root || "/roman-provinces.rdf");

declare variable $spatiumStructor:baseUri := $spatiumStructor:appVariables//uriBase[@type='app']/text();


declare variable $spatiumStructor:placeElements := doc($spatiumStructor:library-path || 'data/spatiumStructor/placeElements.xml');
declare variable $spatiumStructor:placeElementsCustom := doc("/db/apps/" || $spatiumStructor:project || '/data/spatiumStructor/placeElements.xml');
declare variable $spatiumStructor:docTemplates := collection($spatiumStructor:library-path || 'data/teiEditor/docTemplates');
declare variable $spatiumStructor:teiTemplate := doc($spatiumStructor:library-path || 'data/teiEditor/teiTemplate.xml');
declare variable $spatiumStructor:externalResources := doc($spatiumStructor:library-path || 'data/teiEditor/externalResources.xml');
declare variable $spatiumStructor:teiElements := doc($spatiumStructor:library-path || 'data/teiEditor/teiElements.xml');
declare variable $spatiumStructor:teiElementsCustom := doc("/db/apps/" || $teiEditor:project || '/data/teiEditor/teiElements.xml');

declare variable $spatiumStructor:teiDoc := $spatiumStructor:place-collection/id($spatiumStructor:docId) ;
declare variable $spatiumStructor:docTitle :=  $spatiumStructor:teiDoc//tei:fileDesc/tei:titleStmt/tei:title/text() ;

declare variable $spatiumStructor:logs := collection($spatiumStructor:data-collection-path || '/logs');
declare variable $spatiumStructor:now := fn:current-dateTime();
declare variable $spatiumStructor:currentUser := data(sm:id()//sm:username);
declare variable $spatiumStructor:currentUserUri := concat($spatiumStructor:baseUri, '/people/' , data(sm:id()//sm:username));
declare variable $spatiumStructor:zoteroGroup :=request:get-parameter('zoteroGroup', ());

declare variable $spatiumStructor:productionUnitTypes := skosThesau:getChildren($spatiumStructor:appVariables//productionUnitsUri/text(), $spatiumStructor:project);
declare variable $spatiumStructor:newLine := '&#xa;';
declare
    %templates:wrap
    function spatiumStructor:version($node as node(), $model as map(*)){
    data( $config:expath-descriptor//@version)

};
declare
    %templates:wrap
    function spatiumStructor:variables($resourceId as xs:string, $project as xs:string){
    <div class="hidden">
        <div id="currentResourceId">{ $resourceId }</div>
        <div id="currentProject">{ $project } </div>
    </div>

};


declare function spatiumStructor:processUrl($path as xs:string,
                                                                      $resource as xs:string,
                                                                      $project as xs:string,
                                                                      $format as xs:string?
                                                                      ){

   if ($path = "/geo/admin") then spatiumStructor:dashboard()
   else if (starts-with($path, "/geo/places")) then spatiumStructor:getProjectPlaces($format)
   else if (starts-with($path, "/geo/document/")) then spatiumStructor:getDocumentPlaces($resource)
   else if (starts-with($path, "/geo/project-places/")) then spatiumStructor:getDocument2Places($resource)


  else <bold>{ $resource } + { $path }</bold>
};

declare function spatiumStructor:dashboard(){
 <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">

       <div id="spatiumStructor" class="">
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-md-12">
                     <div id="mapid"></div>

                </div>
            </div>
            </div>

        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
        <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>

        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.4.0/dist/leaflet.css"
            integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA=="
            crossorigin=""/>
        <!-- Make sure you put this AFTER Leaflet's CSS -->
        <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"
   integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg=="
   crossorigin=""></script>
 <script>


console.log("dd" + geojsonFeature);
 var mymap = L.map('mapid').setView([41.891775, 12.486137], 4);


L.tileLayer('https://api.tiles.mapbox.com/v4/{{id}}/{{z}}/{{x}}/{{y}}.png?access_token=pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ', {{
 attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
 maxZoom: 10,
 id: 'isawnyu.map-knmctlkh',
 accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
 }}).addTo(mymap);

 var geojsonFeature;
$.getJSON("/geo/places/json", function(json){{
    geojsonFeature = json;
    L.geoJSON(geojsonFeature).addTo(mymap);
}});
 console.log("zgeojsonFeature" + geojsonFeature);



 </script>
 </div>



};

declare function spatiumStructor:placesManager(){

let $placeNumber := count($spatiumStructor:project-place-collection//pleiades:Place)
return

 <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
 <!--Script for fancytree-->
        <!-- Include Fancytree skin and library -->
        <link href="$ausohnum-lib/resources/scripts/jquery/fancytree/skin-bootstrap/ui.fancytree.css" rel="stylesheet" type="text/css"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree-all.min.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.filter.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.glyph.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.wide.js" type="text/javascript"/>
       <div id="spatiumStructor" class="">
            <div class="row">
                <div class="col-xs-7 col-sm-7 col-md-7">
                <input name="searchTree" id="searchTree" placeholder="Filter { $placeNumber } places" title="Filter places" autocomplete="off"/>
                <button id="btnResetSearch" class="btn btn-default" title="Clear filter">
                                    <i class="glyphicon glyphicon-remove-sign"/>
                             </button>
                    <div class="row">
                        
                        <div id="collection-tree" class="col-xs-5 col-sm-5 col-md-5" data-type="json"/>
                        <div id="editLocationButton" class="btn btn-primary editbutton hidden"
                      
                             appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                       editConceptIcon"></i>BIS</div>
                        <div id="placeEditor" class="col-xs-7 col-sm-7 col-md-7"></div>
                    </div>
                </div>
                <div class="col-xs-5 col-sm-5 col-md-5">

            <div id="placeManagerMap" ></div>

{ spatiumStructor:searchPeripleoModal() }
{ spatiumStructor:searchProjectPlacesModal() }


</div>
            </div><!--End of row-->
<!--    <div id="mapid"></div>-->
            </div>



        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.4.0/dist/leaflet.css"
            integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA=="
            crossorigin=""/>
        <!-- Make sure you put this AFTER Leaflet's CSS -->
        <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"
   integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg=="
   crossorigin=""/>

  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-providers.js"></script>
   <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.css"/>

  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.js"></script>
  <!--  Leaflet Draw  -->
      <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.draw/leaflet.draw.css"/>


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
        
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/placeTree.js"/>




 </div>
 };
 
 
 declare function spatiumStructor:placesManager2(){


let $placeNumber := count($spatiumStructor:project-place-collection//pleiades:Place)
let $placeId := request:get-parameter("resource", "")
let $placeUriShort := $spatiumStructor:uriBase || "/places/" || $placeId
let $placeUri := $spatiumStructor:uriBase || "/places/" || $placeId || "#this"

let $place := $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about= $placeUri]
let $productionUnitTypes := skosThesau:getChildren($spatiumStructor:appVariables//productionUnitsUri/text(), $spatiumStructor:project)
let $productionUnits:= $spatiumStructor:project-place-collection//pleiades:Place[pleiades:hasFeatureType[@type="main"][not(./@rdf:resource = "") and (contains((string-join($productionUnitTypes//skos:Concept/@rdf:about, ",")), ./@rdf:resource))]]
let $gazetteerRecord := $spatiumStructor:placeGazetteer//features[.//uri = normalize-space($placeUriShort)]
let $coordinates := $gazetteerRecord//coordList[1]/coordinates[1]/string()


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
<link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/MarkerCluster.css" />
        <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/MarkerCluster.Default.css" />
        <script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.markerCluster1.4.1/leaflet.markercluster.js"></script>
        
<!--
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.css" />
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.Default.css" />
<script src="https://leaflet.github.io/Leaflet.markercluster/dist/leaflet.markercluster-src.js"></script>
-->
<script src="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.featuregroup.subgroup.js"></script>
<!--
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.3.0/dist/MarkerCluster.css"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.3.0/dist/MarkerCluster.Default.css"/>
 <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.markercluster/leaflet.markercluster.js"></script>
-->
    <script src="https://unpkg.com/shpjs@latest/dist/shp.js"/>
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
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.11.0/underscore-min.js"/>
        
    <div id="placeEditorType" class="hidden">placesManager</div>
 <!--Script for fancytree-->
        <div id="spatiumStructor" class="">
            <div class="row">
                <div class="col-xs7 col-sm-7 col-md-7">
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
                        <div id="currentPlaceCoordinates" class="hidden">{ $coordinates }</div>
                        
                        { if($placeId ="") then (
                        <div>
                        <h1 class="display-4">Welcome to the Places Manager</h1>
                        <p>Total of places: {$placeNumber}</p>
                        <p>Including Production Units: { count($productionUnits) }</p>
                        </div>)
                        else if($placeId ="new") then
                        spatiumStructor:newPlaceForm()
                        else spatiumStructor:getPlaceHTML2( $placeId)}</div>
                    </div>
                </div>
                <div class="col-xs-5 col-sm-5 col-md-5">

            <div id="placeManagerMap" ></div>
            <div id="positionInfo"/>
            <div id="savedPositionInfo">Click to store current position: </div>

{ spatiumStructor:searchPleiadesModal() }
{ spatiumStructor:searchProjectPlacesModal() }
{ spatiumStructor:addResourceDialog("seeFurther") }

</div>
            </div><!--End of row-->
<!--    <div id="mapid"></div>-->
        <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>
        <script type="text/javascript" src="/resources/scripts/spatiumStructor.js"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructorFunctions.js"/>        </div>
        <script type="text/javascript">{ $updateTitleWindow }</script>


 </div>
 };


declare function spatiumStructor:archaeoManager(){


 <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
 <!--Script for fancytree-->
        <!-- Include Fancytree skin and library -->
        <link href="$ausohnum-lib/resources/scripts/jquery/fancytree/skin-bootstrap/ui.fancytree.css" rel="stylesheet" type="text/css"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree-all.min.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.filter.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.glyph.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.wide.js" type="text/javascript"/>
       <div id="spatiumStructor" class="">
            <div class="row">
                <div class="col-xs-7 col-sm-7 col-md-7">
                <input name="searchTree" id="searchTree" placeholder="Filter places" title="Filter places" autocomplete="off"/>
                <button id="btnResetSearch" class="btn btn-default" title="Clear filter">
                                    <i class="glyphicon glyphicon-remove-sign"/>
                             </button>
                    <div class="row">
                        
                        <div id="collection-tree" class="col-xs-5 col-sm-5 col-md-5" data-type="json"/>
                        <div id="editLocationButton" class="btn btn-primary editbutton hidden"
                      
                             appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                       editConceptIcon"></i>BIS</div>
                        <div id="placeEditor" class="col-xs-7 col-sm-7 col-md-7"></div>
                    </div>
                </div>
                <div class="col-xs-5 col-sm-5 col-md-5">

            <div id="placeManagerMap" ></div>

{ spatiumStructor:searchPeripleoModal()}
{ spatiumStructor:searchProjectPlacesModal()}
{ spatiumStructor:newSubPlaceModal()}

</div>
            </div><!--End of row-->
<!--    <div id="mapid"></div>-->
            </div>



        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.4.0/dist/leaflet.css"
            integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA=="
            crossorigin=""/>
        <!-- Make sure you put this AFTER Leaflet's CSS -->
        <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"
   integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg=="
   crossorigin=""/>

  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-providers.js"></script>
   <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.css"/>

  <script src="$ausohnum-lib/resources/scripts/spatiumStructor/leaflet-search/src/leaflet-search.js"></script>
  <!--Markercluster -->
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.css" />
<link rel="stylesheet" href="https://leaflet.github.io/Leaflet.markercluster/dist/MarkerCluster.Default.css" />
<script src="https://leaflet.github.io/Leaflet.markercluster/dist/leaflet.markercluster-src.js"></script>

  <!--  Leaflet Draw  -->
      <link rel="stylesheet" href="$ausohnum-lib-dev/resources/scripts/spatiumStructor/leaflet.draw/leaflet.draw.css"/>


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
        
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/archaeoTree.js"/>




 </div>
 };

declare function spatiumStructor:map(){


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
                <div class="col-xs-12 col-sm-12 col-md-12">
                
            <div id="atlasMap" ></div>
            <div id="mapPlaceRecord"></div>            

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


<link href='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/leaflet.fullscreen.css' rel='stylesheet' />
        <script src='$ausohnum-lib/resources/scripts/spatiumStructor/leaflet.fullscreen/Leaflet.fullscreen.min.js'></script>

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
 };


 declare function spatiumStructor:getRomanProvinces(){
    let $romanProvincesDoc := doc($spatiumStructor:place-collection-path-root || "/roman-provinces.rdf")
    let $romanProvinces := $romanProvincesDoc//spatial:Feature

    return $romanProvinces
 };


 declare function spatiumStructor:buildPlaceTree(){
 let $rootDoc := doc($spatiumStructor:project-place-collection-path || "/_root.rdf")
 let $places-collection := collection($spatiumStructor:project-place-collection-path )
 let $rootPlaces := $rootDoc//spatial:Pi
 let $rootNodesFromRootFile :=
        for $place in $rootPlaces
        let $placeUri := $place/@rdf:resource || "#this"
        return
        $places-collection//spatial:Feature[@rdf:about=$placeUri]
 let $romanProvinces := spatiumStructor:getRomanProvinces()
 let $rootNodes :=
         $places-collection//spatial:Feature

(: for $child in $children:)
 return

        serialize(
        <children xmlns:json="http://www.json.org" json:array="true">
         <title>Places</title>
         <id>home</id>
         <key>home</key>
         <lng>{ data($rootDoc//pleiades:Place/geo:long/text()) }</lng>
         <lat>{ data($rootDoc//pleiades:Place/geo:lat/text()) }</lat>
          <isFolder>true</isFolder>
         <orderedCollection json:literal="true">true</orderedCollection>
         <lang></lang>
                        <children xmlns:json="http://www.json.org" json:array="true">
                         <title>Create a new place</title>
                         <id>new</id>
                         <key>new</key>
                         <lng></lng>
                         <lat></lat>
                          <isFolder>false</isFolder>
                         <lang></lang>
                         
                       </children>
                       <children xmlns:json="http://www.json.org" json:array="true">
                         <title>By Alphabetical Order</title>
                         <!--
                         <id>{data($rootDoc/@rdf:about)}</id>
                         <key>{data($rootDoc/@rdf:about)}</key>
                         <lng>{ data($rootDoc//pleiades:Place/geo:long/text()) }</lng>
                         <lat>{ data($rootDoc//pleiades:Place/geo:lat/text()) }</lat>
                         -->
                          <isFolder>true</isFolder>
                         <orderedCollection json:literal="true">true</orderedCollection>
                         <lang></lang>
                                    { spatiumStructor:buildPlaceTree($rootNodes, "en")}
                       </children>

    </children>
        ,
            <output:serialization-parameters>
                <output:method>json</output:method>
            </output:serialization-parameters>
        )

 };

 declare function spatiumStructor:buildPlaceTree($rootNodes, $lang){
                let $collation :=  '?lang=' || lower-case($lang) || "-" || $lang

                for $child in $rootNodes
                let $placeConcept := $child//pleiades:Place
                let $nts := $child//spatial:Pi
                let $order := data($child/@type)
                order by
                      lower-case($child/foaf:primaryTopicOf/pleiades:Place/dcterms:title) collation "?lang=en"

              return

              <children json:array="true" status="{data($child//@status)}" type="collectionItem">
                 <title>{ if($child//pleiades:Place[1]//dcterms:title/text()) then
                            functx:capitalize-first($child//pleiades:Place/dcterms:title/text()) || " [" || substring-before(substring-after($child/@rdf:about, "places/"), "#this") || "]"
                          else ("No label for " || data($child/@rdf:about))

                 }</title>

                 <uri>{ data($child/@rdf:about) }</uri>
                 <key>{ substring-before(substring-after(data($child/@rdf:about), "/places/"), "#this") }</key>
                 <data>
                 <id>{ substring-before(substring-after(data($child/@rdf:about), "/places/"), "#this") }</id>
                 <lng>{ if($placeConcept/geo:long/text()!= "") then
                                                (
                                                data($placeConcept/geo:long/text())
                                                )
            
                                                else
                                                (
                                                    if($child//spatial:C[@type='isInVicinityOf'])
                                                        then (
                                                            let $parentId := data($child//spatial:C[@type='isInVicinityOf'][1]/@rdf:resource)
                                                            let $parentWithGeoRef :=
                                                                        $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about=$parentId[1] || "#this"][1]
                                                            return 
                                                             
                                                            data($parentWithGeoRef//pleiades:Place[1]/geo:long[1])
                                                            )
                                                      else(
                                                            let $Ps := $child/spatial:P
                                                            let $parentId := data($Ps/@rdf:resource)
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(matches(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else 
                                                                        (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:long)
            
                                                    )
                                                    )
                                                }</lng>
                 <lat>{ if($placeConcept/geo:lat/text() != "") then
                                                (
                                                data($placeConcept/geo:lat/text())
                                                )
            
                                                else
                                                (
                                                    if($child//spatial:C[@type='isInVicinityOf'])
                                                        then (
                                                            let $parentId := data($child/spatial:C[@type='isInVicinityOf'][1]/@rdf:resource)
                                                            let $parentWithGeoRef :=  $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about=$parentId[1] || "#this"][1]
                                                            return  data($parentWithGeoRef//pleiades:Place[1]/geo:lat[1])
                                                            )
                                                      else(
                                                            let $Ps := $child/spatial:P
                                                            let $parentId := $child//spatial:P/@rdf:resource
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(matches(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:lat)
            
                                                    )
                                                    )
                                                }</lat>
                 <lang>{$lang}</lang>
                </data>
                 <isFolder>true</isFolder>
                 { spatiumStructor:placeNodes($nts, (), data($child/@type), $lang)}
              </children>



 };

 declare function spatiumStructor:placeNodes($nodes, $visited, $renderingOrder, $lang){

            for $childnodes in $nodes except ($visited)
                let $uri := data($childnodes/@rdf:resource) || "#this"
                let $ntConcept :=
                    $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about=$uri]
                 let $placeConcept := $ntConcept[1]//pleiades:Place

                let $order := data($placeConcept/@ype)

                order by
                    if ($renderingOrder = "ordered") then reverse($childnodes)
                    else (lower-case(

                            if(exists($placeConcept/dcterms:title[@xml:lang=$lang])) then
                           translate($placeConcept/dcterms:title[@xml:lang=$lang]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($placeConcept/dcterms:title[@xml:lang="en"])) then
                            translate($placeConcept/dcterms:title[@xml:lang="en"]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($placeConcept/dcterms:title[@xml:lang="fr"])) then
                            translate($placeConcept/dcterms:title[@xml:lang="fr"]/text(),'Â, Ê, É','A, E, E')
                            else if(exists($placeConcept/dcterms:title[@xml:lang="de"])) then
                            translate($placeConcept/dcterms:title[@xml:lang="de"]/text(),'Â, Ê, É','A, E, E')
                            else(
                            translate($placeConcept/dcterms:title[@xml:lang="en"]/text(),'Â, Ê, É','A, E, E'))
                    ))
                     (:
                     if($renderingOrder ="ordered") then order by reverse($childnodes)
                     else order by $ntSkosConcept/skos:prefLabel[@xml:lang=$lang]:)

    return

                if ($ntConcept//spatial:Pi)
                  then(
                       <children json:array="true" status="{data($ntConcept//@status)}" type="collectionItem">
                                <title>
                                {if(exists($placeConcept//dcterms:title/text())) then
                                (
                                functx:capitalize-first($placeConcept//dcterms:title/text())
                                || " [" || substring-before(substring-after($uri, "/places/"), "#this") ||"]"
                                )

                                else if ($placeConcept/dcterms:title[@xml:lang='en']/text()) then
                                (concat(functx:capitalize-first($ntConcept//pleiades:Place/dcterms:title[@xml:lang='en']/text()), ' (en)'))
                                else if  ($placeConcept/dcterms:title[@xml:lang='fr']/text()) then
                                (concat(functx:capitalize-first($placeConcept/dcterms:title[@xml:lang='fr']/text()), ' (fr)'))



                                else ("No name found for " || data($ntConcept/@rdf:about))
                                || " [" || substring-before(substring-after($placeConcept/@rdf:about, "places/"), "#this") || "]"
                                }</title>
                                <data>
                                <id>{ substring-before(substring-after($uri, "/places/"), "#this") }</id>
                                
                                <!--<key>{ substring-before(substring-after(data($ntConcept/@rdf:about), "/places/"), "#this") }</key>-->
                                 <key>{ substring-before(substring-after($uri, "/places/"), "#this") }</key>
                                <uri>{$uri}</uri>
                                {""
(:                                substring-before(substring-after(data($ntConcept/@rdf:about), "/places/"), "#this") :)
                                }
                                 
                                 <lng>{ if($placeConcept/geo:long/text()!= "") then
                                                (
                                                data($placeConcept/geo:long/text())
                                                )
            
                                                else
                                                (
                                                    if($placeConcept//spatial:C[@type='isInVicinityOf'])
                                                        then (
                                                            let $parentId := data($placeConcept//spatial:C[@type='isInVicinityOf'][1]/@rdf:resource)
                                                            let $parentWithGeoRef :=
                                                                        $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about=$parentId || "#this"][1]
                                                            return 
                                                             
                                                            data($parentWithGeoRef//pleiades:Place[1]//geo:long[1])
                                                            )
                                                      else if($placeConcept/spatial:Pi) then (
                                                            let $Ps := $placeConcept/spatial:Pi
                                                            let $parentId := data($Ps[1]/@rdf:resource)
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(matches(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else 
                                                                        (<pleiades:Place/>)
            
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:long)
            
                                                    )
                                                     
                                                     
                                                     
                                                     
                                                     else(
                                                            let $Ps := $placeConcept/spatial:P
                                                            let $parentId := data($Ps/@rdf:resource)
            
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(matches(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else 
                                                                        (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:long)
            
                                                    )
                                                    
                                                    
                                                    )
                                                }</lng>
                 <lat>{ if($placeConcept/geo:lat/text() != "") then
                                                (
                                                data($placeConcept/geo:lat/text())
                                                )
            
                                                else
                                                (
                                                    if($placeConcept//spatial:C[@type='isInVicinityOf'])
                                                        then (
                                                            let $parentId := data($placeConcept/spatial:C[@type='isInVicinityOf'][1]/@rdf:resource)
                                                            let $parentWithGeoRef :=  $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about=$parentId || "#this"][1]
                                                            return  data($parentWithGeoRef//pleiades:Place[1]//geo:lat[1])
                                                            )
                                                            
                                                      else if ($placeConcept/spatial:Pi) then (
                                                            let $Ps := $placeConcept/spatial:Pi
                                                            let $parentId := data($placeConcept//spatial:Pi[1]/@rdf:resource)
            
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(matches(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:lat)
            
                                                    )
                                                    
                                                      else(
                                                            let $Ps := $placeConcept/spatial:P
                                                            let $parentId := data($placeConcept//spatial:P/@rdf:resource)
            
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(matches(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:lat)
            
                                                    )
                                                    )
                                                }</lat>
                                 
                                 
                                 
                                 
                                 
                                </data>
                                <lang>{$lang}</lang>
                                <isFolder>true</isFolder>
                                { spatiumStructor:placeNodes($ntConcept//spatial:Pi, ($visited, $childnodes), data($ntConcept/@type), $lang)
                                        }
                        </children>
                    )
                    else
                    (
                    <children json:array="false" status="{data($ntConcept//@status)}" type="collectionItem">
                        <title>{
                        if(exists($placeConcept/dcterms:title[1]/text())) then
                                (
                                functx:capitalize-first($placeConcept/dcterms:title[1]/text())
                                
                                )
                               else if(exists($placeConcept/dcterms:title[@xml:lang=$lang][1])) then
                                (
                                concat(functx:capitalize-first($placeConcept/dcterms:title[@xml:lang=$lang]/text()),
                                functx:capitalize-first($placeConcept/dc:title[1]/text()))
                                )
                                else if ($placeConcept/dcterms:title[@xml:lang='en']/text()) then
                                (concat(functx:capitalize-first($placeConcept/dcterms:title[@xml:lang='en']/text()), ' (en)',
                                functx:capitalize-first($placeConcept/dc:title[1]/text())))
                                else if  ($placeConcept/dcterms:title[1][@xml:lang='fr']/text()) then
                                (concat(functx:capitalize-first($placeConcept/dcterms:title[@xml:lang='fr']/text()), ' (fr)',
                                functx:capitalize-first($placeConcept/dc:title[1]/text())))
                                else ("No name foer " || data($ntConcept[1]/@rdf:about))
                                }{" [" || substring-before(substring-after($uri, "places/"), "#this") || "]"}</title>
                          
                                    <id>{ substring-before(substring-after(data($uri), "/places/"), "#this")}</id>
                                    
                                    <key>{ substring-before(substring-after(data($uri), "/places/"), "#this")}</key>
                                    <data>
                                    <uri>{$uri}</uri>
                                    <lng>{ if($placeConcept/geo:long/text() !="") then
                                                (
                                                data($placeConcept/geo:long/text())
                                                )
            
                                                else
                                                (
                                                    if($ntConcept//spatial:C[@type='isInVicinityOf'])
                                                        then (
                                                        
                                                            let $parentId := data($ntConcept[1]/spatial:C[@type='isInVicinityOf'][1]/@rdf:resource)
                                                            
                                                            let $parentWithGeoRef :=  $spatiumStructor:place-collection//spatial:Feature[@rdf:about=$parentId[1] || "#this"][1]
                                                            
                                                            return  data($parentWithGeoRef//pleiades:Place[1]/geo:long[1])
                                                            )
                                                      
                                                      else(
                                                            let $Ps := $ntConcept/spatial:P
                                                            let $parentId := data($ntConcept//spatial:P[1]/@rdf:resource)
            
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(matches(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:long)
            
                                                    )
                                                    )
                                                }
                                    </lng>
                                    <lat>{ if($placeConcept/geo:lat/text() != "") then
                                                (
                                                data($placeConcept/geo:lat/text())
                                                )
            
                                                else
                                                (
                                                    if($ntConcept//spatial:C[@type='isInVicinityOf'])
                                                        then (
                                                            let $parentId := data($ntConcept[1]/spatial:C[@type='isInVicinityOf'][1]/@rdf:resource)
                                                            let $parentWithGeoRef :=  $spatiumStructor:place-collection//spatial:Feature[@rdf:about=$parentId[1] || "#this"][1]
                                                            return  data($parentWithGeoRef//pleiades:Place[1]/geo:lat[1])
                                                            )
                                                      else(
                                                            let $Ps := $ntConcept/spatial:P
                                                            let $parentId := data($ntConcept//spatial:P/@rdf:resource)
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(matches(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:lat)
            
                                                    )
                                                    )
                                                }
            
            
            
            
                                    </lat>
                        <lang>{$lang}</lang>
                        </data>
                    </children>
                    )
         (:{ if($ntConcept//pleiades:Place/geo:lat) then
                                    data($ntConcept//pleiades:Place/geo:lat/text())
                                    else
                                    (
                                    let $parentId := data($ntConcept[1]//spatial:P[1]/@rdf:resource)
                                    let $parentWithGeoRef :=  $spatiumStructor:place-collection//spatial:Feature[@rdf:about=$parentId || "#this"]
                                    return data($parentWithGeoRef//pleiades:Place/geo:lat))}
                        :)


};

declare function spatiumStructor:buildArchaeoTree(){
 let $rootDoc := doc($spatiumStructor:project-place-collection-path || "/_root.rdf")
 let $places-collection := collection($spatiumStructor:project-place-collection-path )
 let $rootPlaces := $rootDoc//spatial:Pi
 let $rootNodesFromRootFile :=
        for $place in $rootPlaces
        let $placeUri := $place/@rdf:resource || "#this"
        return
        $places-collection//spatial:Feature[@rdf:about=$placeUri]
 let $romanProvinces := spatiumStructor:getRomanProvinces()
 let $rootNodes :=
         $places-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place//pleiades:hasFeatureType[@rdf:resource='https://ausohnum.huma-num.fr/concept/c23474']]
 let $rootNodesByRegions :=
         $places-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place//pleiades:hasFeatureType[@rdf:resource='https://ausohnum.huma-num.fr/concept/c23526']]

(: for $child in $children:)
 return

        serialize(
        <children xmlns:json="http://www.json.org" json:array="true">
         <title>Places</title>
         <id>{data($rootDoc/@rdf:about)}</id>
         <key>{data($rootDoc/@rdf:about)}</key>
         <lng>{ data($rootDoc//pleiades:Place/geo:long/text()) }</lng>
         <lat>{ data($rootDoc//pleiades:Place/geo:lat/text()) }</lat>
          <isFolder>true</isFolder>
         <orderedCollection json:literal="true">true</orderedCollection>
         <lang></lang>
                        <children xmlns:json="http://www.json.org" json:array="true">
                         <title>Create a new place</title>
                         <id>new</id>
                         <key>new</key>
                         <lng></lng>
                         <lat></lat>
                          <isFolder>false</isFolder>
                         <lang></lang>
                         
                       </children>
                       <children xmlns:json="http://www.json.org" json:array="true">
                         <title>By Regions</title>
                         <!--
                         <id>{data($rootDoc/@rdf:about)}</id>
                         <key>{data($rootDoc/@rdf:about)}</key>
                         <lng>{ data($rootDoc//pleiades:Place/geo:long/text()) }</lng>
                         <lat>{ data($rootDoc//pleiades:Place/geo:lat/text()) }</lat>
                         -->
                          <isFolder>true</isFolder>
                         <orderedCollection json:literal="true">true</orderedCollection>
                         <lang></lang>
                                    { spatiumStructor:buildArchaeoTree($rootNodesByRegions, "en")}
                       </children>
                       <children xmlns:json="http://www.json.org" json:array="true">
                         <title>By Alphabetical Order</title>
                         <!--
                         <id>{data($rootDoc/@rdf:about)}</id>
                         <key>{data($rootDoc/@rdf:about)}</key>
                         <lng>{ data($rootDoc//pleiades:Place/geo:long/text()) }</lng>
                         <lat>{ data($rootDoc//pleiades:Place/geo:lat/text()) }</lat>
                         -->
                          <isFolder>true</isFolder>
                         <orderedCollection json:literal="true">true</orderedCollection>
                         <lang></lang>
                                    { spatiumStructor:buildArchaeoTree($rootNodes, "en")}
                       </children>

    </children>
        ,
            <output:serialization-parameters>
                <output:method>json</output:method>
            </output:serialization-parameters>
        )

 };
 
 declare function spatiumStructor:buildArchaeoTree($rootNodes, $lang){
                let $collation :=  '?lang=' || lower-case($lang) || "-" || $lang

                for $child in $rootNodes
                let $placeConcept := $child//pleiades:Place
                let $nts := $child//spatial:Pi
                let $order := data($child/@type)
                order by
                      lower-case($child/foaf:primaryTopicOf/pleiades:Place/dcterms:title) collation "?lang=en"

              return

              <children json:array="true" status="{data($child//@status)}" type="collectionItem">
                 <title>{ if($child//pleiades:Place[1]//dcterms:title/text()) then
                            functx:capitalize-first($child//pleiades:Place/dcterms:title/text())
                          else ("No label for " || data($child/@rdf:about))

                 }</title>

                 <uri>{ data($child/@rdf:about) }</uri>
                 <key>{ substring-before(substring-after(data($child/@rdf:about), "/places/"), "#this") }</key>
                 <data>
                 <id>{ substring-before(substring-after(data($child/@rdf:about), "/places/"), "#this") }</id>
                 <lng>{ if($placeConcept/geo:long/text()!= "") then
                                                (
                                                data($placeConcept/geo:long/text())
                                                )
            
                                                else
                                                (
                                                    if($child//spatial:C[@type='isInVicinityOf'])
                                                        then (
                                                            let $parentId := data($child//spatial:C[@type='isInVicinityOf'][1]/@rdf:resource)
                                                            let $parentWithGeoRef :=
                                                                        $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about=$parentId[1] || "#this"][1]
                                                            return 
                                                             
                                                            data($parentWithGeoRef//pleiades:Place[1]/geo:long[1])
                                                            )
                                                      else(
                                                            let $Ps := $child/spatial:P
                                                            let $parentId := data($Ps/@rdf:resource)
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(matches(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else 
                                                                        (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:long)
            
                                                    )
                                                    )
                                                }</lng>
                 <lat>{ if($placeConcept/geo:lat/text() != "") then
                                                (
                                                data($placeConcept/geo:lat/text())
                                                )
            
                                                else
                                                (
                                                    if($child//spatial:C[@type='isInVicinityOf'])
                                                        then (
                                                            let $parentId := data($child/spatial:C[@type='isInVicinityOf'][1]/@rdf:resource)
                                                            let $parentWithGeoRef :=  $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about=$parentId[1] || "#this"][1]
                                                            return  data($parentWithGeoRef//pleiades:Place[1]/geo:lat[1])
                                                            )
                                                      else(
                                                            let $Ps := $child/spatial:P
                                                            let $parentId := data($child//spatial:P/@rdf:resource)
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(matches(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:lat)
            
                                                    )
                                                    )
                                                }</lat>
                 <lang>{$lang}</lang>
                </data>
                 <isFolder>true</isFolder>
                 { spatiumStructor:placeNodes($nts, (), data($child/@type), $lang)}
              </children>



 };


declare function spatiumStructor:getPlaceRdf($uri){
    (:$spatiumStructor:place-collection//.[@rdf:about=$data/uri]:)
 let $decodedUri := xmldb:decode-uri($uri)
 return
(: $uri:)
(: <a>{$decodedUri}</a> :)
    util:eval('collection("' || $spatiumStructor:project-place-collection-path || '")//.[@rdf:about="' || $decodedUri || '"][1]')
};

 declare function spatiumStructor:getPlaceHTML($uri){
(:    Function to display place details
:)
let $log := ""(:console:log("uri: " ):)
let $currentUser := sm:id()//sm:real/sm:username/string()
let $groups := string-join(sm:get-user-groups($currentUser), ' ')
let $userRights :=
        if (matches($groups, ('sandbox'))) then "sandbox"
        else if(matches($groups, ('patrimonium'))) then "editor"
        else ("guest")
    
     let $uriShort := if (contains($uri, '#this')) then substring-before($uri, '#this') else $uri
     let $decodedUri := xmldb:decode-uri(if (contains($uri, '#this')) then $uri else $uri || "#this")
(:     let $placeRdf := util:eval('collection("' || $spatiumStructor:project-place-collection-path || '")//spatial:Feature[@rdf:about="' || $decodedUri || '"][1]'):)
   return
   ((<http:response status="200"> 
                    <http:header name="Cache-Control" value="no-cache"/> 
                    <http:header name="TESTUM" value="no-cache"/>
                </http:response> 
     ),
            if($spatiumStructor:place-collection//spatial:Feature[@rdf:about= $decodedUri]) then (
               
               let $placeRdf :=  $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about= $decodedUri]
                  
                  let $isMadeOfUris := if($placeRdf//spatial:Pi) then <uris>{ $placeRdf//spatial:Pi }</uris> else <none/>
                  let $isPartOfUris := if($placeRdf//spatial:P) then <uris> { $placeRdf//spatial:P }</uris> else <none/>
                  let $isInVicinityOfUris := if($placeRdf//spatial:C[@type='isInVicinityOf']) then <uris> { $placeRdf//spatial:C[@type='isInVicinityOf'] }</uris> else <none/>
                  let $hasInItsVicinityUris:= if($placeRdf//spatial:C[@type='hasInItsVicinity']) then <uris> { $placeRdf//spatial:C[@type='hasInItsVicinity'] }</uris> else <none/>
                  let $placeName := $placeRdf//dcterms:title/text()
                  let $relatedDocs := spatiumStructor:relatedDocuments($uriShort)
                  let $docs := <div class="xmlElementGroup">
                                      <span class="subSectionTitle">List of documents linked to this place</span>
                                      <div id="listOfDocuments">
                                      {if (count($relatedDocs) >0) then
                                            (<div>
                                            {
                                            if(count($relatedDocs) < 10) then () else      (<div>These are the 10 first documents on {count($relatedDocs)} in total</div>)}
                                            <ul class="listNoBullet">
                                            
                                                      {
                                                        for $doc in $relatedDocs[position() <11]
                             (:                           $spatiumStructor:doc-collection//tei:TEI[descendant-or-self::tei:placeName[@ref=$uriShort]]:)
                                                         (:$spatiumStructor:doc-collection//tei:TEI[tei:listPlace//tei:place//tei:placeName[@ref=$uriShort]]:)
                                                                let $docId := data($doc/@xml:id)
                                                                let $title := $doc//tei:titleStmt/tei:title/text()
                                                                let $docUri := if($doc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]) then $doc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]
                                                                                         else $spatiumStructor:uriBase || "/documents/" || $docId
                                                                let $placeType := (
                                                                                             let $placeNodes := 
                                                                                             $doc//tei:listPlace//tei:place//tei:placeName[matches(./@ref, $uriShort)]
                                                                                             for $placeNode in $placeNodes
                                                                                                 return
                                                                                                     if ($placeNode/@ana)
                                                                                                     then data($placeNode/@ana)
                                                                                                     else if (not($placeNode/@ana)) then ($placeNode/parent::node()/name())
                                                                                                     else ()
                                                                                                     )
                                                                          return
                                                                             <li>
                                                                             <span class="glyphicon glyphicon-file"/><a href="{ $docUri }" title="Open document { $docUri }" target="_self">{ $title }</a>
                                                                             
                                                                                             <span>[{ $placeType }]</span><a href="{ $docUri }" title="Open document { $docUri } in a new window" target="_blank">
                                                                                             <i class="glyphicon glyphicon-new-window"/></a>
                                                                             </li>
                                                         
                                                         }</ul>
                                                         </div>)
                                                         
                                         else (<em>None</em>)}
                                         </div>
                                         
                                  </div>
               
                
                
                
                return
                
                <div>
                <!--<script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
                -->
                  <!--
                  <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>
                  -->
             <!--
             <link rel="stylesheet" href="$ausohnum-lib/resources/css/teiEditor.css"/>
             -->
             
                <h3 id="resourceTitle">{ $placeName }</h3>
                <span id="currentPlaceUri" class="hidden">{ $uriShort }</span>
                <h4>URI { $uriShort }</h4>
                    <ul class="nav nav-pills" id="pills-tab" role="tablist">
                                         <li class="nav-item active">
                                           <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Place details</a>
                                         </li>
                                         
                                         <li class="nav-item">
                                           <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML</a>
                                         </li>
                                     </ul>
                                     <div class="tab-content" id="nav-tabContent">
                                         <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
                                     
                                                { spatiumStructor:displayElement('title', $decodedUri, (), ()) }
                                                 { spatiumStructor:displayElement('altLabel', $decodedUri, (), ()) }
                                                {spatiumStructor:displayElement('exactMatch', $decodedUri, (), ())}
                                                { spatiumStructor:displayElement('hasFeatureTypeMain', $decodedUri, (), ()) }
                                                { spatiumStructor:displayElement('productionType', $decodedUri, (), ()) }
                                                {spatiumStructor:placeLocation($uri)}
                                                { spatiumStructor:placeConnectedWith($uri, "isInVicinityOf", $isInVicinityOfUris)}
                                                { spatiumStructor:placeConnectedWith($uri, "hasInItsVicinity", $hasInItsVicinityUris)}
                                                { spatiumStructor:isMadeOf($uri, $isMadeOfUris)}
                                                   { spatiumStructor:isPartOf($uri, $isPartOfUris)}
                                           { $docs}
                                           {spatiumStructor:relatedPeople($uriShort)}
                                           { spatiumStructor:displayElement('generalCommentary', $decodedUri, (), ()) }
                                           { spatiumStructor:displayElement('privateCommentary', $decodedUri, (), ()) }
                                        </div>
                                     <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
                                          { spatiumStructor:xmlFileEditorWithUri($uri) }
                                                              
                                      </div>
                                      </div>
                                      <script>console.log("Editor required");
             var editor4File = ace.edit("xml-editor-file");
                   editor4File.session.setMode("ace/mode/xml");
                   editor4File.setOptions({{
                         minLines: 40,
                         maxLines: Infinity}});
                         
              function getXmlEditorContent(){{
                     var xmlFileEditor = ace.edit("xml-editor-file");
                     return xmlFileEditor.getValue();
                      
              }};           
             </script>
                </div>
                )
                else (
                <div class="jumbotron jumbotron-fluid">
                        <div class="container">
                          <h1 class="display-4">Error!</h1>
                          <p class="lead">There is no place with URI { $decodedUri }</p>
                        </div>
                      </div>
                )
 )};

declare function spatiumStructor:getPlaceHTML2($id){
(:    Function to display place details
:)
let $log := ""(: console:log("uri: " ):)
let $currentUser := sm:id()//sm:real/sm:username/string()
let $groups := string-join(sm:get-user-groups($currentUser), ' ')
let $userRights :=
        if (matches($groups, ('sandbox'))) then "sandbox"
        else if(matches($groups, ('patrimonium'))) then "editor"
        else ("guest")
    let $uri := if(contains( $id, "http")) then $id else 
            $spatiumStructor:baseUri || "/places/" || $id || "#this"
     let $uriShort := if (contains($uri, '#this')) then substring-before($uri, '#this') else $uri
     let $decodedUri := xmldb:decode-uri(if (contains($uri, '#this')) then $uri else $uri || "#this")
(:     let $placeRdf := util:eval('collection("' || $spatiumStructor:project-place-collection-path || '")//spatial:Feature[@rdf:about="' || $decodedUri || '"][1]'):)
   return
   ((<http:response status="200"> 
                    <http:header name="Cache-Control" value="no-cache"/> 
                    <http:header name="TESTUM" value="no-cache"/>
                </http:response> 
     ),
            if($spatiumStructor:place-collection//spatial:Feature[@rdf:about= $decodedUri]) then (
               
               let $placeRdf :=  $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about= $decodedUri]
                  
                  let $isMadeOfUris := if($placeRdf//spatial:Pi) then <uris>{ $placeRdf//spatial:Pi }</uris> else <none/>
                  let $isPartOfUris := if($placeRdf//spatial:P) then <uris> { $placeRdf//spatial:P }</uris> else <none/>
                  let $isInVicinityOfUris := if($placeRdf//spatial:C[@type='isInVicinityOf']) then <uris> { $placeRdf//spatial:C[@type='isInVicinityOf'] }</uris> else <none/>
                  let $hasInItsVicinityUris:= if($placeRdf//spatial:C[@type='hasInItsVicinity']) then <uris> { $placeRdf//spatial:C[@type='hasInItsVicinity'] }</uris> else <none/>
                  let $isAdjacentToUris:= if($placeRdf//spatial:C[@type='isAdjacentTo']) then <uris> { $placeRdf//spatial:C[@type='isAdjacentTo'] }</uris> else <none/>
                  let $placeName := $placeRdf//dcterms:title/text()
                  
                 let $relatedDocs := spatiumStructor:relatedDocuments($uriShort)
                 
                 let $docs := <div class="xmlElementGroup">
                                      <span class="subSectionTitle">List of documents linked to this place</span>
                                      {
                                            if( count($relatedDocs)> 10) then (<div>These are the 10 first documents on {count($relatedDocs)} in total</div>) else()}
                                      <div id="listOfDocuments">
                                      {if($relatedDocs) then
                                      (
                                      <ul class="listNoBullet">{
                                        for $doc in $relatedDocs[position() < 11] 
             (:                           $spatiumStructor:doc-collection//tei:TEI[descendant-or-self::tei:placeName[@ref=$uriShort]]:)
                                         (:$spatiumStructor:doc-collection//tei:TEI[tei:listPlace//tei:place//tei:placeName[@ref=$uriShort]]:)
                                                let $docId := data($doc/@xml:id)
                                                let $title := $doc//tei:titleStmt/tei:title[not(ancestor::tei:bibFull)][1]/text()
                                                let $docUri := if($doc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]) then $doc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]
                                                                         else $spatiumStructor:uriBase || "/documents/" || $docId
                                                let $placeType := (
                                                                             let $placeNodes := 
                                                                             $doc//tei:listPlace//tei:place//tei:placeName[contains(./@ref, $uriShort)]
                                                                             for $placeNode in $placeNodes
                                                                                 return
                                                                                     if ($placeNode/@ana)
                                                                                     then data($placeNode/@ana)
                                                                                     else if (not($placeNode/@ana)) then ($placeNode/parent::node()/name())
                                                                                     else ()
                                                                                     )
                                                          return
                                                             <li>
                                                             <span class="glyphicon glyphicon-file"/><a href="{ $docUri }" title="Open document { $docUri }" target="_self">{ $title }</a>
                                                             
                                                                             <span>[{""
(:                                                                             $placeType :)
                                                                             }]</span><a href="{ $docUri }" title="Open document { $docUri } in a new window" target="_blank">
                                                                             <i class="glyphicon glyphicon-new-window"/></a>
                                                             </li>
                                         
                                         }</ul>)
                                         
                                         else (<em>None</em>)}
                                         </div>
                                         
                                  </div>
               
                let $hasSize :=if($placeRdf//apc:hasSize) then 
                 <div class="xmlElementGroup">
                                      <span class="subSectionTitle">Size</span>
                                      <div>
                                        {spatiumStructor:displayElement('hasSizeType', $decodedUri, (), ())}
                                        {spatiumStructor:displayElement('hasSizeValue', $decodedUri, (), ())}
                                        {spatiumStructor:displayElement('hasSizeComment', $decodedUri, (), ())}
                                        </div>
                                        </div>
                        
                    else()
                let $hasYield :=if($placeRdf//apc:hasYield) then 
                 <div class="xmlElementGroup">
                                      <span class="subSectionTitle">Yield</span>
                                      <div>
                                        {spatiumStructor:displayElement('hasYieldType', $decodedUri, (), ())}
                                        {spatiumStructor:displayElement('hasYieldValue', $decodedUri, (), ())}
                                        {spatiumStructor:displayElement('hasYieldComment', $decodedUri, (), ())}
                                        </div>
                                        </div>
                        
                    else()
                
                return
                
                <div id="placeDetails">
            <!--    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
                
                  
                  <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>
                  -->
             <!--
             <link rel="stylesheet" href="$ausohnum-lib/resources/css/teiEditor.css"/>
             -->
             
                <h3 id="resourceTitle">{ $placeName }</h3>
                <span id="currentPlaceUri" class="hidden">{ $uriShort }</span>
                <span id="placeEditorType" class="hidden">placeManager</span>
                <h4>URI { $uriShort }</h4>
                    <ul class="nav nav-pills" id="pills-tab" role="tablist">
                                         <li class="nav-item active">
                                           <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Place details</a>
                                         </li>
                                         
                                         <li class="nav-item">
                                           <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML</a>
                                         </li>
                                     </ul>
                                     <div class="tab-content" id="nav-tabContent">
                                         <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
                                     
                                                { spatiumStructor:displayElement('title', $decodedUri, (), ()) }
                                                 { spatiumStructor:displayElement('altLabel', $decodedUri, (), ()) }
                                                {spatiumStructor:displayElement('exactMatch', $decodedUri, (), ())}
                                                { spatiumStructor:displayElement('hasFeatureTypeMain', $decodedUri, (), ()) }
                                                { spatiumStructor:displayElement('productionType', $decodedUri, (), ()) }
                                                { $hasSize }
                                                { $hasYield }
                                                {spatiumStructor:placeLocation($uri)}
                                                { spatiumStructor:isPartOf($uri, $isPartOfUris)}
                                                { spatiumStructor:placeConnectedWith($uri, "isInVicinityOf", $isInVicinityOfUris)}
                                                { spatiumStructor:placeConnectedWith($uri, "hasInItsVicinity", $hasInItsVicinityUris)}
                                                { spatiumStructor:placeConnectedWith($uri, "isAdjacentTo", $isAdjacentToUris)}
                                                { spatiumStructor:isMadeOf($uri, $isMadeOfUris)}
                                                
                                                
                                           { $docs }
                                           {spatiumStructor:relatedPeople($uriShort)}
                                           {
                                   spatiumStructor:resourcesManager('seeFurther', $uriShort)
                                   }
                                   { spatiumStructor:displayElement('keywords', $decodedUri, (), ()) }
                                           { spatiumStructor:displayElement('generalCommentary', $decodedUri, (), ()) }
                                           { spatiumStructor:displayElement('privateCommentary', $decodedUri, (), ()) }
                                        </div>
                                     <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
                                          { spatiumStructor:xmlFileEditorWithUri($uri) }
                                                              
                                      </div>
                                      </div>
                                      <script>console.log("Editor required");
             var editor4File = ace.edit("xml-editor-file");
                   editor4File.session.setMode("ace/mode/xml");
                   editor4File.setOptions({{
                         minLines: 40,
                         maxLines: Infinity}});
                         
              function getXmlEditorContent(){{
                     var xmlFileEditor = ace.edit("xml-editor-file");
                     return xmlFileEditor.getValue();
                      
              }};           
             </script>
                </div>
                )
                else (
                <div class="jumbotron jumbotron-fluid">
                        <div class="container">
                          <h1 class="display-4">Error!</h1>
                          <p class="lead">There is no place with URI { $decodedUri }</p>
                        </div>
                      </div>
                )
 )};

declare function spatiumStructor:noPlaceFound($decodedUri){
<div class="jumbotron jumbotron-fluid">
                        <div class="container">
                          <h1 class="display-4">Error!</h1>
                          <p class="lead">There is no place with URI { $decodedUri }</p>
                        </div>
                      </div>
};
declare function spatiumStructor:placeIntro(){
<div class="row">
                        <div class="container">
                          <h1 class="display-4">Welcome to APC Places</h1>
                          <p class="lead"></p>
                        </div>
                      </div>
};
declare function spatiumStructor:getArchaeoHTML($uri, $project){
(:    Function to display place details
:)
let $currentUser := sm:id()//sm:real/sm:username/string()
let $groups := string-join(sm:get-user-groups($currentUser), ' ')
let $userRights :=
        if (matches($groups, ('sandbox'))) then "sandbox"
        
        else if(matches($groups, ($project))) then "editor"
        
        
        else ("guest")
     
     let $uri := if(contains($uri, "http")) then $uri else $spatiumStructor:uriBase || "/places/" || $uri   
     let $uriShort := if (matches($uri, '#this')) then substring-before($uri, '#this') else $uri
     let $decodedUri := xmldb:decode-uri(if (matches($uri, '#this')) then $uri else $uri || "#this")
     let $placeRdf := util:eval('collection("' || $spatiumStructor:project-place-collection-path || '")//spatial:Feature[@rdf:about="' || $decodedUri || '"][1]')
(:               let $placeRdf :=  $spatiumStructor:place-collection//spatial:Feature[@rdf:about= $decodedUri]:)

let $isMadeOfUris := if($placeRdf//spatial:Pi) then <uris>{ $placeRdf//spatial:Pi }</uris> else <none/>
     let $isPartOfUris := if($placeRdf//spatial:P) then <uris> { $placeRdf//spatial:P }</uris> else <none/>
     let $isInVicinityOfUris := if($placeRdf//spatial:C[@type='isInVicinityOf']) then <uris> { $placeRdf//spatial:C[@type='isInVicinityOf'] }</uris> else <none/>
     let $hasInItsVicinityUris:= if($placeRdf//spatial:C[@type='hasInItsVicinity']) then <uris> { $placeRdf//spatial:C[@type='hasInItsVicinity'] }</uris> else <none/>
     let $placeName := $placeRdf//dcterms:title/text()
     let $relatedDocuments := spatiumStructor:relatedDocuments($uriShort, $spatiumStructor:project)
     let $docs :=
                    <div id="relatedDocs">
                      <div class="xmlElementGroup">
                         <span class="subSectionTitle">List of documents linked to this place</span>
                         <div id="listOfDocuments">
                         {if ($relatedDocuments) then
                         (
                         <ul class="listNoBullet">{
                           for $doc in $relatedDocuments
(:                           $spatiumStructor:doc-collection//tei:TEI[descendant-or-self::tei:placeName[@ref=$uriShort]]:)
                            (:$spatiumStructor:doc-collection//tei:TEI[tei:listPlace//tei:place//tei:placeName[@ref=$uriShort]]:)
                                   let $docId := data($doc/@xml:id)
                                   let $title := $doc//tei:titleStmt/tei:title/text()
                                   let $docUri := if($doc//tei:idno[@type="uri"]) then $doc//tei:idno[@type="uri"]
                                                            else $spatiumStructor:uriBase || "/documents/" || $docId
                                   let $placeType := (
                                                                let $placeNodes := 
                                                                $doc//tei:listPlace//tei:place//tei:placeName[matches(./@ref, $uriShort)]
                                                                for $placeNode in $placeNodes
                                                                    return
                                                                        if ($placeNode/@ana)
                                                                        then data($placeNode/@ana)
                                                                        else if (not($placeNode/@ana)) then ($placeNode/parent::node()/name())
                                                                        else ()
                                                                        )
                                             return
                                                <li>
                                                <span class="glyphicon glyphicon-file"/><a href="{ $docUri }" title="Open document { $docUri }" target="_self">{ $title }</a>
                                                
                                                                <span>[{ $placeType }]</span><a href="{ $docUri }" title="Open document { $docUri } in a new window" target="_blank">
                                                                <i class="glyphicon glyphicon-new-window"/></a>
                                                </li>
                            
                            }</ul>)
                            
                            else (<em>None</em>)}
                            </div>
                            
                     </div>
                </div>
   
   
   
   return
   if($placeRdf) then (
   <div>
   <!--<script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
   -->
     <!--
     <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>
     -->
<!--
<link rel="stylesheet" href="$ausohnum-lib/resources/css/teiEditor.css"/>
-->

   <h2 id="resourceTitle">{ $placeName }</h2>
   <span id="currentPlaceUri" class="hidden">{ $uriShort }</span>
   <h5>URI { $uriShort } { spatiumStructor:copyValueToClipboardButton("uri", 1, $uriShort) }</h5>
       <ul class="nav nav-pills" id="pills-tab" role="tablist">
                            <li class="nav-item active">
                              <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Place details</a>
                            </li>
                            <li class="nav-item">
                              <a class="nav-link" id="pills-docs-tab" data-toggle="pill" href="#nav-docs" role="tab" aria-controls="pills-docs" aria-selected="false">Documents</a>
                            </li>
                            <li class="nav-item">
                              <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML</a>
                            </li>
                        </ul>
                        <div class="tab-content" id="nav-tabContent">
                            <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
                        
                                   { spatiumStructor:displayElement('title', $decodedUri, (), ()) }
                                    
                                    { spatiumStructor:displayElement('altLabel', $decodedUri, (), ()) }
                                    
                                    { spatiumStructor:displayElement('hasFeatureTypeMain', $decodedUri, (), ()) }
                                   {""
(:                                   spatiumStructor:biblioManager($uriShort):)
                                   }
                                   {spatiumStructor:placeLocation($uri)}
                                   <h3 style="margin-top: 10px!important;">Link(s) with other places</h3>
                                   { spatiumStructor:isMadeOfArchaeo($uri, $isMadeOfUris)}
                                      { spatiumStructor:isPartOf($uri, $isPartOfUris)}
                                      { spatiumStructor:placeConnectedWith($uri, "isInVicinityOf", $isInVicinityOfUris)}
                                   { spatiumStructor:placeConnectedWith($uri, "hasInItsVicinity", $hasInItsVicinityUris)}
                                  <h3 style="margin-top: 10px!important;">Bibliography and other resources</h3>
                                  {
                                   spatiumStructor:resourcesManager('seeFurther', $uriShort)
                                   }
                                   {
                                   spatiumStructor:resourcesManager('illustration', $uriShort)
                                   }
                                   
                                   { ""
(:                                   spatiumStructor:displayResourceList('illustration', $decodedUri) :)
                                   }
                                   {"" 
(:                                   spatiumStructor:displayElement('productionType', $decodedUri, (), ()) :)
                                   }
                                   
                                   {spatiumStructor:displayElement('exactMatch', $decodedUri, (), ())}
                                  
                                  { spatiumStructor:displayElement('generalCommentary', $decodedUri, (), ()) }
                                  { spatiumStructor:displayElement('privateCommentary', $decodedUri, (), ()) }
                                  
                           
                              {spatiumStructor:relatedPeople($uriShort)}
                              
                           </div>
                           
                           <div class="tab-pane fade in" id="nav-docs" role="tabpanel" aria-labelledby="nav-docs-tab">
                           <button id="addNewDocToPlaceButton" class="btn btn-sm btn-primary pull-right" appearance="minimal" type="button" 
                           onclick="openDialog('dialogAddNewDocumentToPlace')" style="margin: 0 5px 0 5px;"><i class="glyphicon glyphicon-plus"></i></button>
                            { $docs}
                           </div>
                        
                        <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
                             { spatiumStructor:xmlFileEditorWithUri($uri) }
                                                 
                         </div>
                         </div>
                         <script>console.log("Editor required");
var editor4File = ace.edit("xml-editor-file");
      editor4File.session.setMode("ace/mode/xml");
      editor4File.setOptions({{
            minLines: 40,
            maxLines: Infinity}});
            
 function getXmlEditorContent(){{
        var xmlFileEditor = ace.edit("xml-editor-file");
        return xmlFileEditor.getValue();
         
 }};           
</script>
   </div>)
   else
   ( <div class="jumbotron jumbotron-fluid">
                        <div class="container">
                          <h1 class="display-4">Error!</h1>
                          <p class="lead">There is no place with URI { $uriShort }</p>
                        </div>
                      </div>)
 };



declare function spatiumStructor:displayAndEditLabel($placeUri as xs:string,
                                                $labelValue as xs:string,
                                                $elementName as xs:string,
                                                $lang as xs:string,
                                                $userRights as xs:string,
                                                $index as xs:int){
     
     let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]))) 
                then $spatiumStructor:placeElements//xmlElement[nm=$elementNickname] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]
       (:     let $elementNode := $spatiumStructor:placeElements//xmlElement[nm=$elementName]:)
        
        
        return
            <div>
            <div id="{$elementName}_{$lang}_display_{$index}_" class="">
                            <div id="{$elementName}_{$lang}_value" class="xmlElementValue">{$labelValue} ({$lang})
                            <button id="edit_{$elementName}_{$lang}" class="btn btn-primary transparentButton"
                                onclick="editValue('{$elementName}_{$lang}', {$index}, '')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-edit"></i></button>
                             <button id="delete_{$elementName}_{$lang}" class="btn btn-primary  transparentButton"
                                onclick="deleteLabel('{$elementName}', '{$placeUri}', '{$lang}', {$index}, '{$labelValue}')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-trash"></i></button>
                                </div>
                        </div>


                        <div id="{$elementName}_{$lang}_edit_{$index}_" class="xmlElementHidden form-group">
                            <div class="input-group" >
                                <input id="{$elementName}_{$lang}_lang_input" class="form-control langInput" name="altLabel_{$lang}_lang_input" value="{$lang}"></input>                               
                                <input id="{$elementName}_{$lang}_input" class="form-control" name="altLabel_{$lang}_input" value="{$labelValue}"></input>
                                <button id="{$elementName}_{$lang}SaveButton" class="btn btn-success"
                                    onclick="saveDataSimple('{$placeUri}',  '{$elementName}', '{ $elementNode/xpath/text()}', 'text', '{$index}', '{$index}')"
                                    appearance="minimal" type="button"><i class="glyphicon
                                    glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$elementName}_{$lang}CancelEdit" class="btn btn-danger"
                                    onclick='cancelEdit("{$elementName}", "{$index}", "{$labelValue}", "input", "1")'
                                    appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

                            </div>
                         </div>
           </div>
};
declare function spatiumStructor:addAltLabelButton($uriShort as xs:string){

        <div>
            <button id="addAltLabelButton" class="smallRoundButton pull-right" appearance="minimal" type="button" onclick="openDialog('dialogInsertAltLabel')"><i class="glyphicon glyphicon-plus"> </i></button>

          <div id="dialogInsertAltLabel" title="Add a Alternative Term" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">

                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"><i class="glyphicon glyphicon-remove-circle" /></button>
                    <h4 class="modal-title">Add a new alternative term</h4>
                </div>
                <div class="modal-body">
                            <div class="input-group">
                                <span class="input-group-addon" id="newAltLabelEnLabel">EN</span>
                                <input id="newAltLabelEn" name="newAltLabelEn" type="text" class="form-control" placeholder="Alternative term in English" aria-describedby="newAltLabelEnLabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="newAltLabelDeLabel">DE</span>
                                <input id="newAltLabelDe" name="newAltLabelDe" type="text" class="form-control" placeholder="Alternative term in German" aria-describedby="newAltLabelDeLabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="newAltLabelFrLabel">FR</span>
                                <input id="newAltLabelFr" name="newAltLabelFr" type="text" class="form-control" placeholder="Alternative term in French" aria-describedby="newAltLabelFrLabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="newAltLabelExtraLangLabel">Lang.</span>
                                <input id="newAltLabelExtraLang" name="newAltLabelExtraLang" type="text" class="form-control" placeholder="Enter a language code" aria-describedby="newAltLabelExtraLangLabel"
                                size="2"/>
                                <span class="input-group-addon" id="newAltLabelExtraValueLabel">Value</span>
                                <input id="newAltLabelExtraValue" name="newAltLabelExtraValue" type="text" class="form-control" placeholder="Value" aria-describedby="newAltLabelExtraValueLabel" />
                            </div>


                     <button id="addNewAltLabel" class="btn btn-primary" onclick="addNewAltLabel('{$uriShort}')">Add new Alternative term(s)</button>
                    <div class="form-group modal-footer">



                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                  </div>
                </div>
             </div>



         </div>



        };










declare function spatiumStructor:editorMap($resourceID as xs:string){

<div>
<div id="editorMap"></div>

<script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/spatiumStructor.js"/>
        <link href="$ausohnum-lib/resources/css/spatiumStructor.css" rel="stylesheet" type="text/css"/>

        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.4.0/dist/leaflet.css"
            integrity="sha512-puBpdR0798OZvTTbP4A8Ix/l+A4dHDD0DGqYW6RQ+9jxkRFclaxxQb/SJAWZfWAkuyeQUytO7+7N4QKrDh+drA=="
            crossorigin=""/>
        <!-- Make sure you put this AFTER Leaflet's CSS -->
        <script src="https://unpkg.com/leaflet@1.4.0/dist/leaflet.js"
   integrity="sha512-QVftwZFqvtRNi0ZyCtsznlKSWOStnDORoefr1enyq5mVL4tmKB3S/EnC3rRJcxCPavG10IcrVGSmPh6Qw5lwrg=="
   crossorigin=""></script>
 <script  type="text/javascript" >



 var mymap = L.map('editorMap').setView([41.891775, 12.486137], 4);


L.tileLayer('https://api.tiles.mapbox.com/v4/{{id}}/{{z}}/{{x}}/{{y}}.png?access_token=pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ', {{
 attribution: 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',
 maxZoom: 10,
 id: 'isawnyu.map-knmctlkh',
 accessToken: 'pk.eyJ1IjoiaXNhd255dSIsImEiOiJBWEh1dUZZIn0.SiiexWxHHESIegSmW8wedQ'
 }}).addTo(mymap);

 var geojsonFeature;
$.getJSON("/geo/places/json", function(json){{
    geojsonFeature = json;
    L.geoJSON(geojsonFeature).addTo(mymap);
}});




 </script>
</div>
};


declare function spatiumStructor:placesManagerInDoc($placeId){
        <div class="row">
                 <div class="sideToolPane col-sm-3 col-md-3 col-lg-3">
                 <div>
                         <span class="subSectionTitle">List of places linked to this doc (<span class="docPlacesDot"></span> on the map):</span>
                         <div id="listOfPlaces">

                          </div>
                     </div>

                      <div id="placeLookUpPanel" class="sectionInPanel"><span class="subSectionTitle">Add a new place</span>
                             <div class="form-group">

                                    <label for="placesLookupInputDocPlaces">Search in <a href="http://pelagios.org/peripleo/map" target="_blank">Pelagios Peripleo</a></label>
                                     <input type="text" class="form-control"
                                     id="placesLookupInputDocPlaces"
                                     name="placesLookupInputDocPlaces"
                                     />
                              </div>
                       <div class="">

                                     <button id="addNewPlaceButtonDocPlaces " class="btn btn-success hidden" onclick="addPlaceToDoc('{$spatiumStructor:placeId}')" appearance="minimal" type="button">Add place to document<i class="glyphicon glyphicon glyphicon-saved"></i></button>
                         </div>
                   </div>
                   </div>

                   <div id="editorMap"/>

               </div>
};


declare function spatiumStructor:peripleoLookUp( $placeId ){
        <div class="row">
                 <div class="sideToolPane col-sm-3 col-md-3 col-lg-3">

                      <div id="placeLookUpPanel" class="sectionInPanel">
                             <div class="form-group">

                                    <label for="placesLookupInputDocPlaces">Search in <a href="http://pelagios.org/peripleo/map" target="_blank">Pelagios Peripleo</a></label>
                                     <input type="text" class="form-control"
                                     id="placesLookupInputDocPlaces"
                                     name="placesLookupInputDocPlaces"
                                     />
                              </div>
                       <div class="">
                             <iframe id="placesLookupInputDocPlaces_peripleoWidget" allowfullscreen="true" height="380" src="" style="display:none;"> </iframe>
                                     <div id="previewMapDocPlaces" class="hidden"/>
                                     <div id="placePreviewPanelDocPlaces" class="hidden"/>
                                     <button id="addNewPlaceButtonDocPlaces " class="btn btn-success hidden" onclick="addPlaceToDoc('{$spatiumStructor:placeId}')" appearance="minimal" type="button">Add place to document<i class="glyphicon glyphicon glyphicon-saved"></i></button>
                         </div>
                   </div>
                   </div>


 <script  type="text/javascript" >
<!--
$( document ).ready(function() {


 });

-->


 </script>

               </div>
};









declare function spatiumStructor:getProjectPlaces($format as xs:string) {
(:let $placeCollection := collection("/db/apps/" || $spatiumStructor:project || "Data/places" || "/" ||  $spatiumStructor:project ):)
    let $places := <places>{ collection("/db/apps/" || $spatiumStructor:project || "Data/places" || "/" ||  $spatiumStructor:project )/node() }</places>
    let $paramMap :=
        switch($format)
            case "2json2" return
                <output:serialization-parameters>
                <output:method>json</output:method>
                <output:indent>true</output:indent>
                <output:mediatype>text/javascript</output:mediatype>

               </output:serialization-parameters>
            case "json" return
                map {
                "method": "json",
                "media-type" : "text/javascript"
                }
            case "xml" return
                map {
                "method": "xml",
                "indent": true()}
             default return map {
                "method": "json",
                "media-type" : "text/javascript"
                }

let $places2GeoJSon :=
                <root json:array="true" type="FeatureCollection">
        {
        
    for $place in $places//spatial:Feature
                         let $coordinates :=
                                if($place//pleiades:Place/geo:long) then <coordinates><long>{ $place//pleiades:Place/geo:long }</long><lat>{ $place//pleiades:Place/geo:long }</lat></coordinates> 
                                else (
                                let $relatedPlaceWithCoordinates :=
                                       for $relatedPlace in $place//spatial:P
                                           let $relatedPlaceUri := data($relatedPlace/@rdf:resource)
                                              return
                                              $place//spatial:Feature[@rdf:about=$relatedPlaceUri || "#this"][foaf:primaryTopicOf/pleiades:Place//geo:long]
                                let $lat := $relatedPlaceWithCoordinates[1]//pleiades:Place//geo:lat/text()
                                let $long := $relatedPlaceWithCoordinates[1]//pleiades:Place//geo:long/text()
                                return
                                    <coordinates><long>{ $long }</long><lat>{ $lat }</lat></coordinates>
                                )
               
        return
        
                <features type="Feature">
                                <properties>
                                    <name>{ $place//pleiades:Place/dcterms:title/text() }</name>
                                    <uri>{data($place//pleiades:Place/@rdf:about)}</uri>
                                    <id>{encode-for-uri(data($place//pleiades:Place/@rdf:about))}</id>
                                    <placeType>{ $place//pleiades:Place/pleiades:hasFeatureType[@type="main"]/text() }</placeType>
                                    <amenity></amenity>
                                    <popupContent>a                                    
                                    </popupContent>
                                    
                                 </properties>
                                 <style>
                                     <fill>red</fill>
                                     <fill-opacity>1</fill-opacity>
                                     </style>
                                 <geometry>
                                 <type>Point</type>
                                 { if($place//pleiades:Place/geo:long) then
                                 <coordinates json:array="true" json:literal="false">{ data($place//pleiades:Place/geo:long)}</coordinates>
                                 else(<coordinates json:array="true" json:literal="false">{ $coordinates//long/text() }</coordinates>)
                                 }
                                 {
                                 if($place//pleiades:Place/geo:lat) then
                                 <coordinates json:array="true" json:literal="false">{ data($place//pleiades:Place/geo:lat)}</coordinates>
                                 else(
                                 <coordinates json:array="true" json:literal="false">{ $coordinates/lat/text() }</coordinates>
                                 )
                                 }
                                 </geometry>
                                 </features>
                                 
                                 }
                  
             </root>

return
(serialize($places2GeoJSon, <output:serialization-parameters>
                <output:method>json</output:method>
                <output:indent>true</output:indent>
                <output:mediatype>text/javascript</output:mediatype>

               </output:serialization-parameters>)
)
};
declare function spatiumStructor:getDocumentPlaces($docID as xs:string) as xs:string{

    let $placeRefsInDoc := collection("/db/apps/" || $spatiumStructor:project || "Data/documents" )/id($docID)//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace
    let $placeCollection := collection("/db/apps/" || $spatiumStructor:project || "Data/places" || "/" ||  $spatiumStructor:project )

    let $places :=
                                 <places>{ for $place in $placeRefsInDoc//tei:place
                                        let $projectPlaceUri := 
                                                let $splitRef := tokenize(data($place/tei:placeName/@ref), " ")
                                                return 
                                                    for $uri in $splitRef
                                                    return
(:                                                          string-join($uri, "-->"):)
                                                    if(matches($uri, $spatiumStructor:uriBase)) then 
                                                    normalize-space($uri[1]) else ()
                                            
                                return
                                $spatiumStructor:placeCollection//spatial:Feature[@rdf:about=$projectPlaceUri || "#this"]}</places>


    let $paramMap :=map {
                "method": "json",
                "media-type" : "text/javascript"
                }

let $places2GeoJSon :=
                <root json:array="true" type="FeatureCollection">{
                    if($places/node()) then
                                        (
                                        for $place in $places//spatial:Feature
                                        let $coordinates :=
                                                if($place//pleiades:Place/geo:long) then <coordinates><lat>{ $place//pleiades:Place/geo:long }</lat><long>{ $place//pleiades:Place/geo:long }</long></coordinates> 
                                                else (
                                                let $relatedPlaceWithCoordinates :=
                                                       for $relatedPlace in $place//spatial:P
                                                           let $relatedPlaceUri := data($relatedPlace/@rdf:resource)
                                                              return
                                                              $placeCollection//spatial:Feature[@rdf:about=$relatedPlaceUri || "#this"][foaf:primaryTopicOf/pleiades:Place//geo:long]
                                                let $lat := $relatedPlaceWithCoordinates[1]//pleiades:Place//geo:lat/text()
                                                let $long := $relatedPlaceWithCoordinates[1]//pleiades:Place//geo:long/text()
                                                return
                                                    <coordinates><long>{ $long }</long><lat>{ $lat }</lat></coordinates>
                                                )
                                                
                                return
                                <features type="Feature">
                                                <properties>
                                                    <name>{ $place//pleiades:Place/dcterms:title/text() }</name>
                                                    <uri>{data($place//pleiades:Place/@rdf:about)}</uri>
                                                    <id>{encode-for-uri(data($place/pleiades:Place/@rdf:about))}</id>
                                                    <placeType>{ $place//pleiades:Place/pleiades:hasFeatureType[@type="main"]/text() }</placeType>
                                                    <amenity></amenity>
                                                    <popupContent>                                    
                                                    </popupContent>
                                                 </properties>
                                                 <style>
                                                     <fill>red</fill>
                                                     <fill-opacity>1</fill-opacity>
                                                     </style>
                                                 <geometry>
                                                 <type>Point</type>
                                                 {
                                                 if($place//pleiades:Place/geo:long) then
                                                 <coordinates json:array="true" json:literal="false">{ data($place//pleiades:Place/geo:long)}</coordinates>
                                                 else(<coordinates json:array="true" json:literal="false">{ $coordinates//long/text() }</coordinates>)
                                                 }
                                                 { if($place//pleiades:Place/geo:lat) then
                                                 <coordinates json:array="true" json:literal="false">{ data($place//pleiades:Place/geo:lat)}</coordinates>
                                                 else(
                                                 <coordinates json:array="true" json:literal="false">{ $coordinates/lat/text() }</coordinates>
                                                 )
                                                 }</geometry>
                                                 </features>
                                              )
                                             else
                                        (
                                        <features type="Feature">
                                                <properties>
                                                    <name>No place is attached to this document</name>
                                                    <uri></uri>
                                                    <id></id>
                                                    <placeType></placeType>
                                                    <amenity></amenity>
                                                    <popupContent>                                    
                                                    </popupContent>
                                                 </properties>
                                                 <style>
                                                     <fill>red</fill>
                                                     <fill-opacity>1</fill-opacity>
                                                     </style>
                                                 <geometry>
                                                 <type>Point</type>
                                                 <coordinates json:array="true" json:literal="false"></coordinates>
                                                 
                                                 <coordinates json:array="true" json:literal="false"></coordinates>
                                                 
                                                 </geometry>
                                                 </features>
                      )}</root>
                                
return
(:<result> { $places}</result>:)
serialize($places2GeoJSon, $paramMap)

};
declare function spatiumStructor:relatedDocuments($uri as xs:string){
(:        let $resourcePerson := $spatiumStructor:peopleCollection//lawd:person[@rdf:about=$uri ||"#this"]:)
        (:let $docs := $spatiumStructor:doc-collection//tei:TEI[descendant-or-self::tei:listPlace//tei:place[functx:contains-word(tei:placeName/@ref || " ", $uri || " ")]]
                            |$spatiumStructor:doc-collection//tei:TEI[descendant-or-self::tei:history/tei:origin/tei:origPlace[functx:contains-word(./@ref || " ", $uri || " ")]]
                            |$spatiumStructor:doc-collection//tei:TEI[descendant-or-self::tei:history/tei:origin//tei:placeName[functx:contains-word(./@ref || " ", $uri || " ")]]:)
(:          Afunctx:any-word takes more time:)
          let $docs := $spatiumStructor:doc-collection//tei:TEI[descendant-or-self::tei:listPlace//tei:place[functx:contains-any-of(tei:placeName/@ref || " ", $uri || " ")]]
            |$spatiumStructor:doc-collection//tei:TEI[descendant-or-self::tei:history/tei:origin/tei:origPlace[functx:contains-any-of(./@ref || " ", $uri || " ")]]
            |$spatiumStructor:doc-collection//tei:TEI[descendant-or-self::tei:history/tei:origin//tei:placeName[functx:contains-any-of(./@ref || " ", $uri || " ")]]                   
        return $docs
};
declare function spatiumStructor:relatedDocuments($uri as xs:string, $project as xs:string){
(:        let $resourcePerson := $spatiumStructor:peopleCollection//lawd:person[@rdf:about=$uri ||"#this"]:)
        let $collection := collection("/db/apps/" || $project || "Data/documents")
        (:let $docs := $collection//tei:TEI[descendant-or-self::tei:listPlace//tei:place[functx:contains-word(tei:placeName/@ref, $uri)]]
                            |$collection//tei:TEI[descendant-or-self::tei:origPlace[functx:contains-word(./@ref, $uri)]]:)
        let $docs := $collection//tei:TEI[descendant-or-self::tei:listPlace//tei:place[functx:contains-any-of(tei:placeName/@ref || " ", $uri || " ")]]
|$collection//tei:TEI[descendant-or-self::tei:history/tei:origin/tei:origPlace[functx:contains-any-of(./@ref || " ", $uri || " ")]]
        return $docs
};
declare function spatiumStructor:relatedPeople($uri as xs:string){
(:let $teiDoc := $teiEditdor:doc-collection/id($docId):)
let $teiDoc :=  spatiumStructor:relatedDocuments($uri)
let $peopleRelatedToPlace := $spatiumStructor:peopleCollection//lawd:person[.//apc:hasFunction[@target = $uri]]
let $mentionedPeople :=
<div class="xmlElementGroup">
                         <span class="subSectionTitle">People mentioned in documents linked to this place</span>
                         {if(count($teiDoc//tei:profileDesc/tei:listPerson[@type="peopleInDocument"]//tei:person) >10 ) then (
                         <div>These are the 10 first people of the 10 first documents on {count($teiDoc//tei:profileDesc/tei:listPerson[@type="peopleInDocument"]//tei:person)} in total</div>)
                         else()}
                         <div id="listOfPeople">
                         {if ($teiDoc) then
                         (
                    <ul>{for $person in $teiDoc[position() < 11]//tei:profileDesc/tei:listPerson[@type="peopleInDocument"]//tei:person[position() <11]
                                let $personUris := $person/@corresp
                                let $personUriInternal :=
                                    for $uri in tokenize($personUris, " ")
                                    return 
                                        if (matches($uri, $teiEditor:project)) then $uri else ()
                                let $personDetails := $teiEditor:peopleCollection//apc:people[@rdf:about=$personUriInternal]        
                                let $personStatus := $personDetails//apc:personalStatus/text()
                                let $persName := 
                                        if($personDetails//lawd:personalName[@xml:lang='en'])
                                            then $personDetails//lawd:personalName[@xml:lang='en']/text()
                                        else $personDetails//lawd:personalName[1]/text()
                                        order by $person/tei:persName
                                        return
                                        <li><a href="{ $personUriInternal }" title="Open details of { $personUriInternal }">{$persName}</a>
                                        <span>[{ $personDetails//apc:juridicalStatus/text()}]</span>
                                        <span>[{ $personDetails//apc:personalStatus/text()}]</span>
                                        <a href="{ $personUriInternal }" title="Open details of { $personUriInternal } in a new tab" target="_blank">
                               <i class="glyphicon glyphicon-new-window"/></a>
                                        <span class="pull-right"><span class="glyphicon glyphicon-hand-right"/><a href="{data($person/ancestor::tei:TEI//tei:idno[@type='uri'])}" title="Document {data($person/ancestor::tei:TEI//tei:idno[@type='uri'])}" target="_blank"><span class="glyphicon glyphicon-file"/></a></span>
                                            <!--
                                            <i class="glyphicon glyphicon-trash" title="Remove place from list"/>
                                            -->
                                        </li>
                    }</ul>)
                else (<em>None</em>)}</div>
    </div>
    
 let $relatedPeople :=
 <div class="xmlElementGroup">
                         <span class="subSectionTitle">People with a particular relation to this place</span>
                         
                         <div id="listOfPeople">
                         {if ($peopleRelatedToPlace) then
                         (
                    <ul>{for $person in $peopleRelatedToPlace
                                let $personUri := $person/@rdf:about
(:                                let $personStatus := $personDetails//apc:personalStatus/text():)
                                let $persName := 
                                        if($person//lawd:personalName[@xml:lang='en'])
                                            then $person//lawd:personalName[@xml:lang='en']/text()
                                        else $person//lawd:personalName[1]/text()
                                   let $function := for $function in $person//apc:hasFunction[@target = $uri]
                                            let $functionUri := data($function/@rdf:resource)
                                            return string-join(skosThesau:getLabel($functionUri, $spatiumStructor:lang), ", ")
                                        order by $persName
                                        return
                                        <li><a href="{ $personUri }" title="Open details of { $personUri }">{$persName}</a>
                                        <span>[{ $function }]</span>
                                        
                                      
                                            <!--
                                            <i class="glyphicon glyphicon-trash" title="Remove place from list"/>
                                            -->
                                        </li>
                    }</ul>)
                else (<em>None</em>)}</div>
    </div>
    
    return <div>{ $mentionedPeople}{$relatedPeople }</div>
 };

declare function spatiumStructor:relatedPeopleList($uri as xs:string){
(:let $teiDoc := $teiEditdor:doc-collection/id($docId):)
let $teiDoc :=  spatiumStructor:relatedDocuments($uri)
let $peopleInDocs := $teiDoc//tei:profileDesc/tei:listPerson[@type="peopleInDocument"]
let $peopleRelatedToPlace := $spatiumStructor:peopleCollection//lawd:person[.//apc:hasFunction[@target = $uri]]

let $mentionedPeople :=
<people type="linkedByDocuments" number="{count($teiDoc//tei:profileDesc/tei:listPerson[@type="peopleInDocument"]//tei:person)}">
        {if ($teiDoc) then
                    (:for $person in $teiDoc//tei:profileDesc/tei:listPerson[@type="peopleInDocument"]//tei:person:)
                    for $person in functx:distinct-deep($peopleInDocs//tei:person)
                                let $personUris := $person/@corresp
                                let $personUriInternal :=
                                            for $uri in tokenize($personUris, " ")
                                                return if (matches($uri, $teiEditor:project)) then $uri else ()
                                let $personDetails := $teiEditor:peopleCollection//apc:people[@rdf:about=$personUriInternal]        
                                let $juridicalStatus := skosThesau:getLabel($personDetails//apc:juridicalStatus/@rdf:resource, $teiEditor:lang)
                                let $personStatus := skosThesau:getLabel($personDetails//apc:personalStatus/@rdf:resource, $teiEditor:lang)
                                let $personRank := skosThesau:getLabel($personDetails//apc:socialStatus/@rdf:resource, $teiEditor:lang)
                                let $persName := 
                                        if($personDetails//lawd:personalName[@xml:lang='en'])
                                            then $personDetails//lawd:personalName[@xml:lang='en']/text()
                                        else $personDetails//lawd:personalName[1]/text()
                                
                            order by $person/tei:persName
                            return
                                        <person uri="{ $personUriInternal }">
                                            <docId>{ data($person/ancestor::tei:TEI/@xml:id)}</docId> 
                                            <personalName>{$persName}</personalName>
                                            <juridicalStatus>{ $juridicalStatus }</juridicalStatus>
                                            <personalStatus>{ $personStatus }</personalStatus>
                                            <rank>{ $personRank }</rank>
                                          </person>
                else ()
                    }
                    </people>
 let $relatedPeople :=
    <people type="specificRelation" number="{count($peopleRelatedToPlace)}">
       { if ($peopleRelatedToPlace) then
              (for $person in $peopleRelatedToPlace
                                   let $personUri := $person/@rdf:about
   (:                                let $personStatus := $personDetails//apc:personalStatus/text():)
                                   let $persName := 
                                           if($person//lawd:personalName[@xml:lang='en'])
                                               then $person//lawd:personalName[@xml:lang='en']/text()
                                           else $person//lawd:personalName[1]/text()
                                    let $functions := for $function in $person//apc:hasFunction[@target = $uri]
                                               let $functionUri := data($function/@rdf:resource)
                                               return
                                                (skosThesau:getLabel($functionUri, $spatiumStructor:lang))
                                           order by $persName
                                           return
                                           <person uri="{ $personUri }"><personalName>{$persName}</personalName>
                                                   <function>{ string-join($functions, "; ") }</function>
                                           </person>
                )
                    else()
                    }
    </people>
    
    return
    <data>{ $mentionedPeople}{$relatedPeople }</data>
 };

declare function spatiumStructor:getDocument2Places($docID as xs:string) as xs:string{

    let $placeRefsInDoc := collection("/db/apps/" || $spatiumStructor:project || "Data/documents" )/id($docID)//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace
    let $placeCollection := collection("/db/apps/" || $spatiumStructor:project || "Data/places" || "/" ||  $spatiumStructor:project )
    let $places :=
                                 <places>{ for $place in $placeRefsInDoc//tei:place
                                        let $projectPlaceUri := 
                                                let $splitRef := tokenize(data($place/tei:placeName/@ref), " ")
                                                return 
                                                    for $uri in $splitRef
                                                    return
(:                                                          string-join($uri, "-->"):)
                                                    if(matches($uri, $spatiumStructor:uriBase)) then 
                                                    normalize-space($uri[1]) else ()
                                            
                                return
                                $placeCollection//spatial:Feature[@rdf:about=$projectPlaceUri || "#this"]}</places>
    let $places := <places>{ $placeCollection//spatial:Feature} </places>

    let $paramMap :=

                map {
                "method": "json",

                "media-type" : "text/javascript"
                }

let $places2GeoJSon :=
                <root json:array="true" type="FeatureCollection">{

                        for $place in $places//spatial:Feature
                        let $coordinates :=
                                if($place//pleiades:Place/geo:long) then <coordinates><lat>{ $place//pleiades:Place/geo:long }</lat><long>{ $place//pleiades:Place/geo:long }</long></coordinates> 
                                else (
                                let $relatedPlaceWithCoordinates :=
                                       for $relatedPlace in $place//spatial:P
                                           let $relatedPlaceUri := data($relatedPlace/@rdf:resource)
                                              return
                                              $placeCollection//spatial:Feature[@rdf:about=$relatedPlaceUri || "#this"][foaf:primaryTopicOf/pleiades:Place//geo:long]
                                let $lat := $relatedPlaceWithCoordinates[1]//pleiades:Place//geo:lat/text()
                                let $long := $relatedPlaceWithCoordinates[1]//pleiades:Place//geo:long/text()
                                return
                                    <coordinates><long>{ $long }</long><lat>{ $lat }</lat></coordinates>
                                )
                                
                return
                <features type="Feature">
                                <properties>
                                    <name>{ $place//pleiades:Place/dcterms:title/text() }</name>
                                    <uri>{data($place//pleiades:Place/@rdf:about)}</uri>
                                    <id>{encode-for-uri(data($place/pleiades:Place/@rdf:about))}</id>
                                    <placeType>{ $place//pleiades:Place/pleiades:hasFeatureType[@type="main"]/text() }</placeType>
                                    <amenity></amenity>
                                    <popupContent>                                    
                                    </popupContent>
                                 </properties>
                                 <style>
                                     <fill>red</fill>
                                     <fill-opacity>1</fill-opacity>
                                     </style>
                                 <geometry>
                                 <type>Point</type>
                                 { if($place//pleiades:Place/geo:long) then
                                 <coordinates json:array="true" json:literal="false">{ data($place//pleiades:Place/geo:long)}</coordinates>
                                 else(<coordinates json:array="true" json:literal="false">{ $coordinates//long/text() }</coordinates>)
                                 }
                                 { if($place//pleiades:Place/geo:lat) then
                                 <coordinates json:array="true" json:literal="false">{ data($place//pleiades:Place/geo:lat)}</coordinates>
                                 else(
                                 <coordinates json:array="true" json:literal="false">{ $coordinates/lat/text() }</coordinates>
                                 )
                                 }</geometry>
                                 </features>}</root>

return
(:<result> { $places}</result>:)
serialize($places2GeoJSon, $paramMap)

};


declare function spatiumStructor:getProjectPlacesJSon(){

    let $places := collection("/db/apps/" || $spatiumStructor:project || "Data/places" || "/" ||  $spatiumStructor:project )/node()
    let $paramMap :=
        switch($format)
            case "2json2" return
                <output:serialization-parameters>
                <output:method>{$format}</output:method>
                <output:indent>true</output:indent>
               </output:serialization-parameters>
            case "json" return
                map {
                "method": "json",
                "indent": true()}
            case "xml" return
                map {
                "method": "xml",
                "indent": true()}
             default return null

let $places2GeoJSon :=
                for $place in $places//pleiades:Place

                return

                <place type="feature">
                <properties >
                    <name>{ $place/skos:prefLabel/text() }</name>
                    <popupContent>{ $place/skos:prefLabel/text() }</popupContent>
                </properties>
                 <geometry>
                 <type>Point</type>
                 <coordinates json:array="true">{ number($place/geo:Point/geo:lat)}</coordinates>
                 <coordinates json:array="true" json:value="{ number($place/geo:Point/geo:long)}"/>
                 </geometry>
                </place>

return
(<http:response status="200"> 
                    <http:header name="Cache-Control" value="no-cache"/> 
                </http:response> 
     ),(
<result>

{serialize($places2GeoJSon, $paramMap)}
</result>)
};

declare function spatiumStructor:displayPlaceDetails($placeId as xs:string, $path as xs:string){

    let $place :=  util:eval( "collection('" || $spatiumStructor:project-place-collection-path
                                                              || "')//spatial:Feature[@rdf:about='"
                                                              || $spatiumStructor:baseUri || $path || "#this']" ) 
    
    return
  if (matches($placeId, "root")) then
<div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
         <div class="container">
         <div class="row">
 
<div><h4>You need to be loggued-in with an authorized account to access the Places Manager</h4>
<h5>Go to Project's <a href="/">home page</a> before you log-in</h5>
    </div>
    </div>
    </div>
    </div>
      else
      (
        <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
              <div class="container">
                <div class="row">
                    <h4>You need to be loggued-in with an authorized account to access this resource</h4>
                    <h5>Go to Project's <a href="/">home page</a> before you log-in</h5>
                    <h5>{ $spatiumStructor:baseUri || $path || "#this"})</h5>
                 </div>
            </div>      
        </div>
      )
};

declare function spatiumStructor:displayElement($elementNickname as xs:string,
                                          $resourceURI as xs:string?,
                                          $index as xs:int?,
                                          $xpath_root as xs:string?) {
  
  let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]))) 
    then
                        
                        $spatiumStructor:placeElements//xmlElement[nm=$elementNickname] 
                        else $spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]
                        
(:    let $elementNode := $spatiumStructor:placeElements//xmlElement[nm=$elementNickname]:)
    let $elementIndex := if ($index ) then ("[" || string($index) || "]" ) else ("")
    let $fieldType := $elementNode/fieldType/text()
    let $attributeValueType := $elementNode/attributeValueType/text()
    let $conceptTopId := if($elementNode/thesauDb/text()) then
                        substring-after($elementNode/thesauTopConceptURI, '/concept/')
                        else()
    let $xpathRaw := $elementNode/xpath/text()
    let $xpathEnd := if(matches($xpathRaw, "/@"))
            then( functx:substring-before-last($xpathRaw[1], '/') || $elementIndex || "/" || functx:substring-after-last($xpathRaw[1], '/'))
            else($xpathRaw)
    let $elementAncestors := $elementNode/ancestor::teiElement
    let $XPath := if($xpath_root)
                    then
                        $xpath_root || $xpathRaw
                    else
                     if($elementNode/ancestor::teiElement)
                                then
                                    string-join(
                                    for $ancestor at $pos in $elementAncestors
                                    let $ancestorIndex := if($pos = 1 ) then
                                        if($index) then "[" || string($index) || "]" else ("")
                                        else ("")
                                    return
                                    if (matches($ancestor/xpath/text(), '/@'))
                                    then
                                        substring-before($ancestor/xpath/text(), '/@')
                                        || $ancestorIndex
                                        else $ancestor/xpath/text() ||
                                        $ancestorIndex
                                    )
                                 || $xpathEnd
                            else
                        $xpathEnd


    let $elementDataType := $spatiumStructor:placeElements//xmlElement[nm=$elementNickname]/contentType/text()
    let $elementFormLabel := $spatiumStructor:placeElements//xmlElement[nm=$elementNickname]/formLabel[@xml:lang=$spatiumStructor:lang]/text()
(:    let $resourceID := if($resourceID != "") then $resourceID else $spatiumStructor:placeId:)
(:    let $Doc := util:eval("collection('" || $spatiumStructor:project-place-collection-path || "')//.[@rdf:about='" || $resourceURI ||"']"):)
    let $Doc := $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about= $resourceURI]
    (:let $elementValue :=
         (data(
            util:eval("collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='" || $resourceURI ||"']/" || $XPath)))
:)
    return
        switch ($fieldType)
        case "input" return
        spatiumStructor:displayElementCardi($elementNickname, $resourceURI, $index, 'input', $XPath)
        case "textarea" return
        spatiumStructor:displayElementCardi($elementNickname, $resourceURI, $index, 'textarea', $XPath)
        case "combobox" return
        spatiumStructor:displayXmlElementWithThesauCardi($elementNickname, $conceptTopId, $resourceURI, $index, $XPath)
        case "comboboxWithConceptHierarchy" return
        spatiumStructor:displayXmlElementWithThesauCardiWithConceptHierarchy($elementNickname, $conceptTopId, $resourceURI, $index, $XPath)
        case "placePeripleo" return
        spatiumStructor:displayPlaceWithPeripleo($elementNickname, $resourceURI, $index, $XPath)
        case "group" return
         spatiumStructor:displayGroup($elementNickname, $resourceURI, $index, (), $XPath)
        default return spatiumStructor:displayElementCardi($elementNickname, $resourceURI, $index, 'input', $XPath)
};

declare function spatiumStructor:displayElementCardi($elementNickname as xs:string,
             $resourceURI as xs:string?,
             $index as xs:integer?,
             $type as xs:string?,
             $xpath_root as xs:string?) {

        let $currentResourceURI := if($resourceURI != "") then $resourceURI else  $spatiumStructor:placeId
        let $indexNo := if($index) then data($index) else "1"
        let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]))) 
                then $spatiumStructor:placeElements//xmlElement[nm=$elementNickname] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]
        
(:        let $elementNode := $spatiumStructor:placeElements//xmlElement[nm=$elementNickname]:)
        let $elementIndex := if($elementNode/ancestor::xmlElement)
                    then ""
                    else if
                        ($index) then ("[" || string($index) || "]" ) else ("")

        let $xpathEnd := if(matches($elementNode//xpath[1]/text(), "/@"))
            then(functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/"
            || functx:substring-after-last($elementNode//xpath/text(), '/')
            )
            else (
            $elementNode/./xpath/text()
            )
       let $elementAncestors := $elementNode/ancestor::xmlElement
    let $XPath :=
                if($xpath_root) then $xpath_root
                
                else if($elementNode/ancestor::xmlElement)
                        then
                                    string-join(
                                    for $ancestor at $pos in $elementAncestors
                                    let $ancestorIndex := if($pos = 1 ) then
                                        if($index) then "[" || string($index) || "]" else ("")
                                        else ("")
                                    return
                                    if (matches($ancestor/xpath/text(), '/@'))
                                    then
                                        substring-before($ancestor/xpath/text(), '/@')
                                        || $ancestorIndex
                                        else $ancestor/xpath/text() ||
                                        $ancestorIndex
                                    )
                                 || $xpathEnd
                else
                                    $xpathEnd




     let $xpathBaseForCardinalityX :=
            if (matches($XPath, "/@")) then
            (functx:substring-before-last(functx:substring-before-last($XPath, "/@"), '/'))

(:            (functx:substring-before-last($XPath, "/@")):)

            else
                (""||functx:substring-before-last($XPath, '/')||"")

     let $selectorForCardinalityX :=
            if (matches($XPath, "/@")) then
            (functx:substring-after-last(functx:substring-before-last($XPath, "/@"), "/"))
            else
                (functx:substring-after-last($XPath, "/"))
let $xpathSingleQuote := replace($XPath, '"', "'")
    let $contentType :=$elementNode/contentType/text()
    let $elementDataType := $elementNode/contentType/text()
    let $elementFormLabel := $elementNode/formLabel[@xml:lang=$spatiumStructor:lang]/text()
    let $elementCardinality := $elementNode/cardinality/text()
    let $attributeValueType := $elementNode/attributeValueType/text()

(:    let $Doc := $spatiumStructor:place-collection/id($spatiumStructor:docId):)

    let $elementValue :=
        if($elementCardinality = "1" ) then (
                    util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"||$currentResourceURI ||"']/" || $XPath ))
        
        
        else if($elementCardinality = "x" ) then
                    (
                                if($contentType != "attribute") then
                                            (  util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"
                                              ||$currentResourceURI
                                              ||"']/"
                                           || $xpathBaseForCardinalityX || "/" || $selectorForCardinalityX )
                                           )

                                        else
                                            ( 
                                            util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"
                                                        ||$currentResourceURI
                                                        ||"']/"
                                                     || $xpathBaseForCardinalityX  || "/" || $selectorForCardinalityX)
                                           )
                    )

                     else(
                     util:eval( "collection('" || $spatiumStructor:project-place-collection-path
                     ||"')//spatial:Feature[@rdf:about='"||$currentResourceURI ||"']/" || $XPath ))


  
    let $valuesTotal := count($elementValue)
    (:let $data2display :=
    if($elementCardinality = "1" ) then ( "e"||
        data(util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//.[@rdf:about='" || $elementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))
        ) else():)
    let $inputName := 'selectDropDown' (:||$topConceptId:)

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $spatiumStructor:project || "/data/documents')//id('"||$spatiumStructor:docId
                    ||"')/"
                    || functx:substring-before-last($XPath2Ref, '/') || "//tei:category"):)
    return

        (
        if($elementCardinality ="1") then

        (
                let $elementAttributeValue :=
                  (data(util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"||$currentResourceURI ||"']/" || $XPath)))
             let $elementTextNodeValue :=
                     if($elementDataType = "textNodeAndAttribute" ) then
                    (data(util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"||$currentResourceURI ||"']/" || substring-before($XPath, '/@'))))
(:                  ANCIENNE VERSION"là" || (serialize(functx:change-element-ns-deep(util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//id('" ||$spatiumStructor:docId ||"')/" || substring-before($XPath, '/@')), "", ""))):)
                   else
                  (serialize(functx:change-element-ns-deep(util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"||$currentResourceURI ||"']/" || $XPath || "/node()"), "", "")))
        
        let $codeLang :=   
                if($elementNode/xmlLang/text() ="true")
                    then
                     (data(util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"||$currentResourceURI ||"']/" || substring-before($XPath, '/@')/@xml:lang)))
                    else ()
      let $xpathSingleQuote := replace($XPath, '"', "'")       
             return

                 <div id="{$elementNickname}_group_1" class="xmlElementGroup">
                 <div id="{$elementNickname}_display_{$indexNo}_1" class="">
                 <div class="{switch($type)
                                        case 'textarea' return 'xmlElementGroupHeader'
                                        default return 'xmlElementGroupHeaderInline'
                                        }">
                 <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                     <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                     </div>
                     <div id="{$elementNickname}_value_{$indexNo}_1" class="xmlElementValue" style="{if($type= "textarea") then "width: 100%;" else ()}">
                     {switch ($elementDataType)
                             case "text" return $elementTextNodeValue || $codeLang
                             case "enrichedText" return
                                        (<div style="float:left; width: 100%;">
                                               <textarea id="{$elementNickname}_{$indexNo}_1" class="form-control summernote" name="{$elementNickname}_{$indexNo}_1">{ $elementTextNodeValue }</textarea>
                                               <span id="{$elementNickname}_{$indexNo}_1_message"/>
                                            <script>
                                                           
                                                         $('#{$elementNickname}_{$indexNo}_1').summernote(
                                                               //'pasteHTML', markupStr,
                                                         {{
                                                         toolbar: [
                                                           ['style', ['style']],
                                                           ['font', ['italic','bold','underline','clear']],
                                                           //['para', ['ul','ol','paragraph']],
                                                           ['insert', ['link']],
                                                           ['view', ['fullscreen','codeview','help']],
                                                             ],
                                                       
                                                            callbacks: {{
                                                              onChange: function(){{
                                                              $("#{$elementNickname}_{$indexNo}_1_message").css("display", "block");
                                                                $("#{$elementNickname}_{$indexNo}_1_message").html("Text modified and not saved...");
                                                                $("#{$elementNickname}_{$indexNo}_1_message").css('background-color', '#ffaa99');
                                                              }},
                                                              onBlur: function(contents, $editable) {{
                                                              $("#{$elementNickname}_{$indexNo}_1_message").css("display", "block");
                                                                $("#{$elementNickname}_{$indexNo}_1_message").html("Saving text...");
                                                                $("#{$elementNickname}_{$indexNo}_1_message").css('background-color', '#e6f4ff');
                                                                saveTextarea('{$currentResourceURI}', '{$elementNickname}_{$indexNo}_1', 
                                                                    '{$elementNickname}', '{replace($XPath, "'", "&quot;")}', {$indexNo})
                                                              }}
                                                            }}
                                                          }}
                                                       );
                                                       
                                               </script>
                                               </div>
                                         )
                             case "attribute" return $elementAttributeValue
                             case "textNodeAndAttribute" return
                                 (<span>{$elementTextNodeValue}
                                 <a href="{$elementTextNodeValue}" target="_blank" class="urlInxmlElement">{$elementAttributeValue}</a></span>)
                             default return "Error; check type of field"
                     }</div>
                      {switch ($elementDataType)
                                case "enrichedText" return
                                      <button id="saveTextareaButton{$indexNo}" class="saveTextareaButton btn btn-primary" onclick="saveTextarea('{$currentResourceURI}', '{$elementNickname}_{$indexNo}_1', 
                                      '{$elementNickname}', '{replace($XPath, "'", "&quot;")}', {$indexNo})" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
                                default return 
                                        <button id="edit{$elementNickname}_{$indexNo}_1" class="btn btn-primary editbutton"
                                         onclick="editValue('{$elementNickname}', '{$indexNo}', '1')"
                                                appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                                          editConceptIcon"></i></button>
                             }
                 </div>

                 <div id="{$elementNickname}_edit_{$indexNo}_1" class="xmlElementHidden form-group">
                 <div class="input-group" >
                 <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                     <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                         {switch ($type)
                          case "input" return
                             switch ($elementDataType)
                             case "text" case "attribute" return
                             <input id="{$elementNickname}_{$indexNo}_1" class="form-control" name="{$elementNickname}_{$indexNo}_1" value="{$elementAttributeValue}"></input>
                             case "textNodeAndAttribute" return
                             <div>
                             <span>Value of <em>Attribute</em> {functx:substring-after-last($XPath, '/')}</span><input id="{$elementNickname}_text_{$indexNo}_1" class="form-control" name="{$elementNickname}_text_{$indexNo}_1" value="{ $elementAttributeValue }"></input>
                             <span> Value of <em>Node Text</em></span><input id="{$elementNickname}_attrib_{$indexNo}_1" class="form-control" name="{$elementNickname}_attrib_{$indexNo}_1" value="{ $elementTextNodeValue }"></input>
                             </div>
                             default return "Error! Cannot get value"

                          case "textarea" return
                          <textarea id="{$elementNickname}_{$indexNo}_1" class="form-control" name="{$elementNickname}_{$indexNo}_1">{$elementTextNodeValue}</textarea>
                          default return null
                          }
                         <button id="{$elementNickname}SaveButton" class="btn btn-success"
                         onclick="saveDataSimple('{$currentResourceURI}', '{$elementNickname}', '{ $XPath }',
                             '{$elementDataType}', '{$indexNo}', '{$elementCardinality}')"
                                 appearance="minimal" type="button"><i class="glyphicon
         glyphicon glyphicon-ok-circle"></i></button>
                         
                         <button id="{$elementNickname}CancelEdit" class="btn btn-danger"
                         onclick='cancelEdit("{$elementNickname}", "1", "{$elementTextNodeValue}", "input", "1")'
                                 appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                    
                 </div></div>
                 </div>
        )
(:        Cardinality > 1:)
        else
        
        <div id="{$elementNickname}_group_{$indexNo}" class="xmlElementGroup">
        <div class="xmlElementGroupHeaderBlock">
        <span class="labelForm">{$elementFormLabel}<span class="xmlInfo">
                    <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                    </span></span>

                    { if($elementCardinality ="x") then
                    <button id="{$elementNickname}addItem_{$indexNo}" class="btn btn-primary addItem"
                        onclick="addItem(this, '{ $inputName }_add_{ $indexNo }', '{ $indexNo }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>
                  else()
                   }
              </div>
              {
              for $item at $pos in $elementValue
                    
                let $elementAttributeValue := 
                                        if ($elementDataType = "attribute") then 
                                                (data(util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"||$currentResourceURI ||"']/"
                                                || $xpathBaseForCardinalityX|| "/" || $selectorForCardinalityX || "[" || $pos || "]/" || functx:substring-after-last($XPath, '/')  )))
                                        else()        
                                                
                let $elementTextNodeValue := if($elementDataType = "textNodeAndAttribute") then 
                                        $item/text()
(:                                        (data(util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//.[@rdf:about='"||$currentResourceURI ||"']/" || substring-before($XPath, '/@') || "[" || $pos || "]" ))):)
                                        else if ($elementDataType = "attribute") then $elementAttributeValue
                                        else($item/text())
                let $codeLang :=   
                if($elementNode/xmlLang/text() ="true")
                    then 
                    (
 data($item/@xml:lang) 
                    )
                    
                     (:(
                     data(
                            util:eval( 
                                "collection('" || $spatiumStructor:project-place-collection-path || "')//.[@rdf:about='"||$currentResourceURI ||"']/" || substring-before($XPath, '/@')
                                )
                            )
                     ):)
                    else ()
        
              return
              (
              <div class="xmlElementGroup">
                              
                    <div id="{$elementNickname}_display_{$indexNo}_{$pos}" class="">
                         
                        <div id="{$elementNickname}_value_{$indexNo}_{$pos}" class="xmlElementValue">
                        {if($contentType = "textNodeAndAttribute") then ( <div>{$elementTextNodeValue }  <a href="{$elementAttributeValue}" target="_blank" class="urlInxmlElement">{$elementAttributeValue}</a></div>)
                        else if($contentType = "attribute") then ( <a href="{$elementAttributeValue}" target="_blank" class="urlInxmlElement">{$elementAttributeValue}</a>)
                        else (<div> { $elementTextNodeValue  } <a href="{$elementAttributeValue}" target="_blank" class="urlInxmlElement">{$elementAttributeValue}</a></div>)
                        
                        
                        }
                        {
                        if($codeLang) then " (" || $codeLang || ")" else ()} </div>
                        
                        
                        <button id="edit{$elementNickname}_{$indexNo}_{$pos}" class="btn btn-primary editbutton"
                         onclick="editValue('{$elementNickname}', '{$indexNo}', {$pos})"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                          editConceptIcon"></i></button>
                       <a class="removeItem" onclick="removeItem('{$currentResourceURI}', '{$elementNickname}', 
                        '{$xpathBaseForCardinalityX}', '{ $selectorForCardinalityX }', {$pos})"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>

                    </div>

        <div id="{$elementNickname}_edit_{$indexNo}_{$pos}" class="xmlElementHidden form-group">
        <div class="input-group" >
        <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
            <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>
                        {
                        if($codeLang) then " (" || $codeLang || ")" else ()} 
                {switch ($type)
                 case "input" return
                    switch ($elementDataType)
                    case "text" return

                    <input id="{$elementNickname}_{$indexNo}_{$pos}" class="form-control" name="{$elementNickname}_{$indexNo}_{$pos}" value="{$elementTextNodeValue}"></input>

                    case "textNodeAndAttribute" return

                            <div>
                            <div class="input-group">
                            <span class="input-group-addon" id="{$elementNickname}_text_{$indexNo}_{$pos}_addon">Text</span>

                            <input id="{$elementNickname}_text_{$indexNo}_{$pos}" class="form-control" name="{$elementNickname}_text_{$indexNo}_{$pos}" value="{ $elementTextNodeValue  }" aria-describedby="{$elementNickname}_text_{$index}_{$pos}_addon"></input>
                            </div>

                            <div class="input-group">
                            <span class="input-group-addon" id="{$elementNickname}_attrib_{$index}_{$pos}_addon">{functx:substring-after-last($XPath, '/')}</span>
                                <input id="{$elementNickname}_attrib_{$indexNo}_{$pos}" class="form-control" name="{$elementNickname}_attrib_{$indexNo}_{$pos}" value="{ $elementAttributeValue }" aria-describedby="{$elementNickname}_attrib_{$indexNo}_{$pos}_addon"></input>
                            </div>
                            </div>
                        case "attribute" return

                            <div>
                                <div class="input-group">
                                <span class="input-group-addon" id="{$elementNickname}_attrib_{$index}_{$pos}_addon">{functx:substring-after-last($XPath, '/')}</span>
                                <input id="{$elementNickname}_attrib_{$indexNo}_{$pos}" class="form-control" name="{$elementNickname}_attrib_{$indexNo}_{$pos}" value="{ $elementAttributeValue }" aria-describedby="{$elementNickname}_attrib_{$indexNo}_{$pos}_addon"></input>
                            </div>
                            </div>
                    default return "Error! Check data type - cannot get value"

                 case "textarea" return
                 <textarea id="{$elementNickname}_{$indexNo}_1" class="form-control" name="{$elementNickname}_{$indexNo}_1">{$elementAttributeValue}</textarea>
                 default return null
                 }
                <button id="{$elementNickname}SaveButton" class="btn btn-success"
                onclick="saveDataSimple('{$currentResourceURI}', '{$elementNickname}', '{$XPath}',
                    '{$elementDataType}', '{$indexNo}', '{$pos}')"
                        appearance="minimal" type="button"><i class="glyphicon
glyphicon glyphicon-ok-circle"></i></button>
                <button id="{$elementNickname}CancelEdit" class="btn btn-danger"
                onclick="cancelEdit('{$elementNickname}', '{$indexNo}', '{$elementValue}', 'input', '{$pos}') "
                        appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

        </div></div>
        </div>
                      )}


                <div id="{$elementNickname}_add_{$indexNo}" class="xmlElement xmlElementAddItem xmlElementHidden">

                    { switch ($elementDataType)
                    case "text" return
                                <div>{$elementDataType}
                                {if($elementNode/xmlLang/text() ="true") then 
                                    (<div id="lang_{$elementNickname}_add" class="elementWithValue">
                                    {skosThesau:dropDownThesau("c21856", $spatiumStructor:lang, 'Lang.', 'inline', (), (9999), "xml")}
                                    </div>)
                                    else ()
                                    } 
                                    <input id="{$elementNickname}_add_{$indexNo}_1" class="form-control" name="{$elementNickname}_add_{$index}_1" value=""></input>
                                </div>
                    case "textNodeAndAttribute" return
                                <div>
                                <span>Value of <em>Attribute</em> {functx:substring-after-last($XPath, '/')}</span><input id="{$elementNickname}_add_attrib_{$index}_1" class="form-control" name="{$elementNickname}_text_{$index}_1" value=""></input>
                                <span>Value of <em>Node Text</em></span><input id="{$elementNickname}_add_text_{$index}_1" class="form-control" name="{$elementNickname}_add_text_{$index}_1" value=""></input>
                                </div>
                    case "attribute" return
                                <div>
                                <span>Value of <em>Attribute</em> {functx:substring-after-last($XPath, '/')}</span><input id="{$elementNickname}_add_1_1" class="form-control" name="{$elementNickname}_text_{$index}_1" value=""></input>
                                
                                </div>
                    default return "Error! Check data type. Cannot get value" }


                        <button id="addNewItem" class="btn btn-success" onclick='addData(this,
                                "{$currentResourceURI}",
                                "{$elementNickname}_add_{$indexNo}_1", "{$elementNickname}", "{$xpathSingleQuote}", "{$contentType}", "{$indexNo}", "")'
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$elementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelEdit('{$elementNickname}_add_{$indexNo}', '{$indexNo}', '{$elementValue}', 'thesau', {$valuesTotal +1}) "
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                </div>
            </div>
        )
};


declare function spatiumStructor:displayXmlElementWithThesauCardi($elementNickname as xs:string,
             $topConceptId as xs:string,
             $resourceURI as xs:string?,
             $index as xs:integer?,
             $xpath_root as xs:string?) {

        let $currentResourceURI := if($resourceURI != "") then $resourceURI else  $spatiumStructor:placeURI
        let $indexNo := if($index) then data($index) else "1"
        let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]))) 
                then $spatiumStructor:placeElements//xmlElement[nm=$elementNickname] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]
        
(:        let $elementNode := $spatiumStructor:placeElements//xmlElement[nm=$elementNickname]:)
        let $elementIndex := if($index) then ("[" || string($index) || "]" ) else ("")

        let $xpathEnd := if(matches($elementNode//xpath/text(), "/@"))
                                            then(
                                                        functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/"
                                                        || functx:substring-after-last($elementNode//xpath/text(), '/')
                                            )
                                            else (
                                                    $elementNode/./xpath/text()
                                                    )
        let $xpathEndAttrib := if(matches($elementNode/xpath/text(), "/@"))
                                            then(
                                                        functx:substring-after-last($elementNode/xpath/text(), '/') 
                                            )
                                            else (
                                                    $elementNode/./xpath/text()
                                                    )
       let $elementAncestors := $elementNode/ancestor::xmlElement
        let $XPath := if($elementNode/ancestor::xmlElement)
                    then
                        string-join(
                        for $ancestor in $elementAncestors
                        return
                        if (matches($ancestor/xpath/text(), '/@')) then
                            substring-before($ancestor/xpath/text(), '/@')
                            else $ancestor/xpath/text()
                        )
                    || $elementIndex || $xpathEnd
                    else
                        $xpathEnd
     let $xpathBaseForCardinalityX :=
            if (matches($XPath, "/@")) then
            (functx:substring-before-last(functx:substring-before-last($XPath, "/@"), '/'))
            else
                ($XPath)

     let $selectorForCardinalityX :=
            if (matches($XPath, "/@")) then
            (functx:substring-after-last(functx:substring-before-last($XPath, "/@"), "/"))
            else
                (functx:substring-after-last($XPath, "/"))

    let $contentType :=$elementNode/contentType/text()
    let $elementDataType := $elementNode/contentType/text()
    let $elementFormLabel := $elementNode/formLabel[@xml:lang=$spatiumStructor:lang]/text()
    let $elementCardinality := $elementNode/cardinality/text()
    let $attributeValueType := $elementNode/attributeValueType/text()

(:    let $Doc := $spatiumStructor:place-collection/id($spatiumStructor:docId):)

    let $elementValue :=
        if($elementCardinality = "1" ) then (
                    util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"
                    ||$currentResourceURI ||"']/" || $xpathBaseForCardinalityX || "//" || $selectorForCardinalityX ))
(:                    util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//.[@rdf:about='"||$currentResourceURI ||"']/" || $XPath )):)
         else if($elementCardinality = "x" ) then (
                    util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"||$currentResourceURI ||"']/" || $xpathBaseForCardinalityX || "//" || $selectorForCardinalityX ))
         else
         (util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"||$currentResourceURI ||"']/" || $xpathBaseForCardinalityX || "//" || $selectorForCardinalityX ))
(:            (util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//.[@rdf:about='"||$currentResourceURI ||"']/" || $XPath )):)
    let $valuesTotal := count($elementValue)
    let $data2display :=
    if($elementCardinality = "1" ) then (
        data(util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='" || $elementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))
        ) else()
    let $inputName := 'selectDropDown' ||$topConceptId

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $spatiumStructor:project || "/data/documents')//id('"||$spatiumStructor:docId
                    ||"')/"
                    || functx:substring-before-last($XPath2Ref, '/') || "//tei:category"):)
    let $xpathSingleQuote := replace($XPath, '"', "'")
    return

        (
        <div id="{$elementNickname}_group_{$indexNo}" class="xmlElementGroup">
        <div class="xmlElementGroupHeaderBlock">
            <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                    <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                    </span></span>
                    { if($elementCardinality ="x") then
                    <button id="{$elementNickname}addItem_{$indexNo}" class="btn btn-primary addItem"
                        onclick="addItem(this, '{ $inputName }_add_{ $indexNo }', '{ $indexNo }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>

                  else()
                     }
              </div>
              {
              for $item at $pos in $elementValue
              let $value2Bedisplayed:= 
                        if (not(matches($contentType, 'text'))) then (

                            if (not($attributeValueType) or $attributeValueType="uri") then
                            let $attributeValue := 
                                                if($item/@rdf:resource) then data($item/@rdf:resource)
                                                else if($item/@ref) then data($item/@ref)
                                                else if ($item/@ana) then data($item/@ana)
                                                else ()
                            return
                                    skosThesau:getLabel($attributeValue, $spatiumStructor:lang)
                           else
                           skosThesau:getLabel($item/string(), $spatiumStructor:lang)
                        )
                        else if (($contentType ="text") and ($attributeValueType="xml-value") and (not($item[.='']))) then
                             data(util:eval( "collection('" || $spatiumStructor:concept-collection-path ||"')//.[skos:prefLabel[@xml:lang='xml']='" || $item/string() || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text()"))
                       
                       else if ($contentType = "textNodeAndAttribute") then  
                                if((data($item/@rdf:resource)) != "") then 
                            skosThesau:getLabel(data($item/@rdf:resource), $spatiumStructor:lang)
                                else $item/text() 

                        else($contentType || " " || (if ($attributeValueType) then $attributeValueType

                        else ()))
              return
              (
              <div class="itemInDisplayElement">
                      <div id="{$elementNickname}_display_{$indexNo}_{$pos}" class="xmlElement">
                      <!--<span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                          <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                          <div id="{$elementNickname}_value_{$indexNo}_{$pos}"
                          title="{$item/text()} = concept {$item/@ref/string()}" class="xmlElementValue">{ $value2Bedisplayed }</div>
                          <button id="edit{$elementNickname}_{$indexNo}_{$pos}" class="btn btn-primary editbutton"
                           onclick="editValue('{$elementNickname}', '{$indexNo}', '{$pos}')"
                                  appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                            editConceptIcon"></i></button>
                        { if($elementCardinality ="x") then <a class="removeItem" onclick="removeItem('{$currentResourceURI}', '{$elementNickname}', '{$xpathBaseForCardinalityX}', '{ $selectorForCardinalityX }', {$pos})"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
                                else () }
                
                      </div>
                      <div id="{$elementNickname}_edit_{$indexNo}_{$pos}" class="xmlElement xmlElementHidden">

                      <!--
                      <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                          <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                             {""
(:                             skosThesau:dropDownThesau($topConceptId, $spatiumStructor:lang, 'noLabel', 'inline', $index, $pos, $attributeValueType):)
                             }
                             {skosThesau:dropDownThesauForElement($elementNickname, $topConceptId, $spatiumStructor:lang, 'noLabel', 'inline', $index, $pos, $attributeValueType)}

                              <button class="btn btn-success"
                              onclick="saveData(this, '{$currentResourceURI}',
                              '{$inputName}',
                              '{$inputName}',
                              '{$elementNickname}',
                              '{$XPath}',
                              '{$contentType}',
                              '{$indexNo}',
                              '{$pos}')"

                                      appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>

                                      <button id="{$elementNickname}CancelEdit_{$indexNo}_{$pos}" class="btn btn-danger"
                              onclick="cancelEdit('{$elementNickname}', '{$indexNo}', '{functx:trim(string-join($elementValue[1]/text(), " "))}', 'thesau', '{$pos}') "
                                      appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

                      </div>

                      </div>

                      )}


                <div id="{$inputName}_add_{$indexNo}" class="xmlElement xmlElementAddItem xmlElementHidden">

                        {""
(:                        skosThesau:dropDownThesau($topConceptId, 'en', 'noLabel', 'inline', $index + 1, (), ()):)
                        }
                        {skosThesau:dropDownThesauForElement($elementNickname, $topConceptId, $spatiumStructor:lang, 'noLabel', 'inline', $index+1, (), ())}

                        <button id="addNewItem" class="btn btn-success"
                        onclick="addData(this, '{$currentResourceURI}', '{$inputName}_add_{$indexNo}', 
                                '{$elementNickname}', '{$XPath}', '{$contentType}', '{$indexNo}', '{ $topConceptId }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$elementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelEdit('{$inputName}_add_{$indexNo}', '{$indexNo}', '{$elementValue}', 'thesau', {$valuesTotal +1}) "
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                </div>



        </div>
        )
};

declare function spatiumStructor:displayXmlElementWithThesauCardiWithConceptHierarchy($elementNickname as xs:string,
             $topConceptId as xs:string,
             $resourceURI as xs:string?,
             $index as xs:integer?,
             $xpath_root as xs:string?) {

        let $currentResourceURI := if($resourceURI != "") then $resourceURI else  $spatiumStructor:placeURI
        let $indexNo := if($index) then data($index) else "1"
        let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]))) 
                then $spatiumStructor:placeElements//xmlElement[nm=$elementNickname] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]
        
(:        let $elementNode := $spatiumStructor:placeElements//xmlElement[nm=$elementNickname]:)
        let $elementIndex := if($index) then ("[" || string($index) || "]" ) else ("")

        let $xpathEnd := if(matches($elementNode//xpath/text(), "/@"))
                                            then(
                                                        functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/"
                                                        || functx:substring-after-last($elementNode//xpath/text(), '/')
                                            )
                                            else (
                                                    $elementNode/./xpath/text()
                                                    )
        let $xpathEndAttrib := if(matches($elementNode/xpath/text(), "/@"))
                                            then(
                                                        functx:substring-after-last($elementNode/xpath/text(), '/') 
                                            )
                                            else (
                                                    $elementNode/./xpath/text()
                                                    )
       let $elementAncestors := $elementNode/ancestor::xmlElement
        let $XPath := if($elementNode/ancestor::xmlElement)
                    then
                        string-join(
                        for $ancestor in $elementAncestors
                        return
                        if (matches($ancestor/xpath/text(), '/@')) then
                            substring-before($ancestor/xpath/text(), '/@')
                            else $ancestor/xpath/text()
                        )
                    || $elementIndex || $xpathEnd
                    else
                        $xpathEnd
     let $xpathBaseForCardinalityX :=
            if (matches($XPath, "/@")) then
            (functx:substring-before-last(functx:substring-before-last($XPath, "/@"), '/'))
            else
                ($XPath)

     let $selectorForCardinalityX :=
            if (matches($XPath, "/@")) then
            (functx:substring-after-last(functx:substring-before-last($XPath, "/@"), "/"))
            else
                (functx:substring-after-last($XPath, "/"))

    let $contentType :=$elementNode/contentType/text()
    let $elementDataType := $elementNode/contentType/text()
    let $elementFormLabel := $elementNode/formLabel[@xml:lang=$spatiumStructor:lang]/text()
    let $elementCardinality := $elementNode/cardinality/text()
    let $attributeValueType := $elementNode/attributeValueType/text()

(:    let $Doc := $spatiumStructor:place-collection/id($spatiumStructor:docId):)

    let $elementValue :=
        
         (util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"
         ||$currentResourceURI ||"']/" || $xpathBaseForCardinalityX || "//" || $selectorForCardinalityX ))
(:            (util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//.[@rdf:about='"||$currentResourceURI ||"']/" || $XPath )):)
    let $valuesTotal := count($elementValue)
    
    let $inputName := 'selectDropDown' ||$topConceptId

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $spatiumStructor:project || "/data/documents')//id('"||$spatiumStructor:docId
                    ||"')/"
                    || functx:substring-before-last($XPath2Ref, '/') || "//tei:category"):)
    let $xpathSingleQuote := replace($XPath, '"', "'")
    
    
     let $pos :="1" (:To be deleted:)
    let $value2Bedisplayed:=
        for $item at $pos in $elementValue 
                let $attributeValue := 
                                                       if($item/@rdf:resource) then data($item/@rdf:resource)
                                                          else if($item/@ref) then data($item/@ref)
                                                           else if ($item/@ana) then data($item/@ana)
                                                           else ()
                let $value := (
                               if (not(matches($contentType, 'text'))) then
                                   (
                                       if (not($attributeValueType) or $attributeValueType="uri") then 
                                           (
                                               skosThesau:getLabel($attributeValue, $spatiumStructor:lang)
                                            )
                                       else skosThesau:getLabel($item/string(), $spatiumStructor:lang)
                                   )
                               else if (($contentType ="text") and ($attributeValueType="xml-value") and (not($item[.=''])))
                                    then data(util:eval( "collection('"
                                               || $spatiumStructor:concept-collection-path ||"')//.[skos:prefLabel[@xml:lang='xml']='"
                                               || $item/string() || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text()"))
                              else if ($contentType = "textNodeAndAttribute") then 
                                       (
                                       if((data($item/@rdf:resource)) != "") then 
                                               skosThesau:getLabel(data($item/@rdf:resource), $spatiumStructor:lang)
                                       else $item/text() 
                                       )
                             else    ($contentType || " " || (if ($attributeValueType) then $attributeValueType else ()))
                          )
              return
              (<span>
              <span id="{$elementNickname}_value_{$indexNo}_1"
                          title="{$item/text()} = concept { $attributeValue }" class="xmlElementValue">{ $value }
              
             </span>{if($pos < count($elementValue)) then " > " else () }</span>
             )
    return

        (
        <div id="{$elementNickname}_group_{$indexNo}" class="xmlElementGroup">
        <div class="xmlElementGroupHeaderBlock">
            <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                    <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                    </span></span>
                   
              </div>
              <div class="itemInDisplayElement">
                      <div id="{$elementNickname}_display_{$indexNo}_1" class="xmlElement">{ $value2Bedisplayed }
                      <!--<span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                          <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                          
                          <button id="edit{$elementNickname}_{$indexNo}_1" class="btn btn-primary editbutton"
                           onclick="editValue('{$elementNickname}', '{$indexNo}', '1')"
                                  appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                            editConceptIcon"></i></button>
                        { if($elementCardinality ="x") then <a class="removeItem" onclick="removeItem('{$currentResourceURI}', '{$elementNickname}', '{$xpathBaseForCardinalityX}', '{ $selectorForCardinalityX }', 1)"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
                                else () }
                
                      </div>
                      <div id="{$elementNickname}_edit_{$indexNo}_1" class="xmlElement xmlElementHidden">

                      <!--
                      <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                          <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                             {""
(:                             skosThesau:dropDownThesau($topConceptId, $spatiumStructor:lang, 'noLabel', 'inline', $index, $pos, $attributeValueType):)
                             }
                             {skosThesau:dropDownThesauForElement(
                             $elementNickname, $topConceptId, $spatiumStructor:lang,
                             'noLabel', 'inline', $index, $pos, $attributeValueType)}

                              <button class="btn btn-success"
                              onclick="saveDataWithConceptHierarchy(this, '{$currentResourceURI}',
                              '{$inputName}',
                              '{$inputName}',
                              '{$elementNickname}',
                              '{$XPath}',
                              '{$contentType}',
                              '{$indexNo}',
                              '1')"

                                      appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>

                                      <button id="{$elementNickname}CancelEdit_{$indexNo}_1" class="btn btn-danger"
                              onclick="cancelEdit('{$elementNickname}', '{$indexNo}', '{functx:trim(string-join($elementValue[1]/text(), " "))}', 'thesau', '1') "
                                      appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

                      </div>

                      </div>

                      


                <div id="{$inputName}_add_{$indexNo}" class="xmlElement xmlElementAddItem xmlElementHidden">

                        {""
(:                        skosThesau:dropDownThesau($topConceptId, 'en', 'noLabel', 'inline', $index + 1, (), ()):)
                        }
                        {skosThesau:dropDownThesauForElement($elementNickname, $topConceptId, $spatiumStructor:lang, 'noLabel', 'inline', $index+1, (), ())}

                        <button id="addNewItem" class="btn btn-success"
                        onclick="addData(this, '{$currentResourceURI}', '{$inputName}_add_{$indexNo}', 
                                '{$elementNickname}', '{$XPath}', '{$contentType}', '{$indexNo}', '{ $topConceptId }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$elementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelEdit('{$inputName}_add_{$indexNo}', '{$indexNo}', '{$elementValue}', 'thesau', {$valuesTotal +1}) "
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                </div>



        </div>
        )
};

declare function spatiumStructor:displayGroup($xmlElementNickname as xs:string,
                                                        $resourceURI as xs:string?,
                                                        $index as xs:int?,
                                                        $type as xs:string?,
                                                        $xpath_root as xs:string?) {
     
     let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$xmlElementNickname]))) then
                        $spatiumStructor:placeElements//xmlElement[nm=$xmlElementNickname]
                        else ($spatiumStructor:placeElementsCustom//xmlElement[nm=$xmlElementNickname])
    let $xmlElementFormLabel := $elementNode/formLabel[@xml:lang=$spatiumStructor:lang]/text()
    let $xmlElementCardinality := $elementNode/cardinality/text()
    let $indexNo := if($index) then data($index) else "1"
    let $elementAncestors := $elementNode/ancestor::xmlElement
    let $xpathRootWhenSubGroup :=
        if($elementNode/ancestor::xmlElement)
            then (
                                    string-join(
                                                    for $ancestor at $pos in $elementAncestors
                                                        let $ancestorIndex := 
                                                                    if($pos = 1 ) 
                                                                            then if($index) 
                                                                                    then "[" || string($index) || "]" 
                                                                                    else ("")
                                                                             else ("")
                                                        return
                                                            if (contains($ancestor/xpath/text(), '/@'))
                                                                then substring-before($ancestor/xpath/text(), '/@')
                                                                        || $ancestorIndex
                                                                else $ancestor/xpath/text() || $ancestorIndex
                                                )
                                        
                                        )
           else ()
    let $xpathRoot := 
                (if($xpathRootWhenSubGroup != "") then $xpathRootWhenSubGroup || "/" 
                else ())
                || (if(ends-with($elementNode/xpath[1]/text(), '/self')) then
                                       substring-before($elementNode/xpath/text(), '/self')
                                       else $elementNode/xpath[1]/text()
                                       )
                                       
                                       
      
    let $groupNodeBaseXPath := functx:substring-before-last($xpathRoot, "/")
    let $groupNodeXPath := functx:substring-after-last($xpathRoot, "/")
    (:let $groupNodes := util:eval( "collection('" || $spatiumStructor:doc-collection-path || "')//id('" ||$spatiumStructor:docId ||"')/" || $groupNodeBaseXPath
                                 || "/" || $groupNodeXPath):)
    let $groupNodes := util:eval( "$spatiumStructor:place-collection//spatial:Feature[@rdf:about='" || 
                $resourceURI ||"']/" || $xpathRoot)
    let $elementChildren := $elementNode//child::xmlElement                             
    return 
    <div id="{ $xmlElementNickname }_group_{ $index }" class="xmlElementGroup">
        <div id="{ $xmlElementNickname }_display_{$index}_1" class="panel">
           <h4><span class="labelForm">{ $xmlElementFormLabel } <span class="xmlInfo">
                    <a title="TEI element: { $xpathRoot }"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                </span></span>{ if($xmlElementCardinality ="x") then
                    <button id="{$xmlElementNickname}addItem_{$indexNo}" class="btn btn-xs btn-primary addItem pull-right"
                        onclick="addGroupItem(this, '{ $xmlElementNickname }_add_{ $indexNo }', '{ $indexNo }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>
                     else()
         }</h4> 
    <ul class="list-group">
               {
                    for $group at $pos in $groupNodes
                        
                        return
                            <li class="list-group-item elementsByGroup">
                            <div class="xmlElementGroupHeaderBlock">
                <button class="removeItem btn btn-xs btn-warning pull-right"
                                          onclick="removeItemFromList('{ $resourceURI }', '{$xmlElementNickname}', 'xmlNode', {$pos}, '')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></button>
            </div>
            
            
            {
                                    for $elementChild in $elementChildren
                                        let $xpathEnd := $elementChild/child::xpath/text()
                                        
                                        return
                                        <div class="d-block">
                                           {spatiumStructor:displayElement($elementChild/nm/text(),
                                                $resourceURI,
                                                $pos,
                                                $xpathRoot || "[" || $pos || "]" || ""(:$xpathEnd[1]:) )
                                            }</div>
                                        }
                           </li>
             }</ul>
        </div>
        <div id="{$xmlElementNickname}_add_{$indexNo}" class="xmlElement xmlElementAddGroup xmlElementAddGroupItem xmlElementHidden">
        <div class="xmlElementGroupHeaderBlock">
                <span class="labelForm">New { $xmlElementFormLabel } <span class="xmlInfo">
                    <a title="XML element: { $xpathRoot }"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                </span></span>
                </div>
            {
            
            for $elementChild at $pos in $elementChildren
                                        let $xmlElementNickname := $elementChild/child::nm/text()
                                        let $xpathEnd := $elementChild/child::xpath/text()
                                        let $xmlElementDataType := $elementChild/child::contentType/text()
                                        let $xmlElementFieldType := $elementChild/child::fieldType/text()
                                        let $attributeValueType := $elementChild/attributeValueType/text()
                                        let $label :=functx:if-empty($elementChild/child::formLabel[@xml:lang=$spatiumStructor:lang]/text(), "")
                                        let $topConceptUri := functx:substring-after-last($elementChild/child::thesauTopConceptURI/text(), "/")
                                        return 
                                            switch ($xmlElementFieldType)
                                                case "combobox"
                                                   return 
                                                    <div>
                                                        {skosThesau:dropDownThesauForXMLElement($xmlElementNickname,
                                                        $topConceptUri,
                                                        $spatiumStructor:lang,
                                                        $label, 'inline', 
                                                            9999, $pos, $attributeValueType)}
                                                    
                                                    </div>
                                                case "input"
                                                    return
                                                    <div>
                                                    <div class="input-group-prepend">
                                                      <span>{ $label }</span>
                                                      </div>
                                                        <input id="{$xmlElementNickname}_add_{$index}_1" class="form-control elementWithValue" name="{$xmlElementNickname}" value=""></input>
                                                        </div>
                                                
                                                case "textarea"
                                                    return
                                                     <div>
                                                    <div class="input-group-prepend">
                                                      <span>{ $label }</span>
                                                      </div>
                                                       <textarea id="{$xmlElementNickname}_add_{$index}_1" class="form-control elementWithValue" name="{$xmlElementNickname}"></textarea>
                                                   </div>
                                                case "textNodeAndAttribute" return
                                                <div/>
                                                
                                                default return "Error! Check data type (" || $xmlElementDataType || ")- l. 1172"
                                    (:switch ($xmlElementDataType)
                                                case "text"
                                                case "attribute"
                                                return
                                                <div>
                                                type{$xmlElementFieldType}
                                                <input id="{$xmlElementNickname}_text_{$index}_1" class="form-control" name="{$xmlElementNickname}_{$index}_1" value=""></input>
                                                </div>
                                                case "textNodeAndAttribute" return
                                                <div>
                                                type{$xmlElementFieldType}<div class="input-group">
                                                <div class="input-group-prepend">
                                                      <span>Value of <em>Attribute</em>{ functx:substring-after-last($xpathRoot, '/') }</span>
                                                      </div>
                                                      <input id="{$xmlElementNickname}_add_attrib_  {$index}_1" class="form-control" name="{$xmlElementNickname}_text_{$index}_1" value=""></input>
                                                </div>
                                                <span>Value of <em>Node Text</em></span><input id="{$xmlElementNickname}_add_text_{$index}_1" class="form-control" name="{$xmlElementNickname}_add_text_{$index}_1" value=""></input>
                                                </div>
                                                default return "Error! Check data type (" || $xmlElementDataType || ")- l. 1172":)
                                                                
                                                                }
                                                                
                         <button id="{$xmlElementNickname}addNewGroup" class="btn btn-success"
                        
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                         <button id="{$xmlElementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelAddItem(this)"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                                    
                                    </div>
                                    <script>
                                    $({$xmlElementNickname}addNewGroup).on("click", function(){{
                                      addGroupData(this, '{ $resourceURI }', '{$xmlElementNickname}', '{$indexNo}')
                                    }});
                                    </script>
                                    </div>
};


declare function spatiumStructor:displayPlaceWithPeripleo($elementNickName as xs:string, $resourceId as xs:string?, $index as xs:int?, $XPath as xs:string?){
        let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickName]))) 
                then $spatiumStructor:placeElements//xmlElement[nm=$elementNickName] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickName]
        
(:    let $elementNode := $spatiumStructor:placeElements //xmlElement[nm=$elementNickName]:)
     let $elementFormLabel := $elementNode/formLabel[@xml:lang=$spatiumStructor:lang]/text()
    let $currentResourceId := if($resourceId != "") then $resourceId else $spatiumStructor:placeId
     let $XPath:= $elementNode//xpath/text()
     let $elementValueName :=
         (data(
            util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')/id('" ||$currentResourceId ||"')/" || substring-before($XPath, '/@'))))
let $elementValueUri:=
         (data(
            util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')/id('" ||$currentResourceId ||"')/" || $XPath)))


    let $placeRef :=
         (data(
            util:eval( "collection('" || $spatiumStructor:doc-collection-path || "')/id('" ||$currentResourceId ||"')/" || $XPath)))
    let $numberOfPlaceRef := count(tokenize($placeRef, ' '))
    let $placeProjectUri := for $uri in tokenize($placeRef, ' ')
                                    where matches($uri,  $spatiumStructor:baseUri)
                                return functx:trim($uri)
    let $placeRecord := $spatiumStructor:placeRepo//pleiades:Place[@rdf:about = $placeProjectUri]
    let $placePrefLabel := $placeRecord//skos:prefLabel[@xml:lang="en"]/text()
    let $placeRefsAsLink := <ul class="list-inline">
                                            {for $uri in tokenize($placeRef, ' ')

                                            return
                                                 <li class="list-inline-item"><a class="uriAsLink" href="{ $uri }" target="_blank">{ $uri }</a></li>
                                                }
                                            </ul>
    let $element2Display :=
    <div class="xmlElementGroup">

                    <div class="itemInDisplayElement">
                    <div class="xmlElementGroupHeader">
                            <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                                    <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                                </span>
                                </span>
                      </div>
                             <div id="{$elementNickName}_display_{$index}_1" class="xmlElement">
                                <div id="{$elementNickName}_value_{$index}_1" title="{ $placeRef }" class="xmlElementValue">
                                { $elementValueName }  ({$elementValueUri})
                                </div>
                                <button id="edit{$elementNickName}" class="btn btn-primary editbutton" onclick="editValue('{$elementNickName}', '{$index}', '1')"
                                        appearance="minimal" type="button"><i class="glyphicon glyphicon-edit editConceptIcon"></i></button>
                             </div>



                             <div id="{$elementNickName}_edit_{ $index }_1" class="xmlElementHidden form-group">

                         <div class="form-group">

                                    <label for="placesLookupInputDisplayWithPeripleo">Search in <a href="http://pelagios.org/peripleo/map" target="_blank">Pelagios Peripleo</a></label>
                                     <input type="text" class="form-control peripleoLookup"
                                     id="placesLookupInputDisplayWithPeripleo"
                                     name="placesLookupInputDisplayWithPeripleo"
                                     />
                                    <div class="input-group">
                                          <span class="input-group-addon">Place standardized Name</span>
                                          <input type="text" id="placesLookupInputDisplayWithPeripleo_placeName__1" name="placesLookupInputDisplayWithPeripleo_placeName_1_1" value=""/>
                                      </div>
                                    <div class="input-group">
                                          <span class="input-group-addon">Place URI</span>
                                          <input type="text" id="placesLookupInputDisplayWithPeripleo_placeURI__1" name="placesLookupInputDisplayWithPeripleo_placeURI_1_1" value=""/>
                                    </div>

                              </div>

<button id="save{ $elementNickName }" class="btn btn-success"
                onclick="saveDataSimple('{$currentResourceId}',
                'placesLookupInputDisplayWithPeripleo_placeName',
                'placesLookupInputDisplayWithPeripleo_placeURI',
                '{$elementNickName}',
                '{$XPath}',
                'textNodeAndAttribute',
                '{ $index }',
                '1')"
                        appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                        <button id="{$elementNickName}CancelEdit" class="btn btn-danger"
                onclick="cancelEdit('{$elementNickName}', '{ $index }', '', 'taxo', '1') "
                        appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                             </div>

                    </div>
                    <div class="">
                             <!--
                             <iframe id="placesLookupInputDisplayWithPeripleo_peripleoWidget" allowfullscreen="true" height="380" src="" style="display:none;"> </iframe>
                                     <div id="previewMapDocPlaces" class="hidden"/>
                                     <div id="placePreviewPanelDocPlaces" class="hidden"/>
                             -->
                                     <button id="addNewPlaceButtonDocPlaces " class="btn btn-success hidden" onclick="addPlaceToDoc('{$spatiumStructor:placeId}')" appearance="minimal" type="button">Add place to document<i class="glyphicon glyphicon glyphicon-saved"></i></button>
                         </div>
                    </div>
return

    $element2Display




};

declare function spatiumStructor:displayPlaceWithList($elementNickName as xs:string, $resourceId as xs:string?, $index as xs:int?, $XPath as xs:string?){
        let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickName]))) 
                then $spatiumStructor:placeElements//xmlElement[nm=$elementNickName] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickName]
        
(:    let $elementNode := $spatiumStructor:placeElements //xmlElement[nm=$elementNickName]:)
     let $elementFormLabel := $elementNode/formLabel[@xml:lang=$spatiumStructor:lang]/text()
    let $currentResourceId := if($resourceId != "") then $resourceId else $spatiumStructor:placeId
    let $placeRef :=
         (data(
            util:eval( "collection('" || $spatiumStructor:doc-collection-path || "')/id('" ||$currentResourceId ||"')/" || $XPath)))
    let $numberOfPlaceRef := count(tokenize($placeRef, ' '))
    let $placeProjectUri := for $uri in tokenize($placeRef, ' ')
                                    where matches($uri,  $spatiumStructor:baseUri)
                                return functx:trim($uri)
    let $placeRecord := $spatiumStructor:placeRepo//pleiades:Place[@rdf:about = $placeProjectUri]
    let $placePrefLabel := $placeRecord//skos:prefLabel[@xml:lang="en"]/text()
    let $placeRefsAsLink := <ul class="list-inline">
                                            {for $uri in tokenize($placeRef, ' ')

                                            return
                                                 <li class="list-inline-item"><a class="uriAsLink" href="{ $uri }" target="_blank">{ $uri }</a></li>
                                                }
                                            </ul>
    let $element2Display :=
    <div class="xmlElementGroup">

                    <div class="itemInDisplayElement">
                    <div class="xmlElementGroupHeader">
                            <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                                    <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                                </span>
                                </span>
                      </div>
                             <div id="{$elementNickName}_display_{$index}_1" class="xmlElement">
                                <div id="{$elementNickName}_value_{$index}_1" title="{ $placeRef }" class="xmlElementValue">{ $placePrefLabel } {$placeRefsAsLink}
                                </div>
                                <button id="edit{$elementNickName}" class="btn btn-primary editbutton" onclick="editValue('{$elementNickName}', '{$index}', '1')"
                                        appearance="minimal" type="button"><i class="glyphicon glyphicon-edit editConceptIcon"></i></button>
                             </div>

                             <div id="{$elementNickName}_edit_{ $index }_1" class="xmlElementHidden form-group">
                             <select id="{$elementNickName}_{$index}_1" name="{$elementNickName}_{$index}_">
                         {for $items in $spatiumStructor:placeRepo//pleiades:Place
                            return
                                if ($items/@rdf:about = $placeProjectUri)
                                then (<option value="{$items/@rdf:about}{
                                    if($items//skos:exactMatch) then ' ' || concat(data($items//skos:exactMatch/@rdf:resource), ' ') else ()}"
                                    textValue="{$items//skos:prefLabel[@xml:lang='en']}"
                                    selected="selected">
                                    {$items//skos:prefLabel[@xml:lang='en']} {data($items/@rdf:about)}</option>)
                                        else (
                                <option value="{$items/@rdf:about}{if($items//skos:exactMatch) then ' ' || concat(data($items//skos:exactMatch/@rdf:resource), ' ') else ()}"
                                textValue="{$items//skos:prefLabel[@xml:lang='en']}">{$items//skos:prefLabel[@xml:lang='en']} {data($items/@rdf:about)}</option>
                                )
                         }</select>
<button id="save{ $elementNickName }" class="btn btn-success"
                onclick="saveData(this, '{$currentResourceId}', '{$elementNickName}_{$index}_1', '{$elementNickName}_{$index}_1', '{$elementNickName}', '{$XPath}', 'textNodeAndAttribute', '{ $index }', '1')"
                        appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                        <button id="{$elementNickName}CancelEdit" class="btn btn-danger"
                onclick="cancelEdit('{$elementNickName}', '{ $index }', '', 'taxo', '1') "
                        appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                             </div>

                    </div>
                    </div>
return

    $element2Display




};


declare function spatiumStructor:isMadeOf($resourceUri as xs:string, $subPlaces as node()){
            let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm="isMadeOf"]))) 
                then $spatiumStructor:placeElements//xmlElement[nm="isMadeOf"] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm="isMadeOf"]
        
(:            let $elementNode := $spatiumStructor:placeElements//xmlElement[nm="isMadeOf"]:)
            let $elementFormLabel := $elementNode/formLabel[@xml:lang=$spatiumStructor:lang]/text()
            let $XPath := $elementNode/xpath/text()
            let $placeNodes :=
                    for $place in $subPlaces//spatial:Pi
                        let $uriPlace := $place/@rdf:resource ||"#this"
                            return
                            $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about = $uriPlace ]
                            
                            (:util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| data($place/@rdf:resource) ||"#this']/."):)

            return
          <div class="xmlElementGroup">
                 <div id="isMadeOf_display_1_1" class="">
                 <div class="xmlElementGroupHeaderInline">
                 <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                     <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                     <button id="addSubPlace" class="btn btn-primary addItem"
                     onclick="openDialog('dialogAddSubPlace', 'isMadeOf')" appearance="minimal" type="button">
                     <i class="glyphicon glyphicon glyphicon-plus"></i></button>

                     </div>

         {  if( count($placeNodes) > 0) then
            for $subPlace at $pos in $placeNodes

            let $standardizedName := $subPlace//dcterms:title/text()
            let $placeUri := data($subPlace/@rdf:about)
            let $placeUriShort := substring-before($placeUri, "#this")
            let $placeFeatureTypeMain := $subPlace//foaf:primaryTopicOf/pleiades:Place/pleiades:hasFeatureType[@type='main']
(:            let $typeIcon := spatiumStructor:getPlaceTypeIcon($placeFeatureTypeMain):)


            return
            <div class="xmlElementGroup">

                    <div id="isMadeOf_display_1_{$pos}" class="subPlaceDetails">
                       <span>{$standardizedName} </span>- <span class=""><a onclick='displayPlace("{$standardizedName}", "{ $placeUri }")'>{ $placeUriShort }</a></span>
                       
                       { data($subPlace/@rdf:resource) }
<a class="removeItem pull-right" onclick="removeSubPlace(this, '{$resourceUri}', '{ $placeUri }', 
                        'isMadeOf')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>

                        

                    </div>
            </div>
            else  <div class=""><em>There is currently no subplace</em></div>
            }


            </div>

       




       </div>
};

declare function spatiumStructor:relatedPlacesList($resourceUri as xs:string, $relationType as xs:string){
            let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm="isMadeOf"]))) 
                then $spatiumStructor:placeElements//xmlElement[nm="isMadeOf"] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm="isMadeOf"]
        
            let $placeRdf :=  $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about= $resourceUri]
            let $subPlaces :=  
                    switch ($relationType)
                    case "isPartOf" return
                            if($placeRdf//spatial:P) then <uris>{ $placeRdf//spatial:P }</uris> else <none/>
                    case "isMadeOf" return
                            if($placeRdf//spatial:Pi) then <uris>{ $placeRdf//spatial:Pi }</uris> else <none/>
                    case "isInVicinityOf" return
                        if($placeRdf//spatial:C[@type="isInVicinityOf"]) then <uris>{ $placeRdf//spatial:C[@type="isInVicinityOf"] }</uris> else <none/>
                      case "hasInItsVicinity" return
                        if($placeRdf//spatial:C[@type="hasInItsVicinity"]) then <uris>{ $placeRdf//spatial:C[@type="hasInItsVicinity"] }</uris> else <none/>
                      case "isAdjacentTo" return
                        if($placeRdf//spatial:C[@type="isAdjacentTo"]) then <uris>{ $placeRdf//spatial:C[@type="isAdjacentTo"] }</uris> else <none/>
                    default return null                        
                let $placeNodes :=
                    for $place in $subPlaces/node()
                        let $uriPlace := $place/@rdf:resource ||"#this"
                            return
                            $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about = $uriPlace ]
            return
            <places type="{ $relationType }">{
                if( count($placeNodes) > 0) then
                    for $subPlace at $pos in $placeNodes
                             let $standardizedName := $subPlace//dcterms:title/text()
                             let $placeUri := data($subPlace/@rdf:about)
                             let $placeUriShort := substring-before($placeUri, "#this")
                             let $placeFeatureTypeMain := $subPlace//foaf:primaryTopicOf/pleiades:Place/pleiades:hasFeatureType[@type='main']
                    return
                        <place uri="{ $placeUri }" featureTypeMain="placeFeatureTypeMain">{$standardizedName}</place>
                else  ()
            }</places>
};


declare function spatiumStructor:isMadeOfArchaeo($resourceUri as xs:string, $subPlaces as node()){
            let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm="isMadeOf"]))) 
                then $spatiumStructor:placeElements//xmlElement[nm="isMadeOf"] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm="isMadeOf"]
        
(:            let $elementNode := $spatiumStructor:placeElements//xmlElement[nm="isMadeOf"]:)
            let $elementFormLabel := $elementNode/formLabel[@xml:lang=$spatiumStructor:lang]/text()
            let $XPath := $elementNode/xpath/text()
            let $placeNodes :=
                    for $place in $subPlaces//spatial:Pi
                          let $placeUri := $place/@rdf:resource ||"#this"
                            return
                            $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about = $placeUri]
                            (:util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| data($place/@rdf:resource) ||"#this']/."):)

            return
          <div class="xmlElementGroup">
                 <div id="isMadeOf_display_1_1" class="">
                 <div class="xmlElementGroupHeader">
                 <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                     <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                     <button id="addNewSubPlaceButton" class="btn btn-sm btn-primary pull-right" appearance="minimal" type="button" onclick="openDialog('dialogAddNewSubPlace')" style="margin: 0 5px 0 5px;"><i class="glyphicon glyphicon-plus"></i></button>
                     
                     <button id="addSubPlace" class="btn btn-primary addItem pull-right"
                     onclick="openDialog('dialogAddSubPlace', 'isMadeOf')" appearance="minimal" type="button" style="margin: 0 5px 0 5px;">
                     <i class="glyphicon glyphicon glyphicon-link"></i> </button>

                     </div>

         {  if( count($placeNodes) > 0) then
            for $subPlace at $pos in $placeNodes

            let $standardizedName := $subPlace//dcterms:title/text()
            let $placeUri := data($subPlace/@rdf:about)
             let $placeUriShort := substring-before($placeUri, "#this")
            let $placeFeatureTypeMain := $subPlace//foaf:primaryTopicOf/pleiades:Place/pleiades:hasFeatureType[@type='main']
(:            let $typeIcon := spatiumStructor:getPlaceTypeIcon($placeFeatureTypeMain):)


            return
            <div class="xmlElementGroup">

                    <div id="isMadeOf_display_1_{$pos}" class="subPlaceDetails">
<span>{$standardizedName} </span>- <span class="pull-right"><a onclick='displayPlace("{$standardizedName}", "{ $placeUri }")'>{ $placeUriShort }</a></span>
                       
                       { $subPlace/@rdf:resource }
<a class="removeItem pull-right" onclick="removeSubPlace(this, '{$resourceUri}', 
'{ $placeUri }', 'isMadeOf')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>

                        

                    </div>
            </div>
            else  <div class=""><em>There is currently no subplace</em></div>
            }


            </div>

       




       </div>
};


declare function spatiumStructor:isPartOf($resourceUri as xs:string, $subPlaces as node()){
            let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm="isPartOf"]))) 
                then $spatiumStructor:placeElements//xmlElement[nm="isPartOf"] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm="isPartOf"]
        
(:            let $elementNode := $spatiumStructor:placeElements//xmlElement[nm="isPartOf"]:)
            let $elementFormLabel := $elementNode/formLabel[@xml:lang=$spatiumStructor:lang]/text()
            let $XPath := $elementNode/xpath/text()
            let $placeNodes :=
                    for $place in $subPlaces//spatial:P
                            let $placeUri := $place/@rdf:resource ||"#this"
                            return
                            $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about = $placeUri]
                            (:util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| data($place/@rdf:resource) ||"#this']/."):)

            return

          <div class="xmlElementGroup">
                 <div id="isMadeOf_display_1_1" class="">
                 <div class="xmlElementGroupHeaderInline">
                 <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                     <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                     <button id="addSubPlace" class="btn btn-primary addItem"
                     onclick="openDialog('dialogAddSubPlace', 'isPartOf')" appearance="minimal" type="button">
                     <i class="glyphicon glyphicon glyphicon-plus"></i></button>

                     </div>

         {  if( count($placeNodes) > 0) then
            for $subPlace at $pos in $placeNodes
                let $standardizedName := $subPlace//dcterms:title/text()
                let $placeUri := data($subPlace/@rdf:about)
                 let $placeUriShort := substring-before($placeUri, "#this")
                let $placeFeatureTypeMain := $subPlace//foaf:primaryTopicOf/pleiades:Place/pleiades:hasFeatureType[@type='main']
                let $orderingOrder := switch($placeFeatureTypeMain )
                                                            case 'province' return 'a'
                                                            case '' return 'b'
                                                            default return 'b'
(:            let $typeIcon := spatiumStructor:getPlaceTypeIcon($placeFeatureTypeMain):)

            order by $orderingOrder
            return
            <div class="xmlElementGroup">

                { if ( matches($spatiumStructor:romanProvincesDoc//spatial:Feature/@rdf:about, $placeUri) ) then
                    <div id="isPartOf_display_1_{$pos}" class="subPlaceDetails">

                    <span><em>Province: </em>{$standardizedName} <span class="pull-right"><a onclick='displayPlace("{$standardizedName}", "{ $placeUri }")'>{ $placeUriShort }</a></span></span>
                    </div>

                    else
                    (
                    <div id="isPartOf_display_1_{$pos}" class="subPlaceDetails">
                       <span>{$standardizedName} </span><span class="pull-right"><a onclick='displayPlace("{$standardizedName}", "{ $placeUri }")'>{ $placeUriShort }</a></span>
                       { data($subPlace/@rdf:resource) }
<button class="btn btn-xs btn-primary" onclick="changePlaceToNearTo('{ $resourceUri }', '{ $placeUri }')">Change to <em>isInTheVicinityOf</em></button>
                <a class="removeItem pull-right" onclick="removeSubPlace(this, '{$resourceUri}', '{ $placeUri }', 
                        'isPartOf')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>

                    </div>)
                    }
            </div>
            else  <div class=""><em>There is currently no subplace</em></div>
            }


            </div>

       





       </div>
};

declare function spatiumStructor:placeConnectedWith($resourceUri as xs:string, $type as xs:string, $subPlaces as node()){
            let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$type]))) 
                then $spatiumStructor:placeElements//xmlElement[nm=$type] 
                else $spatiumStructor:placeElementsCustom//xmlElement[nm=$type]
        
            
(:            let $elementNode := $spatiumStructor:placeElements//xmlElement[nm=$type]:)
            let $elementFormLabel := $elementNode/formLabel[@xml:lang=$spatiumStructor:lang]/text()
            let $XPath := $elementNode/xpath/text()
            let $placeNodes :=
                    for $place in $subPlaces//spatial:C[@type=$type]
                    let $placeUri := $place/@rdf:resource ||"#this"
                            return
                            $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about = $placeUri]
                            (:util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| data($place/@rdf:resource) ||"#this']/."):)

            return


          <div class="xmlElementGroup">
                 <div id="isMadeOf_display_1_1" class="">
                 <div class="xmlElementGroupHeaderInline">
                 <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
                     <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                     <button id="addSubPlace" class="btn btn-primary addItem"
                     onclick="openDialog('dialogAddSubPlace', '{ $type }')" appearance="minimal" type="button">
                     <i class="glyphicon glyphicon glyphicon-plus"></i></button>

                     </div>

         {  if( count($placeNodes) > 0) then
            for $subPlace at $pos in $placeNodes
                let $standardizedName := $subPlace//dcterms:title/text()
                let $placeUri := data($subPlace/@rdf:about)
                let $placeUriShort := substring-before($placeUri, "#this")
                let $placeFeatureTypeMain := $subPlace//foaf:primaryTopicOf/pleiades:Place/pleiades:hasFeatureType[@type='main']
                let $orderingOrder := switch($placeFeatureTypeMain )
                                                            case 'province' return 'a'
                                                            case '' return 'b'
                                                            default return 'b'
            
                let $typeIcon := if($placeFeatureTypeMain != "") then 
                            spatiumStructor:getPlaceTypeIcon($placeFeatureTypeMain)
                            else if($placeFeatureTypeMain/@rdf:resource != "") then
                                skosThesau:getLabel($placeFeatureTypeMain/@rdf:resource, $spatiumStructor:lang, $spatiumStructor:project)
                                else()

            
            order by $orderingOrder
            return
            <div class="xmlElementGroup">

                {
                    (
                    <div id="isInVicinityOf_display_1_{$pos}" class="subPlaceDetails">
                       <span>{$standardizedName}</span><span class="pull-right"><a onclick='displayPlace("{$standardizedName}", "{ $placeUri }")'>{ $placeUriShort }</a></span>
                       <br/>
                       <ul>
                       { if($typeIcon !="") then  
                       <li>{ $typeIcon }</li> else ()}
<a class="removeItem pull-right" onclick="removeSubPlace(this, '{$resourceUri}', '{ $placeUri }', 
                        '{ $type }')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>


                        </ul>

                    </div>)
                    }
            </div>
            else  <div class=""><em>----</em></div>
            }


            </div>

       




       </div>
};

declare function spatiumStructor:placeLocation($resourceUri as xs:string){
            let $place :=util:eval("collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='" || $resourceUri || "']")
(:            let $place := $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about = $resourceUri]:)
            let $locationDetails:= $place/following-sibling::pleiades:Location
            let $locationAsGeoJSon := if($locationDetails//osgeo:asGeoJSON/text() and $locationDetails//osgeo:asGeoJSON/text() != "") 
                                then ($locationDetails//osgeo:asGeoJSON/text()) else ()
            let $locationType := $locationAsGeoJSon//pair[1]/text()
            let $longitude := $place/foaf:primaryTopicOf/pleiades:Place/geo:long/text() 
            let $latitude := $place/foaf:primaryTopicOf/pleiades:Place/geo:lat/text()
            let $coordinates := substring-before(substring-after($locationDetails//osgeo:asWKT/text(), '(('), '))')
            let $longitudeFromGeoJson := $locationAsGeoJSon//pair[2]/item[1]/text() 
            let $latitudeFromGeoJson := $locationAsGeoJSon//pair[2]/item[2]/text() 
            return

          <div class="xmlElementGroup">
          <div id="placeLocation" class="">
                 <div class="xmlElementGroupHeaderInline">
                 <span class="labelForm">Location<span class="xmlInfo">
                     <a title="XML element: /pleiades:Location"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                     
                     </div>

         {  if( count($locationDetails) > 0) then
            (<div class="xmlElementGroup">

                
                    <div id="placeLocation_display" class="subPlaceDetails">
                       <span>Type:</span><span>{ $locationType }</span>
                      <span>Longitude:</span><span >{ $longitude }</span>
                      <span>Latitude:</span><span>{ $latitude }</span>
                       {if(not($coordinates)) then ""  else <div style="width: 100%; display: block;"><em>Coordinates</em>{ $coordinates}</div>  }
                       <button id="editSubTypeFeatures" class="btn btn-primary editbutton pull-right"
                      onclick="editLocation('{ $longitude }', '{ $latitude }')"
                             appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                       editConceptIcon"></i></button>
                                       
                       <span class="pull-right"></span>
                    </div>
                    <div id="placeLocation_edit" class="subPlaceDetails hidden">
                    <div class="form-group">
                    <label for="placeLocationTypeValue">Place feature Type</label>
                    <input id="placeLocationTypeValue" name="placeLocationTypeValue" readonly="readonly" type="text" value="{ $locationType}"/>
                    </div>
                    <div class="form-group">
                    <label for="placeLocationLongitudeValue">Longitude</label>
                    <input id="placeLocationLongitudeValue" name="placeLocationLongitudeValue" type="text" value="{ $longitude }"/>
                    </div>
                    <div class="form-group">
                    <label for="placeLocationLatitudeValue">Latitude</label>
                    <input id="placeLocationLatitudeValue" name="placeLocationLatitudeValue" type="text" value="{ $latitude }"/>
                    </div>
                    <div class="form-group">
                    <label for="polygonCoordinatesValue">Coordinates for polygons</label>
                    <textarea id="polygonCoordinatesValue" name="placeLocationLatitudeValue" readonly="readonly" type="text" value="{ $coordinates}">{ $coordinates}</textarea>
                    </div>
                    <button id="subTypeFeaturesSaveButton" class="btn btn-success"
                         onclick="saveLocation()"
                                 appearance="minimal" type="button"><i class="glyphicon
         glyphicon glyphicon-ok-circle"></i></button>
                         <button id="subTypeFeaturesCancelEdit" class="btn btn-danger"
                         onclick="cancelEditLocation() "
                                 appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                    </div>    
            </div>
            )
            else  <div class=""><em>----</em></div>
            }
            

            </div>

       </div>
};

declare function spatiumStructor:getPlaceTypeIcon($placeType as xs:string){
            switch($placeType)
            case 'city' return 'City'
            case "" return ""
            default return "type: " || $placeType
        };


declare function spatiumStructor:peripleoWidget($target as xs:string){
    <div>
        <iframe id="{ $target }_peripleoWidget" allowfullscreen="true" height="380" src="" style="display:none;"> </iframe>
        <div id="{ $target }_previewMap" class="hidden"/>
        <div id="{ $target }_placePreviewPanel" class="hidden"/>
    </div>
};
declare function spatiumStructor:xmlFileEditor($resourceId as xs:string){
     let $xmlResource := $spatiumStructor:project-place-collection/id($resourceId)
    return
    <div>
                <div class="textModifiedAlert" id="fileModifiedAlert">File has been modified</div>
               <button id="saveFileButton" class="saveTextButton btn btn-primary" onclick="saveFile('{$resourceId}', 1)" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
               <div id="xml-editor-file" class="">{serialize($xmlResource, ())}</div>
   </div>
};

declare function spatiumStructor:xmlFileEditorWithUri($resourceUri as xs:string){
     let $xmlResource := 
     <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:cito="http://purl.org/spar/cito/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ausohnum="http://ausonius.huma-num.fr/onto" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
     { $spatiumStructor:project-place-collection//rdf:RDF[spatial:Feature[@rdf:about = $resourceUri]] }
     
</rdf:RDF>

return
    <div>
                <div class="textModifiedAlert" id="fileModifiedAlert">File has been modified</div>
               <button id="saveFileButton" class="saveTextButton btn btn-primary" onclick="saveXmlFile('{$resourceUri}')" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
               { $resourceUri }
               <div id="xml-editor-file" class="">{serialize($xmlResource, ())}</div>
   </div>
};
declare function spatiumStructor:xmlFileEditorWithResourceAndUri($resource as node(), $resourceUri as xs:string){
     let $xmlResource := 
     <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:cito="http://purl.org/spar/cito/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ausohnum="http://ausonius.huma-num.fr/onto" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
     { $resource }
     
</rdf:RDF>

return
    <div>
                <div class="textModifiedAlert" id="fileModifiedAlert">File has been modified</div>
               <button id="saveFileButton" class="saveTextButton btn btn-primary" onclick="saveXmlFile('{$resourceUri}')" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
               { $resourceUri }
               <div id="xml-editor-file" class="">{serialize($resource, ())}</div>
   </div>
};

declare function spatiumStructor:saveData($data, $project ){


let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)

(:let $doc-collection := collection($config:data-root || "/" || $spatiumStructor:project || "/documents"):)

let $contentType := $data//contentType/text()
let $resourceURI := $data//resourceURI/text()

let $index := $data//index/text()

let $xpath := $data//xpath/text()
let $xpathEnd := if(matches(functx:substring-after-last($xpath, '/'), "/@"))
            then(
                functx:substring-after-last(functx:substring-before-last($xpath, '/'), '/')
                )
            else
            (functx:substring-after-last($xpath, '/')
            )




let $xpathEndNoSelector :=if(contains($xpathEnd, "[@"))
        then substring-before($xpathEnd, '[@') else $xpathEnd

let $xpathEndSelector := if(contains($xpathEnd, "[@")) then
                    substring-before(substring-after($xpathEnd, '[@'), ']') else ""
let $xpathEndSelectorName :=
                    substring-before($xpathEndSelector, '=')
let $xpathEndSelectorValue :=
                    substring-before(substring-after($xpathEndSelector, '="'), '"')


let $endingSelector := if(matches(functx:substring-after-last($xpath, '/'), "@"))
            then(
                functx:substring-after-last($xpath, '/@')
                )
            else
            (
            )

(:let $resourceId := request:get-parameter('docid', ()):)
(:let $teiDoc := $spatiumStructor:doc-collection/id($resourceId):)
let $paramMap :=
        map {
            "method": "xml",
            "indent": false(),
            "item-separator": ""

   }
let $updatedData := if($data//value/text())
                then $data//value
                    else " "


let $newElement := if($contentType = "text") then
        if(matches(functx:substring-after-last($xpath, '/'), "@")) then(
            <newElement>{element {string($xpathEndNoSelector)}
                {attribute {string($xpathEndSelectorName)} {$xpathEndSelectorValue }, functx:trim($data//value/node())
              }}</newElement>
          )
        else(
            <newElement>{
                element {string($xpathEndNoSelector)}
                    { functx:trim($data//value/node())}
                  }</newElement>)

            else ""


let $updatedDataTextValue := $data//valueTxt/text()



let $xpathWithPrefix := if(contains($data//xpath/text(), "/@"))
                                          then
                                          substring-before($data//xpath/text(), '/@') || '[' || $index || ']/' || functx:substring-after-last($data//xpath/text(), '/')
                                          else
                                          $data//xpath/text() || '[' || $index || ']'

(:if($index = 0) then $data//xpath/text()
                                          else if ($index >= 1) then
                                          $data//xpath/text() || '[' || $index || ']'
(\:                                            substring-before($data//xpath/text(), '/@') || "[" || $index || "]/" || functx:substring-after-last($data//xpath/text(), '/'):\)
                                          else ( $data//xpath/text() )
:)
let $quote := "&amp;quote;"

let $originalXMLNode :=util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"
(:             ||$resourceURI ||"']" || substring-before($xpathWithPrefix, '/@')):)
             ||$resourceURI ||"']" || $xpathWithPrefix)


let $oldValueTxt := data($originalXMLNode)

let $originalXMLNodeWithoutAttribute :=
            if(contains($xpathWithPrefix, '/@')) then 
            util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
             ||$resourceURI ||"']/" || functx:substring-before-last($xpathWithPrefix, '/') )
             else (util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
             ||$resourceURI ||"']" || $xpathWithPrefix ))


let $elementNickname := $data//elementNickname/text()



let $upateData :=
        switch ($contentType)

         case "textNodeAndAttribute" return
                (
(:                Chech if node exists in resource:)
                    (if( exists($originalXMLNode)) then
                            update value $originalXMLNode with $updatedData (:Update attribute:)
        (:                    update value $originalXMLNode with $updatedData:)

                            else
                                (update insert attribute ref { functx:trim($data//value/node()) } into $originalXMLNodeWithoutAttribute,
                                update value $originalXMLNode with $updatedData)
                    ),
                update value $originalXMLNodeWithoutAttribute with $updatedDataTextValue (:Updating text node:)
                )
         case "attribute" return
                update value $originalXMLNode with data($updatedData)
         case "text"  return
                    (
                    (:spatiumStructor:logEvent("logs-debug", "test", $resourceURI, (), "avant: $originalXMLNodeWithoutAttribute/text(): " || serialize($originalXMLNodeWithoutAttribute || " data($updatedData/text()" || data($updatedData/text()), ())
                ),:)
                
                  if ($updatedData = " ") then update value $originalXMLNodeWithoutAttribute/text() with data($updatedData)
                
                else update value $originalXMLNodeWithoutAttribute with data($updatedData/text())
                
                
                
(:                update value $originalXMLNodeWithoutAttribute/text() with data($updatedData):)
                )
(:                        update replace $originalXMLNode with functx:change-element-ns-deep($newElement, "http://www.tei-c.org/ns/1.0", "")/node():)
         case "nodes" return
                update value $originalXMLNode with $updatedData/node()
         default return

                update replace $originalXMLNode with functx:change-element-ns-deep($newElement, "http://www.tei-c.org/ns/1.0", "")
(:            update replace $originalXMLNode/node() with $updatedData/node():)

let $newContent := <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:cito="http://purl.org/spar/cito/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ausohnum="http://ausonius.huma-num.fr/onto" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
{ util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//rdf:RDF[spatial:Feature[@rdf:about='"
             ||$resourceURI ||"']]" ) }</rdf:RDF>

let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]))) 
    then $spatiumStructor:placeElements//xmlElement[nm=$elementNickname] 
                        else $spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]
     
let $elementNickname4update := if($elementNode/ancestor::xmlElement[1]/fieldType/text() = "group")
                                                    then $elementNode/ancestor::xmlElement[1]/nm/text()
                                                    else $elementNickname
 let $index4Update:= if($elementNode/ancestor::xmlElement[1]/fieldType/text() = "group")
                                                    then ()
                                                    else 
                                                    (
                                                    if( $index="") then "1" else $index)
let $xpath4Update:= if($elementNode/ancestor::xmlElement[1]/fieldType/text() = "group")
                                                    then $elementNode/ancestor::xmlElement[1]/xpath/text()
                                                    else 
                                                    (
                                                    )

let $updatedElement := 
        if($elementNode/ancestor::xmlElement[1]/fieldType/text() = "group")
            then spatiumStructor:displayGroup($elementNickname4update, xmldb:decode-uri($resourceURI), $index4Update, (), $xpath4Update)
            else spatiumStructor:displayElement($elementNickname, xmldb:decode-uri($resourceURI), (), ())


(:let $log := spatiumStructor:logEvent("all-logs", "place-update" ||$index, $resourceURI,
    (), "Change in " || $resourceURI ||
    "$elementNickname" || $elementNickname ||
    "$originalXMLNode: " || serialize($originalXMLNode, ()) ||
    "$updatedData: " || serialize($updatedData, ())
    || "div id: " || $elementNickname || "_group_" || $index
    )
:)


    return
    (response:set-header("Connection", "Close"),
    <data>{$data}
    <oldContent>{ $oldValueTxt }</oldContent>
    <newContent>{ $newContent }</newContent>
    <updatedElement>{ $updatedElement }</updatedElement>
    <newValue2Display>{ $updatedDataTextValue }</newValue2Display>
    <elementIdToReplace>{$elementNickname}_group_1</elementIdToReplace>

</data>
)
};

declare function spatiumStructor:saveDataWithConceptHierarchy($data, $project ){


let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)

(:let $doc-collection := collection($config:data-root || "/" || $spatiumStructor:project || "/documents"):)

let $contentType := $data//contentType/text()
let $resourceURI := $data//resourceURI/text()

let $elementNickname := $data//elementNickname/text()
let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]))) 
    then $spatiumStructor:placeElements//xmlElement[nm=$elementNickname] 
                        else $spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]

let $conceptUris := tokenize($data//valueConceptHierarchy/text(), " ")

let $index := $data//index/text()

let $xpath := $data//xpath/text()

let $targetNode :=if(contains($xpath, "/@"))
                then  functx:substring-after-last(substring-before($xpath, "/@"), '/')
                else functx:substring-after-last($xpath, '/')
    
    
let $xpath2Node := if(contains($xpath, "[@"))
        then substring-before($xpath, '[@') else $xpath

let $xpathEnd := if(matches(functx:substring-after-last($xpath, '/'), "/@"))
            then(
                functx:substring-after-last(functx:substring-before-last($xpath, '/'), '/')
                )
            else
            (functx:substring-after-last($xpath, '/')
            )
            



let $xpathEndNoSelector :=if(contains($xpathEnd, "[@"))
        then substring-before($xpathEnd, '[@') else $xpathEnd

let $xpathEndSelector := if(contains($xpathEnd, "[@")) then
                    substring-before(substring-after($xpathEnd, '[@'), ']') else ""
let $xpathEndSelector :=
                    substring-before($xpathEndSelector, '=')
let $xpathEndSelectorValue :=
                    substring-before(substring-after($xpathEndSelector, '="'), '"')


let $endingSelector := if(matches(functx:substring-after-last($xpath, '/'), "@"))
            then(
                functx:substring-after-last($xpath, '/@')
                )
            else
            (
            )

let $updatedData := if($data//value/text())
                then $data//value
                    else " "

let $qnameForNewElement := functx:substring-before-if-contains($targetNode, '[@')
let $specificAttributeName := functx:substring-after-if-contains(substring-before($targetNode, '='), "[@")
let $specificAttributeValue := if($specificAttributeName != "") then substring-before(substring-after($targetNode, '="'), '"]')
                                                else ""

let $attributeName := substring-after($xpathEnd, "@")
let $newElements := <newElement>{
        for $concept in $conceptUris
        
            let $label := if($contentType = "text") then skosThesau:getLabel($concept, "en") else ""
                return
                element {string($qnameForNewElement)}
                {
                if($specificAttributeName != "") then (
                attribute {$specificAttributeName} {$specificAttributeValue}
                ) else(),
                
                attribute {$attributeName} { $concept },
                
                $label
              }
              }</newElement>
              
    (:if($contentType = "text") then
            if(matches(functx:substring-after-last($xpath, '/'), "@")) then(
            <newElement>{element {string($xpathEndNoSelector)}
                {attribute {string($xpathEndSelectorName)} {$xpathEndSelectorValue }, functx:trim($data//value/node())
              }}</newElement>
              )
        else(
            for $concept in $conceptUris
                return
            <newElement>{
                element {string($xpathEndNoSelector)}
                    { functx:trim($concept)}
                  }</newElement>)

            else "":)






let $updatedDataTextValue := $data//valueTxt/text()



let $xpathWithPrefix := if(contains($data//xpath/text(), "/@"))
                                          then
                                          substring-before($data//xpath/text(), '/@') || '[' || $index || ']/' || functx:substring-after-last($data//xpath/text(), '/')
                                          else
                                          $data//xpath/text() (:|| '[' || $index || ']':)

(:if($index = 0) then $data//xpath/text()
                                          else if ($index >= 1) then
                                          $data//xpath/text() || '[' || $index || ']'
(\:                                            substring-before($data//xpath/text(), '/@') || "[" || $index || "]/" || functx:substring-after-last($data//xpath/text(), '/'):\)
                                          else ( $data//xpath/text() )
:)
let $quote := "&amp;quote;"

let $originalXMLNode :=util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"
(:             ||$resourceURI ||"']" || substring-before($xpathWithPrefix, '/@')):)
             ||$resourceURI ||"']/" || $xpath2Node)


let $oldValueTxt := data($originalXMLNode)

let $originalXMLNodeWithoutAttribute :=
            if(contains($xpathWithPrefix, '/@')) then 
            util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
             ||$resourceURI ||"']/" || functx:substring-before-last($xpathWithPrefix, '/') )
             else (util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
             ||$resourceURI ||"']" || $xpathWithPrefix ))




let $upateData :=
        switch ($contentType)

         case "textNodeAndAttribute" return
                (
(:                Chech if node exists in resource:)
                    (if( exists($originalXMLNode)) then
                            update value $originalXMLNode with $updatedData (:Update attribute:)
        (:                    update value $originalXMLNode with $updatedData:)

                            else
                                (update insert attribute ref { functx:trim($data//value/node()) } into $originalXMLNodeWithoutAttribute,
                                update value $originalXMLNode with $updatedData)
                    ),
                update value $originalXMLNodeWithoutAttribute with $updatedDataTextValue (:Updating text node:)
                )
         case "attribute" return
                if(count($conceptUris) >= count($originalXMLNode)) then
                    (
                        for $element at $pos in $conceptUris
                            return 
                                if(exists($originalXMLNode[position() = $pos]))
                                    then update replace $originalXMLNode[position() = $pos] with $newElements/node()[position() = $pos]
                                    else update insert $newElements/node()[position() = $pos] following $originalXMLNode[position() = last()]
                    )
                    else(
                        for $element at $pos in $originalXMLNode
                            return
                            (
                            if(exists($element[position() = $pos]))
                                then update replace $originalXMLNode[position() = $pos] with $newElements/node()[position() = $pos]
                                else update delete $originalXMLNode[position() = $pos]
                            )
                    )
         case "text"  return
                    (
                    (:spatiumStructor:logEvent("logs-debug", "test", $resourceURI, (), "avant: $originalXMLNodeWithoutAttribute/text(): " || serialize($originalXMLNodeWithoutAttribute || " data($updatedData/text()" || data($updatedData/text()), ())
                ),:)
                
                  if ($updatedData = " ") then update value $originalXMLNodeWithoutAttribute/text() with data($updatedData)
                
                else update value $originalXMLNodeWithoutAttribute with data($updatedData/text())
                
                
                
(:                update value $originalXMLNodeWithoutAttribute/text() with data($updatedData):)
                )
(:                        update replace $originalXMLNode with functx:change-element-ns-deep($newElement, "http://www.tei-c.org/ns/1.0", "")/node():)
         case "nodes" return
                update value $originalXMLNode with $updatedData/node()
         default return

                update replace $originalXMLNode with functx:change-element-ns-deep($newElements, "http://www.tei-c.org/ns/1.0", "")
(:            update replace $originalXMLNode/node() with $updatedData/node():)

let $newContent := <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:cito="http://purl.org/spar/cito/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ausohnum="http://ausonius.huma-num.fr/onto" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
{ util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//rdf:RDF[spatial:Feature[@rdf:about='"
             ||$resourceURI ||"']]" ) }</rdf:RDF>

     
let $elementNickname4update := if($elementNode/ancestor::xmlElement[1]/fieldType/text() = "group")
                                                    then $elementNode/ancestor::xmlElement[1]/nm/text()
                                                    else $elementNickname
 let $index4Update:= if($elementNode/ancestor::xmlElement[1]/fieldType/text() = "group")
                                                    then ()
                                                    else 
                                                    (
                                                    if( $index="") then "1" else $index)
let $xpath4Update:= if($elementNode/ancestor::xmlElement[1]/fieldType/text() = "group")
                                                    then $elementNode/ancestor::xmlElement[1]/xpath/text()
                                                    else 
                                                    (
                                                    )

let $updatedElement := 
        if($elementNode/ancestor::xmlElement[1]/fieldType/text() = "group")
            then spatiumStructor:displayGroup($elementNickname4update, xmldb:decode-uri($resourceURI), $index4Update, (), $xpath4Update)
            else spatiumStructor:displayElement($elementNickname, xmldb:decode-uri($resourceURI), (), ())


(:let $log := spatiumStructor:logEvent("all-logs", "place-update" ||$index, $resourceURI,
    (), "Change in " || $resourceURI ||
    "$elementNickname" || $elementNickname ||
    "$originalXMLNode: " || serialize($originalXMLNode, ()) ||
    "$updatedData: " || serialize($updatedData, ())
    || "div id: " || $elementNickname || "_group_" || $index
    )
:)


    return
    (response:set-header("Connection", "Close"),
    <data>{$data}
    <conceptUris>{$conceptUris}</conceptUris>
    <newElements>{ $newElements }</newElements>
    <originalNode>{ $originalXMLNode }</originalNode>
    <newElement1>{ $newElements/node()[position() = 1] }</newElement1>
    <specificAttributeName>{ $specificAttributeName }</specificAttributeName>
    <specificAttributeValue>{ $specificAttributeValue }</specificAttributeValue>
    <originalNodePath>{"collection('" || $spatiumStructor:project-place-collection-path || "')//spatial:Feature[@rdf:about='"
(:             ||$resourceURI ||"']" || substring-before($xpathWithPrefix, '/@')):)
             ||$resourceURI ||"']/" || $xpath2Node}</originalNodePath>
             <targetnode>{ $targetNode }</targetnode>
             <xpathEnd>{ $xpathEnd }</xpathEnd>
             <xpathEndNoSelector>{$xpathEndNoSelector}</xpathEndNoSelector>
             <xpathEndSelector>{$xpathEndSelector}</xpathEndSelector>
    <oldContent>{ $oldValueTxt }</oldContent>
    <newContent>{ $newContent }</newContent>
    <updatedElement>{ $updatedElement }</updatedElement>
    <newValue2Display>{ $updatedDataTextValue }</newValue2Display>
    <elementIdToReplace>{$elementNickname}_group_1</elementIdToReplace>

</data>
)
};

declare function spatiumStructor:saveXmlFile($data, $project ){


let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)

let $resourceURI := $data//resourceURI/text()
let $newContent := <rdf:RDF 
    xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:lawdi="http://lawd.info/ontology/"
    xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:pleiades="https://pleiades.stoa.org/places/vocab#"
    xmlns:prov="http://www.w3.org/TR/prov-o/#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:spatium="http://ausonius.huma-num.fr/spatium-ontoology"
    xmlns:spatial="http://geovocab.org/spatial#">{$data//newContent/node()}</rdf:RDF>
    
 let $newSpatialFeature := $data//newContent//spatial:Feature
 let $newLocation := $data//newContent//pleiades:Location
let $log := spatiumStructor:logEvent("all-logs", "TEST-place-update-xmlfile", $resourceURI,
    <new>{$newSpatialFeature}{$newLocation}</new>, "Change in " || $resourceURI ||
    "new content" || serialize($newContent, ()))



(:
let $deleteOldData :=
                  update delete 
                  util:eval( "collection('" || $spatiumStructor:project-place-collection-path 
                  || "')//rdf:RDF[spatial:Feature[matches(./@rdf:about, '"
               ||$resourceURI ||"')]]/node()" ):)
let $updateNewData :=(
             update replace
                     util:eval( "collection('" || $spatiumStructor:project-place-collection-path 
                     || "')//spatial:Feature[@rdf:about = '"
                  ||$resourceURI ||"']") with $newSpatialFeature
                  ,
                  update replace util:eval( "collection('" || $spatiumStructor:project-place-collection-path 
                     || "')//pleiades:Location[@rdf:about, '"
                  ||substring-before($resourceURI, "#this") ||"']") with $newLocation
                  )
                  
                  (:update insert functx:change-element-ns-deep($newContent/node(), 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', '') into
                     util:eval( "collection('" || $spatiumStructor:project-place-collection-path 
                     || "')//rdf:RDF[spatial:Feature[matches(./@rdf:about, '"
                  ||$resourceURI ||"')]]" ):)
                


let $log := spatiumStructor:logEvent("all-logs", "place-update-xmlfile", $resourceURI,
    <new>{$newSpatialFeature}{$newLocation}</new>, "Change in " || $resourceURI ||
    "new content" || serialize($newContent, ()))


let $updatedFile := spatiumStructor:getPlaceHTML(substring-before($resourceURI, "#this"))


    
    



    return

    <data>{$data}
    <updatedFile>{ $updatedFile }</updatedFile>
    
</data>

};
declare function spatiumStructor:saveTextarea($data, $project){
let $now := fn:current-dateTime()
let $currentUser := sm:id()//sm:real/sm:username

let $currentUserUri := concat($teiEditor:baseUri[1], '/people/' , $currentUser)

let $resourceUriLong := $data//resourceUri/text()
let $resourceUri :=  substring-before($resourceUriLong , "#this")
let $resourceDoc := util:eval( "$spatiumStructor:project-place-collection//spatial:Feature[@rdf:about='"||$resourceUriLong ||"']")

let $elementNickname :=
            $data//elementNickName/text()
let $elementNode :=if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]))) 
                                        then $spatiumStructor:placeElements//xmlElement[nm=$elementNickname] 
                                        else $spatiumStructor:placeElementsCustom//xmlElement[nm=$elementNickname]

let $xpath :=  $data//xpath/text()
let $index := data($data//index)


let $newText := $data//newText 
(:functx:change-element-ns-deep(<ab>{$data//newText/node()}</ab>, 'http://www.tei-c.org/ns/1.0', ''):)



let $originalNodeWithoutAttribute := 
            if(contains($xpath, '/@')) then util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about = '"
             || $resourceUriLong ||"']/" || functx:substring-before-last($xpath, '/') )
             else (util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
             ||$resourceUriLong ||"']" || $xpath ))

let $updateXml := if($newText = " " or $newText = " ") then
                update value
                    $originalNodeWithoutAttribute/text() with $newText
                    else  if ($newText/*[local-name()='p']) then
                    update value $originalNodeWithoutAttribute 
                    with functx:change-element-ns-deep($newText/*[local-name()='p']/node(), "", "")
                    else update value $originalNodeWithoutAttribute 
                    with functx:change-element-ns-deep($newText/node(), "", "")
let $log := teiEditor:logEvent("document-update-" ||$index, $resourceUri, $data, $xpath )

let $newContent := <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:cito="http://purl.org/spar/cito/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ausohnum="http://ausonius.huma-num.fr/onto" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
{ util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//rdf:RDF[spatial:Feature[@rdf:about='"
             ||$resourceUriLong ||"']]" ) }</rdf:RDF>
return

<data>{$data}
<newContent>{ $newContent}</newContent>
</data>


};

declare function spatiumStructor:logEvent($logType as xs:string,
                                                      $eventType as xs:string,
                                                      $resourceId as xs:string,
                                                      $data as node()?,
                                                      $description as xs:string?){
    let $project := request:get-parameter("project", ())
    let $logs := collection('/db/apps/' || $project || 'Data/logs')
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $log :=
<data>
    <log type="{$eventType}" when="{$now}" what="{$resourceId}" who="{$currentUser}">
        {$data}
        <description>{$description}</description>
    </log>
 </data>
return
    update insert
         $log/node()
         into $logs/rdf:RDF/id($logType)
};


declare function spatiumStructor:listPossibleFeatures($resourceId as xs:string){
let $mainTypeFeature := util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')/id('"|| $resourceId ||"')//pleiades:hasFeatureType[@type='main']")
let $subTypeFeatures := <subTypeFeatures>{ util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')/id('"|| $resourceId ||"')//pleiades:hasFeatureType[@type='sub']") }</subTypeFeatures>

return
<div class="xmlElementGroup">
    <div id="subTypeFeatures_display" class="">
         <div class="xmlElementGroupHeaderInline">
              <span class="labelForm">Present features<span class="xmlInfo">
                   <a title='XML element: pleiades:hasFeatureType[@type="sub"]'><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                   </span>
                   <button id="editSubTypeFeatures" class="btn btn-primary editbutton"
                      onclick="editValue('subTypeFeatures', '', '')"
                             appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                       editConceptIcon"></i></button>
               </span>
          </div>
          <div id="subTypeFeatures_display__" class="xmlElementValue">
                {for $feature in $subTypeFeatures//pleiades:hasFeatureType
                   let $prefLabel := skosThesau:getLabel($feature/@rdf:resource, "en")
                   return
                        <span class="resourceRef">{$prefLabel}
                        </span>
                        }
                        {data($subTypeFeatures//pleiades:hasFeatureType[1]/@rdf:resource)}
            </div>

            <div id="subTypeFeatures_edit__" class="xmlElementHidden form-group">
                 <div class="input-group" >
                 <button id="subTypeFeaturesSaveButton" class="btn btn-success"
                         onclick="saveDataSimple()"
                                 appearance="minimal" type="button"><i class="glyphicon
         glyphicon glyphicon-ok-circle"></i></button>
                         <button id="subTypeFeaturesCancelEdit" class="btn btn-danger"
                         onclick="javascript:cancelEdit('subTypeFeatures', '', '', 'input', '1') "
                                 appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                 {
                 let $possibleFeatures := skosThesau:getChildren($mainTypeFeature/@rdf:resource, "en")
                 for $feature at $pos in $possibleFeatures//skos:Concept
                    let $prefLabel :=
                    $feature//skos:prefLabel[@xml:lang='en']
                    return

                     <input class="" value="{ $feature/@rdf:about }" type="checkbox" name="feature_{ $pos }" checked="{if(exists($subTypeFeatures//pleiades:hasFeatureType[@rdf:resource=data($feature/@rdf:about)])) then "checked" else ()}">
                            { $prefLabel }
                     </input>

                 }



                  </div>
            </div>
        </div>
    </div>
};

declare function spatiumStructor:listConceptAsCheckboxes($concepts as node(), $lang as xs:string){

        <div>
        {
        for $concept at $pos in $concepts//skos:Concept
        return
            <input class="" value="{ $concept/@rdf:about }" type="checkbox" name="feature_{ $pos }">
            { $concept//skos:prefLabel[@xml:lang=$lang]/text()}
            </input>
                }
                </div>
};


declare function spatiumStructor:biblioManager($resourceUri as xs:string?){
(:let $resource := util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//id('" || $resourceId ||"')" ):)
let $resource := $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about= $resourceUri]
(:   let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

   return
   <div class="xmlElementGroup">

   <div class="xmlElementGroupHeaderBlock">
   <span class="labelForm">Main Bibliography</span>
   <button id="docBilioAddItem" class="btn btn-primary addItem" onclick="openBiblioDialog()" appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>


   </div>
      <div id="mainBiblioList" class="itemList">
   {for $bibRef at $pos in $resource//cito:citesForInformation
(:   order by $bibRef//tei:ptr/@target:)
    return
    teiEditor:displayBibRef($resourceUri, $bibRef, "edition", $pos)
(:    teiEditor:displayBibRef($teiEditor:docId, substring(data($bibRef/tei:ptr/@target), 2)):)
   }
   </div>



    <!--Dialog for Biblio-->
    <div id="dialogInsertBiblio" title="Add a Bibliographical Reference" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Insert a bibliographical Reference</h4>
                </div>
                <div class="modal-body">
                      <form id="addBiblioForm" role="form" data-toggle="validator" novalidate="true">
                            <div class="form-group">
                                <label for="nameLookupInputModal">Search in <a href="https://www.zotero.org/groups/{$spatiumStructor:appVariables//zoteroGroup/text()}" target="_blank">Zotero Group {$teiEditor:appVariables//zoteroGroup/text()}</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupInputModal" name="zoteroLookupInputModal" autocomplete="on"
                                placeholder="Start to enter a author name or a word..."/>
                            </div>
                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange" name="citedRange"
                                data-error="Please enter your full name."/>

                            </div>
                            <div id="zoteroGroupNo" class="">{$spatiumStructor:appVariables//zoteroGroup/text()}</div>
                            <div id="selectedBiblioAuthor"/>
                            <div id="selectedBiblioDate"/>
                            <div id="selectedBiblioTitle"/>
                            <div id="selectedBiblioUri"/>
                            <div id="selectedBiblioId" />


                    <div class="form-group modal-footer">


                        <button  class="pull-left" type="submit" onclick="addBiblioRef('{$resourceUri}', '{$spatiumStructor:appVariables//zoteroGroup/text()}', 'main')">Add reference</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  </form>
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    </div>

   </div>

};
declare function spatiumStructor:resourcesManager($type as xs:string, $placeUri as xs:string){
let $placeRdf :=  util:eval('$spatiumStructor:project-place-collection//pleiades:Place[@rdf:about="' ||  $placeUri || '"]')
(:let $placeRdf := util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')/ple('"
                || $placeUri ||"')"):)
let $refs := ($placeRdf//cito:citesForInformation)
return 

   <div id="resourcesManager{ $type }" class="xmlElementGroup" >

   <div class="xmlElementGroupHeaderBlock">
   <span class="labelForm">{ switch($type)
                                                        case 'seeFurther' return 'Bibliography'
                                                        default return $type}<span class="xmlInfo">
                     <a title="XML element: cito:citesForInformation"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                     </span></span>
                                                       
   <button id="{$type}AddItem" class="btn btn-primary addItem" onclick="openDialog('dialogInsertResource{$type}')" appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>


   </div>
      <div id="{ $type }List" class="resourceList">
   {for $resource at $pos in $refs

    return
            spatiumStructor:displayResource($placeUri, $resource, $type, $pos)
(:    teiEditor:displayBibRef($resourceId, $bibRef):)
(:    teiEditor:displayBibRef($teiEditor:docId, substring(data($bibRef/tei:ptr/@target), 2)):)
   }
   </div>
   </div>


    

};

declare function spatiumStructor:addResourceDialog($type as xs:string){

    <div id="dialogInsertResource{$type}" title="Add a Reference to a Resource" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Add a Reference to a Resource</h4>
                </div>
                <div class="modal-body">
                      <form id="addResourceForm" class="addResourceForm" role="form" data-toggle="validator" novalidate="true">
                            <div class="form-group">
                                <label for="nameLookupInputModal">Search in <a href="https://www.zotero.org/groups/{$spatiumStructor:appVariables//zoteroGroup/text()}" target="_blank">Zotero Group {$teiEditor:appVariables//zoteroGroup/text()}</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupInputModal"
                                name="zoteroLookupInputModal" autocomplete="off"
                                placeholder="Start to enter an author name or a word..."/>
                            </div>
                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange" name="citedRange"
                                data-error="Please enter your full name."/>

                            </div>
                            <div id="zoteroGroupNo" class="hidden">{$spatiumStructor:appVariables//zoteroGroup/text()}</div>
                            <div id="selectedResourceAuthor" class="valueField"/>
                            <div id="selectedResourceDate" class="valueField"/>
                            <div id="selectedResourceTitle" class="valueField"/>
                            <div id="selectedResourceUri" class="valueField"/>
                            <div id="selectedResourceId" class="valueField"/>


                    <div class="form-group modal-footer">


                        <button  class="pull-left" type="submit" onclick="addResourceToPlace('{$spatiumStructor:appVariables//zoteroGroup/text()}', '{$type}')">Add reference</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  </form>
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    </div>

   };
declare function spatiumStructor:displayResourceList($type as xs:string, $placeId as xs:string){


(:let $place:= util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//id('" || $placeId ||"')" ):)
let $place := $spatiumStructor:project-place-collection//id($placeId)
(:   let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

   return
   <div class="xmlElementGroup">

   <div class="xmlElementGroupHeaderBlock">
   <span class="labelForm">{$type}</span>
   <button id="{$type}AddItem" class="btn btn-primary addItem" onclick="openDialog('dialogInsertResource{$type}')" appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>


   </div>
      <div id="{ $type }List" class="resourceList">
   {for $resource at $pos in $place//ausohnum:hasResource[@type=$type]

    return
            spatiumStructor:displayResource($placeId, data($resource/@rdf:resource))
(:    teiEditor:displayBibRef($resourceId, $bibRef):)
(:    teiEditor:displayBibRef($teiEditor:docId, substring(data($bibRef/tei:ptr/@target), 2)):)
   }
   </div>



    <!--Dialog for Resource-->
    <div id="dialogInsertResource{$type}" title="Add a Reference to a Resource" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Insert a Reference to a Resource</h4>
                </div>
                <div class="modal-body">
                      <div id="addResourceForm" role="form" data-toggle="validator" novalidate="true">
                            <div class="form-group">
                                <label for="nameLookupInputModal">Search in <a href="https://www.zotero.org/groups/{$spatiumStructor:appVariables//zoteroGroup/text()}" target="_blank">Zotero Group {$teiEditor:appVariables//zoteroGroup/text()}</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupInputModal" name="zoteroLookupInputModal" autocomplete="on"
                                placeholder="Start to enter a author name or a word..."/>
                            </div>
                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange" name="citedRange"
                                data-error="Please enter your full name."/>

                            </div>
                            <div id="zoteroGroupNo" class="hidden">{$spatiumStructor:appVariables//zoteroGroup/text()}</div>
                            <div id="selectedResourceAuthor" class="valueField"/>
                            <div id="selectedResourceDate" class="valueField"/>
                            <div id="selectedResourceTitle" class="valueField"/>
                            <div id="selectedResourceUri" class="valueField"/>
                            <div id="selectedResourceId" class="valueField"/>


                    <div class="form-group modal-footer">


                        <button  class="pull-left" type="submit" onclick="addResourceRef('{$placeId}', '{$spatiumStructor:appVariables//zoteroGroup/text()}', '{$type}')">Add reference</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  </div>
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    </div>

   </div>

};

(:declare function spatiumStructor:displayResource( $docUri as xs:string, $resourceUri as xs:string, $type as xs:string, $index as xs:int){
        let $resource := 
                switch($type)
                case "illustration" return $spatiumStructor:resourceRepo//ausohnum:resource[@rdf:about=$resourceUri]
                case "seeFurther" return $teiEditor:biblioRepo//tei:biblStruct[equals(./@corresp, $resourceUri)]
                default return $teiEditor:biblioRepo//tei:biblStruct[equals(./@corresp, $resourceUri)]
        let $xpath := switch ($type)
           case "seeFurther" return "/cito:citesForInformation"
           case "illustration" return
                    '/ausohnum:hasResource[@type="illustration"]'
                                (\:case "secondary" return
                                     //tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl
                     :\)
       default return null

        let $imageUrl := $resource//bibo:Image/bibo:uri/text()
        let $zoteroUrl := $resource//owl:sameAs[1]/@rdf:resource/text()
        let $title := 
               if($resource//bibo:Image/dcterms:title) then $resource//bibo:Image/dcterms:title[1]
                          else ("No title found")
        let $authorLastName := <span class="lastname">{ 
                if($resource[1]//tei:author[1]/tei:surname) then 
                        if(count($resource[1]//tei:author) = 1) then data($resource[1]//tei:author[1]/tei:surname)
                        else if(count($resource[1]//tei:author) = 2) then data($resource[1]//tei:author[1]/tei:surname) || " &amp; " || data($resource[1]//tei:author[2]/tei:surname)
                        else if(count($resource[1]//tei:author) > 2) then  <span>{ data($resource[1]//tei:author[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                else if ($resource[1]//tei:editor[1]/tei:surname) then
                            if(count($resource[1]//tei:editor) = 1) then data($resource[1]//tei:editor[1]/tei:surname)
                        else if(count($resource[1]//tei:editor) = 2) then data($resource[1]//tei:editor[1]/tei:surname) || " &amp; " || data($resource[1]//tei:editor[2]/tei:surname)
                        else if(count($resource[1]//tei:editor) > 2) then  <span>{ data($resource[1]//tei:editor[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                else ("[no name]")
                }</span>
        let $date := data($resource[1]//tei:imprint/tei:date)
        let $citedRange :=if($resource//tei:citedRange and $resource//tei:citedRange != "") then
                                                    if (starts-with(data($resource[1]//tei:citedRange), ',')) 
                                                    then data($resource[1]//tei:citedRange)
                                                    else (', ' || data($resource[1]//tei:citedRange))
                                    else if($resource//prism:pageRange) then 
                                    
                                            if (starts-with(data($resource//prism:pageRange), ',')) 
                                                    then data($resource//prism:pageRange)
                                                    else (', ' || data($resource//prism:pageRange))
                             else ()
          let $suffixLetter := 
                 if (matches(
                 substring(data($resource[1]/@xml:id), string-length(data($resource[1]/@xml:id))),
                 '[a-z]'))
                 then substring(data($resource[1]/@xml:id), string-length(data($resource[1]/@xml:id)))
                 else ''                               
        let $ref2display :=
                switch($type)
                    case "illustration" return if($resource//bibo:Image/dcterms:title) then $resource//bibo:Image/dcterms:title[1] else ()
                    case "seeFurther" return
                            (
                             if($resource[1]//tei:title[@type="short"]) then
                                     (data($resource[1]//tei:title[@type="short"]) || substring-after($citedRange, ','))
                             else ($authorLastName  || " " || $date || $suffixLetter || $citedRange)
                         )
                         
                    default return "Cannot get resource details"
                    
        return
        <div class="resourceRef">{switch ($type)
            case "illustration" return 
                     <div class="resourcePanel col-xs-4 col-sm-4 col-md-4">
                    <h5>{$title}</h5>
                            <ul>
                            <li><a href="{ $imageUrl }" target="_about">Flickr</a><br/></li>
                            <li><a href="{ $zoteroUrl }" target="_about">Zotero</a></li>
                            </ul>
                    </div>
             case "seeFurther" return <span><a href="{data($resource[1]/@corresp)}" target="_blank" class="btn btn-primary">{$ref2display}</a>
         <a class="removeItem" onclick="removeResourceFromList('{$docUri}', '{ $type }', '/pleiades:Place', '{$xpath}', '{ $index }')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a></span>
             default return null
        }</div>
};
:)
declare function spatiumStructor:displayResource( $docUri as xs:string, $resourceNode as node(), $type as xs:string, $index as xs:int){
        let $resourceUri := data($resourceNode/@rdf:resource)
        let $resource := 
                switch($type)
                case "illustration" return $spatiumStructor:resourceRepo//ausohnum:resource[@rdf:about=$resourceUri]
                case "seeFurther" return $teiEditor:biblioRepo//tei:biblStruct[equals(./@corresp, $resourceUri)]
                default return $teiEditor:biblioRepo//tei:biblStruct[equals(./@corresp, $resourceUri)]
        let $xpath := switch ($type)
           case "seeFurther" return "/cito:citesForInformation"
           case "illustration" return
                    '/ausohnum:hasResource[@type="illustration"]'
                                (:case "secondary" return
                                     //tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl
                     :)
       default return null

        let $imageUrl := $resource//bibo:Image/bibo:uri/text()
        let $zoteroUrl := $resource//owl:sameAs[1]/@rdf:resource/text()
        let $title := 
               if($resource//bibo:Image/dcterms:title) then $resource//bibo:Image/dcterms:title[1]
                          else ("No title found")
        let $authorLastName := <span class="lastname">{ 
                if($resource[1]//tei:author[1]/tei:surname) then 
                        if(count($resource[1]//tei:author) = 1) then data($resource[1]//tei:author[1]/tei:surname)
                        else if(count($resource[1]//tei:author) = 2) then data($resource[1]//tei:author[1]/tei:surname) || " &amp; " || data($resource[1]//tei:author[2]/tei:surname)
                        else if(count($resource[1]//tei:author) > 2) then  <span>{ data($resource[1]//tei:author[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                else if ($resource[1]//tei:editor[1]/tei:surname) then
                            if(count($resource[1]//tei:editor) = 1) then data($resource[1]//tei:editor[1]/tei:surname)
                        else if(count($resource[1]//tei:editor) = 2) then data($resource[1]//tei:editor[1]/tei:surname) || " &amp; " || data($resource[1]//tei:editor[2]/tei:surname)
                        else if(count($resource[1]//tei:editor) > 2) then  <span>{ data($resource[1]//tei:editor[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                else ("[no name]")
                }</span>
        let $date := data($resource[1]//tei:imprint/tei:date)
        let $citedRange :=if($resourceNode//tei:citedRange and $resourceNode//tei:citedRange != "") then
                                                    if (starts-with(data($resourceNode[1]//tei:citedRange), ',')) 
                                                    then data($resourceNode[1]//tei:citedRange)
                                                    else (', ' || data($resourceNode[1]//tei:citedRange))
                                    else if($resourceNode//prism:pageRange) then 
                                    
                                            if (starts-with(data($resourceNode//prism:pageRange), ',')) 
                                                    then data($resourceNode//prism:pageRange)
                                                    else (', ' || data($resourceNode//prism:pageRange))
                             else ()
          let $suffixLetter := 
                 if (matches(
                 substring(data($resource[1]/@xml:id), string-length(data($resource[1]/@xml:id))),
                 '[a-z]'))
                 then substring(data($resource[1]/@xml:id), string-length(data($resource[1]/@xml:id)))
                 else ''                               
        let $ref2display :=
                switch($type)
                    case "illustration" return if($resource//bibo:Image/dcterms:title) then $resource//bibo:Image/dcterms:title[1] else ()
                    case "seeFurther" return
                            (
                             if($resource[1]//tei:title[@type="short"]) then
                                     (data($resource[1]//tei:title[@type="short"]) || $citedRange)
                             else ($authorLastName  || " " || $date || $suffixLetter || $citedRange)
                         )
                         
                    default return "Cannot get resource details"
                    
        return
        <div class="resourceRef">{switch ($type)
            case "illustration" return 
                     <div class="resourcePanel col-xs-4 col-sm-4 col-md-4">
                    <h5>{$title}</h5>
                            <ul>
                            <li><a href="{ $imageUrl }" target="_about">Flickr</a><br/></li>
                            <li><a href="{ $zoteroUrl }" target="_about">Zotero</a></li>
                            </ul>
                    </div>
             case "seeFurther" return <span><a href="{data($resource[1]/@corresp)}" target="_blank" class="btn btn-primary">{$ref2display}</a>
        <a class="removeItem" onclick="removeResourceFromList('{$docUri}', '{ $type }', '/pleiades:Place', '{$xpath}', '{ $index }')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a></span>
             default return null
        }</div>
};

declare function spatiumStructor:displayResource( $docId as xs:string, $resourceUri as xs:string){
        let $resource := $spatiumStructor:resourceRepo//ausohnum:resource[@rdf:about=$resourceUri]
        let $imageUrl := $resource//bibo:Image/bibo:uri/text()
        let $zoteroUrl := $resource//owl:sameAs[1]/@rdf:resource/text()
        let $title := if($resource//bibo:Image/dcterms:title) then $resource//bibo:Image/dcterms:title[1]
                          else ("No title found")
        return
        <div>

        <link href="$ausohnum-lib/resources/css/skosThesau.css" rel="stylesheet" type="text/css"/>
        <div class="resourcePanel col-xs-4 col-sm-4 col-md-4">

        <h5>{$title}</h5>
        <ul>
        <li><a href="{ $imageUrl }" target="_about">Flickr</a><br/></li>
        <li><a href="{ $zoteroUrl }" target="_about">Zotero</a></li>
        </ul>
        </div>
        </div>
};

declare function spatiumStructor:addResourceToPlace( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    (:let $data := request:get-data():)
(:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)
       let $docId := "ASUPPRIMER"
    let $placeUri := $data//placeUri/text()
    (:let $docId := request:get-parameter('docid', ()):)
    let $xmlDoc :=util:eval( "$spatiumStructor:place-collection//pleiades:Place[@rdf:about = '"||$placeUri ||"']") 
(:    $spatiumStructor:place-collection//pleiades:Place[@rdf:about = $placeUri]:)

    let $resourceRef := $data//resourceId/text()
    let $typeRef := $data//type/text()
    let $citedRange := $data//citedRange/text()
    let $calculatedCitedRange := if($citedRange != '') then
                            <citedRange>{$citedRange}</citedRange>
                            else ()
    let $zoteroGroup := $data//zoteroGroup/text()
    let $xpath :=
    switch ($typeRef)
       case "seeFurther" return '//cito:citesForInformation'
       case "illustration" return
                '//ausohnum:hasResource[@type="illustration"]'
       (:case "secondary" return
                //tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl
:)
       default return null


            (:let $nodesArray := tokenize($xpath, '/')
            let $lastNode := $nodesArray[last()]:)
     let $zoteroResource := zoteroPlugin:get-zoteroItem($zoteroGroup, $resourceRef, "tei")
     let $zoteroResourceCorresp := data($zoteroResource//tei:biblStruct/@corresp)
     let $resourceId := data($zoteroResource//biblStruct/@xml:id)

    
   (: let $insertLocationElementInDoc := util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')/id('"
                || $docId ||"')" || '/spatial:Feature/foaf:primaryTopicOf/pleiades:Place'  ):)

    let $refAlreadyPresent := switch ($typeRef)
                                            case "seeFurther" return exists($xmlDoc//cito:citesForInformation[@rdf:resource=  $zoteroResourceCorresp])
                                            case "illustration" return exists($xmlDoc//ausohnum:hasResource[@rdf:resource=  $zoteroResourceCorresp])
                                            default return null
                                            
    (:let $testlog := spatiumStructor:logEvent("logs-debug", "test-before-adding-resource", $docId, (),
                        "$spatiumStructor:resourceRepo//.[@xml:id=$typeRef]: " || $spatiumStructor:resourceRepo//.[@xml:id=$typeRef]
                       || "$zoteroResourceInTei: " || serialize($zoteroResource, ())
                       || "$typeRef: " || $typeRef
                       || "xmlDoc: " || serialize($xmlDoc)
                      

                       )
    
:)
       
       (:insert new reference in main bibliography:)
    (:let $insertBiblioInBiblioRepo :=
        if ($teiEditor:biblioRepo//tei:biblStruct[equals(./@corresp, $zoteroResourceCorresp)]) then (
                    update replace $teiEditor:biblioRepo//tei:biblStruct[equals(./@corresp, $zoteroResourceCorresp)] with $zoteroResource//tei:biblStruct)
        else(
                   update insert $zoteroResource//tei:biblStruct into $teiEditor:biblioRepo//tei:listBibl[@xml:id="mainBiblio"]
            ):)
     let $insertBiblioInBiblioRepo :=       
        if ($teiEditor:biblioRepo//tei:biblStruct[@corresp = $zoteroResourceCorresp]) then (
                    update replace $teiEditor:biblioRepo//tei:biblStruct[@corresp=  $zoteroResourceCorresp] with $zoteroResource//tei:biblStruct)
        else(
                   update insert $zoteroResource//tei:biblStruct into $teiEditor:biblioRepo//tei:listBibl[@xml:id="mainBiblio"]
            )                    

(:let $updateResourceRDFAbout := update replace $spatiumStructor:resourceRepo//z:UserItem/@rdf:about with $rdfAboutForResource:)
(:let $updateResourceSameAs:= update insert <owl:sameAs rdf:resource="{$zoteroItemRdfAbout}"/> into $spatiumStructor:resourceRepo//z:UserItem[@rdf:about = $rdfAboutForResource]:)


let $insertBiblioInDocument :=
        switch ($typeRef)
           case "illustration" return
                   if (exists($xmlDoc//ausohnum:hasResource[@rdf:resource=  $zoteroResourceCorresp])) then ()
                   else (
                   let $resourceNode := <node><ausohnum:hasResource type="illustration" rdf:resource="{$zoteroResourceCorresp}"/>
        </node>
                            return
                                update insert ( functx:change-element-ns-deep($resourceNode/node(), "http://ausonius.huma-num.fr/onto", "ausohnum"))
                                                  into $xmlDoc)

            case "main" 
           case "edition" return
                     let $biblNode := <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                 <ptr target="{$zoteroResourceCorresp}" />,
                                 <citedRange>{$citedRange}</citedRange>
                             </bibl>
                          return update insert $biblNode into
                                            $xmlDoc//tei:div[@type="bibliography"][@subtype="edition"]/tei:listBibl
           case "secondary" return
                   if (not(exists($xmlDoc//tei:div[@type="bibliography"][@subtype="seconday"]//tei:ptr[@target =  $zoteroResourceCorresp])))
                        then (
                        let $biblNode := <bibl xmlns="http://www.tei-c.org/ns/1.0">
                                 <ptr target="{ $zoteroResourceCorresp }"/>,
                                 <citedRange>{$citedRange}</citedRange>
                             </bibl>
                          return
                          update insert $biblNode into
                          $xmlDoc//tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl
                        )
                        
                   else()
            case "seeFurther" return
                     if (exists($xmlDoc//cito:citesForInformation[@rdf:resource=$zoteroResourceCorresp])) then () else
                     let $node := <node><cito:citesForInformation rdf:resource="{$zoteroResourceCorresp}" >{
                             if ($citedRange != "") then <prism:pageRange>{ $citedRange }</prism:pageRange> else()}
                       </cito:citesForInformation>
                     </node>
                  
                          return update insert $node/node() into
                                            $xmlDoc
           default return "ERROR!"



(:    let $logs := collection($config:data-root || $teiEditor:project || "/logs"):)



    (:let $updateXml := update value $originalTEINode with $updatedData:)

(:let $newContent := util:eval( "collection('" || $spatiumStructor:doc-collection-path || "')/id('"
             ||$docId ||"')" )
:)
(:let $newBiblList :=  <div>
        {for $bibRef at $pos in  util:eval( "collection('" || $spatiumStructor:doc-collection-path || "')/id('"
             ||$docId ||"')" )//tei:text/tei:body/tei:div[@type='bibliography'][@subtype='edition']/tei:listBibl//tei:bibl
        order by $bibRef//tei:ptr/@target
        return
            teiEditor:displayBibRef($docId, $bibRef, "edition", $pos)
           }</div>:)



    let $logInjection :=
        update insert
        <apc:log type="document-update-add-biblio" when="{$now}" what="{data($data/xml/docId)}" who="{$currentUser}">
            {$data}
            <docId>{$docId}</docId>
            <xmlDoc>{ "xmlDoc: " || serialize($xmlDoc) }</xmlDoc>
            <!--<lastNode>{$lastNode}</lastNode>
            -->
            <origNode2>$originalTEINode</origNode2>
            <bibType>{$typeRef}</bibType>

            <teiBibRef>{$spatiumStructor:zoteroGroup} - {$zoteroResource}</teiBibRef>
        </apc:log>
        into $teiEditor:logs/id('all-logs')

    (:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return
        if ($refAlreadyPresent = true())
        then <data><status>errorAlready</status>Resource already present</data>
else
        <data>
        <status>ok</status>
       <newContent>{ spatiumStructor:resourcesManager($typeRef,  $placeUri) }</newContent>
        </data>
};

declare function spatiumStructor:addResource( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    (:let $data := request:get-data():)
(:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

    let $docId := $data//docId/text()
    (:let $docId := request:get-parameter('docid', ()):)
    let $xmlDoc := $spatiumStructor:place-collection/id($docId)

    let $resourceRef := $data//resourceId/text()
    let $typeRef := $data//type/text()
    let $citedRange := $data//citedRange/text()
    let $calculatedCitedRange := if($citedRange != '') then
                            <citedRange>{$citedRange}</citedRange>
                            else ()
    let $zoteroGroup := $data//zoteroGroup/text()
    let $xpath :=
    switch ($typeRef)
       case "illustration" return
                '//ausohnum:hasResource[@type="illustration"]'
       (:case "secondary" return
                //tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl
:)
       default return null


            (:let $nodesArray := tokenize($xpath, '/')
            let $lastNode := $nodesArray[last()]:)
    let $zoteroResource := zoteroPlugin:get-zoteroItem($zoteroGroup, $resourceRef, "rdf_bibliontology")

    (:let $zoteroResourceInTei := functx:change-element-ns-deep(zoteroPlugin:get-bibItem($zoteroGroup, $resourceRef, "tei")
                                            , 'http://www.tei-c.org/ns/1.0', 'tei'):)
    let $rdfAboutForResource := $spatiumStructor:appVariables//uriBase[@type="app"]/text() || "/resources/" || $resourceRef

     let $zoteroItemRdfAbout := data($zoteroResource//z:UserItem/@rdf:about)

     let $resourceId := functx:substring-after-last($zoteroItemRdfAbout, '/')

    let $resourceIdRef := concat("#", $resourceId)
    let $insertLocationElementInDoc :=         util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')/id('"
                || $docId ||"')" || '/spatial:Feature/foaf:primaryTopicOf/pleiades:Place'  )

let $refAlreadyPresent := exists($xmlDoc//ausohnum:hasResource[@rdf:resource=  $rdfAboutForResource])

let $testlog := spatiumStructor:logEvent("logs-debug", "test-before-adding-resource", $docId, (),
                        "$spatiumStructor:resourceRepo//.[@xml:id=$typeRef]: " || $spatiumStructor:resourceRepo//.[@xml:id=$typeRef]
                       || "$zoteroResourceInTei: " || serialize($zoteroResource, ())
                       || "$typeRef: " || $typeRef
                       || "data($zoteroResource//z:UserItem/@rdf:about):  " || data($zoteroResource//z:UserItem/@rdf:about)

                       )
let $ausohnumResource := <node><ausohnum:resource rdf:about="{ $rdfAboutForResource }">
                <owl:sameAs rdf:resource="{$zoteroItemRdfAbout}"/>{$zoteroResource//rdf:RDF/.}
                </ausohnum:resource></node>


    (:let $originalTEINode :=util:eval( "collection('/db/apps/" || $saveFunctions:project || "/data/documents')//id('"
                 ||$docId ||"')/" || $xpathWithTeiPrefix)
    :)

    (:insert new reference in main bibliography:)
    let $insertResourceInResourceRepo :=
        if ($spatiumStructor:resourceRepo//z:UserItem[@rdf:about= $rdfAboutForResource]) then ()
        else(
                   update insert $ausohnumResource/node() into $spatiumStructor:resourceRepo//.[@xml:id=$typeRef]
            )

let $updateResourceRDFAbout := update replace $spatiumStructor:resourceRepo//z:UserItem/@rdf:about with $rdfAboutForResource
(:let $updateResourceSameAs:= update insert <owl:sameAs rdf:resource="{$zoteroItemRdfAbout}"/> into $spatiumStructor:resourceRepo//z:UserItem[@rdf:about = $rdfAboutForResource]:)


let $insertBiblioInDocument :=
        switch ($typeRef)
           case "illustration" return
                   if (exists($xmlDoc//ausohnum:hasResource[@rdf:resource=  $rdfAboutForResource]))
                    then ()
                   else (
                                                let $resourceNode := <node><ausohnum:hasResource type="illustration" rdf:resource="{$rdfAboutForResource}"/>
        </node>

                                         return
                             (:                     update insert $biblNode into:)

                                                  update insert
                                                  (
                                                  functx:change-element-ns-deep($resourceNode/node(), "http://ausonius.huma-num.fr/onto", "ausohnum"))
                                                  into $insertLocationElementInDoc

                             (:                     $xmlDoc//tei:div[@type="bibliography"][@subtype="edition"]/tei:listBibl:)
                                                )


           case "secondary" return
                    '//tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl'

           default return null



(:    let $logs := collection($config:data-root || $teiEditor:project || "/logs"):)



    (:let $updateXml := update value $originalTEINode with $updatedData:)

let $newContent := util:eval( "collection('" || $spatiumStructor:doc-collection-path || "')/id('"
             ||$docId ||"')" )

let $newBiblList :=  <div>
        {for $bibRef at $pos in  util:eval( "collection('" || $spatiumStructor:doc-collection-path || "')/id('"
             ||$docId ||"')" )//tei:text/tei:body/tei:div[@type='bibliography'][@subtype='edition']/tei:listBibl//tei:bibl
        order by $bibRef//tei:ptr/@target
        return
            teiEditor:displayBibRef($docId, $bibRef, "edition", $pos)
           }</div>



    let $logInjection :=
        update insert
        <apc:log type="document-update-add-biblio" when="{$now}" what="{data($data/xml/docId)}" who="{$currentUser}">
            {$data}
            <docId>{$docId}</docId>
            <!--<lastNode>{$lastNode}</lastNode>
            -->
            <origNode2>$originalTEINode</origNode2>
            <bibType>{$typeRef}</bibType>

            <teiBibRef>{$spatiumStructor:zoteroGroup} - {$zoteroResource}</teiBibRef>
        </apc:log>
        into $teiEditor:logs/id('all-logs')

    (:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return
        if ($refAlreadyPresent = true())
        then <data><status>errorAlready</status>Resource already present</data>
else
        <data>
        <status>ok</status>
        <newBiblList>
 { switch($typeRef)
     case "main" return
        $newBiblList
(:     teiEditor:principalBibliography( $docId ) :)
     default return
(:     teiEditor:principalBibliography( $docId ) :)
     for $bibRef at $pos in $xmlDoc//tei:text/tei:body/tei:div[@type='bibliography'][@subtype='edition']/tei:listBibl//tei:bibl
        order by $bibRef//tei:ptr/@target
        return
            teiEditor:displayBibRef($docId, $bibRef, "edition", $pos)

     }
       </newBiblList>
       <newContent>{ $newContent}</newContent>
        </data>
};
declare function spatiumStructor:changePlaceToNearTo( $data as node(), $project as xs:string){

                            let $now := fn:current-dateTime()
                            let $currentUser := data(sm:id()//sm:username)

                            (:let $data := request:get-data():)
                        (:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

                            let $resourceUri := $data//resourceUri/text()
                            (:let $docId := request:get-parameter('docid', ()):)
                            let $xmlDoc := $spatiumStructor:place-collection/.[@rdf:about = $resourceUri]
                            let $placeUri := $data//placeUri/text()
                                    
                            let $xmlResource :=         util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
                || $resourceUri ||"']"  )
                        
                            let $xmlPlaceChangedAsNearTo:=         util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
                || $placeUri ||"']"  )
                
                            let $resourceUri := substring-before($data//resourceUri/text(), '#')
                            let $placeUri := substring-before($data//placeUri/text(), '#')
                            
                            let $NearToNode := <node>
<spatial:C type="isInVicinityOf" rdf:resource="{ $placeUri }"/></node>
                            (:insert new reference in main bibliography:)
                            let $addPlaceAsNearTo :=
                                     if($xmlResource//spatial:P) then
                                     update insert $NearToNode/node() following $xmlResource//spatial:P[last()]
                                     else update insert $NearToNode/node() preceding $xmlResource//foaf:primaryTopicOf
                           let $deleteFormerSpatialP := update delete $xmlResource/spatial:P[@rdf:resource=$placeUri]

(:REVERSE:)
                        let $NearToNodeReverse := <node>
<spatial:C type="hasInItsVicinity" rdf:resource="{ $resourceUri }"/></node>
                let $addPlaceAsNearToReverse :=
                                     if($xmlResource//spatial:P) then
                                     update insert $NearToNodeReverse/node() following $xmlPlaceChangedAsNearTo//spatial:P[last()]
                                     else update insert $NearToNodeReverse/node() preceding $xmlPlaceChangedAsNearTo//foaf:primaryTopicOf
                let $deleteFormerSpatialPi := update delete $xmlPlaceChangedAsNearTo/spatial:Pi[@rdf:resource=$resourceUri]

                        
                            let $logInjection :=
                                update insert
                                <apc:log type="document-update-add-biblio" when="{$now}" what="{data($data/xml/resourceUri)}" who="{$currentUser}">
                                    {$data}
                                    <resourceUri>{$resourceUri}</resourceUri>
                                    <!--<lastNode>{$lastNode}</lastNode>
                                    -->

                                </apc:log>
                                into $teiEditor:logs/id('all-logs')

                            (:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

                        return

                                <data>
                                <status>ok</status>
                                <newContent>{ spatiumStructor:getPlaceHTML($resourceUri )}</newContent>
                               </data>
};

declare function spatiumStructor:addData( $data as node(), $project as xs:string){


    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    (:let $data := request:get-data():)
(:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

    let $placeUri := $data//placeUri/text()
    let $topConceptId := $data//topConceptId/text()

    let $xpathRaw := $data//xpath/text()
    let $patternForXPathRaw := '\[not\(contains\(.*\)\)\]'
    let $xpath := if (matches($xpathRaw, "not\(contains")) then 
                                 replace($xpathRaw, $patternForXPathRaw, "")
                                 else $xpathRaw
                                
    let $lang := if($data//lang/text() = "undefined") then "en" else $data//lang/text()

    (:let $docId := request:get-parameter('docid', ()):)
    let $place := $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about=$placeUri]
    let $xpathEnd := if(matches(functx:substring-after-last($xpath, '/'), "@"))
            then(
                functx:substring-after-last(functx:substring-before-last($xpath, '/'), '/')
                )
            else
            (functx:substring-after-last($xpath, '/')
            )
    let $endingSelector := if(matches(functx:substring-after-last($xpath, '/'), "@"))
            then(
                functx:substring-after-last($xpath, '/@')
                )
            else
            (
            )
   
     let $xpathWithoutAttrib := if(matches($data//xpath/text(), '/@')) then (substring-before($data//xpath/text(), '/@'))
                                                                                            else ($data//xpath/text())
         
            
    let $xpathInsertLocation :=
                
                      (:if xpath is ending with \@, this must be removed:)
                      if(util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
                             || $placeUri ||"']" || $xpathWithoutAttrib) )
                                (:If there is already one node with same xpath, then location is last:)
                             then ($xpathWithoutAttrib || '[last()]')
                          else(
                            (:if location ends with a [@attribute="xxx"] then this has to be removed:)
                                    if(ends-with(functx:substring-before-last(functx:substring-before-last($data//xpath/text(), '/'), '/'), ']')) 
                                        then (
                                                  substring-before(
                                                    functx:substring-before-last(
                                                        functx:substring-before-last($data//xpath/text(), '/'), '/'), "[@"))
                                        else
                                        
(:                                                functx:substring-before-last(functx:substring-before-last($data//xpath/text(), '/'), '/'):)
                                                functx:substring-before-last($data//xpath/text(), '/')
                          )
                        
                    





  let $insertLocationElement :=
    (: If same element exists, then location is the last existing element, otherwise location is parent node :)
    if(util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
           || $placeUri ||"']/" || $xpathInsertLocation) )
           
           then (
             util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
           || $placeUri ||"']/" || $xpathInsertLocation)
         )
         else(

                util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
           || $placeUri ||"']" ||

                functx:substring-before-last($xpathInsertLocation, "/")
              ))


        let $insertTestLog :=
      update insert
                <log type="document-add-data-test" when="{$now}" what="{$placeUri}" who="{$currentUser}">
                $xpath {$data//xpath/text()}
                $xpathInsertLocation: {$xpathInsertLocation}
                substring-before($data//xpath/text(), '/@') : {if(matches($data//xpath/text(), '/@')) then (substring-before($data//xpath/text(), '/@'))
                                                                                            else ($data//xpath/text())
                }
                </log> 
      into $spatiumStructor:logs/id('all-logs')




    let $newElement :=
      if(matches(functx:substring-after-last($xpath, '/'), "@"))
                            
              then(
              let $patternForAttributesWithValue := '\[(.*)="(.*)"\]'
                            let $attributesWithValue := analyze-string($xpathRaw, $patternForAttributesWithValue)
                            return
              <newElement>
              
                      {element {
                      if(ends-with($xpathEnd, "]")) then
                      string(substring-before($xpathEnd, "[@"))
                      else
                      string($xpathEnd)
                      }
                      
                      {attribute {string($endingSelector)} {$data//value },
                                    if(count($attributesWithValue//fn:match) > 0) then
                                    (
                                            for $match in $attributesWithValue
                                                            let $attributeSeq := $match//fn:group[1]/text()
                                                            let $attributeName := substring-after($match//fn:group[1]/text(), '@')
                                                            let $attributeValue :=  $match//fn:group[2]/text()
                                                    return
                                             attribute {$attributeName} {$attributeValue }
                                    )
                                    else (),
                                 if($lang and $lang!= "undefined") then attribute xml:lang {$lang} else (),
                                if(($data//contentType/text() = 'text') or ($data//contentType/text() ="textNodeAndAttribute")) then
                                functx:trim($data//valueTxt/text())
                                else ()


          }}</newElement>
          )
        else(<newElement>
        {
          element {string($xpathEnd)}
               {attribute xml:lang {$lang},
               $data//valueTxt/text()
                }
            }</newElement>
        )
      
      
      let $insertNewElement :=
            if(util:eval( "collection('" || $spatiumStructor:project-place-collection-path ||"')//spatial:Feature[@rdf:about='"
           || $placeUri ||"']/" || $xpathWithoutAttrib) )
                   then (
                     update insert
                     
                     ('&#xD;&#xa;',
                     $newElement/node())
                     
                     
                     (:('&#xD;&#xa;',
                     functx:change-element-ns-deep($newElement, "", "")/node()):)
(:                     following $insertLocationElement:)
                     following $insertLocationElement
                   )
            else(
            
            
            update insert $newElement/node() into $insertLocationElement
(:            update insert functx:change-element-ns-deep($newElement, "", "")/node() into $insertLocationElement:)
            )

    let $insertLog :=
      update insert
      <log type="document-add-data" when="{$now}" what="{$placeUri}" who="{$currentUser}">{$newElement}
      <nm>{$data/xml/xmlElementNickname/text()}</nm>
      <xpath>{$data//xpath/text()}</xpath>
      <valueTxt>{$data//contentType/text() }</valueTxt>
      <insertLocBis>{functx:substring-before-last($xpathInsertLocation, "/")}</insertLocBis>
      <inserrtLoc>{$xpathInsertLocation}</inserrtLoc>
      <insertLocationElement>{ $insertLocationElement }</insertLocationElement>
      <newElement>{ $newElement }</newElement>
      </log> into $teiEditor:logs/id('all-logs')


    (:let $updateXml := update value $originalTEINode with $updatedData:)




    (:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)
let $newContent := <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:cito="http://purl.org/spar/cito/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ausohnum="http://ausonius.huma-num.fr/onto" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
{ util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//rdf:RDF[spatial:Feature[@rdf:about='"
             || $placeUri ||"']]" ) }</rdf:RDF>

return
    <data>
    <updatedElement>{ spatiumStructor:displayElement($data/xml/xmlElementNickname/text(), $placeUri,  (), ()) }</updatedElement>
    <newContent>{ $newContent }</newContent>
    </data>
};

declare function spatiumStructor:addGroupData($data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $xmlElementNickname := $data//xmlElementNickname/text()
    let $elementNode := if (not(exists($spatiumStructor:placeElementsCustom//xmlElement[nm=$xmlElementNickname]))) 
                                        then $spatiumStructor:placeElements//xmlElement[nm=$xmlElementNickname] 
                                        else $spatiumStructor:placeElementsCustom//xmlElement[nm=$xmlElementNickname]
    (:let $data := request:get-data():)
(:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

    let $resourceUri := $data//resourceUri/text()
    let $topConceptId := $data//topConceptId/text()
    let $xpath := replace($data//xpath/text(), 'tei:', '')
    let $dataTemplate := serialize($elementNode/template)
    (:let $updateTemplate :=
        for $item in $data//groupItem
            let $template := $dataTemplate
            let $element := "\$" || data($item/@teiElement)
            let $value := $item/text()
            let $updatedData := teiEditor:replaceData($dataTemplate, $element, $value)
                return
            $updatedData:)
    
    let $variables :=
        for $item in $data//groupItem
            
                return
             "\$" || data($item/@xmlElement)
    let $values :=
        for $item in $data//groupItem
            return
             $item/text()
    let $node2insert := parse-xml(functx:replace-multi($dataTemplate, $variables, $values))
    let $xpath := functx:substring-before-last($elementNode/xpath, '/')
    let $insertNode := update insert $node2insert/template/node() into util:eval( "$spatiumStructor:project-place-collection//spatial:Feature[@rdf:about='" || $resourceUri ||"']/" || $xpath)
let $newContent := <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:cito="http://purl.org/spar/cito/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ausohnum="http://ausonius.huma-num.fr/onto" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
{ util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//rdf:RDF[spatial:Feature[@rdf:about='"
             ||$resourceUri ||"']]" ) }</rdf:RDF>
return 
<data>
<updatedElement>{spatiumStructor:displayGroup($xmlElementNickname, $resourceUri, (), (), ())}</updatedElement>
 <newContent>{ $newContent }</newContent>
</data>

};

declare function spatiumStructor:searchPlace($query as xs:string){
let $places-collection := collection($spatiumStructor:project-place-collection-path )
 return
    <results>{
  for $place in $places-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place//dcterms:title[matches(lower-case(.), lower-case($query))]]
  return 
    <item><placename>{$place/foaf:primaryTopicOf/pleiades:Place//dcterms:title/text()}</placename>
  <uri>{data($place/@rdf:about)}</uri>
  <exactMatch>{for $exactMatch in $place//skos:exactMatch
            return string-join($exactMatch/@rdf:resource, " ")
  }</exactMatch>
            </item>
  }
 </results>
 
};

declare function spatiumStructor:newPlaceForm(){
<div>
       <div id="spatiumStructor" class="">
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-md-12">
                <h3>Create a new place</h3>
                <a onclick="openDialog('dialogSearchPleiades')" class="newDocButton"><i class="glyphicon glyphicon-plus"/>Import a place from Pleiades dataset</a>
                <div class="form-group">
                        <label for="newPlaceStandardizedNameEn">Standardized name (in English)</label>
                                     <input type="text" class="form-control"
                                     id="newPlaceStandardizedNameEn" 
                                     name="newPlaceStandardizedNameEn"
                                     />
               </div>
                <h4>Names</h4>
                            <div class="input-group">
                                <span class="input-group-addon" id="prefLabelLaLabel">Latin</span>
                                <input id="prefLabelLa" name="prefLabelLa" type="text" class="form-control" placeholder="Preferred label in Latin" aria-describedby="prefLabelLaabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="prefLabelGrcLabel">Ancient Greek</span>
                                <input id="prefLabelGrc" name="prefLabelGrc" type="text" class="form-control" placeholder="Preferred label in Ancient Greek" aria-describedby="prefLabelGrc" />
                            </div>
                            <div class="panel">
                            <h5>Names in other languages</h5>
                                    {skosThesau:dropDownThesau("c21856", "en", 'Language', 'row', (), (), "xml")}       
                                    <div class="input-group">
                                        <span class="input-group-addon" od="prefLabelExtraValueLabel">Name</span>
                                        <input id="prefLabelExtraValue" name="prefLabelExtraValue" type="text" class="form-control" placeholder="Value" aria-describedby="prefLabelExtraValueLabel" />
                                </div>
                            </div>    
                        <div id="altLabelImport"/>
                        
               <h4>Type of place</h4>
                {skosThesau:dropDownThesauForElement("hasFeatureTypeMain", substring-after($spatiumStructor:appVariables//placeMainTypeUri/text(), "/concept/"), "en", 'Space type', 'inline', (), (), "uri")}
                {skosThesau:dropDownThesauForElement("productionType", "c21879", "en", 'Production type', 'inline', (), (), "uri")}
                
                <h4>Exact match(es)</h4>
                     <div class="form-group">
                        <label for="exactMatch">exactMatch</label>
                                     <input type="text" class="form-control"
                                     id="exactMatch" 
                                     name="exactMatch"
                                     />
               </div>
               <div id="exactMatchImport"/>
             <h5>Geometry</h5>
                <p>You can use the Leaflet Map tools to calculate the coordinates [please prefer marker tool <img src="$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-black.png" height="12px;"/>]</p>
                 <div class="input-group">
                                <span class="input-group-addon" id="geometryTypeLabel">Type</span>
                                <input id="geometryType" name="geometryType" type="text" class="form-control"
                                placeholder="Geometry type" aria-describedby="geometryTypeLabel" value="Point"/>
                            </div>
                
                <div class="input-group">
                                <span class="input-group-addon" id="latNewPlaceLabel">Lat.</span>
                                <input id="latNewPlace" name="latNewPlace" type="text" class="form-control" placeholder="Latitude" aria-describedby="latNewPlaceLabel" />
                            </div>
                 <div class="input-group">
                                <span class="input-group-addon" id="longNewPlaceLabel">Long.</span>
                                <input id="longNewPlace" name="longNewPlace" type="text" class="form-control" placeholder="Longitude" aria-describedby="longNewPlaceLabel" />
                            </div>
                 <div class="input-group">
                                <span class="input-group-addon" id="polygonCoordinatesNewPlaceLabel">Coordinates</span>
                                <input id="polygonCoordinatesNewPlace" name="longNewPlace" type="text" class="form-control" placeholder="Coordinates" aria-describedby="polygonCoordinatesNewPlaceLabel" />
                            </div>
                
                </div>
                
                <div>
                    <button id="createNewPlace" 
                                  class="btn btn-success"
                                  onclick="createNewPlace('{ request:get-parameter("placeEditorType", ()) }')"
                                  appearance="minimal"
                                  type="button">Create place<i class="glyphicon glyphicon glyphicon-saved"></i></button>
                 </div>               
                </div>
                </div>
              
                </div>

};

declare function spatiumStructor:newArchaeoForm(){
<div>

       <div id="spatiumStructor" class="">
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-md-12">
                <h3>Create a new place</h3>
                <a onclick="openDialog('dialogSearchPleiades')" class="newDocButton"><i class="glyphicon glyphicon-plus"/>Import a place from Pleiades dataset</a>
                <div class="form-group">
                        <label for="newPlaceStandardizedNameEn">Standardized name (in English)</label>
                                     <input type="text" class="form-control"
                                     id="newPlaceStandardizedNameEn" 
                                     name="newPlaceStandardizedNameEn"
                                     />
               </div>
                <h4>Names</h4>
                            <div class="input-group">
                                <span class="input-group-addon" id="prefLabelLaLabel">Latin</span>
                                <input id="prefLabelLa" name="prefLabelLa" type="text" class="form-control" placeholder="Preferred label in Latin" aria-describedby="prefLabelLaabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="prefLabelGrcLabel">Ancient Greek</span>
                                <input id="prefLabelGrc" name="prefLabelGrc" type="text" class="form-control" placeholder="Preferred label in Ancient Greek" aria-describedby="prefLabelGrc" />
                            </div>
                            <h5>Names in other languages</h5>
                                    {skosThesau:dropDownThesau("c21856", "en", 'Language', 'row', (), (), "xml")}       
                                    <div class="input-group">
                                        <span class="input-group-addon" od="prefLabelExtraValueLabel">Name</span>
                                        <input id="prefLabelExtraValue" name="prefLabelExtraValue" type="text" class="form-control" placeholder="Value" aria-describedby="prefLabelExtraValueLabel" />
                                </div>
               <div id="altLabelImport"/>
               
               <h4>Type of place</h4>
               {skosThesau:dropDownThesauForElement("hasFeatureTypeMain", substring-after($spatiumStructor:appVariables//placeMainTypeUri/text(), "/concept/"), "en", 'Place type', 'inline', (), (), "uri")}
               {""(:skosThesau:dropDownThesauForElement("hasFeatureTypeMain", "c23473", "en", 'Place type', 'row', (), (), "uri"):)}
                {"" 
(:                skosThesau:dropDownThesauForElement("productionType", "c21879", "en", 'Production type', 'row', (), (), "uri"):)
                }
                
                <h4>Exact match(es)</h4>
                     <div class="form-group">
                        <label for="exactMatch">exactMatch</label>
                                     <input type="text" class="form-control"
                                     id="exactMatch" 
                                     name="exactMatch"
                                     />
               </div>
               <div id="exactMatchImport"/>
             <h4>Geometry</h4>
               <p>You may use the 'Drawing tools' available on the map to create coordinates (best tool to create a point: <img src="$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-grey.png" height="18px"/>)</p>             
                 <div class="input-group">
                                <span class="input-group-addon" id="geometryTypeLabel">Type</span>
                                <input id="geometryType" name="geometryType" type="text" class="form-control" placeholder="Geometry type" aria-describedby="geometryTypeLabel" />
                            </div>
                
                <div class="input-group">
                                <span class="input-group-addon" id="latNewPlaceLabel">Lat.</span>
                                <input id="latNewPlace" name="latNewPlace" type="text" class="form-control" placeholder="Latitude" aria-describedby="latNewPlaceLabel" />
                            </div>
                 <div class="input-group">
                                <span class="input-group-addon" id="longNewPlaceLabel">Long.</span>
                                <input id="longNewPlace" name="longNewPlace" type="text" class="form-control" placeholder="Longitude" aria-describedby="longNewPlaceLabel" />
                            </div>
                 <div class="input-group">
                                <span class="input-group-addon" id="polygonCoordinatesNewPlaceLabel">Coordinates</span>
                                <input id="polygonCoordinatesNewPlace" name="longNewPlace" type="text" class="form-control" placeholder="Coordinates" aria-describedby="polygonCoordinatesNewPlaceLabel" />
                            </div>
                
                </div>
                
                <div>
                    <button id="createNewPlace" 
                                  class="btn btn-success"
                                  onclick="createNewPlace('archaeo-manager')"
                                  appearance="minimal"
                                  type="button">Create place<i class="glyphicon glyphicon glyphicon-saved"></i></button>
                 </div>               
                </div>
                </div>
              
                </div>

};

declare function spatiumStructor:newSubPlaceModal(){

<div>
<div id="dialogAddNewSubPlace" title="Create and Add a Place" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create and add a sub place</h4>
                </div>
                <div class="modal-body">
    

            <div class="row">
                <div class="col-xs-12 col-sm-12 col-md-12">
                
                <a onclick="openDialog('dialogSearchPeripleo')" class="newDocButton"><i class="glyphicon glyphicon-plus"/>Create a place from Pelagios datasets</a>
                <div class="form-group">
                        <label for="newPlaceStandardizedNameEn">Standardized name (in English)</label>
                                     <input type="text" class="form-control"
                                     id="newPlaceStandardizedNameEn" 
                                     name="newPlaceStandardizedNameEn"
                                     />
               </div>
                <h5>Names</h5>
                            <div class="input-group">
                                <span class="input-group-addon" id="prefLabelLaLabel">Latin</span>
                                <input id="prefLabelLa" name="prefLabelLa" type="text" class="form-control" placeholder="Preferred label in Latin" aria-describedby="prefLabelLaabel" />
                            </div>
                            <div class="input-group">
                                <span class="input-group-addon" id="prefLabelGrcLabel">Ancient Greek</span>
                                <input id="prefLabelGrc" name="prefLabelGrc" type="text" class="form-control" placeholder="Preferred label in Ancient Greek" aria-describedby="prefLabelGrc" />
                            </div>
                            <div class="input-group">
                                 {skosThesau:dropDownThesau("c21856", "en", 'Language', 'row', (), (), "xml")}            
                            <span class="input-group-addon" od="prefLabelExtraValueLabel">Name</span>
                                <input id="prefLabelExtraValue" name="prefLabelExtraValue" type="text" class="form-control" placeholder="Value" aria-describedby="prefLabelExtraValueLabel" />
                            </div>
               <div id="altLabelImport"/>
               
               <h5>Type of place</h5>
               {skosThesau:dropDownThesauForElement("hasFeatureTypeMainSubPlace", substring-after($spatiumStructor:appVariables//placeMainTypeUri/text(), "/concept/"), "en", 'Place type', 'inline', (), (), "uri")}
                {""(:skosThesau:dropDownThesauForElement("hasFeatureTypeMainSubPlace", "c23473", "en", 'Space type', 'row', (), (), "uri"):)}
                
                <h5>Exact match(es)</h5>
                     <div class="form-group">
                        <label for="exactMatch">exactMatch</label>
                                     <input type="text" class="form-control"
                                     id="exactMatch" 
                                     name="exactMatch"
                                     />
               </div>
               <div id="exactMatchImport"/>
             <h5>Geometry</h5>
              
                 <div class="input-group">
                                <span class="input-group-addon" id="geometryTypeLabel">Type</span>
                                <input id="geometryType" name="geometryType" type="text" class="form-control" placeholder="Geometry type" aria-describedby="geometryTypeLabel" />
                            </div>
                
                <div class="input-group">
                                <span class="input-group-addon" id="latNewPlaceLabel">Lat.</span>
                                <input id="latNewPlace" name="latNewPlace" type="text" class="form-control" placeholder="Latitude" aria-describedby="latNewPlaceLabel" />
                            </div>
                 <div class="input-group">
                                <span class="input-group-addon" id="longNewPlaceLabel">Long.</span>
                                <input id="longNewPlace" name="longNewPlace" type="text" class="form-control" placeholder="Longitude" aria-describedby="longNewPlaceLabel" />
                            </div>
                 <div class="input-group">
                                <span class="input-group-addon" id="polygonCoordinatesNewPlaceLabel">Coordinates</span>
                                <input id="polygonCoordinatesNewPlace" name="longNewPlace" type="text" class="form-control" placeholder="Coordinates" aria-describedby="polygonCoordinatesNewPlaceLabel" />
                            </div>
                
                </div>
                
                               
                </div>
                </div>
                 <div class="form-group modal-footer">


                <button id="createNewArcheo" 
                                  class="btn btn-success"
                                  onclick="createNewSubPlace()"
                                  appearance="minimal"
                                  type="button">Create place<i class="glyphicon glyphicon glyphicon-saved"></i></button>
                                  
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                
                </div>
          </div>
     </div>
};
declare function spatiumStructor:addDocToPlaceModal(){

<div>
<div id="dialogAddExistingDocToPlace" title="Add a reference to an existing document to the current place" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Add a reference to a document</h4>
                </div>
                <div class="modal-body">
                        <div class="form-group">
                                <label for="documentLookup">Search a document by title or id</label>
                                             <input type="text" class="form-control"
                                             id="documentLookup" 
                                             name="documentLookup"
                                             />
                       </div>
                
                </div>
                 <div class="form-group modal-footer">


                <button id="addSelectedDocToPlace" 
                                  class="btn btn-success"
                                  onclick="createNewSubPlace()"
                                  appearance="minimal"
                                  type="button">Add</button>
                                  
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                
                </div>
          </div>
     </div>
};

declare function spatiumStructor:addNewDocModal(){
(:    let $templateList :=  collection( $teiEditor:library-path || '/data/teiEditor/docTemplates'):)
    let $templateList :=  collection('/db/apps/' || $spatiumStructor:project || '/data/teiEditor/docTemplates')
    let $project := request:get-parameter("project", ())
    let $collection := "documents-" ||  request:get-parameter("user", ())
    return
    <div>
    
    <!--Dialog for new document-->
    <div id="dialogAddNewDocumentToPlace" title="Add a new document" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Add a document to present place</h4>
                </div>
                <div class="modal-body">
                    <div id="" class="row">
                        <div class="col-xs-6 col-sm-6 col-md-6">
                        <p>You are about to create a new document in the collection "{ $collection }"</p>
                        <div class="">
                           <!-- <label for="newDocTemplate{$collection}" >Select a template</label>
                                    { 
                        <select id="newDocTemplate{$collection}" name="newDocTemplate{$collection}" 
                        class="templateSelect">
                        
                              {for $items in $templateList//tei:TEI
(:                              order by $items[@xml:id = $teiEditor:project], $items/@xml:id:)
                                  return
                                  <option value="{data($items/@xml:id)}">{data($items/@xml:id)}</option>
 (:                                       if ((contains(data($items/@xml:id), $teiEditor:project)))
                                        then (
                                        <option value="{data($items/@xml:id)}" selected="selected">{data($items/@xml:id)}</option>)
                                        else (
                                        <option value="{data($items/@xml:id)}">{data($items/@xml:id)}</option>
                                        ):)

                                     }
                        </select>}
                        -->
                    </div>
                    <br/>
                    <div class="form-group">
                                <label for="newDocTitle{$collection}" >Title of the document to be created</label>
                                <input type="text" class="form-control" style="width: 100%;" id="newDocTitle{$collection}" name="newDocTitle{$collection}"/>
                      </div>
                                {skosThesau:dropDownThesauXML('c39', 'en', 'Language', 'inline', 1, 1, 'xml')}
                                {skosThesau:dropDownThesauXML('c109', 'en', 'Script', 'inline', 1, 1, 'xml')}
                             </div>
                       </div>



                    <div class="form-group modal-footer">


                        <button id="createDocument{ $collection }" class="pull-left" onclick="createNewDocumentAndAddToPlace('{ $collection }')">Create document</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
       </div><!--End of dialog-->
    </div>
};





declare function spatiumStructor:searchPeripleoModal(){
   

    
    <div>
    
    <!--Dialog for new document-->
    <div id="dialogSearchPeripleo" title="Search Pelagios Peripleo" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Search a place in Pelagios Peripleo</h4>
                </div>
                <div class="modal-body">
                <div id="placeLookUpPanel" class="sectionInPanel"><span class="subSectionTitle">Add from Pelagios datasets</span>
                             <div class="form-group">
                             
                                    <label for="placesLookupInputDocPlaces">Search in <a href="http://pelagios.org/peripleo/map" target="_blank">Pelagios Peripleo</a></label>
                                     <input type="text" class="form-control"
                                     id="placesLookupInputDocPlaces" 
                                     name="placesLookupInputDocPlaces"
                                     />
                                     
                              </div>
                              <input id="newPlaceUri" class="hidden" type="text"/>
                       <div class="">
                             <iframe id="placesLookupInputDocPlaces_peripleoWidget" allowfullscreen="true" height="380" src="" style="display:none;"> </iframe>
                                     <div id="previewMapDocPlaces" class="hidden"/>
                                     <div id="placePreviewPanelDocPlaces" class="hidden"/>
                                
                                </div>
                </div>
                </div>
                    <div class="form-group modal-footer">
                        <button id="selectPlacePeripleo" class="pull-left" onclick="selectPeripleoPlace()">Select</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
       
       <!--End of dialog-->
    </div>
};

declare function spatiumStructor:searchPleiadesModal(){
   

    
    <div>
    <script type="text/javascript" src="$ausohnum-lib/resources/scripts/spatiumStructor/pleiades-static-search.js"/>
<!--Dialog for new document-->
    <div id="dialogSearchPleiades" title="Search Pleiades" class="modal fade"  tabindex="-1" style="display: none;">
        <div class="modal-dialog" data-backdrop="static" data-keyboard="false" role="document">
            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Import a place from Pleiades dataset</h4>
                </div>
                <div class="modal-body">
                <div id="placeLookUpPanel" class="sectionInPanel"><span class="subSectionTitle"></span>
                             <div class="form-group">
                             
                                    <label for="pleiadesPlacesLookup">Search in <a href="https://pleiades.stoa.org" target="_blank">Pleiades</a></label>
                                     <input type="text" class="form-control"
                                     id="pleiadesPlacesLookup" 
                                     name="pleiadesPlacesLookup"
                                     />
                                     
                              </div>
                              <input id="newPlaceUri" class="hidden" type="text"/>
                       <div class="">
                                     <div id="pleiadesPreviewMap" class="" style="height:200px"/>
                                     <div id="placePreviewPanelDocPlaces" class="hidden"/>
                                
                                </div>
                                <div id="results"/>
                </div>
                </div>
                    <div class="form-group modal-footer">
                        <button id="selectPlacePeripleo" class="pull-left" onclick="selectPleiadesPlace()">Select</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>

                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
         </div>       
       <!--End of dialog-->
       <script type="text/javascript">
        var satelliteMap = L.tileLayer.provider('MapBox', {{
            id: 'mapbox.satellite',
            accessToken: 'pk.eyJ1IjoidnJhemFuYWphbyIsImEiOiJjanR0dzU5a2ExMnR5NDRsOHVsdGk2cjdoIn0.3UtNLHIkJ96HSp8qLyFZUA'
               }});
      
        var pleiadesPreviewMap = L.map("pleiadesPreviewMap", {{
                                        maxZoom: 18,
                                        fullscreenControl: {{
                                        pseudoFullscreen: false}}
                                        }});
        pleiadesPreviewMap.setView([41.891775, 12.486137], 5);


        
        L.tileLayer('https://{{s}}.tile.openstreetmap.org/{{z}}/{{x}}/{{y}}.png', {{
                    attribution: ' <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }}).addTo(pleiadesPreviewMap);
        satelliteMap.addTo(pleiadesPreviewMap);


     L.control.layers({{
        					
                        "Satellite image": satelliteMap
                        
                         }}).addTo(pleiadesPreviewMap);

                        $('#dialogSearchPleiades').on('shown.bs.modal', function() {{
                         setTimeout(function() {{
                             pleiadesPreviewMap.invalidateSize();
                             console.log(pleiadesPreviewMap);
                             }}, 10);
                        
                        }});
        </script>
    </div>
};

declare function spatiumStructor:searchProjectPlacesModal(){

    <div id="dialogAddSubPlace" title="Add a Place" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal"/>
                                <h4 class="modal-title">Search a place</h4>
                            </div>
                <div class="modal-body">
                            <div id="placeLookUpPanel" class="sectionInPanel">
                                    <div class="form-group">
                                           <label for="placesLookupInputDocPlaces">Search in project's places</label>
                                            <input type="text" class="form-control projectPlacesLookUp"
                                            id="projectPlacesLookup"
                                            name="projectPlacesLookup"
                                            autocomplete="on"/>
                                       </div>
                                       <div class="">
                                             <iframe id="placesLookupInputDocPlaces_peripleoWidget" allowfullscreen="true" height="380" src="" style="display:none;"> </iframe>
                                                     <div id="projectPlaceDetailsPreview" class=""/>
                                                     <input id="placeTypeSelection" type="text" class="hidden"/>
                                                     <input id="currentPlaceUri" type="text" class="hidden"/>
                                                     <input id="selectedPlaceUri" type="text" class="hidden"/>
                                        </div>
                            </div>
                   </div>

                    <div class="form-group modal-footer">
                        <button  class="pull-left" type="submit" onclick="addPlaceToPlace()">Select place</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                 </div>
                
            </div>
};

declare function spatiumStructor:createNewPlaceModal(){

    <div id="dialogCreateNewPlaceModal" title="Create a new Place" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Create a new place</h4>
                </div>
                <div class="modal-body">
                      { spatiumStructor:newPlaceForm() }
                </div>

            </div>


    </div>

};


declare function spatiumStructor:getPeripleoPlaceDetails( $data as node(), $project as xs:string){

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:real//sm:username)

(:let $data := request:get-data():)
(:let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

let $placeCollection := collection($teiEditor:data-repository-path || "/places")
let $placeCollectionProject := collection($teiEditor:data-repository-path|| "/places/" || $project)

let $placeUri := $data//placeUri/text()
let $sourceUri := substring-before(substring-after($placeUri, '//'), '/')


let $url4httpRequest := switch ($sourceUri)
                                    case "pleiades.stoa.org"
                                    case "vici.org" return $placeUri || "/rdf"

                                    case "gazetteer.dainst.org" return replace($placeUri, '/place/', '/doc/')  || '.rdf'

                                    case "sws.geonames.org" return $placeUri || "/about.rdf"
                                    default return $placeUri || "/rdf"




    let $http-request-data := <request xmlns="http://expath.org/ns/http-client"
    method="GET" href="{$url4httpRequest}"/>


    let $responses :=
    http:send-request($http-request-data)
    let $response :=
    <results>
      {if ($responses[1]/@status ne '200')
         then
             <failure>{$responses[1]}</failure>
         else
           <success>
             {$responses[2]}
             {'' (: todo - use string to JSON serializer lib here :) }
           </success>
      }
    </results>

let $placeRecord := if ($response//rdf:RDF) then $response//rdf:RDF

                                   else (<error>Can't get place</error>)


let $placeLabel :=
                if ($placeRecord/*[local-name()="Feature"]/*[local-name()="label"]) then $placeRecord/*[local-name()="Feature"]/*[local-name()="label"][1]/text()
                            else if ($placeRecord/*[local-name()="Feature"]/*[local-name()="title"]) then $placeRecord//*[local-name()="title"][1]/text()
                            else if ($placeRecord/*[local-name()="Feature"]/*[local-name()="name"]) then $placeRecord//*[local-name()="name"][1]/text()
                            else ("No label or name found")
                            
let $placeAltLabels := 
<div id="altLabelImport">
        <span><strong>Alternative labels retrieve from {$placeUri}:</strong></span>{
                for $altLabel at $pos in $placeRecord//*[local-name()="altLabel"]
                return
                        <div class="input-group altLabelImport">
                              
                                <input id="altLabelLang{ $pos }" name="altLabelLang{ $pos }" type="text" class="altLabelLangFromExtResource form-control inputLangSmall" placeholder="" aria-describedby="" value="{ if($altLabel/@xml:lang) then data($altLabel/@xml:lang) else "en"}"/>
                                
                                <input id="altLabel{ $pos }" name="altLabel{ $pos }" type="text" class="altLabelExtResource form-control" placeholder="" aria-describedby="" value="{ $altLabel/text()}"/>
                 </div>
                }
                </div>
let $placeLocation :=
                    <geo:Point>
                    {
                    if ($placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Place"][1]/*[local-name()="lat"]) then 
                   $placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Place"][1]/*[local-name()="lat"]
                    else if ($placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Concept"][1]/*[local-name()="lat"]) then 
                   $placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Concept"][1]/*[local-name()="lat"]
                    else if ($placeRecord/*[local-name()="AbstractGeometry"]) then $placeRecord/*[local-name()="AbstractGeometry"]
                            else ("Error in retrieving coordinate")
                            }
                    {
                    if ($placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Place"][1]/*[local-name()="long"]) then 
                    $placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Place"][1]/*[local-name()="long"]
                    else if ($placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Concept"][1]/*[local-name()="long"]) then 
                    $placeRecord/*[local-name()="Feature"]/*[local-name()="primaryTopicOf"]/*[local-name()="Concept"][1]/*[local-name()="long"]
                    else if ($placeRecord/*[local-name()="AbstractGeometry"]) then $placeRecord/*[local-name()="AbstractGeometry"]
                            else ("Error in retrieving coordinate")
                            }        
                    </geo:Point>


let $projectUriOfPlace :=
    if (exists($placeCollectionProject//Place[owl:sameAs[matches(./@rdf:resource, $placeUri)]])) then
            data($placeCollectionProject//Place[owl:sameAs[matches(./@rdf:resource, $placeUri)]]/@rdf:about)
            else $placeUri


let $newPlaceRecord :=
        <rdf:RDF  xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:lawdi="http://lawd.info/ontology/"   xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:pleiades="https://pleiades.stoa.org/places/vocab#"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:spatium="http://ausonius.huma-num.fr/spatium-ontoology">
        <spatial:Feature rdf:about="#this">
             <skos:exactMatch rdf:resource="{$placeUri}"/>
            <foaf:primaryTopicOf>
                <pleiades:Place rdf:about="">
                    <dcterms:title xml:lang="en">{$placeLabel}</dcterms:title>
                            { $placeLocation }
                            </pleiades:Place>
                            </foaf:primaryTopicOf>
                            </spatial:Feature>
                            </rdf:RDF>


return
     (response:set-header("Content-Type", "application/xml; charset=utf-8"),
           
            
    <result>
        <placeLocation>{ $placeLocation }</placeLocation>
        <placeLabel>{ $placeLabel }</placeLabel>
        <exactMatch>{ $placeUri }</exactMatch>
        <altLabels>{ $placeAltLabels }</altLabels>
      
      
</result>
)

};
declare function spatiumStructor:createNewPlace($data as node(), $project as xs:string){

let $placeNumberList := for $place in $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about[matches(.,  $spatiumStructor:baseUri)]]
        return
        <item>
        {functx:substring-after-last($place/@rdf:about, "/" )}
        </item>
let $placeIdPrefix := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")//idPrefix[@type='place']/text()
let $last-id:= fn:max($placeNumberList)
let $newId := fn:sum(($last-id, 1))
let $newUri := $spatiumStructor:baseUri|| "/" || "places" || "/" || fn:sum(($last-id, 1))
let $exactMatch := $data//exactMatch/text()
let $title := $data//title/text()
let $placeCoordinates:=
                switch ($data//geometryType/text())
                case "Point" return
                <geo:Point><geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float">{ $data//longitude/text()}</geo:long>
                    <geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float">{ $data//latitude/text()}</geo:lat></geo:Point>
                case "Polygon" return
                <geo:Point><spatium:coordinates>{ $data//coordinates/text()}</spatium:coordinates></geo:Point>
                default return 
                <geo:Point>
                    <geo:long></geo:long>
                    <geo:lat></geo:lat></geo:Point>
        let $placeLocation :=
            if($data//latitude/text())
            then(
                switch ($data//geometryType/text())
                case "Point" return
                <geo:Point><osgeo:asGeoJSON>{{"type": "Point", "coordinates": [{ $data//longitude/text()}, { $data//latitude/text() }]}}</osgeo:asGeoJSON>
         <osgeo:asWKT>POINT ({ $data//latitude/text()} { $data//longitude/text() })</osgeo:asWKT></geo:Point>
                case "Polygon" return
                <geo:Point><osgeo:asGeoJSON>{{"type": "Polygon", "coordinates": [[{ 
                            let $json := $data//coordinates/text()
                            let $splitJSon := tokenize($json, ',') 
                            return
                                string-join(
                                for $value at $pos in $splitJSon
                                let $end := if($pos ne count($splitJSon)) then (", ") else ("")
                                return
                                    if( $pos mod 2 = 1 ) 
                                        then ('[' ||$value || ', ') 
                                        else ($value || ', 0.0]' )
                                        || $end
                                        , '')}]]}}</osgeo:asGeoJSON>
                <osgeo:asWKT>POLYGON Z (({ replace($data//coordinates/text(), ', ', ' ')}))</osgeo:asWKT></geo:Point>
                default return 
                <geo:Point>
                    <geo:long></geo:long>
                    <geo:lat></geo:lat>
                </geo:Point>
                )
                else
                (
                <geo:Point>
                <osgeo:asGeoJSON/>
                <osgeo:asWKT/>
                </geo:Point>)
                
let $newPlaceRecord :=
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:foaf="http://xmlns.com/foaf/0.1/"
        xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
        xmlns:lawdi="http://lawd.info/ontology/"
        xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/"
        xmlns:owl="http://www.w3.org/2002/07/owl#"
        xmlns:pleiades="https://pleiades.stoa.org/places/vocab#"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:skos="http://www.w3.org/2004/02/skos/core#"
        xmlns:spatial="http://geovocab.org/spatial#"
        xmlns:spatium="http://ausonius.huma-num.fr/spatium-ontoology"
        xmlns:prov="http://www.w3.org/TR/prov-o/#">
        <spatial:Feature rdf:about="{$newUri}#this">
             {if($data//exactMatch) then <skos:exactMatch rdf:resource="{$exactMatch}"/>
             else ()
             }
            <foaf:primaryTopicOf>
                <pleiades:Place rdf:about="{$newUri}">
                    <dcterms:title xml:lang="en">{$title}</dcterms:title>
                    {if($data//prefLabelLa != "") then <skos:altLabel xml:lang="la">{ $data//prefLabelLa/text() }</skos:altLabel>
                    else()
                    }
                    {if($data//prefLabelGrc != "") then <skos:altLabel xml:lang="grc">{ $data//prefLabelGrc/text() }</skos:altLabel>
                    else()
                    }
                    <pleiades:hasFeatureType type="main" rdf:resource="{$data//placeTypeMain/text()}"/>
                    {if($data//productionType/text() !="") then (<pleiades:hasFeatureType type="productionType" rdf:resource="{$data//productionType/text()}"/>) else ()
                    }
                    { $placeCoordinates/node() }
                    <skos:note/>
                </pleiades:Place>
             <skos:note type="private"/>
            </foaf:primaryTopicOf>
        </spatial:Feature>
         <pleiades:Location rdf:about="{$newUri}/position">
         <prov:wasDerivedFrom>
            <rdf:Description>
               <rdfs:label>APC</rdfs:label>
            </rdf:Description>
         </prov:wasDerivedFrom>
         { $placeLocation/node() }
         <pleiades:start_date rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"></pleiades:start_date>
         <pleiades:end_date rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"></pleiades:end_date>
      </pleiades:Location>
</rdf:RDF>

let $path2placeRepoRoot := $spatiumStructor:project-place-collection-path
let $createPlaceProjectRecordInPlaceRepo :=
     
     xmldb:store($spatiumStructor:project-place-collection-path, $newId || ".xml", $newPlaceRecord)
let $changeMod := sm:chmod(xs:anyURI(concat($spatiumStructor:project-place-collection-path, "/", $newId, ".xml")), "rw-rw-r--")    

return
<result>
<newUri>{ $newUri }</newUri>
<newId>{ $newId }</newId>
<newHtml>{switch($data//type/text())
                    case "archaeo-manager" return 
                    spatiumStructor:getArchaeoHTML( $newUri ||"#this", $project)
                    default return 
                    spatiumStructor:getPlaceHTML( $newUri ||"#this" )
}</newHtml>
</result>
};

declare function spatiumStructor:createNewSubPlace($data as node(), $project as xs:string){

let $placeNumberList := for $place in $spatiumStructor:project-place-collection//pleiades:Place[@rdf:about[matches(.,  $spatiumStructor:baseUri)]]
        return
        <item>
        {functx:substring-after-last($place/@rdf:about, "/" )}
        </item>
let $placeIdPrefix := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")//idPrefix[@type='place']/text()
let $last-id:= fn:max($placeNumberList)
let $newId := fn:sum(($last-id, 1))
let $newUri := $spatiumStructor:baseUri|| "/" || "places" || "/" || fn:sum(($last-id, 1))
let $exactMatch := $data//exactMatch/text()
let $parentPlaceUri := $data//parentPlaceUri/text()

        let $title := $data//title/text()
        let $placeCoordinates:=
                switch ($data//geometryType/text())
                case "Point" return
                <geo:Point><geo:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float">{ $data//longitude/text()}</geo:long>
                    <geo:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float">{ $data//latitude/text()}</geo:lat></geo:Point>
                case "Polygon" return
                <geo:Point><spatium:coordinates>{ $data//coordinates/text()}</spatium:coordinates></geo:Point>
                default return 
                <geo:Point>
                    <geo:long></geo:long>
                    <geo:lat></geo:lat></geo:Point>
        let $placeLocation :=
                switch ($data//geometryType/text())
                case "Point" return
                <geo:Point><osgeo:asGeoJSON>{{"type": "Point", "coordinates": [{ $data//longitude/text()}, { $data//latitude/text() }]}}</osgeo:asGeoJSON>
         <osgeo:asWKT>POINT ({ $data//latitude/text()} { $data//longitude/text() })</osgeo:asWKT></geo:Point>
                case "Polygon" return
                <geo:Point><osgeo:asGeoJSON>{{"type": "Polygon", "coordinates": [[{ 
                            let $json := $data//coordinates/text()
                            let $splitJSon := tokenize($json, ',') 
                            return
                                string-join(
                                for $value at $pos in $splitJSon
                                let $end := if($pos ne count($splitJSon)) then (", ") else ("")
                                return
                                    if( $pos mod 2 = 1 ) 
                                        then ('[' ||$value || ', ') 
                                        else ($value || ', 0.0]' )
                                        || $end
                                        , '')}]]}}</osgeo:asGeoJSON>
                <osgeo:asWKT>POLYGON Z (({ replace($data//coordinates/text(), ', ', ' ')}))</osgeo:asWKT></geo:Point>
                default return 
                <geo:Point>
                    <geo:long></geo:long>
                    <geo:lat></geo:lat>
                </geo:Point>
                
let $newPlaceRecord :=
<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:foaf="http://xmlns.com/foaf/0.1/"
        xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
        xmlns:lawdi="http://lawd.info/ontology/"
        xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/"
        xmlns:owl="http://www.w3.org/2002/07/owl#"
        xmlns:pleiades="https://pleiades.stoa.org/places/vocab#"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:skos="http://www.w3.org/2004/02/skos/core#"
        xmlns:spatial="http://geovocab.org/spatial#"
        xmlns:spatium="http://ausonius.huma-num.fr/spatium-ontoology"
        xmlns:prov="http://www.w3.org/TR/prov-o/#">
        <spatial:Feature rdf:about="{$newUri}#this">
            <spatial:P rdf:resource="{ $parentPlaceUri }"/>
             {if($data//exactMatch) then <skos:exactMatch rdf:resource="{$exactMatch}"/>
             else ()
             }
            <foaf:primaryTopicOf>
                <pleiades:Place rdf:about="{$newUri}">
                    <dcterms:title xml:lang="en">{$title}</dcterms:title>
                    {if($data//prefLabelLa != "") then <skos:altLabel xml:lang="la">{ $data//prefLabelLa/text() }</skos:altLabel>
                    else()
                    }
                    {if($data//prefLabelGrc != "") then <skos:altLabel xml:lang="grc">{ $data//prefLabelGrc/text() }</skos:altLabel>
                    else()
                    }
                    <pleiades:hasFeatureType type="main" rdf:resource="{$data//placeTypeMain/text()}"/>
                    {if($data//productionType/text() !="") then (<pleiades:hasFeatureType type="productionType" rdf:resource="{$data//productionType/text()}"/>) else ()
                    }
                    { $placeCoordinates/node() }
                    <skos:note/>
                </pleiades:Place>
             <skos:note type="private"/>
            </foaf:primaryTopicOf>
        </spatial:Feature>
         <pleiades:Location rdf:about="{$newUri}/position">
         <prov:wasDerivedFrom>
            <rdf:Description>
               <rdfs:label>APC</rdfs:label>
            </rdf:Description>
         </prov:wasDerivedFrom>
         { $placeLocation/node() }
         <pleiades:start_date rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"></pleiades:start_date>
         <pleiades:end_date rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"></pleiades:end_date>
      </pleiades:Location>
</rdf:RDF>

let $path2placeRepoRoot := $spatiumStructor:project-place-collection-path
let $createPlaceProjectRecordInPlaceRepo :=
     
     xmldb:store($spatiumStructor:project-place-collection-path, $newId || ".xml", $newPlaceRecord)
    
  let $spatialPiNodeForParent := <node>
     <spatial:Pi rdf:resource="{$newUri}"/></node>
let $updateParentRecord := 
                update insert $spatialPiNodeForParent/node() preceding util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $parentPlaceUri || "#this" ||"']/foaf:primaryTopicOf")
return
<result>
<newUri>{ $newUri }</newUri>
<newId>{ $newId }</newId>
<newHtml>{
spatiumStructor:getPlaceHTML( $newUri ||"#this" )
}</newHtml>
</result>
};
declare function spatiumStructor:addPlaceToPlace($data as node(), $project as xs:string){
    
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $type := $data//placeRelationType/text()
    let $addedPlaceUriLong := $data//placeToBeAddedUri/text()
    let $addedPlaceUri := substring-before($addedPlaceUriLong, "#this")
    let $currentPlaceUri := $data//currentPlaceUri/text()
    let $currentPlaceUriLong := $currentPlaceUri || "#this"
    let $currentPlace := collection($spatiumStructor:project-place-collection-path)//spatial:Feature[@rdf:about=$currentPlaceUriLong]
    
    let $xmlNodeToInsert :=
     switch ($type)
                    case "isInVicinityOf"
                    case "hasInItsVicinity"
                    case "isAdjacentTo" return
                            <data><spatial:C type="{$type}" rdf:resource="{$addedPlaceUri}"/>       
         </data>
                    case "isPartOf" return
                    <data><spatial:P rdf:resource="{$addedPlaceUri}"/>
         </data>
                    case "isMadeOf" return
                    <data><spatial:Pi rdf:resource="{$addedPlaceUri}"/>
         </data>
                    default return <error/>
                    
    let $xmlNodeToInsertReverse :=
     switch ($type)
                    case "isInVicinityOf" return
                    <data><spatial:C type="hasInItsVicinity" rdf:resource="{$currentPlaceUri}"/>       
         </data>
                    case "hasInItsVicinity" return
                            <data><spatial:C type="isInVicinityOf" rdf:resource="{$currentPlaceUri}"/>       
         </data>
                    case "isAdjacentTo" return
                            <data><spatial:C type="isAdjacentTo" rdf:resource="{$currentPlaceUri}"/>       
         </data>
         
                    case "isPartOf" return
                    <data><spatial:Pi rdf:resource="{$currentPlaceUri}"/>
         </data>
                    case "isMadeOf" return
                    <data><spatial:P rdf:resource="{$currentPlaceUri}"/>
         </data>
                    default return <error/>
    
                    
        
    (:let $logInjection :=
        update insert
        <apc:log type="test-debug-addPlaceToPlace" when="{$now}" what="{$currentPlaceUriLong}" who="{$currentUser}">
            {$data}
            to insert: {$xmlNodeToInsert}
            $spatiumStructor:project-place-collection-path: {$spatiumStructor:project-place-collection-path}
            $inserLocation: {serialize($insertLocation, ())}
        </apc:log>
        into $spatiumStructor:logs/id('all-logs')
    :)
    
    
    
    let $insertPlaceToPlace :=
                    update insert $xmlNodeToInsert/node()
                                            preceding
                 util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $currentPlaceUriLong ||"']/foaf:primaryTopicOf")

    let $insertReversePlaceToPlace :=
                    update insert $xmlNodeToInsertReverse/node()
                                            preceding
                 util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $addedPlaceUriLong ||"']/foaf:primaryTopicOf")
 
return
<updatedPlace>{spatiumStructor:getPlaceHTML2($currentPlaceUriLong)}</updatedPlace>
};

declare function spatiumStructor:removeSubPlace($data as node(), $project as xs:string){
    
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $type := $data//placeRelationType/text()
    let $subPlaceUriLong := $data//subPlaceUri/text()
    let $subPlaceUri := substring-before($subPlaceUriLong, "#this")
    let $currentPlaceUriLong := $data//currentPlaceUri/text()
    let $currentPlaceUri := substring-before($currentPlaceUriLong, "#this")
    let $currentPlace := collection($spatiumStructor:project-place-collection-path)//spatial:Feature[@rdf:about=$currentPlaceUriLong]
    let $placeRelationType := $data//placeRelationType/text()
    
    let $deleteNode :=
     switch ($placeRelationType)
                    case "isInVicinityOf"
                    case "hasInItsVicinity"
                    case "isAdjacentTo" return
                                      (
                                      update delete util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $currentPlaceUriLong ||"']//spatial:C[@rdf:resource='" || $subPlaceUri || "']" ),
                                        update delete util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $subPlaceUriLong ||"']//spatial:C[@rdf:resource='" || $currentPlaceUri || "']" )
                                        )
                   case "isPartOf" return
                    (
                                      update delete util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $currentPlaceUriLong ||"']//spatial:P[@rdf:resource='" || $subPlaceUri || "']" ),
                                        update delete util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $subPlaceUriLong ||"']//spatial:Pi[@rdf:resource='" || $currentPlaceUri || "']" )
                                        )
                   case "isMadeOf" return
                    (
                                      update delete util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $currentPlaceUriLong ||"']//spatial:Pi[@rdf:resource='" || $subPlaceUri || "']" ),
                                        update delete util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $subPlaceUriLong ||"']//spatial:P[@rdf:resource='" || $currentPlaceUri || "']" )
                                        )                    
                    default return <error/>
                    
                    
        
    (:let $logInjection :=
        update insert
        <apc:log type="test-debug-addPlaceToPlace" when="{$now}" what="{$currentPlaceUriLong}" who="{$currentUser}">
            {$data}
            to insert: {$xmlNodeToInsert}
            $spatiumStructor:project-place-collection-path: {$spatiumStructor:project-place-collection-path}
            $inserLocation: {serialize($insertLocation, ())}
        </apc:log>
        into $spatiumStructor:logs/id('all-logs')
    :)
    
    
         
return
<updatedPlace>{spatiumStructor:getPlaceHTML2($currentPlaceUriLong)}</updatedPlace>
};

declare function spatiumStructor:removeItem($data as node(), $project as xs:string){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    
    let $xpathBase:= $data//xpathBase/text()
    let $xpathSelector:= $data//xpathSelector/text()
    let $elementNickname := $data//elementNickname/text()
    let $index := "[" || $data//index/text() || "]"
    let $resourceUri := if(contains($data//resourceURI/text(), "#")) then $data//resourceURI/text()
                                            else $data//resourceURI/text() || "#this"
    
    let $nodeToRemove :=
    
            update delete util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $resourceUri ||"']/"
                                        || $xpathBase || "/" || $xpathSelector || $index)
    let $updatedElement := spatiumStructor:displayElement($elementNickname, xmldb:decode-uri($resourceUri), (), ())
    let $newContent := <rdf:RDF xmlns:pleiades="https://pleiades.stoa.org/places/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:cito="http://purl.org/spar/cito/" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:ausohnum="http://ausonius.huma-num.fr/onto" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/">
{ util:eval( "collection('" || $spatiumStructor:project-place-collection-path || "')//rdf:RDF[spatial:Feature[@rdf:about='"
             ||$resourceUri ||"']]" ) }</rdf:RDF>
 return 
            <data>
            <newContent>{ $newContent }</newContent>
            <updatedElement>{ $updatedElement }</updatedElement>
            </data>
            
            

};
declare function spatiumStructor:removeResourceFromList($data as node(), $project as xs:string){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    
    let $xpathBase:= $data//xpathBase/text()
    let $xpathSelector:= $data//xpathSelector/text()
    let $type:= $data//type/text()
    let $index := "[" || $data//index/text() || "]"
    let $resourceUri := if(contains($data//resourceURI/text(), "#")) then $data//resourceURI/text()
                                            else $data//resourceURI/text() || "#this"
    
    let $nodeToRemove :=
    
            update delete util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $resourceUri ||"']/"
                                        || $xpathBase || "/" || $xpathSelector || $index)
    let $updatedElement := spatiumStructor:resourcesManager($type, xmldb:decode-uri($resourceUri))
 return 
            <data>
            <updatedPlace>{spatiumStructor:getPlaceHTML2(substring-before($resourceUri, "#this"))}</updatedPlace>
            <updatedElement>{ $updatedElement }</updatedElement>
            </data>
            
            

};
declare function spatiumStructor:updateLocation($data as node(), $project as xs:string){
    
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $type := $data//type/text()
    let $coordinates := $data//coordinates/text()
    let $longitude := if($data//longitude/text() != "") then $data//longitude/text() else ""
    let $latitude := if($data//latitude/text() != "") then $data//latitude/text() else ""
    
    let $currentPlaceUri := $data//placeUri/text()
    let $currentPlaceUriLong := $currentPlaceUri || "#this"
    let $currentPlace := collection($spatiumStructor:project-place-collection-path)//spatial:Feature[@rdf:about=$currentPlaceUriLong]
    
    let $AsGeoJson :=
            if($longitude = "" or $longitude = " ") then "" else
            switch ($type)
                case "Point" return '{"type": "Point", "coordinates": [' ||  $longitude || ', ' || $latitude || ']}'
                case "Polygon" return '{"type": "Polygon", "coordinates": [[' ||( 
                            let $json := $data//coordinates/text()
                            let $splitJSon := tokenize($json, ',') 
                            return
                                string-join(
                                for $value at $pos in $splitJSon
                                let $end := if($pos ne count($splitJSon)) then (", ") else ("")
                                return
                                    if( $pos mod 2 = 1 ) 
                                        then ('[' ||$value || ', ') 
                                        else ($value || ', 0.0]' )
                                        || $end
                                        , ''))|| ']]}'
                  default return 
                        '{"type": "Point", "coordinates": []}'
         
                  
    let $asWKT := 
        if($longitude = "" or $longitude = " ") then "" else
                switch ($type)
                        case "Point" return "POINT  (" || $longitude || ", " || $latitude || ")"
                        case "Polygon" return "POLYGON Z ((" || replace($coordinates, ', ', ' ') || "))"
                        default return "POINT ()"
        
    (:let $logInjection :=
        update insert
        <apc:log type="test-debug-addPlaceToPlace" when="{$now}" what="{$currentPlaceUriLong}" who="{$currentUser}">
            {$data}
            to insert: {$xmlNodeToInsert}
            $spatiumStructor:project-place-collection-path: {$spatiumStructor:project-place-collection-path}
            $inserLocation: {serialize($insertLocation, ())}
        </apc:log>
        into $spatiumStructor:logs/id('all-logs')
    :)
    
    
    
    let $updateGeoLong:=
                    update value 
                 util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $currentPlaceUriLong ||"']/foaf:primaryTopicOf/pleiades:Place/geo:long")
                                with $longitude
    let $updateGeoLat:=
                    update value
                 util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $currentPlaceUriLong ||"']/foaf:primaryTopicOf/pleiades:Place/geo:lat")
                                with $latitude
    let $updateAsGeoJSon:=
                    update value 
                 util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $currentPlaceUriLong ||"']/following-sibling::pleiades:Location/osgeo:asGeoJSON")
                                with $AsGeoJson
    let $updateAsWKT:=
                    update value 
                 util:eval( "collection('"
                                        || $spatiumStructor:project-place-collection-path
                                        ||"')//spatial:Feature[@rdf:about='"|| $currentPlaceUriLong ||"']/following-sibling::pleiades:Location/osgeo:asWKT")
                                with $asWKT
                                
         
return
<updatedPlace>{spatiumStructor:getPlaceHTML($currentPlaceUriLong)}</updatedPlace>
};


declare function spatiumStructor:listPlacesAsTable(){
(:    let $people := $prosopoManager:peopleCollection//lawd:person:)
    
    
    let $complete := concat ('
        $( function() {
                      $.widget( "custom.catcomplete", $.ui.autocomplete, {
                      //$("#search").autocomplete({
                      
                    _create: function() {
                      this._super();
                      
                      
                      this.widget().menu( "option", "items", "> :not(.ui-autocomplete-category)" );
                    },
                    _renderMenu: function( ul, items ) {
                      var that = this,
                        currentCategory = "";
                      $.each( items, function( index, item ) {
                        var li;
                        if ( item.category != currentCategory ) {
                          ul.append( "<li class=\"ui-autocomplete-category\">" + item.category + "</li>" );
                          currentCategory = item.category;
                        }
                        li = that._renderItemData( ul, item );
                        if ( item.category ) {
                          li.attr( "aria-label", item.category + " : " + item.label );
                        }
                      });
                    }
                  });
                  
                  var data = [', '
                    
                    
                  ];
               
                  $( "#search" ).catcomplete({
                    delay: 0,
                    source: data
                  });
     } );')
  
return
    <div id="placesListDiv">
    <table id="placesList" class="table">
     <thead>
        <tr style="font-size: smaller;">
            <td>ID</td>
            <td class="sortingActive">Name</td>
            <td>URI</td>
            <td>TM</td>
            <long></long>
            <lat></lat>
        </tr>
        </thead>
        <tbody>
                
         </tbody>
      </table>
      
      
      <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
    <script type="text/javascript">$(document).ready( function () {{
                        $('#placesList').DataTable({{
                        //paging: false
                        order: [[ 0, "asc" ]],
                        'pageLength': 100,
                        "scrollY":        "600px",
                        "scrollCollapse": true,
                        "ajax": '/geo/list',
                        "columns": [
                                    {{ "data": "id" }},
                                    {{ "data": "name" }},
                                    {{ "data": "uri" }},
                                    {{ "data": "exactMatches" }}
                                ],
                                "columnDefs": [
                                                   //{{ 
                                                   //"targets": [0],
                                                   //"render": function ( data, type, full, meta ) {{
                                                   //            return '<span class="spanLink" onclick="displayPlace('+ full.id +', ' + full.long +', ' + full.lat + ')">' + data + '</span>';    }}
                                                   //}},
                                                   //{{ "targets": [1],
                                                   //"render": function ( data, type, full, meta ) {{
                                                   //            return '<span class="spanLink" onclick="displayPlace('+ full.id +'zzz, ' + full.long +', ' + full.lat + ')">' + data + '</span>';    }}
                                                   //}},
                                                   {{
                                                       "targets": [ 2 ],
                                                       "visible": false
                                                   }},
                                                   {{
                                                       "targets": [ 3 ],
                                                       "visible": false
                                                   }}
                                                ],
                                                
                                                "language": {{
                                            "search": "Search (also by TM no.):"
                                                }}
                            }});
                        }} );</script>
    <script type="text/javascript">{ $complete }</script>
    <script type="text/javascript">$( '#placesList' ).searchable();</script>
    
   </div>
};
declare function spatiumStructor:getLastUpdatePlace($project){
let $collection := ("/db/apps/" || $project || "Data/places/" || $project)
let $childCollections := xmldb:get-child-collections($collection)
let $placesInChildCollections :=
    for $subCollection in $childCollections
        let $resources := for $resource in xmldb:get-child-resources($collection || "/" || $subCollection)
                        return <place path="{ $collection || "/" || $subCollection || $resource }" lastModified="{ xmldb:last-modified($collection || "/" || $subCollection, $resource) }"/>
    return $resources   
let $placesInParentCollection :=
   for $child in  xmldb:get-child-resources($collection)
(:   order by xs:dateTime(xmldb:last-modified($collection|| "/imports", $child)) descending:)
   return <place path="{ $collection || $child }" lastModified="{ xmldb:last-modified($collection, $child) }"/>
 let $places := ($placesInChildCollections, $placesInParentCollection) 
  
   
   return 
       for $place in $places
        order by xs:dateTime($place/@lastModified) descending
        return
       $place[1]
};
declare function spatiumStructor:buildProjectPlacesCatalogue( $project ){
let $startTime := util:system-time()
let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
let $placeCollection := util:eval('collection("/db/apps/' || $project || 'Data/places/' || $project || '")')
let $appVariables := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")
let $concept-collection:= doc("/db/apps/" || $appVariables//thesaurus-app/text() || "Data/concepts/" || $project || ".rdf")
let $productionUnitTypes := skosThesau:getChildren($appVariables//productionUnitsUri/text(), $project)
let $romanProvinces := ($placeCollection//pleiades:Place[pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"]]
   ,
     $placeCollection//pleiades:Place[pleiades:hasFeatureType[@rdf:resource="https://ausohnum.huma-num.fr/concept/c23737"]]
   )
let $romanProvincesUriList := string-join($romanProvinces//@rdf:about, " ")
let $features :=
            for $placeSpatialFeature in $placeCollection//spatial:Feature
                    let $uriLong := data($placeSpatialFeature/@rdf:about)
                    let $uri := substring-before($uriLong, "#this")
                    let $id := functx:substring-after-last($uri, "/")
                    let $place := $placeSpatialFeature//pleiades:Place
                    let $exactMatch := string-join($placeSpatialFeature//skos:exactMatch/@rdf:resource, " ")
                    let $placeName := $place/dcterms:title/text()
                    let $altNames := string-join($place//skos:altLabel/text(), " ")
                    let $provinceUri := $placeSpatialFeature//spatial:P[functx:contains-any-of($romanProvincesUriList, ./@rdf:resource/string()) ]/@rdf:resource/string()
                    let $provinceName := $romanProvinces//.[@rdf:about = $provinceUri]//dcterms:title/text()      
                     (:let $mainPlaceType := if($place/pleiades:hasFeatureType[@type = "main"]/@rdf:resource) 
                        then  $projectThesaurus//skos:Concept[@rdf:about = $place/pleiades:hasFeatureType[matches(./@type, "main")]/@rdf:resource]//skos:prefLabel[@xml:lang ="en"]/text()
                                                            else("untyped place"):)
                     let $mainPlaceTypeUri := functx:if-absent($place//pleiades:hasFeatureType[@type = "main"]/@rdf:resource, "no-type")
                     let $mainPlaceType :=
                           functx:if-absent(
                                $concept-collection//skos:Concept[@rdf:about = $mainPlaceTypeUri]//skos:prefLabel[@xml:lang ="en"]/text(),
                                "untyped place")
                            
                     let $productionTypeUris := $place/pleiades:hasFeatureType[@type = "productionType"]/@rdf:resource
                      let $productionType := if($productionTypeUris) then
                                    for $productionTypeUri at $pos in $productionTypeUris
                                        let $label := $concept-collection//skos:Concept[@rdf:about = $productionTypeUri]//skos:prefLabel[@xml:lang ="en"]/text()
                                        where $productionTypeUri != ""
                                        return 
                                            <prodTypes>
                                                <productionType>{ $label }</productionType>
                                                <productionTypeLink><a href="{ $productionTypeUri }" target="_blank" class="label label-primary labelInTable">{ $label }</a></productionTypeLink>
                                             </prodTypes>
                                                
                                         else
                                             ()
                       let $marker := concat("marker-",
                                            switch(lower-case($mainPlaceType))
                                                        case "landed estate" return
                                                        (
                                                            if($productionType[1]) then 
                                                                switch(lower-case($productionType[1]))
                                                                        case "wheat" return "farming-wheat"
                                                                        case "cereals"
                                                                            return "farming-wheat-and-others"
                                                                        case "vineyard" 
                                                                        case "wine" 
                                                                        case "vines" return "farming-vineyard"
                                                                default return "farming-wheat"
        (:                                                    || "Icon":)
                                                            else("farming-wheat")
                                                        )
                                                       case "forest"
                                                       case "forest or pastureland" return "forest-pasture"
                                                       case "workshop" return 
                                                       ( if($productionType[1]) then 
                                                                switch(lower-case($productionType[1]))
                                                                    case "bricks" return "workshops-bricks"
                                                                    default return concat("workshops-", lower-case($productionType[1]))
                                                                
                                                                else ("color-violet")
                                                            )
                                                       case "military camp/outpost" return "default"
                                                       case "modern place" case "city" case "settlement" case "village/settlement" return "default"
                                                       case "mine" case "quarry" return "extraction-marble"
                                                       case "area" case "geographic region" return "color-green"
                                                       case "production units" return "default"
                                                       case "administrative district" return "default"
                                                       case "station" return "default"
                                                       case "roman provinces" case "province" return "color-black"
                                                       case "ethnic region" return "color-black"
                                                       case "villa" return "villa"
                                                       case "untyped place" return "color-red"
                                                       default return 
                                                             "default"
                                                       , ".png")

        
         
                 let $isPartOf := ($placeSpatialFeature//spatial:P)
                 let $isMadeOf := ($placeSpatialFeature//spatial:Pi)
                 let $isInVicinityOf := ($placeSpatialFeature//spatial:C[@type='isInVicinityOf'])
                 let $coordinates :=(
                    if($place//geo:long/text() != "")
                        then      (<geoCoord>
                                                    <coordinates json:array="true" json:literal="false">{ $place/geo:long/text()}, {$place/geo:lat/text()}</coordinates>
                                      </geoCoord>)
                        
                        
                        else 
                                (
(:                                if isMadeOf take coordinates:)
                                (if($isMadeOf or $isInVicinityOf) 
                                            then
                                                 <geoCoord>{
                                                     for $parent in ($isMadeOf, $isInVicinityOf)
                                                              return
                                                                     
                                                                                 try { spatiumStructor:getRelatedPlacesCoordinates($project, $placeCollection, data($parent/@rdf:resource), 0, ()) } 
                                                                                 catch * {"error in in isMadeOf"}
                                                                               
                                                      }</geoCoord>
                                     else if ($isPartOf) then (
                                               <geoCoord>{
                                                    for $parent in $isPartOf
                                                        return 
                                                           
                                                                try { 
                                                                spatiumStructor:getRelatedPlacesCoordinates($project, $placeCollection, data($parent/@rdf:resource), 0, count($isPartOf)) } 
                                                                catch * {"error in is Part Of" || " - Error ", $err:code, ": ", $err:description}    
                                                               
                                           }</geoCoord>
                                               )
                                         else (<geoCoord><coordinates type="lastChance">0, 0</coordinates></geoCoord>
                                         )
                                  )
(:                                if isInVicinityOf take coordinates:)
                                (:(
                                    if($isInVicinityOf//node())
                                        then (
                                            <geoCoord>{
                                                    for $parent in $isInVicinityOf
                                                        return 
                                                            <coordinates>{ 
                                                                          try { spatiumStructor:getRelatedPlacesCoordinates($project, $placeCollection, data($parent/@rdf:resource), 0) } 
                                                                         catch * {"error in is InVicinityOf" || " - Error ", $err:code, ": ", $err:description}    }
                                                            </coordinates>
                                              }</geoCoord>
                                    ) else()
                                    ):)
(:                                    if no isMadeOf and no IsInVicinity of take coordinates:)
                                (:(
                                if($isPartOf//node())
                                        then (
                                        <geoCoord>{
                                                    for $parent in $isPartOf
                                                        return 
                                                            <coordinates>
                                                                {
                                                                try { spatiumStructor:getRelatedPlacesCoordinates($project, $placeCollection, data($parent/@rdf:resource), 0) } 
                                                                catch * {"error in is InVicinityOf" || " - Error ", $err:code, ": ", $err:description}    
                                                                }
                                                                </coordinates>
                                           }</geoCoord>
                                                )
                                    else(<coordinates>[0, 0]</coordinates>)
                                ):)
            )                  )
                      
                                   
                      
                      
      return
        (
        <features type="Feature">
                                <properties>
                                    <name>{ $placeName }</name>
                                    <altNames>{ $altNames }</altNames>
                                    <uri>{ $uri }</uri>
                                    <id>{ $id }</id>
                                    <placeType>{ if ( $mainPlaceType = "MAN MADE MATERIAL") then "Please check type of place"
                                        else $mainPlaceType }</placeType>
                                    <placeTypeUri>{ if ( $mainPlaceType = "MAN MADE MATERIAL") then "Please check type of place"
                                        else if ($mainPlaceTypeUri = "") then "no-uri" else 
                                        data($mainPlaceTypeUri) }</placeTypeUri>
                                    <provinceUri>{ $provinceUri }</provinceUri>
                                    <provinceName>{ $provinceName }</provinceName>
                                    <productionType>{ if($productionType//productionType) then string-join($productionType//productionType, ", ") else ()
                                                                        }</productionType>
                                    <productionTypeLink>{ if($productionType//productionTypeLink) then $productionType//productionTypeLink/node() else ()
                                                                        }</productionTypeLink>
                                    <exactMatch>{ $exactMatch }</exactMatch>
                                    <icon>{ $marker }</icon>
                                    <amenity></amenity>
                                    <popupContent>{"<h5>"  || $placeName || "</h5>"}
                                   {if($mainPlaceType) then "<div>" || $mainPlaceType || "</div>" else ("no main type")} 
                                   {'<span class="uri">' || $uri || '</span>'}
                                   {if($productionType//productionType) then '<div class="margin-top: 5em;"><span>Types of production: </span>' || string-join($productionType, ', ') || '</div>'
                                   else("")}</popupContent>
                                 </properties>
                                 <style>
                                     <fill>red</fill>
                                     <fill-opacity>1</fill-opacity>
                                  </style>
                                  <geometry>
                                     <type>MultiPoint</type>
                                     {if (normalize-space($coordinates) = "") then <coordinates json:array="true" json:literal="false">[0, 0]</coordinates>
                                     else if($coordinates//coordinates[(normalize-space(.) !="") or (not(contains(./text(), "0, 0")))]) then 
                                            let $numberOfCoordinates := count($coordinates//coordinates)
                                            let $numberOfCoordinatesWith00 := count($coordinates//coordinates[./text() ="0, 0"])
                                            return
                                                    if ($numberOfCoordinates >1) then
                                                            for $coord in $coordinates//coordinates[normalize-space(.) !=""][not(contains(./text(), "0, 0"))]
                                                            return (<coordinates json:array="true" json:literal="false">[{ normalize-space($coord)}]</coordinates>, $spatiumStructor:newLine )
                                                   
                                                   else (<coordinates json:array="true" json:literal="false">[{ normalize-space($coordinates//coordinates/text())}]</coordinates>)
                                           else (<coordinates json:array="true" json:literal="false">[2, 2]</coordinates>)
                                        }
                                </geometry>
                           </features>,
                                                                $spatiumStructor:newLine)
                           
      let $endTime := util:system-time()      
      let $duration := $endTime - $startTime
      let $seconds := $duration div xs:dayTimeDuration("PT1S")
return
<places xmlns:json="http://www.json.org" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <last-update>{  $now }</last-update>
    <generated-in>{ $seconds }</generated-in>
    <count>{ count($placeCollection//spatial:Feature) }</count>
    <user>{ $currentUser }</user>
        <root json:array="true" type="FeatureCollection">
        { $features }
                   </root>
             </places>
};

declare function spatiumStructor:getRelatedPlacesCoordinates($project as xs:string, $placeCollection, $placeUri as xs:string, $level as xs:int, $placesNumber as xs:int?){
(:    let $placeCollection := util:eval('collection("/db/apps/' || $project || "Data/places/" || $project ||  '")'):)
    let $placeUriLong := $placeUri || '#this'
    let $place := $placeCollection//spatial:Feature[@rdf:about= $placeUriLong ]
    
(:    let $place := $spatiumStructor:place-collection//spatial:Feature[@rdf:about=$placeUri || "#this" ]:)
    
    return
     (:Check number of related places; if more than 2 and place type is Province, then the place is discarded     :)
    if (($placesNumber > 1) and ($place//pleiades:hasFeatureType[@type="main"][@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"])) then ()
  else 
    if($place//pleiades:Place/geo:long/text() != "")
        then      (<geoCoord>
                         <coordinates json:array="true" json:literal="false">{ $place//pleiades:Place/geo:long/text()}, {$place//pleiades:Place/geo:lat/text()}</coordinates>
                       </geoCoord>)
        else if( $level = 1) then ()
        
        else (
             
             let $isPartOf := ($place//spatial:P)
             let $isMadeOf := ($place//spatial:Pi)
             let $isInVicinityOf := ($place//spatial:C[@type='isInVicinityOf'])
            
           let $coordinatesFromIsMadeOf :=
             if($isMadeOf) then (
                        for $relatedPlace in $isMadeOf
                                   let $relatedPlaceUri := data($relatedPlace/@rdf:resource)
                                   let $relatedPlaceNode := $placeCollection//spatial:Feature[@rdf:about= $relatedPlaceUri || "#this" ]
                                   let $relatedPlaceGeoCoordinates := if($relatedPlaceNode//geo:long/text() != "") then (<geoCoord><coordinates json:array="true" json:literal="false">{ $relatedPlaceNode//pleiades:Place/geo:long/text()}, { $relatedPlaceNode//pleiades:Place/geo:lat/text() }</coordinates></geoCoord>) 
                                                                                               else (
                                                                                               <geoCoord>{
                                                                                                try { spatiumStructor:getRelatedPlacesCoordinates($project, $placeCollection, $relatedPlaceUri, $level +1, ()) }
                                                                                                catch * {"error in isMadeOf" } 
                                                                                                }</geoCoord>
                                                                                               )
                                return $relatedPlaceGeoCoordinates
                                )
             else ()
          
          
          let $coordinatesFromIsInVicinityOf :=<geoCoord>{
                if($isInVicinityOf) then (
                    for $relatedPlace at $pos in $isInVicinityOf
                          let $relatedPlaceUri := data($relatedPlace/@rdf:resource)
                          let $relatedPlaceNode := $placeCollection//spatial:Feature[@rdf:about= $relatedPlaceUri || "#this" ]
                          let $relatedPlaceGeoCoordinates := if($relatedPlaceNode//geo:long/text() != "") then (
                          <coordinates json:array="true" json:literal="false">{ $relatedPlaceNode//pleiades:Place/geo:long/text()}, { $relatedPlaceNode//pleiades:Place/geo:lat/text() }</coordinates>
                          ) 
                    else (try { spatiumStructor:getRelatedPlacesCoordinates($project, $placeCollection, $relatedPlaceUri, $level + 1, ()) }
                             catch * {"error in isMadeOf" } 
                            )
                   return $relatedPlaceGeoCoordinates
             )
             else ()}</geoCoord>
        
        let $coordinatesFromIsPartOf :=
                if($isPartOf) then (
                    for $relatedPlace in $isPartOf
                          let $relatedPlaceUri := data($relatedPlace/@rdf:resource)
                          let $relatedPlaceNode := $placeCollection//spatial:Feature[@rdf:about= $relatedPlaceUri || "#this" ]
                          let $relatedPlaceGeoCoordinates :=
                          (:Check number of related places; if more than 2 and place type is Province, then the place is discarded     :)
                                if (
                                (count($relatedPlaceNode) > 1) and
                                (
                                ($relatedPlaceNode//pleiades:hasFeatureType[@type="main"][@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"])
                                or ($relatedPlaceNode//pleiades:hasFeatureType[@type="main"][@rdf:resource="https://ausohnum.huma-num.fr/concept/c23587"])
                                )) then ()
                                else 
                                    if($relatedPlaceNode//geo:long/text() != "") then (<geoCoord><coordinates json:array="true" json:literal="false" type="{$relatedPlaceNode//pleiades:hasFeatureType[@type="main"][@rdf:resource="https://ausohnum.huma-num.fr/concept/c22264"]}">{ $relatedPlaceNode//pleiades:Place/geo:long/text()}, { $relatedPlaceNode//pleiades:Place/geo:lat/text() }</coordinates></geoCoord>) 
                                                                                  else (
                                                                                  <geoCoord>{
                                                                                                try { spatiumStructor:getRelatedPlacesCoordinates($project, $placeCollection, $relatedPlaceUri, $level + 1, ()) }
                                                                                                catch * {"error in isPartOf" } 
                                                                                                }</geoCoord>
                                                                                  )
                   return $relatedPlaceGeoCoordinates
             )
             else ()
        
      return (
      if($coordinatesFromIsMadeOf//coordinates) then $coordinatesFromIsMadeOf else (), 
      if($coordinatesFromIsInVicinityOf//coordinates) then $coordinatesFromIsInVicinityOf else (),
      if((count($coordinatesFromIsMadeOf//coordinates) >0 ) or (count($coordinatesFromIsInVicinityOf//coordinates) >0) )
                then () else ($coordinatesFromIsPartOf) 
      )
(:             else( <coordinates json:array="true" json:literal="false">15, 15</coordinates>):)
             )
             
         
};

declare function spatiumStructor:updateGazetteer($project as xs:string){
update replace doc("/db/apps/" || $project || "Data/places/project-places-gazetteer.xml")//places with spatiumStructor:buildProjectPlacesCatalogue($project)
};

declare function spatiumStructor:getProjectPlacesGazetteer( $project, $placeType, $dataFormat){
    let $data := if($placeType = "all") then
        doc($spatiumStructor:place-collection-path-root || "project-places-gazetteer.xml")//features[properties/placeTypeUri[not(contains((string-join($spatiumStructor:productionUnitTypes//skos:Concept/@rdf:about, ",")), ./text()))]]
    else if($placeType = "production-units") then doc($spatiumStructor:place-collection-path-root || "project-places-gazetteer.xml")//features[properties/placeTypeUri[(contains((string-join($spatiumStructor:productionUnitTypes//skos:Concept/@rdf:about, ",")), ./text()))]]
            else doc($spatiumStructor:place-collection-path-root || "project-places-gazetteer.xml")//root//features[placeType/text() = $placeType]
    return
serialize(<root json:array="true" type="FeatureCollection">{ $data }</root>,
            <output:serialization-parameters>
              <output:media-type value="application/json"/>
                <output:method value="{ $dataFormat }"/>
                <output:indent value="yes"/>
                <output:json-ignore-whitespace-text-nodes value="yes"/>
            </output:serialization-parameters>
        )
};



declare function spatiumStructor:pleaseLogin($project as xs:string){
  <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
     <div id="spatiumStructor" class="">
            <div class="row">
                  <div class="jumbotron jumbotron-fluid">
                        <div class="container">
                          <h1 class="display-4">Error!</h1>
                          <p class="lead">You cannot access this resource. Please login from the <a href="/">home page</a>.</p>
                        </div>
            </div>
            </div>
        </div>
    </div>

};

declare function spatiumStructor:dateRangeFromRelatedDoc($placeUri as xs:string){
        let $relatedDocs := spatiumStructor:relatedDocuments($placeUri)
        let $origDateNotBeforeXPath := if(exists($spatiumStructor:teiElements//teiElement[nm="origDateNotBefore"])) 
                then $spatiumStructor:teiElements//teiElement[nm="origDateNotBefore"]/xpath/text() 
                else $spatiumStructor:teiElementsCustom//teiElement[nm="origDateNotBefore"]/xpath/text()      
        let $origDateNotAfterXPath := if(exists($spatiumStructor:teiElements//teiElement[nm="origDateNotAfter"])) 
                then $spatiumStructor:teiElements//teiElement[nm="origDateNotAfter"]/xpath/xpath/text() 
                else $spatiumStructor:teiElementsCustom//teiElement[nm="origDateNotAfter"]/xpath/text()        
        
        let $earlierNotBeforeDate := min(for $date in util:eval("$relatedDocs/" || $origDateNotBeforeXPath || "[. != '']") return  replace($date, "\?", ""))
       
       let $latestNotAfterDate := max(for $date in util:eval("$relatedDocs/" || $origDateNotAfterXPath || "[. != '']") return  replace($date, "\?", ""))
       return 
                ($earlierNotBeforeDate, $latestNotAfterDate) 
            };
declare function spatiumStructor:dateRangeScale($earlierNotBeforeDate as xs:integer,
                                $latestNotAfterDate as xs:integer,
                                $scaleStartingYearBC as xs:integer,
                                $scaleEndingYearAD as xs:integer){
                
         
       <div>
       <svg height="50" width="400">
                <line x1="0" y1="10" x2="{ sum(($earlierNotBeforeDate, $scaleStartingYearBC)) }" y2="10" style="stroke:rgb(192, 231, 237);stroke-width:10" />
                <line x1="{ sum(($earlierNotBeforeDate, $scaleStartingYearBC)) }" y1="10" x2="{ sum(($latestNotAfterDate, $scaleStartingYearBC)) }" y2="10" style="stroke:rgb(125, 29, 32);stroke-width:10" />
                <line x1="{ sum(($latestNotAfterDate, $scaleStartingYearBC)) }" y1="10" x2="{sum(($scaleEndingYearAD, $scaleStartingYearBC)) }" y2="10" style="stroke:rgb(192, 231, 237);stroke-width:10" />
                <text x="0" y="35" fill="black">- {$scaleStartingYearBC}</text>
                <text x="{ $scaleStartingYearBC }" y="35" fill="black">1</text>
                <text x="{ sum(($scaleStartingYearBC, 50)) }" y="35" fill="black">50</text>
                <text x="{ sum(($scaleStartingYearBC, 95)) }" y="35" fill="black">100</text>
                <text x="{ sum(($scaleStartingYearBC, 145)) }" y="35" fill="black">150</text>
                <text x="{ sum(($scaleStartingYearBC, 195))}" y="35" fill="black">200</text>
                <text x="{ sum(($scaleStartingYearBC, 245)) }" y="35" fill="black">250</text>
                <text x="{ sum(($scaleStartingYearBC, 295)) }" y="35" fill="black">{ $scaleEndingYearAD }</text>
                
        </svg>
        </div>
            };            
            
declare function spatiumStructor:representativeCoordinates($placeUri){
    let $placeRecord := $spatiumStructor:project-place-collection//spatial:Feature[@rdf:about= $placeUri || "#this"]
    
    return 
        if( normalize-space($placeRecord//geo:long/text()) = "")
            then
                (:let $gazetteerRecord := $spatiumStructor:placeGazetteer//features[.//uri = normalize-space($placeUri)]:)
                
                <div class="xmlElementGroup">
                <span class="subSectionTitle"><strong>Representative coordinates:</strong></span>
                This place has <strong>no coordinates</strong>. Current location on map is drawn from coordinates of related places (see below) 
                </div>
        else 
                let $representativeCoordinates :=  substring-before($placeRecord//geo:lat/text(), '.') || '.' || substring(substring-after($placeRecord//geo:lat/text(), '.'), 0, 5)
                    || ", " || substring-before($placeRecord//geo:long/text(), '.') || '.' || substring(substring-after($placeRecord//geo:long/text(), '.'), 0, 5)
                return
                        <div class="xmlElementGroup">
                        <span class="subSectionTitle"><strong>Representative coordinates (lat., long.):</strong>
                        { $representativeCoordinates }
                        </span>
            
                        <div></div>
                        </div>
  
};            
declare function spatiumStructor:JSonPlaceRecord($placeUriShort as xs:string){
  let $gazetteerRecord := $spatiumStructor:placeGazetteer//features[.//uri = normalize-space($placeUriShort)]
  let $coordinates := $gazetteerRecord//coordinates[1]/text()
  let $iconScript :='$(document).ready( function () {{
        var greenIcon = L.icon({
                             iconUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/marker-2x-orange.png",
                             shadowUrl: "$ausohnum-lib/resources/scripts/spatiumStructor/markers/shadow.png",
                         
                             iconSize:     [38, 95], // size of the icon
                         shadowSize:   [50, 64], // size of the shadow
                         iconAnchor:   [22, 94], // point of the icon which will correspond to marker s location
                         shadowAnchor: [4, 62],  // the same for the shadow
                         popupAnchor:  [-3, -76] // point from which the popup should open relative to the iconAnchor
                                });
        L.marker(' || $coordinates || ', {icon: greenIcon}).addTo(editorMap);
  }});'
  
  return
  <script>
                </script>
  
};

declare function spatiumStructor:setGazetteerSynchro($project as xs:string){
        scheduler:schedule-xquery-cron-job(
            "/db/apps/" || $project || "/modules/spatiumStructor/buildGazetteer.xql",
            "0 0/2 * * * ?",
            "buildAndUpdatePlacesGazetteer" || functx:capitalize-first($project),
        <parameters>
            <param name="project" value="{ $project }"/>
        </parameters>
        )

};

declare function spatiumStructor:copyValueToClipboardButton($elementNickname as xs:string, $index as xs:int, $value as xs:string){
        let $javascript :='
                                    function copyValueToClipboard(element) {{
                              /* Get the text field */
                              console.log(element)
                              var copyText = document.getElementById(element);
                            
                              /* Select the text field */
                              copyText.select();
                              copyText.setSelectionRange(0, 99999); /*For mobile devices*/
                            
                              /* Copy the text inside the text field */
                              document.execCommand("copy");
                            
                              /* Alert the copied text */
                              alert("Copied the text: " + copyText.value);
                                }}'
        return
<span>
<input id="elementValue_{$elementNickname }_{ $index }" style="position: absolute; left:     -1000px; top:-1000px" value="{ $value}"></input> 
<button class="btn btn-small btn-primary" onclick="copyValueToClipboard('elementValue_{$elementNickname }_{ $index }')"><i class="glyphicon glyphicon-copy"/></button>
 <script>{ $javascript }</script>   
</span>
};

declare function spatiumStructor:getPlaceHierarchy($placeUri as xs:string, $processedPlaces as node()*) as element(){
    let $placeCollection:= collection($spatiumStructor:project-place-collection-path)
    let $place:=$placeCollection//spatial:Feature[@rdf:about=$placeUri ||"#this"]
    let $partOfPlaces:=$place//spatial:P
    return 
        if($partOfPlaces[1][@rdf:resource!=""])
            then spatiumStructor:getPlaceHierarchy($partOfPlaces[1]/@rdf:resource, ($processedPlaces, $place))
            else 
                <places>{($processedPlaces, $place)}</places>
};