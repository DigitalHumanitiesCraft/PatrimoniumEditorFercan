xquery version "3.1";



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
        
(:let $query := $places//spatial:Feature[.//dcterms:title[contains(./text(), "plot of  (")]]:)
let $query := $places//spatial:Feature[.//dcterms:title[contains(./text(), "Land plot of")]]
let $processData :=  
    <results count="{ count($query) }">{
        for $item in $query
            
            let $ousiaRefId := substring-after($item//skos:exactMatch/@rdf:resource, "/ousiaRefId/")
            let $itemGeoRef := $ousiaref_georefXML//landplot[@ousiaRefId = $ousiaRefId]/@geoRef/string()
            let $ousiaID := $ousiaRef2ousiaXml//ousia[@refId = $ousiaRefId]/@ousiaId
            let $ousiaTMURI := "https://www.trismegistos.org/ousia/" || $ousiaID[1]
            let $ousiaType:= $ousiaRef_keywordsXml//ousia[@ousiaRefId = $ousiaRefId]/@type 
            
            let $origOusiaUri := $item//spatial:P[not(./@rdf:resource="https://patrimonium.huma-num.fr/places/1031")][1]/@rdf:resource/string()||"#this"
            let $origLandPlotNomos := $item//spatial:C[not(./@rdf:resource="https://patrimonium.huma-num.fr/places/1031")][1]/@rdf:resource/string()||"#this"
            let $nomosName := $places//spatial:Feature[@rdf:about = $origLandPlotNomos]//dcterms:title/text()                            
            let $origOusiaRecordRaw := $egyptianPlace1stImport//spatial:Feature[@rdf:about=$origOusiaUri]
            let $origOusiaRecord :=
(:                if($origOusiaRecordRaw//pleiades:hasFeatureType[@type="main"][@rdf:resource="https://ausohnum.huma-num.fr/concept/c26346"]):)
(:                    then ():)
(:                    else:)
                        if ($ousiaID != "") then
                        (let $ousiaUriFromousiaID := $places//spatial:Feature[.//skos:exactMatch[@rdf:resource = $ousiaTMURI]]/@rdf:about/string()
                         return  $places//spatial:Feature[@rdf:about=$ousiaUriFromousiaID]
                        )
                    else $origOusiaRecordRaw
                
            let $ousiaRecord :=""
            let $origOusiaName := if($origOusiaRecord//dcterms:title/text() = "ousiac land") then "ousiac land"
                                else $origOusiaRecord//dcterms:title/text()
            let $origOusiaTm := $origOusiaRecord//skos:exactMatch/@rdf:resource/string()
            let $correctOusiaRecord := $places//spatial:Feature[@rdf:resource="https://ausohnum.huma-num.fr/concept/c23587"]
                            [.//skos:exactMatch[@rdf:resource=$ousiaTMURI]]
                            | $places//spatial:Feature[@rdf:resource="https://ausohnum.huma-num.fr/concept/c23587"]
                            [.//skos:related[@rdf:resource=$origOusiaTm]]
(:                            [.//pleiades:hasFeatureType]:)
            let $correctAPCPlace := $places//spatial:Feature[.//skos:exactMatch[@rdf:resource = $origOusiaTm]][1]
            
            
            let $landplotName := (switch ($ousiaType)
                            case "unknown" return "Property attached to "
                            case "animals; sheep" case "animals; donkeys"
                            case "epiteretes"
                            case "procurator"
                            case "familia Caesaris"
                            case "administration"
                            return "Property attached to " 
                            default return 
                                (if($origOusiaRecord//dcterms:title/text() = "ousiac land") then "Land plot of " else "Land plot of the ")
                                )
                            || $origOusiaName[1] ||
                            (if($nomosName != "") then " (" || $nomosName ||")" else ())
            let $landplotType := switch ($ousiaType)
                            case "unknown" return (<pleiades:hasFeatureType type="main" rdf:resource="https://ausohnum.huma-num.fr/concept/c22226">Estate</pleiades:hasFeatureType>)
                            case "animals; sheep" case "animals; donkeys" return <pleiades:hasFeatureType type="main" rdf:resource="https://ausohnum.huma-num.fr/concept/c2187">Production units</pleiades:hasFeatureType>
                            default return <pleiades:hasFeatureType type="main" rdf:resource="https://ausohnum.huma-num.fr/concept/c21871">Landed estate</pleiades:hasFeatureType>
                            
(:            let $retrieveKeywords :=:)
(:                    for $keyword in tokenize($landplotType, "; "):)
(:                    let $matchApcTerm := $apcKeywords//keyword[@tmTerm=$keyword]/@apcTerm/string():)
(:                    let $matchApcUri := "https://ausohnum.huma-num.fr/concept/" || $apcKeywords//keyword[@tmTerm=$keyword]/@apcUri/string():)
(:                    let $certainty := $apcKeywords//keyword[@tmTerm=$keyword]/@certainty/string():)
(:                    return :)
(:                        if($keyword = "unknown") then ():)
(:                        else :)
(:                        if($certainty = "low") then <pleiades:hasFeatureType type="productionType" rdf:resource="{ $matchApcUri }" certainty="low"/>:)
(:                            else:)
(:                        <pleiades:hasFeatureType rdf:resource="{ $matchApcUri }" type="productionType"/>:)
            let $placeAllDetails :=
                <place rdf:about="{$item/@rdf:about/string()}">
                <origTitle>{ $item //dcterms:title/text() }</origTitle>
                <origSpatialP>{ $item//spatial:P }</origSpatialP>
                <ousia ousiaRefId="{ $ousiaRefId }" ousiaID="{ $ousiaID }" OusiaRefIDTM="{ $origOusiaTm }"
                ousiaTM="{ $ousiaTMURI}"
                type="{ $ousiaType }"
                    apcUriFormer="{ $origOusiaUri }" apcUriCurrent="{ substring-before($correctAPCPlace/@rdf:about, "#this") }">
                    
                        
                        
                    </ousia>
                
                <correctPlaceDetails geoRef="{ $itemGeoRef }" tmPlace="https://www.trismegistos.org/georef/{$itemGeoRef}">
                        <name>{ $landplotName }</name>
                </correctPlaceDetails>
              </place>
            
            let $placeLight :=
                <place rdf:about="{$item/@rdf:about/string()}">
                        <name>{if($origOusiaName =" ") then "ERROR: " else ()}{ $landplotName }</name>
                        <type>{ $ousiaType/string() }</type>
                        <nomos uri="{ $origOusiaUri }">{ $nomosName }</nomos>
                        <landPlotTM ousiaRefId="{ $ousiaRefId }" geoRef="{ $itemGeoRef }" tmPlace="https://www.trismegistos.org/georef/{$itemGeoRef}"/>
                        <ousia ousiaTM="{ $ousiaTMURI}" apcUri="{ substring-before($correctAPCPlace/@rdf:about, "#this") }"/>
                        <keywords></keywords>
                        <origTitle>{ $item//dcterms:title/text() }</origTitle>
              </place>
            
(:            let $updateName := update value $item//dcterms:title/text() with $landplotName:)
            return
              $placeLight
    }
    </results>
    
    
    return 
        <result xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:pleiades="https://pleiades.stoa.org/places/vocab#">{ $processData }</result>