xquery version "3.1";


declare namespace apc="https://ausohnum.huma-num.fr/apps/eStudium/onto#"; 
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace saxon="http://saxon.sf.net/";
declare namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/";
declare namespace tei="http://www.tei-c.org/ns/1.0";
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

let $xsl4CleaningData := xs:anyURI("xmldb:exist:///db/apps/ausohnum-library/xslt/cleanTextEdition.xsl")
                                (:let $xslCleanTeiFile := xs:anyURI("xmldb:exist:///db/apps/ausohnum-library/xslt/cleanTeiFile.xsl"):)

let $cleanTeiFile :=  transform:transform($data/node(), $xsl4CleaningData, ())
let $cleanTeiFileLocaName :=  transform:transform($data/*[local-name()='data'], $xsl4CleaningData, ())
let $cleanedTeiHeader := $cleanTeiFile/teiFile/TEI/teiHeader
let $newTextParts := for $textpart at $index in $data//teiText//ab
         let $parsedText := util:parse-html(<ab>{replace(replace($textpart, '&lt;', '<'), '&gt;', '>')}</ab>)
            return
            (
            <div xml:id="{$data//tei:div[@type='edition']/tei:div[@type='textpart'][$index]/@xml:id}" subtype="{$textpart/@subtype}" type="textpart" >
                    
                    
                    
                    
                    <ab>
                    {$parsedText/HTML/BODY/node()}
            
                    </ab>
                        
                    </div>
            )

let $doc-collection := collection('/db/apps/patrimonium/data/documents')
let $docId := data($cleanTeiFile/teiFile/TEI/@xml:id)
let $teiDoc := $doc-collection//id($docId)
let $logs := collection("/db/apps/patrimonium/data/logs")

let $now := fn:current-dateTime()
let $currentUser := sm:id()

(:let $replaceHeader := update delete $teiDoc/teiHeader :)

let $replaceHeader := update replace $teiDoc//tei:teiHeader with $data//tei:TEI/tei:teiHeader

let $replaceText := update replace $teiDoc//tei:div[@type='edition']/tei:div[@type="textpart"] with $newTextParts/node()


let $logInjection := 
    update insert
    <apc:log type="document-update" when="{$now}" what="{$docId}" who="{$currentUser}">
        
        <newText>{$newTextParts}</newText>
    </apc:log> into $logs/rdf:RDF/id('all-logs')

return
null
