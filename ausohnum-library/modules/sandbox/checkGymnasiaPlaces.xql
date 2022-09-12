xquery version "3.1";

import module namespace functx="http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace dcterms = "http://purl.org/dc/terms/";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
let $nl := '&#xa;'
let $corpusTEST := collection('/db/apps/gymnasiaData/documents/documents-vrazanajao')
let $corpus := collection("/db/apps/gymnasiaData/documents")
let $places := collection("/db/apps/gymnasiaData/places/gymnasia")
let $placeList:= doc("/db/apps/gymnasiaData/places/gymnasia/list.xml")

return
string-join(    
for $placeInList in $placeList//pleiades:Place
    let $formerUri := data($placeInList/@rdf:about)
    let $placenameFr := $placeInList//skos:prefLabel[@xml:lang="fr"]/text()
    let $placenameEn := $placeInList//skos:prefLabel[@xml:lang="en"]/text()
    let $placenameDe := $placeInList//skos:prefLabel[@xml:lang="de"]/text()
    
    let $placeInGazetteerWithSameUri := $places//pleiades:Place[@rdf:about = $formerUri]
    let $sameUriPlacename := $placeInGazetteerWithSameUri//dcterms:title/text()
    let $exactMatch := $placeInList//skos:exactMatch/@rdf:resource/string()
    
    let $uriInGazetteerFromExactMatch := substring-before($places//spatial:Feature[.//skos:exactMatch[@rdf:resource = $exactMatch]]/@rdf:about, "#this")
    let $uriInGazetteerFromPlacename :=substring-before($places//spatial:Feature[contains(.//dcterms:title, $placenameEn)][1]/@rdf:about, "#this")
    let $mentionsFormerUri :=
        for $mention in $corpus//@ref[contains(., $formerUri)]/ancestor::tei:TEI/@xml:id/string()
        return $mention
    let $uriInGazetteer :=
        if($uriInGazetteerFromExactMatch!="") then $uriInGazetteerFromExactMatch || " :eatch"
        else if($uriInGazetteerFromPlacename!="") then $uriInGazetteerFromPlacename || " :placename" 
        else () 
    
    return
       if($placeInGazetteerWithSameUri) then 
            
        $formerUri || " (" || $placenameEn || " | " 
        || "" ||
       ( if($placeInGazetteerWithSameUri) then  $sameUriPlacename else "---" )
        ||" = " || $exactMatch || " --> " || $uriInGazetteer || " mentions former URI: " || string-join($mentionsFormerUri, " ")
        else()
    , $nl || $nl)
            
    