xquery version "3.1";

import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare namespace lawd="http://lawd.info/ontology/";
declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#"; 
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ausohnum="http://ausonius.huma-num.fr/onto";
declare namespace spatial="http://geovocab.org/spatial#";
declare boundary-space preserve;

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
let $projectdata-path := "xmldb:exist:///db/apps/patrimoniumData/"
let $dumpfile := util:binary-to-string(util:binary-doc(
    "xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/meta/tm-geo-dump.csv"))
let $tmDataType     := "geo"
let $items := tokenize($dumpfile, ';\r')    
let $headers := tokenize($items[1], ',')

let $indexStart := 19611
let $indexEnd := 19639

let $data :=
        <tmdata xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
        date="{$now}" creator="{ $currentUser }">
    {
         for $item at $posItem in $items
         where $posItem > $indexStart
         and $posItem < $indexEnd
         let $itemDetails := tokenize($item, '","')
         
         return
        <item xml:id="{$tmDataType}{substring-after($itemDetails[1], '"')}"
             rdf:about="https://www.trismegistos.org/{$tmDataType}/{substring-after($itemDetails[1], '"')}">
        {
                 for $column at $colPos in $itemDetails
                 return
                     element
                     {
                         if(functx:substring-before-last(substring-after($headers[$colPos], '"'), '"') != "") 
                         then functx:substring-before-last(substring-after($headers[$colPos], '"'), '"')
                         else "element"
                     } { if ($colPos =1) then substring-after($column, '"')
                        else if ($colPos = count($itemDetails)) then substring-before($column, '"')
                        else $column
                    }
                    
    }
    </item>
        }
</tmdata>

return
    (
(:    $data,:)
    xmldb:store($projectdata-path || "egyptianMaterial/meta/" || $tmDataType,
            "tmData-" || $tmDataType || "-" || $indexStart || "-to-" || $indexEnd || "-"
            || substring(replace($now, ":", "-"), 1, 16) || ".xml", $data)
    )



