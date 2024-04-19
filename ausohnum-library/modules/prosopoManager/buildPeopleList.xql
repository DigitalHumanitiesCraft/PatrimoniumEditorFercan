xquery version "3.1";


import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons" at "../commons/commonsApp.xql";
import module namespace functx="http://www.functx.com";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";
declare namespace json="http://www.json.org";

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace http="http://expath.org/ns/http-client";

declare namespace lawd="http://lawd.info/ontology/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace local = "local";


(:declare option exist:serialize "method=xml media-type=xml";:)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare boundary-space preserve;


(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "application/javascript";
(:declare option output:method "xml";:)
(:declare option output:media-type "text/xml";:)
(:declare option exist:timeout "30000";:)

declare variable $project :=request:get-parameter('project', "");
declare variable $lang :=request:get-parameter('lang', "");
declare variable $peopleCollection := collection("/db/apps/" || $project || "Data/people");
 <root>{
  for $person in $peopleCollection//lawd:person[@rdf:about != ""][position() < 101]
      let $name := $person//lawd:personalName[1]/text()
      let $uri := $person/@rdf:about
      let $id := substring-before(functx:substring-after-last($uri, "/"), "#")
      
      let $sex := ausohnumCommons:getLabelFromConcept($person//apc:sex/@rdf:resource, $lang)
      
      let $exactMatches := string-join($person//skos:exactMatch/@rdf:resource, " ")
      let $personFunctions :=
            for $function in distinct-values(data($person//apc:hasFunction/@rdf:resource))
                return 
                '<a href="' || $function || '" target="about" title="Open record in new tab">' || ausohnumCommons:getLabelFromConcept($function, $lang) || '</a>'
      let $personalStatus := if($person//apc:personalStatus/@rdf:resource != "") then ausohnumCommons:getLabelFromConcept($person//apc:personalStatus/@rdf:resource, $lang) else " "
      let $socialStatus := if($person//apc:socialStatus/@rdf:resource != "") then ausohnumCommons:getLabelFromConcept($person//apc:socialStatus/@rdf:resource, $lang) else " "
       let $juridicalStatus := if($person//apc:juridicalStatus/@rdf:resource != "") then ausohnumCommons:getLabelFromConcept($person//apc:juridicalStatus/@rdf:resource, $lang) else " "
       let $temporalRange := ausohnumCommons:dateRangeFromRelatedDoc(substring-before($uri, "#this"))
            (:Too long:)
      order by $name

      return <data json:array="true"><id>{ $id }</id>
                    <name>{ if($name != "") then ($name || ' <a href="' || substring-before($uri, "#this") || '" target="blank"><i class="glyphicon glyphicon-new-window"/></a>' )else " "}</name>
                    <sex>{ if($sex != "") then $sex else " "}</sex>
                    <personalStatus>{ $personalStatus }</personalStatus>
                    <citizenship>{ $juridicalStatus }</citizenship>
                    <socialStatus>{ $socialStatus }</socialStatus>
                    <functions>{ if(data($personFunctions) != "") then $personFunctions else " "}</functions>
                    <exactMatch>{if($exactMatches != "") then $exactMatches else " "}</exactMatch>
                    <temporalRangeStart>{ $temporalRange[1] }</temporalRangeStart>
                    <temporalRangeEnd>{ $temporalRange[2] }</temporalRangeEnd>
                 </data>}</root>