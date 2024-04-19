xquery version "3.1";

(:import module namespace config="https://ausohnum.huma-num.fr/apps/eStudium/config" at "../config.xqm";:)

(: import module namespace ausohnumCommons="http://ausonius.huma-num.fr/commons" at "../commons/commonsApp.xql"; :)
(: import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor" at "./teiEditorApp.xql"; :)

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "/db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";
import module namespace functx="http://www.functx.com";


declare namespace apc="https://ausohnum.huma-num.fr/apps/eStudium/onto#";
declare namespace ausohnum= "http://ausonius.huma-num.fr/onto";
declare namespace bibo="http://purl.org/ontology/bibo/";
declare namespace cito="http://purl.org/spar/cito/";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace err = "http://www.w3.org/2005/xqt-errors";
declare namespace ev = "http://www.w3.org/2001/xml-events";
declare namespace foaf = "http://xmlns.com/foaf/0.1/";
declare namespace geo = "http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace json="http://www.json.org";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace prism="http://prismstandard.org/namespaces/basic/2.0/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace spatial="http://geovocab.org/spatial#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace thot = "http://thot.philo.ulg.ac.be/";
declare namespace xf = "http://www.w3.org/2002/xforms";
declare namespace local = "local";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare boundary-space preserve;
declare option exist:serialize "method=json media-type=application/javascript";
(:declare option output:indent "yes";
declare option output:method "xml";
declare option output:media-type "xml";
declare option output:json-ignore-whitespace-text-nodes "yes";
:)
declare variable $lang := request:get-parameter("lang", ());
declare variable $project := request:get-parameter("project", ());
declare variable $document-collection := collection("/db/apps/" || $project || "Data/documents");
declare variable $placeGazetteer := doc("/db/apps/" || $project || "Data/places/project-places-gazetteer.xml");
declare variable $documents := $document-collection//tei:TEI except $document-collection//documents-test;
declare variable $peopleCollection := collection("/db/apps/" || $project || "Data/people");
declare variable $placesCollection := collection("/db/apps/" || $project || "Data/places/" ||$project);
declare variable $biblioRepo := doc("/db/apps/" || $project || "Data/biblio/biblio.xml");
declare variable $appVariables := doc("/db/apps/" || $project || "/data/app-general-parameters.xml");
declare variable $placeToDisplay := $appVariables//dashboardPlaceToDisplay/text();
declare variable $baseUri := $appVariables//uriBase[@type='app']/text();
declare variable $teiElements := doc("/db/apps/" || $project || 'data/teiEditor/teiElements.xml');
declare variable $teiElementsCustom := doc("/db/apps/" || $project || '/data/teiEditor/teiElements.xml');
declare variable $docPrefix := $appVariables//idPrefix[@type="document"]/text();

declare variable $productionUnitTypes := skosThesau:getChildren($appVariables//productionUnitsUri/text(), $project);


declare function local:displayBibRef($resource as node()){
    let $resourceUri := data($resource/tei:ptr/@target)
    let $resourceRecord := $biblioRepo//tei:biblStruct[@corresp = $resourceUri]
    let $authorLastName := <span class="lastname">{ 
                if($resourceRecord[1]//tei:author[1]/tei:surname) then 
                        if(count($resourceRecord[1]//tei:author) = 1) then data($resourceRecord[1]//tei:author[1]/tei:surname)
                        else if(count($resourceRecord[1]//tei:author) = 2) then data($resourceRecord[1]//tei:author[1]/tei:surname) || " &amp; " || data($resourceRecord[1]//tei:author[2]/tei:surname)
                        else if(count($resourceRecord[1]//tei:author) > 2) then  <span>{ data($resourceRecord[1]//tei:author[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                else if ($resourceRecord[1]//tei:editor[1]/tei:surname) then
                            if(count($resourceRecord[1]//tei:editor) = 1) then data($resourceRecord[1]//tei:editor[1]/tei:surname)
                        else if(count($resourceRecord[1]//tei:editor) = 2) then data($resourceRecord[1]//tei:editor[1]/tei:surname) || " &amp; " || data($resourceRecord[1]//tei:editor[2]/tei:surname)
                        else if(count($resourceRecord[1]//tei:editor) > 2) then  <span>{ data($resourceRecord[1]//tei:editor[1]/tei:surname)} <em> et al.</em></span>
                        else ()
                        
                else ("[no name]")
                }</span>       
                
        let $date := data($resourceRecord[1]//tei:imprint/tei:date)
        let $citedRange :=if($resource//tei:citedRange and $resource//tei:citedRange != "") then
                                                    if (starts-with(data($resource[1]//tei:citedRange), ',')) 
                                                    then data($resource[1]//tei:citedRange)
                                                    else (', ' || data($resource[1]//tei:citedRange))
                                    else if($resource//prism:pageRange) then 
                                    
                                            if (starts-with(data($resource//prism:pageRange), ',')) 
                                                    then data($resource//prism:pageRange)
                                                    else (', ' || data($resource//prism:pageRange))
                             else ()
          let $suffixLetter := 
                 if (matches(
                 substring(data($resourceRecord[1]/@xml:id), string-length(data($resourceRecord[1]/@xml:id))),
                 '[a-z]'))
                 then substring(data($resourceRecord[1]/@xml:id), string-length(data($resourceRecord[1]/@xml:id)))
                 else ''                               
        let $ref2display :=
                             if($resourceRecord[1]//tei:title[@type="short"]) then
                                     (serialize(<span class="labelInTable label label-primary">
                                     {$resourceRecord[1]//tei:title[@type="short"]/text() || " "} { substring-after($citedRange, ',')}
                                     </span>))
                             else (serialize(<span class="labelInTable label label-primary">{ $authorLastName  || " " || $date || $suffixLetter || $citedRange } </span>))
               
                    
        return
        $ref2display
};

declare function local:getDocumentKeywords($docId as xs:string){
    let $teiDoc := $documents/id($docId)
    let $elementNicknameKeyword := "docKeywords"
    let $docKeywordXPath :=
                if (not(exists($teiElementsCustom//teiElement[nm=$elementNicknameKeyword]))) 
                                        then $teiElements//teiElement[nm=$elementNicknameKeyword]/xpath/text() 
                                        else $teiElementsCustom//teiElement[nm=$elementNicknameKeyword]/xpath/text()
    let $docKeywordXPathElementNode:= substring-before($docKeywordXPath, '/@')
    let $docKeywordAttributeName := substring-after($docKeywordXPath, '/@')
    let $keywordsInDoc := util:eval("$teiDoc/" || $docKeywordXPathElementNode)  
    let $peopleInDoc := $teiDoc//tei:profileDesc/tei:listPerson[@type="peopleInDocument"]//tei:person
    let $peopleRecords :=
        for $person at $pos in $peopleInDoc
(:            where $pos < 50:)
           
            let $personUris := data($person/@corresp)
            let $personUriInternal :=
                for $uri in tokenize($personUris, " ")
                return 
                    if (contains($uri, $project)) then $uri else ()
             let $personUriInternalLong := $personUriInternal || "#this"       
            let $personDetails := $peopleCollection//lawd:person[@rdf:about=$personUriInternalLong][not(.//apc:socialStatus[@rdf:resource="https://ausohnum.huma-num.fr/concept/c22259"])]
        return $personDetails
        
        (:let $persName := if($personDetails//lawd:personalName[@xml:lang="en"]) then $personDetails//lawd:personalName[@xml:lang="en"]/text() else $personDetails//lawd:personalName[1]/text()
            let $personStatus := $personDetails//apc:personalStatus/text()
            let $personRank := $personDetails//apc:socialStatus/text()
    :)
    
    let $relatedPlaces := $teiDoc//tei:sourceDesc/tei:listPlace//tei:place 
    let $productionUnitTypesURIs :=
        for $item in $productionUnitTypes//skos:Concept return data($item/@rdf:about)
    let $keywordsFromPlaces :=
        for $place at $pos in $relatedPlaces
            let $placeName := $place/tei:placeName/string()
            let $placeUris := data($place/tei:placeName/@ref)
            let $placeUriInternal :=
                for $uri in tokenize($placeUris, " ")
                return 
                    if (contains($uri, $project)) then $uri else ()
            let $placeRecord:= $placesCollection//pleiades:Place[@rdf:about = $placeUriInternal][1]
            return
            (
                if(contains($productionUnitTypesURIs,
                        data($placeRecord//pleiades:hasFeatureType[@type="main"]/@rdf:resource)))
                    then data($placeRecord//pleiades:hasFeatureType[@type="main"]/@rdf:resource)
                    else ()
                    ,
                    $placeRecord//pleiades:hasFeatureType[@type="productionType"]/@rdf:resource
             )
    
    
    
    
    
    let $keywordUriList :=
    distinct-values(
        for $keyword in $keywordsInDoc
            return util:eval("$keyword/@" ||  $docKeywordAttributeName || "")
            )
            
    let $personalStatusesUriList :=distinct-values( 
        for $personStatus in $peopleRecords[.//lawd:person[apc:socialStatus/@rdf:resource != "http://ausohnum.huma-num.fr/concept/c22259"]]//apc:personalStatus[@rdf:resource !=""]
            return util:eval("$personStatus/@rdf:resource"))
(:    let $socialStatusesUriList :=distinct-values( :)
(:        for $socialStatus in $peopleRecords//apc:socialStatus[@rdf:resource !=""]:)
(:            return util:eval("data($socialStatus/@rdf:resource)"))        :)
    let $peopleFunctionsUriList :=distinct-values( 
        for $function in $peopleRecords[.//apc:socialStatus[@rdf:resource != "http://ausohnum.huma-num.fr/concept/c22259"]]//apc:hasFunction[@rdf:resource !=""]
                        
            return util:eval("$function/@rdf:resource"))        
            
    let $keywordsFromPlacesUriList :=distinct-values($keywordsFromPlaces)
    
    let $keywordList :=
        for $uri at $pos in ($keywordUriList, $personalStatusesUriList, $peopleFunctionsUriList, $keywordsFromPlacesUriList)
        let $label := skosThesau:getLabel(data($uri), "uri")
        order by $label
            return
            <keyword>{ $uri }</keyword>
(:    let $keywordsFromPlacesUriList :=distinct-values( :)
(:        for $place in $keywordsFromPlaces:)
(:            return util:eval("data($personStatus/@rdf:resource)")):)
    
    return 
    
        (for $uri at $pos in functx:distinct-deep($keywordList)
        let $label := skosThesau:getLabel(data($uri), "uri")
        return 
            <span class="label label-primary labelInTable">{$label }</span>
       )
     

};
let $newList := 
<root xmlns:json="http://www.json.org">
    {
    for $document in $documents
(:    [position() < 10]:)
        let $title := if(count($document//tei:titleStmt/tei:title[not(@type='corpus')]) >1) then
                    if($document//tei:titleStmt/tei:title[not(@type='corpus')][@xml:lang=$lang] != "") then 
                        $document//tei:titleStmt/tei:title[not(@type='corpus')][@xml:lang=$lang]/text()
                        else $document//tei:titleStmt/tei:title[not(ancestor::tei:bibFull)][1][not(@type='corpus')]/text()
                else $document//tei:titleStmt/tei:title[not(ancestor::tei:bibFull)][1][not(@type='corpus')]/text()
          
          let $provenanceUri := 
                let $splitRef := tokenize(data($document//tei:sourceDesc/tei:msDesc/tei:history/tei:provenance/tei:location/tei:placeName/@ref), " ")
                     return  for $uri in $splitRef
                                 return
                                 if(contains($uri, $baseUri)) then 
                                 normalize-space($uri[1]) else ()
           
           let $provinceName :=
                $placeGazetteer//features[properties[uri = $provenanceUri]]//provinceName/text()
           let $provinceUri :=
                $placeGazetteer//features[properties[uri = $provenanceUri]]//provinceUri/text()
(:           $document-collection//corpus[title = substring-after(util:collection-name($document), "/documents/")]//area/text()                                                    :)
           let $datingNotBefore :=
                           for $date in $document//tei:origin[not(ancestor::tei:bibFull)]//tei:origDate
                           
                        return
                            if($date/@notBefore-custom)
                                then replace($date/@notBefore-custom, "\?", "")
                                else if($date/@notBefore) then replace($date/@notBefore, "\?", "")
                                else ()

                    (:if($document//tei:origDate/@notBefore-custom)
                           then functx:substring-after-if-contains($document//tei:origDate/@notBefore-custom, "/")
                    else if($document//tei:origDate/tei:date/@notBefore)
                    
                    then functx:substring-after-if-contains($document//tei:origDate/tei:date/@notBefore, "/")
                    else ():)
         let $datingNotAfter :=
                 for $date in $document//tei:origin[not(ancestor::tei:bibFull)]//tei:origDate
                        return
                            if($date/@notAfter-custom)
                                    then replace($date/@notAfter-custom, "\?", "")
                                    else if($date/@notAfter) then replace($date/@notAfter, "\?", "")
                                    else ()
                (:if($document//tei:origDate/@notAfter-custom)
                           then functx:substring-after-if-contains($document//tei:origDate/@notAfter-custom, "/")
                    else if($document//tei:origDate/tei:date/@notAfter)
                    
                    then functx:substring-after-if-contains($document//tei:origDate/tei:date/@notAfter, "/")
                    else ():)
(:           let $edition:= "temp":)
        let $edition :=if($document//tei:div[@subtype="edition"]//tei:bibl)
                then 
                    for $ref in $document//tei:div[@subtype="edition"]//tei:bibl
                    return 
                    local:displayBibRef($ref)
                else(" ")
       let $keywords :=
       local:getDocumentKeywords(data($document/@xml:id))
                (:for $term in $document//tei:term
                    return <span class="label label-primary labelInTable">{ functx:capitalize-first($term/text()) }</span>:)
        
      let $dataNode := <dataNode>    <data json:array="true">
        <id>{ data($document/@xml:id)}</id>
        <status></status>
        <title>{ $title } </title>
        <uri>{ $baseUri || "/documents/" || $document/@xml:id }</uri>
        { switch ($placeToDisplay)
                  case 'provenance' return
                    if($provenanceUri != "")
                        then
                            (<provenance>{ $placeGazetteer//features[properties/uri = $provenanceUri[1]]/properties/name/text() }</provenance>,
                            <provenanceAltNames>{ $placeGazetteer//features[properties/uri = $provenanceUri[1]]/properties/altNames/text() }</provenanceAltNames>)
                        else(<provenance/>,<provenanceAltNames/>)
                       
                   case 'origin' return
                   let $uri := data($document//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace/@ref)
                   return
                        (<provenance>{ $document//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace/text() }</provenance>)
                  default return
                  (<provenance>{'<a href="' || $provenanceUri ||'" >' || $document//tei:sourceDesc/tei:msDesc/tei:history/tei:provenance/string() || '</a>
                                <a href="' || $provenanceUri || '" target="_blank"><i class="glyphicon glyphicon-new-window"/></a>'}</provenance>
                        )
           }
         <provenanceUri>{ switch ($placeToDisplay)
                  case 'provenance' return if($provenanceUri[1] != "") then $provenanceUri[1] else " "
                  case 'origin' return if(data($document//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace/@ref) != "") then data($document//tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace/@ref) else " "
                  default return if($provenanceUri[1] != "") then $provenanceUri[1] else " " }</provenanceUri>
          <provenanceCoordinates>{ 
          if($provenanceUri[1] != "") then string-join($placeGazetteer//features[properties/uri = $provenanceUri[1]]/geometry//coordinates, ", ") else " "
          }</provenanceCoordinates>
         <provinceName>{ if($provinceName != "") then $provinceName else " "}</provinceName>
         <provinceUri>{ if($provinceUri != "") then $provinceUri else " " }</provinceUri>
         <datingNotBefore>{ if($datingNotBefore != "") then min($datingNotBefore) else " "}</datingNotBefore>
         <datingNotAfter>{ if($datingNotAfter  != "") then max($datingNotAfter) else " "}</datingNotAfter>
         <tmNo>{ if($document//tei:idno[@subtype="tm"]/text() != "") then $document//tei:idno[@subtype="tm"]/text() else " "}</tmNo>
         <edition>{ normalize-space(string-join($edition, " ")) }</edition>
         <otherId>{ string-join(for $uri in $document//tei:idno[not(contains(., $project))]/text()
                            return encode-for-uri($uri), " ")}</otherId>
         <keywords>{ serialize($keywords) }</keywords>                   
    </data>
</dataNode>
       
       order by xs:int(substring-after(data($document/@xml:id), $docPrefix ))
               return (
        $dataNode/node()         
 
)}
</root>



let $list := doc("/db/apps/" || $project || "Data/lists/list-documents.xml")
let $updateList := update replace $list/documentsList/root with $newList
let $updateDate :=
        update value $list/documentsList/@lastUpdate with fn:current-dateTime()
let $updateDocNumber := update value $list/documentsList/@documentsNumber with count($documents)


return

<response status="ok">
            <message>List of documents updated for project { $project }</message>
</response>
    