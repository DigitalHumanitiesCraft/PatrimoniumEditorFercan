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
declare namespace apc="http://patrimonium.huma-num.fr/onto#";
let $tab := '&#9;' (: tab :)
let $nl := "&#10;"
let $places := collection("/db/apps/patrimoniumData/places/patrimonium/")
let $yieldCommentsCsv := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/landplots/yields-comments.csv"))
let $yieldCommentsXml :=  
    <comments>
        {for $item at $pos in tokenize(replace($yieldCommentsCsv, '"', ''), "\n")
        where $pos >1
        let $details := tokenize($item, $tab)
        return
            if($details[5] != "") then
                    <comment apcPlace="https://patrimonium.huma-num.fr/places/{$details[1]}" comment="{$details[5]}"/>
                    else()
}</comments>
let $sizesCommentsCsv := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/landplots/sizesComments.csv"))
let $sizesCommentsXml :=  
    <comments>
        {for $item at $pos in tokenize(replace($sizesCommentsCsv, '"', ''), $nl)
        where $pos >1
        let $details := tokenize($item, $tab)
        let $apcPlaceUri := (
                     substring-before(
                        $places//spatial:Feature[.//skos:hiddenLabel[equals(./@rdf:resource, "https://www.trismegistos.org/ousiaRefId/" || $details[1])]]/@rdf:about
                        , "#this"))
        return
            if($details[3] != "") then
                    <comment ousiaRefId="{ $details[1]}" apcPlace="{ $apcPlaceUri }" comment="{$details[3]}"/>
                    else()
}</comments>

return 
    
    <result count="{count($sizesCommentsXml//comment)}">
    {
    for $item in $sizesCommentsXml//comment
        let $place := $places//pleiades:Place[@rdf:about = $item/@apcPlace]
        return
            (
            update value $place//apc:hasSize with $item/@comment/string(),
            
            $item/@apcPlace/string() || $tab || $item/@ousiaRefId/string() || $tab || $item/@comment /string()||$nl
            )
    }
    </result>
