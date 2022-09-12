xquery version "3.1";

import module namespace skosThesau="https://ausohnum.huma-num.fr/skosThesau/" at "/db/apps/ausohnum-library/modules/skosThesau/skosThesauApp.xql";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";

declare variable $project := "patrimonium";
declare variable $collection := "places/patrimonium";
(:declare variable $thesaurusTopConceptUri external;:)

(:declare variable $thesaurusConcepts := skosThesau:getChildren($thesaurusTopConceptUri, $project);:)

declare variable $xpathTextNode := "pleiades:hasFeatureType";
declare variable $attributeNode := "@rdf:resource";
declare variable $lang := "en";
declare variable $xpath := "*[local-name()= '" || substring-after($xpathTextNode, ":") || "']";

let $nodes := util:eval( "collection('/db/apps/" || $project || "Data/" || $collection || "')//" || $xpath)
let $attributesNodes := util:eval( "collection('/db/apps/" || $project || "Data/" || $collection || "')//" || $xpath || "/" || $attributeNode)
let $processNodes :=
        for $node at $pos in $nodes
            let $attribute := data($attributesNodes[$pos])
            let $uptodateLabel := skosThesau:getLabel($attribute, "en", $project)
            let $labelRequireUpdate := ($uptodateLabel = $node)
            let $updateLabel:= if($labelRequireUpdate = false()) then 
                            update replace  $nodes[$pos]/text() with $uptodateLabel
                            else ()
         
         let $log := if($labelRequireUpdate = false()) then 
                "pos= " || $pos || " - uri: " || $attribute || " - current label: " || $node || " - up-to-date?: " || $labelRequireUpdate || " - should be: " || $uptodateLabel
                else ()
    return $log
return 
    <result>{
 $processNodes
    }</result>
             