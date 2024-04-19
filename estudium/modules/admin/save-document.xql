xquery version "3.1";


declare namespace apc="https://ausohnum.huma-num.fr/apps/eStudium/onto#"; 
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace saxon="http://saxon.sf.net/";

(:declare default element namespace "http://www.tei-c.org/ns/1.0";:)

(:declare option exist:serialize "method=xml media-type=text/xml
omit-xml-declaration=yes indent=yes";:)

declare option output:method "xml";
declare option output:media-type "text/xml";
declare option output:indent "yes";
declare option output:omit-xml-declaration "yes";
declare option saxon:output "indent=yes";

let $data := request:get-data()
(:let $ancientText := util:parse-html(replace(replace($data/data/teiText//div[@type='textpart']/*, '&lt;', '<'), '&gt;', '>')):)

let $xslCleanDiv := xs:anyURI("xmldb:exist:///db/apps/ausohnum-library/xslt/cleanTextEdition.xsl")
(:let $xslCleanTeiFile := xs:anyURI("xmldb:exist:///db/apps/ausohnum-library/xslt/cleanTeiFile.xsl"):)

let $cleanTeiFile :=  transform:transform($data/*[local-name()='data'], $xslCleanDiv, ())

let $doc-collection := collection('/db/apps/patrimonium/data/documents')
let $docId := data($data//TEI/@xml:id)
let $teiDoc := $doc-collection//id($docId)
let $logs := collection("/db/apps/patrimonium/data/logs")

let $now := fn:current-dateTime()
let $currentUser := sm:id()

(:let $replaceHeader := update delete $teiDoc/teiHeader :)
(:let $replaceHeader := update replace $teiDoc//teiHeader with $data//teiHeader:)
(:let $replaceText := update replace $doc-collection//id($docId)/text with $data/data/teiFile/node()/text:)


let $logInjection := 
    update insert
    <apc:log type="document-update" when="{$now}" what="{$docId}" who="{$currentUser}">
        <data>{$data}</data>
        <!--<teiClean>{$cleanTeiFile}</teiClean>-->
        <teiClean>{$cleanTeiFile}</teiClean>
        <teiHeader>{$data//teiHeader/node()}</teiHeader>
        <teiTextpart>{$data//text/.//div[@type='textpart']}</teiTextpart>
        <teiText>{$data/*[local-name()='data']/*[local-name()='teiText']/*[local-name()='div'][@type='edition']/*[local-name()='div'][@type='textpart']}</teiText>
            <teiTextLoop>{
                for $textpart in $data/*[local-name()='data']/*[local-name()='teiText']/*[local-name()='div'][@type='edition']//*[local-name()='div'][@type='textpart']
                  let $text := $textpart//text()
                  let $cleanedText := util:parse-html(<ab>{replace(replace($textpart, '&lt;', '<'), '&gt;', '>')}</ab>)
(:                let $testcleaning :=  util:parse-html(<a>dededed</a>):)
(:                  let $cleanedText := <ab>{replace(replace($text, '&lt;', '<'), '&gt;', '>')}</ab>:)
                  
                return
                (<div n="{$textpart/@n}" subtype="{$textpart/@subtype}" type="textpart">
                    <ab>
                    {$cleanedText/HTML/BODY/node()}
            
                    </ab>
                        
                    </div>)
                }</teiTextLoop>
    </apc:log> into $logs/rdf:RDF/id('all-logs')

return
null
