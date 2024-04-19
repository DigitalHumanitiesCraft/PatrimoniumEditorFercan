xquery version "3.1";

import module namespace functx="http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace dcterms = "http://purl.org/dc/terms/";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace local = "local";
declare boundary-space preserve;

declare function local:removeTEIns($nodes){
    functx:change-element-ns-deep($nodes, "http://www.tei-c.org/ns/1.0", "")
};

let $corpusTEST := collection('/db/apps/gymnasiaData/documents/documents-vrazanajao')
let $corpusA := collection("/db/apps/gymnasiaData/documents/documents-ybroux")
let $places := collection("/db/apps/gymnasiaData/places/patrimonium")
return
    <results>{
    for $doc in ($corpusTEST//tei:TEI[.//tei:history/tei:provenance/tei:location/tei:placeName/@ref =""][.//tei:origPlace[@ref!=""]])
        let $origin := $doc//tei:history/tei:origin/tei:origPlace 
        
        let $originPlaceUri :=
            for $uri in tokenize($origin/ref, " ")
                return 
                    if(contains($uri, "gymnasia")) then $uri else ()
        let $originPlacename := normalize-space($origin/text())
        let $originPlaceUris := normalize-space($origin/@ref)
(:UPdate listPlace        :)
        
        let $updateListPlace :=
            if(not(exists($doc//tei:sourceDesc/tei:listPlace)))
                then
                        let $newListPlace := <node>
                        <tei:listPlace>
                            <place>
                                <placeName ref="{ $originPlaceUris }" ana="provenance">{ $originPlacename }</placeName>
                            </place>
                        </tei:listPlace>
                        </node>
                    return
                    update insert functx:change-element-ns-deep($newListPlace/node(), "http://www.tei-c.org/ns/1.0", "")  into $doc//tei:sourceDesc
                else if (exists($doc//tei:placeName[@ana="provenance"]))
                    then
                        (update value $doc//tei:placeName[@ana="provenance"]/@ref with $originPlaceUris,
                         update value $doc//tei:placeName[@ana="provenance"]/text() with $originPlacename
                        )
                else()
        let $updateProvenancePlacename:=
        if($originPlacename!="")
            then
                (
                    if(exists($doc//tei:msDesc/tei:history/tei:provenance/tei:location/tei:placeName)) then
                    (update value $doc//tei:msDesc/tei:history/tei:provenance/tei:location/tei:placeName with $originPlacename,
                    update value $doc//tei:msDesc/tei:history/tei:provenance/tei:location/tei:placeName/@ref with $originPlaceUris
                    )
                else if(exists($doc//tei:msDesc/tei:history/tei:provenance/tei:location)) then
                     (update insert <placeName ref="{ $originPlaceUris }">{ $originPlacename }</placeName> into $doc//tei:msDesc/tei:history/tei:provenance/tei:location)
                else if(exists($doc//tei:msDesc/tei:history/tei:provenance)) then
                        let $newLocation := <node>
                        <location>
                            <placeName ref="{ $originPlaceUris }">{ $originPlacename }</placeName>
                        </location>
                        </node>
                        return
                     (update insert functx:change-element-ns-deep($newLocation/node(), "http://www.tei-c.org/ns/1.0", "") into $doc//tei:msDesc/tei:history/tei:provenance)
                  
                 else()
                )
            else()
             
(:        let $placeInList:= $doc//tei:listPlace//tei:placeName[@ana="provenance"]:)
(:        let $placeUri :=normalize-space($placeInList/@ref):)
(:        let $placeRecord := $places//spatial:Feature[./@rdf:about=$placeUri || "#this"]:)
(:        let $placeName := $placeRecord//dcterms:title[1]/text():)
       

(:        let $updateDocPlaceName:= if($placeName!="") then update value $doc//tei:history/tei:provenance/tei:location/tei:placeName with $placeName else ():)
(:        let $updateDocPlaceRef:= if($placeUris!="") then update value $doc//tei:history/tei:provenance/tei:location/tei:placeName/@ref with $placeUris else ():)
         
       let $newOrigPlace := 
                            <origPlace>
                                <placeName type="ancient" ref="{ $originPlaceUris }">{ $originPlacename }</placeName>
                            </origPlace>
                           
        let $updateOrigPlace :=
         update replace $doc//tei:origPlace with functx:change-element-ns-deep($newOrigPlace, "http://www.tei-c.org/ns/1.0", "")
        
    
    return "Doc " || data($doc/@xml:id) 
        || " " ||
        (if($originPlacename!="") then " updated with placename " || $originPlacename 
                            else "NOT uptdated for placename ")
        || (if($originPlaceUris!="") then " updated with place uris " || $originPlaceUris 
                            else "NOT uptdated for place uris") || '&#xa;'               
    }</results>