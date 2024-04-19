xquery version "3.1";

import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager" at "db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

let $biblio := collection("/db/apps/gymnasiaData/biblio")
let $docs := collection("/db/apps/gymnasiaData/documents")
let $docTest := doc("/db/apps/gymnasiaData/documents/gymnasia/gymnasia1.xml")
let $logs :=doc("/db/apps/gymnasiaData/logs/logs-debug.xml")//rdf:RDF
for $biblioRef in $docs//tei:ptr
    let $ref := $biblioRef/@target
    
    
    
return 

    if (starts-with($ref, "#")) then
        let $newTarget := data($biblio/id(substring-after($ref, "#"))/@corresp)
        let $log := <data>
            <log doc="{data($biblioRef/ancestor::tei:TEI/@xml:id)}" ref="{$ref}" newTarget="{$newTarget}"/></data>
        return
            (
            if($newTarget != "")then(
                update value $biblioRef/@target with $newTarget,
                update insert $log/node() into $logs
            )else (
                    let $log := <data><log doc="{data($biblioRef/ancestor::tei:TEI/@xml:id)}" ref="{$ref}" newTarget=""/></data>
                    return
                        update insert $log/node() into $logs
                    )
            )
    
    else(
        let $log := <data><log doc="{data($biblioRef/ancestor::tei:TEI/@xml:id)}" ref="{$ref}" newTarget=""/></data>
        return
            update insert $log/node() into $logs
        )
