xquery version "3.1";
import module namespace functx="http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare boundary-space preserve;

    let $docs:= collection("/db/apps/gymnasiaData/documents")
let $concepts :=(["http://ausonius.huma-num.fr/concept/c19329","https://ausohnum.huma-num.fr/concept/c19892"],
["http://ausonius.huma-num.fr/concept/c19333","https://ausohnum.huma-num.fr/concept/c19898"],
["http://ausonius.huma-num.fr/concept/c19334","https://ausohnum.huma-num.fr/concept/c19899"],
["http://ausonius.huma-num.fr/concept/c19335","https://ausohnum.huma-num.fr/concept/c19900"],
["http://ausonius.huma-num.fr/concept/c19336","https://ausohnum.huma-num.fr/concept/c19904"],
["http://ausonius.huma-num.fr/concept/c19344","https://ausohnum.huma-num.fr/concept/c19914"],
["http://ausonius.huma-num.fr/concept/c19345","https://ausohnum.huma-num.fr/concept/c19916"],
["http://ausonius.huma-num.fr/concept/c19347","https://ausohnum.huma-num.fr/concept/c19922"])

for $concept in $concepts
    let $oldConcept := array:get($concept, 1)
    let $newConcept := array:get($concept, 2)
    let $matches := $docs//tei:rs[@ref= $oldConcept]
    let $updateMatches :=  update value $matches/@ref with $newConcept
    let $InsertChangeNote:=
        for $match in $matches
        let $teiDoc:= root($match)
        let $changeNode := <node>
           <change when="{ fn:current-dateTime() }" who="http://ausohnum.huma-num.fr/people/vrazanajao">Update @ref in tei:rs with correct concept URI</change></node>
        let $insertRevisionChange := if($teiDoc//tei:change[contains(@when, "2022-02-23")]) then () else
                            update insert
                            ('&#xD;&#xa;',
                            functx:change-element-ns-deep($changeNode, "http://www.tei-c.org/ns/1.0", "")/node())
                              following $teiDoc//tei:revisionDesc/tei:listChange/tei:change[last()]
        return 
            ()
    
    return ( "replace " || $oldConcept || " with " || $newConcept || " for " || serialize($matches)
           )