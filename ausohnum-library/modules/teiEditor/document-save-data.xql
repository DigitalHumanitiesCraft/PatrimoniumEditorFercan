xquery version "3.1";

import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor" at "teiEditorApp.xql";

(:declare default element namespace "http://www.tei-c.org/ns/1.0";:)

import module namespace console="http://exist-db.org/xquery/console" at "java:org.exist.console.xquery.ConsoleModule";
declare namespace apc="http://patrimonium.huma-num.fr/onto#"; 
declare namespace functx = "http://www.functx.com";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare variable $docId := request:get-parameter('docid', ());
declare variable $project :=request:get-parameter('project', 'patrimonium');
(:declare variable $project := 'patrimonium';:)

declare function functx:trim
  ( $arg as xs:string? )  as xs:string {

   replace(replace($arg,'\s+$',''),'^\s+','')
 } ;

declare function functx:change-element-ns
  ( $elements as element()* ,
    $newns as xs:string ,
    $prefix as xs:string )  as element()? {

   for $element in $elements
   return
   element {QName ($newns,
                      concat($prefix,
                                if ($prefix = '')
                                then ''
                                else ':',
                                local-name($element)))}
           {$element/@*, $element/node()}
 } ;

declare function functx:change-element-ns-deep
  ( $nodes as node()* ,
    $newns as xs:string ,
    $prefix as xs:string )  as node()* {

  for $node in $nodes
  return if ($node instance of element())
         then (element
               {QName ($newns,
                          concat($prefix,
                                    if ($prefix = '')
                                    then ''
                                    else ':',
                                    local-name($node)))}
               {$node/@*,
                functx:change-element-ns-deep($node/node(),
                                           $newns, $prefix)})
         else if ($node instance of document-node())
         then functx:change-element-ns-deep($node/node(),
                                           $newns, $prefix)
         else $node
 } ;
 
 
 

let $now := fn:current-dateTime()
let $currentUser := sm:id()

let $data := request:get-data()
let $doc-collection := collection("/db/apps/patrimonium/data/documents")

let $docId := $data//docId/text()
(:let $docId := request:get-parameter('docid', ()):)
let $teiDoc := $doc-collection//id($docId)

let $updatedData := $data//value/text()
let $xpath := replace($data//xpath/text(), 'tei:', '')
let $xpathWithTeiPrefix := $data//xpath/text()

        (:let $nodesArray := tokenize($xpath, '/')
        let $lastNode := $nodesArray[last()]:)

let $originalTEINode :=util:eval( "collection('/db/apps/patrimonium/data/documents')//id('"
             ||$docId ||"')/" || $xpathWithTeiPrefix)
(:            let $updatedNode :=  <updatedNode  xmlns="http://www.tei-c.org/ns/1.0">{parse-xml('<' || $lastNode || ">" || $updatedData|| '</' || $lastNode || '>')}</updatedNode>        :)
(:let $updatedTEINode :=  <updatedNode>{parse-xml('<' || $lastNode || ">" || $updatedData|| '</' || $lastNode || '>')}</updatedNode>:)

(:let $updatedTEINode := functx:change-element-ns-deep($updatedNode, 'http://www.tei-c.org/ns/1.0', ''):)

let $logs := collection("/db/apps/patrimonium/data/logs")

(:let $updateXml := update insert $aaa/node() following $originalTEINode :)

(:let $updateXml := update value $originalTEINode with $updatedData:)





let $logInjection := 
    update insert
    <apc:log type="document-update" when="{$now}" what="{string($data/xml/docId)}" who="{$currentUser}">
        {$data}
        <docId>{$docId}</docId>
        <!--<lastNode>{$lastNode}</lastNode>
        -->
        <origNode2>{$originalTEINode}</origNode2>
        <existingNode>{exists($originalTEINode)}</existingNode>
        
        <updatedData>{$updatedData}</updatedData>
        <xpath>{$data//xpath/text()}</xpath>
    </apc:log>
    into $logs/rdf:RDF/id('all-logs')

(:let $save := teiEditor:saveData(string($data/xml/docId), string($data/xml/input), string($updatedData)):)

return

<data>{$data}</data>

