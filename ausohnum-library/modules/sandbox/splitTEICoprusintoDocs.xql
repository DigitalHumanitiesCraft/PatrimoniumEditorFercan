xquery version "3.1";
declare namespace tei="http://www.tei-c.org/ns/1.0";

let $corpusOrig := doc("/db/apps/patrimoniumData/imports/hernan/teiCorpusOrig.xml")
let $corpus4texts := doc("/db/apps/patrimoniumData/documents/documents-hgonzalez/teiCorpus.xml")
let $doc-collection-path := "/db/apps/patrimoniumData/imports/hernan/2"
return 
    for $doc in $corpusOrig//tei:TEI
        let $docId:=data($doc/@xml:id)
        let $id:=substring-after($docId, "apcd")
        let $filename:= $docId ||".xml"
        
        let $storeNewFile := 
            xmldb:store($doc-collection-path, $filename, $doc)
(:        let $newFile:=doc($doc-collection-path || "/" || $filename):)
(:        let $updateText :=:)
(:            if(xs:integer($id) > 542) then:)
(:                update replace $newFile//tei:div[@type="edition"] :)
(:                with $corpus4texts/id($docId)//tei:div[@type="edition"]  :)
(:            else():)
        return $docId 