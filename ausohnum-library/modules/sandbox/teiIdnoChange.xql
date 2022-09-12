xquery version "3.1";
import module namespace functx="http://www.functx.com";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare boundary-space preserve;


let $docs := collection("/db/apps/patrimoniumData/documents")


for $doc in $docs//tei:teiHeader/tei:fileDesc[tei:publicationStmt/tei:idno[@type="EDR"]]

    let $origIdno := $doc//tei:publicationStmt//tei:idno[@type="EDR"]
    let $targetIdno := $doc//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:altIdentifier/tei:idno[not(text())][@type="uri"]
    let $updateData := 
        if($targetIdno) then (
            update insert attribute subtype { lower-case(data($origIdno/@type))} into $targetIdno,
(:            update insert attribute subtype { "mamaXI"} into $targetIdno,:)
            update value $targetIdno with $origIdno/text(),
        
        functx:change-element-ns-deep(
                    functx:change-element-names-deep(
                         $doc//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:altIdentifier/tei:idno[@type="uri"][@subtype=lower-case(data($origIdno/@type))],
                         xs:QName('tei:idno'),
                         xs:QName('idno'))
             , "http://www.tei-c.org/ns/1.0", "")
            
            )
        else (
            let $newIdno := <tei:data><tei:altIdentifier>
                    <tei:idno type="uri" subtype="{ lower-case(data($origIdno/@type)) }">{ $origIdno/text() }</tei:idno>
                </tei:altIdentifier>
                </tei:data>
            return update insert 
            functx:change-element-ns-deep($newIdno/node(), "http://www.tei-c.org/ns/1.0", "")
            into $doc//tei:sourceDesc/tei:msDesc/tei:msIdentifier
            )
    let $deleteOrigIdno := update delete $origIdno
    
return 
    
    <results>
        OK for {$doc//tei:publicationStmt/tei:idno[@type="uri"]/text()}
        </results>