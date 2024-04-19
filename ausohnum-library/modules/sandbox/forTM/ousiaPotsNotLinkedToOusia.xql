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

(:declare option exist:serialize "omit-xml-declaration=yes";:)

let $documents := collection("/db/apps/patrimoniumData/documents/")
let $places := collection("/db/apps/patrimoniumData/places/patrimonium")
let $ousiaPlots := doc("/db/apps/patrimoniumData/places/patrimonium/imports/ousiaPlots2020-06-05T11-55.xml")
let $tab := '&#9;' (: tab :)
let $nl := "&#10;"
let $query := $ousiaPlots//spatial:Feature
[.//spatial:P[@rdf:resource = ""]]

return
     
    <results>APCUri{$tab}Name in APC{$tab}URI of Ousia{$tab}souai ID{$tab}OusiaRefId{$nl}
{for $place in $query
            let $apcUriShort := substring-before($place/@rdf:about, "#this")
            let $spatialPs := $place//spatial:P
            let $ousiaUri := for $spatialP in $spatialPs
                let $ousiaPlace := $places//spatial:Feature[@rdf:about = $spatialP/@rdf:resource ||"#this"]
                let $placeStatus := $ousiaPlace//pleiades:hasFeatureType[@type="main"]/@rdf:resource/string()
                let $placeOusiaId := substring-after($ousiaPlace//skos:exactMatch[contains(./@rdf:resource, "ousia")]/@rdf:resource, "ousia/")
                return
                if($placeStatus = "https://ausohnum.huma-num.fr/concept/c23587")
                    then $spatialP/@rdf:resource/string() || $tab || $placeOusiaId else()
            return
                $apcUriShort 
                || $tab || $place//dcterms:title/text()
                || $tab || $ousiaUri[1]
                ||$tab || "ousiaRefId= " || substring-after($place//skos:hiddenLabel/@rdf:resource, "RefId/")
                || $nl
        }
        </results>