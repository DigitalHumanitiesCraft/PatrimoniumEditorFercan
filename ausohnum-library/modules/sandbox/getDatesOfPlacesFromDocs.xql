xquery version "3.1";


import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" 
at "/db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";
import module namespace functx="http://www.functx.com";
(:import module namespace spatiumStructor="http://ausonius.huma-num.fr/spatiumStructor" at "/db/apps/ausohnum-library/modules/spatiumStructor/spatiumStructor.xql";:)
(:import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons" at "/db/apps/ausohnum-library/modules/commons/commonsApp.xql";:)

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
declare namespace local = "local";

let $productionUnits := skosThesau:getChildren("https://ausohnum.huma-num.fr/concept/c21870", "patrimonium")
let $productionUnitsList := for $prodUnit in $productionUnits//skos:Concept
                return data($prodUnit/@rdf:about)
let $tab := '&#9;'
let $places:= collection("/db/apps/patrimoniumData/places/patrimonium")
let $gazetteer := doc("/db/apps/patrimoniumData/places/project-places-gazetteer.xml")
let $doc-collection:= collection("/db/apps/patrimoniumData/documents")
let $results:=
    for $place in $places//pleiades:Place
        let $placeType := data($place//pleiades:hasFeatureType[@type="main"]/@rdf:resource)
        return
            if(not(contains($productionUnitsList, $placeType))) then ()
            else
                let $placeUri := data($place/@rdf:about)
                let $placeInGazetteer := $gazetteer//features[.//uri = $placeUri]
                let $placeName := normalize-space($place//dcterms:title/text())
                let $productionTypeUri := data($place//pleiades:hasFeatureType[@type="productionType"][1]/@rdf:resource)               
                let $productionType:= for $item at $pos in $productionTypeUri
                        return 
                            skosThesau:getLabel($item, "en", "patrimonium") || (if($pos < count($productionTypeUri)) then "|" else ())
                let $province:=$placeInGazetteer//provinceName/text()
                let $relatedDocs :=  for $doc in $doc-collection//tei:placeName[contains(./@ref, $placeUri)]
                        return root($doc)
                
                let $origDates := $relatedDocs//tei:origDate
                let $dateBefore :=
                        for $date in $origDates
                                return
                                    if($date/@notBefore-custom)
                                        then replace($date/@notBefore-custom, "\?", "")
                                        else if($date/@notBefore) then replace($date/@notBefore, "\?", "")
                                        else ()
                 let $dateAfter := 
                       for $date in $origDates
                                return
                                    if($date/@notAfter-custom)
                                            then replace($date/@notAfter-custom, "\?", "")
                                            else if($date/@notAfter) then replace($date/@notAfter, "\?", "")
                                            else ()
               let $dateRange :=
                (min($dateBefore), max($dateAfter))
                
            return '&#xa;' || $placeName || $tab || $placeUri || $tab || $province || $tab || $productionType || $tab || $dateRange[1] || $tab || $dateRange[2]

return <results>{$results}</results>