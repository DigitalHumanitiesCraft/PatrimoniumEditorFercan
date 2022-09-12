xquery version "3.1";


module namespace saveFunctions="http://ausonius.huma-num.fr/teiEditorSave";

import module namespace functx="http://www.functx.com" at "/db/system/repo/functx-1.0/functx/functx.xql";
import module namespace httpclient="http://exist-db.org/xquery/httpclient" at "java:org.exist.xquery.modules.httpclient.HTTPClientModule";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor" at "teiEditorApp.xql";
import module namespace zoteroPlugin="http://ausonius.huma-num.fr/zoteroPlugin" at "../zoteroPlugin/zoteroPlugin.xql";

(:declare default element namespace "http://www.tei-c.org/ns/1.0";:)

import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";

declare namespace apc="http://patrimonium.huma-num.fr/onto#"; 

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";


(:declare variable $docId := request:get-parameter('docid', ());:)
declare variable $saveFunctions:project :=request:get-parameter('project', ());
declare variable $saveFunctions:zoteroGroup :=request:get-parameter('zoteroGroup', ());
declare variable $saveFunctions:biblioRepo := doc("/db/apps/" || $saveFunctions:project || "/data/biblio/biblio.xml");
(:declare variable $xpath := request:get-parameter('xpath', ());:)
(:declare variable $project := 'patrimonium';:)



declare function saveFunctions:saveData(){
 

let $now := fn:current-dateTime()
let $currentUser := sm:id()

let $data := request:get-data()
let $doc-collection := collection("/db/apps/" || $saveFunctions:project || "/data/documents")

let $docId := $data//docId/text()
(:let $docId := request:get-parameter('docid', ()):)
let $teiDoc := $doc-collection//id($docId)

let $updatedData := $data//value/text()
let $xpath := replace($data//xpath/text(), 'tei:', '')
let $xpathWithTeiPrefix := $data//xpath/text()

        (:let $nodesArray := tokenize($xpath, '/')
        let $lastNode := $nodesArray[last()]:)

let $originalTEINode :=util:eval( "collection('/db/apps/" || $saveFunctions:project || "/data/documents')//id('"
             ||$docId ||"')/" || $xpathWithTeiPrefix)
(:            let $updatedNode :=  <updatedNode  xmlns="http://www.tei-c.org/ns/1.0">{parse-xml('<' || $lastNode || ">" || $updatedData|| '</' || $lastNode || '>')}</updatedNode>        :)
(:let $updatedTEINode :=  <updatedNode>{parse-xml('<' || $lastNode || ">" || $updatedData|| '</' || $lastNode || '>')}</updatedNode>:)

(:let $updatedTEINode := functx:change-element-ns-deep($updatedNode, 'http://www.tei-c.org/ns/1.0', ''):)

let $logs := collection("/db/apps/" || $saveFunctions:project || "/data/logs")

(:let $updateXml := update insert $aaa/node() following $originalTEINode :)

let $updateXml := update value $originalTEINode with $updatedData





let $logInjection := 
    update insert
    <apc:log type="document-update" when="{$now}" what="{string($data/xml/docId)}" who="{$currentUser}">
        {$data}
        <docId>{$docId}</docId>
        <!--<lastNode>{$lastNode}</lastNode>
        -->
        <origNode2>{$originalTEINode}</origNode2>
        <existingNode>{exists($originalTEINode)}</existingNode>
        <project>{$saveFunctions:project}</project>
        <updatedData>{$updatedData}</updatedData>
        <xpath>{$data//xpath/text()}</xpath>
    </apc:log>
    into $logs/rdf:RDF/id('all-logs')

(:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return

<data>{$data}</data>

};


declare function saveFunctions:addBiblio( $data as node()){

let $now := fn:current-dateTime()
let $currentUser := sm:id()

(:let $data := request:get-data():)
let $doc-collection := collection("/db/apps/" || $saveFunctions:project || "/data/documents")

let $docId := $data//docId/text()
(:let $docId := request:get-parameter('docid', ()):)
let $teiDoc := $doc-collection//id($docId)

let $bibRef := $data//biblioId/text()
let $typeRef := $data//type/text()
let $citedRange := $data//citedRange/text()
let $xpath :=
switch ($typeRef) 
   case "main" return 
            //tei:div[@type="bibliography"][@subtype="principalEdition"]/tei:listBibl
   case "secondary" return 
            //tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl
   
   default return null



        (:let $nodesArray := tokenize($xpath, '/')
        let $lastNode := $nodesArray[last()]:)
let $BibRefAsTei := zoteroPlugin:get-bibItem($saveFunctions:zoteroGroup, $bibRef, "tei")
let $bibTeiId := data($BibRefAsTei//tei:biblStruct/@xml:id)
let $bibTeiIdRef := concat("#", $bibTeiId)
(:let $originalTEINode :=util:eval( "collection('/db/apps/" || $saveFunctions:project || "/data/documents')//id('"
             ||$docId ||"')/" || $xpathWithTeiPrefix)
:)

(:insert new reference in main bibliography:)
let $insertBiblioInBiblioRepo :=
    if ($saveFunctions:biblioRepo//tei:biblStruct[@xml:id = $bibTeiId]) then ()
    else(
               update insert $BibRefAsTei//tei:biblStruct into $saveFunctions:biblioRepo//.[@xml:id="mainBiblio"]
        )
        

let $insertBiblioInTeiDocument :=
    switch ($typeRef) 
       case "main" return 
               if (not(exists($teiDoc//tei:div[@type="bibliography"][@subtype="edition"]//tei:ptr[@target =  $bibTeiIdRef])))
               
               then (
               let $biblNode := <bibl xmlns="http://www.tei-c.org/ns/1.0">
                        <ptr target="{$bibTeiIdRef}"/>,  
                        <citedRange>{$citedRange}</citedRange>
                    </bibl> 
                 return
                 update insert $biblNode into
                 $teiDoc//tei:div[@type="bibliography"][@subtype="edition"]/tei:listBibl
               )
               else()
               
       case "secondary" return 
                //tei:div[@type="bibliography"][@subtype="secondary"]/tei:listBibl
       
       default return null
   
                
    
let $logs := collection("/db/apps/" || $saveFunctions:project || "/data/logs")



(:let $updateXml := update value $originalTEINode with $updatedData:)





let $logInjection := 
    update insert
    <apc:log type="document-update" when="{$now}" what="{string($data/xml/docId)}" who="{$currentUser}">
        {$data}
        <docId>{$docId}</docId>
        <!--<lastNode>{$lastNode}</lastNode>
        -->
        <origNode2>$originalTEINode</origNode2>
        <bibType>{$typeRef}</bibType>
        <teiBibRef>{$saveFunctions:zoteroGroup} - {$BibRefAsTei//tei:biblStruct}</teiBibRef>
    </apc:log>
    into $logs/rdf:RDF/id('all-logs')

(:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return

<data>{$data}</data>

};