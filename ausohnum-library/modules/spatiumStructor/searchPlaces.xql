xquery version "3.1";

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


return

    <data>
    <when>{fn:current-dateTime()}</when>
    <list>
    <items>
        <identifier>{count($places-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place//dcterms:title[contains(lower-case(.), lower-case($query))]])} match{if(count($places-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place//dcterms:title[contains(lower-case(.), lower-case($query))]])>1) then "es" else ()}</identifier>
        <title>Search "{$query}" returns </title>
        <object_type></object_type>
        <dataset_path>
            <title>Patrimonium Places</title>
            <id>Patrimonium Places</id>
        </dataset_path>
        <geo_bounds>
               <min_lon></min_lon>
               <max_lon></max_lon>
               <min_lat></min_lat>
               <max_lat></max_lat>
        </geo_bounds>
        
            <exactMatch></exactMatch>
      </items>
    
    {
  for $place at $pos
    in ($places-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place//dcterms:title[contains(lower-case(.), lower-case($query))]],
        $places-collection//spatial:Feature[foaf:primaryTopicOf/pleiades:Place[contains(./@rdf:about, $query)]]
        )
  let $placeConcept := $place//pleiades:Place
  let $long := if($placeConcept/geo:long) then
                                                (
                                                data($placeConcept/geo:long/text())
                                                )
            
                                                else
                                                (
                                                    if($place//spatial:C[@type='isInVicinityOf'])
                                                        then (
                                                            let $parentId := data($place[1]/spatial:C[@type='isInVicinityOf']/@rdf:resource)
                                                            let $parentWithGeoRef :=  $places-collection//spatial:Feature[@rdf:about=$parentId || "#this"][1]
                                                            return  data($parentWithGeoRef//pleiades:Place[1]/geo:long[1])
                                                            )
                                                      else(
                                                            let $Ps := $place/spatial:P
                                                            let $parentId := data($place//spatial:P/@rdf:resource)
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $places-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(contains(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:long)
            
                                                    )
                                                    )
            let $lat := if($placeConcept/geo:lat) then
                                                (
                                                data($placeConcept/geo:lat/text())
                                                )
            
                                                else
                                                (
                                                    if($place//spatial:C[@type='isInVicinityOf'])
                                                        then (
                                                            let $parentId := data($place[1]/spatial:C[@type='isInVicinityOf']/@rdf:resource)
                                                            let $parentWithGeoRef :=  $places-collection//spatial:Feature[@rdf:about=$parentId || "#this"][1]
                                                            return  data($parentWithGeoRef//pleiades:Place[1]/geo:lat[1])
                                                            )
                                                      else(
                                                            let $Ps := $place/spatial:P
                                                            let $parentId := data($place//spatial:P/@rdf:resource)
            
                                                            let $parentWithGeoRef :=
                                                                    for $p in $Ps
                                                                        let $pId := data($p/@rdf:resource)
                                                                        let $pPlace := $places-collection//pleiades:Place[@rdf:about=$pId]
                                                                        return
                                                                        if($pPlace[not(contains(.//pleiades:hasFeatureType/text(), "province") )]) then
                                                                        $pPlace
                                                                        else (<pleiades:Place/>)
            
                                                       return
                                                       data($parentWithGeoRef[1]//geo:lat)
            
                                                    )
                                                    )
                                                                                                
  return 
    <items>
        <identifier>{data($place/@rdf:about)}</identifier>
        <title>{$place/foaf:primaryTopicOf/pleiades:Place/dcterms:title/text()}</title>
        <object_type>Place</object_type>
        <dataset_path>
            <title>Patrimonium Places</title>
            <id>Patrimonium Places</id>
        </dataset_path>
        <geo_bounds>
               <min_lon>{$long}</min_lon>
               <max_lon>{$long}</max_lon>
               <min_lat>{$lat}</min_lat>
               <max_lat>{$lat}</max_lat>
        </geo_bounds>
        
            <exactMatch>{for $exactMatch in $place//skos:exactMatch
            return string-join($exactMatch/@rdf:resource, " ")
                }</exactMatch>
      </items>
  }
  </list>
 </data>
 