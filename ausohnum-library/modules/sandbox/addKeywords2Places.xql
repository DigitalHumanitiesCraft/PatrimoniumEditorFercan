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
let $egyptianPlace1stImport := doc("/db/apps/patrimoniumData/egyptianMaterial/places/egyptianPlaces1stImport.xml")
let $ousiaRef2ousiaCsv := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/places/ousiaRef_to_ousia.csv"))
let $ousiaRef2ousiaXml :=  
    <ousia>
        {for $item in tokenize(replace($ousiaRef2ousiaCsv, '"', ''), "\r")
        return <ousia refId="{tokenize($item, ",")[1]}" ousiaId="{tokenize($item, ",")[2]}"/>
}</ousia>
let $ousiaref_georefCsv := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/places/ousiaref_georef.csv"))
let $ousiaref_georefXML :=  
    <landplots>
        {for $item in tokenize(replace($ousiaref_georefCsv, '"', ''), "\r")
        return <landplot ousiaRefId="{tokenize($item, ",")[1]}" geoRef="{tokenize($item, ",")[2]}"/>
}</landplots>
let $ousiaRef_keywordsCsv := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/places/ousiaRef_keywords.csv"))
let $ousiaRef_keywordsXml :=  
    <ousia>
        {for $item in tokenize(replace($ousiaRef_keywordsCsv, '"', ''), "\r")
        return <ousia ousiaRefId="{tokenize($item, ",")[1]}" type="{tokenize($item, ",")[2]}"/>
}</ousia>
let $apcKeywordsCsv := util:binary-to-string(util:binary-doc("/db/apps/patrimoniumData/egyptianMaterial/keywords/keywordsList-tabs.txt"))
let $apcKeywords := <apcKeywords>
        {for $item at $pos in tokenize($apcKeywordsCsv, "\r")
        where $pos > 1
        let $itemDetails := tokenize($item, "\t")
        return <keyword tmId="{normalize-space($itemDetails[1])}" tmTerm="{normalize-space($itemDetails[2])}"
        apcTerm="{normalize-space($itemDetails[3])}" apcUri="{normalize-space($itemDetails[4])}"
        certainty="{normalize-space($itemDetails[5])}" docRelated="{normalize-space($itemDetails[6])}"/>
        }</apcKeywords>
 
let $query := $placesForQuery//spatial:Feature
let $processData :=  
        for $item in $query
            
            let $ousiaRefId := substring-after($item//skos:hiddenLabel[contains(@rdf:resource, "/ousiaRefId/")]/@rdf:resource, "/ousiaRefId/")
            let $itemGeoRef := $ousiaref_georefXML//landplot[@ousiaRefId = $ousiaRefId]/@geoRef/string()
            let $ousiaID := $ousiaRef2ousiaXml//ousia[@refId = $ousiaRefId]/@ousiaId
            let $ousiaTMURI := "https://www.trismegistos.org/ousia/" || $ousiaID[1]
            let $ousiaType:= $ousiaRef_keywordsXml//ousia[@ousiaRefId = $ousiaRefId]/@type 
            let $landplotType := switch ($ousiaType)
                            case "unknown" return (<pleiades:hasFeatureType type="main" rdf:resource="https://ausohnum.huma-num.fr/concept/c22226">Estate</pleiades:hasFeatureType>)
                            case "animals; sheep" case "animals; donkeys" return <pleiades:hasFeatureType type="main" rdf:resource="https://ausohnum.huma-num.fr/concept/c2187">Production units</pleiades:hasFeatureType>
                            default return <pleiades:hasFeatureType type="main" rdf:resource="https://ausohnum.huma-num.fr/concept/c21871">Landed estate</pleiades:hasFeatureType>
            
            let $retrieveKeywords :=
                    for $keyword in tokenize($ousiaType, "; ")
                    let $matchApcTerm := $apcKeywords//keyword[@tmTerm=$keyword]/@apcTerm/string()
                    let $matchApcUri := "https://ausohnum.huma-num.fr/concept/" || $apcKeywords//keyword[@tmTerm=$keyword]/@apcUri/string()
                    let $certainty := $apcKeywords//keyword[@tmTerm=$keyword]/@certainty/string()
                    let $docRelated := $apcKeywords//keyword[@tmTerm=$keyword]/@docRelated/string()
                    return 
(:                        if($keyword = "unknown") then ():)
(:                        else if ($docRelated !="") then ():)
(:                        else if($certainty = "low") then <pleiades:hasFeatureType type="productionType" rdf:resource="{ $matchApcUri }" certainty="low"/>:)
(:                            else:)
(:                        <pleiades:hasFeatureType rdf:resource="{ $matchApcUri }" type="productionType"/>:)
                    if($keyword = "garden land")
                    then
                        <dcterms:subject rdf:resource="https://ausohnum.huma-num.fr/concept/c23695">Gardens</dcterms:subject>
                        else()
        let $insertKeyword :=
            for $keyword in $retrieveKeywords
                return
                if($item//pleiades:hasFeatureType[functx:contains-any-of(./@rdf:resource, $keyword/@rdf:resource)])
                
                    then 
                "Keyword already inserted" else
(:                    let $insertKeyword :=:)
(:           update insert $keyword into $item//pleiades:Place:)
(:                    return:)
                    "Keyword " || $keyword/@rdf:resource/string() || " inserted"
       
       let $placeLight :=
                <place rdf:about="{$item/@rdf:about/string()}" name="{ $item//dcterms:title/text() }">
                        
                        <type>{ $ousiaType/string() }</type>
                        
                       
                        <keywords>{ $retrieveKeywords }</keywords>
                        <insertOrNot>{ $insertKeyword }</insertOrNot>
              </place>
       
        return
            $placeLight
    
    
    return 
        
        <result xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:pleiades="https://pleiades.stoa.org/places/vocab#"
            places="{ count($processData//.[contains(./insertOrNot, "Key")]) }" keywords="">{ $processData//.[contains(./insertOrNot, "Key")] }</result>