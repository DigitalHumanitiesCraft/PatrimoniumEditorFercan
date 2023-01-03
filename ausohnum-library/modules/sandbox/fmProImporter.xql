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

let $sourceFilename := "doc-alberto-20191008.xml"
(:let $sourceFilename := "sources-20190920-1320.xml":)
let $collectionName := "test1"

let $path2docs := "xmldb:exist:///db/apps/patrimoniumData/documents/"
let $pathForNewFile := $path2docs || $collectionName
let $logs := collection("xmldb:exist:///db/apps/patrimoniumData" || '/logs')
let $fmpSources := doc("xmldb:exist:///db/apps/patrimoniumData/fmProImports/" || $sourceFilename)



let $xslt := doc("xmldb:exist:///db/apps/ausohnum-library/xslt/fmProPatrimonium2xml.xsl")
let $xslParam :=
        <output:serialization-parameters
        xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:omit-xml-declaration value="no"/>
            <output:method value="xml"/>
            <output:indent value="yes"/>
            <output:undeclare-prefixes value="no"/>
        </output:serialization-parameters>


let $newTeiCorpus := transform:transform( $fmpSources, $xslt, $xslParam)



let $externalDocUris := <extDocUris>
                        {for $rows in $fmpSources//ROW
                            return 
                                <doc xml:id="patrimonium{ $rows//sourceID}">
                            
                                    <extDocUri>{ 
                                        if($rows//ext_source_uri/text()) then $rows//ext_source_uri/text()
                                        else "manual"
                                    }</extDocUri>
                                </doc>
                        }
                        </extDocUris>
return 
    
    for $teiDoc at $pos in $newTeiCorpus//tei:TEI
      
       let $docId := data($teiDoc/@xml:id)
       let $filename := $docId || ".xml"
       let $externalDocUri := $externalDocUris//doc[equals(./@xml:id, $docId)]//extDocUri
       let $ext_source_type :=$externalDocUris//doc[equals(./@xml:id, $docId)]//ext_source_type
       
               let $log :=
                    <data>
                        <log type="test-import" when="{$now}" what="doc-{ $pos }" who="{$currentUser}"><description>
                            $externalDocUri: { $externalDocUri }
                            
                            Test: 
                       
                        </description></log>
                     </data>
               
                   let $logTextBeforeParse :=
                        update insert
                            $log/node()
                     into $logs/rdf:RDF/id('all-logs')
               
       
       
       let $url4httpRequest := 
                    if($externalDocUri/text() !='' ) then 
                        (if(contains($externalDocUri/text(), 'edh-www.adw.uni-heidelberg.de/edh/inschrift/')) then
                            $externalDocUri/text() || ".xml"
                         else if(contains($externalDocUri/text(), 'http://papyri.info/ddbdp')) then
                                $externalDocUri/text() || "/source"
                         else if(contains($externalDocUri/text(), 'http://mama.csad.ox.ac.uk/monuments/MAMA-XI')) then
                                    (
                                let $externalDocId := substring-before(substring-after($externalDocUri, "http://mama.csad.ox.ac.uk/monuments/"), ".html")
                                    return 
                                    "http://mama.csad.ox.ac.uk/xml/" || $externalDocId || ".xml"
                                    )
                                    else if(contains($externalDocUri/text(), 'https://epigraphy.packhum')) then
                                    $externalDocUri
                                    
                                    else("STOP"))
                        else ($externalDocUri)
       
       
       
          
       
            let $http-request-data := 
                        if(($externalDocUri !='') and  ($externalDocUri!= "Manual")
                        or ($externalDocUri!= "Manual")) then 
                            <request xmlns="http://expath.org/ns/http-client"
                method="GET" href="{$url4httpRequest}"/>
                else ()









            let $responses :=if(($externalDocUri !='') and (not(contains($externalDocUri, 'Manual'))) ) then 
                http:send-request($http-request-data)
                else(<none/>)
            let $response :=if(($externalDocUri !='') and (not(contains($externalDocUri, 'Manual'))) ) then 
                <results>
                  {if ($responses[1]/@status ne '200')
                     then
                         <failure>{$responses[1]}</failure>
                     else
                       <success>
                         {$responses[2]}
                         {'' (: todo - use string to JSON serializer lib here :) }
                       </success>
                  }
                </results>
                else(<none/>)
       
       
       
       

       
       
       
       
            let $textDiv :=
                if(
                    (contains($externalDocUri, 'https://epigraphy.packhum'))
                    or (contains($ext_source_type, "Manual")
                    or contains($externalDocUri, 'Manual')
                    or ($externalDocUri ='') )
                  ) 
                  then
                    <div type="textpart"xmlns="http://www.tei-c.org/ns/1.0">
                        { teiEditor:convertIntoEpiDoc($teiDoc//tei:div[@type='textpart']//tei:ab) } </div>
                else
                        $response//tei:div[@type='edition']//tei:ab
       
       
       
       
       
       
                        
(:            let $apparatusDiv := $response//tei:div[@type='apparatus']:)
(:            let $biblioDiv := $response//tei:div[@type='apparatus']:)
            
            let $newDoc := 
            xmldb:store("xmldb:exist:///db/apps/patrimoniumData/documents/test1",
                        $filename,
                        <TEI xmlns="http://www.tei-c.org/ns/1.0">{ $teiDoc/node()} </TEI>,
                        "text/xml")
            
(:            let $updateTextDiv := update replace:)
(:            util:eval(doc($path2docs || 'alberto-test/' || $filename))/tei:TEI/tei:text:)
(:                with $textDiv:)


 
            let $updateTextDiv := 
(:            update replace:)
(:                    util:eval( "doc('" || $path2docs ||  $collectionName || '/' || $filename ||"')"):)
                    update replace util:eval( "doc('" || $path2docs ||  $collectionName || "/" || $filename
                                ||"')")/tei:TEI/tei:text/tei:body/tei:div[@type="edition"]
                with functx:change-element-ns-deep($textDiv, "http://www.tei-c.org/ns/1.0", "")
       
      
    return <results>
        {$filename, doc($path2docs || $collectionName || '/' || $filename)//tei:TEI}
        </results>