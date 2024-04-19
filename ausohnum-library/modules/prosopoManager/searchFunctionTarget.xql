xquery version "3.1";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";

declare namespace dcterms="http://purl.org/dc/terms/";

declare namespace foaf="http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";

declare namespace json="http://www.json.org";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace spatial="http://geovocab.org/spatial#";


declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "application/json";
declare option output:indent "yes";

declare variable $project :=request:get-parameter('project', ());
declare variable $query :=request:get-parameter('query', ());


let $places-collection := collection("/db/apps/" || $project || "Data/places/" || $project )
let $militaryunits-collection := skosThesau:getChildren("https://ausohnum.huma-num.fr/concept/c22224", $project)


return

    <data>
    <when>{fn:current-dateTime()}</when>
    <list>
    <items>
        <identifier>{count($places-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place//dcterms:title[matches(lower-case(.), lower-case($query))]])} match{if(count($places-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place//dcterms:title[starts-with(lower-case(.), lower-case($query))]])>1) then "es" else ()}</identifier>
        <title>Search "{$query}" returns </title>
        <object_type></object_type>
        <dataset_path>
            <title>Patrimonium Places</title>
            <id>Patrimonium Places</id>
        </dataset_path>
            <exactMatch></exactMatch>
      </items>
    
    {
  for $item at $pos in ($places-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place//dcterms:title[matches(lower-case(.), lower-case($query))]], $militaryunits-collection//skos:Concept[skos:prefLabel[matches(lower-case(.), lower-case($query))]])
  let $placeConcept := $item//pleiades:Place
  let $militaryUnitConcept := $item
  return 
    <items>
        <identifier>{if($placeConcept) then data($placeConcept/@rdf:about) else data($militaryUnitConcept/@rdf:about)}</identifier>
        <title>
        {if($placeConcept) then $placeConcept//dcterms:title/text() else $militaryUnitConcept/skos:prefLabel[1]/text()}
        </title>
        <object_type>Place</object_type>
        <dataset_path>
            <title>Patrimonium Places</title>
            <id>Patrimonium Places</id>
            </dataset_path>
      </items>
  }
  </list>
 </data>
 