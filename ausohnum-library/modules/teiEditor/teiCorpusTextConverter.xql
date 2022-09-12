xquery version "3.1";

import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";

import module namespace functx="http://www.functx.com";

import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";

declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";

declare namespace tei="http://www.tei-c.org/ns/1.0";


let $currentUser := xmldb:get-current-user()

let $now := fn:current-dateTime()



(:let $filename := request:get-uploaded-file-name("file"):)
(:let $fileContent := :)
(:    util:binary-to-string(request:get-uploaded-file-data("file")):)
(:let $storeFile:= xmldb:store("xmldb:exist:///db/apps/patrimoniumData/fmProImports/", $filename, $fileContent):)

(:let $sourceFilename := "doc-alberto-20191008.xml":)

(:let $sourceFilename := "sources-20190920-1320.xml":)
let $collectionName := "documents-dromero"

let $path2docs := "xmldb:exist:///db/apps/patrimoniumData/documents/"
let $pathToTeiCorpus := $path2docs || $collectionName || ""
let $logs := collection("xmldb:exist:///db/apps/patrimoniumData" || '/logs')
let $teiCorpus := collection($pathToTeiCorpus)

return 
    
    for $teiDoc at $pos in $teiCorpus//tei:TEI
                   let $docId := data($teiDoc/@xml:id)
                   let $extDocUri :=
                            $teiDoc//tei:publicationStmt//tei:idno[@type="EDH"]/text()
                            | $teiDoc//tei:publicationStmt//tei:idno[@type="PHI"]/text()
                            | $teiDoc//tei:publicationStmt//tei:idno[@type="MAMAXI"]/text()
                   
                   
                   
                    let $textDiv :=
                        if (exists($teiDoc//tei:div[@type='textpart']/tei:ab/node()/node()))
                            then ()
                        else(
                            if((contains($extDocUri, "edh"))
                                or (contains($extDocUri, "mama"))
                                )
                                then 
                                    (teiEditor:getTextDivFromXml($extDocUri))
                            
                            
                            
                            else if (contains($extDocUri, "EDCS-")) then
                                    (teiEditor:getTextDivFromXml(
                                        teiEditor:edcsMatcher(substring-after($extDocUri, "EDCS-"))
                                    )
                                    )
                            else(
                                
                                if(teiEditor:convertIntoEpiDoc($teiDoc//tei:div[@type='textpart']//tei:ab) !="error")
                                    then
                                        <div type="textpart"xmlns="http://www.tei-c.org/ns/1.0">
                                        { teiEditor:convertIntoEpiDoc($teiDoc//tei:div[@type='textpart']//tei:ab) }
                                        </div>
                                        else ("Error TEXT not converted"
                                        || "\n" ||
                                        $teiDoc//tei:div[@type='textpart']/tei:ab
                                        )
                                    )
                        )
                            
                   let $log :=
                                <data>
                                    <log type="test-import" when="{$now}" what="doc-{ $pos }" who="{$currentUser}"><description>
                                        
                                    DocId: { $docId}
                                    Already processed : { 
                                       exists($teiDoc//tei:div[@type='textpart']/tei:ab/node()/node())
                                   }
                                   $textDiv : { $textDiv }
                                    </description></log>
                                 </data>
                           
                               let $logTextBeforeParse :=
                                    update insert
                                        $log/node()
                                 into $logs/rdf:RDF/id('all-logs')
            (:            let $apparatusDiv := $response//tei:div[@type='apparatus']:)
            (:            let $biblioDiv := $response//tei:div[@type='apparatus']:)
                
                        
             
                        let $updateTextDiv := 
            (:            update replace:)
            (:                    util:eval( "doc('" || $path2docs ||  $collectionName || '/' || $filename ||"')"):)
                        if (
                            
                                exists($teiDoc//tei:div[@type='textpart']/tei:ab/node()/node())
                            
                            )
                        then ()
                            else
                            (
                                update replace 
                                        util:eval( "collection('" || $pathToTeiCorpus||"')/id('" || $docId 
                                        || "')//tei:body/tei:div[@type='edition']/tei:div[@type='textpart']")
                            with functx:change-element-ns-deep($textDiv, "http://www.tei-c.org/ns/1.0", "")
                        )
                        
                          
                return <results>
                        ok
                        </results>