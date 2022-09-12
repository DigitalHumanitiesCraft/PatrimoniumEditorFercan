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
let $adminType := ("https://ausohnum.huma-num.fr/concept/c22264", "https://ausohnum.huma-num.fr/concept/c26346",
                "https://ausohnum.huma-num.fr/concept/c26368", "https://ausohnum.huma-num.fr/concept/c26369")
(:                province, Egyptian nomos, Egyptian meris, toparchy:)

let $landplots := ("https://patrimonium.huma-num.fr/places/55030#this ", "https://patrimonium.huma-num.fr/places/55058#this ", "https://patrimonium.huma-num.fr/places/55066#this ", "https://patrimonium.huma-num.fr/places/55136#this ", "https://patrimonium.huma-num.fr/places/55233#this ", "https://patrimonium.huma-num.fr/places/55245#this ", "https://patrimonium.huma-num.fr/places/55348#this ", "https://patrimonium.huma-num.fr/places/55362#this ", "https://patrimonium.huma-num.fr/places/55396#this ", "https://patrimonium.huma-num.fr/places/55401#this ", "https://patrimonium.huma-num.fr/places/55411#this ", "https://patrimonium.huma-num.fr/places/55412#this ", "https://patrimonium.huma-num.fr/places/55458#this ", "https://patrimonium.huma-num.fr/places/55509#this ", "https://patrimonium.huma-num.fr/places/55538#this ", "https://patrimonium.huma-num.fr/places/55612#this ", "https://patrimonium.huma-num.fr/places/55613#this ", "https://patrimonium.huma-num.fr/places/55615#this ", "https://patrimonium.huma-num.fr/places/55616#this ", "https://patrimonium.huma-num.fr/places/55655#this ", "https://patrimonium.huma-num.fr/places/55664#this ", "https://patrimonium.huma-num.fr/places/55666#this ", "https://patrimonium.huma-num.fr/places/55686#this ", "https://patrimonium.huma-num.fr/places/55689#this ", "https://patrimonium.huma-num.fr/places/55734#this ", "https://patrimonium.huma-num.fr/places/55752#this ", "https://patrimonium.huma-num.fr/places/55753#this ", "https://patrimonium.huma-num.fr/places/55754#this ", "https://patrimonium.huma-num.fr/places/55755#this ", "https://patrimonium.huma-num.fr/places/55756#this ", "https://patrimonium.huma-num.fr/places/55757#this ", "https://patrimonium.huma-num.fr/places/55758#this ", "https://patrimonium.huma-num.fr/places/55759#this ", "https://patrimonium.huma-num.fr/places/55760#this ", "https://patrimonium.huma-num.fr/places/55761#this ", "https://patrimonium.huma-num.fr/places/55762#this ", "https://patrimonium.huma-num.fr/places/55763#this ", "https://patrimonium.huma-num.fr/places/55764#this ", "https://patrimonium.huma-num.fr/places/55765#this ", "https://patrimonium.huma-num.fr/places/55766#this ", "https://patrimonium.huma-num.fr/places/55767#this ", "https://patrimonium.huma-num.fr/places/55768#this ", "https://patrimonium.huma-num.fr/places/55769#this ", "https://patrimonium.huma-num.fr/places/55770#this ", "https://patrimonium.huma-num.fr/places/55790#this ", "https://patrimonium.huma-num.fr/places/55791#this ", "https://patrimonium.huma-num.fr/places/55803#this ", "https://patrimonium.huma-num.fr/places/55809#this ", "https://patrimonium.huma-num.fr/places/55866#this ", "https://patrimonium.huma-num.fr/places/55904#this ", "https://patrimonium.huma-num.fr/places/55905#this ", "https://patrimonium.huma-num.fr/places/55906#this ", "https://patrimonium.huma-num.fr/places/55911#this ", "https://patrimonium.huma-num.fr/places/55931#this ", "https://patrimonium.huma-num.fr/places/55969#this ", "https://patrimonium.huma-num.fr/places/56026#this ", "https://patrimonium.huma-num.fr/places/56037#this ", "https://patrimonium.huma-num.fr/places/56039#this ", "https://patrimonium.huma-num.fr/places/56046#this ", "https://patrimonium.huma-num.fr/places/56050#this ", "https://patrimonium.huma-num.fr/places/56060#this ", "https://patrimonium.huma-num.fr/places/56189#this ", "https://patrimonium.huma-num.fr/places/56197#this ", "https://patrimonium.huma-num.fr/places/56238#this ", "https://patrimonium.huma-num.fr/places/56286#this ", "https://patrimonium.huma-num.fr/places/56294#this ", "https://patrimonium.huma-num.fr/places/56304#this ", "https://patrimonium.huma-num.fr/places/56331#this")

                
let $processPlace :=
        for $place in $placesForQuery//spatial:Feature
            let $uri := substring-before($place/@rdf:about, "#this")
            let $docs := $documents//tei:TEI[.//tei:placeName[@ref=$uri]]
            
            return 
                if(count($docs) =0) then 
                <place uri="{$uri}"/>
                else ()
    
    return
        <results count="{count($processPlace)}">{ $processPlace }</results>