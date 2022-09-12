xquery version "3.1";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace dcterms = "http://purl.org/dc/terms/";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

let $corpusTEST := collection('/db/apps/patrimoniumData/trash/documents-test')
let $corpus := collection("/db/apps/patrimoniumData/documents/documents-ybroux")
let $places := collection("/db/apps/patrimoniumData/places/patrimonium")
return
    <results>{
    for $doc in $corpus//tei:TEI[.//tei:history/tei:provenance/tei:location/tei:placeName/@ref =""]
        let $placeInList:= $doc//tei:listPlace//tei:placeName[@ana="provenance"]
        let $placeUri :=normalize-space($placeInList/@ref)
        let $placeRecord := $places//spatial:Feature[./@rdf:about=$placeUri || "#this"]
        let $placeName := $placeRecord//dcterms:title[1]/text()
        let $placeUris := $placeUri || (
        if($placeRecord//skos:exactMatch[1]/@rdf:resource!="") then ( " " || string-join($placeRecord//skos:exactMatch/@rdf:resource, " ") )else  ())
        let $updateDocPlaceName:= if($placeName!="") then update value $doc//tei:history/tei:provenance/tei:location/tei:placeName with $placeName else ()
        let $updateDocPlaceRef:= if($placeUris!="") then update value $doc//tei:history/tei:provenance/tei:location/tei:placeName/@ref with $placeUris else ()
         
        
    
    return "Doc " || data($doc/@xml:id) 
        || " " ||
        (if($placeName!="") then " updated with placename " || $placeName 
                            else "NOT uptdated for placename")
        || (if($placeUris!="") then " updated with place uris " || $placeUris 
                            else "NOT uptdated for place uris") || '&#xa;'               
    }</results>