(:~
: AusoHNum Library - spatial data manager module
: This function return the list of places linked to a document, serialized in Geo JSON. Used for leaflet maps.
: @author Vincent Razanajao
: @param project name
: @param document id
:)


xquery version "3.1";

(:import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "./spatiumStructor.xql";:)
import module namespace functx="http://www.functx.com";
import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "spatiumStructor.xql";
declare namespace json="http://www.json.org";

declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace http="http://expath.org/ns/http-client";

declare namespace lawdi="http://lawd.info/ontology/";
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

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

(:declare option exist:serialize "method=xml media-type=xml";:)
declare boundary-space strip;

declare option output:indent "yes";
(: Switch to JSON serialization :)


declare option output:method "json";
declare option output:media-type "text/json";


declare variable $project :=request:get-parameter('project', ());
declare variable $docId:=request:get-parameter('docId', ());
declare variable $library-path := "/db/apps/ausohnum-library/";
(:declare variable $places := collection("/db/apps/" || $project || "Data/places" || "/" || $project)//rdf:RDF;:)
declare variable $appVariables := doc("/db/apps/" || $project || "/data/app-general-parameters.xml");
(:declare variable $concept-collection:= collection("/db/apps/" || $appVariables//thesaurus-app/text() || "Data/concepts");:)
declare variable $concept-collection:= doc("/db/apps/" || $appVariables//thesaurus-app/text() || "Data/concepts/" || $project || ".rdf");

let $placeRefsInDoc := collection("/db/apps/" || $spatiumStructor:project || "Data/documents" )/id($docId)//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace
let $placeGazetteer := doc("/db/apps/" || $spatiumStructor:project || "Data/places/project-places-gazetteer.xml")



return 

    <root json:array="true" type="FeatureCollection">{
        for $place in $placeRefsInDoc//tei:place
            let $projectPlaceUri := 
                    let $splitRef := tokenize(data($place/tei:placeName/@ref), " ")
                    return 
                        for $uri in $splitRef
                        return
(:                                                          string-join($uri, "-->"):)
                        if(matches($uri, $spatiumStructor:uriBase)) then 
                        normalize-space($uri[1]) else ()
            let $feature := $placeGazetteer//features[properties/uri/text() = $projectPlaceUri ]
            let $builtFeature := <features type="Feature">
                    <properties><name>{$feature/properties/name/text()}</name><uri>{$feature/properties/uri/text()}</uri><id>{$feature/properties/id/text()}</id><placeType>{$feature/properties/placeType/text()}</placeType><placeTypeUri>{$feature/properties/placeTypeUri/text()}</placeTypeUri><productionType>{$feature/properties/productionType/text()}</productionType><icon>{$feature/properties/icon/text()}</icon><amenity>{$feature/properties/amenity/text()}</amenity><popupContent>{$feature/properties/popupContent/text()}</popupContent></properties><style><fill>red</fill><fill-opacity>1</fill-opacity></style><geometry><type>MultiPoint</type>{$feature//coordList/node()}</geometry></features>
        return 
            $feature
    }   
    {
    
    if(count($placeRefsInDoc//tei:place) = 1) then <features type="Feature"></features> else()
    }
    </root>