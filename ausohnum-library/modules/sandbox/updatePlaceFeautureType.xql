xquery version "3.1";

import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#"; 
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ausohnum="http://ausonius.huma-num.fr/onto";
declare namespace spatial="http://geovocab.org/spatial#";

declare option exist:serialize "omit-xml-declaration=yes";

let $documents := collection("/db/apps/patrimoniumData/documents/")
let $places := collection("/db/apps/patrimoniumData/places/patrimonium")
let $placesForQuery:= doc("/db/apps/patrimoniumData/places/patrimonium/imports/ousiaPlots2020-06-05T11-55.xml")

return for $item in $placesForQuery//pleiades:hasFeatureType[@type="main"][@rdf:resource = "https://ausohnum.huma-num.fr/concept/c26406"]
(:            let $doSomething := :)
(:                if(starts-with($item//dcterms:title, "Imperial flock attached to ousia")) then ():)
(:                else:)
                    return
                    (update value $item/@rdf:resource with "https://ausohnum.huma-num.fr/concept/c21971",
                    update value $item/text() with "Storage buildings")
(:            let $updateTextNode := update value $item//pleiades:hasFeatureType[@type="main"]/text() with "Flock":)
(:        return $item:)
        