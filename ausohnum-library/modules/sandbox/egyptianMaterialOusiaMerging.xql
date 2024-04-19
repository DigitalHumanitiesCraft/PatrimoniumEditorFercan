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
    
let $logs := doc('xmldb:exist:///db/apps/patrimoniumData/logs/logs-import-egyptianMaterial.xml')
let $teiTemplate := doc("xmldb:exist:///db/apps/patrimonium/data/teiEditor/docTemplates/teiTemplatePatrimoniumEgypt.xml")
let $collectionPrefix := "apcd"
let $egyptianPlaces := doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/egyptianMaterialPlaces.xml")
let $ousiaList:= doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/ousiaList.xml")
let $geoToOusiaRaw := util:binary-to-string(util:binary-doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/cleaning-ousia/geoToOusia.csv"))
let $geoToOusia := tokenize(replace($geoToOusiaRaw, '"', ''), "\r\n")
let $doc-collection-path := "xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/forFinal/docs"
let $project-places-collection := collection("xmldb:exist:///db/apps/patrimoniumData/places/patrimonium")
let $egyptianMaterial-peopleList := doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/meta/peopleProv4import.xml")
let $egyptianMaterial-peopleRecords := collection("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/forFinal/meta")

(:let $createOusiaList ::)
(:<ousiaList>:)
(:        {:)
(:    for $record at $pos in $geoToOusia:)
(:        :)
(:(:        where count($record) >1:):)
(:        let $tmNo := tokenize($record, ',')[1]:)
(:        let $tmUri := "https://www.trismegistos.org/place/" || $tmNo:)
(:        let $ousiaNo := tokenize($record, ',')[2]:)
(:        let $apcNo := data($egyptianPlaces//spatial:Feature[skos:exactMatch[@rdf:resource = $tmUri]]/@rdf:about):)
(:        return :)
(:        <ousia xml:id="{$ousiaNo}">:)
(:        <ousiaNo>{$ousiaNo}</ousiaNo>:)
(:        <tmNo>{ $tmNo}</tmNo>:)
(:        <apcNo>{ substring-before($apcNo, "#this") }</apcNo>:)
(:    </ousia>:)
(:        }:)
(:</ousiaList>:)

let $items := 
    
    <result xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
    {functx:distinct-deep(
        for $record at $pos in $geoToOusia
        
        let $ousiaNo :=tokenize($record, ',')[2]
        let $ousiaRecord := $ousiaList//ousia[ousiaNo/text() = $ousiaNo]
        let $apcAsouiaMaster := $ousiaRecord[1]//apcNo/text()|| "#this"
        let $ousia2beRemoved := $ousiaRecord[position()>1]
        
        let $node2beDeleted := for $item in $ousia2beRemoved//apcNo
                                    where $item/text() !=""
                                    return (<node2Merge rdf:resource="{ $item/text()}"/>)
        
        let $exactMatches2Include := for $item in $ousia2beRemoved/tmNo
(:                                    where $item/apcNo/text() !="":)
                       
                                    return (<skos:exactMatch rdf:resource="https://www.trismegistos.org/place/{ $item/text()}"/>)
        
        
        let $processMultipleOusia :=
            if (count($ousiaRecord) >1)
                then
                    
                    <item ousiaNo="{ $ousiaNo }" apcNo="{ $apcAsouiaMaster }">{
            $exactMatches2Include
            }
            {$node2beDeleted}
            </item>              
                        
       
                    
                else()
        return
            
            $processMultipleOusia
       
        )
        
    }
    </result>

(:let $insertExactMatchInMaster :=:)
(:        for $item in $items//item:)
(:        where string-length($item/@apcNo) >6:)
(:        let $apcRecord := $egyptianPlaces//spatial:Feature[@rdf:about = $item/@apcNo]:)
(:        :)
(:        return :)
(:            update insert   :)
(:            $item/node() following $apcRecord//skos:exactMatch:)
            
return  $items