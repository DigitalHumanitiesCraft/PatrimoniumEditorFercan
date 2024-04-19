xquery version "3.1";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "./skosThesauApp.xql";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace skos = "http://www.w3.org/2004/02/skos/core#";


(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "application/json";
declare option output:indent "yes";

declare variable $project :=request:get-parameter('project', ());
declare variable $query :=request:get-parameter('query', ());
declare variable $topConceptUri := request:get-parameter('topConceptUri', ());

let $conceptCollection := skosThesau:getChildren(xs:anyURI($topConceptUri), $project)

return

    <data>
    <when>{fn:current-dateTime()}</when>
    <list>
    <items>
        <identifier>{count($conceptCollection//skos:Concept[skos:prefLabel[matches(lower-case(.), lower-case($query))]])} match{if(count($conceptCollection//skos:Concept[prefLabel[starts-with(lower-case(.), lower-case($query))]])>1) then "es" else ()}</identifier>
        <title>Search "{$query}" returns </title>
        <object_type></object_type>
        <dataset_path>
            <title>Concepts {$project}</title>
            <id>Concepts</id>
        </dataset_path>
        <exactMatch></exactMatch>
      </items>
    
    {
  for $concept at $pos in $conceptCollection//skos:Concept[skos:prefLabel[matches(lower-case(.), lower-case($query))]]|$conceptCollection//skos:Concept[skos:altLabel[matches(lower-case(.), lower-case($query))]]
  
                                                                                
  return 
    <items>
        <identifier>{data($concept/@rdf:about)}</identifier>
        <title>{$concept/skos:prefLabel[1]/text()}</title>
        <object_type>Concepts</object_type>
        <dataset_path>
            <title>Concept</title>
            <id>Concept</id>
        </dataset_path>
        
        
      </items>
  }
  </list>
 </data>
