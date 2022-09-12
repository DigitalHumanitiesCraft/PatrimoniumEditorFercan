xquery version "3.1";

(:import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "./spatiumStructor.xql";:)
import module namespace functx="http://www.functx.com";
import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";
declare namespace json="http://www.json.org";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "text/javascript";
declare option output:json-ignore-whitespace-text-nodes "yes";
declare variable $project :=request:get-parameter('project', ());
declare variable $format := request:get-parameter('format', ());
declare variable $appVariables := doc("/db/apps/" || $project || "/data/app-general-parameters.xml");
declare variable $placeType :=request:get-parameter('resource', ());
declare variable $place-collection-path-root := "/db/apps/" || $project || "Data/places/" ;
declare variable $productionUnitTypes := skosThesau:getChildren($appVariables//productionUnitsUri/text(), $project);
 
let $data := if($placeType = "all") then
        doc($place-collection-path-root || "project-places-gazetteer.xml")//features[properties/placeTypeUri[not(contains((string-join($productionUnitTypes//skos:Concept/@rdf:about, ",")), ./text()))]]
    else if($placeType = "production-units") then doc($place-collection-path-root || "project-places-gazetteer.xml")//features[properties/placeTypeUri[(contains((string-join($productionUnitTypes//skos:Concept/@rdf:about, ",")), ./text()))]]
    else if($placeType = "archaeo-features") then 
        (let $archaeoFeatures := skosThesau:getChildren($appVariables//archaeoFeaturesUri/text(), $project)
        return
        doc($place-collection-path-root || "project-places-gazetteer.xml")//features[properties/placeTypeUri[(contains((string-join($archaeoFeatures//skos:Concept/@rdf:about, ",")), ./text()))]]
        )
    else doc($place-collection-path-root || "project-places-gazetteer.xml")//features[properties/placeType/text() = $placeType]
    
    
    return
<root json:array="true" type="FeatureCollection">{ $data }</root>