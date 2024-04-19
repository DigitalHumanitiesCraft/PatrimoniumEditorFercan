xquery version "3.1";

import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";

import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/commons/commonsApp.xql";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";

(:import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/spatiumStructor/spatiumStructor.xql";
:)

import module namespace personRecordGenerator ="http://ausonius.huma-num.fr/personRecordGenerator"
      at "./personRecordGenerator.xql";

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
let $personId := request:get-parameter("resource", "")
let $personUriShort := $prosopoManager:uriBase || "/people/" || $personId
let $personUri := $prosopoManager:uriBase || "/people/" || $personId || "#this"

return
switch($origin)
case "call" return 
personRecordGenerator:recordForDisplay($personUriShort)
case "controller"
return

<div data-template="templates:surround" data-template-with="templates/page-apc.html" data-template-at="content">
    <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.css" />
    <script src="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.js"></script>

   <div class="container">
        <div class="row" data-template="app:navBar"/>
        <div class="row">
               { personRecordGenerator:recordForDisplay($personUriShort) }
   
 </div></div>
    <script>$("#datanavbar-people").addClass("active");
    if($("#apcMenu").hasClass("active")){{}} else{{$("#apcMenu").addClass("active");}}</script>
        <!--<link href="$ausohnum-lib/resources/css/prosopoManager.css" rel="stylesheet" type="text/css"/>-->
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/prosopoManager/prosopoManager.js"/>
        <link href="$ausohnum-lib/resources/css/ausohnumCommons.css" rel="stylesheet" type="text/css"/>
            
</div>

default return
 <div data-template="templates:surround" data-template-with="templates/page-apc.html" data-template-at="content">
    <link rel="stylesheet" href="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.css" />
    <script src="$ausohnum-lib/resources/scripts/jquery/summernote/summernote.min.js"></script>

   <div class="container">
        <div class="row" data-template="app:navBar"/>
        <div class="container">
        
               { personRecordGenerator:recordForDisplay($personUriShort) }
                    
 
 </div></div>
    <script>
        $("#logoForMenu").removeClass("hidden");
        if($("#apcMenu").hasClass("active")){{}} else{{$("#apcMenu").addClass("active");}}
        $("#datanavbar-people").addClass("active");</script>
        <!--<link href="$ausohnum-lib/resources/css/prosopoManager.css" rel="stylesheet" type="text/css"/>-->
        <script type="text/javascript" src="$ausohnum-lib/resources/scripts/prosopoManager/prosopoManager.js"/>
        <link href="$ausohnum-lib/resources/css/ausohnumCommons.css" rel="stylesheet" type="text/css"/>
            
</div>





