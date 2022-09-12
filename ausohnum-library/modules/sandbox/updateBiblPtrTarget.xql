xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

let $documents := collection("/db/apps/patrimoniumData/documents")
let $biblioCollection := doc("/db/apps/patrimoniumData/biblio/biblio.xml")
let $refs :=
(:<ref>{:)
    for $ptr in $documents//tei:bibl/tei:ptr
        let $targetOld := $ptr/@target[1]
        let $targetNew := data($biblioCollection//id(substring-after($targetOld, "#"))/@corresp)
        return
            update value $ptr/@target with $targetNew
(:     }</ref>   :)
 
return "ok"

