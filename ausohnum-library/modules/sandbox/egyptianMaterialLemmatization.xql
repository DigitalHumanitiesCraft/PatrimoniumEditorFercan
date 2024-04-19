xquery version "3.1";

import module namespace kwic="http://exist-db.org/xquery/kwic";


import module namespace http="http://expath.org/ns/http-client" at "java:org.expath.exist.HttpClientModule";
import module namespace teiEditor="http://ausonius.huma-num.fr/teiEditor"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/teiEditor/teiEditorApp.xql";
import module namespace prosopoManager="http://ausonius.huma-num.fr/prosopoManager"
      at "xmldb:exist:///db/apps/ausohnum-library/modules/prosopoManager/prosopoManager.xql";

import module namespace functx="http://www.functx.com";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace lawd="http://lawd.info/ontology/";
declare namespace pleiades="https://pleiades.stoa.org/places/vocab#";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#"; 
declare namespace geo="http://www.w3.org/2003/01/geo/wgs84_pos#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace ausohnum="http://ausonius.huma-num.fr/onto";
declare namespace spatial="http://geovocab.org/spatial#";
declare boundary-space preserve;

let $now := fn:current-dateTime()
let $currentUser := data(sm:id()//sm:username)
    
let $logs := doc('xmldb:exist:///db/apps/patrimoniumData/logs/logs-import-egyptianMaterial.xml')
let $teiTemplate := doc("xmldb:exist:///db/apps/patrimonium/data/teiEditor/docTemplates/teiTemplatePatrimoniumEgypt.xml")
let $collectionPrefix := "apcd"
let $doc-collection-path :=  "/db/apps/patrimoniumData/documents/documents-ybroux"
let $documents := collection("xmldb:exist:///db/apps/patrimoniumData/documents/documents-ybroux")
let $people := collection("xmldb:exist:///db/apps/patrimoniumData/people")
let $project-places-collection := collection("xmldb:exist:///db/apps/patrimoniumData/places/patrimonium")
let $lemmatizedCorpus := collection("xmldb:exist:///db/apps/patrimoniumData/egyptianMaterial/docYanneBroux")
let $paramMap :=
        map {
            "method": "xml",
            "indent": false(),
            "item-separator": ""
            }

return

for $lemDoc at $pos in $lemmatizedCorpus//file
    where $pos >1 
(:    and $pos < 3:)
    let $docNo := substring-after($lemDoc/@text, '/text/')
    let $teiDoc := $documents//tei:TEI[.//tei:idno[@type="tm"][matches(., $docNo)]]
    let $teiDocId := data($teiDoc/@xml:id)
    
    let $processPeople :=
if(exists($teiDoc//tei:rs[@type="person"])) then (
    let $insertLog := 
                            update insert
                <log when="{ $now }">{Document || $teiDocId || " not processed for people as already processed"}</log>
                into $logs/rdf:RDF
                return ()
    )
            
else
        for $mention in $lemDoc//word[./@per]
            
            let $originalLemma := replace($mention/@original, "\[|\(|\]|\)", " ")
            
            
            let $apcNo := if($people//lawd:person[skos:exactMatch[@rdf:resource=$mention/@per]]) 
                        then substring-before($people//lawd:person[skos:exactMatch[@rdf:resource=$mention/@per]]/@rdf:about, "#")
                        else "error:cannot-retireve-apc-uri"
            let $matches := $teiDoc//tei:div[@type="edition"]//tei:ab[ft:query(., $originalLemma)]
                
            
            let $expandedResult := util:expand($matches, "expand-xincludes=no")
            let $resultAsString := serialize(<results>{ $expandedResult } </results>)
            
           
            
            let $resultAsString := 
                replace(
                    replace(
                    $resultAsString, '</exist:match></supplied><exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">',
                                 '</supplied>' )
                        , '</exist:match><supplied reason="lost"><exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">', '<supplied reason="lost">')
            let $resultAsString := 
                replace(
                    replace(
                    $resultAsString
                    , '</exist:match><ex><exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">', '<ex>')
                    
                    '</exist:match></ex><exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">',
                                 '</ex>' )
                        
                                 

            
            
            let $updatedAb := functx:change-element-ns-deep(
            parse-xml(replace(replace($resultAsString, '<exist:match xmlns:exist="http://exist.sourceforge.net/NS/exist">',
                         '<rs type="person" ref="' || $apcNo || '">' ),
                         '</exist:match>', "</rs>")
                    )
                    , "http://www.tei-c.org/ns/1.0", "")
        
            
        
            let $abDetails :=
                    <locations>{
                    for $ab at $pos in $teiDoc//tei:div[@type="edition"]//tei:ab[ft:query(., $originalLemma)]
                    let $pathToAb := functx:path-to-node-with-pos($ab)
                    return 
                        <item n="{ $pos }" doc="{data($ab//ancestor-or-self::tei:TEI/@xml:id)}">{ $pathToAb }</item>
                    }</locations>        
        
            let $updateEachAb :=
                for $ab at $pos in $teiDoc//tei:div[@type="edition"]//tei:ab[ft:query(., $originalLemma)]
                    let $xpathToAb := "tei:" || replace(substring-after(functx:path-to-node-with-pos($ab), "TEI/"), '/', '/tei:')
                    let $updateData := if(string-length($xpathToAb) > 4) then
                                        update replace 
                                           util:eval( "collection('" || $doc-collection-path || "')/id('" || $teiDocId || "')//" || $xpathToAb)
                                            with $updatedAb/tei:ab[$pos]
                                    else ()
                    let $insertLog :=
                                update insert
<log when="{ $now }">Person {$apcNo} marked in document { $teiDocId}
                </log>
                into $logs/rdf:RDF
            return "doc " || $teiDocId || " processed with people"
        
        
        return 
            <data>
            </data>
                

    
return
    <result xmlns:tei="http://www.tei-c.org/ns/1.0">
    { $processPeople }
    </result>


