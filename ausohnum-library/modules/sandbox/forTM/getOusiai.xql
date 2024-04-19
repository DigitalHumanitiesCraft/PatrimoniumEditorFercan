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
let $tab := '&#9;' (: tab :)
let $nl := "&#10;"
let $query := $places//spatial:Feature[.//skos:exactMatch[contains(./@rdf:resource, "ousia")]]

return 
    <results>
        {for $place in $query
            let $ousiaUri := $place//skos:exactMatch[contains(./@rdf:resource, "ousia")]/@rdf:resource
            let $apcUriShort := substring-before($place/@rdf:about, "#this")
            let $landdplotsNo := count($places//spatial:Feature[.//spatial:P[@rdf:resource= $apcUriShort]])
            order by number(substring-after($ousiaUri, "/ousia/"))
            return
                $ousiaUri || $tab || $apcUriShort 
                || $tab || $place//dcterms:title/text()
                || $tab || $landdplotsNo
                || $nl
        }
        </results>
    
    