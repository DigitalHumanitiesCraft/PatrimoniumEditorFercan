xquery version "3.1";


(:import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager" at "prosopoManager.xql";
:)
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


let $people-collection := collection("/db/apps/" || $project || "Data/people/" )


return

    <data>
    <when>{fn:current-dateTime()}</when>
    <list>
    <items>
        <identifier>{count($people-collection//lawd:person[foaf:primaryTopicOf/apc:people//lawd:personalName[starts-with(lower-case(.), lower-case($query))]])} match{if(count($people-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place//lawd:personalName[starts-with(lower-case(.), lower-case($query))]])>1) then "es" else ()}</identifier>
        <title>Search "{$query}" returns </title>
        <object_type></object_type>
        <dataset_path>
            <title>Patrimonium People</title>
            <id>Patrimonium People</id>
        </dataset_path>
        <exactMatch></exactMatch>
      </items>
    
    {
  for $people at $pos 
    in ($people-collection//lawd:person[foaf:primaryTopicOf/apc:people//lawd:personalName[matches(lower-case(.), lower-case($query))]],
    $people-collection//lawd:person[contains(./@rdf:about, $query)])
  let $peopleRecord:= $people//lawd:person
       order by $people/foaf:primaryTopicOf/apc:people/lawd:personalName/text()                             
  return 
    <items>
        <identifier>{data($people/@rdf:about)}</identifier>
        <title>{$people/foaf:primaryTopicOf/apc:people/lawd:personalName/text()} [{ substring-before(substring-after($people/@rdf:about, "/people/"), "#this")}]</title>
        <object_type>Place</object_type>
        <dataset_path>
            <title>Patrimonium People</title>
            <id>Patrimonium People</id>
        </dataset_path>
        
        
      </items>
  }
  </list>
 </data>
 