xquery version "3.1";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "../skosThesau/skosThesauApp.xql";

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dcterms="http://purl.org/dc/terms/";

declare namespace foaf="http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";

declare namespace json="http://www.json.org";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace snap="http://onto.snapdrgn.net/snap#";
declare namespace spatial="http://geovocab.org/spatial#";


declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "application/json";
declare option output:indent "yes";

declare variable $project :=request:get-parameter('project', ());
declare variable $query :=request:get-parameter('query', ());
declare variable $parentConceptUri :=request:get-parameter('parentConceptUri', 'https://ausohnum.huma-num.fr/concept/c22265');


(:let $functions-collection := collection("/db/apps/" || $project || "Data/functions/" ):)
let $functions-collection := skosThesau:getChildren("https://ausohnum.huma-num.fr/concept/c22265", $project)


return

    <data>
    <when>{fn:current-dateTime()}</when>
    <list>
    <items>
        <identifier>{count($functions-collection//skos:Concept[skos:prefLabel[matches(lower-case(.), lower-case($query))]])} match{if(count($functions-collection//skos:Concept[prefLabel[starts-with(lower-case(.), lower-case($query))]])>1) then "es" else ()}</identifier>
        <title>Search "{$query}" returns </title>
        <object_type></object_type>
        <dataset_path>
            <title>Patrimonium Functions</title>
            <id>Patrimonium Functions</id>
        </dataset_path>
        <exactMatch></exactMatch>
      </items>
    
    {
  for $function at $pos in $functions-collection//skos:Concept[skos:prefLabel[matches(lower-case(.), lower-case($query))]]|$functions-collection//skos:Concept[skos:altLabel[matches(lower-case(.), lower-case($query))]]
  
                                                                                
  return 
    <items>
        <identifier>{data($function/@rdf:about)}</identifier>
        <title>{$function/skos:prefLabel[1]/text()}</title>
        <object_type>Function</object_type>
        <dataset_path>
            <title>Patrimonium Functions</title>
            <id>Patrimonium Functions</id>
        </dataset_path>
        
        
      </items>
  }
  </list>
 </data>
