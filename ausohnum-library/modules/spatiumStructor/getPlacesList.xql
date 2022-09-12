(:~
: AusoHNum Library - spatial data manager module
: This function return the list of places linked to a document, serialized in JSON. Used in Data Table.
: @author Vincent Razanajao
: @param project name
: @param document id
: @return JSon list of all places.
:)


xquery version "3.1";

(:import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "./spatiumStructor.xql";:)
import module namespace functx="http://www.functx.com";
import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons" at "../commons/commonsApp.xql";
(:import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "prosopoManager.xql";:)
declare namespace json="http://www.json.org";

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace foaf = "http://xmlns.com/foaf/0.1/";
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


(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

declare variable $project :=request:get-parameter('project', ());
declare variable $placesCollection := collection("/db/apps/" || $project || "Data/places/" || $project);
declare variable $nl := '&#xa;';
declare variable $type := request:get-parameter("listType", ());
declare variable $lang:= request:get-parameter("lang", ());

switch($type)
case "admin" return
  <root>{
  for $place in $placesCollection//spatial:Feature
                let $name := $place/foaf:primaryTopicOf/pleiades:Place/dcterms:title/text()
                
                
                let $uri := $place/@rdf:about
                let $uriShort := substring-before($uri, "#this") 
                let $id := functx:substring-after-last($uriShort, "/")
                let $tmNo := try { substring-after($place//skos:exactMatch[matches(./@rdf:resource, "trismegistos")]/@rdf:resource, "/place/")}
                catch * {""}
                let $exactMatches := string-join($place//skos:exactMatch/@rdf:resource, " ")
                order by lower-case($name) 
  
  return
                <data json:array="true">
                    <name>{'<span class="spanLink" onclick="displayPlace(' || "'" || replace($name, "\W", " ") || "', '" || $uriShort || "'" || ')">' || $name || "</span>"}
                     {if ($place//spatial:Pi) then 
                     
                      '<div><a class="btn btn-light btn-xs" data-toggle="collapse" href="#collapseSubPlaces' || $id || '" role="button" aria-expanded="false" aria-controls="collapseExample" style="font-size: smaller;">' ||
                                count($place//spatial:Pi) || ' subplace' || (if(count($place//spatial:Pi) > 1) then 's' else '') || ' - click to see</a>
                            <div class="collapse" id="collapseSubPlaces' || $id  || '">
                                    <div class="card card-body">'
                     else ()}
                    {if ($place//spatial:Pi) then 
                         for $subPlace at $pos in $place//spatial:Pi
                            let $subPlaceUri := functx:substring-before-if-contains(data($subPlace/@rdf:resource), "#this")
                            let $subPlace := $placesCollection//pleiades:Place[@rdf:about = $subPlaceUri]
                            let $subPlaceName := $subPlace//dcterms:title[1]/text()
                           
                             
                            return
                            
                            '<span class="subPlace"></name><br/>|_ ' || '<span class="spanLink" onclick="displayPlace(' || "'" || $subPlaceName || "', '" || $subPlaceUri || "'" || ')">' || $subPlaceName || "</span></span>"
                         
                        else()}
                         {if ($place//spatial:Pi) then '</div></div></div>' else '' }
                    </name>
                    <id>{ $id }{if ($tmNo) then $nl || "TM " || $tmNo else ()}</id>
                    <uri>{ $uriShort }</uri>
                   
                    <exactMatches>{$exactMatches}</exactMatches></data>
                
    }
  </root>
  
case "public" return
 <root>{
  for $place in doc("/db/apps/" || $project || "Data/places/project-places-gazetteer.xml")//features
(:                let $name := functx:if-empty(replace($place/properties/name/text(), "\W", " "), " "):)
                let $name := functx:if-empty($place/properties/name/text(), " ")
                let $uri := functx:if-empty($place/properties/uri/text(), " ")
                let $id := functx:if-empty(functx:substring-after-last($uri, "/"), " ")
                (:let $tmNo := try { substring-after($place//skos:exactMatch[matches(./@rdf:resource, "trismegistos")]/@rdf:resource, "/place/")}
                                    catch * {""}:)
                let $exactMatch :=for $uri at $pos in  tokenize($place/properties/exactMatch/text(), " ")
                    let $separator := if($pos < count(tokenize($place/properties/exactMatch/text(), " "))) then " " else ()
                    let $sourceName :=
                        switch(substring-before(substring-after($uri, "//"), "/"))
                            case "pleiades.stoa.org" return "Pleiades"
                            case "www.trismegistos.org" return "TM"
                            default return ""
                    let $cssColor:=
                        switch(substring-before(substring-after($uri, "//"), "/"))
                            case "pleiades.stoa.org" return "background-color:#5b9ec4"
                            case "www.trismegistos.org" return "background-color:#4848b7"
                            default return ""    
                   return
                                if($uri = " ") then ()
                                else
                                '<a href="' || $uri  || '" title="Open in a new window record ' || $sourceName || ' ' || $uri
                                ||'" target="_blank" class="label label-primary labelInTable"' 
(:                                style="color: white; padding: 2px; ' :)
(:                                || $cssColor :)
                                ||'">'
                                || $sourceName || ':' || functx:substring-after-last($uri, '/') 
(:                                ||'<i class="glyphicon glyphicon-new-window"/></a>' :)
                                || $separator
                                
                                
(:                                   functx:if-empty($place/properties/exactMatch/text(), " "):)
                order by lower-case($name) 
  
  return
                <data json:array="true">
                    <id>{ $id }</id>
                    <name>
                    { $name
(:                    '<span class="spanLink" onclick="showPlaceOnMapAndDisplayRecord(' || "'" || $uri || "'" || ')">' || $name || "</span>":)
                    }</name>
                    <nameDatatableRender>
                    { 
                    '<span class="spanLink" onclick="showPlaceOnMapAndDisplayRecord(' || "'" || $uri || "'" || ')">' || $name || "</span>"
                    }
                    </nameDatatableRender>
                    <uri>{ $uri }</uri>
                    <geoCoord>{ string-join($place//coordList//coordinates, ", ") }</geoCoord>
                   <type>{ '<a href="' || $place//placeTypeUri || '" class="">' || functx:capitalize-first($place//placeType/text()) || '</a>' }</type>
                   <productionType>{ $place//productionTypeLink/text() 
(:                   functx:if-empty('<a href="' || $place//placeTypeUri || '" class="label label-primary" target="_blank">' || functx:capitalize-first($place//productionType/text()) || '</a>', " "):)
(:                   ausohnumCommons:getLabelFromConcept($place//productionType/text(), $lang) :)
                   }</productionType>
                   <productionTypeLink>{ serialize($place//productionTypeLink/node()) }</productionTypeLink>
                   <provinceUri>{ $place//provinceUri/text() }</provinceUri>
                   <provinceName>{ '<a href="' || $place//provinceUri ||'" class="" target="_blank">' || functx:if-empty($place//provinceName/text(), ' ') || '</a>'}</provinceName>
                    <exactMatch>{ $exactMatch }</exactMatch>
                    <altNames>{ functx:if-empty($place/properties/altNames/text(), " ") }</altNames>
                    </data>
                    
                
    }
  </root>
  default return
  <root>{
  for $place in $placesCollection//spatial:Feature
                let $name := $place/foaf:primaryTopicOf/pleiades:Place/dcterms:title/text()
                
                
                let $uri := $place/@rdf:about
                let $uriShort := substring-before($uri, "#this") 
                let $id := functx:substring-after-last($uriShort, "/")
                let $tmNo := try { substring-after($place//skos:exactMatch[matches(./@rdf:resource, "trismegistos")]/@rdf:resource, "/place/")}
                catch * {""}
                let $exactMatches := string-join($place//skos:exactMatch/@rdf:resource, " ")
                order by lower-case($name) 
  
  return
                <data json:array="true">Type:{$type}
                    <name>{'<span class="spanLink" onclick="displayPlace(' || "'" || replace($name, "\W", " ") || "', '" || $uriShort || "'" || ')">' || $name || "</span>"}
                     {if ($place//spatial:Pi) then 
                     
                      '<div><a class="btn btn-light btn-xs" data-toggle="collapse" href="#collapseSubPlaces' || $id || '" role="button" aria-expanded="false" aria-controls="collapseExample" style="font-size: smaller;">' ||
                                count($place//spatial:Pi) || ' subplace' || (if(count($place//spatial:Pi) > 1) then 's' else '') || ' - click to see</a>
                            <div class="collapse" id="collapseSubPlaces' || $id  || '">
                                    <div class="card card-body">'
                     else ()}
                    {if ($place//spatial:Pi) then 
                         for $subPlace at $pos in $place//spatial:Pi
                            let $subPlaceUri := functx:substring-before-if-contains(data($subPlace/@rdf:resource), "#this")
                            let $subPlace := $placesCollection//pleiades:Place[@rdf:about = $subPlaceUri]
                            let $subPlaceName := $subPlace//dcterms:title[1]/text()
                           
                             
                            return
                            
                            '<span class="subPlace"></name><br/>|_ ' || '<span class="spanLink" onclick="displayPlace(' || "'" || $subPlaceName || "', '" || $subPlaceUri || "'" || ')">' || $subPlaceName || "</span></span>"
                         
                        else()}
                         {if ($place//spatial:Pi) then '</div></div></div>' else '' }
                    </name>
                    <id>{ $id }{if ($tmNo) then $nl || "TM " || $tmNo else ()}</id>
                    <uri>{ $uriShort }</uri>
                   
                    <exactMatches>{$exactMatches}</exactMatches></data>
                
    }
  </root>