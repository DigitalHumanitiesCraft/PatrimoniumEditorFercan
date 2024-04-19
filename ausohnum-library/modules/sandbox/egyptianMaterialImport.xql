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
let $doc-collection-path := "xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/forFinal/docs"
let $project-places-collection := collection("xmldb:exist:///db/apps/patrimoniumData/places/patrimonium")
let $egyptianMaterial-peopleList := doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/meta/peopleProv4import.xml")
let $egyptianMaterial-peopleRecords := collection("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/forFinal/meta")
let $lemmatizedCorpus := collection("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/docYanneBroux")
let $places2beAdded :=doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/meta/places2beAdded.xml")

let $tmUrisOfFilesToProcess := 

        for $file in $lemmatizedCorpus//file
            return data($file/@text)
let $HGVNumbersOfFilesToProcess := 
        for $file in $lemmatizedCorpus//file
            return data($file/@HGV)
let $filenamesToProcess := 
        for $file in $lemmatizedCorpus//file
            return data($file/@name)
            
let $papiryInfoCollectionTranscr := collection("xmldb:exist:///db/apps/papyriInfo/data/DDB_EpiDoc_XML")
let $HGV_metadata := collection("xmldb:exist:///db/apps/papyriInfo/data/HGV_meta_EpiDoc")
let $processedtmNo := for $file in 
            collection("xmldb:exist:///db/apps/patrimoniumData/documents/documents-ybroux")//tei:idno[@type='tm']
            return data($file)

let $logTmNoTobeProcessed := update insert 
                <log when="{ $now }">@@@@@@@@
                TM: { $tmUrisOfFilesToProcess }    
                HGV: { $HGVNumbersOfFilesToProcess }        
                Filename : { $filenamesToProcess }
                distinct TM: { distinct-values($tmUrisOfFilesToProcess)}
                </log> into $logs/rdf:RDF
return 
    for $tmUri at $pos in distinct-values($tmUrisOfFilesToProcess)
        
(:        where $pos < 4:)
        
       let $tmNo := functx:substring-after-last($tmUri, '/')    
       return if(collection("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/forFinal/docs")[contains(.//tei:idno[equals(./@type, "tm")], $tmNo)])
           then
            ()
        else
        
(:        let $HGVNo := $HGVNumbersOfFilesToProcess[$pos]:)
        
        
(:        let $teiHeader := $HGV_metadata/id("hgv"|| $HGVNo):)
(:        let $teiHeader := $HGV_metadata//tei:TEI[equals(.//tei:idno[@type = "filename"], $HGVNo)]//tei:teiHeader:)
        let $lemmatizedText := $lemmatizedCorpus//file[@text=$tmUri]    
        let $teiHeader := if($HGV_metadata/id("hgv"|| $tmNo)) then 
            $HGV_metadata/id("hgv"|| $tmNo)//tei:teiHeader
            else if ($HGV_metadata//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt//tei:idno[@type="TM"][contains(., $tmNo)][1]]/tei:teiHeader) then
            $HGV_metadata//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt//tei:idno[@type="TM"][contains(., $tmNo)][1]]/tei:teiHeader
            else ()
        
        
        
        
        let $ddb-filename := if($teiHeader//tei:idno[equals(./@type, "ddb-filename")]) then $teiHeader//tei:idno[equals(./@type, "ddb-filename")]/text()
                            else $teiHeader//tei:idno[equals(./@type, "filename")]/text()
        
        let $insertLogStart := update insert 
                <log when="{ $now }">Start TM: {$tmNo}
                    $HGVNumbersOfFilesToProcess[$pos]: {$HGVNumbersOfFilesToProcess[$pos]}
                    $ddb-filename : {$ddb-filename}
                </log> into $logs/rdf:RDF
        
        
(:        let $TMRetrieve := teiEditor:TMTextRelations($tmNo, "all"):)
            let $teiText := if($papiryInfoCollectionTranscr/id($ddb-filename)) then
        $papiryInfoCollectionTranscr/id($ddb-filename)//tei:div[matches(./@type, "edition")]
        else $papiryInfoCollectionTranscr//tei:TEI[tei:teiHeader/tei:fileDesc/tei:publicationStmt//tei:idno[matches(./@type,"filename")][matches(./text(), $ddb-filename)]]//tei:div[matches(./@type, "edition")]
(:        $papiryInfoCollectionTranscr//tei:TEI[matches(.//tei:idno[matches(./@type,  "TM")], $tmNo)]//tei:div[matches(./@type, "edition")]     :)
        
        
        let $insertLogMeta := update insert 
                <log when="{ $now }">TM: {$tmNo} Header: { $teiHeader}
                    text: { $teiText }
                </log> into $logs/rdf:RDF

       let $doc-collection := collection("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/forFinal/docs")

  
        let $docIdList := for $id in $doc-collection//tei:TEI[contains(./@xml:id, $collectionPrefix)]
            return
            <item>
            {substring-after($id/@xml:id, $collectionPrefix)}
            </item>

        let $last-id:= fn:max($docIdList)
(:        let $last-id := 101000:)
        let $newDocId := $collectionPrefix || fn:sum(($last-id, 1))
        let $newDocUri := $teiEditor:baseUri || "" || "documents" ||"/" || $newDocId
        
        let $filename := $newDocId || ".xml"


   let $storeNewFile := 
   xmldb:store($doc-collection-path, $filename, $teiTemplate)

   let $changeMod := sm:chmod(xs:anyURI(concat($doc-collection-path, "/", $filename)), "rw-rw-r--")
   let $changeGroup := sm:chgrp(xs:anyURI(concat($doc-collection-path, "/", $filename)), "documents-ybroux")
    
    
   let $updateId := if(util:eval( "doc('" || $doc-collection-path ||"/" || $filename||"')")/tei:TEI/@xml:id) then
                            (update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/@xml:id
                            with $newDocId)
                            else 
                            (update insert attribute xml:id {$newDocId} into util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI)
    let $newDoc := doc($doc-collection-path ||"/" || $filename)
    
    let $creationNode :=
    <change who="{$currentUser}" when="{$now}">Creation of this file</change>
    
    let $updateCreationChange := update replace $newDoc/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:listChange/tei:change
                                with functx:change-element-ns-deep($creationNode, "http://www.tei-c.org/ns/1.0", "")

    
    let $title := if($lemmatizedText/@description != "") then $lemmatizedText/@description
            else $teiHeader//tei:titleStmt/tei:title/text()

            
    let $updateTitle := if($title != "") then update value $newDoc//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text() with $title else ()
    let $updateIDNOProject := update replace  util:eval( "doc('" || $doc-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="uri"]/text()
                            with 'https://patrimonium.huma-num.fr/' || $newDocUri
    let $altIdentifier1 := 'http://papyri.info/ddbdp/' || $teiHeader//tei:idno[@type='ddb-hybrid']/text() 
    let $updateAltIdentifier1 := (update value $newDoc//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:altIdentifier[1]/tei:idno/@subtype
                                with "papyriHGV",
                                update value $newDoc//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:altIdentifier[1]/tei:idno
                                with $altIdentifier1
                                )
    let $tmNoIdno := <data>
            <tei:idno type="tm">{ $tmNo }</tei:idno></data>                            
    let $updateTmNo := update insert functx:change-element-ns-deep($tmNoIdno/node(), "http://www.tei-c.org/ns/1.0", "") 
                            following $newDoc//tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno
    let $tmUriAltIdentifier := <data>           <tei:altIdentifier>
                        <tei:idno type="uri" subtype="tm">https://www.trismegistos.org/text/{ $tmNo }</tei:idno>                            
                     </tei:altIdentifier>
            </data>
            
    let $updatetmUriAltIdentifier := update insert functx:change-element-ns-deep($tmUriAltIdentifier/node(), "http://www.tei-c.org/ns/1.0", "") 
                            into $newDoc//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier
    
    
    let $updateText := if(exists($teiText//tei:div[matches(./@type, "textpart")])) then 
                            update replace $newDoc//tei:div[matches(./@type, "edition")]
                            with $teiText
                        else 
                            update replace $newDoc//tei:div[matches(./@type, "edition")]
                            with functx:change-element-ns-deep(<tei:div type="edition">
                            <tei:div type="textpart" subtype="" n="">
                            {$teiText/node()}
                            </tei:div>
                        </tei:div>, "http://www.tei-c.org/ns/1.0", "")
                            

    let $updateMsItem := update value $newDoc//tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/@xml:id
                        with $newDocId ||"-msItem-1"
                        
     
    let $updateMainLang := if($teiText/@xml:lang != "") then update value $newDoc//tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/tei:textLang/@mainLang
                        with data($teiText/@xml:lang)
                        else()
    let $msContentsUmmary := <data>     <tei:summary>{ data($lemmatizedText/@description) }</tei:summary></data>
    let $insertMsContentsummar := if($lemmatizedText/@description != "") then update insert functx:change-element-ns-deep($msContentsUmmary/node(), "http://www.tei-c.org/ns/1.0", "") into 
                $newDoc//tei:sourceDesc/tei:msDesc/tei:msContents
                else ()
                        
                        
    let $updateDates :=
            if($teiHeader//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate)
            then
                for $date in $teiHeader//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin//tei:origDate
                let $notBefore := $date/@notBefore
                let $notAfter := $date/@notAfter
                let $notBeforeCustom := if(starts-with($notBefore, '0')) then substring($notBefore, 2) else $notBefore
                let $notAfterCustom := if(starts-with($notAfter, '0')) then substring($notAfter, 2) else $notAfter
                let $when := $date/@when
                let $textualDate := $date/text()
                
                return
                (
                if($notBefore !="") then 
                update value $newDoc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notBefore-custom
                with $notBeforeCustom else(),
                if($notAfter !="") then update value $newDoc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/@notAfter-custom
                with $notAfterCustom else(),
                if($when !="") then update insert attribute when { $when } into $newDoc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate
                    else (),
                if($textualDate !="") then update value $newDoc//tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate/text()
                with $textualDate else ()
                )
                else()


(:        let $provenanceTm := tokenize($teiHeader//tei:sourceDesc//tei:history/tei:provenance//tei:placeName[1]/@ref, ' ')[contains(., 'trisme')]:)
        let $provenanceTm := data($lemmatizedText/@provenance)
        let $provenancePleiades := tokenize($teiHeader//tei:sourceDesc//tei:history/tei:provenance//tei:placeName[1]/@ref, ' ')[contains(., 'pleiades')]
        let $projectPlaceUri := substring-before($project-places-collection//spatial:Feature[skos:exactMatch[@rdf:resource = $provenanceTm]][1]/@rdf:about, "#this")
        let $placesInLemmatizedFile := 
                <placesInLemmatizedFile>
                        {
                for $place in $lemmatizedText//word[@geo]
                    let $apcPlace :=substring-before($project-places-collection//spatial:Feature[skos:exactMatch[@rdf:resource = $place/@geo]][1]/@rdf:about, "#this")
                    let $tmPlace := <node>
                            <place uris="{$place/@geo}"/>
                        </node>
                    let $logPlace := if( $apcPlace="") then 
                            update insert $tmPlace/node() 
                                 into $places2beAdded/rdf:RDF
                            else ()
                    
                    return 
                    <node>
                    <place>
                        <tei:placeName ref="{ if($apcPlace !="") then $apcPlace else $place/@geo }"
                    ana="mentioned-in-text"></tei:placeName>
                    </place>
                    </node>
                }
                </placesInLemmatizedFile>
        
        let $origPlaceForList := <place>        <tei:place>
                         <tei:placeName ref="{$projectPlaceUri} { $teiHeader//tei:sourceDesc//tei:history/tei:provenance//tei:placeName[1]/@ref }" 
                     ana="provenance">{ $teiHeader//tei:sourceDesc//tei:history/tei:provenance//tei:placeName[1]/text()}</tei:placeName>
                   </tei:place></place>

        


    let $updateProvenance := if($teiHeader//tei:sourceDesc//tei:history/tei:provenance//tei:placeName[1]/@ref) then (update value $newDoc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:provenance/tei:location/tei:placeName/@ref             
                            with $projectPlaceUri 
(:                            || " " :)
(:                            || data($teiHeader//tei:sourceDesc//tei:history/tei:provenance//tei:placeName[1]/@ref):)
                            ,
                            update value $newDoc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:provenance/tei:location/tei:placeName
                            
                            with data($teiHeader//tei:sourceDesc//tei:history/tei:provenance//tei:placeName[1]/text())
                            )
                            else()
    
    
    
    let $updateListOfPlacesProv := if($origPlaceForList//tei:placeName) then
                update insert functx:change-element-ns-deep(functx:distinct-deep($origPlaceForList/node()), "http://www.tei-c.org/ns/1.0", "") 
                    into $newDoc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace
                    else ()
    let $updateListOfPlaces := if($placesInLemmatizedFile//tei:placeName) then
                update insert functx:change-element-ns-deep(functx:distinct-deep($placesInLemmatizedFile/node/node()), "http://www.tei-c.org/ns/1.0", "") 
                    into $newDoc/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace
                    else ()
    let $peopleInLemmatizedFile := 
                <peopleInLemmatizedFile>{
                for $people in functx:distinct-deep($lemmatizedText//word[@per])
                    let $tmPersUri := $people/@per
                    let $apcUri := $egyptianMaterial-peopleList//person[equals(./@tm, $tmPersUri)]/@apc
                    return 
                    <people>    <tei:person corresp="{ $apcUri }">
                                <persName>{ $egyptianMaterial-peopleRecords//lawd:person[matches(./@rdf:about, $apcUri)]//lawd:personalName[1]/text()}</persName>
                        </tei:person>
                  </people>
                }
                </peopleInLemmatizedFile>

    let $updateListOfPeople := if($peopleInLemmatizedFile//tei:person) then 
        update insert functx:change-element-ns-deep(functx:distinct-deep($peopleInLemmatizedFile/people/node()), "http://www.tei-c.org/ns/1.0", "") 
                    into $newDoc//tei:teiHeader/tei:profileDesc/tei:listPerson[@type="peopleInDocument"]
                    else()
    let $teiBibFull :=
                <node><tei:bibFull sameAs="{ $altIdentifier1 }">
                                { $teiHeader//tei:fileDesc }
            </tei:bibFull>
        </node>
    let $embedOrigFileDescIntoSourceDesc :=
        update insert 
    functx:change-element-ns-deep($teiBibFull/node(), "http://www.tei-c.org/ns/1.0", "")
                into $newDoc//tei:sourceDesc
                
    let $insertLogEnd := update insert 
                <log when="{ $now }">End of TmNo: {$tmNo} ($ddb-filename: { $ddb-filename })
                file created: { $filename }
                </log> into $logs/rdf:RDF
                    
    return $newDoc
    