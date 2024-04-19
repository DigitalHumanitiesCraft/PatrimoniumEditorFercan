(:~
: AusoHNum Library - prosopographical module
: This function serves as an interace between a project front-end and XQuery functions related to prosopographical matters.
: @author Vincent Razanajao
: @param type is the paramater of the http request that calls this function
:)

xquery version "3.1";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option exist:timeout "60000";

declare variable $type := request:get-parameter('type', ());
declare variable $data := request:get-data();
declare variable $project := request:get-parameter('project', ());
declare variable $lang := request:get-parameter('lang', ());
declare variable $currentLg := request:get-parameter("lg", ()) ;
declare variable $username := request:get-parameter('user', ());
declare variable $path:= request:get-parameter('path', ());
declare variable $resource:= request:get-parameter('resource', ());
declare variable $format:= request:get-parameter('format', ());
declare variable $conceptId := request:get-parameter('conceptId', ());
declare variable $conceptUris := request:get-parameter('conceptUris', ());
declare variable $lang4Thesaurus := request:get-parameter('lang4Thesaurus', ());


declare variable $label := request:get-parameter('label', ());

switch ($type)
   case "getTreeFromConcept" return 
    let $conceptUri := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")//uriBase[@type="thesaurus"]/text() || "/concept/" || $conceptId
    return
    serialize(
    skosThesau:getTreeFromConcept($project, $conceptUri, "en"),  <output:serialization-parameters>
                <output:method>json</output:method>
                <output:media-type>application/json</output:media-type>
            </output:serialization-parameters>)
 case "getTreeFromMultipleConcepts" return 
    let $conceptUri := doc("/db/apps/" || $project || "/data/app-general-parameters.xml")//uriBase[@type="thesaurus"]/text() || "/concept/" || $conceptId
    let $lang := if($lang4Thesaurus = "") then "fr" else string($lang4Thesaurus)
    return
    serialize(
    skosThesau:getTreeFromMultipleConcepts($project, ($conceptUris), $label, $lang),  <output:serialization-parameters>
                <output:method>json</output:method>
                <output:media-type>application/json</output:media-type>
            </output:serialization-parameters>)
   default return ()