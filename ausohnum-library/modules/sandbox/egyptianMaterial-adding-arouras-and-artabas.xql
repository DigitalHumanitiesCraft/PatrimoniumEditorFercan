xquery version "3.1";

import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";

import module namespace functx="http://www.functx.com";


declare namespace lawd="http://lawd.info/ontology/";
declare namespace apc="http://patrimonium.huma-num.fr/onto#";
declare namespace foaf="http://xmlns.com/foaf/0.1/"; 
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#"; 
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ausohnum="http://ausonius.huma-num.fr/onto";
declare namespace spatial="http://geovocab.org/spatial#";
declare boundary-space preserve;

declare variable $tab := '&#9;';

let $plotsRaw := util:binary-to-string(util:binary-doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/landplots/ousia-plots.csv'))
let $plots := tokenize(replace($plotsRaw, '"', ''), "\r\n")
let $arourasRaw := util:binary-to-string(util:binary-doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/landplots/arouras-tab.txt'))
let $arouras := tokenize($arourasRaw, "\r")
let $artabasRaw := util:binary-to-string(util:binary-doc('xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/landplots/artabas-tab.txt'))
let $artabas := tokenize($artabasRaw, "\r")


let $docs := collection('xmldb:exist:///db/apps/patrimoniumData/documents/documents-ybroux')
let $places := collection('xmldb:exist:///db/apps/patrimoniumData/places/patrimonium/imports')
let $processArouras :=
    for $aroura at $pos in $arouras
        where $pos > 1 and $pos < 3
        let $arouraSplit := tokenize($aroura, "\t")
        let $ousia_ref := "https://www.trismegistos.org/ousiaRefId/" || $arouraSplit[1]
        let $apcPlace := $places//spatial:Feature[skos:exactMatch[@rdf:resource= $ousia_ref]]
        let $arouraValue := $arouraSplit[2]
        let $comment := $arouraSplit[3]
    let $node2Insert :=<data>
                    <apc:hasSize type="aroura" value="{$arouraValue}">{ $comment }</apc:hasSize></data>
    return
        (concat("Aroura ", $pos, ") ", "Place ", data($apcPlace/@rdf:about), " with "), serialize($node2Insert/node()),
        update insert $node2Insert/node() following $apcPlace//pleiades:Place//pleiades:hasFeatureType
        )
        
        
let $processArtabas :=
    for $artaba at $pos in $artabas
        let $artabasSplit := tokenize($artaba, "\t")
        let $ousia_ref := "https://www.trismegistos.org/ousiaRefId/" || $artabasSplit[1]
        let $apcPlace := $places//spatial:Feature[skos:exactMatch[@rdf:resource= $ousia_ref]]
        let $artabaValue := $artabasSplit[2]
        let $comment := $artabasSplit[3]
        let $node2Insert :=<data>
                        <apc:hasYield type="artabas" value="{$artabaValue}">{ $comment }</apc:hasYield></data>
        return
          (concat("Artabas ", $pos, ") ", "Place ", data($apcPlace/@rdf:about), " with "), serialize($node2Insert/node()),
        update insert $node2Insert/node() following $apcPlace//pleiades:Place//pleiades:hasFeatureType
        )  
return
    <result>
    {$processArouras}, { $processArtabas }
    </result>