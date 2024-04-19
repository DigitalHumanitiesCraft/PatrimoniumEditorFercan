xquery version "3.1";
import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";

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
    
(:let $logs := doc('xmldb:exist:///db/apps/patrimoniumData/logs/logs-import-egyptianMaterial.xml'):)

let $collectionPrefix := "apcd"
let $egyptianPlaces := doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/egyptianMaterialPlaces.xml")
let $ousiaList:= doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousiaList.xml")
let $geoToOusiaRaw := util:binary-to-string(util:binary-doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/geoToOusia.csv"))
let $geoToOusia := tokenize(replace($geoToOusiaRaw, '"', ''), "\r\n")
let $exactMatchList := doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/exactMatchList.xml")

let $doc-collection-path := "xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/forFinal/docs"
let $project-places-collection := collection("xmldb:exist:///db/apps/patrimoniumData/places/patrimonium")
let $egyptianMaterial-peopleList := doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/meta/peopleProv4import.xml")
let $egyptianMaterial-peopleRecords := collection("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/forFinal/meta")
let $docs := collection("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/docs")
let $nl := '&#xa;'
return
(:   let $insertTMExactMatch := :)
(:    for $item in $exactMatchList//item:)
(:        where string-length($item/@apcNo) >6:)
(:        let $apcRecord := $egyptianPlaces//spatial:Feature[@rdf:about = $item/@apcNo]:)
(:        let $node2Insert := <node> :)
(:             {$item/skos:exactMatch}</node>:)
(:        return :)
(:(:            $item//skos:exactMatch:):)
(:            update insert   :)
(:            $node2Insert/node() following $apcRecord//skos:exactMatch:)
 
(: let $deleteExtraPlaces :=   for $item in $exactMatchList//node2Merge:)
(:        let $apcUri := $item/@rdf:resource || "#this":)
(:        return :)
(:(:            $item//skos:exactMatch:):)
(:            update delete $egyptianPlaces//rdf:RDF[spatial:Feature[@rdf:about = $apcUri]]   :)
(:            :)
          
    <result>{
    for $item in $exactMatchList//node2Merge
        let $uriToBeChanged := $item/@rdf:resource
        let $apcUri := substring-before($item/parent::item/@apcNo, "#this")
        let $updateRefInDocs := if($apcUri = "") then (
            "This uri " || $uriToBeChanged || " for ousia " || $item/parent::item/@ousiaNo || " has not been changed" || $nl)
            else (
                for $ref in $docs//@ref[. = $uriToBeChanged]
                    let $docId := $ref/ancestor::tei:TEI/@xml:id
                    let $updateData := update value $ref with $apcUri
                    
                    return
                        "Change " || $uriToBeChanged || " with " || $apcUri || " in doc " || $docId || $nl
                
                )
        
        return
            
            $updateRefInDocs
            
    }</result>