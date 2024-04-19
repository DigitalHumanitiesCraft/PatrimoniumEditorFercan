xquery version "3.1";

import module namespace functx="http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
    
let $logs := doc('xmldb:exist:///db/apps/patrimoniumData/logs/logs-import-egyptianMaterial.xml')
let $teiTemplate := doc("xmldb:exist:///db/apps/patrimonium/data/teiEditor/docTemplates/teiTemplatePatrimoniumEgypt.xml")
let $collectionPrefix := "apcd"
let $doc-collection-path := "xmldb:exist:///db/apps/patrimoniumData/documents/documents-ybroux"
let $project-places-collection := collection("xmldb:exist:///db/apps/patrimoniumData/places/patrimonium")
let $lemmatizedCorpus := collection("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial")

let $HGV_metadata := collection("xmldb:exist:///db/apps/papyriInfo/data/HGV_meta_EpiDoc")
let $HGVNo := "22838"


let $peopleInLemmatizedFile := 
    <peopleInLemmatizedFile>
        {
        for $file in $lemmatizedCorpus//file
            return
                <file name="{ $file/@name }" tm="{ $file/@TM }" HVG="{ $file/@HGV }" xml:lang="{ $file/@lang }">
                {
                for $people in $file//word[@per_id]
                    let $tmPersNo := $people/@per_id
        
                return 
                    <mention corresp="{ $people/@per_id }"
                    row="{ $people/@row }" token="{ $people/@wordNum }">
                    <persName type="regularized">{ data($people/@regularized) }</persName>
                    <persName type="original">{ data($people/@original) }</persName>
                    </mention>
                }
                </file>
        }
    </peopleInLemmatizedFile>
    
return
    $peopleInLemmatizedFile