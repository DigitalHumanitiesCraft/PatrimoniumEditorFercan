(:~
: AusoHNum Library - prosopographical module - Main Module
: This module contains the main functions of the prosopographical module.
: @author Vincent Razanajao
:)
xquery version "3.1";

module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager";

import module namespace config="http://ausonius.huma-num.fr/ausohnum-library/config" at "../config.xqm";

import module namespace dbutil="http://exist-db.org/xquery/dbutil" at "/db/apps/shared-resources/content/dbutils.xql";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor" at "../teiEditor/teiEditorApp.xql";

import module namespace functx="http://www.functx.com";
(:import module namespace httpclient="http://exist-db.org/xquery/httpclient" at "java:org.exist.xquery.modules.httpclient.HTTPClientModule";:)
import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";


import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
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

declare namespace foaf="http://xmlns.com/foaf/0.1/";

declare namespace json="http://www.json.org";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace prism="http://prismstandard.org/namespaces/basic/2.0/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace snap="http://onto.snapdrgn.net/snap#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace z = "http://www.zotero.org/namespaces/export#";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method 'adaptive';
(:declare option output:item-separator "&#xa;";:)

declare variable $prosopoManager:library-path := "/db/apps/ausohnum-library/";
declare variable $prosopoManager:project :=request:get-parameter('project', ());
declare variable $prosopoManager:appVariables := doc("/db/apps/" || $prosopoManager:project || "/data/app-general-parameters.xml");
declare variable $prosopoManager:uriBase := $prosopoManager:appVariables//uriBase[@type="app"]/text();
declare variable $prosopoManager:data := request:get-data();
declare variable $prosopoManager:docId :=  request:get-parameter('docid', ());
declare variable $prosopoManager:placeId :=  request:get-parameter('placeid', ());
declare variable $prosopoManager:placeURI :=  request:get-parameter('placeuri', ());
declare variable $prosopoManager:lang :=request:get-parameter('lang', "en");
declare variable $prosopoManager:languages := $prosopoManager:appVariables//languages;

declare variable $prosopoManager:editorLabels := doc($prosopoManager:library-path || "data/teiEditor/teiEditorLabels.xml");
(:declare variable $prosopoManager:project := "patrimonium";:)
declare variable $prosopoManager:data-collection-path := "/db/apps/" || $prosopoManager:project || "Data";
declare variable $prosopoManager:data-collection := collection($prosopoManager:data-collection-path);
declare variable $prosopoManager:place-collection :=collection($prosopoManager:data-collection-path|| "/places");
declare variable $prosopoManager:project-place-collection := collection("/db/apps/" || $prosopoManager:project || "Data/places/" || $prosopoManager:project );

declare variable $prosopoManager:doc-collection-path := $prosopoManager:data-collection-path || "/documents";
declare variable $prosopoManager:doc-collection:= collection($prosopoManager:data-collection-path || "/documents");
declare variable $prosopoManager:place-collection-path-root := $prosopoManager:data-collection-path || "/places/" ;
declare variable $prosopoManager:project-place-collection-path := $prosopoManager:data-collection-path || "/places/" || $prosopoManager:project ;
declare variable $prosopoManager:project-people-collection-path := $prosopoManager:data-collection-path || "/people"  ;


declare variable $prosopoManager:concept-collection-path := "/db/apps/" || $prosopoManager:appVariables//thesaurus-app/text() || "Data/concepts";

declare variable $prosopoManager:biblioRepo := doc($prosopoManager:data-collection-path || "/biblio/biblio.xml");
declare variable $prosopoManager:resourceRepo := collection($prosopoManager:data-collection-path || "/resources");
declare variable $prosopoManager:peopleRepo := doc($prosopoManager:data-collection-path || "/people/people.xml");
declare variable $prosopoManager:peopleCollection := collection($prosopoManager:data-collection-path || "/people");
declare variable $prosopoManager:peopleCollectionPath := $prosopoManager:data-collection-path || "/people";
declare variable $prosopoManager:placeCollection := collection($prosopoManager:data-collection-path || "/places");
declare variable $prosopoManager:placeRepo := doc($prosopoManager:data-collection-path || "/places/listOfPlaces.xml");
declare variable $prosopoManager:romanProvincesDoc := doc($prosopoManager:place-collection-path-root || "/roman-provinces.rdf");

declare variable $prosopoManager:baseUri := $prosopoManager:appVariables//uriBase[@type='app']/text();
declare variable $prosopoManager:uriBasePeople := $prosopoManager:appVariables//uriBase[@type='people']/text();

declare variable $prosopoManager:peopleElements := doc($prosopoManager:library-path || 'data/prosopoManager/peopleElements.xml');
declare variable $prosopoManager:peopleElementsCustom := doc("/db/apps/" || $prosopoManager:project || '/data/teiEditor/placeElements.xml');
declare variable $prosopoManager:docTemplates := collection($prosopoManager:library-path || 'data/teiEditor/docTemplates');
declare variable $prosopoManager:teiTemplate := doc($prosopoManager:library-path || 'data/teiEditor/teiTemplate.xml');
declare variable $prosopoManager:externalResources := doc($prosopoManager:library-path || 'data/teiEditor/externalResources.xml');
declare variable $prosopoManager:teiDoc := $prosopoManager:place-collection/id($prosopoManager:docId) ;
declare variable $prosopoManager:docTitle :=  $prosopoManager:teiDoc//tei:fileDesc/tei:titleStmt/tei:title/text() ;

declare variable $prosopoManager:logs := collection($prosopoManager:data-collection-path || '/logs');
declare variable $prosopoManager:now := fn:current-dateTime();
declare variable $prosopoManager:currentUser := data(sm:id()//sm:username);
declare variable $prosopoManager:currentUserUri := concat($prosopoManager:baseUri, '/people/' , data(sm:id()//sm:username));
declare variable $prosopoManager:zoteroGroup :=request:get-parameter('zoteroGroup', ());


declare
    %templates:wrap
    function prosopoManager:version($node as node(), $model as map(*)){
    data( $config:expath-descriptor//@version)

};
declare
    %templates:wrap
    function prosopoManager:variables($resourceId as xs:string, $project as xs:string){
    <div class="hidden">
        <div id="currentResourceId">{ $resourceId }</div>
        <div id="currentProject">{ $project } </div>
    </div>

};


declare function prosopoManager:processUrl($path as xs:string,
                                                                      $resource as xs:string,
                                                                      $project as xs:string,
                                                                      $format as xs:string?
                                                                      ){

   if ($path = "/geo/admin") then prosopoManager:dashboard()
   else if (starts-with($path, "/exist/apps/estudium/geo/places")) then prosopoManager:getProjectPlaces($format)
   else if (starts-with($path, "/exist/apps/estudium/geo/document/")) then prosopoManager:getDocumentPlaces($resource)


  else <bold>{ $resource } + { $path }</bold>
};

declare function prosopoManager:dashboard(){
 <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">

       <div id="prosopoManager" class="">
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-md-12">
                     <div id="mapid"></div>

                </div>
            </div>
            </div>

        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/prosopoManager/prosopoManager.js"/>
        <link href="$ausohnum-lib/resources/css/prosopoManager.css" rel="stylesheet" type="text/css"/>

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

declare function prosopoManager:peopleManager(){
let $peopleNumber := count($prosopoManager:peopleCollection//lawd:person)
return
 <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
 <!--Script for fancytree-->
        <!-- Include Fancytree skin and library -->
        <link href="$ausohnum-lib/resources/scripts/jquery/fancytree/skin-bootstrap/ui.fancytree.css" rel="stylesheet" type="text/css"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree-all.min.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.filter.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.glyph.js" type="text/javascript"/>
        <script src="$ausohnum-lib/resources/scripts/jquery/fancytree/jquery.fancytree.wide.js" type="text/javascript"/>
       <div id="prosopoManager" class="">
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-md-12">
                    <div class="row">
                        <div class="col-xs-3 col-sm-3 col-md-3">
                        <input name="searchTree" id="searchTree" placeholder="Filter { $peopleNumber } persons" title="Filter places" autocomplete="off"/>
                            <button id="btnResetSearch" class="btn btn-default" title="Clear filter">
                                    <i class="glyphicon glyphicon-remove-sign"/>
                             </button>
                      
 
                        <div id="collection-tree" data-type="json"/>
                        </div>
                        <div id="peopleEditor" class="col-xs-9 col-sm-9 col-md-9">
                        
                        
                        </div>
                    </div>
                </div>
                <div class="col-xs-5 col-sm-5 col-md-5">

            
                </div>
            </div><!--End of row-->
<!--    <div id="mapid"></div>-->
            
            { prosopoManager:searchProjectPeopleModal() }
            { prosopoManager:addFunctionModal() }
            { prosopoManager:deleteRelationshipModal() }
            </div>



        <link href="$ausohnum-lib/resources/css/prosopoManager.css" rel="stylesheet" type="text/css"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/prosopoManager/prosopoManager.js"/>
        
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/prosopoManager/peopleTree.js"/>

      


 </div>
 };
declare function prosopoManager:peopleManager2(){

let $peopleCollection := util:eval('collection("' || $prosopoManager:data-collection-path || "/people" || '")')
let $peopleNumber := count($peopleCollection//lawd:person)
(:let $peopleNumber := count($prosopoManager:peopleCollection//lawd:person):)
let $nameNumber := count($peopleCollection//lawd:personalName)
let $bondNumber := count($peopleCollection//snap:hasBond)
let $peopleId := request:get-parameter("resource", "")
let $peopleUri := $prosopoManager:uriBase || "/people/" || $peopleId || "#this"
(:let $personRecord := $prosopoManager:peopleRepo//lawd:person[@rdf:about = $peopleUri]:)
let $updateTitleWindow :=
                        if ($peopleId != "") then '$(document).ready( function () {{
                document.title = "People - " + "' || $peopleId || '";
                    }});' 
                    else '$(document).ready( function () {{
                document.title = "' || "APC People" || '";
                    }});'
return

 <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
    <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.css" />
    <script src="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.js"></script>

         <div id="prosopoManager" class="">
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-md-12">
                    <div class="row">
                        <div id="sideColPeople" class="col-xs-3 col-sm-3 col-md-3">
                        <button class="btn btn-sm btn-primary" onclick="openNewPersonForm()">Create a new person</button>
                        <br/>
                                                       { prosopoManager:listPeopleAsTable() }
<!--                        <ul class="nav nav-tabs" id="peopleTab" role="tablist">
                                <li class="nav-item">
                                  <a class="nav-link active" id="home-peopleTab" data-toggle="tab" href="#homePeopleTab" role="tab" aria-controls="home-peopleTab" aria-selected="true">Search People</a>
                                </li>
                                <li class="nav-item">
                                  <a class="nav-link" id="allPeopleTree-peopleTab" data-toggle="tab" href="#allPeopleTree" role="tab" aria-controls="allPeopleTree-peopleTab" aria-selected="false">All People</a>
                                </li>
                                
                         </ul>
                         <div class="tab-content" id="peopleTabContent">
                                <div class="tab-pane fade show active in" id="homePeopleTab" role="tabpanel" aria-labelledby="home-peopleTab">
                                       <input name="searchPeople" id="searchPeople" class="projectPeopleSearch" placeholder="Search among { $peopleNumber } persons" title="" autocomplete="off">
                                       <span id="LoadingImage" style="display: none">
                                       <img class="loadingImage" src="$shared/resources/scripts/jquery/skin/loading.gif" /></span></input>
                                        <div id="peopleSearchResult"/>
                                
                                </div>
                                <div class="tab-pane fade" id="allPeopleTree" role="tabpanel" aria-labelledby="allPeopleTree-peopleTab">
                                
                                    { prosopoManager:listPeopleAsTable() }
                                </div>
                                
                         </div>
 -->                       
                        </div>
                        
                        <div id="peopleEditor" class="col-xs-9 col-sm-9 col-md-9">
                        { if($peopleId ="") then (
                        <div>
                        <h1 class="display-4">Welcome to APC People</h1>
                        <h4>Numbers of...</h4>
                        <ul class="list-group">
                        <li class="list-group-item"><strong>... persons: </strong>{$peopleNumber}</li>
                        <li class="list-group-item"><strong>... personal names: </strong>{$nameNumber}</li>
                        <li class="list-group-item"><strong>... interpersonal relations:</strong> {$bondNumber}</li>
                        </ul>
                        </div>
                        )
                        else if($peopleId ="new") then
                        prosopoManager:newPersonForm()
                        else prosopoManager:getPeopleHTML2($peopleUri) }
                        </div>
                    </div>
                </div>
                <div class="col-xs-5 col-sm-5 col-md-5">

            
                </div>
            </div><!--End of row-->
<!--    <div id="mapid"></div>-->
            
            { prosopoManager:searchProjectPeopleModal() }
            { prosopoManager:addFunctionModal() }
            { prosopoManager:deleteRelationshipModal() }
            { prosopoManager:addResourceDialog("seeFurther") }
            </div>



        <link href="$ausohnum-lib/resources/css/prosopoManager.css" rel="stylesheet" type="text/css"/>
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/prosopoManager/prosopoManager.js"/>
          <script type="text/javascript">{ $updateTitleWindow }</script>


 </div>
 };
 

 
declare function prosopoManager:getPeopleRdf($uri){
    (:$prosopoManager:place-collection//.[@rdf:about=$data/uri]:)
 let $decodedUri := xmldb:decode-uri($uri)
 return
(: $uri:)
(: <a>{$decodedUri}</a> :)
    util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $decodedUri || '"][1]')
};

 declare function prosopoManager:getPeopleHTML($uri){
(:    Function to display People details
:)
(:     let $uri :="https://patrimonium.huma-num.fr/people/" || $uri   :)
     let $uriShort := substring-before($uri, '#this')
     let $decodedUri := xmldb:decode-uri($uriShort)
(:     let $peopleRdf := util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//.[@rdf:about="' || $decodedUri || '#this"]'):)
     
     let $peopleRdf := $prosopoManager:peopleCollection//lawd:person[@rdf:about= $decodedUri || '#this']
     
     let $persName := $peopleRdf//lawd:personalName/text()
     let $docs := <div class="xmlElementGroup">
                         <h4 class="subSectionTitle">List of documents attached to this person</h4>
                         <div id="listOfDocuments">
                         <ul class="listNoBullet">{
                           for $doc at $pos in $prosopoManager:doc-collection//tei:TEI[descendant-or-self::tei:listPerson//tei:person[@corresp=$uriShort]]
                            (:$spatiumStructor:doc-collection//tei:TEI[tei:listPlace//tei:place//tei:placeName[@ref=$uriShort]]:)
                                   
                                   let $title := $doc//tei:titleStmt/tei:title[not(ancestor::tei:bibFull)]/text()
                                   let $docUri := $doc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]
                                   let $datingNotBefore :=
                                                    if($doc//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notBefore-custom)
                                                           then data($doc//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notBefore-custom)
                                                    else if($doc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/tei:date/@notBefore)
                                                    
                                                    then data($doc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/tei:date/@notBefore)
                                                    else ()
                                    let $datingNotAfter :=
                                                    if($doc//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notAfter-custom)
                                                           then data($doc//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notAfter-custom)
                                                    else if($doc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/tei:date/@notAfter)
                                                    
                                                    then data($doc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/tei:date/@notAfter)
                                                    else ()
        
                                   let $placeType := (
                                                                let $placeNodes := 
                                                                $doc//node()[@ref=$uriShort]
                                                                for $placeNode in $placeNodes
                                                                    return
                                                                        if ($placeNode/@ana)
                                                                        then data($placeNode/@ana)
                                                                        else ($placeNode/parent::node()/name())
                                                                        )
                                             return
                                                <li>{ $pos }
                                                <span class="glyphicon glyphicon-file"/><a href="{ $docUri }" title="Open this document in same window" target="_self">{ $title }</a>
                                                <a href="{ $docUri }" target="_blank">
                                                                <i class="glyphicon glyphicon-new-window"/></a>
                                                                {if($datingNotBefore) then <span>[{$datingNotBefore }{
                                                                if($datingNotAfter) then "-" || $datingNotAfter else ()}]</span>
                                                                else()
                                                                }
                                                </li>
                            
                            }</ul>
                            </div>
                     </div>
  
   return
   ((<http:response status="200"> 
                    <http:header name="Cache-Control" value="no-cache"/> 
                </http:response> 
     ),
   <div>
            <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
                      <div class="row">
                                    <div class="col-sm-12 col-md-12 col-lg-12">
                                                <span id="currentPeopleUri" class="hidden">{ $uriShort }</span>
                                                <h3>{ $persName }</h3>
                                                <h4>URI { $uri }</h4>
                                                <div class="">
                                                <ul class="nav nav-pills" id="pills-tab" role="tablist">
                                                            <li class="nav-item active">
                                                              <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Person details</a>
                                                            </li>
                                                            
                                                            <li class="nav-item">
                                                              <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML</a>
                                                            </li>
                                                 </ul>
                                                 <div class="tab-content" id="nav-tabContent">
                                                            <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
                                                                         <div class="row">
                                                                         <div class="col-sm-4 col-md-4 col-lg-4">
                                                                             { prosopoManager:displayElement('standardizedName', $decodedUri, (), ()) }
                                                                             { prosopoManager:displayElement('sex', $decodedUri, (), ()) }
                                                                             { prosopoManager:displayElement('personalStatus', $decodedUri, (), ()) }
                                                                             { prosopoManager:displayElement('socialStatus', $decodedUri, (), ()) }
                                                                             { prosopoManager:displayElement('juridicalStatus', $decodedUri, (), ()) }
                                                                        </div>
                                                                        <div class="col-sm-4 col-md-4 col-lg-4">
                                                                                {prosopoManager:hasFunction($uri)}
                                                                         </div>
                                                                        <div class="col-sm-4 col-md-4 col-lg-4">
                                                                                {prosopoManager:hasBond($uri)}
                                                                                { $docs }
                                                                                 {prosopoManager:relatedPlaces( $uri)}
                                                                        </div>
                                                                        </div>
                                                                        <div class="row">
                                                                             { prosopoManager:displayElement('generalCommentary', $decodedUri, (), ()) }
                                                                             <br/>
                                                                             { prosopoManager:displayElement('privateCommentary', $decodedUri, (), ()) }
                                                                        
                                                                        </div>
                                                            
                                                            </div>
                                                            
                                                            <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
                                                             { prosopoManager:xmlFileEditorWithUri($uri) }
                                                            </div>
                                                    </div>
                                        </div>
                                </div>
                            </div>
                    </div>
                     <script>
        
 function getXmlEditorContent(){{
        var xmlFileEditor = ace.edit("xml-editor-file");
        return xmlFileEditor.getValue();
         
 }};           

    
                 </script>   
               <script type="text/javascript" src="$ausohnum-lib/resources/scripts/prosopoManager/prosopoManager.js"/>
               <link rel="stylesheet" href="$ausohnum-lib/resources/css/skosThesau.css"/>
                    <link href="$ausohnum-lib/resources/css/prosopoManager.css" rel="stylesheet" type="text/css"/>
            <link rel="stylesheet" href="$ausohnum-lib/resources/css/teiEditor.css"/>
</div>
)
 };

declare function prosopoManager:getPeopleHTML2($uri){
(:    Function to display People details
:)
(:     let $uri :="https://patrimonium.huma-num.fr/people/" || $uri   :)
    let $peopleCollection := util:eval('collection("' || $prosopoManager:data-collection-path || "/people" || '")')
    let $uriLong := if(not(contains($uri, 'http'))) then $prosopoManager:baseUri || "/people/" || $uri || "#this" else $uri
     let $uriShort := substring-before($uriLong, '#this')
     let $decodedUri := xmldb:decode-uri($uriShort)
(:     let $peopleRdf := util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//.[@rdf:about="' || $decodedUri || '#this"]'):)
     
     let $peopleRdf := $peopleCollection//lawd:person[@rdf:about= $decodedUri || '#this']
     
     let $persName := $peopleRdf//lawd:personalName/text()
     let $docs := <div class="xmlElementGroup">
                         <h4 class="subSectionTitle">List of documents attached to this person</h4>
                         <div id="listOfDocuments">
                         <ul class="listNoBullet">{
                           for $doc at $pos in $prosopoManager:doc-collection//tei:TEI[descendant-or-self::tei:listPerson//tei:person[@corresp=$uriShort]]
                            (:$spatiumStructor:doc-collection//tei:TEI[tei:listPlace//tei:place//tei:placeName[@ref=$uriShort]]:)
                                   
                                   let $title := $doc//tei:titleStmt[1]/tei:title[not(ancestor::tei:bibFull)]/text()
                                   let $docUri := $doc//tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]
                                   let $datingNotBefore :=
                                                    if($doc//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[1]/@notBefore-custom)
                                                           then data($doc//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[1]/@notBefore-custom)
                                                    else if($doc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[1]/tei:date/@notBefore)
                                                    
                                                    then data($doc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[1]/tei:date[1]/@notBefore)
                                                    else ()
                                    let $datingNotAfter :=
                                                    if($doc//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[1]/@notAfter-custom)
                                                           then data($doc//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[1]/@notAfter-custom)
                                                    else if($doc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[1]/tei:date/@notAfter)
                                                    
                                                    then data($doc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate[1]/tei:date/@notAfter)
                                                    else ()
        
                                   let $placeType := (
                                                                let $placeNodes := 
                                                                $doc//node()[@ref=$uriShort]
                                                                for $placeNode in $placeNodes
                                                                    return
                                                                        if ($placeNode/@ana)
                                                                        then data($placeNode/@ana)
                                                                        else ($placeNode/parent::node()/name())
                                                                        )
                                             return
                                                <li>{ $pos }
                                                <span class="glyphicon glyphicon-file"/><a href="{ $docUri }" title="Open this document in same window" target="_self">{ $title }</a>
                                                <a href="{ $docUri }" target="_blank"><i class="glyphicon glyphicon-new-window"/></a>
                                                <a href="{ replace($docUri, '/documents', '/egypt-documents')}" target="_blank" title="Open with editor dedicated to Egyptian material"><i class="glyphicon glyphicon-flash"/></a>                                                               
                                                               {if($datingNotBefore) then <span>[{$datingNotBefore }{
                                                               
                                                               if($datingNotAfter) then "-" || $datingNotAfter else ()}]</span>
                                                                else()
                                                                }
                                                </li>
                            
                            }</ul>
                            </div>
                     </div>
  
   return
   (
   (:(<http:response status="200"> 
                    <http:header name="Cache-Control" value="no-cache"/> 
                </http:response> 
     ),:)
   <div id="htmlContent">
            
                      <div class="row">
                                    <div class="col-sm-12 col-md-12 col-lg-12">
                                                <span id="currentPeopleUri" class="hidden">{ $uriShort }</span>
                                                <h3>{ $persName }</h3>
                                                <h4>URI { $uriShort }</h4>
                                                <div class="">
                                                <ul class="nav nav-pills" id="pills-tab" role="tablist">
                                                            <li class="nav-item active">
                                                              <a class="nav-link" id="pills-home-tab" data-toggle="pill" href="#nav-metadata" role="tab" aria-controls="pills-home" aria-selected="false">Person details</a>
                                                            </li>
                                                            
                                                            <li class="nav-item">
                                                              <a class="nav-link" id="pills-profile-tab" data-toggle="pill" href="#nav-xmlfile" role="tab" aria-controls="pills-profile" aria-selected="false">XML</a>
                                                            </li>
                                                 </ul>
                                                 <div class="tab-content" id="nav-tabContent">
                                                            <div class="tab-pane fade in active" id="nav-metadata" role="tabpanel" aria-labelledby="nav-metadata-tab">
                                                                         <div class="row">
                                                                         <div class="col-sm-4 col-md-4 col-lg-4">
                                                                             { prosopoManager:displayElement('standardizedName', $decodedUri, (), ()) }
                                                                             { prosopoManager:displayElement('exactMatches', $decodedUri, (), ()) }
                                                                             { prosopoManager:displayElement('sex', $decodedUri, (), ()) }
                                                                             { prosopoManager:displayElement('personalStatus', $decodedUri, (), ()) }
                                                                             { prosopoManager:displayElement('socialStatus', $decodedUri, (), ()) }
                                                                             { prosopoManager:displayElement('juridicalStatus', $decodedUri, (), ()) }
                                                                        </div>
                                                                        <div class="col-sm-4 col-md-4 col-lg-4">
                                                                                {prosopoManager:hasFunction($uriLong)}
                                                                         </div>
                                                                        <div class="col-sm-4 col-md-4 col-lg-4">
                                                                                {prosopoManager:hasBond($uriLong)}
                                                                                { $docs }
                                                                                 {prosopoManager:relatedPlaces( $uriLong )}
                                                                        </div>
                                                                        </div>
                                                                        <div class="row">
                                                                        { prosopoManager:resourcesManager('seeFurther', $decodedUri) }
                                                                       
                                                                             { prosopoManager:displayElement('generalCommentary', $decodedUri, (), ()) }
                                                                             <br/>
                                                                             { prosopoManager:displayElement('privateCommentary', $decodedUri, (), ()) }
                                                                        
                                                                        </div>
                                                            
                                                            </div>
                                                            
                                                            <div class="tab-pane fade in" id="nav-xmlfile" role="tabpanel" aria-labelledby="nav-text-tab">
                                                             { prosopoManager:xmlFileEditorWithUri($uriLong) }
                                                            </div>
                                                    </div>
                                        </div>
                                </div>
                            </div>
            
                     <script>
        
 function getXmlEditorContent(){{
        var xmlFileEditor = ace.edit("xml-editor-file");
        return xmlFileEditor.getValue();
         
 }};           

    
                 </script>   
               <script type="text/javascript" src="$ausohnum-lib/resources/scripts/prosopoManager/prosopoManager.js"/>
               <link rel="stylesheet" href="$ausohnum-lib/resources/css/skosThesau.css"/>
                    <link href="$ausohnum-lib/resources/css/prosopoManager.css" rel="stylesheet" type="text/css"/>
            <link rel="stylesheet" href="$ausohnum-lib/resources/css/teiEditor.css"/>
</div>
)
 };




declare function prosopoManager:newPersonForm(){
       <div id="spatiumStructor" class="">
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-md-12">
                <h3>Create a new person</h3>
                <div class="form-group">
                        <label for="newPersonStandardizedNameEn">Standardized name (in English)</label>
                                     <input type="text" class="form-control"
                                     id="newPersonStandardizedNameEn" 
                                     name="newPersonStandardizedNameEn"
                                     />
               </div>
                               <!--
               <div class="form-group row">
                <label for="newPersonSex">Sex</label>
                                <select id="newPersonSex" name="newPersonSex">
                                     <option value="Male">Male</option>
                                     <option value="Female">Female</option>
                                     </select>
               
                </div>
                                      -->
               {skosThesau:dropDownThesauForElement("sex", "c23490", "en", 'Sex', 'row', (), (), "uri")}
               
               {skosThesau:dropDownThesauForElement("personalStatus", "c22071", "en", 'Personal Status', 'row', (), (), "uri")}    
                {skosThesau:dropDownThesauForElement("socialStatus", "c22077", "en", 'Rank', 'row', (), (), "uri")}
                {skosThesau:dropDownThesauForElement("juridicalStatus", "c22081", "en", 'Citizenship', 'row', (), (), "uri")}
               
               
             </div> 
             <div>
                    <button id="createNewPerson" 
                                  class="btn btn-success"
                                  onclick="createNewPerson()"
                                  appearance="minimal"
                                  type="button">Create person<i class="glyphicon glyphicon glyphicon-saved"></i></button>
                 </div>               
                </div>
                </div>
              

};



declare function prosopoManager:createNewPerson($data as node(), $project as xs:string){

let $peopleNumberList := for $person in $prosopoManager:peopleCollection//apc:people/@rdf:about
            where $person != ""
                  order by xs:integer(functx:substring-after-last($person, "/" ))
                  return
                  xs:integer(functx:substring-after-last($person, "/" ))
        
let $personIdPrefix := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")//idPrefix[@type='people']/text()
let $last-id:= fn:max($peopleNumberList)
let $newId := fn:sum(($last-id, 1))
let $newUri := $prosopoManager:baseUri|| "/" || "people" || "/" || fn:sum(($last-id, 1))
let $standardizedName := $data//standardizedName/text()


        let $sex := $data//sex/text()
        let $sexUri := $data//sexUri/text()
        let $personalStatus := $data//personalStatus/text()
        let $socialStatus:= $data//socialStatus/text()
        let $juridicalStatus := $data//juridicalStatus/text()
        let $personalStatusUri := $data//personalStatusUri/text()
        let $socialStatusUri := $data//socialStatusUri/text()
        let $juridicalStatusUri := $data//juridicalStatusUri/text()
        
                
let $newPersonRecord :=
<rdf:RDF 
        xmlns:apc="http://patrimonium.huma-num.fr/onto#"
        xmlns:lawd="http://lawd.info/ontology/"
        xmlns:pleiades="https://pleiades.stoa.org/places/vocab#"
        xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:foaf="http://xmlns.com/foaf/0.1/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"         
        xmlns:skos="http://www.w3.org/2004/02/skos/core#"
        xmlns:snap="http://onto.snapdrgn.net/snap#" >
        <lawd:person rdf:about="{$newUri}#this">
             <foaf:primaryTopicOf>
                <apc:people rdf:about="{$newUri}">
                    <lawd:personalName xml:lang="en">{ $standardizedName }</lawd:personalName>
                    <apc:sex rdf:resource="{ $sexUri }">{ $sex }</apc:sex>
                    
                    {
                    if ($personalStatusUri != "") then <apc:personalStatus rdf:resource="{ $personalStatusUri }">{ $personalStatus }</apc:personalStatus>
                    else <apc:personalStatus rdf:resource=""/>
                    }
                    {
                    if ($socialStatusUri != "") then <apc:socialStatus rdf:resource="{ $socialStatusUri }">{ $socialStatus }</apc:socialStatus>
                    else <apc:socialStatus rdf:resource=""/>
                    }
                    {
                    if ($juridicalStatusUri != "") then <apc:juridicalStatus rdf:resource="{ $juridicalStatusUri }">{ $juridicalStatus }</apc:juridicalStatus>
                    else <apc:juridicalStatus rdf:resource=""/>
                    }
                    
                    <skos:note/>
                 </apc:people>
                 <skos:note type="private"/>
            </foaf:primaryTopicOf>
        </lawd:person>
</rdf:RDF>


let $createPersonInPeopleRepo :=
     xmldb:store($prosopoManager:peopleCollectionPath, $newId || ".xml", $newPersonRecord)
 let $changeMod := sm:chmod(xs:anyURI(concat($prosopoManager:peopleCollectionPath, "/", $newId, ".xml")), "rw-rw-r--")
      

return
<result>
<newUri>{ $newUri }</newUri>
<newId>{ $newId }</newId>
<newHtml>{
prosopoManager:getPeopleHTML( $newUri ||"#this" )
}</newHtml>
</result>
};






declare function prosopoManager:editorMap($resourceID as xs:string){

<div>
<div id="editorMap"></div>

<script type="text/javascript" src="$ausohnum-lib/resources/scripts/prosopoManager/prosopoManager.js"/>
        <link href="$ausohnum-lib/resources/css/prosopoManager.css" rel="stylesheet" type="text/css"/>

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


declare function prosopoManager:placesManagerInDoc($placeId){
        <div class="row">
                 <div class="sideToolPane col-sm-3 col-md-3 col-lg-3">
                 <div>
                         <span class="subSectionTitle">List of places attached to this doc (<span class="docPlacesDot"></span> on the map):</span>
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

                                     <button id="addNewPlaceButtonDocPlaces " class="btn btn-success hidden" onclick="addPlaceToDoc('{$prosopoManager:placeId}')" appearance="minimal" type="button">Add place to document<i class="glyphicon glyphicon glyphicon-saved"></i></button>
                         </div>
                   </div>
                   </div>

                   <div id="editorMap"/>

               </div>
};


declare function prosopoManager:peripleoLookUp( $placeId ){
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
                                     <button id="addNewPlaceButtonDocPlaces " class="btn btn-success hidden" onclick="addPlaceToDoc('{$prosopoManager:placeId}')" appearance="minimal" type="button">Add place to document<i class="glyphicon glyphicon glyphicon-saved"></i></button>
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









declare function prosopoManager:getProjectPlaces($format as xs:string) {
(:let $placeCollection := collection("/db/apps/" || $prosopoManager:project || "Data/places" || "/" ||  $prosopoManager:project ):)
    let $places := collection("/db/apps/" || $prosopoManager:project || "Data/places" || "/" ||  $prosopoManager:project )/node()
    let $paramMap :=
        switch($format)
            case "2json2" return
                <output:serialization-parameters>
                <output:method>{$format}</output:method>
                <output:indent>true</output:indent>
                <output:mediatype>text/plain</output:mediatype>

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
             default return null

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
serialize($places2GeoJSon, $paramMap)

};
declare function prosopoManager:getDocumentPlaces($docID as xs:string) as xs:string{

    let $placeRefsInDoc := collection("/db/apps/" || $prosopoManager:project || "Data/documents" )/id($docID)//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace
    let $placeCollection := collection("/db/apps/" || $prosopoManager:project || "Data/places" || "/" ||  $prosopoManager:project )
    let $places :=
                                 <places>{ for $place in $placeRefsInDoc//tei:place
                                        let $projectPlaceUri := 
                                                let $splitRef := tokenize(data($place/tei:placeName/@ref), " ")
                                                return 
                                                    for $uri in $splitRef
                                                    return
(:                                                          string-join($uri, "-->"):)
                                                    if(contains($uri, $prosopoManager:uriBase)) then 
                                                    normalize-space($uri[1]) else ()
                                            
                                return
                                $placeCollection//spatial:Feature[@rdf:about=$projectPlaceUri || "#this"]}</places>


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

declare function prosopoManager:getProjectPlacesJSon(){

    let $places := collection("/db/apps/" || $prosopoManager:project || "Data/places" || "/" ||  $prosopoManager:project )/node()
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

<result>

{serialize($places2GeoJSon, $paramMap)}
</result>
};

(:declare function prosopoManager:displayPlaceDetails($placeId as xs:string, $path as xs:string){

    let $place :=  util:eval( "collection('" || $prosopoManager:project-people-collection-path
                                                              || "')//spatial:Feature[@rdf:about='"
                                                              || $prosopoManager:baseUri || $path || "#this']" ) 
    
    return
  if (contains($placeId, "root")) then
<div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
           <div class="row">
 
<div>{$path} is not a valid place URI
    </div>
    </div>
    </div>
      else
      (
        <div data-template="templates:surround" data-template-with="templates/page.html" data-template-at="content">
                   <div class="row">
 
<h4>{ $place//dcterms:title[1]/text() }</h4>
<h5>{ $prosopoManager:baseUri || $path || "#this"})</h5>

</div>      
        
        </div>
      )
};
:)
declare function prosopoManager:displayElement($elementNickname as xs:string,
                                          $resourceURI as xs:string?,
                                          $index as xs:int?,
                                          $xpath_root as xs:string?) {
    let $elementNode := $prosopoManager:peopleElements//xmlElement[nm=$elementNickname]
    let $elementIndex := if ($index ) then ("[" || string($index) || "]" ) else ("")
    let $fieldType := $elementNode/fieldType/text()
    let $attributeValueType := $elementNode/attributeValueType/text()
    let $conceptTopId := if($elementNode/thesauDb/text()) then
                        substring-after($elementNode/thesauTopConceptURI, '/concept/')
                        else()
    let $xpathRaw := $elementNode/xpath/text()
    let $xpathEnd := if(contains($xpathRaw, "/@"))
            then( functx:substring-before-last($xpathRaw[1], '/') || $elementIndex || "/" || functx:substring-after-last($xpathRaw[1], '/'))
            else($xpathRaw)
    let $elementAncestors := $elementNode/ancestor::xmlElement
    let $XPath := if($xpath_root)
                    then
                        $xpath_root || $xpathRaw
                    else
                     if($elementNode/ancestor::xmlElement)
                                then
                                    string-join(
                                    for $ancestor at $pos in $elementAncestors
                                    let $ancestorIndex := if($pos = 1 ) then
                                        if($index) then "[" || string($index) || "]" else ("")
                                        else ("")
                                    return
                                    if (contains($ancestor/xpath/text(), '/@'))
                                    then
                                        substring-before($ancestor/xpath/text(), '/@')
                                        || $ancestorIndex
                                        else $ancestor/xpath/text() ||
                                        $ancestorIndex
                                    )
                                 || $xpathEnd
                            else
                        $xpathEnd


    let $elementDataType := $prosopoManager:peopleElements//xmlElement[nm=$elementNickname]/contentType/text()
    let $elementFormLabel := $prosopoManager:peopleElements//xmlElement[nm=$elementNickname]/formLabel[@xml:lang=$prosopoManager:lang]/text()
(:    let $resourceID := if($resourceID != "") then $resourceID else $prosopoManager:placeId:)
(:    let $Doc := util:eval("collection('" || $prosopoManager:project-people-collection-path || "')//.[@rdf:about='" || $resourceURI ||"']"):)
(:    let $Doc := $prosopoManager:doc-collection//tei:TEI[@rdf:about= $resourceURI]:)
    (:let $elementValue :=
         (data(
            util:eval("collection('" || $prosopoManager:project-people-collection-path || "')//.[@rdf:about='" || $resourceURI ||"']/" || $XPath)))
:)

    return
        switch ($fieldType)
        case "input" return
        prosopoManager:displayElementCardi($elementNickname, $resourceURI, $index, 'input', $XPath)
        case "textarea" return
        prosopoManager:displayElementCardi($elementNickname, $resourceURI, $index, 'textarea', $XPath)
        case "combobox" return
        prosopoManager:displayXmlElementWithThesauCardi($elementNickname, $conceptTopId, $resourceURI, $index, $XPath)
        default return prosopoManager:displayElementCardi($elementNickname, $resourceURI, $index, 'input', $XPath)
};

declare function prosopoManager:displayElementCardi($elementNickname as xs:string,
             $resourceURI as xs:string?,
             $index as xs:integer?,
             $type as xs:string?,
             $xpath_root as xs:string?) {

        let $currentResourceURI := if($resourceURI != "") then $resourceURI || "#this" else  $prosopoManager:placeId
        
        let $indexNo := if($index) then data($index) else "1"
        let $elementNode := $prosopoManager:peopleElements//xmlElement[nm=$elementNickname]
        let $elementIndex := if($elementNode/ancestor::xmlElement)
                                then ""
                            else if
                                ($index) then ("[" || string($index) || "]" )
                            else ("")

        let $xpathEnd := if(contains($elementNode//xpath[1]/text(), "/@"))
            then(functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/"
            || functx:substring-after-last($elementNode//xpath/text(), '/')
            )
            else (
            $elementNode/./xpath/text()
            )
        
        let $elementAttributeName :=if(contains($elementNode//xpath[1]/text(), "/@"))
                        then functx:substring-after-last($elementNode//xpath[1]/text(), "/@")
                        else ""
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
                                if (contains($ancestor/xpath/text(), '/@'))
                                    then
                                        substring-before($ancestor/xpath/text(), '/@')
                                        || $ancestorIndex
                                    else $ancestor/xpath/text() ||
                                        $ancestorIndex
                        )
                        || $xpathEnd
                    else $xpathEnd




     let $xpathBaseForCardinalityX :=
            if (contains($XPath, "/@")) then

            (functx:substring-before-last(functx:substring-before-last($XPath, "/@"), '/'))

            (: (functx:substring-before-last($XPath, "/@")) :)

            else (: if(functx:substring-before-last($XPath, '/') !='') then :)
                (""||functx:substring-before-last($XPath, '/')||"")
            (: else "" :)

     let $selectorForCardinalityX :=
            if (contains($XPath, "/@")) then
            (functx:substring-after-last(substring-before($XPath, "/@"), "/"))
            else
                (functx:substring-after-last($XPath, "/"))

    let $contentType :=$elementNode/contentType/text()
    let $elementDataType := $elementNode/contentType/text()
    let $elementFormLabel := $elementNode/formLabel[@xml:lang=$prosopoManager:lang]/text()
    let $elementCardinality := $elementNode/cardinality/text()
    let $attributeValueType := $elementNode/attributeValueType/text()

(:    let $Doc := $prosopoManager:place-collection/id($prosopoManager:docId):)

    let $elementValue :=
        if($elementCardinality = "1" ) then (
                    util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$currentResourceURI ||"']/" || $XPath ))
         else if($elementCardinality = "x" )
                then (
                    if($contentType != "attribute") then
                              (  util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"
                                ||$currentResourceURI
                                ||"']/"
                             || $xpathBaseForCardinalityX || "/" || $selectorForCardinalityX )
                             )
                    else (
                        util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"
                                    ||$currentResourceURI
                                    ||"']"
                                 || $xpathBaseForCardinalityX
                                 || "/" || $selectorForCardinalityX )
                       )
                    )

         else(
         util:eval( "collection('" || $prosopoManager:project-people-collection-path
         ||"')//lawd:person[@rdf:about='"||$currentResourceURI ||"']/" || $XPath ))




    let $valuesTotal := count($elementValue)
    (:let $data2display :=
    if($elementCardinality = "1" ) then ( "e"||
        data(util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//.[@rdf:about='" || $elementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))
        ) else():)
    let $inputName := 'selectDropDown' (:||$topConceptId:)

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $prosopoManager:project || "/data/documents')//id('"||$prosopoManager:docId
                    ||"')/"
                    || functx:substring-before-last($XPath2Ref, '/') || "//tei:category"):)
    return

        (
        if($elementCardinality ="1") then

        (
                let $elementAttributeValue :=
                  (data(util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$currentResourceURI ||"']/" || $XPath)))
             let $elementTextNodeValue :=
                     if($elementDataType = "textNodeAndAttribute" ) then
                    (data(util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$currentResourceURI ||"']/" || substring-before($XPath, '/@'))))
(:                  ANCIENNE VERSION"là" || (serialize(functx:change-element-ns-deep(util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//id('" ||$prosopoManager:docId ||"')/" || substring-before($XPath, '/@')), "", ""))):)
                   else
                  (serialize(functx:change-element-ns-deep(util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$currentResourceURI ||"']/" || $XPath || "/node()"), "", "")))
             return

                 <div class="xmlElementGroup">
                    <div id="{$elementNickname}_display_{$indexNo}_1" class="">
                            <div class="{switch($type)
                                        case 'textarea' return 'xmlElementGroupHeader'
                                        default return 'xmlElementGroupHeaderInline'
                                        }">
                                    <span class="labelForm">{$elementFormLabel} <span class="teiInfo">
                                    <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                                    </span></span>
                            </div>
                            <div id="{$elementNickname}_value_{$indexNo}_1" class="xmlElementValue"  style="{if($type= "textarea") then "width: 100%;" else ()}">
                                    {switch ($elementDataType)
                                        case "text" return $elementTextNodeValue
                                        case "enrichedText" return
                                        (<div style="float:left; width: 100%">
                                               <textarea id="{$elementNickname}_{$indexNo}_1" class="form-control summernote" name="{$elementNickname}_{$indexNo}_1">{ $elementTextNodeValue }</textarea>
                                               <span id="{$elementNickname}_{$indexNo}_1_message"/>
                                            <script>
                                                           // markupStr = '{$elementTextNodeValue}';
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
                                    }
                            </div>
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
                            <span class="labelForm">{$elementFormLabel} <span class="teiInfo">
                                    <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                             </span></span>
                                            {switch ($type)
                                             case "input" return
                                                switch ($elementDataType)
                                                case "text"
                                                case "attribute" return
                                                <input id="{$elementNickname}_{$indexNo}_1" class="form-control" name="{$elementNickname}_{$indexNo}_1" value="{$elementAttributeValue}"></input>
                                                case "textNodeAndAttribute" return
                                                <div>
                                                <span>Value of <em>Attribute</em> {functx:substring-after-last($XPath, '/')}</span><input id="{$elementNickname}_text_{$indexNo}_1" class="form-control" name="{$elementNickname}_text_{$indexNo}_1" value="{ $elementAttributeValue }"></input>
                                                <span> Value of <em>Node Text</em></span><input id="{$elementNickname}_attrib_{$indexNo}_1" class="form-control" name="{$elementNickname}_attrib_{$indexNo}_1" value="{ $elementTextNodeValue }"></input>
                                                </div>
                                                default return "Error! Check data type."
                   
                                             case "textarea" return
                                                <textarea id="{$elementNickname}_{$indexNo}_1" class="form-control" name="{$elementNickname}_{$indexNo}_1">{$elementTextNodeValue}</textarea>
                                             default return null
                                             }
                         <button id="{$elementNickname}SaveButton" class="btn btn-success"
                         onclick="saveDataSimple('{$currentResourceURI}', '{$elementNickname}', '{$XPath}', '{$elementDataType}', '{$indexNo}', '{$elementCardinality}')" appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-ok-circle"></i></button>
                         
                         <button id="{$elementNickname}CancelEdit" class="btn btn-danger"
                         onclick="cancelEdit('{$elementNickname}', '{$indexNo}', '{$elementTextNodeValue}', '{$type}', '1') "
                                 appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                    
                    </div></div>
                 </div>
        )
(:        Cardinality > 1:)
        else
        <div id="{$elementNickname}_group_{$indexNo}" class="xmlElementGroup">
        <div class="xmlElementGroupHeaderBlock">
        <span class="labelForm">{$elementFormLabel}<span class="teiInfo">
                    <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                    </span></span>

                    { if($elementCardinality ="x") then
                    <button id="{$elementNickname}addItem_{$indexNo}" class="btn btn-primary addItem"
                        onclick="addItem(this, '{ $inputName }_add_{ $indexNo }', '{ $indexNo }')"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>
                  else()
                   }
              </div>
              {for $item at $pos in $elementValue

                let $elementAttributeValue :=if($elementAttributeName !="")
                            then util:eval("data($item/@" || $elementAttributeName ||")")
                            else()
                (: if($elementDataType = "textNodeAndAttribute") then

                                                (data(util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$currentResourceURI ||"']/"
                                                || $xpathBaseForCardinalityX|| "[" || $pos || "]/" || functx:substring-after-last($XPath, '/')  )))
                                                else "" :)
                let $elementTextNodeValue := $item/text()(: if($elementDataType = "textNodeAndAttribute") then ""||
                                        (data(util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$currentResourceURI ||"']/" || substring-before($XPath, '/@') || "[" || $pos || "]" )))
                                        else() :)

              return
              (
              <div class="xmlElementGroup">

                    <div id="{$elementNickname}_display_{$indexNo}_{$pos}" class="">
                    <!--<div class="xmlElementGroupHeaderInline">
                    <span class="labelForm">{$elementFormLabel} <span class="teiInfo">
                        <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                        </span></span>

                        </div>
                        -->
                        <div id="{$elementNickname}_value_{$indexNo}_{$pos}" class="xmlElementValue">
                        { switch($elementDataType)
                            case "attribute" return $elementAttributeValue
                            case "text" return $elementTextNodeValue
                            case "textNodeAndAttribute"
                            return  
                            <a href="{$elementAttributeValue}" target="_blank" class="urlInxmlElement">{$elementTextNodeValue}</a>
                            default return $elementTextNodeValue 
                            }
                        </div>
                        <button id="edit{$elementNickname}_{$indexNo}_{$pos}" class="btn btn-primary editbutton"
                         onclick="editValue('{$elementNickname}', '{$indexNo}', {$pos})"
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                          editConceptIcon"></i></button>
                        <a class="removeItem" onclick="removeItem(this, '{ $currentResourceURI }', '{ $elementNickname }', '{ $xpathBaseForCardinalityX }', '{ $selectorForCardinalityX }', '{$pos}')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
                    </div>

        <div id="{$elementNickname}_edit_{$indexNo}_{$pos}" class="xmlElementHidden form-group">
        <div class="input-group" >
        <span class="labelForm">{$elementFormLabel} <span class="xmlInfo">
            <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
            </span></span>

                {switch ($type)
                 case "input" return
                    switch ($elementDataType)
                    case "text" return
                    
                    <input id="{$elementNickname}_{$indexNo}_{$pos}" class="form-control" name="{$elementNickname}_{$indexNo}_{$pos}" value="{$elementTextNodeValue}"></input>
                    case "attribute" return
                    <input id="{$elementNickname}_{$indexNo}_{$pos}" class="form-control" name="{$elementNickname}_{$indexNo}_{$pos}" value="{$elementAttributeValue}"></input>
                    
                    
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

                    default return "Error! Check data type."

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
                    case "text" 
                    case "attribute"
                    return
                    <input id="{$elementNickname}_text_{$index}_1" class="form-control elementWithValue" name="{$elementNickname}_{$index}_1" value=""></input>
                    case "textNodeAndAttribute" return
                    <div>
                    <span>Value of <em>Attribute</em> {functx:substring-after-last($XPath, '/')}</span><input id="{$elementNickname}_add_attrib_{$index}_1" class="form-control" name="{$elementNickname}_text_{$index}_1" value=""></input>
                    <span>Value of <em>Node Text</em></span><input id="{$elementNickname}_add_text_{$index}_1" class="form-control" name="{$elementNickname}_add_text_{$index}_1" value=""></input>
                    </div>
                    default return "Error! Check data type." }


                        <button id="addNewItem" class="btn btn-success" onclick='addData(this, "{$currentResourceURI}", "{$elementNickname}_add_{$indexNo}", "{$elementNickname}", "{$XPath}", "{$contentType}", "{$indexNo}", "")'
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$elementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelEdit('{$elementNickname}_add_{$indexNo}', '{$indexNo}', '{$elementValue}', 'thesau', {$valuesTotal +1}) "
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                </div>
            </div>
        )
};


declare function prosopoManager:displayXmlElementWithThesauCardi($elementNickname as xs:string,
             $topConceptId as xs:string,
             $resourceURI as xs:string?,
             $index as xs:integer?,
             $xpath_root as xs:string?) {

        let $currentResourceURI := if($resourceURI != "") then $resourceURI || "#this" else  $prosopoManager:placeURI
        let $indexNo := if($index) then data($index) else "1"
        let $elementNode := $prosopoManager:peopleElements//xmlElement[nm=$elementNickname]
        let $elementIndex := if($index) then ("[" || string($index) || "]" ) else ("")

        let $xpathEnd := if(contains($elementNode//xpath/text(), "/@"))
            then(functx:substring-before-last($elementNode//xpath/text(), '/') || $elementIndex || "/"
            || functx:substring-after-last($elementNode//xpath/text(), '/')
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
                        if (contains($ancestor/xpath/text(), '/@')) then
                            substring-before($ancestor/xpath/text(), '/@')
                            else $ancestor/xpath/text()
                        )
                    || $elementIndex || $xpathEnd
                    else
                        $xpathEnd
     let $xpathBaseForCardinalityX :=
            if (contains($XPath, "/@")) then
            (functx:substring-before-last(functx:substring-before-last($XPath, "/@"), '/'))
            else
                ($XPath)

     let $selectorForCardinalityX :=
            if (contains($XPath, "/@")) then
            (functx:substring-after-last(functx:substring-before-last($XPath, "/@"), "/"))
            else
                (functx:substring-after-last($XPath, "/"))

    let $contentType :=$elementNode/contentType/text()
    let $elementDataType := $elementNode/contentType/text()
    let $elementFormLabel := $elementNode/formLabel[@xml:lang=$prosopoManager:lang]/text()
    let $elementCardinality := $elementNode/cardinality/text()
    let $attributeValueType := $elementNode/attributeValueType/text()

(:    let $Doc := $prosopoManager:place-collection/id($prosopoManager:docId):)

    let $elementValue :=
        if($elementCardinality = "1" ) then (
         util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"
                ||$currentResourceURI ||"']/" || $XPath ))
         else if($elementCardinality = "x" ) then (
         util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$currentResourceURI ||"']/" || $xpathBaseForCardinalityX || "//" || $selectorForCardinalityX ))
         else(util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"||$currentResourceURI ||"']/" || $XPath ))
    let $valuesTotal := count($elementValue)
    let $data2display :=
    if($elementCardinality = "1" ) then (
        data(util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='" || $elementValue || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']"))
        ) else()
    let $inputName := 'selectDropDown' ||$topConceptId

    (:let $itemList :=
        util:eval( "collection('/db/apps/" || $prosopoManager:project || "/data/documents')//id('"||$prosopoManager:docId
                    ||"')/"
                    || functx:substring-before-last($XPath2Ref, '/') || "//tei:category"):)
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
                        if (not(contains($contentType, 'text'))) then (

                            if (not($attributeValueType) or $attributeValueType="uri") then
                                  skosThesau:getLabel($item/string(), $prosopoManager:lang)
(:                                 ||    data(util:eval( "collection('" || $prosopoManager:concept-collection-path ||"')//skos:Concept[@rdf:about='" || $item/string() || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text()")                                 ):)
                           else
                        skosThesau:getLabel($item/string(), $prosopoManager:lang)
                        )
                        else if (($contentType ="text") and ($attributeValueType="xml-value") and (not($item[.='']))) then
                             data(util:eval( "collection('" || $prosopoManager:concept-collection-path ||"')//skos:Concept[skos:prefLabel[@xml:lang='xml']='" || $item/string() || "']//skos:prefLabel[not(ancestor-or-self::skos:exactMatch)][@xml:lang='en']/text()"))
                        else if (contains($contentType, "textNodeAndAttribute")) then  
                                $item/text()
                                            else($elementValue/text() 
(:                                                                || $contentType || "---" || (if ($attributeValueType) then $attributeValueTypeelse ()):)
                                                                )
              return
              (
              <div class="itemInDisplayElement">
                      <div id="{$inputName}_display_{$indexNo}_{$pos}" class="xmlElement">
                      <!--<span class="labelForm">{$elementFormLabel} <span class="teiInfo">
                          <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                          <div id="{$inputName}_value_{$indexNo}_{$pos}"
                          title="{normalize-space($item/text())} = concept {$item/@ref/string()}" class="xmlElementValue">{ $value2Bedisplayed }</div>
                          <button id="edit{$inputName}_{$indexNo}_{$pos}" class="btn btn-primary editbutton"
                           onclick="editValue('{$inputName}', '{$indexNo}', '{$pos}')"
                                  appearance="minimal" type="button"><i class="glyphicon glyphicon-edit
                                            editConceptIcon"></i></button>
                { if($elementCardinality=1)
                    then
                        <a class="resetItem" onclick="resetValue(this, '{$currentResourceURI}',
                                '{$inputName}',
                                '{$inputName}',
                                '{$elementNickname}',
                                '{$XPath}',
                                '{$contentType}',
                                '{$indexNo}',
                                '{$pos}')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
                    else <a class="removeItem" onclick="removeItemFromList('{$currentResourceURI}', '{$elementNickname}', '{functx:substring-before-last($xpathEnd, '/@')}', {$pos}, '{$topConceptId}')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
                }
                
                      </div>
                      <div id="{$inputName}_edit_{$indexNo}_{$pos}" class="xmlElement xmlElementHidden">

                      <!--
                      <span class="labelForm">{$elementFormLabel} <span class="teiInfo">
                          <a title="XML element: {$XPath}"><i class="glyphicon glyphicon glyphicon-info-sign"></i></a>
                          </span></span>
                          -->
                             {skosThesau:dropDownThesau($topConceptId, $prosopoManager:lang, 'noLabel', 'inline', $index, $pos, $attributeValueType)}

                              <button class="btn btn-success"
                              onclick="saveData('{$currentResourceURI}',
                              '{$inputName}',
                              '{$inputName}',
                              '{$elementNickname}',
                              '{$XPath}',
                              '{$contentType}',
                              '{$indexNo}',
                              '{$pos}')"

                                      appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>

                                      <button id="{$elementNickname}CancelEdit_{$indexNo}_{$pos}" class="btn btn-danger"
                              onclick="cancelEdit('{$inputName}', '{$indexNo}', '{functx:trim($elementValue[1]/text())}', 'thesau', '{$pos}') "
                                      appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>

                      </div>

                      </div>

                      )}


                <div id="{$inputName}_add_{$indexNo}" class="xmlElement xmlElementAddItem xmlElementHidden">

                        {skosThesau:dropDownThesau($topConceptId, 'en', 'noLabel', 'inline', $index + 1, (), ())}


                        <button id="addNewItem" class="btn btn-success"
                        onclick='addData(this, "{$currentResourceURI}", "{$inputName}_add_{$indexNo}", 
                                "{$elementNickname}", "{$XPath}", "{$contentType}", "{$indexNo}", "{ $topConceptId }")'
                                appearance="minimal" type="button"><i class="glyphicon glyphicon-ok-circle"></i></button>
                                <button id="{$elementNickname}CancelEdit_{$indexNo}_add" class="btn btn-danger"
                        onclick="cancelEdit('{$inputName}_add_{$indexNo}', '{$indexNo}', '{$elementValue}', 'thesau', {$valuesTotal +1}) "
                                appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-remove-circle"></i></button>
                </div>



        </div>
        )
};




declare function prosopoManager:getPlaceTypeIcon($placeType as xs:string){
            switch($placeType)
            case 'city' return 'C'
            default return "type: " || $placeType
        };


declare function prosopoManager:peripleoWidget($target as xs:string){
    <div>
        <iframe id="{ $target }_peripleoWidget" allowfullscreen="true" height="380" src="" style="display:none;"> </iframe>
        <div id="{ $target }_previewMap" class="hidden"/>
        <div id="{ $target }_placePreviewPanel" class="hidden"/>
    </div>
};
declare function prosopoManager:xmlFileEditor($resourceId as xs:string){
     let $xmlResource := $prosopoManager:project-place-collection/id($resourceId)
    return
    <div>
                <div class="textModifiedAlert" id="fileModifiedAlert">File has been modified</div>
               <button id="saveFileButton" class="saveTextButton btn btn-primary" onclick="saveXmlFile('{$resourceId}', 1)" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
               <div id="xml-editor-file" class="">{serialize($xmlResource, ())}</div>
   </div>
};

declare function prosopoManager:xmlFileEditorWithUri($resourceUri as xs:string){
     let $xmlResource := $prosopoManager:peopleCollection//lawd:person[@rdf:about=$resourceUri]
    return
    <div>
                <div class="textModifiedAlert" id="fileModifiedAlert">File has been modified</div>
               <button id="saveFileButton" class="saveTextButton btn btn-primary" onclick="saveXmlFile('{$resourceUri}', 1)" appearance="minimal" type="button"><i class="glyphicon glyphicon-floppy-save"></i></button>
               { $resourceUri }
               <div id="xml-editor-file" class="">
               {serialize($xmlResource, ())}</div>
   </div>
};

declare function prosopoManager:saveData($data, $project ){


let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)

(:let $doc-collection := collection($config:data-root || "/" || $prosopoManager:project || "/documents"):)

let $contentType := $data//contentType/text()
let $resourceURI := $data//resourceURI/text()
let $uriShort := substring-before($resourceURI, "#this")
let $index := $data//index/text()

let $xpath := replace($data//xpath/text(), 'tei:', '')
let $xpathEnd := if(contains(functx:substring-after-last($xpath, '/'), "/@"))
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

let $endingSelector := if(contains(functx:substring-after-last($xpath, '/'), "@"))
            then(
                functx:substring-after-last($xpath, '/@')
                )
            else
            (
            )

(:let $resourceId := request:get-parameter('docid', ()):)
(:let $teiDoc := $prosopoManager:doc-collection/id($resourceId):)
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
        if(contains(functx:substring-after-last($xpath, '/'), "@")) then(
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

let $originalXMLNode :=util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"
             ||$resourceURI ||"']" || $xpathWithPrefix)

(:let $originalXMLNode :=util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//.[@rdf:about='"
             ||$resourceURI ||"']" || substring-before($xpathWithPrefix, '/@'))
:)
let $oldValueTxt := data($originalXMLNode)

let $originalXMLNodeWithoutAttribute :=
            if(contains($xpathWithPrefix, '/@')) then util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"
             ||$resourceURI ||"']/" || functx:substring-before-last($xpathWithPrefix, '/') )
             else (util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"
             ||$resourceURI ||"']" || $xpathWithPrefix ))


let $elementNickname := $data//elementNickname/text()


let $upateData :=
        switch ($contentType)

         case "textNodeAndAttribute" return
                (
(:                Check if node exists in resource:)
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
         (:prosopoManager:logEvent("logs-debug", "test", $resourceURI, (), "avant: $originalXMLNodeWithoutAttribute/text(): " || serialize($originalXMLNodeWithoutAttribute, ())),
         :)
         (
                
                if ($updatedData = " ") then update value $originalXMLNodeWithoutAttribute/text() with data($updatedData)
                
                else update value $originalXMLNodeWithoutAttribute with data($updatedData/text())
                )
         )
(:                        update replace $originalXMLNode with functx:change-element-ns-deep($newElement, "http://www.tei-c.org/ns/1.0", "")/node():)
         case "nodes" return
                update value $originalXMLNode with $updatedData/node()
         default return

                update replace $originalXMLNode with functx:change-element-ns-deep($newElement, "http://www.tei-c.org/ns/1.0", "")
(:            update replace $originalXMLNode/node() with $updatedData/node():)

let $newContent := util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"
             ||$resourceURI ||"']" )

(:let $log := prosopoManager:logEvent("all-logs", "test-before-new-Element", $resourceId, (), <data>

</data>):)
let $updatedElement := prosopoManager:displayElement($elementNickname, xmldb:decode-uri($uriShort ), (), ())


let $log := prosopoManager:logEvent("all-logs", "people-update" ||$index, $resourceURI,
    (), "Change in " || $resourceURI ||
    "$elementNickname" || $elementNickname ||
    "New element: " || serialize($newElement, ()) ||
    "$updatedElement: " || serialize($updatedElement)
    || "div id: " || $elementNickname || "_group_" || $index
    )



    return

    <data>
    <oldContent>{ $oldValueTxt }</oldContent>
    <newContent>{ $newContent }</newContent>
    <updatedElement>{ $updatedElement }</updatedElement>
    <elementIdToReplace>{$elementNickname}_group_{ $index }</elementIdToReplace>

</data>

};

declare function prosopoManager:saveTextarea($data, $project){
let $now := fn:current-dateTime()
let $currentUser := sm:id()//sm:real/sm:username

let $currentUserUri := concat($teiEditor:baseUri[1], '/people/' , $currentUser)

let $resourceUriLong := $data//resourceUri/text()
let $resourceUri :=  substring-before($resourceUriLong , "#this")
let $resourceDoc := util:eval( "$prosopoManager:peopleCollection//lawd:person[@rdf:about='"||$resourceUriLong ||"']")

let $elementNickname :=
            $data//elementNickName/text()
let $elementNode :=if (not(exists($prosopoManager:peopleElementsCustom//xmlElement[nm=$elementNickname]))) 
                                        then $prosopoManager:peopleElements//xmlElement[nm=$elementNickname] 
                                        else $prosopoManager:peopleElementsCustom//xmlElement[nm=$elementNickname]

let $xpath :=  $data//xpath/text()
let $index := data($data//index)


let $newText := $data//newText 
(:functx:change-element-ns-deep(<ab>{$data//newText/node()}</ab>, 'http://www.tei-c.org/ns/1.0', ''):)



let $originalNodeWithoutAttribute := 
            if(contains($xpath, '/@')) then util:eval( "collection('" || $prosopoManager:peopleCollectionPath ||"')//lawd:person[@rdf:about = '"
             || $resourceUriLong ||"']/" || functx:substring-before-last($xpath, '/') )
             else (util:eval( "collection('" ||$prosopoManager:peopleCollectionPath ||"')//lawd:person[@rdf:about='"
             ||$resourceUriLong ||"']" || $xpath ))

let $updateXml := if($newText = " " or $newText = "" ) then
                update value
                    $originalNodeWithoutAttribute/text() with $newText
                    else  if ($newText/*[local-name()='p']) then
                    update value $originalNodeWithoutAttribute 
                    with functx:change-element-ns-deep($newText/*[local-name()='p']/node(), "", "")
                    else update value $originalNodeWithoutAttribute 
                    with functx:change-element-ns-deep($newText/node(), "", "")
let $log := teiEditor:logEvent("document-update-" ||$index, $resourceUri, $data, $xpath )

let $newContent := util:eval( "$prosopoManager:peopleCollection//lawd:person[@rdf:about='"||$resourceUriLong ||"']")
return

<data>{$data}
<newContent>{ $newContent}</newContent>
</data>


};




declare function prosopoManager:removeItem($data as node(), $project as xs:string){
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    
    let $xpathBase:= $data//xpathBase/text()
    let $xpathSelector:= $data//xpathSelector/text()
    let $elementNickname := $data//elementNickname/text()
    let $index := "[" || $data//index/text() || "]"
    let $resourceUri := $data//resourceURI/text()
    let $resourceUriShort:=substring-before($resourceUri, "#this")
    let $nodeToRemove :=
    
            update delete util:eval( "collection('"
                                        || $prosopoManager:peopleCollectionPath
                                        ||"')//lawd:person[@rdf:about='"|| $resourceUri ||"']/"
                                        || $xpathBase || "/" || $xpathSelector || $index)
    let $updatedElement := 
            switch ($elementNickname)
            case 'hasFunction' return prosopoManager:hasFunction($resourceUri) 
            
            default return prosopoManager:displayElement($elementNickname, xmldb:decode-uri($resourceUriShort), (), ())
 return 
            <data>
            <updatedResource>{prosopoManager:getPeopleHTML($resourceUri) }</updatedResource>
            <updatedElement>{ $updatedElement }</updatedElement>
            </data>
            
            

};

declare function prosopoManager:removeBond($data as node(), $project as xs:string){
    
    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
     
return
<updatedResource></updatedResource>
};


declare function prosopoManager:saveXmlFile($data, $project ){


let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)

let $resourceURI := $data//resourceURI/text()
let $newContent := <rdf:RDF xmlns:lawd="http://lawd.info/ontology/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">{$data//newContent/node()}</rdf:RDF>
    
 let $newLawdPerson:= $newContent//lawd:person
 
 let $updateNewData :=(
             update replace
                     util:eval( "collection('" || $prosopoManager:project-people-collection-path
                     || "')//lawd:person[matches(./@rdf:about, '"
                  ||$resourceURI ||"')]") with $newLawdPerson
                 
                  )
                  



let $updatedFile := prosopoManager:getPeopleHTML($resourceURI)


    
    



    return

    <data>{$data}
    <updatedFile>{ $updatedFile }</updatedFile>
    
</data>

};

declare function prosopoManager:logEvent($logType as xs:string,
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


declare function prosopoManager:listPossibleFeatures($resourceId as xs:string){
let $mainTypeFeature := util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')/id('"|| $resourceId ||"')//pleiades:hasFeatureType[@type='main']")
let $subTypeFeatures := <subTypeFeatures>{ util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')/id('"|| $resourceId ||"')//pleiades:hasFeatureType[@type='sub']") }</subTypeFeatures>

return
<div class="xmlElementGroup">
    <div id="subTypeFeatures_display" class="">
         <div class="xmlElementGroupHeaderInline">
              <span class="labelForm">Present features<span class="teiInfo">
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
                        <span class="bibRef">{$prefLabel}
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

declare function prosopoManager:listConceptAsCheckboxes($concepts as node(), $lang as xs:string){

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


declare function prosopoManager:biblioManager($resourceId as xs:string?){
let $resource := util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//id('" || $resourceId ||"')" )
(:   let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

   return
   <div class="xmlElementGroup">

   <div class="xmlElementGroupHeaderBlock">
   <span class="labelForm">Main Bibliography</span>
   <button id="docBilioAddItem" class="btn btn-primary addItem" onclick="openBiblioDialog()" appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>


   </div>
      <div id="mainBiblioList" class="itemList">
   {for $bibRef at $pos in $resource//tei:text/tei:body/tei:div[@type='bibliography'][@subtype='edition']/tei:listBibl//tei:bibl
   order by $bibRef//tei:ptr/@target
    return
    teiEditor:displayBibRef($resourceId, $bibRef, "edition", $pos)
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
                                <label for="nameLookupInputModal">Search in <a href="https://www.zotero.org/groups/{$prosopoManager:appVariables//zoteroGroup/text()}" target="_blank">Zotero Group {$teiEditor:appVariables//zoteroGroup/text()}</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupInputModal" name="zoteroLookupInputModal" 
                                placeholder="Start to enter a author name or a word..."/>
                            </div>
                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange" name="citedRange"
                                data-error="Please enter your full name."/>

                            </div>
                            <div id="zoteroGroupNo" class="">{$prosopoManager:appVariables//zoteroGroup/text()}</div>
                            <div id="selectedResourceAuthor"/>
                            <div id="selectedResourceDate"/>
                            <div id="selectedResourceTitle"/>
                            <div id="selectedResourceUri"/>
                            <div id="selectedResourceId" />


                    <div class="form-group modal-footer">


                        <button  class="pull-left" type="submit" onclick="addResourceToPerson('{$prosopoManager:appVariables//zoteroGroup/text()}', 'seeFurther')">Add reference</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  </form>
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    </div>

   </div>

};

declare function prosopoManager:addResourceDialog($type as xs:string){

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
                                <label for="nameLookupInputModal">Search in <a href="https://www.zotero.org/groups/{$prosopoManager:appVariables//zoteroGroup/text()}" target="_blank">Zotero Group {$teiEditor:appVariables//zoteroGroup/text()}</a>
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
                            <div id="zoteroGroupNo" class="hidden">{$prosopoManager:appVariables//zoteroGroup/text()}</div>
                            <div id="selectedResourceAuthor" class="valueField"/>
                            <div id="selectedResourceDate" class="valueField"/>
                            <div id="selectedResourceTitle" class="valueField"/>
                            <div id="selectedResourceUri" class="valueField"/>
                            <div id="selectedResourceId" class="valueField"/>
                        <div class="modal-footer">


                        <button  class="pull-left" type="submit" onclick="addResourceToPerson('{$prosopoManager:appVariables//zoteroGroup/text()}', '{$type}')">Add reference</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  </form>
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    </div>

   };

declare function prosopoManager:resourcesManager($type as xs:string, $personUri as xs:string){
let $personUri := if(contains($personUri, "#this")) then $personUri else $personUri || "#this"
let $personRdf :=  $prosopoManager:peopleCollection//lawd:person[@rdf:about= $personUri]
let $refs := ($personRdf//cito:citesForInformation)
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
            prosopoManager:displayResource($personUri, $resource, $type, $pos)
(:    teiEditor:displayBibRef($resourceId, $bibRef):)
(:    teiEditor:displayBibRef($teiEditor:docId, substring(data($bibRef/tei:ptr/@target), 2)):)
   }
   </div>
   </div>


    

};

declare function prosopoManager:displayResourceList($type as xs:string, $placeId as xs:string){


let $place:= util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//id('" || $placeId ||"')" )
(:   let $teiDoc := $teiEditor:doc-collection/id($teiEditor:docId):)

   return
   <div class="xmlElementGroup">

   <div class="xmlElementGroupHeaderBlock">
   <span class="labelForm">{$type}</span>
   <button id="{$type}AddItem" class="btn btn-primary addItem" onclick="openDialog('dialogInsertResource{$type}')" appearance="minimal" type="button"><i class="glyphicon glyphicon glyphicon-plus"></i></button>


   </div>
      <div id="{ $type }List" class="resourceList">
   {for $resource in $place//ausohnum:hasResource[@type=$type]

    return
        "Not to be used"
(:            prosopoManager:displayResource($placeId, data($resource/@rdf:resource)):)
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
                                <label for="nameLookupInputModal">Search in <a href="https://www.zotero.org/groups/{$prosopoManager:appVariables//zoteroGroup/text()}" target="_blank">Zotero Group {$teiEditor:appVariables//zoteroGroup/text()}</a>
                                </label>
                                <input type="text" class="form-control zoteroLookup" id="zoteroLookupInputModal" name="zoteroLookupInputModal" placeholder="Start to enter a author name or a word..."/>
                            </div>
                            <div class="form-group">
                                <label for="citedRange">Cited Range
                                </label>
                                <input type="text" class="form-control" id="citedRange" name="citedRange"
                                data-error="Please enter your full name."/>
                        </div>
                            <div id="zoteroGroupNo" class="">{$prosopoManager:appVariables//zoteroGroup/text()}</div>
                            <div id="selectedResourceAuthor"/>
                            <div id="selectedResourceDate"/>
                            <div id="selectedResourceTitle"/>
                            <div id="selectedResourceUri"/>
                            <div id="selectedResourceId" />
                        <div class="modal-footer">


                        <button  class="pull-left" type="submit" onclick="addResourceRef('{$placeId}', '{$prosopoManager:appVariables//zoteroGroup/text()}', '{$type}')">Add reference</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  </div>
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    </div>

   </div>

};


(:declare function prosopoManager:displayResource( $docUri as xs:string, $resourceUri as xs:string, $type as xs:string, $index as xs:int){
        let $resource := 
                switch($type)
                case "illustration" return $prosopoManager:resourceRepo//ausohnum:resource[@rdf:about=$resourceUri]
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
                if($resource[1]//tei:author[1]/tei:surname) then data($resource[1]//tei:author[1]/tei:surname)
                else if ($resource[1]//tei:editor[1]/tei:surname) then $resource[1]//tei:editor[1]/tei:surname
                else ("[no name]")
                }</span>
        let $date := data($resource[1]//tei:imprint/tei:date)
        let $citedRange :=if($resource//tei:citedRange and $resource//tei:citedRange != "") then
                                                    if (starts-with(data($resource[1]//tei:citedRange), ',')) 
                                                    then data($resource[1]//tei:citedRange)
                                                    else (', ' || data($resource[1]//tei:citedRange))
                                    else if($resource//prism:pageRange) then $resource//prism:pageRange
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
         <a class="removeItem" onclick="removeResourceFromList('{$docUri}', '{ $type }', '/lawd:person', '{$xpath}', '{ $index }')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a></span>
             default return null
        }</div>
};:)

declare function prosopoManager:displayResource( $docUri as xs:string, $resourceNode as node(), $type as xs:string, $index as xs:int){
        let $resourceUri := data($resourceNode/@rdf:resource)
        let $resource := 
                switch($type)
                case "illustration" return $prosopoManager:resourceRepo//ausohnum:resource[@rdf:about=$resourceUri]
                case "seeFurther" return $teiEditor:biblioRepo//tei:biblStruct[equals(./@corresp, $resourceUri)]
                default return $teiEditor:biblioRepo//tei:biblStruct[equals(./@corresp, $resourceUri)]
        let $xpath := switch ($type)
           case "seeFurther" return "/cito:citesForInformation"
           case "illustration" return
                    '/ausohnum:hasResource[@type="illustration"]'
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
        <a class="removeItem" onclick="removeResourceFromList('{$docUri}', '{ $type }', '/lawd:person', '{$xpath}', '{ $index }')"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a></span>
             default return null
        }</div>
};


declare function prosopoManager:hasBond($uri as xs:string){
        let $uriShort :=substring-before($uri, "#this")
        
        let $resourcePerson := $prosopoManager:peopleCollection//lawd:person[@rdf:about=$uri]
(:        let $resourcePerson := util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[matches(./@rdf:about, '" || $uri || "')]"):)


        
        return
        <div id="bondList" class="xmlElementGroup">
                         <h4 class="subSectionTitle">Bonds
                         <button id="addSubPlace" class="btn btn-primary addItem pull-right"
                     onclick="openDialog('dialogAddBond')" appearance="minimal" type="button">
                     <i class="glyphicon glyphicon glyphicon-plus"></i></button></h4>

                         <div id="listOfBonds">
                         <ul class="">{
        for $bond in $resourcePerson//snap:hasBond
                let $bondUri := data($bond/@rdf:resource)
                let $bondType := data($bond/@rdf:type)
                let $bondRecord := $prosopoManager:peopleCollection//lawd:person[@rdf:about=$bondUri[1] || "#this"]
                let $bondName := $bondRecord//lawd:personalName/text()
               return
               <li class="xmlElementItem"><a onclick="displayPerson({ substring-after($bondUri[1], "/people/") })" title="Open this person in same window" >{$bondName}</a>
                                                <a href="{ $bondUri }" target="_self">
                                                                <i class="glyphicon glyphicon-new-window"/></a>
                                                                <span class="">[{ $bondType}]<button class="removeItem btn btn-xs btn-warning"
                                          onclick="removeRelationship(this, '{$uriShort}', '{$bondUri}', '{$bondType}')"><i class="glyphicon glyphicon-trash" title="Remove relationship"/></button></span>
                                                                
                                                                </li>
               }
               </ul>
               </div>
               </div>
               
};

declare function prosopoManager:hasFunctionList($uri as xs:string){
        let $resourcePerson := $prosopoManager:peopleCollection//lawd:person[@rdf:about = $uri]
        let $functionList := skosThesau:getChildren("https://ausohnum.huma-num.fr/concept/c22265", $prosopoManager:project)
        
        return
        <functions>{
            for $function at $pos in $resourcePerson//apc:hasFunction
                
                let $functionUri := data($function/@rdf:resource)
                let $functionType := data($function/@rdf:type)
                let $functionTargetUri := data($function/@target)
                let $functionName:= $functionList//skos:Concept[./@rdf:about =$functionUri]//skos:prefLabel[@xml:lang=$prosopoManager:lang]
                let $functionName:= skosThesau:getLabel($functionUri[1], '')
                let $targetLabel :=  if(contains($functionTargetUri, 'places')) then 
                                                     if($prosopoManager:project-place-collection//pleiades:Place[@rdf:about=$functionTargetUri]) then $prosopoManager:project-place-collection//pleiades:Place[@rdf:about=$functionTargetUri]//dcterms:title/text()
                                                     else "⚠ No record for " || $functionTargetUri
                                               else if(contains($functionTargetUri, 'concept'))  then skosThesau:getLabel($functionTargetUri, '')
                                               else "⚠ error"
               return
                 <function uri="{ $functionUri }" targetUri="{ $functionTargetUri }"
                 targetLabel="{if($functionTargetUri) then ($targetLabel ) else () }">{ $functionName }
                 </function>
    }
    </functions>
               
};

declare function prosopoManager:hasFunction($uri as xs:string){
        let $resourcePerson := $prosopoManager:peopleCollection//lawd:person[matches(./@rdf:about, $uri)]
        let $functionList := skosThesau:getChildren("https://ausohnum.huma-num.fr/concept/c22265", $prosopoManager:project)
        
        return
        <div id="functionList" class="xmlElementGroup">
                         <h4 class="subSectionTitle">Functions<button id="openAddFunction" class="btn btn-primary addItem pull-right"
                     onclick="openDialog('dialogAddFunction')" appearance="minimal" type="button">
                     <i class="glyphicon glyphicon glyphicon-plus"></i></button>

                         </h4>
                         <div id="listOfFunctions">
                         <ul class="list-group">{
        for $function at $pos in $resourcePerson//apc:hasFunction
                let $functionUri := data($function/@rdf:resource)
                let $functionType := data($function/@rdf:type)
                let $functionTargetUri := data($function/@target)
                let $functionName:= $functionList//skos:Concept[./@rdf:about =$functionUri]//skos:prefLabel[@xml:lang=$prosopoManager:lang]
                let $functionName:= skosThesau:getLabel($functionUri[1], '')
                let $targetLabel :=  if(contains($functionTargetUri, 'places')) then 
                                                     if($prosopoManager:project-place-collection//pleiades:Place[@rdf:about=$functionTargetUri]) then $prosopoManager:project-place-collection//pleiades:Place[@rdf:about=$functionTargetUri]//dcterms:title/text()
                                                     else "⚠ No record for " || $functionTargetUri
                                               else if(contains($functionTargetUri, 'concept'))  then skosThesau:getLabel($functionTargetUri, '')
                                               else "⚠ error"
                    
(:                let $functionName := skosThesau:getLabelFromXmlValue($functionType, 'en')[1]:)
               return
                 <li class="list-group-item xmlElementGroupItem">
                      <span>
                        { if($pos >1) then 
                            <button class="btn btn-xs btn-primary" onclick="functionMove({$pos}, 'up')"><i class="glyphicon glyphicon-arrow-up"/></button>
                            else ()}
                       { if($pos < count($resourcePerson//apc:hasFunction)) then 
                            <button class="btn btn-xs btn-primary" onclick="functionMove({$pos}, 'down')"><i class="glyphicon glyphicon-arrow-down"/></button>
                                          
                    else()}
                      </span>
               <a href="{ $functionUri }" title="Open this document in same window" target="_self">{$functionName}</a>
               {if($functionTargetUri) then (
                                    <span>[<a href="{ $functionTargetUri }" target="_blank">{ $targetLabel }</a>]</span>)
                                                else ""}
               <a class="removeItem pull-right" onclick="removeItem(this, '{$uri}', 'hasFunction', '/foaf:primaryTopicOf/apc:people', 'apc:hasFunction', { $pos })"><i class="glyphicon glyphicon-trash" title="Remove reference from list"/></a>
                                 
                                                
                </li>
               }
               </ul>
               
               </div>
               </div>
               
};

declare function prosopoManager:relatedDocuments($uri as xs:string){
        let $uriShort := if(contains($uri, "#this")) then substring-before($uri, "#this") else $uri
        (: let $resourcePerson := $prosopoManager:peopleCollection//lawd:person[@rdf:about=$uri] :)
        let $docs := $prosopoManager:doc-collection//tei:TEI[descendant-or-self::tei:listPerson//tei:person[@corresp=$uriShort]]
        return $docs
};
declare function prosopoManager:relatedPlaces($uri as xs:string){
        let $resourcePerson := $prosopoManager:peopleCollection//lawd:person[@rdf:about=$uri]
        let $relatedDocs := prosopoManager:relatedDocuments($uri)
        let $relatedPlaces := $relatedDocs//tei:sourceDesc/tei:listPlace//tei:place
        
        let $uniquePlacesUris := 
                for $place in $relatedPlaces
                        let $splitRef := tokenize(data($place/tei:placeName/@ref), " ")
                        let $placeUri := (
                                                 for $uri in $splitRef
                                                     return
                                                           if(contains($uri, $teiEditor:baseUri)) then 
                                                                             normalize-space($uri[1]) else ()
                                                )                      
                        return
                        $placeUri
                        
       let $uniquePlaces2 :=   <places>
            {for $place in distinct-values($uniquePlacesUris)
                return
                <placeName ref="{$place}"/>
                
                }</places>
         (:let $uniquePlace := for $place in functx:distinct-nodes($uniquePlacesUri)
                    return <placeName ref="{ $placeUri }"></placeName>:)
        return
        <div id="placesLists" class="xmlElementGroup">
                         <h4 class="subSectionTitle">Places linked to this person</h4>
                         <div id="listOfPlaces">
                         <ul class="listNoBullet">{
                         
        for $place in $uniquePlaces2//placeName
                      
                       let $placeRecord := $prosopoManager:place-collection//spatial:Feature[@rdf:about=$place/@ref || "#this"][1]
                       let $placeName := $placeRecord[1]//foaf:primaryTopicOf/pleiades:Place/dcterms:title
                       (:let $placevicinityof := if($placeRecord//spatial:C[@type="invicinityOf"]) then
                                      let $nearbyPlaceRecord := $prosopoManager:place-collection//spatial:Feature[@rdf:about=$placeRecord//spatial:C[@type="invicinityOf"]/@rdf:resource || "#this"][1]
                                      return
                                  <span> [near <a href="{ data($nearbyPlaceRecord//foaf:primaryTopicOf/pleiades:Place/@rdf:about) }">{$nearbyPlaceRecord//foaf:primaryTopicOf/pleiades:Place/dcterms:title}</a><a href="{ $placeUri }" target="_blank">
                                                                      <i class="glyphicon glyphicon-new-window"/></a>]</span>
                                  else ():)
              order by $placeName
              return
               
               <li><a href="{ $place/@ref }" title="Open this document in same window" target="_self">{ $placeName }</a>
                                                <a href="{ $place/@ref }" target="_blank">
                                                                <i class="glyphicon glyphicon-new-window"/></a>
                                                                
                                                                </li>
               }
               </ul>
               </div>
               </div>
               
};

declare function prosopoManager:relatedPlacesList($uri as xs:string){
        let $resourcePerson := $prosopoManager:peopleCollection//lawd:person[@rdf:about=$uri]
        let $relatedDocs := prosopoManager:relatedDocuments($uri)
        let $relatedPlaces := $relatedDocs//tei:sourceDesc/tei:listPlace//tei:place
        
        let $uniquePlacesUris := 
                for $place in $relatedPlaces
                        let $splitRef := tokenize(data($place/tei:placeName/@ref), " ")
                        let $placeUri := (
                                                 for $uri in $splitRef
                                                     return
                                                           if(contains($uri, $teiEditor:baseUri)) then 
                                                                             normalize-space($uri[1]) else ()
                                                )                      
                        return
                        $placeUri
                        
       let $uniquePlaces2 :=   <places>
            {for $place in distinct-values($uniquePlacesUris)
                return
                <placeName ref="{$place}"/>
                
                }</places>
         (:let $uniquePlace := for $place in functx:distinct-nodes($uniquePlacesUri)
                    return <placeName ref="{ $placeUri }"></placeName>:)
        return
        <places id="relatedPlacesLists">{
            for $place in $uniquePlaces2//placeName
                      
                       let $placeRecord := $prosopoManager:place-collection//spatial:Feature[@rdf:about=$place/@ref || "#this"][1]
                       let $placeName := $placeRecord[1]//foaf:primaryTopicOf/pleiades:Place/dcterms:title/text()
              order by $placeName
              return
                <place uri="{ $place/@ref }">{ $placeName }</place>
               }</places>
};


declare function prosopoManager:relatedPeopleList($uri as xs:string){
        let $uri := if(not(contains($uri, "#this"))) then concat($uri, "#this") else $uri
        let $uriShort :=substring-before($uri, "#this")
        
        let $resourcePerson := $prosopoManager:peopleCollection//lawd:person[@rdf:about=$uri]
        let $hasBond := $resourcePerson//snap:hasBond
        return
        <people>
            {
                    for $bond in $hasBond
                        let $bondUri := data($bond/@rdf:resource)
                        let $bondType := data($bond/@rdf:type)
                        let $bondRecord := $prosopoManager:peopleCollection//lawd:person[@rdf:about=$bondUri[1] || "#this"]
                         let $bondName := $bondRecord//lawd:personalName/text()
                         return
                         <bond uri="{ $bondUri }" bondType="{ $bondType }">{ $bondName }</bond> 
             }
        </people>
};
declare function prosopoManager:addResourceToPerson( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    (:let $data := request:get-data():)
(:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)
       
    let $personUri := $data//personUri/text()
    (:let $docId := request:get-parameter('docid', ()):)
    let $xmlDoc :=util:eval( "$prosopoManager:peopleCollection//lawd:person[@rdf:about = '"||$personUri ||"#this']") 
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
       case "seeFurther" return "//cito:citesForInformation"
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

       
       (:insert new reference in main bibliography:)
    let $insertBiblioInBiblioRepo :=
        if ($teiEditor:biblioRepo//tei:biblStruct[@corresp = $zoteroResourceCorresp]) then (
                    update replace $teiEditor:biblioRepo//tei:biblStruct[@corresp = $zoteroResourceCorresp] with $zoteroResource//tei:biblStruct)
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
                     let $node := <node><cito:citesForInformation rdf:resource="{$zoteroResourceCorresp}" >{
                     if ($citedRange!= "") then <prism:pageRange>{ $citedRange }</prism:pageRange> else()}
                       </cito:citesForInformation>
                     </node>
                  return update insert $node/node() into
                                            $xmlDoc
           default return "ERROR!"



    let $logInjection :=
        update insert
        <apc:log type="person-update-add-biblio" when="{$now}" what="{data($data/xml/docId)}" who="{$currentUser}">
            {$data}
            <docId>{$personUri}</docId>
            <xmlDoc>{ "xmlDoc: " || serialize($xmlDoc) }</xmlDoc>
            <!--<lastNode>{$lastNode}</lastNode>
            -->
            <origNode2>$originalTEINode</origNode2>
            <bibType>{$typeRef}</bibType>

            <teiBibRef>{$prosopoManager:zoteroGroup} - {$zoteroResource}</teiBibRef>
        </apc:log>
        into $teiEditor:logs/id('all-logs')

    (:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return
        if ($refAlreadyPresent = true())
        then <data><status>errorAlready</status>Resource already present</data>
else
        <data>
        <status>ok</status>
       <newContent>{ prosopoManager:resourcesManager($typeRef, $personUri) }</newContent>
        </data>
};

declare function prosopoManager:removeResourceFromList($data as node(), $project as xs:string){
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
                                        || $prosopoManager:project-people-collection-path
                                        ||"')//lawd:person[@rdf:about='"|| $resourceUri ||"']"
                                        || "/" || $xpathSelector || $index)
    let $updatedElement := prosopoManager:resourcesManager($type, xmldb:decode-uri($resourceUri))
 return 
            <data>
            <updatedPlace>{prosopoManager:getPeopleHTML2($resourceUri)}</updatedPlace>
            <updatedElement>{ $updatedElement }</updatedElement>
            </data>
            
            

};
declare function prosopoManager:addResource( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    (:let $data := request:get-data():)
(:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

    let $docId := $data//docId/text()
    (:let $docId := request:get-parameter('docid', ()):)
    let $xmlDoc := $prosopoManager:place-collection/id($docId)

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
    let $rdfAboutForResource := $prosopoManager:appVariables//uriBase[@type="app"]/text() || "/resources/" || $resourceRef

     let $zoteroItemRdfAbout := data($zoteroResource//z:UserItem/@rdf:about)

     let $resourceId := functx:substring-after-last($zoteroItemRdfAbout, '/')

    let $resourceIdRef := concat("#", $resourceId)
    let $insertLocationElementInDoc :=         util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')/id('"
                || $docId ||"')" || '/spatial:Feature/foaf:primaryTopicOf/pleiades:Place'  )

let $refAlreadyPresent := exists($xmlDoc//ausohnum:hasResource[@rdf:resource=  $rdfAboutForResource])

let $testlog := prosopoManager:logEvent("logs-debug", "test-before-adding-resource", $docId, (),
                        "$prosopoManager:resourceRepo//.[@xml:id=$typeRef]: " || $prosopoManager:resourceRepo//.[@xml:id=$typeRef]
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
        if ($prosopoManager:resourceRepo//z:UserItem[@rdf:about= $rdfAboutForResource]) then ()
        else(
                   update insert $ausohnumResource/node() into $prosopoManager:resourceRepo//.[@xml:id=$typeRef]
            )

let $updateResourceRDFAbout := update replace $prosopoManager:resourceRepo//z:UserItem/@rdf:about with $rdfAboutForResource
(:let $updateResourceSameAs:= update insert <owl:sameAs rdf:resource="{$zoteroItemRdfAbout}"/> into $prosopoManager:resourceRepo//z:UserItem[@rdf:about = $rdfAboutForResource]:)


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

let $newContent := util:eval( "collection('" || $prosopoManager:doc-collection-path || "')/id('"
             ||$docId ||"')" )

let $newBiblList :=  <div>
        {for $bibRef at $pos in  util:eval( "collection('" || $prosopoManager:doc-collection-path || "')/id('"
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

            <teiBibRef>{$prosopoManager:zoteroGroup} - {$zoteroResource}</teiBibRef>
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
declare function prosopoManager:changePlaceToNearTo( $data as node(), $project as xs:string){

                            let $now := fn:current-dateTime()
                            let $currentUser := data(sm:id()//sm:username)

                            (:let $data := request:get-data():)
                        (:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

                            let $resourceUri := $data//resourceUri/text()
                            (:let $docId := request:get-parameter('docid', ()):)
                            let $xmlDoc := $prosopoManager:place-collection/.[@rdf:about = $resourceUri]

                            let $xmlResource :=         util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//spatial:Feature[@rdf:about='"
                || $resourceUri ||"']"  )

                            let $placeUri := substring-before($data//placeUri/text(), '#')
                            let $NearToNode := <node>
<spatial:C type="invicinityOf" rdf:resource="{ $placeUri }"/></node>

                            (:insert new reference in main bibliography:)
                            let $addPlaceAsNearTo :=
                                if($xmlResource//spatial:P) then
                                update insert $NearToNode/node() following $xmlResource//spatial:P[last()]
                                else update insert $NearToNode/node() preceding $xmlResource//foaf:primaryTopicOf

                        let $deleteFormerSpatialP := update delete $xmlResource/spatial:P[@rdf:resource=$placeUri]

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
                                <newContent>{ prosopoManager:getPeopleHTML($resourceUri )}</newContent>
                               </data>
};

declare function prosopoManager:addData( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)

    (:let $data := request:get-data():)
(:    let $doc-collection := collection($config:data-root || $teiEditor:project || "/documents"):)

    let $personUri := $data//personUri/text()
    let $topConceptId := $data//topConceptId/text()
    let $xpath := replace($data//xpath/text(), 'tei:', '')
    let $lang := $data//lang/text()

    (:let $docId := request:get-parameter('docid', ()):)
    let $person := $prosopoManager:project-place-collection//apc:people[@rdf:about=$personUri]
(:     let $xpathEnd := if(contains(functx:substring-after-last($xpath, '/'), "@")) :)
    let $xpathEnd := if(contains($xpath, "/@"))

            then(
                functx:substring-after-last(functx:substring-before-last($xpath, '/'), '/')
                )
            else
            (functx:substring-after-last($xpath, '/')
            )
(:     let $endingSelector := if(contains(functx:substring-after-last($xpath, '/'), "@")) :)
    let $endingSelector := if(contains($xpath,"/@"))
            then(
                functx:substring-after-last($xpath, '/@')
                )
            else
            (
            )
    let $xpathInsertLocation :=
(:                 if(contains(functx:substring-after-last($data//xpath/text(), '/'), "@")) :)
                if(contains($data//xpath/text(), '/@'))

(:                 if xpath is ending with \@, this must be removed:)
                then(
                      if(util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//apc:people[@rdf:about='"
                             || $personUri ||"']" || $data//xpath/text()) )
(:                             If there is already one node with same xpath, then location is last:)
                             then (
                               functx:substring-before-last($data//xpath/text(), '/') || '[last()]'
                                )
                          else(functx:substring-before-last(substring-before($data//xpath/text(), '/@'), '/'))
                        )
                else
                    (
                    (: $data//xpath/text() :)
                   functx:substring-before-last($data//xpath/text(), '/')
                    )
 
  let $xpathLastNode :=functx:substring-before-if-contains($xpathEnd, "[")
 
  let $insertLocationElement :=
    (: If same element exists, then location is the last existing element, otherwise location is parent node :)
    if(exists(util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"
           || $personUri ||"#this']" || $data//xpath/text()) ))
           then (
             util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"
           || $personUri ||"#this']" || $xpathInsertLocation || "/" || $xpathLastNode || "[last()]")
         )
         else(

                util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"
           || $personUri ||"#this']" ||

                $xpathInsertLocation || "[1]"
              ))

  
    let $attribs:=tokenize($xpathEnd, "\[@")[position()>1]
    let $quote:=if(contains($xpathEnd, "'")) then "'" else '"'

    let $newElement :=
(:     
      if(contains(functx:substring-after-last($xpath, '/'), "@"))
              then(<newElement>
                      {element {string($xpathEnd)}
                      {attribute {string($endingSelector)} {$data//value },
                                 if($lang and $lang!= "undefined") then attribute xml:lang {$lang} else (),
                       functx:trim($data//valueTxt/text())


          }}</newElement>
          )
        else :)
        (<newElement>
        {
          
          element {string($xpathLastNode)}
               { for $attrib in $attribs
                        let $att:=substring-before($attrib, "=")
                        let $val:= substring-before(substring-after($attrib, $quote), $quote)
                        return 
                           if($att="xml:lang" and $lang!='')then (attribute { $att } { $lang })
                           else
                          attribute { $att } { $val }
                ,
                if($endingSelector !="") then
                    attribute { $endingSelector } { functx:trim($data//value/text())}
                else(),

                    if($data//valueTxt!="undefined")
                        then functx:trim($data//valueTxt/text())
                        else ()             
                }
            }</newElement>
        )





      let $insertNewElement :=
            if(util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"
           || $personUri ||"#this']" || $data//xpath/text()) )
                   then (
                     update insert $newElement/node()
                     (: ('&#xD;&#xa;',
                     functx:change-element-ns-deep(
                         $newElement, "", "")/node()) :)
(:                     following $insertLocationElement:)
                     following $insertLocationElement 
                   )
            else(
            update insert $newElement/node() into $insertLocationElement
            )

    let $insertLog :=
      update insert
      <log type="document-add-data" when="{$now}" what="{data($data/xml/docId)}" who="{$currentUser}">aa{$newElement}
      <nm>{$data/xml/xmlElementNickname/text()}</nm>
      <xpath>{$data//xpath/text()}</xpath>
      <inserrtLoc>{$xpathInsertLocation}</inserrtLoc>
      <insertLocFull>{ "collection('" || $prosopoManager:project-people-collection-path ||"')//apc:people[@rdf:about='"
           || $personUri ||"']" ||

                $xpathInsertLocation}</insertLocFull>
      <xpathLastNode>{ $xpathLastNode }</xpathLastNode>
      <exists>{ exists(util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"
           || $personUri ||"#this']" || $data//xpath/text()) ) }</exists>
      </log> into $teiEditor:logs/id('all-logs')


    (:let $updateXml := update value $originalTEINode with $updatedData:)




    (:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return
    <response>
    <log type="document-add-data" when="{$now}" what="{data($data/xml/docId)}" who="{$currentUser}">aa{$newElement}
      <nm>sd{$data/xml/xmlElementNickname/text()}</nm>
      <xpath>{$data//xpath/text()}</xpath>
      <util>{if(util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"
           || $personUri ||"#this']" || $data//xpath/text())) then"eee" else "no"}</util>
      
      <inserrtLoc>{$xpathInsertLocation}</inserrtLoc>
      <insert2>{if(util:eval( "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"
           || $personUri ||"#this']" || $data//xpath/text()) )
           then (
              "collection('" || $prosopoManager:project-people-collection-path ||"')//lawd:person[@rdf:about='"
           || $personUri ||"#this']" || $xpathInsertLocation || "/" || $xpathLastNode || "[last()]"
         )
         else("NOO")}</insert2>
      
                <newElement>{ $newElement }</newElement>
      <insertLocationElement>{ $insertLocationElement }</insertLocationElement>
      </log>
       <newContent xmlns:lawd="http://lawd.info/ontology/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">{util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"|| $personUri || "#this']" )}</newContent>

      <updatedElement>{prosopoManager:displayElement($data/xml/xmlElementNickname/text(),$personUri,  (), ())}</updatedElement>

      </response>
};

declare function prosopoManager:getBondTypeReverse( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $bondTypesList := skosThesau:getChildren("https://ausohnum.huma-num.fr/concept/c23489", "en")
    let $appVariables := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")
    let $concept-collection-path := "/db/apps/" || $appVariables//thesaurus-app/text() || "Data/concepts"
    let $listOfconcepts := doc($concept-collection-path || "/patrimonium.rdf")
    let $bondUri := $data//bondUri/text()
    let $bondTypeUri := $data//bondTypeUri/text()
    let $currentPeopleUri := $data//currentPeopleUri/text()
    let $bondType := skosThesau:getLabel($bondTypeUri, "xml")
    let $bondNode := <snap:hasBond rdf:type="{ $bondType }" rdf:resource="{ $bondUri }"/>
    let $bondTypeReverseNodes := if($listOfconcepts//skos:Concept[matches(./@rdf:about, $bondTypeUri)]//owl:reverseOf) then
            $listOfconcepts//skos:Concept[matches(./@rdf:about, $bondTypeUri)]//owl:reverseOf
            else "nobond"
    
    let $bondReverseNodeFirst := if($bondTypeReverseNodes != "nobond") then 
            $listOfconcepts//skos:Concept[matches(./@rdf:about, $bondTypeReverseNodes[1]/@rdf:resource)]
            else()
    
    let $bondTypeReverseCode := if($bondTypeReverseNodes != "nobond") then 
            data($bondReverseNodeFirst//skos:prefLabel[matches(./@xml:lang, "xml")]/text())
            else ("")
    let $bondTypeReversePrefLabelEn := if($bondTypeReverseNodes != "nobond") then 
                    data($bondReverseNodeFirst//skos:prefLabel[matches(./@xml:lang, "en")]/text())
                    else "No reverse bond type found. Please select or search for in the panel below"
    
       return
       <data>
            <bondReverseUri>{ data($bondReverseNodeFirst/@rdf:about) }</bondReverseUri>
            <bondReverseCode>{ $bondTypeReverseCode }</bondReverseCode>
        <bondReversePrefLabel>{ $bondTypeReversePrefLabelEn }</bondReversePrefLabel>
  </data>
};

declare function prosopoManager:addBond( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
(:    let $bondTypesList := skosThesau:getChildren("https://ausohnum.huma-num.fr/concept/c23489", $prosopoManager:lang):)
    let $bondUri := $data//bondUri/text()
    let $bondUriShort := substring-before($bondUri, "#this")
    let $bondTypeUri := $data//bondTypeUri/text()
    let $currentPeopleUri := $data//currentPeopleUri/text()
    let $currentPeopleUriLong := $currentPeopleUri  || "#this"
    let $bondTypeUri := $data//bondTypeUri/text()
    let $bondTypeReverseUri := $data//bondTypeReverseUri/text()
    
    let $bondType := skosThesau:getLabel($bondTypeUri, "xml", $project)
(:    let $bondType := $data//bondTypeCode/text():)
    let $bondTypeReverseCode := 
                    if($bondTypeReverseUri !="") then skosThesau:getLabel($bondTypeReverseUri, "xml", $project)
                        else $data//bondTypeReverseCode/text()
                                                    
                    
                                                    
                                                    
    let $bondNode := <data>
    <snap:hasBond rdf:type="{ $bondType }" rdf:resource="{ $bondUriShort }"/>
    </data>
    let $bondReverseNode := <data>
    <snap:hasBond rdf:type="{ $bondTypeReverseCode}" rdf:resource="{ $currentPeopleUri }"/>
    </data>
    
    let $updateCurrentPerson :=
            if(util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' 
            || $currentPeopleUriLong || '"]')//snap:hasBond) then
                update insert $bondNode/node() following
                    util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUriLong || '"]')//snap:hasBond[last()]
            else
                update insert $bondNode/node() into
                util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUriLong || '"]')//foaf:primaryTopicOf/apc:people
    let $updateReverseBond := 
                if(util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $bondUri || '"]')//snap:hasBond)
                then
                update insert $bondReverseNode/node() following
                util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $bondUri || '"]')//snap:hasBond[last()]
                else 
                update insert $bondReverseNode/node() into
                util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $bondUri || '"]')//foaf:primaryTopicOf/apc:people
    return
       <data>
       <newBondList>{ prosopoManager:hasBond($currentPeopleUriLong) }</newBondList>
       <newContent xmlns:lawd="http://lawd.info/ontology/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">{util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$currentPeopleUriLong ||"']" )}</newContent>
  </data>
};

declare function prosopoManager:addFunction( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $functionUri := $data//functionUri/text()
    let $targetUri := $data//targetUri/text()
    let $currentPeopleUri := $data//currentPeopleUri/text() || "#this"
    
    let $functionNode :=
            if($targetUri != "") then 
        <data>
        <apc:hasFunction rdf:resource="{ $functionUri}" target="{$targetUri}"/></data>
        else
        <data>
        <apc:hasFunction rdf:resource="{ $functionUri}"/></data>
    
    let $updateCurrentPerson :=
                if(util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUri|| '"]')//apc:hasFunction)
                then
                update insert $functionNode/node() following
                util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUri|| '"]')//apc:hasFunction[last()]
                else
                update insert $functionNode/node() into
                util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUri|| '"]')//foaf:primaryTopicOf/apc:people
    return
       <data>
       <details>targetUri: { $targetUri }</details>
       <newFunctionList>{ prosopoManager:hasFunction($currentPeopleUri) }</newFunctionList>
       <newContent xmlns:lawd="http://lawd.info/ontology/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">{util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$currentPeopleUri ||"']" )}</newContent>
  </data>
};


declare function prosopoManager:moveFunction( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $currentPeopleUri := $data//currentPeopleUri/text() || "#this"
    let $pos := xs:int($data//functionPosition/text())
    let $moveDirection := $data//moveDirection/text()
    let $saveNode1 :=
            <data>{util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUri|| '"]')//apc:hasFunction[$pos]}
                 </data>
    let $saveNode2 :=
            <data> {util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUri|| '"]')//apc:hasFunction[$pos+1]}
               </data>
       
let $moveFunction :=
   switch ($moveDirection)
   case "down"
       return
           (update insert $saveNode2/node() preceding 
                util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUri|| '"]')//apc:hasFunction[$pos],
            update replace util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUri|| '"]')//apc:hasFunction[$pos+2] with text { "" }
           )
   case "up"
   
       return
           (update insert $saveNode1/node() preceding 
                util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUri|| '"]')//apc:hasFunction[$pos -1],
            update replace util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUri|| '"]')//apc:hasFunction[$pos+1] with text { "" }
            )
       default return null
    
    
    
    
    return
       <data>
            <details>personUri : {$currentPeopleUri}
            moveDirection: {$moveDirection}
            </details>
            <newFunctionList>{ prosopoManager:hasFunction($currentPeopleUri) }</newFunctionList>
            <newContent>{util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$currentPeopleUri ||"']" )}</newContent>
         </data>
};
declare function prosopoManager:removeRelationship( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $personUri := $data//personUri/text()
    
    let $bondUri:= $data//bondUri/text()
    let $bondType := $data//bondType/text()
    let $relatedPersonName :=
    $prosopoManager:peopleCollection//apc:people[@rdf:about = $bondUri[1]]/lawd:personalName[1]/text()
    
    let $appVariables := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")
    let $concept-collection-path := "/db/apps/" || $appVariables//thesaurus-app/text() || "Data/concepts"
    let $listOfconcepts := doc($concept-collection-path || "/patrimonium.rdf")
    let $bondTypeReverseNodes := 
          
(:          if($listOfconcepts//skos:Concept[matches(.//skos:prefLabel[@xml:lang="xml"][1], $bondType[1])]//owl:reverseOf)
            then
                $listOfconcepts//skos:Concept[matches(.//skos:prefLabel[@xml:lang="xml"][1], $bondType[1])]//owl:reverseOf
            else "nobond"
     let $bondReverseNodeFirst := if($bondTypeReverseNodes != "nobond")
            then 
                $listOfconcepts//skos:Concept[matches(./@rdf:about, $bondTypeReverseNodes[1]/@rdf:resource)]
            else():)
          
       if($listOfconcepts//skos:Concept[.//skos:prefLabel[@xml:lang="xml"][1] = $bondType[1]]//owl:reverseOf)
            then
                $listOfconcepts//skos:Concept[.//skos:prefLabel[@xml:lang="xml"][1] = $bondType[1]]//owl:reverseOf
            else "nobond"
     let $bondReverseNodeFirst := if($bondTypeReverseNodes != "nobond") then 
            $listOfconcepts//skos:Concept[matches(./@rdf:about, $bondTypeReverseNodes[1]/@rdf:resource)]
            else()
    
     let $bondTypeReverseCode := if($bondTypeReverseNodes != "nobond") then 
            data($bondReverseNodeFirst//skos:prefLabel[matches(./@xml:lang, "xml")][1]/text())
            else ("")

    
    let $removeRelationshipInBond :=
          let $bondNodes := util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//apc:people[matches(./@rdf:about, '" || $bondUri || "')]")//snap:hasBond[@rdf:resource=$personUri]
          let $suggestion := 
          
                <div>
                    <h4>More than 1 relation with <strong>{$relatedPersonName}</strong>.
                    <br/>Please select which should be deleted in related person's record</h4>
                    {for $relation at $pos in $bondNodes
                        return
                        <div>
                          <input type="radio" name="relatedBondType" class="d-block" value="{data($relation/@rdf:type)}">{data($relation/@rdf:type)}</input>
                          <br/>
                        </div>
                    }
                </div>
          
          
          return
          if (count($bondNodes) >1)
            then(
                if($bondTypeReverseNodes ="nobond") then 
                    $suggestion
                else (
                    let $bondNode :=
                        util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//apc:people[matches(./@rdf:about, '" || $bondUri || "')]")//snap:hasBond[@rdf:resource=$personUri][@rdf:type=$bondTypeReverseCode]
                    return
                            if($bondNode) then
                              
                                    <div>
                                        <h4>This relationship will be deleted in <strong>{$relatedPersonName}</strong>'s record</h4>
                                            <input id="relatedBondType" type="checkbox" name="relatedBondType" value="{data($bondNode/@rdf:type)}">{data($bondNode/@rdf:type)}</input>
                                            
                                        </div>
                              
                            else (
                                $suggestion
                            )
                
                )
            )
            else (
                    <div>
                                    <div>
                                        <h4>This relationship will be deleted in <strong>{$relatedPersonName}</strong>'s record</h4>
                                            <input id="relatedBondType" type="checkbox" name="relatedBondType" value="{data($bondNodes[1]/@rdf:type)}" checked="checked">{data($bondNodes[1]/@rdf:type)}</input>
                                            
                                        </div>
                                </div>
            )
    return
       <data>
            <details>
            </details>
            <response>{ $removeRelationshipInBond }
            <input id="personUri" type="text" class="hidden" value="{ $personUri }"></input>
            <input id="bondUri" type="text" class="hidden" value="{ $bondUri }"></input>
            <input id="bondType" type="text" class="hidden" value="{ $bondType }"></input>
            
    
            </response>
         </data>
};

declare function prosopoManager:confirmRelationshipDeletion($data as node(), $project as xs:string){
 let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $personUri := $data//personUri/text()
    let $bondUri:= $data//bondUri/text()
    let $bondType := $data//bondType/text()
    let $relatedBondType := $data//relatedBondType/text()
    
    let $removeRelationshipInPerson :=
            update delete util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//apc:people[matches(./@rdf:about, '" || $personUri || "')]")//snap:hasBond[@rdf:resource=$bondUri][@rdf:type=$bondType]
     let $removeRelationshipInBond :=
            update delete util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//apc:people[matches(./@rdf:about, '" || $bondUri || "')]")//snap:hasBond[@rdf:resource=$personUri][@rdf:type=$relatedBondType]
    return
       <data>
            <details>
            </details>
            <newBondList>{ prosopoManager:hasBond($personUri ||"#this") }</newBondList>
            <newContent>{ util:eval( "collection('" || $prosopoManager:project-people-collection-path || "')//lawd:person[@rdf:about='"||$personUri ||"']" ) }</newContent>
         </data>
};

declare function prosopoManager:searchProjectPeopleModal(){

    <div id="dialogAddBond" title="Add a Bond" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Add a new bond</h4>
                </div>
                <div class="modal-body">
                    
                            <div id="peopleLookUpPanel" class="sectionInPanel">
                                <div class="form-group">
                                    <label for="projectPeopleLookup">Search a person in project's people</label>
                                     <input type="text" class="form-control projectPeopleLookup"
                                     id="projectPeopleLookup"
                                     name="projectPeopleLookup"/>
                                </div>
                                            
                                <div id="projectPeopleDetailsPreview" class=""/>
                                <br/>
                                <div class="row">
                                    <div class="col-xs-6 col-sm-6 col-md-6">
                                            <label>Select a relationship type...</label>
                                            <div class="form-group">
                                                 {skosThesau:dropDownThesauForElement("hasBondType", "c23489", $prosopoManager:lang, '', 'inline', (), (), ())}
                                            </div>
                                     </div>
                                     <div class="col-xs-6 col-sm-6 col-md-6">
                                            <div class="form-group">
                                                 <label for="bondTypesLookup">...or search</label>
                                                 <input type="text" class="form-control bondTypesLookup"
                                                 id="bondTypesLookup"
                                                 name="bondTypesLookup"/>
                                             </div>
                                     </div>
                                </div>
                                <hr/>
                                <div id="reverseSuggestion"/>
                                <br/>
                                <!--<div style="padding-left: 1em">-->
                                <div class="row">
                                    
                                    <div id="selectReverseBondType" class="col-xs-6 col-sm-6 col-md-6 hidden form-group">
                                        <label>Select a reverse relationship type...</label>
                                            {skosThesau:dropDownThesauForElement("hasBondTypeReverse", "c23489", $prosopoManager:lang, '', 'inline', (), (), ())}
                                    </div>
                                    
                                    <div id="bondReverseTypesLookupDiv" class="form-group col-xs-6 col-sm-6 col-md-6 hidden">
                                            <label for="bondReverseTypesLookup">... or search</label>
                                            <input type="text" class="form-control bondTypesLookup"
                                     id="bondReverseTypesLookup"
                                     name="bondReverseTypesLookup" />
                                        </div>
                                   <!--</div>-->
                                </div>
                                
                                <input id="selectedbondTypesLookup" type="text" class="hidden"/>
                                <input id="peopleTypeSelection" type="text" class="hidden"/>
                                <input id="currentPeopleUri" type="text" class="hidden"/>
                                <input id="selectedPeopleUri" type="text" class="hidden"/>
                                <input id="bondReverseUri" type="text" class="hidden"/>
                                <input id="bondTypeReverseCode" type="text" class="hidden"/>
                                <input id="selectedbondReverseTypesLookup" type="text" class="hidden"/>
                                 </div>
                   </div>

                    <div class="modal-footer">


                        <button  id="checkReverseButton" class="btn btn-success pull-left" type="submit" onclick="checkReverse()">Get reverse bond</button>
                        <button  id="addBondButton" class="btn btn-primary pull-left hidden" type="submit" onclick="addBond()">Validate</button>
                        <button type="button" class="btn btn-default" onclick="closeAddBondModal()">Cancel</button>
                    </div>
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->
                </div>
            </div>
};


(:declare function prosopoManager:addFunction( $data as node(), $project as xs:string){

    let $now := fn:current-dateTime()
    let $currentUser := data(sm:id()//sm:username)
    let $bondTypesList := skosThesau:getChildren("https://ausohnum.huma-num.fr/concept/c22148", $prosopoManager:lang)
    let $bondUri := $data//bondUri/text()
    let $bondTypeUri := $data//bondTypeUri/text()
    let $currentPeopleUri := $data//currentPeopleUri/text()
    let $bondTypeUri := $data//bondTypeUri/text()
    
    let $bondType := skosThesau:getLabel($bondTypeUri, "xml")
(\:    let $bondType := $data//bondTypeCode/text():\)
    let $bondTypeReverseCode := $data//bondTypeReverseCode/text()
    let $bondNode := <data><snap:hasBond rdf:type="{ $bondType }" rdf:resource="{ substring-before($bondUri, "#this") }"/>
    </data>
    let $bondReverseNode := <data><snap:hasBond rdf:type="{ $bondTypeReverseCode}" rdf:resource="{ substring-before($currentPeopleUri, "#this" ) }"/>
    </data>
    
    let $updateCurrentPerson :=
                update insert $bondNode/node() into
                util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $currentPeopleUri|| '"]')//foaf:primaryTopicOf/apc:people
    let $updateReverseBond := update insert $bondReverseNode/node() into
                util:eval('collection("' || $prosopoManager:project-people-collection-path || '")//lawd:person[@rdf:about="' || $bondUri|| '"]')//foaf:primaryTopicOf/apc:people
    return
       <data>
       <newBondList>{ prosopoManager:hasBond($currentPeopleUri) }</newBondList>
       
  </data>
};
:)
declare function prosopoManager:addFunctionModal(){

    <div id="dialogAddFunction" title="Add a Function" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Add a function</h4>
                </div>
                <div class="modal-body">
                            <div id="peopleLookUpPanel" class="sectionInPanel">
                             <div class="form-group">
                                    <label for="functionsLookup">Function</label>
                                     <input type="text" class="form-control functionsLookup"
                                     id="functionsLookup"
                                     name="functionsLookup"
                                     placeholder="search a function"/>
                             </div>        
                             <div class="form-group">
                                    <label for="functionTargetLookup">Target</label>
                                     <input type="text" class="form-control functionTargetLookup"
                                     id="functionTargetLookup"
                                     name="functionsLookup"
                                     placeholder="Search in project's Places or Military units"/>
                             </div>               
                             <br/>
                                     <div id="detailsPreview" class="hidden">Function to be added:<br/> 
                                     <span  id="functionDetailsPreview" class=""/><span> of </span>
                                     <span id="targetDetailsPreview"/>
                                     </div>
                                     <hr/>
                                     <div id="reverseSuggestion"/>
                                     <input id="selectedFunctionUri" type="text" class="hidden"/>
                                     <input id="targetUri" type="text" class="hidden"/>
                             </div>                                     
                   </div>

                    <div class="modal-footer">
                        <button  id="addFunctionButton" class="btn btn-primary pull-left" type="submit" onclick="addFunction()">Validate</button>
                        <button type="button" class="btn btn-default" onclick="closeAddFunctionModal()">Cancel</button>
                    </div>
                  
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    

};

declare function prosopoManager:deleteRelationshipModal(){

    <div id="dialogDeleteRelationship" title="Remove a relationship" class="modal fade" tabindex="-1" style="display: none;">

            <!-- Modal content-->
            <div class="modal-content modal4editor">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal"/>
                    <h4 class="modal-title">Delete a relationship</h4>
                </div>
                <div class="modal-body">
                            <div id="suggestionForRelation" class="sectionInPanel">
                             </div>                                     
                   </div>

                    <div class="modal-footer">
                        <button  id="confirmRelationShipDeletionButton" class="btn btn-primary pull-left" type="submit" onclick="confirmRelationshipDeletion()">Validate</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                  
                    <!--                <a href="javascript: void(0);" onclick="tests()">Test</a>        -->

                </div>

            </div>


    

};


declare function prosopoManager:buildPeopleTree(){
 
 
 let $rootNodes :=
         $prosopoManager:peopleCollection //lawd:person

(: for $child in $children:)
 return

        serialize(
        <children xmlns:json="http://www.json.org" json:array="true">
         <title>People</title>
         <id></id>
         <key></key>
          <isFolder>true</isFolder>
         <orderedCollection json:literal="true">true</orderedCollection>
         <lang></lang>
                        <children xmlns:json="http://www.json.org" json:array="true">
                         <title>Create a new person</title>
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
                                    { prosopoManager:buildPeopleTree($rootNodes, "en")}
                       </children>

    </children>
        ,
            <output:serialization-parameters>
                <output:method>json</output:method>
            </output:serialization-parameters>
        )

 };

 declare function prosopoManager:buildPeopleTree($rootNodes, $lang){
                for $child in $rootNodes
                let $placeConcept := $child//apc:people
                let $rdfAbout := $child/@rdf:about
                order by
                      lower-case($child//apc:people[1]//lawd:personalName/text()) collation "?lang=en"

              return

              <children json:array="true" status="{data($child//@status)}" type="collectionItem">
                 <title>{ if($child//apc:people[1]//lawd:personalName/text()) then
                            functx:capitalize-first($child//apc:people/lawd:personalName/text())
                          else ("No label for " || $rdfAbout)

                 } [{ substring-before(functx:substring-after-last($rdfAbout, "/" ), '#') }]</title>
                 <uri>{ $rdfAbout }</uri>
                 <key>{ substring-before(substring-after($rdfAbout, "/people/"), "#this") }</key>
                 <data>
                 <id>{ substring-before(substring-after($rdfAbout, "/people/"), "#this") }</id>
                 <lang>{$lang}</lang>
                </data>
                 <isFolder>false</isFolder>
                
              </children>


 };
 
 (:declare function prosopoManager:peopleNodes($nodes, $visited, $renderingOrder, $lang){

            for $childnodes in $nodes except ($visited)
                let $uri := data($childnodes/@rdf:resource) || "#this"
                let $ntConcept :=
                   $prosopoManager:peopleCollection//lawd:person[@rdf:about=$uri]
                 let $placeConcept := $ntConcept[1]//apc:people

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
                     (\:
                     if($renderingOrder ="ordered") then order by reverse($childnodes)
                     else order by $ntSkosConcept/skos:prefLabel[@xml:lang=$lang]:\)

    return

                if ($ntConcept//skos:narrower)
                  then(
                       <children json:array="true" status="{data($ntConcept//@status)}" type="collectionItem">
                                <title>
                                {if(exists($placeConcept//dcterms:title/text())) then
                                (
                                functx:capitalize-first($placeConcept//dcterms:title/text())
                                || $uri
                                )

                                else if ($placeConcept/dcterms:title[@xml:lang='en']/text()) then
                                (concat(functx:capitalize-first($ntConcept//pleiades:Place/dcterms:title[@xml:lang='en']/text()), ' (en)'))
                                else if  ($placeConcept/dcterms:title[@xml:lang='fr']/text()) then
                                (concat(functx:capitalize-first($placeConcept/dcterms:title[@xml:lang='fr']/text()), ' (fr)'))



                                else ("No name found for " || data($ntConcept/@rdf:about))
                                }</title>
                                <data>
                                <id>{$uri}</id>
                                <key>{ substring-before(substring-after(data($ntConcept/@rdf:about), "/places/"), "#this") }</key>
                                <uri>{$uri}</uri>
                                { substring-before(substring-after(data($ntConcept/@rdf:about), "/places/"), "#this") }
                                 <lng>{ data($placeConcept/geo:long/text()) }</lng>
                                <lat>{ data($placeConcept/geo:lat/text()) }</lat>
                                </data>
                                <lang>{$lang}</lang>
                                <isFolder>true</isFolder>
                                { prosopoManager:peopleNodes($ntConcept//skos:narrower, ($visited, $childnodes), data($ntConcept/@type), $lang)
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
                                else ("No name for " || data($ntConcept[1]/@rdf:about))
                                }</title>
                          
                                    <id>{ substring-before(substring-after(data($uri), "/places/"), "#this")}</id>
                                    
                                    <key>{ substring-before(substring-after(data($uri), "/places/"), "#this")}</key>
                                    <data>
                                    <uri>{$uri}</uri>
                                    
                        <lang>{$lang}</lang>
                        </data>
                    </children>
                    )
         (\:{ if($ntConcept//pleiades:Place/geo:lat) then
                                    data($ntConcept//pleiades:Place/geo:lat/text())
                                    else
                                    (
                                    let $parentId := data($ntConcept[1]//spatial:P[1]/@rdf:resource)
                                    let $parentWithGeoRef :=  $spatiumStructor:place-collection//spatial:Feature[@rdf:about=$parentId || "#this"]
                                    return data($parentWithGeoRef//pleiades:Place/geo:lat))}
                        :\)


};:)

declare function prosopoManager:listPeopleAsTable(){
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
    <div id="peopleListDiv">
    <table id="peopleList" class="table">
     <thead>
        <tr>
            
            <td class="sortingActive">Name</td>
            <td>ID</td>
            <td class="hidden">TM</td>
        </tr>
        </thead>
        <tbody>
                
         </tbody>
      </table>
      
      
      <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.css"/>
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.js"></script>
    <script type="text/javascript">$(document).ready( function () {{
                        $('#peopleList').DataTable({{
                        //paging: false
                        'pageLength': 100,
                        "ajax": '/people/json',
                        "columns": [
                                    {{ "data": "name" }},
                                    {{ "data": "id" }},
                                    {{ "data": "exactMatches" }}
                                ],
                                "columnDefs": [
                                                   {{ "targets": [0],
                                                   "render": function ( data, type, full, meta ) {{
                                                               return '<span class="spanLink" onclick="displayPerson('+ full.id +')">' + data + '</span>';    }}
                                                   }},
                                                   {{ "targets": [1],
                                                   "render": function ( data, type, full, meta ) {{
                                                               return '<span class="spanLink" onclick="displayPerson('+ data +')">' + data + '</span>';    }}
                                                   }},
                                                   {{
                                                       "targets": [ 2 ],
                                                       "visible": false
                                                   }}
                                                ],
                                                "language": {{
                                            "search": "Search (also by TM no.):"
                                                }}
                            }});
                        }} );</script>
    <script type="text/javascript">{ $complete }</script>
    <script type="text/javascript">$( '#peopleList' ).searchable();</script>
    
   </div>
};