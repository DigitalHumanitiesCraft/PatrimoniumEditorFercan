xquery version "3.1";

import module namespace functx="http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace dcterms = "http://purl.org/dc/terms/";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare boundary-space preserve;

let $corpusTEST := collection('/db/apps/gymnasiaData/documents/documents-vrazanajao')
let $corpusA := collection("/db/apps/gymnasiaData/documents/documents-ybroux")
let $places := collection("/db/apps/gymnasiaData/places/patrimonium")
return
   
    for $origPlace in $corpusTEST//tei:origPlace[@ref!=""]
    
        let $newNode :=
<origPlace>
                                <placeName type="ancient" ref="{ $origPlace/@ref}">{ $origPlace/text()}</placeName>
                            </origPlace>
        return update replace $origPlace with functx:change-element-ns-deep($newNode,
                                    "http://www.tei-c.org/ns/1.0", "")
        
            
    
   