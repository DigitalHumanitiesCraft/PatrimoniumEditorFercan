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
let $teiTemplate := doc("xmldb:exist:///db/apps/patrimonium/data/teiEditor/docTemplates/teiTemplateEgypt.xml")
let $collectionPrefix := "apcd"
let $doc-collection-path := "xmldb:exist:///db/apps/patrimoniumData/documents"
let $newDocs-collection-path := $doc-collection-path || "/documents-ybroux/newDocs"
let $project-places-collection := collection("xmldb:exist:///db/apps/patrimoniumData/places/patrimonium")
let $missingDocsList := doc("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/docs/missingDocsList.xml")


let $processTmNo :=
    for $item at $pos in $missingDocsList//doc
        where $pos < 2
        let $doc-collection := collection($doc-collection-path)
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
                xmldb:store($newDocs-collection-path, $filename, $teiTemplate)

   let $changeMod := sm:chmod(xs:anyURI(concat($newDocs-collection-path, "/", $filename)), "rw-rw-r--")
   let $changeGroup := sm:chgrp(xs:anyURI(concat($newDocs-collection-path, "/", $filename)), "documents-ybroux")
    
    
   let $updateId := if(util:eval( "doc('" || $newDocs-collection-path ||"/" || $filename||"')")/tei:TEI/@xml:id) then
                            (update replace  util:eval( "doc('" || $newDocs-collection-path ||"/" || $filename
                            ||"')")/tei:TEI/@xml:id
                            with $newDocId)
                            else 
                            (update insert attribute xml:id {$newDocId} into util:eval( "doc('" || $newDocs-collection-path ||"/" || $filename
                            ||"')")/tei:TEI)
    let $newDoc := doc($newDocs-collection-path ||"/" || $filename)
    let $UPDATE-docUri := update value $newDoc//tei:publicationStmt/tei:idno/text() with $newDocUri
    let $creationNode :=
    <change who="vrazanajao" when="{$now}">Creation of this file {$item/@tmUri/string()}</change>
    
    let $updateCreationChange := update replace $newDoc/tei:TEI/tei:teiHeader/tei:revisionDesc/tei:listChange/tei:change
                                with functx:change-element-ns-deep($creationNode, "http://www.tei-c.org/ns/1.0", "")

    let $UPDATE-tm := update value $newDoc//tei:altIdentifier/tei:idno[@type="uri"][@subtype="tm"]/text() with $item/@tmUri/string()
    let $title := if($item//title/text() != "") then $item//title/text()
                                                else "Document TM " || substring-after($item/@tmUri, "text/")
    let $UPDATE-title := update value $newDoc//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()
                            with $title
    let $UPDATE-notBefore := if($item//origDate/@notBefore-custom != "") then
                    update value $newDoc//tei:origDate/@notBefore-custom with $item//origDate/@notBefore-custom
                else ()
    let $UPDATE-notAfter := if($item//origDate/@notAfter-custom != "") then
                    update value $newDoc//tei:origDate/@notAfter-custom with $item//origDate/@notAfter-custom
                else ()
    let $date := if($item//origDate/@notBefore-custom != "") then 
                    $item//origDate/@notBefore-custom
                    || (if($item//origDate/@notBefore-custom = $item//origDate/@notAfter-custom) then () else "-" || $item//origDate/@notAfter-custom)
                    || " AD"
                    else ()
    let $UPDATE-date := if($date != "") then
                update value $newDoc//tei:origDate/text() with $date
                else()
    
    let $UPDATE-listPlace := 
            if($item//ousia/@apc != "") then
                let $node := <node>
                <place>
                    <placeName ref="{substring-before($item//ousia/@apc, "#this") } { $item//ousia/@tm}" ana="mentionned-in-text">{
                        $project-places-collection//spatial:Feature[@rdf:about=$item//ousia/@apc]//dcterms:title/text()}</placeName>
                </place>
                </node>
                return
                    update insert functx:change-element-ns-deep($node/node(), "http://www.tei-c.org/ns/1.0", "") into $newDoc//tei:listPlace
                else()
        
    let $UPDATE-PlaceProvenance := 
            if($item//provenance/@apcPlace != "") then
                (
                    
                    let $node := <node>
                    <place>
                        <placeName ref="{$item//provenance/@apcPlace } { $item//provenance/@tm }" ana="provenance">{ $item//provenance/text() }</placeName>
                    </place>
                    </node>
                return
                    (
                    update value $newDoc//tei:provenance[@type="findspot"]/tei:location/tei:placeName/@ref with $item//provenance/@apcPlace/string(),
                    update value $newDoc//tei:provenance[@type="findspot"]/tei:location/tei:placeName/text() with $item//provenance/text(),
                    update insert $node/node() into $newDoc//tei:listPlace
                    )
                )
                else()    
        
    return "About to create doc for TM " || $item/@tmUri/string() || " ID will be: " || $newDocId
    
return
    <results>{ $processTmNo } </results>